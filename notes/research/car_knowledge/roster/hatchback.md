# 해치백 (Compact hatchback, 미국 말 "hatchback" / "5-door") — 베타 손님 차 조사 (wr-carbook, 2026-10-21)

> 목적: wr-design의 `docs/design/car_roster.md` 근거. 미국 거리에 흔한 실제 차 3~5대 → 크기·구동·엔진 배치·서스펜션·흔한 고장·겉모양 공통점.
> 환산 1 stud = 0.28 m. car_spec 규칙: 폭(X) ×1.15, 높이는 앉은 R15 머리 공간 확인(세단은 실제 5.2 → 게임 5.8, +0.6). 기준 세단 = 길이 17.0 · 폭 7.6 · 높이 5.8 · 휠베이스 10.0 stud.
> 실제 브랜드 얼굴(그릴·로고·시그니처 램프)은 섞지 않아요 — '피할 것' 칸에 적기.
> 출처는 각 줄 끝 [n], 맨 아래 목록. 확인 못 하면 "(확인 못 함)", 검색 결과 요약만 보면 "(검색 요약)".

## 0. 고른 차와 뺀 차
- **고름 (4대)**: Honda Civic Hatchback(11세대) · Mazda3 Hatchback(4세대) · Toyota Corolla Hatchback(E210) · VW Golf GTI(Mk8).
- **뺌**: 보통 Golf — VW가 2021년 1월 미국용 생산을 끝냈고, 2022년형부터 미국엔 **GTI와 Golf R만** 남음 [12]. 그래서 Golf 대표는 GTI.
- **뺌**: Hyundai Elantra 등 — 이번 조사에서 현재 미국에서 파는 해치백 차체를 확인 못 함(확인 못 함). 세단만 있는 차는 이 파일에서 제외.
- 미국 판매 근거 (이름 전체 = 세단+해치 합계, 해치만 따로 센 공개 숫자는 확인 못 함):
  - Honda Civic 2024년 **242,005대**(+20.8%), Toyota Corolla 2024년 **232,908대**(+0.2%) [13].
  - Mazda3(세단+해치) 2024년 1~11월 **34,830대** [14](검색 요약).
  - Golf GTI 판매 대수는 확인 못 함. 대신 2022~23 GTI 리콜 한 건만 6,632대 [20] → 적지 않게 굴러다님.
  - Civic Hatchback은 미국 인디애나 Greensburg 공장에서 만든 첫 Civic 해치 [1] → '미국 동네 차' 느낌에 맞음.

## 1. 대표 실제 차 (미국 판매 상위 — 판매 순위 출처 포함)
| 차 (세대·연식) | 길이 × 폭 × 높이 / 휠베이스 (mm) | 공차 중량 | 구동 | 엔진 배치·종류 | 앞 / 뒤 서스펜션 | 흔한 타이어 |
|---|---|---|---|---|---|---|
| **Honda Civic Hatchback** (11세대 FL, 2022년형~) | 4,547 × 1,801 × 1,415 / 2,735 [2][1] | 1,322~1,412 kg [2] | FF(앞바퀴) [2] | 앞 엔진, 직렬 4: 2.0 L 자연흡기 158 hp 또는 1.5 L 터보 180 hp, CVT / 6단 수동 [2] | 스트럿 / **멀티링크** [2] | P215/55R16, P235/40R18 [2] |
| **Mazda3 Hatchback** (4세대 BP, 2019년형~) | 4,460 × 1,795 × 1,435~1,440 / 2,725 [3] | 3,146 lb ≈ 1,427 kg (2.5 S 자동) [4] | FF, AWD 고를 수 있음 [4][5] | 앞 엔진, 직렬 4 2.5 L 191 hp, 6단 자동 (2.5 터보도 있음) [4][3] | 스트럿 / **토션빔** [4][3] | P205/60R16 [4] (윗급 215/45R18 — 검색 요약) |
| **Toyota Corolla Hatchback** (E210, 2019년형~) | 4,370 × 1,790 × 약 1,448(57 in) / 2,640 [6][7] | 3,060 lb ≈ 1,388 kg (SE CVT) [7] | FF [7] | 앞 엔진, 직렬 4 2.0 L M20A-FKS 169 hp, 출발 기어 달린 CVT / 6단 수동 [6] | 스트럿 / **멀티링크** [7][9] | P205/55R16 (cars.com SE 표기) [7] |
| **VW Golf GTI** (Mk8, 2022년형~) | 4,284 × 1,789 × 1,456 / 2,636 (Golf 8세대 공통 값) [10] — GTI 표기 169 × 70 × 58 in / 104 in [11] | 3,183 lb ≈ 1,444 kg [11] | FF [11] | 앞 엔진, 직렬 4 2.0 L **터보** 241 hp, 7단 DSG (6단 수동은 2024년형이 미국 마지막) [11][10] | 스트럿 / **멀티링크** [11][10] | P225/40R18 [11] |

