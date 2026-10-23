# 구동계 (Drivetrain — FF transaxle, drive shafts, CV joints, mounts)

> 기준 차: 가로배치 직렬 4기통 앞바퀴굴림(FF) 중형 세단, 미국 왼쪽 운전석 (예: Toyota Camry XV70/XV80, Honda Accord 10·11세대, Hyundai Sonata DN8, Nissan Altima L34).
> 차 안 좌표·이름은 `docs/specs/car_spec.md` 기준(앞 = −Z, 운전석 = −X). 1 stud ≈ 280 mm, 바퀴 중심 FL = (−3.25, 1.2, −5.0).
> 출처는 각 줄 끝 [n] → 맨 아래 '출처' 목록. 출처 없는 문장은 쓰지 않아요.
> "(검색 요약)" = 페이지가 막혀 검색 결과 요약으로만 본 것. "(확인 못 함)" = 출처를 못 찾음. "(추론)" = 출처 둘을 이어 낸 결론.

## 한눈에 (3줄)
- FF는 **트랜스액슬** = 변속기 + 차동기어(디퍼렌셜)가 **한 상자**, 엔진 옆(캠리는 운전석 쪽)에 붙고 좌우 **구동축 2개**가 앞바퀴를 돌려요 [15][27].
- 캠리 2.5 L 구동축은 **왼쪽 590.4 mm(짧음) / 오른쪽 916.5 mm(김, 베어링 케이스 볼트 2로 받침)**, 바퀴 쪽 = 공 6개짜리 **제파(Rzeppa) 등속조인트**, 변속기 쪽 = **트라이포드(삼발이) 조인트** [4][5][20].
- 캠리 8단 자동은 **딥스틱이 없어요** — 아래 **오버플로 플러그**에서 ATF가 '똑똑' 흘러나오는 걸로 양을 맞추고, 액은 **Toyota Genuine ATF WS** [8].

---

## 부품: 트랜스액슬 (자동) (Automatic transaxle — "trans", "transmission")
### ① 하는 일
- 엔진 회전을 바퀴에 맞는 속도·힘으로 바꾸고(변속), 안에 든 차동기어로 좌우 바퀴에 나눔. 엔진과 굴리는 바퀴가 같은 쪽 끝에 있는 차(FF 등)에 거의 다 쓰임 [15].
- 캠리 XV70 계열 8단 자동 = 토요타·아이신 **Direct Shift-8AT**: 위키 표 기준 **UA80E/F**(380 N·m급, 캠리 V6 등)와 **UB80E/F**(280 N·m급, "4기통 같은 낮은 토크용", **Camry 2.5 2018~**) 두 계열 [13].
  - Gears 잡지: UA80E 적용 차 = **Camry 3.5 L**, RAV4 2.5 AWD, Highlander 등 [14].
  - 캠리 정비 매뉴얼 A25A 구동축 탈거 절차는 "ATF 빼기(**UB80E 또는 UB80F**)"로 링크 [2].
  - → **캠리 2.5 L(A25A) FWD = UB80E** 로 보는 게 출처와 맞음 (추론, [2][13][14]). 매뉴얼 '트랜스액슬 뭉치' 페이지는 UA80E 장(章) 아래에 있음 [7][12].
- 구조(UA80E 기준): **라비뇨형 유성기어 2세트**로 8단, 클러치 4개(C1~C4) + 브레이크 2개, 원웨이 클러치·밴드 없음; 단마다 **2개 물림·4개 풂**(클러치 투 클러치 변속) [14].
- 기어비(UB80E/F): 1단 5.250 … 6단 1.000 … 8단 0.673, 후진 −4.015 [13].

### ② 실제 모양·크기·재질·색 — 특징 3개
- 매뉴얼 부품도: 트랜스액슬 몸통, **토크 컨버터**, 드라이브 플레이트+토크컨버터 고정 볼트, 시동모터(이음새에 붙음), 숨구멍(breather) 플러그·호스, 앞 엔진 마운트 브래킷, 하네스, **ATF 쿨러 + 들어가고 나오는 쿨러 호스 4개**, 변속 케이블 브래킷, 케이스 커버·플러그 [7].
- 무게: "엔진+트랜스액슬 뭉치는 **아주 무거움**" — 엔진 리프터가 떨어지지 않게 매뉴얼 순서대로 [12]. 단독 무게 (확인 못 함).
- 재질·색: 알루미늄 주물 회색 몸통 (확인 못 함 — 매뉴얼 그림은 흑백 선화).
- 특징 3개(캐주얼): ① 엔진 옆에 붙은 **종 모양(벨하우징) 덩어리** ② 아래쪽 **물결 무늬 리브 + 플러그 2~3개** ③ 옆으로 튀어나온 **구동축 구멍 2개(좌·우)**.

