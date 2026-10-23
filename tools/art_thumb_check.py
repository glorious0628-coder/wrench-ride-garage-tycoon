# wr-art check tool (not art, 10-21 thumbnails): original Play screenshot vs Codex redraw.
#   py -I tools/art_thumb_check.py <out_sheet.png> <original.png> <new.png>
# Sheet: top = original | new (960 wide each); bottom-left = edge overlay (original edges red, new edges cyan, both = white)
# bottom-right = new at store-card sizes (480x270, 256x144). Prints size, mean brightness/saturation (old -> new),
# edge match % and the 8x8 grid cells with the most new-only edges (= maybe something added).
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

out, a_path, b_path = sys.argv[1:4]
W, H = 960, 540
a = Image.open(a_path).convert("RGB")
b = Image.open(b_path).convert("RGB")
print("original %dx%d  new %dx%d  ratio %.4f" % (a.width, a.height, b.width, b.height, b.width / b.height))
a2, b2 = a.resize((W, H), Image.LANCZOS), b.resize((W, H), Image.LANCZOS)
ha, hb = (np.asarray(x.convert("HSV")).astype(float) for x in (a2, b2))
print("brightness %.0f%% -> %.0f%%   saturation %.0f%% -> %.0f%%" % (ha[..., 2].mean() / 2.55, hb[..., 2].mean() / 2.55,
                                                             ha[..., 1].mean() / 2.55, hb[..., 1].mean() / 2.55))


def edges(img):
    g = np.asarray(img.convert("L").filter(ImageFilter.GaussianBlur(1.2)).filter(ImageFilter.FIND_EDGES)).astype(float)
    return g > np.percentile(g, 88)


ea, eb = edges(a2), edges(b2)
# edge match with 4 px tolerance (dilate)
da = np.asarray(Image.fromarray((ea * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(9))) > 0
db = np.asarray(Image.fromarray((eb * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(9))) > 0
print("edges of original found in new (±4px): %.0f%%   edges of new found in original: %.0f%%"
      % (100 * (ea & db).sum() / ea.sum(), 100 * (eb & da).sum() / eb.sum()))
ov = np.zeros((H, W, 3), np.uint8) + 20
ov[ea] = (255, 60, 60)
ov[eb] = (60, 220, 255)
ov[ea & eb] = (255, 255, 255)
# grid of changed cells: new edges with no original edge nearby (= maybe an added thing)
cells = []
gy, gx = H // 8, W // 8
for j in range(8):
    for i in range(8):
        s = (slice(j * gy, (j + 1) * gy), slice(i * gx, (i + 1) * gx))
        n = eb[s].sum()
        extra = (eb[s] & ~da[s]).sum() / max(n, 1)
        cells.append((extra, i, j, n))
cells.sort(reverse=True)
print("cells with most NEW-only edges (col,row: % of new edges with no original edge near):",
      ", ".join("%d,%d:%.0f%%" % (i, j, 100 * e) for e, i, j, n in cells[:6] if n > 50))
sheet = Image.new("RGB", (W * 2 + 30, H * 2 + 70), (245, 245, 245))
d = ImageDraw.Draw(sheet)
sheet.paste(a2, (10, 30)); d.text((10, 10), "ORIGINAL (Play screenshot)", fill=(0, 0, 0))
sheet.paste(b2, (W + 20, 30)); d.text((W + 20, 10), "NEW (Codex)", fill=(0, 0, 0))
ovi = Image.fromarray(ov)
sheet.paste(ovi, (10, H + 60)); d.text((10, H + 40), "edges: red = original only, cyan = new only, white = both", fill=(0, 0, 0))
for e, i, j, n in cells[:6]:
    if n > 50 and e > 0.35:
        d.rectangle([10 + i * gx, H + 60 + j * gy, 10 + (i + 1) * gx, H + 60 + (j + 1) * gy], outline=(255, 200, 0), width=2)
sm = b.resize((480, 270), Image.LANCZOS)
xs = b.resize((256, 144), Image.LANCZOS)
sheet.paste(sm, (W + 20, H + 60)); d.text((W + 20, H + 40), "store size 480x270 / 256x144", fill=(0, 0, 0))
sheet.paste(xs, (W + 20 + 490, H + 60))
sheet.save(out)
print("sheet", out)
