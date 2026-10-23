# 소형 크로스오버 SUV (Compact crossover SUV, 미국 말 "compact SUV") — 베타 손님 차 조사 (wr-carbook)

> 목적: wr-design의 `docs/design/car_roster.md` 근거. 미국 거리에 흔한 실제 차 4대 → 크기·구동·엔진 배치·서스펜션·흔한 고장·겉모양 공통점.
> 환산 1 stud = 0.28 m. car_spec 규칙: 폭(X) ×1.15, 높이는 앉은 R15 머리 공간 확인(세단은 +0.6). 기준 세단 = 길이 17.0 · 폭 7.6 · 높이 5.8 · 휠베이스 10.0 stud.
> 실제 브랜드 얼굴(그릴·로고·시그니처 램프)은 섞지 않아요 — '피할 것' 칸에 적기.
> 출처는 각 줄 끝 [n], 맨 아래 목록. 확인 못 하면 "(확인 못 함)", 검색 결과 요약만 보면 "(검색 요약)".
> 조사일 2026-10-21. 단위 바꾸기: 1 in = 25.4 mm, 1 lb = 0.4536 kg (계산은 wr-carbook).

## 0. 한 줄 요약
- 소형 SUV = **세단과 같은 '가로배치 4기통 앞바퀴굴림(FF)' 뼈대**에 키(높이)와 바닥(지상고)을 올리고, 트렁크 대신 **뒷문(liftgate)** 을 단 차. 4대 모두 앞 = 맥퍼슨 스트럿, 뒤 = 멀티링크(Equinox는 '4링크') [4][6][8][10].
- 세단과 가장 큰 '속' 차이 = **사륜(AWD)을 고르면 뒤로 힘을 보내는 부품이 더 붙음**(뒤로 가는 축 + 뒤 차동/클러치 뭉치). 단, 하이브리드 RAV4는 **축 없이 뒤에 전기모터**를 달아요 [2][3][25].
- 2024년 미국 판매: RAV4 1위 SUV(전체 3위), CR-V 2위 SUV(전체 4위) — 이 차종이 미국 동네 정비소 손님의 큰 몫 [1].

## 1. 대표 실제 차 (미국 판매 상위 — 판매 순위 출처 포함)
2024년 미국 판매(대수, 전체 차 순위): **RAV4 475,193 (3위) · CR-V 402,791 (4위) · Equinox 207,730 (13위) · Tucson 206,126 (14위)** [1]. Ford Escape는 20위 안에 없고, 2026년형을 끝으로 단종 발표(2025-08) → 이번 표에서 뺐어요 [11].

| 차 (세대·연식) | 길이 × 폭 × 높이 / 휠베이스 (mm) | 공차 중량 | 구동 | 엔진 배치·종류 | 앞 / 뒤 서스펜션 | 흔한 타이어 |
|---|---|---|---|---|---|---|
| Toyota RAV4 5세대 XA50 (2019~2025년형) [2] | 4,570~4,600 × 1,855 × 1,660 / 2,690 [2] (토요타 발표: 4,595 × 1,854 × 1,699, 휠베이스 2,690 [3]) | 1,530~1,640 kg (하이브리드 1,680~1,720) [2] | FF 또는 AWD [2] | 가로배치 직렬 4기통 2.5 L A25A-FKS, 8단 자동 / 하이브리드 A25A-FXS + eCVT [2] | 스트럿 / 멀티링크 [4] | 225/65R17 (LE) [4] |
| Honda CR-V 6세대 (2023년형~) [5] | 4,694 × 1,867 × 1,681~1,689 / 2,700 (184.8 × 73.5 × 66.2~66.5 in, 106.3 in) [6] | 1,575~1,781 kg (3,472~3,926 lb) [6] | FF 또는 AWD('Real-Time AWD') [5][6] | 가로배치 1.5 L 터보 4기통 + CVT / 하이브리드 2.0 L + e-CVT [5] | 맥퍼슨 스트럿 / 멀티링크 [6] | 235/65R17 (LX), 235/60R18 (EX 등) [6] |
| Chevrolet Equinox 4세대 (2025년형~) [7] | 4,653 × 1,902 × 1,666 / 2,730 [7] | 1,555 kg (FWD LT 3,428 lb) [8] | FF(CVT) 또는 AWD(8단 자동) [7] | 가로배치 1.5 L 터보 4기통 LSD [7] | 맥퍼슨 스트럿 / 4링크(Four-Link) [8] | 235/65R17 (LT) [8] |
| Hyundai Tucson 4세대 NX4 긴 휠베이스(북미) (2022년형~) [9] | 4,630~4,670 × 1,865 × 1,650~1,690 / 2,755 [9] (SE FWD: 길이 182.7 in = 4,641, 높이 66.3 in = 1,684 [10]) | 1,555 kg (SE FWD 3,429 lb) [10] | FF 또는 AWD [9] | 가로배치 2.5 L 4기통 + 8단 자동 / 1.6 T 하이브리드 [9][10] | 스트럿 / 멀티링크 [10] | P235/65HR17 (SE) [10] |

