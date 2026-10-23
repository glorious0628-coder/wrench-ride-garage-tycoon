# Crossover SUV body grey shape (wr-3d-suv, 10-21): Body/Shell, Body/Glass, Body/Hood, Body/Bumper_F, Body/Bumper_R, Chassis.
#   blender --background --factory-startup --python tools/blender/wr_suv/build_suv.py -- <A|B> <out_dir> [all|surface]
# A = suv_spec rear (liftgate hinge Z +7.9, near-upright liftgate), B = concept rear (upper rear leaned forward by a
# smooth shear: hinge ~Z +6.8, rear glass ~33 deg) - everything else identical.
# Same method as the sedan (tools/blender/wr_body/build_body.py): one smooth outer surface (suv_shape.py: rings + end caps,
# every feature line a row) cut along clean lines into the parts (rows, stations, planes; angular wheel arches = tangent
# planes of a rounded trapezoid; grille openings = planes along s), every panel gets a small gap at its seams and a real
# thickness (solidify), inner skins thinned. SUV additions: black arch + sill cladding cut out of the same surface and
# raised 0.045 (grown over the neighbouring panel edges), one-piece liftgate (seams; inside the Shell), two roof rails,
# short roof spoiler, shark-fin antenna. Export: one grey GLB per part in car coords (Roblox local: +Y up, front -Z,
# origin = ground between the axles) + all parts in one GLB + <part>_attachments.json + stats + hood swing check.
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import suv_shape as BS
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

argv = sys.argv[sys.argv.index("--") + 1:]
VAR = argv[0]
OUT = os.path.abspath(argv[1])
STAGE = argv[2] if len(argv) > 2 else "all"
WHEEL_DIR = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "art", "3d", "wheel"))
os.makedirs(OUT, exist_ok=True)
P_ = BS.SPEC_A if VAR == "A" else BS.SPEC_B
shape = BS.Shape(P_)


def SH(s, Y):
    """final s of an unsheared point (variant B leans the upper rear forward; A: identity)"""
    return s + BS.shear_ds(P_, s, Y)
fb = shape.f_belt

# ------------------------------------------------------------------ seams (car coords: x, Y, s) -------------------
CUT = dict(hood_front_Y=3.62, lamp_bot_F=3.05, bumper_top_R=2.90, lamp_R=(3.82, 4.10),
           hinge_Y=4.61, hinge_Z=-4.10,                           # hood hinge: main 10-21 (spec Z -3.6 pulled 0.5 forward)
           hood_rear=-4.30, ws_base=-4.03, header=-0.38,
           gate_s=7.90, roof_rear=7.96, rg_base=8.30,            # liftgate hinge seam, rear glass top / base
           lamp_end_F=-7.40, lamp_end_R=7.60,
           bseam_F=((-7.40, 3.05), (-6.55, 2.45)),               # slanted bumper / fender seams, side view (s, Y)
           bseam_R=((7.62, 2.90), (6.70, 2.45)),
           door_F=-3.40, door_B=0.40, door_R=((3.62, 1.0), (3.62, 4.7)),
           glass_F=-3.05, bpil=(0.30, 0.72), divider=(3.20, 3.55),
           quarter=((6.55, fb(6.55)), (6.05, shape.top_full(6.05) - 0.50)),
           clad=((-3.2, 1.42), (3.2, 1.62)),                     # sill cladding top line, side view (s, Y)
           black_F=1.32, black_R=2.20,                           # bumper lower black (3rd pass: 1.50 -> 1.32)
           bar_F=(3.38, 3.52), slit_F=3.15, head_x=2.10,         # front light bar strip, black slit, headlamp corners
           skid_F=(1.32, 2.55), skid_R=(1.75, 2.60),             # silver skid plates: (top Y, half width); front one
           corner_x=3.00, corner_xe=3.76, drl_x=3.40)            # 3rd pass: bumper corner crease / fold end, DRL drop
                                                                 # = separate plate (skid_plate), rear = colour region
lb = CUT["lamp_bot_F"]


def round_poly(poly, r, n=3):
    """round the corners of a convex polygon (x, Y) with arcs of n segments; corners on the centre line (x = 0) stay"""
    out = []
    m = len(poly)
    for i, p in enumerate(poly):
        if abs(p[0]) < 1e-6 or r <= 0:
            out.append(p); continue
        a, b, c = Vector(poly[i - 1]), Vector(p), Vector(poly[(i + 1) % m])
        d0, d1 = (a - b).normalized(), (c - b).normalized()
        ang = d0.angle(d1)
        t = r / math.tan(ang / 2)
        p0 = b + d0 * t; p1 = b + d1 * t
        ctr = b + (d0 + d1).normalized() * (r / math.sin(ang / 2))
        a0 = math.atan2(p0.y - ctr.y, p0.x - ctr.x); a1 = math.atan2(p1.y - ctr.y, p1.x - ctr.x)
        da = (a1 - a0 + math.pi) % (2 * math.pi) - math.pi
        for k in range(n + 1):
            out.append((ctr.x + r * math.cos(a0 + da * k / n), ctr.y + r * math.sin(a0 + da * k / n)))
    return out


OPEN_F = {
    "grille_up": [(0.0, 2.66), (1.85, 2.66), (1.85, 2.84), (0.0, 2.84)],          # thin slot under the light bar
    # big lower grille: 3rd pass taller (1.44..2.26, concept front cell 1.3..2.2), sides parallel to the black frame,
    # rounded corners
    "intake": round_poly([(0.0, 1.44), (2.80, 1.44), (2.12, 2.26), (0.0, 2.26)], 0.10, 3),
    # corner vertical intakes (3rd pass, concept: tall rounded slot in a black frame on the inward-turned corner)
    "slot": round_poly([(3.22, 1.60), (3.56, 1.60), (3.56, 2.56), (3.22, 2.56)], 0.08, 2),
}
OPEN_R = {
    "reflector": [(3.16, 1.86), (3.38, 1.86), (3.38, 2.34), (3.16, 2.34)],
}
R_CORNER, R_BELT, R_DLO, R_ROOFIN = BS.ROW["corner"], BS.ROW["belt"], BS.ROW["dlo"], BS.ROW["roofin"]
ARCH_C, TYRE_D, TYRE_W = 1.49, 2.98, 1.15                      # suv_spec: tyre 2.98 x 1.15, centre Y 1.49
WHEEL_S = (-4.85, 4.85)
GAP = 0.035
THK = 0.07
CLAD_UP = 0.06                                                   # cladding stands proud of the paint
SEAM_ST = [CUT[k] for k in ("hood_rear", "ws_base", "header", "gate_s", "roof_rear", "rg_base", "lamp_end_F",
                            "lamp_end_R", "door_F", "door_B", "glass_F")] + list(CUT["bpil"]) + list(CUT["divider"])


def BL(x, Y, s):
    return Vector((x, -s, Y))


def CAR(v):
    return (v.x, v.z, -v.y)


def clad_line(s):
    (s0, y0), (s1, y1) = CUT["clad"]
    return y0 + (y1 - y0) * (s - s0) / (s1 - s0)


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


CR_MID = BS.ROW["crease0"] + 1
for i in range(len(st) - 1):
    if -7.45 < st[i] and st[i + 1] < 7.7:
        for j in (CR_MID, NJ - CR_MID):
            e = bm.edges.get((V[i][j], V[i + 1][j]))
            if e is not None:
                e.smooth = False

add_cap(0, True)
add_cap(len(st) - 1, False)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
L_orig = bm.edges.layers.int.new("orig")
for e in bm.edges:
    e[L_orig] = 1                                   # grid edges; edges made by the cut planes get 0
print("outer surface: stations", len(st), "faces", len(bm.faces))
OUTER_BVH = BVHTree.FromBMesh(bm)


def surf_s(x, Y, front=True):
    if front:
        h = OUTER_BVH.ray_cast(BL(x, Y, -12.0), Vector((0, -1, 0)))
    else:
        h = OUTER_BVH.ray_cast(BL(x, Y, 12.0), Vector((0, 1, 0)))
    return None if h[0] is None else -h[0].y


def surf_x(Y, s, side=1):
    h = OUTER_BVH.ray_cast(BL(side * 8.0, Y, s), Vector((-side, 0, 0)))
    return None if h[0] is None else h[0].x


def surf_top(x, s):
    h = OUTER_BVH.ray_cast(BL(x, 12.0, s), Vector((0, 0, -1)))
    return None if h[0] is None else h[0].z


# ------------------------------------------------------------------ 2. seam cuts ---------------------------------
def fc(f):
    return CAR(f.calc_center_median())


def bisect(no, co, pred):
    faces = [f for f in bm.faces if pred(fc(f), f)]
    if not faces:
        return
    edges = list({e for f in faces for e in f.edges}); verts = list({v for f in faces for v in f.verts})
    bmesh.ops.bisect_plane(bm, geom=faces + edges + verts, dist=1e-6, plane_co=BL(*co), plane_no=BL(*no))


def plane_sY(p0, p1):
    ds, dY = p1[0] - p0[0], p1[1] - p0[1]
    n = Vector((0, -ds, dY)).normalized()
    if n.z < 0:
        n = -n
    return (n.x, n.y, n.z), (0.0, p0[1], p0[0])


def plane_xY(p0, p1, side):
    """plane containing the s axis through back-view points p0=(x, Y), p1 (mirrored by side); normal points outward (+x side)"""
    (x0, y0), (x1, y1) = p0, p1
    x0 *= side; x1 *= side
    dx, dy = x1 - x0, y1 - y0
    n = Vector((dy, -dx, 0)).normalized()
    if n.x * side < 0:
        n = -n
    return (n.x, n.y, 0.0), (x0, y0, 0.0)


