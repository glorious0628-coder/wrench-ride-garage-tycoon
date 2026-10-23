"""Ella's own moves (wr-anim 10-23, main decision notes/gpt/main/ella/ella3d_decision.md '동작'):
  Mech_EllaWalk  — a small-step walk for a skirt: hips within ±25°, knees within 35° (the 3D helper found the back foot
                   goes through the skirt's back hem from ±30° / 45°), the hips barely sway
  Mech_EllaSit   — sitting for the A-line seated skirt (Ella_SkirtSit): knees together, back straight, hands resting on the lap
  Mech_EllaWave  — the arrival wave (scene 1c): the arm raised where the puff sleeve and the shawl clip least, a short forearm wag
  Mech_EllaIdle  — standing: arms hang in the dress's A line (the stock idle swings them into the skirt), a slow breath

Her body is the R15 joint tree with her own slim parts (art/3d/ella_v2/ella_spec.md): joint HEIGHTS hip 2.0 · knee 1.178 ·
ankle 0.252 · shoulder 3.78, so thigh 0.822, shin 0.926 and HipHeight 2.0 (AuthoredHipHeight 2.0). The KFS poses are joint
rotations only, so they play on the stock R15 as well (the legs are a little longer there, the feet float ~0.2 in a photo).

  py tools/anim/ella_anim.py [--check]   ->  art/anim/Mech_Ella*.rbxmx + build/anim/preview_ella.luau (Studio stand-ins)
                                             + build/anim/ella_poses.json (the key poses as joint matrices for the Blender
                                             clipping check art/3d/ella_v2/scripts via tools/anim/ella_blender.py)
Joint convention (same as body_def.py / mech_anim.py): +rx at a hip / shoulder = forward, -rx at a knee = bend.
"""
import json
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mech_anim as m  # noqa: E402

ELLA_AUTH = 2.0
# Ella's rig in mech_anim's terms (HRP space: the hip joints sit at the root pivot, 2.0 over the ground, HRP centre 3.0)
m.RIGS["ella"] = dict(JOINT=dict(m.RIGS["classic"]["JOINT"]), HIP_Y=-1.0, HIPUP=0.0, THIGH=0.822, SHIN=0.926,
                      ANKLE_SOLE=0.252, GROUND=-3.0, LEG_R=0.3, FOOT_HALF=(0.3, 0.1, 0.4), SHIN_HALF=(0.3, 0.45, 0.3),
                      AUTH=ELLA_AUTH, TOOL_DY=0.0)
POSES_OUT = os.path.join(m.ROOT, "build", "anim", "ella_poses.json")
PREVIEW_OUT = os.path.join(m.ROOT, "build", "anim", "preview_ella.luau")

# part -> the joint (body_def.py name) it hangs on
JOINT_OF = {"LowerTorso": "Root", "UpperTorso": "Waist", "Head": "Neck"}
for _s in ("Right", "Left"):
    for _p, _j in (("UpperArm", "Shoulder"), ("LowerArm", "Elbow"), ("Hand", "Wrist"), ("UpperLeg", "Hip"),
                   ("LowerLeg", "Knee"), ("Foot", "Ankle")):
        JOINT_OF[_s + _p] = _s + _j

# ---------------------------------------------------------------- walk
STRIDE = 0.55  # the ankle ahead of / behind the hip at contact (hips +20° ahead, -18° behind, the legs near straight)
LIFT = 0.06  # the swing foot's clearance over the floor at the passing pose (knee 33°: a bigger lift is a bigger knee)
WALK_T = 0.85  # one full cycle; CustomerService scales it with the NPC's speed


def walk_pose(rf, lf, rl, ll, bob, arms, turn=0.0):
    """rf / lf = right / left ankle ahead (+) or behind (-) the hip; rl / ll = ankle lifted over the sole line;
    bob = pelvis drop; arms = (right shoulder rx, left shoulder rx)."""
    p = {}
    m.legs_pose(p, pelvis_y=bob, pelvis_f=0.0, pelvis_pitch=-1.5,
                left=dict(foot_f=lf, foot_y=m.GROUND + m.ANKLE_SOLE + ll, out=1.5),
                right=dict(foot_f=rf, foot_y=m.GROUND + m.ANKLE_SOLE + rl, out=1.5))
    p["UpperTorso"] = (1.0, turn, 0)  # upright; the shoulders turn against the hips (the arm swing's side), a little more than the hips sway
    p["LowerTorso"] = p["LowerTorso"][:1] + (-turn * 0.5,) + p["LowerTorso"][2:]  # (the pelvis turns the other way: the walk reads, the hem barely moves)
    p["Head"] = (0.0, 0, 0)
    # the arms hang in the dress's A line (the mesh is authored 18° out): only a fore-aft swing, elbows soft
    p["RightUpperArm"] = (arms[0], 0, 0)
    p["LeftUpperArm"] = (arms[1], 0, 0)
    p["RightLowerArm"] = (8 + max(0, arms[0]) * 0.8, 0, 0)
    p["LeftLowerArm"] = (8 + max(0, arms[1]) * 0.8, 0, 0)
    return p


