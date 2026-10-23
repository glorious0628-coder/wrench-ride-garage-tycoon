# 배기 (Exhaust System)

> 기준 차: 가로배치 직렬 4기통 앞바퀴굴림(FF) 중형 세단, 미국 왼쪽 운전석 (예: Toyota Camry XV70/XV80, Honda Accord 10·11세대, Hyundai Sonata DN8, Nissan Altima L34).
> 차 안 좌표·이름은 `docs/specs/car_spec.md` 기준(앞 = −Z, 운전석 = −X).
> 출처는 각 줄 끝 [n] → 맨 아래 '출처' 목록. 출처 없는 문장은 쓰지 않아요. 못 찾은 건 "(확인 못 함)".
> 조사 한계: RepairPal·YourMechanic·obd-codes·Eastwood·NAPA 등 여러 사이트가 접속을 막아(403) 공임 시간은 약한 출처뿐이에요. Camry 2.5L(A25A) 배기 분해도 원문은 못 열었고, 같은 차의 V6(2GR) 정비 매뉴얼 그림을 대신 봤어요.

## 한눈에 (3줄)
- 길: 엔진 → **배기 매니폴드**(요즘은 촉매가 붙어 있거나 아예 헤드 속에 들어감) → **앞 파이프(촉매·O2 센서·플렉스)** → **가운데 파이프(공명기)** → **뒤 머플러 + 꼬리관** [1][3][4][11][17].
- 이음새는 대부분 **볼트 2개 + 한 번 쓰고 버리는 개스킷**(플랜지) 또는 **밴드 클램프**(슬립 이음), 매달기는 **고무 걸이** [1][12][13][14].
- 고장 단골: 구멍(시끄러움), 고무 걸이 끊김(덜그럭), 열 차단판 떨림, 이음새 새기(틱틱·P0171), 촉매 수명(P0420·썩은 달걀 냄새), O2 센서(P0130~P0141) [20][23][24][28].

---

## 부품: 배기 매니폴드 (Exhaust Manifold / "Manifold Converter")
### ① 하는 일
- 실린더 4개에서 나온 뜨거운 가스를 한 관으로 모아요 [17].

### ② 실제 모양·크기·재질·색 — 알아보게 할 특징 3개
- 옛날·보통 차는 **주철(cast iron)** 덩어리 [17]. 무늬 없는 회색~녹 갈색.
- **Toyota Camry XV70**: 부품 목록에 "Catalytic Converter, Exhaust Manifold"(촉매 붙은 매니폴드) 이름이 있어요 [3]. V6(2GR) 매뉴얼은 매니폴드 안에 **앞 촉매(TWC: Front Catalyst)** 가 들어 있다고 그려요(wr-carbook 확인, diagrams/index.md) [2]. 2.5L 4기통만의 그림은 (확인 못 함).
- **Honda Accord 1.5 터보**: 매니폴드를 **알루미늄 실린더 헤드 속에 함께 주조**해서 따로 된 매니폴드가 없어요. 배기 밸브 8개를 4개씩 2묶음("4-into-2")으로 터보로 보내요 [11].
- 캐주얼 특징 3개: ① 엔진 뒤(또는 앞)에 붙은 **굵은 4갈래→1관** 모양 ② 위를 덮은 **반짝이는 열 차단판(주름진 은색)** ③ 꼭대기에 꽂힌 **O2 센서 1개 + 검은 선**.

### ③ 차 안 위치
- 가로배치 엔진의 배기 쪽 면(차 앞 또는 방화벽 쪽 — 차마다 다름, Camry 2.5L 정확한 방향은 확인 못 함). 게임은 `Deco_EngineLower`에 들어 있어요.

### ④ 붙어 있는 방식
- 헤드에 **스터드+너트**, 사이에 **매니폴드 개스킷**(부품 17173-F0010 등) [7].
- 배기 스터드는 열 때문에 녹슬고 **잘 부러져요**. 오래 기름(침투유)에 적신 뒤 풀고, 부러지면 드릴로 빼거나 EDM(방전 가공)으로 빼요 [27].
- 볼트 크기(예: 14 mm)·조이는 힘(2.5L): (확인 못 함).

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 차가울 때 "틱틱틱" → 데워지면 줄어듦 / 앞쪽 하체 쉭쉭 | 매니폴드 개스킷 새기, 스터드 부러짐, 매니폴드 금 | 청진기·소리 위치, 너트 빠짐 눈으로 (포럼 경험담 수준, 공식 출처 못 찾음) | 개스킷 교체(공임 $376~552, RepairPal 인용) [29] |
| 엔진 경고등 + **P0171**(희박) | O2 센서 앞쪽에서 공기가 새어 들어와 센서가 "공기 많다"로 읽음 | 스캐너 연료 보정값, 배기 누설 점검 [24] | 새는 곳 수리 [24] |
| 매니폴드 자체 교체 | 금·녹 | | 교체 $700~2,500+ (RepairPal 평균 $1,514~1,724 인용) [29] |

