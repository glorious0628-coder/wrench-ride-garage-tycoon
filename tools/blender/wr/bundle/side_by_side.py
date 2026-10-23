# Our customer sedan (B_concept GLBs + Detail wheels) next to bought-bundle cars, at a near and a far distance.
#   blender --background --factory-startup --python side_by_side.py -- <setup.json> <out_dir>
# setup.json: {"packs": {"cf": [{"label":..,"path":..,"length":17}, ...3], "c2": [...]}, "paint": "#098FFC"}
# Writes <out>/<pack>_<view>.png for view in lot_near, curb_near, lot_far, curb_far and <out>/measure.json.
# Camera = Roblox-like: vertical FOV 70 deg, eye height 5 stud. Near = 17-20 stud, far = 100 (lot) / 80 (curb).
import bpy, sys, os, json, math
from mathutils import Vector, Matrix
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bundle_lib as B  # noqa: E402

argv = sys.argv[sys.argv.index("--") + 1:]
setup = json.load(open(argv[0], encoding="utf-8")); out = os.path.abspath(argv[1]); os.makedirs(out, exist_ok=True)
PAINT = setup.get("paint", "#098FFC")
RESX, RESY = setup.get("res", [1920, 1080])


def scene_base():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_EEVEE"; sc.view_settings.view_transform = "Standard"
    sc.render.resolution_x, sc.render.resolution_y = RESX, RESY
    w = bpy.data.worlds.new("w"); w.use_nodes = True; sc.world = w
    bg = w.node_tree.nodes["Background"]; bg.inputs[0].default_value = (0.62, 0.74, 0.92, 1); bg.inputs[1].default_value = 0.85
    sd = bpy.data.lights.new("sun", "SUN"); sd.energy = 3.4; sd.angle = math.radians(6)
    so = bpy.data.objects.new("sun", sd); sc.collection.objects.link(so)
    so.rotation_euler = (math.radians(48), 0, math.radians(-150))
    # asphalt + lighter concrete strip (sidewalk / lot edge)
    for nm, size, loc, col in (("asphalt", 600, (0, 0, 0), (0.16, 0.16, 0.17)),):
        bpy.ops.mesh.primitive_plane_add(size=size, location=loc); g = bpy.context.active_object; g.name = nm
        m = bpy.data.materials.new(nm); m.use_nodes = True
        b = m.node_tree.nodes["Principled BSDF"]; b.inputs["Base Color"].default_value = (*col, 1); b.inputs["Roughness"].default_value = 0.95
        g.data.materials.append(m)
    cd = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
    cd.sensor_fit = 'VERTICAL'; cd.angle_y = math.radians(70); cd.clip_end = 2000; cd.clip_start = 0.1
    return sc, cam


def strip(x0, x1, y0, y1, col=(0.55, 0.55, 0.53), z=0.02, name="strip"):
    bpy.ops.mesh.primitive_plane_add(size=1, location=((x0 + x1) / 2, (y0 + y1) / 2, z))
    g = bpy.context.active_object; g.name = name; g.scale = (x1 - x0, y1 - y0, 1)
    m = bpy.data.materials.new(name); m.use_nodes = True
    m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (*col, 1)
    g.data.materials.append(m)


def look(cam, pos, target):
    pos = Vector(pos); f = (Vector(target) - pos).normalized(); r = f.cross(Vector((0, 0, 1))).normalized(); u = r.cross(f)
    cam.matrix_world = Matrix(((r.x, u.x, -f.x, pos.x), (r.y, u.y, -f.y, pos.y), (r.z, u.z, -f.z, pos.z), (0, 0, 0, 1)))


def render(sc, path):
    sc.render.filepath = path; bpy.ops.render.render(write_still=True)


def put(c, loc=(0, 0, 0), rot_z=0.0):
    if c.get("as_is"):
        E, meshes, info = B.place_bundle_car(c["path"], c["label"], scale=1.0, loc=loc, rot_z=rot_z, keep_origin=True)
    else:
        E, meshes, info = B.place_bundle_car(c["path"], c["label"], length=c["length"], loc=loc, rot_z=rot_z)
    return E, meshes, info


