# Wheel = Rim + Tire (wr-3d, 10-21) from clean primitives, measured on art/concepts/parts/wheel_6view.png
# (split cells art/3d/wheel/work/concept/, front cell: tire R 228 px = 1.2 stud -> 190 px/stud), car_spec sizes win:
#   tire 2.4 x 0.9 (the drawing's tire is ~36 % too wide), rim 17" = bead seat d 1.55, flange lip d 1.69 (concept 1.71),
#   5 spokes (one at 12 o'clock), 5 lug holes on the spokes' axis at r 0.28 (car_spec; concept 0.20), centre cap
#   r 0.11 (concept 0.11), valve stem at about 171 deg (concept: just right of 6 o'clock, between the lower spokes).
# Real wheel facts used (parts_quickref s1): ET45 offset -> mounting face 0.185 outboard of the centre (x1.15),
# nut seat face 0.265, spokes run from the recessed hub out to the lip (concave face), see-through spoke windows
# (the brake shows through on the car), drop centre in the barrel, rim protector shape on the tire, 4 tread grooves.
#   blender --background --factory-startup --python tools/blender/wr/build_wheel.py -- <out_dir> [segs_tire=48] [segs_rim=40]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wr_lib as W
from wr_lib import P
from mathutils import Vector, Matrix
import numpy as np

argv = sys.argv[sys.argv.index("--") + 1:]
OUT = os.path.abspath(argv[0]); os.makedirs(OUT, exist_ok=True)
ST = int(argv[1]) if len(argv) > 1 else 48
SR = int(argv[2]) if len(argv) > 2 else 40
PAL = json.load(open(argv[3], encoding="utf-8")) if len(argv) > 3 and argv[3] else {}


def C(name, default):
    return PAL.get(name, default)


# ---------------- numbers (stud, build frame: +X outboard, +Y car front, +Z up) ----------------
MOUNT_X = 0.185      # hub back = mounting face (sits on the brake disc hat)
HUB_X = 0.280        # hub front = lug nut seat plane (Bolt_N)
HUB_R = 0.37
BOLT_R = 0.28        # car_spec
HOLE_R = 0.058       # lug hole (nut seat) radius
BORE_R = 0.107       # centre bore (60.1 mm)
SPOKES = [0, 72, 144, 216, 288]
VALVE_CLOCK = 171


