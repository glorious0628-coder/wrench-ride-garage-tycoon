# 전기·조명 (Electrical & Lighting — 12 V, fuses, relays, harness, lights, OBD-II)

> 기준 차: 가로배치 직렬 4기통 앞바퀴굴림(FF) 중형 세단, 미국 왼쪽 운전석 (예: Toyota Camry XV70/XV80, Honda Accord 10·11세대, Hyundai Sonata DN8, Nissan Altima L34).
> 차 안 좌표·이름은 `docs/specs/car_spec.md` 기준(앞 = −Z, 운전석 = −X). Battery (−2.2, 1.55, −6.6).
> 출처는 각 줄 끝 [n] → 맨 아래 '출처' 목록. 출처 없는 문장은 쓰지 않아요.
> "(검색 요약)" = 페이지가 막혀 검색 결과 요약으로만 본 것. "(확인 못 함)" = 출처를 못 찾음. "(추론)" = 출처 둘을 이어 낸 결론.
> 배터리·발전기·시동모터·**기생 전류(parasitic draw, 50 mA 기준)** 는 [01_starting_charging.md](01_starting_charging.md) — 여기선 이어지는 것만.

## 한눈에 (3줄)
- 지도: **배터리 → 엔진룸 퓨즈·릴레이 박스(1~2개) → 운전석 계기판 아래 퓨즈 박스(정션 블록) → 각 장치 → 차체로 접지(−)**; 컴퓨터끼리는 **CAN 통신(캠리 버스 5개)**, 진단은 **DLC3(OBD-II 16핀)** → 게이트웨이 ECU [1][2][3][18].
- 캠리 XV70 헤드라이트는 **본 램프가 LED라 전구 교체 X**(뭉치째), 갈 수 있는 건 **방향지시등·옆 표시등 전구**; 뭉치는 **앞 범퍼를 뗀 뒤 볼트 1 + 나사 3** [5][6][9].
- 퓨즈는 **같은 암페어로만** 교체, 또 끊어지면 원인(과부하) 수리; 철사로 대신 X [2]. 색 = 5 A 황갈, 10 A 빨강, 15 A 파랑, 20 A 노랑, 25 A 투명, 30 A 초록, 40 A 주황 [16].

---

## 부품: 12 V 시스템 지도 (Battery → fuse/relay boxes → loads → ground)
- **엔진룸**: 캠리 사용설명서 그림에 **퓨즈 박스 2개(양쪽)**, 배터리 = 운전석 쪽 앞 [1] (도안 01).
  - 사용설명서: 엔진룸 **type A**, (있으면) **type B** 퓨즈 박스, 그리고 **운전석 계기판 아래** 박스 — 엔진룸은 탭 누르고 뚜껑 들기, 실내는 걸쇠 눌러 뚜껑 [2].
  - 정비 매뉴얼 이름: **엔진룸 릴레이 블록 & 정션 블록 뭉치**(예: EPS 퓨즈), **계기판 정션 블록 뭉치**(예: IG1-NO.1 릴레이, EPS-IG1 퓨즈) [3].
- 배터리 단자는 **(−) 먼저 풀고**, 새로 달 땐 (+) 먼저 [4].
- **접지(ground)**: 엔진에서 차체로 가는 **엔진 접지선**, 배터리 (−) 케이블. 시동모터 전류는 접지가 나쁘면 **차체로 돌아가다 바디 접지 끈을 달궈 연기**를 내거나, 스로틀·변속 케이블까지 상하게 할 수 있음 [25].
- **CAN 통신(아주 짧게)**: 컴퓨터(ECU)끼리 잇는 **2선 꼬임선(CAN High / CAN Low)**, 양끝에 **120 Ω 저항** [18]. 캠리 XV70 CAN은 **버스 5개**, **DLC3 ↔ 중앙 게이트웨이 ECU**를 잇는 진단 버스가 따로 있음 [15]. 스캔툴이 아무 ECU와도 통신이 안 되면 **게이트웨이 ECU·진단 버스부터** 점검 [15].
- 특징 3개(캐주얼, 퓨즈 박스): ① 검은 **플라스틱 상자 + 딸깍 뚜껑** ② 뚜껑 안쪽 **퓨즈 지도(번호·암페어 표)** ③ 줄 맞춰 꽂힌 **알록달록 작은 퓨즈 + 네모난 릴레이 몇 개**.
- 게임 위치: 엔진룸 퓨즈 박스 = 배터리 옆(car_spec `Deco_EngineBay` '퓨즈·릴레이 박스(배터리 옆)' 맞음) [1]; 실내 박스 = 운전석 무릎 왼쪽 아래 (추론, [2] '운전석 쪽 계기판 아래').

