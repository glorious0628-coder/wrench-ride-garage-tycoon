"""Run one of art/3d/ella_v2/scripts (check_pose.py / render.py) with the key poses of tools/anim/ella_anim.py added to
body_def.POSES (names like Mech_EllaWalk_K0), so Ella's real meshes are posed at exactly the angles the animation has.
  blender -b --factory-startup -P tools/anim/ella_blender.py -- check_pose.py ella_skirt.glb Mech_EllaWalk_K0
  blender -b --factory-startup -P tools/anim/ella_blender.py -- render.py <cfg.json>   (cfg "pose": "Mech_EllaSit_K0")
(run from art/3d/ella_v2: the scripts use paths relative to it)
"""
import json
import os
import runpy
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ELLA = os.path.abspath(os.path.join(HERE, "..", "..", "art", "3d", "ella_v2"))
SCRIPTS = os.path.join(ELLA, "scripts")
sys.path.insert(0, SCRIPTS)
import body_def as B  # noqa: E402

poses = json.load(open(os.path.join(HERE, "..", "..", "build", "anim", "ella_poses.json")))
for name, joints in poses.items():
    B.POSES[name] = {j: np.array(mat) for j, mat in joints.items()}
args = sys.argv[sys.argv.index("--") + 1:]
script = args[0]
sys.argv = sys.argv[:sys.argv.index("--") + 1] + args[1:]
os.chdir(ELLA)
runpy.run_path(os.path.join(SCRIPTS, script), run_name="__main__")
