# 정비소 운영 — 하는 일 전체 목록 + 하루 흐름 + 우리 게임에 넣는 법 (shop_operations) — wr-carbook, 2026-10-22

> 부탁: ① 미국 동네 독립 정비소(independent shop)가 하는 일 전체 + 비율·시간·값·계절, ② 하루 흐름(접수 → 견적 → 승인 → 부품 → 수리 → 검사 → 정산)과 사람들·권유 판매·손님이 화나는 순간, ③ 우리 게임에 넣는 법.
> 규칙: 이번에 직접 연 출처 = **[n]**(맨 아래). 이 폴더 기존 파일 = **CJV**(`common_jobs_visible.md`), **05투어**(`video/05_shop_tour.md`), **07견적**(`video/07_estimate_receipt.md`), **FC**(`docs/design/fault_catalog.md`), **ECO**(`economy.md`), **GG**(`garage_growth.md`), **FB**(`fun_boost.md`) — 거기 있는 내용은 다시 안 쓰고 링크만 해요.
> 표시: 못 찾은 건 **(확인 못 함)**, 검색 결과 요약만 본 건 **(검색 요약)**, 내 해석은 **(추정)**·**(제안)**. 돈은 미국 달러, 차·동네마다 크게 달라요 — 게임 '느낌'용.

## 한눈에 (3줄)
1. **'일 종류별 매출 비율'은 공개 자료를 못 찾았어요.** 있는 건 "예방 정비(preventive maintenance) 매출 목표 30 %, 실제 대부분 5~12 %" 하나뿐 [1]. 그래서 '얼마나 흔한가'는 CJV의 주기·순위(CarMD·AAA)를 그대로 씀.
2. **진짜 정비소의 뼈대 = 접수 → 점검 → 견적 → 손님 허락 → 일 → 마무리 → 사후 연락 7단계** [8]. 허락 없이 일 시작 X, 견적을 넘는 변경은 먼저 알림 [8][19]. 이 뼈대가 우리 게임의 `n.fixToo`("Want me to fix that too?")와 이미 같은 모양 (07견적).
3. **손님이 화나는 순간 4개 = 갑작스런 청구서·밀리는 일·같은 문제가 다시 옴·필요 없는 걸 권함** [5][24][21]. 우리는 이걸 **'화나서 떠나는 일 없는' 부드러운 이벤트**로 바꿔 쓰자 (제안, §3).

---

## ① 미국 동네 정비소가 하는 일 — 표

### ①-0 이 표 읽는 법 (솔직하게)
- **비율(매출·건수)**: 일 종류별 공개 조사는 **못 찾음**. 가장 가까운 것 = FenderBender 칼럼의 "목표 30 %, 대부분 5~12 %"(예방 정비 매출) [1], 그리고 CJV ①-1의 CarMD 경고등 수리 순위·AAA 출동 순위(배터리가 견인 다음 2위) — 새로 찾은 게 아니라 CJV 것.
- **일하는 시간**: 정비소는 **책 시간(flat-rate / book time)** 으로 일해요 — 일마다 정해진 시간표가 있고, 기술자는 시계가 아니라 이 시간으로 월급이 계산됨 [6]. 책은 Mitchell 1·ALLDATA 같은 회사 것을 많이 씀(검색 요약) [6]. 아래 '시간' 칸은 **CJV·FC에서 이미 확인된 것만** 숫자, 나머지는 (확인 못 함).
- **값**: 이번에 새로 연 KBB·ThePricer 것 + CJV 값. 낮은 품질 사이트 것은 (검색 요약, 낮은 품질)로 표시.
- **현실 점검**: 오늘날 일하는 차는 **주행 5만~15만 마일이 거의 80 %**(2026 조사, 정비소 약 700곳) [17] → 게임 손님 차도 '꽤 탄 중고차' 느낌이 맞음.

