"""Make a 4 s AI loop seamless: crossfade its last X s into its head (wr-sound). Peak -3.3 dB, mono 48 kHz ogg.
Run: tools/audio_ai/.venv/Scripts/python.exe tools/sfx_xloop.py <in.ogg> <out.ogg> [xfade_s=0.3]
"""
# crossfade a loop's tail into its head so the seam is continuous: xloop.py in.ogg out.ogg [xfade_s]
import sys, subprocess, numpy as np, wave
src, dst = sys.argv[1], sys.argv[2]; xf = float(sys.argv[3]) if len(sys.argv) > 3 else 0.3
raw = subprocess.run(['ffmpeg','-v','quiet','-i',src,'-f','s16le','-ac','1','-ar','48000','-'],capture_output=True).stdout
x = np.frombuffer(raw, dtype=np.int16).astype(float) / 32768; n = int(48000 * xf)
t = np.linspace(0, np.pi / 2, n); y = x[n:].copy()
y[-n:] = x[-n:] * np.cos(t) + x[:n] * np.sin(t)
y *= 10 ** ((-3.3 - 20 * np.log10(np.abs(y).max())) / 20)
tmp = dst + '.wav'
with wave.open(tmp, 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(48000); w.writeframes((y * 32767).astype(np.int16).tobytes())
subprocess.run(['ffmpeg','-v','quiet','-y','-i',tmp,'-c:a','libvorbis','-q:a','6',dst]); import os; os.remove(tmp)
print(dst, f"{len(y)/48000:.2f}s", 'edge jump', round(abs(y[0]-y[-1]), 4))
