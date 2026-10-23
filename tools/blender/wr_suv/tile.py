# Tile review images into one sheet (wr-3d-suv quick look): py -I tile.py <out.png> <cols> <cell_w> <cell_h> <img[:label]>...
import sys
from PIL import Image, ImageDraw, ImageFont
out, cols, cw, ch = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
items = sys.argv[5:]
try:
    F = ImageFont.truetype("arial.ttf", 20)
except Exception:
    F = ImageFont.load_default()
rows = (len(items) + cols - 1) // cols
sheet = Image.new("RGB", (cols * cw, rows * (ch + 26)), (236, 236, 236))
d = ImageDraw.Draw(sheet)
for i, it in enumerate(items):
    p, _, lab = it.partition("::")
    im = Image.open(p).convert("RGBA")
    bg = Image.new("RGBA", im.size, (236, 236, 236, 255)); bg.alpha_composite(im); im = bg.convert("RGB")
    k = min(cw / im.width, ch / im.height)
    im = im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS)
    x, y = (i % cols) * cw, (i // cols) * (ch + 26)
    sheet.paste(im, (x + (cw - im.width) // 2, y + 26 + (ch - im.height) // 2))
    d.text((x + 6, y + 3), lab or p.split("/")[-1], fill=(40, 40, 40), font=F)
sheet.save(out)
