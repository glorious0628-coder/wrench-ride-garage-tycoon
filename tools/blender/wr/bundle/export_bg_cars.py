# Export bought-bundle cars (Cars Full, CC0) as our background cars: one mesh, one material, shared atlas.
#   blender --background --factory-startup --python export_bg_cars.py -- <cars.json> <out_dir>
# cars.json: {"atlas": "<bg_cars_atlas.png>", "atlas_worn": "<..._worn.png>",
#             "cars": [{"name": "BG_Sedan_1", "src": "<glb>", "length": 17.0, "worn": false}, ...]}
# Frame (Roblox / our README): 1 BU = 1 stud, GLB front = -Z, up = +Y, origin = ground between the two axles
# (x = wheel centre line). Uniform scale so the car length = "length". Body + 4 wheels joined (wheels don't turn).
# UVs re-laid for the shared atlas (see build_atlas.py): atlas mats v' = 0.25 + 0.75 v; glass cell -> bottom-left.
import bpy, sys, os, json, math
from mathutils import Vector, Matrix
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bundle_lib as B  # noqa: E402

argv = sys.argv[sys.argv.index("--") + 1:]
cfg = json.load(open(argv[0], encoding="utf-8")); out = os.path.abspath(argv[1]); os.makedirs(out, exist_ok=True)
stats = {}


