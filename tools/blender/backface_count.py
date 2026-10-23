# count magenta (back-facing) pixels in backface renders: py -I tools/blender/backface_count.py <dir>
import sys, glob, os
import numpy as np
from PIL import Image
for f in sorted(glob.glob(os.path.join(sys.argv[1], "*.png"))):
    a = np.asarray(Image.open(f).convert("RGBA"))
    n = int(((a[..., 0] > 200) & (a[..., 1] < 60) & (a[..., 2] > 200) & (a[..., 3] > 200)).sum())
    print(os.path.basename(f), n)
