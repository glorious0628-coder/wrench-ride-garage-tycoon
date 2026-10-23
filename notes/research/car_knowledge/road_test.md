# 시운전 (Road Test / Test Drive)

> 기준 차: 가로배치 직렬 4기통 FF 중형 세단, 미국 왼쪽 운전석 (car_spec 기준).
> 출처는 각 줄 끝 [n] → 맨 아래 '출처'. 출처 없는 문장은 쓰지 않아요. **(확인)** = 페이지를 직접 열어 확인 · **(검색 요약)** = 검색 결과 요약만 봄(알파 전 재확인) · **(추정)** = 근거 없는 내 생각.
> 이 파일은 시운전이라는 '행동' 전체를 다뤄요. 증상별 부품 설명은 [02_brakes](02_brakes.md) · [03_wheels_tires](03_wheels_tires.md) · [06_suspension_steering](06_suspension_steering.md)에 있어서 여기선 **링크만** 걸고, 시운전에서 '어떻게 구별하는지'만 적어요.
> 많은 정비 사이트(Tire Review, Brake & Front End, Tomorrow's Technician)가 서버에서 403으로 막혀 본문을 못 열었어요 → 그 줄은 전부 (검색 요약).

## 한눈에 (3줄)
1. 시운전은 **고치기 전(손님 말대로 증상을 똑같이 만들어 보기)** 과 **고친 뒤(진짜 나았는지 확인)** 두 번 해요. 못 만들면 진단이 추측이 되고, 안 해 보고 내주면 재방문이 늘어요 [1][2][3][6][7](검색 요약).
2. 증상은 **언제 나는지**(속도·브레이크·턴·턱·가속·식었을 때)로 갈라요. 가장 큰 갈림길: "**브레이크 안 밟아도** 일정 속도에서 떨림 = 바퀴/타이어 쪽" vs "**밟을 때만** 떨림·페달 덜덜 = 브레이크 쪽" [15][16][17](검색 요약).
3. 게임엔 **60~90초 길(레일 주행 + 손가락 몇 번)** 로 넣어요. 운전 게임이 되지 않게 짧게, 핸들은 자동. 시운전에서만 잡히는 고장(CV 조인트 딸깍·휠 베어링 웅·속도 떨림·쏠림)이 핵심 재미예요.

---

## 1. 언제·누가·무슨 허락으로 시운전을 하나

### ① 언제
| 때 | 하는 말 | 출처 |
|---|---|---|
| **고치기 전** | 기술자가 소리를 직접 듣고 손님 불평을 확인("duplicate the complaint"). 소리·진동을 적어 두면 견적에도 도움 | [2](검색 요약) |
| 같은 단계 | 증상이 정비소 안에서 안 나오면 증상이 날 때까지 몰아 봐야 하고, 아니면 진단은 추측 | [7](검색 요약) |
| **못 만들 때** | 제조사 절차: 사양대로 달리면 **비슷한 다른 차를 타 보고** 손님 불평이 '원래 그런 것'인지 확인. 일부 제조사는 '재현 못 함(could not duplicate)' 처리에 시험 과정을 적으라고 함 | [4][5](검색 요약) |
| **고친 뒤** | 제조사 절차에 '인도 전 품질 확인 시운전 + 손님 만족 확인'이 있음. 증상이 사라지고 드라이브 사이클을 돌려야 수리가 끝 | [5][7](검색 요약) |
| 특히 | 브레이크·타이어·앞 하체(front end) 수리 뒤 | [1](확인) |
| 기록 | 수리 지시서에 시험한 방법을 적도록 권장 | [6](검색 요약) |

### ② 허락·보험·운전자 (못 찾은 건 못 찾았다고 적어요)
- **운전자**: 고객·회사 차를 몰 수 있는 사람의 **운전 기록(MVR)** 을 먼저 확인, 쓸 만한 기준을 **글로** 정해 두기, 시운전은 **승인된 운전자**(관리자·반장·오래된 직원)만, 기록은 매년 다시 보기, 수동 변속 등 어떤 차든 몰 수 있어야 함 [1](확인).
- **길 정하기**: 정해진 코스를 써서 차가 서도 위치를 알기 쉽게 / 우회전 많은 길 / 정지 표지판보다 신호등 교차로 / 혼잡·위험 교차로·공사·학교 앞은 피하기 / 운전자에게 전화기·무전기·사고 보고서 주기 / 시트·바닥 일회용 커버 / 비싼 차·클래식카는 더 조심 / 누가 봐도 위험한 차는 시운전 안 함 [1](확인).
- **보험**: 일반 사업 배상보험은 정비소가 맡은 남의 차를 빼 놓는 경우가 많고, 그 구멍을 **garagekeepers(맡은 차 보험)** 가 메워요. 시운전·사고는 보통 **garage liability(차고 배상)** 와 같이 묶여 있고, 직원이 업무로 모는 시험 운전도 약관에 따라 보장됨. 약관마다 달라서 **무면허·미성년 운전자 제외 조항, 시험용 번호판이 보장 차인지** 확인하라고 권함. 서명받은 면책 문서는 보험을 대신하지 못함. (대부분 보험 대리점 홍보 글 — 실제 약관이 아님) [8](검색 요약).
- **거리 제한 / 신분증 확인**: 정비소 보험의 표준 '몇 마일까지' 규칙은 **못 찾았어요**. 검색에 나온 20 mile은 Maserati의 시운전 **공임 지급** 기준이지 직원 운전 제한이 아님 [9](검색 요약). 면허 확인은 위 MVR 확인에 포함된 것으로 보임(추정).
- **손님 허락**: 수리 동의는 서면 또는 구두로 받고(주 규정에 따라 다름), 캘리포니아 BAR 자료는 견적에 서명이나 구두 승인, 분해 뒤 추가 진단·수리 전에 다시 승인을 요구 [10](검색 요약). **'시운전 동의 문구' 표준은 못 찾음.** 실무는 작업 지시서(work order) 약관에 넣는 것으로 보이나 확인 못 함(추정).
- **손님이 직접 몰기**: 손님이 운전해 증상을 재현하게 하면 정확하다는 강사 의견 vs 기술자 시간이 낭비된다는 반론이 둘 다 있음 [11](검색 요약).

### ③ 길이·시간
- 표준 시간은 **못 찾았어요**. 정비 글은 "여러 속도와 조건"으로 몰라고 하고 [24](확인) 길이는 말하지 않아요. 같은 코스를 고정해 쓰면 '정상 소리'를 배운다고 함 [25](검색 요약).

---

## 2. 전형적인 길 (한 판에 이런 걸 해 봐요)
| 구간 | 하는 일 | 보는 것 | 출처 |
|---|---|---|---|
| 정비소 주차장 | 느리고 **좁게 양쪽 돌기**, 8자 흔들기 | 앞바퀴 쪽 소리(CV), 베어링 하중 바뀔 때 소리 | [13][14][26](검색 요약) |
| 동네 골목 | 정지·출발, 속도 턱 | 덜컹·찍찍·덜그럭(하체) | [12][27](검색 요약) |
| 거친 길 | 오래된 하체 부품 소리가 잘 남 | 부싱·쇼바·볼조인트 | [27](검색 요약) |
| 평평하고 곧은 길 | 안전할 때 핸들을 살짝 느슨히 | 한쪽으로 쏠리는지 | [12][24](검색 요약·확인) |
| 한적한 길/주차장 | 정지-출발 테스트 | 브레이크 쏠림·헐거운 조향 | [12](검색 요약) |
| 브레이크 정지 | **25~40 mph** 에서 보통·세게 밟기 | 페달 덜덜, 쏠림, 끼익, 끌림 | [17](검색 요약) |
| 고속도로 램프/고속 | 가속·차선 바꾸기 | 망설임, 거친 변속, 진동, 경고등, 조향 반응 | [26][27](검색 요약) |
| 내내 | 오디오 끄고 바람·타이어·엔진 소리 듣기 | 일반 소음 | [26](검색 요약, 어느 글인지 불확실) |
- 같은 길을 고정하면 편함: 같은 속도 대에서 비교 [25](검색 요약). 어떤 한 길에서만 나는 소리는 **노면 탓**일 수 있으니 다른 종류의 길에서 확인 [25](검색 요약).
- 창문 닫기: 찾은 글에 **없음** → 쓰지 않아요.
- 정지 상태에서 재현해 보기: 문 닫기·부위 누르기·엔진 회전 올리기 [27](검색 요약).

---

## 3. 증상 → 원인 → 시운전으로 구별하는 법 → 게임 ID

> 게임 ID는 `docs/design/fault_catalog.md` 이름. 없는 건 **[새 ID 제안]**.

### 3-1. 브레이크 (자세한 부품 설명 → [02_brakes](02_brakes.md))
| 증상 | 원인 | 시운전에서 구별 | 게임 ID |
|---|---|---|---|
| **끼익(squeal)** | 패드 마모 경고판이 디스크에 닿음 / 또는 패드 공진 | 경고판 소리는 브레이크를 **안 밟을 때** 나서 구별(02_brakes [25]). 공진은 저속 제동 때 | PAD_WORN |
| **그르륵(grinding)** | 철판이 디스크를 긁음 | 밟을 때 쇠 긁는 소리. 오래 두면 디스크까지 | PAD_GONE |
| **페달이 덜덜 / 핸들 떨림(밟을 때만)** | 디스크 두께 차이·흔들림(runout) | **속도에 따라 반복되고 불러낼 수 있음**. 기계적 떨림은 속도 의존, ABS 떨림은 미끄러운 노면 의존 / 브레이크가 뜨거워질수록 커짐 [16][17](검색 요약) | BrakeDisc(ID 없음 → **DISC_PULSE** 제안) |
| **밟으면 한쪽으로 쏠림** | 캘리퍼 한쪽이 굳음·패드 오염 | 쏠림이 **밟을 때만** 나타나면 브레이크 쪽 [19](검색 요약) | PAD_UNEVEN |
| **밟지 않아도 계속 쏠림 + 끌림** | 캘리퍼가 안 풀림(drag) | 쏠림이 **항상**이면 브레이크가 끌리고 있을 수 있음. 끌린 뒤 식으면 쏠림이 원래대로 돌아오는 단서 [17][19](검색 요약) | PAD_UNEVEN 변주 **[새 ID: CALIPER_DRAG]** |
- 중요한 구별: 쏠림이 **언제나** 있으면 브레이크가 아닌 **타이어·얼라인먼트·부싱** 쪽 [17](검색 요약).

### 3-2. 쏠림 (pull) — 타이어 / 얼라인먼트 / 브레이크 (→ [03_wheels_tires](03_wheels_tires.md) · [06](06_suspension_steering.md))
| 원인 | 시운전 단서 | 출처 |
|---|---|---|
| **타이어 공기압 차이** (제일 먼저 볼 것: 2~3 psi 차이로도 60 mph에서 느껴진다는 글) | 곧은 길에서 일정하게 한쪽으로 | [19](검색 요약) |
| **타이어 마모 차이 / conicity(원뿔 모양 불량)** | 마모가 더 된 쪽으로, 공기압 같아도 쏠림 | [18][19](검색 요약) |
| **얼라인먼트** | 공기압·타이어가 정상이면 다음 의심. 안쪽 편마모 동반 | [18][19](검색 요약) |
| **브레이크 끌림** | 위 3-1 | [17][19](검색 요약) |
| 마모된 부싱·조향 부품 | 거친 길·세게 밟을 때 더 나빠짐 | [17](검색 요약) |
- 게임 ID: **TIRE_UNEVEN**("The car pulls to one side."). 다른 후보를 가르는 순서 = 공기압 → 타이어 → 브레이크 → 얼라인먼트(순서는 [19] 글 순서 그대로). 좌우 타이어를 바꿔서 쏠림이 따라가는지 보는 요령은 이번 검색에선 **출처 못 찾음**(추정) — 게임 힌트로 쓰지 않거나 (추정) 표시.

### 3-3. 속도에서 나는 떨림 (진동)
| 증상 | 원인 | 시운전 구별 | 게임 ID |
|---|---|---|---|
| **고속 핸들 떨림, 브레이크 안 밟아도** | 휠 밸런스 / 휜 림 / 헐거운 하체 | **50~70 mph** 에서 가장 잘 느껴짐(03_wheels_tires [23]). 브레이크 안 밟아도 있고 일정한 **떨림(shimmy)**, 펄스 아님 [15][16](검색 요약) | WHEEL_IMBALANCE |
| 밟을 때만 커지는 떨림 | 같은 불균형이 제동 하중에 드러남(제조사 절차 문서가 '불균형이 제동 때만 느껴질 수 있음'이라 함) | 밟기 전에도 약하게 있었는지 확인 / 하체 마모 부품도 같은 증상 [15](검색 요약) | WHEEL_IMBALANCE vs DISC_PULSE (**헷갈리는 짝**) |
| 빠르고 망치질 같은 펄스 = 디스크, 느리고 규칙적인 흔들림 = 불균형/베어링 | 한 블로그 의견(약한 출처) | 참고만 | — [16](검색 요약, 낮은 신뢰) |
| **드라이브샤프트 떨림**(뒷바퀴굴림 차) | 샤프트 불균형·U-조인트 | 바퀴/림/타이어가 멀쩡한데 떨리면 샤프트 의심. 속도에 비례하면 불균형, **가속·기어 변경 때 '쿵'** 이면 U-조인트(앞바퀴굴림은 안쪽 CV 조인트) [23](검색 요약) | (우리 기준 차는 FF라 **나중**) **[새 ID: DRIVESHAFT_VIB]** |
| 같은 rpm에서 나면 타이어 아님? | 포럼 의견 | **약한 출처**, 쓰지 않음 | — |

### 3-4. 하체 소리 (→ [06](06_suspension_steering.md))
| 증상 | 원인 | 시운전 구별 | 게임 ID |
|---|---|---|---|
| **턱 넘을 때 '쿵(clunk)'** | 스태빌 링크, 스트럿 마운트, 볼조인트, 부싱 | 속도 턱·거친 길에서 재현 [27](검색 요약). 확인은 **리프트에서 흔들기** (06 파일) | SWAYLINK_WORN |
| 쇼바 출렁 | 감쇠력 저하 | 시운전: 턱 뒤에 여러 번 출렁이면 의심(06 [34]) | Strut/Shock |
| 앞이 숙여짐·뒤가 주저앉음 | 쇼바 | 06 파일 | Strut/Shock |
| 한 가지씩 빼 보기: 링크를 떼고 다시 시운전 | 포럼 요령 | **약한 출처** — 게임에선 '정비사 요령' 말풍선만 | — [28](검색 요약) |

### 3-5. 조향 (→ [06](06_suspension_steering.md))
| 증상 | 원인 | 시운전 구별 | 게임 ID |
|---|---|---|---|
| **핸들 돌릴 때 '웅'(whine)** | 파워스티어링 액체 부족 → 펌프에 공기 | 돌릴 때 들림. 벨트는 '웅'보다 '끼익' [22](검색 요약). **참고: 우리 기준 차(Camry XV70 등)는 전동 조향(EPS)** — 유압 펌프 소리는 옛 차 [06 파일 EPS 부분] | **[새 ID: PS_LOW_FLUID]** — **옛 차 전용** |
| 핸들 늦게 돌아옴·삐걱 | 마운트 베어링 | 06 [35] | — |
| 헐렁·떠다님(wander) | 타이어/얼라인먼트/조향 부품 마모 | 06 파일 '쏠림·떠다님' 절. 이번 검색에선 wander 전용 출처 **못 찾음** | — |

### 3-6. 바퀴 쪽 소리: CV 조인트 vs 휠 베어링 (→ [06](06_suspension_steering.md))
| 증상 | 원인 | 시운전 구별 | 게임 ID |
|---|---|---|---|
| **급하게 돌 때 '딱딱딱' 딸깍** | 바깥 CV 조인트 마모, 보통 찢어진 고무 부츠(boot) → 기름 샘 → 흙 들어감 | **빈 곳에서 핸들을 끝까지 꺾고 천천히 가속**, 반대쪽도. **왼쪽으로 돌 때 나면 보통 왼쪽 바깥 CV**(항상은 아님) [13](검색 요약) | **[새 ID: CV_JOINT_WORN]** |
| **'웅~' 허밍, 속도 따라 커짐** | 휠 베어링 | 베어링·구동계 소리는 **일정**, 타이어 소리는 노면 따라 변함. 낮은 속도로 **좌우로 흔들며(weaving)** 베어링 하중을 바꿔 보기. 한쪽으로 돌 때 더 커지고 반대로 돌 때 작아지면 그쪽 베어링 의심 [13][14](검색 요약) | **[새 ID: WHEEL_BEARING_HUM]** |
| 둘 다 헷갈림 | 타이어 소리·CV·디퍼렌셜이 베어링 흉내 | **시운전 + 흔들기 + 눈**을 같이, 모르겠으면 타이어를 돌려 소리 위치가 바뀌는지 [13](검색 요약) | 헷갈리는 짝 |
| 달군 뒤 온도 | 불량 베어링이 더 뜨거움 | 적외선 온도계 [13](검색 요약) | (Lv 높음 도구 후보) |
- 구별 한 줄: **CV = 돌면서 가속할 때 '딸깍'(소리가 규칙적으로 빨라짐)**, **베어링 = 곧게 달려도 '웅' + 돌 때 변함**. (앞 절은 [13] 근거, '규칙적으로 빨라짐'은 (추정)).

### 3-7. 변속·엔진·그 밖의 시운전 증상
| 증상 | 원인 | 시운전 구별 | 게임 |
|---|---|---|---|
| 변속이 거칠다 / 미끄러짐 / rpm만 튐(flare) | 액체 부족·상태, 소프트웨어, 안쪽 마모 | 먼저 **액체 양·상태**(탄 냄새·찌꺼기), 제조사 서비스 공지, 적응값 초기화 순서 [20][21](검색 요약). 차가울 때만 나는 flare도 있음(밤새 두었다가 첫 두 번 변속에서만) [20] | 후속 부품(Transmission) — **[새 ID: TRANS_FLARE]** 알파 뒤 |
| 가속 때 망설임 + 엔진 경고등 **깜빡임** | 심한 실화(misfire) | 깜빡이는 등은 급한 실화, 촉매 손상 위험. 스캔으로 코드 확인 | SparkPlugs |
| 막히는 길에서 과열 / 에어컨 켜면 더 뜨거움 | 냉각 팬 | 팬이 첫 의심. 에어컨 켜짐과 관계 | RAD_FAN |
| 에어컨 소음 | 압축기 클러치·풀리 베어링 | 시운전에서 에어컨 켜고 끄며 소리 비교 | (후속 부품) |
(마지막 세 줄은 모두 포럼/Q&A 위주 — 약한 출처 [29][30](검색 요약).)

### 3-8. 경고등 켜짐
- 대시보드 등은 시운전 내내 보고, 깜빡임/계속 켜짐을 구분. 여기서 확인된 출처는 위 misfire 줄뿐. 나머지는 fault_catalog 해당 줄을 그대로 쓰기.

---

## 4. 우리 게임에 넣는 법 (제안 — 결정은 wr-design)

### ① 두 번 하는 시운전
- **고치기 전 (진단용)**: 손님이 "It shakes on the highway."라고 하면 **스캐너·눈으로 안 보이는 걸** 시운전으로 잡아요. 끝나면 **의심 후보 2~3개**가 좁혀지고 도감에 "Road Test Notes" 한 줄이 남음.
- **고친 뒤 (확인용)**: 같은 코스를 다시. **전엔 나던 소리·떨림이 사라지면 "Spot On!" 연출**, 안 사라지면 손님이 "Still doing it…" → 오진 피드백(벌 X, fault_catalog 규칙 3과 같음). 머플러 개스킷 빠뜨림 같은 **내 실수**도 여기서 잡힘(fault_catalog §1-5 이미 있음).

### ② 시운전에서만 잡히는 것 vs 눈/스캐너
| 시운전에서만(또는 가장 쉽게) | 눈·스캐너로 되는 것 |
|---|---|
| CV_JOINT_WORN(돌 때 딸깍) · WHEEL_BEARING_HUM · WHEEL_IMBALANCE(고속 떨림, 단 휠 밸런서로도 측정) · 쏠림(TIRE_UNEVEN/공기압/CALIPER_DRAG 가르기) · DISC_PULSE(밟을 때 페달) · SWAYLINK_WORN(턱 쿵, 리프트 흔들기로 확정) · RAD_FAN(막힐 때만) · TRANS_FLARE | BAT_*(전압) · TIRE_BALD/BULGE/FLAT(눈) · PAD_WORN 두께(바퀴 떼고) · MUF_HOLE(리프트) · RAD_LEAK(웅덩이·압력) · SparkPlugs 코드 P030x |
- 이 표는 **fault_catalog 진단 컬럼에 '시운전' 칸을 하나 더**해 주면 정리됨(아래 §6).

### ③ 1~2분 코스 아이디어 — 우리 마을 "Motor Avenue" 근처 (실제 이름 X, detroit.md §4·5 규칙)
> 길 이름은 가상(Motor Avenue, Six/Seven Mile 숫자 마일 길 — 이건 wr-design 판단 [detroit.md C]). 건물·기념물은 일반 모양.

| # | 장소 (게임 안 이름) | 길이 | 나오는 고장 |
|---|---|---|---|
| 1 | **정비소 마당 출구** (좁은 U턴) | 5초 | CV_JOINT_WORN 딸깍, WHEEL_BEARING_HUM이 돌 때 변함 |
| 2 | **골목 속도 턱 ×2** (Six Mile 가) | 10초 | SWAYLINK_WORN 쿵, MUF_HANGER·MUF_SHIELD 덜그럭 |
| 3 | **얼었다 녹은 자국 구간(bumpy patch, 봄 이벤트와 연결 [detroit O])** | 8초 | Strut/Shock 출렁, SWAYLINK |
| 4 | **정지 표지판 앞 브레이크** (한 번) | 8초 | PAD_WORN 끼익, PAD_GONE 그르륵, DISC_PULSE 페달 덜덜, PAD_UNEVEN 쏠림 |
| 5 | **'마을 첫 콘크리트 1마일' 기념 표지판이 있는 곧은 길** (detroit.md D) | 20초 | TIRE_UNEVEN 쏠림, WHEEL_IMBALANCE 핸들 떨림(속도 계기 '55' 근처), WHEEL_BEARING_HUM |
| 6 | **옛 신호등 탑 교차로** (detroit.md E) 빨간불 정지 | 8초 | SparkPlugs 엔진 덜덜, RAD_FAN 온도 올라감, 경고등 |
| 7 | **강가 부두 길을 돌아 정비소로** | 10초 | 에어컨·변속 같은 후속 고장 |
- 합 약 70초. 앞쪽은 **고장 하나**만 활성: 한 차량에 보통 1~2개 고장이 켜져 있어서(fault_catalog 규칙 5) **한 코스에서 소리 1~2개만** 나요.
- 구현 원리: 코스는 하나, **고장에 따라 '켜지는 효과'만 달라짐**. 코스를 늘리지 않아도 변주 수만큼 재미가 생김.

### ④ 짧게, 운전 게임으로 새지 않게
- **자동 주행(레일)**, 손님이 조수석(또는 NPC 직원 운전). 플레이어는 **조수석 시점에서 '이상한 곳 가리키기'** — 소리 나는 쪽을 탭, 떨림이 올라올 때 '느꼈어요' 버튼. 핸들·페달 조작 X.
- 손으로 하는 건 **세 번만**: ① 정지 표지판에서 브레이크 길게 누르기 ② 곧은 길에서 속도 슬라이더 55까지 ③ 신호등에서 멈춤 확인. 조작 2~3개면 충분.
- 로블록스 아이들은 운전을 좋아함(fun_boost #6) → **'자유 주행'은 Proving Grounds(v3, town_theme.md)** 로 미룸. 지금 코스는 **일 중간 휴식 같은 짧은 연출**.
- 레벨 5(fault_catalog 해금)에 맞추되, 첫 체험은 **튜토리얼 배터리 다음 일**처럼 1회 보여 주기(안 하면 경고 X).

### ⑤ 안전·가짜 소비자(fake-up consumers)
- 게임 안에서 **실제 운전 위험을 가르치는 장면은 X**: 사고·충돌 없음, 속도 위반 장면 없음, "안전한 길에서만 한다" 말풍선 1회.
- 실제 보험·허락 규칙(위 §1②)은 **교육 한 줄**로만: "Only approved drivers take customer cars out." 보험사·상표 이름은 쓰지 않음.
- 손님이 조수석에 타는 것은 허용(손님이 직접 몰기는 현실에서도 논쟁 [11]) → 게임에선 **손님이 '여기서 그래요' 하고 알려 주는 연출**로 즐겁게.

### ⑥ 새 손님 말 (영어 원문 — 증상만, 원인 X)
| ID | 말 (영어) | 한국어 |
|---|---|---|
| CV_JOINT_WORN | "It clicks when I turn into my driveway." | 집 앞길로 돌 때 딸깍해요. |
| WHEEL_BEARING_HUM | "There's a humming noise that gets louder the faster I go." | 빨리 달릴수록 웅 하는 소리가 커져요. |
| DISC_PULSE | "The brake pedal shakes when I stop from the highway." | 고속에서 멈출 때 브레이크 페달이 떨려요. |
| CALIPER_DRAG | "It pulls to the right all the time, and one wheel smells hot." | 계속 오른쪽으로 쏠리고 한쪽 바퀴에서 뜨거운 냄새가 나요. |
| TIRE_UNEVEN | (기존) "The car pulls to one side." | |
| WHEEL_IMBALANCE | (기존) "The steering wheel shakes on the highway." | |
| SWAYLINK_WORN | (기존) "There's a clunk when I go over bumps." | |
| PS_LOW_FLUID(옛 차) | "The steering whines when I turn the wheel." | 핸들을 돌리면 웅 소리가 나요. |
| TRANS_FLARE | "The engine revs but the car doesn't shift right at first." | 처음엔 엔진만 올라가고 변속이 이상해요. |
| DRIVESHAFT_VIB(RWD) | "I feel a shake at 60 and a clunk when I put it in drive." | 60에서 떨리고 드라이브에 넣으면 쿵 해요. |
- 규칙(fault_catalog 0): 손님 말은 증상만. '어느 바퀴'는 가끔 틀리게 말하게(Lv6+).

### ⑦ 새로 필요한 것
| 종류 | 항목 |
|---|---|
| 부품·도구 | 도구는 새로 없어도 시작 가능(시운전은 도구가 아니라 '행동'). 후속: 적외선 온도계(베어링), 흔들기 지렛대(06), 청진기(이미 Lv4) |
| UI | "Test Drive" 버튼(차 옆 키 아이콘), 코스 진행 막대, **소리 위치 탭**·**떨림 느낌 버튼**, 끝나면 "Road Test Notes" 카드 1장(최대 3줄). 화면 요소 최소(ui-keep-simple) |
| 소리 | 딸깍(CV), 웅(베어링), 쿵(턱), 끼익·그르륵(브레이크), 덜그럭(머플러), 엔진 덜덜, 팬 소리. **속도·핸들 각도에 따라 피치 변함**(베어링 '웅'이 커지는 방식) |
| 코스 | 길 하나 + 표지/소품 4~5개(속도 턱, 정지 표지판, 기념 표지판, 신호등 탑, 얼었다 녹은 자국) |
| 코드 | 코스 on-rails 이동, 구간 트리거에 고장 ID → 효과 연결, 시운전 결과 → 진단 후보 좁히기, 수리 후 전/후 비교 |

### ⑧ 공개 전 / 공개 뒤
| 시점 | 넣을 것 |
|---|---|
| **공개 전(10/31)** | **하지 않기를 권장(추정)**. 이유: 시험이 10/29이고 Work View(보닛·바퀴·차 밑)가 최우선이라 [memory]. 넣어도 **정말 최소**: 정지 표지판 브레이크 한 구간 + 곧은 길 1구간만(PAD_WORN·WHEEL_IMBALANCE·TIRE_UNEVEN 3개 확인). 품질이 안 되면 안 넣음 |
| 공개 뒤 첫 업데이트 | 전체 코스 + 고친 뒤 확인, CV·베어링·DISC_PULSE·CALIPER_DRAG 추가 |
| 그 뒤 | Proving Grounds 자유 주행(v3), 변속·에어컨, 구동축, State Inspection(flip_loop) 연결 |

### ⑨ 맡을 세션
| 세션 | 일 |
|---|---|
| **wr-dev** | 코스 on-rails, 고장↔구간 트리거, 전/후 비교, 결과 카드 |
| **wr-sound** | 증상 소리 10종(피치 변화 포함) — 소리 검수 흐름대로 |
| **wr-builder** | 코스(길·턱·표지·신호등 탑·자국 구간) |
| **wr-ui** | Test Drive 버튼·막대·탭 UI·노트 카드 |
| **wr-design** | 어떤 고장이 시운전 전용인지 표 확정, 손님 말, 공개 전/뒤 결정, 길 이름 |
| **wr-carbook** | 이 파일 검수, 약한 출처(변속·경고등) 확인 |

---

## 5. flip_loop State Inspection와 다른 점
- flip_loop.md는 State Inspection을 "시운전 + 안전 부품 점검"이라고 적었어요. **미시간 실제 절차**(검색 결과)는 면허 있는 **정비사가 '수리가 제대로 됐고 안전하다'고 서류(TR-13A 등)에 서명** + **검사관이 주요 부품 출처 서류를 확인**하는 쪽이고, 검색 결과에 **시운전은 안 나왔어요** [31](검색 요약). → 게임에서는 "시운전"을 남겨 두되, 도감에 "실제론 서류·부품 영수증 검사가 큼"이라고 한 줄. 그리고 용어: salvage → **'rebuilt' 인증 전 시운전은 게임 연출**(추정).

## 6. 다른 점 / fault_catalog에 더할 것
1. **§0 진단 방법 표**의 Test Drive 행(Lv5 '재미 보강안'): 아래 구분을 더해요 — **고치기 전(후보 좁히기)** / **고친 뒤(확인)**, '시운전 노트' 결과물.
2. **진단 컬럼에 '시운전' 칸 추가**: 각 고장 줄에 '시운전에서 어떻게 나타나는가'(소리/진동/쏠림, 속도·턴·브레이크·턱).
3. **새 ID 후보**: CV_JOINT_WORN · WHEEL_BEARING_HUM · DISC_PULSE(BrakeDisc 줄 이름 정리) · CALIPER_DRAG(PAD_UNEVEN 변주) · PS_LOW_FLUID(옛 차) · TRANS_FLARE · DRIVESHAFT_VIB(RWD 차). 부품/표는 06·02 파일의 부품 설명과 맞추기.
4. **WHEEL_IMBALANCE 시운전 단서**: "브레이크 안 밟아도 50~70 mph에서 일정한 떨림" — 지금은 '고속도로에서 핸들이 떨려요'뿐. **DISC_PULSE와 가르는 질문 말풍선**을 더하면 헷갈리는 짝이 됨.
5. **TIRE_UNEVEN '쏠림'은 한 증상=여러 원인**: 공기압(제일 먼저) / 타이어 / 얼라인먼트 / 브레이크 끌림. 03 파일 §196과 같이 대사를 둘로 나누기("안쪽이 닳았어요" vs "쏠려요").
6. **PAD_WORN '멈출 때 끼익' 대사**: 02_brakes 검수가 이미 "안 밟을 때도 끼익" 쪽을 권함 — 시운전 구별 질문에 활용.
7. **파워스티어링 whine**은 우리 기준 차(EPS)에선 안 맞음 → 옛 차(시대 차 era_cars)에만.
8. **보험·허락 규칙**은 게임 규칙(도감 한 줄)으로만. 실제 약관은 정비소·주마다 다르고 표준 거리 제한은 못 찾음.
9. 이번에 **못 찾은 것**: 표준 시운전 시간·마일 제한, 손님 동의 표준 문구, 창문 닫기 규칙, 타이어 서로 바꿔 쏠림 따라가기 요령. 게임에 쓰려면 wr-carbook이 다시 조사.

---

## 출처
1. Road testing a good plan, but protect your shop first — FenderBender — https://fenderbender.com/running-a-shop/operations/article/33024332/road-testing-a-good-plan-but-protect-your-shop-first (확인)
2. Road Testing For Customer Satisfaction, Safety — Shop Owner — https://www.shopownermag.com/?p=193862 (403, 검색 요약)
3. Every Repair Lives or Dies by Nine Critical Decisions — Motor — https://www.motor.com/2026/02/nine-step-diagnostic-repair-roadmap/ (검색 요약)
4. 제조사 서비스 공지(NHTSA 게시) — https://static.nhtsa.gov/odi/tsbs/2016/MC-10118908-9999.pdf (검색 요약)
5. 제조사 서비스 공지(NHTSA 게시, 인도 전 QC 시운전) — https://static.nhtsa.gov/odi/tsbs/2012/MC-10137454-9999.pdf , MC-10126192-9999.pdf (검색 요약)
6. NHTSA 문서 INRD-RQ26001 — https://static.nhtsa.gov/odi/inv/2026/INRD-RQ26001-11521P1.pdf (검색 요약)
7. 2.5 Diagnostic Strategy and Logical Sequencing — OpenExamPrep ASE L1 — https://open-exam-prep.com/study-guides/ase-l1/general-powertrain/diagnostic-strategy (검색 요약)
8. Garagekeepers / garage liability — Insurance Journal https://www.insurancejournal.com/magazines/mag-features/2014/02/10/319390.htm · Complete Markets https://completemarkets.com/Garagekeepers-Legal-Liability-Dealers-Open-Lot/Storefronts/ · Pioneer https://www.pioneerinsurance.com/business/garage-insurance (검색 요약, 대리점 글)
9. Mercedes-Benz 서비스 공지 시운전 기록/공임 — https://static.nhtsa.gov/odi/tsbs/2013/SB-10059810-2280.pdf , Maserati White Book road test — https://whitebookaftersales.maserati.com/americas/en-am/whitebook/warranty-management/submitting-a-warranty-claim/road-test.html (검색 요약)
10. Digital Dealer https://digitaldealer.com/?p=63362 · California BAR https://www.bar.ca.gov/pdf/workshops/202301-automotive-repair-transactions/presentation.pdf (검색 요약)
11. Auto Service World — https://www.autoserviceworld.com/?p=283804 (검색 요약)
12. Real World – Take Me Out! Test Drive Pointers For Technicians — Tomorrow's Technician — https://www.tomorrowstechnician.com/?p=650 (403, 검색 요약)
13. Diagnostic Solutions: Hubs/Bearings, CV Shafts & U-Joints — Tire Review — https://www.tirereview.com/diagnostic-solutions-hubs-bearings-cv-shafts-u-joints/ (403, 검색 요약)
14. Tech Tip: Diagnosing a Worn Wheel Hub Bearing — Brake & Front End — https://www.brakeandfrontend.com/tech-tip-diagnosing-a-worn-wheel-hub-bearing/ (검색 요약)
15. 제조사 서비스 공지 (불균형이 제동 때 두드러짐) — https://static.nhtsa.gov/odi/tsbs/2014/MC-10250966-9999.pdf , MC-10122192-9999.pdf (검색 요약)
16. Curing Brake Pulsation And Judder Complaints Starts With The Customer — Brake & Front End — https://www.brakeandfrontend.com/curing-brake-pulsation-judder-complaints-starts-customer/ (검색 요약)
17. SECTION 206-00: Brake System — General Information (Ford Mustang 2014 워크숍 매뉴얼) — https://www.reichwein.it/manuals/Mustang_2014/Workshop_Manual_Wiring_Diagrams/Resources/Service_Manual/seb60006.htm (검색 요약)
18. Symptom: pulling to one side — Michelin — https://www.michelin.ca/en/auto/learn/tire-damage/handling-problems/symptom-pulling-to-one-side (검색 요약)
19. Car Pulls to One Side: Causes and How to Fix It — Haynes — https://us.haynes.com/blogs/tips-tutorials/car-pulls-to-one-side-causes-and-how-to-fix-it (검색 요약)
20. Thinking it Through (harsh shift) — Gears Magazine — https://gearsmagazine.com/magazine/a-bump-in-the-road-diagnosing-a-harsh-shift-complaint/ (검색 요약)
21. ALLDATA case study: Ford Taurus transaxle slipping — Vehicle Service Pros — https://www.vehicleservicepros.com/training-and-resources/tech-tips/blog/21270209/alldata-corp-case-study-ford-taurus-automatic-transaxle-slipping (검색 요약)
22. Diagnosing Steering System Noises — Vehicle Service Pros — https://www.vehicleservicepros.com/industry-news/article/53089781/diagnosing-steering-system-noises-2017-08-04 (검색 요약)
23. Suspension Vibration and Noise Diagnosis — Brake & Front End — https://www.brakeandfrontend.com/?p=38849 (검색 요약)
24. Why Road Tests Matter — Auto Training Centre — https://www.autotrainingcentre.com/blog/road-tests-auto-mechanic-training/ (확인)
25. Vehicle Mechanical Diagnostic Techniques — Innova — https://www.innova.com/blogs/fix-advices/vehicle-mechanical-diagnostic-techniques (검색 요약)
26. Test Driving Car Checklist — KBB — https://kbb.com/car-advice/test-driving-car-checklist (검색 요약, '오디오 끄기·주차장 느린 턴'이 이 글인지 다른 구매자용 체크리스트인지 불확실; 구매자용 글임)
27. Diagnosing Undercar Noises During a Test Drive (영상 글) — Brake & Front End — https://www.brakeandfrontend.com/undercar-noise-test-drive/ (403) + Nationwide/AutoTrader 구매자용 시운전 글 (검색 요약)
28. s197forum / bobistheoilguy 포럼 스레드(앤드링크·스트럿 마운트 clunk) — 약한 출처 (검색 요약)
29. yourmechanic.com Q&A (misfire 깜빡임·과열·에어컨) — 약한 출처 (검색 요약)
30. 위와 같음
31. Mechanic inspections now required for rebuilt salvage vehicles — Michigan SOS — https://content.govdelivery.com/accounts/MISOS/bulletins/190867a · Public Act 369 of 2016 Repair Facility Bulletin — https://www.michigan.gov/documents/sos/Public_Act_369_of_2016_Repair_Facility_Bulletin_03022017_553473_7.pdf (검색 요약)
32. 내부: [02_brakes](02_brakes.md) · [03_wheels_tires](03_wheels_tires.md) · [06_suspension_steering](06_suspension_steering.md) · docs/design/fault_catalog.md · fun_boost.md #6 · flip_loop.md · garage_growth.md · town_theme.md · detroit.md §4–5
