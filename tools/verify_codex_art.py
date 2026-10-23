"""Is this picture really a Codex (GPT image) output? (main 10-20, after the user asked "코덱스가 그린 거 맞냐고")

Looks through build/codex_jobs/*/ for a job whose own generated image ($CODEX_HOME/generated_images/<session id>/*.png,
found from the job log) has the same bytes as the given file.

  py -I tools/verify_codex_art.py art/out/field_1020/facade_police_v4.png [more.png ...]

Prints CODEX <job> or NOT FOUND for each file. Exit 1 if any file is not found.
"""
import filecmp
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import codex_image  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JOBS = os.path.join(ROOT, "build", "codex_jobs")


def in_generated_images(path, size):
    """Fallback when a job log has no session id (e.g. codex timed out after saving): is this exact file anywhere
    in $CODEX_HOME/generated_images? Returns that file or None."""
    home = os.environ.get("CODEX_HOME") or os.path.join(os.path.expanduser("~"), ".codex")
    root = os.path.join(home, "generated_images")
    for dp, _, fn in os.walk(root):
        for f in fn:
            p = os.path.join(dp, f)
            if f.lower().endswith(".png") and os.path.getsize(p) == size and filecmp.cmp(p, path, shallow=False):
                return p
    return None


def find_job(path):
    size = os.path.getsize(path)
    for e in os.scandir(JOBS):
        if not e.is_dir():
            continue
        logs = sorted(f for f in os.listdir(e.path) if f.startswith("log_"))
        if not logs:
            continue
        log = open(os.path.join(e.path, logs[-1]), encoding="utf-8", errors="replace").read()
        own = codex_image.own_generated_image(log)
        if own and os.path.getsize(own) == size and filecmp.cmp(own, path, shallow=False):
            return e.name
    return None


def main():
    bad = 0
    for p in sys.argv[1:]:
        job = find_job(p)
        if job:
            print("CODEX %s  <- %s" % (job, p))
            continue
        gen = in_generated_images(p, os.path.getsize(p))
        if gen:
            print("CODEX (no job log, found in %s)  <- %s" % (os.path.relpath(gen, os.path.dirname(os.path.dirname(gen))), p))
            continue
        print("NOT FOUND (not a Codex output?)  %s" % p)
        bad += 1
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
