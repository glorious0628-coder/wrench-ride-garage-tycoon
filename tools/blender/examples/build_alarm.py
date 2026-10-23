# Angry alarm clock find, built from clean primitives (pp-3d-make 10-20, same way as build_camera.py after the user
# found the Hunyuan versions "not smooth"). Measured on the 6-view concept cells (224 px = 1 unit, front cell:
# body circle centre (302, 325) r 205, white face r 145, bells r 78 at x 167 / 440 centred y 136 tilted outward,
# hammer bar 102 x 40 at y 91, feet r 36 at x 173 / 428, body 160 deep). Image-left in the front view = Blender +X.
# The face (angry brows = clock hands, eyes, mouth) is painted per texel straight from the concept front label map:
# the face is flat and built to the concept's size, so the painting lands exactly.
#   blender --background --factory-startup --python tools/blender/build_alarm.py -- <out_prefix> <front_lab.png> [mult]
import bpy, sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import proc_lib as P
import numpy as np
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
out, labp = argv[0], argv[1]
MULT = float(argv[2]) if len(argv) > 2 else 1.0


def S(n):
    return max(3, int(round(n * MULT)))


P.reset()
U = 1 / 224.0
# colour codes measured per part on the concept (tools/blender/part_colours.py; user 10-20: use the concept's codes)
red = P.mat("red", "#FB2727", 0.35)
yellow = P.mat("yellow", "#FDD524", 0.35)   # concept bells, darker 20-45 % band (main 3rd: renders lemon)
face = P.mat("face", "#F2ECEA", 0.55)
CX, BZ = 302, 537                      # front-cell x of the centre line, y of the ground


def X(px):
    return (CX - px) * U


def Z(py):
    return (BZ - py) * U


BR, BCZ = 205 * U, Z(325)
# body: lathe around the front axis with a softly bulging side wall and round rims (GPT alarm_proc_r1: "slab-like")
P.lathe("body", [(0, -90 * U), (150 * U, -89 * U), (172 * U, -85 * U), (189 * U, -76 * U), (200 * U, -62 * U), (207 * U, -42 * U), (209 * U, -14 * U),
                 (207 * U, 24 * U), (200 * U, 56 * U), (150 * U, 64 * U)], (0, 0, BCZ), axis='Y', segs=S(38), material=red)
FRONT = 86 * U
# bezel: a closed round ring (torus-like) whose outer side melts into the body - no flat plate / step (grey r1)
P.lathe_loop("bezel", [(150 * U, 2 * U), (155 * U, 17 * U), (166 * U, 27 * U), (182 * U, 29 * U), (198 * U, 21 * U),   # thinner rim like the concept (main 3rd v5b)
                       (206 * U, 4 * U), (201 * U, -16 * U)], (0, FRONT - 14 * U, BCZ), axis='Y', segs=S(42),
             material=red)
FR = 155 * U
FY = FRONT
DOME = [(0, 14 * U), (0.5 * FR, 12 * U), (0.85 * FR, 6 * U), (FR, 0)]
P.lathe("face", DOME, (0, FY, BCZ), axis='Y', segs=S(50), material=face)   # edge hidden under the bezel


def dome_h(rr):
    pts = [(p_[0], p_[1]) for p_ in DOME]
    for (r0, h0), (r1, h1) in zip(pts[:-1], pts[1:]):
        if rr <= r1:
            return h0 + (h1 - h0) * (rr - r0) / max(r1 - r0, 1e-9)
    return 0.0


import json, bmesh
FEAT = json.load(open(os.path.join(os.path.dirname(out), "face_features.json")))
black = P.mat("black", "#353237", 0.4)
sclera = P.mat("sclera", "#F2ECEA", 0.3)
# raised clock-hand brows and frown: clean swept strokes measured on the concept (face_clean.json: hand tips and
# widths, mouth circle) - the earlier traced outlines were bumpy (user 10-20)
CLEAN = json.load(open(os.path.join(os.path.dirname(os.path.abspath(out)), "face_clean.json")))


def on_face(px, py, lift):
    x, z = X(px), Z(py)
    return (x, FY + dome_h(((x) ** 2 + (z - BCZ) ** 2) ** 0.5) + lift, z)


