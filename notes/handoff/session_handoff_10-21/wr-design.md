# wr-design 정리 (10-21, 세션 끝)

## 한 일
- 차 규격 → 재미 보강안·시대 차·고장 카탈로그(GPT 토론) → 경제·수익·알파·루프 B·재방문·차종·튜토리얼·경제 시뮬까지 설계 문서를 쓰고, carbook 검수와 메인 결정을 그때그때 반영. 바뀐 숫자는 전부 board.md로 wr-dev·3D에 알림.

## 문서 (버전)
| 파일 | 버전 | 내용 |
|---|---|---|
| docs/specs/car_spec.md | **v0.8** | 세단 규격(높이선 B, 바퀴 2.75, 깊어진 엔진룸, 배터리 방향 Y −90°, 뒤 Shock/Spring 분리, 근거 §9) |
| docs/specs/suv_spec.md | v0.1 | SUV = 세단과 다른 것만(16.6 × 7.7 × 6.6, 엔진룸 = 세단 + (0, +0.5, +0.15)) |
| docs/design/fault_catalog.md | v0.4 | 고장(출처 확인 + carbook 검수 9건) |
| docs/design/fun_boost.md | v0.2 | 재미 보강안 18개(GPT 2라운드) |
| docs/design/era_cars.md | v0.2 | 시대 차 12개(실제 차 조사·링크 확인) |
| docs/design/economy.md | **v0.3** | 레벨 = 평판 표, 돈, 협동, 복원 평판 100/150/200·시세 $4,800, 돈 쓰는 곳 |
| docs/design/monetization_options.md | — | 수익 3안(A/B/C, B 추천) — 사용자 결정 대기 |
| docs/design/alpha_scope.md | v0.3 | 손님·고장 생성기·업그레이드 Lv1~5·체크리스트 |
| docs/design/ui_screens.md | v0.2 | 첫 15분 흐름 + 화면 목록 |
| docs/design/tutorial_script.md | v0.1 | 24단계 대본(wr-dev 구현함) |
| docs/design/flip_loop.md | v0.2 | 루프 B(타이틀·감정 도구·복원 실수 함정) |
| docs/design/retention_social.md | v0.1 | 매일·친구·이벤트·업적·시즌(Roblox 규칙 확인) |
| docs/design/car_roster.md | v0.2 | 베타 7종(만들 순서 결정됨) |
| docs/design/econ_sim_report.md + tools/econ_sim.py | v1 | 경제 시뮬(결과 notes/sim/) |

## 남은 일
- **SUV 보닛 경첩·리프트게이트 수정**: suv_spec v0.1에 **반영 안 됨** — board에서 수정 요청을 못 찾음(메인이 정한 숫자가 있으면 suv_spec §1·§4에 넣기). 높이선은 아직 '제안값'.
- **보닛 열림 57.8°**: **반영 안 됨** — car_spec은 아직 "+70°(앞끝 약 8.2)". 57.8°로 정해졌으면 car_spec §4-1 보닛 줄·천장 계산 고치기.
- board에 남은 질문: wr-art "SUV 길이 −1.5 vs 16.6" → **16.6이 맞음**(suv_spec·car_roster v0.2 기준, 답 줄 남기기). wr-builder 리프트 숫자(`Equipment.LIFT`) v0.7 반영 확인.
- carbook에 부탁한 SUV 확인 4개(보닛·벨트라인 높이 mm, 머플러, 스페어, 리프트게이트 경첩) 결과 오면 suv_spec ⓒ 채우기.
- wr-dev Config 반영 확인: `FlipRep` 200/150/100/30, `RestoredValue` 4800, `GarageLevels`(Lv2 15·Lv3 45).
- Play 실측 3개(차 1대 시간·기분, 복원 시간·등급, 협동 차 나눔) → `tools/econ_sim.py` CONFIG에 넣고 다시 돌리기.
- 사용자 결정 대기: 수익 A/B/C, 첫 시대 차(네발/세발, 확정 차), Gold 복원 상급 보상, 첫 시즌 겨울, 친구 초대 $100.

## 주의할 점
- `tools/api_research.py` 보고서가 **검색 0회**면 기억으로 쓴 것 → 링크 직접 확인(Wikipedia API·내장 브라우저).
- 셸 heredoc에 따옴표가 많으면 깨짐 → 고치는 스크립트는 scratchpad에 .py로 써서 실행.
- 숫자는 모두 '시험값' — economy·alpha·flip은 시뮬로 맞췄지만 Play 실측 전.