def side_of(c, plane):
    n, p = plane
    return (c[0] - p[0]) * n[0] + (c[1] - p[1]) * n[1] + (c[2] - p[2]) * n[2]


PL_bF = plane_sY(*CUT["bseam_F"])
PL_bR = plane_sY(*CUT["bseam_R"])
PL_dR = plane_sY(*CUT["door_R"])
PL_q = plane_sY(*CUT["quarter"])
PL_clad = plane_sY(*CUT["clad"])
_r23 = BS.ring(shape, CUT["rg_base"])[BS.ROW["roofedge"]]
CUT["gate_line"] = ((2.88, 2.90), (round(float(_r23[0]), 3), round(float(_r23[1]), 3)))   # back view (x, Y): lower
PL_gate = {sx: plane_xY(*CUT["gate_line"], sx) for sx in (-1, 1)}                     # liftgate side seam
hf = CUT["hood_front_Y"]
bisect((0, 1, 0), (0, hf, 0), lambda c, f: c[2] < -6.6)
bisect((0, 1, 0), (0, lb, 0), lambda c, f: c[2] < -6.4)
bisect(*PL_bF, lambda c, f: -7.9 < c[2] < -5.6 and c[1] < lb + 0.15 and abs(c[0]) > 1.5)
bisect((0, 1, 0), (0, CUT["bumper_top_R"], 0), lambda c, f: c[2] > 6.0)
for yv in CUT["lamp_R"]:
    bisect((0, 1, 0), (0, yv, 0), lambda c, f: c[2] > 7.2)
bisect(*PL_bR, lambda c, f: 5.6 < c[2] < 8.0 and c[1] < CUT["bumper_top_R"] + 0.15 and abs(c[0]) > 1.5)
for sx in (-1, 1):
    bisect(*PL_gate[sx], lambda c, f, sx=sx: c[2] > CUT["rg_base"] - 0.03 and c[1] > CUT["bumper_top_R"] - 0.05 and c[0] * sx > 1.5)
bisect(*PL_dR, lambda c, f: 3.3 < c[2] < 3.9 and R_CORNER <= f[L_kseg] < R_BELT)
bisect(*PL_q, lambda c, f: 5.6 < c[2] < 7.0 and R_BELT <= f[L_kseg] < R_DLO)
bisect(*PL_clad, lambda c, f: -4.4 < c[2] < 4.4 and abs(c[0]) > 1.9 and c[1] < 2.3)
bisect((0, 1, 0), (0, CUT["black_F"], 0), lambda c, f: c[2] < -5.6)      # front bumper lower black (colour line)
for yv in list(CUT["bar_F"]) + [CUT["slit_F"]]:                             # white light bar strip + black slit
    bisect((0, 1, 0), (0, yv, 0), lambda c, f: c[2] < CUT["lamp_end_F"] + 0.1)
for sx in (-1, 1):                                                            # headlamp lens corners
    bisect((1, 0, 0), (sx * CUT["head_x"], 0, 0), lambda c, f: c[2] < -7.0 and 2.95 < c[1] < 3.75)
bisect((0, 1, 0), (0, CUT["skid_F"][0], 0), lambda c, f: c[2] < -6.6)       # silver skid plates
for sx in (-1, 1):
    bisect((1, 0, 0), (sx * CUT["skid_F"][1], 0, 0), lambda c, f: c[2] < -6.6 and c[1] < CUT["skid_F"][0] + 0.15)
    bisect((1, 0, 0), (sx * CUT["skid_R"][1], 0, 0), lambda c, f: c[2] > 7.4 and c[1] < CUT["skid_R"][0] + 0.15)
bisect((0, 1, 0), (0, CUT["skid_R"][0], 0), lambda c, f: c[2] > 7.4)
for sx in (-1, 1):                                                            # 3rd pass: bumper corner crease line
    bisect((1, 0, 0), (sx * CUT["corner_x"], 0, 0), lambda c, f: c[2] < -6.3 and c[1] < lb + 0.02)
    bisect((1, 0, 0), (sx * CUT["drl_x"], 0, 0), lambda c, f: c[2] < -6.9 and 2.95 < c[1] < 3.75)   # DRL drop
for e in bm.edges:              # keep the crease cut line (the inner-cut-line dissolve below would take it out)
    if all(abs(abs(v.co.x) - CUT["corner_x"]) < 1e-4 and -v.co.y < -6.3 for v in e.verts):
        e[L_orig] = 1
bisect((0, 1, 0), (0, CUT["black_R"], 0), lambda c, f: c[2] > 5.6)       # rear bumper lower black

# angular wheel arches: tangent planes of the rounded-trapezoid opening and of the cladding's outer edge
OUTL = {"open": BS.arch_outline(0.0, step_deg=6.0, seg_len=0.22), "flare": BS.arch_outline(BS.FLARE_W, step_deg=6.0, seg_len=0.22)}


def cut_outline(ws, pts):
    n = len(pts)
    for i in range(n):
        p0 = Vector(pts[i]); p1 = Vector(pts[(i + 1) % n])
        d = p1 - p0
        if d.length < 1e-6:
            continue
        nrm = Vector((d.y, -d.x)).normalized()          # outward (CCW outline)
        tdir = d.normalized(); L = d.length
        if p0.y + ws * 0 < -1.0 and p1.y < -1.0:        # below the body bottom: nothing to cut
            continue

        def near(c, f, p0=p0, tdir=tdir, L=L, nrm=nrm):
            if abs(c[0]) < 1.9:
                return False
            q = Vector((c[2] - ws, c[1] - ARCH_C)) - p0
            t = q.dot(tdir)
            if t < -0.2 or t > L + 0.2:
                return False
            return abs(q.dot(nrm)) < 0.45
        bisect((0.0, nrm.y, nrm.x), (0.0, ARCH_C + p0.y, ws + p0.x), near)


for ws in WHEEL_S:
    cut_outline(ws, OUTL["open"])
    cut_outline(ws, OUTL["flare"])


def in_arch(c):
    if abs(c[0]) < 1.9:
        return False
    return any(BS.in_arch_shape(c[2] - ws, c[1] - ARCH_C, -0.012) for ws in WHEEL_S)   # slivers on the line -> kept


def in_flare(c):
    if abs(c[0]) < 1.9:
        return False
    for ws in WHEEL_S:
        d = BS.arch_dist(c[2] - ws, c[1] - ARCH_C)
        if -0.012 <= d < BS.FLARE_W - 0.012:
            return True
    return False


def in_rocker(c):
    return abs(c[0]) > 1.9 and WHEEL_S[0] < c[2] < WHEEL_S[1] and side_of(c, PL_clad) > 0      # under the line


def poly_planes(poly):
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
    if any(abs(p[0]) < 1e-6 for p in half):
        right = [p for p in half]
        left = [(-x, y) for x, y in reversed(half) if abs(x) > 1e-6]
        pts = [p for p in right if abs(p[0]) > 1e-6]
        return [[(0.0, half[0][1])] + pts + [(0.0, half[-1][1])] + left]
    return [half, [(-x, y) for x, y in reversed(half)]]


def inside_poly(pt, planes):
    return all((pt[0] - p[0]) * n[0] + (pt[1] - p[1]) * n[1] < 0 for n, p in planes)


OPENINGS = []
for front, table in ((True, OPEN_F), (False, OPEN_R)):
    for name, half in table.items():
        for poly in full_poly(half):
            pls = poly_planes(poly)
            OPENINGS.append((name, front, pls, poly))
            xs = [p[0] for p in poly]; ys = [p[1] for p in poly]
            for n_, p_ in pls:
                bisect(n_, p_, lambda c, f, front=front, xs=xs, ys=ys: ((c[2] < -6.4) if front else (c[2] > 6.6))
                       and min(xs) - 0.4 < c[0] < max(xs) + 0.4 and min(ys) - 0.4 < c[1] < max(ys) + 0.4)


# black frame round the lower grille (concept front: black trapezoid surround, body-colour corners) - colour only
# 2nd pass (main + GPT 10-21: heavy SUV face): measured on the concept front cell - black trapezoid from (+-2.15, 2.24) to
# (+-2.92, 1.38), i.e. narrow top / wide bottom, sides ~42 deg; it merges into the black lower bumper (Y < black_F)
# 3rd pass: rounded corners (concept outline: rounded top corners, the legs sweep into the lower black band)
FRAME_F = full_poly(round_poly([(0.0, 1.32), (3.05, 1.32), (2.15, 2.40), (0.0, 2.40)], 0.16, 3))[0]
FRAME_PL = poly_planes(FRAME_F)
for n_, p_ in FRAME_PL:
    bisect(n_, p_, lambda c, f: c[2] < -6.4 and abs(c[0]) < 3.4 and 1.0 < c[1] < 2.6)
# black frame round each corner intake (raised black plastic like the grille frame)
SLOTF_PL = [poly_planes(pl) for pl in full_poly(round_poly([(3.14, 1.52), (3.64, 1.52), (3.64, 2.64), (3.14, 2.64)], 0.12, 2))]
for _pl in SLOTF_PL:
    for n_, p_ in _pl:
        bisect(n_, p_, lambda c, f: c[2] < -6.0 and 2.9 < abs(c[0]) < 3.9 and 1.3 < c[1] < 2.85)


