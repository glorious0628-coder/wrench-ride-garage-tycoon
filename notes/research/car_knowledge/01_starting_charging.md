# 시동·충전 (Starting & Charging System)

> 기준 차: 가로배치 직렬 4기통 앞바퀴굴림(FF) 중형 세단, 미국 왼쪽 운전석 (예: Toyota Camry XV70/XV80, Honda Accord 10·11세대, Hyundai Sonata DN8, Nissan Altima L34).
> 차 안 좌표·이름은 `docs/specs/car_spec.md` 기준(앞 = −Z, 운전석 = −X).
> 출처는 각 줄 끝 [n] → 맨 아래 '출처' 목록. 출처 없는 문장은 쓰지 않아요. 못 찾은 건 "(확인 못 함)".
> 차종별 세부는 **Camry XV70(A25A-FKS 2.5L)** 만 정비 매뉴얼로 확인했어요. Accord·Sonata·Altima 의 배터리 자리·규격은 믿을 만한 출처를 못 열어서 (확인 못 함).

## 한눈에 (3줄)
- 배터리(12 V, 납축전지 6칸)가 시동 모터를 돌려 엔진을 깨우고, 엔진이 돌면 벨트로 도는 발전기(Alternator)가 전기를 만들어 배터리를 다시 채워요 [1][23].
- 진단 숫자 3개: 쉬는 배터리 ≈12.6 V(꽉 참), 크랭킹 중 9.6 V 이상(70°F 기준), 시동 중 충전 ≈13.5~14.5 V [1][2][15].
- 소리로 가르기: **빠른 따다다닥 = 배터리 약함**, **딸깍 한 번 또는 무소리 = 시동 모터·솔레노이드·배선 쪽** [12][14].

---

## 부품: 배터리 (12V Battery)

### ① 하는 일
- 엔진 꺼진 동안 전기를 모아 두었다가, 시동 때 시동 모터에 큰 전류를 줘요. 12 V 차는 2.1 V짜리 칸(cell) 6개를 직렬로 이어 꽉 차면 12.6 V [1].
- 엔진이 돌 때는 발전기의 전압 조정기가 13.5~14.5 V로 배터리를 채워요 [1].

### ② 실제 모양·크기·재질·색 — 알아보게 할 특징 3개
- 재질: 플라스틱 상자 안에 납 합금 판(−: 해면 납, +: 이산화납) + 묽은 황산 전해액, 판 사이에 분리막 [1]. 전해액은 황산 약 36 % + 물 64 % [3].
- 단자: 윗면(가끔 옆면)에 굵은 단자 2개, 부식 막으려고 납 도금 [1].
- 종류 3가지:
  - 일반 습식(Flooded): 액체 전해액, 옛날 것은 마개 열고 증류수 보충 [1].
  - EFB(Enhanced Flooded): 액체 전해액 그대로지만 + 판에 폴리플리스 층을 대 오래 버팀, 기본 스톱앤고 차용, 약 27만 회 시동 [4][5].
  - AGM: 전해액을 유리섬유 매트에 흡수시킨 밀폐형, 안 엎질러짐, 약 36만 회 시동, 회생제동·전기 많이 쓰는 차용 [4][5].
  - 규칙: 스톱앤고 차에는 일반 배터리를 넣으면 안 되고 [5], AGM이 있던 차는 AGM으로 바꿔야 해요 [4]. 바꾼 뒤 BMS 등록이 필요한 차도 있음 [4].
- 그룹 크기(BCI Group Size) = 가로·세로·높이 + 단자 위치 + 고정 방식 규격 [1]. 예 (출처끼리 조금 다름):

| 그룹 | 길이 × 폭 × 높이 | 출처·메모 |
|---|---|---|
| 24 | 10.25 × 6.81 × 8.88 in (260 × 173 × 225 mm) | [6] |
| 24F | 10.75 × 6.81 × 8.88 in (273 × 173 × 229 mm) | [6] — 인치 높이와 cm 높이가 서로 안 맞음(페이지 오류 가능) |
| 35 | 9.06 × 6.89 × 8.88 in (230 × 175 × 225 mm) | [6] |
| H6 (L3) | 278 × 175 × 190 mm | [7] — H6 = Group 48 이라는데 Group 48 은 306 × 175 × 192 mm 로 적혀 길이가 달라요 [7] |
| H7 = 94R | 315 × 175 × 190 mm (12 3/8 × 6 7/8 × 7 1/2 in) | [7] |

