# Review sheets for the sedan body grey pass (wr-3d-body, 10-21).
#   py -I tools/blender/wr_body/review_sheets.py <work_dir art/3d/sedan_body/work> <out_dir art/3d/sedan_body/review> <hero.png>
# Per variant (A = car_spec hinge 3.05, B = concept heights): grey 6-view next to the concept, overlay sheet (concept
# stretched to the spec box, red concept / blue 3D outlines), 3/4 renders (+ hood open next to the hero concept),
# 2x zoom crops. Plus one A-vs-B decision sheet.
import os, sys, json
from PIL import Image, ImageDraw, ImageFont

W_, OUT, HERO = sys.argv[1], sys.argv[2], sys.argv[3]
VARS = sys.argv[4].split(",") if len(sys.argv) > 4 else ["A", "B"]
os.makedirs(OUT, exist_ok=True)
try:
    F = ImageFont.truetype("arial.ttf", 26); FS = ImageFont.truetype("arial.ttf", 20)
except Exception:
    F = FS = ImageFont.load_default()
BG = (236, 236, 236)


def flat(p, bg=BG):
    im = Image.open(p).convert("RGBA"); b = Image.new("RGBA", im.size, bg + (255,)); b.alpha_composite(im)
    return b.convert("RGB")


def fit(im, w=None, h=None):
    k = min(w / im.width if w else 9e9, h / im.height if h else 9e9)
    return im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS)


