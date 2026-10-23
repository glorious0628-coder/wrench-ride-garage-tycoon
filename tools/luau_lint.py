"""py luau_lint.py <file.luau>...: rough Luau syntax check without a compiler (pp-plot-look, 10-18).
Checks: brackets ( [ { balance over the file (strings and comments skipped), block keywords vs `end` balance, and
a `--` comment on a line where a ( [ { opened on that line is still open (the comment eats the arguments after it).
Not a real parser: a clean result means no obvious slip, not that it compiles (pp-studio's compile_check decides)."""
import re
import sys

OPEN = {"(": ")", "[": "]", "{": "}"}


def strip(line, state):
    """returns (code without strings/comments, comment_started_with_open_bracket, state)"""
    out = []
    i = 0
    depth_line = 0
    hazard = False
    while i < len(line):
        if state["long"]:
            j = line.find("]" + "=" * state["long_eq"] + "]", i)
            if j < 0:
                return "".join(out), hazard, state
            i = j + 2 + state["long_eq"]
            state["long"] = False
            continue
        c = line[i]
        if c in "\"'`":
            q = c
            i += 1
            while i < len(line) and line[i] != q:
                i += 2 if line[i] == "\\" else 1
            i += 1
            out.append(" ")
            continue
        if line.startswith("--", i):
            m = re.match(r"--\[(=*)\[", line[i:])
            if depth_line > 0:
                hazard = True
            if m:
                state["long"] = True
                state["long_eq"] = len(m.group(1))
                i += len(m.group(0))
                continue
            break
        m = re.match(r"\[(=*)\[", line[i:])
        if m:
            state["long"] = True
            state["long_eq"] = len(m.group(1))
            i += len(m.group(0))
            out.append(" ")
            continue
        if c in OPEN:
            depth_line += 1
        elif c in ")]}":
            depth_line = max(0, depth_line - 1)
        out.append(c)
        i += 1
    return "".join(out), hazard, state


def check(path):
    src = open(path, encoding="utf-8").read().split("\n")
    state = {"long": False, "long_eq": 0}
    stack = []
    blocks = 0
    problems = []
    notes = []
    for n, line in enumerate(src, 1):
        code, hazard, state = strip(line, state)
        if hazard:
            notes.append(f"{n}: note: `--` after an open bracket (fine for a table / call split over lines)")
        for c in code:
            if c in OPEN:
                stack.append((c, n))
            elif c in ")]}":
                if not stack or OPEN[stack[-1][0]] != c:
                    problems.append(f"{n}: unexpected {c}")
                else:
                    stack.pop()
        words = re.findall(r"\b(function|do|then|repeat|end|until|elseif)\b", code)
        for w in words:
            if w in ("function", "do", "repeat"):
                blocks += 1
            elif w == "then":
                pass
            elif w in ("end", "until"):
                blocks -= 1
        # `if ... then` opens a block; `elseif ... then` doesn't
        blocks += len(re.findall(r"\bif\b", code)) - len(re.findall(r"\bif\b[^\n]*?\bthen\b[^\n]*?\belse\b[^\n]*?$", code)) * 0
        # if-expressions (`if a then b else c` with no `end`) don't open blocks: count `then ... else` inside one line
        # without an `end` on the line as expressions
        for m in re.finditer(r"\bif\b(.*?)\bthen\b(.*?)\belse\b", code):
            if not re.search(r"\bend\b", code[m.end():]) and not code.rstrip().endswith("then"):
                blocks -= 1
    for c, n in stack:
        problems.append(f"{n}: {c} never closed")
    return problems, blocks, notes


bad = 0
for p in sys.argv[1:]:
    problems, blocks, notes = check(p)
    tail = "" if blocks == 0 else f"  (block balance {blocks:+d}: rough, check if-expressions by eye)"
    print(("OK  " if not problems else "BAD ") + p + tail)
    for x in problems[:20]:
        print("    " + x)
    bad += len(problems)
sys.exit(1 if bad else 0)
