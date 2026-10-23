# Creeper / lie-down board (3D helper 10-22) - the bay's mechanic's creeper, hero-grade (seen big at the bottom of the
# UnderView screen), casual low-poly with round bevels, real structure (art/3d/creeper_v1/refs.md):
#   red square-tube steel frame (2 side rails + 3 cross members, black plastic end plugs) -> hardboard deck on the cross
#   members -> 2 red vinyl body cushions -> black padded headrest on the head end -> 6 swivel casters under the rails
#   (mount plate, swivel race, pressed fork with trail, axle, black PU wheel with grey hub).
# Mix of real ones (Torin TR6452 / Whiteside padded steel creepers, Sunex 8505B, Big Red plastic ones, Lisle 92102) +
# the interior concept (art/concepts/interior/interior_better_a.png: red board, red rails, black headrest).
# Size (refs.md / PROGRESS.md): 3.80 long x 2.00 wide (rails) stud, pad top 0.465, headrest top 0.585, wheels 0.21.
# Build frame: +Y = the head end (exports to Roblox -Z = LookVector), +Z up, X across; origin = floor centre (P.finish
# pivot_bottom). One mesh, one PBR material (base + ORM baked), like the other wr props.
#   blender -b --factory-startup -P build_creeper.py -- <out_dir>
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))   # tools/blender/wr
import wr_lib as W   # noqa: E402
from wr_lib import P  # noqa: E402
from mathutils import Vector, Matrix  # noqa: E402
import numpy as np  # noqa: E402

OUT = os.path.abspath(sys.argv[sys.argv.index("--") + 1]); os.makedirs(OUT, exist_ok=True)

# ---- dimensions (stud; 1 stud = 0.28 m)
RAIL_X, RAIL_S = 0.855, 0.09           # rail centre line (x), square tube side (1 in = 0.09 stud) -> 1.80 wide
RZ0 = 0.27; RZ1 = RZ0 + RAIL_S         # rail bottom / top
RAIL_Y = 1.86                          # rail ends (the plugs go over them)
CAP_Y0, CAP_Y1, CAP_S = 1.82, 1.90, 0.106   # end plug: from y 1.82 to 1.90, a hair bigger than the tube
CROSS_S, CROSS_Y = 0.07, (-1.62, 0.0, 1.62)
CZ1 = 0.355; CZ0 = CZ1 - CROSS_S       # cross members: top 0.355 = under the deck board
BX, BZ0, BZ1, BY = 0.790, 0.350, 0.376, 1.80     # deck board (hardboard): half width, z, half length
PX = 0.780; PZ0, PZ1 = 0.371, 0.478    # cushions: half width, bottom (0.005 into the board), top of the sides
CROWN = 0.014                          # cushion tops bulge this much in the middle (soft pad, not a slab)
FOOT_CUSH = (-1.79, -0.33)             # foot-end body cushion (y)
BODY_CUSH = (-0.29, 1.79)              # upper body cushion (y), the headrest sits on its head end
HX, HY, HZ0, HZ1 = 0.48, (1.12, 1.74), 0.476, 0.596   # headrest: half width, y range, bottom (into the cushion), top
HCROWN = 0.012
CASTER_Y = (-1.50, 0.0, 1.50)          # casters under both rails
WR, WW = 0.105, 0.080                  # wheel radius / width (2.3 in x 0.9 in)
TRAIL = 0.035                          # wheel axle behind the swivel (toward the foot, -Y)

P.reset()
red = P.mat("frame", "#A8221E", 0.48, 0.0)          # powder-coated steel, satin, darker than the pad (GPT r1: the
# bright glossy rail pulled the eye from the cushions where its edge fills the UnderView)
vinyl = P.mat("vinyl", "#BE201D", 0.60, 0.0)        # red vinyl cushions (deeper red)
black = P.mat("headrest", "#2A2A2D", 0.50, 0.0)     # black vinyl headrest
board = P.mat("board", "#38383B", 0.85, 0.0)        # hardboard deck (seen as the dark line under the cushions)
plug = P.mat("plug", "#1E1E20", 0.62, 0.0)          # black plastic tube plugs
zinc = P.mat("zinc", "#B9BBBE", 0.35, 0.65)         # zinc-plated caster plate / fork / axle
pu = P.mat("pu", "#2C2D30", 0.72, 0.0)              # black polyurethane wheel
hub = P.mat("hub", "#6C6E72", 0.50, 0.0)            # grey wheel hub

parts = []
# ---- frame: 2 side rails, 3 cross members (ends 0.025 into the rails), 4 end plugs
for sx in (1, -1):
    parts.append(P.rounded_box("rail", (RAIL_S, 2 * RAIL_Y, RAIL_S), (sx * RAIL_X, 0, (RZ0 + RZ1) / 2), 0.022, segs=2,
                               material=red))
    for sy in (1, -1):
        parts.append(P.rounded_box("plug", (CAP_S, CAP_Y1 - CAP_Y0, CAP_S), (sx * RAIL_X, sy * (CAP_Y0 + CAP_Y1) / 2,
                                   (RZ0 + RZ1) / 2), 0.026, segs=1, material=plug))