### ③ 차 안 위치
- 엔진 **왼쪽 = 운전석 쪽(−X)**, 배터리·에어클리너·ECM 아래 (README [22] 근거) → car_spec `Deco_Transaxle` X −1.0~−2.6, Y 0.9~1.6 **맞음**.
- 위에 **트랜스액슬 위 마운트**(볼트 5, 42 N·m)가 얹혀 차체에 붙음 (도안 20, diagrams/index.md).

### ④ 붙어 있는 방식·떼는 방법
- 캠리 매뉴얼은 트랜스액슬을 **엔진째 + 앞 서브프레임째 아래로 내림**(Engine assembly with transaxle) [7][12].
- 분리 부품: 시동모터 → 플라이휠 하우징 아래 덮개 → 토크컨버터 고정 볼트 → 하네스 → 쿨러 호스 → 마운트 [7].
- 시간 (확인 못 함).

### ATF (자동변속기 오일) — 점검·교환
- 액 종류: **Toyota Genuine ATF WS** [8]. ATF는 엔진오일과 구별하려고 보통 **빨강(또는 초록)** 으로 물들이고, 빨강 염료는 **누유 찾기**에 도움 [22].
- **딥스틱·주입관 없음**: 케이스의 **주입구(refill hole)** 로 넣고, 하우징의 **오버플로 플러그**에서 **넘치는 양을 흘려 보내** 높이를 맞춤. "오버플로" = 플러그 구멍에서 ATF가 나오는 상태 [8].
- 조건: 차를 리프트에 **수평**(앞뒤·좌우 ±1 이내)으로, 엔진이 식었을 때 정량 넣고 → 엔진을 돌려 순환 → **정해진 액 온도 + 공회전**에서 확인 [8]. 정확한 온도 범위는 매뉴얼 본문에서 못 읽음 (확인 못 함).
  - 참고: Gears 잡지(UA80E) "최소 **20 °C(68 °F)**, 엔진 켜고 P, 아래 플러그에서 **똑똑 떨어지면** 정상, 모자라면 주입구로 천천히" [14]; DIY 포럼(UB80E) "95~113 °F, 104 °F가 이상적" [31](검색 요약, 비공식).
- 교환 뒤: Techstream으로 **'ATF 열화 추정값 리셋'** — 안 하면 데이터 'ATF Thermal Degradation Estimate'가 틀림 [9].
- 교환 전 떼는 것: 바퀴집 연장 패드 좌·우, 엔진 아래 덮개, 펜더 에이프런 실(LH) [9].
- 색 판단: 짙은 갈색·검정 = 문제·혹사·수명 끝일 수 있으나, **색만으론 확실치 않음**(대부분 쓰면 어두워짐) → 제조사 교환 주기가 기준 [22].

