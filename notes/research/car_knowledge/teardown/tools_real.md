# 진짜 공구 — 조이는 것 ↔ 공구 · 초보 vs 숙련 · 위험 공구 (wr-carbook, 2026-10-22)

> 사용자: "그에 맞는 도구들도 있어야 해". 이 파일 = **미국 정비소에서 실제로 쓰는 공구 이름**과 **어떤 조이는 것에 무엇을 쓰는지**, **처음 vs 숙련 정비사가 가진 것**, **위험한 공구·일의 진짜 규칙**. 게임 공구 목록·해금 순서는 wr-design이 정해요(§10은 제안만).
> 캠리 예 = [sedan_teardown.md](sedan_teardown.md) 표 번호(A1, D4 …). 출처 번호는 맨 아래, "(검색 요약)" = 검색 결과 요약만 본 것.

## 0. 한눈에 (게임 설계용)
- **틀린 공구의 진짜 결과**가 분명함 → "틀린 공구는 안 됨/느림"보다 **"틀린 공구 = 망가뜨림"**이 더 현실적이고 재밌음:
  | 틀린 공구 | 진짜로 생기는 일 | 출처 |
  |---|---|---|
  | 12각 소켓·오픈 렌치를 꽉 낀 볼트에 | 머리가 둥글게 뭉개짐(6각이 면을 잡아 덜 뭉갬) | [S5][S4] |
  | 오픈 렌치를 브레이크 관 너트에 | 무른 너트가 뭉개짐 → **플레어 너트 렌치**(6면 중 5면을 감쌈) | [S25] |
  | 크롬(일반) 소켓을 임팩트에 | **깨질 수 있음** → 임팩트 소켓(두껍고 검정) | [S4][S5] |
  | 십자 드라이버를 일본 JIS 나사에 | 빠져나오며 머리를 갉음 | [S17] |
  | 드라이버로 커넥터 잠금 걸쇠 비틀기 | 걸쇠가 부러지는 제일 흔한 이유 | [S23](검색 요약) |
  | 피클 포크(쐐기)로 볼조인트·타이로드 | **고무 부트가 찢어짐** → 갈 부품일 때만 | [S35](검색 요약) |
  | 클립을 공구 없이 잡아당기기 | 클립·패널이 부러짐 → 트림 도구로 **클립을** 들어야(패널 말고) | [S18] |
  | 임팩트로 휠 너트 끝까지 조이기 | 나사 뭉개짐·스터드 늘어남·**디스크 휨** → 마지막은 토크 렌치 | [S10][S9] |
  | 연료 퀵 커넥터를 드라이버로 | 하지 말 것 → 관 크기에 맞는 **분리 공구**(5/16"·3/8"가 흔함) | [S24](검색 요약) |
  | 나선형 '이지아웃'으로 부러진 볼트 | 더 꽉 박히거나 공구가 속에서 부러짐 | [S51] |
- **조임 힘 = 공구 단계**: 손 → 클립 도구 → 1/4"·3/8" 라쳇(약함) → 토크 렌치(정확) → 1/2" 브레이커 바·임팩트(셈) → 전용 공구 → 기계·자격(sedan_teardown §4 표).
- **미국 정비사는 손공구를 자기 돈으로 삼**, 큰 장비(리프트·임팩트 공기 공구·진단기)는 가게 것 [S79][S6] → 게임: '내 공구함'(성장) vs '정비소 장비'(투자) 두 갈래.

## 1. 볼트 머리 크기 — 일본 차는 '10·12·14·17·19'
| 볼트 굵기 | ISO/ANSI | DIN(독일) | **JIS(일본)** |
|---|---|---|---|
| M5 | 8 | 8 | 8 |
| M6 | 10 | 10 | **10** |
| M8 | 13 | 13 | **12** |
| M10 | 16 | 17 | **14** |
| M12 | 18 | 19 | **17** |
| M14 | 21 | 22 | **19** |
| M16 | 24 | 24 | 22 |
- 일본 차(캠리 포함) 핵심 = **10, 12, 14, 17, 19 mm**. **13 mm는 주로 유럽 차** 크기 [S1]. 포럼: 10·13 mm가 세계적으로 제일 많이 씀, 20 mm는 거의 안 씀 [S3](검색 요약).
- 미국 차 크기 순위 자료는 못 찾음. 옛 미국 차는 **인치(SAE)** → 정비사는 미터 + 인치 둘 다 [S6].
- **휠 너트 머리**: 17·19·21 mm가 흔함, 22·23 mm·11/16"·13/16"은 드묾 [S9]. 캠리 = 21 mm로 흔히 말함(확인 못 함).
- 학교 공구 목록(검색 요약): 3/8" 소켓 10~19 mm, 1/2" 10~24 mm, 1/4" 6~12 mm, 콤비 렌치 8~24 mm [S8]. 첫날 목록: 콤비 렌치 8~19 mm [S7].

