"""Side-by-side check sheet for the mechanic moves (wr-anim): each row = the real reference (browser screenshot of a
search page, notes/research/ref_mech_motions/) next to our game shots (Play photos, notes/playtest/wr-anim/), the game
shots cropped to the phone's 844×390 shape. A layout tool only — it draws no art.

  py tools/anim/compare_sheet.py            -> notes/playtest/wr-anim/compare_sheet.jpg (+ phone/ crops)
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REF = os.path.join(ROOT, "notes", "research", "ref_mech_motions")
SHOTS = os.path.join(ROOT, "notes", "playtest", "wr-anim")
OUT = os.path.join(SHOTS, "compare_sheet.jpg")

ROWS = [
    ("엔진룸: 몸 숙이기 + 렌치 / 임팩트", "02_lean_engine_bay_sheet.jpg", ["01_bay_lean_wrench.jpg", "02_bay_impact.jpg"]),
    ("바퀴: 한쪽 무릎 + 임팩트 렌치", "01_kneel_impact_lugnuts_sheet.jpg", ["03_wheel_kneel_impact.jpg", "06_wheel_from_behind.jpg", "10_user_avatar_wheel.jpg"]),
    ("바퀴: 렌치 / 마지막 너트 딸깍", "06_torque_wrench_wheel_sheet.jpg", ["04_wheel_kneel_wrench.jpg", "05_torque_click.jpg"]),
    ("보닛: 걸쇠 → 들기 → 막대", "04_hood_prop_rod_sheet.jpg", ["07_hood_release.jpg", "08_hood_lift.jpg", "09_prop_rod.jpg"]),
    ("잭 펌프 · 운전석 페달 (기준 장면, 게임엔 아직 안 걸림)", "03_floor_jack_sheet.jpg", ["11_sandbox_jackpump.jpg", "12_sandbox_sit_pedal.jpg"]),
    ("(페달 참고)", "05_brake_pedal_foot_sheet.jpg", []),
]
PHONE = (844, 390)
CELL_H = 300


def font(size):
    for f in ("C:/Windows/Fonts/malgunbd.ttf", "C:/Windows/Fonts/malgun.ttf"):
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


def phone_crop(img):
    w, h = img.size
    th = int(w * PHONE[1] / PHONE[0])
    if th <= h:
        top = (h - th) // 2
        img = img.crop((0, top, w, top + th))
    return img.resize(PHONE, Image.LANCZOS)


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    os.makedirs(os.path.join(SHOTS, "phone"), exist_ok=True)
    f_title, f_lab = font(26), font(18)
    rows = []
    for title, ref, shots in ROWS:
        cells = []
        r = Image.open(os.path.join(REF, ref)).convert("RGB")
        r = r.resize((int(r.width * CELL_H / r.height), CELL_H), Image.LANCZOS)
        cells.append(("실제 (검색 화면)", r))
        for s in shots:
            p = Image.open(os.path.join(SHOTS, s)).convert("RGB")
            ph = phone_crop(p)
            ph.save(os.path.join(SHOTS, "phone", s))
            g = ph.resize((int(PHONE[0] * CELL_H / PHONE[1]), CELL_H), Image.LANCZOS)
            cells.append((s.split(".")[0], g))
        width = sum(c[1].width for c in cells) + 12 * (len(cells) + 1)
        row = Image.new("RGB", (width, CELL_H + 80), (245, 245, 245))
        d = ImageDraw.Draw(row)
        d.text((12, 8), title, fill=(20, 20, 20), font=f_title)
        x = 12
        for lab, c in cells:
            row.paste(c, (x, 44))
            d.text((x + 4, 44 + CELL_H + 6), lab, fill=(60, 60, 60), font=f_lab)
            x += c.width + 12
        rows.append(row)
    W = max(r.width for r in rows)
    H = sum(r.height for r in rows) + 8 * len(rows)
    sheet = Image.new("RGB", (W, H), (255, 255, 255))
    y = 0
    for r in rows:
        sheet.paste(r, (0, y))
        y += r.height + 8
    sheet.save(OUT, quality=88)
    print(OUT, sheet.size)


if __name__ == "__main__":
    main()
