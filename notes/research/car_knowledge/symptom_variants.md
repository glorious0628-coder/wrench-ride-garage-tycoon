# 부품별 증상 변주 (symptom_variants) — "같은 부품이라도 매번 다른 수수께끼" (wr-carbook, 10-21)

> 메인 부탁(tycoon_analysis 장점 1·2): 부품마다 **실제** 증상·원인·결말 변주 2~4개. 각 변주 = 손님 말(영어 원문 + 한국어) · 찾는 단서(눈·소리·도구·숫자) · **헷갈리는 짝** · 고친 뒤 달라지는 것.
> 근거 = 이 폴더의 시스템 파일(출처 번호는 그 파일 안) + 이번에 새로 연 출처 [S1]~[S4](맨 아래). `ID`는 제안(이미 fault_catalog v0.4에 있는 건 그 ID 그대로, 새 것은 **NEW**).
> 손님 말은 원인을 말하지 않아요(fault_catalog §0 규칙).

---

## 1. Battery (배터리) — 같은 "시동이 안 걸려요"가 5갈래
| ID | 손님 말 (EN / 한) | 단서 (눈·소리·도구) | 헷갈리는 짝 | 고친 뒤 | 근거 |
|---|---|---|---|---|---|
| BAT_DEAD | "It won't start. Just goes click-click-click." / "시동이 안 걸려요. 딸깍딸깍 소리만 나요." | **빠른 딸깍딸깍** + 계기판 희미·깜빡 / 테스터 쉬는 전압 **12.0 V 이하**(12.66 V = 100 %, 12.24 = 50 %, 11.89↓ = 0 %) / 표면 전하 때문에 처음엔 13 V대로 떴다 내려앉음 | BAT_CORROSION(전압은 정상), StarterMotor('딸깍' **한 번**) | 시동 '부릉', 테스터 12.6 V+ | 01 ⑤ [2][3][14] |
| BAT_CORROSION | "Sometimes it starts, sometimes it doesn't." / "될 때도 있고 안 될 때도 있어요." | 단자에 **흰·초록 가루** / 쉬는 전압은 **12.5 V 정상** → 단자 사이 **전압 강하**로 잡음 | BAT_DEAD(교체하면 오진) | 와이어 브러시로 닦고 바셀린 → 반짝, 매번 시동 | 01 ⑤ [1][3][11][14][17] |
| BAT_OLD | "It cranks really slow in the morning." / "아침에 시동이 느릿느릿 걸려요." | **느린 크랭킹** / 부하 시험: CCA 50 % 부하 15초에 **9.6 V 미만**(70°F 기준)이면 불합격 / 옆면 **불룩** | BAT_DEAD(충전하면 잠깐 됨), 시동모터 끌림 | 크랭킹 빨라짐 | 01 ⑤ [2][11] |
| ALT_FAIL (나중 부품 Alternator) | "My battery keeps dying, even the new one." / "새 배터리도 자꾸 방전돼요." · 또는 "The battery light is on." / "배터리 경고등이 켜졌어요." | **배터리 모양 경고등 = 충전 계통 고장**(토요타 정의) / 시동 켠 채 전압 **13.2 V 미만**(정상 13.5~14.5) / 윙·그르렁 소리 | BAT_DEAD(배터리만 바꾸면 이틀 뒤 '다시 온 손님') | 시동 중 14 V 근처, 경고등 꺼짐 | 01 ⑤ [24][25][33] |
| **NEW** BAT_DRAIN (기생 전류) | "It's fine when I drive, but dead every morning." / "탈 땐 괜찮은데 아침마다 방전돼요." | 시동 켜면 충전 전압 **정상**(발전기 멀쩡) / 키 끈 상태 전류 **50 mA 넘음**(정상 50 mA 이하) → 퓨즈를 하나씩 빼며 숫자가 떨어지는 회로 찾기 | ALT_FAIL(충전 전압으로 갈림), BAT_OLD | 밤새 세워도 시동 | 01 ⑤ [24] |
| (짝) StarterMotor 후보 | "It just clicks once and nothing." / "딸깍 한 번 하고 끝이에요." | **딸깍 한 번 또는 무소리** + 배터리 정상 → 전압 강하 + 0.5 V 미만이면 시동모터 쪽 | BAT_DEAD(빠른 연속 딸깍과 구별) | 시동 | 01 시동모터 ⑤ [14][17][18] |

