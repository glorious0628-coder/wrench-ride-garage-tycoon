# Shared helpers for the fault-look parts (wr-3d helper, 10-21): coolant tank, brake reservoir, wipers, washer nozzles.
# Build frame (proc_lib / wr_lib): Blender +X = car right, +Y = car front, +Z = up; the glTF exporter turns it into
# Roblox +X right, +Y up, -Z front. Car coords in the docs are Roblox (x, Y, z): B(x, Y, z) -> build Vector.
import bpy, bmesh, math, os, sys, json
from mathutils import Vector, Matrix

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
sys.path.insert(0, os.path.join(ROOT, "tools", "blender", "wr"))
import wr_lib as W  # noqa: E402
from wr_lib import P  # noqa: E402

SEDAN = os.path.join(ROOT, "art", "3d", "sedan_body")


def B(x, Y, z):
    """Roblox car coords -> build frame"""
    return Vector((x, -z, Y))


def R(v):
    """build frame -> Roblox car coords (list, rounded)"""
    return [round(v[0], 4), round(v[2], 4), round(-v[1], 4)]


def Rdir(v):
    v = Vector(v).normalized()
    return [round(v[0], 4), round(v[2], 4), round(-v[1], 4)]


def hexf(h):
    return [int(h[i:i + 2], 16) / 255 for i in (1, 3, 5)]


