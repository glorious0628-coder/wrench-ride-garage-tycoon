# 부품 빠른 참고표 (parts_quickref) — 6면 시안·3D용 (wr-carbook, 10-20)

> 메인 부탁: 바퀴·브레이크 묶음·배터리·라디에이터·머플러 5개 — **실제 치수 → stud 환산, 알아보는 특징 3개, 볼트 수·자리**.
> 환산: **1 stud = 0.28 m = 280 mm** (car_spec §0). car_spec 규칙: 차 폭 방향(X)은 ×1.15, 엔진룸 안 부품은 ×1.1까지 키워도 됨. 아래 'stud(실제)'는 그대로 나눈 값, '게임 권장'은 car_spec 규칙을 적용한 값.
> 기준 차 = Toyota Camry XV70 2.5 L(2018~2024). 그림체는 캐주얼(B) — 모양은 단순하게, **구성·비율·자리**는 이 표대로.
> 출처 번호는 맨 아래. 판매처 목록(애프터마켓) 숫자는 '판매처'라고 표시 — 공식 매뉴얼 숫자보다 한 단계 약한 근거예요.

## 0. 한 장 비교 (car_spec 숫자와)

| 부품 | 실제 크기 (mm) | stud(실제) | 게임 권장 | car_spec 지금 | 판정 |
|---|---|---|---|---|---|
| 타이어 215/55R17 | 지름 668 · 폭 215 | 2.39 · 0.77 | 2.4 · 0.88(×1.15) | 2.4 · 0.9 | **맞음** |
| 휠(림) 17×7.5 | 지름 432 · 폭 191 | 1.54 · 0.68 | 1.55 · 0.78 | 1.55 | **맞음** |
| 앞 디스크 | 지름 305 · 두께 28 | 1.09 · 0.10 | 1.1 · 0.12 | (장식, 숫자 없음) | 새로 |
| 앞 패드 1장 | 길이 142.6 · 높이 55.7 · 두께 16.4 | 0.51 · 0.20 · 0.06 | 같음 | 세트 0.25 × 0.5 × 0.6 | **방향 확인**(§2) |
| 배터리 (H5/Group 47) | 242 × 175 × 190 | 0.86 × 0.63 × 0.68 | 0.95 × 0.69 × 0.75 (×1.1) | 0.95 × 0.75 × 0.7 | **맞음** |
| 라디에이터 코어 | 700 × 440 × 16 (+양옆 탱크) | 2.50 × 1.57 × 0.06 | 탱크 포함 폭 ≈ 3.3, 높이 1.6~1.8 | 4.2 × 1.8 × 0.6 | **폭이 넓음**(§4) |
| 뒤 머플러 몸통 | 356 × 279 × 140 (전체 길이 743) | 1.27 × 1.0 × 0.5 (전체 2.65) | 같음 | v0.3 가로 통 2.6 × 0.6 × 1.0 | **맞음**(§5) |

---

## 1. 바퀴 (Wheel = Rim + Tire)

**실제 치수**
- 타이어 **215/55R17 94V**(LE 기본): 폭 215 mm, 옆면 높이 = 215 × 0.55 = 118 mm, 림 17 in = 432 mm → **바깥 지름 432 + 2 × 118 = 668 mm** [1][2]. 공기압 앞뒤 35 psi [2].
- 다른 트림: 205/65R16, 235/45R18, 235/40R19 [2] — 바깥 지름은 모두 비슷(약 650~690 mm, 계산값).
- 휠 17 × 7.5 in, 오프셋 ET45 [3](판매처) · 볼트 자리 **5 × 114.3**(PCD 114.3 mm), 너트 **M12×1.5**, 가운데 구멍 60.1 mm, **너트 5개, 103 N·m** [3][4].
- 너트 육각 21 mm(Toyota) [3](검색 요약 — 03 파일 참고). 너트는 **원뿔(테이퍼) 자리**.
- 무게: 타이어 약 11~12 kg [3] + 휠 (확인 못 함) → car_spec 20 kg은 그럴듯한 범위.