- 무게: H6 예시 제품 20.6~24.5 kg, H7 예시 23.3~25.8 kg [7]. 24F 무게 (확인 못 함).
- CCA(저온 시동 전류) = 0°F(−18 °C)에서 30초 동안 7.2 V 이상 버티며 낼 수 있는 전류 [1]. H6 예시 약 720~800 A, H7 약 800~850 A [7].
- Camry XV70 교체 규격: 같은 크기, 20시간율 60 Ah 이상 [9].
- 날짜 표시(date code): 제조사마다 표기법이 달라 믿을 만한 1차 출처를 못 열었어요 (확인 못 함).
- **알아보게 할 특징 3개 (캐주얼 그림에서도)**
  1. 납작하고 각진 검정/회색 상자 + 윗면 한쪽 끝에 **빨간 + 단자 덮개**, 반대쪽에 검은 − 단자 [1][9].
  2. 굵은 케이블 2가닥(+ 빨강, − 검정)이 단자 클램프(너트 1개씩)로 물려 있음 [9].
  3. 바닥 옆을 잡는 **작은 고정 클램프 + 볼트 1개**, 아래엔 받침(트레이) [9][10].

### ③ 차 안 위치
- Camry XV70(A25A): 엔진룸 **왼쪽(운전석) 앞쪽**. 정비 매뉴얼 엔진룸 그림에서 배터리·브레이크액 탱크·퓨즈 박스 1개가 차의 왼쪽, 냉각수 보조탱크·워셔액 탱크는 오른쪽 앞 [8].
- XV70 V6 매뉴얼 기준, 시동 모터는 배터리 받침·에어클리너·ECM **아래**(운전석 쪽)에 있어요 → 배터리를 떼야 시동 모터가 보임 [20].
- Accord 10/11세대, Sonata DN8, Altima L34 배터리 자리 (확인 못 함 — 열어 본 페이지가 '엔진룸에 있을 수 있음' 수준만 말함).

### ④ 붙어 있는 방식 (Camry XV70 매뉴얼 기준)
- 떼는 순서 [9][10]:
  1. − 단자 너트 풀고 **− 케이블 먼저** 분리.
  2. + 단자 덮개 열기(걸쇠 2개) → + 단자 너트 풀고 분리.
  3. **볼트 1개** 풀고 'No. 2 battery clamp'(바닥 쪽 작은 클램프) 떼기 → 배터리 들어 올리기.
- 조이는 힘: 단자 너트 5.4 N·m, 클램프 볼트 18.5 N·m [9].
- 다시 달 땐 + 먼저, − 마지막 [3]. 이유: − 먼저 풀면 렌치가 차체에 닿아도 둘 다 접지라 합선이 안 나고, + 먼저 풀다 차체에 닿으면 불꽃·폭발·공구 손상 위험 [3].
- 공구: 단자 볼트 10 mm (XV50 Camry 정비 가이드) [19].
- 다시 연결 후 일부 시스템 초기화 필요(XV70) [9]; 라디오·창문·스로틀 학습 등 메모리 복구가 필요한 차가 있음, SRS 고장 없는지 확인 [3].
- 통풍(vent): 습식은 수소가 빠지는 통풍 마개, 밀폐형은 압력 밸브 [1]. 실내에 있는 배터리는 바닥 밖으로 빼는 통풍 튜브가 필요 [3].

### ⑤ 흔한 고장 (증상 → 원인 → 진단 → 수리법·시간)
| 증상 (소리·연기·냄새·누유 색·경고등·OBD 코드) | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 키 돌리면 **빠른 따다다닥(chatter)**, 계기판 희미 | 배터리 방전·약함, 또는 케이블 저항 큼 [14] | 쉬는 전압: 12.66 V↑ = 100 %, 12.45 = 75 %, 12.24 = 50 %, 12.06 = 25 %, 11.89↓ = 0 % [2][3]. 측정 전 표면전하 제거(전조등 1~2분 켜고 5분 기다리기) [3]. 전압이 솔레노이드 유지 문턱(약 8~9 V) 밑으로 떨어지며 붙었다 떨어졌다 반복 [14] | 충전 후 부하 시험 → 불합격이면 교체 [2]. 교체 공임 시간 (확인 못 함). 배터리 값 $100~300 [12] |
| 크랭킹이 느림(drag) | 배터리 약함·케이블 저항·엔진 저항 [14] | **부하 시험(SAE J537)**: 75 % 이상 충전 상태에서 CCA의 50 % 부하 15초 → 70°F 이상에서 9.6 V 이상이면 합격, 추우면 기준↓(40°F 9.3 V, 0°F 8.5 V), 부하 뗀 뒤 5초 안에 12.0 V 넘게 회복 [2]. 전자식 전도도 시험은 약 10초, 방전 거의 없음 [2] | 불합격 → 교체 [2] |
| 될 때도 있고 안 될 때도 있음 / 단자에 흰·초록 가루 | 단자 부식(저항 ↑) [1] | 눈으로 단자 확인, 전압 강하 시험 [14][17] | 베이킹소다+물로 중화 → 와이어 브러시로 반짝일 때까지 → 말린 뒤 연결 → 바셀린·보호 스프레이 [3][11] |
| 상자가 **불룩**, 금 감, 샘 | 수명·열 [11][1] | 눈 [11] | 교체 [11] |
| 자꾸 방전 (밤새 세워 두면) | 기생 전류(parasitic draw), 또는 발전기 문제 | 키 끈 상태 정상 소모 50 mA 이하 [24] | 원인 회로 찾기 / 발전기 점검(아래) |
| 경고: 배터리 모양 경고등 | Toyota: **충전 계통 고장** 표시 → 즉시 안전한 곳에 세우기 [33]. AAA 는 '배터리가 죽어 가는 신호' 목록에도 넣음 [11] → 출처 엇갈림, 정비사는 발전기·벨트·배선부터 봄 [25] | 아래 발전기 표 | |
| P0562 (System Voltage Low) | 발전기·조정기 고장, 배선 헐거움·부식, 배터리 케이블 저항, 퓨즈, 낡은 배터리·큰 방전 [26] | 시동 중 전압, 접지 점퍼 시험 [26] | 원인 부품 수리 [26] |

