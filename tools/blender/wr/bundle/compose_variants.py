# Colour-variant sheet: all <label>_q.png of the given groups, one block per car type, 9 per row.
#   python -I compose_variants.py <var_dir> <out.png> <group_prefix,group_prefix,...> [picks.json]
# group_prefix e.g. "v_Car_18_" ; picks.json {"v_Car_18_C": "pick"} draws a green frame.
import sys, os, json
from PIL import Image, ImageDraw, ImageFont

vd, outp, groups = sys.argv[1], sys.argv[2], sys.argv[3].split(",")
picks = json.load(open(sys.argv[4], encoding="utf-8")) if len(sys.argv) > 4 else {}
try:
    F = ImageFont.truetype("arialbd.ttf", 18); FK = ImageFont.truetype("malgun.ttf", 16)
except OSError:
    F = FK = ImageFont.load_default()
files = sorted(f for f in os.listdir(vd) if f.endswith("_q.png"))
blocks = []
PER = 9
for g in groups:
    fs = [f for f in files if f.startswith(g)]
    if not fs:
        continue
    ims = [Image.open(os.path.join(vd, f)).convert("RGB") for f in fs]
    w, h = ims[0].size
    rows = (len(ims) + PER - 1) // PER
    b = Image.new("RGB", (PER * w, 30 + rows * (h + 22)), (255, 255, 255)); d = ImageDraw.Draw(b)
    d.text((6, 4), g[2:].rstrip("_"), fill=(0, 0, 0), font=F)
    for i, (f, im) in enumerate(zip(fs, ims)):
        x, y = (i % PER) * w, 30 + (i // PER) * (h + 22)
        b.paste(im, (x, y + 22)); lb = f[:-6]
        d.text((x + 4, y + 2), lb[len(g):], fill=(0, 0, 0), font=F)
        if lb in picks:
            d.rectangle([x + 1, y + 1, x + w - 2, y + h + 20], outline=(20, 150, 60), width=5)
            d.text((x + 40, y + 2), picks[lb], fill=(20, 150, 60), font=FK)
    blocks.append(b)
W = max(b.width for b in blocks); H = sum(b.height + 8 for b in blocks)
sheet = Image.new("RGB", (W, H), (200, 200, 205)); y = 0
for b in blocks:
    sheet.paste(b, (0, y)); y += b.height + 8
sheet.save(outp); print(outp, sheet.size)
