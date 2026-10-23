# 냉각 (Cooling System)

> 기준 차: 가로배치 직렬 4기통 앞바퀴굴림(FF) 중형 세단, 미국 왼쪽 운전석 (예: Toyota Camry XV70/XV80, Honda Accord 10·11세대, Hyundai Sonata DN8, Nissan Altima L34).
> 차 안 좌표·이름은 `docs/specs/car_spec.md` 기준(앞 = −Z, 운전석 = −X).
> 출처는 각 줄 끝 [n] → 맨 아래 '출처' 목록. 출처 없는 문장은 쓰지 않아요. 못 찾은 건 "(확인 못 함)".
> 세부(볼트·토크·스펙)는 **Camry XV70 A25A-FKS 2.5L 정비 매뉴얼**로 확인. Accord·Sonata·Altima 의 물펌프 구동 방식·캡 압력은 열어 본 믿을 만한 출처가 없어 (확인 못 함).

## 한눈에 (3줄)
- 물펌프가 냉각수를 엔진 → 써모스탯 → 라디에이터 → 다시 엔진으로 돌리고, 라디에이터 핀 사이로 바람(주행풍 + 전동팬)이 열을 빼요 [1].
- 압력 캡이 계통에 압력을 걸어 끓는점을 올려요(보통 4~30 psi 범위) [1]; Camry XV70 계통 시험 압력 103 kPa(15 psi) [6].
- 정상 엔진 온도 약 195~220°F [22]. 과열 3대 신호 = 온도계 빨간 칸·경고등, 보닛 밑 흰 김, 달콤한 냄새의 냉각수 웅덩이 [22][14].

---

## 부품: 라디에이터 (Radiator)

### ① 하는 일
- 뜨거운 냉각수가 좁은 관 여러 개를 지나며 핀으로 열을 공기에 넘겨요. 넓은 면적 / 작은 부피 구조 [1].

### ② 실제 모양·크기·재질·색 — 알아보게 할 특징 3개
- 구조: 양쪽 끝 **헤더 탱크 2개** + 그 사이 **코어**(얇은 판·관을 땜·브레이징으로 붙임) [1].
- 재질: 옛날 황동·구리 → 요즘 **알루미늄 코어 + 플라스틱 헤더 탱크(개스킷)** — 이 조합은 더 잘 깨지고 수리가 어려움 [1].
- **가로흐름(crossflow)**: Camry XV70 분해도에서 탱크가 **좌우 끝에 세로로** 붙어 있음 [4] (diagrams/07). 세로흐름(downflow, 탱크가 위·아래)은 초기 라디에이터 방식 [1].
- 크기·무게 (확인 못 함).
- 아래쪽에 **드레인 콕(drain cock plug)** 이 있음 [8][17].
- **알아보게 할 특징 3개**
  1. 차 폭 거의 다 차지하는 **얇고 넓은 판** + 촘촘한 은색 핀 무늬 [1].
  2. 좌·우(또는 위·아래) 끝에 붙은 **검정/진회색 플라스틱 탱크** [1].
  3. 굵은 고무호스 2개(위·아래)가 탱크 목에 **링 모양 스프링 클립**으로 물려 있음 [3][4].

### ③ 차 안 위치 (Camry XV70)
- 엔진룸 **맨 앞 가운데**, 앞 범퍼 보강재 뒤 [2][3].
- 앞(차 앞쪽) → 뒤 순서: **에어컨 콘덴서**(라디에이터 앞면에 걸쇠 2 + 가이드 2로 걸림) → **라디에이터** → **팬 슈라우드 + 전동팬 1개**(뒷면에 걸쇠 2 + 가이드 2) → 엔진 [3][4].
- 아래는 **아래 받침 2개 + 고무 쿠션 2개** 위에 얹힘 [4].
- 보조탱크는 엔진룸 오른쪽(조수석) 앞 [2].

### ④ 붙어 있는 방식 (Camry XV70 떼기 — 위로 빼냄)
- 미리 떼는 것 [3]: 엔진 언더커버 → **냉각수 빼기** → 헤드라이트 → 범퍼 보강재·흡수재 → 보닛 잠금장치 → 에어클리너.
- 위쪽 고정 [3][4]: **위 라디에이터 브래킷 2개 (볼트 2 + 너트 2, 12.5 N·m)** + **위 라디에이터 서포트 (볼트 4, 12.5 N·m)**.
- 호스 [3][4]: No. 1(위) · No. 2(아래) 라디에이터 호스 = 미는 스프링 클립(slide clip) / 주입구 목에 No. 5 · No. 6 바이패스 호스.
- 전기 [3]: 팬 모터 커넥터(잠금 레버 달림).
- 팬 슈라우드는 라디에이터에 걸쇠로 붙어 **같이 나옴** [3][4].
- 공임 시간 (확인 못 함 — 열어 본 공임 출처 없음).