- 수명 기본: 깊은 방전·열이 수명을 줄여요; 가장 흔한 마모는 극판 물질 탈락, 방전 상태로 두면 황산화(sulfation) [1].
- 얼어 있는 배터리는 점프·부하 시험 금지 [3].

### ⑥ 게임 손맛 아이디어 (제안만)
- 멀티미터 대면 숫자가 **조금 높게 떴다가(표면전하 13.0~13.8 V [2]) 내려앉는** 연출 → "전조등 켜 놓고 기다렸다 재기" 미니 단계.
- 부하 시험기: 15초 바늘이 떨어지는 걸 보는 미니게임, 9.6 V 선에 빨간 줄.
- − 먼저 풀면 '딸깍', + 먼저 풀다 차체 닿으면 작은 불꽃 (car_spec 의 기존 안과 실제 이유가 일치 [3]).
- 단자 부식 닦기: 거품(베이킹소다) → 문지르기 → 반짝 → 바셀린 한 번 쓱.

---

## 부품: 시동 모터 (Starter Motor)

### ① 하는 일
- 시동 때만 잠깐 돌며 엔진 플라이휠의 큰 톱니(ring gear)를 돌려 엔진을 깨워요 [13].
- 솔레노이드(solenoid)가 두 가지 일을 함: (1) 레버로 작은 톱니(pinion)를 밀어 링기어에 물리고, (2) 모터로 가는 큰 전류 접점을 닫음 [13].
- 엔진이 돌면 한 방향 클러치(overrunning/sprag clutch)가 엔진이 모터를 거꾸로 돌리지 못하게 막고, 키를 놓으면 스프링이 피니언을 빼요 [13].
- 요즘 것은 감속기어(유성기어) 방식이 많음 — 작고 가벼우며 전류는 적게, 힘은 크게 [13]. A25A-FKS 시동 모터 = **1.3 kW 유성기어식** [21].
- 오래 돌리면 안 됨: 보통 30초 안쪽 설계, 쉬었다 다시 [13]. Camry 푸시 버튼은 시동될 때까지 또는 최대 30초 크랭킹 [32].

### ② 실제 모양·크기·재질·색 — 알아보게 할 특징 3개
- 크기·무게 (확인 못 함).
- **알아보게 할 특징 3개**
  1. 굵은 **원통(모터)** 위에 작은 **원통(솔레노이드)** 이 업혀 있는 '두 통' 모양 [13].
  2. 앞끝에 튀어나온 작은 톱니(피니언) [13].
  3. 솔레노이드 끝의 굵은 전원 단자(너트로 고정한 두꺼운 케이블) + 작은 플러그 커넥터 1개 [19][20].

### ③ 차 안 위치
- 피니언이 플라이휠(자동변속기는 플렉스플레이트) 링기어에 물려야 하니 엔진과 변속기가 만나는 곳에 붙어요 [13].
- Camry XV70 (V6 매뉴얼): 운전석 쪽, **배터리 받침·에어클리너·ECM 아래** [20].
- Camry XV50 2.5L: 에어클리너·에어박스를 떼야 접근 [19]. A25A XV70 4기통의 정확한 자리 (확인 못 함 — 위 V6·XV50 자료로 보면 변속기 쪽 = 운전석 쪽).

