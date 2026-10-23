"""Freesound CC0-only candidate collector (wr-sound 10-22, user: "CC0 으로 해줘").
Search pages are public (no login): license filter = Creative Commons 0, GenAI-tagged sounds dropped.
Downloads the public HQ preview mp3 (no login) to art/sfx/freesound/raw/<cat>_<id>.mp3 and appends art/sfx/freesound/LEDGER.md.
Usage: py -I tools/sfx_freesound.py <cat> "<query>" ["<query>" ...] [--max N]
"""
import html
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "art/sfx/freesound/raw"
LEDGER = ROOT / "art/sfx/freesound/LEDGER.md"
UA = {"User-Agent": "Mozilla/5.0 (wr-sound; CC0 candidate search)"}


def get(url, binary=False):
    for wait in (4, 12, 30, 60, 0):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=40) as r:
                b = r.read()
            time.sleep(2.5)  # Freesound answers 429 to fast / parallel requests
            return b if binary else b.decode("utf-8", "replace")
        except urllib.error.HTTPError as e:
            if e.code != 429 or not wait:
                raise
            time.sleep(wait)


def search(q):
    u = "https://freesound.org/search/?q=" + urllib.parse.quote(q) + "&f=" + urllib.parse.quote('license:"Creative Commons 0"') + "&s=score+desc&advanced=0&g=0"
    page = get(u)
    out = []
    for blk in page.split('class="bw-search__result"')[1:]:
        m = re.search(r'href="(/people/([^/]+)/sounds/(\d+)/)"', blk)
        mp3 = re.search(r'data-mp3="([^"]+)"', blk)
        title = re.search(r'aria-label="Sound (.*?) by ', blk)
        text = html.unescape(re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", blk)))
        if not (m and mp3):
            continue
        if re.search(r"genai|ai[- ]generated|ai generated", text, re.I):
            continue
        dur = re.search(r"(\d+):(\d+)(?:\.(\d+))?", text)
        secs = int(dur.group(1)) * 60 + int(dur.group(2)) if dur else None
        out.append({"id": m.group(3), "user": m.group(2), "url": "https://freesound.org" + m.group(1), "title": html.unescape(title.group(1)) if title else "?", "mp3": mp3.group(1).replace("-lq.mp3", "-hq.mp3"), "secs": secs})
    return out


def main():
    a = sys.argv[1:]
    mx = 12
    if "--max" in a:
        i = a.index("--max")
        mx = int(a[i + 1])
        del a[i:i + 2]
    cat, qs = a[0], a[1:]
    seen = {}
    for q in qs:
        for r in search(q):
            seen.setdefault(r["id"], r)
    RAW.mkdir(parents=True, exist_ok=True)
    LEDGER.parent.mkdir(parents=True, exist_ok=True)
    if not LEDGER.exists():
        LEDGER.write_text("# Freesound CC0 장부 (10-22 wr-sound)\n\n라이선스 = Creative Commons 0만, GenAI 태그 소리 제외. 받은 것 = 로그인 없이 되는 HQ 미리듣기 mp3.\n\n| 파일 | 이름 | 만든 사람 | URL | 라이선스 | 받은 날 |\n|---|---|---|---|---|---|\n", encoding="utf-8")
    n = 0
    for r in seen.values():
        if r["secs"] is not None and r["secs"] > 60:
            continue
        f = RAW / f"{cat}_{r['id']}.mp3"
        if not f.exists():
            try:
                f.write_bytes(get(r["mp3"], True))
            except Exception as e:
                print("fail", r["id"], e)
                continue
            with LEDGER.open("a", encoding="utf-8") as L:
                L.write(f"| {f.name} | {r['title']} | {r['user']} | {r['url']} | CC0 | {date.today()} |\n")
        print(f"{f.name}\t{r['secs']}s\t{r['title'][:50]}\t{r['user']}")
        n += 1
        if n >= mx:
            break


if __name__ == "__main__":
    main()