### ⑤ 흔한 고장 (증상 → 원인 → 진단 → 수리법·시간)
| 증상 (소리·연기·냄새·누유 색·경고등·OBD 코드) | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 과열 + 보닛 밑 흰 김, 차 밑에 냉각수 웅덩이(색은 차마다: 노랑·주황·빨강·초록·파랑·보라, 달콤한 냄새) | 라디에이터 균열·녹, 캡 균열, 호스 샘 [22] | 엔진 식힌 뒤 호스·라디에이터 새는 곳 보기, 보조탱크 F~L 확인 [14]. **압력 시험**: 냉각수 채우고 워밍업 → 캡 테스터로 **103 kPa(1.1 kgf/cm², 15 psi)** 걸고 압력이 떨어지는지; 떨어지면 호스·라디에이터·물펌프 누수 확인 [6] | 냉각수 빼기 → 교체 → 채우기 → 공기 빼기 (아래 '공기 빼기') |
| 가끔 과열, 웅덩이 없음 | 라디에이터 막힘 [23] | 앞에서 불빛 비추고 거울로 라디에이터·콘덴서 핀 확인(에어 덕트·에어클리너 떼고) [5] | 청소: 0.4 MPa(58 psi) 공기 + 물안개, 핀과 평행하게 150초씩, 10분 불리고 다시, 3분 말리기 [5]. 안 되면 교체 |
| 온도 경고등 + 계기판 "Engine Coolant Temp High" | 과열 [14][15] | 즉시 세우고 에어컨 끄고 엔진 끄기 [14] | 원인 수리 |
| P0217 (과열 상태 기록) | 냉각수 부족·누수, 더러운 냉각수, 팬 고장, 써모스탯·물펌프, 헤드개스킷, 라디에이터 막힘, 온도 센서 [24] | 코드 범위가 넓어서 다른 코드 함께 보기, **차가운 엔진에서 시작** [24] | 원인 부품 |

- 라디에이터 수명 (확인 못 함).

### ⑥ 게임 손맛 아이디어 (제안만)
- 라디에이터 앞에 '콘덴서', 뒤에 '팬 덩어리'가 샌드위치 — 라디에이터를 빼면 팬이 같이 딸려 나오는 실제 구조 그대로 [3][4].
- 핀 청소 미니게임: 노즐을 **핀과 평행하게** 유지해야 점수(기울이면 핀이 휨) [5].
- 손전등 + 거울로 핀 막힘 찾기 [5].

---

## 부품: 라디에이터 캡 · 압력 (Radiator Cap / Pressure Cap)

### ① 하는 일
- 안에 정해진 압력에서 열리는 안전 밸브. 압력을 올리면 냉각수 끓는점이 올라감; 완전히 열기 전에 압력을 먼저 빼 주는 구조 [1].

### ② 수치 (출처끼리 다름 — 그대로 적음)
| 차 / 출처 | 값 |
|---|---|
| 일반 범위 | 4~30 psi [1] |
| Camry XV70 A25A 캡 단품 시험 — 새 캡 표준 | 74~103 kPa (0.8~1.1 kgf/cm², 10.7~14.9 psi) [5] |
| 같은 차 — 쓰던 캡 최소 | 59 kPa (0.6 kgf/cm², 8.6 psi) 밑이면 교체 [5] |
| 같은 차 — 계통 압력 시험 | 103 kPa (15 psi) [6] |
| Dynamic Force 기사 (팽창 탱크 캡) | 88 kPa (약 12.75 psi), 사진 설명은 12.5 psi — 기사 안에서도 조금 다름 [16] |
| Honda Accord / Sonata / Altima | (확인 못 함) |

- 결론: "16 psi(108 kPa)" 은 Camry XV70 매뉴얼 값과 **안 맞음**. XV70 은 15 psi 이하 [5][6].

### ③ 위치 · ④ 다는 방식
- 라디에이터 쪽 '라디에이터 캡' 과 보조탱크 캡이 둘 다 있음(뜨거울 때 둘 다 열지 말 것) [14][7].
- 캡 시험 순서(XV70) [5]: 고무 패킹 3개 물·손가락으로 닦기 → 변형·금·부풂 확인 → 패킹이 시트에 붙지 않았나 → 패킹에 냉각수 바르기 → 테스터를 30° 이상 위로 기울여 → 1초에 1번씩 펌프 → 최대 압력 읽기. 최대 압력을 '유지 못 하는 것' 자체는 불량 아님 [5].

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 냉각수가 자꾸 줄어드는데 새는 곳이 안 보임 | 캡 불량 가능 | Toyota: 새는 곳이 없으면 딜러에서 **캡 시험** + 계통 점검 [7] | 캡 교체 |
| 과열 | 캡 금 [22] | 캡 테스터 [5] | 캡 교체 |

