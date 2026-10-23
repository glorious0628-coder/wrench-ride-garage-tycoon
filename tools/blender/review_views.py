# PBR review renders of one game-ready GLB (pp-3d-make 10-20, 1st review). EEVEE, real roughness/metal, soft studio
# light, orthographic, same scale for all six sides, transparent film (composite on white later).
#   blender --background --factory-startup --python review_views.py -- <file.glb> <out_dir> [px=1024]
# Writes front/back/left/right/top/bottom/threeq/threeq_back.png. glTF front = -Z -> Blender +Y, so "front" looks from
# +Y; "left" = the object's OWN left (camera on Blender -X), matching the 6-view sheet (front, back, left / right,
# top, bottom). Top = looking down with the front at the picture's bottom, bottom = looking up with the front at the top.
import bpy, sys, os, math
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
glb, out = os.path.abspath(argv[0]), os.path.abspath(argv[1])
PX = int(argv[2]) if len(argv) > 2 else 1024
os.makedirs(out, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=glb)
objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
for o in objs:
    for c in o.bound_box:
        w = o.matrix_world @ Vector(c)
        lo = Vector(map(min, lo, w)); hi = Vector(map(max, hi, w))
center = (lo + hi) / 2; size = max(hi - lo)
tris = sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in objs)
print("TRIS", tris, "DIM", [round(v, 3) for v in (hi - lo)])

sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE"
sc.render.film_transparent = True
sc.render.resolution_x = sc.render.resolution_y = PX
sc.view_settings.view_transform = "Standard"
try:
    sc.eevee.taa_render_samples = 32
except Exception:
    pass
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = sc.world.node_tree.nodes["Background"]; bg.inputs[0].default_value = (1, 1, 1, 1); bg.inputs[1].default_value = 0.55


def light(name, kind, energy, loc, size=1.0):
    ld = bpy.data.lights.new(name, kind); ld.energy = energy
    if kind == "AREA":
        ld.size = size * 3
    ob = bpy.data.objects.new(name, ld); sc.collection.objects.link(ob)
    ob.location = center + Vector(loc) * size * 3
    ob.rotation_euler = (-(Vector(loc))).to_track_quat("-Z", "Y").to_euler()


light("key", "AREA", 400 * size * size, (0.8, 1.2, 1.4), size)
light("fill", "AREA", 160 * size * size, (-1.3, 0.6, 0.6), size)
light("rim", "AREA", 160 * size * size, (0.2, -1.4, 1.0), size)
light("under", "AREA", 50 * size * size, (0, 0.3, -1.4), size)

cam_data = bpy.data.cameras.new("cam"); cam_data.type = "ORTHO"
cam = bpy.data.objects.new("cam", cam_data); sc.collection.objects.link(cam); sc.camera = cam


def shoot(name, direction, scale, up=(0, 0, 1)):
    from mathutils import Matrix
    d = Vector(direction).normalized(); f = -d
    r = f.cross(Vector(up)).normalized(); u = r.cross(f)
    cam.matrix_world = Matrix.Translation(center + d * (size * 3)) @ Matrix((
        (r.x, u.x, -f.x, 0), (r.y, u.y, -f.y, 0), (r.z, u.z, -f.z, 0), (0, 0, 0, 1)))
    cam_data.ortho_scale = scale; cam_data.clip_end = size * 10
    sc.render.filepath = os.path.join(out, name + ".png")
    bpy.ops.render.render(write_still=True)


s = size * 1.1
for n, d, up in (("front", (0, 1, 0), (0, 0, 1)), ("back", (0, -1, 0), (0, 0, 1)), ("left", (-1, 0, 0), (0, 0, 1)),
                 ("right", (1, 0, 0), (0, 0, 1)), ("top", (0, 0, 1), (0, -1, 0)), ("bottom", (0, 0, -1), (0, 1, 0))):
    shoot(n, d, s, up)
shoot("threeq", (1, 1, 0.8), size * 1.45)
shoot("threeq_back", (-1, -1, 0.8), size * 1.45)
print("done", out)
