# Windshield wipers (arm + blade, long 2.7 driver / short 1.9 passenger) for WIPER_WORN (wr-3d helper 10-21),
# fault_looks v0.3 §5b, concept art/concepts/workview/wiper_long_6view.png (short = same shape, blade 1.9).
# Each wiper is built in its own frame (X = u along the blade toward its tip, Y = v down the glass slope, Z = n =
# glass normal; origin = pivot on the drum axis at the cowl), fitted to the sedan's real glass (B_concept Glass mesh):
# the blade's rubber edge rests on the glass (bend = the glass bulge along the rest line), the pivot drum stands at
# the cowl / glass junction. Exported twice: local frame (review views) and car rest pose (game: node origin = pivot
# for arms, rubber-edge middle for blades). Worn blade = same mesh, cracked rubber texture.
#   blender -b --factory-startup --python build_wipers.py -- <out_dir> [palette.json]
import bpy, bmesh, sys, os, math, json, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fault_common import *  # noqa
import numpy as np
from mathutils.bvhtree import BVHTree

argv = sys.argv[sys.argv.index("--") + 1:]
OUT = os.path.abspath(argv[0]); os.makedirs(OUT, exist_ok=True)
PAL = json.load(open(argv[1], encoding="utf-8")) if len(argv) > 1 and argv[1] else {}
C_ = lambda k, d: PAL.get(k, d)

# ------------------------------------------------------------------ glass / cowl of the sedan (build coords)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=os.path.join(SEDAN, "B_concept", "sedan_body_all.glb"))
TREES = {}
for o in bpy.context.scene.objects:
    if o.type == 'MESH' and o.name in ("Glass", "Shell"):
        bm = bmesh.new(); bm.from_mesh(o.data); bm.transform(o.matrix_world); TREES[o.name] = BVHTree.FromBMesh(bm)
DOWN = Vector((0, 0, -1))


def hit(name, x, yb):
    h = TREES[name].ray_cast(Vector((x, yb, 9.0)), DOWN, 20)
    return (h[0], h[1]) if h[0] is not None else (None, None)


def glass_n(x, yb, e=0.02):
    """smooth glass normal from 4 nearby hits (face normals of a faceted mesh jump)"""
    ps = [hit("Glass", x + dx, yb + dy)[0] for dx, dy in ((-e, 0), (e, 0), (0, -e), (0, e))]
    n = (ps[1] - ps[0]).cross(ps[3] - ps[2]).normalized()
    return n if n.z > 0 else -n


def edge_y(x):
    """build y of the glass bottom edge at x (front-most y with glass)"""
    for k in range(200):
        yb = 3.95 - 0.002 * k
        if hit("Glass", x, yb)[0] is not None:
            return yb
    return None


def fit(px, L, yb_line, near=0.16):
    xs = [px + near + L * i / 24 for i in range(25)]
    G = [hit("Glass", x, yb_line)[0] for x in xs]
    N = [glass_n(x, yb_line) for x in xs]
    u = (G[-1] - G[0]).normalized()
    n0 = sum(N, Vector()).normalized(); n = (n0 - u * u.dot(n0)).normalized()
    v = n.cross(u).normalized()                    # down the slope (toward the car front)
    t = [((g - G[0]).dot(u) - L / 2) / (L / 2) for g in G]
    h = [(g - G[0]).dot(n) for g in G]
    A = np.array([[1.0, 1 - ti * ti] for ti in t]); c0, sag = np.linalg.lstsq(A, np.array(h), rcond=None)[0]
    sag = float(min(max(sag, 0.0), 0.06))
    M = G[0] + u * (L / 2) + n * (c0 + sag)
    gaps = []
    for g, nn, ti in zip(G, N, t):
        E = M + u * (ti * L / 2) + n * (sag * (1 - ti * ti) - sag)
        gaps.append((E - g).dot(nn))
    lift = max(0.0, 0.004 - min(gaps)); M = M + n * lift
    gaps = [g_ + lift for g_ in gaps]
    # pivot: on the cowl just in front of the glass edge (the hood's rear edge sweeps up in front of the hinge
    # line, so nothing may stand there: y 3.80 = car z -3.80 is behind the hinge's danger band)
    pc, _ = hit("Shell", px, 3.80)
    return {"u": u, "v": v, "n": n, "M": M, "sag": sag, "gap_min": min(gaps), "gap_max": max(gaps), "P": pc, "edge": edge_y(px)}


