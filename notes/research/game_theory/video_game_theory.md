# Video Game Theory — Wrench & Ride 대입 (조사 노트 v0.1, 2026-10-22)

> 목적: 일반 게임 이론을 정리하고 우리 정비소 게임에 대입. `docs/design/game_textbook.md`(H&H 9법칙·노가다 4가지·로블록스 6가지)는 **다시 쓰지 않고** 그 위에 얹음.
> 표시: (확인) = 이번에 검색 결과/페이지에서 직접 본 것. (추정) = 내 해석 또는 근거가 약한 것.
> 출처는 모두 검색 결과에 나온 링크. 원문 책·논문을 끝까지 읽은 건 아님(요약·2차 자료가 많음) → 중요한 결정 전엔 원문 확인 필요.

---

## 1. MDA Framework (Mechanics – Dynamics – Aesthetics)
- 2004년 Hunicke, LeBlanc, Zubek의 논문. 게임을 세 층으로 본다: **Mechanics**(규칙·부품), **Dynamics**(플레이어 입력과 만나 돌아갈 때 생기는 움직임), **Aesthetics**(플레이어가 느끼는 감정). (확인) https://en.wikipedia.org/wiki/MDA_framework · 원 논문 PDF https://users.cs.northwestern.edu/%7Ehunicke/MDA.pdf
- 핵심: 디자이너는 Mechanics부터 위로 짓고, 플레이어는 Aesthetics부터 아래로 느낀다. (확인, 같은 출처)
- 감정 8종: Sensation, Fantasy, Narrative, Challenge, Fellowship, Discovery, Expression, Submission. Fellowship은 거의 멀티플레이 전용. (확인, 검색 요약; 8개 전체는 2차 요약에서 확인) https://aaai.org/papers/ws04-04-001-mda-a-formal-approach-to-game-design-and-game-research/
- 쓰는 법(추정): "원하는 감정"을 먼저 적고, 거기서 거꾸로 규칙을 고르기.

**우리 정비소 게임에 대입하면:** 목표 감정 = Discovery("아하, 원인이다!") + Fellowship(친구와 같이 차 들어올리기) + Expression(내 정비소 꾸미기). 이걸 만드는 Mechanics = 스캐너·부품 구성·두 손 부품·정비소 업그레이드이고, Dynamics = "소리 듣고 → 의심 → 확인 → 고침"의 추리 흐름. 새 기능을 넣을 땐 "어떤 감정 한 개를 돕나?"를 먼저 적고, 못 적으면 뺀다.

---

## 2. Bartle player types + Yee/Quantic Foundry 동기
**Bartle (1996, MUD 연구)**
- 4종: Achievers(목표·보상), Explorers(세계 구석 발견), Socializers(사람 관계), Killers(다른 플레이어와 경쟁·충돌). (확인) https://en.wikipedia.org/wiki/Bartle_taxonomy_of_player_types
- 한계: MUD에 맞춘 모델이고 모든 게임에 맞는다는 비판, 사람은 여러 유형이 섞임. (확인) https://code.tutsplus.com/bartles-taxonomy-of-player-types-and-why-it-doesnt-apply-to-everything--gamedev-4173a (비율 숫자는 출처마다 달라 쓰지 않음)

**Yee 2006 (MMORPG 설문)**
- 동기 3묶음: Achievement(발전·기계 이해·경쟁), Social(대화·관계·팀워크), Immersion(발견·역할놀이·꾸미기·현실 도피). (확인) https://dl.digra.org/index.php/dl/article/download/239/239 · 요약: https://webspace.ship.edu/jacamp/psyberpsych/Gaming_Addiction/motivations.html
- 후속 연구 중 하나: Achievement 위주 플레이가 괴로운 플레이와 더 연결, Social·Immersion은 더 긍정적인 경향. (확인-2차 요약, 연구 하나만 근거) https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2021.743273/epub

**Quantic Foundry**
- Nick Yee 공동 창업. 12 동기를 6묶음(Action, Social, Mastery, Achievement, Immersion, Creativity)으로 정리. 12개 중 Destruction, Competition, Challenge, Fantasy, Discovery, Story는 확인, 나머지 6개 이름은 이번에 열어 보지 못함. (확인 일부) https://quanticfoundry.com/wp-content/uploads/2020/08/GDC-2020-Slides-Player-Segments-Quantic-Foundry.pdf (PDF 글자 추출 실패 → 검색 요약만 근거) · https://gdcvault.com/play/1025742/A-Deep-Dive-into-the

