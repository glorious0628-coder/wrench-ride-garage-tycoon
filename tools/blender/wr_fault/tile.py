# Quick labelled tiling of review images (wr-3d helper 10-21). Transparent PNGs go on a light grey background.
#   py -I tile.py <out.png> <cols> <cell_px|0 = keep size> [--title "text"] label=path [label=path ...]
# cell_px > 0: every image is fitted into a cell_px square; 0: images keep their pixel size (same-scale sheets).
import sys
from PIL import Image, ImageDraw, ImageFont

a = sys.argv[1:]
out, cols, cell = a[0], int(a[1]), int(a[2]); rest = a[3:]
title = None
if rest and rest[0] == "--title":
    title = rest[1]; rest = rest[2:]
try:
    F = ImageFont.truetype("arial.ttf", 18); FT = ImageFont.truetype("arial.ttf", 22)
except Exception:
    F = FT = ImageFont.load_default()
items = []
for s in rest:
    lab, p = s.split("=", 1)
    im = Image.open(p).convert("RGBA"); bg = Image.new("RGBA", im.size, (236, 236, 236, 255)); bg.alpha_composite(im)
    im = bg.convert("RGB")
    if cell > 0:
        k = min(cell / im.width, cell / im.height); im = im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS)
    items.append((lab, im))
rows = [items[i:i + cols] for i in range(0, len(items), cols)]
cw = [max(r[j][1].width for r in rows if j < len(r)) for j in range(cols)]
rh = [max(im.height for _, im in r) + 26 for r in rows]
top = 36 if title else 0
S = Image.new("RGB", (sum(cw) + 10 * (cols + 1), sum(rh) + 10 * (len(rows) + 1) + top), "white"); d = ImageDraw.Draw(S)
if title:
    d.text((10, 8), title, fill=(0, 0, 0), font=FT)
y = top + 10
for r, h in zip(rows, rh):
    x = 10
    for j, (lab, im) in enumerate(r):
        d.text((x + 2, y), lab, fill=(50, 50, 50), font=F)
        S.paste(im, (x, y + 24))
        x += cw[j] + 10
    y += h + 10
S.save(out); print("ok", out, S.size)
