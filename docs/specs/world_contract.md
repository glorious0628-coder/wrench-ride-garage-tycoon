# 맵 ↔ 코드 약속 (world_contract) — v1 (10-20, wr-builder) · 맵 WorldVersion 18

wr-dev 코드가 맵에서 찾을 **이름·자리·방향** 약속이에요. 이 이름은 바꾸지 않아요(바꿔야 하면 board.md에 먼저).
맵은 짓기 코드로 만들어요: `src/ServerScriptService/World/` (wr-builder 몫).

## 1. 기본
- 맵 전체 = `workspace.Garage` (Model). 속성 `WorldVersion`(지금 23 — 23: 베이 1 앞 진입로(★ Curbside — 대기 칸 `Queue.*` + 길가 일 `Curb.*`) + 차 길 찻길 위로(`Traffic.EntryTurn`·`ExitTurn`, 진입로 벌림), Parking1~4 표시점 없앰, `ShowCamera` 옮김, 22: 할로윈(★ 할로윈 — 장면 카메라 표시점·트로피 선반·기간 장식) + 둥근 기름 자국, 21: 베이 부품 카트, 20: 정비소 앞면 세 시대(★ 정비소가 자란다) + 스폰 자리 옮김 + 대기실 사진 벽 자리, 19: 3D 거리 소품(고증 노트 street_props.md대로) + SkyLoop 역(양쪽 승강장·지붕·엘리베이터 탑) + 열차 앞코, 18: Gearport 4단계 SkyLoop + 3단계 검수(톱니 방향·침목·글자틀 뒷면), 17: 거리 소품(파트, `Town.StreetProps`) + 강가 옛날식 가로등, 16: Gearport 3단계(Market Hall·Foundry Road·Old Works·철길 마당), 15: Gearport 2단계(집 동네·강가·스카이라인·역·맵 끝 벽, 맵 x −440..480 · z −266..480), 14: Gearport 1단계 Piston Avenue(★ Gearport), 13: QA 걷기(문·통로 넓힘, 표시점 몇 개 이동 = 아래 ★ QA 10-21), 12: Lv16 장비(★ Lv16 장비) + 베이 3·4 진짜 건물, 11: 11: 리프트 car_spec v0.7(패드 지름 0.7), 10: 10: 생활감 디테일 + 그림 자리 판(★ 그림 자리), 9: 9: 성능 정리(이름·자리 변화 없음, 코드가 읽는 모델은 ModelStreamingMode Atomic), 8: 8: 루프 B 장소(★ 루프 B) + 폐차장 디테일, 7: 7: 업그레이드로 바뀌는 맵(★ 업그레이드), 6: 교차로·가게 거리·폐차장 블록아웃, 5: 소품·거리·대역 차, 4: 조명 노출 낮춤, 2: 디테일·동네·조명, 3: 장비(리프트·잭·크레인·고물통·소파). v1 이름·자리는 그대로, 새 이름은 아래 ★), `Front = "-Z"`.
- **정비소 앞 = -Z**(길 쪽). 길에서 정비소를 보면 오른쪽이 **-X**(베이 2·3·4 쪽), 왼쪽이 **+X**(대기실·쇼룸 쪽).
- 단위 스터드. 땅(주차장·길) 윗면 **y = 0**, 건물 바닥 윗면 **y = 0.2**, 인도 윗면 0.5.
- 만드는 때: `WorldBoot.server.luau`가 서버 시작 때 `Build.build()` — 이미 같은 버전 맵이 있으면 그대로 둬요(편집 모드에서 구운 맵). **다른 서버 코드는 `workspace:WaitForChild("Garage")`로 기다려요.**
- 템플릿의 기본 `workspace.Baseplate`·`workspace.SpawnLocation`은 맵이 지워요(같은 자리에 겹쳐서). 스폰은 `Garage.SpawnLocation`.
- **표시점(Marker)**: 투명 파트(`Transparency 1`, 안 부딪힘·안 잡힘·안 닿음), 속성 `Marker = true`.
  - `Position` = 그 자리의 **바닥 위 점**(y = 바닥 윗면). `CFrame.LookVector` = 아래 표의 '보는 쪽'.
  - 차 표시점(`CarSpot`·`ApproachSpot`·`Parking*`·`Spot*`)은 크기 8×0.2×18 = 차 바닥 자리. **차 중심을 이 Position에 두고, 차 코를 LookVector 쪽으로.**
- 차 크기 = `docs/specs/car_spec.md` §0: 폭 7.6 × 길이 17 × 높이 5.8, 피벗 = 바퀴 사이 가운데 **땅바닥**, 차 앞 = 로컬 -Z(LookVector). 그래서 **차 놓기 = `car:PivotTo(CarSpot.CFrame)`** 한 줄이면 차 코가 표시점의 LookVector 쪽을 봐요. car_spec이 말한 `CarAnchor` = 이 문서의 `CarSpot`. R15 = 키 5.18, 폭 4(Studio에서 재 봄).
- 레벨 잠금: 늘어날 곳은 Model에 속성 `UnlockLevel`(1 / 6 / 16). 아직 안 지은 곳은 속성 `Placeholder = true` + 분홍 반투명 상자(안 부딪힘). **분홍이 진짜 건물로 바뀌어도 아래 이름·자리는 그대로**예요.

## 2. 이름 표
경로는 모두 `workspace.Garage.` 아래.

### 베이
| 경로 | 종류 | 자리 (Position) | 보는 쪽 | 뜻 |
|---|---|---|---|---|
| `Bays.Bay1` | Model | — | — | Lv1 베이(UnlockLevel 1) |
| `Bays.Bay1.CarSpot` | Marker 8×18 | (0, 0.2, -1) | +Z | 손님 차 서는 자리(차 코가 안쪽 벽) |
| `Bays.Bay1.LiftSpot` | Marker | (0, 0.2, -1) | +Z | 리프트 중심 = CarSpot과 같은 CFrame. 속성 `Installed`(진짜 리프트가 있으면 true — Bay1은 지금 true), `PostOffsetX = 6.0`(car_spec §7: 기둥 = 차 로컬 x ±6.0, z -0.5 → 베이에선 차 코가 +Z라 월드 z = -1 + 0.5) |
| `Bays.Bay1.ApproachSpot` | Marker 8×18 | (0, 0, -36) | +Z | 베이 앞 차로에서 들어가기 직전 자리 |
| `Bays.Bay1.DriverExitSpot` | Marker | (7, 0.2, -3) | +X | 손님이 차에서 내려 서는 자리(운전석 = 차 왼쪽 = +X, 대기실 쪽) |
| `Bays.Bay1.WorkArea` | Marker 26×19.8×38 | 중심 (0, 10.1, 0) | — | '이 베이 안' 판정 상자 |
| `Bays.Bay1.Shutter` | Part 16×0.6×0.4 | 열린 상태로 지음 | — | 롤업 셔터. 속성 `TopY = 14`, `OpenBottomY = 13.4`, `ClosedBottomY = 0.2`. 닫기 = 위 끝(TopY) 고정하고 Size.Y를 늘려 아래 끝을 ClosedBottomY로. 셔터 구멍 = x -8..8, y 0.2..14 |
| `Bays.Bay2` | Model | x -42..-14 | — | **진짜 베이(★ 업그레이드 `Bay2`)** — 사기 전엔 workspace에 없음. 표시점 이름 = Bay1과 같음(CarSpot (-28, 0.2, -1), ApproachSpot (-28, 0, -36), DriverExitSpot (-21, 0.2, -3) …), `Shutter`, `Lift` 있음 |
| `Bays.Bay3` / `Bays.Bay4` | Model | 중심 x -56 / -84 | — | **진짜 베이**(★ 업그레이드 `Bay3` Lv10 / `Bay4` Lv16) — 사기 전엔 workspace에 없음. 표시점 이름 = Bay1과 같음 |

