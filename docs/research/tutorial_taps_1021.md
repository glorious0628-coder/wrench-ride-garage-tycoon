# 튜토리얼 탭 수 세기 + 잠김·닫기 점검 — wr-ui, 2026-10-21 밤
> 메인 공부 노트 `docs/research/main_study_1021.md` §2 "다음 점검 = 튜토리얼 흐름도 탭 수 세기(wr-ui), 잠긴 업그레이드는 자물쇠 + 회색 통일, 닫기 X는 늘 오른쪽 위".
> 아래 본문 = 코드 따라 읽고 센 것(문서보다 코드 우선). 🐞1·🐞2는 내가 코드로 다시 확인함.

## 요약 (먼저 읽기)
- **세 차 합계: 탭 약 85 · 꾹 4 · 걷기 약 13** (Rosa 18탭 · Tyler 37탭 · 3번째 29~30탭). 제일 큰 군더더기 = **카트 왕복**(Cart 버튼만 Tyler 10탭).
- **진행이 멈추는 고장 4개** — 줄이기보다 먼저:
  - ✅ 🐞1 Rosa "Scan the car" 누를 버튼 없음 → **wr-ui 고침**(`JobCard.luau`: 튜토리얼 차도 "시동 걸어 보기" 뒤엔 작업 카드 **차 스캔하기** 버튼이 보임). Play 확인.
  - ✅ 🐞2 Tyler "Final check" 누를 곳 없음 → **wr-ui 고침**: 고친 차(Fixed, 아직 FinalChecked 아님)면 작업 카드에 **마지막 점검** 버튼(같은 Scan → 서버가 final로) — work_view §2d대로 모든 차. Play: 버튼 클릭 → 서버 `FinalChecked = true` 확인.
  - ⬜ 🐞3 3번째 차 브레이크 밟기 버튼 없음(추리 단서 하나를 못 얻음) → **wr-dev** `Tutorial.luau:430` suspects 단계에 `action = "brake"`.
  - ⬜ 🐞4 3번째 차 잭 안내가 못 찾은 뒤에만 → **wr-dev** `Tutorial.luau:426-436` 순서.
- ✅ 폰 꾹 프롬프트(Pump 1.5초·Hand back 0.6초)에 "탭"이라 써 있던 것 → **"꾹" / "Hold"**(`PromptUI.luau`, wr-ui).
- **줄일 곳 Top 3(wr-dev)**: ① Cart 한 번에(놓기·들기 뒤 자동 복귀, 약 20탭) ② 렌치 든 채로 피스톤·돌리기 ③ 작업 화면 안 **Lower car 버튼**(버튼 wr-ui · 높이 잠금 예외 wr-dev). 전체 11개 = 아래 A-5 표.
- **잠김 통일**(B-1): 자물쇠는 EquipShop·Settings 두 곳뿐이고 회색은 글자색만 → 규칙 제안 **"잠김 = 자물쇠 아이콘 + 줄 흐림(UIKit.setButton Gray, disabled)"**. 어긋남: Appraisal Buy 못 함(갈색, 자물쇠 X). → wr-ui 다음 일(Appraisal 옮길 때 같이).
- **닫기**(B-2): 진짜 창 5개(UIKit.window)는 모두 오른쪽 위 X ✅. 어긋남 = **Appraisal**(30px 빨간 "X" 글자) 하나, Haggle은 X 없이 Decline(의도면 OK). 규칙: **창 = 오른쪽 위 X, 축하 카드 = 아래 가운데 Nice! 하나**.

---
# 튜토리얼 탭 수 + UI 일관성 점검 (읽기만, 2026-10-21)