---

## 부품: 퓨즈 (Fuses — blade type)
### ① 하는 일: 너무 큰 전류가 흐르면 **끊어져** 선과 장치를 보호 [2][16].
### ② 모양·크기·색 — 특징 3개
- 칼날형(blade) 크기 6가지: **Micro2 · Micro3 · LP Mini · Mini · Regular(ATO/ATC) · Maxi(대전류)** [16].
- 색(=암페어, Maxi 일부 제외 공통): **5 A 황갈(tan) · 10 A 빨강 · 15 A 파랑 · 20 A 노랑 · 25 A 투명 · 30 A 초록 · 40 A 주황**, 35 A 청록, 70 A 황갈/호박 [16].
- 그 밖: 카트리지(J-case 등), **퓨저블 링크(10 A 넘는 큰 전류용 금속 띠, 배터리 근처)** [16].
- 캠리: 퓨즈 type A·B·C 그림(정상/끊김), **뽑기 집게(pullout tool)는 type A만** 됨, 암페어 표는 **박스 뚜껑**에 [2].
- 특징 3개(캐주얼): ① 손톱만 한 **반투명 색 플라스틱 머리** ② 머리 속에 보이는 **S자 금속 줄(끊기면 가운데가 벌어짐)** ③ 머리 위 **숫자(10, 15…)**.
### ④ 교체 [2]
- 엔진 스위치 OFF → 뚜껑 열기 → 집게로 뽑기 → 끊긴 것 확인 → **같은 암페어** 새 퓨즈.
- 더 큰 암페어·다른 물건·**철사(잠깐이라도)** 금지. 갈았는데 **또 끊어지면** 딜러 점검(과부하 원인 수리).
### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 · 시간 |
|---|---|---|---|
| 한 장치만 갑자기 안 됨(라이트·와이퍼 등) | 퓨즈 끊김 [2] | 눈: 금속 줄 끊김 [2] / 퓨즈 양쪽 전압 | 같은 A 교체(몇 분) [2] |
| 새 퓨즈도 바로 끊어짐 | 합선·과부하 [2] | 원인 회로 추적 | 배선·장치 수리 [2] |
| 밤새 배터리 방전 | 기생 전류 → [01 파일](01_starting_charging.md) | 모듈이 잠들 때까지 **30~120분** 기다린 뒤 퓨즈마다 **mV 전압강하** 재기(퓨즈 뽑으면 모듈이 깨어남) — **50 mA 넘는 회로** 찾기 [24] | 원인 회로 수리 |
### ⑥ 게임 손맛 아이디어 (제안만)
- 뚜껑 안 **퓨즈 지도** 보고 'HEAD LH 10 A' 칸 찾기 → 끊긴 퓨즈는 가운데 줄이 벌어진 그림. 20 A 꽂으면 "Wrong rating" 경고 + 다음 손님 사고 위험 대사.
- '또 끊어짐' 손님 = 숨은 합선 찾기 퀘스트(배선 피복 벗겨진 곳).

---

## 부품: 릴레이 (Relays)
### ① 하는 일: 작은 전류(스위치)로 **큰 전류(전조등 등)를 켜고 끄는 전기 스위치** — 코일에 전기가 들어오면 접점이 붙음 [26](검색 요약).
### ② 모양·단자
- 흔한 번호(보쉬식): 코일 **85·86**, 공통 **30**, 평소 열림 **87**, 평소 닫힘 **87a**; 회사마다 번호가 다를 수 있어 그림 확인 [26](검색 요약).
- 캠리 조명 릴레이: **H-LP LH · H-LP RH · DIM · DRL(LED 방향지시등 차)** — 코일 단자 **1·2**, 접점 단자 **3·5** [11].
- 특징 3개(캐주얼): ① **작은 네모 큐브** ② 바닥 **납작 핀 4~5개** ③ 옆면의 **회로 그림 스티커**.
### ④ 점검 (캠리) [11]
- 1·2에 전압 **안 줄 때** 3–5 사이 **10 kΩ 이상**, **줄 때 1 Ω 미만** — 다르면 교체.
### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 |
|---|---|---|---|
| 한쪽 헤드라이트만 안 켜짐(퓨즈 멀쩡) | 그쪽 **H-LP 릴레이** 접점 불량 [11] | 저항 점검 [11] | 릴레이 교체(꽂기만) |
| 상향/하향 전환 안 됨 | DIM 릴레이 [11] | 같은 점검 | 교체 |
### ⑥ 게임 손맛: 옆 칸 같은 릴레이와 **바꿔 꽂기** → 고장이 따라가면 릴레이(점화코일 바꿔 끼우기와 같은 정비사 요령 — fault_catalog SparkPlugs 아이디어와 짝).

