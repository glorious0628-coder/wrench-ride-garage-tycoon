# Brake Detail / Lite (wr-3d 10-21, notes/gpt/main/wheel_brake_3d_main_decision.md).
#   Detail (bay cars): Disc ~850, Caliper ~1,000, CaliperBracket ~800, BrakePads (2) ~300 - same shapes as
#   build_brake.py v10 (approved) with lighter topology: per-ring segment counts on the disc (hidden cup / bore rings
#   coarser), vents and stud holes painted, slabs without back rounding, small round parts with fewer sides.
#   Lite (all other cars): Brake_Lite = disc + caliper (+ bracket nubs) as ONE mesh, pivot = wheel centre;
#   Brake_Lite_L mirrored for the left wheels.
# Changes asked by main 10-21: stud circle 0.28 -> 0.24 (disc hat smaller, closer to the concept), pads with clearer
# colour / value contrast when mounted (darker, slightly warm friction block + brighter steel plate).
#   blender --background --factory-startup --python build_brake_lod.py -- <out_dir> <detail|lite> [palette.json] [scale]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wr_lib as W
from wr_lib import P
from mathutils import Vector, Matrix
import numpy as np

argv = sys.argv[sys.argv.index("--") + 1:]
OUT = os.path.abspath(argv[0]); os.makedirs(OUT, exist_ok=True)
LOD = argv[1]; DET = LOD == "detail"
PAL = json.load(open(argv[2], encoding="utf-8")) if len(argv) > 2 and argv[2] else {}
K = float(argv[3]) if len(argv) > 3 else 1.0     # main 10-21: whole corner x 2.75 / 2.4 (built at 2.4 size, scaled at export)


def C_(name, default):
    return PAL.get(name, default)


MOUNT_X, XR, RD, TH = 0.185, 0.0, 0.55, 0.12
BOLT_R = 0.24
HAT_R = 0.315
SPOKES = [0, 72, 144, 216, 288]
RM = 0.46
CEN = Vector((XR, RM, 0.0))
PIN_PHI, PIN_R = 43.0, 0.525
PIN = Vector((0.0, PIN_R * math.cos(math.radians(PIN_PHI)) - RM, PIN_R * math.sin(math.radians(PIN_PHI))))
FR = W.frame(CEN, (0, 1, 0), (0, 0, 1), (1, 0, 0))
FRICTION = "#362C26"   # concept #3E3E40 -> darker, warm brown (main 10-21: pad contrast when mounted)
PLATE = "#CDD6E0"      # concept #CFCECC -> bright zinc-plated steel, slightly cool so the pad reads apart from the grey disc


def sector(R0, R1, ph0, ph1, corner, step=0.05, k=3, extra=None):
    u0, u1 = math.radians(ph0) * RM, math.radians(ph1) * RM
    poly = extra if extra is not None else [(u0, R0 - RM), (u1, R0 - RM), (u1, R1 - RM), (u0, R1 - RM)]
    pts = W.densify(W.round_corners(poly, corner, k) if corner > 0 else poly, step)
    out = [((RM + v) * math.cos(u / RM) - RM, (RM + v) * math.sin(u / RM)) for u, v in pts]
    return out[::-1]


def slab(name, pts, t0, t1, rad, n, mat, sharp=True):
    """outline slab with front rounding only (no back rounding, no support rings)"""
    ob = W.outline_slab(name, pts, t0, t1, rad, n, FR, material=mat, rad_back=0.0, n_back=1, support=False)
    if sharp:
        W.mark_sharp(ob, 35)
    return ob


def disc_mats():
    return (P.mat("disc_band", C_("disc_band", "#C8C7C9"), 0.36, 0.70), P.mat("disc_hat", C_("disc_hat", "#BFBEC0"), 0.50, 0.65),
            P.mat("disc_edge", C_("disc_edge", "#BFBEC0"), 0.55, 0.65))