### ★ 리프트 `Bays.Bay1.Lift` (Model, 파트로 지음 — wr-dev 임시 리프트 대신)
| 경로 | 종류 | 뜻 |
|---|---|---|
| `Lift.Carriage` | Model (PrimaryPart `CarriageRoot`) | **움직이는 부분 전부**(기둥 슬라이더 2, 팔 4, 패드 4). 올리기: `Lift.Carriage:PivotTo(Lift.CarriageHome.CFrame + Vector3.yAxis * y)`, y = car_spec 3-3(Ground 0 / Wheel 2 / Under 6). 안 부딪힘 |
| `Lift.CarriageHome` | Marker | Ground 때 Carriage 자리(= LiftSpot CFrame) |
| `Lift.Carriage` 안 `Pad` ×4 | Part | 윗면 = 바닥 + 0.5 + y = 차 `LiftPoint_*`(차 로컬 ±3.0, 0.5, ∓3.0) 바로 아래. 그래서 차 LiftOffset = y와 같이 움직이면 딱 맞아요 |
| `Lift.Control` | Part (노란 상자) | 올림/내림 버튼 상자. **ProximityPrompt는 wr-dev가 여기에 붙여요**(맵은 안 붙임). 자리 = 차 오른쪽 기둥 바깥(월드 x -7.3, 높이 6.4) |
| `Lift.PostL` / `PostR` | Part | 기둥(L/R = 차 기준 왼쪽/오른쪽; 월드로는 PostL x +6, PostR x -6), 높이 13, 위 빔 아래 12.6 → Under 때 차 지붕(12.0)과 0.6 여유 |
- 속성 `Lift.Levels = "Ground=0,Wheel=2,Under=6"`(참고용), **`Lift.Variant` = "Old" | "Hydraulic"**, **`Lift.MaxLevel` = "Wheel" | "Under"**(낡은 리프트는 Wheel까지만 — economy.md Lv1). 두 모양은 이름·구조가 같고(Carriage·Control·CarriageHome), 베이에는 늘 하나만 있어요(★ `HydraulicLift`).

### ★ 업그레이드로 바뀌는 맵 (World/Upgrades, World/Growth — economy.md 1-2 · alpha_scope.md 3)
**규칙**: 바뀌는 조각(Model/Part)에 속성 두 개.
- `UpgradeId` = 상점 물건 id 또는 레벨 문 `"LevelN"`(레벨이 N 이상이면 가진 것으로 봄).
- `UpgradeState` = `"Owned"`(가졌을 때만 보임) / `"Locked"`(아직 안 가졌을 때만 보임 = 사기 전 모습). 참고용 `UnlockLevel`(살 수 있게 되는 레벨)도 붙어 있어요.
- 숨김 = `ServerStorage.WorldHidden`으로 옮김(안 그려지고 안 부딪힘). 다시 보일 땐 원래 부모로(속성 `Home`). **그래서 숨은 동안엔 workspace에서 못 찾아요** — 예: 사기 전엔 `Bays.Bay2`가 없음.
- **코드(wr-dev)가 부르는 것**: `local Upgrades = require(ServerScriptService.World.Upgrades)`
  - `Upgrades.apply({ level = 6, owned = { Bay2 = true, HydraulicLift = true } })` → 바뀐 id 목록. 레벨이 오르거나 물건을 살 때, 그리고 정비소 주인이 들어올 때 한 번.
  - `Upgrades.Changed.Event:Connect(function(ids) ... end)` → 리프트가 바뀌면(`HydraulicLift`) 새 `Lift.Control`에 Prompt를 다시 붙이고 `Lift.MaxLevel`을 읽어요. Bay2가 생기면 그 베이를 손님 차 자리에 넣어요.
  - 맵을 새로 지을 땐 Build가 Lv1 모습(`level = 1, owned = {}`)으로 맞춰 놔요.

| UpgradeId | 살 수 있는 Lv · 값 | Owned(산 뒤) 보이는 것 | Locked(사기 전) 보이는 것 | 코드가 쓸 이름 |
|---|---|---|---|---|
| `PartsShelfPlus` | 3 · $400 | 베이1 벽 선반 `PartsShelfPlus`(x 12.2..13.9, z 1.4..5.8) | — | `PartsShelfPlus.Slots.Slot1..4`(산 부품 놓는 자리), `UsePoint` (10.8, 0.2, 3.6) |
| `Bay2` | 4 · $1,000 | `Bays.Bay2`(건물·셔터·리프트·소품) | `UpgradeSpots.Bay2`(빈 콘크리트 바닥·체인·"BAY 2 COMING SOON") + 베이1 서쪽 앞 홈통 | 베이 표시점(위 베이 표) |
| `WheelBalancer` | 5 · $1,200 | `Tools.WheelBalancer`(베이1 앞 오른쪽 구석) | — | `UsePoint` (10.6, 0.2, -13.6) **-Z**(화면 앞, v13), `WheelMount` (7.6, 3.0, -17.1) |
| `HydraulicLift` | 6 · $2,400 | 모든 베이의 `Lift`가 유압(파랑·노랑, MaxLevel Under) | 낡은 리프트(바랜 회청색, 녹, MaxLevel Wheel) | `Bays.BayN.Lift` (이름 같음) |
| `OBDReader` | 6 · $2,500 | `Tools.OBDStand`(베이1 대기실 문 옆 카트) | — | `UsePoint` (10.6, 0.2, -7.4) +X (v13: 넓힌 문을 비켜 2.6 남쪽) |
| `Level6` | 6 (공짜) | 대기실 의자 2개 더(`WaitingRoom.Seats.Seat7·8`, 보는 쪽 +X) + `SeatsPlus`(틀·탁자·화분) | — | Seat7, Seat8 |
| `TireChanger` | 7 · $2,200 | `Tools.TireChanger`(베이1 서쪽 벽, 타이어 랙 앞) | — | `UsePoint` (-7.6, 0.2, -3.7) -X, `TireMount` (-11.1, 3.4, -3.7) (v32: z −0.3, 3D 누움판 자리) |
| `Level8` | 8 (공짜) | — | 폐차장 길 `Junkyard.Barrier`(+ 표지 `SignTop`·`SignLow` "Opens at Level 8" — 차단기와 같이 사라짐, 맵 v28) | — |
| `PartsWasher` | 9 · $1,500 | `Tools.PartsWasher`(베이1 동쪽, 창문 아래) | — | `UsePoint` (7.8, 0.2, -10.2) +X (v13: 1.6 북쪽) |
| `SpringCompressor` | 11 · $2,500 | `Tools.SpringCompressor`(베이1 서쪽 벽, 탈착기와 랙 사이) | — | `UsePoint` (-10.0, 0.2, 0.4) -X |
| `EngineCrane` | 13 · $7,500 | `Tools.EngineCrane1`(앞 왼쪽 구석) | — | (아직 표시점 없음) |
| `RestorationBay` | 8 · $3,500 | `RestoreBay`(★ 루프 B) | `UpgradeSpots.RestoreBay`(빈 바닥·"RESTORATION BAY COMING SOON") | ★ 루프 B 표 |
| `PaintBooth` | 16 · $20,000 | `PaintBooth`(★ 루프 B) | `UpgradeSpots.PaintBooth` | ★ 루프 B 표 |
| `Level9` / `Level12` / `Level16` | 9 · 12 · 16 (공짜) | `Showroom`(Lv9) / 진열 단상 `Showroom.Platforms.Spot2·3`(Lv12) / `Spot4~6`(Lv16) + 그 칸 가격판 | `UpgradeSpots.Showroom`(빈 바닥) / 단상 자리의 줄 기둥 `Platforms.SpotNLocked` | ★ 루프 B 표 |
| `Bay3` · `Bay4` | 10 · 16 | `Bays.Bay3` / `Bays.Bay4`(Bay2와 같은 건물·셔터·리프트) | `UpgradeSpots.Bay3` / `.Bay4`(빈 바닥 + COMING SOON) + 앞 베이의 서쪽 홈통 | 베이 표시점 같은 이름(CarSpot (-56 / -84, 0.2, -1), ApproachSpot (… , 0, -36), DriverExitSpot (cx + 7, 0.2, -3)) |
| `Alignment` · `Dyno` | **12**(10-22, shop_areas §7) · 16 · $12,000 · $15,000 | `AlignmentBay` / `DynoRoom`(★ Lv16 장비) | `UpgradeSpots.AlignmentBay` / `.DynoRoom` | ★ Lv16 장비 표 |
- id 이름은 제안이에요. wr-dev 상점 코드의 id와 다르면 board로 알려 주세요(맵 쪽을 바꿀게요).
- 손에 드는 공구(Battery Tester, Ratchet/Impact Wrench, Stethoscope, Pressure Tester, 샌더·스프레이건)는 맵에 안 나와요(3D 공구).

