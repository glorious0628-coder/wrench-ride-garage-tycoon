# 해치백 — 3D용 속 구조 노트 (wr-carbook, 2026-10-22)

> **누가 보나**: 3D 도우미(10/23~), wr-design(`hatchback_spec`), wr-dev.
> **바탕**: [hatchback.md](hatchback.md)(10-21: 크기·서스·고장·겉모양) + 이번에 새로 찾은 것: 제조사 사양서·부품 카탈로그·사용설명서 글, **실제 뒷모습 사진 직접 봄**(Wikimedia Commons — Civic 해치 2022, Mazda3 해치, Corolla 해치).
> **섞은 차** = Honda Civic Hatchback(11세대) · Toyota Corolla Hatchback(E210) · Mazda3 Hatchback(4세대) · VW Golf GTI(Mk8).
> **결론 먼저**: **앞(엔진룸·앞 서스·앞 브레이크)과 바퀴는 세단 그대로.** 다른 건 **뒤쪽만**: 트렁크 뚜껑 → 뒷유리째 열리는 해치, 해치 가스 스트럿 2, 뒷유리 와이퍼 + 모터, 짧은 뒤 오버행(스페어·머플러 자리 압축). 뒤 서스는 멀티링크(4대 중 3대) = 세단과 같은 종류.
> **표시 규칙**: [n] = 맨 아래 출처, "(검색 요약)" = 요약만 봄, "(확인 못 함)", **"추정"** = carbook 계산, **"게임 제안"** = 정하는 건 wr-design. 좌표 약속은 car_spec 그대로(앞 −Z, 위 +Y, 조수석 +X, 원점 = 바퀴 사이 땅).

---

## 0. 세단과 같은 것 / 다른 것 (한 장 요약)

| 구역 | 세단과 같음? | 근거 |
|---|---|---|
| 엔진·변속기 | **같음** — 앞 엔진, 가로배치 직렬 4기통, 앞바퀴굴림(4대 모두) | [hatchback.md 1절] |
| 엔진룸 배치(배터리·라디에이터·액 통) | **같음**(세단 좌표에서 앞 차축 차이만큼 옮기기) | Civic 해치는 세단과 휠베이스·앞모습이 같음 [hatchback.md 1절] · 이 4대의 배터리 쪽은 (확인 못 함), 앞 세대 Mazda3은 운전석 쪽 [9] |
| 앞 서스 | **같음** — 맥퍼슨 스트럿(4대 모두) | [hatchback.md 1절] |
| 뒤 서스 | **같음** — 멀티링크(Civic·Corolla·GTI). Mazda3만 토션빔 | [1][2][3][4] |
| 브레이크 | **같음** — 4바퀴 디스크(뒤 디스크 4대 모두: Civic 10.2 in 솔리드 · Corolla 11 in · Mazda3 10~10.4 in · GTI 12 in) | [1][2][3][4] |
| 바퀴 너트 | **같음 — 5개**(4대 모두). Civic 5×114.3 · GTI 5×112 · Mazda3·Corolla 규격은 출처가 엇갈림 | [5][6] |
| 너트 조임 | 비슷 — Civic 108 N·m(CVT) · Corolla 103 N·m · Mazda3 108~147 N·m (세단 103 N·m) | [5][6][7] (검색 요약 포함) |
| 잭 자리 | **같음** — Mazda3 사용설명서는 세단·해치 한 가지 방법(차체 아래 레일 앞·뒤 자리) | [8] |
| 앞 와이퍼·워셔 | **같음** | — |
| **뒤 끝** | **다름** — 해치(뒷유리 포함), 스트럿 2, 뒷유리 와이퍼, 짧은 뒤 | §2~§5 |

---

## 1. 크기 (car_roster v0.2) + 단순화 선택지

