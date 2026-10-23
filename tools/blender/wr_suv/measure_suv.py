# Measure the exported SUV body GLBs (wr-3d-suv, copied from wr_body/measure_body.py): size vs suv_spec, wheel arches,
# triangles per mesh.
#   blender --background --factory-startup --python tools/blender/wr_suv/measure_suv.py -- <glb_dir> <out.json>
import bpy, sys, os, json, math
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import suv_shape as BS
a = sys.argv[sys.argv.index("--") + 1:]
d, outp = os.path.abspath(a[0]), os.path.abspath(a[1])
bpy.ops.wm.read_factory_settings(use_empty=True)
res = {"meshes": {}}
allv = []
shell = []
for n in ("shell", "glass", "hood", "bumper_f", "bumper_r", "chassis"):
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.join(d, "suv_%s.glb" % n))
    obs = [o for o in bpy.context.scene.objects if o not in before and o.type == 'MESH']
    tris = 0; vs = []
    for o in obs:
        me = o.data; tris += sum(len(p.vertices) - 2 for p in me.polygons)
        vs += [o.matrix_world @ v.co for v in me.vertices]
    car = [(v.x, v.z, -v.y) for v in vs]
    res["meshes"][n] = dict(tris=tris, x=[round(min(c[0] for c in car), 3), round(max(c[0] for c in car), 3)],
                            Y=[round(min(c[1] for c in car), 3), round(max(c[1] for c in car), 3)],
                            Z=[round(min(c[2] for c in car), 3), round(max(c[2] for c in car), 3)])
    if n != "chassis":
        allv += car
    if n in ("shell", "bumper_f", "bumper_r"):
        shell += car
L = max(c[2] for c in allv) - min(c[2] for c in allv)
H = max(c[1] for c in allv)
Wm = max(abs(c[0]) for c in allv) * 2
Wb = max(abs(c[0]) for c in allv if c[1] < 4.0) * 2          # below the mirrors (cladding / body side)
# roof height without the rails: shell top at |x| < 1.5 (rails at x +-1.98)
Hroof = max(c[1] for c in shell if abs(c[0]) < 1.5 and 0.0 < c[2] < 4.0 and c[1] < 6.5)   # mid roof (no antenna)
# wheel arch openings: top of the opening (lowest lip vertex over the axle) and the s centre of its flat top
arch = {}
for ws in (-4.85, 4.85):
    pts = np.array([(c[2], c[1]) for c in shell if abs(c[0]) > 3.3 and abs(c[2] - ws) < 0.5 and 2.8 < c[1] < 3.4])
    if len(pts):
        top = float(pts[:, 1].min())
        flat = np.array([(c[2], c[1]) for c in shell if abs(c[0]) > 3.3 and abs(c[2] - ws) < 0.75 and abs(c[1] - top) < 0.012])
        # fit the opening shape (suv_shape rounded trapezoid) to the lip vertices: best s offset of its centre
        lip = [(c[2], c[1]) for c in shell if abs(c[0]) > 3.3 and abs(c[2] - ws) < 2.4 and 1.2 < c[1] < 3.3
               and abs(BS.arch_dist(c[2] - ws, c[1] - 1.49)) < 0.05]
        best = None
        for k in range(-200, 201):
            ds0 = k * 0.001
            err = sum(BS.arch_dist(sv - ws - ds0, Yv - 1.49) ** 2 for sv, Yv in lip)
            if best is None or err < best[0]:
                best = (err, ds0)
        arch[ws] = dict(opening_top_Y=round(top, 3), lip_vertices=len(lip), centre_s=round(ws + best[1], 3),
                        rms=round(math.sqrt(best[0] / max(1, len(lip))), 4))
res.update(length=round(L, 3), height_rails=round(H, 3), height_roof=round(Hroof, 3), width_body=round(Wb, 3),
           width_with_mirrors=round(Wm, 3), front=round(min(c[2] for c in allv), 3), rear=round(max(c[2] for c in allv), 3),
           arches={str(k): v for k, v in arch.items()},
           wheelbase_from_arches=round(arch[4.85]["centre_s"] - arch[-4.85]["centre_s"], 3)
           if all(arch.get(k, {}).get("centre_s") is not None for k in (-4.85, 4.85)) else None,
           tris_total=sum(m["tris"] for m in res["meshes"].values()))
json.dump(res, open(outp, "w"), indent=1)
print(json.dumps({k: v for k, v in res.items() if k != "meshes"}))
for k, v in res["meshes"].items():
    print(k, v)
