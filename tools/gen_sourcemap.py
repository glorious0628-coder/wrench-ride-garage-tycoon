"""default.project.json -> sourcemap.json (the Rojo sourcemap shape), so luau-lsp can follow require(script.Parent.X).

    py -I tools/gen_sourcemap.py            -> writes sourcemap.json at the project root

Rojo isn't installed here; this does the part luau-lsp needs. File names follow sync_to_studio.py (= Rojo):
X.server.luau = Script, X.client.luau = LocalScript, X.luau = ModuleScript, init(.server/.client).luau = the folder
itself is that script. A service named in the project tree gets its own class (ReplicatedStorage, StarterPlayer ...);
plain folders are Folder. Run it again after adding / renaming / moving a .luau file (tools/luau_check.py does).
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SERVICES = {
    "ReplicatedStorage", "ReplicatedFirst", "ServerScriptService", "ServerStorage", "StarterPlayer", "StarterGui",
    "StarterPack", "Workspace", "Lighting", "SoundService", "Players", "Teams", "Chat", "TextChatService",
}
KINDS = ((".server.luau", "Script"), (".client.luau", "LocalScript"), (".luau", "ModuleScript"))


def kind(name: str):
    for ext, cls in KINDS:
        if name.endswith(ext):
            return name[: -len(ext)], cls
    return None, None


def rel(p: Path) -> str:
    return p.relative_to(ROOT).as_posix()


def from_dir(path: Path, name: str, cls: str) -> dict:
    node = {"name": name, "className": cls, "filePaths": [], "children": []}
    for child in sorted(path.iterdir(), key=lambda c: c.name):
        if child.is_dir():
            node["children"].append(from_dir(child, child.name, "Folder"))
            continue
        base, scls = kind(child.name)
        if not base:
            continue
        if base == "init":
            node["className"] = scls  # (the folder is this script; its other files are its children)
            node["filePaths"].append(rel(child))
        else:
            node["children"].append({"name": base, "className": scls, "filePaths": [rel(child)]})
    # a folder holding an init script: that script's class; a plain folder needs no filePaths
    return node


def from_tree(tree: dict, name: str) -> dict:
    cls = tree.get("$className") or (name if name in SERVICES else "Folder")
    if "$path" in tree:
        node = from_dir(ROOT / tree["$path"], name, cls)
    else:
        node = {"name": name, "className": cls, "filePaths": [], "children": []}
    for key, sub in tree.items():
        if not key.startswith("$"):
            node["children"].append(from_tree(sub, key))
    return node


def main() -> int:
    project = json.loads((ROOT / "default.project.json").read_text(encoding="utf-8"))
    tree = from_tree(project["tree"], project["name"])
    tree["filePaths"] = ["default.project.json"]
    out = ROOT / "sourcemap.json"
    out.write_text(json.dumps(tree, indent=1) + "\n", encoding="utf-8", newline="\n")
    n = sum(1 for _ in (ROOT / "src").rglob("*.luau"))
    print(f"wrote {rel(out)} ({n} .luau files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