inner = RAIL_X - RAIL_S / 2 + 0.025
for y in CROSS_Y:
    parts.append(P.rounded_box("cross", (2 * inner, CROSS_S, CROSS_S), (0, y, (CZ0 + CZ1) / 2), 0.010, segs=1,
                               material=red))
# ---- deck board + cushions + headrest
parts.append(P.rounded_box("board", (2 * BX, 2 * BY, BZ1 - BZ0), (0, 0, (BZ0 + BZ1) / 2), 0.008, segs=1, material=board))
def crowned(ob, hx, cuts, crown):
    """cut the rounded box along X (planes x = cuts) and lift its upper half by crown * (1 - u^2) * t^2 (u = x / hx,
    t = height above the box middle / half height): a pad that bulges across, edges and bottom untouched"""
    bm = bmesh.new(); bm.from_mesh(ob.data)
    for c in cuts:
        bmesh.ops.bisect_plane(bm, geom=list(bm.verts) + list(bm.edges) + list(bm.faces), plane_co=(c, 0, 0),
                               plane_no=(1, 0, 0))
    zs = [v.co.z for v in bm.verts]; zm, hz = (min(zs) + max(zs)) / 2, (max(zs) - min(zs)) / 2
    for v in bm.verts:
        t = (v.co.z - zm) / hz
        if t > 0:
            u = min(abs(v.co.x) / hx, 1.0)
            v.co.z += crown * (1 - u * u) * t * t
    bm.to_mesh(ob.data); bm.free()
    return ob


for y0, y1 in (FOOT_CUSH, BODY_CUSH):
    parts.append(crowned(P.rounded_box("cushion", (2 * PX, y1 - y0, PZ1 - PZ0), (0, (y0 + y1) / 2, (PZ0 + PZ1) / 2),
                                       0.045, segs=3, material=vinyl), PX, (-0.42, 0.0, 0.42), CROWN))
parts.append(crowned(P.rounded_box("headrest", (2 * HX, HY[1] - HY[0], HZ1 - HZ0), (0, sum(HY) / 2, (HZ0 + HZ1) / 2), 0.05,
                                   segs=3, material=black), HX, (-0.24, 0.0, 0.24), HCROWN))


# ---- casters
def prism_x(name, pts_yz, x0, x1, material):
    """convex outline in the YZ plane (CCW seen from +X) extruded across X from x0 to x1"""
    bm = bmesh.new()
    a = [bm.verts.new((x0, y, z)) for y, z in pts_yz]
    b = [bm.verts.new((x1, y, z)) for y, z in pts_yz]
    n = len(pts_yz)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((a[i], a[j], b[j], b[i]))
    caps = [bm.faces.new(list(reversed(a))), bm.faces.new(b)]
    bmesh.ops.triangulate(bm, faces=caps, quad_method='BEAUTY', ngon_method='BEAUTY')
    return W._finish_bm(name, bm, material)


AZ = WR - 0.003                           # axle height = tread radius (wheel on the floor)
FORK_IN = WW / 2 + 0.0095                 # fork leg inner face (clear of the hub face at 0.040)
FORK_T = 0.014
PLATE = (0.130, 0.130, 0.018)
PZ_TOP = RZ0 + 0.004                      # plate top 0.004 into the rail bottom
RACE_Z1 = PZ_TOP - PLATE[2] + 0.002
RACE_Z0 = RACE_Z1 - 0.022
BR_Z1 = RACE_Z0 + 0.002; BR_Z0 = BR_Z1 - 0.016   # fork bridge (top 0.002 into the race)