### ⑥ 게임 손맛 아이디어
- 뜨거울 때 캡 클릭 → 김 '푸슉' + 경고(실제 매뉴얼 경고 [14]) — 벌점 대신 화상 경고 연출.
- 캡 테스터 게이지에 '새 캡' 초록 띠(74~103) / '최소' 빨간 선(59) [5].

---

## 부품: 보조탱크 (Coolant Reservoir / Overflow·Expansion Tank)
- ① 하는 일: 데워져 부푼 냉각수를 받아 두는 탱크. 넘치면 땅으로 흐르거나 통에 모였다가 일부는 다시 빨려 들어감; 탱크가 마르면 냉각수가 끓어 과열될 수 있음 [1].
- ② 모양: 반투명 플라스틱 통 옆에 **F(Full)·L(Low)** 줄 [7] (Hyundai 는 MAX(F)·MIN(L) [21]).
- ③ 위치: Camry XV70 엔진룸 오른쪽 앞 [2].
- ④ 확인: **엔진이 차가울 때** F~L 사이면 정상, L 이하면 F 까지 보충 [7]. 물만 넣지 말 것(정비 매뉴얼) [6]. 급할 땐 물도 가능(오너 매뉴얼, 비상용) [14].
- ⑥ 게임: 탱크 옆면 액체 높이를 F/L 줄과 비교 — 가장 쉬운 '눈 진단'.

---

## 부품: 전동 냉각팬 + 슈라우드 (Electric Cooling Fan & Shroud)

### ① 하는 일
- 정차·저속에서도 바람을 만들어 줌; 온도 스위치 또는 엔진 컴퓨터가 제어 [1].
- A25A Camry: **팬 1개(큰 지름)**, 별도 제어 유닛이 냉각수 온도·냉매 압력·차속·엔진 rpm 을 보고 속도 결정 [17]. PWM 가변 속도 **브러시리스** 팬, PCM 과 통신선, 액티브 셔터(그릴 개폐) 포함 [16].

### ②·③·④
- 라디에이터 뒷면에 슈라우드째 걸쇠 2 + 가이드 2, 모터 커넥터 1(잠금 레버) [3][4]. 슈라우드·모터·팬·드레인 플러그가 한 그림에 묶여 있음 [17].
- **주의**: 엔진이 꺼져 있어도 팬이 돌 수 있음 → 손·옷·공구 조심, 시동 끄기 또는 배터리 − 분리 [21].

### ⑤ 흔한 고장 (Camry XV70 문제 증상표)
| 증상 | 의심 순서 (확률순) [13] | 진단 | 수리 |
|---|---|---|---|
| 팬이 안 돎 (막히는 길에서만 과열) | 1 냉각수 온도 센서 → 2 EFI-MAIN No.1 릴레이 → 3 팬 회로 → 4 팬·모터 → 5 ECM | **퓨즈 먼저** [13]. 시동 직후 에어컨 켜면 팬이 돌아야 정상(소리·바람 확인, 영하에선 안 돌 수 있음) [14] | 원인 부품 |
| 팬이 안 멈춤 | 1 냉각수 온도 센서 → 2 팬 회로 → 3 팬·모터 → 4 ECM | | |
| 팬 속도가 안 바뀜 | 1 팬 회로 → 2 팬·모터 → 3 ECM | | |

### ⑥ 게임 손맛
- 에어컨 버튼 켜기 → 팬 도는지 귀 대 보기(실제 오너 매뉴얼 점검법 [14]).

---

## 부품: 물펌프 (Water Pump / Coolant Pump)

### ① 하는 일
- 원심 펌프로 냉각수를 돌림 — 자연 대류만으로는 너무 느림 [1].

### ② 구동 방식 — 차마다 다름
- **Toyota A25A-FKS (Camry XV70): 전기 물펌프** — "전기 펌프, 전기 써모스탯, 차단 밸브" 의 새 냉각계 [17]; PCM 제어, 냉간 시동 초반엔 아예 안 돌려 엔진·촉매를 빨리 데움 [16]; 매뉴얼 부품명 "ENGINE WATER PUMP ASSEMBLY (WATER INLET HOUSING)" + 전기 커넥터 [9]. **벨트에 안 걸림** — 벨트는 크랭크·발전기·에어컨만 [32][17].
- 같은 계통에 차단 밸브 2개: FSV1 = 히터 코어 쪽, FSV2 = 변속기 오일(ATF) 워머 쪽 [16].
- 일반(기계식 펌프) 엔진: 서펜타인 벨트가 물펌프를 돌리는 경우가 있어, 벨트가 상하거나 느슨하면 냉각수 흐름이 느려져 과열 → AAA 는 물펌프보다 벨트를 먼저 보라고 함 [22].
- Honda Accord 1.5T/2.0T, Hyundai G2.5, Nissan Altima 2.5 의 구동 방식 (확인 못 함). 현대 G2.5 에는 '통합 열관리 모듈(ITM)' 관련 서비스 공지가 있다는 검색 결과를 봤지만 PDF 본문을 못 읽음 (확인 못 함).

