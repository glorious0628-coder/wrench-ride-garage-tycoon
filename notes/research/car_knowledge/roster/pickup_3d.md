# 픽업트럭 — 3D용 속 구조 노트 (wr-carbook, 2026-10-22)

> **누가 보나**: 3D 도우미(10/23~), wr-design(`pickup_spec` 쓸 때), wr-dev(잭·볼트 코드).
> **바탕**: [pickup.md](pickup.md)(크기·구동·고장·겉모양, 10-21) + 이번에 새로 찾은 것: 사용설명서 그림 2장 **직접 봄**(F-150 2018 5.0, Silverado 2019+ 5.3), 사용설명서 글, 부품 회사 자료.
> **섞은 차** = Ford F-150(2015~) · Chevrolet Silverado 1500(2019~) — 판스프링 트럭 2대. Ram 1500은 뒤가 코일이라 하체는 빼고 엔진룸만 참고([pickup.md] §3).
> **표시 규칙**: 출처 = 줄 끝 [n](맨 아래 목록). "(검색 요약)" = 검색 결과 요약에서만 봄. "(확인 못 함)" = 못 찾음. **"추정"** = carbook이 숫자를 이어서 계산한 것(출처 X). **"게임 제안"** = 단순화 제안, 정하는 건 wr-design.
> **좌표 약속(car_spec 그대로)**: 앞 = −Z, 위 = +Y, 차 오른쪽(조수석) = +X, 원점 = 앞뒤 바퀴 사이 가운데의 땅. 실제 mm ÷ 280 = stud, **폭(X)만 ×1.15**, 높이(Y)는 실제 그대로(픽업은 원래 높아서 머리 공간 더하기 X).

---

## 0. 한눈에 — 세단과 무엇이 다른가

| | 세단 (car_spec) | 픽업 | 근거 |
|---|---|---|---|
| 뼈대 | 차체가 곧 뼈대(유니바디) + 앞 서브프레임 | **사다리 프레임**(긴 레일 2 + 가로대 여러 개) 위에 캡·짐칸을 따로 얹음 | [pickup.md 3절], [19][20] |
| 엔진 | 가로 직렬 4, 앞바퀴굴림 | **세로 V8(또는 V6)**, 뒷바퀴굴림 + 4WD | [pickup.md 1절] |
| 엔진룸 배터리 | 운전석 쪽 | **조수석 쪽** (두 트럭 모두 — 그림 확인) | [1][2] |
| 보닛 받침 | 받침대 막대(prop rod) | **가스 스트럿 2개**(두 트럭 모두 사용설명서) | [7][8] |
| 냉각 팬 | 전동 팬 1 | **전동 팬 2**(팬 클러치 X) | [4][6] |
| 뒤 서스 | 멀티링크 + 코일 | **통 차축(라이브 액슬) + 판스프링**, 차축이 스프링 **위**에 얹힘 | [15][16][18] |
| 동력 전달 | 앞 구동축 2 | 변속기 → (4WD) 트랜스퍼 케이스 → **긴 구동축 + U조인트** → 뒤 디퍼렌셜 / 앞 구동축 → 앞 디퍼렌셜 | [pickup.md 3절] |
| 바퀴 너트 | 5개 | **6개**(풀사이즈 1500급 전부). 8개는 2500 헤비듀티만 | [9][10][30][31] |
| 머플러 | 뒤 범퍼 밑 가로 통 | **조수석 쪽, 뒤 차축 앞**에 세로로 긴 통 → 꼬리관이 **조수석 뒷바퀴 바로 뒤 옆으로** 나옴 | [25] |
| 스페어 | 트렁크 바닥 | **짐칸 아래 케이블 윈치**로 매달림, 뒤 범퍼 구멍으로 막대 꽂아 내림 | [12][13] |
| 주차 브레이크 | (세단 프로토 없음) | **전동 주차 브레이크 = 뒤 캘리퍼에 모터 혹** | [29] |

**3D가 새로 만들 것 (게임 제안)**: Shell(캡+짐칸)·Glass·Hood(+가스 스트럿 2)·Bumper_F·Bumper_R(스텝 범퍼)·Tailgate·Chassis(사다리 프레임)·엔진룸 장식(V8)·하체 장식(판스프링·통 차축·구동축·트랜스퍼 케이스·앞 디퍼렌셜·배기·탱크·스페어 윈치·히치)·바퀴(6너트)·Battery(긴 것)·Radiator(팬 2)·Muffler(세로 통).
**세단 것 다시 쓸 수 있는 것**: 브레이크 패드 모양(크기만), 냉각수 통·브레이크액 통·워셔 노즐·와이퍼 메시(자리만 옮김), 볼트·너트 공용 메시.

---

## 1. 크기와 구역 (stud)

### 1-1. 큰 숫자 (car_roster v0.2 + 새로 찾은 것)
| 항목 | 값 | 근거 |
|---|---|---|
| 길이 × 폭 × 높이 / 휠베이스 | **21.0 × 8.5 × 7.0 / 13.2** → 앞 차축 Z **−6.6**, 뒤 **+6.6** | car_roster §1, [pickup.md 2절] |
| 앞 오버행 | **3.4** (세단과 같음) → 앞 끝 Z **−10.0** | F-150 앞 오버행 37~37.8 in = 0.94~0.96 m (검색 요약) [32] |
| 뒤 오버행 | **4.4** → 뒤 끝 Z **+11.0** | 길이 − 휠베이스 − 앞 = 7.8 − 3.4 (추정) |
| 타이어 | 지름 **3.32**(car_roster), 폭 제안 **1.3**(275 mm × 1.15 × 1.146) → 바퀴 중심 Y **1.66** | car_roster, [pickup.md 2절] |
| 휠(림) | 18 in → **1.87**(× 1.146) | [pickup.md 2절] |
| 윤거(좌우 바퀴 중심) | **(확인 못 함)** — 게임 제안 **X ±3.55**(세단 비율, 바깥면 4.2 < 반폭 4.25) | 추정 |
| 가장 낮은 점(지상고) | **(확인 못 함)** — 뒤 디퍼렌셜 아래가 가장 낮음. 게임 제안 **0.85**(약 240 mm) | 추정 |

