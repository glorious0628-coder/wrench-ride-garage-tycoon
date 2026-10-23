"""Make the upload files for the sounds the user picked (wr-sound).

art/sfx/picks.json  {"<out name>": {"from": "<key>_<n>", "trim": [start, end] | null}}
  -> art/sfx/<category>/<out name>.ogg  (same chain as sfx_process.py, cut to `trim` when given)
  -> art/sfx/picks.md (table for main's upload + wr-dev)
Run: py -I tools/sfx_finalize.py
"""

import json
import shutil
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sfx_process as sp  # noqa: E402

PICKS = sp.OUT / "picks.json"
OUTDIR = sp.OUT  # --picks <json> --outdir <dir> --md <md> to build a separate set (e.g. v2 for main's 2nd check)


def build(name: str, spec: dict, tmpdir: Path) -> dict:
    if "src" in spec:  # an already-made candidate file (compose output) used as the upload file
        spec = dict(spec, copy=spec["src"])
    if "copy" in spec:  # an already-made candidate (e.g. from sfx_compose.py): use it as is
        src = sp.OUT / spec["copy"]
        cat = src.parent.name
        dst = OUTDIR / cat / (name + ".ogg")
        dst.parent.mkdir(parents=True, exist_ok=True)
        if src.resolve() != dst.resolve():
            shutil.copyfile(src, dst)
        fin = sp.measure(dst)
        return {"name": name, "from": spec["copy"], "cat": cat, "loop": False, "trim": None,
                "dur": round(fin["dur"], 2), "tp": round(fin["tp"], 1),
                "lufs": None if fin["lufs"] is None else round(fin["lufs"], 1),
                "file": str(dst.relative_to(sp.ROOT)).replace("\\", "/"), "use": spec.get("use", ""),
                "volume": spec.get("volume", "")}
    src = sp.RAW / (spec["from"] + ".wav")
    key = spec["from"].rsplit("_", 1)[0]
    loop = key in sp.LOOPS
    cat = sp.CATEGORY.get(key, "misc")
    stage = tmpdir / (name + "_s1.wav")
    chain = ["highpass=f=70", "pan=mono|c0=0.5*c0+0.5*c1"]
    trim = spec.get("trim")
    if trim:
        chain.append(f"atrim={trim[0]}:{trim[1]}")
        chain.append("asetpts=PTS-STARTPTS")
    elif not loop:
        chain += [
            "silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.005:detection=peak",
            "areverse",
            "silenceremove=start_periods=1:start_threshold=-55dB:start_silence=0.02:detection=peak",
            "areverse",
        ]
    sp.run([sp.FFMPEG, "-hide_banner", "-y", "-i", str(src), "-af", ",".join(chain), "-c:a", "pcm_s16le", str(stage)])
    m1 = sp.measure(stage)
    target = sp.PEAK_LOOP if loop else sp.PEAK_ONESHOT
    gain = target - m1["tp"]
    chain2 = [f"volume={gain:.2f}dB"]
    if not loop:
        fade_out = min(spec.get("fade", 0.03), m1["dur"] / 3)
        chain2 += ["afade=t=in:d=0.003", f"afade=t=out:st={max(0.0, m1['dur'] - fade_out):.4f}:d={fade_out:.4f}:curve=cub"]
    dst = OUTDIR / cat / (name + ".ogg")
    dst.parent.mkdir(parents=True, exist_ok=True)
    sp.run([sp.FFMPEG, "-hide_banner", "-y", "-i", str(stage), "-af", ",".join(chain2), "-c:a", "libvorbis", "-q:a", "6", str(dst)])
    fin = sp.measure(dst)
    if fin["tp"] > -1.0 and not loop:
        chain2[0] = f"volume={gain + (-1.1 - fin['tp']):.2f}dB"
        sp.run([sp.FFMPEG, "-hide_banner", "-y", "-i", str(stage), "-af", ",".join(chain2), "-c:a", "libvorbis", "-q:a", "6", str(dst)])
        fin = sp.measure(dst)
    return {"name": name, "from": spec["from"], "cat": cat, "loop": loop, "trim": trim,
            "dur": round(fin["dur"], 2), "tp": round(fin["tp"], 1),
            "lufs": None if fin["lufs"] is None else round(fin["lufs"], 1),
            "file": str(dst.relative_to(sp.ROOT)).replace("\\", "/"), "use": spec.get("use", ""),
            "volume": spec.get("volume", "")}


def main():
    global OUTDIR
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--picks", default=str(PICKS))
    ap.add_argument("--outdir", default=str(sp.OUT))
    ap.add_argument("--md", default=str(sp.OUT / "picks.md"))
    a = ap.parse_args()
    OUTDIR = Path(a.outdir).resolve()
    picks = json.loads(Path(a.picks).read_text(encoding="utf-8"))
    rows = []
    with tempfile.TemporaryDirectory() as td:
        for name, spec in picks.items():
            r = build(name, spec, Path(td))
            rows.append(r)
            print(json.dumps(r, ensure_ascii=False))
    lines = [
        "# 고른 효과음 (업로드할 파일)",
        "",
        "사용자가 귀로 고른 것만. 메인 = Roblox **비공개 오디오** 업로드 → id를 아래 'id' 칸과 board에 → wr-dev가 `Shared/Sounds.luau`에 넣기.",
        "Volume = Roblox Sound.Volume 제안값(파일은 모두 피크 −1 dBTP로 맞춰져 있어서 크기는 Volume으로 맞춤).",
        "",
        "| 이름(Sounds 키) | 업로드 파일 | 원본 후보 | 길이 | loop | LUFS | Volume 제안 | 쓰는 자리 | id |",
        "|---|---|---|---|---|---|---|---|---|",
    ]
    ids_path = sp.OUT / "audio_ids.json"  # main writes the uploaded ids here
    ids = json.loads(ids_path.read_text(encoding="utf-8")) if ids_path.exists() else {}
    for r in rows:
        r["id"] = ids.get(r["name"], "")
        lines.append(f"| {r['name']} | {r['file']} | {r['from']}{' (자름 ' + str(r['trim'][0]) + '~' + str(r['trim'][1]) + 's)' if r['trim'] else ''} | {r['dur']} | {'O' if r['loop'] else 'X'} | {'-' if r['lufs'] is None else r['lufs']} | {r['volume']} | {r['use']} | {r['id']} |")
    Path(a.md).write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
