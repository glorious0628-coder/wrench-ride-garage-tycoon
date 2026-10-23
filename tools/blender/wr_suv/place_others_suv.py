# Review-only assembly of the OTHER helpers' finished parts at their suv_spec places (wr-3d-suv 2nd pass; read only:
# art/3d/brake, muffler, battery, radiator GLBs are imported, moved and re-exported into OUR work folder for renders).
# Wheels are not here: the SUV review wheels (wheel helper Rim/Tire scaled to 2.98 x 1.15) come from build_suv.py.
#   blender --background --factory-startup --python tools/blender/wr_suv/place_others_suv.py -- <art/3d dir> <out.glb>
import bpy, sys, os, math
from mathutils import Matrix, Vector

a = sys.argv[sys.argv.index("--") + 1:]
ROOT, OUTF = os.path.abspath(a[0]), os.path.abspath(a[1])
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
BL = lambda x, Y, s: Vector((x, -s, Y))
ROT_Y180 = Matrix.Rotation(math.pi, 4, 'Z')      # Roblox Y (up) = Blender Z


def place(rel, off, rot=None):
    p = os.path.join(ROOT, rel)
    if not os.path.exists(p):
        print("missing", p); return []
    before = set(sc.objects)
    bpy.ops.import_scene.gltf(filepath=p)
    new = [o for o in sc.objects if o not in before]
    meshes = [o for o in new if o.type == 'MESH']
    for o in meshes:
        mw = o.matrix_world.copy(); o.parent = None
        o.data = o.data.copy(); o.data.transform(mw)
        if rot is not None:
            o.data.transform(rot)
        o.data.transform(Matrix.Translation(BL(*off))); o.matrix_world = Matrix.Identity(4)
    for o in new:
        if o.type != 'MESH':
            bpy.data.objects.remove(o)
    return meshes


obs = []
for sx in (1, -1):
    for ss in (-4.85, 4.85):                       # suv_spec: wheel centre (+-3.25, 1.49, +-4.85); brake meshes = sedan's
        c = (sx * 3.25, 1.49, ss)
        r = None if sx > 0 else ROT_Y180
        obs += place("brake/Disc.glb", c, r)
        obs += place("brake/Hub.glb" if sx > 0 else "brake/Hub_L.glb", c)
        pc = (sx * 3.25, 1.49, ss - 0.5271)
        obs += place("brake/Caliper.glb" if sx > 0 else "brake/Caliper_L.glb", pc)
        obs += place("brake/CaliperBracket.glb" if sx > 0 else "brake/CaliperBracket_L.glb", pc)
obs += place("muffler/Muffler.glb", (0.3, 1.0, 7.6))
obs += place("battery/Battery.glb", (-2.2, 2.85, -5.55), Matrix.Rotation(-math.pi / 2, 4, 'Z'))   # car_spec v0.8: Snap Y -90
obs += place("radiator/Radiator.glb", (0.0, 2.8, -7.35))
for o in sc.objects:
    o.select_set(o in obs)
bpy.ops.export_scene.gltf(filepath=OUTF, export_format='GLB', use_selection=True, export_yup=True)
print("PLACED", len(obs), OUTF)
