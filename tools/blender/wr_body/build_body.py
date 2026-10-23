# Sedan body grey shape (wr-3d-body, 10-21): Body/Shell, Body/Glass, Body/Hood, Body/Bumper_F, Body/Bumper_R, Chassis.
#   blender --background --factory-startup --python tools/blender/wr_body/build_body.py -- <A|B> <out_dir> [all|surface]
# A = car_spec heights (hood hinge (0, 3.05, -3.85)), B = concept heights (hood ~0.8 higher) for the comparison.
# One smooth outer surface (body_shape.py: rings + end caps, every feature line a row) is cut along clean lines into
# the parts (rows, stations, planes; wheel arches = 72 tangent planes; grille openings = planes along s), every panel
# gets a small gap at its seams and a real thickness (solidify -> closed, no back faces from inside / through the
# arches), the inner skins are thinned (collapse decimate, outer skin untouched), then details (mirrors, handles,
# grille / diffuser pockets) and the chassis. Export: one grey GLB per part in car coords (Roblox local: +Y up,
# front -Z, origin = ground between the axles) + all parts in one GLB for review + <part>_attachments.json + stats.
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import body_shape as BS
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

argv = sys.argv[sys.argv.index("--") + 1:]
VAR = argv[0]
OUT = os.path.abspath(argv[1])
STAGE = argv[2] if len(argv) > 2 else "all"
os.makedirs(OUT, exist_ok=True)
shape = BS.Shape(BS.SPEC_A if VAR == "A" else BS.SPEC_B)

# ------------------------------------------------------------------ seams (car coords: x, Y, s) -------------------
if VAR == "A":
    CUT = dict(hood_front_Y=2.70, lamp_bot_F=2.44, bumper_top_R=2.45, lamp_R=(3.35, 3.58), hinge_Y=3.05)
else:
    CUT = dict(hood_front_Y=3.08, lamp_bot_F=2.80, bumper_top_R=2.62, lamp_R=(3.45, 3.70),
               hinge_Y=round(shape.top_full(-3.85) - 0.05, 2))
fb = shape.f_belt
CUT.update(
    hood_rear=-4.05 if VAR == "B" else -3.85, ws_base=-3.78, hinge_Z=-3.85, header=-0.55, roof_rear=5.0, rg_base=6.97,
    lamp_end_F=-7.35, lamp_end_R=7.55,
    bseam_F=((-7.35, CUT["lamp_bot_F"]), (-6.15, 1.90)),     # slanted front bumper / fender seam, side view (s, Y)
    bseam_R=((7.55, CUT["bumper_top_R"]), (6.20, 1.88)),
    door_F=-3.30, door_B=0.30, door_bot=0.90,
    door_R=((3.40, 0.90), (3.85, fb(3.85))) if VAR == "A" else ((3.22, 0.90), (3.72, fb(3.72))),
    glass_F=-2.90 if VAR == "A" else -3.05, bpil=(0.12, 0.48), divider=(2.88, 3.00),
    quarter=((4.25, fb(4.25)), (3.85, shape.top_full(3.85) - 0.48)),
    trunk_x=2.75,
)
lb = CUT["lamp_bot_F"]
# openings in the bumpers (front-view polygons (x, Y), right half; mirrored) -> pocket inserts behind them
OPEN_F = {
    "grille_up": [(0.0, lb - 0.20), (2.25, lb - 0.20), (2.25, lb - 0.05), (0.0, lb - 0.05)],      # thin upper grille
    "intake": [(0.0, 0.98), (2.45, 0.98), (2.02, 1.86), (0.0, 1.86)] if VAR == "A" else
              [(0.0, 1.00), (2.50, 1.00), (2.05, 2.02), (0.0, 2.02)],                              # big lower intake
    "slot": [(3.22, 1.06), (3.40, 1.06), (3.40, 1.78), (3.22, 1.78)],                               # corner slots
}
OPEN_R = {
    "diffuser": [(0.0, 0.74), (2.55, 0.74), (2.40, 1.10), (0.0, 1.10)] if VAR == "A" else
                [(0.0, 1.52), (2.40, 1.52), (2.25, 1.80), (0.0, 1.80)],
    "reflector": [(3.02, 1.30), (3.16, 1.30), (3.16, 1.86), (3.02, 1.86)] if VAR == "A" else
                 [(2.92, 1.95), (3.06, 1.95), (3.06, 2.38), (2.92, 2.38)],
}
R_CORNER, R_BELT, R_DLO, R_ROOFIN = BS.ROW["corner"], BS.ROW["belt"], BS.ROW["dlo"], BS.ROW["roofin"]
if VAR == "A":
    ARCH_R, ARCH_C, TYRE_D, TYRE_W = 1.45, 1.20, 2.40, 0.90
else:                               # main 10-21: wheels +15 % -> tyre 2.75 (x1.146), centre Y 1.375, arch 1.525
    ARCH_R, ARCH_C, TYRE_D, TYRE_W = 1.525, 1.375, 2.75, 1.03
WHEEL_S = (-5.0, 5.0)
GAP = 0.035                       # panel gap (total)
THK = 0.07                        # panel thickness
SEAM_ST = [CUT[k] for k in ("hood_rear", "ws_base", "header", "roof_rear", "rg_base", "lamp_end_F", "lamp_end_R",
                            "door_F", "door_B", "glass_F")] + list(CUT["bpil"]) + list(CUT["divider"])


def BL(x, Y, s):
    return Vector((x, -s, Y))


def CAR(v):
    return (v.x, v.z, -v.y)       # -> (x, Y, s)


bpy.ops.wm.read_homefile(use_empty=True)
sc = bpy.context.scene

# ------------------------------------------------------------------ 1. outer surface -----------------------------
st = BS.stations(shape, extra=SEAM_ST)
rings = [BS.ring(shape, s) for s in st]
NJ = len(rings[0])
bm = bmesh.new()
L_kseg = bm.faces.layers.int.new("kseg"); L_cap = bm.faces.layers.int.new("cap")
V = [[bm.verts.new(BL(r[j][0], r[j][1], s)) for j in range(NJ)] for s, r in zip(st, rings)]
for i in range(len(st) - 1):
    for j in range(NJ):
        f = bm.faces.new((V[i][j], V[i][(j + 1) % NJ], V[i + 1][(j + 1) % NJ], V[i + 1][j]))
        f[L_kseg] = j if j < BS.NH - 1 else NJ - 1 - j
        f[L_cap] = 0


def add_cap(i_ring, front):
    G = BS.cap_grid(rings[i_ring], st[i_ring], 0.03, front=front)
    M, N = G.shape[0] - 1, G.shape[1] - 1
    R = V[i_ring]; nr = NJ
    bl, br, tl = nr - BS.NB, BS.NB, nr - BS.NB - BS.NS_
    VV = [[None] * (N + 1) for _ in range(M + 1)]
    for a in range(M + 1):
        VV[a][0] = R[(bl + a) % nr]; VV[a][N] = R[(tl - a) % nr]
    for b in range(N + 1):
        VV[0][b] = R[(bl - b) % nr]; VV[M][b] = R[br + b]
    for a in range(1, M):
        for b in range(1, N):
            x, Y, s = G[a, b]
            VV[a][b] = bm.verts.new(BL(x, Y, s))
    for a in range(M):
        for b in range(N):
            f = bm.faces.new((VV[a][b], VV[a + 1][b], VV[a + 1][b + 1], VV[a][b + 1]))
            f[L_kseg] = -1; f[L_cap] = 1 if front else 2


# shoulder crease = a crisp character line (Accord-like), headlamp -> tail lamp: sharp edges along its middle row
CR_MID = BS.ROW["crease0"] + 1
for i in range(len(st) - 1):
    if -7.45 < st[i] and st[i + 1] < 7.6:
        for j in (CR_MID, NJ - CR_MID):
            e = bm.edges.get((V[i][j], V[i + 1][j]))
            if e is not None:
                e.smooth = False

add_cap(0, True)
add_cap(len(st) - 1, False)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
print("outer surface: stations", len(st), "faces", len(bm.faces))
OUTER_BVH = BVHTree.FromBMesh(bm)


def surf_s(x, Y, front=True):
    """outer surface s at (x, Y) seen from the front (or rear)"""
    if front:
        h = OUTER_BVH.ray_cast(BL(x, Y, -12.0), Vector((0, -1, 0)))     # towards +s
    else:
        h = OUTER_BVH.ray_cast(BL(x, Y, 12.0), Vector((0, 1, 0)))      # towards -s
    return None if h[0] is None else -h[0].y


def surf_x(Y, s, side=1):
    h = OUTER_BVH.ray_cast(BL(side * 8.0, Y, s), Vector((-side, 0, 0)))
    return None if h[0] is None else h[0].x


