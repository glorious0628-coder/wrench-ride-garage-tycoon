# fault_looks §5b 고증 확인 — 통 눈금·색·자리, 워셔 노즐·물줄기, 웅덩이 (wr-carbook, 2026-10-21 밤)

> 메인 부탁: "냉각수·브레이크액 통 실제 눈금·색·자리, 워셔 노즐 물줄기 모양, 웅덩이 색·크기 — 메인이 지금 이 3D를 만드는 중".
> 대상: `docs/design/fault_looks.md` v0.3 **§5b**(wr-design 파일 — 고치지 않고 다른 점만 여기 + board).
> 근거 = 캠리 XV70 공장 정비 매뉴얼·사용설명서(tocamry.com, 그림은 `diagrams/26~39`) + 실제 캠리 영상 장면(시간 링크). 좌표는 §5b와 같은 차 기준 stud.

## 한눈에 — §5b와 다른 것 (3D에 바로)
| # | 무엇 | §5b 지금 | 실제 (근거) | 3D 제안 |
|---|---|---|---|---|
| 1 | **브레이크액 통 캡 색** | 검정 | **흰색~밝은 회백색** 둥근 캡(통과 거의 같은 색) [V1][P1] | 캡 = 흰 #ECE8E2 + 위에 얕은 홈 줄. 검정 X |
| 2 | **워셔액 캡** | 파란 아이콘 (실제 색 확인 못 함) | **검은 둥근 캡**, 윗면에 **앞유리·물줄기 그림이 새겨짐**(색 없이 튀어나온 무늬) [V3 0:07] | 캡 = 검정, 아이콘은 **연한 회색 새김**(읽기 좋게 연파랑 OK — 실제는 색 없음) |
| 3 | **냉각수 캡** | (색 안 적힘) | **검은 둥근 캡**, 캡 꼭대기에 **넘침 호스가 꽂힘**, **돌리지 않고 '팍' 들어 여는 캡**(앞쪽 작은 고리에 걸림) [V2 0:27·3:58][V3 0:04] | 캡 = 검정 + 가는 검은 호스 1개. 여는 동작 = 돌리기 X, **탭 → 위로 팍**(소리도 '딸깍'보다 '퐁') |
| 4 | **냉각수 F·L 줄 높이** | F 3.30 / L 2.80 (몸통 2.55~3.55) | 그림에서 **F = 위 어깨 바로 아래**, **L = 옆면 가운데쯤**(보이는 높이의 약 55% 아래) [M1] | **F 3.40 / L 3.00** 권장(빔 2.6~넘침 3.5는 그대로). 줄은 **짧은 가로 틱 + 큰 글자 'F'·'L'**, 실제는 플라스틱에 **같은 색으로 도드라짐** → 게임은 읽기 위해 진한 회색 |
| 5 | **냉각수 분홍** | 액 #CCB1C2 | 실제 영상에서 흰 통 너머로 **또렷한 장밋빛 분홍** [V4 0:26] — #CCB1C2는 회색에 가까워 '분홍'으로 안 읽힘 | 액 = **#E59AB8** 쯤(웅덩이 #E7A9C4와 한 가족) |
| 6 | **워셔 노즐 자리** | 보닛, 경첩에서 앞으로 0.45 (Z −4.3) | 보닛에 붙는 것 **맞음**(보닛 분해 순서에 노즐·워셔 호스가 있음 [M3]), 단 **보닛 뒤끝 바로 앞, 유리 코앞**(떼는 법에 "앞유리 다치지 않게" [M2], 영상에서 보닛 뒤끝 틈에 박힌 모습 [V5 0:30]) | Z **−3.95~−4.0**(뒤끝에서 0.1~0.15 앞), 높이는 보닛 윗면에 반쯤 묻힘. 크기 0.2×0.1×0.25 그대로, **검정** |
| 7 | **물줄기 모양** | 노즐 → 유리 가운데 포물선, '물방울 줄' | 캠리 노즐은 **넓게 퍼지는 부채꼴 안개 분무**(가는 바늘 두 줄 X) [V5 0:14]. 맞는 자리 = 앞유리 **가운데 사다리꼴**: 유리 아래끝에서 **약 30 cm 위**부터 위로, 가운데에서 아래 ±16 cm·위 ±36 cm [M2] | 노즐마다 **부채꼴 1장**(폭 약 25°), 유리에 닿는 자리 = 유리 아래끝에서 1.0~1.1 stud 위(§5b 목표 Y 4.8·Z −3.0이 대략 맞음), X는 가운데 ±0.6~1.3 안. 두 부채꼴이 가운데서 살짝 겹침 |
| 8 | **분사하면 와이퍼도 움직임** | (없음) | 레버를 당기면 **워셔 + 와이퍼 같이**, 뿜은 뒤 **와이퍼가 저절로 두어 번** 닦고, 멈춰 있으면 **잠깐 뒤 한 번 더**(물방울 방지) [M4] | 분사 시험 = 뿜음 → 와이퍼 2번 → 1초 쉬고 1번. WIPER_WORN 줄무늬가 이때 보임 → **두 일이 한 번의 시험으로 이어짐** |
| 9 | **조수석 와이퍼 길이** | 1.9 (18 in) | **20 in**(운전석 26 in) [W1][W2] | 조수석 블레이드 **2.1**(508 mm ÷ 280 × 1.15), 운전석 2.7 그대로 |
| 10 | **Service position 모양** | 유리 위로 0.4 들림 | 와이퍼가 **유리 위로 크게 돌아 올라가 비스듬히 섬**(그림에서 쉴 자리보다 약 60° 위) — 그 뒤에 손으로 팔 고리를 잡고 유리에서 들기 [M5][W2 "거의 위를 향함"] | 정비 위치 = 팔이 피벗 축으로 **약 60° 회전**(유리에 붙은 채), 그다음 '팔 들기' 탭 = 유리에서 0.4 뜸. 두 단계 |
| 11 | **에어컨 물 자리** | (0.6, −3.3) | **앞 조수석 쪽 아래**(여름·에어컨 켰을 때) [B1] | X를 **+1.2쯤**으로(방화벽 바로 뒤 조수석 발밑 아래) |
| 12 | **웅덩이 크기** | 0.6~2.0 고정값 | 실제 크기 기준 숫자는 못 찾음(확인 못 함). 정비 글들은 '**몇 방울 = 천천히 샘(지켜봄)** / **웅덩이 = 고쳐야 함**, 브레이크액은 조금이라도 바로' [B1](검색 요약 포함) | 크기 2단으로: **방울 자국**(지름 0.3~0.5, 가장자리 또렷) / **웅덩이**(지금 값). 브레이크액은 방울 단계라도 '급함' |

