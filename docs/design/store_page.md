# 첫 화면·게임 소개글·썸네일 (store_page) — v0.2 (wr-design, 2026-10-21)

> tycoon_analysis 보완 2: 썸네일·첫 화면이 '폐차 사서 복원'을 약속하면 약 3시간(Lv8) 해금과 부딪힘 → **손님 차 고치기를 전면**, 복원은 **"Lv8에 열림"** 표시. 조사: 썸네일 = 실제 플레이가 좋음(tycoon_success).
> 원문 영어 + 한국어. 실제 브랜드·남의 IP X, 그림체 B. 썸네일 그림은 **사람 시험 뒤 실제 장면으로** wr-art가.

## 1. 게임 소개글 (Roblox 게임 페이지) — v0.3 (공개용, 10-22 — AI 티 점검 `notes/playtest/wr-gamer/ai_look_report.md` ④: 첫 줄(진짜 3단계)은 유지, '세 개씩' 2곳과 'from a small shed to a brick shop' 풀기 — README 'AI 티 X' 글 기준: 소리 내어 읽어 광고 같지 않게, 한 문장 한 동작, 실제로 되는 것만)
첫 두 줄이 목록에서 잘려 보이므로 **첫 줄 = 무엇을 하는 게임인지**. **공개 때 실제로 되는 것만** 씀(work_view v0.5 작업 화면·스캔·잭, 코드의 장비·복원 Lv8·쇼룸). 오일 교환·밈 차·시대 차처럼 **아직 없는 것은 안 씀**.

**English (원문)**
> **Find the problem, fix it with your own hands, and hear it start again!**
> Run a small neighborhood garage in Gearport, where customers drive in and tell you what their car is doing.
>
> - Scan the car to see where to look, then find the real cause yourself.
> - Open the hood and work up close, one bolt at a time.
> - Jack the car up and set the stands to swap wheels and brake pads.
> - Some cars try to trick you. The part looks fine, but something else is wrong.
> - Earn new tools and grow your garage. At Garage Level 6 you can buy a hydraulic lift.
> - Fix cars alone, or work on the same car with friends.
> - At Garage Level 8: buy wrecks from the junkyard and restore them.
>
> We add new jobs and cars with updates.

**한국어 (번역)**
> **문제를 찾고, 내 손으로 고치고, 다시 시동!**
> Gearport의 작은 동네 정비소를 운영해요. 손님이 차를 몰고 와서 차가 어떤지 말해 줘요.
>
> - 차를 스캔해서 어디를 볼지 알아내고, 진짜 원인은 직접 찾아요.
> - 보닛을 열고 가까이서, 볼트 하나씩 풀어요.
> - 잭으로 차를 올리고 스탠드를 받쳐 바퀴와 브레이크 패드를 갈아요.
> - 가끔은 속이는 차도 있어요. 부품은 멀쩡해 보이는데 다른 게 문제예요.
> - 새 공구를 얻고 정비소를 키워요. 정비소 레벨 6이 되면 유압 리프트를 살 수 있어요.
> - 혼자 고치거나, 친구와 같은 차를 같이 고쳐요.
> - 정비소 레벨 8: 폐차장에서 부서진 차를 사서 복원해요.
>
> 업데이트로 새 일과 새 차를 더해요.

- 쓰지 않는 말: '돈을 쓰면 빨라짐', 실제 브랜드·차 이름, "best/#1", "weekly updates" 같은 약속(update_roadmap은 2~4주 — 날짜 약속 X), 아직 없는 기능(오일 교환·차 밑 누움판 화면·밈 차·시대 차).
- 공개 뒤 기능이 들어오면 그때 한 줄씩 더함(예: 차 밑 누움판 화면 + 오일 교환이 들어오면 "Slide under the car on a creeper for oil changes.").
- 짧은 한 줄(목록·광고용): **"Fix real-feeling cars with your own hands, solo or with friends."** / "진짜 같은 차를 내 손으로 고쳐요. 혼자 또는 친구와."

## 2. 썸네일 장면 목록 (시험 뒤 실제 장면 → wr-art)
| # | 장면 | 약속하는 것 | 글자(영어, 짧게) |
|---|---|---|---|
| 1 (대표) | 보닛 연 세단, 정비사가 **Scanner로 빨간 배터리**를 가리키고 손님이 뒤에서 기다림 | 진단 추리 = 핵심 | "WHAT'S WRONG?" |
| 2 | 잭 스탠드에 올린 차(Lv1 — 리프트 X), 바퀴 빠지고 **헌 패드 vs 새 패드** 나란히 | 손으로 고치는 손맛 | "FIX IT YOURSELF" |
| 3 | **친구 두세 명이 같은 차**에 붙어 각자 다른 부품 | 협동 | "FIX CARS WITH FRIENDS" |
| 4 | 정비소 **전·후**: 골함석 창고 → 벽돌 정비소(garage_growth) | 정비소가 자란다 | "GROW YOUR GARAGE" |
| 5 | 밈 차 한 대(덕트 테이프 차)와 웃는 손님 | 웃음·다양성 | "WEIRD CARS TOO!" |
| 6 | 방수포 덮인 폐차 + 자물쇠 + **"Unlocks at Garage Lv 8"** | 나중 목표(정직하게 표시) | "RESTORE CLASSICS · LV 8" |
- 첫 썸네일은 1(진단) — 복원 장면(6)은 맨 뒤.
- 실제 게임 화면에서 찍은 장면 위에 글자만(가짜 장면 X — 조사: 실제 플레이 썸네일이 좋음).
- 아이콘(정사각): 큰 렌치 + 작은 세단 앞모습(오리지널), 글자 없음.