### 1-2. 짐칸·뒤 높이 (Y, 실제 그대로 ÷ 0.28)
| 선 | 실제 | stud | 근거 |
|---|---|---|---|
| 짐칸 바닥 윗면 | 약 32~35 in (0.81~0.89 m) | **3.1** | F-150 (검색 요약) [32] |
| 짐칸 깊이 | 21.4~22 in (0.55 m) | **2.0** | [33] (검색 요약) |
| 짐칸 옆벽 위 끝 | 55.5 in (1.41 m) | **5.0** | F-150 2016 실측(포럼, 검색 요약) [34] |
| 테일게이트 위 끝 | 57.5 in (1.46 m) | **5.2** | 같은 곳 [34] |
| 테일게이트 경첩 | 바닥 높이 = 문 아래 끝 양 모서리 | **약 3.0** | 추정(바닥 높이에서 아래로 내려 열림) |
| 짐칸 바닥 길이(안쪽) | 67~70 in (1.70~1.78 m) | **6.1~6.4** | F-150 67.1 / Silverado 70 in (검색 요약) [33] |
| 히치 구멍(2 in 사각) | 위 20 in · 아래 18 in (Silverado 2018 순정 18 in 타이어) | 가운데 **1.7** | 포럼 실측(검색 요약) [34] |
| 캡-짐칸 틈 | (확인 못 함) | 게임 제안 **0.15** | — |

### 1-3. 앞뒤 구역 (Z) — **추정**(위 숫자를 이어 붙인 것, 3D 회색 단계에서 메인이 옆모습으로 판단)
| 구역 | Z | 메모 |
|---|---|---|
| 앞 범퍼 끝 | −10.0 | 프레임 앞 끝(크러시 혼)에 볼트 |
| 라디에이터 | 약 −9.2 | 앞 차축보다 약 2.6 앞 |
| 엔진룸 | −9.6 ~ **약 −4.0**(방화벽) | 보닛이 길어 세단(−8.0 ~ −3.8)보다 앞으로 김 |
| 앞 차축 | −6.6 | |
| 캡(2열 크루캡) | 약 −4.0 ~ +3.9 | |
| 짐칸 앞벽 바깥 | 약 +4.05 | 캡과 틈 0.15 |
| 뒤 차축 | +6.6 | 짐칸 가운데보다 조금 앞 |
| 테일게이트 바깥 | 약 +10.6 | |
| 뒤 범퍼 끝 | +11.0 | 스텝 범퍼가 테일게이트보다 0.4쯤 튀어나옴 |

---

## 2. 엔진룸 (보닛 열었을 때) — 세로 V8

### 2-1. 무엇이 어디에 (사용설명서 그림 직접 봄)
그림은 둘 다 **차 앞에서 뒤(방화벽)를 보고** 찍은 것 → 그림 오른쪽 = 차 왼쪽(운전석). 브레이크액 통이 그림 오른쪽 위(운전석 방화벽)인 걸로 맞춤 확인.

| 부품 | F-150 2018 5.0 [2] | Silverado 2019+ 5.3 [1] | **게임 제안** (X, Z는 추정) |
|---|---|---|---|
| **배터리** | 조수석 쪽, 엔진 옆 가운데쯤 (B) | 조수석 쪽, 뒤쪽(방화벽 쪽) (3) — + 단자는 덮개 아래(2), **− 점프용 단자는 펜더 쪽 따로**(1) | **조수석(+X)**, X ≈ +2.6, Z ≈ −6.0 |
| 퓨즈·릴레이 박스 | 조수석 쪽(2018~20 "오른쪽") [5] | 조수석 쪽, 배터리 **앞** (4) — 1500은 조수석 [3] | 배터리 앞(+X, Z ≈ −7.6) |
| **에어필터 통** | 운전석 쪽 앞~가운데, 큰 상자 (F) | 운전석 쪽 앞~가운데, 큰 상자 (9) | **운전석(−X)** 앞, 굵은 흡기관이 엔진 앞 가운데 스로틀로 감 |
| **브레이크액 통**(마스터 실린더+부스터) | 운전석 방화벽 (E) | 운전석 방화벽 (10) | 운전석 방화벽(−X, Z ≈ −4.4) — 세단과 같은 쪽 |
| **냉각수 통** | 앞 가운데쯤(라디에이터 뒤) (G) | 운전석 쪽 뒤, 엔진 옆(8) — **압력 캡이 여기**(라디에이터 캡 없음) [4] | Silverado식: 운전석 뒤쪽, 브레이크액 통 안쪽 |
| **워셔액 통** 주입구 | 조수석 앞 구석 (A) | 운전석 앞 구석 (11) | 둘 다 실제 — 게임 제안: **조수석 앞 구석**(운전석 앞은 에어필터가 차지) |
| 엔진오일 주입 캡 | 조수석 쪽 헤드 위 (C) | 운전석 쪽 헤드 뒤 (7) | 한쪽 헤드 위(아무 쪽) |
| 오일 게이지 | 가운데 뒤 (D) | 조수석 쪽 앞 (5) | 엔진 옆 노란 고리 |
| 냉각 팬 | 그림 밖(라디에이터 뒤) | "전동 냉각 팬(그림 밖)" (6) | 라디에이터 뒤 슈라우드 안 **팬 2개** |

- 같은 자리를 쓰는 것: **배터리 조수석 · 에어필터 운전석 · 브레이크액 운전석 방화벽**(두 트럭 같음). 이 셋이 '트럭 엔진룸 얼굴'.
- Ram 1500(DT)는 사용설명서 그림을 못 읽음(확인 못 함). 옛 Ram(DS)은 배터리가 운전석 앞(검색 요약) [P-Ram] → 세 회사가 다 같지 않음. 우리는 **두 트럭이 같은 '조수석 배터리'**로.

### 2-2. 엔진 모양 (세로 V8 — 캐주얼이지만 구성은 빠짐없이)
| 덩어리 | 무엇 | 자리 | 근거 |
|---|---|---|---|
| 앞면 | **서펜타인 벨트 + 풀리**(물펌프·발전기·에어컨 압축기·텐셔너) — **라디에이터 쪽을 봄** | 엔진 앞(Z ≈ −8.0) | "엔진 앞 = 라디에이터 쪽, 뒤 = 방화벽" [P-Eco] |
| 위 가운데 | **흡기 매니폴드**(V자 골 사이), 스로틀이 앞쪽 | 두 뱅크 사이 위 | [P-Eco], 그림 [2]의 흡기 주름 8줄 |
| 양 옆 헤드 | **밸브 커버 2**(좌·우 뱅크), 각 뱅크에 **점화 코일 4개**(V8 = 8개, V6 = 6개) | 엔진 양옆 위 | 코일-온-플러그 배치는 일반 구조(이 차 출처 확인 못 함) |
| 양 바깥 아래 | **배기 매니폴드 2**(주철, 좌우 하나씩) + 열 차단판 → 아래로 내려가 배기관 | 엔진 양 바깥 아래 | [pickup.md 3절][16] — V형은 매니폴드 2개 |
| 뒤 | 벨하우징 → **변속기**(10단·8단 자동, 길게 뒤로) | 방화벽 아래로 캡 바닥 밑 | [pickup.md 1절] |
| 발전기·압축기 좌우 | (확인 못 함) | 게임 제안: 발전기 위 한쪽, 압축기 아래 반대쪽 | — |

