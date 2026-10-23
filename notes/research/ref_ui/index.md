# UI 참고 — 인기 Roblox 게임 화면 (wr-art, 10-21)

내장 브라우저 Bing 이미지 검색 화면 스크린샷(다운로드 X, 800×597). 한 장에 게임 화면·UI 10~20장 → 모두 60장 이상 훑음.
기준 문서: `docs/design/ui_screens.md` v0.2(wr-design) — 폰 가로 812×375 기준, 버튼 48 px+, 글자 18 px+(Cash 22 px+), 테두리 2 px, 영어 원문, 이모지 X.

| 파일 | 검색 주소 | 무엇 |
|---|---|---|
| 01_bing_roblox_tycoon_ui_kits.jpg | https://www.bing.com/images/search?q=roblox+tycoon+game+UI+HUD+shop+menu+screenshot+2025 | 타이쿤 UI 키트(Cash 띠·Rebirth·Shop·Settings·Rewards 창), DevForum 'good looking UI' |
| 02_bing_restaurant_retail_tycoon.jpg | https://www.bing.com/images/search?q=Restaurant+Tycoon+2+Retail+Tycoon+2+roblox+UI+shop+screenshot | Restaurant Tycoon 2·Retail Tycoon 2: 아래 아이템 줄, 하늘색 둥근 창, 잠금 아이콘 업그레이드 목록 |
| 03_bing_ps99_grow_a_garden.jpg | https://www.bing.com/images/search?q=Pet+Simulator+99+Grow+a+Garden+roblox+UI+buttons+screenshot | Pet Simulator 99(초록 통통 버튼·두꺼운 외곽선), Grow a Garden(나무판 상점·위 탭 SEEDS/GARDEN/SELL) |
| 04_bing_cdt_driving_empire.jpg | https://www.bing.com/images/search?q=roblox+Car+Dealership+Tycoon+Driving+Empire+UI+HUD+mobile+screenshot | Car Dealership Tycoon(위 Cash 띠 + 오른쪽 아이콘)·Driving Empire(딜러십 카드 격자, 설정 창) — **같은 장르(차)** |
| 05_bing_bloxburg_adopt_me.jpg | https://www.bing.com/images/search?q=Bloxburg+Adopt+Me+roblox+UI+menu+mobile+screenshot | Adopt Me(분홍·하늘 둥근 카드, 큰 Play 버튼)·Bloxburg(빌드 메뉴, 색 고르기) |
| 06_bing_theme_park_lumber_pizza.jpg | https://www.bing.com/images/search?q=Theme+Park+Tycoon+2+Lumber+Tycoon+Work+at+a+Pizza+Place+roblox+UI+screenshot | Theme Park Tycoon 2(아래 건설 아이콘 줄)·Lumber Tycoon 2·Work at a Pizza Place(작은 UI, 세계가 주인공) |
| (ref_style/03) | notes/research/ref_style/03_bing_roblox_mechanic_games.jpg | Roblox 정비 게임(Car Repair Simulator 등) 화면 |

## 공통점
1. **위 가운데 또는 왼쪽 위 = 돈 띠**(초록 $ 아이콘 + 큰 숫자, 흰 글자 + 검정/진한 테두리). 오른쪽 위·왼쪽 가운데에 **둥근 사각 아이콘 버튼 세로 줄**(Shop·Settings·Rewards).
2. **아래 가운데 = 아이템·도구 줄**(정사각 칸 5~8개, 고른 칸은 테두리 굵게·살짝 큼). Retail·Theme Park·Restaurant 모두 같음.
3. **창(Shop)** = 둥근 사각 판 + 위 제목 리본/탭 + 오른쪽 위 빨간 X(정사각 큰 버튼) + 카드 격자(그림·이름·가격·초록 Buy). 폰에선 화면 대부분.
4. 버튼: **두꺼운 외곽선 + 아래쪽 진한 그림자 띠(눌리는 느낌)**, 초록 = 사기/좋음, 빨강 = 닫기/위험, 노랑/주황 = 강조·한정.
5. 글자: **굵고 둥근 산세리프(Fredoka·Gotham Black 계열) + 2~3 px 진한 테두리** — 배경이 뭐든 읽힘.
6. 같은 장르 Car Dealership Tycoon·Driving Empire는 **어두운 반투명 판 + 흰 글자**(차 그림이 주인공)로 더 차분함. 펫·정원 게임은 밝고 통통.
7. 세계가 주인공인 게임(Lumber, Pizza Place, Theme Park)은 UI가 작고 가장자리에만.

## 우리 3안 (그림체 B와 어울리게, 같은 화면·같은 배치)
- **A 깔끔한 둥근 카드**: 흰/아주 옅은 회색 반투명 둥근 카드, 진한 남색 글자, 포인트 하늘색(차 색)·초록 Buy. 차분, 차·정비소가 주인공(CDT·Adopt Me 계열).
- **B 정비소 느낌**: 공구함 빨강 + 브러시드 금속판(회색) + 모서리 볼트 4개 장식 + 노랑-검정 경고 띠 아주 조금, 숫자는 계기판 느낌. 우리 게임만의 개성.
- **C 통통 타이쿤**: 아주 큰 통통한 버튼, 두꺼운 검정 외곽선 + 아래 그림자 띠, 밝은 초록·주황·하늘색(PS99·Grow a Garden 계열). 아이들에게 가장 익숙.
- 공통: 영어 원문만, 이모지 X(아이콘은 그림), 폰 가로 844×390 화면 비율, 왼쪽 아래 이동 스틱·오른쪽 아래 점프 자리 비움.
