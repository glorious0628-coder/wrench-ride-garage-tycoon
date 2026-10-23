# 도시 테마 (town_theme) — v0.2 (wr-design, 2026-10-21)

> **메인 결정(10-21, `notes/gpt/main/detroit_plan_main_decision.md`)**: 도시 이름 = **Gearport**, 길·동네 이름 = wr-builder 계획 §1(Piston Avenue · Chassis Street · Brickyard Heights · The Old Works · Market Hall · Union Depot · SkyLoop · Midtown). 아래 v0.1의 Pistonbrook·Maple Row·Showroom Row 제안은 **대체됨** — 이야기 톤(§2)·레벨 연결(§4)·시대 차 연결(§5)·피할 것(§6)은 그대로 씀. 남은 걱정: Gearport 상표 출원 기록(§1) → 출시 전 상표 확인. 놀이 연결 = `gearport_links.md`.

> 사용자(10-21): "디트로이트 시티 … 미국에 자동차로 유명했다던 그거 모티브로 지어보는 거 어떨까 재밋을 것 같애".
> → 실제 자동차 도시의 **일반적인 이야기**(강가 공방 → 조립 공장 → 크루즈 문화 → 공장이 줄어듦 → 다시 차를 고치고 만드는 사람들)를 모티브로 한 **가상 도시**. 실제 도시·거리·행사·회사·인물 이름 X(Detroit, Motor City, Motown(음반 상표), Woodward, Belle Isle, River Rouge 등).
> 토론: GPT 1라운드 `notes/gpt/wr-design/town_r1_*`(이름 겹침·톤·범위·연결 지적 받아들임). 맵 배치 = wr-builder, 역사 근거 = wr-carbook(board로 부탁).
> 원문 영어, 9~15세 서양 아이들. **사용자 OK 전엔 제안**.

## 1. 도시 이름 — **Pistonbrook**
| 후보 | 판정 |
|---|---|
| **Pistonbrook** ✅ | 피스톤(차) + 시냇물(강가 공방 이야기). 짧고 읽기 쉬움. Bing 정확 검색에서 같은 이름 사용처를 못 찾음(10-21) |
| Boltbrook | 예비 1순위(같은 검색에서 사용처 못 찾음) |
| Gearport | X — 자동차·부품 분야에서 이미 쓰임(출원 자료 있음, GPT 확인) |
| Rivet City | X — 유명 게임의 도시 이름 |
| Sparkbend | X — 같은 이름의 앱이 있음 |
| Piston Falls · Torqueville · New Axle | X — 폭포 지형 필요 / 철자 어려움 / 제품명 같음 |
- **출시 전 상표 확인은 사용자·메인이 따로**(빠른 검색일 뿐).
- 도시 표지판(영어): **"Welcome to Pistonbrook — Where Cars Come Back to Life"**.

## 2. 이야기 (톤: 쇠락 구경 X → **이웃이 아끼는 차를 다시 달리게 하는 따뜻한 이야기**)
| 시대 | 도시 이야기 (게임 속 설정) | 이어지는 시대 차 |
|---|---|---|
| 1880~90년대 | 강가 마차 공방에서 한 발명가가 **손으로 만든 모터 마차**를 몰고 나왔다는 동네 전설 | **Pioneer Carriage**("A motor carriage from the dawn of the automobile." — '세계 최초' 아님) |
| 1910~20년대 | 강을 따라 공장이 생기고 **여러 사람이 부품을 이어 붙이는 조립 라인**으로 차를 만듦 | (나중) Openroad Tourer · Roundstep Sedan |
| 1950년대 | 금요일 밤 번쩍이는 크루저들이 큰길을 천천히 도는 **Cruise Night**, 주말 차 전시 | **Starlane Cruiser** |
| 1970~2000년대 | 공장이 하나둘 줄고 옛 공장 땅 한쪽이 폐차장이 됨 — **그래도 주민과 가게는 계속 살아 있었음** | (나중) Squareway Wagon · Lowbeam Coupe |
| 지금 | 동네 사람들이 다시 차를 고치고 아낌. 요즘은 조용한 전기차도 다님 | **Quietline EV**(손님 차) |
- 플레이어 = 동네 작은 정비소를 맡은 사람. 목표 문구: **"Keep Pistonbrook rolling, one car at a time."**
- 하지 않는 것: '버려진 도시' 구경거리, 주민이 무력했던 것처럼 보이는 연출, 실제 공장·거리 모양 따라 하기.

