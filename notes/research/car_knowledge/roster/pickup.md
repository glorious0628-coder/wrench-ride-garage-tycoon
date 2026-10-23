# 픽업트럭 (Pickup truck, full-size + mid-size) — 베타 손님 차 조사 (wr-carbook)

> 목적: wr-design의 `docs/design/car_roster.md` 근거. 미국 거리에 흔한 실제 차 3~5대 → 크기·구동·엔진 배치·서스펜션·흔한 고장·겉모양 공통점.
> 환산 1 stud = 0.28 m. car_spec 규칙: 폭(X) ×1.15, 높이는 앉은 R15 머리 공간 확인. 기준 세단 = 길이 17.0 · 폭 7.6 · 높이 5.8 · 휠베이스 10.0 stud.
> 실제 브랜드 얼굴(그릴·로고·시그니처 램프)은 섞지 않아요 — '피할 것' 칸에 적기.
> 출처는 각 줄 끝 [n], 맨 아래 목록. 확인 못 하면 "(확인 못 함)", 검색 결과 요약만 보면 "(검색 요약)".
> 조사일 2026-10-21. 크기는 **가장 흔한 형태 = 4도어 크루캡(crew cab) + 짧은 짐칸(short bed, 5.5~5.8 ft)** 기준.

## 0. 한 줄 요약
- 픽업은 세단과 **뼈대부터 달라요**: 따로 된 **사다리 프레임(ladder frame)** 위에 차체(캡)와 짐칸(bed)을 얹고, 엔진은 **세로로(longitudinal)** 놓여 **뒷바퀴**를 돌려요(4WD는 트랜스퍼 케이스로 앞바퀴도) [4][20][21].
- 크기: 세단보다 **길이 +24%, 휠베이스 +32%, 높이 +20%** — 게임으로 약 **21 × 8.5 × 7.0 stud, 휠베이스 13.2** (§2).
- 미국 판매 1·2·5위가 픽업(F-Series 732,139대, Silverado 542,517대, Ram 373,120대, 2024년) [5].

## 1. 대표 실제 차 (미국 판매 상위 — 판매 순위 출처 포함)
판매(2024 미국, CarPro): **1위 Ford F-Series 732,139 · 2위 Chevrolet Silverado 542,517 · 5위 Ram Pickups 373,120 · 16위 Toyota Tacoma 192,813** (CarPro는 원 데이터 제공처를 밝히지 않음) [5].

