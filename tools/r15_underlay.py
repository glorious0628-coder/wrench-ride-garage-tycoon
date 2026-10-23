"""R15 block body underlay for drawing people concepts (pp-3d-make 10-20; API r15_plan_api_a.md: "give the artist ortho renders
of the exact rig as an underlay before drawing"). Our NPC body is the default blocky R15 and can't change shape, so a people
6-view concept has to sit on exactly these blocks — clothes, hair and props go on top.

  py -I tools/r15_underlay.py <out_dir> [px_per_stud=88]
  -> r15_underlay_6view.png   grey body, same 6-view layout as our sheets (top row front, back, left = its own left;
                               bottom row right, top (front down), bottom (front up)), white background
     r15_underlay_lines.png   the same with joint / clothing-break lines and labels (for the artist and the 3D check)

Numbers = art/3d/r15/r15_block_measured_10-20.txt (Studio). The head outline is an approximation of the classic head mesh
(its mesh can't be read): a rounded box 1.196 x 1.203 x 1.198.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

CELL_W, CELL_H = 418, 627
FEET_Y = 575
# visual blocks: name -> (x0, x1, y0, y1, z0, z1)  (ground y 0, front -Z, its right +X)
BLOCKS = {
    "legR": (0.0, 1.0, 0.0, 2.0, -0.5, 0.5), "legL": (-1.0, 0.0, 0.0, 2.0, -0.5, 0.5),
    "torso": (-1.0, 1.0, 2.0, 4.0, -0.5, 0.5),
    "armR": (1.0, 2.0, 2.0, 3.954, -0.5, 0.5), "armL": (-2.0, -1.0, 2.0, 3.954, -0.5, 0.5),
    "head": (-0.598, 0.598, 3.985, 5.188, -0.599, 0.599),
}
FILL = {"legR": (150, 150, 158), "legL": (140, 140, 148), "torso": (185, 185, 192), "armR": (165, 165, 172),
        "armL": (158, 158, 165), "head": (205, 205, 210)}
# picture axes per view: (body axis for picture x, sign), (body axis for picture y-down, sign); axes 0 x / 1 y / 2 z
VIEWS = {
    "front": ((0, -1), (1, -1)), "back": ((0, 1), (1, -1)), "left": ((2, 1), (1, -1)), "right": ((2, -1), (1, -1)),
    "top": ((0, -1), (2, -1)), "bottom": ((0, -1), (2, 1)),
}
ORDER = ["front", "back", "left", "right", "top", "bottom"]
# depth order: what's nearer the viewer is drawn last. Viewer direction along each view's depth axis.
DEPTH = {"front": (2, -1), "back": (2, 1), "left": (0, -1), "right": (0, 1), "top": (1, 1), "bottom": (1, -1)}
LINES = [("neck 4.0", 4.0), ("waist (Upper/LowerTorso) 2.4", 2.4), ("hip 2.0", 2.0), ("elbow 3.035", 3.035),
         ("wrist 2.275", 2.275), ("knee 1.178", 1.178), ("ankle 0.252", 0.252), ("hat 5.186", 5.186)]


def rect(view, b, k, cx, cy):
    (ax, asg), (ay, aysg) = VIEWS[view]
    lo = [b[0], b[2], b[4]]
    hi = [b[1], b[3], b[5]]
    xs = [cx + k * asg * lo[ax], cx + k * asg * hi[ax]]
    ys = [cy + k * aysg * lo[ay], cy + k * aysg * hi[ay]]
    return min(xs), min(ys), max(xs), max(ys)


def draw_cell(view, k, lines):
    im = Image.new("RGB", (CELL_W, CELL_H), (255, 255, 255))
    d = ImageDraw.Draw(im)
    cx = CELL_W / 2
    cy = FEET_Y if view not in ("top", "bottom") else CELL_H / 2
    dax, dsg = DEPTH[view]
    order = sorted(BLOCKS, key=lambda n: dsg * ((BLOCKS[n][2 * dax] + BLOCKS[n][2 * dax + 1]) / 2))
    for name in order:
        b = BLOCKS[name]
        x0, y0, x1, y1 = rect(view, b, k, cx, cy)
        if name == "head":
            rad = 0.5 * k if view in ("top", "bottom") else 0.3 * k
            d.rounded_rectangle([x0, y0, x1, y1], radius=rad, fill=FILL[name], outline=(90, 90, 96), width=2)
        else:
            d.rounded_rectangle([x0, y0, x1, y1], radius=0.06 * k, fill=FILL[name], outline=(90, 90, 96), width=2)
    if lines and view not in ("top", "bottom"):
        try:
            font = ImageFont.truetype("arial.ttf", 11)
        except OSError:
            font = ImageFont.load_default()
        for label, y in LINES:
            py = FEET_Y - k * y
            for x in range(0, CELL_W, 8):
                d.line([x, py, x + 4, py], fill=(230, 60, 60), width=1)
            if view == "front":
                d.text((2, py - 12), label, fill=(200, 30, 30), font=font)
    if lines:
        d.text((6, CELL_H - 18), view + (" (front down)" if view == "top" else " (front up)" if view == "bottom" else ""),
               fill=(0, 0, 0))
    return im


def main():
    out = sys.argv[1]
    k = float(sys.argv[2]) if len(sys.argv) > 2 else 88.0
    os.makedirs(out, exist_ok=True)
    for name, lines in (("r15_underlay_6view.png", False), ("r15_underlay_lines.png", True)):
        sheet = Image.new("RGB", (CELL_W * 3, CELL_H * 2), (255, 255, 255))
        for i, v in enumerate(ORDER):
            sheet.paste(draw_cell(v, k, lines), ((i % 3) * CELL_W, (i // 3) * CELL_H))
        sheet.save(os.path.join(out, name))
        print("wrote", os.path.join(out, name))


if __name__ == "__main__":
    main()
