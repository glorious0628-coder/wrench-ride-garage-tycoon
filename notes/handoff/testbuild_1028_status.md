# 10/28 사용자 시험판 준비 상태표 (wr-release, 2026-10-22 19:07 처음 · **10-23 10:3x 다시 정리 — §0·§1이 최신, §3~§6은 옛 기록**)

근거: `board.md` 줄 번호(아래 "L1234" = board 그 줄) · 게시용 창(`365fbff4`)과 `src/`를 **읽기만 해서 비교한 결과**(굽기·쓰기 없음) · 파일 수정 시각 · `Config.luau`(스위치 전부 false 확인) · `launch.md`.
읽기 많은 board 요약은 API(`ask --job summary` 1번, $0.18)로 초안을 받고 **줄 번호·사실은 원문으로 다시 확인**했어요(초안에 줄 번호·"검수 통과" 판단이 틀린 곳이 있어 고침).

## 0. 한눈에 (10-23 10:3x)
- **'진짜 남은 일' 표 = `launch.md` 맨 위 ★(원본 `notes/handoff/open_items_1023.md`)**. 이 상태표 §1이 그중 스위치 부분이에요.
- 지금 게시용 창 = **8번째 굽기(10-23 09:57)**: 맵 v34 · CarMeshes 125 · 스크립트 146 · 스위치 전부 꺼짐(Features 13 · StoreOn 8). 창 ↔ src 차이 = wr-ui 파일(CurbUI·Scrub·UIStyle 등), 9번째 굽기는 메인이 '굽기'라고 할 때.
- **메인 '통과' 줄이 있는 스위치**: VfxV2(L1313 "목록 OK") · Coffee("10/27 목록 후보" L1212). 나머지는 10/27 밤에 메인이 정함.
- 지운 세션(wr-vfx·wr-art·wr-art-cars·wr-sound·wr-design·wr-pass·wr-anim·wr-builder·wr-carbook·wr-gamer) 일: 끝난 것 대부분 ✅(VFX·소리 id·MechAnim IDS·실내 v34), 주인 없는 것 = 깜박이 3D·저장 안전 시험·보안 L3/L6/L8·공개 뒤 실내 목록 — launch.md ★ 표 §3.

## 1. 스위치 13개(`Config.Features`) — 10-23 10:3x 다시 정리 (Config.Features 13 · 전부 꺼짐, 9:57 확인) — 켤지는 메인 판단
| 스위치 | 지금 | 켜기 전 남은 것 | 담당 | 사용자 결정? |
|---|---|---|---|---|
| Coffee | ✅ 코드·Play 1인(L1216), 메인 "10/27 목록 후보"(L1212) | **2인 시험 기록 없음** · 컵 쥐고 앉는 동작은 공개 뒤 | wr-dev · 메인 | 아니오 |
| ClampTrap | ✅ 배터리 고정쇠 함정 Play 한 바퀴 OK | 목록 후보로 메인 판단 | 메인 | 아니오 |
| MechAnim | ✅ 동작 9 + 잭 펌프·스탠드 3 번호 넣고 진짜 Play 확인(L1320) | 메인이 켤지 · 잭 펌프에서 손이 얼굴 실루엣과 살짝 겹침(작음) | 메인 | 아니오 |
| Minigames | 🔨 서버 6종 손 시험·2인 OK(L1314·L1344) | 광내기 v3·단자 카메라 wr-ui 고침 뒤 wr-mini 통합 재시험 · 공기압 사진 없음 · **10/27 진짜 지연 시험**(Perfect 띠) · 범위 결정일 10/25(사용자는 "6개 다") | wr-ui · wr-mini | 아니오(6개 다 결정 있음) |
| NewParts + LiveLumps(EngineBay·EngineTop) | ✅ 엔진룸 v2.3 연결·굽기·팔레트·스트럿 탑 도장 | **엔진룸 화면 삼각형 94~106k Lite 쓸지** · 메인 품질 검수 | 메인 | 아니오(메인 판단) |
| 차 밑 3D LiveLumps(Deco_Underbody·EngineLower·Transaxle) | ✅ 그리기만 붙음, 켜기 줄 3개(L1247) | 켤지(공개 전엔 그리기만, 부품 줄은 11/14 오일 교환) · 차 밑 조명 어두움(볼트 안 보임, L1293) | 메인 | 아니오 |
| NewPartsLater | ⬜ 흡기 관·스로틀·ECM 줄 등록만 | 3D F_ 점 기다림 → **공개 뒤** | 주인 없음 | 아니오 |
| NewPartsP5 | ⬜ 라디에이터 덮개·호스 | 냉각수 빼기·붓기를 wr-mini 냉각수 채우기와 어떻게 이을지 **메인 결정** → wr-dev | 메인 → wr-dev | 아니오 |
| Stars | ✅ 코드·분포 고침(편중 FaultService 창에 있음) | 켜기 = 한 줄, wr-ui 별 한 줄·정산 줄 확인(L846) | 메인 · wr-ui | 아니오 |
| ToolMatch | ✅ 코드, 공구 칸 넘침 wr-ui 처리 | 켜기 판단 · 2인 시험 안 돌림 · 공짜 공구(Lv6) | 메인 · wr-dev | 아니오 |
| UnderView | ✅ 누움판 3D 업로드·v32 반영·누운 높이 고침(L1293) | 켤지(머플러 Lv6이 공개 판에 들어갈지) · 누움 애니는 공개 뒤 | 메인 | 아니오 |
| E2Susp | 🔨 블록·고장·Guide 안내(서스 단계 7줄, Play OK) | **서스 3D 없음**(78노드 38.6k tris 줄이기 남음) — 10/27까지 안 오면 뺌(사용자 "퀄리티 안 되면 빼고") | 메인(3D) | 아니오 |
| VfxV2 | ✅ 메인 "VfxV2 목록 OK, 웅덩이 v2c 켜도 됨"(L1313) | 켜기 | 메인 | 아니오 |
| VfxSparkle | ✅ 크게 고침(GPT 통과, 서버 신호로 확인, L1284) | **배터리 불꽃 움직임은 사용자 눈 한 번** · 켜기 | 메인 | **예(눈 한 번)** |
| StoreOn 8 | ⬜ 판매 꺼짐, 코드·화면·상품 id 있음. 보안 C1~H3 코드 끝(L1086) | **메인 보안 확인 줄 없음** · 10/28 다른 계정 구매 시험 · 판매 켜기는 메인(사용자 OK 뒤) | 메인 | 예(무엇을 팔지는 10-22 결정 있음 — 켜는 날만) |


