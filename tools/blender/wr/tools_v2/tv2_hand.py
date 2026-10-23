# Hand-size check (wr 3D helper 10-22): the existing Wrench (art/3d/tool_wrench) and a new tool side by side, each with the
# 0.30 stud R15-fist box placed + turned by its json Grip (same box as tools/blender/wr/grip_check.py), same camera / scale.
#   blender -b --factory-startup --python tv2_hand.py -- <tool.glb> <tool_attachments.json> <out.png> [tool_scale_note]
# Optional 5th..: extra pairs "glb json" to put more tools in the row (all at one scale). Roblox axes -> Blender (x, -z, y).
import bpy, sys, os, json, math
from mathutils import Vector, Matrix

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
a = sys.argv[sys.argv.index("--") + 1:]
out = os.path.abspath(a[2])
pairs = [(os.path.join(ROOT, "art", "3d", "tool_wrench", "Wrench.glb"), os.path.join(ROOT, "art", "3d", "tool_wrench", "wrench_attachments.json")),
         (os.path.abspath(a[0]), os.path.abspath(a[1]))]
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene


def bl(v):
    return Vector((v[0], -v[2], v[1]))


def objs_of(before):
    return [o for o in bpy.data.objects if o not in before]


def extent(objs):
    lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
    for o in objs:
        if o.type != 'MESH':
            continue
        for c in o.bound_box:
            w = o.matrix_world @ Vector(c)
            lo = Vector(map(min, lo, w)); hi = Vector(map(max, hi, w))
    return lo, hi


skin = bpy.data.materials.new("skin"); skin.use_nodes = True
b = skin.node_tree.nodes["Principled BSDF"]; b.inputs["Base Color"].default_value = (1.0, 0.75, 0.55, 1); b.inputs["Alpha"].default_value = 0.45
try:
    skin.surface_render_method = 'BLENDED'
except Exception:
    pass
x_off = 0.0
allobjs = []
for glb, js in pairs:
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=glb)
    objs = objs_of(before)
    g = json.load(open(js, encoding="utf-8"))["Grip"]
    p, ax, sec = bl(g["pos"]), bl(g["axis"]).normalized(), bl(g["secondary_axis"]).normalized()
    third = ax.cross(sec).normalized(); sec = third.cross(ax).normalized()
    lo, hi = extent(objs)
    shift = Vector((x_off - lo.x, 0, 0))
    for o in objs:
        if o.parent is None:
            o.location += shift
    p = p + shift
    bpy.ops.mesh.primitive_cube_add(size=0.30)
    hand = bpy.context.active_object
    hand.matrix_world = Matrix.Translation(p) @ Matrix(((ax.x, sec.x, third.x, 0), (ax.y, sec.y, third.y, 0), (ax.z, sec.z, third.z, 0), (0, 0, 0, 1)))
    hand.data.materials.append(skin)
    allobjs += objs + [hand]
    lo, hi = extent(objs)
    x_off = hi.x + 0.5
lo, hi = extent(allobjs)
cen = (lo + hi) / 2; size = max(hi - lo)
sc.render.engine = "BLENDER_EEVEE"; sc.render.resolution_x = 1600; sc.render.resolution_y = 800
sc.view_settings.view_transform = "Standard"
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
sc.world.node_tree.nodes["Background"].inputs[0].default_value = (0.24, 0.25, 0.28, 1)
sun = bpy.data.lights.new("s", "SUN"); sun.energy = 3; so = bpy.data.objects.new("s", sun); sc.collection.objects.link(so); so.rotation_euler = (0.7, 0.2, 0.6)
cd = bpy.data.cameras.new("c"); cd.type = "ORTHO"; cd.ortho_scale = size * 1.08
cam = bpy.data.objects.new("c", cd); sc.collection.objects.link(cam); sc.camera = cam
d = Vector((0.15, 1, 0.55)).normalized(); cam.location = cen + d * size * 3; cam.rotation_euler = (-d).to_track_quat("-Z", "Y").to_euler()
cd.clip_end = size * 10
sc.render.filepath = out; bpy.ops.render.render(write_still=True)
print("ok", out)