- 크기 감: V8은 세단 4기통보다 **폭이 넓고(두 뱅크) 길이는 비슷하거나 김**. 엔진룸 폭 안 꽉 차게 — 엔진룸이 휑하지 않게(세단 규칙 '부품 ×1.1까지 키워도 됨' 그대로).
- 터보 V6(F-150 EcoBoost)는 앞 범퍼 뒤 아래에 **넓고 납작한 인터쿨러**(Ford 부품 "Front Intercooler") [6] — 우리는 **V8 하나로** 만들고 인터쿨러는 X(게임 제안).

### 2-3. 라디에이터·팬
- 앞에서 뒤로: (F-150은 맨 앞 **그릴 셔터** — 검색 요약 [6]) → 에어컨 콘덴서 → 라디에이터 → **팬 슈라우드 + 전동 팬 2개** → 엔진 앞 벨트.
- 팬: Silverado 사용설명서 "Engine Electric Cooling Fans"(여러 개, 시동 꺼도 돌 수 있다는 경고) [4]. F-150은 부품 이름이 "Engine Cooling Motor and Fan Assembly"(클러치 없음) [6]. → **벨트 팬(클러치 팬) X, 전동 팬 2개**.
- 크기: 트럭 라디에이터 치수 (확인 못 함). 게임 제안: 세단 3.6 × 1.9 × 0.6보다 크게 **약 4.6 × 2.4 × 0.6**(추정, 엔진룸 폭 비율).
- Silverado는 **라디에이터 캡이 없음** — 냉각수는 통(서지 탱크) 압력 캡으로만 [4]. 게임의 '냉각수 통에 붓기'와 맞음.

### 2-4. 보닛
| | F-150 | Silverado | 게임 제안 |
|---|---|---|---|
| 받침 | "lift cylinders"(가스 스트럿)가 열린 채 잡아 줌 [8] | "gas strut system"이 자동으로 들어 올려 끝까지 열린 채 잡아 줌 [7] | **가스 스트럿 2개**(좌우 경첩 옆) — 받침대 막대 X(세단·SUV와 다름) |
| 여는 법 | 운전석 대시 아래 레버 → 보닛 앞 가운데 2차 걸쇠 [P-Hood] | 같은 식 [7] | 세단과 같은 2단계 |
| 경첩 | 좌·우 따로 파는 부품(검색 요약) — 자리 글 출처 없음 | 같음 | 뒤 양 모서리(방화벽 쪽) — 일반 구조 |
| 열림 각 | (확인 못 함) | (확인 못 함) | 받침대 제한이 없어 **약 60°**(추정). 리프트 Under(+6)에서 열어도 천장 20 안(추정 앞끝 ≈ 9.7 + 6) |

---

## 3. 사다리 프레임 (Chassis)

### 3-1. 확인된 것
- **완전 박스형(상자 단면) 레일** — F-150 [19], Silverado [20], Ram [21].
- **가로대 수**: F-150 2015~ **8개**(그중 5개는 레일을 뚫고 지나가 양쪽 용접) [19] · Silverado 2019~ "9개"(검색 요약) [20].
- 앞 끝 = 충돌 흡수 '크러시 혼'(앞 범퍼가 붙는 곳) [19]. Ram은 **앞 레일이 바깥으로 벌어짐**(검색 요약) [21].
- 캡은 바닥 가로대의 받침 자리에 볼트(검색 요약) [P-Cab]. 받침 고무 개수 (확인 못 함).

### 3-2. 못 찾은 숫자 → 추정 (wr-design이 ⓒ로)
레일 바깥 간격·단면 높이·땅에서 높이는 차체 회사 자료(Ford BBAS, GM Upfitter)에만 있고 못 읽음(확인 못 함). 아래는 **다른 숫자에서 이은 추정**:
| 항목 | 추정 (stud) | 이은 근거 |
|---|---|---|
| 레일 가운데 X (뒤·가운데 구간) | **±2.3** | 판스프링이 레일 바로 아래 매달림 + 짐칸 바퀴집 사이 폭 50.6 in(±0.64 m → ±2.6 stud) 안쪽 + 뒷타이어 안쪽면 2.9 안쪽 |
| 레일 가운데 X (앞 구간) | **±2.0** | 앞바퀴가 꺾일 자리 — Ram '벌어진 앞 레일'은 앞 끝에서만 바깥으로 [21] |
| 레일 단면 (높이 × 폭) | **0.7 × 0.3** | 약 200 × 75 mm급(일반 하프톤 크기 감, 출처 없음) |
| 레일 높이 — 캡 아래 구간 | 아래 **1.4** · 위 **2.1** | 추정 |
| 레일 높이 — 뒤 차축 위 '킥업' | 아래 **2.2** · 위 **2.9**(짐칸 바닥 3.1 바로 밑) | 레일이 차축을 넘어가려고 위로 휨 — 프레임 트럭 공통 구조(이 두 차 글 출처 확인 못 함) |
| 레일 높이 — 엔진 아래 앞 구간 | 아래 **1.6** · 위 **2.3** | 추정 |
| 레일 앞 끝 / 뒤 끝 | Z **−9.6** / **+10.6** | 앞 범퍼 뒤 ~ 히치 가로대 |

### 3-3. 가로대 — 게임 제안 7개 (실제 8~9개를 줄임)
| # | 자리 Z | 무엇이 붙나 |
|---|---|---|
| ① | −9.4 | 라디에이터 받침·앞 범퍼 |
| ② | 약 −7.4 | **앞 서스 가로대**(아래 A암 뿌리) — 엔진 바로 아래 앞 |
| ③ | 약 −2.4 | **변속기 가로대**(변속기 뒤 받침) |
| ④ | 약 +1.0 | 캡 뒤 받침 |
| ⑤ | 약 +4.3 | 짐칸 앞 + 판스프링 앞 걸이 근처 |
| ⑥ | 약 +8.9 | **스페어 윈치**가 붙음(뒤 차축 뒤) |
| ⑦ | 약 +10.6 | 뒤 끝 가로대 + **히치 리시버** + 스텝 범퍼 받침 |

---

## 4. 뒤 통 차축 + 판스프링 (F-150 · Silverado 공통)

