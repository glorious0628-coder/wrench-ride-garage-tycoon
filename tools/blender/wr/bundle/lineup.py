# Side-view size lineup: our sedan + exported background cars, same scale (ortho), for the README / check sheet.
#   blender --background --factory-startup --python lineup.py -- <out.png> <out.json> <glb;glb;...>
# Writes the render and a json with each car's pixel span so labels / reference lines can be drawn afterwards.
import bpy, sys, os, json, math
from mathutils import Vector, Matrix
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bundle_lib as B  # noqa: E402

argv = sys.argv[sys.argv.index("--") + 1:]
outp, outj, glbs = argv[0], argv[1], argv[2].split(";")
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE"; sc.view_settings.view_transform = "Standard"; sc.render.film_transparent = False
w = bpy.data.worlds.new("w"); w.use_nodes = True; sc.world = w
w.node_tree.nodes["Background"].inputs[0].default_value = (1, 1, 1, 1); w.node_tree.nodes["Background"].inputs[1].default_value = 1.0
sd = bpy.data.lights.new("sun", "SUN"); sd.energy = 2.5; so = bpy.data.objects.new("sun", sd); sc.collection.objects.link(so)
so.rotation_euler = (math.radians(50), 0, math.radians(-120))
GAP = 3.0
y = 0.0; spans = []
# side view from +X (car right side): car front (+Y) points to the image right
items = [("OurSedan", None)] + [(os.path.basename(g)[:-4], g) for g in glbs]
for name, g in items:
    if g is None:
        E, meshes = B.place_our_sedan(paint="#098FFC")
    else:
        E, meshes, info = B.place_bundle_car(g, name, scale=1.0, keep_origin=True)
    lo, hi = B.bbox(meshes)
    E.location = (0, y - lo.y, 0); bpy.context.view_layer.update()
    lo2, hi2 = B.bbox(meshes)
    spans.append({"name": name, "y0": lo2.y, "y1": hi2.y, "h": hi2.z, "L": hi2.y - lo2.y})
    y = hi2.y + GAP
total = y - GAP
cd = bpy.data.cameras.new("cam"); cd.type = "ORTHO"; cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
PX = 22.0                       # pixels per stud
H_ST = 13.0
sc.render.resolution_x = int(total * PX) + 40; sc.render.resolution_y = int(H_ST * PX)
cd.ortho_scale = sc.render.resolution_x / PX
cx = total / 2; cz = H_ST / 2 - 0.6
cam.location = (100, cx, cz); cam.rotation_euler = Vector((-1, 0, 0)).to_track_quat("-Z", "Y").to_euler()   # right side; front -> image right
sc.render.filepath = outp; bpy.ops.render.render(write_still=True)
json.dump({"px_per_stud": PX, "res": [sc.render.resolution_x, sc.render.resolution_y], "centre_y": cx, "centre_z": cz, "spans": spans},
          open(outj, "w"), indent=1)
print("LINEUP", outp)
