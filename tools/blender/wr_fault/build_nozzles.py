# Hood washer nozzles x2 for WASHER_EMPTY (wr-3d helper 10-21), fault_looks v0.3 §5b, concept
# art/concepts/workview/washer_nozzle_6view.png. Small black bump 0.20 x 0.11 x 0.25 (x, up, length): shield-shaped
# from above (wide back, round nose at the front), tall steep back with the jet hole facing the windshield, flange,
# 2 snap clips + barbed hose stem under the base (they sit inside the hood skin, 0.085 thick). Origin = base centre
# on the hood top. Built upright (local), then placed on the sedan Hood mesh at (+-1.1, z -4.3), tilted to the hood
# normal. Attachments: base, jet tip, jet direction (30 deg up, aimed at the windshield spot), glass target.
#   blender -b --factory-startup --python build_nozzles.py -- <out_dir> [palette.json]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fault_common import *  # noqa
from mathutils.bvhtree import BVHTree

argv = sys.argv[sys.argv.index("--") + 1:]
OUT = os.path.abspath(argv[0]); os.makedirs(OUT, exist_ok=True)
PAL = json.load(open(argv[1], encoding="utf-8")) if len(argv) > 1 and argv[1] else {}
C_ = lambda k, d: PAL.get(k, d)

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=os.path.join(SEDAN, "B_concept", "sedan_body_all.glb"))
TREES = {}
for o in bpy.context.scene.objects:
    if o.type == 'MESH' and o.name in ("Glass", "Hood"):
        bm = bmesh.new(); bm.from_mesh(o.data); bm.transform(o.matrix_world); TREES[o.name] = BVHTree.FromBMesh(bm)


def hit(name, x, yb, e=0.02):
    D = Vector((0, 0, -1))
    p = TREES[name].ray_cast(Vector((x, yb, 9.0)), D, 20)[0]
    ps = [TREES[name].ray_cast(Vector((x + dx, yb + dy, 9.0)), D, 20)[0] for dx, dy in ((-e, 0), (e, 0), (0, -e), (0, e))]
    n = (ps[1] - ps[0]).cross(ps[3] - ps[2]).normalized()
    return p, (n if n.z > 0 else -n)


L_, HB, FL = 0.25, 0.10, 0.02           # length, dome height above the flange, flange thickness
JET_UP = 30.0
NZ, SINK, FAN = 4.20, 0.035, 25.0   # car z -4.20: just in front of the hood's rear edge (z -4.06), carbook #6; fan spray 25 deg


def halfw(y):
    """top-view half width: wide back (0.10), straight sides to a round nose at the front"""
    t = (y + L_ / 2) / L_                 # 0 back .. 1 front
    w = 0.100 * (1 - 0.40 * t)
    if t > 0.80:                          # round nose
        w *= math.sqrt(max(0.0, 1 - ((t - 0.80) / 0.20) ** 2))
    if t < 0.06:                          # rounded back corners
        w *= 0.55 + 0.45 * math.sqrt(max(0.0, 1 - ((0.06 - t) / 0.06) ** 2))
    return w


def height(y):
    t = (y + L_ / 2) / L_
    if t < 0.14:                          # steep, rounded back face
        return HB * math.sqrt(max(0.0, 1 - ((0.14 - t) / 0.14) ** 2))
    h = HB * (1 - 0.74 * ((t - 0.14) / 0.86) ** 1.5)
    if t > 0.86:
        h *= math.sqrt(max(0.0, 1 - ((t - 0.86) / 0.14) ** 2)) * 0.6 + 0.4 * (1 - (t - 0.86) / 0.14)
    return h


def dome(mat):
    n_y, n_a, p, taper = 16, 10, 3.6, 0.24
    ys = [-L_ / 2 + L_ * (0.5 - 0.5 * math.cos(math.pi * i / n_y)) for i in range(n_y + 1)]   # denser at both ends
    ys = [min(max(y, -L_ / 2 + 0.0015), L_ / 2 - 0.0015) for y in ys]
    rings = []
    for y in ys:
        w, h = max(halfw(y), 0.002), max(height(y), 0.002)
        ring = []
        for j in range(n_a + 1):
            th = math.pi * j / n_a; c, s_ = math.cos(th), math.sin(th)
            sz = abs(s_) ** (2 / p)
            ring.append(Vector((math.copysign(abs(c) ** (2 / p), c) * w * (1 - taper * sz), y, FL - 0.004 + sz * h)))
        rings.append(ring)
    bm = bmesh.new(); vr = [[bm.verts.new(v) for v in r] for r in rings]
    for a, b in zip(vr[:-1], vr[1:]):
        for j in range(n_a):
            bm.faces.new((a[j], a[j + 1], b[j + 1], b[j]))
        bm.faces.new((a[n_a], a[0], b[0], b[n_a]))          # flat bottom strip
    for r in (vr[0], vr[-1]):
        bm.faces.new(r)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    ob = P._new("dome", bm); ob.data.materials.append(mat)
    return ob


def outline_pts():
    ys = [-L_ / 2 + L_ * (0.5 - 0.5 * math.cos(math.pi * i / 16)) for i in range(17)]
    right = [(halfw(y), y) for y in ys]
    left = [(-halfw(y), y) for y in reversed(ys)]
    pts = right + left
    out = []
    for q in pts:
        if not out or (Vector(q) - Vector(out[-1])).length > 1e-4:
            out.append(q)
    return out[::-1] if sum((out[i][0] * out[(i + 1) % len(out)][1] - out[(i + 1) % len(out)][0] * out[i][1]) for i in range(len(out))) < 0 else out