# ------------------------------------------------------------------ 2. seam cuts ---------------------------------
def fc(f):
    return CAR(f.calc_center_median())


def bisect(no, co, pred):
    """cut with a plane (car coords normal (nx, nY, ns), point (x, Y, s)) only through the faces pred(centre, f)"""
    faces = [f for f in bm.faces if pred(fc(f), f)]
    if not faces:
        return
    edges = list({e for f in faces for e in f.edges}); verts = list({v for f in faces for v in f.verts})
    bmesh.ops.bisect_plane(bm, geom=faces + edges + verts, dist=1e-6, plane_co=BL(*co), plane_no=BL(*no))


def plane_sY(p0, p1):
    """plane containing the X axis through side-view points p0=(s, Y), p1; normal points to +s (rear)"""
    ds, dY = p1[0] - p0[0], p1[1] - p0[1]
    n = Vector((0, -ds, dY)).normalized()          # (x, Y, s)
    if n.z < 0:
        n = -n
    return (n.x, n.y, n.z), (0.0, p0[1], p0[0])


def side_of(c, plane):
    n, p = plane
    return (c[0] - p[0]) * n[0] + (c[1] - p[1]) * n[1] + (c[2] - p[2]) * n[2]


PL_bF = plane_sY(*CUT["bseam_F"])
PL_bR = plane_sY(*CUT["bseam_R"])
PL_dR = plane_sY(*CUT["door_R"])
PL_q = plane_sY(*CUT["quarter"])
hf = CUT["hood_front_Y"]
bisect((0, 1, 0), (0, hf, 0), lambda c, f: c[2] < -6.6)
bisect((0, 1, 0), (0, lb, 0), lambda c, f: c[2] < -6.4)
bisect(*PL_bF, lambda c, f: -7.8 < c[2] < -5.6 and c[1] < lb + 0.15)
bisect((0, 1, 0), (0, CUT["bumper_top_R"], 0), lambda c, f: c[2] > 6.0)
for yv in CUT["lamp_R"]:
    bisect((0, 1, 0), (0, yv, 0), lambda c, f: c[2] > 7.2)
bisect(*PL_bR, lambda c, f: 5.6 < c[2] < 7.9 and c[1] < CUT["bumper_top_R"] + 0.15)
for sx in (1, -1):
    bisect((1, 0, 0), (sx * CUT["trunk_x"], 0, 0), lambda c, f: c[2] > 6.8 and c[1] > CUT["bumper_top_R"] - 0.05)
bisect((0, 1, 0), (0, CUT["door_bot"], 0), lambda c, f: -4.2 < c[2] < 4.0 and R_CORNER <= f[L_kseg] < R_BELT)
bisect(*PL_dR, lambda c, f: 3.0 < c[2] < 4.3 and R_CORNER <= f[L_kseg] < R_BELT)
bisect(*PL_q, lambda c, f: 3.4 < c[2] < 4.8 and R_BELT <= f[L_kseg] < R_DLO)
bisect((0, 1, 0), (0, 0.95, 0), lambda c, f: c[2] < -5.6)          # front bumper: black lower lip border
bisect((0, 1, 0), (0, 1.90, 0), lambda c, f: c[2] > 7.6)           # rear bumper: black diffuser band (rear face)
bisect((0, 0, 1), (0, 0, 7.95), lambda c, f: c[2] > 7.5 and c[1] < 1.95)
bisect((0, 1, 0), (0, 1.05, 0), lambda c, f: c[2] > 5.6)           # + thin black bottom strip along the sides

# wheel arches: 72 tangent planes of the arch circle (each only through the faces near its own arc piece)
NARC = 72
ARCHES = []
for ws in WHEEL_S:
    for k in range(NARC):
        th = 2 * math.pi * k / NARC
        n = (0.0, math.sin(th), math.cos(th)); p = (0.0, ARCH_C + ARCH_R * math.sin(th), ws + ARCH_R * math.cos(th))

        def near(c, f, th=th, ws=ws):
            if abs(c[0]) < 1.9:
                return False
            ds, dY = c[2] - ws, c[1] - ARCH_C
            r = math.hypot(ds, dY)
            if r > ARCH_R + 0.6 or r < ARCH_R - 0.7:
                return False
            a = math.atan2(dY, ds)
            da = (a - th + math.pi) % (2 * math.pi) - math.pi
            return abs(da) < 2.5 * math.pi / NARC
        bisect(n, p, near)
    ARCHES.append(ws)


def in_arch(c):
    if abs(c[0]) < 1.9:
        return False
    for ws in ARCHES:
        ds, dY = c[2] - ws, c[1] - ARCH_C
        if math.hypot(ds, dY) > ARCH_R + 0.1:
            continue
        if max(ds * math.cos(2 * math.pi * k / NARC) + dY * math.sin(2 * math.pi * k / NARC) for k in range(NARC)) < ARCH_R:
            return True
    return False


def poly_planes(poly):
    """front-view polygon (x, Y) -> list of (normal, point) planes along s (CCW polygon: inside = negative side)"""
    out = []
    n = len(poly)
    area = sum(poly[i][0] * poly[(i + 1) % n][1] - poly[(i + 1) % n][0] * poly[i][1] for i in range(n))
    for i in range(n):
        (x0, y0), (x1, y1) = poly[i], poly[(i + 1) % n]
        dx, dy = x1 - x0, y1 - y0
        nx, ny = (dy, -dx) if area > 0 else (-dy, dx)
        L = math.hypot(nx, ny)
        out.append(((nx / L, ny / L, 0.0), (x0, y0, 0.0)))
    return out


def full_poly(half):
    """mirror a right-half polygon that starts/ends on x = 0 (or a separate shape, then both copies)"""
    if any(abs(p[0]) < 1e-6 for p in half):
        right = [p for p in half]
        left = [(-x, y) for x, y in reversed(half) if abs(x) > 1e-6]
        pts = [p for p in right if abs(p[0]) > 1e-6]
        return [[(0.0, half[0][1])] + pts + [(0.0, half[-1][1])] + left]
    return [half, [(-x, y) for x, y in reversed(half)]]


def inside_poly(pt, planes):
    return all((pt[0] - p[0]) * n[0] + (pt[1] - p[1]) * n[1] < 0 for n, p in planes)


OPENINGS = []      # (name, front?, planes, polygon)
for front, table in ((True, OPEN_F), (False, OPEN_R)):
    for name, half in table.items():
        for poly in full_poly(half):
            pls = poly_planes(poly)
            OPENINGS.append((name, front, pls, poly))
            xs = [p[0] for p in poly]; ys = [p[1] for p in poly]
            for n_, p_ in pls:
                bisect(n_, p_, lambda c, f, front=front, xs=xs, ys=ys: ((c[2] < -6.6) if front else (c[2] > 6.6))
                       and min(xs) - 0.4 < c[0] < max(xs) + 0.4 and min(ys) - 0.4 < c[1] < max(ys) + 0.4)


def in_opening(c):
    for name, front, pls, poly in OPENINGS:
        if (front and c[2] < -6.6) or (not front and c[2] > 6.6):
            if inside_poly((c[0], c[1]), pls):
                return True
    return False


bmesh.ops.dissolve_degenerate(bm, dist=2e-4, edges=bm.edges)
bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=2e-4)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
print("after cuts faces", len(bm.faces))


# ------------------------------------------------------------------ 3. labels ------------------------------------
def label(f):
    x, Y, s = fc(f)
    k = f[L_kseg]; cap = f[L_cap]
    ax = abs(x)
    side = "L" if x < 0 else "R"
    bottom = (cap == 0 and 0 <= k < R_CORNER)
    if in_arch((x, Y, s)) or in_opening((x, Y, s)):
        return "DELETE"
    # front end
    if s < CUT["hood_rear"] and Y > hf and (cap == 1 or k >= R_BELT):
        return "HOOD"
    if s < CUT["lamp_end_F"] and lb < Y < hf:     # light bar under the hood edge; the fender tip runs up to the
        return "LAMP_F"                             # hood corner, so the hood / fender seam is one unbroken line
    if Y < lb and s < -5.0 and side_of((x, Y, s), PL_bF) < 0 and (not bottom or s < CUT["lamp_end_F"]):
        return "BUMPER_F"
    # rear end
    y0, y1 = CUT["lamp_R"]
    if s > CUT["lamp_end_R"] and y0 < Y < y1:
        return "LAMP_R"
    if Y < CUT["bumper_top_R"] and s > 5.0 and side_of((x, Y, s), PL_bR) > 0 and (not bottom or s > 8.27):
        return "BUMPER_R"
    if bottom:
        return "DELETE"
    if s > CUT["rg_base"] and ax < CUT["trunk_x"] and Y > CUT["bumper_top_R"]:
        return "TRUNK"
    # glass
    if k >= R_ROOFIN and (CUT["ws_base"] < s < CUT["header"] or CUT["roof_rear"] < s < CUT["rg_base"]):
        return "GLASS"
    if R_BELT <= k < R_DLO:
        b0, b1 = CUT["bpil"]; d0, d1 = CUT["divider"]
        if CUT["glass_F"] < s < b0 or b1 < s < d0 or (s > d1 and side_of((x, Y, s), PL_q) < 0):
            return "GLASS"
    # side panels
    if R_CORNER <= k < R_BELT:
        if s < CUT["door_F"]:
            if Y < CUT["door_bot"] and s > -5.0:      # rocker runs up to the arch (no sliver seam at the arch)
                return "BODY"
            return "FENDER_" + side
        if Y > CUT["door_bot"]:
            if CUT["door_F"] < s < CUT["door_B"]:
                return "DOOR_F" + side
            if s > CUT["door_B"] and side_of((x, Y, s), PL_dR) < 0:
                return "DOOR_R" + side
    return "BODY"


