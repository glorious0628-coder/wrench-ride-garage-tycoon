# 시대별 희귀 차량 (era_cars) — v0.3 (사용자 결정 10-21: 처음 3대 먼저 · 최초의 차 = 네발) (wr-design, 2026-10-20)

> ⚠️ **사용자 규칙(10-22)**: "모양은 현실 세계에 없더라도 자동차 구조나 부품은 현실적이어야 돼" · "구조가 현실적이지 않은 자동차 절대 금지" → **겉은 자유, 속은 진짜**: 시대 차는 **그 시대 진짜 구조**(예: 1880년대 = 라디에이터 없음, 체인 구동·통 차축·드럼/블록 브레이크 — 실제 차 조사대로). 겉 디자인만 오리지널.

> 사용자: "지금은 없는 차량들도 가끔 등장하면 좋겠어 ㅋㅋ 최초의 자동차부터 지금 자동차까지!" + "자동차 뇌피셜 ㄴㄴ 무조건 자료 찾아서 디자인도 섞어야돼".
> → 시대마다 **실제 차 4~5대를 조사**하고, **여러 차에 공통인 특징만** 섞어 오리지널을 만들어요. 한 차에만 있는 특징(얼굴·그릴·엠블럼·시그니처 라인)은 쓰지 않아요. 이름도 실제 차 이름·말장난 X.
> **사용자 결정 (10-21)**: **3대 먼저** — 1880년대 · 1950년대 · 지금 전기차. **최초의 차 = 네발 모터 마차**. 나머지 9개 시대는 아래 §1에 레시피로 남겨 두고 반응을 보고 늘려요.
> 근거: 조사 `notes/research/api/2026-10-20_era_refs_a.md`(1885~1959), `_era_refs_b.md`(1960~지금) · 링크 실제 확인 `notes/research/era_refs_verified.md`(Wikipedia 69개 중 66개 확인) · 역사 사실 확인 `notes/research/era_facts_verified.md` · GPT 토론 2라운드 `notes/gpt/wr-design/era_r1_*`, `era_r2_*`.
> 그림체 B(둥근 캐주얼), 원문 영어, 서양권 아이들이 익숙한 차.

---

## 0. 처음 만드는 3대 (확정)

세 대는 **들어오는 길이 서로 달라요** — 하나는 손님, 하나는 복원, 하나는 발견. 그래서 셋만으로 '시대 차'의 재미 세 가지를 다 맛봐요.

| | **Pioneer Carriage** (1885~95) | **Starlane Cruiser** (1950s) | **Quietline EV** (2013~) |
|---|---|---|---|
| 레시피 | §1 #1 (네발 — Daimler 1886 모터 마차 = "세계 첫 네발 자동차", Mercedes-Benz 공식 역사) | §1 #5 | §1 #12 |
| 어떻게 오나 | **발견**: Mythic. Barn Find 단서 20개 확정(Lv11+) 또는 Car Show Weekend | **복원**: Lv8 폐차장 열리자마자 **확정 복원 의뢰 1대**(era_cars §2 약속) — 그 뒤 Rare 매물 | **손님**: Lv6+ 손님 차로 가끔(Uncommon) — 고치는 일, 복원 X |
| 들어 있는 것 / 없는 것 | 엔진(뒤 1기통·노출 플라이휠은 X — Benz 고유) · **핫튜브 점화 버너** · 증발식 물탱크 · 벨트 구동 · 나무 살 바퀴 · 작은 소음기 통(장식). **없음**: 배터리·라디에이터·머플러·유리 | 앞 V8 · 뒷바퀴굴림 · 기화기 · **드럼 브레이크** · 발전기(제너레이터) · 12 V(1955~ 대부분) · 크롬 범퍼·화이트월 타이어 | 바닥 배터리 팩 · 모터 · **12 V 보조 배터리**(ⓒ carbook 확인) · 배터리 냉각수 · 앞 트렁크. **없음**: 엔진오일·머플러·점화 플러그·연료 |
| 그 차만의 수리 | **핫튜브 불꽃 맞추기**(버너 불꽃 크기 → 관이 빨갛게 → 플라이휠 돌리기) + **물 채우기**(증발 냉각). '두 차를 섞은 게임 설계'라고 도감에 적음 | **기화기 공회전 나사를 소리로 맞추기** + 드럼 브레이크 별 바퀴 조정 + 크롬 광내기 | **고전압 안전 3단계**(주황 선 확인 → 서비스 플러그 뽑고 기다리기 → 낮은 전압 진단) + 배터리 모듈 진단. **함정**: "It won't turn on!" = 큰 배터리가 아니라 **12 V 보조 배터리** 방전(ⓒ) · 오일 교환·머플러 찾으면 오진 |
| 희귀도 · 가치 | Mythic · 2.5× | Rare · 1.35× (확정 의뢰 차는 Silver 쯤 목표) | Uncommon · (손님 차 — 공임 ×1.15) |
| 도감 문구 (영어) | "A motor carriage from the dawn of the automobile." | "Chrome, fins and whitewalls — the cruiser era." | "Quiet, quick, and full of batteries." |
| 3D 메모 | 세단 부품 재사용 거의 없음(새로) — 크기·바퀴는 carbook history 근거로 3D 전에 확인 | 바퀴 안 부품(드럼)·차체 새로, 공구·볼트 규칙은 공용 | 세단 차체 비율에 가까움 → 하체·엔진룸만 새로(엔진룸 = 모터·인버터·앞 트렁크) |
- 시대 차 3대에도 car_spec 이름 규칙(`Body/…`, `MechanicalParts/…`)을 쓰고, **없는 부품은 슬롯을 만들지 않음**.
- 나머지 9개는 §1 레시피 그대로 보관(Openroad Tourer·Roundstep·Trail Utility·Longhood·Backbay Van·Squareway Wagon·Lowbeam·Corner Hatch·Glideback).

