# Shared helpers for the 2nd hand-tool batch (wr 3D helper 10-22): fuse puller, plug socket + extension, trim tool,
# hose clamp pliers, drain pan. Same way as tools/blender/wr/build_wrench.py (clean primitives -> proc_lib.finish bake ->
# PBR GLB) + the json shape of art/3d/tool_*/<tool>_attachments.json (+ mesh_bbox_centre / size).
# Build frame (Blender): +X = along the tool toward the working end, +Y = the face the concept "front" view shows (exports
# to Roblox -Z), +Z = up. W.to_roblox: (x, y, z) -> (x, z, -y).
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))   # tools/blender/wr
import wr_lib as W   # noqa: E402
from wr_lib import P  # noqa: E402
from mathutils import Vector, Matrix  # noqa: E402
import numpy as np  # noqa: E402

rb = W.to_roblox


def hexf(h):
    return np.array([int(h[i:i + 2], 16) / 255 for i in (1, 3, 5)], np.float32)


def args():
    a = sys.argv[sys.argv.index("--") + 1:]
    out = os.path.abspath(a[0]); os.makedirs(out, exist_ok=True)
    pal = json.load(open(a[1], encoding="utf-8")) if len(a) > 1 and a[1] else {}
    return out, pal


def rnd(v, n=4):
    return [round(float(x), n) for x in v]


def rb_dir(v):
    v = Vector(v).normalized()
    return rb(tuple(v))


def bbox(ob):
    co = np.array([v.co[:] for v in ob.data.vertices])
    lo, hi = co.min(0), co.max(0)
    return lo, hi


def add_bbox(data, ob):
    lo, hi = bbox(ob)
    c = (lo + hi) / 2; s = hi - lo
    data["mesh_bbox_centre"] = rb(tuple(c))
    data["mesh_bbox_size"] = [round(float(s[0]), 4), round(float(s[2]), 4), round(float(s[1]), 4)]
    data["bbox_note"] = "Roblox centres an imported MeshPart on its bounds: attachment CFrame in the part = pos - mesh_bbox_centre"
    return data


def write_json(path, data, ob):
    add_bbox(data, ob)
    data["tris"] = P.tris(ob)
    json.dump(data, open(path, "w", encoding="utf-8"), indent=1)


def group(ob, name):
    """put every vertex of a part into vertex group `name` (rig split after the bake: vertex groups survive bmesh)"""
    g = ob.vertex_groups.get(name) or ob.vertex_groups.new(name=name)
    g.add(list(range(len(ob.data.vertices))), 1.0, 'REPLACE')
    return ob


def group_by(ob, fn):
    """vertex group per vertex: fn(co) -> group name"""
    names = {}
    for v in ob.data.vertices:
        names.setdefault(fn(v.co), []).append(v.index)
    for n, ids in names.items():
        g = ob.vertex_groups.get(n) or ob.vertex_groups.new(name=n)
        g.add(ids, 1.0, 'REPLACE')
    return ob


def export_rig(ob, out_glb, names):
    """split the finished (baked) mesh into one object per vertex group in `names` (dict group -> node name; a face
    goes to the group most of its verts are in) and export them together: same texture, same axes as the single GLB"""
    me = ob.data
    gidx = {ob.vertex_groups[g].index: g for g in names if g in ob.vertex_groups}
    vg = {}
    for v in me.vertices:
        best = None; bw = 0.0
        for ge in v.groups:
            if ge.group in gidx and ge.weight > bw:
                best, bw = gidx[ge.group], ge.weight
        vg[v.index] = best
    made = []
    for g, node in names.items():
        bm = bmesh.new(); bm.from_mesh(me)
        dead = []
        for f in bm.faces:
            votes = [vg[v.index] for v in f.verts]
            if max(set(votes), key=votes.count) != g:
                dead.append(f)
        bmesh.ops.delete(bm, geom=dead, context='FACES')
        nm = bpy.data.meshes.new(node); bm.to_mesh(nm); bm.free()
        nm.materials.clear()
        for m in me.materials:
            nm.materials.append(m)
        o = bpy.data.objects.new(node, nm); bpy.context.scene.collection.objects.link(o)
        made.append(o)
    for o in bpy.context.scene.objects:
        o.select_set(o in made)
    bpy.context.view_layer.objects.active = made[0]
    bpy.ops.export_scene.gltf(filepath=out_glb, export_format='GLB', use_selection=True)
    res = {o.name: len(o.data.polygons) for o in made}
    print("RIG", out_glb, res)
    for o in made:
        bpy.data.objects.remove(o, do_unlink=True)
    return res