bm.faces.ensure_lookup_table()
LAB = [label(f) for f in bm.faces]
counts = {}
for l in LAB:
    counts[l] = counts.get(l, 0) + 1
print(counts)
L_lab = bm.faces.layers.int.new("lab")
NAMES = sorted(counts)
for f in bm.faces:
    f[L_lab] = NAMES.index(LAB[f.index])


# ---- colour stage: one material slot list for every part (codes measured on the concept: measure_colours.py) ----
_cj = os.path.join(os.path.dirname(os.path.normpath(OUT)), "colours.json")
COL = json.load(open(_cj)) if os.path.exists(_cj) else {}
C_ = lambda k, d: COL.get(k, {}).get("hex", d)
MATS = [  # name, hex (deliverable), roughness, metal, paint, emit
    ("paint", "#E6E6E6", 0.40, 0.0, 1, 0),        # neutral in the ColorMap; default paint = PAINT_DEFAULT
                                                  # (roughness 0.30 -> 0.40: roof highlight read before the colour)
    ("trim_black", C_("trim_black", "#262626"), 0.75, 0.0, 0, 0),
    ("glass", C_("glass", "#595E65"), 0.06, 0.0, 0, 0),
    ("light_white", C_("light_white", "#F8F7F7"), 0.25, 0.0, 0, 1),
    ("tail_red", C_("tail_red", "#F41D27"), 0.25, 0.0, 0, 1),
    ("lamp_inner", "#1A1A1C", 0.50, 0.0, 0, 0),
    ("gap", "#4A4C51", 0.60, 0.0, 0, 0),           # panel gaps: even dark grey, not a black line (GPT rule 2)
    ("inner", "#2E3034", 0.85, 0.0, 0, 0),
    ("chassis", "#2B2C2F", 0.85, 0.0, 0, 0),
    ("liner", "#1E1E20", 0.90, 0.0, 0, 0),
    ("slat", "#3A3B3E", 0.60, 0.0, 0, 0),
]
PAINT_DEFAULT = C_("paint", "#098FFC")
MI = {m[0]: i for i, m in enumerate(MATS)}
MAT_OBJS = []


def _lin(v):
    return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4


for nm, hx, ro, me_, pa, em in MATS:
    m = bpy.data.materials.new(nm); m.use_nodes = True
    c = tuple(int(hx[i:i + 2], 16) / 255 for i in (1, 3, 5))
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*[_lin(v) for v in c], 1); bsdf.inputs["Roughness"].default_value = ro
    bsdf.inputs["Metallic"].default_value = me_
    m["wr_hex"] = hx; m["wr_rough"] = ro; m["wr_metal"] = me_; m["wr_paint"] = pa; m["wr_emit"] = em
    m.use_backface_culling = True
    MAT_OBJS.append(m)


def outer_mat(lab, x, Y, s, k):
    if lab in ("HOOD", "TRUNK") or lab.startswith("FENDER") or lab.startswith("DOOR"):
        return MI["paint"]
    if lab == "BODY":
        if R_BELT <= k < R_DLO and CUT["hood_rear"] < s < CUT["rg_base"] - 0.02:
            return MI["trim_black"]          # window band: sail, B-pillar, divider, C-pillar (Altima-like black C-pillar)
        if k >= R_BELT and CUT["hood_rear"] < s < CUT["ws_base"]:
            return MI["trim_black"]          # cowl strip under the wipers
        return MI["paint"]
    if lab == "LAMP_F":
        return MI["light_white"]
    if lab == "LAMP_R":
        return MI["tail_red"]
    if lab == "BUMPER_F":
        return MI["trim_black"] if Y < 0.95 else MI["paint"]
    if lab == "BUMPER_R":
        return MI["trim_black"] if (Y < 1.05 or (Y < 1.90 and s > 7.95)) else MI["paint"]   # concept: black diffuser
                                                                    # band on the rear face, the corners stay blue
    if lab == "GLASS":
        return MI["glass"]
    return MI["inner"]


for f in bm.faces:
    x_, Y_, s_ = fc(f)
    f.material_index = outer_mat(LAB[f.index], x_, Y_, s_, f[L_kseg])
_gb = bm.copy()
bmesh.ops.delete(_gb, geom=[f for f in _gb.faces if LAB[f.index] != "GLASS"], context='FACES')
GLASS_BVH = BVHTree.FromBMesh(_gb); _gb.free()

L_seam = bm.edges.layers.int.new("seam")
KEEP_OUT = {NAMES.index(n) for n in ("DELETE", "GLASS", "LAMP_F", "LAMP_R") if n in NAMES}   # lamps slide under their
                                                     # neighbours (grown + sunk), so those seams need no shrink (and the
                                                     # dense nose faces would fold if shrunk)
for e in bm.edges:
    if len(e.link_faces) == 2:
        a, b = e.link_faces[0][L_lab], e.link_faces[1][L_lab]
        e[L_seam] = 1 if (a != b and a not in KEEP_OUT and b not in KEEP_OUT) else 0


def strip_layers(b):
    for coll in (b.faces.layers.int, b.faces.layers.string, b.edges.layers.int, b.verts.layers.int):
        for nm in [l.name for l in coll]:
            coll.remove(coll[nm])


if STAGE == "surface":
    import colorsys
    b3 = bm.copy(); strip_layers(b3)
    me = bpy.data.meshes.new("surface"); b3.to_mesh(me)
    ob = bpy.data.objects.new("surface", me); sc.collection.objects.link(ob)
    for i, nm in enumerate(NAMES):
        m = bpy.data.materials.new(nm); m.use_nodes = True
        c = colorsys.hsv_to_rgb(i / len(NAMES), 0.55, 0.85)
        m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (*c, 1)
        me.materials.append(m)
    for p_, f in zip(me.polygons, bm.faces):
        p_.material_index = NAMES.index(LAB[f.index]); p_.use_smooth = True
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, "sedan_body_%s_surface.blend" % VAR))
    print("SURFACE saved", NAMES)
    sys.exit(0)


# ------------------------------------------------------------------ 4. parts: gap, thickness -----------------------
def extract(labs):
    ids = {NAMES.index(l) for l in labs if l in NAMES}
    b2 = bm.copy()
    lay = b2.faces.layers.int["lab"]
    bmesh.ops.delete(b2, geom=[f for f in b2.faces if f[lay] not in ids], context='FACES')
    bmesh.ops.delete(b2, geom=[v for v in b2.verts if not v.link_faces], context='VERTS')
    return b2


def offset_boundary(b2, dist, only_seams=True):
    """move boundary vertices along the surface, perpendicular to the boundary: dist > 0 = shrink (panel gap),
    < 0 = grow (glass under the frame). only_seams: only edges that were a seam between two kept parts (arch /
    window / opening / bottom edges stay where they are). Returns {vert index: move vector}."""
    b2.normal_update()
    lay = b2.edges.layers.int.get("seam")
    moves = []
    for v in b2.verts:
        bnd = [e for e in v.link_edges if e.is_boundary and (not only_seams or (lay is not None and e[lay] == 1))]
        if not bnd or len(bnd) > 2:
            continue
        dirs = []
        for e in bnd:
            f = e.link_faces[0]
            t = (e.other_vert(v).co - v.co)
            if t.length < 1e-7:
                continue
            d = v.normal.cross(t.normalized())
            if d.length < 1e-6:
                continue
            d.normalize()
            if d.dot(f.calc_center_median() - v.co) < 0:
                d = -d
            dirs.append(d)
        if not dirs:
            continue
        m = sum(dirs, Vector())
        if m.length < 1e-6:
            continue
        m.normalize()
        c = max(m.dot(dirs[0]), 0.6)
        inner_len = [e.calc_length() for e in v.link_edges if not e.is_boundary]
        lim = 0.4 * min(inner_len) if inner_len else abs(dist)
        mag = min(abs(dist) / c, lim)
        moves.append((v, m * mag * (1 if dist > 0 else -1)))
    out = {}
    for v, m in moves:
        v.co += m; out[v.index] = m
    return out


