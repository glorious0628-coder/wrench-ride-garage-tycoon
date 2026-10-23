# 로블록스 저장소 397개 선별 결과 (2026-10-22 표 기준)

**기준**
- 별, 라이선스, 마지막 push, archived 값은 첨부 1에 적힌 그대로 옮겼습니다.
- "용도"와 "분류"는 저장소 설명 한 줄만 보고 판단했습니다. 저장소를 열어 코드를 확인하지는 않았습니다.
- "(추측)"이라고 적은 부분은 확인하지 않은 내 판단입니다.

---

## 1. 고르기: 뺀 것

### 1-a. 분야가 안 맞아서 뺀 것 (목록 대상 아님)

| 뺀 이유 | 해당 저장소 (예시 전부) |
|---|---|
| 치트·익스플로잇·실행기 | xeno-executor, Exunys/Aimbot-V2·V3·Aimbot-Script·AirHub·AirHub-V2, Averiias/Universal-SilentAim, ttwizz/Open-Aimbot, ic3w0lf22/Unnamed-ESP, 7GrandDadPGN/VapeV4ForRoblox, AlexR32/Parvus, fatesc/fates-admin, Upbolt/Hydroxide, luau/UniversalSynSaveInstance, Awakenchan/GcViewerV3, Claude-Reverser/MCP-Sploit, Standard-2/Myriad, kuskebabi/Birdy(DEX 재현), atrexus/vulkan |
| 스크립트 허브용 UI | Footagesus/WindUI, GhostDuckyy/UI-Libraries |
| 디컴파일·난독화 | prometheus-lua/Prometheus, PY44N·birthdates/Lua-Obfuscator, caomod2077/Deobfuscator, atrexus/unluau, xgladius/luauDec, shrimp-nz/medal, metaworm/luac-parser-rs |
| 매크로 | NatroTeam/NatroMacro, rayo0312/Roblox-Assist-Suite |
| 계정·쿠키·스나이퍼 | Roblox-Account-Manager, occursive/roblox-account-generator, Aspectise/Roblox-Mass-Tools, efenatuyo/ugc-sniper, tcpcon/chrome-extension-logger-poc, scoobyluvs/Fake-img-logger, MoterHaker/bypass-captcha-examples |
| 런처·Studio/클라이언트 수정 | bloxstrap, AppleBlox, Chevstrap, Novetus, Lution-old, MaximumADHD/Roblox-Studio-Mod-Manager, revolutionxk/roblox-modloader, uwufuzzywiiiaisddd/Roblox-Studio-Patcher, Extravi/Bloxshade, FastFlag 관련 3개, "Mod Manager/Installer/Loader" 4개(NOASSERTION), befexx/Moon-Animator-2-Unlocked |
| 리눅스 실행기 | vinegar, cordial, mocktail, SuperPuiu/Pwootie |
| 다른 게임용 스크립트·게임 복사 | Stefanuk12/ROBLOX, retpirato/Roblox-Scripts, Script-Pastebin/Fruit-Blox, KH0DIN/Uncopylocked 모음, roblox-game-copier 2개 |
| 로블록스 게임 제작과 무관 | qsv, mlua, the-mirror, mudcrab, blip, zlua, Astra, NotBlox, vectarine, kaledis, GDLuau, Yelp/casper, Vitreus, noctalia 2개, dotfiles, discord-luau, 7deer_skills 등 |

### 1-b. archived=Y라서 뺀 것 (게임 제작용만)

| 저장소 | 별 · 라이선스 · push | 뺀 이유 | 대체 (첨부 1에 있는 것) |
|---|---|---|---|
| Sleitnick/Knit | 632 · MIT · 2024-07-31 | 보관됨. 프레임워크라 구조를 바꿔야 함 | 필요 없음 (지금 구조 유지) |
| Roblox/roact | 626 · Apache-2.0 · 2023-12-13 | 보관됨 | Roblox/react-luau (우리에겐 비추, 4절) |
| Roblox/testez | 210 · Apache-2.0 · 2024-03-05 | 보관됨 | Roblox/jest-roblox |
| evaera/matter | 142 · MIT · 2024-07-16 | 보관됨 | matter-ecs/matter (ECS 자체가 비추) |
| red-blox/Red | 56 · MIT · 2024-02-18 | 보관됨 | ffrostfall/ByteNet, 1Axen/blink |
| evaera/plasma | 43 · MIT · 2024-07-16 | 보관됨 | SirMallard/Iris |
| freddylist/llama | 52 · MIT · 2022-07-15 | 보관됨 | cxmeel/sift |
| lutest-dev/lutest | 8 · MIT · 2026-08-28 | 보관됨 | Roblox/jest-roblox |
| rojo-rbx/remodel | 176 · MIT · 2023-07-22 | 보관됨 | 비슷한 일: lune, rbxmk (후속작인지는 확인 필요) |
| Roblox/studio-rust-mcp-server, boshyxd/robloxstudio-mcp | 496 / 495 · MIT | 보관됨 | 이미 `tools/studio_mcp.py`가 있음 |
| tiffany352/Roblox-Tag-Editor | 63 · NOASSERTION · 2022-12-05 | 보관됨 | 첨부 1에 없음 (확인 필요) |
| 그 밖의 보관 저장소 | | 보관됨 + 필요 없음 | AeroGameFramework, Fabric, Rbx-Gui-Library, Rbx-Wallstick-Legacy, Shime, wax, gargantuan, luanoid, lemur, RbxRefresh, studio-bridge, DataStore3, CorePackages, Wasynth, noblox.js, RoVer, Core-Scripts, Infinity-AntiCheat, RbxFingerprint |