### ①-1 일 목록 (동네 정비소가 받는 일 + 계절)
| 일 (US 이름) | 매출·건수 비율 | 시간 (book time) | 값 범위 | 계절·때 | 우리 게임에 지금? |
|---|---|---|---|---|---|
| **오일+필터 교환** (oil & filter change) | 못 찾음 | 15분~1시간 (CJV ①-2) | 일반 $35~75, 합성 $65~125 (CJV) | 일 년 내내, 주행거리마다 | economy Lv3 예정 |
| **타이어 위치 교환** (tire rotation) | 못 찾음 | 약 30분 (CJV) | $20~50 (CJV) | 봄·가을 점검 때 많음 [9](검색 요약) | **고장 목록에 없음** |
| **타이어 장착·밸런스** (mount & balance) | 못 찾음 | (확인 못 함) | 타이어 1개당 장착·밸런스 약 $12~30 (검색 요약, 낮은 품질) [29] | **첫눈 오면 폭발**(아래 ①-2) [18] | 기계 Lv5(Wheel Balancer) |
| **펑크 수리** (flat repair) | AAA 출동 상위 (CJV) | (확인 못 함) | (확인 못 함) | 일 년 내내 | 있음 `TIRE_FLAT` |
| **얼라인먼트** (wheel alignment) | 못 찾음 | 최대 약 1시간 (CJV) | 앞만 $65~100 (CJV) | **봄 구멍(pothole) 철** [12] | Lv16 기계 (ECO) |
| **브레이크 패드·디스크** | 정비소 고르는 이유 2위 (CJV) | 패드 양쪽 0.8 h (CJV) | 축당 $150~400 (CJV) | 일 년 내내, 연 1회 점검 권장 [9] | 있음 `PAD_*` |
| **브레이크액 교환** (brake fluid flush) | 못 찾음 | (확인 못 함) | 평균 **$173~205** [13] | 2년 또는 20,000 mi (검색 요약) | **없음** |
| **배터리 시험·교체** | AAA 출동 약 700만 건 (CJV) | (확인 못 함) | $45~300 (CJV) | **겨울**: 32°F에서 약 35 %, 0°F에서 약 60 % 약해짐 [10] / **여름**: 열이 배터리 고장 1위 원인, 3년 넘으면 점검 [11] | 있음 `BAT_*` |
| **시동·충전** (starter / alternator) | 못 찾음 | (확인 못 함) | (확인 못 함) | 겨울에 늘어남 [10] | 알파 후보 (FC) |
| **냉각 계통** (coolant top-off/flush, 서모스탯, 호스) | CarMD 서모스탯 9위 (CJV) | (확인 못 함) | 냉각수 교환 $131~209 (CJV) | **여름 과열**; Car Care Council: 냉각 계통 고장 = 고장 나서 멈추는 이유 중 앞쪽 [9], 정비소 전화는 더운 날 에어컨 > 과열(검색 요약) [31] | 있음 `RAD_*` |
| **에어컨 충전·진단** (A/C recharge) | 못 찾음 | (확인 못 함) | 전국 평균 약 $283~366, 차종별 $250~440, 일부 $500+ [16]; 새 냉매(R-1234yf)는 값이 몇 배 [16] | **여름**; 더운 날 정비소에서 제일 흔한 수리가 에어컨, 보통 충전으로 끝(검색 요약) [31] | **없음 (FC에 에어컨 없음)** |
| **A/C 큰 수리** (compressor / condenser) | 못 찾음 | (확인 못 함) | 컴프레서 약 $1,058~1,447, 콘덴서 약 $833~978 [16] | 여름 | 없음 |
| **변속기액 교환** (transmission fluid) | 못 찾음 | (확인 못 함) | 부분 교환 $150~175, 전체 flush $165~290 [14] | 수동 30,000~60,000 mi, 자동은 차마다(안 바꾸는 차도) [14]; Car Care Council 24,000~36,000 mi [9] | **없음** |
| **파워스티어링액** | 못 찾음 | (확인 못 함) | 평균 $172~204 [15] | (확인 못 함) | 없음 (XV70은 전동 랙이라 해당 X, CJV) |
| **서펜타인 벨트·호스** | 못 찾음 | (확인 못 함) | (확인 못 함) | 일 년 내내 | 알파 후보 (FC) |
| **엔진 경고등 진단** (check-engine) | CarMD 10위 목록 (CJV) | 스캐너 몇 분 (CJV) | **진단비 약 $100~130**(한 시간 공임쯤), 수리하면 빼 주는 곳이 많음 (검색 요약) [22] / 수리 평균 $415 (CJV) | 일 년 내내 | 있음(OBD Reader) |
| **서스펜션·스티어링** (strut, link, 볼조인트) | 못 찾음 | (확인 못 함) | (확인 못 함) | **봄**: 구멍이 타이어·바퀴·얼라인먼트·서스·쇼바를 상함, 평균 수리 약 $600(2021) [12] | 있음 `SWAYLINK`·Strut (FC) |
| **배기** (muffler, exhaust, catalytic) | 촉매가 CarMD 1위 (CJV) | 머플러만 1~3 h (낮은 품질) [30] | 머플러 설치 $150~350대 (낮은 품질) [30]; 촉매 평균 $1,348 (CJV) | 겨울 소금·녹 뒤 (추정) | 있음 `MUF_*` |
| **와이퍼·전구** | 가장 짧은 주기 (CJV) | 몇 분 (CJV) | 블레이드 $30~75 (CJV) | **겨울**: 약 6개월마다 점검, 극한 날씨엔 더 빨리 닳음 [9] | 와이퍼 3D 새로 (CJV ③) |
| **에어필터 2종** | 못 찾음 | 공구 없이 짧게 (CJV) | $25~200 (CJV) | **산불 철** 연기가 많을 때 점검·교체 [9] | 있음 AirFilter |
| **라이트 점검 + 연 1회 브레이크 점검** | 못 찾음 | 짧음 | 무료로 해 주는 곳 많음 (CJV) | Car Care Council: 라이트는 오일 교환 때마다 보기 [9] | 일부 |
| **주유 캡·소소한 경고등** | CarMD 7위 (CJV) | 1분 | 조이기 무료 (CJV) | — | 알파 후보 (FC) |
| **주(state) 안전 점검·배출가스 검사** | 해당 주만 | 뉴욕 약 1시간, 버지니아 30~45분, 펜실베이니아 45~90분 (검색 요약, 낮은 품질) [23] | 뉴욕 약 $10~37, 버지니아 $20, 펜실베이니아 $15~41 (검색 요약, 낮은 품질) [23] | 해마다 기한에 맞춰 | **미시간엔 없음** (아래) |
| **출발 전 점검** (pre-trip) | 못 찾음 | Car Care Council "10분 확인" [9] | 무료~ | **명절·여름 여행 전**: 필터·액·벨트·호스·타이어·배터리·브레이크 + VIN으로 리콜 확인 (검색 요약) [32] | 없음 |
| **무료 눈 점검 → 추가 견적** | — | — | 무료 (CJV) | 봄 4월 'Car Care Month' 행사 (검색 요약, 낮은 품질) [32] | FB #10 루프 근거 |