### ⑤ 흔한 고장
| 증상 (소리·누유 색·경고등·코드) | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 바닥에 **빨간 기름** 자국(트랜스액슬 밑 = 운전석 쪽 앞, 추론) | ATF 누유(실·플러그·쿨러 호스) — 빨강 염료가 누유 확인용 [22]; 쿨러 호스 4개가 누유 후보 자리 [7] | 눈 + 오버플로 플러그 점검 [8] | 새는 곳 수리 + ATF 보충·높이 맞춤 [8] |
| 변속 때 **'붕' 하고 회전만 올라감(flare)·미끄러짐(slip)**, 낮은 단에 오래 머묾 | 액 부족·오염, 솔레노이드, 토크컨버터 클러치 등 → **P0730**(기어비 틀림) [25] | 스캔툴 + 액 상태 | 원인별. "P0730은 몰지 말 것" [25] |
| 고속에서 rpm이 평소보다 높음, 연비↓ | **P0741** 토크컨버터 클러치(TCC) 성능/잠김 안 됨 — 컨버터와 입력축 속도 차이 [24] | 스캔툴 | 밸브바디·TCC 솔레노이드·컨버터·배선·TCM [24] |
| 엔진 경고등 + 변속 이상, 비상(페일세이프) 모드 | **P0700** = 변속기 제어 쪽 고장 신호(대개 시프트 솔레노이드) [23]; 진짜 원인은 **함께 저장된 다른 코드** [23 함께 검색](검색 요약) | 스캔툴로 짝 코드 | 원인별, "아주 심각" [23] |
| 2018 캠리 변속 충격·이상 | 트랜스액슬 하드웨어와 ECM 소프트웨어 불일치 → **T-SB-0010-18**(ECM 재프로그램, 보증 X) [26](검색 요약) | 캘리브레이션 ID 확인 | ECM 리플래시 |
| 2018 캠리 4기통 TCC 관련 MIL | **T-SB-0018-18**: ECM 로직 수정 [26](검색 요약) | Techstream 코드 확인 | ECM 업데이트 |
| 라인 압력 비정상 | SLT 솔레노이드·압력 조절 밸브·오일펌프; D만 낮음 = C1·B2 누설, R만 낮음 = C3·B2 [14] | 압력계: D 공회전 **73~102 psi**, D 스톨 189~232, R 스톨 247~305 [14] | 밸브바디/정비 |
- 시간: (확인 못 함 — 공임 시간 공개 출처 없음).

### ⑥ 게임 손맛 아이디어 (제안만)
- **딥스틱 없는 ATF 점검**: 온도계 바늘이 초록 칸에 들어왔을 때 오버플로 플러그를 열면 → '쏴아'(과다) / '똑똑'(정상) / '안 나옴'(부족, 주입구로 천천히). 차가 기울면(리프트 수평 X) 결과가 틀리는 함정.
- **누유 색 사전**: 빨강 = ATF, (다른 파일) 초록·분홍 = 냉각수, 갈색·검정 = 엔진오일 — 바닥 자국 위치 + 색으로 추리.

---

## 비교: CVT · 다른 회사 (Honda / Nissan / Hyundai)
- **CVT**: 고정 기어 없이 **두 개의 폭이 바뀌는 풀리 + 벨트(또는 체인)** 로 비를 연속으로 바꿈; 차엔 토크가 커서 **체인/강철 벨트** 필요 [17].
- 이름: 닛산 **Xtronic**, 혼다 첫 CVT 1996 시빅 'Multi Matic'(토크컨버터 대신 다판 클러치), 현대·기아 **IVT(Intelligent Variable Transmission)** [17].
- Honda Accord 2018: **1.5T = CVT**(또는 6단 수동), **2.0T = 10단 자동**(또는 6단 수동) [27](검색 요약).
- Nissan Altima 2019: 2.5 L·2.0 VC-Turbo 모두 **Xtronic CVT**, 토크컨버터 잠금 범위 확대 [28](검색 요약).
- Hyundai Sonata DN8의 변속기 종류 (확인 못 함).
- 벨트식 효율 약 **88%**(수동보다 낮지만 엔진을 효율 좋은 rpm에 둘 수 있음) [17].

## 부품: 수동 트랜스액슬 + 클러치 (짧게) (Manual transaxle / clutch)
- 클러치 = **플라이휠 면에 마찰판(디스크)** 을 스프링이 눌러 붙임; 페달을 밟으면 **릴리스 베어링**이 움직여 끊음; 페달 힘은 링크·케이블·**유압(마스터·슬레이브 실린더)** 로 전달 [18].
- 하는 일: 엔진과 변속기를 떼어 출발·변속 [18]. 미끄러짐은 출발 때 조금은 필요하지만 줄여야 마모가 적음 [18]. 증상 목록은 출처에 없음 (확인 못 함).
- 수동은 기준 세단(캠리 XV70 미국형)에 없음 (확인 못 함) — Accord 2018엔 6단 수동 있음 [27](검색 요약).

