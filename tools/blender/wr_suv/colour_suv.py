# Colour pass for the SUV body (wr-3d-suv, 10-21; copied from wr_body/colour_body.py): per-face material slots from
# build_suv.py (codes measured on
# the concept, measure_colours_suv.py) are baked to textures and exported as PBR GLBs (base + ORM), one per part.
#   blender --background --factory-startup --python tools/blender/wr_suv/colour_suv.py -- <suv_body_slots.blend> <deliver_dir> <preview_dir>
# Paint is NEUTRAL (#E6E6E6) in the ColorMap so code can recolour each customer car; the default paint code and the
# paint mask are written separately:
#   <part>_color.png          base colour, paint neutral (= GLB baseColor)
#   <part>_color_overlay.png  same RGB, alpha 0 on paint / 1 elsewhere  -> SurfaceAppearance.AlphaMode = Overlay,
#                             MeshPart.Color = paint colour (the part colour shows through the transparent paint area)
#   <part>_paintmask.png      white = paint
#   <part>_roughness.png, <part>_metalness.png (Roblox wants them separate), <part>_orm.png (packed, in the GLB)
#   <part>_emissive.png       white = lamps (light bar / tail lamp / reflectors), for a glow option
#   preview GLBs (<preview_dir>) carry the default blue in the base colour, for review renders only.
import bpy, bmesh, sys, os, math, json
import numpy as np

a = sys.argv[sys.argv.index("--") + 1:]
SRC, OUT, PREV = os.path.abspath(a[0]), os.path.abspath(a[1]), os.path.abspath(a[2])
os.makedirs(OUT, exist_ok=True); os.makedirs(PREV, exist_ok=True)
TEX = {"Shell": 2048, "Bumper_F": 1024, "Bumper_R": 1024, "Hood": 1024, "Chassis": 1024, "Glass": 256}
if len(a) > 3:     # other objects, e.g. "Deco_EngineTop:1024,Deco_EngineBay:1024"
    TEX = {k: int(v) for k, v in (t.split(":") for t in a[3].split(","))}
ALL_NAME = a[4] if len(a) > 4 else "suv_body_all"
SMOOTH = float(a[5]) if len(a) > 5 else 40.0      # decor: 61 (6/8-sided hoses read smooth, box edges stay sharp)
bpy.ops.wm.open_mainfile(filepath=SRC)
sc = bpy.context.scene
cj = os.path.join(os.path.dirname(OUT), "work", "colours.json")   # art/3d/suv_body/work/colours.json
COL = json.load(open(cj)) if os.path.exists(cj) else {}
PAINT_DEFAULT = COL.get("paint", {}).get("hex", "#7C8A71")
hexrgb = lambda h: tuple(int(h[i:i + 2], 16) / 255 for i in (1, 3, 5))


def activate(ob):
    for o in sc.objects:
        o.select_set(o == ob)
    bpy.context.view_layer.objects.active = ob


def uv_unwrap(ob):
    """UV islands split at material borders (colour borders = polygon edges, no stair steps); sharp edges kept"""
    me = ob.data
    sh = me.attributes.get("sharp_edge")
    keys = set()
    if sh is not None:
        for e in me.edges:
            if sh.data[e.index].value:
                keys.add(tuple(sorted(tuple(round(c, 5) for c in me.vertices[v].co) for v in e.vertices)))
    bm = bmesh.new(); bm.from_mesh(me)
    border = [e for e in bm.edges if len(e.link_faces) == 2 and e.link_faces[0].material_index != e.link_faces[1].material_index]
    bmesh.ops.split_edges(bm, edges=border)
    bm.to_mesh(me); bm.free()
    activate(ob)
    bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.004)
    bpy.ops.mesh.remove_doubles(threshold=1e-6)
    bpy.ops.object.mode_set(mode='OBJECT')
    sh = me.attributes.get("sharp_edge") or me.attributes.new("sharp_edge", 'BOOLEAN', 'EDGE')
    n = 0
    for e in me.edges:
        k = tuple(sorted(tuple(round(c, 5) for c in me.vertices[v].co) for v in e.vertices))
        if k in keys:
            sh.data[e.index].value = True; n += 1
    bpy.ops.object.shade_smooth(keep_sharp_edges=True)
    bpy.ops.object.shade_smooth_by_angle(angle=math.radians(SMOOTH), keep_sharp_edges=True)
    return n


