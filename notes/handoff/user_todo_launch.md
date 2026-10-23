# 공개 전 사용자 할 일 (wr-release 정리, 2026-10-22)

공개 날 = **10/31(토)**. 사람 시험 = 10/29(목). 아래는 **사용자만 할 수 있는 일**이에요(게시·결제·설문은 우리가 못 해요).
메인이 "게시해도 돼요"라고 말하기 전에는 공개 버튼을 누르지 않아요.
모두 **Creator Dashboard**(create.roblox.com → 내 작품 → 그룹 게임 "렌치 & 라이드") 안에서 해요.

| | 할 일 | 언제 | 어디서·어떻게 | 준비된 것 |
|---|---|---|---|---|
| ⬜ | **1. 연령 설문**(안 하면 아무도 게임을 못 해요) | 10/30까지 | 게임 → Publish settings → Content rating → Start → 쪽마다 답 → Submit | 추천 답 표 = `docs/design/store_page.md` §5 (거의 다 "없음", 자유 창작 = "아니요") |
| ⬜ | **2. 게임 아이콘 넣기** | 10/30까지 | 게임 → Places/Basic info → Icon → 그림 올리기 | `art/ui/brand/game_icon_512_v2.png` (메인 검수 끝난 것으로 — 메인이 마지막 판을 알려 줌) |
| ⬜ | **3. 썸네일 넣기** | 10/30까지 | 게임 → Thumbnails → 순서대로 올리기 | `art/thumbs/final_key/` 1_A → 2_B → 3_D → 4_C (메인 최종 검수 뒤) |
| ⬜ | **4. 한 서버 최대 인원 = 4** | 10/30까지 | 게임 → Places → 이 장소 → Settings(또는 Configure) → Server Fill / Max Players = **4** | 정비소 1개 = 주인 + 친구만이라 4명이 딱 맞아요 |
| ⬜ | **5. 게임 설명 글** | 10/30까지 | 게임 → Basic info → Description | 영어 원문 + 한국어 = `docs/design/store_page.md` §1 |
| ⬜ | **5b. 한국어 게임 이름 = "렌치 & 라이드 : 정비소 타이쿤"** (사용자 10-22 결정) | 10/30까지 | 게임 → **Localization** → 한국어(Korean) → Experience information의 **Name**에 `렌치 & 라이드 : 정비소 타이쿤` 넣고 저장(같은 곳 Description에 `store_page.md` §1 한국어) | 지금 한국어 이름 '차고 타이쿤'은 로블록스 **자동 번역**(Garage → 차고)이라 손으로 넣어야 바뀌어요. 영어 이름 "Wrench & Ride : Garage Tycoon"은 그대로(Open Cloud로 확인 10-22). 로고·게임 안 글은 이미 '정비소 타이쿤' |
| ⬜ | **6. 폰으로 직접 해 보기** | 10/29 시험 날 | 진짜 폰에서 게임 열기 → 첫 차 고치기 → 글자 잘림·버튼 크기·느림 보기 | 메인이 "폰 시험 판 준비됐어요" 하면 |
| ⬜ | **7. 친구 들어오기 진짜 시험** | 10/29~30 | 친구 1명과 같이 들어와서 초대(Invite)·Join이 되는지 | Studio에선 흉내만 해 봤어요 — 진짜 게임에서만 확인돼요 |
| ⬜ | **8. 공개 버튼** | **10/31(토)**, 메인이 "게시해도 돼요" 한 뒤 | ① Studio 게시용 창에서 **File → Publish to Roblox**(저장만으로는 진짜 게임에 안 올라가요) → ② 대시보드 게임 → Privacy/Access → **Public** | 10/30 밤 = 마지막 굽기·저장(wr-release) |
| ⬜ | (나중) 게임 패스 판매 켜기 | 기능이 다 들어간 것만 | 게임 → Monetization → Passes → 하나씩 On sale | 장부 `art/roblox_gamepasses.json`(지금은 전부 판매 X). 무엇을 팔지 = wr-pass가 정리 → 사용자 결정 |

## 알아 두면 좋은 것
- **연령 설문 '무서움(Fear)' 칸**: 메모는 "없음"이지만, 지금 판에는 할로윈 손님 Ella(밤길·자정에 '펑' 호박으로)가 들어 있어요. 무섭지 않은 동화 느낌이라 "없음"으로 봐도 될 것 같지만, 메인이 한 번 더 보고 알려 드릴게요.
- 게시용 창(Studio "렌치 & 라이드 : 차고 타이쿤")은 Team Create로 자동 저장돼요. 창을 닫아도 괜찮아요.
- 공개 뒤 고칠 게 생기면 → 세션들이 고치고 → wr-release가 다시 굽고 → 사용자는 Studio에서 **File → Publish to Roblox**만(메인이 부탁할 때).