def build_disc(name):
    band, hat, edge = disc_mats()
    o, i = XR + TH / 2, XR - TH / 2
    if DET:
        prof = [(0.112, MOUNT_X), (0.300, MOUNT_X), (HAT_R, MOUNT_X - 0.015), (HAT_R, o + 0.016), (HAT_R + 0.017, o),
                (RD - 0.012, o), (RD, o - 0.013), (RD, i + 0.013), (RD - 0.012, i), (0.300, i), (0.287, i + 0.013),
                (0.287, MOUNT_X - 0.030), (0.120, MOUNT_X - 0.030)]
        segs = [48, 48, 48, 48, 48, 48, 48, 48, 48, 24, 24, 24, 24]   # every ring seen from outside 48 (hat edge / bore showed kinks at 24), inboard cup 24
    else:
        prof = [(0.112, MOUNT_X), (HAT_R, MOUNT_X), (HAT_R, o), (RD, o), (RD, i), (0.112, i)]
        segs = [12, 24, 24, 24, 24, 12]
    ob = W.revolve_x_var(name, prof, segs, material=band, closed=True)

    def mat_fn(c, n):
        r = math.hypot(c.y, c.z)
        if r > RD - 0.004 or (r > RD - 0.015 and abs(n.x) < 0.7):
            return edge
        if r < HAT_R + 0.004:
            return hat
        return None
    P.assign_by(ob, mat_fn)
    return ob


def disc_paint(Pm, Nm, base, orm, mask):
    """vent slots (36) on the edge band (vented rotor read) + 5 stud holes on the hat (dark, soft edges)"""
    r = np.sqrt(Pm[..., 1] ** 2 + Pm[..., 2] ** 2); x = Pm[..., 0]
    phi = np.arctan2(Pm[..., 1], Pm[..., 2])
    edge = mask & (r > RD - 0.006) & (np.abs(x - XR) < 0.026)
    f = (phi * 36 / (2 * np.pi)) % 1.0
    slot = np.clip((0.33 - np.abs(f - 0.5)) / 0.03 + 0.5, 0, 1) * np.clip((0.026 - np.abs(x - XR)) / 0.004, 0, 1) * edge
    dark = np.array([int(C_("disc_vent", "#141414")[k:k + 2], 16) / 255 for k in (1, 3, 5)], np.float32)
    base = base * (1 - slot[..., None]) + dark * slot[..., None]
    orm[..., 1] = orm[..., 1] * (1 - slot) + 0.85 * slot
    hole = np.zeros(r.shape, np.float32)
    for th in SPOKES:
        cy, cz = BOLT_R * math.sin(math.radians(th)), BOLT_R * math.cos(math.radians(th))
        dd = np.sqrt((Pm[..., 1] - cy) ** 2 + (Pm[..., 2] - cz) ** 2)
        hole = np.maximum(hole, np.clip((0.022 - dd) / 0.004 + 0.5, 0, 1))
    hole *= mask & (x > MOUNT_X - 0.035)
    base = base * (1 - hole[..., None]) + np.array([0.09, 0.09, 0.09], np.float32) * hole[..., None]
    orm[..., 1] = orm[..., 1] * (1 - hole) + 0.9 * hole
    return base, orm


