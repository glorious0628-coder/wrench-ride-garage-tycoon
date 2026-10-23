# Concept vs grey 3D at SPEC scale (wr-3d-suv, 10-21; copied from wr_body/compare_body.py). Each concept cell (split 6-view) is stretched to the
# suv_spec box of that view (side 16.6 x 6.6, front/back 7.7 x 6.6 without mirrors, top/bottom 7.7 x 16.6) and laid
# on the render made by render_body.py (fixed px/stud frames). Writes per view: concept | 3D | 50% overlay | outlines
# (red concept, blue 3D), and one overlay sheet + a 6-view grey sheet in the concept layout.
#   py -I tools/blender/wr_suv/compare_suv.py <concept_prefix> <render_dir> <px_per_stud> <out_dir> [label]
# The top view is only for the layout of roof / glass / hood seams (it is drawn ~25-30% too narrow; stretched here).
import os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

cp, rd, PX, od = sys.argv[1], sys.argv[2], float(sys.argv[3]), sys.argv[4]
LABEL = sys.argv[5] if len(sys.argv) > 5 else ""
os.makedirs(od, exist_ok=True)
SPEC = dict(L=16.6, W=7.7, H=6.6, s0=-8.15, s1=8.45)
HL, HW, HH = 8.3, 3.85, 3.3
FRAME = {"left": (20, 10), "right": (20, 10), "front": (10, 10), "back": (10, 10), "top": (10, 20), "bottom": (10, 20)}
try:
    FONT = ImageFont.truetype("arial.ttf", 22)
except Exception:
    FONT = ImageFont.load_default()


def concept_box(name, a):
    m = a.min(2) < 235
    ys, xs = np.where(m)
    y0, y1, x0, x1 = ys.min(), ys.max(), xs.min(), xs.max()
    if name in ("front", "back"):            # body width without the mirrors: widest of the lower 45 % rows
        rows = range(int(y1 - 0.45 * (y1 - y0)), y1 - 4)
        w = [(np.where(m[r])[0].min(), np.where(m[r])[0].max()) for r in rows if m[r].any()]
        x0 = int(np.median([v[0] for v in w])); x1 = int(np.median([v[1] for v in w]))
    if name in ("top", "bottom"):            # body width without mirrors / tyres: median over rows away from them
        rows = [r for r in range(y0, y1) if m[r].any()]
        wid = np.array([np.where(m[r])[0].max() - np.where(m[r])[0].min() for r in rows])
        mid = [r for r, w in zip(rows, wid) if abs(w - np.median(wid)) < 4]
        x0 = int(np.median([np.where(m[r])[0].min() for r in mid])); x1 = int(np.median([np.where(m[r])[0].max() for r in mid]))
    return x0, y0, x1, y1


def spec_px(name, W, H):
    """pixel box of the spec box inside the render frame (u0, v0, u1, v1)"""
    if name in ("left", "right"):
        return W / 2 - HL * PX, H / 2 - HH * PX, W / 2 + HL * PX, H / 2 + HH * PX
    if name in ("front", "back"):
        return W / 2 - HW * PX, H / 2 - HH * PX, W / 2 + HW * PX, H / 2 + HH * PX
    return W / 2 - HW * PX, H / 2 - HL * PX, W / 2 + HW * PX, H / 2 + HL * PX


def edge(mask, it=2):
    return mask ^ ndimage.binary_erosion(mask, iterations=it)


