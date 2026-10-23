# Handheld OBD-II scanner (wr-3d 10-21) from clean primitives, measured on art/concepts/tools/obd_6view.png front / side
# views (main decision: the top / bottom views' projection is wrong, not used for shape). Game size (ref_tools/index.md):
# body 0.92 x 0.48 x 0.15 stud. Real layout (Foxwell / Autel / Innova mix): tall body, colour screen on top (no text -
# simple icons and bars), D-pad + 4 buttons below, rubber bumpers on the sides and corners, cable out of the top with a
# strain relief, SAE J1962 plug (D-shaped, 2 x 8 = 16 pins) with a red grip. Cable kept short (main 10-21).
# Build frame (= the concept front): screen faces +Y, up +Z, width X; origin = body centre.
#   blender --background --factory-startup --python build_obd.py -- <out_dir> [palette.json]
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


BW, BH, BT = 0.18, 0.44, 0.13      # body half width, half height, thickness
FXZ = W.frame((0, 0, 0), (1, 0, 0), (0, 0, 1), (0, -1, 0))   # outline (x, z), thickness t -> y = -t
P.reset()
frame_m = P.mat("frame", C("frame", "#8E9295"), 0.55, 0.05)
bump = P.mat("bumper", C("bumper", "#F8312E"), 0.75, 0.0)
face = P.mat("face", C("face", "#3C3D3D"), 0.55, 0.0)
screen = P.mat("screen", C("screen", "#232F3E"), 0.15, 0.0)
btn = P.mat("button", C("button", "#414241"), 0.60, 0.0)
black = P.mat("black", C("black", "#313030"), 0.70, 0.0)
plug = P.mat("plug", C("plug", "#3A3B3A"), 0.55, 0.0)
parts = []


def slab(name, pts, y_front, y_back, rad, n, mat, rad_back=None, support=True):
    return W.outline_slab(name, pts, -y_front, -y_back, rad, n, FXZ, material=mat, rad_back=rad if rad_back is None else rad_back,
                          n_back=n, support=support)


parts.append(slab("body", W.densify(W.rrect_pts(BW, BH, 0.08, 4), 0.5), BT / 2, -BT / 2, 0.03, 2, frame_m))
parts.append(slab("faceplate", W.densify(W.rrect_pts(BW - 0.035, BH - 0.05, 0.05, 3), 0.3), BT / 2 + 0.012, BT / 2 - 0.01, 0.006, 1, face,
                  rad_back=0.0, support=False))
parts.append(slab("screen", W.rrect_pts(0.115, 0.115, 0.015, 2, cy=0.19), BT / 2 + 0.015, BT / 2 + 0.005, 0.003, 1, screen, rad_back=0.0,
                  support=False))
# buttons: 4 round + D-pad ring + centre button
for x_, z_ in ((-0.10, -0.06), (0.10, -0.06), (-0.10, -0.30), (0.10, -0.30)):
    parts.append(W.revolve_x("btn", [(0, BT / 2 + 0.03), (0.024, BT / 2 + 0.029), (0.033, BT / 2 + 0.022), (0.035, BT / 2 + 0.005), (0, BT / 2 + 0.005)],
                             10, closed=False, material=btn, center=(x_, 0, z_), axis='Y'))
parts.append(W.revolve_x("dpad", [(0.045, BT / 2 + 0.026), (0.075, BT / 2 + 0.026), (0.085, BT / 2 + 0.02), (0.087, BT / 2 + 0.005),
                                  (0.045, BT / 2 + 0.005)], 20, closed=True, material=btn, center=(0, 0, -0.18), axis='Y'))
parts.append(W.revolve_x("dcentre", [(0, BT / 2 + 0.032), (0.03, BT / 2 + 0.031), (0.04, BT / 2 + 0.024), (0.042, BT / 2 + 0.005), (0, BT / 2 + 0.005)],
                         16, closed=False, material=frame_m, center=(0, 0, -0.18), axis='Y'))
# red rubber bumpers: 4 corner caps + 2 side rails (inside the 0.48 width)
for sx in (-1, 1):
    for sz in (-1, 1):
        parts.append(slab("corner", W.rrect_pts(0.06, 0.09, 0.05, 3, cx=sx * 0.18, cy=sz * 0.375), 0.075, -0.075, 0.03, 1, bump, support=False))
    parts.append(slab("rail", W.rrect_pts(0.022, 0.30, 0.02, 2, cx=sx * 0.205, cy=0.0), 0.06, -0.06, 0.018, 1, bump, support=False))
# cable: ribbed strain relief, short cable, J1962 plug (red grip + black D-shaped head)
parts.append(W.revolve_x("relief", [(0, BH - 0.02), (0.045, BH - 0.02), (0.045, BH + 0.03), (0.038, BH + 0.04), (0.042, BH + 0.06),
                                    (0.034, BH + 0.075), (0.036, BH + 0.095), (0.026, BH + 0.12), (0, BH + 0.12)], 12, closed=False, material=black, axis='Z'))
cab = [Vector((0, 0, BH + 0.10)), Vector((0, 0.01, BH + 0.20)), Vector((0, 0.0, BH + 0.30)), Vector((0, 0, BH + 0.38))]
parts.append(W.tube("cable", cab, 0.022, around=10, material=black))
CZ = BH + 0.44                          # plug grip centre
parts.append(slab("grip", W.densify(W.round_corners([(-0.10, CZ - 0.07), (0.10, CZ - 0.07), (0.115, CZ + 0.06), (-0.115, CZ + 0.06)], 0.025, 3), 0.3),
                  0.045, -0.045, 0.016, 2, bump))   # edge rounding 0.016 (was 0.02): the cap ring is inset 1.4 x this = 0.022 < the 0.025 corner radius (QA z-fighting 10-22)
