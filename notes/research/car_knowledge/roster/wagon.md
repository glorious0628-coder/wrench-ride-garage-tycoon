# 왜건 (Station wagon, 미국 말 "wagon" / "station wagon") — 베타 손님 차 조사 (wr-carbook, 2026-10-21)

> 목적: wr-design의 `docs/design/car_roster.md` 근거. 미국 거리에 흔한 실제 차 3~5대 → 크기·구동·엔진 배치·서스펜션·흔한 고장·겉모양 공통점.
> 환산 1 stud = 0.28 m. car_spec 규칙: 폭(X) ×1.15, 높이는 앉은 R15 머리 공간 확인(세단은 실제 5.2 → 게임 5.8, +0.6). 기준 세단 = 길이 17.0 · 폭 7.6 · 높이 5.8 · 휠베이스 10.0 stud.
> 실제 브랜드 얼굴(그릴·로고·시그니처 램프)은 섞지 않아요 — '피할 것' 칸에 적기.
> 출처는 각 줄 끝 [n], 맨 아래 목록. 확인 못 하면 "(확인 못 함)", 검색 결과 요약만 보면 "(검색 요약)".

## 0. 먼저 알아 둘 것 — 미국 왜건은 거의 '한 차'
- 오늘 미국 길 위 왜건의 압도적 다수 = **Subaru Outback 6세대(BT, 2020~2025년형)**. 미국 판매 2020 153,290 · 2021 154,623 · 2022 147,262 · 2023 161,812 · **2024 168,771대** [1].
- 나머지는 아주 적음:
  - Volvo V60 Cross Country — 2025년 1~11월 미국 **3,630대**, 일반 V60은 30대. 2026년 1월 말 주문 마감, **2026년 4월 미국 생산 끝** → Volvo는 미국에서 SUV만 파는 회사가 됨. 큰 V90은 이미 단종 [5].
  - Audi A6 allroad (C8) — 2025년형까지 미국 판매 사양이 남아 있음 [6][8](검색 요약). Motor1은 "2021년형 이후 미국에 없음"이라고 썼는데 위 2025년형 사양과 **어긋남** → 2025년형 사양 페이지를 믿음. 새 A6 allroad는 미국에 **2027년 목표** [7].
  - Buick Regal TourX (2018~2020년형) — 독일(Opel)에서 들여온 왜건, 2020년형 뒤 북미 판매 끝 [11]. Regal 전체 미국 판매 2019 10,363대(TourX만 따로는 확인 못 함) [11].
- **반전**: Outback 7세대(BU, 2026년형~)는 위키백과 분류가 **'5도어 SUV'** 로 바뀜 — "더 각진 모양, 더 높은 지붕, 더 많은 플라스틱 덧판(cladding)" [1]. → 게임의 '왜건'은 **2020~2025 Outback 같은 '들어 올린 왜건'** 을 기준으로 잡는 게 맞아요.
- 옛 미국 왜건(나무무늬 Country Squire·Pinto Squire 등)은 시대 차 → [history.md](../history.md) (나무무늬 = 1970~80년대는 비닐 무늬).
- 뺌: Subaru Forester — SUV(이 파일 범위 밖).