### ①-2 미국에서 '주 검사'는 어디서? (Michigan = 없음)
- 정기 **안전 검사(safety inspection)** 가 있는 주: Delaware·Hawaii·Maine·Massachusetts·Missouri·New York·North Carolina·Pennsylvania·Rhode Island·Vermont·Virginia·West Virginia 등. 일부는 상업용 차만(Connecticut·New Jersey·DC), Louisiana는 개인 차 의무가 2026-06-30에 끝남 [3].
- **배출가스 검사(emissions)**: 주 전체 = Connecticut·Delaware·Massachusetts·New Jersey·New York·Rhode Island·Vermont (위키 표에서 내가 읽어 낸 것 — 표에 따로 '주 전체' 표시는 없음 (추정)). 큰 도시 지역만 = Arizona·California·Colorado·Georgia·Illinois·Indiana·Maryland·Nevada·Ohio·Oregon·Texas·Utah·Wisconsin 등 [3].
- **Michigan**: 위키 목록에 "안전·배출가스·VIN 검사 없음"으로 들어 있음 [3]. KBB 목록을 인용한 SlashGear도 Michigan을 검사 없는 주에 넣음 (검색 요약) [33]. 단, 목록마다 주 이름이 조금 다르니 최신은 주 정부 확인 필요 [33].
- → **우리 디트로이트풍 도시에는 '주 검사' 일을 넣지 않는 게 맞음** (정비소가 하는 척하면 거짓). 대신 "여행 가는 친구 차를 출발 전 점검" 같은 일이 맞음 (제안, §3).

### ①-3 계절표 (미시간 느낌으로)
| 철 | 실제로 몰리는 일 | 근거 |
|---|---|---|
| **가을(10월 'Fall Car Care Month')** | 배터리 시험(3년 넘으면 교체 고려), 난방·성에제거·와이퍼·라이트·타이어·브레이크 점검, 연료통 반 이상 채우기 | [9] |
| **겨울(첫 추위·첫눈)** | 배터리 방전(AAA 필라델피아 하루 2,300 통화 중 1,068이 배터리), 겨울 타이어 교체 줄 서기(알래스카 한 타이어 가게: 10~11월 6~8주가 연 매출 30 %) | [10][18] |
| **봄(해빙)** | 구멍(pothole): 얼었다 녹는 순환에 아스팔트가 깨지고, 미시간은 매년 3월쯤 위험 철, 소리·진동·편마모면 점검 | [12] |
| **여름** | 열 때문에 배터리 고장 1위, 에어컨, 과열, 여행 전 점검 | [11][31][32] |
| **일 년 내내** | 오일·브레이크·타이어·점검 | CJV |
- 미시간 한정 계절 자료(겨울 소금·녹 수요 등)는 **못 찾음**.

---

## ② 하루 정비소 — 7단계 + 사람들

### ②-1 하루 흐름 (실제 순서)
| # | 단계 | 실제로 하는 일 | 근거 |
|---|---|---|---|
| 1 | **접수·듣기** (check-in) | 차는 3가지로 옴: 그냥 들어옴(walk-in) · 견인으로 옴 · 예약. **서비스 어드바이저(service advisor)** 가 손님 말(증상)을 듣고 수리 주문서(repair order, RO)에 적음. 증상 적기·차 정보·**한 바퀴 둘러보기**는 07견적 §1 그대로 | [8][27], 07견적 |
| 2 | **점검·진단** (inspection / diagnosis) | 작업 전에 **모든 차를 점검**해야 함 — 건너뛰면 나중에 비쌈. 결과는 종이보다 말·메일로 알리라는 조언 | [8] |
| 3 | **진단비** (diagnostic fee) | 경고등 같은 건 원인 찾는 시간 값을 받음. 미국 평균 약 $100~130, 수리하면 공제해 주는 곳 많음 (검색 요약) | [22] |
| 4 | **견적 만들기** (estimate) | "가장 중요한 단계" — 메모를 꼼꼼히 써서 나중에 생길 일 여지까지 담기. 부품+공임, 책 시간 × 시간당 요금 (07견적 §2) | [8], 07견적 |
| 5 | **손님 허락** (authorization) | 일 시작 전 말·서면 허락. 서명 전엔 시작 X. 주마다 법이 다름 | [8], 07견적 |
| 6 | **부품 주문** (parts) | 부품 가게(parts counter)에 주문, 가게에서 배달. 정비소 설문: 배달의 **75 %가 60분 이내**(Babcox, 연도 불명) (검색 요약). 부품 배달이 늦거나 배달 기사 부족이 2021 조사(정비소 500곳)에서 가장 큰 이유 | [21] |
| 7 | **수리 중** (work in progress) | 기술자가 일함. 새 문제가 나오면 **견적의 5 %를 넘는 변경은 손님에게 먼저 알림** | [8] |
| 8 | **마무리·시운전** (QC / road test) | 어드바이저가 기술자와 같이 **빠진 게 없는지** 확인, 차 몸·실내에 기름때·쓰레기가 없는지 보고 최대한 깨끗이 돌려줌. 시운전 기준 자체는 이번엔 못 찾음 | [8] |
| 9 | **정산·설명·키 돌려주기** | 영수증 줄 설명(07견적 §3). Michigan 법: 서면 견적이 있어야 하고 견적을 넘는 요금은 손님이 알고 동의해야 함, 합계 $50 미만 일은 서면 견적 불필요 (검색 요약) | [19] |
| 10 | **사후 연락** (follow-up) | 큰 수리 뒤에는 직접 연락하고 의견을 물음 → 단골·소개가 쌓임 | [8] |