d_shape = [(-0.088, 0.034), (-0.088, -0.010), (-0.062, -0.034), (0.062, -0.034), (0.088, -0.010), (0.088, 0.034)]
d_shape = W.round_corners(d_shape[::-1], 0.008, 1)[::-1]
HEAD0, HEAD1 = CZ + 0.055, CZ + 0.13
parts.append(W.outline_slab("head", d_shape, HEAD0, HEAD1, 0.008, 1, W.frame((0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1)), material=plug,
                            rad_back=0.0, support=False))
ob = W.join("OBDScanner", parts)
print("tris before finish", P.tris(ob))


def paint(Pm, Nm, base, orm, mask):
    """screen: engine icon, green check box, coloured bars (no text); white D-pad arrows; plug pins 2 x 8; grip ribs; back cover"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    scr = mask & (Nm[..., 1] > 0.9) & (y > BT / 2 + 0.012) & (np.abs(x) < 0.11) & (np.abs(z - 0.19) < 0.11)
    u, v = -x, z - 0.19          # screen u runs to the viewer's right = -X (front view looks along -Y)
    ico = scr & (np.abs(u + 0.05) < 0.032) & (np.abs(v - 0.06) < 0.022)          # engine block icon (grey)
    ico |= scr & (np.abs(u + 0.05) < 0.012) & (np.abs(v - 0.088) < 0.008)
    base[ico] = hexf("#C9CDD3")
    chk = scr & (np.abs(u - 0.05) < 0.035) & (np.abs(v - 0.06) < 0.026)          # green box with a white tick
    base[chk] = hexf("#2DBE4F")
    tick = chk & ((np.abs((v - 0.055) - (u - 0.045) * 1.0) < 0.006) & (u > 0.035) & (u < 0.07) |
                  (np.abs((v - 0.055) + (u - 0.045) * 1.0) < 0.006) & (u > 0.033) & (u <= 0.045))   # short left arm
    base[tick] = hexf("#FFFFFF")
    for vc, hl, col in ((0.0, 0.095, "#2DBE4F"), (-0.035, 0.07, "#2F86D9"), (-0.065, 0.08, "#8E9295"), (-0.092, 0.05, "#D9362F")):
        bar = scr & (np.abs(v - vc) < 0.010) & (u > -0.095) & (u < -0.095 + 2 * hl)
        base[bar] = hexf(col)
    # D-pad arrows (white triangles at 4 points of the ring)
    ring = mask & (Nm[..., 1] > 0.8) & (y > BT / 2 + 0.02)
    dx, dz = x, z + 0.18
    for ax, az in ((0, 1), (0, -1), (1, 0), (-1, 0)):
        along = dx * ax + dz * az; across = np.abs(dx * az - dz * ax)      # symmetric, no flip needed
        tri = ring & (along > 0.052) & (along < 0.075) & (across < (0.075 - along) * 0.9)
        base[tri] = hexf("#F2F2F2")
    # plug pins 2 x 8 on the head face
    pf = mask & (Nm[..., 2] > 0.9) & (z > HEAD1 - 0.003)
    pin = np.zeros(mask.shape, bool)
    for r_ in (0.012, -0.012):
        for k in range(8):
            pin |= np.hypot(x - (-0.06 + k * 0.12 / 7), y - r_) < 0.0055
    base[pf] = hexf("#1A1A1A"); base[pf & pin] = hexf("#D9C27A"); orm[pf & pin, 2] = 0.9
    # grip ribs on the red plug grip, battery cover on the back
    gr = mask & (np.abs(Nm[..., 1]) > 0.9) & (np.abs(z - CZ) < 0.05) & (np.abs(x) < 0.09)
    rib = gr & (np.abs(((z - CZ) / 0.025) - np.round((z - CZ) / 0.025)) < 0.18)
    base[rib] = base[rib] * 0.7
    back = mask & (Nm[..., 1] < -0.9) & (np.abs(x) < 0.13) & (np.abs(z + 0.02) < 0.32)
    base[back] = hexf("#2C2D2E")
    return base, orm


P.finish(ob, os.path.join(OUT, "OBDScanner"), tex=1024, pivot_bottom=False, weighted=False, smooth_angle=50, paint=paint, recalc_normals=False)
rb = W.to_roblox
data = {"tool": "OBD-II scanner (handheld, short cable)", "units": "stud",
        "space": "mesh local, Roblox axes (+Y up, -Z = the screen side, +X = right edge when you look at the screen... = Blender +X); origin = body centre",
        "Grip": {"pos": rb((0, 0, -0.22)), "axis": rb((0, 0, 1)), "secondary_axis": rb((0, 1, 0)),
                 "note": "lower half of the body (R15 right hand). Axis = up toward the cable, SecondaryAxis = screen side (thumb on the D-pad)."},
        "Cable_End": {"pos": rb((0, 0, HEAD1)), "axis": rb((0, 0, 1)),
                      "note": "face of the J1962 plug (2 x 8 pins) - snaps into the car's OBD_Port; code can stretch a longer cable from here"},
        "Cable_Root": {"pos": rb((0, 0, BH + 0.10))},
        "Screen": {"pos": rb((0, BT / 2 + 0.015, 0.19)), "normal": rb((0, 1, 0)), "size": [0.23, 0.23], "note": "for a SurfaceGui if the code wants live text"},
        "size": "body 0.48 x 0.92 x 0.15 (bumpers included); total height with the short cable + plug about 1.45"}
json.dump(data, open(os.path.join(OUT, "obd_attachments.json"), "w", encoding="utf-8"), indent=1)
print("ok")