---

## 부품: 배선 하네스·커넥터 (Wiring harness & connectors)
- 커넥터에는 **잠금(lock)** 이 있음: 캠리 랙 하네스 커넥터는 "**잠금을 먼저 풀고**" 뺀 다음 볼트 2로 받침 떼기 [12]. 하네스를 **잡아당기지 말 것**(EPS 경고) [12].
- 헤드라이트 뭉치도 마지막에 **커넥터 각각**을 빼야 빠짐 [6].
- 나쁜 접지·접속의 결과: 1988 어코드 사례 — 방향지시등 등 **부속이 들쭉날쭉**, 부속 많이 켜면 실화, 엔진에서 7.00 V까지 떨어짐 [25].
- 특징 3개(캐주얼): ① 테이프·주름관으로 묶인 **검은 굵은 다발** ② 끝의 **네모 플러그 + 눌러 푸는 탭** ③ 군데군데 **차체에 꽂는 클립**.
### ⑥ 게임 손맛: 커넥터는 **탭 누르기 → 당기기** 2동작(탭 안 누르고 당기면 '삐걱' 실패) — 실제 잠금 구조와 같음.

---

## 고장 공통: 나쁜 접지·전압 강하 (Bad ground / voltage drop)
| 증상 | 원인 | 진단 (실제 숫자) | 수리 |
|---|---|---|---|
| 여러 전기 장치가 **동시에** 이상(깜빡이 들쭉날쭉, 실화) | 엔진·바디 **접지 불량** [25] | **전압강하 시험**(작동 중): 좋은 엔진 접지 **최대 0.36 V**(크랭킹 중), 볼트 느슨하면 **1.17 V**(3배↑, 그래도 시동은 걸림) / 배터리 케이블 1개당 한계 **0.50 V** / 바디 접지 부속 켜고 **약 0.50 V 넘으면** 수리 [25] | 접지 볼트 닦고 조이기, 끈 교체 [25] |
| 바디 접지 끈이 달아오르거나 연기 | 엔진 접지 끊김 → 시동 전류가 차체로 [25] | 눈·냄새 | 엔진 접지 수리 |
| 라이트가 **어두움** | 접지·전압 강하 (추론, [25]) / 렌즈 변색(아래) [23] | 전압강하 시험 / 렌즈 보기 | 원인별 |
- 접지 불량은 **저절로 낫지 않고**, 증상이 늦게 나타날 수 있음 [25].
- ⑥ 게임: 멀티미터 '전압강하 모드' — 빨간 탐침·검은 탐침을 접지 볼트 양쪽에 대고 0.36 / 1.17 V 읽기.

---

