"""Ask Claude (our Anthropic API SDK) to review images, or to answer a design question — the fallback for gpt_image_review.py.

Usage: py tools/api_image_review.py --prompt-file notes/gpt/review/<묶음>_q.md [--image a.png --image b.png ...]
                                    --out notes/gpt/review/<묶음>_api_a.md [--model opus] [--effort high]
                                    [--max-usd 0.5] [--daily-usd 0 (= no cap)]

Same arguments as gpt_image_review.py (the user 10-19: "만약에 gpt 사용량 다하면 API SDK 랑 해줘"), so a session can swap the
script name when GPT answers exit 3 (usage limit). --image is optional: without it this is a plain text question.
- Key: same as api_research.py (ANTHROPIC_API_KEY or ../Game/.env, memory only, never printed or written).
- Spend: shares api_research.py's daily ledger (notes/research/api/_spend.json); no daily cap by default (user 10-20: "하루 10 상한 없애도 돼 그냥 지금 있는 크레딧 안에서만 다 쓰믄 됩니당"); --daily-usd N > 0 sets one.
  When the account runs out of credits the API errors and this exits 3 with "out of API credits".
- Images are sent as they are (base64). Only a file over the API's 5 MB per-image limit is re-encoded in memory
  (never written back, never cropped or resized).
Exit codes: 0 ok, 2 bad input / over a --daily-usd cap, 3 API error (rate limit, overload, connection, out of credits), 4 no answer.
"""
import argparse
import base64
import datetime
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import anthropic  # noqa: E402
from api_research import MODELS, api_key, load_ledger, save_ledger, turn_cost  # noqa: E402

MAX_IMAGE_BYTES = 5 * 1024 * 1024
MEDIA = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp", ".gif": "image/gif"}

SYSTEM = """You are the second reviewer for "Wrench & Ride Garage Tycoon", a Roblox semi-realistic car-repair and garage
tycoon game (1-4 player co-op): R15 avatars diagnose and fix modular, semi-realistic MeshPart cars (engine bay, underbody,
wheels, body panels), later restore junkyard wrecks and sell them in a showroom. Rare historic cars (first automobile to
today) appear as original designs. Look at every attached image carefully, at full size and at the small in-game size
the prompt names, and judge honestly: say what works, what does not, and why. Disagree with the asker when the evidence
says so. House art rules the prompt may rely on: ONE casual art style for everything (car bodies AND mechanical parts:
simple clean shapes, friendly readable colours, not photo-real), but the car's parts are COMPLETE like a real car: every
real part in its real place, nothing missing, each part instantly recognisable (battery, radiator, brake disc and
caliper, shock absorber, exhaust...); garage tools read as real tools in the same casual style; people are Roblox R15
avatars; no real brand names, logos
or copied trade dress; no rising-sun ray backgrounds; no cut-outs or stretching. Answer in Korean, in plain short
sentences, item by item, with a clear verdict for each (OK / 다시 + 고칠 점)."""


def image_block(path: str) -> dict:
    ext = os.path.splitext(path)[1].lower()
    if ext not in MEDIA:
        raise ValueError(f"unsupported image type: {path}")
    with open(path, "rb") as f:
        data = f.read()
    media = MEDIA[ext]
    if len(data) > MAX_IMAGE_BYTES:
        from PIL import Image  # only needed for oversized files

        im = Image.open(io.BytesIO(data))
        buf = io.BytesIO()
        if im.mode in ("RGBA", "LA", "P"):
            im.save(buf, "PNG", optimize=True)
        else:
            im.convert("RGB").save(buf, "JPEG", quality=92)
            media = "image/jpeg"
        data = buf.getvalue()
        if len(data) > MAX_IMAGE_BYTES:
            raise ValueError(f"image still over 5 MB after re-encoding: {path}")
    return {"type": "image", "source": {"type": "base64", "media_type": media, "data": base64.standard_b64encode(data).decode("ascii")}}


def main() -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--prompt-file", required=True)
    ap.add_argument("--image", action="append", default=[], help="image(s) to attach (optional)")
    ap.add_argument("--out", required=True)
    ap.add_argument("--model", default="opus")
    ap.add_argument("--effort", default="high", choices=["low", "medium", "high", "xhigh", "max"])
    ap.add_argument("--max-usd", type=float, default=0.5)
    ap.add_argument("--daily-usd", type=float, default=0.0)  # 0 = no daily cap
    a = ap.parse_args()

    model = MODELS.get(a.model, a.model)
    today = datetime.date.today().isoformat()
    try:
        prompt = open(a.prompt_file, encoding="utf-8").read().strip()
        content = [image_block(p) for p in a.image]
    except (OSError, ValueError) as e:
        print(f"bad input: {e}", file=sys.stderr)
        return 2
    content.append({"type": "text", "text": prompt})

    spent_today = float(load_ledger().get(today, 0.0))
    if a.daily_usd > 0 and spent_today + a.max_usd > a.daily_usd:
        print(f"refused: today's spend ${spent_today:.2f} + this call's cap ${a.max_usd:.2f} > daily cap ${a.daily_usd:.2f}")
        return 2

    client = anthropic.Anthropic(api_key=api_key(), max_retries=3)
    params = dict(
        model=model,
        max_tokens=16000,
        system=SYSTEM,
        thinking={"type": "adaptive"},
        output_config={"effort": a.effort},
        messages=[{"role": "user", "content": content}],
    )
    if model in ("claude-opus-5-5", "claude-sonnet-5-5"):
        params["betas"] = ["server-side-fallback-2026-07-01"]
        params["fallbacks"] = "default"
    try:
        with client.beta.messages.stream(**params) as stream:
            response = stream.get_final_message()
    except anthropic.RateLimitError as e:
        print(f"rate limited: {e.status_code}", file=sys.stderr)
        return 3
    except anthropic.APIStatusError as e:
        if "credit" in str(e).lower():
            print("out of API credits - tell main (inbox_main)", file=sys.stderr)
        else:
            print(f"api error {e.status_code}", file=sys.stderr)
        return 3
    except anthropic.APIConnectionError:
        print("connection error", file=sys.stderr)
        return 3

    usd, _ = turn_cost(model, response.usage)
    ledger = load_ledger()
    ledger[today] = round(float(ledger.get(today, 0.0)) + usd, 4)
    save_ledger(ledger)

    text = ""
    if response.stop_reason != "refusal":
        text = "\n".join(b.text for b in response.content if getattr(b, "type", "") == "text").strip()
    if not text:
        print(f"no answer: stop_reason={response.stop_reason}", file=sys.stderr)
        return 4
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    with open(a.out, "w", encoding="utf-8") as f:
        f.write(f"<!-- Claude API 검수 (GPT 대신) · {model} · effort {a.effort} · 약 ${usd:.3f} · 그림 {len(a.image)}장 -->\n\n")
        f.write(text + "\n")
    print(f"done: {a.out}  cost ~${usd:.3f}  today ${ledger[today]:.2f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
