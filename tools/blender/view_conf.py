# Per-view local alignment confidence (pp-3d-make 10-20, GPT sneaker_tex_r1: "gate votes by local alignment").
# Where the mesh render's edges (mesh_views.py) sit on the concept's edges, that view's labels are trusted; where
# they disagree (e.g. a collar Hunyuan made bigger) the view's vote counts little and other views decide.
#   py -I tools/blender/view_conf.py <views_lab.json> <concept views.json> <mesh_views_dir> <out_views.json> [win=41]
# Adds a 6th field to every view: path of <view>_conf.png (0..255) next to the label maps.
import sys, json, os
import numpy as np, cv2
from PIL import Image
from scipy import ndimage

lj, cj, md, oj = sys.argv[1:5]; WIN = int(sys.argv[5]) if len(sys.argv) > 5 else 41
lab_cfg = json.load(open(lj, encoding="utf-8")); con_cfg = json.load(open(cj, encoding="utf-8"))


def edges(g, mask):
    e = cv2.Canny(cv2.GaussianBlur((g * 255).astype(np.uint8), (0, 0), 1.5), 30, 80) > 0
    return e & ndimage.binary_dilation(mask, iterations=2)


out = dict(lab_cfg); out["views"] = {}
for name, v in lab_cfg["views"].items():
    lp, ox, oy, w, h = v[:5]
    con = np.asarray(Image.open(con_cfg["views"][name][0]).convert("RGB")).astype(np.float32) / 255
    cm = ndimage.binary_fill_holes(con.min(-1) < 0.975)
    m = np.asarray(Image.open(os.path.join(md, name + ".png")).convert("RGBA").resize((w, h), Image.LANCZOS)).astype(np.float32) / 255
    mg = np.ones(cm.shape, np.float32); mm = np.zeros(cm.shape, bool)
    mg[oy:oy + h, ox:ox + w] = m[..., :3].mean(-1) * m[..., 3] + (1 - m[..., 3]); mm[oy:oy + h, ox:ox + w] = m[..., 3] > 0.5
    ec = edges(con.mean(-1), cm); em = edges(mg, mm)
    dc = ndimage.distance_transform_edt(~ec); dm = ndimage.distance_transform_edt(~em)
    good = (em & (dc < 4)).astype(np.float32) + (ec & (dm < 4)).astype(np.float32)
    allv = em.astype(np.float32) + ec.astype(np.float32)
    g = ndimage.uniform_filter(good, WIN); a = ndimage.uniform_filter(allv, WIN)
    dens = a / max(float(a.max()), 1e-6)
    conf = np.where(a > 1e-4, g / np.maximum(a, 1e-6), 0.7)
    conf = np.where(dens < 0.08, 0.7, conf)  # smooth areas: neutral
    conf = np.clip(conf, 0.05, 1.0)
    cp = os.path.join(os.path.dirname(lp), f"{name}_conf.png")
    Image.fromarray((conf * 255).astype(np.uint8)).save(cp)
    out["views"][name] = [lp, ox, oy, w, h, os.path.abspath(cp).replace("\\", "/")]
    print(name, "conf mean in object", round(float(conf[cm].mean()), 2))
json.dump(out, open(oj, "w", encoding="utf-8"), indent=1)
print("ok", oj)
