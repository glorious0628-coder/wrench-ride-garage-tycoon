# 브레이크 (Brakes)

> 기준 차: 가로배치 직렬 4기통 앞바퀴굴림(FF) 중형 세단, 미국 왼쪽 운전석 (예: Toyota Camry XV70/XV80, Honda Accord 10·11세대, Hyundai Sonata DN8, Nissan Altima L34).
> 차 안 좌표·이름은 `docs/specs/car_spec.md` 기준(앞 = −Z, 운전석 = −X).
> 출처는 각 줄 끝 [n] → 맨 아래 '출처' 목록. 출처 없는 문장은 쓰지 않아요.
> 숫자가 가장 단단한 차 = **Camry XV70**(Toyota 정비 매뉴얼 사본 tocamry.com + Toyota 서비스 공지 TSB). Accord 10세대 공식 숫자는 대부분 **(확인 못 함)** — 웹에 공개된 Honda 정비 매뉴얼을 못 찾음.
> "(검색 요약)" = 페이지가 403으로 막혀 검색 결과 요약으로만 본 것. "(추론)" = 출처 둘을 이어 붙여 낸 결론.

## 한눈에 (3줄)
- 앞은 **통풍 디스크(vented rotor) + 피스톤 1개짜리 미끄럼 캘리퍼(floating single-piston caliper)**, 뒤는 **막힌 디스크(solid rotor)** — Camry 4기통 기준 앞 305 mm / 뒤 281 mm [22][23].
- 패드 갈기(Toyota 매뉴얼): 바퀴 → **아래 슬라이드 볼트 1개만** 풀기 → 캘리퍼를 **위로 젖혀** 고정 → 패드 2장 빼기 → 심(shim)·마모 경고판 옮기기 → 피스톤 천천히 밀어 넣기 → 볼트 34.3 N·m [1][2].
- 뒤 캘리퍼에 전자 주차 브레이크(EPB)가 있으면 **'패드 교체 모드'를 먼저** 켜야 해요(안 켜고 밀면 캘리퍼 안 기어가 부서짐) [7][39].

---

## 부품: 브레이크 디스크 (Brake rotor / disc)
### ① 하는 일
- 바퀴와 같이 도는 쇠 원판. 패드가 양쪽에서 꽉 집으면 마찰로 차를 세워요 [25].

### ② 실제 모양·크기·재질·색 — 알아보게 할 특징 3개
- 재질: 회주철(gray cast iron) [25]. 오래 세워 두면 녹·오염으로 마찰이 고르지 않게 됨 [43].
- 앞 = 두 장 사이에 날개(vane)가 있는 **통풍형(vented)**, 무거운 앞에 흔함. 뒤 = 한 장짜리 **막힌형(solid)** [25].
- Camry XV70 4기통: 앞 **305 mm(12.01 in) 통풍**, 뒤 **281 mm(11.06 in) 막힌형**; V6·XSE·TRD 앞은 약 328 mm [22][23](판매처 목록, 공식 매뉴얼 숫자 아님).
- Camry 앞 디스크 두께: 새것 **28.0 mm**, 최소 **25.0 mm**(이하면 교체) [4].
- '296 mm'는 옛 Camry(V3, 2001~06) 16인치 바퀴용 앞 디스크로 검색됨 — XV70 값 아님 [23](검색 요약).
- Accord 10세대 앞 디스크: 트림·엔진 따라 **293 mm 또는 312 mm**로 판매처 목록이 서로 다름 [23](검색 요약, 확정 못 함).
- 최소 두께(MIN TH / discard)는 디스크 모자(hat)나 바깥 가장자리에 **찍혀(cast/stamped)** 있어요 [33].
- 알아보게 할 특징 3개(캐주얼): ① 가운데가 볼록 솟은 **모자(hat) + 바퀴 볼트 구멍 5개** ② 가장자리 옆면에 보이는 **통풍 날개 틈 줄무늬**(앞만) ③ 패드가 닿는 **반짝이는 띠(friction track)** vs 녹슨 모자 — 색 대비.

### ③ 차 안 위치
- 바퀴 안쪽, 허브(hub)에 끼워진 채 바퀴 볼트 사이에 끼어 있어요(슬립온 slip-on) [33].
- 디스크를 허브에 임시로 고정할 땐 바퀴 너트 5개로 103 N·m [4].

### ④ 붙어 있는 방식
- 디스크 자체 볼트는 없음(Camry: 캘리퍼 브래킷 떼면 빠짐) [21]. 안 빠지면 고무망치로 앞면을 돌아가며 톡톡 [21].
- Toyota 공지: 안 빠지면 디스크의 **나사 구멍에 볼트를 넣어 조여** 밀어내기, 녹은 녹 제거제 [18].
- 다시 끼울 때: 허브 면·디스크 모자 뒷면 녹/때를 철솔로 청소 [18][36]. 녹 0.025 mm만 있어도 가장자리 흔들림(runout)이 0.075~0.125 mm로 커짐 [36].

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 브레이크 밟으면 **페달·핸들이 덜덜**(pulsation) — 보통 "디스크 휨(warped rotor)"이라 부름 | 진짜로 휘는 일은 거의 없음. **흔들림(lateral runout) → 패드 찌꺼기가 고르지 않게 붙음 → 두께 차이(DTV)** [25][43][44] | 다이얼 게이지로 흔들림: Toyota(Sienna) 최대 **0.05 mm** [19], 보통 0.05~0.075 mm, 가장자리에서 약 1/2 in 안쪽 [33]. 마이크로미터로 8곳 두께 → 차이 0.013 mm 넘으면 떨림 [33] | 최소 두께 위면 깎기(on-car lathe 권장), 아래면 교체 [18][33]. **허브 위치 바꿔 끼우기(index/phase match)** — 각 볼트 자리마다 재서 가장 작은 자리 [19]. Toyota 공지 공임: 패드+심 양쪽 0.8 h [19] |
| 위 떨림이 **새 디스크인데도 금방** 다시 | 너트를 임팩트로 들쭉날쭉 조임(예: 80 vs 160 ft-lb) → 모자 휨 [36], 허브 녹 [36][43] | 너트 조임 순서·토크 확인 | 별 순서로 토크렌치, 임팩트 금지(Toyota 공지) [19][36] |
| 쇠 긁는 소리(grinding), 디스크에 동심원 홈 | 패드 다 닳아 철판이 긁음 | 눈: 홈 / 두께 25.0 mm 이하? [4] | 디스크+패드 교체(이 줄의 '원인'은 패드 항목 참고) |
- 두께 차이가 몇 mm면 느껴지는지 출처끼리 다름: 위키백과 ≈ 0.17 mm [25], 업계지 15 µm(0.015 mm)부터 불만 [43], ASE 교재 한도 0.013 mm [33] → **업계지·ASE 쪽이 정비 기준**.

