# Rear muffler (wr-3d 10-21) from clean primitives, measured on art/concepts/parts/muffler_6view.png (the right view's
# flange is wrong - main 6-view decision). car_spec v0.7: transverse drum under the rear bumper, 2.6 x 0.6 x 1.0,
# pivot = centre (+0.3, 0.8, +7.6). parts_quickref s5 (Walker 21005 for the Camry): oval body 356 x 279 x 140 mm ->
# drum 1.27 long (X) x 1.0 deep (Z front-back) x 0.5 tall, rolled seams at both ends, offset-offset pipes on the end caps:
# inlet 2.4" with a 2-bolt flange (concept: at the car-right end, flange facing the car front), outlet 2.0" tailpipe
# with an angle-cut tip (car-left end, bent back), 2 rubber hangers on top (rod into a rubber isolator).
# Build frame: +X car right, +Y car front, +Z up; origin = drum centre.
#   blender --background --factory-startup --python build_muffler.py -- <out_dir> [palette.json]
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


L2, HY, HZ, CR = 0.635, 0.50, 0.25, 0.22     # drum half length (X), half depth (Y), half height (Z), stadium corner
P.reset()
steel = P.mat("steel", C("steel", "#B5B3AE"), 0.55, 0.55)     # stainless, satin (main 10-21: less glossy, same casual finish as battery / radiator)
rub = P.mat("rubber", C("rubber", "#232323"), 0.80, 0.0)
parts = []
# drum: stadium section rings lofted along X with rounded ends and a rolled seam bead near each end
base = W.densify(W.rrect_pts(HY, HZ, CR, 6), 0.7)


def ring(x, d):
    pts = W.offset_outline(base, d)
    return [Vector((x, p[0], p[1])) for p in pts]


prof = []
for k in range(3, 0, -1):                       # rounded end (car left)
    a = math.pi / 2 * k / 3
    prof.append((-L2 + 0.05 * (1 - math.sin(a)), -0.05 * (1 - math.cos(a))))
prof += [(-L2 + 0.05, 0.0), (-L2 + 0.065, 0.012), (-L2 + 0.085, 0.012), (-L2 + 0.10, 0.0),
         (L2 - 0.10, 0.0), (L2 - 0.085, 0.012), (L2 - 0.065, 0.012), (L2 - 0.05, 0.0)]
for k in range(1, 4):
    a = math.pi / 2 * k / 3
    prof.append((L2 - 0.05 * (1 - math.cos(a)), -0.05 * (1 - math.sin(a))))
rings = [ring(x, d) for x, d in prof]
drum = W.loft("drum", rings, cap0=True, cap1=True, material=steel)
parts.append(drum)
# inlet: out of the car-right end cap (offset to the front), bends forward, 2-bolt oval flange facing the car front
R_IN = 0.12
pin = []
x0, y0 = L2 - 0.02, 0.20
for t in range(2):
    pin.append(Vector((x0 + 0.12 * t, y0, 0.0)))
for k in range(1, 7):                           # 90 deg bend (radius 0.22, no pinch) from +X to +Y
    a = math.pi / 2 * k / 6
    pin.append(Vector((x0 + 0.12 + 0.22 * math.sin(a), y0 + 0.22 * (1 - math.cos(a)), 0.0)))
xe = x0 + 0.12 + 0.22
pin += [Vector((xe, y0 + 0.22 + 0.07, 0.0))]
parts.append(W.tube("inlet", pin, R_IN, around=12, material=steel))
yf = y0 + 0.22 + 0.07
FL = W.frame((xe, yf, 0.0), (1, 0, 0), (0, 0, 1), (0, -1, 0))    # outline (x, z) about the pipe end, thickness to -Y
fl = W.rrect_pts(0.25, 0.125, 0.115, 4)
parts.append(W.outline_slab("flange", W.densify(fl, 0.3), -0.035, 0.0, 0.01, 1, FL, material=steel, rad_back=0.01, n_back=1))
# tailpipe: out of the car-left end cap (offset to the back), bends back and a little down, angle-cut tip
R_OUT = 0.10
pt = []
x1, y1 = -L2 + 0.02, -0.20
# wr-carbook 10-21 (Walker 21005 / real sedans): the tailpipe leaves the end cap, turns and runs STRAIGHT BACK (slightly
# down) - only the tip is cut at an angle. Last run parallel to the car axis; tip at local z +0.5 (car Z ~8.1, inside the
# bumper end 8.5); FX_Exhaust axis ~ (0, -0.15, 0.99) in Roblox axes.
for t in range(2):
    pt.append(Vector((x1 - 0.09 * t, y1, -0.02)))
