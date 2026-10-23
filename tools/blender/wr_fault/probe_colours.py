# Median colour of small boxes on a concept sheet (sheet px).  py -I probe_colours.py <sheet.png> name:x,y[,r] ...
import sys
import numpy as np
from PIL import Image
a = np.asarray(Image.open(sys.argv[1]).convert("RGB")).astype(int)
for s in sys.argv[2:]:
    nm, xy = s.split(":"); v = [int(t) for t in xy.split(",")]; x, y = v[0], v[1]; r = v[2] if len(v) > 2 else 4
    blk = a[y - r:y + r + 1, x - r:x + r + 1].reshape(-1, 3)
    m = np.median(blk, 0).astype(int)
    print(f"{nm:14s} #{m[0]:02X}{m[1]:02X}{m[2]:02X}  min {blk.min(0)} max {blk.max(0)}")