def in_opening(c):
    for name, front, pls, poly in OPENINGS:
        if (front and c[2] < -6.4) or (not front and c[2] > 6.6):
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
    c = (x, Y, s)
    bottom = (cap == 0 and 0 <= k < R_CORNER)
    if in_arch(c) or in_opening(c):
        return "DELETE"
    if s < CUT["hood_rear"] and Y > hf and (cap == 1 or k >= R_BELT):
        return "HOOD"
    if s < CUT["lamp_end_F"] and lb < Y < hf:
        return "LAMP_F"
    if Y < lb and s < -5.0 and side_of(c, PL_bF) < 0 and (not bottom or s < -6.9):
        if in_flare(c) and not bottom:
            return "BUMPER_F_CLAD"
        # 2nd pass (heavy SUV face): the black grille frame + lower black band are one raised black plastic piece
        # (stands CLAD_UP proud like the arch cladding, so its trapezoid edge catches the light in 3/4 views)
        if Y < CUT["black_F"] or (s < -6.4 and inside_poly((x, Y), FRAME_PL)) or \
                (s < -6.0 and any(inside_poly((x, Y), _pl) for _pl in SLOTF_PL)):
            return "BUMPER_F_CLAD"
        return "BUMPER_F"
    y0, y1 = CUT["lamp_R"]
    if s > CUT["lamp_end_R"] and y0 < Y < y1:
        return "LAMP_R"
    if Y < CUT["bumper_top_R"] and s > 5.0 and side_of(c, PL_bR) > 0 and (not bottom or s > 8.1):
        return "BUMPER_R_CLAD" if (in_flare(c) and not bottom) else "BUMPER_R"
    if bottom:
        return "DELETE"
    if k < R_BELT and (in_flare(c) or in_rocker(c)):
        return "CLAD_" + side
    # glass (windshield, rear glass on the top rows; side glass in the window band)
    if k >= R_ROOFIN and (CUT["ws_base"] < s < CUT["header"] or CUT["roof_rear"] < s < CUT["rg_base"]):
        return "GLASS"
    if R_BELT <= k < R_DLO:
        b0, b1 = CUT["bpil"]; d0, d1 = CUT["divider"]
        if CUT["glass_F"] < s < b0 or b1 < s < d0 or (s > d1 and side_of(c, PL_q) < 0):
            return "GLASS"
    # one-piece liftgate (closed, part of the Shell): behind the hinge seam; beside the glass its side seam runs along the
    # roof-edge row (clean row line), below the glass base along the slanted plane on the rear face; above the bumper
    if s > CUT["gate_s"] and Y > CUT["bumper_top_R"]:
        if s < CUT["rg_base"] and k >= BS.ROW["roofedge"]:
            return "GATE"
        if s >= CUT["rg_base"] and side_of(c, PL_gate[1 if x >= 0 else -1]) < 0 and (cap == 2 or k >= R_CORNER):
            return "GATE"
    if R_CORNER <= k < R_BELT:
        if s < CUT["door_F"]:
            return "FENDER_" + side
        if CUT["door_F"] < s < CUT["door_B"]:
            return "DOOR_F" + side
        if s > CUT["door_B"] and side_of(c, PL_dR) < 0:
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

CLAD_LABS = {"CLAD_L", "CLAD_R", "BUMPER_F_CLAD", "BUMPER_R_CLAD"}

# ---- materials: slot list kept for the colour stage (codes measured later); grey pass exports grey -------------
_cj = os.path.join(os.path.dirname(os.path.normpath(OUT)), "colours.json")       # measured on the concept
COL = json.load(open(_cj)) if os.path.exists(_cj) else {}
C_ = lambda k, d: COL.get(k, {}).get("hex", d)
MATS = [  # name, hex, roughness, metal (0 everywhere: paint reads as paint), paint flag, emit flag
    ("paint", "#E6E6E6", 0.40, 0.0, 1, 0),        # neutral in the ColorMap; default paint = colours.json paint
    ("trim_black", C_("trim_black", "#262626"), 0.75, 0.0, 0, 0),
    ("glass", C_("glass", "#595E65"), 0.06, 0.0, 0, 0),
    ("light_white", C_("light_white", "#F8F7F7"), 0.25, 0.0, 0, 1),
    ("tail_red", C_("tail_red", "#F41D27"), 0.25, 0.0, 0, 1),
    ("lamp_inner", "#1A1A1C", 0.50, 0.0, 0, 0),
    ("gap", "#4A4C51", 0.60, 0.0, 0, 0),
    ("inner", "#2E3034", 0.85, 0.0, 0, 0),
    ("chassis", "#2B2C2F", 0.85, 0.0, 0, 0),
    ("liner", "#1E1E20", 0.90, 0.0, 0, 0),
    ("slat", "#5A5C60", 0.50, 0.0, 0, 0),         # 3rd pass: lighter grey grille slats (concept)
    ("skid", C_("skid", "#B9BBBE"), 0.45, 0.0, 0, 0),
]
MATS.append(("lamp_module", "#B6B8B4", 0.25, 0.0, 0, 1))   # 3rd pass: LED module reflectors in the headlamps (concept)
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
    if lab in ("HOOD", "GATE") or lab.startswith("FENDER") or lab.startswith("DOOR"):
        return MI["paint"]
    if lab in CLAD_LABS:
        return MI["trim_black"]
    if lab == "BODY":
        if R_BELT <= k < R_DLO and CUT["hood_rear"] < s:
            return MI["trim_black"]          # window band: sail, B-pillar, divider, D-pillar (floating roof)
        if R_DLO <= k < R_ROOFIN and CUT["ws_base"] - 0.05 < s < CUT["header"] + 0.05:
            return MI["trim_black"]          # A-pillar black (concept: dark pillars all round, painted roof rail)
        if k >= R_BELT and CUT["hood_rear"] < s < CUT["ws_base"]:
            return MI["trim_black"]          # cowl strip
        return MI["paint"]
    if lab == "LAMP_F":
        b0, b1 = CUT["bar_F"]
        if b0 < Y < b1:
            return MI["light_white"]         # thin light bar right under the hood edge (family face)
        if abs(x) > CUT["drl_x"] and Y > CUT["slit_F"]:
            return MI["light_white"]         # 3rd pass: the DRL drops down at the lamp's outer end (L-shaped signature)
        if abs(x) > CUT["head_x"]:
            return MI["lamp_inner"]          # headlamp lens at the corners (white bar on top)
        return MI["trim_black"] if Y < CUT["slit_F"] else MI["paint"]   # black slit under, fascia paint between
    if lab == "LAMP_R":
        return MI["tail_red"]
    if lab == "BUMPER_F":
        # (2nd pass: the front skid is a separate forward-facing plate - skid_plate() - the chin under it stays black)
        if s < -6.4 and inside_poly((x, Y), FRAME_PL):
            return MI["trim_black"]
        return MI["trim_black"] if Y < CUT["black_F"] else MI["paint"]
    if lab == "BUMPER_R":
        if Y < CUT["skid_R"][0] and abs(x) < CUT["skid_R"][1] and s > 7.9:
            return MI["skid"]
        return MI["trim_black"] if Y < CUT["black_R"] else MI["paint"]
    if lab == "GLASS":
        return MI["glass"]
    return MI["inner"]


for f in bm.faces:
    x_, Y_, s_ = fc(f)
    f.material_index = outer_mat(LAB[f.index], x_, Y_, s_, f[L_kseg])
# cut-plane lines that run INSIDE one part (extensions of tangent / seam planes past their segment) only leave slivers:
# dissolve them back into their face (the real part boundaries stay)
_dis = [e for e in bm.edges if e[L_orig] == 0 and len(e.link_faces) == 2
        and e.link_faces[0][L_lab] == e.link_faces[1][L_lab]
        and e.link_faces[0].material_index == e.link_faces[1].material_index]       # colour borders stay
bmesh.ops.dissolve_edges(bm, edges=_dis, use_verts=True, use_face_split=False)
bm.faces.index_update(); bm.faces.ensure_lookup_table()
LAB = [NAMES[f[L_lab]] for f in bm.faces]
print("dissolved inner cut edges", len(_dis), "faces now", len(bm.faces))
_gb = bm.copy()
bmesh.ops.delete(_gb, geom=[f for f in _gb.faces if LAB[f.index] != "GLASS"], context='FACES')
GLASS_BVH = BVHTree.FromBMesh(_gb); _gb.free()

# seams: 1 = normal seam (both sides shrink), 2 = cladding edge (cladding grows over the panel, the panel shrinks)
L_seam = bm.edges.layers.int.new("seam")
KEEP_OUT = {NAMES.index(n) for n in ("DELETE", "GLASS", "LAMP_F", "LAMP_R") if n in NAMES}
CLAD_IDS = {NAMES.index(n) for n in CLAD_LABS if n in NAMES}
for e in bm.edges:
    v_ = 0
    if len(e.link_faces) == 2:
        a, b = e.link_faces[0][L_lab], e.link_faces[1][L_lab]
        if a != b and a not in KEEP_OUT and b not in KEEP_OUT:
            v_ = 2 if ((a in CLAD_IDS) != (b in CLAD_IDS)) else 1
    e[L_seam] = v_

# 3rd pass: the front bumper corner folds back (concept: a crease from under the headlamp down to the black lower bumper,
# the vertical intake sits on the inward-turned corner). Corner vertices in front of the chord between the surface points
# at x = corner_x and corner_xe are pushed straight back (only s changes, so every cut line stays) onto that chord plane;
# full below Y 2.70, fading out up to the lamp bottom; the crease line (a cut at x = corner_x) is kept sharp.
_xc, _xe = CUT["corner_x"], CUT["corner_xe"]
_sc, _se = surf_s(_xc, 2.2), surf_s(_xe, 2.2)
_kc = (_se - _sc) / (_xe - _xc)
_moved = 0; _maxd = 0.0
for v in bm.verts:
    x_, Y_, s_ = CAR(v.co)
    if s_ > -6.0 or Y_ > lb - 1e-4 or abs(x_) < _xc - 1e-4 or abs(x_) > _xe:
        continue
    sp = _sc + (abs(x_) - _xc) * _kc
    if s_ < sp:
        w = BS.smoothstep(lb, lb - 0.35, Y_)
        v.co = BL(x_, Y_, s_ + w * (sp - s_)); _moved += 1; _maxd = max(_maxd, w * (sp - s_))