### ③ 위치 (A25A)
- 실린더 블록에 볼트로 붙음 [9], **에어컨 압축기 바로 위** [16]. 떼려면 발전기 → 써모스탯 달린 냉각수 입구(water inlet) 순서로 먼저 떼야 함 [10][9].

### ④ 붙어 있는 방식 (A25A, XV70 매뉴얼)
- **볼트 4개 → 블록, 43 N·m (32 ft·lbf)** [9].
- 센서 배선 고정 볼트 1개, **8 mm 소켓, 10 N·m** [9].
- 커넥터 2개(펌프, 센서 배선) [9].
- 개스킷은 **재사용 불가** → 새 것, 맞닿는 면 청소 [9].
- 배터리 분리 후 조향각 센서 영점 등 보정 필요 [9].

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 펌프 아래 **작은 구멍(weep hole)** 에서 냉각수 스밈 | 축 씰 마모 [28] | 눈: 구멍 주위 냉각수 자국 [28] | 교체 |
| 펌프와 엔진이 맞닿는 면에서 샘 | 더 급한 고장 — 펌프 자체 또는 엔진과의 씰 [28] | 눈 | 교체 |
| 돌 때 갈리는·끽 소리, 펌프가 손으로 흔들림 | 풀리 헐거움·베어링 마모(기계식) [28] | 손으로 흔들어 보기 [28] | 교체 |
| 하우징 가장자리 곰보 자국 | 캐비테이션 — 공기 섞임·잘못된 냉각수 비율 [28] | 눈 | 교체 + 공기 빼기 |
| 과열 | 금 → 압력·흐름 저하 [22] | 압력 시험 [6] | 교체 |
| (A25A 전기 펌프) 고장 코드 | 회로 단선·단락, 신호 없음, 걸림, 과속 → 코드 + 일부는 rpm 제한 '림프 모드' [16] | 스캐너 | 교체 |

- 물펌프 수명: 대부분 6만~10만 마일 [22]. 물펌프 또는 써모스탯 교체 비용 $300~700 [23]. 공임 시간 (확인 못 함).

### ⑥ 게임 손맛
- A25A 처럼 **전선이 꽂힌 물펌프** = "전기 펌프는 벨트가 없어요" 퀴즈 (시대 차·옛날 차는 벨트 구동 — era 차와 대비).
- weep hole 자국 데칼 → 청진기·눈 진단.

---

## 부품: 써모스탯 (Thermostat)

### ① 하는 일
- 왁스 알갱이 밸브: 엔진이 차가우면 거의 닫혀 라디에이터를 건너뛰게 하고, 적정 온도가 되면 열림 [1].
- A25A: 전기로 데우는 히터가 붙은 '맵 제어' 써모스탯 — PCM 이 히터를 켜 더 일찍 열게 함 [16][17].

### ② 수치 (Camry XV70 A25A 매뉴얼)
- 열리기 시작: **80~84 °C (176~183 °F)** [11] (Dynamic Force 기사도 같은 범위 [16][17]).
- 밸브 들림: 95 °C(203 °F)에서 **8.0 mm 이상** [11].
- 72 °C(162 °F) 밑에선 완전히 닫혀야 [11].
- 히터 저항(단자 1-2): **10.6~14.2 Ω** [11].
- 다른 차 개방 온도 (확인 못 함).

