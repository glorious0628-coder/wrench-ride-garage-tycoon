# Review sheet for the SUV front face 3rd pass (wr-3d-suv, 10-21): 2nd pass | 3rd pass | concept, front / hero-angle
# bumper / corner / 3/4, plus front-view area fractions (black, grey-silver, paint).
#   py -I tools/blender/wr_suv/review3_face_suv.py <art/3d/suv_body> <hero concept png>
# reads work/B/face_after (2nd pass, paint #8FA283), work/B/face_p3 (3rd pass), work/concept/suv_front.png
import os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT, HERO = sys.argv[1], sys.argv[2]
RV = os.path.join(ROOT, "review"); WB = os.path.join(ROOT, "work", "B"); CO = os.path.join(ROOT, "work", "concept")
j = os.path.join
FONT = next((f for f in ("C:/Windows/Fonts/malgun.ttf", "arial.ttf") if os.path.exists(f) or "/" not in f), "arial.ttf")
try:
    F = ImageFont.truetype(FONT, 28); FS = ImageFont.truetype(FONT, 20)
except Exception:
    F = FS = ImageFont.load_default()
BG = (236, 236, 236)


def flat(p):
    im = Image.open(p).convert("RGBA"); b = Image.new("RGBA", im.size, BG + (255,)); b.alpha_composite(im)
    return b.convert("RGB")


def fit(im, w, h):
    k = min(w / im.width, h / im.height)
    return im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS)


def cls(r, m):
    L = r[..., :3].mean(-1); g = (r[..., 1] > r[..., 0] + 6) & (r[..., 1] > r[..., 2] + 6)
    return tuple(round(float(v.sum()) / float(m.sum()), 2) for v in ((L < 80) & m & ~g, (~g) & (L >= 80) & m, g & m))


def frac_render(p, half, y0):
    a = np.asarray(Image.open(p).convert("RGBA")).astype(int)
    r = a[int(500 - (2.6 - 3.3) * 100):int(500 - (y0 - 3.3) * 100), int(500 - half * 100):int(500 + half * 100)]
    return cls(r, r[..., 3] > 200)


def frac_concept(half, y0):
    c = np.asarray(Image.open(j(CO, "suv_front.png")).convert("RGB")).astype(int)
    r = c[int(487 - 2.6 / 0.0239):int(487 - y0 / 0.0239), int(347.5 - half / 0.0257):int(347.5 + half / 0.0257)]
    return cls(r, r.min(-1) < 235)


A = {n: (frac_render(j(WB, "face_after", "front.png"), *k), frac_render(j(WB, "face_p3", "front.png"), *k), frac_concept(*k))
     for n, k in (("inner", (2.6, 0.85)), ("full", (3.8, 1.0)))}
hero = Image.open(HERO).convert("RGB")
cf = Image.open(j(CO, "suv_front.png")).convert("RGB").crop((150, 150, 550, 550))
rows = [("front", None, (cf, "시안 6면 앞 칸")),
        ("hero", (60, 560, 560, 1000), (hero.crop((30, 560, 720, 960)), "대표 시안 범퍼")),
        ("hero", (330, 600, 760, 1010), (hero.crop((480, 560, 760, 900)), "대표 시안 앞 모서리·램프")),
        ("threeq_low", (150, 380, 850, 800), (hero, "대표 시안"))]
cells = []
for v, crop, con in rows:
    for d_, lab in (("face_after", "2차"), ("face_p3", "3차")):
        im = flat(j(WB, d_, v + ".png"))
        cells.append((im.crop(crop) if crop else im, lab))
    cells.append(con)
CW, CH, pad = 760, 560, 14
foot = ["앞 뷰 면적 비율 (검정, 회색·은색, 도장) — 범퍼 가운데(|x|<2.6, Y 0.85~2.6): 2차 %s  3차 %s  시안 %s" % A["inner"],
        "                                    — 범퍼 전체(|x|<3.8, Y 1.0~2.6, 모서리 흡기구 포함): 2차 %s  3차 %s  시안 %s" % A["full"],
        "3차: 그릴 살 굵게(0.055→0.095)·밝게(#3A3B3E→#5A5C60), 안쪽 더 어둡게 / 그릴 1.44~2.26·틀 1.32~2.40 둥근 모서리 / 앞 범퍼 아래 1.00→0.88, 스키드 0.92~1.32",
        "앞 모서리: x 3.0 세로 꺾임선(날카롭게) 바깥을 최대 0.28 뒤로 접음 + 세로 흡기구(검정 솟은 틀 0.50×1.12, 살 3) / 램프: LED 모듈 칸 2개씩 + 바깥 끝 흰 띠가 아래로 꺾임(ㄱ)"]
o = Image.new("RGB", (3 * (CW + pad) + pad, 4 * (CH + pad + 34) + 64 + 30 * len(foot)), "white")
d = ImageDraw.Draw(o); d.text((pad, 16), "SUV 앞 얼굴 2차 → 3차 (도장 #8FA283 같은 조명) — 그릴 살·높이, 앞 모서리 꺾임 + 세로 흡기구, 램프 안쪽 구획", fill=(0, 0, 0), font=F)
for i, (im, lab) in enumerate(cells):
    im = fit(im, CW, CH); x = pad + (i % 3) * (CW + pad); y = 64 + (i // 3) * (CH + pad + 34)
    o.paste(im, (x + (CW - im.width) // 2, y + 30)); d.text((x, y + 2), lab, fill=(40, 40, 40), font=FS)
y = 64 + 4 * (CH + pad + 34)
for t in foot:
    d.text((pad, y), t, fill=(0, 0, 0), font=FS); y += 30
o.save(j(RV, "suv_B3_face_2_vs_3.png")); print("ok suv_B3_face_2_vs_3.png", A)