그대로 맞는 것: 냉각수 통 = **조수석 앞 구석**(TRQ 영상 "passenger side" [V2 0:00]) · 반투명 흰 통 · 분홍 · F/L · 식었을 때 판정 · 뜨거울 때 캡 금지 [M1] / 브레이크액 통 = **운전석 방화벽, 배터리 뒤**(영상 [V1 0:02], 사진 [P1]) · 반투명 흰 · MAX/MIN · 패드 닳으면 조금 내려감 정상 [M6] / 브레이크액 색 = 투명~연노랑 [B1] / 워셔 캡 = **조수석 앞 구석, 냉각수 통 바로 앞·옆**(V3에서 두 캡이 나란히) / 워셔 노즐 = 보닛 부품.

## 1. 냉각수 보조탱크 (자세히)
- **눈금** (사용설명서 그림, `diagrams/26`): 통 옆면에 짧은 가로 틱 + 글자 **F**(어깨 바로 아래)·**L**(옆면 가운데쯤). "식었을 때 F와 L 사이면 됨, L 위나 아래면 F까지 보충" [M1]. 글자는 인쇄가 아니라 **플라스틱 성형**(그림에 같은 선 굵기로 그려짐 — 실물도 도드라진 글자로 보임, 확인 정도 = 그림·영상 흐릿).
- **모양** (TRQ 교체 영상, `diagrams/32`): 위가 넓고 아래가 조금 좁은 **세로로 긴 상자**, 한쪽 위 모서리에 **목 + 캡**, 옆에 볼트 귀 2개(10 mm 너트 2개로 고정), **앞쪽에 전선 커넥터 1개**(무엇인지는 영상이 말하지 않음 — 확인 못 함). 캡에서 **넘침 호스**가 라디에이터 쪽으로 감.
- **캡**: 검정 둥근 캡, **돌리는 캡이 아니라 들어 여는 캡**("pop up the cap… release it from the little hook… snap the cover on" [V2 0:27·3:58]). ※ 사진 1장(`diagrams/29`)은 흰 캡처럼 보임 — 연식·조명 차이일 수 있어 영상 2개(검정)를 따름.
- **색**: 통 = 우윳빛 반투명 흰, 액 = 장밋빛 분홍(Toyota Super Long Life Coolant, 미국 50:50 [M1]) — 영상 `diagrams/33`.
- 게임 연결: '식었을 때만' 규칙 그대로. 캡 여는 동작을 **'팍' 들기**로 하면 워셔 캡(돌림)·브레이크 캡(돌림)과 손맛이 달라 세 통이 헷갈리지 않음.

