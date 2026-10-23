# Radial brightness profile of a round concept cell (wr-3d): prints the value along a few angles from the centre.
#   py -I tools/blender/wr/measure_radial.py <cell.png> <angle_deg,...> [step=4]
import sys, math
import numpy as np
from PIL import Image
a = np.asarray(Image.open(sys.argv[1]).convert("RGB")).astype(int)
fg = a.min(2) < 235
ys, xs = np.where(fg)
cx, cy = (xs.min() + xs.max()) / 2, (ys.min() + ys.max()) / 2
R = max(xs.max() - xs.min(), ys.max() - ys.min()) / 2
print("bbox", xs.min(), ys.min(), xs.max(), ys.max(), "centre", cx, cy, "R", R)
step = int(sys.argv[3]) if len(sys.argv) > 3 else 4
for ang in [float(t) for t in sys.argv[2].split(",")]:
    th = math.radians(ang)   # 0 = up, clockwise
    row = []
    for r in range(0, int(R) + 6, step):
        x = int(round(cx + r * math.sin(th))); y = int(round(cy - r * math.cos(th)))
        if 0 <= x < a.shape[1] and 0 <= y < a.shape[0]:
            row.append("%d:%s" % (r, "%02x%02x%02x" % tuple(a[y, x])))
    print("ang", ang, " ".join(row))