for k in range(1, 7):                            # 90 deg bend from -X to straight back (-Y), radius 0.15
    a = math.pi / 2 * k / 6
    pt.append(Vector((x1 - 0.09 - 0.15 * math.sin(a), y1 - 0.15 * (1 - math.cos(a)), -0.02)))
d = Vector((0.0, -0.989, -0.149)).normalized()  # straight back, a little down
L_ = (0.50 - 0.35) / -d.y                        # run to y = -0.50 (local z +0.5 in Roblox)
pt += [pt[-1] + d * (L_ * 0.5), pt[-1] + d * L_]
tail = W.tube("tail", pt, R_OUT, around=12, material=steel)
# angle-cut tip: shear the last ring along the pipe so the opening is slanted
tip_c = pt[-1]
for v in tail.data.vertices:
    if (v.co - tip_c).length < R_OUT * 1.05 + 1e-4:
        off = (v.co - tip_c)
        v.co += d * (off.z * 0.9)               # lower lip sticks out further (slanted cut)
parts.append(tail)
# rubber hangers on top: rod up from the drum, bent forward into a rubber isolator
HANG = []
for s in (1, -1):
    hx = s * 0.36
    rod = [Vector((hx, 0.0, HZ - 0.02)), Vector((hx, 0.0, HZ + 0.06)), Vector((hx, 0.04, HZ + 0.10)), Vector((hx, 0.12, HZ + 0.11))]
    parts.append(W.tube("rod", rod, 0.022, around=8, material=steel))
    c = Vector((hx, 0.16, HZ + 0.11)); HANG.append(c)
    parts.append(W.revolve_x("iso", [(0, 0.045), (0.055, 0.043), (0.072, 0.025), (0.072, -0.025), (0.055, -0.043), (0, -0.045)],
                             12, closed=False, material=rub, center=c, axis='Y'))
ob = W.join("Muffler", parts)
print("tris before finish", P.tris(ob))


def paint(Pm, Nm, base, orm, mask):
    """dark pipe openings (inlet in the flange, tailpipe tip), flange bolt holes"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    fl_front = mask & (Nm[..., 1] > 0.8) & (y > yf - 0.01)
    op = fl_front & (np.hypot(x - xe, z) < R_IN - 0.02)
    holes = fl_front & ((np.hypot(x - (xe + 0.19), z) < 0.03) | (np.hypot(x - (xe - 0.19), z) < 0.03))
    base[op | holes] = hexf("#151515")
    tip = mask & (np.linalg.norm(Pm - np.array(tip_c, np.float32), axis=-1) < R_OUT * 1.6) & ((Nm @ np.array(d, np.float32)) > 0.5)
    base[tip] = hexf("#151515")
    # seams a touch darker (rolled joints)
    seam = mask & (np.abs(np.abs(x) - (L2 - 0.075)) < 0.012)
    base[seam] = base[seam] * 0.8
    return base, orm


P.finish(ob, os.path.join(OUT, "Muffler"), tex=1024, pivot_bottom=False, weighted=False, smooth_angle=50, paint=paint, recalc_normals=False)
rb = W.to_roblox
data = {"part": "Muffler (MechanicalParts/Muffler, tailpipe included)", "units": "stud",
        "space": "part local, Roblox axes (+X car right, +Y up, -Z car front); origin = drum centre",
        "mount": {"car_pos": [0.3, 0.8, 7.6]}, "SnapAttachment": [0, 0, 0],
        "Bolt_1": {"pos": rb((xe + 0.19, yf + 0.035, 0.0)), "axis": [0, 0, -1], "note": "inlet flange bolt (comes out to the car front)"},
        "Bolt_2": {"pos": rb((xe - 0.19, yf + 0.035, 0.0)), "axis": [0, 0, -1], "note": "inlet flange bolt"},
        "Hanger_1": {"pos": rb(tuple(HANG[0])), "note": "rubber isolator, car right (pull off by hand)"},
        "Hanger_2": {"pos": rb(tuple(HANG[1])), "note": "rubber isolator, car left"},
        "FX_Exhaust": {"pos": rb(tuple(tip_c)), "axis": rb(tuple(d)), "note": "tailpipe tip (smoke / sound)"},
        "Grip_L": {"pos": rb((-0.50, 0.0, HZ)), "note": "drum top, car-left end"},
        "Grip_R": {"pos": rb((0.50, 0.0, HZ)), "note": "drum top, car-right end"}}
json.dump(data, open(os.path.join(OUT, "muffler_attachments.json"), "w", encoding="utf-8"), indent=1)
print("ok")