### ⑥ 게임 손맛 아이디어 (제안만)
- 다이얼 게이지 미니게임: 디스크 한 바퀴 돌리며 바늘이 0.05 넘는 곳 찾기 → "허브 위치 바꾸기" 버튼으로 바늘 줄이기.
- 손님 "디스크 휘었대요" → 실제로는 **너트 임팩트 조임**이 범인인 추리 이야기.

---

## 부품: 브레이크 패드 (Brake pads)
### ① 하는 일
- 캘리퍼 안에서 디스크 양쪽(안쪽 inboard / 바깥 outboard)에 1장씩, 피스톤이 밀면 디스크를 집어요 [25][1].

### ② 실제 모양·크기·재질·색 — 알아보게 할 특징 3개
- 구조: **철판(backing plate)** + 붙인 **마찰재(friction material)**; 철판 귀(ears/tabs)가 브래킷 홈에 얹힘 [32].
- Camry 앞 패드 마찰재: 새것 **11.0 mm**, 최소 **1.0 mm** [4]. 뒤 패드 숫자 (확인 못 함).
- 마찰재 종류: 유기(NAO, 조용·부드러움), 세미메탈(금속 30~65%, 검은 가루·소음), **세라믹**(조용, 밝은 가루, 요즘 승용차 대부분) [32].
- 심(anti-squeal shim): Camry는 패드마다 **No.1·No.2 심** 2장 + **마모 경고판(wear indicator plate)** [1][2].
- 마모 경고판(squealer): 철판에 붙은 스프링강 탭, 마찰재 약 **1.5 mm(2/32 in)** 남으면 디스크에 닿아 높은 소리 [32]. Camry 앞은 경고판을 **위쪽(upper side)** 으로, 뒤는 **아래쪽(lower side)** 으로 끼움 [2][6].
- 교체 기준: 매뉴얼 최소 1.0 mm [4], 정비소들이 흔히 쓰는 기준은 약 **3 mm(4/32 in)** [47](검색 요약, 낮은 품질 출처들의 공통 숫자), Camry 가이드도 3 mm [22].
- 알아보게 할 특징 3개(캐주얼): ① 두꺼운 **검은/회색 마찰 덩어리 + 얇은 은색 철판** 두 층 ② 철판 양끝 **귀(ears)** 튀어나옴 ③ 위 모서리의 작은 **휘어진 경고 탭**.

### ③ 차 안 위치
- 캘리퍼 브래킷(Toyota: caliper mounting) 안, 디스크 양면 [1].

### ④ 붙어 있는 방식 (Camry XV70 앞, Toyota 매뉴얼)
1. 바퀴 떼기 [1].
2. **아래 슬라이드 핀을 잡고 그 볼트 1개만** 풀기 → 캘리퍼(Toyota 이름 front disc brake cylinder assembly)를 **위로 들어** 떨어지지 않게 고정, 브레이크 호스 꺾지 않기 [1]. (wr-carbook가 본 부품도: 위쪽 핀을 축으로 젖힘 [3], diagrams/05)
3. 브래킷에서 패드 2장 빼기 → No.1·No.2 심 떼기 → 경고판은 드라이버로 떼기 [1].
4. 설치: No.1 심 양면에 심 그리스(08887-80409), 마찰면엔 기름 금지 [2].
5. 피스톤 **천천히** 밀어 넣기, 억지로 X, 리저버 넘침 주의 [2]. (TSB 힌트: 넘칠 것 같으면 리저버에서 조금 빼기 [18])
6. 패드 2장 → 캘리퍼 내리고 아래 핀 잡고 볼트 **34.3 N·m(약 25 ft·lbf)** [2][3].
7. 페달 여러 번 밟아 단단해질 때까지 → 안전한 곳에서 시운전 [2].
- 볼트·공구(DIY 사진 가이드): 슬라이드 볼트 **14 mm** 소켓, 핀이 같이 돌면 핀 평면을 **17 mm** 스패너로 잡기; 브래킷 볼트 **17 mm** 2개(디스크 갈 때만); 블리더 8 mm [20][21].
- DIY 가이드 둘은 **볼트 2개를 다 풀고 캘리퍼를 빼서** 끈으로 스프링에 매달거나 디스크 위에 올림 — 매뉴얼(1개 풀고 젖힘)과 방법이 다름 [20][21].
- 토크: 슬라이드 볼트 34 N·m(25 ft-lb), 브래킷 볼트 107 N·m(79 ft-lb) [3][18][20][21]; 브레이크 호스 유니언 볼트 29.4 N·m + 재사용 불가 개스킷 [3].
- 같이 가는 작은 부품: 패드 지지판(pad support plate = abutment clip) 4개 [3]. 업계지들은 클립을 **매번 새것**으로(열로 스프링 힘 약해짐) [32][50](검색 요약).
- **그리스 위치는 출처끼리 다름**: 2013 Toyota 공지(Corolla) = 지지판에 그리스 **금지** [18] / 2022 Toyota 공지(Camry) = 키트의 Wako 그리스를 **클립 지정 부위에만 0.0075 g** [16] / DIY = 클립 닿는 곳에 얇게 [20]. → 차·연식별 지시를 따름.
- Accord 10세대: 슬라이드 볼트·브래킷 볼트 크기·토크 **(확인 못 함)**. 옛 Accord(2010~11) 표: 앞 브래킷 108 N·m, 앞 캘리퍼 볼트 34 N·m(Akebono) [46](검색 요약).

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 높은 **끼익(squeal)** 소리 (2,000~15,000 Hz) | 패드·디스크 공진(stick-slip) — 성능엔 보통 지장 없음 [25][35] | 저속에서 더 잘 남, 청진기(ChassisEar)로 위치 [16] | 심 새것·댐핑 페이스트(철판 금속 접점만), 길들이기 [35]. Camry 2018~22 공지: 바깥쪽 클립 키트 교체 **양쪽 0.7 h** / 캘리퍼 교체 1.1 h(+반대쪽 0.2 h) [16][17] |
| 브레이크 안 밟을 때도 나는 끼익 | **마모 경고판**이 디스크에 닿음 — 위키백과: 경고판 소리는 브레이크를 안 밟을 때 나서 구별됨 [25] | 바퀴 떼고 마찰재 두께 재기(최소 1.0 mm) [4] | 패드 교체(한 축 양쪽), Corolla 공지 공임 0.8 h [18] |
| 쇠 긁는 **그르륵(grinding)** | 마찰재 다 닳아 철판이 디스크를 긁음 (ASE 노이즈 페이지엔 따로 없음 [35]) | 눈: 철판 노출, 디스크 홈 | 패드+디스크 |
| 덜컥(clunk) 전진↔후진 바꿀 때 / 가볍게 밟을 때 웅(groan) | 지친 클립(anti-rattle) 때문에 패드가 놀음 [35] | 패드 손으로 흔들기 | 클립 매번 교체 [35] |
| 바깥 패드만 빨리 닳음 | **슬라이드 핀이 뻑뻑**(녹·마른 그리스·찢어진 부트) [31] | 핀 빼서 손으로 밀어 보기 | 핀 청소+**실리콘/합성 폴리글리콜 그리스**(석유계 금지, 부트 부풂) [31]; Toyota는 리튬비누 글리콜 그리스 [18] |
- 패드 길들이기(bedding): 40→10 mph 중간 제동 5~8번(30초 간격) → 50→10 mph 세게 3~4번 → 5분 식히기, 뜨거울 때 완전히 서 있지 않기 [35]. (Camry 가이드: 40→10 mph 8~10번 [22] — 숫자 조금 다름)
- 비용: RepairPal 2023 Camry 패드 교체 **$305~392**(공임 따로 표시 없음) [48](검색 요약). DIY 앞 패드+디스크 2~3시간 [21].

