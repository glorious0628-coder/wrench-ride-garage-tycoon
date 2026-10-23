# Review sheets for the SUV 2nd pass (wr-3d-suv, 10-21): front face before / after, engine bay (hood on the prop rod)
# vs the hero concept, underbody from the lift, grey checks.
#   py -I tools/blender/wr_suv/review2_sheets_suv.py <art/3d/suv_body> <hero concept png>
# reads work/B/{face_before,face_after}, work/concept/suv_{front,left,bottom}.png, work/decor/{c_bay,g_bay,c_under,g_under}
import os, sys, json
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT, HERO = sys.argv[1], sys.argv[2]
RV = os.path.join(ROOT, "review"); os.makedirs(RV, exist_ok=True)
WB, WD, CO = os.path.join(ROOT, "work", "B"), os.path.join(ROOT, "work", "decor"), os.path.join(ROOT, "work", "concept")
FONT = next((f for f in ("C:/Windows/Fonts/malgun.ttf", "arial.ttf") if os.path.exists(f) or "/" not in f), "arial.ttf")
try:
    F = ImageFont.truetype(FONT, 28); FS = ImageFont.truetype(FONT, 20)
except Exception:
    F = FS = ImageFont.load_default()
BG = (236, 236, 236)
j = os.path.join


def flat(p, bg=BG):
    im = Image.open(p).convert("RGBA"); b = Image.new("RGBA", im.size, bg + (255,)); b.alpha_composite(im)
    return b.convert("RGB")


def fit(im, w, h):
    k = min(w / im.width, h / im.height)
    return im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS)


