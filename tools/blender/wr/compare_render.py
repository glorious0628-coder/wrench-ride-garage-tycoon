# Side-by-side comparison renders (wr-3d 10-21): two assembled corner GLBs (outboard face = +Y, wheel centre at the
# origin, made by assemble.py with rotz 90) stand on a floor next to each other.
#   persp: camera like Roblox's default (vertical FOV 70), eye 2.5 studs up, 25 deg to the side, at each distance
#   ortho: straight side view with a 1-stud ruler on the floor (size comparison)
#   blender --background --factory-startup --python compare_render.py -- <persp|ortho> <out_prefix> <a.glb> <a_centre_z> <b.glb> <b_centre_z> [dist ...]
import bpy, sys, math
from mathutils import Vector, Matrix

a = sys.argv[sys.argv.index("--") + 1:]
mode, out = a[0], a[1]
A, za, Bg, zb = a[2], float(a[3]), a[4], float(a[5])
dists = [float(v) for v in a[6:]] or [3, 8, 20]
bpy.ops.wm.read_factory_settings(use_empty=True)
GAP = 3.4


def load(p, off):
    before = set(bpy.data.objects); bpy.ops.import_scene.gltf(filepath=p)
    for o in set(bpy.data.objects) - before:
        if o.type == 'MESH':
            o.data.transform(o.matrix_world); o.matrix_world = Matrix.Identity(4); o.data.transform(Matrix.Translation(off))


load(A, Vector((-GAP / 2, 0, za))); load(Bg, Vector((GAP / 2, 0, zb)))
sc = bpy.context.scene
# floor
me = bpy.data.meshes.new("floor"); me.from_pydata([(-40, -40, 0), (40, -40, 0), (40, 40, 0), (-40, 40, 0)], [], [(0, 1, 2, 3)])
fl = bpy.data.objects.new("floor", me); sc.collection.objects.link(fl)
fm = bpy.data.materials.new("floor"); fm.use_nodes = True
fm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.32, 0.33, 0.35, 1)
fm.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.8
me.materials.append(fm)
if mode == "ortho":   # 1-stud ruler ticks along the floor in front of the wheels
    tm = bpy.data.materials.new("tick"); tm.use_nodes = True
    tm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.9, 0.75, 0.1, 1)
    for i in range(-4, 5):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(i, 1.6, 0.01))
        t = bpy.context.active_object; t.scale = (0.03, 0.03, 0.02 if i % 2 else 0.06); t.data.materials.append(tm)
    for h in (1.0, 2.0, 3.0):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(-4.6, 1.6, h))
        t = bpy.context.active_object; t.scale = (0.3, 0.02, 0.02); t.data.materials.append(tm)
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = sc.world.node_tree.nodes["Background"]; bg.inputs[0].default_value = (0.55, 0.62, 0.72, 1); bg.inputs[1].default_value = 0.9
sun = bpy.data.lights.new("sun", "SUN"); sun.energy = 3.0
so = bpy.data.objects.new("sun", sun); sc.collection.objects.link(so); so.rotation_euler = (math.radians(50), 0, math.radians(30))
sc.render.engine = "BLENDER_EEVEE"; sc.view_settings.view_transform = "Standard"
sc.render.resolution_x, sc.render.resolution_y = 1280, 720
cd = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
tgt = Vector((0, 0, (za + zb) / 2))


def aim(pos):
    cam.location = pos; cam.rotation_euler = (tgt - pos).to_track_quat("-Z", "Y").to_euler()


if mode == "persp":   # each corner alone, same camera pose relative to its own wheel centre
    cd.type = "PERSP"; cd.sensor_fit = "VERTICAL"; cd.angle_y = math.radians(70); cd.clip_start = 0.05
    groups = {}
    for o in sc.objects:
        if o.type == 'MESH' and o.name != "floor":
            groups.setdefault("A" if sum(v.co.x for v in o.data.vertices) / max(len(o.data.vertices), 1) < 0 else "B", []).append(o)
    for key, zc, xc in (("A", za, -GAP / 2), ("B", zb, GAP / 2)):
        for k2, obs in groups.items():
            for o in obs:
                o.hide_render = (k2 != key)
        t = Vector((xc, 0, zc))
        for d in dists:
            h = 2.5 - zc
            horiz = math.sqrt(max(d * d - h * h, 0.5))
            az = math.radians(25)
            pos = t + Vector((math.sin(az) * horiz, math.cos(az) * horiz, h))
            cam.location = pos; cam.rotation_euler = (t - pos).to_track_quat("-Z", "Y").to_euler()
            sc.render.filepath = "%s_%s_%gstud.png" % (out, key, d); bpy.ops.render.render(write_still=True)
else:
    cd.type = "ORTHO"; cd.ortho_scale = 10.5
    cam.location = Vector((0, 20, 1.6)); cam.rotation_euler = (math.radians(90), 0, math.radians(180))
    sc.render.filepath = out + "_ortho.png"; bpy.ops.render.render(write_still=True)
print("done", out)
