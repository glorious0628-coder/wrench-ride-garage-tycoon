# Front brake (wr-3d, 10-21) from clean primitives, measured on art/concepts/parts/brake_6view.png (split cells in
# art/3d/brake/work/concept/; front cell: disc r 184 px = 0.55 stud -> 334 px/stud). car_spec / parts_quickref win on
# size: disc d 1.1 x 0.12 (305 x 28 mm, x1.15 on the thickness), pads 0.51 x 0.20 x (plate + friction), single-piston
# floating caliper at the FRONT of the wheel centre at centre height (parts_quickref s2, Camry manual diagram 18; the
# concept draws it there too: front view = outboard face of a RIGHT wheel, caliper on the picture's right = car front).
# Meshes (built for the RIGHT wheel around the wheel centre; build frame +X outboard, +Y car front, +Z up):
#   Disc            vented rotor with hat (pivot = wheel centre)                     - static (Decor/Deco_Hub in proto)
#   CaliperBracket  dark bracket: inboard cross member + 2 arms over the disc edge, pin bosses, rubber boots - static
#   Caliper         moving body: outboard fingers (C-notch shows the pad), bridge, inboard housing + piston boss,
#                   2 ears (slide-pin bolt seats = BrakePads Bolt_1/2), bleeder, banjo + hose, anti-rattle clip
#   BrakePads       2 curved pads (steel backing plate + friction block, ears) as ONE mesh, X-symmetric
#   pivot of Caliper / CaliperBracket / BrakePads = pad-set centre C = wheel centre + (0, front 0.46, 0)
# Left wheels: Disc and BrakePads turn 180 deg about Y; Caliper_L / CaliperBracket_L are mirrored copies (a turned
# right caliper would sit BEHIND the wheel and MeshParts cannot be mirrored).
#   blender --background --factory-startup --python tools/blender/wr/build_brake.py -- <out_dir> [palette.json]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wr_lib as W
from wr_lib import P
from mathutils import Vector, Matrix
import numpy as np

argv = sys.argv[sys.argv.index("--") + 1:]
OUT = os.path.abspath(argv[0]); os.makedirs(OUT, exist_ok=True)
PAL = json.load(open(argv[1], encoding="utf-8")) if len(argv) > 1 and argv[1] else {}
SEG = 48


def C_(name, default):
    return PAL.get(name, default)


# ---------------- numbers (stud) ----------------
MOUNT_X = 0.185                 # wheel mounting face = disc hat face (wheel_attachments.json)
XR = 0.0                        # disc ring centre plane = wheel centre plane
RD = 0.55                       # disc radius (305 mm)
TH = 0.12                       # disc thickness
HAT_R = 0.356                   # hat outer radius (stud circle 0.28 + hole + margin)
BOLT_R = 0.28; SPOKES = [0, 72, 144, 216, 288]
RM = 0.46                       # pad-set centre radius (middle of the friction band 0.375-0.545)
CEN = Vector((XR, RM, 0.0))     # pad-set centre C (build frame)
PIN_PHI, PIN_R = 43.0, 0.525    # slide pins (seen from outside: angle up from the front axis)
PIN = Vector((0.0, PIN_R * math.cos(math.radians(PIN_PHI)) - RM, PIN_R * math.sin(math.radians(PIN_PHI))))  # local
FR = W.frame(CEN, (0, 1, 0), (0, 0, 1), (1, 0, 0))   # local outline (u = y, v = z), thickness along x


def sector(R0, R1, ph0, ph1, corner, step=0.05, k=3, extra=None):
    """annular-sector outline (local y, z) around the wheel centre: param rect u = arc length at RM, v = r - RM"""
    u0, u1 = math.radians(ph0) * RM, math.radians(ph1) * RM
    poly = extra if extra is not None else [(u0, R0 - RM), (u1, R0 - RM), (u1, R1 - RM), (u0, R1 - RM)]
    pts = W.densify(W.round_corners(poly, corner, k), step)
    out = []
    for u, v in pts:
        ph = u / RM; r = RM + v
        out.append((r * math.cos(ph) - RM, r * math.sin(ph)))
    return out[::-1]   # (u, v) -> (y, z) swaps the axes: reverse so the outline is counter-clockwise (insets go IN)


