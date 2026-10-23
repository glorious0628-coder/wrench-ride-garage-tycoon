# API 리서치: junk_mechanics (2026-10-21)

- 모델 claude-sonnet-5-5 · effort medium · 비용 약 $0.465 · 검색 14회 · 턴 1 · 끝 end_turn
- 메인 세션 검수 전 자료예요. 숫자는 출처를 보고 다시 확인해요.

Results are JSON strings.
# Junk Mechanics 경쟁작 브리핑

## 1. 한 줄 요약
Junk Mechanics는 고물상에서 부서진 차를 사서 고치고 칠해 되파는 플리핑 게임입니다. 2026-03-12에 만들어졌고, 7개월 만에 방문 6천만 회를 넘겼습니다. 우리 게임과 루프가 가장 많이 겹치는 경쟁작입니다.

## 2. 찾은 것
숫자는 출처마다 날짜가 달라 서로 맞지 않습니다. 대부분 서드파티 집계라 공식 값이 아닙니다.

| 항목 | 내용 | 출처 |
|---|---|---|
| 개발자 | Oil Leak 그룹. 그룹장은 alamo_as, 멤버 51,554명 | Rolimons |
| 출시 | 2026-03-12 생성 | Rolimons |
| 방문 수 | 61,495,588회 (Rolimons, 약 79일 전 스냅샷) | Rolimons |
| 현재 동접(CCU) | 2,933명 (Rolimons). 5,900명 (newgame.co.jp). 10,235명 (BloxBunny, 2026-09-05). 시점마다 크게 다름 | 각 사이트 |
| 최고 동접 | 18,338명 (팬 위키 표기). 공식 확인 못 함 | junkmechanic.wiki |
| 좋아요 비율 | 약 88.2% (👍54,270 / 👎7,261). 즐겨찾기 139,217 | Rolimons |
| 평균 플레이 시간 | 약 13분 (Rolimons 13.47분, BloxBunny 13분) | Rolimons, BloxBunny |
| 장르 태그 | Simulation / Vehicle Sim | MXBLOX, BloxBunny |
| 서버 인원 | 최대 12명 | Rolimons |
| 게임패스 | Premium Garage 399, Portable Jack 199, VIP 399, Big Inventory 179 R$ | 팬 위키, Rolimons |
| 개발자 상품 | 고물상 새로고침 39 R$. 그 외 (확인 못 함) | 팬 위키 |
| 업데이트 | 8/5 [TUNING] (신차 4대, 터보). 8/30 Tuning & More (ECU, 기어 튜닝). 9/20 고물상 확장과 한정 차. 10/3 Cars & Bids (경매). 10/10 할로윈. 대략 2~4주마다 한 번 | 팬 위키, allthings.how |
| 코드 | 좋아요 목표를 채우면 현금 코드를 푸는 방식 (30KTHANKS 등) | thespike, PCGamesN |

**핵심 루프** (팬 위키와 가이드 기준, 공식 노트는 (확인 못 함))
- **차 얻기:** 고물상에서 산다. 고물상은 4종이고, 등급이 높을수록 희귀차 확률이 높다. 유료 새로고침이 있다.
- **수리:** 엔진, 변속기, 라디에이터, 배터리, 브레이크 디스크, 타이어, 휠 7개 부품을 본다. 부품마다 상태 %가 있고, 85~100%까지 고친다. 차를 리프트에 올리는 정비소(Nando)가 있다. 진단 미니게임이 있는지는 (확인 못 함).
- **도색:** 커스텀 숍에서 칠한다.
- **판매:** 구매자는 세 명이다. Juan은 모든 차를 사고 흥정이 된다. Rick은 즉시 구매인데 값이 낮다. Mr. Lupin은 4~5등급 차만 높은 값에 산다.
- **후반:** 튜닝(터보, ECU, 기어), 차 5등급, 경매. 경매는 현금과 프리미엄 키로 하고, 플레이어끼리 입찰도 있다.
- **협동:** 서버에 12명이 같이 있다. 공동 작업이 되는지는 (확인 못 함).

## 3. 플레이어 평가
- 칭찬과 불만을 직접 인용할 댓글이나 Reddit 글은 이번 검색에서 못 찾았습니다 (확인 못 함).
- 간접 신호는 있습니다.
  - 좋아요 88%는 같은 그룹 중앙값(94.7%)보다 낮습니다 (BloxBunny).
  - 즐겨찾기는 방문 1천 회당 2.19로 중앙값 4.08보다 낮습니다.
  - 평균 13분이라 오래 붙잡지는 못합니다.
  - PCGamesN은 독창적인 아이디어는 아니지만 잘 만든 게임이라는 취지로 평가합니다.
