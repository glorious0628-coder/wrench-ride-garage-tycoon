# Hose clamp pliers (wr 3D helper 10-22): swivel-jaw spring-clamp pliers with a ratchet lock bar, after
# art/concepts/tools/hose_clamp_pliers_6view.png front view (its back / top / bottom views are drawn at other scales and
# are not used). Real (ref_tools_firstbatch 4, tools_real 3 [S19][S20]): two steel arms crossing at a riveted pivot,
# round swivel jaw cups with a cross slot for the clamp ears, dipped grips, return spring between the handles and a
# toothed lock bar that holds the clamp squeezed.
# Game: 1.32 stud long. Rest pose is a bit less open than the concept (the grips fit an R15 fist: 0.27 apart);
# a rig GLB (two arms) lets code squeeze it about the rivet.
# Build frame: length along X (jaws at +X), pivot (rivet) at the origin, plier plane XZ, front face +Y (arm A in front).
#   blender -b --factory-startup --python build_hose_pliers.py -- <out_dir> [palette.json]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tv2_lib as T
from tv2_lib import W, P, Vector, Matrix, np, rb

OUT, PAL = T.args()
C = lambda n, d: PAL.get(n, d)
AH = math.radians(11.5)            # handle side angle
AJ, AJ2, RJ_BEND = math.radians(12.0), math.radians(17.0), 0.28   # jaw side angle, bent outward after RJ_BEND
Y0, Y1 = 0.002, 0.034              # arm A layer (arm B = the same turned 180 deg about X)
CUP_R, CUP_H = 0.048, 0.085

P.reset()
steel = P.mat("steel", C("steel", "#55565A"), 0.45, 0.70)
bright = P.mat("bright", C("bright", "#B4B2AE"), 0.35, 0.80)
red = P.mat("grip", C("grip", "#C92D31"), 0.70, 0.0)


def jaw_pt(r):
    """arm A centreline on the jaw side at distance r along it"""
    if r <= RJ_BEND:
        return Vector((r * math.cos(AJ), r * math.sin(AJ)))
    b = Vector((RJ_BEND * math.cos(AJ), RJ_BEND * math.sin(AJ)))
    return b + Vector((math.cos(AJ2), math.sin(AJ2))) * (r - RJ_BEND)


def hdl_pt(r):
    return Vector((-r * math.cos(AH), -r * math.sin(AH)))


# centreline from the handle end to the jaw end with half widths
CL = [(hdl_pt(r), w) for r, w in ((0.855, 0.021), (0.80, 0.022), (0.65, 0.024), (0.47, 0.026), (0.33, 0.029), (0.18, 0.033),
                                  (0.07, 0.036))]
CL += [(jaw_pt(r), w) for r, w in ((0.07, 0.036), (0.16, 0.031), (0.24, 0.027), (0.30, 0.024), (0.36, 0.022), (0.405, 0.021))]
CL = [CL[i] for i in range(len(CL)) if i == 0 or (CL[i][0] - CL[i - 1][0]).length > 1e-4]
CUP_C = jaw_pt(0.405) + Vector((math.cos(AJ2), math.sin(AJ2))) * 0.022      # cup centre (X, Z) of arm A


def strip_outline(cl, k=3):
    """closed CCW outline around a centreline polyline with half widths, round ends"""
    L_, R_ = [], []
    n = len(cl)
    for i, (p, w) in enumerate(cl):
        d = (cl[min(i + 1, n - 1)][0] - cl[max(i - 1, 0)][0]).normalized()
        nn = Vector((-d.y, d.x))
        L_.append(p + nn * w); R_.append(p - nn * w)
    out = []
    d0 = (cl[1][0] - cl[0][0]).normalized(); d1 = (cl[-1][0] - cl[-2][0]).normalized()
    out += R_
    a1 = math.atan2(-d1.x, d1.y) - math.pi     # round jaw end: from the right side over the tip to the left side
    for j in range(1, k):
        a = math.atan2((R_[-1] - cl[-1][0]).y, (R_[-1] - cl[-1][0]).x) + math.pi * j / k
        out.append(cl[-1][0] + Vector((math.cos(a), math.sin(a))) * cl[-1][1])
    out += L_[::-1]
    for j in range(1, k):
        a = math.atan2((L_[0] - cl[0][0]).y, (L_[0] - cl[0][0]).x) + math.pi * j / k
        out.append(cl[0][0] + Vector((math.cos(a), math.sin(a))) * cl[0][1])
    return W._ccw([(p.x, p.y) for p in out])


