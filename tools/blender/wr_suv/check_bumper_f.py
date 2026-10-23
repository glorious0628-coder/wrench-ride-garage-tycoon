# Bumper_F vs Chassis / Shell overlap by slot material (wr-3d-suv 2nd pass: bigger black grille + front skid plate must
# not poke into the radiator support / body).
#   blender --background --factory-startup --python tools/blender/wr_suv/check_bumper_f.py -- <suv_body_slots.blend>
import bpy, bmesh, sys, os
from mathutils.bvhtree import BVHTree
a = sys.argv[sys.argv.index("--") + 1:]
bpy.ops.wm.open_mainfile(filepath=os.path.abspath(a[0]))
O = bpy.data.objects


def tree(ob, pred=lambda f: True):
    b = bmesh.new(); b.from_mesh(ob.data)
    bmesh.ops.delete(b, geom=[f for f in b.faces if not pred(f)], context='FACES')
    n = len(b.faces); t = BVHTree.FromBMesh(b); b.free()
    return t, n


tc, _ = tree(O["Chassis"]); ts, _ = tree(O["Shell"])
bf = O["Bumper_F"]; out = {}
for i, m in enumerate(bf.data.materials):
    t, n = tree(bf, lambda f, i=i: f.material_index == i)
    if n:
        out[m.name] = dict(faces=n, chassis=len(t.overlap(tc)), shell=len(t.overlap(ts)))
print("BUMPER_F OVERLAP", out)