| 차 (세대·연식) | 길이 × 폭 × 높이 / 휠베이스 (mm) | 공차 중량 | 구동 | 엔진 배치·종류 | 앞 / 뒤 서스펜션 | 흔한 타이어 |
|---|---|---|---|---|---|---|
| **Ford F-150** 14세대 (2021~) — SuperCrew 5.5 ft 짐칸 | 5,885 × 2,029 × 1,920~1,971 / 3,693 [1] | 1,824 kg~ (가장 가벼운 형태) [1] | 뒷바퀴굴림(RWD) 또는 4WD [1]; XLT·Lariat 등 "2단 자동 4WD" [11] | 세로 배치. 2.7/3.5 EcoBoost 트윈터보 V6, 5.0 V8(Coyote), 3.5 PowerBoost 하이브리드 V6 등. 10단 자동 10R80 [1] | 앞: 코일-온-쇼크(coil-over) **더블 위시본 독립** / 뒤: **Hotchkiss식 일체 차축 + 판스프링** (2015 공식 사양서) [6]. 현행도 일반 F-150은 판스프링 일체 차축(Raptor만 5링크 코일) [8] | XLT 4WD 265/70R17·275/65R18·275/60R20, XL 2WD 245/70R17 [10] |
| **Chevrolet Silverado 1500** 4세대 (2019~) — Crew Cab 5'8" | 5,885 × 2,062 × 1,920~1,930 / 3,744 [2] | 크루캡 2,176~2,272 kg [2] | RWD, 4WD 선택(Trail Boss·ZR2·AT4는 4WD 기본) [2] | 세로 배치. 5.3/6.2 V8(DFM 기통 휴지), 2.7 터보 I4, 3.0 Duramax 디젤 I6. 8·10단 자동 [2] | 앞: 위시본 독립 + 코일 / 뒤: 일체(beam) 차축 + 판스프링 (ZR2 사양) [9] | ZR2 275/70R18 [9]; 2020 LTZ 265/65R18 (검색 요약) [31] |
| **Ram 1500** 5세대 DT (2019~) — Crew Cab 5'7" | 5,916 × 2,085 × 1,968~2,012 / 3,673 [3] (보도자료는 144.5 in = 3,670) [7] | 약 2,307 kg(5,085 lb, 2023 Big Horn 4x4) (검색 요약) [27] | 4x2 / 4x4 [3] | 세로 배치. 3.6 Pentastar V6 eTorque(마일드 하이브리드), 5.7 Hemi V8, 3.0 Hurricane 트윈터보 I6(2025~), 3.0 EcoDiesel V6. 8단 자동 [3] | 앞: 독립(복합소재 위 컨트롤암 + 알루미늄 아래 컨트롤암) / 뒤: **5링크 코일 스프링**(판스프링 아님!) [7]; 4바퀴 에어 서스펜션 선택 [7] | 18 또는 20인치 휠에 32인치 타이어 [7]; Big Horn 275/65R18 (검색 요약) [27] |
| **Toyota Tacoma** 4세대 N400 (2024~) — 중형, Double Cab | 5,410~5,745 × 1,953~2,029 × 1,877~1,895 / 3,350~3,686 (형태별 범위) [4] | 1,880~2,454 kg [4] | 엔진 세로 배치, 4WD는 **2단 트랜스퍼 케이스**, 하이브리드 Limited는 상시 AWD [4] | 2.4 터보 I4(T24A-FTS), i-Force Max 하이브리드. 8단 자동(일부 6단 수동) [4] | 앞: (확인 못 함) / 뒤: Double Cab 대부분 **코일**, XtraCab은 **판스프링** [4] | (확인 못 함) |

- 프레임: F-150 플랫폼 T3 [1], Ram은 프레임의 98%가 고장력강 [3], Tacoma는 TNGA-F **보디-온-프레임** [4]. 위키 '차대': "대부분의 픽업은 따로 된 프레임을 차대로 써요" [21].
- 짐칸 길이: F-150 SuperCrew 5.5 / 6.5 ft [1], Silverado Crew 5'8" / 6'6" [2], Ram Crew 짧은/표준 짐칸(2도어 레귤러캡은 없어짐) [3], Tacoma Double Cab 5 / 6 ft [4].

## 2. 평균 → stud (게임 권장)
풀사이즈 3대(F-150·Silverado·Ram 크루캡 짧은 짐칸) 평균. 높이는 각 범위의 가운데 값 사용.

| 항목 | 실제 평균 | stud (÷0.28) | 게임 권장(×1.15 폭 등) | 세단 대비 |
|---|---|---|---|---|
| 길이 | 5,895 mm | 21.05 | **21.0** | 17.0 → **+4.0 (×1.24)** |
| 폭 (거울 빼고) | 2,059 mm | 7.35 | **8.5** (×1.15 = 8.46) | 7.6 → +0.9 |
| 높이 | 1,954 mm | 6.98 | **7.0** (이미 높아 앉은 R15 머리 여유 충분 — 세단식 +0.6 불필요할 듯, 실측 확인) | 5.8 → +1.2 |
| 휠베이스 | 3,703 mm | 13.23 | **13.2** | 10.0 → **+3.2 (×1.32)** |
| 타이어 지름 | 275/65R18 ≈ 815 mm · 275/70R18 ≈ 842 mm (계산) [9][10] | 2.9~3.0 | **2.9** | 2.4 → +0.5 |
| 타이어 폭 | 275 mm | 0.98 | **1.1** (×1.15) | 0.9 → +0.2 |
| 휠(림) 지름 | 18 in = 457 mm | 1.63 | **1.65** (17~20 in → 1.55~1.8) | 1.55 → +0.1 |
| 공차 중량 | 약 1.8~2.3 t [1][2][27] | — | (게임 무게감·리프트 연출용) | (세단 무게는 car_spec에 없음) |

