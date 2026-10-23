# 에셋 쇼핑 조사 (2026-10-22, 조사 도우미)

사용자 말: "우리 게임에 있으면 좋겠다 싶은 에셋 찾아봐, 구매 가능하면 구매할게."
**이 문서는 조사만 했어요.** 구매·다운로드·설치·로그인은 하나도 안 했고, 사는 건 사용자예요. 링크는 내가 직접 열어 본 것만 '확인'이라고 적었고, 못 연 건 '확인 못 함'이라고 따로 적었어요(맨 아래). 가격은 오늘(10-22) 본 값이고 세일로 바뀔 수 있어요(세금 별도일 수 있음).

---

## 한 줄 결론

1. **제일 돈값 하는 건 '진짜 녹음' 소리 3묶음(Sonniss 사이트, 합 $96)** 이에요. 지금 ElevenLabs 소리 중 AI가 헷갈린 것·몸통 없는 것(렌치·라쳇·임팩트·시동·보닛·문·와이퍼·영수증)을 사람이 녹음한 소리로 바꿀 수 있어요. 파일 이름·트랙리스트를 내가 직접 읽어서 우리 목록과 맞는지 확인했어요.
2. **공짜로도 꽤 있어요**: Sonniss 무료 GDC 2026 묶음(7.47 GB), Roblox 상점의 ProSoundEffects 무료 녹음(보닛·문·트렁크·시동 등 실제 자동차 녹음 수백 개), Freesound CC0.
3. **애니메이션은 '사는 팩'이 없어요.** 로블록스 상점에 애니메이션 자산 종류가 아예 없고, 정비 자세(쪼그림·누움·렌치 돌림) 팩도 못 찾았어요. 만드는 길이 답이고, 도구는 **Moon Animator 2($19.99 세일)** + 무료 도구(영상 → 애니메이션, Blender 연결)예요.
4. **소품 3D는 살 게 없어요.** 상점의 정비소 소품 팩 2개는 만든 사람이 'AI로 만들었다'고 적어 놨고(우리 규칙 위반), 나머지는 사실적인 그림체거나 삼각형이 너무 많아요. 우리가 Blender·파트로 만드는 쪽이 낫고, 이미 산 번들(카툰 시티)로 거리 소품은 덮여요.
5. **UI**는 새로 살 큰 건 없고(우리 kit_B가 있음), 글꼴은 **로블록스 안 무료 글꼴**(Highway Gothic = 미국 도로 표지판 글꼴, Special Elite = 영수증 타자기 글꼴)이 우리 분위기에 딱이에요. 아이콘은 이미 쓰는 gvesster 무료 팩의 유료 큰 팩($16.99)이 후보예요.
6. **플러그인**은 우리가 코드로 짓기 때문에 거의 필요 없어요. 애니메이션용 Moon Animator 2 하나만 후보예요.

---

## TOP 10

(순서 = 추천 순서. ★ = 사용자가 돈을 내는 것, ☆ = 공짜)

