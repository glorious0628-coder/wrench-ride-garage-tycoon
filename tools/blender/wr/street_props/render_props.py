# Check renders for the street props (wr-3d, 10-21). Blender frame: +Z up, +Y = GLB front (-Z).
#   blender --background --factory-startup --python render_props.py -- each   <out_dir> <glb> [<glb> ...]
#   blender --background --factory-startup --python render_props.py -- before <out_dir> <props_config.json> <_src dir> <name> [...]
#   blender --background --factory-startup --python render_props.py -- lineup <out.png> <glb> [<glb> ...]
# each   : per GLB a 3/4 front view (q34) + front + side, ortho, own framing -> <name>_<view>.png
# before : the pack model with the same scale / turn / origin as export_props.py (pack material) -> <name>_src_<view>.png
# lineup : all GLBs side by side on a 1-stud grid with an R15-size box (2 x 5 x 1 stud) -> front ortho + 3/4 perspective
import bpy, sys, os, json, math
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
mode = argv[0]
VIEWS = {"q34": (-0.75, 1.0, 0.62), "front": (0.0, 1.0, 0.12), "side": (1.0, 0.0, 0.12), "back34": (0.8, -1.0, 0.5)}


def scene(res=(600, 600)):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_EEVEE"; sc.view_settings.view_transform = "Standard"
    sc.render.resolution_x, sc.render.resolution_y = res
    sc.render.film_transparent = False
    w = bpy.data.worlds.new("w"); w.use_nodes = True; sc.world = w
    bg = w.node_tree.nodes["Background"]; bg.inputs[0].default_value = (0.80, 0.83, 0.88, 1); bg.inputs[1].default_value = 0.9
    sd = bpy.data.lights.new("sun", "SUN"); sd.energy = 3.2; sd.angle = math.radians(8)
    so = bpy.data.objects.new("sun", sd); sc.collection.objects.link(so)
    so.rotation_euler = (math.radians(50), 0, math.radians(-150))     # light from front-left-above
    cd = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
    cd.clip_end = 5000; cd.clip_start = 0.01
    return sc, cam


def import_glb(p):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.abspath(p))
    return [o for o in bpy.data.objects if o not in before and o.type == "MESH"]


def bbox(objs):
    pts = [o.matrix_world @ v.co for o in objs for v in o.data.vertices]
    return (Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts))),
            Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts))))


def ortho_shot(sc, cam, objs, d, path, fill=1.25):
    lo, hi = bbox(objs); cen = (lo + hi) / 2; size = (hi - lo).length
    d = Vector(d).normalized()
    cam.data.type = "ORTHO"; cam.data.ortho_scale = size * fill * 0.85
    cam.location = cen + d * (size * 4 + 2)
    cam.rotation_euler = (-d).to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = path; bpy.ops.render.render(write_still=True)


def tris(objs):
    return sum(len(p.vertices) - 2 for o in objs for p in o.data.polygons)


if mode == "each":
    out = os.path.abspath(argv[1]); os.makedirs(out, exist_ok=True); info = {}
    for g in argv[2:]:
        sc, cam = scene()
        objs = import_glb(g); n = os.path.basename(g)[:-4]
        for vn in ("q34", "front", "side", "back34"):
            ortho_shot(sc, cam, objs, VIEWS[vn], os.path.join(out, n + "_" + vn + ".png"))
        lo, hi = bbox(objs)
        info[n] = {"height": round(hi.z - lo.z, 3), "size_xyz_glb": [round(hi.x - lo.x, 3), round(hi.z - lo.z, 3), round(hi.y - lo.y, 3)], "tris": tris(objs)}
    json.dump(info, open(os.path.join(out, "info.json"), "w"), indent=1)

elif mode == "before":
    out = os.path.abspath(argv[1]); os.makedirs(out, exist_ok=True)
    cfg = json.load(open(argv[2], encoding="utf-8")); src = os.path.abspath(argv[3]); S = 1.0 / cfg["metres_per_stud"]
    for name in argv[4:]:
        P = next(p for p in cfg["props"] if p["name"] == name)
        sc, cam = scene()
        objs = import_glb(os.path.join(src, "x", "x", P["src"]))
        for o in objs:
            o.data.transform(o.matrix_world); o.matrix_world = Matrix.Identity(4)
            o.data.transform(Matrix.Rotation(math.radians(P["rot_z_deg"]), 4, "Z") @ Matrix.Scale(S, 4))
        lo, hi = bbox(objs)
        if P.get("origin") == "stair_bottom":
            foot = [o.matrix_world @ v.co for o in objs for v in o.data.vertices if (o.matrix_world @ v.co).z < lo.z + 0.02]
            org = Vector(((lo.x + hi.x) / 2, (min(c.y for c in foot) + max(c.y for c in foot)) / 2, lo.z))
        else:
            org = Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
        for o in objs:
            o.data.transform(Matrix.Translation(-org))
        for vn in ("q34", "front", "side", "back34"):
            ortho_shot(sc, cam, objs, VIEWS[vn], os.path.join(out, name + "_src_" + vn + ".png"))

