# 자동차 지식 노트 (car_knowledge) — wr-carbook, 2026-10-20

> 사용자: **"자동차 박사가 되어야 함"**, "자동차 뇌피셜 ㄴㄴ 무조건 자료 찾아서", "내부 도안 같은 것도 다 보라고 해".
> 팀 모두(wr-design·wr-art·wr-dev·wr-builder·wr-3d)가 **차에 관한 판단을 하기 전에 여기부터** 봐요. 모르는 건 `notes/handoff/board.md`에 "→ wr-carbook: 질문".
> 말은 쉽게, 내용은 정비사 수준으로. **모든 사실엔 출처 링크**(각 파일 맨 아래). 출처를 못 찾은 건 "(확인 못 함)"이라고 적어요.
> 기준 차 = **가로배치 직렬 4기통 앞바퀴굴림(FF) 중형 세단, 미국 왼쪽 운전석** — 대표로 Toyota Camry XV70(2018~2024, A25A-FKS 2.5 L)의 정비 매뉴얼 그림을 근거로 삼고, Honda Accord·Hyundai Sonata·Nissan Altima로 교차 확인. 게임 좌표·이름은 `docs/specs/car_spec.md`(앞 = −Z, 운전석 = −X).
> 그림체는 캐주얼(사용자 결정 B)이지만 **구성은 진짜 차**. 각 파일 ②의 '알아보게 할 특징 3개'가 캐주얼 그림·3D의 기준이에요.

## 목차

