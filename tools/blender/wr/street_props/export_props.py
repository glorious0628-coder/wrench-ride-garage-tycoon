# Cartoon City street props (RG Poly, CC0) -> our GLBs: one mesh, one material, shared atlas.
#   blender --background --factory-startup --python export_props.py -- <props_config.json> <_src dir> <out dir> [only_name]
# Needs <out>/street_props_atlas.png, _mr.png and _map.json from build_atlas.py.
# Frame (art/3d/README.md): 1 BU = 1 stud (pack metres / 0.28), GLB up = +Y, front = -Z (Blender +Y here),
# origin = ground centre of the bbox (fire escape stair: centre of its bottom end). Uniform scale, no reshaping.
# Triangles are kept as they are (no decimation). Faces that a camera would see from behind (the pack relies on
# double-sided materials; Roblox draws one side) get a flipped copy with its own vertices and negated normals.
# Mailbox: flat lid instead of the USPS-like dome, the front chute notch closed, the slot moved to the front with a
# small hood, the handle plate moved down to the front door; teal walls + dark grey lid (atlas recolour).
import bpy, bmesh, sys, os, json, math
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

argv = sys.argv[sys.argv.index("--") + 1:]
cfg = json.load(open(argv[0], encoding="utf-8")); src = os.path.abspath(argv[1]); out = os.path.abspath(argv[2])
only = argv[3] if len(argv) > 3 else None
AN = cfg["atlas"]["name"]
amap = json.load(open(os.path.join(out, AN + "_map.json"), encoding="utf-8"))
SRC_S = amap["src_size"]; AW, AH = amap["size"]
S = 1.0 / cfg["metres_per_stud"]
stats_p = os.path.join(out, "street_props_stats.json")
stats = json.load(open(stats_p, encoding="utf-8")) if (only and os.path.exists(stats_p)) else {}


# ---------------------------------------------------------------- helpers
def corner_normals(me):
    return [Vector(c.vector) for c in me.corner_normals]


def add_faces(me, faces, cn, mat_index=0, variant_attr=None, variant=0):
    """faces: list of [(co, uv, normal), ...] (each corner own vertex). Appends to mesh + cn list."""
    nv0, nl0, np0 = len(me.vertices), len(me.loops), len(me.polygons)
    nverts = sum(len(f) for f in faces)
    me.vertices.add(nverts); me.loops.add(nverts); me.polygons.add(len(faces))
    vi = nv0; li = nl0
    uvs = []
    for k, f in enumerate(faces):
        P = me.polygons[np0 + k]; P.loop_start = li; P.material_index = mat_index
        for co, uv, n in f:
            me.vertices[vi].co = co; me.loops[li].vertex_index = vi
            uvs.append(uv); cn.append(Vector(n)); vi += 1; li += 1
    me.update(calc_edges=True)
    uvd = me.uv_layers.active.data
    for k, uv in enumerate(uvs):
        uvd[nl0 + k].uv = uv
    if variant_attr:
        a = me.attributes[variant_attr]
        for k in range(len(faces)):
            a.data[np0 + k].value = variant
    return np0


def face_set(me, pred):
    return [p.index for p in me.polygons if pred(p)]


def src_px(uv):
    """Blender uv -> source atlas pixel (x right, y down)"""
    return uv[0] * SRC_S, (1.0 - uv[1]) * SRC_S