def bake(ob, tex, kind):
    im = bpy.data.images.new(kind, tex, tex, alpha=False, float_buffer=True); im.colorspace_settings.name = 'Non-Color'
    for m in ob.data.materials:
        nt = m.node_tree; N = nt.nodes
        for n_ in [n_ for n_ in N if n_.name.startswith("wr_")]:
            N.remove(n_)
        em = N.new("ShaderNodeEmission"); em.name = "wr_em"
        c = hexrgb(m["wr_hex"])
        if kind == "base_prev" and m["wr_paint"]:
            c = hexrgb(PAINT_DEFAULT)
        val = {"base": c, "base_prev": c, "orm": (1.0, m["wr_rough"], m["wr_metal"]),
               "mask": (float(m["wr_paint"]),) * 3, "emit": (float(m["wr_emit"]),) * 3}[kind]
        em.inputs["Color"].default_value = (*val, 1)
        out_n = [n_ for n_ in N if n_.type == 'OUTPUT_MATERIAL'][0]
        nt.links.new(em.outputs[0], out_n.inputs["Surface"])
        ti = N.new("ShaderNodeTexImage"); ti.name = "wr_tex"; ti.image = im; N.active = ti
    bpy.ops.object.bake(type='EMIT')
    arr = np.empty(tex * tex * 4, np.float32); im.pixels.foreach_get(arr)
    return arr.reshape(tex, tex, 4)


def pad(arrs, cov, it=64):
    """fill empty texture space with the nearest island colour (mipmaps would pull in black)"""
    out = {}
    for k, A0 in arrs.items():
        A = A0[:, :, :3].copy(); m = cov.copy()
        for _ in range(it):
            if m.all():
                break
            acc = np.zeros_like(A); cnt = np.zeros(m.shape, np.float32)
            for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                mm = np.roll(np.roll(m, dy, 0), dx, 1); aa = np.roll(np.roll(A, dy, 0), dx, 1)
                acc += aa * mm[..., None]; cnt += mm
            new = (~m) & (cnt > 0)
            A[new] = acc[new] / cnt[new][:, None]; m = m | new
        out[k] = A
    return out


def save(path, A, alpha=None, srgb=True):
    h, w = A.shape[:2]
    rgba = np.ones((h, w, 4), np.float32); rgba[:, :, :3] = A
    if alpha is not None:
        rgba[:, :, 3] = alpha
    o = bpy.data.images.new(os.path.basename(path), w, h, alpha=alpha is not None)
    o.colorspace_settings.name = 'sRGB' if srgb else 'Non-Color'
    o.pixels.foreach_set(rgba.ravel()); o.update()
    o.filepath_raw = path; o.file_format = 'PNG'; o.save()
    return path


def pbr_material(name, basep, ormp):
    pm = bpy.data.materials.new(name); pm.use_nodes = True; N = pm.node_tree.nodes; L = pm.node_tree.links
    for n_ in list(N):
        N.remove(n_)
    o_ = N.new("ShaderNodeOutputMaterial"); b = N.new("ShaderNodeBsdfPrincipled"); L.new(b.outputs[0], o_.inputs["Surface"])
    tb = N.new("ShaderNodeTexImage"); tb.image = bpy.data.images.load(basep); L.new(tb.outputs["Color"], b.inputs["Base Color"])
    to = N.new("ShaderNodeTexImage"); to.image = bpy.data.images.load(ormp); to.image.colorspace_settings.name = 'Non-Color'
    sp = N.new("ShaderNodeSeparateColor"); L.new(to.outputs["Color"], sp.inputs[0])
    L.new(sp.outputs["Green"], b.inputs["Roughness"]); L.new(sp.outputs["Blue"], b.inputs["Metallic"])
    pm.use_backface_culling = True
    return pm


