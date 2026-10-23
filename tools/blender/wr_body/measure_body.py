# Measure the exported sedan body GLBs (wr-3d-body): size vs car_spec, wheel arches, triangles per mesh.
#   blender --background --factory-startup --python tools/blender/wr_body/measure_body.py -- <glb_dir> <out.json>
import bpy, sys, os, json, math
from mathutils import Vector
a = sys.argv[sys.argv.index("--") + 1:]
d, outp = os.path.abspath(a[0]), os.path.abspath(a[1])
bpy.ops.wm.read_factory_settings(use_empty=True)
res = {"meshes": {}}
allv = []
for n in ("shell", "glass", "hood", "bumper_f", "bumper_r", "chassis"):
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.join(d, "sedan_%s.glb" % n))
    obs = [o for o in bpy.context.scene.objects if o not in before and o.type == 'MESH']
    tris = 0; vs = []
    for o in obs:
        me = o.data; tris += sum(len(p.vertices) - 2 for p in me.polygons)
        vs += [o.matrix_world @ v.co for v in me.vertices]
    car = [(v.x, v.z, -v.y) for v in vs]          # blender (glTF import Y-up -> Z-up) -> car x, Y, s
    res["meshes"][n] = dict(tris=tris, x=[round(min(c[0] for c in car), 3), round(max(c[0] for c in car), 3)],
                            Y=[round(min(c[1] for c in car), 3), round(max(c[1] for c in car), 3)],
                            Z=[round(min(c[2] for c in car), 3), round(max(c[2] for c in car), 3)])
    if n != "chassis":
        allv += car
L = max(c[2] for c in allv) - min(c[2] for c in allv)
H = max(c[1] for c in allv)
Wm = max(abs(c[0]) for c in allv) * 2
Wb = max(abs(c[0]) for c in allv if c[1] < 3.2 or c[1] > 4.8) * 2     # below / above the mirror band
# arch centres: shell verts on the arch lip (radius ~1.45-1.5 from the spec centre) -> mean s of the arch top verts
arch = {}
import numpy as np
for ws in (-5.0, 5.0):       # circle fit (s, Y) on the outer arch-lip vertices of shell + bumpers
    pts = np.array([(c[2], c[1]) for c in allv if abs(c[0]) > 3.45 and abs(c[2] - ws) < 1.75 and c[1] > 1.3
                    and 1.45 < math.hypot(c[2] - ws, c[1] - 1.375) < 1.62])
    if len(pts) > 10:
        A_ = np.c_[2 * pts[:, 0], 2 * pts[:, 1], np.ones(len(pts))]
        b_ = (pts ** 2).sum(1)
        cx, cy, k = np.linalg.lstsq(A_, b_, rcond=None)[0]
        arch[ws] = (round(float(cx), 3), round(float(cy), 3), round(float(math.sqrt(k + cx * cx + cy * cy)), 3))
res.update(length=round(L, 3), height=round(H, 3), width_body=round(Wb, 3), width_with_mirrors=round(Wm, 3),
           front=round(min(c[2] for c in allv), 3), rear=round(max(c[2] for c in allv), 3),
           arch_top={str(k): v for k, v in arch.items()},
           wheelbase_from_arches=round(arch[5.0][0] - arch[-5.0][0], 3) if len(arch) == 2 else None,
           tris_total=sum(m["tris"] for m in res["meshes"].values()))
json.dump(res, open(outp, "w"), indent=1)
print(json.dumps({k: v for k, v in res.items() if k != "meshes"}))
for k, v in res["meshes"].items():
    print(k, v)