### ⑥ 게임 손맛 아이디어 (제안만)
- 패드 두께를 **자(캘리퍼스)로 재는** 클릭: 11 → 1 mm 눈금, 3 mm 아래면 빨강.
- 심 2장 + 경고판을 새 패드로 **옮겨 끼우기**(빼먹으면 끼익 재발 손님).

---

## 부품: 캘리퍼 (Brake caliper — floating, single piston)
### ① 하는 일
- 기름 압력을 받아 피스톤 1개가 안쪽 패드를 밀고, 몸통이 미끄러져 바깥 패드를 당겨요(미끄럼/떠 있는 floating 캘리퍼) [25].

### ② 실제 모양·크기·재질·색 — 알아보게 할 특징 3개
- Camry 앞 = 피스톤 1개(single piston), 피스톤 실(seal), 실린더 부트, 블리더 플러그+캡; 위·아래 슬라이드 핀 + 부싱·부트 [3]. 일부 트림엔 **2-pot(피스톤 2개)** 캘리퍼가 따로 있음 [1][16].
- 피스톤 실(사각 단면)이 놓을 때 피스톤을 0.005~0.010 in 되돌림 [31]. 피스톤 = 크롬 도금 강(부트 찢어지면 녹) 또는 페놀 수지 [31].
- 알아보게 할 특징 3개(캐주얼): ① 디스크 가장자리를 **집게처럼 감싸는 덩어리** ② 뒤쪽에 **둥근 피스톤 컵** + 꼭대기 근처 **블리더 꼭지(8 mm)** [20] ③ 위·아래 **고무 주름 부트 두 개**(슬라이드 핀).

### ③ 차 안 위치
- 가로배치 FF 차는 조향 랙(steering rack)이 바퀴 중심 **뒤**에 있어서 캘리퍼는 바퀴 중심 **앞쪽**에 다는 게 보통, 시계 **3시/9시 자리**가 가장 흔함 [45](일반론). 공학 포럼 요약도 같은 이유 [45 함께 본 검색](검색 요약).
- Camry 가이드: "오른쪽 캘리퍼 작업 땐 핸들을 오른쪽으로" [21] → 오른쪽 바퀴 **앞쪽**이 바깥으로 나옴 = 캘리퍼가 앞쪽(추론).
- Camry 사진 가이드: 볼트 머리는 엔진룸 쪽(안쪽)을 봄, 블리더는 위쪽 볼트 바로 아래 [20].
- **XV70 매뉴얼 그림 확인(wr-carbook, diagrams/18)**: 앞 바퀴 뭉치 그림에서 캘리퍼는 디스크 중심과 **거의 같은 높이(약 3/9시)**, **타이로드 끝(조향 팔)의 반대쪽**에 그려져 있어요. 조향 랙이 바퀴 축 뒤에 있으니(타이로드 = 뒤쪽) 캘리퍼 = **바퀴 중심 앞쪽(−Z), 높이는 중심과 비슷** (그림 + 위 일반론으로 낸 결론, 사진 실측은 아님) — https://www.tocamry.com/components-2923.html

