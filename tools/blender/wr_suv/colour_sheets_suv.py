# Colour review sheets for the SUV body (wr-3d-suv, 10-21; adapted from wr_body/colour_sheets.py).
#   py -I tools/blender/wr_suv/colour_sheets_suv.py <work/B> <review_dir> <hero.png> <deliver_dir> <paint_hex>
import os, sys, json
from PIL import Image, ImageDraw, ImageFont

R, OUT, HERO, D, PAINT = sys.argv[1:6]
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


def grid(cells, cols, cw, ch, title, labels, pad=12, foot=None):
    rows = (len(cells) + cols - 1) // cols
    out = Image.new("RGB", (cols * (cw + pad) + pad, rows * (ch + pad + 30) + 60 + (40 if foot else 0)), "white")
    d = ImageDraw.Draw(out); d.text((pad, 14), title, fill=(0, 0, 0), font=F)
    for i, im in enumerate(cells):
        im = fit(im, cw, ch); x = pad + (i % cols) * (cw + pad); y = 60 + (i // cols) * (ch + pad + 30)
        out.paste(im, (x + (cw - im.width) // 2, y + 30 + (ch - im.height) // 2))
        d.text((x, y + 4), labels[i], fill=(60, 60, 60), font=FS)
    if foot:
        d.text((pad, out.height - 34), foot, fill=(0, 0, 0), font=FS)
    return out


m = json.load(open(os.path.join(R, "measure.json"))); iou = json.load(open(os.path.join(R, "col_cmp", "iou.json")))
foot = ("L %.2f (16.6)  W %.2f (7.7, mirrors %.2f)  H rails %.2f / roof %.2f (6.6 / 6.4)  wheelbase %.2f (9.7)  tris %d  |  "
        "IoU side %.3f/%.3f front %.3f back %.3f  |  default paint %s" % (m["length"], m["width_body"], m["width_with_mirrors"],
        m["height_rails"], m["height_roof"], m["wheelbase_from_arches"], m["tris_total"], iou["left"], iou["right"], iou["front"],
        iou["back"], PAINT))
T = "SUV B colour"
g6 = Image.open(os.path.join(R, "col_cmp", "sheet_concept_vs_grey.png")).convert("RGB")
big = Image.new("RGB", (g6.width, g6.height + 44), "white"); big.paste(g6, (0, 0))
ImageDraw.Draw(big).text((10, g6.height + 10), T + "  |  " + foot, fill=(0, 0, 0), font=FS)
big.save(os.path.join(OUT, "suv_B_colour6_vs_concept.png"))
cmp_ = [Image.open(os.path.join(R, "col_cmp", f"spec_cmp_{n}.png")).convert("RGB") for n in ("left", "front", "back", "top")]
grid(cmp_, 2, 1500, 760, f"{T} - concept stretched to the suv_spec box vs colour 3D (top = layout only)",
     ["side", "front", "back", "top (layout only)"], foot=foot).save(os.path.join(OUT, "suv_B_colour_overlay.png"))
c = os.path.join(R, "col_r")
cells = [Image.open(HERO).convert("RGB"), flat(os.path.join(R, "col_open", "hero.png")), flat(os.path.join(c, "hero.png"))]
cells += [flat(os.path.join(c, f"{n}.png")) for n in ("threeq_fl", "threeq_fr", "threeq_rl", "threeq_rr")]
cells += [flat(os.path.join(R, "col_open", "threeq_fl.png"))]
grid(cells, 2, 1100, 740, f"{T} - hero angle + 4 corners (default paint {PAINT}; review wheels = wheel helper meshes scaled to 2.98 x 1.15)",
     ["hero concept", "colour, same angle, hood opened 70 deg", "colour, same angle, hood closed", "front-left", "front-right",
      "rear-left", "rear-right", "front-left, hood opened 70 deg"], foot=foot).save(os.path.join(OUT, "suv_B_colour_threeq.png"))
z = Image.open(os.path.join(R, "col_zoom2x.png")).convert("RGB")
zz = Image.new("RGB", (z.width, z.height + 60), "white"); zz.paste(z, (0, 60))
ImageDraw.Draw(zz).text((12, 14), f"{T} - 2x zoom (paint reads as paint, thin even dark-grey gaps, black cladding / pillars / rails, silver skid)",
                        fill=(0, 0, 0), font=F)
zz.save(os.path.join(OUT, "suv_B_colour_zoom2x.png"))
Image.open(os.path.join(R, "col_small", "small.png")).save(os.path.join(OUT, "suv_B_colour_small64_96.png"))
nz = [flat(os.path.join(R, "col_neutral", "threeq_fl.png")), flat(os.path.join(R, "col_neutral", "threeq_rr.png"))]
mk = Image.open(os.path.join(D, "suv_shell_paintmask.png")).convert("RGB")
ov = Image.open(os.path.join(D, "suv_shell_color_overlay.png")).convert("RGBA")
chk = Image.new("RGBA", ov.size, (255, 0, 255, 255)); chk.alpha_composite(ov)
grid(nz + [mk, chk.convert("RGB")], 2, 1000, 700,
     f"paint system: GLB ColorMap has NEUTRAL paint (#E6E6E6); default paint {PAINT} = MeshPart.Color through AlphaMode Overlay",
     ["deliverable GLB as imported (neutral paint)", "rear", "Shell paint mask (white = paint)",
      "Shell color_overlay.png: paint area transparent (magenta here) -> Overlay shows MeshPart.Color"]).save(
    os.path.join(OUT, "suv_B_paint_system.png"))
print("ok", OUT)
