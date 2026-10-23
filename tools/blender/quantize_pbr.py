# Turn a baked concept projection into clean PBR maps: every texel is matched to one material of the item's palette
# (shading and the concept's painted highlights don't count much; white background fringe is filled from neighbours),
# then base colour / roughness / metalness come from that material. Writes <prefix>_base.png, _orm.png (R 1, G rough,
# B metal, glTF order) and _labels.png (debug).
#   py -I quantize_pbr.py <proj.png> <prefix> <palette.json>
#   palette.json: [{"name": "body", "hex": "#F6C400", "rough": 0.45, "metal": 0}, ...]
import sys, json
import numpy as np
from PIL import Image
from scipy import ndimage

src, prefix, pj = sys.argv[1:4]
maskp = sys.argv[4] if len(sys.argv) > 4 else None
pal = json.load(open(pj, encoding="utf-8"))
a = np.asarray(Image.open(src).convert("RGB")).astype(np.float32) / 255.0


def hsv(x):
    mx = x.max(-1); mn = x.min(-1); d = mx - mn
    h = np.zeros_like(mx)
    r, g, b = x[..., 0], x[..., 1], x[..., 2]
    m = d > 1e-6
    rr = m & (mx == r); gg = m & (mx == g) & ~rr; bb = m & ~rr & ~gg
    h[rr] = ((g - b)[rr] / d[rr]) % 6; h[gg] = (b - r)[gg] / d[gg] + 2; h[bb] = (r - g)[bb] / d[bb] + 4
    h = h / 6.0
    s = np.where(mx > 1e-6, d / np.maximum(mx, 1e-6), 0)
    return h, s, mx


H, Sat, V = hsv(a)
cols = np.array([[int(p["hex"][i:i + 2], 16) / 255 for i in (1, 3, 5)] for p in pal], np.float32)
ph, ps, pv = hsv(cols)
D = []
for k in range(len(pal)):
    dh = np.abs(H - ph[k]); dh = np.minimum(dh, 1 - dh)
    hw = np.minimum(Sat, ps[k])  # hue only matters when both are coloured
    D.append(60.0 * (dh ** 2) * hw + 0.5 * (Sat - ps[k]) ** 2 + 0.25 * (V - pv[k]) ** 2)
lab = np.argmin(np.stack(D), 0)
# near-white texels are the concept's painted highlights or the white background fringe: take the nearest real colour
# (a palette that has a real white material keeps texels that are close to it)
has_white = any(p.get("white") for p in pal)
unknown = (Sat < 0.14) & (V > 0.86)
if has_white:
    wk = [i for i, p in enumerate(pal) if p.get("white")][0]
    unknown &= lab != wk
inside = np.ones(lab.shape, bool)
if maskp:
    inside = np.asarray(Image.open(maskp).convert("L")) > 128
    # the bake margin smears the island's edge outward; only texels on the mesh are trusted
    inside = ndimage.binary_erosion(inside, iterations=1)
# each patch of highlight/fringe takes the material that surrounds it (an eye's highlight stays eye, a body
# highlight stays body), counting only trusted texels on the mesh
patch = unknown & inside
known = inside & ~unknown
comp, nc = ndimage.label(patch)
resolved = np.zeros(lab.shape, bool)
for k, sl in enumerate(ndimage.find_objects(comp), start=1):
    ys = slice(max(sl[0].start - 3, 0), sl[0].stop + 3); xs = slice(max(sl[1].start - 3, 0), sl[1].stop + 3)
    c = comp[ys, xs] == k
    ring = ndimage.binary_dilation(c, iterations=3) & ~c & known[ys, xs]
    if ring.any():
        lab[ys, xs][c] = np.bincount(lab[ys, xs][ring], minlength=len(pal)).argmax()
        resolved[ys, xs][c] = True
fill = ~inside | (patch & ~resolved)
if fill.any() and (~fill).any():
    idx = ndimage.distance_transform_edt(fill, return_distances=False, return_indices=True)
    lab = lab[idx[0], idx[1]]
# remove lone specks (3x3 majority)
lab = ndimage.median_filter(lab, size=5)
base = cols[lab]
rough = np.array([p["rough"] for p in pal], np.float32)[lab]
metal = np.array([p["metal"] for p in pal], np.float32)[lab]
# a little softness on the borders so edges aren't stair-stepped in the texture
base = np.stack([ndimage.gaussian_filter(base[..., c], 0.8) for c in range(3)], -1)
Image.fromarray((np.clip(base, 0, 1) * 255).astype(np.uint8)).save(prefix + "_base.png")
orm = np.stack([np.ones_like(rough), rough, metal], -1)
Image.fromarray((orm * 255).astype(np.uint8)).save(prefix + "_orm.png")
dbg = (np.array([[(i * 97) % 255, (i * 57 + 80) % 255, (i * 151 + 40) % 255] for i in range(len(pal))], np.uint8))[lab]
Image.fromarray(dbg).save(prefix + "_labels.png")
print("ok", nc, "patches", int(resolved.sum()), "texels by ring;", {p["name"]: int((lab == i).sum()) for i, p in enumerate(pal)})
