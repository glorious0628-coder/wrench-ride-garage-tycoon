#!/bin/sh
# 2x review crops (wr-3d-suv): sh zoom2x.sh <A|B> <out.png>
V=$1; OUTP=$2
ROOT="$(cd "$(dirname "$0")/../../.." && pwd -W 2>/dev/null || pwd)"
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
W="$ROOT/art/3d/suv_body/work/$V"
"$B" --background --factory-startup --python "$ROOT/tools/blender/wr_suv/render_suv.py" -- "$W/glb/suv_body_all.glb;$W/review_wheels.glb" "$W/r2" 200 grey threeq_fl,threeq_rr,left 2>&1 | grep -E "Error|Traceback"
py -I - "$W/r2" "$OUTP" << 'PY'
import sys
from PIL import Image
d, outp = sys.argv[1], sys.argv[2]
def flat(n):
    im = Image.open(d + "/" + n + ".png").convert("RGBA"); bg = Image.new("RGBA", im.size, (236, 236, 236, 255)); bg.alpha_composite(im); return bg.convert("RGB")
fl, rr, lf = flat("threeq_fl"), flat("threeq_rr"), flat("left")
W, H = fl.size
crops = [fl.crop((int(W * .10), int(H * .34), int(W * .45), int(H * .86))), fl.crop((int(W * .26), int(H * .18), int(W * .62), int(H * .70))),
         rr.crop((int(W * .13), int(H * .26), int(W * .49), int(H * .80))), rr.crop((int(W * .40), int(H * .22), int(W * .76), int(H * .76))),
         lf.crop((int(lf.width * .02), int(lf.height * .26), int(lf.width * .40), int(lf.height * .78))), lf.crop((int(lf.width * .60), int(lf.height * .18), int(lf.width * .98), int(lf.height * .70)))]
cw = 1100
rows = []
out = Image.new("RGB", (2 * cw + 10, 3 * 760 + 20), (236, 236, 236))
for i, c in enumerate(crops):
    k = min(cw / c.width, 760 / c.height); c = c.resize((int(c.width * k), int(c.height * k)), Image.LANCZOS)
    out.paste(c, ((i % 2) * (cw + 10), (i // 2) * 770))
out.save(outp)
PY