### ★ 폐차장 `Junkyard` (Model, UnlockLevel 8 — 지금은 블록아웃, 실사진 notes/research/ref_junkyard)
| 경로 | 종류 | 자리 | 보는 쪽 | 뜻 |
|---|---|---|---|---|
| `Junkyard.Barrier` | Model | 길 시작 z 48 | — | 잠겨 있는 동안 길을 막는 바리케이드(★ `Level8` Locked — Upgrades.apply가 Lv8에서 치움) |
| `Junkyard.JunkyardEntry` | Marker | (47, 0, 192) | +Z | 문 바로 앞 길 위 |
| `Junkyard.Gate` | Model | 문 x 33..61, z 204 | — | 철망 문 두 짝 `GateL`/`GateR`(열린 채로 지음, 속성 `Open = true`; v13: 안쪽 울타리에 붙게 활짝, 철망도 부딪힘) + 간판 "SALVAGE YARD" |
| `Junkyard.Gate.GatePoint` | Marker | (47, 0, 204) | +Z | 문 가운데 |
| `Junkyard.Office` | Model | 컨테이너 x 14..22.8, z 210..231.8 | — | 사무실(폐차 사기·팔기 창구). 창구 = +X 쪽 |
| `Junkyard.Office.ServicePoint` | Marker | (25.4, 0, 224) | -X | 플레이어가 창구 앞에 서는 자리 |
| `Junkyard.Office.DoorPoint` | Marker | (26, 0, 216) | -X | 문 앞 |
| `Junkyard.TowSpot` | Marker 10×30 | (74, 0, 228) | -Z | 견인차가 서는 자리(코가 문 쪽) |
| `Junkyard.WreckSpots.Spot1..10` | Marker 8×18 | 두 줄: x 22(보는 쪽 +X) / x 72(보는 쪽 -X), z 252·268·284·300·316 (홀수 = 왼줄, 짝수 = 오른줄) | 길 쪽 | 살 수 있는 폐차가 놓이는 자리. `car:PivotTo(SpotN.CFrame)`. 바닥에 녹슨 휠 받침 4개(장식) |
| `Junkyard.Piles.Pile1..6` | Model | 뒤쪽·옆 담 | — | 눌린 차 판(블록 대역) 더미(속성 `Placeholder3D = "WreckPile"`) — 나중에 차 메시로 |
| `Junkyard.Crane` / `Crane.CraneSpot` | Model + Marker 16×16 | (118, 0, 316) | +Z | 고철 크레인(궤도·운전석·팔·자석, 파트). 팔은 뒤쪽 더미(+Z)를 향함 |
| `Junkyard.AppraisePoints.Spot1..10` | Marker | 각 폐차 자리 앞(길 쪽) | 차 쪽 | **감정 자리**: 플레이어가 서서 폐차를 둘러보는 곳 |
| `Junkyard.PriceTags.Spot1..10` | Part(노란 판) | 차 앞 모서리 기둥 | 길 쪽 | 값 표시: `PriceTags.SpotN.Label.Price.Text = "$750"` |
| `Junkyard.PartsShed` | Model | 서쪽 담 옆 x -38..-16, z 210..232 | — | 중고 부품 창고(장식: 엔진·배터리·문짝 선반) |
| `Junkyard.DecorWrecks` | Model ×3 | 자리 밖 | — | 장식 녹슨 대역 차(바퀴 없음). 게임 코드가 쓰지 않음 |
- 길: 마당 가운데 자갈 길 x 37..57(z 204..344), 뒤쪽 가로 길 z 326..344(돌아 나가는 곳).

### ★ 장비·고물통
| 경로 | 종류 | 자리 | 뜻 |
|---|---|---|---|
| `ScrapBin` | Model | 베이1 뒤 왼쪽 (-11.2, 14.2), 3.2×3.2×3 열린 통 | 헌 부품 버리는 곳(wr-dev 부탁 ①) |
| `ScrapBin.DropPoint` | Marker | (-8.0, 0.2, 14.2), 보는 쪽 -X | 플레이어가 서는 자리 |
| `ScrapBin.DropSpot` | Marker | (-11.2, 3.2, 14.2) | 통 입구 가운데(부품이 떨어지는 곳) |
| `Tools.FloorJack1` | Model | (10, 0.2, 8.6), 손잡이 +Z | 수동 잭(Lv1). `UsePoint` (10, 0.2, 13.8) 보는 쪽 -Z. 움직이는 건 아직 없음(장식+자리) |
| `Tools.EngineCrane1` | Model | 앞 왼쪽 구석 (x -12.6..-6.6, z -17..-14) | 엔진 크레인(장식). 쓰게 되면 마커 추가 |

- `WaitingRoom.Seats`: 이제 **Seat1~Seat6**(Seat5·6 = 앞 유리창 쪽 소파, 보는 쪽 +Z). 속성 `Facing`.
- 타이어 랙·바깥 진열대의 타이어는 원기둥 자리(속성 `Placeholder3D = "Tire"`) — 차 타이어 메시가 오면 그 메시로 바꿔요.
- 베이1 뒷문 = 뒤 벽 x -3.4..0.6(공구함과 작업대 사이) → 뒷길.
- `Dressing.ParkedCars`의 차(직원 칸 2대·이웃 3대)는 **블록 대역**(속성 `Placeholder3D = "Car"`), 손님 대기 칸 `Parking1..6`·차로에는 두지 않아요. 직원 칸 = 주차장 동쪽 x 74..98(STAFF 글자). `Tools.ToolCart1`(빨간 이동 카트)은 장식.

- Bay1↔Bay2 사이 벽 `Building.ExpansionWallWest`(x -14..-13)는 Bay2를 사도 그대로예요(벽에 공구·랙이 붙어 있어서). 두 베이는 앞 셔터로 드나들어요.

### 작업대·공구
| 경로 | 종류 | 자리 | 보는 쪽 | 뜻 |
|---|---|---|---|---|
| `Workbenches.Workbench1` | Model | 베이1 뒤 벽 오른쪽(x 2..12, z 16.5..19), 윗면 y 3.4 | — | 수리 작업대(부품 재생 미니게임) |
| `Workbenches.Workbench1.WorkPoint` | Marker | (7, 0.2, 14.5) | +Z | 작업대 앞에 서는 자리 |
| `Tools.ToolChest1` | Model | 베이1 뒤 벽 왼쪽(x -11..-4) | — | 빨간 공구함(공구 고르기) |
| `Tools.ToolChest1.UsePoint` | Marker | (-7.5, 0.2, 14.5) | +Z | 공구함 앞 |

### 부품 카운터
| 경로 | 종류 | 자리 | 보는 쪽 | 뜻 |
|---|---|---|---|---|
| `PartsCounter` | Model | 베이1 ↔ 부품실 벽 구멍(z 6..14), 카운터 윗면 y 3.4 | — | 부품 사기·받기 |
| `PartsCounter.ServicePoint` | Marker | (11.5, 0.2, 10) | +X | 플레이어가 서는 자리(베이 쪽) |
| `PartsCounter.StaffPoint` | Marker | (17, 0.2, 10) | -X | 부품 직원(NPC) 자리 |
| `PartsCounter.HandoverPoint` | Marker | (14.5, 3.4, 10) | -X | 산 부품이 나타나는 카운터 위 |
| `PartsShelves.Shelf1..3` | Model | 부품실 안 | — | 장식(선반+상자) |

### 손님 대기실
| 경로 | 종류 | 자리 | 보는 쪽 | 뜻 |
|---|---|---|---|---|
| `WaitingRoom` | Model | x 15..37, z -19..2 | — | 대기실 |
| `WaitingRoom.Seats.Seat1..Seat4` | **Seat** | x 34.6, z -16.5 / -13.5 / -10.5 / -7.5, 높이 2.4 | -X | 손님 NPC 앉는 자리(`Seat:Sit(humanoid)`). 레벨 따라 늘 수 있음 → 폴더 안 Seat를 다 세서 써요 |
| `WaitingRoom.VendingMachine.UsePoint` | Marker | (27, 0.2, -3) | +Z | 자판기 앞 |
| `WaitingRoom.ReceptionDesk.ServicePoint` | Marker | (20.5, 0.2, -11) | +Z | 손님이 접수·계산하는 자리 |
| `WaitingRoom.ReceptionDesk.StaffPoint` | Marker | (20.5, 0.2, -4.5) | -Z | 접수 직원 자리 |
| `WaitingRoom.CustomerDoor` | Marker | (32, 0.2, -21) | +Z | 대기실 정문 바로 밖(주차장 쪽). 정문 x 29..35(빈 폭 5.4) |
| `WaitingRoom.BayDoor` | Marker | (14.5, 0.2, -2) | +X | 베이1 ↔ 대기실 문(**6폭** z -5..1, 높이 8) 가운데 |