# ================= Disc =================
def build_disc():
    P.reset()
    band = P.mat("disc_band", C_("disc_band", "#C9C9C9"), 0.36, 0.70)    # machined friction band (shiny cast iron)
    hat = P.mat("disc_hat", C_("disc_hat", "#B4B4B4"), 0.50, 0.65)      # hat (turned, duller)
    edge = P.mat("disc_edge", C_("disc_edge", "#8F8F8F"), 0.55, 0.65)   # cast edge
    vent = P.mat("disc_vent", C_("disc_vent", "#3A3A3A"), 0.80, 0.30)   # vent channel (vanes painted)
    o, i = XR + TH / 2, XR - TH / 2
    prof = [(0.112, MOUNT_X), (0.335, MOUNT_X), (0.350, MOUNT_X - 0.008), (HAT_R, MOUNT_X - 0.024), (HAT_R, o + 0.022),
            (HAT_R + 0.010, o + 0.004), (HAT_R + 0.026, o), (RD - 0.012, o), (RD - 0.001, o - 0.010), (RD, o - 0.034),
            (RD - 0.026, o - 0.038), (RD - 0.026, i + 0.038), (RD, i + 0.034), (RD - 0.001, i + 0.010), (RD - 0.012, i),
            (0.340, i), (0.327, i + 0.012), (0.327, MOUNT_X - 0.042), (0.317, MOUNT_X - 0.030), (0.122, MOUNT_X - 0.030),
            (0.112, MOUNT_X - 0.020)]
    ob = W.revolve_x("Disc", prof, SEG, material=band)

    def mat_fn(c, n):
        r = math.hypot(c.y, c.z)
        if RD - 0.03 < r and abs(c.x - XR) < 0.026:
            return vent
        if r > RD - 0.004 or (r > RD - 0.015 and abs(n.x) < 0.7):
            return edge
        if r < HAT_R + 0.004:
            return hat
        return None
    P.assign_by(ob, mat_fn)
    return ob


def disc_paint(Pm, Nm, base, orm, mask):
    """vent vanes (36) in the edge channel + 5 stud holes on the hat face (dark, both sides)"""
    r = np.sqrt(Pm[..., 1] ** 2 + Pm[..., 2] ** 2); x = Pm[..., 0]
    phi = np.arctan2(Pm[..., 1], Pm[..., 2])
    ch = mask & (r > RD - 0.030) & (np.abs(x - XR) < 0.0255)
    f = (phi * 36 / (2 * np.pi)) % 1.0
    vw = np.clip((0.17 - np.abs(f - 0.5)) / 0.03 + 0.5, 0, 1) * ch       # anti-aliased vane edges
    col = np.array([int(C_("disc_edge", "#8F8F8F")[k:k + 2], 16) / 255 for k in (1, 3, 5)], np.float32)
    base = base * (1 - vw[..., None]) + col * vw[..., None]
    orm[..., 1] = orm[..., 1] * (1 - vw) + 0.55 * vw
    hole = np.zeros(r.shape, np.float32)
    for th in SPOKES:
        cy, cz = BOLT_R * math.sin(math.radians(th)), BOLT_R * math.cos(math.radians(th))
        dd = np.sqrt((Pm[..., 1] - cy) ** 2 + (Pm[..., 2] - cz) ** 2)
        hole = np.maximum(hole, np.clip((0.022 - dd) / 0.004 + 0.5, 0, 1))
    hole *= mask & (x > MOUNT_X - 0.035)
    base = base * (1 - hole[..., None]) + np.array([0.09, 0.09, 0.09], np.float32) * hole[..., None]
    orm[..., 1] = orm[..., 1] * (1 - hole) + 0.9 * hole
    return base, orm


