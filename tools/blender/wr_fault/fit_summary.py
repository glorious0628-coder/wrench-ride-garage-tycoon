# one line per (new mesh, car mesh) from fit_check.py's json.   py -I fit_summary.py <fit.json>
import json, sys
R = json.load(open(sys.argv[1], encoding="utf-8"))
for p, rec in R["parts"].items():
    for c, e in rec.items():
        s = f"{p:28s} {c:28s} overlap {e['overlap_tris']:4d}"
        if "min_gap" in e:
            s += f"  gap {e['min_gap']:.3f} at {e.get('at')}  inside {e['verts_inside']}"
        if "overlap_box" in e:
            s += f"  box {e['overlap_box']}"
        print(s)
for k, v in R.get("liquid_inside", {}).items():
    print("LIQUID", k, v)
print("HOOD SWEEP", R.get("hood_sweep_hits"))