- 손님 걸음: 차에서 내림(`DriverExitSpot`) → `BayDoor` → `ReceptionDesk.ServicePoint`(접수) → 빈 `Seat`. 끝나면 `ReceptionDesk.ServicePoint`(계산) → `BayDoor` → 차.

### ★ QA 10-21 (v13) — 걷기 검사로 고친 것 (자세히: notes/playtest/wr-builder/qa_1021.md)
- 옮긴 표시점: `WaitingRoom.BayDoor` (14.5,0.2,-1)→(14.5,0.2,-2) · `ReceptionDesk.ServicePoint` (21,-9)→(20.5,-11) · `ReceptionDesk.StaffPoint` (21,-2.5)→(20.5,-4.5) · `Tools.WheelBalancer.UsePoint` (6.2,-17.1)+X→(10.6,-13.6)-Z · `Tools.OBDStand.UsePoint` (10.6,-4.8)→(10.6,-7.4) · `Tools.PartsWasher.UsePoint` (7.8,-11.8)→(7.8,-10.2). 이름은 그대로.
- 문 폭: 베이1↔대기실 6, 대기실 정문 5.4(틀 6), 쇼룸 정문 약 6. 손님 길찾기 반지름 1.5(지금 CustomerService)로 모든 손님 길 통과, 문은 반지름 2로도 통과.
- 낮은 가구(높이 2 미만)는 PathfindingService가 계단처럼 밟고 넘어가요 → 손님 다니는 곳 커피 테이블은 윗면 2.2(의자 2.4)로. 새 가구도 손님 길 위엔 2 이상이거나 길 밖에.
- `PartsCounter.StaffPoint` 자리(부품실)는 문이 없는 직원 방이에요: 걸어서는 못 가요(NPC면 그 자리에 바로 놓기).
- `workspace.BuilderRefs`(빌더 창 측정용 R15 인형·차 상자)는 게임 것이 아니에요: `WorldBoot`가 서버 시작 때 지우고, `tools/bake_world.luau`는 이제 기본으로 안 만들어요.

### 길·주차 (차가 다니는 점)
| 경로 | 자리 | 보는 쪽 | 뜻 |
|---|---|---|---|
| `Traffic.RoadIn` | (-250, 0, -79.5) | +X | 손님 차가 나타나는 곳(가까운 차로, 오른쪽 통행) |
| `Traffic.EntryTurn` | **v23** (42, 0, -79.5) | → EntryCurb | 대로 위 꺾는 점: 여기서 비스듬히 들어오는 진입로로(**이 점 없이 RoadIn → EntryCurb로 가면 인도를 120칸 가로질러요**) |
| `Traffic.EntryCurb` | (48, 0, -70) | +Z | 들어오는 진입로 위(인도 턱 낮춘 곳 **v23: x 34..60**, 양옆 벌림) |
| `Traffic.LaneEast` | (48, 0, -36) | -X | 앞 차로 동쪽 끝 → 서쪽으로 한 방향 |
| `Traffic.LaneWest` | (-95, 0, -36) | -Z | 앞 차로 서쪽 끝 → 나가는 쪽 |
| `Traffic.ExitCurb` | (-95, 0, -70) | -Z | 나가는 진입로 위(**v23: x -104..-78**, 양옆 벌림) |
| `Traffic.ExitTurn` | **v23** (-88, 0, -81) | +X | 대로 위 꺾는 점: 진입로에서 나와 동쪽으로(**이 점 없이 ExitCurb → RoadOut으로 가면 인도를 120칸 가로질러요**) |
| `Traffic.RoadOut` | (250, 0, -79.5) | +X | 나간 차가 사라지는 곳 |
| `Traffic.SideDriveFront` / `SideDriveBack` | (47, 0, -24) / (47, 0, 32) | +Z / -X | 옆길(대기실 동쪽, x 38..56) → 뒷마당. 견인차·복원 베이용 |
| `Parking.Parking5` · `Parking6` | x 18 · 30 / z -56 | -Z | 보통 주차 칸(12×20, 코가 길 쪽). **v23: Parking1~4는 없어요** — 1 = 길가 일 진열대 코너, 2 = `Curb.CurbSpot`, 3·4 = `Queue.QueueSpot2·1`(★ Curbside). 다음 손님 대기는 이제 `Queue` |

- **차 길 (v23 — 모든 점이 찻길 또는 진입로 위, 두 점 사이 직선이 인도를 안 지남)**:
  - 들어올 때: `RoadIn → EntryTurn → EntryCurb → LaneEast → Bay?.ApproachSpot → CarSpot`
  - 나갈 때: `CarSpot → ApproachSpot(후진) → LaneWest → ExitCurb → ExitTurn → RoadOut`
  - 대기 줄: `RoadIn → Queue.QueueEntryN → (Queue.QueueApronN) → Queue.QueueSpotN` → 베이가 비면 `→ Bay?.ApproachSpot → CarSpot` / 집에 갈 때 `QueueSpotN → (그 x, z −36) → LaneWest → ExitCurb → ExitTurn → RoadOut`
  - 길가 일: `RoadIn → Curb.CurbEntry → (Curb.CurbApron) → Curb.CurbSpot` / 떠날 때 `CurbSpot → Curb.CurbExit → LaneWest → ExitCurb → ExitTurn → RoadOut`
  - 괄호 점(Apron)은 있으면 마지막 다리가 칸으로 똑바로(없어도 인도엔 안 걸림). 확인: 지금 속도(대로 45 · 칸 22.5 · 후진 12)·방향 3.5/초 흉내로 차 몸통(7.6×17) 81점이 인도에 닿는 프레임 = **모든 길 0**(옛 RoadIn→EntryCurb 340 · ExitCurb→RoadOut 379), `notes/playtest/wr-builder/curbside/route_sim.py` + Play 자국 사진 9·10.
  - 주차: `LaneEast → Parking5·6`(코를 -Z로 넣음).
- 차로(z -46..-20)는 비워 둬요: 가로등·소품은 차 길 밖에만.

### ★ 그림 자리 (포스터·안전 표지 — 지금은 빈 판, 그림은 나중에 Codex)
- 빈 판 = Part `ArtSlot`(속성 `ArtSlot` = 이름, `AspectW`/`AspectH` = 판 크기(스터드), `Kind` = Poster / SafetySign). 그림이 오면 그 면에 Decal(앞면 = 판이 보는 쪽).
| ArtSlot | 자리 | 크기 W×H | 종류 |
|---|---|---|---|
| B1_PosterWest | 베이1 서쪽 벽, 타이어 랙 위 | 4 × 3 | Poster |
| B1_PosterBack | 베이1 뒤 벽, 시계 오른쪽 위 | 3.6 × 3.6 | Poster |
| B1_SafetyDoor | 베이1 → 대기실 문 위 | 3.2 × 1.6 | SafetySign |
| B1_SafetyLift | 베이1 뒤 벽, 빨간 공구함 위 | 2.4 × 1.8 | SafetySign |
| WR_PosterCross | 대기실 안쪽 벽, 정수기 위 | 3 × 4 | Poster |
| WR_PosterEast | 대기실 동쪽 벽, 의자 위 | 4 × 3 | Poster |
| WR_Certificate | 대기실, 접수대 옆 벽 | 2.2 × 1.6 | Poster(자격증 액자) |
| B2_PosterBack · B2_SafetyWest | 베이2 뒤 벽 · 서쪽 벽 (Bay2 산 뒤) | 4 × 3 · 2.4 × 3 | Poster · SafetySign |
| RB_PosterBack | 복원 베이 뒤 벽 (산 뒤) | 4 × 3 | Poster |
| SR_Banner | 쇼룸 뒤 벽, 라운지 위 (Lv9 뒤) | 12 × 3 | Poster(가로 현수막) |
| GP_MuralWest | Gearport 상가 줄, 빈 땅(x −58..−36) 서쪽 건물 옆 벽, +X를 봄 | 24 × 16 | Poster(벽화) |
| GP_MuralEast | 상가 줄, 빈 땅(x 136..150) 동쪽 건물 옆 벽, −X를 봄 | 24 × 16 | Poster(벽화) |
| GP_MuralCross | 교차로 모퉁이 4층 건물(x 172..198) 동쪽 벽, Chassis St 쪽 +X | 24 × 28 | Poster(벽화) |
- 이미 글자 있는 판(SAFETY FIRST, OIL CHANGE $29, TIRES/BRAKES/BATTERIES, BAY 2)은 그대로.