# ================= Pads =================
PAD_FR = (0.375, 0.545, 0.24)   # friction r0, r1, half arc length at RM
PAD_X = (TH / 2, TH / 2 + 0.045, TH / 2 + 0.045 + 0.022)   # friction from disc face, then plate (local x, outer pad)


def pad_outlines():
    vb, vt, e0, e1 = 0.365 - RM, 0.56 - RM, 0.0, 0.055
    plate = [(-0.255, vb), (0.255, vb), (0.255, e0), (0.29, e0), (0.29, e1), (0.255, e1), (0.255, vt), (-0.255, vt),
             (-0.255, e1), (-0.29, e1), (-0.29, e0), (-0.255, e0)]
    pl = sector(0, 0, 0, 0, 0.016, step=0.09, k=1, extra=plate)
    u = PAD_FR[2]
    fr = sector(0, 0, 0, 0, 0.03, step=0.09, k=2, extra=[(-u, PAD_FR[0] - RM), (u, PAD_FR[0] - RM), (u, PAD_FR[1] - RM), (-u, PAD_FR[1] - RM)])
    return pl, fr


def build_pads():
    P.reset()
    fric = P.mat("pad_friction", C_("pad_friction", "#3B3836"), 0.92, 0.0)
    steel = P.mat("pad_plate", C_("pad_plate", "#A9ACAF"), 0.40, 0.85)
    pl, fr = pad_outlines()
    parts = []
    for s in (1, -1):   # outer (+x) and inner (-x) pad, mirror images
        a, b, c = PAD_X
        if s > 0:
            parts.append(W.outline_slab("fric", fr, a, b + 0.002, 0.007, 1, FR, material=fric, rad_back=0.004, support=False))
            parts.append(W.outline_slab("plate", pl, b, c, 0.006, 1, FR, material=steel, support=False))
        else:
            parts.append(W.outline_slab("fric", fr, -b - 0.002, -a, 0.004, 1, FR, material=fric, rad_back=0.007, support=False))
            parts.append(W.outline_slab("plate", pl, -c, -b, 0.006, 1, FR, material=steel, support=False))
    ob = W.join("BrakePads", parts)
    W.mark_sharp(ob, 35)    # flat faces + crisp small chamfers
    return ob


