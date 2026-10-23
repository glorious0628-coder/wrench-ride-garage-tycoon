"""Does a game GLB fit its slot? (pp-3d-gear 10-20) Plain Python, no Blender.
  py -I tools/blender/slot_fit.py <file.glb> <slot or weapon name> [--budget 5000]
Slot names / sizes: notes/design/3d_tools/gear_slots.json (copy of gear_slots.md).
- slot: the game stretches the mesh to the slot's size on each axis -> any ratio difference is a squash. Prints the
  per-axis stretch and the squash % (over 3% = remake the shape to the slot ratio, never stretch).
- weapon: the GLB origin must be the grip (fist centre), front -Z. The game scales by length (Z) and puts the bbox
  centre at the spec centre -> prints where the grip lands, both ends and the width/height vs the spec.
Also: triangles vs budget, texture sizes (<= 1024), doubleSided (must be false).
"""
import json
import os
import struct
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
SPEC = os.path.join(HERE, "..", "..", "notes", "design", "3d_tools", "gear_slots.json")
CM = {5126: "<f4", 5123: "<u2", 5125: "<u4", 5121: "u1"}
NT = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}


def quat_mat(q):
    x, y, z, w = q
    return np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                     [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                     [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]])


def node_mat(n):
    if "matrix" in n:
        return np.array(n["matrix"], float).reshape(4, 4).T
    m = np.eye(4)
    m[:3, :3] = quat_mat(n.get("rotation", [0, 0, 0, 1])) @ np.diag(n.get("scale", [1, 1, 1]))
    m[:3, 3] = n.get("translation", [0, 0, 0])
    return m


def load(path):
    b = open(path, "rb").read()
    jl = struct.unpack("<I", b[12:16])[0]
    j = json.loads(b[20:20 + jl])
    binary = b[20 + jl + 8:]

    def acc(i):
        a = j["accessors"][i]
        v = j["bufferViews"][a["bufferView"]]
        n = NT[a["type"]]
        return np.frombuffer(binary, CM[a["componentType"]], a["count"] * n, v.get("byteOffset", 0) + a.get("byteOffset", 0)).reshape(-1, n)

    pts, tris = [], 0

    def walk(ni, parent):
        n = j["nodes"][ni]
        m = parent @ node_mat(n)
        if "mesh" in n:
            for p in j["meshes"][n["mesh"]]["primitives"]:
                pos = acc(p["attributes"]["POSITION"]).astype(float)
                pts.append((np.c_[pos, np.ones(len(pos))] @ m.T)[:, :3])
                nonlocal tris
                tris += (j["accessors"][p["indices"]]["count"] if "indices" in p else len(pos)) // 3
        for c in n.get("children", []):
            walk(c, m)

    for ni in j["scenes"][j.get("scene", 0)]["nodes"]:
        walk(ni, np.eye(4))
    P = np.concatenate(pts)
    sizes = []
    for im in j.get("images", []):
        v = j["bufferViews"][im["bufferView"]]
        data = binary[v.get("byteOffset", 0):v.get("byteOffset", 0) + v["byteLength"]]
        if data[:8] == b"\x89PNG\r\n\x1a\n":
            sizes.append(struct.unpack(">II", data[16:24]))
        else:
            sizes.append(("?", im.get("mimeType")))
    double = [m.get("doubleSided", False) for m in j.get("materials", [])]
    return P.min(0), P.max(0), tris, sizes, double


def main():
    a = sys.argv[1:]
    if len(a) < 2:
        print(__doc__)
        return 2
    budget = int(a[a.index("--budget") + 1]) if "--budget" in a else 5000
    spec = json.load(open(SPEC, encoding="utf-8"))
    # (pp-3d-field 10-20) the field props' slots too: notes/design/3d_tools/field_slots.json, same format
    field = os.path.join(os.path.dirname(SPEC), "field_slots.json")
    if os.path.exists(field):
        for k, v in json.load(open(field, encoding="utf-8"))["slots"].items():
            spec["slots"].setdefault(k, v)
    lo, hi, tris, texs, double = load(a[0])
    size = hi - lo
    centre = (lo + hi) / 2
    ok = True
    print("GLB size X,Y,Z = %.3f, %.3f, %.3f   bbox centre = (%.3f, %.3f, %.3f)" % (*size, *centre))
    print("tris %d / budget %d %s" % (tris, budget, "OK" if tris <= budget else "OVER"))
    ok &= tris <= budget
    big = [t for t in texs if t[0] == "?" or max(t) > 1024]
    print("textures", texs, "OK" if not big else "OVER 1024 / unknown")
    ok &= not big
    print("doubleSided", double, "OK" if not any(double) else "must be false")
    ok &= not any(double)
    name = a[1]
    if name in spec["slots"]:
        s = np.array(spec["slots"][name]["size"], float)
        k = s / np.maximum(size, 1e-6)
        squash = (k.max() / k.min() - 1) * 100
        print("slot %s size %s -> stretch per axis X %.3f  Y %.3f  Z %.3f" % (name, s.tolist(), *k))
        print("squash %.1f%% %s" % (squash, "OK" if squash <= 3 else "TOO MUCH (make the shape to the slot ratio)"))
        ok &= squash <= 3
    elif name in spec["weapons"]:
        w = spec["weapons"][name]
        k = w["size"][2] / size[2]
        c = centre * k
        print("weapon %s: game scale %.3f (length %.3f -> %.2f)" % (name, k, size[2], w["size"][2]))
        print("  bbox centre from grip  (%.3f, %.3f, %.3f)   spec (%.3f, %.3f, %.3f)" % (*c, *w["center"]))
        print("  front end z %.3f (spec %.2f)   back end z %.3f (spec %.2f)" % (lo[2] * k, w["front"], hi[2] * k, w["back"]))
        print("  width %.3f (spec %.2f)   height %.3f (spec %.2f)" % (size[0] * k, w["size"][0], size[1] * k, w["size"][1]))
        off = np.abs(c - np.array(w["center"])).max()
        print("  grip offset %.3f %s" % (off, "OK" if off <= 0.06 else "MOVE: the hand would miss the handle"))
        print("  (new GLB: give dev its real size + centre for WEAPON_MESH; width/height may differ from the spec)")
        ok &= off <= 0.06
    else:
        print("unknown name; slots:", ", ".join(spec["slots"]), "| weapons:", ", ".join(spec["weapons"]))
        return 2
    print("RESULT", "OK" if ok else "FIX")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
