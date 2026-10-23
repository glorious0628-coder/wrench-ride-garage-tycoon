# Trim (clip) removal tool (wr 3D helper 10-22, REDONE the same day after the main review: the first version was a fat
# tapered body + eye-like hole + split tail = read as a fish). Now what the real ones are
# (notes/research/ref_tools_v2/trim_01_bing.jpg, ref_tools_firstbatch 3): a FLAT, WIDE nylon plate - flat-oval handle
# section, widening toward the front while it thins into a wedge blade, V-notch fork on the end, one gentle bend near the
# blade; no ribs (the old ribs read as gills), no eye hole. Casual = rounded edges and a little extra thickness only.
# Game: 1.15 stud long (like the 1.2 wrench), handle 0.164 wide x 0.056 thick, blade 0.204 wide x 0.018 thick at the tips.
# Fit (kept from v1): prong tip centres 0.154 apart, V notch 0.033 wide where the clip stem (0.03) sits, notch 0.17 deep,
# clip head 0.1 fits the mouth (0.104).
# Build frame: length along X (fork at +X), plan in the XZ plane (width = Z), thickness = Y (flat face +Y).
# Origin = middle of the length.   blender -b --factory-startup --python build_trim_tool.py -- <out_dir> [palette.json]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tv2_lib as T
from tv2_lib import W, P, Vector, Matrix, np, rb

OUT, PAL = T.args()
C = lambda n, d: PAL.get(n, d)
BEND = math.radians(-8)            # blade bends toward -Y (like the concept side views)
HT = 0.028                         # half thickness of the handle (0.056)
X_TIP = 0.575
KNEE = -0.04                         # where the wedge starts (cut rows there + at the bend)

P.reset()
orange = P.mat("nylon", C("nylon", "#EE6418"), 0.55, 0.0)

# ---- plan outline (X, Z), CCW: back end arc -> lower edge -> lower tine -> V notch -> upper tine -> upper edge
cx, r = -0.493, 0.082
back = [(cx + r * math.cos(math.radians(a)), r * math.sin(math.radians(a))) for a in range(90, 271, 15)]
edge_lo = [(0.33, -0.102)]      # one straight widening line from the back arc: no kink / near-collinear points (they make sliver or folded cap triangles)
tine_lo = [(X_TIP, -0.102), (X_TIP, -0.052)]
notch_lo = [(0.50, -0.037), (0.43, -0.0165), (0.412, -0.010)]
notch_up = [(0.412, 0.010), (0.43, 0.0165), (0.50, 0.037)]
tine_up = [(X_TIP, 0.052), (X_TIP, 0.102)]
edge_up = [(0.33, 0.102)]
pts = back + edge_lo + tine_lo + notch_lo + notch_up + tine_up + edge_up
# corner radius at the tine tips must be >= the cap inset (0.018) or the inset cap outline folds over itself (= overlapping
# cap triangles, QA 'z-fighting'); other points keep their own shape
RAD = [0.02 if abs(p[0] - X_TIP) < 1e-6 else 0.0 for p in pts]
pts = W.round_corners(pts, RAD, 3)
pts = W._ccw(pts)
FXZ = W.frame((0, 0, 0), (1, 0, 0), (0, 0, 1), (0, -1, 0))     # local (x, y) = (X, Z), local z = -Y
blade = T.slab_ear("trim", pts, -HT, HT, 0.018, 3, FXZ, material=orange)
ob = W.join("TrimTool", [blade])
# cut rows across the long cap triangles where the plate changes direction (wedge knee, bend start / end), so the flat faces
# bend there instead of shading as streaks across one big triangle
bm = bmesh.new(); bm.from_mesh(ob.data)
for xc in (KNEE, 0.3065, 0.353, 0.40):
    bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], dist=1e-6, plane_co=(xc, 0, 0), plane_no=(1, 0, 0))
bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0008)      # the cuts leave 0.0002-wide slivers (QA 'back-to-back')
bmesh.ops.dissolve_degenerate(bm, dist=0.0008, edges=bm.edges[:])
bm.to_mesh(ob.data); bm.free()


def thick(x):
    """thickness factor: full to x = -0.05, then a LINEAR wedge down to 0.32 at the tips (0.056 -> 0.018); linear keeps the two
    big flat faces planar (a curved taper makes the sparse cap triangles show as streaks)"""
    return 1.0 - 0.68 * min(max((x - KNEE) / (X_TIP - KNEE), 0.0), 1.0)


for v in ob.data.vertices:
    v.co.y *= thick(v.co.x)
# ---- bend the blade end out of the plane (smooth over x 0.31 .. 0.40)
XB0, XB1 = 0.3065, 0.40


def bend_pt(x, y):
    if x <= XB0:
        return x, y
    s = min(1.0, (x - XB0) / (XB1 - XB0))
    th = BEND * s * s * (3 - 2 * s) if x < XB1 else BEND
    dx = x - XB0
    return XB0 + dx * math.cos(th) - y * math.sin(th), dx * math.sin(th) + y * math.cos(th)


for v in ob.data.vertices:
    v.co.x, v.co.y = bend_pt(v.co.x, v.co.y)
print("tris before finish", P.tris(ob))
T.finish(ob, OUT, "TrimTool")
# ---- attachments: the clip stem sits in the V notch where it is ~0.03 wide
tx = 0.43
bx, by = bend_pt(tx, 0.0)
fwd = Vector((math.cos(BEND), math.sin(BEND), 0))
lift = Vector((-math.sin(BEND), math.cos(BEND), 0))
gx = -0.31
tipx, tipy = bend_pt(X_TIP, 0.0)
data = {"tool": "Trim / clip removal tool (flat nylon pry with V-notch fork)", "units": "stud",
        "space": "mesh local, Roblox axes (+X = toward the fork, +Y = up in the concept front view (plate width), -Z = the flat face (concept front face)); origin = middle of the length",
        "Grip": {"pos": rb((gx, 0, 0)), "axis": [1, 0, 0], "secondary_axis": [0, 0, -1],
                 "note": "middle of the flat handle. Axis (+X) toward the fork; SecondaryAxis = flat face. Same convention as the Wrench."},
        "Tip": {"pos": rb((bx, by, 0.0)), "axis": T.rnd(rb(tuple(fwd))), "lift": T.rnd(rb(tuple(-lift))),
                "note": "where the clip's stem sits in the V notch (0.033 wide there; notch bottom 0.02 further in). Axis = the way the fork slides UNDER the clip head (perpendicular to the clip's own axis); lift = the face that pushes the clip head out: align lift with the fastener's pull-out axis."},
        "Fork_Tips": {"pos": rb((tipx, tipy, 0.0)), "spread": 0.154, "mouth": 0.104,
                      "note": "middle between the two prong tips; spread = distance between the prong tip centres, mouth = gap between the prongs at the tips (clip head 0.1 fits)"},
        "Bend_deg": round(math.degrees(BEND), 1),
        "size": "1.15 long x 0.204 wide (blade) x 0.056 thick (handle) -> 0.018 at the prong tips"}
T.write_json(os.path.join(OUT, "trim_tool_attachments.json"), data, ob)
print("ok")
