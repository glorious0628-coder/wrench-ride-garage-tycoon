"""Mechanic moves for the R15 character (wr-anim, 10-22) — one source for every Mech_* animation.

  py tools/anim/mech_anim.py                 -> art/anim/<Name>.rbxmx (KeyframeSequence, to upload) + build/anim/preview.luau
  py tools/anim/mech_anim.py --check         -> also print where hands / feet land (studs, HRP space) per key pose

Grounds: notes/research/mechanic_motions_1022.md §3 (TOP 5, lengths 3-10x shorter than real, 3-5 key poses).
Rig = Roblox default R15 (blocky, scale 1): every joint frame is axis-aligned, so a pose is just a rotation in the
character's own axes — X right, Y up, Z back (forward = -Z). Signs that matter:
  +rx at a shoulder / hip = the limb swings forward;  -rx at a knee = it bends;  -rx at the waist / neck = lean / look down.
Rotations are CFrame.Angles(rx, ry, rz) = Rx @ Ry @ Rz (written out as full matrices, so the .rbxmx and the Studio
preview are the same numbers). Legs that must stay planted are solved here (2-link, side view), not eyeballed.
"""
import math
import os
import sys

import numpy as np
from scipy.optimize import minimize

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT_DIR = os.path.join(ROOT, "art", "anim")
PREVIEW = os.path.join(ROOT, "build", "anim", "preview.luau")

# ---------------------------------------------------------------- rig (measured in Studio, default R15, 10-22)
HIP_Y = -1.0  # hip joints sit at the root pivot height (HRP space); the root joint pivots there too
THIGH = 0.92  # hip -> knee
SHIN = 1.009  # knee -> ankle
ANKLE_SOLE = 0.262  # ankle -> sole, foot flat
GROUND = -3.192  # sole of a standing rig (HRP space) = HIP_Y - HipHeight
LEG_R = 0.49  # half the leg's thickness (a knee on the floor sits this high)
HIP_X = 0.5
WAIST_UP = 0.4  # hip height -> waist
UT_C = 0.849  # waist -> upper torso centre
SHOULDER = np.array([0.972, 0.598, 0.0])  # from the upper torso centre (x mirrored for the left)
UARM = 0.774  # shoulder -> elbow
LARM = 0.807  # elbow -> wrist
HAND_C = 0.132  # wrist -> hand centre

PARENT = {
    "LowerTorso": "HumanoidRootPart", "UpperTorso": "LowerTorso", "Head": "UpperTorso",
    "LeftUpperArm": "UpperTorso", "LeftLowerArm": "LeftUpperArm", "LeftHand": "LeftLowerArm",
    "RightUpperArm": "UpperTorso", "RightLowerArm": "RightUpperArm", "RightHand": "RightLowerArm",
    "LeftUpperLeg": "LowerTorso", "LeftLowerLeg": "LeftUpperLeg", "LeftFoot": "LeftLowerLeg",
    "RightUpperLeg": "LowerTorso", "RightLowerLeg": "RightUpperLeg", "RightFoot": "RightLowerLeg",
}
ORDER = ["LowerTorso", "UpperTorso", "Head", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm",
         "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg",
         "RightFoot"]
# joint attachment in Part0 (a0) and Part1 (a1), positions only (all identity rotations)
JOINT = {
    "LowerTorso": ((0, -1.0, 0), (0, -0.2, 0)),
    "UpperTorso": ((0, 0.2, 0), (0, -0.849, 0)),
    "Head": ((0, 0.849, 0), (0, -0.576, 0)),
    "RightUpperArm": ((0.972, 0.598, 0), (-0.501, 0.419, 0)),
    "LeftUpperArm": ((-0.972, 0.598, 0), (0.501, 0.419, 0)),
    "RightLowerArm": ((0, -0.355, 0), (0, 0.275, 0)),
    "LeftLowerArm": ((0, -0.355, 0), (0, 0.275, 0)),
    "RightHand": ((0, -0.532, 0), (0, 0.132, 0)),
    "LeftHand": ((0, -0.532, 0), (0, 0.132, 0)),
    "RightUpperLeg": ((0.5, -0.2, 0), (0, 0.471, 0)),
    "LeftUpperLeg": ((-0.5, -0.2, 0), (0, 0.471, 0)),
    "RightLowerLeg": ((0, -0.449, 0), (0, 0.413, 0)),
    "LeftLowerLeg": ((0, -0.449, 0), (0, 0.413, 0)),
    "RightFoot": ((0, -0.596, 0), (0, 0.106, 0)),
    "LeftFoot": ((0, -0.596, 0), (0, 0.106, 0)),
}
# a second body (wr-anim 10-22, GPT r2 'a short-arm variant'): the slender R15 avatars (narrow torso, long legs, short
# arms — the user's own avatar), measured in Play from its AnimationConstraint attachments. Its moves end in "_S" and
# MechAnim picks them for an avatar whose arms are short. x offsets of slanted limbs are kept (the FK uses them).
RIGS = {
    "classic": dict(JOINT=dict(JOINT), HIP_Y=-1.0, HIPUP=0.0, THIGH=0.92, SHIN=1.009, ANKLE_SOLE=0.262, GROUND=-3.192,
                    LEG_R=0.49, FOOT_HALF=(0.5, 0.156, 0.5), SHIN_HALF=(0.49, 0.65, 0.49), AUTH=2.192, TOOL_DY=0.0),
    "slim": dict(JOINT={
        "LowerTorso": ((0, -1.221, 0), (0, -0.429, 0.018)),
        "UpperTorso": ((0, 0.069, 0.022), (0, -0.549, 0.046)),
        "Head": ((0, 0.742, 0.095), (0, -0.553, -0.006)),
        "RightUpperArm": ((0.245, 0.456, 0.073), (-0.142, 0.381, 0.020)),
        "LeftUpperArm": ((-0.246, 0.456, 0.073), (0.138, 0.374, 0.021)),
        "RightLowerArm": ((0.124, -0.321, -0.024), (-0.126, 0.266, -0.018)),
        "LeftLowerArm": ((-0.128, -0.328, -0.023), (0.126, 0.266, -0.019)),
        "RightHand": ((0.121, -0.254, -0.020), (-0.099, 0.152, 0.058)),
        "LeftHand": ((-0.121, -0.254, -0.021), (0.097, 0.152, 0.057)),
        "RightUpperLeg": ((0.266, -0.188, -0.013), (0.031, 0.555, -0.022)),
        "LeftUpperLeg": ((-0.266, -0.188, -0.013), (-0.031, 0.557, -0.022)),
        "RightLowerLeg": ((-0.047, -0.518, -0.003), (0.001, 0.484, -0.021)),
        "LeftLowerLeg": ((0.047, -0.516, -0.003), (-0.002, 0.484, -0.019)),
        "RightFoot": ((0.007, -0.602, 0.050), (0.024, 0.104, 0.079)),
        "LeftFoot": ((-0.008, -0.602, 0.053), (-0.020, 0.103, 0.078)),
    }, HIP_Y=-0.98, HIPUP=0.241, THIGH=1.076, SHIN=1.086, ANKLE_SOLE=0.292, GROUND=-3.43, LEG_R=0.2,
        FOOT_HALF=(0.117, 0.188, 0.22), SHIN_HALF=(0.157, 0.696, 0.207), AUTH=2.45, TOOL_DY=0.085),
}
RIG = "classic"