기준: **폰**. 코드가 문서보다 우선(다른 곳은 ⚠로 표시). 경로 줄임: CM = `src/StarterPlayer/StarterPlayerScripts/ClientModules/`, SS = `src/ServerScriptService/Modules/`.
입력 종류: 탭 버튼 / 탭 프롬프트 / 꾹 프롬프트 N초 / 3D 탭(작업 화면 안에서 부품·볼트 누르기) / 걷기 / 공구 바꾸기 / 끌기.
알아둘 것:
- 작업 화면 안에서는 **모든 ProximityPrompt가 꺼짐**(CM `WorkView.luau:241`) → 잭·Lower car·Hand back은 밖에 나와야 함.
- 볼트 = 탭 1번이면 혼자 끝까지 돎(0.4초, CM `Wrench.luau:186-189`). 꾹 0.4초도 됨. 아래에선 "탭"으로 셈.
- 튜토리얼 차에선 작업 카드의 **Scan 버튼·Try 버튼이 숨겨짐**(CM `JobCard.luau:140-144`). 대신 튜토리얼 띠에 Order·Try 버튼만 있음(CM `Tutorial.luau:933-965`). → 아래 🐞 참고.

---
## A-1. 1번 차 Rosa (배터리) — 코드 순서

| # | 플레이어가 하는 일 | 입력 | 코드 |
|---|---|---|---|
| 1 | 차가 들어옴, "YOUR FIRST JOB!" 배너 | (없음) | CM `Tutorial.luau:273-275, 660-663` |
| 2 | 띠의 **Try starting it** 버튼 | 탭 버튼 | CM `Tutorial.luau:276-278, 952-963` |
| 3 | 🐞 "Scan the car" — **누를 버튼이 없음**, 화살표도 없음. 보닛을 열어야 이 단계가 지나감 | (막힘) | CM `Tutorial.luau:279-281`, CM `JobCard.luau:140-141` |
| 4 | 보닛 앞으로 걸어감 (스폰 자리 → 보닛 약 8 stud, 프롬프트 거리 7) | 걷기 | CM `Tutorial.luau:288-289, 862` |
| 5 | **Open hood** → 작업 화면 자동 + Scanner 자동 장착 | 탭 프롬프트 | SS `CarService.luau:53-80`, `Main.server.luau:220-222`, SS `TutorialService.luau:84-98` |
| 6 | 배터리를 Scanner로 누름 → 빨강, 배너 | 3D 탭 | CM `Inspect.luau:194`, CM `Tutorial.luau:291-292` |
| 7 | 띠의 **Order a battery ($90)** → 2초 뒤 카트에 '툭' | 탭 버튼 | CM `Tutorial.luau:294-295, 933-949`, SS `WorkService.luau:93-107` |
| 8-10 | 볼트 3개 풀기(−, +, 고정쇠). 렌치는 자동 장착 | 3D 탭 ×3 | CM `Tutorial.luau:297-299, 721-730` |
| 11 | 풀린 헌 배터리 누르기(들기) | 3D 탭 | CM `WorkView.luau:391-394` |
| 12 | **Cart** 버튼(카메라 카트로) | 탭 버튼 | CM `WorkViewUI.luau:70-72`, CM `Tutorial.luau:265-266` |
| 13 | 카트 화면 아무 데나 눌러 내려놓기 | 3D 탭 | CM `WorkView.luau:364-366` |
| 14 | 카트의 새 배터리 누르기(들기) | 3D 탭 | CM `Tutorial.luau:316-318` |
| 15 | **Cart** 버튼(돌아옴) — 안 누르고 탭하면 다시 카트에 놓임 | 탭 버튼 | CM `Tutorial.luau:260-261`, CM `WorkView.luau:364` |
| 16 | 빈 자리 근처 누르기 → '착' | 3D 탭 | CM `WorkView.luau:368-371` |
| 17-19 | 볼트 3개 조이기(+, −, 고정쇠) | 3D 탭 ×3 | CM `Tutorial.luau:322-324` |
| 20 | 다 고치면 서버가 작업 화면에서 꺼냄 | (자동) | `Main.server.luau:224-231` |
| 21 | 띠의 **Start it up** 버튼 | 탭 버튼 | CM `Tutorial.luau:326-327` |
| 22 | **Hand back the keys** (거리 12, 대개 걷기 0~1) | 꾹 프롬프트 0.6초 | SS `JobService.luau:65-84`, CM `Tutorial.luau:329` |
| 23 | Level 2 카드 **Nice!** (10초면 혼자 닫힘) | 탭 버튼 | CM `Tutorial.luau:775-825` |

