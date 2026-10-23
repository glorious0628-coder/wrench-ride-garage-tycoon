# Engine-bay + underbody decor for the SUV (wr-3d-suv 2nd pass, 10-21) = the sedan's decor (tools/blender/wr_body/
# build_decor.py, same pieces / colours / groups: Deco_EngineTop, Deco_EngineLower, Deco_Transaxle, Deco_EngineBay,
# Deco_FrontSubframe, Deco_Underbody, Deco_RearAxle + Moving/HoodProp) fitted to the SUV body (suv_spec v0.2):
#   engine bay: sedan place + (0, +0.5, +0.15) (suv_spec 4); the SUV bay is 0.5 shorter at the firewall (Z -7.8..-4.2,
#     firewall front face -4.23 vs the sedan's -3.98), so the firewall-side pieces (brake booster + master cylinder +
#     reservoir, strut towers) go 0.40 further forward (0.35 in the brief; 0.40 keeps the sedan's 0.015 gap to the firewall)
#   underbody: Y +0.2 (ground clearance), wheelbase 9.7: front suspension around the axle Z -4.85 (+0.15), the part between
#     the axle and the firewall squeezed (sedan -5.0..-3.95 -> -4.85..-4.27), floor / tunnel / tank stretched to the SUV
#     floor (-3.98..1.95 -> -4.23..1.83), rear axle -0.15, exhaust tail kept on the muffler (suv_spec (0.3, 1.0, 7.6))
#   hand-placed in SUV coords where the short bay is crowded: downpipe, steering rack, subframe rear cross member,
#     drive shafts, harness, battery tray leg (rails are at Y 1.98..2.28)
# Battery (-2.2, 2.85 bottom, -5.55) and Radiator (0, 2.8, -7.35) (suv_spec 4) are repair parts by another helper:
# their boxes stay EMPTY (checked), the tray / cable ends / hose ends meet them.
#   blender --background --factory-startup --python tools/blender/wr_suv/build_decor_suv.py -- <suv_body.blend> <out_dir>
import bpy, bmesh, sys, os, math, json
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

a = sys.argv[sys.argv.index("--") + 1:]
SRC, OUT = os.path.abspath(a[0]), os.path.abspath(a[1])
os.makedirs(OUT, exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=SRC)
sc = bpy.context.scene
for o in list(sc.objects):
    if o.type != 'MESH' or o.name.startswith("Hood_open"):
        bpy.data.objects.remove(o)
WHEELS = sc.objects.get("ReviewWheels")
BODY = {o.name: o for o in sc.objects if o is not WHEELS}


# ------------------------------------------------------------------ sedan -> SUV place maps (car coords x, Y, s) ----
def _pw(table, s):
    for (a0, b0), (a1, b1) in zip(table[:-1], table[1:]):
        if a0 <= s <= a1:
            return b0 + (b1 - b0) * (s - a0) / (a1 - a0)
    return s + (table[0][1] - table[0][0] if s < table[0][0] else table[-1][1] - table[-1][0])


FW = 0.40                                                       # firewall-side pieces: extra forward shift
Z_BAY = lambda x, Y, s: (x, Y + 0.5, s + 0.15)
Z_FW = lambda x, Y, s: (x, Y + 0.5, s + 0.15 - FW)
_FT = [(-9.0, -8.85), (-5.0, -4.85), (-3.95, -4.27)]           # front suspension / subframe (squeezed behind the axle)
Z_FS = lambda x, Y, s: (x, Y + 0.2, _pw(_FT, s))
_UT = [(-3.98, -4.23), (1.95, 1.83), (2.05, 1.90), (6.05, 5.90), (6.85, 6.85), (9.0, 9.0)]
Z_UB = lambda x, Y, s: (x, Y + 0.2, _pw(_UT, s))               # floor, tunnel, tank, rear axle, exhaust
ZONE = None                                                     # None = coordinates are already SUV


def BL(x, Y, s):
    if ZONE is not None:
        x, Y, s = ZONE(x, Y, s)
    return Vector((x, -s, Y))


def CAR(v):
    return (v.x, v.z, -v.y)


# ------------------------------------------------------------------ materials (codes measured on the bay concept) ---
# same colour codes as the sedan decor (measured on the sedan bay / bottom concepts; the SUV hero bay shows the same parts)
_SW = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(OUT))), "sedan_body", "work")   # art/3d/sedan_body/work
_bj = os.path.join(_SW, "bay_colours.json")
bc = json.load(open(_bj)) if os.path.exists(_bj) else {}
H = lambda k, d: bc.get(k, {}).get("hex", d)
_uj = os.path.join(_SW, "under_colours.json")
uc = json.load(open(_uj)) if os.path.exists(_uj) else {}
U = lambda k, d: uc.get(k, {}).get("hex", d)
print("colour sources", _bj, os.path.exists(_bj), _uj, os.path.exists(_uj))
DM = [  # name, hex, rough, metal, paint, emit
    ("paint", "#E6E6E6", 0.40, 0.0, 1, 0),                         # strut towers: body colour (tinted like the body)
    ("engine_cover", H("engine_cover", "#3C3B3C"), 0.55, 0.0, 0, 0),
    ("valve_cover", H("valve_cover", "#BAB9BE"), 0.35, 0.6, 0, 0),
    ("block", "#A7A9AD", 0.50, 0.5, 0, 0),
    ("coil", H("coil", "#3C4049"), 0.45, 0.0, 0, 0),
    ("intake_black", H("intake_runner", "#313236"), 0.55, 0.0, 0, 0),
    ("alu_bright", H("throttle", "#B3B3B9"), 0.30, 0.7, 0, 0),
    ("heat_shield", H("heat_shield", "#B7B2B4"), 0.35, 0.8, 0, 0),
    ("alternator", H("alternator", "#D2D1D5"), 0.35, 0.6, 0, 0),
    ("belt_black", H("belt", "#312F33"), 0.80, 0.0, 0, 0),
    ("box_black", H("air_box", "#252527"), 0.70, 0.0, 0, 0),
    ("hose_black", H("hose", "#2A2D33"), 0.65, 0.0, 0, 0),
    ("rubber_black", H("booster", "#1A1818"), 0.60, 0.0, 0, 0),
    ("tank_white", H("reservoir_white", "#E4DFDA"), 0.30, 0.0, 0, 0),
    ("coolant_white", H("coolant_tank", "#E0D9E4"), 0.30, 0.0, 0, 0),     # pinkish translucent white (concept)
    ("coolant_pink", H("coolant_pink", "#CCB1C2"), 0.30, 0.0, 0, 0),
    ("washer_white", H("washer_white", "#E4EDF9"), 0.30, 0.0, 0, 0),
    ("cap_yellow", H("cap_yellow", "#FCD74D"), 0.40, 0.0, 0, 0),
    ("cap_blue", H("cap_blue", "#3B88FC"), 0.40, 0.0, 0, 0),
    ("ac_pipe", H("ac_pipe", "#D2D5DC"), 0.30, 0.8, 0, 0),
    ("cable_red", "#D2262B", 0.50, 0.0, 0, 0),
    ("condenser", "#8F949B", 0.50, 0.5, 0, 0),
    ("transaxle", "#9A9C9F", 0.55, 0.4, 0, 0),
    ("compressor", H("compressor", "#B4B2B4"), 0.40, 0.6, 0, 0),     # AC compressor (a shade darker than the alternator)
    # underbody (values kept apart: floor #2B2C2F < boots #252425 rubber < frames #3B3B3C < tank / covers #43-#48)
    ("frame_black", "#3B3B3C", 0.50, 0.3, 0, 0),                    # subframes, stabilizers (concept #2D..#47)
    ("under_black", U("undercover", "#484746"), 0.90, 0.0, 0, 0),   # textured plastic undercovers (matte)
    ("tank_black", U("fuel_tank", "#434342"), 0.40, 0.0, 0, 0),     # fuel tank (a bit glossy -> reads apart)
    ("exhaust", "#B5A08C", 0.50, 0.55, 0, 0),                       # champagne steel (concept pipe mid-tone); finish = muffler
    ("shield_silver", U("heat_shield", "#AEADAE"), 0.45, 0.7, 0, 0),
    ("arm_grey", U("front_arm", "#868686"), 0.45, 0.5, 0, 0),       # front cast arms
    ("arm_dark", U("rear_arm", "#636463"), 0.50, 0.4, 0, 0),        # rear links
    ("boot_black", U("boot", "#252425"), 0.70, 0.0, 0, 0),
]
DI = {m[0]: i for i, m in enumerate(DM)}
MOBJ = []
_lin = lambda v: v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
for nm, hx, ro, me_, pa, em in DM:
    m = bpy.data.materials.new("d_" + nm); m.use_nodes = True
    c = tuple(int(hx[i:i + 2], 16) / 255 for i in (1, 3, 5))
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*[_lin(v) for v in c], 1); b.inputs["Roughness"].default_value = ro
    b.inputs["Metallic"].default_value = me_
    m["wr_hex"] = hx; m["wr_rough"] = ro; m["wr_metal"] = me_; m["wr_paint"] = pa; m["wr_emit"] = em
    m.use_backface_culling = True
    MOBJ.append(m)


