# 영상 공부 1 — 작업 모드 첫 3가지 일 (wr-carbook, 10-21)

> 내장 브라우저로 유튜브를 보고(다운로드·로그인 X) 설명란 챕터 + 멈춘 화면으로 정리. 스크립트는 이 영상들에선 열리지 않아(버튼 없음/빈 창) **챕터·화면**으로 봤어요. 아래 문장은 내 말로 요약.
> 쓸 곳: wr-dev·wr-ui `docs/design/work_view.md`(단계 순서·손 동작·카메라·단계별 초). 매뉴얼 근거는 이미 있는 노트(01·02·03·under_car_work)와 겹치면 그쪽 출처를 같이 적었어요.

## 1. 배터리 교체 (2018~2023 캠리)

| 영상 | 채널 | 길이 | 링크 |
|---|---|---|---|
| How to Change the Battery on a 2017-2023 Toyota Camry (Dealer Tech POV) | Greasy Jac (토요타 정비사 시점) | 1:23 | https://www.youtube.com/watch?v=vJSMkqacmdY |
| How to Change a Battery in a 2018-21 Camry from David Potter at J Allen Toyota | J. Allen Automotive (딜러) | 3:03 | https://www.youtube.com/watch?v=ycfR-6P9lko |
| 2018-2024 TOYOTA CAMRY Battery Replacement | TheOGbuilds | 4:25 | https://www.youtube.com/watch?v=hWZYc5i4uDg (설명란 공구 목록만 봄) |

**단계와 시간 (Greasy Jac 챕터 그대로 = 실제 숙련자 속도)**
| 시간 | 단계 | 공구 | 링크 |
|---|---|---|---|
| 0:06~0:21 (약 15초) | 단자 풀기 — **(−) 먼저**, 그다음 + 빨간 덮개 열고 (+) | **10 mm** | https://www.youtube.com/watch?v=vJSMkqacmdY&t=6s |
| 0:21~0:35 (약 14초) | 고정쇠(hold-down) 풀기 | **12 mm** (+ 연장대 — TheOGbuilds 목록) | &t=21s |
| 0:35~0:50 (약 15초) | 새 배터리 넣고 고정쇠 조이기 | 12 mm | &t=35s |
| 0:50~1:15 (약 25초) | 단자 다시 끼우고 조이기(**+ 먼저 → − 마지막**) | 10 mm | &t=50s |
| 1:15~ | 시동 걸고 확인 | — | &t=75s |
- 정비사 실제 속도로 **약 70초**(배터리 들고 옮기는 시간 포함). 매뉴얼 순서(− 먼저 → + 덮개 걸쇠 2 → + → 고정쇠 볼트 1, 단자 5.4 N·m·고정쇠 18.5 N·m)와 같음 [01 파일 9·10].
- 손님 대수리 시간 감: TheOGbuilds 설명란은 "배터리를 받침에서 들어낼 힘"이 필요하다고 적음(무거움 → 우리 TwoHand 운반 근거).

