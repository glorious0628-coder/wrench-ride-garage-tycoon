# 서스펜션·조향 (Suspension & Steering)

> 기준 차: 가로배치 직렬 4기통 앞바퀴굴림(FF) 중형 세단, 미국 왼쪽 운전석 (예: Toyota Camry XV70/XV80, Honda Accord 10·11세대, Hyundai Sonata DN8, Nissan Altima L34).
> 차 안 좌표·이름은 `docs/specs/car_spec.md` 기준(앞 = −Z, 운전석 = −X). 바퀴 중심 FL = (−3.25, 1.2, −5.0), 1 stud ≈ 280 mm.
> 출처는 각 줄 끝 [n] → 맨 아래 '출처' 목록. 출처 없는 문장은 쓰지 않아요.
> "(검색 요약)" = 페이지가 막혀 검색 결과 요약으로만 본 것. "(확인 못 함)" = 출처를 못 찾음. "(추론)" = 출처 둘을 이어 낸 결론.
> 얼라인먼트(캠버·토·캐스터)·편마모(컵 마모 포함) 기본은 [03_wheels_tires.md](03_wheels_tires.md) — 여기선 반복 안 해요.

## 한눈에 (3줄)
- 캠리 XV70 앞 = **맥퍼슨 스트럿**(쇼바+스프링 한 기둥, 위 너트 3 · 너클 볼트 2) + **아래 컨트롤암 1개씩** + 스태빌라이저; 뒤 = 스프링·쇼바가 **따로**인 **팔 3종(위 팔·아래 팔·트레일링 암)** 독립식 [1][2][14][12][13].
- 캠리 XV70 **전동 파워스티어링(EPS)은 '랙 형'**: 모터·감속기·토크센서·EPS 컴퓨터가 모두 **스티어링 랙 몸통 안에** 들어 있어요(기둥형 아님) [21][22].
- 스트럿·아래 팔·구동축을 떼면 **앞바퀴 얼라인먼트 + 'Reset Memory' + 가속도 센서 영점 보정**이 따라와요. 안 하면 VSC 꺼짐·슬립등·ABS등 [2][6][27].

---

## 부품: 앞 스트럿 뭉치 (Front strut assembly — "strut", "quick strut")
### ① 하는 일
- 맥퍼슨 스트럿 = **쇼바(댐퍼) 윗부분이 그대로 조향 축의 위 끝**이 되는 방식. 보통 **코일 스프링을 같이 품고**, 아래는 너클(바퀴 뭉치)에 붙어요 [28].
- 앞바퀴굴림 차 앞에 가장 흔하고, 엔진룸 폭을 덜 먹어 **가로배치 엔진**에 잘 맞아요 [28].
- 쇼바가 하는 일 = 출렁임을 잡아 타이어가 땅에 붙어 있게 함. 닳으면 타이어가 땅에서 뜨고 '출렁', 제동 때 앞이 숙이고(dive) 가속 때 뒤가 주저앉음(squat), 코너에서 차체가 기움 [34].

### ② 실제 모양·크기·재질·색 — 알아보게 할 특징 3개
- 위→아래 순서(캠리 분해도): 가운데 너트 → **위 지지대(front suspension support)** → **베어링(strut mounting bearing)** → 위 스프링 고무 받침 → **먼지 덮개(주름관) + 범프 고무(spring bumper)** → **코일 스프링** → 아래 스프링 고무 받침 → **쇼크 업소버 몸통**(맨 아래 너클 잡는 두 갈래 브래킷) [1][2].
- 옆에 **스태빌라이저 링크 자리**, **바퀴 속도센서 선·브레이크 호스 받침**이 붙어 있어요 [1][2].
- 쇼바 안엔 **가스**가 들어 있어서, 버릴 때 몸통에 구멍을 내 가스를 빼라고 매뉴얼에 적혀 있음(가스는 무색·무취·무독) [4].
- 실제 길이·무게·색 (확인 못 함 — 매뉴얼 그림에 치수 없음).
- 알아보게 할 특징 3개(캐주얼): ① **굵은 코일 스프링이 기둥을 감싼 모양** ② 위 끝 **둥근 모자(마운트)에 볼트 3개** ③ 아래 끝 **두 갈래 집게 + 큰 볼트 2개**.

### ③ 차 안 위치
- 위 = 엔진룸 양옆 **스트럿 탑(타워)** 에 너트 3개가 보임, 아래 = 앞바퀴 안쪽 너클 [1]. car_spec `Deco_EngineBay` '스트럿 타워 2(위 너트 3씩 보임)'와 맞음.
- 게임 좌표 감: 앞바퀴 중심 (∓3.25, 1.2, −5.0) 바로 안쪽·위로 서 있고, 위 끝은 엔진룸 옆벽 (추론, [1] 그림 + car_spec).