def to_object(name, b2):
    me = bpy.data.meshes.new(name); b2.to_mesh(me); b2.free()
    ob = bpy.data.objects.new(name, me); sc.collection.objects.link(ob)
    for m in MAT_OBJS:
        me.materials.append(m)
    return ob


def set_mat(ob, idx_or_fn):
    """every polygon one slot (int) or fn(car centre (x, Y, s), car normal) -> slot"""
    for p in ob.data.polygons:
        if callable(idx_or_fn):
            p.material_index = idx_or_fn(CAR(p.center), CAR(p.normal))
        else:
            p.material_index = idx_or_fn
    return ob


def near_opening(x, Y, s):
    for _, front, pls, _ in OPENINGS:
        if (s < 0) != front or abs(s) < 6.6:
            continue
        if all((x - p_[0]) * n_[0] + (Y - p_[1]) * n_[1] < 0.06 for n_, p_ in pls):
            return True
    return False


def rim_mat(c, kind):
    x, Y, s = c
    if kind == "lamp":
        return MI["lamp_inner"]
    if abs(x) > 1.9 and any(abs(math.hypot(s - ws, Y - ARCH_C) - ARCH_R) < 0.07 for ws in WHEEL_S):
        return MI["paint"]                    # painted arch lip
    if near_opening(x, Y, s):
        return MI["trim_black"]               # grille / intake / slot / reflector opening lips
    if GLASS_BVH.find_nearest(BL(x, Y, s))[3] < 0.09:
        return MI["trim_black"]               # window seals
    if Y < 1.0:
        return MI["inner"]                    # open bottom edge
    return MI["gap"]                          # panel seams: even dark grey


def colour_panel(ob, kind):
    """after solidify (vertex groups 'inner' / 'rim' still on the object)"""
    gi = ob.vertex_groups["inner"].index
    inn = [any(g.group == gi and g.weight > 0.5 for g in v.groups) for v in ob.data.vertices]
    for p in ob.data.polygons:
        flags = [inn[i] for i in p.vertices]
        if not any(flags):
            continue                          # outer skin keeps the surface's slot
        if all(flags):
            p.material_index = MI["glass"] if kind == "glass" else (MI["lamp_inner"] if kind == "lamp" else MI["inner"])
        else:
            p.material_index = MI["glass"] if kind == "glass" else rim_mat(CAR(p.center), kind)


def activate(ob):
    for o in sc.objects:
        o.select_set(o == ob)
    bpy.context.view_layer.objects.active = ob


def solidify(ob, thk, thin_inner=0.0):
    """closed panel: outer skin stays, inner skin offset inward; thin_inner = keep this share of the inner skin"""
    ob.vertex_groups.new(name="inner"); ob.vertex_groups.new(name="rim")
    m = ob.modifiers.new("sol", 'SOLIDIFY'); m.thickness = thk; m.offset = -1.0
    m.use_rim = True; m.use_even_offset = False; m.use_quality_normals = True
    m.shell_vertex_group = "inner"; m.rim_vertex_group = "rim"
    activate(ob)
    bpy.ops.object.modifier_apply(modifier="sol")
    if thin_inner > 0:
        bmx = bmesh.new(); bmx.from_mesh(ob.data)
        dl = bmx.verts.layers.deform.active
        gi, gr = ob.vertex_groups["inner"].index, ob.vertex_groups["rim"].index
        ing = lambda v, g: g in v[dl] and v[dl][g] > 0.5
        inner_f = set(f for f in bmx.faces if all(ing(v, gi) for v in f.verts))
        prot = set(v for v in bmx.verts if ing(v, gr))
        edges = [e for e in bmx.edges if len(e.link_faces) == 2 and all(f in inner_f for f in e.link_faces)
                 and not (e.verts[0] in prot and e.verts[1] in prot)]
        verts = [v for v in set(v for f in inner_f for v in f.verts) if v not in prot]
        n0 = sum(len(f.verts) - 2 for f in bmx.faces)
        bmesh.ops.dissolve_limit(bmx, angle_limit=math.radians(6), use_dissolve_boundaries=False, verts=verts, edges=edges)
        bmesh.ops.triangulate(bmx, faces=[f for f in bmx.faces if len(f.verts) > 4], quad_method='BEAUTY', ngon_method='BEAUTY')
        print("  thin", ob.name, "tris", n0, "->", sum(len(f.verts) - 2 for f in bmx.faces))
        bmx.to_mesh(ob.data); bmx.free()
    colour_panel(ob, KIND.get(ob.name, "panel"))
    for g in list(ob.vertex_groups):
        ob.vertex_groups.remove(g)


KIND = {"p_LAMP_F": "lamp", "p_LAMP_R": "lamp", "Glass": "glass"}


def push(b2, dist):
    b2.normal_update()
    for v in b2.verts:
        v.co -= v.normal * dist


def panel(name, labs, gap=GAP / 2, thk=THK, sink=0.0, thin=0.3, only_seams=True):
    b2 = extract(labs)
    bmesh.ops.remove_doubles(b2, verts=b2.verts, dist=0.01)          # slivers from crossing cuts (T-junctions)
    bmesh.ops.dissolve_degenerate(b2, dist=0.01, edges=b2.edges)
    if gap:
        offset_boundary(b2, gap, only_seams)
    if sink:
        bmesh.ops.remove_doubles(b2, verts=b2.verts, dist=0.012)
        bmesh.ops.dissolve_degenerate(b2, dist=0.012, edges=b2.edges)
        push(b2, sink)
    strip_layers(b2)
    ob = to_object(name, b2)
    solidify(ob, thk, thin)
    return ob


def join(name, obs):
    obs = [o for o in obs if o is not None]
    for o in sc.objects:
        o.select_set(o in obs)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active; ob.name = name; ob.data.name = name
    return ob


shell_parts = []
for lab in ("BODY", "FENDER_L", "FENDER_R", "DOOR_FL", "DOOR_FR", "DOOR_RL", "DOOR_RR", "TRUNK"):
    if lab in NAMES:
        shell_parts.append(panel("p_" + lab, {lab}))
# lamps: sunk strips grown a little under their neighbours' edges (no see-through at the seams)
shell_parts.append(panel("p_LAMP_F", {"LAMP_F"}, gap=-0.03, sink=0.06, thk=0.06, only_seams=False))
shell_parts.append(panel("p_LAMP_R", {"LAMP_R"}, gap=-0.03, sink=0.06, thk=0.06, only_seams=False))
hood = panel("Hood", {"HOOD"})
bump_f = panel("Bumper_F", {"BUMPER_F"})
bump_r = panel("Bumper_R", {"BUMPER_R"})
b2 = extract({"GLASS"}); offset_boundary(b2, -0.03, only_seams=False); push(b2, 0.045); strip_layers(b2)
glass = to_object("Glass", b2); solidify(glass, 0.03, 0.0)       # thin slab: no inner thinning (would poke through)


# ------------------------------------------------------------------ 5. details -----------------------------------
def rbox(name, size, center, radius, segs=3, rot=None):
    """closed rounded box (car-coord size (sx, sY, ss), centre (x, Y, s))"""
    b = bmesh.new(); bmesh.ops.create_cube(b, size=1.0)
    sx, sY, ss = size
    bmesh.ops.scale(b, vec=Vector((sx, ss, sY)), verts=b.verts)
    if radius > 0.001:
        bmesh.ops.bevel(b, geom=list(b.verts) + list(b.edges), offset=min(radius, 0.49 * min(size)), segments=segs,
                        profile=0.5, affect='EDGES', clamp_overlap=True)
    if rot is not None:
        bmesh.ops.rotate(b, verts=b.verts, cent=(0, 0, 0), matrix=rot)
    bmesh.ops.translate(b, vec=BL(*center), verts=b.verts)
    bmesh.ops.recalc_face_normals(b, faces=b.faces)
    return to_object(name, b)