## 부품: 토크 컨버터 (Torque converter)
### ① 하는 일: 오일로 힘을 전달하는 '물 클러치' — 엔진과 변속기가 **단단히 붙어 있지 않음** [16] → 그래서 D에 두고 서 있어도 엔진이 안 꺼짐 (추론); 수동의 클러치에 해당 [16].
### ② 구성: **임펠러(펌프, 엔진이 돌림) → 터빈(변속기 입력) → 스테이터(오일 방향 바꿈, 원웨이 클러치 위)** + **록업 클러치**(기계로 직결해 손실 제거) [16]. 출발(스톨) 때 힘을 **1.8~2.5배**로 키움 [16].
- 캠리 UA80E는 록업이 **1단 포함 모든 단에서** 가능, SL·SLU 솔레노이드가 잠금·속도 제어 [14].
- 특징 3개(캐주얼): ① **도넛 모양 납작 원통** ② 엔진 쪽 면의 **볼트 자리 원** ③ 가운데 **굵은 축 구멍**.
### ③ 위치: 엔진과 트랜스액슬 사이 벨하우징 안, 드라이브 플레이트에 볼트로 [7].
### ⑤ 고장: 스테이터 클러치 고착 = 효율↓·연비↓, 파손 = 미끄러짐(거의 못 움직임), 계속 미끄러지면 과열 [16]; 코드는 위 P0741 [24].

## 부품: 차동기어 (Differential — "diff", 트랜스액슬 안)
- 코너에서 **바깥 바퀴가 더 많이 돎** → 좌우 바퀴 속도를 다르게 해 주는 장치; 링기어가 힘을 받아 캐리어 속 작은 기어들이 나눔 [19].
- FF에선 트랜스액슬 안에 같이 들어 있음 [15]. 따로 오일을 넣는지(캠리 2WD) (확인 못 함 — AWD는 'transfer oil' 따로 뺌 [2]).

---

## 부품: 좌·우 구동축 (Front drive shafts — "axles", "half shafts", "CV axles")
### ① 하는 일: 트랜스액슬 차동기어에서 앞바퀴 허브로 회전 전달, **바퀴가 조향·상하로 움직여도** 같은 속도로 [20].
### ② 실제 모양·크기 — 특징 3개 (캠리 A25A) [4][5][1]
- **왼쪽(LH, 트랜스액슬 쪽) 길이 A = 590.4 mm**, **오른쪽(RH, 2WD) 916.5 mm**(AWD 920.5) → 오른쪽이 약 1.55배 김 [4][5].
  - 게임 비율: 590 mm ≈ **2.1 stud**, 916 mm ≈ **3.3 stud** (mm ÷ 280).
- 오른쪽은 **베어링 케이스(drive shaft bearing case)를 볼트 2개**로 받쳐서 같이 빠짐(2WD) — 2WD 볼트 토크 **50.5 N·m** [2][6].
- 한 개 구성: 바깥 조인트 축 뭉치(outboard joint shaft) + 바깥 부트·클램프 2 → 가운데 축에 **다이내믹 댐퍼(front drive shaft damper, 클램프 2)** → 안쪽 **트라이포드 조인트**(스냅링으로) + 안쪽 조인트 컵(inboard joint) + 안쪽 부트·클램프 2 [1][3][5].
- 그리스 양: 바깥 **95~115 g**, 안쪽 LH **170~190 g**, RH(2WD) **135~155 g** [5]. 부트 클램프 틈 1.2~4.0 mm [5].
- 특징 3개(캐주얼): ① 양끝의 **주름 고무 부트(바깥 것이 더 작고 둥긂)** ② 가운데 **작은 원통 혹(댐퍼)** ③ 바퀴 쪽 끝 **톱니 축 + 큰 너트**.

### ③ 차 안 위치
- 트랜스액슬(−X 쪽, 엔진 왼쪽)에서 좌우 앞바퀴로; 왼쪽 축은 짧고 오른쪽은 엔진 밑을 지나 길어요 (추론, [4] + README [22]).
- car_spec `Deco_FrontSubframe` '드라이브샤프트 2' 포함 — 길이 차이를 그리면 진짜 같음.