### ④ 붙어 있는 방식 (캠리 정비 매뉴얼 순서) [2]
1. 앞바퀴 떼기 → 와이퍼 아래 **카울 루버(cowl top ventilator louver)** 떼기.
2. **스태빌라이저 링크 너트** 풀어 떼기(볼조인트 부트 손상 X, 같이 돌면 **6 mm 육각**으로 잡기).
3. **속도센서·브레이크 호스**: 볼트 1 + 클램프 풀어 완전히 떼어 놓기.
4. (스프링까지 분해할 거면) 가운데 너트를 **풀기만** — 빼지 말 것.
5. 아래 팔을 **잭+나무토막**으로 받치고 → 너클 쪽 **볼트 2 + 너트 2**(볼트는 잡고 너트 돌림) → 너클은 **철사로 매달기**.
6. 위 **너트 3개** 풀고 뭉치를 빼냄.
- 조이는 힘: 위 너트 3개 **50 N·m**, 너클 볼트 2개 **290 N·m**, 스태빌 링크 74 N·m, 센서·호스 받침 29 N·m [1](도안 15).
- 다시 단 뒤: **앞바퀴 얼라인먼트**(Reset Memory + 가속도 센서 영점 보정), 차고가 바뀌면 후방카메라 축 설정 [2].

### 스프링 압축기 안전 (Spring compressor)
- 캠리 매뉴얼: 전용 공구(SST)의 **훅을 스프링 지름 양쪽에 걸고, 두 팔 평행·양쪽 감긴 수 같게**, 멈춤 핀 끼우기 → 압축 [2].
- **임팩트 렌치 금지**(공구 망가짐), **코일끼리 닿을 때까지 누르지 말 것**, 스프링 힘이 **완전히 빠진 걸 확인한 뒤에만** 가운데 너트를 뺌 [2].
- 공구 회사 설명서: 눌린 스프링은 **아주 큰 힘을 저장**(최대 약 1,500 kg 언급), 잘못 끼우면 **부품이 튀어나가 크게 다침**, 보안경·안전 체인, 손가락 끼임 주의 [39](검색 요약).

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| "배처럼 출렁여요", 제동 때 앞 숙임, 가속 때 뒤 주저앉음, 코너 기울기 [34] | 쇼바 감쇠력 저하(약 **5만 mi**부터 서서히 — 운전자는 잘 못 느낌) [34] | 시운전 [34] / 모서리 눌렀다 놓기(**2번 넘게** 출렁이면 의심, 단 주관적) [36](검색 요약) / 떼어서 로드를 **4번 이상** 누르고 빼기: 걸림·소리 없이 일정 속도로 돌아와야 정상 [3] | 교체. 시간: 2013~18 캠리 **좌우 한 쌍 약 2.5시간**, 교체 뒤 얼라인먼트 필요 [38](검색 요약) |
| 쇼바 몸통에 기름 젖음(먼지 엉김) | 실(seal) 새는 것 [36](검색 요약) | 눈: 로드가 몸통에 들어가는 자리 [36](검색 요약) | 교체 [3] |
| 턱에서 '쿵·덜컥'(bottoming) | 쇼바가 끝까지 내려앉음 [34] | 시운전 | 교체 |
| 타이어 **컵(물결) 마모** + 통통 소리 | 쇼바 마모 [34] | 타이어 보기 → [03 파일 ⑤](03_wheels_tires.md) | 쇼바 + 밸런스, 심하면 타이어 |
| 저속 핸들 돌릴 때 **삐걱·끄응**, 핸들이 늦게 돌아옴, 쏠림 | **마운트 베어링** 걸림 [35][37](검색 요약) | 차를 땅에 둔 채 핸들 끝→끝 돌리며 소리·걸림 듣기 [35] | 마운트·베어링 교체 — **스트럿 갈 때 같이 갈라고 권장** [35] |
| 턱에서 '퍽' 텅 빈 소리 | 마운트 고무 갈라짐 [37](검색 요약) | 들어 올린 상태에서 마운트 **좌우 흔들림** = 마모(아래로 살짝은 정상) [35] | 마운트 교체 |

### ⑥ 게임 손맛 아이디어 (제안만)
- **바운스 테스트**: 차 모서리를 꾹 눌렀다 놓으면 출렁임 횟수가 화면에 1·2·3… 숫자로 — 단 "주관적" 함정이라, **기름 자국(눈)** 과 짝으로 확정.
- **스프링 압축기 미니게임**: 양쪽 훅을 번갈아 조금씩(한쪽만 돌리면 기울어 경고음), 너무 누르면 코일이 닿아 빨간불. 너트는 '힘 빠짐' 표시 뒤에만 풀림.
- 끝나면 얼라인먼트 기계 + '영점 보정' 버튼 안 누르면 슬립 경고등(03 파일 아이디어와 연결).

---

