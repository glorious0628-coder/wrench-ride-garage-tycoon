# Clean the split 6-view concept cells in 2D before projecting them (pp-3d-make 10-20, main's fix ①): every object
# pixel becomes one palette material (flat colour), the concept's painted highlights / small white specks take the
# material around them, and the white background is filled with the nearest material so the projection never smears
# background white onto the mesh edges. Writes <out_dir>/<view>.png and a new views json pointing at them.
#   py -I tools/blender/clean_views.py <views.json> <palette.json> <out_dir> [min_white_frac=0.02]
import sys, json, os
import numpy as np
from PIL import Image
from scipy import ndimage

vj, pj, od = sys.argv[1:4]
MINW = float(sys.argv[4]) if len(sys.argv) > 4 else 0.02
cfg = json.load(open(vj, encoding="utf-8")); pal = json.load(open(pj, encoding="utf-8"))
os.makedirs(od, exist_ok=True)
cols = np.array([[int(p["hex"][i:i + 2], 16) / 255 for i in (1, 3, 5)] for p in pal], np.float32)


def hsv(x):
    mx = x.max(-1); mn = x.min(-1); d = mx - mn; h = np.zeros_like(mx)
    r, g, b = x[..., 0], x[..., 1], x[..., 2]; m = d > 1e-6
    rr = m & (mx == r); gg = m & (mx == g) & ~rr; bb = m & ~rr & ~gg
    h[rr] = ((g - b)[rr] / d[rr]) % 6; h[gg] = (b - r)[gg] / d[gg] + 2; h[bb] = (r - g)[bb] / d[bb] + 4
    return h / 6.0, np.where(mx > 1e-6, d / np.maximum(mx, 1e-6), 0), mx


ph, ps, pv = hsv(cols)
wk = [i for i, p in enumerate(pal) if p.get("white")]
out = {"size": cfg["size"], "power": cfg.get("power", 12), "views": {}}
for name, (path, ox, oy, w, h) in cfg["views"].items():
    a = np.asarray(Image.open(path).convert("RGB")).astype(np.float32) / 255
    H, S, V = hsv(a)
    # background = near-pure white connected to the border
    bgc = (a.min(-1) >= 252 / 255)  # the concept background is pure white; a white material is shaded below that
    lab_bg, _ = ndimage.label(bgc)
    border = set(np.unique(np.r_[lab_bg[0], lab_bg[-1], lab_bg[:, 0], lab_bg[:, -1]])) - {0}
    bg = np.isin(lab_bg, list(border))
    obj = ndimage.binary_fill_holes(ndimage.binary_opening(~bg, iterations=1))
    D = []
    for k in range(len(pal)):
        dh = np.abs(H - ph[k]); dh = np.minimum(dh, 1 - dh); hw = np.minimum(S, ps[k])
        D.append(60.0 * dh ** 2 * hw + 0.5 * (S - ps[k]) ** 2 + 0.25 * (V - pv[k]) ** 2)
    lab = np.argmin(np.stack(D), 0)
    # near-white inside the object: a real white material only if it is a big patch; small ones are painted highlights
    nearw = obj & (S < 0.16) & (V > 0.8)
    comp, n = ndimage.label(nearw)
    area = obj.sum()
    fix = np.zeros_like(nearw)
    for k, sl in enumerate(ndimage.find_objects(comp), start=1):
        c = comp[sl] == k
        if not wk or c.sum() < MINW * area:
            fix[sl] |= c
        else:
            lab[sl][c] = wk[0]
    if not wk:
        fix |= nearw
    fix |= obj & (S < 0.16) & (V > 0.95)  # painted specular highlights are near pure white; a white material is shaded
    known = obj & ~fix
    if wk:  # off-white shading that wasn't classified as the white material shouldn't be white either
        pass
    idx = ndimage.distance_transform_edt(~known, return_distances=False, return_indices=True)
    lab = lab[idx[0], idx[1]]  # highlights and the background take the nearest real material
    lab = ndimage.median_filter(lab, size=5)
    img = (cols[lab] * 255).astype(np.uint8)
    p2 = os.path.join(od, f"{name}.png").replace("\\", "/")
    Image.fromarray(img).save(p2)
    out["views"][name] = [p2, ox, oy, w, h]
    print(name, "fixed", int(fix.sum()), "px;", {pal[i]["name"]: int(((lab == i) & obj).sum()) for i in range(len(pal))})
json.dump(out, open(os.path.join(od, "views.json"), "w", encoding="utf-8"), indent=1)
print("ok", os.path.join(od, "views.json"))
