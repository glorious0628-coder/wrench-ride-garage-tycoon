# Review sheets for the fault-look parts from one review version (wr-3d helper 10-21).
#   py -I finalize_sheets.py <work/vN dir> <art/3d/fault_parts dir>
import os, sys, shutil
from PIL import Image, ImageDraw, ImageFont

W, OUT = sys.argv[1], sys.argv[2]
CP = os.path.join(OUT, "work", "concept")
try:
    F = ImageFont.truetype("arial.ttf", 17); FT = ImageFont.truetype("arial.ttf", 24)
except Exception:
    F = FT = ImageFont.load_default()


def load(p, cell):
    im = Image.open(p).convert("RGBA"); bg = Image.new("RGBA", im.size, (238, 238, 238, 255)); bg.alpha_composite(im)
    im = bg.convert("RGB")
    k = min(cell / im.width, cell / im.height)
    return im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS)


def block(title, items, cols, cell):
    rows = [items[i:i + cols] for i in range(0, len(items), cols)]
    S = Image.new("RGB", (cols * (cell + 10) + 10, 40 + len(rows) * (cell + 34)), "white"); d = ImageDraw.Draw(S)
    d.text((10, 8), title, fill=(0, 0, 0), font=FT)
    for r, row in enumerate(rows):
        for c, (lab, p) in enumerate(row):
            if not os.path.exists(p):
                continue
            im = load(p, cell); x = 10 + c * (cell + 10); y = 40 + r * (cell + 34)
            d.text((x + 2, y), lab, fill=(60, 60, 60), font=F); S.paste(im, (x + (cell - im.width) // 2, y + 24 + (cell - im.height) // 2))
    return S


def stack(blocks, path):
    Wd = max(b.width for b in blocks); S = Image.new("RGB", (Wd, sum(b.height for b in blocks) + 12 * len(blocks)), "white"); y = 0
    for b in blocks:
        S.paste(b, (0, y)); y += b.height + 12
    S.save(path); print("ok", path, S.size)


PARTS = [("coolant_tank", "cool", "Coolant reservoir (body + black flip cap; liquid hidden in grey)"),
         ("brake_reservoir", "brake", "Brake fluid reservoir (body + black base + white cap)"),
         ("washer_nozzle", "nozzle", "Hood washer nozzle (one mesh, used twice)"),
         ("wiper_long", "wiperL", "Wiper LONG 2.7 (arm + blade, own frame: drum = pivot)")]
WMAP = {"front": "n_top", "back": "n_bottom", "left": "front", "right": "back", "top": "n_top", "bottom": "n_bottom"}
for mode, tag in (("grey", "grey"), ("colour", "colour")):
    blocks = []
    for cn, rn, title in PARTS:
        items = []
        for v in ("front", "back", "left", "right", "top", "bottom"):
            rv = WMAP[v] if rn == "wiperL" else v
            pref = "eevee_" if mode == "grey" else ""
            items += [("concept " + v, f"{CP}/{cn}_{v}.png"), ("3D " + v + ("" if rv == v else f" ({rv})"), f"{W}/{rn}_{mode}/{pref}{rv}.png")]
        if mode == "grey":
            items += [("3/4 (Workbench, back-face cull)", f"{W}/{rn}_grey/wb_threeq.png"), ("3/4 back", f"{W}/{rn}_grey/eevee_threeq_back.png")]
        else:
            items += [("3/4", f"{W}/{rn}_colour/threeq.png"), ("3/4 back", f"{W}/{rn}_colour/threeq_back.png")]
        blocks.append(block(f"{title} - {mode}", items, 7, 230))
    if mode == "grey":
        items = [("short 2.1 top (n)", f"{W}/wiperS_grey/eevee_n_top.png"), ("short side", f"{W}/wiperS_grey/eevee_front.png"),
                 ("short 3/4", f"{W}/wiperS_grey/wb_hi3q.png")]
    else:
        items = [("short 2.1 top (n)", f"{W}/wiperS_colour/n_top.png"), ("short 3/4", f"{W}/wiperS_colour/hi3q.png"),
                 ("WORN blade top", f"{W}/wiperL_worn/n_top.png"), ("WORN 3/4", f"{W}/wiperL_worn/hi3q.png"), ("WORN rubber edge (below)", f"{W}/wiperL_worn/under.png")]
    blocks.append(block("Wiper SHORT (same shape, blade 2.1)" + (" + worn blade texture" if mode == "colour" else ""), items, 5, 300))
    stack(blocks, os.path.join(OUT, f"fault_parts_{tag}_sheet.png"))

# 2x grey close-ups
items = []
for rn, vs in (("cool_grey2x", ("eevee_threeq", "wb_threeq_back", "eevee_threeq_left", "wb_bottom")), ("brake_grey2x", ("eevee_threeq", "wb_threeq_back", "eevee_threeq_left", "wb_bottom")),
               ("nozzle_grey2x", ("eevee_threeq", "wb_threeq_back", "eevee_backlow", "wb_bottom")), ("wiper_grey2x", ("eevee_n_top", "eevee_front", "wb_hi3q", "eevee_back3q"))):
    items += [(f"{rn} {v}", f"{W}/{rn}/{v}.png") for v in vs]
stack([block("Grey 2x close-ups: smooth curves, round circles, no gaps; Workbench views cull back faces (a flipped face = hole)", items, 4, 420)],
      os.path.join(OUT, "fault_parts_grey2x.png"))
# overlays
ov = [Image.open(f"{W}/{d}/overlay_sheet.png").convert("RGB") for d in ("ov_cool", "ov_brake", "ov_nozzle", "ov_wiper")]
stack([o for o in ov], os.path.join(OUT, "fault_parts_overlay_sheet.png"))
for d, n in (("ov_cool", "coolant"), ("ov_brake", "brake"), ("ov_nozzle", "nozzle"), ("ov_wiper", "wiper")):
    shutil.copy(f"{W}/{d}/overlay_sheet.png", os.path.join(OUT, f"fault_parts_overlay_{n}.png"))
# in place
b1 = block("On the sedan, hood open 57.8 deg - NORMAL levels (coolant 3.10 between F 3.40 / L 3.00, brake 3.20 between MAX/MIN) - decor: old tanks cut out, master cylinder redrawn 0.235 lower (proposal)",
           [(v, f"{W}/inplace_ok/{v}.png") for v in ("workcam", "coolant_close", "brake_close", "coolant_front")], 2, 760)
b2 = block("Fault look: LOW (coolant 2.66 below L, brake 2.97 below MIN)", [(v, f"{W}/inplace_low/{v}.png") for v in ("workcam", "coolant_close", "brake_close", "coolant_front")], 2, 760)
stack([b1, b2], os.path.join(OUT, "fault_parts_inplace_bay.png"))
b3 = block("Hood closed: wipers at rest on the glass, nozzles on the hood's rear edge, blue review lines = washer fan (centre +-12.5 deg) from the jet tip to the glass target",
           [(v, f"{W}/inplace_closed/{v}.png") for v in ("cowl_front", "cowl_3q", "cowl_driver", "cowl_mid", "nozzle_close")], 2, 760)
b4 = block("Wiper SERVICE position (arm turned 60 deg up the glass about the pivot axis)", [(v, f"{W}/inplace_service/{v}.png") for v in ("cowl_front", "cowl_3q")], 2, 760)
stack([b3, b4], os.path.join(OUT, "fault_parts_inplace_cowl.png"))