def stall_lines(xs, rz, length=18.0):
    for x in xs:
        bpy.ops.mesh.primitive_plane_add(size=1, location=(x, 0, 0.015))
        g = bpy.context.active_object; g.scale = (0.25, length, 1); g.rotation_euler = (0, 0, rz)
        m = bpy.data.materials.get("line") or bpy.data.materials.new("line"); m.use_nodes = True
        m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.85, 0.85, 0.82, 1)
        g.data.materials.append(m)


measures = {}
for pack, cars in setup["packs"].items():
    # ---------- measure each car alone (rot 0) ----------
    for c in cars:
        scene_base()
        E, meshes, info = put(c)
        m = B.measure_car(meshes, B.bundle_glass_pred) if not c.get("as_is") else {}
        lo, hi = B.bbox(meshes); m.update({"L": round(hi.y - lo.y, 3), "W": round(hi.x - lo.x, 3), "H": round(hi.z - lo.z, 3)})
        m.update(info); m["tris"] = B.tri_count(meshes)
        measures[c["label"]] = m
    if "OurSedan" not in measures:
        scene_base()
        E, meshes = B.place_our_sedan(paint=PAINT)
        m = B.measure_car(meshes, B.sedan_glass_pred, B.sedan_wheel_pred); m["tris"] = B.tri_count(meshes)
        measures["OurSedan"] = m
    # ---------- lot: 4 cars angled, ours in the middle-right ----------
    sc, cam = scene_base()
    rz = math.radians(-32)
    order = [cars[2], cars[1], "ours", cars[0]]
    xs = [-24.0, -12.0, 0.0, 12.0]
    stall_lines([x + 6.0 for x in xs[:-1]] + [xs[0] - 6.0, xs[-1] + 6.0], rz)
    for x, c in zip(xs, order):
        if c == "ours":
            B.place_our_sedan(loc=(x, 0, 0), rot_z=rz, paint=PAINT)
        else:
            put(c, loc=(x, 0, 0), rot_z=rz)
    look(cam, (-6.0, 20.0, 5.0), (-6.0, 0, 2.6)); render(sc, os.path.join(out, "%s_lot_near.png" % pack))
    look(cam, (-6.0, 100.0, 5.0), (-6.0, 0, 2.6)); render(sc, os.path.join(out, "%s_lot_far.png" % pack))
    for dist in setup.get("ladder", []):       # distance ladder: from how far does the style gap stop showing?
        look(cam, (-6.0, float(dist), 5.0), (-6.0, 0, 2.6)); render(sc, os.path.join(out, "%s_lot_d%03d.png" % (pack, dist)))
    # ---------- curb: 3 cars end to end, walk past on the sidewalk ----------
    sc, cam = scene_base()
    strip(-12, -5.0, -80, 80, name="sidewalk")
    lens = [measures[cars[0]["label"]]["L"], 17.0, measures[cars[1]["label"]]["L"]]
    ys = [lens[0] / 2 + 1.5 + 8.5, 0.0, -(8.5 + 1.5 + lens[2] / 2)]
    put(cars[0], loc=(0, ys[0], 0))
    B.place_our_sedan(loc=(0, 0, 0), paint=PAINT)
    put(cars[1], loc=(0, ys[2], 0))
    look(cam, (-16.0, 4.0, 5.0), (0, 0, 2.6)); render(sc, os.path.join(out, "%s_curb_near.png" % pack))
    look(cam, (-80.0, 10.0, 5.0), (0, 0, 2.6)); render(sc, os.path.join(out, "%s_curb_far.png" % pack))
json.dump(measures, open(os.path.join(out, "measure.json"), "w", encoding="utf-8"), indent=1)
print("MEASURE", json.dumps(measures))