### 길이가 다른 이유와 해결
- 가로 엔진 + 끝에 붙은 변속기에선 **좌우 축 길이가 다른 게 숙명**, 이게 **토크 스티어**(가속 때 핸들 쏠림)의 원인 중 하나; 해결책 = 한쪽에 **중간축(intermediate / lay shaft)** 을 둬 길이를 맞춤("요즘 차 대부분") [21].
- 캠리 매뉴얼은 오른쪽을 '중간축'이 아니라 **'베어링 케이스로 받친 긴 축'** 으로 표기, 길이 590 vs 916 [2][4] → 완전한 '같은 길이' 구조는 아님 (추론).

### ④ 떼는 순서 (캠리 A25A) [2]
1. 바퀴 → 바퀴집 연장 패드 좌·우 → 엔진 아래 덮개 No.1·No.2 → 펜더 에이프런 실 좌·우.
2. **ATF 빼기** (AWD는 트랜스퍼 오일도).
3. **액슬 너트**: 전용 공구 + 망치로 **코킹(찍은 자리) 완전히 펴기**(덜 펴면 축 나사 망가짐) → **브레이크 밟은 채** 너트 풀기. (조이는 힘 294 N·m, 새 너트 — 도안 18)
4. 속도센서 → 타이로드 → 스태빌 링크 → **아래 팔** 분리 → 허브에서 구동축 분리.
5. LH = 전용 풀러로 트랜스액슬에서 뽑기 / RH(2WD) = **볼트 2 풀고 베어링 케이스째** 뽑기.
6. **스냅링** 빼기(새것으로, 끝 틈은 아래로) [6].
- 주의: **오일실·안쪽 부트 손상 X, 떨어뜨리지 말 것**; 잘 안 빠지면 안쪽 조인트 끝을 **놋쇠 막대 + 망치**로 [2].
- 끼울 때: 오일실 입술에 그리스, 안쪽 조인트 톱니에 ATF WS [6]. 다 하면 **앞바퀴 얼라인먼트 + Reset Memory + 영점 보정** [2].
- 시간: 캠리 기준 공임 시간 (확인 못 함).

### 점검 기준 [4]
- 바깥 조인트 **반지름 방향 유격 과다 X**, 안쪽 조인트 **축 방향으로 부드럽게 미끄러짐**, 안쪽 반지름 유격 X, **부트 손상 X**, 길이 A·B 규격 안.

---

## 부품: 등속조인트 (CV joints — 바깥 제파, 안쪽 트라이포드) + 부트
### ① 하는 일 / ② 모양
- **바깥(바퀴 쪽) = 제파(Rzeppa)**: 안·바깥 껍데기 사이 **케이지 속 공 6개**, 꺾임 보통 **45~48°**(최대 54°) — 조향 큰 각도를 받음 [20].
- **안쪽(변속기 쪽) = 트라이포드**: **세 갈래 축 + 롤러 3개**가 홈 3개짜리 컵 안에서 미끄러짐 → 축이 **앞뒤로 늘었다 줄었다(plunge)** 가능, 각도는 작지만 싸고 효율 좋음 [20]. 캠리 매뉴얼도 안쪽 = **TRIPOD JOINT** [1][3].
- **부트(고무 주름 장화)**: 그리스를 가두고 먼지를 막음; 갈라지면 오염물이 들어가 조인트가 **빨리 닳거나 완전히 망가짐** [20]. 그리스는 보통 이황화몰리브덴계 [20].
- 특징 3개(캐주얼): ① 바깥: **둥근 공 모양 관절 + 작은 부트** ② 안쪽: **긴 컵 + 큰 부트** ③ 부트 양끝 **쇠 띠 클램프**.

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 · 시간 |
|---|---|---|---|
| **회전할 때 딱딱딱(clicking)**, 크게 꺾을수록 심함 | **바깥 CV 조인트** 마모 [29](검색 요약) | 주차장 크게 원 돌기 + 바깥 유격 [4] | 구동축(또는 조인트) 교체 [29](검색 요약) |
| **바퀴 안쪽·서스펜션에 검은 그리스 튐** | **부트 찢어짐** → 그리스 빠짐·흙 들어감 [20][29](검색 요약) | 눈: 부트 갈라짐 [4] | 막 찢어졌고 소리 없으면 **부트 교체+그리스 다시 채움**, 이미 소리·떨림이면 축 교체 [29](검색 요약) |
| 가속·감속 때 '덜컥'(clunk), 가속 때 떨림 | **안쪽 조인트** 쪽 [29](검색 요약) — 단 떨림은 바퀴·베어링 등 원인이 많음 [29](검색 요약) | 안쪽 축 방향 미끄러짐·유격 [4] | 교체 |
| 직진 중에도 딱딱 + 심한 떨림 | 완전 파손 직전 [29](검색 요약) | 시운전 | 즉시 교체 |
- 한 번 찢어진 부트를 방치하면 조인트가 끝남 [20].

