# wr-art-cars check tool (not art, 10-22 turn signals): old | new pairs + phone-size copies + amber pixel share.
#   py -I tools/art_signal_sheet.py <out.png> <spec.json>
#   spec = [{"label": "hatch A", "old": "a.png", "new": "b.png", "phone": 120, "zoom": [x0, y0, x1, y1]}, ...]
#   phone = car width in px on a phone (default 120; for 6-car sheets the whole sheet is scaled so one car is that wide: "cars_across": 3)
#   zoom  = optional fractional box (0..1) cropped from both pictures (front lamps), shown big.
import json
import sys
from PIL import Image, ImageDraw

H = 300          # height of the big old/new pictures
ZH = 220         # height of the zoom crops
GAP = 14


def amber_share(img):
    """share of pixels that look like an amber lens (hue ~20-45 deg, saturated, bright)"""
    hsv = img.convert("RGB").resize((img.width // 4, img.height // 4)).convert("HSV")
    n = hit = 0
    for h, s, v in hsv.getdata():
        if v > 40:
            n += 1
            if 14 <= h <= 32 and s > 150 and v > 170:   # PIL hue 0..255 -> 14..32 = 20..45 deg
                hit += 1
    return 100.0 * hit / max(n, 1)


def fit_h(img, h):
    return img.resize((max(1, int(img.width * h / img.height)), h), Image.LANCZOS)


def row(spec):
    a = Image.open(spec["old"]).convert("RGB")
    b = Image.open(spec["new"]).convert("RGB")
    across = spec.get("cars_across", 1)
    phone = spec.get("phone", 120)
    big = [fit_h(a, H), fit_h(b, H)]
    small = [x.resize((phone * across, max(1, int(x.height * phone * across / x.width))), Image.LANCZOS) for x in (a, b)]
    zooms = []
    if spec.get("zoom"):
        x0, y0, x1, y1 = spec["zoom"]
        for x in (a, b):
            zooms.append(fit_h(x.crop((int(x0 * x.width), int(y0 * x.height), int(x1 * x.width), int(y1 * x.height))), ZH))
    w = max(big[0].width + GAP + big[1].width, sum(z.width for z in zooms) + GAP * len(zooms), small[0].width + GAP + small[1].width) + 20
    h = 28 + H + GAP + max(s.height for s in small) + (GAP + ZH if zooms else 0) + 20
    r = Image.new("RGB", (w, h), "white")
    d = ImageDraw.Draw(r)
    if spec.get("amber", True):
        sa, sb = amber_share(a), amber_share(b)
        txt = f"OLD (left) amber {sa:.2f}%   |   NEW (right) amber {sb:.2f}%"
    else:   # yellow / orange paint counts as amber -> no number
        sa = sb = float("nan")
        txt = "OLD (left)   |   NEW (right)   (paint is yellow/orange: no amber number)"
    d.text((10, 6), f"{spec['label']}   {txt}   |   small row: car ~{phone}px wide (phone)", fill=(0, 0, 0))
    y = 28
    r.paste(big[0], (10, y)); r.paste(big[1], (10 + big[0].width + GAP, y))
    y += H + GAP
    r.paste(small[0], (10, y)); r.paste(small[1], (10 + small[0].width + GAP, y))
    y += max(s.height for s in small) + GAP
    x = 10
    for z in zooms:
        r.paste(z, (x, y)); x += z.width + GAP
    return r, sa, sb


def main():
    out, spec_file = sys.argv[1:3]
    specs = json.load(open(spec_file, encoding="utf-8"))
    rows = []
    for s in specs:
        r, sa, sb = row(s)
        rows.append(r)
        print(f"{s['label']}: amber old {sa:.2f}% -> new {sb:.2f}%")
    W = max(r.width for r in rows)
    sheet = Image.new("RGB", (W, sum(r.height + 6 for r in rows)), (235, 235, 235))
    y = 0
    for r in rows:
        sheet.paste(r, (0, y)); y += r.height + 6
    sheet.save(out)
    print(out, sheet.size)


if __name__ == "__main__":
    main()
