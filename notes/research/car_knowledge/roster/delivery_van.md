# 배달·화물 밴 (Cargo van / delivery van, full-size) — 베타 손님 차 조사 (wr-carbook)

> 목적: wr-design의 `docs/design/car_roster.md` 근거. 미국 거리에 흔한 실제 차 3~5대 → 크기·구동·엔진 배치·서스펜션·흔한 고장·겉모양 공통점.
> 환산 1 stud = 0.28 m. car_spec 규칙: 폭(X) ×1.15, 높이는 앉은 R15 머리 공간 확인. 기준 세단 = 길이 17.0 · 폭 7.6 · 높이 5.8 · 휠베이스 10.0 stud.
> 실제 브랜드 얼굴(그릴·로고·시그니처 램프)은 섞지 않아요 — '피할 것' 칸에 적기.
> 출처는 각 줄 끝 [n], 맨 아래 목록. 확인 못 하면 "(확인 못 함)", 검색 결과 요약만 보면 "(검색 요약)".
> 조사일 2026-10-21. 크기는 **택배·배달에 가장 흔한 '긴 휠베이스 + 하이루프(high roof) 화물 밴'** 기준.

## 0. 한 줄 요약
- 미국 풀사이즈 밴 3대는 **구동 방식이 셋 다 달라요**: Ford Transit = 뒷바퀴굴림(AWD 선택), **Ram ProMaster = 앞바퀴굴림 + 가로 엔진(이 급에서 유일)**, Mercedes Sprinter = 뒷바퀴굴림(AWD 선택) [1][5][7][10].
- 크기: 세단보다 **길이 +25%, 높이 ×1.66** — 게임으로 약 **21.3 × 8.4 × 9.7 stud, 휠베이스 13.6**. 하이루프 안은 서서 걸을 수 있는 높이(약 2.0~2.07 m)라 **R15가 짐칸 안에 서요** (§2).
- 판매(2024 미국): Transit 152,738대(Ford 발표, "No. 1-selling van") [14], ProMaster 65,868대 [15]. Sprinter는 Mercedes가 모델별로 안 나눠 발표(밴 전체 49,573대, 검색 요약) [17].

## 1. 대표 실제 차 (미국 판매 상위 — 판매 순위 출처 포함)
판매 순위(2024 미국 풀사이즈 밴): **1위 Ford Transit** — Ford 발표 152,738대(E-Transit 12,610대 포함으로 보임: 업계 표의 내연 Transit 140,128 + 12,610 = 152,738) [14][16] · **2위 Ram ProMaster** 65,868 [15] · Chevrolet Express 약 44,221 · Ford E-Series 약 40,778 (검색 요약) [16] · Sprinter는 공개 수치 없음 [16][17].

| 차 (세대·연식) | 길이 × 폭 × 높이 / 휠베이스 (mm) | 공차 중량 | 구동 | 엔진 배치·종류 | 앞 / 뒤 서스펜션 | 흔한 타이어 |
|---|---|---|---|---|---|---|
| **Ford Transit** 북미 4세대 (2015 MY~) — 148" Long, High Roof 화물 | 5,982 × 2,065 × 2,784 / 3,750 (235.5 × 81.3 × 109.6 in, 148 in) [2]; 위키 하이루프 차체 높이 2,800 [1] | 2,261 kg(4,985 lb, KBB 2024 T-250 High Roof — 휠베이스 130으로 적혀 구성 불분명) [3] | 앞 엔진 **RWD**, AWD 선택 [1] | 3.5 V6(포트+직분사, 2020~), 3.5 EcoBoost V6, (예전 3.7 V6·3.2 Power Stroke 디젤 I5). 10단 자동 10R80(2020~) [1]. 세로 배치로 봄(직접 쓴 출처는 못 엶 — RWD + F-150과 같은 10R80) | 앞: **맥퍼슨 스트럿** / 뒤: **판스프링 + 일체 차축** [1] | 235/65R16C (148" 하이루프 AWD 한 대) (검색 요약) [4] |
| **Ram ProMaster** (2014 MY~, Fiat Ducato 기반) — 2500 High Roof 159" | 5,994 × 2,032 × 2,591 / 4,039 (236 × 80 × 102 in, 159 in) [6] | 2,220 kg (4,895 lb) [6] | **앞바퀴굴림(FWD)** — "segment exclusive" [5][6] | **가로 배치**(Ducato 사양 "Transversal") [7]. 3.6 Pentastar V6(280 hp) [5][6], 초기 3.0 EcoDiesel I4 [5] | 앞: 스트럿(독립) / 뒤: **판스프링 + 일체 차축** [6][7] | LT225/75R16 [6] |
| **Mercedes-Benz Sprinter** 3세대 VS30 (2019 MY~ 미국) — 2500 High Roof 144" | 5,931 × (거울 빼고 확인 못 함; 거울 포함 2,344) × 2,731 / 3,658 (233.5 × 92.3 × 107.5 in, 144 in) [9][8] | 2,370 kg (5,225 lb) [10] | RWD, AWD 선택(트윈터보 디젤) [10]; 유럽엔 FWD도 있음 [8] | 2.0 OM654 터보 디젤 I4(이 구성 170 hp) [10]; 3.0 V6 디젤은 2022까지, 가솔린 2.0 M274는 미국 판매 중단 [8][17]. 9단 자동 [8] | 앞: **스트럿 + 가로놓인 판스프링(transverse leaf)** — 2007~2016 Sprinter 기준 자료 [12]; 3세대는 (확인 못 함) / 뒤: 판스프링 + 일체 차축 [12] | LT245/75R16 (검색 요약) [11] |
| (작은 밴) **Ford Transit Connect** 2세대 (2014~2023 MY 북미) — LWB | 4,820 × 1,830 × 1,830 / 3,060 [13] | (확인 못 함) | 앞 엔진 FWD [13] | 2.0 I4 / 1.6 EcoBoost 등 [13] | (확인 못 함) | (확인 못 함) |

