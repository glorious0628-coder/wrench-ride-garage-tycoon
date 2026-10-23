# QA review sheets (random colour per island = detached / overlapping pieces show up) for GLBs, wr 3D helper 10-22.
#   blender -b --factory-startup -P tv2_qa_shots.py -- <out_dir> <a.glb> [b.glb ...]
# Writes <out_dir>/<name>_qa_random.png (front / right / top / 3/4, one colour per island) and <name>_qa_material.png.
import bpy, sys, os
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, ".claude", "skills", "blender-asset-qa", "scripts"))
import review_shots  # noqa: E402
import bmesh  # noqa: E402

a = sys.argv[sys.argv.index("--") + 1:]
out = os.path.abspath(a[0]); os.makedirs(out, exist_ok=True)
for f in a[1:]:
    name = os.path.splitext(os.path.basename(f))[0]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=os.path.abspath(f))
    for ob in bpy.context.scene.objects:
        if ob.type == "MESH" and ob.data.users == 1:
            bm = bmesh.new(); bm.from_mesh(ob.data); bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5); bm.to_mesh(ob.data); bm.free()
    for mode in ("random", "material"):
        r = review_shots.run(objects=None, out=os.path.join(out, f"{name}_qa_{mode}.png"), mode=mode, res=512)
        print("shot", name, mode, r["sheet"])
