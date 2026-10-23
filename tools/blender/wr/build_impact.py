# Cordless 1/2" impact wrench (wr-3d 10-21) from clean primitives, measured on art/concepts/tools/impact_6view.png side
# view (main decision: anvil and socket on one axis; more GREY, red only on rubber parts). Game size (ref_tools/index.md):
# head ~0.8 long, 1.15 tall with the battery; socket for the 21 mm wheel nut ~0.24 long.
# Real layout (DeWalt / Milwaukee / Ryobi mix): short barrel, silver hammer case nose with screws, square anvil + impact
# socket, pistol grip with rubber overmould, trigger + forward/reverse button above it, LED below the nose, battery pack
# under the grip with 4 charge LEDs, vents at the back of the barrel.
# Build frame (= the concept): socket points +Y (front), up +Z, width X; origin = battery bottom centre.
#   blender --background --factory-startup --python build_impact.py -- <out_dir> [palette.json]
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


AXZ = 0.96                         # barrel / socket axis height
TIP_Y = 0.66
P.reset()
grey = P.mat("body", C("body", "#7C7F84"), 0.55, 0.05)
rubber = P.mat("rubber", C("rubber", "#D8322C"), 0.75, 0.0)
silver = P.mat("nose", C("nose", "#C3C6C9"), 0.45, 0.60)       # satin, same casual finish as the parts
black = P.mat("black", C("black", "#262628"), 0.60, 0.0)
sock = P.mat("socket", C("socket", "#2E2F31"), 0.50, 0.50)      # black impact socket (chrome-moly, black oxide)
parts = []


def rr_ring(hx, hz, cr, y, zc, k=4, step=0.2, d=0.0):
    pts = W.densify(W.rrect_pts(hx, hz, cr, k), step)
    if abs(d) > 1e-9:
        pts = W.offset_outline(pts, d)
    return [Vector((x, y, zc + z)) for x, z in pts]


# barrel (grey): rounded-square section lofted along Y; rear rubber bumper with a rounded end
HX, HZ, CR = 0.205, 0.182, 0.10
rings = [rr_ring(HX, HZ, CR, y, AXZ, d=dd) for y, dd in ((-0.27, -0.01), (-0.26, 0.0), (0.12, 0.0), (0.17, -0.02))]
parts.append(W.loft("barrel", rings, material=grey))
cap = []
for y, dd in ((-0.25, 0.012), (-0.36, 0.012), (-0.405, -0.004), (-0.43, -0.03), (-0.442, -0.07)):
    cap.append(rr_ring(HX, HZ, CR, y, AXZ, d=dd))
parts.append(W.loft("rear", cap, material=rubber))
# silver hammer-case nose (lathe about Y) + square anvil + socket
parts.append(W.revolve_x("nose", [(0.0, 0.10), (0.172, 0.10), (0.172, 0.22), (0.150, 0.31), (0.110, 0.355), (0.0, 0.355)], 24, closed=False,
                         material=silver, center=(0, 0, AXZ), axis='Y'))
anv = W.outline_slab("anvil", W.rrect_pts(0.036, 0.036, 0.008, 1), 0.35, 0.44, 0.0, 1, W.frame((0, 0, AXZ), (1, 0, 0), (0, 0, 1), (0, 1, 0)),
                     material=silver, rad_back=0.0, support=False)
anv.data.transform(Matrix.Identity(4))
parts.append(anv)
parts.append(W.revolve_x("socket", [(0.0, 0.425), (0.075, 0.425), (0.090, 0.43), (0.090, 0.52), (0.105, 0.545), (0.105, TIP_Y - 0.012),
                                     (0.095, TIP_Y), (0.0, TIP_Y)], 24, closed=False, material=sock, center=(0, 0, AXZ), axis='Y'))
# neck under the front of the barrel (LED + F/R button area)
nk = W.outline_slab("neck", W.round_corners([(-0.10, 0.70), (0.20, 0.74), (0.20, 0.86), (-0.10, 0.86)], 0.04, 2), -0.12, 0.12, 0.03, 2,
                    W.frame((0, 0, 0), (0, 1, 0), (0, 0, 1), (1, 0, 0)), material=grey)
parts.append(nk)
# pistol grip: rounded section lofted along the slanted grip line; rubber on the front / back faces, grey sides
top, bot = Vector((0, -0.06, 0.80)), Vector((0, -0.155, 0.30))
gax = (top - bot).normalized(); gfw = Vector((0, gax.z, -gax.y))      # grip axis, grip "forward"
grip_rings = []
for t, sx, sy in ((0.0, 0.10, 0.105), (0.25, 0.105, 0.112), (0.55, 0.108, 0.115), (0.85, 0.104, 0.110), (1.0, 0.10, 0.105)):
    c = bot.lerp(top, t)
    pts = W.densify(W.rrect_pts(sx, sy, 0.075, 4), 0.2)
    grip_rings.append([c + Vector((x, 0, 0)) + gfw * yy for x, yy in pts])