### ②-2 사람들 (roles)
| 역할 | 하는 일 | 근거 |
|---|---|---|
| **주인(owner)** | (확인 못 함 — 이번에 주인 역할을 직접 설명한 자료는 못 찾음) | — |
| **서비스 어드바이저 (service advisor, service writer)** | 손님 말 듣기 → 필요한 서비스 정하기 → 수리 주문서 작성 → 시간·값 견적 → 추가 일이 나오면 **먼저 허락 받기** → 손님이 서명하고 복사본 받음. 일정 잡기·불만 처리·정비 권유도 함. 월급이 이익의 일정 % 커미션인 곳이 있음 (검색 요약, 낮은 품질) | [27][28] |
| **기술자 (technician)** | 점검·진단·수리. BLS: 중간 연봉 **$50,620**(2025), 일 거리는 시간제(hourly) 또는 한 일 양에 따라 받는 곳이 있음, 약 82만 5천 명 | [4] |
| **A/B/C 급** | 가게 관례(공식 등급 아님): A = 도움 없이 진단·수리 끝냄 / B = 기본 일(스티어링·서스·브레이크·얼라인먼트·가벼운 엔진 부품) 하면서 전기·진단 배우는 중 / C는 정의를 못 찾음 (검색 요약) | [25] |
| **플랫 레이트 (flat rate)** | 책 시간 × 기술자 단가 — 책 시간이 2.0시간이면 1.5시간에 끝내든 2.5시간 걸리든 같은 값. 단가는 보통 손님에게 받는 공임의 **30~50 %**. 빠르면 이득, 느리면 손해. **진단은 시간을 알 수 없어 시간제로 주는 곳이 많음.** 단점: 서두르다 '다시 옴(comeback)', 가르치면 손해라 후배를 안 가르치게 됨 | [6] |
| **루브 기술자 (lube tech)** | 입문 역할: 차를 빨리 점검·기름칠하고, 더 필요한 수리는 어드바이저에게 넘김. 마스터 기술자 중에 루브 기술자 출신이 많다고 말하는 가게도 있음 (검색 요약). BLS도 '윤활 일꾼(lubrication workers)'을 입문 역할로 적음 | [4][25] |
| **부품 담당·포터 (parts person, porter)** | 부품 카운터·배달·정리 같은 입문 일로 분류됨(대학 정비과 진로표). 부품 매니저 일은 자세히 못 찾음 | [25](검색 요약) |

### ②-3 권유 판매(upselling)와 윤리 — 초록·노랑·빨강 점검표
- **손님 마음**: AAA 설문(기사 날짜 2016-12-06) — 미국 운전자 **약 3분의 2가 정비소를 믿지 않음**. 이유 1위 = 필요 없는 서비스를 권함 **76 %**, 과청구 73 %, 나쁜 경험 63 %, 일이 제대로 될지 걱정 49 %. 그래도 **64 %는 믿는 단골 정비소가 있음** [5].
- **초록·노랑·빨강 점검표 (traffic-light / DVI)**: 정비소 소프트웨어(ALLDATA)는 빨강 = Service Now, 노랑 = Service Soon, 초록 = Okay로 씀. 어느 정비소는 "애매한 권유 때문에 급한지 미룰 수 있는지 모른다"는 불만을 줄이려고 도입, 빨강·노랑 판정에는 **사진이나 측정값**을 붙이게 함 (검색 요약, 블로그·가게 홍보) [20]. 색 의미를 정한 독립 표준은 못 찾음 [20].
- **좋은 가게의 모습** (Motorist 단체의 10가지 중): ① 무엇을 봤고 어떤 상태·원인·안전·다음 단계인지 설명("나쁘다"만 X) ② 일 시작 전 서면 견적, 값이 바뀌면 먼저 연락 ③ 사진·측정값·스캔 결과를 보여 줌 ④ **"어떤 건 급하고 어떤 건 미뤄도 된다"** 며 전부 승인하라고 압박 안 함 ⑤ 안전 얘기는 침착하게, 과장 X ⑥ 예산에 맞춰 순서 정하기 [7].
- **노랑 무시의 결말**: 서펜타인 벨트가 닳았다고 노랑이었는데 몇 달 뒤 끊어진 정비소 이야기 (검색 요약, 블로그) [20] — 게임의 '미룬 일이 나중에 터짐' 이야기 재료 (제안).
- **현실**: 손님이 일을 미루는 경향 — 정비소 약 700곳 조사에서 **50 %가 "손님이 일을 미루거나 거절"**, 49 %는 필수 아닌 일에 더 조심스러워졌다고 함 (2026-04 발표) [17]. 영국 자료(검색 요약): 빨강 안전 문제를 찾고도 70 %는 전부 승인 안 함, 못 하는 이유 1위가 돈 [34].