## 2. 소켓·라쳇 말 (Socket wrench)
| 말 | 뜻 | 출처 |
|---|---|---|
| **드라이브 1/4" · 3/8" · 1/2" · 3/4"** | 라쳇 네모 머리 크기(약 6.3·9.5·12.5·19 mm). 작을수록 좁은 데·약한 볼트, 클수록 센 볼트 | [S4] |
| **6각(6-point) vs 12각(12-point)** | 6각 = 면을 잡아 덜 뭉갬, 꽉 낀 볼트용 / 12각 = 30°마다 걸려 좁은 데서 편함. 정비사는 둘 다 | [S5][S4] |
| **얕은(shallow) vs 깊은(deep)** | 얕은 = 좁은 데 / 깊은 = 볼트가 너트 위로 길게 나온 곳(배기 클램프 등) | [S4] |
| **연장대·워블·유니버설 조인트** | 1/2"~20" 연장대, 워블 약 15° 꺾임, 유니버설 = 각도 꺾어 손 안 닿는 볼트 | [S4] |
| **브레이커 바 (breaker bar)** | 라쳇 없는 긴 막대 — 꽉 낀 볼트를 '깨서' 풂(라쳇 망가뜨리지 않게). 첫날 공구에 **1/2", 24"+** | [S4][S7] |
| **임팩트 소켓** | 두꺼운 벽·질긴 합금·검정. 일반 크롬은 임팩트에서 깨질 수 있음(단 검정이라고 다 임팩트용은 아님) | [S4][S5] |

