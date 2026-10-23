# Check sheets for the street props from render_props.py output + street_props_stats.json.
#   python -I compose_sheets.py <render dir> <art/3d/street_props dir>
# -> _check/props_sheet.png (9 x 3/4 view, name, height stud, triangles), _check/props_before_after.png
#    (mailbox + fire escape, pack vs ours), _check/props_size_r15.png (lineup with an R15-size box, ortho + player view)
import sys, os, json
from PIL import Image, ImageDraw, ImageFont

rd, od = sys.argv[1], sys.argv[2]
ck = os.path.join(od, "_check"); os.makedirs(ck, exist_ok=True)
stats = json.load(open(os.path.join(od, "street_props_stats.json"), encoding="utf-8"))
ORDER = ["Prop_Hydrant", "Prop_Hydrant_Blue", "Prop_Cone", "Prop_Mailbox", "Prop_Trashbag", "Prop_FireEscapeStair", "Prop_Tire", "Prop_GasCan",
         "Prop_ParkBin_1", "Prop_ParkBin_2"]


def font(sz, bold=False):
    for f in (("malgunbd.ttf" if bold else "malgun.ttf"), "arial.ttf"):
        try:
            return ImageFont.truetype(os.path.join("C:/Windows/Fonts", f), sz)
        except OSError:
            pass
    return ImageFont.load_default()


F1, F2, F3 = font(26, True), font(21), font(34, True)


def tile(path, size):
    return Image.open(path).convert("RGB").resize((size, size), Image.LANCZOS)