**우리 정비소 게임에 대입하면:** 우리는 Killers가 거의 필요 없는 협동 게임(친구만 입장). Explorers = 이상한 소리의 원인 추리·시대 차 발견, Achievers = 정비소 레벨·복원 등급, Socializers = 두 손 부품·친구 정비소 방문. 세 유형 모두에게 "할 게 있는" 정비소지만, 경쟁(Competition) 동기를 원하는 아이용으로는 Pit Stop 같은 **선택형** 기록 경쟁만 둔다(추정).

---

## 3. Self-Determination Theory (SDT) in games
- Ryan, Rigby, Przybylski 2006: 게임이 끌리는 힘은 **Autonomy(내가 고른다), Competence(잘한다고 느낀다), Relatedness(사람과 이어진다)**를 채워 주는 데서 나온다. 인게임 자율·유능감은 재미·선호·플레이 후 기분 변화와 연결, 멀티플레이 설문에선 세 가지 모두 즐거움과 다음 플레이를 따로따로 예측. (확인) https://repository.essex.ac.uk/7228/ · https://www.rochester.edu/news/printable.php?id=2719
- 후속 모델: Przybylski, Rigby, Ryan 2010 (같은 세 욕구가 끌림과 웰빙을 설명). (확인-검색 요약)
- 주의: CHI 계열 리뷰에서 Relatedness는 연구가 가장 적다고 함. (확인-검색 요약) https://www.frontiersin.org/journals/virtual-reality/articles/10.3389/frvir.2022.847120/pdf

**우리 정비소 게임에 대입하면:** Autonomy = 어느 손님을 받을지·어떤 순서로 점검할지 고르기(정답 한 길 X). Competence = 틀려도 전액 환불·단서가 점점 또렷해져 "내가 알아냈다"를 느끼게. Relatedness = 두 손 부품, 친구가 바퀴 잡아 주기, 단골 손님 이름 기억. 이 셋 중 하나를 깎는 기능(예: 강제 타이머, 혼자서만 가능한 일)은 "틀려도 괜찮아"와 부딪힌다.

---

## 4. Octalysis (Yu-kai Chou)
- 8 Core Drives: Epic Meaning & Calling / Development & Accomplishment / Empowerment of Creativity & Feedback / Ownership & Possession / Social Influence & Relatedness / Scarcity & Impatience / Unpredictability & Curiosity / Loss & Avoidance. (확인) https://yukaichou.com/gamification-examples/octalysis-gamification-framework/
- **White Hat**(위쪽, 의미·성취·창의: 좋은 기분) vs **Black Hat**(아래쪽, 희소·불확실·손실: 압박으로 행동하게 하지만 끝나면 지침). (확인, 같은 출처)
- 주의: 대부분 컨설팅 회사 자료라 "과학적으로 입증" 홍보 문구는 검증 못 함. (확인-검색 요약) https://www.gbl.uzh.ch/quartz/definitions/Octalysis-Framework

**우리 정비소 게임에 대입하면:** White Hat 중심: "마을 사람들을 돕는다"(Meaning), 정비소 레벨(Accomplishment), 정비소 꾸미기·튜닝(Creativity), 내 공구·내 차(Ownership), 친구와 협동(Social). Black Hat 3개(희소·불확실·손실)는 아이 대상이라 **가볍게만**: 시대 차의 "가끔 나타남"(Curiosity)은 OK, 시간 한정 판매·잃을까 겁주기(Scarcity/Loss)는 쓰지 않는다.

---

## 5. Game feel / Juice
**Swink (Game Feel, 2008)**
- 정의: 가상 물체를 실시간으로 조작하는 것 + 연출(polish)로 강조된 상호작용. 요소 6개: input, response, context, polish, metaphor, rules. 입력-반응 루프는 약 0.1초 안. 비판: 정의가 좁고 측정 기준이 없음. (확인) https://en.wikipedia.org/wiki/Game_feel · https://arxiv.org/pdf/2011.09201

**Jonasson & Purho, "Juice it or lose it" (2012)**
- 벽돌깨기에서 늘이고·튕기고·소리를 더해 "살아 있게" 만든 시연. 요지: 최소 입력에 최대 출력. 그림이 허술해도 반응이 없으면 어색하다. (확인-2차) https://gamedeveloper.com/design/video-is-your-game-juicy-enough-

