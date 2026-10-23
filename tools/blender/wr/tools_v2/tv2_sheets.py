# Review sheets for the 2nd hand-tool batch (wr 3D helper 10-22) - plain PIL, no Blender.
#   py -I tv2_sheets.py            -> art/3d/tools_v2/work/<tool>/three_views.png, real_compare.png, hand_fit.png
#                                     art/3d/tools_v2/work/tools_v2_review_all.png (one picture, 5 rows) + tris_table.png
# Needs the renders of review_tool.sh (colour/, grey/), tv2_hand.py (hand_size.png) and tv2_fit.py (work/fit/*.png).
import os, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
T2 = os.path.join(ROOT, "art", "3d", "tools_v2"); WK = os.path.join(T2, "work"); REF = os.path.join(ROOT, "notes", "research", "ref_tools_v2")
FONT = "C:/Windows/Fonts/malgun.ttf"; FONTB = "C:/Windows/Fonts/malgunbd.ttf"


def F(sz, bold=False):
    return ImageFont.truetype(FONTB if bold else FONT, sz)


def on_white(path, box=None, size=None):
    im = Image.open(path).convert("RGBA")
    bg = Image.new("RGBA", im.size, (255, 255, 255, 255)); bg.paste(im, (0, 0), im)
    im = bg.convert("RGB")
    if box:
        im = im.crop(box)
    if size:
        im.thumbnail(size, Image.LANCZOS)
    return im


