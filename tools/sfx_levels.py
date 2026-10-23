"""Level + end check for the game's sound files (wr-sound): loudest 0.3 s RMS, first/last 5 ms, and the in-game dB
(loudest + 20*log10(Volume from Shared/Sounds.luau)).  Run: py -I tools/sfx_levels.py [dir_or_ogg ...]  (default art/sfx/v2)
"""
import math
import re
import subprocess
import sys
import tempfile
import wave
from array import array
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FF = r"C:\Users\glori\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.1-essentials_build\bin\ffmpeg.exe"


def db(x):
    return -120.0 if x <= 0 else 20 * math.log10(x)


def analyse(p: Path):
    t = Path(tempfile.gettempdir()) / "_lv.wav"
    subprocess.run([FF, "-y", "-loglevel", "quiet", "-i", str(p), "-ac", "1", "-ar", "48000", "-c:a", "pcm_s16le", str(t)])
    with wave.open(str(t)) as w:
        d = array("h", w.readframes(w.getnframes()))
    sr = 48000
    n = len(d)
    win = min(int(0.3 * sr), n)
    best = -120.0
    step = int(0.05 * sr)
    for i in range(0, max(1, n - win + 1), step):
        seg = d[i:i + win]
        best = max(best, db(math.sqrt(sum(x * x for x in seg) / len(seg)) / 32768))
    k = int(0.005 * sr)
    first = db(math.sqrt(sum(x * x for x in d[:k]) / k) / 32768)
    last = db(math.sqrt(sum(x * x for x in d[-k:]) / k) / 32768)
    return n / sr, best, first, last


def volumes():
    s = (ROOT / "src/ReplicatedStorage/Shared/Sounds.luau").read_text(encoding="utf-8")
    return {m[0]: float(m[1]) for m in re.findall(r"(\w+) = \{ id = \"[^\"]*\", volume = ([\d.]+)", s)}


def main():
    args = sys.argv[1:] or [str(ROOT / "art/sfx/v2")]
    vol = volumes()
    files = []
    for a in args:
        p = Path(a)
        files += sorted(p.rglob("*.ogg")) if p.is_dir() else [p]
    print("name | dur | loudest0.3s | Volume | in-game | first5ms | last5ms")
    for f in files:
        if f.stem.endswith("_spare") or "_wr32" in f.stem:
            continue
        dur, best, first, last = analyse(f)
        v = vol.get(f.stem)
        ig = "" if v is None else f"{best + db(v):.1f}"
        print(f"{f.stem} | {dur:.2f} | {best:.1f} | {v if v is not None else '-'} | {ig} | {first:.0f} | {last:.0f}")


if __name__ == "__main__":
    main()
