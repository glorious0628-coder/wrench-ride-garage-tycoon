# Thumbnail stitcher (wr-builder, 10-21): a 1920x1080 picture from several square Studio captures.
# Studio's viewport is only ~1046 px square here, so the camera stays at ONE point and turns (look_at) for each tile;
# pictures from one point that only turn are related exactly by a rotation, so they line up without seams.
#   plan:   py -I tools/builder/thumb_stitch.py plan  <spec.json>   -> prints each tile's look_at point
#   stitch: py -I tools/builder/thumb_stitch.py stitch <spec.json>  -> writes spec["out"] (and reports holes)
# spec.json: {"pos":[x,y,z], "look":[x,y,z], "fov": target vertical FOV (deg, as Camera.FieldOfView on a 16:9 screen),
#             "tileFov": capture FOV (deg, square viewport), "w":1920, "h":1080, "tiles":["file1.jpg", ...] (plan order),
#             "out": "notes/playtest/wr-builder/thumb_x.png"}
import json
import math
import sys

import cv2
import numpy as np


def basis(fwd):
    f = np.array(fwd, float)
    f /= np.linalg.norm(f)
    r = np.cross(f, [0.0, 1.0, 0.0])  # CFrame.lookAt with world up: no roll
    r /= np.linalg.norm(r)
    u = np.cross(r, f)
    return f, r, u


def plan(spec):
    pos = np.array(spec["pos"], float)
    f, r, u = basis(np.array(spec["look"], float) - pos)
    w, h = spec.get("w", 1920), spec.get("h", 1080)
    ty = math.tan(math.radians(spec["fov"]) / 2)
    tx = ty * w / h
    tt = math.tan(math.radians(spec["tileFov"]) / 2) * 0.8  # overlap
    nx = max(1, math.ceil(tx / tt))
    ny = max(1, math.ceil(ty / tt))
    tiles = []
    for j in range(ny):
        v = ty * ((2 * j + 1) / ny - 1) * (1 if ny > 1 else 0)
        for i in range(nx):
            uu = tx * ((2 * i + 1) / nx - 1) * (1 if nx > 1 else 0)
            d = f + uu * r - v * u  # row 0 = top
            d /= np.linalg.norm(d)
            tiles.append([round(float(x), 4) for x in pos + d * 20])
    return tiles


def stitch(spec):
    pos = np.array(spec["pos"], float)
    f, r, u = basis(np.array(spec["look"], float) - pos)
    w, h = spec.get("w", 1920), spec.get("h", 1080)
    ty = math.tan(math.radians(spec["fov"]) / 2)
    tx = ty * w / h
    xs = (np.arange(w) + 0.5) / w * 2 - 1
    ys = (np.arange(h) + 0.5) / h * 2 - 1
    X, Y = np.meshgrid(xs * tx, ys * ty)
    D = f[None, None, :] + X[..., None] * r[None, None, :] - Y[..., None] * u[None, None, :]
    out = np.zeros((h, w, 3), np.float32)
    best = np.full((h, w), np.inf, np.float32)
    looks = plan(spec)
    tt = math.tan(math.radians(spec["tileFov"]) / 2)
    for file, lk in zip(spec["tiles"], looks):
        img = cv2.imread(file, cv2.IMREAD_COLOR)
        th, tw = img.shape[:2]
        tf, tr, tu = basis(np.array(lk) - pos)
        z = D @ tf
        px = (D @ tr) / z / (tt * tw / th)
        py = (D @ tu) / z / tt
        mapx = ((px + 1) / 2 * tw - 0.5).astype(np.float32)
        mapy = ((1 - py) / 2 * th - 0.5).astype(np.float32)
        m = np.maximum(np.abs(px), np.abs(py))
        ok = (z > 0) & (m < 0.985) & (m < best)
        sample = cv2.remap(img, mapx, mapy, cv2.INTER_LANCZOS4, borderMode=cv2.BORDER_REPLICATE)
        out[ok] = sample[ok]
        best[ok] = m[ok]
    holes = int(np.isinf(best).sum())
    cv2.imwrite(spec["out"], np.clip(out, 0, 255).astype(np.uint8))
    return holes


if __name__ == "__main__":
    mode, path = sys.argv[1], sys.argv[2]
    spec = json.load(open(path, encoding="utf-8"))
    if mode == "plan":
        for i, t in enumerate(plan(spec)):
            print(i, json.dumps(t))
    else:
        print("holes", stitch(spec), "->", spec["out"])