## 1. 대표 실제 차 (미국 판매 상위 — 판매 순위 출처 포함)
| 차 (세대·연식) | 길이 × 폭 × 높이 / 휠베이스 (mm) | 공차 중량 | 구동 | 엔진 배치·종류 | 앞 / 뒤 서스펜션 | 흔한 타이어 |
|---|---|---|---|---|---|---|
| **Subaru Outback** (6세대 BT, 2020~2025년형) | 4,860 × 1,855 × 1,680 / 2,745 [1] (2025년형 191.9 in ≈ 4,874 [2]) · 지상고 220 mm(Wilderness 240) [1] | 3,641 lb ≈ 1,652 kg [2] | **AWD 기본** (Symmetrical AWD) [2][13] | **세로배치 수평대향(박서) 4기통** 2.5 L FB25D 182 hp / 2.4 L 터보 FA24F 260 hp, CVT [1][13][14] | 스트럿 / **더블 위시본** [2] | P225/65R17 [2] |
| **Volvo V60 Cross Country** (2세대 SPA, 2018~, 미국 2026-04 생산 끝) | 약 4,788(188.5 in) × 1,850 × 약 1,504(59.2 in) / 2,872 [4][3] · 일반 V60보다 60 mm 높음 [3] | 4,004 lb ≈ 1,816 kg (B5 AWD Plus) [4] | AWD [4] | 앞 엔진, 직렬 4 2.0 L 터보 + 마일드 하이브리드 247 hp, 8단 자동 [4][3] | **더블 위시본** / 멀티링크 [4] (뒤 = 가로 복합소재 판스프링 — 검색 요약 [23]) | P215/55R18 [4] |
| **Audi A6 allroad** (C8, 2019~2025) | 약 4,951 × 약 1,905(75 in) × 약 1,496(58.9 in) / 약 2,925 [6][27] | 4,486 lb ≈ 2,035 kg [6] | AWD (quattro) [6][10] | 앞 엔진, **V6** 3.0 L 터보 + 마일드 하이브리드 335 hp, 7단 자동 [6] | 멀티링크 / 멀티링크 [6] + **에어 서스펜션**(높이 조절) [9][10] | P245/45R20 [6] |
| **Buick Regal TourX** (6세대, 2018~2020년형) | 4,990 × 1,860 × 1,480 / 2,830 [11] | 3,708 lb ≈ 1,682 kg [12] | **AWD 기본** [11][12] | 앞 엔진, 직렬 4 2.0 L 터보 LTG 250 hp, 8단 자동 [11][12] | 맥퍼슨 스트럿 / 5링크 [12] | P235/50R18 [12] |

- 판매 근거 다시: Outback 혼자 2024년 16.9만 대 [1] vs V60 CC 2025년 약 0.4만 대 [5]. **게임 손님 왜건 = Outback형이 대부분, 나머지는 '가끔 오는 유럽·미국 왜건'**.
- V60 CC 폭: 위키백과 V60 값 1,850 mm(거울 빼고) [3], cars.com은 75 in로 반올림 [4]. A6 allroad 폭·높이·휠베이스는 인치 표기 환산 + 검색 요약이라 ±10 mm 오차 있을 수 있음.

## 2. 평균 → stud (게임 권장)
4대 단순 평균: 길이 4,897 · 폭 1,868 · 높이 1,540 · 휠베이스 2,843 mm. 하지만 판매 비중이 Outback에 쏠려서 **게임 권장은 Outback 값 기준**.

| 항목 | 실제 (평균 / Outback) | stud (÷0.28) | 게임 권장(×1.15 폭 등) | 세단 대비 |
|---|---|---|---|---|
| 전장 (길이) | 4,897 / 4,860 mm | 17.5 / 17.4 | **17.4** | +0.4 |
| 전폭 (폭, 거울 빼고) | 1,868 / 1,855 mm | 6.7 / 6.6 | **7.6** (6.6 × 1.15) | 같음 |
| 전고 (높이) | 1,540 / 1,680 mm | 5.5 / 6.0 | **6.6** (Outback형, +0.6 머리 공간) · 낮은 왜건(V60 CC·A6·TourX 평균 1,493 mm)은 **5.9** | +0.8 (Outback형) / +0.1 (낮은 왜건) |
| 휠베이스 | 2,843 / 2,745 mm | 10.2 / 9.8 | **10.0** (세단과 같게 → 바닥·바퀴 자리 공유) | 같음 |
| 앞+뒤 오버행 합 | Outback 4,860 − 2,745 = 2,115 mm | 7.6 | 앞 3.4 + 뒤 **4.0** | 뒤 +0.4 (긴 짐칸) |
| 지상고 | Outback 220 mm · V60 CC 약 206~211 mm (검색 요약 [25]) | 0.79 / 0.75 | **0.8** | +0.3 (세단 0.5) |
| 타이어 지름 | 225/65R17 ≈ 724 mm (Outback), 245/45R20 ≈ 729, 215/55R18 ≈ 694, 235/50R18 ≈ 692 (계산) | 2.6 / 2.5 | **2.6** (Outback형) | +0.2 (세단 2.4) |
| 공차 중량 | 1,652 (Outback) ~ 2,035 kg (A6) | — | 리프트 질량 참고 | 세단보다 무거움(세단 값은 이 파일에서 확인 안 함) |