| 항목 | 내용 | 근거 |
|---|---|---|
| 차축과 스프링 | **차축이 스프링 위에 얹힘**(spring-under). 리프트 블록이 '차축과 스프링 사이'에 들어가고, 내림 키트 설명이 스프링을 '차축 아래'로 다시 단다고 씀 | 간접 근거 [18] (검색 요약) — 공장 매뉴얼 글은 못 찾음 |
| 앞 끝 | 스프링 **앞 눈(eye)** → 프레임에 고정된 **앞 걸이(hanger)** | [P-Ride] [16][pickup.md 3절] |
| 뒤 끝 | 스프링 **뒤 눈** → **섀클**(흔들리는 짧은 고리)로 프레임에 매달림 — Silverado는 섀클을 따로 팖 | [16] |
| 길이 (휜 면 따라) | **Silverado 31⅜ + 31⅜ in = 약 1,594 mm, 차축이 정가운데** · F-150 28½ + 31⅝ in = 약 1,527 mm, 차축이 한쪽으로 3 in 치우침(어느 쪽이 앞인지 확인 못 함) | 부품 회사 사양 [15][16], 재는 법 = 눈 중심 ↔ 가운데 볼트 [17] |
| 판 수 | 순정 **3장**(긴 판 2 + 짧은 보조 1) — 두 트럭 같음. 무거운 짐용은 4~5장 | [15][16] |
| 폭 | F-150 3 in · Silverado 2½ in | [15][16] |
| 고정 | 차축마다 **U-볼트 2개 = 너트 4개**(한쪽), 아래에 받침판, 가운데 볼트가 차축 자리를 잡음 | F-150 U-볼트 4개/차 (검색 요약) [23], [pickup.md 3절] |
| 쇼바 | F-150 2015~ = **바깥쪽 + 엇갈림**(한쪽은 차축 앞, 다른 쪽은 뒤) [19]. Silverado (확인 못 함) | [19] |
| 디퍼렌셜 | 가운데 '호박통' — 정가운데인지 치우쳤는지 (확인 못 함). **뒤 덮개 볼트 12개**(F-150 Super 8.8 [22], Silverado 9.5/9.76 in "12볼트"(검색 요약)) | [22] |
| 오일 | F-150 덮개에 주입 구멍. GM 뒤 디퍼렌셜은 **주입 플러그만, 빼는 플러그 없음**(포럼, 검색 요약) → 오일 빼려면 덮개를 엶 | [22] |
| 차축 축 | F-150 = 안쪽 **C-클립**으로 고정(포럼, 검색 요약) | [22] |

**게임 제안 자리 (추정)**
- 차축 통: X −3.0 ~ +3.0, Y **1.66**(바퀴 중심), Z +6.6. 디퍼렌셜 호박통 가운데 X 0, 크기 약 1.4 × 1.3 × 1.2(X×Y×Z), **가장 낮은 점 Y ≈ 0.85**, 덮개(볼트 12 원)는 **뒤(+Z)를 봄**.
- 판스프링(Silverado식 대칭): X **±2.3**(레일 아래), 앞 눈 Z **+3.8**, 뒤 섀클 Z **+9.4**, 가운데(차축 아래) Y 약 1.3, 양 끝 눈 Y 약 2.0(아래로 휜 활 모양, 실제 휨 약 5¾ in = 0.5 stud [P-Spring]).
- 쇼바: 왼쪽 = 차축 앞, 오른쪽 = 차축 뒤(엇갈림 — 어느 쪽이 앞인지는 확인 못 함, 게임 선택). 아래 끝 = 차축 통, 위 끝 = 프레임.
- **둘이 들면 쉬운 판스프링**(car_roster LEAF_SPRING_SAG): 실제로 길고(1.5 m+) 무거움 → TwoHand가 맞음. 무게 (확인 못 함).

---

## 5. 동력 전달 (4WD 판 기준 — 게임 제안: 크루캡은 4WD로)

| 부품 | 자리 (추정) | 메모 · 근거 |
|---|---|---|
| 변속기 | Z −4.2 ~ −1.0, X 0, Y 1.0~1.9 | 엔진 뒤로 길게, 캡 바닥 밑 [pickup.md 1절] |
| **트랜스퍼 케이스** | Z −1.0 ~ +0.2, 변속기 바로 뒤 | 앞·뒤 구동축으로 힘을 나눔, 4LO [pickup.md 3절][20-old] |
| **뒤 구동축** | 트랜스퍼 케이스 뒤 → 뒤 디퍼렌셜 앞(Z ≈ +5.9), 길이 약 5.7 | 5.5 ft 짐칸 크루캡은 **한 토막**일 가능성(6.5 ft 이상만 두 토막이라는 포럼 답, 검색 요약) [24] → 게임: 한 토막, **양 끝 U조인트 2** |
| 앞 구동축 | 트랜스퍼 케이스 앞 → 앞 디퍼렌셜 | (검색 요약) [P-4wd] |
| 앞 디퍼렌셜 | 앞 차축 근처, 프레임에 볼트(독립 서스) | 어느 쪽으로 치우쳤는지 **회사마다 다름**(GM 운전석 쪽 / Ram 조수석 쪽 — 둘 다 부품 이름에서 짐작, 검색 요약) [P-4wd] → 게임: 운전석 쪽 조금 |
| 앞 반축 2 | 앞 디퍼렌셜 → 앞 바퀴, **등속조인트(CV) + 주름 부트** | F-150 좌우 CV 축 (검색 요약) [P-4wd] |
| 2WD 판 | 트랜스퍼 케이스·앞 구동축·앞 디퍼렌셜·앞 반축 **없음**, 변속기 → 뒤 구동축 바로 | [pickup.md 3절] |

- U조인트 = **십자 모양 + 컵 4개**(캐주얼하게 십자 + 둥근 끝 4). 고장 UJOINT_WORN(car_roster)의 부품.

---

## 6. 앞 서스·조향·브레이크·바퀴

