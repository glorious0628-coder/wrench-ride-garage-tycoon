# AI 티 점검 도구 (tools/ai_check)

우리 그림과 글을 **우리가 먼저** 검사해서, 기계가 만든 티가 나는 곳을 찾아 더 잘 다시 만들기 위한 도구예요.
도구는 **보조 경보기**일 뿐이에요. 진짜 합격 기준은 사람 눈: **"게임 안 모습과 맞나"**, **"실제 크기에서 읽히나"** (손 확대 점검도 그대로).

## 1. 깔려 있는 것 (2026-10-22 설치, 사용자 허락받음)

| 도구 | 버전 | 하는 일 | 어디에 |
|---|---|---|---|
| c2patool | 0.28.2 (contentauth/c2patool 공식 릴리스 v0.28.2, Windows x86_64 zip, sha256 확인함) | 그림 파일 안에 **C2PA 출처 표시**가 있나 읽기 (기록만) | `tools/ai_check/c2patool/c2patool/c2patool.exe` (zip 원본도 같이 둠) |
| RapidOCR | 3.10.0 (+ 실행 엔진 onnxruntime 1.31.0, 모델은 pip 안에 들어 있음) | 그림 속 **글자 읽기** | `tools/ai_check/.venv` |
| dslop | 0.2.2 | 영어 글의 **AI 말버릇**(줄표, "it's not X, it's Y", 군더더기 부사 ...) 규칙 검사 | `tools/ai_check/.venv` |

- 파이썬은 새 가상환경 `tools/ai_check/.venv` (Python 3.13.15). 다른 venv와 섞이지 않아요.
- 같이 깔린 부품: numpy, opencv-python-headless, pillow, shapely 등 (RapidOCR이 필요로 해요).
- `words_en.txt` = 영어 단어 2만 개 목록. 이 PC에 이미 있던 `bert-base-uncased`의 `vocab.txt`에서 온전한 영어 단어(소문자 알파벳 3글자 이상)만 뽑은 것이에요 (새로 받은 것 아님). 도메인 말(wrench, radiator ...)은 `allowed_words.txt`와 `Locale.en`에 나온 단어로 보충해요.

## 2. 쓰는 법

프로젝트 폴더(`Wrench & Ride Garage Tycoon`)에서, **새 venv의 파이썬**으로, `-I` 를 붙여서:

```
tools\ai_check\.venv\Scripts\python.exe -I tools\ai_look_check.py images art\ui
tools\ai_check\.venv\Scripts\python.exe -I tools\ai_look_check.py images art\thumbs
tools\ai_check\.venv\Scripts\python.exe -I tools\ai_look_check.py text src\ReplicatedStorage\Shared\Locale.luau
tools\ai_check\.venv\Scripts\python.exe -I tools\ai_look_check.py text docs\design\store_page.md
```

- 결과 보고서는 `notes/ai_check/` 에 **날짜가 붙은 Markdown**으로 저장돼요 (예 `images_art-ui_2026-10-22.md`). 화면에는 짧은 요약만 나와요.
- `images <폴더>`: PNG/JPG마다 ① C2PA 표시 ② OCR 글자와 신뢰도 ③ 판정. 옵션:
  - `--max-depth 0` 그 폴더 바로 아래 파일만 (0 = 하위 폴더 안 봄, 1 = 한 단계 아래까지 ...)
  - `--limit 30` 앞에서 30장만 (OCR은 그림 한 장에 1~2초 걸려요. 수천 장이면 `--max-depth`나 `--limit`로 줄이세요)
  - `--include-check` 우리가 만든 비교표(`_check` 폴더, `_`로 시작하는 파일)도 검사
  - `--no-ocr`, `--no-c2pa` 한쪽만
- `text <파일>`: `Locale.luau`는 `Locale.en`의 `["키"] = "값"`을 뽑고 (색 태그 `<font>`와 `{빈칸}`은 뺌), `.md/.txt`는 **한글이 안 섞인 줄과 따옴표 안의 영어 문장**을 뽑아서 dslop에 넣어요. 한국어 글(`LocaleKo.luau` 등)은 못 읽어요.

## 3. 결과 읽는 법

### 그림 (images)

**C2PA 열**
- `있음: OpenAI Media Service API / ChatGPT gpt-image / trainedAlgorithmicMedia / 날짜` = 파일 안에 'GPT 이미지가 만들었다'는 서명이 그대로 있어요. 뜻: **GPT 원본 그대로**인 파일이라는 **사실 기록**. (서명 뒤에 그림이 바뀌었으면 `서명 뒤 바뀜?`이 붙어요.)
- `없음` = 표시가 없어요. **AI가 아니라는 뜻이 아니에요.** 고치거나 줄이거나 캡처하면 표시가 사라져요.
- 우리는 표시를 **지우거나 숨기지 않아요.** c2patool은 `c2patool 파일` 한 가지로만 불러서 읽기만 해요.