### ⑥ 게임 손맛 아이디어 (제안만)
- **소리 규칙**: 크게 돌 때 딱딱 = 바깥 조인트, 가속·감속 '덜컥' = 안쪽 조인트 (좌·우 어느 쪽인지 가리는 규칙은 출처 없음 → 게임에선 눈으로 부트 확인해 정함).
- **부트 교체 vs 축 교체** 갈림길: 그리스만 튀고 소리 없음 → 싼 부트 수리(그리스 양 게이지 95~115 g 맞추기), 소리 남 → 축 통째.
- 액슬 너트 '코킹 펴기 → 브레이크 밟고 풀기 → 새 너트 294 N·m → 다시 코킹' 4단계.

---

## 부품: 엔진·변속기 마운트 (Engine / transmission mounts)
### ① 하는 일 / ② 모양
- 고무가 닳으면 엔진이 **너무 많이 움직이고** 떨림이 실내로 옴 — 거꾸로 말하면 마운트 = 엔진을 잡아 두고 떨림을 거르는 고무 받침 [30](검색 요약).
- 캠리 A25A: 서브프레임 위 **앞 엔진 마운트 고무(front engine mounting insulator)** + **뒤 엔진 마운트 고무(rear)** [11], 트랜스액슬 쪽 **뒤 No.2 엔진 마운트 고무 + 뒤 브래킷**, 앞 마운트 브래킷 [7], 트랜스액슬 **위 마운트(볼트 5, 42 N·m)** (도안 20), 엔진 오른쪽 **No.2 엔진 마운트 스테이 RH** [7].
- 캠리 매뉴얼에서 **액티브 컨트롤 엔진 마운트**(진공 스위칭 밸브로 제어)는 **2GR-FKS(V6) 엔진 제어 장에만** 있음 → 4기통 기준 차엔 일반 고무 마운트로 보면 됨 (추론, [30]).
- 특징 3개(캐주얼): ① **쇠 브래킷 2장 사이 검은 고무 덩어리** ② 큰 볼트 2~5개 ③ (유압식이면) 둥근 **통 모양**.

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 · 시간 |
|---|---|---|---|
| 공회전 때 실내 떨림(rpm 올리면 줄어듦) | 마운트 고무 마모 [30](검색 요약) | 눈: 고무 갈라짐·주저앉음, 유압식 기름 샘 [30](검색 요약) | 마운트 교체 · 시간 (확인 못 함) |
| P→D, D↔R 넣을 때 '쿵' | 마운트가 닳아 엔진이 너무 움직임 [30](검색 요약) | 브레이크 밟고 D/R 넣으며 엔진 움직임 보기 [30](검색 요약) | 교체 |
- 비슷한 소리는 실화·구동계·배기관 닿음·느슨한 브래킷에서도 남 [30](검색 요약).

### ⑥ 게임 손맛
- 보닛 열고 손님이 D↔R 넣을 때 엔진이 '꿀렁' 많이 움직이면 마운트 — 눈으로 보는 진단(다른 정비사 손 필요 = 손님 NPC 활용).

---

## 내부 도안 근거 (정비 매뉴얼 그림·분해도 — 본 것과 '어디에 무엇이')
- 도안 20 (components-2989, C419615C02): 자동 트랜스액슬 + **위 마운트** + **ATF 쿨러·호스 4개** [7]. 같은 페이지 다른 그림: 엔진+트랜스액슬이 **앞 범퍼 연장재·서브프레임 브래킷**과 함께 아래로 빠지는 구성, 시동모터·토크컨버터·드라이브 플레이트 볼트, 숨구멍 플러그 [7].
- 도안 17 (components-4013): 서브프레임 위 **앞·뒤 엔진 마운트 고무** [11].
- 도안 18 (components-2923, C370391C01): 구동축 LH/RH, **트라이포드**, 안·바깥 부트, **댐퍼**, 액슬 너트, 스냅링 2종, 오일실 좌·우, (AWD) 트랜스퍼 오일실·더스트 커버·베어링 [1].
- 구동축 점검 그림(inspection-2926): 길이 **A(전체)** · **B(안쪽 조인트 쪽)** — LH A 590.4 / B 87.9~88.5 mm, RH(2WD) A 916.5 / B 97.3~98.3 mm [4].
- 캠리 V6 매뉴얼: 앞쪽 액티브 마운트 = 2GR-FKS 엔진 제어 장 [30 참고: tocamry 3156].

