#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
ai_look_check.py - 우리 그림·글의 'AI 티' 점검 도우미 (읽기만 해요, 파일을 고치거나 지우지 않아요)

실행 (프로젝트 폴더에서, 새 venv의 파이썬으로 -I 와 같이):
  tools\\ai_check\\.venv\\Scripts\\python.exe -I tools\\ai_look_check.py images art\\ui
  tools\\ai_check\\.venv\\Scripts\\python.exe -I tools\\ai_look_check.py text src\\ReplicatedStorage\\Shared\\Locale.luau

images <폴더>   : 그림(PNG/JPG)마다
                  (a) c2patool  -> 파일 안에 C2PA 출처 표시(생성기·시각)가 있나 '기록'만 해요
                  (b) RapidOCR  -> 그림 속 글자를 읽고, 신뢰도 낮거나 말이 안 되는 단어면 '깨진 글자 의심'
text <파일>     : Locale.luau 의 영어 글, 또는 .md/.txt 속 영어 글을 뽑아서 dslop(AI 말버릇 규칙 검사기)로 검사

안전 규칙
  - C2PA 표시는 읽기만 해요 (c2patool 에 파일 경로만 줘요. 쓰기·지우기 옵션은 절대 안 써요).
  - 그림 파일은 열어서 읽기만 하고 다시 저장하지 않아요.
  - art/_bought, '_draft', '_rejected', 이름에 'pizza'가 들어간 것은 건너뛰어요 (팀 규칙).
  - 결과는 notes/ai_check/ 에 날짜 붙은 Markdown 보고서로 써요.

