# Combination wrench (wr-3d 10-21) from clean primitives, measured on art/concepts/tools/wrench_6view.png front view
# (the top / bottom views are ~15 % short - main decision: not used for shape; side views give the thin thickness and the
# 15 deg ring bend). Size: notes/research/ref_tools/index.md game size 1.2 stud long.
# Real combination wrench: open end (jaw slot tilted 15 deg to the handle), 12-point ring end bent 15 deg out of the
# plane, I-beam shanks (recessed centre), our game colour: chrome + red rubber grip sleeve.
# Build frame (= the concept's front view): length along X (open end at +X), flat face toward +Y (front), width along Z.
#   blender --background --factory-startup --python build_wrench.py -- <out_dir> [palette.json]
import bpy, bmesh, sys, os, math, json
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


HO = Vector((0.47, 0.0)); HR = 0.135            # open head centre / radius (x, z)
SLOT_W, SLOT_A = 0.115, math.radians(15)       # jaw opening, tilt
RC = Vector((-0.49, 0.0)); RR, RIN = 0.115, 0.074   # ring centre, outer radius, 12-point inner radius
HEAD_T, SHANK_T, GRIP_T = 0.055, 0.040, 0.075
BEND_X0, BEND_X1, BEND = -0.30, -0.38, math.radians(15)
FXZ = W.frame((0, 0, 0), (1, 0, 0), (0, 0, 1), (0, -1, 0))   # outline (x, z), thickness along -Y


def plate_xz(name, outer, holes, t, ch, mat, hole_chamfer=None):
    """flat plate in the XZ plane (thickness t along Y, centred), crisp chamfers on both faces, holes allowed"""
    o = [(-x, z) for x, z in outer]; hs = [[(-x, z) for x, z in h] for h in holes]
    ob = W.plate2d(name, o, hs, -t / 2, t / 2, ch, material=mat, back_chamfer=ch, hole_chamfer=hole_chamfer)
    ob.data.transform(Matrix.Rotation(math.pi / 2, 4, 'Z'))
    W.mark_sharp(ob, 35)
    return ob


P.reset()
chrome = P.mat("chrome", C("chrome", "#C9CCCF"), 0.40, 0.60)   # satin chrome (casual finish)
grip = P.mat("grip", C("grip", "#E0332D"), 0.70, 0.0)
parts = []
# --- open end head with the jaw slot (one concave outline)
d = Vector((math.cos(SLOT_A), math.sin(SLOT_A))); nrm = Vector((-d.y, d.x)); hw = SLOT_W / 2
bottom_c = HO + d * 0.015


def circ_hit(off):
    """point where the slot edge (offset `off` along nrm) leaves the head circle"""
    p0 = HO + nrm * off
    t = math.sqrt(max(HR * HR - off * off, 0.0))
    return p0 + d * t


a_up = math.atan2((circ_hit(hw) - HO).y, (circ_hit(hw) - HO).x)
a_lo = math.atan2((circ_hit(-hw) - HO).y, (circ_hit(-hw) - HO).x)
pts = []
n = 32
a0, a1 = a_up, a_lo + 2 * math.pi
for k in range(n + 1):
    a = a0 + (a1 - a0) * k / n
    pts.append(HO + Vector((math.cos(a), math.sin(a))) * HR)
# lower slot edge inward, round bottom, upper edge outward
for k in range(1, 4):
    pts.append(circ_hit(-hw).lerp(bottom_c - nrm * hw, k / 4))
for k in range(0, 9):
    a = -math.pi / 2 - math.pi * k / 8
    pts.append(bottom_c + (nrm * math.sin(a) + d * math.cos(a)) * hw)     # round slot bottom (-90 .. -270 deg)
for k in range(1, 4):
    pts.append((bottom_c + nrm * hw).lerp(circ_hit(hw), k / 4))
rads = [0.0] * len(pts); rads[0] = 0.014; rads[n] = 0.014          # round only the two jaw tips
outline = W.round_corners([(p.x, p.y) for p in pts], rads, 2)
parts.append(plate_xz("open_head", outline, [], HEAD_T, 0.008, chrome))
# --- ring end with a 12-point opening
ring_o = W.circle_pts(RC.x, RC.y, RR, 32)
star = []
for k in range(24):
    a = math.pi * 2 * k / 24
    r = RIN if k % 2 == 0 else RIN * 0.86
    star.append((RC.x + r * math.cos(a), RC.y + r * math.sin(a)))
ring = plate_xz("ring", ring_o, [star], HEAD_T, 0.008, chrome, hole_chamfer=[False])
# --- I-beam shanks (thinner than the heads), grip sleeve
shank_o = W.outline_slab("shank_o", W.densify(W.rrect_pts(0.095, 0.0525, 0.02, 3, cx=0.26, cy=0.0), 0.06), -SHANK_T / 2, SHANK_T / 2,
                         0.010, 1, FXZ, material=chrome, support=False)