**stud 환산**: 타이어 지름 2.39, 폭 0.77(×1.15 → 0.88) · 림 지름 1.54, 폭 0.68(×1.15 → 0.78) · PCD 반지름 57 mm = **0.20 stud**(car_spec은 클릭 쉽게 0.28 — 의도된 키움) · 너트 21 mm = 0.075 stud(작아서 게임에선 키우는 게 맞음).

**알아보게 할 특징 3개 (캐주얼)**
1. 검은 **두꺼운 고무 링** + 옆면 둥근 **볼록 테두리(비드)** — 림과 만나는 선이 또렷.
2. 트레드에 **굵은 세로 홈 3~4줄**(홈 바닥에 작은 턱 = 마모 표시).
3. 은색 휠 가운데 **너트 5개가 별 모양 원**으로 + 가운데 캡.

**볼트 자리**: 바깥면 허브, 반지름 0.20(실제)·0.28(게임), 5개면 72° 간격(게임 4개면 90°). 조이는 순서 = **별(대각선)**, 2~3바퀴 나눠서 [4].

## 2. 브레이크 묶음 (디스크 + 캘리퍼 + 패드 2장)

**실제 치수**
- 앞 디스크: **지름 305 mm, 두께 새것 28.0 / 최소 25.0 mm**, 통풍형(두 장 사이 날개) [5][6]. 뒤 디스크 281 mm 막힌형 [6](판매처).
- 앞 패드 1장: **142.6 (길이, 디스크 둘레 방향) × 55.7 (높이, 반지름 방향) × 16.4 mm (철판+마찰재 전체 두께)** [7](판매처 2곳 같은 값). 마찰재만 새것 11.0 / 최소 1.0 mm [5].
- 세트(디스크를 사이에 두고 패드 2장) 두께 ≈ 16.4 + 28 + 16.4 = **약 61 mm** (계산).
- 캘리퍼: **피스톤 1개짜리 떠 있는(floating) 캘리퍼** + 받침 브래킷 [8]. 겉치수 (확인 못 함) — 패드(142.6 mm)를 감싸니 그보다 조금 큰 덩어리.

**stud 환산**: 디스크 지름 1.09, 두께 0.10 · 패드 0.51 × 0.20 × 0.06 · 세트 두께 0.22.

**캘리퍼·패드 자리와 방향 (중요)**
- 캘리퍼는 **바퀴 중심 앞쪽(−Z), 중심과 거의 같은 높이(약 9시/3시 방향)** — 매뉴얼 그림에서 타이로드 반대쪽 [9] (02 파일 ③).
- 그 자리에선 패드의 **긴 쪽(142.6 = 0.51 stud)이 세로(Y)**, 짧은 쪽(55.7 = 0.20)이 앞뒤(Z), 두께(세트 0.22)가 좌우(X).
- → car_spec 패드 세트 **0.25 × 0.5 × 0.6 (X×Y×Z)** 는 X·Y는 맞고 **Z 0.6 → 약 0.2**가 실제 비율. 캘리퍼를 지금처럼 '뒤·위 45°'에 두면 패드가 비스듬해짐 → wr-design에 board로 알림.

**알아보게 할 특징 3개 (캐주얼)**
- 디스크: ① 가운데 볼록 **모자(hat) + 볼트 구멍 5개** ② 가장자리 옆면 **날개 틈 줄무늬**(통풍형) ③ 패드 닿는 **반짝 띠** vs 녹슨 모자 색 대비.
- 캘리퍼: ① 디스크 가장자리를 **집게처럼 감싸는 덩어리** ② 안쪽 **둥근 피스톤 컵** + 꼭대기 **블리더 꼭지** ③ 위·아래 **고무 주름 부트**(슬라이드 핀) + 브레이크 호스 1줄.
- 패드: ① **은색 철판 + 두꺼운 회색/검정 마찰재** 두 층 ② 철판 양끝 **귀(ears)** ③ 위 모서리 작은 **휘어진 경고 탭(squealer)**.