## 부품: 아래 컨트롤암 + 부싱 (Lower control arm / "front lower No. 1 suspension arm", bushings)
### ① 하는 일
- 너클을 서브프레임에 이어 바퀴의 **앞뒤·좌우 자리를 잡아** 줘요 [28].
### ② 모양 — 특징 3개
- 서브프레임 양옆에 1개씩, **L자 삼각판** 모양(도안 17) [5]. 서브프레임 쪽 고무 **부싱**(bushing stopper 포함) [6].
- 특징 3개(캐주얼): ① **L자/삼각 철판** ② 안쪽 두 끝의 **둥근 고무 통(부싱)** ③ 바깥 끝의 **볼조인트 자리**.
### ③ 위치
- 앞 서브프레임 양옆, 엔진 아래 (`Deco_FrontSubframe` Y 0.5~1.3, Z −6~−4) [5].
### ④ 붙어 있는 방식 [6][7]
- 먼저 떼기: 바퀴 → 바퀴집 연장 패드 좌·우 → 엔진 아래 덮개 No.1·No.2 → 앞 바닥 덮개 → 펜더 에이프런 실.
- 볼조인트 쪽 **볼트 1 + 너트 2**, 서브프레임 쪽 **볼트 3 + 너트 1** — 너트에 멈춤쇠가 있어 **너트는 돌리지 말고 볼트를 돌림** [6].
- 조이는 힘: 서브프레임 볼트 **200 N·m**(설명서 그림 번호 순서대로) [7].
- 단 뒤: 앞바퀴 얼라인먼트 + Reset Memory + 가속도 센서 영점 보정 [6].
### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 · 시간 |
|---|---|---|---|
| 앞쪽 덜컥·떨림·쏠림 | 부싱·서스펜션 부품 마모 (뒤쪽 표에 'Suspension parts (worn)'가 쏠림·편마모 원인으로 올라 있음) [15] | 들어 올려 눈·지렛대 | 팔 교체(부싱 일체) [6] · 시간 (확인 못 함) |
### ⑥ 게임 손맛
- 너트는 고정, **볼트를 돌려야** 풀리는 '함정' — 너트를 돌리면 헛돎 표시.

---

## 부품: 아래 볼조인트 (Lower ball joint)
### ① 하는 일
- 공 모양 관절: 앞바퀴가 **조향(좌우로 돎)** 하면서 **위아래로도 움직이게** 해 줌. 아래 볼조인트는 제동·구동·코너 힘을 더 받아 **더 빨리 닳을 수 있음** [30].
### ② 모양 — 특징 3개
- 쇠 통 안에 **볼 스터드 + 소켓**, 스터드는 **원뿔(테이퍼)+나사**, 위에 **고무 부트**. 요즘 것은 대부분 **밀봉형(그리스 니플 없음)** [30].
- 캠리: 너클 아래에 붙은 별도 부품, 팔에는 **볼트 2 + 너트 1**(92 N·m), 코터핀 [11](도안 18).
- 특징 3개: ① **동그란 고무 부트(작은 우산)** ② 아래로 나온 **나사 기둥** ③ 납작한 **볼트 2구멍 받침**.
### ③ 위치: 앞바퀴 너클 맨 아래, 컨트롤암 바깥 끝 [11].
### ④ 점검·교체 [8][9]
- 차에서: 들어 올려 아래 팔을 손으로 **294 N(30 kgf) 이상** 위아래로 흔들어 **헐거움이 있으면 교체** — mm 한계값은 매뉴얼에 없음 [8].
- 떼어서: 바이스에 물리고 3~5초에 1바퀴씩 돌려 **5바퀴째 회전 토크 0.98~3.43 N·m** 벗어나면 교체 [9].
### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 |
|---|---|---|---|
| 핸들 돌릴 때 딸깍·뚝, 정차 끝에 삐걱, 턱에서 '퉁' [30] | 볼·소켓 마모 / 부트 찢어져 그리스 마름 [30] | 흔들기 294 N [8] / 부트 눈 | 교체 [8] |
| 핸들이 뻑뻑·끈적 [30] | 마른 볼조인트 [30] | — | 교체 |
| (위험) **바퀴 각도가 풀려 조종 불능** | 완전 파손 [30] | — | 즉시 견인·교체 |
- 무거운 핸들의 원인 목록에도 '앞 아래 볼조인트'가 3번째로 올라 있음 [25].
### ⑥ 게임 손맛
- **흔들기 게이지**: 지렛대로 30 kgf 이상 줬을 때 '덜그럭' 소리 = 불량. 방치하면 손님 차가 '바퀴 꺾임' 사고 이야기(겁주기 X, 경고 대사 정도).

---

## 부품: 스태빌라이저 바 + 엔드 링크 (Stabilizer / sway bar + end links)
### ① 하는 일: 좌우 바퀴를 이어 **코너에서 차체 기울기(롤)** 를 줄이는 **비틀림 스프링** [31].
### ② 모양 — 특징 3개
- 둥근 쇠막대를 **U자**로 굽힌 것, 가운데 긴 부분이 **고무 부싱 2개**로 차체(캠리는 서브프레임)에 붙고, 양끝이 **링크**로 서스펜션에 이어짐; 맥퍼슨이면 볼조인트로 이을 수 있음 [31][17].
- 캠리: 브래킷 좌·우 **볼트 2개씩**, 바 + 링크 2 + 브래킷 2 + 부싱 2가 한 덩어리로 빠짐 [17]. 링크 위 끝은 스트럿 몸통에 너트로(74 N·m) [1].
- 특징 3개: ① **긴 U자 막대** ② 막대를 감싼 **고무 반지 2개(부싱)** ③ 양끝의 **짧은 막대 + 공 관절(링크)**.
### ③ 위치: 서브프레임 위를 가로질러(도안 17), 양끝은 스트럿 몸통으로 올라감 [5][1].
### ④ 링크 점검 [10]: 바이스에 물려 5바퀴째 회전 토크 **0.05~1.96 N·m**, 걸림·유격 있으면 교체; **먼지 덮개 찢어짐·그리스 묻음**도 교체.
### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 |
|---|---|---|---|
| 저·중속 **작은 요철에서 덜그럭·딸깍**, 한쪽이 더 큼 | **엔드 링크** 볼조인트 마모 [37](검색 요약) | 손으로 링크 흔들기(단단해야 정상), 부트 찢어짐 [37](검색 요약) / 떼어서 회전 토크 [10] | 링크 교체 · 시간 (확인 못 함) |
| 코너에서 예전보다 많이 기움 | 링크·부싱 마모 [37](검색 요약) | 시운전 | 링크·부싱 |
| 앞 '쿵' 소리 | 스트럿 마운트보다 **엔드 링크인 경우가 많음** [37](검색 요약) | 링크부터 확인 | |
- 토요타 차는 볼조인트보다 **스태빌 링크 고장이 흔하다**는 정비사 포럼 의견이 있음(일화) [37](검색 요약).
### ⑥ 게임 손맛
- '덜그럭' 소리를 듣고 **링크 vs 볼조인트 vs 쇼바** 고르기 — 손으로 흔들어 봐서 링크만 '달각' 움직이면 정답.

