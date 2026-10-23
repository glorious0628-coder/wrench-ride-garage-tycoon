# Per-row (along the length) extents of the SUV top / bottom cells (wr-3d-suv). Length normalised to 16.6 (front -8.15),
# width normalised to 7.7 by the median body width (the top cell is drawn too narrow: layout only).
#   py -I tools/blender/wr_suv/measure_tb.py <cell_prefix> [step]
import sys
import numpy as np
from PIL import Image
P = sys.argv[1]; STEP = int(sys.argv[2]) if len(sys.argv) > 2 else 8


def runs(m, conv):
    out = []; i = 0
    while i < len(m):
        if m[i]:
            j = i
            while j < len(m) and m[j]:
                j += 1
            if j - i >= 2:
                out.append((conv(i), conv(j - 1)))
            i = j
        else:
            i += 1
    return out


for n in ("top", "bottom"):
    a = np.asarray(Image.open(f"{P}_{n}.png").convert("RGB")).astype(int)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    m = a.min(2) < 235
    ys, xs = np.where(m)
    y0, y1 = ys.min(), ys.max()
    rows = [rr for rr in range(y0, y1) if m[rr].any()]
    wid = np.array([np.where(m[rr])[0].max() - np.where(m[rr])[0].min() for rr in rows])
    mid = [rr for rr, w in zip(rows, wid) if abs(w - np.median(wid)) < 4]
    x0 = int(np.median([np.where(m[rr])[0].min() for rr in mid])); x1 = int(np.median([np.where(m[rr])[0].max() for rr in mid]))
    cx = (x0 + x1) / 2; sx = 7.7 / (x1 - x0 + 1); sl = 16.6 / (y1 - y0 + 1)
    print(n, "rows", y0, y1, "body cols", x0, x1, "len px", y1 - y0 + 1, "width px", x1 - x0 + 1, "ratio L/W", round((y1 - y0 + 1) / (x1 - x0 + 1), 3), "spec", round(16.6 / 7.7, 3))
    paint = (g > r + 6) & (g > b + 6) & (a.max(2) > 110)
    dark = a.max(2) < 75
    light = (a.min(2) > 215) & m
    red = (r > g + 70) & (r > b + 60)
    X = lambda i: round((i - cx) * sx, 2)
    for y in range(y0, y1 + 1, STEP):
        # top cell: front at the bottom of the picture; bottom cell: front at the top
        s = (-8.15 + (y1 - y) * sl) if n == "top" else (-8.15 + (y - y0) * sl)
        f = np.where(m[y])[0]; p = np.where(paint[y])[0]
        print(f"s {s:6.2f} all {X(f.min()):6.2f}..{X(f.max()):5.2f}  paint {X(p.min()) if len(p) else '-'}..{X(p.max()) if len(p) else '-'}  dark {runs(dark[y], X)}  light {runs(light[y], X)} red {runs(red[y], X)}")
