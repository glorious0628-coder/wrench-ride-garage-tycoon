# 알파 범위 설계 (alpha_scope) — v0.3 (wr-design, 2026-10-20 밤, GPT 2라운드)

> 기획서 7장 로드맵 2(알파 3~4주): NPC 손님 자동 입고 AI, 고장 증상 랜덤 생성기, 수리 정산, 공구/리프트 업그레이드 상점.
> 숫자는 **1차 시험값**(Config는 wr-dev). 먼저 '일 시간 분포·Calm 완료율'을 재고 맞춰요(§4).
> 토론: `notes/gpt/wr-design/alpha_r1_*`, `alpha_r2_*`. 관련: economy.md, fault_catalog.md, fun_boost.md, ui_screens.md.
> **지금 코드와의 간격**(GPT 지적): 손님 종류·인내심 단계·고장 변형·함정·임시 베이는 아직 코드에 없음, 빠른 팁은 '주차 후 240초 한 번 판정', `FaultService.roll`은 열린 슬롯을 균등 추첨. → 아래는 새로 만들 규칙이에요.

---

## 1. NPC 손님

### 1-1. 종류
| 종류 (영어) | 언제부터 | 비율 | 인내심 (차가 베이에 선 순간 → 출고 버튼) | 팁 (지금 Fast tip $80 한 번 판정을 **대체**) | 특징 |
|---|---|---|---|---|---|
| **Regular** | Lv1 | 기본 | **Calm 0~420 s** → Restless 420~660 s → Upset 660 s~ | Calm $80 · Restless $40 · Upset $0 | |
| **In a Hurry** | Lv2 | 20% | Calm 0~300 → Restless ~480 → Upset | Calm $160 · Restless $60 · Upset $0 | 처음부터 시계 아이콘, 말이 빠름 |
| **Regular Customer**(단골, 이름 있음) | Lv4 Rosa · Lv7 Tyler | 단골 1명당 30~45분에 1번 | Regular와 같음 | Regular + 10% | 지난 수리를 기억하는 대사(fun_boost #9) |
| **VIP Rush** (협동 전용) | **Lv6+, 2명 이상** | 15분에 1번(선택 — 받을지 고름) | Calm 0~360 → Upset 600 | 공임 ×1.5 + Calm 팁 $200 | 금색 번호판, 한 차를 같이 맡는 이벤트 |
| VIP (기획서 5장) | Lv16 | 10% | Calm 300 | 공임 ×1.5 | 알파 밖 |

- **첫 손님(튜토리얼)**: 인내심 없음 + First job bonus $150(지금 코드).
- **시간으로 별점 안 깎음** — 별점은 수리 품질만(미수리 −1, 오교체 −0.5). 시간은 팁만.
- **손님은 화나도 차를 가지고 떠나지 않음**(하던 일·산 부품이 사라지면 억울함 — 유저 것 빼앗기 X). Upset 뒤엔 팁 0으로 고정, 재촉 대사도 더 늘리지 않음.
- **"Finish later"(나중에 이어하기)**: 플레이어가 원하면 차를 무료 보관 주차장으로 → 베이를 비움. 다음에 이어서 고침(인내심 시계 멈춤, 팁은 Restless 기준).
- 시험 기준: Regular의 **Calm 완료율 70~85%**. 70% 밑이면 시간 늘리고, 90% 넘으면 줄임.

### 1-2. 대기 중 행동 (대기실 = world_contract `WaitingRoom`)
| 단계 | 행동 |
|---|---|
| 도착 | 차에서 내림 → 접수대(`ReceptionDesk.ServicePoint`)에서 말풍선(증상) → 40%는 자판기에서 캔 하나(마시는 동작) |
| Calm | 의자·소파(`WaitingRoom.Seats`)에 앉아 폰 보기 / TV 보기 / 커피 |
| Restless | 일어나서 **발 동동**·시계 보기(기획서 3장), 가끔 베이 문 쪽으로 와서 한마디 |
| Upset | 팔짱·한숨, 의자로 돌아가 앉음(베이 안으로 들어오지 않음 — 작업 방해 X) |
| 출고 | 차로 걸어감 → 시동 → 좋으면 환호·춤(fun_boost #10), 나쁘면 고개 갸웃 |

### 1-3. 대사 묶음 (영어 원문, 칸마다 돌아가며)
도착 직후의 **증상 대사**는 fault_catalog의 손님 말(예: "It won't start. Just goes click-click-click.")을 붙여요.

| 종류 | 도착 인사 | Calm | Restless | Upset | 출고 좋음 | 출고 나쁨 |
|---|---|---|---|---|---|---|
| Regular | "Hi! Could you check my car?" / "Hey, something feels off with my car." | "Take your time." / "I'll be right here." | "How's it going?" / "Any news on my car?" | "Could I get an update?" / "I've been waiting a while. How's it looking?" | "That feels much better. Thanks!" / "Nice work! It's running great." | "I still notice the problem. Could you check again?" / "It feels a little off. Can we take another look?" |
| In a Hurry | "Hi! I'm on a tight schedule. Can you help?" / "Hey! I've got to be somewhere soon." | "Thanks for taking a look." / "I appreciate the help." | "Any idea how much longer?" / "How's my car coming along?" | "I'm running late. Could I get an update?" / "I'm short on time. How close are we?" | "Great, I can get going. Thanks!" / "You saved me some time. Thanks!" | "It still feels off. Could you check it?" / "I need to go soon, but this needs another look." |
| Rosa (꽃집, 오래된 세단) | "Hello again! Good to see you." / "Hi, I'm back — and I brought you a daisy." | "I know you'll take a good look." / "No rush. I'm comfortable here." | "How's my old car doing?" / "Found anything yet?" | "I'm getting worried. Any news?" / "It's been a while. Could you update me?" | "Lovely! Thanks for looking after it." / "It feels great. See you next time!" | "I can still feel that problem." / "Could we give it one more check?" |
| Tyler (배달 밴 기사) | "Hey, I'm back! Can you take a look?" / "Hi again. My van's acting weird." | "Cool, I'll hang out here." / "Thanks. Let me know what you find." | "Got any clues yet?" / "How's it looking?" | "Hey, any update? I've got packages waiting." / "I'm getting worried about the van." | "Yep, that did it! Thanks!" / "Nice! It feels great now." | "Hmm, I still feel it." / "Something's still wrong. Mind checking again?" |
| VIP Rush | "Hi! I have a deadline. Can you help?" / "Hello! I could use a quick check." | "Thanks for fitting me in." / "I appreciate your help." | "How's the work coming along?" / "Do you have an update for me?" | "My deadline is close. How's it looking?" / "I need to leave soon. Could you update me?" | "Excellent. Thanks for the quick work!" / "That's just what I needed. Thank you!" | "I still notice the issue. Could you check?" / "This needs another look before I go." |
- 화가 나도 플레이어를 탓하거나 비꼬지 않아요(아이 대상). 한국어는 Locale 번역.

### 1-4. 협동 인원 → 입고량·베이
| 접속 인원 (그 정비소) | 동시에 와 있는 차 상한 | 고장 수 |
|---|---|---|
| 1명 | 산 베이 수, 최대 2 | `FaultsByLevel` 그대로 |
| 2명 | 최대 2대 | 그대로 |
| 3~4명 | Lv1~2: 최대 2 · Lv3~5: 최대 3 · Lv6+: 최대 4 | 그대로 (3명 이상 +1은 뺌 — 친구가 들어온 순간 난도가 바뀌면 혼란) |
- 산 베이보다 차가 많아야 하면 **임시 베이**(맵의 빈 베이, **플로어 잭 세트**)를 사람이 있는 동안만 엶. 화면에 "Temporary bay (while friends are here)" — 영구 혜택이 아님을 표시.
- 사람이 나가도 그 베이에서 작업 중인 차는 **출고까지 남음**, 다음 차만 안 받음.
- 베이가 비면 8 s 뒤 다음 차(지금 코드). 3~4명에겐 차를 더 주고, **한 차를 같이 맡는 건 VIP Rush(선택)**로.

---

## 2. 고장 랜덤 생성기

### 2-1. 고장 수
`FaultsByLevel` 그대로: Lv1~5 = 1개 · Lv6~15 = 1~2개 · Lv16+ = 2~3개. 폐차 복원만 2~5개.

### 2-2. 종류 고르기
1. **열린 종류**: `FaultUnlock`(Battery 1, Wheel 1, BrakePads 2, Bumper 3, **OilChange 3**(사람 시험 뒤 첫 큰 새 일 — 사용자 결정 10-21, 잭 스탠드 + 누움판 차 밑 화면, work_view §2c), Radiator 5, Muffler 6(누움판으로 — 리프트 독점 해금에서 뗌, work_view v0.2), Hood 9) + **장비가 필요한 변형은 장비를 산 뒤에만**(핸들 떨림 ← 밸런서, 펑크 패치 ← 타이어 탈착기).
2. **가중치**(열린 것끼리 나눔): Battery 25 · Wheel 25 · BrakePads 25 · **OilChange 25**(실제로 가장 흔한 일 — carbook common_jobs_visible ①) · Bumper 10 · Radiator 10 · Muffler 10 · Hood 5.
3. **새 종류 맛보기**: 해금 뒤 **다음 3대 중 1대는 확정**으로 그 종류(가중치 ×3은 운 나쁘면 한 번도 안 나와서 X).
4. **연속 방지**: 같은 종류 **3연속 금지**(2연속 금지면 Lv1의 두 종류가 기계적으로 번갈아 나옴). 같은 변형은 **직전 2대 안에서 피함**(후보가 모자라면 허용).

### 2-3. 변형 가중치 (fault_catalog ID)
| 종류 | 변형 (가중치) |
|---|---|
| Battery | BAT_DEAD 70 · BAT_CORROSION 20 (Lv3+, **함정**) · BAT_OLD 10 |
| (Lv3+ 함정 후보, 부품 아님) | Fuel Cap 헐거움("Check Fuel Cap") — 캡만 잠그면 끝, 가장 쉬운 함정 |
| Wheel | TIRE_FLAT 40 · TIRE_BALD 40 · TIRE_BULGE 20 (Lv3+) · WHEEL_IMBALANCE (밸런서 산 뒤 20) |
| BrakePads | PAD_WORN 70 · PAD_GONE 30 |
| Bumper | BUMPER_HANGING 50 · BODY_SCRATCH_LIGHT 25(**함정**: 광만) · BODY_SCRATCH_DEEP 25 |
| Radiator | RAD_LEAK 70 · RAD_FAN 30 |
| Muffler | MUF_HOLE 50 · MUF_HANGER 35(**함정**: 걸이만) · MUF_SHIELD 15 |

### 2-4. 오진 함정 · 숨은 고장
- **함정**(부품은 멀쩡한데 증상이 있음, 또는 정상인데 이상해 보임) 비율: Lv1~2 **0%** · Lv3~5 **5%** · Lv6~15 **10%**(처음엔 이 정도로, 정답률 보고 올림). 한 차 최대 1개, 레벨 업 직후 첫 차·Hurry 손님엔 X.
- **Scanner 규칙**: Scanner 색 = **부품의 Condition**이지 '원인 확정'이 아님. Lv1~2는 빨강이 바로 답(쉬운 성공). Lv3부터 **"증상은 있는데 전부 초록"**이 새 추리 단계 → 화면 힌트 **"Everything scans green… look closer, then test the symptom."**, 초록 옆 작은 "Part condition: OK", Job Card엔 다음 행동 하나만. 단서는 눈에 띄게(단자 흰 가루, 끊어진 고무 걸이). 정상 응결은 잠깐 기다리면 **"Vapor fades. No repair needed."**로 끝 — "초록인데 뭔가 사야 하나?" 오해 X.
- **숨은 두 번째 고장**(Lv6+, **10%**, 고장 2개 차엔 X): 손님은 말 안 함 → Scanner로 찾으면 "Want me to fix that too?" → OK면 공임 + 팁 $30. 거절해도 원래 일은 정상 출고.

---

## 3. 공구·리프트 업그레이드 (Lv1~5) — 전부 게임 돈, Robux로 안 팖

| Lv | 장비 (영어) | 값 | 바뀌는 **행동** |
|---|---|---|---|
| 1 | Hand Wrench · Lug Wrench · Scanner(색 점검) · **Floor Jack + Jack Stands ×2 + Creeper**(✅ 사용자 결정 10-21 — Old Lift 없앰, work_view §2b) | 무료 | 볼트 꾹 0.4초(work_view §3) |
| 2 | Battery Tester | $250 | 전압 숫자. 단자 부식이면 배터리 **쉬는 전압은 정상(12.5 V)** → 화면 "Battery reads fine — check the terminals."(실제 진단은 단자 사이 전압 강하) |
| 3 | **Ratchet Wrench** | $500 | **누른 채 볼트 위를 쓸기**(0.22 s/개, "드르륵") — 클릭 → 쓸기로 손동작이 바뀜. 첫 사용 때 2~3개 한 번에 |
| 3 | Parts Shelf +4 | $400 | 부품 미리 사 두기(이동 줄이는지 측정) |
| 3 | (공짜) Terminal Brush | — | **단자 청소**(새 수리 행동, BAT_CORROSION) |
| 4 | Bay 2 | $1,000 | 혼자서도 **두 차 작업 순서 정하기**(새 계획 재미) |
| 5 | Wheel Balancer | $1,200 | 핸들 떨림 일 + 타이밍 게이지 미니게임(한 묶음) |
| (6) | Impact Wrench $1,800 · Hydraulic Lift $2,400 · OBD Reader $2,500 · **Stethoscope $400**(Lv4 → Lv6로 옮김: 소리 단서 일이 Lv6 머플러부터라) | | Impact = 같은 쓸기를 0.09 s + 큰 소리 + 손 닿는 거리 +1. Lv6의 주된 새 경험은 리프트 아래 작업·OBD |
- 'Lift Motor Tune-up'은 뺌(한 일에서 아끼는 시간이 너무 작음 — GPT 지적).
- 새 행동 순서: **Lv3 단자 청소·쓸기 → Lv4 두 차 순서 정하기 → Lv5 휠 밸런싱 → Lv6 리프트 아래·OBD**. 첫 15분엔 구매 간격 규칙을 안 씀(이미 첫 정산·Lv2·브레이크가 빠르게 이어짐).
- 계산(GPT): 초반 순이익 건당 약 $190(5분) → $400 = 약 2건, $1,200 = 약 6~7건. Lv3 셋(Ratchet·Shelf) $900 = 약 5건(25분).

---

## 4. 알파 시험 체크리스트

### 4-1. 1인 15분
| 확인할 것 | 목표 숫자 |
|---|---|
| 첫 시동 성공 | **3~4분** 안 |
| 첫 정산·Lv2 | 5분 안 |
| 15분에 끝낸 일 | 3건, Lv3 |
| 시간 나눠 재기 | 입고 → 첫 점검 / 첫 점검 → 원인 발견 / 원인 → 출고 (중앙값·90%값) |
| Regular Calm 완료율 | **70~85%** |
| 막힘(30초 넘게 진행 없음) | 15분당 **1회 이하**, 원인 기록. 힌트 뒤 60초 안에 다시 진행 **80% 이상** |
| 멀쩡한 부품 오교체 | 첫 3건 **10% 이하** |
| 돈 | 각 구매까지 걸린 시간, 구매 직후 남은 돈, **부품값이 없어 멈춘 일 0건** |
| 폰(812×375) | 첫 수리 중 잘못 누름·버튼 가림 횟수, 글자 읽힘 |
| 기술 | 손님 길찾기 강제 이동 15분당 0~1회, 빈 베이 → 다음 차 도착 시간(목표 8~15 s), 프레임·핑 |

### 4-2. 2인 15분
| 확인할 것 | 목표 |
|---|---|
| 두 명 모두 기여 인정·정산(Team pay) | **100%** |
| 같은 볼트를 둘이 동시에 | 중복 처리 **0건** |
| 두 손 부품 운반·내려놓기 동기화 | 상대 화면에서도 같은 자리 |
| 임시 베이 | 두 번째 베이가 열리고 "Temporary bay" 표시 |
| 한 명이 나감 | 그 사람이 하던 차·산 부품 **소실 0건**, 차는 출고까지 남음 |
| 부품 대금 | 산 사람에게 먼저 환급, 도우미 손해 0 |
| 함정이 나온 차의 정답률 | **60~80%**(너무 낮으면 불공평, 너무 높으면 함정 의미 X) |
| 재미 질문(끝나고 한 줄) | "가장 재밌던 순간 / 가장 답답했던 순간" |

---

## 5. 사용자/메인 결정 필요
- "Finish later"(차 보관) 를 알파에 넣을지(추천: 넣음 — 화난 손님이 베이를 무한히 차지하는 문제의 출구).
- VIP Rush를 '선택해서 받는 이벤트'로 할지(추천: 선택 — 하기 싫은 사람에게 강제 X).
