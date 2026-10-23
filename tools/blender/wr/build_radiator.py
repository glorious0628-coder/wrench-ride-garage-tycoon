# Radiator + fan shroud (wr-3d 10-21) from clean primitives, measured on art/concepts/parts/radiator_6view.png.
# car_spec v0.7: 3.6 x 1.9 x 0.6 (fan + shroud included, comes out together), pivot = centre at (0, 2.3, -7.5).
# Real layout (parts_quickref s4, Camry manual): crossflow core (aluminium fins, flat tubes) between two black plastic
# end tanks; filler neck + cap and upper hose neck on one tank, lower neck on the other (concept: car-right tank has
# the cap and the upper neck, car-left tank the lower neck); 2 upper mounting brackets (bolts), 2 rubber pegs below;
# behind: shroud with one fan + motor, wire to a connector. Build frame: +X car right, +Y car front, +Z up.
#   blender --background --factory-startup --python build_radiator.py -- <out_dir> [palette.json]
import bpy, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wr_lib as W
from wr_lib import P
from mathutils import Vector, Matrix
import numpy as np

argv = sys.argv[sys.argv.index("--") + 1:]
OUT = os.path.abspath(argv[0]); os.makedirs(OUT, exist_ok=True)
PAL = json.load(open(argv[1], encoding="utf-8")) if len(argv) > 1 and argv[1] else {}


def C(n, d):
    return PAL.get(n, d)


def hexf(h):
    return np.array([int(h[i:i + 2], 16) / 255 for i in (1, 3, 5)], np.float32)


TX0, TX1 = 1.44, 1.70          # tank inner / outer x (necks stick out 0.10 -> 3.6 overall, car_spec)
HZ = 0.82                      # half height of the body (cap / tabs / pegs -> ~1.88 overall, car_spec 1.9)
CY0, CY1 = 0.15, 0.25          # core front-back (core faces the car front +Y)
TY0, TY1 = 0.04, 0.30          # tanks
FXY = W.frame((0, 0, 0), (1, 0, 0), (0, 0, 1), (0, -1, 0))   # outline (x, z), thickness along -Y (t -> y = -t)

P.reset()
alu = P.mat("core", C("core", "#B9BCC0"), 0.45, 0.80)
frame_m = P.mat("frame", C("frame", "#C9CCCF"), 0.35, 0.85)
tank = P.mat("tank", C("tank", "#2A2B2D"), 0.55, 0.0)
fanm = P.mat("fan", C("fan", "#232426"), 0.55, 0.0)
rub = P.mat("rubber", C("rubber", "#1C1C1C"), 0.80, 0.0)
red = P.mat("red", C("connector_latch", "#C8302C"), 0.5, 0.0)
parts = []


def slab_xz(name, outline, y_front, y_back, rad, n, mat, rad_back=None):
    """outline in (x, z), from y_front (towards the car front) back to y_back"""
    return W.outline_slab(name, outline, -y_front, -y_back, rad, n, FXY, material=mat,
                          rad_back=rad if rad_back is None else rad_back, n_back=n)


# core (fins painted) + top / bottom side plates
parts.append(W.outline_slab("core", W.densify(W.rrect_pts(TX0 + 0.02, HZ - 0.04, 0.01, 1), 0.8), -CY1, -CY0, 0.0, 1, FXY, material=alu, rad_back=0.0, support=False))
for s in (1, -1):
    parts.append(W.outline_slab("plate", W.rrect_pts(TX0 + 0.03, 0.035, 0.012, 1, cy=s * (HZ - 0.03)), -(CY1 + 0.008), -(CY0 - 0.008), 0.006, 1, FXY,
                                material=frame_m, rad_back=0.006, n_back=1, support=False))