| 항목 | car_roster 값 | 메모 |
|---|---|---|
| 길이 × 폭 × 높이 / 휠베이스 | **15.8 × 7.4 × 5.8 / 9.6** → 앞 차축 Z **−4.8**, 뒤 **+4.8** | 4대 평균 [hatchback.md 2절] |
| 앞 / 뒤 오버행 | **3.4 / 2.8** → 앞 끝 Z −8.2, 뒤 끝 +7.6 | 앞은 세단과 같고 **뒤만 0.8 짧음** |
| 타이어 | **2.64**(2.3 × 1.146) → 바퀴 중심 Y 1.32 | |
| 엔진룸 | 세단 좌표 + (0, 0, **+0.2**) | 앞 차축이 −5.0 → −4.8로 0.2 뒤로 온 만큼(SUV 규칙과 같은 방식). 바퀴가 0.11 작아 바퀴집 쪽만 맞춤 |

**게임 단순화 선택지 (근거 있는 것, wr-design이 고르기)**
- **A. car_roster대로**(15.8 / 9.6 / 타이어 2.64): 실제 4대 평균. 차체·바퀴 새로.
- **B. '세단 앞 절반 그대로'**: Civic·Mazda3은 해치와 세단의 **휠베이스·폭이 똑같고 뒤만 다름**(Civic 2,735 mm 같음, 뒤만 124 mm 짧음 / Mazda3 2,725 mm 같음, 200 mm 짧음) [hatchback.md 1절][1]. → 우리 세단에서 **B필러 앞(엔진룸·앞문·바퀴 2.75)을 그대로** 두고 뒤만 해치로 자르면 3D 일이 반 이하. 단, 우리 세단은 중형(Camry급)이라 실제 소형 해치보다 약 4% 큼 — 캐주얼 그림체에선 거의 안 보임(추정). 길이는 17.0 − (뒤 오버행 3.6 → 2.8) = **약 16.2**.

---

## 2. 해치 (트렁크 뚜껑 대신) — `Body/Liftgate`

| 항목 | 내용 | 근거 |
|---|---|---|
| 무엇 | **뒷유리까지 통째로** 지붕 뒤 끝 경첩으로 위로 열리는 문 | [hatchback.md 3절] |
| 경첩 | **2개**, 지붕 뒤 끝(뒷유리 위). Civic 11세대는 경첩을 **아래·바깥쪽으로 옮김**, Corolla 부품도 좌·우 2개 | [10][11][12] |
| 재질 | Civic = 가벼운 **수지(플라스틱) 해치** | [10] |
| 가스 스트럿 | **2개**(좌·우 부품 번호 따로: Civic 74870/74820-T47, Corolla 68960/68950-0WE20), Mazda3 "짝으로 교체"(검색 요약), GTI 세트 | [13][12][14] |
| 스트럿 양끝 자리 | (확인 못 함 — 글 출처 없음) | 아래 게임 제안 |
| 걸쇠 | 해치 아래 가운데 걸쇠 + 차체 뒤판의 고리(스트라이커) — 일반 구조(이 4대 글 확인 못 함) | — |
| 브레이크등(3번째) | 해치 위 끝(스포일러 안) — Corolla 사진, Civic은 램프·보조 브레이크등이 해치 폭 거의 전부 | 사진 직접 [P3], [10] |
| 뒤 램프 | **차체 쪽 + 해치 쪽으로 나뉨**(해치를 열면 안쪽 반이 같이 올라감) — Civic·Corolla 사진 | 사진 직접 [P1][P3] |
| 번호판 | Civic = **해치 위**(사진) · Corolla = **뒤 범퍼**(Toyota 회보, 번호판 자리가 범퍼에 성형) · Mazda3 = 범퍼(일본판 사진) | [P1], [15], [P2] |
| 열림 각·높이 | (확인 못 함) | 아래 게임 제안 |