# ---------------------------------------------------------------- mailbox edit (source frame: metres, +X = front)
def edit_mailbox(ob, cn):
    me = ob.data
    uvd = me.uv_layers.active.data
    mats = [m.name for m in me.materials]
    var = me.attributes["wr_variant"]

    def is_shell(p):   # walls + dome use the blue strip (x ~497-501 px)
        x, y = src_px(uvd[p.loop_start].uv)
        return mats[p.material_index] == "City_Atlas" and 490 < x < 508 and y < 150

    shell = [p.index for p in me.polygons if is_shell(p)]
    ZW, ZC, ZT = 0.74, 0.795, 0.80          # wall top, chamfer top, lid top (pack: wall 0.609, dome 0.837)
    move = {(-0.255, 0.609): (-0.255, ZW), (-0.227, 0.723): (-0.232, ZC), (-0.150, 0.806): (-0.150, ZT),
            (-0.045, 0.837): (-0.045, ZT), (0.047, 0.837): (0.047, ZT), (0.152, 0.806): (0.152, ZT),
            (0.229, 0.723): (0.234, ZC), (0.257, 0.609): (0.257, ZW),
            (0.257, 0.585): (0.257, ZW),        # front chute ledge -> front wall top
            (0.029, 0.638): (0.234, ZC)}        # chute back wall foot -> front chamfer (closes the notch)
    sv = {me.loops[li].vertex_index for i in shell for li in me.polygons[i].loop_indices}
    moved = 0
    for vi in sv:
        v = me.vertices[vi]; key = (round(v.co.x, 3), round(v.co.z, 3))
        if key in move:
            v.co.x, v.co.z = move[key]; moved += 1
        else:
            assert abs(v.co.z - 0.067) < 0.002, ("unexpected shell vertex", key)
    me.update()
    for i in shell:   # dome/notch faces changed shape: flat normals; faces at the top -> dark grey lid copy
        p = me.polygons[i]
        for li in p.loop_indices:
            cn[li] = p.normal.copy()
        if min(me.vertices[me.loops[li].vertex_index].co.z for li in p.loop_indices) > ZW - 0.002:
            var.data[i].value = 1

    # parts that sat in the chute notch (now inside the box): slot frame on the ledge, plate + handle on its back wall
    def centre(p):
        return p.center

    def region(pred):
        return [p.index for p in me.polygons if p.index not in shell and pred(p)]
    slot = region(lambda p: 0.10 < centre(p).x < 0.19 and 0.56 < centre(p).z < 0.64)
    plate_handle = region(lambda p: centre(p).x < 0.09 and centre(p).z > 0.66)
    assert len(slot) == 32 and len(plate_handle) == 42, (len(slot), len(plate_handle))

    def verts_of(fs):
        return sorted({me.loops[li].vertex_index for i in fs for li in me.polygons[i].loop_indices})

    def bb(vs):
        cs = [me.vertices[i].co for i in vs]
        return (Vector((min(c.x for c in cs), min(c.y for c in cs), min(c.z for c in cs))),
                Vector((max(c.x for c in cs), max(c.y for c in cs), max(c.z for c in cs))))
    FRONT = 0.2565
    # slot frame: stand it up on the front wall (ledge normal (0.226, 0, 0.974) -> +X), centre z 0.645
    ang = math.atan2(0.974, 0.226)
    R = Matrix.Rotation(ang, 4, 'Y')
    vs = verts_of(slot); lo, hi = bb(vs); c = (lo + hi) / 2
    for i in vs:
        me.vertices[i].co = R @ (me.vertices[i].co - c)
    for i in slot:
        for li in me.polygons[i].loop_indices:
            cn[li] = (R.to_3x3() @ cn[li]).normalized()
    lo, hi = bb(vs)
    t = Vector((FRONT - lo.x, 0, 0.645 - (lo.z + hi.z) / 2))
    for i in vs:
        me.vertices[i].co += t
    slot_lo, slot_hi = bb(vs)
    # handle plate + handle: move to the front door, centre z 0.43
    vs2 = verts_of(plate_handle); lo2, hi2 = bb(vs2)
    t2 = Vector((FRONT - lo2.x, 0, 0.43 - (lo2.z + hi2.z) / 2))
    for i in vs2:
        me.vertices[i].co += t2
    me.update()
    # rain hood over the slot (new 12 tris, dark grey lid colour): sloped wedge from the wall
    y0, y1 = slot_lo.y - 0.015, slot_hi.y + 0.015
    zb = slot_hi.z + 0.006; zt_back = zb + 0.024; zt_front = zb + 0.010; x0, x1 = FRONT - 0.004, FRONT + 0.05
    V = {"b0": (x0, y0, zb), "b1": (x1, y0, zb), "b2": (x1, y1, zb), "b3": (x0, y1, zb),
         "t0": (x0, y0, zt_back), "t1": (x1, y0, zt_front), "t2": (x1, y1, zt_front), "t3": (x0, y1, zt_back)}
    quads = [("b0", "b3", "b2", "b1"), ("t0", "t1", "t2", "t3"), ("b0", "b1", "t1", "t0"), ("b2", "b3", "t3", "t2"),
             ("b1", "b2", "t2", "t1"), ("b3", "b0", "t0", "t3")]
    uv = (499.0 / SRC_S, 1.0 - 30.0 / SRC_S)       # a point in the blue strip -> variant 1 (dark grey lid)
    faces = []
    for q in quads:
        a, b, c_, d = (Vector(V[k]) for k in q)
        n = (b - a).cross(c_ - a).normalized()
        for tri in ((a, b, c_), (a, c_, d)):
            faces.append([(co, uv, n) for co in tri])
    ci = mats.index("City_Atlas")
    np0 = add_faces(me, faces, cn, mat_index=ci, variant_attr="wr_variant", variant=1)
    return {"verts_moved": moved, "slot_frame_tris": len(slot), "plate_handle_tris": len(plate_handle), "hood_tris_added": len(faces),
            "lid_faces": sum(1 for i in shell if var.data[i].value == 1)}


