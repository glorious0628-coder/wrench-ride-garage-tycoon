# Fuse puller (wr 3D helper 10-22) - one-piece moulded plastic U "tweezers", measured on
# art/concepts/tools/fuse_puller_6view.png front view (per-column outline; top / bottom views of that sheet are not used).
# Real: ~100 mm, nylon, arms flex at the U end, small hooked jaws with serrated faces that pinch the blade fuse's head
# (notes/research/ref_tools_firstbatch/index.md 1). Game: 0.74 stud (the bay's mini fuse is 0.07 wide -> rest jaw gap
# 0.084, a light squeeze closes it on the fuse).
# Build frame: length along X (jaws at +X), U plane = XZ, front face +Y. Origin = middle of the length.
#   blender -b --factory-startup --python build_fuse_puller.py -- <out_dir> [palette.json]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tv2_lib as T
from tv2_lib import W, P, Vector, Matrix, np, rb

OUT, PAL = T.args()
C = lambda n, d: PAL.get(n, d)
L = 0.74
S = L / 356.0                      # stud per concept pixel (front view 356 px long)
TEETH_Y = 48.0 - 0.042 / S         # jaw teeth faces at z = +-0.042 (rest gap 0.084)
HT = 0.035                         # half thickness at the grip (tapers to 0.026 at the jaws)


def XZ(xc, yc):
    return (0.37 - xc * S, (48.0 - yc) * S)


# top half, concept pixels (x from the jaw tip, y from the top edge; the sheet is symmetric about y = 48)
top_outer = [(355, 48), (354.6, 40), (353, 31), (349, 17), (343, 9.5), (335, 6.5), (318, 5), (282, 4), (250, 2), (220, 0.6),
             (186, 0), (160, 1), (130, 3), (108, 4), (84, 6), (60, 6), (45, 5), (30, 3.2), (18, 3.5), (9, 6), (3.5, 10),
             (0.8, 16), (0, 22), (0.4, 26.5)]
top_inner = [(1.5, TEETH_Y), (9, TEETH_Y), (11.5, 25.0), (14, 23.0), (22, 23.0), (24.5, 25.5), (27, TEETH_Y), (44, TEETH_Y),
             (46.5, 25.0), (52, 23), (72, 25), (96, 27), (120, 29), (150, 33), (174, 35), (200, 36), (250, 36), (300, 35.5),
             (313, 35.5), (318.5, 36.6), (321.3, 39.2), (322.5, 43)]
slot_end = [(322.8, 48)]


def mirror(pts):
    return [(x, 96.0 - y) for x, y in pts]


poly = top_outer[1:] + top_inner + slot_end + mirror(top_inner)[::-1] + mirror(top_outer[1:])[::-1] + [top_outer[0]]
outline = [XZ(x, y) for x, y in poly]
# drop near-duplicates
clean = []
for p in outline:
    if not clean or (Vector(p) - Vector(clean[-1])).length > 1e-5:
        clean.append(p)
outline = W._ccw(clean)

P.reset()
red = P.mat("plastic", C("plastic", "#E0353A"), 0.55, 0.0)
FXZ = W.frame((0, 0, 0), (1, 0, 0), (0, 0, 1), (0, -1, 0))
body = W.outline_slab("body", outline, -HT, HT, 0.010, 2, FXZ, material=red, support=False)


def taper(x):
    """thickness factor along X: 1 at the grip, 0.74 at the jaws"""
    x0, x1 = XZ(120, 0)[0], XZ(45, 0)[0]
    return 1.0 - 0.26 * W.smoothstep(x0, x1, x)


for v in body.data.vertices:
    v.co.y *= taper(v.co.x)
parts = [body]
# raised grip ribs: 5 per arm on both faces (concept x 194..264 from the jaw end, across the arm y 8..31)
for xc in (194, 211, 228, 246, 264):
    for sz in (1, -1):
        X, Zc = XZ(xc, 19.5)
        Zc *= sz
        for sy in (1, -1):
            ex, ey, ez = (1, 0, 0), (0, 0, -sy), (0, sy, 0)
            fr = W.frame((X, 0, Zc), ex, ey, ez)
            rib = W.outline_slab("rib", W.rrect_pts(0.0075, 0.024, 0.0072, 1), HT - 0.004, HT + 0.0065, 0.004, 1, fr, material=red,
                                 rad_back=0.0, support=False, cap='fan')
            parts.append(rib)
ob = W.join("FusePuller", parts)
T.group_by(ob, lambda co: "armA" if co.z > 0 else "armB")
print("tris before finish", P.tris(ob))


def paint(Pm, Nm, base, orm, mask):
    """serrations on the jaw teeth faces (the faces that touch the fuse)"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    xt0, xt1 = XZ(44, 0)[0], XZ(27, 0)[0]
    face = mask & (np.abs(Nm[..., 2]) > 0.8) & (np.abs(np.abs(z) - 0.042) < 0.004) & (x > xt0) & (x < xt1)
    line = face & (np.mod((x - xt0) / 0.0072, 1.0) < 0.35)
    base[line] = base[line] * 0.62
    return base, orm


T.finish(ob, OUT, "FusePuller", paint=paint)
# ---- attachments (Roblox axes)
tip = XZ(44, 48)                 # deepest point between the teeth = where the fuse's top lands
piv = XZ(330, 48)
r_tooth = XZ(35, 48)[0] - piv[0]
close = math.degrees(math.asin((0.042 - 0.035) / r_tooth))
data = {"tool": "Fuse puller (one-piece plastic, mini blade fuses)", "units": "stud",
        "space": "mesh local, Roblox axes (+X = toward the jaws, +Y = across the U (arm A side), -Z = the front face of the concept front view); origin = middle of the length",
        "Grip": {"pos": rb((XZ(230, 48)[0], 0, 0)), "axis": [1, 0, 0], "secondary_axis": [0, 0, -1],
                 "note": "middle of the ribbed arms (thumb on one arm, fingers on the other). Axis (+X) toward the jaws; SecondaryAxis = front face. Same convention as the Wrench."},
        "Tip": {"pos": rb((tip[0], 0, 0)), "axis": [1, 0, 0],
                "note": "where the fuse's TOP sits between the teeth (fuse head goes 0.035 into the jaws). Axis = the way the jaws point: align it with -(fastener axis) of F_FusePull_1 (the fuse comes out along +axis of the fastener)."},
        "Jaw_Gap": {"rest": 0.084, "fuse_width": 0.07},
        "Squeeze": {"pivot": rb((piv[0], 0, 0)),
                    "rig_glb": "FusePuller_Rig.glb (nodes FusePuller_ArmA = +Y arm, FusePuller_ArmB = -Y arm; same axes / texture as FusePuller.glb)",
                    "ArmA_axis": rb((0, 1, 0)), "ArmB_axis": rb((0, -1, 0)),
                    "close_deg": round(close, 2), "max_deg": 3.0,
                    "rule": "arm CFrame = pivot * CFrame.fromAxisAngle(axis, rad(t)) * pivot:Inverse() * rest; t = 0 rest (open), close_deg = teeth touch a 0.07 fuse, max_deg = fully pinched. The real tool only flexes ~1 deg: exaggerate in code if wanted. Convert pivot / axes with meshLocal like Grip."},
        "size": "0.74 long x 0.20 tall (U) x 0.07 thick (0.052 at the jaws)"}
T.write_json(os.path.join(OUT, "fuse_puller_attachments.json"), data, ob)
T.export_rig(ob, os.path.join(OUT, "FusePuller_Rig.glb"), {"armA": "FusePuller_ArmA", "armB": "FusePuller_ArmB"})
print("ok")
