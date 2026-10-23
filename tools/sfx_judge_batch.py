"""Run the sound judge (same models and score as tools/sound_judge.py) over many sounds at once, loading the models once.

art/sfx/_judge/<round>.json  {"<key>": {"want": "...", "avoid": [...], "expect": [...], "files": ["<cat>/<file>.ogg", ...]}, ...}
  -> art/sfx/_judge/<round>_result.json + a short table on stdout
Run: tools/audio_ai/.venv/Scripts/python.exe tools/sfx_judge_batch.py art/sfx/_judge/<round>.json
"""
import json
import os
import sys
from pathlib import Path

os.environ.setdefault("HF_HUB_DISABLE_IMPLICIT_TOKEN", "1")
os.environ.setdefault("HF_HUB_DISABLE_TELEMETRY", "1")

ROOT = Path(__file__).resolve().parent.parent
SFX = ROOT / "art" / "sfx"
AST_ID = "MIT/ast-finetuned-audioset-10-10-0.4593"
CLAP_ID = "laion/clap-htsat-unfused"


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    spec_path = Path(sys.argv[1])
    specs = json.loads(spec_path.read_text(encoding="utf-8"))
    for s in specs.values():
        if any("pizzadoggy" in f.lower() for f in s["files"]):
            sys.exit("Pizza Doggy audio must not go into AI (license)")

    import librosa
    import torch
    from transformers import ASTFeatureExtractor, ASTForAudioClassification, ClapModel, ClapProcessor

    ast_fe = ASTFeatureExtractor.from_pretrained(AST_ID)
    ast = ASTForAudioClassification.from_pretrained(AST_ID).eval()
    clap_p = ClapProcessor.from_pretrained(CLAP_ID)
    clap = ClapModel.from_pretrained(CLAP_ID).eval()

    out = {}
    for key, s in specs.items():
        texts = [s["want"]] + s.get("avoid", [])

        def clap_logits(y48):
            # same as sound_judge.py: one forward pass with texts + clip (logits_per_audio is stable across versions)
            try:
                inp = clap_p(text=texts, audio=[y48], sampling_rate=48000, return_tensors="pt", padding=True)
            except TypeError:
                inp = clap_p(text=texts, audios=[y48], sampling_rate=48000, return_tensors="pt", padding=True)
            return clap(**inp).logits_per_audio[0]

        rows = []
        for rel in s["files"]:
            f = SFX / rel
            y16, _ = librosa.load(str(f), sr=16000, mono=True)
            y48, _ = librosa.load(str(f), sr=48000, mono=True)
            with torch.no_grad():
                probs = torch.sigmoid(ast(**ast_fe(y16, sampling_rate=16000, return_tensors="pt")).logits[0])
                top = torch.topk(probs, 5)
                labels = [(ast.config.id2label[int(i)], round(float(p), 3)) for p, i in zip(top.values, top.indices)]
                share = torch.softmax(clap_logits(y48), dim=0)
            score = float(share[0])
            worst = max(range(1, len(texts)), key=lambda k: float(share[k])) if len(texts) > 1 else None
            expect_ok = all(any(e.lower() in n.lower() for n, _ in labels) for e in s.get("expect", [])) if s.get("expect") else True
            rows.append({"file": rel, "seconds": round(len(y16) / 16000, 2), "score_want": round(score, 3),
                         "pass": score >= s.get("min", 0.5) and expect_ok,
                         "closest_avoid": (texts[worst], round(float(share[worst]), 3)) if worst else None,
                         "audioset_top5": labels})
        rows.sort(key=lambda r: -r["score_want"])
        out[key] = {"want": s["want"], "avoid": s.get("avoid", []), "rows": rows}
        print(f"== {key}")
        for r in rows:
            av = f"~{r['closest_avoid'][0][:28]} {r['closest_avoid'][1]}" if r["closest_avoid"] else ""
            hears = ", ".join(f"{n} {p}" for n, p in r["audioset_top5"][:3])
            print(f"  {'PASS' if r['pass'] else 'drop'} {r['score_want']:.3f} {Path(r['file']).stem:16s} {r['seconds']:.2f}s {av} | {hears}")
    res = spec_path.with_name(spec_path.stem + "_result.json")
    res.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