**볼트 수·자리 (Toyota 매뉴얼)** [8][10] — 패드 갈 때 실제 방법은 둘 다 있음: Toyota 매뉴얼 = **아래 볼트 1개 풀고 위로 젖힘**, DIY 가이드(car_spec v0.3 근거) = **2개 다 풀고 떼어 매달기**. car_spec v0.3 '2개 풀고 Hinge로 젖힘'은 둘을 섞은 것(게임엔 괜찮음).
| 볼트 | 수 | 자리 | 힘 |
|---|---|---|---|
| 슬라이드 핀 볼트 | 2 (위·아래) | 캘리퍼 몸통 뒤(차 안쪽) 위·아래 | 34.3 N·m |
| — 패드 갈 때 푸는 것 | **아래 1개만** → 위 핀을 축으로 위로 젖힘 | | |
| 캘리퍼 브래킷 볼트 | 2 | 너클 뒷면(디스크 갈 때) | 107 N·m |
| 브레이크 호스 유니언 볼트 | 1 | 캘리퍼 뒤 (+새 와셔) | 29.4 N·m |
| 패드 받침 클립 | 4 | 브래킷 홈 | — |

## 3. 배터리 (12V Battery)

**실제 치수**
- 매뉴얼: 교체는 **같은 크기, 60 Ah(20시간율) 이상** [11].
- 규격은 출처마다 엇갈려요(Group 35·24F·47·48·H5 다 나옴, 연식별로 다를 수 있음) [12]. 그중 **H5 = Group 47 (60 Ah)** 가 매뉴얼의 60 Ah와 맞고, **바닥 턱을 누르는 고정쇠**(매뉴얼 그림) = 유럽(DIN)식 배터리 모양과 맞아서 기준으로 써요(추론).
- **H5/Group 47: 242 × 175 × 190 mm**, 60 Ah, AGM 제품 무게 **약 17.8 kg (39.2 lb)** [13][14].

**stud 환산**: 0.86 × 0.63 × 0.68 → ×1.1 = **0.95 × 0.69 × 0.75**. car_spec 0.95 × 0.75 × 0.7, 16 kg → 크기 맞음, 무게는 실제가 조금 더 무거움(17~18 kg).

**알아보게 할 특징 3개**
1. 납작한 **검정/회색 상자**, 윗면 한쪽 끝 **빨간 + 단자 덮개**, 반대쪽 검은 − 단자 [11].
2. 굵은 **빨강·검정 케이블 2줄**이 단자 클램프(너트 1개씩)로 물림 [11].
3. 상자 **아래 긴 쪽 턱**을 누르는 **작은 고정쇠 + 볼트 1개**, 밑에 받침(트레이) [15].

**볼트 수·자리** [11][15]: − 단자 너트(5.4 N·m) · + 단자 너트(5.4 N·m, 위에 덮개 걸쇠 2) · 바닥 고정쇠 볼트 1개(18.5 N·m). 자리 = 엔진룸 **운전석 쪽 앞**(car_spec (−2.2, 1.55, −6.6) 맞음).

## 4. 라디에이터 (Radiator + 팬)

**실제 치수** (2018 Camry 2.5 L 맞춤 교체품 기준 — 판매처)
- 코어: **27 9/16 × 17 5/16 × 5/8 in = 700 × 440 × 16 mm**, 알루미늄 코어 1줄, **플라스틱 탱크**, **가로흐름(crossflow — 탱크가 좌우 끝)** [16]. 같은 숫자(699 × 440.5 × 16)가 다른 판매처에도 있음 [17].
- 위·아래 호스 구멍 지름 **1.5 in(38 mm)**, 판매처 표기로 입구 'Left'·출구 'Right' — 서로 **반대쪽 탱크**에 있음(어느 쪽에서 본 좌우인지는 표기 없음) [16].
- 탱크 포함 전체 폭 (확인 못 함) — 상자 길이가 33 5/8 in(854 mm)라 전체 폭은 그보다 작음 [16]. 무게: 상자 포함 8 lb(3.6 kg) [16].
- 앞에 **콘덴서**(에어컨), 뒤에 **팬 슈라우드 + 큰 팬 1개** — 셋이 샌드위치 [18].