**화면에서 본 것 (멈춘 장면)**
- J. Allen 0:20·2:00(https://www.youtube.com/watch?v=ycfR-6P9lko&t=20s, &t=120s): 카메라는 **운전석 쪽 펜더 위에서 엔진룸을 비스듬히 내려다봄**. 배터리 긴 쪽이 화면 가로(= 차 앞뒤)로 놓이고, **+ 빨간 덮개가 앞쪽 끝, −가 뒤쪽 끝**, 그 뒤에 반투명 흰 브레이크액 통 → car_spec v0.8(긴 쪽 앞뒤, + 앞 / − 뒤)과 같음.
- J. Allen 1:30(&t=90s): 손이 배터리 **아래 앞쪽 모서리** 쪽으로 내려가 고정쇠 볼트를 풂 → 바닥 턱 고정쇠(매뉴얼 그림과 같음).
- Greasy Jac 0:58(&t=58s): + 덮개를 젖히면 **볼트식 단자 클램프 + 너트**가 보이고, 굵은 + 케이블은 옆 퓨즈 박스로 이어짐.

**우리 게임에 쓰는 법**: 단계 5개 × 각 10~25초가 진짜 속도 → 게임은 전체 **60~90초** 안이 자연스러움. 카메라 = **운전석 펜더 위 45° 내려다보기**(배터리·브레이크액 통·퓨즈 박스가 한 화면). 손 클릭 순서 = − → +덮개 → + → 고정쇠(앞 아래, 연장대 표시).

## 2. 앞 브레이크 패드 교체 (2018~2023 캠리 2.5)

| 영상 | 채널 | 길이 | 링크 |
|---|---|---|---|
| Toyota Camry 2018-2023 2.5 L - Replacing (Only) Front Brake Pads | AutoTechOCD | 11:32 | https://www.youtube.com/watch?v=F139Cf119t8 |
| (참고, 안 봄) Front pads & rotors replacement 2018-2024 Toyota Camry | 603 Mechanic vids | 5:29 | https://www.youtube.com/watch?v=ocQuRgMCzM4 |
| (참고, 안 봄) 2018-2024 TOYOTA CAMRY FRONT BRAKES TUTORIAL | Gearmo Auto | 9:45 | https://www.youtube.com/watch?v=u3v3C6zT4kE |

**화면에서 본 순서 (AutoTechOCD)**
| 시간 | 본 것 | 링크 |
|---|---|---|
| 1:00 | **먼저 보닛 열고 브레이크액 통 높이 확인**(노란 경고 그림 캡이 있는 반투명 흰 통, 배터리 바로 뒤) — 피스톤을 밀면 액이 통으로 돌아와 넘칠 수 있어서 확인하는 실제 단계 | https://www.youtube.com/watch?v=F139Cf119t8&t=60s |
| 4:00 | 바퀴 뗀 상태, 손으로 볼트를 풂(카메라는 바퀴 높이, 바퀴집 바깥) | &t=240s |
| 4:50~5:30 | **캘리퍼를 떼어 손에 들고**(DIY식: 볼트 2개 다 풂), 뒤로 **등속 조인트 고무 부트**·너클이 보임, 오른쪽 뒤에 **잭 스탠드** | &t=290s, &t=330s |
| 9:20 | 새 패드를 **캘리퍼 받침(브래킷)에 끼움** — 패드는 캘리퍼가 아니라 브래킷에 앉음(매뉴얼 그림과 같음) | &t=560s |
- 매뉴얼은 '아래 볼트 1개 풀고 위로 젖힘', 이 영상(DIY)은 '2개 다 풀고 떼어 듦' → 둘 다 실제, car_spec v0.3 메모와 같음 [02 파일].

**우리 게임에 쓰는 법**: ① 패드 일 시작 전에 **"브레이크액 통 확인"** 한 클릭(보닛 쪽) — 진짜 정비사 습관이라 '아는 사람' 보너스 감. ② 카메라 = **바퀴 높이, 바퀴집 바깥에서 비스듬히**(캘리퍼·디스크·부트가 한 화면). ③ 새 패드는 **브래킷에 끼우는** 손맛(캘리퍼가 젖혀진 동안). ④ 전체 영상 11분은 설명 포함 — 숙련자 실제 작업은 이보다 짧음(정확한 초는 확인 못 함).

## 3. 잭으로 차 들고 바퀴 빼기

| 영상 | 채널 | 길이 | 링크 |
|---|---|---|---|
| How to Change a Tire (plus jacking it up) | ChrisFix | 14:21 | https://www.youtube.com/watch?v=314HE4aMG-g |
| (참고, 안 봄) How to properly jack up a car | Fast and Reliable Mobile Mechanic | 1:49 | https://www.youtube.com/watch?v=WZaNyebHRH0 |
- ChrisFix 1:10(https://www.youtube.com/watch?v=314HE4aMG-g&t=70s): 처음에 **휠 가운데 캡(허브캡)부터** 손으로 가리키며 시작 — 캡이 있는 휠은 너트 전에 캡을 뗌. 그 뒤 장면은 영상 중간 광고 때문에 못 봤어요(확인 못 함).
- 순서·안전은 매뉴얼로 이미 확정: **땅에 있을 때 너트를 먼저 살짝(한 바퀴) 풂**(사용설명서 'Slightly loosen the wheel nuts (one turn)' — https://www.tocamry.com/replacing_a_flat_tire-2012.html) → 고임목 → 잭(앞 가운데) → 스탠드(앞바퀴 뒤 문턱) → 너트 빼기 → 바퀴 굴려 빼기**, 끼울 땐 손으로 고르게 → 내리고 → **별 순서로 2~3바퀴 103 N·m** [03 파일 12, under_car_work 1].

**우리 게임에 쓰는 법**: '너트 먼저 한 바퀴 풀기(바퀴가 땅에 있을 때)' 한 단계 — 사용설명서 순서 그대로. (들고 나서 풀면 바퀴가 같이 돈다는 '이유' 설명은 출처를 못 봄 — 확인 못 함.) 끼울 땐 너트의 **원뿔 쪽이 안으로**(사용설명서).

## 다음
- 영상 스크립트를 못 읽은 게 아쉬움 → 다음 주제(차 밑·오일 교환)부터 **스크립트가 있는 영상**을 고르고, 광고가 적은 짧은 영상 위주.