def build_rim():
    P.reset()
    # real materials: painted silver cast alloy (clear coat), darker unpainted back, machined mounting pad
    silver = P.mat("rim_silver", C("rim_silver", "#C6C6C6"), 0.30, 0.60)
    inner = P.mat("rim_inner", C("rim_inner", "#7C7C7C"), 0.50, 0.45)
    mount = P.mat("rim_mount", C("rim_mount", "#9D9C9B"), 0.40, 0.70)
    capm = P.mat("rim_cap", C("rim_cap", "#B8B8B8"), 0.30, 0.65)
    vrub = P.mat("valve_rubber", C("valve_rubber", "#1C1C1C"), 0.75, 0.0)
    vcap = P.mat("valve_cap", C("valve_cap", "#9C9C9C"), 0.35, 0.9)
    parts = []
    # lip + barrel (closed profile, (r, x))
    lip = [(0.680, 0.322), (0.692, 0.356), (0.720, 0.386), (0.758, 0.398), (0.776, 0.411), (0.818, 0.415),
           (0.841, 0.405), (0.847, 0.385), (0.836, 0.368), (0.780, 0.356), (0.776, 0.300), (0.712, 0.230),
           (0.712, -0.200), (0.776, -0.270), (0.780, -0.356), (0.836, -0.368), (0.847, -0.388), (0.832, -0.410),
           (0.780, -0.410), (0.715, -0.380), (0.680, -0.340)]
    parts.append(W.revolve_x("lip", lip, SR, material=silver))
    # face = hub + 5 spokes as ONE plate (no seam between hub and spokes): curve fill with the 5 filleted windows
    # (measured: parallel spokes ~0.27 wide, window inner end r 0.37 / outer r 0.685), the 5 lug holes and the
    # centre bore; caps re-triangulated evenly, then the whole plate is bent into the concave dish (hub recessed,
    # spokes rising to the lip). (A crown along the spokes was tried: it made a light blotch where it faded in.)
    B = 0.008; HW = 0.135; RIN, ROUT = 0.37, 0.685
    xc = (MOUNT_X + HUB_X) / 2; hd = (HUB_X - MOUNT_X) / 2
    outl = [W.circle_pts(0, 0, 0.705 - B, SR)]
    for i, th in enumerate(SPOKES):
        outl.append(W.fillet_window(th, th + 72, HW - B, RIN - B, ROUT + B, 0.035 + B, 0.04 + B))
        d = W.clock_dir(th) * BOLT_R
        outl.append(W.circle_pts(d.y, d.z, HOLE_R + B, 16))
    outl.append(W.circle_pts(0, 0, BORE_R + B, 18))
    M = W.frame((xc, 0, 0), (0, 1, 0), (0, 0, 1), (1, 0, 0))
    face = W.curve_plate("face", outl, hd, B, 0, M, material=silver)
    print('face caps', W.ring_caps(face, 1, 0.055), W.ring_caps(face, -1, 0.085))

    def rise(r):          # concave dish: flat hub, spokes climb 0.106 to the lip step, flat again there
        t = min(max((r - 0.36) / 0.35, 0), 1)
        return 0.106 * t * t * (3 - 2 * t)
    for v in face.data.vertices:
        v.co.x += rise(math.hypot(v.co.y, v.co.z))
    W.mark_sharp(face, 30)
    parts.append(face)
    # centre cap (dome)
    parts.append(W.revolve_x("cap", [(0, 0.317), (0.045, 0.315), (0.080, 0.307), (0.100, 0.295), (0.110, 0.279),
                                     (0.110, 0.262), (0, 0.262)], 28, material=capm, closed=False))
    # valve stem between the two lower spokes, angled out like a real snap-in stem
    u = W.clock_dir(VALVE_CLOCK); a = Vector((1, 0, 0)); d = (u * 0.42 + a * 0.91).normalized()
    p0 = a * 0.335 + u * 0.688
    parts.append(W.tube("valve", [p0, p0 + d * 0.04, p0 + d * 0.075], [0.026, 0.023, 0.020], around=10, material=vrub))
    parts.append(W.tube("valve_cap", [p0 + d * 0.072, p0 + d * 0.105], 0.017, around=10, material=vcap))
    ob = W.join("Rim", parts)

    # back-side / inside colour (concept back view: dark spoke backs, lighter bare mounting pad, silver back flange)
    def paint_side(cen, nrm):
        r = math.hypot(cen.y, cen.z)
        radial = (cen.y * nrm.y + cen.z * nrm.z) / max(r, 1e-6)
        if r < 0.36 and nrm.x < -0.9 and cen.x < MOUNT_X + 0.01:   # flat mounting pad (sits on the disc hat)
            return mount
        if r < 0.70 and nrm.x < -0.3:                                # backs of hub / spokes
            return inner
        if 0.66 < r < 0.73 and radial < -0.6 and cen.x < 0.33:       # barrel inner wall
            return inner
        return None
    P.assign_by(ob, paint_side)
    return ob


def build_tire():
    P.reset()
    rub = P.mat("tire", C("tire", "#2C2C2C"), 0.88, 0.0)   # rubber
    R0, XE = 1.2, 0.35

    def rt(x):
        return R0 - 0.018 * (x / XE) ** 2
    GD = 0.046
    half = []
    for gc in (0.068, 0.200):            # 4 circumferential grooves (2 per side), U-shaped
        x0, x1 = gc - 0.0225, gc + 0.0225
        half += [(rt(x0), x0), (rt(x0) - GD, x0 + 0.007), (rt(x1) - GD, x1 - 0.007), (rt(x1), x1)]
    half += [(rt(XE), XE)]
    # rounded shoulder (arc centre (1.10, 0.355), r 0.09) and a bulged sidewall down to the rim flange
    for ang in (35, 65):
        a = math.radians(ang)
        half.append((1.093 + 0.09 * math.cos(a), 0.357 + 0.09 * math.sin(a)))
    half += [(1.100, 0.448), (1.005, 0.457), (0.915, 0.448), (0.858, 0.418), (0.790, 0.372)]
    # closed loop: outboard bead -> sidewall -> tread -> centre -> inboard side -> inboard bead; the closing strip
    # (bead to bead at r 0.79) is the inside of the tire, tucked into the rim flanges
    loop = [(r, x) for r, x in reversed(half)] + [(R0, 0.0)] + [(r, -x) for r, x in half]
    ob = W.revolve_x("Tire", loop, ST, material=rub, closed=True)
    return ob