## 3. 게임 안 첫 화면
- 스폰 = **Bay 1 앞**(tutorial_script §1b) → 첫 장면은 **들어오는 Rosa의 차**, 복원·쇼룸이 먼저 보이지 않게(카메라 방향 = 베이 쪽).
- 뒷마당 복원 베이 문·폐차장 바리케이드에 작은 표지 **"Opens at Garage Level 8"** / "정비소 레벨 8에 열려요"(기대 배신 막기 — 교과서 1).
- 쇼룸 유리문: **"Showroom, Garage Level 9"**.
- Locale 키: `sign.opensAt` "Opens at Garage Level {n}" / "정비소 레벨 {n}에 열려요".

## 4. 검사 질문 5개
1. 기대: 첫 줄·첫 썸네일이 '손님 차 진단·수리' → 들어오면 바로 그것 ✓, 복원은 Lv8이라고 미리 말함 ✓
2. 따뜻함: '동네 정비소', '친구와' ✓
3. 보정: 첫 장면이 바로 일감(차) ✓
4. 눈에 보이는 반응: '다시 부릉'이 소개글 첫 줄 ✓
5. 정비소가 자란다: 소개글·썸네일 4번 ✓

## 5. 로블록스 연령 설문 메모 (사용자가 직접 답함 — 참고용)
> 근거: Roblox 공식 문서 'Content maturity and compliance' (https://create.roblox.com/docs/en-us/production/promotion/content-maturity.md, 10-21 확인). 자리 = Creator Dashboard → 게임 → **Publish settings → Content rating → Start** → 쪽마다 답 → Save and Continue → 미리보기 → **Submit**. 설문을 안 하면 로블록스가 게임을 **아무도 못 하게 막음**(사실상 필수). **가장 센 장면 기준**으로 답하고, 나중에 다시 할 수 있어요.

| 질문 칸 | 우리 게임 | 추천 답 | 이유 |
|---|---|---|---|
| 폭력 (Violence) | 싸움·공격·무기 없음. 배터리 순서를 틀리면 작은 불꽃만(다치는 연출 X), 잭 스탠드 없이 차 밑에 못 들어감 | **없음** | 공식 정의 = 플레이어·NPC에게 일부러 힘을 쓰는 것 |
| 피 (Blood) | 없음 | **없음** | |
| 무서움 (Fear) | 없음(밤·으스스 연출 없음) | **없음** | 핼러윈 시즌을 넣으면 그때 다시 |
| 저속한 유머 (Crude humor) | 없음(밈 차도 아직 없음, 들어와도 장난감·뽁뽁이 수준) | **없음** | |
| 연애 (Romantic themes) | 없음 | **없음** | |
| 술 (Alcohol) · 약물 | 없음(정비소·거리 소품에 술집 간판도 X) | **없음** | |
| 거친 말 (Strong language) | 없음. 손님 말은 우리가 쓴 것, 정비소 이름은 로블록스 필터 + 우리 금지어 두 겹 | **없음** | |
| 도박 (Gambling) | 없음(돈·아이템을 걸고 운에 맡기는 놀이 X) | **없음** | |
| 돈 주고 사는 랜덤 아이템 (Paid random items) | 없음 — 게임 패스는 내용이 정해진 것만(정비소 이름 바꾸기 299 R$ 등), 뽑기 X | **없음** | 하우스 룰과 같음 |
| 소셜 행아웃 (Social hangout) | 아님 — 주된 놀이는 차 고치기, 대화는 덤. 모르는 사람과 안 섞임(친구·친구의 친구만) | **아니요** | '주된 주제가 다른 사람과 이야기·어울리기'인 게임만 해당 |
| 자유 창작 (Free-form user creation) | 손으로 그리기·칠하기·스프레이 **없음**. 정비소 **이름 글자**만 입력(필터 통과한 글자가 간판에) | **아니요** (판단이 필요한 칸 — 아래) | 공식 예시 = 표면에 손으로 그리기·칠하기·쓰기·스프레이 |

- **조심할 칸 = 자유 창작**: 정비소 이름은 '자판으로 친 짧은 글자 + 로블록스 글자 필터(GetNonChatStringForBroadcastAsync)'라서 손으로 그리는 '자유 창작'과 다르다고 봐서 **아니요**를 추천해요. 이 칸을 **예**로 하면 **16세 이상만** 할 수 있게 돼서, 우리 주 대상(어린이)이 못 해요. 화면에 뭔가를 그리거나 칠하는 기능(낙서·스티커 자유 배치 등)을 나중에 넣으면 그때 다시 생각해요.
- 예상 결과: 모든 칸이 '없음'이면 가장 낮은 단계(Minimal)로 나올 것 같아요(추측 — 실제 등급은 설문 결과 화면에서 확인).
- 바뀌면 다시 할 때: 핼러윈 등 무서운 시즌, 밈 차 중 '방귀' 같은 저속 유머, 그리기 기능, 뽑기 상품(우리는 안 함).