def lin(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def boolean_union(base, others, name=None):
    """exact boolean union of closed meshes -> one clean shell (no faces inside: the part is see-through)"""
    for o in others:
        m = base.modifiers.new("u", 'BOOLEAN'); m.operation = 'UNION'
        try:
            m.solver = 'EXACT'
        except Exception:
            pass
        m.object = o
        bpy.context.view_layer.objects.active = base
        for x in bpy.context.scene.objects:
            x.select_set(x == base)
        bpy.ops.object.modifier_apply(modifier=m.name)
        bpy.data.objects.remove(o)
    # material slots of the others are lost by the boolean unless the base has them: keep base slots
    if name:
        base.name = name; base.data.name = name
    bm = bmesh.new(); bm.from_mesh(base.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-6)
    bmesh.ops.dissolve_degenerate(bm, dist=1e-6, edges=bm.edges)
    bm.to_mesh(base.data); bm.free()
    return base


def add_mats(ob, mats):
    for m in mats:
        if m.name not in [x.name for x in ob.data.materials if x]:
            ob.data.materials.append(m)


def set_mat_all(ob, mat):
    add_mats(ob, [mat])
    idx = [m.name for m in ob.data.materials].index(mat.name)
    for p in ob.data.polygons:
        p.material_index = idx


def set_mat_where(ob, mat, test):
    """faces whose centre (build coords, world) passes test(c, n) get `mat`"""
    add_mats(ob, [mat])
    idx = [m.name for m in ob.data.materials].index(mat.name)
    mw = ob.matrix_world
    for p in ob.data.polygons:
        c = mw @ Vector(p.center); n = (mw.to_3x3() @ Vector(p.normal)).normalized()
        if test(c, n):
            p.material_index = idx


def plain_material(name, hexcol, rough=0.3, metal=0.0, alpha=1.0):
    m = bpy.data.materials.new(name); m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    c = hexf(hexcol)
    b.inputs["Base Color"].default_value = (*[lin(v) for v in c], 1)
    b.inputs["Roughness"].default_value = rough; b.inputs["Metallic"].default_value = metal
    if alpha < 1.0:
        b.inputs["Alpha"].default_value = alpha
        try:
            m.surface_render_method = 'BLENDED'
        except Exception:
            m.blend_method = 'BLEND'
    m.use_backface_culling = True
    return m


def make_translucent(ob, alpha):
    """after proc_lib.finish: the PBR material keeps its textures, alpha < 1 -> glTF alphaMode BLEND"""
    for m in ob.data.materials:
        b = [n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'][0]
        b.inputs["Alpha"].default_value = alpha
        try:
            m.surface_render_method = 'BLENDED'
        except Exception:
            m.blend_method = 'BLEND'
        m.use_backface_culling = True


def export_one(ob, path):
    for o in bpy.context.scene.objects:
        o.select_set(o == ob)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True)


def set_origin(ob, origin):
    """move the object's origin to `origin` (build coords) without moving the mesh in the world"""
    ob.data.transform(Matrix.Translation(-(Vector(origin) - ob.location)))
    ob.location = Vector(origin)


def smooth(ob, angle=50):
    for o in bpy.context.scene.objects:
        o.select_set(o == ob)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.object.shade_smooth()
    try:
        bpy.ops.object.shade_smooth_by_angle(angle=math.radians(angle))
    except Exception as e:
        print("smooth_by_angle", e)


def tris_of(ob):
    return sum(len(p.vertices) - 2 for p in ob.data.polygons)


def mesh_info(ob):
    ws = [ob.matrix_world @ v.co for v in ob.data.vertices]
    lo = Vector([min(w[i] for w in ws) for i in range(3)]); hi = Vector([max(w[i] for w in ws) for i in range(3)])
    c = (lo + hi) / 2; s = hi - lo
    return {"origin": R(ob.matrix_world.translation), "bbox_centre": R(c), "bbox_size": [round(s.x, 4), round(s.z, 4), round(s.y, 4)],
            "tris": tris_of(ob)}


# ---------------------------------------------------------------- stroke letters (painted, not geometry) ------------
# unit letters: height 1, strokes as segments (x right, y up)
FONT = {
    "F": ([((0, 0), (0, 1)), ((0, 1), (0.58, 1)), ((0, 0.53), (0.46, 0.53))], 0.58),
    "L": ([((0, 1), (0, 0)), ((0, 0), (0.56, 0))], 0.56),
    "M": ([((0, 0), (0, 1)), ((0, 1), (0.36, 0.38)), ((0.36, 0.38), (0.72, 1)), ((0.72, 1), (0.72, 0))], 0.72),
    "A": ([((0, 0), (0.33, 1)), ((0.33, 1), (0.66, 0)), ((0.13, 0.36), (0.53, 0.36))], 0.66),
    "X": ([((0, 0), (0.6, 1)), ((0, 1), (0.6, 0))], 0.6),
    "I": ([((0, 0), (0, 1))], 0.0),
    "N": ([((0, 0), (0, 1)), ((0, 1), (0.6, 0)), ((0.6, 0), (0.6, 1))], 0.6),
}


def text_segments(text, h0, y0, height, gap=0.28):
    """segments (in (h, y) plane, h = viewer-right) for a word starting at h0, baseline y0"""
    segs = []; h = h0
    for ch in text:
        strokes, w = FONT[ch]
        for (a, b) in strokes:
            segs.append(((h + a[0] * height, y0 + a[1] * height), (h + b[0] * height, y0 + b[1] * height)))
        h += (w + gap) * height
    return segs, h


def seg_mask(hh, yy, segs, half_w):
    import numpy as np
    m = np.zeros(hh.shape, bool)
    for (ax, ay), (bx, by) in segs:
        dx, dy = bx - ax, by - ay; L2 = dx * dx + dy * dy
        t = np.clip(((hh - ax) * dx + (yy - ay) * dy) / max(L2, 1e-12), 0, 1)
        d = np.hypot(hh - (ax + t * dx), yy - (ay + t * dy))
        m |= d < half_w
    return m


def pillow_slab(name, pts, t0, t1, r0, r1, bulge, n_round, matrix, material=None, n_mid=4):
    """extrude a closed CCW 2D outline (local XY) from local z = t0 to t1: quarter-round edges (r0 at t0, r1 at t1),
    side walls bulging out by `bulge` in the middle, FLAT n-gon caps (work for concave outlines, triangulated later)"""
    rings = []
    for j in range(n_round + 1):
        a = math.pi / 2 * j / n_round
        rings.append((t0 + r0 - r0 * math.cos(a), -(r0 - r0 * math.sin(a))))
    m0, m1 = t0 + r0, t1 - r1
    for j in range(1, n_mid):
        t = m0 + (m1 - m0) * j / n_mid
        rings.append((t, bulge * math.sin(math.pi * j / n_mid)))
    for j in range(n_round, -1, -1):
        a = math.pi / 2 * j / n_round
        rings.append((t1 - r1 + r1 * math.cos(a), -(r1 - r1 * math.sin(a))))
    bm = bmesh.new(); vr = []
    for t, d in rings:
        ring = W.offset_outline(pts, d) if abs(d) > 1e-9 else pts
        vr.append([bm.verts.new(matrix @ Vector((x, y, t))) for x, y in ring])
    m = len(pts)
    for r0_, r1_ in zip(vr[:-1], vr[1:]):
        for j in range(m):
            bm.faces.new((r0_[j], r1_[j], r1_[(j + 1) % m], r0_[(j + 1) % m]))
    bm.faces.new(list(reversed(vr[0]))); bm.faces.new(vr[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    ob = P._new(name, bm)
    if material is not None:
        ob.data.materials.append(material)
    return ob