def use_rig(name):
    global RIG, JOINT, HIP_Y, HIPUP, THIGH, SHIN, ANKLE_SOLE, GROUND, LEG_R, FOOT_HALF, SHIN_HALF, AUTH, TOOL_DY
    r = RIGS[name]
    RIG = name
    JOINT, HIP_Y, HIPUP, THIGH, SHIN = r["JOINT"], r["HIP_Y"], r["HIPUP"], r["THIGH"], r["SHIN"]
    ANKLE_SOLE, GROUND, LEG_R, FOOT_HALF, SHIN_HALF = r["ANKLE_SOLE"], r["GROUND"], r["LEG_R"], r["FOOT_HALF"], r["SHIN_HALF"]
    AUTH, TOOL_DY = r["AUTH"], r["TOOL_DY"]
    _LAST.clear()


PRIORITY = {"Idle": 0, "Movement": 1, "Action": 2, "Action2": 3, "Action3": 4, "Action4": 5, "Core": 1000}
EASE = {"Linear": 0, "Constant": 1, "Elastic": 2, "Cubic": 3, "Bounce": 4, "CubicV2": 5}
EDIR = {"In": 0, "Out": 1, "InOut": 2}


def rot(rx, ry, rz):
    a, b, c = (math.radians(v) for v in (rx, ry, rz))
    X = np.array([[1, 0, 0], [0, math.cos(a), -math.sin(a)], [0, math.sin(a), math.cos(a)]])
    Y = np.array([[math.cos(b), 0, math.sin(b)], [0, 1, 0], [-math.sin(b), 0, math.cos(b)]])
    Z = np.array([[math.cos(c), -math.sin(c), 0], [math.sin(c), math.cos(c), 0], [0, 0, 1]])
    return X @ Y @ Z


def cf(r=None, p=(0, 0, 0)):
    m = np.eye(4)
    if r is not None:
        m[:3, :3] = r
    m[:3, 3] = p
    return m


# ---------------------------------------------------------------- legs (side view: f = forward, y = up)
# a segment's world angle phi: 0 = hanging straight down, +90 = pointing forward. phi_child = phi_parent + rx.

def hip_at(pelvis_y, pelvis_f, pelvis_pitch):
    """hip joint (f, y): the root pivots HIPUP below the hips on some bodies, so the pitch moves them a little"""
    a = math.radians(pelvis_pitch)
    return np.array([pelvis_f - HIPUP * math.sin(a), HIP_Y + pelvis_y - HIPUP * (1 - math.cos(a))])


def leg(pelvis_y, pelvis_f, pelvis_pitch, foot_f, foot_y=None, foot_phi=0.0, knee_fwd=True):
    """Joint rx (hip, knee, ankle) so the ankle lands at (foot_f, foot_y) with the foot at world angle foot_phi
    (0 = flat). pelvis_* = the root joint's offset / pitch (rx). foot_y defaults to 'sole on the ground'."""
    hip = hip_at(pelvis_y, pelvis_f, pelvis_pitch)
    if foot_y is None:
        # flat foot: ankle is ANKLE_SOLE over the floor; a tilted foot keeps its toe / heel on it (close enough)
        foot_y = GROUND + ANKLE_SOLE * math.cos(math.radians(foot_phi))
    ank = np.array([foot_f, foot_y])
    d = ank - hip
    dist = float(np.hypot(*d))
    dist = min(dist, THIGH + SHIN - 1e-4)
    # angle of hip->ankle from straight down (+ = forward)
    base = math.degrees(math.atan2(d[0], -d[1]))
    cos_h = (THIGH ** 2 + dist ** 2 - SHIN ** 2) / (2 * THIGH * dist)
    a_h = math.degrees(math.acos(max(-1, min(1, cos_h))))
    cos_k = (THIGH ** 2 + SHIN ** 2 - dist ** 2) / (2 * THIGH * SHIN)
    a_k = math.degrees(math.acos(max(-1, min(1, cos_k))))
    thigh_phi = base + a_h if knee_fwd else base - a_h
    shin_phi = thigh_phi - (180 - a_k) if knee_fwd else thigh_phi + (180 - a_k)
    hip_rx = thigh_phi - pelvis_pitch
    knee_rx = shin_phi - thigh_phi
    ankle_rx = foot_phi - shin_phi
    return hip_rx, knee_rx, ankle_rx


def legs_pose(pose, pelvis_y, pelvis_f, pelvis_pitch, left, right):
    """left / right = dict(foot_f=, foot_y=None, foot_phi=0, out=0 (x spread deg as rz), yaw=0)."""
    for side, spec in (("Left", left), ("Right", right)):
        h, k, a = leg(pelvis_y, pelvis_f, pelvis_pitch, spec["foot_f"], spec.get("foot_y"), spec.get("foot_phi", 0.0))
        sign = -1 if side == "Left" else 1
        pose[side + "UpperLeg"] = (h, spec.get("yaw", 0) * sign, spec.get("out", 0) * sign)
        pose[side + "LowerLeg"] = (k, 0, 0)
        pose[side + "Foot"] = (a, 0, -spec.get("out", 0) * sign)
    pose["LowerTorso"] = (pelvis_pitch, 0, 0, (0, pelvis_y, -pelvis_f))
    return pose