### ④ 붙어 있는 방식
- 캘리퍼 몸통 ↔ 브래킷: 슬라이드 볼트 2개(14 mm, 34.3 N·m) [3][20]. 브래킷 ↔ 너클: 볼트 2개(17 mm, 107 N·m) [3][20].
- 호스: 유니언(banjo) 볼트 29.4 N·m + 새 개스킷 [3]; ASE: 동 와셔 양쪽 매번 새것 [31].
- 피스톤 밀기: C클램프/F클램프에 **헌 패드를 대고**(페놀 피스톤 가운데 직접 누르면 깨짐) [21][31].

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 브레이크 밟으면 **한쪽으로 쏠림(pull)** | **반대쪽** 피스톤이 굳음(일하는 쪽으로 쏠림), 패드 기름 오염, 호스 눌림 [34] | 양쪽 패드 두께 비교, 바퀴 손으로 돌리기 | 캘리퍼 교체(한 축 양쪽 권장 [16]) |
| 끌림(drag), **바퀴 뜨거움·타는 냄새**, 연비 나빠짐 | 굳은 피스톤·녹슨 핀·귀 낀 패드(기계), 속이 갈라진 호스·마스터 구멍 막힘·ABS 밸브(유압) [34] | **블리더를 열며 바퀴 돌리기**: 풀리면 유압 원인, 그대로면 기계 원인 [34] | 해당 부품 교체 |
| 블리더·피스톤 부트 주변 젖음 | 실 누유 | 눈 | 오버홀(실 교체) 또는 교체, 깊은 녹·홈이면 교체 [31] |
- 비용: Accord 캘리퍼 교체 평균 $326(부품 $74 + 공임 $252) [49 함께 검색](검색 요약).

### ⑥ 게임 손맛 아이디어
- "블리더 열고 바퀴 돌려 보기" 진단 클릭 1번으로 **유압 vs 기계** 갈래 추리.

---

## 부품: 뒤 브레이크 + 주차 브레이크 (Rear brakes & parking brake: cable / drum-in-hat / EPB)
### ① 하는 일
- 뒤 디스크는 앞보다 작은 힘 담당, 주차 브레이크는 서 있을 때 뒤바퀴를 잠금 [26].

### ② 실제 모양·종류
- Camry XV70은 정비 매뉴얼이 **EPB 있는 차 / 없는 차** 두 갈래 [10](목록 페이지).
- EPB 없는 Camry: 뒤 디스크 모자 안에 **작은 드럼 슈(drum-in-hat)**, 발 페달+케이블 [22][15]. 뒤 허브 떼기 순서에 '주차 브레이크 슈 조정 구멍 마개(adjusting hole plug)'가 있음 [15](검색 요약).
- EPB 있는 Camry: 왼·오른쪽 **EPB 액추에이터(뒤 캘리퍼에 붙은 모터)** + 배선(No.2 parking brake wire) + O링 [8][9].
- 어느 트림에 EPB? → 2018 Camry **XLE·XSE·하이브리드** = EPB, SE는 발 페달 [24](검색 요약). Core 가이드는 "발 페달 drum-in-hat, EPB 아님"이라고만 써서 **트림 구분이 빠져 있음** [22].
- Accord 2018: EPB 서비스 모드 영상 대상 차종에 포함 [51] — 전 트림 표준인지 (확인 못 함).
- EPB 방식 두 가지: 캘리퍼마다 모터(지금 업계 표준) / 가운데 모터가 케이블 당김 [39].

### ③ 차 안 위치
- 뒤 캘리퍼도 슬라이드 볼트 1개 풀고 **위로 들어 올림**(Camry, EPB 차) [5].

### ④ 붙어 있는 방식·순서 (Camry XV70 뒤, EPB 차)
1. 바퀴 떼기 → **패드 교체 모드(rear brake pad replacement mode)** → EPB 배선 커넥터 빼기 [5].
   - Techstream: 주차 브레이크 풀린 상태, 페달 안 밟고 IG ON → Chassis > Brake > Utility > **EPB Full Release** → 표시등이 **1초 간격으로 느리게 깜빡**이면 완료 [7].
   - Techstream 없이: IG OFF→ON 후 **8초 안에 스위치를 잠금 쪽 3번, 풀림 쪽 3번** → 표시등 0.25초 간격 빠른 깜빡 → 풀림 쪽 5초 이상 → 느린 깜빡(1초)이면 모드 [7].
   - 작업 중 스위치·변속 레버 만지지 말 것(피스톤이 빠질 수 있음) [7].
   - 끝나면: IG ON, 스위치를 잠금 쪽으로 **5초 이상** [7]. C060E2A·C06132A·C13B800 남으면 지우기 [7].
2. No.1 슬라이드 핀 잡고 볼트 풀기 → 캘리퍼 위로 → 패드 2장, 안쪽 No.1·No.2 심 + 바깥 심 + 경고판 [5].
3. 설치: 심 안쪽 면에 그리스, **새 경고판**, 피스톤 천천히, 경고판은 **아래쪽**, **새 볼트**로 34.3 [6].
- 모드 없이 피스톤을 억지로 밀면 안 기어(유성기어)가 부서지거나 축이 끊김; 피스톤은 **돌리지 말고 곧게** 밀기(모터-온-캘리퍼형) [39].
- 모드 끝나면 모터가 패드가 닿을 때까지 나와서 새 패드 두께를 배움(전류 15~20 A 튀는 것으로 감지) [39].
- EPB 없는 Camry 뒤 피스톤 밀기: 주차가 드럼-인-햇이라 캘리퍼에 나사식 주차 장치가 없으니 곧게 밀면 됨 **(추론)**. 나사식(screw-in) 피스톤 차의 자세한 방법은 (확인 못 함).

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 노란 EPB/브레이크 경고등, 주차 안 걸림 | EPB 액추에이터 회로 단선·단락 | DTC **C060B13**(왼 단선), C061013(오른 단선), C060B12/C061012(배터리 단락), C060962(스위치 신호) [8] | 커넥터·액추에이터 점검/교체 |
| 주차 브레이크가 약함(EPB 없는 차) | 드럼-인-햇 슈 마모·조정 풀림 (확인 못 함: XV70 조정값) | 조정 구멍으로 슈 조정 [15] | 슈 교체/조정 |

