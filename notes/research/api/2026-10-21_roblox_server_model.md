# API 리서치: roblox_server_model (2026-10-21)

- 모델 claude-sonnet-5-5 · effort medium · 비용 약 $1.069 · 검색 14회 · 턴 1 · 끝 end_turn
- 메인 세션 검수 전 자료예요. 숫자는 출처를 보고 다시 확인해요.

Returns JSON string. Let me fetch pages directly and grep.
Good: .md version is accessible. Fetch it.
Search works. Fetch is exhausted; I'll use searches.
Now more targeted searches.
# Roblox 서버 사실 확인 (공식 문서만)

**한 줄 요약:** 텔레포트, 비공개 서버, 초대, 친구 확인 API는 공식 문서로 일부 확인했습니다. 예약 서버와 친구 "Join" 버튼의 관계, 예약 서버 수명, 서버 최대 인원, 가득 찬 서버의 Join 동작은 공식 문장을 못 찾았습니다.

검색 도구 한도가 중간에 소진되어 몇몇 페이지는 전문을 읽지 못했습니다. 아래 인용문은 검색 결과 발췌에서 가져왔습니다. 따옴표 안은 20단어 미만으로 줄였고, 원문은 영어입니다.

## 1. 예약 서버 (ReserveServerAsync / ShouldReserveServer / ReservedServerAccessCode)