**판정 열 (OCR)**
- `깨진 글자 의심` = 아래 중 하나라도 있을 때. **먼저 눈으로 확대해서 보세요.** 위치(`[위 왼쪽]` 등)도 적어 둬요.
  - OCR 신뢰도가 낮음 (0.75 미만)
  - 모음 없음 / 자음 5개 넘게 이어짐 / 같은 글자 3번 연속 / 영어에 없는 글자 짝 / 숫자와 글자가 섞임 (`2a2E`)
  - **철자가 틀린 것 같은 단어**: 사전에 없는데 사전 단어와 한 글자만 다름 (예: `SEAR` ← gear? `GARAGGE` ← garage)
  - 사전에 없는 단어 + 신뢰도가 0.92 미만
- `확인 필요(참고)` = 사전에 없는 단어인데 신뢰도는 높음 (진짜 가게 이름일 수 있음), 한글·한자로 읽힘(OCR은 영어 중심이라 한국어 그림은 거의 못 읽음), 이름 글자(Wrench & Ride 등)와 거의 같은 말 (로고의 `&`를 못 읽은 OCR 오독이 많음).
- `OK` = 글자를 읽었고 이상한 단어 없음. `글자 없음` = 글자를 못 찾음.
- 한두 글자짜리 조각(`O`, `1`)은 무늬를 글자로 잘못 읽은 것이 많아서 판정에서 빼요 (표의 'OCR이 읽은 글자' 칸에는 보여요).

### 글 (text)

- 걸린 글마다 **규칙 이름과 한국어 이유**가 나와요. 자주 나오는 것: `em-dash`(줄표 —), `contrastive`("it's not X, it's Y"), `filler-adverbs`(really, actually ...), `three-beat`(짧은 문장 3개 연속), `summary-capstone`("That's it." 식 마무리), `but-opener`.
- 설정은 `dslop_ui.toml` (한 줄 UI 글용: 문장 길이 통계와 `not` 금지 규칙은 끔), `dslop_doc.toml` (긴 글의 통계 항목 보는 용). **주의**: dslop은 설정 파일 문법이 틀리면 조용히 기본 규칙으로 돌아가요. 스크립트가 시작할 때 확인해서 보고서에 경고를 써 줘요.

## 4. 한계 (꼭 읽기)

- **OCR이 못 읽은 뭉개진 글자는 안 걸려요.** 예: `art/thumbs/thumb_front.png` 오른쪽 멀리 있는 간판은 사람이 보면 글자가 깨져 있는데 OCR은 아무것도 못 읽어서 '글자 없음'이었어요. "글자 없음"은 안전하다는 뜻이 아니에요. 글자가 있어야 하는 그림(간판·썸네일·로고)은 직접 확대해서 보세요.
- **꾸민 글씨체, 비스듬한 글자, 작은 글자**는 사람은 읽어도 OCR이 틀려서 오탐이 많아요 (로고 `Wrench & Ride`가 `WrenchoRide`로 읽히는 것처럼).
- 한국어 그림 글자는 거의 못 읽어요 (`_ko` 파일). 한국어 글은 dslop도 못 써요 (번역투 목록 + 소리 내어 읽기).
- 영어 단어 목록은 완벽하지 않아요. 처음 보는 이름(SKYLOOP 등)은 '참고'로 나와요. 계속 나오는 우리 말은 `allowed_words.txt`에 한 줄씩 더하세요.
- **dslop은 '규칙' 검사기**예요. 걸렸다고 AI가 쓴 글이 아니고, 안 걸렸다고 사람 글도 아니에요. 한국 팀이 쓴 영어도 걸릴 수 있어요. 짧은 UI 글에는 통계를 못 써요.
- C2PA는 '있으면 확실한 사실, 없어도 AI가 아니라는 뜻은 아님'이에요. 서명이 믿을 만한 곳(신뢰 목록)에 있는지는 보지 않았어요 (`signingCredential.untrusted`는 정상).
- 이 도구들은 **'AI 안 썼어요'를 증명하지 않아요.** 그런 말은 하지 않기 (팀 규칙).

## 5. 안전 규칙

- 읽기만 해요: 그림은 열어서 읽기만, 다시 저장하지 않아요. C2PA 표시도 그대로.
- `art/_bought`, `_draft`, `_rejected`, 이름에 `pizza`가 들어간 것은 건너뛰고, 그런 폴더를 직접 넘기면 거절해요 (팀 규칙: Pizza Doggy 등은 AI 입력 금지).
- 다운받은 c2patool 폴더(`tools/ai_check/c2patool`)는 믿을 수 없는 곳에서 온 것으로 보고, 그 안의 `c2patool.exe`만 실행해요 (안에 들어 있는 `sample/` 파일은 쓰지 않아요). 파이썬은 `-I` 로 실행해서 그 폴더의 파일을 불러오지 않게 해요.
- 탐지기를 속이는 일(표시 지우기, 노이즈 넣기)은 하지 않아요. 목표는 그림·글을 **더 잘 다시 만드는 것**이에요.

## 6. 파일 목록

| 파일 | 뜻 |
|---|---|
| `tools/ai_look_check.py` | 실행하는 스크립트 (한 장짜리, `-I`로 실행) |
| `tools/ai_check/dslop_ui.toml`, `dslop_doc.toml` | dslop 규칙 설정 |
| `tools/ai_check/allowed_words.txt` | 사전에 없어도 괜찮은 단어 (우리가 더하는 곳) |
| `tools/ai_check/words_en.txt` | 영어 단어 목록 |
| `notes/ai_check/*.md` | 결과 보고서 (날짜 붙음) |
