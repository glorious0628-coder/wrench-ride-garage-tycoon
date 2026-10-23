"""Main-session wake-up: exit as soon as a sub-session ends its turn or notes/handoff/board.md changes.

  py -I tools/session_watch.py --self <my session uuid> [--every 8]     (run with run_in_background)

Why (user 10-23: "메시지 수신하면 바로 바로 확인"): the desktop app wakes the main session for a sub-session's
report only when ALL linked sessions are idle, and notify_when_idle does not work for desktop sessions. So with
several sessions working, a finished report can sit unread. This watcher reads the sub-sessions' transcripts
(~/.claude/projects/<project>/*.jsonl): a turn has ended when the last user/assistant entry is an assistant
message with stop_reason end_turn. Its exit re-invokes the main session; re-arm it after every wake-up.
"""
import argparse
import glob
import json
import os
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJ = os.path.expanduser("~/.claude/projects/C--Users-glori-Documents-Roblox-Wrench---Ride-Garage-Tycoon")
BOARD = os.path.join(ROOT, "notes", "handoff", "board.md")
TAIL = 400_000


def state(path):
    """(ended, title, uuid of the last user/assistant entry) from the end of one transcript."""
    size = os.path.getsize(path)
    with open(path, "rb") as f:
        f.seek(max(0, size - TAIL))
        lines = f.read().decode("utf-8", "replace").splitlines()
    ended, title, last = None, None, None
    for line in reversed(lines):
        try:
            d = json.loads(line)
        except ValueError:
            continue
        t = d.get("type")
        if title is None and t == "custom-title":
            title = d.get("customTitle")
        if ended is None and t in ("user", "assistant"):
            m = d.get("message") or {}
            ended = t == "assistant" and isinstance(m, dict) and m.get("stop_reason") == "end_turn"
            last = d.get("uuid")
        if ended is not None and title is not None:
            break
    return bool(ended), title or os.path.basename(path)[:8], last


def scan(me, since):
    out = {}
    for p in glob.glob(os.path.join(PROJ, "*.jsonl")):
        if os.path.basename(p).startswith(me) or os.path.getmtime(p) < since:
            continue
        try:
            out[p] = state(p)
        except OSError:
            pass
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--self", required=True, help="this main session's transcript uuid (prefix ok)")
    ap.add_argument("--every", type=float, default=8)
    ap.add_argument("--hours", type=float, default=6, help="only transcripts touched in the last N hours")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    since = time.time() - a.hours * 3600
    before = scan(a.self, since)
    board = os.path.getsize(BOARD)
    while True:
        time.sleep(a.every)
        now = scan(a.self, since)
        # a new end_turn entry (different uuid) counts even if the whole turn fit between two polls
        done = [title for p, (ended, title, last) in now.items()
                if ended and before.get(p, (False, None, None))[2] != last]
        new_lines = []
        if os.path.getsize(BOARD) != board:
            time.sleep(2)
            with open(BOARD, "rb") as f:
                f.seek(min(board, os.path.getsize(BOARD)))
                new = f.read().decode("utf-8", "replace")
            board = os.path.getsize(BOARD)
            # the main session's own lines ("- [10-23 09:40] 메인 → ...") must not wake it
            new_lines = [l.strip() for l in new.splitlines() if l.strip() and "] 메인" not in l[:40]]
        if done or new_lines:
            stamp = time.strftime("%m-%d %H:%M:%S")
            for title in done:
                print(f"{stamp} turn ended: {title}")
            if new_lines:
                print(f"{stamp} board changed:")
                for line in new_lines:
                    print("  " + line[:220])
            return 0
        before = now


if __name__ == "__main__":
    sys.exit(main())