# ---------------------------------------------------------------- position rule -> variant (same as build_atlas.py)
def rule_variant(rule, pts):
    if not rule:
        return 0
    for c in rule["any"]:
        k = "xyz".index(c["coord"])
        vals = [p[k] + c.get("offset", 0.0) for p in pts]
        if c.get("abs"):
            vals = [abs(v) for v in vals]
        if min(vals) >= c["min_ge"]:
            return rule["variant"]
    return 0


def tag_by_rule(me, rule):
    var = me.attributes["wr_variant"]; n = 0
    for p in me.polygons:
        v = rule_variant(rule, [tuple(me.vertices[i].co) for i in p.vertices])
        var.data[p.index].value = v; n += (v != 0)
    return n


# ---------------------------------------------------------------- uv remap into the shared atlas
def remap_uvs(ob, prop):
    me = ob.data; uvd = me.uv_layers.active.data
    mats = [m.name for m in me.materials]
    var = me.attributes["wr_variant"]
    ents = [e for e in amap["entries"] if e["prop"] == prop]
    used = set(); miss = 0
    for p in me.polygons:
        mn = mats[p.material_index]; vr = var.data[p.index].value
        pts = [src_px(uvd[li].uv) for li in p.loop_indices]
        cx = sum(q[0] for q in pts) / len(pts); cy = sum(q[1] for q in pts) / len(pts)
        e = next((e for e in ents if e["mat"] == mn and e["variant"] == vr and
                  e["src_rect"][0] <= cx <= e["src_rect"][2] and e["src_rect"][1] <= cy <= e["src_rect"][3]), None)
        if e is None:
            miss += 1; continue
        used.add(id(e))
        ox, oy = e["offset_px"]
        for li, (x, y) in zip(p.loop_indices, pts):
            assert e["src_rect"][0] - 0.01 <= x <= e["src_rect"][2] + 0.01 and e["src_rect"][1] - 0.01 <= y <= e["src_rect"][3] + 0.01
            uvd[li].uv = ((x + ox) / AW, 1.0 - (y + oy) / AH)
    assert miss == 0, (prop, "faces without atlas slot", miss)
    return len(used)


# ---------------------------------------------------------------- back faces
def sphere_dirs():
    ds = []
    for el in (-60, -30, -10, 0, 10, 30, 60):
        for az in range(0, 360, 30):
            a, e = math.radians(az + (15 if el % 20 else 0)), math.radians(el)
            ds.append(Vector((math.cos(e) * math.cos(a), math.cos(e) * math.sin(a), math.sin(e))))
    ds += [Vector((0, 0, 1)), Vector((0.05, 0.02, -1)).normalized()]
    return ds


def ray_grid(me, d, step):
    pts = [v.co for v in me.vertices]
    lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    cen = (lo + hi) / 2; rad = (hi - lo).length / 2 + 0.05
    a = d.orthogonal().normalized(); b = d.cross(a).normalized()
    n = int(2 * rad / step) + 1
    for i in range(n):
        for j in range(n):
            yield cen + d * (rad + 1) + a * (-rad + i * step) + b * (-rad + j * step), rad


def find_backfaces(me, step):
    bm = bmesh.new(); bm.from_mesh(me); tree = BVHTree.FromBMesh(bm); bm.free()
    bad = set()
    for d in sphere_dirs():
        ray = -d
        for o, rad in ray_grid(me, d, step):
            loc, nor, idx, dist = tree.ray_cast(o, ray, 4 * rad + 2)
            if idx is not None and nor.dot(ray) > 1e-4:
                bad.add(idx)
    return bad