- 중형 Tacoma: 19.3~20.5 × 8.0~8.3(×1.15) × 6.7~6.8 stud, 휠베이스 12.0~13.2 [4] → '작은 픽업' 변형으로 쓰기 좋아요.
- **베이 맞나? (car_spec §7)**
  - 최소 베이 안쪽 20 × 30, 천장 16: 길이 21.0 + 앞뒤 여유 6.5 = 27.5 < 30 → **들어감**. 폭 8.5 + 양쪽 문 3.5×2 = 15.5 → 걸을 틈 4.5(세단 5.4보다 좁음) → **빠듯하지만 됨**. 천장: 리프트 `Under` 6 + 7.0 = 13.0 < 16 → **됨**. 리프트 위 보닛 열기는 세단 13 → 픽업은 보닛이 더 높아 14~15쯤(추정, 실측 필요) → 16 안쪽이지만 여유 적음.
  - 지은 베이 28 × 40, 천장 20, 셔터 16 × 13.8: **넉넉히 들어감**. 최소 셔터(폭 10 × 높이 9)도 8.5 × 7.0이라 통과.
  - 리프트 팔 `LiftPoint_*`(세단 ±3.0, Z ±3.0): 픽업은 **프레임 레일 밑**을 받쳐요 → 휠베이스 13.2라 Z를 ±4.5쯤으로 넓혀야 해요(제안, wr-design 결정).

## 3. 세단과 다른 '속 구성' (부품 목록에 영향)
| 부품/구성 | 세단(Camry) | 픽업 | 근거 |
|---|---|---|---|
| 뼈대 | 유니바디(차체 = 뼈대) | **사다리 프레임**: 길게 뻗은 레일 2개 + 가로 크로스멤버 여러 개, 그 위에 캡·짐칸을 따로 얹음 | [21][4] |
| 엔진·변속기 | 가로 배치 + 트랜스액슬 | **세로 배치** 엔진 → 뒤쪽으로 긴 변속기(10단 10R80 등) | [1][4] |
| 4WD | 없음 | 변속기 뒤 **트랜스퍼 케이스**(보조 기어박스): 앞·뒤 구동축으로 힘을 나눔. 파트타임은 2WD↔4WD 전환, 중앙 차동 없음. **로우 기어(4LO)**로 느리게 큰 힘. 트럭은 대개 체인식 | [20][11] |
| 앞바퀴 구동 연결 | 등속조인트 구동축(앞) | 4WD면 앞 차동기어 + 앞 구동축. F-150(2013~2018)은 **IWE(진공으로 붙였다 떼는 앞바퀴 허브)** | [13] |
| 뒤 차축 | 그냥 굴러가는 뒤바퀴 | **일체형 뒤 차축(live axle)** 안에 **뒤 차동기어(디프)**, 변속기→디프는 **긴 프로펠러 샤프트(구동축) + U-조인트(십자 이음)** | [6][19] |
| 뒤 스프링 | 코일 + 멀티링크/토션빔 | **판스프링(leaf spring)**: 휜 강판 여러 장, 앞 끝 '눈(eye)'은 프레임 브래킷에, 뒤 끝은 **섀클(shackle)** 로 매달림(늘어날 틈), 가운데 **센터 볼트**, 차축은 **U-볼트**로 스프링에 고정 | [17][8][18] |
| 예외 | — | **Ram 1500 = 뒤 5링크 코일**(판스프링보다 약 40 lb 가볍다고 보도자료), Tacoma Double Cab 대부분 코일, F-150 Raptor 5링크 코일 | [7][4][8] |
| 앞 서스펜션 | 맥퍼슨 스트럿 | **더블 위시본**(위·아래 A암) + 코일-오버 쇼크. Ram은 위 암 복합소재·아래 암 알루미늄 | [6][7] |
| 브레이크 | 4바퀴 디스크(또는 뒤 드럼) | F-150 4바퀴 벤트 디스크(앞 13.8 in·뒤 13.7 in, 2015) [6], Silverado 4바퀴 디스크 [9][26](검색 요약). **Tacoma 3세대(~2023)는 뒤 드럼 → 2024 4세대 4바퀴 디스크** [24] | |
| 짐칸 | 트렁크 | **따로 된 짐칸(bed) + 뒷문(tailgate)**. Ram 알루미늄 테일게이트는 열릴 때 댐핑·들어 올림 보조 [7] | [7] |
| 스페어 타이어 | 트렁크 바닥 | **짐칸 아래에 케이블 윈치로 매달림**: 뒤 범퍼 근처 구멍에 막대를 꽂아 반시계로 돌려 내림, 녹 때문에 잘 안 내려오는 일 흔함 (검색 요약). GM은 '스페어 휠 호이스트' 부품 | [25] |
| 견인 장치 | 없음 | 뒤 범퍼 밑 **리시버 히치**(프레임에 볼트): Class III/IV = 2 in 사각 구멍(5,000 / 10,000 lb) [22]. **트레일러 배선**: 4핀(미등·좌우 깜빡이 겸 브레이크·접지) / 7핀(+12 V·전기 브레이크·후진등) [23] | [22][23] |
| 연료·배기 | 뒷좌석 아래 탱크 | (픽업 탱크 위치 확인 못 함) — 배기는 V형 엔진이면 **매니폴드가 양쪽 2개** | [16] |

