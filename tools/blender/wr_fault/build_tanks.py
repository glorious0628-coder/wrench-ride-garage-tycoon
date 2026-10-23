# Coolant reservoir + brake fluid reservoir for the engine-bay Work View (wr-3d helper 10-21), fault_looks v0.3 §5b.
# Concepts art/concepts/workview/coolant_tank_6view.png, brake_reservoir_6view.png. Built in CAR coords (Roblox
# x, Y, z -> build (x, -z, Y)); every mesh node's origin = its pivot (body: bottom centre, cap: bottom centre on the
# neck, liquid: bottom centre). Bodies are ONE clean shell each (exact boolean union, no faces inside) because they
# are see-through; the liquid is a separate prism the game scales in Y from its bottom.
# Coolant tank = a "boot": the outboard lower corner is cut away because the front wheel house (liner X >= 2.57,
# arch roof Y 2.45 .. 2.84 under the tank) sits there - see the README / report.
#   blender -b --factory-startup --python build_tanks.py -- <out_dir> [coolant,brake] [palette.json]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fault_common import *  # noqa
import numpy as np

argv = sys.argv[sys.argv.index("--") + 1:]
OUT = os.path.abspath(argv[0]); os.makedirs(OUT, exist_ok=True)
WHICH = argv[1].split(",") if len(argv) > 1 and argv[1] else ["coolant", "brake"]
PAL = json.load(open(argv[2], encoding="utf-8")) if len(argv) > 2 and argv[2] else {}
C_ = lambda k, d: PAL.get(k, d)
INFO = {}
YZ = W.frame((0, 0, 0), (1, 0, 0), (0, 0, 1), (0, 1, 0))    # local (x, y, z) -> build (x, z, y): outline in car X-Y, depth along car Z
XY = W.frame((0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1))    # outline in plan (x, build y), extruded up


def ribbed_cap(name, cx, cy, h0, h1, r, ribs, rib_d, top_rad, mat, spr=4, dome=0.006):
    """screw cap: rounded top edge, grip ribs on the side (rib depth rib_d), slightly domed top; axis = build Z"""
    segs = ribs * spr
    prof = [(r * 0.90, h0, 0.0), (r - 0.004, h0 + 0.002, 0.0), (r, h0 + 0.012, 1.0), (r, h1 - top_rad - 0.004, 1.0)]
    for k in range(1, 4):
        a = math.pi / 2 * k / 3
        prof.append((r - top_rad + top_rad * math.cos(a), h1 - top_rad + top_rad * math.sin(a), 0.0))
    prof += [(r * 0.62, h1 + dome * 0.5, 0.0), (r * 0.30, h1 + dome, 0.0)]
    bm = bmesh.new(); rings = []
    for rr, h, w in prof:
        ring = []
        for i in range(segs):
            th = 2 * math.pi * i / segs
            rib = (0.5 + 0.5 * math.cos(ribs * th))
            rad = rr - w * rib_d * (1 - rib)
            ring.append(bm.verts.new((cx + rad * math.cos(th), cy + rad * math.sin(th), h)))
        rings.append(ring)
    top = bm.verts.new((cx, cy, h1 + dome * 1.15)); bot = bm.verts.new((cx, cy, h0))
    for a, b_ in zip(rings[:-1], rings[1:]):
        for i in range(segs):
            j = (i + 1) % segs
            bm.faces.new((a[i], a[j], b_[j], b_[i]))
    for i in range(segs):
        j = (i + 1) % segs
        bm.faces.new((rings[-1][i], rings[-1][j], top))
        bm.faces.new((rings[0][j], rings[0][i], bot))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    ob = P._new(name, bm); ob.data.materials.append(mat)
    return ob


def prism(name, cx, cy, hw, hh, cr, z0, z1, mat, k=4):
    """liquid column: rounded-rectangle plan, flat top / bottom, NO top/bottom rounding (stretches cleanly in Y)"""
    pts = W.rrect_pts(hw, hh, cr, k, cx, cy)
    return W.outline_slab(name, pts, z0, z1, 0.0, 1, XY, material=mat, rad_back=0.0, n_back=1, support=False, cap='fan')


