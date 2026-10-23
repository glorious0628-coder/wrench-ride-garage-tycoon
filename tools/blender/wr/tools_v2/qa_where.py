# Where does the QA (blender-asset-qa) see overlapping coplanar faces / hidden back-to-back faces? Same test as
# .claude/skills/blender-asset-qa/scripts/qa_check.py but it prints the places (Blender world coords of the GLB import:
# +Y = the model's front = glTF -Z, +Z = up).
#   blender -b --factory-startup -P qa_where.py -- <glb> [eps=0.001]
import sys, os, math
import bpy, bmesh
from collections import Counter
from mathutils import Vector
from mathutils.bvhtree import BVHTree

a = sys.argv[sys.argv.index("--") + 1:]
glb = os.path.abspath(a[0]); eps = float(a[1]) if len(a) > 1 else 0.001
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=glb)
for ob in bpy.context.scene.objects:
    if ob.type == "MESH" and ob.data.users == 1:
        bm = bmesh.new(); bm.from_mesh(ob.data); bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5); bm.to_mesh(ob.data); bm.free()
verts, tris, meta = [], [], []
for ob in [o for o in bpy.context.scene.objects if o.type == "MESH"]:
    bm = bmesh.new(); bm.from_mesh(ob.data); bm.transform(ob.matrix_world)
    bmesh.ops.triangulate(bm, faces=bm.faces[:]); bm.verts.ensure_lookup_table()
    base = len(verts); verts.extend(v.co.copy() for v in bm.verts)
    for f in bm.faces:
        tris.append(tuple(base + v.index for v in f.verts)); meta.append((ob.name, f.normal.copy(), f.index))
    bm.free()


def in_tri(p, a_, b_, c_, n):
    for u, v in ((a_, b_), (b_, c_), (c_, a_)):
        if (v - u).cross(p - u).dot(n) < -1e-9:
            return False
    return True


bvh = BVHTree.FromPolygons(verts, tris, epsilon=0.0)
sets = [set(t) for t in tris]
zf, bb = set(), set()
for ti, t in enumerate(tris):
    A, B, C = (verts[i] for i in t); n = meta[ti][1]
    if n.length < 0.5:
        continue
    cen = (A + B + C) / 3
    for p in (cen, cen.lerp(A, .6), cen.lerp(B, .6), cen.lerp(C, .6)):
        for _, _, tj, _ in bvh.find_nearest_range(p, eps):
            if tj is None or tj == ti or (sets[ti] & sets[tj]):
                continue
            n2 = meta[tj][1]; d = n.dot(n2)
            if abs(d) < 0.999:
                continue
            A2, B2, C2 = (verts[i] for i in tris[tj])
            q = p - n2 * n2.dot(p - A2)
            if in_tri(q, A2, B2, C2, n2):
                (zf if d > 0 else bb).add((min(ti, tj), max(ti, tj)))


def report(name, pairs):
    print(name, len(pairs))
    c = Counter()
    for i, j in pairs:
        cen = sum((verts[k] for k in tris[i]), Vector()) / 3
        c[(meta[i][0], round(cen.x, 1), round(cen.y, 1), round(cen.z, 1))] += 1
    for k, v in c.most_common(25):
        print("   ", k, v)


report("ZFIGHT", zf); report("BACK2BACK", bb)
for i, j in sorted(bb)[:6]:
    pa = [tuple(round(c, 4) for c in verts[k]) for k in tris[i]]; pb = [tuple(round(c, 4) for c in verts[k]) for k in tris[j]]
    print("PAIR", [round(c, 3) for c in meta[i][1]], pa, "|", [round(c, 3) for c in meta[j][1]], pb)
print("ZF-DETAIL")
shown = 0
for i, j in sorted(zf):
    ci = sum((verts[k] for k in tris[i]), Vector()) / 3
    pa = [tuple(round(c, 4) for c in verts[k]) for k in tris[i]]; pb = [tuple(round(c, 4) for c in verts[k]) for k in tris[j]]
    print("ZPAIR", [round(c, 3) for c in meta[i][1]], pa, "|", [round(c, 3) for c in meta[j][1]], pb)
    shown += 1
    if shown >= int(os.environ.get("QA_SHOW", "10")):
        break