라이선스 때문에 뺀 것은 맨 아래 5절에 따로 모았습니다.

---

## 2. 분류별 상위 3 (별 순)

| 분류 | 1 | 2 | 3 |
|---|---|---|---|
| 데이터 저장 | MadStudioRoblox/ProfileStore · 346 · Apache-2.0 · 2025-07-31 | paradoxum-games/lyra · 154 · MIT · 2026-03-25 | leifstout/dataServiceTyped · 108 · MIT · 2026-10-03 (설명 없음) |
| 네트워크·리모트 | osyrisrblx/t · 334 · MIT · 2025-03-11 (값 타입 검사) | 1Axen/blink · 193 · MIT · 2026-09-23 | ffrostfall/ByteNet · 183 · MIT · 2025-08-01 |
| UI 라이브러리 | dphfox/Fusion · 806 · MIT · 2026-02-02 | Roblox/react-luau · 583 · MIT · 2026-10-14 (읽기 전용 미러) | jsdotlua/react-lua · 576 · MIT · 2025-05-23 |
| 애니메이션 | fraktality/spr · 146 · MIT · 2024-07-31 | Reselim/Flipper · 144 · MIT · 2021-11-25 | littensy/ripple · 134 · MIT · 2026-07-18 |
| 입력 | **첨부 1에 입력 전용 라이브러리가 없음.** RbxUtil 안에 입력 모듈이 있는 것으로 알고 있지만 첨부 1로는 확인할 수 없음 (확인 필요) | — | — |
| 카메라 | Sleitnick/RbxCameraShaker · 127 · MIT · 2023-07-06 | (해당 없음) | — |
| 테스트 | flipbook-labs/flipbook · 125 · MIT · 2026-10-21 (UI 미리보기) | buildthomas/MockDataStoreService · 84 · Apache-2.0 · 2023-08-15 | Roblox/jest-roblox · 50 · MIT · 2026-10-02 |
| 린트·포맷 | JohnnyMorganz/StyLua · 2321 · MPL-2.0 · 2026-10-12 | JohnnyMorganz/luau-lsp · 558 · MIT · 2026-10-22 (이미 씀) | NightrainsRbx/RobloxLsp · 236 · MIT · 2025-01-25 |
| 패키지 | Roblox/foreman · 263 · MIT · 2026-05-01 | pesde-pkg/pesde · 129 · MIT · 2026-10-21 | (해당 없음) |
| 디버그·콘솔 | evaera/Cmdr · 533 · MIT · 2026-10-21 | Epix-Incorporated/Adonis · 514 · MIT · 2026-10-21 | SirMallard/Iris · 358 · MIT · 2026-10-21 |
| 성능 | Pyseph/PacketProfiler · 86 · MIT · 2026-09-09 | boatbomber/CullThrottle · 80 · MPL-2.0 · 2026-07-31 | MaximumADHD/Roblox-Parallel-Worker · 59 · MIT · 2025-06-01 |
| 기타 | rojo-rbx/rojo · 1812 · MPL-2.0 · 2026-10-06 | roblox-ts/roblox-ts · 1322 · MIT · 2026-10-19 | lune-org/lune · 967 · MPL-2.0 · 2026-10-21 |