def export(path, ob):
    activate(ob)
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_apply=True, export_yup=True)


sc.render.engine = 'CYCLES'; sc.cycles.device = 'CPU'; sc.cycles.samples = 1
sc.render.bake.margin = 4; sc.render.bake.use_selected_to_active = False
sc.view_settings.view_transform = 'Standard'
report = {"paint_default": PAINT_DEFAULT, "paint_neutral": "#E6E6E6", "parts": {}}
for name, tex in TEX.items():
    ob = bpy.data.objects[name]
    nsharp = uv_unwrap(ob)
    activate(ob)
    arrs = {k: bake(ob, tex, k) for k in ("base", "base_prev", "orm", "mask", "emit")}
    cov = arrs["orm"][:, :, 0] > 0.5
    P = pad(arrs, cov)
    low = name.lower()
    paths = {
        "color": save(os.path.join(OUT, f"suv_{low}_color.png"), P["base"]),
        "color_overlay": save(os.path.join(OUT, f"suv_{low}_color_overlay.png"), P["base"], alpha=1.0 - P["mask"][:, :, 0]),
        "paintmask": save(os.path.join(OUT, f"suv_{low}_paintmask.png"), P["mask"], srgb=False),
        "orm": save(os.path.join(OUT, f"suv_{low}_orm.png"), P["orm"], srgb=False),
        "roughness": save(os.path.join(OUT, f"suv_{low}_roughness.png"), np.repeat(P["orm"][:, :, 1:2], 3, 2), srgb=False),
        "metalness": save(os.path.join(OUT, f"suv_{low}_metalness.png"), np.repeat(P["orm"][:, :, 2:3], 3, 2), srgb=False),
    }
    if P["emit"].max() > 0.5:
        paths["emissive"] = save(os.path.join(OUT, f"suv_{low}_emissive.png"), P["emit"], srgb=False)
    prev_base = save(os.path.join(PREV, f"suv_{low}_color_preview.png"), P["base_prev"])
    # deliverable GLB (neutral paint) and preview GLB (default blue)
    keep = list(ob.data.materials)
    pm = pbr_material(f"{name}_pbr", paths["color"], paths["orm"])
    ob.data.materials.clear(); ob.data.materials.append(pm)
    for p in ob.data.polygons:
        p.material_index = 0
    export(os.path.join(OUT, f"suv_{low}.glb"), ob)
    pv = pbr_material(f"{name}_pbr_preview", prev_base, paths["orm"])
    ob.data.materials.clear(); ob.data.materials.append(pv)
    export(os.path.join(PREV, f"suv_{low}.glb"), ob)
    ob.data.materials.clear(); ob.data.materials.append(pm)
    report["parts"][name] = dict(tris=sum(len(p.vertices) - 2 for p in ob.data.polygons), tex=tex, sharp_edges_kept=nsharp,
                                 paint_px=int((P["mask"][:, :, 0] > 0.5).sum()), files={k: os.path.basename(v) for k, v in paths.items()})
    print(name, report["parts"][name])
# all parts together (deliverable look + preview look)
objs = [bpy.data.objects[n] for n in TEX]
for o in sc.objects:
    o.select_set(o in objs)
bpy.context.view_layer.objects.active = objs[0]
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, ALL_NAME + ".glb"), export_format='GLB', use_selection=True, export_yup=True)
for n in TEX:
    ob = bpy.data.objects[n]
    ob.data.materials.clear(); ob.data.materials.append(bpy.data.materials[f"{n}_pbr_preview"])
bpy.ops.export_scene.gltf(filepath=os.path.join(PREV, ALL_NAME + ".glb"), export_format='GLB', use_selection=True, export_yup=True)
json.dump(report, open(os.path.join(OUT, ALL_NAME.replace("_all", "") + "_paint.json"), "w"), indent=1)
print("COLOUR DONE")
