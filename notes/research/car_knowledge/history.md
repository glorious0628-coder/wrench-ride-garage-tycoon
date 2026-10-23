# 자동차 역사 노트 (history.md) — 1886 ~ 지금, wr-carbook, 2026-10-20

> 목적: `docs/design/era_cars.md`(시대별 희귀 차)의 **사실 근거**. 초안 = `notes/gpt/wr-design/era_mine.md`.
> 규칙: 모든 줄 끝 [n] = 맨 아래 출처(실제로 열어 본 페이지만). 출처끼리 다르면 "출처마다 다름", 못 찾으면 "(확인 못 함)".
> 게임에는 실제 브랜드·로고·얼굴을 쓰지 않아요. 여기 이름(Benz, Ford…)은 **참고용 진짜 차**예요. 디자인은 특징을 섞어 오리지널로.
> 단위: 길이 mm, 무게 kg(공차 중량, curb weight). in/lb만 있는 건 제가 환산(1 in = 25.4 mm, 1 lb = 0.454 kg).

---

## 1. 한눈에 — 기술이 바뀐 해 (타임라인 표)

### 1-1. 시동 걸기 (Starting)
| 해 | 무엇 | 쉬운 설명 | 출처 |
|---|---|---|---|
| 1886 | 플라이휠 손으로 돌리기 | Benz 첫 차는 **뒤에 누운 큰 플라이휠을 힘껏 돌려서** 시동 | [1] |
| ~1900s–1910s | 손 크랭크(hand crank) | 앞에 꽂은 손잡이를 돌림. 되튕김(kickback)으로 엄지·손목·어깨 부상 | [15][100] |
| 1912 | 전기 셀프 스타터(electric self-starter) | **Cadillac Model Thirty**에 처음. Kettering·Leland 특허. Dewar Trophy 받음 | [15][16] |
| 1919 | Model T도 전기 시동 옵션 | 그 전까지 Model T는 크랭크만 | [14][15] |
| 1920s | 전기 시동이 거의 모든 새 차에 | 여성·노인도 운전하기 쉬워짐 | [15] |
| ~1949 전 | 바닥/계기판 **버튼**·페달로 시동 | 키는 점화만, 시동은 따로 누름 | [15] |
| 1949 | **키 돌려서 점화+시동**(Chrysler) | 오늘날 '키 시동'의 시작 | [15] |
| 1999 | 스마트키 + 버튼 시동(Mercedes KEYLESS GO, S-Class) | 출처마다 1998/1999 — Mercedes 쪽 글은 1999 | [69] |

### 1-2. 점화 (Ignition — 불꽃 만들기)
| 해 | 무엇 | 쉬운 설명 | 출처 |
|---|---|---|---|
| 1883–1897 | **핫튜브(hot tube)** — Daimler | 실린더에 붙은 관을 **버너 불꽃으로 빨갛게 달궈** 압축된 연료에 불이 붙게 함. 전기 X | [3][4][6] |
| 1886 | **배터리 + 트렘블러 코일(trembler coil)** — Benz | Benz는 처음부터 **전기 불꽃**. 발전기(dynamo)를 쓰다 곧 배터리로 바꿈 | [1][17] |
| 1897 | Daimler도 Bosch 전기 점화로 바꿈 | 핫튜브 끝 | [6] |
| 1900–1901 | **마그네토(magneto)** — Bosch 고압 마그네토 | 배터리 없이 엔진이 돌면 스스로 전기 만듦. 첫 차 = 1901 Mercedes 35 hp 경주차 | [18] |
| 1908 | Model T: 플라이휠 저압 마그네토 + 트렘블러 코일 4개 | 손으로 잘 돌리면 시동용 배터리 필요 없음 | [14][17] |
| 1912 | **포인트(breaker points) + 콘덴서 + 배전기(distributor) + 코일 1개** — Kettering의 Delco, Cadillac | 이후 약 60년 동안의 표준 | [17][19] |
| 1963 | 포인트 없는 전자 점화 첫 옵션(Pontiac) | | [17] |
| 1968 | 전자 점화 표준인 첫 양산차(Fiat Dino) | | [17] |
| 1973 / 1975 | 전자 점화 표준: Chrysler 1973, Ford·GM 1975 | 미국 차에서 포인트가 사라짐 | [17] |
| (연도 확인 못 함) | **배전기 없는 점화(distributorless, wasted spark)** | 코일 1개가 360° 떨어진 실린더 2개를 동시에 점화 | [17] |
| 1990s~ | **코일-온-플러그(coil-on-plug)** 널리 퍼짐 | 플러그마다 코일 1개 | [17] |

### 1-3. 연료 공급 (Fuel delivery)
| 해 | 무엇 | 쉬운 설명 | 출처 |
|---|---|---|---|
| 1885–1886 | **표면 기화기(surface carburettor)** — Benz | 연료 통을 **배기열로 데워** 증발시킨 김을 빨아들임. 연료는 리그로인(ligroin) | [1] |
| 1885 | **플로트 기화기(float-fed)** — Daimler·Maybach 괘종시계 엔진 | 뜨개(float)로 연료 높이를 맞춤 | [4][20] |
| 1892–1893 | Maybach 분사 노즐(jet) + 벤투리 기화기 | 이후 기화기의 기본형 | [20] |
| 1952 | **4배럴(four-barrel) 기화기** (Carter WCFB, Rochester 4GC) GM 차에 | 큰 V8 시대 | [20] |
| 1955 / 1957 | 기계식 직분사 Mercedes 300SL(1955) / Chevrolet 기계식 포트 분사(1957, Corvette 등) | 비싼 옵션 | [21][77] |
| 1967 | Bosch D-Jetronic 전자 분사(VW 1600TL/E) | | [21] |
| 1980–1995 | **스로틀바디 분사(TBI, single-point)** 미국 차에 많이 | 기화기 자리에 인젝터 1~2개 | [21] |
| 1980년대 말~1990년대 초 | 기화기 → 연료 분사로 거의 다 바뀜 | | [20][21] |
| 1994 | **미국에서 새로 팔린 마지막 기화기 차 = 1994 Isuzu Pickup(기본 2.3 L)** | 승용차로는 1991 Ford Crown Victoria(경찰·법인용 5.8 L)·1991 Jeep Grand Wagoneer가 후보. 1990 Subaru Justy 설은 이 출처에 없음 | [22] |
| 1997 | **가솔린 직분사(GDI)** 첫 양산 승용 — Mitsubishi 6G74 | (질문지의 1996은 이 출처에선 1997) | [21] |
| 2010s~ | 많은 가솔린 엔진이 직분사로 | | [21] |

### 1-4. 냉각 (Cooling)
| 해 | 무엇 | 쉬운 설명 | 출처 |
|---|---|---|---|
| 1886 | **증발 냉각(evaporative)** — Benz | 물이 끓어 날아가서 계속 채워야 함 | [1][2] |
| 1885 | **공랭(air-cooled)** — Daimler Reitwagen | | [4] |
| 초기~ | **열사이펀(thermosiphon)** — 펌프 없이 뜨거운 물이 저절로 올라가 도는 방식 | 공회전·저속에서 과열, 냉각수 조금만 모자라도 큰 문제 | [23][24] |
| 1908~ | Model T: 첫 2,447대만 워터펌프, 그 뒤는 열사이펀(펌프 없음) | | [14] |
| (연도 확인 못 함) | **벌집 라디에이터(honeycomb)** — Maybach, Mercedes 35 hp | 자동차 물 라디에이터 발명 자체는 Benz로 돌림 | [24] |
| ~ | 엔진 힘이 커지며 **원심 워터펌프** 추가 → 결국 펌프만으로 | | [23][24] |
| 2차대전 전 | 냉각수 = 대개 **그냥 물** (부동액은 얼지 않게 할 때만) | | [24] |
| 1938~2003 | 공랭 뒤 엔진의 대표 — VW Beetle(1938–2003), VW Type 2 버스 T1·T2 | 라디에이터 없음 | [73][84] |
| 지금 | 라디에이터 = 알루미늄 코어 + 플라스틱 탱크(옛날은 놋쇠·구리) | 더 잘 깨지고 고치기 어려움 | [24] |
| 지금(EV) | **전기차도 냉각수·펌프·라디에이터로 배터리·모터를 식힘** | ← 초안 수정 포인트 | [24][65] |

### 1-5. 브레이크 (Brakes)
| 해 | 무엇 | 쉬운 설명 | 출처 |
|---|---|---|---|
| 1886 | Benz Nr.1: 가운데 축에 **강철 밴드 브레이크**. Nr.2부터: **나무 블록**이 뒷바퀴 쇠 테두리를 직접 누름 | 1888 Bertha Benz가 구두장이에게 **가죽**을 덧대게 함 = 첫 브레이크 라이닝 | [1][2] |
| 1900 / 1902 | **드럼 브레이크** 첫 차 = Maybach(1900), 특허 = Louis Renault(1902) | 처음엔 **막대·케이블(기계식)** 으로 슈를 벌림 | [28] |
| 1908~ | Model T: 오른쪽 페달 = **변속기 브레이크**, 주차 브레이크 = 뒷바퀴 드럼. 바퀴에 상용 브레이크 없음 | | [14] |
| 1917 | Malcolm Loughead(Lockheed) 유압 브레이크 특허 | | [25] |
| 1921 | **Duesenberg Model A** — 유압 브레이크 첫 사용 | | [25][26] |
| 1924 | **Chrysler** — 유압 사륜 브레이크 채택 | Chrysler 역사 글은 "처음 실용적으로 대량생산된 사륜 유압" 이라 표현 | [26][27] |
| 1936 | GM·Chevrolet 유압 전면 채택 | | [26] |
| 1939 | **Ford**가 마침내 유압 ("pedal부터 바퀴까지 강철" 광고하던 기계식 고집 끝) | | [26] |
| 1950s | **자동 조정(self-adjusting) 드럼** 등장 | 그 전엔 손으로 주기적 조정 | [28] |
| 1902 | 디스크 브레이크 첫 특허(Lanchester, 구리 패드) | | [29] |
| 1953 | Jaguar C-Type Le Mans 우승 — Dunlop 디스크(그 경주 유일) | | [29] |
| 1955 | **Citroën DS** — 현대식 디스크 첫 지속 양산(앞 인보드) | | [29] |
| 1963 | Studebaker Avanti — 미국 차 앞 디스크 기본 | | [29] |
| 1967 | 미국 FMVSS 105 — **마스터 실린더 2회로(dual circuit)** 의무 | | [25] |
| 1970s 말~80s 초 | 미국 차 대부분 앞 드럼 → **앞 디스크** | | [29] |
| 1971 | Chrysler·Bendix "Sure Brake" — 컴퓨터식 4센서 ABS (1971 Imperial) | | [30] |
| 1978 | **Bosch 전자식 4륜 다채널 ABS** — Mercedes W116 옵션 ("첫 무리 중 하나") | | [30] |
| 2003 / 2012 | ABS 의무: EU 2003, 미국은 ESC 규정(FMVSS 126)과 함께 2012-09-01 | | [30] |
| 1967 / 1997~ | **회생 제동(regenerative)**: 자동 제어는 1967 AMC Amitron부터, 하이브리드·EV에서 일상화 | 브레이크 패드가 훨씬 덜 닳음 | [31][65] |