def obj(name, bm, mat):
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new(name, me); sc.collection.objects.link(ob)
    for m in MOBJ:
        me.materials.append(m)
    for p in me.polygons:
        p.material_index = DI[mat] if isinstance(mat, str) else mat(CAR(p.center))
        p.use_smooth = True
    return ob


# ------------------------------------------------------------------ primitives (car coords x, Y, s) ---------------
def rbox(name, size, center, radius, mat, segs=2, rot=None):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    sx, sY, ss = size
    bmesh.ops.scale(bm, vec=Vector((sx, ss, sY)), verts=bm.verts)
    if radius > 0.001:
        bmesh.ops.bevel(bm, geom=list(bm.verts) + list(bm.edges), offset=min(radius, 0.49 * min(size)), segments=segs,
                        profile=0.5, affect='EDGES', clamp_overlap=True)
    if rot is not None:
        bmesh.ops.rotate(bm, verts=bm.verts, cent=(0, 0, 0), matrix=rot)
    bmesh.ops.translate(bm, vec=BL(*center), verts=bm.verts)
    return obj(name, bm, mat)


AX = {"x": Matrix.Rotation(math.pi / 2, 4, 'Y'), "Y": Matrix.Identity(4), "s": Matrix.Rotation(math.pi / 2, 4, 'X')}


def lathe(name, prof, center, axis, mat, segs=20):
    """surface of revolution, prof = [(r, h)] from one end to the other (r 0 = closed pole)"""
    bm = bmesh.new(); rings = []
    for r, h in prof:
        if r < 1e-6:
            rings.append([bm.verts.new((0, 0, h))])
        else:
            rings.append([bm.verts.new((r * math.cos(2 * math.pi * i / segs), r * math.sin(2 * math.pi * i / segs), h))
                          for i in range(segs)])
    for A_, B_ in zip(rings[:-1], rings[1:]):
        if len(A_) == 1:
            for i in range(segs):
                bm.faces.new((A_[0], B_[i], B_[(i + 1) % segs]))
        elif len(B_) == 1:
            for i in range(segs):
                bm.faces.new((A_[i], B_[0], A_[(i + 1) % segs]))
        else:
            for i in range(segs):
                bm.faces.new((A_[i], A_[(i + 1) % segs], B_[(i + 1) % segs], B_[i]))
    if len(rings[0]) > 1:
        bm.faces.new(rings[0])
    if len(rings[-1]) > 1:
        bm.faces.new(list(reversed(rings[-1])))
    bmesh.ops.transform(bm, matrix=AX[axis], verts=bm.verts)
    bmesh.ops.translate(bm, vec=BL(*center), verts=bm.verts)
    return obj(name, bm, mat)


def cyl(name, r, length, center, axis, mat, segs=16, bevel=0.02):
    e = min(bevel, r * 0.4, length * 0.3); h = length / 2
    prof = [(0, -h), (r - e, -h), (r, -h + e), (r, h - e), (r - e, h), (0, h)]
    return lathe(name, prof, center, axis, mat, segs)


def catmull(pts, n=10):
    P = [Vector(p) for p in pts]
    P = [P[0] + (P[0] - P[1])] + P + [P[-1] + (P[-1] - P[-2])]
    out = []
    for i in range(1, len(P) - 2):
        p0, p1, p2, p3 = P[i - 1], P[i], P[i + 1], P[i + 2]
        for k in range(n):
            t = k / n
            out.append(0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t ** 3))
    out.append(P[-2])
    return out


def tube(name, pts, r, mat, around=8, n=4, rings=()):
    """smooth hose along car-coord points (Catmull-Rom), round section, closed ends; rings = [(t, extra r)] ribs"""
    path = [BL(*p) for p in catmull(pts, n)]
    bm = bmesh.new(); loops = []
    up = Vector((0, 0, 1))
    for i, p in enumerate(path):
        t = (path[min(i + 1, len(path) - 1)] - path[max(i - 1, 0)]).normalized()
        side = t.cross(up)
        if side.length < 1e-3:
            side = t.cross(Vector((1, 0, 0)))
        side.normalize(); u = side.cross(t).normalized()
        rr = r
        for tt, er in rings:
            if abs(i / (len(path) - 1) - tt) < 0.6 / len(path):
                rr = r + er
        loops.append([bm.verts.new(p + (side * math.cos(2 * math.pi * k / around) + u * math.sin(2 * math.pi * k / around)) * rr)
                      for k in range(around)])
    for A_, B_ in zip(loops[:-1], loops[1:]):
        for k in range(around):
            bm.faces.new((A_[k], A_[(k + 1) % around], B_[(k + 1) % around], B_[k]))
    bm.faces.new(list(reversed(loops[0]))); bm.faces.new(loops[-1])
    return obj(name, bm, mat)


def belt(name, pulleys, x, width, thick, mat, samp=64):
    """flat belt around pulleys (Y, s, r) in the plane x = const: convex hull of the pulley rims"""
    pts = []
    for (Y, s, r) in pulleys:
        for k in range(samp):
            a_ = 2 * math.pi * k / samp
            pts.append((s + (r + thick / 2) * math.cos(a_), Y + (r + thick / 2) * math.sin(a_)))
    pts = sorted(set(pts))

    def cross(o, a1, b1):
        return (a1[0] - o[0]) * (b1[1] - o[1]) - (a1[1] - o[1]) * (b1[0] - o[0])
    lo, hi = [], []
    for p in pts:
        while len(lo) >= 2 and cross(lo[-2], lo[-1], p) <= 0:
            lo.pop()
        lo.append(p)
    for p in reversed(pts):
        while len(hi) >= 2 and cross(hi[-2], hi[-1], p) <= 0:
            hi.pop()
        hi.append(p)
    hull = lo[:-1] + hi[:-1]
    # resample evenly
    import numpy as np
    H_ = np.array(hull + [hull[0]]); d = np.r_[0, np.cumsum(np.linalg.norm(np.diff(H_, axis=0), axis=1))]
    tt = np.linspace(0, d[-1], 40, endpoint=False)
    ring = np.stack([np.interp(tt, d, H_[:, 0]), np.interp(tt, d, H_[:, 1])], 1)
    cen = ring.mean(0)
    bm = bmesh.new(); L = []
    for s_, Y_ in ring:
        n_ = Vector((s_ - cen[0], Y_ - cen[1])).normalized()
        q = []
        for dx in (-width / 2, width / 2):
            for dr in (-thick / 2, thick / 2):
                q.append(bm.verts.new(BL(x + dx, Y_ + n_.y * dr, s_ + n_.x * dr)))
        L.append(q)
    m = len(L)
    for i in range(m):
        A_, B_ = L[i], L[(i + 1) % m]
        for (p, q) in ((0, 1), (1, 3), (3, 2), (2, 0)):
            bm.faces.new((A_[p], A_[q], B_[q], B_[p]))
    return obj(name, bm, mat)


def torus(name, R, r, center, axis, mat, seg=14, rs=6):
    bm = bmesh.new(); L = []
    for i in range(seg):
        a_ = 2 * math.pi * i / seg
        L.append([bm.verts.new(((R + r * math.cos(2 * math.pi * k / rs)) * math.cos(a_), (R + r * math.cos(2 * math.pi * k / rs)) * math.sin(a_),
                                r * math.sin(2 * math.pi * k / rs))) for k in range(rs)])
    for i in range(seg):
        A_, B_ = L[i], L[(i + 1) % seg]
        for k in range(rs):
            bm.faces.new((A_[k], A_[(k + 1) % rs], B_[(k + 1) % rs], B_[k]))
    bmesh.ops.transform(bm, matrix=AX[axis], verts=bm.verts)
    bmesh.ops.translate(bm, vec=BL(*center), verts=bm.verts)
    return obj(name, bm, mat)


GROUPS = {"Deco_EngineTop": [], "Deco_EngineLower": [], "Deco_Transaxle": [], "Deco_EngineBay": []}
ZONE = Z_BAY                # engine bay: sedan places + (0, +0.5, +0.15)
T, Lw, Tx, Bay = (GROUPS[k] for k in GROUPS)
EX = 0.3                    # engine centre x (car_spec: slightly right)

