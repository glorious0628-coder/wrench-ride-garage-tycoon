"""Propose Sound.Volume for every game sound so the in-game loudness (loudest 0.3 s RMS * Volume) lands on a target per
kind of sound (wr-sound 10-22: the old table spread 20 dB and the engine start was 12.5 dB under the fault sounds).
Reads art/sfx/v3 first, then art/sfx/v2.  Writes art/sfx/v3/volumes_1022.md.   Run: py -I tools/sfx_volumes.py
"""
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sfx_levels as L  # noqa: E402

ROOT = L.ROOT
# in-game target (dB, loudest 0.3 s RMS after Volume)
T = {
    # hand work: one level, tiny things a bit under
    "wrench": -24, "wrenchTighten": -24, "ratchet": -24, "impact": -23, "impactBurst": -22, "clank": -23, "install": -24,
    "partDrop": -25, "hammerTap": -24, "cartLoad": -24, "bladeSnap": -26, "spark": -27, "jackPump": -24, "rattle": -24,
    "swayClunk": -24, "engineCrank": -22, "boltPop": -25, "partSlide": -24, "tick": -29, "crankShort": -23, "scanStart": -25, "scannerBeep": -25,
    # the engine and the faults: the start is the payoff, so it is the top of the work sounds
    "engineStart": -21, "engineFail": -22, "exhaustLoud": -23, "brakeSqueal": -24, "brakeGrind": -24, "beltSqueal": -23,
    "fuelPrime": -26, "tireHiss": -25, "steamHiss": -25,
    # money / progress
    "payout": -19, "levelUp": -18, "stamp": -24, "orderDing": -23, "deskBell": -24, "signPaint": -22, "cheer": -21,
    "clap": -24, "lineHonk": -23, "wrongBuzz": -26,
    # the shop
    "hoodOpen": -24, "hoodClose": -24, "liftLock": -25, "liftMotor": -30, "wiperMotor": -26, "washerSpray": -26,
    "washerWhirr": -27, "pourGlug": -29, "trainPass": -29,
    # background beds (loops)
    "ambGarage": -35, "ambStreet": -35, "ambBirds": -37, "ambNight": -35,
    # halloween
    "neonOn": -25, "coachRoll": -27, "coachStop": -25, "ellaCheer": -22, "ellaGiggle": -25, "morningBird": -27,
    "pumpkinPop": -21, "pumpkinRoll": -27, "slipperDing": -23, "sparkle": -27, "sparkleTrail": -26, "bell12": -19,
    "clockTickSoft": -31,
}
SOUNDS_KEY = {"ambNight": "nightAmb"}  # file name -> Sounds.luau key


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    old = L.volumes()
    rows = []
    for name, tgt in T.items():
        f = None
        for d in ("v3", "v2"):
            c = list((ROOT / "art/sfx" / d).rglob(name + ".ogg"))
            if c:
                f = c[0]
                break
        if not f:
            rows.append((name, None, None, None, None, "no file"))
            continue
        _, best, _, _ = L.analyse(f)
        v = 10 ** ((tgt - best) / 20)
        flag = ""
        if v > 1.0:
            flag = f"1.0에서 막힘 → {best:.1f} dB (목표 {tgt})"
            v = 1.0
        rows.append((name, f.parent.parent.name + "/" + f.parent.name, best, old.get(SOUNDS_KEY.get(name, name)), round(v, 2), flag))
    lines = ["# 효과음 크기 맞춤 제안 (10-22 wr-sound)", "", "게임 안 크기 = 파일의 가장 큰 0.3초 RMS(dB) + 20·log10(Volume). 종류마다 목표를 하나 두고 Volume을 거꾸로 계산. `v3`가 있으면 v3 파일, 없으면 v2 파일 기준.", "",
             "| 이름 | 파일 | 파일 크기(dB) | 옛 Volume | **새 Volume** | 게임 안(dB) | 메모 |", "|---|---|---|---|---|---|---|"]
    for name, loc, best, ov, nv, flag in rows:
        if best is None:
            lines.append(f"| {name} | - | - | - | - | - | {flag} |")
            continue
        lines.append(f"| {name} | {loc} | {best:.1f} | {ov if ov is not None else '-'} | **{nv}** | {best + 20 * math.log10(nv):.1f} | {flag} |")
    out = ROOT / "art/sfx/v3/volumes_1022.md"
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
