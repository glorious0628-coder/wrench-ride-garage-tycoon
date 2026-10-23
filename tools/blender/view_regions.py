# Snap each view's material labels to the MESH's own parts (pp-3d-make 10-20, GPT sneaker_1st_r1: "deliberate, solid
# panel regions"). The mesh's grey render (mesh_views.py, same framing as the concept cell) is cut into regions along
# its own edges (watershed on the render's gradient = straps, pads, toe cap, sole come out as regions); every region
# takes the concept material that covers most of it. Result: label maps whose borders sit on real mesh edges.
#   py -I tools/blender/view_regions.py <views_lab.json> <mesh_views_dir> <out_dir> [markers=260] [compact=0.002]
# Writes <out_dir>/<view>_lab.png (+ _regprev.png check) and views_lab.json (keeps the conf field if present).
import sys, json, os
import numpy as np
from PIL import Image
from scipy import ndimage
from skimage import filters, segmentation, morphology

lj, md, od = sys.argv[1:4]
NM = int(sys.argv[4]) if len(sys.argv) > 4 else 260
CP = float(sys.argv[5]) if len(sys.argv) > 5 else 0.002
cfg = json.load(open(lj, encoding="utf-8")); os.makedirs(od, exist_ok=True)
out = dict(cfg); out["views"] = {}
rng = np.random.default_rng(0)
for name, v in cfg["views"].items():
    lp, ox, oy, w, h = v[:5]
    lab = np.asarray(Image.open(lp)).astype(np.int32); S = lab.shape[0]
    m = np.asarray(Image.open(os.path.join(md, name + ".png")).convert("RGBA").resize((w, h), Image.LANCZOS)).astype(np.float32) / 255
    g = np.ones((S, S), np.float32); a = np.zeros((S, S), bool)
    g[oy:oy + h, ox:ox + w] = m[..., :3].mean(-1); a[oy:oy + h, ox:ox + w] = m[..., 3] > 0.5
    grad = filters.sobel(ndimage.gaussian_filter(g, 1.0))
    grad[~a] = grad.max()
    regions = segmentation.watershed(grad, markers=NM, compactness=CP, mask=a)
    K = int(lab[lab != 255].max()) + 1 if (lab != 255).any() else 1
    nl = np.full(lab.shape, 255, np.int32)
    for r in range(1, regions.max() + 1):
        sel = regions == r
        if not sel.any():
            continue
        vals = lab[sel]; vals = vals[vals != 255]
        if len(vals) == 0:
            continue
        nl[sel] = np.bincount(vals, minlength=K).argmax()
    # mesh pixels whose region had no concept label: nearest label
    hole = a & (nl == 255)
    if hole.any() and (nl != 255).any():
        idx = ndimage.distance_transform_edt(nl == 255, return_distances=False, return_indices=True)
        nl[hole] = nl[idx[0], idx[1]][hole]
    nl[~a] = 255
    Image.fromarray(nl.astype(np.uint8)).save(os.path.join(od, f"{name}_lab.png"))
    pal = (rng.random((K + 1, 3)) * 0 + np.array([[240, 44, 156], [192, 240, 60], [244, 244, 244], [64, 224, 240]] + [[0, 0, 0]] * 8)[:K + 1]).astype(np.uint8)
    prev = np.full((S, S, 3), 255, np.uint8); prev[a] = (pal[np.minimum(nl[a], K)] * 0.65 + 0.35 * 255 * g[a, None]).astype(np.uint8)
    bnd = segmentation.find_boundaries(regions) & a; prev2 = prev.copy(); prev2[bnd] = (40, 40, 40)
    Image.fromarray(np.concatenate([prev2, prev], 1)).save(os.path.join(od, f"{name}_regprev.png"))
    out["views"][name] = [os.path.abspath(os.path.join(od, f"{name}_lab.png")).replace("\\", "/")] + list(v[1:])
    print(name, "regions", int(regions.max()))
json.dump(out, open(os.path.join(od, "views_lab.json"), "w", encoding="utf-8"), indent=1)
print("ok", os.path.join(od, "views_lab.json"))
