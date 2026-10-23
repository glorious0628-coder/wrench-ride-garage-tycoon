# wr-carbook 인계 (10-21)

## 노트 목록 (`notes/research/car_knowledge/`, 목차 = README.md)
- README(원리·시스템 지도) · diagrams/(캠리 XV70 정비 매뉴얼 분해도·엔진룸·하체 사진 24장 + index.md)
- 시스템 01 시동·충전 · 02 브레이크 · 03 바퀴·타이어 · 04 냉각 · 05 엔진 · 06 서스·조향 · 07 구동계 · 08 배기 · 09 연료 · 10 전기·조명 · 11 차체·도색
- parts_quickref(프로토 5부품 치수→stud) · decor_quickref(장식 9덩어리 + 엔진룸 색 지도) · history(1886~지금 + era_cars 대조) · glossary(미국 용어↔한국어) · restoration(루프 B) · roster/(베타 차 7종 + README)
- 출처 사이트 요령: 메모리 camry-manual-source (tocamry.com)

## 검수에서 찾았지만 아직 반영 확인 안 된 것 (board에 적음 — 주인이 고칠 것)
- wr-design fault_catalog: 압력 시험 = 바늘 떨어짐(김 X) · BAT_OLD '배터리 경고등' → 발전기 단서 · Strut 'Clunk' → 스태빌 링크 · Headlight 전구/범퍼 · Oil 경고(빨강 부족 / 흰 Maintenance Required) · 도색 클리어(반영됨 확인)
- wr-design era_cars: 1번 Muffler 없음 → Benz엔 소음기 · Benz 조향 손잡이 레버 · 작은 것 4건(history §5)
- wr-design flip_loop: 타이틀 도장 칸 · 녹 '자리' 단서 · 녹 구멍 = 잘라 용접 + 에폭시 · 즉시 판매 튜닝 보너스 0 · 침수차 바로 시동 = 함정
- wr-design car_spec: 배터리 놓는 방향(사진상 긴 쪽 앞뒤·단자 안쪽 — 확인 권장) · 장식 앞 덮개판·인젝터 8·마운트 4 · 뒤 Strut 분리 · 베이 크기(하이루프 밴)
- wr-dev Locale: 과열 대사 '잠깐 달리다가' · 'Scanner' 이름 · 머플러 진단 문구 둘로
- 메인(3D): 허브 스터드 5·먼지 가림판·마모 탭·받침대(넘김 완료) · **꼬리관 축 → 차 뒤로 곧게** · 배터리 통기 캡 6

## 다음 할 일
1. 엔진룸 장식 3D 나오면 검수(decor_quickref 기준) → board "wr-carbook → 메인(3D)".
2. board의 "→ wr-carbook" 질문 답하기.
3. 위 미반영 목록이 고쳐졌는지 다음 판에서 확인.
4. (확인 못 함) 남은 것: 공임 시간 대부분, A25A 엔진 겉치수·압축 기준, 배터리 정확한 그룹(연식별).
