# Wheel Detail / Lite (wr-3d 10-21, main decision notes/gpt/main/wheel_brake_3d_main_decision.md):
#   Detail (bay cars, all four corners): Tire ~1,800, Rim ~2,100 - visible outer rings 64 segments, hidden inner rings
#   fewer; Lite (every other car): same silhouette, corner (wheel + brake) <= 2,100.
# Same shape as build_wheel.py v6 (approved), changes: lug circle 0.28 -> 0.24, tread grooves painted (repeated grooves
# were the biggest cost), shoulder lugs shorter / softer (looked like saw teeth from the side), rim = open shell where the
# tire hides the barrel (the outer barrel under the tire is not built), face plate with only a front chamfer.
#   blender --background --factory-startup --python build_wheel_lod.py -- <out_dir> <detail|lite> [palette.json] [scale]
# Everything is built at the 2.4-stud size, then scaled uniformly about the wheel centre by `scale` (2.75/2.4 = 1.1458).
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wr_lib as W
from wr_lib import P
from mathutils import Vector, Matrix
import numpy as np

argv = sys.argv[sys.argv.index("--") + 1:]
OUT = os.path.abspath(argv[0]); os.makedirs(OUT, exist_ok=True)
LOD = argv[1]
PAL = json.load(open(argv[2], encoding="utf-8")) if len(argv) > 2 and argv[2] else {}
# main 10-21 (notes/gpt/main/sedan_body_grey_main_decision.md): whole corner x 2.75 / 2.4 (tire d 2.75, wheel centre Y 1.375)
K = float(argv[3]) if len(argv) > 3 else 1.0
SUF = "" if LOD == "detail" else "_Lite"
DET = LOD == "detail"


def C(name, default):
    return PAL.get(name, default)


MOUNT_X, HUB_X = 0.185, 0.280
BOLT_R = 0.24            # main / GPT 10-21 (was 0.28; clicking uses a bigger hit box in code)
HOLE_R = 0.058
SPOKES = [0, 72, 144, 216, 288]
HW, RIN, ROUT = 0.135, 0.37, 0.665   # window ends 0.015 in front of the barrel (0.685 z-fought with it)
VALVE_CLOCK = 171


def rise(r):
    t = min(max((r - 0.36) / 0.35, 0), 1)
    return 0.106 * t * t * (3 - 2 * t)