### ③ 위치 · ④ 다는 방식 (XV70)
- '써모스탯 달린 냉각수 입구(water inlet with thermostat sub-assembly)' 한 덩어리, **아래 라디에이터 호스(No. 2)** 와 No. 7 바이패스 호스가 연결 [12][10].
- 떼는 순서 [10]: 냉각수 빼기 → **발전기 떼기** → No. 2 라디에이터 호스 분리 → 입구 커넥터 분리 → No. 7 바이패스 호스 클립 밀고, 호스를 돌려 곧게 뽑기(힘 주지 말 것) → **8 mm 소켓으로 볼트 2개** → 개스킷 떼기.

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 엔진이 잘 안 데워짐, 히터 약함, 연비↓, 온도계 낮음, **P0128** | 써모스탯 열린 채 고착, 냉각수 온도 센서, 팬 계속 돎, 흡기온 센서, 추운 날 짧은 주행 [25] | 라디에이터 호스가 데워지는 속도: 느리면 써모스탯 열림 고착, 너무 빠르면 센서 [25]. 스캐너 온도 vs 계기판 비교, 정상 약 200°F [25] | 교체 (A25A 는 발전기를 먼저 떼야 해서 일이 커짐 [10]). 공임 시간 (확인 못 함). 물펌프·써모스탯 교체 비용 $300~700 [23] |
| 과열 | 닫힌 채 고착, 스프링 부러짐·걸림 [22] | 압력 시험·온도 확인 | 교체 |
| 쿵쿵(thumping) 소리 | 써모스탯 문제 신호 [22] | 소리 | 교체 |
| (A25A) 써모스탯 검사 불합격 | 개방 온도·들림·저항 벗어남 [11] | 물에 넣고 데우며 재기, 저항 측정 [11] | 냉각수 입구째 교체 [11] |

### ⑥ 게임 손맛
- 냄비 물에 써모스탯 넣고 온도 올리기 → 80 °C 근처에서 '딸깍 열림' 보기(실제 매뉴얼 검사 [11]).
- 히터 붙은 써모스탯은 멀티미터로 Ω 재기 미니 단계 [11].

---

## 부품: 위·아래 라디에이터 호스 + 클램프 (Upper/Lower Radiator Hoses & Spring Clamps)
- ① 위 호스 = 엔진 → 라디에이터, 아래 호스 = 라디에이터 → 엔진(A25A 는 써모스탯 입구 쪽) [3][12].
- ② Camry XV70: No. 1(위)·No. 2(아래) 호스, **미는 스프링 클립** [3][4].
- 스프링 클램프 = 띠 모양 스프링강을 말아 만든 링, 귀(tab)를 플라이어로 눌러 벌려서 끼움/뺌; 지름 몇 인치 냉각 호스에 흔함; 좁은 곳에 좋아 엔진룸에서 인기 [30]. 나사(worm-drive) 클램프는 나사로 띠를 조임 [30].
- ⑤ 고장 [31] (대형차 교재 기준, 원리는 같음): **전기화학적 열화(ECD)** — 호스·냉각수·금속 이음이 전지처럼 0.1~0.3 V 를 만들어 **금속 끝에서 2인치(50 mm) 안쪽**을 먼저 상하게 함. 엔진이 완전히 식은 뒤 끝 부분을 눌러 말랑하면 의심(교재) [31].
- 막힌·새는 호스도 과열 원인(잘못된 냉각수 찌꺼기·금) [22].
- ⑥ 게임: 호스 끝 2인치 '말랑 지점' 누르기 진단, 스프링 클램프 플라이어 손맛.

## 부품: 히터 코어 (Heater Core) — 짧게
- 대시보드 아래 공조 덕트 안의 작은 라디에이터; 송풍기 바람이 핀을 지나며 데워짐 [29].
- 고장: 달콤한 냄새(첫 신호), 앞유리 김(기름진 막), 바닥 젖음, 막히면 난방 약함·없음; 교체는 대시보드를 많이 뜯어야 해서 비쌈 [29].
- A25A: 히터 코어로 가는 흐름을 FSV1 밸브가 열고 닫음 [16].

## 부품: 냉각수 (Coolant / Antifreeze) — 종류·색
- 기본: 에틸렌글리콜 + 물 + 부식 방지제. 50:50 이면 약 −34 °F(−37 °C)까지 [18]. 사람·동물에게 독, 달콤 씁쓸한 맛 [18]. 누수 냉각수는 달콤한 냄새 [22].
- 기술 종류 [18]: OAT(유기산, 예 DEX-COOL, 주황 염료), HOAT(OAT + 규산염), P-HOAT(인산염, 아시아 차, 흔히 빨강·파랑), Si-OAT(유럽 차, 흔히 분홍). 옛 일반 냉각수는 초록·노랑 [18].
- 색은 구분 '도우미'일 뿐 — AAA 는 냉각수 색이 노랑·주황·빨강·초록·파랑·보라 모두 가능하다고 함 [22].