## 2. StoreOn · LiveLumps
| 이름 | 맡은 세션 | 지금 상태 | 메인 검수 | 켜려면 남은 것 | 10/27 후보? |
|---|---|---|---|---|---|
| **StoreOn** (8개: StarterPack·PayBoost·CashSmall/Medium/Big·VIPMechanic·GoldTools·GarageRename) | wr-pass 설계 · wr-dev 코드(StoreService L1023) · wr-ui 화면(StoreUI L1042) · 만들기 wr-release(패스 3·봉투 3, 판매 꺼짐 L1045) | 코드·화면·상품 id 다 있음, **8개 전부 false**(Config 확인). 가게 화면은 판매 켠 것만 보임 | ❌ — 메인 메모 7번 "보안 Critical 고침 + 메인 확인 뒤"인데 **메인 확인 줄 board에 없음**(보안 C1~H3 끝 보고는 L1086, 창에는 이미 들어감) | ① **메인 보안 확인** ② **10/28 구매 시험**(다른 계정 — 지금 계정들은 다 '가짐', L968) ③ 로블록스 for-sale은 사용자 · 판매 켜기는 메인만, 사용자 OK 뒤. wr-pass: "10/28 문 통과한 것만 10/31 켬" | **아니오** — 10/28 구매 시험 뒤 10/30~31(메인이 따로 말할 때만 켬) |
| **LiveLumps.Sedan** 4개(Deco_EngineBay·EngineTop·Hub_F·Hub_R) | wr-dev | 전부 false. 켜짐 조건 = Features.NewParts(Hub는 E2Susp) + 그 줄 true + (Studio 밖) 부품 메시 `_Detail` 다 구워짐 — **EngineBay·EngineTop 메시는 CarMeshes 118에 구워짐**, Hub는 서스 3D 없어서 안 구움 | ❌ | NewParts와 **같이** EngineBay·EngineTop만 | NewParts와 같이(**Hub_F/R은 E2Susp 따라감 = 보통 뺌**) |

## 3. 게시용 창에 아직 안 들어간 파일 (읽기 전용 비교, 10-23 09:31 — 7번째 sync 뒤)
창 id `7890e91d…` ↔ `src/` 146개 중 **10개가 다름**(창에만 있는 것 0). 09:2x에 sync한 25개(wr-ui 10 · wr-vfx 5 · wr-mini 6 · wr-dev 2 · wr-anim 1 · LocaleKo)는 들어가 있음. 그 뒤에 또 고쳐진 것 = 다음 sync 대상:

| 누가(추정) | 파일 (수정 시각) | 메모 |
|---|---|---|
| wr-ui / wr-dev | `Shared/Locale`·`Shared/LocaleKo`(09:26) · `ClientModules/Guide`·`GuideGlow`(09:25~26) · `ClientModules/Scrub`(09:30) | 글·안내·문지르기 — 아직 일하는 중 |
| wr-mini | `Modules/MinigameService`·`Dev/DevHooks`(09:25) | 미니 게임 서버 계속 고침 |
| wr-builder | `World/Build`(09:30)·`World/Interior`(09:31) | 맵 v33 작업 중 — 굽기 부탁 줄을 기다림 |
| ? (주인 모름) | `ClientModules/Inspect`(09:23) | 부탁 줄 없음. 이번 sync에서 뺌 — 누가 고치는지 board에 물어봄 |

## 4. (옛 10-22 19시) launch.md 표에서 10/28 전에 끝나야 하는데 ⬜인 줄 — 10-23에 launch.md 표를 고쳤으니 최신은 launch.md ★ 표
| 줄 | 할 일 | 상태·내 의견 |
|---|---|---|
| 12 | 10/27(화) 밤 메인이 **켤 스위치 목록**을 wr-release에 줌 | ⬜ — 10/27 밤 일정 그대로. §1·§2가 목록 만들 재료 |
| 25 | **E2 스트럿·스프링**(3D·Guide·LiveLumps Hub) | ⬜ — 설계 ✅, 블록 ✅, **3D 78노드 Detail 38.6k tris·줄이기 남음**. 10/27까지 3D 검수·bake 안 되면 빼기(사용자 "퀄리티 안 되면 빼고") |
| 29 | 공구 4~5 시안(6면) → 3D | ⬜ — 손 공구 2차 4개 3D ✅ 10-22 16:10(wr-release 메모)·공구 3D 5번 굽기에 들어감. **표 업데이트 필요**(메인이 '끝'으로 바꿀지) |
| 30 | 첫 묶음 부품 3D(부품마다 따로) | ⬜ — 엔진룸 v2.3 ✅, 캘리퍼·브레이크 등 QA 번호 ✅(5번째 굽기). **서스 부품만 미완**. 표 업데이트 필요 |
| 33 | 첫 묶음 들어간 판으로 wr-play·wr-gamer 시험 → "게시해도 돼요" | ⬜ — 10/28 오전 굽기 뒤라야 시작. 10/28 사용자가 플레이하는 날과 겹침 |
| 74 | 저장 안전 확인(나갔다 들어오기, 서버 꺼짐), 게임 패스 판매 켜기 | ⬜ — **보안 C1~H3·세션 잠금·영수증은 코드로 끝**(L1086), 진짜 나갔다 들어오기 시험은 board에 없음. 10/29 사람 시험 전에 필요 |
| 58 | 시험 1에서 나온 것 고치기(옛 목표 10/24) | ⬜ — 목표 날짜 지났음, board상 wr-play 시험 3·all_report 고침(L1000~) 있음 → **표를 ✅/🔨로 바꾸자고 메인에 제안** |
| (참고) 86 | 호박차·Ella·드레스 3D → 업로드 | ⬜ — 10/30까지, 10/28 전 아님. 3D 일이 메인이라 늦어지면 10/30 밤 굽기 위험 |
| (참고) 64 | 10/29 사람 시험에서 눈으로 볼 것 | ⬜ — 10/29 일 |

## 5. 사용자 시험판(10/28)에 필요한 것 — 굽기 전날까지 정리
1. 메인: **10/27 밤 스위치 목록**(위 §1 표 12 + §2 StoreOn은 '꺼 둠' 권장).
2. 각 세션이 끝낼 것: wr-mini(6종 서버) · wr-ui(고침 3 + 광내기 + 아이콘 7) · wr-vfx(뾰로롱 크게) · wr-dev(차 밑 3D 연결 알림 + 서스 3D 여부) · wr-anim(업로드 OK 기다림) · wr-art(웅덩이·손가락, 19:00 뒤).
3. 메인이 직접: MechAnim 9개 업로드 판단, 엔진룸 팔레트 이미지 업로드, 누움판 3D, 서스 3D 도우미, UnderView·MechAnim 켤지.
4. wr-release(나): 10/28 오전 굽기 순서 = `sessions/wr-release.md` '굽기 순서' 그대로. 켜기 전에 이 표 §3 파일이 전부 들어갔는지 읽기 전용 비교(`diff_only.py` 같은 방식)부터 한 번.
5. 알아 둘 점: board L1216의 새 id `2e2cbe71`은 옛 표기 — 실제 열린 게시용 창은 `365fbff4`(19:04 `list_roblox_studios`, studio.md 표와 같음).


