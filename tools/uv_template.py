"""UV template for a GLB: the triangles of its UV layout drawn on a texture-sized canvas, so a painter can draw a new
texture for the SAME mesh (3D schedule 10-19: the box's grade textures go on the S1 mesh, no new mesh).

  py tools/uv_template.py <in.glb> <out_dir> [--px 2048]

Writes into out_dir:
  <name>_uv.png          white canvas, triangle edges coloured by the face's direction (top / bottom / front / back /
                         left / right — legend in the corner), each island's direction written in its middle
  <name>_uv_over.png     the same lines over the model's current texture (where today's art sits)
  <name>_uv_mask.png     transparent canvas, the islands filled in light grey (what's actually used; paint inside)
Front = -Z (Roblox LookVector) after the file's own node transforms; glTF UV (0,0) is the image's top-left.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "3d", "_tools"))
import glbkit  # noqa: E402

DIRS = {  # name, colour
    "top": ((0, 1, 0), (220, 40, 40)),
    "bottom": ((0, -1, 0), (120, 70, 20)),
    "front": ((0, 0, -1), (30, 120, 230)),
    "back": ((0, 0, 1), (30, 170, 80)),
    "right": ((1, 0, 0), (200, 120, 0)),
    "left": ((-1, 0, 0), (150, 60, 200)),
}
KO = {"top": "위", "bottom": "아래", "front": "앞(-Z)", "back": "뒤", "right": "오른쪽(+X)", "left": "왼쪽"}


def face_dir(n):
    best, bd = None, -2
    for name, (v, _) in DIRS.items():
        d = float(np.dot(n, v))
        if d > bd:
            best, bd = name, d
    return best


def font(px):
    for f in ("C:/Windows/Fonts/malgunbd.ttf", "C:/Windows/Fonts/malgun.ttf", "arial.ttf"):
        try:
            return ImageFont.truetype(f, px)
        except OSError:
            pass
    return ImageFont.load_default()


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    src, out = sys.argv[1], sys.argv[2]
    px = int(sys.argv[sys.argv.index("--px") + 1]) if "--px" in sys.argv else 2048
    os.makedirs(out, exist_ok=True)
    name = os.path.splitext(os.path.basename(src))[0]
    parts = glbkit.load(src)
    lines = Image.new("RGB", (px, px), (255, 255, 255))
    mask = Image.new("RGBA", (px, px), (0, 0, 0, 0))
    over = None
    dl, dm = ImageDraw.Draw(lines), ImageDraw.Draw(mask)
    labels = {}  # dir -> list of uv centres
    for p in parts:
        if p["uv"] is None:
            continue
        if over is None and p["image"] is not None:
            over = p["image"].resize((px, px))
        uv, pos, idx = p["uv"], p["pos"], p["idx"]
        for tri in idx:
            a, b, c = pos[tri[0]], pos[tri[1]], pos[tri[2]]
            n = np.cross(b - a, c - a)
            ln = np.linalg.norm(n)
            if ln < 1e-12:
                continue
            d = face_dir(n / ln)
            pts = [(float(uv[i][0]) * px, float(uv[i][1]) * px) for i in tri]
            dm.polygon(pts, fill=(200, 200, 200, 255))
            dl.line(pts + [pts[0]], fill=DIRS[d][1], width=max(1, px // 1024))
            labels.setdefault(d, []).append((sum(x for x, _ in pts) / 3, sum(y for _, y in pts) / 3))
    f = font(px // 40)
    for d, cs in labels.items():
        # one label per direction, at the triangle centre nearest the middle of that direction's centres
        mx = sum(x for x, _ in cs) / len(cs)
        my = sum(y for _, y in cs) / len(cs)
        cx, cy = min(cs, key=lambda c: (c[0] - mx) ** 2 + (c[1] - my) ** 2)
        dl.text((cx, cy), KO[d], fill=DIRS[d][1], font=f, anchor="mm", stroke_width=3, stroke_fill=(255, 255, 255))
    # legend
    lf = font(px // 64)
    y = 10
    for d, (_, col) in DIRS.items():
        if d in labels:
            dl.rectangle((10, y, 10 + px // 64, y + px // 64), fill=col)
            dl.text((20 + px // 64, y), f"{KO[d]} ({len(labels[d])} tris)", fill=(0, 0, 0), font=lf)
            y += px // 50
    lines.save(os.path.join(out, f"{name}_uv.png"))
    mask.save(os.path.join(out, f"{name}_uv_mask.png"))
    if over is not None:
        o = over.convert("RGBA")
        lr = lines.convert("RGBA")
        # white -> transparent so only the lines sit on the art
        arr = np.array(lr)
        white = (arr[:, :, 0] > 245) & (arr[:, :, 1] > 245) & (arr[:, :, 2] > 245)
        arr[white, 3] = 0
        o.alpha_composite(Image.fromarray(arr))
        o.convert("RGB").save(os.path.join(out, f"{name}_uv_over.png"))
    print(f"{name}: {sum(len(p['idx']) for p in parts)} tris, dirs {sorted(labels)} -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
