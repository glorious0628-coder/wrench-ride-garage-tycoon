# Fit check of the fault-look parts on the sedan (wr-3d helper 10-21): overlaps (intersecting triangle pairs) and the
# smallest clearance between each new mesh and the car meshes (B_concept body + decor). Decor pieces the new parts
# REPLACE are cut out of Deco_EngineBay by box (old coolant tank + cap, old brake reservoir + cap, the first part of
# the old reservoir hose); everything else stays. Also: liquid inside its tank (at the overflow level), the hood
# opening sweep (0 .. 57.8 deg) against the wipers, and the closed hood vs the washer nozzles.
#   blender -b --factory-startup --python fit_check.py -- <out.json> <glb> [<glb> ...]
import bpy, bmesh, sys, os, json, math
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

a = sys.argv[sys.argv.index("--") + 1:]
OUTJ, GLBS = a[0], a[1:]
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
SED = os.path.join(ROOT, "art", "3d", "sedan_body")
# car (Roblox) boxes cut out of Deco_EngineBay: (lo, hi)
CUT = {"old_coolant_tank+cap": ((2.30, 2.94, -5.96), (3.06, 3.60, -5.10)),
       "old_brake_res+cap": ((-1.78, 3.08, -4.89), (-1.32, 3.44, -4.55)),
       "old_reservoir_hose_start": ((2.10, 2.90, -6.45), (2.47, 3.10, -5.85))}


def C(v):
    return (v.x, v.z, -v.y)


def bm_of(o):
    bm = bmesh.new(); bm.from_mesh(o.data); bm.transform(o.matrix_world); return bm


bpy.ops.wm.read_factory_settings(use_empty=True)
for f in (os.path.join(SED, "B_concept", "sedan_body_all.glb"), os.path.join(SED, "decor", "sedan_decor_all.glb")):
    bpy.ops.import_scene.gltf(filepath=f)
car = {}
cut_n = {}
for o in list(bpy.context.scene.objects):
    if o.type != 'MESH':
        continue
    bm = bm_of(o)
    if o.name == "Deco_EngineBay":
        dead = set()
        for k, (lo, hi) in CUT.items():
            n = 0
            for f in bm.faces:
                c = C(f.calc_center_median())
                if all(lo[i] <= c[i] <= hi[i] for i in range(3)):
                    dead.add(f); n += 1
            cut_n[k] = n
        bmesh.ops.delete(bm, geom=list(dead), context='FACES')
    car[o.name] = bm
    bpy.data.objects.remove(o)
trees = {k: BVHTree.FromBMesh(v) for k, v in car.items()}
new = {}
for g in GLBS:
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.abspath(g))
    for o in set(bpy.data.objects) - before:
        if o.type == 'MESH':
            new[o.name] = bm_of(o)
ntrees = {k: BVHTree.FromBMesh(v) for k, v in new.items()}
R = {"cut_from_Deco_EngineBay": {k: {"faces": cut_n.get(k, 0), "box_lo": list(CUT[k][0]), "box_hi": list(CUT[k][1])} for k in CUT},
     "parts": {}}


def clearance(bm, tree, step=1):
    best = 1e9; bestp = None; inside = 0
    for v in bm.verts[::step]:
        loc, nor, i, d = tree.find_nearest(v.co, 2.0)
        if loc is None:
            continue
        if (v.co - loc).dot(nor) < 0 and d < 0.3:
            inside += 1
        if d < best:
            best, bestp = d, v.co.copy()
    return best, bestp, inside


for nm, bm in new.items():
    t = ntrees[nm]; rec = {}
    for cn, ct in trees.items():
        pairs = t.overlap(ct)
        bm.verts.ensure_lookup_table(); bm.faces.ensure_lookup_table()
        d, p, inside = clearance(bm, ct, 1)
        if d > 0.6 and not pairs:
            continue
        e = {"overlap_tris": len(pairs), "min_gap": round(d, 4), "verts_inside": inside}
        if p is not None:
            e["at"] = [round(x, 3) for x in C(p)]
        if pairs:
            cs = [C(bm.faces[i].calc_center_median()) for i, _ in pairs]
            e["overlap_box"] = [[round(min(c[k] for c in cs), 3) for k in range(3)], [round(max(c[k] for c in cs), 3) for k in range(3)]]
        rec[cn] = e
    for on, ot in ntrees.items():          # new vs new
        if on == nm:
            continue
        pairs = t.overlap(ot)
        if pairs:
            bm.faces.ensure_lookup_table()
            cs = [C(bm.faces[i].calc_center_median()) for i, _ in pairs]
            rec["NEW:" + on] = {"overlap_tris": len(pairs), "overlap_box": [[round(min(c[k] for c in cs), 3) for k in range(3)],
                                                                            [round(max(c[k] for c in cs), 3) for k in range(3)]]}
    R["parts"][nm] = rec


# liquid inside its tank at the overflow level: scale the liquid to the max top and test every vertex
def inside_of(tree, p):
    loc, nor, i, d = tree.find_nearest(p, 2.0)
    return loc is not None and (p - loc).dot(nor) < 0, d


LIQ = {"Deco_Level_Coolant": ("CoolantTank_Body", 2.915), "Deco_Level_Coolant_Upper": ("CoolantTank_Body", 3.45),
       "Deco_Level_BrakeFluid": ("BrakeReservoir_Body", 3.32)}
R["liquid_inside"] = {}
for ln, (bn, top) in LIQ.items():
    if ln not in new or bn not in ntrees:
        continue
    bm = new[ln]; zs = [v.co.z for v in bm.verts]; z0, z1 = min(zs), max(zs)
    worst = 1e9; bad = 0
    for v in bm.verts:
        z = z0 + (v.co.z - z0) * (top - z0) / (z1 - z0)
        p = Vector((v.co.x, v.co.y, z))
        ins, d = inside_of(ntrees[bn], p)
        if not ins:
            bad += 1
        else:
            worst = min(worst, d)
    R["liquid_inside"][ln] = {"top_tested": top, "verts_outside": bad, "min_wall_gap": round(worst, 4)}

# hood opening sweep vs wipers / everything new that is NOT on the hood
hood = car.get("Hood")
if hood is not None:
    H = Vector((0.0, 3.85, 4.15)); res = {}
    for deg in range(0, 59, 2):
        M = Matrix.Translation(H) @ Matrix.Rotation(math.radians(deg), 4, 'X') @ Matrix.Translation(-H)
        b2 = hood.copy(); b2.transform(M); ht = BVHTree.FromBMesh(b2)
        for nm, t in ntrees.items():
            if nm.startswith("Washer_Nozzle"):
                continue
            n = len(ht.overlap(t))
            if n:
                res.setdefault(nm, []).append([deg, n])
        # the nozzles ride on the hood: test them (moved) against the wipers, glass, shell
        for nm in [k for k in new if k.startswith("Washer_Nozzle")]:
            b3 = new[nm].copy(); b3.transform(M); nt_ = BVHTree.FromBMesh(b3)
            for on in [k for k in ntrees if not k.startswith("Washer_Nozzle")] + ["Glass", "Shell"]:
                tt = ntrees.get(on) or trees.get(on)
                n = len(nt_.overlap(tt))
                if n:
                    res.setdefault(nm + " vs " + on, []).append([deg, n])
            b3.free()
        b2.free()
    R["hood_sweep_hits"] = res
json.dump(R, open(OUTJ, "w", encoding="utf-8"), indent=1)
print(json.dumps(R, indent=1)[:6000])