### ④ 붙어 있는 방식
- Camry XV70 V6: 볼트 2개 + 단자 30 너트 + 커넥터 1개 [20].
- Camry XV50 2.5L 순서 [19]: 배터리 단자 분리(10 mm) → 에어클리너·하우징 떼기 → 시동 모터 커넥터 뽑기 → **12 mm** 볼트 풀어 굵은 케이블 분리 → **14 mm** 고정 볼트 풀어 빼기. 조이는 힘: 고정 볼트 39 N·m(29 ft·lbf), 케이블 너트 13 N·m(9 ft·lbf) [19].
- 공구: 10·12·14 mm 소켓, 토크 렌치 [19].

### ⑤ 흔한 고장 (증상 → 원인 → 진단 → 수리법·시간)
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| **딸깍 한 번**, 안 돎 | 솔레노이드 접점 탐, 브러시 마모·전기자 끊김, 케이블 저항 큼, 엔진 고착 [14] | 배터리 정상인지 먼저 [17]. 크랭크를 손(브레이커 바)으로 돌려 엔진·에어컨 압축기 고착 아닌지 확인 [14][17]. **전압 강하 시험**: + 쪽 0.5 V 미만, − 쪽 0.5 V 미만 [17] (다른 기준: + 0.2 V, 솔레노이드 포함 0.5 V, 접지 0.2 V [15]). 둘 다 정상이면 시동 모터 불량 [17] | 시동 모터 교체. 쉬우면 1~2시간, 깊이 묻혀 있으면 최대 6시간 [22] |
| **아무 소리 없음** | 배터리 완전 방전, 시동 퓨즈, 점화 스위치, 중립 안전 스위치, 도난 방지 잠금 [14] | 시동 시도 중 S 단자 전압 0 V → 제어 회로 문제 [14]. 딸깍조차 없으면 솔레노이드에 전원이 안 온 것 → 시동 모터 자체는 가능성 낮음 [18] | 제어 회로·릴레이·스위치 수리 |
| 빠른 따다다닥 | 배터리 약함·케이블 저항 [14] | 배터리 부하 시험, 단자 청소 [14] | 배터리 쪽(위 표) |
| 윙 소리만, 엔진 안 돎 | 피니언 한 방향 클러치 고장, 링기어 이 빠짐 [14] | 피니언 확인 [14] | 시동 모터 교체; 링기어 손상 확인 후 새 모터 달기 [18] |
| 갈리는 소리(grinding) | 링기어 이 손상, 고정 볼트 풀림, 정렬 불량 [14] | 기어 이 눈으로 확인 [14] | 볼트 조이기 / 교체 |
| 느린 크랭킹 (배터리·케이블 정상인데) | 모터 내부 저항·끌림 [14][18] | 크랭킹 중 9.6 V 이상 유지해야 정상(70°F) [15]; 정상 크랭킹 약 150~250 rpm, 100 rpm 미만이면 느림 [14][15] | 시동 모터 교체 [18] |
| 차가울 땐 되는데 뜨거우면 끌림 | 전기자 권선 열화(열 흡수) [14] | 뜨거울 때 재현 [14] | 교체 |
| 툭 치면 됨 | 브러시 등 내부 마모 — 고친 게 아님 [16] | | 교체 |
| 엔진룸에서 연기, 시동 후에도 모터가 계속 돎, 시동 모터에 오일 범벅 | 전기 과열 등 [22] | 눈 | 교체 |

- 시동 모터 수명: 대부분 10만~15만 마일 [22]. 교체 비용(부품+공임) $350~1,200 범위 [22].

### ⑥ 게임 손맛 아이디어 (제안만)
- '소리 3종 세트'로 추리: 따다다닥(배터리) / 딸깍(시동 모터) / 무소리(퓨즈·스위치) — 청진기 없이 귀로 푸는 첫 추리.
- Camry 처럼 **배터리·받침을 떼야 시동 모터가 보이는** 층 구조 → "먼저 할 것" 사슬이 자연스러움 [20].
- 크랭크를 렌치로 직접 돌려 보는 '엔진 고착 확인' 클릭 1번.

---

## 부품: 발전기 (Alternator)

### ① 하는 일
- 엔진이 돌 때 벨트로 돌며 교류를 만들고, 다이오드 정류기로 직류로 바꿔 배터리를 채우고 전기 장치에 전기를 줘요 [23].
- 안쪽: 손가락을 깍지 낀 모양의 회전자(claw-pole rotor), 3상 고정자, 다이오드 6개 정류기, 브러시·슬립링(약한 계자 전류만 흐름) [23][24].
- 전압 조정: 옛날엔 따로, 1970~90년대엔 발전기 안, 요즘은 엔진 컴퓨터(PCM/ECM)가 조절 [23][24]. 그래서 '고정된 정상 범위' 하나로 판정하기 어려움 [24].
- A25A-FKS 발전기: **100 A(1200 W)** [21]. (애프터마켓 업체 페이지는 120~150 A 라고 적어 출처가 엇갈림 [28].)
- 일반 출력: 요즘 차 120~155 A 이상, 공회전에선 20~50 A, 최대 출력은 2,500 rpm 넘어서 [24].

