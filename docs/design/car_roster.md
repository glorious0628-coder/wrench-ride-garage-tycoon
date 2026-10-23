# 베타 손님 차종 계획 (car_roster) — v0.3 (wr-design, 2026-10-22)

> ⚠️ **사용자 규칙(10-22)**: "모양은 현실 세계에 없더라도 자동차 구조나 부품은 현실적이어야 돼" · "구조가 현실적이지 않은 자동차 절대 금지" → **겉은 자유, 속은 진짜**: 모든 차종은 실제 차 3~5대의 진짜 구조(구동·서스·엔진 배치·부품 자리)를 따름 — 규격서(hatchback_spec·pickup_spec·suv_spec)와 full_teardown 부품 표가 기준.

> 기획서 7장 베타 '차량 5~8종'. 서양 아이들이 매일 보는 차종 7개 + 세단 도색 변형(택시).
> **규칙(사용자 "자동차 뇌피셜 ㄴㄴ")**: 차종마다 미국 거리에 흔한 실제 차 3~5대의 **공통 특징만** 섞어요. 한 차만의 얼굴(그릴·로고·시그니처 램프)과 **한 회사만의 기계**(예: 수평대향 엔진)는 X.
> **근거 = wr-carbook 조사** `notes/research/car_knowledge/roster/`(README + 차종별 파일, 출처는 각 파일). v0.1의 ⓒ(가정) 값을 전부 조사 값으로 바꿨어요.
> 차 이름 규칙: 코드 = `CarType`(영어), 부품 이름은 car_spec 그대로, 없는 부품은 슬롯을 만들지 않음, 새 부품만 추가.
> 기준 세단 = car_spec v0.7(길이 17.0 · 폭 7.6 · 높이 5.8 · 휠베이스 10.0 stud, 가로배치 I4 FF, 앞 맥퍼슨 / 뒤 멀티링크, 타이어 2.75).
> **바퀴 크기 규칙**: carbook 값은 실제 비율(1 stud = 0.28 m, 폭 ×1.15). 세단처럼 캐주얼 그림체로 **모든 차종 타이어 ×1.146**(세단 2.4 → 2.75와 같은 비율).

## 결정 (메인 10-21)
- 만들 순서 = **세단 → SUV → 픽업 → 배달 밴 → 해치백 → 미니밴 → 왜건**(싼 차와 새 기계 차를 번갈아).
- ~~10-22 사용자 OK: 공개 전 = 해치백 + 픽업트럭~~ → **10-22 밤 사용자가 바꿈: "해치백·픽업은 공개 뒤 매주 업데이트로 넣자. 부품 따로 떼는 방식으로 제대로."** (처음 사용자 말은 그대로 지킴: "같은 디자인의 차가 연속으로 오지 않으면 좋겠어. 색만 다른 것도 x") → 공개(10/31) 판 차종 = **세단·SUV**, 해치백·픽업은 **매주 표에서 '한 주의 주인공'**(shop_areas §2·update_roadmap v0.2): **해치백 1/2 · 픽업 1/16**. 규격 `docs/specs/hatchback_spec.md`·`pickup_spec.md`(모양·크기·3D 할 일 — **그 안의 '공개 땐 세단과 같은 고장만 / 10/27'은 이 결정으로 옛 것**, 이제 그 주에 자기 부품·자기 고장까지 같이 들어옴, 아래 §6). 대표 시안 A/B 고르기 = 그 주가 가까워지면 메인이 사용자에게 물음(해치백 12/12 전 · 픽업 12/26 전).
- 단골 Tyler = 알파엔 세단, 배달 밴이 나오면 밴으로.

---

## 1. 한눈에