- 지상고(바닥 높이): RAV4 LE 8 in(203 mm) [4] · CR-V 2WD 7.8 in / AWD 8.2 in(198/208 mm) [6] · Tucson SE 7 in(178 mm) [10]. Equinox는 표에 없음(확인 못 함) [8].
- RAV4는 2026년형부터 6세대(XA60)로 바뀌었어요 — 위 숫자는 거리에 가장 많은 5세대 기준 [2].
- 옛 세대 참고: Equinox 3세대(2018~2024) 4,652 × 1,843 × 1,661 / 2,725 — 4세대가 폭만 약 6 cm 넓어짐 [7].

## 2. 평균 → stud (게임 권장)
계산: 4대 평균(RAV4는 토요타 발표 4,595 / 1,699, Tucson은 SE 실측값 4,641 / 1,684 사용).

| 항목 | 실제 평균 | stud | 게임 권장(×1.15 폭 등) | 세단 대비 |
|---|---|---|---|---|
| 전장 (길이) | 4,646 mm | 16.6 | **16.6** | −0.4 (세단 17.0) — 거의 같음, 조금 짧음 |
| 전폭 (거울 빼고) | 1,872 mm | 6.69 | **7.7** (×1.15) | +0.1 (세단 7.6) |
| 전고 (높이) | 1,685 mm | 6.0 | **6.6** (세단처럼 머리 공간 +0.6) | **+0.8** (세단 5.8) — 가장 눈에 띄는 차이 |
| 휠베이스 | 2,719 mm | 9.7 | **9.7** | −0.3 (세단 10.0) |
| 지상고 | 약 196 mm (178~208) | 0.70 | **0.7** | +0.2 (세단 0.5) |
| 타이어 지름 / 폭 | 235/65R17 = 약 737 mm / 235 mm | 2.63 / 0.84 | **2.6 / 1.0** (폭 ×1.15) | +0.2 / +0.1 (세단 2.4 / 0.9) |
| 휠(림) 지름 | 17인치 (기본 트림) | 1.55 | **1.55** (윗 트림 18~19인치 = 1.6~1.7) | 같음 |
| 공차 중량 | 약 1,530~1,780 kg | — | (게임 무게 감각만) | 세단보다 무거움 |

- 정리: **길이·휠베이스는 세단과 거의 같고, 키가 약 0.8 stud 크고, 바닥이 0.2 높고, 바퀴가 조금 큰 차.** 그래서 앞뒤 오버행(길이 − 휠베이스) 합 = 6.9로 세단(7.0)과 거의 같아요.
- 엔진룸·부품 자리: 가로배치 4기통 FF라 세단 car_spec의 엔진룸 배치를 그대로 쓸 수 있어요(RAV4는 Camry와 **같은 TNGA-K 플랫폼** [2][3]).

## 3. 세단과 다른 '속 구성' (부품 목록에 영향)
1. **사륜(AWD) 뭉치 — 가솔린 차** (FF가 기본, 고르면 추가):
   - 앞 트랜스액슬 옆에서 힘을 빼서 → **가운데 긴 축(프로펠러 샤프트)** → **뒤 차동기어 + 전자 클러치(커플링)** → 뒤 구동축 2개 → 뒷바퀴. 평소엔 앞바퀴 위주, 미끄러질 때 뒤로 보냄.
   - RAV4(가솔린 윗 트림): 'Dynamic Torque Vectoring AWD + Rear Driveline Disconnect' — 뒤로 최대 50 %, 뒤 좌우 바퀴에 따로 나눔. **앞·뒤 바퀴 축에 래칫식 도그 클러치**가 있어 AWD가 필요 없으면 축 회전을 멈춤(연비) [3].
   - CR-V: 'Real-Time AWD with Intelligent Control System' — 평소 앞바퀴굴림, **전자 제어 다판 클러치**로 뒤 차축에 힘을 보냄, 최대 50 % [5][6][12]. 뒤 차동기어 오일은 정비 알림(Maintenance Minder) **6번 항목 '뒤 차동기어 오일 교환'** [13].
   - Equinox 3세대(2018~2024): GKN 사륜, 운전자가 버튼으로 뒤 축을 끊을 수 있음 [7]. 4세대는 AWD = 8단 자동, FWD = CVT로 변속기도 달라요 [7].
   - Tucson: 'HTRAC' — 전자 제어 클러치로 앞뒤 힘 나눔(자세한 자리: 확인 못 함) (검색 요약) [26].
   - → 게임 부품 후보: **Driveshaft(가운데 축)**, **RearDifferential(뒤 차동기어 + 커플링)**, 뒤 구동축 2개. 세단에는 없는 것.