rows = []
cells_c, cells_r = {}, {}
for name in ["front", "back", "left", "right", "top", "bottom"]:
    rp = os.path.join(rd, name + ".png")
    if not os.path.exists(rp):
        continue
    r = Image.open(rp).convert("RGBA"); W, H = r.size
    ca = np.asarray(Image.open(f"{cp}_{name}.png").convert("RGB"))
    x0, y0, x1, y1 = concept_box(name, ca)
    u0, v0, u1, v1 = spec_px(name, W, H)
    sx = (u1 - u0) / (x1 - x0 + 1); sy = (v1 - v0) / (y1 - y0 + 1)
    # whole concept cell scaled so its box lands on the spec box (mirrors / tyres outside the box keep the same scale)
    ci = Image.open(f"{cp}_{name}.png").convert("RGB")
    cw, ch = ci.size
    cs = ci.resize((max(1, int(round(cw * sx))), max(1, int(round(ch * sy)))), Image.LANCZOS)
    ox, oy = int(round(u0 - x0 * sx)), int(round(v0 - y0 * sy))
    cbg = Image.new("RGB", (W, H), "white"); cbg.paste(cs, (ox, oy))
    rbg = Image.new("RGBA", (W, H), (255, 255, 255, 255)); rbg.alpha_composite(r); rbg = rbg.convert("RGB")
    ov = Image.blend(cbg, rbg, 0.5)
    cm = np.asarray(cbg).min(2) < 235
    cm = ndimage.binary_fill_holes(ndimage.binary_closing(cm, iterations=2))
    rm = np.asarray(r)[..., 3] > 40
    ol = np.full((H, W, 3), 255, np.uint8)
    ol[edge(cm)] = (230, 30, 30); ol[edge(rm)] = (30, 60, 230)
    # spec box (thin grey)
    olim = Image.fromarray(ol); d = ImageDraw.Draw(olim); d.rectangle([u0, v0, u1, v1], outline=(170, 170, 170))
    # crop all to the spec box + margin
    m = int(0.9 * PX)
    box = (max(0, int(u0) - m), max(0, int(v0) - m), min(W, int(u1) + m), min(H, int(v1) + m))
    parts = [cbg.crop(box), rbg.crop(box), ov.crop(box), olim.crop(box)]
    w, h = parts[0].size
    if name in ("top", "bottom"):
        sheet = Image.new("RGB", (w * 4 + 30, h + 40), (235, 235, 235))
        for i, p in enumerate(parts):
            sheet.paste(p, (i * (w + 10), 40))
    else:
        sheet = Image.new("RGB", (w * 2 + 10, h * 2 + 50), (235, 235, 235))
        for i, p in enumerate(parts):
            sheet.paste(p, ((i % 2) * (w + 10), 40 + (i // 2) * (h + 10)))
    d = ImageDraw.Draw(sheet)
    d.text((6, 8), f"{LABEL} {name}: concept (stretched to spec box) | grey 3D | 50% | outlines red=concept blue=3D", fill=(0, 0, 0), font=FONT)
    sheet.save(os.path.join(od, f"spec_cmp_{name}.png"))
    # silhouette agreement inside the frame
    inter = (cm & rm).sum(); uni = (cm | rm).sum()
    rows.append((name, inter / max(uni, 1)))
    cells_c[name] = cbg.crop(box); cells_r[name] = rbg.crop(box)
for n, iou in rows:
    print(f"{n}: silhouette IoU concept(spec-stretched) vs 3D = {iou:.3f}")
import json
json.dump({n: round(float(i), 4) for n, i in rows}, open(os.path.join(od, "iou.json"), "w"), indent=1)


# 6-view sheets in the concept layout: top row front, back, left; bottom row right, top, bottom
def sheet6(cells, title, path):
    S = 520
    out = Image.new("RGB", (3 * S, 2 * S + 40), "white")
    d = ImageDraw.Draw(out); d.text((8, 8), title, fill=(0, 0, 0), font=FONT)
    for i, n in enumerate(["front", "back", "left", "right", "top", "bottom"]):
        if n not in cells:
            continue
        im = cells[n]; k = min((S - 20) / im.width, (S - 20) / im.height)
        im = im.resize((int(im.width * k), int(im.height * k)), Image.LANCZOS)
        out.paste(im, ((i % 3) * S + (S - im.width) // 2, 40 + (i // 3) * S + (S - im.height) // 2))
        d.text(((i % 3) * S + 8, 44 + (i // 3) * S), n, fill=(120, 120, 120), font=FONT)
    out.save(path)
    return out


a = sheet6(cells_c, "SUV concept 6-view (stretched to suv_spec box)", os.path.join(od, "_concept6.png"))
b = sheet6(cells_r, f"grey 3D {LABEL} (same scale)", os.path.join(od, "_grey6.png"))
both = Image.new("RGB", (a.width * 2 + 20, a.height), (220, 220, 220)); both.paste(a, (0, 0)); both.paste(b, (a.width + 20, 0))
both.save(os.path.join(od, "sheet_concept_vs_grey.png"))
print("ok", od)