def settle(spec):
    """pelvis drop so the stance leg can reach the floor without over-stretching (legs_pose clamps the reach)"""
    return spec


def walk_keys():
    d = STRIDE
    sw = 11.0  # arm swing (deg) — small, a hand never reaches the skirt
    # (the pelvis bobs 0.06 down at the contact poses, up at the passing poses)
    ks = [
        (0.00, walk_pose(+d, -d, 0.0, 0.0, -0.08, (-sw, sw), 5.0)),  # R heel strike ahead, L toe-off behind
        (WALK_T * 0.25, walk_pose(0.0, 0.0, 0.0, LIFT, -0.012, (0.0, 0.0), 0.0)),  # R stance under the hip, L swinging through
        (WALK_T * 0.50, walk_pose(-d, +d, 0.0, 0.0, -0.08, (sw, -sw), -5.0)),
        (WALK_T * 0.75, walk_pose(0.0, 0.0, LIFT, 0.0, -0.012, (0.0, 0.0), 0.0)),
        (WALK_T, walk_pose(+d, -d, 0.0, 0.0, -0.08, (-sw, sw), 5.0)),
    ]
    return [m.kf(t, p) for t, p in ks]


# ---------------------------------------------------------------- idle
def idle_pose(breath):
    p = {}
    m.legs_pose(p, pelvis_y=0.0, pelvis_f=0.0, pelvis_pitch=0.0, left=dict(foot_f=0.0, out=1.0), right=dict(foot_f=0.0, out=1.0))
    p["UpperTorso"] = (breath * 1.2, 0, 0)
    p["Head"] = (-breath * 0.8, 0, 0)
    p["RightUpperArm"] = (2 + breath, 0, 0)
    p["LeftUpperArm"] = (2 + breath, 0, 0)
    p["RightLowerArm"] = (6, 0, 0)
    p["LeftLowerArm"] = (6, 0, 0)
    return p


def idle_keys():
    return [m.kf(0.0, idle_pose(0)), m.kf(1.8, idle_pose(1)), m.kf(3.6, idle_pose(0))]


# ---------------------------------------------------------------- sit (the stock seat puts the root at the seat; legs 90 / -90)
def sit_pose(arm_out=0.0, hand_lift=0.0):
    p = {}
    p["LowerTorso"] = (0, 0, 0)
    p["RightUpperLeg"] = (90, 0, 2)
    p["LeftUpperLeg"] = (90, 0, -2)
    p["RightLowerLeg"] = (-90, 0, 0)
    p["LeftLowerLeg"] = (-90, 0, 0)
    p["RightFoot"] = (0, 0, -2)
    p["LeftFoot"] = (0, 0, 2)
    p["UpperTorso"] = (-2, 0, 0)
    p["Head"] = (2, 0, 0)
    # hands resting on the lap, the forearms crossing the front of the thighs a little inward
    p["RightUpperArm"] = (SIT_SH + hand_lift, 0, arm_out)
    p["LeftUpperArm"] = (SIT_SH + hand_lift, 0, -arm_out)
    p["RightLowerArm"] = (SIT_EL, 0, 0)
    p["LeftLowerArm"] = (SIT_EL, 0, 0)
    p["RightHand"] = (-10, 0, 0)
    p["LeftHand"] = (-10, 0, 0)
    return p


SIT_SH, SIT_EL, SIT_OUT = 10.0, 52.0, -30.0  # tools/anim/ella_scan2.py sit: the hands land 0.04 over the seated skirt (0 vertices inside), 0.52 either side of the middle


def sit_keys():
    return [m.kf(0.0, sit_pose(SIT_OUT, 0.0)), m.kf(2.4, sit_pose(SIT_OUT, 1.5)), m.kf(4.8, sit_pose(SIT_OUT, 0.0))]


