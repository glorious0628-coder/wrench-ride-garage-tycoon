# Colour codes for the SUV body parts, measured on the concept (wr-3d-suv, 10-21; same rule as wr_body/measure_colours.py:
# pixels of the part, keep the 35-65 % brightness band, median). Boxes are in the split 6-view cells (700 px) and the
# hero image; check images with the boxes are written next to the output.
#   py -I tools/blender/wr_suv/measure_colours_suv.py <cell_prefix> <hero.png> <out.json>
import sys, json
import numpy as np
from PIL import Image, ImageDraw

cp, hero, outp = sys.argv[1:4]
BOX = {   # part: [(image, (x0, y0, x1, y1), pixel filter)]
    "paint":       [("left", (240, 335, 345, 400), "green"), ("left", (375, 335, 450, 395), "green"),
                    ("right", (360, 335, 460, 395), "green"), ("front", (290, 375, 410, 388), "green")],   # evenly lit cells (hero door is in shade)
    "glass":       [("left", (285, 262, 345, 300), "dark"), ("left", (385, 255, 445, 298), "dark")],
    "trim_black":  [("left", (240, 418, 450, 432), "black"), ("left", (470, 360, 500, 380), "black"),
                    ("front", (250, 448, 450, 456), "black")],
    "light_white": [("front", (275, 349, 425, 354), "white")],
    "tail_red":    [("back", (250, 320, 450, 330), "red")],
    "skid":        [("front", (260, 438, 440, 452), "silver"), ("back", (260, 426, 440, 440), "silver")],
}


def load(n):
    return Image.open(hero if n == "hero" else f"{cp}_{n}.png").convert("RGB")


def filt(a, kind):
    r, g, b = a[..., 0].astype(int), a[..., 1].astype(int), a[..., 2].astype(int)
    if kind == "green":
        return (g > r + 6) & (g > b + 6) & (a.max(-1) > 90)
    if kind == "dark":
        return (a.max(-1) < 120) & (a.min(-1) > 10)
    if kind == "black":
        return a.max(-1) < 80
    if kind == "white":
        return a.min(-1) > 170
    if kind == "red":
        return (r > g + 60) & (r > b + 60)
    if kind == "silver":
        return (a.min(-1) > 130) & (a.max(-1) < 240) & (np.abs(r - b) < 18) & (np.abs(g - b) < 18)
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
