"""Cut a Freesound CC0 recording into a game sound (wr-sound 10-22): one-shots = from the first onset (or --at S) for --dur seconds,
cubic fade-out, peak -1 dBTP, mono ogg; --loop = a seamless loop of --dur seconds from --at (equal-power crossfade of the tail
into the head, 1.5 s).   Usage: tools/audio_ai/.venv/Scripts/python.exe tools/sfx_fs_cut.py <in.mp3> <out.ogg> --dur D [--at S] [--loop] [--hp HZ]
"""
import argparse
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from scipy.io import wavfile

FF = r"C:\Users\glori\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.1-essentials_build\bin\ffmpeg.exe"
SR = 44100


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inp")
    ap.add_argument("out")
    ap.add_argument("--dur", type=float, required=True)
    ap.add_argument("--at", type=float)
    ap.add_argument("--loop", action="store_true")
    ap.add_argument("--hp", type=float, default=0)
    a = ap.parse_args()
    t = Path(tempfile.gettempdir()) / "_fscut.wav"
    af = f"highpass=f={a.hp}" if a.hp else "anull"
    subprocess.run([FF, "-y", "-loglevel", "error", "-i", a.inp, "-ac", "1", "-ar", str(SR), "-af", af, "-c:a", "pcm_s16le", str(t)], check=True)
    _, d = wavfile.read(str(t))
    x = d.astype(np.float64) / 32768
    if a.at is not None:
        s = int(a.at * SR)
    elif a.loop:
        s = 0
    else:
        hop = int(SR * 0.005)
        env = np.array([np.sqrt(np.mean(x[i:i + hop] ** 2)) + 1e-9 for i in range(0, len(x) - hop, hop)])
        thr = env.max() * 10 ** (-18 / 20)
        s = max(0, int(np.argmax(env > thr)) * hop - int(0.01 * SR))
    n = int(a.dur * SR)
    if a.loop:
        X = int(1.5 * SR)
        seg = x[s:s + n + X]
        if len(seg) < n + X:
            print("too short for loop", len(x) / SR)
            sys.exit(1)
        y = seg[:n].copy()
        w = np.linspace(0, 1, X)
        y[:X] = y[:X] * np.sin(w * np.pi / 2) + seg[n:n + X] * np.cos(w * np.pi / 2)
        pk = 0.68
    else:
        y = x[s:s + n].copy()
        f = min(int(0.06 * SR), len(y) // 3)
        y[-f:] *= np.linspace(1, 0, f) ** 3
        y[:int(0.003 * SR)] *= np.linspace(0, 1, int(0.003 * SR))
        pk = 0.86
    y = y / (np.abs(y).max() + 1e-9) * pk
    tmp = Path(tempfile.gettempdir()) / "_fscut2.wav"
    wavfile.write(str(tmp), SR, (y * 32767).astype(np.int16))
    Path(a.out).parent.mkdir(parents=True, exist_ok=True)
    subprocess.run([FF, "-y", "-loglevel", "error", "-i", str(tmp), "-c:a", "libvorbis", "-q:a", "6", a.out], check=True)
    print(f"{a.out}: from {s / SR:.2f}s, {len(y) / SR:.2f}s")


if __name__ == "__main__":
    main()