**합계(Rosa)**: 탭 **18**(버튼 5 · 프롬프트 1 · 3D 12) · 꾹 **1** · 걷기 **1~2** · 공구 바꾸기 **0**(Scanner·렌치 모두 자동) · 창 **1**(레벨 카드) + 작업 화면 1번, 카트 왕복 1번(Cart 2탭).
(Scan 버튼이 고쳐지면 탭 +1 = 19)

## A-2. 2번 차 Tyler (앞 왼쪽 패드) — 코드 순서

| # | 플레이어가 하는 일 | 입력 | 코드 |
|---|---|---|---|
| 1 | 띠의 **Press the brake** 버튼 | 탭 버튼 | CM `Tutorial.luau:337-339` |
| 2 | 차 앞 가운데로 걸어감 | 걷기 | CM `Tutorial.luau:356` |
| 3 | **Jack front** → 고임목·잭·펌프·스탠드 3초 자동 연출 | 탭 프롬프트 | SS `JackService.luau:443-446, 474-480, 379` |
| 4 | 앞 왼쪽 바퀴로 걸어감 | 걷기 | CM `Tutorial.luau:363-364` |
| 5 | **Work on wheel** → 바퀴 작업 화면 | 탭 프롬프트 | SS `WorkService.luau:295-313` |
| 6-10 | 바퀴 너트 5개 풀기(렌치 자동) | 3D 탭 ×5 | CM `Tutorial.luau:366-368` |
| 11-13 | 헌 바퀴 누르기 → Cart → 카트에 놓기 | 3D 탭 + 탭 버튼 + 3D 탭 | CM `Tutorial.luau:372-374` |
| 14 | ⚠ **Cart 다시 눌러 돌아오기** — 안내 없음(카트 화면에 그대로 남음) | 탭 버튼 | CM `WorkView.luau:523-528` |
| 15-16 | 캘리퍼(패드) 볼트 2개 풀기 | 3D 탭 ×2 | CM `Tutorial.luau:376-379` |
| 17-19 | 헌 패드 누르기 → Cart → 놓기 ("Worn out!" 배너) | 3D·버튼·3D | CM `Tutorial.luau:381, 682-685` |
| 20 | ⚠ Cart 다시 눌러 돌아오기 — 안내 없음 | 탭 버튼 | |
| 21 | ⚠ **손에 든 렌치 내려놓기**(공구 줄 맨 앞 '맨손' 칸) — 렌치를 들고 있으면 캘리퍼 탭이 안 먹힘, 안내 없음 | 공구 바꾸기 | CM `WorkView.luau:377`, CM `Hotbar.luau:1-3` |
| 22 | 캘리퍼 누르기 = 피스톤 밀기 | 3D 탭 | CM `Tutorial.luau:383-384`, CM `WorkView.luau:377-389` |
| 23 | **Exit** (힌트 "Tap Exit to walk again") | 탭 버튼 | CM `Tutorial.luau:390` |
| 24 | 부품 카운터로 걸어감 | 걷기 | |
| 25 | **Buy parts** 프롬프트 → 상점 창(브레이크 탭 자동 선택) | 탭 프롬프트 | SS `ShopService.luau:129-136`, CM `Shop.luau:47-70` |
| 26 | 패드 **Buy** (2초 뒤 카트로 배달) | 탭 버튼 | CM `Shop.luau:200-213` |
| 27 | 걸어서 돌아감(멀어지면 상점 창 자동 닫힘) | 걷기 | CM `Shop.luau:226-237` |
| 28 | **Work on wheel** 다시 | 탭 프롬프트 | CM `Tutorial.luau:386-388` |
| 29-32 | Cart → 새 패드 누르기 → Cart → 자리 누르기 | 버튼·3D·버튼·3D | CM `Tutorial.luau:386-388, 260-261` |
| 33 | "Hold to tighten all" — 볼트 하나 누르면 전부 조여짐 | 3D 탭 | CM `Tutorial.luau:392-394`, SS `BoltService.luau:102-111` |
| 34-37 | Cart → 헌 바퀴 누르기 → Cart → 자리 누르기 | 버튼·3D·버튼·3D | CM `Tutorial.luau:396-398` |
| 38 | 바퀴 너트 조이기(하나 누르면 전부) | 3D 탭 | CM `Tutorial.luau:400-402` |
| 39 | ⚠ **Exit** — 작업 화면 안엔 Lower 버튼이 없고, 안에 있으면 높이 잠금 | 탭 버튼 | SS `JackService.luau:249-252` |
| 40 | 차 앞으로 걸어감 | 걷기 | |
| 41 | **Lower car** | 탭 프롬프트 | SS `JackService.luau:449-452`, CM `Tutorial.luau:404-405` |
| 42 | 띠의 **Press the brake** → 끼익 없음(자동 전후 비교) | 탭 버튼 | CM `Tutorial.luau:407-408, 686-689` |
| 43 | 🐞 "Final check: scan it once more" — **버튼이 어디에도 없음**. 단계가 안 끝나고 화살표도 없음 | (막힘) | CM `Tutorial.luau:410-412`, CM `JobCard.luau:140` (Scan 줄은 1단계일 때만) |
| 44 | **Hand back the keys** (스스로 찾아야 함) | 꾹 프롬프트 0.6초 | SS `JobService.luau:65-84` |

