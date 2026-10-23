# wr-dev 인계 (10-21 마감)

상태: 코드 전부 lint·컴파일 통과(71 스크립트), 내 Studio 창(5fbd029f…)은 Play 꺼진 편집 상태. 사진 notes/playtest/wr-dev/01~56.
작업 방식: `src/` 수정 → `py -I tools/luau_lint.py` → `STUDIO_ID=5fbd029f-b0cc-472f-aefb-6b3e4d3f45d3 py tools/sync_to_studio.py` → Play.
시험 도구: `ServerStorage.DevCall`(Dev/DevHooks: rep·money·config·tut·ask·pickup·install·piston·fault·fixFaults 등), DevClient(플레이어 대신 Prompt/원격), 2인 시험 Dev/CoopTest(StudioTestService).

## 한 일 (오늘)
- 루프 B 끝까지: 폐차장 감정(타이틀 CLEAN/SALVAGE/FLOOD/JUNK, 녹 자리별 심각도) → 블록 견인차 → 복원(세척·녹 6단계·기계 수리, 복원도·등급) → 딜러(바로 팔기·주 검사→REBUILT·쇼룸 진열) → 바이어 NPC·흥정 → 이익 나누기.
- car_spec v0.7 CarParts 반영, 바퀴·브레이크 Detail/Lite를 클라이언트 거리 전환으로(틀 = ReplicatedStorage.CarMeshes).
- 튜토리얼 24단계(tutorial_script v0.1), 진행 저장(Tut/TutSkip).

## 시스템 목록 (ServerScriptService/Modules)
PlayerData·DataService(저장) / CarFactory·CarService·FaultService·CarryService·BoltService(차·부품·볼트) / ShopService·EquipmentService·UpgradeService(상점·장비·맵 업그레이드) / LiftService / JobService·CustomerService(손님·정산) / DiagnosisService·StationService(진단·밸런서·청진기·OBD) / JunkyardService·RestoreService·ShowroomService(루프 B) / TutorialService / Places(맵 이름) / ToolKit.
클라이언트(ClientModules): HUD·JobCard·Inspect·Wrench·Carry·Shop·EquipShop·Effects·Balance·Listen·Appraisal·RestoreCard·Dealer·Haggle·CarLook(Detail/Lite)·Tutorial.

## 남은 일
- 배터리 놓는 방향 car_spec v0.8 나오면 CarParts 반영(긴 쪽 앞뒤, 단자 엔진 쪽).
- 3D 메시 업로드 뒤 연결: `ReplicatedStorage.CarMeshes.<Wheel|BrakePads|BrakeCaliper|Hub>_Detail/_Lite`에 넣기만 하면 됨 → 진짜 메시로 전환 튀는지 확인.
- 하체 장식은 리프트가 올라갔을 때만 보이기(아직 없음).
- 산 폐차·진열 차 저장("나중에 마저 하기" 결정 대기).
- 튜토리얼: 2인 Play 확인, "Wrong part — Sell it back"(상점 되팔기 기능 없음), 셋째 손님 대사(대본과 실제 고장 불일치) 결정 대기.
- 견인차·진열·판매가 순간이동 → 몰고 가는 움직임, 1인 소유 표시를 감정 카드에, FLOOD 단서·JUNK 부품 팔기·튜닝.
- 숫자 결정 대기: 판매 평판(Gold 40 등 시험값), 스프레이만으로 Gold 95% 가능 문제.

## 알려진 버그·주의
- MCP screen_capture에는 BillboardGui가 안 찍힘(이름표·말풍선) → 튜토리얼 화살표는 ScreenGui로 그림.
- DevClient로 Prompt 누르기가 가끔 "not shown"(같은 키 가까운 Prompt 우선·카메라) → 시험은 DevCall pickup/install/piston 지름길.
- 렌치를 든 동안엔 Prompt가 숨음(의도) — 시험 스크립트에서 unequip 잊지 말기.
- 피스톤 Prompt 키는 Q(E 줍기와 겹쳐서 바꿈).
