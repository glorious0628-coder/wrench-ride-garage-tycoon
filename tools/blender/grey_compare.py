# Grey shape sheet (pp-3d-make 10-20): concept cell | grey EEVEE | grey Workbench for each of the 6 views, plus the
# two 3/4 views, so the shape can be judged without colour.
#   py -I tools/blender/grey_compare.py <grey_views_dir> <concept_prefix> <out.png> [cell=360]
import sys
from PIL import Image, ImageDraw
gd, cp, outp = sys.argv[1:4]; C = int(sys.argv[4]) if len(sys.argv) > 4 else 360
N = ["front", "back", "left", "right", "top", "bottom"]


def cell(p):
    im = Image.open(p).convert("RGBA"); bg = Image.new("RGBA", im.size, (235, 235, 235, 255)); bg.alpha_composite(im)
    return bg.convert("RGB").resize((C, C), Image.LANCZOS)


s = Image.new("RGB", (C * 9, C * 2 + C), "white"); dr = ImageDraw.Draw(s)
for i, n in enumerate(N):
    x = (i % 3) * 3 * C; y = (i // 3) * C
    s.paste(cell(f"{cp}_{n}.png"), (x, y)); s.paste(cell(f"{gd}/eevee_{n}.png"), (x + C, y)); s.paste(cell(f"{gd}/wb_{n}.png"), (x + 2 * C, y))
    dr.text((x + 4, y + 4), n, fill=(90, 90, 90))
for i, n in enumerate(["eevee_threeq", "wb_threeq", "eevee_threeq_back", "wb_threeq_back"]):
    s.paste(cell(f"{gd}/{n}.png"), (i * C, 2 * C))
s.save(outp); print("ok", outp)
