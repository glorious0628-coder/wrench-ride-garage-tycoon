"""Real type / Roblox API checks with luau-lsp (tools/luau-lsp, MIT) — on top of luau_lint.py's bracket check.

    py -I tools/luau_check.py                      -> every file under src
    py -I tools/luau_check.py src/.../X.luau ...    -> only report these files (the whole project is still analysed,
                                                      so requires and the other modules' types are known)
    py -I tools/luau_check.py --all                 -> also list the old problems the baseline holds
    py -I tools/luau_check.py --update-baseline     -> take the current problems as the new baseline (wr-dev / main
                                                      only, after a cleanup — never to hide a new one)

The project had ~150 old problems when this came in (10-22), nearly all type notes (`T?` passed where `T` is wanted,
`for k in t or {} do`, mixed-type tables, unused names). They're in tools/luau_check_baseline.json; what fails is a
problem that isn't there — a new one, or one more of the same kind in a file. A file's line numbers may move freely.
Rebuilds sourcemap.json first (tools/gen_sourcemap.py). Exit 0 = nothing new.
"""

import collections
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LSP = ROOT / "tools" / "luau-lsp" / "luau-lsp.exe"
DEFS = ROOT / "tools" / "luau-lsp" / "globalTypes.d.luau"
BASELINE = ROOT / "tools" / "luau_check_baseline.json"
LINE = re.compile(r"^(.*?\.luau)(?: \[[^\]]*\])?\((\d+),(\d+)\): (\w+): (.*)$")


def norm_path(p: str) -> str:
    p = p.replace("\\", "/")
    i = p.find("src/")
    return p[i:] if i >= 0 else p


def key_of(code: str, msg: str) -> str:
    msg = re.sub(r"\bline \d+\b", "line N", msg)  # ("... shadows previous declaration at line 76")
    return code + ": " + " ".join(msg.split())


def analyse() -> list:
    subprocess.run([sys.executable, "-I", str(ROOT / "tools" / "gen_sourcemap.py")], check=True, cwd=ROOT,
                   stdout=subprocess.DEVNULL)
    out = subprocess.run(
        [str(LSP), "analyze", "--platform=roblox", f"--definitions=@roblox={DEFS.relative_to(ROOT).as_posix()}",
         "--sourcemap=sourcemap.json", "src"],
        cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    found, cur = set(), None
    for raw in (out.stdout + "\n" + out.stderr).splitlines():
        m = LINE.match(raw)
        if m:
            cur = [norm_path(m.group(1)), int(m.group(2)), m.group(4), m.group(5)]
            found.add(tuple(cur))  # (a module's problem is printed once per file that requires it: kept once)
    return sorted(found)


def main() -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    only = {norm_path(str(Path(a).resolve())) for a in args}
    problems = analyse()
    counts = collections.Counter((p[0], key_of(p[2], p[3])) for p in problems)
    if "--update-baseline" in sys.argv:
        base = {}
        for (f, k), n in sorted(counts.items()):
            base.setdefault(f, {})[k] = n
        BASELINE.write_text(json.dumps(base, indent=1, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
        print(f"baseline: {len(problems)} problems in {len(base)} files -> {BASELINE.relative_to(ROOT).as_posix()}")
        return 0
    base = json.loads(BASELINE.read_text(encoding="utf-8")) if BASELINE.exists() else {}
    seen = collections.Counter()
    new, old = [], []
    for p in problems:
        f, k = p[0], key_of(p[2], p[3])
        if only and f not in only:
            continue
        seen[(f, k)] += 1
        (old if seen[(f, k)] <= base.get(f, {}).get(k, 0) else new).append(p)
    gone = sum(max(0, n - counts.get((f, k), 0)) for f, ks in base.items() for k, n in ks.items()
               if not only or f in only)
    for f, line, code, msg in new:
        print(f"NEW  {f}:{line}  {code}: {msg}")
    if "--all" in sys.argv:
        for f, line, code, msg in old:
            print(f"old  {f}:{line}  {code}: {msg}")
    where = f"{len(only)} file(s)" if only else "src"
    print(f"luau-lsp {where}: {len(new)} new, {len(old)} old (baseline){f', {gone} fixed since the baseline' if gone else ''}")
    return 1 if new else 0


if __name__ == "__main__":
    sys.exit(main())
