# API 리서치: roblox_retention_rules (2026-10-21)

- 모델 claude-sonnet-5-5 · effort medium · 비용 약 $0.416 · 검색 14회 · 턴 1 · 끝 end_turn
- 메인 세션 검수 전 자료예요. 숫자는 출처를 보고 다시 확인해요.

Let me read a few key pages for details.
# Roblox 공식 규칙: 리텐션·소셜 시스템 (2025–2026)

**한 줄 요약:** 알림, 초대(친구 추천), 뱃지, 유료 랜덤 아이템은 공식 문서가 있어서 그대로 쓰면 됩니다. 좋아요·즐겨찾기·팔로우·그룹 가입에 보상을 주는 것은 현재 공식 페이지로 확인하지 못했습니다. 아래 근거는 개발자 포럼 글(커뮤니티 글)입니다.

검색 도구 사용 한도가 중간에 끝나서 몇 곳은 원문을 끝까지 읽지 못했습니다. 그 항목에는 "(확인 못 함)"을 적었습니다.

| 항목 | 공식 규칙(짧게 인용) | 우리 게임에 쓰는 법 | 링크 |
|---|---|---|---|
| 1. 좋아요·즐겨찾기·팔로우·그룹 가입 보상 | **공식 페이지에서 직접 확인 못 함.** Community Standards 본문에서 해당 문구를 찾지 못했습니다. 포럼 글은 2018년 규칙을 인용합니다: "Do not create promotions offering prizes of any sort". 다른 포럼 글(2025-09)은 팔로우 보상이 "not allowed"라고 하지만 개발자 개인 의견입니다. 현실에서는 많은 게임이 "좋아요+그룹 가입 보상"을 쓰지만, 정책 위반 위험이 있습니다. | 보상 없이 부탁만 합니다. 예: 정비 완료 화면에 "재미있었다면 좋아요 부탁!" 문구를 넣습니다. 보상은 **친구 초대**나 **이벤트 알림 신청**에 연결합니다. 좋아요·즐겨찾기·팔로우·그룹 가입에는 아무 보상도 걸지 않습니다. | [포럼: 팔로우 보상](https://devforum.roblox.com/t/is-follow-reward-allowed-on-roblox/3947013), [포럼: 좋아요 보상](https://devforum.roblox.com/t/rewards-through-likingfavoritinginvites/233704), [Community Standards](https://about.roblox.com/community-standards) |
| 2. 친구 초대·추천 | 공식 "Friend referral system" 문서가 있습니다. 문서에 따르면 `ReferredByPlayerId`는 모든 초대 유형에서 자동으로 채워집니다. 초대 옵션의 launch data는 최대 200자이고, 초대받은 친구가 들어오면 `Player:GetJoinData()`로 읽습니다. 추천 이벤트와 추천 보상은 Studio에서 설정합니다. 초대 대상은 Roblox 친구가 아니어도 됩니다. | 초대자와 초대받은 사람 모두에게 **편의·외형 보상**을 줍니다(돈 되는 성능 보상은 제외). 서버에서 `PlayerAdded` 때 `ReferredByPlayerId`를 확인합니다. 같은 사람이 반복해서 보상받는 어뷰징은 DataStore로 막습니다. 초대 직후 협동 정비 시작 지점으로 보내는 launch data도 좋습니다. 단, 이 문서의 보상 규칙 세부 문구는 끝까지 읽지 못했습니다(확인 못 함). | [공식: 친구 추천 시스템](https://create.roblox.com/docs/production/promotion/referral-system), [공식: 초대 프롬프트](https://create.roblox.com/docs/production/promotion/invite-prompts), [DevForum 발표](https://devforum.roblox.com/t/announcing-the-new-friend-referral-system-for-your-experiences/3623795) |
| 3a. 이벤트 RSVP | 이벤트 시스템으로 시간 기반 이벤트를 만듭니다. 플레이어는 게임 상세 페이지에서 이벤트를 보고, 시작될 때 받을 알림을 신청할 수 있습니다. 업데이트 공지도 알림으로 보낼 수 있습니다. | 시즌 이벤트(예: 클래식카 주간, 폐차장 경매일)를 이벤트로 등록합니다. 게임 안에는 "알림 신청" 안내를 둡니다. | [공식: 이벤트와 업데이트](https://create.roblox.com/docs/production/promotion/experience-events) |
| 3b. 경험 알림 API | 자격은 최소 방문 100회, 모더레이션 중이 아닐 것, 관리 권한이 있을 것입니다. 만 13세 이상 신청자에게만 전달됩니다. 알림 문구는 99자 이하입니다. 사용자 1명당 한 게임에서 하루 1회까지입니다(Open Cloud 문서). 출시 때는 3일 1회였고 이후 하루 1회로 완화됐습니다. 신청 창은 `PromptOptIn()`으로 띄우며 문구는 고정입니다. 사용자 반응이 좋을수록 도달 범위가 늘어납니다. | 좋은 타이밍은 첫 수리 성공 직후나 희귀차 입고 직후입니다. 이때 `CanPromptOptInAsync()`를 확인하고 `PromptOptIn()`을 호출합니다. 알림 내용은 "희귀 차가 도착했어요", "이벤트 시작" 같은 진짜 소식만 담습니다. 하루 1회 한도 때문에 한 주 일정을 미리 짜 둡니다. | [공식: 경험 알림](https://create.roblox.com/docs/production/promotion/experience-notifications), [공식: Open Cloud](https://create.roblox.com/docs/cloud/guides/experience-notifications), [DevForum: 한도 완화](https://devforum.roblox.com/t/updates-to-notification-rate-limits/3007106) |
| 4. 뱃지 | "up to 5 badges for free in a 24-hour period (GMT)" (게임당). 초과분은 개당 100 Robux입니다. | 매일 5개까지 무료이니 하루에 몰아 만들지 말고 나눠서 만듭니다. 서버에서 `UserHasBadge`로 확인한 뒤 `AwardBadge`를 호출합니다. 숨은 업적 모범 사례 문서는 못 찾았습니다(확인 못 함). 제안: 숨은 뱃지는 설명을 "???"로 하고 희귀차 복원·첫 100% 진단 같은 이야기 있는 순간에 줍니다. | [공식: 뱃지](https://create.roblox.com/docs/production/publishing/badges), [DevForum: 무료 뱃지 발표](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515) |
| 5. 일일 보상·로그인 연속 | 일일 보상 자체의 제한 문구는 못 찾았습니다(확인 못 함). 다만 Robux 또는 Robux로 산 게임 재화로 결과가 랜덤인 아이템에는 확률 공개 의무가 있습니다. | **무료** 일일 상자는 정책 영향이 작습니다. 그래도 보상표를 보여 주는 편이 안전합니다. **유료** 랜덤 상자(Robux 구매 포함)는 만들지 않는 것이 하우스 룰과도 맞습니다. 폐차장 경매는 결과가 랜덤이면 "유료 랜덤"에 해당할 수 있으니 주의합니다. 만들 경우 모든 결과와 실제 숫자 확률을 구매 전에 보여 줘야 합니다. | [공식: 유료 랜덤 아이템](https://create.roblox.com/docs/production/monetization/paid-random-items), [DevForum: 요건 명확화](https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622) |
| 5b. 유료 랜덤 아이템 정책 | 유료 랜덤 아이템 정책이 확대됐습니다. 알, 상자, 스핀, 천장(pity) 시스템, 행운 부스트까지 포함되고 PolicyService 사용 요건이 있습니다(트위터 요약, 날짜 불명확). 일부 이용자는 구매할 수 없으므로 `PolicyService`의 `ArePaidRandomItemsRestricted`를 써야 합니다. | 이 게임은 유료 랜덤을 아예 넣지 않는 것을 권장합니다. 대신 Robux로는 편의·외형을 **확정된 내용**으로만 팝니다. | [Community Standards](https://about.roblox.com/community-standards), [X 요약(2차 출처)](https://x.com/RoUtilityNews/status/2059344970994053348) |
| 6. 시즌 이벤트·한정 아이템(FOMO) | 한정 판매나 FOMO를 직접 다루는 공식 정책은 못 찾았습니다(확인 못 함). | 한정 아이템은 **외형 전용**으로 하고 다음 시즌에 되돌아오게 합니다. 성능이나 돈 버는 능력은 한정으로 팔지 않습니다. 카운트다운으로 압박하는 표현은 피합니다. | (공식 근거 없음) |
| 7a. 서버 공지(채팅) | `TextChatService`의 `TextChannel:DisplaySystemMessage()`로 시스템 메시지를 보여 줍니다. 학습 예제에서 클라이언트가 채팅 로딩 전에 호출하면 실패해서 잠깐 기다리라는 사례가 있습니다. | 서버가 RemoteEvent로 보내고 클라이언트가 `RBXGeneral`/`RBXSystem` 채널에 표시합니다. 호출 전에 채팅 로드를 기다립니다. 공식 문서 원문은 이번에 직접 열지 못했습니다(확인 못 함). | [포럼: 시스템 메시지](https://devforum.roblox.com/t/system-messages-not-working/3772387) |
| 7b. 서버 간 공지 | 2024-02에 한도가 크게 올랐습니다. 메시지 크기는 1KB입니다. 포럼 인용으로는 "240 requests per minute"가 새 한도 중 하나인데, 어느 항목의 값인지 불명확합니다. 옛 문서 공식은 서버당 분당 "150 + 60 × 플레이어 수"였습니다. Open Cloud와 엔진 API는 한도를 공유합니다. | 전 서버 공지는 희귀차 입고처럼 드문 일만 보냅니다. 메시지는 1KB 이하로 짧게 하고, 보내기 전에 최신 한도 표를 공식 문서에서 다시 확인합니다. | [DevForum: 한도 상향](https://devforum.roblox.com/t/enhanced-messagingservice-limits/2835576), [공식: Messaging 가이드](https://create.roblox.com/docs/cloud/guides/usage-messaging) |

## 우리 게임에 가져올 것·피할 것

1. **좋아요·즐겨찾기·팔로우·그룹 보상은 하지 않습니다.** (S)
   - 이유: 공식 확인이 안 되고 정책 위반 위험이 있습니다. 신고나 제재가 나오면 손해가 큽니다.
2. **친구 추천 시스템을 쓰고 보상은 외형이나 편의로 합니다.** (M)
   - 이유: 공식 기능이라 안전하고, 1~4명 협동이라는 게임 방향과 맞습니다.
3. **알림 신청 창은 첫 성공 순간에 띄웁니다.** (S)
   - 이유: 알림은 하루 1회가 한도라서, 신청자를 일찍 모으는 것이 중요합니다.
4. **유료 랜덤은 만들지 않습니다.** (S)
   - 이유: 확률 공개와 지역 제한 요건이 있고, "돈 쓰면 이긴다"는 인상도 줍니다.
5. **뱃지는 하루 5개 무료 한도에 맞춰 나눠 만듭니다.** (S)
6. **서버 간 공지는 드문 일에만 씁니다.** (S)
   - 이유: 한도 수치가 불확실하므로 보수적으로 씁니다.

## 출처

- https://create.roblox.com/docs/production/promotion/referral-system
- https://create.roblox.com/docs/production/promotion/invite-prompts
- https://create.roblox.com/docs/production/promotion/experience-events
- https://create.roblox.com/docs/production/promotion/experience-notifications
- https://create.roblox.com/docs/cloud/guides/experience-notifications
- https://create.roblox.com/docs/production/publishing/badges
- https://create.roblox.com/docs/production/monetization/paid-random-items
- https://create.roblox.com/docs/cloud/guides/usage-messaging
- https://about.roblox.com/community-standards
- https://devforum.roblox.com/t/announcing-the-new-friend-referral-system-for-your-experiences/3623795
- https://devforum.roblox.com/t/updates-to-notification-rate-limits/3007106
- https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622
- https://devforum.roblox.com/t/enhanced-messagingservice-limits/2835576
- https://devforum.roblox.com/t/announcing-free-badge-creations/1680515
- https://devforum.roblox.com/t/is-follow-reward-allowed-on-roblox/3947013
- https://devforum.roblox.com/t/rewards-through-likingfavoritinginvites/233704
- https://devforum.roblox.com/t/system-messages-not-working/3772387

## 검색에서 본 자료 (자동 수집)
- [Experience notifications](https://create.roblox.com/docs/production/promotion/experience-notifications)
- [creator-docs/content/en-us/production/promotion/experience-notifications.md at main · Roblox/creator-docs · GitHub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/promotion/experience-notifications.md)
- [User notifications](https://create.roblox.com/docs/cloud/guides/experience-notifications)
- [Introducing Experience Notifications - Announcements - Developer Forum](https://devforum.roblox.com/t/introducing-experience-notifications/2826474)
- [Introducing In-Experience Notification Permission Prompts - Announcements - Developer Forum](https://devforum.roblox.com/t/introducing-in-experience-notification-permission-prompts/2909125)
- [Introducing Experience Notifications - Page 6 - Announcements - Developer Forum](https://devforum.roblox.com/t/introducing-experience-notifications/2826474?page=6)
- [Updates to Notification Rate Limits - Announcements - Developer Forum](https://devforum.roblox.com/t/updates-to-notification-rate-limits/3007106)
- [Introducing Experience Notifications - Page 7 - Announcements - Developer Forum](https://devforum.roblox.com/t/introducing-experience-notifications/2826474?page=7)
- [Notifications](https://create.roblox.com/docs/cloud/reference/features/notifications)
- [Is Follow Reward Allowed on roblox? - Platform Usage Support - Developer Forum](https://devforum.roblox.com/t/is-follow-reward-allowed-on-roblox/3947013)
- [Rewards through Liking/Favoriting/Invites - Scripting Support - Developer Forum](https://devforum.roblox.com/t/rewards-through-likingfavoritinginvites/233704)
- [The issue of bribing players for likes - Website Features - Developer Forum](https://devforum.roblox.com/t/the-issue-of-bribing-players-for-likes/4495969)
- [Rewarding Players for Liking the Game - Scripting Support - Developer Forum](https://devforum.roblox.com/t/rewarding-players-for-liking-the-game/2920714)
- [Do ToS allow "X Likes for next reward"? - Game Design Support - Developer Forum](https://devforum.roblox.com/t/do-tos-allow-x-likes-for-next-reward/1029127)
- [Boundaries of in-game rewards - Game Design Support - Developer Forum](https://devforum.roblox.com/t/boundaries-of-in-game-rewards/3051700)
- [Is rewarding players for liking, favoriting a game allowed? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/is-rewarding-players-for-liking-favoriting-a-game-allowed/2926286)
- [Is giving rewards from favoriting the game allowed? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/is-giving-rewards-from-favoriting-the-game-allowed/2815306)
- [Giving In-Game Awards For Following Users: Is It Allowed? - Platform Usage Support - Developer Forum](https://devforum.roblox.com/t/giving-in-game-awards-for-following-users-is-it-allowed/2866211)
- [robux subscription](https://asset-sherlockbot.adobe.com/robux-subscription)
- [Paid random items policy guidelines](https://create.roblox.com/docs/production/monetization/paid-random-items)
- [RoUtility on X: "Roblox has expanded its Paid Random Items policy Games using paid eggs, crates, spins, pity systems, luck boosts, etc now face stricter odds disclosure and regional compliance requirements through PolicyService. Read more: https://t.co/WNtsV9weDe https://t.co/V1up8Lzgfb" / X](https://x.com/RoUtilityNews/status/2059344970994053348?lang=en)
- [Roblox Community Standards](https://about.roblox.com/community-standards)
- [Clarifying Requirements for Paid Random Items - Announcements - Developer Forum](https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622)
- [Guidelines around users paying for random virtual items - Announcements - Developer Forum](https://devforum.roblox.com/t/guidelines-around-users-paying-for-random-virtual-items/307189)
- [Clarifying Requirements for Paid Random Items - Page 4 - Announcements - Developer Forum](https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622?page=4)
- [Clarifying Requirements for Paid Random Items - Page 2 - Announcements - Developer Forum](https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622?page=2)
- [Loot boxes get stricter — Roblox clarifies odds disclosure and region-gating for Paid Random Items — The ZehnStudio99](https://zehn-studio26.com/news/paid-random-items-odds-disclosure/)
- [Korea’s Loot-Box Rules Push Roblox to Disclose Item Odds Worldwide](https://www.techtimes.com/articles/319148/20260626/koreas-loot-box-rules-push-roblox-disclose-item-odds-worldwide.htm)
- [Announcing Free Badge Creations! - Announcements - Developer Forum](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515)
- [Badges](https://roblox.fandom.com/wiki/User_badge)
- [Badges](https://create.roblox.com/docs/production/publishing/badges)
- [Announcing Free Badge Creations! - Page 13 - Announcements - Developer Forum](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515?page=13)
- [Announcing Free Badge Creations! - Page 2 - Announcements - Developer Forum](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515?page=2)
- [Announcing Free Badge Creations! - Page 8 - Announcements - Developer Forum](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515?page=8)
- [Announcing Free Badge Creations! - Page 14 - Announcements - Developer Forum](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515?page=14)
- [Announcing Free Badge Creations! - Page 15 - Announcements - Developer Forum](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515?page=15)
- [Announcing Free Badge Creations! - Page 12 - Announcements - Developer Forum](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515?page=12)
- [How many Robux can you get for $100 in Roblox?](https://sportskeeda.com/roblox-news/how-many-robux-can-get-100-roblox)
- [SocialService.GameInvitePromptClosed to return Enum if a Player was invited - Engine Features - Developer Forum](https://devforum.roblox.com/t/socialservicegameinvitepromptclosed-to-return-enum-if-a-player-was-invited/4102768)
- [Player invite prompts](https://create.roblox.com/docs/production/promotion/invite-prompts)
- [[P1] Referral invites: invite friends, fall together, both earn an invite-only cosmetic · Issue #97 · besessener/TowerOfBlox · GitHub](https://github.com/besessener/TowerOfBlox/issues/97)
- [creator-docs/content/en-us/production/promotion/invite-prompts.md at main · Roblox/creator-docs · GitHub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/promotion/invite-prompts.md)
- [Friend referral system](https://create.roblox.com/docs/production/promotion/referral-system)
- [Player Prompt Invite not receiving Launch/Join Data - Scripting Support - Developer Forum](https://devforum.roblox.com/t/player-prompt-invite-not-receiving-launchjoin-data/2231733)
- [creator-docs/content/en-us/production/promotion/referral-system.md at main · Roblox/creator-docs · GitHub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/promotion/referral-system.md)
- [Is it possible to detect when player invites someone else - Scripting Support - Developer Forum](https://devforum.roblox.com/t/is-it-possible-to-detect-when-player-invites-someone-else/2171053)
- [SocialService](https://create-roblox-com.translate.goog/docs/reference/engine/classes/SocialService?_x_tr_sl=en&_x_tr_tl=es&_x_tr_hl=es&_x_tr_pto=tc#PromptGameInvite)
- [Experience events and updates](https://create.roblox.com/docs/production/promotion/experience-events)
- [--- title: "Experience events and updates"](https://create.roblox.com/docs/production/promotion/experience-events.md)
- [Roblox Creator Events](https://events.roblox.com/)
- [ExperienceNotificationService](https://create.roblox.com/docs/reference/engine/classes/ExperienceNotificationService)
- [A lot of questions regarding Roblox Events - Platform Usage Support - Developer Forum](https://devforum.roblox.com/t/a-lot-of-questions-regarding-roblox-events/2872611)
- [Messaging usage guide](https://create.roblox.com/docs/cloud/guides/usage-messaging)
- [Enhanced MessagingService Limits - Announcements - Developer Forum](https://devforum.roblox.com/t/enhanced-messagingservice-limits/2835576)
- [MessagingService Subscription Limit - Scripting Support - Developer Forum](https://devforum.roblox.com/t/messagingservice-subscription-limit/812295)
- [Enhanced MessagingService Limits - Page 3 - Announcements - Developer Forum](https://devforum.roblox.com/t/enhanced-messagingservice-limits/2835576?page=3)
- [MessagingService Limit - Scripting Support - Developer Forum](https://devforum.roblox.com/t/messagingservice-limit/2879156)
- [MessagingService](https://roblox.fandom.com/wiki/Class:MessagingService)
- [Unifying MessagingService OpenCloud API and Engine API rate limits - Announcements - Developer Forum](https://devforum.roblox.com/t/unifying-messagingservice-opencloud-api-and-engine-api-rate-limits/4600993)
- [Can someone explain - Scripting Support - Developer Forum](https://devforum.roblox.com/t/can-someone-explain/3092795)