P.reset()
blk = P.mat("nozzle", C_("nozzle", "#363738"), 0.62, 0.0)
hole = P.mat("hole", "#0B0B0B", 0.8, 0.0)
XY = W.frame((0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1))
parts = [dome(blk)]
parts.append(W.outline_slab("flange", W.offset_outline(outline_pts(), 0.011), 0.0, FL, 0.005, 2, XY, material=blk, rad_back=0.0, n_back=1,
                            support=False, cap='fan'))
# jet boss on the steep back face: find the surface point along the jet line
d_jet = Vector((0, -math.cos(math.radians(JET_UP)), math.sin(math.radians(JET_UP))))
bm = bmesh.new(); bm.from_mesh(parts[0].data); tr = BVHTree.FromBMesh(bm)
zj = FL + 0.052
hitp = tr.ray_cast(Vector((0, -0.5, zj)) , Vector((0, 1, 0)), 2)[0]
nrm = tr.find_nearest(hitp)[1]
jet_c = hitp
ax = (d_jet + nrm).normalized()          # boss axis between the face normal and the jet
rot = ax.to_track_quat('Z', 'Y').to_matrix().to_4x4()
boss = W.revolve_x("boss", [(0, -0.006), (0.017, -0.006), (0.017, 0.004), (0.013, 0.0075), (0.0075, 0.0075), (0.0075, 0.003), (0, 0.003)], 16,
                   closed=False, material=blk, axis='Z')
boss.data.transform(rot); boss.data.transform(Matrix.Translation(jet_c))
parts.append(boss)
TIP = jet_c + ax * 0.003
# under the base: barbed stem (slightly behind the middle) + 2 snap clips
parts.append(W.revolve_x("stem", [(0, 0.002), (0.024, 0.002), (0.024, -0.03), (0.029, -0.034), (0.021, -0.048), (0.027, -0.052), (0.019, -0.068),
                                  (0, -0.068)], 12, closed=False, material=blk, center=(0, -0.02, 0), axis='Z'))
for s in (-1, 1):
    parts.append(P.rounded_box("clip", (0.012, 0.045, 0.05), (s * 0.058, 0.03, -0.024), 0.004, segs=1, material=blk))
    parts.append(P.rounded_box("lip", (0.016, 0.045, 0.012), (s * 0.066, 0.03, -0.044), 0.004, segs=1, material=blk))
ob = W.join("WasherNozzle", parts); ob.data.name = "WasherNozzle"


def paint(Pm, Nm, base, orm, mask):
    import numpy as np
    rel = Pm - np.array(TIP, np.float32)
    along = rel @ np.array(ax, np.float32)
    rad = np.linalg.norm(rel - along[..., None] * np.array(ax, np.float32), axis=-1)
    m = mask & (rad < 0.0075) & (np.abs(along) < 0.008)
    base[m] = np.array(hexf("#0A0A0A"), np.float32)
    return base, orm


P.finish(ob, os.path.join(OUT, "WasherNozzle"), tex=512, smooth_angle=50, weighted=False, pivot_bottom=False, paint=paint, cull_hidden=True)
export_one(ob, os.path.join(OUT, "local_WasherNozzle.glb"))
INFO = {"WasherNozzle_local": mesh_info(ob), "local_jet_tip": [round(v, 4) for v in R(TIP)], "local_jet_dir": Rdir(d_jet)}
mesh0 = ob.data.copy()
# ---------------------------------------------------------------- place on the hood (closed), L = driver (-x)
glass = TREES["Glass"]
placed = {}
for side, sx in (("L", -1.1), ("R", 1.1)):
    top_p, n_h = hit("Hood", sx, NZ)
    base_p = top_p - n_h * SINK                               # half sunk into the hood's rear edge (carbook #6)
    yv = Vector((0, 1, 0)); yv = (yv - n_h * n_h.dot(yv)).normalized(); xv = yv.cross(n_h).normalized()
    Rm = Matrix((xv, yv, n_h)).transposed()
    gt, _ = hit("Glass", sx * 0.91, 3.0)                     # spray spot on the windshield (car z -3.0)
    tip_w = base_p + Rm @ TIP
    flat = Vector((gt.x - tip_w.x, gt.y - tip_w.y, 0)).normalized()
    jet_w = (flat * math.cos(math.radians(JET_UP)) + Vector((0, 0, math.sin(math.radians(JET_UP))))).normalized()
    o2 = bpy.data.objects.new("Washer_Nozzle_" + side, mesh0.copy()); bpy.context.scene.collection.objects.link(o2)
    o2.data.name = o2.name
    o2.data.transform(Rm.to_4x4()); o2.location = base_p
    export_one(o2, os.path.join(OUT, o2.name + ".glb"))
    INFO[o2.name] = mesh_info(o2)
    INFO[o2.name].update({"base_on_hood": R(base_p), "hood_normal": Rdir(n_h), "jet_tip": R(tip_w), "jet_dir": Rdir(jet_w),
                          "glass_target": R(gt), "fan_width_deg": FAN, "sink_into_hood": SINK, "hood_top": R(top_p), "tilt_deg": round(math.degrees(math.acos(max(-1, min(1, n_h.z)))), 2)})
json.dump(INFO, open(os.path.join(OUT, "nozzle_fit.json"), "w", encoding="utf-8"), indent=1)
print("NOZZLE", json.dumps(INFO, indent=0)[:1500])
