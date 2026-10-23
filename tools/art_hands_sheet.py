# art_hands_sheet.py <out.png> <spec.json>
# Hands check sheet (main 10-22: "every picture with people gets a hands zoom check"): crops each person (both
# hands in view) from each picture, scales every crop to the same height and lays them out in one row per picture
# with a label - so each hand can be looked at one by one. spec.json = [{"file": "...", "label": "...",
# "boxes": [[x0, y0, x1, y1, "who"], ...]}, ...] in the picture's own pixels.
import json
import sys

from PIL import Image, ImageDraw

out, spec = sys.argv[1], json.load(open(sys.argv[2], encoding="utf-8"))
H, PAD, LAB = 240, 8, 16
rows = []
for item in spec:
    im = Image.open(item["file"]).convert("RGB")
    crops = []
    for x0, y0, x1, y1, who in item["boxes"]:
        c = im.crop((x0, y0, x1, y1))
        c = c.resize((max(1, int(c.width * H / c.height)), H), Image.LANCZOS)
        crops.append((c, who))
    rows.append((item["label"], crops))
W = max(sum(c.width + PAD for c, _ in crops) + PAD for _, crops in rows)
sheet = Image.new("RGB", (W, len(rows) * (H + LAB * 2 + PAD) + PAD), (28, 28, 28))
d = ImageDraw.Draw(sheet)
y = PAD
for label, crops in rows:
    d.text((PAD, y), label, fill=(255, 220, 0))
    x = PAD
    for c, who in crops:
        sheet.paste(c, (x, y + LAB))
        d.text((x, y + LAB + H + 2), who, fill=(220, 220, 220))
        x += c.width + PAD
    y += H + LAB * 2 + PAD
sheet.save(out)
print(out, sheet.size)