**합계(Tyler)**: 탭 **37**(버튼 15 · 프롬프트 5 · 3D 17) · 꾹 **1** · 걷기 **5** · 공구 바꾸기 **1**(손으로, + 렌치 자동 3번) · 창 **1**(상점) + 작업 화면 2번, 카트 왕복 5번(Cart 10탭).

## A-3. 3번째 차 (못 박힌 타이어, 용의자 카드) — 코드 순서 (화살표 없음이 설계)

| # | 플레이어가 하는 일 | 입력 | 코드 |
|---|---|---|---|
| 1 | 손님 말 + "What could it be? / Brakes? / Tire?" | (없음) | CM `Tutorial.luau:418-431` |
| 2 | 🐞 브레이크 밟아 보기 — **버튼 없음**(job3엔 `action` 없음 + 작업 카드 Try 숨김) → "Brakes? Quiet" 도장을 못 받음 | (불가) | CM `Tutorial.luau:430`, CM `JobCard.luau:143-144` |
| 3 | ⚠ Scan 단계 없음(문서엔 있음) | — | |
| 4 | ⚠ 차 앞으로 걸어감 — 바퀴 작업 화면은 스탠드가 먼저인데, 잭 안내("Now you do it")는 **못을 찾은 뒤에만** 나옴 → 그 전엔 안내 0 | 걷기 | CM `Tutorial.luau:426-436`, SS `WorkService.luau:134-136` |
| 5 | **Jack front** (이번엔 연출 없음) | 탭 프롬프트 | SS `JackService.luau:476-480` |
| 6 | **Pump** | 꾹 프롬프트 1.5초 | SS `JackService.luau:447-449, 483-492` |
| 7-10 | 스탠드 자리 2곳(양쪽 문턱 아래)으로 걸어가 **Place stand** ×2 | 걷기 ×2 + 탭 프롬프트 ×2 | SS `JackService.luau:454-459` |
| 11-12 | 앞 왼쪽 바퀴로 걸어가 **Work on wheel** | 걷기 + 탭 프롬프트 | |
| 13 | (렌치를 들고 있으면) 맨손으로 — 돌리기는 맨손만 됨 | 공구 바꾸기 0~1 | CM `WorkView.luau:551` |
| 14 | 타이어를 끌어서 돌려 못 찾기 → "A nail!" | 끌기 | CM `WorkView.luau:548-559, 104-131` |
| 15 | 렌치 고르기 — job3 단계엔 `tool`이 없어 자동 장착·통통 없음 | 공구 바꾸기 | CM `Tutorial.luau:432-437` |
| 16-20 | 너트 5개 풀기(하나씩) | 3D 탭 ×5 | SS `BoltService.luau:102`(전부 조이기는 2번 차만) |
| 21-23 | 헌 바퀴 누르기 → Cart → 놓기 | 3D·버튼·3D | |
| 24-25 | **Exit** → 카운터로 걸어감 | 탭 버튼 + 걷기 | |
| 26 | **Buy parts** 프롬프트 → 상점 창 | 탭 프롬프트 | |
| 27 | ⚠ **Wheels 탭** 누르기 — job3엔 `shop` 값이 없어 자동 선택 안 됨 | 탭 버튼 | CM `Tutorial.luau:769`, CM `Shop.luau:47-70` |
| 28 | 바퀴 **Buy** | 탭 버튼 | |
| 29-30 | 걸어서 돌아가 **Work on wheel** | 걷기 + 탭 프롬프트 | |
| 31-34 | Cart → 새 바퀴 → Cart → 자리 | 버튼·3D·버튼·3D | |
| 35-39 | 너트 5개 조이기(하나씩, 별 순서면 보너스) | 3D 탭 ×5 | SS `BoltService.luau:94-99, 117-120` |
| 40-42 | **Exit** → 차 앞으로 → **Lower car** | 탭 버튼 + 걷기 + 탭 프롬프트 | |
| 43 | **Hand back the keys** → "쏠림은 못 때문" 배너 | 꾹 프롬프트 0.6초 | CM `Tutorial.luau:1146-1150` |