HUBPX = (300, 317)
for side in ("L", "R"):
    tx, ty = CLEAN[side]["tip"]
    tx, ty = HUBPX[0] + (tx - HUBPX[0]) * 0.92, HUBPX[1] + (ty - HUBPX[1]) * 0.92   # a bit shorter (main 3rd)
    n = 10
    pts = [on_face(HUBPX[0] + (tx - HUBPX[0]) * k / (n - 1), HUBPX[1] + (ty - HUBPX[1]) * k / (n - 1), 15 * U) for k in range(n)]
    hw = [(11 + (15.5 - 11) * (k / (n - 1)) ** 1.2) * U for k in range(n)]      # thicker (main 3rd): narrow at the hub, wide outer end
    P.sweep("hand" + side, pts, hw, [11 * U] * n, around=8, sink=4 * U, material=black)
m = CLEAN["mouth"]; xc, yc, R_ = m["xc"], m["yc"], m["R"]
a0 = math.acos(max(-1, min(1, (m["x0"] + 6 - xc) / R_))); a1 = math.acos(max(-1, min(1, (m["x1"] - 6 - xc) / R_)))
n = 16
mpts = []; mw = []
for k in range(n):
    ang = a0 + (a1 - a0) * k / (n - 1)
    mpts.append(on_face(xc + R_ * math.cos(ang), yc - R_ * math.sin(ang), 8 * U))
    u_ = abs(2 * k / (n - 1) - 1)
    mw.append((19.0 - 8.0 * u_ ** 2) * U)   # +20 % (API v3: thin at 64 px)                                     # thick middle, thinner ends
P.sweep("mouth", mpts, mw, [9 * U] * n, around=8, sink=10 * U, material=black)   # bottom buried in the face
# hub: the round knob where the two hands meet (the outline merged it into the V)
HX, HZ = X(300), Z(317)
P.sphere("hub", 24 * U, (HX, FY + dome_h(abs(HZ - BCZ)) + 18 * U, HZ), segs=S(20), rings=10, material=black, scale=(1, 0.55, 1))   # hub: round (2nd v4)
# eyes: a low white eyeball dome under each painted iris
EYES = []
for e in FEAT["eyes"]:
    ex, ez, er = X(e["cx"]), Z(e["cy"]), e["r"] * U
    rs = er * 2.15   # bigger eye whites (main 3rd)
    rr = (ex ** 2 + (ez - BCZ) ** 2) ** 0.5
    ey = FY + dome_h(rr) - 3 * U
    P.lathe("eye", [(0, 14 * U), (0.45 * rs, 12.5 * U), (0.8 * rs, 8 * U), (rs, 0)], (ex, ey, ez), axis='Y', segs=S(28), material=sclera)  # bulging (grey r1)
    EYES.append((ex, ez, er, rs, ey))
    # one clean dark rim round the eyeball (2nd review v2: painted outline looked like two blurry grey rings)
# bells: yellow domes tilted outward, small knob on top, red post down to the body
for side in (1, -1):
    # 2nd review: bells sat half inside the rim -> on a short red post, clear of the body, tilted outward
    ang = math.radians(38)
    dirv = Vector((side * math.sin(ang), 0, math.cos(ang)))
    rim = Vector((0, -6 * U, BCZ)) + dirv * (BR + 4 * U)   # close to the body like the concept, small visible post
    tilt = side * math.radians(28)   # less splayed (main 3rd)
    # puffy round dome with a soft rolled lip (grey r1: "lamp-shade with a hard lip")
    # ~25 % smaller, deeper dome like the concept (main 3rd v5b: bells big and flat)
    bell = P.lathe("bell", [(0, 86 * U), (36 * U, 82 * U), (58 * U, 72 * U), (74 * U, 57 * U), (82 * U, 40 * U),
                            (86 * U, 24 * U), (88 * U, 11 * U), (88 * U, 5 * U), (87 * U, 1 * U), (83 * U, -2 * U), (77 * U, -3.5 * U), (70 * U, -4 * U)],
                   (0, 0, 0), axis='Z', segs=S(22), material=yellow)
    knob = P.sphere("knob", 21 * U, (0, 0, 95 * U), segs=S(12), rings=6, material=yellow)   # bigger knob
    for o in (bell, knob):
        o.data.transform(Matrix.Rotation(tilt, 4, 'Y'))
        o.data.transform(Matrix.Translation(rim))
    plen = 60 * U
    post = P.cylinder("post", 12 * U, plen, (0, 0, 0), axis='Z', segs=S(10), material=red)
    post.data.transform(Matrix.Translation((0, 0, -plen / 2 + 2 * U)))   # post end sits deep inside the body (no z-fight)
    post.data.transform(Matrix.Rotation(side * ang, 4, 'Y'))
    post.data.transform(Matrix.Translation(rim))
