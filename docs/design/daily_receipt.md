# 오늘의 영수증 (daily_receipt) — v0.3 (wr-design, 2026-10-21) — 알파 시험

> 사용자 결정 ②(10-21): '오늘의 영수증' 넣기 — 단위 결산(game_textbook A-4). **일 1건 정산(Payout)을 대체하지 않는 짧은 선택형 묶음 결산.** 협동이면 **내 몫**만.
> 원칙(game_textbook): 화면 숫자는 **돈 + 정비소 레벨** 두 개 — 영수증은 그 둘로 빨려 들어가는 '한 번 돌아보기'일 뿐, 새 숫자·새 목표 X.

## 1. 언제
| 때 | 무엇 | 왜 |
|---|---|---|
| **다음 접속**(스폰 뒤 3초, 화면 오른쪽에서 미끄러져 들어옴) | **지난 근무(Last Shift)** 영수증 — 지난 접속에서 일 1건 이상 + 5분 이상 놀았을 때만 | Roblox는 나갈 때 창을 띄울 수 없음(창 닫으면 끝) → 돌아왔을 때 "지난번에 이만큼 했어" |
| **언제든** — 메뉴 'Garage' 탭 또는 접수대 **영수증 프린터**(맵 소품, Prompt "Print receipt") | **이번 근무(This Shift)** 지금까지 누적 | 그만두기 전에 스스로 보고 싶을 때 |
| **나가기 직전 선택**: 메뉴 'Leave' 버튼은 없음(Roblox 기본 메뉴) → 대신 **일 5건째·10건째**에 작은 띠 "Receipt ready at the front desk!" (누르면 보기, 무시해도 됨) | | 강제 창 X |
- 일 1건 정산 카드는 그대로(첫 정산 = 큰 축하, 그 뒤 짧은 띠 — tutorial_script). 영수증은 **여러 건을 모은 것**이라 겹치지 않음.

## 2. 무엇이 찍히나 (내 몫만)
| 줄 (영어 원문) | 한국어 | 값 | 없으면 |
|---|---|---|---|
| `Cars fixed` | 고친 차 | 대수 | 0이면 영수증 안 뜸 |
| `Spot On!` | 딱 맞춘 진단 | 횟수 | 0이면 줄 숨김 |
| `Earned` | 번 돈 | **받은 돈만**: 손님이 낸 돈(공임·팁·보너스·부품 대금) + 복원차 판매 + 고물 — 협동은 내 몫. **산 부품값은 빼지 않음**(부품 카운터 영수증에 이미 보임) → **절대 마이너스 X** | 0이면 $0 그대로 |
| `Reputation` | 평판 | +N과 **정비소 레벨 막대**(이번 근무에 찬 만큼 다른 색) | |
| `New at your garage` | 새로 생긴 것 | 오른 레벨·산 장비·열린 일 종류(최대 3줄, 넘으면 "+2 more") | 줄 숨김 |
| `Restored & sold` | 복원해 판 차 | 대수 + 이익 | 줄 숨김 |
| `Customer of the shift` | 오늘의 손님 | 가장 기뻐한 손님 이름(단골 우선) + 한마디 | |
| `Crew` | 같이 일한 사람 | 친구 이름(최대 3) — 협동일 때만 | 줄 숨김 |
| 맨 아래 도장 | | **"THANK YOU!"** + 정비소 이름·날짜 | |
- **줄은 최대 7줄**, 숫자는 크게, 글은 짧게(교과서 7: 글자는 가장 느린 정보).
- 하지 않는 것: 지난번보다 '적다'는 비교, 순위, 놓친 것 목록, **쓴 돈·빼기 줄**(틀려도 괜찮아 — v0.2: 순수입으로 하면 부품만 사 두고 못 끝낸 근무에 마이너스가 찍힘, 메인 지적).

## 3. 생김새 — 정비소 영수증
- 감열지 영수증 한 장(위·아래 톱니 모양 끝, 점선 줄, 고정폭 글꼴 느낌의 Studio 글자 + 테두리), 머리 **"WRENCH & RIDE — GEARPORT"**, 가짜 바코드 장식, 빨간 'THANK YOU!' 고무도장이 '쿵' 찍힘(소리 + 살짝 흔들림).
- 접수대에 **작은 영수증 프린터 소품**(wr-builder): 띠를 누르거나 Prompt로 보면 '지지직' 인쇄 소리 + 종이가 올라오는 짧은 연출 → 화면 카드로.
- 폰: 화면 높이 80%, 세로 스크롤 X(7줄 안에 들어감), 닫기 48 px. PC: 오른쪽 위 반쯤.
- 버튼: **"Nice!"**(닫기) · **"Back to work"**(닫고 Job Card로).

## 4. 저장·코드 (wr-dev)
- 근무(Shift) = 접속~나감. DataStore에 **지난 근무 요약 한 개만** 저장(`LastShift = { t, cars, spotOn, earned (받은 돈 합, 늘 0 이상), rep, levelFrom, levelTo, unlocks = {…}, restored, restoredEarned, customer, crew = {…} }`), 다음 접속 때 보여 주고 지움.
- `ThisShift`는 서버 메모리 누적(PlayerData). `earned`는 **돈이 들어올 때만 더함**(JobService `paid[player]`, 판매·고물 수입) — 부품 살 때 빼지 않음.
- Config: `Config.Receipt = { MinJobs = 1, MinMinutes = 5, BannerAtJobs = { 5, 10 }, MaxLines = 7 }`.

