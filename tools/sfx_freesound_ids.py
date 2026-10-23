"""Download specific Freesound sounds (CC0 only, public HQ preview mp3) by 'user/sounds/id' (wr-sound 10-22).
Checks the sound page says Creative Commons 0 and has no GenAI tag; adds a LEDGER.md line.
Usage: py -I tools/sfx_freesound_ids.py <cat> user/id [user/id ...]
"""
import html
import re
import sys
import time
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sfx_freesound as F  # noqa: E402


def main():
    cat, items = sys.argv[1], sys.argv[2:]
    F.RAW.mkdir(parents=True, exist_ok=True)
    for it in items:
        user, sid = it.split("/")
        url = f"https://freesound.org/people/{user}/sounds/{sid}/"
        page = F.get(url)
        text = html.unescape(re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", page)))
        cc0 = "Creative Commons 0" in text or "publicdomain/zero" in page
        ai = bool(re.search(r"genai|ai[- ]generated", text, re.I))
        mp3 = re.search(r'data-mp3="([^"]+)"', page) or re.search(r'property="og:audio" content="([^"]+)"', page)
        title = re.search(r"<title>(.*?)</title>", page)
        print(it, "CC0" if cc0 else "NOT-CC0", "AI" if ai else "noAI", (title.group(1) if title else "?")[:60], bool(mp3))
        if not (cc0 and not ai and mp3):
            continue
        f = F.RAW / f"{cat}_{sid}.mp3"
        if not f.exists():
            f.write_bytes(F.get(mp3.group(1).replace("-lq.mp3", "-hq.mp3"), True))
            with F.LEDGER.open("a", encoding="utf-8") as L:
                L.write(f"| {f.name} | {html.unescape(title.group(1)) if title else '?'} | {user} | {url} | CC0 | {date.today()} |\n")


if __name__ == "__main__":
    main()