## 부품: 헤드라이트 뭉치 (Headlamp assembly — LED vs halogen)
### ① 하는 일 / 종류
- 할로겐 전구는 필라멘트, HID는 **전기 아크**로 빛남 [19]. LED 헤드램프는 요즘 차(캠리 XV70)의 본 램프 [5][9].
- **DRL(주간주행등)**: 캠리 미국형 — 시동 켜짐 + **주차 브레이크 풀림** + 스위치가 AUTO(또는 해당 위치)일 때 자동으로 켜짐, 한 번 켜지면 주차 브레이크 다시 걸어도 유지; **type A = 헤드라이트를 어둡게**, **type B = 주차등을 밝게** 써서 DRL로 [10]. 미국형만 스위치로 끌 수 있음 [10].
### ② 실제 모양·구성 — 특징 3개
- 캠리 헤드라이트 부품도: **헤드라이트 뭉치**, **앞 옆표시등(side marker) 소켓 마개·전구**, **앞 방향지시등 전구·소켓**, **헤드라이트 뒤 덮개**, 헤드라이트 커버; 방향지시등이 **LED형 / 전구형** 두 가지 [5].
- 사용설명서 '전구형(bulb type)'으로 직접 갈 수 있는 것: **앞 방향지시등·주차등, 앞 옆표시등, 후진등, 뒤 방향지시등, 뒤 옆표시등** — 그 밖의 전구는 딜러 [9].
- 할로겐 차(2015~17 캠리 = XV70 이전 세대, 할로겐 헤드램프 트림): **하향 H11, 상향 9005(HB3)** [27](검색 요약). 와트: **H11 = 55 W @12 V**, **HB3 = 65 W @12.8 V**, H4 = 60/55 W(한 전구로 상·하향) [19].
- 렌즈는 플라스틱 위에 **보호 코팅** — 햇빛(UV)이 코팅을 망가뜨려 **누렇게·뿌옇게** 됨 [23].
- 특징 3개(캐주얼): ① **투명 커버 안 반짝이는 반사경(또는 LED 줄)** ② 바깥쪽 끝 **호박색(amber) 방향지시등 칸** ③ 뒤쪽 **둥근 마개(전구 소켓) + 커넥터**.
### ③ 위치: 앞 범퍼 커버 위·안쪽, 범퍼 보강재(철 빔) 위 좌우 (도안 03, diagrams/index.md) — car_spec `Headlight_L/_R` 위치 감 맞음.
### ④ 떼는 순서 (캠리 XV70) [6]
1. **앞 범퍼 뭉치 떼기** (범퍼 순서는 diagrams/index.md 02·03: 클립 9 + 나사 8 + 볼트 4 + 걸쇠 12) [8].
2. 헤드라이트 둘레에 **보호 테이프**.
3. **볼트 1 + 나사 3** 풀기.
4. **가이드**를 빼며 그림 방향으로 빼냄.
5. (전구형 방향지시등 차) 클램프 풀기 → **커넥터 각각** 빼기.
- 조이는 힘: 부품도에 토크 표는 있으나 숫자는 그림 속 (확인 못 함) [5].
- 시간: (확인 못 함).

### 헤드라이트 조준 (Headlight aiming) [7][19]
- 준비(캠리): 타이어 공기압 맞춤, **연료 가득**, 오일·냉각수 정량, 트렁크 비우고 스페어·공구·잭은 제자리, **운전석에 평균 체중(68 kg, 150 lb) 1명** [7].
- 어두운 곳에서 컷오프선(빛의 위 경계)이 보이게, 차를 벽(스크린)에 **90°** 로 세움 — 거리·목표 높이 숫자는 본문에서 못 읽음 (확인 못 함) [7]. 조준기(aim test machine)가 있으면 기계 설명서대로 [7].
- 미국 SAE식 헤드램프는 **장착 높이와 상관없이** 조준(유럽 ECE는 높이에 따라) [19].

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 · 시간 |
|---|---|---|---|
| "헤드라이트 하나가 나갔어요" (할로겐 차) | 전구 필라멘트 끊김 (추론, [19]) / 퓨즈 [2] / H-LP 릴레이 [11] | 켜 보기 → 퓨즈 → 릴레이 저항 [11] → 전구 | 전구 교체(차에 따라 범퍼 뗌) |
| 같은 증상 (**캠리 XV70 LED**) | LED 램프는 사용자 교체 전구 없음 [9][5] | 퓨즈·릴레이 먼저 [2][11] | **뭉치째 교체**(범퍼 떼고 볼트 1 + 나사 3) [6] |
| **뿌옇고 누런 렌즈**, 밤에 어두움 | UV로 보호 코팅 분해 [23] | 눈: 렌즈 너머 전구가 잘 안 보이면 [23] | AAA 시험(약 11년 된 세단 2대): 바랜 하향등 = 새것의 **22%** 빛; **복원(연마) → 약 70%**(단 눈부심 DOT 기준 초과), **순정 교체 → 100%**, 사제 83~90% [23]. 빠르면 **3~5년**부터 바램 [23] |
| 방향지시등이 **빨리 깜빡임(hyperflash)** | 전구 하나 끊김 → 운전자에게 알리려고 **평소보다 훨씬 빠르게/느리게** 깜빡이게 함 [20] / LED로 바꿔 전류가 적어 '전구 끊김'으로 착각 [28](검색 요약) | 정상 속도 = **분당 60~120번(1~2 Hz)** [20] | 전구 교체 / LED면 부하 저항·LED용 플래셔 [28](검색 요약) |
| 빛이 너무 높음·낮음(맞은편 번쩍) | 조준 틀어짐(충돌·뭉치 교체 뒤) | 조준 준비 조건 맞추고 스크린/조준기 [7] | 조준 나사 조정 [7] |