| 파일 | 시스템 | 게임 부품(car_spec) | 상태 |
|---|---|---|---|
| [diagrams/index.md](diagrams/index.md) | **내부 도안 모음**(정비 매뉴얼 분해도·엔진룸 배치도 스크린샷 22장 + '어디에 몇 개로') | 전부 | 프로토 끝 + 엔진·하체 미리 |
| [decor_quickref.md](decor_quickref.md) | **장식 덩어리 참고표**: car_spec §5 Decor 9개 — 실제 모양·자리·색·특징 3개 + 실제 엔진룸 색 지도(사진) (3D용) | Decor 전부 | 끝 |
| [parts_quickref.md](parts_quickref.md) | **부품 빠른 참고표**: 바퀴·브레이크 묶음·배터리·라디에이터·머플러 실제 치수 → stud, 특징 3개, 볼트 자리 (6면·3D용) | 프로토 5종 | 끝 |
| [01_starting_charging.md](01_starting_charging.md) | 시동·충전: 배터리·시동모터·발전기·벨트 | Battery, Alternator, (StarterMotor 후보) | 끝 |
| [02_brakes.md](02_brakes.md) | 브레이크: 디스크·패드·캘리퍼·드럼·브레이크액·ABS | BrakePads, BrakeCaliper, BrakeDisc | 끝 |
| [03_wheels_tires.md](03_wheels_tires.md) | 바퀴·타이어: 구조·편마모·휠 너트·밸런스·얼라인먼트 | Wheel(Rim+Tire) | 끝 |
| [04_cooling.md](04_cooling.md) | 냉각: 라디에이터·팬·워터펌프·서모스탯·호스·냉각수 | Radiator | 끝 |
| [05_engine.md](05_engine.md) | 엔진: 4기통 구조·점화·흡기·오일·엔진 내리기 | EngineBlock, SparkPlugs, AirFilter | 끝 |
| [06_suspension_steering.md](06_suspension_steering.md) | 서스펜션·조향: 스트럿·스프링·컨트롤암·볼조인트·전동 랙 | Strut | 끝 |
| [07_drivetrain.md](07_drivetrain.md) | 구동계: 8단 자동 트랜스액슬(UB80E)·구동축·등속조인트·ATF | (Deco_Transaxle, Deco_FrontSubframe) | 끝 |
| [08_exhaust.md](08_exhaust.md) | 배기: 매니폴드·촉매·산소센서·머플러·걸이 | Muffler | 끝 |
| [09_fuel.md](09_fuel.md) | 연료: 탱크·펌프·인젝터·EVAP·주유 캡 | (Deco_Underbody) | 끝 |
| [10_electrical_lighting.md](10_electrical_lighting.md) | 전기·조명: 퓨즈·릴레이·배선·헤드라이트·경고등·OBD | Headlight | 끝 |
| [11_body_paint.md](11_body_paint.md) | 차체·판금·도색: 보닛·범퍼·녹·샌딩→프라이머→도장→클리어 | Hood, Bumper_F/R, Trunk, Door, Windshield | 끝 |
| [history.md](history.md) | 1886 ~ 지금: 시대별 기술 변화 + 대표 실제 차 + 시대 차 고장 근거 + era_cars 대조 | (era_cars.md 근거) | 끝 |
| [common_jobs_visible.md](common_jobs_visible.md) | **흔한 정비 일 + 보이는 고장 신호**: 일 순위(CarMD·AAA)·시간·순서, 통 F/L·MAX/MIN, 웅덩이 색 8가지, 연기 색, 와이퍼·워셔, '정상 함정' 6개, 3D에 있는 것/더할 것 | fault_looks·work_view 근거 | 끝 |
| [fault_looks_3d_check.md](fault_looks_3d_check.md) | **fault_looks §5b 고증 확인**: 냉각수 F/L 높이·검은 들어 여는 캡·분홍 색, 브레이크액 흰 캡, 워셔 검은 캡(그림 새김)·보닛 뒤끝 노즐·안개 부채꼴·맞는 자리, 와이퍼 26/20 in·정비 위치, 웅덩이 자리·2단 크기 | 메인 3D·wr-design | 끝 (10-21 밤) |
| [under_car_work.md](under_car_work.md) | **차 밑 누워서 작업**: 잭·스탠드·누움판 실제 순서·잭 자리(매뉴얼)·안전 규칙, 누워서 보이는 하체 vs 3D, 누움판 일 vs 리프트 일 | work_view 근거 | 끝 |
| [symptom_variants.md](symptom_variants.md) | **부품별 증상 변주**(같은 부품 = 매번 다른 수수께끼): 손님 말 EN/한·단서 숫자·헷갈리는 짝·고친 뒤 — 7부품 36갈래 | fault_catalog 근거 | 끝 |
| [street_props.md](street_props.md) | **거리 소품 고증**(소화전·우체통·비상계단·주차·쓰레기통·공사 구역·폐타이어·볼라드·가로등·고가 셔틀·모퉁이 소품) — 모양·색·놓는 규칙·출처 | 빌더 근거 | 끝 |
| [detroit.md](detroit.md) | **마을 모티브(모터 시티)**: 1850s~지금 연표, 동네 정비 문화(주유소·크루징·겨울 소금·봄 포트홀), 게임 마을 아이디어, **피할 것**(실제 이름·상표·건물·행사) | 마을·이야기 근거 | 끝 |
| [restoration.md](restoration.md) | **루프 B**: 폐차 감정(타이틀 도장·녹 자리·침수·압축)·복원 순서·실수 함정·중고차 시세·흥정 | flip_loop.md 근거 | 끝 |
| [roster/README.md](roster/README.md) | **베타 손님 차 7종**(세단·SUV·미니밴·픽업·배달 밴·해치백·왜건): 실제 차 크기→stud·구동·서스·흔한 고장·섞을 겉모양 | car_roster.md 근거 | 끝 |
| [teardown/sedan_teardown.md](teardown/sedan_teardown.md) | **★ 세단 완전 분해 지도**(10-22, 사용자 "모든 부위가 따로 + 맞는 도구"): 캠리 XV70 매뉴얼로 차체·램프·엔진룸·바퀴·브레이크·서스·차 밑·실내·엔진/변속기 약 110칸 — 자리·조이는 것(종류·수·N·m)·먼저 뗄 것·공구·무게 + §3 먼저 뗄 것 사슬 + §4 조임 힘 → 공구 단계 | full_teardown·wr-dev 부품 그래프·3D 다시 만들기 | 끝 |
| [teardown/tools_real.md](teardown/tools_real.md) · [teardown/hard_to_fix.md](teardown/hard_to_fix.md) · [teardown/turn_signals.md](teardown/turn_signals.md) | **진짜 공구**(조이는 것 ↔ 공구, 틀린 공구 결과, 초보/숙련, 위험 공구 규칙) · **어려운 차 이유 8가지 + 쉬운→어려운 일 사다리**(Haynes 1~5, 플랫레이트, ASE) · **미국 깜박이 법·자리**(FMVSS 108, 실제 차 11대) | car_difficulty·공구 해금·wr-art-cars | 끝 |
| [roster/pickup_3d.md](roster/pickup_3d.md) · [roster/hatchback_3d.md](roster/hatchback_3d.md) | **3D용 속 구조**(10-22): 픽업 엔진룸·프레임·판스프링·6너트·잭 자리 / 해치백은 뒤쪽만(해치·스트럿·뒷유리 와이퍼) | 3D 도우미·pickup_spec·hatchback_spec | 끝 |
| [glossary.md](glossary.md) | 영어(미국 정비 용어) ↔ 한국어, 영국식 금지어, 손님 증상 말 | 게임 글자 원문 | 끝 |