- 한 줄 요약: **"세단 바닥(휠베이스 10.0)에 지붕을 뒤 끝까지 늘리고, 바닥을 0.3 올리고, 바퀴를 키우고, 바퀴집에 검은 덧판을 두른 차"**.
- 높이 6.6이면 R15가 서서 들어가진 않지만, 앉은 머리 위 여유는 세단보다 큼. 리프트 높이(car_spec §3-3)는 지상고 +0.3만큼 덜 올려도 됨.

## 3. 세단과 다른 '속 구성' (부품 목록에 영향)
1. **엔진이 '눕고' '세로'로 놓임 (Outback)** — 기준 세단(가로배치 직렬 4)과 가장 큰 차이.
   - Subaru: 박서 엔진을 **세로(longitudinal)** 로 놓고 **변속기를 바로 뒤, 휠베이스 안쪽**에 둠 → 힘이 거의 일직선으로 **뒤 차동기어**까지 감. 가로배치 AWD는 방향 바꾸는 기어가 더 필요하다고 설명 [13].
   - 수평대향(flat-4) = 피스톤이 좌우로 누워 마주 봄 [14]. → 게임 `EngineBlock`은 **납작하고 넓은 상자 + 양옆 실린더 헤드 두 덩어리**.
   - **점화플러그가 엔진 위가 아니라 양옆**(좌 2 · 우 2)에 있어 손이 잘 안 들어감, 보통 **배터리·에어박스를 빼고** 작업, 운전석 쪽 뒤 플러그가 특히 어려움 [21](검색 요약). → 게임 SparkPlugs 미션: 세단은 '위에서 4개', Outback형은 '양옆 2+2 + 배터리·에어필터 먼저 빼기'.
   - FB 엔진은 **타이밍 체인**(옛 EJ는 타이밍 벨트) [14][15]. Outback 2020~2025 기본 엔진 = 직분사 FB25D [14].
2. **AWD 구동 부품이 추가** (세단 FF에는 없음):
   - **추진축(프로펠러 샤프트)** → **뒤 차동기어(리어 디퍼렌셜)** → **뒤 구동축 2개** (Subaru 설명의 '뒤 차동기어까지 일직선' [13]).
   - CVT 차의 앞뒤 힘 나누기 = **전자 제어 다판 트랜스퍼 클러치**(Active Torque Split), 미끄러지면 한쪽 축으로 최대 100% [13]. Subaru 정비 회보의 CVT 부품 목록에도 **'Multi Plate Transfer Clutches (MPT)'**, 'Extension Housing Rear Seal'이 있음 → 클러치가 **변속기 뒤쪽 안**에 들어 있다는 뜻 [16].
   - 수동 변속기 Subaru는 **비스커스 센터 디퍼렌셜**(50:50) [13] — 6세대 Outback엔 수동이 없어서(CVT만 [1]) 게임엔 참고만.
   - → 게임 부품 후보: `PropShaft`, `RearDiff`, `RearDriveShaft` ×2 (장식 또는 나중 고칠 부품).
3. **뒤 서스펜션이 세단보다 큼직하거나 특이함**:
   - Outback = 뒤 **더블 위시본** [2] / TourX = 5링크 [12] / A6 allroad = 멀티링크 + **에어 서스펜션**(지상고 조절) [6][9][10].
   - V60 = 뒤에 코일 스프링 대신 **가로로 놓인 복합소재(유리섬유) 판스프링 1장** (검색 요약 [23]) — 짐칸으로 스프링 탑이 안 튀어나옴.
