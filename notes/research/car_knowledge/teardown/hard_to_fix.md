# 고치기 어려운 차 — 진짜로 왜 어렵나 (wr-carbook, 2026-10-22)

> 사용자: "레벨이 오를수록 더 어려운 차들이 와야돼 고치기 더 어려운 차!" · "우리의 게임성은 현실적인 거에 있으니까".
> 이 파일 = **현실에서 정비사가 '어렵다'고 하는 이유**와 **쉬운 일 → 어려운 일 순서**. 설계(★ 단계·보상)는 wr-design `car_difficulty.md`가 정해요 — 여기 '게임으로 옮기면'은 제안만.
> 출처 번호는 맨 아래. "(검색 요약)" = 검색 결과 요약만 본 것, "(포럼)" = 정비사·차 주인 개인 경험.

## 0. 한눈에
정비사들이 '어려운 차·어려운 일'을 말할 때 **되풀이되는 이유 8가지** [J1][D1][A1][M1]:
1. **좁고 묻혀 있음** — 부품 하나 꺼내려고 다른 걸 잔뜩 떼야 함.
2. **작은 일에 큰 분해** — 앞을 통째로, 흡기를 통째로, 심지어 **캡(운전석 칸)을 통째로** 들어냄.
3. **녹** — 흔한 일이 긴 일이 됨(볼트가 안 풀리거나 부러짐).
4. **전기·전자·소프트웨어** — 진단이 어렵고, 딜러 전용 장비·등록·보정이 필요.
5. **전용 공구·특수 나사** — 타이밍 고정 공구, 트리플 스퀘어 비트 등.
6. **무겁고 복잡한 구동계** — AWD·4WD, 변속기, 프레임 트럭.
7. **고장이 줄줄이** — 하나 고치면 다른 게 나옴, 고장이 다른 고장을 만듦.
8. **옛 차·드문 차** — 부품을 구하기 어렵고, 아는 사람이 적음.
→ 게임 제안: 차 '어려움' = 이 8가지를 **차마다 몇 개 얹느냐**. ★1 차는 0개, ★5 차는 3~4개.

## 1. 이유별 — 진짜 예와 정비소가 하는 일
### 1-1. 녹 (rust belt — 겨울에 길에 소금 뿌리는 지역, 디트로이트 포함 → `../detroit.md`)
| 무엇이 | 진짜 예 | 정비소가 하는 일 | 시간 |
|---|---|---|---|
| 브레이크 관 | 차 밑을 지나 물·눈·소금에 녹슴. 이음 너트가 둥글게 뭉개짐 [R1][R2] | 녹 제거 스프레이 → 열 → **플레어 너트 렌치**에 짧게 탁 치기 → 이미 뭉개졌으면 바이스 그립 [R2]. 다른 데도 심하게 녹았으면 "차값보다 비쌀 수 있음" [R1] | 한 토막 DIY 약 1시간 [R2] / 차 전체 관 새로 = "엄두가 안 나는 일"(ABS 차) [R1] |
| 배기 스터드·산소센서 | 매니폴드 일에서 스터드가 "20% 확률로 부러짐", 부러지면 보통 쌍으로 [R3](포럼) | 부러진 토막에 **너트를 용접**해 돌리기가 제일 확실 [R3](포럼). 주철은 MAPP 토치로 안 데워지고 산소+MAPP는 됨 [R3](포럼). 머플러 가게는 잘라내고 새 관 용접(약 $100) [R3](포럼) | — |
| 서스펜션 볼트 | 시카고 맥시마 뒤 쇼바: 1~2시간 일 예상 → 녹 제거제 30분, 1/2" 임팩트, 3 ft 브레이커 바, 토치, 망치 → **3시간 실패**, 다음 날 열+망치로 20분 만에 풂, 반대쪽은 가게에 $150 [R4](포럼) | 순서: **녹 제거 스프레이 → 임팩트·브레이커 바 → 열(토치·인덕션 히터) → 자르기·드릴·용접** [R4][R5] | 인덕션 히터: 너트 15~20초 가열(제조사 말, 토치보다 빠르고 고무 볼조인트 안 태움) [R5] |
| 프레임 | 토요타 타코마(2005-10 위주) 프레임 녹 → 최대 $3.4B 합의, 약 150만 대, 검사한 것의 약 15%가 프레임 교체, 대당 $15,000 잡음 [R6] | 프레임 통째 교체 = "비싸고 오래 걸리고 손 많이 감" [R6] | — |
- **공임표(book time)는 '녹 없는 깨끗한 차' 기준** [R7](검색 요약) → 녹 차는 실제 시간이 공임표보다 길어짐 = 정비사 손해(§3 플랫레이트).

