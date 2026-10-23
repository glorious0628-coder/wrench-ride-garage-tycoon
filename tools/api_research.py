"""Game-genre research on the user's Anthropic API credits, with web search and web fetch.

  py tools/api_research.py --topic-file notes/research/api/topics/<name>.md [--name <name>]
                           [--model opus|sonnet|haiku|<model id>] [--effort low|medium|high|xhigh|max]
                           [--max-usd 1.0] [--daily-usd 0 (= no cap)] [--max-searches 15] [--max-continuations 6]

The user asked for it ("우리 API SDK 있잖아. 그거 게임 리서치 돌려"): research runs here instead of on app usage.
- Key: ANTHROPIC_API_KEY from the environment, else from ../Game/.env, read into memory only. It is never printed,
  logged or written anywhere (the client gets it directly).
- Writes notes/research/api/<date>_<name>.md (the report, with sources) and <date>_<name>.usage.json.
- Spend: estimated from response.usage every turn (list prices below). A run stops at --max-usd (one turn over at
  most). The ledger notes/research/api/_spend.json keeps the daily total; no daily cap by default (user 10-20: "하루 10 상한 없애도 돼 그냥 지금 있는 크레딧 안에서만 다 쓰믄 됩니당"); --daily-usd N > 0 sets one.
- Model: Claude Opus 5.5 by default (adaptive thinking, effort medium), with the server-side refusal fallback
  (fallbacks="default"). Pass --model sonnet / haiku for cheaper runs.
Reports are summaries in Korean with source links; the main session reviews them before anything reaches the game.
"""
import argparse
import datetime
import json
import os
import re
import sys

import anthropic

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_ROOT = os.path.join(ROOT, "notes", "research", "api")
LEDGER = os.path.join(OUT_ROOT, "_spend.json")
# (10-20 19:4x the user moved ../Game/.env into ../Halo & Horns/.env; the old place is still tried first)
ENV_CANDIDATES = [os.path.join(os.path.dirname(ROOT), d, ".env") for d in ("Game", "Halo & Horns")]
GAME_ENV = next((p for p in ENV_CANDIDATES if os.path.exists(p)), ENV_CANDIDATES[0])

MODELS = {"opus": "claude-opus-5-5", "sonnet": "claude-sonnet-5-5", "haiku": "claude-haiku-5-5"}
# USD per 1M tokens: (input, output, cache read); a cache write costs 1.25x input. Web search: $10 per 1,000.
PRICES = {
    "claude-opus-5-5": (4.0, 20.0, 0.20),
    "claude-sonnet-5-5": (2.0, 10.0, 0.20),
    "claude-haiku-5-5": (0.10, 0.50, 0.01),
}
SEARCH_USD = 0.01

SYSTEM = """You research Roblox games and real-world car mechanics for the team making "Wrench & Ride Garage Tycoon", a
Roblox semi-realistic car-repair + tycoon + co-op (1-4 players) game: R15 NPC customers bring broken cars with real-world
symptoms, players diagnose (eyes, OBD scanner), lift, unbolt and replace modular MeshPart parts, get paid and grow the
garage; later they buy wrecks at a junkyard, restore and tune them, and flip them in a used-car showroom by haggling.
Rare historic cars from the very first automobile to today appear now and then (original designs, no real brands).
House rules: no real brand names, logos or trade dress; convenience and cosmetics for Robux, never pay-to-win; fun first.

Use web search and web fetch to find current, concrete facts (game pages, update logs, guides, videos' descriptions,
community threads). Prefer primary sources and recent dates; say when a number is uncertain.
Write the final report in Korean, in plain short sentences, as markdown:
1. 한 줄 요약
2. 찾은 것 (게임·자료별, 숫자와 날짜)
3. 우리 게임에 가져올 것 / 피할 것 (중요한 순서, 각각 '왜'와 '크기 S/M/L')
4. 출처 (링크 목록)
Summarise in your own words; never copy long passages."""


def api_key() -> str:
    key = os.environ.get("ANTHROPIC_API_KEY", "").strip()
    if key:
        return key
    try:
        with open(GAME_ENV, encoding="utf-8") as f:
            for line in f:
                m = re.match(r"\s*ANTHROPIC_API_KEY\s*=\s*(.*)$", line)
                if m:
                    return m.group(1).strip().strip('"').strip("'")
    except OSError:
        pass
    sys.exit("no ANTHROPIC_API_KEY (environment or ../Game/.env)")


def load_ledger() -> dict:
    try:
        with open(LEDGER, encoding="utf-8") as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return {}


def save_ledger(ledger: dict) -> None:
    with open(LEDGER, "w", encoding="utf-8") as f:
        json.dump(ledger, f, ensure_ascii=False, indent=2)


def turn_cost(model: str, usage) -> tuple[float, int]:
    p_in, p_out, p_cache = PRICES.get(model, PRICES["claude-opus-5-5"])
    inp = getattr(usage, "input_tokens", 0) or 0
    out = getattr(usage, "output_tokens", 0) or 0
    c_read = getattr(usage, "cache_read_input_tokens", 0) or 0
    c_write = getattr(usage, "cache_creation_input_tokens", 0) or 0
    stu = getattr(usage, "server_tool_use", None)
    searches = (getattr(stu, "web_search_requests", 0) or 0) if stu else 0
    usd = (inp * p_in + out * p_out + c_read * p_cache + c_write * p_in * 1.25) / 1e6 + searches * SEARCH_USD
    return usd, searches


