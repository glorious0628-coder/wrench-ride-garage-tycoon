# 중형 세단 (Midsize Sedan) — 베타 손님 차 조사 (wr-carbook, 10-21)

> 이미 프로토 세단의 기준 차라 자세한 건 car_knowledge 시스템 파일(01~11)·parts_quickref·decor_quickref에 있어요. 여기는 **다른 차종과 나란히 비교**하려고 같은 틀로 요약만.
> 환산 1 stud = 0.28 m, 폭 ×1.15 (car_spec §0).

## 1. 대표 실제 차
| 차 (세대·연식) | 길이 × 폭 × 높이 / 휠베이스 (mm) | 구동 | 엔진 배치 | 앞 / 뒤 서스펜션 |
|---|---|---|---|---|
| Toyota Camry XV70 (2018~2024) | 4,880~4,910 × 1,840 × 1,445 / 2,820, 공차 1,480~1,660 kg | FF (AWD 선택) | 가로배치 I4 2.5 L(A25A) / V6 / 하이브리드 | 맥퍼슨 / 더블위시본 [1][7] |
| Toyota Camry XV80 (2025~) | 4,885~4,920 × 1,840 × 1,445 / 2,825 | FF·AWD | 가로배치 I4 하이브리드만 | (확인 못 함) [2] |
| Honda Accord 10세대 (2018~2022) | 4,900 × 1,860 × 1,450 / 2,830 | FF | 가로배치 I4 1.5T·2.0T | 맥퍼슨 / 멀티링크 [3][8] |
| Honda Accord 11세대 (2023~) | 4,970 × 1,860 × 1,450 / 2,830 | FF | 가로배치 I4 1.5T·하이브리드 | (확인 못 함) [3] |
| Nissan Altima L34 (2019~) | 4,901 × 1,850 × 1,447 / 2,825 | FF·AWD | 가로배치 I4 | (확인 못 함) [4] |
| Hyundai Sonata DN8 (2020~) | 4,900~4,910 × 1,860 × 1,445 / 2,840 | FF | 가로배치 I4 | (확인 못 함) [5] |
| Chevrolet Malibu 9세대 (2016~2024 미국 생산 끝) | 4,923~4,933 × 1,854 × 1,455 / 2,830 | FF | 가로배치 I4 | (확인 못 함) [6] |
- 미국 판매: Camry는 **2002년부터 매년 미국 승용차 판매 1위**(1997~2000도) [2'].

## 2. 평균 → stud
| 항목 | 실제 평균(위 7개) | stud | 게임 권장 | car_spec 지금 |
|---|---|---|---|---|
| 길이 | 약 4,915 mm | 17.6 | 17.0~17.6 | 17.0 (4.8 m 기준 — 요즘 세대는 조금 더 김) |
| 폭 | 약 1,852 mm | 6.6 | ×1.15 = **7.6** | 7.6 ✓ |
| 높이 | 약 1,447 mm | 5.2 | +0.6 머리 공간 = 5.8 | 5.8 ✓ |
| 휠베이스 | 약 2,829 mm | 10.1 | 10.0 | 10.0 ✓ |

## 3. 속 구성 — 다른 차종 비교의 '기준'
- 유니바디, 가로배치 엔진 + 왼쪽 트랜스액슬, 앞 맥퍼슨, 뒤 멀티링크/더블위시본, 4바퀴 디스크, 연료탱크 뒷좌석 아래, 스페어 트렁크 바닥 → README·시스템 파일 01~11.

## 4. 흔한 고장
- 고장 카탈로그(fault_catalog)와 시스템 파일 01~11의 ⑤ 표가 그대로 이 차종 기준.

## 5. 겉모양 공통점 / 피할 것
- 섞기 표는 wr-art `notes/research/ref_sedan/index.md`(Camry·Accord·Altima·Sonata·Malibu·K5 6대): 낮고 긴 보닛, 누운 앞유리, 뒤로 흐르는 패스트백 지붕, 가로로 얇은 램프, 큰 아래 흡기구, 옆창 3개 [9].
- 피할 것: Camry 망치머리 C자 램프·벌집 그릴, Accord 가로 검정 그릴판 얼굴 등(같은 파일 '안 가져오는 것' 칸) [9].

## 6. 출처
1. Toyota Camry (XV70) — Wikipedia (정보표) — https://en.wikipedia.org/wiki/Toyota_Camry_(XV70)
2. Toyota Camry (XV80) — Wikipedia (정보표) — https://en.wikipedia.org/wiki/Toyota_Camry_(XV80)
2'. Toyota Camry — Wikipedia ("In the United States, as of 2025, the Camry has been the best-selling passenger car each year since 2002") — https://en.wikipedia.org/wiki/Toyota_Camry
3. Honda Accord — Wikipedia (10·11세대 정보표) — https://en.wikipedia.org/wiki/Honda_Accord
4. Nissan Altima — Wikipedia (6세대 정보표) — https://en.wikipedia.org/wiki/Nissan_Altima
5. Hyundai Sonata — Wikipedia (8세대 정보표) — https://en.wikipedia.org/wiki/Hyundai_Sonata
6. Chevrolet Malibu — Wikipedia (9세대 정보표) — https://en.wikipedia.org/wiki/Chevrolet_Malibu
7. car_knowledge/06_suspension_steering.md (캠리 XV70 정비 매뉴얼: 앞 스트럿, 뒤 스프링·쇼크 따로 + 위 팔) — 이 폴더
8. Honda Accord 2018 제조사 사양(앞 맥퍼슨·뒤 멀티링크) — car_spec §9 링크 https://owners.honda.com/vehicles/information/2018/Accord%20Sedan/specs
9. wr-art ref_sedan 섞기 표 — `notes/research/ref_sedan/index.md`
