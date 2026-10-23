# Paint colour A/B under the SAME light (wr-3d-suv, 10-21): concept cell vs renders of the slots blend recoloured with
# each candidate (render_suv.py mode keep:#hex), + rendered-paint medians vs the concept's paint medians.
#   py -I tools/blender/wr_suv/paint_compare_sheet.py <paintcmp_dir> <concept_prefix> <hero.png> <out.png> <hexA> <hexB>
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

D, CP, HERO, OUTP, A, B = sys.argv[1:7]
try:
    F = ImageFont.truetype("arial.ttf", 24); FS = ImageFont.truetype("arial.ttf", 19)
except Exception:
    F = FS = ImageFont.load_default()


def green_med(arr):
    q = arr.reshape(-1, arr.shape[-1]).astype(int)
    if q.shape[1] == 4:
        q = q[q[:, 3] > 200][:, :3]
    g = q[(q[:, 1] > q[:, 0] + 3) & (q[:, 1] > q[:, 2] + 3) & (q.max(1) > 60)]
    return np.median(g, 0)


def px(s, Y):
    return int(1000 + (s - 0.15) * 100), int(500 - (Y - 3.3) * 100)


rows = []
c_side = green_med(np.asarray(Image.open(f"{CP}_left.png").convert("RGB"))[335:400, 240:345])
c_face = green_med(np.asarray(Image.open(f"{CP}_front.png").convert("RGB"))[355:372, 290:410])
txt = [f"concept: side door {tuple(int(v) for v in c_side)}, front fascia {tuple(int(v) for v in c_face)} (6-view cells, even light)"]
res = {}
for h in (A, B):
    n = h.strip("#")
    x0, y0 = px(-2.5, 3.4); x1, y1 = px(-0.6, 2.3)
    side = green_med(np.asarray(Image.open(f"{D}/{n}/left.png").convert("RGBA"))[y0:y1, x0:x1])
    face = green_med(np.asarray(Image.open(f"{D}/{n}/front.png").convert("RGBA"))[530:545, 350:650])
    ds, df = float(np.linalg.norm(side - c_side)), float(np.linalg.norm(face - c_face))
    res[h] = (ds, df)
    txt.append(f"{h}: rendered side door {tuple(int(v) for v in side)} (diff {ds:.1f}), fascia {tuple(int(v) for v in face)} (diff {df:.1f})")


def flat(p, bg=(236, 236, 236)):
    im = Image.open(p).convert("RGBA"); b = Image.new("RGBA", im.size, bg + (255,)); b.alpha_composite(im)
    return b.convert("RGB")


def fit(im, w, h):
    k = min(w / im.width, h / im.height)
    return im.resize((int(im.width * k), int(im.height * k)), Image.LANCZOS)


cells = [(Image.open(HERO).convert("RGB"), "hero concept"), (flat(f"{D}/{A.strip('#')}/hero.png"), f"{A} (same light)"),
         (flat(f"{D}/{B.strip('#')}/hero.png"), f"{B} (same light)"),
         (Image.open(f"{CP}_left.png").convert("RGB").crop((50, 200, 650, 500)), "concept side cell"),
         (flat(f"{D}/{A.strip('#')}/left.png").crop((100, 150, 1900, 900)), f"{A} side"),
         (flat(f"{D}/{B.strip('#')}/left.png").crop((100, 150, 1900, 900)), f"{B} side")]
CW, CH = 900, 520
out = Image.new("RGB", (3 * (CW + 10) + 10, 2 * (CH + 36) + 70 + 30 * len(txt)), "white")
d = ImageDraw.Draw(out)
d.text((10, 12), "SUV paint: two candidates rendered with the SAME lights (review studio rig), next to the concept", fill=(0, 0, 0), font=F)
for i, (im, lab) in enumerate(cells):
    im = fit(im, CW, CH); x = 10 + (i % 3) * (CW + 10); y = 60 + (i // 3) * (CH + 36)
    out.paste(im, (x + (CW - im.width) // 2, y + 30)); d.text((x, y + 4), lab, fill=(60, 60, 60), font=FS)
y = 60 + 2 * (CH + 36) + 4
for t in txt:
    d.text((10, y), t, fill=(0, 0, 0), font=FS); y += 30
out.save(OUTP)
best = min(res, key=lambda k: sum(res[k]))
print("closer:", best, res)
