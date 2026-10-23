# wr-builder 인계 — 10-21

## 맵 버전
- **WorldVersion 13** (`src/ServerScriptService/World/Build.luau`). 약속: `docs/specs/world_contract.md` (★ QA 10-21까지 반영).
- 내 Studio 창: `place/_work/WrenchRide_builder.rbxlx` (id는 notes/handoff/studio.md). 창은 저장 안 함. 맵은 코드로 다시 지어요.

## 지은 것
- Lv1 정비소(베이1·대기실·부품실), 동네·거리·교차로, 주차장, 소품·조명(Play에서 하얗게 안 날림).
- 업그레이드로 바뀌는 맵(UpgradeId/UpgradeState, `Upgrades.apply`): 베이2·3·4, 장비들, 대기실 의자 추가.
- 폐차장(Lv8), 복원 베이·도색 부스·쇼룸(루프 B), Lv16 휠 얼라인먼트 베이·다이노룸·부스 장비.
- 2주 리프트(`Equipment.LIFT`, car_spec v0.7 숫자), 생활감 디테일, 그림 자리 판(ArtSlot), 성능 정리.
- v13 QA 걷기: 문·통로 넓힘, 표시점 6개 이동, 폐차장/부스 문짝, 측정용 인형 제거 → `notes/playtest/wr-builder/qa_1021.md`, 검사 스크립트 `notes/playtest/wr-builder/qa/scripts/`.

## 만드는 법
1. `py -I tools/luau_lint.py <파일>`
2. `STUDIO_ID=<id> py tools/sync_to_studio.py --only ServerScriptService.World`
3. `tools/bake_world.luau`를 Edit에서 execute_luau로 실행 (굽기)

## 남은 일
- 메인: v13을 메인 저장본에 굽기. 저장본에 `workspace.BuilderRefs` 있으면 지우기 (board에 적음).
- wr-dev: 표시점 6개 자리 이동 확인 (이름은 그대로, board에 적음).
- 사용자 결정 필요: 베이1 뒷문을 지나갈 수 있는 문으로 바꿀지 (지금은 닫힌 장식 문).
- 차·손 공구·둥근 소품은 3D 담당(지금은 블록 대역, 속성 `Placeholder3D`).

## 주의할 점
- 손님 길 위 가구는 높이 2 이상이거나 길 밖에 두기: 길찾기가 높이 2 미만은 계단처럼 밟고 넘어가요.
- 문은 빈 폭 5 이상. 손님 길찾기 반지름은 1.5(CustomerService).
- execute_luau는 따로 도는 VM이라, 모듈 이벤트 테스트는 한 번 실행 안에서 끝내기.
- 화면 캡처는 하나씩 차례로 찍기(동시에 찍으면 시간 초과). 첫 장은 흐리게 나올 수 있어 다시 찍기.
- 다른 게임 창이나 wr-dev·메인 창은 건드리지 않기. 키 파일 읽지 않기.
