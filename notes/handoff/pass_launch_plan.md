# 게임 패스 지금 상태 + 10/31 공개 판 계획 (wr-pass, 2026-10-22)

> 결정 1장 = `notes/handoff/pass_decisions_1022.md`. 설계 = `docs/design/monetization.md`(이제 wr-pass가 주인).
> 사용자 결정 반영 완료(10-22). 규칙: **효과가 게임에 없는 패스는 팔지 않음** · 품질 안 되면 안 팖 · 만들기·값·판매 켜기 = 사용자 OK 뒤 메인.

## 1. 지금 상태 (10-22 점검 — grep `Config.Passes`·`MarketplaceService`·`Passes.owns`)

코드 바탕: `Config.Passes`(id 5개) + 서버 `Modules/Passes.luau` `Passes.owns(player, name)`(Roblox에 한 번 묻고 기억, 게임 안에서 사면 바로 반영). 효과를 실제로 쓰는 곳은 **`NameService.luau:185`(GarageRename) 하나뿐**. `PaidSpeed`·`ProcessReceipt`·`PromptProductPurchase`·`PolicyService`·상점 'Robux' 칸 = 없음(`Equipment.luau`는 "Game cash only — never Robux").

| 패스 | id · 값 | 게임 안 효과 코드 | 아이콘 (512, 업로드됨) | 10/31에 팔 수 있나 |
|---|---|---|---|---|
| Garage Rename | 2046200362 · 299 | ✅ 있음 — 첫 이름 무료 → 그 뒤 `rename.need` 글 + `PromptGamePassPurchase`(`NameWindow.luau:132`) | ✅ | **✅ 가능** — 남은 것: 다른 계정으로 살 때 흐름 시험(만든 계정은 다 '가짐'으로 나옴), 아이콘 150 px 다시 보기 |
| Gold Tools | 2045396387 · 249 | ❌ 없음(금색 모양·볼트 −10 %·기록 끔 모두 X) | ✅ (금+검정 = 공구 브랜드 색 닮음 지적 있었음 → 150 px 때 같이) | **🔨 가능(S)** — wr-dev가 `Config.PaidSpeed = 0.10` + 산 사람 공구만 금색 재질·소리. 공구 3D가 새로 바뀌어도 재질만 바꾸면 따라감 |
| Paint Pro | 2045384384 · 249 | ❌ — 플레이어가 차를 칠하는 기능 자체가 없음(바디 숍 = 공개 뒤 Lv14/16, `shop_areas.md`) | ✅ | **❌ 공개 뒤**(바디 숍과 같이) |
| Neon Garage | 2043716463 · 199 | ❌ — 정비소 조명 테마 없음(`NeonSign`은 이름 간판일 뿐) | ✅ | **❌ 공개 뒤**(wr-builder 테마 3개 + 고르는 창) |
| Custom Sign | 2044412404 · 99 | ❌ — 간판 모양·색·글꼴 고르기 없음(이름 창만 있음) | ✅ | **❌ 공개 뒤**(이름 창에 칸 더하기 — wr-ui-2 M) |
| Starter Look | 2045222683 · 49 | ❌ — 그리고 **`Config.Passes`에 id가 아예 없음** | ✅ (v2 그림) | **🔁 결정 4에 따라** — '시작 묶음 99'로 같은 id를 바꾸거나(추천), 아니면 공개 뒤 |

전부 지금 **판매 꺼짐**(`art/roblox_gamepasses.json` forSale false). AI 티 점검(wr-gamer)은 패스 그림 6장 = '조금'(광택 많음) → 판매 켤 때 150 px·게임 모습과 나란히 다시 보기.

## 2. 10/31 공개 판 — 확정 (사용자 결정 10-22 반영, 판매 켜기는 품질·시험 통과한 것만)

| | 상품 | 조건 |
|---|---|---|
| **판다** | Garage Rename 299 (효과 ✅ 이미 있음) | 다른 계정 구매 흐름 시험 |
| **판다** | Gold Tools 249 | wr-dev 코드(금색·볼트 −10 %·기록 끔) + 금색 모양 품질 |
| **판다 (사용자 결정)** | Pay Boost ×1.5 249 · Starter Pack 99 · VIP Mechanic 299 · Cash Envelope 49/129/299 | 각자 문 통과(아래 §3 10/28). **봉투는 저장 시험(산 뒤 나가기·서버 꺼짐·두 번 누르기·하루 상한)이 제일 센 문 — 못 넘으면 11/7**. **VIP는 소파 3D·옷이 품질 안 되면 이름표+걷기만 켜거나 11/14로** (사용자 "퀄리티 없으면 안 넣는 걸루") |
| **공개 뒤** | Paint Pro(바디 숍과) · Neon Garage · Custom Sign · Quick Tow · Junkyard Radar · 구독 · 선물 | 기능·그림이 생기면 하나씩 |
| **안 함** | 유료 뽑기 · 광고 보상 · 레벨·평판·새 일·베이·장비 | — |