| 순서 | 차종 (CarType) | 섞을 실제 차 (carbook 조사) | 크기 길이 × 폭 × 높이 / 휠베이스 (stud) | 타이어 (게임, ×1.146) | 구동·엔진 (정한 것) | 세단과 다른 '속' | 제작 난이도 |
|---|---|---|---|---|---|---|---|
| 0 | **Sedan** | Camry · Accord · Altima · Sonata · Malibu | 17.0 × 7.6 × 5.8 / 10.0 | 2.75 | FF 가로 I4 | 기준 | — |
| 1 | **Crossover** (SUV) | RAV4 · CR-V · Equinox · Tucson | 16.6 × 7.7 × 6.6 / 9.7, 지상고 0.7 | 2.98 | FF 가로 I4, **AWD 판 = 뒤 커플링 + 프로펠러 샤프트**(RAV4 가솔린·CR-V 공통) | 리프트게이트 가스 스트럿 2, 지붕 레일, AWD 판의 뒤 디퍼렌셜 | **낮음** |
| 2 | **Pickup** | F-150 · Silverado 1500 · Ram 1500 · (중형 1대) | 21.0 × 8.5 × **7.4**(앉은 머리 +0.4) / 13.2 | 3.32 × 1.28, **너트 6** | **뒷바퀴굴림 세로배치 V6/V8 + 4WD 트랜스퍼 케이스** | **사다리 프레임**, 뒤 **통 차축 + 판스프링**(F-150·Silverado 공통 — Ram의 코일은 한 차만이라 X), 구동축·U조인트·뒤 디퍼렌셜, 짐칸·테일게이트, **스페어는 짐칸 아래 케이블로 감아 내림** | **높음** |
| 3 | **DeliveryVan** | Transit · ProMaster · Sprinter | 21.3 × 8.4 × **9.7**(하이루프) / 13.6 | 3.04 | **뒷바퀴굴림 세로배치**(Transit·Sprinter 2대 공통 — ProMaster의 FF는 한 차만) | 미닫이 옆문 + 뒤 양문, 뒤 **판스프링**(픽업 하체 재사용) | 중간 |
| 4 | **Hatchback** | Civic Hatchback · Mazda3 Hatchback · Corolla Hatchback · Golf GTI | **16.2 × 7.6** × 5.8 / **10.0**(세단 차대 그대로 — Civic·Mazda3 해치 = 세단 휠베이스) | **2.75(세단 바퀴)** | FF 가로 I4 | 뒤 오버행만 짧음(2.8), 해치 가스 스트럿 2 + 뒤 와이퍼 모터, 뒤 서스 = **멀티링크**(4대 중 3대 — 세단 뒤 그대로) | **낮음** |
| 5 | **Minivan** | Pacifica · Odyssey · Sienna · Carnival | 18.5 × 8.2 × 6.9 / 10.9, 지상고 0.5 | 2.98 | FF 가로 V6 | **양쪽 전동 미닫이문**(모터·케이블·롤러·레일), 큰 전동 뒷문, 뒤 서스는 토션빔 아님(요즘 미니밴은 스페어가 없거나 임시 스페어) | 중간 |
| 6 | **Wagon** | Outback · V60 Cross Country · A6 allroad · Regal TourX | 17.4 × 7.6 × 6.6 / 10.0, 지상고 0.8 | 2.98 | FF 가로 I4 + **AWD 기본**(SUV와 같은 커플링 방식 — Outback의 수평대향·세로배치는 한 회사만이라 X) | 긴 지붕·리프트게이트, 검은 바퀴집 덧판, 높인 차체 | **가장 낮음**(세단 + SUV 재사용) |
| — | Taxi | 세단 + 노란 도색·지붕 표시등 | 세단 | 2.75 | 세단 | 같음 | 거의 0 |

## 2. 차종별 — 겉 섞기 · 피할 것 · 고유 고장 (게임용 2~3개)
고장은 carbook이 찾은 실제 고장 중 **여러 차에 생기는 일반적인 것**만 골랐어요(한 차의 리콜·소송 건은 뺌).

### 2-1. Crossover
- **섞을 겉**: 높은 지붕·높은 바닥 + 거의 수평 지붕선, 거의 세운 리프트게이트(트렁크 턱 없음), **바퀴 둘레 검은 플라스틱 덧판**, **각진 바퀴 아치**, 지붕 레일 2줄, 짧은 앞뒤 오버행.
- **피할 것**: 팔각형 겹친 앞·뒤 모양·두 단 사다리꼴 그릴(RAV4), 그릴 속 숨은 보석 무늬 주간등(Tucson), Equinox 세로 줄 그릴 + 흰 지붕 투톤, 모든 로고·그릴 무늬.
| 고장 ID | 손님 말 (영어) | 원인 | 진단 | 수리 |
|---|---|---|---|---|
| LIFTGATE_STRUT | "My liftgate won't stay up." / "The power liftgate opens an inch, beeps, and closes." | 가스 스트럿 압력 빠짐 / 전동 스트럿 고장 | 끝까지 열고 손 떼기 → 스르르 내려오면 불량, 막대 기름 자국 | 스트럿 **2개 같이** 교체(해치백·왜건·미니밴과 공유 부품 `LiftgateStrut_L/R`) |
| BATTERY_CLAMP_LOOSE (함정) | "Something clunks under the hood when I turn." | 배터리 고정쇠 헐거움 → 배터리가 움직임(+단자가 닿으면 위험) | 배터리를 흔들어 봄, 고정쇠 자리 | **고정쇠 조이기**(배터리는 멀쩡 → 바꾸면 오진) |
| REAR_DIFF_FLUID (AWD) | "It groans in tight, slow turns." | 뒤 디퍼렌셜 오일 오염 | 천천히 크게 돌 때 뒤에서 '웅—' | 뒤 디퍼렌셜 오일 교환(액체 일) |

### 2-2. Pickup
- **섞을 겉**: 4도어 크루캡 + 따로 떨어진 짐칸(틈), 내려 여는 테일게이트, 큰 휠 + 두툼한 타이어, 높은 보닛, 뒤 범퍼 밑 사각 히치, 짐칸 밑 스페어, 옆 아래로 보이는 사다리 프레임.
- **피할 것**: C자로 감싼 헤드램프(F-150), 2~3단 쌓인 램프(Silverado), 큰 글자·십자 그릴(Ram), 모든 로고.
| 고장 ID | 손님 말 | 원인 | 진단 | 수리 |
|---|---|---|---|---|
| LEAF_SPRING_SAG | "The back sits low and squeaks over bumps." | 판스프링 처짐·판 부러짐, U-볼트 풀림 | 리프트에서 판 금·부러짐, U-볼트 옆 반짝이는 자국, 한쪽 기울기 | **좌우 한 쌍** 교체 — 무거워서 **둘이 들면 쉬움**(협동 재미) |
| UJOINT_WORN | "Clunk when I shift into Drive." | 구동축 U-조인트 마모 | 리프트, 중립에서 구동축을 **손으로 돌려** 유격 | U-조인트 교체(디퍼렌셜 요크와 위치 표시 후 분리) |
| EXH_MANIFOLD_TICK | "It ticks loud when it's cold, then goes away." | 주철 배기 매니폴드 균열·볼트 부러짐 | **차가울 때만** 소리(청진기), 그을음 자국 | 매니폴드·볼트·개스킷 교체 — 데운 뒤엔 소리가 사라져서 '식혀서 다시 듣기'가 단서 |