def finish_body(ob, path, tex, paint, alpha):
    P.finish(ob, path, tex=tex, smooth_angle=40, weighted=True, pivot_bottom=False, paint=paint, cull_hidden=False,
             recalc_normals=True)
    make_translucent(ob, alpha)
    export_one(ob, path + ".glb")


def finish_solid(ob, path, tex, paint=None, smooth_angle=50, cull=True):
    P.finish(ob, path, tex=tex, smooth_angle=smooth_angle, weighted=True, pivot_bottom=False, paint=paint, cull_hidden=cull,
             recalc_normals=True)


def finish_liquid(ob, path, hexcol):
    m = plain_material(ob.name + "_mat", hexcol, 0.22)
    ob.data.materials.clear(); ob.data.materials.append(m)
    smooth(ob, 35)
    export_one(ob, path + ".glb")


def paint_text(Pm, Nm, base, mask, plane_axis, plane_val, sign, words, col, half_w, tol=0.004):
    """paint stroke words on a flat face (normal = sign * plane_axis); words = [(text, h0, y0, height)], h = viewer-right
    (= -car X for a face looking at the car front), y = car up"""
    on = mask & (Nm[..., plane_axis] * sign > 0.95) & (np.abs(Pm[..., plane_axis] - plane_val) < tol)
    hh = -Pm[..., 0]; yy = Pm[..., 2]
    for text, h0, y0, height in words:
        segs, _ = text_segments(text, h0, y0, height)
        m = on & seg_mask(hh, yy, segs, half_w * height)
        base[m] = np.array(hexf(col), np.float32)
    return base