# ------------------------------------------------------------------ meshes in the local frame
def section_loft(name, path, sect, mat, up=Vector((0, 0, 1)), scales=None, cap=True):
    """loft a closed cross-section (list of (side, up) points) along a 3D path; side = tangent x up"""
    rings = []
    for i, p in enumerate(path):
        tng = (path[min(i + 1, len(path) - 1)] - path[max(i - 1, 0)]).normalized()
        side = tng.cross(up).normalized(); upv = side.cross(tng).normalized()
        sc = scales[i] if scales else (1.0, 1.0)
        rings.append([p + side * a * sc[0] + upv * b * sc[1] for a, b in sect])
    return W.loft(name, rings, cap0=cap, cap1=cap, material=mat)


def rrect_sect(w, h, r, k=2):
    pts = W.rrect_pts(w / 2, h / 2, r, k)
    return [(x, y) for x, y in pts]


BLADE = [(0.010, 0.000), (0.017, 0.012), (0.019, 0.022), (0.041, 0.027), (0.046, 0.036), (0.043, 0.046), (0.030, 0.063), (0.012, 0.076),
         (-0.012, 0.076), (-0.030, 0.063), (-0.043, 0.046), (-0.046, 0.036), (-0.041, 0.027), (-0.019, 0.022), (-0.017, 0.012), (-0.010, 0.000)]


def build_blade(name, L, sag, mats):
    """blade in its own frame: origin = rubber edge middle, X along the blade, Y across, Z off the glass"""
    beam, rubber, cap_m, adapter = mats
    n_st = 18
    rings = []
    for i in range(n_st + 1):
        tt = -1 + 2 * i / n_st; x = tt * L / 2
        z0 = sag * (1 - tt * tt) - sag
        # the blade narrows a little toward the end caps
        k = 1.0 - 0.10 * max(0.0, abs(tt) - 0.85) / 0.15
        rings.append([Vector((x, a * k, z0 + b * k)) for a, b in BLADE])
    blade = W.loft("blade", [[Vector((r.x, -r.y, r.z)) for r in ring] for ring in rings], cap0=True, cap1=True, material=beam)
    blade.data.materials.append(rubber)
    for p in blade.data.polygons:            # rubber = the lip (lowest 0.024 above the bent bottom line)
        c = Vector(p.center); tt = c.x / (L / 2)
        if c.z - (sag * (1 - tt * tt) - sag) < 0.024:
            p.material_index = 1
    parts = [blade]
    for s in (-1, 1):                         # end caps (concept: chunky clip at each end)
        tt = s * (1 - 0.06 / L); x = tt * L / 2; z0 = sag * (1 - tt * tt) - sag
        parts.append(P.rounded_box("endcap", (0.10, 0.098, 0.07), (x - s * 0.01, 0, z0 + 0.044), 0.018, segs=2, material=cap_m))
    parts.append(P.rounded_box("adapter", (0.22, 0.082, 0.05), (0, 0, 0.088), 0.014, segs=2, material=adapter))
    parts.append(P.rounded_box("adapter_base", (0.26, 0.094, 0.024), (0, 0, 0.068), 0.008, segs=1, material=adapter))
    return W.join(name, parts)