**합계(3번째)**: 탭 **29~30**(버튼 10 · 프롬프트 7 · 3D 12) · 꾹 **2** · 끌기 1 · 걷기 **7** · 공구 바꾸기 **1~2** · 창 **1**(상점) + 작업 화면 2번, 카트 왕복 2번.

**세 차 합계**: 탭 약 84~85 · 꾹 4 · 걷기 약 13 · 손 공구 바꾸기 2~3 · 창 3.

## A-4. 문서와 코드가 다른 곳
| 문서 | 코드 |
|---|---|
| Rosa 1b·Tyler·3번째 "Scan the car" 버튼 (work_view §2d·§5, v03_text §1-3·§2-2) | Rosa만 단계가 있고 **버튼이 숨겨짐**. Tyler·3번째는 Scan 단계 자체가 없음 |
| Tyler 17 Final check (v03_text §2-17) | 단계는 있는데 **버튼이 없음** — 게임 전체에서 Final check를 누를 곳이 없음(JobCard Scan 줄은 1단계 전용) |
| 주문하면 카메라 0.3초 카트로 (work_view §5 Rosa 3) | 카메라 이동 없음, 배너만 |
| 헌 배터리 '두 손 들기 0.6초 → 카트' / 바퀴 '옆으로 쓸기' (§3, v03 `tut.rollWheel` "Swipe") | 둘 다 **탭으로 들기 → Cart → 탭**. Locale `tut.rollWheel` = "Roll the wheel off" |
| Tyler 너트 "첫 번만 한 번에 풀림" (§5 Tyler 2, v03 §2-5) | 풀기는 하나씩(5탭). 한 번에는 **조이기만** (SS `BoltService.luau:102`) |
| 헌 패드 2장·"캘리퍼 탭해서 닫기" (v03 §2-9·14) | 패드 = 부품 1개, 캘리퍼 닫기 단계 없음 |
| 피스톤 "원 꾹" / 힌트 "Hold the round button" | **맨손으로 캘리퍼 탭 한 번**. 렌치 들면 안 됨 |
| 작업 화면의 **Lower car 버튼** (§2b·v03 §2-16) | 프롬프트만 → Exit + 걷기 필요 |
| 3번째: Scan → 브레이크 조용 → 바퀴 돌려 못 → 잭 직접 (§5) | 브레이크 버튼 없음, 잭 안내는 못 찾은 뒤에만(실제론 이미 스탠드 위라 `tut.jackYourself`는 사실상 안 보임) |
| 잭만 올린 상태 "Work on wheel" 회색 + 이유 (§2b) | 프롬프트가 그냥 숨겨짐 (SS `WorkService.luau:313`) |

