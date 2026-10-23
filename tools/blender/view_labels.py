# Material label maps for the split 6-view concept cells (pp-3d-make 10-20), used by label_bake.py.
# Each object pixel -> one palette material: shaded colours match by hue/sat/value, painted highlights and small
# white specks take the material around them (ring majority), anti-aliased edges and thin lines are cleaned with a
# mode filter. Background = near-white connected to the cell border -> 255. The original cells are not changed.
#   py -I tools/blender/view_labels.py <views.json> <palette.json> <out_dir>
# Writes <out_dir>/<view>_lab.png (palette index, 255 = background), <view>_labprev.png and views_lab.json.
import sys, json, os
import numpy as np
from PIL import Image
from scipy import ndimage

vj, pj, od = sys.argv[1:4]
cfg = json.load(open(vj, encoding="utf-8")); pal = json.load(open(pj, encoding="utf-8"))
os.makedirs(od, exist_ok=True)
K = len(pal)
cols = np.array([[int(p["hex"][i:i + 2], 16) / 255 for i in (1, 3, 5)] for p in pal], np.float32)
white = [i for i, p in enumerate(pal) if p.get("white")]


def hsv(x):
    mx = x.max(-1); mn = x.min(-1); d = mx - mn; h = np.zeros_like(mx)
    r, g, b = x[..., 0], x[..., 1], x[..., 2]; m = d > 1e-6
    rr = m & (mx == r); gg = m & (mx == g) & ~rr; bb = m & ~rr & ~gg
    h[rr] = ((g - b)[rr] / d[rr]) % 6; h[gg] = (b - r)[gg] / d[gg] + 2; h[bb] = (r - g)[bb] / d[bb] + 4
    return h / 6.0, np.where(mx > 1e-6, d / np.maximum(mx, 1e-6), 0), mx


PH, PS, PV = hsv(cols)
out = dict(cfg); out["views"] = {}
for name, v in cfg["views"].items():
    path = v[0]
    a = np.asarray(Image.open(path).convert("RGB")).astype(np.float32) / 255
    H, Sa, V = hsv(a)
    D = []
    for k in range(K):
        dh = np.abs(H - PH[k]); dh = np.minimum(dh, 1 - dh)
        D.append(60.0 * dh ** 2 * np.minimum(Sa, PS[k]) + 0.5 * (Sa - PS[k]) ** 2 + 0.25 * (V - PV[k]) ** 2)
    D = np.stack(D)
    for k, p in enumerate(pal):
        if p.get("never"):  # only made by rules in label_bake (e.g. lens_dark via absorb_as)
            D[k] = np.inf
    lab = D.argmin(0)
    nearw = a.min(-1) > 0.975
    cc, n = ndimage.label(nearw)
    border = set(np.unique(np.concatenate([cc[0], cc[-1], cc[:, 0], cc[:, -1]]))) - {0}
    bg = np.isin(cc, list(border))
    obj = ndimage.binary_fill_holes(~bg)
    bg = ~obj
    # painted highlights: pale, bright, not a real white material -> take the surrounding material
    unk = obj & (Sa < 0.16) & (V > 0.88)
    if white:
        # a real white part (sole) is a big region; only small pale patches are highlights
        comp, nc = ndimage.label(unk)
        sizes = ndimage.sum(np.ones_like(comp), comp, range(1, nc + 1))
        big = np.isin(comp, [i + 1 for i, s in enumerate(sizes) if s > 0.02 * obj.sum()])
        lab[big] = white[0]
        unk &= ~big
    known = obj & ~unk
    comp, nc = ndimage.label(unk)
    for k, sl in enumerate(ndimage.find_objects(comp), start=1):
        ys = slice(max(sl[0].start - 4, 0), sl[0].stop + 4); xs = slice(max(sl[1].start - 4, 0), sl[1].stop + 4)
        c = comp[ys, xs] == k
        ring = ndimage.binary_dilation(c, iterations=3) & ~c & known[ys, xs]
        if ring.any():
            sub = lab[ys, xs]; sub[c] = np.bincount(sub[ring], minlength=K).argmax()
    # mode filter (7 px) inside the object
    votes = np.stack([ndimage.uniform_filter((lab == k).astype(np.float32), 7) for k in range(K)])
    lab = votes.argmax(0)
    # "inside": a painted detail only counts where it sits inside the listed materials (eyes/brows inside the face);
    # the same colour elsewhere (a brown shadow under a bell) takes the colour around it
    for k, p in enumerate(pal):
        if not p.get("inside"):
            continue
        ins = [i for i, q in enumerate(pal) if q["name"] in p["inside"]] + [i for i, q in enumerate(pal) if q.get("decal")]
        comp, nc = ndimage.label((lab == k) & obj)
        for c_i, sl in enumerate(ndimage.find_objects(comp), start=1):
            ys = slice(max(sl[0].start - 4, 0), sl[0].stop + 4); xs = slice(max(sl[1].start - 4, 0), sl[1].stop + 4)
            c = comp[ys, xs] == c_i
            ring = ndimage.binary_dilation(c, iterations=3) & ~c & obj[ys, xs]
            if not ring.any():
                continue
            rl = lab[ys, xs][ring]; maj = np.bincount(rl, minlength=K).argmax()
            if maj not in ins:
                sub = lab[ys, xs]; sub[c] = maj
    lab[bg] = 255
    Image.fromarray(lab.astype(np.uint8)).save(os.path.join(od, f"{name}_lab.png"))
    prev = np.full(a.shape, 1.0, np.float32); prev[~bg] = cols[lab[~bg]]
    Image.fromarray((prev * 255).astype(np.uint8)).save(os.path.join(od, f"{name}_labprev.png"))
    out["views"][name] = [os.path.abspath(os.path.join(od, f"{name}_lab.png")).replace("\\", "/")] + list(v[1:])
    print(name, {p["name"]: int((lab == i).sum()) for i, p in enumerate(pal)})
json.dump(out, open(os.path.join(od, "views_lab.json"), "w", encoding="utf-8"), indent=1)
print("ok", os.path.join(od, "views_lab.json"))
