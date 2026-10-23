# 가로등 (prop_street_lamp), built from smooth even-ring parts (pp-3d-props 10-20). Concept: the 6-view
# art/out/field_1020/prop_street_lamp_n1_6view.png (art review + main 3rd OK, main "시작" 18:23), split into 640 px cells.
# Slot memo (v4_3d_slots.md): front = the arm side, slot 1.6 x 11.9 x 3.3 -> the arm points to the FRONT (+Y here,
# the game's -Z). So the concept's front cell (arm to the picture's right) is this model's RIGHT view; arm and head
# lengths from the front / back cells (main memo: the top / bottom cells draw them ~1.4x too long).
# Measured: 580 px tall (y 29..609) = 11.9 studs; pole axis = front x 241 / left x 318.5. Y = front x - 241, Z = 609 - y.
#   blender --background --factory-startup --python tools/blender/build_street_lamp.py -- <out_prefix>
import bpy, sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import proc_lib as P
from props_lib import slab, rod
from tree_lib import tube
from mathutils import Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
out = os.path.abspath(argv[0])
STUD = 11.9 / 580.0
P.reset()
# real materials (colour codes re-measured with part_colours.py at the colour stage)
steel = P.mat("steel", "#A9AEB9", 0.35, 0.3)   # painted light-grey steel, satin
lens = P.mat("lens", "#F6EEA2", 0.2)           # warm yellow lamp glass (the night glow is the game's PointLight)

# base: front x 188..296 / left x 264..374, y 533..609 (Z 0..76): a round foot with soft rounded edges
slab("base", 108, 108, 76, 54, 20, (0, 0, 38), axis='Z', k=6, n=4, material=steel)   # round shoulders, 6 steps (2nd g2: 3 steps read as a 45-degree chamfer)
rod("pole_lo", 27, 70, 215, segs=22, material=steel)                       # front x 215..269, y 400..533
# middle block: front x 202..282 / left x 278..360, y 289..398 (Z 211..320), a rounded square box
slab("block", 81, 81, 109, 20, 20, (0, 0, 265.5), axis='Z', k=4, n=4, material=steel)   # round shoulders; corner = edge radius -> round (spherical) corners, no mitre at the shoulder (2nd g2, g5)
tube("pole_hi", [(0, 0, 315, 26), (0, 0, 400, 26), (0, 0, 470, 26)], n=1, around=20, cap_end='dome', dome_rings=5,
     material=steel)   # front x 215..267, y 120..289; a round shoulder into the neck (2nd g2: no ring in the concept)
# neck + arm: r 19.5 neck (front x 222..261, y 89..113) bending into the arm (y 47..77, centre Z 547) towards the head
tube("arm", [(0, 0, 480, 19.5), (0, 0, 512, 19.5), (0, 5, 532, 18.5), (0, 19, 543, 17.5), (0, 40, 547, 17),
             (0, 70, 548, 17), (0, 128, 552, 16)], n=2, around=16, cap_end='dome', material=steel)
# head: a pill (front x 323..451 -> Y 82..210, left x 279..359 -> 80 wide), dome top y 29 (Z 580), 45 deep
slab("head", 80, 128, 45, 40, 22, (0, 146, 557.5), axis='Z', k=7, n=4, material=steel)   # fully rounded dome (g1 rad 18 left a flat top)
# lens underneath: front x 336..443 / left 290..347, y 70..95 (Z 514..539)
slab("lens", 68, 116, 30, 34, 2, (0, 146, 529), axis='Z', k=7, n=4, rad_back=15, material=lens)   # round lower corners (2nd g7: chamfer)   # the head's underside IS the lens: a big yellow body bulging below the grey rim to the concept's lower line (front y 95 -> Z 514); 2nd g6: hidden, 3 px

for o in bpy.context.scene.objects:
    print("PART", o.name, P.tris(o))
ob = P.join_all("prop_street_lamp")
ob.data.transform(Matrix.Diagonal((STUD, STUD, STUD, 1)))
print("TRIS before finish", P.tris(ob))
P.finish(ob, out, smooth_angle=40, weighted=False, pivot_bottom=False)   # origin = foot centre (pole axis), not bbox
