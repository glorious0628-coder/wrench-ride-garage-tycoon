# Underbody decor colour codes measured on the 6-view bottom cell (art/3d/sedan_body/work/concept/sedan_bottom.png,
# 700 px, front up) (wr-3d-body, 10-21). Same rule as measure_bay_colours.py: part pixels (filter), 35-65 % band, median.
#   py -I tools/blender/wr_body/measure_under_colours.py <sedan_bottom.png> <out.json>
import sys, json
import numpy as np
from PIL import Image, ImageDraw
src, outp = sys.argv[1:3]
BOX = {
    "exhaust_pipe": [((345, 300, 357, 322), "bronze"), ((349, 250, 360, 320), "bronze")],
    "heat_shield": [((315, 325, 336, 392), "silver"), ((364, 325, 386, 392), "silver")],
    "undercover": [((280, 327, 307, 383), "black"), ((260, 262, 305, 318), "black")],
    "tunnel": [((327, 400, 337, 432), "black")],
    "fuel_tank": [((300, 447, 400, 493), "black")],
    "rear_subframe": [((300, 503, 400, 533), "black")],
    "front_subframe": [((310, 203, 400, 227), "black")],
    "front_arm": [((267, 193, 297, 213), "grey")],
    "rear_arm": [((263, 527, 297, 543), "grey")],
    "boot": [((290, 173, 310, 193), "black")],
    "spring": [((263, 123, 280, 167), "silver")],
    "engine_under": [((313, 137, 357, 173), "silver")],
    "muffler": [((290, 563, 407, 593), "silver")],
    "undertray_front": [((300, 80, 400, 97), "black")],
}


def filt(a, k):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]; mx = a.max(-1); mn = a.min(-1)
    return {"black": mx < 90, "silver": (mn > 110) & (mx - mn < 30), "grey": (mn > 55) & (mx - mn < 30) & (mx < 200),
            "bronze": (r > b + 15) & (mn > 70)}[k]


a0 = np.asarray(Image.open(src).convert("RGB")).astype(np.float32)
chk = Image.open(src).convert("RGB"); d = ImageDraw.Draw(chk)
res = {}
for part, boxes in BOX.items():
    P = []
    for (x0, y0, x1, y1), k in boxes:
        a = a0[y0:y1, x0:x1].reshape(-1, 3); P.append(a[filt(a, k)])
        d.rectangle([x0, y0, x1, y1], outline=(255, 0, 255))
    P = np.concatenate(P)
    if len(P) < 20:
        print(part, "too few px", len(P)); continue
    V = P.max(1); lo, hi = np.percentile(V, 35), np.percentile(V, 65)
    c = np.median(P[(V >= lo) & (V <= hi)], 0).round().astype(int)
    res[part] = dict(hex="#%02X%02X%02X" % tuple(c), px=int(len(P)))
    print(f"{part:>16}: {res[part]['hex']} ({len(P)} px)")
json.dump(res, open(outp, "w"), indent=1); chk.resize((1400, 1400)).save(outp.replace(".json", "_check.png")); print("ok")
