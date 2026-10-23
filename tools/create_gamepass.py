"""Create (or update) a game pass with Open Cloud, icon included (user 10-21: "게임 패스도 너희가 만들어서 이미지까지 넣어줘").

  py tools/create_gamepass.py --universe <id> --name "Garage Rename" --price 299 --image art/ui/passes/rename.png
        [--description "..."] [--for-sale]          (default: not for sale until the feature is in the game)
  py tools/create_gamepass.py --universe <id> --update <gamePassId> [--name ..] [--price ..] [--image ..] [--for-sale|--not-for-sale]
  py tools/create_gamepass.py --list --universe <id>

API (create.roblox.com/docs/cloud/reference/features/game-passes, checked 10-21, Beta):
  POST  https://apis.roblox.com/game-passes/v1/universes/{universeId}/game-passes                  multipart/form-data
  PATCH https://apis.roblox.com/game-passes/v1/universes/{universeId}/game-passes/{gamePassId}     multipart/form-data
  fields: name (required on create), description, imageFile, isForSale, price, isRegionalPricingEnabled
  scope: game-pass:write (list: game-pass:read). Icon: <= 512x512, png/jpg/bmp, keep the important part inside the circle.
The key is read from .env like upload_images (never printed). Results go to art/roblox_gamepasses.json {name: {id, price, forSale}}.
"""
import argparse
import json
import mimetypes
import os
import sys
import urllib.error
import urllib.request
import uuid

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from upload_images import read_env  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
API = "https://apis.roblox.com/game-passes/v1/universes/{u}/game-passes"
LEDGER = os.path.join(ROOT, "art", "roblox_gamepasses.json")


def call(method, url, key, fields=None, image=None):
    headers = {"x-api-key": key}
    body = None
    if fields is not None or image:
        b = uuid.uuid4().hex
        parts = []
        for k, v in (fields or {}).items():
            parts.append(f"--{b}\r\nContent-Disposition: form-data; name=\"{k}\"\r\n\r\n{v}\r\n".encode())
        if image:
            with open(image, "rb") as f:
                data = f.read()
            ctype = mimetypes.guess_type(image)[0] or "image/png"
            parts.append(f"--{b}\r\nContent-Disposition: form-data; name=\"imageFile\"; filename=\"{os.path.basename(image)}\"\r\n"
                         f"Content-Type: {ctype}\r\n\r\n".encode() + data + b"\r\n")
        parts.append(f"--{b}--\r\n".encode())
        body = b"".join(parts)
        headers["Content-Type"] = f"multipart/form-data; boundary={b}"
    req = urllib.request.Request(url, data=body, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            raw = r.read().decode("utf-8")
            return json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as e:
        sys.exit(f"HTTP {e.code}: {e.read().decode('utf-8', 'replace')[:500]}")


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("--universe", required=True)
    ap.add_argument("--name")
    ap.add_argument("--description", default="")
    ap.add_argument("--price", type=int)
    ap.add_argument("--image")
    ap.add_argument("--update")
    ap.add_argument("--for-sale", action="store_true")
    ap.add_argument("--not-for-sale", action="store_true")
    ap.add_argument("--list", action="store_true")
    a = ap.parse_args()
    env = read_env()
    key = env.get("ROBLOX_OPENCLOUD_KEY") or env.get("ROBLOX_API_KEY")
    if not key:
        sys.exit("no ROBLOX_OPENCLOUD_KEY in .env")
    base = API.format(u=a.universe)
    if a.list:
        print(json.dumps(call("GET", base, key), indent=2, ensure_ascii=False)[:4000])
        return
    if a.image:
        from PIL import Image  # size check only (the icon itself comes from wr-art / Codex)
        w, h = Image.open(a.image).size
        if w > 512 or h > 512:
            sys.exit(f"{a.image} is {w}x{h}: game pass icons must be <= 512x512 (resize a copy first)")
    fields = {}
    if a.name:
        fields["name"] = a.name
    if a.description:
        fields["description"] = a.description
    if a.price is not None:
        fields["price"] = str(a.price)
    if a.for_sale:
        fields["isForSale"] = "true"
    elif a.not_for_sale or not a.update:
        fields["isForSale"] = "false"  # create = not for sale until the feature is in the game
    ledger = json.load(open(LEDGER, encoding="utf-8")) if os.path.exists(LEDGER) else {}
    if a.update:
        call("PATCH", f"{base}/{a.update}", key, fields, a.image)
        pid = a.update
        print(f"updated {pid}")
    else:
        if not a.name:
            sys.exit("--name is required to create")
        res = call("POST", base, key, fields, a.image)
        pid = str(res.get("gamePassId") or "")
        if not pid:
            sys.exit(f"no gamePassId in {json.dumps(res)[:300]}")
        print(f"created {a.name}: {pid}")
    name = a.name or next((n for n, v in ledger.items() if str(v.get("id")) == str(pid)), pid)
    entry = ledger.get(name, {})
    entry.update({"id": pid, "universe": a.universe})
    if a.price is not None:
        entry["price"] = a.price
    entry["forSale"] = fields.get("isForSale", str(entry.get("forSale", "false")).lower()) == "true"
    if a.image:
        entry["image"] = os.path.relpath(a.image, ROOT) if os.path.isabs(a.image) else a.image
    ledger[name] = entry
    with open(LEDGER, "w", encoding="utf-8") as f:
        json.dump(ledger, f, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    main()
