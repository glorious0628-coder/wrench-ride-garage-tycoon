# Measure the SUV 6-view side cell (wr-3d-suv, 10-21): silhouette top/bottom per column, paint (green) / dark bands,
# tyres, in px and stud (length stretched to suv_spec 16.6, front -8.15).
#   py -I tools/blender/wr_suv/measure_side.py <cell_left.png> [step]
import sys
import numpy as np
from PIL import Image
from scipy import ndimage

a = np.asarray(Image.open(sys.argv[1]).convert("RGB")).astype(int)
STEP = int(sys.argv[2]) if len(sys.argv) > 2 else 8
r, g, b = a[..., 0], a[..., 1], a[..., 2]
fg = a.min(2) < 235
ys, xs = np.where(fg)
X0, X1 = xs.min(), xs.max()
GROUND = ys.max()
PX = (X1 - X0 + 1) / 16.6
print("x", X0, X1, "ground", GROUND, "top", ys.min(), "px/stud", round(PX, 3), "height stud", round((GROUND - ys.min()) / PX, 3))
paint = (g > r + 6) & (g > b + 6) & (a.max(2) > 110)
dark = (a.max(2) < 75)
tyre = dark & (np.arange(a.shape[0])[:, None] > GROUND - 0.25 * (GROUND - ys.min()))
lab, n = ndimage.label(ndimage.binary_closing(tyre, iterations=2))
sz = ndimage.sum(tyre, lab, range(1, n + 1))
for i in np.argsort(sz)[::-1][:2]:
    yy, xx = np.where(lab == i + 1)
    print("tyre blob x", xx.min(), xx.max(), "y", yy.min(), yy.max(), "cx", (xx.min() + xx.max()) / 2,
          "s", round(((xx.min() + xx.max()) / 2 - X0) / PX - 8.15, 3), "diam px", xx.max() - xx.min(), "stud", round((xx.max() - xx.min()) / PX, 3))
silver = (a.min(2) > 150) & (np.abs(r - b) < 25) & (np.abs(g - b) < 25) & (a.max(2) < 235) & (np.arange(a.shape[0])[:, None] > GROUND - 0.4 * (GROUND - ys.min()))
lab, n = ndimage.label(silver)
sz = ndimage.sum(silver, lab, range(1, n + 1))
for i in np.argsort(sz)[::-1][:2]:
    yy, xx = np.where(lab == i + 1)
    cx, cy = (xx.min() + xx.max()) / 2, (yy.min() + yy.max()) / 2
    print("rim x", xx.min(), xx.max(), "y", yy.min(), yy.max(), "c", (cx, cy), "s", round((cx - X0) / PX - 8.15, 3), "Y", round((GROUND - cy) / PX, 3), "diam stud", round((xx.max() - xx.min()) / PX, 3))
print("col  s   top(Y)  bot(Y)  paint_top paint_bot  dark runs (Y ranges)")
for x in range(X0, X1 + 1, STEP):
    col = fg[:, x]; t = np.where(col)[0]
    pt = np.where(paint[:, x])[0]
    s = (x - X0) / PX - 8.15
    Y = lambda yy: round((GROUND - yy) / PX, 2)
    # dark runs
    d = dark[:, x] & col
    runs = []
    yy = 0
    while yy < len(d):
        if d[yy]:
            y0 = yy
            while yy < len(d) and d[yy]:
                yy += 1
            if yy - y0 >= 2:
                runs.append((Y(yy - 1), Y(y0)))
        yy += 1
    print(x, round(s, 2), Y(t.min()), Y(t.max()), Y(pt.min()) if len(pt) else -1, Y(pt.max()) if len(pt) else -1, runs)
