"""Builder loop: run a build script in Studio, dump the parts, render them in Blender, put the render beside the concept.

  set STUDIO_ID=<WrenchRide window id>
  py tools/builder/build_run.py <build.luau|-> <out_dir> [concept_front.png]

  build.luau  = Luau that (re)builds workspace.BuilderSandbox (use "-" to only dump what is there now)
  out_dir     = gets parts.json, front/back/left/right/top/threeq.png and compare_front.png
Never saves, closes or publishes the place.
"""
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from studio_mcp import Client  # noqa: E402

BLENDER = os.environ.get("BLENDER", r"C:\Users\glori\Tools\blender-5.2.2\blender.exe")
CHUNK = 20000


def fetch(c):
    with open(os.path.join(HERE, "export_parts.luau"), encoding="utf-8") as f:
        print(c.luau(f.read()))
    total = int(re.search(r"LEN(\d+)END", c.luau('return "LEN" .. #_G.BUILDEXPORT .. "END"')).group(1))
    parts = []
    for a in range(1, total + 1, CHUNK):
        o = c.luau(f'return "HEX" .. (_G.BUILDEXPORT:sub({a}, {a + CHUNK - 1}):gsub(".", function(ch) '
                   f'return string.format("%02x", ch:byte()) end)) .. "END"')
        parts.append(bytes.fromhex(re.search(r"HEX([0-9a-f]*)END", o).group(1)))
    c.luau("_G.BUILDEXPORT = nil return 'ok'")
    return json.loads(b"".join(parts).decode("utf-8"))


def compare(concept, render, dst):
    from PIL import Image, ImageDraw
    a = Image.open(concept).convert("RGB"); b = Image.open(render).convert("RGB")
    h = 900
    a = a.resize((round(a.width * h / a.height), h)); b = b.resize((round(b.width * h / b.height), h))
    im = Image.new("RGB", (a.width + b.width + 20, h + 40), "white")
    im.paste(a, (0, 40)); im.paste(b, (a.width + 20, 40))
    d = ImageDraw.Draw(im); d.text((10, 10), "concept", fill="black"); d.text((a.width + 30, 10), "studio parts (blender)", fill="black")
    im.save(dst)


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    build, out = sys.argv[1], os.path.abspath(sys.argv[2])
    concept = sys.argv[3] if len(sys.argv) > 3 else None
    os.makedirs(out, exist_ok=True)
    c = Client().start()
    try:
        if build != "-":
            with open(build, encoding="utf-8") as f:
                print("build:", c.luau(f.read()))
        data = fetch(c)
    finally:
        c.close()
    pj = os.path.join(out, "parts.json")
    with open(pj, "w", encoding="utf-8") as f:
        json.dump(data, f)
    print("parts:", len(data))
    r = subprocess.run([BLENDER, "--background", "--factory-startup", "--python", os.path.join(HERE, "render_parts.py"),
                        "--", pj, out], capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.returncode != 0 or not os.path.exists(os.path.join(out, "front.png")):
        print(r.stdout[-3000:], r.stderr[-3000:])
        raise SystemExit("blender failed")
    if concept:
        compare(concept, os.path.join(out, "front.png"), os.path.join(out, "compare_front.png"))
    print("done", out)


if __name__ == "__main__":
    main()
