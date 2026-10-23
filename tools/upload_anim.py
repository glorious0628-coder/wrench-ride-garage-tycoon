"""Upload R15 KeyframeSequences (.rbxm / .rbxmx from tools/anim/mech_anim.py) to Roblox as Animation assets (main 10-22).

  py tools/upload_anim.py art/anim/Mech_Lean.rbxmx art/anim/Mech_Kneel.rbxmx        (owned by the group 572517831)
  py tools/upload_anim.py art/anim/Mech_Lean.rbxmx --user                          (owned by the user account instead)

An animation only plays in a game owned by the same creator, so the group (the game's owner) is the default.
Same key and multipart call as upload_model.py; results go to art/anim/anim_ids.json ({name: assetId}).
Re-running uploads a new asset, so check the ledger first.
"""
import json
import os
import sys
import time
import uuid

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from upload_images import DEFAULT_CREATOR, read_env  # noqa: E402
from upload_model import API, GROUP_ID, call  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEDGER = os.path.join(ROOT, "art", "anim", "anim_ids.json")


def main(argv):
    sys.stdout.reconfigure(encoding="utf-8")
    paths = [a for a in argv if not a.startswith("--")]
    if not paths:
        sys.exit(__doc__)
    env = read_env()
    key = env.get("ROBLOX_OPENCLOUD_KEY") or env.get("ROBLOX_API_KEY")
    if not key:
        sys.exit("no ROBLOX_OPENCLOUD_KEY in .env")
    creator = {"userId": env.get("ROBLOX_CREATOR_ID", DEFAULT_CREATOR)} if "--user" in argv else {"groupId": GROUP_ID}
    ledger = json.load(open(LEDGER, encoding="utf-8")) if os.path.exists(LEDGER) else {}
    for rel in paths:
        path = os.path.join(ROOT, rel) if not os.path.isabs(rel) else rel
        name = os.path.splitext(os.path.basename(path))[0]
        if name in ledger:
            print(f"{name}: already {ledger[name]} (skipped)")
            continue
        req = {
            "assetType": "Animation",
            "displayName": f"WrenchRide_{name}"[:50],
            "description": "Wrench & Ride mechanic animation",
            "creationContext": {"creator": creator},
        }
        b = uuid.uuid4().hex
        with open(path, "rb") as f:
            data = f.read()
        body = b"".join([
            f"--{b}\r\nContent-Disposition: form-data; name=\"request\"\r\n\r\n{json.dumps(req)}\r\n".encode(),
            f"--{b}\r\nContent-Disposition: form-data; name=\"fileContent\"; filename=\"{os.path.basename(path)}\"\r\nContent-Type: model/x-rbxm\r\n\r\n".encode(),
            data,
            f"\r\n--{b}--\r\n".encode(),
        ])
        try:
            op = call("POST", f"{API}/assets", key, body, f"multipart/form-data; boundary={b}")
        except RuntimeError as e:
            sys.exit(f"{name}: {e}")
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
        with open(LEDGER, "w", encoding="utf-8") as f:
            json.dump(ledger, f, indent=2, ensure_ascii=False)
        print(f"{name}: {asset_id}")


if __name__ == "__main__":
    main(sys.argv[1:])