도구는 '보조 경보기'예요. 진짜 점검은 사람 눈: "게임 안 모습과 맞나", "실제 크기에서 읽히나".
"""
import argparse
import concurrent.futures
import datetime
import json
import math
import os
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent          # 프로젝트 폴더
AICHK = ROOT / "tools" / "ai_check"
C2PATOOL = AICHK / "c2patool" / "c2patool" / "c2patool.exe"   # zip 안에 c2patool/ 폴더가 한 겹 더 있어요
DSLOP = Path(sys.executable).parent / "dslop.exe"             # venv 의 Scripts 폴더
DSLOP_UI_CFG = AICHK / "dslop_ui.toml"
DSLOP_DOC_CFG = AICHK / "dslop_doc.toml"
ALLOWED_FILE = AICHK / "allowed_words.txt"
WORDS_FILE = AICHK / "words_en.txt"                           # 영어 단어 목록 (아래 README 참고)
REPORT_DIR = ROOT / "notes" / "ai_check"
LOCALE_EN = ROOT / "src" / "ReplicatedStorage" / "Shared" / "Locale.luau"

IMG_EXT = {".png", ".jpg", ".jpeg"}
# 팀 규칙: 이 폴더/이름은 어떤 도구에도 넣지 않아요
HARD_SKIP = {"_bought", "_draft", "_rejected"}
SOFT_SKIP = {"_check"}        # 우리가 만든 비교표·확대 모음(글씨가 파이썬으로 들어간 것) — --include-check 로 켤 수 있어요

LOW_CONF = 0.75     # 이 아래면 '신뢰도 낮음' -> 깨진 글자 의심
SOFT_CONF = 0.92    # 사전에 없는 단어가 있는데 신뢰도가 이 아래면 -> 깨진 글자 의심


def eprint(*a):
    print(*a, file=sys.stderr, flush=True)


def today():
    return datetime.date.today().isoformat()


# ---------------------------------------------------------------------------------------------
# 공통: 건너뛸 경로 판정
# ---------------------------------------------------------------------------------------------
def name_is_banned(name: str) -> bool:
    low = name.lower()
    return low in HARD_SKIP or low.startswith("_bought") or "pizza" in low


def path_has_banned_part(p: Path) -> bool:
    return any(name_is_banned(part) for part in p.parts)


def collect_images(folder: Path, max_depth, include_check):
    files, skipped_dirs, skipped_files = [], {}, []
    base_depth = len(folder.parts)
    for dirpath, dirnames, filenames in os.walk(folder):
        d = Path(dirpath)
        depth = len(d.parts) - base_depth
        keep = []
        for dn in sorted(dirnames):
            low = dn.lower()
            if name_is_banned(dn) or (low in SOFT_SKIP and not include_check):
                skipped_dirs[str((d / dn).relative_to(ROOT)).replace("\\", "/")] = True
                continue
            keep.append(dn)
        dirnames[:] = keep if (max_depth is None or depth < max_depth) else []
        for fn in sorted(filenames):
            if Path(fn).suffix.lower() in IMG_EXT and not name_is_banned(fn):
                if fn.startswith("_") and not include_check:   # _check_cards.png, _store_check.png 같은 우리가 만든 비교표
                    skipped_files.append(str((d / fn).relative_to(ROOT)).replace("\\", "/"))
                    continue
                files.append(d / fn)
    return files, sorted(skipped_dirs) + skipped_files


# ---------------------------------------------------------------------------------------------
# (a) c2patool — C2PA 출처 표시 읽기 (기록만)
# ---------------------------------------------------------------------------------------------
def c2pa_read(path: Path):
    """읽기 전용. 'c2patool <파일>' 한 가지 모양으로만 불러요."""
    try:
        r = subprocess.run([str(C2PATOOL), str(path)], capture_output=True, timeout=120, cwd=str(AICHK))
    except Exception as ex:  # noqa: BLE001
        return {"status": "error", "msg": f"실행 실패: {ex}"}
    out = r.stdout.decode("utf-8", "replace").strip()
    err = r.stderr.decode("utf-8", "replace").strip()
    if r.returncode == 0 and out.startswith("{"):
        try:
            j = json.loads(out)
        except ValueError:
            return {"status": "error", "msg": "JSON 읽기 실패"}
        return parse_c2pa(j)
    msg = (err or out).strip()
    low = msg.lower()
    if "no claim" in low or "no manifest" in low or "no c2pa" in low or "jumbf not found" in low:
        return {"status": "none"}
    return {"status": "error", "msg": msg[:120].replace("\n", " ")}


def parse_c2pa(j):
    am = j.get("active_manifest")
    mans = j.get("manifests") or {}
    m = mans.get(am) or (next(iter(mans.values())) if mans else {})
    gens = m.get("claim_generator_info") or []
    gen = gens[0].get("name") if gens and isinstance(gens[0], dict) else (m.get("claim_generator") or "?")
    sig = m.get("signature_info") or {}
    agent, version, when, src = None, None, None, None
    for a in m.get("assertions") or []:
        if str(a.get("label", "")).startswith("c2pa.actions"):
            for act in (a.get("data") or {}).get("actions") or []:
                if act.get("action") in ("c2pa.created", "c2pa.opened") and not agent:
                    sa = act.get("softwareAgent")
                    if isinstance(sa, dict):
                        agent, version = sa.get("name"), sa.get("version")
                    elif isinstance(sa, str):
                        agent = sa
                    when = act.get("when") or when
                    dst = act.get("digitalSourceType")
                    if dst:
                        src = str(dst).rstrip("/").split("/")[-1]
    codes = [v.get("code", "") for v in (j.get("validation_status") or [])]
    modified = any(("mismatch" in c.lower()) for c in codes)
    return {
        "status": "has",
        "generator": gen,
        "issuer": sig.get("issuer"),
        "agent": agent,
        "version": version,
        "when": (when or sig.get("time") or "")[:10],
        "source": src,
        "n_manifests": len(mans),
        "codes": sorted(set(codes)),
        "modified_after_sign": modified,
    }


def c2pa_label(c):
    if c is None:
        return "(건너뜀)"
    if c["status"] == "none":
        return "없음"
    if c["status"] == "error":
        return "오류: " + c.get("msg", "")
    bits = [c.get("generator") or "?"]
    ag = " ".join(x for x in [c.get("agent"), c.get("version")] if x)
    if ag:
        bits.append(ag)
    if c.get("source"):
        bits.append(c["source"])
    if c.get("when"):
        bits.append(c["when"])
    s = "있음: " + " / ".join(bits)
    if c.get("modified_after_sign"):
        s += " (서명 뒤 바뀜?)"
    return s


# ---------------------------------------------------------------------------------------------
# (b) RapidOCR + 깨진 글자 의심 판정
# ---------------------------------------------------------------------------------------------
HANGUL = re.compile(r"[\u3131-\u318E\uAC00-\uD7A3]")
CJK = re.compile(r"[\u3040-\u30FF\u3400-\u4DBF\u4E00-\u9FFF\uAC00-\uD7A3\u3131-\u318E]")
VOWELS = set("aeiouy")
IMPOSSIBLE = ("qx", "qz", "qj", "jq", "jx", "jz", "vq", "vx", "vj", "wq", "wx", "xz", "zx", "zq", "fq", "gq", "kq", "pq", "bq", "cj", "cx", "dx", "hx", "kx", "mx", "px", "sx", "tx", "yx", "vv", "ww", "wv", "vw")
CONTRACTION = {"s", "t", "re", "ll", "ve", "d", "m"}


def load_vocab(extra_text_blobs=()):
    vocab = set()
    if WORDS_FILE.exists():
        vocab |= {w.strip().lower() for w in WORDS_FILE.read_text(encoding="utf-8").splitlines() if w.strip()}
    if ALLOWED_FILE.exists():
        for ln in ALLOWED_FILE.read_text(encoding="utf-8").splitlines():
            ln = ln.strip().lower()
            if ln and not ln.startswith("#"):
                vocab.add(ln)
    # 게임 글(Locale.en)에 나온 단어는 '우리가 쓴 말'이라 사전에 있다고 쳐요
    try:
        for _, val in parse_locale_en(LOCALE_EN):
            for w in re.findall(r"[A-Za-z]+", val):
                vocab.add(w.lower())
    except Exception:  # noqa: BLE001
        pass
    for blob in extra_text_blobs:
        for w in re.findall(r"[A-Za-z]+", blob):
            vocab.add(w.lower())
    return vocab


def in_vocab(lw, vocab):
    if lw in vocab:
        return True
    for suf, repl in (("s", ""), ("es", ""), ("ies", "y"), ("ed", ""), ("ed", "e"), ("ing", ""), ("ing", "e"), ("er", ""), ("ers", ""), ("ly", ""), ("y", "")):
        if lw.endswith(suf) and len(lw) - len(suf) >= 3:
            stem = lw[: -len(suf)] + repl
            if stem in vocab:
                return True
    # 같은 자음이 겹친 꼴 (stopped, running)
    m = re.match(r"^(.*?)(.)\2(ed|ing|er|ers|y)$", lw)
    if m and (m.group(1) + m.group(2)) in vocab:
        return True
    return False


def split_camel(w):
    return [p for p in re.findall(r"[A-Z]+(?![a-z])|[A-Z][a-z]*|[a-z]+", w) if p]


def classify_word(w, vocab):
    """None=괜찮음 / ('strong', 이유) = 말이 안 됨 / ('weak', 이유) = 사전에 없지만 읽을 수는 있음"""
    lw = w.lower()
    if len(lw) < 2:
        return None
    if lw in vocab or in_vocab(lw, vocab):
        return None
    # 대문자·소문자가 안쪽에서 섞인 꼴 (WrEnch, GarAge / 붙여 쓴 WrenchoRide)
    if re.search(r"[a-z][A-Z]", w):
        parts = split_camel(w)
        if len(parts) >= 2 and all(len(p) >= 3 for p in parts):
            res = [classify_word(p, vocab) for p in parts]
            res = [r for r in res if r]
            if not res:
                return None
            return sorted(res, key=lambda r: r[0] != "strong")[0]
        return ("strong", "대소문자 섞임")
    if len(lw) >= 3 and not (set(lw) & VOWELS):
        return ("strong", "모음 없음")
    if re.search(r"[bcdfghjklmnpqrstvwxz]{5,}", lw):
        return ("strong", "자음이 5개 넘게 이어짐")
    if re.search(r"(.)\1\1", lw):
        return ("strong", "같은 글자 3번 이어짐")
    for bg in IMPOSSIBLE:
        if bg in lw:
            return ("strong", f"영어에 없는 글자 짝 '{bg}'")
    if len(lw) >= 3 and sum(1 for ch in lw if ch in VOWELS) / len(lw) > 0.8:
        return ("strong", "모음만 많음")
    return ("weak", "사전에 없음")


BRAND_FORMS = ("wrenchride", "garagetycoon", "gearport")   # 우리 로고·마을 이름: OCR이 &(톱니바퀴 모양)를 못 읽어 'WrenchoRide'처럼 나와요


def brand_like(w):
    import difflib
    lw = re.sub(r"[^a-z]", "", w.lower())
    if len(lw) < 6:
        return None
    for b in BRAND_FORMS:
        if lw != b and difflib.SequenceMatcher(None, lw, b).ratio() >= 0.84:
            return b
    return None


def near_miss(lw, vocab):
    """사전에 없는 단어가 사전 단어와 한 글자(바뀜·빠짐·더함·자리바뀜)만 다르면 그 낱말을 돌려줘요 (예 garagge -> garage)"""
    if not (4 <= len(lw) <= 12) or not lw.isalpha():
        return None
    letters = "abcdefghijklmnopqrstuvwxyz"
    splits = [(lw[:i], lw[i:]) for i in range(len(lw) + 1)]
    cands = set()
    for a, b in splits:
        if b:
            cands.add(a + b[1:])                                   # 빠짐
        if len(b) > 1:
            cands.add(a + b[1] + b[0] + b[2:])                     # 자리바뀜
        for c in letters:
            if b:
                cands.add(a + c + b[1:])                           # 바뀜
            cands.add(a + c + b)                                   # 더함
    cands = [c for c in cands if len(c) >= 4 and c in vocab and c != lw]
    if not cands:
        return None
    cands.sort(key=lambda c: (c[0] != lw[0], c))                    # 첫 글자가 같은 것을 먼저 (OCR은 첫 글자는 덜 틀려요)
    return "/".join(cands[:3])


def pos_ko(pos):
    if not pos:
        return ""
    x, y = pos
    h = "왼쪽" if x < 0.34 else ("오른쪽" if x > 0.66 else "가운데")
    v = "위" if y < 0.34 else ("아래" if y > 0.66 else "가운데")
    return f" [{v} {h}]" if (h, v) != ("가운데", "가운데") else " [한가운데]"


TOKEN_RE = re.compile(r"[A-Za-z]+(?:'[A-Za-z]+)?|[A-Za-z0-9]+")


def words_of(text):
    out = []
    for t in TOKEN_RE.findall(text):
        if "'" in t:
            a, b = t.split("'", 1)
            out.append(a)
            if b.lower() not in CONTRACTION:
                out.append(b)
        else:
            out.append(t)
    return out


def judge_ocr_lines(lines, vocab):
    """lines = [(text, score, pos)] -> (verdict, [flag 문장], [참고 문장])"""
    flags, notes = [], []
    for txt, sc, pos in lines:
        t = txt.strip()
        where = pos_ko(pos)
        alnum = re.sub(r"[^A-Za-z0-9\u3131-\u318E\uAC00-\uD7A3\u4E00-\u9FFF]", "", t)
        if len(alnum) <= 2:
            continue                                  # 'O' 같은 한두 글자 조각은 무늬를 글자로 잘못 읽은 것이 많아서 건너뜀
        if CJK.search(t):
            notes.append(f"비영어(한글·한자) 글자로 읽힘 '{t[:30]}'{where} - 눈으로 확인 (OCR은 영어 중심)")
            continue
        if sc < LOW_CONF:
            flags.append(f"신뢰도 낮음 {sc:.2f} '{t[:40]}'{where}" + (" (짧은 조각이라 무늬를 글자로 읽은 것일 수도)" if len(alnum) <= 4 else ""))
        for w in words_of(t):
            if re.fullmatch(r"\d+[A-Za-z]{0,2}|[A-Za-z]{1,2}\d+", w):
                continue                              # 3D, 4WD, V8, 2x
            if re.search(r"[A-Za-z]", w) and re.search(r"\d", w):
                flags.append(f"숫자·글자 섞임 '{w}'")
                continue
            c = classify_word(w, vocab)
            if not c:
                continue
            kind, why = c
            bl = brand_like(w)
            if bl:
                notes.append(f"'{w}'{where}는 이름 글자 '{bl}'와 거의 같아요 (로고의 &를 못 읽은 OCR 오독일 수 있음) - 로고 모양은 눈으로 확인")
            elif kind == "strong":
                flags.append(f"의심 단어 '{w}' ({why}, 신뢰도 {sc:.2f}){where}")
            elif sc < SOFT_CONF:
                flags.append(f"사전에 없는 단어 '{w}' (신뢰도 {sc:.2f}){where}")
            elif near_miss(w.lower(), vocab):
                flags.append(f"철자가 틀린 것 같은 단어 '{w}' (비슷한 낱말: {near_miss(w.lower(), vocab)}, 신뢰도 {sc:.2f}){where}")
            else:
                notes.append(f"사전에 없는 단어 '{w}' (신뢰도 {sc:.2f}){where} - 진짜 낱말인지 눈으로 확인")
    if flags:
        verdict = "깨진 글자 의심"
    elif notes:
        verdict = "확인 필요(참고)"
    elif any(len(re.sub(r"[^A-Za-z0-9]", "", t)) > 2 for t, _, _ in lines):
        verdict = "OK"
    else:
        verdict = "글자 없음"
    return verdict, flags, notes


class OcrRunner:
    def __init__(self):
        import numpy as np  # noqa: F401
        from PIL import Image  # noqa: F401
        from rapidocr import RapidOCR
        self.engine = RapidOCR(params={"Global.log_level": "error", "Global.text_score": 0.3})

    def _prep(self, im, bg):
        from PIL import Image
        import numpy as np
        rgba = im.convert("RGBA")
        base = Image.new("RGBA", rgba.size, bg + (255,))
        base.alpha_composite(rgba)
        rgb = base.convert("RGB")
        w, h = rgb.size
        m = max(w, h)
        if m < 480:                                   # 작은 아이콘은 글자가 너무 작아서 키워 읽어요 (OCR 입력만, 파일은 그대로)
            k = min(4, math.ceil(512 / m))
            rgb = rgb.resize((w * k, h * k), Image.LANCZOS)
        return np.array(rgb)

    def read(self, path: Path):
        from PIL import Image
        import numpy as np
        with Image.open(path) as im:
            im.load()
            size = im.size
            rgba = im.convert("RGBA")
        alpha = np.array(rgba.getchannel("A"))
        transp = float((alpha < 250).mean())
        tries = [(255, 255, 255)]
        if transp > 0.05:
            tries.append((36, 36, 36))                # 투명한 그림은 어두운 바탕에서도 한 번 더 (흰 글자 대비)
        best = None
        for bg in tries:
            arr = self._prep(rgba, bg)
            res = self.engine(arr)
            txts = list(res.txts) if getattr(res, "txts", None) is not None else []
            scs = [float(s) for s in res.scores] if getattr(res, "scores", None) is not None else []
            boxes = getattr(res, "boxes", None)
            poss = []
            for i in range(len(txts)):
                try:
                    b = np.array(boxes[i], dtype=float)
                    poss.append((float(b[:, 0].mean()) / arr.shape[1], float(b[:, 1].mean()) / arr.shape[0]))
                except Exception:  # noqa: BLE001
                    poss.append(None)
            lines = list(zip(txts, scs, poss))
            weight = sum(len(t) * s for t, s, _ in lines)
            if best is None or weight > best[0]:
                best = (weight, lines, bg)
        return size, transp, best[1]


# ---------------------------------------------------------------------------------------------
# images 모드
# ---------------------------------------------------------------------------------------------
def md_cell(s):
    return str(s).replace("|", "\\|").replace("\n", " ")


def human_size(n):
    return f"{n/1024:.0f} KB" if n < 1024 * 1024 else f"{n/1024/1024:.1f} MB"


def versions():
    v = {}
    try:
        r = subprocess.run([str(C2PATOOL), "--version"], capture_output=True, timeout=30)
        v["c2patool"] = r.stdout.decode("utf-8", "replace").strip()
    except Exception:  # noqa: BLE001
        v["c2patool"] = "?"
    try:
        from importlib.metadata import version
        v["rapidocr"] = version("rapidocr")
        v["onnxruntime"] = version("onnxruntime")
        v["dslop"] = version("dslop")
    except Exception:  # noqa: BLE001
        pass
    return v


def cmd_images(args):
    folder = (ROOT / args.folder).resolve() if not Path(args.folder).is_absolute() else Path(args.folder).resolve()
    if not folder.is_dir():
        eprint("폴더가 없어요:", folder)
        return 2
    if path_has_banned_part(folder):
        eprint("이 폴더는 팀 규칙(_bought·_draft·_rejected·Pizza Doggy)이라 검사하지 않아요:", folder)
        return 2
    files, skipped_dirs = collect_images(folder, args.max_depth, args.include_check)
    if args.limit:
        files = files[: args.limit]
    rel = lambda p: str(p.relative_to(ROOT)).replace("\\", "/") if ROOT in p.parents else str(p)  # noqa: E731
    print(f"그림 {len(files)}장 검사 시작 ({rel(folder)})", flush=True)
    t0 = time.time()

    # (a) C2PA — 여러 개 동시에
    c2 = {}
    if not args.no_c2pa:
        if not C2PATOOL.exists():
            eprint("c2patool을 못 찾았어요:", C2PATOOL)
            return 2
        with concurrent.futures.ThreadPoolExecutor(max_workers=6) as ex:
            futs = {ex.submit(c2pa_read, p): p for p in files}
            for f in concurrent.futures.as_completed(futs):
                c2[futs[f]] = f.result()
        print(f"  c2patool 끝 ({time.time()-t0:.0f}초)", flush=True)

    # (b) OCR — 하나씩
    vocab = load_vocab()
    rows = []
    ocr = None
    if not args.no_ocr:
        ocr = OcrRunner()
    for i, p in enumerate(files, 1):
        row = {"path": p, "size_bytes": p.stat().st_size, "c2pa": c2.get(p), "dims": None, "lines": None,
               "verdict": "(OCR 건너뜀)", "flags": [], "notes": [], "err": None}
        if ocr:
            try:
                dims, transp, lines = ocr.read(p)
                row["dims"] = dims
                row["lines"] = lines
                row["verdict"], row["flags"], row["notes"] = judge_ocr_lines(lines, vocab)
            except Exception as ex:  # noqa: BLE001
                row["verdict"] = "OCR 오류"
                row["err"] = str(ex)[:100]
        rows.append(row)
        if i % 20 == 0 or i == len(files):
            print(f"  OCR {i}/{len(files)} ({time.time()-t0:.0f}초)", flush=True)

    write_images_report(args, folder, rows, skipped_dirs, time.time() - t0, rel)
    return 0


def write_images_report(args, folder, rows, skipped_dirs, secs, rel):
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    slug = re.sub(r"[^A-Za-z0-9]+", "-", rel(folder)).strip("-").lower() or "root"
    out = Path(args.out) if args.out else REPORT_DIR / f"images_{slug}_{today()}.md"
    n = len(rows)
    has = [r for r in rows if r["c2pa"] and r["c2pa"]["status"] == "has"]
    err = [r for r in rows if r["c2pa"] and r["c2pa"]["status"] == "error"]
    gens = {}
    for r in has:
        c = r["c2pa"]
        key = f'{c.get("generator")} ({c.get("agent") or "-"} {c.get("version") or ""})'.strip()
        gens[key] = gens.get(key, 0) + 1
    bad = [r for r in rows if r["verdict"] == "깨진 글자 의심"]
    maybe = [r for r in rows if r["verdict"] == "확인 필요(참고)"]
    ok = [r for r in rows if r["verdict"] == "OK"]
    notext = [r for r in rows if r["verdict"] == "글자 없음"]
    v = versions()

    L = []
    L.append(f"# AI 티 점검 - 그림 `{rel(folder)}` ({today()})")
    L.append("")
    L.append(f"- 도구: {v.get('c2patool','?')} · RapidOCR {v.get('rapidocr','?')} (onnxruntime {v.get('onnxruntime','?')}) · 스크립트 `tools/ai_look_check.py images`")
    L.append(f"- 걸린 시간 {secs:.0f}초. **읽기만 했어요** (그림·C2PA 표시를 고치거나 지우지 않음).")
    if skipped_dirs:
        L.append(f"- 건너뛴 폴더·파일({len(skipped_dirs)}): " + ", ".join(f"`{d}`" for d in skipped_dirs[:12]) + (" ..." if len(skipped_dirs) > 12 else ""))
    L.append("")
    L.append("## 요약")
    L.append("")
    L.append(f"- 검사한 그림 **{n}장**")
    if not args.no_c2pa:
        L.append(f"- C2PA 출처 표시 **있음 {len(has)}장** / 없음 {n-len(has)-len(err)}장" + (f" / 오류 {len(err)}장" if err else ""))
        for k, c in sorted(gens.items(), key=lambda x: -x[1]):
            L.append(f"  - {k}: {c}장")
        mod = [r for r in has if r["c2pa"].get("modified_after_sign")]
        if mod:
            L.append(f"  - 표시는 있는데 서명 뒤에 그림이 바뀐 것으로 보이는 파일: {len(mod)}장")
        L.append("  - (표시가 **없다**고 해서 AI가 아니라는 뜻은 아니에요: 고치거나 리사이즈하거나 캡처하면 표시가 없어져요. 있음 = 'GPT 원본 그대로'라는 사실 기록일 뿐이에요.)")
    if not args.no_ocr:
        L.append(f"- 글자 검사: **깨진 글자 의심 {len(bad)}장** · 확인 필요(참고) {len(maybe)}장 · OK {len(ok)}장 · 글자 없음(그림에 글자가 없거나 OCR이 못 읽음) {len(notext)}장")
    L.append("")

    def table(rs):
        T = ["| 파일 | 크기 | C2PA | OCR이 읽은 글자 (신뢰도) | 판정 / 이유 |", "|---|---|---|---|---|"]
        for r in rs:
            txt = "; ".join(f"{t.strip()[:36]} ({s:.2f})" for t, s, _p in (r["lines"] or []) if len(t.strip()) > 0)[:200] or "-"
            why = r["verdict"]
            det = r["flags"] + r["notes"]
            if r["err"]:
                det.append(r["err"])
            if det:
                why += ": " + " / ".join(det[:4]) + (" ..." if len(det) > 4 else "")
            dims = f'{r["dims"][0]}x{r["dims"][1]}' if r["dims"] else "?"
            T.append(f'| `{md_cell(rel(r["path"]))}` | {dims}, {human_size(r["size_bytes"])} | {md_cell(c2pa_label(r["c2pa"]))} | {md_cell(txt)} | {md_cell(why)} |')
        return T

    if not args.no_ocr:
        L.append("## 깨진 글자 의심 (먼저 눈으로 볼 것)")
        L.append("")
        if bad:
            L += table(bad)
        else:
            L.append("없음.")
        L.append("")
        if maybe:
            L.append("## 확인 필요 (참고 - 사전에 없는 단어, 신뢰도는 높음)")
            L.append("")
            L += table(maybe)
            L.append("")
    L.append("## 전체 표")
    L.append("")
    L += table(rows)
    L.append("")
    L.append("## 읽는 법과 한계")
    L.append("")
    L.append("- **깨진 글자 의심** = OCR 신뢰도가 낮거나(<%.2f), 모음 없음·이상한 글자 짝 같은 '말이 안 되는 단어'가 있다는 뜻이에요. 꾸민 글씨체·비스듬한 글자는 사람은 읽어도 OCR이 못 읽어서 **오탐**이 많아요." % LOW_CONF)
    L.append("- **글자 없음**이 '안전'은 아니에요: 글자가 너무 망가졌거나 작아서 OCR이 아예 못 읽은 경우도 이렇게 나와요. 글자가 있어야 하는 그림(간판·썸네일·로고)은 직접 보세요.")
    L.append("- 진짜 기준은 도구가 아니라 사람 점검이에요: 손 확대, 게임 안 모습과 맞는지, 실제 크기에서 읽히는지.")
    out.write_text("\n".join(L) + "\n", encoding="utf-8")

    print("")
    print(f"== 요약 ({rel(folder)}) ==")
    print(f"그림 {n}장 | C2PA 있음 {len(has)} | 깨진 글자 의심 {len(bad)} | 참고 {len(maybe)} | OK {len(ok)} | 글자 없음 {len(notext)}")
    for r in bad[:10]:
        print(f"  - {rel(r['path'])}: " + " / ".join(r["flags"][:2]))
    print("보고서:", rel(out))


# ---------------------------------------------------------------------------------------------
# text 모드 (dslop)
# ---------------------------------------------------------------------------------------------
RULE_KO = {
    "em-dash": "줄표(—)를 썼어요 (AI 글에 흔함) - 쉼표나 두 문장으로",
    "double-hyphen": "' -- ' 줄표 대용 - 쉼표나 두 문장으로",
    "contrastive": "'it's not X, it's Y' 꼴 - 무엇인지 바로 말하기",
    "demonstrative-is": "'This is ...' 식 지시어 + is 로 시작하는 풀이",
    "filler-adverbs": "군더더기 부사 (quietly, actually, really, simply, essentially ...) - 빼거나 구체적으로",
    "weasel-connectives": "얼버무리는 연결말 (which means, in turn ...)",
    "banned-flourish": "상투적 꾸밈말 (worth noting, to be clear, at the end of the day ...)",
    "banned-negation": "'not'/\"n't\" 사용 (엄격 규칙, 기본 꺼 둠)",
    "negation-pair": "'not X, not Y' 부정 짝",
    "symmetric-negation": "'not X but Y' / 'fine if X, wrong if Y' 대칭 부정",
    "which-chain": "한 문장에 which 3번 이상",
    "but-opener": "짧은 문장을 'But'으로 시작",
    "aphorism": "'X does not Y.' 식 한 줄 격언",
    "summary-capstone": "문단 끝 'That is the X.' 식 마무리 한 줄",
    "declarative-callback": "문단 끝 단편 되받기 문장",
    "three-beat": "짧은 문장 3개 연속 (리듬이 군더더기처럼 읽힘) - 두 개를 합치기",
    "sentence-length-cv": "문장 길이가 너무 일정함 (긴 글 통계)",
    "sentence-length-kurtosis": "문장 길이 분포가 너무 밋밋함 (긴 글 통계)",
    "word-freq-dispersion": "단어 분포가 너무 고름 (긴 글 통계)",
}
ANSI = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")
VIOL = re.compile(r"^\s*(\S+?):(\d+):(\d+)\s+([a-z0-9-]+)\s*$")
METRIC = re.compile(r"^\s*(\S+)\s+([a-z0-9-]+)=([-\d.]+)\s*\(threshold\s*([-\d.]+)\)")


def run_dslop(text: str, cfg: Path):
    env = dict(os.environ)
    env["NO_COLOR"] = "1"
    r = subprocess.run([str(DSLOP), "-c", str(cfg), "-"], input=text.encode("utf-8"), capture_output=True, timeout=300, env=env, cwd=str(AICHK))
    out = ANSI.sub("", (r.stdout.decode("utf-8", "replace") + "\n" + r.stderr.decode("utf-8", "replace")))
    viol, metrics = [], []
    for ln in out.splitlines():
        m = VIOL.match(ln)
        if m:
            viol.append((int(m.group(2)), int(m.group(3)), m.group(4)))
            continue
        m = METRIC.match(ln)
        if m:
            metrics.append((m.group(2), float(m.group(3)), float(m.group(4))))
    return viol, metrics, r.returncode


def dslop_config_selftest(cfg: Path):
    """dslop 은 설정 파일이 틀리면 조용히 기본 규칙으로 돌아가요. 'banned-negation = false' 가 먹혔는지 확인."""
    if "banned-negation = false" not in cfg.read_text(encoding="utf-8"):
        return True
    viol, _, _ = run_dslop("I do not know. We can't go.\n", cfg)
    return not any(v[2] == "banned-negation" for v in viol)


def unescape_lua(s):
    return re.sub(r"\\(.)", lambda m: {"n": "\n", "t": " ", "\\": "\\", '"': '"', "'": "'"}.get(m.group(1), m.group(1)), s)


LOC_LINE = re.compile(r'^\s*\["(?P<key>[^"]+)"\]\s*=\s*(?:"(?P<val>(?:[^"\\]|\\.)*)"|\'(?P<val2>(?:[^\'\\]|\\.)*)\')\s*,?\s*(?:--.*)?$')


def parse_locale_en(path: Path):
    """Locale.luau 의 Locale.en = { ... } 안의 ["키"] = "값" 만. 반환: [(키, 값)]"""
    return [(k, v) for k, v, _ in parse_locale_en_ln(path)]


def parse_locale_en_ln(path: Path):
    """위와 같고 줄 번호까지: [(키, 값, 줄번호)]"""
    out = []
    inside = False
    for lineno, ln in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not inside:
            if re.match(r"^\s*Locale\.en\s*=\s*\{", ln):
                inside = True
            continue
        if ln.startswith("}"):
            break
        m = LOC_LINE.match(ln)
        if m:
            v = m.group("val") if m.group("val") is not None else m.group("val2")
            out.append((m.group("key"), unescape_lua(v), lineno))
    return out


def clean_ui_string(s):
    s = re.sub(r"<[^>]+>", "", s)               # 색 태그 <font ...>
    s = re.sub(r"\{\w+\}", "X", s)               # {part} 같은 빈칸
    return re.sub(r"\s+", " ", s).strip()


def extract_md_english(text):
    """.md/.txt 에서 영어 글을 뽑아요. 반환: [(줄번호들, 문자열)] 문단 단위"""
    lines = text.splitlines()
    items = []   # (lineno, string, is_bullet)
    in_code = False
    for i, raw in enumerate(lines, 1):
        s = raw.strip()
        if s.startswith("```"):
            in_code = not in_code
            continue
        if in_code or not s:
            continue
        t = re.sub(r"^[>\s]+", "", s)
        bullet = bool(re.match(r"^([-*+]|\d+\.)\s+", t))
        t = re.sub(r"^([-*+]|\d+\.)\s+", "", t)
        t = t.replace("**", "").replace("__", "").replace("`", "")
        quotes_src = s
        if t.startswith("#") or t.startswith("|") or HANGUL.search(t):
            for m in re.finditer(r'"([^"\n]{10,}?)"|\u201c([^\u201d\n]{10,}?)\u201d', quotes_src.replace("**", "")):
                q = (m.group(1) or m.group(2) or "").strip()
                if q and not HANGUL.search(q) and len(q.split()) >= 2 and re.search(r"[A-Za-z]{3}", q):
                    items.append((i, q, True))
            continue
        if len(re.findall(r"[A-Za-z]", t)) >= 12 and len(t.split()) >= 3 and not t.startswith(("http", "![")):
            items.append((i, t, bullet))
    paras = []
    for ln_no, s, bullet in items:
        if paras and not bullet and paras[-1]["last"] == ln_no - 1 and not paras[-1]["quote"]:
            paras[-1]["text"] += " " + s
            paras[-1]["lines"].append(ln_no)
            paras[-1]["last"] = ln_no
        else:
            paras.append({"lines": [ln_no], "text": s, "last": ln_no, "quote": False})
    return [(p["lines"], p["text"]) for p in paras]


def cmd_text(args):
    path = (ROOT / args.file).resolve() if not Path(args.file).is_absolute() else Path(args.file).resolve()
    if not path.is_file():
        eprint("파일이 없어요:", path)
        return 2
    if path_has_banned_part(path):
        eprint("이 파일은 팀 규칙(_bought·Pizza Doggy 등)이라 검사하지 않아요:", path)
        return 2
    if not DSLOP.exists():
        eprint("dslop 을 못 찾았어요 (새 venv의 python 으로 실행해야 해요):", DSLOP)
        return 2
    rel = lambda p: str(p.relative_to(ROOT)).replace("\\", "/") if ROOT in p.parents else str(p)  # noqa: E731
    raw = path.read_text(encoding="utf-8")
    ext = path.suffix.lower()

    # 1) 영어 글 뽑기
    if ext == ".luau" or ext == ".lua":
        triples = parse_locale_en_ln(path)
        pairs = [(f"{k} (줄 {n})", v) for k, v, n in triples]
        if not pairs:
            for i, ln in enumerate(raw.splitlines(), 1):
                for m in re.finditer(r'"((?:[^"\\]|\\.)+)"', ln):
                    v = unescape_lua(m.group(1))
                    if len(v.split()) >= 3 and re.search(r"[A-Za-z]{3}", v):
                        pairs.append((f"줄 {i}", v))
        if pairs and sum(1 for _, v in pairs if HANGUL.search(v)) > len(pairs) * 0.3:
            eprint("한국어 글이 많은 파일이에요. dslop은 영어 전용이라 한국어는 검사하지 않아요:", rel(path))
            return 2
        units = [(k, v, clean_ui_string(v)) for k, v in pairs]
        units = [(k, v, c) for k, v, c in units if re.search(r"[A-Za-z]{2}", c)]
        mode = "ui"
        skipped_note = (f"`Locale.en` 안의 `[\"키\"] = \"값\"` {len(pairs)}개를 읽고, 그중 영어 글자가 있는 {len(units)}개를 검사했어요"
                        f" (빈칸만 있는 `{{money}}` 같은 글은 뺌).")
    else:
        paras = extract_md_english(raw)
        units = [(f"줄 {lines[0]}" + (f"-{lines[-1]}" if len(lines) > 1 else ""), t, t) for lines, t in paras]
        mode = "doc"
        skipped_note = f"한글이 섞이지 않은 줄 + 따옴표 안의 영어 문장 {len(units)}덩이를 뽑았어요 (한국어는 dslop이 못 읽어서 제외)."

    if not units:
        eprint("검사할 영어 글을 못 찾았어요.")
        return 2

    # 2) dslop — 한 번에: 글 하나 = 한 문단 (빈 줄로 나눔)
    cfg_ok = dslop_config_selftest(DSLOP_UI_CFG)
    body = "\n\n".join(c for _, _, c in units) + "\n"
    viol, _, _ = run_dslop(body, DSLOP_UI_CFG)
    # 줄 번호 -> 글 번호 (글 하나 = 한 줄 + 빈 줄)
    flagged = {}
    for ln, col, rule in viol:
        idx = (ln - 1) // 2
        if 0 <= idx < len(units):
            flagged.setdefault(idx, []).append(rule)

    # 3) 통계 항목 (글 전체) — 긴 글에서만 뜻이 있어요
    words_total = sum(len(c.split()) for _, _, c in units)
    metric_lines = []
    if mode == "doc":
        _, metrics, _ = run_dslop(body, DSLOP_DOC_CFG)
        metric_lines = metrics
    cfg_doc_ok = dslop_config_selftest(DSLOP_DOC_CFG)

    write_text_report(args, path, rel, units, flagged, mode, skipped_note, words_total, metric_lines, cfg_ok and cfg_doc_ok)
    return 0


def write_text_report(args, path, rel, units, flagged, mode, skipped_note, words_total, metrics, cfg_ok):
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    slug = re.sub(r"[^A-Za-z0-9]+", "-", path.stem).strip("-").lower()
    out = Path(args.out) if args.out else REPORT_DIR / f"text_{slug}_{today()}.md"
    v = versions()
    L = []
    L.append(f"# AI 티 점검 - 글 `{rel(path)}` ({today()})")
    L.append("")
    L.append(f"- 도구: dslop {v.get('dslop','?')} (규칙 검사, 영어 전용) · 스크립트 `tools/ai_look_check.py text` · 설정 `tools/ai_check/dslop_ui.toml`")
    L.append(f"- {skipped_note}")
    L.append(f"- 글 {len(units)}개 (영어 {words_total}단어) 중 **걸린 글 {len(flagged)}개**")
    if not cfg_ok:
        L.append("- **경고**: dslop 설정 파일을 못 읽어서 기본 규칙(엄격)으로 돌았을 수 있어요. 설정 파일 문법을 확인하세요.")
    L.append("")
    L.append("## 걸린 글")
    L.append("")
    if flagged:
        L.append("| 위치(키) | 글 | 걸린 규칙 | 이유 |")
        L.append("|---|---|---|---|")
        for idx in sorted(flagged):
            k, orig, clean = units[idx]
            rules = []
            for r in flagged[idx]:
                if r not in rules:
                    rules.append(r)
            why = " / ".join(RULE_KO.get(r, r) for r in rules)
            L.append(f"| `{md_cell(k)}` | {md_cell(orig)[:260]} | {', '.join(rules)} | {md_cell(why)} |")
    else:
        L.append("없음.")
    L.append("")
    if mode == "doc":
        L.append("## 글 전체 통계 (참고)")
        L.append("")
        if words_total < 150:
            L.append(f"영어가 {words_total}단어뿐이라 문장 길이 통계는 믿을 수 없어요. 참고만 하세요.")
        if metrics:
            for name, val, thr in metrics:
                L.append(f"- {name} = {val:.2f} (기준 {thr:.2f}): {RULE_KO.get(name, '')}")
        else:
            L.append("- 통계 항목에는 안 걸렸어요.")
        L.append("")
    else:
        L.append("## 참고")
        L.append("")
        L.append("- 한 줄 UI 글은 문장 길이·단어 분포 같은 '통계 항목'이 뜻이 없어서 껐어요. 패턴 규칙(줄표·'not X, it's Y'·군더더기 부사·짧은 문장 3개 연속 등)만 봐요.")
        L.append("- 'not / n't' 금지 규칙은 UI 글(Can't ... / Not enough ...)에 너무 많이 걸려서 꺼 뒀어요 (`dslop_ui.toml`에서 켤 수 있어요).")
    L.append("")
    L.append("## 한계")
    L.append("")
    L.append("- dslop은 '규칙' 검사기예요. 걸렸다고 AI가 쓴 글이 아니고, 안 걸렸다고 사람 글도 아니에요. 한국 팀이 쓴 영어도 걸릴 수 있어요.")
    L.append("- 한국어 글은 못 검사해요. 한국어는 번역투 목록(~을 통해, ~에 대한, 보여집니다 ...)과 소리 내어 읽기로 봐요.")
    L.append("- 진짜 기준은 소리 내어 읽었을 때 광고 같지 않고, 한 문장에 한 동작인지예요.")
    out.write_text("\n".join(L) + "\n", encoding="utf-8")

    print("")
    print(f"== 요약 ({rel(path)}) ==")
    print(f"글 {len(units)}개(영어 {words_total}단어) | 걸린 글 {len(flagged)}개" + ("" if cfg_ok else " | (경고: dslop 설정 확인)"))
    for idx in sorted(flagged)[:10]:
        k, orig, _ = units[idx]
        print(f"  - [{k}] {orig[:70]}  -> {', '.join(sorted(set(flagged[idx])))}")
    if metrics:
        print("통계:", ", ".join(f"{n}={val:.2f}" for n, val, _ in metrics))
    print("보고서:", rel(out))


# ---------------------------------------------------------------------------------------------
def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:  # noqa: BLE001
        pass
    ap = argparse.ArgumentParser(description="우리 그림·글의 AI 티 점검 도우미 (읽기만 해요)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("images", help="폴더 속 PNG/JPG: C2PA 출처 표시 기록 + OCR 깨진 글자 의심")
    a.add_argument("folder")
    a.add_argument("--max-depth", type=int, default=None, help="하위 폴더 몇 단계까지 (0 = 그 폴더 바로 아래 파일만)")
    a.add_argument("--limit", type=int, default=0, help="앞에서 N장만")
    a.add_argument("--include-check", action="store_true", help="_check 폴더(우리가 만든 비교표)도 검사")
    a.add_argument("--no-c2pa", action="store_true")
    a.add_argument("--no-ocr", action="store_true")
    a.add_argument("--out", help="보고서 파일 경로 (기본: notes/ai_check/images_<폴더>_<날짜>.md)")
    a.set_defaults(fn=cmd_images)
    b = sub.add_parser("text", help="Locale.luau 또는 .md/.txt 의 영어 글을 dslop으로 검사")
    b.add_argument("file")
    b.add_argument("--out", help="보고서 파일 경로")
    b.set_defaults(fn=cmd_text)
    args = ap.parse_args()
    sys.exit(args.fn(args))


if __name__ == "__main__":
    main()