| 질문 | 사실 | 짧은 인용 | 링크 | 확신 |
|---|---|---|---|---|
| 접속 코드 사용법 | 기존 예약 서버에는 접속 코드(ReservedServerAccessCode)를 넣어 들어갑니다. 새 예약 서버는 ShouldReserveServer=true로 만듭니다. | "a unique code for entering a reserved server" | [Teleport 가이드](https://create.roblox.com/docs/projects/teleport) | 높음 |
| 친구 Join 버튼으로 예약 서버 안의 사람을 따라갈 수 있나 | (확인 못 함) 공식 문서에서 이 내용을 찾지 못했습니다. 개발자 포럼에 같은 질문이 있지만 공식 답이 아닙니다. | – | [포럼 질문(비공식)](https://devforum.roblox.com/t/questions-about-reserved-servers/3641358) | 낮음 |
| GetPlayerPlaceInstanceAsync / TeleportToPlaceInstance로 찾기 | (확인 못 함) 두 함수는 존재하고 GetPlayerPlaceInstanceAsync는 Yields입니다. 예약 서버를 찾는지는 문서에 없습니다. TeleportToPlaceInstance는 Deprecated입니다. | – | [TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService) | 중간 (존재만) |
| 수명 | (확인 못 함) 만료 시간 문장을 못 찾았습니다. | – | – | – |
| 누가 들어갈 수 있나 | 코드를 가진 서버 스크립트가 지정해 보낸 플레이어입니다. 포럼 답변은 "코드로만 접근된다"는 취지였습니다. 이는 비공식입니다. | – | [포럼(비공식)](https://devforum.roblox.com/t/how-to-use-teleportservice-with-reserved-settings-to-other-place/2431776) | 중간 |
| 코드와 플래그 동시 사용 | 둘을 같이 쓰면 오류가 난다는 포럼 보고가 있습니다. 비공식입니다. | – | [포럼](https://devforum.roblox.com/t/i-still-have-a-little-doubt-about-teleportoptions/2031752) | 중간 |

- 공식 예제는 ReserveServerAsync로 코드를 받고 TeleportToPrivateServer로 보냅니다.
- 코드를 DataStore에 저장해 다시 쓰는 예제도 있습니다.
- ReserveServer와 TeleportToPrivateServer는 Deprecated입니다. TeleportAsync와 TeleportOptions를 쓰세요.

## 2. 비공개 서버 (Private Servers)

| 질문 | 사실 | 짧은 인용 | 링크 | 확신 |
|---|---|---|---|---|
| 규칙 | 구독형 기능입니다. 플레이어가 누구와 같이 놀지 정합니다. | "While private servers can be free" | [Private servers](https://create.roblox.com/docs/production/monetization/private-servers) | 높음 |
| 무료로 열 수 있나 | 됩니다. Access Settings에서 "Allow private servers"를 켜고, "Requires Robux"를 끄면 모두에게 무료입니다. | "Disable Requires Robux to make private servers free to all." | 위와 같음 | 높음 |
| 제한 | 가격을 바꾸면 활성 구독이 모두 취소됩니다. 유료 접근(Robux/현지 통화)과 비공개 서버는 동시에 켤 수 없습니다. 만 13세 미만은 설정에 따라 못 들어갈 수 있습니다. | – | 위와 같음 | 높음 |
| PrivateServerId / OwnerId | (확인 못 함) 이번에 속성 문서를 못 열었습니다. | – | – | – |
| 친구 Join 버튼 | (확인 못 함) | – | – | – |

## 3. SocialService:PromptGameInvite

| 질문 | 사실 | 짧은 인용 | 링크 | 확신 |
|---|---|---|---|---|
| LaunchData | 초대 옵션의 LaunchData는 최대 200자입니다. 친구가 초대 알림으로 들어오면 Player:GetJoinData()에서 읽습니다. | "Maximum of 200 characters." | [Invite prompts](https://create.roblox.com/docs/production/promotion/invite-prompts) | 높음 |
| 서버 측 처리 | 서버에서 launch data를 확인하라고 안내합니다. | – | 위와 같음 | 높음 |
| 특정 친구 초대 | InviteUser에 UserId를 주면 한 명을 초대합니다. 없으면 친구 목록 선택창이 뜹니다. | – | [ExperienceInviteOptions](https://create.roblox.com/docs/reference/engine/classes/ExperienceInviteOptions#InviteUser) | 높음 |
| 초대 수락 시 초대자와 같은 서버(instance)로 가나 | (확인 못 함) 문서가 같은 서버 배치를 명시한 문장을 못 찾았습니다. | – | – | – |
| 초대자가 예약 서버에 있을 때 | (확인 못 함) | – | – | – |
| 추천인 | 모든 초대 유형에서 GetJoinData()의 ReferredByPlayerId가 채워집니다. | – | [Referral](https://create.roblox.com/docs/production/promotion/referral-system) | 높음 |

## 4. TeleportService 실패 처리와 한도

| 질문 | 사실 | 짧은 인용 | 링크 | 확신 |
|---|---|---|---|---|
| 호출 방식 | TeleportAsync는 PlaceId, 플레이어 배열, 옵션을 받습니다. 그룹 텔레포트도 이 배열로 합니다. | – | [Teleport 가이드](https://create.roblox.com/docs/projects/teleport) | 높음 |
| 재시도 | pcall로 감싸고 몇 번 재시도하라고 권합니다. 예약 서버 관련 실패에 특히 도움이 됩니다. | "we recommend retrying some number of times on failure" | 위와 같음 | 높음 |
| TeleportInitFailed | 호출은 성공해도 마지막에 실패할 수 있고, 이때 이 이벤트가 발생합니다. | – | 위와 같음 | 높음 |
| 공식 예제 값 | 재시도 5회, 재시도 간격 1초, FLOOD_DELAY 15초입니다. | – | 위와 같음 | 높음 |
| 레이트 리밋 숫자, 1회 최대 인원 | (확인 못 함) | – | – | – |
| 친구 합류 설정 | Fully open이면 친구 Join으로 어느 place든 들어옵니다. 안 그러면 시작 place로 갑니다. | "players who try to join their friends in non-start places will instead join your game's start place." | 위와 같음 | 높음 |

## 5. 서버 크기와 채우기

| 질문 | 사실 | 링크 | 확신 |
|---|---|---|---|
| Players.MaxPlayers, PreferredPlayers | 두 속성이 Players 서비스에 있습니다. | [Players](https://create.roblox.com/docs/reference/engine/classes/Players) | 중간 |
| 대시보드 최대치, 서버 채우기, 친구 함께 배치 | (확인 못 함) 공식 문장을 못 찾았습니다. | – | – |

## 6. 친구 확인 API

| 질문 | 사실 | 링크 | 확신 |
|---|---|---|---|
| Player:IsFriendsWith | Deprecated입니다. 대체 API는 IsFriendsWithAsync이고, Yields입니다. | [Player](https://create.roblox.com/docs/reference/engine/classes/Player) | 높음 |
| Players:GetFriendsAsync | Yields이고 FriendPages를 반환합니다. | [Players](https://create.roblox.com/docs/reference/engine/classes/Players) | 높음 |
| 레이트 리밋 | (확인 못 함) | – | – |

## 7. 개인 서버와 가득 찬 서버

- 탈 것: tycoon용 "personal server"나 "solo instance" 공식 가이드는 (확인 못 함).
- 가득 찬 서버에서 친구 Join 동작은 (확인 못 함).

## 우리 게임에 주는 의미

1. **로비에서 예약 서버로 가는 방식은 위험도가 큽니다.** 친구 Join이 예약 서버에 안 먹힐 가능성이 있습니다. 확인 못 한 항목이라 Studio 테스트(2계정, 모바일 앱)가 필요합니다. (크기 S)
2. **초대는 PromptGameInvite 대신 예약 서버 코드를 직접 공유하는 방식을 쓰세요.** 초대가 같은 서버로 가는지 확인 못 했습니다. 코드는 LaunchData 200자 안에 넣을 수 있습니다. (크기 M)
3. **무료 비공개 서버를 켜 두세요.** 공식으로 가능하고, 친구끼리 협동 플레이에 맞습니다. 유료로 막지 않아야 pay-to-win을 피합니다. (크기 S)
4. **TeleportAsync는 SafeTeleport 패턴으로 쓰세요.** 5회 재시도와 TeleportInitFailed 처리가 필수입니다. (크기 S)
5. **친구 판별은 IsFriendsWithAsync로 하세요.** 로딩 때 한 번만 부르고 캐시하세요. 레이트 리밋은 확인 못 했습니다. (크기 S)

**추가로 확인할 것:** 예약 서버 수명, 서버 최대 인원, 친구 Join 동작은 Studio 실험이나 DevForum 공식 공지로 보완하세요.

## 출처
- https://create.roblox.com/docs/projects/teleport
- https://create.roblox.com/docs/reference/engine/classes/TeleportService
- https://create.roblox.com/docs/reference/engine/classes/TeleportOptions
- https://create.roblox.com/docs/production/monetization/private-servers
- https://create.roblox.com/docs/production/promotion/invite-prompts
- https://create.roblox.com/docs/reference/engine/classes/ExperienceInviteOptions
- https://create.roblox.com/docs/production/promotion/referral-system
- https://create.roblox.com/docs/reference/engine/classes/Player
- https://create.roblox.com/docs/reference/engine/classes/Players
- 비공식 참고: https://devforum.roblox.com/t/questions-about-reserved-servers/3641358

## 검색에서 본 자료 (자동 수집)
- [TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService#ReserveServer)
- ['Reserve' a Server - Scripting Support - Developer Forum](https://devforum.roblox.com/t/reserve-a-server/1125284)
- [How to use a reserved server with TeleportPartyAsync? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/how-to-use-a-reserved-server-with-teleportpartyasync/2159572)
- [How to use :ReserveServer() to make a lobby system? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/how-to-use-reserveserver-to-make-a-lobby-system/1637565)
- [TeleportService](https://robloxapi.github.io/ref/class/TeleportService.html)
- [How to use TeleportService with reserved settings to other Place - Scripting Support - Developer Forum](https://devforum.roblox.com/t/how-to-use-teleportservice-with-reserved-settings-to-other-place/2431776)
- [TeleportOptions](https://create.roblox.com/docs/reference/engine/classes/TeleportOptions#ShouldReserveServer)
- [:TeleportAsync() + ReservedServers are driving me nuts - Scripting Support - Developer Forum](https://devforum.roblox.com/t/teleportasync-reservedservers-are-driving-me-nuts/2830240)
- [How do I make it so that it creates a new server? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/how-do-i-make-it-so-that-it-creates-a-new-server/3844284)
- [--- title: "Teleport between places" url: /docs/en-us/projects/teleport](https://create.roblox.com/docs/projects/teleport.md)
- [TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService)
- [I still have a little doubt about TeleportOptions - Scripting Support - Developer Forum](https://devforum.roblox.com/t/i-still-have-a-little-doubt-about-teleportoptions/2031752)
- [Questions about Reserved servers - Scripting Support - Developer Forum](https://devforum.roblox.com/t/questions-about-reserved-servers/3641358)
- [How to reserve and teleport to private servers - Scripting Support - Developer Forum](https://devforum.roblox.com/t/how-to-reserve-and-teleport-to-private-servers/2037956)
- [title | description |](https://github.com/Roblox/creator-docs/blob/main/content/en-us/resources/modules/spawn-with-friends.md)
- [0% found this document useful (0 votes)](https://www.scribd.com/document/866715362/text-Copy-Copy)
- [Teleport between places](https://create.roblox.com/docs/projects/teleport)
- [Cannot teleport to reserved server - Scripting Support - Developer Forum](https://devforum.roblox.com/t/cannot-teleport-to-reserved-server/1371885)
- [TeleportInitFailed, Please help me with this - Scripting Support - Developer Forum](https://devforum.roblox.com/t/teleportinitfailed-please-help-me-with-this/2060557)
- [Error Code: 773 appears randomly when teleporting to a reserved server - Scripting Support - Developer Forum](https://devforum.roblox.com/t/error-code-773-appears-randomly-when-teleporting-to-a-reserved-server/3183319)
- [Simplified Teleport Error Handling - Announcements - Developer Forum](https://devforum.roblox.com/t/simplified-teleport-error-handling/1652500)
- [TeleportToPrivateServer unknown failure? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/teleporttoprivateserver-unknown-failure/1273596)
- [Teleport between places](https://create-roblox-com.translate.goog/docs/projects/teleport?_x_tr_sl=en&_x_tr_tl=pt&_x_tr_hl=pt&_x_tr_pto=wa)
- [Doors (game)](https://en.wikipedia.org/wiki/Doors_(game))
- [title | description |](https://github.com/Roblox/creator-docs/blob/main/content/en-us/resources/modules/friends-locator.md)
- [github.com](https://github.com/TheMeltz/PartyService)
- [New on Yahoo](https://tech.yahoo.com/gaming/articles/roblox-party-features-explained-120400847.html)
- [title | description | next | prev |](https://github.com/Roblox/creator-docs/blob/main/content/en-us/education/battle-royale-series/managing-players.md)
- [Private servers](https://create.roblox.com/docs/production/monetization/private-servers)
- [creator-docs/content/en-us/production/monetization/private-servers.md at main · Roblox/creator-docs · GitHub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/private-servers.md)
- [How to Join Private Servers in Roblox](https://gamedevourer.com/how-to-join-private-servers-in-roblox/)
- [Roblox Private Servers: Everything You Need to Know in 2026 - Tech2Geek](https://www.tech2geek.net/roblox-private-servers-everything-you-need-to-know-in-2026/)
- [How Roblox Creators Can Enable Private Servers](https://topofgames.org/news/how-roblox-creators-can-enable-private-servers)
- [How To Enable Private Servers on Your Own Roblox Game](https://www.techbloat.com/how-to-enable-private-servers-on-your-own-roblox-game.html)
- [Roblox Private Servers Explained: Cost, Setup & 2026 Changes](https://www.technerdiness.com/roblox/roblox-private-servers-explained/)
- [How to Set Up Private Servers in Roblox](https://craftane.com/rblxtutorials/how-to-set-up-private-servers-roblox)
- [How to Enable a Free Private Server Option in Your Roblox Experience - TOP OF GAMES](https://topofgames.info/guides/roblox-enable-private-servers-free-option)
- [--- title: "Private servers"](https://create.roblox.com/docs/en-us/production/monetization/private-servers.md)
- [Private server](https://roblox.fandom.com/wiki/Private_server)
- [Roblox: How to Create and Configure a Private Server](https://vandal.elespanol.com/en/roblox/roblox-how-to-create-and-configure-a-private-server.html)
- [Roblox Private Servers Guide: How to Create, Join & Use Them](https://racoon.gg/roblox/blog/roblox-private-servers)
- [SocialService](https://create.roblox.com/docs/reference/engine/classes/SocialService)
- [SocialService](https://robloxapi.github.io/ref/class/SocialService.html)
- [SocialService](https://roblox.fandom.com/wiki/Class:SocialService)
- [PromptGameInvite](https://roblox.fandom.com/wiki/Class:SocialService/PromptGameInvite)
- [SocialService:PromptGameInvite does not use the correct Modal in Roblox Studio - Engine Bugs - Developer Forum](https://devforum.roblox.com/t/socialservicepromptgameinvite-does-not-use-the-correct-modal-in-roblox-studio/4566400)
- [PromptGameInvite UI for specific friends is broken - Engine Bugs - Developer Forum](https://devforum.roblox.com/t/promptgameinvite-ui-for-specific-friends-is-broken/4571026)
- [creator-docs/content/en-us/production/promotion/invite-prompts.md at main · Roblox/creator-docs · GitHub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/promotion/invite-prompts.md)
- [Player invite prompts](https://create.roblox.com/docs/production/promotion/invite-prompts)
- [Social Service Prompt Invite is sometimes slow or just won't open - Engine Bugs - Developer Forum](https://devforum.roblox.com/t/social-service-prompt-invite-is-sometimes-slow-or-just-wont-open/3824242)
- [Make your games more unique - Invite Friends - Bulletin Board - Developer Forum](https://devforum.roblox.com/t/make-your-games-more-unique-invite-friends/1214272)
- [ExperienceInviteOptions](https://create.roblox.com/docs/reference/engine/classes/ExperienceInviteOptions#InviteUser)
- [Friend referral system](https://create.roblox.com/docs/production/promotion/referral-system)
- [[P1] Referral invites: invite friends, fall together, both earn an invite-only cosmetic · Issue #97 · besessener/TowerOfBlox · GitHub](https://github.com/besessener/TowerOfBlox/issues/97)
- [Player Prompt Invite not receiving Launch/Join Data - Scripting Support - Developer Forum](https://devforum.roblox.com/t/player-prompt-invite-not-receiving-launchjoin-data/2231733)
- [Announcing the new Friend Referral System for your Experiences - Announcements - Developer Forum](https://devforum.roblox.com/t/announcing-the-new-friend-referral-system-for-your-experiences/3623795)
- [Detecting if player joined through an invite - Scripting Support - Developer Forum](https://devforum.roblox.com/t/detecting-if-player-joined-through-an-invite/2337270)
- [creator-docs/content/en-us/production/promotion/referral-system.md at main · Roblox/creator-docs · GitHub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/promotion/referral-system.md)
- [Players](https://create.roblox.com/docs/reference/engine/classes/Players)
- [Player](https://roblox.fandom.com/wiki/Class:Player)
