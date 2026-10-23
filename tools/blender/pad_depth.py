# Fix the depth of a multi-view Hunyuan shape part by part (pp-3d-props 10-20). Hunyuan follows the concept's front /
# back outline closely but squeezes depth (the pine's pads all sat in one flat plane, side view -34 %). For each part
# (a box in the FRONT view: X and Z range), its vertices are moved in Y so the part's depth centre and depth match the
# concept's side cell; the move fades out over `fade` outside the box so branches bend smoothly into it.
#   blender --background --factory-startup --python tools/blender/pad_depth.py -- <in.glb> <out.glb> <parts.json>
# parts.json: {"unit": studs per concept px, "x0": concept front x of the origin, "ground": concept front y of Z=0,
#   "fade": px, "parts": [{"name", "x": [xa, xb] (front cell px), "z": [ya, yb] (front cell px rows),
#                          "cy": target depth centre (px, + = front), "d": target depth (px)}]}
import bpy, sys, os, json
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
src, dst, cfg = os.path.abspath(argv[0]), os.path.abspath(argv[1]), json.load(open(argv[2]))
U = cfg["unit"]; FADE = cfg.get("fade", 20) * U
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
ob = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
bpy.context.view_layer.objects.active = ob; ob.select_set(True)
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
me = ob.data
co = [v.co.copy() for v in me.vertices]
dy = [0.0] * len(co); wsum = [0.0] * len(co)
for p in cfg["parts"]:
    # front cell px -> build coords: X = (x0 - x) * U (image left = +X), Z = (ground - y) * U
    xa, xb = sorted(((cfg["x0"] - p["x"][0]) * U, (cfg["x0"] - p["x"][1]) * U))
    za, zb = sorted(((cfg["ground"] - p["z"][0]) * U, (cfg["ground"] - p["z"][1]) * U))
    inside = [c for c in co if xa <= c.x <= xb and za <= c.z <= zb]
    ys = sorted(c.y for c in inside)
    lo, hi = ys[int(len(ys) * 0.01)], ys[int(len(ys) * 0.99)]
    cur_c, cur_d = (lo + hi) / 2, max(hi - lo, 1e-4)
    tgt_c, tgt_d = p["cy"] * U, p["d"] * U
    k = tgt_d / cur_d
    print("PART", p["name"], "now centre %.2f depth %.2f -> %.2f / %.2f (x%.2f)" % (cur_c, cur_d, tgt_c, tgt_d, k))
    for i, c in enumerate(co):
        ex = max(xa - c.x, 0, c.x - xb); ez = max(za - c.z, 0, c.z - zb)
        e = (ex * ex + ez * ez) ** 0.5
        if e >= FADE:
            continue
        w = 1.0 if e == 0 else 0.5 * (1 + __import__("math").cos(3.14159265 * e / FADE))
        dy[i] += w * (tgt_c + (c.y - cur_c) * k - c.y); wsum[i] += w
for i, v in enumerate(me.vertices):
    if wsum[i] > 1:
        dy[i] /= wsum[i]
    v.co.y = co[i].y + dy[i]
me.update()
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', use_selection=False)
print("EXPORTED", dst, "dims", [round(d, 3) for d in ob.dimensions])
