"""Concept vs 3D, same scale (pp-3d-review 10-20, main 3rd caught missing size/colour checks on the alarm clock).
Crops each view of a 6-view concept sheet and the matching Blender render to their silhouettes, scales both to the same
height, and writes: side-by-side, a 50% overlay, and outline-on-outline (concept red, 3D blue) per view.
  py notes/design/3d_tools/concept_compare.py <concept_6view.png> <renders_dir> <out_dir>
renders_dir holds front/back/left/right/top/bottom.png (pp-3d-make's review/<ver>_renders/, transparent or plain bg).
Also prints the median colour of a few pixel probes you pass with --probe name:x,y (x,y in 0..1 of the front crop).
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

NAMES = ["front", "back", "left", "right", "top", "bottom"]
H = 600


def fg_mask(a):
    if a.shape[2] == 4 and (a[..., 3] < 250).any():
        return a[..., 3] > 40
    rgb = a[..., :3].astype(int)
    corner = np.median(np.concatenate([rgb[:8, :8].reshape(-1, 3), rgb[-8:, -8:].reshape(-1, 3)]), 0)
    return np.abs(rgb - corner).sum(2) > 40


def crop(img):
    a = np.asarray(img.convert("RGBA"))
    m = fg_mask(a)
    ys, xs = np.where(m)
    c = img.convert("RGBA").crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    mm = Image.fromarray((m[ys.min():ys.max() + 1, xs.min():xs.max() + 1] * 255).astype(np.uint8))
    return c, mm


def concept_cells(path):
    a = np.asarray(Image.open(path).convert("RGB"))
    fg = a.astype(int).min(2) < 235
    lab, n = ndimage.label(ndimage.binary_closing(fg, iterations=3))
    sizes = ndimage.sum(np.ones_like(lab), lab, range(1, n + 1))
    keep = [i + 1 for i, s in enumerate(sizes) if s > 0.02 * a.shape[0] * a.shape[1]]
    boxes = []
    for i in keep:
        ys, xs = np.where(lab == i)
        boxes.append((xs.min(), ys.min(), xs.max(), ys.max()))
    row_h = a.shape[0] // 2
    boxes.sort(key=lambda b: ((b[1] + b[3]) // 2 // row_h, b[0]))
    img = Image.open(path).convert("RGB")
    return {nm: img.crop((b[0], b[1], b[2] + 1, b[3] + 1)) for nm, b in zip(NAMES, boxes)}


def scaled(im, mask):
    s = H / im.height
    return im.resize((max(1, round(im.width * s)), H), Image.LANCZOS), mask.resize((max(1, round(im.width * s)), H))


def main():
    sheet, rdir, out = sys.argv[1], sys.argv[2], sys.argv[3]
    os.makedirs(out, exist_ok=True)
    cells = concept_cells(sheet)
    rows = []
    for nm in NAMES:
        rp = os.path.join(rdir, nm + ".png")
        if nm not in cells or not os.path.exists(rp):
            continue
        ci, cm = scaled(*crop(cells[nm]))
        ri, rm = scaled(*crop(Image.open(rp)))
        w = max(ci.width, ri.width)
        canvas = Image.new("RGB", (ci.width + ri.width + w * 2 + 60, H + 40), (240, 240, 240))
        canvas.paste(ci.convert("RGB"), (0, 40))
        canvas.paste(ri, (ci.width + 20, 40), ri)
        ov = Image.new("RGB", (w, H), (255, 255, 255))
        ov.paste(ci.convert("RGB"), ((w - ci.width) // 2, 0))
        r2 = Image.new("RGB", (w, H), (255, 255, 255))
        r2.paste(ri, ((w - ri.width) // 2, 0), ri)
        canvas.paste(Image.blend(ov, r2, 0.5), (ci.width + ri.width + 40, 40))
        ol = Image.new("RGB", (w, H), (255, 255, 255))
        for m, col, dx in ((cm, (230, 30, 30), (w - cm.width) // 2), (rm, (30, 60, 230), (w - rm.width) // 2)):
            e = np.asarray(m) > 127
            edge = e ^ ndimage.binary_erosion(e, iterations=2)
            ys, xs = np.where(edge)
            px = ol.load()
            for y, x in zip(ys, xs):
                if 0 <= x + dx < w:
                    px[x + dx, y] = col
        canvas.paste(ol, (ci.width + ri.width + w + 50, 40))
        d = ImageDraw.Draw(canvas)
        d.text((4, 4), f"{nm}: concept | 3D | 50% overlay | outlines (red concept, blue 3D)  concept w/h={cm.width/H:.3f} 3D w/h={rm.width/H:.3f}", fill=(0, 0, 0))
        canvas.save(os.path.join(out, f"cmp_{nm}.png"))
        rows.append((nm, cm.width / H, rm.width / H))
    for nm, a, b in rows:
        print(f"{nm}: width/height concept {a:.3f} vs 3D {b:.3f} ({(b / a - 1) * 100:+.1f}%)")


if __name__ == "__main__":
    main()