| 항목 | 내용 | 근거 |
|---|---|---|
| 앞 서스 | **더블 위시본**(위·아래 A암) + **코일오버 쇼바**(스프링이 쇼바를 감쌈), 알루미늄 너클(F-150) | [pickup.md 3절][P-F150] |
| 조향 | 랙 앤 피니언(F-150 표준) | [19] — 랙이 차축 앞/뒤인지 (확인 못 함) → 게임 제안: 세단처럼 **차축 뒤**, 그러면 캘리퍼는 **앞쪽**(세단 규칙 그대로) |
| 브레이크 | **4바퀴 디스크** | [19][28] |
| 디스크 지름 | Silverado(2.7) 앞 345 · 뒤 360 mm 통풍 [28] · F-150 2020 앞 350 · 뒤 348 mm, 2021~ 뒤 336 mm (검색 요약) [P-Rotor] | → 게임 제안 앞·뒤 **약 1.41 stud**(345 mm ÷ 280 × 1.146) — 18 in 림 1.87 안에 들어감 |
| 주차 브레이크 | Silverado 2019~ = **뒤 캘리퍼에 모터**(처음 전동) (검색 요약), F-150도 2018~ 전동 주차 브레이크 [29] | → 뒤 캘리퍼에 **모터 혹 + 전선** 장식 |
| **바퀴 너트** | **6개**, M14 × 1.5. F-150 6 × 135, Silverado·Ram 6 × 139.7 | [30][P-F150] |
| 조이는 힘 | F-150 **150 lb·ft (204 N·m)** [9][12] · Silverado **140 lb·ft (190 N·m)** [10] · Ram 130 lb·ft (176 N·m, 검색 요약) [30] | 세단 103 N·m의 약 2배 |
| 조이는 순서 | 두 사용설명서 다 **"엇갈려(crisscross)·그림 순서대로"**, 다 조이는 건 바퀴를 땅에 내린 뒤 [9][10]. 6너트 순서 예 **1 → 4 → 2 → 5 → 3 → 6**(마주 보는 쌍, 2차 출처, 검색 요약) [11] | 그림 자체는 못 읽음 |
| 다시 조이기 | F-150 160 km 안에 한 번 더 [9] · Silverado 160·1,600·9,600 km에 점검 [10] | 손님 팁 대사 소재 |
| 바퀴 무게 | 18 in 휠 약 28.5 lb + 275/65R18 타이어 45~56 lb → 한 짝 **약 75~85 lb(34~39 kg)** | 부품 쇼핑 글(검색 요약) [37] — 합은 추정 |

**게임 제안 (바퀴)**
- 너트 원 반지름: 실제 139.7 mm PCD → 반지름 0.25 stud × 1.146 = 0.29, 세단처럼 클릭 쉽게 키우면 **약 0.34**. 12시부터 **60°씩 6개**.
- 별 순서 보너스: 1(12시) → 4(6시) → 2(2시) → 5(8시) → 3(4시) → 6(10시) — 마주 보는 쌍을 번갈아.
- 무게 **36 kg**, Roll 그대로(세단 20 kg보다 무거움 — 굴리기 속도만 조금 느리게).

---

## 7. 배기·연료·스페어·히치 (차 밑)

### 7-1. 배기 (단일 배기 V8 기준)
- 길: 배기 매니폴드 2(좌우) → 아래 파이프 2(촉매 — 자리 확인 못 함) → **Y자로 합침**(변속기 뒤) → 조수석 쪽 따라 뒤로 → **머플러** → 꼬리관이 **뒤 차축 위로 넘어** → **조수석 뒷바퀴 바로 뒤에서 옆으로** 나옴 [25].
  - F-150: 순정 자리에 그대로 다는 단일 배기 = "조수석 뒷타이어 뒤로 나옴", 머플러는 차축 앞 + '차축 넘는 꼬리관'(검색 요약) [25].
  - Silverado 5.3 단일 배기도 **조수석 뒷타이어 뒤**. 듀얼 배기 판은 뒤 범퍼 구멍 2개로(스페어·히치를 피해 돌아감) [25].
  - Ram 5.7은 순정이 듀얼 → 뒤 범퍼 [25]. → 우리는 **단일, 옆으로** (F-150·Silverado 공통).
- **게임 제안 `Muffler` 자리 (추정)**: 조수석 쪽 레일 안쪽, X ≈ **+1.3**, Y ≈ 1.1, Z ≈ **+2.0 ~ +4.6**(캡 뒤 아래 ~ 짐칸 앞 아래), 앞뒤로 긴 납작 타원 통. 볼트·고무 걸이 방식은 세단과 같게(앞 플랜지 볼트 2 + 고무 걸이 2~3).
- 꼬리관 끝: X ≈ +3.9(차체 옆 바로 안), Z ≈ **+8.6**(뒷타이어 뒤끝 8.26 바로 뒤), Y ≈ 1.1, 옆·아래로 향함.

### 7-2. 연료탱크
- 세 트럭 다 (확인 못 함). 애프터마켓 '미드십 교체 탱크'가 **레일 사이** 순정 자리에 들어간다는 설명(검색 요약) [26]. Silverado 순정 약 91 L(검색 요약), Ram DT 26갤런(검색 요약).
- **게임 제안**: 레일 사이 **운전석 쪽 반**(X −1.6 ~ −0.2), Z +1.0 ~ +4.4(뒤 차축 앞), 쇠끈 2 — 머플러(조수석 쪽 반)와 나란히.

### 7-3. 스페어 타이어 (사용설명서 글)
- F-150: 스페어는 **차 밑, 뒤 범퍼 바로 앞**. 범퍼 **구멍에 열쇠 실린더**가 있고, 잭 손잡이를 범퍼 구멍 → **안내관**에 꽂아 **반시계로 돌리면 내려옴**. 윈치 받침이 타이어를 **프레임에 납작하게** 붙여 잡음. 잭·공구 가방 = **캡 뒷좌석 조수석 쪽** [12].
- Silverado: 호이스트 막대를 **뒤 범퍼 구멍**으로 넣음, 케이블은 프레임 브래킷에 클립, 스페어 잠금은 범퍼 덮개 밑, **밸브 꼭지가 아래**로 가게 보관. 잭·공구 = **2열 좌석 밑**(크루캡) [13].
- 녹 때문에 잘 안 내려오는 일 흔함 [pickup.md 3절 [25]] → 고장·미니게임 소재.
- **게임 제안 자리**: 타이어 3.32를 **눕혀서**(축이 세로) X 0, 가운데 Z **+8.9**, 위 Y ≈ 2.2 · 아래 ≈ 0.9(가로대 ⑥ 아래). 윈치(작은 원통) = 가로대 ⑥ 위 가운데, 안내관 = 윈치 → 뒤 범퍼 가운데 구멍(Z +10.9, Y ≈ 2.4). 앞쪽 디퍼렌셜 덮개(Z ≈ 7.1)와 틈 약 0.1 — 실제도 빠듯.

### 7-4. 히치·트레일러
- 뒤 범퍼 밑 가운데 **2 in 사각 리시버**, 프레임 뒤 끝(가로대 ⑦)에 볼트 [pickup.md 3절][22-old]. 높이 가운데 Y **≈ 1.7**(포럼 실측) [34]. 옆에 **7핀 트레일러 소켓**(둥근 뚜껑) [pickup.md [23]].

---

## 8. 잭·리프트 자리 (wr-design 질문 1)

