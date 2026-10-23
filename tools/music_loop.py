"""Cut a seamless game loop out of an ElevenLabs Music track (wr-sound, docs/design/music_list.md §2).

art/music/raw/<key>_<n>.wav (2-min song with intro/outro)  ->  art/music/<key>_<n>.ogg (stereo, -16 LUFS, <= -1 dBTP)
  1. beats + tempo (librosa), downbeats = the beat phase with the strongest low-end (kick/bass) onsets
  2. every (start downbeat, N bars) inside the song body (skip intro/outro) whose length is in [--min, --max] s
     -> pick the pair whose music right after the END sounds most like the music right after the START
        (log-mel + chroma cosine over 2 s, same loudness) = the jump back is a bar of the same groove
  3. the loop's first --xfade s = equal-power crossfade from the song's own continuation after END into START,
     so the last sample flows into the first (no click, no hole)
  4. level to --lufs (true peak kept <= -1 dBTP), Vorbis q5 stereo; then decode the .ogg with ffmpeg and check
     the seam: sample jump, level change, spectral flux at the seam vs. the loop's own flux (percentile)
Jingle mode (--jingle S): keep the first S seconds from the first onset, cut on a beat, 0.4 s fade-out, -14 LUFS.
Run: tools/audio_ai/.venv/Scripts/python.exe tools/music_loop.py <key>_<n> [--bpb 4] [--min 56 --max 84] [--jingle 4]
"""
import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

import librosa
import numpy as np
import soundfile as sf

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sfx_process as sp  # noqa: E402  (ffmpeg path + measure)

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "art" / "music" / "raw"
OUT = ROOT / "art" / "music"
SR_A = 22050  # analysis rate


def feats(y, sr):
    mel = librosa.power_to_db(librosa.feature.melspectrogram(y=y, sr=sr, n_mels=64, hop_length=512))
    chroma = librosa.feature.chroma_stft(y=y, sr=sr, hop_length=512)
    rms = librosa.feature.rms(y=y, hop_length=512)[0]
    return mel, chroma, rms


def window_sim(mel, chroma, rms, f0, f1, n):
    a, b = slice(f0, f0 + n), slice(f1, f1 + n)
    if f0 + n > mel.shape[1] or f1 + n > mel.shape[1]:
        return -9.0

    def cos(u, v):
        return float(np.dot(u, v) / (np.linalg.norm(u) * np.linalg.norm(v) + 1e-9))

    m = cos(mel[:, a].mean(1) - mel.mean(), mel[:, b].mean(1) - mel.mean())
    c = cos(chroma[:, a].mean(1), chroma[:, b].mean(1))
    lv = abs(20 * np.log10(rms[a].mean() + 1e-9) - 20 * np.log10(rms[b].mean() + 1e-9))
    return m + c - 0.1 * lv


def level(x, sr, lufs_target, tmpdir):
    t = Path(tmpdir) / "lvl.wav"
    sf.write(t, x, sr, subtype="PCM_24")
    m = sp.measure(t)
    gain = min(lufs_target - m["lufs"], -1.2 - m["tp"])
    return x * 10 ** (gain / 20), gain, m


def encode(x, sr, dst, tmpdir):
    t = Path(tmpdir) / "enc.wav"
    sf.write(t, x, sr, subtype="PCM_24")
    sp.run([sp.FFMPEG, "-hide_banner", "-y", "-i", str(t), "-c:a", "libvorbis", "-q:a", "5", str(dst)])


def decode(path):
    r = subprocess.run([sp.FFMPEG, "-v", "quiet", "-i", str(path), "-f", "f32le", "-ac", "2", "-ar", "48000", "-"],
                       capture_output=True)
    return np.frombuffer(r.stdout, dtype=np.float32).reshape(-1, 2)


