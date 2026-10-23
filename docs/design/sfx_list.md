# 효과음 목록 v0.1 (wr-sound, 2026-10-21)

> 만드는 곳: ElevenLabs Sound Effects(사용자 크롬, 사용자 계정). **유료 요금제가 된 뒤에만 만들어요**(무료로 만든 소리는 나중에 결제해도 상업적으로 못 씀 — §0).
> 검수 = **사용자 귀**(Claude·GPT는 소리를 못 들음). 업로드 = 메인(비공개). 연결 = wr-dev(`Shared/Sounds.luau` + `SoundPlayer`).
> Pizza Doggy 음향(`art/_bought/pizzadoggy_audio/`)은 이 일과 완전히 따로 — AI에 넣지도, 참고하지도 않아요.

## 0. 라이선스 (10-21 확인)

| 요금제 | 값 | 효과음 상업적 사용 | 효과음 횟수(200 크레딧/회) | 메모 |
|---|---|---|---|---|
| Free(지금 사용자 계정) | $0 | **X — 개인 용도만** | 월 50회 | 무료 때 만든 건 결제 뒤에도 상업 X, 출처 표시 필요 |
| **Starter** | 첫 달 $1, 그다음 월 $6 | **O(상업 라이선스)** | 월 30k 크레딧 ≈ 150회 | v0.1 전부(약 100회)에 충분 |
| Creator | 첫 달 $11, 그다음 월 $22 | O | 월 121k ≈ 600회 | 192 kbps, 크레딧 추가 구매 가능 |