def lathe_rings(name, specs, n, material=None, pole0=None, pole1=None, a0=0.0, axis='Z'):
    """solid of revolution whose rings may be circles OR polygons with the same point count n (all at the same angles,
    so hex / square openings bridge to circles with clean quads). specs = [(h, r or fn(angle)->r)]; pole0 / pole1 =
    h of a centre pole closing the first / last ring (None = open: only for rings that are buried). axis = 'Z' / 'Y'."""
    bm = bmesh.new(); rings = []

    def pt(h, r, a):
        p, q = r * math.cos(a), r * math.sin(a)
        return Vector((p, q, h)) if axis == 'Z' else Vector((q, h, p))
    for h, r in specs:
        ring = []
        for i in range(n):
            a = a0 + 2 * math.pi * i / n
            rr = r(a) if callable(r) else r
            ring.append(bm.verts.new(pt(h, rr, a)))
        rings.append(ring)
    for A, B in zip(rings[:-1], rings[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((A[i], A[j], B[j], B[i]))
    for ring, ph in ((rings[0], pole0), (rings[-1], pole1)):
        if ph is not None:
            c = bm.verts.new(pt(ph, 0.0, 0.0))
            for i in range(n):
                bm.faces.new((ring[i], ring[(i + 1) % n], c))
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-7)
    return W._finish_bm(name, bm, material)


def hex_r(R, corner0=0.0):
    """radius of a hexagon (circumradius R, a corner at angle corner0) along angle a"""
    ap = R * math.cos(math.pi / 6)
    return lambda a: ap / math.cos(((a - corner0) % (math.pi / 3)) - math.pi / 6)


def square_r(hs, corner0=math.pi / 4):
    """radius of a square (half side hs, corners at corner0 + k*90deg) along angle a"""
    return lambda a: hs / max(abs(math.cos(a - corner0 + math.pi / 4)), abs(math.sin(a - corner0 + math.pi / 4)))


def stadium(hw, ht, k=3):
    """rounded-rectangle section, half width hw (local y) x half thickness ht (local x), corner radius ~ the smaller
    half (a fat capsule when they are close) -> list of (x, y) CCW"""
    cr = min(hw, ht) * 0.96
    return W.rrect_pts(ht, hw, cr, k)


def loft_sections(name, stations, material=None, cap0=True, cap1=True, pole1=None):
    """stations = [(X, zc, yc, hw, ht)] -> loft of stadium sections across the X axis (section local x -> Blender Y,
    local y -> Blender Z). pole1: X of a pole closing the last ring (rounded end)."""
    bm = bmesh.new()
    vr = [[bm.verts.new(Vector((X, yc + x, zc + y))) for x, y in stadium(hw, ht)] for X, zc, yc, hw, ht in stations]
    m = len(vr[0])
    for A, B in zip(vr[:-1], vr[1:]):
        for i in range(m):
            j = (i + 1) % m
            bm.faces.new((A[i], B[i], B[j], A[j]))
    ends = [(vr[0], cap0, None), (vr[-1], cap1, pole1)]
    for ring, on, pole in ends:
        if not on:
            continue
        c = sum((v.co for v in ring), Vector()) / m
        if pole is not None:
            c = Vector((pole, c.y, c.z))
        cv = bm.verts.new(c)
        for i in range(m):
            bm.faces.new((ring[i], ring[(i + 1) % m], cv))
    return W._finish_bm(name, bm, material)


def interp(table, x):
    """piecewise-linear lookup in [(x, v...)] sorted by x"""
    if x <= table[0][0]:
        return table[0][1:]
    for (x0, *v0), (x1, *v1) in zip(table[:-1], table[1:]):
        if x0 <= x <= x1:
            t = (x - x0) / (x1 - x0) if x1 > x0 else 0.0
            return [a + (b - a) * t for a, b in zip(v0, v1)]
    return table[-1][1:]


def finish(ob, out, name, paint=None, smooth=50, tex=1024):
    P.finish(ob, os.path.join(out, name), tex=tex, pivot_bottom=False, weighted=False, smooth_angle=smooth, paint=paint,
             recalc_normals=False)
    return ob


def slab_ear(name, pts, t0, t1, rad, n, matrix, material=None):
    """like wr_lib.outline_slab (even inset rings, rounded edges both faces) but the two caps are n-gons ear-clipped by
    Blender: robust for long concave outlines (V-notch forks) where the CDT cap of outline_slab drops triangles"""
    depth = t1 - t0
    rb = rad
    if rb + rad > depth:
        f = depth / (rb + rad) * 0.999; rb *= f; rad *= f
    rings = []
    for j in range(0, n + 1):
        a = math.pi / 2 * j / n
        rings.append((t0 + rb - rb * math.cos(a), -(rb - rb * math.sin(a))))
    for j in range(n, -1, -1):
        a = math.pi / 2 * j / n
        rings.append((t1 - rad + rad * math.cos(a), -(rad - rad * math.sin(a))))
    clean = []
    for t, d in rings:
        if clean and abs(clean[-1][0] - t) < 1e-9 and abs(clean[-1][1] - d) < 1e-9:
            continue
        clean.append((t, d))
    bm = bmesh.new(); vr = []
    for t, d in clean:
        ring = W.offset_outline(pts, d) if abs(d) > 1e-9 else pts
        vr.append([bm.verts.new(matrix @ Vector((x, y, t))) for x, y in ring])
    m = len(pts)
    for r0, r1 in zip(vr[:-1], vr[1:]):
        for j in range(m):
            bm.faces.new((r0[j], r1[j], r1[(j + 1) % m], r0[(j + 1) % m]))
    caps = [bm.faces.new(vr[0]), bm.faces.new(vr[-1])]
    for cf in caps:                 # hard edge around the flat caps: no shading streaks across the long ear-clip triangles
        for e in cf.edges:
            e.smooth = False
    bmesh.ops.triangulate(bm, faces=caps, quad_method='BEAUTY', ngon_method='EAR_CLIP')
    return W._finish_bm(name, bm, material)
