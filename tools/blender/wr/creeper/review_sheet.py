# Creeper review sheet (3D helper 10-22): real photos (Bing image-search screenshots, art/3d/creeper_v1/work/ref) and the
# interior concept crop next to our renders (work/colour, work/review), plus the lying / standing R15 at the same scale.
#   py -I tools/blender/wr/creeper/review_sheet.py <creeper_v1 dir> <out.png> [info.json]
import sys, os, json
from PIL import Image, ImageDraw, ImageFont

D = os.path.abspath(sys.argv[1]); OUT = os.path.abspath(sys.argv[2])
REF, COL, REV = (os.path.join(D, "work", x) for x in ("ref", "colour", "review"))
info = json.load(open(os.path.join(D, "creeper_info.json"), encoding="utf-8"))
F = "C:/Windows/Fonts/malgun.ttf"; FB = "C:/Windows/Fonts/malgunbd.ttf"
f_t, f_h, f_c = ImageFont.truetype(FB, 34), ImageFont.truetype(FB, 24), ImageFont.truetype(F, 19)
W = 2400
canvas = Image.new("RGB", (W, 3000), "white"); dr = ImageDraw.Draw(canvas)


def trim(im, pad=12):
    im = im.convert("RGBA")
    bg = Image.new("RGBA", im.size, (255, 255, 255, 255)); bg.alpha_composite(im)
    rgb = bg.convert("RGB")
    inv = Image.eval(rgb.convert("L"), lambda v: 255 if v < 246 else 0)
    bb = inv.getbbox() or (0, 0, *rgb.size)
    bb = (max(bb[0] - pad, 0), max(bb[1] - pad, 0), min(bb[2] + pad, rgb.width), min(bb[3] + pad, rgb.height))
    return rgb.crop(bb)


def fit(im, w, h):
    s = min(w / im.width, h / im.height)
    return im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))), Image.LANCZOS)


def cell(im, x, y, w, h, cap, frame=True):
    t = fit(im, w, h)
    canvas.paste(t, (x + (w - t.width) // 2, y + (h - t.height) // 2))
    if frame:
        dr.rectangle((x, y, x + w, y + h), outline=(210, 210, 210), width=2)
    yy = y + h + 6
    for line in cap.split("\n"):
        dr.text((x, yy), line, font=f_c, fill=(40, 40, 40)); yy += 24


y = 20
dr.text((24, y), "누움판(Creeper) v1 — 실물 사진(Bing 이미지 검색 화면 스크린샷) · 목표 시안 ↔ 우리 3D", font=f_t, fill=(0, 0, 0)); y += 56
dr.text((24, y), f"Creeper.glb 한 메시 · 삼각형 {info['tris']:,} · 크기 {info['size_x_y_z_roblox'][0]} × {info['size_x_y_z_roblox'][1]} × "
        f"{info['size_x_y_z_roblox'][2]} stud (폭 × 높이 × 길이) = 0.52 × 0.17 × 1.06 m · 패드 윗면 {info['pad_top']} · 머리 받침 윗면 "
        f"{info['headrest_top']} · 바퀴 6개 지름 0.21", font=f_c, fill=(60, 60, 60)); y += 40

# ---- row 1: real photos + concept
dr.text((24, y), "① 실물 (특징만 섞음, 브랜드·로고 안 넣음)", font=f_h, fill=(150, 20, 20)); y += 38
b1 = Image.open(os.path.join(REF, "bing_01_padded_6caster.png")); b5 = Image.open(os.path.join(REF, "bing_05_steel_creeper_side.png"))
b4 = Image.open(os.path.join(REF, "bing_04_creeper_in_use.png"))
reals = [
    (b1.crop((8, 134, 215, 314)), "패드형 철제(Torin TR6452식)\n빨간 패드 + 검은 각관 프레임\n바퀴 6 · 머리 받침 따로"),
    (b1.crop((586, 134, 856, 314)), "패드 3조각 + 레일 끝 마개\n레일 아래 캐스터 판"),
    (b5.crop((8, 394, 186, 574)), "Whiteside 40in 패드형\n레일이 패드 옆, 바퀴 6"),
    (b1.crop((739, 646, 1050, 824)), "플라스틱 일체형(Big Red)\n빨간 몸통 + 검은 머리 받침"),
    (b4.crop((964, 134, 1234, 333)), "쓰는 모습: 머리~엉덩이가 판 위\n다리는 밖으로"),
]
cw, ch, x = 400, 300, 24
for im, cap in reals:
    cell(im, x, y, cw, ch, cap); x += cw + 22
cc = Image.open(os.path.join(REF, "concept_creeper_crop.png"))
cell(cc, x, y, 2400 - x - 24, ch, "목표 시안\n빨간 판·레일\n검은 머리 받침")
y += ch + 100

# ---- row 2: ours, colour
dr.text((24, y), "② 우리 3D (EEVEE, GLB 그대로: 색 base + ORM 1024)", font=f_h, fill=(20, 60, 150)); y += 38
ours = [
    (trim(Image.open(os.path.join(REV, "solo_q34.png"))), "3/4 — 빨간 각관 레일 2 + 가로대 3 + 검은 마개 4\n검은 판(하드보드) 위 빨간 비닐 패드 2조각 + 검은 머리 받침"),
    (trim(Image.open(os.path.join(REV, "lean_wall.png"))), "시안 자세(벽에 기대기, 머리 위,\n캐스터는 벽 쪽)"),
    (trim(Image.open(os.path.join(COL, "left.png"))), "옆 — 캐스터: 판 + 회전 링 + 포크(뒤로\n0.035 꼬리) + 축 + 검은 PU 바퀴·회색 허브"),
    (trim(Image.open(os.path.join(COL, "bottom.png"))), "밑 — 가로대 3 위 판, 바퀴는\n레일 아래 앞·가운데·뒤"),
]
widths = [760, 420, 700, 380]
x = 24
for (im, cap), w in zip(ours, widths):
    cell(im, x, y, w, 420, cap); x += w + 24
y += 420 + 80

# ---- row 3: same scale with R15
dr.text((24, y), "③ R15와 같은 축척 (1 stud = 0.28 m, 회색 블록 R15 = tools/blender/r15_preview.py)", font=f_h, fill=(20, 110, 40)); y += 38
r15 = [
    (trim(Image.open(os.path.join(REV, "r15_side.png"))), "누운 R15 옆(직교): 머리~엉덩이 + 허벅지 위 0.4가 판 위,\n다리는 밖 — 실제 쓰는 모습과 같음. 등 = 패드 윗면 0.49"),
    (trim(Image.open(os.path.join(REV, "solo_r15_standing.png"))), "선 R15(키 5.2) 옆: 길이 3.8 = 키의 73%\n(실제 1 m ÷ 1.75 m = 58%, R15가 짧고 굵어서)"),
    (trim(Image.open(os.path.join(REV, "underview_like.png")), 0), "UnderView 비슷한 카메라(CarParts Under_Rear:\n몸 옆 1.6, 바닥 + 1.0, 시야 60°) — 화면 아래에 레일·패드"),
]
widths = [900, 560, 820]
x = 24
for (im, cap), w in zip(r15, widths):
    cell(im, x, y, w, 420, cap); x += w + 24
y += 420 + 80
canvas = canvas.crop((0, 0, W, y))
canvas.save(OUT)
print("SHEET", OUT, canvas.size)
