# 'AI 티' 점검용 오픈소스 도구 조사 (2026-10-22)

사용자 질문: "AI 티가 나지 않는지 따져봐야 돼. 이거를 위한 오픈 소스 있나 한 번 찾아볼래?"
목적은 **우리 그림·글·소리를 우리가 먼저 검사해서, 기계가 만든 티가 나면 더 잘 다시 만드는 것**(품질 점검)이에요. 탐지기를 속이는 방법(메타데이터 지우기, 노이즈 넣기 등)은 조사도 안 했고 쓰지도 않아요. 팀 규칙대로 **"AI 안 썼어요"라고는 절대 말하지 않아요.**
이 보고서는 **조사만** 했어요. 아무것도 설치·다운로드하지 않았어요. (GitHub·Hugging Face 정보는 각 사이트의 API와 README를 직접 열어 확인했어요. 확인 못 한 건 맨 아래 '확인 못 한 것'.)
관련 앞 보고서: `notes/playtest/wr-gamer/ai_look_report.md` (사람들이 실제로 "AI 같다"고 하는 것 목록).

---

## 한 줄 결론

1. **오픈소스는 있어요.** 그림은 쓸 만한 게 몇 개 있고, 소리는 연구용 모델이 있고, 글은 짧은 문장에서 거의 못 써요.
2. **하지만 탐지기가 잡는 것과 사람들이 "AI 티 난다"고 하는 것은 달라요.** 탐지기는 '어떤 AI 그림 만드는 기계의 지문(픽셀 통계)'을 봐요. 사람들은 손가락·깨진 글자·있을 수 없는 물건·게임과 다른 그림체를 봐요(DevForum 1등 이유가 "로블록스 캐릭터가 아니다"). 그래서 **탐지기는 '보조 경보기'**, 진짜 점검은 팀의 기존 사람 점검(손 확대·글자 읽기·게임 모습 맞는지)이에요.
3. **제일 쓸모 있는 건 '정답을 아는 도구'**예요: 그림 파일 안의 출처 표시(C2PA)를 읽는 c2patool. 우리 `art/` PNG 9,197장 중 **280장에 OpenAI(GPT) 출처 표시가 그대로 남아 있어요**(사실 기록, 아래 0장). 이 280장이 '확실히 GPT가 만든 원본'이라서, **탐지기가 우리 그림체에서 정말 구별하는지 시험하는 정답지**로도 쓸 수 있어요.
4. 추천은 **그림 2개(c2patool + Smaug 탐지 모델) + 글자 깨짐 확인용 OCR 1개, 글은 규칙 검사기(dslop) 1개, 소리는 '먼저 시험해 보고 쓸지 정하기'(SONICS·AudioMosaic)**. 자세한 건 5장.

---

## 0. 우리 환경과 우리 폴더에서 확인한 사실

**우리 PC** (직접 확인): Windows 11, Ryzen 7 260, RAM 약 31 GB, GPU = NVIDIA RTX 5060 Laptop **VRAM 8 GB**. 기존 가상환경 `tools/audio_ai/.venv`는 Python 3.13, **torch 2.14.1 CPU판**, transformers 5.20, librosa, huggingface_hub, scikit-learn이 이미 있음. (GPU로 돌리려면 CUDA판 torch를 따로 깔아야 하는데, 이 새 GPU와 맞는지는 확인 못 함.)
→ 7B(70억)짜리 모델 2개를 쓰는 도구(Binoculars)는 **이 PC에 안 맞아요**(계산값: 70억 × 2바이트 ≈ 14 GB씩).

**C2PA(출처 표시) 사실** — 내가 PNG 파일 앞부분 400 KB에서 `caBX`·`c2pa`·`OpenAI`·`trainedAlgorithmicMedia` 글자만 찾아본 결과(읽기만 함, 서명 검증은 안 함):

| 폴더 | 표시 있는 PNG / 전체 PNG | 뜻 |
|---|---|---|
| `art/thumbs` | 48 / 78 | 가게 썸네일 원본(`final_key/1_A.png` 등)은 표시 있음 |
| `art/ui` | 82 / 120 | UI 그림 상당수가 GPT 원본 그대로 |
| `art/concepts` | 122 / 278 | 콘셉트 그림 |
| `art/_redraw_old_1021` | 21 / 143 | |
| `art/textures` | 7 / 8 | |
| `art/3d` | 0 / 6,469 | Blender 결과물 쪽(폴더 이름만 보고 판단, 내용은 안 열어 봄) |
| `art/_bought` | 0 / 2,051 | 산 소재 |
| **합계** | **280 / 9,197** (모두 OpenAI 표시) | |

- 표시는 **고치거나 줄이거나 다른 이름으로 저장한 파일엔 없어요**: 예 `art/ui/game_icon_512.png`(리사이즈판)·`art/thumbs/final_key/_store_check.png`는 표시 없음, 원본 `game_icon.png`는 있음.
- OpenAI도 "표시는 스크린샷·SNS 업로드 등으로 쉽게 없어지고, **표시가 없다고 해서 AI가 아니라는 뜻이 아니다**"라고 설명해요. 그래서 **표시 없음 = 안전**이 아님. 이건 사실 기록일 뿐이고, 표시를 지우거나 숨기는 일은 안 해요.
- 쓸모: ① 어떤 파일이 'GPT 원본 그대로'인지 목록을 만들 수 있음(= 우리가 손봐야 할 후보), ② 탐지기 시험용 정답지(양성 = 표시 있는 280장, 음성 = `art/3d`의 Blender 결과물).
- 기존 도구 `tools/verify_codex_art.py`(Codex 작업 폴더의 파일과 바이트가 같은지)와 서로 보완돼요: 그쪽은 작업 기록이 남은 것만, C2PA는 파일 자체만 보면 돼요.

