# Creeper review renders (3D helper 10-22): the finished Creeper.glb with a blocky R15 (tools/blender/r15_preview.py glb)
#   lying on its back on it, same scale: side, 3/4, a low "UnderView-like" camera beside the body (CarParts.lie:
#   camera 1.9 stud along the car from the body line, at floor + 1.0, looking along the floor), and the concept pose
#   (leaning on a wall, headrest up, casters to the wall). EEVEE, white background, real PBR from the GLB.
#   blender -b --factory-startup -P render_review.py -- <Creeper.glb> <r15_preview.glb> <out_dir>
import bpy, sys, os, math
from mathutils import Vector, Matrix
a = sys.argv[sys.argv.index("--") + 1:]
GLB, R15, OUT = (os.path.abspath(x) for x in a[:3]); os.makedirs(OUT, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE"
sc.view_settings.view_transform = "Standard"
sc.render.film_transparent = False
w = bpy.data.worlds.new("w"); w.use_nodes = True
w.node_tree.nodes["Background"].inputs[0].default_value = (1, 1, 1, 1)
w.node_tree.nodes["Background"].inputs[1].default_value = 1.0
sc.world = w
for rot, e in (((50, 0, -35), 2.2), ((60, 0, 150), 0.8)):
    s = bpy.data.objects.new("sun", bpy.data.lights.new("sun", "SUN")); s.data.energy = e
    s.rotation_euler = [math.radians(v) for v in rot]; sc.collection.objects.link(s)
# floor (light grey, catches the shadow)
bpy.ops.mesh.primitive_plane_add(size=60, location=(0, 0, 0)); fl = bpy.context.object
fm = bpy.data.materials.new("floor"); fm.use_nodes = True
fm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.82, 0.82, 0.83, 1)
fm.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.9
fl.data.materials.append(fm)

bpy.ops.import_scene.gltf(filepath=GLB)
cr = [o for o in bpy.context.selected_objects if o.type == 'MESH'][0]
PAD_TOP = 0.492          # pad top at the centre line (0.478 sides + 0.014 crown)
HEAD_TOP_Y = 1.78        # R15 head top 0.12 inside the head end (+Y in Blender = Roblox -Z)


def mat(n, c, r=0.8):
    m = bpy.data.materials.new(n); m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]; b.inputs["Base Color"].default_value = (*c, 1); b.inputs["Roughness"].default_value = r
    return m


skin, shirt, pants = mat("skin", (0.95, 0.78, 0.25)), mat("shirt", (0.13, 0.33, 0.70)), mat("pants", (0.16, 0.17, 0.20))
bpy.ops.import_scene.gltf(filepath=R15)
r15 = [o for o in bpy.context.selected_objects if o.type == 'MESH']
for o in r15:
    nm = o.name.lower()
    o.data.materials.clear()
    o.data.materials.append(skin if "head" in nm else shirt if (("torso" in nm and "pants" not in nm) or "arm" in nm) else pants)
    # lie on the back, head toward +Y: rotate X -90 (up -> +Y, front -> +Z), back plane of the torso on the pad top
    o.matrix_world = Matrix.Translation((0, HEAD_TOP_Y - 5.19, PAD_TOP + 0.5)) @ Matrix.Rotation(-math.pi / 2, 4, 'X') @ o.matrix_world
    o.hide_render = True

cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); sc.collection.objects.link(cam); sc.camera = cam


def shot(name, loc, target, lens=None, ortho=None, res=(1200, 800), r15_on=False):
    for o in r15:
        o.hide_render = not r15_on
    if ortho:
        cam.data.type = 'ORTHO'; cam.data.ortho_scale = ortho
    else:
        cam.data.type = 'PERSP'; cam.data.lens = lens or 35
    cam.location = Vector(loc)
    cam.rotation_euler = (Vector(target) - cam.location).to_track_quat('-Z', 'Y').to_euler()
    sc.render.resolution_x, sc.render.resolution_y = res
    sc.render.filepath = os.path.join(OUT, name + ".png")
    bpy.ops.render.render(write_still=True)


