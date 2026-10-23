# Concept outline -> per-height extents for a lofted 3D shape (pp-3d-props 10-20, user: "외곽선을 그대로 따야 안
# 울퉁불퉁하지 않음?"). For one part (picked by colour inside a box of the split 6-view cells), every pixel row gives the
# part's left/right edge in the front cell and front/back edge in the left cell; the back and right cells (mirror views)
# are averaged in. The edge curves are smoothed (gaussian) so the 3D outline follows the concept as a clean curve,
# not a pixel staircase. Output JSON: rows of (z, x0, x1, y0, y1) in concept px, in the build axes
# (X = cx_front - x, Y = cx_left - x, Z = ground - y).
#   py -I tools/silhouette_extents.py <cell_prefix> <out.json> --part green --cx-front 321 --cx-left 330 --ground 620
#      [--zmin 0 --zmax 9999] [--box-front x0,y0,x1,y1] [--box-left x0,y0,x1,y1] [--sigma 3]
import argparse, json
import numpy as np
from PIL import Image
from scipy import ndimage


def mask(path, part, box):
    a = np.asarray(Image.open(path).convert("RGB")).astype(float) / 255
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    if part == "green":
        m = (g > r + 0.06) & (g > b + 0.04) & (a.min(2) < 0.92)
    elif part == "brown":
        m = (r > g + 0.12) & (r > b + 0.12)
    else:
        m = a.min(2) < 0.92
    m = ndimage.binary_closing(m, iterations=3)
    m = ndimage.binary_fill_holes(m)
    if box:
        x0, y0, x1, y1 = box
        keep = np.zeros_like(m); keep[y0:y1 + 1, x0:x1 + 1] = True; m &= keep
    lab, n = ndimage.label(m)
    if n > 1:   # the biggest piece only (specks / a neighbour's edge)
        sizes = ndimage.sum(m, lab, range(1, n + 1)); m = lab == (1 + int(np.argmax(sizes)))
    return m


def edges(m):
    """per row: (min col, max col) or None"""
    out = []
    for row in m:
        xs = np.where(row)[0]
        out.append((xs.min(), xs.max()) if len(xs) else None)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("prefix"); ap.add_argument("out")
    ap.add_argument("--part", default="green")
    ap.add_argument("--cx-front", type=float, required=True); ap.add_argument("--cx-left", type=float, required=True)
    ap.add_argument("--ground", type=float, required=True)
    ap.add_argument("--box-front"); ap.add_argument("--box-left"); ap.add_argument("--sigma", type=float, default=3)
    ap.add_argument("--no-mirror", action="store_true", help="front/left only (back/right differ)")
    ap.add_argument("--view", default="front", choices=["front", "left"],
                    help="--columns: which cell (left = the side view, its mirror = right; centre --cx-left)")
    ap.add_argument("--columns", action="store_true",
                    help="flat parts (pine pads): per FRONT column the part's bottom/top -> cols (X, z0, z1); the "
                         "top line keeps its bumps (row extents would flatten them)")
    a = ap.parse_args()
    if a.columns:
        return columns(a)
    bf = [int(v) for v in a.box_front.split(",")] if a.box_front else None
    bl = [int(v) for v in a.box_left.split(",")] if a.box_left else None
    W = Image.open(a.prefix + "_front.png").width
    mf = mask(a.prefix + "_front.png", a.part, bf); ml = mask(a.prefix + "_left.png", a.part, bl)
    if not a.no_mirror:   # the back / right cells are mirror views of front / left: flip them and keep the average
        mb = mask(a.prefix + "_back.png", a.part, [W - 1 - bf[2], bf[1], W - 1 - bf[0], bf[3]] if bf else None)[:, ::-1]
        mr = mask(a.prefix + "_right.png", a.part, [W - 1 - bl[2], bl[1], W - 1 - bl[0], bl[3]] if bl else None)[:, ::-1]
    ef, el = edges(mf), edges(ml)
    if not a.no_mirror:
        eb, er = edges(mb), edges(mr)
    rows = [y for y in range(len(ef)) if ef[y] is not None and el[y] is not None]
    y0, y1 = min(rows), max(rows)
    ys = np.arange(y0, y1 + 1)

    def series(e, e2, k):
        v = []
        for y in ys:
            c = [x[k] for x in (e[y], e2[y] if e2 is not None else None) if x is not None]
            v.append(np.mean(c) if c else np.nan)
        v = np.array(v, float)
        bad = np.isnan(v)
        if bad.any():
            v[bad] = np.interp(np.where(bad)[0], np.where(~bad)[0], v[~bad])
        return ndimage.gaussian_filter1d(v, a.sigma, mode="nearest")
    fx0 = series(ef, None if a.no_mirror else eb, 0); fx1 = series(ef, None if a.no_mirror else eb, 1)
    lx0 = series(el, None if a.no_mirror else er, 0); lx1 = series(el, None if a.no_mirror else er, 1)
    out = []
    for i, y in enumerate(ys):
        # image left = +X in the front view, image left = +Y (front) in the left view
        out.append([round(a.ground - y, 2), round(a.cx_front - fx1[i], 2), round(a.cx_front - fx0[i], 2),
                    round(a.cx_left - lx1[i], 2), round(a.cx_left - lx0[i], 2)])
    json.dump({"rows": out}, open(a.out, "w"), indent=0)
    print("rows", len(out), "z", out[0][0], "..", out[-1][0], "max width", max(r[2] - r[1] for r in out),
          "max depth", max(r[4] - r[3] for r in out))


def columns(a):
    v1, v2, cx = ("front", "back", a.cx_front) if a.view == "front" else ("left", "right", a.cx_left)
    bf = [int(v) for v in (a.box_front if a.view == "front" else a.box_left).split(",")]
    W = Image.open(a.prefix + "_%s.png" % v1).width
    mf = mask(a.prefix + "_%s.png" % v1, a.part, bf)
    mb = None if a.no_mirror else mask(a.prefix + "_%s.png" % v2, a.part, [W - 1 - bf[2], bf[1], W - 1 - bf[0], bf[3]])[:, ::-1]
    xs = [x for x in range(W) if mf[:, x].any()]
    x0, x1 = min(xs), max(xs)
    top, bot = [], []
    for x in range(x0, x1 + 1):
        c = [m[:, x] for m in (mf, mb) if m is not None and m[:, x].any()]
        top.append(np.mean([np.where(m)[0].min() for m in c])); bot.append(np.mean([np.where(m)[0].max() for m in c]))
    top = ndimage.gaussian_filter1d(np.array(top), a.sigma, mode="nearest")
    bot = ndimage.gaussian_filter1d(np.array(bot), a.sigma, mode="nearest")
    out = [[round(cx - x, 2), round(a.ground - bot[i], 2), round(a.ground - top[i], 2)]
           for i, x in enumerate(range(x0, x1 + 1))]
    json.dump({"cols": out}, open(a.out, "w"), indent=0)
    print("cols", len(out), "X", out[0][0], "..", out[-1][0], "Z", min(c[1] for c in out), "..", max(c[2] for c in out))


if __name__ == "__main__":
    main()