### 1-2. 좁은 엔진룸·묻힌 부품
| 차 | 왜 어렵나 | 시간 |
|---|---|---|
| **가로 V6 뒤쪽 점화플러그** — 크라이슬러 3.6 펜타스타 | 뒤 줄(방화벽 쪽) 플러그 = **위 흡기(plenum) 떼야 함**: 진공관·흡기관·센서, 8 mm 볼트 7개(일부 T30 토크스)·10 mm·13 mm 브래킷 볼트 → 그다음 코일 [C1] | 판매점 추정 2.5~3.5 h(차종별), 가게 $342~501 [C1](검색 요약) |
| 토요타·렉서스 3.5 V6(2GR 계열 — **캠리 V6도 이 엔진**) | 뒤 줄 플러그는 흡기 떼야 함, "흡기 안 떼고는 가망 거의 없음" [C2](포럼, 검색 요약) | 약 2.5 h [C2] |
| 닛산 VQ35 | 뒤 줄은 매니폴드 떼기, 공임표 2.3 h·난이도 "C" [C3](포럼) | 3.5~4 h(판매점 추정) [C3] |
| 포드 3.5 V6 | 뒤 줄은 위 흡기 떼기 [C4](검색 요약) | DIY 약 2.5 h [C4] |
| 스바루 박서(수평대향) | 플러그가 프레임 옆에 붙어 있음, 운전석 뒤 플러그가 제일 어려움: 한쪽은 에어박스, 다른 쪽은 배터리 빼야 [C5](검색 요약) | 약 2.5 h (반대로 Haynes WRX는 "쉬움 2/5, 2 h") [C5][H5] |
| 닷지 스트라투스 | **배터리가 범퍼 뒤** — 차 들고 바퀴·안쪽 펜더 떼고 배터리 [J1] | — |
| AMC 페이서 | 플러그 2개가 방화벽 속 [J1] | — |
| LT1 카마로 | V6 자리에 V8 — 플러그 갈다 "신경이 다쳤다"는 댓글 [J1] | — |
| 포드 F-250 디젤(6.0 파워스트로크) | 큰 일은 **캡(운전석 칸)을 프레임에서 들어냄**(댓글) [J1]. 헤드 개스킷 공임표 22.1 h(4x4 자동), 딜러 견적 40 h [C6](포럼, 검색 요약). DIY 한 주인 50~60 h + 부품 $2,500(오일쿨러만 8 h) [C7] | 매우 김 |
| BMW N20 타이밍 체인 | 체인은 앞이지만 **오일팬을 떼야 함** → 엔진 마운트 풀고 엔진 들기 + BMW 전용 공구 3개 [C8] | 딜러 10~15 h, DIY "최소 이틀" [C8] |
| BMW N47 디젤 | 체인이 **엔진 뒤**(변속기 쪽) → 보통 엔진·변속기 내림 [C9](검색 요약) | 전문점 $2,000~4,000 [C9] |
| 아우디(옛 A4 등) | 타이밍 벨트 = **앞 범퍼·라디에이터 지지대를 앞으로 빼는 '서비스 위치'** [C10](포럼) | 8~10 h(독립 정비소) [C10] |
| **캠리 XV70(우리 기준 차)** | 라디에이터 = 위로 빼는데 그 전에 헤드라이트·범퍼 보강재·보닛 잠금장치·에어클리너까지 [K1] / 헤드라이트 = 범퍼 먼저 [K1] / 시동모터 = 배터리·받침·에어클리너 먼저 [K1] | (`sedan_teardown.md` 표) |

### 1-3. AWD·4WD·프레임 트럭
- AWD는 **트랜스퍼 케이스(PTU) + 뒤 디퍼렌셜(전자 클러치) + 드라이브샤프트 + 뒤 구동축 2개**가 더 있음. 오일·브레이크·벨트·플러그는 FWD와 비슷, **기어오일 2곳**(약 $200~300)과 **뒤 휠 베어링**은 일이 더 많아 비쌈 [W1].
- 변속기 내리기: FWD 약 7~10 h(트랜스액슬 + 주변 많이), RWD 약 4~8 h, AWD/4x4 더 김 [W2](검색 요약, 낮은 품질 사이트). 한 정비사 공임표 8.6 h [W3](포럼).
- 프레임(body-on-frame) 트럭: 차체가 모듈이라 오히려 고치기 쉽다는 말도 있음 [W4] — 하지만 **프레임 녹**이 크고 비싼 고장(§1-1 타코마) + 판스프링 걸이 녹(볼트로 고침) [W5](포럼). → 게임: 픽업 = 부품이 **크고 무겁고**(공구·리프트 필요) **녹 확률 높음**, 구조는 단순.