**이미 있는 팀 도구(중복 만들지 말기)**: `tools/art_hands_sheet.py`(손 확대 모음), `tools/art_thumb_check.py`(원본 vs 새 그림 비교·스토어 크기), `tools/gpt_image_review.py`·`api_image_review.py`(GPT/Claude 그림 검수), `tools/locale_check.py`(한/영 글 빠진 것), `tools/sound_judge.py`·`music_judge.py`·`sfx_judge_batch.py`(AST+CLAP로 소리 듣기), `tools/sfx_process.py`(앞뒤 페이드·피크 -1 dBTP 맞춤).
**주의(기존 규칙)**: Pizza Doggy 소리 파일은 라이선스상 **AI 입력 금지** → 아래 탐지 모델에도 넣지 않기. `art/_bought`(산 소재)도 같은 조항이 있는지 모르니 **넣지 않기**(정답지 음성은 `art/3d`나 CC0만).

---

## 1. 그림 (그림 탐지기 · 출처 표시 읽기)

날짜 = GitHub는 마지막 push, Hugging Face는 lastModified. ★ = 우리에게 쓸 만한 정도(3 = 지금 시험해 볼 만, 1 = 참고만, 0 = 쓰지 않기).

### 1-1. 출처 표시(C2PA) 읽기

| 이름 | 링크 | 라이선스 | 최근 업데이트 | CPU 가능? | 크기 | 잘 잡는 것 / 못 잡는 것 | ★ |
|---|---|---|---|---|---|---|---|
| **c2patool** | https://github.com/contentauth/c2patool (사용법 `docs/usage.md`) | Apache-2.0 (README: Apache-2.0·MIT 이중) | 2026-10-21 (v0.28.2, 2026-10-08) | 됨. 탐지 모델이 아니라 파일 읽는 도구. Windows용 zip 있음 | 10.9 MB | **잡는 것**: 파일 안에 'GPT가 만들었다' 표시가 있는지, 언제·누가 서명했는지. `c2patool 파일.png`만 치면 JSON으로 나옴. **못 잡는 것**: 표시가 지워진 파일, 표시가 없는 다른 AI 그림 | **3** |

### 1-2. AI 그림 탐지 모델 (점수를 내는 것)

| 이름 | 링크 | 라이선스 | 최근 업데이트 | CPU 가능? | 크기 | 잘 잡는 것 / 못 잡는 것 | ★ |
|---|---|---|---|---|---|---|---|
| **Smaug-AI-Image-Detector** (Abacus.AI) | https://huggingface.co/abacusai/Smaug-AI-Image-Detector | Apache-2.0 (기반 모델 google/embeddinggemma-2도 Apache-2.0 표시 확인) | 2026-10-21 (만든 날 2026-10-16 = **6일 전**) | 카드에 "CPU도 됨"(속도는 모름). 로컬 실행이라 그림이 밖으로 안 나감 | 4.39억 파라미터, 가중치 파일 약 878 MB | **학습에 포함(회사 주장)**: GPT-Image 2, Nano Banana Pro, Midjourney 7, FLUX.2, DALL·E 3, Firefly 3, Seedream 5 등 최신 생성기. 회사 자체 시험: 진짜 Reddit 사진을 AI로 잘못 의심 3.0%, 다른 두 세트 0.4~1.4%. **못 잡는 것(카드 고백)**: 갓 나온 생성기·회피용, "AI로 일부만 고친 사진"은 진짜로 봄. **카드에 일러스트·게임 아이콘 얘기 없음**(사진 위주). 판정선 기본 0.5 | **3** |
| **Community Forensics 프런티어 판**(Thermostatic) | https://huggingface.co/Thermostatic/community-forensics-frontier-detector-2026-08 | MIT | 2026-08-16 | **ONNX(fp16) 파일 있음 → onnxruntime으로 CPU 가능** | 2,180만 파라미터 (fp16 약 44 MB는 계산값) | 학습에 **GPT Image, DALL·E 3, FLUX 1/2, Imagen 3/4, Seedream, Midjourney 5.2, Recraft, Ideogram** 포함, 진짜 그림 쪽에 WikiArt(미술 작품)도 포함. **카드 고백**: "아주 작은 합성 조각, 아주 낮은 해상도에 약함", 모든 공격에 튼튼하진 않음. Smaug 쪽 표에서는 진짜 사진을 세트에 따라 6.6~17.7% AI로 오판. **개인 한 명의 비공식 미세조정**. 판정선 0.65 | **2** |
| **Community Forensics 공식**(OwensLab, CVPR 2025) | https://huggingface.co/OwensLab/commfor-model-384 · 코드 https://github.com/JeongsooP/Community-Forensics | MIT | 가중치 2025-08-28 · 코드 2026-01-06 | 작아서 CPU 가능할 것(직접 실행 안 함) | 2,180만 파라미터 (약 90 MB는 계산값) | 논문: 4,803개 모델이 만든 270만 장으로 학습 → 많은 확산 모델에 잘 일반화. **못 잡는 것**: 최근 생성기 — Smaug 표에서 Reddit 사진 AUC 0.744(약함). 모델 카드엔 사용법이 "나중에 업데이트"라고만 있음(노트북은 GitHub에) | **2** |
| **B-Free** (나폴리 대학 GRIP) | https://github.com/grip-unina/B-Free | 자체 라이선스: "**정보·비영리 목적만, 산업·수익 목적 금지**" | 2026-01-14 | 확인 못 함 | 확인 못 함 | CVPR 2025, FLUX·SD3.5 포함 27개 생성기에서 일반화(논문 주장). **우리는 게임패스 수익이 있을 수 있어 라이선스상 쓰지 않기** | 1 |
| **Effort** (ICML 2025) | https://github.com/YZY-stack/Effort-AIGI-Detection | CC BY-NC 4.0 (README 배지; GitHub는 '없음') | 2025-07-14 | CLIP ViT-L/14 기반, GPU 전제 설명이 많음. 가중치는 **구글 드라이브**(고정 주소 아님) | 확인 못 함 | GPT-ImgEval 보고서에서 **GPT-4o 그림 94.75%**. 폴더째 검사 가능(`training/demo.py --image <폴더>`). 비영리 조건·드라이브 가중치라 번거로움 | 1 |
| **SuSy** (BSC) | https://huggingface.co/HPAI-BSC/SuSy | Apache-2.0 | 2025-03-31 | 가능(CNN) | 1,270만 파라미터 | 재현율: SDXL 79.5, Midjourney v5 73.1, DALL·E 3 88.6, Flux.1-dev 96.5 / **DALL·E 2 20.7, Firefly 40.9**. **'야생' 진짜 사진은 33%만 진짜로 판정(= 오탐 많음)**. 224×224 조각 단위. GPT 그림은 목록에 없음 | 1 |
| **UniversalFakeDetect** (CVPR 2023) | https://github.com/WisconsinAIVision/UniversalFakeDetect | MIT | 2026-08-19 (README는 2023 그대로) | CLIP ViT-L/14 + 선형층, 가능할 것 | 확인 못 함 | **학습 = ProGAN뿐.** GPT-ImgEval 표에서 GPT-4o 그림 75.58%. 옛날 방식 | 1 |
| **NPR** (CVPR 2024) | https://github.com/chuangchuangtan/NPR-DeepfakeDetection | **라이선스 파일 없음** | 2025-05-01 | README 명령이 GPU(`CUDA_VISIBLE_DEVICES`) 전제 | 확인 못 함 | 업샘플링 흔적을 봄. GPT-4o 그림 78.25%(보고서 표 3). 라이선스 없어서 쓰기 애매 | 1 |
| **AIDE** (ICLR 2025) | https://github.com/shilinyan99/AIDE | MIT | 2025-06-04 | CUDA 11.8·PyTorch 2.0.1 요구 → 우리 환경과 안 맞음. 체크포인트는 구글 드라이브 | 확인 못 함 | ProGAN·GenImage 학습. 만든 시험 세트 Chameleon은 학술용·메일 신청 | 1 |
| **CNNDetection** (2020) | https://github.com/PeterWang512/CNNDetection | CC BY-NC-SA 4.0 | 2024-07-26 | 가능 | 확인 못 함 | ProGAN 시절. 제목부터 "for now". GPT-4o 그림 73.81%(CNN-spot) | 0 |
| **DIRE** (ICCV 2023) | https://github.com/ZhendongWang6/DIRE | 없음, **보관(archived)됨** | 2024-09-26 | 확산 모델로 그림을 다시 그려 비교 → 무겁고 GPU 필요 | 큼 | 옛 확산 모델용 | 0 |
| haywoodsloan/ai-image-detector-deploy | https://huggingface.co/haywoodsloan/ai-image-detector-deploy | Apache-2.0 | 2026-08-24 | 가능(느림) | 1.95억 | Smaug 표: 진짜 사진 오탐 1~11%, AUC 0.90~0.95 | 1 |
| Ateeqq/ai-vs-human-image-detector | https://huggingface.co/Ateeqq/ai-vs-human-image-detector | Apache-2.0 | 2025-12-24 | 가능 | 9,290만 | 카드에 "과적합 보고 있음". Smaug 표: 진짜 사진 14~40% 오탐 | 0 |
| Organika/sdxl-detector | https://huggingface.co/Organika/sdxl-detector | **CC BY-NC 3.0** | 2024-09-06 | 가능 | 8,680만 | **SDXL 전용**. 다운로드 많지만(7만) Smaug 표: 진짜 사진 22~44% 오탐 | 0 |
| umm-maybe/AI-image-detector | https://huggingface.co/umm-maybe/AI-image-detector | CC BY 4.0 | 2024-01-03 | 가능 | 확인 못 함 | 카드: Midjourney 5·SDXL·DALL·E 3 샘플이 학습에 없음. Smaug 표 AUC 0.65 | 0 |