# end tanks (ribbed panels painted), rounded
for s in (1, -1):
    t = W.densify(W.rrect_pts((TX1 - TX0) / 2, HZ, 0.05, 2, cx=s * (TX0 + TX1) / 2), 0.5)
    parts.append(W.outline_slab("tank", t, -TY1, -TY0, 0.03, 2, FXY, material=tank, rad_back=0.0, n_back=1, support=False))
# filler neck + cap (car-right tank, top), bleed nipple (car-left tank, top)
cx = (TX0 + TX1) / 2; cyy = (TY0 + TY1) / 2
parts.append(W.revolve_x("neck", [(0, HZ + 0.06), (0.07, HZ + 0.06), (0.07, HZ - 0.02), (0, HZ - 0.02)], 12, closed=False, material=tank,
                         center=(cx, cyy, 0), axis='Z'))
parts.append(W.revolve_x("cap", [(0, HZ + 0.15), (0.08, HZ + 0.147), (0.108, HZ + 0.13), (0.112, HZ + 0.06), (0, HZ + 0.06)],
                         16, closed=False, material=rub, center=(cx, cyy, 0), axis='Z'))
parts.append(W.revolve_x("bleed", [(0, HZ + 0.10), (0.022, HZ + 0.10), (0.03, HZ + 0.08), (0.03, HZ - 0.02), (0, HZ - 0.02)], 10, closed=False,
                         material=tank, center=(-cx, cyy, 0), axis='Z'))
# hose necks: upper on the car-right tank (+X, z +0.55), lower on the car-left tank (-X, z -0.60)
for s, zc in ((1, 0.55), (-1, -0.60)):
    x0 = s * (TX1 - 0.02)
    prof = [(0.0, x0 + s * 0.12), (0.09, x0 + s * 0.12), (0.115, x0 + s * 0.10), (0.100, x0 + s * 0.065), (0.100, x0), (0.0, x0)]
    if s < 0:
        prof = prof[::-1]
    parts.append(W.revolve_x("hneck", prof, 12, closed=False, material=tank, center=(0, cyy + 0.02, zc), axis='X'))
# upper mounting brackets (metal tabs with a bolt hole) and lower rubber pegs
for s in (1, -1):
    tab = [(s * 0.92 - 0.10, HZ - 0.06), (s * 0.92 + 0.10, HZ - 0.06), (s * 0.92 + 0.10, HZ + 0.06)] + \
          [(s * 0.92 + 0.10 * math.cos(math.radians(a)), HZ + 0.06 + 0.10 * math.sin(math.radians(a))) for a in range(30, 151, 30)] + \
          [(s * 0.92 - 0.10, HZ + 0.06)]
    parts.append(W.outline_slab("tab", tab, -(CY1 - 0.005), -(CY1 - 0.04), 0.0, 1, FXY, material=frame_m, rad_back=0.0, support=False))
    parts.append(W.revolve_x("peg", [(0, -HZ - 0.08), (0.03, -HZ - 0.08), (0.042, -HZ - 0.065), (0.042, -HZ + 0.02), (0, -HZ + 0.02)], 8,
                             closed=False, material=rub, center=(s * 1.2, (CY0 + CY1) / 2, 0), axis='Z'))
# fan shroud behind the core: plate with chamfered corners and a round opening, ring around the opening
SH_X, SH_Z, OPEN_R = 1.06, 0.78, 0.76
sh = [(-SH_X + 0.18, -SH_Z), (SH_X - 0.18, -SH_Z), (SH_X, -SH_Z + 0.18), (SH_X, SH_Z - 0.18), (SH_X - 0.18, SH_Z),
      (-SH_X + 0.18, SH_Z), (-SH_X, SH_Z - 0.18), (-SH_X, -SH_Z + 0.18)]