- 4대 모두 **앞 엔진 앞바퀴굴림(FF)** — 기준 세단(Camry)과 같은 '가로배치 FF' 집안 [23]. 엔진은 Camry 2.5 L보다 작은 2.0 L급 또는 1.5~2.0 L 터보.
- 같은 이름 세단과 비교 (해치백이 뭐가 다른지):
  - Civic: 휠베이스·폭·높이 **세단과 같음**, 뒤 오버행만 **124 mm 짧음** (세단 4,674 → 해치 4,549) [1].
  - Mazda3: 휠베이스(2,725)·폭 같고, 길이 **200 mm 짧음** (세단 4,660 → 해치 4,460) [3].
  - Corolla: 해치는 휠베이스 104 in, 세단은 106 in → 해치가 **약 2 in(약 60 mm) 짧은 휠베이스** [7][8].
  - GTI: 미국엔 Golf 세단이 없어서 비교 없음 (같은 집안 Jetta는 이 파일 범위 밖).

## 2. 평균 → stud (게임 권장)
4대 평균(위 표 mm 값): 길이 4,415 · 폭 1,794 · 높이 약 1,439 · 휠베이스 2,684 mm.

| 항목 | 실제 평균 | stud (÷0.28) | 게임 권장(×1.15 폭 등) | 세단 대비 |
|---|---|---|---|---|
| 전장 (길이) | 4,415 mm (Civic 16.2 · Mazda3 15.9 · Corolla 15.6 · GTI 15.3 stud) | 15.8 | **15.8** | −1.2 (17.0 → 15.8) |
| 전폭 (폭, 거울 빼고) | 1,794 mm | 6.4 | **7.4** (6.4 × 1.15) | −0.2 (거의 같음 → 부품 공유하려면 7.6 그대로도 OK) |
| 전고 (높이) | 1,439 mm | 5.1 | **5.8** (+0.6 머리 공간, 세단 규칙 그대로) | 같음 |
| 휠베이스 | 2,684 mm | 9.6 | **9.6** | −0.4 |
| 앞+뒤 오버행 합 | 4,415 − 2,684 = 1,731 mm | 6.2 | 앞 **3.4**(세단 엔진룸 그대로) + 뒤 **2.8** | 뒤만 −0.8 (세단 3.6) — Civic처럼 '뒤가 잘린' 모양 [1] |
| 타이어 지름 | 205/55R16 ≈ 632 mm, 235/40R18 ≈ 645 mm, 225/40R18 ≈ 637 mm (계산) | 2.3 | **2.3** (세단 Wheel 2.4 공유해도 4% 차이) | −0.1 |
| 공차 중량 | 약 1,390~1,440 kg (Civic 1,322~1,412) | — | 리프트·물리 질량 참고 | (세단 무게는 이 파일에서 확인 안 함) |

- 한 줄 요약: **"세단에서 트렁크 엉덩이를 약 1.2 stud 잘라 내고, 지붕을 뒤 끝까지 끌고 내려온 차"**. 폭·높이·엔진룸은 세단과 거의 같아서 **엔진룸 부품(배터리·라디에이터·엔진) 자리는 세단 좌표 그대로** 쓸 수 있어요(Civic·Mazda3는 휠베이스까지 세단과 같음 [1][3]).
- 차 피벗(앞뒤 바퀴 가운데)은 휠베이스 9.6 기준 → 앞바퀴 Z −4.8, 뒷바퀴 Z +4.8.

## 3. 세단과 다른 '속 구성' (부품 목록에 영향)
1. **뒷문 = 리프트게이트(해치)**: 트렁크 뚜껑 대신 **뒷유리까지 통째로** 지붕 쪽 경첩으로 열리는 문. 무게를 **가스 스트럿(gas strut, 'lift support') 2개**가 받쳐 줘요 [16].
   - 스트럿은 한쪽은 차체, 한쪽은 문에 붙는 **볼 스터드(ball stud)** 에 끼움. GM 정비 회보: 막대(rod) 쪽이 **아래(문 쪽)** 로 가게 달아야 먼지가 막대-몸통 씰에 덜 쌓여 오래 감 [16].
   - GM은 스트럿 교체를 **"보통 소모품(maintenance item)"** 으로 봄, 약해지면 **두 개 같이** 교체 [16].
   - → 게임 부품 후보: `HatchStrut` ×2 (좌/우, 한 메시 180° 돌려 쓰기), 볼 스터드 4개.
