# Measure the sedan 6-view side cell (wr-3d-body): silhouette top/bottom per column, tyres, glass, in px and stud.
#   py -I tools/blender/wr_body/measure_side.py <cell_left.png>
import sys
import numpy as np
from PIL import Image
from scipy import ndimage

a = np.asarray(Image.open(sys.argv[1]).convert("RGB")).astype(int)
r, g, b = a[..., 0], a[..., 1], a[..., 2]
fg = a.min(2) < 235
ys, xs = np.where(fg)
X0, X1 = xs.min(), xs.max()
GROUND = ys.max()
PX = (X1 - X0 + 1) / 17.0
print("x", X0, X1, "ground", GROUND, "px/stud", round(PX, 3))
blue = (b > r + 60) & (b > 150)
dark = (a.max(2) < 70)                       # tyre black / black trim
grey_glass = (a.max(2) < 140) & (np.abs(r - b) < 40) & ~dark
# tyres: big dark blobs in the lower part
tyre = dark & (np.arange(a.shape[0])[:, None] > GROUND - 120)
lab, n = ndimage.label(ndimage.binary_closing(tyre, iterations=2))
sz = ndimage.sum(tyre, lab, range(1, n + 1))
for i in np.argsort(sz)[::-1][:2]:
    yy, xx = np.where(lab == i + 1)
    print("tyre blob x", xx.min(), xx.max(), "y", yy.min(), yy.max(), "cx", (xx.min() + xx.max()) / 2, "diam", xx.max() - xx.min())
# light rim (silver) per tyre: pixels light grey
silver = (a.min(2) > 150) & (np.abs(r - b) < 25) & (a.max(2) < 235) & (np.arange(a.shape[0])[:, None] > GROUND - 110)
lab, n = ndimage.label(silver)
sz = ndimage.sum(silver, lab, range(1, n + 1))
for i in np.argsort(sz)[::-1][:2]:
    yy, xx = np.where(lab == i + 1)
    print("rim x", xx.min(), xx.max(), "y", yy.min(), yy.max(), "c", ((xx.min() + xx.max()) / 2, (yy.min() + yy.max()) / 2))
print("col  s(stud)  top  bot  blue_top blue_bot glass_top glass_bot")
for x in range(X0, X1 + 1, 8):
    col = fg[:, x]; t = np.where(col)[0]
    bt = np.where(blue[:, x])[0]; gl = np.where(grey_glass[:, x])[0]
    s = (x - X0) / PX - 8.4
    print(x, round(s, 2), t.min(), t.max(), bt.min() if len(bt) else -1, bt.max() if len(bt) else -1,
          gl.min() if len(gl) else -1, gl.max() if len(gl) else -1)