### ⑥ 게임 손맛 아이디어 (제안만)
- **연도 따라 다른 수리**: 옛 차(할로겐) = 뒤 마개 돌려 H11 전구 갈기, 요즘 차(LED) = 범퍼 떼고 뭉치째. 같은 손님 대사 "One of my headlights is out."이 차 연식에 따라 다른 일로 — era_cars와 연결.
- **렌즈 복원 미니게임**: 사포 단계(거친 → 고운) → 광택 → **UV 코팅** 마무리. 코팅 빼먹으면 몇 게임일 뒤 다시 누래짐(AAA '복원 70%' 근거로 교체보다 싸지만 덜 밝음).
- **조준 벽**: 차를 벽에 90°로, 운전석에 68 kg 더미 앉히기, 컷오프선을 테이프 선에 맞추기.

---

## 부품: 뒤 등·방향지시등 (Taillights, brake lights, turn signals, side markers)
- 미국 규칙: 앞 옆표시등 **호박색**, 뒤 옆표시등 **빨강** + 반사판 필수 [20]. 미등(뒤 위치등)은 **빨강만**, 브레이크등은 미등보다 **밝은 빨강** [20]. 미국은 뒤 방향지시등이 **빨강도 허용**(대부분 다른 나라는 호박색 필수) [20].
- LED 미등은 1993년 양산차에 처음 [20]; 꺼져 있으면 **무색**으로 보일 수 있음 [20].
- 캠리 사용설명서상 사용자 교체 가능 뒤 전구: **후진등, 뒤 방향지시등, 뒤 옆표시등** [9]. 와트·전구 번호는 페이지에 없음 (확인 못 함).
- 특징 3개(캐주얼): ① 뒤 모서리 감싸는 **빨간 가로 긴 렌즈** ② 그 안 **흰 칸(후진등)** ③ 옆구리로 이어진 **작은 빨간 반사판**.
- car_spec 후보 `Taillight_L/R`와 연결 가능.

---

## 부품: OBD-II 단자 (DLC — Data Link Connector) + 스캔툴
### ① 하는 일 / 규칙
- 1996년부터 미국 승용차·8,500 lb 미만 가솔린 경트럭은 **OBD-II 필수** [17].
- 단자 = **SAE J1962 16핀(2×8) 암(female) 커넥터**, 12 V 차는 type A, **핸들에서 2 ft(0.61 m) 안**에 있어야 함(면제 제외) [17].
- 핀: **16 = 배터리 +12 V**, **4 = 차체 접지**, **5 = 신호 접지**, **6 = CAN High**, **14 = CAN Low** [17]. 2008년부터 미국 판매 차는 모두 **ISO 15765-4(CAN 방식)** [17].
- 흔한 자리 = **운전석 쪽 핸들 아래**, 덮개로 가려진 경우도 있음 [29](검색 요약).
- 캠리 XV70: 이름 **DLC3**, 전 차종에 있음, 진단 버스로 **중앙 게이트웨이 ECU**에 연결 [15]. 캠리의 정확한 자리 그림 설명 문장은 (확인 못 함) [30].
### ② 모양 — 특징 3개
- ① **사다리꼴(D자) 플라스틱 소켓** ② 위아래 2줄 **구멍 16개** ③ 계기판 아래 **작은 덮개 뒤**(있으면).
### ③ 위치: car_spec `Deco_Interior` `OBD_Port` '운전석 무릎 아래' — 2 ft 규칙·흔한 자리와 **맞음** [17][29].
### 스캔툴 기초
- 코드 모양: 첫 글자 **P(파워트레인)·B(바디)·C(섀시)·U(통신)**, 두 번째 자리 **0 = SAE 공통 코드** [17].
- **프리즈 프레임**(고장 순간의 값 묶음) = Service $02 [17].
- 엔진 경고등(MIL): 보통 **호박색/빨강**, OBD-II 차에서 **켜져 있음 = 작은 고장(곧 정비)**, **깜빡임 = 심각, 몰기 위험** [22].
- 브랜드 전용 시스템(ABS·에어백·변속기 등)은 일반 스캐너로 못 읽을 수 있음 [29](검색 요약). 캠리 전용 툴 = **Techstream**(06·07 파일의 영점 보정·ATF 리셋도 이걸로).
### ⑥ 게임 손맛: 스캐너 꽂으면 화면에 **코드 + 프리즈 프레임(속도·rpm·온도)** — "P0301 @ 0 mph, 750 rpm" 같은 단서로 '신호 대기 때 떨림' 손님 대사와 맞추기.