FXZ = W.frame((0, 0, 0), (1, 0, 0), (0, 0, 1), (0, -1, 0))     # local (x, y) = (X, Z), local z = -Y
armA = []
arm = W.outline_slab("arm", strip_outline(CL), -Y1, -Y0, 0.007, 1, FXZ, material=steel, support=False)
W.mark_sharp(arm, 40)
armA.append(arm)
armA.append(W.outline_slab("boss", W.circle_pts(0, 0, 0.058, 18), -Y1 - 0.003, -(Y0 + 0.0015), 0.0035, 1, FXZ, material=steel, support=False))   # proud of the arm faces by > 1 mm (QA: coplanar faces flicker)
# rivet dome on the front face
armA.append(W.revolve_x("rivet", [(0.0, Y1 + 0.017), (0.018, Y1 + 0.015), (0.03, Y1 + 0.008), (0.034, Y1 + 0.001), (0.034, Y1 - 0.004),
                                  (0.0, Y1 - 0.004)], 12, closed=False, material=bright, axis='Y'))
# swivel jaw cup (axis along Z, toward the other jaw)
cup = P.cylinder("cup", CUP_R, CUP_H, (CUP_C.x, 0.0, CUP_C.y), axis='Z', segs=14, bevel=0.007, bsegs=1, material=bright)
armA.append(cup)
# red dipped grip over the handle end
gd = -Vector((math.cos(AH), 0, math.sin(AH)))
gu = Vector((-gd.z, 0, gd.x))                 # in-plane normal
yv = Vector((0, 1, 0))
YC = (Y0 + Y1) / 2
rings = []
for r, s in ((0.462, 0.90), (0.472, 1.0), (0.60, 1.0), (0.72, 1.02), (0.82, 1.04), (0.858, 0.96), (0.88, 0.80), (0.893, 0.50)):
    c = Vector((0, YC, 0)) + gd * r
    rings.append([c + gu * math.cos(2 * math.pi * k / 10) * 0.040 * s + yv * math.sin(2 * math.pi * k / 10) * 0.035 * s for k in range(10)])
grip = W.loft("grip", rings, cap0=True, cap1=True, material=red)
armA.append(grip)
# spring seat (small cup on the handle's inner edge, the spring's end sits in it)
RS = 0.36
sp_c = hdl_pt(RS)
SEAT_TOP = sp_c.y + 0.028 + 0.010            # arm A's inner edge there is ~sp_c.y + 0.028
armA.append(P.cylinder("seat", 0.024, 0.018, (sp_c.x, 0.0, SEAT_TOP - 0.009), axis='Z', segs=10, bevel=0.004, bsegs=1, material=steel))
# ratchet lock bar (arm A, behind arm B) + pin + release lever; pawl on arm B
RB = 0.43
bc = hdl_pt(RB)
bar = [(bc.x - 0.012, -0.112), (bc.x - 0.012, 0.172)]
bar += [(bc.x - 0.006, 0.182), (bc.x + 0.006, 0.182), (bc.x + 0.012, 0.172)]
z = 0.16
while z > 0.02:
    bar += [(bc.x + 0.012, z), (bc.x + 0.004, z - 0.0088)]
    z -= 0.0175
bar += [(bc.x + 0.012, z), (bc.x + 0.012, -0.112), (bc.x + 0.006, -0.122), (bc.x - 0.006, -0.122)]
barA = W.outline_slab("bar", W._ccw(bar), 0.038, 0.050, 0.002, 1, FXZ, material=steel, support=False)
pin = P.cylinder("pin", 0.010, 0.091, (bc.x, -0.0075, bc.y), axis='Y', segs=8, material=bright)   # end 3 mm proud of the bar (QA: coplanar faces)
lever = P.rounded_box("lever", (0.06, 0.016, 0.03), (bc.x + 0.004, Y1 + 0.007, bc.y - 0.002), 0.007, 2, material=bright)
armA += [barA, pin, lever]
for o in armA:
    T.group(o, "armA")
# arm B = arm A turned 180 deg about X (no bar, pin, lever)
armB = []
for o in armA:
    if o.name.startswith(("bar", "pin", "lever")):
        continue
    me = o.data.copy(); me.transform(Matrix.Rotation(math.pi, 4, 'X'))
    ob2 = bpy.data.objects.new(o.name + "_B", me); bpy.context.scene.collection.objects.link(ob2)
    for g in list(ob2.vertex_groups):
        ob2.vertex_groups.remove(g)
    T.group(ob2, "armB")
    armB.append(ob2)
