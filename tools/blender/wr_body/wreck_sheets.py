# Wreck review sheets (wr-3d-body, 10-21).   py -I tools/blender/wr_body/wreck_sheets.py <art/3d/sedan_body> <concept dir>
import os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT, CON = sys.argv[1], sys.argv[2]
WR = os.path.join(ROOT, "work", "wreck"); RV = os.path.join(ROOT, "review"); D = os.path.join(ROOT, "wreck")
FONT = "C:/Windows/Fonts/malgun.ttf" if os.path.exists("C:/Windows/Fonts/malgun.ttf") else "arial.ttf"
F = ImageFont.truetype(FONT, 28); FS = ImageFont.truetype(FONT, 20)
BG = (236, 236, 236)


def flat(p, bg=BG):
    im = Image.open(p).convert("RGBA"); b = Image.new("RGBA", im.size, bg + (255,)); b.alpha_composite(im); return b.convert("RGB")


def crop(im, pad=20):
    a = np.asarray(im.convert("RGB")).astype(int); m = (np.abs(a - np.array(BG)).sum(-1) > 12) & (a.min(-1) < 245)
    ys, xs = np.where(m)
    return im.crop((max(0, xs.min() - pad), max(0, ys.min() - pad), min(im.width, xs.max() + pad), min(im.height, ys.max() + pad)))


def fit(im, w, h):
    k = min(w / im.width, h / im.height); return im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS)


def sheet(cells, cols, cw, ch, title, out, pad=14):
    rows = (len(cells) + cols - 1) // cols
    o = Image.new("RGB", (cols * (cw + pad) + pad, rows * (ch + pad + 34) + 64), "white"); d = ImageDraw.Draw(o)
    d.text((pad, 16), title, fill=(0, 0, 0), font=F)
    for i, (im, lab) in enumerate(cells):
        im = fit(im, cw, ch); x = pad + (i % cols) * (cw + pad); y = 64 + (i // cols) * (ch + pad + 34)
        o.paste(im, (x + (cw - im.width) // 2, y + 30 + (ch - im.height) // 2)); d.text((x, y + 2), lab, fill=(40, 40, 40), font=FS)
    o.save(os.path.join(RV, out)); print("ok", out)


j = os.path.join
cf = Image.open(j(CON, "sedan_wreck_front.png")).convert("RGB"); cr = Image.open(j(CON, "sedan_wreck_rear.png")).convert("RGB")
sheet([(crop(cf), "시안 앞"), (crop(flat(j(WR, "r3", "threeq_fl.png"))), "3D 심함(3): 녹·벗겨진 클리어·먼지 + 찌그러진 범퍼 + 깨진 램프 + 펑크"),
       (crop(cr), "시안 뒤"), (crop(flat(j(WR, "r3", "threeq_rl.png"))), "3D 심함(3) 뒤: 트렁크 아래·뒤 범퍼 아래 녹")],
      2, 900, 620, "폐차 상태: 시안 vs 3D (도장 기본 파랑 + 단계별 바랜 색)", "sedan_wreck_vs_concept.png")
cells = []
for L, t in ((3, "3 심함"), (2, "2 중간"), (1, "1 가벼움"), (0, "0 새 차(복원 끝)")):
    cells.append((crop(flat(j(WR, "r%d" % L, "threeq_fl.png"))), t))
for L in (3, 2, 1, 0):
    cells.append((crop(flat(j(WR, "r%d" % L, "threeq_rl.png"))), ""))
sheet(cells, 4, 520, 360, "복원 단계별 오버레이 (단계가 겹쳐 있어 고칠수록 손상만 줄어듦; 3단계만 범퍼 찌그러짐·램프 깨짐·펑크 표시)",
      "sedan_wreck_levels.png")
crack = Image.open(j(D, "sedan_headlight_crack_L.png")).convert("RGBA"); cb = Image.new("RGBA", crack.size, (248, 247, 247, 255)); cb.alpha_composite(crack)
ov = Image.open(j(D, "sedan_shell_wreck3_color_overlay.png")).convert("RGBA")
chk = Image.new("RGBA", ov.size, (9, 143, 252, 255)); chk.alpha_composite(ov)
sheet([(flat(j(WR, "r3", "wreck_corner_fl.png")), "Bumper_F_Dented + HeadlightCrack_L"), (flat(j(WR, "r3", "tyre_fl.png")), "Tire_Flat (바닥 눌림 + 옆면 불룩)"),
       (cb.convert("RGB"), "깨진 헤드램프 텍스처 (흰 램프 위)"), (chk.convert("RGB").resize((1024, 1024)), "Shell 3단계 오버레이 (투명 = 도장색이 비침, 여기선 파랑)")],
      2, 900, 640, "폐차 부품: 찌그러진 앞 범퍼 · 펑크 타이어 · 깨진 헤드램프 · 오버레이", "sedan_wreck_parts.png")
# game-size check: 64 / 96 px, heavy level
rows = []
for bgc in ((90, 140, 90), (30, 36, 60)):
    row = Image.new("RGB", (2 * (192 + 288 + 30), 300), "white"); x = 0
    for n in ("threeq_fl", "threeq_rl"):
        ra = Image.open(j(WR, "r3", n + ".png")).convert("RGBA"); ys, xs = np.where(np.asarray(ra)[..., 3] > 10)
        im = flat(j(WR, "r3", n + ".png"), bgc).crop((xs.min() - 4, ys.min() - 4, xs.max() + 4, ys.max() + 4)); sq = Image.new("RGB", (max(im.size),) * 2, bgc); sq.paste(im, ((sq.width - im.width) // 2, (sq.height - im.height) // 2))
        row.paste(sq.resize((64, 64), Image.LANCZOS).resize((192, 192), Image.NEAREST), (x, 0)); x += 202
        row.paste(sq.resize((96, 96), Image.LANCZOS).resize((288, 288), Image.NEAREST), (x, 0)); x += 308
    rows.append(row)
s = Image.new("RGB", (rows[0].width, 600), "white"); s.paste(rows[0], (0, 0)); s.paste(rows[1], (0, 300)); s.save(j(RV, "sedan_wreck_small64_96.png"))
print("ok small")
# 3 -> 2 at game size (the step that removes the dent, the flat tyre and the cracked lamp): 3/4 front + rear at 96 / 160 px
cells = []
for n in ("threeq_fl", "threeq_rl"):
    for L in (3, 2):
        ra = Image.open(j(WR, "r%d" % L, n + ".png")).convert("RGBA"); ys, xs = np.where(np.asarray(ra)[..., 3] > 10)
        im = flat(j(WR, "r%d" % L, n + ".png"), (90, 140, 90)).crop((xs.min() - 4, ys.min() - 4, xs.max() + 4, ys.max() + 4))
        sq = Image.new("RGB", (max(im.size),) * 2, (90, 140, 90)); sq.paste(im, ((sq.width - im.width) // 2, (sq.height - im.height) // 2))
        cells.append((sq.resize((96, 96), Image.LANCZOS).resize((288, 288), Image.NEAREST), "%d단계 96px" % L))
        cells.append((sq.resize((160, 160), Image.LANCZOS).resize((320, 320), Image.NEAREST), "%d단계 160px" % L))
sheet(cells, 4, 320, 320, "게임 크기에서 3 → 2 (찌그러진 범퍼·펑크·깨진 램프가 빠지는 순간)", "sedan_wreck_3to2_small.png")
