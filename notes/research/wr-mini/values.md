# 미니 게임 차종별 값 — 근거 (wr-mini, 10-22)

조사: `placard_coolant.md`(API research, 검색 23회) + car_knowledge `03_wheels_tires`·`04_cooling`·`teardown/tools_real.md`.

| 값 | 게임 | 근거 | 메모 |
|---|---|---|---|
| 세단 문 라벨 공기압 | **35 psi** (`Config.TirePsi.Sedan`) | 03 [11] Camry 2018 앞뒤 35 psi · tirepressure.com 2018 Camry 35/35 | 식은 타이어 기준 |
| SUV(Crossover) 문 라벨 | **35 psi** (`Config.TirePsi.Crossover`) | Mazda CX-5 매뉴얼 19인치 35/35(17인치 34) https://www.mazdausa.com/static/manuals/2017/cx5/contents/10020109.html · Equinox Premier 35/35 https://tirepressure.com/2018-chevrolet-equinox-tire-pressure | 우리 SUV = 여러 차 섞은 오리지널(ref_suv), 큰 휠 → 35. RAV4 미국 라벨은 확인 못 함 |
| 해치백 | (차종 아직 코드에 없음) | Mazda3 해치 매뉴얼 36/36 https://www.mazdausa.com/static/manuals/2019/mazda3/contents/10020109.html | 해치백이 들어올 때 wr-carbook 확인 |
| 냉각수 색 | **분홍** (세단·SUV 둘 다) | 04 [19] Toyota SLLC 분홍; SUV 속 = Camry와 같은 가로배치 I4(TNGA-K, ref_suv) | Honda 파랑·GM 주황·Nissan 파랑은 다른 회사 계열 차가 생기면 |
| 탱크 눈금 글자 | **FULL** (화면 깃발 기본) | Toyota FULL/LOW 또는 MAX/MIN(toyotanation 매뉴얼 인용), 04 [7] F·L | |
| 토크 렌치 | 클릭형, 딸깍에서 멈춤 | tools_real [S104] https://en.wikipedia.org/wiki/Torque_wrench · [S105] https://www.parktool.com/en-int/blog/repair-help/torque-wrench-use-and-care | 차 내린 뒤 별 순서(03 [12][32][33]) |
| 흠집 광내기 | 손톱 안 걸리는 얕은 흠 = 광내기만, 칠 X | 11 [27] | BODY_SCRATCH_LIGHT |
