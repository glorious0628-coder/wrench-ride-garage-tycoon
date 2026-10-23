# 소리 묶음 — "우리 컴퓨터 안에서 AI 점수 받아도 되는 곳" 다시 조사 (2026-10-22, 조사 도우미)

사용자 말: "소리 묶음 AI 넣어서 같이 골라도 되는 걸로 다시 해줘."
**조사만 했어요.** 구매·다운로드·설치·로그인·메일 보내기는 하나도 안 했어요. 사는 건 사용자예요.
링크는 내가 직접 열어서 글을 읽은 것만 '확인'이라고 적었고, 못 읽은 건 맨 아래 '확인 못 한 것'에 따로 적었어요. 값은 오늘(10-22) 본 값이고 세금·세일로 달라질 수 있어요.
(라이선스 글 인용은 AI 조항이 어디인지 보이게 **짧은 조각만** 영어 그대로 따왔고, 나머지는 쉬운 한국어로 줄였어요. 판단은 아래 '분류 기준'대로 내가 한 거라서 법률 자문은 아니에요.)

---

## 분류 기준 (A / B / C)

우리가 AI를 쓰는 방식(= `tools/sound_judge.py`, 이번에 코드를 직접 읽어 확인): 우리 컴퓨터에서 오픈소스 모델 AST·CLAP을 `from_pretrained(...).eval()`로 **돌려서 점수만** 받음. 학습 코드 없음, 파일을 인터넷 서비스에 올리는 코드 없음(모델 가중치 내려받기만). 점수는 "무슨 소리로 들리나"를 보고 **진짜 녹음 중에서 고르는 데만** 씀.

| 분류 | 뜻 | 우리 방식 |
|---|---|---|
| **A** | AI 얘기가 아예 없음, 또는 CC0처럼 권리를 다 풀어 둠 | **OK** |
| **B** | '학습(training)·AI 개발·생성 AI'만 금지. 분석·분류·점수는 글자상 안 걸림 | **글자상 OK** (왜 그런지 한 줄 + 애매한 점 따로) |
| **C** | AI로 '처리·분석·입력' 자체를 금지(또는 분석 연구를 금지) | **X** |

**B 공통 안전 규칙**(꼭): ① 점수는 **고르기에만** 쓰고, 그 점수·소리 설명을 ElevenLabs 같은 생성 AI 프롬프트에 되먹이거나 "이 소리랑 비슷하게 만들어"에 쓰지 않기(= '비슷한 소리 생성' 금지에 걸림). ② 파일을 GPT·Claude·HuggingFace 서버 등 **남의 AI 서비스에 올리지 않기**(로컬 실행만). ③ 원본 파일을 남에게 주거나 공개 저장소에 올리지 않기.

---

## 한 줄 결론

1. **Sonniss 라이선스는 B예요**(AI '학습'만 금지, 점수·분류는 글자에 없음). 그래서 앞에 추천한 Sonniss 묶음은 **우리 방식으로 써도 글자상 OK**예요. 다만 제목이 "NO AI TRAINING **OR USAGE**"라서 '고르는 데 AI 쓰기'까지 막는 뜻으로 읽힐 여지가 조금 있어요(아래 4번 자세히). 마음이 불안하면 Sonniss에 한 줄 물어보기(메일 주소: 라이선스 페이지에 있는 `timothy@sonniss.com`, **보내는 건 사용자**).
2. **A급(걱정 0)만으로도 꽤 채워져요**: Freesound CC0(오늘 열어서 CC0 확인한 소리 16개) + Stormwave(약관에 AI 조항 없음, 합 $20.95) + Mixkit 무료(AI 조항 없음).
3. **C라서 빼야 하는 곳**: Pro Sound Effects("분석" 자체를 막음), Epidemic Sound(AI 도구에 넣기 금지 + 게임엔 못 씀), Uppbeat(머신러닝 목적 금지). 이미 산 Pizza Doggy도 C(코드에 이미 막아 둠).
4. **새로 알게 된 걱정 하나**: Roblox 이용약관은 "UGC(올린 것)에 대해 Roblox가 머신러닝 학습에 쓸 수 있는 권리를 가진다"고 적혀 있어요. B급 소리를 Roblox에 올릴 때 이게 'AI 학습 금지·제3자에게 권리 주기 금지'와 부딪히는지는 **애매**해요(7번). Sonniss·ASE에 "Roblox 업로드 OK?" 한 줄 물어보는 걸 같이 권해요. A급은 이 걱정이 없어요.

---

## TOP 8 (전부 A 또는 B)

순서 = 추천 순서. ☆ = 공짜, ★ = 사용자가 돈을 내는 것.