def build_arm(name, fitd, mats):
    """arm in the wiper frame: drum on the pivot (axis Z), root block, tapered bar to the blade adapter, hook"""
    arm_m, drum_m, cap_m = mats
    M_loc = fitd["M_loc"]                     # rubber-edge middle of the blade in this frame
    ad_top = M_loc + Vector((0, 0, 0.113))    # adapter top
    parts = []
    z0, z1 = -0.07, 0.15
    prof = [(0, z0), (0.143, z0), (0.145, z0 + 0.01), (0.145, z1 - 0.03), (0.141, z1 - 0.012), (0.130, z1 - 0.002), (0.114, z1),
            (0.100, z1), (0.098, z1 - 0.006), (0, z1 - 0.006)]
    parts.append(W.revolve_x("drum", prof, 28, closed=False, material=drum_m, axis='Z'))
    parts.append(W.revolve_x("drum_cap", [(0, z1 + 0.004), (0.086, z1 + 0.004), (0.096, z1 - 0.004), (0.096, z1 - 0.01), (0, z1 - 0.01)], 24,
                             closed=False, material=cap_m, axis='Z'))
    # root block: from the drum side toward the blade (tapers from 0.12 to 0.075 wide, 0.11 to 0.07 high)
    dirv = Vector((ad_top.x, ad_top.y, 0)).normalized()
    zr = max(ad_top.z + 0.06, 0.10)
    root = [dirv * 0.05 + Vector((0, 0, zr)), dirv * 0.20 + Vector((0, 0, zr)), dirv * 0.32 + Vector((0, 0, zr - 0.004))]
    parts.append(section_loft("root", root, rrect_sect(0.14, 0.12, 0.04), arm_m, scales=[(1, 1), (0.82, 0.8), (0.66, 0.64)]))
    # bar: from the root down to just over the adapter (straight, slowly tapering, flat-ish section)
    a0 = dirv * 0.30 + Vector((0, 0, zr - 0.004)); a1 = ad_top + Vector((0, 0, 0.026)) - dirv * 0.20
    bar = [a0.lerp(a1, i / 6) for i in range(7)]
    parts.append(section_loft("bar", bar, rrect_sect(0.09, 0.062, 0.022), arm_m, scales=[(1 - 0.2 * i / 6, 1 - 0.1 * i / 6) for i in range(7)]))
    # hook / clip over the adapter (rounded block whose underside sits on the adapter top)
    hk = [a1 - dirv * 0.02, ad_top + Vector((0, 0, 0.018)) - dirv * 0.06, ad_top + Vector((0, 0, 0.018)) + dirv * 0.06]
    parts.append(section_loft("hook", hk, rrect_sect(0.094, 0.046, 0.016), arm_m, scales=[(0.8, 1.2), (1, 1), (1, 0.9)]))
    return W.join(name, parts)


def worn_paint(L, sag):
    rng = random.Random(7 if L > 2 else 11)
    cracks = [(rng.uniform(-L / 2 + 0.06, L / 2 - 0.06), rng.uniform(0.0025, 0.0045), rng.uniform(-0.3, 0.3)) for _ in range(int(26 * L))]
    nicks = [(rng.uniform(-L / 2 + 0.1, L / 2 - 0.1), rng.uniform(0.01, 0.03)) for _ in range(int(3 * L))]

    def paint(Pm, Nm, base, orm, mask):
        x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
        tt = np.clip(x / (L / 2), -1, 1); zb = z - (sag * (1 - tt * tt) - sag)
        rub = mask & (zb < 0.024) & (zb > -0.002)
        wear = rub & (zb < 0.010)
        base[wear] = base[wear] * 0.55 + np.array(hexf("#77777A"), np.float32) * 0.45       # chalky worn edge
        for cx, w, sk in cracks:
            m = rub & (np.abs(x - cx - sk * (zb - 0.012)) < w)
            base[m] = np.array(hexf("#9A9A9C"), np.float32)
            orm[m, 1] = 0.95
        for cx, w in nicks:                                                                    # bitten-out bits
            m = rub & (np.abs(x - cx) < w) & (zb < 0.008)
            base[m] = np.array(hexf("#0B0B0B"), np.float32)
        return base, orm
    return paint