2. **사륜 — 하이브리드 차(전기 뒤 모터)**: RAV4 하이브리드 AWD(AWD-i)는 **뒤 차축에 전기모터(40 kW)** 를 따로 달고 가운데 축·뒤 차동기어 없이 굴러요 [2][25]. 하이브리드 RAV4 배터리 = 1.6 kWh 니켈수소 [2], Tucson 하이브리드 = 1.49 kWh 리튬이온 [9]. → 'AWD인데 가운데 축이 없는 차'도 있다는 점 주의.
3. **뒷문(liftgate) — 트렁크 대신**: 위로 열리는 큰 문 1장 + 양옆 **가스 스트럿(또는 전동 스트럿)**. 전동 리프트게이트는 **스트럿 모양 전동 구동기(powered gate strut)** 가 문을 밀고 당겨요(스텔란티스 정비 회보 용어 'PLGM drive unit = powered gate strut') [18]. CR-V는 'Power Tailgate with Programmable Height' 옵션 [6]. → 게임 부품 후보: `Liftgate` + 스트럿 2개(세단 `Trunk` 대신).
4. **서스펜션은 세단과 같은 종류**: 앞 맥퍼슨 스트럿, 뒤 멀티링크 [4][6][8][10]. RAV4 = Camry와 같은 TNGA-K + 멀티링크 뒤 [3]. → car_spec `Strut` 그대로 쓰고, 스프링이 길고 바퀴가 높을 뿐.
5. **스페어 타이어**: RAV4 = 작은 임시 스페어(강철 휠) [4], Equinox = T125/70R17 임시 스페어 [8], Tucson = 임시 스페어 [10], CR-V = 임시 스페어 T155/90D17 또는 펑크 수리 키트(트림별 구분은 확인 못 함) [6]. **놓인 자리(짐칸 바닥 아래 등)는 이번에 출처로 확인 못 함.**
6. **지붕 레일(roof rails)**: CR-V 'Gloss Black Roof Rails' 옵션 [6]. RAV4 이전 세대는 '지붕 레일 포함 높이'를 따로 적음 → 레일이 높이에 들어감 [3].
7. **12 V 배터리 고정쇠**: 세단과 같은 부품이지만, RAV4 2013~2018(4세대)은 고정쇠가 덜 조이면 배터리가 움직여 (+)단자가 고정쇠에 닿아 합선될 수 있어 리콜 → 고정쇠·받침·(+)단자 덮개 교체 [20]. → 게임 `Battery` 교체 때 '고정쇠 꽉' 단계의 실제 근거.

## 4. 그 차종만의 흔한 고장 (증상 → 원인 → 진단 → 수리)
| 증상 (손님 말 영어 예) | 원인 | 진단 | 수리 |
|---|---|---|---|
| "My oil level keeps going UP and it smells like gas." (CR-V 2017~2018, 1.5 L 터보) | 추운 날·짧은 운행에서 덜 탄 연료가 피스톤 링을 지나 엔진오일에 섞임 = **오일 희석(oil dilution)**. 힘 빠짐·실화·시동 꺼짐도 보고됨 [14][15] | 딥스틱 오일이 '가득' 위로 올라감 + 오일에서 기름 냄새 [14] (검색 요약 [15]) | 엔진·변속기 컴퓨터 소프트웨어 업데이트 + 오일 교환, 일부는 에어컨 조절기 교체. 혼다가 캠축·로커암·점화플러그 보증을 6년 무제한 km로 연장 [14] |
| "The tank clicks off early — the gauge never reads full." (RAV4 하이브리드 2019~2021) | 연료탱크 모양·연료 게이지 센서(sender) 자리 탓에 다 안 차고 게이지가 낮게 나옴 (검색 요약 [17]) | 주유기가 일찍 '딸깍', 게이지·주행 가능 거리가 기대보다 적음 [16] | 토요타 고객 지원 프로그램(2021년형 = 20TE06): 확인되면 **연료탱크 새것으로 교체** [16] (8년/10만 마일 — 검색 요약 [17]) |
| "The power liftgate opens an inch, beeps, and closes again." / "It grinds." | 전동 리프트게이트 **스트럿(구동기) 속 기계 고장**, 또는 조절 모듈이 위치 기억을 잃음 (검색 요약 [19]) | 갈리는·긁히는·두드리는 소리, 걸림·멈춤·안 열림/안 닫힘, 겉 손상, 관련 고장 코드가 있을 때만 스트럿 고장으로 봄. 소리만 크면 정상 차와 비교 [18] | 위 조건이면 **전동 스트럿 교체**. 조건이 아니면 교체하지 말 것 [18] |
| "It groans/moans in tight, slow turns." (CR-V 2002~2007 4WD — 옛 세대) | 뒤 차동기어 오일이 오염 → 클러치판이 떨림 (검색 요약 [21]) | 천천히 크게 돌 때 뒤에서 '웅—' 소리 (검색 요약 [21]) | **뒤 차동기어 오일 교환(혼다 전용 오일)** + 클러치 길들이기 주행(8자 회전 여러 번) (검색 요약 [21]). 요즘 CR-V도 정비 알림 6번 = 뒤 차동기어 오일 [13] |
| "My battery slid around under the hood." (RAV4 2013~2018) | 윗면이 작은 교체 배터리 + 덜 조인 고정쇠 → 급회전 때 배터리가 움직여 (+)단자가 고정쇠에 닿음 → 합선·화재 위험 [20] | 배터리가 흔들리는지, 고정쇠가 맞는지 확인 [20] | 리콜: 고정쇠·배터리 받침·(+)단자 덮개 새것으로 [20] |

