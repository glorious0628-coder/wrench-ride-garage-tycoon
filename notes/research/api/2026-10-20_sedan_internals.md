# API 리서치: sedan_internals (2026-10-20)

- 모델 claude-sonnet-5-5 · effort medium · 비용 약 $0.553 · 검색 20회 · 턴 1 · 끝 end_turn
- 메인 세션 검수 전 자료예요. 숫자는 출처를 보고 다시 확인해요.

# Camry·Accord·Sonata·Altima·Malibu 엔진룸·하부·정비 사양 검증

## 1. 한 줄 요약
- Camry(XV70)는 비교적 확인이 됐습니다. Accord, Sonata, Altima, Malibu는 일부만 확인했습니다.
- **엔진룸 배치, 하부 배치, 라디에이터·범퍼·헤드라이트·스트럿·교류발전기 절차는 이번 검색에서 근거 링크를 못 찾았습니다.** 이 항목은 아래에서 "미확인"으로 표시했습니다. 추측으로 채우지 않았습니다.
- 다음 단계에서는 제조사 공장 서비스 매뉴얼이나 구독형 정비 DB(ALLDATA·Mitchell 등)를 확인해야 합니다.

## 2. 찾은 것

### 2-1. 엔진룸 배치 (항목 1)
| 항목 | 내용 | 신뢰도 | 출처 |
|---|---|---|---|
| Camry 배터리 | 운전석 쪽에 있습니다. 에어필터 하우징 바로 뒤, 퓨즈박스 옆입니다. 좌우 표현이 헷갈려서 사진으로 다시 확인해야 합니다. | 중 (개인 DIY 사이트) | [PaulsTravelPictures](https://www.paulstravelpictures.com/2018-2022-Toyota-Camry-12V-Automotive-Battery-Replacement-Guide/) |
| Malibu 배터리 | 엔진룸 앞쪽, 운전석 쪽입니다. | 중 (부품 쇼핑몰) | [AutoZone](https://www.autozone.com/batteries-starting-and-charging/battery/chevrolet/malibu/2018) |
| Accord 퓨즈박스 | 엔진룸 안, 후드 래치 레버 뒤쪽 위입니다. 박스는 2개입니다. | 중 (포럼) | [DriveAccord](https://www.driveaccord.net/threads/how-do-you-open-10th-gen-fuse-box.511698/) |
| Sonata, Altima 배터리 위치 | 확인 못 했습니다. | 미확인 | – |
| 공기통, 냉각수 탱크, 마스터실린더, 워셔통, 변속기, 벨트 쪽, 발전기, 컴프레서, 흡기·배기 매니폴드, 팬, 스트럿 타워 | 근거 있는 자료를 못 찾았습니다. | **미확인** | – |

- 엔진룸 배치는 우리 게임 모델과 직접 비교해야 합니다. 그래서 차종별 엔진룸 사진을 따로 찾아보는 편이 좋습니다.
- 일반적으로 알려진 가로배치 I4 FWD 구조는 다음과 같습니다. 이것은 일반 상식이고 이번 검색의 근거는 없습니다.
  - 변속기는 한쪽 옆에 있습니다.
  - 벨트는 반대쪽 옆에 있습니다.
  - 흡기 매니폴드와 배기 매니폴드는 앞뒤 중 한쪽에 나뉘어 있습니다.
  - 차종마다 다를 수 있습니다.

### 2-2. 하부 배치 (항목 2)
| 항목 | 내용 | 신뢰도 | 출처 |
|---|---|---|---|
| Accord 서스펜션 | 앞은 맥퍼슨 스트럿, 뒤는 멀티링크입니다. | 높음 (제조사) | [Honda Owners](https://owners.honda.com/vehicles/information/2018/Accord%20Sedan/specs) |
| Camry 서스펜션 | 앞은 스트럿입니다. 뒤 형식은 확인 못 했습니다. | 중 | [CarBuzz](https://carbuzz.com/cars/toyota/camry/2018/specs-and-trims/) |
| Camry 뒤 브레이크 | 디스크입니다. | 중 | [CarConnection](https://www.thecarconnection.com/specifications/toyota_camry_2018) |
| Accord 뒤 브레이크 | 디스크입니다. | 중 | [Autoweb](https://www.autoweb.com/honda/accord-sedan/2018) |
| Altima 뒤 브레이크 | 디스크입니다. 부품도에 디스크 로터와 캘리퍼가 있습니다. | 중 | [Nissan Parts](https://parts.nissanusa.com/v-2019-nissan-altima--s--2-5l-l4-gas/brakes--rear-brakes) |
| Sonata, Malibu 뒤 서스펜션·브레이크 | 확인 못 했습니다. | 미확인 | – |
| 서브프레임, 로어암, 조향기어박스 위치, 등속축 길이(중간축), 배기 경로, 연료탱크, 잭 포인트 | 근거를 못 찾았습니다. | **미확인** | – |

### 2-3. 정비 절차 (항목 3)
| 항목 | 내용 | 신뢰도 | 출처 |
|---|---|---|---|
| Camry 배터리 | (순서) 음극 단자를 먼저 풀고, 양극 단자를 풉니다. 단자 너트는 10mm입니다. 홀드다운은 앞쪽 아래에 12mm 볼트 1개이고, 긴 연장봉이 필요합니다. 홀드다운 바를 빼고 배터리를 들어냅니다. | 중 | [PaulsTravelPictures](https://www.paulstravelpictures.com/2018-2022-Toyota-Camry-12V-Automotive-Battery-Replacement-Guide/) |
| Camry 휠 | 너트는 5개입니다. 토크는 103 N·m(76 ft·lb)이고, 별 모양 순서로 조입니다. | 중 | [ownerspecs](https://ownerspecs.com/toyota/camry-xv70-2018-2024/torque) |
| Camry 앞 패드 | 캘리퍼 볼트는 14mm, 위아래 2개입니다. 캘리퍼를 돌리지 않고 분리해 줄에 걸어둡니다. 피스톤은 F클램프로 누릅니다. 마모 표시(스퀼 바)는 패드 위쪽에 있습니다. | 중 | [PaulsTravelPictures](https://www.paulstravelpictures.com/2018-2022-Toyota-Camry-Front-Brake-Pads-Replacement-Guide/index.html), [iFixit](https://www.ifixit.com/Guide/How+To+Replace+the+Front+Brake+Pads+and+Rotors+on+Your+2018%E2%80%932024+Toyota+Camry/185984) |
| Altima 앞 패드 | 휠 너트가 5개입니다. 마모 표시는 이전 위치와 방향으로 다시 장착해야 합니다. | 중 | [PaulsTravelPictures](https://paulstravelpictures.com/Nissan-Altima-Front-Brake-Pads-Replacement-Guide/) |
| Camry 교류발전기 | 2018–2024 2.5L용 iFixit 가이드가 있고, 공구는 10mm, 12mm, 14mm입니다. 하지만 단계별 내용을 못 읽었습니다. | 낮음 | [iFixit](https://www.ifixit.com/Guide/How+To+Replace+the+Alternator+in+Your+2018%E2%80%932024+Toyota+Camry/185987) |
| Camry 머플러 | 이전 세대(2012–17) 자료입니다. 플랜지 볼트 2개이고 14mm입니다. 고무 행거를 뽑아서 뺍니다. XV70에 그대로 맞는지는 불확실합니다. | 낮음 | [GoParts](https://www.go-parts.com/garage/muffler-toyota-camry-2012-2017) |
| Camry 범퍼·헤드라이트 | 이전 세대(2011–17) 자료입니다. 클립과 볼트를 풀고, 휠하우스 안쪽도 풉니다. 헤드라이트 교체 가이드는 범퍼 제거를 먼저 하라고 합니다. XV70은 불확실합니다. | 낮음 | [1A Auto](https://www.1aauto.com/how-to-remove-bumper-cover-2011-17-toyota-camry/video/51758), [YouCanic](https://www.youcanic.com/replace-headlight-assembly-toyota-camry-2012-2017/) |
| 라디에이터, 스트럿, 다른 4차종의 휠 토크·패드 볼트 수 | 못 찾았습니다. | **미확인** | – |

- XV70 범퍼는 브래킷이 약해 헤드라이트와 범퍼 사이가 벌어지는 경우가 흔합니다. 정비 게임의 고장 증상 소재로 쓸 만합니다. 출처: [GoParts](https://www.go-parts.com/garage/bumper-filler-panel-toyota-camry-2018-2025)

### 2-4. 실제 치수 (항목 4)
| 항목 | 값 | 신뢰도 | 출처 |
|---|---|---|---|
| Camry 축거 | 2,820 mm | 높음 | [Wikipedia](https://en.wikipedia.org/wiki/Toyota_Camry_(XV70)) |
| Camry 크기 | 길이 4,880–4,910 mm, 폭 1,840 mm, 높이 1,445 mm, 공차중량 1,480–1,660 kg | 높음 | 위와 같음 |
| Camry 배터리 규격 | 2018–19년식은 H6(그룹 48), 2020–22년식은 H5(그룹 47)입니다. **한 개인 사이트의 주장이라 불확실합니다.** | 낮음 | [PaulsTravelPictures](https://www.paulstravelpictures.com/2018-2022-Toyota-Camry-12V-Automotive-Battery-Replacement-Guide/) |
| Camry 타이어 | 205/65R16, 215/55R17이 있고, 트림마다 다릅니다. | 중 | [wheel-size](https://www.wheel-size.com/size/toyota/camry/2023/) |
| Camry 로터 | 앞 12.0 in(약 305 mm, 하이브리드 LE 기준), 뒤 11.1 in(약 282 mm) | 중 | [CarConnection](https://www.thecarconnection.com/specifications/toyota_camry_2018) |
| Accord 축거 | 111.4 in(약 2,830 mm) | 중 | [CarConnection](https://www.thecarconnection.com/specifications/honda_accord_2018) |
| Accord 로터 | 앞 12.3 in(약 312 mm), 뒤 11.1 in(약 282 mm). 엔진 사양별 값은 불확실합니다. | 중 | [Autoweb](https://www.autoweb.com/honda/accord-sedan/2018) |
| Sonata 크기 | 축거 2,840 mm, 길이 4,855–4,900 mm, 폭 1,860–1,865 mm, 높이 1,445–1,475 mm | 중 | [CarsGuide](https://www.carsguide.com.au/hyundai/sonata/car-dimensions/2020) |
| Sonata 무게·연료 | 공차중량 1,530 kg, 연료탱크 60 L | 중 | [Auto123](https://www.auto123.com/en/new-cars/technical-specs/hyundai/sonata/2020/base/preferred/) |
| Altima 배터리 | 순정 H5 | 중 | [Nissan Parts](https://parts.nissanusa.com/v-2019-nissan-altima--sr--2-0l-l4-gas/electrical--battery) |
| Malibu 배터리 | 순정 그룹 47(H5) 또는 48(H6) | 중 | [AutoZone](https://www.autozone.com/batteries-starting-and-charging/battery/chevrolet/malibu/2018) |
| 배터리 mm·kg, 윤거, 후드 길이, 엔진룸 폭 | 못 찾았습니다. | **미확인** | – |

## 3. 우리 게임에 가져올 것 / 피할 것
1. **확인된 값만 "검증됨"으로 표시하고, 나머지는 "미확인" 플래그를 단다 (S)**
   - 이유: 위 표의 절반 이상이 미확인입니다. 추측 값이 스펙에 섞이는 것을 막아야 합니다.
2. **공장 매뉴얼·구독 DB로 미확인 항목을 채운다 (M)**
   - 이유: 엔진룸 배치, 서브프레임, 배기 경로, 라디에이터 절차는 무료 요약 글로 확인되지 않았습니다.
3. **배터리 절차는 Camry 방식으로 구현한다 (S)**
   - 이유: 근거가 가장 분명합니다. 음극을 먼저 풀고, 홀드다운을 풀고, 들어냅니다. 10mm 단자 너트와 12mm 홀드다운 볼트, 연장봉이 필요한 점이 "공구 선택" 재미 요소가 됩니다.
4. **앞 패드 교환은 "캘리퍼 볼트 2개 → 캘리퍼 걸어두기 → 피스톤 누르기 → 패드 교체"로 만든다 (S)**
   - 이유: 14mm 볼트 2개와 F클램프 단계가 확인됐습니다. 마모 표시 방향 같은 작은 디테일이 진단 퀴즈가 됩니다.
5. **휠은 너트 5개, 별 모양 순서, 약 100 N·m 근처로 한다 (S)**
   - 이유: Camry 103 N·m이 확인됐습니다. 모든 차가 같지는 않을 수 있습니다.
6. **하이브리드나 트림 값을 일반 값으로 쓰지 않는다 (S)**
   - 이유: 로터와 타이어, 배터리 규격은 트림과 연식마다 다릅니다. 실제 값을 인용하되 "참고용"이라고 적어야 합니다.
7. **이전 세대 자료를 XV70 절차로 쓰지 않는다 (S)**
   - 이유: 머플러와 범퍼 자료는 2011–17년식입니다.
8. **실제 브랜드명과 로고는 쓰지 않는다 (S)**
   - 이유: 하우스 룰입니다. 위 차종명은 연구용입니다. 게임 안에서는 원본 디자인과 가상 이름을 써야 합니다.

## 4. 출처
- [Camry XV70 Wikipedia](https://en.wikipedia.org/wiki/Toyota_Camry_(XV70))
- [Camry 배터리 교체](https://www.paulstravelpictures.com/2018-2022-Toyota-Camry-12V-Automotive-Battery-Replacement-Guide/)
- [Camry 앞 패드](https://www.paulstravelpictures.com/2018-2022-Toyota-Camry-Front-Brake-Pads-Replacement-Guide/index.html)
- [iFixit 앞 패드·로터](https://www.ifixit.com/Guide/How+To+Replace+the+Front+Brake+Pads+and+Rotors+on+Your+2018%E2%80%932024+Toyota+Camry/185984)
- [iFixit 교류발전기](https://www.ifixit.com/Guide/How+To+Replace+the+Alternator+in+Your+2018%E2%80%932024+Toyota+Camry/185987)
- [Camry 휠 토크](https://ownerspecs.com/toyota/camry-xv70-2018-2024/torque)
- [CarConnection Camry](https://www.thecarconnection.com/specifications/toyota_camry_2018)
- [CarBuzz Camry](https://carbuzz.com/cars/toyota/camry/2018/specs-and-trims/)
- [wheel-size Camry](https://www.wheel-size.com/size/toyota/camry/2023/)
- [Camry 머플러 (2012–17)](https://www.go-parts.com/garage/muffler-toyota-camry-2012-2017)
- [Camry 범퍼 (2011–17)](https://www.1aauto.com/how-to-remove-bumper-cover-2011-17-toyota-camry/video/51758)
- [Camry 헤드라이트 (2012–17)](https://www.youcanic.com/replace-headlight-assembly-toyota-camry-2012-2017/)
- [Camry 범퍼 틈](https://www.go-parts.com/garage/bumper-filler-panel-toyota-camry-2018-2025)
- [Honda 사양](https://owners.honda.com/vehicles/information/2018/Accord%20Sedan/specs)
- [CarConnection Accord](https://www.thecarconnection.com/specifications/honda_accord_2018)
- [Autoweb Accord](https://www.autoweb.com/honda/accord-sedan/2018)
- [DriveAccord 퓨즈박스](https://www.driveaccord.net/threads/how-do-you-open-10th-gen-fuse-box.511698/)
- [CarsGuide Sonata](https://www.carsguide.com.au/hyundai/sonata/car-dimensions/2020)
- [Auto123 Sonata](https://www.auto123.com/en/new-cars/technical-specs/hyundai/sonata/2020/base/preferred/)
- [Altima 배터리](https://parts.nissanusa.com/v-2019-nissan-altima--sr--2-0l-l4-gas/electrical--battery)
- [Altima 뒤 브레이크](https://parts.nissanusa.com/v-2019-nissan-altima--s--2-5l-l4-gas/brakes--rear-brakes)
- [Altima 앞 패드](https://paulstravelpictures.com/Nissan-Altima-Front-Brake-Pads-Replacement-Guide/)
- [Malibu 배터리](https://www.autozone.com/batteries-starting-and-charging/battery/chevrolet/malibu/2018)

## 검색에서 본 자료 (자동 수집)
- [Battery Replacement: 2018 Toyota Camry SE 2.5L 4 Cyl.](https://www.carcarekiosk.com/video/2018_Toyota_Camry_SE_2.5L_4_Cyl./battery/replace_battery)
- [Toyota Camry 12V Automotive Battery Replacement Guide - 2018 To 2022 Model Years - Picture Illustrated Automotive Maintenance DIY Instructions](https://www.paulstravelpictures.com/2018-2022-Toyota-Camry-12V-Automotive-Battery-Replacement-Guide/)
- [How To Replace the Alternator in Your 2018–2024 Toyota Camry - iFixit Repair Guide](https://www.ifixit.com/Guide/How+To+Replace+the+Alternator+in+Your+2018%E2%80%932024+Toyota+Camry/185987)
- [Replace the Battery on a 2019 Toyota Camry](https://howtune.com/articles/567-replace-the-battery-on-a-2019-toyota-camry)
- [2018 Toyota Camry Battery Replacement](https://www.mobilebattery.com/post/2018-toyota-camry-battery-replacement)
- [Toyota Camry 12V Battery Replacement: 2026 DIY Guide](https://autoreviewnest.com/how-to-replace-toyota-camry-12v-battery/)
- [Toyota Camry 1997-2011: How to Replace Battery](https://www.camryforums.com/how-tos/a/toyota-camry-how-to-replace-battery-396984)
- [How to replace the battery 2011-2017 Toyota Camry](https://www.carparts.com/blog/tutorials/toyota/camry/how-to-replace-the-battery-2011-2017-toyota-camry/)
- [DIY Battery Change: Where is Toyota Camry Battery Positioned? - Luffi](https://luffi.net/where-is-toyota-camry-battery-pd1556/)
- [Confirm this item fits](https://www.ebay.com/itm/397016809335)
- [How do you open 10th Gen fuse box?](https://www.driveaccord.net/threads/how-do-you-open-10th-gen-fuse-box.511698/)
- [Fuse Box Diagram Honda Accord (2018, 2019-..)](https://fuse-box.info/honda/honda-accord-2018-fuses)
- [2016-2025 Honda Accord Fuse Box Guide: Decoding Failures, Part Numbers, and Programming](https://www.go-parts.com/garage/fuse-box-honda-accord-2016-2025)
- [Honda Accord 10 Fuse and Relay Boxes](https://bezpiecznikisamochodowe.pl/en/honda-accord-10-fuse-and-relay-boxes/)
- [Fuse Box Diagram Honda Accord Hybrid (2018-2022)](https://fuse-box.info/honda/honda-accord-hybrid-2018-2019-fuses)
- [Honda Accord fuses: complete cabin and under-hood box diagrams by generation with position decoding](https://aboutthecars.com/honda/honda-accord-complete-fuse-box/)
- [The vehicle's fuses are contained in three fuse boxes. The ...](https://techinfo.honda.com/rjanisis/pubs/om/tk0707/TK0707O00397A.PDF)
- [Honda Accord (2013](https://autousermanual.com/blogs/honda-accord-fuse-box-location-diagrams-user-guide-2013-2017/)
- [Honda Accord (1998](https://autousermanual.com/blogs/honda-accord-fuse-box-location-diagrams-user-guide-1998-2002/)
- [Honda Accord (ninth generation)](https://en.wikipedia.org/wiki/Honda_Accord_(ninth_generation))
- [2018-2025 Toyota Camry Front Bumper Gap: A Guide to Failing Support Brackets](https://www.go-parts.com/garage/bumper-filler-panel-toyota-camry-2018-2025)
- [Easy Replacement Guide: Toyota Camry Replace Headlight Assembly](https://www.youcanic.com/replace-headlight-assembly-toyota-camry-2012-2017/)
- [How to Remove Bumper Cover 2011-17 Toyota Camry](https://www.1aauto.com/how-to-remove-bumper-cover-2011-17-toyota-camry/video/51758)
- [How to Remove Reinstall Front Bumper 2006-11 Toyota Camry](https://www.1aauto.com/how-to-remove-reinstall-front-bumper-2006-11-toyota-camry/video/44579)
- [How to Replace Headlights 2007-09 Toyota Camry](https://www.1aauto.com/how-to-replace-headlights-2007-09-toyota-camry/video/45751)
- [Q&A: 2000 Toyota Camry Headlight Assembly Replacement](https://www.justanswer.com/toyota/18dfy-2000-toyota-camry-new-headlight-assemblies-mounting-assembly.html)
- [How to Replace Headlights 2007-2011 Toyota Camry](https://www.1aauto.com/how-to-replace-headlights-2007-2011-toyota-camry/video/62860)
- [How to Remove a Front Fender From a Toyota Camry](https://www.pullapart.com/video-library/part-pulling-guides/how-to-remove-a-front-fender-from-a-toyota-camry/)
- [How to Remove a Front Bumper From a Toyota Camry](https://www.pullapart.com/video-library/part-pulling-guides/how-to-remove-a-front-bumper-from-a-toyota-camry/)
- [Disc Brake Set For 2016 Chevrolet Malibu Front and Rear 296mm J60 New Model](https://www.ebay.com/itm/355878895379)
- [Batteries - 2016 Chevrolet Malibu](https://www.oreillyauto.com/shop/b/battery---accessories/batteries/31624da3221a/v/a/137393/automotive-car-2016-chevrolet-malibu)
- [Battery for 2017 Chevrolet Malibu](https://www.gmpartscenter.net/v-2017-chevrolet-malibu--l--1-5l-l4-gas/electrical--battery)
- [2018-malibu.pdf - Owners Manual,Owner's Manual](https://cdn.dealereprocess.org/cdn/servicemanuals/chevrolet/2018-malibu.pdf)
- [2018 Chevrolet Malibu Battery Replacement](https://www.autozone.com/batteries-starting-and-charging/battery/chevrolet/malibu/2018)
- [Fuse Box Diagram Chevrolet Malibu (2016-2025)](https://fuse-box.info/chevrolet/chevrolet-malibu-2016-2019-fuses-and-relay)
- [Chevrolet Malibu 12V Automotive Battery Replacement Guide - 2016, 2017, 2018, 2019, 2020, 2021, 2022 & 2023 - Picture Illustrated Automotive Maintenance DIY Instructions](https://www.paulstravelpictures.com/2016-2023-Chevrolet-Malibu-12V-Automotive-Battery-Replacement-Guide/index.html)
- [Front Brakes for 2016 Chevrolet Malibu](https://g.oempartsonline.com/v-2016-chevrolet-malibu--l--1-5l-l4-gas/brakes--front-brakes)
- [Front Brakes for 2016 Chevrolet Malibu](https://www.gmpartsoutlet.net/v-2016-chevrolet-malibu--premier--2-0l-l4-gas/brakes--front-brakes)
- [www.ebay.com](https://www.ebay.com/p/594415482)
- [2023 Toyota Camry — Wheel & Tire Sizes, PCD, Offset](https://www.wheel-size.com/size/toyota/camry/2023/)
- [Toyota Camry (XV40)](https://en.wikipedia.org/wiki/Toyota_Camry_(XV40))
- [Toyota Camry (XV70)](https://en.wikipedia.org/wiki/Toyota_Camry_(XV70))
- [Toyota Camry VIII (XV70) Facelift (2020–2024) — Wheel & Tire Sizes, PCD, Offset](https://www.wheel-size.com/size/toyota/camry/xv70-2020-2024/)
- [Toyota Camry VIII (XV70) [2017 .. 2022] - Wheel Fitment Data and Specs for USA+](https://www.wheel-size.com/size/toyota/camry/xv70-2017-2022/usdm/)
- [Toyota Camry (XV50)](https://en.wikipedia.org/wiki/Toyota_Camry_(XV50))
- [Toyota Camry (XV80)](https://en.wikipedia.org/wiki/Toyota_Camry_(XV80))
- [2024 Toyota Camry - Wheel & Tire Sizes, PCD, Offset and Rims specs](https://www.wheel-size.com/size/toyota/camry/2024/)
- [Toyota Camry XV70 2.5 Hybrid Specs, Performance, Comparisons](https://www.ultimatespecs.com/car-specs/Toyota/116281/Toyota-Camry-XV70-25-Hybrid.html)
- [Technical data of vehicle Toyota Camry VIII (XV70, facelift 2020)](https://www.automoli.com/us/vehicles/toyota/camry/camry-viii-xv70-facelift-2020-9068/)
- [Battery Replacement: 2018 Hyundai Sonata Hybrid Limited 2.0L 4 Cyl.](https://www.carcarekiosk.com/video/2018_Hyundai_Sonata_Hybrid_Limited_2.0L_4_Cyl./battery/replace_battery)
- [Where Is the Starter Located on 2006 Hyundai Sonata V6?](https://www.justanswer.com/hyundai/p5dtm-starter-locatwd-2006-hyundai-sonata-v6.html)
- [Hyundai Sonata - Battery - DIY video guides](https://www.scegliauto.com/en/video/hyundai/sonata/batteria/tutorial/)
- [Replacing the battery in a 2017 Sonata Limited](https://www.hyundai-forums.com/threads/replacing-the-battery-in-a-2017-sonata-limited.670572/)
- [Hyundai Sonata: Repair procedures - Engine And Transaxle Assembly - Engine Mechanical System](https://www.hsguide.net/repair_procedures-27.html)
- [Hyundai Sonata: Radiator. Repair procedures - Cooling System - Engine Mechanical System](http://www.hsguide.net/radiator_repair_procedures-40.html)
- [Where Is Hyundai Sonata Battery: Easy-to-Follow Location Tips - Luffi](https://luffi.net/where-is-hyundai-sonata-battery-pd1178/)
- [Hyundai Sonata: Coolant. Repair procedures - Cooling System - Engine Mechanical System](https://www.hsguide.net/coolant_repair_procedures-38.html)
- [Hyundai Sonata: Engine compartment - Maintenance](https://www.hsguide.net/engine_compartment-942.html)
- [MC 11017341 0001](https://static.nhtsa.gov/odi/tsbs/2025/MC-11017341-0001.pdf)
- [2019 Nissan Altima Battery Replacement Prices & Cost Estimates](https://www.kbb.com/nissan/altima/2019/battery-replacement/)