## 3. 동네 (지금 맵에 이름만 붙이는 것부터)
| 동네 (영어 간판) | 지금 맵 (world_contract) | 할 수 있는 것 | 언제 |
|---|---|---|---|
| **Maple Row** (우리 동네 — 'Heights' 대신, 실제 지명 연상 피함) | 정비소·길 건너 주택가·가게 거리 | 손님 정비(루프 A), 단골 Rosa의 꽃집 **"Rosa's Blooms"**, Roadside Call | **v1** |
| **The Old Works** (옛 공장 땅) | 폐차장(`Junkyard`) — 간판 **"Old Works Salvage"** | 폐차 감정·매입(루프 B), 고철, (v2) 옛 공방 헛간 단서 | **v1** |
| **Showroom Row** (시내 쪽 — 'Grand Boulevard' 대신) | 쇼룸(`Showroom`) — 간판 **"Showroom Row Motors"** | 쇼룸 바이어(시내 사람·수집가), 박물관 전시 벽 | **v1** |
| (Cruise Night) — 동네가 아니라 **이벤트** | 지금 큰길(교차로·가게 거리) | 격주 **Car Show Weekend**를 이 이름으로: 복원한 크루저가 큰길을 천천히 돎(retention_social §3) | **v2** |
| **Riverside Depot** (강가 창고·철길) | 없음(새 공간) | 배달 밴 손님(Tyler 회사 "Riverside Parcel"), 부품 배송 | **v3** |
| **Proving Grounds** (옛 시험 주행장) | 없음(새 공간 — 지금은 시운전 짧은 길) | 시운전·Pit Stop Rush·다이노 | **v3** |
- **v1 = 이름·간판·이야기 글만**(지금 맵, 새 건물 X). v2 = 이벤트 이름 + 공방 단서. v3 = 새 공간을 하나씩(업데이트 리듬 — retention_social §7).

## 4. 레벨과 '동네가 살아남' 연결 (기존 보상에 작은 시각 변화만)
| Lv (economy) | 이미 있는 보상 | 붙일 작은 변화 |
|---|---|---|
| 4 | 단골 Rosa | **Rosa's Blooms 간판에 불이 켜짐**, 가게 앞 화분 |
| 7 | 단골 Tyler, Roadside Call | Tyler의 배달 차가 **동네 길을 다시 돎** |
| 8 | 폐차장·견인 | **Old Works Salvage 문이 열림**(바리케이드 치움 — 맵에 이미 있음) |
| 9 | 쇼룸 1칸 | **Showroom Row Motors 개장** 리본 |
| 11 | Barn Find 단서 | **공방 장부 조각**(§5) 첫 장 |
| 16 | 대형 모터스 | 정비소 간판이 큰 네온으로, 동네 신문 벽보 "Maple Row's Best Garage" |
- 도시 전체가 갑자기 밝아지는 연출 X(규모 크고, 주민이 무력했던 것처럼 보임 — GPT 지적).

## 5. 시대 차 이야기 연결 (한 공방이 다 만든 게 아니라, 차마다 자기 길)
| 차 | 이야기로 들어오는 길 |
|---|---|
| Pioneer Carriage | **옛 공방 장부(Workshop Ledger) 조각**: Barn Find 단서 = 장부 페이지. 20장을 모으면 **"the old carriage house by the brook"** 위치가 열림 → 방수포 공개. (단서 20개 = era_cars §2 확정 규칙과 같음) |
| Starlane Cruiser | **Old Works Salvage 기록**: Lv8 폐차장이 열리면 사장이 "We've had this one since the Cruise Night days." — 확정 복원 의뢰 |
| Quietline EV | 그냥 **요즘 손님 차**(Lv6+). 새 공장 이야기는 만들지 않음(손님 대사 한 줄이면 충분: "It's quiet, right? Everyone in Maple Row is getting one.") |
| (나중) 배달 밴 | Tyler 회사 "Riverside Parcel" — Riverside Depot(v3)와 연결 |

## 6. 실제 자동차 도시 역사에서 가져올 것 / 피할 것
| 가져올 것(일반적 소재 — 게임 행동으로) | 피할 것 |
|---|---|
| 손으로 만든 초기 차 → Pioneer Carriage 수리 | 특정 공장·거리·행사 이름과 모양 |
| 여러 사람이 부품을 이어 붙이는 **조립 라인** → 협동(둘이 들기·각자 다른 부품) 설명 그림 | 실제 회사 로고·창업자 이름 |
| 해마다 바뀌는 디자인 → 도감 '시대별 모습' | 공장 폐쇄를 '폐허 구경'으로 |
| 주말 크루즈·차 전시 문화 → Car Show Weekend | 실제 도시·주민 비하로 읽힐 표현 |
- 역사 근거는 **wr-carbook**이 history.md에 출처와 함께(board로 부탁). GPT가 준 참고: 자동차 도시 역사 박물관 전시·조립 라인 역사 페이지(town_r1_a.md 링크).

## 7. wr-builder에게 (v1 — 간판·표지판만)
- 도시 입구 표지판 "Welcome to Pistonbrook — Where Cars Come Back to Life", 동네 표지판 3개(Maple Row / The Old Works / Showroom Row), 간판 3개(Rosa's Blooms / Old Works Salvage / Showroom Row Motors), Lv 연결 시각 변화(§4)는 코드가 켜고 끌 수 있게 이름 붙인 Part로.
- 모든 글자 영어, 실제 상표 X, 그림체 B.

## 8. 결정 필요 (사용자)
- 도시 이름 **Pistonbrook**(예비 Boltbrook) — 출시 전 상표 확인 포함.
- v1 범위(이름·간판만)로 시작하는 데 동의?