def sources_of(content) -> list[dict]:
    found = []
    for block in content:
        if getattr(block, "type", "") == "web_search_tool_result":
            results = getattr(block, "content", None)
            if isinstance(results, list):  # an error result is a single object, not a list
                for r in results:
                    url = getattr(r, "url", None)
                    if url:
                        found.append({"title": getattr(r, "title", ""), "url": url})
    return found


def main() -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--topic-file", required=True)
    ap.add_argument("--name")
    ap.add_argument("--model", default="opus")
    ap.add_argument("--effort", default="medium", choices=["low", "medium", "high", "xhigh", "max"])
    ap.add_argument("--max-usd", type=float, default=1.0)
    ap.add_argument("--daily-usd", type=float, default=0.0)  # 0 = no daily cap
    ap.add_argument("--max-searches", type=int, default=8)
    ap.add_argument("--max-fetches", type=int, default=4)
    ap.add_argument("--fetch-tokens", type=int, default=8000, help="max tokens kept from one fetched page")
    ap.add_argument("--max-continuations", type=int, default=6)
    a = ap.parse_args()

    model = MODELS.get(a.model, a.model)
    topic = open(a.topic_file, encoding="utf-8").read().strip()
    name = a.name or os.path.splitext(os.path.basename(a.topic_file))[0]
    today = datetime.date.today().isoformat()
    os.makedirs(OUT_ROOT, exist_ok=True)

    ledger = load_ledger()
    spent_today = float(ledger.get(today, 0.0))
    if a.daily_usd > 0 and spent_today + a.max_usd > a.daily_usd:
        print(f"refused: today's spend ${spent_today:.2f} + this run's cap ${a.max_usd:.2f} > daily cap ${a.daily_usd:.2f}")
        return 2

    client = anthropic.Anthropic(api_key=api_key(), max_retries=3)
    tools = [
        {"type": "web_search_20260209", "name": "web_search", "max_uses": a.max_searches},
        # fetched pages are the main cost (the first run read whole pages: ~$3 in one turn), so keep them short
        {"type": "web_fetch_20260209", "name": "web_fetch", "max_uses": a.max_fetches, "max_content_tokens": a.fetch_tokens},
    ]
    params = dict(
        model=model,
        max_tokens=32000,
        system=SYSTEM,
        tools=tools,
        thinking={"type": "adaptive"},
        output_config={"effort": a.effort},
    )
    if model in ("claude-opus-5-5", "claude-sonnet-5-5"):
        params["betas"] = ["server-side-fallback-2026-07-01"]
        params["fallbacks"] = "default"

    messages = [{"role": "user", "content": topic}]
    usd, searches, turns, sources = 0.0, 0, 0, []
    tokens = {"input": 0, "output": 0, "cache_read": 0, "cache_write": 0}
    final = None
    stop = "?"
    for _ in range(a.max_continuations + 1):
        turns += 1
        try:
            with client.beta.messages.stream(messages=messages, **params) as stream:
                response = stream.get_final_message()
        except anthropic.RateLimitError as e:
            stop = f"rate limited: {e.status_code}"
            break
        except anthropic.APIStatusError as e:
            stop = f"api error {e.status_code}"
            break
        except anthropic.APIConnectionError:
            stop = "connection error"
            break
        cost, n = turn_cost(model, response.usage)
        u = response.usage
        tokens["input"] += getattr(u, "input_tokens", 0) or 0
        tokens["output"] += getattr(u, "output_tokens", 0) or 0
        tokens["cache_read"] += getattr(u, "cache_read_input_tokens", 0) or 0
        tokens["cache_write"] += getattr(u, "cache_creation_input_tokens", 0) or 0
        usd += cost
        searches += n
        sources += sources_of(response.content)
        final = response
        stop = response.stop_reason
        if stop == "pause_turn" and usd < a.max_usd:
            # the server-side tool loop paused: re-send the turn and it resumes (no extra "continue" message)
            messages = [{"role": "user", "content": topic}, {"role": "assistant", "content": response.content}]
            continue
        break

    text = ""
    if final is not None and stop != "refusal":
        text = "\n".join(b.text for b in final.content if getattr(b, "type", "") == "text").strip()
    if not text:
        text = f"(보고서 없음: stop_reason={stop})"

    seen, src_lines = set(), []
    for s in sources:
        if s["url"] not in seen:
            seen.add(s["url"])
            src_lines.append(f"- [{s['title'] or s['url']}]({s['url']})")
    base = os.path.join(OUT_ROOT, f"{today}_{name}")
    with open(base + ".md", "w", encoding="utf-8") as f:
        f.write(f"# API 리서치: {name} ({today})\n\n")
        f.write(f"- 모델 {model} · effort {a.effort} · 비용 약 ${usd:.3f} · 검색 {searches}회 · 턴 {turns} · 끝 {stop}\n")
        f.write("- 메인 세션 검수 전 자료예요. 숫자는 출처를 보고 다시 확인해요.\n\n")
        f.write(text + "\n")
        if src_lines:
            f.write("\n## 검색에서 본 자료 (자동 수집)\n" + "\n".join(src_lines[:60]) + "\n")
    with open(base + ".usage.json", "w", encoding="utf-8") as f:
        json.dump({"model": model, "effort": a.effort, "usd": round(usd, 4), "searches": searches, "turns": turns, "tokens": tokens,
                   "stop_reason": stop, "topic_file": a.topic_file}, f, ensure_ascii=False, indent=2)

    ledger = load_ledger()
    ledger[today] = round(float(ledger.get(today, 0.0)) + usd, 4)
    save_ledger(ledger)
    print(f"done: {base}.md  cost ~${usd:.3f}  searches {searches}  stop {stop}  today ${ledger[today]:.2f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
