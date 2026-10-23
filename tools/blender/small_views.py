# Game-size check (pp-3d-make 10-20): 3/4 front and 3/4 back renders at 64 and 96 px on grass green and dark night
# blue, shown x3 with nearest so the pixels are visible.   py -I tools/blender/small_views.py <render_dir> <out.png>
import sys
from PIL import Image
rd, outp = sys.argv[1:3]
rows = []
for bgc in ((90, 140, 90, 255), (30, 36, 60, 255)):
    row = Image.new("RGB", (2 * (192 + 288 + 30), 300), "white"); x = 0
    for n in ("threeq", "threeq_back"):
        im = Image.open(f"{rd}/{n}.png").convert("RGBA"); bg = Image.new("RGBA", im.size, bgc); bg.alpha_composite(im); bg = bg.convert("RGB")
        row.paste(bg.resize((64, 64), Image.LANCZOS).resize((192, 192), Image.NEAREST), (x, 0)); x += 202
        row.paste(bg.resize((96, 96), Image.LANCZOS).resize((288, 288), Image.NEAREST), (x, 0)); x += 308
    rows.append(row)
s = Image.new("RGB", (rows[0].width, 600), "white"); s.paste(rows[0], (0, 0)); s.paste(rows[1], (0, 300)); s.save(outp); print("ok", outp)
