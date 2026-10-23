"""3D quality gate for our GLBs with the project skill blender-asset-qa (main 10-22, user: "지금까지 만든 3D 모두 검사").

  blender -b --factory-startup -P tools/blender/qa_glb.py -- --out notes/qa_3d [--profile roblox] [--shots] a.glb b.glb ...

Each GLB is imported into an empty scene and all its meshes are checked together as one asset
(.claude/skills/blender-asset-qa/scripts/qa_check.py: z-fighting, floating parts, normals, topology, scale, UVs, tris).
Our units: 1 BU = 1 stud (0.28 m), so --eps / --tol are in studs (defaults 0.001 / 0.002).
Writes <out>/<name>.json per file and <out>/summary.json; with --shots also <out>/<name>_random.png for files with errors.
"""
import json
import os
import sys

import bpy

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, ".claude", "skills", "blender-asset-qa", "scripts"))
import qa_check  # noqa: E402
import review_shots  # noqa: E402


def args():
    a = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    opt = {"out": "notes/qa_3d", "profile": "roblox", "shots": False, "eps": 0.001, "tol": 0.002}
    files, i = [], 0
    while i < len(a):
        if a[i] in ("--out", "--profile", "--eps", "--tol"):
            opt[a[i][2:]] = a[i + 1] if a[i] in ("--out", "--profile") else float(a[i + 1])
            i += 2
        elif a[i] == "--shots":
            opt["shots"] = True
            i += 1
        else:
            files.append(a[i])
            i += 1
    return opt, files


def empty_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def weld_gltf_splits():
    """glTF stores a vertex per (position, normal, UV) - the importer leaves those splits open, which shows up as
    false 'open boundary edges' / 'duplicate verts'. Weld exact copies (1e-5 stud) so the check sees the real topology."""
    import bmesh
    for ob in bpy.context.scene.objects:
        if ob.type == "MESH" and ob.data.users == 1:
            bm = bmesh.new()
            bm.from_mesh(ob.data)
            bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
            bm.to_mesh(ob.data)
            bm.free()


def main():
    opt, files = args()
    out = os.path.join(ROOT, opt["out"]) if not os.path.isabs(opt["out"]) else opt["out"]
    os.makedirs(out, exist_ok=True)
    summary = {}
    for f in files:
        path = f if os.path.isabs(f) else os.path.join(ROOT, f)
        name = os.path.splitext(os.path.basename(path))[0]
        empty_scene()
        try:
            bpy.ops.import_scene.gltf(filepath=path)
            weld_gltf_splits()
            res = qa_check.run(objects=None, profile=opt["profile"], eps=opt["eps"], tol=opt["tol"])
            # our colour-palette meshes point every face's UV at one cell centre on purpose (one texture per zone)
            palette = [e for e in res["errors"] if "zero-area UV faces" in e]
            res["errors"] = [e for e in res["errors"] if e not in palette]
            res["warnings"] += [e + " (palette UV = by design)" for e in palette]
            res["pass"] = not res["errors"]
            tris = sum(m.get("tris", 0) for m in res["objects"].values())
            row = {"file": os.path.relpath(path, ROOT).replace("\\", "/"), "pass": res["pass"],
                   "errors": res["errors"], "warnings": res["warnings"], "tris": tris,
                   "meshes": len(res["objects"])}
            if opt["shots"] and res["errors"]:
                shot = review_shots.run(objects=None, out=os.path.join(out, name + "_random.png"), mode="random", res=384)
                row["shot"] = os.path.relpath(shot["sheet"], ROOT).replace("\\", "/")
            with open(os.path.join(out, name + ".json"), "w", encoding="utf-8") as fh:
                json.dump(res, fh, ensure_ascii=False, indent=1, default=str)
        except Exception as e:  # one bad file must not stop the batch
            row = {"file": f, "pass": False, "errors": [f"{type(e).__name__}: {e}"], "warnings": [], "tris": 0}
        summary[name] = row
        print(f"[qa] {name}: {'PASS' if row['pass'] else 'FAIL'} e={len(row['errors'])} w={len(row['warnings'])} tris={row['tris']}",
              flush=True)
    sp = os.path.join(out, "summary.json")
    old = {}
    if os.path.exists(sp):
        with open(sp, encoding="utf-8") as fh:
            old = json.load(fh)
    old.update(summary)
    with open(sp, "w", encoding="utf-8") as fh:
        json.dump(old, fh, ensure_ascii=False, indent=1)


main()