### 2-3. DeliveryVan
- **섞을 겉**: 짧은 보닛 + 높은 상자 지붕, 조수석 쪽 미닫이 옆문(옆 가로 레일 홈), 뒤 양문, 차체에 비해 작아 보이는 16인치 휠 + 굵은 타이어, 아주 긴 휠베이스.
- **피할 것**: 세 차 앞 얼굴 모두(별 엠블럼·파란 타원·RAM 글자와 각자 그릴·램프) → **세 차 어느 것도 닮지 않은 오리지널 얼굴**(wr-art 실사진 조사 때 대조).
| 고장 ID | 손님 말 | 원인 | 진단 | 수리 |
|---|---|---|---|---|
| SLIDING_DOOR_ALIGN | "The sliding door is so hard to open, I have to slam it." | 미닫이문 정렬 틀어짐 | 여닫기, 문 틈·정렬 | 문 위치 조정(틈 맞추기 미니게임 — 보닛 틈과 같은 틀) |
| LEAF_SPRING_SAG | "The back end sags when it's loaded." | 과적·피로로 판스프링 처짐 | 빈 차 높이 비교, 판 금 | 픽업과 공유 |
| REAR_AXLE_OIL | "Something's howling from the back." | 뒤 차축 기어 오일 부족 | 주입 플러그 열어 오일 높이 | 오일 보충(심하면 베어링) — Tyler 이야기("I carry heavy boxes all day.") |

### 2-4. Hatchback
- **섞을 겉**: 5도어 + 지붕 끝 경첩 해치(뒷유리 포함), 세단보다 **뒤 오버행만 짧음**, 16~18인치 휠, 뒷유리 와이퍼.
- **피할 것**: 그릴에서 헤드라이트로 이어지는 빨간 줄·벌집 그릴·X자 안개등·체크무늬 시트(GTI), 아주 두꺼운 C필러(Mazda3), 모든 로고.
| 고장 ID | 손님 말 | 원인 | 진단 | 수리 |
|---|---|---|---|---|
| LIFTGATE_STRUT | "My hatch won't stay up — it nearly hit my head." | 해치 가스 스트럿 압력 빠짐 | 열고 손 떼기 | SUV와 공유 |
| REAR_WIPER | "My rear wiper is super slow or stopped." | ① 축 녹슬어 낌 ② 모터 ③ 해치 배선 끊김 ④ 퓨즈 | **순서대로**: 퓨즈 → 커넥터에 12 V → 모터 소리 → 축에 윤활 | 원인 하나만 고침 — 여러 단계 진단 연습(Lv11 두 단계 진단과 같은 급) |

### 2-5. Minivan
- **섞을 겉**: 긴 상자 몸통 + 짧은 보닛, 양쪽 미닫이문 + 뒤 옆판 가운데 레일 홈(창 아랫선에 숨김), 거의 세운 큰 뒷문, 바퀴가 앞뒤 끝 쪽.
- **피할 것**: 번개처럼 꺾인 창 아랫선·떠 있는 D필러(Odyssey), 세로 헤드램프·별 지도 주간등·T자 뒤 램프(Carnival), 모든 로고.
| 고장 ID | 손님 말 | 원인 | 진단 | 수리 |
|---|---|---|---|---|
| POWER_DOOR_STUCK | "The sliding door is slow, grinds, or sticks near the end." / "My power sliding door won't move." | 레일에 이물질 / 롤러 닳음 / 구동 케이블 꼬임 | 레일 청소 뒤에도 그러면 롤러, 문이 아예 안 움직이고 케이블이 빠졌으면 케이블 | **레일 청소(쉬움)** → 안 되면 롤러 → 케이블(어려움) — 같은 증상, 세 단계 |
| POWER_LIFTGATE_NOISE (함정일 때도) | "The power liftgate makes a loud noise." | 전동 뒷문 구동 스트럿 고장 **또는 정상 작동 소리** | 갈리는·긁히는 소리·걸림·고장 코드가 **있을 때만** 고장 — 정상 차 소리와 비교(전후 비교 버튼) | 고장이면 전동 스트럿 교체, **아니면 아무것도 안 바꿈**("That's just how it sounds!") |