def kneel(pose, pelvis_y, pelvis_f, pelvis_pitch, down="Right", up_foot_f=0.75, down_knee_f=-0.35, out=6):
    """One knee on the floor (down), the other foot flat ahead (up). Down leg: knee at LEG_R over the floor, shin
    lying back along it, toes tucked (foot pointing down)."""
    up = "Left" if down == "Right" else "Right"
    h, k, a = leg(pelvis_y, pelvis_f, pelvis_pitch, up_foot_f)
    s_up = -1 if up == "Left" else 1
    pose[up + "UpperLeg"] = (h, 0, out * s_up)
    pose[up + "LowerLeg"] = (k, 0, 0)
    pose[up + "Foot"] = (a, 0, -out * s_up)
    # down leg: thigh from the hip to the knee point, shin back flat (phi -90), foot -90 (toes into the floor)
    hip = hip_at(pelvis_y, pelvis_f, pelvis_pitch)
    # the knee joint sits LEG_R + 0.12 over the floor: the shin box reaches a little past the joint
    ky = GROUND + LEG_R + 0.12
    dy = ky - hip[1]
    down_knee_f = pelvis_f - math.sqrt(max(0.0, THIGH ** 2 - dy ** 2))  # the knee a thigh's length from the hip, behind it
    knee = np.array([down_knee_f, ky])
    d = knee - hip
    thigh_phi = math.degrees(math.atan2(d[0], -d[1]))
    length = float(np.hypot(*d))
    shin_phi = -90.0 + 6.0  # a touch raised at the ankle, like a real kneel
    s_dn = -1 if down == "Left" else 1
    pose[down + "UpperLeg"] = (thigh_phi - pelvis_pitch, 0, out * s_dn * 0.5)
    pose[down + "LowerLeg"] = (shin_phi - thigh_phi, 0, 0)
    pose[down + "Foot"] = (-48.0 - shin_phi, 0, 0)  # toes tucked under, heel up
    pose["LowerTorso"] = (pelvis_pitch, 0, 0, (0, pelvis_y, -pelvis_f))
    return pose, abs(length - THIGH)  # (how far the knee misses its spot — must be ~0, else move the pelvis)


# ---------------------------------------------------------------- forward kinematics (checks)

def fk(pose):
    world = {"HumanoidRootPart": np.eye(4)}
    for name in ORDER:
        a0, a1 = JOINT[name]
        v = pose.get(name, (0, 0, 0))
        p = v[3] if len(v) > 3 else (0, 0, 0)
        T = cf(rot(v[0], v[1], v[2]), p)
        world[name] = world[PARENT[name]] @ cf(None, a0) @ T @ np.linalg.inv(cf(None, a1))
    return world


def where(pose):
    w = fk(pose)
    out = {}
    for n in ("RightHand", "LeftHand", "Head"):
        out[n] = w[n][:3, 3]
    for n in ("RightFoot", "LeftFoot"):
        # lowest of the foot box corners
        fx, fy, fz = FOOT_HALF
        corners = [w[n] @ np.array([x, y, z, 1]) for x in (-fx, fx) for y in (-fy, fy) for z in (-fz, fz)]
        out[n + "_low"] = min(c[1] for c in corners) - GROUND
    for n in ("RightLowerLeg", "LeftLowerLeg"):
        sx, sy, sz = SHIN_HALF
        corners = [w[n] @ np.array([x, y, z, 1]) for x in (-sx, sx) for y in (-sy, sy) for z in (-sz, sz)]
        out[n + "_low"] = min(c[1] for c in corners) - GROUND
    return out


# ---------------------------------------------------------------- the moves

BAY_FWD = 0.9  # the stand is 2.4 off the bumper: step in until the thighs touch it (refs: mechanics lean on the car)


def stand_lean(lean=-32, hips_back=0.28, pitch=-14):
    """Engine bay: stepped in to the bumper, feet planted shoulder wide, hips back, chest over the bay."""
    p = {}
    legs_pose(p, pelvis_y=-0.10, pelvis_f=BAY_FWD - hips_back, pelvis_pitch=pitch,
              left=dict(foot_f=BAY_FWD + 0.05, out=4), right=dict(foot_f=BAY_FWD - 0.12, out=4))
    p["UpperTorso"] = (lean - pitch, 0, 0)
    p["Head"] = (-12, 0, 0)
    return p


def arms(p, r=None, l=None):
    """r / l = (shoulder rx, ry, rz), (elbow rx), (wrist rx, ry, rz)."""
    for side, spec in (("Right", r), ("Left", l)):
        if spec is None:
            continue
        sh, el, wr = spec
        p[side + "UpperArm"] = tuple(sh)
        p[side + "LowerArm"] = (el, 0, 0)
        p[side + "Hand"] = tuple(wr)
    return p


def reach(p, side, target, elbow_out=12, twist=0.0, wrist=(0, 0, 0)):
    """Arm IK: shoulder (rx, ry, rz) + elbow rx so the hand centre lands on target (HRP space), the rest of the pose
    as it is (torso lean included). Soft pull toward a natural arm (elbow a bit out, no wild twist)."""
    s = 1 if side == "Right" else -1
    up, lo, hd = side + "UpperArm", side + "LowerArm", side + "Hand"
    tgt = np.array(target, dtype=float)
    tgt[0] *= 1  # (x given for this side directly)

    def cost(v):
        q = dict(p)
        q[up] = (v[0], v[1], v[2])
        q[lo] = (v[3], 0, 0)
        q[hd] = tuple(wrist)
        w = fk(full_pose(q))
        miss = w[hd][:3, 3] - tgt
        nat = (v[1] - twist * s) ** 2 * 0.00003 + (v[2] - elbow_out * s) ** 2 * 0.00001 + (v[3] - 30) ** 2 * 0.000003
        return float(miss @ miss) + nat

    best = None
    for g in ((60, 0, 0, 30), (100, 0, -20 * s, 20), (30, 0, -30 * s, 60), (140, 0, 0, 10)):
        r = minimize(cost, np.array(g, dtype=float), method="L-BFGS-B",
                     bounds=[(-60, 185), (-80, 80), (-110, 110), (0, 150)])
        if best is None or r.fun < best.fun:
            best = r
    v = best.x
    p[up] = (float(v[0]), float(v[1]), float(v[2]))
    p[lo] = (float(v[3]), 0, 0)
    p[hd] = tuple(wrist)
    w = fk(full_pose(p))
    return float(np.linalg.norm(w[hd][:3, 3] - tgt))


# the tool in the right hand (Roblox grip: handle = hand * RightGripAttachment(0,-0.158,0, Rx -90) * Tool.Grip^-1): a
# wrench or ratchet lies along the hand's -Z; the impact wrench's anvil points out of the fist (hand -Y).
TOOLS = {
    # roll: a hand axis that must line up with `roll` (hand: the jaw stands along the bolt axis = hand Y, either
    # sign; gun: the grip's 'up' (hand -Z) toward the given way, signed)
    # measured on the game's own meshes in the hand (Play, 10-22): the Wrench mesh is held at its middle, jaw 0.55 out;
    # the ImpactWrench mesh's anvil ~1.0 out of the fist, the body 0.5 up the grip. (RatchetWrench block: head 1.7 out
    # — it reaches past the bolt into the bay with these keys, which reads fine from outside.)
    "hand": dict(tip=np.array([0.0, -0.12, -0.55]), axis=np.array([0.0, 0.0, -1.0]), roll=np.array([0.0, 1.0, 0.0]), signed=False, rollw=0.2),
    "gun": dict(tip=np.array([0.0, -1.0, -0.5]), axis=np.array([0.0, -1.0, 0.0]), roll=np.array([0.0, 0.0, -1.0]), signed=True, rollw=0.6),
}


_LAST = {}