**Vlambeer, "The Art of Screenshake" (Jan Willem Nijman, 2013)**
- 총알 한 발에 소리·탄피·카메라 흔들림·총 반동을 겹쳐 쓰는 예. 조언: 작은 디테일을 넣으라. (확인-2차) https://unwinnable.com/2014/06/16/notes-on-luftrausers/ · https://medienwissenschaft.uni-bayreuth.de/wp-content/uploads/GxD-10-Game-Feel.pdf
- 주의(추정): 화면 흔들림·깜박임은 어린이·민감한 사람에게 불편할 수 있으니 **끄는 설정** 필요.

**우리 정비소 게임에 대입하면:** 볼트 풀 때 렌치 한 바퀴 = 볼트 한 바퀴 + "딸깍" 소리 + 먼지 한 톨(조작감, textbook 4번과 연결). 임팩트 렌치는 "드르륵" 진동, 고친 차 시동 소리가 확 달라지는 순간(최대 출력)에 쓰기. 큰 흔들림은 쓰지 않고 소리·작은 튕김 위주로 "따뜻한" 느낌 유지.

---

## 6. Flow & 난이도 곡선
- Csikszentmihalyi: 몰입의 핵심은 **도전과 실력의 균형**. 곁들이는 조건: 분명한 목표, 즉각 피드백, 통제감, 집중. 모두 필요한 건 아님. (확인) https://www.gamedeveloper.com/design/the-psychological-state-of-quot-flow-quot-and-game-design · https://khoury.northeastern.edu/~lieber/courses/csu670/f08/materials/p31-chen-flow-in-games.pdf
- 단순 균형 모델은 더 복잡: 연구에 따라 "너무 쉬움"보다 "조금 어려움"을 더 즐거워하는 경향. (확인-검색 요약, Abuhamdeh & Csikszentmihalyi 2012)
- Jenova Chen: 플레이어가 흐름 안에 머물도록 선택권을 주는 설계(Flow in Games). (확인) https://cacm.acm.org/?p=1415
- 동적 난이도 조절(DDA)은 편하지만 새 문제도 만든다. (확인-검색 요약) https://www.gamedeveloper.com/design/the-flow-applied-to-game-design

**우리 정비소 게임에 대입하면:** "레벨 오를수록 어려운 차"(프로젝트 방향)를 곡선으로: 쉬움(배터리) → 살짝 어려움(연결·단자 함정) → 쉬운 한 대로 숨 돌리기 → 더 어려움 식 톱니. 막혔을 땐 정답이 아니라 **단서가 더 선명해짐**(DDA를 숨기지 말고 "차가 더 크게 소리 냄"으로 이야기 속에 넣기). 같은 레벨에서도 손님 요청으로 쉬운/어려운 일을 고르게 함(Autonomy).

---

## 7. Interesting Decisions (Sid Meier) & Theory of Fun (Raph Koster)
**Sid Meier**
- "게임 = 흥미로운 선택의 연속." 흥미로운 선택의 조건(2차 정리): 어느 하나가 늘 최고가 아님, 선택지가 똑같이 매력적이진 않음, 알고 고를 수 있음. 의미 없는 결정은 머리만 쓰고 만족이 없다. (확인-2차) https://jesperjuul.net/text/justwhatisit.html · https://www.gamedeveloper.com/design/designing-interesting-decisions-in-games-and-when-not-to- · 문헌 요약 https://www.ybrikman.com/blog/2026/06/18/sid-meier-memoir/
- 비판: 선택이 아닌 즐거움도 많음(Juul). (확인, 같은 첫 링크)

**Raph Koster, A Theory of Fun (2004)**
- 재미 = 패턴을 배울 때 오는 보상. 패턴을 다 배우면 지루, 너무 어렵거나 너무 쉬워 패턴이 안 보여도 지루. 게임은 결과 부담 없이 배우는 곳. 비판(Bogost): 재미만 앞세우는 것. (확인-2차) https://www.shortform.com/summary/a-theory-of-fun-for-game-design-summary-raph-koster · https://www.engadget.com/2012-10-10-gdc-online-2012-raph-kosters-keynote-on-a-theory-of-fun-10-ye.html

**우리 정비소 게임에 대입하면:** (Meier) "배터리 교체냐 오일 점검 먼저냐" 같은 **진단 순서·비용 선택**이 진짜 결정; 항상 정답이 같은 "다음 볼트 누르기"는 결정이 아니라 조작이다(조작은 쉽게, 결정은 흥미롭게). (Koster) 고장 "패턴"(증상 소리·누수 색 → 원인)을 배우는 재미가 핵심 → 차 종류가 늘어도 규칙은 일관, 새 함정은 한 번에 한 개만.