## A-5. 줄일 곳 제안
(절약 = 세 차 합계 기준 추정. 위험 = 핵심 루프 "찾고 → 풀고 → 바꾸고 → 확인" 배움이 줄어드는지)

| # | 제안 | 아끼는 탭 | 위험 | 누가 |
|---|---|---|---|---|
| 1 | **Cart를 한 번에 끝내기**: 헌 부품을 든 채 Cart 누르면 카메라가 0.3초 카트로 갔다가 **놓고 자동 복귀**; 손이 비고 카트에 새 부품이 있으면 Cart 누르면 **들고 자동 복귀**(점선 자리 빛남). 지금은 "카트 화면에 갇힘" 2번(Tyler 14·20)도 없어짐 | Rosa 4 · Tyler 12 · 3번째 4 = **약 20** | 낮음 — 카트는 3D로 그대로 보이고 놓는 소리·'툭'도 남음 | wr-dev (`WorkView.luau` tap/Cart 처리) |
| 2 | **피스톤·돌리기는 렌치 든 채로도 되게**(캘리퍼 탭 조건 `not tool` 빼기 / 돌리기는 볼트가 아닌 곳 끌기면 OK) 또는 그 단계에서 자동 맨손 | 2~3 + 막힘 1곳 제거 | 없음 | wr-dev (`WorkView.luau:377, 551`) |
| 3 | 3번째 차 너트 단계에도 렌치 칸 통통(`tool="Wrench"`)·자동 장착 | 1 | 낮음(3번째는 '스스로'지만 공구 고르기는 핵심이 아님) | wr-dev (`Tutorial.luau:432-437`) |
| 4 | **작업 화면 안에 Lower car 버튼**(WorkViewUI 버튼 + 누른 사람은 높이 잠금 예외 → 자동으로 화면에서 나옴). 서버 `Remotes.Jack "lower"`는 이미 있음 | Tyler·3번째 각 1탭 + 걷기 1 = **2탭·걷기 2** | 없음(문서 원안) | 버튼 = wr-ui, 잠금 예외 = wr-dev (`JackService.luau:249-252, 535-551`) |
| 5 | Tyler 너트 **풀기도 한 번에**(문서대로, 조이기와 같게) | 4 | 낮음 — 3번째 차에서 5개를 손으로 다시 함 | wr-dev (`BoltService.luau:102`) |
| 6 | 3번째 차 상점 **Wheels 탭 자동**(`fixflat` 단계에 `shop="Wheel"`) | 1 | 없음 | wr-dev 파일이지만 한 줄 UI 성격 (`Tutorial.luau:437`) |
| 7 | 스탠드 2개를 **한 자리에서**(앞 가운데에서 Place stands 한 번 → 두 개 차례로 '착'), 걷기 2 없앰 | 1탭·걷기 2 | 중간 — §2b "3동작 직접" 손맛이 약간 줄어듦(펌프 꾹은 남음) | wr-dev (`JackService.luau:454-459`) |
| 8 | Rosa·Tyler **Hand back을 띠 버튼으로**(Start it up처럼). 아니면 최소한 폰 프롬프트 글자 **"Tap" → "Hold"**(꾹 프롬프트인데 "Tap"이라 써 있음: Pump 1.5초·Hand back 0.6초) | 걷기 0~1, 실패 탭 줄임 | 낮음 | "Hold" 글자 = **wr-ui만** (`PromptUI.luau:51-61`), 띠 버튼 = wr-dev |
| 9 | Tyler 부품 사러 가기를 **잭 올리기 전으로**(브레이크 끼익 → "새 패드 사 와요" → 카운터 → 잭) — Exit·재진입·걷기 1 없앰 | 2탭·걷기 1 | 중간 — 헌 패드를 보기 전에 사서 '찾았다' 맛이 약해짐. 대신 카운터는 그대로 배움 | wr-dev (`Tutorial.luau:333-391` 순서) |
| 10 | Lower car 다음 **브레이크 시험 자동**(이미 자동 전후 소리가 있음) | 1 | 중간 — "내가 밟아서 조용해짐" 확인 순간이 줄어듦 → **비추천** | wr-dev |
| 11 | Level 2 카드 Nice! — 이미 10초 자동 닫힘. 화면 아무 데나 눌러도 닫히게 | 0 (막힘만 줄임) | 없음 | **wr-ui만** (`Tutorial.luau:808-818`의 카드 모양 쪽) |