# same scale with the lying R15: side (orthographic, from the character's left = Blender +X), 3/4
shot("r15_side", (30, -0.9, 1.0), (0, -0.9, 1.0), ortho=7.6, res=(1400, 560), r15_on=True)
shot("r15_q34", (5.2, 5.6, 2.6), (0, -0.4, 0.5), lens=40, res=(1200, 800), r15_on=True)
shot("r15_top", (0, -0.9, 30), (0, -0.9, 0), ortho=7.6, res=(800, 1100), r15_on=True)
# UnderView-like: camera beside the body 1.9 stud along the car (here: along -X... the body lies along Y, so the camera
# sits 1.9 to the side), at floor + 1.0, a bit toward the head from the root, looking along the floor past the head
root_y = HEAD_TOP_Y - 5.19 + 3.0        # R15 root (torso centre) along Y
# (CarParts Under_Rear: eye 1.6 from the body line, 0.9 toward the head from the root, floor + 1.0, looking at the head
# end past the body, vertical fov 60 = Config Under fov; the arm on the camera side hidden as if raised to the work)
for o in r15:
    if o.name.lower().startswith("armr"):
        o.hide_set(True)
cam.data.sensor_fit = 'VERTICAL'
lens60 = 12 / math.tan(math.radians(30))
for o in r15:
    o.hide_render = False
arm = [o for o in r15 if o.name.lower().startswith("armr")]
for o in arm:
    o.hide_render = True
cam.data.type = 'PERSP'; cam.data.lens = lens60
cam.location = Vector((-1.6, root_y + 0.9, 1.0))
cam.rotation_euler = (Vector((0.3, root_y + 2.5, 0.8)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
sc.render.resolution_x, sc.render.resolution_y = 1280, 720
sc.render.filepath = os.path.join(OUT, "underview_like.png"); bpy.ops.render.render(write_still=True)
for o in arm:
    o.hide_render = False
cam.data.sensor_fit = 'AUTO'
# no character: 3/4 close, a standing R15 beside it (same scale), and the concept pose (leaning on a wall, headrest up)
shot("solo_q34", (4.2, -4.8, 3.3), (0, -0.2, 0.25), lens=50, res=(1200, 800))
bpy.ops.import_scene.gltf(filepath=R15)
standing = [o for o in bpy.context.selected_objects if o.type == 'MESH']
for o in standing:
    nm = o.name.lower()
    o.data.materials.clear()
    o.data.materials.append(skin if "head" in nm else shirt if (("torso" in nm and "pants" not in nm) or "arm" in nm) else pants)
    o.matrix_world = Matrix.Translation((-2.6, 0.6, 0)) @ Matrix.Rotation(math.radians(-60), 4, 'Z') @ o.matrix_world
shot("solo_r15_standing", (7.0, -8.6, 5.2), (-1.0, 0.1, 1.9), lens=35, res=(1200, 900))
for o in standing:
    o.hide_render = True
lean = math.radians(72)
cr.matrix_world = Matrix.Translation((0, 0.0, 0)) @ Matrix.Rotation(lean, 4, 'X') @ Matrix.Translation((0, 1.9, 0))
# (rotate about the foot end on the floor: head end up, casters toward +Y = the wall side)
bpy.context.view_layer.update()
lo = min((cr.matrix_world @ Vector(c)).z for c in cr.bound_box)
cr.location.z -= lo
bpy.ops.mesh.primitive_plane_add(size=12, location=(0, 1.22, 3)); wall = bpy.context.object
wall.rotation_euler = (math.radians(90), 0, 0)
wm = bpy.data.materials.new("wall"); wm.use_nodes = True
wm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.86, 0.85, 0.82, 1)
wall.data.materials.append(wm)
shot("lean_wall", (-2.6, -6.5, 2.4), (0, 0.4, 1.8), lens=40, res=(800, 1000))
print("REVIEW_OK", OUT)