## 2. BrakePads (브레이크 패드) + 캘리퍼 — 같은 "브레이크 소리"가 5갈래
| ID | 손님 말 | 단서 | 헷갈리는 짝 | 고친 뒤 | 근거 |
|---|---|---|---|---|---|
| PAD_WORN | "My brakes squeal when I stop." / "멈출 때 끼익 소리가 나요." | 패드의 **마모 경고 탭**이 디스크에 닿음 — 마찰재 약 **1.5 mm** 남음(새것 11.0, 매뉴얼 최소 1.0, 정비소 기준 약 3 mm). 탭 소리는 **브레이크를 안 밟을 때도** 날 수 있음 | PAD_NOISY(두께는 충분) | 패드 두께 새것, 조용 | 02 패드 ② [4][32] |
| **NEW** PAD_NOISY (진동 끼익) | "They squeal at low speed, but the pads are new!" / "패드 새로 갈았는데 천천히 갈 때 끼익 해요!" | 패드 **두께 충분** / 높은 끼익(2,000~15,000 Hz)은 패드·디스크 **떨림(stick-slip)** — 성능엔 보통 문제 없음 / 청진기로 위치 | PAD_WORN(갈면 오진 — 두께부터 보기) | **심(shim) 새로 + 소음 방지 페이스트**·클립 키트 → 조용 | 02 ⑤ [16][17][25][35] |
| PAD_GONE | "Now it's grinding, like metal on metal!" / "이제 쇠 긁는 소리가 나요!" | 드르륵 / 패드 철판이 디스크를 긁음 → 디스크에 **동심원 홈**, 디스크 두께가 **최소 25.0 mm** 밑이면 교체 | PAD_WORN(늦게 와서 디스크까지) | 패드 + 디스크 교체(깎기는 최소 두께 위일 때만) | 02 디스크 ② [4][33] |
| **NEW** CALIPER_STICK (캘리퍼 고착) | "The car pulls when I brake, and one wheel feels hot." / "브레이크 밟으면 한쪽으로 쏠리고, 한쪽 바퀴가 뜨거워요." | **안쪽·바깥 패드가 고르지 않게 닳음** / 피스톤이 녹·부식으로 붙음 → **브레이크가 계속 끌림(drag)**, 슬라이드 핀·부싱 녹 / 밟을 때 '멀쩡한 쪽'으로 쏠리고, 끌리면 '나쁜 쪽'으로 쏠림 | PAD_UNEVEN(기존 — 핀 기름칠로 끝), TIRE_UNEVEN(얼라인먼트), 허브 베어링 헐거움도 쏠림 원인 | 핀 청소·그리스 또는 캘리퍼 교체 + 공기 빼기 → 쏠림 사라짐 | [S3], 02 캘리퍼 ⑤ |
| BRAKE_PULSE (디스크 두께 차) | "The brake pedal pulses when I stop." / "브레이크 밟으면 페달이 덜덜 떨려요." | 흔히 'warped rotor'라 부르지만 실제론 **흔들림 → 두께 차(DTV)** / 다이얼 게이지 흔들림 최대 **0.05 mm**, 8곳 두께 차 0.013 mm 넘으면 떨림 | WHEEL_IMBALANCE(밟지 않아도 떨림) | 디스크 깎기·교체, **허브 위치 바꿔 끼우기** | 02 ⑤ [19][33][43][44] |

- 덤: 패드는 **한 축(좌우) 같이**, 새 패드 넣기 전 **피스톤 밀기**(02, car_spec 순서).