---

## 부품: 뒤 서스펜션 (Rear suspension — Camry 독립식 vs 토션빔)
### 캠리 XV70 (2WD)
- 매뉴얼 뒤 서스펜션 목록: **코일 스프링 · 아래 팔(No.1·No.2) · 쇼크 업소버 · 스태빌라이저 · 서브프레임(rear suspension member) · 트레일링 암 · 위 팔(upper control arm)** [14][15].
- **스프링은 No.2 아래 팔 위에 따로** 얹혀 있음: 캠버·토 조정 캠에 **맞춤 표시** → 서브프레임 쪽 너트 풀기 → 팔을 **잭으로 받쳐** 액슬 캐리어 쪽 볼트·너트 빼기 → 팔을 천천히 내리고 스프링 빼기 [12].
- **쇼바는 따로**: 아래 바닥 덮개 → 쇼바 너트 풀기(캐리어 핀 잡고) → 스태빌 링크 → **볼트 2개**로 차체에서 분리 → 위 팔–캐리어 볼트·너트 → 캐리어에서 너트·와셔 [13]. 트렁크 안쪽 작업은 이 순서에 **없음** [13].
- 뒤 고장 순서표(토요타): **쏠림** = 타이어 → 뒤 얼라인먼트 → 허브 → 쇼바 → 스프링 → 서스 부품 / **바닥 닿음** = 과적 → 스프링 → 쇼바 / **출렁·흔들림** = 타이어 → 스프링 → 쇼바 → 스태빌 / **떨림(shimmy)** = 타이어·밸런스·얼라인먼트·위 팔·No.1·No.2 팔·트레일링 암·쇼바·허브 [15].
- 특징 3개(캐주얼): ① **스프링과 쇼바가 나란히 따로** 선 모양 ② 여러 갈래 **가는 팔**(위 1 + 아래 2 + 앞으로 뻗은 트레일링 암) ③ 팔 끝 **둥근 조정 캠(눈금 원판)**.

### 토션빔 (소형 FF 차)
- **H자 또는 C자** 큰 철 부재: 앞쪽은 고무 부싱으로 차체에, 뒤쪽에 바퀴 허브; 가운데 가로빔이 비틀리며 스태빌라이저 역할 [29].
- 소형·준중형 FF에 흔함(VW 폴로·골프 옛 세대, 르노 메간, 푸조 308, 기아 쏘울 등) [29].
- 싸고(멀티링크 대비 '차당 €100' 절약 언급), 가볍고, 부싱이 적어 튼튼; 대신 **캠버·토 조절이 공장 고정이라 보통 조정 불가** [29].
- → 우리 기준 중형 세단에는 car_spec 결론(멀티링크/더블위시본)이 맞음. 토션빔은 **소형차 손님** 변형에 쓰면 진짜 같음 (추론).

### ⑥ 게임 손맛
- 뒤 스프링 교체: **조정 캠 맞춤 표시 그리기 → 잭으로 팔 받치기 → 천천히 내리기** 3단계. 표시 안 하면 다음에 얼라인먼트 비용 추가.

---

## 부품: 스티어링 컬럼 + 중간축 (Steering column / intermediate shaft)
### ① 하는 일: 핸들 회전을 아래 랙의 **피니언 축**까지 전달. 컬럼은 큰 정면충돌 때 **접히게(collapsible)** 만들어 운전자 부상을 줄임 [32].
### ② 모양·구성 (캠리 부품명) [20]
- 스티어링 컬럼 뭉치, **컬럼 구멍 덮개**(방화벽 고무), **중간축(steering intermediate shaft)**, 스티어링 잠금 장치, 트랜스폰더 키 코일, 위 브래킷·클램프; 위쪽엔 핸들, **스파이럴 케이블**(에어백 선 감개) 달린 방향지시 스위치, 위·아래 컬럼 커버.
- 특징 3개: ① **핸들 뒤 굵은 원통(커버)** ② 아래로 비스듬히 내려가는 **가는 축 + 관절 마디** ③ 방화벽을 지나는 **고무 장화(구멍 덮개)**.
### ③ 위치: 운전석(−X) 계기판 아래 → 방화벽 → 엔진룸 아래 랙 (추론, [20][17]).
### ④ 분리: 랙 뗄 때 중간축은 **볼트 1개** 빼고 밀어 분리, 축과 랙에 **맞춤 표시** [17]. 핸들은 안전벨트로 묶어 **스파이럴 케이블 보호** [17].
### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 |
|---|---|---|---|
| 핸들 **유격 큼**(직진 상태 좌우로 살살) | 조향 계통 마모 | 엔진 켜고 직진 → 좌우 살살: **최대 30 mm** 넘으면 조향 점검 [19] | 원인 부품 교체 |
| 저속 핸들 돌릴 때 마찰 소리 | EPS 모터 / 컬럼 / 스파이럴 케이블 / 컬럼 커버가 핸들에 닿음 [25] | 순서대로 | |

