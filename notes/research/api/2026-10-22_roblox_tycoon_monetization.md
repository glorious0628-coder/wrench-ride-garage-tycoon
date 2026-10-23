# 로블록스 타이쿤 수익 상품 + 규칙 조사 (2026-10-22, wr-design 조사 도우미 — WebSearch 23회·WebFetch 48회, 브라우저·다운로드 X)

> 방법: 상점 탭이 WebFetch로 안 보여서 로블록스 공개 JSON — 패스 `apis.roblox.com/game-passes/v1/universes/{id}/game-passes?passView=Full&pageSize=100`, 개발자 상품 `apis.roblox.com/developer-products/v2/universes/{id}/developerproducts?limit=100`, 통계 `games.roblox.com/v1/games?universeIds=…`, 좋아요 `…/games/votes`. 평점 % = 좋아요 ÷ (좋아요 + 싫어요). **개발자 상품 목록은 예전·시험 상품까지 다 나옴**(게임에서 실제로 보이는지 모름).

## 1. 비슷한 게임이 파는 것
| 게임 | 방문 · 평점 | 패스 (R$) | 개발자 상품 (R$) |
|---|---|---|---|
| Car Dealership Tycoon | 25.4억 · 92.9% | VIP 500(차·집·걷기 +25%·채팅 태그), 차 칸 ×3 299, 특수 색 80 (2x Money·시즌 패스·차 묶음은 판매 중지) | 돈 $10k/10 ~ $25M/3000, **2X Money 상품 299~599**, **시간제 부스트**(2X 15분 29, 25%~3x 9~499), **시간 건너뛰기**("Complete Now" 799 등), 차 159~1399, **유료 랜덤**(스핀 79/590), 묶음 1599·2349. 시즌 패스 399/599(검색 요약) |
| Restaurant Tycoon 2 | 16.5억 · 93.1% | **자동 수금 200**, 일꾼 칸 500, 요리 2배 빠름 1299, 먹기 2배 600, VIP 손님 2배 450, 수입 부스터 50, 꾸미기 60~250 | 돈 250/75 ~ 10,000/1500(큰 묶음이 R$당 더 많음), 다이아, **시작 묶음 250**(할인 175), **시간제 1.5x·2x** 10분~8시간 40~800, 땅 넓히기 120~3200 |
| My Restaurant! | 8.9억 · 91.6% | 자동 수금 400, 자동 안내 600, VIP 400, 부자 손님 1200, 돈 나무 700, 시작 묶음 200 | 이익 2배 150, 층 50~9000, 돈 700/1500, 젬, **상자(유료 랜덤)** |
| Theme Park Tycoon 2 | 16.2억 · 89.0% | 땅 374, 충돌 끄기 270, 색 90 | 돈 $5,000/8 ~ $1.75M/1500 — **2배·VIP 없음** |
| Retail Tycoon 2 | 3.4억 · 88.4% | 땅 399, 탈것 299·499, 꾸미기 149~299 | 돈만 $1,000/5 ~ $300,000/1000 — **2배·VIP 없음** |
| Lumber Tycoon 2 | 13.4억 · 87.7% | 즉시 짓기 720 등 | 돈 $500/9 ~ $100,000/1799 |
| **[🔧] Repair a Car**(우리와 가장 비슷, 2025-08) | 0.68억 · 86.9% | **VIP 249 · 2x Money 249** · 2x 운 199 · 시작 묶음 19 | 돈 묶음 9~1195, 젬, 일꾼 묶음, 서버 운 79~289, 칸 +1 95~145, 공구 125~225, 꾸미기 부품 9~1799, 상자 |
- **돈 묶음 = 7/7**(전부 크기 고정, 큰 묶음일수록 R$당 많이 줌 — 진행에 맞춰 크기가 바뀌는지는 못 찾음). 땅·칸 6/7, 꾸미기 7/7, **수입 배수(2배) 4/7**(가장 큰 TPT2·RT2… 중 TPT2·Retail·LT2는 안 팖), VIP 3/7, 자동 수금 2/7, 시간제 부스트 2/7, 시간 건너뛰기 2/7, 시작 묶음 3/7, 유료 랜덤 3/7.
- 흔한 값: 패스 50~1299(대부분 150~500), 2배 249~599, VIP 249~500, 자동 수금 200~400.
- **무엇이 가장 잘 팔리나 = 믿을 자료 못 찾음**(2020 DevForum 의견만 — "자동 수금이 제일 좋은 생각", "2배 500은 비쌈").
- 평점: 2배를 파는 CDT·RT2 92.9~93.1% vs 안 파는 TPT2·Retail·LT2 87.7~89.0% — 작은 표본, 상관일 뿐.