# ---------------- engine (block + oil pan + head = lower / top)
Lw.append(rbox("block", (2.6, 1.30, 1.10), (EX, 1.95, -5.45), 0.10, "block", 2))
Lw.append(rbox("oilpan", (2.2, 0.50, 0.95), (EX + 0.05, 1.05, -5.45), 0.12, "block", 2))
Lw.append(cyl("drain_plug", 0.06, 0.08, (EX + 0.6, 0.78, -5.6), "Y", "box_black", 10))
T.append(rbox("head", (2.5, 0.36, 1.00), (EX, 2.75, -5.40), 0.08, "block", 2))
T.append(rbox("valve_cover", (2.4, 0.27, 0.90), (EX, 3.03, -5.36), 0.11, "valve_cover", 3))
for i, dx in enumerate((-0.825, -0.275, 0.275, 0.825)):
    T.append(rbox("coil", (0.21, 0.30, 0.24), (EX + dx, 3.27, -5.15), 0.05, "coil", 1))
T.append(rbox("engine_cover", (2.1, 0.17, 0.52), (EX + 0.05, 3.245, -5.70), 0.075, "engine_cover", 3))
T.append(cyl("oil_cap", 0.14, 0.08, (EX + 0.85, 3.36, -5.70), "Y", "intake_black", 20))
# intake: 4 runners from the head front, down into the plenum at the front, throttle at the left end
for i, dx in enumerate((-0.80, -0.30, 0.20, 0.70)):
    x = EX + dx
    T.append(tube("runner", [(x, 2.80, -5.93), (x, 2.93, -6.15), (x, 2.88, -6.40), (x, 2.65, -6.56), (x, 2.40, -6.50)], 0.15, "intake_black", 8, 4))
T.append(cyl("plenum", 0.20, 2.10, (EX + 0.0, 2.25, -6.45), "x", "intake_black", 14, 0.06))
T.append(cyl("throttle", 0.20, 0.30, (EX - 1.20, 2.25, -6.45), "x", "alu_bright", 14, 0.03))
# dipstick (yellow ring) in front of the engine cover + its tube
T.append(torus("dipstick", 0.075, 0.024, (EX + 0.5, 3.25, -6.02), "s", "cap_yellow", 10, 5))
T.append(tube("dip_tube", [(EX + 0.5, 3.17, -6.02), (EX + 0.5, 2.95, -5.98), (EX + 0.5, 2.6, -5.95)], 0.025, "intake_black", 6, 3))
# exhaust heat shield behind the engine (firewall side), leaning back
Lw.append(rbox("heat_shield", (2.1, 1.00, 0.07), (EX + 0.1, 2.45, -4.83), 0.03, "heat_shield", 2,
               rot=Matrix.Rotation(math.radians(-14), 3, 'X')))
for k in range(3):
    Lw.append(rbox("shield_rib", (1.9, 0.05, 0.05), (EX + 0.1, 2.05 + k * 0.3, -4.78 - k * 0.07), 0.02, "heat_shield", 1))
# belt drive at the right end, one readable zone from above (GPT r1: alternator + belt + AC compressor): timing cover,
# belt plane x = 1.95 outboard of the intake, alternator high at the front-right, AC compressor in front of it
XB = EX + 1.62
Lw.append(rbox("timing_cover", (0.27, 1.15, 1.00), (EX + 1.42, 2.00, -5.50), 0.08, "block", 2))
PUL = [(1.45, -5.55, 0.30), (2.85, -6.05, 0.13), (2.05, -6.55, 0.20), (2.35, -5.40, 0.16), (2.55, -6.45, 0.09)]
for (Y, s_, r) in PUL:
    Lw.append(cyl("pulley", r, 0.13, (XB, Y, s_), "x", "alu_bright" if r < 0.25 else "block", 14 if r > 0.12 else 8, 0.02))
Lw.append(belt("belt", PUL, XB, 0.14, 0.04, "belt_black"))
# alternator: one lathe with cooling ribs in the profile (reads as an alternator from above)
_ap = [(0, -0.24), (0.24, -0.24), (0.28, -0.20)]
for k in range(3):
    z0 = -0.12 + k * 0.10
    _ap += [(0.28, z0), (0.305, z0 + 0.02), (0.305, z0 + 0.05), (0.28, z0 + 0.07)]
_ap += [(0.28, 0.20), (0.24, 0.24), (0, 0.24)]
Lw.append(lathe("alternator", _ap, (XB - 0.27, 2.85, -6.05), "x", "alternator", 14))
Lw.append(cyl("ac_comp", 0.24, 0.44, (XB - 0.28, 2.05, -6.55), "x", "compressor", 16, 0.05))
Lw.append(rbox("ac_comp_head", (0.20, 0.16, 0.22), (XB - 0.40, 2.30, -6.62), 0.04, "box_black", 1))   # pipe fitting on top
Lw.append(rbox("mount_r", (0.62, 0.24, 0.36), (EX + 1.62, 2.98, -5.15), 0.06, "rubber_black", 2))

# ---------------- transaxle (left of the engine, under the battery)
Tx.append(rbox("transaxle", (0.93, 0.95, 1.00), (-1.515, 1.66, -5.45), 0.26, "transaxle", 2))
Tx.append(cyl("bellhousing", 0.56, 0.22, (-1.08, 1.75, -5.45), "x", "transaxle", 16, 0.06))
Tx.append(rbox("mount_l", (0.40, 0.18, 0.36), (-1.70, 2.20, -5.05), 0.05, "rubber_black", 2))

# ---------------- engine bay (driver side: air box, battery tray, fuse box, booster + master; passenger: tanks)
# SUV: air box a bit narrower (0.85) between the bumper-seam backing strip (x 2.75) and the radiator box (x 1.8)
Bay.append(rbox("air_box", (0.85, 0.55, 1.05), (-2.30, 2.72, -6.98), 0.11, "box_black", 2))
Bay.append(rbox("air_box_lid", (0.89, 0.27, 1.09), (-2.30, 3.08, -6.98), 0.11, "intake_black", 2))
Bay.append(cyl("air_outlet", 0.16, 0.18, (-1.86, 2.85, -6.80), "x", "box_black", 14, 0.03))
Bay.append(tube("intake_hose", [(-1.79, 2.85, -6.80), (-1.58, 2.80, -6.74), (-1.38, 2.52, -6.55), (-1.06, 2.25, -6.45)], 0.18,
                "hose_black", 10, 5, rings=[(0.25, 0.02), (0.45, 0.02), (0.65, 0.02)]))
Bay.append(rbox("bat_tray", (0.72, 0.10, 0.99), (-2.20, 2.295, -5.70), 0.03, "box_black", 1))   # v0.8: battery long side front-back
ZONE = None                 # SUV: the leg stands on the frame rail (top 2.28) up to the tray (bottom 2.745)
Bay.append(rbox("bat_tray_leg", (0.10, 0.465, 0.10), (-2.30, 2.5125, -5.93), 0.02, "box_black", 1))
ZONE = Z_BAY
Bay.append(rbox("fuse_box", (0.40, 0.56, 0.90), (-2.98, 3.23, -5.70), 0.07, "box_black", 2))
Bay.append(rbox("fuse_lid", (0.42, 0.06, 0.92), (-2.98, 3.53, -5.70), 0.03, "engine_cover", 1))
# battery cables end at the battery's + (outboard front) and - (inboard front) terminal spots, top 3.1 (car_spec)
Bay.append(tube("cable_pos", [(-2.80, 3.22, -6.10), (-2.45, 3.32, -6.27), (-2.08, 3.30, -6.16), (-1.95, 3.17, -6.00)], 0.05, "cable_red", 6, 4))
Bay.append(tube("cable_neg", [(-1.95, 3.17, -5.40), (-1.82, 3.27, -5.30), (-1.45, 2.95, -5.30), (-1.15, 2.45, -5.40)], 0.05, "hose_black", 6, 4))
# brake booster (drum on the firewall) + master cylinder + reservoir with the yellow cap
ZONE = Z_FW                 # SUV firewall is 0.25 further forward than the sedan's: these pieces go FW further forward
Bay.append(lathe("booster", [(0, -0.215), (0.30, -0.215), (0.43, -0.17), (0.46, -0.08), (0.46, 0.08), (0.43, 0.17), (0.30, 0.215), (0, 0.215)],
                 (-1.55, 2.85, -4.21), "s", "rubber_black", 16))
Bay.append(cyl("master_cyl", 0.12, 0.52, (-1.55, 2.95, -4.68), "s", "alu_bright", 16, 0.03))
Bay.append(rbox("brake_res", (0.42, 0.26, 0.32), (-1.55, 3.22, -4.72), 0.06, "tank_white", 2))
Bay.append(cyl("brake_cap", 0.09, 0.08, (-1.55, 3.39, -4.72), "Y", "cap_yellow", 16, 0.02))
# strut towers (body colour) with the top nuts; SUV: just behind the axle (Z -4.68, between the battery and the
# firewall, under the cowl), slimmer, with a skirt down to the higher wheel-arch top (3.15)
ZONE = None
TOWER_Z = -4.68
for sx in (-1, 1):
    Bay.append(lathe("strut_tower", [(0, 4.01), (0.28, 4.01), (0.33, 3.97), (0.36, 3.86), (0.40, 3.62), (0.42, 3.48), (0.42, 3.15)],
                     (sx * 2.75, 0.0, TOWER_Z), "Y", "paint", 16))
    Bay.append(lathe("strut_nut_c", [(0, 4.09), (0.07, 4.09), (0.07, 4.00)], (sx * 2.75, 0.0, TOWER_Z), "Y", "alu_bright", 6))
    for k in range(3):
        a_ = 2 * math.pi * k / 3 + 0.5
        Bay.append(lathe("strut_nut", [(0, 4.06), (0.045, 4.06), (0.045, 4.00)], (sx * 2.75 + 0.18 * math.cos(a_), 0.0, TOWER_Z + 0.18 * math.sin(a_)), "Y", "alu_bright", 6))
