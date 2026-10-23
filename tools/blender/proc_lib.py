# Helpers for building hard-surface toy items from clean primitives in headless Blender (pp-3d-make 10-20).
# User 10-20: Hunyuan meshes were "not smooth" -> camera/alarm clock/boxes are built from bevelled primitives measured
# on the 6-view concept; one material per part, baked to one base + ORM texture, exported as a game GLB.
# Blender axes while building: front faces +Y (exports as glTF -Z = game front), up +Z, the object's own left = +X.
import bpy, bmesh, math, os
import numpy as np
from mathutils import Vector, Matrix

MATS = {}


def reset():
    bpy.ops.wm.read_homefile(use_empty=True)
    MATS.clear()


def mat(name, hexcol, rough, metal=0.0):
    """a flat material; colour/rough/metal are read back when baking"""
    m = bpy.data.materials.new(name); m.use_nodes = True
    c = tuple(int(hexcol[i:i + 2], 16) / 255 for i in (1, 3, 5))
    m["pp_col"] = c; m["pp_rough"] = rough; m["pp_metal"] = metal
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*[srgb_to_lin(v) for v in c], 1); b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    MATS[name] = m
    return m


def srgb_to_lin(v):
    return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4


def _new(name, bm):
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(ob)
    return ob


def rounded_box(name, size, center, radius, segs=3, material=None):
    """box (sx, sy, sz) with all edges rounded by `radius`"""
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=Vector(size), verts=bm.verts)
    if radius > 0.001:
        bmesh.ops.bevel(bm, geom=list(bm.verts) + list(bm.edges), offset=radius, segments=segs, profile=0.5, affect='EDGES',
                        clamp_overlap=True)
    bmesh.ops.translate(bm, vec=Vector(center), verts=bm.verts)
    ob = _new(name, bm)
    if material:
        ob.data.materials.append(material)
    return ob


def cylinder(name, r, depth, center, axis='Y', segs=24, bevel=0.0, bsegs=2, material=None, r_top=None):
    """capped cylinder (or cone when r_top given) along an axis with rounded rims"""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=segs, radius1=r, radius2=r if r_top is None else r_top,
                          depth=depth)
    if bevel > 0:
        rims = [e for e in bm.edges if len(e.link_faces) == 2 and abs(e.link_faces[0].normal.dot(e.link_faces[1].normal)) < 0.5]
        bmesh.ops.bevel(bm, geom=rims, offset=bevel, segments=bsegs, profile=0.5, affect='EDGES', clamp_overlap=True)
    rot = {'Y': Matrix.Rotation(-math.pi / 2, 4, 'X'), 'Z': Matrix.Identity(4), 'X': Matrix.Rotation(math.pi / 2, 4, 'Y')}[axis]
    bmesh.ops.transform(bm, matrix=rot, verts=bm.verts)
    bmesh.ops.translate(bm, vec=Vector(center), verts=bm.verts)
    ob = _new(name, bm)
    if material:
        ob.data.materials.append(material)
    return ob


