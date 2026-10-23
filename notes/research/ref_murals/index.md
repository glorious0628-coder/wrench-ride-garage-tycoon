# Gearport 벽화 참고 (wr-art, 10-21)

근거: 메인 부탁(가상 도시 Gearport = 디트로이트 '모터 시티' 느낌, 실제 벽화·브랜드·실존 인물 X, 글자 'GEARPORT'만), wr-builder `notes/research/ref_detroit/index.md` 18·19·20(Eastern Market 벽화, 다리 밑 그림), `docs/specs/world_contract.md` ★ 그림 자리 + `notes/playtest/wr-builder/gearport/stage3.md`.
스크린샷 = 내장 브라우저 Bing 화면(다운로드 X, 640×478).

| 파일 | 검색 주소 | 무엇 |
|---|---|---|
| 01_bing_eastern_market_murals.jpg | https://www.bing.com/images/search?q=Detroit+Eastern+Market+murals+painted+building+wall | 디트로이트 Eastern Market 벽화: 건물 벽 전체를 덮는 밝은 그림, 큰 굵은 글자, 만화풍 |
| 02_bing_greetings_postcard_murals.jpg | https://www.bing.com/images/search?q=american+small+town+mural+brick+wall+greetings+from+vintage+car+river+bridge | 미국 소도시 'Greetings from' 엽서 벽화: **큰 입체 글자 속에 동네 장면**, 뒤에 하늘·풍경 |
| 03_bing_faded_industrial_murals.jpg | https://www.bing.com/images/search?q=faded+painted+mural+brick+factory+wall+workers+industrial+history | 공장 벽화·바랜 벽(⚠ 디에고 리베라 '디트로이트 산업' 벽화가 많이 나옴 → **구도·인물·기계 모양 따라 하지 않음**, 바랜 벽 질감만 참고) |
| 04_bing_ghost_signs.jpg | https://www.bing.com/images/search?q=ghost+sign+faded+painted+advertisement+old+brick+building+america | 고스트 사인: 오래 해에 바래 **벽돌 줄눈이 비쳐 보이는** 칠, 가장자리 벗겨짐 |
| 05_bing_farmers_market_murals.jpg | https://www.bing.com/images/search?q=farmers+market+mural+fruit+vegetables+people+painted+wall+usa | 미국 장터 벽화: 큰 과일·채소 바구니, 차양, 사람들 |

## 섞기 → 5장 배정
| 판 (W×H) | 주제 | 가져온 특징 |
|---|---|---|
| GP_MuralWest 24×16 | 'GEARPORT' 엽서 벽화 | 02의 큰 입체 글자 + 글자 속 동네 장면(강·다리·옛 차·굴뚝) |
| GP_MuralEast 24×16 | 강과 다리, 강가 길의 옛 차 | 01의 밝은 색 면 + 강가 도시 풍경 |
| GP_MuralCross 24×28 | 동네 정비공 영웅(블록 사람) + 리프트 위 옛 차 + 톱니 | 01 만화풍 큰 인물 |
| GP_MuralMarket 26×10 | 장터: 과일·채소 바구니·차양·사람들 | 05 |
| GP_MuralWorks 40×22 | 옛 자동차 공장 조립 줄·노동자·굴뚝 | 밝고 따뜻한 캐주얼(리베라 구도 X) |
- 공통: 그림체 B(둥근 캐주얼), 사람은 우리 게임처럼 **Roblox 블록 사람**, 04처럼 **조금 바랜 칠 + 벽돌 줄눈이 살짝 비침**. 실제 브랜드·실존 인물·실제 벽화 X.

## 결과 (art/concepts/murals/, 비율 = 판 W×H 그대로 맞음)
| 판 | 파일 크기 | codex job |
|---|---|---|
| GP_MuralWest 24×16 | 1536×1024 | GP_MuralWest_1792549095 |
| GP_MuralEast 24×16 | 1536×1024 | GP_MuralEast_1792549095 |
| GP_MuralCross 24×28 | 1161×1355 | GP_MuralCross_1792549095 |
| GP_MuralMarket 26×10 | 2022×778 | GP_MuralMarket_1792549339 |
| GP_MuralWorks 40×22 | 1691×930 | GP_MuralWorks_1792549338 |
- 같은 축척 비교 시트: art/concepts/murals/_check/murals_sheet_same_scale.png (1 stud = 30 px).
- ⚠ 검수 때 볼 것: East의 투톤 1950년대 크루저와 Works 조립 줄의 1910년대 차가 실제 옛 차(1955 Chevy Bel Air·Ford Model T 시대 모양)를 꽤 닮음 — 시대 느낌으로 OK인지, '그대로 베낀 디자인 X'에 걸리는지 메인 판단.

## v2 고침 (10-21, 메인·GPT notes/gpt/main/murals_r1_a.md) — East·Market·Works 처음부터 다시(v1은 _draft/)
- East (job GP_MuralEast_1792549777): 투톤 벨에어 느낌 → 한 색 청록 오리지널 1950년대 차(타원 그릴 1줄, 흰 지붕·옆 장식·V 장식 없음).
- Works (job GP_MuralWorks_1792549777): 검은 똑같은 차 행렬 → 4대 모두 다른 차(회색 차대·초록 로드스터·적갈색·남색), 일꾼 5명 밝은 작업복, 큰 덩어리 위주.
- Market (job GP_MuralMarket_1792549777): 사람 5명·큰 상자 위주로 덜어 냄.
- 세 장 모두 Cross·West를 그림체 ref로 넣고 블록 사람 비율 문장을 같게.
- 확인: _check/murals_sheet_same_scale_v2.png(같은 축척), _check/murals_far_400px.png(벽 거리 축소판 가로 400px).
