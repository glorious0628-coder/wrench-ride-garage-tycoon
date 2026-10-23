# Battery (wr-3d 10-21) from clean primitives, measured on art/concepts/parts/battery_6view.png (front + top views; the
# side views' terminal colours are wrong - main 6-view decision). car_spec v0.7: H5 / Group 47, 0.95 x 0.75 x 0.70
# (X across the car x height x depth), pivot = bottom centre, mounted at (-2.2, 2.35, -5.7) (left = driver side).
# Real layout (parts_quickref s3, Camry manual): terminals on the FRONT edge corners, + toward the fuse box (outboard,
# car left -X) with a red cover, - inboard; base ledge all round (the hold-down clamp presses it, 1 bolt); fold-flat
# handle in the middle of the lid; vent cap strip; charge eye. Build frame: +X car right, +Y car front, +Z up.
#   blender --background --factory-startup --python build_battery.py -- <out_dir> [palette.json]
import bpy, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wr_lib as W
from wr_lib import P
from mathutils import Vector
import numpy as np

argv = sys.argv[sys.argv.index("--") + 1:]
OUT = os.path.abspath(argv[0]); os.makedirs(OUT, exist_ok=True)
PAL = json.load(open(argv[1], encoding="utf-8")) if len(argv) > 1 and argv[1] else {}


def C(n, d):
    return PAL.get(n, d)


def hexf(h):
    return np.array([int(h[i:i + 2], 16) / 255 for i in (1, 3, 5)], np.float32)


FZ = W.frame((0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1))   # outline in (x, y), thickness along z
LEDGE_Z, BODY_TOP, LID_TOP, DECK_TOP = 0.069, 0.51, 0.64, 0.687
POST = {"neg": (0.37, 0.18), "pos": (-0.37, 0.18)}           # - inboard (+X), + outboard (-X, toward the fuse box)

P.reset()
case = P.mat("case", C("case", "#2B2B2D"), 0.55, 0.0)          # black polypropylene case
lid = P.mat("lid", C("lid", "#5A5B5E"), 0.50, 0.0)             # grey lid
handle = P.mat("handle", C("handle", "#1E1E20"), 0.60, 0.0)
red = P.mat("red", C("red", "#D2262A"), 0.40, 0.0)             # + terminal cover
lead = P.mat("lead", C("lead", "#8C8C8E"), 0.45, 0.85)          # - lead post
parts = []
# base ledge (all round, the hold-down clamp presses it)
parts.append(W.outline_slab("ledge", W.densify(W.rrect_pts(0.475, 0.35, 0.045, 2), 0.3), 0.0, LEDGE_Z, 0.015, 1, FZ,
                            material=case, rad_back=0.004, n_back=1))
# case body
parts.append(W.outline_slab("body", W.densify(W.rrect_pts(0.456, 0.3325, 0.035, 2), 0.3), LEDGE_Z - 0.01, BODY_TOP + 0.01, 0.0, 1, FZ,
                            material=case, rad_back=0.0, n_back=1, support=False))
# grey lid (slightly wider than the body: the lid lip)
parts.append(W.outline_slab("lid", W.densify(W.rrect_pts(0.465, 0.3425, 0.04, 3), 0.3), BODY_TOP, LID_TOP, 0.02, 2, FZ,
                            material=lid, rad_back=0.006, n_back=1))
# raised deck: everything except the two terminal shelves at the front corners
deck = [(-0.44, -0.32), (0.44, -0.32), (0.44, 0.03), (0.285, 0.03), (0.235, 0.32), (-0.235, 0.32), (-0.285, 0.03), (-0.44, 0.03)]
parts.append(W.outline_slab("deck", W.densify(W.round_corners(deck, [0.03, 0.03, 0.03, 0.02, 0.03, 0.03, 0.02, 0.03], 2), 0.3),
                            LID_TOP - 0.01, DECK_TOP, 0.012, 1, FZ, material=lid, rad_back=0.0, n_back=1, support=False))
# terminal posts: - = lead cone, + = red cover
nx, ny = POST["neg"]
parts.append(W.revolve_x("collar_n", [(0, LID_TOP + 0.012), (0.066, LID_TOP + 0.012), (0.070, LID_TOP), (0, LID_TOP)], 16, closed=False,
                         material=lid, center=(nx, ny, 0), axis='Z'))
parts.append(W.revolve_x("post_n", [(0, 0.735), (0.030, 0.733), (0.042, 0.722), (0.050, LID_TOP + 0.01), (0, LID_TOP + 0.01)], 20,
                         closed=False, material=lead, center=(nx, ny, 0), axis='Z'))
px, py = POST["pos"]
parts.append(W.revolve_x("collar_p", [(0, LID_TOP + 0.012), (0.072, LID_TOP + 0.012), (0.076, LID_TOP), (0, LID_TOP)], 16, closed=False,
                         material=lid, center=(px, py, 0), axis='Z'))
parts.append(W.revolve_x("cover_p", [(0, 0.748), (0.035, 0.746), (0.055, 0.737), (0.062, 0.722), (0.064, LID_TOP + 0.01), (0, LID_TOP + 0.01)],
                         16, closed=False, material=red, center=(px, py, 0), axis='Z'))