### ② 실제 모양·크기·재질·색 — 알아보게 할 특징 3개
- 크기·무게 (확인 못 함).
- **알아보게 할 특징 3개**
  1. 은색(알루미늄) 둥근 몸통에 **통풍 구멍·슬롯**(안쪽 팬 2개로 공기 흐름) [23].
  2. 앞쪽에 벨트가 걸린 **골 파인 작은 풀리** — 크랭크보다 2~3배 빨리 돎 [23].
  3. 뒤쪽에 굵은 **B+ 단자(너트 + 고무 덮개)** 와 작은 플러그 커넥터 [27].

### ③ 차 안 위치
- A25A-FKS: 벨트는 엔진 **오른쪽(조수석) 끝**에 있고, 풀리 3개(크랭크, 발전기, 에어컨 압축기) + 텐셔너만 감아요 [30][21]. → 발전기는 엔진 오른쪽 끝 벨트 구역.
- 같은 엔진에서 써모스탯(냉각수 입구)을 떼려면 **발전기를 먼저 떼야** 함 [35] → 발전기가 써모스탯·물펌프 쪽을 가리는 자리 (자세히는 04_cooling.md).
- 한 가이드는 "엔진룸 위·앞쪽, 보닛 열면 보임" 이라 적음 [27]. 정확한 높이·앞뒤 (확인 못 함).

### ④ 붙어 있는 방식
- 먼저: 배터리 − 분리, 벨트 풀기 [27].
- A25A 벨트 풀기: 텐셔너를 **반시계 방향**으로 돌리고 **5 mm 육각 렌치**로 고정 → 벨트 빼기. 접근은 오른쪽 바퀴집 안쪽 커버·엔진 언더커버 떼고 [30]. (다른 가이드는 14 mm 렌치로 텐셔너 볼트를 돌린다고 적음 [27] → 출처 엇갈림, 매뉴얼 [30] 우선.)
- 고정: **14 mm 볼트 2개**, 배선 브래킷 10 mm 볼트 1개, **B+ 단자 너트 10 mm**, ECM 스마트 충전용 커넥터 1개 [27].
- 조이는 힘(애프터마켓 가이드 값, 매뉴얼 미확인): 고정 볼트 18 ft·lbs, B+ 너트 70~90 in·lbs [27] (확인 못 함 — 공식 값 아님).
- 공임: 정비소 1.0~1.5시간, 혼자 하면 2~3시간 [27].

### ⑤ 흔한 고장 (증상 → 원인 → 진단 → 수리법·시간)
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 충전 경고등(배터리 모양) 켜짐 | 충전 계통 고장 [33]; 다이오드 1개 나가면 경고등이 **희미하게**, 2개 이상이면 더 밝게 [24] | 시동 중 배터리 전압: 정상 약 13.8~14.2 V(공회전, 전기 끔), 뜨거운 날 13.5~14.3 V, 추우면 잠깐 15 V 넘게도 [24]; Denso 기준 13.2 V 미만 = 발전기·배선 불량, 14.5 V 초과 = 조정기·배터리·연결 불량 [25] | 발전기 교체 1.0~1.5 h [27] |
| 새 배터리도 며칠 뒤 또 방전, 점프하면 걸렸다 곧 꺼짐 | 발전기 못 채움 [12] | 위 전압 + 부하(전조등·에어컨·열선) 켜고 다시 재기 [24] | 교체 |
| 전조등 어두움·깜빡, 전기 장치 느림 | 충전 부족 [27] | 전압 | 교체 |
| 윙·그르렁 소리(rpm 따라 변함), 주기적 웅웅 | 베어링 마모 [24][27] | 청진기·벨트 빼고 손으로 돌려 보기 (확인 못 함 — 절차 출처 없음) | 교체 |
| 고무 타는 냄새 | 벨트 미끄러짐 등 [27] | 벨트·텐셔너 점검 [25] | 벨트·텐셔너 교체 |
| P0562 | 발전기·조정기·배선·퓨즈·배터리 [26] | 시동 중 12 V 근처 이하면 충전 문제, 접지 점퍼 시험 [26] | 원인 수리 |
| 전압 강하 | B+ 케이블 0.2 V 넘으면 저항 과다, 접지 0.2 V 이하 (GM은 + 쪽 0.5 V까지 허용) [24] | 전압 강하 시험 [24] | 케이블·접지 수리 |

