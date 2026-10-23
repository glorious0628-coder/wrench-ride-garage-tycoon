# Score how well a Hunyuan mesh matches its 6-view concept (pp-3d-make 10-20), to pick the best seed.
# Uses mesh_views.py renders (same framing as the concept cells): per view silhouette IoU (object box mapped onto the
# concept's box) and edge agreement (share of mesh crease/outline edges within 4 px of a concept edge, and back).
#   py -I tools/blender/shape_score.py <concept views.json> <mesh_views_dir> [<mesh_views_dir> ...]
import sys, json, os
import numpy as np, cv2
from PIL import Image
from scipy import ndimage

cfg = json.load(open(sys.argv[1], encoding="utf-8"))
W8 = {"front": 1, "back": 1, "left": 1.5, "right": 1.5, "top": 1, "bottom": 0.3}


def edges(g, mask):
    e = cv2.Canny(cv2.GaussianBlur((g * 255).astype(np.uint8), (0, 0), 1.5), 30, 80) > 0
    return e & ndimage.binary_dilation(mask, iterations=2)


for md in sys.argv[2:]:
    tot = 0; wsum = 0; parts = []
    for name, (path, ox, oy, w, h) in cfg["views"].items():
        con = np.asarray(Image.open(path).convert("RGB")).astype(np.float32) / 255
        cm = ndimage.binary_fill_holes(con.min(-1) < 0.975)
        m = np.asarray(Image.open(os.path.join(md, name + ".png")).convert("RGBA").resize((w, h), Image.LANCZOS)).astype(np.float32) / 255
        mg = np.ones(cm.shape, np.float32); mm = np.zeros(cm.shape, bool)
        mg[oy:oy + h, ox:ox + w] = m[..., :3].mean(-1) * m[..., 3] + (1 - m[..., 3]); mm[oy:oy + h, ox:ox + w] = m[..., 3] > 0.5
        iou = (cm & mm).sum() / max((cm | mm).sum(), 1)
        ec = edges(con.mean(-1), cm); em = edges(mg, mm)
        dc = ndimage.distance_transform_edt(~ec); dm = ndimage.distance_transform_edt(~em)
        e1 = (dc[em] < 4).mean() if em.any() else 0; e2 = (dm[ec] < 4).mean() if ec.any() else 0
        sc = 0.5 * iou + 0.25 * e1 + 0.25 * e2
        parts.append(f"{name} iou{iou:.2f} e{e1:.2f}/{e2:.2f}")
        tot += W8[name] * sc; wsum += W8[name]
    print(f"{tot / wsum:.3f}", md, "|", "; ".join(parts))
