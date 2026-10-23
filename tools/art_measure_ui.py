"""Measure the b3 redraws: button canvas/box vs the normal button, balancer pivot/arc positions."""
import math, sys
from PIL import Image

ROOT = "C:/Users/glori/Documents/Roblox/Wrench & Ride Garage Tycoon/"


def box(im, t=128):
    a = im.split()[3].point(lambda v: 255 if v > t else 0)
    return a.getbbox()


def buttons(src):
    for n in ("blue", "gray", "orange"):
        a = Image.open(ROOT + f"art/ui/kit_B/button_{n}.png")
        try:
            b = Image.open(ROOT + f"{src}/button_{n}_pressed.png")
        except FileNotFoundError:
            print(n, "missing"); continue
        ba, bb = box(a), box(b)
        ra = (ba[3] - ba[1]) / (ba[2] - ba[0]); rb = (bb[3] - bb[1]) / (bb[2] - bb[0])
        print(f"{n}: normal {a.size} {ba} h/w {ra:.3f} | pressed {b.size} {bb} h/w {rb:.3f}")


def dial_hub(path):
    """Find the silver hub: low-saturation bright pixels near the vertical centre line."""
    im = Image.open(path).convert("RGBA"); w, h = im.size; px = im.load()
    xs = ys = n = 0
    for y in range(int(h * 0.3), int(h * 0.75)):
        for x in range(int(w * 0.35), int(w * 0.65)):
            r, g, b, a = px[x, y]
            if a > 200 and max(r, g, b) > 150 and max(r, g, b) - min(r, g, b) < 25:
                xs += x; ys += y; n += 1
    return (xs / n, ys / n, n) if n else None


def zone_arc(path, c):
    im = Image.open(path).convert("RGBA"); w, h = im.size; px = im.load()
    rs = []; angs = []
    for y in range(h):
        for x in range(w):
            if px[x, y][3] > 128:
                dx, dy = x - c[0], c[1] - y
                rs.append(math.hypot(dx, dy)); angs.append(math.degrees(math.atan2(dx, dy)))
    rs.sort(); angs.sort()
    k = len(rs) // 100
    return dict(r_in=rs[k] / w, r_out=rs[-k - 1] / w, ang_from=angs[k], ang_to=angs[-k - 1])


if __name__ == "__main__":
    what = sys.argv[1]
    if what == "buttons":
        buttons(sys.argv[2])
    elif what == "dial":
        p = sys.argv[2]; im = Image.open(p); print(im.size, "box", box(im), "hub", dial_hub(p))
    elif what == "zone":
        c = (float(sys.argv[3]), float(sys.argv[4])); im = Image.open(sys.argv[2]); print(im.size, zone_arc(sys.argv[2], c))
    elif what == "needle":
        p = sys.argv[2]; im = Image.open(p); print(im.size, "box", box(im), "hub", dial_hub(p))