def ring(name, r_out, r_in, depth, center, axis='Y', segs=24, bevel=0.0, bsegs=2, material=None, front_only=False):
    """thick ring (lens barrel / flash rim) with rounded edges"""
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, cap_ends=False, radius=r_out, segments=segs)
    outer = list(bm.verts)
    bmesh.ops.create_circle(bm, cap_ends=False, radius=r_in, segments=segs)
    inner = [v for v in bm.verts if v not in outer]
    bm.verts.ensure_lookup_table()
    for i in range(segs):
        bm.faces.new((outer[i], outer[(i + 1) % segs], inner[(i + 1) % segs], inner[i]))
    ext = bmesh.ops.extrude_face_region(bm, geom=list(bm.faces))
    bmesh.ops.translate(bm, vec=Vector((0, 0, depth)), verts=[g for g in ext["geom"] if isinstance(g, bmesh.types.BMVert)])
    bmesh.ops.translate(bm, vec=Vector((0, 0, -depth / 2)), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    if bevel > 0:
        rims = [e for e in bm.edges if len(e.link_faces) == 2 and abs(e.link_faces[0].normal.dot(e.link_faces[1].normal)) < 0.5]
        if front_only:  # only the visible front rims (the back sits inside the body)
            rims = [e for e in rims if min(v.co.z for v in e.verts) > depth / 2 - 1e-6]
        bmesh.ops.bevel(bm, geom=rims, offset=bevel, segments=bsegs, profile=0.5, affect='EDGES', clamp_overlap=True)
    rot = {'Y': Matrix.Rotation(-math.pi / 2, 4, 'X'), 'Z': Matrix.Identity(4), 'X': Matrix.Rotation(math.pi / 2, 4, 'Y')}[axis]
    bmesh.ops.transform(bm, matrix=rot, verts=bm.verts)
    bmesh.ops.translate(bm, vec=Vector(center), verts=bm.verts)
    ob = _new(name, bm)
    if material:
        ob.data.materials.append(material)
    return ob


def dome(name, rx, ry, rz, center, segs=20, rings=6, material=None, axis='Y', half=True):
    """half (or full) ellipsoid; for a lens glass bulging along +axis"""
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=segs, v_segments=rings * (2 if half else 1), radius=1.0)
    if half:
        bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z < -1e-4], context='VERTS')
        # close the flat back
        edges = [e for e in bm.edges if len(e.link_faces) == 1]
        if edges:
            bmesh.ops.holes_fill(bm, edges=edges, sides=0)
    bmesh.ops.scale(bm, vec=Vector((rx, rz, ry)) if axis == 'Y' else Vector((rx, ry, rz)), verts=bm.verts)
    if axis == 'Y':
        bmesh.ops.transform(bm, matrix=Matrix.Rotation(-math.pi / 2, 4, 'X'), verts=bm.verts)
    bmesh.ops.translate(bm, vec=Vector(center), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    ob = _new(name, bm)
    if material:
        ob.data.materials.append(material)
    return ob


def sphere(name, r, center, segs=12, rings=6, material=None, scale=(1, 1, 1)):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=segs, v_segments=rings, radius=r)
    bmesh.ops.scale(bm, vec=Vector(scale), verts=bm.verts)
    bmesh.ops.translate(bm, vec=Vector(center), verts=bm.verts)
    ob = _new(name, bm)
    if material:
        ob.data.materials.append(material)
    return ob


def assign_by(ob, fn_mat):
    """per-face material: fn_mat(face_center, face_normal) -> material or None (keep)"""
    me = ob.data
    for p in me.polygons:
        m = fn_mat(Vector(p.center), Vector(p.normal))
        if m is None:
            continue
        if m.name not in [x.name for x in me.materials]:
            me.materials.append(m)
        p.material_index = [x.name for x in me.materials].index(m.name)


def join_all(name):
    obs = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    for o in bpy.context.scene.objects:
        o.select_set(o in obs)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active; ob.name = name
    return ob


def tris(ob):
    return sum(len(p.vertices) - 2 for p in ob.data.polygons)


def _bake_geo(ob, sock, tex):
    """bake the object's own Position / Normal (Blender coords) into a float map; returns (tex, tex, 3)"""
    im = bpy.data.images.new("g_" + sock, tex, tex, alpha=False, float_buffer=True); im.colorspace_settings.name = 'Non-Color'
    for m in ob.data.materials:
        nt = m.node_tree; N = nt.nodes
        for n in [n for n in N if n.name.startswith("pp_")]:
            N.remove(n)
        g = N.new("ShaderNodeNewGeometry"); g.name = "pp_geo"; em = N.new("ShaderNodeEmission"); em.name = "pp_em"
        nt.links.new(g.outputs[sock], em.inputs["Color"])
        nt.links.new(em.outputs[0], [n for n in N if n.type == 'OUTPUT_MATERIAL'][0].inputs["Surface"])
        ti = N.new("ShaderNodeTexImage"); ti.name = "pp_tex"; ti.image = im; N.active = ti
    bpy.context.scene.render.bake.margin = 0
    bpy.ops.object.bake(type='EMIT')
    a = np.empty(tex * tex * 4, np.float32); im.pixels.foreach_get(a)
    return a.reshape(tex, tex, 4)[:, :, :3]