# ================= Caliper (moving) =================
def build_caliper():
    P.reset()
    paint = P.mat("caliper", C_("caliper", "#8A8B8D"), 0.55, 0.10)      # painted cast iron
    rub = P.mat("rubber", C_("rubber", "#1E1E1E"), 0.80, 0.0)
    steel = P.mat("steel", C_("steel", "#B8BBBE"), 0.35, 0.90)
    parts = []
    # outboard fingers: one C-shaped block, the notch between the two finger tips shows the pad (concept front
    # view). Concave corners get big fillets so the edge-rounding insets cannot cross (the first notch went wobbly).
    zh, yi, zn, yn = 0.31, -0.095, 0.165, -0.015
    C_out = [(yi, -zh), (0.16, -zh), (0.16, zh), (yi, zh), (yi, zn), (yn, zn), (yn, -zn), (yi, -zn)]
    rads = [0.035, 0.08, 0.08, 0.035, 0.03, 0.045, 0.045, 0.03]
    fo = W.densify(W.round_corners(C_out, rads, 4), 0.07)
    parts.append(W.outline_slab("fingers", fo, 0.130, 0.180, 0.02, 3, FR, material=paint, rad_back=0.006, n_back=1))
    # bridge over the disc edge
    # two bars: the open window between them shows the pad tops (pad check window of a floating caliper)
    for s_ in (1, -1):
        br = W.densify(W.rrect_pts(0.0275, 0.0525, 0.022, 3, cx=0.1325, cy=0.1825 * s_), 0.08)
        parts.append(W.outline_slab("bridge", br, -0.27, 0.17, 0.02, 2, FR, material=paint))
    # inboard housing + piston boss (round cup seen from inside the wheel)
    ho = W.densify(W.round_corners([(-0.13, -0.31), (0.16, -0.31), (0.16, 0.31), (-0.13, 0.31)], 0.08, 4), 0.08)
    parts.append(W.outline_slab("housing", ho, -0.31, -0.132, 0.03, 2, FR, material=paint, rad_back=0.01, n_back=1))
    boss = W.revolve_x("boss", [(0, -0.372), (0.06, -0.369), (0.10, -0.359), (0.122, -0.343), (0.13, -0.324), (0.13, -0.30), (0, -0.30)],
                       28, closed=False, material=paint, center=(0, CEN.y, CEN.z))
    parts.append(boss)
    # ears with slide-pin bolt seats (the code's Bolt_M10 heads sit on the inboard faces)
    for s in (1, -1):
        e = Vector((0, PIN.y, PIN.z * s))
        web = [(-0.11, 0.20 * s), (e.y + 0.035, 0.20 * s), (e.y + 0.035, e.z), (e.y - 0.035, e.z), (-0.11, 0.24 * s)]
        if s < 0:
            web = [(p[0], p[1]) for p in reversed(web)]
        parts.append(W.outline_slab("web", W.round_corners(web, 0.02, 2), -0.25, -0.172, 0.012, 1, FR, material=paint))
        parts.append(W.revolve_x("ear", [(0, -0.255), (0.040, -0.255), (0.048, -0.247), (0.048, -0.178), (0.040, -0.170), (0, -0.170)],
                                 20, closed=False, material=paint, center=(0, CEN.y + e.y, CEN.z + e.z)))
    # bleeder nipple on top, banjo bolt + hose on the inboard face
    bl = CEN + Vector((-0.255, 0.09, 0.30))
    parts.append(W.tube("bleed_hex", [bl + Vector((0, 0, -0.01)), bl + Vector((0, 0, 0.025))], 0.024, around=6, material=steel))
    parts.append(W.tube("bleeder", [bl + Vector((0, 0, 0.02)), bl + Vector((0, 0, 0.07))], [0.014, 0.011], around=10, material=steel))
    bj = CEN + Vector((-0.31, 0.07, 0.17))
    parts.append(W.tube("banjo", [bj + Vector((0.01, 0, 0)), bj + Vector((-0.045, 0, 0))], 0.034, around=6, material=steel))
    parts.append(W.tube("banjo_body", [bj + Vector((-0.022, 0, -0.01)), bj + Vector((-0.022, 0, 0.06))], 0.026, around=12, material=steel))
    hose = [bj + Vector((-0.022, 0, 0.05)), bj + Vector((-0.03, -0.005, 0.12)), bj + Vector((-0.05, -0.02, 0.19)),
            bj + Vector((-0.09, -0.045, 0.245)), bj + Vector((-0.14, -0.075, 0.28))]
    parts.append(W.tube("hose", hose, 0.021, around=10, material=rub))
    # anti-rattle spring clip on the outboard face, along the notch (concept front view)
    clip = []
    for j in range(13):
        t = -1 + 2 * j / 12; zc = 0.15 * t
        clip.append(Vector((0.165 + 0.0105 * math.cos(t * math.pi / 2) ** 0.5, CEN.y - 0.03 - 0.012 * math.cos(t * math.pi / 2), zc)))
    parts.append(W.tube("clip", clip, 0.0075, around=8, material=steel))
    return W.join("Caliper", parts)