# ---------------- pads ----------------
def build_pads():
    P.reset()
    fric = P.mat("pad_friction", C_("pad_friction_mounted", FRICTION), 0.92, 0.0)
    steel = P.mat("pad_plate", C_("pad_plate_mounted", PLATE), 0.35, 0.90)
    vb, vt, e0, e1 = 0.365 - RM, 0.56 - RM, 0.0, 0.055
    plate = [(-0.255, vb), (0.255, vb), (0.255, e0), (0.29, e0), (0.29, e1), (0.255, e1), (0.255, vt), (-0.255, vt),
             (-0.255, e1), (-0.29, e1), (-0.29, e0), (-0.255, e0)]
    pl = sector(0, 0, 0, 0, 0.0, step=0.17, extra=plate)
    u = 0.24
    fr = sector(0, 0, 0, 0, 0.03, step=0.17, k=1, extra=[(-u, 0.375 - RM), (u, 0.375 - RM), (u, 0.545 - RM), (-u, 0.545 - RM)])
    a, b, c = TH / 2, TH / 2 + 0.045, TH / 2 + 0.045 + 0.022
    parts = []
    for s in (1, -1):
        if s > 0:
            parts.append(W.outline_slab("fric", fr, a, b + 0.002, 0.0, 1, FR, material=fric, rad_back=0.006, n_back=1, support=False))
            parts.append(W.outline_slab("plate", pl, b, c, 0.0, 1, FR, material=steel, rad_back=0.0, support=False))
        else:
            parts.append(W.outline_slab("fric", fr, -b - 0.002, -a, 0.006, 1, FR, material=fric, rad_back=0.0, support=False))
            parts.append(W.outline_slab("plate", pl, -c, -b, 0.0, 1, FR, material=steel, rad_back=0.0, support=False))
    # wear indicator ("squealer"): small bent spring-steel tab on the INNER pad's top end; it touches the disc when the
    # friction is worn -> the PAD_WORN squeal (wr-carbook / Toyota manual: indicator on the upper end)
    ph = math.radians(31.5); r0 = 0.515
    base = Vector((-(c - 0.004), r0 * math.cos(ph) - RM, r0 * math.sin(ph))) + CEN
    up = Vector((0, -math.sin(ph), math.cos(ph)))            # along the pad end, away from the pad (tangential)
    tab = [base - up * 0.01, base + up * 0.012, base + up * 0.026 + Vector((0.012, 0, 0)), base + up * 0.030 + Vector((0.032, 0, 0)),
           base + up * 0.026 + Vector((0.050, 0, 0))]
    parts.append(W.strip("weartab", tab, 0.028, 0.006, (0, math.cos(ph), math.sin(ph)), material=steel))
    ob = W.join("BrakePads", parts)
    W.mark_sharp(ob, 35)
    return ob


