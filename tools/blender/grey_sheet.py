# Build a 6-view sheet of the mesh's grey renders in the SAME layout/framing as the concept sheet cells (pp-3d-make
# 10-20, GPT sneaker_tex_r2: paint the mesh, not the concept). Top row front, back, left; bottom row right, top, bottom.
# Each view sits in a 600 px cell at the concept object's box (ox, oy, w, h) from views.json.
#   py -I tools/blender/grey_sheet.py <views.json> <mesh_views_dir> <out.png>
# Also: py -I tools/blender/grey_sheet.py --split <painted_sheet.png> <views.json> <out_dir>  -> <view>.png cells + views.json
import sys, json, os
import numpy as np
from PIL import Image
NAMES = ["front", "back", "left", "right", "top", "bottom"]
if sys.argv[1] == "--split":
    sp, vj, od = sys.argv[2:5]; cfg = json.load(open(vj, encoding="utf-8")); os.makedirs(od, exist_ok=True)
    S = cfg["size"]; im = Image.open(sp).convert("RGB").resize((3 * S, 2 * S), Image.LANCZOS)
    out = dict(cfg); out["views"] = {}
    for i, n in enumerate(NAMES):
        x, y = (i % 3) * S, (i // 3) * S
        p = os.path.join(od, n + ".png"); im.crop((x, y, x + S, y + S)).save(p)
        out["views"][n] = [os.path.abspath(p).replace("\\", "/")] + cfg["views"][n][1:5]
    json.dump(out, open(os.path.join(od, "views.json"), "w", encoding="utf-8"), indent=1); print("ok", od)
    sys.exit(0)
vj, md, outp = sys.argv[1:4]; cfg = json.load(open(vj, encoding="utf-8")); S = cfg["size"]
sheet = Image.new("RGB", (3 * S, 2 * S), "white")
for i, n in enumerate(NAMES):
    _, ox, oy, w, h = cfg["views"][n][:5]
    m = Image.open(os.path.join(md, n + ".png")).convert("RGBA").resize((w, h), Image.LANCZOS)
    cell = Image.new("RGBA", (S, S), (255, 255, 255, 255)); cell.alpha_composite(m, (ox, oy))
    sheet.paste(cell.convert("RGB"), ((i % 3) * S, (i // 3) * S))
sheet.save(outp); print("ok", outp)