def blob(name, size, center, segs=16, rings=10, power=0.55):
    """rounded 'pillow' (superellipsoid) for mirror housings: size = full extents (x, Y, s)"""
    b = bmesh.new(); bmesh.ops.create_uvsphere(b, u_segments=segs, v_segments=rings, radius=1.0)
    for v in b.verts:
        x, y, z = v.co
        f = lambda t: math.copysign(abs(t) ** power, t)
        v.co = Vector((f(x) * size[0] / 2, f(y) * size[2] / 2, f(z) * size[1] / 2))
    bmesh.ops.translate(b, vec=BL(*center), verts=b.verts)
    bmesh.ops.recalc_face_normals(b, faces=b.faces)
    return to_object(name, b)


def box_lo_hi_(name, lo, hi, radius=0.03, segs=1):
    size = tuple(h - l for l, h in zip(lo, hi)); cen = tuple((l + h) / 2 for l, h in zip(lo, hi))
    return rbox(name, size, cen, radius, segs)


details_shell = []
# side mirrors on the sail (front lower corner of the front side window)
for sx in (-1, 1):
    ms = CUT["glass_F"]
    rb_ = BS.ring(shape, ms)[R_BELT]          # beltline row (window base) at the mirror station
    xs, mY = float(rb_[0]), float(rb_[1]) + 0.14
    hx = 3.97                          # housing centre: sticks out past the shoulder like the concept (front view)
    arm_l = hx - 0.22 - (xs - 0.08)
    details_shell.append(set_mat(rbox("mirror_arm", (arm_l, 0.17, 0.30), (sx * (xs - 0.08 + arm_l / 2), mY + 0.04, ms + 0.06), 0.06, 2), MI["trim_black"]))
    mcy = mY + 0.18      # housing: painted cap, black underside (concept)
    details_shell.append(set_mat(blob("mirror", (0.80, 0.53, 0.60), (sx * hx, mcy, ms + 0.12)),
                                 lambda c, n, mcy=mcy: MI["paint"] if c[1] > mcy + 0.02 else MI["trim_black"]))
    # black triangular base on the door (sail mount) under the arm - reads at small sizes (concept)
    details_shell.append(set_mat(rbox("mirror_base", (0.12, 0.34, 0.46), (sx * (xs + 0.02), mY + 0.02, ms + 0.08), 0.05, 2), MI["trim_black"]))
# door handles on the shoulder crease line (Accord-like straight line through the handles)
for hs in (-1.25, 2.25):
    hY = shape.f_crease(hs) - 0.12
    for sx in (-1, 1):
        xs = surf_x(hY, hs, sx)
        xs = abs(xs) if xs is not None else 3.75
        details_shell.append(set_mat(rbox("handle", (0.09, 0.11, 0.52), (sx * (xs + 0.015), hY, hs), 0.04, 2), MI["paint"]))


for sx in (-1, 1):
    for sj in (CUT["door_F"], CUT["door_B"]):
        details_shell.append(box_lo_hi_("jamb", (min(sx * 3.22, sx * 3.60), CUT["door_bot"] - 0.05, sj - 0.11),
                                         (max(sx * 3.22, sx * 3.60), shape.f_crease(sj) - 0.08, sj + 0.11)))
    (s0, y0), (s1, y1) = CUT["door_R"]
    y1n = shape.f_crease(3.75) - 0.08                    # stop under the shoulder (it tucks in above the crease)
    s1 = s0 + (s1 - s0) * (y1n - y0) / (y1 - y0); y1 = y1n
    L = math.hypot(s1 - s0, y1 - y0); ang = math.atan2(s1 - s0, y1 - y0)
    details_shell.append(rbox("jamb_r", (0.38, L, 0.22), (sx * 3.41, (y0 + y1) / 2, (s0 + s1) / 2), 0.03, 1,
                              rot=Matrix.Rotation(ang, 3, 'X')))


# backing strips behind the seams a pure side view looks straight through (both sides line up): door seams above the
# crease (the shoulder tucks in, so they sit further in) and the slanted bumper / fender seams
def strip_between(name, p0, p1, x0, x1, thick=0.16):
    (s0, y0), (s1, y1) = p0, p1
    L = math.hypot(s1 - s0, y1 - y0); ang = math.atan2(s1 - s0, y1 - y0)
    return rbox(name, (x1 - x0, L, thick), ((x0 + x1) / 2, (y0 + y1) / 2, (s0 + s1) / 2), 0.02, 1,
                rot=Matrix.Rotation(ang, 3, 'X'))


for sx in (-1, 1):
    for sj in (CUT["door_F"], CUT["door_B"]):
        y0 = shape.f_crease(sj) - 0.12; y1 = shape.f_belt(sj) - 0.04
        details_shell.append(box_lo_hi_("jamb_up", (min(sx * 2.92, sx * 3.10), y0, sj - 0.11), (max(sx * 2.92, sx * 3.10), y1, sj + 0.11)))
    (rs0, ry0), (rs1, ry1) = CUT["door_R"]
    yA = shape.f_crease(3.7) - 0.12; yB = shape.f_belt(3.75) - 0.04
    sA = rs0 + (rs1 - rs0) * (yA - ry0) / (ry1 - ry0); sB = rs0 + (rs1 - rs0) * (yB - ry0) / (ry1 - ry0)
    for x0, x1 in ((2.92, 3.10),):
        o = strip_between("jamb_up_r", (sA, yA), (sB, yB), x0, x1)
        if sx < 0:
            o.data.transform(Matrix.Scale(-1, 4, (1, 0, 0))); o.data.flip_normals()
        details_shell.append(o)
    for (pa, pb), xin in ((CUT["bseam_F"], (3.0, 3.36)), (CUT["bseam_R"], (3.0, 3.34))):
        # from the top of the seam down to where it meets the arch
        sa, ya = pa; sb, yb = pb
        o = strip_between("seam_back", (sa, ya - 0.02), (sb, yb), *xin)
        if sx < 0:
            o.data.transform(Matrix.Scale(-1, 4, (1, 0, 0))); o.data.flip_normals()
        details_shell.append(o)


    # rear bumper top seam where it runs along the rear corner (horizontal, Y = bumper_top_R)
    yb_ = CUT["bumper_top_R"]
    details_shell.append(box_lo_hi_("seam_back_r", (min(sx * 2.30, sx * 2.92), yb_ - 0.10, 7.45), (max(sx * 2.30, sx * 2.92), yb_ + 0.10, 7.95)))
    details_shell.append(box_lo_hi_("seam_back_r", (min(sx * 2.10, sx * 2.45), yb_ - 0.10, 7.95), (max(sx * 2.10, sx * 2.45), yb_ + 0.10, 8.32)))


def pocket(name, poly, front, recess, depth=0.30, wall=0.025, slats=0):
    """dark pocket behind a bumper opening: walls follow the curved surface (no gap to look into the bumper),
    flat back face `recess` behind the surface; optional horizontal slats; closed (solidified)"""
    # densify the polygon edges so the front ring follows the curved surface
    pts = []
    n = len(poly)
    for i in range(n):
        a, b = Vector(poly[i]), Vector(poly[(i + 1) % n])
        k = max(1, int((b - a).length / 0.30))
        for t in range(k):
            pts.append(a.lerp(b, t / k))
    cen = sum(pts, Vector((0, 0))) / len(pts)
    pts = [p + (p - cen).normalized() * 0.05 for p in pts]       # a little larger than the opening (under the lip)
    sgn = -1 if front else 1
    ss = []
    for p in pts:
        sv = surf_s(p.x, p.y, front)
        ss.append(sv if sv is not None else (-8.3 if front else 8.5))
    s_back = (max(ss) + recess) if front else (min(ss) - recess)
    b = bmesh.new()
    ring_f = [b.verts.new(BL(p.x, p.y, sv - sgn * 0.02)) for p, sv in zip(pts, ss)]
    ring_b = [b.verts.new(BL(p.x, p.y, s_back + (-sgn) * 0.0)) for p in pts]
    m = len(pts)
    for i in range(m):
        b.faces.new((ring_f[i], ring_f[(i + 1) % m], ring_b[(i + 1) % m], ring_b[i]))
    b.faces.new(list(reversed(ring_b)) if front else ring_b)
    # normals: into the pocket (towards the viewer outside)
    bmesh.ops.recalc_face_normals(b, faces=b.faces)
    eye = BL(cen.x, cen.y, -20 if front else 20)
    for f in b.faces:
        if f.normal.dot(eye - f.calc_center_median()) < 0:
            f.normal_flip()
    ob = to_object(name, b)
    m_ = ob.modifiers.new("sol", 'SOLIDIFY'); m_.thickness = wall; m_.offset = -1.0; m_.use_rim = True
    activate(ob); bpy.ops.object.modifier_apply(modifier="sol")
    obs = [ob]
    if slats:
        ys = [p[1] for p in poly]; y0, y1 = min(ys), max(ys)
        for k in range(1, slats + 1):
            yk = y0 + (y1 - y0) * k / (slats + 1)
            # x extent of the opening at this height
            xs_ = []
            for i in range(n):
                (xa, ya), (xb, yb) = poly[i], poly[(i + 1) % n]
                if (ya - yk) * (yb - yk) <= 0 and ya != yb:
                    xs_.append(xa + (yk - ya) * (xb - xa) / (yb - ya))
            if len(xs_) < 2:
                continue
            xa, xb = min(xs_) - 0.04, max(xs_) + 0.04
            obs.append(rbox(name + "_slat", (xb - xa, 0.07, 0.12), ((xa + xb) / 2, yk, s_back + sgn * 0.07), 0.03, 2))
    return obs


