# 게임 패스 아이콘 참고 (wr-art, 10-21)

근거: 메인 부탁 + `docs/design/monetization.md` §1·§4. Roblox 패스 이미지 규칙(메인 전달, 공식 문서): 512×512 이하, 중요한 건 가운데 **원 안**(가장자리가 둥글게 잘림), png.
스크린샷 = 내장 브라우저 Bing 화면(다운로드 X).

| 파일 | 검색 주소 | 무엇 |
|---|---|---|
| 01_bing_roblox_gamepass_tycoon.jpg | https://www.bing.com/images/search?q=roblox+gamepass+icons+tycoon+VIP+2x+cash+gold+tools+icon+set | 인기 타이쿤 패스 아이콘(2x Cash·VIP 등) |
| 02_bing_roblox_gamepass_round.jpg | https://www.bing.com/images/search?q=roblox+game+pass+icon+round+circle+design+512 | 원형 패스 아이콘 세트·DevForum 피드백 |

## 공통점
1. **둥근 바탕 원**(진한 테두리 + 안쪽 그러데이션/햇살 무늬) 가운데에 **큰 물건 하나**, 원 밖으로 조금 튀어나와도 중요한 건 원 안.
2. 세트는 **같은 원 틀 + 원 색만 다르게** 해서 한눈에 구별.
3. 64px에서도 읽히게 굵은 실루엣·강한 대비, 작은 디테일 X.
4. 인기 아이콘은 '2x'·'VIP' 글자가 많지만 우리는 **글자 X**(Roblox가 이름을 따로 보여 줌) → 물건 모양으로만.

## 우리 세트
- 같은 틀: 둥근 원판 = kit B 말투(빨간 공구함 금속 테두리 + 볼트 4개), 안쪽 색만 패스마다 다름. 위에서 부드러운 빛 하나. 방사형 빛줄기 X.
- Garage Rename(간판 + 연필), Gold Tools(금색 렌치·래칫·임팩트 + 작은 불꽃), Paint Pro(스프레이 건 + 불꽃·펄 무늬 차 문), Neon Garage(네온 정비소 정면), Custom Sign(간판 + 'ABC'), Starter Look(정비사 옷 + 공구 + 작은 리본).

## 결과 (art/ui/gamepass/, 1254² 투명 PNG — 모서리 투명, 그림은 원 안)
| 패스 | codex job |
|---|---|
| gold_tools.png (틀 기준, 먼저) | gold_tools_1792551061 |
| garage_rename · paint_pro · neon_garage · custom_sign · starter_look | …_1792551311 (gold_tools를 그림체 ref로) |
- 확인 시트(64px + 원으로 자른 미리보기): _check/gamepass_sheet.png
- 크기: Roblox 패스 규칙 512 이하 → 파일은 1254² 원본(줄이는 건 업로드 때 메인 판단 — Roblox가 어차피 줄임).
- ⚠ Gold Tools의 임팩트 렌치가 금색 + 검정 그립·배터리라 노랑+검정 공구 브랜드 색 조합을 떠올릴 수 있음 → 메인·GPT 판단.
- starter_look 잡은 그림 3장이 나왔지만 Codex 설명에 '고침' 없음(변형 여러 장 중 1장 저장).
