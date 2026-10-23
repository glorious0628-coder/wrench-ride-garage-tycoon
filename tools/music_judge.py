"""Let the audio AI 'listen' to whole music loops (wr-sound, docs/design/music_list.md §2) — same two models as
tools/sound_judge.py, but a song is longer than the models' 10 s window, so each file is cut into 10 s windows spread
over the whole loop and the answers are averaged.
  - AST: average AudioSet chances -> top 5 + the names we care about (voices = must be ~0, genre, mood)
  - CLAP: share of 'want' among want + avoid, averaged over the windows
art/music/_judge/<round>.json  {"<key>": {"want": "...", "avoid": [...], "files": ["<file>.ogg", ...]}, ...}
  -> <round>_result.json + table on stdout
Run: tools/audio_ai/.venv/Scripts/python.exe tools/music_judge.py art/music/_judge/<round>.json
Only music WE made (ElevenLabs) - never Pizza Doggy files (license: no AI input).
"""
import json
import os
import sys
from pathlib import Path

os.environ.setdefault("HF_HUB_DISABLE_IMPLICIT_TOKEN", "1")
os.environ.setdefault("HF_HUB_DISABLE_TELEMETRY", "1")

ROOT = Path(__file__).resolve().parent.parent
MUSIC = ROOT / "art" / "music"
AST_ID = "MIT/ast-finetuned-audioset-10-10-0.4593"
CLAP_ID = "laion/clap-htsat-unfused"
WATCH = ["Singing", "Speech", "Vocal music", "Choir", "Humming", "Rapping",
         "Happy music", "Tender music", "Exciting music", "Sad music", "Scary music", "Angry music",
         "Funk", "Soul music", "Rhythm and blues", "Jazz", "Pop music", "Rock music", "Electronic music",
         "Classical music", "Music for children", "Lullaby", "Background music", "Video game music",
         "Bell", "Church bell", "Jingle bell", "Vehicle horn, car horn, honking", "Glockenspiel", "Harp"]


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    spec_path = Path(sys.argv[1])
    specs = json.loads(spec_path.read_text(encoding="utf-8"))
    if any("pizzadoggy" in f.lower() for s in specs.values() for f in s["files"]):
        sys.exit("Pizza Doggy audio must not go into AI (license)")

    import librosa
    import numpy as np
    import torch
    from transformers import ASTFeatureExtractor, ASTForAudioClassification, ClapModel, ClapProcessor

    ast_fe = ASTFeatureExtractor.from_pretrained(AST_ID)
    ast = ASTForAudioClassification.from_pretrained(AST_ID).eval()
    clap_p = ClapProcessor.from_pretrained(CLAP_ID)
    clap = ClapModel.from_pretrained(CLAP_ID).eval()
    names = ast.config.id2label
    watch = {n: i for i, n in names.items() if n in WATCH}

    out = {}
    for key, s in specs.items():
        texts = [s["want"]] + s.get("avoid", [])
        rows = []
        for rel in s["files"]:
            f = MUSIC / rel
            y16, _ = librosa.load(str(f), sr=16000, mono=True)
            y48, _ = librosa.load(str(f), sr=48000, mono=True)
            dur = len(y16) / 16000
            n = max(1, min(6, int(dur // 10)))
            starts = np.linspace(0, max(0.0, dur - 10), n)
            probs, shares = [], []
            for t in starts:
                a16 = y16[int(t * 16000): int((t + 10) * 16000)]
                a48 = y48[int(t * 48000): int((t + 10) * 48000)]
                with torch.no_grad():
                    probs.append(torch.sigmoid(ast(**ast_fe(a16, sampling_rate=16000, return_tensors="pt")).logits[0]))
                    try:
                        inp = clap_p(text=texts, audio=[a48], sampling_rate=48000, return_tensors="pt", padding=True)
                    except TypeError:
                        inp = clap_p(text=texts, audios=[a48], sampling_rate=48000, return_tensors="pt", padding=True)
                    shares.append(torch.softmax(clap(**inp).logits_per_audio[0], dim=0))
            p = torch.stack(probs).mean(0)
            sh = torch.stack(shares).mean(0)
            top = torch.topk(p, 5)
            worst = max(range(1, len(texts)), key=lambda k: float(sh[k])) if len(texts) > 1 else None
            voice = max(float(p[watch[v]]) for v in ("Singing", "Speech", "Vocal music", "Choir", "Humming", "Rapping")
                        if v in watch)
            rows.append({"file": rel, "seconds": round(dur, 1), "windows": n, "score_want": round(float(sh[0]), 3),
                         "closest_avoid": (texts[worst], round(float(sh[worst]), 3)) if worst else None,
                         "voice_max": round(voice, 3),
                         "top5": [(names[int(i)], round(float(v), 3)) for v, i in zip(top.values, top.indices)],
                         "watch": {k: round(float(p[i]), 3) for k, i in watch.items() if float(p[i]) >= 0.02}})
        rows.sort(key=lambda r: -r["score_want"])
        out[key] = {"want": s["want"], "avoid": s.get("avoid", []), "rows": rows}
        print(f"== {key}")
        for r in rows:
            av = f"~{r['closest_avoid'][0][:30]} {r['closest_avoid'][1]}" if r["closest_avoid"] else ""
            print(f"  {r['score_want']:.3f} {Path(r['file']).stem:18s} {r['seconds']}s voice {r['voice_max']} {av}")
            print("        top: " + ", ".join(f"{n} {v}" for n, v in r["top5"]))
            print("        watch: " + ", ".join(f"{n} {v}" for n, v in sorted(r["watch"].items(), key=lambda kv: -kv[1])))
    res = spec_path.with_name(spec_path.stem + "_result.json")
    res.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
