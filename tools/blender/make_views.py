# views.json for split 6-view cells (pp-3d-make 10-20): the object's box inside each 600 px split cell = the cell's
# non-white bbox (NOT the sheet coordinates split_6view prints).
#   py -I tools/blender/make_views.py <cell_prefix e.g. C:/Users/glori/ComfyUI/input/old_camera> <out.json>
import sys, json
import numpy as np
from PIL import Image
pre, outp = sys.argv[1:3]; out = {"size": 600, "views": {}}
for n in ["front", "back", "left", "right", "top", "bottom"]:
    p = f"{pre}_{n}.png"; a = np.asarray(Image.open(p).convert("RGB")).min(-1) < 245
    ys, xs = np.nonzero(a)
    out["views"][n] = [p.replace("\\", "/"), int(xs.min()), int(ys.min()), int(xs.max() - xs.min() + 1), int(ys.max() - ys.min() + 1)]
json.dump(out, open(outp, "w", encoding="utf-8"), indent=1); print(json.dumps(out["views"]))