**stud 환산**: 코어 2.50 × 1.57 × 0.06. 탱크까지 넣으면 폭 약 2.8~3.0(추정) → ×1.15 ≈ **3.3**. 깊이는 콘덴서+코어+팬 슈라우드 합쳐 0.4~0.6이면 자연스러움(추정).
- car_spec **4.2 × 1.8 × 0.6**은 폭이 실제 비율보다 약 25% 넓음(실제 라디에이터 ≈ 차 폭의 약 40~45%, car_spec은 55%). 엔진룸을 꽉 채우는 '읽기 쉬움' 의도라면 괜찮지만, 진짜 비율은 **3.3 안팎** → wr-design 판단.
- car_spec 무게 7 kg(팬 포함) — 라디에이터 단품 약 3~3.5 kg + 팬·슈라우드 → 그럴듯(팬 무게 확인 못 함).

**알아보게 할 특징 3개**
1. 넓고 얇은 판에 **촘촘한 은색 핀 줄무늬**.
2. **좌우 끝에 세로로 선 검은 플라스틱 탱크**(한쪽 위에 주입구 목·캡).
3. 뒤에 붙은 **둥근 팬 + 사각 슈라우드**, 위·아래 **굵은 검정 호스 2줄**(스프링 클립).

**볼트 수·자리** [18][19]: 위 브래킷 2개(볼트 2 + 너트 2, 12.5 N·m) + 위 지지대 볼트 4 · 아래는 **고무 쿠션 2개**에 얹힘 · 호스 위(No.1)·아래(No.2) + 바이패스 2 · 팬 커넥터 1. 게임 '볼트 2 + 호스 클램프 2'는 이걸 줄인 것 — 맞음.

## 5. 뒤 머플러 (Rear Muffler, 꼬리관 포함)

**실제 치수** (2018~2024 Camry 맞춤 교체품 Walker 21005 — 판매처)
- **타원 몸통 14 × 11 × 5.5 in = 356 × 279 × 140 mm**, 전체 길이(관 포함) **29.25 in = 743 mm**, 들어가는 쪽 **2.4 in 관 + 볼트 2개 용접 플랜지**, 나가는 쪽 **2.0 in 비스듬히 자른 꼬리관**, 입·출구가 몸통 가운데가 아닌 **한쪽으로 치우침(offset-offset)**, 걸이 포함 [20][21].
- 매뉴얼(V6): 머플러 하나 = **플랜지 볼트 2 (43 N·m) + 새 개스킷 + 고무 걸이 2** [22]. V6·듀얼 배기 차는 왼쪽·오른쪽 2개.

**stud 환산**: 몸통 1.27 × 1.0 × 0.5, 전체 2.65. car_spec v0.3 **가로 통 2.6 × 0.6 × 1.0 (X × Y × Z)** → 전체 길이 2.65 ↔ 2.6, 앞뒤 폭 1.0 ↔ 몸통 짧은 변 1.0, 높이 0.5 ↔ 0.6 — **맞음**. (가로 배치 근거는 car_spec §9 wr-art 도안 모음.)

**알아보게 할 특징 3개**
1. **납작한 타원 통**(옆에서 보면 긴 알약), 앞뒤 끝이 둥글게 접힌 이음매(롤 심).
2. 한쪽으로 치우쳐 들어가는 **관 + 둥근 플랜지(볼트 2)**.
3. 반대쪽 끝에서 나오는 **비스듬히 잘린 꼬리관** + 몸통 위 **고무 걸이 2개**(쇠 막대가 고무 고리에 꽂힘).