### 1-3. 시험 결과 한눈에 (어디까지 믿어도 되나)

- **GPT-ImgEval 기술 보고서**(arXiv 2504.02782, 동료평가 전 보고서) 표 3 — 2025-04 GPT-4o **웹 화면**에서 만든 그림: CNN-spot 73.8 · UnivFD 75.6 · NPR 78.3 · DRCT 88.2 · **Effort 94.8 · FakeVLM 99.6 (%)**. 옛 탐지기는 GPT 그림에 약하고 2025년판은 강했다는 뜻. 단 ① 본문 글("NPR 99%")과 표(78.3)가 안 맞는 곳이 있어 **표만 믿었어요** ② 지금 우리가 쓰는 GPT 이미지 모델 버전과 같다는 보장은 없어요.
- **2602.07814 대규모 비교**(초록만 읽음): 16개 방법·12개 데이터셋·291개 생성기, 최고 평균 정확도 75.0%, **"모두에게 제일인 건 없다"**. Flux Dev·Firefly v4·Midjourney v7은 대부분 탐지기를 속여 평균 18~30%.
- **2606.01050 TextFake**(초록만): **글자가 많은 AI 그림에서 80%를 넘는 방법이 없음**, 글자 렌더링이 좋아지면 탐지기가 더 못 잡음.
- **2608.01258**(GPT Image 2·Nano Banana 2 시험, 초록만): "기존 탐지기가 고화질 생성물에서 성능이 떨어진다."
- **Smaug 표**(회사가 직접 같은 26,070장으로 오픈소스 11개를 비교, 자기 모델이 1등): AUC 0.98 평균. 독립 확인은 못 찾았어요.
- 요약: **사진으로 하는 시험에선 잘 나오지만, 우리 같은 일러스트·아이콘·UI·로블록스풍 그림이 잘 나오는지는 누구도 안 보여 줬어요.** → 우리 정답지로 직접 시험해야 해요(5장).

---

## 2. 글

