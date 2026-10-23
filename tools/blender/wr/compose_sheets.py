# wr-3d 10-21: labelled review sheets for the final Detail / Lite corner (run after final_review.sh).
#   py -I tools/blender/wr/compose_sheets.py <review_dir> <detail_tris> <lite_tris>
import sys
from PIL import Image, ImageDraw, ImageFont
R = sys.argv[1].rstrip("/") + "/"; DT, LT = sys.argv[2], sys.argv[3]
try:
    F = ImageFont.truetype("arial.ttf", 22); FS = ImageFont.truetype("arial.ttf", 18)
except Exception:
    F = FS = ImageFont.load_default()


def onbg(p, c=(60, 62, 70, 255)):
    a = Image.open(p).convert("RGBA"); bg = Image.new("RGBA", a.size, c); bg.alpha_composite(a); return bg.convert("RGB")


W, H = 800, 450
s = Image.new("RGB", (2 * W + 30, 3 * (H + 40) + 50), "white"); d = ImageDraw.Draw(s)
d.text((10, 10), f"Detail (bay cars) corner {DT} tris   |   Lite (other cars) corner {LT} tris   - tire d 2.75, camera FOV 70, eye 2.5 studs", fill=(0, 0, 0), font=F)
for i, dist in enumerate((3, 8, 20)):
    y = 50 + i * (H + 40)
    for j, key in enumerate("AB"):
        s.paste(Image.open(f"{R}dist_{key}_{dist}stud.png").convert("RGB").resize((W, H), Image.LANCZOS), (j * (W + 30), y + 30))
        d.text((j * (W + 30) + 5, y + 4), f"{'Detail' if key == 'A' else 'Lite'} - {dist} stud", fill=(0, 0, 0), font=F)
s.save(R + "lod_distance_compare.png")
im = Image.open(R + "size_ortho.png").convert("RGB"); d = ImageDraw.Draw(im)
d.text((330, 80), "NEW  tire d 2.75 (x1.146)", fill=(0, 0, 0), font=F); d.text((735, 80), "OLD  tire d 2.4", fill=(0, 0, 0), font=F)
d.text((20, 660), "ticks = 1 stud (floor), 1 / 2 / 3 stud height marks on the right", fill=(40, 40, 40), font=FS)
im.save(R + "size_2p4_vs_2p75.png")


def crop2x(p, box, c=(235, 235, 235, 255)):
    return onbg(p, c).crop(box).resize((800, 800), Image.LANCZOS)


for name, pref, tri in (("detail", "corner_detail", DT), ("lite", "corner_lite", LT)):
    s = Image.new("RGB", (1600, 1640), "white"); d = ImageDraw.Draw(s)
    s.paste(crop2x(f"{R}{pref}_grey/eevee_front.png", (212, 212, 812, 812)), (0, 40))
    s.paste(crop2x(f"{R}{pref}_grey/eevee_threeq.png", (380, 300, 880, 800)), (800, 40))
    s.paste(crop2x(f"{R}{pref}_grey/wb_threeq_back.png", (150, 250, 650, 750)), (0, 840))
    s.paste(crop2x(f"{R}{pref}_grey/eevee_top.png", (112, 312, 912, 712)).resize((800, 400)), (800, 840))
    d.text((8, 8), f"{name.upper()} corner {tri} tris - grey, 2x crops (front / 3-4 / back / top), backface px = 0", fill=(0, 0, 0), font=F)
    s.save(R + f"grey2x_{name}.png")
s = Image.new("RGB", (1600, 840), "white"); d = ImageDraw.Draw(s)
s.paste(onbg(R + "brake_detail_colour/threeq.png").crop((420, 180, 920, 680)).resize((800, 800)), (0, 40))
s.paste(onbg(R + "brake_detail_colour/threeq_back.png").crop((150, 200, 650, 700)).resize((800, 800)), (800, 40))
d.text((8, 8), "pads mounted: zinc steel plate #CDD6E0 (bright, cool) + friction #362C26 (darker, warm) - outboard notch / inboard window", fill=(0, 0, 0), font=F)
s.save(R + "pads_mounted.png")
print("ok")