def seam_check(y, bar_s, sr=48000):
    """decoded loop (as the game will play it) -> how much the jump end->start stands out.
    The seam sits on a downbeat, where the music has an onset anyway, so its spectral flux is compared with the
    flux at the loop's own bar starts (flux_vs_bars = percentile; <= ~80 = it does not stand out) and the level
    of the 0.5 s before/after the seam with the same 0.5 s around those bar starts (level_db = seam step,
    level_bars = typical step at a bar start)."""
    jump = float(np.abs(y[-1] - y[0]).max())
    mono = y.mean(1)
    wrapped = np.concatenate([mono, mono[: sr * 2]])  # play it twice: the seam is at len(y)
    S = np.abs(librosa.stft(wrapped, n_fft=2048, hop_length=512))
    flux = np.maximum(0, np.diff(np.log1p(S), axis=1)).sum(0)
    db = lambda s: 20 * np.log10(np.sqrt(np.mean(s ** 2)) + 1e-9)  # noqa: E731
    h = int(0.5 * sr)

    def at(t):
        f = int(t * sr / 512) - 1
        i = int(t * sr)
        return flux[max(0, f - 2): f + 3].max(), db(wrapped[i: i + h]) - db(wrapped[i - h: i])

    seam_f, seam_l = at(len(y) / sr)
    bars = [at(k * bar_s) for k in range(1, int(len(y) / sr / bar_s))]
    bf = np.array([b[0] for b in bars])
    bl = np.array([abs(b[1]) for b in bars])
    return {"jump": round(jump, 4), "level_db": round(float(seam_l), 2), "level_bars": round(float(np.median(bl)), 2),
            "flux_vs_bars": round(float((bf < seam_f).mean() * 100), 1)}


def make_loop(name, a):
    x, sr = sf.read(RAW / f"{name}.wav", always_2d=True)
    mono = librosa.resample(x.mean(1), orig_sr=sr, target_sr=SR_A)
    dur = len(mono) / SR_A
    tempo, beats = librosa.beat.beat_track(y=mono, sr=SR_A, hop_length=512, units="frames")
    bt = librosa.frames_to_time(beats, sr=SR_A, hop_length=512)
    low = librosa.onset.onset_strength(y=mono, sr=SR_A, hop_length=512, fmax=200, n_mels=32)
    phase = max(range(a.bpb), key=lambda p: low[beats[p:: a.bpb]].mean())
    down = bt[phase:: a.bpb]
    mel, chroma, rms = feats(mono, SR_A)
    n2 = int(2.0 * SR_A / 512)
    best = None
    for i, s in enumerate(down):
        if s < a.skip_in or s > a.skip_in + 24:
            continue
        for j in range(i + 4, len(down)):
            e = down[j]
            L = e - s
            if L > a.max or e > dur - a.skip_out:
                break
            if L < a.min or (j - i) % a.bar_mult:
                continue
            bars = j - i
            f_s, f_e = int(s * SR_A / 512), int(e * SR_A / 512)
            score = window_sim(mel, chroma, rms, f_s, f_e, n2) + window_sim(mel, chroma, rms, f_s - n2, f_e - n2, n2)
            score += 0.15 if bars % 8 == 0 else (0.08 if bars % 4 == 0 else 0)
            if best is None or score > best[0]:
                best = (score, s, e, bars)
    if best is None:
        sys.exit(f"{name}: no loop window (dur {dur:.1f}s, tempo {float(np.atleast_1d(tempo)[0]):.0f})")
    score, s, e, bars = best
    i0, i1 = int(round(s * sr)), int(round(e * sr))
    # beat tracking is only good to ~20 ms: slide END so its hits line up with START's (no flam in the crossfade)
    env = np.sqrt(librosa.util.frame(x.mean(1), frame_length=48, hop_length=48).astype(np.float64) ** 2).mean(0)
    k0, k1, w = i0 // 48, i1 // 48, int(1.5 * sr) // 48
    ref = env[k0: k0 + w] - env[k0: k0 + w].mean()
    lags = range(-40, 41)  # 1 ms steps
    corr = [float(np.dot(ref, env[k1 + d: k1 + d + w] - env[k1 + d: k1 + d + w].mean())) for d in lags]
    shift = lags[int(np.argmax(corr))]
    i1 += shift * 48
    e = i1 / sr
    n = int(a.xfade * sr)
    loop = x[i0:i1].copy()
    t = np.linspace(0, np.pi / 2, n)[:, None]
    loop[:n] = x[i1: i1 + n] * np.cos(t) + x[i0: i0 + n] * np.sin(t)
    with tempfile.TemporaryDirectory() as td:
        loop, gain, _ = level(loop, sr, a.lufs, td)
        dst = OUT / f"{name}.ogg"
        encode(loop, sr, dst, td)
        fin = sp.measure(dst)
    y = decode(dst)
    seam = seam_check(y, (e - s) / bars)
    chk = OUT / "_check"
    chk.mkdir(exist_ok=True)
    sf.write(chk / f"{name}_seam.wav", np.concatenate([y[-3 * 48000:], y[: 3 * 48000]]), 48000)  # seam at 3.0 s
    return {"name": name, "file": str(dst.relative_to(ROOT)).replace("\\", "/"), "shift_ms": shift,
            "bpm": round(float(np.atleast_1d(tempo)[0]), 1), "bpb": a.bpb, "start": round(float(s), 2),
            "end": round(float(e), 2), "bars": bars, "len": round(float(e - s), 2), "match": round(float(score), 3),
            "lufs": fin["lufs"], "tp": fin["tp"], "seam": seam, "song_dur": round(dur, 1)}