## 2. 로블록스 규칙 (공식)
- 패스 = 한 번 사는 것 / 개발자 상품 = 여러 번. 상품은 **`ProcessReceipt`에서 줘야 함**("PromptProductPurchaseFinished does not mean … successfully purchased"). 다른 게임에서 파는 것 2026-05-29부터 막힘. https://create.roblox.com/docs/production/monetization/developer-products · /game-passes
- **경험 구독**: R$ 가격 = 누구나, 49 R$ 이상, 지역 가격 늘 켜짐 / 현지 화폐 = 신분·전화 인증, $2.99~14.99. 수익 70%(현지 화폐는 둘째 달부터 100%). **등급 여러 개 X**("Mutually exclusive subscriptions are not supported"), 산 뒤 혜택에 조건 붙이기 X, 게임당 50개. 나이 제한은 못 찾음 — 13세 미만 부모 지출 한도에 구독 포함(검색 요약). https://create.roblox.com/docs/production/monetization/subscriptions
- **보상형 광고**: 만든 이 = 월 2,000 방문·공개·설문 승인·주인 13+ 인증 / **보는 사람 13세 이상만**(DevForum 2025) / 보상 = 개발자 상품만(로블록스 돈·랜덤 X), 진행을 막는 문으로 강요 X. 2026-03 로이터: 13세 미만 보상형 금지, 광고 등록 2026-05-04부터. https://create.roblox.com/docs/production/promotion/rewarded-video-ads
- **유료 랜덤**: 모든 결과와 확률(%) 표시, 열쇠·스핀권·운 부스트도, 제한 지역이면 대체 길 필수. https://create.roblox.com/docs/production/monetization/paid-random-items
- **어린이 대상**: "avoid using pushy or urgent messages when interacting with minors" — "GET IT NOW" 대신 "View Item", `PolicyService` 필수, 설명은 정확·진실. 13세 미만 월 지출 한도(부모). 2026-05 시드니대 연구: 상위 15개 중 14개에 속이는 구매 설계(가짜 할인·가짜 급함·카운트다운·'꼭 필요해 보이게'·돈 내고 진행). https://create.roblox.com/docs/production/monetization · https://www.sydney.edu.au/news-opinion/news/2026/05/17/inside-the-pay-to-play-world-of-roblox-targeting-children-.html
- **지역 가격**: 패스는 기본으로 켜짐, 개발자 상품은 직접 켜고 **코드가 가격을 읽어야**(하드코딩 X), 최대 70% 아래까지. 가격 실험 도구 = 30일 거래 6만 건 이상. https://create.roblox.com/docs/production/monetization/regional-pricing
- **선물**: 패스 선물 기능 없음(2026-03 요청 중) — 개발자 상품으로 직접 만들어야, 보내는 사람 가격대 ≥ 받는 사람일 때만 권장.

## 3. 2배·이기려고 사는 것과 평점
- 믿을 자료 못 찾음. DevForum 2024 의견: "수입을 직접 돕는 패스(특히 2x cash)는 넣지 마라", 대신 무료로도 버는 프리미엄 화폐. https://devforum.roblox.com/t/monetization-ideas-for-my-tycoon-game/3048249