### 2-6. Wagon
- **섞을 겉**: 검은 플라스틱 바퀴집·문 아래 덧판, 보통 왜건보다 높인 차체, 지붕이 뒤 끝까지 가는 긴 몸통 + 세운 리프트게이트, 큰 휠, 지붕 레일.
- **피할 것**: '토르의 망치' T자 헤드라이트(V60 CC), Outback의 돌려서 가로 바가 되는 지붕 레일 **모양 그대로**, 모든 로고.
| 고장 ID | 손님 말 | 원인 | 진단 | 수리 |
|---|---|---|---|---|
| PARASITIC_DRAIN | "My battery is dead every morning, even the new one." | 시동 끈 뒤에도 무언가가 배터리를 먹음(잠들지 않는 모듈·켜진 실내등) | **기생 전류 시험**: 테스터를 달고 퓨즈를 하나씩 뽑아 전류가 떨어지는 퓨즈 찾기(실제 정비 요령) | 그 회로 고치기 — 배터리를 또 바꾸면 오진(BAT_DEAD·ALT와 헷갈리는 짝 3번째) |
| LIFTGATE_STRUT | "The tailgate won't stay up." | 가스 스트럿 | 열고 손 떼기 | 공유 |

## 3. 공용 부품 (재사용)
| 공용 | 쓰는 차종 |
|---|---|
| 세단 엔진룸·브레이크·바퀴 부품 | Crossover · Hatchback · Wagon · (Minivan 일부) |
| 세단 뒤 멀티링크 | Hatchback · Minivan · (Crossover·Wagon) |
| `LiftgateStrut_L/R` | Crossover · Hatchback · Wagon · Minivan |
| AWD 커플링 + 프로펠러 샤프트 + 뒤 디퍼렌셜 | Crossover(AWD) · Wagon |
| 판스프링 · 통 차축 · 구동축·U조인트 · 뒤 디퍼렌셜 | Pickup · DeliveryVan |
| 차 밑 스페어 케이블 | Pickup (옛 미니밴만 — 지금 미니밴 X) |
| 미닫이문 레일·롤러 | DeliveryVan · Minivan |

## 4. 베이·리프트 (carbook 확인)
- 지은 베이(28 × 40, 천장 20, 셔터 13.8 — world_contract): **7종 모두 들어감**. car_spec §7 최소 베이(20 × 30, 셔터 9)는 픽업이 빠듯하고 하이루프 밴은 못 들어감 → 맵은 지금 크기 유지.
- 밴을 리프트 `Under`(+6)로 올리면 지붕 15.7 < 천장 20.
- **리프트 팔 자리(`LiftPoint_*`)는 차종마다**: 프레임 차(픽업)는 **프레임 아래 약 Z ±4.5**, 나머지는 문턱 아래. 차종별 car_spec 부록에 적을 예정.

## 5. 다음
- 차종을 만들 차례가 오면 그 차종의 car_spec 부록(크기·피벗·LiftPoint·새 부품)을 써요(지금은 Crossover부터).
- 세 번째 헷갈리는 짝(PARASITIC_DRAIN)과 연료 캡·배터리 고정쇠 함정은 fault_catalog에 '차종 고장' 절로 옮길 예정.

## 6. 해치백·픽업 = 공개 뒤 매주 업데이트 (10-22 밤 사용자: "부품 따로 떼는 방식으로 제대로") — v0.1 (GPT r1 반영 — r2 전)
> 규칙(그대로): **세단과 같은 방식**(부품 = 표 한 줄 `id·kind·zone·lump·needs·holds·unlock`, 조이는 것 종류가 공구를 정함, 떼기 = 끼우기 거꾸로) + **차종마다 다른 속** = `PartGraph.derive(Sedan, { move, add, remove, set })`(wr-dev 계획 §2-4). 구조·부품은 반드시 현실. **연속 같은 차종 X**(10-22 규칙, `CustomerService`가 직전 차종을 뺌).
> 어느 주: **해치백 1/2(9주차) → 픽업 1/16(11주차)** (shop_areas §2·update_roadmap v0.2). 해치백이 먼저인 이유: 세단 차대·앞·바퀴·브레이크·뒤 멀티링크(E2)를 **그대로 쓰는 낮은 난이도**(규격), 해치 스트럿은 SUV와 공유 / 픽업은 **뼈대부터 다른 차** + 센 볼트·무거운 부품이라 바퀴·브레이크(4주차)·오일·벨트·차 밑(2주차)·E2 서스가 먼저 있어야 함. 이 순서는 car_roster 옛 순서(세단→SUV→픽업→밴→해치백)와 다름 — 사용자가 시기를 바꾼 김에 쉬운 것부터(메인 확인). **난도 설명 고침(GPT r1)**: 별은 **차종이 아니라 그 일**(깊이·시간·진단)로 정해짐 — 픽업 배터리는 여전히 ★1, 픽업 자기 구조 고장(판스프링·U조인트·매니폴드)은 규칙상 **최소 ★4**(car_difficulty §2). 그래서 ★5(1/23) 전 난도 상승은 차종 크기가 아니라 **11/28~ ★4 복합 의뢰 + 1/9 얼라인먼트 + 픽업 ★4 고장**이 공급함.
> 근거: 규격 `docs/specs/hatchback_spec.md`·`pickup_spec.md`(모양·자리·3D 할 일) · SUV 규격(리프트게이트·스트럿 자리) · carbook `roster/hatchback.md`·`pickup_3d.md` · full_teardown §0-2(E2 서스).