| 차 | 냉각수 | 색 | 메모 |
|---|---|---|---|
| Toyota (Camry) | Toyota Super Long Life Coolant (SLLC), 에틸렌글리콜 계열 [7] | **분홍** [19] | 미국판 50 % 냉각수 + 50 % 탈이온수 미리 섞음, −35 °C(−31 °F)까지 [7]. 첫 교환 10만 마일/10년, 이후 6만 마일/5년 [19]. 옛 '빨강' Long Life 는 원액(희석 필요) [19] |
| Honda | Honda Type 2 | **파랑** [20] | 50:50 미리 섞음, 희석 금지, −34°F / 265°F, 5년·6만 마일(판매처 표기) [20]. Honda 는 2-EHA 를 뺀 OAT 계열 [18] |
| GM | DEX-COOL | **주황** [18] | OAT [18]. 교환 주기 (확인 못 함 — GM 공식 페이지 못 엶) |
| Hyundai (Sonata DN8) | **인산염 계열 에틸렌글리콜**(알루미늄 엔진 부품 보호) [21] | (확인 못 함 — 매뉴얼에 색 없음, 2차 출처는 파랑·초록·분홍으로 엇갈림) | 부동액 35~60 %, 50:50 이면 −35 °C 까지, 증류수·탈이온수만 [21] |
| Nissan | (확인 못 함) | (확인 못 함) | |
| 옛 일반(IAT) | 규산염 계열 | 초록·노랑 [18] | 교환 주기 (확인 못 함) |

- 섞지 말 것: Honda Type 2 판매처는 초록·분홍·주황·노랑과 섞지 말라고 표기 [20]; Toyota 는 첨가제 쓰지 말 것 [14].

## 부품: 냉각수 온도 센서 (ECT Sensor) — 짧게
- NTC 서미스터: 온도가 오르면 저항이 내려감, ECM 이 5 V 를 저항 통해 보내고 전압으로 읽음 (Saab 예: 20 °C 3550 Ω, 100 °C 180 Ω — 차마다 값 다름) [27].
- P0117 = 회로 낮음(접지 단락), P0118 = 높음(+ 단락·단선); Saab 기준 0.2 V 미만 / 4.9 V 초과가 0.6초 → 고장 시 대체값 사용, 팬 계속 돎, 공회전 높음 [26].
- Camry 팬 문제 증상표에서 '팬 안 돎'·'팬 안 멈춤' 둘 다 1순위 의심 = 냉각수 온도 센서 [13].
- A25A 에서 센서 자리 (확인 못 함).

## 온도계 · 경고등 (Temp Gauge / High Coolant Temp Warning) — 짧게
- Toyota: 고온 경고등(부저 + 화면 메시지) = 냉각수 온도 너무 높음 → 즉시 안전한 곳에 세우기 [15].
- 과열 대처(Camry 오너 매뉴얼) [14]: 세우기 → 에어컨 끄고 엔진 끄기 → 김 가라앉을 때까지 보닛 열지 말기 → 식은 뒤 호스·라디에이터 누수 보기 → 탱크 F~L 확인·보충(뜨거울 때 천천히) → 시동 걸고 에어컨 켜서 팬 도는지 → 안 돌면 즉시 끄고 딜러.
- AAA 는 운전자가 직접 보충하고 계속 달리는 건 위험, 견인 권장 [22]. 온도계는 써모스탯이 정상일 때만 믿을 수 있음 [22].

## 공기 빼기 (Bleeding / Burping)
- 왜: 공기가 섞이면 캐비테이션(물펌프 곰보)·과열 [28][1].
- **Camry A25A (전기 펌프)**: EGR 밸브 퀵커넥트에서 공기 빼기 → 엔진 3,000 rpm 으로 돌려 **냉각수 채우기 모드(Engine Coolant Filling Mode)** 진입(보통 3번째 사이클) → 스캐너로 물펌프 약 5,250 rpm, FSV 둘 다 열림 확인 [16]. 즉 "캡 열고 공회전 기다리기" 만으로는 이 엔진은 부족.
- 기계식 펌프 일반 차의 '캡 열고 공회전' 절차 출처는 못 열었음 (확인 못 함).
- 냉각수 용량 (확인 못 함).

---