# ================= Bracket (static) =================
def build_bracket():
    P.reset()
    dark = P.mat("bracket", C_("bracket", "#4C4D50"), 0.60, 0.30)
    rub = P.mat("rubber", C_("rubber", "#1E1E1E"), 0.80, 0.0)
    parts = []
    # inboard cross member (arc inside the pads' radius) + its 2 mounting bolt bosses (to the knuckle)
    parts.append(W.outline_slab("cross", sector(0.29, 0.352, -48, 48, 0.03, 0.045, k=3), -0.128, -0.068, 0.010, 1, FR, material=dark, support=False))
    W.mark_sharp(parts[-1], 35)
    for s in (1, -1):
        ph = math.radians(30 * s); rr = 0.325
        c = Vector((0, rr * math.cos(ph), rr * math.sin(ph)))
        parts.append(W.revolve_x("mboss", [(0, -0.150), (0.036, -0.150), (0.042, -0.144), (0.042, -0.100), (0, -0.100)],
                                 14, closed=False, material=dark, center=c))
        # arm: inboard leg + bridge over the disc edge + short outboard leg (holds the pad ears)
        a0, a1 = (38, 48) if s > 0 else (-48, -38)
        parts.append(W.outline_slab("leg_in", sector(0.30, 0.605, a0, a1, 0.025, 0.05, k=3), -0.128, -0.068, 0.010, 1, FR, material=dark, support=False))
        W.mark_sharp(parts[-1], 35)
        parts.append(W.outline_slab("leg_top", sector(0.568, 0.608, a0, a1, 0.015, 0.09, k=2), -0.100, 0.100, 0.012, 2, FR, material=dark))
        parts.append(W.outline_slab("leg_out", sector(0.47, 0.608, a0, a1, 0.03, 0.09, k=3), 0.068, 0.105, 0.012, 2, FR, material=dark))
        ph = math.radians(43 * s)
        parts.append(W.revolve_x("oboss", [(0, 0.124), (0.026, 0.124), (0.034, 0.118), (0.036, 0.100), (0, 0.100)], 18, closed=False,
                                 material=dark, center=(0, 0.565 * math.cos(ph), 0.565 * math.sin(ph))))
        # slide-pin boss + ribbed rubber boot (bellows) toward the caliper ear
        e = CEN + Vector((0, PIN.y, PIN.z * s))
        parts.append(W.revolve_x("pinboss", [(0, -0.136), (0.040, -0.136), (0.046, -0.130), (0.046, -0.072), (0, -0.072)],
                                 18, closed=False, material=dark, center=(0, e.y, e.z)))
        boot = [(0, -0.176), (0.026, -0.176), (0.036, -0.170), (0.030, -0.163), (0.038, -0.155), (0.031, -0.148),
                (0.039, -0.141), (0.036, -0.134), (0, -0.134)]
        parts.append(W.revolve_x("boot", boot, 16, closed=False, material=rub, center=(0, e.y, e.z)))
    return W.join("CaliperBracket", parts)


def export(ob, name, pivot, mirror=False, paint=None):
    if mirror:
        W.mirror_x(ob)
    W.translate(ob, -pivot)
    print(name, "tris before finish", P.tris(ob))
    P.finish(ob, os.path.join(OUT, name), tex=1024, pivot_bottom=False, weighted=False, smooth_angle=50, paint=paint,
             recalc_normals=False)


def rb(v):
    return W.to_roblox(v)


# ---- build + export ----
d = build_disc(); export(d, "Disc", Vector((0, 0, 0)), paint=disc_paint)
p = build_pads(); export(p, "BrakePads", CEN)
for side, mir in (("", False), ("_L", True)):
    c = build_caliper(); export(c, "Caliper" + side, CEN * (Vector((-1, 1, 1)) if mir else Vector((1, 1, 1))), mirror=mir)
    b = build_bracket(); export(b, "CaliperBracket" + side, CEN * (Vector((-1, 1, 1)) if mir else Vector((1, 1, 1))), mirror=mir)