---

## 부품: 스티어링 랙 + 전동 파워스티어링 (Rack-and-pinion gear with EPS — 캠리 XV70 = 랙 형)
### ① 하는 일
- 피니언(작은 톱니바퀴)이 돌면 랙(톱니 막대)이 **좌우로 미끄러져** 타이로드로 너클을 밀고 당김 [32].
- EPS: 센서가 핸들 **토크·위치**를 읽고 컴퓨터가 **전기 모터**로 힘을 보탬; 모터는 **기어(랙)나 컬럼 어느 쪽에도** 달 수 있음 [33]. 유압식처럼 벨트로 늘 도는 펌프가 없어 **연비에 유리**, 고장 나도 기계 연결은 남아 **손힘으로 조향 가능(무거움)** [33].
- **캠리 XV70 = 랙 어시스트**: "랙 앤 피니언 파워스티어링 기어 뭉치"에 **모터(회전각 센서 내장)·감속기(모터 힘을 랙 축으로)·토크센서·EPS 컴퓨터가 내장** [21][22]. 컴퓨터는 **토크 + 차속(스키드 컨트롤 ECU에서)** 으로 모터 전류를 계산 [21].
- 첫 양산 EPS = 1988 스즈키 세르보 [33].

### ② 모양 — 특징 3개
- 가로로 긴 통(랙) 양끝에 **주름 고무 부트 No.1·No.2**(클립은 재사용 X, 리튬 그리스) [16], 몸통에 **모터 덩어리 + 굵은 커넥터**, 열 차단판(heat insulator, 볼트 2) [17].
- 특징 3개: ① **가로 긴 원통 + 양끝 주름 부트** ② 한쪽에 불룩 붙은 **모터 혹** ③ 양끝에서 바깥으로 나가는 **타이로드**.

### ③ 위치: 앞 서브프레임 위(엔진 뒤 아래), 스태빌라이저와 같이 서브프레임에 얹힘 [5][16].

### ④ 붙어 있는 방식·떼는 순서 (캠리) [17]
- 주의: 커넥터 빼기 전 **이그니션 ON → 핸들 가운데 → OFF**; 핸들이 가운데가 아니면 ON 금지. 기어를 떨어뜨리거나 치지 말 것(모터·토크센서), 하네스 당기기 금지.
1. 앞바퀴 직진 → 핸들 안전벨트로 고정 → 바퀴·바퀴집 패드·엔진 아래 덮개.
2. 중간축 볼트 1 + 맞춤 표시 → 분리.
3. 타이로드 좌·우: **코터핀 + 너트** 빼고 전용 풀러로 너클에서 밀어냄.
4. **엔진+트랜스액슬을 내림**(이 차는 랙을 빼려면 엔진 내리기 절차가 들어 있음) → 열 차단판(볼트 2) → 하네스 커넥터(**잠금 먼저 풀고**) + 볼트 2.
5. 서브프레임 내림 → 스태빌 브래킷 볼트 2+2 → 랙 **볼트 4 + 너트 4**(너트 돌리지 말고 볼트를 돌림).
- 랙 프리로드(떼어서, 무부하): **1.5~3.05 N·m**, 벗어나면 기어 뭉치 교체 [18].
- 교체 뒤: **토크센서 영점 보정** + **어시스트 맵 쓰기**(Techstream: Chassis > EMPS > Utility). IG 전압 **8 V 이하면 보정 불가** → 배터리 먼저. 영점 보정 땐 바퀴 직진·핸들 가운데, 떨림 멈춘 뒤 **3초 이상** 핸들에 손대지 말기 [24].
- 시간 (확인 못 함).

