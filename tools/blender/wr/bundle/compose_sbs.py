# Compose side_by_side_near.png / side_by_side_far.png from side_by_side.py renders.
#   python -I compose_sbs.py <sbs_dir> <check_dir>
import sys, os
from PIL import Image, ImageDraw, ImageFont

src, dst = sys.argv[1], sys.argv[2]
os.makedirs(dst, exist_ok=True)
try:
    F = ImageFont.truetype("malgunbd.ttf", 24); FS = ImageFont.truetype("malgun.ttf", 19)
except OSError:
    F = FS = ImageFont.load_default()
ROWS = {"bg": "고른 배경 차 (Cars Full): BG_Sedan_1 · BG_Pickup_1 · BG_Van_1 + 우리 세단(파랑)",
        "c2": "참고 비교 (Cars 2, 안 고름): Car_5 · Car_18 픽업 · Car_17 밴 + 우리 세단(파랑)"}


def label(img, text, sub=None):
    d = ImageDraw.Draw(img)
    w = d.textlength(text, font=F) + 20
    d.rectangle([0, 0, w, 36], fill=(255, 255, 255)); d.text((10, 4), text, fill=(0, 0, 0), font=F)
    if sub:
        w2 = d.textlength(sub, font=FS) + 20
        d.rectangle([0, 36, w2, 64], fill=(255, 255, 255)); d.text((10, 38), sub, fill=(70, 70, 70), font=FS)
    return img


# near: 2 x 2
W, H = 960, 540
near = Image.new("RGB", (2 * W + 6, 2 * H + 6 + 2 * 40), (40, 40, 44))
y = 0
for pack in ("bg", "c2"):
    d = ImageDraw.Draw(near); d.text((10, y + 6), ROWS[pack], fill=(255, 255, 255), font=F); y += 40
    for i, (v, sub) in enumerate((("lot_near", "주차장: 눈높이 5, 거리 약 20 stud, 시야 70°"),
                                  ("curb_near", "길가 주차: 인도에서 걸어가며 (눈높이 5, 약 16 stud)"))):
        im = Image.open(os.path.join(src, "%s_%s.png" % (pack, v))).convert("RGB").resize((W, H), Image.LANCZOS)
        near.paste(label(im, "가까이", sub), (i * (W + 6), y))
    y += H + 6
near.save(os.path.join(dst, "side_by_side_near.png"))

# far: per row = whole 1080p frame (scaled) + 1:1 crop around the cars, x2 nearest (what a 1080p player sees)
CROPS = {"lot_far": (960 - 240, 400, 960 + 240, 670), "curb_far": (960 - 320, 365, 960 + 320, 725)}
rows = []
for pack in ("bg", "c2"):
    for v, sub in (("lot_far", "주차장 100 stud"), ("curb_far", "길가 80 stud")):
        full = Image.open(os.path.join(src, "%s_%s.png" % (pack, v))).convert("RGB")
        a = full.resize((W, H), Image.LANCZOS)
        c = full.crop(CROPS[v]).resize((W, H), Image.NEAREST)
        row = Image.new("RGB", (2 * W + 6, H), (40, 40, 44))
        row.paste(label(a, "멀리 - 전체 화면(1080p)", sub), (0, 0)); zx = W / (CROPS[v][2] - CROPS[v][0])
        row.paste(label(c, "같은 화면 확대 x%.1f (실제 픽셀)" % zx, ROWS[pack].split(":")[0]), (W + 6, 0))
        rows.append(row)
far = Image.new("RGB", (2 * W + 6, len(rows) * (H + 6)), (40, 40, 44))
for i, r in enumerate(rows):
    far.paste(r, (0, i * (H + 6)))
far.save(os.path.join(dst, "side_by_side_far.png"))
print("ok", near.size, far.size)