### ②-4 손님이 화나는 순간 (출처 있는 것만)
| 순간 | 실제로 일어나는 일 | 근거 |
|---|---|---|
| **① 갑작스런 청구서** | BBB(미국 소비자 단체): 원하지 않은 일에 대한 놀라운 요금 → 청구 분쟁. 전국에서 해마다 약 3만 5천 건 자동차 수리 불만 접수 (검색 요약, BBB 보도). 07견적: "부품 100 + 공임 100"이라고만 말하면 세금·소모품까지 290을 보고 화냄 → 처음부터 '전부 포함 한 숫자'로 말하는 가게 | BBB (검색 요약) [35], 07견적 |
| **② 밀리는 일·기다림** | 지연과 변명, 일이 안 끝났는데 연락 없음(BBB 사례). 2021 조사: 정비소 평균 한 대 일이 약 1.5일 더 걸림, 74 %가 예약을 더 오래 기다리라고 말함 | [35](검색 요약), [21] |
| **③ 부품 기다림** | 같은 조사: 정비소 절반이 부품 배달이 자주 막히고 34 %가 가끔 막힌다고 답함. 전자 부품(변속기 컨트롤 모듈 등)은 몇 달 백오더 사례(검색 요약) | [21] |
| **④ 같은 문제가 다시 옴 (comeback)** | BBB: 고치지 못한 수리를 반복하며 돈 더 씀. 건강한 가게의 comeback 비율은 대략 5 % 이하라는 업계 글이 있으나 정식 조사 아님 (검색 요약) | [35], [24] |
| **⑤ 필요 없는 일 권유** | 위 AAA 76 % | [5] |
| **⑥ 우리가 그랬다는 말다툼** | 접수 때 차 한 바퀴 둘러보기로 이미 있던 흠 기록 → 다툼 방지 | 07견적 §1 |
- 법·권리 쪽 (참고): FTC 안내는 서명한 서면 견적, 빈 주문서에 서명 X, 정해진 금액을 넘기 전 승인받기 (검색 요약) [26]. 캘리포니아는 손님이 요청하면 헌 부품을 돌려줌 (검색 요약) [26].

---

## ③ 우리 게임에 넣는 법 (제안 — 게임 규칙: 손님은 화나서 떠나지 않음 · 시간 별점 깎기 X · 틀려도 괜찮음)

### ③-0 먼저: 우리한테 이미 있는 것 vs 없는 것
- **있음** (FC 확인): 배터리, 타이어·휠, 브레이크 패드, 라디에이터, 머플러, 범퍼·보닛 도색, 스트럿·스웨이링크, 헤드라이트, 서펜타인, 연료 캡·점화·발전기·촉매(알파 후보).
- **없음 (이 문서 ①-1에서 새로 보인 것)**: **에어컨**, **와이퍼·워셔** (3D는 CJV ③에 제안), **브레이크액·변속기액 교환**, **타이어 위치 교환**, **얼라인먼트 흐름의 의미 있는 손맛(ECO Lv16만)**, **출발 전 점검(pre-trip)**, **점검표(초록·노랑·빨강)**, **부품 주문·기다림**, **계절**, **겨울 타이어 교체 몰림**, **구멍(pothole) 시즌**.