elif mode == "lineup":
    # R15 box on the image left, props to its right (camera looks along -Y, so image right = world -X)
    outp = os.path.abspath(argv[1]); os.makedirs(os.path.dirname(outp), exist_ok=True)
    sc, cam = scene((2400, 1000))
    gap = 1.0; placed = []

    def mat(name, rgb):
        m = bpy.data.materials.new(name); m.use_nodes = True
        m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (*rgb, 1)
        m.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.9
        return m
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-1.0, 0, 2.5)); bx = bpy.context.active_object; bx.scale = (2, 1, 5)
    bpy.ops.object.transform_apply(scale=True); bx.data.materials.append(mat("r15", (0.80, 0.52, 0.30)))
    placed.append({"name": "R15 (box 2 x 5 x 1)", "cx": -1.0, "h": 5.0})
    x = 2.0 + gap
    for g in argv[2:]:
        objs = import_glb(g)
        lo, hi = bbox(objs)
        for o in objs:
            o.location.x += -x - hi.x              # its max x at -x
        placed.append({"name": os.path.basename(g)[:-4], "cx": -x - (hi.x - lo.x) / 2, "h": hi.z - lo.z})
        x += (hi.x - lo.x) + gap
    cx = -x / 2 + 0.5
    bpy.ops.mesh.primitive_plane_add(size=1, location=(cx, 0, -0.002)); gp = bpy.context.active_object; gp.scale = (x + 6, 16, 1)
    gp.data.materials.append(mat("ground", (0.30, 0.31, 0.33)))
    lm = mat("line", (0.08, 0.08, 0.10))
    for k in range(int(x) + 5):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(1 - k, 0, 0.0)); ln = bpy.context.active_object; ln.scale = (0.02, 16, 0.004)
        ln.data.materials.append(lm)
    # wall behind: a line every stud, thick at 5 and 10
    bpy.ops.mesh.primitive_plane_add(size=1, location=(cx, -5.0, 7.0), rotation=(math.radians(90), 0, 0)); wl = bpy.context.active_object
    wl.scale = (x + 6, 14, 1); wl.data.materials.append(mat("wall", (0.40, 0.42, 0.46)))
    for h in range(1, 14):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(cx, -4.98, h)); ln = bpy.context.active_object
        ln.scale = (x + 6, 0.01, 0.03 if h % 5 else 0.09); ln.data.materials.append(lm)
    cam.data.type = "ORTHO"; cam.data.ortho_scale = x + 2; cam_z = 6.0
    cam.location = (cx, 60, cam_z); cam.rotation_euler = (math.radians(90), 0, math.radians(180))
    sc.render.filepath = outp; bpy.ops.render.render(write_still=True)
    # perspective like a player: eye 5 stud, vertical FOV 70, looking at the small props from the front-left
    cam.data.type = "PERSP"; cam.data.sensor_fit = "VERTICAL"; cam.data.angle_y = math.radians(70)
    tgt = Vector((-9.0, 0, 1.6)); pos = Vector((-3.0, 13.0, 5.0))
    f = (tgt - pos).normalized(); r = f.cross(Vector((0, 0, 1))).normalized(); u = r.cross(f)
    cam.matrix_world = Matrix(((r.x, u.x, -f.x, pos.x), (r.y, u.y, -f.y, pos.y), (r.z, u.z, -f.z, pos.z), (0, 0, 0, 1)))
    sc.render.filepath = outp[:-4] + "_persp.png"; bpy.ops.render.render(write_still=True)
    json.dump({"placed": placed, "cam_x": cx, "cam_z": cam_z, "ortho_scale": x + 2, "res": [2400, 1000], "image_right_is": "-X"},
              open(outp[:-4] + ".json", "w"), indent=1)