**게임 부품 목록 영향(제안 — wr-design 결정)**: 세단 부품에 더해 `FrameRail`(장식), `LeafSpring_L/R`(+섀클·U-볼트), `RearDiff`, `DriveShaft`(+U-조인트), `TransferCase`(4WD형), `Tailgate`, `SpareWinch`, `TowHitch`(+트레일러 소켓). Ram형 변형은 `LeafSpring` 대신 `CoilSpring_Rear`.

## 4. 그 차종만의 흔한 고장 (증상 → 원인 → 진단 → 수리)
| 증상 (손님 말 영어 예) | 원인 | 진단 | 수리 |
|---|---|---|---|
| "It rattles for a few seconds when I start it cold." (F-150 3.5 EcoBoost) | 6시간 넘게 식은 뒤 첫 시동에 엔진 앞 커버 쪽 2~5초 '따다닥' — **닳은 VCT(캠 페이저) 유닛** | 증상 확인(차가운 시동) — Ford TSB 20-2191 (2017~2018 F-150, 2018-07-10 이전 생산) | 흡기·배기 VCT 유닛 4개 교체 + PCM 프로그램 업데이트 [12] |
| "Front wheels grind when I speed up — only in 2WD." (F-150 4x4) | **IWE 진공 허브**에 진공이 새거나 IWE 부품 마모 → 2WD인데 반쯤 물림 | 진공 호스·체크밸브 점검, 각 IWE에 진공 걸어 시험 — Ford TSB 20-2028 (2013~2018 F-150) | TCCM 재프로그램, 체크밸브 교체, 결과 따라 진공관·IWE·휠베어링·클러치링 교체 [13] |
| "Ticking noise and the check engine light, it's shaking." (GM 5.3/6.2 V8) | **기통 휴지(AFM/DFM)용 리프터**가 주저앉거나 롤러가 빠짐 → 그 실린더 밸브가 안 열림 → 실화(P030x) (검색 요약) | 실화 코드 + 틱 소리 → 압축 시험, 밸브 커버 열고 푸시로드·리프터 확인 | 리프터(+가이드) 교체, 심하면 엔진 재조립 [15] |
| "Engine knocks / lost power." (2021~2024 6.2 L87 V8) | **커넥팅로드·크랭크축 제조 결함** — NHTSA 리콜 25V274 (GM N252494000) | 딜러 엔진 검사 | 불합격 → 엔진 수리·교체 / 합격 → 더 진한 오일 + 새 오일 캡 + 필터 [14] |
| "It ticks loud when cold, goes away when warm." (Ram 5.7 Hemi) | **배기 매니폴드 균열 / 볼트 부러짐**(주철 매니폴드와 강철 볼트가 열에 다르게 늘었다 줄었다) | 차가운 시동 때 매니폴드 근처 소리·그을음 — 2019~2021 Ram 1500 5.7 TSB(2022) | 매니폴드 통째(볼트·개스킷·차열판·타이바) 교체, 양쪽 약 4시간 [16] |
| "The back sits low and it squeaks over bumps." (판스프링 트럭 전부) | **판스프링 처짐 / 판 부러짐**, 눈 부싱 마모, 섀클 녹, U-볼트 풀림 | 리프트에 올려 판 금·부러짐 보기, U-볼트 헐거움(차축 옆 반짝이는 자국), 한쪽 기울기 | 보통 **좌우 한 쌍 교체** + 볼트·섀클, 3~5시간 + 얼라인먼트, U-볼트 재조임 [18][17] |
| "Clunk when I shift into Drive." / 속도 따라 떨림 | **U-조인트 마모**(그리스 부족·정렬 불량·녹) | 리프트, 중립에서 구동축을 손으로 돌려 유격 확인; 저속 끽끽 = 마른 조인트 | U-조인트 교체(샤프트는 디프 요크와 위치 표시 후 분리) [19] |

