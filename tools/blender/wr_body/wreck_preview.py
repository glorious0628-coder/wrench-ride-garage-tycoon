# Wreck pass, review assembly (wr-3d-body, 10-21): the deliverable body GLBs with their colour / ORM images swapped for
# the wreck preview maps (blue paint under the overlay) -> one GLB per level for the review renders.
#   blender --background --factory-startup --python tools/blender/wr_body/wreck_preview.py -- <art/3d/sedan_body> <level> <out.glb> [bumper_f_glb]
import bpy, sys, os

a = sys.argv[sys.argv.index("--") + 1:]
ROOT, L, OUTF = os.path.abspath(a[0]), a[1], os.path.abspath(a[2])
BF = os.path.abspath(a[3]) if len(a) > 3 else None
DEL = os.path.join(ROOT, "B_concept"); PREV = os.path.join(ROOT, "work", "wreck", "prev")
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
for base in ("sedan_shell", "sedan_hood", "sedan_bumper_f", "sedan_bumper_r", "sedan_glass", "sedan_chassis"):
    src = BF if (base == "sedan_bumper_f" and BF) else os.path.join(DEL, base + ".glb")
    before = set(sc.objects)
    bpy.ops.import_scene.gltf(filepath=src)
    if L == "0":
        continue
    for o in [o for o in sc.objects if o not in before and o.type == 'MESH']:
        for m in o.data.materials:
            for n in m.node_tree.nodes:
                if n.type != 'TEX_IMAGE' or n.image is None:
                    continue
                nm = n.image.name
                pc = os.path.join(PREV, f"{base}_wreck{L}_prevcolor.png"); po = os.path.join(PREV, f"{base}_wreck{L}_orm.png")
                if "_orm" in nm and os.path.exists(po):
                    im = bpy.data.images.load(po); im.colorspace_settings.name = 'Non-Color'; n.image = im
                elif "_orm" not in nm and os.path.exists(pc):
                    n.image = bpy.data.images.load(pc)
for o in sc.objects:
    o.select_set(o.type == 'MESH')
bpy.ops.export_scene.gltf(filepath=OUTF, export_format='GLB', use_selection=True, export_yup=True)
print("PREVIEW", L, OUTF)
