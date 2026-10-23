# Tycoon / Simulator / Incremental 설계 이론 (Wrench & Ride 대입)

> 조사일 2026-10-22. 기존 `docs/design/game_textbook.md`(9법칙 + 노가다 4가지 + 로블록스 6가지)를 **복사하지 않고 그 위에** 쌓은 노트.
> 표시: **(확인)** = 링크를 열어 읽었거나 검색 결과에서 직접 본 것 / **(추정)** = 내 생각.
> 출처가 3rd party(블로그·가이드)면 따로 적음. 숫자는 대부분 "공식 아님". 긴 인용 없음.
> 검색·열람 약 25회. RDC 발표 영상은 못 찾음(아래 "더 알아볼 것").

---

## 1. 핵심 루프: fix -> money -> upgrade

- 증분(incremental) 게임 = 반복 행동이나 자동화로 자원을 쌓고, 진행이 점점(보통 지수적으로) 빨라지는 장르. 압박이 적고 실패 상태가 없고, 피드백이 자주 오고, 작은 업적이 규칙적으로 보상을 줌 (확인) — [Wikipedia: Incremental game](https://en.wikipedia.org/wiki/Incremental_game)
- 로블록스 tycoon 가이드(3rd party)의 공통 조언: 초반 업그레이드는 싸고 효과가 크게, 후반은 모아야 살 수 있게, 베테랑용 rebirth 루프 추가 (확인, 공식 아님) — [creation.dev 등 검색 결과 묶음](https://www.creation.dev/glossary/tycoon)
- 경제는 **faucet(돈이 들어오는 곳)** 과 **sink(돈이 나가는 곳)** 로 점검. faucet이 많으면 인플레이션(노력의 가치 하락), sink가 많으면 답답함. 후반 남는 돈을 흡수할 새 sink를 업데이트로 계속 추가하는 게 흔한 방법 (확인, 실무 블로그 수준) — [Yu-kai Chou 분석](https://yukaichou.com/gamification-study/economy-design-framework-axie-infinity-collapse/), [Unity 게임 경제 가이드](https://unity.com/resources/game-economy-design-guide)
- 우리 게임은 루프가 **두 개**(손님 수리 / 복원·매매). 두 루프가 같은 돈 faucet이면서 **서로 다른 sink**(공구·베이·부품 구매, 복원용 차 구입)를 가져야 인플레이션이 덜함 (추정).

**우리 정비소 게임에 대입하면:** "고침 -> 돈 -> 공구/베이 업그레이드" 한 바퀴를 3~6분으로 짧게 두고, 돈이 나가는 곳(sink)을 업그레이드 / 부품 구입 / 폐차 감정 구매 세 갈래로 미리 지도에 그려 두기(econ_sim에서 faucet 대비 sink 비율 표로 점검).

---

## 2. 성장 곡선: 지수 vs 다항식, 비용 스케일링

- 고전 공식: n번째 구매 비용 = 기본비용 x 성장률^(가진 개수). 예) AdVenture Capitalist 레모네이드 가판대는 성장률 1.07 (확인) — [The Math of Idle Games, Part I](https://www.gamedeveloper.com/design/the-math-of-idle-games-part-i)
- Cookie Clicker 건물은 성장률 1.15로 분석됨 (확인) — [Demaine 외 논문](https://erikdemaine.org/papers/CookieClicker_JCDCGGG2017/paper.pdf)
- 핵심 구조: **비용은 지수적, 생산은 선형/다항식**. 지수는 결국 어떤 다항식보다 커져서, 초반엔 생산이 비용을 쉽게 따라가다가 후반엔 비싸지는 느낌이 옴. 균형은 이 격차가 나타나는 시점을 설계로 조절하는 것 (확인) — [Part I](https://www.gamedeveloper.com/design/the-math-of-idle-games-part-i)
- 변형: 다음 단계가 아래 단계를 "만들어내는" 계단식(미분형) 생산이면 지수에 가까운 성장을 만들 수 있고, 아래 단계가 아주 커지는 모습 자체가 보상 느낌. 공짜 하위 생성기 때문에 직접 구매가 의미 없어지는 문제는 "산 개수" 기준 보너스로 해결 (확인) — [Part II](https://www.gamedeveloper.com/game-platforms/the-math-of-idle-games-part-ii)
- 시작·끝 비용을 정해 놓고 그 사이를 지수로 보간하는 방법(A^(1-x) x B^x)도 개발자 포럼에서 소개됨 (확인, 포럼) — [Positech 포럼](https://forums.positech.co.uk/t/a-new-change-1-09-for-cost-calculations/15761)
- 숫자가 커지면 약어·과학표기가 필요 (확인) — [Wikipedia](https://en.wikipedia.org/wiki/Incremental_game)
- (추정) 우리 게임은 숫자가 지수로 폭발하는 incremental이 아니라 **"정비소 레벨" 계단형 + 차 난이도에 비례하는 수입**이 더 맞음. 달러가 몇 억이 되면 "동네 정비소" 느낌이 깨짐. 레벨 N에서 수입 ~ 다항식(예: 난이도^1.5), 업그레이드 가격 ~ 완만한 지수(성장률 1.1~1.2 정도에서 시작해 시뮬레이션으로 조정)처럼, 체감 숫자는 작게.

**우리 정비소 게임에 대입하면:** 돈은 $수천~수십만 범위에서 끝나게 하고, 업그레이드 가격은 "기본 x 1.15^개수" 같은 완만한 지수 + 레벨 문(폐차장 Lv8 등)으로 막아서 숫자 폭발 없이도 "점점 비싸다"를 느끼게 하기.

---

## 3. Rebirth / Prestige

- Prestige = 대부분 리셋하고 영구 배율·화폐를 받는 "New Game+". 다음 판은 비용 곡선을 더 멀리까지 타고 갈 수 있음 (확인) — [Part I](https://www.gamedeveloper.com/design/the-math-of-idle-games-part-i)
- 언제 리셋할지 고르는 것 자체가 전략 요소. 여러 겹 prestige(Realm Grinder)도 있음 (확인) — [Wikipedia](https://en.wikipedia.org/wiki/Incremental_game)
- 개발자 회고들(블로그, 약한 근거): 첫 리셋은 코어 루프를 본 직후 와야 하고(한 회고는 25~35분이 늦었고 15~20분이 낫다고 봄), 리셋 전에 "얻을 보상"을 미리 보여 줘야 손해처럼 안 느껴짐. 자유 리셋은 너무 일찍/늦게 하는 사람이 생겨서 설계된 리셋 일정을 쓰는 사례도 있음 (확인, 단일 사례) — [Doomscroll 2077 회고](https://dev.to/tanishpaul1106/aura-data-and-prestige-designing-the-economy-of-doomscroll-2077-293f), [Gold, Goblins 글](https://funovus.com/blogs/Gold-and-Goblins)
- 로블록스 tycoon 템플릿 예: 리셋 때 돈·공장 초기화, rebirth 횟수 저장, 배율 = 1 + 횟수 x 0.5, rebirth 전용 구역 해금. 고정 선형 배율은 후반 rebirth가 너무 세지는 위험 (확인, 템플릿 가이드 수준) — [검색 결과 요약](https://www.creation.dev/templates/tycoon-template)
- (추정) **정비소 이야기에서 "리셋"은 어색함.** 정비소를 팔고 새로 시작하는 건 "정비소가 자란다" 목표와 반대. 대안: 리셋 없는 prestige — 예) **"체인 정비소 지점 열기"**(새 도시 지점, 처음엔 작은 차부터 다시) 또는 **"명예의 전당 / 마스터 정비사 별"**(영구 소폭 보너스·전시, 정비소는 그대로). 사용자가 monetization v2 / rebirth 도입을 이미 열어 둔 상태라 시험 뒤 결정.

**우리 정비소 게임에 대입하면:** 알파~공개 전엔 prestige를 넣지 않고, 넣게 되면 "정비소를 지점으로 확장(새 지점은 쉬운 차부터 + 영구 평판 보너스)" 형태로 리셋 느낌을 줄이기. 첫 지점 개설은 첫 레벨 문 뒤 15~20분 근처로 가늠(추정).

---

## 4. 해금(Unlock) 속도

- 로블록스 공식: 첫 몇 분에 XP 문턱을 낮춰 빨리 레벨업시키라고 함 (확인) — [Onboarding 문서](https://create.roblox.com/docs/en-us/production/game-design/onboarding)
- 일반 이론: 새 시스템은 한꺼번에 주지 않고, 기술 이정표에 묶어 단계별로 열기 (확인, 블로그 의견) — [itch.io 토론 요약](https://itch.io/t/5446445/feedback-prestige-loop-accelerates-to-endgame-levels-at-3-prestige-points)
- Roblox Creator Hub: 신규 콘텐츠는 "새 테마를 정하고 선행조건/구매로 접근"하게 하라는 조언 (확인) — [Monetization 문서](https://create.roblox.com/docs/en-us/production/monetization)
- (추정) 우리는 "새 도구/베이/차 종류가 열릴 때"마다 작은 축하 + 새 고장 유형 하나를 같이 열어 **해금 = 새 재미 한 조각**이 되게(해금이 숫자 증가만이면 약함).

**우리 정비소 게임에 대입하면:** 레벨업마다 (1) 새 공구 하나, (2) 그 공구가 필요한 새 고장 유형 하나를 짝으로 열어서 "새 공구를 쓰고 싶어서 다음 레벨을 원하게" 만들기.

---

## 5. Flow와 보상 간격 (가변 vs 고정)

- Flow: 도전과 실력이 균형일 때 몰입, 도전이 너무 크면 좌절, 너무 작으면 지루. 하지만 flow는 균형만이 아니라 **분명한 목표와 즉각적인 피드백**도 조건 (확인) — [Flow applied to game design](https://www.gamedeveloper.com/design/the-flow-applied-to-game-design), [Jenova Chen, Flow in Games](https://khoury.northeastern.edu/~lieber/courses/csu670/f08/materials/p31-chen-flow-in-games.pdf)
- Skinner의 변동 비율(variable ratio) 보상은 반응 횟수가 가장 높고 소거가 어려움; 고정 비율/간격은 보상 직후 쉬는 구간이 생김. 다만 쥐·비둘기 실험이라 게임에 그대로 적용은 해석 (확인, 2차 자료) — [Lumen 심리학](https://courses.lumenlearning.com/suny-hvcc-psychology-1/chapter/reading-reinforcement-schedules/), [Psychology Today](https://www.psychologytoday.com/gb/blog/brain-wise/201311/use-unpredictable-rewards-to-keep-behavior-going)
- 변동 보상은 loot box/gacha가 쓰는 원리와 같고, 윤리 쟁점은 "변동성이 사용자를 위한가, 플랫폼 지표만 위한가" (확인, 블로그 수준) — [Variable Rewards 개념 정리](https://concepts.dsebastien.net/concept/variable-rewards/)
- **돈 없이 쓰는 변동 보상 (추정)**: 고장 종류가 매번 조금씩 다름(진단 추리의 "아하!"), 팁 금액이 손님 기분에 따라 다름, 폐차장에서 가끔 희귀 부품/시대 차 발견. 이건 "결과가 놀라운 것"이지 "돈 내고 뽑는 것"이 아니라 윤리 문제가 없음.
- 고정 간격 보상은 일정한 "잔잔한 확인"(영수증, 일일 도구상자)에 쓰고, 변동 보상은 발견·희귀 차에 쓰는 조합 (추정).

**우리 정비소 게임에 대입하면:** 볼트 하나, 부품 하나는 **고정**(항상 소리·반짝), 손님 팁·희귀 부품 발견·시대 차 방문은 **변동**(돈 안 받는 놀람). 유료 뽑기는 쓰지 않기.

---

## 6. 첫 10분 (FTUE)

- 로블록스 공식: FTUE = 처음 몇 분. 컨트롤과 코어 루프를 가르치고, 성공은 D1 retention과 목표 완료로 판단. 플레이어 퍼널로 단계별 이탈 확인, A/B로 "짧은 대사 vs 화살표" 비교. 낮은 XP 문턱, 시작 아이템/화폐량 테스트, 끝에 단기·중기·장기 목표와 "돌아오고 싶게 하는 보상 순간" (확인) — [Onboarding](https://create.roblox.com/docs/en-us/production/game-design/onboarding)
- 로블록스 공식: 들어오고 나가기가 쉬워서 빨리 재미를 줘야 하고, 길고 글 많은 튜토리얼은 이탈 원인 (확인) — [Design for Roblox](https://create.roblox.com/docs/production/game-design/design-for-roblox)
- 일반 FTUE 조언(블로그): 30초 안에 동사(할 일)를 손에 주기, 안전 연습 뒤에 긴장, 필요한 때 가르치기, 베테랑은 건너뛰기, 낯선 사람으로 시험 (확인, 블로그) — [bugnet](https://bugnet.io/blog/how-to-design-a-tutorial-that-doesnt-bore-players)
- GDC 2016 Celia Hodent "The Gamer's Brain Part 2: UX of Onboarding"가 대표 발표(영상은 직접 못 봄) (확인, 검색 결과 설명만) — [GDC Vault 안내 검색 결과](https://gdcvault.com/play/1023231/contactUs)
- tycoon 3rd party 기준: 첫 기계 30초 안에 놓기, simulator는 첫 1분 안에 숫자가 올라가기 (확인, 공식 아님) — [rolearn/creation.dev 계열 요약](https://rolearn.dev/guidance/first-week-retention-optimization/)

**우리 정비소 게임에 대입하면:** 튜토리얼 Rosa 차 한 대를 "30초 안에 첫 볼트를 돌리고, 5분 안에 첫 출고 + 정비소 레벨 바가 차는 것"으로 맞추고, 끝에 "내일 올 단골 손님/다음 레벨 문" 같은 돌아올 이유 한 줄 보여 주기. 텍스트 대사 대신 화살표·반짝이 우선(퍼널로 A/B).

---

## 7. 협동 tycoon (친구끼리)

- 로블록스 공식: 친구와 함께 하는 사용자가 많아 소셜을 지원하는 게임이 유리, 친구가 친구를 데려옴, 싱글 게임은 청중 만들기 더 어려움. 파티·거래로 초대를 게임 일부로. 개인 서버는 친구 그룹이 놀 수 있게 싸게 (확인) — [Design for Roblox](https://create.roblox.com/docs/production/game-design/design-for-roblox)
- 다른 장르 사례(참고): Tap Tycoon은 클랜이 투자 팁을 공유해 공동 배율을 키움, Sheikh Tycoon은 20명이 로켓 모듈을 공동으로 짓고 보상 분배, 둘 다 "공유 배율/공동 목표"가 협동 이유 (확인, 소개 페이지) — [Tap Tycoon (Giant Bomb)](https://giantbomb.com/wiki/Games/Tap_Tycoon), [Sheikh Tycoon](https://peerpush.com/p/sheikh-tycoon-idle-game)
- 협동의 설계 질문(추정): 서로 기여가 보이는가(무임승차 느낌 방지), 친구가 늦게 들어와도 따라잡을 수 있는가, 정비소 주인이 없어도 일이 진행되는가(우리는 이미 임시 베이로 대응 — textbook 확인).

**우리 정비소 게임에 대입하면:** "두 손 부품은 둘이 들기", "친구가 와서 같은 차의 다른 쪽(엔진룸 vs 차 밑)을 맡기", "정산에 각자 기여가 이름으로 보이는 영수증"을 넣고, 친구 전용 서버 구조 덕에 낯선 사람과의 갈등은 이미 없음.

---

## 8. 수익화와 설계 (윤리적 vs 착취적)

- 로블록스 Creator Hub 공식: 플레이어가 수익화를 싫어하면 다운보트할 수 있음. 확률 요소는 투명하게. **타이머/약속 메커니즘**(기다려야 하는 것)은 재미가 일찍 끊긴다고 로블록스 사용자가 싫어함. 할인은 진짜여야 하고 가짜 긴급함(리셋되는 카운트다운)·압박 문구는 피하기, 특히 미성년자 대상. tourist(변화·즉시 효과) vs local(장기 혜택, 패스) 구분 (확인) — [Monetization](https://create.roblox.com/docs/en-us/production/monetization)
- **Paid random items 정책**: Robux로(직접·간접) 사는 무작위 아이템은 모든 결과와 정확한 확률(%)을 구매 전 표시, 합계 100%, 운 부스터·pity 시스템도 포함 (확인) — [Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items)
- 어린이 대상 약탈적 수익화 학술 조사: Penn State 연구는 로블록스 개발자들이 알면서 약탈적 설계를 쓰는 경우가 있다고 보고(UI 조작, 심리 전술) (확인, 검색 결과) — [Penn State 논문 페이지](https://pure.psu.edu/en/publications/how-predatory-monetization-designs-manifest-in-child-friendly-vid/)
- 규제 사례: FTC는 Genshin Impact에 2천만 달러 합의(16세 미만 구매 제한), Fortnite에 혼란스러운 버튼 설계로 환불금 부과 (확인, 2차 기사) — [Deceptive Patterns 기사](https://www.deceptive.design/articles/genshin-impact-game-developer-will-be-banned-from-selling-lootboxes-to-teens-under-16-without-parental-consent-pay-a-20-million-fine-to-settle-ftc-charges), [Fenwick 분석](https://fenwick.com/insights/publications/ftcs-aggressive-enforcement-of-childrens-privacy-and-dark-patterns-a-cautionary-tale-and-simple-steps-companies-can-take-to-reduce-risk)
- 3rd party tycoon 조언: 편의형 패스(자동 수집, 2배 돈, 외형)가 잘 팔리고 무료 플레이어를 덜 소외시킴; 이탈이 쌓이니 1주차 유지부터 설계 (확인, 공식 아님) — [Roblox 수익화 가이드 검색 결과](https://medium.com/@andy.a.g/the-complete-guide-to-monetizing-a-roblox-game-in-2026-c5e915a7c778)
- (추정) 윤리 기준 한 줄: "돈 안 낸 친구도 같은 방에서 즐거워야 하고, 어린이가 가격·확률·기간을 오해할 수 없어야 한다." 2x 돈 / 시간 건너뛰기는 **숨은 압박 없이 한 번 사는 영구 패스** 형태, 경쟁적 타이머 구매는 피하기.

**우리 정비소 게임에 대입하면:** 확률 뽑기·한정 카운트다운·"곧 사라짐" 문구는 쓰지 않고, 외형(정비소 간판/작업복)과 편의(공구 단축·돈 2배 같은 영구 패스)만 파는 방향을 monetization v2 검토 때 기준 목록으로 삼기(GPT와 토론).

---

## 9. 로블록스 쪽 발견(Discovery) 지표 — 공식이 말하는 것

**공식으로 확인된 것**
- Home의 "Recommended for You"는 2단계(후보를 engagement·retention·monetization 신호로 추림 -> 사용자별 순위). 신호는 사용자당 평균이라 작은 게임도 불리하지 않음. 가장 영향 큰 신호: 추천을 본 뒤 얼마나 자주 플레이하는지(play-through rate), 얼마나 빨리 떠나는지(bounce, 부정 신호), 돌아오는 날 수, 플레이 시간. co-play(초대·참가·개인 서버 포함), 질 좋은 세션, 소비도 신호 (확인) — [Discovery 문서](https://create.roblox.com/docs/discovery)
- 업데이트·게임플레이 변경은 추천 신호를 움직일 수 있고, 업데이트마다 콘텐츠 품질을 다시 평가함 (확인) — [Discovery 문서](https://create.roblox.com/docs/discovery)
- 2026년 6월 개편: 리텐션 창을 7일 -> **28일**(1일 / 2~7일 / 8~28일 따로)로 늘림. 친구와 함께 오기(co-play)를 장기 가치 신호로 취급. 결과 반영에 최대 4주 걸림. 신호 가중치는 Creator Analytics > Acquisition > Home Recommendations에서 볼 수 있음. 첫 인상(로딩·저사양 기기에서 안정성·썸네일이 약속한 대로)으로 bounce 낮추기 권고 (확인) — [Roblox 뉴스룸](https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox), [DevForum 공지](https://devforum.roblox.com/t/recommended-for-you-algorithm-improvements-that-better-value-long-term-retention/4684575)
- Analytics 문서: **D1 retention과 평균 세션 시간**을 가장 먼저 올릴 것, D7·D30은 장기, payer conversion·ARPPU도 봄. 벤치마크 점수표(DAU 100+ 필요)는 비교용일 뿐 추천에 직접 쓰이지 않음. 고D1·고세션시간 게임이 추천에 더 잘 나온다고 명시. 수치 목표(예: D1 몇 %)는 **공식 문서에 없음** (확인) — [Analytics](https://create.roblox.com/docs/production/analytics), [Acquisition](https://create.roblox.com/docs/production/analytics/acquisition)
- 업데이트 주기: 공식 Monetization 문서는 "주 1회 업데이트를 목표, 최소 월 1회"라고 권고(수익화/라이브옵스 문맥) (확인) — [Monetization](https://create.roblox.com/docs/en-us/production/monetization)
- 소셜: 사용자는 그룹으로 노는 경우가 많으니 그룹 플레이를 지원하라 (확인) — [Strategies](https://create.roblox.com/docs/get-started/strategies)

**공식에 없음 / 확인 못 함**
- 좋아요/즐겨찾기 비율이 추천 순위에 들어간다는 **공식 근거는 못 찾음**. 3rd party는 "좋아요 비율 ~10~12% 가중, 70% 이상 Top Rated" 같은 숫자를 주장하지만 로블록스 문서가 아님 (확인: 공식에 없음) — [rolearn 분석(비공식)](https://rolearn.dev/insights/roblox-game-discovery-algorithm-2026)
- "주 업데이트하면 CCU 40~60% 높음", "48~72시간 신선도 보너스" 등은 3rd party 주장이고 공식 확인 불가 — [rolearn 업데이트 가이드(비공식)](https://rolearn.dev/guidance/update-cadence-content-planning)
- 3rd party의 D1/D7 "좋은 수준" 숫자(tycoon D1 30% / D7 15%, simulator D1 35% / D7 18% 등)는 공식 아님, 참고만 (확인, 비공식) — [rolearn](https://rolearn.dev/guidance/first-week-retention-optimization/)
- RDC 공식 발표에서 tycoon/simulator 디자인을 다룬 자료는 이번 검색에서 못 찾음.

**우리 정비소 게임에 대입하면:** 친구 서버 구조는 공식 신호(co-play)와 잘 맞으니 "친구 초대 -> 같이 한 차 고치기" 순간을 첫 10분에 넣고, 게시 뒤엔 Home Recommendations 대시보드에서 play-through / bounce / D1 / 2~7일 / 8~28일을 주 1회 표로 보며 약한 구간 하나씩 고치기(textbook B-6과 연결).

---

## 10. 업데이트 리듬 (정리)

- 확정: 28일 창이라 **한 번의 큰 업데이트보다 꾸준한 이유-로-돌아옴**이 유리하다고 해석 가능 (추정; 근거 = 위 28일 개편 공지).
- 공식 권고: 주 1회 목표, 월 1회 최소 (수익화 문서). 주제는 업데이트마다 하나로 좁히기.
- 우리 계획(추정): 공개 10/31 -> 이후 "NPC 다양화·얼굴"(memory release-bar) 같은 한 주제씩 월 1~2회부터, 여력되면 매주 작은 콘텐츠(새 시대 차 1대, 새 고장 유형 등).

**우리 정비소 게임에 대입하면:** 공개 뒤 업데이트를 "새 시대 차 한 대 + 새 고장 두 가지" 같은 작은 단위로 쪼개 월 최소 1회, 가능하면 주 1회 낸다.

---

## 더 알아볼 것

1. **Pecorella "Math of Idle Games" Part III** (prestige 주기 균형)와 GDC 2015 "Idle Games: The Mechanics and..." 영상 — Part III는 열어보지 못함. [GDC Vault](https://gdcvault.com/play/1022065/Idle-Games-The-Mechanics-and)
2. **RDC 영상 중 tycoon/simulator 리텐션 발표** — 이번엔 공식 발표 못 찾음; RDC 세션 목록을 직접 확인.
3. **Roblox 공식 사회 기능 문서**(초대·개인 서버·co-play 정의) — 이번 검색은 3rd party만 나옴.
4. **좋아요 비율의 실제 영향** — Creator Analytics 신호 가중치 표(Home Recommendations 탭)로 확인.
5. **리셋 없는 prestige 사례 조사** (체인/지점 확장 등), 그리고 Kongregate Part II의 "산 개수 기준 보너스" 아이디어를 우리 업그레이드에 대입해 보기.
6. **어린이 대상 윤리 점검표**: Penn State SOUPS 2025 논문 본문 읽고 우리 monetization v2 체크리스트로 변환.
7. **econ_sim**으로 위 성장률 후보(1.1 / 1.15 / 1.2)와 faucet:sink 비율을 시뮬레이션.