# ---------------- caliper ----------------
def caliper_parts(paint, rub, steel, lite=False):
    parts = []
    zh, yi, zn, yn = 0.31, -0.095, 0.165, -0.015
    C_out = [(yi, -zh), (0.16, -zh), (0.16, zh), (yi, zh), (yi, zn), (yn, zn), (yn, -zn), (yi, -zn)]
    rads = [0.035, 0.08, 0.08, 0.035, 0.03, 0.045, 0.045, 0.03]
    fo = W.densify(W.round_corners(C_out, rads, 1 if lite else 2), 0.14 if lite else 0.10)
    parts.append(slab("fingers", fo, 0.130, 0.180, 0.0 if lite else 0.02, 1 if lite else 2, paint, sharp=lite))
    for s_ in (1, -1):
        br = W.densify(W.rrect_pts(0.0275, 0.0525, 0.022, 1, cx=0.1325, cy=0.1825 * s_), 0.2)
        parts.append(slab("bridge", br, -0.27, 0.17, 0.0 if lite else 0.012, 1, paint))
    ho = W.densify(W.round_corners([(-0.13, -0.31), (0.16, -0.31), (0.16, 0.31), (-0.13, 0.31)], 0.08, 1 if lite else 3), 0.2 if lite else 0.12)
    parts.append(slab("housing", ho, -0.31, -0.132, 0.0 if lite else 0.025, 1 if lite else 2, paint, sharp=lite))
    boss = [(0, -0.37), (0.10, -0.36), (0.13, -0.33), (0.13, -0.30), (0, -0.30)] if not lite else [(0, -0.36), (0.13, -0.34), (0.13, -0.30), (0, -0.30)]
    parts.append(W.revolve_x("boss", boss, 10 if lite else 16, closed=False, material=paint, center=(0, CEN.y, CEN.z)))
    if lite:
        return parts
    for s in (1, -1):
        e = Vector((0, PIN.y, PIN.z * s))
        web = [(-0.11, 0.20 * s), (e.y + 0.035, 0.20 * s), (e.y + 0.035, e.z), (e.y - 0.035, e.z), (-0.11, 0.24 * s)]
        if s < 0:
            web = web[::-1]
        parts.append(slab("web", W.round_corners(web, 0.02, 1), -0.25, -0.172, 0.0, 1, paint))
        parts.append(W.revolve_x("ear", [(0, -0.255), (0.044, -0.255), (0.048, -0.247), (0.048, -0.172), (0, -0.172)],
                                 12, closed=False, material=paint, center=(0, CEN.y + e.y, CEN.z + e.z)))
    bl = CEN + Vector((-0.255, 0.09, 0.30))
    parts.append(W.tube("bleed_hex", [bl + Vector((0, 0, -0.01)), bl + Vector((0, 0, 0.025))], 0.024, around=6, material=steel))
    parts.append(W.tube("bleeder", [bl + Vector((0, 0, 0.02)), bl + Vector((0, 0, 0.07))], [0.014, 0.011], around=8, material=steel))
    bj = CEN + Vector((-0.31, 0.07, 0.17))
    parts.append(W.tube("banjo", [bj + Vector((0.01, 0, 0)), bj + Vector((-0.045, 0, 0))], 0.034, around=6, material=steel))
    parts.append(W.tube("banjo_body", [bj + Vector((-0.022, 0, -0.01)), bj + Vector((-0.022, 0, 0.06))], 0.026, around=8, material=steel))
    hose = [bj + Vector((-0.022, 0, 0.05)), bj + Vector((-0.035, -0.008, 0.15)), bj + Vector((-0.07, -0.035, 0.225)),
            bj + Vector((-0.14, -0.075, 0.28))]
    parts.append(W.tube("hose", hose, 0.021, around=8, material=rub))
    clip = []
    for j in range(7):
        t = -1 + 2 * j / 6; zc = 0.15 * t
        clip.append(Vector((0.165 + 0.0105 * math.cos(t * math.pi / 2) ** 0.5, CEN.y - 0.03 - 0.012 * math.cos(t * math.pi / 2), zc)))
    parts.append(W.tube("clip", clip, 0.0075, around=8, material=steel))
    return parts


def build_caliper():
    P.reset()
    paint = P.mat("caliper", C_("caliper", "#8A8A8E"), 0.55, 0.10)
    rub = P.mat("rubber", C_("rubber", "#2B2B2C"), 0.80, 0.0)
    steel = P.mat("steel", C_("steel", "#CBC9C9"), 0.35, 0.90)
    return W.join("Caliper", caliper_parts(paint, rub, steel))


# ---------------- bracket ----------------
def bracket_parts(dark, rub, lite=False):
    parts = []
    if not lite:
        parts.append(slab("cross", sector(0.29, 0.352, -48, 48, 0.03, 0.08, k=2), -0.128, -0.068, 0.008, 1, dark))
    for s in (1, -1):
        a0, a1 = (38, 48) if s > 0 else (-48, -38)
        ph = math.radians(43 * s)
        if lite:
            parts.append(slab("leg_top", sector(0.47, 0.608, a0, a1, 0.0, 0.2), -0.12, 0.105, 0.0, 1, dark))
            continue
        parts.append(slab("leg_in", sector(0.30, 0.605, a0, a1, 0.025, 0.08, k=2), -0.128, -0.068, 0.008, 1, dark))
        parts.append(slab("leg_top", sector(0.568, 0.608, a0, a1, 0.012, 0.2, k=1), -0.100, 0.100, 0.008, 1, dark))
        parts.append(slab("leg_out", sector(0.47, 0.608, a0, a1, 0.025, 0.08, k=2), 0.068, 0.105, 0.008, 1, dark))
        parts.append(W.revolve_x("oboss", [(0, 0.124), (0.030, 0.124), (0.036, 0.114), (0.036, 0.100), (0, 0.100)], 10, closed=False,
                                 material=dark, center=(0, 0.565 * math.cos(ph), 0.565 * math.sin(ph))))
        e = CEN + Vector((0, PIN.y, PIN.z * s))
        parts.append(W.revolve_x("pinboss", [(0, -0.136), (0.044, -0.136), (0.046, -0.130), (0.046, -0.072), (0, -0.072)],
                                 10, closed=False, material=dark, center=(0, e.y, e.z)))
        boot = [(0, -0.176), (0.030, -0.176), (0.038, -0.166), (0.031, -0.155), (0.039, -0.145), (0.036, -0.134), (0, -0.134)]
        parts.append(W.revolve_x("boot", boot, 8, closed=False, material=rub, center=(0, e.y, e.z)))
    return parts