- **하지 말 것**: 엔진 돌 때 배터리 케이블 뽑아서 발전기 '시험' — 높은 전압 튐으로 발전기·전자장치 손상 가능 [24].
- Toyota 스마트 충전: 고속 순항 중 12.5~13.5 V 가 정상일 수 있다는 업체 설명 [28] (공식 확인 못 함). 그래서 진단은 공회전·워밍업 후·부하 걸고 [28][24].

### ⑥ 게임 손맛 아이디어 (제안만)
- 멀티미터 '엔진 켜고' 모드: 바늘이 14 V 근처 = 초록, 13.2 V 밑 = 빨강, 14.5 V 위 = 주황(과충전) [25].
- 경고등이 **희미하게** 켜지는 연출 = 다이오드 1개 고장 힌트 [24] (Lv 높은 숨은 고장).
- 벨트 풀 때 5 mm 육각 핀을 꽂아 텐셔너를 '잠그는' 손맛 [30].

---

## 부품: 서펜타인 벨트 + 텐셔너 (Serpentine / V-ribbed Belt & Tensioner) — 짧게
- 한 줄 벨트가 크랭크 풀리에서 힘을 받아 여러 부품을 돌림; 텐셔너(스프링·유압·수동)가 팽팽하게 잡음; 홈이 여러 줄(multi-rib) [29].
- A25A-FKS: 크랭크·발전기·에어컨 압축기 3개 + 자동 텐셔너. **물펌프는 전기식이라 벨트에 없음** [30][21][34]. (일반 차는 벨트가 끊기면 물펌프도 멈춰 과열될 수 있음 [29] — A25A에선 해당 안 됨.)
- 점검(대형차 교재 기준이라 참고만): 요즘 EPDM 벨트는 잘 안 갈라지고, 홈 깊이 게이지가 홈에 쏙 들어가면(마모 10 % 넘음) 교체; '1인치에 금 3개' 규칙은 옛 네오프렌 벨트용; 텐셔너 팔 떨림 3 mm 미만 정상, 6 mm 넘으면 댐핑 고장 [31].
- 다른 가이드: 5만 마일 넘은 벨트는 교체, 텐셔너 녹·약함·걸림 확인 [24]. 너무 느슨하면 미끄러짐, 너무 팽팽하면 발전기 베어링 손상 [25].

## 부품: 점화 스위치 / 푸시 시동 (Ignition / Engine Switch) — 짧게
- Camry XV70 스마트키: 주차브레이크 + P 단 → 브레이크 꾹 → 버튼 한 번 짧게 → 시동될 때까지 또는 최대 30초 크랭킹. 브레이크 안 밟고 누르면 모드만 바뀜 [32].
- 스위치·제어 회로가 고장 나면 '무소리' 노크랭크 [14]. 요즘 차는 PCM이 릴레이로 시동 신호를 주고, 도난방지·브레이크 페달 신호가 조건 [17].

## 부품: 충전 경고등 (Charging System Warning Light) — 짧게
- Toyota: 충전 계통 고장 → 즉시 안전한 곳에 세우고 딜러 연락 [33].
- 정상: 엔진 끈 상태(키 ON)에선 켜지고, 시동 걸면 꺼짐; 공회전에서 희미하게 켜질 수 있음 [25].
- 같이 볼 것: 전압이 떨어지면 전동 파워스티어링 경고등도 켜질 수 있음(Toyota) [33].

---

## 내부 도안 근거 (정비 매뉴얼 그림·분해도·배치도 — 본 것과 '어디에 무엇이')
- Camry XV70 엔진룸 배치도 [8] (wr-carbook 직접 확인, diagrams/index.md): 앞에서 볼 때 차 왼쪽(운전석) = 배터리 + 브레이크액 탱크 + 퓨즈 박스 1개, 오른쪽 앞 = 냉각수 보조탱크 + 워셔액 탱크, 가운데 앞 = 라디에이터·전동팬·콘덴서.
- Camry XV70 배터리 분해도 [10] (wr-carbook 직접 확인, diagrams/index.md): − 단자 / + 단자(덮개, 걸쇠 2) / No. 2 battery clamp + 볼트 1 / 배터리 / 받침.
- A25A 벨트 그림 [21]: 그림 설명 "1 발전기, 2 텐셔너, 3 크랭크축, 4 에어컨 압축기" — 4개 풀리 배치, 물펌프 풀리 없음.
- 시동 모터(XV70 V6) [20] (wr-carbook 직접 확인, diagrams/index.md): 배터리 받침·에어클리너·ECM 아래, 볼트 2 + 단자 30 너트 + 커넥터.

