"""Sound pictures for wr-sound (Claude can't hear, so it looks): loudness line + log-frequency spectrogram.

py -I tools/sfx_spectro.py <out.png> <file.ogg|wav> [more files...]
Each file = one row: name, loudness (dB, top strip), spectrogram 50 Hz..16 kHz (log), time grid every 0.25 s.
"""

import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sfx_process as sp  # noqa: E402

SR = 32000
W, H_SPEC, H_ENV, PAD_L, PAD_T = 760, 150, 40, 70, 18
F_LO, F_HI = 50.0, 16000.0


def load(path: str) -> np.ndarray:
    r = subprocess.run([sp.FFMPEG, "-hide_banner", "-loglevel", "error", "-i", path, "-ac", "1", "-ar", str(SR),
                        "-f", "f32le", "-"], capture_output=True)
    return np.frombuffer(r.stdout, dtype=np.float32)


def colormap(v: np.ndarray) -> np.ndarray:
    # 0..1 -> dark blue / purple / orange / yellow-white
    stops = np.array([[0, 0, 8], [40, 10, 90], [150, 30, 110], [235, 100, 40], [255, 220, 90], [255, 255, 230]], float)
    pos = np.linspace(0, 1, len(stops))
    out = np.empty(v.shape + (3,))
    for c in range(3):
        out[..., c] = np.interp(v, pos, stops[:, c])
    return out.astype(np.uint8)


def row_image(path: str, max_dur: float) -> Image.Image:
    x = load(path)
    n_fft, hop = 2048, 160
    win = np.hanning(n_fft)
    pad = np.concatenate([np.zeros(n_fft // 2), x, np.zeros(n_fft)])
    frames = max(1, (len(pad) - n_fft) // hop)
    spec = np.empty((frames, n_fft // 2 + 1))
    for i in range(frames):
        seg = pad[i * hop:i * hop + n_fft] * win
        spec[i] = np.abs(np.fft.rfft(seg))
    db = 20 * np.log10(spec + 1e-9)
    db -= db.max()
    freqs = np.fft.rfftfreq(n_fft, 1 / SR)
    # log-frequency rows
    rows = np.geomspace(F_LO, F_HI, H_SPEC)[::-1]
    cols = int(W * (len(x) / SR) / max_dur)
    cols = max(1, min(W, cols))
    t_idx = np.linspace(0, frames - 1, cols).astype(int)
    img = np.zeros((H_SPEC, cols))
    for j, f in enumerate(rows):
        k = np.searchsorted(freqs, f)
        k0, k1 = max(0, k - 1), min(len(freqs) - 1, k + 1)
        img[j] = db[t_idx, k0:k1 + 1].max(axis=1)
    v = np.clip((img + 80) / 80, 0, 1)
    spec_rgb = colormap(v)
    # loudness strip (RMS per column, dB)
    step = max(1, len(x) // cols)
    rms = np.array([np.sqrt(np.mean(x[i * step:(i + 1) * step] ** 2) + 1e-12) for i in range(cols)])
    rdb = np.clip(20 * np.log10(rms), -60, 0)

    canvas = Image.new("RGB", (PAD_L + W + 10, PAD_T + H_ENV + H_SPEC + 22), (16, 16, 20))
    d = ImageDraw.Draw(canvas)
    d.text((4, 2), Path(path).stem, fill=(255, 255, 255))
    # envelope
    ey = PAD_T
    d.rectangle([PAD_L, ey, PAD_L + W, ey + H_ENV], fill=(28, 28, 34))
    pts = [(PAD_L + i, ey + H_ENV - (rdb[i] + 60) / 60 * H_ENV) for i in range(cols)]
    if len(pts) > 1:
        d.line(pts, fill=(120, 220, 140), width=1)
    d.text((4, ey + 2), "loud", fill=(150, 150, 150))
    # spectrogram
    sy = PAD_T + H_ENV
    canvas.paste(Image.fromarray(spec_rgb), (PAD_L, sy))
    for f, lab in [(100, "100"), (300, "300"), (1000, "1k"), (3000, "3k"), (8000, "8k")]:
        yy = sy + int((np.log(F_HI) - np.log(f)) / (np.log(F_HI) - np.log(F_LO)) * H_SPEC)
        d.line([(PAD_L - 4, yy), (PAD_L + W, yy)], fill=(70, 70, 80))
        d.text((PAD_L - 34, yy - 6), lab, fill=(200, 200, 200))
    t = 0.0
    while t <= max_dur + 1e-6:
        xx = PAD_L + int(t / max_dur * W)
        d.line([(xx, ey), (xx, sy + H_SPEC)], fill=(60, 60, 70) if t % 1 else (110, 110, 120))
        if abs(t * 2 - round(t * 2)) < 1e-6:
            d.text((xx - 8, sy + H_SPEC + 4), f"{t:.1f}s", fill=(200, 200, 200))
        t += 0.25
    return canvas


def main():
    out, files = sys.argv[1], sys.argv[2:]
    durs = [len(load(f)) / SR for f in files]
    max_dur = max(durs)
    rows = [row_image(f, max_dur) for f in files]
    sheet = Image.new("RGB", (rows[0].width, sum(r.height for r in rows)), (0, 0, 0))
    y = 0
    for r in rows:
        sheet.paste(r, (0, y))
        y += r.height
    sheet.save(out)
    print(out)


if __name__ == "__main__":
    main()