def build_bracket():
    P.reset()
    dark = P.mat("bracket", C_("bracket", "#5A5B5D"), 0.60, 0.30)
    rub = P.mat("rubber", C_("rubber", "#2B2B2C"), 0.80, 0.0)
    return W.join("CaliperBracket", bracket_parts(dark, rub))


def stud_parts(mat, sides=10, simple=False):
    out = []
    for th in SPOKES:
        d = W.clock_dir(th) * BOLT_R
        prof = ([(0.0, 0.335), (0.018, 0.335), (0.026, 0.322), (0.026, 0.10), (0.0, 0.10)] if not simple
                else [(0.0, 0.33), (0.024, 0.33), (0.024, 0.15), (0.0, 0.15)])
        out.append(W.revolve_x("stud", prof, sides, closed=False, material=mat, center=(0, d.y, d.z)))
    return out


def build_hub():
    """Deco_Hub: hub flange + pilot (seen through the disc bore), 5 wheel studs through the disc hat and the rim's lug holes,
    dust shield behind the disc (open at the front for the caliper), ABS wheel-speed sensor + wire up toward the strut"""
    P.reset()
    steel = P.mat("stud", C_("stud", "#B7B9BC"), 0.45, 0.70)
    hubm = P.mat("hub", C_("hub", "#6F7276"), 0.55, 0.55)
    shield = P.mat("shield", C_("shield", "#45474A"), 0.65, 0.35)
    black = P.mat("black", C_("rubber", "#2B2B2C"), 0.75, 0.0)
    parts = []
    parts.append(W.revolve_x("flange", [(0.0, 0.183), (0.094, 0.183), (0.104, 0.175), (0.104, 0.156), (0.28, 0.156),
                                        (0.28, 0.105), (0.20, 0.095), (0.20, -0.22), (0.0, -0.22)], 24,
                             closed=False, material=hubm))
    parts += stud_parts(steel, sides=8)
    sh = [(0.235, -0.105), (0.562, -0.105), (0.586, -0.072), (0.574, -0.068), (0.553, -0.093), (0.235, -0.093)]
    parts.append(W.revolve_arc("shield", sh, 30, math.radians(55), math.radians(305), material=shield))
    a_s = math.radians(150); sp = Vector((-0.17, 0.20 * math.cos(a_s), 0.20 * math.sin(a_s)))
    parts.append(W.revolve_x("abs", [(0.0, -0.10), (0.030, -0.10), (0.034, -0.11), (0.034, -0.20), (0.020, -0.215), (0.0, -0.215)], 10,
                             closed=False, material=black, center=(0, sp.y, sp.z)))
    wire = [Vector((-0.21, sp.y, sp.z)), Vector((-0.27, sp.y - 0.02, sp.z + 0.06)), Vector((-0.36, sp.y - 0.02, sp.z + 0.20)),
            Vector((-0.46, sp.y, sp.z + 0.36)), Vector((-0.56, sp.y + 0.02, sp.z + 0.50))]
    parts.append(W.tube("abs_wire", wire, 0.013, around=8, material=black))
    return W.join("Hub", parts)


