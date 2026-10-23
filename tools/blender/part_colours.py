# Colour codes per part, measured on the concept (pp-3d-make 10-20, user: "부위 마다 시안의 색깔 코드 있잖아. 그걸로 해줭").
# For every material of a palette, all concept pixels that view_labels.py gave that material (all 6 cells) are pooled;
# highlights and shadows are dropped (only the 35-65 % brightness band of that material is kept) and the median of the
# rest is the part's colour code. Prints a table and writes <palette>_measured.json with the hex replaced.
#   py -I tools/blender/part_colours.py <views.json (original cells)> <views_lab.json (label maps)> <palette.json>
import sys, json
import numpy as np
from PIL import Image

vj, lj, pj = sys.argv[1:4]
views = json.load(open(vj, encoding="utf-8"))["views"]; labs = json.load(open(lj, encoding="utf-8"))["views"]
pal = json.load(open(pj, encoding="utf-8"))
pix = {i: [] for i in range(len(pal))}
for n, v in views.items():
    a = np.asarray(Image.open(v[0]).convert("RGB")).astype(np.float32)
    lab = np.asarray(Image.open(labs[n][0])).astype(int)
    for i in pix:
        pix[i].append(a[lab == i])
out = []
for i, p in enumerate(pal):
    P = np.concatenate(pix[i]) if pix[i] else np.zeros((0, 3))
    q = dict(p)
    if len(P) > 50:
        V = P.max(1); lo, hi = np.percentile(V, 35), np.percentile(V, 65)
        mid = P[(V >= lo) & (V <= hi)]
        c = np.median(mid, 0).round().astype(int)
        q["hex"] = "#%02X%02X%02X" % tuple(c); q["measured_px"] = int(len(P))
    print(f'{p["name"]:>12}: {p["hex"]} -> {q["hex"]}  ({len(P)} px)')
    out.append(q)
op = pj.replace(".json", "_measured.json")
json.dump(out, open(op, "w", encoding="utf-8"), indent=1); print("ok", op)