def fit(im, w, h, bg=(255, 255, 255)):
    im = im.copy(); im.thumbnail((w, h), Image.LANCZOS)
    c = Image.new("RGB", (w, h), bg); c.paste(im, ((w - im.width) // 2, (h - im.height) // 2))
    return c


def wrap(d, text, font, width):
    lines = []; cur = ""
    for ch in text:
        if d.textlength(cur + ch, font=font) > width:
            lines.append(cur); cur = ch.lstrip()
        else:
            cur += ch
    if cur:
        lines.append(cur)
    return lines


def caption(canvas, x, y, w, text, size=17, color=(30, 30, 30), bold=False):
    d = ImageDraw.Draw(canvas); f = F(size, bold)
    for para in text.split("\n"):
        for ln in wrap(d, para, f, w):
            d.text((x, y), ln, fill=color, font=f); y += int(size * 1.4)
    return y


def crop_tight(im, pad=18):
    """crop a white-background render to its content (+ pad), keeps aspect"""
    import numpy as np
    a = np.array(im.convert("L")); ys, xs = np.where(a < 245)
    if len(xs) == 0:
        return im
    return im.crop((max(xs.min() - pad, 0), max(ys.min() - pad, 0), min(xs.max() + pad, im.width), min(ys.max() + pad, im.height)))


TOOLS = [
    dict(key="fuse_puller", ko="퓨즈 집게", en="Fuse puller", tris=1881, dims="0.74 x 0.20 x 0.083", rig="FusePuller_Rig.glb (팔 2개)",
         refs=[("fuse_04_red_slim.jpg", "실물 ① 빨간 플라스틱 퓨즈 집게 (Bing 이미지 'fuse puller red for blade and old fuses')"),
               ("fuse_03_bing_red.jpg", "실물 ② 검색: 'red plastic fuse puller tweezers close up' (빨간 U/X 집게 여러 종)")],
         views=["front", "threeq"],
         notes="맞음: 한 덩어리 빨간 플라스틱 U자 집게, 팔에 미끄럼 리브, 끝 갈고리 + 톱니(블레이드 퓨즈 머리를 물림), 팔이 살짝 휘며 집힘.\n다름: 실물은 더 가늘고 긴 막대(길이:폭 약 5:1) — 우리는 캐주얼하게 통통(3.7:1). 손에 쥐어 보이게 굵게."),
    dict(key="plug_socket", ko="플러그 소켓 + 연장대", en="Plug socket + extension", tris=1040, dims="0.125 x 1.10 x 0.125", rig="-",
         refs=[("plug_02_socket_hex_top.jpg", "실물 ① 점화플러그 소켓 (Walmart 'Spark Plug Socket Rubber Insert' 580x580)"),
               ("plug_01_bing.jpg", "실물 ② 검색: '3/8 drive spark plug socket rubber insert extension' (소켓·연장대 여러 종)")],
         views=["front", "threeq"],
         notes="맞음: 크롬 얇은 벽 깊은 소켓 + 6각 입 + 안쪽 고무 삽입, 3/8 네모 구멍 달린 연장대, 널링(마름모 홈) 띠.\n다름: 빨간 손 슬리브는 시안(연장대에 끼운 돌리개) 그대로 — 실물 사진엔 없음(일부 제품은 빨간 띠)."),
    dict(key="trim_tool", ko="트림 도구 (다시 만듦)", en="Trim / clip tool", tris=954, dims="1.15 x 0.204 x 0.073", rig="-",
         refs=[("trim_02_detail_walmart.jpg", "실물 ① Walmart '12pcs Auto Trim Removal Tool Set, Plastic Pry Tool Kit' 576x576: 납작한 주황 나일론 판 4종, V홈 포크, 날 끝 꺾임"),
               ("trim_01_bing.jpg", "실물 ② 검색: 'automotive trim clip removal tool fork plastic pry tool orange' (납작한 판 + 쇠 손잡이 형)")],
         views=["front", "threeq"],
         notes="맞음(통째로 다시 만듦): 납작하고 넓은 주황 나일론 판 · 손잡이는 납작 타원 단면(폭 0.164 x 두께 0.056) · 앞으로 갈수록 넓어지며(0.204) 얇아지는 쐐기 날(끝 두께 0.018) · 끝 V홈 포크(가닥 끝 사이 0.104, 가닥 중심 0.154, 홈 0.033) · 날 근처 8° 꺾임. 구멍·리브 뺌(물고기로 읽혔음).\n다름: 실물 두께 약 5 mm(0.02 stud)인데 우리 손잡이는 0.056(캐주얼하게 2.5배) · 실물 세트엔 반대쪽 끝이 평평한 날 · 실물 일부는 날이 더 휘어 있음."),
    dict(key="hose_pliers", ko="호스 클램프 플라이어", en="Hose clamp pliers", tris=1840, dims="1.34 x 0.42 x 0.106", rig="HosePliers_Rig.glb (팔 2개)",
         refs=[("hose_01_bing.jpg", "실물 검색: 'hose clamp pliers swivel jaw ratchet lock automotive spring clamp pliers' (검정 몸 + 빨간 그립)")],
         views=["front", "threeq"],
         notes="맞음: 검은 강철 몸통 + 빨간 딥 그립, 끝에 돌아가는 컵 턱(십자 홈), 래칫 잠금대 + 반환 스프링, 피벗 리벳에서 교차.\n다름: 실물 대부분 턱이 한 방향으로 꺾여 있음(스위벨 각 30~45°) — 우리는 컵 턱만 살짝 바깥으로 꺾음."),
    dict(key="drain_pan", ko="받이통", en="Drain pan", tris=2455, dims="1.05 x 0.444 x 1.96 (몸통 1.00 x 0.44 x 1.60)", rig="-",
         refs=[("drain_01_bing.jpg", "실물 ① 검색: 'plastic oil drain pan with spout and handle 16 quart white background' (깊은 통 + 주둥이 + 테두리 일체 손잡이)"),
               ("drain_05_lowhandle_coasthd.jpg", "실물 ② coasthd.co.nz 저상 오일 받이통(Bing 상세 보기): 짧고 납작한 D 고리 손잡이가 테두리 높이로 끝에 붙음 — 손잡이를 이 모양으로 낮춤"),
               ("drain_04_coolant_green.jpg", "실물 ③ 검색: 'antifreeze coolant drain pan green spout cap handle' (Groz 4.25 gal; 테두리에 붙은 납작한 귀 손잡이 + 깊은 통)")],
         views=["threeq", "front"],
         notes="맞음(손잡이·받이 공간 고침): 깊고 넓은 플라스틱 통, 두껍게 말린 테두리, 한쪽 끝 주둥이(테두리가 U로 낮아짐), 반대쪽은 테두리 높이의 납작한 D 고리 손잡이(손가락 구멍) — 솟은 아치 없음, 스크린이 테두리보다 0.18 아래로 가라앉아 어두운 받이 공간(깊이 0.21)이 보임. 안쪽 구멍 뚫린 스크린(저상 오일 탱크의 격자 덮개가 실제 있음) — 네모 구멍 5 x 7 = 35개.\n다름: 실물은 검정/초록 PE 통(주황은 우리 공구 색 통일) · 손잡이 형태는 제품마다 다름 · 주둥이 뚜껑(마개) 없음."),
]
FITS = {
    "fuse_puller": [("fuse_front.png", "정면 단면: 빨간 퓨즈 머리가 두 턱 사이(벌린 폭 0.084 > 퓨즈 0.07), 옆 퓨즈와 간격 0.035"),
                    ("fuse_q.png", "위에서 3/4: 뚜껑 연 퓨즈 박스에 집게가 내려옴"), ("fuse_side.png", "옆 단면: 팔 두께 0.083, 퓨즈 두께 0.028")],
    "plug_socket": [("plug_section.png", "단면: 소켓(지름 0.125)이 플러그 구멍(0.156) 안에서 플러그 6각 + 자기를 감쌈, 고무 바닥이 닿음"),
                    ("plug_q.png", "3/4: 엔진 커버·코일 뗀 뒤 구멍으로 연장대가 올라옴")],
    "trim_tool": [("trim_top.png", "위에서: 두 가닥(끝 사이 0.104)이 클립 머리 0.1을 감싸고, V홈 0.033 = 자루"), ("trim_section.png", "단면: 두 가닥이 머리 양옆에 걸림(덮개가 6° 기울어 있어 도구도 기울여 넣음)"),
                  ("trim_q.png", "3/4: 덮개 가장자리를 따라 옆에서 들어감")],
    "hose_pliers": [("hose_close.png", "가까이: 두 컵 턱이 밴드 귀(흰 조각)를 양옆에서 물음 (벌림 0.117 > 귀 0.043)"), ("hose_side.png", "옆(+X): 호스 아래에서 올라온 모습"),
                    ("hose_q.png", "3/4")],
    "drain_pan": [("pan_side.png", "단면(x=-2): 받이통 높이 0.446(손잡이도 같은 높이) < 차 아래 여유 0.68~0.8 → 주둥이 쪽이 범퍼 밖, 손잡이는 엔진 쪽"),
                  ("pan_q.png", "앞 3/4: 범퍼 아래 땅에 놓임")],
}


def three_views(t):
    key = t["key"]; col = os.path.join(WK, key, "colour"); grey = os.path.join(WK, key, "grey")
    names = ["front", "left", "top", "threeq"]
    W_, H_ = 480, 480
    img = Image.new("RGB", (W_ * 4, H_ * 2 + 150), "white")
    for i, n in enumerate(names):
        img.paste(fit(crop_tight(on_white(os.path.join(col, n + ".png"))), W_, H_), (i * W_, 0))
        g = os.path.join(grey, "eevee_" + n + ".png")
        img.paste(fit(crop_tight(on_white(g)), W_, H_), (i * W_, H_ + 0))
    d = ImageDraw.Draw(img)
    for i, n in enumerate(["앞 front", "옆 left", "위 top", "3/4"]):
        d.text((i * W_ + 8, 4), n, fill=(200, 0, 0), font=F(18, True))
        d.text((i * W_ + 8, H_ + 4), n + " (회색)", fill=(90, 90, 90), font=F(16))
    y = H_ * 2 + 8
    d.text((10, y), f"{t['ko']} ({t['en']}) — 삼각형 {t['tris']:,} · 크기(stud, x×y×z) {t['dims']} · 1 stud = 0.28 m · 리그: {t['rig']}", fill=(0, 0, 0), font=F(20, True))
    d.text((10, y + 34), "위 줄 = 색 PBR 렌더(흰 바탕 합성), 아래 줄 = 회색 점토 렌더. 같은 6면 이름 규칙(앞 = 시안 앞면).", fill=(60, 60, 60), font=F(16))
    out = os.path.join(WK, key, "three_views.png"); img.save(out); return out


def real_compare(t):
    key = t["key"]
    refs = t["refs"]; n = len(refs)
    CW = 760
    H0 = 600
    img = Image.new("RGB", (CW * 2 + 40, 60 + n * 0 + H0 * 1 + 30 + (n - 1) * 0 + 300 + 20), "white")
    # left: real photos stacked in columns (each ~ 760 x 570); right: 3D renders
    rows = max(n, 1)
    img = Image.new("RGB", (CW * 2 + 60, 40 + rows * 470 + 260), "white")
    d = ImageDraw.Draw(img)
    d.text((10, 6), f"{t['ko']} — 실물 사진(왼쪽, Bing 이미지 검색 화면 스크린샷) ↔ 우리 3D(오른쪽)", fill=(0, 0, 0), font=F(22, True))
    for i, (fn, cap) in enumerate(refs):
        ph = Image.open(os.path.join(REF, fn)).convert("RGB")
        img.paste(fit(ph, CW, 420), (10, 40 + i * 470))
        caption(img, 12, 40 + i * 470 + 424, CW - 6, cap, 14, (70, 70, 70))
    views = t["views"]
    vh = 420
    vims = [fit(crop_tight(on_white(os.path.join(WK, key, "colour", v + ".png"))), CW // 2 - 4, vh) for v in views]
    x0 = CW + 40
    for i, v in enumerate(vims):
        img.paste(v, (x0 + i * (CW // 2), 40))
    d.text((x0, 40 + vh + 6), "우리 3D: " + " · ".join({"front": "앞", "threeq": "3/4", "left": "옆", "top": "위"}[v] for v in views), fill=(200, 0, 0), font=F(16, True))
    caption(img, x0, 40 + vh + 40, CW - 20, t["notes"], 17)
    out = os.path.join(WK, key, "real_compare.png"); img.save(out); return out


def hand_fit(t):
    key = t["key"]
    hs = Image.open(os.path.join(WK, key, "hand_size.png")).convert("RGB")
    fits = [(os.path.join(WK, "fit", fn), cap) for fn, cap in FITS[key] if os.path.exists(os.path.join(WK, "fit", fn))]
    CW = 700
    n = len(fits)
    img = Image.new("RGB", (CW * 3 + 40, 40 + 420 + 70 + 420 + 200), "white")
    d = ImageDraw.Draw(img)
    d.text((10, 6), f"{t['ko']} — 손 크기(왼쪽 = 기존 렌치 옆, 큐브 = R15 주먹 0.30) · 일하는 끝이 엔진룸 부품에 맞는지", fill=(0, 0, 0), font=F(22, True))
    img.paste(fit(hs, CW * 2, 400), (10, 40))
    caption(img, 12, 40 + 404, CW * 2, "Grip 자리에 R15 주먹(0.30 큐브)을 둠 — 같은 배율로 기존 렌치(1.2 stud) 옆에 놓은 그림. 기존 렌치·임팩트·스캐너와 같은 규칙.", 15, (70, 70, 70))
    y = 40 + 470
    for i, (p, cap) in enumerate(fits[:3]):
        im = Image.open(p).convert("RGB")
        img.paste(fit(im, CW, 420), (10 + i * (CW + 10), y))
        caption(img, 12 + i * (CW + 10), y + 424, CW - 10, cap, 15, (60, 60, 60))
    out = os.path.join(WK, key, "hand_fit.png"); img.save(out); return out


def tris_table():
    rows = [("공구", "삼각형", "크기 stud (x × y(위) × z)", "리그 GLB", "텍스처")]
    for t in TOOLS:
        rows.append((t["ko"], f"{t['tris']:,}", t["dims"], t["rig"], "base+orm 1024²"))
    rows.append(("— 비교(기존) —", "", "", "", ""))
    rows += [("렌치", "1,356", "1.20 x 0.27 x 0.141", "-", ""), ("임팩트 렌치", "1,747", "0.45 x 1.154 x 1.102", "-", ""), ("OBD 스캐너", "1,929", "0.48 x 1.475 x 0.172", "-", "")]
    cw = [330, 130, 520, 330, 190]
    img = Image.new("RGB", (sum(cw) + 20, 60 + 44 * len(rows)), "white"); d = ImageDraw.Draw(img)
    d.text((10, 8), "손 공구 2차 5종 삼각형 표 (GLB 불러와서 센 값)", fill=(0, 0, 0), font=F(24, True))
    for r, row in enumerate(rows):
        x = 10
        for c, v in enumerate(row):
            d.text((x, 52 + r * 44), v, fill=(200, 0, 0) if r == 0 else (0, 0, 0), font=F(20, r == 0))
            x += cw[c]
        d.line((10, 52 + r * 44 + 38, sum(cw) + 10, 52 + r * 44 + 38), fill=(200, 200, 200))
    out = os.path.join(WK, "tris_table.png"); img.save(out); return out


def overall():
    rows = []
    for t in TOOLS:
        tv = Image.open(os.path.join(WK, t["key"], "three_views.png")).convert("RGB")
        rows.append(tv.resize((tv.width // 2, tv.height // 2), Image.LANCZOS))
    W_ = max(r.width for r in rows); H_ = sum(r.height for r in rows)
    img = Image.new("RGB", (W_, H_), "white"); y = 0
    for r in rows:
        img.paste(r, (0, y)); y += r.height
    out = os.path.join(WK, "tools_v2_review_all.png"); img.save(out); return out


def qa_sheet():
    """3/4 colour render + QA random-colour sheet (one colour per island: more than one colour = loose pieces) of the four fixed tools"""
    rows = [("트림 도구 TrimTool (다시 만든 판)", os.path.join(WK, "trim_tool", "colour", "threeq.png"), "TrimTool"),
            ("호스 플라이어 HosePliers (+ Rig)", os.path.join(WK, "hose_pliers", "colour", "threeq.png"), "HosePliers"),
            ("렌치 Wrench (슬리브 모서리)", os.path.join(WK, "qa", "Wrench_colour", "threeq.png"), "Wrench"),
            ("OBD 스캐너 OBDScanner (플러그 손잡이 모서리)", os.path.join(WK, "qa", "OBDScanner_colour", "threeq.png"), "OBDScanner")]
    H = 520
    img = Image.new("RGB", (1500, 40 + len(rows) * H), "white"); d = ImageDraw.Draw(img)
    d.text((10, 6), "QA 고친 공구: 3/4 색 렌더 ↔ QA random(부품마다 다른 색) — z-fighting 0 · 떠 있는 조각 0 (notes/qa_3d/*.json)", fill=(0, 0, 0), font=F(22, True))
    for i, (title, col, name) in enumerate(rows):
        y = 40 + i * H
        img.paste(fit(crop_tight(on_white(col)), 460, H - 30), (10, y + 24))
        rnd = Image.open(os.path.join(WK, "qa", name + "_qa_random.png")).convert("RGB")
        img.paste(fit(rnd, 1000, H - 30), (490, y + 24))
        d.text((10, y + 2), title, fill=(200, 0, 0), font=F(18, True))
    out = os.path.join(WK, "qa_fixed_tools.png"); img.save(out); return out


if __name__ == "__main__":
    for t in TOOLS:
        print(three_views(t)); print(real_compare(t)); print(hand_fit(t))
    print(tris_table()); print(overall()); print(qa_sheet())
