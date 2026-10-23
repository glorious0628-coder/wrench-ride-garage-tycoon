# Put a GLB's review renders next to its 6-view concept (pp-3d-make 10-20). Layout like the concept sheet:
# top row front, back, left; bottom row right, top, bottom; plus a 3/4 row. Concept cells come from the split views.
#   py -I tools/blender/sheet_compare.py <render_dir> <concept_prefix e.g. ComfyUI/input/flashy_sneaker> <out.png> [cell=400]
import sys
from PIL import Image, ImageDraw
rd, cp, outp = sys.argv[1:4]
C = int(sys.argv[4]) if len(sys.argv) > 4 else 400
names = ["front", "back", "left", "right", "top", "bottom"]


def cell(path):
    im = Image.open(path).convert("RGBA"); bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
    bg.alpha_composite(im); return bg.convert("RGB").resize((C, C), Image.LANCZOS)


sheet = Image.new("RGB", (C * 6, C * 2 + C + 30), "white"); dr = ImageDraw.Draw(sheet)
for i, n in enumerate(names):
    x = (i % 3) * 2 * C; y = (i // 3) * C
    sheet.paste(cell(f"{cp}_{n}.png"), (x, y)); sheet.paste(cell(f"{rd}/{n}.png"), (x + C, y))
    dr.text((x + 4, y + 4), n + " concept", fill=(120, 120, 120)); dr.text((x + C + 4, y + 4), n + " 3D", fill=(200, 0, 0))
for i, n in enumerate(["threeq", "threeq_back"]):
    sheet.paste(cell(f"{rd}/{n}.png"), (i * C, 2 * C + 30))
sheet.save(outp); print("ok", outp)
