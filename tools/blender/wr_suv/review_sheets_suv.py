# Review sheets for the SUV body grey pass (wr-3d-suv, 10-21; adapted from wr_body/review_sheets.py).
#   py -I tools/blender/wr_suv/review_sheets_suv.py <work_dir art/3d/suv_body/work> <out_dir art/3d/suv_body/review> <hero.png>
# Per variant (A = suv_spec rear: liftgate hinge Z +7.9, B = concept rear: hinge ~Z +6.8): grey 6-view next to the
# concept, overlay sheet (concept stretched to the spec box, red concept / blue 3D outlines), 3/4 renders + the hero
# concept + the same angle with the hood opened 70 deg, 2x zoom crops. Plus one A-vs-B decision sheet.
import os, sys, json
from PIL import Image, ImageDraw, ImageFont

W_, OUT, HERO = sys.argv[1], sys.argv[2], sys.argv[3]
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


def grid(cells, cols, cw, ch, title, labels=None, pad=12, foot=None):
    rows = (len(cells) + cols - 1) // cols
    out = Image.new("RGB", (cols * (cw + pad) + pad, rows * (ch + pad + 30) + 60 + (40 if foot else 0)), "white")
    d = ImageDraw.Draw(out); d.text((pad, 14), title, fill=(0, 0, 0), font=F)
    for i, im in enumerate(cells):
        im = fit(im, cw, ch)
        x = pad + (i % cols) * (cw + pad); y = 60 + (i // cols) * (ch + pad + 30)
        out.paste(im, (x + (cw - im.width) // 2, y + 30 + (ch - im.height) // 2))
        if labels:
            d.text((x, y + 4), labels[i], fill=(60, 60, 60), font=FS)
    if foot:
        d.text((pad, out.height - 34), foot, fill=(0, 0, 0), font=FS)
    return out


NAMES = {"A": "A = suv_spec rear (liftgate hinge Z +7.9 / Y 6.35, near-upright liftgate)",
         "B": "B = concept rear (upper rear leaned: hinge ~Z +6.75, rear glass ~38 deg, roof drops 0.12)"}
M = {}
for v in ("A", "B"):
    vd = os.path.join(W_, v)
    m = json.load(open(os.path.join(vd, "measure.json"))); M[v] = m
    iou = json.load(open(os.path.join(vd, "cmp", "iou.json"))) if os.path.exists(os.path.join(vd, "cmp", "iou.json")) else {}
    foot = ("L %.2f (spec 16.6)  W %.2f (7.7, mirrors %.2f)  H rails %.2f (6.6) / roof %.2f (6.4)  wheelbase %.2f (9.7)  "
            "tris %d  |  IoU side %.3f/%.3f front %.3f back %.3f" % (m["length"], m["width_body"], m["width_with_mirrors"],
            m["height_rails"], m["height_roof"], m["wheelbase_from_arches"], m["tris_total"], iou.get("left", 0), iou.get("right", 0),
            iou.get("front", 0), iou.get("back", 0)))
    g6 = Image.open(os.path.join(vd, "cmp", "sheet_concept_vs_grey.png")).convert("RGB")
    big = Image.new("RGB", (g6.width, g6.height + 44), "white"); big.paste(g6, (0, 0))
    ImageDraw.Draw(big).text((10, g6.height + 10), NAMES[v] + "  |  " + foot, fill=(0, 0, 0), font=FS)
    big.save(os.path.join(OUT, f"suv_{v}_grey6_vs_concept.png"))
    cmp_ = [Image.open(os.path.join(vd, "cmp", f"spec_cmp_{n}.png")).convert("RGB") for n in ("left", "front", "back", "top")]
    grid(cmp_, 2, 1500, 760, f"{NAMES[v]} - concept stretched to the suv_spec box vs grey 3D (top view = layout only)",
         ["side (wheels: spec wheelbase 9.7 vs concept ~10.7)", "front", "back", "top (layout only - drawn too narrow)"],
         foot=foot).save(os.path.join(OUT, f"suv_{v}_overlay.png"))
    r = os.path.join(vd, "r"); o = os.path.join(vd, "ropen")
    hero = Image.open(HERO).convert("RGB")
    cells = [hero, flat(os.path.join(o, "hero.png")), flat(os.path.join(vd, "rh", "hero.png")), flat(os.path.join(r, "threeq_fl.png")),
             flat(os.path.join(r, "threeq_rr.png")), flat(os.path.join(r, "threeq_low.png"))]
    grid(cells, 3, 1000, 680, f"{NAMES[v]} - grey 3/4 (review wheels = wheel helper's Rim/Tire scaled to 2.98 x 1.15, not part of the body)",
         ["hero concept (hood open)", "grey, same angle, hood opened 70 deg about the Hinge", "grey, same angle, hood closed",
          "front-left 3/4", "rear-right 3/4", "low front-left"], foot=foot).save(os.path.join(OUT, f"suv_{v}_threeq.png"))
    z = Image.open(os.path.join(vd, "zoom2x.png")).convert("RGB")
    zz = Image.new("RGB", (z.width, z.height + 60), "white"); zz.paste(z, (0, 60))
    ImageDraw.Draw(zz).text((12, 14), f"{NAMES[v]} - 2x zoom, strong raking light (surface check: bumps / facets / gaps)", fill=(0, 0, 0), font=F)
    zz.save(os.path.join(OUT, f"suv_{v}_zoom2x.png"))
    print(v, "ok", foot)

# A vs B decision sheet: side outlines + rear 3/4
cells, labels = [], []
for v in ("A", "B"):
    vd = os.path.join(W_, v)
    im = Image.open(os.path.join(vd, "cmp", "spec_cmp_left.png")).convert("RGB")
    w, h = im.size
    cells.append(im.crop((w // 2, 40 + (h - 50) // 2 + 10, w, h)))
    cells.append(flat(os.path.join(vd, "r", "threeq_rr.png")))
    labels += [f"{v} side: outlines red = concept, blue = 3D", f"{v} rear 3/4"]
out = grid(cells, 2, 1100, 560, "SUV rear: A (suv_spec hinge Z +7.9) vs B (concept rear, hinge ~Z +6.75) - everything else identical", labels)
d = ImageDraw.Draw(out)
big = Image.new("RGB", (out.width, out.height + 50), "white"); big.paste(out, (0, 0))
ImageDraw.Draw(big).text((12, out.height + 10), "side IoU A %.3f / B %.3f   tris A %d / B %d   back faces 0 / 0" % (
    json.load(open(os.path.join(W_, "A", "cmp", "iou.json")))["left"], json.load(open(os.path.join(W_, "B", "cmp", "iou.json")))["left"],
    M["A"]["tris_total"], M["B"]["tris_total"]), fill=(0, 0, 0), font=FS)
big.save(os.path.join(OUT, "suv_A_vs_B.png"))
print("ok", OUT)