## 1. 시대 12개 — 섞는 레시피

표 읽는 법: **섞을 특징 ← 출처 차(2대 이상)**. 수리는 그 장치를 단 '이 차'에만 붙는 게임 동작이에요(그 시대 모든 차의 공통 장비라는 뜻 X).

| # | 시대 · 가칭 (영어) | 섞을 특징 ← 출처 차 | 피할 것 (어느 차의 무엇) | 이 차만의 수리 재미 (사실 근거) | 희귀도 |
|---|---|---|---|---|---|
| 1 | 1885~95 · **Pioneer Carriage** | 네발 마차형 몸체 ← [Daimler 1886 모터 마차](https://group.mercedes-benz.com/company/tradition/company-history/1886-1920.html)·[Peugeot Type 3](https://en.wikipedia.org/wiki/Peugeot_Type_3) / 높은 열린 좌석 ← [Duryea Motor Wagon](https://en.wikipedia.org/wiki/Duryea_Motor_Wagon)·Peugeot / 가는 살 바퀴 ← Daimler·Peugeot·[Benz](https://en.wikipedia.org/wiki/Benz_Patent-Motorwagen) / 손잡이 조향(Benz는 틸러가 아니라 **세운 손잡이 레버 + 랙·피니언** — wr-carbook history §5) | Benz의 **세발 + 앞바퀴 1개 + 뒤 노출 플라이휠** 조합, Daimler 마차 차체 그대로 | **핫튜브 불꽃 맞추기**(Daimler 엔진 = 핫튜브 점화 — [Daimler Reitwagen](https://en.wikipedia.org/wiki/Daimler_Reitwagen)) + **물 채우기**(증발식 냉각 — Benz Patent-Motorwagen 문서). '두 차를 섞은 게임 설계'라고 도감에 적음. 구동은 벨트 하나로 | Mythic |
| 2 | 1896~1927 · **Openroad Tourer** (+ 작은 2인승 러너바웃 변형) | 열린 승객석 ← [Cadillac Model A](https://en.wikipedia.org/wiki/Cadillac_Model_A)·[Ford Model T](https://en.wikipedia.org/wiki/Ford_Model_T) / 따로 붙은 펜더·가는 바퀴 ← [Mercedes 35 hp](https://en.wikipedia.org/wiki/Mercedes_35_hp)·Model T / 높은 차체·접이식 지붕 ← Model T·[Austin 7](https://en.wikipedia.org/wiki/Austin_7) | Oldsmobile의 **말린 앞판(curved dash)**, Rolls-Royce 신전 그릴, Model T 놋쇠 라디에이터 윗모양, Bugatti 말굽 그릴 | **시동 고르기**: 크랭크(점화 레버를 먼저 늦추고 돌리기 — 킥백) 또는 전기 시동(1912 Cadillac부터 — [Starter (engine)](https://en.wikipedia.org/wiki/Starter_(engine))). 선택: 트렘블러 코일 '윙' 맞추기([Trembler coil](https://en.wikipedia.org/wiki/Trembler_coil), Model T 1927까지), 카바이드 램프 물 넣기([Carbide lamp](https://en.wikipedia.org/wiki/Carbide_lamp) — **1915년 전 차만**, 그 뒤는 전기 램프) | Legendary |
| 3 | 1928~41 · **Roundstep Sedan** | 닫힌 객실 ← [Ford Model A](https://en.wikipedia.org/wiki/Ford_Model_A_(1927%E2%80%931932))·[Citroën Traction Avant](https://en.wikipedia.org/wiki/Citro%C3%ABn_Traction_Avant) / 둥근 펜더 ← Model A·[Chrysler Airflow](https://en.wikipedia.org/wiki/Chrysler_Airflow) / 옆 발판(running board) ← Model A·[Duesenberg Model J](https://en.wikipedia.org/wiki/Duesenberg_Model_J) | Airflow의 전체 유선형·폭포 그릴, Duesenberg 외장 배기관, Beetle 실루엣 | **기계식 브레이크 막대·케이블 좌우 맞추기** + 6 V 배터리 단자 청소 + 진공 와이퍼(가속하면 느려짐 — **근거 링크 확인 전까지 선택 장식**) | Epic |
| 4 | 1940s · **Trail Utility** (+ 초기 픽업 변형) | 짧고 높은 실용 차체 ← [Willys MB](https://en.wikipedia.org/wiki/Willys_MB)·[Land Rover Series](https://en.wikipedia.org/wiki/Land_Rover_series) / 단순한 평판 패널 ← Land Rover·[Kübelwagen](https://en.wikipedia.org/wiki/Volkswagen_K%C3%BCbelwagen) / 노출된 짐칸 ← [Chevrolet Advance Design](https://en.wikipedia.org/wiki/Chevrolet_Advance_Design)·[Ford F-Series 1세대](https://en.wikipedia.org/wiki/Ford_F-Series_(first_generation)) | Willys의 **세로 슬롯 그릴**(디자인 특허 있음), Land Rover 앞면, 군 표식 | **4륜구동 레버·트랜스퍼 케이스** 맞추기, 접이식 앞유리 | Rare |
| 5 | 1950s · **Starlane Cruiser** (+ 유럽 소형 변형은 다른 실루엣) | 넓은 차체·크롬 장식·투톤 ← [Chevrolet Bel Air](https://en.wikipedia.org/wiki/Chevrolet_Bel_Air)·[Cadillac Eldorado](https://en.wikipedia.org/wiki/Cadillac_Eldorado) / 뒤 펜더가 살짝 올라감 ← Bel Air·Eldorado / 둥근 지붕·큰 유리 ← Bel Air·[Citroën DS](https://en.wikipedia.org/wiki/Citro%C3%ABn_DS) / (변형) 짧고 둥근 소형 ← [Fiat 500](https://en.wikipedia.org/wiki/Fiat_500)·[Mini](https://en.wikipedia.org/wiki/Mini) | 1959 Eldorado의 과장된 핀·총알 미등, Fiat 500 얼굴 | **기화기 공회전 나사를 소리로 맞추기** + 드럼 브레이크, 발전기(제너레이터 — 공회전에서 충전 약함), 화이트월 타이어 닦기. (GPT 안: 점화 배선 순서 — 2순위) | Rare |
| 6 | 1964~72 · **Longhood Coupe** (머슬) | 긴 보닛·짧은 뒤 ← [Mustang 1세대](https://en.wikipedia.org/wiki/Ford_Mustang_(first_generation))·[Camaro 1세대](https://en.wikipedia.org/wiki/Chevrolet_Camaro_(first_generation)) / 넓은 어깨선 ← Camaro·[Barracuda](https://en.wikipedia.org/wiki/Plymouth_Barracuda) / 두 문·낮은 자세·보닛 공기구멍 ← [GTO](https://en.wikipedia.org/wiki/Pontiac_GTO)·[Charger](https://en.wikipedia.org/wiki/Dodge_Charger_(1966)) | Mustang 말 엠블럼·3줄 미등, Charger 숨은 램프 그릴, GTO 세로 쌍둥이 램프 | **타이밍 라이트로 점화 시기 맞추기**(분배기 엔진), 다이노(Lv16) 측정 | Epic |
| 7 | 1960s · **Backbay Van** (뒤 엔진 승합) | 짧은 앞·큰 객실 ← [VW Type 2](https://en.wikipedia.org/wiki/Volkswagen_Type_2)·[Corvair Greenbrier](https://en.wikipedia.org/wiki/Chevrolet_Corvair) / 뒤 엔진 공간 ← Type 2·Greenbrier / 큰 옆창 ← [Fiat 600 Multipla](https://en.wikipedia.org/wiki/Fiat_600_Multipla)·[Subaru Sambar](https://en.wikipedia.org/wiki/Subaru_Sambar) | Type 2의 **V자 앞면**·두 색 배치·큰 엠블럼 자리, 꽃무늬 | **엔진이 뒤에 있다!** (앞 보닛 열면 짐칸 — 첫 '아하'), 공랭이라 라디에이터 없음(→ 냉각 오진 함정) | Rare |
| 8 | 1973~85 · **Squareway Wagon** (+ 픽업·배달 밴 변형) | 각진 긴 지붕 ← [Volvo 240](https://en.wikipedia.org/wiki/Volvo_240)·[W123](https://en.wikipedia.org/wiki/Mercedes-Benz_W123) / 큰 짐칸 창 ← [Country Squire](https://en.wikipedia.org/wiki/Ford_LTD_Country_Squire)·W123 / 네모난 램프·앞면, 큰 범퍼 ← Volvo 240·[Caprice](https://en.wikipedia.org/wiki/Chevrolet_Caprice) | W123 세로 그릴+별, Volvo 세로 미등, 나무무늬를 기본 정체성으로 삼기(선택 장식만 — 실제도 나무가 아니라 **나무무늬 비닐 필름**) | **진공 호스 새는 곳 찾기**(청진기로 쉬익), 테일게이트 잠금 | Rare |
| 9 | 1980s · **Lowbeam Coupe** (팝업 쐐기) | 낮은 쐐기 앞 ← [RX-7](https://en.wikipedia.org/wiki/Mazda_RX-7)·[Porsche 944](https://en.wikipedia.org/wiki/Porsche_944) / 팝업 램프 ← RX-7·[MR2](https://en.wikipedia.org/wiki/Toyota_MR2) / 각진 쿠페 지붕 ← [AE86](https://en.wikipedia.org/wiki/Toyota_AE86)·[Corvette C4](https://en.wikipedia.org/wiki/Chevrolet_Corvette_(C4)) | MR2 중앙 엔진 비율, Corvette 앞면, 944 뒤 펜더 | **팝업 램프 한쪽만 안 올라옴('윙크')** — 모터·기어·링크 고치기([Hidden headlamp](https://en.wikipedia.org/wiki/Hidden_headlamp): 양산차 팝업은 2004년이 마지막) | Epic |
| 10 | 1990s · **Corner Hatch** (+ 초기 SUV 변형) | 짧은 해치백 ← [Golf Mk3](https://en.wikipedia.org/wiki/Volkswagen_Golf_Mk3)·[Civic 6세대](https://en.wikipedia.org/wiki/Honda_Civic_(sixth_generation)) / 둥근 모서리·넓은 뒷유리 ← Golf·Civic / (SUV) 높은 객실·큰 뒷문 ← [Explorer](https://en.wikipedia.org/wiki/Ford_Explorer)·[RAV4](https://en.wikipedia.org/wiki/Toyota_RAV4) | Golf 앞면·빨간 그릴 줄, Civic 램프, Cherokee 슬롯 그릴 | **OBD-II 첫 스캔**(미국 1996년형부터 의무 — [On-board diagnostics](https://en.wikipedia.org/wiki/On-board_diagnostics)) → 코드 보고 부품 찾기 | Uncommon |
| 11 | 2000~12 · **Glideback Hybrid** | 매끈한 짧은 앞 ← [Insight](https://en.wikipedia.org/wiki/Honda_Insight)·[Prius 2세대](https://en.wikipedia.org/wiki/Toyota_Prius_(XW20)) (1세대 [Prius](https://en.wikipedia.org/wiki/Toyota_Prius_(XW10))는 평범한 세단 모양이라 실루엣 출처에서 뺌 — 하이브리드 기계 출처로만) / 길게 내려오는 뒷지붕 ← [Prius 2세대](https://en.wikipedia.org/wiki/Toyota_Prius_(XW20))·Insight / 실용 뒷문 ← Prius 2세대·[Volt](https://en.wikipedia.org/wiki/Chevrolet_Volt) | Prius 삼각형 전체 윤곽, Insight 뒷바퀴 덮개 | **고전압 안전 3단계**: 주황 선 경고 확인 → 서비스 플러그 뽑고 기다리기 → 낮은 전압 진단 퍼즐(실제 절차 흉내만, 위험 동작 X) | Uncommon |
| 12 | 2013~ · **Quietline EV** (+ 전기 픽업 변형) | 그릴 없는 매끈한 앞 ← [Model 3](https://en.wikipedia.org/wiki/Tesla_Model_3)·[Leaf](https://en.wikipedia.org/wiki/Nissan_Leaf) / 짧은 앞 오버행·넓은 실내 ← Leaf·[Ioniq 5](https://en.wikipedia.org/wiki/Hyundai_Ioniq_5) / 바닥 배터리 ← Model 3·Ioniq 5 / (픽업) 캡+짐칸 ← [F-150 Lightning](https://en.wikipedia.org/wiki/Ford_F-150_Lightning)·[R1T](https://en.wikipedia.org/wiki/Rivian_R1T) | Cybertruck 삼각 차체, Ioniq 5 픽셀 램프, Rivian 세로 램프 | **배터리 모듈 진단·냉각 점검**(1세대 Leaf처럼 배터리 능동 냉각이 **없는** 차도 있음 — 이 차는 있는 쪽으로), 앞 트렁크(frunk). 오진 함정 = **머플러·엔진오일이 없음**(EV도 배터리 냉각수는 있음) | Uncommon |

- 'Concept 2040' 같은 미래 차는 넣지 않아요("최초부터 지금까지").
- 도감 문구: 1번은 "the first car"가 아니라 **"a motor carriage from the dawn of the automobile"**(자동차가 처음 나온 시대의 모터 마차) — 사실에 맞게.

## 2. 등장 방식
| 방식 | 어떻게 | 언제 |
|---|---|---|
| **확정 첫 시대 차** | Lv8(폐차장 해금) 직후 짧은 복원 의뢰로 **1대 확정**(추천: 5번 Starlane Cruiser — 아이들이 '옛날 차'로 바로 알아봄) | 베타 |
| **희귀 손님** | 평소 손님 줄에 가끔. 할머니·수집가 손님 "It's been in the family since my grandpa." 같은 서버에 작은 알림 띠(fun_boost #16 규칙: 독점 X, 참여해야 도감) | 알파(1종 시험) |
| **헛간 발견 (Barn Find)** | 폐차장·손님이 준 단서로 헛간에서 방수포 차 공개 → 세척 → 복원 | 베타 |
| **단서 20개 = 원하는 시대 확정** | 희귀 차 일을 끝낼 때마다 단서 1개. 운이 나빠도 언젠가 꼭 얻음 | 베타 |
| **Car Show 주말** | 서버에 시대 차 1대 확정, 주말 동안 여러 번 참여 가능(접속 시간 무관) | 나중 |
| **도감 + 박물관** | 시대별 실루엣 칸, 복원 기록을 **전시 모형**으로 걸기(차를 묶어 두지 않음 — 팔아도 기록은 남음). 시대 다 모으면 간판·네온 꾸미기 | 베타 |

**확률 (시험값, GPT 제안)** — 손님 1명이 올 때: 일반 85% · Uncommon 10% · Rare 3.5% · Epic 1% · Legendary 0.4% · Mythic 0.1%.
**가치 (같은 작업 시간의 일반 차 대비)**: 1× / 1.15× / 1.35× / 1.6× / 2× / 2.5×.
- 희귀도 = 대체로 오래될수록 귀함(아이들 직관 + "가끔"), 가장 오래된 1·2번만 Mythic·Legendary, 나머지는 연식과 섞음(1950s Rare, 1980s Epic).
- **Robux로 확률 X**. VIP 레이더는 이미 나온 매물의 위치·상태 미리보기만.

## 3. 만드는 양 줄이기
- 공용: 볼트·운반·상태(Condition)·도감·보상 코드, car_spec 이름 규칙(`Body/…`, `MechanicalParts/…`). **없는 부품은 슬롯을 만들지 않음**(1번에 Radiator 없음 — **소음기(silencer)는 Benz 차에 있었음**, 배터리는 핫튜브(Daimler)식이면 없음·Benz식 전기 점화면 있음 → 1번은 핫튜브라 Battery 없음, 작은 소음기 통은 장식으로; 12번에 Muffler 없음, 7번에 Radiator 없음).
- 시대 차마다 새로: 차체 실루엣 1, 바퀴 위치·크기 데이터, 있는 부품 목록, 특수 장식 2~3, 전용 미니게임 1.
- 지금 코드(`CarParts.luau`)는 17 stud 세단 고정 슬롯 14개 기준 → 시대 차는 **차마다 슬롯 표를 따로**(wr-dev와 정할 것).
- **첫 제작 3대**: 1 Pioneer Carriage, 5 Starlane Cruiser, 12 Quietline EV — 구조가 가장 달라서 공용 시스템의 한계를 빨리 알 수 있음.
- 3D 직전: 고른 차의 실사진 10~15장 + '그 장치가 실제로 달렸는지'를 한 번 더 확인(README 그림 규칙).

## 4. 일반 손님 차 라인업 (베타 '차량 5~8종')
서양 아이들이 매일 보는 차종. 섞을 단서 ← 미국 베스트셀러(조사 `_era_refs_b.md` 3장).
| 순서 | 차종 | 섞을 공통 단서 ← 출처 | 고장 재미 차이 |
|---|---|---|---|
| 1 | Sedan (지금 프로토 세단) | 4문·분리된 트렁크 ← Camry·Accord·Corolla | 기본 바퀴·브레이크·배터리의 기준 |
| 2 | Crossover SUV | 높은 객실·큰 뒷문·플라스틱 펜더 테 ← RAV4·CR-V·Equinox | 높은 차 밑, 뒷문 |
| 3 | Pickup | 객실 + 열린 짐칸·큰 앞면 ← F-150·Silverado·Ram | 무거운 바퀴, 짐칸 주변 |
| 4 | Hatchback | 짧은 뒤·통째로 열리는 뒷문 ← Civic 해치·Mazda3·Golf | 좁은 엔진룸, 뒷문 |
| 5 | Minivan | 긴 객실·옆 미닫이문 ← Pacifica·Odyssey·Sienna | 미닫이문 레일·잠금 |
| 6 | Delivery Van | 높은 화물칸·흰색·옆 미닫이 ← Transit·ProMaster·Sprinter | 큰 패널, 뒷문 경첩 |
| 7 | Station Wagon | 낮고 긴 지붕 ← Outback·V60·Regal TourX | 긴 뒤쪽 배선, 테일게이트 |
- 택시(노란색·지붕 표시등)는 세단의 **도색·손님 역할 변형**. 쿠페/머슬은 6번 시대 차와 겹쳐서 그다음.
- 이 7종 각각도 3D 전에 실사진 조사 → 공통점만 섞기(같은 규칙).

## 5. 결정 (사용자 10-21)
- 1번 차 = **네발**. 처음 만들 차 = **3대**(Pioneer Carriage · Starlane Cruiser · Quietline EV). 확정 첫 시대 차 = Starlane Cruiser(Lv8 복원 의뢰).

## 6. (지난) 결정 필요
1. **1번 차를 네발로** 할지(추천 — 세발 + 앞바퀴 1개 + 뒤 플라이휠은 Benz 한 차의 고유 조합이라 '그대로 닮은 모양' 위험). 기획서 8장의 '세발 모터 마차' 표현과 다름. 근거: Mercedes-Benz 공식 역사 페이지 — 같은 1886년 Daimler의 모터 마차가 "considered the world's first four-wheeled automobile"([링크](https://group.mercedes-benz.com/company/tradition/company-history/1886-1920.html), 내장 브라우저로 확인). 그래서 네발도 '처음 나온 시대의 차'로 사실에 맞아요.
2. 확정 첫 시대 차를 5번(1950s 크루저)으로 할지.
3. 시대 12개 전부 갈지, 첫 3대(1·5·12)만 먼저 만들고 반응 보고 늘릴지(추천: 3대 먼저).
