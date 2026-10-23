# Colour codes for the sedan body parts, measured on the concept (wr-3d-body, 10-21; same rule as part_colours.py:
# pixels of the part, keep the 35-65 % brightness band, median). Sample boxes are in the split 6-view cells (700 px)
# and the hero image; a check image with the boxes is written next to the output.
#   py -I tools/blender/wr_body/measure_colours.py <cell_prefix> <hero.png> <out.json>
import sys, json
import numpy as np
from PIL import Image, ImageDraw

cp, hero, outp = sys.argv[1:4]
BOX = {   # part: [(image, (x0, y0, x1, y1), pixel filter)]
    "paint":       [("left", (310, 330, 350, 400), "blue"), ("left", (400, 330, 450, 400), "blue"),
                    ("front", (300, 290, 400, 320), "blue"), ("hero", (900, 760, 1000, 880), "blue")],
    "glass":       [("left", (300, 270, 350, 300), "dark"), ("left", (390, 265, 440, 300), "dark")],
    "trim_black":  [("front", (250, 395, 450, 425), "black"), ("left", (500, 268, 530, 292), "black"),
                    ("back", (260, 405, 440, 435), "black")],
    "light_white": [("front", (240, 353, 460, 357), "white")],
    "tail_red":    [("back", (270, 327, 430, 336), "red")],
    "tyre_black":  [("left", (115, 420, 140, 450), "black")],
}


def load(n):
    return Image.open(hero if n == "hero" else f"{cp}_{n}.png").convert("RGB")


def filt(a, kind):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    if kind == "blue":
        return (b > r + 50) & (b > 120)
    if kind == "dark":
        return (a.max(-1) < 140) & (a.min(-1) > 15)
    if kind == "black":
        return a.max(-1) < 90
    if kind == "white":
        return a.min(-1) > 170
    if kind == "red":
        return (r > g + 60) & (r > b + 60)
    return np.ones(a.shape[:2], bool)


res, imgs = {}, {}
for part, boxes in BOX.items():
    P = []
    for n, (x0, y0, x1, y1), k in boxes:
        im = load(n); imgs.setdefault(n, im.copy())
        a = np.asarray(im)[y0:y1, x0:x1].reshape(-1, 3).astype(np.float32)
        a = a[filt(a.reshape(-1, 1, 3), k).reshape(-1)]
        P.append(a)
        ImageDraw.Draw(imgs[n]).rectangle([x0, y0, x1, y1], outline=(255, 0, 255), width=1)
    P = np.concatenate(P)
    V = P.max(1); lo, hi = np.percentile(V, 35), np.percentile(V, 65)
    c = np.median(P[(V >= lo) & (V <= hi)], 0).round().astype(int)
    res[part] = dict(hex="#%02X%02X%02X" % tuple(c), px=int(len(P)))
    print(f"{part:>12}: {res[part]['hex']}  ({len(P)} px)")
json.dump(res, open(outp, "w"), indent=1)
for n, im in imgs.items():
    im.save(outp.replace(".json", f"_check_{n}.png"))
print("ok", outp)