def tire_paint(Pm, Nm, base, orm, mask):
    """shoulder lugs: short lateral grooves painted on the two shoulder ribs (casual, no extra triangles)"""
    x = Pm[..., 0]; r = np.sqrt(Pm[..., 1] ** 2 + Pm[..., 2] ** 2)
    phi = np.arctan2(Pm[..., 1], Pm[..., 2])
    ax = np.abs(x)
    sel = mask & (ax > 0.232) & (r > 1.115)
    n = 44
    ph = (phi + np.sign(x) * 0.10 * (ax - 0.232)) * n / (2 * np.pi)
    d = np.abs(ph - np.round(ph)) * (2 * np.pi / n) * r      # arc distance to the nearest groove line (stud)
    w = 0.013 * (0.6 + 0.4 * np.clip((ax - 0.232) / 0.12, 0, 1))
    k = np.clip(1 - (d - w) / 0.006, 0, 1) * sel
    dark = np.array([int(C("tire_groove", "#141515")[i:i + 2], 16) / 255 for i in (1, 3, 5)], np.float32)
    base = base * (1 - k[..., None]) + dark * k[..., None]
    # groove bottoms a little darker (they read at small sizes)
    g = mask & (np.abs(x) < 0.30) & (r < 1.2 - 0.03) & (r > 1.1)
    base[g] = base[g] * 0.55 + dark * 0.45
    orm[..., 1] = orm[..., 1] * (1 - k) + 0.95 * k
    return base, orm


def attach_json(path):
    bolts = {}
    for i, th in enumerate(SPOKES, start=1):
        d = W.clock_dir(th) * BOLT_R
        bolts["Bolt_%d" % i] = {"pos": W.to_roblox((HUB_X, d.y, d.z)), "axis": [1, 0, 0],
                                "clock_deg_seen_from_outside": th}
    data = {
        "part": "Wheel (Model: Rim [PrimaryPart] + Tire)", "units": "stud",
        "space": "part local = Roblox axes of the RIGHT wheel (FR/RR): +X outboard, +Y up, -Z car front. Mesh origin = wheel centre.",
        "Rim": {"SnapAttachment": {"pos": [0, 0, 0], "note": "wheel centre (car_spec Wheel_XX pivot)"}, **bolts,
                "star_order": [1, 3, 5, 2, 4],
                "bolt_axis_note": "Attachment +X (Axis) = nut comes off outward; pos = nut seat on the hub face (lug hole centre)",
                "lug_hole_radius": HOLE_R, "hub_face_x": HUB_X, "mounting_face_x": MOUNT_X},
        "Tire": {"pivot": [0, 0, 0], "note": "same origin as Rim; tire d 2.4 x w 0.9"},
        "left_wheels": "FL/RL: same meshes turned 180 deg about Y (car_spec). Bolt order stays clockwise seen from outside.",
        "brake_fit": "Disc hat face sits on mounting_face_x; caliper must stay inside the barrel (inner r 0.68) and behind the spokes (spoke backs x >= 0.19 at the hub, ~0.25 at r 0.6).",
    }
    json.dump(data, open(path, "w", encoding="utf-8"), indent=1)
    print("ok", path)


rim = build_rim()
print("RIM tris before finish", P.tris(rim))
P.finish(rim, os.path.join(OUT, "Rim"), tex=1024, pivot_bottom=False, weighted=False, smooth_angle=50)
tire = build_tire()
print("TIRE tris before finish", P.tris(tire))
P.finish(tire, os.path.join(OUT, "Tire"), tex=1024, pivot_bottom=False, weighted=False, smooth_angle=50, paint=tire_paint)
attach_json(os.path.join(OUT, "wheel_attachments.json"))