- 근거: ElevenLabs 구독 페이지(사용자 크롬, 10-21: Free 칸 '음성과 뮤직에 대한 상업적 라이선스' ✗, 효과음 비교 '상업적 사용 = 개인 용도로만 사용 가능'·'취소해도 권한 유지 ✗'), [도움말: 만든 것을 공개해도 되나요](https://elevenlabs.io/docs/help-center/legal/can-i-publish-the-content-i-generate-on-the-platform/llms.txt)("free plan does not include a commercial license", "Content generated during a paid subscription can be used commercially, and indefinitely"), [이용약관](https://elevenlabs.io/terms-of-use) 1(c)(i)·(ii)(무료 = 비상업, 유료 = 상업), [효과음 FAQ](https://elevenlabs.io/sound-effects/commercial)(유료는 출처 표시 X, 로열티 프리).
- 조심: **Beta 표시가 붙은 기능**으로 만든 건 상업 X(도움말). 만들 때 화면에 Beta가 있는지 확인하고 `art/sfx/prompts.md`에 적어요.
- 기록: 요금제·결제일·만든 날짜를 `art/sfx/prompts.md` 맨 위에 남겨요(나중에 증명용).

### 0-1. 무료 소리 출처 (10-21 사용자: "상업적 사용 가능한 무료 게임 효과음 있는 곳 찾아서 가지고 와봐도 돼")

| 출처 | 라이선스 | 판단 |
|---|---|---|
| **Kenney** (kenney.nl) | CC0 — 상업 OK, 출처 표시 X | **사용 중**: 오디오 묶음 7개(목소리 제외) → `art/sfx/cc0/kenney/` + License.txt, 후보 대응표 `art/sfx/cc0/sources.md`. UI·충격음·종·전자음·짧은 음악에 좋고 차 소리는 없음 |
| Pixabay 효과음 | Pixabay Content License — 상업 OK, 출처 X, 단독 재배포 X | 개인 업로드라 권리 확인 책임이 우리 → 필요할 때만, 하나씩 확인 |
| Sonniss GDC 묶음 | 로열티 프리, 출처 X, AI 학습 X | 품질 좋지만 7~30 GB → 필요한 회사 묶음 하나만 받을 때 다시 판단 |
| Roblox 상점 Pro Sound Effects | Roblox 안에서만 | 긴 녹음·브랜드 제목·잘라 올리기 불가 → 예비 |
| 개인이 올린 Roblox 상점 소리 | 불확실 | 쓰지 않음 |

## 1. 소리 규칙 (H&H 소리 설계 방법에서 가져온 것)

- **자주 나는 소리일수록 짧고 조용하게**: 볼트 소리는 0.3초 안(렌치 간격 0.32초), 임팩트는 0.09초 간격이라 겹쳐도 시끄럽지 않게.
- **폰 스피커**: 150 Hz 아래(깊은 '우웅')에 기대지 않기. 엔진도 '부릉'의 가운데 소리(배기 '부르르', 시동 모터 '위잉')가 들려야 해요. 프롬프트에 *deep rumble* 쓰지 않기.
- **한 소리 = 뜻 하나**: 고장 소리(나쁨)는 거슬리되 아프지 않게, 고친 뒤 소리(좋음)는 시원하게. 끽 소리는 아이 귀에 아프지 않게 3~5 kHz 쪽(실제 2~15 kHz 중 낮은 쪽).
- **목소리 X**(사람 말·환호·웃음 전부), **음악 X**(효과음에 멜로디가 섞이면 버림), 실제 브랜드 소리 흉내 X.
- 음량(ffmpeg 다듬기 기준): 짧은 효과음 **피크 −1 dBTP**, 크게 들리는 정도는 Roblox `Volume`으로 맞춤(아래 표의 '크기'). 배경(loop) **−28 LUFS·피크 −6 dBTP**. 잔향 짧게(0.3초 안), 앞뒤 무음 자름. 결과는 `art/sfx/<분류>/<이름>.ogg` + 길이·LUFS 표(`art/sfx/levels.md`).
- 크기 등급(Roblox Volume 제안): 조용 0.3 · 보통 0.45 · 큰 순간 0.6~0.7 · 배경 0.15~0.25.

## 2. 우선순위

- **P0 = 사람 시험 전에 꼭**: 첫 두 손님(Rosa BAT_DEAD, Tyler PAD_WORN) 증상 + 고친 뒤 소리 + 그 두 일에서 손으로 하는 동작(보닛·볼트·부품·불꽃·리프트) + 정산.
- **P1 = 시험 전에 있으면 좋음**: 차 도착·스캐너·영수증(알파 시험 범위)·레벨업·다른 고장 증상 몇 개.
- **P2 = 나중**: 동네 배경, 나머지 고장 증상.

## 3. 목록

열: 키(코드 이름, ★ = `Sounds.luau`에 이미 있는 키) · 쓰는 자리 · 길이(초) · loop · 크기 · ElevenLabs 프롬프트(영어) · 설정(Duration / Prompt influence) · 후보 수.
설정: Duration은 ElevenLabs에 넣는 값(짧은 건 길게 만들고 잘라 씀), influence 높을수록 프롬프트대로(기본 0.3).

### 3-1. P0 — 첫 두 손님 + 손맛 + 정산 (16개)

| # | 키 | 쓰는 자리 | 길이 | loop | 크기 | 프롬프트 | 설정 | 후보 |
|---|---|---|---|---|---|---|---|---|
| 1 | engineFail ★ | BAT_DEAD 시동 시도(Diagnosis.startClue), 전후 비교 '전' | 1.5~2.0 | X | 큰 0.6 | `Close-up of a car with a weak battery: turning the key makes a rapid chattering click-click-click-click from the starter solenoid, the engine does not crank or start, small sedan interior, dry, no music` | 2.0 / 0.6 | 3 |
| 2 | engineStart ★ | 고친 뒤 시동(증명 순간·carStart·전후 '후'), 정상 차 시동 | 2.5~3.0 | X | 큰 0.6 | `A small four-cylinder sedan engine starting: short starter whir, then the engine catches cleanly and settles into a smooth, happy idle, recorded close in a garage, mid-range exhaust burble, no deep rumble, no music` | 3.0 / 0.5 | 3 |
| 3 | brakeSqueal ★ | PAD_WORN 브레이크 밟기(앞 왼쪽), 전후 '전' | 1.2~1.6 | X | 보통 0.5 | `A car slowly rolling to a stop while the brakes make a thin high-pitched metallic squeal from a worn brake pad wear indicator, close to the wheel, short, no music` | 1.5 / 0.6 | 3 |
| 4 | brakeQuiet ★ | 고친 뒤 브레이크(증명 순간·전후 '후') | 1.2~1.5 | X | 조용 0.35 | `A car rolling slowly on smooth concrete and coming to a soft, quiet stop with no squeal, gentle tire roll and a light suspension settle, close, clean, no music` | 1.5 / 0.5 | 3 |
| 5 | wrench ★ | 손 렌치로 볼트 **풀기** 1번(bolt, loosen) | 0.2~0.3 | X | 조용 0.3 | `Single hand wrench breaking a car bolt loose: a short metal creak and a crisp click as the bolt turns, close-up, dry workshop, no music` | 1.0 / 0.5 | 3 |
| 6 | wrenchTighten | 손 렌치로 볼트 **조이기** 1번(bolt, tighten) — 풀기보다 '꽉' 닫히는 느낌 | 0.2~0.3 | X | 조용 0.3 | `Single hand wrench tightening a car bolt until it seats: a short metal ratcheting turn ending in a firm snug click, close-up, dry workshop, no music` | 1.0 / 0.5 | 3 |
| 7 | impact ★ | 임팩트 렌치 볼트 1개(0.09초 간격 쓸기 — 소리는 0.2초마다 한 번만 내기 권장) | 0.15~0.25 | X | 보통 0.45 | `Pneumatic impact wrench, one short burst brrrt on a lug nut, close-up, dry tire shop, no air hiss tail, no music` | 1.0 / 0.6 | 3 |
| 8 | ratchet | 라쳇 렌치(Lv3, 0.22초 쓸기) — 사람 시험엔 없어도 됨, 같이 만들어 둠 | 0.2~0.3 | X | 조용 0.3 | `Socket ratchet wrench turning a bolt: three quick crisp ratchet clicks, close-up, dry, no music` | 1.0 / 0.5 | 2 |
| 9 | clank ★ | 마지막 볼트가 빠지며 부품이 '툭' 떨어져 나옴(DetachPop) | 0.3~0.5 | X | 보통 0.45 | `A metal car part coming loose and dropping a few centimeters onto its mount with a solid clunk, close-up, garage, no music` | 1.0 / 0.5 | 3 |
| 10 | install | 부품이 제자리에 '딸깍' 끼워짐(install, 자석처럼 붙을 때) — 손맛 핵심, 기분 좋게 | 0.3~0.5 | X | 보통 0.5 | `A car part snapping firmly into place: a satisfying solid metal clack-thunk, very clean and tight, close-up, no ring, no music` | 1.0 / 0.6 | 3 |
| 11 | partDrop | 든 부품을 바닥·작업대에 내려놓기(배터리·패드 등) | 0.3~0.5 | X | 조용 0.35 | `Setting a heavy car battery down on a concrete garage floor: a short plastic and metal thud, close-up, no music` | 1.0 / 0.5 | 2 |
| 12 | spark ★ | 배터리 단자 순서 틀림(+ 먼저 풀다 차체 닿음) 작은 불꽃 | 0.3~0.5 | X | 보통 0.45 | `A small electrical spark zap and crackle when a wrench touches a car battery terminal, short and sharp, close-up, no explosion, no music` | 1.0 / 0.5 | 3 |
| 13 | hoodOpen | 보닛 열기(걸쇠 '탁' + 들어 올림) — 첫 일 3단계 | 0.8~1.2 | X | 보통 0.45 | `Opening a car hood: the hood latch pops with a click, then the metal hood is lifted with a light creak, close-up in a garage, no music` | 1.5 / 0.5 | 3 |
| 14 | hoodClose | 보닛 닫기(쾅 — 너무 크지 않게) | 0.5~0.8 | X | 보통 0.5 | `Closing a car hood: a short drop and a solid metal slam as the latch catches, close-up in a garage, no music` | 1.0 / 0.5 | 3 |
| 15 | liftMotor | 2주 리프트 오르내림 동안(유압 펌프 '위이잉') — **loop** | 2.0~4.0 | **O** | 보통 0.4 | `Two-post car lift hydraulic pump motor running steadily, electric hum with hydraulic whine, constant level, garage, no start or stop, seamless loop, no music` | 4.0 / 0.5, **Loop 켬** | 2 |
| 16 | payout | 정산 카드(돈 굴러 오름) — 지금 `reward`(Roblox UI) 자리 | 0.8~1.2 | X | 큰 0.6 | `Old mechanical cash register: a drawer bell ding and a short coin jingle, bright and cheerful, close-up, no music, no voice` | 1.5 / 0.5 | 3 |

- 리프트 멈춤 '철컥'은 P1 #17. 손님 대사·환호는 만들지 않아요(글자 + 다른 소리).

### 3-2. P1 — 시험 전에 있으면 좋음 (13개)

| # | 키 | 쓰는 자리 | 길이 | loop | 크기 | 프롬프트 | 설정 | 후보 |
|---|---|---|---|---|---|---|---|---|
| 17 | liftLock | 리프트가 층(Under 등)에 멈출 때 안전 걸쇠 '철컥' | 0.3~0.6 | X | 보통 0.45 | `Car lift safety lock engaging: a heavy metal clack as the lift stops at its height, close-up, garage, no music` | 1.0 / 0.5 | 2 |
| 18 | carArrive | 손님 차가 Bay로 들어와 섬(첫 일: '덜컹거리며') | 3.0~4.0 | X | 보통 0.45 | `An old small sedan slowly driving into a garage bay and stopping, low speed engine idle, tires rolling on concrete, a soft brake stop, the engine keeps idling, no music` | 4.0 / 0.4 | 2 |
| 19 | cheer ★ | 손님이 고쳐진 차로 떠날 때 **'빵빵' 고맙다는 경적 두 번**(사람 목소리 대신 — 키 이름 바꾸기는 wr-dev 결정) | 0.6~1.0 | X | 보통 0.45 | `A small friendly car horn tooting twice, beep beep, cheerful thank-you honk, from a few meters away, no music` | 1.0 / 0.5 | 3 |
| 20 | scannerBeep | 스캐너(테스터) 값이 뜸(12.0 V 등) | 0.2~0.4 | X | 조용 0.35 | `A handheld electronic car diagnostic tester giving two short confirming beeps, small device, clean, no music` | 0.5 / 0.6 | 2 |
| 21 | deskBell | 손님이 접수대에 옴(작은 종 '띵') | 0.5~1.0 | X | 보통 0.4 | `A single tap on a service desk bell, clear ding, short decay, close-up, no music` | 1.0 / 0.6 | 2 |
| 22 | levelUp | 정비소 레벨 업 카드(지금 `reward`) — 정비소다운 '팡' | 1.0~1.5 | X | 큰 0.65 | `Celebratory garage level-up sound: a quick air-wrench brrrt followed by a bright metallic bell ring and a short sparkle, no melody, no voice, no music` | 1.5 / 0.5 | 3 |
| 23 | receiptPrint | 오늘의 영수증 인쇄(접수대 프린터 '지지직') | 1.0~1.5 | X | 보통 0.4 | `A small thermal receipt printer printing a short receipt, fast buzzing whirr and paper feed, ending with a paper tear, close-up, no music` | 2.0 / 0.6 | 2 |
| 24 | stamp | 영수증 'THANK YOU!' 도장 '쿵' | 0.3~0.5 | X | 보통 0.5 | `A rubber stamp pressed hard onto paper on a wooden counter, a single solid thump, close-up, no music` | 0.5 / 0.6 | 2 |
| 25 | wheelRoll | 뗀 바퀴가 굴러감(물리 코미디) — 굴러가는 동안 loop | 1.5~2.5 | **O** | 보통 0.4 | `A loose car tire with wheel rolling across a concrete garage floor, rubber rumble and light wobble, steady, seamless loop, no music` | 2.0 / 0.5, Loop 켬 | 2 |
| 26 | tireHiss ★ | TIRE_FLAT 바람 새는 소리(전후 '전') | 1.0~2.0 | X | 조용 0.35 | `Air slowly hissing out of a punctured car tire, steady thin hiss, close-up, no music` | 2.0 / 0.5 | 2 |
| 27 | brakeGrind | PAD_GONE 쇠 긁는 '드르륵' | 1.2~1.6 | X | 보통 0.5 | `A car slowing to a stop with harsh metal-on-metal brake grinding, rough scraping from a brake rotor, close to the wheel, no music` | 1.5 / 0.6 | 2 |
| 28 | steamHiss ★ | RAD_LEAK 시동 때 김 '쉬익'(전후 '전') | 1.5~2.0 | X | 보통 0.45 | `Steam hissing out from under a car hood from an overheated radiator, steady hot steam hiss with a few small gurgles, no music` | 2.0 / 0.5 | 2 |
| 29 | exhaustLoud ★ | MUF_HOLE 시동 때 '부아앙' 시끄러운 배기(전후 '전') | 2.0~3.0 | X | 큰 0.6 | `A small car engine starting with a broken muffler: loud raspy blatting exhaust, rattly and obnoxious like a toy race car, mid-range, no deep rumble, no music` | 3.0 / 0.5 | 2 |

### 3-3. P2 — 나중 (동네 배경·남은 증상, 9개)

| # | 키 | 쓰는 자리 | 길이 | loop | 크기 | 프롬프트 | 설정 | 후보 |
|---|---|---|---|---|---|---|---|---|
| 30 | ambGarage | 정비소 안 공기(아주 작게: 먼 라디오 X, 형광등 웅·먼 공구) | 15~20 | **O** | 배경 0.15 | `Quiet small-town auto repair garage room tone, faint fluorescent hum, occasional distant tool clinks, calm, no voices, no radio, no music, seamless loop` | 20 / 0.4, Loop 켬 | 2 |
| 31 | ambStreet | 정비소 앞 대로(먼 차 지나감) | 20~30 | **O** | 배경 0.2 | `Distant city street ambience in an old American brick town, cars passing far away, light wind, no horns, no voices, no music, seamless loop` | 30 / 0.4, Loop 켬 | 2 |
| 32 | ambBirds | 집 동네·공원 낮(새 몇 마리) | 20~30 | **O** | 배경 0.15 | `Calm daytime neighborhood park ambience with a few small songbirds chirping, light breeze in trees, no voices, no music, seamless loop` | 30 / 0.4, Loop 켬 | 2 |
| 33 | trainPass | SkyLoop 고가 전철이 지나감(움직이는 전철에 붙이는 3D 소리) | 6~8 | X | 보통 0.4 | `An elevated city train passing overhead on steel tracks, rhythmic clack-clack and metal rumble approaching and fading away, no horn, no voices, no music` | 8 / 0.4 | 2 |
| 34 | beltSqueal | 벨트 닳음 아침 시동 '끼이익' | 1.5~2.0 | X | 보통 0.5 | `A car engine starting with a loose serpentine belt making a loud rubbery squeal for a second, then fading, no music` | 2.0 / 0.5 | 2 |
| 35 | swayClunk | SWAYLINK 턱 넘을 때 '쿵' | 0.4~0.8 | X | 보통 0.45 | `A car going over a speed bump with a single loose suspension clunk underneath, short, no music` | 1.0 / 0.5 | 2 |
| 36 | rattle | 차 밑 덜그럭(MUF_SHIELD·튜토리얼 세 번째 차) | 1.5~2.0 | X | 보통 0.4 | `A loose metal heat shield rattling under an idling car, tinny buzzing rattle, close-up, no music` | 2.0 / 0.5 | 2 |
| 37 | fuelPrime | 연료 펌프 정상 '위잉' 2초(없으면 고장 단서) | 1.5~2.0 | X | 조용 0.3 | `A car fuel pump priming for two seconds when the key is turned, soft electric whine from the rear of the car, no engine, no music` | 2.0 / 0.5 | 2 |
| 38 | hammerTap | 망치로 판 툭툭(소리 찾기) | 0.3~0.5 | X | 조용 0.35 | `A small hammer tapping a thin metal heat shield twice, tink tink, close-up, no music` | 1.0 / 0.5 | 2 |

## 4. 만들 횟수 예상

P0 16개 × 약 3 = 46회, P1 13개 × 약 2 = 27회, P2 9개 × 2 = 18회 → **약 90회**(Starter 월 약 150회 안). 처음엔 **P0만** 만들어 사용자에게 들려 드리고, 고른 뒤 P1로.

## 5. 흐름

1. 사용자 결제(Starter 이상) → `prompts.md`에 요금제 기록.
2. P0 프롬프트로 후보 만들기(사용자 크롬). 화면에서 내려받기 전에 **파일 이름·개수를 채팅으로 허락**받기 → `art/sfx/raw/<키>_<a|b|c>.mp3`.
3. ffmpeg 다듬기 → `art/sfx/<분류>/<키>_<a|b|c>.ogg`(분류: fault·fix·tool·part·shop·money·town) + `art/sfx/levels.md`.
4. 사용자 듣기 목록(분류별, 경로 + 쓰는 자리) → 사용자가 고름 → `art/sfx/picks.md`.
5. 메인이 고른 것만 비공개 업로드(업로드 한도 아끼기 — 한도가 빠듯하면 짧은 소리 여러 개를 한 파일로 묶고 `Sound.PlaybackRegion`으로 나눠 쓰는 방법도 있음, wr-dev 판단) → id를 board에 → wr-dev가 `Sounds.luau`에 넣고 새 키 연결.

## 6. wr-dev에게 (새 키·연결 자리 제안 — 결정은 wr-dev)

- 새 키: wrenchTighten, ratchet, install, partDrop, hoodOpen, hoodClose, liftMotor(loop), liftLock, payout, carArrive, scannerBeep, deskBell, levelUp, receiptPrint, stamp, wheelRoll(loop), brakeGrind (+ P2).
- `bolt` 효과: loosen → `wrench`, tighten → `wrenchTighten`, tool == ImpactWrench → `impact`(0.2초에 한 번만), Ratchet → `ratchet`. 마지막 볼트로 부품이 떨어지면 `clank`. `install` 효과 → `install`. `spark` 효과 → `spark`.
- `jobDone` 카드 → `payout`(지금 `reward`), 레벨업 카드 → `levelUp`.
- loop 소리(liftMotor·wheelRoll·amb*)는 `SoundPlayer.play`가 아니라 `Looped = true` Sound를 켜고 끄는 함수가 필요해요.
- `cheer` 키는 사람 목소리 대신 '빵빵' 경적으로 만들어요 — 키 이름을 `thanksHonk`로 바꿀지 결정해 주세요.

## 7. 검사 질문 5개 (game_textbook 규칙)

1. 첫 두 손님에서 소리만 듣고도 '고장 → 고침'이 구별되나요? (engineFail ↔ engineStart, brakeSqueal ↔ brakeQuiet)
2. 볼트·부품 소리가 1분에 수십 번 나도 귀가 피곤하지 않나요? (짧고 조용, 겹치기 제한)
3. 폰 스피커로 들어도 엔진·끽 소리가 들리나요? (150 Hz 아래에 기대지 않음)
4. 사람 목소리·음악·브랜드 소리가 섞인 후보는 다 버렸나요?
5. 모든 파일이 **유료 요금제 기간에** 만들어졌다는 기록이 `prompts.md`에 있나요?