### 1-4. 전기·간헐 고장 (가장 '머리'가 어려운 일)
- 정비사 말: **"진단이 실제 수리보다 훨씬 어렵다."** [E1](포럼)
- 간헐 캠 센서 고장 예: **진단 2시간**(시험 주행·재시험) + **교체 10분** → 그래서 가게가 진단비를 받음 [E2]. 진단비 = 보통 공임 1시간(RepairPal $122~233, 수리하면 빼 주기도) [E3](검색 요약).
- **방전(parasitic drain)** [E4]: 모듈이 잠들 때까지 **약 75분** 기다림 → 잠든 뒤 **50 mA 이하가 정상**, 1 A 미만이면 며칠, 1 A 넘으면 하룻밤에 방전. 방법: 배터리 먼저 시험 → 전류계 직렬 → **퓨즈를 하나씩 빼며** 전류 떨어지는 곳 찾기 → 퓨즈 안 거치는 회로는 배선도. 함정: 모듈끼리 서로 깨워서 범인이 옮겨 다님, 퓨즈를 빼는 것 자체가 깨움.
- **CAN 통신 고장**: "원인이 바로 안 보임" — 전체 스캔 + 오실로스코프(CAN 선 쉬는 전압 약 2.5 V) + 브레이크아웃 박스. 원인 = 접지 쇼트, 선끼리 쇼트, 종단 저항 빠짐, **커넥터 부식** [E5].
- **접지 부식**: 저항만 재면 '정상'으로 나오기도 → **전기 흘리며 전압 강하** 재기(0.1~0.2 V 넘으면 불량), 접지 하나가 엉뚱한 증상 여러 개 + 아무 코드 [E6](검색 요약).
- → 게임 제안: ★4~★5 '숨은 고장' = 스캐너만으로는 안 나오고 **멀티미터(전압 강하)·퓨즈 빼기 순서** 미니게임. "진단 시간도 돈" — 진단비 항목.

### 1-5. 고장이 줄줄이 (여러 고장·이어지는 고장)
- **과열 → 헤드 개스킷**: 개스킷이 새면 연소 가스가 냉각수로 → 냉각 더 나빠짐 → 더 과열 → 더 샘(스스로 커지는 고리), 심하면 냉각수가 실린더로 들어가 **엔진이 멈춤(하이드로락)**. 개스킷은 싸고 공임은 큼 [F1].
- 과열 시작은 작은 것: 워터펌프·서모스탯·막힌 라디에이터·팬 [F2](검색 요약) → **싼 호스 하나가 헤드 일로 커짐**.
- **타이밍 벨트 끊김(간섭 엔진)** → 밸브 휨, 피스톤까지 맞으면 엔진 재조립·교체 [F3].
- **같이 하는 일**: 타이밍 벨트 키트 = 벨트 + 텐셔너 + 아이들러 + **워터펌프**(벨트 일 할 때 같이) [F4]. 같이 하는 단계는 공임 두 번 받으면 안 됨 [F5](포럼).
- "엔진 바꾸려다 차 전체를 뜯게 됨"(일이 커짐) [E1](포럼). 메르세데스 CLA250: "고쳐도 고쳐도 문제가 또" [A1].
- → 게임 제안: ★3+ 차는 **고장 2~3개가 원인-결과로 묶임**(예: 막힌 라디에이터 → 과열 → 서모스탯 손상), 하나만 고치면 며칠 뒤 다시 옴(평판 −). '같이 하면 싼 일' 추천 = 숙련 보너스.

