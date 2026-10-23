# Fit check of a tools_v2 hand tool against the engine bay (wr 3D helper 10-22): imports the bay (Detail GLB + the
# fastener kit preview = clip heads / hose bands that code will draw), puts the tool's working end ("Tip" of its
# attachments json) on the bay part's F_ point with the axes the json says, and renders close-ups.
#   blender -b --factory-startup --python tv2_fit.py -- <case> <out_dir> [px=900]
# cases: fuse, plug, hose, trim, pan (the pan also loads the sedan body: chassis / shell / front bumper)
# All the numbers in CASES are in glTF / Roblox axes (+Y up, front -Z) = car-local studs, like parts.json.
import bpy, sys, os, json, math
from mathutils import Vector, Matrix

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
T2 = os.path.join(ROOT, "art", "3d", "tools_v2")
BAY = os.path.join(ROOT, "art", "3d", "engine_bay_v2")
a = sys.argv[sys.argv.index("--") + 1:]
case, out = a[0], os.path.abspath(a[1]); PX = int(a[2]) if len(a) > 2 else 900
os.makedirs(out, exist_ok=True)


def V(*v):
    return Vector(v)


# tool_pt / tool_a1 / tool_a2 (json keys) -> world point / world a1 / a2 (roll fixed by a2). views: (name, centre, dir, ortho scale)
CASES = {
    "fuse": dict(glb="fuse_puller/FusePuller.glb", js="fuse_puller/fuse_puller_attachments.json", tip="Tip",
                 world=V(-2.9, 3.37, -5.93), a1_t=V(1, 0, 0), a1_w=V(0, -1, 0), a2_t=V(0, 1, 0), a2_w=V(1, 0, 0),
                 hide=("FuseBoxLid",), views=[("q", V(-2.9, 3.28, -5.93), V(0.5, 0.8, -0.5), 0.8), ("front", V(-2.9, 3.30, -5.93), V(0, 0, -1), 0.5, (V(0, 0, -1), 5.99)),
                                 ("side", V(-2.9, 3.30, -5.93), V(1, 0, 0), 0.5, (V(1, 0, 0), -2.90)), ("wide", V(-2.9, 3.0, -5.9), V(0.5, 0.7, -0.6), 2.4)]),
    "plug": dict(glb="plug_socket/PlugSocket.glb", js="plug_socket/plug_socket_attachments.json", tip="Tip",
                 world=V(-0.525, 2.695, -5.4), a1_t=V(0, -1, 0), a1_w=V(0, -1, 0), a2_t=V(0, 0, -1), a2_w=V(0, 0, -1),
                 hide=("EngineCover", "IgnitionCoil_", "kit_IgnitionCoil", "AirBox", "IntakeDuct"),
                 views=[("q", V(-0.5, 3.0, -5.4), V(0.5, 0.7, -0.6), 1.6), ("section", V(-0.525, 2.75, -5.4), V(0, 0, -1), 0.75, (V(0, 0, -1), 5.4, True)),
                        ("side", V(-0.5, 2.9, -5.4), V(0, 0, -1), 1.3),
                        ("wide", V(-0.2, 2.6, -5.4), V(0.4, 0.8, -0.7), 3.6)]),
    # clamp ear of the kit preview hangs under the ring (x 1.99, y 2.715): jaws come from below, pinch along Z
    "hose": dict(glb="hose_pliers/HosePliers.glb", js="hose_pliers/hose_pliers_attachments.json", tip="Tip",
                 world=V(1.99, 2.716, -7.69), a1_t=V(1, 0, 0), a1_w=V(0, 1, 0), a2_t=V(0, 1, 0), a2_w=V(0, 0, 1),
                 hide=(), views=[("close", V(1.99, 2.76, -7.69), V(1, 0.15, 0.45), 0.5), ("close2", V(1.99, 2.76, -7.69), V(0, 1, 0.02), 0.5),
                                 ("side", V(1.99, 2.4, -7.69), V(1, 0, 0), 2.0), ("q", V(1.6, 2.3, -7.4), V(0.7, 0.35, 0.65), 3.2)]),
    # clip head 0.1 wide on the radiator cover at (x -1.55, y 3.293, z -7.14): fork slides under it along the cover edge from the left (+X)
    # (toward the front, -Z), lift face up = the clip's pull-out axis
    "trim": dict(glb="trim_tool/TrimTool.glb", js="trim_tool/trim_tool_attachments.json", tip="Tip",
                 world=V(-1.55, 3.2926, -7.14), a1_t=V(0.9903, 0, 0.1392), a1_w=V(1, 0, 0), a2_t=V(-0.1392, 0, 0.9903), a2_w=V(0, 1, 0),
                 hide=(), views=[("close", V(-1.55, 3.3, -7.14), V(0.35, 0.6, 0.75), 0.4), ("side", V(-1.55, 3.3, -7.14), V(0, 0, 1), 0.5), ("section", V(-1.5, 3.3, -7.14), V(-1, 0, 0), 0.4, (V(-1, 0, 0), 1.5, True)),
                                 ("top", V(-1.55, 3.3, -7.14), V(0, 1, 0.01), 0.5), ("q", V(-1.9, 3.3, -6.9), V(0.4, 0.6, 0.7), 2.2)]),
    # drain pan under the radiator end of the car: Catch point (screen top centre) under the lower hose / radiator drain,
    # feet on the ground, spout toward the car front (-Z), handle end toward the engine
    "pan": dict(glb="drain_pan/DrainPan.glb", js="drain_pan/drain_pan_attachments.json", tip="Catch", car=("sedan_chassis.glb", "sedan_shell.glb", "sedan_bumper_f.glb"),
                world=V(-2.0, 0.372, -7.45), a1_t=V(0, 1, 0), a1_w=V(0, 1, 0), a2_t=V(0, 0, -1), a2_w=V(0, 0, -1),
                hide=(), views=[("side", V(-2.0, 1.2, -7.2), V(1, 0, 0), 3.6, (V(1, 0, 0), -2.0, True)),
                                ("front", V(-2.0, 1.4, -7.5), V(0, 0, -1), 4.2), ("q", V(-2.0, 0.9, -7.4), V(0.9, 0.35, -0.8), 4.8)]),
}
cfg = CASES[case]
Cm = Matrix(((1, 0, 0, 0), (0, 0, -1, 0), (0, 1, 0, 0), (0, 0, 0, 1)))          # glTF -> Blender
Ci = Cm.inverted()