---

## 계기판 경고등 (Dashboard warning lights) — 색 규칙
- 색 관습(완전한 법정 통일은 아님): **빨강 = 심각, 안전하게 멈춤** / **노랑·호박 = 곧 점검** / **초록·파랑 = 켜져 있다는 알림(상향등 파랑 등)** [21][31](검색 요약). 미국 FMVSS 101은 **브레이크 계통 고장 경고등을 빨강**으로 요구하는 등 일부 색을 표로 정함 [32].
- 캠리 XV70 사용설명서 '켜지면 할 일' (색은 문서에 대부분 안 적힘) [13]:

| 경고등 | 사용설명서 지시 | 흔한 색 |
|---|---|---|
| 브레이크 계통(액 부족·고장) | **즉시 안전한 곳에 멈추고** 딜러 연락 [13] | 빨강 [32] |
| 냉각수 고온(부저) | **즉시 멈춤** [13] | 빨강 (관습, [21]) |
| 충전 계통 | **즉시 멈추고** 연락 [13] | (확인 못 함) |
| 엔진오일 압력 낮음(부저) | **즉시 멈추고** 연락 [13] | 빨강 (관습 [21]) |
| 타이어 공기압 | **즉시 멈춤** [13] → 03 파일 | 노랑 (확인 못 함) |
| 엔진 경고등(MIL) | **즉시** 딜러 점검 [13] | 호박/빨강 [22] |
| SRS(에어백) · ABS · 슬립 표시 | **즉시** 점검 [13] | (확인 못 함) |
| 전동 파워스티어링(EPS) | **노랑 = 보조 제한, 빨강 = 보조 잃음** → 즉시 점검 [13] | 노랑/빨강 [13] |
| 연료 부족 | 주유 [13] | (확인 못 함) |
| 마스터 경고등 | 부저 + 깜빡임, 화면 확인 [13] | (확인 못 함) |
- 캠리 경고등 전체 목록(사용설명서): 브레이크, MIL, SRS, ABS, 잘못된 페달 조작, 주차 브레이크, 브레이크 홀드, EPS, LTA, PCS, PKSB OFF, 주차 보조 OFF, RCD OFF, 슬립, 연료 부족, 안전벨트(앞·뒤), 마스터, 타이어 공기압 [14].
- ⑥ 게임: 손님 차가 들어올 때 계기판 아이콘을 **색으로 먼저 분류**(빨강 = 견인으로 옴, 노랑 = 운전해서 옴)하면 대사·이동 연출이 자연스러움.

---

## 내부 도안 근거 (정비 매뉴얼 그림·배치도 — 본 것과 '어디에 무엇이')
- 도안 01 (사용설명서 CTH73BT018): ① **퓨즈 박스 2개, 양쪽** · ⑤ 배터리(운전석 쪽 앞) [1].
- 도안 02·03 (components-4187, B596535C01 / B470423C01): 범퍼 커버 뒤 철 빔 위에 **헤드라이트 2개** — 범퍼를 먼저 떼야 빠짐 [8].
- 도안 21 (components-4261, E426968C01): 헤드라이트 뭉치 + **옆표시등 전구·소켓 마개**, **방향지시등 전구·소켓**, 뒤 덮개, 커버; LED형/전구형 방향지시등 두 그림 [5].
- 헤드라이트 탈거 그림(removal-4262): 테이프 붙일 둘레, **볼트 1 + 나사 3** 자리, 가이드 빼는 방향 화살표 [6].
- EPS 부품 위치도(parts_location-3916): **엔진룸 릴레이·정션 블록(EPS 퓨즈)**, **계기판 정션 블록(IG1 릴레이·EPS-IG1 퓨즈)**, DLC3, 게이트웨이 ECU [3].
- CAN 부품 위치도(parts_location-3822): 세 번째 그림에 **DLC3**, **CAN 정션 커넥터 No.1~5**, 정션 커넥터 No.1~3 — 자리를 말로 적은 문장은 없음 [30].