# ---- attachments (Roblox part space; RIGHT side unless noted) ----
hinge_local = Vector((-0.212, PIN.y, PIN.z))
data = {
    "units": "stud",
    "space": "part local, Roblox axes (+X car right = outboard for a RIGHT wheel, +Y up, -Z car front). Positions relative to the part's own origin (= its pivot).",
    "wheel_centre_offsets_note": "place = wheel centre CFrame (car axes, no rotation) * offset; left side uses the _L meshes and the left offsets",
    "Disc": {"pivot": "wheel centre", "SnapAttachment": [0, 0, 0], "offset_from_wheel_centre": {"right": [0, 0, 0], "left": [0, 0, 0]},
             "left_side": "same mesh turned 180 deg about Y (hat outboard)",
             "hat_face_x": MOUNT_X, "ring_centre_x": XR, "diameter": 2 * RD, "thickness": TH,
             "BracketBolt_note": "disc comes off after the bracket (2 bolts) - see CaliperBracket.MountBolt_1/2"},
    "BrakePads": {"pivot": "pad-set centre (middle of the disc thickness, middle of the pads)", "SnapAttachment": [0, 0, 0],
                  "offset_from_wheel_centre": {"right": rb(CEN), "left": rb(Vector((-CEN.x, CEN.y, CEN.z)))},
                  "left_side": "SAME mesh, no rotation (the set is mirror-symmetric)",
                  "Bolt_1": {"pos": rb(Vector((-0.255, PIN.y, PIN.z))), "axis_right": [-1, 0, 0], "note": "upper slide-pin bolt head seat on the caliper ear (car_spec: BrakePads bolts = caliper bolts)"},
                  "Bolt_2": {"pos": rb(Vector((-0.255, PIN.y, -PIN.z))), "axis_right": [-1, 0, 0], "note": "lower slide-pin bolt"},
                  "bolt_left_side": "left: x -> -x, axis [1, 0, 0] (bolts come out toward the car centre)",
                  "remove_direction": "radially out of the bracket = car front (-Z) after the caliper is swung up",
                  "size": "each pad 0.51 long (arc) x 0.195 high x 0.067 thick (plate 0.022 + friction 0.045)"},
    "Caliper": {"pivot": "pad-set centre (same point as BrakePads)", "SnapAttachment": [0, 0, 0],
                "offset_from_wheel_centre": {"right": rb(CEN), "left (Caliper_L)": rb(Vector((-CEN.x, CEN.y, CEN.z)))},
                "Hinge": {"pos_right": rb(hinge_local), "pos_left": rb(Vector((-hinge_local.x, hinge_local.y, hinge_local.z))),
                          "axis": [1, 0, 0], "open_angle_deg": 70,
                          "note": "upper slide pin axis (Toyota: lower bolt out, swing up on the upper pin). Rotate +70 deg about the Hinge +X axis (both sides): the body swings forward and up, pads free."},
                "bolt_seats": "Bolt_1/2 of BrakePads sit on this mesh's ears"},
    "CaliperBracket": {"pivot": "pad-set centre", "SnapAttachment": [0, 0, 0],
                       "offset_from_wheel_centre": {"right": rb(CEN), "left (CaliperBracket_L)": rb(Vector((-CEN.x, CEN.y, CEN.z)))},
                       "MountBolt_1": {"pos": rb(Vector((-0.150, 0.325 * math.cos(math.radians(30)) - RM, 0.325 * math.sin(math.radians(30))))), "axis_right": [-1, 0, 0]},
                       "MountBolt_2": {"pos": rb(Vector((-0.150, 0.325 * math.cos(math.radians(30)) - RM, -0.325 * math.sin(math.radians(30))))), "axis_right": [-1, 0, 0]},
                       "note": "stays put when the caliper swings up (holds the pads, boots on the slide pins). Static decor (Deco_Hub) in the prototype."},
}
json.dump(data, open(os.path.join(OUT, "brake_attachments.json"), "w", encoding="utf-8"), indent=1)
print("ok json")