**먼저 고칠 막힘(줄이기가 아니라 고장)** — 탭이 늘지만 없으면 진행이 멈춤:
- 🐞1 Rosa "Scan the car" 버튼 없음 → 튜토리얼 차일 때도 작업 카드 Scan 버튼을 보이게(띠가 이미 "Scan the car"라고 하므로 중복 아님) 또는 띠에 Scan 버튼 추가. **UI만**(`JobCard.luau:140-141` 조건) — wr-ui 가능.
- 🐞2 Tyler "Final check" 버튼이 게임 어디에도 없음 → 고친 차(Fixed)일 때 작업 카드에 **Final check** 버튼(`btn.finalCheck` 글자는 이미 있음, `JobCard.Scan`이 Fixed면 final로 보냄: `WorkView.luau:497`). **UI만**(JobCard) — wr-ui 가능. 아니면 튜토리얼 단계 빼기(`Tutorial.luau:410-412`, wr-dev).
- 🐞3 3번째 차 브레이크 버튼 없음 → `suspects` 단계에 `action="brake"`(`Tutorial.luau:430`) — wr-dev. 추리의 핵심(단서 2개 중 1개)이라 꼭.
- 🐞4 3번째 차 잭 안내 순서 → 못 찾기 전, 스탠드가 없으면 `jackself` 먼저(`Tutorial.luau:426-436`) — wr-dev.

---
## B-1. 잠긴 것 표시 (자물쇠 아이콘 + 회색 둘 다?)

| 곳 | 자물쇠 `UIStyle.Icon.Lock` | 회색 | 빠진 것 |
|---|---|---|---|
| 업그레이드 상점 잠긴 줄 — CM `EquipShop.luau:38-53`(상태), `126-131`(아이콘) | ✅ | △ 글자만 `C.InkSoft`(회청색). 줄·아이콘은 그대로 진함, `UIStyle.Color.Gray`·흐린 버튼 X | 줄 전체(또는 아이콘)를 흐리게 / Gray 판. 머리 주석(2줄)은 "gray"라고 함 |
| 설정 › 정비소 이름(Lv3 전) — CM `Settings.luau:169-192, 203` | ✅ | △ 글자만 `C.InkSoft` | EquipShop과 같은 모양(서로는 일관). 둘 다 같은 식으로 보강 필요 |
| 폐차 감정 카드 Buy 못 함("Need a free bay"/"Parts only") — CM `Appraisal.luau:84-96, 155-157` | ❌ | ❌ 갈색 `rgb(90,70,60)` 직접 색, `UIKit.setButton(..., true)` 안 씀 | 자물쇠(또는 이유 아이콘) + Gray/흐린 버튼. 누르면 아무 반응 없음(이유 알림 X) |
| 공구 줄 — 두 손으로 들 때 칸 어둡게 — CM `Hotbar.luau:136-146, 176-193` | ❌ | 검정 45% 덮개 | 잠깐 막힘(레벨 잠금 아님)이라 자물쇠는 불필요할 수 있음 — 그대로 둬도 됨, 결정만 |
| 딜러 Display/Inspect 버튼 — CM `Dealer.luau:129-135` | ❌ | ❌ | 못 할 때 **아예 숨김** → 그런 기능이 있는지 모름. 잠금으로 보여 줄지 결정 |
| 작업 화면·잭 프롬프트(스탠드 전 Work on wheel 등) — SS `WorkService.luau:313`, SS `JackService.luau:443-459` | ❌ | ❌ | 숨김. 문서 §2b는 "회색 + 이유". PromptUI에 잠긴 모양이 없음(CM `PromptUI.luau`) |
| 부품 상점 — CM `Shop.luau:167-214` | — | — | 레벨 잠금 없음(서버도 없음) → 해당 없음 |
| 이름 칠하기 버튼(서버 확인 중) — CM `NameWindow.luau:58` | — | ✅ `setButton(..., true)` 흐림 | 잠금 아님(잠깐). `UIKit.setButton` 흐림 모양을 쓰는 곳은 **여기 하나뿐** |
- 요약: 자물쇠를 쓰는 곳은 EquipShop·Settings 둘뿐이고 둘 다 "회색"은 글자색만. `UIKit.setButton(b, text, "Gray", true)`(CM `UIKit.luau:619-663` — 흐림 0.35)를 잠금 표시에 같이 쓰면 하나로 맞출 수 있음. 전부 **wr-ui** 범위(Appraisal은 옛 모양 파일이라 UIKit로 옮기는 김에).