---

## 한 장 요약 ① — 차가 굴러가는 원리 (가로배치 FF 세단)

1. **불 붙이기(시동)**: 키/버튼 → **배터리(12 V)** 전기가 **시동모터**를 돌림 → 시동모터 작은 톱니가 엔진 **플라이휠 큰 톱니**를 돌려 엔진을 처음 몇 바퀴 돌려 줌 [1][2].
2. **엔진(4행정)**: 실린더 4개마다 ① 흡입(공기+연료 빨아들임) ② 압축 ③ **폭발(점화플러그 불꽃)** ④ 배기 — 이 4박자가 피스톤을 위아래로 밀고, **크랭크축**이 그걸 '빙글빙글'로 바꿔요 [3].
   - 공기: 앞 흡기구 → **에어필터 통** → 스로틀 → 흡기 매니폴드 → 실린더.
   - 연료: 뒷좌석 아래 **연료탱크** → 연료펌프 → 연료 레일 → **인젝터**(요즘 차는 실린더 안에 직접 뿜기도 함) [4].
   - 불꽃: 실린더마다 **점화코일 1개 + 점화플러그 1개**(코일이 플러그 바로 위에 꽂힘) [5].
3. **힘 전달(FF)**: 엔진이 차에 **가로로** 놓이고, 바로 옆에 **트랜스액슬**(변속기 + 차동기어 한 덩어리)이 붙어 → 좌우 **구동축(등속조인트)** 두 개로 **앞바퀴**를 돌려요. 뒷바퀴는 그냥 굴러가요 [6][7].
4. **멈추기**: 브레이크 페달 → (부스터가 힘 보탬) → **마스터 실린더**가 브레이크액을 밀어 → 바퀴마다 **캘리퍼 피스톤**이 **패드**를 **디스크(로터)** 에 꽉 눌러 마찰로 멈춤 [8].
5. **방향·충격**: 핸들 → 스티어링 축 → **랙 앤 피니언** → 타이로드 → 앞바퀴 너클이 돌아감. 앞은 **맥퍼슨 스트럿**(쇼바+스프링 한 기둥) + 아래 컨트롤암 [9][10].
6. **열 빼기(냉각)**: 엔진 열을 **냉각수**가 받아 → **워터펌프**가 돌려 → 앞의 **라디에이터**에서 바람(주행풍 + **전동팬**)으로 식힘. **서모스탯**이 엔진이 데워질 때까지 라디에이터 길을 막아 둠 [11].
7. **배기**: 폭발 뒤 가스 → **배기 매니폴드** → **촉매**(독한 가스를 덜 해롭게) → 가운데 관(공명기) → **머플러**(소리 줄임) → 꼬리관. 촉매 앞뒤에 **산소센서** [12][13].
8. **전기**: 엔진이 돌면 벨트로 **발전기(알터네이터)** 가 돌아 전기를 만들고 배터리를 다시 채움. 시동 중 배터리 전압이 약 13.5~14.7 V면 정상 충전 [14].
9. **두뇌·진단**: 엔진 컴퓨터(ECU)가 센서를 보고 연료·불꽃을 조절. 이상하면 **엔진 경고등(Check Engine)** 을 켜고 **OBD-II 고장 코드**(P0xxx 등)를 저장 → 운전석 무릎 아래 **OBD 단자**에 스캐너를 꽂아 읽어요. 1996년 이후 미국 승용차는 모두 OBD-II [15].
10. **뼈대**: 요즘 세단은 따로 된 프레임 없이 **차체 자체가 뼈대(유니바디)**. 앞 펜더·보닛·범퍼·문은 볼트로, 뒤 펜더(쿼터패널)·지붕은 용접으로 붙어요 [16].

