# Concept cell vs 3D render, same height (pp-3d-props 10-20) - for sheets tools/split_6view.py can't split (touching
# views, cut by hand) or whose views map to other model sides. Writes concept | 3D | 50 % overlay | outlines and
# prints w/h diff, IoU and the outline gap p95 / max (% of height), like check2_run's cmp_table.
#   py -I tools/cell_compare.py <out_dir> <name>=<concept_cell.png>:<render.png> [...]
import os, sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

H = 600


def fg(img):
    a = np.asarray(img.convert("RGBA")).astype(int)
    if (a[..., 3] < 250).any():
        return a[..., 3] > 40
    rgb = a[..., :3]
    corner = np.median(np.concatenate([rgb[:8, :8].reshape(-1, 3), rgb[-8:, -8:].reshape(-1, 3)]), 0)
    return np.abs(rgb - corner).sum(2) > 40


def crop(path):
    im = Image.open(path).convert("RGBA"); m = fg(im)
    ys, xs = np.where(m); box = (xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)
    im = im.crop(box); m = m[box[1]:box[3], box[0]:box[2]]
    w = max(1, round(im.width * H / im.height))
    return im.resize((w, H), Image.LANCZOS), np.asarray(Image.fromarray(m.astype(np.uint8) * 255).resize((w, H))) > 127


def main():
    out = sys.argv[1]; os.makedirs(out, exist_ok=True)
    print("side    w/h diff   IoU    outline gap p95 / max (% of height)")
    for arg in sys.argv[2:]:
        name, pair = arg.split("=", 1); cp, rp = pair.split(":")
        ci, cm = crop(cp); ri, rm = crop(rp)
        W = max(ci.width, ri.width)
        A = np.zeros((H, W), bool); Bm = np.zeros((H, W), bool)
        ox_c, ox_r = (W - ci.width) // 2, (W - ri.width) // 2
        A[:, ox_c:ox_c + ci.width] = cm; Bm[:, ox_r:ox_r + ri.width] = rm
        iou = (A & Bm).sum() / max(1, (A | Bm).sum())
        ea = A ^ ndimage.binary_erosion(A); eb = Bm ^ ndimage.binary_erosion(Bm)
        da = ndimage.distance_transform_edt(~ea); db = ndimage.distance_transform_edt(~eb)
        gaps = np.concatenate([db[ea], da[eb]])
        p95, mx = np.percentile(gaps, 95) / H * 100, gaps.max() / H * 100
        wh = (ri.width / ri.height) / (ci.width / ci.height) - 1
        print("%-7s %+6.1f%%   %.3f   %4.1f%% / %4.1f%%" % (name, wh * 100, iou, p95, mx))
        sheet = Image.new("RGB", (W * 4, H), "white")
        bg = lambda im: (lambda b: (b.alpha_composite(im), b)[1])(Image.new("RGBA", im.size, (255, 255, 255, 255)))
        sheet.paste(bg(ci).convert("RGB"), (ox_c, 0)); sheet.paste(bg(ri).convert("RGB"), (W + ox_r, 0))
        ov = Image.new("RGBA", (W, H), (255, 255, 255, 255)); ov.alpha_composite(ci, (ox_c, 0))
        r2 = ri.copy(); r2.putalpha(r2.getchannel("A").point(lambda v: v // 2)); ov.alpha_composite(r2, (ox_r, 0))
        sheet.paste(ov.convert("RGB"), (2 * W, 0))
        ol = np.full((H, W, 3), 255, np.uint8); ol[ndimage.binary_dilation(ea)] = (220, 30, 30); ol[ndimage.binary_dilation(eb)] = (30, 60, 230)
        sheet.paste(Image.fromarray(ol), (3 * W, 0))
        sheet.save(os.path.join(out, "cmp_%s.png" % name))


if __name__ == "__main__":
    main()
