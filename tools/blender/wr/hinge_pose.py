# Hinge check (wr-3d): brake set with the Caliper turned about its Hinge (build frame: +X outboard, +Y front, +Z up)
# by `angle` degrees about +X, written as a review GLB (turned 90 deg about Z like assemble.py).
#   blender --background --factory-startup --python hinge_pose.py -- <out.glb> <angle> <hx> <hy> <hz> <Disc.glb> <Bracket.glb> <Caliper.glb> <Pads.glb> <pivot_y>
import bpy, sys, math
from mathutils import Matrix, Vector
a = sys.argv[sys.argv.index("--") + 1:]
out, ang = a[0], float(a[1]); H = Vector([float(v) for v in a[2:5]]); disc, br, cal, pads = a[5:9]; py_ = float(a[9])
bpy.ops.wm.read_factory_settings(use_empty=True)
def load(p, off, rot=None):
    before = set(bpy.data.objects); bpy.ops.import_scene.gltf(filepath=p)
    for o in set(bpy.data.objects) - before:
        if o.type == 'MESH':
            o.data.transform(o.matrix_world); o.matrix_world = Matrix.Identity(4); o.data.transform(Matrix.Translation(off))
            if rot is not None:
                o.data.transform(rot)
load(disc, Vector((0, 0, 0))); load(br, Vector((0, py_, 0))); load(pads, Vector((0, py_, 0)))
R = Matrix.Translation(H) @ Matrix.Rotation(math.radians(ang), 4, 'X') @ Matrix.Translation(-H)
load(cal, Vector((0, py_, 0)), R)
for o in bpy.data.objects:
    if o.type == 'MESH':
        o.data.transform(Matrix.Rotation(math.radians(90), 4, 'Z'))
for o in bpy.context.scene.objects:
    o.select_set(o.type == 'MESH')
bpy.ops.export_scene.gltf(filepath=out, export_format='GLB', use_selection=True)
print("posed", out)
