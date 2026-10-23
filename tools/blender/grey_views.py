# Grey shape review (pp-3d-make 10-20, user: "회색 모델링을 먼저 매끈하게 하고, 그 다음에 색을 입히는 걸로 해").
# Every material is replaced by one mid-grey semi-gloss plastic, so only the SHAPE is judged: smoothness, round circles,
# gaps, flipped faces (back-face culling on in the Workbench pass: a flipped face shows as a hole).
#   blender --background --factory-startup --python grey_views.py -- <file.glb> <out_dir> [px=1024]
# Writes <out>/eevee_<view>.png (soft studio light + a raking key that shows dents) and <out>/wb_<view>.png
# (Workbench studio light, cavity, back-face culling), views front/back/left/right/top/bottom/threeq/threeq_back,
# plus sheet.png (all of them, 2 rows).
import bpy, sys, os, math
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
glb, out = os.path.abspath(argv[0]), os.path.abspath(argv[1])
PX = int(argv[2]) if len(argv) > 2 else 1024
os.makedirs(out, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=glb)
objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
grey = bpy.data.materials.new("grey"); grey.use_nodes = True
b = grey.node_tree.nodes["Principled BSDF"]
b.inputs["Base Color"].default_value = (0.42, 0.42, 0.42, 1); b.inputs["Roughness"].default_value = 0.32
grey.use_backface_culling = True
for o in objs:
    o.data.materials.clear(); o.data.materials.append(grey)
lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
for o in objs:
    for c in o.bound_box:
        w = o.matrix_world @ Vector(c); lo = Vector(map(min, lo, w)); hi = Vector(map(max, hi, w))
center = (lo + hi) / 2; size = max(hi - lo)
tris = sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in objs)
print("TRIS", tris)
sc = bpy.context.scene
sc.render.resolution_x = sc.render.resolution_y = PX
sc.view_settings.view_transform = "Standard"
sc.render.film_transparent = True
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = sc.world.node_tree.nodes["Background"]; bg.inputs[0].default_value = (0.92, 0.92, 0.92, 1); bg.inputs[1].default_value = 0.25


def light(name, energy, loc):
    ld = bpy.data.lights.new(name, "AREA"); ld.energy = energy * size * size; ld.size = size * 1.2
    ob = bpy.data.objects.new(name, ld); sc.collection.objects.link(ob)
    ob.location = center + Vector(loc) * size * 3
    ob.rotation_euler = (-(Vector(loc))).to_track_quat("-Z", "Y").to_euler()


light("key", 260, (0.9, 1.0, 1.6))      # high raking key: dents and facets show
light("fill", 50, (-1.4, 0.5, 0.3))
light("rim", 90, (0.0, -1.5, 0.8))
cd = bpy.data.cameras.new("cam"); cd.type = "ORTHO"
cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
V = [("front", (0, 1, 0), (0, 0, 1)), ("back", (0, -1, 0), (0, 0, 1)), ("left", (-1, 0, 0), (0, 0, 1)),
     ("right", (1, 0, 0), (0, 0, 1)), ("top", (0, 0, 1), (0, -1, 0)), ("bottom", (0, 0, -1), (0, 1, 0)),
     ("threeq", (1, 1, 0.8), (0, 0, 1)), ("threeq_back", (-1, -1, 0.8), (0, 0, 1))]


def shoot(name, d, up, prefix):
    d = Vector(d).normalized(); f = -d; r = f.cross(Vector(up)).normalized(); u = r.cross(f)
    cam.matrix_world = Matrix.Translation(center + d * size * 3) @ Matrix(((r.x, u.x, -f.x, 0), (r.y, u.y, -f.y, 0),
                                                                           (r.z, u.z, -f.z, 0), (0, 0, 0, 1)))
    cd.ortho_scale = size * (1.45 if name.startswith("threeq") else 1.1); cd.clip_end = size * 10
    sc.render.filepath = os.path.join(out, prefix + name + ".png"); bpy.ops.render.render(write_still=True)


sc.render.engine = "BLENDER_EEVEE"
for n, d, up in V:
    shoot(n, d, up, "eevee_")
sc.render.engine = "BLENDER_WORKBENCH"; sh = sc.display.shading
sh.light = "STUDIO"; sh.color_type = "SINGLE"; sh.single_color = (0.62, 0.62, 0.62)
sh.show_cavity = True; sh.cavity_type = "BOTH"; sh.show_backface_culling = True; sh.show_specular_highlight = True
for n, d, up in V:
    shoot(n, d, up, "wb_")

print("done", out)