| 이름 | 링크 | 라이선스 | 최근 업데이트 | CPU 가능? | 크기 | 잘 잡는 것 / 못 잡는 것 | ★ |
|---|---|---|---|---|---|---|---|
| **dslop** | https://github.com/aaazzam/dslop · `pip install dslop` | Apache-2.0 | 2026-06-30 (PyPI 0.2.2, 2026-04-24) | 됨(규칙+통계, 모델 없음) | 아주 작음 | **영어** 글에서 줄표(—), "it's not X, it's Y", 필러 단어, 세 문장 연속 짧음, 문장 길이가 너무 일정함 같은 **AI 말버릇**을 찾음. 못 잡는 것: 한국어, 의미. 별 6개짜리 새 도구 + 규칙이 빡빡해서(예: "not" 금지 옵션) **오탐 많을 수 있음** | **2** |
| slopless | https://www.npmjs.com/package/slopless (npm) | MIT | 2026-10-16 (v0.2.41) | 됨 | 작음 | 같은 종류의 영어 말버릇 규칙 검사(textlint 기반). README는 안 읽음. Node 필요 | 1 |
| defluff | https://pypi.org/project/defluff/ | MIT | 2026-06-22 | 됨 | 작음 | 영어 군더더기·유행어 목록. 문서 안 읽음 | 1 |
| **Binoculars** (ICML 2024) | https://github.com/ahans30/Binoculars | BSD-3 | 2024-05-14 | 코드는 GPU 전제(없으면 CPU). **Falcon-7B + Falcon-7B-Instruct 2개(각 72억, Apache-2.0)** | 모델 2개 합 약 29 GB(계산값). **우리 8 GB GPU·31 GB RAM으로는 안 맞음** | 영어 긴 글에서 강함(논문: 오탐 0.01%에서 90% 이상 — 모델·글 종류 정해진 시험). **README가 직접: "영어 외 언어는 덜 잘함, 사람 감독 없이 쓰지 말 것."** 논문은 우르두·러시아·불가리아·아랍어만 시험(**한국어 없음**), 거기서 "정밀도는 높지만 재현율 낮음". 짧은 글 수치 없음(기본 512토큰 단위) | 1 |
| **Fast-DetectGPT** (ICLR 2024) | https://github.com/baoguangsheng/fast-detect-gpt | MIT | 2026-02-07 | 기본 모델 gpt-neo-2.7B(MIT, 27억, fp16 약 5.4 GB는 계산값)라 GPU 8 GB엔 들어감. 실험은 A100. 권장은 Llama3-8B(승인 필요 모델) | 위 참조 | 영어. `python scripts/local_infer.py`로 문장 넣고 "기계가 쓴 확률 82%" 식으로 나옴. 한국어 검증 없음 | 1 |
| desklib/ai-text-detector-v1.01 | https://huggingface.co/desklib/ai-text-detector-v1.01 | MIT | 2025-02-17 | 4.34억(DeBERTa-v3-large), 가능하나 느림 | | **영어만.** RAID 순위표 1등이라고 카드가 주장(시점 한정). 문서 단위 | 1 |
| jaspai/modernbert-ai-text-detector | https://huggingface.co/jaspai/modernbert-ai-text-detector | MIT | 2026-08-11 | 1.5억, CPU 가능 | | **카드가 솔직함**: 영어만·문서 단위, 오탐 1%에서 잡는 비율 0.845(MAGE)인데 **2025년 생성기 시험에서는 0.126**. "단일 모델은 모든 면에서 튼튼하지 않다" | 1 |
| KatFishNet (ACL 2025) | https://github.com/Shinwoo-Park/katfishnet | **라이선스 없음** | 2026-04-06 | 특징(띄어쓰기·품사 조합·쉼표) + 가벼운 분류기, 가능할 것 | 작음 | **한국어 전용 연구 코드.** 에세이·시·논문 초록으로 시험(README 표 80점대: 에세이 평균 약 83). **게임 UI 글·짧은 글은 시험 안 함.** 한국어 품사 분석기 필요 | 1 |
| dxlabskku/llm-detection-main (EACL 2026) | https://github.com/dxlabskku/llm-detection-main | 없음 | 2026-09-29 | 한 문장 검사하려면 GPT-3.5로 비교 문장을 만듦 → **우리 글이 밖(OpenAI)으로 나감** | | 한국어 비지도 방법. 외부 호출 필요 | 0 |
| Ghostbuster (NAACL 2024) | https://github.com/vivek3141/ghostbuster | CC BY 3.0(LICENSE 파일; GitHub는 '표시 없음') | 2024-05-27 | **OpenAI API 키 필요**(ada·davinci 로그확률) | | 옛 OpenAI 모델에 매여 있어 지금도 되는지 확인 못 함, 글이 밖으로 나감 | 0 |
| roberta-base-openai-detector | https://huggingface.co/openai-community/roberta-base-openai-detector | MIT | 2024-02-19 | 1.25억, 가능 | | **GPT-2 시절(2019) 탐지기.** 요즘 모델 글엔 약함, 영어만 | 0 |
| Hello-SimpleAI/chatgpt-detector-roberta | https://huggingface.co/Hello-SimpleAI/chatgpt-detector-roberta | 표시 없음 | 2023-01-19 | 가능 | | 2022~23 ChatGPT 질문답 글(HC3) 학습, 영어·중국어판만 | 0 |

**짧은 글(UI 한 줄, 3~12 단어)에 대해**: 위 통계 탐지기들은 모두 **문장 하나가 아니라 문단·문서**를 전제로 해요(Binoculars 기본 512토큰, modernbert "문서 단위"). 짧은 UI 글에서 정확도를 보여 준 자료는 하나도 못 찾았어요. → **쓰지 않는 게 맞아요.** 또 다른 연구(Binoculars 논문이 인용)에선 상용 탐지기가 **영어 비원어민이 쓴 글을 48~76% AI로 오판**했어요. 우리는 한국 팀이 영어를 쓰니 **사람이 쓴 영어도 오탐될 수 있어요.**
**한국어**: 쓸 만한 '설치해서 바로 쓰는' 한국어 AI글 탐지 모델은 못 찾았어요(KatFishNet은 연구 코드, 라이선스 없음).

---

## 3. 소리 · 음악