## car_spec · fault_catalog 와 다른 점
1. **Headlight 볼트 3** → 정비 매뉴얼 탈거 문장은 **볼트 1 + 나사 3**(= 고정점 4) [6]. (diagrams/index.md 03의 '볼트 3개'도 다시 볼 것.) 게임 단순화로 3을 유지해도 되지만 "진짜는 4점 고정"이라고 메모.
2. **fault_catalog Headlight "전구 교체"** → 기준 차(캠리 XV70)는 본 램프 **LED, 사용자 교체 전구 없음 → 뭉치 교체** [5][9]. 제안: 연식별 분기 — 옛 차/싼 트림 = H11 전구(할로겐) [27], 요즘 차 = 뭉치. 진단 순서에 **퓨즈 → 릴레이(H-LP) → 램프** 추가 [2][11].
3. **"뿌옇게 바램 → 렌즈 광택 미니게임"**: 맞음. 다만 AAA 결과 **복원 = 약 70% 밝기 + 눈부심 초과**, **순정 교체 = 100%** [23] → '싼 복원 vs 비싼 교체' 선택지로 쓰면 진짜 같음. UV 코팅 단계가 핵심 [23].
4. car_spec `Deco_EngineBay` '퓨즈·릴레이 박스(배터리 옆)'는 맞고, 캠리는 **엔진룸 박스가 1~2개(type A/B)** + **실내 운전석 계기판 아래 박스**가 더 있음 [1][2] → `Deco_Interior`에 실내 퓨즈 박스 덮개 추가 후보.
5. `OBD_Port` '운전석 무릎 아래' 맞음(16핀, 핸들 2 ft 안) [17][29]. 캠리 정확 위치 그림 문장은 (확인 못 함).
6. fault_catalog에 **퓨즈·접지·릴레이·방향지시등 빠른 깜빡임** 고장이 없음 → 쉬운 Lv1~2 전기 일거리 후보: `FUSE_BLOWN`, `RELAY_HLP`, `TURN_HYPERFLASH`(분당 60~120 기준) [2][11][20], 중급 `BAD_GROUND`(전압강하 0.5 V 기준) [25].
7. 경고등 색: 사용설명서는 색을 거의 안 적음 [13] — 게임 아이콘 색은 **관습(빨강·노랑·초록·파랑)** [21][31] + 브레이크 빨강(FMVSS 101) [32] + EPS 노랑/빨강 [13] 기준으로 정하면 됨.

