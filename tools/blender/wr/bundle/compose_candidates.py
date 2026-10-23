# Compose candidate cells (render_candidates.py output) into labelled grid sheets.
#   python -I compose_candidates.py <cand_dir> <out.png> <prefix> [cols=6] [scale=0.55] [marks.json] [start] [count]
# marks.json: {"label": ["X"|"OK"|"?", "short note"], ...}  -> red / green / orange tag + note under the name.
import sys, os, json
from PIL import Image, ImageDraw, ImageFont

cand, outp, prefix = sys.argv[1], sys.argv[2], sys.argv[3]
cols = int(sys.argv[4]) if len(sys.argv) > 4 else 6
sc = float(sys.argv[5]) if len(sys.argv) > 5 else 0.55
marks = json.load(open(sys.argv[6], encoding="utf-8")) if len(sys.argv) > 6 and sys.argv[6] not in ("", "-") else {}
start = int(sys.argv[7]) if len(sys.argv) > 7 else 0
count = int(sys.argv[8]) if len(sys.argv) > 8 else 999
try:
    F = ImageFont.truetype("arialbd.ttf", 22); FS = ImageFont.truetype("arial.ttf", 18)
    FK = ImageFont.truetype("malgun.ttf", 18)
except OSError:
    F = FS = FK = ImageFont.load_default()
stats = {}
for l in open(os.path.join(cand, "stats.jsonl"), encoding="utf-8"):
    d = json.loads(l); stats[d["label"]] = d
labels = [k for k in stats if k.startswith(prefix)][start:start + count]
CW, CH, LH = 700, 680, 70
cells = []
for lb in labels:
    c = Image.new("RGB", (CW, CH + LH), (255, 255, 255))
    q = Image.open(os.path.join(cand, lb + "_q.png")).convert("RGB")
    f = Image.open(os.path.join(cand, lb + "_f.png")).convert("RGB")
    s = Image.open(os.path.join(cand, lb + "_s.png")).convert("RGB")
    c.paste(q, ((CW - q.width) // 2, LH)); c.paste(f, (0, LH + 400)); c.paste(s, (280, LH + 400))
    d = ImageDraw.Draw(c); st = stats[lb]
    sx, sy, sz = st["size_xyz"]
    name = lb.split("_", 1)[1]
    d.text((8, 4), name, fill=(0, 0, 0), font=F)
    d.text((8, 32), "L %.2f W %.2f H %.2f m  %d tris" % (sy, sx, sz, st["tris"]), fill=(60, 60, 60), font=FS)
    if lb in marks:
        tag, note = marks[lb]
        col = {"X": (210, 30, 30), "OK": (20, 150, 60), "?": (230, 130, 0)}.get(tag, (0, 0, 0))
        d.rectangle([0, 0, CW - 1, CH + LH - 1], outline=col, width=8)
        tw = d.textlength(tag, font=F)
        d.rectangle([CW - tw - 24, 0, CW, 34], fill=col); d.text((CW - tw - 12, 4), tag, fill=(255, 255, 255), font=F)
        d.rectangle([8, CH + LH - 34, CW - 8, CH + LH - 6], fill=(255, 255, 255))
        d.text((14, CH + LH - 32), note, fill=col, font=FK)
    cells.append(c.resize((int(CW * sc), int((CH + LH) * sc)), Image.LANCZOS))
rows = (len(cells) + cols - 1) // cols
cw, ch = cells[0].size
sheet = Image.new("RGB", (cols * cw + (cols + 1) * 6, rows * ch + (rows + 1) * 6), (200, 200, 205))
for i, c in enumerate(cells):
    sheet.paste(c, (6 + (i % cols) * (cw + 6), 6 + (i // cols) * (ch + 6)))
sheet.save(outp)
print(outp, sheet.size, len(cells))