## car_spec · fault_catalog 와 다른 점
1. **변속기 코드**: wr-carbook 메모 'Camry 8단 UA80E' → 출처상 **캠리 2.5 L(A25A) = UB80E**, UA80E는 V6 등 고토크용 [2][13][14]. 게임 글자엔 코드가 안 나오면 영향 없음; 조사 노트·README에서만 정정.
2. `Deco_Transaxle` 구성(변속기·변속 케이블·마운트) 맞음 [7]. 더하면 진짜 같은 것: **ATF 쿨러 + 호스 4개**, **오버플로 플러그(아래)·주입구(옆)** — 'ATF 점검' 일거리를 붙일 자리 [7][8].
3. **ATF/변속기 고장이 fault_catalog에 없음** → 후보: `ATF_LEAK`(빨간 자국, 오버플로 점검), `TRANS_SLIP`(P0730), `TCC_STUCK`(P0741), `TCM_FLAG`(P0700 → 짝 코드 찾기 추리) [22][23][24][25].
4. **CV 조인트·부트 고장이 없음** → 후보: `CV_CLICK`(회전 딱딱 → 축 교체), `CV_BOOT_TORN`(그리스 튐 → 싼 부트 수리) [20][29]. 구동축 교체 끝에 **얼라인먼트 + 영점 보정** 단계(06 파일과 같은 버튼) [2].
5. `Deco_FrontSubframe` '드라이브샤프트 2'는 **좌우 길이 다르게**(LH 2.1 stud, RH 3.3 stud + RH 베어링 받침) 그려야 진짜 [4][2].
6. car_spec `EngineBlock (엔진+변속기 덩어리)` '마운트 3' → 캠리 4기통 마운트는 **앞·뒤(서브프레임) + 트랜스액슬 위 + 오른쪽 스테이** 쪽으로 4군데 이상 보임 (추론, [7][11]) — 게임 단순화(3)는 OK, 장식엔 '앞·뒤 고무 2개'를 서브프레임 위에.