| # | 이름 | 값 | 분류 | 주로 채우는 소리 키 |
|---|---|---|---|---|
| 1 ☆ | **Freesound CC0 골라 담기** (소리 16개, 아래 목록) | $0 | **A** | impact·wrench·ratchet·hammerTap·engineStart·engineFail·brakeGrind·ambGarage·ambStreet·receiptPrint·cash drawer |
| 2 ★ | **Stormwave 5개 묶음**(itch.io) | $20.95 | **A** | hoodClose·열쇠·핸드브레이크·와이퍼·engineStart·ratchet·hammerTap·컴프레서·깜박이 루프 |
| 3 ☆ | **Mixkit 무료 효과음** (자동차 카테고리) | $0 | **A** | engineFail('Failed car ignition')·문·열쇠·'Garage pneumatic screwer' |
| 4 ★ | **Sonniss "Tools"** (Airborne Sound) | $36 | **B** | impact·ratchet·hammerTap·wrench·컴프레서(ambGarage) |
| 5 ★ | **Sonniss "Toyota Rav4 2004"** (pinecone-sound) | $25 | **B** | engineStart·engineFail('false start')·열쇠·문·트렁크 |
| 6 ★ | **Sonniss "Car Interiors – 96kHz"** (Patch Hill Audio) | $35 | **B** | 문·와이퍼·경적·**방향지시등 루프**·브레이크 페달·안전벨트 |
| 7 ★ | **A Sound Effect "Auto Repair"** (Sound Ex Machina) | $59 | **B** | 정비소 실제 녹음: 렌치·라쳇 떨어뜨리기·공압 권총·유압·**정비소 배경**(ambGarage) |
| 8 ☆ | **Zapsplat 무료** (또는 Premium £69.99/년) | $0 (크레딧 표기 필요) | **B** | 휠 임팩트 렌치(차고 울림)·보닛 두드림·차·공구 다수 |

### 총액

| 묶음 | 내용 | 값 |
|---|---|---|
| **A만, 완전 공짜** | 1 + 3 (Freesound + Mixkit) | **$0** |
| **A만, 싸게 제대로** | 1 + 2 + 3 | **$20.95** |
| **더 싸게(Stormwave 셋만)** | Petrol Car Engine $1.99 + Ratchet $1.99 + Car Interior $8.99 | $12.97 |
| **추천 구매** | 2 + 4 + 5 (Stormwave 5개 + Sonniss Tools + RAV4) | **$81.95** |
| 더하면 좋은 것 | + 6 Car Interiors $35 (방향지시등·문) | $116.95 |
| TOP 8 전부 | 2 + 4 + 5 + 6 + 7 (1·3·8은 공짜) | **$175.95** |
| 선택 | Sonniss Electric Cash Register $25(영수증은 Freesound CC0로도 됨), Zapsplat Premium £69.99/년 | 따로 |

(Sonniss 값은 오늘 상품 페이지·검색 목록에서 직접 읽은 값. ASE 값은 상품 페이지 $59.00(세금 별도). Stormwave는 itch '이 값 이상' 방식이라 위는 최소값.)

---

### TOP 항목 자세히