## 2. 브레이크액 통
- 자리: **운전석 쪽 방화벽, 배터리 바로 뒤**(영상 첫 장면 `diagrams/34` 앞 화면, 엔진룸 사진 `diagrams/23` 오른쪽 위 흰 통).
- 모양 (사용설명서 그림 `diagrams/27` 위): 둥근 모서리 상자 + 위에 **둥근 목**, 캡에 홈 줄. **MAX = 옆면 위쪽 가운데**, **MIN = 아래 이음매 바로 위**. 영상에서 액은 흰 통 안에 **살짝 진한 띠**로만 보임(투명~연노랑이라 잘 안 보임) → 게임은 액 윗면에 **얇은 진한 선**을 그려 높이가 읽히게.
- 캡 = **흰색**(영상 `diagrams/34`, 사진 `diagrams/23`). §5b '검정'은 다른 차 기억으로 보임.
- 붓기: 사용설명서 = **새로 딴** DOT 3 / SAE J1703, **깨끗한 깔때기** [M6]. 액은 공기 중 습기를 먹어 제동력↓ — '헌 액 = 갈색' 2단은 그대로 OK(02 파일 [27]).

## 3. 워셔: 캡·노즐·물줄기
- **캡**: 검은 둥근 캡 + **윗면에 워셔 그림 새김** [V3 0:07 `diagrams/37`], 하얀 주입구 목 위. 자리 = 조수석 앞 구석, 냉각수 통 앞 [V3 0:04 `diagrams/38`]. 통 몸통은 범퍼 뒤(앞 바퀴집 덮개를 떼야 펌프가 보임 — 정비 매뉴얼 Washer Motor: 앞바퀴 RH → 바퀴집 패드 나사 3 → 펜더 라이너 나사 6 [M7]).
- **노즐**: **보닛 부품**. 보닛 분해 순서 = 방열판(클립 9) → **노즐** → **워셔 호스(클램프 5 + 그로밋)** [M3]. 그림 `diagrams/28`: 호스가 경첩 쪽 그로밋으로 들어와 보닛 뒤끝을 따라 가다 **T로 갈라져 노즐 2개**. 노즐은 **클립 2개로 끼움, 다시 못 씀**, 떼다 **앞유리 다치지 않게** [M2] → 유리 코앞. 영상에서 보닛 뒤끝 틈에 박힌 **검은 네모 노즐** [V5 0:30 `diagrams/36`].
- **각도**: 노즐은 돌려 맞추는 게 아니라 **각도가 다른 부품(−2°·0°·+2°)으로 바꿔 끼움** [M2 `diagrams/30·31`]. → 나중 변주 "물이 유리 위로 넘어감" = 노즐 각도 부품 바꾸기(작은 일 후보).
- **물줄기**: 실제 캠리 영상 = **넓은 안개 부채꼴**이 유리 아래에서 솟음 [V5 0:14 `diagrams/35`]. 이 영상은 **운전석 쪽 노즐이 막혀 조수석만 뿜는** 장면 → 핀으로 뚫어 고침(영상 제목 "Clean … washer nozzle") = **새 고장 변주 후보 'WASHER_NOZZLE_CLOGGED'**(한쪽만 뿜음 → 핀 콕콕 → 양쪽). 손님 말: "Only one side sprays!"
- **맞는 자리** (정비 매뉴얼 점검 기준 `diagrams/31`): 가운데 사다리꼴 — 아래 변 = 유리 아래끝에서 **297.5 mm 위**, 가운데에서 **±161.7 mm**, 위 변 = **±35.8 cm**, 위 한계는 유리 위쪽 근처 [M2].

