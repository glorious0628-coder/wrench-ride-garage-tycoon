# Drain pan (wr 3D helper 10-22): moulded plastic oil / coolant catch pan with a perforated splash screen, a pour spout at
# one short end, a hand-slot handle at the other and four rubber feet - after art/concepts/tools/drain_pan_6view.png
# (left / right view for length + height, top view for the plan; its front / back views are drawn at another scale).
# Real (notes/research/ref_tools_v2/drain_01..04 = Bing image screenshots; ref_tools_firstbatch 5): low wide
# polyethylene tub 45-60 cm x 30-45 cm x 12-20 cm, thick rolled rim, pour spout on one end, moulded carry handle, a
# mesh / perforated cover on some, rubber feet on the low-profile ones.
# Game: body 1.60 x 1.00 stud (0.45 x 0.28 m), rim 0.44 tall, whole piece 1.95 long. Not scaled up like the hand tools:
# it is bay equipment that goes under the car (a car's belly is ~0.5 stud above the floor).
# Build frame: long axis = Y, the SPOUT end at +Y (exports to Roblox -Z = the concept "front" view), handle end at -Y,
# +Z up, origin = centre of the floor plan at the feet's bottom (z = 0).
#   blender -b --factory-startup --python build_drain_pan.py -- <out_dir> [palette.json]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tv2_lib as T
from tv2_lib import W, P, Vector, Matrix, np, rb

OUT, PAL = T.args()
C = lambda n, d: PAL.get(n, d)
A, B, CR = 0.80, 0.50, 0.17          # rim (d = 0) half length (Y), half width (X), corner radius
RIM = 0.44                           # rim top
ZS = 0.240                           # splash-screen shelf height (the squash base at the spout notch) - screen sits 0.18 under the rim
K, NX, NY = 3, 6, 3                  # corner arc segments, subdivisions of the back short edge / of the long edges
TOPX = [0.25, 0.15, 0.10, 0.05, 0.0]   # front (spout) edge: x of the extra points (mirrored), finer at the notch
N_HI, N_LO = 0.065, 0.125            # notch plateau radius / end of its sloped sides

P.reset()
tubm = P.mat("tub", C("tub", "#EF6A1A"), 0.55, 0.0)
grm = P.mat("screen", C("screen", "#45474C"), 0.60, 0.0)
rub = P.mat("rubber", C("rubber", "#2A2B2E"), 0.85, 0.0)


def ring_pts(d, cr_min=0.035):
    """rounded-rectangle ring (CCW, starts at the +X side of the +Y end) with the same point count for every d"""
    hw, hh = B + d, A + d
    cr = max(CR + d, cr_min)
    out = []
    cx, cy = hw - cr, hh - cr
    for sx, sy, a0, edge in ((1, 1, 0, "top"), (-1, 1, 90, "left"), (-1, -1, 180, "bottom"), (1, -1, 270, "right")):
        for j in range(K + 1):
            a = math.radians(a0 + 90 * j / K)
            out.append((sx * cx + cr * math.cos(a), sy * cy + cr * math.sin(a)))
        if edge == "top":                 # spout end: fixed x list, dense around the notch
            xs = sorted([x for x in TOPX if x < cx - 0.02] + [-x for x in TOPX if 0 < x < cx - 0.02] + [0.0], reverse=True)
            out += [(x, hh) for x in xs]
            continue
        if edge == "left":
            n, p0, p1 = NY, (-hw, cy), (-hw, -cy)
        elif edge == "bottom":
            n, p0, p1 = NX, (-cx, -hh), (cx, -hh)
        else:
            n, p0, p1 = NY, (hw, -cy), (hw, cy)
        for j in range(1, n):
            t = j / n
            out.append((p0[0] + (p1[0] - p0[0]) * t, p0[1] + (p1[1] - p0[1]) * t))
    return out


def bump(x):
    """1 inside the notch (|x| < N_HI), 0 outside N_LO, smooth sides: the U notch in the front rim"""
    t = min(max((N_LO - abs(x)) / (N_LO - N_HI), 0.0), 1.0)
    return t * t * (3 - 2 * t)


def squash(x, y, z, base, smin):
    """the front rim sinks into a pour notch: z above `base` is squeezed by a factor going down to smin at the notch centre
    (outer wall: gentle, base 0.30, smin 0.48; inner wall + shelf: base = shelf height, smin 0.2 - both land at 0.36)"""
    if y > 0.45 and z > base:
        s = 1.0 - (1.0 - smin) * bump(x)
        z = base + (z - base) * s
    return z


# (z, d) rings: outside from the underside up over the rolled rim, then down the inside to the floor
OUTER = [(0.035, -0.072), (0.046, -0.056), (0.075, -0.045), (0.20, -0.034), (0.350, -0.017), (0.390, -0.006),
         (0.410, 0.014), (0.428, 0.025), (0.441, 0.012), (0.444, -0.008), (0.432, -0.027)]
INNER = [(0.404, -0.044), (0.372, -0.056), (ZS + 0.004, -0.062), (ZS - 0.004, -0.100), (0.17, -0.108), (0.100, -0.126),
         (0.088, -0.145)]