def _fib_dirs(n):
    g = math.pi * (3 - math.sqrt(5)); out = []
    for i in range(n):
        z = 1 - 2 * (i + 0.5) / n; r = math.sqrt(max(0.0, 1 - z * z)); a = g * i
        out.append(Vector((r * math.cos(a), r * math.sin(a), z)))
    return out


def cull_hidden_faces(ob, ndirs=96):
    """delete triangles nobody can ever see: every ray from the face (over its outer hemisphere) hits the model
    again (ends of posts buried in the body, faces lying under the brows, backs of parts inside other parts).
    The 3,000-tri budget then goes to what people look at (pp-3d-make 10-20)."""
    from mathutils.bvhtree import BVHTree
    bm = bmesh.new(); bm.from_mesh(ob.data); bm.faces.ensure_lookup_table()
    tree = BVHTree.FromBMesh(bm)
    dims = max(ob.dimensions); far = dims * 4; eps = dims * 1e-4
    dirs = _fib_dirs(ndirs)
    dead = []
    keep_layer = bm.verts.layers.deform.verify()
    nc_idx = ob.vertex_groups["nocull"].index if "nocull" in ob.vertex_groups else -1
    for f in bm.faces:
        if nc_idx >= 0 and any(nc_idx in v[keep_layer] for v in f.verts):
            continue
        c = f.calc_center_median(); n = f.normal
        # test the centre, points near every corner and every edge middle: a face partly peeking out from under a
        # raised part must stay (else a small hole shows)
        vs = [v.co for v in f.verts]
        pts = [c] + [c.lerp(v, 0.97) for v in vs] + [c.lerp((vs[i] + vs[(i + 1) % len(vs)]) / 2, 0.97) for i in range(len(vs))]
        seen = False
        for p0 in pts:
            o = p0 + n * eps
            for d in dirs:
                if d.dot(n) <= 0.02:
                    continue
                if tree.ray_cast(o, d, far)[0] is None:
                    seen = True; break
            if seen:
                break
        if not seen:
            dead.append(f)
    bmesh.ops.delete(bm, geom=dead, context='FACES')
    bm.to_mesh(ob.data); bm.free()
    return len(dead)