**참고**
- 첨부 1에 없는 것: Selene (1차 조사 835★), Wally (1차 505★), Rokit. 이번 표로는 수치를 다시 확인할 수 없습니다.
- 기타에 들어간 묶음:
  - 상태 관리: charm, rodux, reflex, Roblox/signals
  - ECS: jecs, matter-ecs/matter, ecr
  - 유틸: RbxUtil, Janitor, goodsignal, LemonSignal, sift
  - 영역: ZonePlus, QuickZone
  - 예제 게임: slither, fishing-minigame, vesteria

---

## 3. 우리 게임에 지금 필요한 TOP 10

| # | 저장소 | 별 · 라이선스 · push | 해결할 우리 문제 | 넣는 일 | 시기 | 1차 조사 |
|---|---|---|---|---|---|---|
| 1 | fraktality/spr | 146 · MIT · 2024-07-31 | 정산·보상 숫자가 튀어 오르는 연출, 미니게임 게이지 바늘의 출렁임. 지금은 TweenService만 써서 스프링 느낌을 직접 계산해야 함 | 작음 (모듈 1개, 연출 부분에서만 호출) | **공개 전 OK** | 없음 |
| 2 | osyrisrblx/t | 334 · MIT · 2025-03-11 | 미니게임 6개가 새로 보낼 결과 리모트(점수·시간 등)의 값 타입·범위 검사 | 작음. 새 리모트에만 적용. **Guard에 이미 같은 기능이 있으면 넣지 않음** (Guard 내용은 첨부에 없어 확인 필요) | **공개 전 OK** (새 리모트만) | 없음 |
| 3 | Sleitnick/RbxUtil | 470 · MIT · 2026-08-11 | 미니게임을 열고 닫을 때 터치·RenderStepped 연결이 남아 폰에서 메모리가 새는 것 (Trove로 정리). Signal도 있음 | 작음. 필요한 모듈 1~2개만 복사 | **공개 전 OK** | 있음 (TOP 10 5번) |
| 4 | Pyseph/PacketProfiler | 86 · MIT · 2026-09-09 | 리모트 속도 문제를 숫자로 확인 (어느 리모트가 얼마나 보내는지). 성능 측정 | 작음. 개발 중에만 사용. 쓰는 형태(플러그인/모듈)는 README 확인 필요 | **공개 전 OK** | 없음 |
| 5 | SirMallard/Iris | 358 · MIT · 2026-10-21 | 미니게임 게이지 속도·판정 폭·보상값을 Studio 플레이 중에 바로 바꿔 보는 개발용 조정 창 | 작음~중간. **공개 빌드에서 꺼야 함** (주인만 또는 Studio 전용) | **공개 전 OK** (개발용) | 없음 |
| 6 | JohnnyMorganz/StyLua | 2321 · MPL-2.0 · 2026-10-12 | 코드 모양 통일 (포맷) | 작음. 다만 전체 적용 시 모든 파일이 바뀜 | 새 파일·수정 파일만이면 **공개 전 OK**, 전체 적용은 **공개 뒤** 따로 커밋 | 있음 |
| 7 | Roblox/jest-roblox | 50 · MIT · 2026-10-02 | 정산 계산·DataService 잠금 같은 로직의 자동 테스트 (지금 테스트 틀이 없음) | 중간. 돌리는 방법(Studio 안/밖)은 README 확인 필요 | **공개 뒤** (공개 전엔 저장·정산 몇 개만 시험해 볼 수 있음) | 없음 (1차엔 jsdotlua/jest-lua만) |
| 8 | MadStudioRoblox/ProfileStore | 346 · Apache-2.0 · 2025-07-31 | 저장 안전. 서버를 옮길 때 빠른 인계 (우리 잠금은 최대 30초 기다림) | **큼**. 옛 저장 모양을 옮기는 단계와 시험이 필요 | **공개 뒤** (1차 결론과 같음. 공개 전엔 자체 잠금을 Studio 2대로 시험) | 있음 (TOP 1) |
| 9 | 1Axen/blink | 193 · MIT · 2026-09-23 | 리모트 보안과 속도 (설계도로 검사·압축 코드를 생성) | **큼**. 리모트를 모두 손봐야 하고 Guard와 겹침 | **공개 뒤** | 있음 (①, zap과 함께) |
| 10 | lune-org/lune | 967 · MPL-2.0 · 2026-10-21 | Studio 없이 순수 Luau 로직(정산·확률 계산)을 컴퓨터에서 실행·시험 | 중간 (설치는 사용자 OK 후) | **공개 뒤** | 있음 (②) |

