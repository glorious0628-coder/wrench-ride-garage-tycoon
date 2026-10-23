# Main flat colours of a split concept's object pixels (pp-3d-make 10-20) - helper to write the palette json.
#   py -I tools/blender/palette_guess.py <cell_prefix> [k=6]
import sys
import numpy as np
from PIL import Image
from scipy.cluster.vq import kmeans2
pre = sys.argv[1]; k = int(sys.argv[2]) if len(sys.argv) > 2 else 6
px = []
for n in ["front", "back", "left", "right", "top", "bottom"]:
    a = np.asarray(Image.open(f"{pre}_{n}.png").convert("RGB")).reshape(-1, 3).astype(np.float32)
    px.append(a[a.min(1) < 245][::7])
px = np.concatenate(px)
c, l = kmeans2(px, k, seed=1, minit="++")
for i in np.argsort(-np.bincount(l, minlength=k)):
    r, g, b = c[i].astype(int); print(f"#{r:02X}{g:02X}{b:02X}", round(float((l == i).mean()) * 100, 1), "%")