### ⑤ 흔한 고장
| 증상 | 원인 (토요타 순서) | 진단 | 수리 |
|---|---|---|---|
| 핸들 **무거움** | 타이어 공기압·마모 → 얼라인먼트 → 아래 볼조인트 → 랙 → 토크센서 → 모터 → 컬럼 → 배터리·전원 → EPS 전원 → CAN → 정차 중 끝까지 반복 조향(과부하) [25] | 앞에서부터 하나씩 | |
| 좌우 핸들 힘이 다름 | **영점 보정 안 함**이 1순위 → 타이어 → 얼라인먼트 → 볼조인트 → 랙 [25] | DTC C1515/C1516 [21 목록] | 영점 보정 [24] |
| 속도 따라 힘이 안 바뀜 / 핸들이 잘 안 돌아옴 | 스키드 컨트롤 ECU·속도센서·토크센서·모터·EPS ECU·CAN [25] | 스캔툴 | |
| **EPS 경고등** | 노랑 = 보조 **제한**, 빨강 = 보조 **잃음** → 즉시 점검 [26]. 시동 ON 때 켜졌다 시동 걸리면 꺼지는 게 정상; IG 전원 이상·전압 저하로 켜짐(핸들 무거워질 수 있어서 경고) [23] | 스캔툴 DTC: 토크센서 C1511~C1555 무리, 차속 C1541, IG 전원 C1551, PIG 전원 C1552/C1554, ECM 통신 끊김 U0100 등 [21 하위 목록] | 원인별 |
| 정차 중 천천히 돌릴 때 **높은 삐익** | 모터 / 핸들 장착 잘못 [25] | | |

### ⑥ 게임 손맛 아이디어 (제안만)
- 랙 교체 퀘스트 끝에 **'핸들 가운데 → 영점 보정'** 미니게임(3초 손 떼기 타이머). 배터리 8 V 아래면 "Calibration failed — charge battery" 문구로 배터리 편과 연결.
- 경고등 **노랑 vs 빨강** 두 단계로 손님 위급도 표현.

---

## 부품: 타이로드 (안쪽·바깥쪽) + 랙 부트 (Inner / outer tie rods, rack boots)
### ① 하는 일: 랙의 좌우 움직임을 **너클 팔**로 전달 [32]. 앞바퀴 **토(toe) 조정**은 보통 타이로드 길이로 함 → [03 파일 얼라인먼트](03_wheels_tires.md) 참고 (XV70 규격값은 거기서도 확인 못 함).
### ② 모양: 캠리 매뉴얼 이름 = **TIE ROD ASSEMBLY LH/RH**, 바깥 끝에 **코터핀**(재사용 X) [16]; 랙에서 뺄 땐 **맞춤 표시 → 타이로드와 잠금 너트** 분리 [17].
- 특징 3개: ① 가는 쇠막대 ② 바깥 끝 **작은 볼조인트 + 고무 덮개** ③ 너트 구멍에 꽂힌 **철사 핀(코터핀)**.
### ④ 점검·토크
- 타이로드 볼조인트(떼어서): 5번 흔든 뒤 2~4초/바퀴로 5바퀴째 **0.49~3.43 N·m**, 덮개 갈라짐·그리스 묻음이면 교체 [18].
- 너클 쪽 너트 **49 N·m + 새 코터핀** [11](도안 18).
### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리 |
|---|---|---|---|
| 핸들 유격·덜컥, 바퀴 흔들림 | 타이로드 볼조인트 마모 [18][19] | 유격 30 mm 초과 [19] / 회전 토크 [18] | 교체 → **얼라인먼트(토) 필수** (추론: 길이를 바꾸면 토가 바뀜 [03 파일]) |
| 부트 찢어짐·그리스 | 부트 손상 [18] | 눈 | 타이로드 교체(캠리는 덮개 불량 = 뭉치 교체) [18] / 랙 부트 클립은 새것 [16] |
### ⑥ 게임 손맛
- 코터핀 안 꽂으면 '덜컥' 경고 → 체크리스트에서 빠뜨리면 손님 재방문.

---

## 부품 공통: 바퀴가 흔들림·쏠림·떠다님 (wandering / pull)
- 쏠림·떨림의 원인은 서스펜션만이 아니라 **타이어·밸런스·얼라인먼트가 먼저** (토요타 표 1~3순위) [15][25]. 브레이크·공기압 쏠림은 02·03 파일.
- '떠다님(wandering, 직진이 안 잡힘)'의 토요타 표 항목은 (확인 못 함) — 대신 핸들 유격 30 mm 규칙 [19], 스트럿 마운트 걸림 [35]이 근거로 쓸 만함.

---

## 내부 도안 근거 (정비 매뉴얼 그림·분해도 — 본 것과 '어디에 무엇이')
- 도안 15 (components-4002, C422047C01): 스트럿 위 **너트 3**(50 N·m) · 너클 **볼트 2 + 너트 2**(290 N·m) · 스태빌 링크(74 N·m) · 속도센서 선·브레이크 호스 받침(29 N·m) [1].
- 도안 16 (C400790C05): 스트럿 분해 위→아래 너트 → 위 지지대 → 베어링 → 위 고무 받침 → 먼지 덮개 + 범프 고무 → 코일 스프링 → 아래 고무 받침 → 쇼크 몸통 [1][2].
- 도안 17 (components-4013, C373260C01): 앞 서브프레임(사다리꼴 철 틀) 위에 **랙**·**스태빌라이저(브래킷 포함)**, 양옆 **아래 팔 LH/RH**, 앞·뒤 **엔진 마운트 고무(front/rear engine mounting insulator)**, 차체 장착 쿠션·스토퍼, 다이내믹 댐퍼, 배기관 받침 [5].
- 도안 18 (components-2923, C370391C01): 너클·허브 + 구동축 + **타이로드(코터핀)** + 아래 팔 + 속도센서 + 스태빌 링크 + 브레이크 호스 [11].
- 랙 부품도(components-3978): 랙 부트 No.1·No.2, 부트 클램프, **부트 클립(재사용 X)**, 리튬 비누 글리콜 그리스; A25A는 랙 위에 **연료 배관 가드(fuel delivery guard)** [16].
- 컬럼 부품도(components-3951): 컬럼 뭉치·구멍 덮개·중간축·잠금 장치·트랜스폰더 코일·브래킷 [20].
- EPS 부품 위치도(parts_location-3916): ① 랙 뭉치(ECU·모터·토크센서 내장) ② 스티어링 센서 ③ **엔진룸 릴레이 블록(EPS 퓨즈)** ④ **계기판 정션 블록(IG1 릴레이, EPS-IG1 퓨즈)** ⑤ 계기판 ⑥ 바디 ECU ⑦ 게이트웨이 ECU ⑧ DLC3 [22].
- 뒤 서스펜션: 코일 스프링 부품도(components-4020)는 '2WD / RH / LH' 3그림 + 바닥 덮개 No.1·No.2 [12]. 팔 배치 그림 자체는 이번에 못 읽음 (확인 못 함).