### 6-1. 해치백 주 (1/2) — 세단 + 엉덩이만 다름
- **그대로 쓰는 것**: 앞 전부(엔진룸·보닛·앞유리·앞 서스 E2) · 바퀴·브레이크 · 바닥 · 뒤 멀티링크(E2 쇼바·팔·스프링 — 4대 중 3대가 멀티링크) · 머플러 자리. 즉 **세단의 모든 부품·고장이 해치백에서도 그대로**(별도 줄 X).
- **`derive(Sedan, …)`**:
  | 바뀜 | id | kind | zone | lump | needs | holds | unlock · ★ | 메모 |
  |---|---|---|---|---|---|---|---|---|
  | remove | `Trunk`·`TrunkTrim`·`TrunkLid` | | | | | | | 트렁크 뚜껑 대신 해치 |
  | add | `Liftgate` 해치(뒷유리 포함) | Liftgate | Body | `Shell` | `Gate:Open` | `{ Bolt ×4 경첩 }` | Lv9 U3(판금) | 뗄 일은 나중, 열고 닫기만 |
  | add | `LiftgateProp` 받침 막대(보닛 받침대 방식) | Prop | Body | `Shell` | `Gate:Open` | 손으로 걸기 | 같이 | 이게 걸려야 `Gate:Propped` |
  | add | `LiftgateStrut_L/R` 해치 가스 스트럿(SUV와 공유) | LiftgateStrut | Body | `Shell` | **`Gate:Open` + `Gate:Propped`**(열림 ≠ 받침 완료 — GPT r1, 스트럿을 풀면 문이 떨어지므로) | `{ BallClip ×2 }` 양 끝 볼 소켓 클립(손으로 톡, 작은 드라이버로 살짝) | **Lv3 ★1** `LIFTGATE_STRUT` | **2개 같이** 교체 |
  | add | `RearWiperArm`·`RearWiperMotor` | RearWiper | Body | `Shell` | `Gate:Open`, `LiftgateTrim`(해치 안쪽 덮개) | 팔: `{ Bolt ×1 + 캡 }` · 모터: `{ Bolt ×2, Connector ×1 }` | **Lv10 ★3**(분기 진단) `REAR_WIPER` | 아래 진단 줄 |
  | add | `LiftgateTrim` 해치 안쪽 덮개 ⊙ | Trim | Body | `Shell` | `Gate:Open` | `{ Clip ×4 }`(ⓒ) | 같이 | 가림 부품 |
  | meshonly | `LiftgateLatch`·`Striker`(잠금쇠·차체 걸쇠) · `Wiring_Gate`(해치 가로지르는 선 + 뒤 워셔 호스) · `CHMSL`(위쪽 세 번째 브레이크등) | | Body | `Shell` | | 메시만(U2~U3 고장 ⓒ) | | 안 보이면 해치가 장식으로 보임 |
  | set | `Bumper_R` 뒤 범퍼 | BumperCover_R | | | `RearLampCover` | 모양만 다름(볼트 위치) | 세단 줄 그대로 | 해치 아래 가림 |
  | set | `Taillight_L/R` | | | | **바깥 램프 = 차체**(`Taillight_Outer_L/R`, 세단 줄 같음) · **안쪽 램프 = 해치**(`Taillight_Inner_L/R`, `Gate:Open` + `LiftgateTrim`) | 바깥 `{ Bolt ×2, Connector ×1 }` · 안쪽 `{ Nut ×2 + Connector ×1 }` ⓒ | 세단 줄 / 안쪽 U2 | GPT r1: Civic·Corolla처럼 바깥 차체·안쪽 해치로 나눔 |
  | set | `Muffler` | | | | | 배기 끝 −0.8, 스페어 우물 | 세단 줄 | |
- **고장 둘**: `LIFTGATE_STRUT`("My hatch won't stay up — it nearly hit my head." — 열고 손 떼면 스르르, 막대 기름 자국) · `REAR_WIPER`("My rear wiper is super slow or stopped." — **해치를 닫고 작동 시험 먼저** → 퓨즈 → 모터 커넥터에 12 V를 재서 **갈림**: ⓐ 전압 없음 = 해치 경첩 근처 **배선**(구부림에 끊김) ⓑ 전압 있음 = 모터·축 → 소리 → 축 윤활 / 모터 교체. **손님마다 원인이 하나(위 4가지 중 추첨)** — 같은 순서를 외우는 의식이 되지 않게(GPT r1). Lv10 두 단계 진단과 같은 급).
- **새 코드**: 조건 **`Gate:Open` + `Gate:Propped`** 둘(`HoodProp` 방식 재사용) · 조이는 것 종류 `BallClip` 1개(손) · 진단 갈림 4원인 추첨 · 뒤 잭 = 뒤 차축 + 1.6(규격 §7).
- **'또 세단이네' 막기(GPT r1 — 휠보다 뒷모습)**: ① **짐칸 턱이 전혀 없는 지붕 끝 해치, 크게 보이는 뒷유리** — 회색 시안 단계에서 **해치를 닫은 옆모습만으로 세단과 구별되는지** 검사(메인) ② **첫 해치백 손님은 도착하며 해치를 한 번 쑥 올려 보임**(유리째 위로 — 1.5초 연출, 첫 방문 때만) ③ 휠 살·얼굴은 보조.
- **3D**: 규격 §6 그대로(Shell·Glass·Chassis·Hood·Bumper_F/R·RearWiper·Underbody만 새로, 나머지는 세단 메시를 `Hatchback_` 이름으로 한 번 더 굽기) + **부품 따로**: `Liftgate`·`LiftgateStrut_L/R`(SUV 메시)·`LiftgateTrim`·`RearWiper*`. 휠은 **살 모양만 다르게**(연속 같은 차 X).
- **작은 것(같은 주)**: SUV도 같은 `LiftgateStrut`·`Gate:Open`을 받음(SUV 자기 고장 = 리프트게이트 스트럿 먼저) + 밈 차 Bathtub ✗(픽업 주로).