### ⑥ 게임 손맛 아이디어
- 스위치 **↑↑↑ ↓↓↓ 8초 안에** 리듬 입력 → 표시등 깜빡 속도로 성공 확인(진짜 순서 그대로).
- 모드 안 켜고 피스톤 밀면 "뚝!" 소리 + 캘리퍼 박살(벌점 대신 비싼 교훈 1번).

---

## 부품: 드럼 브레이크 (Drum brake — 옛 차·작은 차 뒤)
### ① 하는 일
- 바퀴와 같이 도는 통(drum) 안쪽을 **슈(shoe)** 가 밖으로 밀어 세움. 뒤는 열이 적고 주차 브레이크 넣기 쉬워 뒤에 많이 씀 [26]. 기준 차(Camry XV70)는 뒤도 디스크라 드럼은 **주차용 drum-in-hat**으로만 있음 [22][26].

### ② 모양·부품
- 받침판(backing plate), 드럼, 슈 2개(앞쪽 = leading/primary, 뒤쪽 = trailing/secondary), 휠 실린더, 리턴 스프링, 홀드다운 스프링, 자동 조정기(star wheel·lever·cable), 주차 레버 [26][42].
- 슈 라이닝 최소 **2.0 mm(약 3/32 in)** [42]. 드럼 바깥에 최대 지름이 찍힘(예: "Max Dia 9.090 in") [42].
- 알아보게 할 특징 3개(캐주얼): ① 바퀴 안쪽 **뚜껑 같은 통** ② 안에 **초승달 슈 2장 + 꼬불 스프링** ③ 위쪽 가운데 **작은 원통(휠 실린더)**.

### ④ 순서
- 스프링·케이블·조정기 떼기 → 받침판 '턱'(슈당 3곳, 총 6곳) 철솔 청소 + 고온 그리스 얇게 → 조정기 나사 그리스 → 조립 → 드럼이 **살짝 고르게 끌리며** 들어가게 스타휠 조정(brake spoon) [42].
- 자동 조정기는 보통 **후진하며 브레이크 밟을 때** 1톱니씩 돌아감 [26][42].

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 |
|---|---|---|---|
| 페달 물렁, 드럼 안쪽·받침판 젖음 | 휠 실린더 컵 실 누유 [42] | 먼지 부트 젖힘: 얇은 습기는 정상, **방울 뚝뚝**이면 불량 [42] | 실린더 교체 + **슈도 교체**(기름 먹은 슈는 못 씀) [42] |
| 페달이 낮음 | 자동 조정기 고착(녹), 케이블 늘어남 [42][34] | 스타휠 손으로 돌려 보기 | 조정기 교체 |
| 끌림·뜨거운 드럼 | 리턴 스프링 약함 [42] | 눈 | 스프링 세트 교체(슈 갈 때 같이) [26] |

---

## 부품: 브레이크 호스·파이프 (Brake hose / lines)
- 바퀴 쪽은 고무 **플렉시블 호스**, 차체 쪽은 쇠 파이프. Camry 앞 호스는 유니언 볼트 29.4 N·m + 새 개스킷 [3], 호스 고정 볼트가 바퀴 속도 센서 클램프와 **같이 물림** [11].
- 고장: 속이 갈라진 호스가 **한쪽 밸브**처럼 압력을 가둬 끌림 / 눌린 호스는 처음에 쏠렸다가 풀림 [34].
- 캘리퍼를 호스에 매달지 않기(끈·고리) [18][21].

## 부품: 마스터 실린더 + 부스터 (Master cylinder & brake booster)
- 마스터 실린더: 페달 힘 → 기름 압력. 피스톤 2개 = 회로 2개, **대각선 분리**(앞왼+뒤오 / 앞오+뒤왼) — 한 회로가 새도 설 수는 있지만 거리가 훨씬 김 [29].
- 리저버 = 위에 얹힌 반투명 통, 정비 중 **MIN~MAX 사이** 유지 [10][29].
- 부스터: 엔진 진공으로 페달 힘을 키움, 체크밸브가 시동 꺼진 뒤에도 조금 남김 [30]. Camry 부스터엔 진공 체크밸브 + **진공 경고 스위치** [13].
- 부스터 테스트: 시동 끄고 페달 5~6번 → 25~30 lb로 누른 채 시동 → **1/2~1 in 쑥 내려가면** 정상; 엔진 진공 17~21 inHg(15 미만이면 엔진 쪽 문제); 밟을 때 계속 **쉬익** = 다이어프램 찢어짐 [37].
- 고장: 페달 단단하고 안 들어감 = 부스터·진공 / 페달이 서서히 **가라앉음**(밖 누유 없음) = 마스터 속 우회(bypass) / 물렁·낮음 = 공기 [34][37]. 부스터 안에 브레이크액 → 마스터+부스터 같이 교체 [37].

## 부품: 브레이크액 (Brake fluid)
- Camry: **DOT 3(SAE J1703) 또는 DOT 4(SAE J1704)** [10].
- 끓는점(건조/젖음 3.7% 물): DOT3 205/140 °C, DOT4 230/155 °C, DOT5.1 260/180 °C; DOT5는 실리콘이라 **섞으면 안 됨** [27][40].
- 새 액 색: 무색~호박색(amber), DOT5만 보라 [27]. 오래되면 짙어짐 → 갈색·검정이면 교환 권유 [52](검색 요약, 낮은 품질). **색만으로 판단은 불확실** — ASE도 "눈 검사는 믿을 수 없음" [40].
- 글리콜 액은 물을 빨아들임(hygroscopic): 1년에 약 1~1.5%, 2~3년이면 3.7% 수준 [40]. 교환 기준: 물 3~4%, 구리 200 ppm 이상(시험지), 끓는점 < 젖음 규격 [40]. 교환 주기 2년/24,000 mi(Car Care Council) [52](검색 요약).
- 유리 도장 손상: 글리콜 액이 도장을 상하게 할 수 있음 [27].
- 비용: Camry 플러시 평균 약 $158(공임 ~$140) [49](검색 요약, YourMechanic).