## B-2. 닫기 버튼 자리

| 창/카드 | 만드는 방법 | 닫기 자리 | 일관? |
|---|---|---|---|
| 부품 상점 CM `Shop.luau:131` | `UIKit.window` | X 오른쪽 위(CM `UIKit.luau:822-849`, 44~64 px) + 걸어 나가면 자동 | ✅ |
| 업그레이드 상점 CM `EquipShop.luau:70` | `UIKit.window` | X 오른쪽 위 + 걸어 나가면 자동 | ✅ |
| 딜러 CM `Dealer.luau:153` | `UIKit.window` | X 오른쪽 위 | ✅ |
| 설정 CM `Settings.luau:121` | `UIKit.window` | X 오른쪽 위 | ✅ |
| 정비소 이름 CM `NameWindow.luau:89` | `UIKit.window` | X 오른쪽 위 + Paint(아래 가운데) | ✅ |
| 폐차 감정 CM `Appraisal.luau:111-137` | 직접 만든 어두운 Frame | X 오른쪽 위지만 **30×30 px**(다른 창 최소 44), 빨간 글자 "X" 버튼(닫기 그림 아님) | ❌ 크기·모양 |
| 흥정 CM `Haggle.luau:65-66, 108-117` | 직접 만든 Frame(아래 가운데) | X 없음. **Decline** 칸(2×2 버튼 중 오른쪽 아래)이 닫기 역할 | ❌ 다른 방식(의도면 OK — 서버가 닫음) |
| 영수증 CM `Receipt.luau:290-293` | 종이 카드 | X 없음, 아래 가운데 **Nice** 하나(결정 문서 receipt_decision.md: 일부러) | △ 의도된 예외 |
| 레벨 업 카드 CM `Tutorial.luau:775-825` | `UIKit.plate` | X 없음, 아래 가운데 **Nice!** + 10초 자동 | △ 영수증과는 일관 |
| 게이트 카드 CM `Gate.luau:174-205` | `UIKit.plate` | 닫기 없음, 오른쪽에 행동 버튼 하나 | △ 알림 띠 성격 |
| 작업 화면 CM `WorkViewUI.luau:67-82` | 버튼 2개 | **Exit = 왼쪽 아래**(엄지 자리, Gray) | △ 창이 아니라 '모드 나가기' — 문서 §2 의도 |
| 복원 카드 CM `RestoreCard.luau:112-116`, 작업 카드 CM `JobCard.luau` | plate | 닫기 없음(가까운 차 따라 자동) | — 정보 카드 |
| 영상 장면 CM `Cinema.luau:89-108` | 검은 띠 | 화면 탭 = 건너뛰기 | — |
- 정리: 진짜 '창'은 모두 `UIKit.window` → X 오른쪽 위로 일관. 어긋난 곳은 **Appraisal(작은 X, 옛 모양)** 하나가 뚜렷하고, Haggle은 X 없이 Decline. 카드류(영수증·레벨 업)는 "아래 가운데 Nice 하나"로 서로 일관 — 규칙으로 적어 두면 됨(창 = 오른쪽 위 X, 축하 카드 = 아래 Nice).