def culled_holes(me, step):
    """simulate one-sided drawing: for each view, rays whose first surface faces away (would be culled) while no
    camera-facing surface sits at the same depth -> a hole. Returns {total rays hitting, holes}."""
    bm = bmesh.new(); bm.from_mesh(me); bm.faces.ensure_lookup_table()
    tree_all = BVHTree.FromBMesh(bm)
    holes = hits = 0
    for d in sphere_dirs():
        ray = -d
        front = [f.index for f in bm.faces if f.normal.dot(ray) < -1e-6]
        verts = [v.co.copy() for v in bm.verts]
        tree_f = BVHTree.FromPolygons(verts, [[v.index for v in bm.faces[i].verts] for i in front]) if front else None
        for o, rad in ray_grid(me, d, step):
            loc, nor, idx, dist = tree_all.ray_cast(o, ray, 4 * rad + 2)
            if idx is None:
                continue
            hits += 1
            if nor.dot(ray) > 1e-4:
                fl = tree_f.ray_cast(o, ray, 4 * rad + 2) if tree_f else (None,) * 4
                if fl[3] is None or fl[3] > dist + 1e-4:
                    holes += 1
    bm.free()
    return {"rays_hit": hits, "holes": holes}


def ring_siblings(me, faces):
    """round props: a face seen from behind usually has rotated twins (same area, height, radius, normal tilt)
    that rays just missed; take them too"""
    def key(p):
        c = p.center
        return p.area, c.z, math.hypot(c.x, c.y), p.normal.z
    ks = [key(me.polygons[i]) for i in faces]
    out = set(faces)
    for p in me.polygons:
        a, z, r, nz = key(p)
        for a2, z2, r2, nz2 in ks:
            if abs(a - a2) <= 0.01 * a2 and abs(z - z2) < 0.01 and abs(r - r2) < 0.01 and abs(nz - nz2) < 0.01:
                out.add(p.index); break
    return out


def add_flipped_copies(me, cn, faces):
    uvd = me.uv_layers.active.data
    new = []
    for i in sorted(faces):
        p = me.polygons[i]
        lis = list(p.loop_indices)[::-1]
        new.append([(me.vertices[me.loops[li].vertex_index].co.copy(), tuple(uvd[li].uv), -cn[li]) for li in lis])
    if new:
        add_faces(me, new, cn, mat_index=0)
    return len(new)


# ---------------------------------------------------------------- material
def make_material():
    m = bpy.data.materials.new("StreetPropsAtlas"); m.use_nodes = True
    nt = m.node_tree; b = nt.nodes["Principled BSDF"]
    t = nt.nodes.new("ShaderNodeTexImage"); t.image = bpy.data.images.load(os.path.join(out, AN + ".png"), check_existing=True)
    t.interpolation = 'Linear'
    nt.links.new(t.outputs["Color"], b.inputs["Base Color"])
    t2 = nt.nodes.new("ShaderNodeTexImage"); t2.image = bpy.data.images.load(os.path.join(out, AN + "_mr.png"), check_existing=True)
    t2.image.colorspace_settings.name = "Non-Color"
    sp = nt.nodes.new("ShaderNodeSeparateColor")
    nt.links.new(t2.outputs["Color"], sp.inputs["Color"])
    nt.links.new(sp.outputs["Green"], b.inputs["Roughness"]); nt.links.new(sp.outputs["Blue"], b.inputs["Metallic"])
    m.use_backface_culling = True
    return m


def bbox(me):
    pts = [v.co for v in me.vertices]
    return (Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts))),
            Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts))))


