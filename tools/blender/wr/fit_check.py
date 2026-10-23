# Fit check (wr-3d): import part GLBs with offsets (build frame, like assemble.py) and report triangle overlaps
# between every pair (BVH) + each part's max radius around the wheel axis (X) and its X range.
#   blender --background --factory-startup --python fit_check.py -- <a.glb> dx dy dz [<b.glb> dx dy dz ...]
import bpy, sys, math, os
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree
argv = sys.argv[sys.argv.index("--") + 1:]
bpy.ops.wm.read_factory_settings(use_empty=True)
obs = []
i = 0
while i < len(argv):
    path = argv[i]; off = Vector([float(v) for v in argv[i + 1:i + 4]]); i += 4
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    for o in set(bpy.data.objects) - before:
        if o.type == 'MESH':
            o.data.transform(o.matrix_world); o.matrix_world = Matrix.Identity(4)
            o.data.transform(Matrix.Translation(off)); o.name = os.path.basename(path)
            obs.append(o)
trees = {}
for o in obs:
    vs = [v.co.copy() for v in o.data.vertices]
    trees[o.name] = BVHTree.FromPolygons(vs, [p.vertices[:] for p in o.data.polygons])
    rmax = max(math.hypot(v.y, v.z) for v in vs); xs = [v.x for v in vs]
    print("PART %-22s rmax %.3f  x %.3f .. %.3f" % (o.name, rmax, min(xs), max(xs)))
names = list(trees)
for a in range(len(names)):
    for b in range(a + 1, len(names)):
        n = len(trees[names[a]].overlap(trees[names[b]]))
        print("OVERLAP %-22s x %-22s %d tri pairs" % (names[a], names[b], n))