| 이름 | 링크 | 라이선스 | 최근 업데이트 | CPU 가능? | 크기 | 잘 잡는 것 / 못 잡는 것 | ★ |
|---|---|---|---|---|---|---|---|
| **SONICS (SpecTTTra)** (ICLR 2025) | 코드 https://github.com/awsaf49/sonics · 모델 https://huggingface.co/awsaf49/sonics-spectttra-alpha-120s (5초판 `…-alpha-5s`) | **코드·모델 MIT.** 데이터셋은 CC BY-NC 4.0 + "Suno·Udio 경쟁 제품 연구 금지" 조항 (우린 데이터셋 안 씀) | 코드 2025-05-23 · 모델 2025-03-01 | 모델 카드 표의 메모리 0.1~3.9 GB라 가능할 것(직접 실행 안 함) | 파일 68 MB(5초판) / 75 MB(120초판) | **Suno·Udio 노래 9.7만 곡**으로 학습(가짜 4.9만; 가사가 있는 노래가 대부분으로 보임 — 데이터에 'no_vocal'(기악) 열은 있어서 기악이 얼마나 되는지는 확인 못 함). 모델 카드 수치: **120초판 F1 0.88~0.97, 5초판 F1 0.76~0.78(민감도 0.66~0.69 = 가짜 3개 중 1개는 놓침)**. **못 잡는 것**: ElevenLabs 음악·효과음(학습에 없음), 짧은 소리(5초 미만) | **2** |
| **AudioMosaic 미세조정판 + EnvSDD** | 모델 https://huggingface.co/hanxunh/AudioMosaic-vit-b16-finetune-envsdd-tta · 데이터·코드 https://github.com/apple-yinhan/EnvSDD | MIT (코드·모델) | 모델 2026-05-15 · 코드 2026-05-17 | ViT-B/16, CPU 속도는 확인 못 함 | 가중치 343 MB | **효과음·환경음 전용** 탐지기. 4초 조각(16 kHz). 가짜 = AudioGen·AudioLDM·AudioLDM 2·TangoFlux·AudioLCM. 모델 카드: 못 본 생성기+못 본 데이터에서도 EER 4.5%(낮을수록 좋음). **ElevenLabs·Stable Audio는 목록에 없음**(논문 확인). 우리 효과음 길이 중앙값 약 1.1초라 **4초로 늘려야** 함(영향 모름) | **2** |
| Cros Vila 등 CLAP 탐지기 (TISMIR 2025) | https://github.com/lcrosvila/ai-music-detection | 표시 없음 | 2026-08-28 | 가능(CLAP 임베딩+Essentia) | 작음 | Suno·Udio 2만 곡+MSD 1만 곡. 논문: 상용 탐지기가 **22.05 kHz로 리샘플만 해도 속음.** 데이터 다운로드 링크는 아직 "TODO" | 1 |
| Spot-if-AI | https://github.com/QosmoInc/Spot-if-AI | MIT | 2026-03-25 | 브라우저 안에서 SONICS를 ONNX로 돌림(Spotify 웹 플레이어용 크롬 확장) | | SONICS를 ONNX로 바꾸는 참고 코드. 그 자체로 우리에게 필요한 건 아님 | 1 |
| Audio Sleuth | https://pypi.org/project/audio-sleuth/ | **확인 못 함** | 0.0.2 (날짜 확인 못 함) | 확인 못 함 | | "오디오 생성물 탐지 오픈소스 프레임워크"라는 소개만 봄 | 1 |
| AASIST / ASVspoof 계열 | https://github.com/clovaai/aasist | MIT | 2023-06-25 | 가능 | | **사람 목소리 위조 탐지용.** 우리는 목소리가 없어서 해당 없음. 효과음엔 잘 안 맞는다고 SynSFX 소개 글에 나옴 | 0 |
| SynSFX (효과음 데이터 논문) | https://arxiv.org/abs/2607.04848 | 확인 못 함 | 2026-07 논문 | | | 효과음 4.3만 클립(가짜 2.6만) 데이터 논문. 코드·데이터 링크를 못 찾음 | 0 |
| (참고) ACRCloud · Pex · Sightengine | — | 유료·비공개 | | | | ElevenLabs까지 잡는다고 주장하는 **상용** 서비스. 오픈소스 아님 → 이번 조사 대상 아님 | — |

**우리 소리는 어떤가**: 음악 루프 8개(`art/music/*.ogg`)가 58~84초, 48 kHz 스테레오, 기악. 효과음 616개 중앙값 1.1초. 그리고 **우리 소리는 ElevenLabs가 만든 거라서, 위 두 모델이 학습 때 본 적 없는 생성기**예요. 그래서 "잡힌다/안 잡힌다"를 **우리 소리로 먼저 시험**해야만 쓸지 정할 수 있어요(정답을 알고 있어요: ElevenLabs로 만든 것 = 양성, CC0 소재 `art/sfx/cc0`·Kenney = 음성).
이미 팀에 있는 `sfx_process.py`(앞 3 ms 페이드인·뒤 30 ms 페이드아웃·피크 맞춤)가 플레이어가 실제로 지적하는 소리 문제(딸깍·크기 들쭉날쭉)를 막고 있어요. 이게 탐지 모델보다 더 직접적이에요.

---

## 4. 'AI 티' 점검 꼼수 도구 (탐지기 말고 눈에 보이는 결함 찾기)