## 3. Wheel (바퀴·타이어) — 같은 "바퀴 이상"이 6갈래
| ID | 손님 말 | 단서 | 헷갈리는 짝 | 고친 뒤 | 근거 |
|---|---|---|---|---|---|
| TIRE_FLAT | "I think I've got a flat." / "펑크 난 것 같아요." | 게이지 낮음, 트레드에서 **못 찾기**(빼지 말 것) / 수리 가능 = **트레드 면 + 6 mm(1/4 in) 이하** → 타이어 떼서 안쪽 **플러그+패치 한 몸** | TIRE_BULGE(패치 X), 옆면 구멍(교체) | 공기압 라벨대로(캠리 35 psi) | 03 펑크 [5][6] |
| **NEW** TPMS_COLD (추위 함정) | "My tire light came on this morning!" / "오늘 아침 타이어 경고등이 켜졌어요!" | 기온 **10°F 떨어질 때마다 약 1 psi** 빠짐 → 네 바퀴 고르게 조금 낮음, 구멍 없음 / 미국 법: 라벨보다 **25 % 이상** 빠지면 경고 | TIRE_FLAT(한 바퀴만 많이 빠짐) | **공기만 채우기**(+ 토요타는 초기화) — 타이어 갈면 오진 | 03 ④ [21], 03 TPMS [20] |
| TIRE_BALD | "My tires feel slippery in the rain." / "비 오면 미끄러워요." | 트레드 **2/32 in(법)**, 4/32 in(빗길 안전) — 페니·쿼터 동전 / 홈 속 마모 표시 띠가 표면과 같음 | TIRE_UNEVEN(한쪽만 닳음) | 새 타이어 10/32 in | 03 ④ [2][10] |
| TIRE_UNEVEN / 편마모 갈래 | "The car pulls to one side." / "차가 한쪽으로 쏠려요." | **닳은 모양이 원인을 말함**: 가운데 = 공기 과다, 양 끝 = 부족, 한쪽 끝 = 캠버·토, 깃털 = 토, 컵 모양 = 쇼바·밸런스 | CALIPER_STICK(밟을 때만 쏠림), 허브 베어링 | 원인(얼라인먼트·쇼바) 고치고 타이어 — 원인 안 고치면 새 타이어도 같이 닳음 | 03 ⑤ [7][8] |
| WHEEL_IMBALANCE | "The steering wheel shakes on the highway." / "고속도로에서 핸들이 떨려요." | 림 안쪽 **밸런스 추 빠진 자국** / 밸런서 기계 | BRAKE_PULSE(밟을 때만), HUB_BEARING | 밸런서에서 추 붙이면 부드러움 | 03 밸런스, fault_catalog |
| **NEW** HUB_BEARING (허브 베어링) | "There's a humming noise that gets louder the faster I go." / "빨리 달릴수록 웅웅 소리가 커져요." | 소리가 **속도에 비례**하고 가속·감속엔 안 변함, **돌 때 변하거나** 어떤 속도에서 커짐 / 바퀴를 **12시·6시 잡고 흔들어** 헐거움(앞바퀴굴림 차는 0이 정상) / 매뉴얼: 다이얼 게이지 헐거움 **최대 0.05 mm** 넘으면 **허브 뭉치 교체** | 바깥 등속 조인트(돌 때만 딸깍), 타이어 소음, TIRE_UNEVEN | 소리 사라짐 + (토요타) 교체 뒤 얼라인먼트·센서 영점 보정 | [S1][S2] |
| TIRE_BULGE | "There's a weird bump on my tire." / "타이어에 혹이 났어요." | 옆면 혹 = 속 구조 끊어짐 (코드 겹친 자리의 오목한 자국은 정상) | 정상 오목 자국(함정) | 반드시 교체 | 03 ⑤ [7] |

## 4. Radiator (라디에이터) + 냉각 — 같은 "과열·김"이 5갈래
| ID | 손님 말 | 단서 | 헷갈리는 짝 | 고친 뒤 | 근거 |
|---|---|---|---|---|---|
| RAD_LEAK | "It's overheating and there's steam!" / "과열되고 김이 나요!" | 앞 바닥 웅덩이 — **색은 차마다**(Toyota 분홍·Honda 파랑·GM 주황·옛 초록), 단 냄새 / **압력 시험 103 kPa(15 psi): 바늘이 떨어지고 새는 자리 방울** | RAD_CAP, HOSE_SOFT | 냉각수 채우고 공기 빼기, 바늘 그대로 | 04 ⑤ [6][18][19][20][22] |
| RAD_FAN | "It only overheats in traffic." / "막히는 길에서만 과열돼요." | 서 있을 때 팬이 안 돎 / 토요타 의심 순서: **냉각수 온도 센서 → 릴레이 → 회로 → 팬 모터 → ECM**, 퓨즈 먼저 / 에어컨 켜면 팬이 돌아야 정상 | (짝 = 센서 vs 팬 모터) | 정차 중 팬 돎 | 04 팬 [13][14] |
| RAD_CLOG | "It overheats sometimes, but nothing is leaking." / "가끔 과열되는데 새는 건 없어요." | 앞 핀 막힘 — **콘덴서(라디에이터 앞)에 먼저** 쌓임 / 손전등+거울 | RAD_LEAK(웅덩이 없음) | 공기 0.4 MPa + 물안개로 **핀과 나란히** 청소 | 04 ⑤ [5] |
| **NEW** RAD_CAP (캡 불량) | "I keep adding coolant, but I never see a leak." / "냉각수를 계속 채우는데 새는 데가 안 보여요." | 새는 곳 없음 → **캡 시험**: 새 캡 74~103 kPa, 쓰던 캡 **59 kPa 미만이면 교체** | RAD_LEAK(압력 시험에서 방울 없음) | 캡만 교체 | 04 캡 [5][7] |
| **NEW** THERMO_OPEN (서모스탯 열린 채) | "My heater is weak and the temp gauge stays low." / "히터가 약하고 온도계가 낮게 있어요." | **P0128**, 위 호스가 늦게 데워짐 / 매뉴얼 검사: 80~84 °C에서 열리기 시작 | RAD 쪽 고장(이건 과열이 아니라 '안 데워짐') | 온도계 가운데, 히터 따뜻 | 04 서모스탯 [11][25] |
| **NEW** HOSE_SOFT (호스) | "There's a sweet smell and a little puddle." / "단 냄새가 나고 조금 고여요." | 호스 끝 **금속 이음에서 2 in 안쪽이 말랑**(전기화학적 열화), 스프링 클립 자리 | RAD_LEAK | 호스 + 클립 교체 | 04 호스 [31] |