### ★ Lv16 장비 (World/Motors — 실사진 notes/research/ref_alignment_dyno)
뒷마당(뒷길 서쪽 끝, x -100..-59)에 작은 건물 둘. 문 = -Z(뒷길 쪽). 사기 전엔 workspace에 없어요.
| 경로 | 해금 | 자리 | 표시점 (보는 쪽) |
|---|---|---|---|
| `AlignmentBay` | `Alignment` **Lv12** | x -100..-80, z 44..80 | `CarSpot` (-90, **0.8**, 62) +Z(발판 위 — 경사로로 올라감) · `LiftSpot`(= CarSpot) · `ApproachSpot` (-90, 0, 32) +Z · `WorkArea` · `ConsolePoint` (-83, 0.2, 70) +Z |
| `AlignmentBay.Lift` | 〃 | 4주 리프트 | 2주 리프트와 같은 규칙: `Lift.Carriage`(발판 2·가로보 2·턴테이블 2·미끄럼 판 2)를 `PivotTo(CarriageHome.CFrame + y)`, 속성 `Variant = "FourPost"`, `MaxLevel = "Under"`, `Control`은 없음(콘솔로 조작 — 필요하면 말해 주세요) |
| `AlignmentBay.CameraTower` · `Console` | 〃 | 차 앞(+Z 끝) T자 기둥 + 카메라 2 / 콘솔 | 장식(값은 코드 몫) |
| `DynoRoom` | `Dyno` Lv16 | x -79..-59, z 44..80 | `CarSpot` (-69, 0.2, 62) +Z · `ApproachSpot` (-69, 0, 32) +Z · `WorkArea` · `ConsolePoint` (-74, 0.2, 62) -X · `FanSpot` (-69, 0.2, 76) -Z |
| `DynoRoom.Dynamometer.Rollers` | 〃 | 롤러 4개(`FrontRoller` ×2 = 차 앞바퀴 z 67, `RearRoller` ×2 = 뒷바퀴 z 57), 바닥에서 0.25 솟음 | 돌리기 = 코드가 롤러 CFrame을 X축으로 돌림(안 부딪힘). 표시점 `Dynamometer.FrontRollers` / `RearRollers` |
| `DynoRoom.CoolingFan` · `Monitor` | 〃 | 차 코 앞 큰 송풍기 / 왼쪽 모니터 책상 | 장식 |
| `PaintBooth.Gear` | `PaintBooth` Lv16 | 스프레이 건 걸이(동쪽 벽) · 적외선 건조 램프 · 조명 스탠드 2 · 흡기 필터 판 3(서쪽 벽) | `Gear.GunRackPoint` (-21.6, 0.2, 66.2) +X(건 집는 자리) |
- 뒷길이 서쪽으로 x -100까지 늘었어요(`Site.Lot.BackLaneWest`) — 견인·Lv16 차가 두 건물 앞 `ApproachSpot`까지 와요.

### ★ 루프 B 장소 (World/FlipPlaces — flip_loop.md, 실사진 notes/research/ref_showroom_paint)
사기 전(Locked)엔 이 모델들이 workspace에 없어요(★ 업그레이드 규칙). 안의 이름은 아래 그대로.
| 경로 | 해금 | 자리 | 표시점 (보는 쪽) |
|---|---|---|---|
| `RestoreBay` | `RestorationBay` Lv8 | 뒷마당 x -14..18, z 44..80, 셔터 = -Z(뒷길 쪽) | `CarSpot` (2, 0.2, 62) +Z · `ApproachSpot` (2, 0, 32) +Z · `LiftSpot`(= CarSpot) + `Lift`(낡은/유압, 베이와 같은 규칙) · `WorkArea` · **`WashPoint`** (11.2, 0.2, 49) +X(파워워시 카트 앞) · `Shutter` |
| `PaintBooth` | `PaintBooth` Lv16 | 뒷마당 x -50..-18, z 44..80, 큰 문 2짝 = -Z(열린 채) | `CarSpot` (-34, 0.2, 62) +Z · `ApproachSpot` (-34, 0, 32) +Z · `WorkArea` · **`SprayPoint`** (-27, 0.2, 62) -X(차 옆 칠하는 자리) · **`MixPoint`** (-60, 0.2, 62.8) +X(옆 페인트 조색실 문 앞) |
| `Showroom` | `Level9` | x 56..112, z -20..30, 유리 정면(-Z)·동쪽, 서쪽 벽에 차 들이는 유리문 | 아래 |
| `Showroom.DisplaySpots.Spot1..6` | Spot1 Lv9 · 2·3 Lv12 · 4~6 Lv16(속성 `UnlockLevel`) | x 66 / 84 / 102 × z -8.5 / 12, 단상 위(y 0.5) | -Z. `car:PivotTo(SpotN.CFrame)` |
| `Showroom.ViewPoints.Spot1..6` | 〃 | 차 오른쪽 옆(x + 6.8) | -X — 바이어가 차를 보는 자리 |
| `Showroom.PriceTags.Spot1..6` | 〃 | 차 왼쪽 앞 기둥 | -Z — `PriceTags.SpotN.Label.Price.Text` |
| `Showroom.BuyerSpawn` → `BuyerDoor` → `Lobby` | Lv9 | (84, 0.5, -70) 인도 → (84, 0, -21) 문 밖 → (84, 0.2, -15) 안 | +Z — 바이어 걸음: Spawn → Door → Lobby → `ViewPoints.SpotN` → `SellDesk` |
| `Showroom.SellDesk` / `DealerPoint` | Lv9 | (104, 0.2, 23.2) / (104, 0.2, 27.8) | +Z / -Z — **v1에서 자리 바뀜**(106, 26 → 104, 23.2): 플레이어가 판매 책상 앞에 서는 자리 / 딜러 자리 |
| `Showroom.CarEntry` · `CarDoor` | Lv9 | (50, 0, 8) +X 옆길에서 / 서쪽 벽 유리문 z 0..16 | `CarDoor` 속성 `TopY 13`, `ClosedBottomY 0.2`, `OpenBottomY 12.4` — 셔터와 같은 방식(지금은 닫힌 채로 지음) |
- 쇼룸 바깥: 깃발·번팅·"USED CARS" 기둥 간판(장식). 대기 의자 대신 뒤쪽 라운지 소파.