| # | 이름 | 링크 | 값 | 무엇에 쓰나 | 왜 좋은가 | 라이선스 OK 근거 | 주의 |
|---|---|---|---|---|---|---|---|
| 1 ★ | **Sonniss "Car Interiors – 96kHz"** (Patch Hill Audio) 106개 · 980 MB | https://sonniss.com/sound-effects/car-interiors-96khz-24-bit-stereo/ | **$35** | 차 문 열기·닫기·잠금, 브레이크 페달, 대시 스위치, **방향지시등 '딱딱' 루프 5개**(우리 앞 주황 깜박이), 와이퍼·경적·안전벨트·비상 브레이크·시동(설명에 적힘) | 차 안에서 진짜로 녹음. 트랙리스트 PDF에서 DoorOpen·DoorClose·DoorLock·BrakePedal·DashSwitch·Directional(루프)·CarWash 파일 이름을 직접 확인. 지금 우리 AI 소리(와이퍼·경적 등)와 자리가 겹쳐요 | Sonniss 라이선스 2.0 (https://sonniss.com/license/): 게임에 쓰기 OK, 출처 표시 X, 평생·무제한 프로젝트, 완성된 게임 안에 넣어 파는 것 OK | 트랙리스트 PDF를 일부만 읽음(106개 중 28개 이름 — 나머지는 가게 설명 글에 의존, 확인 못 함). **AI에 넣기 금지**(아래 '지킬 것') |
| 2 ★ | **Sonniss "Tools"** (Airborne Sound) 250개 · 5.9 GB · 96 kHz | https://sonniss.com/sound-effects/tools/ | **$36** | **공압 임팩트 렌치**(켜고·회전 올리고·볼트 조임), **공압 라쳇**, 망치, 드릴, **에어 컴프레서 켜짐·돌아감·꺼짐·공기 빠짐** → `impact`·`ratchet`·`wrench`·`hammerTap`·`ambGarage` 자리 | 가장 AI가 헷갈린 렌치·임팩트 계열(얇음 목록: wrench·wrenchTighten·impact·impactBurst)을 진짜 정비소 공구 소리로 바꿀 수 있음. 트랙리스트(2,738줄)에서 'Impact Wrench, Pneumatic, Chicago Pneumatic 1/2 inch drive', 'Ratchet, Pneumatic 3/8 drive', 'Air Compressor turning on and running and turning off' 직접 확인 | 위와 같은 Sonniss 라이선스 | 손 렌치(스패너) 소리는 따로 안 보임(트랙리스트에서 'hand wrench' 못 찾음) → 아래 Stormwave 라쳇·Freesound 보충. 5.9 GB라 디스크 여유 필요 |
| 3 ★ | **Sonniss "Toyota Rav4 2004"** (pinecone-sound) 29개 · 431 MB | https://sonniss.com/sound-effects/toyota-rav4-2004/ | **$25** | 시동 소리 4종(시동-공회전-rev-정지 65초 · 시동-공회전-정지 29초 · 짧은 판 7초 · **'false start' 3.5초 = 헛돌다 안 걸림** → `engineFail` 후보), **점화 키 배럴 소리 1분 41초**, 운전석·조수석 문, 트렁크 닫기, 전동 창, 지나가는 소리 | 시동 성공·실패가 이 게임의 핵심 소리(첫 두 손님). 우리 `engineStart`(AI가 오토바이로 들음)·`engineFail`을 평범한 4기통 SUV 녹음으로 비교해 볼 수 있음. 파일 이름 직접 확인 | Sonniss 라이선스 2.0 | 도요타 모델 이름은 파일 이름에만 있고 게임엔 안 나옴. 'dead battery 딸깍딸깍'은 정확히 없음(false start가 제일 가까움 — 귀로 확인) |
| 4 ★ | **Stormwave "Ratchet Mechanism SFX Pack"** + **"Petrol Car Engine SFX Pack"** (itch.io) | https://stormwave-audio.itch.io/ratchet-sfx-pack · https://stormwave-audio.itch.io/petrol-car-engine-sfx-pack | **$1.99 + $1.99 = $3.98** | 라쳇 녹음 10개(13초) · 2.0 가솔린 엔진 7개(시동 2·공회전 루프·rev 4) | 값이 싸서 부담 없고, 둘 다 itch 페이지에 **'No generative AI was used'** 표시. 소리 맛보기 겸 1·2·3 전에 시험용 | Stormwave 가게 약관(https://stormwave-audio.com/shop/shop-terms-conditions/): '자기 원본 상업·비상업 프로젝트, **video games** 에 쓰기 OK' 직접 확인 | itch 압축 파일 안 'Sound Effect License Agreement.pdf'는 사기 전엔 못 읽음(가게 약관과 같을 거라고 봄 — 산 뒤 한 번 읽기). 원본 파일 남에게 주기 X |
| 5 ☆ | **Sonniss GDC 2026 무료 게임 오디오 묶음** (+ 지난 9년 '아카이브' 200 GB) | https://gdc.sonniss.com/ | **$0** | 어떤 소리든 빈 곳 메우기(추가로 찾기용 '낚시터'): 347+ 파일 · 7.47 GB · 17곳 제작사(Epic Stock Media·SoundBits·Just Sound Effects 등) | 공짜인데 가게에서 파는 것과 **같은 파일**(손 안 댄 원본). 가게 라이브러리 샘플이라 품질 높음 | 묶음 전용 라이선스 2.0(https://sonniss.com/gdc-bundle-license/, 2026-08-27 효력): 게임 OK, 출처 X, 수정 OK, 평생. 직접 읽음 | 안에 뭐가 있는지 트랙리스트 페이지를 내가 못 열어 봄(자바스크립트 페이지) → **확인 못 함: 정비소 공구·시동이 들어 있는지는 받아 봐야 앎**. 7.47 GB 다운로드는 사용자가. **AI에 넣기 금지** |
| 6 ☆ | **Roblox 상점 'ProSoundEffects' 무료 효과음** (직업 음향 회사 라이브러리, 상점에서 바로 ID로 씀) | 예: 보닛 열림 https://create.roblox.com/store/asset/9116548055 · 아래 '소리 분야 표'에 ID 모음 | **$0** | `hoodOpen`/`hoodClose`(보닛 열림 소리 변형 10개), 문·트렁크, **키를 꽂고 돌리는 소리**, 금전등록기 서랍, 공기 빠짐 칙, 주차 브레이크 당김, 작은 마을·주차장 배경 | **업로드 필요 없음**(Roblox가 호스팅) · 진짜 녹음 · 전부 무료. 시험 전에 바로 ID만 바꿔 껴 볼 수 있음 | Roblox 공식 문서(https://create.roblox.com/docs/audio/assets): 상점 오디오는 '무료로 쓰는 용도'이고 '10만 개+ 전문 효과음·음악'이라고 소개. ID로 게임에서 쓰기 OK | 파일을 받을 수 없어서 **자르기·EQ·크기 조정은 못 함**(`PlaybackRegion`·Volume·PitchShift로만). 이름에 브랜드(Audi·Jaguar)가 있어도 게임엔 안 보임. 게임에서 실제 재생은 **확인 못 함**(Studio에서 한 번 틀어 보기). 'Tire Dealer 2'엔 사람 목소리가 섞임 |
| 7 ★ | **Moon Animator 2** (xsixx) — Studio 플러그인 | https://create.roblox.com/store/asset/4725618216 | **US$19.99**(33% 세일 중) | 쪼그림·누움판 눕기·렌치 돌림 등 R15 자세 애니메이션 만들기, IK·곡선·자석 정렬 | 로블록스 애니메이션 플러그인의 표준(투표 30,000표 · 93% 좋아요, 2020년부터, 어제(10-21)도 업데이트). Studio 기본 Animation Editor보다 빠르고 편함 | 상점 정식 판매(구매 페이지 직접 열어 가격 확인) | **필수는 아님**(기본 Animation Editor + IK로도 가능). 플러그인은 Studio 권한으로 도니까 이 정도로 검증된 것만 |
| 8 ☆ | **영상 → 애니메이션(Animation Capture – Body)** + **RBXMonkey (Blender ↔ Studio)** | https://create.roblox.com/docs/animation/capture · https://create.roblox.com/store/asset/16708835782 | **$0** | 사람이 직접 쪼그려 앉고 렌치 돌리는 15초 영상 → R15 키프레임(손으로 다듬기). Blender로 정교하게 만들 땐 RBXMonkey 플러그인 + Blender 애드온 | 사람 동작에서 나와서 'AI가 지어낸 동작'이 아님. 우리는 이미 Blender를 씀 | 로블록스 공식 기능(베타 → File ▸ Beta Features ▸ **Live Animation Creator** 켜기, 영상 15초 이하·한 사람·고정 카메라). RBXMonkey = 투표 2,000표 · 93%, 10-09 업데이트, '영원히 무료'라고 설명 | 베타라 결과가 거칠 수 있음(다듬기 필요). RBXMonkey는 최신 Blender 애드온과 짝 맞춰야 함 |
| 9 ★ | **Sonniss "Electric Cash Register"** (Andreas) 106개 · 370 MB | https://sonniss.com/sound-effects/electric-cash-register/ | **$25** | 영수증 프린터 `receiptPrint`(Bon Print 3종·종이 움직임·**종이 뜯기 Rip**), 서랍 열고 닫기, 키·버튼, 에러 켜짐/꺼짐 → `receiptPrint`·`payout`·`stamp`·`wrongBuzz` | 오래된 Sanyo 금전등록기를 직접 녹음. 파일 이름 직접 확인(Bon_Print_1~3, Drawer_Open_Close, UI_Button, Error_On_Off). 우리 '오늘의 영수증' 화면과 딱 맞음 | Sonniss 라이선스 2.0 | 영수증/서랍 위주라 '칭' 하는 계산대 종소리는 없음(`payout`은 AI 그대로 두거나 코인 라이브러리 보충) |
| 10 ★ | **gvesster "Icon Pack"** (벡터 만화풍) 900+ 아이콘 | https://gvesster.itch.io/gvesster-icon-pack | **$16.99** | 공용 UI 아이콘(설정·돈·상·잠금·트로피·톱니·**망치·공구·차·볼트·열쇠** 등 12 종류) | **이미 우리가 쓰는 무료 팩과 같은 작가**라 그림체가 맞음 · 'No generative AI was used' 표시 · Roblox용으로 팔림 | 작가 라이선스 글(https://gvesster.itch.io/gvesster-license): '게임에서 유료 팩 아이콘 쓰는 건 상업 라이선스 없이 OK, 수익 나도 OK, 대신 UI 디자인 의뢰를 받아 팔 때만 라이선스 필요' 직접 읽음 | 팩 이름대로 시뮬레이터·RNG 풍(알·포션·펫)이 많아서 **쓸 건 일부**. 정비 부품 아이콘은 계속 우리 그림. 급하지 않음 — **공개 뒤 OK**. 원본 그대로 쓰기(색 바꾸기 X는 기존 규칙 그대로) |