- "Fix it up!"이라는 비슷한 게임과 누가 베꼈나 논란이 있습니다. 유튜브 제목은 "Fix it up just COPIED Junk Mechanics"입니다. 영상은 실제 사실 여부가 확인된 게 아니라 의견입니다.
- 가이드에는 Rick의 즉시 구매가 너무 싸다는 초보 실수 경고가 있습니다. 영상에서 본 판매가보다 실제 제안가가 낮다는 불만도 보입니다.
- 과금 쪽은 패스가 편의(인벤토리, 잭, VIP) 중심으로 보입니다. 그러나 강한 pay-to-win인지는 (확인 못 함).

## 4. 첫 3분 (영상은 못 봄, 가이드 기준)
- 튜토리얼을 끝내고 첫 판매를 Juan에게 한다. 코드를 입력한다.
- 싼 고물상 차를 산다.
- 정비소에서 부품을 85~90%까지 고치고, 칠한 뒤 Juan에게 흥정해서 판다.
- 첫 "차 고침" 순간이 몇 분에 오는지는 (확인 못 함). 영상 근거가 없습니다.
- 참고 영상: [Becoming BEST Car Mechanic](https://www.youtube.com/watch?v=gQTqjKQgxRI), [I Built the BEST CAR](https://www.youtube.com/watch?v=LTj8bj0udqA)

## 5. 썸네일과 설명
- 설명 첫 줄은 이모지가 붙은 네 단어 구호입니다. 차를 사서, 고치고, 팔고, 모으라는 뜻입니다 (Rolimons에 인용된 문구 기준).
- 아이콘과 썸네일 스타일은 이미지를 못 봐서 (확인 못 함).
- 게임 이름 앞에 [UPD], [TUNING], [BODYKIT] 같은 태그를 업데이트마다 바꿔 붙입니다.

## 6. 우리 게임에 가져올 것 / 피할 것
1. **가져올 것: 고치기 → 칠하기 → 흥정 판매의 짧은 루프.** 이유: 12명 서버에서 7개월 만에 6천만 방문을 만든 검증된 구조다. 크기 M.
2. **가져올 것: 구매자 캐릭터별 성격(후하게 쳐줌 / 급매 / 고급 전문).** 이유: 판매에 선택의 재미가 생긴다. 크기 S.
3. **가져올 것: 2~4주마다 큰 업데이트와 코드·좋아요 목표.** 이유: 재방문을 만든다. 크기 M.
4. **차별점으로 삼을 것: 진단, 리프트, 볼트 풀기, 증상 기반 수리, NPC 고객 수리와 협동.** 이유: 경쟁작은 상태 % 올리기에 가까워 보여서(확인 못 함) 우리의 현실 정비가 눈에 띈다. 크기 L.
5. **피할 것: 13분짜리 짧은 세션과 낮은 즐겨찾기 비율.** 이유: 후반 목표(복원, 튜닝, 경매)를 초반에 미리 보여줘야 한다. 크기 M.
6. **피할 것: 즉시 판매가 너무 싼 함정.** 이유: 초보가 손해 보고 이탈한다. 안내 문구로 막아야 한다. 크기 S.
7. **패스 가격은 비슷하게 하되 편의와 외형만 판매.** 이유: 인벤토리 179, 잭 199, VIP 399 R$가 기준선이다. 우리 하우스 룰(pay-to-win 금지)과 맞는다. 크기 S.
8. **피할 것: 베꼈다는 논란.** 이유: 같은 용어와 구조를 쓰면 같은 말을 듣는다. 현실 정비와 옛날 자동차 도감으로 차별화한다. 크기 M.

## 7. 출처
- [Rolimons 게임 페이지](https://www.rolimons.com/game/70435795041539)
- [Rolimons 그룹 Oil Leak](https://www.rolimons.com/group/461748520)
- [BloxBunny 통계](https://bloxbunny.com/games/9872734936/tuning-junk-mechanics)
- [MXBLOX](https://mxblox.com/games/junk-mechanics)
- [Zing 통계](https://zing.co.uk/industry-resources/roblox/experience/9872734936--tuning-junk-mechanics/)
- [allthings.how 이벤트](https://allthings.how/junk-mechanics-events-schedule/)
- [팬 위키 junkmechanic.wiki](https://junkmechanic.wiki/)
- [팬 위키 수리 루프](https://junkmechanic.wiki/wiki/repair-loop/)
- [팬 위키 junkmechanicswiki.wiki](https://junkmechanicswiki.wiki/)
- [초보 가이드](https://junkmechanicswiki.wiki/guides/beginner/)
- [newgame.co.jp 가이드](https://newgame.co.jp/metaverse/en/roblox/70435795041539/junk-mechanics/guide/)
- [PCGamesN 코드](https://www.pcgamesn.com/junk-mechanics-codes)
- [TheSpike 코드](https://www.thespike.gg/roblox/game-codes/junk-mechanics-codes)
- [YouTube: Fix it up 논란](https://www.youtube.com/watch?v=1muNrr6okIY)
- [YouTube: ECU 튜닝 업데이트](https://www.youtube.com/watch?v=_dSXDnp9njw)

**한계:**
- Roblox 공식 페이지는 직접 열지 못했습니다.
- Reddit, DevForum, 디스코드 글과 실제 플레이어 댓글 인용은 찾지 못했습니다.
- 위의 팬 위키는 대부분 비공식 사이트입니다. 그래서 부품 목록과 구매자 설명은 확인되지 않은 정보로 봐 주세요.

## 검색에서 본 자료 (자동 수집)
- [Roblox Junk Mechanics codes (September 2026)](https://www.thespike.gg/roblox/game-codes/junk-mechanics-codes)
- [[BODYKIT] Junk Mechanics](https://www.rolimons.com/game/70435795041539)
- [Don't Miss Free Cash Codes for Junk Mechanics!](https://gamerant.com/junk-mechanics-codes-roblox/)
- [Junk Mechanics Codes (October 2026)](https://urgametips.com/junk-mechanics-codes/)
- [List of Roblox games](https://en.wikipedia.org/wiki/List_of_Roblox_games)
- [Roblox oof](https://en.wikipedia.org/wiki/Roblox_oof)
- [Doors (game)](https://en.wikipedia.org/wiki/Doors_(game))
- [Junk Mechanics Wiki - Complete Roblox Game Database (2026)](https://junkmechanic.wiki/)
- [Junk Mechanics Wiki - Codes, Cars & Repair Guide](https://www.junkmechanics.wiki/)
- [Junk Mechanics codes October 2026 - Pocket Tactics](https://www.pockettactics.com/junk-mechanics-codes)
- [Junk Mechanics codes (October 2026)](https://www.pcgamesn.com/junk-mechanics-codes)
- [Junk Mechanics Codes (October 2026)](https://robloxden.com/game-codes/junk-mechanics)
- [Junk Mechanics codes (October 2026)](https://www.sportskeeda.com/roblox-news/junk-mechanics-codes)
- [Junk Mechanics Codes (September 2026)](https://beebom.com/junk-mechanics-codes/)
- [Junk Mechanics Codes (October 2026)](https://mxblox.com/games/junk-mechanics)
- [Junk Simulator codes (April 2025)](https://sportskeeda.com/roblox-news/junk-simulator-codes)
- [Junk Mechanics](https://www.robloxapp.vnggames.com/games/70435795041539/Junk-Mechanics?isAd=false&nativeAdData=&numberOfLoadedTiles=6&page=gameDetailPage&placeId=70435795041539&position=2&universeId=9872734936)
- [Junk Mechanics codes (October 2026) - Dexerto](https://www.dexerto.com/roblox/junk-mechanics-codes-3394945/)
- [Junk Mechanics Codes, Cars, Tier List & Money Method](https://junkmechanics.org/)
- [Junk Mechanics Wiki — Codes, Cars & Repair Guide](https://junkmechanics-wiki.wiki/)
- [Junk Mechanics Wiki — Cars, Codes & Repair Guides](https://junk-mechanics-wiki.wiki/)
- [Junk Mechanics Wiki (Roblox) — Codes, Cars, Tiers & Money Guide](https://junkmechanicswiki.wiki/)
- [Repair & Flip Loop - Junk Mechanics Wiki](https://junkmechanic.wiki/wiki/repair-loop/)
- [Junk Mechanics](https://www.roblox.com/games/70435795041539/Junk-Mechanics)
- [Junk Mechanics Codes September 2026 - RoCodes](https://rocodes.gg/codes/junk-mechanics)
- [Junk Jack](https://en.wikipedia.org/wiki/Junk_Jack)
- [Junk Yard (pinball)](https://en.wikipedia.org/wiki/Junk_Yard_(pinball))
- [Oil Leak](https://www.rolimons.com/group/461748520)
- [Junk Mechanics Events Schedule: Tuning & More Countdown and What’s Next](https://allthings.how/junk-mechanics-events-schedule/)
- [[UPD] Junk Mechanics Roblox Stats, Players, Visits and Trends](https://zing.co.uk/industry-resources/roblox/experience/9872734936--tuning-junk-mechanics/)
- [【Junk Mechanics】最新コード4個とゲーム情報](https://newgame.co.jp/metaverse/en/roblox/70435795041539/junk-mechanics/)
- [[TUNING] Junk Mechanics Player Count — Live Stats & History · BloxBunny](https://bloxbunny.com/games/9872734936/tuning-junk-mechanics)
- [Junk Mechanics Codes October 2026 - All Working Codes](https://www.game.guide/roblox-codes/junk-mechanics)
- [Junk Mechanics Codes (August 2026): No Codes Live Yet, 8,500-Like Unlock Looms - Shane the Gamer](https://www.shanethegamer.com/news/junk-mechanics-codes-august-2026-no-codes-live-yet-8500-like-unlock-looms/)
- [2 NEW CODES & ECU TUNING UPDATE!](https://www.youtube.com/watch?v=_dSXDnp9njw)
- [Junk Mechanics Roblox Codes for October 2026](https://games.gg/roblox/guides/junk-mechanics-roblox-codes-for-october-2026/)
- [ROBLOX: Junk Mechanics - NEW CARS & PAINT + NEW CODES (August 11, 2026) - YouTube](https://www.youtube.com/watch?v=pQiwqOAdy78)
- [Junk Mechanics august 2026 update: Feature Tracking Guide - Junk Mechanics Wiki](https://www.junkmechanics.wiki/updates/Junk-Mechanics-august-2026-update)
- [Tuning Update Notes - Junk Mechanics Wiki](https://junkmechanic.wiki/wiki/updates/)
- [Junk Mechanics Beginner Guide - Junk Mechanics Wiki](https://junkmechanic.wiki/guides/beginner-guide/)
- [Junk Mechanics Beginner Guide (Oct 2026): First Car, Repairs & Selling](https://junkmechanicswiki.wiki/guides/beginner/)
- [Junk Mechanics: The Fastest Money Method for Flipping Cars in Roblox](https://allthings.how/junk-mechanics-the-fastest-money-method-for-flipping-cars-in-roblox/)
- [Junk Mechanics: How to Make Money Fast in Roblox](https://allthings.how/junk-mechanics-how-to-make-money-fast-in-roblox/)
- [Junker test](https://en.wikipedia.org/wiki/Junker_test)
- [Junk Mechanics — Your first steps in the junkyard](https://newgame.co.jp/metaverse/en/roblox/70435795041539/junk-mechanics/guide/)
- [Steal a Brainrot](https://en.wikipedia.org/wiki/Steal_a_Brainrot)
- [Junk Mechanics How to Play: The Ultimate Beginner’s Guide to Roblox Car Building — Junk Mechanics Wiki](https://www.junk-mechanics.wiki/guide/junk-mechanics-how-to-play)
- [Junk Mechanics how to play: Step-by-Step Repair Guide - Junk Mechanics Wiki](https://www.junkmechanics.wiki/guide/Junk-Mechanics-how-to-play)
- [Junk Mechanics beginner guide: Step-by-Step Profit Route - Junk Mechanics Wiki](https://www.junkmechanics.wiki/guide/Junk-Mechanics-beginner-guide)
- [Answer to "junk mechanics copied fix it up" #roblox #robloxfyp #carsoftiktok #junkmechanics #oilleak](https://www.tiktok.com/@zephyr_back/video/7668256985086692629)
- [Fix it up just COPIED Junk Mechanics.. 💀💀 - YouTube](https://www.youtube.com/watch?v=1muNrr6okIY)
- [Junk Mechanic Roblox Tutorial](https://www.tiktok.com/discover/junk-mechanic-roblox-tutorial)
- [Top 10 Best Mechanic Games in Roblox](https://www.tiktok.com/discover/top-10-best-mechanic-games-in-roblox)
- [Junk Mechanics vs Fix It Up: Core Gameplay Differences (August 2026)](https://junk-mechanics-wiki.wiki/guide/vs-fix-it-up)
- [Roblox%E2%80%93Schlep controversy](https://en.wikipedia.org/wiki/Roblox%E2%80%93Schlep_controversy)
- [Becoming BEST Car Mechanic in Roblox Junk Mechanics - YouTube](https://www.youtube.com/watch?v=gQTqjKQgxRI)
- [I Built the BEST CAR in Junk Mechanics! (ROBLOX) - YouTube](https://www.youtube.com/watch?v=LTj8bj0udqA)
- [Junk Mechanics Guides: Repair, Money, Tuning, Auctions and More](https://junkmechanicswiki.wiki/guides/)
