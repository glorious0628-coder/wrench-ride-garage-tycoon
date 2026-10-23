# Old camera find, built from clean primitives (pp-3d-make 10-20, after the user said the Hunyuan camera "is not
# smooth"). Measurements from the 6-view concept cells (art/out/redraw/obj_old_camera_6view.png split into
# ComfyUI/input/old_camera_*.png), 224 px = 1 unit: body 448 x 255 px (front), 170 px deep (side), cream above the
# seam at 113 px, lens ring r 108 / glass r 78 / dark centre ~0.5, ring sticks out 48 px + glass dome 30 px, flash disc
# r 90 at 358 px up, mount 90 px wide, button r 39 (object's left = +X), knurled dial r 45 (object's right = -X).
#   blender --background --factory-startup --python tools/blender/build_camera.py -- <out_prefix>
import bpy, sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import proc_lib as P
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
out = argv[0]
MULT = float(argv[1]) if len(argv) > 1 else 1.0   # circle segments x MULT (1 = 1,500-tri budget, 2 = round circles ~3k)


def S(n):
    return max(3, int(round(n * MULT)))


def SC(n):  # the big round parts people look at (lens, flash): round even at x1 (user: "circles look angular")
    return max(3, int(round(n * max(MULT, CIRC))))


CIRC = float(argv[2]) if len(argv) > 2 else 2.0
BODYSEG = int(argv[3]) if len(argv) > 3 else 3   # body corner rounding segments (main 10-20: <= 3,000 tris, round corners)


def BS(n):
    return max(n, int(round(n * (1 + (MULT - 1) * 0.5))))
P.reset()
U = 1 / 224.0
# colour codes measured per part on the concept (tools/blender/part_colours.py + lens rings; user 10-20)
navy = P.mat("navy", "#1A4079", 0.45)
cream = P.mat("cream", "#F3E6D0", 0.5)
reflector = P.mat("reflector", "#F3E6D0", 0.35)
glass = P.mat("lens", "#1D8AFA", 0.06)


BW, BD, BH = 448 * U, 170 * U, 255 * U          # body
SEAM = 113 * U                                     # navy below, cream above
body = P.rounded_box("body", (BW, BD, BH), (0, 0, BH / 2), radius=44 * U, segs=BODYSEG, material=navy)
# a loop exactly on the seam so the colour border is a straight edge of the mesh
import bmesh
bm = bmesh.new(); bm.from_mesh(body.data)
bmesh.ops.bisect_plane(bm, geom=list(bm.verts) + list(bm.edges) + list(bm.faces), plane_co=(0, 0, SEAM), plane_no=(0, 0, 1))
bm.to_mesh(body.data); bm.free()
P.assign_by(body, lambda c, n: cream if c.z > SEAM else navy)

FRONT = BD / 2                                     # body front face (y)
LZ = (523 - 400) * U                               # lens centre height
ring_d = 48 * U
P.lathe_loop("lens_ring", rounded_rect_loop_ := P.rounded_rect_loop(76 * U, 108 * U, -(ring_d + 0.04) / 2, (ring_d + 0.04) / 2, 15 * U, 0, n=3),
             (0, FRONT + ring_d / 2 - 0.02, LZ), axis='Y', segs=SC(30), material=navy)   # even revolved ring: no wavy highlight (2nd v3f)
# glass dome (lathe). Concept lens (user: the 3D one looked "like an eyeball"): bright glass, an inner lens element
# in a deeper but still clearly BLUE tone (not a black pupil) with a light ring round it, and two white glints.
R, Hd = 76 * U, 32 * U   # rim exactly on the barrel's inner wall (no bright gap, no crease)
prof = [(0, 0.80 * Hd), (0.30 * R, 0.84 * Hd), (0.55 * R, 0.90 * Hd), (0.75 * R, 0.76 * Hd), (0.92 * R, 0.42 * Hd), (R, 0.0)]   # centre dips a little (concave lens element)
GY = FRONT + ring_d - 0.06 - 6 * U   # rim sits below the barrel lip
gl = P.lathe("lens_glass", [(0, 0.80 * Hd), (0.18 * R, 0.82 * Hd), (0.36 * R, 0.86 * Hd), (0.55 * R, 0.90 * Hd), (0.68 * R, 0.84 * Hd), (0.80 * R, 0.70 * Hd), (0.90 * R, 0.50 * Hd), (0.97 * R, 0.24 * Hd), (R, 0.0)], (0, GY, LZ), axis='Y', segs=SC(20), material=glass)   # rounder dome (2nd v3e)


# the lens look (inner element, soft light ring, glints, gradient) is PAINTED into the texture in lens_paint() below