def finish(ob, out, tex=1024, smooth_angle=60, weighted=True, pivot_bottom=True, paint=None, island_margin=0.02,
           split_materials=True, cull_hidden=True, max_tris=0, planar_mats=(), recalc_normals=True):
    """paint(P, N, base, orm, mask) may change base/orm per texel (P/N = texel position/normal in build coords):
    gradients, glints, small painted marks that should not cost triangles"""
    """triangulate, smooth normals, UV, bake per-material colour + ORM to one texture each, export PBR GLB"""
    bpy.context.view_layer.objects.active = ob
    for o in bpy.context.scene.objects:
        o.select_set(o == ob)
    bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.delete_loose(use_verts=True, use_edges=True, use_faces=False)   # stray points / edges (2nd v3: ']' speck)
    bpy.ops.mesh.select_all(action='SELECT')
    if recalc_normals:   # Roblox draws one side only: every face must face out. recalc_normals=False when every part
        # is built facing out already: overlapping closed parts can get flipped here (pp-3d-props bench g7 divider)
        bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.mesh.quads_convert_to_tris()
    if cull_hidden:
        bpy.ops.object.mode_set(mode='OBJECT')
        n0 = len(ob.data.polygons); removed = cull_hidden_faces(ob)
        print("hidden faces removed", removed, "of", n0)
        if max_tris and len(ob.data.polygons) > max_tris:
            # error-driven collapse: flat / gently curved areas give triangles first, silhouettes and small round
            # parts keep theirs (symmetric in X so both sides stay alike)
            for o_ in bpy.context.scene.objects:
                o_.select_set(o_ == ob)
            dm = ob.modifiers.new("fit", 'DECIMATE'); dm.decimate_type = 'COLLAPSE'
            dm.ratio = max_tris / len(ob.data.polygons); dm.use_symmetry = True; dm.symmetry_axis = 'X'
            dm.use_collapse_triangulate = True
            if "flex" in ob.vertex_groups:   # only the big smooth parts give triangles; small round parts are kept
                dm.vertex_group = "flex"; dm.vertex_group_factor = 1.0
            bpy.ops.object.modifier_apply(modifier="fit")
            print("decimated to", len(ob.data.polygons))
        bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
    if split_materials:
        # colour borders = UV island borders: split along material changes before unwrapping, weld back after -> the
        # border is the polygon edge itself (straight), not a stair-stepped line of texels (main 3rd, camera v3c)
        bpy.ops.object.mode_set(mode='OBJECT')
        bm = bmesh.new(); bm.from_mesh(ob.data)
        border = [e for e in bm.edges if len(e.link_faces) == 2 and e.link_faces[0].material_index != e.link_faces[1].material_index]
        bmesh.ops.split_edges(bm, edges=border)
        bm.to_mesh(ob.data); bm.free()
        bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=island_margin)  # wide gaps: no colour bleed at small mip levels
    if planar_mats:
        # painted round parts (lens glass) get ONE planar island: no UV seam crossing the painted gradient
        idx = [i for i, m in enumerate(ob.data.materials) if m.name in planar_mats]
        bpy.ops.object.mode_set(mode='OBJECT')
        for p_ in ob.data.polygons:
            p_.select = p_.material_index in idx
        bpy.ops.object.mode_set(mode='EDIT')
        bpy.ops.uv.cube_project(cube_size=2.0, correct_aspect=True)
        bpy.ops.mesh.select_all(action='SELECT')
        bpy.ops.uv.pack_islands(margin=island_margin)
    if split_materials:
        bpy.ops.mesh.remove_doubles(threshold=1e-6)       # weld the geometry again; UVs stay split (they are per loop)
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.shade_smooth()
    try:
        bpy.ops.object.shade_smooth_by_angle(angle=math.radians(smooth_angle))
    except Exception as e:
        print("smooth_by_angle", e)
    if weighted:
        wn = ob.modifiers.new("wn", 'WEIGHTED_NORMAL'); wn.keep_sharp = True; wn.weight = 50
        bpy.ops.object.modifier_apply(modifier="wn")
    # bake: every material temporarily emits its colour, then (1, rough, metal)
    sc = bpy.context.scene; sc.render.engine = 'CYCLES'; sc.cycles.device = 'CPU'; sc.cycles.samples = 1
    sc.render.bake.margin = 8; sc.render.bake.use_selected_to_active = False
    sc.view_settings.view_transform = 'Standard'
    imgs = {}
    for kind in ("base", "orm"):
        im = bpy.data.images.new(kind, tex, tex, alpha=False, float_buffer=True); im.colorspace_settings.name = 'Non-Color'
        imgs[kind] = im
        for m in ob.data.materials:
            nt = m.node_tree; N = nt.nodes
            for n in [n for n in N if n.name.startswith("pp_")]:
                N.remove(n)
            em = N.new("ShaderNodeEmission"); em.name = "pp_em"
            c = m["pp_col"]
            em.inputs["Color"].default_value = (*c, 1) if kind == "base" else (1, m["pp_rough"], m["pp_metal"], 1)
            out_n = [n for n in N if n.type == 'OUTPUT_MATERIAL'][0]
            nt.links.new(em.outputs[0], out_n.inputs["Surface"])
            ti = N.new("ShaderNodeTexImage"); ti.name = "pp_tex"; ti.image = im; N.active = ti
        bpy.ops.object.bake(type='EMIT')
    arrs = {}
    for kind, im in imgs.items():
        a = np.empty(tex * tex * 4, np.float32); im.pixels.foreach_get(a); arrs[kind] = a.reshape(tex, tex, 4)
    # fill the empty texture space with the nearest island colour (Roblox mipmaps would mix black into the edges)
    cov = arrs["orm"][:, :, 0] > 0.5
    for kind in ("base", "orm"):
        A = arrs[kind][:, :, :3].copy(); m = cov.copy()
        for _ in range(64):
            if m.all():
                break
            acc = np.zeros_like(A); cnt = np.zeros(m.shape, np.float32)
            for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                mm = np.roll(np.roll(m, dy, 0), dx, 1); aa = np.roll(np.roll(A, dy, 0), dx, 1)
                acc += aa * mm[..., None]; cnt += mm
            new = (~m) & (cnt > 0)
            A[new] = acc[new] / cnt[new][:, None]; m = m | new
        arrs[kind][:, :, :3] = A
    if paint is not None:
        Pm = _bake_geo(ob, "Position", tex); Nm = _bake_geo(ob, "Normal", tex)
        Nm = Nm / np.maximum(np.linalg.norm(Nm, axis=-1, keepdims=True), 1e-6)
        mask = np.linalg.norm(Pm, axis=-1) > 1e-6
        b3, o3 = paint(Pm, Nm, arrs["base"][:, :, :3].copy(), arrs["orm"][:, :, :3].copy(), mask)
        arrs["base"][:, :, :3] = b3; arrs["orm"][:, :, :3] = o3
    paths = {}
    for kind, im in imgs.items():
        a = arrs[kind].astype(np.float32).ravel()
        o = bpy.data.images.new(kind + "_8", tex, tex, alpha=False)
        o.colorspace_settings.name = 'sRGB' if kind == "base" else 'Non-Color'
        o.pixels.foreach_set(a); o.update()
        p = out + "_" + kind + ".png"; o.filepath_raw = p; o.file_format = 'PNG'; o.save(); paths[kind] = p
    # one PBR material
    pm = bpy.data.materials.new("pbr"); pm.use_nodes = True; N = pm.node_tree.nodes; L = pm.node_tree.links
    for n in list(N):
        N.remove(n)
    o_ = N.new("ShaderNodeOutputMaterial"); b = N.new("ShaderNodeBsdfPrincipled"); L.new(b.outputs[0], o_.inputs["Surface"])
    tb = N.new("ShaderNodeTexImage"); tb.image = bpy.data.images.load(paths["base"]); L.new(tb.outputs["Color"], b.inputs["Base Color"])
    to = N.new("ShaderNodeTexImage"); to.image = bpy.data.images.load(paths["orm"]); to.image.colorspace_settings.name = 'Non-Color'
    sp = N.new("ShaderNodeSeparateColor"); L.new(to.outputs["Color"], sp.inputs[0])
    L.new(sp.outputs["Green"], b.inputs["Roughness"]); L.new(sp.outputs["Blue"], b.inputs["Metallic"])
    ob.data.materials.clear(); ob.data.materials.append(pm)
    for p in ob.data.polygons:
        p.material_index = 0
    if pivot_bottom:  # origin = bottom centre (game checklist); after the bake so paint() works in build coords
        xs = [v.co.x for v in ob.data.vertices]; ys = [v.co.y for v in ob.data.vertices]; zs = [v.co.z for v in ob.data.vertices]
        ob.data.transform(Matrix.Translation((-(min(xs) + max(xs)) / 2, -(min(ys) + max(ys)) / 2, -min(zs))))
    for m in ob.data.materials:  # glTF doubleSided = false: Roblox draws one side (pp-3d-check 10-20; pp-3d-field)
        if m:
            m.use_backface_culling = True
    bpy.ops.export_scene.gltf(filepath=out + ".glb", export_format='GLB', use_selection=True)
    print("EXPORTED", out + ".glb", "tris", tris(ob), "dims", [round(d, 3) for d in ob.dimensions])