**주의**
- 1번 spr과 2번 t는 마지막 push가 2024년, 2025년으로 오래됐습니다. 작은 모듈이라 큰 문제는 아닐 수 있지만(추측) 폰에서 직접 확인해야 합니다. spr 대신 littensy/ripple (2026-07-18)도 선택지입니다.
- MPL-2.0 파일을 **게임 안에 넣고 고치면** 고친 그 파일을 공개해야 합니다. 예: CullThrottle. StyLua·Lune은 개발 도구라 게임에 들어가지 않습니다.
- luau-lsp는 이미 쓰고 있어서 TOP 10에서 뺐습니다.

---

## 4. 넣지 말 것 (유명하지만 우리와 안 맞음)

| 저장소 | 별 · 라이선스 · push | 이유 |
|---|---|---|
| rojo-rbx/rojo | 1812 · MPL-2.0 · 2026-10-06 | 자체 sync가 이미 있음. 공개 전에 동기화 흐름을 바꾸는 건 위험. 검토는 공개 뒤에 |
| roblox-ts/roblox-ts | 1322 · MIT · 2026-10-19 | 이미 Luau로 짜여 있음. TypeScript 전환은 전부 다시 쓰는 일 |
| dphfox/Fusion | 806 · MIT · 2026-02-02 | UIKit·MiniFrame을 갈아엎어야 함 |
| Roblox/react-luau · jsdotlua/react-lua | 583 · 576 · MIT | 위와 같은 이유에 더해 무거움. react-luau는 읽기 전용 미러 |
| Quenty/NevermoreEngine | 623 · MIT · 2026-10-22 | 큰 프레임워크라 구조가 바뀜 |
| Epix-Incorporated/Adonis, kohls-admin | 514 · 49 · MIT | 관리자 시스템. 친구 서버라 필요 적고, 공격받을 곳만 늘어남 (추측) |
| evaera/Cmdr | 533 · MIT · 2026-10-21 | `Dev/DevHooks`와 겹침. 공개 빌드에서 꺼야 하는 부담 |
| Ukendio/jecs 및 ECS류 | 475 · MIT · 2026-10-22 | 게임 구조 전체를 ECS로 바꿔야 함 |
| littensy/charm, Roblox/rodux, littensy/reflex | 271 · 336 · 109 | 상태 관리 프레임워크라 UI 데이터 흐름이 바뀜 |
| easy-games/chickynoid | 265 · MIT · 2024-05-27 | 캐릭터 이동을 서버 권한 방식으로 교체. 크고, 타이쿤엔 과함 (추측) |
| rbxts-flamework/core | 160 · MIT · 2025-09-04 | TypeScript 필요 |
| Reselim/Flipper | 144 · MIT · 2021-11-25 | 오래 안 바뀜. spr·ripple로 충분 |
| NightrainsRbx/RobloxLsp | 236 · MIT · 2025-01-25 | luau-lsp를 이미 씀 |
| lisphm/A-Chassis | 105 · MPL-2.0 · 2026-08-27 | 차 주행 섀시. 주행이 핵심 기능이 아니면 무거움. 주행을 넣을 때만 검토 |

---

## 5. 못 씀 목록 (라이선스)

게임 제작에 관련된 것만 적었습니다. GPL 도구는 게임에 넣지 않고 도구로만 쓰면 문제가 적은 경우가 많지만, 요청 기준대로 모두 여기에 넣었습니다.

### NOASSERTION: 라이선스 확인 필요

| 저장소 | 별 · push | 비고 |
|---|---|---|
| 1ForeverHD/TopbarPlus | 242 · 2026-10-20 | 상단 HUD 아이콘. 라이선스가 확인되면 후보 |
| Kampfkarren/Roblox | 397 · 2023-06-27 | 게임에서 떼어 낸 스크립트 모음 |
| Scythe-Technology/zune | 122 · 2026-08-30 | Luau 런타임 |
| nanoblox/hd-admin | 83 · 2026-09-24 | 관리자 |
| seal-runtime/seal | 62 · 2026-10-21 | Luau 스크립팅 |
| Roblox/gear | 55 · 2026-10-22 | gear 원본 |
| gogolumo/rbsmithy-roblox-claude-skill | 9 · 2026-10-16 | |
| cxmeel/resurface-plugin | 8 · 2026-04-28 | |

### GPL-3.0

| 저장소 | 별 · push |
|---|---|
| sebattfg/ZeroScript-Free | 361 · 2026-09-25 |
| Ransomwave/azul | 130 · 2026-10-21 |
| pinehappi/DataDelve | 50 · 2026-02-05 |
| tacheometry/testez-companion | 27 · 2024-04-21 |
| alexmercier25/Enoria | 11 · 2026-03-12 |
| RadiatedExodus/RunLSC | 7 · 2022-12-04 |