def sheet(cells, cols, cw, ch, title, out, pad=14, foot=()):
    rows = (len(cells) + cols - 1) // cols
    o = Image.new("RGB", (cols * (cw + pad) + pad, rows * (ch + pad + 34) + 64 + 30 * len(foot)), "white")
    d = ImageDraw.Draw(o); d.text((pad, 16), title, fill=(0, 0, 0), font=F)
    for i, (im, lab) in enumerate(cells):
        im = fit(im, cw, ch); x = pad + (i % cols) * (cw + pad); y = 64 + (i // cols) * (ch + pad + 34)
        o.paste(im, (x + (cw - im.width) // 2, y + 30)); d.text((x, y + 2), lab, fill=(40, 40, 40), font=FS)
    y = 64 + rows * (ch + pad + 34)
    for t in foot:
        d.text((pad, y), t, fill=(0, 0, 0), font=FS); y += 30
    o.save(j(RV, out)); print("ok", out)


def fractions_render(p):
    a = np.asarray(Image.open(p).convert("RGBA")).astype(int)
    r = a[int(500 - (2.6 - 3.3) * 100):int(500 - (0.85 - 3.3) * 100), 240:760]       # front ortho 100 px/stud, |x| < 2.6
    return cls(r, r[..., 3] > 200)


def cls(r, m):
    L = r[..., :3].mean(-1); g = (r[..., 1] > r[..., 0] + 6) & (r[..., 1] > r[..., 2] + 6)
    return tuple(round(float(v.sum()) / float(m.sum()), 2) for v in ((L < 80) & m & ~g, (~g) & (L >= 80) & m, g & m))


c = np.asarray(Image.open(j(CO, "suv_front.png")).convert("RGB")).astype(int)
r = c[int(487 - 2.6 / 0.0239):int(487 - 0.80 / 0.0239), int(347.5 - 2.6 / 0.0257):int(347.5 + 2.6 / 0.0257)]
fc = cls(r, r.min(-1) < 235)
fb, fa = fractions_render(j(WB, "face_before", "front.png")), fractions_render(j(WB, "face_after_oldpaint", "front.png"))
# ---- 1. front face before / after (before = previous run's render with the 1st-pass paint #7C8A71 -> the after is shown
# in the same paint for a fair look, plus the new default paint #8FA283)
hero = Image.open(HERO).convert("RGB")
cf = Image.open(j(CO, "suv_front.png")).convert("RGB").crop((150, 150, 550, 550))
crop_h = (60, 560, 560, 1000)
cells = []
for v, crop in (("front", None), ("hero", crop_h), ("threeq_fl", None)):
    for d_, lab in (("face_before", "1차"), ("face_after_oldpaint", "2차 (같은 도장 #7C8A71)"), ("face_after", "2차 (새 기본 도장 #8FA283)")):
        im = flat(j(WB, d_, v + ".png"))
        cells.append((im.crop(crop) if crop else im, lab + {"front": " 앞", "hero": " 대표 각도 범퍼", "threeq_fl": " 3/4"}[v]))
    cells.append({"front": (cf, "시안 6면 앞 칸"), "hero": (hero.crop((30, 560, 720, 960)), "대표 시안 범퍼"),
                  "threeq_fl": (flat(j(WB, "face_after", "threeq_low.png")), "2차 낮은 3/4")}[v])
sheet(cells, 4, 640, 480, "SUV 앞 얼굴 1차 → 2차: 큰 검정 사다리꼴 그릴 + 은색 스키드 판 (라이트 띠 그대로)", "suv_B2_face_before_after.png",
      foot=["앞 뷰 범퍼(타이어 안쪽, Y 0.85~2.6) 면적 비율 (검정, 회색·은색, 도장):  1차 %s   2차 %s   시안 %s" % (fb, fa, fc),
            "2차: 검정 틀 = 시안 앞 칸에서 잰 사다리꼴(위 ±2.15 @Y2.40, 아래 ±3.03 @Y1.40) + 아래 검정 띠, 0.06 솟은 검정 플라스틱 한 덩어리",
            "흡기구 위 2.26·살 4개 | 스키드 = 따로 붙은 거의 세운 판(Y 1.00~1.45, 폭 ±2.55, 위 끝 0.03 턱; 1차는 아래로 꺾인 면에 칠만 해서 그늘) "
            "| 앞 범퍼 아래 둥글림 (0.9, 0.95) → (0.6, 0.55)"])
# ---- 2. engine bay with the hood on the prop rod vs the hero concept
pj = json.load(open(j(ROOT, "decor", "hood_prop_attachments.json")))
cells = [(hero, "대표 시안 (보닛 열림)"), (flat(j(WD, "c_bay", "hero.png")), "3D 색, 같은 각도 (보닛 받침대 %.1f°)" % pj["hood_open_deg"]),
         (flat(j(WD, "c_bay", "bay_34.png")), "3D 색 3/4"), (flat(j(WD, "c_bay", "bay_top.png")), "3D 색 위에서"),
         (flat(j(WD, "c_bay", "prop_side.png")), "받침대 (조수석 앞, 보닛 앞 오른쪽 소켓)"), (flat(j(WD, "g_bay", "bay_34.png")), "회색 3/4")]
sheet(cells, 2, 1000, 680, "SUV 엔진룸 장식 (세단 장식 재사용, SUV 자리) — 배터리·라디에이터·바퀴·브레이크 = 다른 도우미 실제 메시(읽기만)",
      "suv_B2_bay_vs_concept.png",
      foot=["엔진룸 = 세단 자리 + (0, +0.5, +0.15); 방화벽 쪽(부스터·마스터 실린더·브레이크액 통·스트럿 타워)은 0.40 더 앞; 배터리 자리 (-2.2, 2.85, -5.55)·"
            "라디에이터 자리 (0, 2.8, -7.35) 비움; 받침대 길이 %.2f → 보닛 %.1f°" % (pj["length"], pj["hood_open_deg"])])
p2 = j(WD, "g_bay", "bay_top2x.png")
if os.path.exists(p2):
    z = flat(p2); W_, H_ = z.size
    boxes = [("운전석 쪽: 에어박스·배터리 자리·퓨즈박스·부스터", (int(W_ * 0.56), int(H_ * 0.08), int(W_ * 0.94), int(H_ * 0.62))),
             ("엔진 위: 코일 4·엔진 커버·오일 캡·딥스틱·흡기", (int(W_ * 0.30), int(H_ * 0.10), int(W_ * 0.68), int(H_ * 0.64))),
             ("조수석 쪽: 냉각수·워셔 통·발전기·벨트·받침대", (int(W_ * 0.04), int(H_ * 0.08), int(W_ * 0.42), int(H_ * 0.62)))]
    sheet([(z.crop(b), t) for t, b in boxes], 3, 700, 600, "SUV 엔진룸 회색 2배 점검", "suv_B2_bay_grey2x.png")
# ---- 3. underbody from the lift
cells = [(flat(j(WD, "c_under", v + ".png")), lab) for v, lab in
         (("under_front", "앞 하체 (리프트 Under, 눈 1.4 아래에서 올려다봄)"), ("under_rear", "뒤 하체: 연료탱크·뒤 서브프레임·링크·머플러"),
          ("under_side", "옆에서 올려다봄: 언더커버·터널 배기·열 차단판"))]
bot = flat(j(WD, "c_under", "bottom.png")).rotate(90, expand=True)
cb = Image.open(j(CO, "suv_bottom.png")).convert("RGB")
a_ = np.asarray(cb); m_ = a_.min(-1) < 235; ys, xs = np.where(m_)
cb = cb.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
if cb.height > cb.width:
    cb = cb.rotate(90, expand=True)
cells += [(bot, "3D 아래 정면 (앞 = 왼쪽)"), (cb, "시안 6면 아래 칸")]
gcells = [(flat(j(WD, "g_under", v + ".png")), "회색 " + v) for v in ("under_front",)]
sheet(cells + gcells, 2, 1000, 680, "SUV 하체 장식 — 지상고 +0.2, 휠베이스 9.7 (스트럿·스프링·쇼바 = 검토용 자리표시)", "suv_B2_under_lift.png",
      foot=["앞: 서브프레임·L 팔·랙(엔진 뒤, 오일팬과 배기 사이)·스태빌·구동축(엔진 +0.5 따라 기울어 바퀴 중심 1.49로) | 가운데: 터널 배기·촉매·공명기·열 차단판·언더커버 "
            "| 뒤: 새들 탱크·뒤 서브프레임·링크·조정 캠, 배기 끝 = 머플러 입구 (1.255, 1.0, 7.065)"])