- 게임 메모: 위 1·2는 **연료·오일 계통**, 3은 **리프트게이트(SUV만)**, 4는 **AWD 뒤 차동(AWD만)**, 5는 **배터리**와 연결. 'SUV 손님만의 고장' 후보 = 3(리프트게이트 스트럿)과 4(뒤 차동 오일).

## 5. 겉모양 공통점 — 섞을 특징 후보 (2대 이상에 공통인 것만) / 피할 것
| 섞을 특징 | 어느 차들에 공통 |
|---|---|
| 세단보다 **높은 지붕 + 높은 바닥**, 뒤까지 거의 수평으로 이어지는 지붕선, 뒤는 거의 세운 **리프트게이트**(트렁크 턱 없음) | 4대 모두 (높이 1,666~1,699, 지상고 178~208 mm) [3][6][7][10] |
| **바퀴 둘레·아랫단의 검은 플라스틱 덮개(cladding)** — "검은 아래 차체"로 키가 커 보이게 | RAV4 ('black lower body', Trail 트림 큰 검은 오버펜더) [22], Equinox ('각진 바퀴 구멍과 펜더 플레어' — 검색 요약) [24], Tucson ('각진 바퀴 아치') [23] |
| **각진(반원 아닌) 바퀴 아치** | RAV4 [22], Equinox (검색 요약) [24], Tucson [23] |
| **지붕 레일**(세로 막대 2줄) | CR-V [6], RAV4(레일 포함 높이 표기) [3], Tucson (검색 요약) [23] |
| 짧은 앞뒤 오버행(바퀴가 차 모서리 가까이) | 4대 모두 — 길이 − 휠베이스 = 1,886~1,994 mm, 평균 6.9 stud (1·2장 계산), Tucson은 제조사도 '짧은 오버행' [23] |
| (참고, 공통 아님) 가로로 길고 얇은 헤드램프 | RAV4만 출처 확인 ('long, narrow headlamps') [22] — 2대 이상 확인 전엔 섞지 않음 |

| 피할 것 (한 차만의 얼굴) | 어느 차 |
|---|---|
| 팔각형 두 개를 겹친 앞·뒤 모양('Cross Octagon'), 두 단 사다리꼴 그릴 | Toyota RAV4 [22] |
| 그릴 속에 숨었다가 켜질 때만 보이는 보석 무늬 주간등('Parametric Hidden Lights') | Hyundai Tucson [23] |
| 각 브랜드 그릴 무늬·로고(나비넥타이 등)·이름 글자 | Chevrolet Equinox, Honda CR-V 등 전부 |
| Equinox ACTIV의 세로 줄 그릴·흰 지붕 투톤 조합 그대로 | Chevrolet Equinox (검색 요약) [24] |