### ★ Gearport (가상 자동차 도시 — 계획 notes/design/detroit_town_plan.md, World/Gearport)
- 다 **장식**: 코드가 읽을 표시점 없음(1단계). 손님 차 길(z −79.5)·`Traffic.*`·정비소 표시점 그대로.
- 대로 **Piston Avenue**: 옛 길(z −96..−74) = 동쪽 가는 2차로, 가운데 화단 z −104..−96, 서쪽 가는 2차로 z −126..−104(장식 차만 서 있음), 건너 인도 z −134..−126. 교차로 길 = **Chassis Street**(x 202..224).
- 2단계 폴더: `Town.BrickyardHeights`(Maple Row z −216..−200, 집 30채) · `Town.RiversidePark` · `Town.RiverWalk`(산책로 z −266..−258, 난간, 강물 = 걸을 수 있는 얕은 물 y −1.5, 건너편 벽 높이 18) · `Town.Midtown`(스카이라인, 배경, Persistent) · `Town.UnionDepot` · `Town.MapEdges`(서·동·북 옹벽 높이 16).
- 3단계 폴더: `Town.MarketHall`(교차로 북동, 정면 z −62가 대로 쪽) · `Town.FoundryRoad`(z 196..212, 교차로 길 끝) · `Town.OldWorks`(`MotorWorks`·`BrickFactory`·`SawtoothShedEast/North`·`Smokestacks`(Persistent)·`RailYard`). 공장 문은 다 닫힌 셔터(못 들어감).
- **번들 배경 차 자리**: `Town.OldWorks.RailYard.BundleCarSpots.Spot1..3` = 철길 마당 평판 화차 위(x 184, 데크 윗면 y 3.2, z 255/295/335, 보는 쪽 +Z, 크기 7.6×17). 큰길·인도에서 60칸 넘게 떨어짐. 차 PivotTo(Spot.CFrame)로 놓으면 돼요(메인 업로드).
- **SkyLoop** (4단계, 장식): `Town.SkyLoop` = `Guideway`(대로 화단 위, 윗면 y 30, x −360..190)·`Column`·`StationDepot`·`StationChassis`(양쪽 승강장 + 선로 위 지붕)·`TowerDepot`·`TowerChassis`(노선 양 끝 화단 안 엘리베이터 탑, 길 쪽 문은 닫힘 "CLOSED FOR SERVICE" = 못 올라감)·`StopWest`/`StopEast`(표시점, 열차 Root 자리)·`Train`(2량, Persistent, PrimaryPart `Root`). **열차는 클라이언트에서만 움직여요**: `StarterPlayerScripts/SkyLoop.client.luau`(wr-builder, 꾸밈 — 게임 규칙 X). 서버의 열차는 StopWest에 서 있어요.
- 거리 소품: `Town.StreetProps`(장식). 3D 소품 자리: `Town.StreetProps.FireEscape.FireEscapeStairSpot`(상가 뒷벽 4곳, 2층 발판 위 계단 아래 끝, 오르는 쪽 +X) — Prop_FireEscapeStair가 놓인 곳(v19). 3D 소품 MeshPart 이름 = `Prop_<이름>`(소화전·우체통·콘·봉투·비상계단·타이어·기름통·공원 통), 모두 장식(이름 바뀔 수 있음). 메시는 Build 때 `InsertService:LoadAsset`으로 불러옴(못 불러오면 그 소품만 빠지고 맵은 그대로).
- 맵 끝: 서 x −440 · 동 x 480 · 북 z 480 = 옹벽(보임, 못 넘음), 남 = 강(빠져도 다시 올라옴, 건너편 못 감). 땅 = `Site.MAP_X0/X1/Z0/Z1`.
- `Traffic.RoadIn`(−250) · `RoadOut`(250)은 그대로라 이제 길 한가운데서 차가 나타나고 사라져요. 길이 x −440..480으로 길어졌으니 원하면 ±420 근처로 옮겨도 돼요(wr-dev 결정).
- 폴더: `Town.PistonAvenue`(화단·가로등·차로) · `Town.AvenueShops`(상가 16채 + `RivalGarageWest/East` + `VacantLot` + `ArtSlots`) · `Town.FuelStation` · `Town.AvenueParking`(대역 차 `StreetCar1..4`). `Town` 속성 `City = "Gearport"`.
- **놀이 연결 자리 (예약 — 아직 없음, wr-design 설계 → wr-dev 코드)**: 지을 때 아래 이름으로 표시점을 둬요.
| 경로 (예약) | 단계 | 뜻 |
|---|---|---|
| `Town.MarketHall.CouponStall.PromptPoint` | **있음 (v16)** (261, 0.6, −34), 보는 쪽 +Z(노점) | Market Hall 안 맨 뒤 "PARTS SWAP" 노점 앞(플레이어가 서는 자리, 아치 문 2개로 걸어 들어감). 하루 한 번 부품 카운터 할인 전표 — 규칙은 wr-design·wr-dev |
| `Town.UnionDepot.ArrivalPoint` | **있음 (v15)** (−370, 1.4, −205), 보는 쪽 −Z(선로) | Union Depot 승강장 끝, 열차가 서는 자리. VIP 손님 방문 예고 연출 — 규칙은 wr-design·wr-dev. 선로 2줄 z −214 / −228(x −440..−296, 서쪽 터널) |

### 기타
| 경로 | 뜻 |
|---|---|
| `SpawnLocation` | **v20: 베이 1 앞마당 (8, 0.2, -30)**, 베이 1 안(첫 손님 차)을 봐요(LookVector ≈ (-0.30, 0, 0.95)) — 옛 자리 (26, 0.2, -24)는 베이 문이 옆으로만 보여 첫 차가 안 보였어요. 4×4, Neutral, Duration 0 |
| `Site` / `Building` / `Town` / `Dressing` | 땅·길 / 건물 껍데기 / 도시(Gearport)·나무·옆 가게 / 장식 소품(간판 글자·공구·포스터 등). 코드가 만질 일 없음, 이름이 바뀔 수 있음 |
| `game.Lighting` | 맵이 `ClockTime`·밝기·노출 등 몇 값, `WorldAtmosphere`·`WorldColor`(ColorCorrection), 템플릿 효과의 **ColorGrading 톤매퍼 = Default**·**Bloom 세기 ≤ 0.4**를 정해요(World/Lights — Retro 톤매퍼 때 Play가 하얗게 날아감) |
| `Building.SignBoard` | 지붕 위 간판 판(빨강, 비어 있음). 글자 = 나중에 SurfaceGui(영어 원문, 실제 상호 X) |

## 3. 크기 메모 (왜 이 숫자)
- 베이 1칸 28×40(안쪽 26×38), 천장 20: car_spec §7 최소(20×30, 천장 16)보다 넉넉히. 차(7.6) 양옆에 캐릭터 2명(8) + 여유, 리프트 `Under` 6 + 차 5.8 + 보닛 열림까지 천장 아래.
- 셔터 구멍 16×13.8(car_spec 최소 10×9): 3인칭 카메라가 걸리지 않게 실제보다 넉넉히.
- 작업대·카운터 윗면 3.4: R15(5.18)의 가슴 아래.
- 앞 차로 깊이 26, 주차 칸 12×20, 인도 8, 도로 22(차로 11×2).

## ★ 정비소가 자란다 (v20, wr-builder — docs/design/garage_growth.md)
- 앞면만 바뀌어요(표시점·문·창 자리는 세 시대 모두 같음). `Upgrades`가 Lv로 하나만 보이게 해요:
  - `Building.Facade.Shed` = UpgradeId `Level6` Locked (Lv1~5): 나무 판자 + 골함석, 손글씨 간판(`SignFaded` Level3 Locked / `SignFresh` Level3 Owned), 문 위 판자 지붕.
  - `Building.Facade.BrickEra` = `Level6` Owned → 안의 `Brick` = `Level16` Locked (Lv6~15): 벽돌, 사무실 위 박공, 빨간 철판 간판(옛 `Building.SignBoard`가 여기로 옮겨짐) + 전구 테두리, 파란 차양(옛 `Building.Awning`·`Dressing.OfficePlate`도 여기).
  - `Building.Facade.Enamel` = `Level16` Owned (Lv16+): 하얀 법랑(판 이음 줄·빨간 띠·둥근 모서리), 차양 `Canopy` + 글자 띠, 큰 네온 간판 `NeonSign`; 안의 `StarBorder` = `Level17` Owned(금별 테두리).
  - 칸 2·3도 자기 껍데기(`Bays.Bay2.Shed`·`Bays.Bay2.BrickEra.Brick`·`Bays.Bay3.BrickEra.Brick`). 칸 2 사기 전 자리(`UpgradeSpots.Bay2`)는 판자로 막힌 헛간(사방 막힘).
  - `Building.Flags` = `Level10` Owned(깃대 2), `Building.FlowerPot` = `Level12` Owned.
  - `Building.Facade.ShowCamera` **v23: (6, 17, -80)**, 보는 쪽 (4, −9, 60).Unit(살짝 아래) = 레벨 업 "Show me" 카메라 자리(앞면 전체가 보임). 옛 (10, 12, −64)는 대기 칸 차·손님이 화면 아래를 가려서 길 쪽 위로 옮김(아직 쓰는 코드 없음). 
- `WaitingRoom.PhotoWall` (대기 의자 위 동쪽 벽, "OUR CUSTOMERS" 판) + `PhotoWall.PhotoWallSpot` (36.74, 8.4, -12.3), 보는 쪽 -X, 크기 0.2 × 4.4 × 11.4 = 밈 차 사진 붙일 자리(코드는 시험 뒤).