## 3. 조이는 것 → 공구 (캠리 예 포함)
| 조이는 것·일 | 공구 (미국 정비소 말) | 쓸 때 진짜 요령 | 캠리 예 | 출처 |
|---|---|---|---|---|
| 육각 볼트·너트 | 소켓 + 라쳇, 콤비 렌치 | 꽉 낀 건 6각 + 브레이커 바 | 거의 전부 | [S4][S5] |
| 휠 너트 풀기 | **임팩트 렌치 + 임팩트 소켓**, 또는 브레이커 바 | 땅에 있을 때 먼저 풂 | D1 | [S10] |
| 휠 너트 조이기 | 토크 스틱/임팩트로 거의 → **토크 렌치로 마무리** | **별 모양(엇갈려)**, 반 → 전부 2~3번, 오일·그리스 X, 뾰족한 쪽 안으로 | D1 103 N·m | [S9][S10][S11][S12] |
| 토크스(별) 나사 | 토크스 비트/소켓(T10·T30 …) | 십자보다 덜 빠져나옴, "차에 흔함" | D3 T10, A14·B9 T30 | [S15] |
| 바깥 토크스(E-Torx) | E 소켓 — **크기 이름이 T와 다름**(E8 ≈ T40 비트 맞는 자리) | | C15 E8, C21 E6 | [S16] |
| 트리플 스퀘어(XZN, 12각 별) | XZN 비트 M4~M18 | 독일 차(BMW·벤츠·VW), 헤드 볼트에도 — 이중 육각과 헷갈림 | (유럽풍 차) | [S16] |
| 보안 토크스 | 가운데 구멍 난 비트 | 가운데 핀이 일반 비트를 막음 | — | [S15] |
| 십자 나사 | 십자 드라이버 | 낮은 힘에 빠져나옴 | 문 판 S 3 | [S16] |
| 일본 JIS 십자 | JIS 드라이버(머리에 점·X 표시) | 일반 십자는 얕게 앉아 갉음(논쟁 있음) | (일본 차 나사) | [S17] |
| 플라스틱 푸시핀·트림 클립 | **포크 끝 트림 도구, 패널 팝퍼**, 테이프 감은 롱노즈, 90° 픽 | **클립을** 들기(패널 X), 두 조각 클립 = 가운데 핀 2~4 mm 들고 몸통 빼기, 테이프 감은 일자는 마지막 수단 | A4, A11, A16 | [S18] |
| 스프링 호스 밴드 | **호스 클램프 플라이어**(잠금형·긴 것) | 집게로 눌러 밀기 | C12 라디에이터 호스 | [S19][S20] |
| 웜(나사) 호스 밴드 | 너트 드라이버(7 mm·5/16"), 플렉시블 드라이버, 일자 | | C4 흡기 호스 | [S19][S21][S22] |
| 귀(ear) 밴드 | 전용 집게(끼울 때), 니퍼(뗄 때) | | (CV 부트) | [S19] |
| 커넥터 잠금 걸쇠 | 단자 해제 공구(평평한 끝) | 드라이버로 비틀면 부러짐 | 거의 모든 K | [S23](검색 요약) |
| 연료 퀵 커넥터 | **연료관 분리 공구**(관 크기별, 5/16"·3/8" 흔함) | 드라이버로 하지 말 것 | C20 | [S24](검색 요약) |
| 브레이크·연료 관 너트 | **플레어 너트(라인) 렌치** | 6면 중 5면 감쌈 | C10, D8 | [S25] |
| 오일 필터 | **캡 렌치**(좁은 데) / **밴드 렌치**(크기 조절) | 캡 크기 64·65·67 mm 흔함(검색 요약) | C24 | [S26] |
| 오일 드레인 플러그 | 소켓 + 토크 렌치, 개스킷 새것 | 알루미늄 팬 나사 잘 뭉개짐(검색 요약) | C23 40 N·m | [S27][S28] |
| 점화플러그 | **플러그 소켓**(고무/자석, 얇은 것), 간극 게이지, 토크 렌치 | 손으로 끝까지 돌려 넣고 → 토크. 이리듐·백금은 간극 조정 X, 납작 게이지는 틀림 | C6 20 N·m | [S29][S30][S31] |
| 산소센서 | **산소센서 소켓**(홈 난 것, 토요타 SST 09224-00012) | 떨어뜨리거나 친 센서는 교체, 자주 녹으로 붙음 | C22 | [S33][S34] |
| 볼조인트·타이로드 끝 | **나사식 분리기 / 프레스 / 피클 포크** | 피클 포크는 부트 찢음(갈 부품일 때만), 너클을 망치로 쳐서 떼는 법도 | E6, E7 | [S35] |
| 베어링 | 유압 프레스 / 프레스 키트 | 가운데 안 맞추면 튀어나옴 | (허브) | [S36] |
| 코터핀 | 플라이어 | 다리를 꺾어 잠금, **재사용 X**, 성 모양 너트와 짝 | E6, E7 | [S37] |
| 스냅 링 | **스냅 링 플라이어**(안쪽 = 오므림, 바깥 = 벌림) | | E2 구동축 | [S38] |
| 찍어 고정한 축 너트 | 찍힘 펴는 정(SST) + 망치 → 큰 소켓(27~30 mm대 포럼) + 3/4" 브레이커 바, 브레이크 밟고 | 너트 새것 | E1 | [S39][S40](검색 요약) |
| 캘리퍼 피스톤 | 앞 = C 클램프/나사식 공구, 뒤(주차 브레이크) = **되감기(wind-back) 공구** — EPB 차는 스캔툴 모드 | 캘리퍼 떨어져 손가락 끼임 주의, 호스 꺾지 말기 | D4, D9 | [S41][S42] |
| 벨트 텐셔너 | **서펜타인 벨트 공구** 또는 3/8"·1/2" 브레이커 바 | 스프링이 세니 천천히 놓기 | C17 | [S43](검색 요약) |
| 코일 스프링 | **스트럿 스프링 압축기** | §8 위험 | E4 | [S44][S45] |
| 배기 고무 걸이 | **걸이 분리 플라이어**(Lisle 38350 등) | 고무를 받침에서 밀어냄 | F6, F7 | [S52](검색 요약) |

## 4. 안 풀리는(녹슨) 볼트 — 정비사 단계
| 단계 | 진짜 | 출처 |
|---|---|---|
| ① 녹 제거 스프레이(penetrating oil) | **30분 이상 기다리고 다시 뿌림**, 6각 소켓 + 브레이커 바 | [S47] |
| (스프레이 비교, 논쟁 있음) | 풀리는 힘 평균: 안 뿌림 516 · WD-40 238 · PB Blaster 214 · Liquid Wrench 127 · Kroil 106 · **ATF+아세톤 50:50 53**(단위·방법 논쟁) | [S48](검색 요약) |
| ② 충격·냉각 | 탁탁 치기, 냉각 스프레이, 렌치에 렌치 걸어 길게 | [S47] |
| ③ 너트 스플리터 | 너트는 부수고 볼트는 살림 | [S47] |
| ④ 열 | 토치(옛 방법) / **인덕션 히터** = 불꽃 없이 그 자리만 몇 초에 760 °C+, 쇠에 잘 됨(주변 플라스틱엔 여전히 열) | [S49][S50] |
| ⑤ 추출기(extractor) | 구멍 뚫고 반시계 — 나선형은 더 박히거나 속에서 부러질 수 있음 | [S51] |
| ⑥ 마지막 | **부러진 스터드에 새 너트를 용접**해 돌리기 | [S47] |
- 토치 주의: 플라스틱·배선·연료·내장에 불 붙음, 연료관·고무 부싱 근처 불꽃은 쓸데없는 위험 → 냉각 스프레이 + 녹 제거제. 토요타: 연료 부품 일은 불씨 근처 X [S50][S47][S100]. 브레이크 부트·실·호스는 불꽃에 상함 [S35b](검색 요약).
- 실제 시간 이야기는 [hard_to_fix.md](hard_to_fix.md) §1-1.

## 5. 들어 올리기·큰 장비
| 장비 | 진짜 규칙·사실 | 출처 |
|---|---|---|
| **플로어 잭** | 단단하고 평평한 바닥, 정해진 잭 자리만 | [S54] |
| **잭 스탠드** | 토요타: "**잭만으로 받친 차에서 일하거나 두지 말 것** — 안전 스탠드로". 평평한 곳 + 고임목, 정해진 자리, 고무 받침 스탠드, **차를 흔들어 확인** | [S53] |
| 고임목 규칙 | 앞을 내릴 땐 뒷바퀴 **앞**에, 뒤를 내릴 땐 앞바퀴 **뒤**에 고임목 | [S53] |
| (실제 사고) | 뉴욕 정비 사망 12건(1992~2006): 유압 잭 고장, 잭에서 트럭 떨어짐, 비탈에서 굴러감 → 리프트·피트 쓰기, 스탠드, 고임목, 고정 안 된 부품 밑에 스탠드 X / 아이오와: 고임목 없이 견인차가 살짝 굴러 스탠드가 빠져 2명 사망 | [S55][S56] |
| **2주 리프트** | 차 회사 지정 리프트 자리만(추측 X), ALI 리프트 자리 안내서 매년, 직접 만든 받침·나무토막 X / 팔 4개 → 용량 ÷ 4가 팔 하나 한계(뒤가 무거운 트럭 주의) / 일할 높이보다 조금 올렸다가 **기계식 잠금에 내려 앉히기** — "유압만 믿지 말 것", 흔들어 확인 / 매일 점검, 매년 ALI 검사 | [S58][S59] |
| 토요타 리프트 | 스윙 암 = 무게 중심 가운데 + 팔 잠금, 판 리프트 = 고무 블록, 짐 많이 실은 차 들지 말 것 | [S53] |
| **엔진 크레인(호이스트)** | 붐이 늘어나면 **들 수 있는 무게가 줄어듦**(2톤 = 붐 접었을 때 — 늘리면 1톤·1,500 lb·1,000 lb 예) | [S60][S61][S62](검색 요약) |
| 엔진 레벨러 | 크레인에 걸어 엔진 기울기 조절(약 1,200 lb~3톤) | [S62](검색 요약) |
| **미션 잭** | 라쳇·브레이커 바로 올림(임팩트 X), 가운데 맞추고 **끈으로 묶고**, 2명 | [S63](검색 요약) |
| 엔진 서포트 바 | 위에서 엔진을 받치는 쇠 막대(마운트·서브프레임 뗄 때) | [S63](검색 요약) |
| 누움판(creeper) | 바퀴 달린 낮은 판 — 차 밑으로 미끄러져 들어감 | [S64] · `../under_car_work.md` |
| 오일 받이통 | (자료 못 찾음) | — |
| 오일 흡입기(extractor) | 딥스틱 관으로 빨아냄(브레이크액·기어오일·냉각수도), 조금 남을 수 있음 | [S65][S66](검색 요약) |
| 흘림 없는 냉각수 깔때기 | 라디에이터 캡 자리에 끼움, 마개로 넘친 것 막고 뺌, 1/3~반 채우고 히터 켜고 엔진 돌림. **뜨거울 때 캡 열지 말기** | [S67][S68] |
| 브레이크 공기 빼기 | 토요타 = 2명: 블리더에 비닐 호스 → 페달 밟고 → 풀고 → 페달 놓기 **전에** 잠금 → 반복, 통은 MIN~MAX, 페인트에 묻으면 바로 씻기 / 다른 방법: 중력(느림)·진공·**압력(빠름, 정비소 표준)** · 캠리 블리더 8.3 N·m | [S69][S70] |

## 6. 진단·전기 장비
| 장비 | 사실 | 출처 |
|---|---|---|
| 배터리 단자 풀러 | 단자 기둥을 안 망가뜨리고 단자를 뽑음 | [S71] |
| 배터리 시험기 | 멀티미터 = 전압만, **부하 시험기** = 시동 걸 힘이 있는지 | [S72](검색 요약) |
| 멀티미터 | 전압·전류·저항(+주파수·온도). 고전압 일은 CAT III/IV·1000 V 등급 | [S73][S90] |
| 테스트 라이트 | 전기 있다/없다만 — 컴퓨터·**에어백 회로엔 위험**(전구가 전류를 먹음). 토요타 SRS 진단 = 10 kΩ 이상 고저항 계측기 | [S74][S93] |
| OBD-II 스캐너 | 1996년부터 미국 의무, 16핀 J1962, 코드·프리즈 프레임·실시간 값 | [S75] · `../10_electrical_lighting.md` |
| **양방향(bidirectional) 스캔툴** | 부품에 명령(팬·연료 펌프·퍼지 밸브 켜기) — 싼 코드 리더는 못 함. EPB 모드·TPMS 등록·카메라 보정도 이쪽 | [S76] |
| 스캐너 값 | 전문가용 $1,500~3,500, 기본 리더 $100 미만 | [S87] |
| 에어컨 냉매 회수 기계 | EPA 승인 장비 필수, **회수 먼저**, 같은 차에 다시 넣어도 재생해서 | [S77] |
| EPA 609 자격 | 돈 받고 차 에어컨 만지면 **609 자격 필수**(교육 + 시험), 정비소는 장비 인증 1번 + 자격증 기록 3년 | [S77][S78] |
| R-1234yf (새 냉매) | 약간 불붙음, **전용 기계 + 냉매 식별기**(R-134a = SAE J2788, 1234yf = J2843) | [S80] |

## 7. 초보 vs 숙련 — 누가 무엇을 가지나
### 7-1. 누가 사나
- 미국 노동통계국: 정비사가 **렌치·플라이어·소켓·라쳇은 대개 자기 것**, 공기 렌치·선반·용접 토치·잭·호이스트·컴퓨터 진단기는 **고용주 것** [S79]. UTI도 같음 [S6]. 첫날부터 자기 공구를 가져오라는 가게 많음 [S7].
- 가게 스캔툴은 공용 — 마음대로 쓰려면 정비사가 따로 삼, 공구값을 미리 대 주고 월급에서 나눠 받는 사장도 [S83].
### 7-2. 초보(시작하는 정비사·집 DIY) — TechForce '첫날' 목록 [S7]
- 3/8"·1/4" 라쳇·소켓 세트(미터 + 인치), 콤비 렌치 8~19 mm, 드라이버, 플라이어
- **토크 렌치 2개**: 1/2" 20~150 ft·lb, 3/8" 10~80 ft·lb
- **1/2" 브레이커 바 24"+**, 데드블로 망치·볼핀 망치, 프라이 바
- **첫 3달 안**: 기본 OBD-II 스캐너(제일 싼 것 말고), 멀티미터, 테스트 라이트, 단자 키트, 퓨즈 집게
- **일이 생기면**: 오일 필터 렌치, 캘리퍼 되감기 세트, 볼조인트 분리기/피클 포크, 나사산 복구 키트, 누움판
- **소모품**: 녹 제거제, 고착 방지제(anti-seize), 브레이크 클리너, 접점 클리너, 유전체 그리스, 나사 고정제
- **2년차 이후**: 전문 양방향 스캔툴, 오실로스코프, 부품 시험기
- **아끼면 안 되는 것**: 토크 렌치, 잭 스탠드, 전기 시험 장비. 전용 공구는 AutoZone·Advance·NAPA **무료 대여**
- 브랜드: 매일 쓰는 건 Snap-on·GearWrench·Carlyle, 가끔 쓰는 건 Harbor Freight Icon·Pittsburgh Pro (게임엔 실제 상표 X)
### 7-3. 숙련(전문 정비사) — UTI 목록 [S6] + 학교 그림표 [S81]
- 1/4"·3/8"·1/2" 소켓 **6각·12각, 얕은·깊은**, 깊은 임팩트 소켓, 토크스 — 미터 + 인치
- 3/8" 80톱니 라쳇, 연장대, 어댑터, **1/2" 토크 렌치 50~250 ft·lb**, **5/8" 플러그 소켓**
- 조절 렌치, 롱노즈·곡선 플라이어, 24 oz 데드블로, 프라이 바 세트
- **무선 1/2" 임팩트 + 무선 3/8" 라쳇**, 공기 임팩트·공기 라쳇
- 콤비·**플레어 너트 렌치** 세트, 전선 스트리퍼, 멀티미터, 코드 리더, 회로 시험기, **훅·픽 세트**, **청진기**, 점검 거울, 늘어나는 자석
- **55" 롤 캐비닛(공구함)**, 딜러는 전자 토크 렌치·1/4" 12각 세트까지
### 7-4. 돈
- 정비사 한 해 공구값: 대부분 **$2,501~5,000**(2010 조사) [S84]. 공구함 = "정비사가 사는 제일 비싼 단일 물건" [S86].
- 전체 세트 약 $3,000~8,000, 고급 시작 세트 + 공구함 약 $10,000, 싼 시작 세트 $200~400, 최고급은 $80,000까지(검색 요약) [S85].
- 같은 일 다른 값(상표 예): 깊은 소켓 세트 약 $44 vs $645, 토크 렌치 약 $139 vs $449, 공구함 $399 vs 약 $1,540 [S82] — 비싼 쪽 = 재질·마감·평생 보증.
- 정비소 장비(판매사 어림): 2주 리프트 $3,500~7,500, 손공구 $2,000~4,000, 공기 공구 $1,500~3,000, **타이어 체인저 $2,000~6,000**, **얼라인먼트 $5,000~15,000**, 일반 정비소 전체 $45,000~85,000 [S87].
- 공구 트럭 할부 = 전체 값이 많이 커짐 [S7].

## 8. 위험 공구·위험 일 — 진짜 규칙
| 위험 | 진짜 규칙 | 출처 |
|---|---|---|
| **스프링 압축기** | 스프링은 "기름·배터리·들린 차처럼 **에너지를 품고** 있음". 눌린 채 **위 너트를 풀면 스프링이 튀어나감**. 양쪽 고르게 조이기, 두 압축기가 한쪽으로 몰리지 않게, 풀린 스프링을 사람·위로 향하지 않게, 번갈아 천천히 풀기 / 매번 점검(금·녹·홈·거친 나사면 X), 눌린 스프링을 그대로 두지 말기 / 종류: 바깥 집게형·안쪽형·클란(Klann)형(센 스프링), 벽 고정형이 제일 안전(검색 요약) / 안전 사슬, 옆에 서기, **얼굴 가리개** | [S45][S44][S46] |
| **잭만으로 받친 차 밑** | 토요타 "잭만으로 받친 차에서 일하지 말 것", 사망 사례(유압 잭 고장, 병 잭에서 버스 미끄러짐, 비탈) | [S53][S55][S57] |
| **여러 조각 림(split rim)** | OSHA 1910.177: 공기 넣을 땐 **안전 케이지**(최대 압력 150% 견딤), 날아가는 길 밖에 서기, 압력 든 채 링 치지 말기, 교육 필수 — **단 승용차·LT 타이어 픽업·밴은 제외**(트럭·버스·트레일러용) | [S96] |
| **에어백** | 배터리(−) 먼저 + 기다리기: **토요타 90초 이상**, 포드 예 1분, ASE 안내 보통 1~3분(어떤 차 10분) — 매뉴얼 확인 / 저항 재지 말기, SRS 커넥터 찌르지 말기, 열·불 X, **핸들 패드는 펴지는 면 위로** / 토요타: SRS 일 중 보조 전원 X | [S93][S94][S95] |
| **배터리** | 충전 중 **수소**(불붙음) → 불꽃·담배 X, 과충전은 유독 황화수소 / 황산 = 피부 화상 → 보안경·장갑 / 전기 일 전 (−) 먼저, 시동 켠 채 떼지 말기, 언 배터리 점프 X, 배터리 위로 몸 숙이지 말기, **점프 마지막 집게는 죽은 배터리 (−)가 아니라 차체 접지에** | [S89] |
| **에어컨 냉매** | 공기 중으로 빼기 금지 → 회수, 자격 + 인증 장비 / 새는 액체 냉매 = **동상**(보안경·단열 장갑, 검색 요약) / R-134a = 질식, 250 °C 넘는 불·뜨거운 면에서 분해되면 **불화수소** 등 유독 가스 / R-1234yf = 약간 불붙음 | [S77][S102][S101][S80] |
| **하이브리드 고전압** | '고전압' = 50 V 넘음, 하이브리드는 12~650 V / **Class 0 장갑**(교류 1,000 V) + 가죽 덧장갑, 매일 점검, 6개월마다 시험 / 순서: 키 OFF → 스마트키 끄기 → 12 V 배터리 떼기 → **매뉴얼 시간 기다리기(최대 약 10분)** → 장갑 → 서비스 플러그 뽑기 → **0 V 확인**(먼저 아는 전원으로 계측기 시험) → 한 손 규칙 / 프리우스: 288 V+, 주황 선, 플러그 뽑고 5분 이상 | [S90][S91][S92] |
| **토치를 연료·브레이크 관 근처에** | §4 — 불·부트 손상 | [S50][S47][S100][S35b] |
| **임팩트로 휠 너트 끝까지** | 나사·스터드·디스크 망가짐, 임팩트는 "늘 너무 세게 쪽으로 틀림"(포럼) → 마지막은 토크 렌치 | [S10][S9][S14] |
| **고압 세척기** | 약 40 bar(580 psi)면 피부를 뚫음(세척기는 3,000 psi까지), 입구 상처는 작아 보여도 속이 망가짐, 증상이 9~52시간 늦게, 6시간 안 수술이 절단을 줄임 / 2014년 응급실 6,057명(14% 입원), 사람에게 겨누지 말기·보안경·장갑, 고무장화도 뚫림 | [S98][S99] |
| **엔진 크레인 과적** | 붐을 늘리면 용량 줄어듦, 과적으로 붐이 접힌 사례(포럼) | [S61][S62] |
| **브레이크 먼지** | OSHA 부록 F: 음압 덮개 + HEPA 청소기(압축 공기는 덮개 안에서만) 또는 **저압 물 청소**(주 5건 이하 가게), **마른 솔질 금지**, 쓴 필터·천은 적셔 봉함 | [S97] |
| 토요타 기타 | 캘리퍼 떨어져 손가락 끼임, 브레이크 관 꺾지 말기, 휠 볼트·너트에 오일·그리스 X, 뾰족한 쪽 안으로 | [S42][S12] |

## 9. 조임 힘(토크) 기본
- **왜 토크 렌치**: 휠 너트 — 너무 세면 나사 뭉개짐·스터드 늘어남·디스크 휨, 녹·먼지가 끼면 '가짜 토크', 나사에 오일·그리스 X(조이는 힘이 바뀜) [S10][S9][S12]. 플러그 — 손으로 끝까지 → 토크 [S29]. 드레인 — 알루미늄 팬 나사, 와셔 매번 새것 [S28]. 연장대·SST를 토크 렌치에 붙이면 계산 안 하면 실제로 더 세게 조여짐 [S93].
| 값 | 숫자 | 출처 |
|---|---|---|
| 휠 너트 캠리·코롤라 | **103 N·m (76 ft·lbf)**, "2~3번 단단히" | [S11][S9] |
| 휠 너트 일반 | 승용 약 80~100 ft·lb(트럭 더), 콘티넨탈 110~120 N·m + 약 50 km 뒤 다시 | [S9][S10] |
| 토요타 알루미늄 휠 | 처음 1,000마일 뒤 너트 다시 확인 | [S12] |
| 드레인 캠리 A25A | 40 N·m, 개스킷 새것 | [S27] |
| 플러그 캠리 | 4기통 20, V6 18 N·m | [S32] |
| 플러그 NGK 개스킷형 14 mm | 주철 헤드 18.0~25.3 / 알루미늄 18.0~21.6 lb·ft | [S29] |
| 블리더 캠리 | 8.3 N·m | [S69] |
| **토크 렌치 종류** | **클릭형** = 설정값에 '딸깍'. 보관은 가장 낮은 값(0 아님), 라쳇·브레이커 바처럼 쓰지 말고 딸깍에서 멈춤 / **빔형** = 바늘이 눈금 가리킴 | [S104][S105] |
| 정확도·교정 | ISO 6789 ±6%(대부분), 1년에 10%까지 틀어짐 → **5,000번 또는 12달마다 교정** | [S104][S105] |
| 토크 스틱 | 정해진 힘에서 휘는 막대(정확도 주장 제각각) — 조금 못 미치게 → 손 토크 렌치로 끝(검색 요약) | [S13] |

## 10. 게임 공구 단계 제안 (wr-design 참고 — 결정 아님)
| 단계 | 공구 | 열리는 일(캠리 표) | 근거 |
|---|---|---|---|
| 처음 | 손, 기본 렌치 세트(10·12·14 mm), 트림 도구, 스캐너(코드 읽기만) | 배터리 C1, 에어필터 C3, 전구 B2, 와이퍼 B7, 범퍼 A4(클립 퍼즐) | §7-2 첫날 |
| 초보 | 3/8" 라쳇 + 소켓 세트, 드라이버·토크스, 호스 클램프 플라이어, 오일 필터 렌치 + 받이통, 잭 + **스탠드** | 오일 C23·C24, 패드 D4·D6, 라디에이터 호스, 코일·플러그 C6 | §7-2 |
| 중급 | **토크 렌치**, **1/2" 브레이커 바**, 임팩트, 서펜타인 벨트 공구, 플레어 너트 렌치 + 블리더, 멀티미터 | 바퀴 D1, 브래킷·디스크 D5·D7, 벨트 C17, 발전기 C16, 브레이크 호스 D8 | §7-2 첫 3달 |
| 숙련 | **스프링 압축기**, 볼조인트 분리기·타이로드 풀러, 액슬 너트 소켓 + 정, 스냅 링 플라이어, 인덕션 히터, 양방향 스캔툴(EPB·TPMS) | 스트럿 E3·E4, 구동축 E1·E2, 뒤 패드 D9(EPB), 녹 볼트 | §7-3 |
| 정비소 투자 | 2주 리프트, 타이어 체인저, 얼라인먼트, 냉매 회수 기계(609), 엔진 크레인·리프터, 미션 잭 | 콘덴서 C14·압축기 C15, 엔진·변속기 H1·H2 | §5·§6·§7-4 |
- 위험 공구는 '안전 단계'를 빼먹으면 **실패·부상 연출**(스프링 = 위 너트 먼저 풀면 튐, 잭만 = 차 흔들림 경고, 에어백 = 90초 타이머). 고장이 아니라 **규칙을 아는 게 숙련**이라는 현실 그대로.
- **소모품**: 개스킷·O링·코터핀·클립·새 볼트·녹 제거제 → 싼 소모품 상자(돈 조금, 빼먹으면 재작업).

## 출처
(† = 검색 요약만 본 것)
- S1 https://www.zippgroup.com/imperial-metric-bolt-head-wrench-size/
- S2 https://www.mcmaster.com/products/hex-head-screws/jis-specification~jis
- S3† https://www.garagejournal.com/forum/threads/question-about-sockets.520807/post-10284214
- S4 https://en.wikipedia.org/wiki/Socket_wrench
- S5 https://shopgraytools.com/blogs/news/the-ultimate-socket-buyers-guide
- S6 https://www.uti.edu/blog/automotive/automotive-technician-tool-list
- S7 https://techforce.org/build-smart-not-fast-a-tool-buying-guide-for-new-automotive-techs/
- S8† https://wccc.me.edu/wp-content/uploads/Automotive-Technology-Tool-List-1.pdf
- S9 https://en.wikipedia.org/wiki/Lug_nut
- S10 https://www.continental-tires.com/car/tire-knowledge/tire-care-maintenance/retorquing-wheels
- S11 https://www.tocamry.com/installing_the_spare_tire-2013.html
- S12 https://www.tocamry.com/wheels-1993.html
- S13† https://ricksfreeautorepairadvice.com/how-a-torque-stick-works/
- S14† https://forums.edmunds.com/discussion/comment/506534
- S15 https://en.wikipedia.org/wiki/Torx
- S16 https://en.wikipedia.org/wiki/List_of_screw_drives
- S17 https://motofaction.org/mechanical-101/a-what-is-jis-screw-difference-phillips-different-vessel-keihin-carbs-cross-head-japanese-industrial-standard
- S18 https://plasticranger.com/how-to-remove-plastic-push-clips/
- S19 https://en.wikipedia.org/wiki/Hose_clamp
- S20† https://ricksfreeautorepairadvice.com/hose-clamp-pliers-a-must-have-tool-for-spring-band-clamps/
- S21† https://boltdepot.com/Flexible_hose_clamp_driver
- S22 https://en.wikipedia.org/wiki/Nut_driver
- S23† https://www.toolsource.com/misc-c-318/terminal-release-tool-kit-iii-p-191991.html
- S24† https://www.lislecorp.com/specialty-tools/disconnect-tools/35800-aluminum-disconnect-set-6-pc
- S25 https://uniorusa.com/blogs/tech-tips/what-is-a-flare-nut-wrench
- S26† https://bobistheoilguy.com/forums/threads/oil-filter-wrench-size.167253/latest
- S27 https://www.tocamry.com/a25a_fks_oil_and_oil_filter-2082.html
- S28† https://bobistheoilguy.com/forums/threads/reality-check-on-overtightening-drain-plugs.238171/latest
- S29 https://ngksparkplugs.com/en/resources/correctly-install-spark-plugs
- S30 https://en.wikipedia.org/wiki/Spark_plug
- S31† https://engineerfix.com/what-size-socket-fits-spark-plugs/
- S32 https://www.tocamry.com/installation-2086.html
- S33 https://www.tocamry.com/removal-3213.html
- S34† https://www.garagejournal.com/forum/threads/oxygen-sensor-wrench-socket.373730/post-7046706
- S35† https://www.toolsource.com/blog/how-to-separate-a-tapered-tie-rod-end-or-ball-joint-from-a-steering-knuckle-shop-proven-methods/
- S35b† https://phoenixsystems.co/blogs/company-news-tips/can-i-use-a-torch-to-remove-a-stuck-brake-caliper-bolt
- S36 https://vehicleservicepros.com/11588330
- S37 https://en.wikipedia.org/wiki/Split_pin
- S38 https://tameson.com/pages/snap-ring-pliers
- S39 https://www.tocamry.com/removal-2924.html
- S40† https://ricksfreeautorepairadvice.com/how-to-remove-an-axle-nut/
- S41† https://phoenixsystems.co/blogs/company-news-tips/what-is-the-best-tool-to-compress-a-brake-caliper-piston
- S42 https://www.tocamry.com/removal-2101.html
- S43† https://toolsource.com/belt-tensioning-tools-c-1321_139_140/serpentine-belt-tool-p-215724.html
- S44 https://www.fcpeuro.com/blog/3-types-of-coil-spring-compressor-and-removal-tools
- S45 https://wiki.hsbne.org/_export/xhtml/tools/automotive/spring_compressors
- S46† https://www.sitebox.ltd.uk/docs/sealey/pdf/instructions/ak3845.pdf (안전 설명서 — 검색 요약만, PDF 안 엶)
- S47 https://www.journeymanhq.com/?p=714528
- S48† https://www.ferrarichat.com/forum/threads/effective-penetrating-oils-test.390481
- S49 https://www.motor.com/magazine-summary/trouble-shooter-september-2009/
- S50 https://www.vehicleservicepros.com/home/blog/21257024/induction-innovations-blog-why-induction-heat-is-more-precise-safe-and-reliable-than-a-torch
- S51 https://en.wikipedia.org/wiki/Screw_extractor
- S52† https://www.toolsid.com/lisle/exhaust-removal-pliers-mpn-38350.html
- S53 https://www.tocamry.com/vehicle_lift_and_support_locations-2046.html
- S54 https://en.wikipedia.org/wiki/Jack_(device)
- S55 https://healthweb-back.health.ny.gov/environmental/investigations/face/facts/vehicle_repair.htm
- S56 https://stacks.cdc.gov/view/cdc/166806
- S57† https://www.cdc.gov/niosh/face/stateface/ne/99ne018.html · https://www.cdc.gov/niosh/face/stateface/ca/99ca006.html
- S58 https://www.vehicleservicepros.com/industry-news/article/53089961/twin-post-lifts-safety-and-maintenance-tips-2014-11-05
- S59 https://www.autolift.org/?p=23153
- S60 https://en.wikipedia.org/wiki/Engine_crane
- S61 https://www.penntoolco.com/cherry-pickers-personal-lifts/
- S62† https://turbobuick.com/threads/opinions-on-engine-cranes.365981
- S63† https://manuals.harborfreight.com/manuals/61000-61999/61232-792363612326.pdf (검색 요약만) · https://www.turnermotorsport.com/p-366775-schwaben-deluxe-transverse-engine-support-bar/
- S64 https://en.wikipedia.org/wiki/Creeper_(tool)
- S65† https://www.toolsource.com/oil-extractors-c-1321_463_557/fluid-evacuator-plus-88-liter-07201-p-91487.html
- S66† https://audizine.com/threads/oil-extractor-vs-drain-plug-whats-your-method.630962/latest
- S67 https://flyinmiata.com/products/spill-free-coolant-system-bleeding-funnel
- S68† https://www.tocamry.com/engine_coolant-1986.html
- S69 https://www.tocamry.com/bleeding-2760.html
- S70 https://www.dieselarmy.com/tech-stories/breaking-down-the-different-easy-and-essential-brake-bleed-methods/
- S71 https://www.gearwrench.com/all-tools/auto-specialty/engine-tools/202d-battery-terminal-puller
- S72† https://www.partzilla.com/blog/multimeter/vs/battery/tester
- S73 https://en.wikipedia.org/wiki/Multimeter
- S74† https://www.youcanic.com/video/how-to-use-a-test-light-to-diagnose-car-electrical-problems-beginner-friendly-2/
- S75 https://en.wikipedia.org/wiki/On-board_diagnostics
- S76 https://www.innova.com/blogs/fix-advices/what-is-bi-directional-control-how-can-an-innova-scan-tool-help-me
- S77 https://www.epa.gov/mvac/regulatory-requirements-mvac-system-servicing
- S78 https://www.epa.gov/mvac/section-609-technician-training-and-certification-programs
- S79 https://www.bls.gov/ooh/installation-maintenance-and-repair/automotive-service-technicians-and-mechanics.htm
- S80 https://www.motor.com/magazine-summary/a-c-refrigerants-still-not-as-easy-as-1-2-3-4yf-april-2020/
- S81 https://www.autotrainingcentre.com/blog/infographic-auto-mechanics-toolbox/
- S82 https://www.slashgear.com/2028870/harbor-freight-alternatives-to-snap-on-tools
- S83 https://www.ratchetandwrench.com/articles/3146-solutions-for-equipping-technicians
- S84 https://www.vehicleservicepros.com/distribution/tool-distributor/article/10328978/survey-shows-techs-ready-to-spend-money
- S85† https://www.vehicleservicepros.com/service-repair/article/55391274/boxed-in-the-culture-of-the-100000-toolbox · https://www.careervillage.org/questions/532415/
- S86 https://www.vehicleservicepros.com/service-repair/the-garage/article/10334878/making-a-statement
- S87 https://autoleap.com/blog/mechanic-shop-equipment (판매사)
- S89 https://www.aa1car.com/library/battery_safety.htm
- S90 https://www.fluke.com/en-us/learn/blog/automotive/hybrid-vehicle-measurement-safety-basics-taking-high-voltage-readings
- S91 https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.137
- S92 https://toyota-club.net/files/2003/03-09-15_prius-1.htm
- S93 https://www.tocamry.com/precaution-2045.html
- S94 https://rts.i-car.com/srs-4702.html
- S95 https://open-exam-prep.com/study-guides/ase-g1/electrical/body-electrical-accessories
- S96 https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.177
- S97 https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.1001AppF
- S98 https://pmc.ncbi.nlm.nih.gov/articles/PMC6579780
- S99 https://blog.bitco.com/high-pressure-washer-safety
- S100 https://www.tocamry.com/removal-3508.html
- S101 https://en.wikipedia.org/wiki/1,1,1,2-Tetrafluoroethane
- S102† https://pubmed.ncbi.nlm.nih.gov/22658586/
- S104 https://en.wikipedia.org/wiki/Torque_wrench
- S105 https://www.parktool.com/en-int/blog/repair-help/torque-wrench-use-and-care