# ---------------------------------------------------------------- wave
WAVE_SH = (10.0, 0.0, 135.0)  # (rx, ry, rz) shoulder of the raised arm: tools/anim/ella_wave_scan.py counted the puff / forearm / hand vertices inside the shawl, braid and hair over a grid — rz 130-140 with rx 0-15 clips least (14-16 puff vertices, forearm 0) and puts the hand level with the head


def wave_pose(wag, up=1.0):
    """up 0 = the arm down at her side (the A line), 1 = raised; wag = the elbow's wag (deg) and half of it at the wrist"""
    p = idle_pose(0)
    p["RightUpperArm"] = (2.0 + (WAVE_SH[0] - 2.0) * up, 0, WAVE_SH[2] * up)
    p["RightLowerArm"] = (6.0 + (44.0 - 6.0) * up + wag * up, 0, 0)
    p["RightHand"] = (0, 0, wag * 0.55 * up)
    p["Head"] = (-4 * up, -6 * up, 0)
    return p


def wave_keys():
    # GPT r2 (notes/gpt/wr-anim/ella_r2_a.md): ±18° at the elbow and the wrist, three wags in ~1.2 s, then hold: raise 0.35 s,
    # wag, hold, lower. (the elbow stays <= 62°: the hand keeps >= 0.35 from the hair — tools/anim/ella_scan2.py wave)
    ks = [(0.0, wave_pose(0, 0.0)), (0.35, wave_pose(0)), (0.55, wave_pose(18)), (0.75, wave_pose(-18)), (0.95, wave_pose(18)),
          (1.15, wave_pose(-18)), (1.35, wave_pose(18)), (1.55, wave_pose(-18)), (1.85, wave_pose(0)), (2.3, wave_pose(0, 0.0))]
    return [m.kf(t, p) for t, p in ks]


# ---------------------------------------------------------------- output
def joint_mats(pose):
    """body_def.py's POSES format: joint -> 3x3 (local rotation at the joint)"""
    out = {}
    for part, v in pose.items():
        j = JOINT_OF.get(part)
        if j is None:
            continue
        out[j] = m.rot(v[0], v[1], v[2]).tolist()
    return out


def main(argv):
    m.use_rig("ella")
    anims = {
        "Mech_EllaWalk": dict(loop=True, prio="Core", keys=walk_keys()),
        "Mech_EllaIdle": dict(loop=True, prio="Core", keys=idle_keys()),
        "Mech_EllaSit": dict(loop=True, prio="Core", keys=sit_keys()),
        "Mech_EllaWave": dict(loop=False, prio="Action", keys=wave_keys()),
    }
    poses = {}
    for name, spec in anims.items():
        spec["auth"] = ELLA_AUTH
        if name == "Mech_EllaWave":
            spec["keys"] = [dict(k, only=("RightUpperArm", "RightLowerArm", "RightHand", "Head")) for k in spec["keys"]]
        m.write_rbxmx(name, spec)
        for i, k in enumerate(spec["keys"]):
            poses[f"{name}_K{i}"] = joint_mats(m.full_pose(k["pose"]))
    os.makedirs(os.path.dirname(POSES_OUT), exist_ok=True)
    json.dump(poses, open(POSES_OUT, "w"))
    m.PREVIEW = PREVIEW_OUT
    m.write_preview(anims)
    txt = open(PREVIEW_OUT, encoding="utf-8").read().replace("f:ClearAllChildren()" + chr(10), "")
    open(PREVIEW_OUT, "w", encoding="utf-8", newline=chr(10)).write(txt)
    print(f"{len(anims)} Ella animations -> {m.OUT_DIR}; poses -> {POSES_OUT}")
    # the joint angles that matter for the skirt
    for name in ("Mech_EllaWalk",):
        for i, k in enumerate(anims[name]["keys"]):
            p = m.full_pose(k["pose"])
            print(f"  {name} K{i} t={k['t']:.2f}  hips R {p['RightUpperLeg'][0]:+.1f} L {p['LeftUpperLeg'][0]:+.1f}"
                  f"  knees R {p['RightLowerLeg'][0]:+.1f} L {p['LeftLowerLeg'][0]:+.1f}  pelvis y {p['LowerTorso'][3][1]:+.3f}")


if __name__ == "__main__":
    main(sys.argv[1:])