### ⑥ 게임 손맛 아이디어 (제안만)
- "차가울 때만 틱틱" 손님 → 시동 직후 청진기로 매니폴드에 대면 파동이 큼, 1분 뒤엔 작아짐(헷갈리는 짝: 엔진 밸브 소리).
- 스터드 풀 때 "녹 게이지": 침투유 뿌리고 기다리면 쉽게, 바로 돌리면 가끔 "똑!" 부러짐 → 드릴 미니게임.

---

## 부품: 열 차단판 (Heat Shield)
### ① 하는 일
- 뜨거운 배기에서 차 바닥·부품을 지켜요. 떼어 버리면 다른 부품이 일찍 고장 나거나 불이 날 수 있다는 경고가 있어요(검색 요약, 원문 못 엶) — (확인 못 함).

### ② 모양
- 얇은 철판을 **주름지게 찍은 은색 판**, 매니폴드·촉매·가운데 파이프 위를 덮어요. Accord 부품 목록에 "Floor Heat Baffle", "L/R Muffler Baffle" 판과 6×14 와셔 볼트가 함께 나와요 [10]. Camry V6 그림엔 "tail exhaust pipe baffle sub-assembly" [1].
- 캐주얼 특징: ① 주름 은박 ② 볼트 2~3개로 바닥에 붙음 ③ 파이프 모양 따라 휜 판.

### ④ 붙는 방식
- 바닥이나 파이프에 작은 볼트(Accord 6×14 와셔 볼트) [10] 또는 점용접.

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 특정 rpm이나 시동 때 **"찰찰·징징" 떨림 소리** | 고정 볼트·점용접이 녹·열로 끊어져 판이 떨림 (공식 출처 못 엶 — 검색 요약 [NAPA·7zap]) | 식은 상태에서 고무망치로 판을 툭툭 → 같은 소리면 찾음 (검색 요약) | 큰 스테인리스 밴드로 묶기(임시) / 다시 용접·자가 나사+넓은 와셔 (검색 요약) — (확인 못 함) |

### ⑥ 게임 손맛 아이디어
- fault_catalog `MUF_SHIELD` 그대로 좋아요. "망치로 판 툭툭 두드려 소리 찾기" 동작 추가(청진기 없이도 Lv1에서 가능).

---

## 부품: 산소 센서 — 앞(공연비 센서) / 뒤 (Upstream A/F Sensor · Downstream O2 Sensor)
### ① 하는 일
- **앞 센서(Sensor 1, 촉매 앞)**: 배기 속 산소를 재서 엔진 컴퓨터가 연료 양을 맞추게 해요 [15][30].
- **뒤 센서(Sensor 2, 촉매 뒤)**: 촉매가 일을 잘하는지 봐요. 앞·뒤 신호를 비교해서 촉매 효율을 판단해요(미국 새 차는 앞뒤 둘 다 의무) [15][16][22].
- 종류: 보통 지르코니아 센서는 "협대역" — 진함 ≈ 0.8 V, 묽음 ≈ 0.2 V, 기준 ≈ 0.45 V [15]. **광대역(Wideband·A/F 센서)**는 진함·묽음 정도를 직선 신호로 알려 줘요(1992 NTK 처음) [15]. 앞 센서는 광대역일 때가 많고 더 비싸요 [30].
- 약 316 °C(600 °F)는 돼야 일을 시작해서 **센서 안에 히터**가 있어요 [15]. 히터가 고장 나면 데워질 때까지 늦게 일해요(보통 2분 안이 정상) [21].