---

## 8. Variable Reward & Hook Model
- 가변 비율 보상(언제 줄지 모름)은 소거에 가장 강하고, 도박(슬롯머신)이 이 방식. (확인) https://courses.lumenlearning.com/waymaker-psychology/chapter/reading-reinforcement-schedules (Skinner 직접 인용은 확인 못 함 → 이름 인용은 (추정))
- Nir Eyal **Hook Model**: Trigger → Action → Variable Reward → Investment. 외부 알림에서 내적 감정 트리거로 옮기는 게 목표. 슬롯머신 비교 비판 있음. (확인-2차) https://concepts.dsebastien.net/concept/hook-model/ · https://amplitude.com/blog/the-hook-model.md
- Eyal의 윤리 체크 "Manipulation Matrix": 내가 쓰고 싶은가 + 삶을 낫게 하는가 → Facilitator/Entertainer/Peddler/Dealer. 대부분 캐주얼 게임은 Entertainer("조심해서 진행"). 판단을 만든 사람 개인에게 맡긴다는 비판. (확인-2차) https://idealgas.substack.com/p/the-manipulation-matrix

**우리 정비소 게임에 대입하면:** 건강한 "가변 보상" = 어떤 차가 올지(가끔 시대 차), 폐차장에서 뭘 발견할지 같은 **발견의 놀라움**(돈 내고 뽑지 않음). Hook의 Investment는 "내 정비소 꾸밈·단골 손님 기억"처럼 만든 만큼 정이 드는 것으로, 로그인 보상 연속 같은 의무감으로는 만들지 않는다. 확률 상품은 아예 안 판다(monetization 기존 결정과 같음).

---

## 9. Loss Aversion, Goal Gradient, Zeigarnik
**Loss aversion (Kahneman & Tversky)**
- 사람은 같은 크기의 손해를 이득보다 약 2배 크게 느낀다고 흔히 요약(정확한 상수 아님). 연속 접속(streak)이 이 심리를 쓰며, 불안·집착을 만들 수 있음. 가상 화폐에도 손실 회피 편향이 나타났다는 석사 논문. (확인-2차) https://uxmag.com/articles/the-psychology-of-hot-streak-game-design · https://harvest.usask.ca/handle/10388/13478 · https://yukaichou.com/gamification-study/core-drive-8-loss-avoidance/

**Goal gradient (Kivetz, Urminsky, Zheng 2006)**
- 커피 10잔 스탬프카드: 목표에 가까울수록 더 자주 삼. 공짜 2칸을 미리 채워 준 카드(12칸)는 더 빨리 완성(중앙값 10일 vs 15일). 첫 보상에 빨리 다가간 사람이 더 빨리 다시 옴. (확인) https://business.columbia.edu/insights/chazen-global-insights/goal-gradient-hypothesis-resurrected-purchase-acceleration · https://business.columbia.edu/sites/default/files-efs/pubfiles/1200/goalgradient.pdf

**Zeigarnik effect**
- 흔한 설명(끝나지 않은 일을 더 기억)은 **재현이 불안정**. 2025 메타분석: 기억 이점은 없고, 중단된 일을 **다시 하려는 경향(Ovsiankina)**은 있음. 인터넷의 "90% vs 30%" 수치는 확인 불가. (확인-검색 요약) https://en.wikipedia.org/wiki/Zeigarnik_effect

**우리 정비소 게임에 대입하면:** (Goal gradient) 정비소 레벨 바와 "이 차 수리 4/6 부품" 진행 막대는 정직하게 보이기 — 첫 레벨은 살짝 빨리 차게 해서 "시작이 반"을 줌(공짜 스탬프식 가속은 낮은 레벨 구간에만). (Zeigarnik→Ovsiankina) 손님 차를 "Finish later" 한 채 두면 다음 접속에서 "Rosa의 차가 기다려요"로 **부드럽게 다시 하고 싶게**(압박·벌 없이). (Loss aversion) 잃는 것은 쓰지 않는다: 손님은 안 떠나고, 틀린 부품은 전액 환불 — 이미 있는 설계 유지.

---

