# 복원 등급 배지 참고 — Bronze / Silver / Gold (wr-art, 10-21)

근거: 메인 부탁(docs/design/flip_loop.md 복원도 = 핵심 부품 60 + 외관 25 + 청결 15, 무료 메달 팩 X — notes/gpt/main/icons_free_pack_main_decision.md). 내장 브라우저 Bing 화면(다운로드 X, 640×478).

| 파일 | 검색 주소 | 무엇 |
|---|---|---|
| 01_bing_vintage_hood_emblems.jpg | https://www.bing.com/images/search?q=vintage+car+hood+emblem+badge+chrome+enamel+shield+wings | 1930~50년대 보닛 엠블럼: 가운데 방패/문장 + **양옆 크롬 날개**, 색 에나멜 상감 |
| 02_bing_mechanic_cert_patches.jpg | https://www.bing.com/images/search?q=automotive+mechanic+certification+patch+badge+master+technician | 정비 자격 패치(ASE 등): **톱니바퀴 고리** 안 문장 + 아래 리본 칸 |
| 03_bing_car_show_trophies.jpg | https://www.bing.com/images/search?q=car+show+trophy+best+in+show+award+plaque+concours+medal | 쇼카 트로피: 금색 차 앞모습·피스톤·핸들 모양, 받침 |

## 섞기 표
| 가져오는 곳 | 특징 | 안 가져오는 것 |
|---|---|---|
| 옛 보닛 엠블럼 | 양옆으로 펼친 **금속 날개**(Gold만), 에나멜 상감 | 특정 회사 문장·마스코트·Cadillac 화관 등 |
| 정비 자격 패치 | 가운데를 감싸는 **톱니바퀴 고리**(금속, 글자 없음) | ASE 파란 톱니 + 글자 로고 그대로, 파랑 바탕 |
| 쇼카 트로피 | 가운데 **차 앞모습** 부조 → 우리 세단 얼굴(곧은 빛 띠 + 사다리꼴 흡기구) | 실제 차 모양, 받침·명패 |
| 정비소(우리 게임) | 톱니 뒤 **엇갈린 렌치 2개**(Silver·Gold), 빨간 공구함색 에나멜 | — |

## 등급 구별 (같은 바탕 모양 + 금속 3색 + 장식 늘어남)
- Bronze: 톱니 고리 + 가운데 빨간 에나멜 원 + 우리 차 얼굴 부조, 구리빛 브론즈.
- Silver: Bronze + 뒤에 엇갈린 렌치 2개, 은빛 크롬.
- Gold: Silver + 양옆 날개 + 위 작은 별 1개, 노란 금.

## 결과 (art/ui/badges/, 1254² 투명 PNG)
- badge_gold.png (job badge_gold_1792544155) — 먼저 그림, ui_B.png 그림체 ref.
- badge_silver.png · badge_bronze.png (job …_1792544263) — gold를 같은 물건 ref로 장식만 빼고 금속색 바꿈.
- 비교 시트: art/ui/badges/_check/badges_sheet.png (64px 미리보기 포함).
- 투명 영역에 아주 작은 점(한 덩어리 8px 이하, 장당 50~130개)이 남아 있음 — 64~256px 표시에선 안 보임.