**게임 제안 자리 (A안 좌표, 추정)**
- 높이선: 지붕 5.8 → **해치 경첩 (0, ≈ 5.5, ≈ +4.3)** → 뒷유리가 약 35°로 내려와 아래 끝 (Y ≈ 4.2, Z ≈ +6.2) → 해치 아래 판이 거의 세로로 (Y ≈ 2.6, Z ≈ +7.2) → 뒤 범퍼(2.6 ~ 0.6, 끝 Z +7.6).
- 경첩 2개: X ≈ **±1.9**(Civic처럼 바깥쪽).
- 열기: 약 **70°** 돌려 **아래 끝 Y ≈ 7.0**(서 있는 R15 머리 위 — SUV 리프트게이트 열린 높이와 같게).
- 스트럿 2(**SUV `LiftgateStrut_L/R` 메시 그대로**, car_roster 공용 부품): 닫혔을 때 뒷유리 옆 가장자리를 따라 비스듬히 — 차체 쪽 끝 = 열린 구멍 옆 아래 (∓3.0, ≈ 4.1, ≈ +6.0), 해치 쪽 끝 = 해치 옆 위 (∓2.95, ≈ 4.9, ≈ +5.0), 길이 약 1.3. 막대 쪽은 아래로(GM 회보: 먼지가 씰에 덜 쌓임) [hatchback.md 3절].
- 번호판: 2대(Corolla·Mazda3)처럼 **뒤 범퍼**에 → 해치가 단순해짐.

---

## 3. 뒷유리 와이퍼 (해치백만의 부품)

| 항목 | 내용 | 근거 |
|---|---|---|
| 축(피벗) 자리 | **뒷유리 아래 가운데** — Civic 해치·Mazda3 해치 사진에서 팔이 유리 아래 끝을 따라 가로로 누워 있음. Corolla 사진은 흐려 확실하지 않음 | 사진 직접 [P1][P2][P3] |
| 쉬는 자리 | 유리 아래 끝을 따라 **가로로**, Civic은 차 **왼쪽(운전석) 반**으로 누움 | [P1] |
| 모터 | **해치 안쪽 판 뒤**(실내 트림 안), 해치에 볼트(일반 설명서: 볼트 3), 전선·워셔 호스가 모터에 꽂힘. 와이퍼를 떼면 유리에 구멍이 남음(Civic 키트) | [16][17] |
| 해치백 전용 부품 | Civic 모터 76700-T47-A01(5도어만), Corolla 85130-12A40, Mazda3는 해치만 뒤 와이퍼(세단 X) | [18] |
| 뒤 워셔 노즐 | Civic = 유리 **위쪽**(포럼) · 나머지 (확인 못 함) | [19] |
| 뒤 워셔액 | **앞과 같은 통 하나**를 쓰는 것으로 보임: Civic·Corolla 부품표에 워셔 모터가 하나, Mazda3는 앞 워셔가 도는 동안 뒤가 안 뿜어진다고 사용설명서에 씀(짐작) | [20] |
| 해치로 가는 전선 | 해치를 여닫을 때 접히는 전선 묶음 — 거기서 잘 끊어짐(뒤 와이퍼 고장 원인 ③) | [hatchback.md 3절·4절] |

**게임 제안**
- 부품: `RearWiper`(팔 + 날, 고치는 부품 — 날만 갈기도) · `RearWiperMotor`(해치 안 판 뒤, 고장 REAR_WIPER용).
- 자리: 축 (0, ≈ 4.3, ≈ +6.15)(뒷유리 아래 끝 바로 위), 팔 약 1.6 + 날 약 1.3(뒷날 실제 길이 확인 못 함), 쉬는 자리 = 유리 아래 끝 따라 **−X쪽**으로 가로. 모터 = 축 바로 안쪽 (0, ≈ 4.0, ≈ +6.4).
- 뒤 워셔: 앞 워셔 통 하나에서 — 워셔액 붓기 일은 세단 그대로. 노즐은 와이퍼 축 덮개에(단순화).
- **길가 일(curb_jobs) 덤**: 해치백 손님은 '뒷날 1개'도 갈 수 있음(실제로 흔한 교체 품목) — wr-design 판단.

---

## 4. 짧은 뒤 — 스페어·머플러·뒤 서스·뒤 범퍼

