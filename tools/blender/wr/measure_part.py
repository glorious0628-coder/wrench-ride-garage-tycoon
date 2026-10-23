# wr-3d: colour codes for one part: view_labels + part_colours on the split concept cells.
#   py -I tools/blender/wr/measure_part.py <part> '<json palette list>' [cell_prefix (default = part)]
import sys, json, os, subprocess
part, pal = sys.argv[1], json.loads(sys.argv[2]); cp = sys.argv[3] if len(sys.argv) > 3 else part
root = os.path.abspath(f"art/3d/{part}/work"); d = f"{root}/colour"; os.makedirs(d, exist_ok=True)
views = {"views": {n: [f"{root}/concept/{cp}_{n}.png".replace("\\", "/")] for n in ["front", "back", "left", "right", "top", "bottom"]}}
json.dump(views, open(f"{d}/views.json", "w"), indent=1)
json.dump(pal, open(f"{d}/palette.json", "w"), indent=1)
subprocess.run([sys.executable, "-I", "tools/blender/view_labels.py", f"{d}/views.json", f"{d}/palette.json", f"{d}/lab"], capture_output=True)
r = subprocess.run([sys.executable, "-I", "tools/blender/part_colours.py", f"{d}/views.json", f"{d}/lab/views_lab.json", f"{d}/palette.json"],
                   capture_output=True, text=True)
print(r.stdout)
