"""Trim, level and encode ElevenLabs SFX candidates (wr-sound).

art/sfx/raw/<key>_<n>.wav  ->  art/sfx/<category>/<key>_<n>.ogg  + art/sfx/levels.md

- one-shots: 70 Hz high-pass, mono, cut silence front/back, 3 ms fade-in, 30 ms fade-out, peak -1 dBTP
- loops (LOOPS): no trim, no fades (the seam must stay as ElevenLabs made it), mono, peak -3 dBTP, seam check
Run: py -I tools/sfx_process.py [key ...]
"""

import json
import re
import subprocess
import sys
import tempfile
import wave
from array import array
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "art" / "sfx" / "raw"
OUT = ROOT / "art" / "sfx"
FFBIN = Path(r"C:\Users\glori\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.1-essentials_build\bin")
FFMPEG = str(FFBIN / "ffmpeg.exe")

# key -> category folder (docs/design/sfx_list.md §5)
CATEGORY = {
    "engineFail": "fault", "brakeSqueal": "fault", "brakeGrind": "fault", "tireHiss": "fault",
    "steamHiss": "fault", "exhaustLoud": "fault",
    "engineStart": "fix", "brakeQuiet": "fix",
    "wrench": "tool", "wrenchTighten": "tool", "impact": "tool", "impactBurst": "tool", "ratchet": "tool", "spark": "tool",
    "scannerBeep": "tool", "wrenchFit": "tool", "boltCrack": "tool", "threadSpin": "tool", "boltSnug": "tool",
    "clank": "part", "install": "part", "partDrop": "part", "wheelRoll": "part",
    "hoodOpen": "shop", "hoodClose": "shop", "liftMotor": "shop", "liftLock": "shop", "carArrive": "shop",
    "deskBell": "shop", "cheer": "shop",
    "payout": "money", "levelUp": "money", "receiptPrint": "money", "stamp": "money",
    "wrongBuzz": "ui",
    "bell12": "halloween", "sparkleTrail": "halloween", "pumpkinPop": "halloween", "slipperDing": "halloween",
    "ambNight": "halloween", "bellOne": "halloween", "bellBig": "halloween",
    "neonOn": "halloween", "coachRoll": "halloween", "coachStop": "halloween", "ellaCheer": "halloween",
    "sparkle": "halloween", "pumpkinRoll": "halloween", "ellaGiggle": "halloween", "morningBird": "halloween",
    "clockTickSoft": "halloween",
    "signPaint": "money", "brushSwish": "money", "sparkleTiny": "money",
    "beltSqueal": "fault", "swayClunk": "fault", "rattle": "fault", "fuelPrime": "fault", "hammerTap": "tool",
    "ambGarage": "town", "ambStreet": "town", "ambBirds": "town", "trainPass": "town",
    "crankShort": "fix", "clap": "shop", "orderDing": "shop", "lineHonk": "shop", "tick": "money",
    "scanStart": "tool", "jackPump": "tool", "cartLoad": "part",
    "boltPop": "tool", "wrenchHeavy": "tool", "tightenHeavy": "tool", "ratchetHeavy": "tool", "impactHeavy": "tool", "partSlide": "part",
    "wiperMotor": "curb", "bladeSnap": "curb", "washerSpray": "curb", "washerWhirr": "curb", "pourGlug": "curb",
}
LOOPS = {"liftMotor", "wheelRoll", "ambGarage", "ambStreet", "ambBirds", "ambNight", "pourGlug"}
PEAK_ONESHOT = -1.3  # before encoding; the ogg must end at -1.0 dBTP or below
PEAK_LOOP = -3.3


def run(args):
    return subprocess.run(args, capture_output=True, text=True, encoding="utf-8", errors="replace")


def measure(path: Path) -> dict:
    """true peak (dBTP), integrated loudness (LUFS, None if < 0.4 s), duration"""
    r = run([FFMPEG, "-hide_banner", "-nostats", "-i", str(path), "-af", "ebur128=peak=true", "-f", "null", "-"])
    err = r.stderr
    tp = re.findall(r"Peak:\s+(-?[\d.]+|-inf) dBFS", err)
    i = re.findall(r"I:\s+(-?[\d.]+) LUFS", err)
    with wave.open(str(path)) if path.suffix == ".wav" else _decode(path) as w:
        dur = w.getnframes() / w.getframerate()
    lufs = float(i[-1]) if i and dur >= 0.4 else None
    return {"tp": float(tp[-1]) if tp and tp[-1] != "-inf" else -99.0, "lufs": lufs, "dur": dur}


def _decode(path: Path):
    tmp = Path(tempfile.gettempdir()) / ("_sfx_decode_" + path.stem + ".wav")
    run([FFMPEG, "-hide_banner", "-y", "-i", str(path), "-c:a", "pcm_s16le", str(tmp)])
    return wave.open(str(tmp))


def samples(path: Path):
    with wave.open(str(path)) as w:
        data = array("h", w.readframes(w.getnframes()))
        return data, w.getframerate(), w.getnchannels()


def rms_db(vals) -> float:
    if not vals:
        return -99.0
    s = sum(v * v for v in vals) / len(vals)
    import math
    return 10 * math.log10(s / (32768.0 ** 2)) if s > 0 else -99.0


def mono_loss(path: Path) -> float:
    """dB lost when the stereo raw is folded to mono (phase cancel check)"""
    data, _, ch = samples(path)
    if ch != 2:
        return 0.0
    left, right = data[0::2], data[1::2]
    st = (rms_db(left) + rms_db(right)) / 2
    mono = rms_db([(a + b) / 2 for a, b in zip(left, right)])
    return round(st - mono, 1)


