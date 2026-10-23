# 미니밴 (Minivan, 미국 말 "minivan") — 베타 손님 차 조사 (wr-carbook)

> 목적: wr-design의 `docs/design/car_roster.md` 근거. 미국 거리에 흔한 실제 차 4대 → 크기·구동·엔진 배치·서스펜션·흔한 고장·겉모양 공통점.
> 환산 1 stud = 0.28 m. car_spec 규칙: 폭(X) ×1.15, 높이는 앉은 R15 머리 공간 확인(세단은 +0.6). 기준 세단 = 길이 17.0 · 폭 7.6 · 높이 5.8 · 휠베이스 10.0 stud.
> 실제 브랜드 얼굴(그릴·로고·시그니처 램프)은 섞지 않아요 — '피할 것' 칸에 적기.
> 출처는 각 줄 끝 [n], 맨 아래 목록. 확인 못 하면 "(확인 못 함)", 검색 결과 요약만 보면 "(검색 요약)".
> 조사일 2026-10-21. 단위 바꾸기: 1 in = 25.4 mm, 1 lb = 0.4536 kg (계산은 wr-carbook).

## 0. 한 줄 요약
- 미니밴 = **가로배치 엔진 앞바퀴굴림(FF)** 뼈대에 **길고 높은 상자 몸통 + 양쪽 미닫이문(sliding door) + 큰 뒷문**. 4대 모두 앞 = 스트럿 [4][9][11][16].
- 세단과 가장 큰 '속' 차이 = **미닫이문 장치(레일 3줄·롤러·전동 모터·케이블·래치)**, 바닥에 접혀 들어가는 의자(Stow 'n Go) 통, 뒤 에어컨 배관, 차 밑 스페어 [5][17][18][21][22].
- 엔진은 차마다 달라요: Pacifica·Odyssey·Carnival = **V6 3.5~3.6 L**, Sienna = **2.5 L 4기통 하이브리드만**(2021년형부터) [3][8][10][15].

## 1. 대표 실제 차 (미국 판매 상위 — 판매 순위 출처 포함)
2024년 미국 판매: **Pacifica 107,356 (−11 %) · Odyssey 80,293 (+7 %) · Sienna 75,037 (+13 %) · Carnival 49,726 (+14 %)** [1]. (Sienna는 73,982로 적은 곳도 있음 — 검색 요약 [2]. 순위 1~4위는 같음.) 같은 회사 Chrysler Voyager(Pacifica 싼 판) 12,033대는 따로 [1].

| 차 (세대·연식) | 길이 × 폭 × 높이 / 휠베이스 (mm) | 공차 중량 | 구동 | 엔진 배치·종류 | 앞 / 뒤 서스펜션 | 흔한 타이어 |
|---|---|---|---|---|---|---|
| Chrysler Pacifica RU (2017년형~) [3] | 5,171 × 2,022 × 1,775~1,796 / 3,089 (203.6 × 79.6 × 69.9~70.7 in) [3] | 1,964 kg (플러그인 하이브리드 2,262) [3]; Select FWD 4,521 lb = 2,051 kg [4] | FF 또는 AWD(2020년 6월~) [3] | 가로배치 3.6 L Pentastar V6 + 9단 자동 / 플러그인 하이브리드(e-CVT) [3] | 스트럿 / **트레일링 암**(독립식, 따로 떼는 뒤 크래들) [4][5] | P235/65HR17 (Select) [4] |
| Honda Odyssey 5세대 RL6 (2018년형~) [8] | 5,212 × 1,994 × 1,768 / 3,000 (205.2 × 78.5 × 69.6 in, 118.1 in) [9] | 2,053~2,082 kg (4,526~4,590 lb) [9] | **FF만** [9] | 가로배치 3.5 L V6 J35Y6 + 10단 자동 [8][9] | 맥퍼슨 스트럿 / **트레일링 암 달린 소형 멀티링크** [9] | 235/60R18 (EX-L), 235/55R19 (윗 트림) [9] |
| Toyota Sienna 4세대 XL40 (2021년형~) [10] | 5,174~5,184 × 1,994 × 1,740~1,778 / 3,061 (203.7~204.1 × 78.5 × 68.5~70 in, 120.5 in) [10] | 2,090~2,146 kg (4,608~4,731 lb) [10] | FF 또는 전기식 AWD(뒤 전기모터) [10][12] | 가로배치 2.5 L 직렬 4기통 A25A-FXS **하이브리드만** + eCVT, 합계 243~245 hp [10][11] | 스트럿 / 멀티링크 [11] | P235/50TR20 (XSE) [11] |
| Kia Carnival 4세대 KA4 (북미 2022년형~) [15] | 5,155 × 1,995 × 1,740~1,775 / 3,090 [15] | 1,985~2,144 kg [15]; LX FWD 4,555 lb = 2,066 kg [16] | FF [15] | 가로배치 3.5 L V6 + 8단 자동 / 2025년형부터 1.6 T 하이브리드 + 6단 [15][16] | 스트럿 / 멀티링크 [16] | P235/65HR17 (LX) [16] |

- 지상고: Pacifica Select 5 in(127 mm) [4], Sienna XSE 6 in(152 mm) [11]. Odyssey·Carnival은 확인 못 함 [9][16].
- 플랫폼: Pacifica = 'RU' 전용 플랫폼 [3][5], Sienna = **Camry·RAV4와 같은 TNGA-K** [10][12], Odyssey = Acura MDX와 같은 바탕(위키 숨은 주석 — 확인 정도 낮음) [8], Carnival = 현대·기아 N3 [15].
- Sienna 이전 세대(~2020)는 뒤 = **토션빔(twist-beam)** 이었고 4세대부터 멀티링크로 바뀜 (검색 요약) [14].

## 2. 평균 → stud (게임 권장)
계산: 4대 평균(Sienna 길이는 가운데 5,179, 높이는 낮은 값(표준 지붕) 사용: Pacifica 1,775 · Odyssey 1,768 · Sienna 1,740 · Carnival 1,740).

| 항목 | 실제 평균 | stud | 게임 권장(×1.15 폭 등) | 세단 대비 |
|---|---|---|---|---|
| 전장 (길이) | 5,179 mm | 18.5 | **18.5** | **+1.5** (세단 17.0) |
| 전폭 (거울 빼고) | 2,001 mm | 7.15 | **8.2** (×1.15) | +0.6 (세단 7.6) |
| 전고 (높이) | 1,756 mm | 6.3 | **6.9** (세단처럼 머리 공간 +0.6) | **+1.1** (세단 5.8) |
| 휠베이스 | 3,060 mm | 10.9 | **10.9** | +0.9 (세단 10.0) |
| 앞뒤 오버행 합 (길이 − 휠베이스) | 2,119 mm | 7.6 | **7.6** | +0.6 (세단 7.0) |
| 지상고 | 약 140 mm (127~152) | 0.5 | **0.5** | 같음 (SUV처럼 높지 않음) |
| 타이어 지름 / 폭 | 235/65R17 ≈ 235/60R18 ≈ 235/55R19 ≈ 235/50R20 ≈ 737~743 mm / 235 mm | 2.64 / 0.84 | **2.6 / 1.0** (폭 ×1.15) | +0.2 / +0.1 (세단 2.4 / 0.9) |
| 휠(림) 지름 | 17~20인치 | 1.55~1.81 | 기본 **1.55**(17인치), 윗 트림 1.8(20인치) | 같음~큼 |
| 공차 중량 | 약 2,050~2,150 kg | — | (게임 무게 감각만) | 세단보다 훨씬 무거움 |

- 정리: **세단보다 1.5 stud 길고, 0.6 넓고, 1.1 높은 상자. 바닥 높이는 세단과 같음**(타고 내리기 쉽게). 바퀴 지름은 림이 17~20인치로 달라도 바깥 지름이 거의 같아요(약 0.74 m) [4][9][11][16].
- 미닫이문 길이: 휠베이스가 10.9라 앞문 뒤 ~ 뒷바퀴 앞 사이에 문이 들어가요(문 정확한 크기는 확인 못 함 — 3D 때 사진으로).

## 3. 세단과 다른 '속 구성' (부품 목록에 영향)
1. **미닫이문(sliding door) 장치 — 미니밴의 핵심**:
   - 문이 **레일 3줄(위·가운데·아래)** 에 매달려 롤러로 굴러감. 위·아래 롤러는 문틀 위·아래 레일, **가운데 경첩+롤러 뭉치는 뒤 옆판(쿼터패널)의 가운데 레일**을 탐 [17]. 이 특허(아래 롤러 조립체)에선 **받침 롤러가 문 무게 대부분**을 받고 안내 롤러가 방향을 잡아요 [17].
   - 가운데 레일 자리: 대부분 미니밴은 **뒤 옆창 아랫선에 레일과 문 모터를 숨김**, 2011 Odyssey는 일부러 몸통 낮은 곳에 드러냄 [24]; 지금 Odyssey는 **창 테두리 속에 숨김** [25].
   - 전동 미닫이문(PSD): **모터 + 드럼 + 구동 케이블 + 케이블 장력기(tensioner)** 로 문을 당김 [18]. 손잡이 → **바깥 손잡이 케이블** → 앞·뒤 **래치 2개**가 문을 잠금 [19].
   - 4대 모두 전동 미닫이문: Odyssey 전 트림 기본 [9], Sienna LE·XLE '양쪽 전동 미닫이문' + XLE 발차기 센서 [13], Pacifica '핸즈프리 미닫이문', **알루미늄 문** [3][5], Carnival 전동 미닫이문 (검색 요약 — 딜러 목록) [26].
   - → 게임 부품 후보: `SlidingDoor`(좌·우) + 롤러 3묶음 + 레일 + 문 모터·케이블 + 래치. 세단 `Door`(경첩 2개)와 완전히 다른 정비.
2. **바닥에 접혀 들어가는 의자(Stow 'n Go, Pacifica)**: 2·3열 의자가 **바닥에 만든 통(bin)** 으로 들어감 → 전용 바닥판이 필요 [5][7]. 플러그인 하이브리드는 **배터리(16 kWh)가 2열 바닥 아래**라 Stow 'n Go 없음 [3][5]. Odyssey는 대신 '옆으로 미는 2열 의자(Magic Slide)' [8].
3. **AWD 방식이 차마다 다름**:
   - Pacifica AWD: 9단 변속기 옆 **PTU(동력 분배기)** → **3토막 가운데 축**(차 바닥 가운데 터널) → **뒤 구동 모듈(전자 제어 습식 클러치)** → 뒷바퀴. 필요 없으면 PTU와 뒤 모듈 양쪽에서 **끊어서 축이 멈춤**. 뒤로 최대 100 % [6][7]. Stow 'n Go 통과 AWD를 둘 다 넣으려 미닫이문↔미닫이문 폭을 전 세대(RT)보다 약 1.5 in(38 mm) 넓힘 [7].
   - Sienna AWD: **가운데 축도 뒤 차동기어도 없이 뒤 차축에 전기모터 1개** (하이브리드라 가능) [10][12]. 평소 FF, 출발·미끄러질 때 뒤로 최대 80 % (검색 요약) [13].
   - Odyssey·Carnival: AWD 없음(이번 출처 기준 FF만) [9][15][16].
   - → 게임: 미니밴 AWD 손님은 Pacifica식 = `Driveshaft` + `RearDriveModule`, Sienna식 = `RearMotor`(고압 전기) — 정비가 달라요.
4. **뒤 서스펜션**: Pacifica = 얇은 강판 **트레일링 암** + 고무로 띄운 **뒤 크래들(받침틀)**, 뒤 쇼크 속 리바운드 스프링 덕에 **뒤 스태빌라이저 바 없음** [5]. Odyssey = 트레일링 암 달린 멀티링크 [9]. Sienna·Carnival = 멀티링크 [11][16]. (토션빔은 지금 4대엔 없음 — Sienna 옛 세대만 [14].)
5. **앞 서스펜션**: Pacifica 앞 맥퍼슨 스트럿은 알루미늄 위주(단조 아래 컨트롤암·주조 너클), 앞 크래들은 6점 고정 [5]. Odyssey 앞 = 맥퍼슨 스트럿 [9]. → car_spec `Strut` 그대로.
6. **뒷문(liftgate)**: Pacifica 뒷문 = 안쪽 마그네슘 + 바깥 알루미늄 판 [5]. Odyssey 전동 뒷문(높이 기억, Elite는 핸즈프리) [9], Sienna 발차기 센서 뒷문 [13]. 전동 뒷문 구동기 = 스트럿 모양 'powered gate strut' [23].
7. **뒤 에어컨(rear A/C)**: 3열까지 식히려 **뒤 증발기 + 차 밑을 지나는 긴 냉매 배관**. 배관 고정 클립(piping clamp)이 빠지면 냉매가 샘 [21].
8. **스페어 타이어**: 옛 Sienna(2004~2011)는 **차 밑에 케이블로 매단 스페어 받침** [22]. 지금: Odyssey = 임시 스페어 T135/80D17 [9], Pacifica Select·Sienna XSE = 스페어 '없음(N/A)'으로 표기 [4][11]. 하이브리드 Sienna가 수리 키트만 있는지·놓인 자리는 확인 못 함.
9. **하이브리드 고압 부품**: Sienna 하이브리드 배터리 1.9 kWh [10], Pacifica 플러그인 16 kWh 리튬이온(2열 바닥 아래) [3][5]. → 게임에서 '고압 주의' 부품 후보.

## 4. 그 차종만의 흔한 고장 (증상 → 원인 → 진단 → 수리)
| 증상 (손님 말 영어 예) | 원인 | 진단 | 수리 |
|---|---|---|---|
| "My power sliding door won't open or close." | 전동 미닫이문 **구동 케이블이 닳거나 걸려서 꼬임·빠짐**, 케이블 장력기 홈 손상 [18] | 케이블이 손상되고 제자리에서 벗어나 문이 안 움직임 [18] | 문을 더 움직이지 말고 분해 → 보이는 케이블을 잘라 문을 풀고 → 장력기 볼트 풀기 → **손상 부품(케이블·장력기) 교체**. 모터 드럼 덮개는 열지 말 것 [18] (Stellantis 정비 회보) |
| "In the cold, my sliding door didn't latch — it popped open." | **바깥 손잡이 케이블에 물이 들어가 얼어서** 앞·뒤 래치가 꽉 안 잠김 → 달리다 열릴 수 있음 [19]. 그 전 리콜은 뒤 래치 부품이 끈적여 걸림 (검색 요약) [20] | 추운 날 래치가 덜 걸림 확인 [19] | 리콜 20V-437(Odyssey 2018~2020, 324,194대): **전동 미닫이문 바깥 손잡이 케이블 교체** [19] |
| "The sliding door is slow, grinds, or sticks near the end." | 레일에 흙·이물질, **롤러 닳음·금·평평해짐**, 래치·스트라이커 어긋남 (검색 요약) [27] | 레일 청소 후에도 그러면 롤러 문제, 문 끝을 당겨 덜컥거리는지 확인 (검색 요약) [27] | 롤러 교체(아래 롤러 뭉치의 받침 롤러가 문 무게 대부분을 받음 [17]), 래치·스트라이커 조정 |
| "The front A/C is cold but the rear blows warm." | 뒤 에어컨 배관 **고정 클립(piping clamp)이 풀리거나 빠져서 냉매 샘** [21] | 클립이 빠졌는지·풀렸는지 눈으로 확인. 멀쩡하면 다른 원인 찾기 [21] | 냉매 회수 → **새 클립 끼움** → 냉매 다시 채움 → 작동 확인 [21] (Toyota T-SB-0152-13, Sienna 2011~2013) |
| "My spare tire fell off on the highway!" / "The spare under the van looks rusty." | 차 밑 **스페어 받침 케이블이 제설 소금으로 녹슬어 끊어짐** [22] | 겨울 소금 쓰는 지역 차, 케이블 녹 확인 [22] | 리콜 14V-273(Sienna 2004~2011): 우선 스페어를 짐칸으로 옮기고, 부품 나오면 **스페어 받침 뭉치 새것으로** [22] |
| "The power liftgate makes a loud noise." | 전동 뒷문 구동 스트럿 고장일 수도, 정상 작동 소리일 수도 [23] | 갈리는·긁히는 소리, 걸림, 안 열림, 고장 코드가 있을 때만 고장. 정상 차와 소리 비교 [23] | 위 조건이면 전동 스트럿 교체, 아니면 교체 X [23] |

- 게임 메모: 미니밴만의 고장 = **미닫이문(케이블·래치·롤러) 3종 + 뒤 에어컨 + 차 밑 스페어**. 세단 Door 정비와 겹치지 않게 'Sliding Door' 별도 작업으로.

## 5. 겉모양 공통점 — 섞을 특징 후보 (2대 이상에 공통인 것만) / 피할 것
| 섞을 특징 | 어느 차들에 공통 |
|---|---|
| **긴 상자 몸통 + 짧은 보닛**, 세단보다 높고(6.9 stud) 바닥은 낮음(0.5) | 4대 모두 (1·2장 숫자) [3][9][10][15] |
| **양쪽 전동 미닫이문** + 뒤 옆판에 **가운데 레일 홈**(대개 뒤 옆창 아랫선에 숨김) | 4대 모두 미닫이문 [3][9][13][26]; 레일 숨김 = '대부분 미니밴' [24], 지금 Odyssey [25] |
| **거의 세운 큰 뒷문(liftgate)**, 범퍼 위까지 내려옴 | Pacifica [5], Odyssey [9], Sienna [13], Carnival (검색 요약) [26] |
| 휠베이스가 길어 **바퀴가 앞뒤 끝 쪽**, 오버행 합 7.6 stud | 4대 모두 (2장 계산) |
| 큰 옆창 3줄(앞문·미닫이문·뒤 옆창), 뒤 기둥 근처 창이 길게 뒤로 | 사진 대조 필요 — **이번엔 출처 문장으로 확인 못 함** |

| 피할 것 (한 차만의 얼굴) | 어느 차 |
|---|---|
| 창 아랫선이 번개처럼 꺾이는 '라이트닝 볼트' 옆선·떠 있는 D필러 | Honda Odyssey [24][25] |
| 세로 헤드램프 + 'Star Map' 주간등, 'T'자로 만나는 뒤 램프 막대, 손잡이 없는 뒷문, SUV 같은 세운 얼굴 | Kia Carnival (2025 부분변경, 검색 요약) [26] |
| 각 브랜드 그릴 무늬·날개 로고·이름 글자 | Chrysler Pacifica, Toyota Sienna 등 전부 |

## 6. 출처
1. TFLcar — "Chrysler Still Sold More Than 100,000 Pacifica Minivans In 2024, But Rivals Are Eating Its Lunch" (2025-01-07) — https://tflcar.com/2025/01/minivan-sales-2024-chrysler-pacifica-vs-competition/
2. Guide Auto Web — "Minivans Are Back! Latest Sales Results Highlight Sustained Growth" (검색 요약) — https://www.guideautoweb.com/en/articles/79351/minivans-are-back-latest-sales-results-highlight-sustained-growth
3. Wikipedia — Chrysler Pacifica (minivan) (정보상자·본문, raw) — https://en.wikipedia.org/wiki/Chrysler_Pacifica_(minivan)
4. Cars.com — 2025 Chrysler Pacifica Select FWD specs — https://www.cars.com/research/chrysler-pacifica-2025/specs/460097/
5. Mobility Engineering Technology (SAE) — "2017 Pacifica Is First Hybrid Minivan, Rides on All-New FCA Platform" — https://www.mobilityengineeringtech.com/component/content/article/42426
6. Automotive World — "All-wheel drive arrives: ordering opens for 2020 Chrysler Pacifica AWD Launch Edition" (FCA 보도자료) — https://www.automotiveworld.com/news/all-wheel-drive-arrives-ordering-opens-for-2020-chrysler-pacifica-awd-launch-edition/
7. Jalopnik — "The AWD 2021 Chrysler Pacifica Looks Great And Solves A Major Engineering Problem From 2005" — https://jalopnik.com/the-awd-2021-chrysler-pacifica-looks-great-and-solves-a-1841492542
8. Wikipedia — Honda Odyssey (North America) (5세대 RL6) — https://en.wikipedia.org/wiki/Honda_Odyssey_(North_America)
9. Honda News — "2025 Honda Odyssey Specifications & Features" — https://hondanews.com/en-US/honda-automobiles/releases/release-410d07897fdd63d8043cb72750011124-2025-honda-odyssey-specifications-features
10. Wikipedia — Toyota Sienna (4세대 XL40) — https://en.wikipedia.org/wiki/Toyota_Sienna
11. Cars.com — 2025 Toyota Sienna XSE FWD specs — https://www.cars.com/research/toyota-sienna-2025/specs/461556/
12. New Atlas — "2021 Toyota Sienna unveil" (TNGA-K, 뒤 전기모터·축/차동 없음) — https://newatlas.com/automotive/2021-toyota-sienna-unveil/
13. Toyota Canada — "All-New, All-Hybrid, And Impressively Priced: The 2021 Toyota Sienna" (전동 미닫이문·발차기 센서; 80 %는 검색 요약) — https://media.toyota.ca/en/releases/2020/all-new-all-hybrid-and-impressively-priced-the-2021-toyota-sienna.html
14. J.D. Power — 2021 Toyota Sienna review (토션빔 → 멀티링크, 검색 요약·본문 403) — https://www.jdpower.com/cars/2021/toyota/sienna
15. Wikipedia — Kia Carnival (4세대 KA4) — https://en.wikipedia.org/wiki/Kia_Carnival
16. Cars.com — 2025 Kia Carnival LX FWD specs — https://www.cars.com/research/kia-carnival-2025/specs/454280/
17. Google Patents — US6036257A "Articulating lower roller assembly for sliding vehicle door" (GM, 2000) — https://patents.google.com/patent/US6036257
18. Stellantis STAR Online S2323000058 — "Power Sliding Door Will Not Open And Or Close" (2023-07), NHTSA 게시 — https://static.nhtsa.gov/odi/tsbs/2023/MC-10242755-9999.pdf
19. NHTSA — Recall 20V-437 "Power Sliding Doors May Open While Moving" (Honda Odyssey 2018~2020) — https://static.nhtsa.gov/odi/rcl/2020/RCAK-20V437-4199.pdf
20. Consumer Reports — "Honda recalls 2018 Odyssey over problem with sliding doors" (18V-795, 검색 요약) — https://www.consumerreports.org/car-recalls-defects/honda-odyssey-minivan-recalled-over-problem-with-sliding-doors
21. Toyota T-SB-0152-13 — "A/C Inoperative - Rear A/C Line Retainer Missing" (2013-10-02), NHTSA 게시 — https://static.nhtsa.gov/odi/tsbs/2013/SB-10061628-2280.pdf
22. NHTSA — Recall 14V-273 "Spare Tire Assembly may Corrode and Detach" (Toyota Sienna 2004~2011) — https://static.nhtsa.gov/odi/rcl/2014/RCAK-14V273-8373.pdf
23. Stellantis STAR Online S2523000094 — "Power Liftgate Noise During Gate Operation" (2025-12), NHTSA 게시 — https://static.nhtsa.gov/odi/tsbs/2025/MC-11026641-0001.pdf
24. WardsAuto — "Honda Improves Minivan Formula with '11 Odyssey" (레일·모터 자리, 라이트닝 볼트) — https://wardsauto.com/honda/honda-improves-minivan-formula-with-11-odyssey
25. Honda Information Center — 2023 Odyssey Feature Highlights ("sliding-door channels are hidden in the window trim") — https://www.hondainfocenter.com/2023/Odyssey/Feature-Guide/Feature-Highlights/
26. Carscoops — "2025 Kia Carnival detailed in Korea" (검색 요약) + 딜러 목록(전동 미닫이문·뒷문, 검색 요약) — https://www.carscoops.com/2023/11/2025-kia-carnival-detailed-in-korea-new-hybrid-van-has-242-hp/
27. VehQ — "How To Fix Honda Odyssey Sliding Door" 등 수리 안내·차주 보고 (검색 요약) — https://vehq.com/how-to-fix-honda-odyssey-sliding-door/
