# 같은 차종 안 '등급(트림)마다 겉이 다른 점' — 변형 키트 근거 (wr-art-cars, 10-22)

부탁: 메인 10-22 14:50 (사용자 "세단, suv도 디자인 다양하게 해줘 차종이 같다고 디자인이 다 같을 필요는 없자눙") → `docs/design/car_variety.md` §1 변형 키트.
wr-carbook 트림 고증은 아직 없음(board 10-21 낮 carbook 줄: "부탁 받은 게 없어서 안 했어요") → 이번에 사진 + 위키로 직접 확인. 브랜드 얼굴은 안 가져오고 **여러 회사에 공통인 '등급 차이 패턴'만**.
스크린샷 = 내장 브라우저 Bing 이미지 검색 화면(다운로드 X).

| 파일 | 검색 주소 | 본 것 |
|---|---|---|
| 01_bing_camry_le_se_xse.jpg | https://www.bing.com/images/search?q=2025+Camry+LE+vs+SE+vs+XSE+front+comparison | Camry 기본(LE) = 차색 범퍼 + 가로줄 아래 그릴, 스포티(SE/XSE) = 검은 그물 큰 흡기구 + 검은 장식 + 검은 지붕(XSE 투톤) |
| 02_bing_accord_lx_sport.jpg | https://www.bing.com/images/search?q=Honda+Accord+LX+vs+Sport+front+bumper+wheels+comparison | Accord 기본(LX) = 은색 휠·크롬 장식, Sport = 검은 장식·큰 검은/투톤 휠·트렁크 스포일러 |
| 03_bing_rav4_le_xle_adventure_trd.jpg | https://www.bing.com/images/search?q=RAV4+LE+vs+XLE+vs+Adventure+vs+TRD+Off-Road+front+comparison | RAV4 기본(LE/XLE) vs 거친(Adventure/TRD) = 더 크고 각진 검은 그릴, 아래 보호판, 지붕 레일·가로대, 주황 포인트 |
| 04_bing_crv_ex_sport_touring.jpg | https://www.bing.com/images/search?q=Honda+CR-V+EX+vs+Sport+Touring+black+trim+front+comparison | CR-V 기본(EX) = 은색 장식·은색 휠, Sport/Sport Touring = 검은 그릴 테두리·검은 휠 |
| (글) Wikipedia "Toyota RAV4" | https://en.wikipedia.org/wiki/Toyota_RAV4_(XA50) | ① 2021 개편: "alloy wheels which can be had in either silver or black" ② 6세대: 겉을 3 "design themes"로 나눔 = **Core**(LE·XLE·Limited) · **Adventure/Rugged**(Woodland) · **Sport**(SE·XSE·GR Sport) ③ Woodland = 브론즈 휠 + 지붕 레일 ④ TRD Off-Road = 앞 보호판(skid plate) |

## 공통 패턴 (2개 회사 이상에서 본 것)
| 바뀌는 곳 | 기본(Core) | 스포티(Sport) | 거친(Rugged, SUV만) | 근거 |
|---|---|---|---|---|
| 앞 아래 그릴·흡기구 | 차색 범퍼 + **가로 막대** 몇 줄, 작은 흡기구 | **검은 그물(벌집) + 더 큰 흡기구**, 양옆 세로 공기구멍, 아래 **얇은 검은 립** | 더 크고 네모난 검은 그릴 + **은색/검은 보호판** | 01·02·03·04 |
| 장식 색 | 은색·크롬 | **유광 검정**(그릴 테두리·거울·창틀) | 무광 검정 + 포인트 색 | 01·02·04 |
| 휠 | 은색 합금(옛·싼 차 = **강철 + 플라스틱 휠캡**) | **크고 검은/투톤(검은 면 + 깎은 은색 모서리)** | 브론즈·짙은 회색 + 굵은 타이어 | 02·04·위키 ① ③ |
| 지붕 | 차색 | **검은 지붕 투톤** | 지붕 레일 + 가로대 | 01·03·위키 ③ |
| 뒤 | 없음 | 트렁크 **작은 립 스포일러** | — | 02 |
- 헤드라이트 **외곽 모양은 등급 사이에 그대로**, 안쪽 렌즈·주간등만 다름(01·02 사진 — car_variety §1 '헤드라이트 모양 교체 X'와 맞음).
- 강철 휠 + 휠캡은 요즘 새 차 기본형엔 드묾 → 우리 게임에선 '오래된·싼 손님 차'(Rosa) 느낌으로 쓰는 게 맞음(car_variety §1 단골 예와 같음).

## 우리 키트에 옮기기 (car_variety §1 그대로 + 위 근거)
- 앞범퍼 2 = **기본(Core)** · **스포티(Sport)** — 같은 범퍼 외곽·볼트 자리, 다른 건 그릴 무늬(가로 막대 ↔ 검은 벌집)·안개등 자리(작은 세로 홈 ↔ 큰 옆 공기구멍)·아래 립(없음 ↔ 검은 립). 헤드라이트 외곽 그대로 + 렌즈 무늬만.
- 휠 3 = 강철 + 휠캡 · 은색 5스포크 · 투톤(검은 면 + 은색 모서리). 타이어 공용.
- 소품 2 = 지붕 가로대(루프랙) · 작은 스포일러(세단 = 트렁크 립, SUV = 지붕 끝 스포일러는 이미 있으니 **SUV는 루프랙 가로대 / 뒤 범퍼 위 작은 날개 X** → SUV 소품 = 가로대 · 앞 보호판(Rugged)로 제안).
- 도색: 단색 · 투톤(검은/흰 지붕) · 줄무늬(보닛→지붕→트렁크까지 이어지는 2줄).
- 제안(나중): SUV에 세 번째 얼굴 '거친(Rugged)'이 실제 등급 패턴이라 SUV에 더 잘 맞음 — 공개 전엔 2종만.
