# Review-only assembly of the OTHER helpers' finished parts at their car_spec places (read only: art/3d/wheel, brake,
# muffler, battery, radiator GLBs are imported, moved, and re-exported into OUR work folder for the review renders).
#   blender --background --factory-startup --python tools/blender/wr_body/place_others.py -- <art/3d dir> <out.glb> [flat_tyre.glb]
# (flat_tyre.glb: wreck review - that tyre mesh on the front-left wheel instead of Tire.glb)
import bpy, sys, os, math
from mathutils import Matrix, Vector

a = sys.argv[sys.argv.index("--") + 1:]
ROOT, OUTF = os.path.abspath(a[0]), os.path.abspath(a[1])
FLAT = os.path.abspath(a[2]) if len(a) > 2 else None
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
    for ss in (-5.0, 5.0):
        c = (sx * 3.25, 1.375, ss)
        r = None if sx > 0 else ROT_Y180
        tyre = os.path.relpath(FLAT, ROOT) if (FLAT and sx < 0 and ss < 0) else "wheel/Tire.glb"
        obs += place(tyre, c, r) + place("wheel/Rim.glb", c, r) + place("brake/Disc.glb", c, r)
        obs += place("brake/Hub.glb" if sx > 0 else "brake/Hub_L.glb", c)
        pc = (sx * 3.25, 1.375, ss - 0.5271)
        obs += place("brake/Caliper.glb" if sx > 0 else "brake/Caliper_L.glb", pc)
        obs += place("brake/CaliperBracket.glb" if sx > 0 else "brake/CaliperBracket_L.glb", pc)
obs += place("muffler/Muffler.glb", (0.3, 0.8, 7.6))
obs += place("battery/Battery.glb", (-2.2, 2.35, -5.7), Matrix.Rotation(-math.pi / 2, 4, 'Z'))   # car_spec v0.8: Snap Y -90
obs += place("radiator/Radiator.glb", (0.0, 2.3, -7.5))
for o in sc.objects:
    o.select_set(o in obs)
bpy.ops.export_scene.gltf(filepath=OUTF, export_format='GLB', use_selection=True, export_yup=True)
print("PLACED", len(obs), OUTF)