# coolant reservoir (white, pink coolant below the level line) + cap; washer tank + blue cap
ZONE = Z_BAY
Bay.append(rbox("coolant_tank", (0.75, 0.55, 0.85), (2.68, 3.225, -5.65), 0.10, lambda c: DI["coolant_pink"] if c[1] < 3.80 else DI["coolant_white"], 2))
Bay.append(cyl("coolant_cap", 0.11, 0.09, (2.55, 3.54, -5.87), "Y", "rubber_black", 18, 0.02))       # SUV: tank 0.12 forward
Bay.append(rbox("washer_tank", (0.60, 0.75, 0.70), (2.60, 2.79, -6.60), 0.10, "washer_white", 2))
Bay.append(cyl("washer_neck", 0.07, 0.12, (2.62, 3.15, -6.50), "Y", "washer_white", 12, 0.01))
Bay.append(cyl("washer_cap", 0.12, 0.08, (2.62, 3.24, -6.50), "Y", "cap_blue", 18, 0.02))
# radiator hoses (ends meet the reserved radiator box's tanks), reservoir hose, AC pipe, condenser, harness
# radiator hoses end at the real radiator's necks (art/3d/radiator json: upper (1.77, 2.85, -7.69) car-right tank,
# lower (-1.77, 1.70, -7.69) car-left); the upper hose drops between the intake and the alternator and runs in front of
# the AC compressor, so the belt zone stays open from above
Bay.append(tube("upper_hose", [(1.20, 3.08, -5.86), (1.28, 2.95, -6.12), (1.29, 2.62, -6.50), (1.31, 2.60, -7.02), (1.85, 2.75, -7.15),
                               (1.98, 2.84, -7.42), (1.90, 2.86, -7.69)], 0.10, "hose_black", 8, 3))
Bay.append(tube("lower_hose", [(-1.90, 1.70, -7.69), (-1.93, 1.66, -7.42), (-1.70, 1.58, -7.05), (-1.05, 1.62, -6.32), (-0.62, 1.78, -6.02)], 0.11, "hose_black", 8, 3))
Bay.append(tube("coolant_hose", [(2.40, 2.98, -6.07), (2.20, 3.02, -6.30), (2.17, 3.06, -6.85), (2.02, 3.12, -7.25), (1.86, 3.16, -7.50)], 0.045, "hose_black", 6, 4))   # to the radiator filler neck (cap 1.57, 3.27, -7.67)
Bay.append(tube("ac_pipe", [(XB - 0.40, 2.36, -6.66), (1.95, 2.42, -7.02), (2.12, 2.50, -7.40), (2.00, 2.62, -7.82), (1.72, 2.70, -7.87)], 0.045, "ac_pipe", 6, 3))
Bay.append(rbox("condenser", (3.50, 1.42, 0.05), (0.0, 2.16, -7.865), 0.015, "condenser", 1))
ZONE = None                 # SUV: harness passes behind the (moved) brake reservoir and in front of the booster
Bay.append(tube("harness", [(-2.80, 3.82, -5.20), (-2.25, 3.80, -4.98), (-1.55, 3.80, -4.74), (-0.90, 3.72, -4.79), (-0.40, 3.70, -4.81),
                            (0.60, 3.68, -4.81), (1.55, 3.64, -4.83)], 0.055, "hose_black", 6, 3))


# =============================== underbody (car_spec §5 Deco_FrontSubframe / Deco_Underbody / Deco_RearAxle) ========
# seen from Lift:Under (6-view bottom cell): engine + transaxle open from below (oil drain plug), black subframe with
# L arms, rack + boots, stabilizer, drive shafts; tunnel exhaust (catalyst -> resonator under a silver heat shield ->
# over the tank -> right to the muffler inlet flange); black undercovers either side; saddle fuel tank on 2 straps;
# rear subframe (X brace) + 3 links + trailing arm + stabilizer + adjustment cams. Repair parts keep their room:
# Strut_FL/FR, Shock_RL/RR, Spring_RL/RR (ROOMS below), Muffler (art/3d/muffler mesh), wheels / hubs (wheel helper).
GROUPS.update({"Deco_FrontSubframe": [], "Deco_Underbody": [], "Deco_RearAxle": []})
FS, UB, RA = GROUPS["Deco_FrontSubframe"], GROUPS["Deco_Underbody"], GROUPS["Deco_RearAxle"]


def bar(name, A, B, w, t, mat, radius=0.03, segs=1):
    """rounded box from A to B (car coords), width w (sideways), thickness t (up); ends mapped by the current ZONE"""
    global ZONE
    z = ZONE
    a_, b_ = BL(*A), BL(*B); d = b_ - a_
    q = d.to_track_quat('X', 'Z').to_matrix()
    ZONE = None
    ob = rbox(name, (d.length, t, w), CAR((a_ + b_) / 2), radius, mat, segs, rot=q)
    ZONE = z
    return ob


def boot(name, x0, x1, Y, s_, r, mat="boot_black"):
    """rubber CV / rack boot along x from x0 to x1 (3 ribs)"""
    L_ = x1 - x0; pr = [(0, 0.0)]
    for k, f in enumerate((0.0, 0.25, 0.45, 0.65, 1.0)):
        pr.append(((r * 0.55 if k in (0, 4) else (r if k % 2 else r * 0.80)), f * L_))
    pr.append((0, L_))
    return lathe(name, pr, (x0, Y, s_), "x", mat, 8)


def scale_x(ob, f):
    c = sum((v.co for v in ob.data.vertices), Vector()) / len(ob.data.vertices)
    ob.data.transform(Matrix.Translation(c) @ Matrix.Diagonal((f, 1, 1, 1)) @ Matrix.Translation(-c))
    return ob


# ---------------- front subframe: trapezoid ladder under the engine; SUV: rear cross member dips UNDER the downpipe
# (the short SUV bay has no room for the sedan's arch over it), mounts up to the frame rails (SUV bottom 1.98)
ZONE = Z_FS
for sx in (-1, 1):
    FS.append(bar("sf_side", (sx * 1.62, 0.73, -6.42), (sx * 1.70, 0.73, -4.18), 0.22, 0.22, "frame_black", 0.05, 1))
    for s_ in (-6.25, -4.15):
        FS.append(bar("sf_ear", (sx * 1.66, 0.80, s_), (sx * 2.16, 0.80, s_), 0.20, 0.14, "frame_black", 0.0, 1))
        FS.append(rbox("sf_mount", (0.16, 0.98, 0.16), (sx * 2.16, 1.29, s_), 0.0, "rubber_black", 1))
FS.append(bar("sf_front", (-1.72, 0.72, -6.33), (1.72, 0.72, -6.33), 0.26, 0.20, "frame_black", 0.05, 1))
ZONE = None
FS.append(tube("sf_rear", [(-1.80, 0.94, -4.40), (-0.62, 0.90, -4.40), (0.0, 0.86, -4.40), (0.62, 0.90, -4.40), (1.80, 0.94, -4.40)],
               0.11, "frame_black", 6, 2))
ZONE = Z_FS
# L-shaped lower control arms (cast, grey) + bushings + ball joints (meet the knuckle line x +-2.55)
for sx in (-1, 1):
    FS.append(bar("arm_f", (sx * 1.66, 0.77, -5.12), (sx * 2.50, 0.79, -5.04), 0.22, 0.09, "arm_grey", 0.035, 1))
    FS.append(bar("arm_r", (sx * 1.86, 0.77, -5.12), (sx * 1.80, 0.77, -4.45), 0.17, 0.09, "arm_grey", 0.035, 1))
    FS.append(cyl("arm_bush_f", 0.10, 0.22, (sx * 1.66, 0.77, -5.12), "s", "rubber_black", 6, 0.02))
    FS.append(cyl("arm_bush_r", 0.11, 0.15, (sx * 1.80, 0.77, -4.45), "Y", "rubber_black", 6, 0.02))
    FS.append(lathe("ball_joint", [(0, 0.67), (0.08, 0.69), (0.09, 0.80), (0.05, 0.92), (0, 0.93)],
                    (sx * 2.55, 0.0, -5.03), "Y", "boot_black", 8))
