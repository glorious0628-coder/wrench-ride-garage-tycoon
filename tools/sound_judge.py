"""Let an open-source audio AI "listen" to our generated sound candidates before the user does (user 10-21: "너가 듣고 좋은
걸로 판단하고, 프롬프트도 수정할 수 있으면 좋겠어"). Two models, both run on the CPU:
  - AST (MIT/ast-finetuned-audioset-10-10-0.4593, BSD-3): which of the 527 AudioSet sound names it hears (top 5).
  - CLAP (laion/clap-htsat-unfused): how close the sound is to what we want vs. what we must avoid (text <-> audio).

  tools/audio_ai/.venv/Scripts/python.exe tools/sound_judge.py --want "a healthy car engine starts smoothly and idles"
        --avoid "a broken engine sputtering" --avoid "fingernails on a chalkboard" [--expect "Engine starting"] [--json out.json]
        art/sfx/raw/engineStart_*.mp3

Score = CLAP chance of 'want' among want + avoid (0..1). Pass = score >= --min (0.5) and, with --expect, that AudioSet name
in the top 5. Only for sounds WE made (ElevenLabs / our edits) - never Pizza Doggy files (their license forbids AI input).
The AI does not replace the user's ears: it only filters, the user still picks.
"""
import argparse
import glob
import json
import os
import sys

os.environ.setdefault("HF_HUB_DISABLE_IMPLICIT_TOKEN", "1")  # public models only, never send a saved token
os.environ.setdefault("HF_HUB_DISABLE_TELEMETRY", "1")

AST_ID = "MIT/ast-finetuned-audioset-10-10-0.4593"
CLAP_ID = "laion/clap-htsat-unfused"


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+")
    ap.add_argument("--want", required=True, help="what the sound should be (English)")
    ap.add_argument("--avoid", action="append", default=[], help="what it must not sound like (repeat)")
    ap.add_argument("--expect", action="append", default=[], help="AudioSet name that should be in the top 5 (repeat)")
    ap.add_argument("--min", type=float, default=0.5)
    ap.add_argument("--json")
    a = ap.parse_args()
    files = []
    for f in a.files:
        files += sorted(glob.glob(f)) or [f]
    if any("pizzadoggy" in f.lower() for f in files):
        sys.exit("Pizza Doggy audio must not go into AI (license)")

    import librosa
    import numpy as np
    import torch
    from transformers import ASTFeatureExtractor, ASTForAudioClassification, ClapModel, ClapProcessor

    ast_fe = ASTFeatureExtractor.from_pretrained(AST_ID)
    ast = ASTForAudioClassification.from_pretrained(AST_ID).eval()
    clap_p = ClapProcessor.from_pretrained(CLAP_ID)
    clap = ClapModel.from_pretrained(CLAP_ID).eval()
    texts = [a.want] + a.avoid

    def clap_logits(y48):
        # one forward pass with the texts and the clip: logits_per_audio is stable across transformers versions
        try:
            inp = clap_p(text=texts, audio=[y48], sampling_rate=48000, return_tensors="pt", padding=True)
        except TypeError:
            inp = clap_p(text=texts, audios=[y48], sampling_rate=48000, return_tensors="pt", padding=True)
        return clap(**inp).logits_per_audio[0]

    rows = []
    for f in files:
        y16, _ = librosa.load(f, sr=16000, mono=True)
        y48, _ = librosa.load(f, sr=48000, mono=True)
        dur = len(y16) / 16000
        with torch.no_grad():
            logits = ast(**ast_fe(y16, sampling_rate=16000, return_tensors="pt")).logits[0]
            probs = torch.sigmoid(logits)
            top = torch.topk(probs, 5)
            labels = [(ast.config.id2label[int(i)], round(float(p), 3)) for p, i in zip(top.values, top.indices)]
            share = torch.softmax(clap_logits(y48), dim=0)
        score = float(share[0])
        worst = max(range(1, len(texts)), key=lambda k: float(share[k])) if len(texts) > 1 else None
        expect_ok = all(any(e.lower() in n.lower() for n, _ in labels) for e in a.expect) if a.expect else True
        ok = score >= a.min and expect_ok
        rows.append({"file": f, "seconds": round(dur, 2), "score_want": round(score, 3), "pass": ok,
                     "closest_avoid": (texts[worst], round(float(share[worst]), 3)) if worst else None,
                     "audioset_top5": labels, "peak": round(float(np.max(np.abs(y16))) if len(y16) else 0.0, 3)})
    rows.sort(key=lambda r: -r["score_want"])
    for r in rows:
        avoid = f"  ~avoid '{r['closest_avoid'][0]}' {r['closest_avoid'][1]}" if r["closest_avoid"] else ""
        print(f"{'PASS' if r['pass'] else 'drop'}  want {r['score_want']:.3f}  {r['seconds']:5.2f}s  {os.path.basename(r['file'])}{avoid}")
        print("        hears: " + ", ".join(f"{n} {p}" for n, p in r["audioset_top5"]))
    if a.json:
        with open(a.json, "w", encoding="utf-8") as fh:
            json.dump({"want": a.want, "avoid": a.avoid, "expect": a.expect, "results": rows}, fh, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    main()
