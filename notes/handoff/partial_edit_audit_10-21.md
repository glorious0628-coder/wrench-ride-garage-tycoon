# 부분 수정 점검 (wr-art, 10-21) — 사용자: "부분 수정하면 그림이 울어", "지금까지 그렇게 한 거 있으면 싹 다시 그려"

방법: `build/codex_jobs/` 89개 잡 전부 — ① 넣은 ref가 '같은 물건'인지(`--style` 없이 → 도구가 "keep the same object … change only what the instructions say"를 붙임), ② Codex 세션이 만든 그림 수(`~/.codex/generated_images/<세션>/*.png`), ③ Codex 자기 설명("first render … I'm correcting …")을 읽음. 업로드 기록 = `art/roblox_assets.json`.
(Codex 기록엔 '편집 도구를 썼다'가 직접 찍히지 않아요. 아래 A·B는 **편집이었을 가능성이 높은 것**, C는 시점이 바뀐 새 그림이라 부분 수정으로 볼 수 없는 것.)

## A. 이전 그림을 넣고 '일부만 바꾸게' 한 것 (같은 시점·같은 물건) → 다시 그림
| 지금 그림 | 어떤 부분 수정이었나 | 업로드 |
|---|---|---|
| art/ui/badges/badge_silver.png | 금 배지를 넣고 "날개·별 빼고 은색으로" | **됨** (2026-10-21 10:24) |
| art/ui/badges/badge_bronze.png | 금 배지를 넣고 "날개·별·렌치 빼고 동색으로" | **됨** (10:23) |
| art/ui/kit_B/button_green_pressed.png | 평소 버튼을 넣고 "누른 모양만" | 안 됨 |
| art/ui/kit_B/button_red_pressed.png | 〃 | 안 됨 |
| art/ui/kit_B/tab_selected.png | 평소 탭을 넣고 "파랑만" | 안 됨 |
| art/ui/kit_B/slot_selected.png | 평소 칸을 넣고 "금색 테두리만" | 안 됨 |
| art/concepts/car_sedan/sedan_wreck_front.png | 대표 시안(같은 3/4 앞)을 넣고 "녹·먼지만 입혀" | 안 됨 |

## B. Codex가 잡 안에서 자기 첫 그림을 고친 것 ("first render … correcting") → 다시 그림
| 지금 그림 | Codex 설명 | 업로드 / 3D |
|---|---|---|
| art/concepts/car_sedan/sedan_hero.png (v3, OK판) | "first render carried over … correcting those" | 안 됨 / 세단 3D 기준 |
| art/concepts/parts/battery_6view.png | "added a molded plus symbol … I'll correct" (그림 3장) | 안 됨 / 배터리 3D 기준 |
| art/concepts/parts/radiator_6view.png | "front and back views are too large … correcting" | 안 됨 / 라디에이터 3D 기준 |
| art/concepts/tools/wrench_6view.png | "long views are too large … correcting" | 안 됨 / 렌치 3D 기준 |
| art/concepts/tools/obd_6view.png | "seven contacts per row … correcting … final size adjustment" (그림 3장) | 안 됨 / 스캐너 3D 기준 |
| art/concepts/murals/GP_MuralWest.png | "fifth letter reads like a B … correcting that letter" | 안 됨 |
| (art/concepts/ui/ui_C.png — 안 고른 안이라 다시 안 그림) | "correcting the screen framing" | — |

## C. 이전 그림은 디자인 참고로만 쓰고 **새 시점·새 그림**으로 그린 것 → 부분 수정 아님(다시 안 그림, 메인 판단)
- 아이콘 13장(art/ui/icons/: battery·tire·wheel·brake_pads·brake_disc·radiator·muffler·hood·front_bumper·rear_bumper·wrench·impact_wrench·obd_reader) — 6면·대표 시안을 넣고 3/4 아이콘 한 장으로 새로 그림(시점이 달라 덧칠 불가). 업로드 안 됨.
- 6면 시트: sedan_6view v3·suv_6view·impact_6view — 3/4 대표 시안을 넣고 6칸 정투영으로 새로 그림. (impact는 그림 1장, 고친 흔적 없음)
- sedan_wreck_rear.png v2 — 앞 폐차 그림을 넣고 3/4 뒤로 새로 그림.
- loading_bg.png v4 — 지시대로 v3를 ref로 '처음부터 새로' 그림(그림 1장, Codex: "redraw … as one new image").

## 앞으로 (모든 그림)
- 프롬프트 맨 앞에: "draw the WHOLE picture again as ONE brand-new image in a single pass; do NOT edit, inpaint, mask or paint over any attached picture, and do NOT fix your own first result by editing it — if it is wrong, generate the whole picture again".
- 제안(도구 주인 판단): `tools/codex_image.py`의 같은 물건 ref 문구 "change only what the instructions below say" → "draw it again from scratch as a new image, keeping this design" 로.

## 결과 1차 (10-21) — 13장 처음부터 다시 그림, 비교 시트 art/_redraw_old_1021/_check/old_vs_new_1021.png
- 모든 잡: Codex 설명이 "new image / from scratch"(편집 X). 그림 여러 장 나온 잡(버튼 초록 누름 3·폐차 앞 3·배터리 2·라디에이터 2)은 "generating a fresh whole image" = 통째로 다시.
- **통과 9장(지금 자리에 새 판)**: badge_silver·badge_bronze(업로드된 것 → 메인이 다시 올림), button_green_pressed·button_red_pressed·tab_selected·slot_selected, sedan_wreck_front, sedan_hero, GP_MuralWest. 세단·폐차·West는 옛 판과 거의 같음(평균 색 차 4.5~8/255).
- **6면 4장 = 비율이 바뀌어 3D와 어긋남 → 자리엔 옛 판을 되돌려 둠**(새 판은 art/_redraw_old_1021/_draft_new/):
  - battery 앞 W:H 1.35 → 1.14, radiator 1.68 → 1.36, wrench 옆 뷰 높이가 앞보다 큼(190 vs 117), obd 오른쪽 뷰 높이 494 vs 667.
  - 옛 판 각 뷰의 자리·크기(%)를 숫자로 적어 2차로 다시 그리는 중 → art/_redraw_old_1021/try2/.

## 결과 2차 (10-21) — 6면 4장, 옛 판 뷰별 자리·크기(%)를 숫자로 넣어 처음부터 (비교 _check/sheets_old_vs_try2.png)
| 시트 | 뷰별 가로:세로 변화(최대) | 전체 축척 | 결정 |
|---|---|---|---|
| battery_6view | 1% | ×1.00~1.02 | **새 판으로 교체** (job battery_6view_1792551062, 그림 1장) |
| radiator_6view | 4% | ×1.01~1.02 | **교체** (job …_1792551062, 첫 그림이 커서 '통째로 다시') |
| wrench_6view | 7% (옆 뷰 20px 막대) | ×0.98~1.07 | **교체** (job …_1792551062, '통째로 다시') |
| obd_6view | 51% (위·아래 뷰) | ×1.16~1.37 | **옛 판 유지**(3D 기준) — 새 판 _draft_new/obd_6view_try2_scale_changed.png. 옛 판은 Codex가 잡 안에서 고친 판(B)이라 남은 1장 |