### 6-2. 픽업 주 (1/16) — 뼈대부터 다른 차
- **그대로 쓰는 것**(자리만 새로, 크기 확인): 패드·캘리퍼·디스크(1.43) · 냉각수 통·브레이크액 통 · 와이퍼 · 공용 조이는 것 종류·공구 · 바퀴(너트 **6** — 같은 `LugNut`, 개수 6). 배터리(긴 AGM)·라디에이터(4.6 × 2.4)·머플러(세로 타원) = 픽업 자기 메시(같은 `kind`, 다른 크기).
- **`derive(Sedan, …)`** (규격 §9 코드 약속 + 아래):
  | 바뀜 | id | kind | zone | lump | needs | holds | unlock · ★ |
  |---|---|---|---|---|---|---|---|
  | remove | `Strut_F*`(E2 맥퍼슨) · 앞 `Shock`/`Spring` 합체 · `Shock_R*`·`Spring_R*`·`RearArm2_R*`(멀티링크) · 세단 `EngineUnderCover_*` | | | | | | | 픽업 서스 구조가 다름 |
  | add 앞 | `Coilover_FL/FR`(코일 + 쇼바 **통째**, 아래 팔 위) | Coilover | Wheel | `Deco_Hub_F?` | `Lift:Wheel`, `Stands`(**프레임 레일 아래**), `Wheel_F?`, `Support:Arm` | 위 `Bolt ×2` + 아래 `Bolt ×1`(+ 토크 ⓒ) | **Lv9 ★3** `COILOVER_LEAK` — **통째 교체만**(스프링만 따로는 ★5 압축기 이후, GPT r1) |
  | add 앞 | `HalfShaft_FL/FR`(4WD 앞 반축 + 등속조인트 부트) · 앞 `Differential` ↔ `TransferCase` 연결 | | Under | | | 메시만 | | 4WD가 보이게(GPT r1) |
  | add 앞 | `UpperArm_F*`·`LowerArm_F*` | Arm | Wheel | `Deco_Hub_F?` | 같음 | 메시만(U3) | |
  | add 뒤 | **`LeafSpring_RL/RR`** 판스프링 | LeafSpring | Wheel | `Deco_RearAxle` | `Lift:Wheel`, `Stands`(**프레임 레일 아래 — 차체를 받침. 뒤 스탠드는 차축 아래가 아님**: 규격 §7의 '차축 아래' 자리는 바퀴만 뗄 때), `Wheel_R?`, **`Support:Axle`**(통 차축을 **별도 잭**이 받쳐 천천히 내림 — `Support:Arm`과 같은 코드, 점 `J_Axle`) | 한 쪽: `{ UBolt ×2 → 너트 ×4, Bolt ×1 앞 눈, Bolt ×2 뒤 섀클 }` = **조이는 것 7** · 한 쌍 = **14** + 바퀴 너트 12 = **26 → ★3 상한 22 초과 → ★4(≤ 30)** (ⓒ 토크) | **Lv10 ★4** `LEAF_SPRING_SAG` — **좌우 한 쌍**, 무거워서 **둘이 들면 쉬움**(친구 또는 직원 `Call`), 한 쪽씩 따로 맡길 수도(같은 일 두 번) |
  | add 뒤 | `Shock_R*`(프레임 바깥) | Shock | Wheel | `Deco_RearAxle` | 같음 | `{ Bolt ×1 위, Bolt ×1 아래 }` | **Lv7 ★2** `SHOCK_LEAK`(세단과 같은 고장 이름·다른 부품) |
  | add 구동 | `Driveshaft_R` + `UJoint_*` | Driveshaft | Under | `Deco_Transaxle` | `Lift:Wheel`/`Lift:Under`, `Stands` | **양 끝 요크 모두 위치 표시(페인트)** → 디퍼렌셜 쪽 `{ Bolt ×4 요크 }` → 축을 손으로 받쳐 내림(무게 ⓒ) → 변속기 쪽은 빼서 앞으로 밀기 / U조인트: 스냅 링(손) | **Lv11 ★4** `UJOINT_WORN`("Clunk when I shift into Drive.") — 중립에서 손으로 돌려 유격(차종 구조 고장 → 최소 ★4) |
  | add 구동 | `Driveshaft_F` · `Differential_F/R` · `TransferCase` | | Under | | | **오일 마개**(`DrainPlug`·`FillPlug`, **`Fluid:GearOil`** 새 액체 — SUV 뒤 디퍼렌셜도 같은 것) | 메시 + 오일 교환 일 `GEAROIL_OLD` ★2(Lv8) |
  | add 배기 | `ExhaustManifold_L/R` | Manifold | EngineBay | `Deco_EngineLower` | `Hood:Open`, 엔진 커버 | `{ Nut ×6~8 스터드, Bolt ×3 열 차단판 }`(ⓒ) + **녹** | **Lv12 ★4** `EXH_MANIFOLD_TICK`("It ticks loud when it's cold" — **식혀서 다시 듣기**) |
  | add 짐칸 | `Tailgate`(내려 여는 문) | Tailgate | Body | `Shell` | | 케이블 2 + 경첩 핀(손으로 들어 뺌) | U2 |
  | add 짐칸 | **`SpareTire`**(짐칸 밑 케이블로 감아 내림) | SpareTire | Under | | | **휠 윈치 샤프트** — 범퍼 구멍에 육각 막대를 넣어 돌림(꾹 돌리기 → 내려옴, 케이블이 느슨해짐) | **Lv3 ★2** `TIRE_FLAT` 픽업판 "Spare swap"(고임목·잭·스탠드·바퀴 너트 6·윈치·스페어 고정 = ★1 상한 8 초과 → 안내 붙인 ★2, GPT r1) — **첫 픽업 ★1 일은 배터리 같은 짧은 일** |
  | add 짐칸 | `Hitch`(사각 히치) | Hitch | Under | `Deco_Underbody` | | `{ Bolt ×2 + 핀 }` | U2 |
  | meshonly | `Frame` 사다리 프레임 | | | | | **뗄 수 없음**(★5 복원 때 프레임 교정은 판금 일) | |
  | set | 보닛 | | | | | 가스 스트럿(받침대 X) | |
  | set | 센 볼트 | `BoltHeavy` | | | | 센 볼트가 더 많음 → **브레이커 바(Lv9)** | |