| 항목 | 내용 | 근거 / 게임 제안 |
|---|---|---|
| 스페어 | **짐칸 바닥 아래 우물**에 **임시 스페어**: Civic T125/80D16 · T125/85D16 [1] · Corolla SE(바닥 덮개·공구 판 들고 가운데 고정 나사 풀기, 검색 요약) [21] · Mazda3 T125/70D16(FWD)·T125/80D16(AWD), **잭은 짐칸 매트 아래**(5도어) [22] · GTI 작은 철 스페어 [4] | 게임: 뒤 차축 뒤 Z ≈ +5.1 ~ +7.3에 눕힘(지름 약 2.3), 바닥 덮개 아래 |
| 머플러 | 뒤 차축 뒤 가로 통인지 (확인 못 함). 배기 끝: GTI 범퍼 양쪽 2개 [4] · Civic 스포츠 투어링만 '듀얼 배기 끝' [10] · Corolla 범퍼의 두 구멍은 가짜, 진짜 끝은 그 아래(검색 요약) [23] · Mazda3 오른쪽 아래 1개(일본판 사진) [P2] | 게임: **세단 `Muffler` 메시 그대로**, 뒤 끝이 0.8 짧아진 만큼 앞으로 → 피벗 약 (+0.3, 0.8, **+6.7**), 스페어 우물 **아래**. 꼬리관 = 오른쪽 아래 1개 |
| 뒤 서스 | 멀티링크(3대) = **세단 `Deco_RearAxle` 그대로**(Z 약 −0.2 옮김), 뒤 스프링·쇼바 따로 선 모양도 세단 그대로(이 4대의 스프링·쇼바 분리 여부는 확인 못 함) | [1][2][4] |
| 뒤 범퍼 볼트 | 이 4대의 공장 매뉴얼은 못 찾음. 포럼·키트 설명은 모두 **같은 방식**: 바퀴집 안쪽 나사 약 **3개씩**, 범퍼 아래 클립·나사 여러 개, **뒤 램프 아래·해치 입구 쪽 위 고정**(램프·해치 씰을 먼저) — Civic 10세대 해치·Civic 세단·Corolla·Mazda3·VW 계열 | [24] (포럼·키트, 검색 요약 섞임) |
| 게임 뒤 범퍼 | **세단 4볼트(바퀴집 옆 2 + 아래 2) 그대로** OK. 진짜 같게 하려면 **위 2개는 해치를 열어야** 보이게(앞 범퍼의 '보닛 열고 위 볼트'와 같은 틀) — 선택 | 제안 |

---

## 5. 고치는 부품 — 세단과 같은가 (게임 부품별)

| 게임 부품 | 해치백 |
|---|---|
| `Hood` · `Bumper_F` · `Battery` · `Radiator` | **세단과 같음**(자리만 엔진룸 규칙 +Z 0.2) |
| `Wheel` ×4 · `BrakePads` ×4 | **같음**(너트 5, 뒤 디스크). 타이어 2.64(A안) 또는 세단 2.75(B안) |
| `Muffler` | 같은 메시, 자리만 앞으로(§4) |
| `Bumper_R` | 더 작음(뒤가 짧음), 볼트 방식 같음 — 위 볼트를 해치 열기 뒤로 할지 선택 |
| `Trunk` → **`Liftgate`** | 해치(뒷유리 포함), 경첩 2 |
| **새 부품** | `LiftgateStrut_L/R`(SUV와 공용) · `RearWiper` · `RearWiperMotor` |
| 고장(car_roster §2-4) | LIFTGATE_STRUT(스트럿 2개 같이) · REAR_WIPER(퓨즈 → 12 V → 모터 소리 → 축 윤활, 원인 하나만) |

---