## ★ 잭 세트 — Lv1 리프트 없음 (v20, 10-21, 사용자 결정 · work_view v0.5 §2b · carbook under_car_work.md)
- **낡은 리프트(`Lift` Variant Old)는 더 안 지어요**(World/Equipment `OLD_LIFT = false`). `Lift` Variant Hydraulic은 그대로(`HydraulicLift` Owned일 때만 보임). → **Lv1 베이에는 `Lift`가 없어요** — LiftService가 임시 리프트를 짓지 않고 잭 세트로 처리해야 해요(wr-dev).
- 베이마다(`Bays.Bay1..4`, `RestoreBay`) `JackKit` (Model, 서쪽 벽 쪽 — 기다리는 자리):
  | 이름 | 무엇 | 보는 쪽 |
  |---|---|---|
  | `FloorJackSpot` | 플로어 잭이 기다리는 바닥 자리 (Bay1 (−4.5, 0.2, 8.5)) | 잭 받침(앞) 쪽 = −Z |
  | `StandSpot1` · `StandSpot2` | 잭 스탠드 2개 자리 (Bay1 (−11.6, 0.2, −7) · v31 (−10.45, 0.2, −1.0) — 2번은 누움판 앞 노란 선 위) | −Z |
  | `ChockSpot1` · `ChockSpot2` | 바퀴 고임목 2개 자리 (Bay1 (−12, 0.2, −0.6) · (−12, 0.2, 0.6)) | +X |
  | `CreeperWallSpot` | 누움판 보관 자리 (Bay1 v32: 3D 누움판(메시 `Board`)을 벽에 15° 기대 세움, 판 가운데 (−11.97, 2.14, −1.12), 걸이 없음 — `World/Interior`가 옮김) — 판 가운데 높이 | +X (벽 밖) |
  | `CreeperFloorSpot` | 누움판을 내려놓는 자리 = 차 왼쪽 문턱 옆 (Bay1 (−6.6, 0.2, −1)) | +X (차 밑으로 미끄러지는 쪽) |
  - 소품(파트, 장식): `JackStand1/2`(빨간 다리 4 + 기둥 + 고무 받침), `Creeper`(빨간 판 + 머리 받침 + 바퀴 6), `WheelChock1/2`(노란 쐐기). 잭 = Bay1은 `Tools.FloorJack1`, 다른 베이는 `JackKit.FloorJack1` — 둘 다 속성 `Placeholder3D = "FloorJack"`(3D 잭이 오면 바뀜).
  - **차에 놓는 자리는 차에서**: 스탠드 = 차 `LiftPoint_*`(문턱 아래 앞바퀴 뒤·뒷바퀴 앞), 잭 = 차 앞·뒤 가운데 아래(car_spec), 고임목 = 들지 않는 쪽 바퀴 앞뒤.

## ★ 베이 부품 카트 `Bays.BayN.BayCart` (v21, 10-21, work_view "Put it on the cart / Take the new one from the cart")
- 베이마다(`Bay1..4`, 베이와 같이 보였다 숨음) 빨간 3단 정비 카트(실제 스틸 서비스 카트: 턱 있는 판 3·기둥 4·검정 바퀴 4·한쪽 끝 손잡이). 파트 23개. `RestoreBay`엔 없음(필요하면 말해 주세요).
- 자리 = **차 앞 왼쪽**(차 왼쪽 = +X, 코 = +Z), 긴 쪽이 차와 나란히: 카트 바닥 상자 x cx+7.2..cx+10.1, z 1.5..7.0(손잡이 포함), 손잡이 = −Z 끝(셔터 쪽).
- **`PartsCart` = 맨 윗판 파트**(이름 그대로 — 모델 이름은 `BayCart`라서 `bay:FindFirstChild("PartsCart", true)`가 윗판을 찾아요). Bay1 윗판 가운데 (8.6, 3.5, 4.6), **윗면 y 3.6**, Size (4.8, 0.2, 2.8), **로컬 X(긴 쪽) = 월드 −Z**, 로컬 Z = 월드 −X. 부품 자리 = WorkService.cartSpot/cartPlace 그대로(윗면 +0.6, 로컬 X ±1.6 × 3칸, 로컬 Z ±0.9 × 2줄 — 판 안에 들어감). 윗판 둘레에 높이 0.35 턱.
- Bay2/3/4 = 같은 자리, x만 cx(−28/−56/−84) 기준. 모델 속성 `Kind = "PartsCart"`(나중에 밀기 등 만질 때 이 이름으로). 아래 칸 파란 통(`PartsBin`)은 장식(안 부딪힘).


## ★ 할로윈 — Ella의 밤 (v22, 10-21, World/Halloween + World/Seasonal · halloween_pumpkin.md v0.3 §4·§5b)
**늘 있는 것(안 보이는 표시점 — Position = 카메라 눈 자리, LookVector = 보는 쪽 참고용)**
| 경로 | 자리 | 뜻 |
|---|---|---|
| `Bays.BayN.CinemaCam_Street` | (cx+14, 6.5, −58) → 차 자리 위 6 | ① 도착 1a·1b: 앞 차로 건너 손님 주차장에서 간판·베이 문 |
| `Bays.BayN.CinemaCam_Door` | (cx+6.8, 5.0, −18.6) → DriverExitSpot | ① 1c Ella 내림 / ③ 3a·3b 떠남 — 문 안쪽, 차 옆 3칸, 차 지붕 아래 |
| `Cinema.CinemaCam_StreetEnd` | (−83, 5, −59) → (−96, 3, −75) | ② 자정: 차가 `Traffic.ExitCurb`(−95, 0, −70)에서 멈출 때, 뒤로 Union Depot 시계탑 |
| `Cinema.CinemaCam_Shelf` | (34.0, 7.6, 1.6) → 구두 | ③ 3c 선반의 유리 구두 |
| `Cinema.PopSpot` · `PumpkinRollTo` · `CoachAppear` | (−95, 0, −70) −Z · (−112, 0, −84) · (−170, 0, −79.5) +X | (코드 선택) 펑 자리 = ExitCurb, 호박이 굴러갈 곳, 대로에서 호박차 불빛이 처음 보이는 곳 |
| `WaitingRoom.TrophyShelf` + `SlipperSpot` | 대기실 동쪽 벽(사진 벽 옆, 포스터와 구석 사이) 선반 윗면 (36.5, 6.5, −0.1), 보는 쪽 −Z | 유리 구두 `PivotTo(SlipperSpot.CFrame)`(밑창 가운데, 앞코 −Z). "SPECIAL GUESTS" 명판 + 따뜻한 스포트 조명. 나중 다른 특별 손님 트로피도 여기 |
- ⚠ 베이마다 표시점이 있어요: `Garage:FindFirstChild("CinemaCam_Door", true)`는 아무 베이 것(대개 Bay1)을 찾음 → **Ella 차가 선 베이에서 `bay:FindFirstChild("CinemaCam_Door")` 먼저**. Bay2~4 것은 그 베이를 산 뒤에만 workspace에 있음.

**기간에만 있는 것 `HalloweenDecor` (Model, 147파트)** — 짓기 때 `ServerStorage.WorldSeasonal`에 두고, `World/Seasonal`(WorldBoot가 켬)이 `Config.Halloween.start ≤ 지금 < finish`(서버 UTC)일 때 `workspace.Garage`로 옮김(30초마다 확인). **시험용 강제: `workspace:SetAttribute("SeasonHalloween", true/false)`**(nil = 날짜대로) — `HalloweenService.forceActive` 쓸 때 같이 켜 주세요.
- 고증(미국 동네 가게 할로윈): 짚단 + 잭오랜턴 + 옥수숫대 묶음(문 양옆), 주황·보라 줄전구(앞면 y 15.2, 모든 시대 간판·차양 아래 · 문 위), 거미줄(베이 문 위 두 구석 + 사무실 창 왼쪽 위, 거미 한 마리), 사무실 창 안 "Closing soon" 걸이 간판.
- `ClosingSign` (Part, 왼쪽 창 가운데 (18.5, 8.9, −19.71), 앞 = −Z) + SurfaceGui **`Label`**(꺼진 채, 글자 "Closing soon") — HalloweenService가 `Label.Enabled`를 켜면 Seasonal이 뒤 보라 테(`ClosingSignHanger.SignGlow` → Neon)·주황 빛을 **지직 깜빡인 뒤** 켬, 끄면 같이 꺼짐.
- 잭오랜턴 7개 = 파트 대역(주황 타원 + 줄기 + 빛나는 눈·코·입 + PointLight), 모델 속성 `Placeholder3D = "JackOLantern"` → 3D가 오면 바꿀 자리.
- 짚단만 부딪힘(문·손님 길 밖), 나머지는 안 부딪힘. 차 길·셔터 구멍(x −8..8, y < 13.4)·손님 문(x 29.35..34.65) 안 막음.
- 파트: Lv1 4,367 + 147 = 4,514 / Lv16 5,448 + 147 = 5,595(할로윈 주간에만 예산 5,500을 약 95 넘음 — 공개 첫 주에 Lv16은 드묾).

