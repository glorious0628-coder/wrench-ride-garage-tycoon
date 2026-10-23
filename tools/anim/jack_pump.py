"""Mech_JackPump alone (wr-anim 10-23): mech_anim.py's whole build takes 6 minutes, this one animation a few seconds.
  py tools/anim/jack_pump.py [--out DIR]  ->  art/anim/Mech_JackPump.rbxmx + build/anim/preview_jack.luau (Studio stand-in)
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mech_anim as m  # noqa: E402


def main():
    m.use_rig("classic")
    misses = {}
    keys = m.jack_pump(lambda n, x: misses.__setitem__(n, max(misses.get(n, 0), x)))
    spec = dict(loop=True, prio="Action2", keys=keys, auth=m.AUTH)
    m.write_rbxmx("Mech_JackPump", spec)
    m.PREVIEW = os.path.join(m.ROOT, "build", "anim", "preview_jack.luau")
    m.write_preview({"Mech_JackPump": spec})
    txt = open(m.PREVIEW, encoding="utf-8").read().replace("f:ClearAllChildren()" + chr(10), "")
    open(m.PREVIEW, "w", encoding="utf-8", newline=chr(10)).write(txt)
    print("Mech_JackPump -> worst reach miss %.3f studs (JACK_D %.2f)" % (misses.get("Mech_JackPump", 0), m.JACK_D))


if __name__ == "__main__":
    main()