bumper_f_extra, bumper_r_extra = [], []
POCKET_MAT = {"reflector": "tail_red"}
for name, front, pls, poly in OPENINGS:
    _n0 = len(bumper_f_extra) + len(bumper_r_extra)
    if front:
        bumper_f_extra += pocket(name, poly, True, 0.10 if name != "intake" else 0.08, slats=2 if name == "intake" else 0)
    else:
        bumper_r_extra += pocket(name, poly, False, 0.08)
    for o in (bumper_f_extra + bumper_r_extra)[_n0:]:
        set_mat(o, MI["slat"] if "_slat" in o.name else MI[POCKET_MAT.get(name, "trim_black")])

for o in details_shell:
    if o.name.startswith(("jamb", "seam_back")):
        set_mat(o, MI["gap"])
shell = join("Shell", shell_parts + details_shell)
bump_f = join("Bumper_F", [bump_f] + bumper_f_extra)
bump_r = join("Bumper_R", [bump_r] + bumper_r_extra)


# ------------------------------------------------------------------ 6. chassis -----------------------------------
def box_lo_hi(name, lo, hi, radius=0.04, segs=1):
    """rounded box from car-coord corners lo=(x, Y, s), hi"""
    size = tuple(h - l for l, h in zip(lo, hi)); cen = tuple((l + h) / 2 for l, h in zip(lo, hi))
    return rbox(name, size, cen, radius, segs)


def liner(name, ws, side, r_in=ARCH_R - 0.02, r_out=ARCH_R + 0.03, x0=2.45, x1=3.64, a0=-32, a1=212, segs=34,
          r_hub=0.72):
    """wheel-arch liner: partial tube tucked under the arch lip + an inboard wall (annulus, hub hole for the
    knuckle / driveshaft; the wheel rim covers it) -> a pure side view does not look through the wheel wells"""
    b = bmesh.new()
    ang = [math.radians(a0 + (a1 - a0) * i / segs) for i in range(segs + 1)]
    rings_ = []
    for x in (side * x0, side * x1):
        rin = [b.verts.new(BL(x, ARCH_C + r_in * math.sin(a), ws + r_in * math.cos(a))) for a in ang]
        rout = [b.verts.new(BL(x, ARCH_C + r_out * math.sin(a), ws + r_out * math.cos(a))) for a in ang]
        rings_.append((rin, rout))
    (i0, o0), (i1, o1) = rings_
    for i in range(segs):
        b.faces.new((i0[i], i0[i + 1], i1[i + 1], i1[i]))
        b.faces.new((o0[i], o1[i], o1[i + 1], o0[i + 1]))
        b.faces.new((i0[i], o0[i], o0[i + 1], i0[i + 1]))
        b.faces.new((i1[i], i1[i + 1], o1[i + 1], o1[i]))
    for e in (0, segs):
        b.faces.new((i0[e], i1[e], o1[e], o0[e]))
    bmesh.ops.recalc_face_normals(b, faces=b.faces)
    obs = [to_object(name, b)]
    bp = bmesh.new()
    lay = []
    for xx in (side * x0, side * (x0 - 0.05)):
        lay.append(([bp.verts.new(BL(xx, ARCH_C + r_in * math.sin(a), ws + r_in * math.cos(a))) for a in ang],
                    [bp.verts.new(BL(xx, ARCH_C + r_hub * math.sin(a), ws + r_hub * math.cos(a))) for a in ang]))
    (oa, ia), (ob_, ib) = lay
    for i in range(segs):
        bp.faces.new((oa[i], oa[i + 1], ia[i + 1], ia[i]))          # wheel side
        bp.faces.new((ob_[i], ib[i], ib[i + 1], ob_[i + 1]))        # inboard side
        bp.faces.new((oa[i], ob_[i], ob_[i + 1], oa[i + 1]))        # outer rim
        bp.faces.new((ia[i], ia[i + 1], ib[i + 1], ib[i]))          # hub hole rim
    for e in (0, segs):
        bp.faces.new((oa[e], ia[e], ib[e], ob_[e]))
    bmesh.ops.recalc_face_normals(bp, faces=bp.faces)
    obs.append(to_object(name + "_wall", bp))
    return obs


hY = CUT["hinge_Y"]
ch = []
# floor pan (underbody pass, 10-21): two halves either side of the exhaust tunnel (x +-0.46, top 1.10), kick-up at
# Z +1.9 to a raised rear floor (Y 1.20) over the fuel tank / rear subframe / muffler, spring+shock pockets (top 2.40)
# above the rear lower arms; everything clear of the tyres (2.75 dia, x +-2.735..3.765)
TUN = 0.46
for sx in (-1, 1):
    lohi = lambda a_, b_: (min(sx * a_, sx * b_), max(sx * a_, sx * b_))
    x0_, x1_ = lohi(TUN, 3.36); ch.append(box_lo_hi("floor", (x0_, 0.54, -3.70), (x1_, 0.64, 1.95)))
    x0_, x1_ = lohi(TUN, 2.40); ch.append(box_lo_hi("floor_front", (x0_, 0.54, -3.98), (x1_, 0.64, -3.66)))
    x0_, x1_ = lohi(TUN - 0.04, TUN); ch.append(box_lo_hi("tunnel_wall", (x0_, 0.60, -3.98), (x1_, 1.10, 1.95), 0.01))
    x0_, x1_ = lohi(2.40, 3.36); ch.append(box_lo_hi("floor_side", (x0_, 0.54, 1.85), (x1_, 0.64, 3.75)))
    x0_, x1_ = lohi(TUN, 2.42); ch.append(box_lo_hi("kickup", (x0_, 0.60, 1.85), (x1_, 1.30, 1.95), 0.02))
    x0_, x1_ = lohi(2.38, 2.42); ch.append(box_lo_hi("tank_wall", (x0_, 0.60, 1.85), (x1_, 1.30, 3.80), 0.01))
    # rear spring / shock pocket (Spring_R* on the No.2 lower arm, Shock_R* beside it - repair parts, room kept)
    x0_, x1_ = lohi(1.71, 2.42); ch.append(box_lo_hi("pocket_top", (x0_, 2.30, 4.16), (x1_, 2.40, 5.94), 0.02))
    x0_, x1_ = lohi(1.71, 1.75); ch.append(box_lo_hi("pocket_in", (x0_, 1.20, 4.16), (x1_, 2.40, 5.94), 0.01))
    x0_, x1_ = lohi(1.71, 2.42); ch.append(box_lo_hi("pocket_f", (x0_, 1.20, 4.16), (x1_, 2.40, 4.20), 0.01))
    ch.append(box_lo_hi("pocket_r", (x0_, 1.20, 5.90), (x1_, 2.40, 5.94), 0.01))
ch.append(box_lo_hi("tunnel_top", (-TUN, 1.02, -3.98), (TUN, 1.10, 1.95), 0.02))
ch.append(box_lo_hi("kick_c", (-TUN, 1.00, 1.85), (TUN, 1.30, 1.95), 0.02))
ch.append(box_lo_hi("floor_raised", (-2.42, 1.20, 1.85), (2.42, 1.30, 4.20), 0.03))
ch.append(box_lo_hi("floor_raised", (-1.75, 1.20, 4.18), (1.75, 1.30, 5.92), 0.02))
ch.append(box_lo_hi("floor_raised", (-2.42, 1.20, 5.90), (2.42, 1.30, 6.55), 0.03))
for sx in (-1, 1):
    ch.append(box_lo_hi("sill", (min(sx * 2.95, sx * 3.45), 0.50, -3.55), (max(sx * 2.95, sx * 3.45), 0.95, 3.55), 0.06))
# firewall + cowl shelf under the hood's rear edge: top below the hood's crowned underside at the sides
yc = min(shape.f_belt(-4.4), shape.f_belt(-3.85)) - THK - 0.08
ch.append(box_lo_hi("firewall", (-3.0, 1.06, -3.98), (3.0, yc, -3.86), 0.03))
for sx in (-1, 1):   # lower firewall with the exhaust-tunnel cut-out
    ch.append(box_lo_hi("firewall_low", (min(sx * 0.46, sx * 3.0), 0.62, -3.98), (max(sx * 0.46, sx * 3.0), 1.08, -3.86), 0.03))