# the pawl on arm B's back face, where the bar's teeth pass
pw = P.rounded_box("pawl", (0.022, 0.012, 0.026), (bc.x + 0.019, -0.0385, -bc.y - 0.026), 0.004, 1, material=bright)   # top 1.5 mm inside arm B (QA: back-to-back faces)
T.group(pw, "armB")
armB.append(pw)
# return spring between the handles (each half goes with its arm)
pts = []
TURNS, PER = 4, 6
for k in range(TURNS * PER + 1):
    a = 2 * math.pi * k / PER
    zz = (SEAT_TOP - 0.012) * (1 - 2 * k / (TURNS * PER))
    pts.append((sp_c.x + 0.017 * math.cos(a), 0.017 * math.sin(a), zz))
spring = W.tube("spring", pts, 0.0055, around=4, material=steel)
T.group_by(spring, lambda co: "armA" if co.z < 0 else "armB")
ob = W.join("HosePliers", armA + armB + [spring])
print("tris before finish", P.tris(ob))


def paint(Pm, Nm, base, orm, mask):
    """cross slot in each jaw cup (on the face toward the other jaw and down the sides), fine grip texture lines"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    for sz in (1, -1):
        cz = sz * CUP_C.y; face_z = cz - sz * CUP_H / 2
        incup = mask & (np.hypot(x - CUP_C.x, y) < CUP_R + 0.002) & (np.abs(z - cz) < CUP_H / 2 + 0.002)
        slot = incup & (np.abs(x - CUP_C.x) < 0.0095) & ((z - face_z) * sz < 0.026)
        base[slot] = T.hexf("#2A2A2C")
        edge = incup & (np.abs(np.abs(x - CUP_C.x) - 0.0115) < 0.002) & ((z - face_z) * sz < 0.026)
        base[edge] = base[edge] * 0.8
    return base, orm


T.finish(ob, OUT, "HosePliers", paint=paint, smooth=45)
# ---- attachments
cup_r = CUP_C.length
close = math.degrees(math.atan2(CUP_C.y, CUP_C.x) - math.asin((CUP_H / 2 + 0.009) / cup_r))
gr = hdl_pt(0.67)
data = {"tool": "Hose clamp pliers (swivel jaws, ratchet lock)", "units": "stud",
        "space": "mesh local, Roblox axes (+X = toward the jaws, +Y = up in the concept front view, -Z = front face = arm A side); origin = the rivet (pivot)",
        "Grip": {"pos": rb((gr.x, 0, 0)), "axis": [1, 0, 0], "secondary_axis": [0, 0, -1],
                 "note": "between the two red grips (fist around both, they are 0.27 apart at rest). Axis (+X) toward the jaws; SecondaryAxis = front face. Same convention as the Wrench."},
        "Tip": {"pos": rb((CUP_C.x, 0, 0)), "axis": [1, 0, 0],
                "note": "between the two jaw cups = where the hose clamp's ears go (F_HoseClamp_*). Axis = the way the jaws point; the ears are pinched along +-Y (mesh)."},
        "Jaw_A": {"pos": rb((CUP_C.x, 0, CUP_C.y - CUP_H / 2)), "axis": [0, -1, 0], "note": "slot face of the upper cup (arm A), facing the other cup"},
        "Jaw_B": {"pos": rb((CUP_C.x, 0, -CUP_C.y + CUP_H / 2)), "axis": [0, 1, 0]},
        "Jaw_Gap": {"rest": round(2 * (CUP_C.y - CUP_H / 2), 3), "closed": 0.018},
        "Squeeze": {"pivot": [0, 0, 0],
                    "rig_glb": "HosePliers_Rig.glb (nodes HosePliers_ArmA = upper jaw + lower handle + lock bar, HosePliers_ArmB = lower jaw + upper handle + pawl; the spring is split between them; same axes / texture as HosePliers.glb)",
                    "ArmA_axis": rb((0, 1, 0)), "ArmB_axis": rb((0, -1, 0)),
                    "close_deg": round(close, 1),
                    "rule": "arm CFrame = pivot * CFrame.fromAxisAngle(axis, rad(t)) * pivot:Inverse() * rest; t = 0 rest (jaws 0.117 open), close_deg = jaws pinch a clamp's ears (gap 0.018). Positive t closes BOTH the jaws and the handles. Convert pivot / axes with meshLocal like Grip."},
        "size": "1.32 long x 0.39 tall (rest) x 0.10 thick (jaw cups)"}
T.write_json(os.path.join(OUT, "hose_pliers_attachments.json"), data, ob)
T.export_rig(ob, os.path.join(OUT, "HosePliers_Rig.glb"), {"armA": "HosePliers_ArmA", "armB": "HosePliers_ArmB"})
print("ok")