def euler_xyz(R):
    """R = Rx @ Ry @ Rz -> (rx, ry, rz) degrees."""
    ry = math.asin(max(-1.0, min(1.0, R[0, 2])))
    rx = math.atan2(-R[1, 2], R[2, 2])
    rz = math.atan2(-R[0, 1], R[0, 0])
    return math.degrees(rx), math.degrees(ry), math.degrees(rz)


def tool_reach(p, tool, tip, aim, roll, wrist_cost=1.0, max_raise=185, aim_w=1.5, elbow_out=0.0):
    """Right arm, 7 joints (shoulder 3, elbow, wrist 3): the tool's tip on `tip`, its axis along `aim` (HRP space).
    Wrists cost (a bent-back wrist reads broken), so the shoulder / elbow do the work first. roll = an optional
    hand-space up direction wish (unit, world) for the hand's +Y... (unused when None). Returns (tip miss, aim error°,
    worst wrist°)."""
    spec = dict(TOOLS[tool])
    spec["tip"] = spec["tip"] + np.array([0.0, TOOL_DY, 0.0])  # (the slim hand's grip sits higher in the hand)
    tgt = np.array(tip, dtype=float)
    want = np.array(aim, dtype=float)
    want /= np.linalg.norm(want)
    rwant = np.array(roll, dtype=float)
    rwant /= np.linalg.norm(rwant)

    def rollerr(h):
        d = float((h[:3, :3] @ spec["roll"]) @ rwant)
        return 1 - (d if spec["signed"] else abs(d))

    def frame(v):
        q = dict(p)
        q["RightUpperArm"] = (v[0], v[1], v[2])
        q["RightLowerArm"] = (v[3], 0, 0)
        q["RightHand"] = (v[4], v[5], v[6])
        return fk(full_pose(q))["RightHand"]

    def cost(v):
        h = frame(v)
        at = (h @ np.append(spec["tip"], 1))[:3]
        ax = h[:3, :3] @ spec["axis"]
        miss = at - tgt
        c = float(miss @ miss) + aim_w * (1 - float(ax @ want)) + spec["rollw"] * rollerr(h)
        # an elbow up above the shoulder with the hand down low reads broken: keep the elbow under the shoulder
        q = dict(p)
        q["RightUpperArm"] = (v[0], v[1], v[2])
        w = fk(full_pose(q))
        el = (w["RightUpperArm"] @ np.array([0, -0.355, 0, 1]))[:3]
        sh = (w["RightUpperArm"] @ np.array([-0.501, 0.419, 0, 1]))[:3]
        c += max(0.0, el[1] - sh[1] + 0.1) * 2.0
        # wrist: rx = bend (±70 real), ry = forearm twist (±80 real, cheap), rz = side tilt (±25 real, dear)
        c += wrist_cost * (v[4] ** 2 + v[5] ** 2 * 0.25 + v[6] ** 2 * 3.0) * 0.00004
        c += (v[1] ** 2) * 0.00001 + (v[3] - 40) ** 2 * 0.000003 + (v[2] - elbow_out) ** 2 * 0.00002
        return c

    best = None
    guesses = [(60, 0, 0, 40, 0, 0, 0), (90, 0, -25, 30, 0, 0, 0), (30, 0, -30, 70, 0, 0, 0), (120, 0, 0, 20, 0, 0, 0),
               (70, 20, -10, 60, -30, 0, 0), (50, -20, 10, 80, 30, 0, 0), (20, 0, 0, 100, 40, 0, 0), (80, -40, -20, 90, 0, 60, 0),
               (80, 40, -20, 90, 0, -60, 0), (10, 0, -10, 20, 0, 80, 0), (10, 0, -10, 20, 0, -80, 0)]
    if _LAST.get(tool) is not None:
        guesses.insert(0, tuple(_LAST[tool]))  # the previous key's arm first: neighbouring keys stay alike
    for g in guesses:
        r = minimize(cost, np.array(g, dtype=float), method="L-BFGS-B",
                     bounds=[(-60, max_raise), (-80, 80), (-110, 110), (0, 150), (-70, 70), (-85, 85), (-28, 28)])
        if best is None or r.fun < best.fun:
            best = r
    v = best.x
    _LAST[tool] = v
    p["RightUpperArm"] = (float(v[0]), float(v[1]), float(v[2]))
    p["RightLowerArm"] = (float(v[3]), 0, 0)
    p["RightHand"] = (float(v[4]), float(v[5]), float(v[6]))
    h = frame(v)
    at = (h @ np.append(spec["tip"], 1))[:3]
    ax = h[:3, :3] @ spec["axis"]
    err = math.degrees(math.acos(max(-1, min(1, float(ax @ want)))))
    rerr = math.degrees(math.acos(max(-1, min(1, 1 - rollerr(h)))))
    return float(np.linalg.norm(at - tgt)), max(err, rerr), float(max(abs(v[4]), abs(v[5]), abs(v[6])))


def kf(t, pose, ease="CubicV2", edir="InOut", only=None):
    return dict(t=t, pose=pose, ease=ease, edir=edir, only=only)


# ---------------------------------------------------------------- Mech_JackPump (module level)
# The game's 3D floor jack (JackLook: HANDLE_PUMP 40 ± 8 at 1.6 Hz, JackService.handleAt) has a steep handle: its end is
# 3.6 over the floor (measured in Play 10-22, Sedan front) — chest-low on an R15, so the mechanic stands and pushes it
# down with both hands (ref 03: "Auto mechanic uses hydraulic jack", standing, both hands on the end). The client puts the
# root JACK_D behind the handle's end (mid stroke), facing the car (MechAnim.luau JACK_D). Keys at the stroke's top
# (e 48) and bottom (e 32); the loop starts at the top.
JACK_D = 1.0  # (the client stands the root this far behind the handle's end: MechAnim.luau JACK_D)