## car_spec · fault_catalog 와 다른 점
1. **BAT_OLD 증상 "My battery light came on"** — Toyota 매뉴얼은 이 등을 '충전 계통 고장'으로 정의 [33]. 정비사는 발전기·벨트·배선부터 봐요 [25]. AAA 는 배터리 쇠약 신호로도 적어 출처가 엇갈림 [11]. → BAT_OLD 의 손님 말은 "It cranks slow in the morning" / 상자 불룩 쪽이 더 정확하고, 배터리 등은 ALT 쪽 단서로 쓰는 걸 제안.
2. **딸깍 소리 구분**: fault_catalog BAT_DEAD "click-click-click"(빠른 연속) = 배터리 약함 — 실제와 맞아요 [12][14]. 다만 **딸깍 한 번 / 무소리 = 시동 모터·솔레노이드·케이블·스위치** [12][14][18] 라서, 후보 `StarterMotor`(car_spec 4-2 후보)를 넣으면 '헷갈리는 짝'이 진짜처럼 됨. 지금은 "딸깍" 이 배터리에만 묶여 있음.
3. **멀티미터 숫자**: fault_catalog "12.6 꽉 / 12.2 반 / 11.8 죽음" 은 ASE 표(12.66 / 12.24 = 50 % / 11.89↓ = 0 %)와 대체로 맞음 [2][3]. "시동 중 13.7~14.7 V 정상"은 출처마다 다름: 13.5~14.5 V [1], 13.8~14.2 V(공회전) [24], Denso 13.2~14.5 V [25]. 그리고 측정 전 표면전하 제거가 실제 단계 [3].
4. **P0562 를 BAT_DEAD(시동 안 걸림) 진단에 씀** — P0562 는 '시스템 전압 낮음'으로 원인 목록 1번이 발전기·조정기 [26]. 배터리만 죽은 차에도 뜰 수는 있지만, 충전 고장 쪽 단서로 쓰는 게 더 자연스러움.
5. **배터리 자리** car_spec (−2.2, 1.55, −6.6) = 엔진룸 왼쪽 앞 — Camry XV70 와 일치 [8]. car_spec "변속기 위 받침대" 표현도 V6 매뉴얼(배터리 받침 아래 시동 모터·변속기 쪽)과 어긋나지 않음 [20]. 단, Accord·Sonata·Altima 는 (확인 못 함).
6. **배터리 볼트 3개(− 단자, + 단자, 고정쇠)** — XV70 과 일치(고정은 **바닥 쪽 작은 클램프 + 볼트 1**, 위를 가로지르는 막대 아님) [9][10]. + 단자에는 **덮개(걸쇠 2)** 가 있어 '덮개 열기' 단계가 하나 더 [9].
7. **배터리 무게 16 kg** — H6 예시 20.6~24.5 kg [7]. 기준 차 배터리 정확한 무게는 (확인 못 함); 16 kg 은 조금 가벼울 수 있음.
8. **Alternator 볼트 "3 (고정 2 + B+)"** — 실제: 14 mm 고정 볼트 2 + B+ 너트 10 mm + 배선 브래킷 볼트 1 + 커넥터 1 [27]. 먼저 할 것 "배터리 − 풀기, 벨트 풀기(텐셔너)" 는 일치 [27][30].
9. **Alternator(벨트) 끽 소리 → 과열은 없음**: A25A 는 물펌프가 전기식이라 벨트가 끊겨도 물펌프는 안 멈춤 [30][34]. 반대로 일반 설명(벨트 끊김 → 과열 [29])은 다른 엔진에만 해당.

