# Split a 6-view concept sheet into its view cells for the 3D generator's input only (user OK 10-20: "6면 시안을 넣어야지").
# The original sheet is never changed; each view is copied with only its own pixels onto a white square, all at the same
# scale. Sheet layout (fixed by the 6-view prompt): top row = front, back, left (the object's own left: its front faces
# the picture's left), bottom row = right, top, bottom.
#   py -I tools/split_6view.py <sheet.png> <out_prefix> [cell=600] [min_frac=0.02]   ->  <out_prefix>_front.png, _back, _left, _right, _top, _bottom
#   min_frac = smallest view area as a share of the sheet; thin parts (radiator / muffler side views) need ~0.003
#   (Wrench & Ride 10-20: wr-art found those side views were dropped as specks at 0.02).
import sys
import numpy as np
from PIL import Image
from scipy import ndimage

NAMES = ["front", "back", "left", "right", "top", "bottom"]
SIZE = 600


def main():
    global SIZE
    src, prefix = sys.argv[1], sys.argv[2]
    if len(sys.argv) > 3:
        SIZE = int(sys.argv[3])   # tall views (big tree 605 px) need a bigger cell
    min_frac = float(sys.argv[4]) if len(sys.argv) > 4 else 0.02
    a = np.asarray(Image.open(src).convert("RGB"))
    fg = a.astype(int).min(2) < 235
    lab, n = ndimage.label(ndimage.binary_closing(fg, iterations=3))
    sizes = ndimage.sum(np.ones_like(lab), lab, range(1, n + 1))
    keep = [i + 1 for i, s in enumerate(sizes) if s > min_frac * a.shape[0] * a.shape[1]]
    if len(keep) != 6:
        print("ERROR: found", len(keep), "views, not 6 - views touch or have loose parts; check the sheet by eye")
        sys.exit(1)
    boxes = []
    for i in keep:
        ys, xs = np.where(lab == i)
        boxes.append((xs.min(), ys.min(), xs.max(), ys.max(), i))
    row_h = a.shape[0] // 2
    boxes.sort(key=lambda b: ((b[1] + b[3]) // 2 // row_h, b[0]))
    for name, (x0, y0, x1, y1, i) in zip(NAMES, boxes):
        region = a[y0:y1 + 1, x0:x1 + 1].copy()
        mask = ndimage.binary_dilation(lab[y0:y1 + 1, x0:x1 + 1] == i, iterations=4)
        region[~mask] = 255
        h, w = region.shape[:2]
        if max(h, w) > SIZE:
            print("ERROR: view bigger than", SIZE, name)
            sys.exit(1)
        can = np.full((SIZE, SIZE, 3), 255, np.uint8)
        oy, ox = (SIZE - h) // 2, (SIZE - w) // 2
        can[oy:oy + h, ox:ox + w] = region
        Image.fromarray(can).save(f"{prefix}_{name}.png")
        print(name, (int(x0), int(y0), int(x1), int(y1)), "size", (w, h))


if __name__ == "__main__":
    main()