def make_jingle(name, a):
    x, sr = sf.read(RAW / f"{name}.wav", always_2d=True)
    mono = librosa.resample(x.mean(1), orig_sr=sr, target_sr=SR_A)
    on = librosa.onset.onset_detect(y=mono, sr=SR_A, hop_length=512, units="time")
    t0 = max(0.0, float(on[0]) - 0.02) if len(on) else 0.0
    tempo, beats = librosa.beat.beat_track(y=mono, sr=SR_A, hop_length=512, units="time")
    cut = [b for b in beats if t0 + a.jingle - 1.0 <= b <= t0 + a.jingle]
    t1 = float(cut[-1]) if cut else t0 + a.jingle
    i0, i1 = int(t0 * sr), int(t1 * sr)
    y = x[i0:i1].copy()
    n = int(0.4 * sr)
    y[-n:] *= np.cos(np.linspace(0, np.pi / 2, n))[:, None]
    m = int(0.005 * sr)
    y[:m] *= np.linspace(0, 1, m)[:, None]
    with tempfile.TemporaryDirectory() as td:
        y, gain, _ = level(y, sr, a.lufs if a.lufs != -16.0 else -14.0, td)
        dst = OUT / f"{name}.ogg"
        encode(y, sr, dst, td)
        fin = sp.measure(dst)
    return {"name": name, "file": str(dst.relative_to(ROOT)).replace("\\", "/"), "start": round(t0, 2),
            "end": round(t1, 2), "len": round(t1 - t0, 2), "bpm": round(float(np.atleast_1d(tempo)[0]), 1),
            "lufs": fin["lufs"], "tp": fin["tp"]}


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    ap = argparse.ArgumentParser()
    ap.add_argument("names", nargs="+")
    ap.add_argument("--bpb", type=int, default=4, help="beats per bar (3 = waltz)")
    ap.add_argument("--min", type=float, default=56)
    ap.add_argument("--max", type=float, default=84)
    ap.add_argument("--skip-in", dest="skip_in", type=float, default=6)
    ap.add_argument("--skip-out", dest="skip_out", type=float, default=8)
    ap.add_argument("--xfade", type=float, default=0.4)
    ap.add_argument("--bar-mult", dest="bar_mult", type=int, default=4, help="loop = a multiple of this many bars (phrase)")
    ap.add_argument("--lufs", type=float, default=-16.0)
    ap.add_argument("--jingle", type=float, default=0)
    a = ap.parse_args()
    log = OUT / "loops.json"
    old = json.loads(log.read_text(encoding="utf-8")) if log.exists() else {}
    for name in a.names:
        r = make_jingle(name, a) if a.jingle else make_loop(name, a)
        old[name] = r
        print(json.dumps(r, ensure_ascii=False))
    log.write_text(json.dumps(old, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
