"""
src/ 의 Luau 파일을 열려 있는 WrenchRide Studio(편집 모드, STUDIO_ID로 지정)에 밀어 넣는다.

  py tools/sync_to_studio.py            -> 바뀐 스크립트만 다시 만든다
  py tools/sync_to_studio.py --all      -> 전부 다시 만든다

파일 이름 규칙(Rojo와 같음): X.server.luau = Script, X.client.luau = LocalScript, X.luau = ModuleScript.
src에 없는 스크립트는 관리 대상 폴더(ServerScriptService, ReplicatedStorage, StarterPlayerScripts)에서 지운다.
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from studio_mcp import Client  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "src")
ROOTS = [["ServerScriptService"], ["ReplicatedStorage"], ["ReplicatedFirst"], ["StarterPlayer", "StarterPlayerScripts"]]


def kind(filename):
    for suffix, cls in ((".server.luau", "Script"), (".client.luau", "LocalScript"), (".luau", "ModuleScript")):
        if filename.endswith(suffix):
            return filename[: -len(suffix)], cls
    return None, None


def collect():
    items = {}
    for dirpath, _, files in os.walk(SRC):
        rel = os.path.relpath(dirpath, SRC)
        parts = [] if rel == "." else rel.split(os.sep)
        for f in sorted(files):
            base, cls = kind(f)
            if not cls:
                continue
            with open(os.path.join(dirpath, f), encoding="utf-8") as fh:
                src = fh.read().replace("\r\n", "\n")
            items[".".join(parts + [base])] = (cls, src)
    return items


def lua(value):
    """파이썬 리스트/문자열 -> Luau 테이블 리터럴 (JSON의 [[ 는 Luau에서 긴 문자열이 된다)"""
    if isinstance(value, list):
        return "{" + ", ".join(lua(v) for v in value) + "}"
    return json.dumps(value)


def src_hash(src):
    h = 0
    for b in src.encode("utf-8"):
        h = (h * 31 + b) % 2147483647
    return f"{len(src.encode('utf-8'))}:{h}"


READ_LUA = """
local HttpService = game:GetService("HttpService")
local roots = %s
local function hash(src)
    src = string.gsub(src, string.char(13), "")
    local h = 0
    for i = 1, #src do h = (h * 31 + string.byte(src, i)) %% 2147483647 end
    return #src .. ":" .. h
end
local out = {}
for _, r in ipairs(roots) do
    local node = game:GetService(r[1])
    for i = 2, #r do node = node and node:FindFirstChild(r[i]) end
    if node then
        for _, d in ipairs(node:GetDescendants()) do
            if d:IsA("LuaSourceContainer") then
                local parts, n = {}, d
                while n and n ~= game do table.insert(parts, 1, n.Name); n = n.Parent end
                out[table.concat(parts, ".")] = { c = d.ClassName, h = hash(d.Source) }
            end
        end
    end
end
return HttpService:JSONEncode(out)
"""

PREP_LUA = """
local deletes = %s
local folders = %s
for _, p in ipairs(deletes) do
    local node = game
    for name in string.gmatch(p, "[^%%.]+") do node = node and node:FindFirstChild(name) end
    if node and node ~= game then node:Destroy() end
end
for _, p in ipairs(folders) do
    local node = game
    for name in string.gmatch(p, "[^%%.]+") do
        local child = node:FindFirstChild(name)
        if not child then
            if node == game then child = game:GetService(name)
            else child = Instance.new("Folder"); child.Name = name; child.Parent = node end
        end
        node = child
    end
end
return "ok"
"""


def long_string(text):
    level = 1
    while ("]" + "=" * level + "]") in text:
        level += 1
    eq = "=" * level
    # Lua drops the newline right after the opening bracket, so add one (keeps line numbers)
    return f"[{eq}[\n{text}]{eq}]"


WRITE_LUA = """
local path, className = %s, %s
local node = game
local parts = string.split(path, ".")
for i = 1, #parts - 1 do
    local child = node:FindFirstChild(parts[i])
    if not child then
        if node == game then child = game:GetService(parts[i])
        else child = Instance.new("Folder"); child.Name = parts[i]; child.Parent = node end
    end
    node = child
end
local name = parts[#parts]
local s = node:FindFirstChild(name)
if s and s.ClassName ~= className then s:Destroy(); s = nil end
if not s then s = Instance.new(className); s.Name = name end
s.Source = %s
s.Parent = node
return #s.Source
"""

# a script longer than the execute_luau string limit (200000, Client.client.luau passed it on 10-19) goes in pieces:
# the first piece sets Source, every next piece appends to it
APPEND_LUA = """
local node = game
for name in string.gmatch(%s, "[^%%.]+") do node = node and node:FindFirstChild(name) end
node.Source = node.Source .. %s
return #node.Source
"""
CHUNK_BYTES = 90000


def chunks(src):
    """split at line ends into pieces of at most CHUNK_BYTES utf-8 bytes (their concatenation is exactly src)"""
    out, cur, size = [], [], 0
    for line in src.splitlines(keepends=True):
        n = len(line.encode("utf-8"))
        if cur and size + n > CHUNK_BYTES:
            out.append("".join(cur))
            cur, size = [], 0
        cur.append(line)
        size += n
    out.append("".join(cur))
    return out


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    full = "--all" in sys.argv
    # --only A B ...: just these scripts (dotted path prefixes), nothing removed. For when another session is in the
    # middle of other files (e.g. --only ServerScriptService ReplicatedStorage.Shared.Config)
    only = sys.argv[sys.argv.index("--only") + 1:] if "--only" in sys.argv else None
    items = collect()
    c = Client().start()
    try:
        state = c.text("get_studio_state", {})
        if "Edit" not in state.split("Current Studio Mode:")[-1].split("\n")[0]:
            sys.exit("Studio가 플레이 중입니다. 정지한 뒤 다시 실행하세요.\n" + state)
        current = json.loads(c.luau(READ_LUA % lua(ROOTS)))
        to_write = [p for p, (cls, src) in items.items()
                    if full or p not in current or current[p]["c"] != cls or current[p]["h"] != src_hash(src)]
        extra = [p for p in current if p not in items]
        if only:
            to_write = [p for p in to_write if any(p == o or p.startswith(o + ".") for o in only)]
            extra = []
        if "--skip" in sys.argv:
            sk = sys.argv[sys.argv.index("--skip") + 1].split(",")
            to_write = [p for p in to_write if p not in sk]
        deletes = extra
        folders = sorted({".".join(p.split(".")[:-1]) for p in to_write})
        c.luau(PREP_LUA % (lua(deletes), lua(folders)))
        for p in to_write:
            cls, src = items[p]
            # set Source directly (multi_edit hangs in published / collaborative places)
            parts = chunks(src)
            c.luau(WRITE_LUA % (json.dumps(p), json.dumps(cls), long_string(parts[0])))
            for more in parts[1:]:
                c.luau(APPEND_LUA % (json.dumps(p), long_string(more)))
            print("  wrote", p, f"({cls})")
        for p in extra:
            print("  removed", p)
        after = json.loads(c.luau(READ_LUA % lua(ROOTS)))
        bad = [p for p, (cls, src) in items.items() if (not only or p in to_write) and (p not in after or after[p]["h"] != src_hash(src))]
        if bad:
            sys.exit("동기화 후 내용이 다른 스크립트: " + ", ".join(bad))
        print(f"sync ok: {len(to_write)} written, {len(extra)} removed, {len(items)} total")
    finally:
        c.close()


if __name__ == "__main__":
    main()