_nsharp = 0
for e in bm.edges:
    (xa, Ya, sa), (xb, Yb, sb) = CAR(e.verts[0].co), CAR(e.verts[1].co)
    if abs(abs(xa) - _xc) < 2e-3 and abs(abs(xb) - _xc) < 2e-3 and max(sa, sb) < -6.0 and max(Ya, Yb) < lb - 0.30 and min(Ya, Yb) > 1.0:
        e.smooth = False; _nsharp += 1
bm.normal_update()
OUTER_BVH = BVHTree.FromBMesh(bm)
print("CORNER FOLD: chord s %.3f -> %.3f (slope %.2f), moved %d verts, max setback %.3f, sharp crease edges %d"
      % (_sc, _se, _kc, _moved, _maxd, _nsharp))

# variant B: lean the upper rear forward (all cuts / labels were made in the unsheared loft, so ring-based seams follow)
if P_.get("shear"):
    for v in bm.verts:
        x_, Y_, s_ = CAR(v.co)
        v.co = BL(x_, Y_, SH(s_, Y_))
    bm.normal_update()
    OUTER_BVH = BVHTree.FromBMesh(bm)
    _gb = bm.copy()
    bmesh.ops.delete(_gb, geom=[f for f in _gb.faces if LAB[f.index] != "GLASS"], context='FACES')
    GLASS_BVH = BVHTree.FromBMesh(_gb); _gb.free()
HINGE_F = SH(CUT["gate_s"], shape.top_full(CUT["gate_s"]))       # final Z of the liftgate hinge / roof rear edge


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
    bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, "suv_surface.glb"), export_format='GLB', export_yup=True)
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, "suv_body_surface.blend"))
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


def offset_boundary(b2, dist, kinds=(1, 2), only_seams=True):
    """move boundary vertices along the surface, perpendicular to the boundary: dist > 0 = shrink (panel gap),
    < 0 = grow. Only boundary edges whose seam value is in kinds (only_seams)."""
    b2.normal_update()
    lay = b2.edges.layers.int.get("seam")
    moves = []
    for v in b2.verts:
        bnd = [e for e in v.link_edges if e.is_boundary and (not only_seams or (lay is not None and e[lay] in kinds))]
        if not bnd or len(bnd) > 2:
            continue
        if only_seams and lay is not None and 2 not in kinds and any(e.is_boundary and e[lay] == 2 for e in v.link_edges):
            continue          # corner where a seam meets the raised cladding: stays put (the cladding step covers it)
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
        mag = min(abs(dist) / c, lim) if dist > 0 else abs(dist) / c
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
    for p in ob.data.polygons:
        if callable(idx_or_fn):
            p.material_index = idx_or_fn(CAR(p.center), CAR(p.normal))
        else:
            p.material_index = idx_or_fn
    return ob


def near_opening(x, Y, s):
    for _, front, pls, _ in OPENINGS:
        if (s < 0) != front or abs(s) < 6.4:
            continue
        if all((x - p_[0]) * n_[0] + (Y - p_[1]) * n_[1] < 0.06 for n_, p_ in pls):
            return True
    return False


def rim_mat(c, kind):
    x, Y, s = c
    if kind == "lamp":
        return MI["lamp_inner"]
    if kind == "clad":
        return MI["trim_black"]
    if abs(x) > 1.9 and any(abs(BS.arch_dist(s - ws, Y - ARCH_C)) < 0.08 for ws in WHEEL_S):
        return MI["trim_black"]
    if near_opening(x, Y, s):
        return MI["trim_black"]
    if GLASS_BVH.find_nearest(BL(x, Y, s))[3] < 0.09:
        return MI["trim_black"]
    if Y < 1.0:
        return MI["inner"]
    return MI["gap"]


def colour_panel(ob, kind):
    gi = ob.vertex_groups["inner"].index
    inn = [any(g.group == gi and g.weight > 0.5 for g in v.groups) for v in ob.data.vertices]
    for p in ob.data.polygons:
        flags = [inn[i] for i in p.vertices]
        if not any(flags):
            continue
        if all(flags):
            p.material_index = MI["glass"] if kind == "glass" else (MI["lamp_inner"] if kind == "lamp" else MI["inner"])
        else:
            p.material_index = MI["glass"] if kind == "glass" else rim_mat(CAR(p.center), kind)


def activate(ob):
    for o in sc.objects:
        o.select_set(o == ob)
    bpy.context.view_layer.objects.active = ob


def solidify(ob, thk, thin_inner=0.0, kind="panel"):
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
    colour_panel(ob, kind)
    for g in list(ob.vertex_groups):
        ob.vertex_groups.remove(g)


def push(b2, dist):
    b2.normal_update()
    for v in b2.verts:
        v.co -= v.normal * dist


def panel(name, labs, gap=GAP / 2, thk=THK, sink=0.0, thin=0.3, only_seams=True, kind="panel"):
    b2 = extract(labs)
    md = 0.01 if kind == "clad" else 0.01                # slivers from crossing cut planes (cladding has no small detail)
    bmesh.ops.remove_doubles(b2, verts=b2.verts, dist=md)
    bmesh.ops.dissolve_degenerate(b2, dist=md, edges=b2.edges)
    if kind == "clad":
        offset_boundary(b2, GAP / 2, kinds=(1,))         # normal gap to another cladding / bumper piece
        push(b2, -CLAD_UP)                               # stand proud of the paint (its rim = the step; the panel
                                                         # next to it keeps its edge right under the step)
    elif gap:
        offset_boundary(b2, gap, kinds=(1,) if only_seams else (0, 1, 2), only_seams=only_seams)
    if sink:
        bmesh.ops.remove_doubles(b2, verts=b2.verts, dist=0.012)
        bmesh.ops.dissolve_degenerate(b2, dist=0.012, edges=b2.edges)
        push(b2, sink)
    strip_layers(b2)
    ob = to_object(name, b2)
    solidify(ob, thk, thin, kind)
    return ob


def join(name, obs):
    obs = [o for o in obs if o is not None]
    tl = {}
    for o in obs:
        k = o.name.split(".")[0]
        tl[k] = tl.get(k, 0) + sum(len(p.vertices) - 2 for p in o.data.polygons)
    print("JOIN", name, sorted(tl.items(), key=lambda kv: -kv[1])[:14])
    for o in sc.objects:
        o.select_set(o in obs)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active; ob.name = name; ob.data.name = name
    return ob


shell_parts = []
for lab in ("BODY", "FENDER_L", "FENDER_R", "DOOR_FL", "DOOR_FR", "DOOR_RL", "DOOR_RR", "GATE"):
    if lab in NAMES:
        shell_parts.append(panel("p_" + lab, {lab}))
for lab in ("CLAD_L", "CLAD_R"):
    if lab in NAMES:
        shell_parts.append(panel("p_" + lab, {lab}, thk=THK + CLAD_UP, kind="clad"))
shell_parts.append(panel("p_LAMP_F", {"LAMP_F"}, gap=0.0, sink=0.05, thk=0.06, only_seams=False, kind="lamp"))
shell_parts.append(panel("p_LAMP_R", {"LAMP_R"}, gap=0.0, sink=0.05, thk=0.06, only_seams=False, kind="lamp"))
hood = panel("Hood", {"HOOD"})
bump_f = panel("Bumper_F", {"BUMPER_F"})
bump_r = panel("Bumper_R", {"BUMPER_R"})
bump_f_cl = panel("Bumper_F_clad", {"BUMPER_F_CLAD"}, thk=THK + CLAD_UP, kind="clad") if "BUMPER_F_CLAD" in NAMES else None
bump_r_cl = panel("Bumper_R_clad", {"BUMPER_R_CLAD"}, thk=THK + CLAD_UP, kind="clad") if "BUMPER_R_CLAD" in NAMES else None
b2 = extract({"GLASS"}); offset_boundary(b2, -0.03, only_seams=False); push(b2, 0.045); strip_layers(b2)
glass = to_object("Glass", b2)
glass.vertex_groups.new(name="inner"); glass.vertex_groups.new(name="rim")
_m = glass.modifiers.new("sol", 'SOLIDIFY'); _m.thickness = 0.03; _m.offset = -1.0; _m.use_rim = True
_m.use_quality_normals = True
activate(glass); bpy.ops.object.modifier_apply(modifier="sol")
for g in list(glass.vertex_groups):
    glass.vertex_groups.remove(g)
set_mat(glass, MI["glass"])


# ------------------------------------------------------------------ 5. details -----------------------------------
def rbox(name, size, center, radius, segs=3, rot=None):
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
    b = bmesh.new(); bmesh.ops.create_uvsphere(b, u_segments=segs, v_segments=rings, radius=1.0)
    for v in b.verts:
        x, y, z = v.co
        f = lambda t: math.copysign(abs(t) ** power, t)
        v.co = Vector((f(x) * size[0] / 2, f(y) * size[2] / 2, f(z) * size[1] / 2))
    bmesh.ops.translate(b, vec=BL(*center), verts=b.verts)
    bmesh.ops.recalc_face_normals(b, faces=b.faces)
    return to_object(name, b)


PLAIN = {"floor", "floor_front", "tunnel_wall", "floor_side", "kickup", "tank_wall", "pocket_top", "pocket_in", "pocket_f",
         "pocket_r", "tunnel_top", "kick_c", "floor_raised", "jamb", "jamb_up", "jamb_sail", "gate_header", "seam_back_r"}   # hidden: no bevel