gr = W.loft("grip", grip_rings, material=grey)
P.assign_by(gr, lambda c_, n_: rubber if abs(n_.dot(gfw)) > 0.55 and abs(n_.dot(gax)) < 0.9 else None)
parts.append(gr)
# trigger (black, side profile slab) and forward / reverse button
trig = [(0.045, 0.73), (0.06, 0.62), (0.11, 0.60), (0.14, 0.64), (0.13, 0.73)]
parts.append(W.outline_slab("trigger", W.round_corners(trig, 0.02, 2), -0.035, 0.035, 0.01, 1, W.frame((0, 0, 0), (0, 1, 0), (0, 0, 1), (1, 0, 0)),
                            material=black))
parts.append(W.revolve_x("fr_btn", [(0.0, -0.135), (0.026, -0.135), (0.03, -0.125), (0.03, 0.125), (0.026, 0.135), (0.0, 0.135)], 12,
                         closed=False, material=black, center=(0, 0.08, 0.80), axis='X'))
# battery foot (grey) + battery pack (black) with a latch
parts.append(W.outline_slab("foot", W.densify(W.rrect_pts(0.19, 0.27, 0.06, 3, cx=0.0, cy=-0.03), 0.3), 0.24, 0.35, 0.025, 2,
                            W.frame((0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1)), material=grey, rad_back=0.0, support=False))
parts.append(W.outline_slab("battery", W.densify(W.rrect_pts(0.225, 0.325, 0.06, 3, cx=0.0, cy=0.015), 0.3), 0.0, 0.26, 0.035, 2,
                            W.frame((0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1)), material=black))
parts.append(W.outline_slab("latch", W.rrect_pts(0.07, 0.025, 0.012, 1), 0.0, 0.035, 0.006, 1,
                            W.frame((0, 0.335, 0.235), (1, 0, 0), (0, 0, 1), (0, 1, 0)), material=black, support=False))
ob = W.join("ImpactWrench", parts)
print("tris before finish", P.tris(ob))


def paint(Pm, Nm, base, orm, mask):
    """vents on the barrel sides, nose screws, LED (white), 4 green charge LEDs, hex opening of the socket"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    side = mask & (np.abs(Nm[..., 0]) > 0.8)
    for k in range(5):
        slot = side & (np.abs(y - (-0.22 + 0.035 * k)) < 0.009) & (np.abs(z - AXZ) < 0.07)
        base[slot] = hexf("#2A2B2D")
    front = mask & (Nm[..., 1] > 0.6)
    for sx in (-1, 1):
        for sz in (-1, 1):
            scr = front & (np.hypot(x - sx * 0.125, z - (AXZ + sz * 0.125)) < 0.018) & (y > 0.2)
            base[scr] = hexf("#2A2B2D")
    led = front & (np.abs(x) < 0.04) & (np.abs(z - 0.785) < 0.016) & (y > 0.18) & (y < 0.22)
    base[led] = hexf("#F4F1E6"); orm[led, 1] = 0.2
    for k in range(4):
        g = front & (np.abs(x - (-0.09 + 0.06 * k)) < 0.018) & (np.abs(z - 0.10) < 0.014) & (y > 0.33)
        base[g] = hexf(C("led_green", "#7BE36F"))
    tip = mask & (Nm[..., 1] > 0.9) & (y > TIP_Y - 0.002)
    ang = np.arctan2(z - AXZ, x); rr = np.hypot(x, z - AXZ)
    hexr = 0.058 / np.cos(((ang + np.pi / 6) % (np.pi / 3)) - np.pi / 6)
    base[tip & (rr < hexr)] = hexf("#0B0B0C")
    return base, orm


P.finish(ob, os.path.join(OUT, "ImpactWrench"), tex=1024, pivot_bottom=False, weighted=False, smooth_angle=50, paint=paint, recalc_normals=False)
rb = W.to_roblox
gc = bot.lerp(top, 0.5)
data = {"tool": "Impact wrench (cordless 1/2 inch, 21 mm wheel-nut socket)", "units": "stud",
        "space": "mesh local, Roblox axes (+Y up, -Z = the socket direction / front, +X = the tool's left side when the socket points away from you); origin = battery bottom centre",
        "Grip": {"pos": rb(tuple(gc)), "axis": rb(tuple(gax)), "secondary_axis": rb(tuple(gfw)),
                 "note": "middle of the pistol grip. Axis = up along the grip (battery -> barrel), SecondaryAxis = toward the trigger (front). R15 right hand, index finger on the trigger."},
        "Trigger": {"pos": rb((0, 0.11, 0.66))},
        "Socket_Tip": {"pos": rb((0, TIP_Y, AXZ)), "axis": rb((0, 1, 0)), "note": "open end of the socket = where the wheel nut sits; axis points out of the socket"},
        "Anvil": {"pos": rb((0, 0.40, AXZ))},
        "size": "1.10 long (with socket) x 1.145 tall x 0.45 wide"}
json.dump(data, open(os.path.join(OUT, "impact_attachments.json"), "w", encoding="utf-8"), indent=1)
print("ok")
