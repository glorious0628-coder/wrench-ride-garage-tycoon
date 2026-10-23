# Per-row extents of the SUV front / back cells (wr-3d-suv): body width without mirrors normalised to 7.7, height
# (ground .. rail top) normalised to 6.6. Prints per row: Y, full extent, paint extent, dark runs, light / red runs (x in stud).
#   py -I tools/blender/wr_suv/measure_fb.py <cell_prefix> [step]
import sys
import numpy as np
from PIL import Image
P = sys.argv[1]; STEP = int(sys.argv[2]) if len(sys.argv) > 2 else 5


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


for n in ("front", "back"):
    a = np.asarray(Image.open(f"{P}_{n}.png").convert("RGB")).astype(int)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    m = a.min(2) < 235
    ys, xs = np.where(m)
    y0, y1 = ys.min(), ys.max()
    rows = range(int(y1 - 0.45 * (y1 - y0)), y1 - 4)
    w = [(np.where(m[rr])[0].min(), np.where(m[rr])[0].max()) for rr in rows if m[rr].any()]
    x0 = int(np.median([v[0] for v in w])); x1 = int(np.median([v[1] for v in w]))
    cx = (x0 + x1) / 2; sx = 7.7 / (x1 - x0 + 1); sy = 6.6 / (y1 - y0 + 1)
    print(n, "rows", y0, y1, "body cols", x0, x1, "stud/px x", round(sx, 4), "y", round(sy, 4), "aspect(conc w/h)", round((x1 - x0 + 1) / (y1 - y0 + 1), 3), "spec", round(7.7 / 6.6, 3))
    paint = (g > r + 6) & (g > b + 6) & (a.max(2) > 110)
    dark = a.max(2) < 75
    light = (a.min(2) > 215) & m
    red = (r > g + 70) & (r > b + 60)
    X = lambda i: round((i - cx) * sx, 2)
    for y in range(y0, y1 + 1, STEP):
        Y = round((y1 - y) * sy, 2)
        f = np.where(m[y])[0]; p = np.where(paint[y])[0]
        print(f"Y {Y:5.2f} all {X(f.min()):6.2f}..{X(f.max()):5.2f}  paint {X(p.min()) if len(p) else '-'}..{X(p.max()) if len(p) else '-'}  dark {runs(dark[y], X)}  light {runs(light[y], X)}  red {runs(red[y], X)}")