bm = bmesh.new()
rings = []
for z, d, base, smin in [(z, d, 0.30, 0.48) for z, d in OUTER] + [(z, d, ZS, 0.75) for z, d in INNER]:
    rings.append([bm.verts.new((x, y, squash(x, y, z, base, smin))) for x, y in ring_pts(d)])
n = len(rings[0])
for r0, r1 in zip(rings[:-1], rings[1:]):
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((r0[i], r0[j], r1[j], r1[i]))
for ring, z in ((rings[0], OUTER[0][0]), (rings[-1], INNER[-1][0])):
    c = bm.verts.new((0, 0, z))
    for i in range(n):
        bm.faces.new((ring[i], ring[(i + 1) % n], c))
tub = W._finish_bm("tub", bm, tubm)
parts = [tub]

# ---- pour spout: a U channel that continues the notch in the rim (same section at the wall), narrowing and dropping to a
# rounded tip, 0.04 thick, flat bottom + sloped sides like the notch
SP_Y0, SP_L = A - 0.030, 0.235
NSEC, NA = 4, 8
UH = 0.40                                  # flat bottom = this fraction of the half width
TH = 0.040


def ss(t):
    t = min(max(t, 0.0), 1.0)
    return t * t * (3 - 2 * t)


secs = []                                   # (y, half width, z_floor, z_lip)
for k in range(NSEC + 1):
    t = k / NSEC
    secs.append((SP_Y0 + SP_L * 0.78 * t, 0.136 - 0.052 * t, 0.373 - 0.036 * t, 0.428 - 0.075 * t))
for sgm in (0.55, 0.88):              # rounded tip: the width closes like a circle over the last 22 %
    tt = secs[NSEC]
    y = SP_Y0 + SP_L * (0.78 + 0.22 * sgm)
    secs.append((y, tt[1] * math.sqrt(max(1 - sgm * sgm, 0.0)) + 0.010, tt[2] - 0.006 * sgm, tt[3] - 0.012 * sgm))
bm = bmesh.new()
rows = []
for y, w, zf, zl in secs:
    uu = [2 * i / NA - 1 for i in range(NA + 1)]
    zin = [zf + (zl - zf) * ss((abs(u) - UH) / (1 - UH)) for u in uu]
    inner = [(w * u, z) for u, z in zip(uu, zin)]
    outer = [(w * u * 0.99, z - TH * (1.0 - 0.45 * abs(u) ** 3)) for u, z in zip(uu, zin)][::-1]
    rows.append([bm.verts.new((x, y, z)) for x, z in inner + outer])
m = len(rows[0])
for r0, r1 in zip(rows[:-1], rows[1:]):
    for i in range(m):
        j = (i + 1) % m
        bm.faces.new((r0[i], r0[j], r1[j], r1[i]))
for ring in (rows[0], rows[-1]):
    c = sum((v.co for v in ring), Vector()) / m
    cv = bm.verts.new(c)
    for i in range(m):
        bm.faces.new((ring[i], ring[(i + 1) % m], cv))
parts.append(W._finish_bm("spout", bm, tubm))
TIP_Y = SP_Y0 + SP_L

# ---- handle: flat D-loop tab on the -Y end at rim height (like the low D handles of real low-profile pans: no raised arch).
# Plan outline (u = along Y, v = across X) with a finger slot through it, 0.056 thick, flush with the rim top.
TAB_Z0, TAB_Z1 = 0.386, RIM + 0.002
TAB_U, TAB_HL, TAB_HW = -(A + 0.072), 0.088, 0.300      # centre along Y, half length (out from the wall), half width
tab_outer = W.rrect_pts(TAB_HL, TAB_HW, 0.055, 3, TAB_U, 0.0)
tab_slot = W.rrect_pts(0.026, 0.205, 0.024, 2, TAB_U - 0.004, 0.0)
tab = W.plate2d("handle", tab_outer, [tab_slot], TAB_Z0, TAB_Z1, 0.012, material=tubm, hole_chamfer=[True], back_chamfer=0.012)
tab.data.transform(Matrix.Rotation(-math.pi / 2, 4, 'Y'))        # native x -> +Z, native y (u) -> +Y, native z (v) -> -X
parts.append(tab)

# ---- splash screen: perforated plate resting on the shelf (dark grey), 0.022 thick
GZ0, GZ1 = ZS, ZS + 0.022
GX, GY, GCR = B - 0.080, A - 0.083, 0.100
g_outer = W.rrect_pts(GY, GX, GCR, 3)                              # (u = length, v = width)
COLS, ROWS = 5, 7
PX, PY = 0.165, 0.205
HR = 0.056                       # square hole, half side 0.040 (corner radius 0.056)
holes = []
for r in range(ROWS):
    for c in range(COLS):
        u = (r - (ROWS - 1) / 2) * PY
        v = (c - (COLS - 1) / 2) * PX + (0.0 if r % 2 == 0 else PX * 0.0)
        holes.append(W.circle_pts(u, v, HR, 4, a0=math.radians(45)))