### 1-6. 옛 차 vs 아주 새 차
**옛 차·클래식** [O1][O2][O3][O4]
- 카뷰레터 = 센서 없이 **손으로 맞춤**(제트·고도), 포인트 점화 = 닳아서 **간격·드웰·타이밍**을 주기적으로 맞춤, 마스터 실린더 통 1개짜리 = 한 곳 새면 브레이크 전부 잃음, 인치/미터 나사 섞임, 에탄올이 옛 연료관을 녹임 [O1].
- 진단 도구가 다름: 드웰 미터·진공 게이지·누설 시험기 [O1]. **OBD-II는 1996년부터 미국 의무**, 그 전엔 회사마다 단자·코드가 다르고 엔진등 깜박임 횟수로 코드 [O3].
- 아는 사람이 적음: 카뷰레터 아는 정비사를 못 구해 문 닫은 박물관 [O2]. 부품이 귀함: 포르쉐 928 속도계 최대 $800 [A1].
- → 게임(era_cars와 연결): 시대 차 = **스캐너 안 됨**(꽂을 데 없음) → 귀·눈·전용 옛 공구(타이밍 라이트·드웰 미터)로.

**아주 새 차** [N1][N2][N3][N4][N5]
- **ADAS 보정**: 앞유리 갈면 약 $300 일이 $1,000+로(카메라 떼고·소프트웨어·보정), AAA는 수리비 최대 37% 더 [N1]. 보정이 필요한 때 = 앞유리 교체, 충돌 수리, 얼라인먼트·타이어 크기 변경, 범퍼·그릴 레이더 주변 일, 서스펜션 변경 [N2]. 보정비 미국 약 $150~650 [N3](검색 요약). **캠리 XV70도 앞유리 갈면 앞 카메라 보정**, 앞 범퍼 떼면 레이더 조정, 거울 떼면 옆 카메라 조정 [K2][K3][K4].
- **전자식 주차 브레이크(EPB)**: 뒤 패드 갈려면 **스캔툴로 '정비 모드'** — 피스톤을 모터로 뒤로 물리고, 끝나면 다시 맞춤. 안 하면 부품 망가짐 [N4]. (캠리 XV70도 EPB 버전 따로 있음 [K5])
- **보안 게이트웨이**: FCA(크라이슬러 계열) 2018+ = 등록 안 한 장비는 지우기·작동 시험 막힘(읽기는 됨), 등록 연 약 $50(판매사 말) [N5]. 닛산 = 딜러 소프트웨어가 필요한 수리 많음 [M1](포럼 요약).
- → 게임: 새 차 ★ = 부품 교체는 쉬워도 **마지막 '보정' 단계 + 비싼 스캐너**가 필요.

### 1-7. 전용 공구·특수 나사
- 타이밍 벨트 = 엔진마다 다른 **고정 공구** + 매뉴얼 필수, Haynes 난이도 4/5 [H8]. BMW N20 체인 = 전용 공구 3개(타이밍 키트·플렉스플레이트 고정·밸런스축 실 공구) [C8].
- 클러치 = **미션 잭 + 클러치 정렬 공구** [H9]. 브레이크 패드 = 피스톤 되감기 공구 [H3]. 브레이크 관 = 플레어 키트·플레어 너트 렌치·튜브 커터·벤더 [R2].
- **트리플 스퀘어(XZN)** = BMW·벤츠·폭스바겐 계열 12각 나사, 센 볼트에 씀, 틀린 비트는 머리를 망가뜨림 [T1].
- 스프링 압축기 = "보기보다 위험", 압축 풀기 전에 위 너트를 빼면 스프링이 튀어나감 [T2](검색 요약) → `tools_real.md` 위험 공구.

### 1-8. 하이브리드·전기차 (높은 전압)
- 고전압 선 = **주황색**. 팩 전압 = 혼다 인사이트 144 V, 프리우스 2세대 201.6 V, 새 전기차 400~924 V. 직류 약 55~60 V부터 위험 [V1].
- 작업 전: **서비스 플러그 뽑기 → 기다리기**(인버터 콘덴서 방전 — 토요타 약 5분, 렉서스 10분+, 다른 자료 15분 [V1][V2](검색 요약)), 스마트키는 20 ft 밖, 프리우스는 꺼진 것 같아도 엔진이 다시 켜질 수 있음 [V1].
- **절연 고무장갑 Class 0**(직류 1,500 V까지, 6개월마다 검사) [V3]. 정비사들이 싫어하는 이유: 차종별 교육, 감전 위험, 오래 걸림, 비싼 장비 [V4].
- → 게임(먼 업데이트): 주황 선 = 장갑 없이 만지면 안 됨, 서비스 플러그 뽑고 타이머.

