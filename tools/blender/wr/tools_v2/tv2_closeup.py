# Close-up / custom-angle review render of one GLB (wr 3D helper 10-22). Same light + look as tools/blender/review_views.py.
# Coordinates are the BUILD frame (the GLB is imported back to it: front = +Y, up = +Z).
#   blender -b --factory-startup --python tv2_closeup.py -- <glb> <out.png> <cx,cy,cz> <dx,dy,dz> <ortho_scale> [px=1024] [more.glb ...]
# camera looks at the centre from direction d (unit vector from the centre toward the camera). Extra GLBs are imported
# as they are (use for props placed by a json elsewhere).
import bpy, sys, os, math
from mathutils import Vector, Matrix

a = sys.argv[sys.argv.index("--") + 1:]
glb, out = os.path.abspath(a[0]), os.path.abspath(a[1])
cen = Vector([float(v) for v in a[2].split(",")])
d = Vector([float(v) for v in a[3].split(",")]).normalized()
scale = float(a[4]); PX = int(a[5]) if len(a) > 5 else 1024
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=glb)
sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE"; sc.render.film_transparent = False
sc.render.resolution_x = sc.render.resolution_y = PX
sc.view_settings.view_transform = "Standard"
try:
    sc.eevee.taa_render_samples = 32
except Exception:
    pass
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = sc.world.node_tree.nodes["Background"]; bg.inputs[0].default_value = (1, 1, 1, 1); bg.inputs[1].default_value = 0.55
size = 2.0


def light(name, kind, energy, loc):
    ld = bpy.data.lights.new(name, kind); ld.energy = energy
    if kind == "AREA":
        ld.size = size * 3
    ob = bpy.data.objects.new(name, ld); sc.collection.objects.link(ob)
    ob.location = cen + Vector(loc) * size * 3
    ob.rotation_euler = (-(Vector(loc))).to_track_quat("-Z", "Y").to_euler()


light("key", "AREA", 400 * size * size, (0.8, 1.2, 1.4)); light("fill", "AREA", 160 * size * size, (-1.3, 0.6, 0.6))
light("rim", "AREA", 160 * size * size, (0.2, -1.4, 1.0)); light("under", "AREA", 50 * size * size, (0, 0.3, -1.4))
cd = bpy.data.cameras.new("cam"); cd.type = "ORTHO"
cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
f = -d; up = Vector((0, 0, 1)) if abs(d.z) < 0.95 else Vector((0, 1, 0))
r = f.cross(up).normalized(); u = r.cross(f)
cam.matrix_world = Matrix.Translation(cen + d * 10) @ Matrix(((r.x, u.x, -f.x, 0), (r.y, u.y, -f.y, 0), (r.z, u.z, -f.z, 0), (0, 0, 0, 1)))
cd.ortho_scale = scale; cd.clip_end = 40
sc.render.filepath = out
bpy.ops.render.render(write_still=True)
print("ok", out)