| 하는 일 | 도구 | 링크 | 라이선스 | 최근 업데이트 | CPU? | 잘 되는 것 / 안 되는 것 | ★ |
|---|---|---|---|---|---|---|---|
| **깨진 글자 찾기** (그림 속 글자를 OCR로 읽어 우리가 넣으려던 글과 비교) | **RapidOCR** | https://github.com/RapidAI/RapidOCR · PyPI `rapidocr` 3.10.0 | Apache-2.0 | 2026-10-22 (PyPI 2026-10-08) | 됨(ONNX, 순수 파이썬 wheel) | 간판·로고·썸네일 글자. 한국어 모델은 프로젝트가 지원한다고 알고 있으나 **직접 확인 못 함**. 장식 글씨체·비스듬한 글자는 OCR이 못 읽어도 사람이 읽는 경우가 있음(오탐) | **3** |
| 〃 | PaddleOCR | https://github.com/PaddlePaddle/PaddleOCR | Apache-2.0 | 2026-09-16 (v3.7.0) | 됨(Windows용 paddlepaddle 있음) | 더 정확한 편이라고 알려짐(직접 비교 안 함), 설치가 무거움 | 2 |
| 〃 | Tesseract (+pytesseract) | https://github.com/tesseract-ocr/tesseract | Apache-2.0 | 2026-10-20 | 됨 | Windows에 프로그램을 따로 설치해야 함. 큰 글씨·깨끗한 배경엔 OK, 장식 글씨엔 약함 | 2 |
| 〃 | EasyOCR | https://github.com/JaidedAI/EasyOCR | Apache-2.0 | 2025-12-05 (PyPI 2024-09) | 됨(이미 있는 torch CPU 사용) | 오래된 편 | 1 |
| **손가락 이상 찾기** | MediaPipe Hand Landmarker | https://github.com/google-ai-edge/mediapipe | Apache-2.0 | 2026-10-22 | 됨 | **쓸모 제한**: 손을 찾으면 항상 21점을 돌려줘서 **손가락 개수가 틀려도 안 틀려 보임**, 실사 손 위주라 **만화·로블록스·레고풍 손은 아예 못 찾음**(내 추론 — 문서 근거 + 직접 시험 안 함). 맞는 전용 오픈소스는 못 찾음 | 1 |
| 〃 | **기존 `art_hands_sheet.py` + 눈 확대** | `tools/art_hands_sheet.py` | 우리 것 | | 됨 | 팀 규칙대로 "검수 질문 첫 항목 = 손". 이게 지금 최선 | **3** |
| **글자 품질 점수** | TIQA (논문) | https://arxiv.org/abs/2603.07119 | 확인 못 함 | 2026-03 | | 생성 그림 속 글자 품질을 사람 판단과 맞춰 매기는 모델 논문. 코드·가중치 공개 여부 못 봄 | 0 |
| **게임 그림체와 맞는지** (제일 큰 불만 1위 = "로블록스답지 않다") | open_clip 등으로 **우리가 직접 짤 것** | https://github.com/mlfoundations/open_clip | MIT | 2026-02-27 (v3.3.0) | 됨 | **'기성 도구'가 아니라 내 아이디어(검증 안 함)**: 게임 안 화면 캡처들과 새 그림을 같은 이미지 모델로 숫자(임베딩)로 바꾸고, 새 그림이 게임 화면 무리에서 얼마나 먼지 순위를 매겨 "게임과 제일 다른 순" 목록을 만듦. 코드 30줄 안팎 예상. `art_thumb_check.py`(원본 vs 새 그림 비교)와 같은 역할의 전체 버전 | 2 |

---

## 5. 추천 파이프라인 (작게 시작)

### 5-0. 원칙

1. **탐지기 점수는 '다시 볼 목록'을 만드는 데만 써요.** 점수가 낮아도 "합격"이 아니고, 높아도 "실패"가 아니에요. 합격 기준은 팀의 사람 점검(`ai_look_report.md` 2장: 손·깨진 글자·있을 수 없는 물건·게임 모습과 맞는지·실제 크기에서 읽히는지).
2. **탐지기를 속이려고 그림을 망가뜨리지 않아요**(노이즈·재압축·표시 지우기 없음). 목표는 그림을 **더 잘 다시 만드는 것**이에요. "AI 안 썼다" 말하지 않기.
3. 전부 **로컬에서만 실행**해요. 공개 전 그림을 Hugging Face 데모 Space 같은 곳에 올리지 않아요. 다운로드한 파일은 믿을 수 없는 코드로 보고(특히 Smaug는 저장소에 파이썬 파일 `smaug_image_detect.py`가 들어 있음) **읽어 본 뒤**, 새 빈 폴더에 받고, `py -I`로 실행해요. (모든 다운로드는 메인/사용자 허락 뒤에.)
4. 정답지 규칙: 양성 = C2PA 표시가 있는 280장(GPT 원본 확정), 음성 = `art/3d`의 Blender 결과물. `art/_bought`·Pizza Doggy는 넣지 않아요.

### 5-1. 그림 — 설치 후보 2개 + 글자 확인 1개

| 순서 | 도구 | 하는 일 | 크기 | 실행 방법 |
|---|---|---|---|---|
| ① | **c2patool** | 'GPT 원본 그대로' 파일 목록 | 10.9 MB zip | `c2patool 그림.png` (폴더는 PowerShell `Get-ChildItem art -Recurse -Filter *.png` 반복, 표시 없는 파일은 오류 메시지가 나오니 그걸 '없음'으로 처리). 설치 전엔 0장의 바이트 스캔(부록)으로 같은 목록을 만들 수 있음 |
| ② | **Smaug** (+ 필요하면 Thermostatic) | AI 가능성 점수 0~1 | 878 MB (Thermostatic 약 44 MB 계산값) | 모델 카드 예시: `det = SmaugImageDetect.from_pretrained(path); det(["a.png","b.png"], batch_size=8)` → 점수 목록. 폴더 전체는 파일 목록 만들어 넘기기. 오래 걸리면 `crops=1`(카드: 3배 빠름) |
| ③ | **RapidOCR** | 그림 속 글자 → 우리가 넣으려던 글 목록과 비교, 모르는 단어·못 읽은 곳 표시 | 작음 | 썸네일·로고·간판·UI 글자 그림에만. 읽은 글이 기대한 글과 다르면 '깨진 글자 의심' |

**임계값 (시작값, 우리 데이터 시험 전)**
- c2patool 표시 있음 → "GPT 원본 그대로" 표시. **게임·가게에 들어가는 파일이면 4가지 사람 점검(손·글자·있을 수 없는 물건·게임 일치)을 반드시** 하고, 필요하면 `gpt_image_review.py`로 GPT 검수.
- Smaug **0.5 이상** → 다시 볼 목록에 넣기(모델 카드가 정해 둔 기본선). **0.9 이상** → 목록 맨 위. **0.5 미만** → 그냥 "탐지기는 못 알아챔"이고 합격 아님.
- 크기 **256 px 미만 아이콘**은 탐지기 건너뛰기(Thermostatic 카드가 낮은 해상도에 약하다고 고백, 나머지도 같은 약점이 있을 것 — 추측).
- OCR: 기대한 글자와 다르면(편집거리 크거나 사전에 없는 단어) 자동으로 '다시 그리기' 후보.

**쓸지 말지 정하는 시험 (설치 후 30분 이내로 끝낼 것)**
1. 양성 280장 중 크기 512 px 이상인 것 + 음성 Blender 결과물 같은 수(예 200 + 200)에 Smaug를 돌림.
2. **양성의 90% 이상이 0.5 이상이면서 음성의 10% 이하만 0.5 이상**인 판정선이 있으면 → 쓸 만함. 그런 판정선이 없으면(예: Blender 결과물도 높게 나옴) → **우리 그림체엔 쓸모없는 도구**라고 결론 내고 버리기. (이 기준 값은 내가 정한 제안이에요.)
3. 시험은 **원본**과 **실제로 게임·가게에 올라가는 판(리사이즈·압축됨)** 둘 다 해서, 올린 뒤에도 구별되는지 확인.