## 2. 쉬운 일 → 어려운 일 (정비사·매뉴얼 순서)
**Haynes 난이도(1~5)와 시간** — 사다리로 제일 좋은 자료 [H1~H9]:
| 일 | Haynes | 시간 | 우리 게임 ★ 제안 |
|---|---|---|---|
| 와이퍼 날 | 1 | 5~25분 [H1](검색 요약) | ★1 (길가 일) |
| 배터리 | 1 | 약 30분 [H2] | ★1 |
| 엔진오일·필터, 에어필터 | (DIY 조사 '쉬움') | 오일 10~15분 [P2] | ★1 |
| 앞 브레이크 패드 | 2 | 45분~1.5 h [H3] | ★2 |
| 보조 벨트(서펜타인) | 2 | 45분~1.5 h [H4] | ★2 |
| 점화플러그(4기통) | 2 | 약 2 h(WRX) [H5] | ★2 (V6 뒤 줄 = ★4) |
| 워터펌프(벨트 일과 같이) | 2 | 1.5~5 h [H6] | ★3 |
| 시동모터 | 3 | 1~4 h [H7](검색 요약) | ★3 |
| 스트럿 | "경험 필요" | 바퀴당 약 1 h + 얼라인먼트 [T3](검색 요약) | ★3 (스프링 압축기) |
| 타이밍 벨트 | 4 (차에 따라 5) | 1.5~4 h | ★4 |
| 클러치 | 4 | "가장 손 많이 가는 일 중 하나", 변속기 내림 [H9] | ★4~★5 |
| 헤드 개스킷·엔진·변속기 내리기 | — | 변속기 8.6 h(공임표, 포럼) [W3] / 6.0 디젤 헤드 22 h+ [C6] | ★5 |
- 미국 DIY 조사(AASA): **쉬움** = 배터리·냉각수 보충·에어필터, **중간** = 브레이크 패드·슈, **어려움** = 인젝터·워터펌프 [P1].
- 정비사 포럼 순서: 오일·타이어 로테이션 → 브레이크·튠업 → 벨트·액·필터 → 서스·구동 → **엔진·변속기 내리기** / 에어컨은 DIY 금지(냉매 회수), 얼라인먼트 DIY "No", **판금이 제일 어려움** [E1](포럼).
- 흔한 공임(포럼): 패드 축당 1~2 h, 패드+디스크 약 1~1.2 h, 타이밍 벨트 3.7~4.4 h, 발전기 1.8 h(혼다), 벨트 일 때 워터펌프 +0.3~0.5 h, 클러치 평균 약 4 h(3~7.5 h) [P3][P4][P5](검색 요약).

## 3. 정비사가 '어려운 차'를 싫어하는 진짜 이유 — 플랫레이트(flat rate)
- 미국 정비사 월급 = 대부분 **공임표 시간 × 시급**(실제 걸린 시간이 아님): 브레이크 일 공임표 2 h면 1 h 걸려도 3 h 걸려도 2 h어치 [S1]. 공임표 = Mitchell·ALLDATA·Chilton, 잘하는 정비사는 '효율 100%+' [S2](검색 요약).
- 그래서 **녹·부러진 볼트·긴 진단**은 정비사 손해(공임표는 깨끗한 차 기준 [R7]) — 신입은 시간당 벌이가 아주 낮아지는 '함정' [S2](검색 요약).
- → 게임 제안(재밌는 현실): 일감 카드에 **'공임표 시간(손님이 내는 돈)'**, 실제로 빨리 끝내면 남는 시간 = 이득, 녹 볼트가 나오면 시간이 늘어 손해 → 녹 제거제·인덕션 히터를 사는 이유가 생김.

## 4. 기술 분야 (ASE A1~A9) — 성장 나무 후보
A1 엔진 수리 · A2 자동 변속기 · A3 수동 구동계·차축 · A4 서스펜션·조향 · A5 브레이크 · A6 전기·전자 · A7 냉난방·에어컨 · A8 엔진 성능(진단) · A9 경차 디젤. **A1~A8 다 따면 '마스터 정비사'** [S3][S4](검색 요약).
→ 게임 제안: 레벨 = 이 분야가 하나씩 열림(★ 차의 계통과 짝). 예: A5 브레이크 먼저, A6 전기는 늦게.

