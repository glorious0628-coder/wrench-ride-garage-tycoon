# Grey shape renders of several GLBs side by side (rows = models, cols = views), for a fair shape-only comparison.
import sys, os, numpy as np
from PIL import Image, ImageDraw
sys.path.insert(0, sys.argv[1])
import glbshade
out = sys.argv[2]
items = [a.split('=', 1) for a in sys.argv[3:]]  # label=path
glbshade.V['threeq_b'] = (1, -1, -1)
views = ['front', 'back', 'threeq', 'threeq_b', 'left']
N = 384
rows = []
for label, path in items:
    P = glbshade.prims(path)
    grey = [(pos, idx, uv, nr, np.array([0.82, 0.80, 0.74]), None, 0.6) for (pos, idx, uv, nr, fac, tx, rough) in P]
    tris = sum(len(p[1]) for p in P)
    ims = []
    for v in views:
        im, e = glbshade.render(grey, v, N=N, ext=None)
        ims.append(Image.fromarray(im))
    rows.append((f"{label}  ({tris} tris)", ims))
W = N * len(views); H = (N + 28) * len(rows)
sheet = Image.new('RGB', (W, H), (255, 255, 255)); d = ImageDraw.Draw(sheet)
for r, (lab, ims) in enumerate(rows):
    y = r * (N + 28); d.text((6, y + 6), lab, fill=(0, 0, 0))
    for c, im in enumerate(ims):
        sheet.paste(im, (c * N, y + 28))
sheet.save(out); print('ok', out, sheet.size)