## 부품: 공기 빼기 (Bleeding)
- Camry 매뉴얼: 블리더 캡 떼고 비닐관 → 페달 펌프 → 밟은 채 블리더 풀기 → 멈추면 조임 → 새 액 나올 때까지 반복, 블리더 토크 8.3(단위 잘림, N·m로 보임) [10]. 순서는 그 페이지에서 (확인 못 함).
- 일반 순서: 마스터에서 **가장 먼 바퀴부터** — 보통 RR → LR → RF → LF, 대각선 회로 차는 RR → LF → LR → RF도 있음, 공장 정보 우선 [38].
- 2인 수동: 3~4번 펌프 후 유지, 블리더 1/2바퀴 열고 페달 떼기 전에 닫기; 압력식 15~30 psi; 진공식 15~20 inHg [38].
- ABS 모듈에 공기 들어가면(모듈 교체·리저버 바닥) 스캔툴 **자동 공기빼기**로 밸브·펌프 돌린 뒤 일반 공기빼기 [38].

## 부품: ABS 바퀴 속도 센서 + 톤 링 (Wheel speed sensor & tone ring / encoder)
- ABS = 바퀴 속도 센서·밸브·펌프·ECU 4가지, 작동 중엔 **페달이 드르륵 맥박** [28].
- 센서 종류: 수동형(VR, 코일) / 능동형(Hall) [28][41].
- Camry: 앞 센서는 **스티어링 너클에 볼트 1개**로 꽂힘, 커넥터는 펜더 라이너 뒤, 클램프 볼트 2개 더(하나는 호스와 같이) [11]. 센서가 읽는 '속도 센서 로터'는 **앞 허브 베어링 안**에 있음 [12].
- 고장 예: DTC **C05061F**(오른 앞 센서 신호 끊김) — 센서 끝이나 로터에 **1 mm × 1 mm 이상 쇳가루·기름** 붙어도 뜸; 청소 → 지우고 → 안 되면 센서·허브 교체 [12]. 경고등 끄기: 34 mph(54 km/h) 이상 3초 [12].
- 톤 링 고장(다른 차 일반): 녹으로 금 감, 이 빠짐, 쇳가루, 자석 엔코더 자력 손상 → 금 간 링은 서기 직전 **가짜 ABS 작동**인데 경고등·코드는 안 남기도 함 [41].
- 얼라인먼트 등을 한 뒤 Toyota는 **영점 보정(zero point calibration)** 안 하면 VSC 꺼짐·슬립·ABS 경고등 [53](검색 요약).

## 경고등 (Brake / ABS / EPB warning lights)
- Camry 계기판에 브레이크 시스템 경고등, ABS 경고등, 슬립 표시등, 주차 브레이크 표시등, 브레이크 홀드 표시등 [14]. ABS등이 시동 때 안 켜지면 점검 [14].
- Camry 정비 매뉴얼: **빨간** 브레이크 경고등은 스키드 컨트롤 ECU가 켬(EBD 금지·고장 등), **노란** 브레이크 경고등은 ECU 내부 고장(C059704)·EPB 쪽 [14 함께 검색](검색 요약). 브레이크액 부족과 빨간 등 연결은 내가 연 Camry 페이지에선 (확인 못 함).
- EPB 고장이면 노란 EPB 경고등 [39].

---

## 내부 도안 근거 (본 것과 '어디에 무엇이')
- 앞 브레이크 부품도(C374508C04 / C376230C04)는 diagrams/05·06 + diagrams/index.md 에 정리 [3].
- Toyota TSB T-SB-0088-22 Figure 1·3: 차를 위에서 본 그림에 1 Front / 2 Rear / 3 Left / 4 Right, 5 = **바깥쪽 클립 키트(outer side fitting kit)** — 클립 키트가 브래킷 바깥쪽에 있다는 표시 [16]. Figure 2 = 클립 위 그리스 바를 곳 [16].
- Toyota TSB T-SB-0150-13 Figure 1·2: 패드 철판의 심 그리스 바를 곳, 심은 **아래 클립 2개 먼저 → 위 클립 3개** 끼움 [18].
- Toyota TSB T-SB-0033-18 Figure 6: 바퀴 너트 **틀린 순서 vs 맞는 순서** 그림(별 순서) [19].
- Camry 뒤 브레이크(EPB) 부품 목록 그림: 위 = EPB 액추에이터 + O링 + 배선, 가운데 = 캘리퍼·패드·심·유니언 볼트, 아래 = 브래킷(cylinder mounting)·No.1/No.2 슬라이드 핀·부싱·디스크 [9]. 토크 숫자는 그림 안에만 있어 (확인 못 함).

