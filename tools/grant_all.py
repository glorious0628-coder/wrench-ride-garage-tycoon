"""Grant the game's universe "Use" on every user-owned asset we uploaded (the game is group-owned, the uploads are
user-owned: without this the game shows blank images / missing meshes). Main only, after the game exists (10-21).

  py tools/grant_all.py            (models in art/3d/models.json + images in art/roblox_assets.json)
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import upload_images  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    env = upload_images.read_env()
    key = env.get("ROBLOX_OPENCLOUD_KEY") or env.get("ROBLOX_API_KEY")
    if not key:
        sys.exit("no ROBLOX_OPENCLOUD_KEY in .env")
    ids = []
    models = json.load(open(os.path.join(ROOT, "art", "3d", "models.json"), encoding="utf-8"))
    ids += [str(v) for v in models.values()]
    images = json.load(open(os.path.join(ROOT, "art", "roblox_assets.json"), encoding="utf-8"))
    for v in images.values():
        for k in ("decalId", "imageId"):
            if v.get(k):
                ids.append(str(v[k]))
    ids = sorted(set(ids))
    print(f"{len(ids)} assets -> universe {upload_images.UNIVERSE}")
    ok = fail = 0
    for i in range(0, len(ids), 20):
        if upload_images.grant_use(key, ids[i:i + 20]):
            ok += len(ids[i:i + 20])
        else:
            fail += len(ids[i:i + 20])
    print(f"done: {ok} granted, {fail} failed")


if __name__ == "__main__":
    main()