def build_rim():
    P.reset()
    silver = P.mat("rim_silver", C("rim_silver", "#C3C2C2"), 0.30, 0.60)
    inner = P.mat("rim_inner", C("rim_inner", "#6B6B6C"), 0.50, 0.45)
    mount = P.mat("rim_mount", C("rim_mount", "#9D9C9B"), 0.40, 0.70)
    capm = P.mat("rim_cap", C("rim_cap", "#C1C0C0"), 0.30, 0.65)
    vrub = P.mat("valve_rubber", C("valve_rubber", "#212121"), 0.75, 0.0)
    vcap = P.mat("valve_cap", C("valve_cap", "#9C9C9C"), 0.35, 0.9)
    parts = []
    if DET:
        # open shell from the flange's outer edge round to the back flange's outer edge: the strips behind the tire
        # sidewalls and the barrel under the tire are hidden by the tire and not built
        lip = [(0.847, 0.390), (0.835, 0.411), (0.790, 0.415), (0.758, 0.400), (0.688, 0.345),
               (0.680, 0.300), (0.680, -0.330), (0.720, -0.388), (0.800, -0.414), (0.842, -0.398)]
        segs = [64] * 5 + [32] * 5
    else:
        lip = [(0.846, 0.392), (0.800, 0.415), (0.730, 0.392), (0.680, 0.310),
               (0.680, -0.330), (0.800, -0.412), (0.845, -0.390)]
        segs = [36] * 4 + [18] * 3
    lipo = W.revolve_x_var("lip", lip, segs, material=silver, closed=False, recalc=False)
    # open shell: the flange front faces must look out (+X)
    W.orient_by(lipo, lambda c, n: (1 if n.x > 0 else -1) if (c.x > 0.40 and math.hypot(c.y, c.z) > 0.76) else 0)
    P.nocull(lipo)   # partly buried in the face plate: the cull left jagged gaps seen through the windows
    parts.append(lipo)
    # face plate (hub + spokes in one piece): windows, lug holes (Detail), bent into the concave dish
    nf, nl, ni, no = (4, 3, 2, 5) if DET else (2, 2, 2, 3)
    holes = [W.fillet_window(th, th + 72, HW, RIN, ROUT, 0.035, 0.04, n_fil=nf, n_line=nl, n_in=ni, n_out=no) for th in SPOKES]
    outer = W.circle_pts(0, 0, 0.705, 24 if DET else 15)
    hc = [True] * 5
    if DET:   # lug holes: plain 16-sided (12 read as polygons at 2x), no chamfer (the nuts sit on them)
        for th in SPOKES:
            d = W.clock_dir(th) * BOLT_R
            holes.append(W.circle_pts(d.y, d.z, HOLE_R, 16)); hc.append(False)
    face = W.plate2d("face", outer, holes, MOUNT_X, HUB_X, 0.008 if DET else 0.0, material=silver, outer_chamfer=False,
                     front_ds=0.10 if DET else None, back_ds=0.20 if DET else None, rmax=0.70, hole_chamfer=hc)
    for v in face.data.vertices:
        v.co.x += rise(math.hypot(v.co.y, v.co.z))
    W.mark_sharp(face, 30)
    P.nocull(face)   # long cap triangles partly inside the lip were culled -> gaps
    parts.append(face)
    cap_prof = [(0, 0.317), (0.07, 0.310), (0.104, 0.290), (0.110, 0.262), (0, 0.262)]
    parts.append(W.revolve_x("cap", cap_prof if DET else [(0, 0.312), (0.09, 0.300), (0.11, 0.27), (0, 0.262)],
                             16 if DET else 10, material=capm, closed=False))
    if DET:
        u = W.clock_dir(VALVE_CLOCK); a = Vector((1, 0, 0)); d = (u * 0.42 + a * 0.91).normalized()
        p0 = a * 0.335 + u * 0.688
        parts.append(W.tube("valve", [p0, p0 + d * 0.075], [0.025, 0.020], around=8, material=vrub))
        parts.append(W.tube("valve_cap", [p0 + d * 0.072, p0 + d * 0.105], 0.017, around=8, material=vcap))
    ob = W.join("Rim" + SUF, parts)

    def paint_side(cen, nrm):
        r = math.hypot(cen.y, cen.z)
        radial = (cen.y * nrm.y + cen.z * nrm.z) / max(r, 1e-6)
        if r < 0.36 and nrm.x < -0.9 and cen.x < MOUNT_X + 0.01:
            return mount
        if r < 0.70 and nrm.x < -0.3:
            return inner
        if 0.672 < r < 0.73 and radial < -0.6 and cen.x < 0.33:   # barrel only (window ends at r 0.665 stay silver)
            return inner
        return None
    P.assign_by(ob, paint_side)
    return ob


def rim_paint(Pm, Nm, base, orm, mask):
    """Lite: lug nut seats painted (no holes)"""
    if DET:
        return base, orm
    k = np.zeros(mask.shape, np.float32)
    for th in SPOKES:
        cy, cz = BOLT_R * math.sin(math.radians(th)), BOLT_R * math.cos(math.radians(th))
        dd = np.sqrt((Pm[..., 1] - cy) ** 2 + (Pm[..., 2] - cz) ** 2)
        k = np.maximum(k, np.clip((HOLE_R - dd) / 0.006 + 0.5, 0, 1))
    k *= mask & (Nm[..., 0] > 0.8)
    base = base * (1 - k[..., None]) + np.array([0.33, 0.33, 0.34], np.float32) * k[..., None]   # mid-dark: close to Detail's holes (disc behind)
    return base, orm


def build_tire():
    P.reset()
    rub = P.mat("tire", C("tire", "#343536"), 0.88, 0.0)
    if DET:
        half = [(0.785, 0.372), (0.858, 0.418), (0.965, 0.456), (1.075, 0.450), (1.155, 0.420), (1.180, 0.398), (1.195, 0.355)]
        hs = [32] + [64] * 6; cseg = 64
    else:
        half = [(0.790, 0.372), (0.875, 0.428), (1.030, 0.456), (1.160, 0.418), (1.196, 0.345)]
        hs = [18] + [36] * 4; cseg = 36
    loop = list(reversed(half)) + [(1.200, 0.0)] + [(r, -x) for r, x in half]
    segs = list(reversed(hs)) + [cseg] + hs
    return W.revolve_x_var("Tire" + SUF, loop, segs, material=rub, closed=True)


