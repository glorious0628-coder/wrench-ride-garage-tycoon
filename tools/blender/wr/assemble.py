# Put several part GLBs together for review renders (wr-3d 10-21). Each GLB is moved by its offset (BUILD frame:
# +X car right, +Y car front, +Z up; = where its pivot sits relative to the wheel centre), then everything is turned
# about Z by rotz degrees (90: the outboard face (+X) looks at review "front" (+Y), like the 6-view concept's front)
# and written as one GLB (meshes kept separate). The review tools (grey_views / review_views) read that GLB.
#   blender --background --factory-startup --python assemble.py -- <out.glb> <rotz> <a.glb> dx dy dz [mirror] [<b.glb> ...]
import bpy, sys, math
from mathutils import Matrix, Vector

argv = sys.argv[sys.argv.index("--") + 1:]
out, rotz = argv[0], float(argv[1]); rest = argv[2:]
bpy.ops.wm.read_factory_settings(use_empty=True)
i = 0
while i < len(rest):
    path = rest[i]; off = Vector([float(v) for v in rest[i + 1:i + 4]]); i += 4
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    for o in set(bpy.data.objects) - before:
        if o.type == 'MESH':
            o.data.transform(o.matrix_world); o.matrix_world = Matrix.Identity(4)
            o.data.transform(Matrix.Translation(off))
R = Matrix.Rotation(math.radians(rotz), 4, 'Z')
for o in bpy.data.objects:
    if o.type == 'MESH':
        o.data.transform(R)
for o in bpy.context.scene.objects:
    o.select_set(o.type == 'MESH')
bpy.ops.export_scene.gltf(filepath=out, export_format='GLB', use_selection=True)
print("assembled", out)