## ★ Curbside — 베이 1 앞 진입로: 대기 줄 + 길가 짧은 일 (v23, 10-22, World/Curbside · downtime_main_decision.md · curb_jobs.md)
**모양**: 인도 턱을 **x −28..14**에서 낮춘 넓은 진입로(`Site.SERVICE_X0..X1`, 콘크리트, 들어오기만 — 동쪽 가는 대로에서 **오른쪽으로 꺾어 바로** 들어옴). 그 뒤 주차 줄 칸 4개 = 서→동 **[진열대 코너 x −36..−24][길가 일 칸 −24..−12][대기 칸 2 −12..0][대기 칸 1 0..12]**. 칸은 모두 코 +Z(정비소 쪽), 바퀴 멈춤 턱 없음. 고증: 오일 교환집은 베이 문 앞에 차가 줄 서고 지나가는 차가 '베이 안 차 + 줄 선 차'를 봄(NOLN McPherson Quick Lube), 부품 가게는 와이퍼를 사면 주차장에서 바로 갈아 줌(O'Reilly 매장 페이지), 진입로는 인도를 끊고 턱을 낮춘 콘크리트 + 양옆 벌림(미국 상가 진입로 모양).
- 차 길 = 위 '길·주차'의 차 길. 꺾는 점(QueueEntryN·CurbEntry)은 칸보다 **5칸 서쪽 찻길 위** → 비스듬히 진입로로(90° 제자리 꺾기 대신 — 45칸/초면 방향이 늦게 돌아 옆으로 미끄러짐).
- 옮긴 것(장식): 벤치 x 64..72(쇼룸 앞 인도) · 공원 쓰레기통 x 19 · 가로등 x 10 → 16 · 소화전 x −20 → −46(노란 연석 칠 x −62.5..−29.5, 진입로 앞에서 끝남).

**대기 줄 `Queue`** (Folder) — 다음 손님이 기다리는 칸, 베이가 비면 **똑바로 앞으로** 베이 1에 들어감(베이 2~4로 갈 땐 차로에서 서쪽)
| 이름 | 자리 | 보는 쪽 | 뜻 |
|---|---|---|---|
| `Queue.QueueSpot1` / `QueueSpot2` | Marker 8×0.2×18, (6, 0, −56) / (−6, 0, −56) | +Z | 대기 차 자리(`car:PivotTo(QueueSpotN.CFrame)`). 코 = 베이 1 문(z −47.5), 꼬리 = 인도 앞(−64.5) |
| `Queue.QueueEntry1` / `2` | **(1, 0, −79.5) / (−11, 0, −79.5)** | 다음 점 쪽 | 대로(가까운 차로 z −79.5) 위 꺾는 점 |
| `Queue.QueueApron1` / `2` | (6, 0, −68) / (−6, 0, −68) | +Z | 진입로 위, 칸과 한 줄 — 여기서 칸까지 똑바로(선택) |
| `Queue.WaveSpot1` / `2` | (11.5, 0, −50.5) / (−0.5, 0, −50.5) | 베이 1 문(0, −20) 쪽 | 손님이 내려 서는 자리 = 운전석(+X) 앞 펜더 옆. 손 흔들기 자리. 베이 안·문 앞에서 다 보임 |
- 바닥 칠(장식): 칸 입구 흰 정지선(z −46.6), "WAIT HERE"(z −52, 길에서 들어오는 운전자 쪽으로 읽힘), 베이 쪽 화살표. 차가 서면 가려짐.

**길가 짧은 일 `Curb`** (Folder — **wr-dev `CurbService`·`Places.curbStall()`이 읽는 이름**. curb_jobs.md §3-2의 `CurbJob.CarSpot` = 여기 `Curb.CurbSpot`, 자리도 (30, 0, −56) 뒤로 넣기 대신 진입로 칸에 앞으로 바로)
| 이름 | 종류 · 자리 | 보는 쪽 | 뜻 |
|---|---|---|---|
| `Curb.CurbSpot` | Marker 8×0.2×18, **(−18, 0, −56)** | +Z | 길가 일 차(세단). 대기 줄·베이 차 길과 안 겹침 |
| `Curb.CurbEntry` | **(−23, 0, −79.5)** | 다음 점 쪽 | 대로 위 꺾는 점 |
| `Curb.CurbApron` | (−18, 0, −68) | +Z | 진입로 위 — 여기서 칸까지 똑바로(선택) |
| `Curb.CurbExit` | (−18, 0, −36) | −X | 떠날 때: CurbSpot에서 앞으로 → 여기서 서쪽 차로에 합류 |
| `Curb.HoodSpot` | (−18, 0, −45.6) | −Z(차 쪽) | 범퍼 앞 2칸 — 보닛·워셔 캡('Pour'). 워셔 캡(차 기준 (2.62, 3.28, −6.50)) = 월드 약 (−20.6, 3.3, −49.5) |
| `Curb.WiperSpotL` | (−12.7, 0, −52.5) | −X | 운전석 쪽(+X) 앞유리 아래 옆 — 긴 날. 옆 대기 칸 2 차와 사이 4.4칸 |
| `Curb.WiperSpotR` | (−23.3, 0, −52.5) | +X | 조수석 쪽 — 옆이 비어 넓음(추천) |
| `Curb.CustomerSpot` | (−23.6, 0, −61) | 보닛 쪽 | 길가 일 손님이 서서 보는 자리(조수석 쪽 뒤) |
| `Curb.SupplyRack` | Model, 진열대 코너 x −27.2..−25.8 · z −50.6..−47.6, 높이 4.8 | 앞 = +X(칸 쪽) | 철망 진열대: 가운데 칸 와이퍼 날 상자 6(주황·검정), 아래 칸 파란 갤런 통 3 + 머리판 "WIPER BLADES / WASHER FLUID". 투명 `Solid` 상자 1개만 부딪힘. 속성 `Kind = "SupplyRack"` |
| `Curb.Jug` | Model(PrimaryPart `Body` 0.45×1.1×0.65 파랑 + `Cap` 흰 원기둥), 진열대 아래 칸 맨 남쪽 (−26.35, 0.35, −50.3) | 앞(라벨) = +X | **손에 쥐여 줄 갤런 통 템플릿 = 진열대에 놓인 통 1개** → `Curb.Jug:Clone()`. 안 부딪힘. 속성 `Kind = "WasherJug"` |
| `Curb.Sign` | Model, A자 간판 (−26.4, 0, −62.4), 판 2장 2.4×3.2 빨강 | 앞판 −Z(대로) · 뒤판 +Z | "QUICK SERVICE / WIPERS · WASHER FLUID". 부딪힘. 속성 `Kind = "AFrame"` |
- 바닥 칠: 노란 "QUICK SERVICE"(z −52) — 흰 "WAIT HERE"와 구별.
- 길 확인(Studio, 차 3대 세운 채): 베이1↔대기실 문·스폰·대기실 정문 → WaveSpot1·2, HoodSpot, WiperSpotL·R, CustomerSpot **18개 다 걸어감**(반지름 1.5). 차 길 7개(들어옴·나감·대기 1·2·길가 들어옴·나감·대기 집에)를 차 크기 상자로 밀어 봄 = 부딪히는 물건 없음.
- ⚠ **장면 카메라**: `Bays.Bay1.CinemaCam_Street` (14, 6.5, −58) 바로 앞에 대기 칸 1 차·WaveSpot1 손님이 크게 걸려요(사진 `notes/playtest/wr-builder/curbside/8_cinemacam_bay1_queue.jpg`) → Ella 장면(hold) 동안엔 대기 칸을 비우거나 손님을 차 안에. `Bays.Bay2.CinemaCam_Street` (−14, 6.5, −58)은 길가 일 칸 위 — curb_jobs대로 hold 땐 길가 차가 안 오니 괜찮음.
- ⚠ **Ella 자정 멈춤**: `HalloweenService.specialDrive`는 나가는 다리 마지막 1개(RoadOut)만 빼고 멈춰요 → 다리에 `ExitTurn`이 들어가면 **ExitTurn(−88, −81, 찻길 위)**에서 멈춤. 설계대로 `ExitCurb`(진입로)에서 멈추려면 2개 빼기. 카메라(`Cinema.CinemaCam_StreetEnd`)는 차를 따라 봐서 어느 쪽이든 보임.
- 파트(v23): **Lv1 4,406 · Lv6 4,671 · Lv16 5,487**(진입로·칸·칠·진열대·간판 +39). 할로윈 주간 +147.
