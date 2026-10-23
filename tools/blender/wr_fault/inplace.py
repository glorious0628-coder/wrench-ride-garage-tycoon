# In-place check renders of the fault-look parts on the sedan (wr-3d helper 10-21): B_concept body + engine-bay decor
# + the other helpers' parts (work/scene/others.glb from tools/blender/wr_body/place_others.py) + our car-pose GLBs.
# Review-only edits of the decor (nothing is written back): the old coolant tank / brake reservoir / first piece of
# the reservoir hose are cut out of Deco_EngineBay, and the master cylinder is cut and redrawn 0.235 lower (proposal:
# the new reservoir's base sits on it). Liquids are set to a level (top Y) per state. Washer jets are drawn as thin
# blue review curves (tip -> 30 deg up -> glass target), not game meshes.
#   blender -b --factory-startup --python inplace.py -- <work_dir> <out_dir> <coolant_top> <brake_top> <views> [hood_deg] [service]
import bpy, bmesh, sys, os, math, json
from mathutils import Vector, Matrix

a = sys.argv[sys.argv.index("--") + 1:]
WD, OUT = os.path.abspath(a[0]), os.path.abspath(a[1]); os.makedirs(OUT, exist_ok=True)
CTOP, BTOP = float(a[2]), float(a[3])
VIEWS = a[4].split(",")
HOOD_DEG = float(a[5]) if len(a) > 5 else 57.8
SERVICE = len(a) > 6 and a[6] == "service"
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
SED = os.path.join(ROOT, "art", "3d", "sedan_body")
B = lambda x, Y, z: Vector((x, -z, Y))
C = lambda v: (v.x, v.z, -v.y)
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene


def imp(p):
    before = set(sc.objects); bpy.ops.import_scene.gltf(filepath=p)
    return [o for o in sc.objects if o not in before and o.type == 'MESH']


car = imp(os.path.join(SED, "B_concept", "sedan_body_all.glb")) + imp(os.path.join(SED, "decor", "sedan_decor_all.glb"))
others = imp(os.path.join(WD, "..", "scene", "others.glb"))
CUT = [((2.30, 2.94, -5.96), (3.06, 3.60, -5.10)), ((-1.78, 3.08, -4.89), (-1.32, 3.44, -4.55)), ((2.10, 2.90, -6.45), (2.47, 3.10, -5.85)),
       ((-1.70, 2.80, -4.96), (-1.40, 3.09, -4.40))]        # last = master cylinder (redrawn lower below)
for o in car:
    if o.name == "Deco_EngineBay":
        bm = bmesh.new(); bm.from_mesh(o.data); mw = o.matrix_world
        dead = [f for f in bm.faces if any(all(lo[i] <= C(mw @ f.calc_center_median())[i] <= hi[i] for i in range(3)) for lo, hi in CUT)]
        bmesh.ops.delete(bm, geom=dead, context='FACES'); bm.to_mesh(o.data); bm.free()
        mc = bpy.data.materials.new("mc"); mc.use_nodes = True
        bsdf = mc.node_tree.nodes["Principled BSDF"]; bsdf.inputs["Base Color"].default_value = (0.45, 0.45, 0.48, 1)
        bsdf.inputs["Metallic"].default_value = 0.7; bsdf.inputs["Roughness"].default_value = 0.3
        bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.12, depth=0.52, location=B(-1.55, 2.715, -4.68), rotation=(math.pi / 2, 0, 0))
        cyl = bpy.context.active_object; cyl.data.materials.append(mc); cyl.name = "MasterCyl_proposal"
mine = {}
for f in sorted(os.listdir(WD)):
    if f.endswith(".glb") and not f.startswith("local_") and "_Worn" not in f and f not in ("WasherNozzle.glb",):
        for o in imp(os.path.join(WD, f)):
            mine[o.name] = o
# liquid levels: scale in build Z about the mesh bottom (= object origin)
LIQ = {"Deco_Level_Coolant": (2.495, 2.925), "Deco_Level_Coolant_Upper": (2.925, None), "Deco_Level_BrakeFluid": (2.927, None)}
for nm, (bot, cap_) in LIQ.items():
    o = mine.get(nm)
    if o is None:
        continue
    top = CTOP if "Coolant" in nm else BTOP
    if cap_ is not None:
        top = min(top, cap_)
    zs = [(o.matrix_world @ v.co).z for v in o.data.vertices]; z0, z1 = min(zs), max(zs)
    h = top - z0
    if h <= 0.004:
        o.hide_render = True; continue
    o.scale = (1, 1, h / (z1 - z0))
# hood + nozzles open together about the hinge
H = B(0, 4.15, -3.85)
Mh = Matrix.Translation(H) @ Matrix.Rotation(math.radians(HOOD_DEG), 4, 'X') @ Matrix.Translation(-H)
for o in car + list(mine.values()):
    if o.name in ("Hood",) or o.name.startswith("Washer_Nozzle"):
        o.matrix_world = Mh @ o.matrix_world
for o in car:
    if o.name == "HoodProp" and HOOD_DEG < 1:
        o.hide_render = True