# hammer: yellow T bar on a short stem
P.rounded_box("hammer_bar", (102 * U, 44 * U, 40 * U), (0, 0, Z(86)), radius=18 * U, segs=4, material=yellow)
P.cylinder("hammer_stem", 16 * U, 46 * U, (0, 0, Z(125)), axis='Z', segs=S(14), material=yellow)
# feet: soft red balls
for fx in (173, 428):
    P.sphere("foot", 36 * U, (X(fx), 0, 34 * U), segs=S(13), rings=6, material=red, scale=(1.0, 1.0, 0.95))

for o in bpy.context.scene.objects:
    print("PART", o.name, P.tris(o))
P.nocull(*[o for o in bpy.context.scene.objects if o.name.split(".")[0] in ("hammer_stem", "post", "face", "eye", "handL", "handR", "mouth")])   # closed shells: no see-through edge (2nd v3)
ob = P.join_all("trophy_alarm")
print("TRIS before finish", P.tris(ob))

# ---- face paint from the concept front label map (0 red 1 yellow 2 face 3 black 4 brown, 255 bg)
im = bpy.data.images.load(labp); im.colorspace_settings.name = 'Non-Color'
W_, H_ = im.size
a = np.empty(W_ * H_ * 4, np.float32); im.pixels.foreach_get(a)
LAB = np.round(a.reshape(H_, W_, 4)[::-1, :, 0] * 255).astype(int)
COL = {2: (0xF4, 0xF1, 0xEC), 3: (0x2B, 0x2A, 0x2E), 4: (0x4E, 0x2C, 0x1A)}
ROUGH = {2: 0.5, 3: 0.4, 4: 0.2}


def face_paint(Pm, Nm, base, orm, mask):
    for ex, ez, er, rs, ey in EYES:
        d = np.sqrt((Pm[..., 0] - ex) ** 2 + (Pm[..., 2] - ez) ** 2)
        # only the eyeball itself: not the brow-hands lying over it (they sit higher)
        sel = mask & (d < rs * 1.02) & (Pm[..., 1] > ey - 0.004) & (Pm[..., 1] < ey + 14.5 * U) & (Nm[..., 1] > 0.2)
        # clean circles (the concept's iris outline is ragged after colour matching): iris, darker pupil, a big glint
        # upper-left and a small one below it (image-left = +X)
        col = np.zeros(base.shape[:2] + (3,), np.float32); col[:] = np.array((0xF2, 0xEC, 0xEA), np.float32) / 255
        def disc(cx_, cz_, r_):
            dd = np.sqrt((Pm[..., 0] - cx_) ** 2 + (Pm[..., 2] - cz_) ** 2)
            return np.clip((r_ - dd) / (0.06 * er) + 0.5, 0, 1)[..., None]       # 1 inside, soft 1-texel edge
        for (cx_, cz_, r_, hexv) in ((ex, ez, er * 1.25, (0x3A, 0x22, 0x16)), (ex, ez, er * 0.75, (0x17, 0x0F, 0x0B)),
                                     (ex + 0.32 * er, ez + 0.30 * er, er * 0.30, (0xFA, 0xFA, 0xF8)),
                                     (ex + 0.36 * er, ez - 0.26 * er, er * 0.13, (0xFA, 0xFA, 0xF8))):
            m_ = disc(cx_, cz_, r_); col = col * (1 - m_) + np.array(hexv, np.float32) / 255 * m_
        # 2nd v6: whites got lost in the white face -> ONE clean thin dark-grey rim + a soft lid shadow on the inner top
        dz_ = (Pm[..., 2] - ez) / rs
        lid = (np.clip((dz_ - 0.25) / 0.6, 0, 1) * np.clip(1 - d / rs, 0, 1) ** 0.3 * 0.18)[..., None]
        white_ = (d < rs * 0.93)[..., None] & ~(col.sum(-1, keepdims=True) < 2.0)
        col = np.where(white_, col * (1 - lid) + np.array((0x8A, 0x84, 0x88), np.float32) / 255 * lid, col)
        rim_ = np.clip(1 - np.abs(d - rs * 0.965) / (rs * 0.035), 0, 1)[..., None]
        col = col * (1 - rim_) + np.array((0x4A, 0x44, 0x48), np.float32) / 255 * rim_
        base[sel] = col[sel]; orm[sel, 1] = 0.25
    return base, orm


# no global decimate (it wrecked the flat parts in a 10-20 test); weighted normals off (they crumpled the bells)
P.finish(ob, out, paint=face_paint, weighted=False, smooth_angle=80, max_tris=int(os.environ.get("MAXTRIS", "0")), tex=2048)