def build_brake_lite():
    P.reset()
    d = build_disc("disc")
    paint = P.mat("caliper", C_("caliper", "#8A8A8E"), 0.55, 0.10)
    dark = P.mat("bracket", C_("bracket", "#5A5B5D"), 0.60, 0.30)
    stud = P.mat("stud", C_("stud", "#B7B9BC"), 0.45, 0.70)
    parts = [d] + caliper_parts(paint, None, None, lite=True) + bracket_parts(dark, None, lite=True) + stud_parts(stud, sides=6, simple=True)
    return W.join("Brake_Lite", parts)


def export(ob, name, pivot, mirror=False, paint=None, tex=1024):
    if mirror:
        W.mirror_x(ob)
    W.translate(ob, -pivot)
    ob.data.transform(Matrix.Scale(K, 4))          # uniform scale about the part's pivot
    sx = np.array([-1.0 if mirror else 1.0, 1.0, 1.0], np.float32)   # mirrored copies paint in the right-side frame
    pf = None if paint is None else (lambda Pm, Nm, b, o, m: paint((Pm / K + pivot_np(pivot)) * sx, Nm * sx, b, o, m))
    print(name, "tris before finish", P.tris(ob))
    P.finish(ob, os.path.join(OUT, name), tex=tex, pivot_bottom=False, weighted=False, smooth_angle=50, paint=pf,
             recalc_normals=False)


def pivot_np(v):
    return np.array([v.x, v.y, v.z], np.float32)


def rb(v):
    return W.to_roblox(Vector(v) * K)