gp = W.plate2d("screen", g_outer, holes, GZ0, GZ1, 0.006, material=grm, hole_chamfer=[False] * len(holes), back_chamfer=0.0)
# native x (thickness) -> +Z, native y (u = length) -> +Y, native z (v = width) -> -X
gp.data.transform(Matrix.Rotation(-math.pi / 2, 4, 'Y'))
parts.append(gp)

# ---- feet: orange boss + dark rubber pad at the four corners of the underside
for sx in (1, -1):
    for sy in (1, -1):
        fx, fy = sx * 0.32, sy * 0.575
        parts.append(P.cylinder("boss", 0.058, 0.044, (fx, fy, 0.028), axis='Z', segs=8, bevel=0.008, bsegs=1, material=tubm))
        parts.append(P.cylinder("pad", 0.044, 0.022, (fx, fy, 0.011), axis='Z', segs=8, bevel=0.0, bsegs=1, material=rub))

print("PARTS", {o.name: P.tris(o) for o in parts})
ob = W.join("DrainPan", parts)
print("tris before finish", P.tris(ob))
HOLE_Z = GZ1


def paint(Pm, Nm, base, orm, mask):
    """fine marks that need no triangles: a shallow recessed panel line on the underside, and the shadowed inside of the
    tub below the screen (floor + lower inner wall darker, so the screen's holes read as holes, not orange dots)"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    under = mask & (Nm[..., 2] < -0.9) & (np.abs(z - 0.035) < 0.004)
    edge = under & ((np.abs(np.abs(x) - 0.40) < 0.006) & (np.abs(y) < 0.66) | (np.abs(np.abs(y) - 0.66) < 0.006) & (np.abs(x) < 0.40))
    base[edge] = base[edge] * 0.82
    toward_in = Nm[..., 0] * x + Nm[..., 1] * y
    inside = mask & (z < ZS - 0.006) & ((Nm[..., 2] > 0.5) | (toward_in < -0.05)) & (np.abs(x) < B - 0.05) & (np.abs(y) < A - 0.05)
    shade = np.clip(0.16 + 0.8 * (z - 0.088) / 0.26, 0.16, 0.45)
    base[inside] = base[inside] * shade[inside][:, None] * np.array([1.0, 0.85, 0.75], np.float32)
    # baked ambient shadow on the inner wall between the screen and the rim: darker toward the screen = the well reads deep
    wall_up = mask & (z >= ZS - 0.006) & (z < 0.40) & (toward_in < -0.05) & (np.abs(Nm[..., 2]) < 0.7)
    ao = np.clip((z - ZS) / (0.40 - ZS), 0.0, 1.0)
    base[wall_up] = base[wall_up] * (0.55 + 0.45 * ao[wall_up])[:, None]
    return base, orm


T.finish(ob, OUT, "DrainPan", paint=paint, smooth=45)

# ---- attachments (Roblox axes: x, z, -y of the build frame)
data = {"tool": "Drain pan (plastic catch pan, splash screen, pour spout, flat D-loop handle)", "units": "stud",
        "space": "mesh local, Roblox axes (+Y up, -Z = the spout end = the concept 'front' view, +Z = the handle end, X = across the pan); origin = middle of the floor plan, feet at Y = 0 of the build",
        "Grip": {"pos": rb((0, TAB_U, (TAB_Z0 + TAB_Z1) / 2)), "axis": [1, 0, 0], "secondary_axis": [0, 0, -1],
                 "note": "the flat D-loop handle at the rim of the +Z end (fingers through the 0.05 slot, thumb on top). Axis (+X) = along the slot; SecondaryAxis = toward the pan body / spout (the way a carried pan points)."},
        "Catch": {"pos": rb((0, 0, GZ1)), "axis": [0, 1, 0], "size_xz": [round(2 * GX, 3), round(2 * GY, 3)],
                  "note": "centre of the splash screen = where the drain stream should land (screen top, 0.12 under the rim). Pan floor under the screen = 0.088 above the feet (dark well 0.21 deep)."},
        "Spout": {"pos": rb((0, TIP_Y, 0.337)), "axis": rb((0, 1, -0.25)), "width": 0.2,
                  "note": "pour lip (tip of the spout, 0.2 wide at the root). Axis = the way the liquid leaves when the pan is tipped."},
        "Floor": {"pos": rb((0, 0, 0)), "axis": [0, 1, 0], "note": "bottom of the four feet = the ground plane the pan sits on"},
        "Rim": {"top": RIM, "half_x": B, "half_z": A, "note": "rim top height = the highest point of the pan (the D-loop is flush with it): slides under anything higher than 0.45"},
        "capacity": "inside depth rim-to-floor 0.36, ~ 0.9 x 1.4 stud floor: about 16 L at real scale (1 stud = 0.28 m)",
        "size": "1.91 long (spout tip to handle loop) x 1.05 wide (rim) x 0.446 tall, body 1.60 x 1.00 x 0.44"}
T.write_json(os.path.join(OUT, "drain_pan_attachments.json"), data, ob)
print("ok")