sh = W.densify(W.round_corners(sh, 0.04, 2), 0.6)
hole = W.circle_pts(0, 0, OPEN_R, 32)
plate = W.plate2d("shroud", [(p[0], p[1]) for p in sh], [hole], -0.13, -0.07, 0.012, material=fanm)   # built along X: turn below (world y 0.13 .. 0.07)
plate.data.transform(Matrix.Rotation(-math.pi / 2, 4, 'Z'))    # local X (depth) -> -Y, local (y, z) -> (x, z)
parts.append(plate)
parts.append(W.revolve_x("venturi", [(OPEN_R, 0.075), (OPEN_R + 0.035, 0.075), (OPEN_R + 0.02, -0.04)],
                         32, closed=True, material=fanm, axis='Y'))
# fan: hub / motor, 7 swept blades with pitch, 3 motor struts
parts.append(W.revolve_x("motor", [(0, -0.30), (0.14, -0.29), (0.20, -0.25), (0.21, 0.02), (0.18, 0.045), (0.0, 0.05)], 16,
                         closed=False, material=fanm, axis='Y'))
for k in range(7):
    a0 = 2 * math.pi * k / 7
    lead, trail = [], []
    for j in range(5):
        t = j / 4; r = 0.20 + 0.52 * t; phi = 0.35 * t * t; w = (0.07 + 0.06 * t) / r
        lead.append((r, phi + w)); trail.append((r, phi - w))
    tip = [(0.745, 0.35 + 0.13 / 0.72 * f) for f in (0.6, 0.0, -0.6)]
    poly = trail + tip[::-1][1:2] + lead[::-1]
    pts = [(r * math.cos(ph), r * math.sin(ph)) for r, ph in poly]
    bl = W.outline_slab("blade", pts, -0.012, 0.012, 0.0, 1, W.frame((0, 0, 0), (1, 0, 0), (0, 0, 1), (0, -1, 0)),
                        material=fanm, rad_back=0.0, support=False)
    # pitch each blade about its own radial axis, then place it round the hub
    M = Matrix.Rotation(a0, 4, 'Y') @ Matrix.Translation((0, -0.02, 0))
    for v in bl.data.vertices:
        rr = math.hypot(v.co.x, v.co.z); ang = math.atan2(v.co.z, v.co.x)
        tt = min(max((rr - 0.20) / 0.53, 0), 1)
        lean = (ang - 0.35 * tt * tt) * rr          # arc distance from the blade's centre line
        v.co.y += -0.35 * lean                      # ~19 deg pitch
    bl.data.transform(M)
    parts.append(bl)
for k in range(3):
    a = math.radians(90 + 120 * k)
    st = W.tube("strut", [Vector((0.2 * math.cos(a), -0.13, 0.2 * math.sin(a))), Vector((0.80 * math.cos(a), 0.06, 0.80 * math.sin(a)))],
                0.018, around=8, material=fanm)
    parts.append(st)
# motor wire to the connector on the car-right side of the shroud
wire = [Vector((0.12, -0.27, -0.08)), Vector((0.45, -0.25, -0.24)), Vector((0.80, -0.17, -0.31)), Vector((0.93, -0.02, -0.33)), Vector((0.96, 0.02, -0.33))]   # behind the blades
parts.append(W.tube("wire", wire, 0.018, around=8, material=rub))
con = W.outline_slab("connector", W.rrect_pts(0.075, 0.05, 0.015, 1, cx=1.02, cy=-0.33), -0.07, 0.0, 0.0, 1, FXY, material=fanm, rad_back=0.0, support=False)
parts.append(con)
parts.append(W.outline_slab("latch", W.rrect_pts(0.02, 0.05, 0.008, 1, cx=0.97, cy=-0.33), -0.004, 0.008, 0.0, 1, FXY, material=red,
                            support=False))
import collections
_c = collections.Counter()
for _p in parts:
    _c[_p.name.split(".")[0]] += P.tris(_p)
print("PARTS", dict(_c))
ob = W.join("Radiator", parts)
print("tris before finish", P.tris(ob))