2. **뒷유리 와이퍼 + 모터**: 세단엔 없는 부품. Civic Hatchback은 전 트림 기본 **Rear wiper** [2]. 모터는 **해치 문 안**에 들어 있고, 전선은 해치가 열고 닫힐 때 접히는 **해치 배선 묶음(harness)** 을 지나가서 거기서 끊어지기 쉬움 [17].
   - → 게임 부품 후보: `RearWiperMotor`(해치 안쪽 판 뒤), `RearWiperArm`.
3. **뒤 서스펜션이 차마다 다름** (세단 기준 = 멀티링크):
   - **멀티링크**: Civic 해치(세단과 같음) [2][1], Corolla 해치 [7][9], GTI [11].
   - **토션빔(twist beam)**: Mazda3 — 4세대에서 멀티링크를 **"더 싸고 작은 토션빔"** 으로 바꿈, 세단·해치 둘 다 [3][4][5].
   - 반전: **Corolla는 세단(LE)이 토션빔, 해치가 멀티링크** [8][7]. Corolla 세단 LE는 2023년부터 멀티링크 → 토션빔으로 바뀜 [6].
   - 토션빔 = 좌우 트레일링 암 두 개를 **가로 빔 하나**로 이은 'H/C 모양' 덩어리, 고무 부싱으로 차체에 붙음, 부싱 수가 적고 바닥 아래가 단순 [15]. 단점: **뒤 바퀴 얼라인먼트 조절이 안 됨**(No redress for wheel alignment) [15] → 뒤 토(toe)가 틀어지면 조절 대신 빔·부싱 교체 쪽.
   - → 게임: 뒤 서스 부품을 차종별로 `RearMultiLink`(암 여러 개) / `RearTwistBeam`(빔 1개 덩어리) 두 가지로.
4. **트렁크 칸이 실내와 한 칸**: 뒷좌석 60/40 접힘(Civic) [2] → 짐칸 바닥 아래에 **임시 스페어**(Civic T125/80D16 · T125/85D16) [2]. 스페어 자리는 세단처럼 '뒤 바닥 아래'지만 정확한 위치 그림은 확인 못 함.
5. **터보 차 = 앞에 인터쿨러**: GTI는 **라디에이터가 인터쿨러에 붙어** 있는 구조(리콜 문서에 "radiator ... affixed to the intercooler") [20]. Civic 해치 1.5 L도 터보 [2]. → 터보 해치는 앞 범퍼 뒤 '라디에이터 앞에 얇은 판 하나 더'(인터쿨러) 장식 후보. 인터쿨러의 정확한 위치 그림은 확인 못 함.
6. **브레이크**: Civic 해치 = 앞 통풍 디스크 / 뒤 일반(솔리드) 디스크 [2] → 세단 프로토의 '뒤도 디스크'와 같음.
7. **변속기**: CVT(Civic·Corolla) · 6단 자동(Mazda3) · 7단 DSG 듀얼클러치(GTI) [2][4][6][11]. 수동은 Civic·Corolla·Mazda3에 있었고 GTI 수동은 2024년형으로 끝 [10].

