# API 리서치: roblox_car_scale (2026-10-20)

- 모델 claude-sonnet-5-5 · effort low · 비용 약 $0.166 · 검색 6회 · 턴 1 · 끝 end_turn
- 메인 세션 검수 전 자료예요. 숫자는 출처를 보고 다시 확인해요.

# 로블록스 자동차 스터드 크기 조사 (한국어 요약)

## 1. 한 줄 요약
공식 확인된 환산값은 **1 stud = 0.28 m** (1 m ≈ 3.571 stud)입니다. 게임별 자동차 스터드 수치는 검색으로 확인하지 못했습니다. 아래 게임별 칸은 "미확인"으로 두었고, 짐작으로 채우지 않았습니다.

## 2. 찾은 것

**환산 기준**
- 2012년 블로그에는 1 stud = 5 cm (1 m = 20 stud)라고 적혀 있었습니다. 지금은 낡은 값입니다. 
월드 패널이 나온 뒤에는 1 m가 25/7 stud, 즉 1 stud가 0.28 m가 됐다
고 합니다. 근거는 개발자 포럼 글입니다.
- 이 값을 Roblox 공식 문서(docs)에서 직접 확인하지는 못했습니다. 포럼 글은 
월드 패널 설정의 환산값이 공식에 가장 가깝다
는 취지입니다. 그래서 "공식 문서 문장"으로는 확인하지 못한 상태입니다. 필요하면 docs의 Units 페이지를 직접 열어 보세요.
- 5 cm/stud 설을 쓰는 위키와 팬 자료가 아직 많습니다. 그런 자료의 자동차 크기는 믿지 마세요.

**우리 세단 환산 (0.28 m/stud 기준, 직접 계산)**

| 항목 | 실제 | studs |
|---|---|---|
| 길이 | 4.8 m | 약 17.1 |
| 너비 | 1.85 m | 약 6.6 |
| 높이 | 1.45 m | 약 5.2 |
| 휠 지름 (가정 0.65 m) | 0.65 m | 약 2.3 |
| 휠베이스 (가정 2.85 m) | 2.85 m | 약 10.2 |

**게임별 수치**

| 게임 / 킷 | 길이·너비·높이·휠·휠베이스 (studs) | 환산 | 확실도 |
|---|---|---|---|
| A-Chassis 기본값 | 서스펜션 길이·행정 등 설정값은 studs 단위입니다. 기본 차체 크기는 못 찾았습니다. | 0.28 가정 | 차체 크기 미확인 |
| Greenville | 미확인 | 미확인 | – |
| Car Dealership Tycoon | 미확인 | 미확인 | – |
| Driving Empire | 미확인 | 미확인 | – |
| Jailbreak | 미확인. 팬 위키에는 "1 stud = 20 m"라는 글도 있는데, 신뢰할 수 없는 값입니다. | 불명 | 신뢰 낮음 |
| Southwest Florida | 미확인 | 미확인 | – |
| Emergency Response: Liberty County | 미확인 | 미확인 | – |
| Car Crushers 2 | 미확인 | 미확인 | – |
| 정비·수리 게임 (Mechanic 계열) | 미확인 | 미확인 | – |

위 게임들은 인기 차량 게임인데도 공개된 차 크기 수치가 거의 없습니다. 직접 측정해야 합니다. Studio에서 모델을 가져오거나 게임 안에서 아바타(5 stud 전후)와 비교하면 됩니다.

**R15 캐릭터**
- 기본 R15 키는 약 5 studs로 봅니다. 
한 포럼 글은 Rthro 아바타를 5 stud 높이의 R15 기준에 맞추는 보정을 소개합니다.

- 정확한 값은 `Model:GetBoundingBox()`의 Y 크기로 직접 재세요. 아바타 스케일에 따라 달라집니다.
- 앉은 R15의 머리 높이는 자료를 못 찾았습니다. 직접 측정이 필요합니다. 제 추정으로는 좌석면 위 약 2.5~3 stud입니다. 이 추정은 근거 없는 감입니다.