def gl2b(v):
    return (Cm @ Vector((v.x, v.y, v.z, 1.0))).xyz


bpy.ops.wm.read_factory_settings(use_empty=True)
bay_objs = []
SCENE = [os.path.join(BAY, "sedan_bay_v2_Detail.glb"), os.path.join(BAY, "work", "fastener_kit_preview.glb")]
SCENE += [os.path.join(ROOT, "art", "3d", "sedan_body", "B_concept", f) for f in cfg.get("car", ())]
for f in SCENE:
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=f)
    bay_objs += [o for o in bpy.data.objects if o not in before]
for o in bay_objs:
    if any(o.name.startswith(h) for h in cfg["hide"] + ("HoodInsulator", "HoodInnerRibs")):
        o.hide_render = True; o.hide_viewport = True
before = set(bpy.data.objects)
bpy.ops.import_scene.gltf(filepath=os.path.join(T2, cfg["glb"]))
tool_objs = [o for o in bpy.data.objects if o not in before]
js = json.load(open(os.path.join(T2, cfg["js"]), encoding="utf-8"))
pt = Vector(js[cfg["tip"]]["pos"])


def frame(a1, a2):
    e1 = a1.normalized(); e2 = (a2 - e1 * a2.dot(e1)).normalized(); e3 = e1.cross(e2)
    return Matrix(((e1.x, e2.x, e3.x), (e1.y, e2.y, e3.y), (e1.z, e2.z, e3.z)))


