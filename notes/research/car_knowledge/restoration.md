# 폐차 감정 · 복원 · 중고차 판매 (Appraisal, Restoration & Used-Car Sales) — 2026-10-21

> Loop B(폐차장 차 사 오기 → 고치기 → 쇼룸에서 흥정해 팔기)의 근거 노트예요. 미국 동네 정비소 기준.
> 규칙: 출처를 **직접 열어 본 것**은 그냥 [n], 페이지가 막혀(403 등) **검색 결과 요약만 본 것**은 "(검색 요약)", 못 찾은 건 "(확인 못 함)".
> 도색 단계·녹 3단계·찌그러짐(PDR)·사포 번호는 이미 [11_body_paint.md](11_body_paint.md)에 있어요 → 여기선 **링크만** 걸어요.
> 엔진 구조·오일 소모·습식 압축 시험 기본은 [05_engine.md](05_engine.md) (파란 연기 줄).

## 한눈에 (3줄)
- **폐차 값 = 바닥값(쇠 무게) + 떼어 팔 부품(특히 촉매) − 숨은 병(녹·침수·엔진·뼈대)**. 서류(타이틀) 도장 하나로 값이 크게 바뀜.
- **복원 = 사진·봉투 정리 → 분해 → 벗기기 → 녹 잘라 용접 → 에폭시 → 퍼티 → 서페이서 갈기 → 칠 → 조립·기계 → 시운전**. 순서를 어기면 나중에 다 드러나요.
- **판매 값 = 상태 등급 + 주행거리·나이 + 사고/타이틀 이력 + 정비 기록 + 색·옵션 − 개조**, 그리고 흥정으로 마무리.

---

## 1. 폐차 감정 (Appraising a junk / salvage car)

### 1-1. 서류: 타이틀 종류 (Title brands)
미국은 차 소유 증명서(타이틀)에 **'도장(brand)'** 이 찍혀요. 주마다 정의가 조금씩 달라요 [5].

| 타이틀 | 뜻 | 게임에서 값 | 출처 |
|---|---|---|---|
| **Clean** (깨끗) | 도장 없음 | 기준값 100% | [5] |
| **Salvage** (샐비지) | 보험사가 **전손(total loss)** 처리한 차. 보통 수리비가 시가의 **약 70%** 를 넘으면 — 주마다 **50~95%** | KBB는 샐비지 차를 **"poor"로 보고 값을 안 매김**. 샐비지 차는 보통 추정 값보다 **65~75% 낮게** 매겨진다고 함 | [5] |
| **Rebuilt / Reconstructed** (재건) | 샐비지 차를 고쳐 **주(州) 검사 통과** → 다시 등록·운행 가능 | 같은 차 KBB "fair" 값의 **60~70%** | [5] |
| **Junk / Non-repairable / Parts only / Scrap** | **부품용·고철용만**, 도로용으로 다시 못 고침 | 쇠값 + 부품값만 | [5][6] |
| **Flood** (침수) | 물 피해로 샐비지 처리된 차(주별 정의) | 샐비지보다 더 의심 — 전기가 몇 년 뒤 고장 | (검색 요약 — SC DMV) [16] |

- 주 예시: **미시간** 시가의 75~90% 손상 = 샐비지, **91% 이상 = 'scrap' 타이틀만**(다시 못 올림). **오리건** 70% 이상 = 샐비지 [5].
- 오리건 규정의 '고철 쪽' 도장 이름들: Destroyed, Dismantled, Hulk, **Junk**, Non-rebuildable, **Non-repairable**, **Parts only**, **Scrap**, Crushed, Wreck — 여기에 **'salvage'는 안 들어감**(샐비지는 고칠 수 있는 쪽) [6].
- **타이틀 세탁(title washing)**: 도장 기준이 주마다 달라서 다른 주로 등록을 옮겨 도장을 지우는 것 [5]. 침수차가 '깨끗한 타이틀'·'분실 타이틀'로 나오면 조심하라고 NHTSA가 경고 (검색 요약) [16]. NICB는 무료 **VINCheck**로 보험사 신고된 전손 기록을 볼 수 있지만, 모든 침수차가 거기 있지는 않다고 함 (검색 요약) [17].
- 정확한 KBB 공식 할인율 페이지는 못 엶 — 다른 글들은 "20~40% 싸다"고도 함 (검색 요약). 숫자는 [5]의 60~70%를 기준으로 쓰길 제안.

### 1-2. 바닥값: 쇠 무게 + 부품
- **공식**: 쇠값 = 차 무게(톤) × 톤당 고철값. 2026년 고철 차 값 **톤당 약 $150~200**(지역·업체마다 다름) [9]. 다른 업체 표는 차체 강철 **톤당 약 $120~240**(파운드 값을 환산), 분기마다 ±20% 흔들림 [10].
- **어디 파느냐로 값이 다름** [9]:

| 파는 곳 | 받는 돈(대략) | 걸리는 시간 |
|---|---|---|
| 고철상(scrap yard) | $200~400 | 당일 |
| 자동차 해체·재활용 업체(recycler) | $250~600 | 1~2주 |
| 직접 부품 떼어 팔기 | $800~2,000 | 4~12주 |
| 개인 구매자(고칠 사람) | $500~$5,000+ | 들쭉날쭉 |

- 한 매입 업체의 실제 거래 기록: 폐차 대부분 **$300~2,500**, 가운데 값 **$400**, 상위 10%는 약 **$1,090** [10].
- **값을 올리는 부품** [9][10]:
  - **촉매(catalytic converter)**: 백금·팔라듐·로듐이 들어 있어 비쌈. 출처마다 차이 — **$50~200** [9] vs **$150~800** [10]. 하이브리드(프리우스 등)·옛 픽업이 가장 비쌈 [8][10]. 서류 없이 떼어 팔면 많은 주에서 불법 [10].
  - **알루미늄 휠** 4개 세트 고철값 $80~200 [10](다른 곳은 $50~150 [9]), 배터리 $10~25, 구리 배선·라디에이터 $5~30 [9].
  - **도는 엔진**(겨우 시동만 걸려도) 재생 업체에 **$400~1,500**, 다음으로 비싼 건 **변속기** [10].
- **촉매 도난**: NICB 집계로 미국 신고 건수 **2018년 1,298건 → 2020년 14,433건**. 차 밑 바깥에 붙어 있고 귀금속이 들어서. 다시 다는 데 **$1,000 넘게** [8]. → 폐차장 차에 **촉매가 없을 수 있음**(값 깎임 + 게임 이벤트감).
- 폐차장이 하는 일(위키): 바퀴·타이어·배터리·**촉매 먼저 떼기** → 냉각수·오일·변속기 오일·에어컨 냉매·휘발유 빼기 → 쓸 만한 컴퓨터·발전기·시동모터·엔진·변속기 떼어 팔기 → (2003년 전 차의) 수은 스위치·에어백 화약 제거 → 납작하게 눌러 → 파쇄기. 차 재료의 **약 75%** 가 재활용 [7]. 손님이 공구 들고 와 직접 떼 가는 **셀프 폐차장(U-pull)** 도 있고, 차는 몇 주~몇 달 서 있다가 고철로 감 [7].