만들 목록(이름·값·설명 영/한·아이콘) = `notes/handoff/pass_build_list.md`. 유료 빨라짐 합계 = Gold Tools 일 −3 % + VIP 걷기 +10 % → **`Config.PaidSpeed` 10 % 상한 안**(wr-dev가 '일 걸리는 시간' 기준으로 합계를 재서 넘으면 VIP 걷기를 낮춤).

## 3. 할 일과 날짜 (확정)

| 날짜 | 누가 | 할 일 | 크기 |
|---|---|---|---|
| 10/22~24 | **wr-dev** | ① `Config.PaidSpeed = 0.10` + Gold Tools 효과(산 사람 공구만 볼트 ×0.9, 금색 재질·소리, 기록 모드 0) ② `Config.Passes`에 `PayBoost`·`VIPMechanic`·`StarterPack`(= 2045222683) 자리 ③ **Pay Boost**: `JobService.release`에서 산 사람 몫 수리비+팁만 ×1.5(부품값·복원 판매·평판·친구 몫 X, 기록 모드 X), 정산 카드 줄 "Pay Boost +$X" ④ **Starter Pack**: 패스 가진 걸 처음 알면 $750 한 번(저장 깃발 `starterPackGiven` — 저장 성공 뒤에 깃발) + 금색 렌치 손잡이 ⑤ **VIP**: 이름표·금색 작업복·걷기 +10 %(`PaidSpeed` 합계 안, 기록·순위 0, 대기실 소파는 wr-builder/3D) | M |
| 10/24~26 | **wr-dev** | **Cash Envelope**: `ProcessReceipt`(저장 성공 뒤에만 `PurchaseGranted`, 영수증 id를 저장해 두 번 안 줌, 하루 90분어치 상한은 서버 시계 기준 날짜), 레벨 구간 금액 표, `GetProductInfo`로 값 읽기, 서버 시험 모드(가짜 영수증) | M |
| 10/24~26 | **wr-ui-2** | 카운터 상점 **'Robux' 칸** + HUD 작은 가게 단추(강요 창·카운트다운·"GET IT NOW" X, 한 줄 설명, 산 건 "Owned", `PolicyService`) · 봉투 사기 전 화면 "You get $X now · Amounts rise at Lv6 and Lv16" · 공구 상점에서 돈이 모자랄 때만 그 줄 안 작은 회색 글 "Need $400 more · Cash options" · 레벨 업·정산 카드·월드 프롬프트에 광고 X | M |
| 10/24~25 | **wr-art** | 새 아이콘 5장(`pay_boost`·`vip_mechanic`·`starter_pack`·`envelope_small/medium/big` = 6장) + 기존 6장 150 px·48 px 시험 시트 | S |
| 10/24 | wr-design → wr-carbook | 상품 이름·설명 영·한 검토(쉬운 말) — 초안은 `pass_build_list.md` | S |
| 10/24~27 | **wr-builder / 3D** | VIP 소파(대기실, 파트로 가능하면 파트) · 금색 작업복은 옷 텍스처 | S |
| 10/26 | 메인 | `pass_build_list.md`대로 만들기(판매 꺼짐): 새 패스 2 + Starter 번호 업데이트 + 개발자 상품 3(도구 `create_devproduct.py` 새로) | — |
| 10/28 | 메인 + wr-play + wr-pass | **문**: 다른 계정/Studio 시험 구매로 상품마다 효과·저장·조르는 느낌 GPT 검수. 통과 못 한 것은 공개 판에서 뺌 | — |
| 10/29 | — | 사람 시험 — 판매는 꺼 둠 | — |
| 10/31 | 메인(사용자 OK) | 통과한 것만 `--for-sale` 켜기 + 장부 갱신 | — |
| 11/7 | wr-dev | (못 통과 시) Cash Envelope · 11/14 VIP(소파 3D 지연 시) | — |
| 공개 2주 뒤 | wr-pass | 진짜 숫자로 다시: 패스별 산 비율, 1인 R$, D1/D7, 장비 산 시간·남은 돈 | — |

## 4. launch.md에 넣을 줄 (메인에게 부탁 — §C 공개 직전 표, '게임 패스는 기능 있는 것만 판매 켜기' 줄을 이걸로 바꿈)
```
| 🔨 | **게임 패스·상품(wr-pass)** — 사용자 결정 ✅ 10-22 · 공개 판 = Garage Rename(✅ 효과 있음)·Gold Tools·Pay Boost 249·Starter Pack 99·VIP 299·Cash Envelope 49/129/299(10/28 문 통과한 것만, 봉투=저장 시험) · 상점 'Robux' 칸 wr-ui-2 · 아이콘 wr-art · 10/28 다른 계정 구매 시험(문) · 10/31 통과한 것만 판매 켜기(메인) · Paint Pro·Neon·Custom Sign·VIP = 공개 뒤 — 계획 `notes/handoff/pass_launch_plan.md` | wr-pass → wr-dev·wr-ui-2·wr-art → 메인 |
```