FZ = (523 - 165) * U                               # flash disc centre height
FR = 90 * U
FY = 0.0
P.lathe_loop("flash_rim", P.rounded_rect_loop(70 * U, FR, -22 * U, 22 * U, 12 * U, 9 * U, n=3), (0, FY, FZ), axis='Y', segs=SC(22), material=navy)
P.cylinder("flash_back", 78 * U, 12 * U, (0, FY - 16 * U, FZ), axis="Y", segs=S(10), material=navy)  # flush with the rim back, behind the dish
# reflector: shallow cream dish facing the front + round bulb
# reflector = a real concave dish (lathe): rim edge at the front, centre 16 px deeper, bulb in the middle
P.lathe("flash_dish", [(0, -9 * U), (35 * U, -5.5 * U), (58 * U, 1 * U), (71 * U, 8 * U)], (0, FY, FZ), axis='Y', segs=SC(12),
        material=reflector, cap=False, thickness=3 * U)
P.sphere("flash_bulb", 25 * U, (0, FY + 6 * U, FZ), segs=SC(10), rings=SC(5), material=cream)  # back stays inside the back plate
P.rounded_box("flash_mount", (90 * U, 40 * U, 33 * U), (0, FY, 263.5 * U), radius=6 * U, segs=1, material=navy)  # body top -> just under the rim

TOP = BH
# shutter button (object's left = +X)
P.cylinder("btn_stem", 28 * U, 22 * U, (0.64, 0.0, TOP + 9 * U), axis="Z", segs=S(24), material=navy)
P.lathe_cap("btn_cap", 39 * U, -11 * U, 11 * U, 9 * U, (0.64, 0.0, TOP + 28 * U), axis='Z', segs=SC(18), n=4, material=navy)
# knurled dial (object's right = -X): a gear-like ring of 14 bumps
dial = P.lathe_cap("dial", 44 * U, -20 * U, 20 * U, 8 * U, (-0.67, 0.0, TOP + 20 * U), axis='Z', segs=S(54), n=4, material=navy)
for v in dial.data.vertices:
    d = Vector((v.co.x + 0.67, v.co.y, 0)); r = d.length
    if r > 30 * U:
        a = math.atan2(d.y, d.x); k = 1.0 - 0.06 * (0.5 + 0.5 * math.cos(20 * a)) ** 2   # 20 fine round grooves (API v3d: read as a star)
        v.co.x = -0.67 + d.x * k; v.co.y = d.y * k

for o in bpy.context.scene.objects:
    print("PART", o.name, P.tris(o))
ob = P.join_all("trophy_camera")
print("TRIS before finish", P.tris(ob))
import numpy as np


def hexc(h):
    return np.array([int(h[i:i + 2], 16) / 255 for i in (1, 3, 5)], np.float32)


def smooth(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)


def lens_paint(Pm, Nm, base, orm, mask):
    """lens v3d (main 3rd: 'flat sticker'; user earlier: 'too much like an eyeball, the concept is fine'): like the concept -
    bright blue glass at the edge fading SOFTLY (no hard circle) into a deep navy centre, a thin light ring between the
    glass and the inner element, high gloss, two highlights upper right: a curved streak and a small soft oval."""
    dx = Pm[..., 0]; dz = Pm[..., 2] - LZ; r = np.sqrt(dx ** 2 + dz ** 2) / R
    sel = mask & (r < 1.02) & (Pm[..., 1] > GY - 0.01) & (Nm[..., 1] > 0.15)
    # radial colour codes measured on the concept lens (r / R: centre #022567, 0.4 #003284, 0.6 #016DE2,
    # 0.78 bright ring #43BFFE, 0.95 edge #015ACC) with smooth blends between them
    stops = [(0.0, "#022567"), (0.30, "#022567"), (0.45, "#003284"), (0.62, "#016DE2"), (0.78, "#43BFFE"), (0.93, "#015ACC"), (1.05, "#015ACC")]
    col = np.zeros(r.shape + (3,), np.float32)
    for (r0, h0), (r1, h1) in zip(stops[:-1], stops[1:]):
        m_ = (r >= r0) & (r < r1); tt = smooth(r0, r1, r)[..., None]
        col[m_] = (hexc(h0) * (1 - tt) + hexc(h1) * tt)[m_]
    lip = smooth(0.90, 0.98, r)[..., None] * 0.7                                  # dark inner barrel lip
    col = col * (1 - lip) + hexc("#163C74") * lip   # concept barrel code
    ang = np.degrees(np.arctan2(dz, -dx))                                          # 0 = image right, 90 = up
    streak = (np.clip(1 - np.abs(r - 0.78) / 0.07, 0, 1) * smooth(28, 48, ang) * (1 - smooth(78, 98, ang)))[..., None]
    col = col * (1 - 0.9 * streak) + hexc("#F2FAFF") * 0.9 * streak
    ox, oz = -0.52 * R, 0.50 * R                                                   # small oval glint out in the bright glass (not an eye catchlight)
    dd = np.sqrt(((dx - ox) / (0.10 * R)) ** 2 + ((dz - oz) / (0.07 * R)) ** 2)
    g = (1 - smooth(0.6, 1.0, dd))[..., None] * 0.9
    col = col * (1 - g) + hexc("#F6FBFF") * g
    base[sel] = col[sel]
    orm[sel, 1] = 0.04
    return base, orm


P.finish(ob, out, paint=lens_paint, planar_mats=("lens",), weighted=False, smooth_angle=70)   # weighted normals made the ring highlight wavy