## 출처
1. Toyota Camry XV70 Repair Manual — Front Drive Shaft (A25A-FKS) Components (도안 18) — https://www.tocamry.com/components-2923.html
2. Toyota Camry XV70 Repair Manual — Front Drive Shaft Removal (A25A-FKS) — https://www.tocamry.com/removal-2924.html
3. Toyota Camry XV70 Repair Manual — Front Drive Shaft Disassembly — https://www.tocamry.com/disassembly-2925.html
4. Toyota Camry XV70 Repair Manual — Front Drive Shaft Inspection (길이 A·B) — https://www.tocamry.com/inspection-2926.html
5. Toyota Camry XV70 Repair Manual — Front Drive Shaft Reassembly (그리스 양, 클램프 틈) — https://www.tocamry.com/reassembly-2927.html
6. Toyota Camry XV70 Repair Manual — Front Drive Shaft Installation (RH 볼트 50.5 N·m, 스냅링) — https://www.tocamry.com/installation-2928.html
7. Toyota Camry XV70 Repair Manual — Automatic Transaxle Assembly Components (도안 20) — https://www.tocamry.com/components-2989.html
8. Toyota Camry XV70 Repair Manual — Automatic Transaxle Fluid Adjustment (딥스틱 없음, 오버플로, ATF WS) — https://www.tocamry.com/adjustment-2996.html
9. Toyota Camry XV70 Repair Manual — Automatic Transaxle Fluid Replacement (ATF 열화 추정 리셋) — https://www.tocamry.com/replacement-2994.html
10. Toyota Camry XV70 Repair Manual — Maintenance: UA80E / UB80E ATF 장(章) — https://www.tocamry.com/ua80e_automatic_transaxle_fluid-2136.html , https://www.tocamry.com/ub80e_automatic_transaxle_fluid-2139.html
11. Toyota Camry XV70 Repair Manual — Front Suspension Member Components (엔진 마운트 고무) — https://www.tocamry.com/components-4013.html
12. Toyota Camry XV70 Repair Manual — Automatic Transaxle Assembly (UA80E 장, "very heavy") — https://www.tocamry.com/automatic_transaxle_assembly-2988.html
13. Wikipedia — Aisin–Toyota 8-speed automatic transmission (UA80E/F, UB80E/F 기어비·토크·적용 차) — https://en.wikipedia.org/wiki/Aisin%E2%80%93Toyota_8-speed_automatic_transmission
14. Gears Magazine (2023-04, Mike Brown) — The UA80E: A Closer Look at the 8-Speed FWD for Toyota and Lexus — https://gearsmagazine.com/magazine/the-ua80e-a-closer-look-at-the-8-speed-front-wheel-drive-for-toyota-and-lexus/
15. Wikipedia — Transaxle — https://en.wikipedia.org/wiki/Transaxle
16. Wikipedia — Torque converter — https://en.wikipedia.org/wiki/Torque_converter
17. Wikipedia — Continuously variable transmission — https://en.wikipedia.org/wiki/Continuously_variable_transmission
18. Wikipedia — Clutch — https://en.wikipedia.org/wiki/Clutch
19. Wikipedia — Differential (mechanical device) — https://en.wikipedia.org/wiki/Differential_(mechanical_device)
20. Wikipedia — Constant-velocity joint — https://en.wikipedia.org/wiki/Constant-velocity_joint
21. Wikipedia — Torque steer — https://en.wikipedia.org/wiki/Torque_steer
22. Wikipedia — Automatic transmission fluid — https://en.wikipedia.org/wiki/Automatic_transmission_fluid
23. Kelley Blue Book — P0700 (+ 짝 코드 설명은 검색 요약: FridayParts 등) — https://www.kbb.com/obd-ii/p0700
24. Kelley Blue Book — P0741 — https://www.kbb.com/obd-ii/p0741
25. Kelley Blue Book — P0730 — https://www.kbb.com/obd-ii/p0730
26. (검색 요약) Toyota T-SB-0010-18 (Transaxle & ECM Software Confirmation), T-SB-0018-18 (4기통 TCC DTC), T-SB-0122-20 — NHTSA — https://static.nhtsa.gov/odi/tsbs/2018/MC-10131751-9999.pdf , https://static.nhtsa.gov/odi/tsbs/2018/MC-10133632-9999.pdf
27. (검색 요약) 2018 Honda Accord 변속기 — AutoGuide / TFLcar — https://www.autoguide.com/auto-news/2017/10/top-10-2018-honda-accord-specs-you-need-to-know.html , https://tflcar.com/2017/10/2018-honda-accord-sedan-review
28. (검색 요약) 2019 Nissan Altima Xtronic CVT — Yahoo Autos / NOLN / Nissan News — https://autos.yahoo.com/still-hunting-nissan-tweaks-cvt-182100940.html , https://www.noln.net/articles/3354-tech-spec-2019-nissan-altima
29. (검색 요약) CV 조인트 증상(바깥 딱딱·안쪽 덜컥·부트 그리스) — Auto Training Centre / YourMechanic(403) — https://www.autotrainingcentre.com/blog/bad-cv-axle-symptoms-clicking-vibration/ , https://yourmechanic.com/article/symptoms-of-a-bad-or-failing-cv-boot
30. (검색 요약) 엔진 마운트 증상 — Rick's Free Auto Repair Advice / JEGS; 캠리 V6 액티브 마운트 장 — https://ricksfreeautorepairadvice.com/recognizing-the-symptoms-of-a-bad-motor-mount/ , https://www.tocamry.com/active_control_engine_mount_for_front_side_-3156.html
31. (검색 요약) BITOG — DIY: 2018+ Camry 4-cyl ATF Change (UB80E) (포럼, 비공식) — https://bobistheoilguy.com/forums/threads/diy-2018-camry-4-cyl-atf-change-ub80e.327272/