if DET:
    P.reset(); export(build_disc("Disc"), "Disc", Vector((0, 0, 0)), paint=disc_paint)
    export(build_pads(), "BrakePads", CEN, tex=512)
    export(build_pads(), "BrakePads_L", CEN * Vector((-1, 1, 1)), mirror=True, tex=512)   # wear tab on the inner pad -> mirrored copy
    export(build_hub(), "Hub", Vector((0, 0, 0)), tex=512)
    export(build_hub(), "Hub_L", Vector((0, 0, 0)), mirror=True, tex=512)
    for side, mir in (("", False), ("_L", True)):
        cl = CEN * Vector((-1, 1, 1)) if mir else CEN
        export(build_caliper(), "Caliper" + side, cl, mirror=mir)
        export(build_bracket(), "CaliperBracket" + side, cl, mirror=mir)
    hinge_local = Vector((-0.212, PIN.y, PIN.z))
    data = {
        "units": "stud",
        "space": "part local, Roblox axes (+X car right = outboard for a RIGHT wheel, +Y up, -Z car front); positions from the part's own origin (= pivot).",
        "versions": "Detail = Disc / Caliper(_L) / CaliperBracket(_L) / BrakePads (bay cars). Lite = Brake_Lite(_L) = disc + caliper + bracket nubs in one static mesh, pivot = wheel centre (all other cars).",
        "Disc": {"pivot": "wheel centre", "SnapAttachment": [0, 0, 0], "left_side": "same mesh turned 180 deg about Y",
                 "hat_face_x": round(MOUNT_X * K, 4), "ring_centre_x": XR, "diameter": round(2 * RD * K, 4), "thickness": round(TH * K, 4),
                 "stud_circle_radius": round(BOLT_R * K, 4)},
        "scale": {"factor": K, "note": "main 10-21: whole corner x 2.75/2.4; offsets below already include it"},
        "BrakePads": {"pivot": "pad-set centre", "SnapAttachment": [0, 0, 0],
                      "offset_from_wheel_centre": {"right": rb(CEN), "left": rb(Vector((-CEN.x, CEN.y, CEN.z)))},
                      "left_side": "BrakePads_L (mirrored copy: the wear tab sits on the inner = piston-side pad), no rotation",
                      "WearTab": {"pos": rb(Vector((-(TH / 2 + 0.045 + 0.018), 0.515 * math.cos(math.radians(31.5)) - RM, 0.515 * math.sin(math.radians(31.5)) + 0.02))),
                                  "note": "squealer on the inner pad's upper end (PAD_WORN squeal source)"},
                      "Bolt_1": {"pos": rb(Vector((-0.255, PIN.y, PIN.z))), "axis_right": [-1, 0, 0], "note": "upper slide-pin bolt seat (on the caliper ear)"},
                      "Bolt_2": {"pos": rb(Vector((-0.255, PIN.y, -PIN.z))), "axis_right": [-1, 0, 0], "note": "lower slide-pin bolt seat"},
                      "bolt_left_side": "left: x -> -x, axis [1, 0, 0]",
                      "remove_direction": "radially out = car front (-Z) after the caliper is swung up",
                      "visibility": "may be hidden while the wheel is on, but MUST be shown again for the pad job (main 10-21)"},
        "Caliper": {"pivot": "pad-set centre", "SnapAttachment": [0, 0, 0],
                    "offset_from_wheel_centre": {"right": rb(CEN), "left (Caliper_L)": rb(Vector((-CEN.x, CEN.y, CEN.z)))},
                    "Hinge": {"pos_right": rb(hinge_local), "pos_left": rb(Vector((-hinge_local.x, hinge_local.y, hinge_local.z))),
                              "axis": [1, 0, 0], "open_angle_deg": 70, "note": "upper slide pin axis; +70 deg about +X swings the body forward and up (both sides)"}},
        "CaliperBracket": {"pivot": "pad-set centre", "SnapAttachment": [0, 0, 0],
                           "offset_from_wheel_centre": {"right": rb(CEN), "left (CaliperBracket_L)": rb(Vector((-CEN.x, CEN.y, CEN.z)))},
                           "MountBolt_1": {"pos": rb(Vector((-0.128, 0.325 * math.cos(math.radians(30)) - RM, 0.325 * math.sin(math.radians(30))))), "axis_right": [-1, 0, 0]},
                           "MountBolt_2": {"pos": rb(Vector((-0.128, 0.325 * math.cos(math.radians(30)) - RM, -0.325 * math.sin(math.radians(30))))), "axis_right": [-1, 0, 0]},
                           "visibility": "static; may be hidden while the wheel is on, MUST show for the pad / disc jobs"},
        "Brake_Lite": {"pivot": "wheel centre", "left": "Brake_Lite_L (mirrored), identity rotation at the left wheel centre", "studs": "5 simple studs included"},
        "Hub": {"pivot": "wheel centre", "SnapAttachment": [0, 0, 0], "left": "Hub_L (mirrored), no rotation",
                "what": "Decor/Deco_Hub_XX: hub flange + pilot, 5 wheel studs (circle %.3f, tips %.3f outboard of the wheel centre: through the disc hat and the rim's lug holes, past the nut seats), dust shield behind the disc (open at the front for the caliper), ABS sensor + wire" % (BOLT_R * K, 0.335 * K),
                "Stud_N": [rb(Vector((0.30, BOLT_R * math.sin(math.radians(t)), BOLT_R * math.cos(math.radians(t))))) for t in SPOKES],
                "stud_note": "stud centres line up with the rim's Bolt_N seats; the code's LugNut threads on here"},
    }
    json.dump(data, open(os.path.join(OUT, "brake_attachments.json"), "w", encoding="utf-8"), indent=1)
else:
    for side, mir in (("", False), ("_L", True)):
        export(build_brake_lite(), "Brake_Lite" + side, Vector((0, 0, 0)), mirror=mir, paint=disc_paint, tex=512)
print("ok")