def make_material(name, img_path):
    m = bpy.data.materials.new(name); m.use_nodes = True
    nt = m.node_tree; b = nt.nodes["Principled BSDF"]
    t = nt.nodes.new("ShaderNodeTexImage"); t.image = bpy.data.images.load(img_path, check_existing=True)
    nt.links.new(t.outputs["Color"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = 0.62; b.inputs["Metallic"].default_value = 0.0
    m.use_backface_culling = True
    return m


# camera directions (centre -> camera) of tools/blender/backface_views.py + game-like low views
VIEW_DIRS = [(0.5, 1, -0.6), (-1, 0.3, -0.5), (0.01, 0.2, -1), (1, 0.2, 0.1), (0.2, -1, 0.9), (0, 1, -0.0875), (0, 1, 0.0875),
             (-1, 0.0875, 0), (1, 0.0875, 0), (-0.7, 0.7, -0.087), (0.7, 0.7, 0.087), (0, -1, -0.0875), (0, -1, 0.3),
             (-1, -0.5, 0.3), (1, 0.5, 0.3), (-0.6, 0.6, 0.6), (0.6, -0.6, 0.6), (0, 0, 1)]


def fix_backfaces(ob, step=0.04):
    """faces that a camera from VIEW_DIRS sees from behind (source pack relied on double-sided materials) get a
    flipped copy (own verts, negated custom normals). Returns the number of faces copied."""
    import bmesh
    from mathutils.bvhtree import BVHTree
    me = ob.data
    bm = bmesh.new(); bm.from_mesh(me); bm.faces.ensure_lookup_table()
    tree = BVHTree.FromBMesh(bm)
    lo = Vector((min(v.co.x for v in bm.verts), min(v.co.y for v in bm.verts), min(v.co.z for v in bm.verts)))
    hi = Vector((max(v.co.x for v in bm.verts), max(v.co.y for v in bm.verts), max(v.co.z for v in bm.verts)))
    cen = (lo + hi) / 2; rad = (hi - lo).length / 2 + 0.5
    bad = set()
    for d in VIEW_DIRS:
        d = Vector(d).normalized(); ray = -d
        a = d.orthogonal().normalized(); b = d.cross(a).normalized()
        n = int(2 * rad / step)
        for i in range(n):
            for j in range(n):
                o = cen + d * (rad + 1) + a * (-rad + i * step) + b * (-rad + j * step)
                loc, nor, idx, dist = tree.ray_cast(o, ray, 4 * rad)
                if idx is not None and nor.dot(ray) > 1e-4:
                    bad.add(idx)
    bm.free()
    if not bad:
        return 0
    # copy those faces flipped, with their own vertices; carry UVs; negate custom normals on the copies
    # final per-corner normals before the edit (keeps the pack's smoothing); copies get the negated ones
    cn_old = [tuple(c.vector) for c in me.corner_normals]
    uv = me.uv_layers.active.data
    polys = [me.polygons[i] for i in sorted(bad)]
    new_v, new_f, new_uv, new_cn = [], [], [], []
    nv0 = len(me.vertices)
    for p in polys:
        lis = list(p.loop_indices)[::-1]
        ids = []
        for li in lis:
            vi = me.loops[li].vertex_index
            new_v.append(me.vertices[vi].co.copy()); ids.append(nv0 + len(new_v) - 1)
            new_uv.append(tuple(uv[li].uv))
            new_cn.append(tuple(-x for x in cn_old[li]))
        new_f.append(ids)
    nl0 = len(me.loops); np0 = len(me.polygons)
    me.vertices.add(len(new_v))
    for k, co in enumerate(new_v):
        me.vertices[nv0 + k].co = co
    nloops = sum(len(f) for f in new_f)
    me.loops.add(nloops); me.polygons.add(len(new_f))
    li = nl0
    for k, f in enumerate(new_f):
        P = me.polygons[np0 + k]; P.loop_start = li; P.material_index = 0
        for vi in f:
            me.loops[li].vertex_index = vi; li += 1
    me.update(calc_edges=True)
    uv = me.uv_layers.active.data
    for k, t in enumerate(new_uv):
        uv[nl0 + k].uv = t
    me.validate(); me.update()
    if len(me.loops) == nl0 + len(new_cn):
        me.normals_split_custom_set(cn_old + new_cn)
    else:
        print("WARN loop count changed by validate; custom normals not reset", len(me.loops), nl0 + len(new_cn))
    return len(polys)


for car in cfg["cars"]:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    # 1) numbers with wheels still separate
    E, meshes, info = B.place_bundle_car(car["src"], "tmp", length=car["length"])
    meas = B.measure_car(meshes, B.bundle_glass_pred); meas.update(info)
    org_tris = B.tri_count(meshes)
    # 2) bake world transforms into mesh data (instanced wheel meshes -> single user), re-lay UVs per material
    dg = bpy.context.evaluated_depsgraph_get()
    objs = []
    mws = {o.name: o.matrix_world.copy() for o in meshes}     # read all first (wheels may be children of the body)
    for o in meshes:
        o.parent = None; o.matrix_world = Matrix.Identity(4)
    for o in meshes:
        o.data = o.data.copy()
        mw = mws[o.name]
        o.data.transform(mw)
        if mw.determinant() < 0:
            o.data.flip_normals()
        me = o.data; uv = me.uv_layers.active.data
        for p in me.polygons:
            mn = o.material_slots[p.material_index].material.name.lower() if o.material_slots and o.material_slots[p.material_index].material else ""
            for li in p.loop_indices:
                u, v = uv[li].uv
                if "window" in mn:
                    uv[li].uv = ((u - 2 / 3) * 0.75, (v - 2 / 3) * 0.75)
                elif "sign" in mn:
                    raise RuntimeError("signs material not supported in the shared atlas: " + car["name"])
                else:
                    uv[li].uv = (u, 0.25 + 0.75 * v)
        objs.append(o)
    bpy.data.objects.remove(E)
    # 3) join, one material
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active
    ob.name = car["name"]; ob.data.name = car["name"]
    ob.data.materials.clear()
    mat = make_material("BG_Car_Worn" if car.get("worn") else "BG_Car", cfg["atlas_worn"] if car.get("worn") else cfg["atlas"])
    ob.data.materials.append(mat)
    for p in ob.data.polygons:
        p.material_index = 0
    # keep only the first UV map
    while len(ob.data.uv_layers) > 1:
        ob.data.uv_layers.remove(ob.data.uv_layers[-1])
    for a in [a for a in ob.data.attributes if a.name.startswith("Col") or a.domain == 'CORNER' and a.data_type in ('FLOAT_COLOR', 'BYTE_COLOR')]:
        ob.data.attributes.remove(a)
    bpy.context.view_layer.update()
    nfix = fix_backfaces(ob)
    lo, hi = B.bbox([ob])
    tris = B.tri_count([ob])
    path = os.path.join(out, car["name"] + ".glb")
    bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True)
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_yup=True, export_apply=True,
                              export_materials='EXPORT', export_image_format="AUTO", export_texcoords=True, export_normals=True,
                              export_animations=False, export_skins=False, export_morph=False)
    stats[car["name"]] = {"src": os.path.relpath(car["src"], B.ROOT).replace("\\", "/"), "worn": bool(car.get("worn")),
                          "scale": round(info["scale"], 4), "length_target": car["length"], "tris": tris, "tris_src": org_tris, "backface_faces_copied": nfix,
                          "size_stud_xyz": [round(hi.x - lo.x, 3), round(hi.z - lo.z, 3), round(hi.y - lo.y, 3)],
                          "bbox_min_roblox": [round(lo.x, 3), round(lo.z, 3), round(-hi.y, 3)],
                          "bbox_max_roblox": [round(hi.x, 3), round(hi.z, 3), round(-lo.y, 3)],
                          "measure": meas}
    print("EXPORTED", car["name"], tris, stats[car["name"]]["size_stud_xyz"], "bf_fix", nfix)
json.dump(stats, open(os.path.join(out, "bg_cars_stats.json"), "w", encoding="utf-8"), indent=1)
