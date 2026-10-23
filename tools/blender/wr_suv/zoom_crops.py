# 2x review crops of the 200 px/stud renders (wr-3d-suv): py -I zoom_crops.py <render_dir> <out.png>
import sys
from PIL import Image
d, outp = sys.argv[1], sys.argv[2]


def flat(n):
    im = Image.open(d + "/" + n + ".png").convert("RGBA"); bg = Image.new("RGBA", im.size, (236, 236, 236, 255)); bg.alpha_composite(im)
    return bg.convert("RGB")


fl, rr, lf = flat("threeq_fl"), flat("threeq_rr"), flat("left")
W, H = fl.size
crops = [fl.crop((int(W * .10), int(H * .34), int(W * .45), int(H * .86))), fl.crop((int(W * .26), int(H * .18), int(W * .62), int(H * .70))),
         rr.crop((int(W * .13), int(H * .26), int(W * .49), int(H * .80))), rr.crop((int(W * .40), int(H * .22), int(W * .76), int(H * .76))),
         lf.crop((int(lf.width * .02), int(lf.height * .26), int(lf.width * .40), int(lf.height * .78))),
         lf.crop((int(lf.width * .60), int(lf.height * .18), int(lf.width * .98), int(lf.height * .70)))]
out = Image.new("RGB", (2 * 1100 + 10, 3 * 760 + 20), (236, 236, 236))
for i, c in enumerate(crops):
    k = min(1100 / c.width, 760 / c.height); c = c.resize((int(c.width * k), int(c.height * k)), Image.LANCZOS)
    out.paste(c, ((i % 2) * 1110, (i // 2) * 770))
out.save(outp)
print("ok", outp)
