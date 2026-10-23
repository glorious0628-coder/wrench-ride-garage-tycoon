# One small shared atlas for the street props (Cartoon City, RG Poly, CC0).
#   python -I build_atlas.py <props_config.json> <_src dir (x/x/*.glb + Textures/city_atlas.png)> <out dir> [--keep]
# The pack props only touch a few thin lines / dots of the 1024 city_atlas.png (gradient strips). For every
# (prop, material, variant) the triangles are grouped into clusters of touching UV rectangles; each cluster's pixels
# (+ `margin` px) are copied 1:1 (no scaling, integer offset -> identical colours) into a slot of the new atlas,
# with `pad` px of edge-repeat around it (mip/bleed safety). Recolours keep the strip's light->dark gradient:
# out = target * (Y(pixel) / Y(ref row)) ** gamma, in linear light.
# variant: 0 = normal. A prop's "variant_rule" (same rule in export_props.py) tags triangles by position, e.g. the
# hydrant's bonnet + nozzle caps = 1; the mailbox lid (variant 1) is a whole-cluster second colour copy instead.
# --keep : the atlas is already uploaded. Keep every slot of props that did not change (same pixels, same UVs),
#          recolour a changed slot in place when only that prop uses it, and put new slots in free space only
#          (old slots nobody uses any more count as free). Size stays the same.
# Writes: <name>.png (colour), <name>_mr.png (glTF metallicRoughness: G = rough, B = metal, R = 255),
#         <name>_roughness.png / <name>_metalness.png (grey, for Roblox SurfaceAppearance), <name>_map.json (slots).
import sys, os, json, struct
import numpy as np
from PIL import Image

CT = {5126: np.float32, 5123: np.uint16, 5125: np.uint32, 5121: np.uint8}
NC = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}


def read_glb(p):
    d = open(p, "rb").read(); ln = struct.unpack("<I", d[12:16])[0]; j = json.loads(d[20:20 + ln])
    off = 20 + ln; bl = struct.unpack("<I", d[off:off + 4])[0]; bin_ = d[off + 8:off + 8 + bl]

    def acc(i):
        a = j["accessors"][i]; bv = j["bufferViews"][a["bufferView"]]
        o = bv.get("byteOffset", 0) + a.get("byteOffset", 0); n = a["count"] * NC[a["type"]]
        arr = np.frombuffer(bin_, dtype=CT[a["componentType"]], count=n, offset=o)
        return arr.reshape(a["count"], NC[a["type"]]) if NC[a["type"]] > 1 else arr
    return j, acc


def rule_variant(rule, pts):
    """pts: triangle / face vertices in the Blender import frame (x, y = -glTF z, z = glTF y), metres.
    rule = {"variant": n, "any": [{"coord": "y", "offset": 0.003, "abs": true, "min_ge": 0.2675}, ...]}"""
    if not rule:
        return 0
    for c in rule["any"]:
        k = "xyz".index(c["coord"])
        vals = [p[k] + c.get("offset", 0.0) for p in pts]
        if c.get("abs"):
            vals = [abs(v) for v in vals]
        if min(vals) >= c["min_ge"]:
            return rule["variant"]
    return 0


def tri_rects(glb, size, rule=None):
    """{(material name, variant): [ (x0,y0,x1,y1) px of each triangle's UVs ]}"""
    j, acc = read_glb(glb); out = {}
    for me in j["meshes"]:
        for pr in me["primitives"]:
            uv = acc(pr["attributes"]["TEXCOORD_0"]).astype(np.float64) * size
            pos = acc(pr["attributes"]["POSITION"]).astype(np.float64)
            idx = acc(pr["indices"]).reshape(-1, 3)
            assert uv.min() >= 0 and uv.max() <= size, (glb, uv.min(), uv.max())   # no wrapping in these props
            mn = j["materials"][pr["material"]]["name"]
            for t in idx:
                p = uv[t]
                bl = [(q[0], -q[2], q[1]) for q in pos[t]]
                out.setdefault((mn, rule_variant(rule, bl)), []).append((p[:, 0].min(), p[:, 1].min(), p[:, 0].max(), p[:, 1].max()))
    return out


def cluster(rects, gap=2.0):
    """union rectangles that touch (within gap px) -> list of bounding rects"""
    par = list(range(len(rects)))

    def f(i):
        while par[i] != i:
            par[i] = par[par[i]]; i = par[i]
        return i
    for i, a in enumerate(rects):
        for k in range(i + 1, len(rects)):
            b = rects[k]
            if a[0] - gap <= b[2] and b[0] - gap <= a[2] and a[1] - gap <= b[3] and b[1] - gap <= a[3]:
                par[f(i)] = f(k)
    groups = {}
    for i, r in enumerate(rects):
        groups.setdefault(f(i), []).append(r)
    return [(min(r[0] for r in g), min(r[1] for r in g), max(r[2] for r in g), max(r[3] for r in g)) for g in groups.values()]