## 내부 도안 근거 (정비 매뉴얼 그림·분해도·배치도 — 본 것과 '어디에 무엇이')
- Camry XV70 엔진룸 배치도 [2] (wr-carbook 직접 확인, diagrams/index.md): 가운데 앞 = 라디에이터·전동팬·콘덴서, 오른쪽 앞 = 냉각수 보조탱크·워셔액 탱크, 왼쪽 = 배터리·브레이크액·퓨즈 박스.
- Camry XV70 라디에이터 분해도 [4] (wr-carbook 직접 확인, diagrams/index.md): 앞→뒤 콘덴서(걸쇠 2 + 가이드 2) / 라디에이터(아래 받침 2 + 고무 쿠션 2, 위 브래킷 2: 볼트 2 + 너트 2, 위 서포트 볼트 4) / 팬 슈라우드 + 팬 1 + 모터 커넥터. 호스 No.1(위)·No.2(아래) 스프링 클립, 주입구 목에 No.5·No.6 바이패스 호스.
- A25A 냉각 계통 그림 [17]: 그림 설명 "1 라디에이터, 2 보조탱크, 3 써모스탯 달린 냉각수 입구, 4 물펌프, 5 실린더 블록". 라디에이터 부품 그림: "1 라디에이터 캡, 2 팬 슈라우드, 3 팬 모터, 4 팬, 5 드레인 플러그".
- A25A 써모스탯 분해도 [12] (wr-carbook 직접 확인, diagrams/index.md): 냉각수 입구(써모스탯) ← No. 2 라디에이터 호스, No. 7 바이패스 호스(슬라이드 클립), 개스킷, 볼트 2(8 mm), 전기 커넥터 1.
- 물펌프 [9]: 블록에 볼트 4, 센서 배선 볼트 1, 커넥터 2, 개스킷. 위치는 에어컨 압축기 위 [16].

## car_spec · fault_catalog 와 다른 점
1. **라디에이터 고정** car_spec "2 (위 브래킷)" / 4-2 "+ 호스 클램프 2" — XV70 실제: 위 브래킷 2개(볼트 2 + 너트 2) + 위 서포트(볼트 4), 아래는 고무 쿠션 2개에 얹힘, 호스는 위·아래 2 + 바이패스 2, 팬 커넥터 1 [3][4]. 그리고 **위로 빼려면 헤드라이트·범퍼 보강재·보닛 잠금장치·에어클리너를 먼저 뗌** [3]. 게임 단순화는 OK 지만 'Requires' 에 Bumper_F(또는 보강재)를 넣으면 실제와 가까움.
2. **RAD_LEAK "green puddle"** — 기준 차 Camry 는 **분홍**(SLLC) [19], Honda 는 **파랑** [20], GM 주황 [18]; 초록은 옛 일반 냉각수 [18]. → 웅덩이 색을 차 브랜드에 맞추면 진짜 같고, '색으로 차 맞히기' 재미도 생김. fault_catalog 의 "초록·주황" 표현은 Camry 와 안 맞음.
3. **공기 빼기 "시동 켜고 캡 열고 기다리기"** — A25A 는 전기 물펌프라 **냉각수 채우기 모드(3,000 rpm 사이클 + 스캐너 확인)** + EGR 퀵커넥트 공기 빼기 [16]. 기계식 펌프 차에만 단순 방식이 맞을 수 있음 (확인 못 함).
4. **RAD_FAN "라디에이터 세트(팬 포함) 교체"** — XV70 매뉴얼은 팬이 안 돌 때 **냉각수 온도 센서 → EFI-MAIN 릴레이 → 회로 → 팬·모터 → ECM** 순으로 의심, 퓨즈 먼저 [13]. 팬은 '팬 + 모터 조립체' 로 따로 부품 [13]. 그리고 팬 점검은 "에어컨 켜면 팬이 돌아야 함" [14]. → 헷갈리는 짝(센서 vs 팬 모터)으로 쓰기 좋음.
5. **캡 압력** — 흔히 말하는 "16 psi(108 kPa)" 는 XV70 매뉴얼과 다름: 새 캡 74~103 kPa(10.7~14.9 psi), 최소 59 kPa, 계통 시험 103 kPa(15 psi) [5][6]. Pressure Tester 연출도 '김 나옴' 보다 **게이지 바늘이 떨어지는 것 + 새는 자리 방울** 이 실제 판정 [6].
6. **물펌프 = 벨트** 라는 일반 상식이 A25A 에선 틀림 — 벨트는 크랭크·발전기·에어컨만 [32], 물펌프는 전기식 [17][9]. fault_catalog 2장 Alternator(벨트) 고장에 과열을 묶지 말 것.
7. **RAD_CLOG 압축공기 청소** — 실제 매뉴얼도 공기(0.4 MPa)+물안개 청소 후 재검사 [5] → 미니게임 근거 있음. 다만 "앞 핀 이물질" 은 **콘덴서 앞**에 먼저 쌓임(라디에이터 앞에 콘덴서가 붙어 있음 [4]) → 둘 다 닦는 절차 [5].
8. **연기 색 규칙(흰 김 = 냉각수)** — AAA·Toyota 모두 과열 때 보닛 밑 김을 신호로 적음 [14][22]. 일치.
9. **Radiator 무게 7 kg, 크기 4.2 × 1.8 × 0.6** — 실제 값 (확인 못 함).