**1. Freesound CC0 골라 담기 — A**
- 곳: https://freesound.org/ (CC0 필터). **오늘 소리 페이지 16개를 열어 'Creative Commons 0 1.0' 표시를 확인**했어요.
- 라이선스: CC0 문구 한 조각 — "even for commercial purposes, all without asking permission". CC0는 권리를 다 푼 거라 AI 점수·분류·Roblox 업로드 모두 걸림이 없어요. Freesound 이용약관(https://freesound.org/help/tos_web/)에서도 AI 조항을 못 찾았어요(AI·학습·데이터셋 단어 검색 0건).
- 소리 목록(링크 앞은 https://freesound.org/people/ — 길이는 오늘 페이지에서 읽은 값):

| 소리 키 | 소리 | 링크 | 길이·메모 |
|---|---|---|---|
| impact / wrench | Impact wrench in the open air | jacekksiazek/sounds/397932/ | 앞 조사에서도 확인 |
| impact | Air Impact Wrench | sevenbsb/sounds/349398/ | |
| impact | IMPACT WRENCH | SamuelGremaud/sounds/458855/ | |
| ratchet | Ratchet drill – tighten fast and short | ldezem/sounds/386209/ | |
| wrench | Socket Wrench | xxqmanxx/sounds/147018/ | |
| clank/partDrop | Foley_Object_Toolbox_Metal_Drop_Mono | Nox_Sound/sounds/556648/ | |
| **brakeGrind·brakeSqueal** | Car Brakes sqeak screech squeal stop | WavJunction.com/sounds/456764/ | 11.6초, 효과음 라이브러리 회사(WavJunction)가 올림 — 우리가 못 찾던 소리 |
| **engineFail** | 1983 Volvo 245 starter engagement failure + successful start | nissse/sounds/322974/ | 1분 2초, 헛돌다 걸림 |
| **engineFail** | 1970 VW Bug Engine Cranking 2 | bowlingballout/sounds/579213/ | 8.6초, Zoom H2n 녹음 |
| engineStart | carstart.wav (Scion Xb, 열쇠 소리 포함) | jessestephens/sounds/46918/ | |
| engineStart | Jeep Wrangler Engine Start 1 | Filmscore/sounds/828776/ | |
| **receiptPrint** | cash drawer and receipt | kalisemorrison/sounds/202531/ | 2.3초, 서랍 + 영수증 |
| receiptPrint | epson receipt printer7 | azumarill/sounds/345057/ | 7.4초 |
| receiptPrint | Receipt Printer 01.wav | thepodcastdoctor/sounds/476011/ | 약국에서 녹음 |
| ambGarage | Suburban garage ambience | RavenWolfProds/sounds/503662/ | 1분 |
| **ambStreet** | Suburban Ambience Day (조용한 동네 거리, 차 지나감) | Joedozer/sounds/844313/ | 1분 44초 |

- 주의: 업로더가 아무나라서 품질이 들쭉날쭉. 소리 설명 글에 "Zoom H2n으로 녹음"처럼 적힌 건 실제 녹음으로 믿어도 되는데, 적혀 있지 않은 건 **AI로 만든 소리가 아닌지 설명·이름을 한 번 보기**(Freesound는 올린 사람 자기 신고). 못 찾은 것: **washerWhirr**(와셔 펌프) — 'washer pump' 검색은 압력 세척기·식기세척기뿐.

**2. Stormwave 5개 묶음 — A**
- 곳: https://stormwave-audio.itch.io/ (모든 페이지에 "No generative AI was used" 표시를 직접 봄) · 약관 https://stormwave-audio.com/shop/shop-terms-conditions/
- 5개 = **Car Interior SFX Pack $8.99**(119개: **Car Hood Slam 1-2**, **Putting Keys Into Ignition 1-3**, Removing Keys, **Handbrake Engage/Release**, Wipers 단일·연속, Seatbelt, Folding Car Key Lock/Unlock, Idle With Indicator Loop, 블로어 루프) + **Petrol Car Engine $1.99**(Start-Up 1-2, Idle Loop, Rev 1-4) + **Ratchet Mechanism $1.99**(10개) + **Tool SFX Pack $4.99**(69개: 망치 3종, 전동 드릴, 펜치, 소형 에어 펌프, 용접 불꽃 등 — **임팩트 렌치는 없음**) + **Airbrush SFX Pack $2.99**(17개: **큰 전기 에어 컴프레서 모터 루프 3개 + 공기 빠짐 3개**).
- 더 싼 보조: Warehouse Tools $4.99(스트랩 라쳇 클릭 10여 개), Door And Gate Vol.I $9.99.
- **AI 조항**: 가게 약관에 **AI 조항이 없어요**(전체를 읽음). 허용 범위: "...commercial and non-commercial projects, video games, animations..." 안에 'video games'가 들어 있어요.
- 분류 **A**. 주의: 구매하면 받는 압축 파일 안의 'Sound Effect License Agreement.pdf'(79 kB)는 **사기 전엔 못 읽었어요** — 가게 약관과 같을 것 같은데, 산 뒤 AI 단어가 있는지 한 번만 읽고 점수 매기기. 파일은 16-bit/44.1kHz WAV라 업로드 규격(48kHz 이하)에 그대로 맞아요.

**3. Mixkit 무료 효과음 — A**
- 곳: https://mixkit.co/free-sound-effects/car/ · 라이선스 https://mixkit.co/license/ ('Sound Effects Free License' 창을 직접 열어 읽음) · 약관 https://mixkit.co/terms/
- 자동차 카테고리 제목 직접 확인: Failed car ignition, Car ignition, Car start ignition, Keys moving, Car door slam, Car door close, Garage pneumatic screwer, Car interior on car wash.
- **AI 조항**: 라이선스·약관에서 AI·학습 단어를 못 찾음(약관의 '대량 다운로드·스크래핑 금지'는 봇으로 긁는 얘기라 손으로 한 곡씩 받는 건 해당 없음).
- 로블록스 근거: 라이선스에 "in video games"가 직접 적혀 있음(게임 안 배포·재생 OK, 소리 파일 단독 재배포만 금지).
- 분류 **A**. 주의: **녹음인지 합성인지 몰라요**(제목만 봄, 소리는 못 들음) → '진짜 녹음' 조건은 귀로 확인. 개별 소리 페이지 링크는 못 땄어요(카테고리에서 제목 찾기).

**4. Sonniss "Tools" — B** · https://sonniss.com/sound-effects/tools/ (오늘 값 $36, 250개·5.9GB·96kHz)
- 상품 태그 직접 확인: Impact Wrench·Pneumatic·Ratchet·Air Compressor·Hammer·Drill. 앞 조사에서 트랙리스트로 'Impact Wrench, Pneumatic, Chicago Pneumatic 1/2 inch drive'·'Ratchet, Pneumatic 3/8 drive'·'Air Compressor turning on and running and turning off'를 확인했어요.
- 대신 싼 길: Sonniss **Tools 3**($40, 손 공구: 망치·**소켓 렌치**·스트랩) · **Craftsman Tools Vol. 2**($15, 179개 망치·톱 등 foley) · **Pneuma**($69, 공압 임팩트 렌치 등 338개).
- 분류 **B**(Sonniss 라이선스, 4번 참고).

**5. Sonniss "Toyota Rav4 2004" — B** · https://sonniss.com/sound-effects/toyota-rav4-2004/ ($25, 29개·431MB)
- 오늘 설명 직접 확인: "Engine start/stop/idle tracks. Foley of doors, windows, boot etc." + 정지 엔진 5·foley 7·지나가기 16. 'false start 3.5초'·'점화 키 배럴'은 앞 조사의 트랙리스트 근거.
- 더 싼 보조(전부 B, 가게 설명 직접 읽음): Mini Themes: Car Foley – Seat Ibiza 2019 **$9.99**(문·엔진·실내 foley·경적), Rusty Van **$10**(문 여닫기·엔진), Car Foley Vol. 2 **$19**(문 쾅·시트·안전벨트).

**6. Sonniss "Car Interiors – 96kHz" — B** · https://sonniss.com/sound-effects/car-interiors-96khz-24-bit-stereo/ ($35, 106개·980MB)
- 오늘 설명 직접 확인: "Car interiors, driving, idling, doors, horns, brakes, locks, wipers, directional, emergency brakes, seatbelts." — **방향지시등('directional')** 이 우리 앞 주황 깜박이 소리 후보. (Stormwave Car Interior에도 'Idle With Indicator Loop'가 있어서 겹침 — 깜박이를 둘 다 들어 보고 하나만 사도 됨.)

**7. A Sound Effect "Auto Repair" (Sound Ex Machina) — B** · https://www.asoundeffect.com/sound-library/auto-repair/ ($59, 248개·24bit/96kHz·3.5GB)
- 오늘 설명 직접 확인: "wrenches and ratchets being dropped", "hydraulic machines and servomotors", "pneumatic pistols", "tools and general ambiences of auto repair shops", 엔진 시동·끄기·공회전. 실제 정비소에서 녹음했다고 적음.
- 같은 사이트 비슷한 것(설명만 읽음): **Garage Workshop**(SmartsoundFX, **$59**, 463개: 임팩트 렌치 윙·유압 리프트·공기 펌프 칙), **Toolbox**(BOOM Library, 1,524개, 망치·라쳇·렌치; **값은 페이지가 $0.00으로 잘못 보여서 못 읽음**).
- 분류 **B**.

**8. Zapsplat 무료 — B** · https://www.zapsplat.com/ (이용약관·라이선스 https://www.zapsplat.com/license-type/standard-license/)
- 오늘 검색해 직접 확인: 'impact wrench' 23건(예: "Screwing screws of a wheel with an impact wrench ... reverb of a garage" 여러 개 = 바퀴 너트 조이기), 'car bonnet' 88건(보닛 위 몸 부딪힘·눌림 등 — 열고 닫는 소리와는 달라서 **hoodOpen 전용은 못 찾음**).
- 무료 = MP3만, 다운로드 한도 있음, **"ZapSplat" 크레딧 표기 필요**(게임 설명·크레딧 화면에). Premium = **£69.99/년**(WAV, 크레딧 불필요, 가입 중 받은 건 평생 사용).
- 분류 **B**(약관 5번 금지 목록).

---

## Sonniss 라이선스 원문 확인 결과 (사용자가 따로 물은 것)

- 주소(직접 열어 읽음): **스토어 라이브러리 전체** https://sonniss.com/license/ · **GDC 무료 묶음** https://sonniss.com/gdc-bundle-license/ (v2.0, 2026-08-27 효력). (앞에서 404였던 `sonniss.com/sound-effects-licence/` 말고 이 두 주소가 열려요. 처음 WebFetch는 Cloudflare가 막았고, 내장 브라우저로 열어서 글 전체를 읽었어요.)
- 두 라이선스 모두 **같은 AI 문단**이 있어요. 제목: **"NO AI TRAINING OR USAGE"**. 본문 핵심 조각:
  - "for the purpose of training artificial intelligence technologies" — 이 목적으로 쓰는 것을 금지(소리를 만드는 AI나 비슷한 스타일의 소리를 만드는 AI도 포함한다고 풀어 씀).
  - "developing, training, or enhancing artificial intelligence technologies" — 이 목적으로 소리를 쓰거나 복제하거나 "leverage"하는 것 금지, 제3자에게 그 권리를 sublicense(넘겨주기)하는 것도 금지.
- **분류 = B.** 이유: 본문이 막는 건 **'AI를 학습시키기·개발하기·더 낫게 만들기'** 와 **'소리 만드는 AI'** 예요. 우리는 이미 만들어진 모델(AST·CLAP)을 우리 컴퓨터에서 **돌리기만** 하고, 모델은 한 글자도 안 바뀌고(`.eval()`, 학습 없음), 파일이 어디로도 안 나가요. '분석', '분류', '데이터셋' 같은 말은 문단에 없어요.
- **애매한 점 두 가지(정직하게)**: ① 제목에 'USAGE'(사용)가 있어서 "AI로 사용하는 것 전반"을 막으려는 뜻일 수도 있어요. 본문엔 그런 문장이 없지만 해석 여지는 남아요. ② 본문이 'enhancing(더 낫게 만들기)'까지 막는데, 우리 점수는 모델을 안 바꾸니까 해당 안 된다고 읽어요. **불안하면**: "이미 있는 모델로 점수만 받아 어떤 소리를 고를지 정하는 건 괜찮은가요? 학습·생성·업로드는 안 합니다" 한 줄을 Sonniss(`timothy@sonniss.com`)에 물어보기(보내는 건 사용자). 답 오기 전에는 **Sonniss 소리를 AI에 넣지 않고 귀로만 고르기**가 제일 안전해요.
- 그 외 Sonniss 약관에서 우리와 관계된 것: (c) "games ... interactive projects"에 동기화(영상·게임에 넣기) OK · (e) 프로젝트에 동기화돼 있으면 배포·공연 OK · **(f) 자르기·편집 OK**(96kHz → 48kHz, ogg 변환 OK) · (d) 하드디스크 1개 + 백업 1개, **네트워크 드라이브·서버에 올리기와 남이 받아 가게 하는 건 금지** · 제한 (d) **편집하는 사람이 혼자여야 함**(팀원이 늘면 multi-user 필요) · 출처 표시 X · 평생·무제한 프로젝트.
- GDC 2026 무료 묶음 **트랙리스트(347줄)를 직접 읽었어요**(구글 시트): 정비소에 쓸 건 **거의 없어요** — 공구·임팩트 렌치·라쳇·컴프레서·영수증 **0건**. 쓸 만한 건 SoundBits Cars–Mad Mustang Mercury '차 문 열고 닫기' 1개, 오토바이 시동·열쇠 꽂기 몇 개, 344 Audio 'East Coast America'의 미국 동부 교외 배경(코네티컷 벌레·새), Epic Stock Media 'Public Spaces' 한적한 거리·광장 배경 정도예요. → **GDC 묶음은 이번엔 '살 필요 없는 공짜 낚시' 수준**이고, 받는 값(7.47GB)에 비해 얻을 게 적어요. 라이선스는 위와 같은 B.

---

## 분류 표 전체

| 곳 | 라이선스 주소(직접 열어 읽은 것) | AI 조항 (짧은 인용) | 분류 | 게임·Roblox OK 근거 | 값 |
|---|---|---|---|---|---|
| **Sonniss 스토어** (판매자 전부 같은 약관) | https://sonniss.com/license/ | "for the purpose of training artificial intelligence technologies" | **B** | (c) games·interactive, (e) 동기화된 배포. Roblox 직접 언급 없음 | 라이브러리마다($10~) |
| **Sonniss GDC 무료 묶음** | https://sonniss.com/gdc-bundle-license/ | 위와 같음 | **B** | 같음 + "Games, films... all count" | $0 |
| **BOOM Library** (Quiet Planet 포함 단일 사용자) | https://www.boomlibrary.com/terms-conditions-regular/ | "AI/ML Training: Developing or training Neural Networks, Artificial Intelligence, or Machine Learning models." (금지 목록 3번) | **B** | "video games" 직접 적힘, 단 소리를 다른 것(음악·영상)과 섞어 써야 함 | 비쌈(수십~수백 달러) |
| **A Sound Effect (ASE)** 판매자 다수 | https://www.asoundeffect.com/license-agreement/ | "training, improving, or developing any Neural Networks (NN), Artificial Intelligence (AI)" (금지 3번) | **B** (※ 첫머리에 'unless explicitly stated'라고 적혀 있어서, 판매자가 따로 약관을 붙인 상품은 다를 수 있음 → 살 때 그 상품 페이지 확인) | 2.b "video games" 직접 적힘, 소리판 앱·soundboard 금지 | 라이브러리마다 |
| **Soundsnap** | https://www.soundsnap.com/license | "train, develop, or improve machine learning, artificial intelligence, or similar automated systems" | **B** (구독) | "Creative Works" 정의에 video games·applications | 6개월 $135 / 12개월 $199 |
| **Zapsplat** | https://www.zapsplat.com/license-type/standard-license/ | "train Artificial Intelligence (AI) or machine learning models of any kind" | **B** | 4번 "Games, apps, and software", 업그레이드 안내에 "Games and all Game Platforms" | 무료(크레딧) / £69.99년 |
| **Epic Stock Media** | https://epicstockmedia.com/licensing/ | "Train machine learning algorithms for commercial use." (YOU CANNOT 목록) | **B** (상업 목적 학습만 금지) | "Commercial Synchronization · All Media" | 묶음이 비쌈($249~$1,649) |
| **Pixabay** 소리 | https://pixabay.com/service/terms/ | 이용약관 '스크레이핑·데이터마이닝 … "including without limitation for machine learning purposes"'. 콘텐츠 라이선스 금지 목록(AI 아님)엔 AI 말 없음 | **B(애매)** — 금지 대상이 '사이트에서 자동 수집'이라 손으로 받은 파일을 로컬 분류는 해당 안 된다고 읽음 | 수정·사용 OK, 단독 재판매만 금지 | $0 |
| **Freesound CC0** | https://creativecommons.org/publicdomain/zero/1.0/ + https://freesound.org/help/tos_web/ | CC0: 권리 포기 / 사이트 약관: AI 조항 없음 | **A** | 상업·수정·배포 모두 OK | $0 |
| **Kenney** (Impact Sounds 등) | https://kenney.nl/assets/impact-sounds ('License: Creative Commons CC0' 직접 읽음) | 없음 | **A** | CC0 | $0 |
| **Stormwave** | https://stormwave-audio.com/shop/shop-terms-conditions/ | 없음 (+ itch 페이지 "No generative AI was used") | **A** (itch 압축 파일 안 PDF는 못 읽음) | "video games" 직접 적힘 | $1~ |
| **Mixkit 무료 효과음** | https://mixkit.co/license/ + https://mixkit.co/terms/ | 없음 | **A** | "in video games" 직접 적힘 | $0 |
| **Envato Elements** | https://help.elements.envato.com/hc/en-us/articles/360000628966 | 라이선스 글·User Terms에서 AI 학습·분석 금지 문구 못 찾음 | **A(AI 문구 없음)** — 단 **게임 쓰는 문구도 못 찾음**, 구독 끊으면 새 프로젝트 못 씀 | 확인 못 함 | 구독 |
| **Pro Sound Effects** | https://www.prosoundeffects.com/individual-end-user-license-agreement | 'Audio Research'를 "extracting, processing, and/or analyzing the Licensed Audio Content"로 정의하고 비생성 AI 연구까지 포함, 2.16 "may not use the Licensed Audio Content for the purpose of Audio Research" | **C** | 게임이 'asynchronous(비동기) 사용'이면 별도 Custom Application License라는 문구도 있음 | — |
| **Epidemic Sound** | https://www.epidemicsound.com/policy/pro-subscription/ | "in any third party AI tool" 업로드·사용 금지 | **C** | 허용 매체가 "video and podcast productions"뿐(게임 없음) | 구독 |
| **Uppbeat** | https://uppbeat.io/uppbeat-basic-license | "to train AI models or for the purposes of machine learning" (파일·메타데이터·태그·분류까지) | **C**(애매하지만 '머신러닝 목적'이라 안전하게 C) | 온라인 게임·앱 허용 | 무료/구독 |
| **Pizza Doggy** (이미 산 것) | 이번에 원문은 안 열음 — `sound_judge.py` 첫 줄 주석이 "their license forbids AI input" | AI 입력 금지 | **C** | — | 이미 보유 |
| Roblox 상점 ProSoundEffects·APM | https://create.roblox.com/docs/audio/assets | 해당 없음 | **해당 없음** — 파일을 받을 수 없어서 **AI 점수에 넣을 수 없음**(귀로만 고르기). ID로 게임에서 쓰는 건 앞 조사 그대로 OK | Roblox 공식 | $0 |

---

## C로 빠진 것과 이유

| 곳 | 이유 (쉬운 말) |
|---|---|
| **Pro Sound Effects** | 약관이 '분석(analyzing)·처리·스펙트럼 같은 소리 정보 뽑기'를 'Audio Research'로 부르고, 그걸 **상업·비상업·사내 연구 모두 금지**(2.16). 비생성 AI 연구까지 이름이 올라 있어서 우리 점수 받기는 걸릴 수 있음. + 게임처럼 '동기화 아닌(비동기) 쓰임'은 따로 허락이 필요하다는 글도 있고, 하드디스크 1개·1명만 허용이 엄격. |
| **Epidemic Sound** | 소리를 "제3자 AI 도구"에 올리거나 쓰는 것 금지 + 허용 매체가 '영상·팟캐스트 제작물'이라 **게임엔 못 씀**(Pro 라이선스 글). |
| **Uppbeat** | 소리·메타데이터·태그를 "머신러닝 목적"에 쓰는 것 금지 — 점수 매기기도 '머신러닝 목적'으로 읽힐 수 있어서 보수적으로 C. |
| **Pizza Doggy** | 이미 산 소리. `sound_judge.py`가 경로에 'pizzadoggy'가 있으면 실행을 거부하게 막아 둠. |
| **itch 'heyheythere Vehicle SFX' ($3.99, 226개)** | 라이선스 때문이 아니라 **'AI Disclosure: AI Assisted … Sounds'** 라고 만든 사람이 직접 적음 → AI 소리 = 우리 규칙(진짜 녹음, AI 티 X) 위반. 사지 말 것. |

---

## 소리 키별로 어디서 채우나 (A 먼저)

| 소리 키 | A (걱정 0) | B (글자상 OK) | 못 찾음/메모 |
|---|---|---|---|
| impact · impactBurst · wrench · wrenchTighten | Freesound 임팩트 렌치 3 · 소켓 렌치 | Sonniss Tools · Zapsplat(휠 너트) · ASE Auto Repair/Garage Workshop | |
| ratchet | Stormwave Ratchet · Freesound ratchet drill | Sonniss Tools(공압 라쳇) | |
| hammerTap · clank · partDrop | Stormwave Tool(망치 3) · Freesound 공구함 떨어짐 | Sonniss Tools/Tools 3 · ASE Auto Repair(렌치 떨어뜨리기) | |
| 컴프레서 · ambGarage | Stormwave **Airbrush(컴프레서 모터 루프)** · Freesound 'Suburban garage ambience' | Sonniss Tools(컴프레서 켜짐·돌아감·꺼짐) · ASE Auto Repair(정비소 배경) | |
| hoodOpen / hoodClose | Stormwave Car Interior('Car Hood Slam' 1-2) | Zapsplat(보닛 두드림, 열기 소리 전용은 아님) | **보닛 '열기' 전용 녹음은 못 찾음**(Roblox 상점 ProSoundEffects는 AI엔 못 넣고 귀로만) |
| 차 문·트렁크·열쇠 | Stormwave Car Interior('Putting Keys Into Ignition') · Mixkit | Sonniss RAV4·Car Interiors | |
| engineStart | Stormwave Petrol Car Engine('Start-Up') · Freesound Jeep·Scion | Sonniss RAV4 | |
| **engineFail**(헛돎) | Freesound **Volvo 245 starter failure** · VW Bug cranking · Mixkit 'Failed car ignition' | Sonniss RAV4('false start' — 앞 조사 근거) | |
| **brakeGrind · brakeSqueal** | Freesound **WavJunction 브레이크 끽** | Sonniss Metal Friction($11.99, 내용 못 확인) | 갈리는 'grind'는 없음, 끽 소리 위주 |
| washerWhirr | — | — | **못 찾음**(CC0 검색 허탕. Mixkit에 'Car interior on car wash' 제목은 있음) |
| 방향지시등(깜박이) | Stormwave('Idle With Indicator Loop') | Sonniss Car Interiors('directional') | |
| 와이퍼 | Stormwave Car Interior | Sonniss Car Interiors | |
| ambStreet(조용한 동네) | Freesound **Joedozer 'Suburban Ambience Day'** | Sonniss GDC('East Coast America' 교외 배경)·ASE 비슷한 것 | |
| receiptPrint · 서랍 | Freesound 영수증 프린터 3 · 'cash drawer and receipt' | Sonniss Electric Cash Register($25, Sanyo 오래된 계산대) · Modern Cash Register $17 | |

---

## 7. Roblox 올릴 때 (B 소리용, 중요)

- 올리는 규격(공식 문서 직접 읽음): 48kHz 이하, 20MB·7분 미만, ID 인증 시 30일 2,000개. Sonniss 96kHz 파일은 ffmpeg로 48kHz로 줄여서 올리기(Sonniss (f)가 편집 허락).
- 올린 오디오는 **처음엔 나만 쓸 수 있는 비공개**예요("initially the only one who can view and use"). 하지만 문서에 "sound effects ... can be distributed on the Creator Store"라고도 있으니 **Creator Store에 배포 설정은 절대 켜지 말기**(원본 재배포 금지에 걸림). 긴 배경음은 'song'으로 분류되면 게임 정보 페이지에 자동 표시될 수 있어서(Configure 페이지에서 끌 수 있음) 올린 뒤 확인하기.
- **걱정되는 점(애매)**: Roblox 이용약관에 "Publish한 UGC에 대해 … 머신러닝 모델 학습을 포함한 목적으로 쓸 수 있는 권리를 Roblox에 준다"는 문장이 있어요(https://en.help.roblox.com/hc/en-us/articles/115004647846 직접 읽음). Sonniss류 라이선스는 "AI 학습을 위해 쓰는 것·제3자에게 sublicense 하는 것"을 막아서, **올리는 행위가 거기에 걸리는지는 내가 판단 못 해요**. Sonniss(e)가 "동기화된 프로젝트 안 배포 OK"라서 게임에 올리는 사람이 많긴 한데, 이 문장 때문에 확실히 하고 싶으면 Sonniss·ASE에 "Roblox 비공개 업로드 OK?"를 같이 물어보기. **A급(CC0·Stormwave·Mixkit)은 이 걱정이 없어요.**
- 팀원 문제: Sonniss 제한 (d) "편집하는 사람이 혼자여야 함". 우리 세션(AI)이 파일을 ffmpeg로 자르는 건 사용자 컴퓨터에서 사용자 이름으로 하는 일이라 괜찮다고 읽지만, 사람 팀원이 소리 파일을 만지게 되면 multi-user가 필요해요.

---

## 확인 못 한 것

- **Stormwave itch 압축 파일 안 'Sound Effect License Agreement.pdf'**: 사기 전엔 못 읽음. 산 뒤 AI 단어가 있는지 읽고 점수 매기기.
- **소리가 진짜 녹음인지·좋은지**: 나는 소리를 못 들어요. Mixkit(녹음/합성 불명), Freesound 일부(올린 사람 말뿐)는 귀로 확인해야 해요.
- **Sonniss 제목 'USAGE'의 뜻**, **Roblox 약관 ML 학습 문장과 B급 라이선스의 충돌 여부**: 내가 법률 판단은 못 함(위 7번).
- Sonniss Car Interiors 트랙리스트 전체(앞 조사엔 106개 중 28개 이름), RAV4 'false start' 파일 이름: 이번엔 상품 설명만 다시 읽음.
- **washerWhirr**·브레이크 '갈림(grind)'·보닛 '열기' 전용 녹음: 후보 못 찾음. Sonniss Metal Friction($11.99)은 설명만 읽음.
- **ASE 'Toolbox'(BOOM) 값**(페이지가 $0.00 표시), ASE 'Car Foley'(13대 차 실내 foley) 상품 주소(내 조회에선 404). ASE 판매자별 약관이 다를 수 있음.
- **Iron Audio Tools Vol.1**(itch, $2 CAD) 라이선스 글 없음 · **Audio Elk Foley Sessions** 열어 보지 않음 · **Artlist·Soundstripe** 약관 열어 보지 않음 · **Envato Elements**의 게임 허용 문구 못 찾음.
- Roblox 약관 중 **'Audio Terms of Use'·Creator Terms**의 오디오 특칙(AI 관련)은 못 읽음.
- Pixabay 소리에는 '사용자가 AI로 만든 것(AI-generated 체크)'이 섞일 수 있어서 쓰려면 하나씩 라벨 확인이 필요.

---

## 다음 한 걸음 (제안 — 결정은 사용자)

1. (지금, 공짜) Freesound 16개 중 마음에 드는 것을 사용자가 직접 받기(로그인은 사용자) → 폴더 `art/_bought/freesound_cc0/` → `sound_judge.py`로 점수(A라서 OK).
2. (싸게) Stormwave Car Interior + Petrol + Ratchet $12.97 → 받은 뒤 압축 안 PDF에서 AI 단어 확인 → 점수.
3. (크게, 선택) Sonniss Tools $36 + RAV4 $25 → **먼저 Sonniss에 한 줄 질문(AI 점수 + Roblox 업로드)**, 답 오면 점수 매기기. 답이 없으면 귀로만.
4. `sound_judge.py`에 C급 곳 경로(pizzadoggy 외 pro sound effects·epidemic·uppbeat)도 막는 목록을 넣을지는 사용자·메인이 결정(코드는 안 건드림).
