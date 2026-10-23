# Review scene for the SUV engine bay / underbody (wr-3d-suv 2nd pass): coloured body with the hood resting on the prop
# rod (hood_prop_attachments.json: hood_open_deg about the hood Hinge, rod turned open_angle_deg about its Hinge axis),
# coloured decor, the other helpers' parts (place_others_suv.py), review wheels, optional placeholders. Saves a .blend
# for render_suv.py (mode keep).  An empty <hood_open_deg> keeps the hood closed and the rod stowed.
#   blender ... --python bay_scene_suv.py -- <hood_attachments.json> <hood_prop_attachments.json> <out.blend> <glb>[;<glb>...] [closed]
import bpy, sys, json, math
from mathutils import Matrix, Vector
a = sys.argv[sys.argv.index("--") + 1:]
hinge = json.load(open(a[0]))["Hinge"]["position"]
prop = json.load(open(a[1]))
closed = len(a) > 4 and a[4] == "closed"
bpy.ops.wm.read_factory_settings(use_empty=True)
for p in a[3].split(";"):
    if p:
        bpy.ops.import_scene.gltf(filepath=p)
B = lambda c: Vector((c[0], -c[2], c[1]))          # car (x, Y, s) -> blender
if not closed:
    hood = [o for o in bpy.context.scene.objects if o.type == 'MESH' and o.name.startswith("Hood") and "Prop" not in o.name][0]
    c = B(hinge)
    hood.matrix_world = Matrix.Translation(c) @ Matrix.Rotation(math.radians(prop["hood_open_deg"]), 4, 'X') @ Matrix.Translation(-c) @ hood.matrix_world
    rods = [o for o in bpy.context.scene.objects if o.type == 'MESH' and o.name.startswith("HoodProp")]
    for rod in rods:
        pv = B(prop["Hinge"]["position"]); ax = B(prop["Hinge"]["axis"]).normalized()
        rod.matrix_world = Matrix.Translation(pv) @ Matrix.Rotation(math.radians(prop["open_angle_deg"]), 4, ax) @ Matrix.Translation(-pv) @ rod.matrix_world
    print("hood", hood.name, prop["hood_open_deg"], "rods", [r.name for r in rods])
bpy.ops.wm.save_as_mainfile(filepath=a[2])
print("saved", a[2])