# ------------------------------------------------------------------ build both wipers
# driver 26 in = 2.7, passenger 20 in = 2.1 (wr-carbook fault_looks_3d_check #9; fault_looks §5b said 1.9)
WIPERS = {"Long": {"px": -2.40, "L": 2.70, "yb_line": 3.60}, "Short": {"px": 0.20, "L": 2.10, "yb_line": 3.67}}
J = {}
for key, w in WIPERS.items():
    f = fit(w["px"], w["L"], w["yb_line"])
    Rm = Matrix((f["u"], f["v"], f["n"])).transposed()            # local -> build rotation (columns u, v, n)
    Pv = f["P"]
    f["M_loc"] = Rm.transposed() @ (f["M"] - Pv)
    print(key, "pivot", R(Pv), "blade mid", R(f["M"]), "M_loc", [round(c, 3) for c in f["M_loc"]], "sag", round(f["sag"], 4),
          "gap", round(f["gap_min"], 4), round(f["gap_max"], 4))
    for part in ("Arm", "Blade", "BladeWorn"):
        P.reset()
        arm_m = P.mat("arm", C_("wiper_arm", "#333335"), 0.45, 0.25)
        drum_m = P.mat("drum", C_("wiper_drum", "#3C3C3F"), 0.40, 0.2)
        capd = P.mat("drumcap", C_("wiper_drumcap", "#29292B"), 0.55, 0.0)
        beam = P.mat("beam", C_("wiper_beam", "#262628"), 0.50, 0.0)
        rubber = P.mat("rubber", C_("wiper_rubber", "#1C1C1D"), 0.85, 0.0)
        ecap = P.mat("endcap", C_("wiper_endcap", "#2B2B2D"), 0.55, 0.0)
        adap = P.mat("adapter", C_("wiper_adapter", "#38383B"), 0.50, 0.0)
        if part == "Arm":
            ob = build_arm("WiperArm_" + key, f, (arm_m, drum_m, capd)); origin_build = Pv; loc0 = Vector()
            paint = None
        else:
            ob = build_blade("WiperBlade_" + key + ("_Worn" if part == "BladeWorn" else ""), w["L"], f["sag"], (beam, rubber, ecap, adap))
            origin_build = f["M"]; loc0 = f["M_loc"]
            paint = worn_paint(w["L"], f["sag"]) if part == "BladeWorn" else None
        nm = ob.name; ob.data.name = nm
        # local-frame copy for the review views (blade sits at its place relative to the pivot)
        P.finish(ob, os.path.join(OUT, nm), tex=512 if part == "Arm" else 1024, smooth_angle=55, weighted=False, pivot_bottom=False,
                 paint=paint, cull_hidden=True, recalc_normals=True)
        ob.data.transform(Matrix.Translation(loc0)); ob.location = Vector()
        export_one(ob, os.path.join(OUT, "local_" + nm + ".glb"))
        # car rest pose: rotate into the car, origin at the pivot (arm) / rubber-edge middle (blade)
        ob.data.transform(Matrix.Translation(-loc0)); ob.data.transform(Rm.to_4x4())
        ob.location = origin_build
        export_one(ob, os.path.join(OUT, nm + ".glb"))
        J[nm] = mesh_info(ob)
    uc, vc = f["M_loc"].x, f["M_loc"].y; rr = math.hypot(uc, vc)
    # service position (carbook #10): the arm turns ~60 deg up the glass about the pivot axis (blade stays on the glass);
    # then 'lift arm' = rotate about the lift hinge until the blade middle is 0.4 off the glass
    service_deg = -60.0                               # about +n (right-handed): negative = toward -v = up the glass
    dArm = (f["u"] * uc + f["v"] * vc).normalized(); lift_axis = dArm.cross(f["n"]).normalized()
    lh = Pv + f["n"] * 0.11 + dArm * 0.06
    lift_deg = math.degrees(math.asin(min(1.0, 0.4 / (f["M"] - lh).length)))
    J["fit_" + key] = {"service_deg": service_deg, "lift_hinge": R(lh), "lift_axis": Rdir(lift_axis), "lift_deg": round(lift_deg, 2),
                       "pivot": R(Pv), "u_blade_dir": Rdir(f["u"]), "v_down_slope": Rdir(f["v"]), "n_glass_normal": Rdir(f["n"]),
                       "blade_mid_rubber_edge": R(f["M"]), "blade_mid_local": [round(c, 4) for c in f["M_loc"]],
                       "blade_bend_sag": round(f["sag"], 4), "rubber_gap_min": round(f["gap_min"], 4), "rubber_gap_max": round(f["gap_max"], 4),
                       "glass_edge_build_y": f["edge"], "rest_matrix_cols_uvn": [Rdir(f["u"]), Rdir(f["v"]), Rdir(f["n"])]}
json.dump(J, open(os.path.join(OUT, "wiper_fit.json"), "w", encoding="utf-8"), indent=1)
print("TRIS", {k: v["tris"] for k, v in J.items() if "tris" in v})