## car_spec · fault_catalog 와 다른 점
1. **뒤 `Strut_RL/RR`(쇼바+스프링 한 덩어리, 5볼트, '트렁크 열기')** → 캠리 XV70 뒤는 **스프링(No.2 아래 팔 위)과 쇼바가 따로**, 쇼바는 아래에서 **볼트 2(차체) + 캐리어 너트 1**, 트렁크 작업 없음 [12][13]. 제안: 뒤는 `Shock_RL/RR` + `Spring_RL/RR`로 나누거나, 최소한 '먼저 할 것'을 `Lift:Under` + 바퀴 떼기로.
2. **fault_catalog Strut "Clunk over bumps" 원인 = 쇼바 오일 샘** → 실제 '쿵·덜그럭'은 **스태빌 엔드 링크·스트럿 마운트·볼조인트**가 흔한 원인 [37][30][35]; 쇼바가 새면 주로 **출렁임·컵 마모·바닥 닿음** [34]. 제안: "Clunk"는 별도 고장 `SWAYLINK_WORN`(싸고 빠른 수리, 흔들기 진단)로, 쇼바는 "bounces like a boat"만.
3. **바운스 테스트 '2번 넘게 출렁이면 불량'**: 일반 정비 요령으로는 맞지만 **주관적**이라는 단서가 붙음 [36](검색 요약); 토요타 매뉴얼 자체 판정은 **떼어서 로드 4번 이상 눌렀다 빼기(걸림·소리·복귀 속도)** [3]. 진단 2단계(눈 기름 + 바운스)로 쓰는 게 진짜와 가까움.
4. **스트럿 교체 뒤 단계 없음** → 실제는 **얼라인먼트 + Reset Memory + 가속도 센서 영점 보정** 필수, 안 하면 VSC 꺼짐·슬립등·ABS등 [2][27]. 03 파일의 '영점 보정' 제안과 같은 버튼으로 묶으면 됨.
5. **스트럿 교체 = 스프링 압축기 필요**(스프링 재사용 시) — 게임엔 없음. 정비소에선 **완성형 스트럿(quick strut)** 으로 통째 바꾸는 방법도 흔함 — 이 용어의 출처 페이지는 (확인 못 함). 압축기는 위험 공구 [2][39] → 레벨 제한 장비 후보.
6. `Deco_FrontSubframe` 구성은 맞음(서브프레임·아래 팔 2·랙+타이로드 2·스태빌+링크·구동축 2) [5]. 더하면 진짜 같은 것: **랙 몸통의 EPS 모터 혹 + 커넥터**, **엔진 마운트 고무 2개(앞·뒤)가 서브프레임 위에** [5][22].
7. EPS가 **랙 형**이라 컬럼(실내)엔 모터가 없음 [21][22] → `Deco_Interior` 핸들 아래에 모터 혹을 그리면 틀림.