- **Transit Connect는 북미에서 2023 MY 뒤 판매 끝** [13] → 신차는 없고 길에 남은 중고만. 크기가 세단과 거의 같아(17.2 × 7.5 × 6.5 stud, 휠베이스 10.9) 따로 만들 필요는 적어요.
- 지붕 높이 종류: Transit 낮은/중간/높은 지붕 83.6 / 100.8 / 110.1 in [1], ProMaster 90 / 101 in(2014 발표) [5], Sprinter 표준 / 하이루프 96.3 / 107.5 in [9].
- 하이루프 실내 높이: Transit 81.5 in(2.07 m) [2], Sprinter 79.1 in(2.01 m) [8].

## 2. 평균 → stud (게임 권장)
3대(Transit 148 High · ProMaster 159 High · Sprinter 144 High) 평균. 폭은 Sprinter가 거울 뺀 값이 없어 Transit·ProMaster 2대 평균.

| 항목 | 실제 평균 | stud (÷0.28) | 게임 권장(×1.15 폭 등) | 세단 대비 |
|---|---|---|---|---|
| 길이 | 5,969 mm | 21.32 | **21.3** | 17.0 → +4.3 (×1.25) |
| 폭 (거울 빼고) | 2,049 mm | 7.32 | **8.4** (×1.15 = 8.41) | 7.6 → +0.8 |
| 높이 (하이루프) | 2,702 mm | 9.65 | **9.7** | 5.8 → +3.9 (×1.66) |
| 휠베이스 | 3,816 mm | 13.63 | **13.6** (ProMaster 159"만 14.4) | 10.0 → +3.6 |
| 실내 높이 | 2.01~2.07 m [2][8] | 7.2~7.4 | **7.3** → 선 R15(5.0~5.3) 머리 위 2 stud 여유 | 세단 실내 4.6 |
| 타이어 지름 | 235/65R16 ≈ 712 · LT225/75R16 ≈ 744 · LT245/75R16 ≈ 774 mm (계산) [4][6][11] | 2.54~2.76 | **2.65** | 2.4 → +0.25 |
| 타이어 폭 | 225~245 mm | 0.8~0.88 | **1.0** (×1.15) | 0.9 → +0.1 |
| 휠(림) 지름 | 16 in = 406 mm | 1.45 | **1.45** (철제 휠이 흔함 — 확인 못 함) | 1.55 → **−0.1 (세단보다 작음!)** |
| 공차 중량 | 약 2.2~2.4 t [3][6][10] | — | — | (세단 무게는 car_spec에 없음) |

- **베이 맞나? (car_spec §7)**
  - 최소 베이 20 × 30, 천장 16: 길이 21.3 + 6.5 = 27.8 < 30 → **들어감**. 폭: 미닫이문(sliding door)은 옆으로 안 열려서 폭 8.4 + 운전석 문 3.5 + 걸을 틈 → **넉넉**. 하지만 **천장: 리프트 `Under` 6 + 9.7 = 15.7 → 16에서 0.3 남음 = 사실상 안 됨**(지붕 위 장식·카메라 여유 없음). **최소 셔터 높이 9 < 9.7 → 못 들어옴.**
  - 지은 베이 28 × 40, 천장 20, 셔터 16 × 13.8: **들어감**(리프트 Under 15.7 < 20, 셔터 13.8 > 9.7).
  - 제안(wr-design 결정): 밴은 Lv1 최소 베이 금지 or 리프트 `Under`를 4 정도로 낮춘 '밴 전용' 높이. 뒷문 두 짝(barn doors)이 뒤로 활짝 열리니 뒤쪽 여유(ProMaster 260°까지 [5]) 필요 — 베이 길이 30 안에서 차를 앞쪽으로.

## 3. 세단과 다른 '속 구성' (부품 목록에 영향)
| 부품/구성 | 세단(Camry) | 화물 밴 | 근거 |
|---|---|---|---|
| 뼈대 | 유니바디 | ProMaster = **유니바디**("unibody가 앞바퀴굴림을 가능하게") [5]. Transit·Sprinter 뼈대 방식 (확인 못 함) | [5] |
| 엔진·구동 (Transit·Sprinter) | 가로 엔진 + 트랜스액슬 → 앞바퀴 | 엔진 → 긴 변속기 → **프로펠러 샤프트 + U-조인트** → **뒤 차동기어(일체 차축 안)** → 뒷바퀴. 픽업과 같은 계열 | [1][12] |
| 엔진·구동 (ProMaster) | 같음 | **세단과 같은 가로 배치 FWD** — 뒤 구동축·뒤 디프가 없어 **바닥이 가장 낮음**("lowest load floor") | [5][7] |
| 뒤 스프링 | 코일 | **판스프링 + 일체 차축**(세 차 모두) — 섀클·센터 볼트·U-볼트 구성은 pickup.md §3과 같음 | [1][6][12][23] |
| 앞 스프링 | 맥퍼슨 스트럿(코일) | Transit·ProMaster = 맥퍼슨 스트럿 [1][6]. Sprinter(2007~2016 자료) = 스트럿 + **좌우를 가로지르는 판스프링 1장**, 스프링이 스트럿에 안 붙어 있어 스트럿만 따로 교체 가능 [12] | |
| 브레이크 | 4바퀴 디스크 | ProMaster 앞 12 in·뒤 11 in **4바퀴 디스크** [6] (Ducato도 앞 벤트·뒤 일반 디스크 [7]). Transit·Sprinter (확인 못 함) | [6][7] |
| 옆문 | 앞뒤 여닫이 4도어 | **미닫이 옆문(sliding door)**: ProMaster 조수석 쪽 기본 + 운전석 쪽 선택 [5], Transit 2020~ 전동 미닫이·양쪽 미닫이 선택 [1]. 위·아래(가운데) **레일 + 롤러 + 래치** (부품 이름 출처 못 엶 — 확인 필요) | [1][5] |
| 뒷문 | 트렁크 뚜껑 | **양쪽으로 여는 뒷문 두 짝(barn doors)**: ProMaster 260°까지 [5]. Sprinter 하이루프 뒷문 구멍 73 × 61 in, 옆문 구멍 72 × 50 in [9] | [5][9] |
| 짐칸 | 트렁크 | 칸막이 뒤 텅 빈 상자: Transit 148 하이루프 바닥 길이 143.7 in [2], Sprinter 짐칸 바닥 높이 27.9 in [26] | [2][26] |
| 배기 후처리 (디젤 Sprinter) | 촉매·산소센서 | + **AdBlue(DEF, 요소수) 탱크·히터·펌프·분사 밸브·SCR 촉매·NOx 센서 2개** | [21] |
| 스페어·견인 | 트렁크 바닥 | (밴 스페어 위치·히치 확인 못 함) | |

**게임 부품 목록 영향(제안 — wr-design 결정)**: 세단 부품 + `SlidingDoor`(+`SlidingDoorTrack`·`Roller`), `RearDoor_L/R`, `LeafSpring_L/R`, 뒷바퀴굴림형은 `DriveShaft`·`RearDiff`. Sprinter형 디젤은 `DEFTank`(파란 캡)·`NOxSensor`. ProMaster형은 세단처럼 트랜스액슬 그대로(구동축 없음) → **같은 '밴'이라도 FWD형·RWD형 2가지 속 구성**.

## 4. 그 차종만의 흔한 고장 (증상 → 원인 → 진단 → 수리)
| 증상 (손님 말 영어 예) | 원인 | 진단 | 수리 |
|---|---|---|---|
| "The sliding door is so hard to open and I have to slam it shut." (Transit) | 수동 미닫이문 정렬이 틀어짐 — Ford SSM 49665 (2015~2021 Transit, 2021-03-15) | 문 여닫기 확인, 문 틈·정렬 보기 | 정비 매뉴얼 절차로 **미닫이문 조정** [18] |
| "Dash says 'No start in 10 starts' — AdBlue!" (Sprinter 디젤) | DEF(요소수) 부족, **탱크 히터 소손**(겨울에 얼어붙음), 분사 밸브·관 막힘(짧은 운행에 요소 결정), **NOx 센서 고장** → '남은 시동 횟수' 카운트다운 | DEF 양 → 코드 읽기(P2200 = NOx 센서 회로, 검색 요약) → 온도·NOx 센서 값 → 펌프·분사량 시험 → 누유 | 원인 부품 교체(히터·펌프·센서·분사 밸브) 뒤 카운트다운 초기화. **DEF만 채우면 안 꺼짐** [21] |
| "Something's howling/grinding from the rear axle." (2023~2024 Transit) | **뒤 차축 오일 부족** → 테일 베어링 손상·고착 → 바퀴 잠김·구동축 분리 가능 — NHTSA 리콜 24V102 (Ford 24S05, 2024-02-09) | 딜러가 뒤 차축 점검 | 베어링 또는 차축 통째 교체(무상) [19]. 그때 잘못된 볼트를 쓴 차는 후속 리콜 24V805 (검색 요약) [20] |
| "Brakes shake when I stop, and I keep replacing front pads." (ProMaster) | FWD라 앞 브레이크가 제동의 약 70~80%를 맡고, 짐을 많이 실을수록 앞 로터 휨·패드 빨리 닳음 (검색 요약) | 페달 떨림, 로터 두께·흔들림 측정 | 앞 패드 + 로터 교체 [22] |
| "The back end sags when it's loaded." (판스프링 밴 전부) | 과적·피로로 **판스프링 처짐 / 판 부러짐**, U-볼트 풀림 | 빈 차 높이 비교, 판 금·부러짐 확인 | 좌우 한 쌍 교체 + U-볼트 재조임 [24][23] |

## 5. 겉모양 공통점 — 섞을 특징 후보 (2대 이상에 공통인 것만) / 피할 것
| 섞을 특징 | 어느 차들에 공통 |
|---|---|
| 짧은 보닛 + 바로 위로 솟은 **높은 상자 지붕(하이루프)** | Transit·ProMaster·Sprinter [1][5][9] |
| 조수석 쪽 **미닫이 옆문**(옆면에 가로 레일 홈) | Transit·ProMaster (Sprinter 옆문 구멍 [9]) [1][5] |
| 뒤에 **양쪽 여는 문 두 짝** | ProMaster·Sprinter [5][9] |
| 16인치 작은 휠 + 굵은 LT 타이어(차체에 비해 바퀴가 작아 보임) | 세 차 모두 [4][6][11] |
| 앞바퀴와 뒷바퀴 사이가 아주 긺(휠베이스 3.7~4.0 m) | 세 차 모두 [2][6][9] |
| **피할 것 (한 차만의 얼굴)** | **어느 차** |
| 세 꼭지 별 엠블럼 + 그 그릴 모양 | Mercedes-Benz Sprinter |
| 파란 타원 엠블럼과 Transit 앞 얼굴(그릴·램프 모양) — 얼굴 세부 출처 못 엶 | Ford Transit |
| RAM 글자·숫양 머리, Ducato 계열 앞 얼굴 — 얼굴 세부 출처 못 엶 | Ram ProMaster |
| → 앞 얼굴은 **세 차 어느 것도 닮지 않은 오리지널**로(사진 대조는 wr-art가 실사진 조사 때) | |

## 6. 출처
1. Ford Transit (North American 4th gen: 지붕 높이·휠베이스·구동·서스펜션·미닫이문) — Wikipedia — https://en.wikipedia.org/wiki/Ford_Transit
2. Ford Transit Van Dimensions (휠베이스·지붕별 길이·높이·실내 높이·짐칸 길이, 거울 뺀 폭 81.3 in) — The Van Smith — https://thevansmith.com/blogs/beginners-guide-to-the-vanlife/ford-transit-van-dimensions
3. 2024 Ford Transit-250 Cargo Van High Roof specs — Kelley Blue Book — https://www.kbb.com/ford/transit-250-cargo-van/2024/high-roof
4. (검색 요약) 2024 Transit 250 High Roof AWD 148" 235/65R16C — Work Truck Solutions 딜러 목록 — https://fordcontentdemo.worktrucksolutions.com/work-van/new-2024-ford-transit-250-high-roof-awd-empty-cargo-van-16369563
5. 2014 Ram ProMaster press release (2013-02-06: FWD·유니바디·지붕 높이·미닫이문·뒷문 260°) — Stellantis media — https://www.media.stellantisnorthamerica.com/print.do?id=13844
6. 2019 RAM ProMaster 2500 High Roof 159" WB specs — Cars.com — https://www.cars.com/research/ram-promaster_2500-2019/specs/401650/
7. Fiat Ducato Chassi 2.3 2018 (엔진 "Transversal", FWD, McPherson, 뒤 rigid) — Ficha Completa — https://www.fichacompleta.com.br/en/carros/fiat/ducato-chassi-2-3-2018
8. Mercedes-Benz Sprinter (3rd gen: 연식·구동·엔진·휠베이스·길이·실내 높이) — Wikipedia — https://en.wikipedia.org/wiki/Mercedes-Benz_Sprinter
9. 2024 Mercedes-Benz Sprinter Dimensions (외부 치수·문 구멍) — Mercedes-Benz of Warwick — https://www.mercedesbenzofwarwick.com/2024-mercedes-benz-sprinter-dimensions/
10. 2024 Sprinter 2500 Cargo High Roof w/144" WB — Kelley Blue Book — https://www.kbb.com/mercedes-benz/sprinter-2500-cargo/2024/high-roof-w-144--wb
11. (검색 요약) 2024 Sprinter 2500 Cargo specs LT245/75R16 — Kelley Blue Book — https://www.kbb.com/mercedes-benz/sprinter-2500-cargo/2024/specs
12. Sprinter 3500 Class C Upgrade Part 4 — Front Struts (가로 판스프링·뒤 판스프링) — SuperSteer — https://supersteerparts.com/sprinterupgradepart4
13. Ford Transit Connect (북미 2023 MY 뒤 종료, 2세대 LWB 치수) — Wikipedia — https://en.wikipedia.org/wiki/Ford_Transit_Connect
14. Ford U.S. retail sales grow at double the industry pace in 2024 (Transit 152,738, E-Transit 12,610) — Ford From The Road — https://www.fromtheroad.ford.com/us/en/articles/2025/ford-u-s--retail-sales-grow-at-double-the-industry-pace-in-2024-
15. Ram ProMaster sales figures USA — GoodCarBadCar — https://www.goodcarbadcar.net/ram-promaster-sales-figures-usa-canada/
16. (검색 요약) Ford Transit Q4 2024 sales & full-size van segment table — Ford Authority — https://fordauthority.com/2025/03/ford-transit-numbers-figures-results-fourth-quarter-2024-q4/
17. (검색 요약) Mercedes-Benz USA Q4/2024 sales (Vans group 49,573; Sprinter gas discontinued US) — Business Wire — https://www.businesswire.com/news/home/20250107541048/en/Mercedes-Benz-USA-Reports-9-Year-Over-Year-Growth-for-Passenger-Car-Sales
18. Ford SSM 49665, Transit manual sliding door adjustment (2021-03-15) — RecallCheck(NHTSA 게시 TSB 미러) — https://recallcheck.net/tsb/146937
19. NHTSA Campaign 24V102000 (Ford 24S05) 2023~2024 Transit rear axle lubricant — RecallCheck — https://recallcheck.net/recall/24V102000 (대수: 이 페이지 113,320 / 다른 검색 요약 77,584 — 공식 NHTSA로 재확인)
20. (검색 요약) NHTSA Campaign 24V805000 (Ford 24S67) axle shaft bolts — RecallCheck — https://recallcheck.net/recall/24V805000
21. Mercedes AdBlue Problems (구성·고장·카운트다운·진단·수리) — Mercedes Medic — https://www.mercedesmedic.com/mercedes-adblue-problems/
22. (검색 요약) RAM ProMaster known issues (front rotor/pad wear) — au7o — https://au7o.io/known-issues/ram-promaster?year=2020 · Firestone ProMaster 2500 brakes — https://vehicle.firestonecompleteautocare.com/ram/promaster-2500/2018/repair/brakes/
23. Leaf spring — Wikipedia — https://en.wikipedia.org/wiki/Leaf_spring
24. When do leaf springs need to be replaced? — TestingAutos — https://www.testingautos.com/car_care/leaf-springs.html
25. 우리 규격: `docs/specs/car_spec.md` §0(기준 세단)·§3-3(리프트)·§7(베이)
26. Mercedes-Benz Sprinter Dimensions & Cargo Space (지붕 96.3/107.5 in, 바닥 높이 27.9 in) — Mercedes-Benz of Los Angeles — https://www.mbzla.com/mercedes-benz-sprinter-dimensions/