## 5. 겉모양 공통점 — 섞을 특징 후보 (2대 이상에 공통인 것만) / 피할 것
| 섞을 특징 | 어느 차들에 공통 |
|---|---|
| 4도어 크루캡 + 따로 떨어진 짐칸(캡과 짐칸 사이 틈) | F-150·Silverado·Ram·Tacoma [1][2][3][4] |
| 짐칸 뒤 **내려 여는 테일게이트** | 전부 (Ram 알루미늄 테일게이트 [7]) |
| 18~20인치 큰 휠 + 두툼한 타이어(지름 약 0.8 m) | F-150·Silverado·Ram [7][9][10] |
| 높은 보닛·높은 차체(약 1.9~2.0 m) | 풀사이즈 3대 [1][2][3] |
| 뒤 범퍼 밑 **사각 리시버 히치** + 트레일러 소켓 | 견인 패키지 트럭 공통 [22][23] |
| 짐칸 밑에 매달린 스페어 타이어(뒤에서 보임) | F-150·Silverado (검색 요약) [25] |
| 사다리 프레임이 바퀴 사이로 보임(측면 아래) | 전부 [21] |
| **피할 것 (한 차만의 얼굴)** | **어느 차** |
| 헤드램프를 'C' 모양으로 감싸는 **C-클램프 램프** (2015~ 13·14세대) (검색 요약) | Ford F-150 [28] |
| 위아래로 나뉜 **2~3단 헤드램프 + 각진 주간등**(2022 개편 전 '쌓인 램프' 40년 전통) | Chevrolet Silverado [29] |
| 그릴 가운데 큰 **'RAM' 글자 / 십자(crosshair) 그릴** (요청 목록 — 출처 직접 확인 못 함) | Ram 1500 |
| 각 회사 로고(타원·보타이·숫양 머리·T) | 전부 — 절대 X |