## 3. 우리 게임에 가져올 것 / 피할 것

1. **0.28 m/stud를 고정 기준으로 쓴다.** (크기 S)
   - 왜: 월드 패널 값과 같고, 포럼 합의도 같습니다. 세단은 약 17.1 × 6.6 × 5.2 studs가 됩니다.
2. **"실제 비율"과 "게임 비율"을 나눠서 정한다.** (크기 M)
   - 왜: R15 캐릭터가 약 5 stud(실제 1.4 m)라서 사람이 실제보다 작게 느껴집니다. 차를 실제 비율로 키우면 문이 작아 보이거나, 차가 너무 커서 리프트와 정비소가 비대해집니다.
   - 시험안: 차 길이를 약 14~17 stud 범위에서 프로토타입으로 비교해 보세요.
3. **먼저 앉은 R15 머리 높이를 측정한다.** (크기 S)
   - 왜: 지붕 높이와 시야, 문 높이가 이 값으로 정해집니다.
4. **인기 게임 차 크기를 직접 측정해 표를 채운다.** (크기 M)
   - 왜: 공개 수치가 없습니다. 비슷한 크기로 맞추면 플레이어가 느끼는 차 크기에 익숙해집니다.
5. **휠 지름과 휠베이스는 실제값 × 3.571로 시작한다.** (크기 S)
   - 왜: A-Chassis의 서스펜션과 휠 설정이 studs 단위이므로 같은 기준을 쓰면 튜닝하기 쉽습니다.
6. **5 cm/stud(20 stud = 1 m) 설을 따르지 않는다.** (크기 S)
   - 왜: 옛 값이라 자동차가 3~4배 커집니다.

## 4. 출처
- 스터드→미터 포럼: https://devforum.roblox.com/t/studs-to-metre-conversion/555264
- 측정 단위·최적 스케일: https://devforum.roblox.com/t/unit-of-measure-for-roblox-studs-and-best-modeling-scale/2657252
- 실제 단위 환산: https://devforum.roblox.com/t/how-to-convert-studs-to-real-world-units/1863780
- 물리 단위 변환: https://devforum.roblox.com/t/understanding-roblox-physics-and-their-conversions-to-real-units/1847678
- A-Chassis 설정 예: https://devforum.roblox.com/t/why-does-a-chassis-do-this/1823075
- Rthro/R15 5 stud 보정: https://devforum.roblox.com/t/rthro-rig-height-scale-normalizer/1114031
- 캐릭터 높이 측정: https://devforum.roblox.com/t/character-height-measuring/4299366
- 5 cm 설(낡은 값) 예: https://jailbreak.fandom.com/f/p/4400000000000164069

