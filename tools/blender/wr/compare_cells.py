# Concept vs 3D overlay from already-split concept cells (wr-3d 10-21; tools/3d_check/concept_compare.py finds the views
# on the sheet with a 2 % area filter, so thin parts' side views get dropped and the names shift). Same output style:
# concept | 3D | 50 % overlay | outlines (red concept, blue 3D), both cropped to their silhouettes and scaled to the same height.
#   py -I tools/blender/wr/compare_cells.py <concept_prefix> <renders_dir> <out_dir>
import os, sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
NAMES = ["front", "back", "left", "right", "top", "bottom"]
H = 600


def fg_mask(a):
    if a.shape[2] == 4 and (a[..., 3] < 250).any():
        return a[..., 3] > 40
    return a[..., :3].astype(int).min(2) < 235


def crop(img):
    a = np.asarray(img.convert("RGBA")); m = fg_mask(a); ys, xs = np.where(m)
    return (img.convert("RGBA").crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)),
            Image.fromarray((m[ys.min():ys.max() + 1, xs.min():xs.max() + 1] * 255).astype(np.uint8)))


def scaled(im, m):
    s = H / im.height; w = max(1, round(im.width * s))
    return im.resize((w, H), Image.LANCZOS), m.resize((w, H))


cp, rd, out = sys.argv[1:4]; os.makedirs(out, exist_ok=True)
rows = []
for nm in NAMES:
    ci, cm = scaled(*crop(Image.open(f"{cp}_{nm}.png")))
    ri, rm = scaled(*crop(Image.open(os.path.join(rd, nm + ".png"))))
    w = max(ci.width, ri.width)
    canvas = Image.new("RGB", (ci.width + ri.width + w * 2 + 60, H + 40), (240, 240, 240))
    canvas.paste(ci.convert("RGB"), (0, 40)); canvas.paste(ri, (ci.width + 20, 40), ri)
    ov = Image.new("RGB", (w, H), "white"); ov.paste(ci.convert("RGB"), ((w - ci.width) // 2, 0))
    r2 = Image.new("RGB", (w, H), "white"); r2.paste(ri, ((w - ri.width) // 2, 0), ri)
    canvas.paste(Image.blend(ov, r2, 0.5), (ci.width + ri.width + 40, 40))
    ol = Image.new("RGB", (w, H), "white"); px = ol.load()
    for m, col in ((cm, (230, 30, 30)), (rm, (30, 60, 230))):
        e = np.asarray(m) > 127; edge = e ^ ndimage.binary_erosion(e, iterations=2); dx = (w - m.width) // 2
        for y, x in zip(*np.where(edge)):
            if 0 <= x + dx < w:
                px[x + dx, y] = col
    canvas.paste(ol, (ci.width + ri.width + w + 50, 40))
    ImageDraw.Draw(canvas).text((4, 4), f"{nm}: concept | 3D | 50% | outlines  concept w/h={cm.width / H:.3f} 3D w/h={rm.width / H:.3f}", fill=(0, 0, 0))
    canvas.save(os.path.join(out, f"cmp_{nm}.png")); rows.append((nm, cm.width / H, rm.width / H))
for nm, a, b in rows:
    print(f"{nm}: width/height concept {a:.3f} vs 3D {b:.3f} ({(b / a - 1) * 100:+.1f}%)")
ims = [Image.open(os.path.join(out, f"cmp_{n}.png")).convert("RGB") for n in NAMES]
W_ = 1800; rs = [im.resize((W_, int(im.height * W_ / im.width))) for im in ims]
sheet = Image.new("RGB", (W_, sum(r.height for r in rs)), "white"); y = 0
for r in rs:
    sheet.paste(r, (0, y)); y += r.height
sheet.save(os.path.join(out, "overlay_sheet.png"))