def s2l(c):
    c = c / 255.0
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def l2s(c):
    c = np.clip(c, 0, 1)
    return np.where(c <= 0.0031308, c * 12.92, 1.055 * c ** (1 / 2.4) - 0.055) * 255.0


def hex_rgb(h):
    h = h.lstrip("#"); return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=np.float64)


def recolour(block, ref_rgb, target_hex, gamma=1.0):
    """keep the block's brightness pattern relative to ref, in the target colour (linear light)"""
    w = np.array([0.2126, 0.7152, 0.0722])
    y = (s2l(block.astype(np.float64)) * w).sum(-1, keepdims=True)
    yref = (s2l(np.asarray(ref_rgb, dtype=np.float64)) * w).sum()
    return l2s(s2l(hex_rgb(target_hex)) * (y / yref) ** gamma).round().astype(np.uint8)


def overlap(a, b):
    return a[0] <= b[2] and b[0] <= a[2] and a[1] <= b[3] and b[1] <= a[3]


def make_slots(items):
    """share slots: same look + same metal/rough + overlapping source rects -> one slot (union rect)"""
    slots = []
    for it in items:
        hit = next((s for s in slots if s["look"] == it["look"] and s["mr"] == it["mr"] and overlap(s["rect"], it["rect"])), None)
        if hit:
            a, b = hit["rect"], it["rect"]
            hit["rect"] = (min(a[0], b[0]), min(a[1], b[1]), max(a[2], b[2]), max(a[3], b[3])); hit["users"].append(it)
        else:
            slots.append({"rect": it["rect"], "look": it["look"], "mr": it["mr"], "users": [it]})
    merged = True
    while merged:
        merged = False
        for i in range(len(slots)):
            for k in range(i + 1, len(slots)):
                A, Bs = slots[i], slots[k]
                if A["look"] == Bs["look"] and A["mr"] == Bs["mr"] and overlap(A["rect"], Bs["rect"]):
                    a, b = A["rect"], Bs["rect"]
                    A["rect"] = (min(a[0], b[0]), min(a[1], b[1]), max(a[2], b[2]), max(a[3], b[3]))
                    A["users"] += Bs["users"]; del slots[k]; merged = True; break
            if merged:
                break
    return slots


def slot_block(city, s, pad):
    r = s["rect"]; block = city[r[1]:r[3], r[0]:r[2]]
    if s["look"]:
        to, ref_row, gamma = s["look"]
        ref = city[ref_row, r[0]:r[2]].reshape(-1, 3).mean(0)
        block = recolour(block, ref, to, gamma)
    return np.pad(block, ((pad, pad), (pad, pad), (0, 0)), mode="edge")


def mr_rgb(mr):
    return (255, round(mr[1] * 255), round(mr[0] * 255))


def entry(u, s, off, pad):
    r = s["rect"]; dx, dy = s["dest"]
    return {"prop": u["prop"], "mat": u["mat"], "variant": u["variant"], "src_rect": list(u["rect"]),
            "offset_px": list(off), "slot_px": [dx, dy, dx + r[2] - r[0] + 2 * pad, dy + r[3] - r[1] + 2 * pad], "pad": pad,
            "mr": list(s["mr"]), "recolour": s["look"][0] if s["look"] else None,
            "look": list(s["look"]) if s["look"] else None, "why": u["why"]}


def find_free(occ, w, h):
    """first top-left position where a w x h box fits in the free (False) cells of occ, or None"""
    H, W = occ.shape
    if w > W or h > H:
        return None
    sat = np.zeros((H + 1, W + 1), np.int32); sat[1:, 1:] = occ.astype(np.int32).cumsum(0).cumsum(1)
    s = sat[h:, w:] - sat[:-h, w:] - sat[h:, :-w] + sat[:-h, :-w]
    ys, xs = np.nonzero(s == 0)
    if len(ys) == 0:
        return None
    k = np.lexsort((xs, ys))[0]
    return int(xs[k]), int(ys[k])