## 한 장 요약 ② — 시스템 지도 (어디에 무엇이)

```
          [앞]  범퍼 커버 ─ 범퍼 철 빔 ─ 콘덴서 ─ 라디에이터 ─ 전동팬
 조수석(+X)        워셔액 통 · 냉각수 보조탱크          배터리 · 퓨즈박스 · 에어필터   운전석(−X)
                  벨트·발전기·에어컨(엔진 오른쪽 끝)  ◀ 엔진(가로, 4기통) ▶ 트랜스액슬(왼쪽)
                                  배기 매니폴드+촉매 (엔진 뒤쪽 아래)
               방화벽 ─ 브레이크액 통·마스터 실린더(운전석 쪽) ─ 와이퍼 카울
  앞바퀴: 스트럿 · 너클 · 디스크+캘리퍼 · 구동축 · 아래 컨트롤암 · 스티어링 랙(서브프레임 위)
  바닥:   배기관(가운데 터널) → 공명기 → 연료탱크(뒷좌석 아래) · 주차브레이크 케이블
  뒤:     뒤 서스펜션(멀티링크/토션빔) · 뒤 디스크 또는 드럼 · 머플러(뒤 범퍼 아래) · 스페어(트렁크 바닥)
          [뒤]
```
- 엔진룸 배치의 근거 그림: [diagrams/01](diagrams/01_camry_xv70_engine_compartment_owners_manual.jpg) — 배터리·브레이크액 통 = 운전석 쪽, 냉각수 통·워셔액 = 조수석 쪽 앞, 맨 앞 콘덴서→라디에이터→팬 [17].
- 트랜스액슬은 **운전석 쪽**: 캠리 매뉴얼에서 시동모터(변속기와 엔진 이음새에 붙음)를 빼려면 **배터리·배터리 받침·에어클리너·ECM을 먼저 떼요** → 이것들이 변속기 위(운전석 쪽)에 얹혀 있다는 뜻 [22]. 벨트·풀리는 반대쪽(조수석 쪽) 끝 — 엔진 편에서 그림으로 다시 확인할 것.

## 한 장 요약 ③ — 게임이 '진짜 같게' 지켜야 할 큰 규칙
| 규칙 | 근거 |
|---|---|
| 배터리: **(−) 먼저 풀고, (+) 먼저 끼움** | 토요타 매뉴얼 [18] |
| 바퀴 너트는 **별 모양(대각선) 순서**로 조임 | 03 파일 |
| 브레이크 패드는 **한 축(좌우) 같이** 바꿈, 새 패드 넣기 전 **피스톤을 밀어 넣음** | 02 파일 |
| 캘리퍼는 **아래 볼트 1개 풀고 위로 젖힘**(토요타) | 매뉴얼 [19] |
| 라디에이터는 **식은 뒤 캡 열기**, 냉각수 빼고 → 갈고 → 채우고 → **공기 빼기** | 04 파일 |
| 머플러: **이음새 볼트 2 + 고무 걸이 2**, 개스킷은 새것 | 매뉴얼 [20] |
| 범퍼는 커버(플라스틱) 뒤에 **철 빔 + 흡수재**가 따로 있음, 헤드라이트는 범퍼를 떼야 빠짐 | 매뉴얼 [21] |
| 도색: **샌딩 → 프라이머 → 색(베이스) → 투명(클리어)** | 11 파일 |
| 연기 색: **흰 김 = 냉각수 / 파란 연기 = 오일 / 검은 연기 = 연료 과다** | 08 파일 |

