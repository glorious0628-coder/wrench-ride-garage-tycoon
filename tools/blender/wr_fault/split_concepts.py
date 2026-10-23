# Split a 3x2 six-view concept sheet into its view cells (front, back, left / right, top, bottom - handoff README order):
# every foreground blob goes to the grid cell holding its centre (thin parts like a wiper do not form one big blob, and
# a part sticking over a grid line stays with its own view), crop each cell to its silhouette, print the bbox (sheet px).
#   py -I split_concepts.py <sheet.png> <out_prefix>
import sys
import numpy as np
from PIL import Image
from scipy import ndimage

sheet, pre = sys.argv[1], sys.argv[2]
im = Image.open(sheet).convert("RGB"); a = np.asarray(im).astype(int)
H, W = a.shape[:2]
fg = a.min(2) < 235
lab, n = ndimage.label(ndimage.binary_dilation(fg, iterations=2))
NAMES = ["front", "back", "left", "right", "top", "bottom"]
boxes = {k: [W, H, 0, 0] for k in range(6)}
for sl, i in zip(ndimage.find_objects(lab), range(1, n + 1)):
    ys, xs = np.where((lab[sl] == i) & fg[sl])
    if len(ys) < 30:
        continue
    cy, cx = ys.mean() + sl[0].start, xs.mean() + sl[1].start
    k = int(cy // (H / 2)) * 3 + int(cx // (W / 3))
    b = boxes[k]
    b[0] = min(b[0], xs.min() + sl[1].start); b[1] = min(b[1], ys.min() + sl[0].start)
    b[2] = max(b[2], xs.max() + sl[1].start + 1); b[3] = max(b[3], ys.max() + sl[0].start + 1)
for k, nm in enumerate(NAMES):
    bx0, by0, bx1, by1 = boxes[k]; m = 14
    im.crop((max(0, bx0 - m), max(0, by0 - m), min(W, bx1 + m), min(H, by1 + m))).save(f"{pre}_{nm}.png")
    print(nm, "bbox", bx0, by0, bx1, by1, "w", bx1 - bx0, "h", by1 - by0)