### 총액

| 묶음 | 항목 | 값 |
|---|---|---|
| **꼭 사면 좋은 것** | 1 Car Interiors $35 + 2 Tools $36 + 3 RAV4 $25 + 4 Stormwave 둘 $3.98 + 7 Moon Animator 2 $19.99 | **$119.97** |
| 더하면 좋은 것 | 9 Electric Cash Register $25 + 10 gvesster Icon Pack $16.99 | **$41.99** |
| **TOP 10 전부** | 위 둘의 합 (5·6·8은 공짜) | **$161.96** |
| 예산이 빠듯하면 | 1 + 2 + 4 (소리만, 공구·차 안) | $74.98 |
| 제일 적게 | 4 Stormwave 둘만 사서 맛 보고, 5·6 공짜로 시작 | $3.98 |

(세금·결제 수수료는 장바구니에서 확인. Sonniss는 가끔 세일 — 오늘도 '여름 세일 중'이라고 적혀 있었어요.)

### 지킬 것 (소리 라이브러리 공통 — Pizza Doggy 때와 같은 규칙)

- **AI에 넣지 않기**: Sonniss 라이선스에 '인공지능 학습·사용 금지' 문구가 있어요. 우리 판정 AI(AST·CLAP)·GPT·Claude에게 파일을 보내지 않고, 이 소리를 참고로 AI가 비슷한 소리를 만들게 하지도 않기. **고르기는 사용자 귀로**, 세션은 ffmpeg로 자르기·크기 맞추기·ogg 변환만.
- 원본 파일을 남에게 주거나 공개 저장소·공유 드라이브에 올리지 않기. 폴더는 `art/_bought/sonniss_.../`처럼 따로. 팀 사람이 늘면 'multi-user 라이선스'가 필요(조항 d).
- Roblox에는 **비공개 오디오로 업로드**(Creator Store 공개 X). 조항 (e)가 '내 프로젝트에 동기화돼 재생되는 것'을 허락하고, 조항 (d)는 '서버·공유 드라이브에 올려 남이 가져가게 하는 것'을 막아요 — 게임 안에서 쓰는 비공개 업로드는 (e) 쪽이라고 읽지만, **Roblox 업로드를 콕 집어 허락한다는 글은 못 찾음**. 마음이 불안하면 Sonniss 채팅에 "Roblox 게임 안에서 쓰는 비공개 오디오 업로드 OK?" 한 줄 물어보기.
- 업로드 한도는 걱정 없어요: Roblox 문서(2026-10-22 판) = ID 인증된 계정은 **30일에 오디오 2,000개 무료**.