Rt = frame(cfg["a1_t"], cfg["a2_t"]); Rw = frame(cfg["a1_w"], cfg["a2_w"])
R = Rw @ Rt.transposed()
M = Matrix.Translation(cfg["world"]) @ R.to_4x4() @ Matrix.Translation(-pt)
Mb = Cm @ M @ Ci
for o in tool_objs:
    if o.parent is None:
        o.matrix_world = Mb @ o.matrix_world
print("tool placed: tip", cfg["world"], "R", R.to_euler())

sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE"; sc.render.film_transparent = False
sc.render.resolution_x = sc.render.resolution_y = PX
sc.view_settings.view_transform = "Standard"
try:
    sc.eevee.taa_render_samples = 32
except Exception:
    pass
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = sc.world.node_tree.nodes["Background"]; bg.inputs[0].default_value = (0.86, 0.87, 0.89, 1); bg.inputs[1].default_value = 0.9
cen0 = gl2b(cfg["world"])


def light(name, kind, energy, loc):
    ld = bpy.data.lights.new(name, kind); ld.energy = energy
    if kind == "AREA":
        ld.size = 6
    ob = bpy.data.objects.new(name, ld); sc.collection.objects.link(ob)
    ob.location = cen0 + Vector(loc) * 6
    ob.rotation_euler = (-(Vector(loc))).to_track_quat("-Z", "Y").to_euler()


light("key", "AREA", 1600, (0.8, 1.2, 1.4)); light("fill", "AREA", 700, (-1.3, 0.6, 0.6))
light("rim", "AREA", 500, (0.2, -1.4, 1.0)); light("top", "AREA", 500, (0.0, 0.2, 2.0))
cd = bpy.data.cameras.new("cam"); cd.type = "ORTHO"; cd.clip_start = 0.01; cd.clip_end = 200
cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
def add_cut(n, d, with_tool=False):
    nb = gl2b(n); 
    cut = bpy.data.objects.new("cutter", bpy.data.meshes.new("cutter"))
    import bmesh
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); bm.to_mesh(cut.data); bm.free()
    sc.collection.objects.link(cut)
    cut.scale = (60, 60, 60) if False else (abs(nb.x) * 60 + (1 - abs(nb.x)) * 120, abs(nb.y) * 60 + (1 - abs(nb.y)) * 120, abs(nb.z) * 60 + (1 - abs(nb.z)) * 120)
    cut.location = nb * (d + 30)
    cut.hide_render = True
    mods = []
    for o in bay_objs + (tool_objs if with_tool else []):
        if o.type == 'MESH' and not o.hide_render:
            m = o.modifiers.new("cut", 'BOOLEAN'); m.operation = 'DIFFERENCE'; m.object = cut; m.solver = 'FLOAT'
            mods.append((o, m))
    return cut, mods


for view in cfg["views"]:
    name, cen, d, scale = view[:4]
    cut = add_cut(*view[4]) if len(view) > 4 else None
    for o in bpy.data.objects:
        if o.type == 'MESH':
            for ms in o.data.materials:
                if ms:
                    ms.use_backface_culling = False
    cb = gl2b(cen); db = gl2b(d).normalized(); fw = -db
    up = Vector((0, 0, 1)) if abs(db.z) < 0.95 else Vector((0, 1, 0))
    r = fw.cross(up).normalized(); u = r.cross(fw)
    cam.matrix_world = Matrix.Translation(cb + db * 30) @ Matrix(((r.x, u.x, -fw.x, 0), (r.y, u.y, -fw.y, 0), (r.z, u.z, -fw.z, 0), (0, 0, 0, 1)))
    cd.ortho_scale = scale
    sc.render.filepath = os.path.join(out, f"{case}_{name}.png")
    bpy.ops.render.render(write_still=True)
    if cut:
        for o, m in cut[1]:
            o.modifiers.remove(m)
        bpy.data.objects.remove(cut[0])
print("done", out)