def box_lo_hi(name, lo, hi, radius=0.03, segs=1):
    if name in PLAIN:
        radius = 0.0
    size = tuple(h - l for l, h in zip(lo, hi)); cen = tuple((l + h) / 2 for l, h in zip(lo, hi))
    return rbox(name, size, cen, radius, segs)


def loft(name, sections, closed_sections=True, cap=True):
    """sections: list of closed point loops [(x, Y, s), ...] (same count) -> closed tube with end caps"""
    b = bmesh.new()
    VV = [[b.verts.new(BL(*p)) for p in sec] for sec in sections]
    n = len(sections[0])
    for i in range(len(VV) - 1):
        for j in range(n):
            b.faces.new((VV[i][j], VV[i][(j + 1) % n], VV[i + 1][(j + 1) % n], VV[i + 1][j]))
    if cap:
        b.faces.new(VV[0]); b.faces.new(VV[-1][::-1])
    bmesh.ops.recalc_face_normals(b, faces=b.faces)
    # make sure the normals point out of the closed volume (recalc does it for closed manifolds)
    return to_object(name, b)


def rrect(w, h, r, n_corner=3):
    """rounded rectangle (u, v) loop, centred, CCW"""
    pts = []
    for cx, cy, a0 in ((w / 2 - r, h / 2 - r, 0), (-w / 2 + r, h / 2 - r, 90), (-w / 2 + r, -h / 2 + r, 180), (w / 2 - r, -h / 2 + r, 270)):
        for k in range(n_corner + 1):
            a = math.radians(a0 + 90 * k / n_corner)
            pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


details_shell = []
# side mirrors on the sail (front lower corner of the front side window); housing reaches ~4.15 (concept front view)
for sx in (-1, 1):
    ms = CUT["glass_F"] + 0.02
    rb_ = BS.ring(shape, ms)[R_BELT]
    xs, mY = float(rb_[0]), float(rb_[1]) + 0.02
    hx = 3.80
    arm_l = hx - 0.24 - (xs - 0.08)
    details_shell.append(set_mat(rbox("mirror_arm", (arm_l, 0.17, 0.30), (sx * (xs - 0.08 + arm_l / 2), mY + 0.05, ms + 0.08), 0.06, 2), MI["trim_black"]))
    mcy = mY + 0.24
    details_shell.append(set_mat(blob("mirror", (0.78, 0.56, 0.62), (sx * hx, mcy, ms + 0.14)),
                                 lambda c, n, mcy=mcy: MI["paint"] if c[1] > mcy + 0.02 else MI["trim_black"]))
    details_shell.append(set_mat(rbox("mirror_base", (0.12, 0.36, 0.48), (sx * (xs + 0.02), mY + 0.02, ms + 0.10), 0.05, 2), MI["trim_black"]))
# door handles on the shoulder crease, near the rear edge of each door (concept)
for hs in (-0.55, 3.00):
    hY = shape.f_crease(hs) - 0.10
    for sx in (-1, 1):
        xs = surf_x(hY, hs, sx)
        xs = abs(xs) if xs is not None else 3.78
        details_shell.append(set_mat(rbox("handle", (0.09, 0.11, 0.54), (sx * (xs + 0.015), hY, hs), 0.04, 2), MI["paint"]))

def flare_top_at(s):
    """highest Y of the arch cladding's outer edge at station s (or the sill cladding line)"""
    y = clad_line(s)
    for ws in WHEEL_S:
        ds = s - ws
        for i in range(400):
            dY = 3.0 - i * 0.01
            if BS.arch_dist(ds, dY) < BS.FLARE_W:
                y = max(y, ARCH_C + dY)
                break
    return y


# door jambs (closed doors: something behind the seam gaps a pure side view looks through), only above the cladding
for sx in (-1, 1):
    for sj in (CUT["door_F"], CUT["door_B"], CUT["door_R"][0][0]):
        y_lo = flare_top_at(sj) - 0.06
        details_shell.append(box_lo_hi("jamb", (min(sx * 3.25, sx * 3.62), y_lo, sj - 0.11),
                                       (max(sx * 3.25, sx * 3.62), shape.f_crease(sj) - 0.08, sj + 0.11)))
        y0 = shape.f_crease(sj) - 0.12; y1 = shape.f_belt(sj) + 0.03
        details_shell.append(box_lo_hi("jamb_up", (min(sx * 2.95, sx * 3.12), y0, sj - 0.11), (max(sx * 2.95, sx * 3.12), y1, sj + 0.11)))


def strip_between(name, p0, p1, x0, x1, thick=0.16):
    (s0, y0), (s1, y1) = p0, p1
    L = math.hypot(s1 - s0, y1 - y0); ang = math.atan2(s1 - s0, y1 - y0)
    return rbox(name, (x1 - x0, L, thick), ((x0 + x1) / 2, (y0 + y1) / 2, (s0 + s1) / 2), 0.02, 1,
                rot=Matrix.Rotation(ang, 3, 'X'))


for sx in (-1, 1):
    for (pa, pb), xin in ((CUT["bseam_F"], (3.0, 3.40)), (CUT["bseam_R"], (3.0, 3.40))):
        sa, ya = pa; sb, yb = pb
        sb, yb = sb + (sb - sa) * 0.30, yb + (yb - ya) * 0.30       # run on past the seam's end into the arch cladding
        xa_ = surf_x(ya - 0.02, sa, 1) or 3.5; xb_ = surf_x(yb, sb, 1) or 3.5
        xin = (xin[0] - 0.25, min(xa_, xb_) - 0.12)
        o = strip_between("seam_back", (sa, ya - 0.02), (sb, yb), *xin)
        if sx < 0:
            o.data.transform(Matrix.Scale(-1, 4, (1, 0, 0))); o.data.flip_normals()
        details_shell.append(o)
    yb_ = CUT["bumper_top_R"]
    details_shell.append(box_lo_hi("seam_back_r", (min(sx * 2.0, sx * 3.0), yb_ - 0.10, 7.60), (max(sx * 2.0, sx * 3.0), yb_ + 0.10, 8.05)))
    details_shell.append(box_lo_hi("seam_back_r", (min(sx * 1.4, sx * 2.5), yb_ - 0.10, 8.05), (max(sx * 1.4, sx * 2.5), yb_ + 0.10, 8.30)))
    details_shell.append(box_lo_hi("seam_back_r", (min(sx * 1.0, sx * 2.1), yb_ - 0.10, 8.28), (max(sx * 1.0, sx * 2.1), yb_ + 0.10, 8.37)))
    # door top edge under the mirror sail (no glass behind it there)
    details_shell.append(box_lo_hi("jamb_sail", (min(sx * 2.88, sx * 3.12), 4.28, CUT["door_F"] - 0.05), (max(sx * 2.88, sx * 3.12), 4.52, CUT["glass_F"] + 0.05)))
# liftgate top seam backing (roof rear header)
_ry = shape.top_full(CUT["gate_s"])
details_shell.append(box_lo_hi("gate_header", (-1.8, _ry - 0.42, HINGE_F - 0.14), (1.8, _ry - 0.24, HINGE_F - 0.02)))

# roof rails: floating bar on two sloped feet (rail top 6.6 = suv_spec), x +-1.98
RAIL_X, RAIL_S = 1.98, (-0.55, SH(6.45, 6.35))
rail_prof = rrect(0.15, 0.12, 0.05, 2)
for sx in (-1, 1):
    secs = []
    n_s = 20
    s0, s1 = RAIL_S
    for i in range(n_s + 1):
        s = s0 + (s1 - s0) * i / n_s
        ry = surf_top(sx * RAIL_X, s) or 6.3
        d0, d1 = s - s0, s1 - s
        h = 0.255 * min(1.0, BS.smoothstep(0.0, 0.42, d0), BS.smoothstep(0.0, 0.42, d1))
        h = max(h, 0.03)
        cy = ry + h + 0.0
        secs.append([(sx * RAIL_X + u, cy + v, s) for (u, v) in rail_prof])
    o = loft("rail", secs)
    details_shell.append(set_mat(o, MI["trim_black"]))

# short roof spoiler on the liftgate top edge (overhangs the rear glass); loft of a wedge section along x
sp_secs = []
XS = [-2.40, -2.30, -2.12, -1.6, -0.8, 0.0, 0.8, 1.6, 2.12, 2.30, 2.40]
for xx in XS:
    taper = BS.smoothstep(2.42, 2.05, abs(xx))           # 1 in the middle, 0 at the tips
    yr = lambda s_, xx=xx: (surf_top(xx, s_) or 6.3)
    H_ = HINGE_F
    y_h = yr(H_)
    tip_s = H_ + 0.05 + 0.32 * (0.35 + 0.65 * taper)
    th = 0.035 + 0.06 * (0.4 + 0.6 * taper)
    loop = [(H_ - 0.24, yr(H_ - 0.24) - 0.04), (H_ - 0.22, yr(H_ - 0.22) + 0.012), (H_ + 0.02, y_h + 0.03),
            (tip_s - 0.05, y_h + 0.0), (tip_s, y_h - 0.035), (tip_s - 0.04, y_h - 0.035 - th),
            (H_ + 0.16, yr(H_ + 0.13) + 0.01), (H_ + 0.08, yr(H_ + 0.08) - 0.035)]
    sp_secs.append([(xx, y, s_) for (s_, y) in loop])
details_shell.append(set_mat(loft("spoiler", sp_secs), MI["paint"]))
# shark-fin antenna on the roof, rear centre
FIN_S = SH(6.55, 6.4)
fin_y = surf_top(0.0, FIN_S) or 6.4
fin = blob("antenna", (0.13, 0.20, 0.48), (0.0, fin_y + 0.06, FIN_S), segs=12, rings=8, power=0.7)
for v in fin.data.vertices:
    x_, Y_, s_ = CAR(v.co)
    k_ = (Y_ - fin_y) / 0.16
    if k_ > 0:
        v.co = BL(x_ * (1 - 0.35 * k_), Y_, s_ + 0.12 * k_)          # lean back, narrower at the top
