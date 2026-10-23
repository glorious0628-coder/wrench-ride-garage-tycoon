# Review sheets for the engine bay + underbody decor pass (wr-3d-body, 10-21).
#   py -I tools/blender/wr_body/bay_under_sheets.py <art/3d/sedan_body> <bay concept png>
# reads work/under/{c_bay,g_bay,g_bay2x,c_under,g_under}, work/B/{col_r,before_fix}, work/concept/sedan_bottom.png
# writes review/sedan_bay_*.png, review/sedan_under_*.png, review/sedan_mirror_rough_before_after.png
import os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT, BAYC = sys.argv[1], sys.argv[2]
U = os.path.join(ROOT, "work", "under"); RV = os.path.join(ROOT, "review"); os.makedirs(RV, exist_ok=True)
FONT = next((f for f in ("C:/Windows/Fonts/malgun.ttf", "malgun.ttf", "arial.ttf") if os.path.exists(f) or "/" not in f), "arial.ttf")
try:
    F = ImageFont.truetype(FONT, 28); FS = ImageFont.truetype(FONT, 20)
except Exception:
    F = FS = ImageFont.load_default()
BG = (236, 236, 236)


def flat(p, bg=BG):
    im = Image.open(p).convert("RGBA"); b = Image.new("RGBA", im.size, bg + (255,)); b.alpha_composite(im)
    return b.convert("RGB")


def fit(im, w, h):
    k = min(w / im.width, h / im.height)
    return im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS)