def tire_paint(Pm, Nm, base, orm, mask):
    """painted tread: 4 circumferential grooves (dark, soft edges) + short shoulder lugs only on the tread top,
    low contrast (main 10-21: the old lugs read as saw teeth from the side)"""
    x = Pm[..., 0]; r = np.sqrt(Pm[..., 1] ** 2 + Pm[..., 2] ** 2); ax = np.abs(x)
    phi = np.arctan2(Pm[..., 1], Pm[..., 2])
    tread = mask & (r > 1.185)
    groove = np.array([int(C("tire_groove", "#141515")[i:i + 2], 16) / 255 for i in (1, 3, 5)], np.float32)
    g = np.zeros(mask.shape, np.float32)
    for gc in (0.068, 0.200):
        g = np.maximum(g, np.clip((0.0225 - np.abs(ax - gc)) / 0.004 + 0.5, 0, 1))
    g *= tread
    base = base * (1 - 0.85 * g[..., None]) + groove * 0.85 * g[..., None]
    # shoulder lugs: 44, on the tread top only (|x| 0.235..0.34), half strength
    n = 44
    ph = (phi + np.sign(x) * 0.10 * (ax - 0.235)) * n / (2 * np.pi)
    d = np.abs(ph - np.round(ph)) * (2 * np.pi / n) * r
    lug = np.clip((0.009 - d) / 0.004 + 0.5, 0, 1) * np.clip((ax - 0.235) / 0.01, 0, 1) * np.clip((0.34 - ax) / 0.02, 0, 1) * tread
    base = base * (1 - 0.45 * lug[..., None]) + groove * 0.45 * lug[..., None]
    orm[..., 1] = np.maximum(orm[..., 1], 0.9 * np.maximum(g, lug))
    return base, orm


def attach_json(path):
    bolts = {}
    for i, th in enumerate(SPOKES, start=1):
        d = W.clock_dir(th) * BOLT_R
        bolts["Bolt_%d" % i] = {"pos": W.to_roblox((HUB_X * K, d.y * K, d.z * K)), "axis": [1, 0, 0], "clock_deg_seen_from_outside": th}
    data = {"part": "Wheel (Model: Rim [PrimaryPart] + Tire), Detail = Rim.glb/Tire.glb, Lite = Rim_Lite.glb/Tire_Lite.glb (same origin, same bolts)",
            "units": "stud",
            "space": "part local = Roblox axes of the RIGHT wheel (FR/RR): +X outboard, +Y up, -Z car front. Mesh origin = wheel centre.",
            "Rim": {"SnapAttachment": {"pos": [0, 0, 0], "note": "wheel centre"}, **bolts, "star_order": [1, 3, 5, 2, 4],
                    "bolt_axis_note": "Attachment +X = nut comes off outward; pos = nut seat on the hub face (lug hole centre). Lite has painted seats at the same places.",
                    "lug_hole_radius": round(HOLE_R * K, 4), "bolt_circle_radius": round(BOLT_R * K, 4), "hub_face_x": round(HUB_X * K, 4),
                    "mounting_face_x": round(MOUNT_X * K, 4)},
            "Tire": {"pivot": [0, 0, 0], "diameter": round(2.4 * K, 4), "width": round(0.912 * K, 4)},
            "scale": {"factor": K, "note": "main 10-21: tire d 2.4 -> 2.75, wheel centre Y 1.375 (car_spec to update)"},
            "left_wheels": "FL/RL: same meshes turned 180 deg about Y.",
            "note": "Rim is an open shell where the tire covers the barrel - a tire-changer job (alpha) needs a closed rim later."}
    json.dump(data, open(path, "w", encoding="utf-8"), indent=1)


def scaled(ob, paint):
    """scale about the pivot (wheel centre) by K; paint functions keep working in the unscaled build frame"""
    ob.data.transform(Matrix.Scale(K, 4))
    if paint is None:
        return None
    return lambda Pm, Nm, b, o, m: paint(Pm / K, Nm, b, o, m)


rim = build_rim(); print("RIM", LOD, "tris before finish", P.tris(rim))
P.finish(rim, os.path.join(OUT, "Rim" + SUF), tex=1024 if DET else 512, pivot_bottom=False, weighted=False, smooth_angle=50,
         paint=scaled(rim, rim_paint), recalc_normals=False)
tire = build_tire(); print("TIRE", LOD, "tris before finish", P.tris(tire))
P.finish(tire, os.path.join(OUT, "Tire" + SUF), tex=1024 if DET else 512, pivot_bottom=False, weighted=False, smooth_angle=50,
         paint=scaled(tire, tire_paint), recalc_normals=False)
if DET:
    attach_json(os.path.join(OUT, "wheel_attachments.json"))