### 1-3. 녹 감정 — 어디에 있느냐가 중요
녹의 3단계(표면 → 비늘 → 뚫림)와 고치는 법은 [11_body_paint.md '녹'](11_body_paint.md#녹-rust) 표를 봐요. 여기선 **'자리'에 따른 심각도**만.

| 자리 | 심각도 | 왜 | 출처 |
|---|---|---|---|
| **프레임 레일(frame rails)·서브프레임** | ★★★ 아주 심각 | 차를 받치는 뼈대. **서스펜션이 붙는 자리**를 특히 봄 | [11] / Hagerty (검색 요약) [14] |
| **바닥판(floor pans)** | ★★★ | 녹으로 구멍 나 **배기가스가 실내·트렁크로 들어오면** 검사 불합격(버지니아). 용접·리벳 패치로 제대로 막으면 OK | [13] |
| **쇼크 타워 / 스트럿 타워(shock/strut towers)** | ★★★ | 유니바디 차는 차체=뼈대라 녹이 곧 구조 문제. Hagerty가 머스탱에서 바닥·프레임 레일·문 아래·쇼크 타워를 꼽음 | (검색 요약) [14] |
| **문턱(rocker panels / sills)** | ★★☆~★★★ | 돌·염화칼슘을 제일 많이 맞음. **겉에 물집이 보이면 안은 더 심함**(Hagerty, MGB). 유니바디에선 구조 부재라는 주장도 있음 | [11] / (검색 요약) [14] |
| **뒤 바퀴집(rear wheel arches)·뒤 쿼터 아래** | ★★☆ | 칠 물집 → 손으로 안쪽 만져 보기. **자석**으로 퍼티 찾기(녹을 퍼티로 덮어 숨김). **리벳으로 박은 철판 패치** = 밑이 심하게 상했다는 신호 | [11] |
| **트렁크 바닥·스페어 타이어 자리** | ★★☆ | 물이 고임(침수 흔적도 여기서) | [12][18] |
| **펜더·문 아래 끝** | ★☆☆ | 볼트로 붙는 판 → 통째 교체 가능(구조 아님) | [11]·[11_body_paint.md](11_body_paint.md) |

- **칠 물집(bubbling)** 은 밑에서 녹이 자라는 중 — 한 중고차 점검 글은 **1~3년 안에 구멍(perforation)이 된다**고 함 [12].
- **두드리기(tap test)**: 판·프레임 레일을 두드려 **소리 높이가 바뀌는 곳** = 퍼티나 썩은 쇠 [11]. 드라이버 손잡이로 쳐서 '땡'(멀쩡) vs '퍽'(녹·퍼티) — (검색 요약).
- **찔러 보기(poke test)**: 문턱 아래 같은 안 보이는 곳을 일자 드라이버로 눌러 **푹 들어가면 뚫린 녹** — (검색 요약, 공식 출처 못 엶).
- Hagerty: "눈에 보이는 녹이 있으면 더 숨어 있다" → **리프트에 올려 밑을 보라** (검색 요약) [14].
- I-CAR의 '녹 자리별 심각도' 공식 문서는 못 찾음 (확인 못 함).

### 1-4. 사고·뼈대 손상 감정 (Frame / unibody damage)
| 신호 | 뜻 | 출처 |
|---|---|---|
| **판 틈(panel gap)이 한쪽만 넓거나 좁음** | 판 끝에서 끝까지 고르게. **3~4 mm 차이도 의미 있음**. 한 판 양쪽·여러 판이 같이 틀어지면 큰 구조 사고 | [12] |
| **오버스프레이** | 안쪽 펜더 가장자리·문틀·트렁크 뚜껑 밑에 바깥 색 가루 = 다시 칠함 | [12] |
| **문 고무 옆 칠 턱** | 문틀 웨더스트립을 만지면 칠이 턱져 있음 = 재도장 | [12] |
| **자석이 약하게 붙음** | 그 밑에 퍼티(Bondo). 단, **알루미늄 판은 원래 안 붙음** | [12] |
| **안쪽 펜더·프레임 레일·라디에이터 서포트의 주름·새 용접 자국** | 구조 손상 | (검색 요약) |
| **뼈대 휨 종류**: sidesway(옆으로), sag(위아래), mash(찌그러짐), **diamond(마름모)·twist(비틀림)** | 프레임 차는 마름모·비틀림도 고치기 쉬운 편, **유니바디는 구조 전손일 가능성** | [15] |

- 정비 업계 글: **눈으로만 보면 부족** — 중심선(centerline)부터 재고, 바닥 측정점을 보통 4곳 → 큰 사고면 **6~8곳**, 앞 사고면 **스트럿 타워·위 레일** 치수가 서스펜션 위치를 좌우 [15]. 측정 = 기준면 높이 + 중심선에서 폭 + 0점에서 길이(3차원 측정기) [15]. 허용 오차 숫자(mm)는 이 글에 없음 (확인 못 함).

### 1-5. 침수차 감정 (Flood damage)
| 단서 | 어디를 | 출처 |
|---|---|---|
| **곰팡내(musty)** / 반대로 **방향제 냄새가 너무 진함**(숨기려고) / 비누·암모니아 냄새(심하게 닦음) | 실내 | (검색 요약) [16] / [18] |
| **진흙·모래(silt)·물 자국 선(waterline)** | **카펫·매트 밑, 대시보드 밑, 글러브박스, 트렁크, 스페어 타이어 자리** | (검색 요약) [16] / [18] |
| **실내만 새 카펫·새 시트 천** | 나머지는 낡았는데 카펫만 새것 → 왜 바꿨는지 묻기 | [18] |
| **모든 라이트에 김 서림**(하나만이면 증거 아님) | 헤드·테일램프 | [18] |
| **퓨즈박스 습기·단자 녹**, 창문·잠금·라이트 오작동 | 전기 | [19] |
| **플라스틱 틈·시트 밑의 흙**(먼지 같지 않은 것), **수상하게 깨끗한 엔진룸** | 실내·엔진룸 | [19] |
| **나이·지역에 비해 이상하게 많은 하체 녹** | 차 밑 | (검색 요약) [16] |
| **시트 볼트를 푼 흔적·녹슨 시트 레일/스프링** | 말리려면 시트를 떼야 해서 | (검색 요약) |
| **오일이 뿌옇거나 우윳빛** | 엔진에 물 | (검색 요약) |

- NICB: 침수는 **전기·엔진·변속기·브레이크·안전장치**를 오래 망가뜨리고, 겉은 멀쩡해 보일 수 있음 (검색 요약) [17]. NHTSA: 문제가 **바로 안 나타날 수 있음** (검색 요약) [16].
- 기록의 한계: NICB 자료는 **보험 든 차만** 있음 — 휴스턴 홍수 차의 **1/3은 무보험**이라 기록에 없었다고 함 [18].
- 안에 물이 있으면 **점검 끝날 때까지 시동 걸지 말라**(NHTSA에 올라온 토요타 서비스 공지) (검색 요약). 원문 PDF는 글자를 못 뽑음 (확인 못 함).

### 1-6. 엔진 감정 (Engine checks)
**① 돌아가나? (Seized 검사)** [26]
- 벨트(서펜타인)를 먼저 벗김(발전기·파워스티어링 펌프가 굳어 있으면 엔진이 굳은 걸로 착각) → P/N + 주차 브레이크 + 바퀴 고임 → (플러그 빼면 압축이 빠져 쉬움) → **크랭크 풀리 볼트에 브레이커 바** → **시계 방향**으로. 잘 돌면 연료·점화 문제, 안 돌면 **굳은 엔진(seized)**.
- 굳는 원인: 오일 부족(펌프 고장·오일 바닥), 과열 [26]. 오래 서 있던 차의 실린더 녹·물 먹음(hydrolock)은 이 글에 없음 (확인 못 함).

**② 압축 시험 (Compression test)** [20][21]
- 방법: 점화·연료 퓨즈 빼기 → 플러그 하나 빼고 게이지 끼우기 → **시동모터로 최소 6번 압축 행정**(약 5~10초, 약 300 rpm) → 읽고 기록 → 한 번 더 해서 같은지 확인 → 실린더마다 반복 [20].
- **건강한 값**: 휘발유 엔진은 **압축비 × 15~20 psi** — 예: 11.4:1이면 약 170~228 psi(해수면) [20]. 다른 정비 글은 "대부분 **140~160 psi**" [21]. (참고 계산: 기준 차 A25A 압축비 13.0 [05_engine.md] × 15~20 = 약 195~260 psi — **우리 계산일 뿐, 토요타 공식 값은 못 찾음** (확인 못 함).)
- **실린더끼리 차이는 10% 이내** [20][21]. 포럼에선 10~15%라는 말도 있음 (검색 요약). 토요타 다른 엔진(2JZ) 매뉴얼 인용은 "차이 **14 psi(98 kPa) 이하**" (검색 요약).
- 해석 [21]:
  - **이웃한 두 실린더가 같이 낮음** → **헤드 개스킷**.
  - 낮은 실린더에 **오일 몇 방울(습식 시험)** → 숫자가 오르면 **링·실린더 벽 마모**, 그대로면 **밸브** (05_engine.md와 같음).

**③ 누설 시험 (Leak-down test)** [22][23]
- 플러그 구멍으로 **압축 공기**를 넣고(피스톤은 압축 상사점) 얼마나 새는지 % 로 봄. 기계 대부분 **100 psi** 넣음 [23], 다른 글은 **80~90 psi** [22]. 크랭크가 돌아갈 수 있어 잡아 둬야 함 [23].
- **좋음 5~10%**, 그럭저럭 **~20%**, **30% 넘으면 문제** [22]. 위키: 20% 넘으면 보통 내부 수리 필요 [23].
- **어디서 '쉿' 소리가 나나** = 어디가 샜나:
  - 배기구(꼬리관) → **배기 밸브** [22][23]
  - 스로틀 바디(흡기) → **흡기 밸브** [22]
  - 브리더·PCV 구멍(크랭크케이스) → **피스톤 링·실린더 벽** [22]
  - 냉각수에 **거품** → **헤드 개스킷** [23]

**④ 오일·연기 보기**
- **우윳빛·마요네즈 같은 오일**(딥스틱·오일 캡) = 냉각수가 섞임 → 헤드 개스킷 의심. **이것만으로 확정은 아님** [24]. 흰 연기(냉각수 탐), 냉각수 거품·기포, 과열, 압축 손실도 같이 봄 [24].
- **블로바이(blow-by)**: 폭발 가스가 **링 틈으로 크랭크케이스에 샘** → 오일 찌꺼기(슬러지), 크랭크케이스 압력이 올라 씰·개스킷으로 오일이 샘. PCV가 이 가스를 흡기로 돌려 태움 [25]. "오일 캡을 열면 연기가 뿜어 나온다"는 이 출처엔 없음 (확인 못 함).

### 1-7. 경매 표시 (Copart / IAA)
Copart 아이콘 [2] (+ Copart 용어 페이지, 본문 못 엶 → 검색 요약 [1]):

| 표시 | 뜻 | 주의 |
|---|---|---|
| **Run and Drive (R)** | Copart에 **들어올 때** 시동이 걸리고, 기어가 들어가고, **제 힘으로 움직였음** | 도로 주행 가능 보장 X, 찾으러 갈 땐 안 걸릴 수도 [1][2] |
| **Engine Start Program (S)** | 들어올 때 **시동 걸리고 공회전**까지만 확인 | 움직이는지는 모름, 보장 X [1][2] |
| **Enhanced Vehicles (E)** | 판매자가 세차·청소·덮개 같은 **'단장' 서비스를 신청**함 | **개조 차가 아님**, 실제로 했는지도 보장 X [1][2] |
| Seller Certified (C) | 판매자가 만족 보장 — 마당을 떠나기 전 보고 마음에 안 들면 구매 거부 가능 | [2] |
| VIX (V) | 주인이 가진 채 파는 전손 차 — 보통 굴러가고 고칠 만한데, 보험사 입장에선 수지가 안 맞던 차 | [2] |

- Copart 검색 필터에 **Flood Damage, Vandalism, Hail Damage, Runs & Drives, Clean Titles, No Damage** 가 있음 [2].
- Copart 손상 분류(도움말 본문 못 엶): **Normal Wear**(아주 작은 생활 흠) / **Minor Dents & Scratches**(칠 긁힘, 우박·주차장 찌그러짐 몇 개) / **Minor to Heavy Damage** — 그 아래 **Front End, Rear End, Side, All Over** (검색 요약) [4]. **Mechanical, Undercarriage** 는 매물 표시엔 보이지만 공식 정의는 못 찾음 (검색 요약).
- 손상 표시는 **보험사가 적은 것이라 출발점일 뿐**, 진단이 아님 (검색 요약 — 해체 업체 안내).
- **IAA 공식 표시 정의는 못 찾음** (확인 못 함). 다른 경매(ACV) 용어집: Run and Drive = 시동·작동·**경매대에 제 힘으로 올라갔다 내려옴**, 그 이상(기계 상태·안전·도로 주행)은 아무 약속 없음 [3].

---

## 2. 복원 순서 (Restoration process)

### 2-1. 먼저 '어느 수준'으로? (위키 [27])
| 수준 | 뜻 |
|---|---|
| **Concours (콩쿠르)** | 최고 단계. 새 차 때보다 더 다듬어지기도, 거의 안 탐. 아마추어는 보통 못 닿음 |
| **Traditional restoration** | 원래 모습(또는 그 이상)으로, 순정·복제 부품 |
| **Restomod (레스토모드)** | 옛 차 + 요즘 엔진·브레이크·전자. **되돌릴 수 있는 개조**가 더 받아들여짐 |
| **Driver / 멀리서 예쁜 쇼카** | 그 사이 — 매일 타는 차 |
| **Preservation (보존, patina)** | 칠·차체를 낡은 그대로 두어 '세월 맛'을 지킴 |
| Replica / Tribute | 다른 차처럼 꾸밈(희귀 차로 속여 판 사례도) |

- 전체 복원은 **몇 년, 수만 달러** — **다 고친 차 값보다 더 드는 일이 흔함**. 미완성 프로젝트 차는 싸지만, 빠진 부품(특히 희귀 차)은 비싸고 구하기 어려움 [27].

### 2-2. 단계별 (실제 순서)
| # | 단계 | 하는 일 · 숫자 | 도구 | 출처 |
|---|---|---|---|---|
| 1 | **감정·계획** | 1장 감정 + 목표 수준(2-1) + 예산. 희귀 부품 먼저 확인 | 리프트, 손전등, 자석, 압축 게이지 | [27] |
| 2 | **기록** | **떼기 전 사진**, 부품마다 **봉투에 넣고 이름표(bag & tag)**, 판 위치 표시, 맞는 부품 조사 | 카메라, 지퍼백, 마커 | [27] |
| 3 | **분해(teardown)** | 보통 실내(시트·카펫·문 안판·대시) → 장식·유리 → 엔진·변속기·서스펜션 (검색 요약). 섀시(뼈대) 검사 [27]. 자르기 전 **실내에 버팀대**를 대어 차체 처짐 막기 (검색 요약, 포럼) | 렌치, 엔진 크레인, 차체 스탠드 | [27] |
| 4 | **벗기기(stripping)** | **매체 블라스팅**: 산화알루미늄·탄화규소는 빨리 깎지만 **열이 나서 얇은 판이 휨** → 판엔 **소다·호두 껍질·고운 유리 구슬(70~100)**, 얇은 판 **20~40 psi**, 3~6 in 거리, 45°, **한 곳에 오래 머물지 말기**. 두꺼운 프레임엔 센 매체 (Eastwood, 검색 요약) [28]. 플라스틱·호두는 **녹은 못 벗김**, 소다 가루는 칠 전에 꼭 씻기, **화학 박리제**는 열이 없지만 공장 실러까지 다 녹임 (포럼, 검색 요약) [29] | 블라스터, 박리제, 스트립 디스크 | [28][29] |
| 5 | **녹 수리** | 썩은 곳 **잘라 내기 → 패치 판 맞추기 → 용접**. 겹치기(lap)보다 **맞대기(butt)** 를 선호 — 겹친 틈에 물이 고여 녹이 돌아옴 (검색 요약). 녹 3단계별 방법은 [11_body_paint.md](11_body_paint.md#녹-rust) | 그라인더, 절단 휠, 패치 판, 클램프 | (검색 요약) |
| 6 | **용접(MIG)** | **가접(tack) 간격 1 in 이하**, 짧게 '팟' 끊어 쏘기, **판이 완전히 식을 때까지 기다림**, 평평한 판은 **약 1 in씩 여기저기 건너뛰며** — **휨(warpage)** 막기. 용접 뒤 3 in **36방 디스크**로 깎되 과열 금지 → 50방 → 120방, 해머·돌리로 높낮이 맞추기 | MIG 용접기, 마스크, 그라인더, 해머·돌리 | [30] |
| 7 | **녹 방지 층** | 혼다 공식: **맨 쇠에는 무조건 2K 에폭시 먼저** → **실러(seam sealer)는 굳은 에폭시·2K 서페이서·공장 전착 위에만**, "맨 쇠에 실러 절대 X". 용접 관통 프라이머는 **아연 많은 것**, 스폿 용접 자리에만. 막힌 판 안쪽엔 **캐비티 왁스** | 에폭시 프라이머, 실러 건, 왁스 노즐 | [31] |
| 8 | **판금·퍼티** | 찌그러짐(PDR·해머&돌리)은 [11_body_paint.md](11_body_paint.md#판금-찌그러짐-dent-repair). 퍼티는 칠을 다 벗긴 맨 판(또는 굳은 에폭시를 24시간 뒤 P80~P180로 갈고) 위에. **셀프 에칭 프라이머 위엔 퍼티 X**(산이 굳는 걸 방해). 경화제 **50:1(약 2%)**. 갈기 **P80 → P180**. **너무 두꺼우면 핀홀** [32]. 실용 두께 한계 **약 6 mm** [12]. "1/8 in 이하" 같은 공식 수치는 못 찾음 (확인 못 함) | 퍼티, 주걱, 블록, 사포 | [12][32] |
| 9 | **서페이서·블록 샌딩** | 2K 하이빌드로 두껍게 → 블록으로 평평하게 — 숫자는 [11_body_paint.md 도색 4~6번](11_body_paint.md#정비소-다시-칠하기--단계와-숫자) | 롱 블록, 가이드 코트 | 11번 파일 |
| 10 | **칠·클리어·물사포·광** | [11_body_paint.md 도색 7~12번](11_body_paint.md#정비소-다시-칠하기--단계와-숫자) 그대로 | 스프레이건, 부스, 폴리셔 | 11번 파일 |
| 11 | **엔진 재생(rebuild)** | 매뉴얼 먼저 → 분해·세척(오일 통로 찌꺼기) → **손톱이 걸리는 실린더 긁힘 = 가공소** → 보어 게이지로 재기(새 링만? 오버사이즈 피스톤?) → **호닝**(가벼운 마모) / **보링**(심한 마모) → 데크 면 가공 → 링 끝 간격 맞추기 → **메인 캡 순서대로** [35]. 호닝 줄무늬(크로스해치)는 **오일을 머금고 링이 자리 잡게** 함, 목표 약 **45°**(위키도 '출처 필요' 표시) [34]. 위쪽 턱(ridge)은 피스톤 빼기 전 리머로, **베어링 전부 새것 + 플라스티게이지로 틈 확인**, 오일 펌프·흡입망 청소 (포럼, 검색 요약). 평면 태핏 캠은 **첫 시동 길들이기**를 안 하면 캠이 망가짐, 길들인 뒤 오일·필터에 **반짝이 가루**가 있으면 안쪽 손상 [35] | 보어 게이지, 마이크로미터, 호닝 도구, 링 컴프레서, 토크 렌치 | [34][35] |
| 12 | **연료** | 탱크: 녹·바니시 청소(강철 탱크는 끓여 씻기) → 핀홀·이음새 확인 → (코팅) / 쇠 연료관: 새 휘발유로 씻고 공기로 말림, 녹·금 있으면 교체 / **고무 호스는 전부 에탄올용 새것**(에탄올이 옛 고무를 끈적하게 녹임) / 펌프는 **새 휘발유로만** 씻기(아세톤은 막을 녹임) / 필터는 탱크·관·펌프·카브 입구 다 찾기. **오래 서 있던 차는 바로 시동 X** — 플로트가 붙어 불날 위험 [36] | 탱크 실러 키트, 새 호스 | [36] |
| 13 | **브레이크** | 라인·호스·브레이크액·패드 — [02_brakes.md](02_brakes.md). 복원용 출처는 따로 못 엶 (확인 못 함) | 플레어 공구 | 02번 파일 |
| 14 | **배선** | 침수·녹 단자 점검(1-5), 나머지 복원 출처는 못 찾음 (확인 못 함) | 멀티미터 | [19] |
| 15 | **조립·시운전** | 칠한 차체에 서스·브레이크·연료 장치를 **새 볼트로, 토크대로** (검색 요약). 마지막에 **시험 운행** [27] | 토크 렌치 | [27] |

### 2-3. 흔한 실수 → 게임 '함정' 표시 (🪤 = 함정으로 재밌음)
| 실수 | 진짜로 무슨 일이 | 함정? | 출처 |
|---|---|---|---|
| **녹 위에 그냥 칠** | 녹이 밑에서 계속 자라 다시 물집. 고치는 법 = 쇠까지 벗기고 에칭 프라이머·서페이서·(실러)·칠 | 🪤 판매 며칠 뒤 '물집' 반품 | [33] |
| **퍼티를 너무 두껍게** | 핀홀, 자석 테스트에 들킴 | 🪤 손님이 자석을 꺼냄 | [12][32] |
| **맨 쇠에 에폭시 없이 실러·퍼티** | 혼다는 "절대 X". 셀프 에칭 위 퍼티는 안 굳고 안 붙음 | 🪤 | [31][32] |
| **봉투·이름표 안 함** | 조립 때 볼트가 남거나 모자람 | 🪤 '남은 볼트' 미니 퍼즐 | [27] |
| **샌딩 자국 부풂(sand scratch swelling)** | 용제가 사포 자국에 스며 자국이 **칠 위로 드러남**. 원인: 대충 손질, 덜 마른 프라이머, 두꺼운 칠 | 🪤 광낸 뒤에 줄무늬가 보임 | [33] |
| **솔벤트 팝(solvent popping)** | 갇힌 용제가 터져 **작은 물집·구멍**. 두꺼운 칠, 플래시 시간 부족, 적외선 램프 너무 가까이 | 🪤 '기다리기' 무시하면 생김 | [33] |
| **피시아이(fisheyes)** | **실리콘·왁스·WD-40·Armor All·기름 낀 공기관**이 칠을 밀어 **동그란 구멍**. 넓게 생기면 하룻밤 말리고 원인 찾아 다시 칠 | 🪤 탈지 단계를 빼면 확률로 생김 | [33] |
| **오렌지 필(orange peel)** | 귤껍질 같은 오톨도톨. 건 조정·온도·희석제 문제. 평평하게 갈고 컴파운드 | 🪤 약하게 — 물사포로 회복 | [33] |
| **흘러내림(runs/sags)** | 한 곳에 너무 많이 → 중력으로 흘러내림. 씻고 말리고 갈고 다시 | 🪤 스프레이 버튼을 오래 누르면 | [33] |
| **용접 휨(warpage)** | 길게 한 번에 용접 → 판이 물결 | 🪤 '식히기' 기다림 게이지 | [30] |
| **센 매체로 얇은 판 블라스팅** | 열로 판이 휨 | 🪤 매체 고르기 | (검색 요약) [28] |
| **오래 서 있던 차 바로 시동** | 플로트 붙어 화재 위험 / 침수차는 전기 손상 | 🪤 | [36] / (검색 요약) |
| **순서 틀림**(칠 다음에 용접 등) | 열·불똥이 새 칠을 태움 — 일반 상식, 출처 따로 못 엶 (확인 못 함) | 🪤 | — |

---

## 3. 중고차 판매 (Selling used cars in the US)

### 3-1. 값을 움직이는 것
| 요인 | 사실 | 출처 |
|---|---|---|
| **상태 등급(KBB)** | **Excellent** 새 차처럼 보이고 기계 최상 — **2%** / **Very Good** 작은 겉 흠, 기계 좋음 — **28%** / **Good** 고칠 수 있는 겉 흠 + 기계 문제 — **50%** / **Fair** 기계 수리 필요 — **20%** (2023 Accord 페이지의 'KBB가 값을 매긴 차' 비율). Poor는 값을 안 줌 | [37] / (검색 요약) |
| **주행거리·나이** | 미국 평균 운전자 1년 **13,476 mi** (FHWA 표, 연도 표시 없음) [52]. AAA: 1년 **13,000 mi 넘게**를 기준으로 '많다/적다' 판단 [39] | [39][52] |
| **사고 이력** | 감정사 인터뷰: Carfax·AutoCheck에 사고가 뜨면 **10~20% 하락** — 단 **5년 미만·100,000 mi 미만** 차 기준, 100,000 mi 넘으면 영향 거의 없음 | [40] |
| **타이틀** | 재건 = KBB fair의 **60~70%**, 샐비지 = 값 없음/65~75% 낮게 (1-1 표) | [5] |
| **정비 기록** | 제조사 주기대로 한 오일·타이어 교환 기록이 값을 더함, 정리된 서류가 믿음을 줌 | [39] |
| **주인 수** | **1인 소유**가 선호(기록 추적 쉬움), **3명 이상**·빨리 바뀐 차는 덜 선호 | [39]. Carfax는 'One Owner' 표시가 소매값 **+15%** 라고 홍보(정식 연구 아님) (검색 요약) |
| **희귀함·지역** | 적게 만든 모델·트림·색, 단종 차 / 따뜻한 해안 = 후륜 스포츠카, 눈 오는 산 = 4WD, 겨울엔 컨버터블 덜 팔림, 기름값 오르면 하이브리드 | [39] |
| **색** | 3년 된 차 120만 대 분석: **노랑 24.0%**, 주황 24.4%, 초록 26.3% 하락(가장 덜 떨어짐) / **금색 34.4%**, 흰색 32.1%, 검정 31.9%(가장 많이) / 평균 31.0%. 이유: 드문 색은 **찾는 사람 > 매물** | [41] |
| **개조** | Edmunds: 개조 차는 시세를 안 냄, **보통 트레이드인 값이 내려감**(딜러가 순정으로 되돌리니까) → 개인에게 팔거나 순정으로 되돌리고 부품 따로 팔라 (페이지 막힘, 검색 요약) [42]. 사려는 사람이 원할 때만 개조가 값이 됨 (포럼, 검색 요약) | (검색 요약) [42] |
| **클래식: 순정 vs 레스토모드** | **희귀·역사적 차는 순정·넘버 매칭(numbers-matching)일 때 거의 항상 최고가**, 개조하면 그 웃돈이 사라짐 / **흔한 클래식은 잘 만든 레스토모드가 순정보다 비싸게** 팔리기도 / 레스토모드는 만드는 데 순정 복원보다 더 들 수 있음 | [43] |

### 3-2. 시세표 (Price guides)
- **KBB**: 상태 등급을 사용자가 고름(KBB가 차를 보지 않음) (검색 요약), 등급 정의는 [37].
- **J.D. Power Valuation Services = 옛 NADA Used Car Guide** — 1930년대부터 딜러 판매 자료로 값을 모음, "90년 넘게" [44]. 2015년 J.D. Power가 인수 (검색 요약).
- **Edmunds** 'True Market Value' — 개조 차엔 안 냄 (검색 요약) [42].
- **Hagerty (클래식)** — 상태 **#1 Concours**(세계 최고, 모든 게 완벽) / **#2 Excellent**(지역 쇼에서 우승감, 전문가는 흠을 찾음) / **#3 Good**(잘 달리지만 매일 타진 않음, 틀린 부품이 좀 있을 수 있음) / **#4 Fair**(매일 타는 차, **맨눈에 흠이 보임** — 크롬 녹, 앞유리 깨짐 등). +/− 로 더 잘게 나눔. Hagerty 사이트가 막혀 **검색 요약** [38]. 위키는 "값 안내서는 6단계, 최고가 Number 1"이라고 함 [27] — #5·#6 정의는 못 엶 (확인 못 함).

### 3-3. 딜러는 어떻게 남기나
- **값 세 가지**: 트레이드인(딜러가 사 주는 값, 가장 낮음, 도매 기준) < 개인 거래(private party) < 딜러 소매(retail). 개인 거래는 트레이드인보다 **15~30% 더** 받는다는 글이 있지만 근거가 약함 (검색 요약) [56]. 대부분 주에서 트레이드인은 **새 차 값과의 차액에만 판매세** → 그 차이를 줄여 줌 (검색 요약) [56].
- **딜러 한 대당 이익**: CarMax(2025 회계연도) 중고 소매 한 대당 총이익 **$2,322**, Lithia 2024년 한 대당 약 **$2,084** (검색 요약) [57]. '도매값 대비 몇 % 붙이나'는 못 찾음 (확인 못 함).
- **리컨디셔닝(recon, 팔기 전 손질)**: 점검(VIN 이력·침수·프레임) → 기계(벨트·플러그·오일·서스·브레이크·전기·에어컨) → 차체·칠 터치업, 헤드라이트 복원, 가죽·플라스틱 → **마지막에 디테일링(세차·광·실내 청소)**. 비용 대략 **$1,000** [46]. Cox Automotive 글: 딜러가 '자동 승인' 한도로 **한 대 $600~800**을 흔히 씀, 잘하는 딜러는 **24시간 안에**, 다른 곳은 **7일 이상** [45]. 고칠 범위는 그 차로 남길 이익에 맞춰 정함, 문제 차는 아예 안 삼 [45].

### 3-4. 흥정·거래 관습
- **흥정 폭**: 블로그들은 딜러 **3~10%** 또는 **5~15%**, 개인 거래 **5~10%** — 공식 연구 아님, 2021~2022년처럼 물건이 모자랄 땐 거의 안 깎아 줌 (검색 요약) [53].
- **무기**: 점검에서 찾은 **구체적 결함**, 더 싼 비슷한 매물, **그냥 나갈 각오** (검색 요약) [53]. FTC: 정비사 **서면 보고서 + 수리비 견적**으로 값을 깎으라 [47].
- **사기 전 점검(pre-purchase inspection)**: FTC — "차량 이력 보고서는 **독립 점검을 대신하지 못함**", 딜러가 점검을 거절하면 다른 곳으로 [47]. 이력 보고서는 사고·침수는 보일 수 있지만 **기계 문제는 보통 안 보임** [47].
- **'As Is'(있는 그대로)**: 딜러는 모든 중고차 창문에 **Buyers Guide** 를 붙여야 하고, 'As Is – No Dealer Warranty' 칸에 체크되면 **팔고 나서 고장은 산 사람 몫**. Buyers Guide 내용이 계약서보다 우선, 말로 한 약속은 Buyers Guide에 적게 하라 [47]. 몇몇 주(뉴욕·뉴저지·매사추세츠 등)는 많은 중고차에 As Is를 허용 안 함, 메인·위스콘신은 자기 양식 (FTC 딜러 안내, 검색 요약) [48]. '묵시적 보증(merchantability)' = 차가 굴러간다는 약속, 주에 따라 최대 4년 [47].
- **추가 요금**: 마지막에 끼워 넣는 옵션·요금 조심, **'out-the-door' 총액을 서면으로** [47]. **서류비(doc fee)**: 캘리포니아는 **$85 상한**(여러 출처), 상한 있는 주가 여럿 — 평균 액수는 출처마다 다름 (검색 요약) [54].
- **시운전(test drive)**: FTC 페이지엔 없음 (확인 못 함). 단, 사고 차의 뼈대 손상은 처음엔 운전감에 안 나타나고 나중에 **편마모·얼라인먼트 문제**로 나온다는 글 (검색 요약).

### 3-5. 클래식 경매
- **Bring a Trailer (BaT)**: 온라인 **7일** 경매, 마지막 몇 분에 입찰하면 **시간 연장**(막판 '저격' 방지), 카드 등록해야 입찰, 끝나면 낙찰자 카드에 바로 청구, 판매자는 사진을 직접 내면 등록비 $99 [49]. **구매자 수수료 5%, 최소 $250** — 상한은 2022년 자료 **$5,000** [49], 최근 기사들은 **$7,500** (검색 요약) [50]. 낙찰 후 안 사면 수수료 내고 퇴출 [49]. 리저브(최저가) 있는/없는 경매 둘 다, 리저브 못 넘으면 판매자 수수료 없음 [49]. BaT 사이트는 직접 못 엶 (확인 못 함).
- **Barrett-Jackson**: 현장 TV 경매, **노 리저브(no reserve)** 가 간판 — 2025 스코츠데일은 **100% 노 리저브, 2,013대** (검색 요약) [51]. 2011년부터 일부 차엔 리저브 허용 (검색 요약) [51]. 구매자 수수료 10~12%는 약한 출처라 (확인 못 함).
- 노 리저브 = **최고가가 얼마든 팔림** → 구경꾼·경쟁 입찰이 몰림(게임의 '경매 이벤트' 근거).

---

## 4. 게임으로 옮길 때 (제안만)
> 결정은 wr-design. 아래는 위 사실에서 바로 나온 손맛 후보예요.

1. **타이틀 도장 카드**: 폐차장 차마다 서류 한 장 — CLEAN / SALVAGE / REBUILT / FLOOD / JUNK 도장. 판매가 배수 예: 깨끗 1.0, 재건 **0.6~0.7** [5], 샐비지 = 고치고 **'검사소' 통과해야 REBUILT로 승격**, JUNK = 부품·고철만 [6]. 타이틀 세탁은 **불법 유혹 이벤트**(하면 평판 폭락)로만.
2. **바닥값 저울**: 폐차장 입구 트럭 저울 → "3,500 lb × 톤당 $175" 쇠값이 뜨고, 그 위에 **촉매 확인**(없으면 "도둑맞음!" −$) · **알루미늄 휠** · **엔진 도나?** 보너스가 쌓임 [9][10][8].
3. **녹 탐침 + 망치 톡톡**: 프레임 레일·바닥·쇼크 타워·문턱·바퀴집·트렁크 바닥 6곳을 망치로 두드림 → 소리 '땡/퍽', 드라이버로 찌르면 '푹'. **자리별 별점(★~★★★)** 이 수리비·구조 위험 표시 [11][13][14].
4. **자석 테스트**: 판 위로 자석을 끌면 퍼티 자리에서 '툭' 떨어짐(알루미늄 판은 처음부터 안 붙음 = 함정 오진) [12]. 손님(구매자)도 자석을 꺼내 우리 퍼티를 검사 → **두꺼운 퍼티 쓰면 흥정 불리**.
5. **틈 게이지**: 문·보닛·트렁크 틈을 끝에서 끝까지 재기 — 한쪽만 **3~4 mm 차이** 나면 "사고 차" 단서 [12]. 마름모·비틀림 뼈대는 '프레임 지그'에서 6~8점 측정 [15].
6. **침수 실루엣**: 카펫을 들추면 **진흙 선**, 스페어 타이어 칸 물 자국, **모든 라이트에 김**, 퓨즈 단자 녹, 방향제 냄새 아이콘 → 3개 이상 찾으면 'FLOOD' 의심 → 서류와 대조 [16][18][19]. 찾기 전 시동 걸면 전기 고장 벌점.
7. **압축 게이지 미니게임**: 실린더 4개 바늘. **10% 넘게 차이** 나면 빨간색, **이웃 두 개가 같이 낮으면 '헤드 개스킷'**, 오일 한 방울 넣어 오르면 '링' [20][21]. 다음 단계 **누설 시험**: 공기 넣고 '쉿' 소리 위치를 맞히기 — 꼬리관=배기 밸브, 흡기=흡기 밸브, 오일 캡=링, 냉각수 거품=헤드 개스킷 [22][23].
8. **브레이커 바 돌리기**: 벨트 먼저 안 벗기면 '가짜 굳음' 오진 → 벗기고 돌려서 판정(도는 엔진 = 판매가 ↑) [26][10].
9. **봉투·이름표 보드**: 분해 때 볼트를 봉투에 안 넣으면 조립 때 '남는 볼트' 퍼즐 [27].
10. **복원 순서 카드 덱**: 블라스팅 → 녹 잘라 용접(식히기 게이지) → **에폭시** → 실러 → 퍼티(두께 게이지) → 서페이서 → 칠 → 클리어 → 광. 순서를 틀리면 **며칠 뒤 함정 발동**(물집·핀홀·피시아이·샌딩 자국) [30][31][32][33]. 탈지를 빼면 **피시아이 확률** ↑ [33].
11. **복원 수준 고르기**: Driver(싸고 빠름) / Restomod(흔한 차일 때 값 ↑) / Concours(희귀 차, 아주 비싸고 오래) — 차 희귀도에 따라 **정답이 다름** [27][43]. 희귀 차를 개조하면 웃돈 증발.
12. **쇼룸 가격표 = KBB식 등급 + Hagerty식 #1~#4**: 일반 차는 Excellent/Very Good/Good/Fair, 시대 희귀 차(era cars)는 #1~#4 [37][38]. Excellent는 **2%뿐** → 진짜 어렵게.
13. **손님 흥정 폭**: 손님마다 '깎으려는 %'(예: 3~15%) + 무기(점검 결함 목록, 비슷한 매물). 우리가 **정비 기록 폴더·1인 소유·드문 색(노랑·주황·초록)** 카드를 내밀면 버팀 [39][41][53]. "As Is로 팔기" 선택 = 값 ↓ 대신 반품 없음 [47].
14. **수수료·경매 이벤트**: 가끔 '온라인 7일 경매'(막판 연장) 또는 '노 리저브 현장 경매'(구경꾼 몰림, 대신 싸게 팔릴 위험) [49][51].

---

## 출처
1. Copart, Copart Terminology — https://www.copart.com/content/us/en/landing-page/copart-terminology (본문 비어 나옴 → 검색 요약)
2. CarProxy, Copart Highlight Definitions — https://www.carproxy.com/how-it-works/copart-highlight-definitions
3. ACV Auctions Glossary, Run and Drive — https://www.acvauctions.com/glossary/run-and-drive
4. Copart Help, Vehicle Damage — https://help.copart.com/22724/kb/article/120673 (리다이렉트, 검색 요약)
5. Wikipedia, Salvage title — https://en.wikipedia.org/wiki/Salvage_title
6. Oregon OAR 735-020-0070 (junk brand group) — https://oregon.public.law/rules/oar_735-020-0070
7. Wikipedia, Vehicle recycling — https://en.wikipedia.org/wiki/Vehicle_recycling
8. Wikipedia, Catalytic converter (Theft) — https://en.wikipedia.org/wiki/Catalytic_converter
9. Gerald, How Much Can You Get for Scrapping a Car (2026) — https://joingerald.com/learn/money-basics/how-much-scrapping-car
10. Cash Auto Salvage, Auto Salvaging / junk car value (updated May 2026) — https://www.cashautosalvage.com/auto-salvaging/
11. The Engine Block, 5 Prime Areas to Look for Rust — https://theengineblock.com/top-five-areas-checking-for-rust/
12. Bumper.ca, Used Car Exterior Inspection: Accidents, Rust, and Bondo — https://www.bumper.ca/car-advice/buying/car-exterior-inspection/
13. Virginia Admin. Code 19VAC30-70-270, Floor pan (passenger vehicles) — https://law.lis.virginia.gov/admincode/title19/agency30/chapter70/section270
14. Hagerty buyer's guides (1965–66 Mustang, MGB, Tri-Five Chevrolet) — https://www.hagerty.com/media/buying-and-selling/1965-66-ford-mustang-buyers-guide/ (403, 검색 요약)
15. FenderBender, Advanced Structural Analysis — https://www.fenderbender.com/running-a-shop/operations/article/33019960/advanced-structural-analysis
16. NHTSA, Hurricane- and Flood-Damaged Vehicles — https://www.nhtsa.gov/hurricane-and-flood-damaged-vehicles (403, 검색 요약)
17. NICB, flood-damaged vehicle warning — https://www.nicb.org/node/125014 (403, 검색 요약)
18. The Drive, How to Spot a Flood-Damaged Car — https://www.thedrive.com/buyers-guides/17774/how-to-spot-a-flood-damaged-car
19. carVertical, How to Detect Signs of Flood Damage in Cars — https://www.carvertical.com/en/blog/how-to-detect-signs-of-flood-damage-in-cars
20. eBay Motors Blog, How to Do an Engine Compression Test — https://www.ebay.com/motors/blog/how-to-use-an-engine-compression-test-kit
21. AA1Car, Compression test — https://www.aa1car.com/library/compression.htm
22. AA1Car, Engine Leakdown Testing — https://www.aa1car.com/library/leakdown.htm
23. Wikipedia, Leak-down tester — https://en.wikipedia.org/wiki/Leak-down_tester
24. Wikipedia, Head gasket — https://en.wikipedia.org/wiki/Head_gasket
25. Wikipedia, Blowby — https://en.wikipedia.org/wiki/Blowby
26. SlashGear, How To Tell If Your Engine Is Seized — https://www.slashgear.com/1612035/engine-seized-locked-up-symptoms-how-avoid
27. Wikipedia, Conservation and restoration of road vehicles — https://en.wikipedia.org/wiki/Conservation_and_restoration_of_road_vehicles
28. Eastwood, Media Blast Equipment Selection Chart / Abrasive Blasting Tips — https://www.eastwood.com/media-blast-equipment-selection-chart-eastwood , https://www.eastwood.com/garage/abrasive-blasting-tips-and-tricks/ (403, 검색 요약)
29. Pro-Touring / HET Club forums, blasting vs chemical stripping — https://www.pro-touring.com/archive/index.php/t-11532.html , https://openforum.hetclub.org/discussion/comment/17241/ (포럼, 검색 요약)
30. Miller Welds, How to MIG and TIG Weld Auto Body Sheet Metal (Ron Covell) — https://www.millerwelds.com/resources/article-library/how-to-mig-and-tig-weld-auto-body-sheet-metal-with-ron-covell
31. Repairer Driven News, New Honda bulletin gives corrosion protection advice (2020) — https://www.repairerdrivennews.com/2020/04/13/new-honda-bulletin-gives-corrosion-protection-advice/
32. Evercoat, FAQs (body filler) — https://www.evercoat.com/faqs/
33. FenderBender, Paint Disasters — https://www.fenderbender.com/running-a-shop/operations/article/33019928/paint-disasters
34. Wikipedia, Honing (metalworking) — https://en.wikipedia.org/wiki/Honing_(metalworking)
35. Street Machine, How to rebuild your engine — https://www.streetmachine.com.au/?p=10114
36. Popular Restorations, fuel system restoration (Article 240) — https://popularrestorations.com/Articles/Article240.htm
37. Kelley Blue Book, condition page (2023 Honda Accord LX) — https://www.kbb.com/honda/accord/2023/lx-sedan-4d/condition
38. Hagerty, Condition Definitions — https://www.hagerty.com/valuationtools/About (403, 검색 요약)
39. AAA Club Alliance, 6 Factors That Make Your Used Car More Desirable — https://cluballiance.aaa.com/the-extra-mile/advice/car/6-factors-that-make-your-used-car-more-desirable
40. KSHB 41, Carfax is great, unless you are selling your car — https://www.kshb.com/money/consumer/dont-waste-your-money/carfax-is-great-unless-you-are-selling-your-car
41. iSeeCars, Car Color Study (MY2022, sold Aug 2024–May 2025) — https://iseecars.com/car-color-study
42. Edmunds Help, What is the True Market Value on aftermarket parts? — https://help.edmunds.com/hc/en-us/articles/206103057-What-is-the-True-Market-Value-on-aftermarket-parts (403, 검색 요약)
43. Motorious, Restomod vs. Original — https://www.motorious.com/articles/features-3/restomod-vs-original-which-classic-car-build-is-right-for-you/
44. J.D. Power Values, Learn About Our History — https://www.jdpowervalues.com/node/311
45. Cox Automotive (Dale Pollak), Five Pointers to Improve Your Used Vehicle Reconditioning Process — https://www.coxautoinc.com/insights-hub/five-pointers-to-improve-your-used-vehicle-reconditioning-process/
46. ACV Auctions, What is Automotive Reconditioning — https://www.acvauctions.com/blog/auto-reconditioning-for-dealerships
47. FTC Consumer Advice, Buying a Used Car From a Dealer — https://consumer.ftc.gov/articles/buying-used-car-dealer
48. FTC, Dealer's Guide to the Used Car Rule — https://www.ftc.gov/business-guidance/resources/dealers-guide-used-car-rule (검색 요약)
49. iSeeCars, Bring a Trailer vs Cars and Bids (2022 자료) — https://www.iseecars.com/articles/bring-a-trailer-vs-cars-and-bids
50. The Autopian, Cars & Bids raises its buyer fees to match Bring a Trailer — https://theautopian.com/cars-bids-raises-its-buyer-fees-post-layoffs-to-match-bring-a-trailer (검색 요약)
51. Old Cars Weekly / Ford Authority, Barrett-Jackson no-reserve — https://www.oldcarsweekly.com/news/barrett-jackson-rocked-scottsdale-surpassing-more-than-198-million-in-total-auction-sales-with-100-no-reserve-collector-car-docket , https://fordauthority.com/2021/06/barrett-jackson-las-vegas-auction-goes-100-percent-no-reserve (검색 요약)
52. FHWA, Average Annual Miles per Driver by Age Group — https://www.fhwa.dot.gov/ohim/onh00/bar8.htm
53. 중고차 흥정 폭 블로그 모음(미국 공식 연구 아님) (검색 요약) — 예: https://cloud.motorsport.unibo.it/article/negotiating-a-used-car-the-exact-math-behind-how-much-to-negotiate
54. Dealer doc fee caps — CarEdge California 딜러 페이지 / KBB, Car dealership document fees could go up in California — https://www.kbb.com/car-news/car-dealership-document-fees-could-go-up-in-california (검색 요약)
55. (번호 비움 — Carfax One Owner +15%는 3-1 표에 '검색 요약'으로만 적음: https://www.autoremarketing.com/?p=40833)
56. Trade-in vs private party 설명 글들 (검색 요약) — 예: https://strongautomotive.com/trade-it-or-sell-it-how-to-get-rid-of-your-old-car/
57. CarMax FY2025 결과 / Lithia 2024 결과 (검색 요약) — https://s21.q4cdn.com/986527125/files/doc_news/CarMax-Reports-Fourth-Quarter-and-Fiscal-Year-2025-Results-2025.pdf , https://europe.autonews.com/retail/used-cars/an-lithia-used-vehicle-sales-0408