## 6. 출처
1. Ford F-Series (fourteenth generation) — Wikipedia — https://en.wikipedia.org/wiki/Ford_F-Series_(fourteenth_generation)
2. Chevrolet Silverado (fourth generation) — Wikipedia — https://en.wikipedia.org/wiki/Chevrolet_Silverado_(fourth_generation)
3. Ram 1500 (DT) — Wikipedia — https://en.wikipedia.org/wiki/Ram_1500_(DT)
4. Toyota Tacoma (fourth generation N400 section) — Wikipedia — https://en.wikipedia.org/wiki/Toyota_Tacoma
5. The 25 Best-Selling Vehicles of 2024 — CarPro (J. Reynolds, 2025-01-13) — https://www.carpro.com/blog/the-25-best-selling-vehicles-of-2024
6. 2015 Ford F-150 Technical Specifications (Ford 공식 PDF: 서스펜션·브레이크·치수) — https://cdn.base.parameter1.com/files/base/acbm/fcp/document/2014/01/2015-ford-f150-tech-specs_11293037.pdf
7. 2019 Ram 1500 press release (Stellantis media, 2018-01-15) — https://media.stellantisnorthamerica.com/print.do?id=18757
8. Why The Current Ford F-150 Is Actually Three Trucks In One — The Autopian — https://www.theautopian.com/why-the-current-ford-f-150-is-actually-three-trucks-in-one-suspension-secrets/
9. 2024 Chevrolet Silverado 1500 ZR2 handling & mechanics — CarExpert NZ — https://www.carexpert.co.nz/chevrolet/silverado-1500/2024/zr2/handling-and-mechanics
10. 2024 Ford F-150 tire sizes — tiresize.com — https://tiresize.com/tires/Ford/F150/2024/
11. Ford F-150 specs (4WD 설명: "Two-speed automatic 4WD") — ford.com — https://www.ford.com/trucks/f150/specs/
12. Ford TSB 20-2191, 3.5L EcoBoost cold start ticking/rattle (2020-06-04, NHTSA 게시) — https://static.nhtsa.gov/odi/tsbs/2020/MC-10176838-0001.pdf
13. Ford TSB 20-2028, 4WD intermittent grinding noise (2020-02-11) — https://www.fordservicecontent.com/Ford_Content/vdirsnet/TSB/EU/~WTSB20-2028/US/EN/~UEmployee/default.aspx
14. GM Safety Recall N252494000 / NHTSA 25V274 owner letter (2025-09) — https://static.nhtsa.gov/odi/rcl/2025/RCONL-25V274-9051.pdf
15. GM's 5.3-Liter V8: A Complete Guide (AFM/DFM lifter) — A Plus Auto Parts — https://aplusauto.parts/gms-5-3-liter-v8-a-complete-guide-to-the-engine-its-problems-and-its-recalls/
16. Ram Hemi engine issue (exhaust manifold TSB) — Motor1 — https://www.motor1.com/news/771101/ram-hemi-engine-issue/
17. Leaf spring — Wikipedia — https://en.wikipedia.org/wiki/Leaf_spring
18. When do leaf springs need to be replaced? — TestingAutos — https://www.testingautos.com/car_care/leaf-springs.html
19. U-Joint Failure Modes — GMB — https://gmb.net/blog/u-joint-failure-modes/
20. Transfer case — Wikipedia — https://en.wikipedia.org/wiki/Transfer_case
21. Vehicle frame (ladder frame, body-on-frame) — Wikipedia — https://en.wikipedia.org/wiki/Vehicle_frame
22. Tow hitch (SAE J684 receiver classes) — Wikipedia — https://en.wikipedia.org/wiki/Tow_hitch
23. Trailer connectors in North America — Wikipedia — https://en.wikipedia.org/wiki/Trailer_connectors_in_North_America
24. 2024 Toyota Tacoma Finally Ditches Rear Drum Brakes for Discs — The Drive — https://www.thedrive.com/news/2024-toyota-tacoma-finally-ditches-rear-drum-brakes-for-discs
25. (검색 요약) F-150 spare under bed — itstillruns https://itstillruns.com/remove-spare-tire-ford-f150-7275740.html · GM Genuine Parts Spare Wheel Hoist https://parts.gmparts.com/product/gm-genuine-parts-spare-wheel-hoist-84447780
26. (검색 요약) 2024 Silverado 1500 fleet spec "4-wheel disc" — Washington DES — https://apps.des.wa.gov/CARS/VehicleSpecifications.aspx?id=2327
27. (검색 요약) Ram 1500 Big Horn 275/65R18 — CarExpert https://www.carexpert.com.au/ram/1500/2024--jgfsaggs20250327 · curb 5,085 lb — Motor Matchup https://www.motormatchup.com/catalog/RAM/1500/2023/Big-Horn-4x4-Crew-Cab-5'7%22-Box
28. (검색 요약) F-150 Lightning does away with Ford's C-clamp headlight design — Ford Authority — https://fordauthority.com/2022/07/f-150-lightning-does-away-with-fords-legendary-c-clamp-headlight-design
29. 2022 Silverado finally ditches Chevy's iconic stacked headlights — The Drive — https://www.thedrive.com/news/42316/2022-silverado-pickup-finally-ditches-chevys-iconic-stacked-headlights
30. 우리 규격: `docs/specs/car_spec.md` §0(기준 세단)·§3-3(리프트)·§7(베이)
31. (검색 요약) 2020 Silverado 1500 Crew Cab LTZ 265/65R18 — AutoPadre — https://www.autopadre.com/vehicle-weight/chevrolet-silverado-1500/2020-crew-cab-ltz-13974