def jack_pump(note=lambda name, miss: None, jack_d=None, tune=None):
    jd = JACK_D if jack_d is None else jack_d
    T = dict(hb0=-0.2, hb1=0.10, py0=-0.04, py1=-0.20, pp0=-2, pp1=-3, ut0=-3, ut1=-9, h0=10, h1=16)
    T.update(tune or {})

    def handle_end(e):
        # measured (root space: root 3.192 over the floor, 1.0 behind the e-40 end): end y, z and the shaft's angle
        y, dz, el = {48: (0.755, -0.409, 66.0), 40: (0.449, 0.0, 58.0), 32: (0.088, 0.362, 50.0)}[e]
        u = np.array([0.0, math.sin(math.radians(el)), math.cos(math.radians(el))])  # up the shaft, toward me
        n = np.array([0.0, u[2], -u[1]])  # its upper side (the side a hand pushes down on)
        return np.array([0.0, y, -jd + dz]), u, n

    def pump(e):
        k = (48 - e) / 16  # 0 top .. 1 bottom
        end, u, n = handle_end(e)
        p = {}
        hb = T['hb0'] + (T['hb1'] - T['hb0']) * k  # the hips go back and sink as the weight comes down onto the handle: arms stay long
        legs_pose(p, pelvis_y=T['py0'] + (T['py1'] - T['py0']) * k, pelvis_f=-hb, pelvis_pitch=T['pp0'] + (T['pp1'] - T['pp0']) * k,
                  left=dict(foot_f=0.30, out=5), right=dict(foot_f=-0.25, out=5))  # left foot ahead, staggered
        p["UpperTorso"] = (T['ut0'] + (T['ut1'] - T['ut0']) * k, 0, 0)  # near upright the whole stroke: the arms and knees do the work, the face stays up
        p["Head"] = (T['h0'] + (T['h1'] - T['h0']) * k, 0, 0)  # eyes on the car (the jack's saddle), never bowed onto the hands
        # right hand over the end cap, left hand a palm lower down the shaft; both on its upper side
        note("Mech_JackPump", reach(p, "Right", end - u * 0.40 + n * 0.18 + np.array([0.05, 0, 0]), wrist=(-25, 0, 0), elbow_out=18))
        note("Mech_JackPump", reach(p, "Left", end - u * 0.75 + n * 0.18 + np.array([-0.05, 0, 0]), wrist=(-25, 0, 0), elbow_out=18))
        return p
    return [kf(0.0, pump(48)), kf(0.3125, pump(32)), kf(0.625, pump(48))]


