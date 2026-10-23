"""Create (or update) a developer product with Open Cloud, icon included (same way as tools/create_gamepass.py).

  py tools/create_devproduct.py --universe <id> --name "Cash Envelope - Small" --price 49 --image art/ui/gamepass/512/envelope_small.png
        [--description "..."] [--for-sale] [--dry-run]       (default: NOT for sale; sale is turned on by main after the 10/28 buy test)
  py tools/create_devproduct.py --universe <id> --update <productId> [--name ..] [--price ..] [--image ..] [--for-sale|--not-for-sale]
  py tools/create_devproduct.py --list --universe <id>

API (create.roblox.com/docs/cloud/reference/features/developer-products.md, read 10-22, Beta):
  POST   https://apis.roblox.com/developer-products/v2/universes/{universeId}/developer-products               multipart/form-data
  PATCH  https://apis.roblox.com/developer-products/v2/universes/{universeId}/developer-products/{productId}
  fields: name (required on create), description, price (int), isForSale, imageFile, isRegionalPricingEnabled, isManagedPricingEnabled
  scope: developer-product:write; response key: productId. Regional pricing is switched on here (the game code reads the price, not a fixed number).
The key is read from .env like create_gamepass.py (never printed). Results go to art/roblox_devproducts.json {name: {id, price, forSale}}.
--dry-run prints the request (fields, image size) and sends nothing.
"""
import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from create_gamepass import call  # noqa: E402
from upload_images import read_env  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
API = "https://apis.roblox.com/developer-products/v2/universes/{u}/developer-products"
LEDGER = os.path.join(ROOT, "art", "roblox_devproducts.json")


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
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    base = API.format(u=a.universe)
    if a.image:
        from PIL import Image  # size check only
        w, h = Image.open(a.image).size
        if w > 512 or h > 512:
            sys.exit(f"{a.image} is {w}x{h}: use <= 512x512 (resize a copy first)")
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
        fields["isForSale"] = "false"
    if not a.update:
        fields["isRegionalPricingEnabled"] = "true"
        if not a.name:
            sys.exit("--name is required to create")
    if a.dry_run:
        print(("PATCH " + base + "/" + a.update) if a.update else ("POST " + base))
        print(json.dumps(fields, indent=2, ensure_ascii=False))
        print("imageFile:", a.image or "(none)")
        return
    env = read_env()
    key = env.get("ROBLOX_OPENCLOUD_KEY") or env.get("ROBLOX_API_KEY")
    if not key:
        sys.exit("no ROBLOX_OPENCLOUD_KEY in .env")
    if a.list:
        print(json.dumps(call("GET", base + "?limit=100", key), indent=2, ensure_ascii=False)[:4000])
        return
    ledger = json.load(open(LEDGER, encoding="utf-8")) if os.path.exists(LEDGER) else {}
    if a.update:
        call("PATCH", f"{base}/{a.update}", key, fields, a.image)
        pid = a.update
        print(f"updated {pid}")
    else:
        res = call("POST", base, key, fields, a.image)
        pid = str(res.get("productId") or "")
        if not pid:
            sys.exit(f"no productId in {json.dumps(res)[:300]}")
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
