"""
Roblox Studio MCP(mcp.bat)와 직접 대화하는 작은 클라이언트.

  py tools/studio_mcp.py call <tool> '<json args>'
  py tools/studio_mcp.py call <tool> @args.json

대상 창은 이름에 STUDIO_NAME(기본 "WrenchRide")이 들어간 Studio 하나. 보통은 STUDIO_ID로 창을 꼭 지정한다.
다른 게임(Halo & Horns: GoodEvil, Parcel Panic) 창은 절대 고르지 않는다.
"""

import json
import os
import queue
import subprocess
import sys
import threading
import time

MCP_BAT = os.path.join(os.environ["LOCALAPPDATA"], "Roblox", "mcp.bat")
TIMEOUT = float(os.environ.get("STUDIO_MCP_TIMEOUT", "180"))
FORBIDDEN = ("GoodEvil", "81671223175574", "79345022650204", "10122026_1", "ParcelPanic", "118470604517234", "패슬 패닉", "PlayTest")


class Client:
    def __init__(self):
        self.proc = subprocess.Popen(
            ["cmd.exe", "/c", MCP_BAT],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        self.q = queue.Queue()
        self.next_id = 1
        self._sid = None
        threading.Thread(target=self._reader, daemon=True).start()
        threading.Thread(target=self._drain, daemon=True).start()

    def _reader(self):
        for line in self.proc.stdout:
            line = line.decode("utf-8", "replace").strip()
            if line:
                try:
                    self.q.put(json.loads(line))
                except json.JSONDecodeError:
                    pass

    def _drain(self):
        for _ in self.proc.stderr:
            pass

    def send(self, msg):
        self.proc.stdin.write((json.dumps(msg) + "\n").encode("utf-8"))
        self.proc.stdin.flush()

    def request(self, method, params=None):
        rid = self.next_id
        self.next_id += 1
        self.send({"jsonrpc": "2.0", "id": rid, "method": method, "params": params or {}})
        while True:
            msg = self.q.get(timeout=TIMEOUT)
            if msg.get("id") == rid:
                if "error" in msg:
                    raise RuntimeError(json.dumps(msg["error"], ensure_ascii=False))
                return msg["result"]

    def start(self):
        self.request("initialize", {
            "protocolVersion": "2025-06-18",
            "capabilities": {},
            "clientInfo": {"name": "wrench-ride", "version": "1.0"},
        })
        self.send({"jsonrpc": "2.0", "method": "notifications/initialized"})
        return self

    def studio_id(self):
        if self._sid:
            return self._sid
        pin = os.environ.get("STUDIO_ID", "")
        if pin:
            self._sid = pin
            return pin
        name = os.environ.get("STUDIO_NAME", "WrenchRide")
        studios = []
        for _ in range(30):
            res = self.request("tools/call", {"name": "list_roblox_studios", "arguments": {}})
            studios = json.loads(res["content"][0]["text"])["studios"]
            hits = [s for s in studios if name.lower() in (s.get("name") or "").lower()
                    and not any(f.lower() in (s.get("name") or "").lower() for f in FORBIDDEN)]
            if len(hits) > 1:
                raise RuntimeError(f"'{name}' Studio 창이 여러 개예요: {[s['name'] for s in hits]}")
            if hits:
                self._sid = hits[0]["id"]
                return self._sid
            time.sleep(0.5)
        raise RuntimeError(f"'{name}' Studio 창을 찾지 못했습니다: {[s.get('name') for s in studios]}")

    def call(self, name, args):
        if name != "list_roblox_studios" and "studio_id" not in args:
            args = dict(args, studio_id=self.studio_id())
        return self.request("tools/call", {"name": name, "arguments": args})

    def text(self, name, args):
        res = self.call(name, args)
        out = "\n".join(p.get("text", "") for p in res.get("content", []) if p.get("type") == "text")
        if res.get("isError"):
            raise RuntimeError(out)
        return out

    def luau(self, code, dm="Edit"):
        return self.text("execute_luau", {"code": code, "datamodel_type": dm})

    def close(self):
        try:
            self.proc.stdin.close()
            self.proc.terminate()
        except Exception:
            pass


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    if len(sys.argv) < 3 or sys.argv[1] != "call":
        sys.exit(__doc__)
    raw = sys.argv[3] if len(sys.argv) > 3 else "{}"
    if raw.startswith("@"):
        with open(raw[1:], encoding="utf-8") as f:
            raw = f.read()
    c = Client().start()
    try:
        print(c.text(sys.argv[2], json.loads(raw)))
    finally:
        c.close()


if __name__ == "__main__":
    main()