# steering rack (alu), EPS motor hump (driver side), boots, tie rods to the knuckle arm (rear). SUV: placed by hand
# between the oil pan (rear -4.825) and the downpipe, under the intermediate drive shaft
ZONE = None
FS.append(cyl("rack", 0.10, 2.90, (0.0, 1.34, -4.66), "x", "alu_bright", 8, 0.03))
FS.append(cyl("rack_motor", 0.16, 0.40, (-0.95, 1.38, -4.60), "s", "frame_black", 10, 0.04))
for sx in (-1, 1):
    FS.append(boot("rack_boot", sx * 1.42, sx * 1.95, 1.34, -4.66, 0.13))
    FS.append(tube("tie_rod", [(sx * 1.92, 1.34, -4.66), (sx * 2.52, 1.40, -4.52)], 0.04, "arm_grey", 6, 1))
    FS.append(cyl("tie_rod_end", 0.07, 0.14, (sx * 2.55, 1.37, -4.51), "Y", "boot_black", 6, 0.02))
# front stabilizer bar (U) over the subframe, under the rack (SUV: underbody +0.15 here), links up inside the wheel wells
ZONE = None
FS.append(tube("stab_f", [(-2.38, 0.95, -4.66), (-2.15, 0.99, -4.66), (-1.82, 1.11, -4.66), (-1.0, 1.13, -4.66), (1.0, 1.13, -4.66),
                          (1.82, 1.11, -4.66), (2.15, 0.99, -4.66), (2.38, 0.95, -4.66)], 0.06, "frame_black", 6, 2))
for sx in (-1, 1):
    FS.append(tube("stab_link", [(sx * 2.38, 0.93, -4.66), (sx * 2.38, 1.95, -4.64)], 0.04, "frame_black", 6, 1))
    FS.append(rbox("stab_clamp", (0.14, 0.16, 0.18), (sx * 1.66, 1.05, -4.66), 0.0, "rubber_black", 1))
# drive shafts: left short from the transaxle, right long with the intermediate shaft + bearing behind the engine.
# SUV: inner ends follow the engine (bay rule), outer ends at the SUV hub centre (+-2.62, 1.49, -4.85) -> they slope down
ZONE = None
FS.append(tube("shaft_l", [(-1.70, 1.75, -4.75), (-2.62, 1.49, -4.85)], 0.075, "alu_bright", 6, 1))
FS.append(boot("cv_l_in", -1.98, -2.24, 1.634, -4.795, 0.13))
FS.append(boot("cv_l_out", -2.36, -2.60, 1.55, -4.83, 0.13))
FS.append(tube("shaft_mid", [(-1.05, 1.72, -4.65), (1.15, 1.72, -4.65)], 0.07, "alu_bright", 6, 1))
FS.append(rbox("shaft_bearing", (0.18, 0.30, 0.18), (1.15, 1.83, -4.67), 0.0, "frame_black", 1))
FS.append(tube("shaft_r", [(1.15, 1.72, -4.65), (2.62, 1.49, -4.85)], 0.075, "alu_bright", 6, 1))
FS.append(boot("cv_r_in", 1.62, 1.90, 1.625, -4.733, 0.13))
FS.append(boot("cv_r_out", 2.36, 2.60, 1.51, -4.83, 0.13))

# ---------------- exhaust (one line): downpipe behind the engine -> catalyst (+2 O2 sensors) -> resonator (under a heat
# shield) -> into the saddle tank's channel -> over the rear subframe -> right to the muffler inlet flange (1.255, 0.8, 7.07)
ZONE = None                 # SUV downpipe: drops between the intermediate shaft and the firewall, over the subframe cross
UB.append(tube("ex_down", [(0.40, 2.62, -4.55), (0.33, 2.10, -4.47), (0.22, 1.55, -4.43), (0.12, 1.16, -4.38), (0.04, 1.06, -4.15),
                           (0.0, 1.00, -3.75), (0.0, 1.00, -3.30)], 0.10, "exhaust", 8, 2))   # member, into the tunnel
ZONE = Z_UB
UB.append(lathe("catalyst", [(0, -0.56), (0.10, -0.56), (0.15, -0.47), (0.195, -0.36), (0.20, -0.26), (0.20, 0.26), (0.195, 0.36),
                             (0.15, 0.47), (0.10, 0.56), (0, 0.56)], (0.0, 0.80, -2.70), "s", "exhaust", 12))
for s_ in (-3.40, -2.02):
    UB.append(rbox("o2_sensor", (0.20, 0.06, 0.06), (0.15, 0.86, s_), 0.0, "alu_bright", 1))
UB.append(tube("ex_mid", [(0.0, 0.80, -2.20), (0.0, 0.80, -0.20)], 0.10, "exhaust", 8, 2))
UB.append(scale_x(lathe("resonator", [(0, -0.66), (0.10, -0.66), (0.17, -0.55), (0.205, -0.40), (0.21, -0.2), (0.21, 0.2), (0.205, 0.40),
                                      (0.17, 0.55), (0.10, 0.66), (0, 0.66)], (0.0, 0.80, 0.40), "s", "exhaust", 12), 1.25))
UB.append(tube("ex_tank", [(0.0, 0.80, 1.00), (0.0, 0.81, 1.60), (0.0, 0.87, 2.05), (0.0, 0.90, 2.30)], 0.10, "exhaust", 8, 2))
UB.append(tube("ex_rear", [(0.0, 0.94, 4.20), (0.05, 1.05, 4.55), (0.30, 1.07, 5.30), (0.85, 1.07, 6.05), (1.20, 1.00, 6.50),
                           (1.255, 0.84, 6.85), (1.255, 0.80, 7.00)], 0.10, "exhaust", 8, 2))
UB.append(rbox("ex_flange", (0.52, 0.22, 0.06), (1.255, 0.80, 7.035), 0.08, "exhaust", 2))
for (x_, Y_, s_, h_) in ((0.0, 0.96, -1.20, 0.12), (0.0, 0.965, 1.55, 0.11), (1.05, 1.165, 6.30, 0.09)):
    UB.append(rbox("ex_hanger", (0.07, h_, 0.10), (x_, Y_, s_), 0.0, "rubber_black", 1))
# heat shield lining the tunnel over the resonator (silver), with pressed ribs
UB.append(rbox("shield_top", (0.80, 0.03, 2.30), (0.0, 0.985, 0.40), 0.01, "shield_silver", 1))
for sx in (-1, 1):
    UB.append(rbox("shield_wall", (0.03, 0.36, 2.30), (sx * 0.395, 0.80, 0.40), 0.01, "shield_silver", 1))
for s_ in (-0.45, 0.15, 0.75, 1.30):
    UB.append(rbox("shield_rib", (0.74, 0.02, 0.06), (0.0, 0.962, s_), 0.0, "shield_silver", 1))
# black undercovers either side of the tunnel: big matte panels with pressed ribs and clips
ZONE = None                 # SUV: covers start behind the front tyre (its rear edge -3.36)
for sx in (-1, 1):
    UB.append(rbox("undercover", (2.05, 0.04, 4.80), (sx * 1.825, 0.72, -0.85), 0.03, "under_black", 1))
    for s_ in (-2.45, -0.85, 0.75):        # pressed recesses (darker insets, like the concept's panel pockets)
        UB.append(rbox("cover_pad", (1.50, 0.02, 1.30), (sx * 1.78, 0.692, s_), 0.05, "frame_black", 1))
    for (xx, s_) in ((0.95, -3.10), (2.70, -3.10), (0.95, 1.40), (2.70, 1.40), (1.85, -3.10), (1.85, 1.40)):
        UB.append(rbox("cover_clip", (0.09, 0.02, 0.09), (sx * xx, 0.688, s_), 0.0, "frame_black", 1))
ZONE = Z_UB
# saddle fuel tank under the rear seat (Z +2.05..+4.35) on 2 steel straps, EVAP canister beside it, one thick fuel line
UB.append(rbox("fuel_tank", (3.70, 0.56, 2.30), (0.0, 0.90, 3.20), 0.18, "tank_black", 2))
for xx in (-0.95, 0.95):
    UB.append(rbox("tank_strap", (0.16, 0.03, 2.40), (xx, 0.605, 3.20), 0.0, "frame_black", 1))
    for s_ in (2.03, 4.37):
        UB.append(rbox("tank_strap_end", (0.16, 0.46, 0.03), (xx, 0.95, s_), 0.0, "frame_black", 1))
UB.append(rbox("evap_canister", (0.30, 0.40, 0.70), (2.12, 0.95, 2.85), 0.08, "under_black", 2))
UB.append(tube("fuel_line", [(-0.95, 0.80, 2.15), (-0.78, 0.55, 1.85), (-0.73, 0.50, 1.40), (-0.73, 0.50, -2.90), (-0.44, 0.50, -3.30),
                             (-0.30, 0.62, -3.55), (-0.30, 0.94, -3.92)], 0.04, "hose_black", 6, 2))