- **새 코드**: 조건 `Support:Axle`(= `Support:Arm`을 통 차축 점 `J_Axle`에) · 액체 `Fluid:GearOil` · `Differential`/`UJoint` 부품 + 위치 표시(RearArm2의 캠 표시와 같은 장치) · 휠 윈치(= 새 동작 '육각 막대 돌리기', 꾹 돌리기 재사용) · 규격 §9의 잭·스탠드 점별 높이(`undersideAt`) · 너트 6.
- **코일오버 압축기 일은 1/23 이후**: 스프링이 압축된 채라 통째 교체만 열고(위 표), 스프링만 분해하는 ★3 일은 열지 않음(압축기 = ★5 큰 일 주).
- **무거운 것 = 협동 재미**: 판스프링 한 쪽 약 14 kg(ⓒ) 두 손 + 걸쇠. 친구 또는 직원 `Call`(staff §5)이 처음 쓰이는 자리 중 하나(앞 구역 유리보다 먼저).
- **3D**: 규격 §6 + 위 부품 따로(`LeafSpring`·`UJoint`·`Driveshaft`·`Differential`·`Coilover`·`ExhaustManifold`·`SpareTire` 케이블·`Tailgate`). 프레임·차축은 검은 무광, 디퍼렌셜 덮개는 밝은 회색(규격 §6).
- **작은 것(같은 주)**: SUV 뒤 디퍼렌셜 오일(`Fluid:GearOil` 공유) · 밈 차 Bathtub(픽업).

### 6-3. 글·표시 (원문 EN · 한)
| 키 | EN | 한 |
|---|---|---|
| `n.gateProp` | Prop the liftgate before you touch the struts. | 스트럿을 만지기 전에 해치를 받쳐 줘요. |
| `n.supportAxle` | The stands hold the truck. Roll the jack under the axle. | 차는 스탠드가 받치고 있어요. 잭을 차축 밑으로 옮겨 주세요. |
| `n.markDriveshaft` | Mark the driveshaft so it goes back the same way. | 구동축에 표시해요. 그래야 같은 자리로 돌아가요. |
| `n.spareWinch` | Turn the winch to lower the spare. | 윈치를 돌려 스페어를 내려요. |
| `n.cool` | Let it cool, then listen again. | 식힌 뒤 다시 들어 봐요. |