## 5. Locale 키 (영어 원문 / 한국어)
| 키 | English | 한국어 |
|---|---|---|
| `receipt.title.last` | Last Shift | 지난 근무 |
| `receipt.title.this` | This Shift | 이번 근무 |
| `receipt.header` | WRENCH & RIDE — GEARPORT | WRENCH & RIDE — GEARPORT |
| `receipt.cars` | Cars fixed | 고친 차 |
| `receipt.spotOn` | Spot On! | 딱 맞춘 진단 |
| `receipt.earned` | Earned | 번 돈 |
| `receipt.rep` | Reputation | 평판 |
| `receipt.new` | New at your garage | 정비소에 새로 생긴 것 |
| `receipt.newMore` | +{n} more | 그 밖에 {n}개 |
| `receipt.restored` | Restored & sold | 복원해서 판 차 |
| `receipt.customer` | Customer of the shift | 오늘의 손님 |
| `receipt.crew` | Crew | 함께한 친구 |
| `receipt.stamp` | THANK YOU! | 고마워요! |
| `receipt.nice` | Nice! | 좋아요! |
| `receipt.back` | Back to work | 다시 일하러 |
| `receipt.ready` | Receipt ready at the front desk! | 접수대에서 영수증을 볼 수 있어요! |
| `act.printReceipt` | Print receipt | 영수증 뽑기 |

## 5b. 돌아오면 기다리는 것 (tycoon_analysis 보완 — 코드는 사람 시험 뒤)
> 조사: '돌아오면 쌓여 있는 것'이 재방문 이유. 우리 규칙: **오프라인 돈 X**(retention_social §0) → 쌓이는 건 돈이 아니라 **이야기 하나**.
| 순서 | 재접속 첫 화면 |
|---|---|
| 1 | 스폰 = 내 정비소 Bay 1 앞(첫 접속과 같은 자리) |
| 2 | **Bay 1에 '기다리던 차' 한 대가 이미 서 있음** — 아래 우선순위로 하나만 |
| 3 | 3초 뒤 **지난 근무 영수증**이 미끄러져 들어옴(§1) — 영수증 맨 아래 한 줄로 그 차를 소개: "Someone's been waiting for you!" |
**기다리던 차 고르는 우선순위** (하나만, 보상 배율 X — 평소 손님과 같은 규칙):
1. **Finish later로 보관한 차**(alpha_scope §1-1) — "Your car from last time is still on the lift." / "지난번 차가 아직 리프트에 있어요."
2. **진짜 원인이 남은 단골**(fault_catalog §1b 결말 변주 — 예: 배터리만 바꿨는데 발전기였음) — "Rosa's back — it died again!" / "Rosa가 다시 왔어요 — 또 방전됐대요!"
3. **아는 단골의 새 고장** — 지난 근무 '오늘의 손님'이 다시 옴 — "{name} is back with a new problem." / "{name}이(가) 새 고장을 들고 다시 왔어요."
4. 그 밖엔 **이름 있는 새 손님 한 명이 문 앞에서 기다림**(평소 손님, 인내심 시계는 차가 베이에 선 뒤부터 — 그냥 바로 일감이 있다는 뜻).
- 하지 않는 것: '접속 안 한 동안 번 돈', '기다리다 화난 손님'(벌 X), 여러 대가 밀려 있음(부담).
- Locale 키: `return.waiting` "Someone's been waiting for you!" / "누군가 기다리고 있었어요!", `return.stored`, `return.regularAgain`, `return.regularNew`(위 문구).
- 저장: 보관 차(`StoredCar`)·단골 후속(`FollowUp = { customer, fault }`) — 저장 범위는 tycoon_analysis 보완 3과 함께(wr-dev).

## 6. 검사 질문 5개 (game_textbook)
1. 기대: 영수증 = "오늘 내가 한 일" — 그대로 보여 줌, 숨은 손해·비교·마이너스 없음 ✓
2. 따뜻함·틀려도 괜찮음: 못 한 것·적은 것 표시 X, 'THANK YOU!' 도장 ✓
3. 보정: 닫기 하나, 강제 X, 프린터·메뉴 어디서나 ✓
4. 눈에 보이는 반응: 인쇄 소리·도장 쿵·레벨 막대가 차오름 ✓
5. 정비소가 자란다: 새 숫자 X — 돈과 레벨 막대, '새로 생긴 것'으로 정비소 성장만 보여 줌 ✓

- 변경 기록: v0.3 (10-21) §5b 돌아오면 기다리는 차 하나(보관 차 > 단골 후속 > 아는 단골 > 새 손님) + 영수증과 묶기, 오프라인 돈 X. v0.2 (10-21) `Earned` = 받은 돈만(산 부품값 안 뺌, 마이너스 X) — 메인 검수. v0.1 첫 초안.