## car_spec · fault_catalog 와 다른 점
1. **캘리퍼 경첩 축**: car_spec `Hinge = 아래 가이드 볼트 축, 위로 70°` → 실제 Toyota는 **아래 볼트를 풀고 위쪽 핀을 축으로** 캘리퍼 아래쪽이 위로 들림 [1][3]. 아래 핀이 축이면 '위로 젖히기'가 안 됨 → **Hinge = 위 핀 축**으로 바꾸는 게 맞음.
2. **볼트 수**: car_spec·4-1 "볼트 2(캘리퍼 가이드 볼트)" → Toyota 매뉴얼 패드 교체는 **1개**(아래) [1]; DIY 가이드는 2개 다 풀고 캘리퍼를 떼서 매닮 [20][21]. 둘 다 '실제'라 고를 수 있음 — 매뉴얼 방식(1개+젖힘)이 손맛도 짧음.
3. **캘리퍼 위치**: car_spec "바퀴 중심 기준 **뒤**·위 45° (뒤 +0.5)" → 가로배치 FF는 조향 랙이 뒤라 캘리퍼가 **바퀴 중심 앞(−Z)**, 흔히 3/9시 [45][21](일반론 + XV70 매뉴얼 그림 diagrams/18 로 확인). 패드 피벗 "뒤 +0.5"도 같이 바뀜.
4. **PAD_WORN 기준 3 mm**: 실제 Camry 최소 1.0 mm / 새것 11.0 mm [4], 경고판은 약 1.5 mm에서 울림 [32]; 3 mm는 정비소 권장선 [47]. → 게임에선 "3 mm = 권장, 1 mm = 한계"로 2단 표시 가능.
5. **PAD_WORN 소리 '멈출 때 끼익'**: 위키백과는 경고판 소리가 **브레이크를 안 밟을 때** 나서 일반 끼익과 구별된다고 씀 [25]. 일반 끼익(공진)은 저속 제동 때 [16]. → 손님 대사를 "브레이크 안 밟아도 끼익" 쪽으로 하면 추리가 더 진짜 같음.
6. **BrakeDisc '디스크 휨'**: 업계는 '휨'을 거의 신화로 봄 — 실제 원인은 흔들림(runout) → 두께 차이(DTV), 허브 녹, 너트 임팩트 조임 [43][44][36]. 진단 = 다이얼 게이지(0.05 mm)·마이크로미터(25.0 mm 최소) [4][19][33]. "파란 열 자국" 근거는 (확인 못 함).
7. **피스톤 밀기**: 게임은 "클릭 1번" OK. 단 실제는 **리저버 넘침 확인**이 같이 붙고 [2][18], **뒤 바퀴 EPB 차는 패드 교체 모드가 먼저** [5][7] — `BrakePads_RL/RR`엔 이 단계가 빠져 있음.
8. **같이 가는 작은 부품**: 패드만이 아니라 심 2장·경고판·클립(지지판 4개)도 같이 [1][3][32] — 게임 '패드 세트'에 시각적으로 포함 추천.
9. **PAD_UNEVEN**: '한쪽 캘리퍼 뻑뻑 → 한쪽만 닳음 → 쏠림' 맞음. 다만 쏠리는 방향은 **굳은 쪽의 반대(잘 듣는 쪽)** [34], 바깥 패드만 닳는 건 **핀** 탓 [31]. 핀 그리스는 실리콘계(석유계 X) [31].
10. 맞는 점: "한 축 양쪽 같이" = Toyota 공지도 **양쪽 다** [16][17][19].