| 쓰임 | F-150 | Silverado 1500 | 게임 제안 (추정 좌표) |
|---|---|---|---|
| **사용설명서 잭(타이어 교체, 모서리 하나)** — 앞 | **프레임 레일**(화살표 표시), **"컨트롤 암 X"** [12] | 앞 타이어 **바로 뒤 프레임 브래킷** 아래 [13] | 레일 아래, Z ≈ −4.6(앞바퀴 뒤), X ±2.0, Y ≈ 1.6 |
| — 뒤 | 타이어 옆(그림만, 차축인지 글로는 확인 못 함 — 포럼은 차축) [12] | **차축 아래, 쇼바 브래킷에서 약 2 in(5 cm) 안쪽** [13] | 차축 통 아래, X ±2.6, Z +6.6, Y ≈ 1.5 |
| **2주 리프트 팔** | 레일 위 자리(확인 못 함) | 앞 패드 = **앞 프레임 레일 자리**, 패드가 레일 폭 이상이어야(GM 넓은 받침 따로 팖) [14] — 뒤 (확인 못 함) | `LiftPoint_*` = 레일 아래 **Z ±4.5, X ±2.2, Y ≈ 1.4**(car_roster §4 그대로) |
| **플로어 잭(정비소, 가운데 하나)** — 앞 | (공장 글 확인 못 함) | (확인 못 함) | 정비소 관행: **앞 서스 가로대 ② 가운데**(Z ≈ −7.4, Y ≈ 1.6). **앞 디퍼렌셜·컨트롤 암에 대지 않기**(F-150 설명서 "컨트롤 암 X") [12][36] |
| — 뒤 | (확인 못 함) | 설명서 잭이 차축 아래 [13] | 정비소 관행: **뒤 차축 통/디퍼렌셜 호박통 아래**(Z +6.6, Y ≈ 0.85~1.5) — 차축 통이 가장 안전, 호박통은 회사 허락 있을 때만(일반 글) [36] |
| **잭 스탠드** | 프레임 레일 | 프레임 | 앞 = 레일 아래(Z −4.6), 뒤 = **차축 통 아래(스프링 자리 옆)** 또는 차축 앞 레일(Z +4.3) [36] |

- 세단과 다른 점: 세단은 앞 잭 = 서브프레임 가운데(앞바퀴 축 1.6 앞). 픽업은 **프레임 레일·가로대·차축 통**이라 받침이 단단한 쇠 덩어리 — 잭 안장이 닿는 자리를 3D에서 평평하게.

---

## 9. 고치는 부품 — 세단과 같은가 다른가 (게임 부품별)

| 게임 부품 | 같은 것 | 다른 것 (픽업) |
|---|---|---|
| `Hood` | 경첩 볼트 2×2, 2단계 열기 | 더 크고 높음, **가스 스트럿 2개**(받침대 X) [7][8] — 떼려면 스트럿 먼저(실제 순서) |
| `Bumper_F` | 앞에서 빼는 큰 판 | **프레임 앞 끝(크러시 혼)에 볼트로** 붙는 무거운 범퍼(세단은 클립+볼트 플라스틱 덮개) [19] — 볼트 수 (확인 못 함), 게임 4개 OK |
| `Bumper_R` | 뒤 큰 판 | **스텝 범퍼**(밟는 판·번호판·**스페어 막대 구멍·열쇠 구멍**), 프레임 뒤에 볼트, 히치가 그 아래 [12][13] |
| `Battery` | 떼는 순서(− 먼저 → + → 고정쇠), 단자 2 + 고정 1 | **조수석 쪽**, **더 긴 AGM**: H7/94R = 315 × 175 × 190 mm(세단 H5 242 mm보다 약 30% 김) 또는 H6/48 [27]. Silverado는 **− 점프 단자가 펜더 쪽 따로** [1] |
| `Wheel` ×4 | 리프트/잭 → 너트 → 굴려 빼기 | **너트 6개**, 204/190 N·m, 엇갈린 6너트 순서, 한 짝 약 36 kg [9][10][37] |
| `BrakePads` ×4 | 바퀴 → 캘리퍼 볼트 2 → 패드 → 피스톤 밀기 | 더 큼. **뒤 캘리퍼 = 전동 주차 브레이크 모터** [29] → 실제 정비는 스캐너로 '정비 모드'(주차 브레이크 풀기) 먼저 — EPB 차 일반 상식(이 차 매뉴얼 확인 못 함). 게임 소재: 뒤 패드 = OBD 스캐너 한 번 |
| `Radiator` | 위 브래킷 볼트 + 호스 + 팬 커넥터, 팬 슈라우드 같이 나옴 | 더 큼, **팬 2개**, Silverado는 라디에이터 캡 없음 [4] |
| `Muffler` | 앞 플랜지 볼트 + 고무 걸이, `Lift:Under` | **조수석 쪽 차축 앞 세로 통**, 꼬리관 **옆으로** [25] |
| 냉각수 통 · 브레이크액 통 · 워셔 | 같은 부품·같은 붓기 일 | 자리만: 브레이크액 운전석 방화벽(같음), 냉각수 운전석 뒤(Silverado), 워셔 앞 구석 [1][2] |
| 와이퍼 · 워셔 노즐 | 앞 와이퍼 2 — 길가 일(curb_jobs) 그대로 | 더 큰 앞유리라 날이 조금 김(길이 확인 못 함) |
| **픽업만** | — | `LeafSpring_L/R`(섀클·U-볼트), U조인트(구동축), 뒤 디퍼렌셜 오일(덮개 12볼트), 스페어 윈치, (4WD) 트랜스퍼 케이스 — car_roster §2-2·§3 |

---

## 10. 코드·설계에 영향 (→ wr-design · wr-dev, 정하는 건 그쪽)
1. **바퀴 너트 수가 차종마다 달라짐**(세단·SUV 5 / 픽업 6): 지금 `CarParts`는 "볼트 수는 모든 차종 공용"(코드 주석) → 픽업 Wheel `bolts = 6`이 가능하게.
2. **보닛 받침 = 가스 스트럿**: 세단·SUV의 `HoodProp`(받침대 세우기) 대신 열면 스트럿이 받침(손 동작 하나 줄어듦).
3. **배터리가 조수석 쪽**: `Snap_Battery`가 +X — 작업 화면 카메라가 반대쪽을 봐야 함.
4. **잭 자리**: 앞 = 가로대(또는 레일), 뒤 = 차축 통 — 세단의 '앞바퀴 축 1.6 앞' 규칙과 다름.
5. **바퀴 무게 36 kg**, 판스프링 TwoHand(둘이 들면 쉬움).
6. 뒤 패드에 '스캐너로 주차 브레이크 풀기' 단계를 넣을지(진짜 같음, 선택).