def build():
    """Targets are in HRP space (studs): x right, y up (floor = GROUND -3.19), z back (forward = -z). Car geometry
    (CarParts.work): the engine-bay stand is 2.4 ahead of the front bumper's pivot (grille ~2.0 ahead, hood edge
    ~2.9 over the floor = y -0.3); a wheel stand is 3.4 out from the wheel centre (hub 1.49 over the floor = y -1.70,
    the nuts on the tyre's outer face ~2.7 ahead), so at a wheel the kneel shifts the body 0.7 toward it."""
    A = {}
    MISS = {}
    QA = {}

    def note(name, m):
        MISS[name] = max(MISS.get(name, 0.0), m)

    # 1 ── Mech_Lean (base, loop): standing over the engine bay ─────────────────────────────────────────────
    def lean_base(lean=-32, hb=0.28, breathe=0.0):
        p = stand_lean(lean=lean - 2 * breathe, hips_back=hb + 0.02 * breathe)
        note("Mech_Lean", reach(p, "Right", (0.7, -0.2 - 0.04 * breathe, -2.4)))  # both hands on the radiator support
        note("Mech_Lean", reach(p, "Left", (-0.75, -0.2 - 0.04 * breathe, -2.4)))
        return p
    A["Mech_Lean"] = dict(loop=True, prio="Action", keys=[kf(0, lean_base()), kf(1.2, lean_base(breathe=1)),
                                                          kf(2.4, lean_base())])

    # 2 ── engine-bay bolt, tool in the right hand (arms only, over the Lean base) ────────────────────────────
    # A bolt standing up in the bay (front, reachable over the bumper): the wrench / ratchet lies flat on it and the
    # hand swings its handle through 60° about the bolt (two 0.22 s strokes per 0.44 s loop); the left hand rests on
    # the fender lip. The impact wrench instead sits straight down on the bolt and buzzes.
    ARMS = ("RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperArm", "LeftLowerArm", "LeftHand")
    # a bolt on top of the engine: ~3.2 over the floor (y ≈ 0) and ~1 stud in past the hood edge (z -3.0); the
    # hood edge / radiator support top is ~2.9 over the floor (y -0.3) and ~2.0 ahead
    BOLT = np.array([0.25, -0.15, -3.45])  # past the radiator: the front top of the engine
    LEFT_REST_BAY = (-0.75, -0.2, -2.4)  # left hand flat on the radiator support

    def tooled(name, base, tool, tip, aim, left, roll, **kw):
        p = base()
        m, e, w = tool_reach(p, tool, tip, aim, roll, **kw)
        QA.setdefault(name, []).append((m, e, w))
        note(name, reach(p, "Left", left))
        return p

    def sweep(a):
        r = math.radians(a)
        aim = -np.array([math.sin(r), 0.0, math.cos(r)])  # from the hand toward the bolt, flat
        return tooled("Mech_BoltSweep", stand_lean, "hand", BOLT, aim, LEFT_REST_BAY, (0, 1, 0))
    A["Mech_BoltSweep"] = dict(loop=True, prio="Action2", keys=[
        kf(0.00, sweep(-30), only=ARMS), kf(0.11, sweep(30), only=ARMS),
        kf(0.22, sweep(-30), only=ARMS), kf(0.33, sweep(30), only=ARMS), kf(0.44, sweep(-30), only=ARMS)])

    def baygun(k):
        return tooled("Mech_BayGun", stand_lean, "gun", BOLT + np.array([0, 0.02 * k, 0]), (0.0, -1.0, -0.2),
                      LEFT_REST_BAY, (0.0, 0.25, -1.0))
    A["Mech_BayGun"] = dict(loop=True, prio="Action2", keys=[
        kf(0.00, baygun(0), only=ARMS), kf(0.05, baygun(1), only=ARMS), kf(0.10, baygun(0), only=ARMS)])

    # 3 ── Mech_Kneel (base, loop): right knee down by a wheel, left foot ahead, body 0.7 toward the wheel ───
    # toward the wheel: classic 0.9 (1.15 had its wide chest on the tyre); the slim body is narrow and short-armed: 1.25
    SH = 0.9 if RIG == "classic" else 1.25
    KNEEL_LEAN = -12  # leaning in a little (GPT r1: at -18 the head crowded the fender)
    F = GROUND + 3.192  # (heights below are written for the classic body's floor: F moves them onto this body's floor)
    # kneel height from the body: the down thigh ~35° off vertical, its knee on the floor
    KNEEL_Y = (GROUND + LEG_R + 0.12 + THIGH * math.cos(math.radians(35))) - HIP_Y

    def kneel_body(lean=-12, breathe=0.0, down="Right"):
        p = {}
        _, miss = kneel(p, pelvis_y=KNEEL_Y - 0.03 * breathe, pelvis_f=SH, pelvis_pitch=-4, down=down,
                        up_foot_f=SH + 0.67 * THIGH)
        p["UpperTorso"] = (lean + 4 - 2 * breathe, 0, 0)
        p["Head"] = (-2, 0, 0)  # eyes on the hub without dropping the head onto the fender
        return p, miss

    def kneel_base(breathe=0.0):
        p, miss = kneel_body(lean=KNEEL_LEAN, breathe=breathe)
        note("Mech_Kneel", miss)
        note("Mech_Kneel", reach(p, "Right", (0.55, F - 1.55 - 0.03 * breathe, -1.85)))
        note("Mech_Kneel", reach(p, "Left", (-0.35, F - 1.25 - 0.03 * breathe, -1.55)))  # forearm on the knee
        return p
    A["Mech_Kneel"] = dict(loop=True, prio="Action", keys=[kf(0, kneel_base()), kf(1.4, kneel_base(1)),
                                                           kf(2.8, kneel_base())])

    # 4 ── wheel nut, tool in the right hand (over the Kneel base) ─────────────────────────────────────────────
    # nut on the tyre's outer face by the hub. Wrench: handle out to the right in the wheel's plane, strokes of 40°
    # (WheelSweep, loop 0.44 s); the impact wrench points straight in and buzzes (WheelGun). TorqueClick = the last
    # nut done up: one smooth pull down ~30°, the handle gives a hair at the 'click' and stops, hands off.
    NUT = np.array([0.0, F - 1.55, -2.72])
    LEFT_KNEE = (-0.35, F - 1.25, -1.55)  # forearm on the up knee
    LEFT_ON_WHEEL = (-0.55, F - 1.25, -2.45)  # left hand flat on the tyre

    def kneel_plain():
        return kneel_body(lean=KNEEL_LEAN)[0]  # = the Kneel base exactly (these anims move the arms only)

    def wheel_hand(name, deg, base=kneel_plain, left=LEFT_ON_WHEEL):
        r = math.radians(deg)
        aim = -np.array([math.cos(r), math.sin(r), 0.0])  # the handle points from the hand to the nut
        return tooled(name, base, "hand", NUT, aim, left, (0, 0, 1), max_raise=100, aim_w=0.4)
    A["Mech_WheelSweep"] = dict(loop=True, prio="Action2", keys=[
        kf(0.00, wheel_hand("Mech_WheelSweep", 25), only=ARMS), kf(0.11, wheel_hand("Mech_WheelSweep", -15), only=ARMS),
        kf(0.22, wheel_hand("Mech_WheelSweep", 25), only=ARMS), kf(0.33, wheel_hand("Mech_WheelSweep", -15), only=ARMS),
        kf(0.44, wheel_hand("Mech_WheelSweep", 25), only=ARMS)])

    def wheelgun(k):
        return tooled("Mech_WheelGun", kneel_plain, "gun", NUT + np.array([0, 0.02 * k, 0]), (0.0, 0.0, -1.0),
                      tuple(NUT + np.array([-0.12, 0.32, 0.8])), (0, 1, 0),  # left hand on top of the gun (ref 01)
                      elbow_out=25)  # (right arm +rz = elbow out to the side: the gun on the hub shows from beside, GPT r1)
    A["Mech_WheelGun"] = dict(loop=True, prio="Action2", keys=[
        kf(0.00, wheelgun(0), only=ARMS), kf(0.05, wheelgun(1), only=ARMS), kf(0.10, wheelgun(0), only=ARMS)])

    def tq(deg, lean):
        return wheel_hand("Mech_TorqueClick", deg, base=lambda: kneel_body(lean=lean - 4)[0])
    A["Mech_TorqueClick"] = dict(loop=False, prio="Action2", keys=[
        kf(0.00, tq(22, -14)), kf(0.25, tq(20, -16)), kf(1.15, tq(-10, -22), edir="In"),
        kf(1.20, tq(-14, -23), ease="Linear"), kf(1.32, tq(-12, -22)), kf(1.50, tq(-11, -20))])

    # 5 ── Mech_JackPump: jack_pump() below (module level, so tools/anim/jack_pump.py can build just this one) ─────────
    A["Mech_JackPump"] = dict(loop=True, prio="Action2", keys=jack_pump(note))

    # 6 ── Mech_StandPlace (1.0 s): down on one knee by the sill, turned side-on, ONE arm slides the stand in ──────
    # Research ② / §3 TOP 5 #3: "한 팔로 스탠드", "팔만 차 밑에" — only the arm goes under the car. Kneeling square to
    # the car with both arms, a blocky R15's head went into the door (Play 10-22: the door panel is a box 0.6 outside
    # the stand spot), so the body turns side-on and the right arm reaches out to its right-front: the stand spot is
    # STAND_HAND (root space) from my root — the client faces me that way (MechAnim.luau STAND_D / STAND_TURN).
    # The hand holds the stand by its top (the Bay stand is ~1.0 tall: column 0.2..1.1, handle at 0.8); the left hand rests on
    # the down leg's thigh.
    STAND_HAND = np.array([1.95, -2.3, -0.9])  # the hand at full reach (the stand's top is 0.15 past it)

    def stand(reach_k, lean):
        p = {}
        _, miss = kneel(p, pelvis_y=-0.95, pelvis_f=0.15, pelvis_pitch=-6, down="Left", up_foot_f=0.85)
        note("Mech_StandPlace", miss)
        p["UpperTorso"] = (lean + 6, 10 * reach_k, -14 * reach_k)  # twist and dip the right shoulder toward the car
        p["Head"] = (-8, 18, 0)  # eyes on the stand under the sill
        start = np.array([1.0, -1.4, -0.7])
        hand = start + (STAND_HAND - start) * reach_k
        note("Mech_StandPlace", reach(p, "Right", tuple(hand), elbow_out=38, wrist=(-15 * reach_k, 0, 0)))
        note("Mech_StandPlace", reach(p, "Left", (-0.72, -1.5, -0.1)))  # resting on the down leg's thigh
        return p
    A["Mech_StandPlace"] = dict(loop=False, prio="Action2", keys=[
        kf(0.00, stand(0.0, -8)), kf(0.45, stand(1.0, -14), edir="Out"),
        kf(0.65, stand(1.0, -14)), kf(1.00, stand(0.3, -10))])

    # the same move for the left arm (the car on my left): every pose mirrored, left <-> right
    def mirrored(spec):
        def flip(pose):
            q = {}
            for n, v in pose.items():
                m = n.replace("Left", "@").replace("Right", "Left").replace("@", "Right") if ("Left" in n or "Right" in n) else n
                if len(v) > 3:
                    q[m] = (v[0], -v[1], -v[2], (-v[3][0], v[3][1], v[3][2]))
                else:
                    q[m] = (v[0], -v[1], -v[2])
            return q
        return dict(spec, keys=[dict(k, pose=flip(k["pose"])) for k in spec["keys"]])
    A["Mech_StandPlace_L"] = mirrored(A["Mech_StandPlace"])

    # 7 ── Hood: Release (0.3) · Lift (0.5) · PropRod (0.4) — standing at the grille ───────────────────────
    def front(lean, pitch, hb, step=1.0):
        """at the grille, stepped in to the bumper by `step` of BAY_FWD (0 = where the work stand puts me)"""
        f = BAY_FWD * step
        p = {}
        legs_pose(p, pelvis_y=-0.10 * (hb / 0.3), pelvis_f=f - hb, pelvis_pitch=pitch,
                  left=dict(foot_f=f + 0.12, out=4), right=dict(foot_f=f - 0.10, out=4))
        p["UpperTorso"] = (lean - pitch, 0, 0)
        return p

    def put(p, name, r=None, l=None, rw=(0, 0, 0), lw=(0, 0, 0)):
        if r is not None:
            note(name, reach(p, "Right", r, wrist=rw))
        if l is not None:
            note(name, reach(p, "Left", l, wrist=lw))
        return p

    def hang(p):  # arms down, relaxed (no target: a rest pose)
        arms(p, r=((10, 0, 5), 14, (0, 0, 0)), l=((10, 0, -5), 14, (0, 0, 0)))
        return p
    # hood edge shut: ~2.0 ahead, y -0.3; the latch lever under its middle. Release: step in, right hand under it.
    rel0 = hang(front(-6, -2, 0.0, step=0.3))
    rel1 = put(front(-24, -10, 0.2), "Mech_HoodRelease", (0.12, -0.55, -2.05), (-0.75, -0.35, -2.0), rw=(40, 0, 0))
    rel1["Head"] = (-18, 0, 0)
    rel2 = put(front(-23, -10, 0.2), "Mech_HoodRelease", (0.12, -0.38, -2.05), (-0.75, -0.35, -2.0), rw=(55, 0, 0))
    rel2["Head"] = (-14, 0, 0)
    A["Mech_HoodRelease"] = dict(loop=False, prio="Action2", keys=[kf(0, rel0), kf(0.16, rel1), kf(0.30, rel2)])
    # Lift: both hands under the edge, push it up fast with the hood's 0.45 s swing — the open edge ends ~4.4 over my
    # head height (measured in Play), out of any R15's reach, so the hands ride it to full reach by 0.3 s and stay up
    lift0 = put(front(-22, -9, 0.2), "Mech_HoodLift", (0.5, -0.38, -2.05), (-0.5, -0.38, -2.05), rw=(40, 0, 0), lw=(40, 0, 0))
    lift1 = put(front(-8, -3, 0.06), "Mech_HoodLift", (0.55, 1.15, -2.45), (-0.55, 1.15, -2.45), rw=(20, 0, 0), lw=(20, 0, 0))
    lift1["Head"] = (14, 0, 0)
    lift2 = put(front(2, 2, 0.0), "Mech_HoodLift", (0.5, 2.15, -2.75), (-0.5, 2.15, -2.75))  # arms up at full reach
    lift2["Head"] = (22, 0, 0)
    A["Mech_HoodLift"] = dict(loop=False, prio="Action2", keys=[
        kf(0, lift0), kf(0.15, lift1, edir="In"), kf(0.30, lift2, edir="Out"), kf(0.50, lift2)])
    # Rod: in the game the rod stands up the moment the hood is open, on my LEFT front (x -1.8, from the radiator
    # support y -0.8 up into the hood, measured in Play). So the left hand takes it mid-shaft and pushes it home into
    # the hood's hole while the right hand rests on the radiator support (ref 04: one hand on the rod) — a hand that
    # visibly meets the rod instead of a hand waving at a hood that is out of reach.
    ROD = np.array([-1.8, 0.0, -2.45])
    prop0 = put(front(2, 2, 0.0), "Mech_PropRod", (0.5, 2.15, -2.75), (-0.5, 2.15, -2.75))
    prop1 = put(front(-14, -6, 0.1), "Mech_PropRod", (0.6, -0.25, -2.4), tuple(ROD + np.array([0.12, 0.55, 0.05])))
    prop1["Head"] = (-6, 22, 0)
    prop2 = put(front(-6, -2, 0.05), "Mech_PropRod", (0.6, -0.25, -2.4), tuple(ROD + np.array([0.12, 1.45, 0.0])))
    prop2["Head"] = (16, 18, 0)
    prop3 = hang(front(-3, -1, 0.0))  # (stays stepped in: the Lean base is stepped in too)
    A["Mech_PropRod"] = dict(loop=False, prio="Action2", keys=[
        kf(0, prop0), kf(0.14, prop1), kf(0.28, prop2), kf(0.40, prop3)])

    # 8 ── Mech_SitPedalPress (in the driver's seat): right foot onto the brake, press 0.4, hold, lift 0.3 ───
    def sit(press):
        p = {"LowerTorso": (-6, 0, 0)}
        p["LeftUpperLeg"] = (84, 0, -6)
        p["LeftLowerLeg"] = (-64, 0, 0)
        p["LeftFoot"] = (-14, 0, 6)
        p["RightUpperLeg"] = (84 - 3 * press, 2, 3)
        p["RightLowerLeg"] = (-66 + 7 * press, 0, 0)
        p["RightFoot"] = (-12 + 30 * press, 0, 0)  # heel down, the ball of the foot pushes (ref 05)
        p["UpperTorso"] = (2 + 5 * press, 0, 0)  # leans back into the seat as the leg pushes
        p["Head"] = (-6 - 3 * press, 0, 0)
        note("Mech_SitPedalPress", reach(p, "Right", (0.62, 0.55 + 0.03 * press, -1.55)))  # hands on the wheel
        note("Mech_SitPedalPress", reach(p, "Left", (-0.62, 0.55 + 0.03 * press, -1.55)))
        return p
    A["Mech_SitPedalPress"] = dict(loop=False, prio="Action2", keys=[
        kf(0, sit(0)), kf(0.40, sit(1), edir="Out"), kf(1.00, sit(1)), kf(1.30, sit(0), edir="In")])

    for name, m in MISS.items():
        A[name]["miss"] = m
    for name, rows in QA.items():
        A[name]["tool"] = (max(r[0] for r in rows), max(r[1] for r in rows), max(r[2] for r in rows))
    return A