def paint(Pm, Nm, base, orm, mask):
    """core: horizontal flat tubes with fins between (soft stripes, not noisy); tank panels; tab holes; neck openings"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    core = mask & (np.abs(x) < TX0 + 0.015) & (np.abs(z) < HZ - 0.045) & (np.abs(Nm[..., 1]) > 0.9) & (y > CY0 - 0.01) & (y < CY1 + 0.01)
    ph = (z + HZ) / 0.075
    tube = np.clip((0.18 - np.abs(ph - np.round(ph))) / 0.05 + 0.5, 0, 1) * core
    fin_dark = hexf("#8D9095"); tube_col = hexf(C("core_tube", "#D3D6DA"))
    base[core] = base[core] * 0.6 + fin_dark * 0.4
    base = base * (1 - tube[..., None]) + tube_col * tube[..., None]
    # tank: raised-panel look (lighter bands with dark gaps)
    tk = mask & (np.abs(x) > TX0 + 0.02) & (np.abs(x) < TX1 - 0.03) & (Nm[..., 1] > 0.9)
    band = (np.abs(((z + HZ) / 0.34) - np.round((z + HZ) / 0.34)) < 0.06) & tk
    base[band] = base[band] * 0.55
    # bracket holes, neck openings (dark)
    for s in (1, -1):
        hole = mask & (np.hypot(x - s * 0.92, z - (HZ + 0.06)) < 0.035) & (np.abs(Nm[..., 1]) > 0.8)
        base[hole] = hexf("#151515")
    for s, zc in ((1, 0.55), (-1, -0.60)):
        op = mask & (np.hypot(y - ((TY0 + TY1) / 2 + 0.02), z - zc) < 0.07) & (s * x > TX1 + 0.08)
        base[op] = hexf("#0E0E0E")
    return base, orm


P.finish(ob, os.path.join(OUT, "Radiator"), tex=1024, pivot_bottom=False, weighted=False, smooth_angle=50, paint=paint, recalc_normals=False)
rb = W.to_roblox
data = {"part": "Radiator (MechanicalParts/Radiator, fan + shroud included)", "units": "stud",
        "space": "part local, Roblox axes (+X car right, +Y up, -Z car front); origin = centre", "mount": {"car_pos": [0, 2.3, -7.5]},
        "SnapAttachment": [0, 0, 0],
        "Bolt_1": {"pos": rb((0.92, (CY1 - 0.02), HZ + 0.06)), "axis": [0, 0, -1], "note": "upper bracket, car right (bolt comes out to the front)"},
        "Bolt_2": {"pos": rb((-0.92, (CY1 - 0.02), HZ + 0.06)), "axis": [0, 0, -1], "note": "upper bracket, car left"},
        "HoseClip_Upper": {"pos": rb((TX1 + 0.07, (TY0 + TY1) / 2 + 0.02, 0.55)), "note": "upper hose neck, car-right tank (slide clip)"},
        "HoseClip_Lower": {"pos": rb((-TX1 - 0.07, (TY0 + TY1) / 2 + 0.02, -0.60)), "note": "lower hose neck, car-left tank"},
        "FanConnector": {"pos": rb((1.02, 0.03, -0.33)), "note": "fan motor connector (unplug before lifting out)"},
        "Cap": {"pos": rb(((TX0 + TX1) / 2, (TY0 + TY1) / 2, HZ + 0.15)), "note": "radiator cap (Fluid_Coolant is on the chassis / overflow tank)"},
        "Grip_L": {"pos": rb((-(TX0 + TX1) / 2, (TY0 + TY1) / 2, HZ)), "note": "top of the car-left tank"},
        "Grip_R": {"pos": rb(((TX0 + TX1) / 2, (TY0 + TY1) / 2, HZ)), "note": "top of the car-right tank (beside the cap)"}}
json.dump(data, open(os.path.join(OUT, "radiator_attachments.json"), "w", encoding="utf-8"), indent=1)
print("ok")
