"""Ask GPT (through the Codex app's CLI, the user's ChatGPT plan) a design question and save its answer.

  py tools/codex_chat.py --prompt-file notes/gpt/<topic>_q.md --out notes/gpt/<topic>_a.md

Runs `codex exec` read-only in the project folder, so GPT can read the code and docs for context but can't change
anything. The answer (its final message) is written to --out. Exit codes: 0 ok, 2 codex missing, 3 usage limit,
4 no answer.
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
    ap.add_argument("--out", required=True)
    ap.add_argument("--timeout", type=int, default=1200)
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")

    exe = codex_exe()
    if not exe:
        print("codex.exe not found (install the Codex app and log in with ChatGPT)", file=sys.stderr)
        return 2
    prompt = open(a.prompt_file, encoding="utf-8").read().strip()
    task = ("You are a game-design partner. Read whatever files in this folder help (start with README.md and "
            "src/ReplicatedStorage/Shared), but do NOT create, edit or delete any file and do not run builds. "
            "Answer in your final message only.\n\n" + prompt + "\n")
    last = ""
    for model in MODELS:
        answer_file = os.path.abspath(a.out) + ".tmp"
        cmd = [exe, "exec", "-m", model, "-C", ROOT, "-s", "read-only", "--skip-git-repo-check",
               "--output-last-message", answer_file, "-"]
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
        # (an answer wins: the run's output also carries the files GPT read, and words like "rate limit" or
        # "try again later" in our own code used to look like a usage limit — 10-19, with 97% of the plan left)
        if not text:
            if any(w in low for w in LIMIT_WORDS):
                print("ChatGPT usage limit reached (or a limit word in the output): " + out[-300:], file=sys.stderr)
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