## 출처
1. Toyota Camry XV70 Repair Manual — Front Disc Brake Pad (except 2-pot) Removal — https://www.tocamry.com/removal-2101.html
2. 같은 매뉴얼 — Front Disc Brake Pad Installation — https://www.tocamry.com/installation-2102.html
3. 같은 매뉴얼 — Front Brake Components (wr-carbook가 매뉴얼에서 직접 확인, 토크 34.3/107/29.4 N·m·부품명) — https://www.tocamry.com/components-2490.html
4. 같은 매뉴얼 — Inspection: Front Brake (except 2-pot) (패드 11.0/1.0 mm, 디스크 28.0/25.0 mm) — https://www.tocamry.com/inspection-2493.html
5. 같은 매뉴얼 — Rear Disc Brake Pad (w/ EPB) Removal — https://www.tocamry.com/removal-2125.html
6. 같은 매뉴얼 — Rear Disc Brake Pad (w/ EPB) Installation — https://www.tocamry.com/installation-2126.html
7. 같은 매뉴얼 — Rear Brake Pad Replacement Mode — https://www.tocamry.com/rear_brake_pad_replacement_mode-2816.html
8. 같은 매뉴얼 — Electric Parking Brake System (DTC 목록) — https://www.tocamry.com/electric_parking_brake_system-2803.html
9. 같은 매뉴얼 — Rear Brake (w/ EPB) Components — https://www.tocamry.com/components-2508.html
10. 같은 매뉴얼 — Brake Fluid (DOT3/DOT4, MIN~MAX, 블리더) + Maintenance 목록 — https://www.tocamry.com/brake_fluid-2089.html , https://www.tocamry.com/maintenance-2058.html
11. 같은 매뉴얼 — Front Speed Sensor Removal — https://www.tocamry.com/removal-2534.html
12. 같은 매뉴얼 — Right Front Wheel Speed Sensor Circuit Intermittent (C05061F) — https://www.tocamry.com/right_front_wheel_speed_sensor_circuit_intermittent_c05061f_-2568.html
13. 같은 매뉴얼 — Brake Booster Components — https://www.tocamry.com/components-2749.html
14. 같은 매뉴얼 — Warning lights and indicators — https://www.tocamry.com/warning_lights_and_indicators-1854.html (+ 빨강/노랑 설명은 tocamry 검색 요약)
15. 같은 매뉴얼 — Rear Axle Hub (2WD w/o EPB) Removal (검색 요약: parking brake shoe adjusting hole plug) — https://www.tocamry.com/removal-2893.html
16. Toyota T-SB-0088-22 Front Brake Squeal/Squeak Noise (2018~22 Camry) — https://static.nhtsa.gov/odi/tsbs/2022/MC-10224176-9999.pdf
17. Toyota T-SB-0015-20 Rev1 (같은 내용 이전판) — https://static.nhtsa.gov/odi/tsbs/2020/MC-10181787-9999.pdf
18. Toyota T-SB-0150-13 TCMC Front Brake Pad Noise (Corolla/Matrix; 107/34/103 N·m, 절차) — https://static.nhtsa.gov/odi/tsbs/2013/MC-10132085-9999.pdf
19. Toyota T-SB-0033-18 Front Brake Vibration (Sienna; runout 0.05 mm, 너트 순서) — https://static.nhtsa.gov/odi/tsbs/2018/MC-10141575-9999.pdf
20. Paul's Travel Pictures — 2018-2022 Camry Front Brake Pads Replacement Guide — https://www.paulstravelpictures.com/2018-2022-Toyota-Camry-Front-Brake-Pads-Replacement-Guide/index.html
21. iFixit — Replace Front Brake Pads and Rotors, 2018–2024 Camry — https://www.ifixit.com/Guide/How+To+Replace+the+Front+Brake+Pads+and+Rotors+on+Your+2018%E2%80%932024+Toyota+Camry/185984
22. Core Brake Parts — 2018-2024 Toyota Camry Brake Guide — https://corebrakeparts.com/blogs/tech-info/2018-2024-toyota-camry-brake-guide
23. (검색 요약) Detroit Axle 판매 목록 Camry 305/281 mm, Accord 293/312 mm; Brembo 카탈로그 옛 Camry 296 mm — https://www.detroitaxle.com/?p=975869 , https://www.detroitaxle.com/?p=922222 , https://www.bremboparts.com/america/en/catalogue/toyota-camry-saloon-v3-2-4-acv30-acv36/000016362-1
24. (검색 요약) North Park Toyota — Electronic Parking Brake & Brake Hold — https://www.northparktoyota.com/blog/index.htm?page=7
25. Wikipedia — Disc brake — https://en.wikipedia.org/wiki/Disc_brake
26. Wikipedia — Drum brake — https://en.wikipedia.org/wiki/Drum_brake
27. Wikipedia — Brake fluid — https://en.wikipedia.org/wiki/Brake_fluid
28. Wikipedia — Anti-lock braking system — https://en.wikipedia.org/wiki/Anti-lock_braking_system
29. Wikipedia — Master cylinder — https://en.wikipedia.org/wiki/Master_cylinder
30. Wikipedia — Vacuum servo — https://en.wikipedia.org/wiki/Vacuum_servo
31. OpenExamPrep ASE A5 4.2 — Caliper Inspection, Slide Pin Lubrication — https://open-exam-prep.com/study-guides/ase-a5/disc-brake-systems/caliper-service-pin-lube
32. OpenExamPrep ASE A5 4.3 — Brake Pad, Anti-Rattle Hardware — https://open-exam-prep.com/study-guides/ase-a5/disc-brake-systems/brake-pad-hardware-replacement
33. OpenExamPrep ASE A5 4.4 — Rotor Runout & Micrometer — https://open-exam-prep.com/study-guides/ase-a5/disc-brake-systems/rotor-runout-measurement
34. OpenExamPrep ASE A5 4.9 — Pull, Drag, Pedal Travel — https://open-exam-prep.com/study-guides/ase-a5/disc-brake-systems/disc-brake-pull-drag-diagnosis
35. OpenExamPrep ASE A5 4.8 — Disc Brake Noise and Squeal — https://open-exam-prep.com/study-guides/ase-a5/disc-brake-systems/disc-brake-noise-squeal
36. OpenExamPrep ASE A5 4.6 — Lug Nut Torque, Hub Cleaning — https://open-exam-prep.com/study-guides/ase-a5/disc-brake-systems/lug-nut-torque-hub-cleaning
37. OpenExamPrep ASE A5 1.7 — Vacuum Booster Diagnosis — https://open-exam-prep.com/study-guides/ase-a5/hydraulic-power-assist-core/vacuum-booster-diagnosis
38. OpenExamPrep ASE A5 1.4 — Hydraulic Bleeding — https://open-exam-prep.com/study-guides/ase-a5/hydraulic-power-assist-core/hydraulic-bleeding-procedures
39. OpenExamPrep ASE A5 2.4 — EPB Systems and Service Modes — https://open-exam-prep.com/study-guides/ase-a5/parking-brakes-hydraulic-diagnosis/epb-systems-service
40. OpenExamPrep ASE A5 2.5 — Brake Fluid Testing — https://open-exam-prep.com/study-guides/ase-a5/parking-brakes-hydraulic-diagnosis/brake-fluid-testing-specs
41. OpenExamPrep ASE A5 5.3 — Tone Rings & Magnetic Encoders — https://open-exam-prep.com/study-guides/ase-a5/electronic-brake-control-systems/tone-rings-reluctor-inspection
42. OpenExamPrep ASE G1 5.2 — Drum Brake Inspection and Shoe Replacement — https://open-exam-prep.com/study-guides/ase-g1/brakes/drum-brakes-shoes
43. Motor Equipment News — The warped rotor myth — https://motorequipmentnews.co.nz/article/warped-rotor-myth
44. (검색 요약) Brake & Front End — Warped Rotors myth — https://www.brakeandfrontend.com/warped-rotors-myth/
45. eBay Motors — What Are Common Brake Caliper Positions? (+ Eng-Tips 포럼 검색 요약) — https://www.ebay.com/motors/blog/diy/what-are-common-brake-caliper-positions
46. (검색 요약) Bolidenforum 기술 데이터 — Honda 2010/2011 Accord 브레이크 토크 — https://www.bolidenforum.de/portal/fahrzeugdaten/honda-2011-accord-se-b90a/?vd_lang=en
47. (검색 요약, 낮은 품질) 패드 3 mm 권장선 — https://carfromjapan.com/article/brake-pad-thickness , https://engineerfix.com/how-low-is-too-low-for-brake-pads/
48. (검색 요약) RepairPal — 2023 Toyota Camry Repair & Maintenance Costs — https://www.repairpal.com/cars/toyota/camry/2023
49. (검색 요약) YourMechanic — Camry Brake System Flush / Accord Caliper Replacement — https://www.yourmechanic.com/estimates/toyota/camry/brake-system-flush , https://yourmechanic.com/estimates/honda/accord/brake-caliper-replacement
50. (검색 요약) Tire Review / MOTOR — brake hardware(클립·심 매번 교체) — https://www.tirereview.com/7-brake-hardware-items-neglected/
51. YouCanic — Honda Accord rear parking brake service mode (2018 Accord 포함) — https://www.youcanic.com/video/honda-accord-how-to-enter-rear-parking-brake-service-mode-change-brake-pads/
52. (검색 요약) 브레이크액 색·2년 주기 (Car Care Council 인용, 품질 낮은 색 설명 페이지 포함) — https://www.gmpperformance.com/product/231507/brake-fluid-flush-and-bleed/
53. (검색 요약) tocamry — front wheel alignment 후 영점 보정 필요 표 — https://www.tocamry.com/removal-2924.html
