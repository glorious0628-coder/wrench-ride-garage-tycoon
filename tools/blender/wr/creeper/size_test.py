# Creeper size test (3D helper 10-22): blocky R15 (tools/blender/r15_preview.py glb) lying on its back on placeholder
# creeper boards of a few sizes, same scale, rendered top + side + 3/4 -> picks the in-game length / width.
#   blender -b --factory-startup -P size_test.py -- <r15_preview.glb> <out_dir>
import bpy, sys, os, math
from mathutils import Vector, Matrix
a = sys.argv[sys.argv.index("--") + 1:]
R15, OUT = os.path.abspath(a[0]), os.path.abspath(a[1]); os.makedirs(OUT, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
VARS = [("real 3.63 x 1.68 (40 x 18.5 in)", 3.63, 1.68, 0.0), ("game 3.8 x 2.0", 3.8, 2.0, 5.0), ("wide 3.8 x 2.4", 3.8, 2.4, 10.4)]
DECK = 0.44


def mat(n, c):
    m = bpy.data.materials.new(n); m.use_nodes = True
    m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (*c, 1)
    m.diffuse_color = (*c, 1)
    return m


red, blk, skin, shirt, pants = mat("r", (0.6, 0.03, 0.03)), mat("k", (0.02, 0.02, 0.02)), mat("s", (0.9, 0.75, 0.3)), mat("t", (0.1, 0.25, 0.6)), mat("p", (0.12, 0.12, 0.14))


def box(n, s, c, m):
    bpy.ops.mesh.primitive_cube_add(size=1, location=c); o = bpy.context.object; o.scale = s; o.name = n
    o.data.materials.append(m); return o


for label, L, W, x0 in VARS:
    box("deck", (W - 0.12, L - 0.1, 0.12), (x0, 0, DECK - 0.06), red)
    for sx in (-1, 1):
        box("rail", (0.10, L, 0.10), (x0 + sx * (W / 2 - 0.05), 0, 0.31), red)
        for y in (-L / 2 + 0.2, 0, L / 2 - 0.2):
            box("wheel", (0.09, 0.22, 0.22), (x0 + sx * (W / 2 - 0.05), y, 0.11), blk)
    box("head", (0.9, 0.45, 0.14), (x0, L / 2 - 0.3, DECK + 0.07), blk)
    bpy.ops.import_scene.gltf(filepath=R15)
    obs = [o for o in bpy.context.selected_objects if o.type == 'MESH']
    for o in obs:
        nm = o.name.lower()
        o.data.materials.clear(); o.data.materials.append(skin if "head" in nm else shirt if ("torso" in nm and "pants" not in nm) or "arm" in nm else pants)
        # lie on the back, head toward +Y: rotate X -90 (z -> y, -y (front) -> +z), back (y=+0.5) onto the deck
        o.matrix_world = Matrix.Translation((x0, L / 2 - 0.12 - 5.19, DECK + 0.14 + 0.5)) @ Matrix.Rotation(-math.pi / 2, 4, 'X') @ o.matrix_world
sc.render.engine = 'BLENDER_WORKBENCH'; sc.display.shading.light = 'STUDIO'; sc.display.shading.color_type = 'MATERIAL'
sc.display.shading.show_cavity = True
sc.render.resolution_x, sc.render.resolution_y = 1400, 700
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); sc.collection.objects.link(cam); sc.camera = cam
cam.data.type = 'ORTHO'
for name, loc, rot, osc in [("top", (5.2, -0.6, 30), (0, 0, 0), 15.5), ("end", (5.2, -40, 0.8), (math.radians(90), 0, 0), 15.5),
                            ("side", (40, 0.0, 0.8), (math.radians(90), 0, math.radians(90)), 7.0)]:
    cam.location = loc; cam.rotation_euler = rot; cam.data.ortho_scale = osc
    sc.render.filepath = os.path.join(OUT, "size_" + name + ".png"); bpy.ops.render.render(write_still=True)
cam.data.type = 'PERSP'; cam.data.lens = 35
cam.location = (5.2 + 12, -16, 9); cam.rotation_euler = (Vector((5.2, 0, 0.5)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
sc.render.filepath = os.path.join(OUT, "size_q34.png"); bpy.ops.render.render(write_still=True)
print("SIZE_OK")