# ---------------- rear axle: subframe (ladder + X brace), No.1 / No.2 lower arms (+ spring seat), upper arm, trailing arm,
# stabilizer, toe / camber adjustment cams (round discs with a mark - the 'match mark' job of Spring_R*)
for sx in (-1, 1):
    RA.append(bar("rsf_side", (sx * 1.42, 0.80, 4.42), (sx * 1.52, 0.80, 5.80), 0.22, 0.20, "frame_black", 0.05, 1))
    for (xx, s_) in ((1.46, 4.52), (1.55, 5.68)):
        RA.append(rbox("rsf_mount", (0.16, 0.36, 0.16), (sx * xx, 1.06, s_), 0.0, "rubber_black", 1))
RA.append(bar("rsf_front", (-1.55, 0.80, 4.52), (1.55, 0.80, 4.52), 0.22, 0.18, "frame_black", 0.05, 1))
RA.append(bar("rsf_rear", (-1.60, 0.80, 5.68), (1.60, 0.80, 5.68), 0.22, 0.18, "frame_black", 0.05, 1))
RA.append(bar("rsf_x", (-1.42, 0.78, 4.58), (1.50, 0.78, 5.62), 0.16, 0.14, "frame_black", 0.04, 1))
RA.append(bar("rsf_x", (1.42, 0.78, 4.58), (-1.50, 0.78, 5.62), 0.16, 0.14, "frame_black", 0.04, 1))
for sx in (-1, 1):
    # No.1 lower arm (front, thin link) + camber cam
    RA.append(tube("arm1", [(sx * 1.48, 0.82, 4.62), (sx * 2.52, 0.84, 4.80)], 0.055, "arm_dark", 6, 1))
    RA.append(cyl("arm1_bush", 0.09, 0.18, (sx * 1.48, 0.82, 4.64), "s", "rubber_black", 6, 0.02))
    RA.append(cyl("cam1", 0.13, 0.03, (sx * 1.48, 0.82, 4.745), "s", "alu_bright", 8, 0.008))
    RA.append(rbox("cam1_mark", (0.02, 0.10, 0.012), (sx * 1.48, 0.89, 4.765), 0.0, "cap_yellow", 1))
    # No.2 lower arm (rear, wide, spring seat) + toe cam
    RA.append(bar("arm2", (sx * 1.52, 0.82, 5.50), (sx * 2.52, 0.86, 5.30), 0.26, 0.08, "arm_dark", 0.03, 1))
    RA.append(lathe("spring_seat", [(0, 0.86), (0.27, 0.86), (0.31, 0.95), (0.25, 0.95), (0, 0.91)],
                    (sx * 2.05, 0.0, 5.43), "Y", "arm_dark", 10))
    RA.append(cyl("arm2_bush", 0.09, 0.18, (sx * 1.52, 0.82, 5.50), "s", "rubber_black", 6, 0.02))
    RA.append(cyl("cam2", 0.13, 0.03, (sx * 1.52, 0.82, 5.385), "s", "alu_bright", 8, 0.008))
    RA.append(rbox("cam2_mark", (0.02, 0.10, 0.012), (sx * 1.52, 0.89, 5.365), 0.0, "cap_yellow", 1))
    # upper arm (from the spring pocket's inner wall) + trailing arm (from a bracket under the rear floor)
    RA.append(tube("arm_up", [(sx * 1.78, 1.86, 4.88), (sx * 2.52, 1.90, 5.00)], 0.05, "arm_dark", 6, 1))
    RA.append(cyl("arm_up_bush", 0.08, 0.16, (sx * 1.80, 1.86, 4.88), "s", "rubber_black", 6, 0.02))
    RA.append(tube("arm_trail", [(sx * 2.30, 0.95, 3.82), (sx * 2.36, 0.92, 4.45)], 0.06, "arm_dark", 6, 1))
    RA.append(rbox("trail_bracket", (0.16, 0.30, 0.18), (sx * 2.30, 1.06, 3.82), 0.0, "frame_black", 1))
RA.append(tube("stab_r", [(-2.30, 0.88, 5.45), (-2.05, 0.88, 5.92), (-1.0, 0.90, 6.02), (1.0, 0.90, 6.02), (2.05, 0.88, 5.92),
                          (2.30, 0.88, 5.45)], 0.05, "frame_black", 6, 2))

ZONE = None                 # from here on: SUV coordinates
# reserved rooms (repair parts made later / by others): capsules (A, B, r) in car coords, kept empty by everything here
# SUV: strut from the knuckle (wheel centre 1.49 + 0.425) up into the tower (Z -4.80), rear spring / shock up to the
# floor pocket roof (2.50) -> both a bit longer than the sedan's (suv_spec 5)
ROOMS = {}
for sx, k in ((-1, "L"), (1, "R")):
    ROOMS["Strut_F" + k] = ((sx * 2.62, 1.915, -4.85), (sx * 2.75, 3.95, TOWER_Z), 0.26)
    ROOMS["Spring_R" + k] = ((sx * 2.05, 1.16, 5.28), (sx * 2.05, 2.49, 5.28), 0.30)
    ROOMS["Shock_R" + k] = ((sx * 2.45, 1.25, 4.55), (sx * 2.15, 2.49, 4.47), 0.13)

# ---------------- hood prop rod (Camry photo diagrams/23: passenger side front; props the hood's front-right corner)
HINGE_HOOD = Vector((0.0, 4.61, -4.10))          # car coords (x, Y, s) of the SUV hood hinge (suv_spec v0.2)
PIVOT = Vector((2.12, 3.60, -7.76))           # on top of the SUV radiator support bar (Y 3.40..3.56), passenger end
_hb = bmesh.new(); _hb.from_mesh(BODY["Hood"].data); _HT = BVHTree.FromBMesh(_hb); _hb.free()
_h = _HT.ray_cast(Vector((1.90, 7.55, 2.0)), Vector((0, 0, 1)))       # blender coords of (1.90, Y, -7.55), looking up
SOCKET_CLOSED = Vector((1.90, round(_h[0].z, 3), -7.55))   # hood underside, front-right (closed hood), 0.21 behind the pivot


def hood_open_pt(p, ang=70.0):
    d = p - HINGE_HOOD; a_ = math.radians(ang)
    return HINGE_HOOD + Vector((d.x, d.y * math.cos(a_) - d.z * math.sin(a_), d.y * math.sin(a_) + d.z * math.cos(a_)))


# the rod that fits across the front (ends past the left support post, x -1.93) props the hood at the angle where it
# reaches the socket; 70 deg (car_spec) would need a 4.7 rod that does not fit under the closed hood
# SUV: rod length chosen so the hood rests at suv_spec's 57.8 deg (same as the sedan), if it still fits stowed across the
# support (tip over the left post, x >= -2.08); otherwise the longest rod that fits
TARGET_DEG = 57.8
ROD_L = min(4.20, (hood_open_pt(SOCKET_CLOSED, TARGET_DEG) - PIVOT).length)
print("ROD for %.1f deg: %.3f (used %.3f)" % (TARGET_DEG, (hood_open_pt(SOCKET_CLOSED, TARGET_DEG) - PIVOT).length, ROD_L))
lo_, hi_ = 30.0, 70.0
for _ in range(40):
    mid = (lo_ + hi_) / 2
    if (hood_open_pt(SOCKET_CLOSED, mid) - PIVOT).length < ROD_L:
        lo_ = mid
    else:
        hi_ = mid
PROP_HOOD_DEG = round((lo_ + hi_) / 2, 1)
SOCKET_OPEN = hood_open_pt(SOCKET_CLOSED, PROP_HOOD_DEG)
prop = []
prop.append(tube("prop_rod", [(PIVOT.x, PIVOT.y, PIVOT.z), (PIVOT.x - ROD_L * 0.5, PIVOT.y, PIVOT.z), (PIVOT.x - ROD_L, PIVOT.y, PIVOT.z)],
                 0.038, "box_black", 8, 2))
prop.append(cyl("prop_pivot", 0.06, 0.10, (PIVOT.x + 0.02, PIVOT.y - 0.01, PIVOT.z), "s", "rubber_black", 10, 0.02))
prop.append(cyl("prop_tip", 0.05, 0.16, (PIVOT.x - ROD_L + 0.06, PIVOT.y, PIVOT.z), "x", "rubber_black", 10, 0.02))
for o in sc.objects:
    o.select_set(o in prop)
