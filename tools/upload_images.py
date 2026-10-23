"""Upload PNGs to Roblox as Decals with the Open Cloud Assets API (user approved on 2026-10-16).

  py tools/upload_images.py art/atlas/items.png art/out/pass_vip.png ...   (<= 10 per run)
  py tools/upload_images.py --check                                        (show the ledger)

Key: ROBLOX_OPENCLOUD_KEY from ../Game/.env or ./.env (never printed). Creator: ROBLOX_CREATOR_ID or the default below.
Results go to art/roblox_assets.json {file: {decalId, imageId?}}. A Decal id can't be used directly by an ImageLabel:
run tools/resolve_images.luau in Studio (Edit) to turn decal ids into image ids (Decal.Texture), then
py tools/upload_images.py --set-image <file>=<imageId> records it.
Look at every image before uploading it (moderation).
The game is group-owned and these uploads are user-owned, so each one also gets "Use" granted to the game's universe
(grant_use, user OK 10-18) — without it the game shows "User is not authorized to access Asset" and a blank image.
Needs the key scope asset-permissions:write; a failed grant prints one line and the upload still counts.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.request
import uuid

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEDGER = os.path.join(ROOT, "art", "roblox_assets.json")
API = "https://apis.roblox.com/assets/v1"
DEFAULT_CREATOR = "11753301316"
UNIVERSE = "10772174231"  # Wrench & Ride (user published 10-21, group 572517831; place 86082014470439)


def read_env():
    env = {}
    for path in (os.path.join(ROOT, ".env"), os.path.join(os.path.dirname(ROOT), "Game", ".env"),
                 os.path.join(os.path.dirname(ROOT), "Halo & Horns", ".env")):  # (10-20 the user moved it here)
        if os.path.exists(path):
            with open(path, encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#") and "=" in line:
                        k, v = line.split("=", 1)
                        env.setdefault(k.strip(), v.strip().strip('"').strip("'"))
    return env


def call(method, url, key, body=None, ctype=None):
    req = urllib.request.Request(url, data=body, method=method, headers={"x-api-key": key})
    if ctype:
        req.add_header("Content-Type", ctype)
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            return json.loads(r.read().decode("utf-8") or "{}")
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"HTTP {e.code}: {e.read().decode('utf-8', 'replace')[:400]}") from None


def multipart(request_json, file_name, data):
    b = uuid.uuid4().hex
    parts = [
        f"--{b}\r\nContent-Disposition: form-data; name=\"request\"\r\n\r\n{json.dumps(request_json)}\r\n".encode(),
        f"--{b}\r\nContent-Disposition: form-data; name=\"fileContent\"; filename=\"{file_name}\"\r\nContent-Type: image/png\r\n\r\n".encode(),
        data,
        f"\r\n--{b}--\r\n".encode(),
    ]
    return b"".join(parts), f"multipart/form-data; boundary={b}"


def load_ledger():
    if os.path.exists(LEDGER):
        with open(LEDGER, encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_ledger(ledger):
    os.makedirs(os.path.dirname(LEDGER), exist_ok=True)
    with open(LEDGER, "w", encoding="utf-8") as f:
        json.dump(ledger, f, indent=2, ensure_ascii=False)


def grant_use(key, asset_ids):
    """Let the game's universe use these assets (and what they depend on: a decal's image). True when it worked."""
    ids = [int(i) for i in asset_ids if i]
    if not ids:
        return True
    body = json.dumps({"subjectType": "Universe", "subjectId": UNIVERSE, "action": "Use",
                       "requests": [{"assetId": i, "grantToDependencies": True} for i in ids]}).encode()
    try:
        res = call("PATCH", "https://apis.roblox.com/asset-permissions-api/v1/assets/permissions", key, body, "application/json")
    except RuntimeError as e:
        print(f"  grant FAIL {ids}: {e}")
        return False
    if res.get("errors"):
        print(f"  grant FAIL {ids}: {json.dumps(res['errors'])[:300]}")
        return False
    print(f"  granted Use to universe {UNIVERSE}: {ids}")
    return True


def upload(path, key, creator):
    name = os.path.splitext(os.path.basename(path))[0]
    req = {
        "assetType": "Decal",
        "displayName": f"WrenchRide_{name}"[:50],
        "description": "Wrench & Ride game art",
        "creationContext": {"creator": {"userId": creator}},
    }
    with open(path, "rb") as f:
        body, ctype = multipart(req, os.path.basename(path), f.read())
    op = call("POST", f"{API}/assets", key, body, ctype)
    op_id = (op.get("path") or "").split("/")[-1] or op.get("operationId")
    for _ in range(60):
        if op.get("done"):
            break
        time.sleep(2)
        op = call("GET", f"{API}/operations/{op_id}", key)
    if not op.get("done"):
        raise RuntimeError(f"{path}: upload still pending (operation {op_id})")
    resp = op.get("response") or {}
    asset_id = resp.get("assetId")
    if not asset_id:
        raise RuntimeError(f"{path}: no assetId in {json.dumps(op)[:300]}")
    return str(asset_id)


def main(argv):
    sys.stdout.reconfigure(encoding="utf-8")
    ledger = load_ledger()
    if "--check" in argv:
        print(json.dumps(ledger, indent=2, ensure_ascii=False))
        return 0
    if argv and argv[0] == "--set-image":
        for pair in argv[1:]:
            f, img = pair.split("=", 1)
            ledger.setdefault(f, {})["imageId"] = img
        save_ledger(ledger)
        print("recorded")
        return 0
    files = [a for a in argv if not a.startswith("--")]
    if not files or len(files) > 10:
        sys.exit(__doc__)
    env = read_env()
    key = env.get("ROBLOX_OPENCLOUD_KEY") or env.get("ROBLOX_API_KEY")
    if not key:
        sys.exit("no ROBLOX_OPENCLOUD_KEY in .env")
    creator = env.get("ROBLOX_CREATOR_ID", DEFAULT_CREATOR)
    for path in files:
        rel = os.path.relpath(os.path.abspath(path), ROOT).replace("\\", "/")
        try:
            decal = upload(path, key, creator)
        except RuntimeError as e:
            print(f"FAIL {rel}: {e}")
            continue
        ledger[rel] = {"decalId": decal, "at": time.strftime("%Y-%m-%d %H:%M")}
        save_ledger(ledger)
        print(f"OK {rel} decal {decal}")
        grant_use(key, [decal])
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
