# Colour review sheets for the sedan body (wr-3d-body, 10-21).
#   py -I tools/blender/wr_body/colour_sheets.py <work/B> <review_dir> <hero.png> <deliver_dir>
import os, sys, json
import numpy as np
from PIL import Image, ImageDraw, ImageFont

R, OUT, HERO, D = sys.argv[1:5]
os.makedirs(OUT, exist_ok=True)
try:
    F = ImageFont.truetype("arial.ttf", 26); FS = ImageFont.truetype("arial.ttf", 20)
except Exception:
    F = FS = ImageFont.load_default()


def flat(p, bg=(236, 236, 236)):
    im = Image.open(p).convert("RGBA"); b = Image.new("RGBA", im.size, bg + (255,)); b.alpha_composite(im)
    return b.convert("RGB")


def fit(im, w, h):
    k = min(w / im.width, h / im.height)
    return im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS)


def grid(cells, cols, cw, ch, title, labels, pad=12):
    rows = (len(cells) + cols - 1) // cols
    out = Image.new("RGB", (cols * (cw + pad) + pad, rows * (ch + pad + 30) + 60), "white")
    d = ImageDraw.Draw(out); d.text((pad, 14), title, fill=(0, 0, 0), font=F)
    for i, im in enumerate(cells):
        im = fit(im, cw, ch); x = pad + (i % cols) * (cw + pad); y = 60 + (i // cols) * (ch + pad + 30)
        out.paste(im, (x + (cw - im.width) // 2, y + 30 + (ch - im.height) // 2))
        d.text((x, y + 4), labels[i], fill=(60, 60, 60), font=FS)
    return out


T = "sedan B colour"
Image.open(os.path.join(R, "col_cmp", "sheet_concept_vs_grey.png")).save(os.path.join(OUT, "sedan_B_colour6_vs_concept.png"))
cmp_ = [Image.open(os.path.join(R, "col_cmp", f"spec_cmp_{n}.png")).convert("RGB") for n in ("left", "front", "back", "top")]
grid(cmp_, 2, 1500, 760, f"{T} - concept stretched to the car_spec box vs colour 3D (top = layout only)",
     ["side", "front", "back", "top"]).save(os.path.join(OUT, "sedan_B_colour_overlay.png"))
c = os.path.join(R, "col_r"); sd = os.path.join(R, "col_side")
cells = [flat(os.path.join(c, f"{n}.png")) for n in ("threeq_fl", "threeq_fr", "threeq_rl", "threeq_rr")]
cells += [Image.open(HERO).convert("RGB"), flat(os.path.join(R, "col_open", "threeq_fl.png"))]
grid(cells, 2, 1100, 760, f"{T} - 3/4 from 4 corners (default paint #098FFC; review wheels 2.75 not part of the body)",
     ["front-left", "front-right", "rear-left", "rear-right", "hero concept", "colour, hood opened 70 deg"]).save(
    os.path.join(OUT, "sedan_B_colour_threeq.png"))
side = [flat(os.path.join(sd, "left.png")), flat(os.path.join(sd, "threeq_fl.png")), flat(os.path.join(sd, "threeq_rl.png"))]
grid(side, 1, 1800, 760, f"{T} - low side light: shoulder crease from the front fender through both doors to the rear fender",
     ["side", "front-left", "rear-left"]).save(os.path.join(OUT, "sedan_B_colour_crease_sidelight.png"))
fl = flat(os.path.join(c, "threeq_fl.png")); rr = flat(os.path.join(c, "threeq_rr.png")); W, H = fl.size
crops = [fl.crop((int(W * .14), int(H * .22), int(W * .62), int(H * .74))), fl.crop((int(W * .46), int(H * .22), int(W * .82), int(H * .66))),
         rr.crop((int(W * .13), int(H * .25), int(W * .55), int(H * .78))), rr.crop((int(W * .45), int(H * .2), int(W * .85), int(H * .66)))]
crops = [x.resize((x.width * 2, x.height * 2), Image.LANCZOS) for x in crops]
grid(crops, 2, 1400, 1000, f"{T} - 2x zoom (paint reads as paint, even dark-grey gaps, thin lamps, black C-pillar)",
     ["front: light bar, two-tier grille, intake", "A-pillar, mirror, doors, crease", "rear: one-line tail lamp, diffuser",
      "C-pillar black, rear door"]).save(os.path.join(OUT, "sedan_B_colour_zoom2x.png"))
Image.open(os.path.join(R, "col_small", "small.png")).save(os.path.join(OUT, "sedan_B_colour_small64_96.png"))
# paint system: neutral deliverable + paint mask + overlay alpha
nz = [flat(os.path.join(R, "col_neutral", "threeq_fl.png")), flat(os.path.join(R, "col_neutral", "threeq_rr.png"))]
mk = Image.open(os.path.join(D, "sedan_shell_paintmask.png")).convert("RGB")
ov = Image.open(os.path.join(D, "sedan_shell_color_overlay.png")).convert("RGBA")
chk = Image.new("RGBA", ov.size, (255, 0, 255, 255)); chk.alpha_composite(ov)
grid(nz + [mk, chk.convert("RGB")], 2, 1000, 700,
     "paint system: GLB ColorMap has NEUTRAL paint (#E6E6E6); default paint #098FFC is applied by code (see README)",
     ["deliverable GLB as imported (neutral paint)", "rear", "Shell paint mask (white = paint)",
      "Shell color_overlay.png: paint area transparent (magenta here) -> AlphaMode Overlay shows MeshPart.Color"]).save(
    os.path.join(OUT, "sedan_B_paint_system.png"))
print("ok", OUT)