if __name__ == "__main__":
    cfg_p, src, out = sys.argv[1], sys.argv[2], sys.argv[3]
    keep = "--keep" in sys.argv[4:]
    cfg = json.load(open(cfg_p, encoding="utf-8")); os.makedirs(out, exist_ok=True)
    A = cfg["atlas"]; PAD, M = A["pad"], A["margin"]; name = A["name"]
    city = np.asarray(Image.open(os.path.join(src, "Textures", "city_atlas.png")).convert("RGB"))
    S = city.shape[0]; assert city.shape[:2] == (1024, 1024)
    # 1) clusters per (prop, material, variant); attach look = (target, ref row, gamma) and metal/rough
    items = []
    for p in cfg["props"]:
        rects = tri_rects(os.path.join(src, "x", "x", p["src"]), S, p.get("variant_rule"))
        for (mat, var), rs in sorted(rects.items()):
            for r in cluster(rs, gap=2 * M + 1):   # clusters whose margins touch become one
                r = (max(0, int(np.floor(r[0])) - M), max(0, int(np.floor(r[1])) - M),
                     min(S, int(np.ceil(r[2])) + M), min(S, int(np.ceil(r[3])) + M))
                rcs = [rc for rc in p.get("recolor", []) if rc["mat"] == mat and
                       (rc["probe"] is None or (r[0] <= rc["probe"][0] <= r[2] and r[1] <= rc["probe"][1] <= r[3]))]
                if p.get("variant_rule"):
                    rcs = [rc for rc in rcs if rc["variant"] == var]
                if not rcs:
                    rcs = [None]
                for rc in rcs:
                    mr = tuple(rc["mr"]) if rc and "mr" in rc else tuple(cfg["mr"][mat])
                    look = (rc["to"], rc["ref_row"], rc.get("gamma", 1.0)) if rc else None
                    items.append({"prop": p["name"], "mat": mat, "variant": rc["variant"] if rc else var, "rect": r,
                                  "look": look, "mr": mr, "why": rc["why"] if rc else ""})
    if not keep:
        slots = make_slots(items)
        W = A["width"]
        order = sorted(range(len(slots)), key=lambda i: -(slots[i]["rect"][3] - slots[i]["rect"][1]))
        x = y = shelf_h = 0
        for i in order:
            r = slots[i]["rect"]; w = r[2] - r[0] + 2 * PAD; h = r[3] - r[1] + 2 * PAD
            if x + w > W:
                x = 0; y += shelf_h; shelf_h = 0
            slots[i]["dest"] = (x, y); x += w; shelf_h = max(shelf_h, h)
        H = max(64, 1 << int(np.ceil(np.log2(max(y + shelf_h, 1)))))
        assert H <= 1024, H
        col = np.zeros((H, W, 3), np.uint8); col[:] = 128
        mrim = np.zeros((H, W, 3), np.uint8); mrim[..., 0] = 255; mrim[..., 1] = 255
        entries = []
        for s in slots:
            b = slot_block(city, s, PAD); dx, dy = s["dest"]
            col[dy:dy + b.shape[0], dx:dx + b.shape[1]] = b; mrim[dy:dy + b.shape[0], dx:dx + b.shape[1]] = mr_rgb(s["mr"])
            off = (dx + PAD - s["rect"][0], dy + PAD - s["rect"][1])
            entries += [entry(u, s, off, PAD) for u in s["users"]]
        report = {"slots": len(slots), "new": len(slots), "kept": 0, "in_place": 0}
    else:
        old = json.load(open(os.path.join(out, name + "_map.json"), encoding="utf-8"))
        col = np.asarray(Image.open(os.path.join(out, name + ".png")).convert("RGB")).copy()
        mrim = np.asarray(Image.open(os.path.join(out, name + "_mr.png")).convert("RGB")).copy()
        H, W = col.shape[:2]
        assert [W, H] == old["size"]

        def same_look(e, it):
            if "look" in e:                                   # map written by this version
                return (tuple(e["look"]) if e["look"] else None) == it["look"]
            return (it["look"][0] if it["look"] else None) == e["recolour"]   # first map: only the target colour stored
        okey = {}
        for e in old["entries"]:
            okey.setdefault((e["prop"], e["mat"], e["variant"], tuple(e["src_rect"])), []).append(e)
        entries, rest, in_place = [], [], {}
        for it in items:
            cands = okey.get((it["prop"], it["mat"], it["variant"], tuple(it["rect"])), [])
            same = [e for e in cands if same_look(e, it) and tuple(e["mr"]) == it["mr"]]
            if same:      # unchanged: keep the uploaded slot and UVs
                e = dict(same[0]); e.setdefault("pad", old.get("pad", PAD)); e["look"] = list(it["look"]) if it["look"] else None
                entries.append(e); continue
            if cands:     # same cluster, new colour: in place if nobody else uses that slot
                e0 = cands[0]; sp = tuple(e0["slot_px"])
                sharers = [e for e in old["entries"] if tuple(e["slot_px"]) == sp]
                if all(e["prop"] == it["prop"] for e in sharers) and len(sharers) == 1 and tuple(e0["mr"]) == it["mr"]:
                    in_place[sp] = (it, e0); continue
            rest.append(it)
        used = {tuple(e["slot_px"]) for e in entries} | set(in_place)
        # clear old slots nobody uses any more (stale pixels -> neutral), mark used ones occupied
        occ = np.zeros((H, W), bool)
        for e in old["entries"]:
            sp = tuple(e["slot_px"])
            if sp not in used:
                col[sp[1]:sp[3], sp[0]:sp[2]] = 128; mrim[sp[1]:sp[3], sp[0]:sp[2]] = (255, 255, 0)
        for sp in used:
            occ[sp[1]:sp[3], sp[0]:sp[2]] = True
        for sp, (it, e0) in in_place.items():
            pad = e0.get("pad", old.get("pad", PAD))
            s = {"rect": tuple(e0["src_rect"]), "look": it["look"], "mr": it["mr"], "dest": (sp[0], sp[1])}
            b = slot_block(city, s, pad)
            assert b.shape[:2] == (sp[3] - sp[1], sp[2] - sp[0]), (b.shape, sp)
            col[sp[1]:sp[3], sp[0]:sp[2]] = b; mrim[sp[1]:sp[3], sp[0]:sp[2]] = mr_rgb(it["mr"])
            entries.append(entry(it, s, tuple(e0["offset_px"]), pad))
        # items that fit inside a kept / recoloured slot of the same look (e.g. a colour twin of a prop) share it
        avail = []
        for e in entries:
            pad = e.get("pad", old.get("pad", PAD)); sp = e["slot_px"]; ox, oy = e["offset_px"]
            avail.append(((sp[0] + pad - ox, sp[1] + pad - oy, sp[2] - pad - ox, sp[3] - pad - oy),
                          tuple(e["look"]) if e.get("look") else None,
                          tuple(e["mr"]), e))
        rest2 = []
        for it in rest:
            hit = next((a for a in avail if a[1] == it["look"] and a[2] == it["mr"] and a[0][0] <= it["rect"][0] and a[0][1] <= it["rect"][1]
                        and it["rect"][2] <= a[0][2] and it["rect"][3] <= a[0][3]), None)
            if hit:
                e = dict(hit[3]); e.update({"prop": it["prop"], "mat": it["mat"], "variant": it["variant"], "src_rect": list(it["rect"]), "why": it["why"]})
                entries.append(e)
            else:
                rest2.append(it)
        rest = rest2
        new_slots = make_slots(rest)
        for s in sorted(new_slots, key=lambda s: -(s["rect"][3] - s["rect"][1])):
            r = s["rect"]
            for pad in (PAD, 12, 10, 8):
                pos = find_free(occ, r[2] - r[0] + 2 * pad, r[3] - r[1] + 2 * pad)
                if pos:
                    break
            assert pos, ("no free space for", r, [u["prop"] for u in s["users"]])
            s["dest"] = pos
            b = slot_block(city, s, pad); dx, dy = pos
            col[dy:dy + b.shape[0], dx:dx + b.shape[1]] = b; mrim[dy:dy + b.shape[0], dx:dx + b.shape[1]] = mr_rgb(s["mr"])
            occ[dy:dy + b.shape[0], dx:dx + b.shape[1]] = True
            off = (dx + pad - r[0], dy + pad - r[1])
            entries += [entry(u, s, off, pad) for u in s["users"]]
        report = {"slots": len({tuple(e["slot_px"]) for e in entries}), "new": len(new_slots), "kept": len(used) - len(in_place),
                  "in_place": len(in_place)}
    Image.fromarray(col).save(os.path.join(out, name + ".png"))
    Image.fromarray(mrim).save(os.path.join(out, name + "_mr.png"))
    Image.fromarray(mrim[..., 1]).save(os.path.join(out, name + "_roughness.png"))
    Image.fromarray(mrim[..., 2]).save(os.path.join(out, name + "_metalness.png"))
    json.dump({"src_size": S, "size": [int(W), int(H)], "pad": PAD, "margin": M, "slots": report["slots"], "entries": entries},
              open(os.path.join(out, name + "_map.json"), "w", encoding="utf-8"), indent=1)
    print("atlas", W, "x", H, report, len(entries), "entries")