---

## 분야별 후보 표

판정 = **사기**(TOP 10 안) / **무료로 쓰기** / **보류**(필요해지면) / **사지 말 것**(이유는 맨 아래 표).

### ① 소리 (정비소 효과음·공구·엔진·배경)

현재 우리 소리: ElevenLabs로 만든 v3(`art/sfx/v3/review_1022.md`) + 산 Pizza Doggy Cozy FX(37개)·Kenney(CC0). AI가 헷갈린 것(brakeGrind·fuelPrime·washerWhirr·partSlide)·몸통이 얇은 것(wrench·wrenchTighten·impact·impactBurst·hoodOpen·liftLock·clank·crankShort)을 '진짜 녹음'으로 비교해 보고, 귀로 이긴 것만 쓰기.

| 이름 | 링크 | 값 | 우리 어디에 | 라이선스·확인 | 판정 |
|---|---|---|---|---|---|
| Sonniss Car Interiors | (TOP 10 #1) | $35 | 문·와이퍼·경적·깜박이·브레이크 페달·시동 | Sonniss 2.0, 파일 이름 일부 확인 | **사기** |
| Sonniss Tools | (TOP 10 #2) | $36 | 임팩트·라쳇·망치·컴프레서 | Sonniss 2.0, 트랙리스트 확인 | **사기** |
| Sonniss Toyota Rav4 2004 | (TOP 10 #3) | $25 | 시동·헛돌기·점화 키·문·트렁크 | Sonniss 2.0, 파일 이름 확인 | **사기** |
| Sonniss Electric Cash Register | (TOP 10 #9) | $25 | 영수증 인쇄·서랍·버튼 | Sonniss 2.0, 파일 이름 확인 | **사기(더하면 좋음)** |
| Stormwave Ratchet · Petrol Car Engine | (TOP 10 #4) | $1.99씩 | 라쳇 · 엔진 시동·공회전 | 가게 약관 확인, 'No generative AI' | **사기** |
| Sonniss GDC 2026 무료 묶음(+아카이브) | https://gdc.sonniss.com/ | $0 | 빈 곳 낚시 | 묶음 라이선스 2.0 직접 읽음 | **무료로 쓰기** |
| Roblox 상점 ProSoundEffects | 아래 ID 표 | $0 | 보닛·문·키·서랍·공기·배경 | Roblox 문서 | **무료로 쓰기** |
| Freesound CC0 (아래 목록) | https://freesound.org/ | $0 | 임팩트 렌치·소켓 렌치·공구함 떨어짐·시동·차고 배경 | 페이지마다 'Creative Commons 0' 표시 직접 확인 | **무료로 쓰기** (품질 들쭉날쭉, 귀로 고르기) |
| Roblox 상점 APM Music (APMOfficial) | Toolbox ▸ Audio ▸ 'APMOfficial' 검색 | $0 | 배경 음악 후보(전문 제작 음악) | Roblox 상점 무료. 곡이 영화풍이 많음, **귀로 고르기 — 내가 못 들음** | **무료로 쓰기(선택)** |
| Sonniss Realistic Coin Handling Sounds (RawAmbience) 313개 | https://sonniss.com/sound-effects/realistic-coin-handling-sounds/ | $15.99 | 돈 받는 소리 `payout`을 AI에서 바꾸고 싶을 때 | Sonniss 2.0. 설명: 'shiny coin chime이 아니라 진짜 동전 만지는 소리' | 보류 |
| Sonniss Huge Hydraulic Lift (audionym) 26개 | https://sonniss.com/sound-effects/huge-hydraulic-lift/ | $26 | `liftMotor`·`liftLock` 비교용 | 큰 산업용 리프트 녹음(우리 2주 리프트와 크기 다름). 파일 이름 못 읽음 | 보류 |
| Sonniss Metal Friction (RawAmbience) 148개 · 102 MB | https://sonniss.com/sound-effects-tag/squeal/ 에서 찾음 | $11.99 | `brakeGrind`·삐걱 쇳소리 후보 | 설명만 읽음(문·게이트 포함) — **내용 못 확인** | 보류 |
| Sonniss Pneuma (Max Kokopelli) 338개 | https://sonniss.com/sound-effects/pneuma/ | $69 | 공압 임팩트 렌치가 더 많이 필요할 때 | Sonniss 2.0 | 보류(Tools로 충분) |
| Iron Audio Tools SFX Vol.1 (itch) 200+개 | https://iron-audio.itch.io/tool-sfx-vol-1 | $2 CAD | 렌치·라쳇·컴프레서 | 'No generative AI', **라이선스 글이 페이지에 없음** | 보류(라이선스 확인 못 함) |

**ProSoundEffects 무료 ID 모음** (https://create.roblox.com/store/asset/<번호> — 번호는 Roblox API에서 직접 조회한 값, 길이 = 조회한 값):

| 쓰임새 | 번호 · 이름 · 길이 |
|---|---|
| 보닛 열기(끼익+철컥, 변형 10개 중 몇 개) | 9116548055 Metal Creak Car Hood Opening 7 (1.8초) · 9116547755 #4 (1.3초) · 9116548343 #10 (1.6초) |
| 보닛 닫기 / 손바닥으로 탁 | 9112956616 Open Close Hood 1 (4.5초, 옛 차) · 9114766463 Hand Hood Slap Car 2 (1.6초) |
| 문 열고 닫기 · 트렁크 | 9113203879 Car Door Movement 1 (1.9초) · 9113205993 Car Trunk Opening Closing 1 (2.6초) |
| 키 꽂고 돌리기 | 9116176803 Keys Insert Into Ignition and Turn (2.6초) |
| 시동(옛 차 = 시대 차용) | 9112952102 1965 Jaguar E-Type Cold Starts 1 (2.4초) · 9112936632 1942 Dodge WC Command Car Start Idle Revs 1 (10.9초) |
| 금전등록기 서랍 | 9113728049 Cash Register 2 (1.7초) · 9113728042 #1 (2.1초) |
| 주차 브레이크 당김(딸깍딸깍 쇠) | 9112957093 Parking Brake Pull 2 (3초) |
| 공기 빠짐(타이어·압축) | 9125353894 Air Release … Tire Air (21초) · 9114808571 Hiss Clunk Air Releases 1 (6.8초) |
| 공구 | 9117707273 Pneumatic Impact Wrench On Off 8 (1초) · 9118047781 Ratchet Wrench Gear Winding 3 (2초) · 9125969494 Socket Wrench Searching A Tool Box (2초) |
| 동네 배경 | 9112874053 Small Town Ambience 1 (36초) · 9112841159 Parking Lot Ambience 1 (36초) · 9112757705 City Ambience 1 (46초) |

**Freesound CC0 직접 확인한 것**(페이지 열어서 'Creative Commons 0' 확인): 임팩트 렌치 https://freesound.org/people/jacekksiazek/sounds/397932/ · https://freesound.org/people/sevenbsb/sounds/349398/ · https://freesound.org/people/SamuelGremaud/sounds/458855/ · 라쳇 드릴 https://freesound.org/people/ldezem/sounds/386209/ · 소켓 렌치 https://freesound.org/people/xxqmanxx/sounds/147018/ · 공구함 쇠 떨어짐 https://freesound.org/people/Nox_Sound/sounds/556648/ · 동네 차고 배경 https://freesound.org/people/RavenWolfProds/sounds/503662/ · 시동 https://freesound.org/people/Filmscore/sounds/828776/ 
(검색 결과로는 브레이크 끽·타이어 바람·유압 잭은 CC0에서 쓸 만한 게 안 나왔어요. 그 소리들은 지금 AI 소리 유지 + 귀로 확인하는 게 현실적이에요.)

**'우리 소리 ↔ 진짜 녹음 후보'** (바꿀지는 사용자 귀로):
`wrench`·`wrenchTighten`·`ratchet`·`impact`·`impactBurst` → Tools · Stormwave 라쳇 · Freesound 렌치 / `hammerTap`·`clank`·`partDrop` → Tools(망치) · Freesound 공구함 / `engineStart`·`engineFail` → RAV4(start·false start) · Stormwave 엔진 · ProSoundEffects 옛 차 시동 / `hoodOpen`·`hoodClose` → ProSoundEffects 보닛(변형 10개) / 문 → Car Interiors · RAV4 · ProSoundEffects / `wiperMotor` · 경적(`lineHonk`·`cheer`) · 깜박이 → Car Interiors / `receiptPrint`·서랍 → Electric Cash Register · ProSoundEffects 서랍 / `ambGarage`·`ambStreet` → Tools(컴프레서)·ProSoundEffects 배경·Freesound / `brakeSqueal`·`brakeGrind`·`steamHiss`·`tireHiss` → 확실한 후보 **못 찾음**(위 설명).

### ② 애니메이션 (R15 정비 동작)

사실 한 줄: Roblox 상점 검색(종류 'Animation')에서 '쪼그림·무릎 꿇기·정비·렌치' 모두 **결과 0개**였어요(애니메이션은 상점에서 팔지 않음). 우리가 필요한 건 `docs/design/work_view.md`의 **숙이기·쪼그려 앉기·누움판에 눕기 3개**(MVP)와 공개 뒤 팔 IK예요.

| 이름 | 링크 | 값 | 무엇 | 확인 | 판정 |
|---|---|---|---|---|---|
| Studio 기본 Animation Editor + IK(Inverse Kinematics) | https://create.roblox.com/docs/animation/editor | $0 | R15 키프레임·IK·곡선 | 공식 문서 목록에서 확인 | 무료로 쓰기 |
| **Animation Capture – Body**(영상 → 키프레임) | https://create.roblox.com/docs/animation/capture | $0 | 15초 영상 → R15 애니메이션 | 공식 문서 직접 읽음(베타 기능 켜야 함) | **무료로 쓰기 (TOP 10 #8)** |
| **RBXMonkey – Blender Animations** | https://create.roblox.com/store/asset/16708835782 | $0 | Blender에서 R15 만들고 Studio로 | 투표 2,000표·93%, 2026-10-09 업데이트 | **무료로 쓰기 (TOP 10 #8)** |
| **Moon Animator 2** | https://create.roblox.com/store/asset/4725618216 | $19.99 | 편한 애니메이션 편집기 | 구매 페이지 직접 확인 | **사기 (TOP 10 #7)** |
| Quaternius Universal Animation Library 1·2 | https://quaternius.itch.io/universal-animation-library · https://quaternius.itch.io/universal-animation-library-2 | $0(이름 정해 내기) | 120개+/130개+ 사람형 동작(앉기·기어가기·농사·낚시 등). Unreal/Unity/Godot용 리그 | CC0, 'No generative AI' 직접 확인 | 보류 — R15로 옮기려면 Blender에서 다시 맞추는 큰 일. **정비 자세는 없음**(기어가기·앉기는 참고용) |
| Mixamo (Adobe) | https://www.mixamo.com/ | $0 | 무릎 꿇기·앉기·눕기 등 | 상업 게임 OK라는 Adobe 쪽 글을 검색으로 봄. **Roblox 업로드 허락 글·정비 동작 목록은 확인 못 함**(로그인 필요) | 보류 |
| Eclipse Animator | https://create.roblox.com/store/asset/86116556258301 | $19.99 | Moon과 같은 종류 | 투표 10,000·99% | 사지 말 것(중복) |
| Auto Animator (Nuximus) | https://create.roblox.com/store/asset/140150139695106 | $14.99 | 걷기·달리기·전투·춤 109개 | 10-20 올라옴, 투표 0 | 사지 말 것 |
| Tempo Animator (FractalForge) | https://create.roblox.com/store/asset/107908830639258 | $4.99 | 새 편집기 | 투표 0표(새것) | 보류 |
| 유료 R15 애니메이션 팩(BuiltByBit '35+ pack' 등) | https://builtbybit.com/resources/r15-animations-35-pack.81248/ | $8.49 | 쪼그림 대기·운동·전투 | 검색 결과 요약만 봄(페이지는 직접 안 열음): '출처 표시하며 내 프로젝트에 사용', 무릎·정비 동작 없음 | 사지 말 것 |

### ③ 소품 3D (정비소 소품 — 차·손 공구는 우리가 직접)

| 이름 | 링크 | 값 | 무엇 | 확인한 것 | 판정 |
|---|---|---|---|---|---|
| NoduoDev "Car Garage Pack Vol. 1" | https://create.roblox.com/store/asset/74108326703084 | $9.99 | 리프트·잭·스탠드·호이스트·엔진·배터리·공구함·작업대·컴프레서 14개 | 스크립트 0. 그림체는 우리와 가장 가까운 만화풍(빨간 공구함). **그런데 설명에 'Meshy AI(이미지→3D)로 만들고 OpenAI 그림으로 참고 이미지'라고 적혀 있음**. 삼각형 합 137,171(개당 약 1만) | **사지 말 것** |
| Irchris5 "Car Tuning Garage & Mechanic Shop Kit" | https://create.roblox.com/store/asset/82340083057728 | $3.99 | 리프트·타이어 랙·공구함 등 10개 | 스크립트 0. **'Includes AI-assisted 3D generation'** 적혀 있음. 삼각형 179,992 | **사지 말 것** |
| IceTimeAdventures "Workshop Tools Asset Pack" | https://create.roblox.com/store/asset/111602276001299 | $2.99 | 공구 카트·렌치·소켓·드라이버 23개 | 스크립트 0, 삼각형 15,674, 사람이 만든 듯(AI 표시 없음). 단 **손 공구는 우리가 직접 만들기로 한 것** | 사지 말 것(규칙) |
| Lukami "Stylized Tool Pack x36" | https://create.roblox.com/store/asset/92374212033627 | $2.99 | 공구 36개·작업대 | 스크립트 0, 삼각형 87,902, 썸네일이 흰 배경 단순 | 사지 말 것(규칙 + 삼각형) |
| Fab "Ultimate Garage & Auto Workshop Mega Pack" (30+개) | https://www.fab.com/listings/b65e8ee6-7b0d-4152-a5f4-38b4c829f0dc | 가격 못 봄 | 공구 카트·작업대·잭·타이어·배터리 | 'AI로 생성됨: 아니요'(Fab 표시). **녹슨 사실적 PBR 그림체** | 사지 말 것(그림체 안 맞음; Fab 라이선스·가격 확인 못 함) |
| itch "Garage Tools Props Pack" (ResilientLogic) | https://resilientlogicstudio.itch.io/garage-tools-props-pack | $5부터 | 공구 11개·작업대 | Unity용. 열어 보지 않음 | 보류(손 공구는 우리가 만듦) |
| Kenney Game Assets All-in-1 | https://kenney.itch.io/kenney-game-assets | $19.95 | 공짜 콘텐츠 6만+ 개를 한 번에(2D·3D·소리 1,200+·글꼴·UI). 페이지에 'CC0'라고 직접 적혀 있진 않지만 Kenney는 원래 CC0 | 정비소 전용 소품 있는지 **확인 못 함**(Kenney 'City Kit (Industrial)'은 목록에서 봄) | 보류 |

결론: **지금 정비소 안 소품은 사지 말고** 파트·Blender로 짓기. 거리 소품은 이미 산 `art/_bought/itch_creator_bundle_v1/cartoon_city`(CC0)가 통나무·드럼통·팔레트·지게차·가스통·타이어를 갖고 있어서(zip 목록을 직접 봄) 새로 살 필요 없음.

### ④ UI (아이콘 팩·폰트)

| 이름 | 링크 | 값 | 무엇 | 확인한 것 | 판정 |
|---|---|---|---|---|---|
| **Roblox 안 글꼴: Highway Gothic** | https://create.roblox.com/docs/reference/engine/datatypes/Font (`rbxasset://fonts/families/HighwayGothic.json`) | $0 | **미국 도로 표지판 글꼴** → 거리 표지판 `MAPLE ROW`·`AVENUE FUEL`·주유소 가격판(지금 Gotham Bold) | 문서의 글꼴 목록에서 직접 확인(전체: Accanthis ADF, Amatic SC, Arimo, Balthazar, Bangers, Builder Sans/Extended/Mono, Comic Neue Angular, Creepster, Denk One, Fondamento, Fredoka One, Grenze Gotisch, Guru, Highway Gothic, Inconsolata, Indie Flower, Josefin Sans, Jura, Kalam, Luckiest Guy, Merriweather, Michroma, Montserrat, Nunito, Oswald, Patrick Hand, Permanent Marker, Press Start 2P, Roboto 계열, Roman Antique, Sarpanch, Source Sans Pro, **Special Elite**, Titillium Web, Ubuntu, Zekton) | **무료로 쓰기** |
| Special Elite(영수증·타자기) · Permanent Marker(손글씨 칠판) | 위와 같음 | $0 | 영수증 글자·칠판 메뉴판 | 위와 같음 | 무료로 쓰기 |
| gvesster Icon Pack | (TOP 10 #10) | $16.99 | 공용 아이콘 900+ | 직접 읽음 | 사기(나중) |
| gvesster Tiers Icon Pack | https://gvesster.itch.io/tiers-icon-pack | $11.99 | 돈·보석·트로피 12단계 색 | 'No generative AI' 확인 | 보류(레벨 보상 그림 필요할 때) |
| Roblox 상점 UI 팩들(Cartoon Blocky UI Kit $2.99, Simulator UI Kit $4.99 …) | https://create.roblox.com/store/asset/128494333803543 | $2.99~ | 시뮬레이터풍 버튼·패널 | 일부는 스크립트 포함. 일반 시뮬레이터 모양 → 우리 정비소 테마 kit_B와 섞이면 통일감 깨짐 | 사지 말 것 |
| 사용자 글꼴 올리기 | — | — | TTF를 올려 쓰기 | 공식 문서에서 지원한다는 글을 **못 찾음**(검색 결과는 '기능 요청'뿐) | 확인 못 함 |

참고: Highway Gothic에 **한글 글자가 있는지는 확인 못 함** — 영어 간판·표지판용으로만 쓰고, 한글 UI는 지금 글꼴 그대로가 안전해요.

### ⑤ Studio 플러그인

플러그인은 Studio 권한으로 돌아서 뒷문 위험이 있어요(전부 스크립트 포함 — 상점이 '스크립트 있음'으로 표시). 그래서 **투표 많고 오래된 것만** 후보로 했어요.

| 이름 | 링크 | 값 | 무엇 | 확인한 것 | 판정 |
|---|---|---|---|---|---|
| Moon Animator 2 | https://create.roblox.com/store/asset/4725618216 | $19.99 | 애니메이션 | 30,000표·93% | **사기** |
| RBXMonkey – Blender Animations | https://create.roblox.com/store/asset/16708835782 | $0 | Blender 연결 | 2,000표·93% | 무료로 쓰기 |
| Building Tools by F3X | https://create.roblox.com/store/asset/144950355 | $0 | 파트 건축 도구 | 10,000표·96% | 보류(우리는 코드로 지음) |
| Stravant GapFill & Extrude | https://create.roblox.com/store/asset/165687726 | $0 | 틈 메우기 | 4,000표·96% | 보류 |
| Archimedes | https://create.roblox.com/store/asset/144938633 | $0 | 곡선 만들기 | 7,000표·96% | 보류 |
| Rojo | https://create.roblox.com/store/asset/13916111004 | $0 | 코드 동기화 | 우리 폴더에 `default.project.json`이 있어 이미 쓰는 듯 | (이미 있을 것) |
| Mesh Optimization Tools | https://create.roblox.com/store/asset/414923656 | $4.99 | 삼각형·충돌 줄이기 | 100표·82% | 보류 |
| Auto Animator · Eclipse · Tempo · MegMo | (②표) | $4.99~19.99 | 애니메이션 | 새것이거나 중복 | 사지 말 것 / 보류 |
| UI Animator 류(Cascade UI Animator $6.99, UI Animator Pro $4.99 …) | 상점 검색 | $5~ | UI 움직임 | 투표 0~새것. UI 움직임은 코드(트윈)로 이미 함 | 사지 말 것 |

---

## 사지 말 것 (이유)

| 무엇 | 값 | 이유 |
|---|---|---|
| NoduoDev "Car Garage Pack Vol. 1" | $9.99 | 만든 사람이 직접 **'Meshy AI로 만든 3D'** 라고 적음(규칙 '게임 안에 AI 티 X'). 삼각형 13.7만. 모양은 우리 그림체에 가장 가까워서 아까운데, 규칙상 X |
| Irchris5 "Car Tuning Garage & Mechanic Shop Kit" | $3.99 | 'AI-assisted 3D generation' 표시 + 삼각형 18만 |
| Roblox 상점 UI 키트 여러 개 | $3~5 | 일반 시뮬레이터 모양이라 우리 UI와 섞이면 통일감 깨짐. 스크립트 포함 |
| Roblox 상점 '무료' 정비소 모델 수십 개 (자동차 리프트·공구함 등) | $0 | 아무나 올린 것, 품질 들쭉날쭉. 일부는 스크립트 포함(예: "Working Garage w/ Button" 스크립트 1개) → 뒷문 위험 |
| Roblox 상점 아무나 올린 소리(예: 게임에서 뜯은 소리, 'Team Fortress 2' 렌치 소리 등) | $0 | 저작권이 불확실. **ProSoundEffects·APM 같은 전문 제작사 것만** 쓰기 |
| Epidemic Sound 구독 | 월 요금 | 게임·Roblox에서 쓰는 약관을 **확인 못 함**('독립 감상용으로는 불가' 글만 확인). 확실해지기 전엔 X |
| Artlist · Soundstripe · Envato(AudioJungle) 소리 | 구독/건별 | Roblox 업로드 가능 여부 **확인 못 함** |
| Magic Sound Effects "Car Engines Vol. 2" | $30 | 차 16대(도시·스포츠·오프로드·픽업) 가속·감속·rpm 루프 중심 400개, '현실적인 차 샘플로 만든' 소리(순수 녹음이 아님), 라이선스 '개인 + 상업 프로젝트 1개'. 우리가 필요한 건 평범한 차 시동·헛돎이라 RAV4가 더 맞음 |
| Stormwave "Industrial Sound Effects Bundle" | $199 | 2,000개 산업 녹음. 너무 큼 — Tools·Pneuma로 충분 |
| Sonniss "Cars Mega Bundle" (GfxSoundsStudios) | $119 | 1,736개·11 GB. 크랭크·공회전은 있지만 RAV4($25)로 먼저 시험해 보고 늘리기 |
| Auto Animator · Eclipse Animator · Tempo Animator | $4.99~19.99 | 우리가 필요한 동작(쪼그림·누움·렌치)이 아니거나(걷기·전투·춤) Moon과 중복 / 새것이라 평가 0 |
| Fab "Ultimate Garage & Auto Workshop Mega Pack" | ? | 녹슨 실사 그림체 → 우리 캐주얼과 안 맞음 |
| ElevenLabs로 더 만들기(소리) | 크레딧 | 사지 말 것은 아니지만, '진짜 녹음이 이기는지' 먼저 비교한 뒤에 |

---

## 확인 못 한 것

- **Sonniss GDC 2026 묶음 트랙리스트**: 자바스크립트 페이지라 못 열었어요 → 정비소 공구·시동이 들어 있는지 모름.
- **Car Interiors 트랙리스트 PDF**: 106개 중 28개 파일 이름만 읽었어요(PDF 글자 변환 한계). 나머지(와이퍼·경적·시동·안전벨트)는 가게 설명 글에만 근거.
- **Sonniss 라이선스의 Roblox 조항**: '게임에 동기화해 재생 OK'는 읽었지만 Roblox 비공개 업로드를 콕 집은 글은 없음(위 '지킬 것').
- **ProSoundEffects 소리의 게임 안 재생**: ID가 상점에서 무료·공개로 뜨는 것만 API로 확인. 우리 게임(Sound / AudioPlayer)에서 실제로 소리 나는지는 **Studio에서 한 번 틀어 봐야** 앎. 소리 자체는 내가 못 들음(귀로 확인은 사용자).
- **Iron Audio Tools Vol.1**: 페이지에 라이선스 글 없음(구매 뒤 압축 안 파일 확인해야). **Stormwave itch 압축 안 PDF**도 구매 전엔 못 읽음(가게 약관만 읽음).
- **Mixamo**: 로그인 필요해서 '정비 동작이 있는지'·Roblox 허락 글은 못 봄.
- **Fab 두 정비소 팩의 가격·라이선스**, **Kenney All-in-1에 정비소 소품이 있는지**: 못 봄.
- **Epidemic Sound·Artlist·Soundstripe**의 Roblox 약관.
- **Highway Gothic 한글 지원**, **글꼴 직접 올리기**.
- **Roblox 상점 가격은 USD로만 보임**(로벅스 가격은 못 봄). Moon Animator 2의 세일 끝나는 날 못 봄.
- 소리의 '진짜 녹음이 AI보다 낫다'는 건 **귀로 비교해야** 앎(AI 판정기에 이 라이브러리 파일을 넣을 수 없는 규칙).

---

## 다음 한 걸음 (제안 — 결정은 사용자)

1. (공짜, 지금) ProSoundEffects 보닛 소리 3개 ID를 Studio에서 틀어 보고 `hoodOpen` 자리에 껴 보기 → 마음에 들면 진짜 녹음 쪽이 이긴다는 증거.
2. (싸게) Stormwave 둘 $3.98 → 라쳇·엔진 소리를 귀로 비교.
3. (크게, 같이) Sonniss 3개($96) 장바구니 → 사용자가 직접 결제·다운로드(폴더 `art/_bought/sonniss_*`) → 세션은 ffmpeg로 자르고 ogg 변환만, **사용자가 귀로 골라서** 바꿀 소리 목록 정하기.
4. (애니메이션) Moon Animator 2는 쪼그림·누움 3개 만들기 직전에. 급하면 기본 Animation Editor + 영상 캡처(무료)로 먼저.
5. UI 아이콘 팩($16.99)은 공개(10/31) 뒤로.
