# Print UV ranges per material (and per 1/3 window cell) for bundle cars -> decide the shared-atlas layout.
#   blender --background --factory-startup --python uv_probe.py -- <a.glb;b.glb;...>
import bpy, sys, os, json
from collections import defaultdict
argv = sys.argv[sys.argv.index("--") + 1:]
for path in argv[0].split(";"):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=path)
    rng = defaultdict(lambda: [1e9, 1e9, -1e9, -1e9, 0]); cells = defaultdict(int)
    for o in bpy.context.scene.objects:
        if o.type != 'MESH':
            continue
        me = o.data; uv = me.uv_layers.active.data
        for p in me.polygons:
            mn = o.material_slots[p.material_index].material.name if o.material_slots else "?"
            us = [uv[i].uv[0] for i in p.loop_indices]; vs = [uv[i].uv[1] for i in p.loop_indices]
            r = rng[mn]; r[0] = min(r[0], min(us)); r[1] = min(r[1], min(vs)); r[2] = max(r[2], max(us)); r[3] = max(r[3], max(vs)); r[4] += 1
            if "indow" in mn:
                cu = int(min(max(sum(us) / len(us), 0), 0.999) * 3); cv = int(min(max(sum(vs) / len(vs), 0), 0.999) * 3)
                cells[(cu, cv)] += 1
                if max(us) - min(us) > 0.34 or max(vs) - min(vs) > 0.34:
                    cells["wide"] += 1
    print("UVPROBE", os.path.basename(path), json.dumps({k: [round(x, 3) for x in v[:4]] + [v[4]] for k, v in rng.items()}), dict((str(k), v) for k, v in cells.items()))
