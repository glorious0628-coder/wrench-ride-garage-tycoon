# Review scene with the coloured hood opened (wr-3d-suv): imports GLBs, turns the object "Hood" +70 deg about the
# Hinge (car coords), saves a .blend for render_suv.py.  blender ... -- <hinge.json(hood_attachments)> <out.blend> <glb>[;<glb>...]
import bpy, sys, json, math
from mathutils import Matrix, Vector
a = sys.argv[sys.argv.index("--") + 1:]
h = json.load(open(a[0]))["Hinge"]["position"]
bpy.ops.wm.read_factory_settings(use_empty=True)
for p in a[2].split(";"):
    bpy.ops.import_scene.gltf(filepath=p)
hood = [o for o in bpy.context.scene.objects if o.type == 'MESH' and o.name.startswith("Hood")][0]
c = Vector((h[0], -h[2], h[1]))
hood.matrix_world = Matrix.Translation(c) @ Matrix.Rotation(math.radians(70), 4, 'X') @ Matrix.Translation(-c) @ hood.matrix_world
bpy.ops.wm.save_as_mainfile(filepath=a[1])
print("saved", a[1])