ch.append(box_lo_hi("cowl", (-3.0, yc - 0.12, -4.35), (3.0, yc, -3.86), 0.03))
ch.append(box_lo_hi("splash_front", (-2.36, 0.80, -7.38), (2.36, 0.86, -6.86), 0.02))   # behind the bumper undertray
yx = shape.f_ybot(-7.65) + 0.08                  # front crossmember sits above the bumper's lower edge
for sx in (-1, 1):
    ch.append(box_lo_hi("rail", (min(sx * 2.02, sx * 2.36), 1.48, -7.25), (max(sx * 2.02, sx * 2.36), 1.78, -3.98), 0.05))   # above arms, stabilizer, drive shafts
    ch.append(box_lo_hi("rad_side", (min(sx * 1.86, sx * 2.06), yx, -7.98), (max(sx * 1.86, sx * 2.06), 3.06, -7.84), 0.03))
# radiator support frame in front of the radiator (reserved box x +-1.8, Y 1.35..3.25, Z -7.8..-7.2 stays empty)
ch.append(box_lo_hi("xmember", (-2.06, yx, -7.98), (2.06, min(yx + 0.25, 1.30), -7.84), 0.04))
ch.append(box_lo_hi("rad_top", (-2.06, 2.90, -7.98), (2.06, 3.06, -7.84), 0.04))   # prop rod lies on it under the hood
yt = 1.20                                         # trunk floor = raised floor height, above the muffler drum
ch.append(box_lo_hi("trunk_floor", (-3.3, yt, 6.48), (3.3, yt + 0.10, 7.45), 0.03))
ch.append(box_lo_hi("rear_panel", (-3.1, yt, 7.45), (3.1, CUT["bumper_top_R"] - 0.05, 7.57), 0.03))
for ws in WHEEL_S:
    for sx in (-1, 1):
        ch += liner("liner", ws, sx, x0=2.62 if ws < 0 else 2.45)
for o in ch:
    set_mat(o, MI["liner"] if o.name.startswith("liner") else MI["chassis"])
chassis = join("Chassis", ch)

# review-only placeholder wheels (tyre 2.4 x 0.9 at the car_spec centres) - NOT a deliverable (the wheel helper makes
# the real ones); only so the grey renders can be judged with wheels like the concept
def tyre(name, xc, ws, side):
    bt = bmesh.new()
    segs = 48
    loop = []
    r0, r1, w, rc = TYRE_D / 2 * 0.655, TYRE_D / 2, TYRE_W, 0.20 * TYRE_D / 2.4
    for k in range(7):                                   # outer-front rounded corner .. outer-back corner
        a_ = math.pi / 2 * k / 6
        loop.append((r1 - rc + rc * math.cos(a_), w / 2 - rc + rc * math.sin(a_)))
    loop = [(r0, w / 2)] + loop[::-1] + [(r1 - rc + rc * math.cos(a_), -(w / 2 - rc + rc * math.sin(a_))) for a_ in
                                         [math.pi / 2 * k / 6 for k in range(7)]] + [(r0, -w / 2)]
    rings_ = []
    for r, xo in loop:
        rings_.append([bt.verts.new(BL(xc + side * xo, ARCH_C + r * math.sin(2 * math.pi * i / segs), ws + r * math.cos(2 * math.pi * i / segs))) for i in range(segs)])
    for k in range(len(rings_)):
        A_, B_ = rings_[k], rings_[(k + 1) % len(rings_)]
        for i in range(segs):
            bt.faces.new((A_[i], A_[(i + 1) % segs], B_[(i + 1) % segs], B_[i]))
    bmesh.ops.recalc_face_normals(bt, faces=bt.faces)
    obs = [to_object(name, bt)]
    rim = bmesh.new()
    bmesh.ops.create_cone(rim, cap_ends=True, cap_tris=False, segments=40, radius1=TYRE_D / 2 * 0.655,
                          radius2=TYRE_D / 2 * 0.655, depth=TYRE_W * 0.69)
    bmesh.ops.rotate(rim, verts=rim.verts, cent=(0, 0, 0), matrix=Matrix.Rotation(math.pi / 2, 3, 'Y'))
    bmesh.ops.translate(rim, verts=rim.verts, vec=BL(xc + side * 0.06, ARCH_C, ws))
    obs.append(to_object(name + "_rim", rim))
    return obs


rw = []
for ws in WHEEL_S:
    for sx in (-1, 1):
        rw += tyre("wheel", sx * 3.25, ws, sx)
_tm = bpy.data.materials.new("review_tyre"); _tm.use_nodes = True
_tm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.04, 0.04, 0.04, 1)
_tm.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.85
_rm = bpy.data.materials.new("review_rim"); _rm.use_nodes = True
_rm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.55, 0.56, 0.58, 1)
_rm.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.35
for o in rw:
    o.data.materials.clear(); o.data.materials.append(_rm if "_rim" in o.name else _tm)
review_wheels = join("ReviewWheels", rw)

# ------------------------------------------------------------------ 7. finish + export ---------------------------
PARTS = {"Shell": shell, "Glass": glass, "Hood": hood, "Bumper_F": bump_f, "Bumper_R": bump_r, "Chassis": chassis}
grey = bpy.data.materials.new("grey"); grey.use_nodes = True
grey.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.42, 0.42, 0.42, 1)
grey.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.35
grey.use_backface_culling = True
gmat = bpy.data.materials.new("glass_grey"); gmat.use_nodes = True
gmat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.08, 0.09, 0.10, 1)
gmat.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.1
gmat.use_backface_culling = True
stats = {}
for name, ob in PARTS.items():
    activate(ob)
    bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.delete_loose(use_verts=True, use_edges=True, use_faces=False)
    bpy.ops.mesh.select_all(action='SELECT'); bpy.ops.mesh.quads_convert_to_tris()
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.shade_smooth(keep_sharp_edges=True)
    try:
        bpy.ops.object.shade_smooth_by_angle(angle=math.radians(40), keep_sharp_edges=True)
    except Exception as e:
        print("smooth_by_angle", e)
    xs = [v.co.x for v in ob.data.vertices]; ys = [-v.co.y for v in ob.data.vertices]; zs = [v.co.z for v in ob.data.vertices]
    lo = (min(xs), min(zs), min(ys)); hi = (max(xs), max(zs), max(ys))
    stats[name] = dict(tris=len(ob.data.polygons), bbox_min=[round(v, 3) for v in lo], bbox_max=[round(v, 3) for v in hi],
                       bbox_center=[round((a + b) / 2, 3) for a, b in zip(lo, hi)],
                       bbox_size=[round(b - a, 3) for a, b in zip(lo, hi)])
    print(name, stats[name])


def export(path, obs):
    for o in sc.objects:
        o.select_set(o in obs)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_apply=True,
                              export_yup=True)


EXP = os.path.join(OUT, "glb"); os.makedirs(EXP, exist_ok=True)
for name, ob in PARTS.items():
    export(os.path.join(EXP, "sedan_%s.glb" % name.lower()), [ob])
export(os.path.join(EXP, "sedan_body_all.glb"), list(PARTS.values()))
bpy.ops.object.select_all(action='DESELECT')
export(os.path.join(OUT, "review_wheels.glb"), [review_wheels])
json.dump(dict(variant=VAR, stations=len(st), parts=stats, cut=CUT), open(os.path.join(OUT, "stats.json"), "w"), indent=1)
# ------------------------------------------------------------------ 8. attachments (Roblox car-local coords) ------
R3 = lambda v: [round(float(c), 3) for c in v]
COORD = ("car-local Roblox studs: +X = car right, +Y = up, -Z = car front; origin = ground between the axles "
         "(car_spec). The GLB mesh is already in these coords; a MeshPart imported from it is centred on mesh_bbox_center, "
         "so attachment local position = position - mesh_bbox_center. axis = attachment +X (Axis) direction.")
hb = stats["Hood"]; fb_ = stats["Bumper_F"]; rb = stats["Bumper_R"]


def att(pos, axis=(1, 0, 0), note=""):
    d = {"position": R3(pos), "axis": R3(axis)}
    if note:
        d["note"] = note
    return d


def hood_top(s_, x_=0.0):
    h = OUTER_BVH.ray_cast(BL(x_, 12.0, s_), Vector((0, 0, -1)))
    return -1 if h[0] is None else h[0].z


