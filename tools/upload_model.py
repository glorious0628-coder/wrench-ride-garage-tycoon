"""Upload a 3D model (.glb / .fbx) to Roblox as a Model asset with Open Cloud (main 10-17: the 3D pipeline test).

  py tools/upload_model.py art/3d/parcel_box/parcel_box_dot.glb            (owned by the group, Config.GROUP_ID)
  py tools/upload_model.py art/3d/parcel_box/parcel_box_dot.glb --user     (owned by ROBLOX_CREATOR_ID instead)

The key is read from .env (ROBLOX_OPENCLOUD_KEY) and never printed or written anywhere. It needs asset:write for the
creator. Results go to art/3d/models.json ({name: assetId}); the asset id is printed. Re-running the same file
uploads a new version as a new asset (Open Cloud has no "replace" for models here), so check the ledger first.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.request
import uuid

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from upload_images import DEFAULT_CREATOR, grant_use, read_env  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
API = "https://apis.roblox.com/assets/v1"
LEDGER = os.path.join(ROOT, "art", "3d", "models.json")
GROUP_ID = "572517831"
CTYPES = {".glb": "model/gltf-binary", ".gltf": "model/gltf+json", ".fbx": "model/fbx"}


def call(method, url, key, body=None, ctype=None):
    req = urllib.request.Request(url, data=body, method=method, headers={"x-api-key": key})
    if ctype:
        req.add_header("Content-Type", ctype)
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            return json.loads(r.read().decode("utf-8") or "{}")
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"HTTP {e.code}: {e.read().decode('utf-8', 'replace')[:400]}") from None


def main(argv):
    sys.stdout.reconfigure(encoding="utf-8")
    paths = [a for a in argv if not a.startswith("--")]
    if not paths:
        sys.exit(__doc__)
    env = read_env()
    key = env.get("ROBLOX_OPENCLOUD_KEY") or env.get("ROBLOX_API_KEY")
    if not key:
        sys.exit("no ROBLOX_OPENCLOUD_KEY in .env")
    # (Wrench & Ride 10-21: the .env has no ROBLOX_CREATOR_ID -> the user's own account, same default as upload_images)
    creator = {"userId": env.get("ROBLOX_CREATOR_ID", DEFAULT_CREATOR)} if "--user" in argv else {"groupId": GROUP_ID}
    ledger = json.load(open(LEDGER, encoding="utf-8")) if os.path.exists(LEDGER) else {}
    for rel in paths:
        path = os.path.join(ROOT, rel) if not os.path.isabs(rel) else rel
        name = os.path.splitext(os.path.basename(path))[0]
        ext = os.path.splitext(path)[1].lower()
        req = {
            "assetType": "Model",
            "displayName": f"WrenchRide_{name}"[:50],
            "description": "Wrench & Ride 3D model",
            "creationContext": {"creator": creator},
        }
        b = uuid.uuid4().hex
        with open(path, "rb") as f:
            data = f.read()
        body = b"".join([
            f"--{b}\r\nContent-Disposition: form-data; name=\"request\"\r\n\r\n{json.dumps(req)}\r\n".encode(),
            f"--{b}\r\nContent-Disposition: form-data; name=\"fileContent\"; filename=\"{os.path.basename(path)}\"\r\nContent-Type: {CTYPES.get(ext, 'application/octet-stream')}\r\n\r\n".encode(),
            data,
            f"\r\n--{b}--\r\n".encode(),
        ])
        op = call("POST", f"{API}/assets", key, body, f"multipart/form-data; boundary={b}")
        op_id = (op.get("path") or "").split("/")[-1] or op.get("operationId")
        for _ in range(90):
            if op.get("done"):
                break
            time.sleep(2)
            op = call("GET", f"{API}/operations/{op_id}", key)
        if not op.get("done"):
            sys.exit(f"{name}: still processing (operation {op_id}); check it later")
        if op.get("error"):
            sys.exit(f"{name}: {json.dumps(op['error'])[:400]}")
        asset_id = str((op.get("response") or {}).get("assetId") or "")
        if not asset_id:
            sys.exit(f"{name}: no assetId in {json.dumps(op)[:300]}")
        ledger[name] = asset_id
        os.makedirs(os.path.dirname(LEDGER), exist_ok=True)
        with open(LEDGER, "w", encoding="utf-8") as f:
            json.dump(ledger, f, indent=2, ensure_ascii=False)
        print(f"{name}: {asset_id}")
        if "--user" in argv:
            grant_use(key, [asset_id])  # (user-owned: the group game needs "Use"; group-owned ones already have it)


if __name__ == "__main__":
    main(sys.argv[1:])