## 출처
1. Toyota Camry XV70 Owner's Manual — Engine compartment (도안 01) — https://www.tocamry.com/engine_compartment-1984.html
2. Toyota Camry XV70 Owner's Manual — Checking and replacing fuses — https://www.tocamry.com/checking_and_replacing_fuses-1996.html
3. Toyota Camry XV70 Repair Manual — Power Steering Parts Location (릴레이·정션 블록) — https://www.tocamry.com/parts_location-3916.html
4. Toyota Camry XV70 Repair Manual — A25A-FKS Battery Removal — https://www.tocamry.com/removal-2073.html
5. Toyota Camry XV70 Repair Manual — Headlight Assembly Components (도안 21) — https://www.tocamry.com/components-4261.html
6. Toyota Camry XV70 Repair Manual — Headlight Assembly Removal — https://www.tocamry.com/removal-4262.html
7. Toyota Camry XV70 Repair Manual — Headlight Assembly Adjustment (조준 준비) — https://www.tocamry.com/adjustment-4265.html
8. Toyota Camry XV70 Repair Manual — Front Bumper Components (도안 02·03) — https://www.tocamry.com/components-4187.html
9. Toyota Camry XV70 Owner's Manual — Light bulbs — https://www.tocamry.com/light_bulbs-1997.html
10. Toyota Camry XV70 Owner's Manual — Headlight switch (DRL) — https://www.tocamry.com/headlight_switch-1910.html
11. Toyota Camry XV70 Repair Manual — Lighting (ext) Relay inspection (H-LP·DIM·DRL) — https://www.tocamry.com/relay-4322.html
12. Toyota Camry XV70 Repair Manual — Steering Gear Removal (커넥터 잠금, 하네스 주의) — https://www.tocamry.com/removal-3979.html
13. Toyota Camry XV70 Owner's Manual — If a warning light turns on or a warning buzzer sounds — https://www.tocamry.com/if_a_warning_light_turns_on_or_a_warning_buzzer_sounds-2008.html
14. Toyota Camry XV70 Owner's Manual — Warning lights and indicators (경고등 목록) — https://www.tocamry.com/warning_lights_and_indicators-1854.html
15. Toyota Camry XV70 Repair Manual — CAN Communication System (버스 5개) / Diagnosis System (DLC3 ↔ 게이트웨이 ECU, 진단 버스) — https://www.tocamry.com/can_communication_system-3820.html , https://www.tocamry.com/diagnosis_system-3829.html
16. Wikipedia — Fuse (automotive) — https://en.wikipedia.org/wiki/Fuse_(automotive)
17. Wikipedia — On-board diagnostics (J1962, 핀, 1996, 2008 CAN, DTC, $02) — https://en.wikipedia.org/wiki/On-board_diagnostics
18. Wikipedia — CAN bus — https://en.wikipedia.org/wiki/CAN_bus
19. Wikipedia — Headlamp (할로겐 전구 와트·HID·SAE 조준) — https://en.wikipedia.org/wiki/Headlamp
20. Wikipedia — Automotive lighting (방향지시등 60~120회/분, 고장 시 빠름/느림, 미국 옆표시등·미등·브레이크등) — https://en.wikipedia.org/wiki/Automotive_lighting
21. Wikipedia — Idiot light (빨강 = 계속 못 감 등) — https://en.wikipedia.org/wiki/Idiot_light
22. Wikipedia — Check engine light (호박/빨강, 켜짐 vs 깜빡임) — https://en.wikipedia.org/wiki/Check_engine_light
23. AAA Newsroom (2018-12) — AAA Illuminates the Dangers of Driving with Cloudy Headlights — http://newsroom.aaa.com/2018/12/dangers-driving-cloudy-headlights/
24. ALLDATA DIY — Parasitic Draw Test — https://alldata.com/diy-us/en/diy-tips/parasitic-draw-test
25. MOTOR Magazine (2005-05) — Foreign Service (접지 전압강하 0.36/1.17/0.50 V) — https://www.motor.com/magazine-summary/foreign-service-3-may-2005/
26. (검색 요약) 릴레이 단자 30·85·86·87·87a — the12volt / Del City(403) — https://www.the12volt.com/INSTALLBAY/forum_posts.asp?tid=83023 , https://www.delcity.net/automotive-relay-diagram/
27. (검색 요약) 2015 Toyota Camry 전구 크기(할로겐 하향 H11 / 상향 9005) — Autofiles / Auxito — https://autofiles.com/bulb-size/toyota/camry/2015/ , https://auxito.com/pages/toyota-camry-bulb-size-guide
28. (검색 요약) Hyperflash·LED 부하 저항 — Sealight / JW Speaker — https://sealight-led.com/blog/turn-signal-hyper-flash.html , https://info.jwspeaker.com/knowledge/blog/how-to-fix-hyper-flashing-with-led-lights
29. (검색 요약) OBD 단자 흔한 위치·브랜드 전용 시스템 — MechanicBase / YouCanic — https://mechanicbase.com/trouble-code/obd-port/ , https://www.youcanic.com/volvo-obd-ii-port-location-diagnostic-port/
30. Toyota Camry XV70 Repair Manual — CAN Communication Parts Location (DLC3, CAN 정션 커넥터) — https://www.tocamry.com/parts_location-3822.html
31. (검색 요약) 경고등 색 관습 — What Car? / Admiral / Cuvva — https://www.whatcar.com/news/car-dashboard-warning-lights-explained/n18867 , https://www.admiral.com/magazine/guides/motor/car-dashboard-warning-lights-symbols-meanings
32. 49 CFR 571.101 (FMVSS 101) — Controls, telltales and indicators (S5.4.1 색은 Table 1, 브레이크 고장 경고 = 빨강) — https://www.law.cornell.edu/cfr/text/49/571.101