details_shell.append(set_mat(fin, MI["trim_black"]))


def pocket(name, poly, front, recess, wall=0.025, slats=0, slat_h=0.055, slat_d=0.12):
    """dark pocket behind a bumper opening; its back face follows the bumper surface at a constant depth `recess`
    (uniform-depth recess on the curved fascia, no deep box at the centre); optional horizontal slats that follow the
    back face; closed (solidified)"""
    pts = []
    n = len(poly)
    for i in range(n):
        a, b = Vector(poly[i]), Vector(poly[(i + 1) % n])
        k = max(1, int((b - a).length / 0.20))
        for t in range(k):
            pts.append(a.lerp(b, t / k))
    cen = sum(pts, Vector((0, 0))) / len(pts)
    pts = [p + (p - cen).normalized() * 0.05 for p in pts]
    sgn = -1 if front else 1
    ss = []
    for p in pts:
        sv = surf_s(p.x, p.y, front)
        ss.append(sv if sv is not None else (-8.1 if front else 8.4))
    b = bmesh.new()
    ring_f = [b.verts.new(BL(p.x, p.y, sv - sgn * 0.02)) for p, sv in zip(pts, ss)]
    ring_b = [b.verts.new(BL(p.x, p.y, sv - sgn * recess)) for p, sv in zip(pts, ss)]
    m = len(pts)
    for i in range(m):
        b.faces.new((ring_f[i], ring_f[(i + 1) % m], ring_b[(i + 1) % m], ring_b[i]))
    # back face: fan from a centre vertex placed on the surface + recess (curved back follows the fascia)
    sc_ = surf_s(cen.x, cen.y, front)
    vc = b.verts.new(BL(cen.x, cen.y, (sc_ if sc_ is not None else sum(ss) / m) - sgn * recess))
    for i in range(m):
        b.faces.new((ring_b[i], ring_b[(i + 1) % m], vc))
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
        prof = rrect(slat_h, slat_d, min(0.03, slat_h * 0.4), 1)   # (u = Y, v = s) flat slat section
        for k in range(1, slats + 1):
            yk = y0 + (y1 - y0) * k / (slats + 1)
            xs_ = []
            for i in range(n):
                (xa, ya), (xb, yb) = poly[i], poly[(i + 1) % n]
                if (ya - yk) * (yb - yk) <= 0 and ya != yb:
                    xs_.append(xa + (yk - ya) * (xb - xa) / (yb - ya))
            if len(xs_) < 2:
                continue
            xa, xb = min(xs_) + 0.01, max(xs_) - 0.01
            secs = []
            NX = max(4, int((xb - xa) / 0.55))
            for j in range(NX + 1):
                xx = xa + (xb - xa) * j / NX
                sv = surf_s(xx, yk, front)
                sv = sv if sv is not None else sc_
                sm = sv - sgn * (recess * 0.62)
                secs.append([(xx, yk + u, sm + v) for (u, v) in prof])
            obs.append(loft(name + "_slat", secs))
    return obs


bumper_f_extra, bumper_r_extra = [], []
POCKET_MAT = {"reflector": "tail_red", "intake": "lamp_inner", "slot": "lamp_inner"}
for name, front, pls, poly in OPENINGS:
    _n0 = len(bumper_f_extra) + len(bumper_r_extra)
    if front:
        if name == "intake":            # 3rd pass: thick lighter slats (concept), darker interior
            bumper_f_extra += pocket(name, poly, True, 0.14, slats=4, slat_h=0.095, slat_d=0.12)
        elif name == "slot":            # corner vertical intakes: 3 fins
            bumper_f_extra += pocket(name, poly, True, 0.12, slats=3, slat_h=0.05, slat_d=0.08)
        else:
            bumper_f_extra += pocket(name, poly, True, 0.12)
    else:
        bumper_r_extra += pocket(name, poly, False, 0.08)
    for o in (bumper_f_extra + bumper_r_extra)[_n0:]:
        set_mat(o, MI["slat"] if "_slat" in o.name else MI[POCKET_MAT.get(name, "trim_black")])


def skid_plate(name, y_top=1.32, y_bot=0.92, half=2.55, end=0.27, lean=0.03):
    """front skid plate (2nd pass, concept: wide silver plate under the black grille that reads from the front): a
    closed wedge with a near-upright face (the chin under it curves ~50 deg down, so paint there stayed in
    shadow); top edge 0.03 proud of the bumper, rounded ends that drop and follow the bumper round the corners"""
    xs = []
    n_mid = 18
    for i in range(n_mid + 1):
        xs.append(-(half - end) + 2 * (half - end) * i / n_mid)
    ends = [(half - end) + end * k / 4 for k in range(1, 5)]
    xs = [-e for e in reversed(ends)] + xs + ends
    secs = []
    for x in xs:
        u = max(0.0, (abs(x) - (half - end)) / end)
        yt = y_bot + 0.10 + (y_top - y_bot - 0.10) * math.sqrt(max(0.0, 1 - min(u, 1.0) ** 2))
        st = surf_s(x, yt, True)
        st = st if st is not None else -8.0
        st -= CLAD_UP                                    # sits on the raised black lower bumper (2nd pass)
        sb = st + lean * (yt - y_bot) / (y_top - y_bot)
        yb_ = min(1.12, yt - 0.04)                       # back face stays in front of the radiator-support cross member
        secs.append([(x, yt, st + 0.05), (x, yt, st - 0.012), (x, yt - 0.03, st - 0.035), (x, y_bot + 0.03, sb - 0.006),
                     (x, y_bot, sb + 0.03), (x, y_bot + 0.02, sb + 0.30), (x, yb_, st + 0.10)])
    return loft(name, secs)


SKID_F = skid_plate("skid_plate")
# 3rd pass: headlamp inner compartments (concept: LED module cells under the DRL) - two light reflector blocks per side
# standing 0.02 out of the sunk lens, turned with the lamp surface
for sx in (-1, 1):
    for xm in (2.40, 2.84):
        sm = surf_s(xm, 3.22, True); k_ = (surf_s(xm + 0.08, 3.22, True) - surf_s(xm - 0.08, 3.22, True)) / 0.16
        mod = rbox("lamp_module", (0.27, 0.13, 0.07), (sx * xm, 3.22, sm + 0.065), 0.03, 2,
                   rot=Matrix.Rotation(-sx * math.atan(k_), 3, 'Z'))
        details_shell.append(set_mat(mod, MI["lamp_module"]))
set_mat(SKID_F, MI["skid"])
bumper_f_extra.append(SKID_F)

for o in details_shell:
    if o.name.startswith(("jamb", "seam_back", "gate_jamb", "gate_header")):    # incl. jamb_sail
        set_mat(o, MI["gap"])
shell = join("Shell", shell_parts + details_shell)
bump_f = join("Bumper_F", [bump_f, bump_f_cl] + bumper_f_extra)
bump_r = join("Bumper_R", [bump_r, bump_r_cl] + bumper_r_extra)


# ------------------------------------------------------------------ 6. chassis -----------------------------------
def outline_chain(off, y_min=-0.52):
    """arch outline points (ds, dY) above y_min, ordered from the rear-bottom over the top to the front-bottom"""
    pts = BS.arch_outline(off, step_deg=9.0, seg_len=0.30)
    keep = []
    for p in pts:
        a = math.atan2(p[1], p[0])
        if a < -math.pi / 2:
            a += 2 * math.pi
        if p[1] > y_min:
            keep.append((a, p))
    keep.sort()
    return [p for a, p in keep]


def liner(name, ws, side, x0=2.55, x1=3.70, r_hub=0.72):
    """wheel-arch liner following the angular opening: partial tube under the arch lip + an inboard wall (hub hole)"""
    b = bmesh.new()
    ci = outline_chain(-0.02); co = outline_chain(0.03)
    n = min(len(ci), len(co))
    ci, co = ci[:n], co[:n]
    rings_ = []
    for x in (side * x0, side * x1):
        rin = [b.verts.new(BL(x, ARCH_C + p[1], ws + p[0])) for p in ci]
        rout = [b.verts.new(BL(x, ARCH_C + p[1], ws + p[0])) for p in co]
        rings_.append((rin, rout))
    (i0, o0), (i1, o1) = rings_
    for i in range(n - 1):
        b.faces.new((i0[i], i0[i + 1], i1[i + 1], i1[i]))
        b.faces.new((o0[i], o1[i], o1[i + 1], o0[i + 1]))
        b.faces.new((i0[i], o0[i], o0[i + 1], i0[i + 1]))
        b.faces.new((i1[i], i1[i + 1], o1[i + 1], o1[i]))
    for e in (0, n - 1):
        b.faces.new((i0[e], i1[e], o1[e], o0[e]))
    bmesh.ops.recalc_face_normals(b, faces=b.faces)
    obs = [to_object(name, b)]
    bp = bmesh.new()
    lay = []
    hub = []
    for p in ci:
        a = math.atan2(p[1], p[0])
        hub.append((r_hub * math.cos(a), r_hub * math.sin(a)))
    for xx in (side * x0, side * (x0 - 0.05)):
        lay.append(([bp.verts.new(BL(xx, ARCH_C + p[1], ws + p[0])) for p in ci],
                    [bp.verts.new(BL(xx, ARCH_C + p[1], ws + p[0])) for p in hub]))
    (oa, ia), (ob_, ib) = lay
    for i in range(n - 1):
        bp.faces.new((oa[i], oa[i + 1], ia[i + 1], ia[i]))
        bp.faces.new((ob_[i], ib[i], ib[i + 1], ob_[i + 1]))
        bp.faces.new((oa[i], ob_[i], ob_[i + 1], oa[i + 1]))
        bp.faces.new((ia[i], ia[i + 1], ib[i + 1], ib[i]))
    for e in (0, n - 1):
        bp.faces.new((oa[e], ia[e], ib[e], ob_[e]))
    bmesh.ops.recalc_face_normals(bp, faces=bp.faces)
    obs.append(to_object(name + "_wall", bp))
    return obs