## 검색에서 본 자료 (자동 수집)
- [Studs to metre conversion? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/studs-to-metre-conversion/555264)
- [Studs to Real life measurements - Building Support - Developer Forum](https://devforum.roblox.com/t/studs-to-real-life-measurements/1822621)
- [Stud (unit)](https://roblox.fandom.com/wiki/Stud_(unit))
- [Stud](https://robloxcities.fandom.com/wiki/Stud)
- [1 Stud = 0.28 m: Roblox Studs to Meters, cm & Feet — studmill](https://studmill.com/tools/studs-converter)
- [Roblox Studs Converter - Convert Studs to Real World Units](https://alienfusiongenerator.com/roblox-studs-converter/)
- [Roblox Units: Studs to Meters Made Easy](https://letstalksport.co.uk/news/2025/09/16/roblox-units-studs-to-meters-made-easy.html)
- [Meters to Roblox](https://milkshakesir.itch.io/meters-to-roblox)
- [Follow MilkshakeSir](https://milkshakesir.itch.io)
- [First upload](https://milkshakesir.itch.io/meters-to-roblox/devlog/513639/first-upload)
- [How To Convert Studs To Real World Units - Community Tutorials - Developer Forum](https://devforum.roblox.com/t/how-to-convert-studs-to-real-world-units/1863780)
- [A-Chassis Steering - Scripting Support - Developer Forum](https://devforum.roblox.com/t/a-chassis-steering/2951099)
- [ROBLOX Calcuations](https://roblox-vehicles-vs.fandom.com/wiki/ROBLOX_Calcuations)
- [Why does a-chassis do this? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/why-does-a-chassis-do-this/1823075)
- [Unit of measure for Roblox (Studs) and best modeling scale - Building Support - Developer Forum](https://devforum.roblox.com/t/unit-of-measure-for-roblox-studs-and-best-modeling-scale/2657252)
- [How to setup a Car on A-Chassis! - Community Tutorials - Developer Forum](https://devforum.roblox.com/t/how-to-setup-a-car-on-a-chassis/1136167)
- [Wheel sizing](https://en.wikipedia.org/wiki/Wheel_sizing)
- [1:43 scale](https://en.wikipedia.org/wiki/1:43_scale)
- [1:24 scale](https://en.wikipedia.org/wiki/1:24_scale)
- [Mini-Z](https://en.wikipedia.org/wiki/Mini-Z)
- [how big is the jailbreak map in real measurements?](https://jailbreak.fandom.com/f/p/4400000000000164069)
- [User blog:EmbalmerMaster9000/ROBLOX: Stud size(s) and how it will affect profiles](https://vsbattles.fandom.com/wiki/User_blog:EmbalmerMaster9000/ROBLOX:_Stud_size(s)_and_how_it_will_affect_profiles)
- [How to roblox how big is a stud: Complete Guide](https://howtoguidedepot.com/how-to-roblox-how-big-is-a-stud/)
- [How many studs is 1 foot in Roblox?](https://www.vintageisthenewold.com/faq/how-many-studs-is-1-foot-in-roblox)
- [Stud (Roblox) — Grokipedia](https://grokipedia.com/page/Stud_Roblox)
- [ROBLOX Action Collection - Jailbreak SWAT Unit Vehicle Playset](https://www.ebay.com/itm/156717528923)
- [Calculate Character Height - Scripting Support - Developer Forum](https://devforum.roblox.com/t/calculate-character-height/2212064)
- [How to get the Height of a R15 Character - Scripting Support - Developer Forum](https://devforum.roblox.com/t/how-to-get-the-height-of-a-r15-character/2946009)
- [Rthro Rig Height Scale Normalizer - Community Resources - Developer Forum](https://devforum.roblox.com/t/rthro-rig-height-scale-normalizer/1114031)
- [Character Height Measuring - Building Support - Developer Forum](https://devforum.roblox.com/t/character-height-measuring/4299366)
- [Measuring Up: How Tall is a Roblox Character?](https://outsidergaming.com/how-tall-roblox-character/)
- [How Tall is a Roblox Character? 📏 Height in Feet & Studs - Playgama Blog](https://playgama.com/blog/2025/07/09/how-tall-is-a-roblox-character-in-feet-or-studs/)
- [Character body specifications](https://create.roblox.com/docs/art/characters/specifications)
- [How Tall is a Roblox Character?<!-- --> - Playbite](https://www.playbite.com/q/how-tall-is-a-roblox-character)
- [How Tall Is a Roblox Character? (Studs, Feet & Real-Life Comparison)](https://socialagechecker.net/blog/how-tall-is-a-roblox-character/)
- [Roblox Game Studs Currency: What you need to know](https://www.thespike.gg/roblox/beginner-guides/roblox-game-studs-currency)
- [Understanding Roblox Physics and Their Conversions to Real Units - Community Tutorials - Developer Forum](https://devforum.roblox.com/t/understanding-roblox-physics-and-their-conversions-to-real-units/1847678)
- [How many studs is there in a meter - Building Support - Developer Forum](https://devforum.roblox.com/t/how-many-studs-is-there-in-a-meter/103417)