## 5. 우리 게임용 '어려운 차' 재료 정리 (제안, wr-design이 정함)
| 재료(현실) | 차 예(오리지널로 섞을 것) | 게임에서 보이는 것 |
|---|---|---|
| 녹(소금 지역) | 오래된 픽업·프레임 차 | 볼트에 녹 표시 → 스프레이 기다리기 / 브레이커 바 / 열 / 부러지면 드릴·용접 |
| 좁은 엔진룸 | 가로 V6 세단·미니밴 | 같은 '플러그 교체'인데 뒤 줄은 흡기 먼저(층 하나 더) |
| AWD | AWD SUV | 구동축·트랜스퍼·뒤 디퍼렌셜이 더 있음(부품 수↑) |
| 프레임 트럭 | 픽업 | 부품이 무거움(잭·리프트·2명), 녹 많음 |
| 전기 숨은 고장 | 새 차·옛 차 둘 다 | 스캐너 '코드 없음' → 멀티미터·퓨즈 순서 |
| 줄줄이 고장 | 관리 안 된 차 | 고장 2~3개가 원인-결과 |
| 새 차 보정 | 최신 세단 | 마지막에 보정(스캐너 업그레이드) |
| 옛 차 | 시대 차(era_cars) | 스캐너 안 됨, 손으로 맞추기, 부품 귀함 |
| 전용 공구 | 유럽풍 오리지널 차 | 특수 비트·고정 공구 없으면 못 함 |
| 고전압 | 하이브리드(먼 업데이트) | 주황 선·장갑·타이머 |