hinge = (0.0, CUT["hinge_Y"], CUT["hinge_Z"])
ATT = {}
ATT["hood"] = dict(part="Body/Hood", coords=COORD, mesh_bbox_center=hb["bbox_center"], mesh_bbox_size=hb["bbox_size"],
    Hinge=att(hinge, (1, 0, 0), "hinge axis = +X; rotate +70 deg about it to open (front end goes up)"),
    SnapAttachment=att(hinge, (1, 0, 0), "= Hinge (pivot)"),
    **{"Bolt_%d" % (i + 1): att((sx * 2.75, hood_top(sz, sx * 2.75) - THK - 0.01, sz), (0, -1, 0), "hinge bolt, head under the hood")
       for i, (sx, sz) in enumerate([(-1, -4.15), (-1, -4.40), (1, -4.15), (1, -4.40)])},
    Grip_L=att((-2.3, hood_top(-7.7, -2.3) - THK - 0.02, -7.7), (0, -1, 0), "front corner, underside"),
    Grip_R=att((2.3, hood_top(-7.7, 2.3) - THK - 0.02, -7.7), (0, -1, 0), "front corner, underside"))
fy0, fy1 = fb_["bbox_min"][1], fb_["bbox_max"][1]
ATT["bumper_f"] = dict(part="Body/Bumper_F", coords=COORD, mesh_bbox_center=fb_["bbox_center"], mesh_bbox_size=fb_["bbox_size"],
    SnapAttachment=att((0.0, round((fy0 + fy1) / 2, 3), -8.0), (1, 0, 0), "pivot (car_spec: centre, Z -8.0)"),
    Bolt_1=att((-2.2, fy1 - 0.06, -7.55), (0, 1, 0), "top bolt, reach with Hood:Open"),
    Bolt_2=att((2.2, fy1 - 0.06, -7.55), (0, 1, 0), "top bolt, reach with Hood:Open"),
    Bolt_3=att((-2.4, fy0 + 0.04, -7.6), (0, -1, 0), "bottom bolt, reach with Lift:Wheel"),
    Bolt_4=att((2.4, fy0 + 0.04, -7.6), (0, -1, 0), "bottom bolt, reach with Lift:Wheel"),
    Grip_L=att((-3.4, (fy0 + fy1) / 2, -7.4), (-1, 0, 0)), Grip_R=att((3.4, (fy0 + fy1) / 2, -7.4), (1, 0, 0)))
ry0, ry1 = rb["bbox_min"][1], rb["bbox_max"][1]
ATT["bumper_r"] = dict(part="Body/Bumper_R", coords=COORD, mesh_bbox_center=rb["bbox_center"], mesh_bbox_size=rb["bbox_size"],
    SnapAttachment=att((0.0, round((ry0 + ry1) / 2, 3), 8.2), (1, 0, 0), "pivot (car_spec: centre, Z +8.2)"),
    Bolt_1=att((-3.45, 1.95, 6.5), (0, 0, -1), "wheel-house side bolt (faces into the rear wheel well)"),
    Bolt_2=att((3.45, 1.95, 6.5), (0, 0, -1), "wheel-house side bolt (faces into the rear wheel well)"),
    Bolt_3=att((-2.3, ry0 + 0.04, 8.0), (0, -1, 0), "bottom bolt, reach with Lift:Wheel"),
    Bolt_4=att((2.3, ry0 + 0.04, 8.0), (0, -1, 0), "bottom bolt, reach with Lift:Wheel"),
    Grip_L=att((-3.4, (ry0 + ry1) / 2, 7.6), (-1, 0, 0)), Grip_R=att((3.4, (ry0 + ry1) / 2, 7.6), (1, 0, 0)))
cb = stats["Chassis"]
ATT["chassis"] = dict(part="Chassis", coords=COORD, mesh_bbox_center=cb["bbox_center"], mesh_bbox_size=cb["bbox_size"],
    LiftPoint_FL=att((-3.0, 0.5, -3.0), (0, -1, 0), "sill underside (car_spec 7)"),
    LiftPoint_FR=att((3.0, 0.5, -3.0), (0, -1, 0), "sill underside"),
    LiftPoint_RL=att((-3.0, 0.5, 3.0), (0, -1, 0), "sill underside"),
    LiftPoint_RR=att((3.0, 0.5, 3.0), (0, -1, 0), "sill underside"),
    Snap_Hood=att(hinge, (1, 0, 0), "matches Hood.SnapAttachment / Hinge"),
    Snap_Bumper_F=ATT["bumper_f"]["SnapAttachment"], Snap_Bumper_R=ATT["bumper_r"]["SnapAttachment"],
    Snap_Wheel_FL=att((-3.25, 1.2, -5.0)), Snap_Wheel_FR=att((3.25, 1.2, -5.0)),
    Snap_Wheel_RL=att((-3.25, 1.2, 5.0)), Snap_Wheel_RR=att((3.25, 1.2, 5.0)),
    Seat_Driver=att((-1.6, 1.5, -0.6)), Seat_Passenger=att((1.6, 1.5, -0.6)),
    Exit_L=att((-5.3, 0.0, -0.6)), Exit_R=att((5.3, 0.0, -0.6)))
AD = os.path.join(OUT, "attachments"); os.makedirs(AD, exist_ok=True)
for k, v in ATT.items():
    json.dump(v, open(os.path.join(AD, "%s_attachments.json" % k), "w"), indent=1)
# hood-open review copy (70 deg about the hinge) - review only
hood_open = hood.copy(); hood_open.data = hood.data.copy(); hood_open.name = "Hood_open70"; sc.collection.objects.link(hood_open)
hood_open.data.transform(Matrix.Translation(BL(*hinge)) @ Matrix.Rotation(math.radians(70), 4, 'X') @ Matrix.Translation(-BL(*hinge)))
zs_ = [v.co.z for v in hood_open.data.vertices]
print("hood open 70: front end height", round(max(zs_), 2))
others = [o for o in PARTS.values() if o is not hood]
export(os.path.join(OUT, "review_hood_open.glb"), others + [hood_open])
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, "sedan_body_%s.blend" % VAR))
print("ALL DONE", sum(v["tris"] for v in stats.values()))


# ------------------------------------------------------------------ 9. hood swing + closed gap check ---------------
def tree(obs):
    b_ = bmesh.new()
    for o in obs:
        b_.from_mesh(o.data)
    t = BVHTree.FromBMesh(b_); b_.free()
    return t


T_shell, T_glass = tree([shell]), tree([glass])
T_body = tree([shell, glass, chassis])
hb0 = bmesh.new(); hb0.from_mesh(hood.data)
swing = []
for ang in range(0, 71, 5):
    hb = hb0.copy()
    M_ = Matrix.Translation(BL(*hinge)) @ Matrix.Rotation(math.radians(ang), 4, 'X') @ Matrix.Translation(-BL(*hinge))
    bmesh.ops.transform(hb, matrix=M_, verts=hb.verts)
    th = BVHTree.FromBMesh(hb)
    hits = len(th.overlap(T_body))
    dmin = min((T_glass.find_nearest(v.co)[3] for v in hb.verts), default=9)
    dmin_s = 9.0
    if ang > 0:     # clearance to the shell, ignoring the closed seams the hood just left (only the cowl / A-pillar zone)
        for v in hb.verts:
            if -v.co.y > -4.3:
                dmin_s = min(dmin_s, T_shell.find_nearest(v.co)[3])
    swing.append((ang, hits, round(dmin, 3), round(dmin_s, 3)))
    hb.free()
print("HOOD SWING (deg, overlapping tri pairs with shell+glass+chassis, min dist to glass, min dist to shell near cowl):")
for r_ in swing:
    print("  ", r_)
# closed gaps: hood outer-surface verts next to other panels
gaps = {"side": [], "rear(cowl)": [], "front(lamp)": []}
for v in hb0.verts:
    if OUTER_BVH.find_nearest(v.co)[3] > 0.004:
        continue
    d = T_shell.find_nearest(v.co)[3]
    if d > 0.2:
        continue
    x, Y, s_ = CAR(v.co)
    k = "rear(cowl)" if s_ > -4.3 else ("front(lamp)" if (s_ < -7.6 and abs(x) < 2.6) or Y < CUT["hood_front_Y"] + 0.05 else "side")
    gaps[k].append(d)
GAPS = {k: (round(min(v), 3), round(sum(v) / len(v), 3), round(max(v), 3), len(v)) for k, v in gaps.items() if v}
print("HOOD CLOSED GAPS (min, mean, max, n):", GAPS)
json.dump(dict(swing=swing, closed_gaps=GAPS, hinge=hinge), open(os.path.join(OUT, "hood_check.json"), "w"), indent=1)