### 6-4. 일정·준비 (shop_areas §2와 맞춤)
| 때 | 해치백 | 픽업 |
|---|---|---|
| 시안 A/B 고르기 (메인 → 사용자) | **12/5 전**(GPT r1: 빠듯 → 두 주 앞당김) | **12/12 전** |
| 3D 시작 · 굽기 | 12/5~ · 12/19 낮 | 12/12~ · 1/2 낮 |
| 코드(derive·조건) · 자동 분해 봇 | 12/12~12/28(3D 오기 전 가짜 블록으로 먼저) | 12/26~1/10 |
| 2인 시험(해치: 스트럿 한 쌍 + 와이퍼 분기 진단 / 픽업: **프레임 받침 → 차축 잭 → 판스프링 좌우 교체 → 다시 조립**) | 12/30 | 1/12 · 1/14(두 번) |
| 공개 | 1/2 | 1/16 |
| **통과 못 하면**(GPT r1) | **껍데기만 먼저 넣지 않음** — 필수 분해 경로와 자기 고장이 통과 못 하면 **그 차종 공개일을 옮기고**, 그 주 주인공은 **이미 끝난 다음 것**(예: 해치백 ✗ → ④ 얼라인먼트를 1/2로 당기고 해치백은 1/16로, 픽업 ✗ → ★5 큰 일을 1/16로 당기고 픽업은 1/30). 최대 두 주 — 그 이상이면 사용자에게 물음 |
| **픽업 합격 기준 하나** | | **프레임에서 차체 받침 → 잭으로 차축 받침 → 판스프링 좌우 교체 → 다시 조립을 2명이 끝까지 통과한 픽업만 1/16에 냄** |

### 6-4b. 판스프링 한 쪽 vs 한 쌍 (GPT r2 — 고장 원인과 수리가 어긋나지 않게)
- **`LEAF_SPRING_SAG`(오래 써서 처짐) = 좌우 한 쌍이 기본**(둘 다 같이 처졌고, 진짜도 같이 바꾸라고 권함 — carbook ⓒ). 한 일 = 조이는 것 14 + 바퀴 12 = 26, **★4**.
- **`LEAF_SPRING_BROKEN`(한 쪽이 충격으로 판 부러짐, 새 고장) = 한 쪽만**: 단서 = **한 모서리만 낮음 + 판 한 장 부러진 자국**, 반대쪽을 **검사하면 멀쩡**(눈으로 확인하는 짧은 단계). 한 일 = 7 + 바퀴 6 = 13이지만 **차종 구조 고장이라 ★4 그대로**(별을 낮추지 않음 — car_difficulty §2). 반복이 길면 별이 아니라 **같은 종류 조임을 쓸기로 빠르게**(임팩트·라쳇).
- 그래서 아이에게 "왜 이번엔 하나, 이번엔 둘인가"가 눈으로 설명됨(처짐 = 양쪽이 낮음 / 부러짐 = 한쪽만 낮음). **한 쪽 수리를 흔한 처짐 의뢰에 쓰지 않음**(r2 최대 위험) — 고장 줄이 원인별로 따로.
- 첫 픽업 방문(GPT r2): **짧은 ★1 바퀴 의뢰**로 시작 — 큰 차체·여섯 개 휠너트·프레임 받침 자리를 직접 보게(배터리만으로 고정 X), **스페어 윈치는 도착 때 눈에 띄게 보여 주고**, 윈치를 직접 내려 고치는 일은 ★2 'Spare swap' 별도 의뢰. 해치백 주는 **1/2 유지**(12/26 공개는 2인 시험 12/30보다 먼저라 위험 — 접속이 낮을지는 출시 뒤 숫자로).

### 6-5. 새 차종은 누구에게 언제 보이나 (GPT r1)
- 튜토리얼 고정 차를 마친 뒤에는 **Lv1부터 해치백·픽업이 방문**(`CarTypeShare`) — 처음엔 **세단 공통 고장만**(배터리·바퀴·패드·범퍼·라디에이터…). 자기 고장(해치 스트럿 Lv3 · 와이퍼 Lv10 · 픽업 ★4들 Lv10~12 · Spare swap Lv3)은 **그 부품의 레벨·공구·3D가 다 열린 뒤에만** 나옴.
- **이미 Lv9+인 플레이어**는 출시 직후 자기 고장을 받을 수 있어야 함 → car_difficulty §3 '새 일이 열리면 다음 3대 안에 한 번' 규칙을 **업데이트 뒤 첫 방문에도 적용**(추첨 운에 묻히지 않게).
- 연속 같은 차종 X는 비율표만으론 안 됨 → **튜토리얼·단골(Rosa·Tyler) 세단까지 직전에 셈**(wr-dev 이미 받은 일).

### 6-6. 게임 교과서 검사 · 크기
1. **아이 기대**: "큰 트럭이다!" · "해치가 위로 열려!" — 새 차가 오면 일도 새로움 ✓
2. **따뜻·손맛**: 스페어를 윈치로 내리는 손맛, 해치를 받쳐 두는 막대, 두 사람이 들어 올리는 판스프링 ✓
3. **서툴러도**: 세단과 같은 순서(고임목→잭→스탠드), 새 단계는 한 줄 막힘 안내 ✓
4. **글 없이**: 큰 차체·프레임이 보임, 해치 열림, 기름 줄 ✓
5. **'정비소가 자란다'**: 다른 차종 손님이 정비소를 북적이게 ✓ (새 숫자 X)
- 크기: 해치백 **M**(조건 1 · 부품 6 · 3D 새로 8) · 픽업 **L**(조건 2 · 액체 1 · 새 동작 1 · 부품 15+ · 3D 새로 20).

### 6-7. 결정 필요 (사용자 — 메인이 시안 때 묻는 것과 합침)
1. 해치백이 픽업보다 먼저(1/2 → 1/16) — OK?
2. 해치백 주에 SUV 해치 스트럿도 같이, 픽업 주에 SUV 디퍼렌셜 오일도 같이 — OK?
