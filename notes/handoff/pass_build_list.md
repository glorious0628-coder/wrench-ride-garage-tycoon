# 메인이 만들 목록 — 게임 패스·개발자 상품 (wr-pass, 2026-10-22, 사용자 결정 반영)

> **만들기·판매 켜기 = 메인.** 만든 직후엔 **전부 판매 꺼짐**, 10/28 문(구매 시험)을 통과한 것만 10/31에 켬. 장부 `art/roblox_gamepasses.json`(패스) · 개발자 상품은 `art/roblox_devproducts.json`(새로 — 도구도 새로 필요: `tools/create_devproduct.py`, Open Cloud developer-products). 글자 제한: 패스·상품 이름 50자, 설명 1000자.
> 설명은 쉬운 말, 사실만(과장·"GET IT NOW" X). 아이콘 512×512 원 안(wr-art, 10/25까지). 코드 쪽 이름표(`Config.Passes` / `Config.Products` 키)는 wr-dev 몫.

## A. 게임 패스 — 새로 2개 + 번호 바꿔 쓰기 1개 (+ 이미 있는 2개는 그대로)
| # | Config 키 | 이름 EN / KO | 값 R$ | 설명 EN | 설명 KO | 아이콘 |
|---|---|---|---|---|---|---|
| 1 | `PayBoost` (**새 패스**) | Pay Boost / 수리비 부스트 | **249** | Earn 1.5x on repair pay and tips. Helps you buy equipment sooner. Your Garage Level still grows only by fixing cars. | 수리비와 팁을 1.5배로 받아요. 장비를 더 일찍 살 수 있어요. 정비소 레벨은 지금처럼 차를 고쳐야 올라요. | `art/ui/gamepass/512/pay_boost.png` (wr-art 새로) |
| 2 | `VIPMechanic` (**새 패스**) | VIP Mechanic / VIP 정비사 | **299** | VIP name tag, gold work clothes, a VIP couch in the waiting room, and you walk 10% faster. Doesn't change your Garage Level or the records. | VIP 이름표, 금색 작업복, 대기실 VIP 소파, 걷기가 10% 빨라져요. 정비소 레벨과 기록·순위는 그대로예요. | `art/ui/gamepass/512/vip_mechanic.png` (wr-art 새로) |
| 3 | `StarterPack` (**기존 Starter Look 번호 2045222683를 바꿔 씀** — `create_gamepass.py --update 2045222683 --name … --price 99 --description … --image …`) | Starter Pack / 시작 묶음 | **99** (49 → 99) | A work outfit, a gold wrench handle, and $750 to start. One per player, one time. | 작업복, 금색 렌치 손잡이, 시작 돈 $750. 한 사람에 한 번이에요. | `art/ui/gamepass/512/starter_pack.png` (wr-art — 기존 Starter Look 그림에 돈 봉투 더해 새로 그림) |
| — | `GarageRename` | (그대로) Garage Rename | 299 | 그대로 | 그대로 | 그대로 |
| — | `GoldTools` | (그대로) Gold Tools | 249 | 그대로 | 그대로 | 그대로(150 px 시험) |

(메인이 말한 "패스 2개" = 1·2번 새 패스. **3번 Starter Pack을 패스로 한 이유**: '한 사람 한 번'이 게임 패스에선 저절로 지켜져요. 개발자 상품으로 하면 여러 번 살 수 있어서 코드로 막아야 해요. 이게 싫으면 개발자 상품으로 만들고 wr-dev가 "이미 받음이면 구매 창 안 열기 + 영수증은 환불 처리"를 더해야 해요 → 패스 추천.)

## B. 개발자 상품 — 새로 3개 (Cash Envelope)
이름 앞에 '봉투'만 보이게 짧게. 값은 코드가 `GetProductInfo`로 읽음(지역 가격 켜기).
| # | Config 키 | 이름 EN / KO | 값 R$ | 설명 EN | 설명 KO | 아이콘 |
|---|---|---|---|---|---|---|
| 4 | `CashSmall` | Cash Envelope - Small / 돈 봉투 (작은 것) | **49** | Cash for about 10 minutes of work at your level. Doesn't change your Garage Level. | 지금 레벨에서 약 10분 일한 만큼의 돈이에요. 정비소 레벨은 그대로예요. | `art/ui/gamepass/512/envelope_small.png` |
| 5 | `CashMedium` | Cash Envelope - Medium / 돈 봉투 (중간) | **129** | Cash for about 30 minutes of work at your level. Doesn't change your Garage Level. | 지금 레벨에서 약 30분 일한 만큼의 돈이에요. 정비소 레벨은 그대로예요. | `…/envelope_medium.png` |
| 6 | `CashBig` | Cash Envelope - Big / 돈 봉투 (큰 것) | **299** | Cash for about 90 minutes of work at your level. Doesn't change your Garage Level. | 지금 레벨에서 약 90분 일한 만큼의 돈이에요. 정비소 레벨은 그대로예요. | `…/envelope_big.png` |
- 받는 돈(혼자 시간당 돈 × 10/30/90분): **Lv1~5** $480 / $1,450 / $4,350 · **Lv6~15** $750 / $2,250 / $6,750 · **Lv16+** $870 / $2,600 / $7,800. 사기 전 화면에 "You get $X now · Amounts rise at Lv6 and Lv16" / "지금 $X 받아요 · Lv6, Lv16에서 올라요". Pay Boost로 안 곱함. **하루 상한 = 큰 봉투 한 개어치(90분)** — 넘으면 구매 창 안 열고 "내일 다시" 알림(카운트다운 X).
- (메인이 말한 "개발자 상품 4개"에서 4번째로 생각한 건 아마 Starter Pack인데, 위 이유로 패스로 둠. 개발자 상품 = 봉투 3개.)

## C. 순서 (메인)
1. 10/26 전에: wr-art 아이콘 5장 오면 → 패스 1·2 만들기, 패스 3 `--update`, `create_devproduct.py` 새로(메인) 후 상품 4~6 만들기. 전부 **판매 꺼짐**. id를 `Config`(wr-dev에 board로)와 장부에.
2. 10/28 문 통과 후 10/31 `--for-sale` 켜기(통과 못 한 것은 켜지 않음).
3. 값·이름을 바꿀 땐 사용자 OK.