## 출처
1. Tire code (sidewall: 215/55R17 읽기) — Wikipedia — https://en.wikipedia.org/wiki/Tire_code
2. Toyota Camry XV70 Repair Manual — Tire And Wheel System Inspection (사이즈·공기압 표) — https://www.tocamry.com/inspection-4065.html
3. 03_wheels_tires.md (ET45 판매처, 21 mm 너트, 타이어 무게 TireSize.com) — 이 폴더
4. Toyota Camry XV70 — 휠 너트 103 N·m·별 순서 (03_wheels_tires.md 출처 [12][16]) — 이 폴더
5. Toyota Camry XV70 Repair Manual — 앞 디스크·패드 두께 (02_brakes.md 출처 [4]) — 이 폴더
6. Detroit Axle 판매 목록 Camry 305/281 mm (02_brakes.md 출처 [23], 판매처) — https://www.detroitaxle.com/?p=975869
7. KarParts360 Camry 2018~ 앞 패드 (높이 55.7 · 폭 142.6 · 두께 16.4 mm) — https://www.walmart.com/ip/KarParts360-Toyota-Camry-2018-2025-Brake-Pads-Mechanical-Pad-Wear-Sensor-Type-16-4mm-0-65in-Inner-Overall-Thickness-142-6mm-5-61in-Inner-Width-55-7mm/19486056454 , 같은 값 eBay — https://www.ebay.com/itm/366670078695
8. Toyota Camry XV70 Repair Manual — Front Brake Components — https://www.tocamry.com/components-2490.html (diagrams/05·06)
9. Toyota Camry XV70 Repair Manual — Front Drive Shaft Components (바퀴 뭉치 그림) — https://www.tocamry.com/components-2923.html (diagrams/18)
10. Toyota Camry XV70 Repair Manual — Front Disc Brake Pad Removal — https://www.tocamry.com/removal-2101.html
11. Toyota Camry XV70 Repair Manual — A25A-FKS Battery Removal (60 Ah 이상) — https://www.tocamry.com/removal-2073.html
12. 검색 결과에서 Camry 2020 배터리 그룹이 35 / 24F / 47(2020~24)·48(2018~19) / H5로 서로 다름 — repairius.com, selectmyblog.com, openlaborproject.com, garagedex.com, carspecs.org (DuckDuckGo 검색 요약) — https://www.garagedex.com/battery/toyota/camry/ , https://www.carspecs.org/battery-size/toyota/camry/
13. Group 47 (H5, L2) 배터리 치수 242 × 175 × 190 mm — batteryequivalents.com (DuckDuckGo 검색 요약) — https://www.batteryequivalents.com/group-47-h5-l2-55l2-batteries.html
14. Interstate MTX-47/H5 AGM: 60 Ah, 650 CCA (공식 페이지 검색 요약) — https://www.interstatebatteries.com/products/mtx-47/h5 ; 무게 39.2 lb (Amazon 목록, 검색 요약) — https://www.amazon.com/Interstate-Batteries-Automotive-Replacement-MTX-47/dp/B0BH853YGP
15. Toyota Camry XV70 Repair Manual — Battery Components (토크·고정쇠) — https://www.tocamry.com/components-2072.html (diagrams/04)
16. RadiatorNow — CSF3858 radiator 2018 Camry 2.5L (코어 치수·가로흐름·플라스틱 탱크·호스 구멍) — https://radiatornow.com/products/toyota-csf3858-radiator-2018-camry-2-5l-l4
17. Alibaba 판매 목록 Camry 2.5L 2018~ radiator core 699 × 440.5 × 16 mm (DuckDuckGo 검색 요약) — https://www.alibaba.com/product-detail/Cooling-System-Auto-Car-Radiator-Aluminum_1601446850017.html
18. Toyota Camry XV70 Repair Manual — Radiator Removal — https://www.tocamry.com/removal-3647.html
19. Toyota Camry XV70 Repair Manual — Radiator Components — https://www.tocamry.com/components-3645.html (diagrams/07·08)
20. A-Premium — Walker 21005 (몸통 14 × 11 × 5.5 in, 걸이 포함) — https://a-premium.com/product/walker-exhaust-muffler-assembly-21005
21. CARiD — Walker 21005 Quiet-Flow SS Oval (전체 29.25 in, offset-offset) — https://www.carid.com/walker/quiet-flow-stainless-steel-oval-exhaust-muffler-mpn-21005.html ; eBay 목록(입구 2.402 in, 출구 2.0 in, 볼트 2개 용접 플랜지, 비스듬한 꼬리관) — https://www.ebay.com/itm/358869381557
22. Toyota Camry XV70 Repair Manual — Exhaust Pipe Removal (V6) — https://www.tocamry.com/removal-3524.html (diagrams/09)
