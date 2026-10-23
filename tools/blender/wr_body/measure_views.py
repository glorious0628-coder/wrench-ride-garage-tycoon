# Per-row extents of the front/back cells and per-row (length) extents of the bottom/top cells (wr-3d-body).
#   py -I tools/blender/wr_body/measure_views.py <cell_prefix>
import sys
import numpy as np
from PIL import Image
P = sys.argv[1]


def load(n):
    a = np.asarray(Image.open(f"{P}_{n}.png").convert("RGB")).astype(int)
    return a, a.min(2) < 235


for n in ("front", "back"):
    a, m = load(n)
    ys, xs = np.where(m)
    y0, y1 = ys.min(), ys.max(); cx = (xs.min() + xs.max()) / 2
    print(n, "rows", y0, y1, "cx", cx)
    blue = (a[..., 2] > a[..., 0] + 60) & (a[..., 2] > 150)
    for y in range(y0, y1 + 1, 6):
        r = np.where(m[y])[0]; bl = np.where(blue[y])[0]
        print(f"  y {y} h(px from ground) {y1 - y}  all {r.min()}..{r.max()} w {r.max() - r.min() + 1}   blue {bl.min() if len(bl) else -1}..{bl.max() if len(bl) else -1}")
for n in ("bottom", "top"):
    a, m = load(n)
    ys, xs = np.where(m)
    y0, y1 = ys.min(), ys.max()
    blue = (a[..., 2] > a[..., 0] + 60) & (a[..., 2] > 150)
    print(n, "rows", y0, y1, "cols", xs.min(), xs.max())
    for y in range(y0, y1 + 1, 12):
        r = np.where(m[y])[0]; bl = np.where(blue[y])[0]
        print(f"  y {y} all {r.min()}..{r.max()} w {r.max() - r.min() + 1}  blue {bl.min() if len(bl) else -1}..{bl.max() if len(bl) else -1}")
