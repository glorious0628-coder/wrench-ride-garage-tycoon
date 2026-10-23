# 우리 게임에 바로 쓸 것 TOP 10 (2026-10-22)

위 세 파일(`tycoon_theory.md` · `video_game_theory.md` · `rise_and_fall.md`)에서 뽑음. 기존 `docs/design/game_textbook.md` 위에 더하는 것. 근거 링크는 각 파일 해당 절에 있음.
표시: **공개 전** = 10/31 전에 되는 작은 것 / **공개 뒤** = 업데이트로. 맡을 세션 제안. (추정) = 우리 판단.

| # | 할 일 | 근거 | 때 | 맡을 세션 |
|---|---|---|---|---|
| 1 | **첫 10분 맞추기**: 30초 안에 첫 볼트, 5분 안에 첫 출고 + 정비소 레벨 바가 참. 끝에 "돌아올 이유 한 줄"(Rosa 차가 기다려요 / 다음 레벨 문). 글보다 화살표·반짝 | tycoon FTUE · Roblox Onboarding 문서 | 공개 전 | wr-dev·wr-ui |
| 2 | **친구와 같이 한 차 고치기를 첫 10분에 넣기** — Roblox 추천이 co-play를 장기 가치 신호로 보고(2026-06 개편, 리텐션 창 28일), 우리 서버는 친구 구조라 잘 맞음 | tycoon Roblox 지표 · FarmVille(플랫폼 알림 의존이 위험) | 공개 전 | wr-design·wr-dev |
| 3 | **재방문 이유는 '즐거운 약속'만**: "Rosa 차가 기다려요 / 친구가 왔어요". 연속 접속 보너스·한정 카운트다운·유료 랜덤 X | video_game_theory 나쁜 강박 고리 · Roblox Monetization 문서 · FTC 사례 | 공개 전(원칙) | wr-design (monetization v2에 board) |
| 4 | **레벨업 = 새 공구 하나 + 그 공구가 필요한 새 고장 하나 짝으로** (이미 full_teardown 공구 5가 이 모양 — 규칙으로 못 박기) | tycoon 해금 리듬 | 공개 전 | wr-design |
| 5 | **난이도 톱니**: 어려운 차 다음엔 쉬운 차(리듬 규칙은 이미 조각 B에 있음). 막히면 정답이 아니라 **단서가 또렷해짐**(소리 커짐) | Flow · difficulty curve | 공개 전(조각 B 켤 때) | wr-dev |
| 6 | **손맛(juice)은 소리·작은 튕김 위주**: 렌치 한 바퀴=볼트 한 바퀴+딸깍, 고친 순간 시동 소리 확 바뀜. 큰 화면 흔들림 X(따뜻한 느낌) | Swink·Vlambeer 자료 | 공개 전 | wr-sound·wr-dev |
| 7 | **공개 전에 2~3개월치 업데이트를 비축**: 매주 업데이트는 방향 맞지만 비축 없으면 끊김. 업데이트를 "새 차 1 + 새 고장 2" 같은 반복 틀로 | rise_and_fall 패턴 1·2 (Roblox 장수 게임·Fall Guys·MultiVersus) | 공개 전(계획) | 메인·wr-design |
| 8 | **돈 숫자는 완만하게**: 가격 = 기본 × 1.15^개수 정도 + 레벨 문. 돈 나가는 곳 3갈래(업그레이드·부품·폐차 감정)를 econ_sim에서 faucet/sink 표로 점검 | Pecorella 비용 공식 | 공개 전 | wr-dev(econ_sim) |
| 9 | **약속은 실제 있는 것만, 공개 땐 작게**: No Man's Sky·Concord 교훈. 가게 소개글에 없는 기능 X(이미 규칙, 유지). 로드맵 공개는 PowerWash처럼 지키는 것만 | rise_and_fall No Man's Sky·PowerWash | 공개 전 | wr-design |
| 10 | **공개 뒤 주 1회 지표 표**: Home Recommendations의 play-through / bounce / D1 / 2~7일 / 8~28일, 약한 구간 하나씩 고치기. 정점 말고 **6~12개월 뒤 유지**를 성공 기준으로 | Roblox Discovery 문서 · RoWatcher | 공개 뒤 | 메인 |

## 덧붙임 (TOP 10 밖, 메모)
- **prestige(환생)**: 정비소에 '리셋'은 어색 → 공개 뒤에 "지점 확장(새 지점은 쉬운 차부터 + 영구 평판 보너스)" 형태로 검토 (추정). 공개 전엔 넣지 않음.
- **Zeigarnik는 기억 효과로는 재현 실패** → 쓸 때는 "하던 일 이어 하고 싶음"으로만 (Finish later).
- **시대 차의 '가끔 나타남'** = 가변 보상의 건강한 형태(돈 내고 뽑지 않음).
- **수익 설계와 이어지는 것**(3·덧붙임 전부) → wr-design에 board로 보냄.

## 이 조사의 한계 (정직하게)
- 공식 문서에 D1/D7 목표 %가 없고, 좋아요 비율·업데이트 주기가 순위에 미친다는 **공식 근거는 못 찾음**. 업데이트 "주 1회 목표, 최소 월 1회"는 Roblox Monetization 문서의 권고.
- Roblox 게임 숫자는 추적 사이트(날짜 불명, 서로 충돌). Among Us·Fall Guys 등 일부는 검색 요약만 봄(본문 서버 차단). 링크 122개 중 일부는 봇 차단(403)이라 열리지 않았으나 주소는 검색에서 나온 것.
- Quantic Foundry 동기 12개 중 6개만 확인. 이론 대부분은 2차 요약 + 원문 링크.
- 회사 내부 포스트모템(GDC)은 못 찾음 → 다음 조사 후보.