### AGPL-3.0

| 저장소 | 별 · push |
|---|---|
| S4US/Roqer | 164 · 2026-10-21 |
| hope1026/weppy-roblox-mcp | 67 · 2026-10-22 |
| photobooth-rbx/photobooth-plugin | 42 · 2026-10-12 |

### NONE (라이선스 없음)

| 저장소 | 별 · push |
|---|---|
| elevenpassin/awesome-roblox | 197 · 2025-05-01 (링크 목록이라 읽기만은 가능) |
| MaximumADHD/sm64-roblox | 121 · 2024-08-17 |
| MaximumADHD/Moonlite | 74 · 2024-08-08 |
| Sleitnick/RbxCookbook | 69 · 2021-12-13 |
| Kinlei/MaterialLua | 64 · 2023-04-18 |
| F3XTeam/RBX-Building-Tools | 62 · 2025-02-19 |
| TemporaryLooker22/Check-UI-Clean-Roblox | 59 · 2026-10-04 |
| prepsure/team-create-hats | 53 · 2025-11-17 |
| BrookenRecord/studio-activity | 53 · 2026-07-06 |
| Crazyblox/penumbra | 51 · 2026-02-12 |
| metaindev/connect-plugin | 15 · 2026-04-20 |
| Pugbread/ro-sync | 8 · 2026-10-09 |
| gdr1461/GAdmin | 8 · 2024-09-04 |

**"Best … 2026" 같은 제목의 NONE 저장소 수십 개** (별 68~75, push 2026-10-21~22, 예: forge-context-engine, luau-guardrail, slime-tycoon-forge, Rerokron-Sentinel-Core 등)
- 모두 라이선스가 없어서 못 씁니다.
- 별 수가 비슷하게 몰려 있고 같은 날 push된 모양이 홍보·스팸 저장소에서 흔한 패턴입니다 (추측). 내려받지 않기를 권합니다.

### 허용 목록에 없는 다른 라이선스

| 저장소 | 별 · 라이선스 · push | 비고 |
|---|---|---|
| Roblox/creator-docs | 860 · CC-BY-4.0 · 2026-10-21 | 공식 문서라 읽는 건 문제없음 |
| Anaminus/roblox-library | 74 · MIT-0 · 2023-12-12 | MIT보다 느슨하다고 알려져 있지만 요청 목록에 없어 확인 필요 |

---
## 메인 판단 (10-22 18:55) — 숫자는 GitHub API 원본(`github_roblox_list_1022.md`)과 다시 맞춰 봄
- **공개 전에 받아서 쓸 후보 3개(작고 MIT, 받기는 사용자 OK 뒤)**:
  1. **fraktality/spr**(146★, MIT, 2024-07 — 작은 모듈이라 오래돼도 괜찮다고 봄, 대안 littensy/ripple 134★ 2026-07) → wr-ui: 정산 숫자 튀기·미니 게임 게이지 출렁임(스프링 느낌).
  2. **Sleitnick/RbxUtil**의 **Trove 하나만**(470★, MIT, 2026-08) → wr-ui·wr-mini: 미니 게임 열고 닫을 때 터치·RenderStepped 연결 정리(폰 메모리 새는 것 방지).
  3. **SirMallard/Iris**(358★, MIT, 2026-10-21) → wr-mini: Studio 안에서만 미니 게임 속도·판정 폭·팁을 바로 바꿔 보는 개발 창(공개 판엔 안 들어가게 IsStudio 안에서만).
- **뺌**: osyrisrblx/t — 우리 `Guard`에 이미 숫자 범위·NaN·타입 검사가 있음(Guard.luau 62~71줄). PacketProfiler는 필요할 때만.
- **공개 뒤**: StyLua 전체 적용, jest-roblox, ProfileStore(저장 갈아타기), blink(리모트), lune — 1차 결론과 같음.
- 라이선스 주의: MPL-2.0 파일을 게임 안에 넣고 고치면 그 파일 공개 의무 → 게임 안에는 MIT만.
- **사용자 결정 (10-22 18:48)**: "별이 너무 몇 개 없어 ㅋㅋ 안 돼" → spr·Trove·Iris 받지 않음. 별 많은 것(StyLua 2.3k·Rojo 1.8k·roblox-ts 1.3k·Lune 1k·Fusion 0.8k)은 개발 도구이거나 구조를 갈아엎는 틀이라 공개 전엔 안 넣음 → **공개 전 GitHub 모듈 0개**, 공개 뒤 StyLua(개발 도구) 정도만 다시 검토.