bpy.context.view_layer.objects.active = prop[0]
bpy.ops.object.join()
PROP = bpy.context.view_layer.objects.active; PROP.name = "HoodProp"; PROP.data.name = "HoodProp"
d0 = Vector((-1.0, 0.0, 0.0)); d1 = (SOCKET_OPEN - PIVOT).normalized()
ax = d0.cross(d1).normalized(); ang = math.degrees(d0.angle(d1))
PROP_INFO = dict(part="Moving/HoodProp (hood prop rod; stowed mesh)", length=round(ROD_L, 3),
                 Hinge=dict(position=[round(v, 3) for v in PIVOT], axis=[round(v, 4) for v in ax],
                            note="rotate the rod %.1f deg about this axis (right-hand) to stand it up under the open hood" % ang),
                 open_angle_deg=round(ang, 2), hood_open_deg=PROP_HOOD_DEG,
                 note_angle="with the rod the hood rests at %.1f deg (suv_spec v0.2: 57.8, prop type)" % PROP_HOOD_DEG,
                 Hood_PropSocket=dict(position_closed=[round(v, 3) for v in SOCKET_CLOSED], position_open70=[round(v, 3) for v in SOCKET_OPEN],
                                      note="add to the Hood as attachment 'PropSocket' (hood underside, front-right); "
                                           "position_open70 = where it is with the hood on the prop (hood_open_deg; name kept from the sedan)"))
print("PROP", PROP_INFO)
GROUPS_EXTRA = {"HoodProp": PROP}

# per-piece diagnostics (before joining): which piece touches what, and its distance to the closed hood
def _tree(ob):
    b_ = bmesh.new(); b_.from_mesh(ob.data); t_ = BVHTree.FromBMesh(b_); b_.free()
    return t_


_BT = {n: _tree(o) for n, o in BODY.items() if n in ("Shell", "Chassis", "Hood")}
_bx = bmesh.new(); bmesh.ops.create_cube(_bx, size=1.0)
bmesh.ops.scale(_bx, vec=Vector((3.6, 0.6, 1.9)), verts=_bx.verts); bmesh.ops.translate(_bx, vec=BL(0, 2.8, -7.35), verts=_bx.verts)
_BT["Radiator_slot"] = BVHTree.FromBMesh(_bx); _bx.free()
_bx = bmesh.new(); bmesh.ops.create_cube(_bx, size=1.0)
bmesh.ops.scale(_bx, vec=Vector((0.70, 0.95, 0.75)), verts=_bx.verts); bmesh.ops.translate(_bx, vec=BL(-2.2, 3.225, -5.55), verts=_bx.verts)
_BT["Battery_slot"] = BVHTree.FromBMesh(_bx); _bx.free()
TRIS_PIECE = {}
for gname, obs in GROUPS.items():
    for o in obs:
        t_ = _tree(o)
        hits = {k: len(t_.overlap(tt)) for k, tt in _BT.items() if k != "Hood"}
        hc = min(_BT["Hood"].find_nearest(v.co)[3] for v in o.data.vertices)
        tr = sum(len(p.vertices) - 2 for p in o.data.polygons)
        TRIS_PIECE[o.name.split(".")[0]] = TRIS_PIECE.get(o.name.split(".")[0], 0) + tr
        if any(hits.values()) or hc < 0.15:
            print("  PIECE", gname, o.name, hits, "hood", round(hc, 3))
print("  TRIS per piece:", sorted(TRIS_PIECE.items(), key=lambda kv: -kv[1])[:60])

# review-only placeholders (NOT deliverables): battery + radiator at their car_spec boxes, so the bay can be judged full
PH = []
PH.append(rbox("ph_battery", (0.70, 0.75, 0.95), (-2.20, 3.225, -5.55), 0.05, "box_black", 1))
PH.append(rbox("ph_bat_cap", (0.16, 0.10, 0.16), (-1.95, 3.63, -5.85), 0.03, "cable_red", 1))
PH.append(rbox("ph_radiator", (3.40, 1.80, 0.25), (0.0, 2.80, -7.50), 0.04, "condenser", 1))
PH.append(rbox("ph_rad_tank_l", (0.18, 1.90, 0.40), (-1.71, 2.80, -7.40), 0.05, "intake_black", 1))
PH.append(rbox("ph_rad_tank_r", (0.18, 1.90, 0.40), (1.71, 2.80, -7.40), 0.05, "intake_black", 1))
PH.append(cyl("ph_fan", 0.75, 0.30, (0.0, 2.80, -7.20), "s", "box_black", 20, 0.05))
PU = []


def coil(name, A, B, R, r, turns, mat):
    A, B = Vector(A), Vector(B); n = int(turns * 12)
    ax = (B - A); L_ = ax.length; ax.normalize()
    u = ax.cross(Vector((0, 0, 1)) if abs(ax.z) < 0.9 else Vector((1, 0, 0))).normalized(); w = ax.cross(u)
    pts = [tuple(A + ax * (L_ * i / n) + (u * math.cos(2 * math.pi * turns * i / n) + w * math.sin(2 * math.pi * turns * i / n)) * R)
           for i in range(n + 1)]
    return tube(name, pts, r, mat, 6, 1)


for sx in (-1, 1):
    (A, B, r_) = ROOMS["Strut_F" + ("L" if sx < 0 else "R")]
    PU.append(tube("ph_strut", [A, B], 0.09, "alu_bright", 10, 1))
    A2 = tuple(Vector(A) + (Vector(B) - Vector(A)) * 0.35)
    PU.append(coil("ph_strut_spring", A2, tuple(Vector(B) - (Vector(B) - Vector(A)) * 0.06), 0.21, 0.035, 5, "alu_bright"))
    (A, B, r_) = ROOMS["Spring_R" + ("L" if sx < 0 else "R")]
    PU.append(coil("ph_spring_r", A, B, 0.24, 0.04, 5, "alu_bright"))
    (A, B, r_) = ROOMS["Shock_R" + ("L" if sx < 0 else "R")]
    PU.append(tube("ph_shock", [A, B], 0.09, "frame_black", 10, 1))
for o in sc.objects:
    o.select_set(o in PU)
bpy.context.view_layer.objects.active = PU[0]
bpy.ops.object.join()
_pu = bpy.context.view_layer.objects.active; _pu.name = "ReviewPlaceholdersUnder"
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, "review_placeholders_under.glb"), export_format='GLB', use_selection=True, export_yup=True)
bpy.data.objects.remove(_pu)
for o in sc.objects:
    o.select_set(o in PH)
bpy.context.view_layer.objects.active = PH[0]
bpy.ops.object.join()
_ph = bpy.context.view_layer.objects.active; _ph.name = "ReviewPlaceholders"
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, "review_placeholders.glb"), export_format='GLB', use_selection=True, export_yup=True)
bpy.data.objects.remove(_ph)

DECO = {}
for name, obs in GROUPS.items():
    for o in sc.objects:
        o.select_set(o in obs)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active; ob.name = name; ob.data.name = name
    bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT'); bpy.ops.mesh.quads_convert_to_tris()
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.shade_smooth(keep_sharp_edges=True)
    bpy.ops.object.shade_smooth_by_angle(angle=math.radians(61), keep_sharp_edges=True)   # 6/8-sided hoses + bevels smooth, box edges sharp
    DECO[name] = ob


# ------------------------------------------------------------------ checks ----------------------------------------
def tree(ob):
    b = bmesh.new(); b.from_mesh(ob.data); t = BVHTree.FromBMesh(b); b.free()
    return t


def box_tree(lo, hi):
    b = bmesh.new(); bmesh.ops.create_cube(b, size=1.0)
    c = [(l + h) / 2 for l, h in zip(lo, hi)]; sz = [h - l for l, h in zip(lo, hi)]
    bmesh.ops.scale(b, vec=Vector((sz[0], sz[2], sz[1])), verts=b.verts); bmesh.ops.translate(b, vec=BL(*c), verts=b.verts)
    t = BVHTree.FromBMesh(b); b.free()
    return t


SLOTS = {"Battery_slot": ((-2.55, 2.85, -6.025), (-1.85, 3.60, -5.075)), "Radiator_slot": ((-1.8, 1.85, -7.65), (1.8, 3.75, -7.05))}
TT = {n: tree(o) for n, o in BODY.items()}
TT.update({n: box_tree(*lh) for n, lh in SLOTS.items()})
rep = {"tris": {}, "overlaps": {}, "hood_clearance": {}}
for name, ob in DECO.items():
    td = tree(ob)
    rep["tris"][name] = len(ob.data.polygons)
    rep["overlaps"][name] = {k: len(td.overlap(t)) for k, t in TT.items()}
    th = TT["Hood"]
    rep["hood_clearance"][name] = round(min(th.find_nearest(v.co)[3] for v in ob.data.vertices), 3)
rep["tris_total"] = sum(rep["tris"].values())


def in_room(ob, A, B, r):
    A, B = Vector(A), Vector(B); n = 0
    for v in ob.data.vertices:
        c = Vector(CAR(v.co)); t = max(0.0, min(1.0, (c - A).dot(B - A) / (B - A).length_squared))
        t0 = (c - A).dot(B - A) / (B - A).length_squared
        if 0.0 <= t0 <= 1.0 and (c - (A + (B - A) * t)).length < r:
            n += 1
    return n


rep["rooms"] = {name: {k: in_room(ob, *v) for k, v in ROOMS.items() if in_room(ob, *v)} for name, ob in DECO.items()}
EXT = {}
_root = os.path.dirname(os.path.dirname(os.path.dirname(OUT)))      # art/3d


