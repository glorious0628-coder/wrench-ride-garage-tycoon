"""Cut and join processed SFX into new candidates (wr-sound) — e.g. close a silent gap, keep only the first crack,
put a wrench 'tick' before a bolt 'crack'.

art/sfx/compose.json  {"<cat>/<name>.ogg": [{"src": "<cat>/<file>.ogg", "start": s, "end": e|null, "at": t,
                                               "gain": dB, "fade_in": s, "fade_out": s, "filter": "<ffmpeg af>"}, ...], ...}
Parts are cut from the (already levelled, mono) candidates, placed at `at` seconds, mixed, then levelled to -1 dBTP.
Run: py -I tools/sfx_compose.py [name ...]
"""

import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sfx_process as sp  # noqa: E402

RECIPES = sp.OUT / "compose.json"


def build(out_rel: str, parts: list, tmpdir: Path) -> dict:
    args, chains, labels = [], [], []
    for i, p in enumerate(parts):
        args += ["-i", str(sp.OUT / p["src"])]
        trim = f"atrim=start={p.get('start', 0)}" + (f":end={p['end']}" if p.get("end") is not None else "")
        c = [trim, "asetpts=PTS-STARTPTS"]
        if p.get("fade_in"):
            c.append(f"afade=t=in:d={p['fade_in']}")
        if p.get("fade_out"):
            # "curve": "cub" = cubic fade (a linear fade still leaves -20 dB in the last 5 ms; the AI-look check wants < -60 dB)
            cv = f":curve={p['curve']}" if p.get("curve") else ""
            c.append(f"areverse,afade=t=in:d={p['fade_out']}{cv},areverse")
        if p.get("filter"):  # any ffmpeg audio filter, e.g. "lowpass=f=1200"
            c.append(p["filter"])
        if p.get("gain"):
            c.append(f"volume={p['gain']}dB")
        ms = int(round(p.get("at", 0) * 1000))
        if ms:
            c.append(f"adelay={ms}")
        chains.append(f"[{i}:a]" + ",".join(c) + f"[p{i}]")
        labels.append(f"[p{i}]")
    graph = ";".join(chains) + ";" + "".join(labels) + f"amix=inputs={len(parts)}:normalize=0:duration=longest[m]"
    stage = tmpdir / "stage.wav"
    sp.run([sp.FFMPEG, "-hide_banner", "-y", *args, "-filter_complex", graph, "-map", "[m]", "-ac", "1",
            "-c:a", "pcm_s16le", str(stage)])
    m1 = sp.measure(stage)
    gain = sp.PEAK_ONESHOT - m1["tp"]
    dst = sp.OUT / out_rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    sp.run([sp.FFMPEG, "-hide_banner", "-y", "-i", str(stage), "-af", f"volume={gain:.2f}dB", "-c:a", "libvorbis",
            "-q:a", "6", str(dst)])
    fin = sp.measure(dst)
    if fin["tp"] > -1.0:
        sp.run([sp.FFMPEG, "-hide_banner", "-y", "-i", str(stage), "-af", f"volume={gain + (-1.1 - fin['tp']):.2f}dB",
                "-c:a", "libvorbis", "-q:a", "6", str(dst)])
        fin = sp.measure(dst)
    return {"file": out_rel, "dur": round(fin["dur"], 2), "tp": round(fin["tp"], 1)}


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    recipes = json.loads(RECIPES.read_text(encoding="utf-8"))
    only = set(sys.argv[1:])
    with tempfile.TemporaryDirectory() as td:
        for out_rel, parts in recipes.items():
            if only and Path(out_rel).stem not in only:
                continue
            print(json.dumps(build(out_rel, parts, Path(td)), ensure_ascii=False))


if __name__ == "__main__":
    main()