## 출처
1. Radiator (engine cooling) — Wikipedia — https://en.wikipedia.org/wiki/Radiator_(engine_cooling)
2. Camry XV70 Owner's Manual: Engine compartment (A25A-FKS) — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/engine_compartment-1984.html
3. Camry XV70 Repair Manual: Radiator Removal — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/removal-3647.html
4. Camry XV70 Repair Manual: Radiator Components — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/components-3645.html
5. Camry XV70 Repair Manual: Radiator On-vehicle Inspection (cap test, fin cleaning) — tocamry.com — https://www.tocamry.com/on_vehicle_inspection-3646.html
6. Camry XV70 Repair Manual: Cooling System (pressure test) — tocamry.com — https://www.tocamry.com/cooling_system-3629.html
7. Camry XV70 Owner's Manual: Engine coolant — tocamry.com — https://www.tocamry.com/engine_coolant-1986.html
8. Camry XV70 Repair Manual: A25A-FKS Coolant — tocamry.com — https://www.tocamry.com/coolant-3615.html
9. Camry XV70 Repair Manual: A25A-FKS Water Pump — tocamry.com — https://www.tocamry.com/water_pump-3654.html
10. Camry XV70 Repair Manual: Thermostat Removal — tocamry.com — https://www.tocamry.com/removal-3651.html
11. Camry XV70 Repair Manual: Thermostat Inspection — tocamry.com — https://www.tocamry.com/inspection-3652.html
12. Camry XV70 Repair Manual: Thermostat Components — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/components-3650.html
13. Camry XV70 Repair Manual: Cooling Fan System Problem Symptoms Table — tocamry.com — https://www.tocamry.com/problem_symptoms_table-3620.html
14. Camry XV70 Owner's Manual: If your vehicle overheats — tocamry.com — https://www.tocamry.com/if_your_vehicle_overheats-2017.html
15. Camry XV70 Owner's Manual: If a warning light turns on — tocamry.com — https://www.tocamry.com/if_a_warning_light_turns_on_or_a_warning_buzzer_sounds-2008.html
16. Toyota's Dynamic Force Engines — Vehicle Service Pros — https://vehicleservicepros.com/service-repair/diagnostics-and-drivability/article/55037008/toyotas-dynamic-force-engines
17. Toyota engines A25·M20 Dynamic Force series (R4) — toyota-club.net — https://toyota-club.net/files/faq/18-03-20_faq_df_r4_eng.htm
18. Antifreeze — Wikipedia — https://en.wikipedia.org/wiki/Antifreeze
19. What Makes Toyota's Super Long Life Coolant So Good? — SlashGear — https://www.slashgear.com/1563642/about-toyota-super-long-life-coolant
20. Honda Type 2 Anti-Freeze Engine Coolant OL999-9011 — Hybrid Racing (판매처 페이지) — https://www.hybrid-racing.com/collections/all/products/honda-type-2-anti-freeze-engine-coolant-ol999-09011
21. Hyundai Sonata (DN8) Owner's Manual: Checking the coolant level — Hyundai — https://ownersmanual.hyundai.com/full_webhelp/DN8/2025/en_AU/id3d03de2299e.html
22. Car Overheating: 8 Causes and Solutions — AAA — https://www.aaa.com/autorepair/articles/car-overheating-8-causes-and-solutions
23. 13 Common Car Problems Explained — AAA — https://www.aaa.com/autorepair/articles/13-common-car-problems-explained
24. P0217 Code — Kelley Blue Book — https://www.kbb.com/obd-ii/p0217/
25. P0128 Code — Kelley Blue Book — https://www.kbb.com/obd-ii/p0128/
26. P0117, P0118 (Saab 9-5 WIS) — saabwisonline — https://saabwisonline.com/9-5-9600/2002/2-engine/psg-16-d223l/fault-diagnosis-diagnostic-trouble-codes/p0117-p0118
27. Temperature sensor, engine coolant (Saab 9-5 WIS) — saabwisonline — https://saabwisonline.com/9-5-9600/2002/2-engine/engine-management-system-v6-diesel/technical-description/temperature-sensor-engine-coolant
28. Five Signs That A Water Pump Failure is Near — GMB — https://gmb.net/blog/cummins-water-pump-failure/
29. Heater core — Wikipedia — https://en.wikipedia.org/wiki/Heater_core
30. Hose clamp — Wikipedia — https://en.wikipedia.org/wiki/Hose_clamp
31. 1.3 Radiators, Hoses, Belts, Pulleys & Fan Clutches (ASE T8, 대형차 교재) — open-exam-prep — https://open-exam-prep.com/study-guides/ase-t8/engine-systems-lube-cooling/radiators-fans-belts-pulleys
32. Camry XV70 Repair Manual: A25A-FKS Drive Belt Installation / Components — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/installation-2081.html , https://www.tocamry.com/components-2079.html