shank_b = W.outline_slab("shank_b", W.densify(W.rrect_pts(0.115, 0.0525, 0.02, 3, cx=-0.28, cy=0.0), 0.03), -SHANK_T / 2, SHANK_T / 2,
                         0.010, 1, FXZ, material=chrome, support=False)
W.mark_sharp(shank_o, 35); W.mark_sharp(shank_b, 35)
# edge rounding 0.026 (was 0.03): outline_slab insets the cap ring by 1.4 x the rounding = 0.036 < the 0.04 corner radius, else the ring folds at
# the corners = overlapping cap triangles (QA z-fighting, 10-22)
sleeve = W.outline_slab("grip", W.densify(W.rrect_pts(0.185, 0.0685, 0.04, 3, cx=-0.015, cy=0.0), 0.12), -GRIP_T / 2, GRIP_T / 2, 0.026, 2, FXZ,
                        material=grip)
parts += [shank_o, sleeve]
# --- 15 deg bend of the ring end out of the plane (toward -Y), gradual over the box-side neck


def bend(ob):
    for v in ob.data.vertices:
        if v.co.x < BEND_X0:
            s = min(1.0, (BEND_X0 - v.co.x) / (BEND_X0 - BEND_X1))
            th = BEND * s * s * (3 - 2 * s) if v.co.x > BEND_X1 else BEND
            dx, dy = v.co.x - BEND_X0, v.co.y
            v.co.x = BEND_X0 + dx * math.cos(th) - dy * math.sin(th)
            v.co.y = dx * math.sin(th) + dy * math.cos(th)


bend(shank_b); bend(ring)
parts += [shank_b, ring]
ob = W.join("Wrench", parts)
print("tris before finish", P.tris(ob))


def paint(Pm, Nm, base, orm, mask):
    """I-beam recess on the shank faces (darker oval), two long grooves on the grip sleeve"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    face = mask & (np.abs(Nm[..., 1]) > 0.9)
    for cx_, hl in ((0.26, 0.06), (-0.27, 0.07)):
        e = ((x - cx_) / hl) ** 2 + (z / 0.024) ** 2
        rec = face & (np.abs(y) < SHANK_T / 2 + 0.01) & (e < 1.0) & (np.abs(x - cx_) < 0.1)
        base[rec] = base[rec] * 0.72
    g = face & (np.abs(y) > GRIP_T / 2 - 0.01) & (np.abs(x + 0.015) < 0.15)
    for zc in (0.032, -0.032):
        line = g & (np.abs(z - zc) < 0.006)
        base[line] = base[line] * 0.6
    return base, orm


P.finish(ob, os.path.join(OUT, "Wrench"), tex=1024, pivot_bottom=False, weighted=False, smooth_angle=50, paint=paint, recalc_normals=False)
rb = W.to_roblox
ring_c = Vector((BEND_X0 + (RC.x - BEND_X0) * math.cos(BEND), (RC.x - BEND_X0) * math.sin(BEND), 0.0))
ring_ax = Vector((-math.sin(BEND), math.cos(BEND), 0.0))     # ring face normal after the bend (front side)
jaw = HO + d * 0.04
data = {"tool": "Wrench (combination, 1.2 stud)", "units": "stud",
        "space": "mesh local, Roblox axes (+X = toward the open end, +Y = width (up in the concept front view), -Z = the flat face that faced the concept viewer)",
        "Grip": {"pos": rb((-0.015, 0.0, 0.0)), "axis": [1, 0, 0], "secondary_axis": rb((0, 1, 0)),
                 "note": "middle of the red sleeve. Axis (+X) runs along the handle toward the OPEN end; SecondaryAxis = flat face (thumb side). R15 right hand wraps the sleeve."},
        "Work_Open": {"pos": rb((jaw.x, 0.0, jaw.y)), "bolt_axis": rb((0, 1, 0)), "jaw_direction": rb((d.x, 0, d.y)),
                      "note": "centre of the nut inside the open jaw (15 deg tilted slot, opening 0.115)"},
        "Work_Ring": {"pos": rb(tuple(ring_c)), "bolt_axis": rb(tuple(ring_ax)), "note": "centre of the 12-point ring (bent 15 deg out of the plane)"},
        "size": "1.2 long x 0.27 wide x ~0.09 thick (ring end lifted 15 deg)"}
json.dump(data, open(os.path.join(OUT, "wrench_attachments.json"), "w", encoding="utf-8"), indent=1)
print("ok")