def process(src: Path, tmpdir: Path) -> dict:
    key, n = src.stem.rsplit("_", 1)
    loop = key in LOOPS
    cat = CATEGORY.get(key, "misc")
    raw = measure(src)
    stage = tmpdir / (src.stem + "_s1.wav")
    chain = ["highpass=f=70", "pan=mono|c0=0.5*c0+0.5*c1"]
    if not loop:
        chain += [
            "silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.005:detection=peak",
            "areverse",
            "silenceremove=start_periods=1:start_threshold=-55dB:start_silence=0.02:detection=peak",
            "areverse",
        ]
    run([FFMPEG, "-hide_banner", "-y", "-i", str(src), "-af", ",".join(chain), "-c:a", "pcm_s16le", str(stage)])
    m1 = measure(stage)
    target = PEAK_LOOP if loop else PEAK_ONESHOT
    gain = target - m1["tp"]
    chain2 = [f"volume={gain:.2f}dB"]
    if not loop:
        fade_out = min(0.03, m1["dur"] / 4)
        chain2 += ["afade=t=in:d=0.003", f"afade=t=out:st={max(0.0, m1['dur'] - fade_out):.4f}:d={fade_out:.4f}"]
    dst = OUT / cat / (src.stem + ".ogg")
    dst.parent.mkdir(parents=True, exist_ok=True)
    run([FFMPEG, "-hide_banner", "-y", "-i", str(stage), "-af", ",".join(chain2), "-c:a", "libvorbis", "-q:a", "6", str(dst)])
    fin = measure(dst)
    if fin["tp"] > -1.0 and not loop:  # vorbis overshoot: pull down and re-encode once
        extra = -1.1 - fin["tp"]
        chain2[0] = f"volume={gain + extra:.2f}dB"
        run([FFMPEG, "-hide_banner", "-y", "-i", str(stage), "-af", ",".join(chain2), "-c:a", "libvorbis", "-q:a", "6", str(dst)])
        fin = measure(dst)
    flags = []
    if m1["dur"] < 0.08:
        flags.append("거의 소리 없음")
    if raw["tp"] < -30:
        flags.append("원본이 아주 작음")
    ml = mono_loss(src)
    if ml > 3:
        flags.append(f"모노로 합치면 {ml} dB 작아짐")
    seam = None
    if loop:
        data, sr, _ = samples(stage)
        k = int(sr * 0.02)
        a, b = rms_db(data[:k]), rms_db(data[-k:])
        jump = abs(int(data[0]) - int(data[-1])) / 32768.0
        seam = f"앞뒤 20 ms 음량 {a:.1f} / {b:.1f} dB, 이음 튐 {jump:.3f}"
        if abs(a - b) > 3 or jump > 0.05:
            flags.append("이음매 확인 필요")
    return {
        "key": key, "n": int(n), "cat": cat, "loop": loop,
        "raw_dur": round(raw["dur"], 2), "dur": round(fin["dur"], 2),
        "tp": round(fin["tp"], 1), "lufs": None if fin["lufs"] is None else round(fin["lufs"], 1),
        "raw_tp": round(raw["tp"], 1), "mono_loss": ml, "seam": seam, "flags": flags,
        "file": str(dst.relative_to(ROOT)).replace("\\", "/"),
    }


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    keys = set(sys.argv[1:])
    srcs = sorted(p for p in RAW.glob("*_*.wav") if not keys or p.stem.rsplit("_", 1)[0] in keys)
    results = []
    with tempfile.TemporaryDirectory() as td:
        for p in srcs:
            try:
                r = process(p, Path(td))
            except FileNotFoundError:  # nothing left after the silence cut (an almost silent take)
                print(json.dumps({"key": p.stem, "error": "empty after trim"}))
                continue
            results.append(r)
            print(json.dumps(r, ensure_ascii=False))
    # merge into levels.json, rewrite levels.md
    lj = OUT / "levels.json"
    old = json.loads(lj.read_text(encoding="utf-8")) if lj.exists() else []
    seen = {(r["key"], r["n"]) for r in results}
    allr = [r for r in old if (r["key"], r["n"]) not in seen] + results
    allr.sort(key=lambda r: (r["cat"], r["key"], r["n"]))
    lj.write_text(json.dumps(allr, ensure_ascii=False, indent=1), encoding="utf-8")
    lines = [
        "# 효과음 길이·음량 표 (tools/sfx_process.py가 만듦)",
        "",
        "한 번 소리: 70 Hz 아래 자름·모노·앞뒤 무음 자름·페이드(3 ms / 30 ms)·피크 −1 dBTP 이하. 반복(loop): 자르지 않음·피크 −3 dBTP·이음매 검사.",
        "LUFS는 0.4초보다 짧으면 '-'. 크게 들리는 정도는 Roblox Volume으로 맞춰요(docs/design/sfx_list.md §1).",
        "",
        "| 파일 | 원본 길이 | 다듬은 길이 | 피크 dBTP | LUFS | 메모 |",
        "|---|---|---|---|---|---|",
    ]
    for r in allr:
        memo = "; ".join(r["flags"] + ([r["seam"]] if r["seam"] else []))
        lines.append(f"| {r['file']} | {r['raw_dur']} | {r['dur']} | {r['tp']} | {'-' if r['lufs'] is None else r['lufs']} | {memo} |")
    (OUT / "levels.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