def sheet(cells, cols, cw, ch, title, out, pad=14):
    rows = (len(cells) + cols - 1) // cols
    o = Image.new("RGB", (cols * (cw + pad) + pad, rows * (ch + pad + 34) + 64), "white")
    d = ImageDraw.Draw(o); d.text((pad, 16), title, fill=(0, 0, 0), font=F)
    for i, (im, lab) in enumerate(cells):
        im = fit(im, cw, ch); x = pad + (i % cols) * (cw + pad); y = 64 + (i // cols) * (ch + pad + 34)
        o.paste(im, (x + (cw - im.width) // 2, y + 30)); d.text((x, y + 2), lab, fill=(40, 40, 40), font=FS)
    o.save(os.path.join(RV, out)); print("ok", out)


def crop_alpha(p, pad=10):
    im = Image.open(p).convert("RGBA"); A = np.asarray(im)
    a = (A[..., 3] > 10) & (A[..., :3].min(-1) < 235)       # alpha, or non-white on a white-backed concept cell
    ys, xs = np.where(a)
    return im.crop((max(0, xs.min() - pad), max(0, ys.min() - pad), xs.max() + pad, ys.max() + pad))


j = lambda *a: os.path.join(*a)
# ---- engine bay: concept vs colour, grey, 3/4 with the hood on the prop
bc = Image.open(BAYC).convert("RGB")
sheet([(bc, "시안 (sedan_enginebay_top)"), (flat(j(U, "c_bay", "bay_top.png")), "3D 색 (보닛 받침대 57.8°, 배터리·라디에이터 = 실제 부품)"),
       (flat(j(U, "g_bay", "bay_top.png")), "3D 회색"), (flat(j(U, "c_bay", "bay_34.png")), "3D 색 3/4 (받침대가 보닛 앞 오른쪽을 받침)")],
      2, 900, 600, "엔진룸 장식: 시안 vs 3D (위에서, 같은 화각)", "sedan_bay_colour_vs_concept.png")
# overlay: concept + 3D outline (blue) / 50 % blend
g = Image.open(j(U, "g_bay", "bay_top.png")).convert("RGBA").resize(bc.size)
edge = g.convert("L").filter(ImageFilter.FIND_EDGES).point(lambda v: 255 if v > 40 else 0)
ov = bc.copy(); blue = Image.new("RGB", bc.size, (0, 90, 255)); ov.paste(blue, (0, 0), edge)
bl = Image.blend(bc, flat(j(U, "c_bay", "bay_top.png")).resize(bc.size), 0.5)
sheet([(ov, "시안 + 3D 윤곽선(파랑)"), (bl, "시안 50 % + 3D 색 50 %")], 2, 900, 600, "엔진룸 위 뷰 겹침", "sedan_bay_overlay.png")
# 2x grey zoom crops (render at 2x: 3072 x 2048)
p2 = j(U, "g_bay2x", "bay_top2x.png")
if os.path.exists(p2):
    z = flat(p2); W_, H_ = z.size
    boxes = [("운전석 쪽: 에어박스·배터리 자리·퓨즈박스·부스터", (int(W_ * 0.56), int(H_ * 0.10), int(W_ * 0.92), int(H_ * 0.62))),
             ("엔진 위: 코일 4·엔진 커버·오일 캡·딥스틱·흡기", (int(W_ * 0.30), int(H_ * 0.12), int(W_ * 0.66), int(H_ * 0.64))),
             ("조수석 쪽: 냉각수·워셔 통·발전기·벨트·받침대", (int(W_ * 0.06), int(H_ * 0.10), int(W_ * 0.42), int(H_ * 0.62)))]
    sheet([(z.crop(b), t) for t, b in boxes], 3, 700, 600, "엔진룸 회색 2배 점검", "sedan_bay_grey2x.png")
# ---- underbody: lift 'Under' views (eye 1.4 below the car's ground plane)
cells = [(flat(j(U, "c_under", v + ".png")), lab) for v, lab in
         (("under_front", "앞 하체 (올려다봄): 오일팬·서브프레임·L 팔·랙·구동축"), ("under_rear", "뒤 하체: 연료탱크·뒤 서브프레임·링크·머플러 자리"),
          ("under_side", "옆에서 올려다봄: 언더커버·터널 배기·열 차단판"))]
bot = flat(j(U, "c_under", "bottom.png")).rotate(90, expand=True)
sheet(cells + [(bot, "아래 정면 (앞 = 왼쪽)")], 2, 900, 620, "하체 장식 — 리프트 Under 높이에서 (색; 스트럿·스프링·쇼바 = 검토용 자리표시)",
      "sedan_under_lift_colour.png")
cells = [(flat(j(U, "g_under", v + ".png")), v) for v in ("under_front", "under_rear", "under_side")]
sheet(cells + [(flat(j(U, "g_under", "bottom.png")).rotate(90, expand=True), "bottom")], 2, 900, 620, "하체 장식 — 회색", "sedan_under_lift_grey.png")
# bottom vs concept bottom cell: same car length, side by side + 50 % blend
cb = crop_alpha(j(ROOT, "work", "concept", "sedan_bottom.png"), 0)
mb = crop_alpha(j(U, "c_under", "bottom.png"), 0)
cbf = Image.new("RGBA", cb.size, BG + (255,)); cbf.alpha_composite(cb); cbf = cbf.convert("RGB")
mbf = Image.new("RGBA", mb.size, BG + (255,)); mbf.alpha_composite(mb); mbf = mbf.convert("RGB")
H = 1100; cbf = cbf.resize((int(cbf.width * H / cbf.height), H), Image.LANCZOS); mbf = mbf.resize((int(mbf.width * H / mbf.height), H), Image.LANCZOS)
blend = Image.blend(cbf.resize(mbf.size, Image.LANCZOS), mbf, 0.5)
sheet([(cbf, "시안 아래 뷰"), (mbf, "3D 아래 뷰 (색)"), (blend, "겹침 50 % (시안을 3D 길이·폭에 맞춤)")], 3, 520, 1100,
      "하체: 6면 시안 아래 칸 vs 3D", "sedan_under_vs_concept.png")
# ---- mirror + paint roughness: before / after (one small picture)
B = j(ROOT, "work", "B")
bf, af = flat(j(B, "before_fix", "threeq_fl_before.png")), flat(j(B, "col_r", "threeq_fl.png"))
box = (int(bf.width * 0.16), int(bf.height * 0.20), int(bf.width * 0.50), int(bf.height * 0.62))
zb = (int(bf.width * 0.265), int(bf.height * 0.33), int(bf.width * 0.345), int(bf.height * 0.44))      # mirror, 3x
o = Image.new("RGB", (2 * 560 + 42, 470 + 290), "white"); d = ImageDraw.Draw(o)
for i, (im, t) in enumerate(((bf, "전: 거울 작음, 거칠기 0.30"), (af, "후: 거울 키움 + 검정 받침, 거칠기 0.40"))):
    c = fit(im.crop(box), 560, 420); o.paste(c, (14 + i * 574, 44)); d.text((14 + i * 574, 10), t, fill=(0, 0, 0), font=FS)
    z = im.crop(zb); z = z.resize((z.width * 3, z.height * 3), Image.LANCZOS); z = fit(z, 560, 280)
    o.paste(z, (14 + i * 574 + (560 - z.width) // 2, 474))
o.save(j(RV, "sedan_mirror_rough_before_after.png")); print("ok before/after")