hY = CUT["hinge_Y"]
ch = []
# floor pan (sedan layout + 0.2 ground clearance, axles +-4.85): two halves either side of the exhaust tunnel, kick-up to
# a raised rear floor over the tank / rear subframe, rear spring + shock pockets; clear of the 2.98 x 1.15 tyres
TUN = 0.46
for sx in (-1, 1):
    lohi = lambda a_, b_: (min(sx * a_, sx * b_), max(sx * a_, sx * b_))
    x0_, x1_ = lohi(TUN, 3.36); ch.append(box_lo_hi("floor", (x0_, 0.74, -3.45), (x1_, 0.84, 1.83)))
    x0_, x1_ = lohi(TUN, 2.40); ch.append(box_lo_hi("floor_front", (x0_, 0.74, -4.23), (x1_, 0.84, -3.41)))
    x0_, x1_ = lohi(TUN - 0.04, TUN); ch.append(box_lo_hi("tunnel_wall", (x0_, 0.80, -4.23), (x1_, 1.30, 1.83), 0.01))
    x0_, x1_ = lohi(2.40, 3.36); ch.append(box_lo_hi("floor_side", (x0_, 0.74, 1.73), (x1_, 0.84, 3.0)))
    x0_, x1_ = lohi(TUN, 2.42); ch.append(box_lo_hi("kickup", (x0_, 0.80, 1.73), (x1_, 1.50, 1.83), 0.02))
    x0_, x1_ = lohi(2.38, 2.42); ch.append(box_lo_hi("tank_wall", (x0_, 0.80, 1.73), (x1_, 1.50, 3.53), 0.01))
    x0_, x1_ = lohi(1.71, 2.42); ch.append(box_lo_hi("pocket_top", (x0_, 2.50, 4.01), (x1_, 2.60, 5.79), 0.02))
    x0_, x1_ = lohi(1.71, 1.75); ch.append(box_lo_hi("pocket_in", (x0_, 1.40, 4.01), (x1_, 2.60, 5.79), 0.01))
    x0_, x1_ = lohi(1.71, 2.42); ch.append(box_lo_hi("pocket_f", (x0_, 1.40, 4.01), (x1_, 2.60, 4.05), 0.01))
    ch.append(box_lo_hi("pocket_r", (x0_, 1.40, 5.75), (x1_, 2.60, 5.79), 0.01))
ch.append(box_lo_hi("tunnel_top", (-TUN, 1.22, -4.23), (TUN, 1.30, 1.83), 0.02))
ch.append(box_lo_hi("kick_c", (-TUN, 1.20, 1.73), (TUN, 1.50, 1.83), 0.02))
ch.append(box_lo_hi("floor_raised", (-2.42, 1.40, 1.73), (2.42, 1.50, 4.05), 0.03))
ch.append(box_lo_hi("floor_raised", (-1.75, 1.40, 4.03), (1.75, 1.50, 5.77), 0.02))
ch.append(box_lo_hi("floor_raised", (-2.42, 1.40, 5.75), (2.42, 1.50, 6.62), 0.03))
for sx in (-1, 1):
    ch.append(box_lo_hi("sill", (min(sx * 2.95, sx * 3.45), 0.70, -3.05), (max(sx * 2.95, sx * 3.45), 1.15, 3.05), 0.06))
yc = min(shape.f_belt(-4.65), shape.f_belt(-4.1)) - THK - 0.08
ch.append(box_lo_hi("firewall", (-3.0, 1.26, -4.23), (3.0, yc, -4.11), 0.03))
for sx in (-1, 1):
    ch.append(box_lo_hi("firewall_low", (min(sx * 0.46, sx * 3.0), 0.82, -4.23), (max(sx * 0.46, sx * 3.0), 1.28, -4.11), 0.03))
ch.append(box_lo_hi("cowl", (-3.0, yc - 0.12, -4.60), (3.0, yc, -4.11), 0.03))
yx = 1.25                                          # radiator support bottom: above the bumper's lower edge
ch.append(box_lo_hi("splash_front", (-2.36, yx - 0.02, -7.23), (2.36, yx + 0.04, -6.71), 0.02))
for sx in (-1, 1):
    ch.append(box_lo_hi("rail", (min(sx * 2.02, sx * 2.36), 1.98, -7.10), (max(sx * 2.02, sx * 2.36), 2.28, -4.23), 0.05))   # 2nd pass: sedan rails + 0.5 (bay rule) - the drive shafts follow the engine (+0.5) and pass under them
    ch.append(box_lo_hi("rad_side", (min(sx * 1.86, sx * 2.06), yx, -7.83), (max(sx * 1.86, sx * 2.06), 3.56, -7.69), 0.03))
# radiator support frame in front of the radiator (reserved box x +-1.8, Y 1.85..3.75, Z -7.65..-7.05 stays empty)
ch.append(box_lo_hi("xmember", (-2.06, yx, -7.83), (2.06, min(yx + 0.25, 1.50), -7.69), 0.04))
ch.append(box_lo_hi("rad_top", (-2.06, 3.40, -7.83), (2.06, 3.56, -7.69), 0.04))
yt = 1.45                                          # cargo floor above the muffler drum (Y 0.7..1.3)
ch.append(box_lo_hi("cargo_floor", (-3.3, yt, 6.62), (3.3, yt + 0.10, 8.00), 0.03))
ch.append(box_lo_hi("rear_panel", (-2.9, yt, 8.00), (2.9, CUT["bumper_top_R"] + 0.08, 8.12), 0.03))
for ws in WHEEL_S:
    for sx in (-1, 1):
        ch += liner("liner", ws, sx, x0=2.62 if ws < 0 else 2.55, r_hub=0.82 if ws < 0 else 0.72)   # 2nd pass: front wall 2.62 like the sedan (battery x -2.55 clear), hub hole 0.82 (brake dust shield)
for o in ch:
    set_mat(o, MI["liner"] if o.name.startswith("liner") else MI["chassis"])
chassis = join("Chassis", ch)


# review-only wheels: the wheel helper's Rim.glb + Tire.glb (read only) scaled to suv_spec 2.98 x 1.15 - NOT a deliverable
def review_wheels():
    obs = []
    for ws in WHEEL_S:
        for sx in (-1, 1):
            for nm in ("Rim", "Tire"):
                p = os.path.join(WHEEL_DIR, nm + ".glb")
                if not os.path.exists(p):
                    continue
                before = set(sc.objects)
                bpy.ops.import_scene.gltf(filepath=p)
                new = [o for o in sc.objects if o not in before]
                for o in new:
                    if o.type != 'MESH':
                        continue
                    o.data = o.data.copy()
                    o.data.transform(o.matrix_world); o.matrix_world = Matrix.Identity(4)
                    for p_ in o.data.polygons:
                        p_.material_index = 0
                    o.data.materials.clear()
                    k_d, k_w = TYRE_D / 2.75, TYRE_W / 1.045
                    M_ = Matrix.Diagonal((k_w * sx, k_d * (1 if sx > 0 else -1), k_d, 1.0))     # left: turn 180 about up
                    o.data.transform(M_)
                    if sx < 0:
                        pass
                    o.data.transform(Matrix.Translation(BL(sx * 3.25, ARCH_C, ws)))
                    o.name = "rw_" + nm
                    obs.append(o)
                for o in new:
                    if o.type != 'MESH':
                        bpy.data.objects.remove(o)
    return obs


rw = review_wheels()
_tm = bpy.data.materials.new("review_tyre"); _tm.use_nodes = True
_tm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.04, 0.04, 0.04, 1)
_rm = bpy.data.materials.new("review_rim"); _rm.use_nodes = True
_rm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.55, 0.56, 0.58, 1)
for o in rw:
    o.data.materials.append(_rm if "Rim" in o.name else _tm)
review_w = join("ReviewWheels", rw) if rw else None

# ------------------------------------------------------------------ 7. finish + export ---------------------------
PARTS = {"Shell": shell, "Glass": glass, "Hood": hood, "Bumper_F": bump_f, "Bumper_R": bump_r, "Chassis": chassis}
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

# grey export materials (the slot materials stay in the .blend for the colour stage)
grey = bpy.data.materials.new("grey"); grey.use_nodes = True
grey.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.42, 0.42, 0.42, 1)
grey.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.35
gmat = bpy.data.materials.new("glass_grey"); gmat.use_nodes = True
gmat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.08, 0.09, 0.10, 1)
gmat.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.1
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, "suv_body_slots.blend"))
for name, ob in PARTS.items():
    ob.data.materials.clear(); ob.data.materials.append(gmat if name == "Glass" else grey)
    for p in ob.data.polygons:
        p.material_index = 0


def export(path, obs):
    for o in sc.objects:
        o.select_set(o in obs)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_apply=True,
                              export_yup=True)


EXP = os.path.join(OUT, "glb"); os.makedirs(EXP, exist_ok=True)
for name, ob in PARTS.items():
    export(os.path.join(EXP, "suv_%s.glb" % name.lower()), [ob])
export(os.path.join(EXP, "suv_body_all.glb"), list(PARTS.values()))
if review_w is not None:
    export(os.path.join(OUT, "review_wheels.glb"), [review_w])