4. **긴 리프트게이트**: 해치백보다 크고 무거운 뒷문, 역시 **가스 스트럿 2개**로 받침. 전동 리프트게이트 차는 스트럿이 약하면 **조금 열렸다가 다시 닫혀 버림** → GM 회보: 이때 **스트럿 2개 교체** [19].
5. **지붕 레일**: 2020년형 Outback은 **지붕 레일이 안쪽으로 돌아가 가로 바(crossbar)가 되는** 방식(탭 들고 → 소켓에서 빼고 → 돌려 꽂기) (검색 요약 [22]). 다른 차는 확인 못 함.
6. **차체 아래·옆 플라스틱 덧판(cladding)**: allroad 계열 = 더 넓은 윤거를 덮는 **플라스틱 바퀴집 덧판** + 높은 지상고 + 높이 조절 에어 서스 [9]; TourX = 플라스틱 덧판 + 조금 높인 차체 [11]; V60 CC = 검은 바퀴집 덧판 + 60 mm 높임 [3][24]. → 게임: `Cladding_FL/FR/RL/RR` 같은 '긁히는 덧판' 부품 후보(교체·도색 X, 검은 플라스틱).
7. **앞유리 카메라**: Outback 앞유리 교체 뒤엔 **EyeSight(앞유리 위 카메라) 재보정**이 필요 [17] → 유리 교체 미션 끝에 '카메라 보정' 한 단계.

## 4. 그 차종만의 흔한 고장 (증상 → 원인 → 진단 → 수리)
| 증상 (손님 말 영어 예) | 원인 | 진단 | 수리 |
|---|---|---|---|
| "A tiny chip turned into a long crack across my windshield." (2020~22 Outback) | (소송 주장) 앞유리 **잔류 응력** — 작은 점에서 한 줄 금이 퍼짐. Subaru는 결함 부인, 합의(2024) [17] | 금이 **한 충격점에서 한 줄로** 뻗었는지 확인(합의 조건) [17] | 앞유리 교체(개선 공정 유리) + **EyeSight 재보정**, 8년/10만 마일 1회 보증 [17] |
| "My battery is dead every morning, even the new one." (2015~2020 Outback) | (소송 주장) 시동 끈 뒤 차 안 통신망(**CAN**)이 소프트웨어 오류로 **잠들지 않아** 배터리를 계속 먹음 [18] | 새 배터리도 또 방전되는지 (진단 절차는 출처에 없음 → `01_starting_charging.md` 참고) | 합의: 첫 배터리 교체 5년/6만 마일 내 100% 등 [18] |
| "I see oil and coolant dripping, and it smells sweet." (2000년대 Outback, EJ25) | **EJ251/EJ253 헤드 개스킷** — 단층 코팅 개스킷이 안쪽 통로 또는 **바깥으로 샘** [15]; EJ253은 냉각 개선 [15] | 머리-블록 이음새의 기름·냉각수 자국 (검색 요약 [26]) | 다층 강판(MLS) 개스킷, 헤드 면 연마, 같이 타이밍 벨트·워터펌프·서모스탯 (검색 요약 [26]) |
| "It feels like stalling when I stop — like forgetting the clutch." / "Feels like someone bumped me from behind at idle." (2010~15 Outback CVT) | 락업 토크컨버터 설계 변경(16-90-13R), 2015년형 '쿵' 느낌(16-104-17), TR690 CVT 오일펌프 체인 커버 개스킷 샘(16-103-16R), P0841 [16] | 시운전 · **스톨 테스트 · 타임 래그 테스트** [16] | 해당 회보대로 수리; Subaru가 CVT 보증을 **10년/10만 마일**로 연장(16-107-17R, '리콜 아님') [16] |
| "The tailgate won't stay up" / "Power tailgate opens a bit then closes again." | 리프트게이트 **가스 스트럿 마모** (GM 회보에선 '소모품') [19] | 수동으로 열어 손 떼기, 전동은 반쯤 열리다 닫히는지 [19] | 스트럿 **2개 같이** 교체, 막대가 아래(문 쪽) [19] |
| "Something went clunk in the back." (2023 V60) | 생산 중 공구 설정 실수로 **뒤 판스프링이 부러질 수 있음** (Volvo TSB A10246, 2023-09) [20] | 판스프링 **일련번호**를 표와 대조 [20] | 번호가 맞으면 판스프링 교체 [20] |