def grid(cells, cols, cw, ch, title, labels=None, pad=12):
    rows = (len(cells) + cols - 1) // cols
    out = Image.new("RGB", (cols * (cw + pad) + pad, rows * (ch + pad + 30) + 60), "white")
    d = ImageDraw.Draw(out); d.text((pad, 14), title, fill=(0, 0, 0), font=F)
    for i, im in enumerate(cells):
        im = fit(im, cw, ch)
        x = pad + (i % cols) * (cw + pad); y = 60 + (i // cols) * (ch + pad + 30)
        out.paste(im, (x + (cw - im.width) // 2, y + 30 + (ch - im.height) // 2))
        if labels:
            d.text((x, y + 4), labels[i], fill=(60, 60, 60), font=FS)
    return out


NAMES = {"A": "A = car_spec heights (hood hinge Y 3.05)",
         "B": "B (adopted, 2nd pass: tyre 2.75, fastback rear, crease ridge, hinge Y 4.15)"}
for v in VARS:
    vd = os.path.join(W_, v)
    if not os.path.isdir(vd):
        continue
    m = json.load(open(os.path.join(vd, "measure.json")))
    Image.open(os.path.join(vd, "final_cmp", "sheet_concept_vs_grey.png")).save(os.path.join(OUT, f"sedan_{v}_grey6_vs_concept.png"))
    cmp_ = [Image.open(os.path.join(vd, "final_cmp", f"spec_cmp_{n}.png")).convert("RGB") for n in ("left", "front", "back", "top")]
    grid(cmp_, 2, 1500, 760, f"{NAMES[v]} - concept stretched to the car_spec box vs grey 3D (top view = layout only)",
         ["side", "front", "back", "top (layout only)"]).save(os.path.join(OUT, f"sedan_{v}_overlay.png"))
    r = os.path.join(vd, "final_r"); o = os.path.join(vd, "final_open")
    hero = Image.open(HERO).convert("RGB")
    cells = [flat(os.path.join(r, "threeq_fl.png")), flat(os.path.join(r, "threeq_rr.png")),
             flat(os.path.join(r, "threeq_fr.png")), flat(os.path.join(r, "threeq_low.png")),
             hero, flat(os.path.join(o, "threeq_fl.png"))]
    grid(cells, 2, 1100, 760, f"{NAMES[v]} - grey 3/4 views (wheels = review placeholders 2.4 x 0.9, not part of the body)",
         ["front-left (hero side)", "rear-right", "front-right", "low front-left", "hero concept (hood open)",
          "grey, hood opened 70 deg about the Hinge"]).save(os.path.join(OUT, f"sedan_{v}_threeq.png"))
    fl = flat(os.path.join(r, "threeq_fl.png")); rr = flat(os.path.join(r, "threeq_rr.png")); lf = flat(os.path.join(r, "left.png"))
    W, H = fl.size
    crops = [fl.crop((int(W * .14), int(H * .22), int(W * .62), int(H * .74))), fl.crop((int(W * .46), int(H * .22), int(W * .82), int(H * .66))),
             rr.crop((int(W * .13), int(H * .25), int(W * .55), int(H * .78))), lf.crop((0, int(lf.height * .25), int(lf.width * .5), int(lf.height * .78)))]
    crops = [c.resize((c.width * 2, c.height * 2), Image.LANCZOS) for c in crops]
    grid(crops, 2, 1400, 1000, f"{NAMES[v]} - 2x zoom (surface check: bumps / facets / gaps)",
         ["front + hood", "A-pillar, doors, crease line", "rear + trunk", "side, front half"]).save(os.path.join(OUT, f"sedan_{v}_zoom2x.png"))
    print(v, "ok", m["length"], m["width_body"], m["height"], m["wheelbase_from_arches"])

if "A" not in VARS:
    # before / after (B 1st pass -> 2nd pass)
    p1 = os.path.join(W_, "B_pass1", "r"); p2 = os.path.join(W_, "B", "final_r")
    cells = [flat(os.path.join(p1, "left.png")), flat(os.path.join(p2, "left.png")),
             flat(os.path.join(p1, "threeq_rr.png")), flat(os.path.join(p2, "threeq_rr.png")),
             flat(os.path.join(p1, "threeq_fl.png")), flat(os.path.join(p2, "threeq_fl.png"))]
    grid(cells, 2, 1300, 700, "sedan B: 1st pass (left, no wheels) -> 2nd pass (right, review wheels 2.75)",
         ["1st: side", "2nd: side (fastback rear, bigger wheels)", "1st: rear 3/4", "2nd: rear 3/4 (rounder, lower tail)",
          "1st: front 3/4", "2nd: front 3/4 (crease ridge, rounder nose top)"]).save(os.path.join(OUT, "sedan_B_pass1_vs_pass2.png"))
    print("ok", OUT)
    sys.exit(0)
# A vs B decision sheet: side + front outline overlays with the numbers
cells, labels = [], []
for v in ("A", "B"):
    vd = os.path.join(W_, v)
    for n in ("left", "front"):
        im = Image.open(os.path.join(vd, "final_cmp", f"spec_cmp_{n}.png")).convert("RGB")
        w, h = im.size
        # the sheet is 2 x 2 (concept | 3D / overlay | outline): take 3D and outline
        cells.append(im.crop((w // 2, 40, w, 40 + (h - 50) // 2)))
        cells.append(im.crop((w // 2, 40 + (h - 50) // 2 + 10, w, h)))
        labels += [f"{v} {n}: grey 3D", f"{v} {n}: outlines red = concept, blue = 3D"]
out = grid(cells, 4, 800, 420, "A (car_spec hood hinge Y 3.05) vs B (concept heights, hinge Y 4.15) - same spec box, same wheels", labels)
d = ImageDraw.Draw(out)
ma = json.load(open(os.path.join(W_, "A", "measure.json"))); mb = json.load(open(os.path.join(W_, "B", "measure.json")))
txt = ("both: L %.2f  H %.2f  W %.2f (mirrors %.2f)  wheelbase %.2f (arch fit)  tyre 2.4  |  tris A %d / B %d  |  back faces 0 / 0"
       % (mb["length"], mb["height"], mb["width_body"], mb["width_with_mirrors"], mb["wheelbase_from_arches"], ma["tris_total"], mb["tris_total"]))
big = Image.new("RGB", (out.width, out.height + 50), "white"); big.paste(out, (0, 0))
ImageDraw.Draw(big).text((12, out.height + 10), txt, fill=(0, 0, 0), font=FS)
big.save(os.path.join(OUT, "sedan_A_vs_B.png"))
print("ok", OUT)