# fold-flat handle (black): bar + two legs with pivot bosses
hz = DECK_TOP
bar = [(-0.30, 0.085), (0.30, 0.085), (0.30, 0.15), (-0.30, 0.15)]
parts.append(W.outline_slab("hbar", W.densify(W.round_corners(bar, 0.025, 2), 0.15), hz - 0.004, hz + 0.035, 0.014, 1, FZ, material=handle,
                            rad_back=0.0, support=False))
for s in (1, -1):
    leg = [(s * 0.335, -0.06), (s * 0.27, -0.06), (s * 0.27, 0.15), (s * 0.335, 0.15)]
    if s < 0:
        leg = leg[::-1]
    parts.append(W.outline_slab("hleg", W.round_corners(leg, 0.02, 2), hz - 0.004, hz + 0.04, 0.014, 1, FZ, material=handle,
                                rad_back=0.0, support=False))
# vent cap strip at the back + 5 round caps
parts.append(W.outline_slab("vstrip", W.densify(W.rrect_pts(0.41, 0.055, 0.03, 2, cy=-0.225), 0.15), DECK_TOP - 0.004, DECK_TOP + 0.012,
                            0.006, 1, FZ, material=lid, rad_back=0.0, support=False))
for k in range(6):                       # 12 V = 6 cells -> 6 vent caps (wr-carbook 10-21)
    parts.append(W.revolve_x("vcap", [(0, DECK_TOP + 0.034), (0.028, DECK_TOP + 0.032), (0.037, DECK_TOP + 0.024), (0.039, DECK_TOP + 0.008),
                                      (0, DECK_TOP + 0.008)], 10, closed=False, material=lid, center=(-0.3375 + 0.135 * k, -0.225, 0), axis='Z'))
ob = W.join("Battery", parts)
print("tris before finish", P.tris(ob))


def paint(Pm, Nm, base, orm, mask):
    """charge eye (green) on the deck; + and - signs on the lid front under the terminals; body side panel"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    up = mask & (Nm[..., 2] > 0.9)
    eye = up & (np.hypot(x - 0.0, y - 0.24) < 0.026) & (z > DECK_TOP - 0.002)
    ring = up & (np.hypot(x, y - 0.24) < 0.04) & ~eye & (z > DECK_TOP - 0.002)
    base[ring] = hexf("#1E1E20"); base[eye] = hexf(C("eye", "#2FB04A")); orm[eye, 1] = 0.2
    front = mask & (Nm[..., 1] > 0.9) & (z > BODY_TOP + 0.015) & (z < LID_TOP - 0.02)
    sign = hexf("#F2F2F2")
    for cx, plus in ((px, True), (nx, False)):
        hbar = (np.abs(x - cx) < 0.036) & (np.abs(z - 0.577) < 0.009)
        vbar = (np.abs(x - cx) < 0.009) & (np.abs(z - 0.577) < 0.036)
        m = front & (hbar | (vbar if plus else False))
        base[m] = sign
    # recessed label panel on the long faces (a shade lighter, like the concept)
    side = mask & (np.abs(Nm[..., 1]) > 0.9) & (z > LEDGE_Z + 0.04) & (z < BODY_TOP - 0.04) & (np.abs(x) < 0.38)
    base[side] = base[side] * 0.85 + hexf("#3A3A3D") * 0.15
    return base, orm


P.finish(ob, os.path.join(OUT, "Battery"), tex=1024, pivot_bottom=False, weighted=False, smooth_angle=50, paint=paint, recalc_normals=False)

rb = W.to_roblox
data = {"part": "Battery (MechanicalParts/Battery)", "units": "stud",
        "space": "part local, Roblox axes (+X car right, +Y up, -Z car front); origin = bottom centre (car_spec pivot)",
        "mount": {"car_pos": [-2.2, 2.35, -5.7], "rotation": "none (terminals face the car front)"},
        "SnapAttachment": [0, 0, 0],
        "Bolt_1": {"pos": rb((nx, ny, 0.735)), "axis": [0, 1, 0], "note": "- terminal (inboard) - take off FIRST"},
        "Bolt_2": {"pos": rb((px, py, 0.748)), "axis": [0, 1, 0], "note": "+ terminal (outboard, red cover)"},
        "Bolt_3": {"pos": rb((0.0, 0.40, LEDGE_Z)), "axis": [0, 1, 0], "note": "hold-down clamp bolt, on the tray in front of the base ledge (clamp presses the ledge)"},
        "Grip_L": {"pos": rb((-0.12, 0.118, DECK_TOP + 0.04)), "note": "on the fold-flat handle"},
        "Grip_R": {"pos": rb((0.12, 0.118, DECK_TOP + 0.04)), "note": "on the fold-flat handle"},
        "size": [0.95, 0.75, 0.70]}
json.dump(data, open(os.path.join(OUT, "battery_attachments.json"), "w", encoding="utf-8"), indent=1)
print("ok")
