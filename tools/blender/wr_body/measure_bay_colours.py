# Engine-bay decor colour codes measured on art/concepts/car_sedan/sedan_enginebay_top.png (wr-3d-body, 10-21).
# Same rule as part_colours.py: pixels of the part (filter), 35-65 % brightness band, median.
#   py -I tools/blender/wr_body/measure_bay_colours.py <enginebay.png> <out.json>
import sys, json
import numpy as np
from PIL import Image, ImageDraw
src, outp = sys.argv[1:3]
BOX = {
    "engine_cover": [((560, 380, 820, 430), "black")],
    "valve_cover": [((462, 285, 505, 345), "silver"), ((830, 285, 850, 340), "silver")],
    "coil": [((518, 300, 552, 340), "black"), ((605, 300, 640, 340), "black")],
    "heat_shield": [((600, 180, 790, 235), "silver")],
    "alternator": [((405, 405, 470, 480), "silver")],
    "intake_runner": [((560, 480, 820, 560), "black")],
    "throttle": [((865, 265, 925, 345), "silver")],
    "air_box": [((1100, 240, 1280, 380), "black")],
    "intake_hose": [((940, 360, 1000, 560), "black")],
    "fuse_box": [((1250, 400, 1320, 540), "black")],
    "booster": [((945, 145, 990, 215), "black")],
    "reservoir_white": [((1000, 200, 1050, 240), "white")],
    "cap_yellow": [((1008, 170, 1046, 196), "yellow"), ((622, 428, 650, 455), "yellow")],
    "coolant_tank": [((235, 290, 370, 375), "light")],
    "coolant_pink": [((240, 345, 365, 380), "pink")],
    "washer_white": [((215, 495, 300, 580), "white")],
    "cap_blue": [((235, 455, 292, 492), "blueish")],
    "strut_top": [((240, 150, 380, 230), "blue")],
    "hose": [((330, 450, 352, 560), "black"), ((950, 520, 1010, 560), "black")],
    "ac_pipe": [((322, 540, 385, 640), "silver")],
    "compressor": [((420, 520, 520, 610), "silver")],
    "belt": [((365, 400, 395, 560), "black")],
}


def filt(a, k):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]; mx = a.max(-1); mn = a.min(-1)
    return {"black": mx < 90, "silver": (mn > 110) & (mx - mn < 30), "white": mn > 200,
            "yellow": (r > 180) & (g > 150) & (b < 90), "light": mn > 150, "pink": (r > g + 15) & (r > 180),
            "blueish": (b > r + 60) & (b > 150), "blue": (b > r + 60) & (b > 150)}[k]


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
json.dump(res, open(outp, "w"), indent=1); chk.save(outp.replace(".json", "_check.png")); print("ok")