# 1) props sheet
C = 420; LAB = 92; cols = 5
sheet = Image.new("RGB", (cols * C, ((len(ORDER) + cols - 1) // cols) * (C + LAB) + 70), (255, 255, 255)); d = ImageDraw.Draw(sheet)
d.text((14, 16), "Street props (Cartoon City CC0 -> ours)  |  3/4 view from front-left  |  1 stud = 0.28 m", fill=(20, 20, 20), font=F1)
for i, n in enumerate(ORDER):
    x, y = (i % cols) * C, 70 + (i // cols) * (C + LAB)
    sheet.paste(tile(os.path.join(rd, n + "_q34.png"), C - 8), (x + 4, y + 4))
    s = stats[n]
    tri = f"{s['tris']:,} tri" + (f"  (pack {s['tris_src']:,} + back-face copies {s['backface_copies']})" if s["backface_copies"] else "")
    if s.get("mailbox_edit"):
        tri = f"{s['tris']:,} tri  (pack {s['tris_src']} + hood {s['mailbox_edit']['hood_tris_added']} + back {s['backface_copies']})"
    d.text((x + 10, y + C + 4), n, fill=(0, 0, 0), font=F1)
    d.text((x + 10, y + C + 36), f"H {s['height_stud']:.2f} stud   W {s['size_stud_xyz'][0]:.2f} x D {s['size_stud_xyz'][2]:.2f}", fill=(60, 60, 60), font=F2)
    d.text((x + 10, y + C + 62), tri, fill=(60, 60, 60), font=F2)
sheet.save(os.path.join(ck, "props_sheet.png"))

# 2) before / after
T = 330
rows = [("Prop_Mailbox", ["q34", "front", "side"], "우편함: 파란 둥근 지붕(USPS 느낌) → 올리브 녹색(1909~1955 미국 우체통) + 짙은 회색 납작 뚜껑, 앞 투입구 + 비 가림"),
        ("Prop_FireEscapeStair", ["q34", "back34", "side"], "비상계단: 갈색(나무처럼 보임) → 어두운 철색 #3A3D42 (금속 0.3 · 거칠기 0.6)")]
ba = Image.new("RGB", (6 * T + 40, len(rows) * (T + 110) + 20), (255, 255, 255)); d = ImageDraw.Draw(ba)
for r, (n, views, caption) in enumerate(rows):
    y = 20 + r * (T + 110)
    d.text((14, y), caption, fill=(0, 0, 0), font=F1)
    d.text((14, y + 36), "전 (팩 원본, 같은 배율)", fill=(150, 40, 40), font=F2)
    d.text((3 * T + 54, y + 36), "후 (우리 GLB)", fill=(30, 110, 60), font=F2)
    for k, v in enumerate(views):
        ba.paste(tile(os.path.join(rd, n + "_src_" + v + ".png"), T - 6), (k * T + 3, y + 70))
        ba.paste(tile(os.path.join(rd, n + "_" + v + ".png"), T - 6), (3 * T + 40 + k * T + 3, y + 70))
    d.line([(3 * T + 20, y + 70), (3 * T + 20, y + 70 + T)], fill=(120, 120, 120), width=3)
ba.save(os.path.join(ck, "props_before_after.png"))

# 3) size vs R15 box
L = json.load(open(os.path.join(rd, "lineup.json"), encoding="utf-8"))
a = Image.open(os.path.join(rd, "lineup.png")).convert("RGB"); W, H = a.size
ppu = W / L["ortho_scale"]
d = ImageDraw.Draw(a)
for p in L["placed"]:
    px = W / 2 + (L["cam_x"] - p["cx"]) * ppu
    py = H / 2 - (p["h"] - L["cam_z"]) * ppu
    nm = p["name"].replace("Prop_", "")
    for k, t in enumerate((nm, f"{p['h']:.1f}")):
        tw = d.textlength(t, font=F2)
        yy = py - 58 + k * 26
        d.rectangle([px - tw / 2 - 4, yy - 1, px + tw / 2 + 4, yy + 24], fill=(255, 255, 255))
        d.text((px - tw / 2, yy), t, fill=(0, 0, 0), font=F2)
def caption(dr, xy, t):
    tw = dr.textlength(t, font=F1); dr.rectangle([xy[0] - 6, xy[1] - 2, xy[0] + tw + 6, xy[1] + 34], fill=(255, 255, 255)); dr.text(xy, t, fill=(0, 0, 0), font=F1)


caption(d, (14, 10), "정면(직교) — 벽 줄 = 1 stud, 굵은 줄 = 5 · 10 stud.  왼쪽 상자 = R15 사람 크기(2 x 5 x 1 stud)")
b = Image.open(os.path.join(rd, "lineup_persp.png")).convert("RGB")
out = Image.new("RGB", (W, H + b.size[1] + 10), (255, 255, 255)); out.paste(a, (0, 0)); out.paste(b, (0, H + 10))
d2 = ImageDraw.Draw(out)
caption(d2, (14, H + 20), "플레이어 눈높이(5 stud) · 세로 시야 70° 원근 (가장자리 상자가 기울어 보이는 건 넓은 시야 탓)")
out.save(os.path.join(ck, "props_size_r15.png"))
# 4) colour pass 2 (research note street_props.md): uploaded v1 -> v2, render dir of v1 = <render dir>1
r1 = rd.rstrip("/\\") + "1"
if os.path.isdir(r1):
    T = 300
    rows = [("우편함: 청록(1차) → 올리브 녹색 #5B6B34 (1909~1955 미국 우체통, 공식 값 없음 → 노트 추정 #4B5320을 조금 밝게)",
             [("1차", os.path.join(r1, "v1_Prop_Mailbox")), ("2차 Prop_Mailbox", os.path.join(rd, "Prop_Mailbox"))]),
            ("소화전: 빨강(팩) → NFPA 291: 몸통 크롬 옐로 #F4B000 + 보닛·노즐 캡 = 물 세기 등급색",
             [("1차", os.path.join(r1, "v1_Prop_Hydrant")), ("2차 Prop_Hydrant (초록 A 1,000~1,499 gpm)", os.path.join(rd, "Prop_Hydrant")),
              ("2차 Prop_Hydrant_Blue (연한 파랑 AA ≥1,500 gpm)", os.path.join(rd, "Prop_Hydrant_Blue"))])]
    views = ["q34", "front", "side"]
    sh = Image.new("RGB", (3 * 3 * T + 60, 2 * (T + 110) + 20), (255, 255, 255)); d = ImageDraw.Draw(sh)
    for r, (cap, cols_) in enumerate(rows):
        y = 20 + r * (T + 110)
        d.text((14, y), cap, fill=(0, 0, 0), font=F1)
        for j, (lab, base) in enumerate(cols_):
            x0 = j * (3 * T + 30)
            d.text((x0 + 14, y + 36), lab, fill=(150, 40, 40) if j == 0 else (30, 110, 60), font=F2)
            for k, v in enumerate(views):
                sh.paste(tile(base + "_" + v + ".png", T - 6), (x0 + k * T + 3, y + 70))
    sh.save(os.path.join(ck, "props_recolour_v2.png"))
print("sheets ok")