### ③-1 가장 재밌을 만한 새 일 TOP — 공개 전(10/31, 작게) vs 공개 뒤
| 순위 | 일 | 왜 재밌나 | 실제 근거 | 언제 | 크기 |
|---|---|---|---|---|---|
| 1 | **점검표 카드 (green/yellow/red) — 무료 눈 점검 → 추가 일 제안** | 이미 있는 `n.fixToo`와 같은 모양, 'Spot On!'과 어울림. 손님이 안 믿는 이유(권유)를 게임이 "우린 사진·숫자로 보여 줘요"로 뒤집음 | [20][7]; CJV "무료 점검 → 추가 일 제안" 루프 | **공개 뒤** (UI 한 장 + 데이터 필요) | M |
| 2 | **에어컨 점검 (A/C check)** | 여름 시즌 일, 차 안·밖 두 군데 확인(새는 흔적·컴프레서·팬) → '충전만' vs '큰 수리' 갈림이 좋은 헷갈리는 짝 | [16]: 충전 $283~366 vs 컴프레서 $1,000+; 더운 날 제일 흔한 수리 (검색 요약) [31] | **공개 뒤** (3D·시스템 새로) | M~L |
| 3 | **겨울 배터리 아침** (이미 있는 `BAT_*` 변주) | 새 부품 필요 없음 — 같은 일을 '겨울 시즌 말'과 '아침 줄 서기'로 변주 | [10]: 32°F에서 약 35 %·0°F에서 약 60 % 약해짐 | **공개 전 가능**(문구·가중치만) | S |
| 4 | **구멍(pothole) 봄 — 소리 추리** | `SWAYLINK_WORN`·`TIRE_UNEVEN` 변주를 '봄 구멍철'로 묶기. 손님이 "I hit a pothole last week"라고 말하면 단서가 됨 | [12] | **공개 전** (손님 대사 Locale만) | S |
| 5 | **와이퍼·워셔 (덤 일)** | 1분짜리 만족스러운 '덤' 일, 제일 짧은 주기 | CJV ①-2 | **공개 뒤** (3D 필요) | S~M |
| 6 | **출발 전 점검 (Road-trip check)** | 짧은 점검표 미니게임: 액·벨트·호스·타이어·배터리·브레이크 — 'Roadside Call'(FB #18)과 이어짐 | [9]: 10분 확인 | **공개 뒤** | M |
| 7 | **브레이크액 교환 (Brake fluid flush)** | 투명 통 높이·색 보기(CJV ②-1 통 3개와 이어짐) + 공기 빼기 | [13]; CJV | **공개 뒤** | M |
| 8 | **타이어 위치 교환 (tire rotation)** | 별 순서 조이기 이미 있는 손맛 재활용 | CJV | **공개 뒤** | S |
- **공개 전 최소**: #3·#4(문구·가중치)뿐. 나머지는 3D·UI 새로 필요해 공개 전엔 위험 — 사용자 규칙(품질 안 되면 안 넣음)과 맞춤.

### ③-2 접수 → 견적 → 손님 허락 흐름을 게임에 넣을까?
- **이미 있는 것**: `n.fixToo`("Want me to fix that too?") = 진짜 '추가 작업 허락 전화'와 같음 (07견적 §우리 게임에 쓰는 법 5).
- **제안: '서비스 어드바이저 책상' 아주 작은 단계** (공개 뒤, 사람 시험 뒤):
  1. 손님이 와서 **한 문장**으로 증상을 말하면 책상에서 **수리 주문서 카드**가 자동으로 한 줄 적힘(플레이어는 '확인' 한 번). [8][27]
  2. 점검 끝에 **카드 3색**: 초록 OK / 노랑 곧 / 빨강 지금. 눌러 보면 **사진 한 장 + 숫자 하나**(패드 3 mm 등). 근거: 사진·측정값을 붙이는 게 신뢰 [7][20].
  3. 손님이 **"Yes, go ahead"** 하면 시작. 기본값은 "전부 할래?"가 아니라 **빨강만 먼저**(안전 먼저, 압박 X). [7]
  - **어린 플레이어용 단순화**: 견적 숫자 계산·세금·소모품 줄은 넣지 않음 (07견적 §3의 결론과 같음).
- **넣지 않는 이유 하나**: 이 단계를 필수로 만들면 첫 5분 '와'를 늦춤. → **Lv3 이후 선택형**(UI 복잡도 최소 규칙).

### ③-3 계절·날씨 이벤트 (제안, 코드는 공개 뒤)
| 철 | 이벤트 | 일(고장 가중치) | 근거 |
|---|---|---|---|
| 가을 | "Fall Car Care Month" — 정비소 앞 무료 점검 주간 | 배터리·와이퍼·라이트·타이어 점검 손님 ↑ | [9]; 05투어(동네 행사) |
| 겨울 | **첫눈 아침** — 아침에 손님 줄 + 겨울 타이어 교체 몰림 | 배터리 방전·타이어 교체 ↑ | [10][18] |
| 봄 | **구멍철(Pothole Season)** — 쿵 소리·핸들 쏠림·편마모 손님 | 서스·타이어·얼라인먼트 ↑ | [12] |
| 여름 | **열파(Heat Wave)** — 에어컨·과열·배터리 | `RAD_*`·`BAT_*`·에어컨 ↑ | [11][31] |
- 시간·돈 압박 X, **'오늘의 영수증'에 날씨 한 줄 + 아이콘**만으로 충분 (GG의 눈에 보이는 변화 원칙과 같은 방향).

### ③-4 화나는 순간을 '부드러운 이벤트'로 (손님은 떠나지 않음)
| 실제 순간 | 게임 이벤트 (제안) | 규칙 |
|---|---|---|
| ① 갑작스런 청구서 | 정산 때 손님이 **"Wait, what's this line?"** 말풍선 → 줄을 누르면 사진·설명이 나오고 손님이 "Ahh, makes sense" | 설명하면 팁↑, 벌 X |
| ② 밀리는 일 | **대기 의자**에 앉은 손님이 시계 대신 **잡지·커피** 반응. 시간 별점 깎기 X | 기다림에 벌 X |
| ③ 부품 기다림 | 부품 선반이 비면 **"Parts truck arrives soon!"** 연출(작은 트럭이 지나감). 기다리는 동안 **다른 차 먼저 해도 됨** | 일을 막지 않음, 선택형 |
| ④ 같은 문제가 다시 옴 | FC §3 단골 "It died again!" 이야기와 이미 같음 — 벌이 아니라 이야기 | 이미 있음 |
| ⑤ 필요 없는 일 권유 | **'안전 먼저' 점검표**로 권유가 아니라 보여 주기 — 필요 없는 부품을 권하는 선택지는 만들지 않음 (게임 안 '권유 판매' 보상 X) | 윤리 점수 개념 도입은 어린이에겐 무거움 (추정) |
| ⑥ 우리가 그랬다 | 접수 때 **한 바퀴 둘러보기**: 차 앞에서 '긁힌 곳 사진' 카드 | 07견적 #6, 사람 시험 뒤 |

### ③-5 부품 기다림 아이디어 (parts-wait)
- 진짜: 부품 카운터에서 배달, 전체의 약 75 %는 60분 이내 (검색 요약, Babcox 연도 불명) [21]; 못 구하면 며칠~몇 달 (전자 부품) [21].
- 게임 제안: **'부품 상자 배달'** = 보통 부품은 선반에 있고, 희귀·시대 차 부품만 **주문 → 그 사이 다른 차**. 복원 베이(ECO Lv8)·시대 차(`era_cars`)와 맞음. 기다림 동안 보상 손해 X, **도착 알림 + 작은 배달 연출**만. 공개 뒤.

### ③-6 담당 세션 (제안)
| 일 | 담당 | 메모 |
|---|---|---|
| 점검표 카드 UI, 수리 주문서 | **wr-ui** | 한 장짜리, 폰 크기, 글자 적게 |
| 계절·날씨·단골 이벤트 규칙, 고장 가중치 | **wr-design** | FC §1b 변주 표에 '계절' 열 추가 |
| 에어컨·와이퍼·점검표 데이터, 날씨 코드 | **wr-dev** | 사람 시험 뒤, `Faults.luau` 변형 데이터 |
| 어드바이저 책상(카운터 + 모니터 + 단말기), 부품 트럭, 대기 의자 | **wr-builder** | 05투어의 카운터·단말기 소품 재사용 |
| 에어컨 부품·와이퍼 3D | **wr-3d** | CJV ③ 목록 이어서 |
| 사실 확인(주 검사·법 등) | **wr-carbook** | 이 문서 (확인 못 함) 항목 채우기 |

---

## 확인 못 한 것 (정직한 목록)
- 일 종류별 **매출·건수 비율**: 공개 자료 못 찾음 [1]. Ratchet+Wrench 2023 조사는 '무슨 차를 고치나'만(국산 80 %·수입 76 %·디젤 32 %·하이브리드 30 %·변속기 27 %·전기차 16 %) [2] — 일 종류가 아님.
- 일마다 **책 시간 숫자**: Mitchell1·ALLDATA 본문은 못 엶(유료). CJV·FC 값만 씀.
- 부품 배달 시간 **연도**·NAPA 공식 배달 정책: 못 찾음.
- 시운전(road test) 기준, 주인(owner) 역할, 부품 매니저 역할: 못 찾음.
- 미시간 한정 계절 수요(소금·녹, 겨울 타이어 전환 시기): 못 찾음. 알래스카 사례 [18]는 비슷한 '몰림'의 근거일 뿐 미시간 숫자 아님.
- AAA 공임 설명 페이지·Michigan 법 원문(legislature.mi.gov)·Tire Review 'comeback' 글: 열리지 않음 → 법·comeback은 (검색 요약).

## 출처 (이번에 직접 연 것 = 1~18, 검색 요약만 = 19~35)
1. FenderBender — Examining your sales mix can confirm if you're doing it right ("예방 정비 매출 목표 30 %, 대부분 5~12 %") — https://www.fenderbender.com/running-a-shop/finance/article/33028493/examining-your-sales-mix-can-confirm-if-youre-doing-it-right
2. Ratchet+Wrench — Numbers: What Are You Working On? (2023 산업 조사, 차 종류 비율) — https://ratchetandwrench.com/running-a-shop/operations/article/33016619/numbers-what-are-you-working-on
3. Wikipedia — Vehicle inspection in the United States (주별 안전·배출가스 검사, Michigan 없음) — https://en.wikipedia.org/wiki/Vehicle_inspection_in_the_United_States
4. BLS — Automotive Service Technicians and Mechanics (중간 연봉 $50,620, 시간제 또는 일 양에 따른 지급, 약 82만 5천 명, 윤활 일꾼 입문) — https://www.bls.gov/ooh/installation-maintenance-and-repair/automotive-service-technicians-and-mechanics.htm
5. Vehicle Service Pros — AAA survey: most U.S. drivers don't trust auto repair shops (기사 2016-12-06: 76 %·73 %·63 %·49 %, 64 % 믿는 가게) — https://www.vehicleservicepros.com/industry-news/press-release/20845948/AAA.com/autorepair
6. AutoLeap — Hourly Rate vs Flat Rate: How Auto Mechanics Are Paid (책 시간, 기술자 단가 30~50 %, 진단은 시간제, 장단점) — https://autoleap.com/blog/hourly-rate-vs-flat-rate-how-auto-mechanics-are-paid/
7. Motorist.org — 10 Green Flags of a Trustworthy Auto Repair Shop (설명·서면 견적·증거·압박 X) — https://motorist.org/10-green-flags-of-a-trustworthy-auto-repair-shop/
8. Vehicle Service Pros — Seven basic steps of the auto repair process (접수·점검·견적·허락·진행·마무리·사후 연락, 5 % 규칙) — https://www.vehicleservicepros.com/shop-operations/service-repair/blog/21021756/seven-basic-steps-of-the-auto-repair-process
9. Car Care Council — Car Care Tips (가을 배터리 시험·난방·와이퍼, 겨울 와이퍼 6개월, 산불 철 필터, 10분 점검, 변속기액 24,000~36,000 mi) — https://carcare.org/car-care-tips/
10. CBS Philadelphia — AAA receives over 1,000 calls for dead car batteries due to cold weather (2017-01: 2,300 중 1,068, 32°F 35 %·0°F 60 %) — https://www.cbsnews.com/philadelphia/news/aaa-dead-car-batteries
11. KATU — Heat is the #1 cause of car battery failure, AAA says — https://www.katu.com/news/local/heat-is-the-1-cause-of-car-battery-failure-reduced-battery-life-aaa-says
12. AAA Auto Club Group newsroom — AAA offers safety tips for dealing with potholes (타이어·휠·얼라인먼트·서스·쇼바 피해, 평균 약 $600(2021), 해빙 순환, 미시간 3월) — https://newsroom.acg.aaa.com/aaa-offers-safety-tips-for-dealing-with-potholes/
13. Kelley Blue Book — Brake fluid flush costs (평균 $173~205) — https://www.kbb.com/service-repair-guide/brake-fluid-flush-costs/
14. Kelley Blue Book — Transmission fluid change (교환 $150~175, flush $165~290, 수동 30,000~60,000 mi) — https://kbb.com/transmission-fluid-change/
15. Kelley Blue Book — Power steering fluid flush costs ($172~204) — https://www.kbb.com/service-repair-guide/power-steering-fluid-flush-costs
16. ThePricer — AC / Freon recharge cost ($283~366, 컴프레서·콘덴서 값, 냉매 종류) — https://www.thepricer.org/ac-freon-recharge-cost/
17. PartsTech — Shop Stats: How has customer behavior changed (OEC 정비소 약 700곳 조사, 2026-04 발표: 50 % 미루거나 거절, 49 % 더 조심, 차의 약 80 %가 5만~15만 mi) — https://partstech.com/resource/blog/how-has-customer-behavior-changed-in-the-last-year/
18. KDLL — For one tire store, first snow brings a flurry of business (알래스카 2022: 10~11월 6~8주 = 연 매출 30 %) — https://www.kdll.org/local-news/2022-10-28/for-one-tire-store-first-snow-brings-a-flurry-of-business
19. (검색 요약) Michigan MCL 257.1332 서면 견적·동의·10 % 또는 $50 중 적은 쪽 규칙, MCL 257.1334a $50 미만 — 검색에서 법 원문 PDF 목록(https://hercules-milenia.legislature.mi.gov/documents/mcl/pdf/MCL-257-1332.pdf)이 나왔으나 열지 않음
20. (검색 요약) ALLDATA 점검표 색 의미 — https://www.alldata.com/ca/en/support/inspections/article/completing-inspection ; Payne Auto Group 블로그 — https://payneautogroup.com/blog/?p=1352 ; Shopmonkey 점검 보고서 — https://support.shopmonkey.io/hc/en-us/articles/44632022471060-Vehicle-Inspections-Summary-Report
21. (검색 요약) IMR 2021 독립 정비소 500곳 조사 부품 지연; Babcox 75 % 60분 이내 — https://www.aftermarketnews.com/the-pulse-how-long-does-it-take-for-your-local-parts-source-to-deliver/ (열기 403)
22. (검색 요약) 진단비 약 $100~130, 공제 관행 — RepairPal 견적기 — https://repairpal.com/estimator/ford/explorer/check-engine-light-diagnosis-testing-cost
23. (검색 요약, 낮은 품질) 주 검사 값·시간 — https://carregistrationfee.com/articles/safety-inspection-by-state , https://cartipsdaily.com/how-long-does-a-state-inspection-take
24. (검색 요약) comeback 비율 5 % 이하 — Tire Review https://www.tirereview.com/back-for-more-correcting-the-comeback-before-it-happens-can-save-profit-dollars/ (열기 403), Transmission Digest https://www.transmissiondigest.com/what-went-wrong-and-why-root-cause-failure-analysis/
25. (검색 요약) 기술자 급(A·B), 루브 기술자, 포터·부품 입문 — https://www.ventavid.com/glossary/technician-levels , https://www.pittstate.edu/automotive/_files/documents/at-career-paths.pdf
26. (검색 요약) FTC 자동차 수리 안내 — https://bulkorder.ftc.gov/system/files/publications/pdf-0078-auto-repair.pdf ; California 소액 재판 안내 — https://sanmateo.courts.ca.gov/self-help/small-claims-self-help/small-claims-automotive-repair-rights
27. (검색 요약) 서비스 어드바이저 구인 글 여러 건 — 예: https://recruiting.paylocity.com/Recruiting/Jobs/Details/3345393 (딜러 중심, 가게마다 다름)
28. (검색 요약, 낮은 품질) 서비스 어드바이저 커미션 — https://www.autoshopowner.com/forums/topic/9896-what-and-how-do-you-pay-your-service-writer
29. (검색 요약, 낮은 품질) 타이어 장착·밸런스 값 — https://mechanicbase.com/tires/tire-mount-balance-cost/
30. (검색 요약, 낮은 품질) 머플러 값·시간 — https://www.thepricer.org/car-exhaust-install-cost/
31. (검색 요약) 더운 날 에어컨·과열 — https://cbsaustin.com/news/local/car-problems-to-watch-for-during-the-extreme-summer-heat
32. (검색 요약) Car Care Council 출발 전 점검(필터·액·벨트·호스·타이어·배터리·브레이크, VIN 리콜) — https://www.counterman.com/car-care-council-video-explains-importance-of-pre-trip-vehicle-checks/ ; 4월 Car Care Month 무료 점검 — https://www.tuffy.com/news_room/tuffy-celebrates-national-car-care-month
33. (검색 요약) 검사 없는 주 목록 — https://www.slashgear.com/1753337/states-that-do-not-require-car-inspections
34. (검색 요약, 영국 자료) Bumper/AutoBI — 빨강 문제에서 70 % 일부만 승인 — https://www.autotrainingcentre.com/blog/why-some-auto-repairs-arent-approved/ 근처 검색 결과
35. (검색 요약) BBB 자동차 수리 불만 약 3만 5천 건/년, 놀라운 요금·지연·반복 수리 — https://spectrumnews1.com/ca/la/business/2026/07/29/prime-automotive-concerns
