# 벤치 (prop_bench), built from smooth parts (pp-3d-props 10-20). Concept: the 6-view
# art/out/field_1020/prop_bench_n1_6view_r2.png (art review + main 3rd OK, main "시작" 18:23). The sheet's views touch,
# so the cells were cut by hand (art/3d/field/bench/work/c_*.png, 640 px).
# NOTE this sheet draws the front cell 223 px tall and the left cell 249 px tall -> each cell is measured in its own
# scale (both = the bench's full height H); its left cell shows the front on the picture's RIGHT (Y = left x - 320).
# H = 3.1 studs; width / depth follow the concept (main 19:14: the slot becomes ~6.3 x 3.1 x 2.8).
# g5 (2nd g4 "다시"): each side frame = blocks like the concept - a square back post (vertical leg, the backrest part
# leaning 5 degrees back), a straight flat arm bar and a front leg block (rounded outer corner); the back slats sit
# against the posts with their ends in them; the seat slats are pill bars with rounded ends; a closed rounded divider.
# Front = +Y (exports as the game's -Z), up +Z, symmetric in X.
#   blender --background --factory-startup --python tools/blender/build_bench.py -- <out_prefix>
import bpy, sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import proc_lib as P
from props_lib import slab
from tree_lib import tube
from mathutils import Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
out = os.path.abspath(argv[0])
H = 3.1
SF, SL = H / 223.0, H / 249.0          # studs per px: front cell (ground y 431, centre x 319.5), left cell (ground 444)
P.reset()
frame = P.mat("frame", "#4B5058", 0.4)     # dark grey painted steel frame
wood = P.mat("wood", "#C66A2C", 0.45)      # orange-brown painted wooden slats, satin


def fx(x):
    return (319.5 - x) * SF


def lz(y):
    return (444 - y) * SL


def ly(x):
    return (x - 320) * SL


TILT = math.radians(5)
SEAT_Z = lz(345)                 # where the post starts to lean back
PY0 = ly(238)                    # post centre (Y) at the floor, side cell x 215..262
PR = 0.28                        # post half size (front cell 40 px, side cell 45 px)


def post_y(z):
    return PY0 - max(0.0, z - SEAT_Z) * math.tan(TILT)


def tilt_about(o, z0, y0):
    """lean a part 5 degrees back about the line (y0, z0) along X"""
    o.data.transform(Matrix.Translation((0, -y0, -z0)))
    o.data.transform(Matrix.Rotation(TILT, 4, 'X'))
    o.data.transform(Matrix.Translation((0, y0, z0)))


ZTOP = lz(195)
for sx in (1, -1):
    xp, xa = sx * fx(147), sx * fx(114)
    # back post: vertical up to the seat, then leaning back; rounded-square tube, flat foot, round dome top
    tube("post", [(xp, PY0, 0.0, PR), (xp, PY0, SEAT_Z, PR), (xp, post_y(ZTOP - PR), ZTOP - PR, PR)], n=3, around=16,
         expo=3.2, cap_end='dome', dome_rings=3, material=frame)
    # arm bar: straight (2nd g4: bowed from above), 0.58 wide (front cell x 93..135) x 0.29 thick (side y 277..300),
    # top at side y 277 (2nd g4: 4 % lower), from the post to the front leg's front face
    y0, y1 = post_y(lz(288)), ly(430) - 0.02
    # (g5 0.29 thick: the side cell's arm block is y 277..322 -> 0.4 thick)
    at = lz(277) - lz(322)
    slab("arm", 0.58, at, y1 - y0, 0.18, 0.14, (xa, (y0 + y1) / 2, lz(277) - at / 2), axis='Y', k=3, n=3,
         material=frame)
    # front leg: side x 383..430 (0.585 deep), floor .. arm top, big round outer top corner, small at the floor
    # its top stays 0.08 inside the arm (g7: the coplanar tops showed a flat tile on the arm's front end)
    lh = lz(277) - 0.08
    slab("leg", 0.56, 0.565, lh, 0.2, 0.12, (xa, ly(406.5) - 0.01, lh / 2), axis='Z', k=3, n=2, rad_back=0.06, n_back=1,
         material=frame)
# back slats (front cell y 215..258 and 266..303): against the posts' front faces, ends inside the posts (X +-2.27 vs
# post 2.12..2.68), leaning back with them (2nd g4: floating in front of the posts)
for (y0, y1) in ((215, 258), (266, 303)):
    zc = (431 - (y0 + y1) / 2) * SF
    yc = post_y(zc) + PR + 0.18 - 0.1          # slat back 0.1 inside the post's front face
    o = slab("back", 2 * fx(163), (y1 - y0) * SF, 0.36, (y1 - y0) * SF / 2, 0.14, (0, yc, zc), k=3, n=2, material=wood)
    tilt_about(o, zc, yc)
# seat: two pill bars side by side in depth (side x 276..329 / 331..384, y 322..370), full width (front x 125..512),
# rounded ends (2nd g4: cut flat)
for (x0, x1) in ((276, 331), (329, 384)):   # the two bars touch (g7: the divider's hidden foot showed through the gap from below)
    # height: the front cell draws the seat Z 0.78..1.57, the side cell 0.92..1.52 -> the middle, 0.85..1.55
    d, t = (x1 - x0) * SL, 1.55 - 0.85
    slab("seat", d, t, 2 * fx(125), min(d, t) * 0.3, 0.2, (0, ly((x0 + x1) / 2), 1.2), axis='X',
         k=3, n=2, material=wood)      # rounded squares in section, like the side cell (g5 circles)
# divider: a closed rounded block on the seat (front cell x 302..338, top y 275), long in depth (top cell)
zt = (431 - 275) * SF
dv = slab("divider", 2 * fx(302), 0.85, zt - 1.52, 0.18, 0.2, (0, ly(330), (zt + 1.52) / 2), axis='Z',
     k=3, n=2, rad_back=0.05, n_back=1, material=frame)

for o in bpy.context.scene.objects:
    print("PART", o.name, P.tris(o))
ob = P.join_all("prop_bench")
print("TRIS before finish", P.tris(ob))
P.finish(ob, out, smooth_angle=40, weighted=False, pivot_bottom=True, recalc_normals=False)   # parts face out already
