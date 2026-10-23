"""Quick look for one Ella key pose: tools/anim/ella_iter.py <pose name> <prefix> [skirt glb] -> build/anim/ella_r/<prefix>_{front,left,q34}.png
(the pose must already be in build/anim/ella_poses.json: run ella_anim.py first)"""
import json, os, subprocess, sys
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
pose, prefix = sys.argv[1], sys.argv[2]
skirt = sys.argv[3] if len(sys.argv) > 3 else ("ella_skirtsit.glb" if "Sit" in pose else "ella_skirt.glb")
views = sys.argv[4].split(",") if len(sys.argv) > 4 else ["front", "left", "q34"]
out = os.path.join(ROOT, "build", "anim", "ella_r")
os.makedirs(out, exist_ok=True)
cfg = {"glbs": [skirt, "ella_sleever.glb", "ella_sleevel.glb", "ella_shawl.glb", "ella_hair.glb", "ella_braid.glb", "ella_slipper.glb", "ella_sock.glb"],
       "body": "ella", "pose": pose, "views": views, "ppu": 110, "W": 700, "H": 700, "centre": [0, 2.75, 0], "out": out, "prefix": prefix + "_"}
cp = os.path.join(out, f"cfg_{prefix}.json")
json.dump(cfg, open(cp, "w"))
subprocess.run(["C:/Users/glori/Tools/blender-5.2.2/blender.exe", "-b", "--factory-startup", "-P", os.path.join(ROOT, "tools", "anim", "ella_blender.py"), "--", "render.py", cp], check=True, capture_output=True)
print("ok", [f"{prefix}_{v}.png" for v in views])