## 4. 와이퍼
- 길이 **운전석 26 in · 조수석 20 in**(OEM) [W2], 영국 판매처도 같음 [W1].
- 쉴 때 = **보닛 밑으로 숨음**, 숨은 채로 들면 보닛에 긁힘(사용설명서 경고) [M5].
- 정비 위치: 시동 끄고 약 45초 안에 레버 2초 → 와이퍼가 **유리 위로 돌아 올라옴**(그림 `diagrams/39`) → 팔 고리 잡고 들기. 내릴 땐 시동 켜고 레버 한 번 → 끄면 숨은 자리로 [M5].

## 5. 바닥 웅덩이
- 자리 근거(B1): 앞 가운데 = 엔진오일·냉각수·파워스티어링 / **앞 조수석 쪽 = 에어컨 물 또는 냉각수 통** / 실내 가운데 아래 = 변속기 / **바퀴 근처 = 브레이크액(캘리퍼)**. 판지(또는 흰 종이)를 밤새 깔아 보는 법.
- 크기: 숫자 기준은 못 찾음. 그래서 **게임 판단**으로 2단(방울 자국 / 웅덩이) — 근거는 '몇 방울은 지켜봄, 고이면 고침, 브레이크액은 바로' [B1].
- 색은 §5b 표 그대로(브레이크액 투명~연노랑 [B1]).

## 출처
- M1 Toyota Camry XV70 Owner's Manual — Engine coolant (F/L 그림) — https://www.tocamry.com/engine_coolant-1986.html
- M2 Toyota Camry XV70 Repair Manual — Washer Nozzle (점검 사다리꼴 A·B·C, 클립 2, 유리 주의, 각도 부품 85381-30230/30220/30240) — https://www.tocamry.com/washer_nozzle-4509.html
- M3 Toyota Camry XV70 Repair Manual — Hood Components / Disassembly (워셔 호스·노즐이 보닛에) — https://www.tocamry.com/components-4139.html · https://www.tocamry.com/disassembly-4141.html
- M4 Toyota Camry XV70 Owner's Manual — Windshield wipers and washer ("Wipers will automatically operate a couple of times after the washer squirts") — https://www.tocamry.com/windshield_wipers_and_washer-1912.html
- M5 Toyota Camry XV70 Owner's Manual — Changing the wiper rest position / Lifting the wipers — https://www.tocamry.com/changing_the_windshield_wiper_rest_position_lifting_the_windshield_wipers-1913.html
- M6 Toyota Camry XV70 Owner's Manual — Brake fluid (MAX/MIN 그림, DOT 3, 깔때기) — https://www.tocamry.com/brake_fluid-1987.html
- M7 Toyota Camry XV70 Repair Manual — Washer Motor (펌프 = 앞 조수석 바퀴집 안쪽) — https://www.tocamry.com/washer_motor-4508.html
- V1 Paul79UF — 2018-2022 Toyota Camry How To Check Brake Fluid Reservoir (0:33) — https://www.youtube.com/watch?v=wIad-LfDSIY&t=2s
- V2 TRQ — How to Replace Coolant Reservoir 2018-2024 Toyota Camry 2.5L (자막 전부) — https://www.youtube.com/watch?v=FVEJF0VR0js&t=27s
- V3 Paul79UF — Toyota Camry How To Fill Windshield Washer Fluid 2018-2023 — https://www.youtube.com/watch?v=0lO35YxHGqY&t=7s
- V4 Paul79UF — 2018-2022 Toyota Camry How To Check Coolant Level In Reservoir — https://www.youtube.com/watch?v=ngrmGoV7Llw&t=26s
- V5 Camry USA — Clean windshield wiper washer nozzle on Toyota Camry 2018 — https://www.youtube.com/watch?v=XYNzLA2Jxhk&t=14s
- P1 2018 Camry 2.5 엔진룸 사진 (`diagrams/23`, 출처는 diagrams/index.md)
- W1 windscreenwipers.co.uk — Toyota Camry 2017 onwards 26"/20" (검색 요약) — https://www.windscreenwipers.co.uk/collections/toyota-camry-2017-to-2025-windscreen-wiper-blades
- W2 Paul's Travel Pictures — 2018-2022 Camry Wiper Blades Replacement Guide (OEM 26"/20", service position) — https://www.paulstravelpictures.com/2018-2022-Toyota-Camry-Windshield-Wiper-Blades-Replacement-Guide/index.html
- B1 Bumper.ca — Identifying Car Fluid Leaks (자리·판지 시험·브레이크액 색) — https://www.bumper.ca/car-advice/ownership/identifying-car-fluid-leaks/