## 출처
1. Toyota Camry XV70 Repair Manual — Front Shock Absorber Components (도안 15·16, 토크는 그림 판독: diagrams/index.md) — https://www.tocamry.com/components-4002.html
2. Toyota Camry XV70 Repair Manual — Front Shock Absorber with Coil Spring Removal (+ 후속 절차 표) — https://www.tocamry.com/removal-4003.html
3. Toyota Camry XV70 Repair Manual — Front Shock Absorber Inspection — https://www.tocamry.com/inspection-4004.html
4. Toyota Camry XV70 Repair Manual — Front Shock Absorber Disposal — https://www.tocamry.com/disposal-4006.html
5. Toyota Camry XV70 Repair Manual — Front Suspension Member Components (도안 17) — https://www.tocamry.com/components-4013.html
6. Toyota Camry XV70 Repair Manual — Front Lower No. 1 Suspension Arm Removal — https://www.tocamry.com/removal-3999.html
7. Toyota Camry XV70 Repair Manual — Front Lower Suspension Arm Installation — https://www.tocamry.com/installation-4000.html
8. Toyota Camry XV70 Repair Manual — Front Lower Ball Joint On-vehicle Inspection — https://www.tocamry.com/on_vehicle_inspection-3993.html
9. Toyota Camry XV70 Repair Manual — Front Lower Ball Joint Inspection — https://www.tocamry.com/inspection-3995.html
10. Toyota Camry XV70 Repair Manual — Front Stabilizer Bar Inspection (link) — https://www.tocamry.com/inspection-4010.html
11. Toyota Camry XV70 Repair Manual — Front Drive Shaft / Axle Components (도안 18) — https://www.tocamry.com/components-2923.html
12. Toyota Camry XV70 Repair Manual — Rear Coil Spring Removal (+ components-4020) — https://www.tocamry.com/removal-4021.html
13. Toyota Camry XV70 Repair Manual — Rear Shock Absorber Removal — https://www.tocamry.com/removal-4029.html
14. Toyota Camry XV70 Repair Manual — Rear Suspension (목록: 스프링·아래 팔·쇼바·스태빌·서브프레임·트레일링 암·위 팔) — https://www.tocamry.com/rear_suspension-4018.html
15. Toyota Camry XV70 Repair Manual — Rear Suspension Problem Symptoms Table — https://www.tocamry.com/problem_symptoms_table-4052.html
16. Toyota Camry XV70 Repair Manual — Steering Gear Components — https://www.tocamry.com/components-3978.html
17. Toyota Camry XV70 Repair Manual — Steering Gear Removal — https://www.tocamry.com/removal-3979.html
18. Toyota Camry XV70 Repair Manual — Steering Gear Inspection (타이로드·프리로드) — https://www.tocamry.com/inspection-3981.html
19. Toyota Camry XV70 Repair Manual — Steering System On-vehicle Inspection (핸들 유격 30 mm) — https://www.tocamry.com/on_vehicle_inspection-3970.html
20. Toyota Camry XV70 Repair Manual — Steering Column Assembly Components — https://www.tocamry.com/components-3951.html
21. Toyota Camry XV70 Repair Manual — Power Steering System Description (+ DTC 하위 목록: power_steering_system-3914) — https://www.tocamry.com/system_description-3918.html
22. Toyota Camry XV70 Repair Manual — Power Steering Parts Location — https://www.tocamry.com/parts_location-3916.html
23. Toyota Camry XV70 Repair Manual — EPS Warning Light Circuit — https://www.tocamry.com/eps_warning_light_circuit-3940.html
24. Toyota Camry XV70 Repair Manual — Power Steering Calibration — https://www.tocamry.com/calibration-3920.html
25. Toyota Camry XV70 Repair Manual — Power Steering Problem Symptoms Table — https://www.tocamry.com/problem_symptoms_table-3921.html
26. Toyota Camry XV70 Owner's Manual — If a warning light turns on (EPS 노랑/빨강) — https://www.tocamry.com/if_a_warning_light_turns_on_or_a_warning_buzzer_sounds-2008.html
27. Toyota Camry XV70 Repair Manual — Front Wheel Alignment Adjustment (차고 152 mm, Reset Memory, 영점 보정; 뒤 adjustment-3989) — https://www.tocamry.com/adjustment-3987.html
28. Wikipedia — MacPherson strut — https://en.wikipedia.org/wiki/MacPherson_strut
29. Wikipedia — Twist-beam rear suspension — https://en.wikipedia.org/wiki/Twist-beam_rear_suspension
30. Wikipedia — Ball joint — https://en.wikipedia.org/wiki/Ball_joint
31. Wikipedia — Anti-roll bar — https://en.wikipedia.org/wiki/Anti-roll_bar
32. Wikipedia — Steering (rack and pinion, collapsible column) — https://en.wikipedia.org/wiki/Steering
33. Wikipedia — Power steering (EPS) — https://en.wikipedia.org/wiki/Power_steering
34. Know Your Parts — 4 Signs of Worn Shocks & Struts — https://www.knowyourparts.com/technical-resources/suspension/4-signs-worn-shocks-struts/
35. Monroe (Australia) — Strut Mounts Vital to Vehicle Safety — https://monroe.com.au/?p=1240
36. (검색 요약) 쇼바 진단·바운스 테스트 — Shock Warehouse / Blue Springs Ford Parts / KYB(403) — https://www.shockwarehouse.com/blogs/suspension-knowledge/diagnosing-worn-suspension-like-a-pro , https://www.bluespringsfordparts.com/blog/diagnose-failing-shocks-and-struts
37. (검색 요약) 스태빌 엔드 링크·스트럿 마운트 소리 — RepairPal / Go-Parts / ClubLexus 포럼 — https://repairpal.com/sway-bar-end-link , https://www.go-parts.com/garage/ps-2017-2023-honda-civic-suspension-strut-mount , https://clublexus.com/forums/suspension-and-brakes/664860-bad-sway-bar-end-links.html
38. (검색 요약) Go-Parts — 2013-2018 Toyota Camry Suspension Strut (2.5 hrs, 얼라인먼트 필요) — https://www.go-parts.com/garage/ps-2013-2018-toyota-camry-suspension-strut
39. (검색 요약) 스프링 압축기 안전 — Laser Tools 2779 / Sealey / OTC — https://www.lasertools.co.uk/items/PDF/Products/2779_Instructions.pdf , https://www.otctools.com/sites/default/files/565353_eng.pdf