## 6. 10-22 19:2x 갱신 (wr-release, 메인 19:15 지시)
- §1 MechAnim·NewParts 칸 고침(위). 누움판·실내 소품 3D는 메인 도우미가 만드는 중(Amano 안 삼, L1237).
- 맵 v31: 디스크 `Build.VERSION = 31`(19:07)이 보이지만 `Interior.luau`가 19:15에도 바뀌어서 **굽기 부탁 줄을 기다림**(wr-builder에 board 19:16로 물음). 지금 게시용 창 = v30.
- 게시용 창 id가 `d942a691-b8ee-4add-90ac-07e9c09cd26b`로 바뀜(19:15 `list_roblox_studios`, 옛 365fbff4는 닫힘).
- launch.md 29줄 ✅·30줄·58줄 🔨로 고침(증거 = board L1100·L1111·L1216·L896).- (19:2x) wr-dev 답(SendMessage): CarParts·PartGraph·Sedan3D·SedanUnder·CarLook·Guide 6개 sync OK(스위치 꺼진 채 변화 = Guide 안내 줄뿐). **새 `PartData/Sedan3D`+`PartData/Generated/SedanUnder` 꼭 같이**(CarParts가 require), Config·Faults·Diagnosis·FaultService·DiagnosisService·StationService·Locale·LocaleKo도 같이. HUD.luau는 wr-ui 몫. **굽기는 wr-dev의 엔진룸 스트럿 탑 도장 bake 줄 뒤에 한 번에**. 튜토리얼 카드 남음은 wr-dev가 진짜 건너뛰기로 확인.


## 7. 10-23 09:3x 갱신 (wr-release 새로 시작, 메인 아침 지시)
- 게시용 창 다시 엶: id **`7890e91d-a5cb-421e-93dd-4de931e8541b`**(studio.md 고침). 열자마자 확인 = 맵 v32 · 파트 4,284 · CarMeshes 125 · 스크립트 145(저장본과 같음).
- **7번째 굽기**(09:25~09:31): sync 25개(`--only`) → lint 0 · locale 985=985 · 컴파일 145 오류 0 · bake_carmeshes 68줄 전부 ok("Under v1 ok" 2번 포함) → CarMeshes 125(빈 메시 0, MeshPart 247) · Play 게임 오류 0(DataStore 403만) · **스위치 전부 꺼짐**(Features 13 · StoreOn 8 · LiveLumps 4 — `Features`가 12 → **13개**, wr-dev의 `ClampTrap` 추가) · 저장함(09:31). 맵은 v32 그대로라 안 굽음.
- 폰 667×375 한국어 확인 사진 `notes/playtest/wr-release/ko_667/`(10장) — 결과는 board.

## 8. 10-23 09:57 갱신 — 8번째 굽기
- 맵 **v34**(4,271파트) · CarMeshes 125 · 스크립트 146 · 스위치 전부 꺼짐 · 저장 09:57. 창 ↔ src 남은 차이 = wr-ui `CurbUI`·`Scrub`·`UIStyle` 3개(§3 표는 이 3개만 남은 걸로 읽기). 보닛 → 스캐너 → 배터리 클릭 확인 OK.

## 9. 10-23 11:08 갱신 — 9번째 굽기
- 맵 v34 · CarMeshes 125 · 스크립트 147 · locale 995=995 · 스위치 전부 꺼짐 · 저장 11:07 · **창 ↔ src 차이 0**. 다음 굽기는 메인이 '굽기'라고 할 때(안전 순서: 바뀐 파일마다 lint + luau_check → 깨진 건 빼고 주인에게 board).

## 10. 10-23 11:28 — 10번째 굽기
- 맵 v34 · CarMeshes 125(세단·SUV 앞 주황 깜박이 v2.1·v2.2 구워짐) · 스크립트 147 · 스위치 전부 꺼짐 · 저장 11:27 · 창 ↔ src 차이 0.