## 6. 출처
1. Motor1 — "The 20 Best-Selling Cars of 2024" (2025-01-16 갱신, 2024년 전체) — https://www.motor1.com/features/716773/best-selling-cars-2024/
2. Wikipedia — Toyota RAV4 (XA50 정보상자·본문, raw) — https://en.wikipedia.org/wiki/Toyota_RAV4
3. Toyota Global Newsroom — "All-New 2019 Toyota RAV4 Serves Up a Breakthrough Debut at New York International Auto Show" — https://global.toyota/en/newsroom/toyota/21906523.html
4. Cars.com — 2025 Toyota RAV4 LE FWD specs — https://www.cars.com/research/toyota-rav4-2025/specs/462243/
5. Wikipedia — Honda CR-V (sixth generation) — https://en.wikipedia.org/wiki/Honda_CR-V_(sixth_generation)
6. Honda Information Center — 2025 CR-V Specifications — https://www.hondainfocenter.com/2025/cr-v/feature-guide/specifications/
7. Wikipedia — Chevrolet Equinox (3·4세대 정보상자) — https://en.wikipedia.org/wiki/Chevrolet_Equinox
8. Cars.com — 2025 Chevrolet Equinox FWD LT specs — https://www.cars.com/research/chevrolet-equinox-2025/specs/455487/
9. Wikipedia — Hyundai Tucson (NX4 정보상자) — https://en.wikipedia.org/wiki/Hyundai_Tucson
10. Cars.com — 2025 Hyundai Tucson SE FWD specs — https://www.cars.com/research/hyundai-tucson-2025/specs/455989/
11. Wikipedia — Ford Escape (4세대, 단종 발표) — https://en.wikipedia.org/wiki/Ford_Escape
12. AWDwiki — Honda (CR-V 2012~: 전자 제어 다판 클러치) — https://www.awdwiki.com/en/honda
13. Patty Peck Honda — "Honda CR-V Maintenance Due Soon Wrench Light" (정비 알림 6 = 뒤 차동기어 오일) — https://www.pattypeckhonda.com/blog/honda-cr-v-maintenance-due-soon-wrench-light-recommended-service/
14. Consumer Reports — "Honda Extends Warranty on Troubled Turbo Engines" — https://www.consumerreports.org/car-recalls-defects/honda-extends-warranty-on-troubled-turbo-engines
15. WardsAuto — "Honda Extends Warranty to Address 1.5L Gas Oil Dilution Problem" (검색 요약) — https://www.wardsauto.com/internal-combustion-engines/honda-extends-warranty-to-address-1-5l-gas-oil-dilution-problem
16. Toyota Motor North America — Customer Support Program 20TE06 (2021 RAV4 HV 주유 성능), NHTSA 게시 — https://static.nhtsa.gov/odi/tsbs/2021/MC-10190477-9999.pdf
17. Green Car Reports — "Toyota RAV4 Hybrid fuel tank issue fix is coming soon" (검색 요약, 본문 403) — https://www.greencarreports.com/news/1128456_toyota-rav4-hybrid-fuel-tank-issue-fix-is-coming-soon
18. Stellantis STAR Online S2523000094 — "Power Liftgate Noise During Gate Operation" (2025-12), NHTSA 게시 — https://static.nhtsa.gov/odi/tsbs/2025/MC-11026641-0001.pdf
19. Go-Parts — CR-V 2017~2022 trunk lid / liftgate motor guide (검색 요약, 부품 판매처 글) — https://www.go-parts.com/garage/trunk-lid-pull-down-motor-honda-cr-v-2017-2022
20. Transport Topics — "Toyota Recalls Nearly 1.9 Million RAV4s" (2023-11) — https://www.ttnews.com/articles/toyota-recalls-rav4s-fire
21. Tire Review — "Honda Tech Tip: Rear Differential Moan or Groan" (검색 요약, 본문 403) — https://www.tirereview.com/?p=87235
22. Toyota Canada — "RAV4 Design: Adding Excitement to the Segment" (2018) — https://media.toyota.ca/en/releases/2018/rav4-design-adding-excitement-to-the-segment.html
23. Hyundai Australia — "All-new Hyundai Tucson adds revolutionary redesign" (지붕 레일·클래딩은 Spinny 블로그 검색 요약) — https://www.hyundai.com/au/en/news/vehicles/all-new-hyundai-tucson-adds-revolutionary-redesign
24. Chevrolet Newsroom — 2025 Chevrolet Equinox (2024-01, 검색 요약 — 본문 403) — https://news.chevrolet.com/newsroom.detail.html/Pages/news/us/en/2024/jan/0123-equinox.html
25. New Atlas — 2021 Toyota Sienna unveil (뒤 전기모터 AWD = RAV4 하이브리드에서 처음, 축·차동 없음) — https://newatlas.com/automotive/2021-toyota-sienna-unveil/
26. Hyundai — Tucson performance ('AWD coupling system', 검색 요약) — https://www.hyundai.com/et/en/find-a-car/tucson/performance