### ② 실제 모양·크기·재질·색 — 특징 3개
- 스파크 플러그 비슷한 금속 몸통 + **육각(22 mm = 7/8")** + 끝에 구멍 뚫린 보호 캡, 뒤로 **검은 선(보통 4가닥: 신호 2 + 히터 2)** 이 나와 커넥터로 가요 [15][19].
- 나사 크기: NGK는 **M18**과 M12 두 종류를 써요 [18].
- 캐주얼 특징 3개: ① 파이프에 꽂힌 **은색 짧은 막대 + 육각 너트** ② 꼬리처럼 나온 **검은 선 + 네모 커넥터** ③ 앞(매니폴드 쪽) 1개, 뒤(촉매 뒤) 1개 — 2개가 짝.

### ③ 차 안 위치
- 앞 센서: 매니폴드 가지들이 하나로 합쳐진 뒤, 촉매 앞 [15]. 뒤 센서: 촉매 뒤 [22]. Camry V6 그림은 앞 배기 파이프(뒤 촉매 달린 것)에 heated O2 센서 2개(Bank 1, Bank 2) [1]. Camry 2.5L 정확한 구멍 자리는 (확인 못 함).
- "Bank 1" = 1번 실린더가 있는 쪽. 직렬 4기통은 Bank 1만 있어요 [22].

### ④ 붙어 있는 방식
- 파이프 나사 구멍에 돌려 끼움. **22 mm(7/8") 홈 파인 O2 센서 소켓**(3/8" 드라이브) — 홈 덕분에 선을 단 채로 돌릴 수 있어요 [19].
- 끼우기(NGK): 손으로 끝까지 → M18은 렌치로 ½~¾바퀴 더, **26~33 ft·lb(약 35~45 N·m)**. M12는 ¾~1바퀴, 13.2~17 ft·lb [18].
- 나사에 붙어 나오는 **눌어붙음 방지제(anti-seize)** 가 없을 때만 바름, **새 개스킷** 사용, 선이 꼬이지 않게, 원래 길로 배선 [18].
- 하지 말 것: 떨어뜨린 센서 쓰기, **임팩트 렌치**, 센서용이 아닌 실리콘·화학제 근처 사용 [18].
- 녹슨 센서는 오래 걸리고, 억지로 돌리면 배기 부품을 망가뜨릴 수 있어요 [30].

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 경고등 + **P0130**(앞 센서 회로, 반응 없음) / P0131 낮은 전압 / P0132 높은 전압 / **P0133 느린 반응** / P0134 반응 없음 | 센서 고장, 선·커넥터 부식, 공기·연료 쪽 새는 곳, MAF/MAP 이상 [20] | 스캐너, 선·커넥터 눈으로, 배기·진공 누설 [20] | 센서 교체(설치비 보통 $250~550, AAA 대표값 $350~400) [30] |
| **P0135**(앞 센서 히터) — 시동 직후 공회전 거침 | 히터 회로 단선·합선, 물 들어간 배선, 오일 오염 [21] | 배선에 물·오일 확인 후 테스트 [21] | 센서 또는 배선 수리 [21] |
| **P0136**(뒤 센서 회로) / P0137 낮음 / P0138 높음(약 1.2 V) / P0139 느림 / P0140 반응 없음 | 센서·배선 부식, 센서 근처 배기 새기, 촉매 손상, 오일·냉각수 오염 [22] | 히터 저항 측정, 배기 누설 [22] | 센서·배선 교체, 새는 곳 먼저 [22] |
| P0141(뒤 센서 히터) | 히터 고장 — KBB 페이지가 비어 있어 원인 출처 (확인 못 함) | | |
| 센서 수명 | 히터 달린 센서 보통 약 **10만 마일(16만 km)** [15] | 하얀~회색 가루 = 실리콘 오염, 검은 기름때 = 오일, 검은 그을음 = 너무 진함 [15] | |
- Toyota 앞 A/F 센서 전용 코드(예: P2195 계열)는 출처를 못 열어 (확인 못 함).

### ⑥ 게임 손맛 아이디어
- 홈 파인 O2 소켓을 쓰면 "선이 홈으로 쏙" 들어가는 연출 — 일반 소켓은 못 씀.
- 스캐너 화면에 **앞 센서 선 = 지그재그(바쁘게 오르내림), 뒤 센서 선 = 평평**이 정상 → 뒤도 지그재그면 촉매 고장(P0420)! 그래프 보는 추리.

---

## 부품: 촉매 변환기 (Catalytic Converter, "Cat" — 앞 = Close-coupled/Manifold Cat, 아래 = Underfloor Cat)
### ① 하는 일
- **3원 촉매**: 질소산화물(NOx) → 질소, 일산화탄소·탄화수소 → 이산화탄소+물 [16].
- 약 **400 °C(750 °F)** 넘어야 일을 잘해서 엔진 가까이 둬요. 빨리 데우려고 매니폴드 바로 뒤에 작은 "앞 촉매(pre-cat)"를 두기도 해요 [16].
- 미국은 1975년식부터 대부분 휘발유 차에 달렸어요 [16].

### ② 실제 모양·재질 — 특징 3개
- 속은 **벌집 모양 세라믹(코디어라이트)** 덩어리, 아주 뜨거운 곳은 금속 포일 [16]. 그 위에 바른 층(워시코트)에 **백금·팔라듐·로듐** — 로듐은 환원, 팔라듐은 산화, 백금은 둘 다 [16]. 세리아가 산소를 저장했다 내놓아요 [16].
- Camry 2.5L는 아래쪽 앞 파이프 부품 이름이 "Converter & Pipe, Front Pipe"(촉매+파이프 한 덩어리) [4]. V6 그림: 매니폴드 = 앞 촉매, 앞 배기 파이프 = **뒤 촉매(Rear Catalyst)** [1][2].
- Accord: "Converter Assembly" 무게 약 14.2~16.6 lb(6.4~7.5 kg) [8].
- 캐주얼 특징 3개: ① 파이프 중간이 **불룩한 타원 통** ② 겉에 **열 차단판 덮개** ③ 앞뒤에 O2 센서 꼭지(앞 1·뒤 1).

### ③ 차 안 위치
- 앞 촉매: 엔진 배기 쪽 매니폴드에 붙음. 아래 촉매: 엔진룸 뒤쪽 바닥 아래, 앞 파이프에 [1][4]. 게임 `Deco_EngineLower`·`Deco_Underbody`.

### ④ 붙어 있는 방식
- 양 끝 플랜지 볼트+개스킷 [1]. Camry 파이프 이음 개스킷 90917-A6004가 "재사용 불가"라는 말은 검색 요약에서만 봤어요 (확인 못 함).
- 미국 1990 대기오염방지법: 정비소는 교체 목적이 아니면 촉매를 떼면 안 돼요 [16].

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 경고등 + **P0420**(촉매 효율 낮음, Bank 1) / **썩은 달걀 냄새** / 심하면 힘 없음 | 촉매 수명·고장(가장 흔함), 매니폴드·파이프 누설, 실화(misfire), 오일 오염, O2 센서 고장, 인젝터 샘 [23] | 앞·뒤 O2 전압 비교 — **뒤가 앞처럼 출렁이면** 촉매가 산소를 못 저장 [16][23] / 정상이면 실화·연료 쪽 확인 [23] | 원인 먼저 고치고 촉매 교체. O2만 바꾸면 안 고쳐질 수 있음 [23]. OEM 촉매는 $1,000 넘을 수 있음 [29] (RepairPal Camry 2011·2013 $1,755~2,113은 검색 요약뿐, 원문 403 — 확인 못 함) |
| 냄새 원인 | 연료 속 황 → 촉매 안에서 **황화수소(H₂S)** 생성 [16] | | 저유황 연료가 줄여 줌 [16] |
| 촉매 녹음·막힘(배기 막혀 힘 없음) | 실화·연료 진함·배기 누설로 **과열 → 녹아내림** [16] | | 원인 수리 + 교체 |
| 촉매 독 | 납, 황, 망간, **냉각수 속 실리콘**, 오일 첨가제(인·아연) [16] | | |
| **도난** — 시동 걸면 갑자기 엄청 시끄러움 | 귀금속 노림. 배터리 공구로 **몇 분이면** 잘라 감 [25] | 차 밑에 잘린 파이프 | 교체 $1,000~3,000 [25] |
- 도난 숫자: 미국 신고 2018년 1,298건 → 2020년 14,433건 → 2022년 약 15.3만 건(위키 인용) [16]. 2020년 12월 로듐 온스당 $14,500, 팔라듐 $2,336, 백금 $1,061; 고물상은 개당 $50~250, 하이브리드는 $800~1,500 [25].

### ⑥ 게임 손맛 아이디어
- "도둑맞은 촉매" 손님: 차 밑에 **톱으로 잘린 파이프 끝 2개** — 보는 순간 웃기고 바로 이해됨. 수리 = 새 촉매 + 이음 2곳.
- 썩은 달걀 냄새를 **초록 구름 아이콘**으로(냄새 진단 칸).

---

## 부품: 플렉스 파이프 (Flex Pipe / Flex Joint)
### ① 하는 일
- 고무 마운트 위에서 흔들리는 엔진 움직임을 흡수해 딱딱한 파이프·용접부가 깨지지 않게 해요. **가로배치 FF 차에 특히 흔해요** [31].
### ② 모양
- **주름관 위에 스테인리스 철망을 엮은 짧은 토막** [31]. 캐주얼 특징: ① 파이프 중간의 **땋은 머리 같은 은색 망** ② 양 끝 링 ③ 촉매 앞뒤 근처.
### ③ 위치
- 보통 매니폴드(또는 촉매)와 나머지 파이프 사이 [31]. Accord 1.5 "앞 플렉스 파이프" 사제 부품이 따로 팔려요(검색 결과) — 정확한 자리 (확인 못 함).
### ④ 붙는 방식
- 앞 파이프에 용접된 일체형이 많아요. 고장 나면 잘라 내고 새 플렉스를 용접, 또는 클램프/플랜지형(용접이 더 오래감) [31].
### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 가속할 때 커지는 **"부르르·지지직·틱틱"** | 철망·안쪽 주름관 닳음, 엔진 마운트 낡아 흔들림 커짐, 녹 [31] | 차 밑 그을음 자국, 망이 풀림 [31] | 잘라 내고 새 것 용접 [31] |
| P0171/P0174, P0420/P0430 | O2 센서·촉매 **앞에서** 새서 [31] | | |
| 실내로 일산화탄소 위험 | 엔진 가까운 누설 [31] | | |
### ⑥ 게임 아이디어
- 엔진 마운트(나중 부품)와 짝 고장: 플렉스만 바꾸면 3주 뒤 또 터짐 → 단골 이야기.

---

## 부품: 가운데 파이프 + 공명기 (Center Pipe / Intermediate Pipe + Resonator)
### ① 하는 일
- 앞 파이프와 뒤 머플러를 잇고, **공명기**는 관을 넓혀 소리 파동을 서로 지워 소음을 줄여요 [17].
### ② 모양
- Camry 2.5L 부품 이름 "Pipe Assembly, Exhaust Intermediate(Center)", 상자 크기 약 55 × 46 × 8 in, 20.6 lb(9.3 kg) 또는 62 × 34 × 6 in, 14.3 lb [4]. → 차 바닥을 따라 **1.4~1.6 m 긴 관** + 중간 불룩한 통(공명기 여부는 그림 못 봐 확인 못 함).
- 캐주얼 특징: ① 바닥 가운데 터널을 지나는 긴 관 ② 중간 작은 타원 통 ③ 고무 걸이 1~2개.
### ③ 위치
- 차 바닥 가운데 터널 아래, 앞좌석~뒷좌석 아래 [1].
### ④ 붙는 방식
- V6 그림: 앞 파이프와 개스킷+볼트, **바닥 커버(front floor cover LH/RH)·브레이스(center floor crossmember brace, front center floor brace)** 를 먼저 떼야 내려와요 [1].
- 매다는 고무: "exhaust pipe support" + No.1 support bracket [1].

---

## 부품: 뒤 머플러 + 꼬리관 (Rear Muffler / "Tail Pipe Assembly" + Exhaust Tip)
### ① 하는 일
- 소리 파동을 안에서 튕기고 지워 조용하게 해요. 순정 머플러는 배압이 꽤 생겨요 [17]. 꼬리관은 마지막 출구, 장식 팁이 붙기도 해요 [17].

### ② 실제 모양·크기·재질·색 — 특징 3개
- Toyota는 머플러+꼬리관이 한 덩어리 "Pipe Assembly, Exhaust Tail(Muffler)" [5]. 듀얼(SE/XSE 등)은 운전석 쪽 17440 + 반대쪽 17430 두 개 [4][5].
- 사제 직결 키트(Camry 2.5L 2018~24): 머플러 몸통 **9.8 × 14 × 4.5 in**(판매처 표기 H×W×L, 약 25 × 36 × 11 cm — 어느 쪽이 차 길이 방향인지는 표기가 애매), 파이프 지름 **2.25 in(57 mm)**, 알루미나이즈드 강, 꼬리 팁 지름 3 in·길이 9.75 in 스테인리스 사선 컷 [12].
- V6 매뉴얼: 머플러 LH·RH 두 개, 각각 뒷바퀴 뒤 **타원 통**(wr-carbook 확인, diagrams/index.md) [2].
- Honda Accord 1.5T: 운전석 쪽 머플러(11.2 lb, 상자 60 × 39 × 23 cm) + 조수석 쪽 "긴 파이프가 붙은" 머플러(30 lb, 상자 134 × 48 × 21 cm) — 두 개가 좌우 다름 [9][10].
- 2018~24 Camry 순정형 교체품 Walker 21005: **타원 몸통 14 × 11 × 5.5 in(356 × 279 × 140 mm), 전체 29.25 in(743 mm)**, 입구 2.4 in 볼트 2개 용접 플랜지, 출구 2.0 in 비스듬한 꼬리관, offset-offset (parts_quickref §5 출처 [20][21]).
- 머플러 방향(차 폭 방향으로 눕힌 '가로형'인지, 길이 방향인지): Camry·Accord 분해도 그림 원문을 못 열어 (확인 못 함). car_spec v0.3은 wr-art 도안 모음 근거로 **가로 통**으로 정함. 위 크기들로 보면 "뒷바퀴 뒤 범퍼 아래 납작한 타원 통" 쪽이 맞아 보이지만 추측이에요.
- 캐주얼 특징 3개: ① 뒤 범퍼 아래 **납작한 타원 통** ② 통에서 뒤로 나온 **꼬리관 + 반짝 팁** ③ 통 위 **고무 걸이 2개**.

### ③ 차 안 위치
- 뒷바퀴 축 뒤, 뒤 범퍼 아래 [2]. 게임 `Muffler` (+1.2, 0.8, +7.0).

### ④ 붙어 있는 방식 (볼트 수·크기, 떼는 순서)
- **Camry 2.5L 사제 키트 부속: 너트 2 + 볼트 2 + 링 개스킷 1** → 앞 이음은 **볼트 2개 플랜지** [12]. V6 매뉴얼도 각 머플러 = 볼트 2 + 재사용 불가 개스킷, 고무 지지대 2개, 플랜지 볼트 **43 N·m**(wr-carbook 확인, diagrams/index.md) [2].
- **Altima 2.5L(2019~25) 사제 키트: 2.5 in 밴드 클램프 1개** → 슬립 이음(관 끼우고 띠로 조임) [13].
- 떼는 순서(Haynes, Camry 일반): 차 올리기 → 녹슨 클램프 볼트에 침투유 → 가운데 파이프와 머플러 잇는 클램프(또는 플랜지) 풀기 → **고무 걸이 빼기** → 새 머플러 + **새 개스킷·클램프** → 고무 걸이 끼우기 → 시동 걸어 새는지 확인 [14].
- 고무 걸이 개수: Camry 2.5L 부품 목록에 서로 다른 지지 고무 **최소 3종(NO.2·NO.3·NO.4/5)** + 브래킷 여러 개 [6]. Accord 목록에 "Exhaust Mounting Rubber" 4종 [10]. 차 1대 정확한 총 개수는 (확인 못 함).
- 너트 크기(14 mm 등): (확인 못 함).

### ⑤ 흔한 고장
| 증상 | 원인 | 진단 | 수리법 · 시간 |
|---|---|---|---|
| 갑자기 **시끄러움**("경주차 같아요") | 머플러·파이프 녹 구멍, 이음 새기 | 리프트로 올려 눈: 녹·구멍·그을음 | 머플러 교체. 공임 2시간 예시($300, 녹슨 머플러+연결관) / 순정형 $600~1,200+, RepairPal 평균 $1,138~1,190(공임 $104~153) 인용 [29] |
| (원인 쪽) 머플러 **속부터** 녹 | 꺼진 뒤 배기 속 수증기가 물로 고임 — 짧은 거리만 달리면 마르지 않음 (포럼 의견만, 공식 출처 못 찾음) | | (확인 못 함) |
| **덜그럭·쿵쿵**, 머플러가 낮게 처짐, 끌림 | **고무 걸이** 열·추위·염화칼슘·진동으로 굳고 갈라져 끊어짐 [28] | 식은 뒤 파이프를 흔들어 봄: 탄력 있게 움직이면 정상, 쿵 하거나 처지면 걸이 고장 [28] | 걸이 교체(주방세제·실리콘 윤활제 조금 발라 끼움), 차체와 **2~3 cm** 띄우기 [28]. 하나씩 잘라 내야 머리로 안 떨어짐(검색 요약) |
| 걸이 끊긴 채 두면 매니폴드 쪽 **틱틱/쉭쉭** 누설 | 앞 이음에 무리 [28] | | |
| 공임 | 전체 교체 = 8시간 이상, 머플러만 = 2~5시간 'book time'이라는 출처도 있음(검색 요약) — 품질 약함 | | |

### ⑥ 게임 손맛 아이디어
- 고무 걸이 끼우기 = **늘려서 쏙** 미니게임(세제 바르면 쉬워짐).
- 플랜지 볼트 2개 풀면 **헌 개스킷이 떨어져 '찰칵'** — 새 개스킷을 안 넣으면 시운전 때 "푸르륵" 새는 소리(오진 아님, 실수 피드백).
- 침투유를 뿌리고 **10초 기다리기 vs 바로 돌리기** 선택 → 기다리면 쉽게, 바로면 가끔 볼트 끊어짐.

---

## 공통: 연기 색·물방울 (Smoke Colors & Condensation)
| 보이는 것 | 뜻 | 출처 |
|---|---|---|
| 추운 날 시동 직후 **옅은 흰 김**, 데워지면 사라짐 | **정상** — 응결된 수증기 | [26] |
| 데워진 뒤에도 **진한 흰 연기** 계속 | 냉각수가 엔진 안에서 탐(헤드 개스킷 등) | [26] |
| **파란 연기** + 타는 냄새 | 오일이 탐(밸브 실, 피스톤 링, 터보). 오일 너무 많이 넣었거나 배기에 흘렸으면 저절로 멈춤 | [26] |
| **회색 연기** | 오일 과다 연소, PCV 고장, 자동변속기 오일 빨림 | [26] |
| **검은 연기**(휘발유 차) | 연료가 너무 많음(더러운 공기 필터, 인젝터 문제) | [26] |
- 엔진룸에서 연기가 나면 바로 차를 세우고 끄기 [26].

---

## 내부 도안 근거 (정비 매뉴얼 그림·분해도·배치도 — 본 것과 '어디에 무엇이')
- **Camry XV70 2GR-FKS(V6) 배기 파이프 구성도** [1]: 그림 이름표 = Front exhaust pipe assembly (TWC: Rear Catalyst), Center exhaust pipe assembly, Heated oxygen sensor (Bank 1)·(Bank 2), No.1 exhaust pipe support bracket (lower side), Exhaust pipe support, Gasket. 꼬리관 그림 = Tail exhaust pipe assembly, Tail exhaust pipe assembly LH, Tail exhaust pipe baffle sub-assembly, Exhaust pipe support(재사용 불가 표시). 별도 그림 = Front floor cover LH/RH, Body mounting plate, Center floor crossmember brace, Front center floor brace. 숫자 토크는 텍스트에 안 나옴. → 4기통은 뱅크가 하나라 O2 배치가 다를 수 있어요.
- **wr-carbook가 매뉴얼에서 확인한 같은 매뉴얼 내용** [2]: 매니폴드에 앞 촉매 일체, 앞 파이프 = 뒤 촉매 + O2 2개, 가운데 파이프, 꼬리 머플러 LH·RH(뒷바퀴 뒤 타원 통), 머플러마다 볼트 2 + 재사용 불가 개스킷 + 고무 지지대 2, 플랜지 볼트 43 N·m, 가운데 파이프 떼려면 바닥 커버·브레이스 먼저.
- **Camry 2018 부품 목록** [3][4][5][6]: 17410 = 앞 파이프("Converter & Pipe" 촉매 포함), 17420 = 가운데(Intermediate) 파이프, 17430/17440 = 꼬리관+머플러(17440 = 운전석 쪽), 17565/17566 = 지지 고무(NO.2~NO.5), 17571~17577 = 브래킷(뒤 머플러 앞·뒤 브래킷, 가운데 파이프 브래킷 이름 있음). 그림 이미지는 텍스트로 못 받음.
- **Accord 2018 부품 목록** [8][9][10]: 18150 촉매(Converter Assy), 18305 운전석 머플러, 18307 조수석 머플러(긴 관 포함), 18215 고무 4종, 18303 머플러 개스킷, 74611/74651/74652 열 차단판, 93404-06014 와셔 볼트 6×14. 그림 속 번호(Ref 9 = 운전석 머플러)만 확인, 개수는 안 나옴.

## car_spec · fault_catalog 와 다른 점
1. **머플러 개수·모양**: car_spec은 `Muffler` 1개(+X 쪽, 1.2 × 0.6 × 2.4, 길이 방향 Z가 김). 실제는 트림에 따라 **머플러 2개(좌·우 듀얼)** 인 차가 많아요 — Accord 1.5T 기본이 좌우 2개, Camry V6·SE류도 2개 [2][5][9]. 사제 Camry 2.5L 머플러 몸통은 약 25 × 36 × 11 cm로 게임 크기(약 34 × 17 × 67 cm, mm÷280 환산)보다 짧고 넓어요 [12]. 게임 크기는 꼬리관 포함이라 길어도 되지만, **몸통은 납작한 타원 통 + 뒤로 나온 꼬리관**으로 나누어 보이게 제안. 방향(가로형인지)은 확인 못 함. → **car_spec v0.3(가로 통 2.6 × 0.6 × 1.0)** 은 Walker 21005 치수(전체 2.65 · 몸통 1.0 · 높이 0.5 stud)와 잘 맞아요(parts_quickref §5).
2. **이음 볼트 2개 = 실제와 맞아요** (Camry 플랜지 2볼트 + 링 개스킷) [12]. 다만 실제는 **개스킷을 새것으로** 바꿔야 해요(재사용 불가) [2][14] → "개스킷" 소모품 추가 제안. Altima 같은 차는 볼트가 아니라 **밴드 클램프 1개** [13] → 차종 차이로 쓸 수 있음.
3. **고무 걸이 2개(손)**: 머플러 하나엔 2개가 실제와 맞아요 [2]. 차 전체엔 더 많아요(가운데 파이프·앞 파이프에도) [1][6].
4. `Deco_EngineLower`의 "배기 매니폴드 + 촉매"는 Camry 식(매니폴드에 촉매 일체)엔 맞지만, Accord 1.5T 식은 **매니폴드가 헤드 속**이라 따로 안 보여요 [11]. 오리지널 차 디자인 땐 한 방식을 골라야 해요.
5. fault_catalog 1-5엔 **촉매(P0420), O2 센서(P0130~P0141), 플렉스 파이프, 매니폴드 틱틱** 고장이 없어요 → 나중 부품 후보: `O2Sensor_Up/Down`(볼트 0, 22 mm 소켓 돌리기 + 커넥터 1), `CatConverter`(볼트 2+2, 도난 이야기).
6. `MUF_HOLE` 연출 "시동 때 구멍에서 연기"는 좋지만, **추운 날 꼬리관 흰 김은 정상** [26]이라 이것만 보고 고장 판정하면 오진이 되게 하면 교육적이에요(헷갈리는 짝).
7. `MUF_SHIELD` 진단 = 청진기(Lv4)인데, 실제로는 **망치로 판 두드려 보기**로도 찾아요(검색 요약 — 원문 못 엶) → Lv1 진단 수단으로 써도 됨.

## 출처
1. Toyota Camry (XV70) 2GR-FKS Exhaust Pipe — Components — https://www.tocamry.com/x-3523.html
2. (wr-carbook가 매뉴얼에서 직접 확인, diagrams/09·10) Toyota Camry XV70 Exhaust Pipe Removal — https://www.tocamry.com/removal-3524.html
3. 2018 Toyota Camry Exhaust Manifold (OEM parts list) — https://www.toyotapartsdeal.com/oem-2018-toyota-camry-exhaust_manifold.html
4. 2018 Toyota Camry Exhaust Pipe (OEM parts list) — https://www.toyotapartsdeal.com/oem-2018-toyota-camry-exhaust_pipe.html
5. 2018 Toyota Camry Muffler (OEM parts list) — https://www.toyotapartsdeal.com/oem-2018-toyota-camry-muffler.html
6. 2019 Toyota Camry Exhaust Hanger (OEM parts list) — https://www.toyotapartsdeal.com/oem-2019-toyota-camry-exhaust_hanger.html
7. 2018 Toyota Camry Exhaust Manifold Gasket — https://www.toyotapartsdeal.com/oem-2018-toyota-camry-exhaust_manifold_gasket.html
8. 2018 Honda Accord Exhaust Pipe (OEM parts list) — https://www.hondapartsnow.com/oem-2018-honda-accord-exhaust_pipe.html
9. 2018 Honda Accord Muffler (OEM parts list) — https://www.hondapartsnow.com/oem-2018-honda-accord-muffler.html
10. Honda 18305-TVA-A04 Silencer Complete (diagram ref + related parts) — https://www.hondapartsnow.com/genuine/honda~muffler~l~exhaust~18305-tva-a04.html
11. detikOto, "Sama-sama 1.5 Turbo, Apa Beda Mesin Accord, Civic dan CR-V?" — https://oto.detik.com/event/d-4638343/sama-sama-15-turbo-apa-beda-mesin-accord-civic-dan-cr-v
12. BRExhaust 108-0333, 2018-2024 Toyota Camry 2.5L Direct-Fit Muffler Kit — https://brexhaust.com/products/108-0333-brexhaust-2018-2024-toyota-camry-2-5l-direct-fit-exhaust-muffler-kit-108-0333
13. BRExhaust Direct-Fit Rear Muffler Kit, Nissan Altima 2.5L 2019-2025 — https://onefastshop.com/products/brexhaust-direct-fit-rear-muffler-kit-nissan-altima-2-5l-2019-2025
14. Haynes, Change Rear Silencer — Toyota Camry — https://us.haynes.com/pages/repair-guides-change-rear-silencer-car-toyota-camry
15. Wikipedia, Oxygen sensor — https://en.wikipedia.org/wiki/Oxygen_sensor
16. Wikipedia, Catalytic converter — https://en.wikipedia.org/wiki/Catalytic_converter
17. Wikipedia, Exhaust system — https://en.wikipedia.org/wiki/Exhaust_system
18. NGK, Oxygen Sensor Installation — https://ngksparkplugs.com/?p=1485
19. GGB Exhaust, 7/8" (22mm) Slotted O2 Socket — https://ggbexhaust.com/collections/accessories/products/7-8-22mm-slotted-o2-socket
20. KBB, P0130 — https://www.kbb.com/obd-ii/p0130/
21. KBB, P0135 — https://www.kbb.com/obd-ii/p0135/
22. KBB, P0136 — https://www.kbb.com/obd-ii/p0136/
23. KBB, P0420 — https://www.kbb.com/obd-ii/p0420/
24. KBB, P0171 — https://www.kbb.com/obd-ii/p0171/
25. CBS News, Catalytic converter thefts soar along with the price of precious metals — https://www.cbsnews.com/news/catalytic-converter-thefts-metals
26. Auto Express, Car exhaust smoke: what the colours mean — https://www.autoexpress.co.uk/car-news/102502/car-exhaust-smoke-what-do-the-different-kinds-of-emissions-and-colours-mean
27. Innova, Handling Seized Fasteners — https://www.innova.com/blogs/fix-advices/handling-seized-fasteners
28. ArabsTurbo, The "Exhaust Hangers": The Reason Your Muffler Hits the Ground — https://www.arabsturbo.com/the-exhaust-hangers-the-reason-your-muffler-hits-the-ground-874448.html
29. ThePricer, Car Exhaust Install Cost — https://www.thepricer.org/car-exhaust-install-cost/
30. ThePricer, O2 Sensor Replacement Cost — https://www.thepricer.org/how-much-does-o2-sensor-replacement-cost/
31. YouCanic, Flex Pipe (glossary) — https://www.youcanic.com/glossary/flex-pipe/
