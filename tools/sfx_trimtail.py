"""Cut dead air off the back (and front) of finished sound files and end with a cubic fade (wr-sound 10-22).
A sound that is > 40 dB under its own peak for the last 0.3 s+ is just silence the game still 'plays' — and for the
'duck' sounds the music stays dipped under it.  Reads art/sfx/v3/<cat>/<name>.ogg (or copies from v2), writes v3 in place.
Run: tools/audio_ai/.venv/Scripts/python.exe tools/sfx_trimtail.py name [name ...]
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from scipy.io import wavfile

ROOT = Path(__file__).resolve().parent.parent
FF = r"C:\Users\glori\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.1-essentials_build\bin\ffmpeg.exe"
KEEP_TAIL = 0.08  # s of room after the last audible frame (peak - 46 dB) before the fade ends
FADE = 0.08


def main():
    for name in sys.argv[1:]:
        v3 = list((ROOT / "art/sfx/v3").rglob(name + ".ogg"))
        if v3:
            f = v3[0]
        else:
            v2 = list((ROOT / "art/sfx/v2").rglob(name + ".ogg"))
            if not v2:
                print(name, "not found")
                continue
            f = ROOT / "art/sfx/v3" / v2[0].parent.name / (name + ".ogg")
            f.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(v2[0], f)
        src = Path(tempfile.gettempdir()) / (name + "_src.ogg")
        shutil.copyfile(f, src)
        t = Path(tempfile.gettempdir()) / "_tt.wav"
        subprocess.run([FF, "-y", "-loglevel", "quiet", "-i", str(src), "-ac", "1", "-ar", "32000", "-c:a", "pcm_s16le", str(t)])
        sr, d = wavfile.read(str(t))
        x = d.astype(np.float64) / 32768
        hop = int(sr * 0.01)
        env = np.array([20 * np.log10(np.sqrt(np.mean(x[i:i + hop] ** 2)) + 1e-9) for i in range(0, len(x) - hop, hop)])
        act = np.where(env > env.max() - 46)[0]
        start = max(0.0, act[0] * 0.01 - 0.01)
        end = min(len(x) / sr, (act[-1] + 1) * 0.01 + KEEP_TAIL)
        dur = end - start
        fade = min(FADE, dur / 3)
        af = f"atrim=start={start:.3f}:end={end:.3f},asetpts=PTS-STARTPTS,afade=t=in:d=0.003,afade=t=out:st={dur - fade:.3f}:d={fade:.3f}:curve=cub"
        subprocess.run([FF, "-y", "-loglevel", "quiet", "-i", str(src), "-af", af, "-ac", "1", "-c:a", "libvorbis", "-q:a", "6", str(f)])
        print(f"{name}: {len(x)/sr:.2f}s -> {dur:.2f}s (cut front {start:.2f}, back {len(x)/sr - end:.2f})")


if __name__ == "__main__":
    main()