---

## 11. 출처
번호 [n]은 이 파일. [pickup.md …]는 10-21 조사 파일의 번호.
1. GM — Chevrolet Silverado 2019~2026 Owner's Manual, **Engine Compartment Overview** (5.3L L84 그림 — 내장 브라우저로 그림 직접 봄, 번호 1~11) — https://www.chsilverado.com/chevrolet_silverado_engine_compartment_overview-305.html
2. Ford — **2018 F-150 Owner's Manual, Under Hood Overview – 5.0L** (그림 E251845 직접 봄, A~G) — https://www.fordservicecontent.com/Ford_Content/vdirsnet/OwnerManual/Home/Content?variantid=4640&languageCode=en&countryCode=USA&moidRef=G539651&Uid=G1914848&ProcUid=G1914849&userMarket=usa&div=f&vFilteringEnabled=False&buildtype=web
3. GM Silverado Owner's Manual — Engine Compartment Fuse Block(1500 = 조수석, 2500/3500 = 운전석) — https://www.chsilverado.com/chevrolet_silverado_engine_compartment_fuse_block-342.html
4. GM Silverado Owner's Manual — Cooling System(전동 냉각 팬, 냉각수 서지 탱크 + 압력 캡) — https://www.chsilverado.com/chevrolet_silverado_cooling_system-311.html
5. fuseandrelay.com — Ford F-150 (13th gen) fuse box locations — https://fuseandrelay.com/ford/f-150-13g.html
6. Ford 부품 카탈로그 — 2018 F-150 Fan Motor(“Engine Cooling Motor and Fan Assembly”) https://www.fordpartsgiant.com/oem-2018-ford-f_150-fan_motor.html · Front Intercooler https://www.fordpartsgiant.com/oem-2018-ford-f_150-intercooler.html · (검색 요약) 그릴 셔터 https://www.autonationparts.com/v-2019-ford-f-150--xlt--3-5l-v6-gas/cooling-system--radiator-and-components
7. 2019 Chevrolet Silverado Owner's Manual p.315~316(보닛 가스 스트럿) — https://www.carmanualsonline.info/chevrolet-silverado-2019-owner-s-manual/32
8. 2021 Ford F-150 Owner's Manual p.503~504(“lift cylinders”, 레버·2차 걸쇠) — https://www.carmanualsonline.info/ford-f-150-2021-owners-manual/51 · 2013~14도 같은 말 https://www.manualslib.com/manual/573212/Ford-F-150.html?page=310
9. 2021 Ford F-150 Owner's Manual p.570~572(바퀴 너트 M14×1.5, 204 N·m, 순서대로, 160 km 뒤 다시) — https://www.carmanualsonline.info/ford-f-150-2021-owners-manual/58
10. 2019 Chevrolet Silverado Owner's Manual p.392(엇갈려 조이기)·p.433(190 N·m) — https://www.carmanualsonline.info/chevrolet-silverado-2019-owner-s-manual/40 · https://www.carmanualsonline.info/chevrolet-silverado-2019-owner-s-manual/44
11. (검색 요약) 6너트 순서 1-4-2-5-3-6 — https://kevinsautos.com/faq/what-is-the-torque-spec-for-the-silverado-1500-lug-nuts.html
12. 2018 Ford F-150 Owner's Manual p.408~414(스페어 자리·범퍼 구멍·안내관·반시계, 잭 자리 프레임 화살표·“NOT the control arm”, 공구 자리, 204 N·m) — https://www.manualslib.com/manual/1376745/Ford-F-150-2018.html
13. GM Silverado Owner's Manual — Tire Changing(호이스트 막대 범퍼 구멍, 밸브 아래, 2열 좌석 밑 공구, 앞 잭 = 타이어 뒤 프레임 브래킷, 뒤 = 차축 아래 쇼바 브래킷 2 in 안쪽) — https://www.chsilverado.com/chevrolet_silverado_tire_changing-363.html
14. GM TechLink — 리프트 받침(앞 프레임 레일 자리, 넓은 어댑터) — https://gm-techlink.com/?p=16991
15. General Spring — 2015~20 F-150 뒤 판스프링 43-1985(28½ × 31⅝ in, 4장/3장, 폭 3 in) https://www.generalspringkc.com/product_p/43-1985.htm · 3장(2/1) https://www.generalspringkc.com/2015-2018-f150-rear-leaf-spring-3-2-1-leaves-1600lb-capacity/
16. General Spring — 2019~25 Silverado/Sierra 1500 뒤 판스프링 22-1849(31⅜ × 31⅜ in, 3장(2/1), 폭 2½ in, 앞 눈 볼트 5/8·뒤 9/16, 섀클 따로) — https://www.generalspringkc.com/2019-2025-chevy-silverado-gmc-sierra-1500-rear-leaf-spring-1825-lbs-capacity-3-2-1-leaves/
17. General Spring — 판스프링 길이 재는 법(눈 중심 ↔ 가운데 볼트) — https://www.generalspringkc.com/blog/how-to-properly-measure-leaf-spring-size-for-your-vehicle/
18. (검색 요약) Silverado 리프트 블록 = 차축과 판스프링 사이 — https://completewebsol.com/product/15-inch-rear-block-w-shock-extensions-19-22-silveradosierra-1500-excludes-trail-boss-at4
19. Off Road Xtreme — 2015 F-150 프레임(완전 박스형, 가로대 8개 중 5개 관통 용접, 크러시 혼, 바깥·엇갈린 뒤 쇼바, 랙 앤 피니언, 4바퀴 디스크) — https://www.offroadxtreme.com/?p=9488
20. GM Authority — 2019 Silverado 프레임(“9개 가로대”, 검색 요약) https://gmauthority.com/blog/2018/02/2019-silverado-frame-lighter-stronger-smarter/ · TFLtruck 완전 박스형 https://tfltruck.com/?p=47601
21. Stellantis — 2019 Ram 1500 보도자료(박스형 레일, 벌어진 앞 레일 — 검색 요약) — https://media.stellantisnorthamerica.com/text.do?id=18757
22. FordMuscle — Super 8.8 덮개 12볼트 https://www.fordmuscle.com/?p=8697 · (검색 요약) Silverado 12볼트 덮개 https://www.go-parts.com/garage/ps-2015-2021-chevrolet-silverado-1500-differential-cover · (검색 요약, 포럼) GM 빼는 플러그 없음 https://bobistheoilguy.com/forums/threads/rear-differential.386142 · (검색 요약, 포럼) C-클립 https://www.mustang6g.com/forums/threads/inside-the-super-8-8-rear-end.150514/
23. (검색 요약) F-150 U-볼트 4개 세트 — https://www.kspmotor.com/products/u-bolts-2004-2020-ford-f150
24. (검색 요약, 포럼) F-150 두 토막 구동축은 6.5 ft 이상 짐칸만 — https://www.f150gen14.com/forum/threads/driveshaft-type-23-screw.28944/
25. 배기 순정 자리 키트 설명: F-150 단일(조수석 뒷타이어 뒤) https://fpautoparts.com/Performance/FlowFX-Cat-Back-Exhaust-System-FLO-717887 · Silverado 5.3 단일 https://rudysdiesel.com/products/flowmaster-flowfx-single-exit-cat-back-exhaust-system-for-2019-2021-gm-1500-5-3l-717858 · 듀얼 https://rudysdiesel.com/products/flowmaster-flowfx-dual-exit-cat-back-exhaust-system-for-2019-2021-gm-1500-5-3l-717894 · Ram 5.7 듀얼 https://rudysdiesel.com/products/flowmaster-flowfx-cat-back-dual-exhaust-system-for-2019-2021-ram-1500-5-7l-hemi-717889
26. (검색 요약) 미드십 교체 탱크 = 레일 사이 — https://elitetruck.com/products/transfer-flow-46-gallon-ram-gas-midship-replacement-fuel-tank-model-0800117435
27. 배터리 규격 표 — F-150 https://autofiles.com/battery-size/ford/f-150/ · Ram 1500 https://autofiles.com/battery-size/ram/1500/
28. auto-data.net — Silverado 1500 IV 크루캡 숏박스 2.7(앞 345·뒤 360 mm 통풍 디스크, 뒤 판스프링 통 차축) — https://www.auto-data.net/en/chevrolet-silverado-1500-iv-crew-cab-short-box-2.7-turbo-310hp-automatic-35467
29. (검색 요약) 2019 Silverado 첫 전동 주차 브레이크 = 뒤 캘리퍼 모터 (GM Authority) · MarkLines — 2018 F-150 ZF 전동 주차 브레이크 https://www.marklines.com/en/news/206797
30. 볼트 규격 — F-150 6×135 https://wheel-sizes.com/lugnuts/ford/f-150/ · Silverado 6×139.7, 190 N·m https://koleso.ee/en/valuveljed/chevrolet/silverado-1500/708/t1xx-2019-2021/1389 · (검색 요약) Ram 6×139.7, 176 N·m https://getjerry.com/car-repair/2019-ram-1500-bolt-pattern
31. (검색 요약) 헤비듀티 8너트(F-250 8×170, 2500HD 8×180, Ram 2500 8×165.1) — https://icecreamswheelsandtires.com/?p=679303
32. (검색 요약) F-150 SuperCrew 5.5' 앞 오버행 37~37.8 in, 짐칸 바닥 높이 32~34.9 in — https://www.autopadre.com/ground-clearance/ford-f-150/2023-xl-supercrew-5-5-box-51291
33. (검색 요약) 2019 Silverado 숏박스 바닥 길이 70 in·깊이 22 in — https://www.autoblog.com/2018/07/27/2019-chevy-silverado-1500-biggest-truck-bed/
34. (검색 요약, 포럼 실측) F-150 짐칸 옆벽 55.5 in·테일게이트 57.5 in https://www.escapeforum.org/goto/post?id=1068462 · Silverado 히치 위 20 / 아래 18 in https://5thgenrams.com/community/threads/need-hitch-height-please.39538/post-592081
36. ToolSource — 프레임 트럭 들 자리(레일·앞 가로대·차축 통·주조 디퍼렌셜은 회사 허락 시) — https://www.toolsource.com/blog/where-to-put-the-jack-and-stands-practical-lift-points-on-modern-cars-and-trucks/
37. (검색 요약) 18 in F-150 휠 약 28.5 lb(eBay) · 275/65R18 타이어 49 lb https://www.Tiresize.com/tires/Bridgestone/Dueler-HT-685-275-65R18.htm
- [P-Eco] FordMasterX — 3.5 EcoBoost 배치(“엔진 앞 = 라디에이터, 뒤 = 방화벽”, 흡기 매니폴드 V 사이) — https://fordmasterx.com/ford-3-5-ecoboost-engine-diagram/ (블로그)
- [P-Hood] Ford 2018 F-150 Owner's Manual — Opening and Closing the Hood — https://www.fordservicecontent.com/Ford_Content/vdirsnet/OwnerManual/Home/Content?variantid=4640&languageCode=en&countryCode=USA&moidRef=G539650&Uid=G1644976&ProcUid=G1702382&userMarket=usa&div=f&vFilteringEnabled=False&buildtype=web
- [P-Ram] (검색 요약) 2016 Ram 1500 엔진룸(배터리 운전석 앞) — http://testdriven.tv/2016/07/under-the-hood-2016-ram-1500-5-7-hemi-v8/
- [P-Cab] (검색 요약) I-CAR — F-150 캡 받침 볼트 — https://rts.i-car.com/crn-22.html
- [P-Ride] Ridetech 2015 F-150 키트(앞 판스프링 브래킷 + 뒤 섀클) — https://coyotedirect.com/products/ridetech-2015-ford-f150-leaf-spring-bracket-kit-rear
- [P-Spring] Springworks — 2009~14 F-150 판스프링(휨 5¾ in) — https://springworks.com/products/2009-2014-ford-f150-f150-raptor-2-wheel-4-wheel-drive-heavy-duty-rear-leaf-spring-43-1783hd
- [P-4wd] (검색 요약) 앞 구동축 = 트랜스퍼 케이스 → 앞 디퍼렌셜 https://www.americantrucks.com/f150-front-driveshaft-assembly-938-310.html · F-150 CV 반축 https://www.americantrucks.com/f150-axles-2015.html · GM 오른쪽 중간축 https://www.autonationparts.com/v-2024-chevrolet-silverado-1500--lt--5-3l-v8-gas/front-drive-axle--front-axle · Ram 운전석 중간축(포럼) https://5thgenrams.com/community/threads/front-differential-fix.72271/
- [P-F150] (검색 요약) 2021 F-150 더블 위시본·알루미늄 너클 — https://www.autoblog.com/es-us/buy/2021-Ford-F_150/review/
- [P-Rotor] (검색 요약) F-150 2021~ 뒤 336 mm 디스크 — https://www.campingworld.com/timbren-bes-rear-brake-kit-for-ford-f-150-2021-2026-with-336mm-rotor-163349.html
- [20-old] Transfer case — Wikipedia — https://en.wikipedia.org/wiki/Transfer_case · [22-old] Tow hitch — Wikipedia — https://en.wikipedia.org/wiki/Tow_hitch