## 쓰는 법 (다른 세션)
- **wr-design**: car_spec·고장 카탈로그를 고칠 때 각 파일 ④(볼트 수·순서)·⑤(증상→원인→진단) 표를 근거로. 다른 점은 각 파일 맨 끝 'car_spec · fault_catalog와 다른 점'에 모아 둬요(board에도 한 줄).
- **wr-art / wr-3d**: ②(모양·색·알아보게 할 특징 3개) + diagrams 스크린샷. 실제 브랜드 모양은 베끼지 않아요.
- **wr-dev**: ⑤의 숫자(전압·두께·압력·코드) = 진단 도구가 보여 줄 값의 근거.
- **wr-builder**: 정비소 장비(리프트·타이어 탈착기·밸런서·얼라인먼트기)는 03·02 파일의 ⑥.

## 출처
1. Starter (engine) — Wikipedia — https://en.wikipedia.org/wiki/Starter_(engine)
2. Flywheel / ring gear (Starter ring gear) — Wikipedia — https://en.wikipedia.org/wiki/Starter_ring_gear
3. Four-stroke engine — Wikipedia — https://en.wikipedia.org/wiki/Four-stroke_engine
4. Fuel injection (direct/port) — Wikipedia — https://en.wikipedia.org/wiki/Fuel_injection
5. Ignition coil (coil-on-plug) — Wikipedia — https://en.wikipedia.org/wiki/Ignition_coil
6. Front-engine, front-wheel-drive layout — Wikipedia — https://en.wikipedia.org/wiki/Front-engine,_front-wheel-drive_layout
7. Transaxle — Wikipedia — https://en.wikipedia.org/wiki/Transaxle
8. Disc brake — Wikipedia — https://en.wikipedia.org/wiki/Disc_brake
9. Rack and pinion (steering) — Wikipedia — https://en.wikipedia.org/wiki/Rack_and_pinion
10. MacPherson strut — Wikipedia — https://en.wikipedia.org/wiki/MacPherson_strut
11. Internal combustion engine cooling — Wikipedia — https://en.wikipedia.org/wiki/Internal_combustion_engine_cooling
12. Catalytic converter — Wikipedia — https://en.wikipedia.org/wiki/Catalytic_converter
13. Oxygen sensor — Wikipedia — https://en.wikipedia.org/wiki/Oxygen_sensor
14. Alternator (automotive) — Wikipedia — https://en.wikipedia.org/wiki/Alternator_(automotive)
15. On-board diagnostics (OBD-II, 1996 US) — Wikipedia — https://en.wikipedia.org/wiki/On-board_diagnostics
16. Vehicle frame — Unibody — Wikipedia — https://en.wikipedia.org/wiki/Vehicle_frame#Unibody
17. Toyota Camry XV70 Owner's Manual — Engine compartment — https://www.tocamry.com/engine_compartment-1984.html
18. Toyota Camry XV70 Repair Manual — A25A-FKS Battery Removal — https://www.tocamry.com/removal-2073.html
19. Toyota Camry XV70 Repair Manual — Front Disc Brake Pad Removal — https://www.tocamry.com/removal-2101.html
20. Toyota Camry XV70 Repair Manual — Exhaust Pipe Removal — https://www.tocamry.com/removal-3524.html
21. Toyota Camry XV70 Repair Manual — Front Bumper Components — https://www.tocamry.com/components-4187.html
22. Toyota Camry XV70 Repair Manual — Starter Removal (배터리·에어클리너·ECM·배터리 받침 → 시동모터 볼트 2 + 30번 단자 너트 + 커넥터) — https://www.tocamry.com/removal-3602.html