- 게임 카탈로그 후보 우선순위: ① 앞유리 금(Outback형 대표 고장, 유리 + 카메라 보정 2단계) ② 아침마다 방전(배터리 미션 변형 — '갈아도 또 방전'이면 다른 원인 찾기) ③ 박서 점화플러그(양옆, 배터리·에어박스 먼저) ④ 오래된 박서 헤드 개스킷 샘(시대 차·중고 손님용).

## 5. 겉모양 공통점 — 섞을 특징 후보 (2대 이상에 공통인 것만) / 피할 것
| 섞을 특징 | 어느 차들에 공통 |
|---|---|
| **검은 플라스틱 바퀴집·문 아래 덧판** | A6 allroad [9] · TourX [11] · V60 CC [24](검색 요약) · Outback(7세대 설명이 덧판을 '더 늘림'이라 6세대에도 있다는 뜻 — 추론) [1] |
| **보통 왜건보다 높인 차체**(지상고 0.2 m 안팎) | Outback 220 mm [1] · V60 CC +60 mm [3] · allroad '더 높은 지상고' [9][10] · TourX '조금 높임' [11] |
| **AWD 기본** | 4대 모두 [2][4][6][12] |
| 지붕이 뒤 끝까지 가는 긴 몸통 + 거의 세운 리프트게이트 | 4대 모두 (왜건 정의) [1][3][9][11] |
| 큰 휠(17~20인치) + 키 큰 타이어 | Outback 17 [2] · V60 CC 18 [4] · TourX 18 [12] · A6 20 [6] |
| 지붕 레일 | Outback [22](검색 요약) — 다른 차는 확인 못 함 |

| 피할 것 (한 차만의 얼굴) | 어느 차 |
|---|---|
| **'토르의 망치' 모양 헤드라이트**(T자 주간등) | Volvo V60 CC [24](검색 요약) |
| 안쪽으로 돌려 가로 바가 되는 지붕 레일 **그 모양 그대로** (기능은 OK, 모양은 우리 식으로) | Subaru Outback [22](검색 요약) |
| 각 회사 로고·엠블럼·회사 고유 그릴 모양 | 전부 (그릴 세부 모양은 이번에 출처 확인 안 함 — 3D 전에 사진으로 확인) |

- wr-art 메모: '알아보게 할 특징 3개' 후보 = ① 바퀴집을 감싼 **두꺼운 검은 덧판** ② 뒤 끝까지 평평한 **긴 지붕 + 지붕 레일** ③ 세단보다 **눈에 띄게 높은 바닥**(바퀴와 덧판 사이 틈). 엔진룸을 열면 **납작한 박서 엔진**이 보이는 게 '속'의 특징.