## 5. Muffler (머플러) + 배기 — 같은 "차 밑 소리"가 5갈래
| ID | 손님 말 | 단서 | 헷갈리는 짝 | 고친 뒤 | 근거 |
|---|---|---|---|---|---|
| MUF_HOLE | "My car got really loud, like a race car." / "차가 경주차처럼 시끄러워졌어요." | 리프트 `Under`에서 녹 구멍, 시동 때 구멍에서 가스 | MUF_HANGER(소리 종류 다름) | 조용 | 08 머플러, fault_catalog |
| MUF_HANGER | "Something's rattling under the car." / "차 밑에서 덜그럭거려요." | **고무 걸이 끊김** → 머플러 처짐·흔들림 | MUF_HOLE(교체하면 오진), MUF_SHIELD | 걸이만 새로 | 08, fault_catalog |
| MUF_SHIELD | "It rattles only when I start it." / "시동 걸 때만 덜그럭거려요." | **열 차단판** 볼트 풀림 → 청진기·망치로 툭툭 | MUF_HANGER | 차단판 조이기 | 08 열 차단판 |
| TAILPIPE_VAPOR (정상 함정) | "White smoke comes out of my tailpipe in the morning!" / "아침에 꼬리관에서 흰 연기가 나와요!" | 추운 날 시동 직후 **옅은 흰 김**, 데워지면 사라짐 / 단 냄새 X | 진한 흰 연기 계속 = 냉각수(헤드개스킷) | **아무것도 안 바꿈** | 08 연기 [26] |
| **NEW** EXH_GASKET (새 개스킷 빠짐) | "It started puffing after the muffler job." / "머플러 갈고 나서 푸르륵 소리가 나요." | 이음 플랜지에 **개스킷 없음/헌 것 재사용** — 매뉴얼: 개스킷은 **재사용 불가** | MUF_HOLE | 새 개스킷 + 볼트 2(43 N·m) | diagrams/09·10 (removal-3524) |
| (짝) CAT_P0420 | "Check engine light and a rotten-egg smell." / "엔진 경고등이 켜지고 썩은 달걀 냄새가 나요." | **P0420**, 뒤 산소센서 그래프가 앞처럼 출렁 | 머플러 아님(촉매) | 원인(새는 곳·실화) 먼저 → 촉매 | 08 촉매 [23] |

## 6. Bumper_F / Bumper_R (범퍼) — 같은 "범퍼 문제"가 5갈래
| ID | 손님 말 | 단서 | 헷갈리는 짝 | 고친 뒤 | 근거 |
|---|---|---|---|---|---|
| BUMPER_HANGING | "My bumper is hanging off!" / "범퍼가 떨어지려 해요!" | 처진 쪽 **걸쇠(claw)·클립 부러짐** — 캠리 앞 범퍼 = 클립 9·나사 8·볼트 4·걸쇠 12 | BUMPER_GAP | 새 클립(싸고 빠름) | 11, diagrams/02 |
| BUMPER_GAP | "There's a gap between my bumper and headlight." / "범퍼랑 헤드라이트 사이가 벌어졌어요." | 옆 고정 브래킷(side retainer) 부러짐 | BUMPER_HANGING | 브래킷 교체 | fault_catalog, diagrams/03 |
| BODY_SCRATCH_LIGHT | "Can you fix this scratch on my bumper?" / "범퍼에 긁힌 것 좀 고쳐 줄래요?" | **손톱 테스트: 안 걸림** = 클리어 안 얕은 긁힘 | BODY_SCRATCH_DEEP | **광내기만**(칠하면 오진) | 11 [27] |
| BODY_SCRATCH_DEEP | 같은 말 | 손톱이 **콱 걸림**, 바닥이 회색·쇠색 | LIGHT | 샌딩 → 프라이머 → 색 → **클리어** → 광 | 11 [7]~[10] |
| **NEW** BUMPER_SENSOR (고친 뒤 함정) | "Since the bumper repair, my parking sensor beeps all the time." / "범퍼 고친 뒤로 주차 센서가 계속 삐삐거려요." | 범퍼 안 **초음파 센서 커넥터**를 안 꽂음 / 레이더 달린 차는 범퍼 수리 뒤 **레이더 조정** 필요(매뉴얼) | — | 커넥터 꽂기(+ 레이더 조정) | [S4], diagrams/02 |