# wiper service position (passenger + driver): rotate arm + blade about the glass normal at the pivot
fitj = json.load(open(os.path.join(WD, "wiper_fit.json"), encoding="utf-8"))
if SERVICE:
    for key in ("Long", "Short"):
        f_ = fitj["fit_" + key]; piv = B(*f_["pivot"]); n = B(*f_["n_glass_normal"]).normalized()
        ang = math.radians(f_.get("service_deg", 0.0))
        Mr = Matrix.Translation(piv) @ Matrix.Rotation(ang, 4, n) @ Matrix.Translation(-piv)
        for nm in ("WiperArm_" + key, "WiperBlade_" + key):
            if nm in mine:
                mine[nm].matrix_world = Mr @ mine[nm].matrix_world
# washer jet review curves
nz = os.path.join(WD, "nozzle_fit.json")
if os.path.exists(nz) and HOOD_DEG < 1:
    J = json.load(open(nz, encoding="utf-8"))
    jm = bpy.data.materials.new("jet"); jm.use_nodes = True
    jb = jm.node_tree.nodes["Principled BSDF"]; jb.inputs["Base Color"].default_value = (0.15, 0.45, 0.95, 1)
    jb.inputs["Emission Color"].default_value = (0.15, 0.45, 0.95, 1); jb.inputs["Emission Strength"].default_value = 0.6
    for side in ("L", "R"):
        e = J["Washer_Nozzle_" + side]; p0 = B(*e["jet_tip"]); d = B(*e["jet_dir"]).normalized(); tg = B(*e["glass_target"])
        # parabola through p0 with start direction d that lands on tg: horizontal distance s, speed from s / angle
        flat0 = Vector((tg.x - p0.x, tg.y - p0.y, 0)); s = flat0.length; th = math.asin(d.z)
        dz = tg.z - p0.z; g = 2 * (s * math.tan(th) - dz) / (s * s) if s > 0 else 0
        for k_, az in enumerate((-e.get("fan_width_deg", 0) / 2, 0.0, e.get("fan_width_deg", 0) / 2)):
            flat = Matrix.Rotation(math.radians(az), 3, 'Z') @ flat0
            pts = [p0 + flat * (k / 24) + Vector((0, 0, (s * k / 24) * math.tan(th) - 0.5 * g * (s * k / 24) ** 2)) for k in range(25)]
            cu = bpy.data.curves.new("jet", 'CURVE'); cu.dimensions = '3D'; cu.bevel_depth = 0.008 if k_ != 1 else 0.012
            sp = cu.splines.new('POLY'); sp.points.add(len(pts) - 1)
            for i, p in enumerate(pts):
                sp.points[i].co = (p.x, p.y, p.z, 1)
            ob = bpy.data.objects.new("jet_" + side, cu); sc.collection.objects.link(ob); cu.materials.append(jm)
# ------------------------------------------------------------------ lights / camera
sc.view_settings.view_transform = "Standard"
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = sc.world.node_tree.nodes["Background"]; bg.inputs[0].default_value = (0.80, 0.82, 0.86, 1); bg.inputs[1].default_value = 0.45
try:
    sc.eevee.taa_render_samples = 48
except Exception:
    pass


def light(name, energy, loc, size=8):
    ld = bpy.data.lights.new(name, "AREA"); ld.energy = energy; ld.size = size
    ob = bpy.data.objects.new(name, ld); sc.collection.objects.link(ob)
    ob.location = Vector(loc); ob.rotation_euler = (-(Vector(loc) - B(0, 3, -5))).to_track_quat("-Z", "Y").to_euler()


light("key", 2600, B(4, 16, -14)); light("fill", 900, B(-9, 10, -6)); light("top", 1200, B(0, 18, -4), 12)
sun = bpy.data.lights.new("sun", "SUN"); sun.energy = 0.9; so = bpy.data.objects.new("sun", sun); sc.collection.objects.link(so)
so.rotation_euler = (math.radians(35), math.radians(10), math.radians(200))
cd = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
cd.clip_start = 0.05; cd.clip_end = 200
# name: (camera position car coords, look-at car coords, lens mm, resolution)
CAMS = {"workcam": ((0.0, 9.0, -11.6), (0.0, 2.9, -5.6), 30, (1600, 1000)),
        "coolant_close": ((1.2, 5.4, -8.3), (2.45, 3.0, -5.9), 55, (1200, 1000)),
        "coolant_front": ((2.4, 4.4, -8.6), (2.49, 3.0, -5.9), 70, (1000, 1000)),
        "brake_close": ((-1.0, 5.4, -7.4), (-1.55, 3.1, -4.75), 60, (1200, 1000)),
        "cowl_front": ((0.0, 7.6, -9.5), (-0.1, 4.25, -3.75), 34, (1600, 900)),
        "cowl_3q": ((-4.6, 6.4, -6.6), (-0.6, 4.2, -3.8), 30, (1600, 1000)),
        "cowl_driver": ((-2.0, 5.6, -6.4), (-1.6, 4.2, -3.75), 45, (1400, 900)),
        "cowl_mid": ((0.6, 5.0, -5.8), (0.4, 4.2, -3.75), 45, (1400, 900)),
        "nozzle_close": ((1.5, 4.85, -5.3), (1.1, 4.2, -4.25), 60, (1200, 900))}
sc.render.engine = "BLENDER_EEVEE"
for v in VIEWS:
    pos, tgt, lens, res = CAMS[v]
    p, t = B(*pos), B(*tgt)
    cam.location = p; cam.rotation_euler = (t - p).to_track_quat("-Z", "Y").to_euler(); cd.lens = lens
    sc.render.resolution_x, sc.render.resolution_y = res
    sc.render.filepath = os.path.join(OUT, v + ".png"); bpy.ops.render.render(write_still=True)
print("done", OUT)