json.dump(dict(stations=len(st), parts=stats, cut={k: v for k, v in CUT.items()}), open(os.path.join(OUT, "stats.json"), "w"), indent=1)

# ------------------------------------------------------------------ 8. attachments (Roblox car-local coords) ------
R3 = lambda v: [round(float(c), 3) for c in v]
COORD = ("car-local Roblox studs: +X = car right, +Y = up, -Z = car front; origin = ground between the axles "
         "(car_spec / suv_spec). The GLB mesh is already in these coords; a MeshPart imported from it is centred on "
         "mesh_bbox_centre (= mesh_bbox_center, same value), so attachment local position = position - mesh_bbox_centre. "
         "axis = attachment +X (Axis) direction.")
hb = stats["Hood"]; fb_ = stats["Bumper_F"]; rb = stats["Bumper_R"]


def att(pos, axis=(1, 0, 0), note=""):
    d = {"position": R3(pos), "axis": R3(axis)}
    if note:
        d["note"] = note
    return d


def head(part, st_):
    return dict(part=part, coords=COORD, mesh_bbox_centre=st_["bbox_center"], mesh_bbox_center=st_["bbox_center"],
                mesh_bbox_size=st_["bbox_size"])


def hood_top(s_, x_=0.0):
    h = OUTER_BVH.ray_cast(BL(x_, 12.0, s_), Vector((0, 0, -1)))
    return -1 if h[0] is None else h[0].z


def hood_under(s_, x_):
    """hood underside (inner skin) straight above (x_, s_): where the prop rod tip meets it"""
    b_ = bmesh.new(); b_.from_mesh(hood.data); t_ = BVHTree.FromBMesh(b_); b_.free()
    h = t_.ray_cast(BL(x_, 2.0, s_), Vector((0, 0, 1)))
    return -1 if h[0] is None else h[0].z


hinge = (0.0, CUT["hinge_Y"], CUT["hinge_Z"])
ATT = {}
ATT["hood"] = dict(head("Body/Hood", hb),
    Hinge=att(hinge, (1, 0, 0), "hinge axis = +X; rotate +57.8 deg about it to open = hood resting on the prop rod (suv_spec v0.2; swing checked 0..70)"),
    SnapAttachment=att(hinge, (1, 0, 0), "= Hinge (pivot)"),
    **{"Bolt_%d" % (i + 1): att((sx * 2.75, hood_top(sz, sx * 2.75) - THK - 0.01, sz), (0, -1, 0), "hinge bolt, head under the hood")
       for i, (sx, sz) in enumerate([(-1, -4.45), (-1, -4.70), (1, -4.45), (1, -4.70)])},
    Grip_L=att((-2.3, hood_top(-7.55, -2.3) - THK - 0.02, -7.55), (0, -1, 0), "front corner, underside"),
    Grip_R=att((2.3, hood_top(-7.55, 2.3) - THK - 0.02, -7.55), (0, -1, 0), "front corner, underside"),
    PropSocket=att((1.90, round(hood_under(-7.55, 1.90), 3), -7.55), (0, -1, 0),
                   "2nd pass: hood prop rod tip rests here (passenger front); rod = decor/hood_prop_attachments.json, "
                   "hood on the rod = 57.8 deg (suv_spec v0.2)"))
fy0, fy1 = fb_["bbox_min"][1], fb_["bbox_max"][1]
ATT["bumper_f"] = dict(head("Body/Bumper_F", fb_),
    SnapAttachment=att((0.0, 1.9, -7.8), (1, 0, 0), "pivot (suv_spec: (0, 1.9, -7.8))"),
    Bolt_1=att((-2.2, fy1 - 0.06, -7.45), (0, 1, 0), "top bolt, reach with Hood:Open"),
    Bolt_2=att((2.2, fy1 - 0.06, -7.45), (0, 1, 0), "top bolt, reach with Hood:Open"),
    Bolt_3=att((-2.4, fy0 + 0.04, -7.45), (0, -1, 0), "bottom bolt, reach with Lift:Wheel"),
    Bolt_4=att((2.4, fy0 + 0.04, -7.45), (0, -1, 0), "bottom bolt, reach with Lift:Wheel"),
    Grip_L=att((-3.45, (fy0 + fy1) / 2, -7.2), (-1, 0, 0)), Grip_R=att((3.45, (fy0 + fy1) / 2, -7.2), (1, 0, 0)))
ry0, ry1 = rb["bbox_min"][1], rb["bbox_max"][1]
ATT["bumper_r"] = dict(head("Body/Bumper_R", rb),
    SnapAttachment=att((0.0, 2.0, 8.1), (1, 0, 0), "pivot (suv_spec: (0, 2.0, +8.1))"),
    Bolt_1=att((-3.45, 2.25, 6.75), (0, 0, -1), "wheel-house side bolt (faces into the rear wheel well)"),
    Bolt_2=att((3.45, 2.25, 6.75), (0, 0, -1), "wheel-house side bolt (faces into the rear wheel well)"),
    Bolt_3=att((-2.3, ry0 + 0.04, 7.95), (0, -1, 0), "bottom bolt, reach with Lift:Wheel"),
    Bolt_4=att((2.3, ry0 + 0.04, 7.95), (0, -1, 0), "bottom bolt, reach with Lift:Wheel"),
    Grip_L=att((-3.4, (ry0 + ry1) / 2, 7.7), (-1, 0, 0)), Grip_R=att((3.4, (ry0 + ry1) / 2, 7.7), (1, 0, 0)))
cb = stats["Chassis"]
ATT["chassis"] = dict(head("Chassis", cb),
    LiftPoint_FL=att((-3.0, 0.7, -3.0), (0, -1, 0), "sill underside (suv_spec 6)"),
    LiftPoint_FR=att((3.0, 0.7, -3.0), (0, -1, 0), "sill underside"),
    LiftPoint_RL=att((-3.0, 0.7, 3.0), (0, -1, 0), "sill underside"),
    LiftPoint_RR=att((3.0, 0.7, 3.0), (0, -1, 0), "sill underside"),
    Snap_Hood=att(hinge, (1, 0, 0), "matches Hood.SnapAttachment / Hinge"),
    Snap_Bumper_F=ATT["bumper_f"]["SnapAttachment"], Snap_Bumper_R=ATT["bumper_r"]["SnapAttachment"],
    Snap_Wheel_FL=att((-3.25, ARCH_C, -4.85)), Snap_Wheel_FR=att((3.25, ARCH_C, -4.85)),
    Snap_Wheel_RL=att((-3.25, ARCH_C, 4.85)), Snap_Wheel_RR=att((3.25, ARCH_C, 4.85)),
    Seat_Driver=att((-1.6, 1.9, -0.5), note="seat surface Y 1.9 (suv_spec 1)"), Seat_Passenger=att((1.6, 1.9, -0.5)),
    Exit_L=att((-5.35, 0.0, -0.5)), Exit_R=att((5.35, 0.0, -0.5)))
AD = os.path.join(OUT, "attachments"); os.makedirs(AD, exist_ok=True)
for k, v in ATT.items():
    json.dump(v, open(os.path.join(AD, "%s_attachments.json" % k), "w"), indent=1)
hood_open = hood.copy(); hood_open.data = hood.data.copy(); hood_open.name = "Hood_open70"; sc.collection.objects.link(hood_open)
hood_open.data.transform(Matrix.Translation(BL(*hinge)) @ Matrix.Rotation(math.radians(70), 4, 'X') @ Matrix.Translation(-BL(*hinge)))
zs_ = [v.co.z for v in hood_open.data.vertices]
print("hood open 70: front end height", round(max(zs_), 2))
others = [o for o in PARTS.values() if o is not hood]
export(os.path.join(OUT, "review_hood_open.glb"), others + [hood_open])
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, "suv_body.blend"))
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
    hb_ = hb0.copy()
    M_ = Matrix.Translation(BL(*hinge)) @ Matrix.Rotation(math.radians(ang), 4, 'X') @ Matrix.Translation(-BL(*hinge))
    bmesh.ops.transform(hb_, matrix=M_, verts=hb_.verts)
    th = BVHTree.FromBMesh(hb_)
    hits = len(th.overlap(T_body))
    dmin = min((T_glass.find_nearest(v.co)[3] for v in hb_.verts), default=9)
    dmin_s = 9.0
    if ang > 0:
        for v in hb_.verts:
            if -v.co.y > -4.6:
                dmin_s = min(dmin_s, T_shell.find_nearest(v.co)[3])
    swing.append((ang, hits, round(dmin, 3), round(dmin_s, 3)))
    hb_.free()
print("HOOD SWING (deg, overlapping tri pairs with shell+glass+chassis, min dist to glass, min dist to shell near cowl):")
for r_ in swing:
    print("  ", r_)
gaps = {"side": [], "rear(cowl)": [], "front(lamp)": []}
for v in hb0.verts:
    if OUTER_BVH.find_nearest(v.co)[3] > 0.004:
        continue
    d = T_shell.find_nearest(v.co)[3]
    if d > 0.2:
        continue
    x, Y, s_ = CAR(v.co)
    k = "rear(cowl)" if s_ > -4.55 else ("front(lamp)" if (s_ < -7.5 and abs(x) < 2.6) or Y < CUT["hood_front_Y"] + 0.05 else "side")
    gaps[k].append(d)
GAPS = {k: (round(min(v), 3), round(sum(v) / len(v), 3), round(max(v), 3), len(v)) for k, v in gaps.items() if v}
print("HOOD CLOSED GAPS (min, mean, max, n):", GAPS)
json.dump(dict(swing=swing, closed_gaps=GAPS, hinge=hinge, open70_front_height=round(max(zs_), 3)),
          open(os.path.join(OUT, "hood_check.json"), "w"), indent=1)