### 5-2. 글 — 규칙 검사기 위주, 통계 탐지기는 설치하지 않기

| 대상 | 도구 | 방법 | 임계값 |
|---|---|---|---|
| 영어 소개글·긴 안내·패치노트 | **dslop** (`pip install dslop`) | 글을 파일로 뽑아 `dslop 파일.md` | 한 건이라도 걸리면 "다시 쓸지" 검토(빡빡한 옵션은 끄고 쓰기). 한 줄 UI 글엔 쓰지 않기 |
| 영어·한국어 모든 글 | **우리 목록 grep**(이미 wr-gamer가 함: 챗봇 잔재·과장 단어·세 개씩·번역투 "~을 통해/~에 대한/보여집니다/결론적으로/상상해 보세요") | `ai_look_report.md` 1-3의 패턴 목록을 `tools/`의 스크립트 한 장으로 | 걸리면 고치기 |
| 길이가 100단어 넘는 영어 글만(가게 소개글) | (선택) modernbert-ai-text-detector — CPU 가능, 1.5억 | 점수는 **참고만** | 이 모델은 2025 생성기에서 약하다고 카드가 말함 → 점수로 결정하지 않기 |

- Binoculars·Fast-DetectGPT·desklib 등은 **설치하지 않는 걸 추천**: 짧은 글 근거 없음, 한국어 근거 없음, Binoculars는 PC에 안 맞음, 비원어민 오탐 위험.
- 한국어는 자동 판정 대신 `ai_look_report.md` 방식(번역투 목록 + 사람이 소리 내어 읽기).

### 5-3. 소리·음악 — 시험부터

| 대상 | 도구 | 방법 |
|---|---|---|
| 음악 루프 8개(58~84초) | SONICS **120초판**(`awsaf49/sonics-spectttra-alpha-120s`, 75 MB) | 120초에 못 미치므로 어떻게 넣어야 하는지(패딩/반복) 문서 확인 필요. 양성 = 우리 ElevenLabs 곡, 음성 = CC0 음악이 있으면 그것(없으면 시험 포기) |
| 효과음 | AudioMosaic EnvSDD-TTA(343 MB) | 효과음을 4초로 늘려 넣어야 함. 양성 = 우리 ElevenLabs 효과음, 음성 = `art/sfx/cc0`·Kenney |

- **판정**: 양성·음성을 가르는 정도(AUC)가 **0.8 미만이면 버림**(내가 정한 제안 값). 가르면 → 점수 0.5 이상은 "귀로 다시 듣기 + `sound_judge.py` 결과와 같이 보기" 목록에 넣기.
- 소리는 탐지기보다 **귀 + 기존 `sound_judge`(AST·CLAP)**가 먼저예요. 사람들이 지적하는 건 'AI 소리' 자체보다 크기 들쭉날쭉·딸깍·끝이 갑자기 끊김인데, 이건 `sfx_process.py`가 이미 막고 있어요.

### 5-4. 결과 모으는 법 (메인이 만들지 정하면)

폴더 하나를 넣으면 `ai_look_scan.csv`를 만드는 스크립트 1장(지금은 없음):
`파일 · 크기 · C2PA 있음 · Smaug 점수 · OCR 읽은 글 · 기대 글과 다름 · 다시 볼까(예/아니오)`
→ 위에서 20장만 `gpt_image_review.py`(손·글자·있을 수 없는 물건 질문 포함)로 보내고, 사람은 `art_hands_sheet.py`로 손 확인. 이렇게 하면 9천 장을 다 볼 필요 없이 **'GPT 원본 그대로 + 점수 높음 + 글자 이상'**인 몇십 장부터 고칠 수 있어요.

### 5-5. 설치 순서 제안 (작은 것부터, 전부 허락 뒤)

1. c2patool (10.9 MB) — 확실한 답. 2. RapidOCR — 글자 깨짐. 3. Smaug (878 MB) — 시험 통과 시에만 유지. 4. dslop — 영어 글. 5. 소리 두 모델(75 MB·343 MB) — 시험 통과 시에만 유지.

---

## 6. 한계 (정직하게)

1. **탐지기는 '사람이 느끼는 AI 티'를 재지 않아요.** 사람들이 지적하는 1위는 "게임과 안 맞는 그림, 손, 깨진 글자, 있을 수 없는 물건"이고, 탐지기는 픽셀 통계예요. 탐지기가 "진짜"라고 해도 손가락이 6개일 수 있고, "AI"라고 해도 게임에 잘 맞을 수 있어요.
2. **사진 위주로 학습·시험됐어요.** 우리는 일러스트·아이콘·UI·로블록스풍이에요. 이 영역에서 정확도를 보여 준 자료가 없어서, 우리 정답지로 직접 시험하기 전엔 **신뢰도를 모른다**고 봐야 해요.
3. **새 생성기에 약해요.** 대규모 비교에서 Flux Dev·Firefly v4·Midjourney v7은 평균 18~30%만 잡혔고, 글자가 많은 AI 그림은 80%를 넘는 방법이 없었어요. 우리가 쓰는 GPT 이미지 모델 버전에 대한 시험은 못 찾았어요(GPT-4o 2025-04 보고서만 있음).
4. **리사이즈·압축에 약해요.** 로블록스에 올리면 그림이 다시 압축·축소돼요. 올린 판 기준으로도 시험해야 하고, 작은 아이콘엔 안 쓰는 게 나아요.
5. **오탐이 있어요.** 가장 좋다는 Smaug도 회사 자체 표에서 진짜 사진을 0.4~3% AI로 의심하고, 다른 모델들은 10~44%예요. 사람이 그린 우리 그림(Blender 결과물)이 걸릴 수 있어요 → 그래서 정답지 시험이 필수예요.
6. **글은 짧은 UI 문장에서 쓸 수 없어요.** 한국어 근거 없음, 비원어민 오탐 위험, 최신 모델 글엔 약함(modernbert 카드 스스로 인정). 글은 규칙 목록 + 사람 읽기가 맞아요.
7. **소리 모델은 Suno·Udio, AudioLDM 계열을 봤어요.** ElevenLabs는 안 봤어요. 5초판은 가짜 3개 중 1개를 놓쳐요. 우리 효과음은 1초 안팎이라 모델 창(4~5초)보다 짧아요.
8. **이 도구들을 다 합쳐도 사람 점검을 대신하지 못해요.** 팀의 "게임 안 모습과 맞는다", "실제 크기에서 읽힌다" 점검이 기준이고, 도구는 그 앞에서 '볼 것 순서'를 정해 줄 뿐이에요.
9. 출처 표시(C2PA)는 **있으면 확실, 없어도 AI가 아니라는 뜻은 아님.** 우리 GPT 원본에는 있지만 손본 판에는 없어요(0장).