# ---------------------------------------------------------------- writers

def full_pose(pose):
    return {n: pose.get(n, (0, 0, 0)) for n in ORDER}


def matrix_of(v):
    r = rot(v[0], v[1], v[2])
    p = v[3] if len(v) > 3 else (0, 0, 0)
    return p, r


def xml_cf(v):
    p, r = matrix_of(v)
    vals = list(p) + [r[i, j] for i in range(3) for j in range(3)]
    tags = ["X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22"]
    return "".join(f"<{t}>{x:.6f}</{t}>" for t, x in zip(tags, vals))


def write_rbxmx(name, spec):
    ref = [0]

    def nref():
        ref[0] += 1
        return f"RBX{ref[0]:08X}"

    lines = ['<roblox xmlns:xmime="http://www.w3.org/2005/05/xmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
             'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">',
             f'<Item class="KeyframeSequence" referent="{nref()}"><Properties>',
             f'<float name="AuthoredHipHeight">{spec.get("auth", 2.192)}</float><bool name="Loop">{"true" if spec["loop"] else "false"}</bool>',
             f'<string name="Name">{name}</string><token name="Priority">{PRIORITY[spec["prio"]]}</token>',
             '</Properties>']

    def pose_xml(part, k, depth):
        only = k["only"]
        v = k["pose"].get(part, (0, 0, 0))
        active = (only is None) or (part in only)
        weight = 1 if active else 0
        kids = [c for c in ORDER if PARENT[c] == part]
        kids = [c for c in kids if only is None or c in only or any(_under(c, o) for o in only)]
        s = [f'<Item class="Pose" referent="{nref()}"><Properties>',
             f'<CoordinateFrame name="CFrame">{xml_cf(v) if active else xml_cf((0, 0, 0))}</CoordinateFrame>',
             f'<token name="EasingDirection">{EDIR[k["edir"]]}</token><token name="EasingStyle">{EASE[k["ease"]]}</token>',
             f'<string name="Name">{part}</string><float name="Weight">{weight}</float></Properties>']
        for c in kids:
            s.append(pose_xml(c, k, depth + 1))
        s.append("</Item>")
        return "".join(s)

    for i, k in enumerate(spec["keys"]):
        lines.append(f'<Item class="Keyframe" referent="{nref()}"><Properties><string name="Name">K{i}</string>'
                     f'<float name="Time">{k["t"]:.4f}</float></Properties>')
        root = [f'<Item class="Pose" referent="{nref()}"><Properties><CoordinateFrame name="CFrame">{xml_cf((0, 0, 0))}</CoordinateFrame>'
                f'<token name="EasingDirection">0</token><token name="EasingStyle">0</token><string name="Name">HumanoidRootPart</string>'
                f'<float name="Weight">0</float></Properties>']
        root.append(pose_xml("LowerTorso", k, 1))
        root.append("</Item>")
        lines.append("".join(root))
        lines.append("</Item>")
    lines.append("</Item></roblox>")
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(os.path.join(OUT_DIR, name + ".rbxmx"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))


