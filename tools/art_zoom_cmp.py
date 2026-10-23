# wr-art check tool (not art, 10-22 thumbnails): crop the same fractional boxes from original and new, stack pairs (orig | new).
#   py -I tools/art_zoom_cmp.py <out.png> <original.png> <new.png> x0,y0,x1,y1 [x0,y0,x1,y1 ...]   (fractions 0..1)
import sys
from PIL import Image
out, a, b = sys.argv[1:4]
boxes = [tuple(float(v) for v in s.split(",")) for s in sys.argv[4:]]
A, B = Image.open(a).convert("RGB"), Image.open(b).convert("RGB")
rows = []
for x0, y0, x1, y1 in boxes:
    ca = A.crop((int(x0*A.width), int(y0*A.height), int(x1*A.width), int(y1*A.height)))
    cb = B.crop((int(x0*B.width), int(y0*B.height), int(x1*B.width), int(y1*B.height)))
    h = 260
    ca = ca.resize((int(ca.width*h/ca.height), h)); cb = cb.resize((int(cb.width*h/cb.height), h))
    r = Image.new("RGB", (ca.width+cb.width+10, h), "white"); r.paste(ca, (0, 0)); r.paste(cb, (ca.width+10, 0)); rows.append(r)
W = max(r.width for r in rows); H = sum(r.height+10 for r in rows)
sheet = Image.new("RGB", (W, H), "white"); y = 0
for r in rows: sheet.paste(r, (0, y)); y += r.height+10
sheet.save(out); print(out, sheet.size)