## 출처
- J1 Jalopnik, "The Ten Hardest Cars To Work On" — https://jalopnik.com/the-ten-hardest-cars-to-work-on-1578975283 (본문 + 독자 댓글)
- D1 Daily Dot, 오스틴 정비사들이 꼽은 비싼 차(독일 차·닛산 CVT, 37단계 정비등 리셋) — https://www.dailydot.com/bmw-audi-volkswagen-mercedes-expensive-to-maintain
- A1 Auto Training Centre, 정비사가 싫어하는 차 4대 — https://www.autotrainingcentre.com/blog/auto-mechanic-dreads-working-4-cars/
- M1 MotorBiscuit, 정비사가 말하는 최악의 차 — https://www.motorbiscuit.com/mechanics-reveal-the-worst-cars-they-service-and-why-they-hate-them/
- R1 MOTOR, Brake line repairs (2018-04) — https://www.motor.com/magazine-summary/brake-shop-brake-line-repairs-april-2018/
- R2 Jalopnik, 녹슨 브레이크 관 갈기 — https://jalopnik.com/heres-how-you-can-replace-your-rusty-brake-lines-1763227864
- R3 (포럼, 검색 요약) 배기 스터드·산소센서: https://www.fiatforum.com/threads/siezed-o2-sensor.498067/post-4666367 · https://www.explorerforum.com/forums/threads/exhaust-manifold-stud-removal-tips.399621/ · https://stangnet.com/mustang-forums/threads/broken-exhaust-manifold-stud.680860/ · https://shoforum.com/threads/exhaust-manifold-studs-are-super-rusty-how-to-remove.47621/ · https://forum.ih8mud.com/threads/removing-02-sensors.875673/
- R4 (포럼) 맥시마 뒤 쇼바 녹 — https://forums.anandtech.com/threads/rust-rant-rear-shocks.2326321/post-35165946
- R5 Mini-Ductor(인덕션 히터) — https://www.catmag.co.uk/insight/removing-suspension-bolts-with-mini-ductor-venom · (검색 요약) https://www.fleetequipmentmag.com/cutting-fleet-repair-time-induction-heating/
- R6 The Truth About Cars, 토요타 프레임 녹 합의 — https://www.thetruthaboutcars.com/2016/11/toyota/
- R7 (검색 요약, 낮은 품질 거울 페이지) 공임표는 녹 없는 차 기준 — https://library.peoplespharmacy.com/labor-guide-auto-repair
- C1 YouCanic, 3.6 펜타스타 코일·플러그 — https://www.youcanic.com/wiki/ignition-coil-spark-plug-replacement-36l-pentastar-engine · (검색 요약) https://www.go-parts.com/garage/ps-2012-2020-dodge-grand-caravan-spark-plug
- C2 (포럼, 검색 요약) 2GR 플러그 — https://au.toyotaownersclub.com/forums/topic/24157-spark-plug-replacement/page/4 · https://clublexus.com/forums/es-5th-gen-2007-2012/786193-diy-spark-plug-change.html
- C3 (포럼, 검색 요약) VQ35 — https://maxima.org/forums/nissan-maxima-research/t-321826.html · https://www.go-parts.com/garage/ps-2013-2013-infiniti-jx35-spark-plug
- C4 (검색 요약) 포드 3.5 — https://www.go-parts.com/garage/engine-intake-manifold-ford-explorer-ford-taurus-ford-edge-2011-2015
- C5 (검색 요약) 스바루 플러그 — https://www.go-parts.com/garage/ps-2020-2024-subaru-forester-spark-plug
- C6 (포럼, 검색 요약) 6.0 파워스트로크 헤드 — https://www.ford-trucks.com/forums/showthread.php?p=9720903 · https://www.airforums.com/threads/ford-6-0-powerstroke-engine-problems-fixes.1307538/
- C7 Daily Dot, 파워스트로크 60시간 — https://www.dailydot.com/news/how-2k-and-60-hours-of-work-can-fix-a-ford-powerstroke/
- C8 FCP Euro, BMW N20 타이밍 체인 — https://www.fcpeuro.com/blog/how-to-replace-the-bmw-n20-timing-chain-part-1-removal
- C9 (검색 요약) N47 — https://good-garage-guide.honestjohn.co.uk/askhj/answer/73640/does-the-engine-need-taken-out-to-replace-the-dmf-and-timing-chain-in-a-bmw-5-series-2-0d-
- C10 (포럼, 검색 요약) 아우디 B5 타이밍 벨트 — https://audiworld.com/forums/s4-rs4-b5-platform-discussion-6/timing-belt-change-100k-miles-makes-me-nervous-1473192
- K1 이 폴더 `../diagrams/index.md`(캠리 라디에이터 removal-3647, 헤드라이트 removal-4262, 시동모터 메모)
- K2 캠리 앞유리 떼기 — https://www.tocamry.com/removal-4496.html
- K3 캠리 앞 범퍼 — https://www.tocamry.com/removal-4188.html
- K4 캠리 바깥 거울 — https://www.tocamry.com/removal-4342.html
- K5 캠리 뒤 브레이크(EPB 있음/없음) — https://www.tocamry.com/rear_brake_w_electric_parking_brake_system_-2507.html
- W1 TestingAutos, AWD vs FWD 정비 — https://www.testingautos.com/AWD-vs-FWD-maintenance.html
- W2 (검색 요약, 낮은 품질) 변속기 공임 — https://engineerfix.com/how-many-labor-hours-to-replace-a-transmission-2/
- W3 (포럼) 변속기 8.6 h — https://forums.corvetteactioncenter.com/threads/how-much-time-to-remove-replace-trans.76548
- W4 RealTruck, 유니바디 vs 프레임 — https://realtruck.com/blog/unibody-vs-body-on-frame-whats-the-difference/
- W5 (포럼, 검색 요약) 판스프링 걸이 녹 — https://www.therangerstation.com/forums/threads/frame-repair-leaf-hanger.196551/
- E1 (포럼) Garage Journal DIY 일 순서 — https://www.garagejournal.com/forum/threads/diy-mechanic-task-list.408915/
- E2 Ratchet+Wrench, 진단비 받기 — https://www.ratchetandwrench.com/articles/1021-get-paid-for-diagnostics
- E3 (검색 요약) 진단비 — https://www.brakeandfrontend.com/time-and-a-half/
- E4 MOTOR, 방전 진단 — https://www.motor.com/2021/06/diagnosing-a-battery-drain/
- E5 Vehicle Service Pros, 간헐 CAN 코드 — https://www.vehicleservicepros.com/service-repair/diagnostics-and-drivability/article/21270313/diagnosing-intermittent-can-codes
- E6 (검색 요약) 접지 전압 강하 — https://open-exam-prep.com/study-guides/ase-a6/general-electrical-diagnosis/circuit-faults-diagnosis
- F1 Wikipedia, Head gasket — https://en.wikipedia.org/wiki/Head_gasket
- F2 (검색 요약) 헤드 고장 원인 — https://www.fridayparts.com/blog/10-common-reasons-for-cylinder-head-failure
- F3 Wikipedia, Interference engine — https://en.wikipedia.org/wiki/Interference_engine
- F4 Haynes, 타이밍 벨트 — https://uk.haynes.com/pages/repair-guides-change-timing-belt-car
- F5 (포럼) 겹치는 공임 — https://shoforum.com/threads/do-these-prices-sound-right.9449/
- O1 Wilson Auto, 클래식 차 정비 — https://wilsonauto.com/why-classic-auto-repair-requires-a-specialized-shop/
- O2 The Drive, 카뷰레터 정비사를 못 구한 박물관 — https://www.thedrive.com/news/classic-car-museum-closing-because-nobody-can-work-on-carburetors-anymore-now-the-collections-for-sale
- O3 Wikipedia, On-board diagnostics — https://en.wikipedia.org/wiki/On-board_diagnostics
- O4 Wikipedia, Contact breaker — https://en.wikipedia.org/wiki/Contact_breaker
- N1 FenderBender, ADAS와 유리 — https://fenderbender.com/running-a-shop/operations/article/55311904/adas-and-collision-repair-the-growing-intersection-of-glass-repair-and-body-shops-in-todays-high-tech-vehicles
- N2 Caliber, ADAS 보정 — https://www.caliber.com/services/auto-glass/everything-you-need-to-know-about-adas-calibration
- N3 (검색 요약) 보정비 — https://glassdoctor.com/node/14264
- N4 Auto Training Centre, EPB 정비 모드 — https://www.autotrainingcentre.com/blog/electronic-parking-brake-service-mode-ev-brake-work/ · ECS Tuning BMW — https://blog.ecstuning.com/bmw-rear-brake-pad-replacement-with-electronic-parking-brake/
- N5 Vehicle Service Pros, 크라이슬러 보안 게이트웨이 — https://www.vehicleservicepros.com/service-repair/article/53084465/chrysler-secure-gateway-2020-12-15
- T1 Wikipedia, Spline drive(XZN) — https://en.wikipedia.org/wiki/Spline_drive
- T2 (검색 요약) 스프링 압축기 위험 — https://wiki.hsbne.org/tools/automotive/spring_compressors
- T3 (검색 요약) Haynes 쇼바·스트럿 — https://us.haynes.com/blogs/tips-tutorials/overview-how-change-your-shock-absorber-or-suspension-system
- V1 AA1Car, 하이브리드 위험 — https://www.aa1car.com/library/hybrid_hazards.htm
- V2 (검색 요약) 기다리는 시간 — https://pmmonline.co.uk/technical/hybrid-vehicle-servicing-part-2/
- V3 I-CAR, 장갑 등급 — https://rts.i-car.com/crn-10.html
- V4 AOL, 정비사가 하이브리드를 싫어하는 이유 — https://www.aol.com/lifestyle/real-reason-mechanics-hate-hybrid-172029178.html
- H1 (검색 요약) Haynes 와이퍼 — https://reader.haynes.com/en-gb/cars/ford/transit/2006-2013/wiper-blade-replacement/
- H2 Haynes 배터리(코롤라) — https://us.haynes.com/pages/repair-guides-change-battery-car-toyota-corolla
- H3 Haynes 앞 패드 — https://us.haynes.com/pages/repair-guides-change-front-brake-pads-car-chevrolet-cruze
- H4 Haynes 보조 벨트 — https://us.haynes.com/pages/repair-guides-change-accessory-belt-car-ford-fiesta
- H5 Haynes 점화플러그 WRX — https://us.haynes.com/pages/repair-guides-change-spark-plugs-car-subaru-wrx
- H6 Haynes 워터펌프 아웃백 — https://us.haynes.com/pages/repair-guides-change-water-pump-car-subaru-outback
- H7 (검색 요약) Haynes 시동모터 타호 — https://reader.haynes.com/en-us/cars/chevrolet/tahoe/2015-2016/starter-motor-replacement/
- H8 = F4 Haynes 타이밍 벨트
- H9 Haynes 클러치 — https://us.haynes.com/pages/repair-guides-change-clutch-car
- P1 FenderBender, AASA DIY 조사 — https://www.fenderbender.com/running-a-shop/shop-customers/article/33033540/aasa-automotive-aftermarket-study-market-shifting-away-from-diy
- P2 UroTuning, 쉬운 DIY 10가지 — https://www.urotuning.com/blogs/news/the-top-10-diy-car-repairs
- P3 (포럼, 검색 요약) 패드 공임 — https://ericthecarguy.com/forums/topic/pricing-jobs
- P4 (포럼, 검색 요약) 타이밍 벨트·발전기 공임 — https://audiworld.com/forums/audi-5000-200-v8-discussion-27/timing-belt-2182336
- P5 (검색 요약) 클러치 공임 — https://clickmechanic.com/jobs/clutch-replacement/alton
- S1 AutoLeap, 플랫레이트 — https://autoleap.com/glossary/flat-rate-pay
- S2 (검색 요약) 플랫레이트 효율·함정 — https://www.ventavid.com/glossary/flat-rate · https://www.toolsource.com/blog/is-flat-rate-pay-killing-your-earnings-what-every-young-technician-needs-to-know/
- S3 ASE A1~A9 — https://ase.com/tests/a1-a9/
- S4 (검색 요약) 마스터 정비사 — https://www.ase.com/test-series