## 출처
1. Automotive battery — Wikipedia — https://en.wikipedia.org/wiki/Automotive_battery
2. 4.2 State-of-Charge & Battery Capacity/Load Testing (ASE T6 study guide) — open-exam-prep — https://open-exam-prep.com/study-guides/ase-t6/batteries-battery-management/battery-testing-service
3. 6.1 Battery Testing and Service (ASE G1 study guide) — open-exam-prep — https://open-exam-prep.com/study-guides/ase-g1/electrical/battery-testing-service
4. EFB technology — VARTA Automotive — https://www.varta-automotive.com/en-za/knowledge/technology/efb
5. Difference between AGM and EFB batteries — Banner Batterien — https://www.bannerbatterien.com/en/Battery-knowledge/17-Difference-between-AGM-and-EFB-batteries
6. Battery group size dimensions — LiTime — https://www.litime.com/blogs/knowledge/battery-group-size-dimensions
7. H6 vs H7 Battery — Utmel — https://www.utmel.com/components/h6-vs-h7-battery-which-one-do-you-like-better?id=1785
8. Camry XV70 Owner's Manual: Engine compartment (A25A-FKS) — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/engine_compartment-1984.html
9. Camry XV70 Repair Manual: Battery Removal — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/removal-2073.html
10. Camry XV70 Repair Manual: Battery Components — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/components-2072.html
11. Battery Maintenance 101 — AAA Northampton — https://northampton.aaa.com/blogs/battery-maintenance-101-how-to-keep-your-car-running-smoothly
12. 13 Common Car Problems Explained — AAA — https://www.aaa.com/autorepair/articles/13-common-car-problems-explained
13. Starter (engine) — Wikipedia — https://en.wikipedia.org/wiki/Starter_(engine)
14. Section 4.3: Cranking System Symptoms (ASE A6 study guide) — open-exam-prep — https://open-exam-prep.com/study-guides/ase-a6/starting-system-diagnosis/cranking-system-symptoms
15. 2.1 Cranking & No-Start Diagnostic Procedures (ASE A1 study guide) — open-exam-prep — https://open-exam-prep.com/study-guides/ase-a1/general-engine-testing/cranking-no-start-diagnostics
16. Bad Starter Symptoms: Clicking, No-Crank, and What Techs Test First — Auto Training Centre — https://www.autotrainingcentre.com/blog/bad-starter-symptoms-clicking-no-crank-tests/
17. Why Doesn't the Engine Crank Over? — Vehicle Service Pros — https://www.vehicleservicepros.com/service-repair/article/53084004/why-doesnt-the-engine-crank-over
18. Tech Tip: Diagnosing Starter Cranking Problems — Delco Remy — https://www.delcoremy.com/the-latest/2023/june-2023/tech-tip-diagnosing-starter-cranking-problems
19. Starter Replacement Toyota Camry 2012-2017 XV50 — YouCanic — https://www.youcanic.com/replace-starter-a-toyota-camry/
20. Camry XV70 Repair Manual: Starter Removal (2GR-FKS V6) — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/removal-3602.html
21. Toyota engines A25·M20 Dynamic Force series (R4) — toyota-club.net — https://toyota-club.net/files/faq/18-03-20_faq_df_r4_eng.htm
22. How Much Does a Starter Replacement Cost? — AAA — https://www.aaa.com/autorepair/articles/how-much-does-a-starter-replacement-cost
23. Alternator (automotive) — Wikipedia — https://en.wikipedia.org/wiki/Alternator_(automotive)
24. How to Test Your Alternator (charging checks) — AA1Car — https://aa1car.com/library/charging_checks.htm
25. Charging System Diagnosis — DENSO Auto Parts — https://www.densoautoparts.com/charging-system-diagnosis
26. P0562 Code — Kelley Blue Book — https://www.kbb.com/obd-ii/p0562/
27. Toyota Camry Alternator Replacement: The Complete Guide — CarTipsDaily — https://cartipsdaily.com/toyota-camry-alternator-replacement
28. Toyota Camry Alternator: Specs, Replacement Cost & Upgrade — JS Alternators (업체 페이지) — https://js-alternators.com/blogs/blog/toyota-camry-alternator
29. Serpentine belt — Wikipedia — https://en.wikipedia.org/wiki/Serpentine_belt
30. Camry XV70 Repair Manual: A25A-FKS Drive Belt Installation / Components — tocamry.com (wr-carbook가 매뉴얼에서 직접 확인) — https://www.tocamry.com/installation-2081.html , https://www.tocamry.com/components-2079.html
31. 1.3 Radiators, Hoses, Belts, Pulleys & Fan Clutches (ASE T8, 대형차 교재) — open-exam-prep — https://open-exam-prep.com/study-guides/ase-t8/engine-systems-lube-cooling/radiators-fans-belts-pulleys
32. Camry XV70 Owner's Manual: Engine (ignition) switch, smart key — tocamry.com — https://www.tocamry.com/engine_ignition_switch_vehicles_with_a_smart_key_system_-1901.html
33. Camry XV70 Owner's Manual: If a warning light turns on — tocamry.com — https://www.tocamry.com/if_a_warning_light_turns_on_or_a_warning_buzzer_sounds-2008.html
34. Toyota's Dynamic Force Engines — Vehicle Service Pros — https://vehicleservicepros.com/service-repair/diagnostics-and-drivability/article/55037008/toyotas-dynamic-force-engines
35. Camry XV70 Repair Manual: A25A-FKS Thermostat Removal — tocamry.com — https://www.tocamry.com/removal-3651.html
