"""Upload sound files (.ogg / .mp3 / .wav / .flac) to Roblox as Audio assets with Open Cloud (main 10-21, wr-sound picks).

  py tools/upload_audio.py art/sfx/fault/engineFail.ogg art/sfx/tool/wrench.ogg ...      (<= 10 per run)

Owned by the user's account (like upload_images), then "Use" is granted to the game's universe (the game is group-owned).
Uploaded audio is private to us (not distributed on the Creator Store). Results go to art/sfx/audio_ids.json {name: assetId}.
Only sounds the user picked by ear (art/sfx/picks.md) - never Pizza Doggy files (no-AI license, and not ours to upload yet).
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
LEDGER = os.path.join(ROOT, "art", "sfx", "audio_ids.json")
CTYPES = {".ogg": "audio/ogg", ".mp3": "audio/mpeg", ".wav": "audio/wav", ".flac": "audio/flac"}


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
    if not paths or len(paths) > 10:
        sys.exit(__doc__)
    env = read_env()
    key = env.get("ROBLOX_OPENCLOUD_KEY") or env.get("ROBLOX_API_KEY")
    if not key:
        sys.exit("no ROBLOX_OPENCLOUD_KEY in .env")
    creator = {"userId": env.get("ROBLOX_CREATOR_ID", DEFAULT_CREATOR)}
    ledger = json.load(open(LEDGER, encoding="utf-8")) if os.path.exists(LEDGER) else {}
    for rel in paths:
        path = os.path.join(ROOT, rel) if not os.path.isabs(rel) else rel
        name = os.path.splitext(os.path.basename(path))[0]
        if "pizzadoggy" in path.lower():
            sys.exit(f"{rel}: Pizza Doggy audio is not uploaded by tools")
        ext = os.path.splitext(path)[1].lower()
        req = {"assetType": "Audio", "displayName": f"WrenchRide_{name}"[:50], "description": "Wrench & Ride sound effect",
               "creationContext": {"creator": creator}}
        b = uuid.uuid4().hex
        with open(path, "rb") as f:
            data = f.read()
        body = b"".join([
            f"--{b}\r\nContent-Disposition: form-data; name=\"request\"\r\n\r\n{json.dumps(req)}\r\n".encode(),
            f"--{b}\r\nContent-Disposition: form-data; name=\"fileContent\"; filename=\"{os.path.basename(path)}\"\r\n"
            f"Content-Type: {CTYPES.get(ext, 'application/octet-stream')}\r\n\r\n".encode(),
            data,
            f"\r\n--{b}--\r\n".encode(),
        ])
        try:
            op = call("POST", f"{API}/assets", key, body, f"multipart/form-data; boundary={b}")
        except RuntimeError as e:
            print(f"FAIL {rel}: {e}")
            continue
        op_id = (op.get("path") or "").split("/")[-1] or op.get("operationId")
        for _ in range(90):
            if op.get("done"):
                break
            time.sleep(2)
            op = call("GET", f"{API}/operations/{op_id}", key)
        if not op.get("done") or op.get("error"):
            print(f"FAIL {rel}: {json.dumps(op.get('error') or 'still processing')[:300]}")
            continue
        asset_id = str((op.get("response") or {}).get("assetId") or "")
        ledger[name] = asset_id
        with open(LEDGER, "w", encoding="utf-8") as f:
            json.dump(ledger, f, indent=2, ensure_ascii=False)
        print(f"{name}: {asset_id}")
        grant_use(key, [asset_id])


if __name__ == "__main__":
    main(sys.argv[1:])