## 10. 유지/복귀 장치 vs 강박 고리, 아이 대상 규칙
- 가변 보상·streak·손실 회피는 "다시 오게 하는" 힘이 큰 만큼 아이에게는 위험. 규제 흐름(확인-검색 요약):
  - FTC–Genshin Impact(2025-01): 확률/비용 오해 소지 루트박스를 어린이에게 판매, 2천만 달러 합의, 16세 미만 부모 동의 없이는 구매 막음. https://www.deceptive.design/articles/genshin-impact-game-developer-will-be-banned-from-selling-lootboxes-to-teens-under-16-without-parental-consent-pay-a-20-million-fine-to-settle-ftc-charges
  - FTC–Epic(2022-12): 아동 개인정보 + 다크패턴 결제. https://mjtsai.com/blog/2022/12/19/epic-settles-with-ftc-over-coppa-complaint/
  - 어린이 단체의 FTC 요청: 확률 팩이 슬롯머신 같다. https://www.videogameschronicle.com/news/15-us-child-advocacy-groups-have-asked-the-ftc-to-investigate-ea-over-loot-boxes
  - UK Children's Code: 15개 기준 중 13번 "Nudge techniques" — 아이가 개인정보를 더 내거나 프라이버시를 낮추도록 유도 금지(참여 시간 연장은 이 검색에서 직접 확인 못 함). https://ico.org.uk/media/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services-2-1.pdf
  - **Roblox 정책**: 돈(Robux, 유료 게임 화폐 포함)으로 사는 랜덤 아이템은 모든 결과와 확률(퍼센트, 합 100%)을 구매 전에 공개해야 함, "Info/Details" 같은 글자 있는 버튼 필요. https://create.roblox.com/docs/en-us/production/monetization/paid-random-items
- 구분(추정): **좋은 복귀 이유** = 하고 싶은 이야기·친구·내 것이 자람. **나쁜 복귀 이유** = 안 오면 잃는다는 겁(손실)·시간 한정·무작위 유료 보상.

**우리 정비소 게임에 대입하면:** 복귀 이유를 "Rosa 차가 기다려요 / 친구가 정비소에 왔어요 / 새로 연 베이" 같은 **즐거운 약속**으로만 만들고, 연속 접속 보너스·시간 한정 세일·유료 랜덤은 두지 않는다. 유료 항목은 확률 없이 "무엇을 사는지 눈으로 보이게". (메모리의 monetization v2 검토 때 이 장 체크리스트로 다시 점검)

---

## 나쁜 강박 고리 피하기 (체크리스트)
- [ ] 안 들어오면 **뭔가를 잃는다**고 겁주는가? (streak 끊김, 곧 사라지는 차) → 있으면 뺀다.
- [ ] 보상이 **돈으로 사는 랜덤**인가? → 쓰지 않는다(쓴다면 Roblox 확률 공개 정책 + 아이 보호 규칙 확인 필수).
- [ ] **시간 한정 압박**(카운트다운 세일·"지금만")이 있는가? → 있으면 뺀다.
- [ ] 플레이를 끝낼 **자연스러운 지점**(차 한 대 출고, 영수증)이 있는가?
- [ ] 아이가 정지해도 **벌이 없는가**? (Finish later, 손님이 떠나지 않음)
- [ ] 화면 흔들림·번쩍임을 **끌 수 있는가**?
- [ ] 친구 초대가 "안 부르면 손해" 식으로 **죄책감을 쓰는가**? → 쓰지 않는다.
- [ ] 같은 보상이 **오래 해도 줄지 않는가**(뒤로 갈수록 쓰레기 노가다가 아닌가)?
- [ ] Eyal 질문: "나(만든 사람)는 우리 아이가 이걸 오래 해도 괜찮은가? 아이의 삶에 도움이 되는가?"
- [ ] 이 장치가 어떤 심리(손실·희소·가변 보상)를 쓰는지 **이름을 붙일 수 있는가**? 이름 붙였는데 "아이에게 말하기 부끄럽다"면 뺀다.

---

## 조사 한계 (정직하게)
- WebSearch 약 20회, WebFetch 2회(Octalysis 페이지는 열어서 확인, Quantic Foundry PDF는 글자 추출 실패). 대부분 이론은 **2차 요약 + 원문 링크**가 근거. 원 논문/책 내용은 직접 끝까지 읽지 않음.
- Zeigarnik은 재현 논란이 크므로 "기억 효과"가 아니라 "다시 하고 싶은 마음"으로만 사용.
- Quantic Foundry 12 동기 전체 목록, Swink 6요소의 세부 정의, 규제의 구체 조항(특히 UK Children's Code의 참여 연장 부분, COPPA)은 더 확인 필요.
