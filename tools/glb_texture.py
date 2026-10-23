"""Take the texture out of a GLB variant of a mesh we already have (3D schedule 10-19, main: Tripo makes the 9 box looks
as variants of S1 with the same vertices / faces / UVs; we only need each one's texture image for Config.BoxTextures).

  py tools/glb_texture.py <variant.glb> <out_dir> [--ref art/3d/parcel_box/parcel_box_dot.glb]

Writes <out_dir>/<name>_tex.png (the texture as it is) and <name>_tex_1024.png (shrunk to 1024 the way Roblox shrinks
uploads — look at the label / small print there), and prints whether the variant really matches the reference:
same triangle count, the same UVs (max difference) and the same shape (max position difference after both are
centred). A mismatch means its texture won't sit right on S1 — don't connect it.
"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "3d", "_tools"))
import glbkit  # noqa: E402


def flat(parts):
    uv = np.concatenate([p["uv"][p["idx"].reshape(-1)] for p in parts if p["uv"] is not None]) if parts else None
    pos = np.concatenate([p["pos"][p["idx"].reshape(-1)] for p in parts])
    return uv, pos


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    src, out = sys.argv[1], sys.argv[2]
    ref = sys.argv[sys.argv.index("--ref") + 1] if "--ref" in sys.argv else os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "..", "art", "3d", "parcel_box", "parcel_box_dot.glb")
    os.makedirs(out, exist_ok=True)
    name = os.path.splitext(os.path.basename(src))[0]
    parts = glbkit.load(src)
    img = next((p["image"] for p in parts if p["image"] is not None), None)
    if img is None:
        print(f"{name}: NO TEXTURE in the file")
        return 1
    img.save(os.path.join(out, f"{name}_tex.png"))
    img.resize((1024, 1024), Image.LANCZOS).save(os.path.join(out, f"{name}_tex_1024.png"))
    rp = glbkit.load(ref)
    ok = True
    tv, tr = glbkit.tri_count(parts), glbkit.tri_count(rp)
    print(f"{name}: texture {img.size[0]}x{img.size[1]}, {tv} tris (ref {tr})")
    if tv != tr:
        print("  MISMATCH: triangle count differs — not a variant of the reference mesh")
        ok = False
    else:
        uva, posa = flat(parts)
        uvb, posb = flat(rp)
        if uva is None or uvb is None:
            print("  MISMATCH: no UVs")
            ok = False
        else:
            du = float(np.abs(uva - uvb).max())
            posa = posa - posa.mean(axis=0)
            posb = posb - posb.mean(axis=0)
            sa, sb = np.abs(posa).max(), np.abs(posb).max()
            dp = float(np.abs(posa / sa - posb / sb).max())
            print(f"  UV max diff {du:.5f} (want < 0.002), shape max diff {dp:.5f} of its size (want < 0.01)")
            if du >= 0.002 or dp >= 0.01:
                print("  MISMATCH: the texture would not line up on S1")
                ok = False
    print("  OK - connect it: upload the _tex.png as an image, put its id in Config.BoxTextures" if ok else "  NOT OK")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