## 4. 그 차종만의 흔한 고장 (증상 → 원인 → 진단 → 수리)
| 증상 (손님 말 영어 예) | 원인 | 진단 | 수리 |
|---|---|---|---|
| "My hatch won't stay up — it nearly hit my head." | 해치 **가스 스트럿 압력 빠짐**(씰 마모로 가스 샘). GM: 약해진 스트럿 = 문이 떨어져 사람을 칠 수 있음 [16] | 해치를 끝까지 열고 손을 떼 봄 → 스르르 내려오면 불량. 막대에 기름 자국 = 씰 고장 (검색 요약) | 문을 막대기로 받치고 → 클립 빼고 볼 스터드에서 떼기 → **2개 같이** 새것, **막대가 아래(문 쪽)** [16] |
| "Rear wiper is super slow / stopped / fuse keeps blowing." | ① 와이퍼 축(피벗) 녹슬어 꽉 낌 ② 모터 고장 ③ 해치 배선 끊김 ④ 퓨즈 (얼어붙은 채 켜면 잘 끊김) [17] | 퓨즈 → 스위치 켰을 때 모터 커넥터에 12 V 오는지 → 모터 소리 → 축에 윤활 뿌려 보기 [17] | 축 윤활 / 모터 통째 교체(약 $220~350+) / 배선 수리 [17] |
| "My car slammed on the brakes by itself — nothing was in front!" (2019~20 Mazda3) | 자동 긴급제동(Smart Brake Support) **소프트웨어 오류**로 앞에 장애물이 있다고 착각, 리콜 **19V-907**, 35,390대 [18] | 경고음 + 계기판 경고 메시지가 뜸, VIN으로 리콜 대상 확인 [18] | 딜러가 SBS 제어 소프트웨어 재프로그램, 일부는 계기판 교체·재프로그램 + 설명서 교체, 무료 [18] |
| "Steering feels sticky on the highway." (2022~23 Civic, 해치 포함) | NHTSA 조사: 고속에서 한동안 달린 뒤 **조향이 잠깐 무거워짐**, 약 238,000대, 불만 145건 (2023-03) [19]. 원인은 출처에 없음 | 고속 시운전, 리콜·TSB 조회 (조사 결과·리콜 여부는 확인 못 함) | (확인 못 함) — 게임에선 '조향 랙 점검' 정도로만 |
| "I smell coolant and a red light came on." (2022~23 GTI) | 공장에서 **라디에이터가 인터쿨러에 제대로 안 붙음** → 흔들리다 **냉각수 호스가 V벨트 풀리에 닿아** 상처 → 샘. 리콜 **22V-707**, GTI 6,632대 [20] | 라디에이터-인터쿨러 고정 확인 → 헐거우면 호스·V벨트 상처 확인 [20] | 상한 **냉각수 호스 + V벨트** 교체, 무료 [20] |

- 게임 고장 카탈로그 후보 우선순위: ① 해치 스트럿(해치백만의 고장, 부품 2개라 짧은 미션) ② 뒷유리 와이퍼 모터 ③ 냉각수 호스 마모(터보 해치). 브레이크 자동 작동·조향 끈적임은 '소프트웨어 업데이트' 미션 소재.

## 5. 겉모양 공통점 — 섞을 특징 후보 (2대 이상에 공통인 것만) / 피할 것
| 섞을 특징 | 어느 차들에 공통 |
|---|---|
| 5도어 + 지붕 끝 경첩 해치(뒷유리 포함), 가스 스트럿 2개 | 4대 모두 (해치백 정의) [1][3][6][10] |
| 세단보다 **뒤 오버행만 짧고** 휠베이스·폭은 세단과 같거나 비슷 | Civic [1] · Mazda3 [3] · Corolla [7][8] |
| 기본 **16인치**, 윗급 **18인치** 휠 | Civic [2] · Mazda3 [4] · Corolla(16) [7] · GTI(18) [11] |
| 앞 스트럿 + 뒤 멀티링크 (밑에서 보면 뒤에 암 여러 개) | Civic · Corolla · GTI [2][7][11] |
| 뒷유리 와이퍼 | Civic 기본 [2] (다른 차는 사진 확인 필요 — 확인 못 함) |
| 폭 약 1.79~1.80 m로 거의 같은 몸통 | 4대 모두 [1][3][6][10] |

| 피할 것 (한 차만의 얼굴) | 어느 차 |
|---|---|
| 얇은 위 그릴 막대를 가로질러 **헤드라이트까지 이어지는 빨간 줄**, 큰 **벌집(honeycomb) 아래 그릴** 안의 **X자 안개등**, 체크무늬(plaid) 시트 | VW Golf GTI [21](검색 요약) |
| 일부러 아주 두껍게 만든 **C필러**(뒷창 옆 기둥) — Mazda가 "순전히 디자인"이라고 함 | Mazda3 Hatchback [22](검색 요약) |
| 각 회사 로고·엠블럼, 회사 고유 그릴 모양 | 전부 |

- wr-art 메모: '알아보게 할 특징 3개' 후보 = ① 짧은 엉덩이 + 거의 세로로 선 해치 ② 해치 위 가운데 뒷유리 와이퍼 하나 ③ 해치 양옆 가스 스트럿 두 개(열었을 때). 그릴·램프는 우리 오리지널.

