# Warp each concept view's material labels onto the mesh's own features (pp-3d-make 10-20).
# Hunyuan's shape is close to the concept but its straps / panels sit a little elsewhere, so a straight projection
# paints camo. Here a dense optical flow (OpenCV DIS) between the mesh's grey render (mesh_views.py, same framing)
# and the concept's shading (concept brightness / its material's brightness = geometry only) moves the label map so
# borders land on the mesh's real creases. Then label_bake.py samples the warped maps with register=0.
#   py -I tools/blender/flow_warp.py <views_lab.json> <palette.json> <mesh_views_dir> <concept_views.json> <out_dir>
import sys, json, os
import numpy as np, cv2
from PIL import Image
from scipy import ndimage

lj, pj, md, cj, od = sys.argv[1:6]
lab_cfg = json.load(open(lj, encoding="utf-8")); con_cfg = json.load(open(cj, encoding="utf-8"))
pal = json.load(open(pj, encoding="utf-8")); os.makedirs(od, exist_ok=True)
cols = np.array([[int(p["hex"][i:i + 2], 16) for i in (1, 3, 5)] for p in pal], np.float32)
pv = cols.max(1) / 255
out = dict(lab_cfg); out["views"] = {}
dis = cv2.DISOpticalFlow_create(cv2.DISOPTICAL_FLOW_PRESET_MEDIUM)
dis.setFinestScale(1); dis.setGradientDescentIterations(25); dis.setVariationalRefinementAlpha(20)
clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
for name, v in lab_cfg["views"].items():
    lp, ox, oy, w, h = v
    lab = np.asarray(Image.open(lp)).astype(np.int32)
    S = lab.shape[0]
    con = np.asarray(Image.open(con_cfg["views"][name][0]).convert("RGB")).astype(np.float32) / 255
    obj_c = lab != 255
    shade = np.ones(lab.shape, np.float32)
    shade[obj_c] = con.max(-1)[obj_c] / np.maximum(pv[lab[obj_c]], 0.05)
    shade = np.clip(shade * 0.75, 0, 1); shade[~obj_c] = 1.0
    mr = Image.open(os.path.join(md, name + ".png")).convert("RGBA").resize((w, h), Image.LANCZOS)
    m = np.asarray(mr).astype(np.float32) / 255
    mg = np.ones(lab.shape, np.float32); ma = np.zeros(lab.shape, np.float32)
    mg[oy:oy + h, ox:ox + w] = m[..., :3].mean(-1) * m[..., 3] + (1 - m[..., 3])
    ma[oy:oy + h, ox:ox + w] = m[..., 3]
    obj_m = ma > 0.5
    a8 = clahe.apply((mg * 255).astype(np.uint8)); b8 = clahe.apply((shade * 255).astype(np.uint8))
    a8 = cv2.GaussianBlur(a8, (0, 0), 1.2); b8 = cv2.GaussianBlur(b8, (0, 0), 1.2)
    flow = dis.calc(a8, b8, None)
    # keep the flow smooth (parts move together)
    flow = np.stack([ndimage.gaussian_filter(flow[..., k], 3) for k in range(2)], -1)
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float32)
    mx, my = xx + flow[..., 0], yy + flow[..., 1]
    wl = cv2.remap(lab.astype(np.float32), mx, my, cv2.INTER_NEAREST, borderValue=255).astype(np.int32)
    # mesh pixels that landed on concept background take the nearest object label
    bad = obj_m & (wl == 255)
    if bad.any():
        idx = ndimage.distance_transform_edt(wl == 255, return_distances=False, return_indices=True)
        wl[bad] = wl[idx[0], idx[1]][bad]
    wl[~obj_m] = 255
    Image.fromarray(wl.astype(np.uint8)).save(os.path.join(od, f"{name}_lab.png"))
    prev = np.full(lab.shape + (3,), 255, np.uint8)
    prev[obj_m] = (cols[wl[obj_m]] * 0.6 + 0.4 * mg[obj_m, None] * 255).astype(np.uint8)
    straight = np.full(lab.shape + (3,), 255, np.uint8); keep = obj_m & (lab != 255)
    straight[keep] = (cols[lab[keep]] * 0.6 + 0.4 * mg[keep, None] * 255).astype(np.uint8)
    Image.fromarray(np.concatenate([straight, prev, np.repeat(a8[..., None], 3, -1), np.repeat(b8[..., None], 3, -1)], 1)).save(
        os.path.join(od, f"{name}_check.png"))
    out["views"][name] = [os.path.abspath(os.path.join(od, f"{name}_lab.png")).replace("\\", "/"), ox, oy, w, h]
    print(name, "flow px mean", round(float(np.abs(flow[obj_m]).mean()), 1), "max", round(float(np.abs(flow[obj_m]).max()), 1))
json.dump(out, open(os.path.join(od, "views_lab.json"), "w", encoding="utf-8"), indent=1)
print("ok", os.path.join(od, "views_lab.json"))