---

## 7. 확인 못 한 것

- **아무것도 설치·실행하지 않았어요.** 그래서 우리 그림·소리에서의 점수, 속도, CPU/GPU 실제 동작은 모두 미확인이에요. (현재 venv torch는 CPU판이고, RTX 5060 Laptop에 맞는 CUDA판 torch가 되는지도 확인 못 함.)
- **Smaug 수치는 만든 회사(Abacus.AI)의 자체 시험**이고, 출시 6일 차라 독립 검증을 못 찾았어요. 카드가 말한 "CPU도 됨"의 속도와, 일러스트·게임 아이콘 성능은 모름. 저장소 파이썬 파일(`smaug_image_detect.py`)은 안 읽었어요 — **쓰기 전에 읽어야 해요.**
- Thermostatic 판은 개인 비공식 미세조정이고, GPT Image에서의 실제 성능 수치는 카드에서 확인하지 못했어요(학습에 포함됐다는 것만 확인).
- **C2PA**: 서명이 진짜인지(검증)는 안 봤고, 파일 앞 400 KB에서 글자만 찾았어요. c2patool 실제 실행·`--info` 출력 형태는 안 해 봤어요. 우리 GPT 이미지 도구의 정확한 모델 버전, 그 모델이 항상 C2PA를 붙이는지도 못 확인(OpenAI 도움말 페이지는 403으로 열리지 않아 검색 요약만 봤어요).
- 논문 2608.01258·2606.01050·2602.07814은 **초록만** 읽었어요(어느 탐지기가 어떤 수치인지 세부 표는 못 봄). GPT-ImgEval은 표 3을 직접 읽었지만 본문과 표가 안 맞는 곳이 있었어요.
- **ElevenLabs(음악·효과음)가 SONICS·EnvSDD 학습에 들어 있는지**: SONICS = Suno·Udio, EnvSDD 논문 생성기 목록에 ElevenLabs·Stable Audio 없음까지만 확인.
- SONICS 120초판에 58~84초 곡을 넣는 방법(패딩 등), AudioMosaic이 CPU에서 얼마나 걸리는지는 확인 못 함.
- RapidOCR·PaddleOCR·Tesseract의 **한국어 지원과 정확도**는 직접 확인 못 함. Python 3.13에서의 설치도 `rapidocr`가 순수 파이썬 wheel(py≥3.8)이고 onnxruntime이 Windows wheel을 낸다는 것까지만 확인.
- KatFishNet 점수의 정확한 지표(AUC인지 F1인지)는 README에 안 적혀 있어 확인 못 함. slopless·defluff는 README를 안 읽었어요. Audio Sleuth·EnvSDD 외 다른 음성 도구는 소개 문장만 봤어요.
- B-Free·Effort·AIDE·NPR의 CPU 동작, 가중치 크기, 가중치가 지금도 받아지는지는 확인 못 함(구글 드라이브 링크는 열어 보지 않음).
- 로블록스가 올린 그림을 어떤 방식·품질로 다시 압축하는지(탐지 점수에 얼마나 영향?)는 모름.
- 상용 탐지기(Sightengine, ACRCloud, Pex 등)는 오픈소스가 아니라 평가하지 않았어요.

---

## 부록 A. 링크 확인 방법 (이번 조사에서 직접 연 것)

- GitHub: `api.github.com/repos/<소유자>/<저장소>`로 라이선스·마지막 push·보관 여부를 읽고, README·LICENSE 원문(raw)을 열어 봄 — UniversalFakeDetect, CNNDetection, NPR, AIDE, DIRE, B-Free, Effort, FakeVLM, Community-Forensics, Binoculars, Fast-DetectGPT, Ghostbuster, KatFishNet, dxlabskku, SONICS, EnvSDD, AASIST, AudioMosaic, lcrosvila, Spot-if-AI, c2patool, c2pa-rs, dslop, noslop, OCR·MediaPipe 저장소.
- Hugging Face: `huggingface.co/api/models/<id>`(라이선스·크기·파일 목록)와 모델 카드 원문 — Smaug, Thermostatic, OwensLab commfor, SuSy, haywoodsloan, Ateeqq, Organika, umm-maybe, desklib, modernbert, roberta 계열, SONICS 4종, AudioMosaic, falcon-7b·gpt-neo-2.7B·embeddinggemma-2(라이선스 태그).
- PyPI/npm: dslop, defluff, slopless, rapidocr, paddleocr, easyocr, pytesseract, mediapipe, open_clip_torch, onnxruntime 등 버전·날짜·파이썬 요구.
- 논문(arXiv 초록/HTML): Binoculars, GPT-ImgEval(표 3), EnvSDD(생성기 목록), 2602.07814, 2606.01050, 2608.01258, TISMIR 초록.
- 열리지 않은 것: OpenAI 도움말(C2PA) 403, ACL Anthology 미리보기 404 → 검색 요약·README로 대체.

## 부록 B. 간이 C2PA 바이트 스캔 (읽기만, 설치 필요 없음)

```python
# py -I scan.py  (프로젝트 루트에서) — PNG 앞 400KB에서 C2PA 표시 글자만 찾음. 서명 검증 아님.
import os
hits = []
for root, _, files in os.walk("art"):
    for f in files:
        if f.lower().endswith(".png"):
            p = os.path.join(root, f)
            b = open(p, "rb").read(400000)
            if b"caBX" in b and b"c2pa" in b:
                hits.append((p, b"OpenAI" in b))
print(len(hits), "files with C2PA marker")
```