# ====================================================================================== coolant reservoir
def coolant():
    P.reset()
    white = P.mat("tank", C_("coolant_tank", "#E3E1EA"), 0.32)
    mark = P.mat("mark", C_("coolant_mark", "#C9C3D1"), 0.40)
    pink = P.mat("cap", C_("coolant_cap", "#232325"), 0.55)      # carbook 10-21: Camry cap = BLACK flip-up cap
    X0, X1, XS, Y0, YS, Y1 = 2.12, 2.86, 2.53, 2.45, 2.88, 3.48
    FY, LY = 3.40, 3.00          # F / L lines (wr-carbook fault_looks_3d_check #4: F just under the shoulder, L mid side)       # body: inboard / outboard / step x; bottom / step / top
    ZF, ZB = 6.20, 5.58                                                # build y of the front (car z -6.20) / back (-5.58) faces
    CAP = (2.55, 5.75)                                                 # Fluid_Coolant (2.55, 3.585, -5.75), decor attachment
    outline = [(X0, Y0), (XS, Y0), (XS, YS), (X1, YS), (X1, Y1), (X0, Y1)]
    outline = W.round_corners(outline, [0.11, 0.10, 0.06, 0.10, 0.13, 0.13], 4)
    body = pillow_slab("CoolantTank_Body", outline, ZB, ZF, 0.07, 0.07, 0.010, 3, YZ, material=white, n_mid=4)
    parts = []
    # moulding seam band round the upper part (concept: between F and L, nearer F)
    parts.append(W.outline_slab("band", W.rrect_pts((X1 - X0) / 2 + 0.012, (ZF - ZB) / 2 + 0.012, 0.082, 4, (X0 + X1) / 2, (ZF + ZB) / 2),
                                3.235, 3.275, 0.009, 2, XY, material=white, support=False))
    # filler neck under the cap
    parts.append(W.revolve_x("neck", [(0, 3.508), (0.118, 3.508), (0.125, 3.501), (0.125, 3.43), (0, 3.43)], 24, closed=False,
                             material=white, center=(CAP[0], CAP[1], 0), axis='Z'))
    # two mounting ears with bolt holes, top corners of the back face (concept back / side views)
    for x0, x1 in ((X0, X0 + 0.17), (X1 - 0.17, X1)):
        cx = (x0 + x1) / 2; r = (x1 - x0) / 2
        out = [(x0, 3.31), (x1, 3.31)] + [(cx + r * math.cos(math.pi * k / 10), 3.48 + r * math.sin(math.pi * k / 10)) for k in range(11)]
        hole = W.circle_pts(cx, 3.485, 0.033, 16)
        parts.append(W.curve_plate("ear", [out, hole], 0.0175, 0.006, 1, W.frame((0, ZB + 0.0055, 0), (1, 0, 0), (0, 0, 1), (0, 1, 0)),
                                   material=white))
    # hose nipple on the inboard side, low (to the radiator filler neck): base boss + 2 barbs
    ny, nz = 5.80, 2.58
    prof = [(0, 2.16), (0.052, 2.16), (0.052, 2.085), (0.045, 2.072), (0.034, 2.066), (0.034, 2.04), (0.043, 2.036), (0.034, 2.008),
            (0.042, 2.004), (0.031, 1.968), (0.024, 1.962), (0, 1.962)]
    parts.append(W.revolve_x("nipple", prof, 12, closed=False, material=white, center=(0, ny, nz), axis='X'))
    # raised level dashes F (3.30) / L (2.80) on the front face, inboard half (the lower part is the inboard half)
    for yy in (FY, LY):
        parts.append(P.rounded_box("dash", (0.14, 0.024, 0.022), (2.34, ZF + 0.004, yy), 0.007, segs=2, material=mark))
    boolean_union(body, parts, "CoolantTank_Body")
    set_mat_all(body, white)
    set_mat_where(body, mark, lambda c, n: c.y > ZF + 0.002 and 2.26 < c.x < 2.42 and (abs(c.z - FY) < 0.02 or abs(c.z - LY) < 0.02))
    set_origin(body, Vector(((X0 + X1) / 2, (ZF + ZB) / 2, Y0)))
    print("coolant body tris", tris_of(body))

    def paint(Pm, Nm, base, orm, mask):
        words = [("F", -2.258, FY - 0.056, 0.062), ("L", -2.258, LY - 0.031, 0.062)]
        return paint_text(Pm, Nm, base, mask, 1, ZF, 1, words, C_("coolant_letter", "#BDB6C6"), 0.085), orm

    finish_body(body, os.path.join(OUT, "CoolantTank_Body"), 1024, paint, float(C_("tank_alpha", 0.55)))
    INFO["CoolantTank_Body"] = mesh_info(body)
    bpy.data.objects.remove(body)

    # black FLIP-UP cap (not a twist cap): smooth round lid with a fine edge groove, latch tab at the front, overflow-hose
    # nipple on top; origin = the hinge at the cap's back edge (opens about +X, front up). Top = Fluid_Coolant 3.585
    cparts = [ribbed_cap("lid", CAP[0], CAP[1], 3.50, 3.585, 0.15, 24, 0.004, 0.026, pink, spr=2, dome=0.008)]
    cparts.append(P.rounded_box("tab", (0.09, 0.05, 0.06), (CAP[0], CAP[1] + 0.155, 3.535), 0.016, segs=2, material=pink))
    cparts.append(W.revolve_x("nip", [(0, 3.645), (0.026, 3.645), (0.033, 3.630), (0.026, 3.615), (0.034, 3.600), (0.040, 3.584), (0, 3.584)], 14,
                              closed=False, material=pink, center=(CAP[0], CAP[1] - 0.03, 0), axis='Z'))
    cap = W.join("CoolantTank_Cap", cparts); cap.data.name = "CoolantTank_Cap"
    set_origin(cap, Vector((CAP[0], CAP[1] - 0.15, 3.50)))
    finish_solid(cap, os.path.join(OUT, "CoolantTank_Cap"), 512, smooth_angle=55)
    INFO["CoolantTank_Cap"] = mesh_info(cap)
    bpy.data.objects.remove(cap)
    # overflow hose: cap nipple -> over the front edge -> down to where the old decor reservoir hose continues to the
    # radiator filler neck (decor coolant_hose kept from car z -6.45 forward)
    hose_m = P.mat("hose", C_("coolant_hose", "#2A2D33"), 0.65)
    pts = [B(2.55, 3.630, -5.72), B(2.53, 3.70, -5.84), B(2.46, 3.70, -6.02), B(2.36, 3.58, -6.20), B(2.25, 3.34, -6.31), B(2.19, 3.14, -6.40),
           B(2.175, 3.06, -6.48)]
    hose = W.tube("CoolantTank_OverflowHose", pts, 0.027, 10, material=hose_m); hose.data.name = hose.name
    set_origin(hose, pts[0])
    finish_solid(hose, os.path.join(OUT, "CoolantTank_OverflowHose"), 256, smooth_angle=70, cull=False)
    INFO["CoolantTank_OverflowHose"] = mesh_info(hose)
    bpy.data.objects.remove(hose)

    # liquid: lower (inboard column, whole depth) + upper (full width above the step); built at the F line
    W_ = 0.045
    lo = prism("Deco_Level_Coolant", (X0 + XS) / 2, (ZF + ZB) / 2, (XS - X0) / 2 - W_, (ZF - ZB) / 2 - W_, 0.05, Y0 + W_, YS + W_, None)
    set_origin(lo, Vector(((X0 + XS) / 2, (ZF + ZB) / 2, Y0 + W_)))
    finish_liquid(lo, os.path.join(OUT, "Deco_Level_Coolant"), C_("coolant_liquid", "#E59AB8"))
    INFO["Deco_Level_Coolant"] = mesh_info(lo)
    up = prism("Deco_Level_Coolant_Upper", (X0 + X1) / 2, (ZF + ZB) / 2, (X1 - X0) / 2 - W_, (ZF - ZB) / 2 - W_, 0.05, YS + W_, FY, None)
    set_origin(up, Vector(((X0 + X1) / 2, (ZF + ZB) / 2, YS + W_)))
    finish_liquid(up, os.path.join(OUT, "Deco_Level_Coolant_Upper"), C_("coolant_liquid", "#E59AB8"))
    INFO["Deco_Level_Coolant_Upper"] = mesh_info(up)