def caster(cx, cy):
    out = []
    out.append(P.rounded_box("plate", PLATE, (cx, cy, PZ_TOP - PLATE[2] / 2), 0.007, segs=1, material=zinc))
    out.append(P.cylinder("race", 0.048, RACE_Z1 - RACE_Z0, (cx, cy, (RACE_Z0 + RACE_Z1) / 2), axis='Z', segs=8,
                          material=zinc))
    ay = cy - TRAIL
    out.append(P.rounded_box("bridge", (2 * (FORK_IN + FORK_T) + 0.008, 0.092, BR_Z1 - BR_Z0), (cx, cy - 0.012, (BR_Z0 + BR_Z1) / 2),
                             0.0, segs=1, material=zinc))
    rb = 0.030                            # leg boss radius round the axle
    top = BR_Z0 + 0.008                   # legs end 0.008 inside the bridge
    leg = [(cy + 0.026, top), (cy - 0.050, top), (ay - rb, AZ)]
    for k in range(1, 4):
        a = math.pi + math.pi * k / 4     # round bottom of the boss: 225, 270, 315 deg
        leg.append((ay + rb * math.cos(a), AZ + rb * math.sin(a)))
    leg.append((ay + rb, AZ))
    # CCW seen from +X: (y, z) going top-front -> top-back -> down the back -> round the bottom -> up the front
    for s in (1, -1):
        x0, x1 = (cx + FORK_IN, cx + FORK_IN + FORK_T) if s > 0 else (cx - FORK_IN - FORK_T, cx - FORK_IN)
        out.append(prism_x("leg", leg, x0, x1, zinc))
    out.append(P.cylinder("axle", 0.015, 2 * (FORK_IN + FORK_T) + 0.020, (cx, ay, AZ), axis='X', segs=8, material=zinc))
    # wheel: profile (r, h) round X - hub boss, flat side, rounded tread
    prof = [(0.0, 0.041), (0.034, 0.041), (0.086, WW / 2 - 0.006), (WR - 0.003, WW / 2 - 0.018),
            (WR - 0.003, -(WW / 2 - 0.018)), (0.086, -(WW / 2 - 0.006)), (0.034, -0.041), (0.0, -0.041)]
    wh = W.revolve_x("wheel", prof, 12, material=[pu, hub], closed=False, center=(cx, ay, AZ), a0=math.pi / 12)
    for p in wh.data.polygons:            # hub faces (near the axle) grey
        c = p.center
        r = math.hypot(c.y - ay, c.z - AZ)
        p.material_index = 1 if r < 0.04 else 0
    out.append(wh)
    return out


for sx in (1, -1):
    for y in CASTER_Y:
        parts += caster(sx * RAIL_X, y)

for o in parts:
    o.data.update()
print("PARTS", len(parts), "tris", sum(P.tris(o) for o in parts))
ob = W.join("Creeper", parts)
print("tris before finish", P.tris(ob))

SEAM = 0.032          # stitched piping line this far in from the cushion / headrest top edges
CUSH = [(PX, FOOT_CUSH, PZ1), (PX, BODY_CUSH, PZ1), (HX, HY, HZ1)]


def paint(Pm, Nm, base, orm, mask):
    """marks that need no triangles: the stitched seam (piping) round the top of each cushion + the headrest, a soft
    darker band where the cushions meet (shadow in the gap)"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    up = mask & (Nm[..., 2] > 0.85)
    for hx, (y0, y1), zt in CUSH:
        on = up & (z > zt - 0.004) & (z < zt + 0.02) & (np.abs(x) < hx) & (y > y0) & (y < y1)
        d = np.minimum(hx - np.abs(x), np.minimum(y - y0, y1 - y))
        seam = on & (np.abs(d - SEAM) < 0.005)
        base[seam] = base[seam] * 0.62
        orm[seam, 1] = np.minimum(orm[seam, 1] + 0.15, 1.0)
    # wheel hubs: grey disc (r 0.058) on both wheel faces, no extra ring of triangles
    hubc = np.array([0x6C, 0x6E, 0x72], np.float32) / 255
    for sx in (1, -1):
        for cy in CASTER_Y:
            cx, ay = sx * RAIL_X, cy - TRAIL
            side = mask & (np.abs(Nm[..., 0]) > 0.6) & (np.abs(x - cx) < WW / 2 + 0.003)
            r = np.hypot(y - ay, z - AZ)
            h = side & (r < 0.058)
            base[h] = hubc
            rim = side & (np.abs(r - 0.058) < 0.004)
            base[rim] = hubc * 0.6
    return base, orm


P.finish(ob, os.path.join(OUT, "Creeper"), tex=1024, smooth_angle=50, weighted=False, pivot_bottom=True, paint=paint,
         recalc_normals=False)
co = np.array([v.co[:] for v in ob.data.vertices])
lo, hi = co.min(0), co.max(0)
info = {"name": "Creeper", "tris": P.tris(ob), "units": "stud (1 stud = 0.28 m)",
        "size_x_y_z_roblox": [round(float(hi[0] - lo[0]), 3), round(float(hi[2] - lo[2]), 3), round(float(hi[1] - lo[1]), 3)],
        "space": "Roblox axes: +Y up, -Z = head end (headrest), origin = floor centre (wheels at Y 0)",
        "mesh_bbox_centre": [0.0, round(float(hi[2] - lo[2]) / 2, 4), 0.0],
        "pad_top": PZ1, "headrest_top": HZ1, "headrest_z_roblox": [-HY[1], -HY[0]], "rail_top": RZ1,
        "lying_note": "R15 lying on its back: back on pad_top (root centre = pad_top + 0.5), head top about 0.12 inside the head end (Roblox z -1.78), legs out past the foot end from mid-thigh"}
json.dump(info, open(os.path.join(OUT, "creeper_info.json"), "w"), indent=1)
print("INFO", info)
