"""Mech_SitCup (wr-anim 10-23, v2 after main review): a seated customer holds a coffee cup in the RIGHT fist; right arm + left arm (resting on the thigh) + head, over the stock
R15 sit (rbxassetid://2506281703, CustomerService plays it on the server NPC). Loop 8 s: the cup rests upright on the
palm in front of the belly, every so often it goes up to the mouth for a sip and comes back.
CoffeeService welds the cup to the right hand (holdIn) while this plays; stand up -> stop it (see notes/handoff/board.md).
Angles were tuned by eye in Play on a seated dummy customer (notes/playtest/wr-anim/coffee/): +rx shoulder = forward,
-rz shoulder = across the body, +rx elbow = bend, head -ry = turned toward the right shoulder.
  py tools/anim/sit_cup.py   ->  art/anim/Mech_SitCup.rbxmx
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mech_anim as m  # noqa: E402

MASK = ("RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperArm", "LeftLowerArm", "LeftHand", "Head")


def pose(r, head=(0, 0, 0), wrist=0):
    """r = right arm (shoulder rx, shoulder rz, elbow rx); wrist = the hand turned about the forearm (ry): the forearm horizontal puts the hand's Z axis straight up
    (the cup's axis, CoffeeService.holdIn seated); turned 110 the lid goes to the mouth."""
    p = {"RightUpperArm": (r[0], 0, r[1]), "RightLowerArm": (r[2], 0, 0), "RightHand": (0, wrist, 0)}
    p.update({"LeftUpperArm": (3, 0, 0), "LeftLowerArm": (86, 0, 0), "LeftHand": (0, 0, 0)})  # the left forearm rests on the thigh
    p["Head"] = head
    return p


REST = pose((22, -14, 68))                        # cup in the fist, in front of the right hip / belly
LIFT = pose((40, -32, 92), (4, -14, -4), 55)          # on its way up / down
SIP = pose((48, -50, 98), (8, -32, -8), 110)          # the cup at the corner of the mouth, the head turned to it


def main():
    m.use_rig("classic")
    keys = [
        m.kf(0.0, REST, only=MASK),
        m.kf(3.4, REST, only=MASK),
        m.kf(4.2, LIFT, only=MASK),
        m.kf(4.9, SIP, only=MASK),
        m.kf(5.7, SIP, only=MASK),
        m.kf(6.4, LIFT, only=MASK),
        m.kf(7.1, REST, only=MASK),
        m.kf(8.0, REST, only=MASK),
    ]
    spec = dict(loop=True, prio="Action", keys=keys, auth=m.AUTH)
    m.write_rbxmx("Mech_SitCup", spec)
    m.PREVIEW = os.path.join(m.ROOT, "build", "anim", "preview_sitcup.luau")  # (Studio stand-in: MechAnimDev, not the shared preview)
    m.write_preview({"Mech_SitCup": spec})
    txt = open(m.PREVIEW, encoding="utf-8").read().replace("f:ClearAllChildren()" + chr(10), "")  # (keep the other stand-ins)
    open(m.PREVIEW, "w", encoding="utf-8", newline=chr(10)).write(txt)
    print("Mech_SitCup ->", m.OUT_DIR)


if __name__ == "__main__":
    main()