### 1-6. 타이어·바퀴 (Tires / wheels)
| 해 | 무엇 | 출처 |
|---|---|---|
| ~1886 | 마차식 **나무 바퀴 + 쇠 테두리(iron tyre)** / Benz Nr.1은 **철사 바퀴 + 통고무(solid rubber)** | [1][32] |
| 1888 | Dunlop 첫 실용 공기 타이어(pneumatic, 자전거) | [32] |
| 1895 | Michelin 첫 자동차용 공기 타이어 (L'Éclair, Paris–Bordeaux–Paris) | [32] |
| ~1950s까지 | **바이어스(bias-ply, 대각선 겹)** 타이어가 미국 표준 | [32][33] |
| 1900s–1920s / 1934 | 초기 타이어는 천연고무라 **하얬음** → 카본블랙 넣어 검게(더 질김). 1934-04-06 Ford 화이트월 옵션 → 1930s~50s 초 전성기 → 1962년형쯤 넓은 화이트월 퇴장, 1970s 가는 줄, ~1980s 중반까지 | [35] |
| 1946 / 1948 | **Michelin X 레이디얼(radial)** 개발 1946 → 1948 Citroën 2CV 기본 (질문지의 1949는 이 출처에선 1948) | [33] |
| 1947 / 1955 | **튜브리스(tubeless)**: Goodrich(Herzegh 1946 출원, 1952 특허) → 1955년엔 새 차 기본 | [34] |
| 1970 | 미국 첫 레이디얼 기본 차 = Continental Mark III | [33] |
| 1976 vs 1980s | 미국 레이디얼 100%: "1976년엔 표준"(Radial tire) vs "1980년대에 100%"(Tire) — **출처마다 다름** | [32][33] |

### 1-7. 등불 (Lights)
| 해 | 무엇 | 출처 |
|---|---|---|
| 1880s 말~ | 초 / 기름 / 아세틸렌 가스등 | [36] |
| ~1910s | **카바이드 램프**: 위 통의 물을 아래 칼슘카바이드에 떨어뜨려 아세틸렌 가스 → 불꽃. 물 양 = 불 크기. 다 쓴 건 젖은 석회 반죽 → 비우고 다시 채움 | [38] |
| 1898 | 첫 전기 헤드램프(Columbia Electric Car, 옵션) | [36] |
| 1908 | Peerless 전기 헤드램프 기본 | [36] |
| 1912 | Cadillac Delco 점화+조명 통합 = 현대 전기 계통의 바탕 | [36] |
| 1915 | Model T 마그네토 전기등(그 전은 아세틸렌 카바이드) | [14] |
| 1924 / 1927 | 상·하향 한 전구(Bilux) / 발로 밟는 하향 스위치 | [36] |
| 1936 | **숨은 헤드램프** 첫 = Cord 810/812 (손 크랭크로 올림) | [36][37] |
| 1940–1983 | 미국 **실드빔(sealed beam)** 의무: 1940 7인치 둥근 것 → 1957 5.75인치 2개씩(쿼드) 허용 → 1974 네모 허용 → 1979 할로겐 실드빔 → 1983 전구 교체식 허용(1984 Lincoln Mark VII) | [36] |
| 1962 | 할로겐 H1 (유럽) | [36] |
| 1962 | 전동 팝업 첫 양산 = Lotus Elan | [37] |
| 1991–1992 | HID(제논) — BMW 7 Series, 첫 양산 하향 HID 1992 | [36] |
| 2004 | **팝업 헤드램프 끝** — Lotus Esprit·Corvette C5 단종 | [37][39] |
| 2007 / 2008 | LED: Lexus LS600h 출시(2007) → Audi R8 첫 '전부 LED' 헤드램프(2008 예정 기사) | [41] |

### 1-8. 전기 (Electrical)
| 해 | 무엇 | 출처 |
|---|---|---|
| ~1960 | **직류 발전기(dynamo / generator, 정류자 commutator)** | [42] |
| 1953 → 1955/56 | **6 V → 12 V**: GM이 1953 Cadillac·Buick·Oldsmobile부터. Jalopnik은 "1955년까지 미국 전 회사" — 다른 기록(Ford·Chrysler 1956, VW Beetle 1968)도 있어 **출처마다 다름** | [43][73] |
| 1960 | **알터네이터(alternator)** 기본 첫 양산차 = Chrysler Valiant (공회전에서도 충전됨) | [27][42] |

### 1-9. 변속기·구동 (Transmission / drivetrain)
| 해 | 무엇 | 출처 |
|---|---|---|
| 1886 | Benz: **벨트** → 가운데 축(차동기어) → **롤러 체인 2개**로 뒷바퀴. 후진 없음 | [1] |
| 1891 | **Système Panhard**: 앞 엔진·뒷바퀴 굴림·클러치·**미끄럼 기어(sliding-gear) 변속기** = 이후 거의 100년 표준 | [9][45] |
| 1894 | 핸들 바퀴(steering wheel) 초기 사용 — Paris–Rouen, Vacheron의 Panhard (공장 표준 아님) | [9] |
| 1901–1907 | Curved Dash: 2단 **유성기어(planetary)** + 체인 1개 + 막대 조향(tiller) | [10][13] |
| 1908–1927 | Model T: 유성기어 2단+후진, **페달 3개 + 밴드(band)** | [14] |
| 1928/1929 | **싱크로메시(synchromesh)** 첫 양산 Cadillac (출처 안에서도 1928·1929 둘 다) — 그 전은 '크래시 박스', 더블 클러치 필요 | [45] |
| 1940 | **Hydra-Matic** 첫 대량생산 완전 자동변속기(1940년형 Oldsmobile, 1939-10 출고), 유체 커플링 + 유성기어 3세트 = 4단 | [44] |
| 1934 | Citroën Traction Avant: 대량생산 **앞바퀴 굴림 + 일체형 차체** | [72] |
| 1959 | **Mini**: 엔진 **가로 배치 + 변속기가 오일팬 안** + 앞바퀴 굴림 → 바닥의 약 80%가 사람·짐 | [47] |
| 1958 | **CVT** 첫 양산 = DAF 600 Variomatic. 1987 Subaru Justy ECVT(첫 전자제어 강철벨트 CVT) | [46] |

### 1-10. 차체 (Body)
| 해 | 무엇 | 출처 |
|---|---|---|
| 1886 | Benz: **강철 파이프 뼈대 + 나무 판 바닥** | [1] |
| ~1930s | 거의 모든 차 = **따로 된 프레임 위에 차체(body-on-frame)** | [48] |
| 1910 | Cadillac Model Thirty — 미국 회사 첫 **닫힌 차체(closed body)** 옵션 | [16] |
| 1922 | 일체형(unitary) 첫 시도 = Lancia Lambda | [48] |
| 1927–1931 | Ford Model A: 앞유리 **안전유리** 초기 채택 | [70] |
| 1934 | Chrysler Airflow(강철 차체, 엔진을 앞바퀴 위로) / Citroën Traction Avant(용접 일체형, 발판 필요 없음) | [48][71][72] |
| 1929 | 발판(running board) 없이 설계된 첫 차 = Ruxton | [80] |
| 1930s~40s | 진짜 **나무 차체 왜건(woodie)**. 1950 Chrysler가 나무 왜건 끝 → 이후 강철 + **나무무늬 비닐(DI-NOC)** | [85] |
| 1960 | Big Three 소형차 일체형, Chrysler 대부분 차종 일체형 | [48] |

### 1-11. 안전·전자 (Safety / electronics)
| 해 | 무엇 | 출처 |
|---|---|---|
| 1949 / 1958 | 안전벨트: Nash 옵션(1949, 안 팔림) / Saab 기본(1958) | [49] |
| 1959 | **Volvo 3점식 벨트**(Nils Bohlin), PV544, 특허 공개 | [49] |
| 1968 | 미국 FMVSS 208 — 어깨 벨트 의무 | [49] |
| 1973 | GM 에어백(ACRS) — 1973 Oldsmobile Toronado, 1977 중단 | [52] |
| 1975 | **촉매 변환기** 미국 1975년형부터 거의 모든 가솔린차 → **무연 휘발유만**(납이 촉매를 망침). 1981~ 3원 촉매 | [50][88] |
| 1980 / 1988 | GM 첫 데이터 링크(1980 Eldorado·Seville) / California OBD-I(1988) | [51] |
| 1981 / 1988 | 에어백: Mercedes S-Class 옵션(1981) / Chrysler 운전석 기본(1988, 미국 첫) | [52] |
| 1995 | ESC 첫 = Mercedes S 600 Coupé(C140), Bosch | [54] |
| **1996** | **OBD-II 의무**(미국 승용차·8,500 lb 이하 가솔린 경트럭). 단자 = 핸들에서 2 ft(61 cm) 안 | [51] |
| 1998-09-01 이후 생산 | 미국 운전석+조수석 에어백 의무(ISTEA 1991) | [52] |
| 2001 | 유럽 EOBD | [51] |
| 2005-10 → 2007-09 | **TPMS**: TREAD Act(2000) → FMVSS 138, 2007년 9월 이후 생산 100% | [53] |
| 2012년형 | **ESC 의무**(FMVSS 126), EU 2014-11 | [54] |
| 2018-05-01 | **후방 카메라** 의무(FMVSS 111 'Rear Visibility', 10,000 lb 이하, 차 뒤 10×20 ft 보이기) | [55] |

### 1-12. 하이브리드·전기차 (Hybrid / EV)
| 해 | 무엇 | 출처 |
|---|---|---|
| 1897 | 뉴욕 전기 택시 12대(나중 62대) | [56] |
| ~1900 | **미국 차의 40% 증기, 38% 전기, 22% 휘발유** — 전기차 흔했음! | [56] |
| 1912 | 전기 스타터 + Ford 대량생산 → 전기차 몰락 (1912년 전기차 값 ≈ 휘발유차 2배) | [56] |
| 1996–1999 | GM **EV1**: 리스만, 1,117대, 납축→NiMH, Cd 0.19, 2003–2004 회수 후 대부분 폐차(crush) | [60] |
| 1997-12 | **Toyota Prius**(일본) — 세계 첫 대량생산 하이브리드. 세계 판매 2000-09, 미국 2001년형부터 | [57] |
| 1999-12 | **Honda Insight** — 북미 첫 하이브리드 | [59] |
| 2008 | Tesla Roadster 인도(첫 320 km+ 양산 EV) | [56] |
| 2010-12 | **Nissan Leaf**(일본·미국) | [56][61] |
| 2012-06 | **Tesla Model S** | [56][62] |

---

## 2. 시대별 — 무엇이 바뀌었나 · 그때 정비사 · 대표 진짜 차

> 각 차 ▶ = **캐주얼 오리지널 디자인 때 '읽히게' 할 특징**(브랜드 얼굴 베끼기 X, 시대 느낌만).

### 시대 1. 1885–1900 — "말 없는 마차" (horseless carriage)
**바뀐 것**: 엔진 달린 첫 차들. 증발 냉각, 벨트·체인, 핫튜브 vs 전기 점화의 두 갈래 [1][3][6]. 1891 Panhard가 '앞 엔진·뒷바퀴 굴림·클러치·기어' 배치를 만듦 [9]. 1895 첫 자동차 공기 타이어 [32]. ~1900 미국 차의 38%가 전기차 [56].
**그때 정비사**: '정비소'가 따로 없었음. 1888 Bertha Benz 여행: 연료(리그로인)는 **약국**(Wiesloch Stadt-Apotheke)에서 삼, 막힌 연료관은 **모자핀**으로 뚫음, 전선 피복은 **가터**로 감쌈, 체인은 **대장장이**가 고침, 브레이크는 **구두장이**가 가죽을 붙임, 멈출 때마다 물 보충 [2]. 언덕에선 아들들이 밀었고, 돌아와서 "언덕용 낮은 기어 + 더 좋은 브레이크 라이닝"을 제안 [2].
**대표 차**
- **Benz Patent-Motorwagen (1885 첫 주행 / 1886-01-29 특허)** — 세발, 뒤 1기통 4행정(약 954 cc, 0.68 PS @400 rpm, 출처마다 다름), 뒤에 누운 **수평 플라이휠**(Nr.2는 뒷바퀴 뒤로 살짝 튀어나옴), 강철 파이프 뼈대·나무 바닥, 2,700×1,400×1,450 mm, 270 kg(Model 2는 360 kg), 약 16 km/h(Model 2) [1]. 조향 = 기둥 위 **손잡이 레버**가 랙·피니언을 돌려 앞바퀴 1개를 꺾음 [1]. 시동 = 플라이휠 손으로 돌리기 [1].
  ▶ 세발 + 뒤에 드러난 엔진·누운 플라이휠 + 높은 의자 + 철사(또는 나무) 큰 뒷바퀴 + 기둥 손잡이.
- **Daimler Motorkutsche (Motorized Carriage, 1886 공개)** — **사서 개조한 마차(stagecoach)**에 Daimler·Maybach '괘종시계(Standuhr) 엔진' 462 cc 1기통, 1.1 PS @600 rpm, 290 kg, 최고 약 16 km/h(첫 네바퀴로 16 km/h) [5][6]. 점화 = 핫튜브(같은 엔진 계열의 Reitwagen 기록, 1897까지 Daimler는 핫튜브) [4][6].
  ▶ 네바퀴 마차 몸통 + 가운데 세운 원통 엔진 + 핫튜브 버너 불.
- **Panhard et Levassor (1891)** — 앞 엔진·뒷바퀴 굴림·미끄럼 기어 변속기, 3,500 프랑. Daimler 엔진 라이선스(1890~) [6][9]. 1894 경주차에 초기 핸들 바퀴 [9].
  ▶ 앞에 상자형 엔진 덮개 + 그 뒤 마차 의자 = '자동차 모양'의 시작.
- **Duryea Motor Wagon (1893-09-21, Springfield MA)** — 미국 초기 휘발유차, 1기통 4 hp, 저압 점화, 마찰식 변속기(나중 기어식으로 교체), 바퀴 54 in(1,372 mm), 1895 Chicago Times-Herald 경주 우승(54 mi, 평균 7.5 mph), 1893–1896 15대 [7][8].
  ▶ 큰 마차 바퀴 4개 + 바닥 아래 누운 엔진 + 마차 의자.
- (참고) **Columbia Electric (1898)** — 첫 전기 헤드램프 옵션 [36]. 이 시대 미국 차 38%가 전기차였다는 점 [56] → '조용한 전기 마차'도 이 시대 희귀 차 후보.

### 시대 2. 1901–1918 — 놋쇠 시대 (Brass Era: 1896–1915)
**바뀐 것**: 'Brass Era'는 미국 말로 **1896–1915**, 등불·라디에이터의 놋쇠 장식에서 온 이름. 1915 = Model T가 놋쇠 장식을 단 마지막 해 [99]. 첫 대량생산(Curved Dash 1901), 조립 라인 대중차(Model T 1908) [10][14]. 1912 전기 스타터·Delco 점화·조명 [15][16][36]. 1900 드럼 브레이크, 1901 마그네토 [18][28].
**그때 정비사**: 손 크랭크 되튕김 부상('chauffeur's fracture') [100], 카바이드 램프 채우기 [38], Model T 밴드 조정 [14], 열사이펀 과열 [23], Curved Dash는 **기화기를 자주 맞춰야 해서** 달리면서 조절하는 차도 있었음 [12].
**대표 차**
- **Oldsmobile Curved Dash (1901–1907)** — 휘어 올라간 앞판, 의자 밑 **수평 1기통**(95 cu in ≈ 1.56 L, 4.5 hp @600 rpm — 출처마다 4/4.5/5/7 hp), 2단 유성기어, **체인 1개**, **가운데 막대 조향(tiller)**, $650, The Henry Ford 기록 길이 97 in(2,464 mm)·폭 62 in(1,575 mm)·높이 56 in(1,422 mm)·295 kg(650 lb; Wikipedia는 390 kg — 다름), 최고 32 km/h, 1902–1905 미국 최다 판매, 19,000대 이상 [10][11][12][13].
  ▶ 썰매처럼 말린 앞판 + 마차 의자 + 막대 핸들 + 가는 바퀴살.
- **Ford Model T (1908–1927)** — 2.9 L 직렬 4기통 20 hp, 68 km/h, 휠베이스 2,540 mm, 540–750 kg, 나무 포병식(artillery) 바퀴, 유성기어 + 페달 3개, 플라이휠 마그네토 + 트렘블러 코일, 열사이펀(초기 2,447대 빼고 펌프 없음), 연료탱크는 앞좌석 밑, 1915 전까지 아세틸렌 등, 1919부터 전기 시동, 1,500만 대 이상, 검은색만은 1914–1925쯤 [14].
  ▶ 높고 각진 차체 + 앞에 선 라디에이터(1915 전엔 놋쇠) + 큰 등 2개 + 앞 크랭크 손잡이 + 접는 천 지붕.
- **Cadillac Model Thirty (1909-12~1914)** — L-head 4기통 3.7 L→6.0 L, 1910 미국 첫 닫힌 차체 옵션, **1912 첫 전기 스타터 양산차**(Dewar Trophy) [16].
  ▶ Model T보다 크고 긴 고급 투어러, 크랭크 손잡이 없는(또는 숨은) 앞.
**이 시대 경계 주의**: 1916–1927 차는 놋쇠가 빠지고 검은 칠 → 'Brass-Era' 이름은 1915까지만 맞음 [99].

### 시대 3. 1919–1940 — 닫힌 강철 세단·발판 시대
**바뀐 것**: 1920s 전기 시동 거의 모든 차 [15]. 유압 브레이크 Duesenberg 1921 → Chrysler 1924 → GM 1936 → Ford 1939 [25][26]. 싱크로메시 1928/29 [45]. 1927 발로 밟는 하향등 스위치 [36]. 1934 유선형(Airflow)·일체형·앞바퀴굴림(Traction Avant) [71][72]. 1936 숨은 헤드램프(Cord) [37]. 1940 실드빔·Hydra-Matic [36][44]. 뒤로 열리는 문(rear-hinged, 'suicide door')은 20세기 전반 흔했음 [78][79].
**그때 정비사**: 포인트(접점) 마모·조정(Kettering 방식, 1912~) [17][19], 기계식 브레이크 막대·케이블 조정(Ford는 1938년형까지) [26][28], 크래시 박스라 더블 클러치 [45], 냉각수가 그냥 물이라 겨울엔 동파 걱정(부동액은 얼지 않게 할 때만) [24], 6 V 계통 [43].
**대표 차**
- **Ford Model A (1927-10 ~ 1932-03)** — 3.3 L L-head 4기통 40 hp, 약 105 km/h, 3단 비동기 미끄럼 기어, **사륜 기계식 드럼**, **카울(앞유리 앞) 연료탱크 → 중력으로 기화기**, 앞유리 안전유리, 길이 165 in(4,191 mm)·폭 67 in(1,702 mm)·휠베이스 103.5 in, 1,027–1,118 kg, 4,858,644대, $385~ [70]. (시동·점화 방식은 이 출처에 없음 — 확인 못 함.)
  ▶ 세로 그릴 + 따로 선 둥근 등 2개 + 흙받이(fender) 곡선 + 발판.
- **Chrysler Airflow (1934–1937)** — 풍동 실험(50개 이상 모형), **엔진을 앞바퀴 위로**(앞 54%), 강철 일체형에 가까운 차체, 앞으로 흘러내리는 '폭포(waterfall) 그릴', 직렬 8기통 4.9–5.3 L, 휠베이스 3,137–3,721 mm, 29,600대 미만 — 너무 앞서 가서 실패 [71].
  ▶ 둥근 이마 + 몸에 묻힌 등 + 둥근 뒤 = '유선형 실패작'의 귀여움.
- **Citroën Traction Avant (1934–1957)** — 대량생산 **앞바퀴굴림 + 용접 일체형**, 앞 토션바 독립 서스펜션, 유압 브레이크, **낮아서 발판이 필요 없음**, 4,450–4,960×1,620–1,790×1,520–1,580 mm, 1,025–1,170 kg, 759,111대, 뒷문은 뒤에 경첩 [72][78].
  ▶ 낮고 긴 검은 세단 + 큰 곡선 흙받이 + 발판 없음.
- (참고) **Cord 810 (1936)** — 숨은 헤드램프 첫 차, 계기판 양옆 손 크랭크로 올림 [37].

### 시대 4. 1941–1959 — 전쟁 지프 → 전후 크롬·꼬리날개(fins)
**바뀐 것**: 1940–42 Hydra-Matic 약 20만 대 [44]. 1949 키 시동 [15], 1949 Nash 안전벨트 옵션 [49]. 1948 Cadillac 작은 꼬리날개 → 1955–1961 전성기 → 1959 Eldorado가 가장 극단 [76]. 1952 4배럴 기화기 [20]. 1953–56 12 V [43]. 1955 튜브리스 기본 [34]. 1957 쿼드(5.75인치×4) 헤드램프 허용 [36]. 1950s 자동 조정 드럼 [28]. 넓은 화이트월은 1950s 초 정점 [35]. 1959 Mini·Volvo 3점 벨트 [47][49].
**그때 정비사**: 발전기(제너레이터) — 공회전 충전이 약함(알터네이터는 공회전에도 충전 → 1960~ 교체) [42], 6 V 차 뜨거울 때 시동 안 걸림(고압축 V8엔 힘 부족) [43], 기화기 공회전 혼합비 나사 [106], 드럼 브레이크 별바퀴 조정 [108], 포인트·드웰 [103][104].
**대표 차**
- **Willys MB / Ford GPW (1941–1945)** — 2.2 L 'Go Devil' 4기통 60 hp, 4륜구동 + 2단 트랜스퍼, **앞으로 접히는 앞유리**, 세로 홈 9개 찍어낸 강철 그릴(Ford가 만들고 Willys가 25,808호부터 따라함), 3,350×1,570×1,770 mm(유리 접으면 1,320), 1,113 kg, 105 km/h, 64만 대 이상 [74].
  ▶ 상자 몸통 + 세로 홈 그릴 + 둥근 등 2개 + 접힌 앞유리 + 옆에 단 예비 바퀴(옆 위치는 확인 못 함).
- **Chevrolet Bel Air (1957)** — 1957 Chevy 꼬리날개(뒤를 넓어 보이게), 크롬 헤드램프 테, 금색 알루미늄 장식, 283 cu in V8 **연료분사 283 hp**(GM 첫 '1 cu in당 1 hp'), 기본은 직렬 6 'Blue Flame', 2단 Powerglide 자동 [77]. (투톤 칠·화이트월·크기는 이 출처에 없음 — 확인 못 함.)
  ▶ 작은 날개 + 반짝이 띠 + 큰 크롬 범퍼.
- **Cadillac Eldorado (1959)** — **거대하고 뾰족한 꼬리날개 + 총알 모양 쌍 꼬리등**, 390 cu in(6.4 L) V8 345 hp, 길이 5,715 mm, 휠베이스 3,302 mm, 2,300–2,400 kg(1959–60), 에어 서스펜션(기본 장비 목록) [75][76].
  ▶ 날개 끝 빨간 총알 등 2개 = 50년대 그 자체.
- **Mini (1959-08-26)** — Alec Issigonis, 1956 수에즈 위기 연료난에서 탄생, 가로 엔진 + 오일팬 속 변속기 + 앞바퀴굴림, 고무 원뿔 서스펜션, 10인치 바퀴, **밖으로 드러난 용접 이음새**, 미닫이 창, 848 cc 33 bhp, 121 km/h, 3,054×1,397(1,410)×1,397(1,346) mm, 약 580–686 kg [47].
  ▶ 아주 작은 상자 + 네 귀퉁이 바퀴 + 겉 이음새 선.
- **VW Beetle (1938–2003)** — 뒤 공랭 수평대향 4기통, 라디에이터 없음, 앞 보닛 밑 짐칸, 1950 유압 브레이크, 1962~ 앞 예비 타이어 공기로 워셔액 분사, 12 V는 1968–69, 4,079–4,140×1,539–1,585×1,500 mm, 730–930 kg, 2,152만 대 [73].
  ▶ 둥근 지붕 + 둥근 흙받이 + 앞에 짐칸·뒤에 엔진.

### 시대 5. 1960–1972 — 머슬카·포니카·꽃무늬 밴
**바뀐 것**: 1960 알터네이터 [42], 1960 Big Three 소형차 일체형 [48], 1962 첫 터보 양산차(Corvair Monza·Oldsmobile Jetfire) [97], 1963 전자 점화 옵션 [17], 1964 Mustang·GTO [81][82], 1967 2회로 마스터 실린더 [25], 1968 어깨 벨트 의무 [49]. 머슬카 = 미국 2도어에 강한 V8·뒷바퀴굴림, 흔히 1964–1973 [83]. 끝난 이유: 보험 할증, 1970 Clean Air Act 이후 옥탄 하향·압축비 하향, 1973 석유 위기 [83].
**그때 정비사**: 포인트 간격·드웰·타이밍(튠업) [103][105], 4배럴 기화기, 공랭 VW의 벨트 하나(발전기+냉각팬) — (아래 3장 참고).
**대표 차**
- **Ford Mustang (1964-04-17, '1964½')** — **긴 보닛·짧은 트렁크**, 직렬 6 170(105 hp)/V8 260(164 hp)/289(210 hp), 4,613×1,732×1,300 mm, 1,109 kg, $2,368, '포니카' 장르를 만듦, 옆 흡입구 장식은 1967 등 뒤 모델 [81].
  ▶ 긴 코 + 짧은 엉덩이 + 앞그릴 가운데 달리는 동물(오리지널 동물로).
- **Pontiac GTO (1964)** — Tempest/LeMans에 $295 옵션 묶음, 389 V8 4배럴 325 hp / **Tri-Power(2배럴 기화기 3개) 348 hp**, **보닛 흡입구(hood scoop)**, 크롬 밸브커버, 듀얼 배기, 32,450대, 약 1,600 kg [82].
  ▶ 보닛 위 공기구멍 2개 + 굵은 줄무늬.
- **VW Type 2 버스 (T1 1950–1967 / T2 1967–1979)** — 뒤 공랭 엔진, 라디에이터 없음(수랭은 나중 멕시코·브라질), T1 = **갈라진 앞유리 + V자 앞얼굴**, T1 4,280×1,720×1,940 mm, T2는 12 V, 1960s 반문화(히피)에 인기 [84].
  ▶ 둥근 빵 덩어리 + 앞 V자 칠 + 큰 엠블럼 자리(오리지널).
- **Mini (계속)**, **Chevrolet Corvair Monza(1962 터보)** [97].

### 시대 6. 1973–1985 — 배기가스 규제·'말레이즈(malaise)' 시대
**바뀐 것**: 1970 Clean Air Act 개정 → 1975까지 HC·CO·NOx 90% 감축 [88]. 1971~ 마력 급감(총→순 마력 표기 변경도) [88]. 1973 진공으로 여닫는 EGR [98]. 1973/1975 전자 점화 표준 [17]. 1974 네모 헤드램프 허용 [36]. 시속 5 mph 범퍼 규정(1982에 3 mph로 완화), 1974 시속 55 mph 제한, 1975 CAFE 연비 규정 [88]. **1975 촉매 + 무연 휘발유** [50]. 1976 레이디얼 표준 [33]. 1970s 말 앞 디스크 [29]. 1981 3원 촉매 [50]. 1980~ 스로틀바디 분사 [21]. 끝: 컴퓨터·전자 분사·3원 촉매가 성숙하며 1985–87쯤, Taurus가 전환점 [88].
**그때 정비사**: 1960s부터 진공으로 움직이는 장치가 많아짐(히터·에어컨 제어, 문 잠금, 헤드램프 덮개, 브레이크 부스터, 배기 장치) → **진공 호스 새는 곳 찾기** [107]. EGR 카본 막힘 [98]. 촉매 막힘·납 중독 [50].
**대표 차**
- **Honda Civic (1세대, 1972-07~1979; 북미형 1973–)** — 가로 수랭 FF, 1,169 cc, **1975 CVCC**(작은 예연소실 + 보조 흡기밸브, 촉매 없이 1970s 미국 규제 통과), 북미형 길이 3,754 mm·폭 1,505·높이 1,325–1,330, 600–790 kg, 1973 석유 위기로 인기 [86][87].
  ▶ 작은 해치백 + 둥근 등 2개 + 짧은 코.
- **Ford Pinto (1971–1980)** — Ford 북미 첫 소형차, 4,140×1,763×1,270 mm, 914–1,030 kg, 뒤 차축과 범퍼 사이 연료탱크 → 1978-06-09 약 150만 대 리콜(방패·긴 주입관·씰), 1972 왜건 + **Squire 나무무늬 비닐**, 1977–78 'Cruising Wagon' 동그란 옆창 [85][89].
  ▶ 작은 왜건 + 나무무늬 옆판 + (또는) 동그란 창.
- **VW Golf / Rabbit (1974-05 유럽, 1974-12 미국 Rabbit, 1978-07 미국 생산)** — Giugiaro '종이접기' 각진 디자인, 공랭 RR(Beetle) → **수랭 가로 FF**로 전환, 1976 GTI(Bosch K-Jetronic), 3,705×1,610×1,395 mm, 790–970 kg [90].
  ▶ 칼로 자른 듯한 상자 해치 + 둥근 등.
- **나무무늬 왜건**: Jeep Wagoneer 1970–1991 나무무늬, Chrysler Town & Country(LeBaron) 1982–88, GM 풀사이즈 왜건 1996까지 [85].

### 시대 7. 1980년대 — 쐐기(wedge)·팝업 헤드램프
**바뀐 것**: 팝업(숨은) 헤드램프는 1960s 중후반 미국에서 다시 인기 → 1970s~2000s 초 다양한 차 → 1980s 흔함(Knight Rider 효과) [37][39]. 1983 전구 교체식 헤드램프 허용 → 1986 Taurus 매끈한 복합 헤드램프 [36][91]. 1980s 터보 보급 [97]. 1988 Chrysler 운전석 에어백 기본, CARB OBD-I [51][52].
**그때 정비사**: 팝업 고장(한쪽만 올라오는 '윙크', 열린 채 고정) [39], 터보 래그·웨이스트게이트 [97], 첫 컴퓨터 제어 엔진(OBD-I은 회사마다 다름) [51].
**대표 차**
- **Lamborghini Countach (1974–1990)** — Gandini(Bertone)의 날카로운 '이탈리안 쐐기', **위로 열리는 가위 문(scissor)**, 팝업 헤드램프, 세로 배치 V12 미드십, 4,140×1,887(후기 2,000)×1,070 mm, 1,300–1,488 kg, 254–298 km/h [92][109].
  ▶ 납작한 쐐기 + 위로 열리는 문 + 팝업 등.
- **Toyota MR2 (1세대 AW11, 1984–1989)** — 미드십 2인승, 1.6 L 4A-GE(130 PS 일본), 슈퍼차저형 145 hp, 3,950×1,666×1,234 mm, 1,035–1,131 kg, 팝업 헤드램프 [93][109].
  ▶ 작은 쐐기 + 문 뒤 옆 공기구멍 + 팝업 등.
- **Mazda RX-7 (1세대 SA/FB 1978–1985)** — 2인승 해치백 쿠페, **로터리(방켈) 12A 1,146 cc**, 4,285×1,675×1,260 mm, 1,043–1,134 kg, 3세대(FD)도 팝업 [94].
  ▶ 낮은 코 + 팝업 등 + 둥근 유리 해치.
- **Ford Taurus (1986년형, 1985-10~1991-07)** — '젤리빈(jelly bean)' 공기역학 차체, Cd 0.32, **차체와 평평한 복합 헤드램프**(미국 세단 중 초기), FF, 3.0 L Vulcan V6 140 hp, 4,785×1,798×1,379 mm, 1,380 kg, 1986 Motor Trend 올해의 차, 200만 대 이상 [91]. — 말레이즈 끝·90년대 둥근 차의 시작 [88].
  ▶ 둥글고 매끈한 가족 세단 + 그릴 거의 없는 얼굴.

### 시대 8. 1990년대 — OBD-II·에어백·둥근 차
**바뀐 것**: 1990s 초 선진국 새 가솔린차 거의 다 연료 분사 [21], 1994 마지막 기화기 [22]. 1991–92 HID [36]. 1990s 코일-온-플러그 [17]. **1996 OBD-II** [51]. 1995 ESC 첫 [54]. 1997 GDI [21]. 1998-09 이후 생산분 듀얼 에어백 [52]. 1996 EV1, 1997 Prius, 1999 Insight [57][59][60]. 팝업은 1990s에 줄어 스포츠카·이국차만 [39].
**그때 정비사**: 16핀 OBD-II 단자에 스캐너 꽂고 P0xxx 코드 읽기 [51]. 엔진룸이 플라스틱 덮개·센서로 가득(출처 확인 못 함).
**대표 차**
- **Honda Civic (5세대 EG, 1991-09~1995-08, 1992–95년형)** — 해치백 4,069×1,699×1,288 mm, 925–1,130 kg, 더 공기역학적인 차체, D16Z6 1.6 L SOHC **VTEC** 125 hp(Si), 일본 올해의 차 [96].
  ▶ 낮고 둥근 작은 해치 + 길쭉한 등.
- **Mazda MX-5 Miata (NA, 1989–1997)** — **팝업 헤드램프**(다음 NB부터 고정), 1.6 L 115 bhp / 1.8 L, 3,950(3,970)×1,675×1,230(1,235) mm, 980–1,002 kg, 전후 영국 로드스터에서 영감, 431,506대 [95].
  ▶ 동그란 작은 2인승 오픈카 + 팝업 '눈'.
- **GM EV1 (1996–1999)** — 아래 시대 9 참조(1990s 차이지만 '물방울' 모양의 원조) [60].

### 시대 9. 2000–2012 — 하이브리드·안전 전자
**바뀐 것**: 2001 EOBD [51]. 2004 팝업 끝 [37]. 2007 TPMS 100% [53]. 2007–2008 LED 헤드램프 [41]. 2008 Tesla Roadster [56]. 2010 Leaf [61]. 2012 ESC 의무 + ABS [30][54]. CVT 보급(Nissan Xtronic 2003 등) [46].
**그때 정비사**: **고전압(HV) 안전** — 주황색 케이블, Class 0 절연 장갑, 서비스 플러그 뽑고 기다리기 [66][67][68]. TPMS 센서 배터리·밸브 부식 [53].
**대표 차**
- **Toyota Prius 1세대 (XW10, 1997-12 일본 / 2000-09 세계 / 미국 2001–2003년형)** — **평범한 4도어 세단**(물방울 아님!), 1.5 L 앳킨슨 4기통 70 hp(미국형), NiMH 273.6 V 1.78 kWh, 4,308×1,695×1,463 mm(NHW11), 1,254 kg [57].
- **Toyota Prius 2세대 (XW20, 미국 2004–2009년형)** — **5도어 리프트백, 캄백(Kammback) 꼬리, Cd 0.26** = 우리가 아는 '하이브리드 모양', 201.6 V NiMH(28 모듈), 4,450×1,725×1,490 mm, 1,317 kg, 스마트키 옵션 [58].
  ▶ 둥근 지붕이 뒤에서 뚝 끊기는 꼬리 + 높은 뒷유리.
- **Honda Insight 1세대 (ZE1, 1999-11 일본, 1999-12 북미 첫 하이브리드 ~2006)** — 2인승 3도어 리프트백, **알루미늄 일체형**, 1.0 L 3기통 67 hp + 10 kW 모터(IMA), 144 V NiMH(D 사이즈 셀 120개), Cd 0.25, 3,945×1,695×1,355 mm, 838–891 kg, EPA 원래 70 mpg 고속 [59]. 뒷바퀴 가림판(skirt)은 Honda 보도자료 요약에서만 봄 — 원문은 못 엶(확인 못 함).
- **GM EV1 (1996–1999)** — **뒷바퀴 사이가 앞보다 9인치 좁은 물방울(teardrop) 평면 + 뒷바퀴 반 가림판**, Cd 0.19, 4,310×1,770×1,280 mm, 1,319–1,400 kg, 리스만 1,117대 [60].
  ▶ '물방울 + 뒷바퀴 반 가림' 은 EV1·Insight 쪽 특징.
- **Nissan Leaf 1세대 (2010-12)** — 5도어 해치 패밀리 EV, 라미네이트 리튬이온 셀 192개, 80 kW 모터, 약 160 km, 배터리 **능동 냉각 없음(공랭·수동)** → 같은 시기 Tesla보다 빨리 열화 [61][63]. 크기·무게는 출처에 없음(확인 못 함).

### 시대 10. 2013–지금 — 전기차(EV)
**바뀐 것**: 2018-05 후방 카메라 의무 [55]. 2020s 원페달 주행(회생 제동만으로 정지) [31]. 무선 업데이트(OTA) [62]. 배터리 = 셀 → 모듈 → 팩, BMS가 셀 전압·온도 감시, 팩 안에 서비스 플러그·메인 퓨즈 [63].
**그때 정비사**: 엔진오일 교환 없음, 배터리·모터·전자장치는 정기정비 거의 없음, 회생 제동으로 브레이크 덜 닳음, **액체 냉각 배터리는 냉각수 점검 필요**, 배터리 보증 보통 8년/10만 마일 [65]. 모듈 분해 전 완전 방전, 분해는 비싸고 오래 걸림 [63]. 열·급속충전이 열화를 키움 [63].
**대표 차**
- **Tesla Model S (2012-06~)** — 그릴 대신 **막힌 앞면(solid fascia)**, **앞 트렁크(frunk) 150 L**, 바닥 속 배터리(가장 무거운 부품, 무게중심↓), 숨는 문손잡이, 뒤 모터(2019~ 듀얼), 40–100 kWh, 335–652 km, 4,980–5,021×1,960×1,440 mm, 1,961–2,250 kg [62]. P85 팩 = 모듈 16개 × 셀 444개(6S74P, 18650) = 7,104셀, 약 400 V, **물+글리콜 액체 냉각**, 모듈마다 BMS — 엔지니어 블로그 자료(Tesla 공식 아님) [64].
  ▶ 그릴 없는 매끈한 코 + 낮은 지붕 + 앞 보닛 밑 짐칸.
- **Nissan Leaf** (위) — 같은 EV라도 **배터리 수동 공랭** → '냉각수 없음'인 EV도 있음 [61][63].

---

## 3. 시대 차 고장·수리 — 게임 재미의 진짜 근거

| 시대 | 실제 고장 | 실제 고치는 법 | 출처 |
|---|---|---|---|
| 1 (1885–1900) | 증발 냉각이라 물이 끓어 없어짐 | 멈출 때마다 물 보충 | [1][2] |
| 1 | 언덕에서 벨트 미끄러짐, 힘 부족 | 사람이 밀기 → '언덕용 낮은 기어' 추가(Nr.2부터 감속 기어) | [1][2] |
| 1 | 나무 블록 브레이크가 닳음 | 구두장이가 **가죽** 덧댐(첫 라이닝) | [1][2] |
| 1 | 연료관 막힘 / 전선 피복 / 체인 | 모자핀으로 뚫기 / 가터로 감싸기 / 대장장이 수리 | [2] |
| 1 | (Daimler) 핫튜브: 너무 달구면(하얗게) **터짐**, 보통 1년 안에 교체, 버너 위치로 타이밍 조절 | 버너 불꽃 위치 맞추기, 관 교체 | [3] |
| 2 (1901–1918) | 손 크랭크 되튕김 → 손목 골절('chauffeur's fracture', 'Ford fracture') | **엄지를 손가락과 같은 쪽**에 두기(감싸 쥐지 않기), 점화를 늦춤(retard) 위치로 놓고 돌리기 | [15][100][101] |
| 2 | Model T 밴드가 느슨/조정 틀어짐 → 차가 슬금슬금 감(특히 추울 때) | 변속기 덮개 쪽 조정 나사로 밴드 조정 (페달 간격 수치는 포럼 요약뿐 — 확인 못 함) | [14] |
| 2 | 열사이펀 냉각: 공회전·저속 과열, 냉각수 조금 모자라도 큰 문제 | 냉각수 가득 유지, 바람(주행·팬) | [23] |
| 2 | 카바이드 램프 가스 다 씀 | 아래 통 석회 반죽 비우고 카바이드 새로, 위 통 물 채우기, 물방울 속도로 불 크기 | [38] |
| 2 | Curved Dash 기화기가 자꾸 틀어짐 | 자주 다시 맞춤(달리며 조절되는 차도) | [12] |
| 3 (1919–1940) | 포인트 접점이 닳고 패임(아크), 러빙 블록 마모 | 정기적으로 드웰/간격 다시 맞춤, 콘덴서가 아크를 줄임 | [19][105] |
| 3 | 기계식(막대·케이블) 드럼 브레이크 늘어짐 | 손으로 주기 조정 (자동 조정은 1950s부터) | [26][28] |
| 3 | 크래시 박스 '드르륵' | 더블 클러치(싱크로메시 전) | [45] |
| 3 | 겨울 냉각수(물) 얼어 터짐 | 부동액(1930s~ 얼지 않게 하려고) | [24] |
| 4 (1941–1959) | 6 V 차가 뜨거울 때 시동 안 걸림(고압축 V8), 부식된 단자로 전압 떨어짐 | 굵은 케이블·단자 청소 → 결국 12 V로 전환 | [43] |
| 4 | 공회전 거칠음 | 기화기 **혼합비 나사**: 진공계 꽂고 엔진 떨릴 때까지 묽게 → 진하게 돌려 **최고 진공** → ¼바퀴 묽게, 그다음 공회전 속도 나사. 정상 공회전 진공 6기통 19–21 inHg | [106] |
| 4 | 드럼 브레이크 페달이 깊어짐 | **별바퀴(star wheel) 조정기**를 돌려 슈가 드럼에 살짝 끌릴 때까지 → 후진하며 브레이크 여러 번(자동 조정기 작동), 방향은 차마다 다름 | [108] |
| 4 | 제너레이터 공회전 충전 약함 | (1960~) 알터네이터로 바뀜 | [42] |
| 5 (1960–1972) | 포인트 튠업 | 필러 게이지 **0.016–0.019 in**(Chevy 스몰블록) → 드웰미터 **약 30°**(V8 28–32°), 1955 Chevy 매뉴얼 26–33°, 공회전↔1,700 rpm 드웰 차가 3° 넘으면 배전기 마모 | [102][103][104][105] |
| 5 | 공랭 VW: 벨트 하나가 발전기 + 냉각팬을 같이 돌림 → 끊어지면 금방 과열 | 예비 벨트, 장력 맞추기(풀리 심) — **열어 본 출처 없음(검색 요약만) → 확인 못 함** | — |
| 5 | 공랭 VW 밸브 간극 수치 | (확인 못 함) | — |
| 6 (1973–1985) | **진공 누설**: 쉭 소리·감속 때 휘파람, 공회전 거칠음, 힘·연비 저하 | 18인치 연료호스를 **청진기처럼** 대고 듣기, 기화기 클리너/WD-40 뿌려 회전수 변하는 곳, 호스 집게로 막아 보기. 단골 = 브레이크 부스터 체크밸브(플라스틱), 변속기 모듈레이터(차 밑 쉭), 기화기 밑 개스킷 | [107] |
| 6 | EGR 밸브 카본 막힘 → 시동 어려움·공회전 거칠음 | 청소 또는 교체 | [98] |
| 6 | 촉매 납 중독(유연 휘발유) / 막힘 / 실화로 과열 | 무연만 넣기, 촉매 교체(제거는 미국 법 위반) | [50] |
| 6 | Pinto 연료탱크 리콜 | 폴리에틸렌 방패 + 긴 주입관 + 씰 | [89] |
| 7 (1980s) | 팝업 한쪽만 올라옴('윙크') / 열린 채 고정 | 보닛 밑 손잡이(다이얼)로 수동으로 올리기, 모터·기어 수리. 미국 FMVSS 108: 고장 나도 **공구 없이** 완전히 열 수 있어야 함 | [39][40] |
| 7 | 터보 래그·과급 과다 | 웨이스트게이트가 배기를 돌려 과급 제한 | [97] |
| 8 (1990s) | 엔진 경고등 | OBD-II 단자(핸들 2 ft 안)에 스캐너 → 5글자 코드(P0xxx) | [51] |
| 9 (2000–2012) | 하이브리드 고전압 작업 | **주황색 케이블**(SAE 색 규칙) 건드리지 않기, **Class 0 장갑(1,000 V)** + 가죽 덧장갑, 쓰기 전 공기 테스트, 6개월마다 시험 / 서비스 플러그 뽑고 기다리기: 1세대 Prius 자료 **5분**, "대부분 제조사 10분" — **출처마다 다름** | [66][67][68] |
| 9 | TPMS 경고 | 림 안 센서 배터리는 보통 교체 불가 → 타이어 떼고 센서 교체, 금속 밸브캡이 부식으로 붙어 밸브 부러짐, 펑크 실런트가 센서 막음 | [53] |
| 10 (2013~) | 배터리 용량 감소 | 열·급속충전이 원인 1순위, BMS 셀 전압·온도 확인, 모듈 분해 전 완전 방전 | [63] |
| 10 | 액체 냉각 배터리 냉각수 | 정기 점검(설명서 주기) — EV에도 펌프·라디에이터 있음 | [24][65] |
| 10 | 브레이크 | 회생 제동 덕에 덜 닳음(대신 오래 안 써서 생기는 문제는 확인 못 함) | [31][65] |

---

## 4. era_mine.md 와 다른 점 (사실 고침)

| 초안 줄 | 초안 내용 | 실제 | 출처 | 제안 |
|---|---|---|---|---|
| 1 Tri-Wheeler | **핫튜브 점화** + 세발 | 핫튜브는 **Daimler**(1883–1897, 네바퀴 마차·Reitwagen). **세발 Benz는 배터리 + 트렘블러 코일 전기 점화** | [1][3][4][6] | 세발로 갈 거면 '코일 윙윙 + 배터리', 핫튜브로 갈 거면 '네바퀴 마차' 쪽이 정확. 섞으면 오리지널은 되지만 '진짜처럼' 규칙엔 어긋남 |
| 1 | (연료 언급 없음) | Benz = **배기열로 데우는 표면 기화기**, 연료 리그로인을 **약국**에서 삼 | [1][2] | '약국에서 연료 사기' 이야기 재료 |
| 1 | 큰 철테 바퀴 | Nr.1 = **철사 바퀴 + 통고무**, Nr.2부터 = **나무 바퀴 + 쇠 테** | [1] | 둘 다 가능, 버전 고르기 |
| 1 | 막대(틸러) 핸들 | Benz = 기둥 위 **손잡이 레버** → 랙·피니언 | [1] | '틸러'보다 '세운 손잡이'로 |
| 1 | 가죽 벨트 걸기 | 벨트 구동은 맞음. 벨트 재질 '가죽'은 출처에 없음 | [1] | (확인 못 함) — '벨트 걸기' 만 |
| 1 | 물 증발식 냉각 | 맞음(Benz). Nr.1엔 실린더 위 작은 라디에이터 형태도 그림에 있음 | [1] | OK |
| 1 | 1886~1895 | Benz 생산 1886–1893, 네바퀴 Benz는 1892 말부터 | [1] | OK(끝을 1893~1895 어디든) |
| 2 Curved-Dash | 의자 밑 엔진·체인·(틸러) | **맞음**: 의자 밑 수평 1기통, 체인 1개, 가운데 틸러, 2단 유성기어. Wikipedia는 '차 가운데' 라고만 함 | [10][11][12][13] | OK. 연도는 1900~ → **1901~1907** |
| 2 | 트렘블러 코일 '윙' | Curved Dash 점화 방식은 열어 본 출처에 없음 | — | (확인 못 함). 확실한 재미는 '기화기 자주 맞추기'[12] |
| 3 Brass-Era | 1908~1927 + 놋쇠 | Brass Era = **1896–1915**, Model T 놋쇠는 **1915까지** | [99] | 1908~**1915** 로 줄이거나, 1916–1927은 '검은 Model T 시대'로 따로 |
| 3 | 카바이드 램프 | 맞음: Model T 1915 전 아세틸렌 카바이드, 1915~ 마그네토 전기등 | [14][38] | 1915 전 차만 |
| 3 | 크랭크 + 점화 레버 타이밍 | 맞음(점화 늦추고 돌리기, 엄지 같은 쪽). Model T 전기 시동은 1919~ 옵션 | [14][15][101] | OK |
| 3 | 튜브 타이어 땜질 | 공기 타이어 + 튜브 시대는 맞음(튜브리스 1955 기본) — 땜질 방법은 출처 없음 | [32][34] | (확인 못 함) |
| 4 Running-Board | 앞으로 열리는(=뒤 경첩) 뒷문 | 20세기 전반 흔함, 1930s~40s엔 "규칙에 가까웠다"는 글도. 다만 모든 차는 아님(Ford 1933–39 설은 원문 못 엶) | [78][79] | OK(‘흔했다’ 수준) |
| 4 | 발판 | 1929 Ruxton이 첫 '발판 없는 차', 1934 Traction Avant도 없음. 1930s 대부분 차는 있었다는 직접 출처는 못 찾음 | [72][80] | (언제 사라졌는지 확인 못 함) |
| 4 | 펜더 예비 타이어 | 출처 없음 | — | (확인 못 함) |
| 4 | 포인트·6 V·막대 브레이크 | 맞음. 단 유압은 Chrysler 1924·GM 1936·Ford 1939 — 회사마다 다름 | [17][26][43] | 'Ford풍 = 막대 브레이크' 식으로 |
| 4→5 사이 | 1941~1949 빠짐 | 지프(1941–45), Hydra-Matic(1940), 키 시동(1949) | [15][44][74] | 'War Jeep' 변형 추가 검토 |
| 5 Finned Cruiser | 꼬리날개·화이트월 | 맞음: 날개 1948 시작, 1955–61 전성, 1959 Eldorado 최대 / 넓은 화이트월 1950s 초 정점 | [35][76] | OK |
| 5 | 발전기(제너레이터) | 맞음(알터네이터 1960~) | [42] | OK |
| 5 | (6 V 가정 시) | 1950s 중반 이후 미국 차는 대개 **12 V**(GM 1953~, 늦어도 1956) | [43] | '6 V 시동 고생' 미니게임은 **1953 전** 차에 |
| 5 | 둥근(통) 앞유리 | 열어 본 출처에 없음 | — | (확인 못 함) |
| 6 Muscle | 보닛 공기구멍·긴 보닛 | 맞음(GTO 보닛 스쿱, Mustang 긴 보닛 짧은 트렁크) | [81][82] | OK. 시대 끝은 1973까지로도 씀 [83] |
| 6 | 4배럴 | 맞음(1952~), GTO Tri-Power는 2배럴×3 | [20][82] | '기화기 3개' 변형 재미 |
| 6b Flower Van | 뒤 공랭, 라디에이터 없음 | **맞음** | [84] | OK. 밸브 간극·벨트 수치는 확인 못 함 |
| 7 Woodie Wagon | 나무무늬 옆판 | 1970s~80s는 **진짜 나무가 아니라 비닐 무늬(DI-NOC)**. 진짜 나무 차체는 1930s~40s | [85] | '나무 광내기' 대신 '비닐 무늬 들뜸' 이 시대에 맞음(들뜸 고장 자체는 확인 못 함) |
| 7 | 네모 헤드라이트·큰 범퍼 | 맞음: 네모 1974 허용, 5 mph 범퍼 | [36][88] | OK |
| 7 | 진공 호스 스파게티·청진기 | 맞음: 1960s~ 진공 장치 많음, EGR 1973 진공식, 호스를 청진기처럼 | [98][107] | OK |
| 7 | 초기 전자 점화 | 맞음(Chrysler 1973, Ford·GM 1975 표준) | [17] | OK |
| 7 | 카세트 | 출처 없음 | — | (확인 못 함) |
| 8 Pop-Up Wedge | 1980~1989 | 팝업은 1960s 말~2004, Countach는 1974~. 1980s에 가장 흔했음은 맞음 | [37][39][92] | OK |
| 8 | '윙크' 고장 | **맞음**(한쪽만 열림, 열린 채 고정) | [39] | OK |
| 8 | 디지털 계기판 | 출처 없음 | — | (확인 못 함) |
| 8 | 초기 터보 | 첫 터보 양산은 **1962**. 1980s는 '보급' 시대 | [97] | '초기' → '터보 붐' |
| 9 90s Hot Hatch | OBD-II 1996 | **맞음**(승용차·8,500 lb 이하 가솔린 경트럭) | [51] | OK |
| 9 | 스캐너 첫 등장 | 아님: GM 데이터 링크 1980, California OBD-I 1988. OBD-II는 **단자·코드 통일** | [51] | '첫 공통 단자' 로 |
| 9 | 큰 날개 스포일러 | Civic EG 출처엔 없음 | [96] | (확인 못 함) |
| 10 Teardrop Hybrid | 물방울 + 뒷바퀴 반 가림 | **1세대 Prius는 평범한 세단**. 물방울 평면 + 뒷바퀴 가림 = **GM EV1(1996)**·Honda Insight(1999). Prius 캄백은 2세대(2003/2004~) | [57][58][59][60] | 모양은 OK, 근거 차를 Insight·EV1·Prius 2세대로 |
| 10 | 주황 선·절연 장갑·서비스 플러그 | **맞음**. 기다리는 시간 5분 vs 10분 — 출처마다 다름 | [66][67][68] | 게임은 '설명서 대기 시간' 으로 |
| 11 Modern EV | **라디에이터 없음** | **틀림**: EV도 **냉각수·펌프·라디에이터**로 배터리·모터 식힘 | [24][65] | '머플러·배기관 없음(무배출)' [56]만 남기고, 라디에이터는 '엔진용 아님, 배터리용' 으로 |
| 11 | 냉각수는 배터리용 | 맞지만 **모든 EV는 아님**: 1세대 Leaf는 능동 냉각 없음 | [61][63] | 차마다 다르게 |
| 11 | frunk·그릴 없음·바닥 배터리 | 맞음(Model S frunk 150 L, 막힌 앞면, 바닥 배터리) — 모든 EV에 frunk가 있는지는 확인 못 함 | [62] | OK |
| 11 | 셀 전압 맞추기·소프트웨어 업데이트 | 맞음(BMS 셀 전압 감시, OTA 업그레이드 사례) | [62][63] | OK |
| 크기 | 1886 세발차 2.7 m | **맞음** 2,700 mm | [1] | OK |
| 추가 | — | ~1900 미국 차 **38%가 전기차** | [56] | 시대 1~2에 '전기 마차' 희귀 변형 후보 |

---

## 5. era_cars.md v0.1 (wr-design 정식안) 와 대조 — wr-carbook, 10-20

era_cars.md v0.1은 이미 위 4절 고친 점 대부분을 반영했어요(핫튜브 = Daimler라고 명시하고 '두 차를 섞은 게임 설계'로 도감에 적기, EV는 '머플러·엔진오일 없음, 배터리 냉각수는 있음', 공랭 밴 = 라디에이터 없음, OBD-II 1996 '의무'). 남은 작은 차이만:

| era_cars 칸 | 지금 | 실제 (이 파일 근거) | 제안 |
|---|---|---|---|
| 1 Pioneer · 조향 | "막대(틸러) 조향 ← Daimler·Peugeot·**Benz**" | Benz는 틸러가 아니라 **기둥 위 손잡이 레버 → 랙·피니언** [1] | 근거 차에서 Benz를 빼거나 '세운 손잡이'로 |
| 1 Pioneer · 수리 | 핫튜브 + 물 채우기 + 벨트 | 맞음. 덧붙일 재료: Bertha Benz 1888 여행 — 연료를 **약국**에서 사고, 막힌 연료관을 **모자핀**으로 뚫고, 브레이크 가죽을 **구두장이**가 붙임 [2] | 손님 이야기·도감 문구 재료 |
| 1 Pioneer · 점화 | 핫튜브(Daimler) | ~1900 미국 차 38%가 **전기차** [56] | 시대 1~2 '조용한 전기 마차' 희귀 변형 후보(선택) |
| 2 Openroad · 카바이드 램프 | 선택 수리 | 맞음, 단 **1915 전 차만**(Model T 1915~ 마그네토 전기등) [14][38] | 연식 표시 |
| 3 Roundstep · 6 V | 6 V 배터리 단자 청소 | 맞음(미국 12 V 전환은 1953~56) [43] | OK |
| 3 Roundstep · 브레이크 | 기계식 막대·케이블 좌우 맞추기 | 회사마다: Chrysler 1924·GM 1936 유압, **Ford는 1939까지 기계식** [26] | 'Ford풍 차' 설정이면 정확 |
| 3 Roundstep · 진공 와이퍼 | "가속하면 느려짐" | 이 파일 출처로는 (확인 못 함) | 근거 링크 하나 달기 |
| 5 Starlane · 제너레이터 | 공회전에서 충전 약함 | 발전기(제너레이터) → 알터네이터 1960~ [42] 맞음 | OK |
| 8 Squareway · 나무무늬 | 선택 장식만 | 1970~80s는 **비닐 무늬(DI-NOC)** [85] | '나무 광내기' 대신 '비닐 무늬 들뜸'이 시대에 맞음 |
| 9 Lowbeam · 팝업 | 2004 마지막 | 맞음 [37][39] | OK |
| 11 Glideback · 근거 차 | Prius 1세대 '매끈한 짧은 앞' | 1세대 Prius는 **평범한 세단 모양**, 물방울·뒷바퀴 덮개 = EV1(1996)·Insight(1999), Prius 캄백은 2세대 [57]~[60] | 근거 차를 Prius 2세대·Insight 중심으로(뒷바퀴 덮개는 era_cars가 이미 '피할 것'에 넣음 — OK) |
| 11 Glideback · 고전압 | 서비스 플러그 뽑고 기다리기 | 맞음. 기다리는 시간은 출처마다 5분/10분 [66][67][68] | 게임은 '설명서 시간'으로 |
| 12 Quietline · 냉각 | 배터리 냉각수 점검 | 대부분 맞음, 단 **1세대 Leaf는 능동 냉각 없음** [61][63] | 차마다 다르게(오진 함정 재료) |

## 출처 (모두 직접 열어 확인)
1. Benz Patent-Motorwagen — Wikipedia — https://en.wikipedia.org/wiki/Benz_Patent-Motorwagen
2. Bertha Benz — Wikipedia — https://en.wikipedia.org/wiki/Bertha_Benz
3. Hot-tube ignitor — Wikipedia — https://en.wikipedia.org/wiki/Hot-tube_ignitor
4. Daimler Reitwagen — Wikipedia — https://en.wikipedia.org/wiki/Daimler_Reitwagen
5. Daimler Motorized Carriage — Wikipedia — https://en.wikipedia.org/wiki/Daimler_Motorized_Carriage
6. Gottlieb Daimler — Wikipedia — https://en.wikipedia.org/wiki/Gottlieb_Daimler
7. Duryea Motor Wagon Company — Wikipedia — https://en.wikipedia.org/wiki/Duryea_Motor_Wagon_Company
8. Duryea Motor Wagon — Wikipedia — https://en.wikipedia.org/wiki/Duryea_Motor_Wagon
9. Panhard — Wikipedia — https://en.wikipedia.org/wiki/Panhard
10. Oldsmobile Curved Dash — Wikipedia — https://en.wikipedia.org/wiki/Oldsmobile_Curved_Dash
11. 1903 Oldsmobile Curved Dash Runabout — The Henry Ford — https://www.thehenryford.org/collections/explore/artifact/3851
12. The Curved Dash Oldsmobile (collection set) — The Henry Ford — https://www.thehenryford.org/collections/explore/sets/detail/the-curved-dash-oldsmobile
13. 1903 Oldsmobile Model R Curved-Dash Runabout (Hershey 2011 lot) — RM Sotheby's — https://rmsothebys.com/auctions/hf11/lots/r144-1903-oldsmobile-model-r-curveddash-runabout
14. Ford Model T — Wikipedia — https://en.wikipedia.org/wiki/Ford_Model_T
15. Starter (engine) — Wikipedia — https://en.wikipedia.org/wiki/Starter_(engine)
16. Cadillac Model Thirty — Wikipedia — https://en.wikipedia.org/wiki/Cadillac_Model_Thirty
17. Ignition system — Wikipedia — https://en.wikipedia.org/wiki/Ignition_system
18. Ignition magneto — Wikipedia — https://en.wikipedia.org/wiki/Ignition_magneto
19. Contact breaker — Wikipedia — https://en.wikipedia.org/wiki/Contact_breaker
20. Carburetor — Wikipedia — https://en.wikipedia.org/wiki/Carburetor
21. Fuel injection — Wikipedia — https://en.wikipedia.org/wiki/Fuel_injection
22. This Was The Last Carbureted Engine Sold New In America — Jalopnik — https://www.jalopnik.com/1887338/last-carbureted-engine-sold-america/
23. Thermosiphon — Wikipedia — https://en.wikipedia.org/wiki/Thermosiphon
24. Radiator (engine cooling) — Wikipedia — https://en.wikipedia.org/wiki/Radiator_(engine_cooling)
25. Hydraulic brake — Wikipedia — https://en.wikipedia.org/wiki/Hydraulic_brake
26. 1939: Ford Finally Adopts Hydraulic Brakes — Mac's Motor City Garage — https://www.macsmotorcitygarage.com/1939-ford-finally-adopts-hydraulic-brakes
27. History of Chrysler — Wikipedia — https://en.wikipedia.org/wiki/History_of_Chrysler
28. Drum brake — Wikipedia — https://en.wikipedia.org/wiki/Drum_brake
29. Disc brake — Wikipedia — https://en.wikipedia.org/wiki/Disc_brake
30. Anti-lock braking system — Wikipedia — https://en.wikipedia.org/wiki/Anti-lock_braking_system
31. Regenerative braking — Wikipedia — https://en.wikipedia.org/wiki/Regenerative_braking
32. Tire — Wikipedia — https://en.wikipedia.org/wiki/Tire
33. Radial tire — Wikipedia — https://en.wikipedia.org/wiki/Radial_tire
34. Tubeless tire — Wikipedia — https://en.wikipedia.org/wiki/Tubeless_tire
35. Whitewall tire — Wikipedia — https://en.wikipedia.org/wiki/Whitewall_tire
36. Headlamp — Wikipedia — https://en.wikipedia.org/wiki/Headlamp
37. Hidden headlamp — Wikipedia — https://en.wikipedia.org/wiki/Hidden_headlamp
38. Carbide lamp — Wikipedia — https://en.wikipedia.org/wiki/Carbide_lamp
39. Why Did Automakers Stop Making Cars With Pop-Up Headlights? — Jalopnik — https://www.jalopnik.com/1806125/why-automakers-stopped-making-cars-popup-headlights-explained/
40. Whatever Happened to Pop-Up Headlights? — Slate — https://www.slate.com/blogs/the_eye/2013/10/22/pop_up_headlights_why_the_hidden_headlamp_has_disappeared.html
41. LED headlamps illuminate the way forward (LEDs Magazine, 2007) — Buildings.com — https://www.buildings.com/specialty-ssl/industrial-life-sciences/article/16695098/led-headlamps-illuminate-the-way-forward
42. Alternator (automotive) — Wikipedia — https://en.wikipedia.org/wiki/Alternator_(automotive)
43. Why Cars Made The Switch To 12-Volt From 6-Volt Batteries — Jalopnik — https://jalopnik.com/2249646/why-cars-switch-to-12-vs-6-volt-batteries
44. Hydramatic — Wikipedia — https://en.wikipedia.org/wiki/Hydramatic
45. Synchromesh — Wikipedia — https://en.wikipedia.org/wiki/Synchromesh
46. Continuously variable transmission — Wikipedia — https://en.wikipedia.org/wiki/Continuously_variable_transmission
47. Mini — Wikipedia — https://en.wikipedia.org/wiki/Mini
48. Vehicle frame — Wikipedia — https://en.wikipedia.org/wiki/Vehicle_frame
49. Seat belt — Wikipedia — https://en.wikipedia.org/wiki/Seat_belt
50. Catalytic converter — Wikipedia — https://en.wikipedia.org/wiki/Catalytic_converter
51. On-board diagnostics — Wikipedia — https://en.wikipedia.org/wiki/On-board_diagnostics
52. Airbag — Wikipedia — https://en.wikipedia.org/wiki/Airbag
53. Tire-pressure monitoring system — Wikipedia — https://en.wikipedia.org/wiki/Tire-pressure_monitoring_system
54. Electronic stability control — Wikipedia — https://en.wikipedia.org/wiki/Electronic_stability_control
55. NHTSA Final Rule Amends FMVSS 111 to Require Rearview Backup Cameras — School Transportation News — https://stnonline.com/news/nhtsa-final-rule-amends-fmvss-111-to-require-rearview-backup-cameras
56. History of the electric vehicle — Wikipedia — https://en.wikipedia.org/wiki/History_of_the_electric_vehicle
57. Toyota Prius (XW10) — Wikipedia — https://en.wikipedia.org/wiki/Toyota_Prius_(XW10)
58. Toyota Prius (XW20) — Wikipedia — https://en.wikipedia.org/wiki/Toyota_Prius_(XW20)
59. Honda Insight — Wikipedia — https://en.wikipedia.org/wiki/Honda_Insight
60. General Motors EV1 — Wikipedia — https://en.wikipedia.org/wiki/General_Motors_EV1
61. Nissan Leaf — Wikipedia — https://en.wikipedia.org/wiki/Nissan_Leaf
62. Tesla Model S — Wikipedia — https://en.wikipedia.org/wiki/Tesla_Model_S
63. Electric vehicle battery — Wikipedia — https://en.wikipedia.org/wiki/Electric_vehicle_battery
64. Tesla Model S Battery System: An Engineer's Perspective — CircuitDigest — https://circuitdigest.com/article/tesla-model-s-battery-system-an-engineers-perspective
65. Maintenance and Safety of Electric Vehicles — U.S. DOE Alternative Fuels Data Center — https://afdc.energy.gov/vehicles/electric-maintenance
66. Prius service notes (2003, 비공식 클럽 자료) — toyota-club.net — https://toyota-club.net/files/2003/03-09-15_prius-1.htm
67. Basic safety tips for servicing hybrids — Fleet Maintenance — https://fleetmaintenance.com/equipment/powertrain/article/10917138/basic-safety-tips-for-servicing-hybrids
68. Insulated Rubber Gloves And High-Voltage Batteries — I-CAR — https://rts.i-car.com/crn-10.html
69. The history of the ignition key (Mercedes-Benz Museum) — Mercedes blog — https://mercedesblog.com/?p=55312
70. Ford Model A (1927–1931) — Wikipedia — https://en.wikipedia.org/wiki/Ford_Model_A_(1927%E2%80%931931)
71. Chrysler Airflow — Wikipedia — https://en.wikipedia.org/wiki/Chrysler_Airflow
72. Citroën Traction Avant — Wikipedia — https://en.wikipedia.org/wiki/Citro%C3%ABn_Traction_Avant
73. Volkswagen Beetle — Wikipedia — https://en.wikipedia.org/wiki/Volkswagen_Beetle
74. Willys MB — Wikipedia — https://en.wikipedia.org/wiki/Willys_MB
75. Cadillac Eldorado — Wikipedia — https://en.wikipedia.org/wiki/Cadillac_Eldorado
76. Car tailfin — Wikipedia — https://en.wikipedia.org/wiki/Car_tailfin
77. 1957 Chevrolet — Wikipedia — https://en.wikipedia.org/wiki/1957_Chevrolet
78. Suicide door — Wikipedia — https://en.wikipedia.org/wiki/Suicide_door
79. A Brief History of the Suicide Door — InsideHook — https://www.insidehook.com/autos/a-brief-history-of-the-suicide-door
80. Running board — Wikipedia — https://en.wikipedia.org/wiki/Running_board
81. Ford Mustang (first generation) — Wikipedia — https://en.wikipedia.org/wiki/Ford_Mustang_(first_generation)
82. Pontiac GTO — Wikipedia — https://en.wikipedia.org/wiki/Pontiac_GTO
83. Muscle car — Wikipedia — https://en.wikipedia.org/wiki/Muscle_car
84. Volkswagen Type 2 — Wikipedia — https://en.wikipedia.org/wiki/Volkswagen_Type_2
85. Woodie (car body style) — Wikipedia — https://en.wikipedia.org/wiki/Woodie_(car_body_style)
86. Honda CVCC — Wikipedia — https://en.wikipedia.org/wiki/Honda_CVCC
87. Honda Civic (first generation) — Wikipedia — https://en.wikipedia.org/wiki/Honda_Civic_(first_generation)
88. Malaise era — Wikipedia — https://en.wikipedia.org/wiki/Malaise_era
89. Ford Pinto — Wikipedia — https://en.wikipedia.org/wiki/Ford_Pinto
90. Volkswagen Golf Mk1 — Wikipedia — https://en.wikipedia.org/wiki/Volkswagen_Golf_Mk1
91. Ford Taurus (first generation) — Wikipedia — https://en.wikipedia.org/wiki/Ford_Taurus_(first_generation)
92. Lamborghini Countach — Wikipedia — https://en.wikipedia.org/wiki/Lamborghini_Countach
93. Toyota MR2 — Wikipedia — https://en.wikipedia.org/wiki/Toyota_MR2
94. Mazda RX-7 — Wikipedia — https://en.wikipedia.org/wiki/Mazda_RX-7
95. Mazda MX-5 (NA) — Wikipedia — https://en.wikipedia.org/wiki/Mazda_MX-5_(NA)
96. Honda Civic (fifth generation) — Wikipedia — https://en.wikipedia.org/wiki/Honda_Civic_(fifth_generation)
97. Turbocharger — Wikipedia — https://en.wikipedia.org/wiki/Turbocharger
98. Exhaust gas recirculation — Wikipedia — https://en.wikipedia.org/wiki/Exhaust_gas_recirculation
99. Brass Era car — Wikipedia — https://en.wikipedia.org/wiki/Brass_Era_car
100. Chauffeur's fracture — Wikipedia — https://en.wikipedia.org/wiki/Chauffeur%27s_fracture
101. Stationary Engine List, June 2001 (crank grip / kickback) — Gas Engine Magazine — https://www.gasenginemagazine.com/gas-engines/stationary-engine-list-june-2001/
102. For Fans Of Antiquated Ways To Power Spark Plugs, Here's How To Set Ignition Points — Jalopnik — https://www.jalopnik.com/2149436/setting-points-ignition-to-fire-spark-plugs/
103. How to Set Points on a Small Block Chevy — It Still Runs — https://itstillruns.com/set-points-small-block-chevy-7208908.html
104. Setting dwell (1955 Chevrolet shop manual quoted) — VCCA forum — https://vccachat.org/ubbthreads.php/topics/12067/setting-dwell.html
105. How to set breaker points? — For A-Bodies Only (Mopar forum) — https://forabodiesonly.com/mopar/posts/1974941654/printfriendly
106. The Vacuum Gauge — Studebaker-info — https://studebaker-info.org/Tech/Vacuum/tvg.html
107. Make vacuum leaks hiss-tory — Old Cars Weekly — https://oldcarsweekly.com/features/make-vacuum-leaks-hiss-tory
108. How do I adjust rear drum brakes with self-adjusters? — Phoenix Systems — https://phoenixsystems.co/blogs/company-news-tips/how-do-i-adjust-rear-drum-brakes-with-self-adjusters
109. Lamborghini Countach & Iconic Cars With The Best Pop-Up Headlights — Lambocars — https://lambocars.com/lamborghini-countach-iconic-cars-with-the-best-pop-up-headlights/

> 못 연 곳(403·404 등)이라 쓰지 않은 것: Smithsonian Duryea 기록, Model T 클럽(MTFCA) 포럼, Holley 혼합비 글, VW 부품사(벨트·밸브 간극), Toyota 공식 Prius ERG PDF(텍스트 못 읽음), Honda Insight 보도자료. 웹 검색 한도(200회)가 다 차서 Mercedes-Benz Classic 페이지는 따로 못 찾음 — 필요하면 다음 차례에 이어서.