## 6. 출처
1. Honda News — 2022 Civic Hatchback Specifications & Features(뒤 멀티링크, 뒤 솔리드 디스크 10.2 in, 임시 스페어 T125/80D16·T125/85D16) — https://hondanews.com/en-US/honda-automobiles/releases/release-cb177600e922c8a5fcfa01b9b80149e2-2022-honda-civic-hatchback-specifications-features
2. Cars.com — 2019 Toyota Corolla Hatchback SE specs(멀티링크, 뒤 디스크 11 in, 임시 스페어) — https://www.cars.com/research/toyota-corolla_hatchback-2019/specs/400030
3. Cars.com — 2019 Mazda3 specs(토션빔, 뒤 디스크) https://www.cars.com/research/mazda-mazda3-2019/specs/ · Mazda3 — Wikipedia https://en.wikipedia.org/wiki/Mazda3
4. Cars.com — 2022 VW Golf GTI specs(멀티링크, 뒤 디스크 12 in, 작은 철 스페어) https://www.cars.com/research/volkswagen-golf_gti-2022/specs/ · Golf Mk8 — Wikipedia(범퍼 양쪽 배기) https://en.wikipedia.org/wiki/Volkswagen_Golf_Mk8
5. (검색 요약) Civic 11세대 5×114.3 https://www.fitmentindustries.com/blogs/1800/eleventh-generation-honda-civic-fitment-guide · (검색 요약) Honda 사용설명서 너트 108 N·m(CVT)/127 N·m(수동) https://techinfo.honda.com/rjanisis/pubs/OM/AH/AT402525IOM/enu/details/131271047-15363.html · GTI 5×112 https://wheel-sizes.com/bolt-pattern/volkswagen/golf-gti/2022/
6. Corolla 너트 103 N·m(2023 사용설명서 인용) https://en.wikipedia.org/wiki/Lug_nut · 규격 엇갈림: 5×114.3 https://flipcars.ca/toyota-corolla-wheel-bolt-pattern-by-year-canada/ / 5×100 https://www.carsandcollectibles.com/bolt-patterns/vehicles/toyota-corolla.html
7. Mazda Canada — 2019 Mazda3 사용설명서(임시 스페어 크기·너트 108~147 N·m) — https://www.mazda.ca/en/digital-owners-manual/2019/mazda3/contents/10020109.html
8. Mazda Canada — 2019 Mazda3 사용설명서 잭 자리(세단·해치 한 방법, 차체 아래 레일 앞·뒤) — https://www.mazda.ca/en/digital-owners-manual/2019/mazda3/contents/08020301.html
9. YOUCANIC — 2016 Mazda3(앞 세대) 배터리 운전석 쪽 — https://www.youcanic.com/2016-mazda-3-car-battery-replacement/
10. Honda News — 2022 Civic Hatchback Press Kit(수지 해치, 경첩 아래·옆으로 옮김, 램프·보조 브레이크등 해치 폭 거의 전부, 스포츠 투어링 듀얼 배기 끝) — https://hondanews.com/en-US/honda-automobiles/releases/release-20c92b0d934f0bc63982bd3eee0149e9-2022-honda-civic-hatchback-press-kit
11. Cars.com — How the 2022 Civic Hatchback differs from the sedan(경첩이 뒷유리 위, 바깥으로) — https://www.cars.com/articles/how-the-2022-honda-civic-hatchback-differs-from-the-sedan-2021-hatchback-437433/
12. Toyota 부품 — Corolla 리프트게이트 경첩 2(68820-12030 / 68810-12050) https://www.toyotapartsdeal.com/oem-2022-toyota-corolla-liftgate_hinge.html · 스트럿 2(68960/68950-0WE20) https://www.toyotapartsdeal.com/oem-2022-toyota-corolla-liftgate_lift_support.html
13. Honda 부품 — 2022 Civic 테일게이트 리프트 서포트 좌·우(74870-T47-305 / 74820-T47-305) — https://www.hondapartsnow.com/oem-2022-honda-civic-tailgate_lift_support.html
14. (검색 요약) Mazda3 가스 스트럿 짝 교체 https://www.repco.co.nz/parts-finder/2019-mazda-3/gas-struts · (검색 요약) GTI 스트럿 세트 5H6827550D https://hamcarparts.com/en/part/volkswagen/golf/set+of+tailgate+gas+struts/6998237
15. (검색 요약) Toyota 회보 — Corolla 번호판은 뒤 범퍼 덮개 성형 자리 — https://static.nhtsa.gov/odi/tsbs/2018/MC-10152181-9999.pdf
16. CravenSpeed — 뒤 와이퍼 떼기 설명(모터 = 해치 안쪽 판 뒤, 볼트 3, 전선·워셔 호스) — https://www.cravenspeed.com/wiper-delete-instructions/
17. PRL — Civic 뒤 와이퍼 떼기 키트(모터가 트림 뒤, 떼면 유리 구멍) https://www.hybrid-racing.com/products/prl-motorsports-rear-wiper-delete-fk8-fl5-civic-type-r · CorkSport — 2019 Mazda3(팔 + 안쪽 모터) https://corksport.com/2019-mazda-3-rear-wiper-delete.html
18. Honda 부품 — 2022 Civic 와이퍼 모터(76700-T47-A01, 5도어) https://www.hondapartsnow.com/oem-2022-honda-civic-wiper_motor.html · Toyota 부품 — Corolla(85130-12A40) https://www.toyotapartsdeal.com/oem-2019-toyota-corolla-wiper_motor.html
19. (포럼) Civic 11세대 해치 — 뒤 워셔 노즐이 유리 위쪽 — https://www.civicxi.com/forum/threads/anyone-done-a-rear-wiper-delete-on-the-11th-gen-hatch-pictures.51478/
20. Mazda3 사용설명서 — 뒤 워셔(앞 워셔 중엔 안 뿜음) https://www.mazda.ca/en/digital-owners-manual/2020/mazda3/contents/05030602.html · 엔진룸 워셔 통 1개 https://www.mazdausa.com/static/manuals/2019/mazda3/contents/07030301.html · 워셔 모터 1개: Honda https://www.hondapartsnow.com/oem-2022-honda-civic-washer_pump.html · Toyota https://www.toyotapartsdeal.com/oem-2019-toyota-corolla-washer_pump.html
21. (검색 요약) Toyota Corolla 빠른 안내서(바닥 덮개·공구 판 → 가운데 고정 나사) — https://assets.sia.toyota.com/publications/en/om-s/OM1947QRG/pdf/OM1947QRG.pdf
22. Mazda Canada — 2019 Mazda3 사용설명서(5도어 잭 = 짐칸 매트 아래) — https://www.mazda.ca/en/digital-owners-manual/2019/mazda3/contents/08020101.html
23. (검색 요약) Autoblog — Corolla 해치 범퍼 두 구멍은 가짜 — https://www.autoblog.com/2019-toyota-corolla-hatchback-exterior-110000438.html
24. 뒤 범퍼 고정(포럼·키트): Civic 10세대 해치 https://www.civicx.com/forum/threads/removing-rear-bumper.7545/ · (검색 요약) Civic 세단 https://www.revemoto.com/blogs/how-to/how-to-install-a-2016-2021-honda-civic-rear-bumper · (검색 요약) Corolla https://www.torklift.com/blog/how-to-install-the-ecohitch-on-a-2020-2026-toyota-corolla-x7514s/ · (검색 요약) Mazda3 https://www.mazda3revolution.com/threads/how-to-remove-the-rear-bumper.170369/ · (검색 요약) VW 계열 https://www.seatcupra.net/forums/resources/guide-removing-rear-bumper.50
- **사진 직접 봄 (내장 브라우저, 다운로드 X)**:
  - [P1] 2022 Honda Civic Hatchback EX-L, rear right — https://commons.wikimedia.org/wiki/File:2022_Honda_Civic_Hatchback_EX-L_in_Platinum_White_Pearl,_rear_right.jpg (뒷유리 아래 가로 와이퍼, 해치 위 번호판, 나뉜 램프)
  - [P2] Mazda3 Fastback 15S Touring rear — https://commons.wikimedia.org/wiki/File:MAZDA3_FASTBACK_15S_Touring_(6BA-BP5P)_rear.jpg · XD L Package rear https://commons.wikimedia.org/wiki/File:Mazda3_FASTBACK_XD_L_Package_2WD_(3DA-BP8P)_rear.jpg (유리 아래 가운데 와이퍼, 범퍼 번호판, 오른쪽 아래 배기 끝 — 일본판)
  - [P3] 2019 Toyota Corolla Hatchback SE rear — https://commons.wikimedia.org/wiki/File:2019_Toyota_Corolla_Hatchback_SE_rear_4.2.18.jpg (스포일러 안 브레이크등, 범퍼 번호판, 차체+해치로 나뉜 램프)