def lathe(name, profile, center, axis='Y', segs=20, material=None, cap=True, thickness=0.0):
    """surface of revolution: profile = [(radius, height), ...] from the axis tip outward; cap closes the back
    (used for lens domes so a ring edge can sit exactly where the dark centre ends)"""
    bm = bmesh.new()
    rings = []
    for r, h in profile:
        if r < 1e-6:
            rings.append([bm.verts.new((0, 0, h))])
        else:
            rings.append([bm.verts.new((r * math.cos(2 * math.pi * i / segs), r * math.sin(2 * math.pi * i / segs), h))
                          for i in range(segs)])
    for a, b in zip(rings[:-1], rings[1:]):
        if len(a) == 1:
            for i in range(segs):
                bm.faces.new((a[0], b[i], b[(i + 1) % segs]))
        else:
            for i in range(segs):
                bm.faces.new((a[i], b[i], b[(i + 1) % segs], a[(i + 1) % segs]))
    if cap and len(rings[-1]) > 1:
        bm.faces.new(list(reversed(rings[-1])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    if not cap:  # open surface (a dish): face +axis (towards the viewer), then give it a real thickness
        if sum(f.normal.z for f in bm.faces) < 0:
            bmesh.ops.reverse_faces(bm, faces=list(bm.faces))
        if thickness > 0:
            ext = bmesh.ops.extrude_face_region(bm, geom=list(bm.faces))
            nv = [g for g in ext["geom"] if isinstance(g, bmesh.types.BMVert)]
            bmesh.ops.translate(bm, vec=Vector((0, 0, -thickness)), verts=nv)
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    rot = {'Y': Matrix.Rotation(-math.pi / 2, 4, 'X'), 'Z': Matrix.Identity(4), 'X': Matrix.Rotation(math.pi / 2, 4, 'Y')}[axis]
    bmesh.ops.transform(bm, matrix=rot, verts=bm.verts)
    bmesh.ops.translate(bm, vec=Vector(center), verts=bm.verts)
    ob = _new(name, bm)
    if material:
        ob.data.materials.append(material)
    return ob


def lathe_loop(name, loop, center, axis='Y', segs=32, material=None):
    """revolve a CLOSED profile loop [(r, h), ...] around the axis -> a closed torus-like ring (rounded bezel)"""
    bm = bmesh.new()
    rings = [[bm.verts.new((r * math.cos(2 * math.pi * i / segs), r * math.sin(2 * math.pi * i / segs), h)) for i in range(segs)]
             for r, h in loop]
    n = len(rings)
    for k in range(n):
        a, b = rings[k], rings[(k + 1) % n]
        for i in range(segs):
            bm.faces.new((a[i], b[i], b[(i + 1) % segs], a[(i + 1) % segs]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    rot = {'Y': Matrix.Rotation(-math.pi / 2, 4, 'X'), 'Z': Matrix.Identity(4), 'X': Matrix.Rotation(math.pi / 2, 4, 'Y')}[axis]
    bmesh.ops.transform(bm, matrix=rot, verts=bm.verts)
    bmesh.ops.translate(bm, vec=Vector(center), verts=bm.verts)
    ob = _new(name, bm)
    if material:
        ob.data.materials.append(material)
    return ob


def flex(*objs):
    """mark parts whose triangles the final fit may reduce (big smooth surfaces); unmarked parts keep every triangle"""
    for o in objs:
        g = o.vertex_groups.get("flex") or o.vertex_groups.new(name="flex")
        g.add([v.index for v in o.data.vertices], 1.0, 'REPLACE')


def nocull(*objs):
    """parts the hidden-face cull must leave alone (thin posts / stems seen through narrow gaps)"""
    for o in objs:
        g = o.vertex_groups.get("nocull") or o.vertex_groups.new(name="nocull")
        g.add([v.index for v in o.data.vertices], 1.0, 'REPLACE')


def sweep(name, pts, half_w, height, up=(0, 1, 0), around=12, cap=True, sink=0.0, power=3.0, material=None):
    """a smooth raised stroke (clock hand, mouth line, eyebrow): a rounded cross-section swept along a SMOOTH path
    (pts: list of 3D points on the surface, half_w / height: per point). Rounded end caps. The flat bottom sits
    `sink` below the path so it melts into the surface; the bottom faces are hidden and get culled.
    Made instead of tracing the concept's outline, which came out bumpy (user 10-20: '시침과 분침이 울퉁불퉁해')."""
    pts = [Vector(p) for p in pts]; upv = Vector(up).normalized()
    # rounded caps: extend both ends by a quarter circle of the end width
    def cap_pts(p0, p1, w, h, n=5):
        d = (p0 - p1).normalized(); out = []
        for k in range(1, n + 1):
            a = (math.pi / 2) * k / n
            out.append((p0 + d * w * math.sin(a), w * math.cos(a), h * math.cos(a) ** 0.6))
        return out
    seq = [(p, w, h) for p, w, h in zip(pts, half_w, height)]
    if cap:
        head = cap_pts(pts[0], pts[1], half_w[0], height[0])[::-1]
        tail = cap_pts(pts[-1], pts[-2], half_w[-1], height[-1])
        seq = head + seq + tail
    bm = bmesh.new(); rings = []
    for i, (p, w, h) in enumerate(seq):
        a = seq[min(i + 1, len(seq) - 1)][0] - seq[max(i - 1, 0)][0]
        t = a.normalized() if a.length > 1e-9 else Vector((1, 0, 0))
        side = t.cross(upv).normalized()
        ring = []
        for j in range(around + 1):
            th = math.pi * j / around
            c, s_ = math.cos(th), math.sin(th)
            x = math.copysign(abs(c) ** (2 / power), c) * w
            z = (abs(s_) ** (2 / power)) * h
            ring.append(bm.verts.new(p + side * x + upv * (z - sink)))
        rings.append(ring)
    for r0, r1 in zip(rings[:-1], rings[1:]):
        for j in range(around):
            f = (r0[j], r0[j + 1], r1[j + 1], r1[j])
            if len({id(v) for v in f}) == 4:
                bm.faces.new(f)
        # closed flat bottom: no see-through at low angles (2nd review alarm v4)
        f = (r0[around], r0[0], r1[0], r1[around])
        if len({id(v) for v in f}) == 4:
            bm.faces.new(f)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-7)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    # face normals must point away from the stroke's inside: flip if the top points down
    ob = _new(name, bm)
    if material:
        ob.data.materials.append(material)
    return ob


def rounded_rect_loop(r0, r1, h0, h1, rad_front, rad_back=0.0, n=4):
    """closed (r, h) profile loop of a ring cross-section: inner radius r0, outer r1, back h0, front h1, rounded
    corners (front corners rad_front, back corners rad_back) - for lathe_loop rings with an even, wave-free surface"""
    def arc(cx, cz, rad, a0, a1):
        if rad <= 0:
            return [(cx, cz)]
        return [(cx + rad * math.cos(a0 + (a1 - a0) * k / n), cz + rad * math.sin(a0 + (a1 - a0) * k / n)) for k in range(n + 1)]
    pts = []
    pts += arc(r0 + rad_back, h0 + rad_back, rad_back, math.pi, math.pi * 1.5)          # inner back
    pts += arc(r1 - rad_back, h0 + rad_back, rad_back, math.pi * 1.5, math.pi * 2)      # outer back
    pts += arc(r1 - rad_front, h1 - rad_front, rad_front, 0, math.pi / 2)               # outer front
    pts += arc(r0 + rad_front, h1 - rad_front, rad_front, math.pi / 2, math.pi)         # inner front
    return pts


def lathe_cap(name, r, h0, h1, rad, center, axis='Z', segs=32, n=4, material=None):
    """a round button / dial body: flat top with a rounded edge of radius rad (lathe from the axis)"""
    prof = [(0, h1), (r - rad, h1)] + [(r - rad + rad * math.sin(math.pi / 2 * k / n), h1 - rad + rad * math.cos(math.pi / 2 * k / n)) for k in range(1, n + 1)] + [(r, h0)]
    return lathe(name, prof, center, axis=axis, segs=segs, material=material)