def _under(part, ancestor_or_self):
    # True if ancestor_or_self is part or below part
    n = ancestor_or_self
    while n in PARENT:
        if n == part:
            return True
        n = PARENT[n]
    return n == part


def write_preview(anims):
    """Luau for Studio Edit: builds every KeyframeSequence into ReplicatedStorage.MechAnimDev (same numbers)."""
    out = ["local SS = game:GetService('ReplicatedStorage') -- (Studio dev stand-ins: MechAnim reads them in Studio only)",
           "local f = SS:FindFirstChild('MechAnimDev') or Instance.new('Folder'); f.Name = 'MechAnimDev'; f.Parent = SS",
           "f:ClearAllChildren()",
           "local PARENT = {" + ",".join(f"{k}='{v}'" for k, v in PARENT.items()) + "}",
           "local function P(name, x,y,z, a,b,c,d,e,g,h,i,j, w, es, ed)",
           "  local p = Instance.new('Pose'); p.Name = name; p.CFrame = CFrame.new(x,y,z,a,b,c,d,e,g,h,i,j)",
           "  p.Weight = w; p.EasingStyle = es; p.EasingDirection = ed; return p end"]
    es_enum = {v: k for k, v in EASE.items()}
    ed_enum = {v: k for k, v in EDIR.items()}
    for name, spec in anims.items():
        out.append(f"do local s = Instance.new('KeyframeSequence'); s.Name = '{name}'; s.Loop = {'true' if spec['loop'] else 'false'}; "
                   f"s.Priority = Enum.AnimationPriority.{spec['prio']}; s.AuthoredHipHeight = {spec.get('auth', 2.192)}")
        for k in spec["keys"]:
            out.append(f"  local k = Instance.new('Keyframe'); k.Time = {k['t']:.4f}; k.Parent = s")
            out.append("  local made = {}")
            out.append("  made.HumanoidRootPart = P('HumanoidRootPart',0,0,0,1,0,0,0,1,0,0,0,1,0,Enum.PoseEasingStyle.Linear,Enum.PoseEasingDirection.In); made.HumanoidRootPart.Parent = k")
            only = k["only"]
            for part in ORDER:
                if only is not None and part not in only and not any(_under(part, o) for o in only):
                    continue
                active = only is None or part in only
                v = k["pose"].get(part, (0, 0, 0)) if active else (0, 0, 0)
                p, r = matrix_of(v)
                nums = ",".join(f"{x:.6f}" for x in list(p) + [r[i, j] for i in range(3) for j in range(3)])
                out.append(f"  made.{part} = P('{part}',{nums},{1 if active else 0},Enum.PoseEasingStyle.{es_enum[EASE[k['ease']]]},"
                           f"Enum.PoseEasingDirection.{ed_enum[EDIR[k['edir']]]}); made.{part}.Parent = made[PARENT.{part}]")
        out.append("  s.Parent = f end")
    out.append("return #f:GetChildren() .. ' sequences'")
    os.makedirs(os.path.dirname(PREVIEW), exist_ok=True)
    with open(PREVIEW, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(out))


# the moves whose hands must visibly meet something at the wheel get the slim-body version too (GPT r2)
SLIM_SET = ("Mech_Kneel", "Mech_WheelGun", "Mech_WheelSweep")


def main(argv):
    sys.stdout.reconfigure(encoding="utf-8")
    use_rig("classic")
    anims = build()
    for spec in anims.values():
        spec["auth"] = AUTH
    if "--classic-only" not in argv:
        use_rig("slim")
        slim = build()
        for name in SLIM_SET:
            spec = slim[name]
            spec["auth"] = AUTH
            anims[name + "_S"] = spec
        use_rig("classic")
    for name, spec in anims.items():
        write_rbxmx(name, spec)
    write_preview(anims)
    print(f"{len(anims)} animations -> {OUT_DIR} + {PREVIEW}")
    if "--check" in argv:
        for name, spec in anims.items():
            if "tool" in spec:
                print(f"  {name}: tool tip miss {spec['tool'][0]:.3f} · aim off {spec['tool'][1]:.1f}° · wrist max {spec['tool'][2]:.0f}°")
            if "miss" in spec:
                print(f"  {name}: worst reach miss {spec['miss']:.3f} studs")
            use_rig("slim" if name.endswith("_S") else "classic")
            for i, k in enumerate(spec["keys"]):
                if k["only"]:
                    continue
                w = where(full_pose(k["pose"]))
                print(f"  {name} K{i} t={k['t']:.2f}  Rhand {np.round(w['RightHand'], 2)}  Lhand {np.round(w['LeftHand'], 2)}"
                      f"  feet low R {w['RightFoot_low']:+.2f} L {w['LeftFoot_low']:+.2f}  shins low R {w['RightLowerLeg_low']:+.2f} L {w['LeftLowerLeg_low']:+.2f}")


if __name__ == "__main__":
    main(sys.argv[1:])