def place(path, off, tag, rot=None):
    if not os.path.exists(path):
        print("missing", path); return None
    before = set(sc.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    new = [o for o in sc.objects if o not in before]
    meshes = [o for o in new if o.type == 'MESH']
    for o in meshes:
        mw = o.matrix_world.copy(); o.parent = None
        o.data = o.data.copy(); o.data.transform(mw); o.matrix_world = Matrix.Identity(4)
        if rot is not None:
            o.data.transform(rot)
        o.data.transform(Matrix.Translation(BL(*off)))
    for o in new:
        if o.type != 'MESH':
            bpy.data.objects.remove(o)
    for o in meshes:
        o.name = tag
    return meshes


EXT["Muffler"] = place(os.path.join(_root, "muffler", "Muffler.glb"), (0.3, 1.0, 7.6), "x_Muffler")        # suv_spec 4
EXT["Radiator"] = place(os.path.join(_root, "radiator", "Radiator.glb"), (0.0, 2.8, -7.35), "x_Radiator")
EXT["Battery"] = place(os.path.join(_root, "battery", "Battery.glb"), (-2.2, 2.85, -5.55), "x_Battery",
                       Matrix.Rotation(-math.pi / 2, 4, 'Z'))          # car_spec v0.8: Snap Y -90
for sx, k in ((1, "R"), (-1, "L")):
    for ss, f in ((-4.85, "F"), (4.85, "R")):
        EXT["Hub_" + f + k] = place(os.path.join(_root, "brake", "Hub.glb" if sx > 0 else "Hub_L.glb"), (sx * 3.25, 1.49, ss), "x_Hub")
if WHEELS is not None:
    EXT["Tyres"] = [WHEELS]
TX = {k: [tree(o) for o in v] for k, v in EXT.items() if v}
rep["external"] = {name: {k: sum(len(td.overlap(t)) for t in ts) for k, ts in TX.items()} for name, td in
                   ((n_, tree(o)) for n_, o in DECO.items())}
rep["external_HoodProp"] = {k: sum(len(tree(PROP).overlap(t)) for t in ts) for k, ts in TX.items()}
# body parts vs the muffler / hubs (the bumper bottom over the muffler was cut away)
rep["external_body"] = {n_: {k: sum(len(tree(o).overlap(t)) for t in ts) for k, ts in TX.items() if k != "Tyres"}
                        for n_, o in BODY.items()}
# per-piece detail for the underbody groups (which piece touches what)
for k, v in EXT.items():
    for o in (v or []):
        if o is not WHEELS:
            bpy.data.objects.remove(o)
tp = tree(PROP)
rep["HoodProp"] = dict(tris=len(PROP.data.polygons), overlaps={k: len(tp.overlap(t)) for k, t in TT.items()},
                       hood_clearance=round(min(TT["Hood"].find_nearest(v.co)[3] for v in PROP.data.vertices), 3), **PROP_INFO)
print("DECOR", json.dumps(rep, indent=1))
json.dump(rep, open(os.path.join(OUT, "decor_check.json"), "w"), indent=1)


def export(path, obs):
    for o in sc.objects:
        o.select_set(o in obs)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_apply=True, export_yup=True)


for name, ob in DECO.items():
    export(os.path.join(OUT, "suv_%s_flat.glb" % name.lower()), [ob])
export(os.path.join(OUT, "suv_decor_flat_all.glb"), list(DECO.values()))
for o in sc.objects:
    o.select_set(o == PROP)
bpy.context.view_layer.objects.active = PROP
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT'); bpy.ops.mesh.quads_convert_to_tris()
bpy.ops.object.mode_set(mode='OBJECT'); bpy.ops.object.shade_smooth()
export(os.path.join(OUT, "suv_hood_prop_flat.glb"), [PROP])
json.dump(PROP_INFO, open(os.path.join(OUT, "hood_prop_attachments.json"), "w"), indent=1)
po = PROP.copy(); po.data = PROP.data.copy(); po.name = "HoodProp_open"; sc.collection.objects.link(po)
R_ = Matrix.Translation(BL(*PIVOT)) @ Matrix.Rotation(math.radians(ang), 4, Vector((ax.x, -ax.z, ax.y))) @ Matrix.Translation(-BL(*PIVOT))
po.data.transform(R_)
tip = max((CAR(v.co) for v in po.data.vertices), key=lambda c: c[1])
print("PROP open tip", [round(v, 2) for v in tip], "socket", [round(v, 2) for v in SOCKET_OPEN])
export(os.path.join(OUT, "review_prop_open.glb"), [po])
bpy.data.objects.remove(po)
# review copy: body with the hood resting on the prop rod (flat colours), for the bay renders
hb = BODY["Hood"].copy(); hb.data = BODY["Hood"].data.copy(); hb.name = "Hood_prop_open"; sc.collection.objects.link(hb)
hb.data.transform(Matrix.Translation(BL(*HINGE_HOOD)) @ Matrix.Rotation(math.radians(PROP_HOOD_DEG), 4, 'X') @ Matrix.Translation(-BL(*HINGE_HOOD)))
export(os.path.join(OUT, "review_body_hood_on_prop.glb"), [o for n, o in BODY.items() if n != "Hood"] + [hb])
bpy.data.objects.remove(hb)
for n in list(BODY):
    bpy.data.objects.remove(BODY[n])
if WHEELS is not None:
    bpy.data.objects.remove(WHEELS)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, "suv_decor.blend"))
# fluid / check points for code (car_spec 3-2 Fluid_*; positions = cap tops, axis = up) + battery cable ends
FL = {"Fluid_OilFill": (EX + 0.85, 3.90, -5.55), "Dipstick": (EX + 0.5, 3.83, -5.87),
      "Fluid_Coolant": (2.55, 4.085, -5.72), "Fluid_BrakeFluid": (-1.55, 3.93, -4.97), "Fluid_Washer": (2.62, 3.78, -6.35),
      "BatteryCable_Pos_End": (-1.95, 3.62, -5.85), "BatteryCable_Neg_End": (-1.95, 3.62, -5.25),
      "FX_HoodGap": (0.0, 4.46, -4.35),
      "Fluid_OilDrain": (EX + 0.6, 1.24, -5.45), "FX_Leak_Engine": (EX + 0.05, 1.30, -5.30),
      "Muffler_InletFlange": (1.255, 1.00, 7.065),
      "Cam_Toe_RL": (-1.52, 1.02, 5.22), "Cam_Toe_RR": (1.52, 1.02, 5.22),
      "Cam_Camber_RL": (-1.48, 1.02, 4.61), "Cam_Camber_RR": (1.48, 1.02, 4.61),
      "LowerBallJoint_FL": (-2.55, 1.06, -4.88), "LowerBallJoint_FR": (2.55, 1.06, -4.88),
      "TieRodEnd_FL": (-2.55, 1.37, -4.51), "TieRodEnd_FR": (2.55, 1.37, -4.51),
      "DriveShaftEnd_FL": (-2.62, 1.49, -4.85), "DriveShaftEnd_FR": (2.62, 1.49, -4.85),
      "RearArmEnds_RL": (-2.52, 1.05, 4.90), "RearArmEnds_RR": (2.52, 1.05, 4.90)}
AXIS = {"Fluid_OilDrain": [0, -1, 0], "FX_Leak_Engine": [0, -1, 0], "Muffler_InletFlange": [0, 0, 1],
        "Cam_Toe_RL": [0, 0, -1], "Cam_Toe_RR": [0, 0, -1], "Cam_Camber_RL": [0, 0, 1], "Cam_Camber_RR": [0, 0, 1]}
json.dump(dict(coords="car-local Roblox studs (+X right, +Y up, -Z front, origin = ground between the axles)",
               note="SUV (suv_spec v0.2 4: battery pivot (-2.2, 2.85, -5.55) = sedan + (0, 0.5, 0.15)); battery cable ends "
                    "meet the battery top (3.60) at its terminals (car_spec v0.8: long side front-back, terminals on the "
                    "inboard long side: + front (-1.95, 3.6, -5.85), - rear (-1.95, 3.6, -5.25)); move them with the battery",
               points={k: {"position": [round(v, 3) for v in p_], "axis": AXIS.get(k, [0, 1, 0])} for k, p_ in FL.items()},
               rooms={k: dict(axis_from=[round(c, 3) for c in A], axis_to=[round(c, 3) for c in B], radius=r)
                      for k, (A, B, r) in ROOMS.items()},
               rooms_note="kept empty for the repair parts Strut_F* (knuckle -> strut tower at Z -4.68), Spring_R* (on the "
                          "No.2 arm seat, top in the floor pocket Y 2.50-2.60), Shock_R*; the knuckle / carrier (Deco_Hub) "
                          "should meet the *Joint / *End points"),
          open(os.path.join(OUT, "decor_attachments.json"), "w"), indent=1)
print("DECOR DONE")
