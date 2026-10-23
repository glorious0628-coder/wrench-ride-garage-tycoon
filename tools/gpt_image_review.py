"""Ask GPT (Codex CLI, the user's ChatGPT plan) to review images: the images are attached to the prompt.

  py tools/gpt_image_review.py --prompt-file notes/gpt/review/<id>_q.md --image a.png [--image b.png ...] --out notes/gpt/review/<id>_a.md

Same as codex_chat.py (read-only, final message saved to --out) but with `codex exec -i` image attachments, so GPT
actually sees the pictures. Wrench & Ride main review (user 10-20: "너가 검수할 때, GPT 이용해서 같이 논의 하고 토론하면서 해줘
걔 말만 듣지 말구 너도 반박하면서") - ask, rebut with evidence, ask again; the conclusion is ours, not GPT's.
Exit codes: 0 ok, 2 codex missing / bad image, 3 usage limit, 4 no answer.
"""
import argparse
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from codex_image import CAPACITY_WORDS, LIMIT_WORDS, MODELS, ROOT, codex_exe  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt-file", required=True)
    ap.add_argument("--image", action="append", required=True, help="image(s) to attach")
    ap.add_argument("--out", required=True)
    ap.add_argument("--timeout", type=int, default=1200)
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")

    exe = codex_exe()
    if not exe:
        print("codex.exe not found", file=sys.stderr)
        return 2
    images = [os.path.abspath(p) for p in a.image]
    for p in images:
        if not os.path.exists(p):
            print("missing image: " + p, file=sys.stderr)
            return 2
    prompt = open(a.prompt_file, encoding="utf-8").read().strip()
    task = ("You are a strict art reviewer for a Roblox game. The attached images are what you review; you may also "
            "read files in this folder for rules (notes/handoff/README.md, docs/기획서.md section 8), but do NOT create, edit or delete "
            "any file. Answer in your final message only.\n\n" + prompt + "\n")
    last = ""
    for model in MODELS:
        answer_file = os.path.abspath(a.out) + ".tmp"
        cmd = [exe, "exec", "-m", model, "-C", ROOT, "-s", "read-only", "--skip-git-repo-check",
               "--output-last-message", answer_file]
        for p in images:
            cmd += ["-i", p]
        cmd.append("-")
        try:
            r = subprocess.run(cmd, input=task, capture_output=True, text=True, encoding="utf-8",
                               errors="replace", timeout=a.timeout)
        except subprocess.TimeoutExpired:
            last = "timeout"
            continue
        out = (r.stdout or "") + (r.stderr or "")
        low = out.lower()
        text = ""
        if os.path.exists(answer_file):
            text = open(answer_file, encoding="utf-8", errors="replace").read().strip()
            os.remove(answer_file)
        if not text:
            if any(w in low for w in LIMIT_WORDS):
                print("ChatGPT usage limit: " + out[-300:], file=sys.stderr)
                return 3
            if any(w in low for w in CAPACITY_WORDS):
                last = "capacity"
                continue
        if text:
            os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
            with open(a.out, "w", encoding="utf-8") as f:
                f.write(text + "\n")
            print("OK %s (model %s)" % (a.out, model))
            return 0
        last = out[-400:]
    print("no answer: %s" % last, file=sys.stderr)
    return 4


if __name__ == "__main__":
    sys.exit(main())
