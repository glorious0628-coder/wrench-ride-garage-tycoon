# wr-art 넘겨주기 (10-21)

## 한 일 (전부 Codex, verify_codex_art 확인, codex job은 build/codex_jobs/)
- 그림체 3안 → 사용자 B(둥근 캐주얼) 선택: art/concepts/style/
- 세단: 대표 시안 v3·엔진룸 위 시점(OK), 6면 v3(spec 우선 3D로 감), 폐차 상태 앞·뒤: art/concepts/car_sedan/
- 부품 6면 5장(바퀴·브레이크·배터리·라디에이터·머플러, OK): art/concepts/parts/
- 손 공구 3종 대표 시안 + 6면(OK): art/concepts/tools/
- UI 방향 3안(사용자 아침에 고름, 메인·GPT 추천 B): art/concepts/ui/
- 손님 NPC·정비사 7장(앞·뒤, OK): art/concepts/npc/
- SUV 대표 시안(OK) + 6면(spec 우선 3D): art/concepts/car_suv/
- 부품 상점 아이콘 15장(투명 PNG, OK): art/ui/icons/ (+ _check/icons_sheet.png)
- 사전 조사: notes/research/ref_sedan·ref_sedan_internals·ref_style·ref_tools·ref_ui·ref_npc·ref_suv·ref_icons·ref_wreck·ref_tow_truck (섞기 표 포함)

## 지금 상태
- **견인차(롤백) 대표 시안 v2 = 메인 검수 전**: art/concepts/tow_truck/tow_hero.png (v1은 _draft). 뒤가 탠덤 2축으로 나옴(F-550식 단축 이중 바퀴 아님), 캡 지붕은 경광등 막대 대신 표시등.
- 폐차 세단 앞·뒤: 메인 확인 전.
- 사용자 결정 기다림: UI 3안 중 하나. wr-design 확인 필요: SUV 길이(15.5 vs 16.6), 견인차 길이(30 vs 실제 31~34).

## 다음 할 일
1. 견인차 검수 결과 → 6면(세단 v3 축척 문장 처음부터).
2. UI 방향 정해지면 UI 그림, NPC 옷 텍스처(낮에, 메인 결론 notes/gpt/main/npc7_main_decision.md 지킬 점 3개).
3. 다음 손님 차(car_roster 순서: 픽업 → 배달 밴 → 해치백 → 미니밴 → 왜건).

## 주의할 점 (사용자 말 그대로)
- "자동차 뇌피셜 ㄴㄴ 무조건 자료 찾아서 디자인도 섞어야돼" — 실제 차 3~5대+ 조사 → 섞기 표.
- "내부 도안 같은 것도 다 보라고 해"
- "그림체는 캐주얼한 건데 부품도 캐주얼하게 생겼는데, 뭔 말인지 알지?"
- "일단은 소스 언어 영어로 할 거니까, 서양권 애들이 익숙한 걸루"
- 배운 것: 고칠 판은 같은 물건 ref로 넣으면 그대로 따라 그림 → `--style` ref로. 6면은 Codex가 위 뷰를 좁게 그림(세단 26%·SUV 20%) → 숫자 재서 보고, 더 그리지 말고 spec 우선 3D.
- 측정 스크립트(6면 칸 크기): scratchpad에 있었음 — 필요하면 tools/로 옮겨 달라고 메인에.