# ---------------------------------------------------------------- main
for P in cfg["props"]:
    if only and P["name"] != only:
        continue
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=os.path.join(src, "x", "x", P["src"]))
    obs = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    assert len(obs) == 1, obs
    ob = obs[0]; me = ob.data
    me.transform(ob.matrix_world); ob.matrix_world = Matrix.Identity(4)
    tris_src = sum(len(p.vertices) - 2 for p in me.polygons)
    lo0, hi0 = bbox(me)
    size_src_m = [round(hi0.x - lo0.x, 4), round(hi0.y - lo0.y, 4), round(hi0.z - lo0.z, 4)]
    cn = corner_normals(me)
    me.attributes.new("wr_variant", 'INT', 'FACE')
    info = {"src": "Cartoon City Massive Pack (Godot) .../Models/" + P["src"], "sheet_no": P["sheet_no"], "tris_src": tris_src,
            "src_size_m_xyz_blender": size_src_m, "front": P["front"]}
    if P.get("variant_rule"):
        info["variant_faces"] = tag_by_rule(me, P["variant_rule"])
    if P.get("edit") == "mailbox":
        info["mailbox_edit"] = edit_mailbox(ob, cn)
    info["atlas_slots"] = remap_uvs(ob, P["name"])
    # scale + turn (front -> +Y), normals turn with it
    M = Matrix.Rotation(math.radians(P["rot_z_deg"]), 4, 'Z') @ Matrix.Scale(S, 4)
    R3 = Matrix.Rotation(math.radians(P["rot_z_deg"]), 3, 'Z')
    me.transform(M)
    cn = [(R3 @ n).normalized() for n in cn]
    lo, hi = bbox(me)
    if P.get("origin") == "stair_bottom":
        foot = [v.co for v in me.vertices if v.co.z < lo.z + 0.02]
        oy = (min(c.y for c in foot) + max(c.y for c in foot)) / 2
        org = Vector(((lo.x + hi.x) / 2, oy, lo.z))
    else:
        org = Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
    me.transform(Matrix.Translation(-org))
    me.update()
    # one material
    mat = make_material()
    me.materials.clear(); me.materials.append(mat)
    for p in me.polygons:
        p.material_index = 0
    me.attributes.remove(me.attributes["wr_variant"])
    # back faces seen from outside -> flipped copies
    lo, hi = bbox(me)
    step = max(hi - lo) / 220
    bad = find_backfaces(me, step) | find_backfaces(me, step * 1.37) | find_backfaces(me, step * 0.79)   # three ray grids
    bad = ring_siblings(me, bad)
    nfix = add_flipped_copies(me, cn, bad)
    me.validate(); me.update()
    assert len(me.loops) == len(cn), (len(me.loops), len(cn))
    me.normals_split_custom_set([tuple(n) for n in cn])
    holes = culled_holes(me, step * 0.61)                                   # a fourth grid checks the result
    tris = sum(len(p.vertices) - 2 for p in me.polygons)
    ob.name = P["name"]; me.name = P["name"]
    path = os.path.join(out, P["name"] + ".glb")
    bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True); bpy.context.view_layer.objects.active = ob
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_yup=True, export_apply=True,
                              export_materials='EXPORT', export_image_format="AUTO", export_texcoords=True, export_normals=True,
                              export_animations=False, export_skins=False, export_morph=False)
    # read back: bbox in GLB / Roblox axes (x, y up, z = -Blender y)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=path)
    rb = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    pts = [o.matrix_world @ v.co for o in rb for v in o.data.vertices]
    gl_lo = [min(p.x for p in pts), min(p.z for p in pts), min(-p.y for p in pts)]
    gl_hi = [max(p.x for p in pts), max(p.z for p in pts), max(-p.y for p in pts)]
    rtris = sum(len(p.vertices) - 2 for o in rb for p in o.data.polygons)
    rmats = sorted({m.name for o in rb for m in o.data.materials if m})
    rimgs = sorted({i.name for i in bpy.data.images})
    info.update({"scale_m_to_stud": round(S, 6), "rot_z_deg": P["rot_z_deg"], "tris": tris, "tris_readback": rtris,
                 "backface_copies": nfix, "holes_one_sided_check": holes,
                 "glb_bbox_min": [round(x, 3) for x in gl_lo], "glb_bbox_max": [round(x, 3) for x in gl_hi],
                 "size_stud_xyz": [round(gl_hi[i] - gl_lo[i], 3) for i in range(3)],
                 "height_stud": round(gl_hi[1] - gl_lo[1], 3), "meshes": len(rb), "materials": rmats, "images": rimgs})
    if P.get("origin") == "stair_bottom":
        # top end (GLB axes) for the README: highest vertices' centre
        top = [p for p in pts if p.z > gl_hi[1] - 0.05]
        info["stair_top_end_glb"] = [round(sum(p.x for p in top) / len(top), 3), round(gl_hi[1], 3), round(sum(-p.y for p in top) / len(top), 3)]
    stats[P["name"]] = info
    print("EXPORTED", P["name"], "tris", tris_src, "->", tris, "(bf copies", nfix, ") size", info["size_stud_xyz"], "holes", holes)
json.dump(stats, open(stats_p, "w", encoding="utf-8"), indent=1)
