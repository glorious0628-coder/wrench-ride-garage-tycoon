"""Check sheet for car concepts (wr-art-cars 10-22): are the customer cars different at one glance?

Row 1 = the pictures as they are, row 2 = the same pictures as black silhouettes (everything that is not near-white),
all scaled to the same height so the outline shape is what you compare. Only a checking tool - it does not draw art.

  py -I tools/art_lineup.py <out.png> <a.png> [b.png ...] [--h 300]
"""
import sys

from PIL import Image, ImageDraw


def silhouette(img):
    g = img.convert("RGB")
    px = g.load()
    w, h = g.size
    out = Image.new("RGB", (w, h), (255, 255, 255))
    po = out.load()
    for y in range(h):
        for x in range(w):
            r, gg, b = px[x, y]
            if min(r, gg, b) < 235:
                po[x, y] = (20, 20, 20)
    return out


def main(argv):
    h = 300
    if "--h" in argv:
        i = argv.index("--h")
        h = int(argv[i + 1])
        argv = argv[:i] + argv[i + 2:]
    out, paths = argv[0], argv[1:]
    tiles = []
    for p in paths:
        im = Image.open(p).convert("RGB")
        bbox = Image.eval(im.convert("L"), lambda v: 255 if v < 235 else 0).getbbox() or (0, 0, *im.size)
        im = im.crop(bbox)
        im = im.resize((max(1, round(im.width * h / im.height)), h), Image.LANCZOS)
        tiles.append((p, im, silhouette(im)))
    pad = 20
    W = sum(t[1].width for t in tiles) + pad * (len(tiles) + 1)
    H = h * 2 + pad * 3 + 20
    sheet = Image.new("RGB", (W, H), (255, 255, 255))
    d = ImageDraw.Draw(sheet)
    x = pad
    for p, im, sil in tiles:
        sheet.paste(im, (x, pad))
        sheet.paste(sil, (x, pad * 2 + h))
        d.text((x, pad * 3 + h * 2 - 4), p.replace("\\", "/").split("/")[-1], fill=(0, 0, 0))
        x += im.width + pad
    sheet.save(out)
    print("OK", out, sheet.size)


if __name__ == "__main__":
    main(sys.argv[1:])
