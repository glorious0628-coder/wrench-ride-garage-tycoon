# Concept vs 3D at the SAME px-per-stud scale (no per-view resize), from art/3d/floor_jack/overlay_same_scale.py,
# generalised (wr-3d helper 10-21): any view mapping, anchor = bottom-centre ("base") or bbox centre ("center").
# Renders must be made at the concept's scale with part_views.py (transparent background).
#   py -I overlay.py <concept_prefix> <render_dir> <out_dir> <ppu> <label> [map] [anchor]
# map: "front=front,back=back,..." (concept view = render file stem); anchor: base | center | base_center (side views
# by the bottom, top/bottom views by the centre - default)
import os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

cp, rd, out, ppu, label = sys.argv[1:6]
MAP = dict(kv.split("=") for kv in sys.argv[6].split(",")) if len(sys.argv) > 6 and sys.argv[6] else {}
ANCH = sys.argv[7] if len(sys.argv) > 7 else "base_center"
os.makedirs(out, exist_ok=True)
NAMES = ["front", "back", "left", "right", "top", "bottom"]
try:
    F = ImageFont.truetype("arial.ttf", 16)
except Exception:
    F = ImageFont.load_default()


def mask_of(im, concept):
    a = np.asarray(im.convert("RGBA"))
    return (a[..., :3].astype(int).min(2) < 235) if concept else (a[..., 3] > 40)


def anchor(nm, m):
    ys, xs = np.where(m)
    if ANCH == "center" or (ANCH == "base_center" and nm in ("top", "bottom")):
        return (xs.min() + xs.max()) / 2, (ys.min() + ys.max()) / 2
    return (xs.min() + xs.max()) / 2, ys.max()


tiles = []
for nm in NAMES:
    rn = MAP.get(nm, nm)
    ci = Image.open(f"{cp}_{nm}.png").convert("RGB"); ri = Image.open(os.path.join(rd, rn + ".png")).convert("RGBA")
    cm, rm = mask_of(ci, True), mask_of(ri, False)
    ax, ay = anchor(nm, cm); bx, by = anchor(nm, rm)
    ox_r, oy_r = int(round(ax - bx)), int(round(ay - by))
    ys, xs = np.where(cm); cy0, cy1, cx0, cx1 = ys.min(), ys.max(), xs.min(), xs.max()
    ys, xs = np.where(rm); ry0, ry1, rx0, rx1 = ys.min() + oy_r, ys.max() + oy_r, xs.min() + ox_r, xs.max() + ox_r
    U = (min(cx0, rx0) - 12, min(cy0, ry0) - 12, max(cx1, rx1) + 12, max(cy1, ry1) + 12)
    w, h = U[2] - U[0], U[3] - U[1]
    con = Image.new("RGB", (w, h), "white"); con.paste(ci, (-U[0], -U[1]))
    mod = Image.new("RGB", (w, h), "white"); mod.paste(ri, (ox_r - U[0], oy_r - U[1]), ri)
    blend = Image.blend(con, mod, 0.5)
    ol = Image.new("RGB", (w, h), "white"); px = ol.load()
    for m, col, (dx, dy) in ((cm, (230, 30, 30), (-U[0], -U[1])), (rm, (30, 60, 230), (ox_r - U[0], oy_r - U[1]))):
        e = m ^ ndimage.binary_erosion(m, iterations=2)
        for y, x in zip(*np.where(e)):
            if 0 <= x + dx < w and 0 <= y + dy < h:
                px[x + dx, y + dy] = col
    # silhouette IoU on the shared canvas
    A = np.zeros((h, w), bool); Bm = np.zeros((h, w), bool)
    ys, xs = np.where(cm); A[ys - U[1], xs - U[0]] = True
    ys, xs = np.where(rm); yy, xx = ys + oy_r - U[1], xs + ox_r - U[0]; ok = (yy >= 0) & (yy < h) & (xx >= 0) & (xx < w); Bm[yy[ok], xx[ok]] = True
    iou = (A & Bm).sum() / max(1, (A | Bm).sum())
    t = Image.new("RGB", (w * 4 + 30, h + 26), (240, 240, 240))
    for i, im in enumerate((con, mod, blend, ol)):
        t.paste(im, (i * (w + 10), 26))
    ImageDraw.Draw(t).text((4, 5), f"{nm} (3D view '{rn}'): concept | 3D | 50% | outlines red concept / blue 3D - same scale {ppu} px/stud - IoU {iou:.2f} {label}",
                           fill=(0, 0, 0), font=F)
    t.save(os.path.join(out, f"cmp_{nm}.png")); tiles.append(t); print(nm, "IoU", round(iou, 3))
Wd = max(t.width for t in tiles)
sheet = Image.new("RGB", (Wd, sum(t.height for t in tiles) + 10 * len(tiles)), "white"); y = 0
for t in tiles:
    sheet.paste(t, (0, y)); y += t.height + 10
sheet.save(os.path.join(out, "overlay_sheet.png")); print("ok", sheet.size)