# ====================================================================================== brake fluid reservoir
def brake():
    P.reset()
    white = P.mat("tank", C_("brake_tank", "#E4E2DB"), 0.32)
    mark = P.mat("mark", C_("brake_mark", "#CDC9BE"), 0.40)
    yellow = P.mat("cap", C_("brake_cap", "#ECE8E2"), 0.40)     # carbook 10-21: Camry brake cap = WHITE
    black = P.mat("base", C_("brake_base", "#2C2C2D"), 0.62)
    rubber = P.mat("grommet", C_("brake_grommet", "#232324"), 0.80)
    tip = P.mat("tip", C_("brake_tip", "#C9C6BF"), 0.45)
    CX, CY = -1.55, 4.72                       # Fluid_BrakeFluid (-1.55, 3.43, -4.72)
    HW, HH = 0.345, 0.215                      # body half width (car x) / half depth (car z)
    YB, YT = 2.885, 3.335                      # body bottom / top
    ZF = CY + HH                               # build y of the front face (car z -4.935)
    body = pillow_slab("BrakeReservoir_Body", W.rrect_pts(HW, HH, 0.09, 5, CX, CY), YB, YT, 0.06, 0.05, 0.012, 4, XY, material=white,
                       n_mid=4)
    parts = []
    parts.append(W.outline_slab("lid", W.rrect_pts(HW + 0.016, HH + 0.016, 0.106, 5, CX, CY), 3.292, 3.32, 0.010, 2, XY,
                                material=white, support=False))
    parts.append(W.outline_slab("plateau", W.rrect_pts(0.22, 0.17, 0.08, 5, CX, CY), 3.31, 3.343, 0.008, 2, XY, material=white,
                                support=False))
    parts.append(W.revolve_x("neck", [(0, 3.36), (0.105, 3.36), (0.105, 3.33), (0, 3.33)], 24, closed=False,
                             material=white, center=(CX, CY, 0), axis='Z'))
    for yy in (3.28, 3.02):          # MAX / MIN dashes
        parts.append(P.rounded_box("dash", (0.10, 0.022, 0.018), (-1.48, ZF + 0.004, yy), 0.006, segs=2, material=mark))
    boolean_union(body, parts, "BrakeReservoir_Body")
    set_mat_all(body, white)
    set_mat_where(body, mark, lambda c, n: c.y > ZF + 0.009 and -1.54 < c.x < -1.42 and (abs(c.z - 3.28) < 0.016 or abs(c.z - 3.02) < 0.016))
    set_origin(body, Vector((CX, CY, YB)))
    print("brake body tris", tris_of(body))

    def paint(Pm, Nm, base, orm, mask):
        words = [("MAX", 1.548, 3.272 - 0.018, 0.036), ("MIN", 1.548, 3.02 - 0.018, 0.036)]
        return paint_text(Pm, Nm, base, mask, 1, ZF + 0.004, 1, words, C_("brake_letter", "#BEB9AD"), 0.11, tol=0.012), orm

    finish_body(body, os.path.join(OUT, "BrakeReservoir_Body"), 1024, paint, float(C_("tank_alpha", 0.55)))
    INFO["BrakeReservoir_Body"] = mesh_info(body)
    bpy.data.objects.remove(body)

    # black base on the master cylinder: plate, 2 grommets + white outlet tips (along the master cylinder, car z),
    # level-sensor connector on the outboard (-x, object's left) side
    bparts = [W.outline_slab("plate", W.densify(W.rrect_pts(0.31, 0.18, 0.07, 5, CX, CY), 0.1), 2.835, 2.888, 0.012, 2, XY,
                             material=black, rad_back=0.006, n_back=1, support=True)]
    for dy in (-0.12, 0.12):
        bparts.append(W.revolve_x("grommet", [(0, 2.84), (0.058, 2.84), (0.062, 2.826), (0.056, 2.79), (0, 2.79)], 20, closed=False,
                                  material=rubber, center=(CX, CY + dy, 0), axis='Z'))
        bparts.append(W.revolve_x("tip", [(0, 2.80), (0.036, 2.80), (0.036, 2.745), (0.029, 2.738), (0, 2.738)], 16, closed=False,
                                  material=tip, center=(CX, CY + dy, 0), axis='Z'))
    bparts.append(P.rounded_box("conn", (0.09, 0.165, 0.16), (CX - HW - 0.06, CY, 3.13), 0.018, segs=2, material=black))
    bparts.append(W.revolve_x("conn_boss", [(0, -1.893), (0.055, -1.893), (0.055, -1.92), (0, -1.92)], 16, closed=False, material=black,
                              center=(0, CY, 3.13), axis='X'))
    base = W.join("BrakeReservoir_Base", bparts)
    set_origin(base, Vector((CX, CY, YB)))

    def paint_b(Pm, Nm, base_, orm, mask):
        x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
        face = mask & (Nm[..., 0] < -0.95) & (x < CX - HW - 0.10)
        sock = face & (np.abs(y - CY) < 0.052) & (np.abs(z - 3.13) < 0.05)
        base_[sock] = np.array(hexf("#0D0D0E"), np.float32)
        pin = sock & (np.abs(y - CY) < 0.009) & (np.abs(z - 3.13) < 0.026)
        base_[pin] = np.array(hexf("#77777A"), np.float32)
        return base_, orm

    finish_solid(base, os.path.join(OUT, "BrakeReservoir_Base"), 512, paint=paint_b)
    INFO["BrakeReservoir_Base"] = mesh_info(base)
    bpy.data.objects.remove(base)

    cap = ribbed_cap("BrakeReservoir_Cap", CX, CY, 3.345, 3.43, 0.15, 16, 0.006, 0.02, yellow)
    set_origin(cap, Vector((CX, CY, 3.345)))
    finish_solid(cap, os.path.join(OUT, "BrakeReservoir_Cap"), 512, smooth_angle=60)
    INFO["BrakeReservoir_Cap"] = mesh_info(cap)
    bpy.data.objects.remove(cap)

    W_ = 0.042
    liq = prism("Deco_Level_BrakeFluid", CX, CY, HW - W_, HH - W_, 0.06, YB + 0.04, 3.15, None)
    set_origin(liq, Vector((CX, CY, YB + 0.04)))
    finish_liquid(liq, os.path.join(OUT, "Deco_Level_BrakeFluid"), C_("brake_liquid_new", "#EFD98A"))
    INFO["Deco_Level_BrakeFluid"] = mesh_info(liq)


if "coolant" in WHICH:
    coolant()
if "brake" in WHICH:
    brake()
old = {}
pj = os.path.join(OUT, "mesh_info.json")
if os.path.exists(pj):
    old = json.load(open(pj, encoding="utf-8"))
old.update(INFO)
json.dump(old, open(pj, "w", encoding="utf-8"), indent=1)
print("TRIS", {k: v["tris"] for k, v in INFO.items()})
