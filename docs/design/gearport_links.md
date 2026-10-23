# Gearport 놀이 연결 2개 (gearport_links) — v0.1 (wr-design, 2026-10-21) — 크기 S

> 근거: 메인 결론 `notes/gpt/main/detroit_plan_main_decision.md`(도시 = **Gearport**, Market Hall·Union Depot, '상태 랜덤 중고 부품 시장'은 GPT 반박으로 버림), 계획 `notes/design/detroit_town_plan.md`(wr-builder).
> 원칙: **게임 규칙·균형은 그대로**(부품 상태·수리 규칙·신품 100% 구매·손님 종류·보상). 마을은 '들르면 작은 좋은 일', **안 가도 손해 없음**.
> 자리 이름은 wr-builder가 world_contract ★로 올림 → 아래 이름은 제안.

## ① Market Hall 부품 노점 — 하루 한 번 할인 전표
| 항목 | 규칙 |
|---|---|
| 어디 | Market Hall 안 부품 노점 **"Dot's Parts Stall"**(오리지널 이름) — 표시점 제안 `Town.MarketHall.PartsStall.ServicePoint` |
| 언제부터 | **Lv3**(부품 상점에 부품이 여러 종류가 된 뒤) |
| 받는 것 | **"Parts Counter Coupon"** 1장: 정비소 부품 카운터에서 **부품 하나를 15% 싸게**(최대 $40 할인) |
| 하루 | **UTC 하루 1번** 받기(Daily Toolbox와 같은 시계) |
| 쌓임 | **1장만 들고 있을 수 있음**, 안 쓰면 **사라지지 않음**(다음 날 또 못 받을 뿐) — 놓쳐도 손해 X, 쌓아서 한 번에 X |
| 쓰는 법 | 부품 카운터에서 살 때 자동 적용(가장 비싼 부품 하나에) + 영수증 줄 "Coupon −$X" |
| 부품 | **신품 그대로**(상태·값·수리 규칙 안 바뀜) |
| 협동 | 사람마다 자기 전표(자기가 산 부품에만). 남에게 못 줌 |
| 노점 대사 (영어) | 받을 때 "Here's today's coupon — use it at your garage counter!" / 이미 받았을 때 "Come back tomorrow, friend!" + 날마다 바뀌는 **"Did you know?" 한 줄**(wr-carbook 노트, 예: "Brake pads have a tiny metal tab that squeals when they're worn out.") |
- **Daily Toolbox(retention_social §1)와 안 겹치는 이유**: Toolbox = 정비소 메뉴에서 Cash·외형(어디서나), 전표 = **마을에 가야 받는 작은 할인**(마을 구경 이유). 보상 종류(현금 vs 할인)·자리(메뉴 vs 마을)가 다름.
- 크기: 하루 최대 $40 ≈ 초반 일 1건의 ⅕ → 경제 영향 거의 없음(시뮬 불필요).
- Config 제안: `Config.Coupon = { MinLevel = 3, Pct = 0.15, MaxOff = 40, Hold = 1 }`.

## ② Union Depot — 열차 도착 = VIP 손님 예고
| 항목 | 규칙 |
|---|---|
| 무엇 | 기존 **VIP Rush**(alpha_scope §1-1: Lv6+, 2명 이상, 15분에 1번, 선택) · **VIP**(Lv16, 손님 10%)가 정비소에 오기 **약 60초 전**, 열차(또는 SkyLoop)가 Union Depot에 들어오는 연출 |
| 예고 | 멀리서 기적 소리(정비소에서도 작게 들림) + 작은 띠 **"A VIP just arrived at Union Depot — they'll be at your garage soon."** |
| 그다음 | VIP 차는 **평소처럼 정비소로 옴**(손님 규칙·보상·인내심 그대로, 인내심 시계는 차가 베이에 선 뒤부터) |
| 역에 가면 | 역에 있던 사람은 VIP가 열차에서 내려 차에 타는 모습을 봄(꾸밈) — **보상 X, 가라고 강제 X** |
| 띠 횟수 | 띠는 **10분에 1번까지**(Lv16 VIP가 자주 오면 기적 소리만) |
| 새 손님 종류 | **X** |
- 코드: 서버가 VIP 생성 60초 전에 `Town.UnionDepot` 열차 연출 이벤트(클라이언트 꾸밈 스크립트 — 메인 결정 2: SkyLoop는 클라이언트 꾸밈)만 쏨. 게임 규칙 X.
- Config 제안: `Config.VipPreviewSeconds = 60`, `Config.VipBannerCooldown = 600`.

## town_theme와의 관계
- 도시 이름은 메인 결정대로 **Gearport**(town_theme v0.1의 Pistonbrook 제안은 대체됨). 남는 걱정 한 줄: 'Gearport'는 자동차 부품 분야 상표 출원 기록이 있다는 GPT 확인이 있었어요(town_r1_a.md 링크) → **출시 전 상표 확인**만 꼭.
- 길·동네 이름은 wr-builder 계획 §1(Piston Avenue, Chassis Street, Brickyard Heights, The Old Works, Market Hall, Union Depot, SkyLoop, Midtown).
