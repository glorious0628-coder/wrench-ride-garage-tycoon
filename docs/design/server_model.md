# 서버 구조 (server_model) — v0.4: **C 섞기** — "정비소 1개 = 주인 1명 + 아는 사람만" (wr-design, 2026-10-21)

> **사용자 결정(10-21)**: "나는 그냥 1인 아니면 1인과 아는 사람들끼리 하는 거면 좋을 것 같애성ㅋㅋ" → **정비소 1개 = 주인 1명 + 친구만. 모르는 사람과는 안 섞임.**
> **사용자 최종 선택(10-21) = C 섞기**: "공개 서버에서 처음 온 사람이나 친구 아닌 사람은 자기 정비소로 이동, 친구는 같은 정비소로 … 이거 ㅈ좋은데". → **주인은 공개 서버**(친구 목록 Join으로 따라올 수 있게 — 가장 중요), 친구가 아닌 사람·처음 온 사람이 남의 서버에 떨어지면 → 자기 정비소로 이동.
> 근거: GPT 2라운드 `notes/gpt/wr-design/server_r1_*`·`server_r2_*`, Roblox 공식 문서 원문(create.roblox.com .md)을 직접 읽은 것만(§1). v0.1의 A·C·D 비교는 결정으로 빠짐.

## 1. 공식 문서로 확인한 사실 (이 설계의 바닥)
| 사실 | 원문 (짧게) | 문서 |
|---|---|---|
| **예약 서버 안의 사람은 Join(따라가기)으로 못 따라감** | "Note that this will not work if the player being followed is in a reserved server." | [TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService) |
| 매치메이킹은 예약·비공개 서버를 안 봄 | "filtering out servers that are full, private, reserved, or about to be shut down" | [Matchmaking](https://create.roblox.com/docs/matchmaking) |
| 기본 매치메이킹 = 친구 있는 서버 최우선, 그다음 **사람이 더 찬 서버**(빈 서버 선호 설정은 문서에 없음) | Friends 15 · … · Occupancy 2 | [Server scoring](https://create.roblox.com/docs/matchmaking/scoring) |
| 예약 서버 = `TeleportAsync` + `ReservedServerAccessCode`/`ShouldReserveServer`, 실패는 pcall + 재시도(예제 5회·1초) + `TeleportInitFailed`, **Studio 플레이 테스트에선 텔레포트 검증 불가** | | [Teleport](https://create.roblox.com/docs/projects/teleport) |
| 초대받은 친구가 같은 서버로 간다는 보장 X → `LaunchData`(200자) + `GetJoinData()`로 서버가 직접 보냄, `CanSendGameInviteAsync`로 먼저 확인 | | [Invite prompts](https://create.roblox.com/docs/production/promotion/invite-prompts), [SocialService](https://create.roblox.com/docs/reference/engine/classes/SocialService) |
| 친구 확인 = `IsFriendsWithAsync`(Yields, 캐시) | | [Player](https://create.roblox.com/docs/reference/engine/classes/Player) |

## 2. 정비소 서버 두 종류
| | **공개 정비소** (보통) | **내 예약 정비소** (낯선 서버에 떨어졌을 때만) |
|---|---|---|
| 어떻게 생기나 | 게임을 켜면 Roblox가 공개 서버에 넣음. **비어 있던 서버면 그 사람이 주인** | 낯선 사람 서버에 떨어지면 서버가 `TeleportAsync`(`ShouldReserveServer`)로 만들어 보냄 — 코드는 그 사람 저장에 기억해 다시 씀 |
| 친구 Join 버튼 | **됨** | **안 됨**(공식) → 게임 안 초대·친구 찾기로 |
| 주인 | 처음 정한 사람 UserId로 **고정**(입장 순서와 분리) | 그 사람 |
| 정원 | MaxPlayers **4**(대시보드) | 4 |
- **이동할 곳 = 새 공개 서버? 예약 서버?** (C의 핵심 질문)
  - **새 공개 서버로는 못 보냄**: 공식 API에 '빈 공개 서버를 새로 만들어 보내기'가 없고, 장소 ID만으로 텔레포트하면 **매치메이킹을 다시 타서** 또 사람이 있는 서버에 떨어질 수 있음(기본 = Friends 다음 **Occupancy — 더 찬 서버 선호**, '빈 서버 선호' 설정은 문서에 없음 — §1). 그러면 튕김이 반복될 위험.
  - 그래서 **예약 서버(내 정비소)**로 보냄 — 확실히 나 혼자 주인. 단점: 그 안에선 **친구가 Join 버튼으로 못 따라옴**(공식) → §4의 초대·친구 찾기로 보완 + 예약 정비소 화면에 작은 안내 **"Friends can't use Join here — send them an invite!"** / "여기선 친구가 Join으로 못 와요 — 초대를 보내 주세요!" + Invite 버튼.
  - 낯선 서버에 떨어지는 비율을 줄이는 시도(실험): 매치메이킹 Occupancy 가중치 낮추기 — **빈 서버 선호를 만들지는 못함**(GPT·문서), 효과는 실측.
  - (나중 실험) 예약 정비소 주인이 친구를 기다릴 때 **"Open my garage to friends"** 버튼 → 주인+같이 있는 친구를 공개 장소로 다시 보내 Join이 되게 — 매치메이킹이 또 낯선 서버로 보낼 수 있어 보장 X, 게시 버전에서 시험.

## 3. 들어오는 길
| 누가 | 어디에 떨어짐 | 처리 |
|---|---|---|
| **처음 온 사람(첫 접속)** | 빈 공개 서버 | 그대로 주인 → 튜토리얼(로딩 1번) |
| | 낯선 주인 서버 | 짧은 대기 화면 → **바로 자기 예약 정비소로**(로딩 2번) → 거기서 튜토리얼. 남의 정비소에서 튜토리얼 시작 X |
| 돌아온 사람 | 빈 공개 서버 | 주인(로딩 1번) |
| | 낯선 주인 서버 | 자기 예약 정비소로 |
| **서버 안 누군가의 친구** (사용자 결정 10-21: "친구의 친구도 OK") | Join 버튼·매치메이킹(Friends 신호)으로 그 서버 | 서버가 지금 서버에 있는 사람들과 `IsFriendsWithAsync`(최대 3번) — **한 명이라도 친구면** 그대로 도우미(주인과 직접 친구 아니어도 OK) |
| 서버 안 **아무와도 친구가 아님** | 그 서버 | 모르는 사람 → **자기 정비소(예약)로** |
| 주인이 나간 뒤 | | 그 방은 **새 손님 차·새 사람을 안 받음**(새로 온 사람 = 자기 정비소로), 남은 친구는 하던 차를 끝내고 'Back to my garage' 버튼 |
- 대기 화면(입장 판정) 동안은 작업 X — 판정은 보통 1초 안.
- 지금 코드 `PlayerData.owner()`(남은 첫 사람으로 바뀜) → **주인 UserId 고정**으로 바꿔야 함.

## 4. 친구가 오는 길 (3개 — 하나가 안 돼도 다른 길)
1. **Roblox Join 버튼**: 주인이 공개 정비소에 있으면 됨.
2. **게임 안 Invite 버튼**: `CanSendGameInviteAsync` → `PromptGameInvite`(`LaunchData` = 주인 UserId) → 친구가 들어오면 서버가 `GetJoinData()`로 주인 정비소를 찾아(공개면 그 서버, 예약이면 코드로) **보냄**. 초대 불가 기기면 버튼 숨김.
3. **"Find a friend's garage" 메뉴**: 지금 게임에 있는 친구 목록 → 누르면 그 친구 정비소로(공개·예약 모두). 서버가 MemoryStore에 'UserId → 지금 정비소(공개 JobId 또는 예약 코드)'를 짧게 기록. 어린 계정·초대 불가 기기 대비.
- 파티(`GetPartyAsync`)로 온 친구들은 파티째 같은 정비소로.

## 5. 텔레포트 실패·기다림 (아이가 '튕겼다'고 느끼지 않게)
| 때 | 화면 (영어 원문 / 한국어) | 처리 |
|---|---|---|
| 입장 판정 | **"Checking in at the garage…"** / 정비소에 들어가는 중… | 1초 안 |
| 자기 정비소로 이동 | **"This garage belongs to someone else. Taking you to your own garage!"** / 여긴 다른 사람 정비소예요. 내 정비소로 데려다줄게요! + 렉카가 차를 끌고 가는 짧은 그림 | `TeleportAsync` |
| 친구 정비소로 이동 | **"Heading to {name}'s garage…"** / {name}의 정비소로 가는 중… | |
| 재시도 중 | **"The road's a bit busy — trying again…"** / 길이 좀 막혀요 — 다시 해 볼게요… | 5회·1초 간격(공식 예제) |
| 끝내 실패 | **"Couldn't get there. You can look around here, or try again."** / 못 갔어요. 여기서 구경하거나 다시 해 봐요. + 버튼 **"Try again"**(다시 하기) | 이 서버에서 '구경 모드'(작업 X, 꾸밈 보기), 다시 하기 |
| 친구가 꽉 참(4명) | **"{name}'s garage is full right now."** / {name}의 정비소가 지금 꽉 찼어요. | 내 정비소로 |
- 모든 이동 문구는 '왜'를 한 줄로 — 이유 모르고 튕기는 느낌 X(교과서 1·3).

## 6. 다른 설계와 맞는지
- **economy §3 협동 보상**: 그대로 맞음 — 도우미가 이제 **늘 친구**. 도우미 평판 50%는 자기 정비소에.
- **retention_social 친구 추천**(`ReferredByPlayerId`, 양쪽 보상): 그대로 — 추천으로 온 친구는 §4-2처럼 초대한 사람 정비소로 보냄.
- **tutorial_script §6(2인 규칙)**: 그대로 — 친구가 첫 일이면 그 사람 화면에 안내.
- **daily_receipt Crew 줄**: 그대로(친구 이름).
- **사람 시험(1인)**: **지금 구조로 그대로 해도 돼요** — 1인은 혼자 서버 = 주인. 친구 2인 시험도 지금 공개 서버 Join으로 됨. 시험 땐 모르는 사람이 못 들어오게 게시 설정(메인·사용자). 결과(정비 재미·튜토리얼·협동 보상)는 이 구조에서도 그대로 씀. 입장·텔레포트는 **게시 버전에서 따로 시험**.

## 7. 사용자에게 물을 질문 (쉬운 말)
1. ~~친구의 친구~~ → **결정(10-21): "친구의 친구도 OK"** — 서버 안 누구와든 친구면 같이 놀기, 모르는 사람만 자기 정비소로.
2. **"혼자 시작할 때 가끔 로딩 화면을 한 번 더 보는 건 괜찮아?"**(낯선 서버에 떨어졌을 때)

## 8. 출시 전 실험 (게시 버전 — Studio로는 텔레포트 검증 불가)
1. 혼자 접속: 로딩 1번·2번 비율, 첫 차 전 이탈.
2. 친구 합류 3길: Join(공개)·초대·친구 찾기, 어린 계정·초대 불가 기기, 예약 정비소에 있을 때.
3. 주인 퇴장·이동 실패: 남은 친구의 작업, 늦게 온 사람, 재시도·구경 모드.

## 9. 코드 크기 (wr-dev) — 합계 **M**
| 조각 | 크기 |
|---|---|
| 주인 UserId 고정 + 주인 나간 방 닫기 | S |
| 입장 판정(지금 있는 사람 각각과 `IsFriendsWithAsync`, 한 명이라도 친구면 OK) + 대기 화면 | S |
| 예약 정비소 만들기·코드 저장·`TeleportAsync` 재시도·실패 화면 | S~M |
| 게임 안 Invite(`LaunchData`) + 도착 처리 | S |
| "Find a friend's garage"(MemoryStore 위치 기록 + 친구 목록 UI) | M |
| 파티째 보내기 | S |

## 10. 게임 교과서 검사 질문 5개
1. 기대: 켜면 곧 **내** 정비소·내 첫 손님 — 남의 정비소에서 튜토리얼 X ✓
2. 따뜻함: 아는 사람끼리만, 모르는 사람이 강제로 도우미 X ✓
3. 보정: Join이 안 되는 곳엔 초대·친구 찾기·다시 하기 ✓ (출시 전 통과 조건)
4. 눈에 보이는 반응: 이동마다 이유 한 줄 + 렉카 그림, 도착하면 바로 차가 들어옴 ✓
5. 정비소가 자란다: 각자 자기 정비소가 자람 ✓

- 변경 기록: v0.3 (10-21) 사용자 최종 선택 **C 섞기** 반영 — 주인은 공개 서버(Join 됨), 낯선/처음 온 사람의 이동처 = 예약 정비소(새 공개 서버로 보내는 API 없음 + 매치메이킹 재진입 위험), 예약 정비소 안내 문구·Invite 버튼, 'Open my garage to friends' 나중 실험. v0.2 B(주인 + 친구만) 만드는 법.
- 변경 기록: v0.4 (10-21) 사용자 결정 "친구의 친구도 OK" — 입장 판정 = 서버 안 **누구와든** 친구면 OK(주인과 직접 친구 아니어도), 모르는 사람만 자기 정비소로.