## 7. Hood (보닛) — 3갈래
| ID | 손님 말 | 단서 | 헷갈리는 짝 | 고친 뒤 | 근거 |
|---|---|---|---|---|---|
| BODY_DENT | "Someone dented my hood in the parking lot." / "주차장에서 누가 보닛을 찌그러뜨렸어요." | 칠 살아 있는 작은 찌그러짐 = **PDR**(안에서 밀기), 칠 깨진 큰 것 = 판금·퍼티·도색 | BODY_SCRATCH | 반듯 | 11 찌그러짐 |
| **NEW** HOOD_ALIGN (틈 안 맞음) | "My hood sits crooked." / "보닛이 삐뚤게 닫혀요." | 펜더와 틈이 한쪽만 넓음 — 매뉴얼 기준 틈 **2.8~6.8 mm** 등 → **경첩 볼트 4개 풀고 맞춘 뒤 13 N·m** | BODY_DENT | 틈 고르게 | diagrams/index(보닛, adjustment-4142) |
| HOOD_LATCH | "My hood won't stay closed." / "보닛이 안 닫혀요." | 닫으면 튕겨 올라옴 — 잠금장치(hood lock)는 **보닛이 아니라 라디에이터 위 지지대**에 있고 운전석 레버 → 케이블 | HOOD_ALIGN | 잠금장치 손질·교체 (원인 순위 출처는 확인 못 함) | diagrams/index(보닛) |

---

## 설계에 쓸 규칙 (사실에서 나온 것)
1. **같은 말, 다른 원인**: "시동이 안 걸려요"(배터리 5갈래), "끼익"(패드 2 + 소음), "쏠려요"(편마모·캘리퍼·베어링), "덜그럭"(걸이·차단판·구멍) — 손님 말 한 줄에 원인 2~3개.
2. **숫자 하나가 갈라 줌**: 쉬는 전압 / 시동 중 전압 / 키 끈 전류 / 패드 mm / 디스크 mm / psi·기온 / 압력 바늘 / 캡 kPa / 헐거움 0.05 mm.
3. **'아무것도 안 바꾸는' 정답**이 실제로 있음: TAILPIPE_VAPOR, TPMS_COLD(공기만), BODY_SCRATCH_LIGHT(광만), PAD_NOISY(심만), RAD_CAP(캡만).
4. **고친 뒤 생기는 일**도 실제: 범퍼 센서 커넥터·레이더 조정, 개스킷 재사용, 스트럿·허브 교체 뒤 얼라인먼트·영점 보정.

## 새로 연 출처
- [S1] Toyota Camry XV70 Repair Manual — Front Axle Hub On-vehicle Inspection (헐거움 최대 0.05 mm, 넘으면 허브 뭉치 교체; 허브 뭉치·너클·**front disc brake dust cover** 부품표 components-2868, 교체 뒤 얼라인먼트·보정 removal-2870) — https://www.tocamry.com/on_vehicle_inspection-2869.html
- [S2] AA1Car — Wheel Bearing & Seal Replacement (소리는 속도에 비례·가속/감속엔 안 변함·돌 때 변함, 12·6시 흔들기, FWD는 헐거움 0, 바깥 CV는 돌 때만) — https://www.aa1car.com/library/2003/bf70348.htm
- [S3] AA1Car — Brake Calipers (피스톤 고착·슬라이드 걸림 → 한쪽 쏠림·끌림, 패드 고르지 않은 마모면 핀·부싱 점검, 녹이 플로팅 캘리퍼를 붙게 함) — https://www.aa1car.com/library/brake_calipers.htm ; 쏠림 방향(밟을 때 좋은 쪽, 끌릴 때 나쁜 쪽)은 검색 요약 문장 — 같은 페이지
- [S4] Toyota Camry XV70 Repair Manual — Front Bumper Removal (레이더·주차센서 커넥터, 범퍼 수리 뒤 레이더 조정 필요) — https://www.tocamry.com/removal-4188.html
- 그 밖의 숫자는 각 시스템 파일(01·02·03·04·08·11, diagrams/index)의 출처 번호를 따라가요.