## 6. 출처
1. Subaru Outback — Wikipedia (6·7세대 치수·지상고·엔진·미국 판매·7세대 SUV 분류) — https://en.wikipedia.org/wiki/Subaru_Outback
2. Cars.com — 2025 Subaru Outback AWD specs — https://www.cars.com/research/subaru-outback-2025/specs/
3. Volvo V60 — Wikipedia (2세대 치수·Cross Country +60 mm·미국 사양) — https://en.wikipedia.org/wiki/Volvo_V60
4. Cars.com — 2025 Volvo V60 Cross Country B5 AWD Plus specs — https://www.cars.com/research/volvo-v60_cross_country-2025/specs/
5. Motor1 — America's Last Volvo Wagon Is Dying As Buyers 'Overwhelmingly' Want SUVs (2025-12-23) — https://www.motor1.com/news/782597/volvo-last-wagon-america-retiring/
6. Cars.com — 2025 Audi A6 allroad 3.0 TFSI Premium Plus specs — https://www.cars.com/research/audi-a6_allroad-2025/specs/
7. Motor1 — Audi Isn't Giving Up On Wagons In America (A6 allroad 2027 목표; '2021년형 이후 없음'은 [6][8]과 어긋남) — https://www.motor1.com/news/803536/audi-wagon-lineup-us-today/
8. Kelley Blue Book — 2025 Audi A6 allroad (검색 요약: 가격·트림) — https://www.kbb.com/audi/a6-allroad/2025/
9. Audi A6 allroad quattro — Wikipedia (넓은 윤거·플라스틱 바퀴집 덧판·높은 지상고·조절 에어 서스) — https://en.wikipedia.org/wiki/Audi_A6_allroad_quattro
10. Audi — A6 allroad quattro 모델 페이지(~2025: AWD·어댑티브 에어 서스·높은 지상고) — https://www.audi.com/en/audi-a6-allroad-quattro-42
11. Buick Regal — Wikipedia (TourX 치수·덧판·AWD·판매·단종) — https://en.wikipedia.org/wiki/Buick_Regal
12. Cars.com — 2019 Buick Regal TourX AWD specs — https://www.cars.com/research/buick-regal_tourx-2019/specs/
13. Subaru of America media — Subaru Offers Four Versions of Symmetrical All-Wheel Drive (2014-02-23) — https://media.subaru.com/pressrelease/580/subaru-offers-four-versions-symmetrical-all-wheel-drive
14. Subaru FB engine — Wikipedia — https://en.wikipedia.org/wiki/Subaru_FB_engine
15. Subaru EJ engine — Wikipedia (EJ251 헤드 개스킷·EJ253 냉각 개선·타이밍 벨트) — https://en.wikipedia.org/wiki/Subaru_EJ_engine
16. Subaru Service Bulletin 16-107-17R — CVT Warranty Extension (NHTSA 보관본) — https://static.nhtsa.gov/odi/tsbs/2017/MC-10125885-9999.pdf
17. CarComplaints — Subaru Cracked Windshield Lawsuit Settlement Reached (2024-04-21) — https://m.carcomplaints.com/news/2024/subaru-cracked-windshield-lawsuit-settlement.shtml
18. CarComplaints — Subaru Battery Settlement Final Approval Hearing Information (2022-10-02) — https://m.carcomplaints.com/news/2022/subaru-battery-settlement.shtml
19. GM Recall Bulletin 15240A / NHTSA 15V415 — Power Lift Gate Prop Rod Recovery (스트럿 마모·2개 교체·막대 아래) — https://static.nhtsa.gov/odi/rcl/2015/RCRIT-15V415-2055.pdf
20. CarComplaints — 2023 Volvo V60 Technical Service Bulletins (TSB A10246 rear leaf spring) — https://m.carcomplaints.com/Volvo/V60/2023/tsbs/
21. CarTipsDaily — Subaru Spark Plug Replacement guide (박서 플러그 양옆·배터리·에어박스) (검색 요약) — https://cartipsdaily.com/subaru-spark-plug-replacement
22. Autoblog — 2020 Subaru Outback roof rack (레일이 돌아가 가로 바) (검색 요약) — https://www.autoblog.com/2019/04/18/2020-subaru-outback-roof-rack
23. Autocar / Henkel — V60 integral link + transverse composite leaf spring (검색 요약) — https://www.autocar.co.uk/node/86540 · https://www.henkel-adhesives.com/tz/en/spotlights/all-spotlights/news/partnership-benteler-sgl-composite-leafspring.html
24. WhichCar / Autotrader.ca — V60 Cross Country 디자인(토르의 망치 헤드라이트·검은 바퀴집 덧판) (검색 요약) — https://www.whichcar.com.au/?p=584000 · https://www.autotrader.ca/editorial/expert-reviews/volvo/v60-cross-country/2020-volvo-v60-cross-country-review/
25. iSeeCars — Volvo V60 Cross Country dimensions (지상고 8.1~8.3 in) (검색 요약) — https://www.iseecars.com/car/2025-volvo-v60_cross_country-dimensions
26. CarFromJapan / Jalopnik — Subaru head gasket 문제 역사·고치는 법 (검색 요약) — https://carfromjapan.com/article/the-history-of-subaru-head-gasket-problem · https://www.jalopnik.com/2036717/subaru-model-years-with-head-gasket-problems/
27. Autotijd — Audi A6 Allroad dimensions (길이 4,951·휠베이스 2,925 mm) (검색 요약) — https://autotijd.be/en/dimensions/audi/a6-allroad