## 6. 출처
1. Honda Civic (eleventh generation) — Wikipedia — https://en.wikipedia.org/wiki/Honda_Civic_(eleventh_generation)
2. Honda Canada — 2022 Civic Hatchback spec sheet (PDF: 서스펜션·타이어·치수·Rear wiper·스페어) — https://www.honda.ca/Content/honda.ca/86525d2a-11fa-4527-8754-5ed987f3510e/ModelPage_Downloads/028382_01_22MY_Civic_Hatchback_HeaderSpec_EN_V2_hires.pdf
3. Mazda3 — Wikipedia (4세대 치수, 토션빔 전환) — https://en.wikipedia.org/wiki/Mazda3
4. Cars.com — 2025 Mazda3 2.5 S Auto FWD specs (길이 175.6 in = 해치) — https://www.cars.com/research/mazda-mazda3-2025/specs/459771/
5. Cars.com — 2025 Mazda3 specs (트림 목록·AWD 트림, 2.5 S 세단 토션빔) — https://www.cars.com/research/mazda-mazda3-2025/specs/
6. Toyota Corolla (E210) — Wikipedia — https://en.wikipedia.org/wiki/Toyota_Corolla_(E210)
7. Cars.com — 2025 Toyota Corolla Hatchback SE CVT specs — https://www.cars.com/research/toyota-corolla_hatchback-2025/specs/
8. Cars.com — 2025 Toyota Corolla LE CVT (세단) specs — https://www.cars.com/research/toyota-corolla-2025/specs/
9. Toyota Canada — Corolla Hatchback features (multi-link rear suspension) (검색 요약) — https://toyota.ca/toyota/en/vehicles/corolla-hatchback/features-benefits
10. Volkswagen Golf Mk8 — Wikipedia — https://en.wikipedia.org/wiki/Volkswagen_Golf_Mk8
11. Cars.com — 2025 Volkswagen Golf GTI 2.0T S DSG specs — https://www.cars.com/research/volkswagen-golf_gti-2025/specs/
12. MotorWeek — Volkswagen to Discontinue Sales of Base Golf in North America, Golf R and GTI Will Continue — https://motorweek.org/this_just_in/volkswagen-to-discontinue-sales-of-base-golf-in-north-america-golf-r-and-gt
13. Motor1 — Cheap Car Sales Exploded in 2024 (Civic·Corolla 2024 판매) — https://www.motor1.com/news/746185/cheap-car-sales-2024/
14. Carscoops — Mazda set for record US sales (Mazda3 2024 1~11월) (검색 요약) — https://www.carscoops.com/2024/12/mazda-set-for-record-us-sales-continues-development-of-ev-hybrid-and-ice/
15. Twist-beam rear suspension — Wikipedia — https://en.wikipedia.org/wiki/Twist-beam_rear_suspension
16. GM Recall Bulletin 15240A / NHTSA 15V415 — Power Lift Gate Prop Rod Recovery (가스 스트럿 마모·2개 교체·막대 아래 방향·'maintenance item') — https://static.nhtsa.gov/odi/rcl/2015/RCRIT-15V415-2055.pdf
17. Samarins — Troubleshooting Rear Wiper Problems: 7 Common Causes — https://www.samarins.com/diagnose/rear-wiper-not-working.html
18. NHTSA Part 573 Safety Recall Report 19V-907 (2019~2020 Mazda3 SBS) — https://static.nhtsa.gov/odi/rcl/2019/RCLRPT-19V907-6397.PDF
19. Motor1 — Feds Investigating Honda Civic For Potential Steering Issues (2023-03-21) — https://www.motor1.com/news/658385/feds-investigating-honda-civic-potential-steering-issues/
20. NHTSA Part 573 Safety Recall Report 22V-707 (2022~2023 Golf GTI / Golf R 라디에이터·냉각수 호스) — https://static.nhtsa.gov/odi/rcl/2022/RCLRPT-22V707-6594.PDF
21. evo — Volkswagen Golf GTI Mk8 review: design (검색 요약) — https://evo.co.uk/volkswagen/golf-gti/205217/volkswagen-golf-gti-mk8-review-design
22. Jalopnik — The 2019 Mazda 3 Hatch's Rear Visibility Is Precisely As Bad As You Think It Is (검색 요약) — https://jalopnik.com/the-2019-mazda-3-hatchs-rear-visibility-is-precisely-as-1830754940
23. Front-engine, front-wheel-drive layout — Wikipedia — https://en.wikipedia.org/wiki/Front-engine,_front-wheel-drive_layout
