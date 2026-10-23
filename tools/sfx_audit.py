"""'Cheap sound' audit of the game's sound files (wr-sound 10-22). Numbers only — flags what players hear as cheap:
 thin (almost no energy < 200 Hz), a gap inside a one-shot (silence > 0.12 s in the middle), dead air at the front/back,
 harsh / hissy (> 40 % of the energy above 5 kHz), sounds that are spectrally near-identical to another one.
Run: tools/audio_ai/.venv/Scripts/python.exe tools/sfx_audit.py [dirs...]   (default art/sfx/v3 then v2 — v3 wins)
"""
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from scipy.io import wavfile

ROOT = Path(__file__).resolve().parent.parent
FF = r"C:\Users\glori\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.1-essentials_build\bin\ffmpeg.exe"
LOOPS = {"liftMotor", "ambGarage", "ambStreet", "ambBirds", "ambNight", "pourGlug", "wheelRoll"}
NEEDS_LOW = {"engineStart", "engineFail", "impact", "impactBurst", "clank", "partDrop", "install", "exhaustLoud", "rattle",
             "swayClunk", "cartLoad", "jackPump", "liftLock", "hoodClose", "hoodOpen", "pumpkinPop", "coachStop", "brakeGrind",
             "crankShort", "liftMotor", "ambGarage"}
HIGH_OK = {"tireHiss", "steamHiss", "washerSpray", "sparkle", "sparkleTrail", "slipperDing", "scannerBeep", "scanStart", "tick",
           "ambBirds", "morningBird", "brakeSqueal", "beltSqueal", "deskBell", "orderDing", "signPaint", "bell12", "payout",
           "levelUp", "wrongBuzz", "stamp", "spark", "bladeSnap", "wrench", "wrenchTighten", "ratchet", "hammerTap", "clap", "neonOn"}


def load(p):
    t = Path(tempfile.gettempdir()) / "_aud.wav"
    subprocess.run([FF, "-y", "-loglevel", "quiet", "-i", str(p), "-ac", "1", "-ar", "32000", "-c:a", "pcm_s16le", str(t)])
    sr, d = wavfile.read(str(t))
    return sr, d.astype(np.float64) / 32768


def main():
    dirs = [Path(a) for a in sys.argv[1:]] or [ROOT / "art/sfx/v3", ROOT / "art/sfx/v2"]
    files = {}
    for d in reversed(dirs):
        for f in d.rglob("*.ogg"):
            if "_spare" in f.stem or "_wr32" in f.stem:
                continue
            files[f.stem] = f
    feats = {}
    print("name | dur | <200Hz % | >5kHz % | lead s | tail s | gap s | flags")
    for name, f in sorted(files.items()):
        sr, x = load(f)
        n = len(x)
        spec = np.abs(np.fft.rfft(x * np.hanning(n))) ** 2
        fr = np.fft.rfftfreq(n, 1 / sr)
        tot = spec.sum() + 1e-12
        low = spec[fr < 200].sum() / tot * 100
        hi = spec[fr > 5000].sum() / tot * 100
        hop = int(sr * 0.01)
        env = np.array([20 * np.log10(np.sqrt(np.mean(x[i:i + hop] ** 2)) + 1e-9) for i in range(0, n - hop, hop)])
        peak = env.max()
        act = np.where(env > peak - 40)[0]
        lead = act[0] * 0.01
        tail = (len(env) - 1 - act[-1]) * 0.01
        # longest silence between active frames (below peak-45 dB)
        gap = 0.0
        run = 0
        for v in env[act[0]:act[-1] + 1]:
            run = run + 1 if v < peak - 45 else 0
            gap = max(gap, run * 0.01)
        flags = []
        loop = name in LOOPS
        if not loop and lead > 0.06:
            flags.append("앞 빈 공백")
        if not loop and tail > 0.25:
            flags.append("뒤 빈 공백")
        if not loop and gap > 0.12:
            flags.append("가운데 빈 틈")
        if name in NEEDS_LOW and low < 8:
            flags.append("얇음(저음 거의 없음)")
        if name not in HIGH_OK and hi > 40:
            flags.append("쇳소리/쉬익 많음")
        if hi > 60:
            flags.append("고음이 60% 넘음")
        print(f"{name} | {n/sr:.2f} | {low:.0f} | {hi:.0f} | {lead:.2f} | {tail:.2f} | {gap:.2f} | {', '.join(flags)}")
        # spectral envelope in 24 log bands for the 'sounds alike' check
        edges = np.geomspace(60, 12000, 25)
        e = np.array([spec[(fr >= edges[i]) & (fr < edges[i + 1])].sum() for i in range(24)])
        feats[name] = np.log10(e / e.sum() + 1e-9)
    names = sorted(feats)
    print("\n비슷하게 들릴 수 있는 쌍(소리 모양 닮음 > 0.97):")
    for i, a in enumerate(names):
        for b in names[i + 1:]:
            c = np.corrcoef(feats[a], feats[b])[0, 1]
            if c > 0.97:
                print(f"  {a} ~ {b}  {c:.3f}")


if __name__ == "__main__":
    main()
