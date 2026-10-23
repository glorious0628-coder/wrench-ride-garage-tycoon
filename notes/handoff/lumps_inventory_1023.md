# 차 부품 덩어리(뭉탱이) 목록 — 10-23 13:45 (메인 조사 도우미, 코드·3D 파일 기준)

사용자 13:31 "이게 제일 중요해" — 공개 전에 전부 따로. 계획·담당 = `lumps_plan_1023.md`(이 파일 다음).

## 한 줄 결론
지금 저장된 판(스위치 전부 꺼짐)에서는 세단·SUV·호박차 모두 **떼는 부품 15개뿐**(보닛·범퍼 2·배터리·라디에이터·머플러·바퀴 4·패드 4). 엔진룸·차 밑·바퀴 안쪽·몸통은 옛 덩어리. 따로 판이 실제로 켜질 수 있는 건 세단 엔진룸 위쪽(EngineBay·EngineTop)뿐.

## 스위치 (전부 false)
- Features: NewParts · NewPartsP5 · NewPartsLater · E2Susp · UnderView.
- LiveLumps: **Sedan 줄만 있음** — Deco_EngineBay · EngineTop · Hub_F · Hub_R · Underbody · EngineLower · Transaxle 모두 false. Crossover·PumpkinCoach 줄 없음 → 어떤 스위치로도 못 나눔(PartGraph L79-80).
- 덩어리가 살아나는 조건(PartGraph L69-118): 기능 스위치 + 차 종류 LiveLumps 줄 true + 게시판에선 부품마다 `<id>_Detail` 메시와 `Decor_<lump>V2` 구워져 있어야.
- 서스: `Generated/<type>Susp` 데이터가 없어서 게시판에선 E2Susp를 켜도 안 켜짐(Studio에선 회색 블록).

## 세단
### 떼는 부품
- 지금 15개. 라디에이터 메시 안에 팬·슈라우드·캡이 같이 있음(build_radiator.py).
- NewParts + EngineBay + EngineTop 켜면 +16(AirBoxLid·AirFilter·CoolantReservoir·FuseBoxLid·Fuse_Horn·EngineCover·OilFillCap·Dipstick·IgnitionCoil 1-4·SparkPlug 1-4), 메시 있음.
- P5 +3(RadiatorCover·호스 위/아래), Later +3(IntakeDuct·ThrottleBody·ECM — 3D에 볼트 자리 없음).
- E2Susp +10(Strut·StabLink·Shock·RearArm2·Spring ×2) — **메시 0**(회색 블록).
- BatteryClamp·BatteryTray: 3D에선 뗄 수 있게 만들었는데 부품 줄 없음.

### 덩어리
| 덩어리 | 안에 묶인 진짜 부품 | 따로 판 | 스위치 |
|---|---|---|---|
| Deco_EngineTop | 실린더 헤드·밸브 커버·코일 4·엔진 커버·오일 캡·흡기 러너 4 + 플레넘·스로틀·딥스틱 | ✅ engine_bay_v2 | NewParts + LiveLumps false |
| Deco_EngineBay | 에어박스·배터리 받침·퓨즈 박스·배터리 선·부스터·마스터 실린더·스트럿 타워·워셔 탱크·라디에이터 호스·AC 파이프·콘덴서·하네스 | ✅ engine_bay_v2(63개: 뗄 것 21 + 고정 42, 메시 각각) | false |
| Deco_EngineLower | 엔진 블록·오일 팬 + 드레인 플러그·열 가림판·타이밍 커버·풀리 5 + 벨트·발전기·AC 컴프레서·엔진 마운트 | 메시만(underbody_v1 각각), 부품 줄 0 | false — **보닛 열면 위에서도 보임**(새 부품 밑에 옛 덩어리 남음) |
| Deco_Transaxle | 케이스·벨하우징·마운트 | underbody_v1인데 TransaxleCase가 아직 한 메시(벨하우징+케이스+디프) | false |
| Deco_Underbody | 다운파이프·촉매 + O2 센서 2·가운데 파이프·레조네이터·뒤 파이프·행거 3·열 가림판·언더커버 2·연료 탱크 + 끈 2·EVAP 통·연료 선 | ✅ underbody_v1(61개, 메시 각각), 떼는 건 머플러만 | false |
| Deco_FrontSubframe | 서브프레임·아래 팔 2 + 부싱·볼 조인트·조향 랙 + 모터 + 부트·타이로드·스태빌라이저 + 링크·구동축 2 + CV 부트 | ❌ 게임 안 없음(suspension_v1 Blender 작업 중, 78개) | 스위치 없음 |
| Deco_RearAxle | 뒤 서브프레임·팔들·스프링 자리·트레일링 암·뒤 스태빌라이저 | ❌ (suspension_v1 작업 중) | 스위치 없음 |
| Deco_Hub ×4 | 디스크 + 허브(플랜지·볼트 5·더스트 실드·ABS 센서 + 선) + 캘리퍼 브래킷 | suspension_v1 작업 중 | E2Susp + LiveLumps false, 게시판 불가 |
| 스트럿·스프링·쇼바·너클 | **아예 안 그려짐**(빈자리) | E2 블록만 | E2Susp |
| Deco_BatteryStand | 메시 없는 **블록** | bay v2 BatteryTray | NewParts |
| Decor_Shell | 몸통·펜더 2·**문 4·트렁크 뚜껑**·앞뒤 등·거울·손잡이 한 메시 | ❌ | — |
| Decor_Glass | 유리 전부 한 메시 | ❌ | — |
| Decor_Chassis | 바닥·터널·실·방화벽·카울·프레임·라디에이터 서포트·트렁크 바닥·휠 하우스 | ❌ | — |
| 실내 | 블록 2개(Deco_Interior·Deco_Dash) | interior_v1(128개) 만들었지만 안 올림 | — |

## SUV(Crossover) — 손님 차 30%(Lv1부터)
떼는 부품 15개(같음). 덩어리 `suv_deco_*` EngineBay·EngineTop·EngineLower·Transaxle·FrontSubframe·Underbody·RearAxle + 셸(문 포함)·유리·섀시·실내 블록. **따로 판 아무것도 없음**, LiveLumps 줄 없음, engine_bay_v2를 SUV에 맞춘 적 없음.

## 호박차(PumpkinCoach)
떼는 부품 15개. 셸(셸 + 장식 + 빛)·유리·섀시·자기 Underbody, 나머지는 **SUV 덩어리를 옮겨 씀**. LiveLumps 줄 없음. v4 엔진룸 계획도 아직 장식. 게시판엔 아직 안 구워짐(12번째 굽기가 13:04 전).

## 배경 차
- 묶음 차(BG_Sedan 1-4·Compact·Pickup·Van·_Worn 3): 차 한 대 = 메시 하나(2.1~2.5k▲), 먼 길·폐차장, 만질 수 없음.
- DecorCars(길가 주차·직원·폐차장): 세단/SUV 셸·유리·보닛·범퍼·와이퍼·Lite 바퀴, 섀시·엔진룸·차 밑 없음.

## 10/28 후보(NewParts + EngineBay/EngineTop) 켜면
세단만 바뀜: 옛 EngineBay·EngineTop 숨기고 새 부품 16 + 고정 42. 엔진룸 화면 83.2k → 97.6k▲(+17%), 그리기 81 → 129(+59%). EngineLower·Transaxle 옛 덩어리는 위에서 그대로 보임. 차 밑·서브프레임·뒤 차축·바퀴 모서리는 옛 덩어리. SUV·호박차 변화 0.
