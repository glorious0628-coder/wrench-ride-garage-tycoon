# claude_api.py — API 크레딧으로 읽기 일 돌리기

Claude Code 사용량 대신, 사용자의 **API 선불 크레딧**으로 "읽기 많고 쉬운 일"을 시키는 작은 도구예요.
파일: `tools/claude_api.py` · 장부: `notes/api_ledger.json`

## 이런 일에 써요

- 긴 글 요약 (기획서, 노트, 로그, 조사 보고서)
- 웹 조사 (검색해서 출처 링크까지 받기)
- 글 말투 검토 (게임 안 글이 어색한지, 영어·한국어 번역이 자연스러운지)
- 그림 검토 (스크린샷·시안 보고 "뭐가 이상한지" 묻기)
- 파일 여러 개를 읽고 "이 중에서 X 찾아줘" 같은 훑기

이 도구는 **답 글만 파일로 저장**해요. 게임 파일을 고치거나 Studio를 만지지 않아요.
답은 **초안**이에요. 숫자·사실·판단은 메인이 한 번 보고 써요. (웹 조사 맨 아래 줄에 `검색 0회`면 기억으로 쓴 거예요 → 링크를 직접 확인하세요.)

## 예시 (프롬프트는 항상 파일로, 한국어 OK)

```
# 긴 글 요약 (--job summary = haiku)
py tools/claude_api.py ask --prompt-file q.md --out a.md --job summary --effort low --file docs/기획서.md notes/handoff/board.md

# 말투 검토 (--job tone = haiku)
py tools/claude_api.py ask --prompt-file q.md --out a.md --job tone --file src/ReplicatedStorage/Shared/LocaleKo.luau

# 어려운 판단 (--job judge = opus)
py tools/claude_api.py ask --prompt-file q.md --out a.md --job judge

# 그림 검수 (--job image = opus, png/jpg/gif/webp, 한 장 5MB 이하)
py tools/claude_api.py ask --prompt-file q.md --out a.md --job image --image shot1.png shot2.png

# 웹 조사 (기본 sonnet, 검색 1번 = $0.01, 기본 최대 30번 — 사용자 10-22 "검색 한도 더 넓게")
py tools/claude_api.py research --prompt-file topic.md --out report.md --max-searches 6

# 돈 쓰기 전에 요청만 확인 (호출 안 함, 토큰 수만 무료로 셈)
py tools/claude_api.py ask --prompt-file q.md --out a.md --file notes/big.md --dry-run

# 장부 보기
py tools/claude_api.py ledger
```

- `--file` 은 글 파일 첨부(여러 개, 4MB 이하), `--image` 는 그림 첨부(`ask` 에서만).
- 한글은 글자 1개가 토큰 1개쯤이에요. 큰 파일은 `--dry-run` 으로 먼저 토큰을 세 보세요.
- `research` 는 검색 도중 서버가 쉬면(`pause_turn`) 알아서 이어가요 (기본 10번, 비용 $4 넘으면 멈춤: `--max-continuations`, `--max-usd`).
  답 맨 아래에 **인용한 출처** 링크와 **검색에서 본 다른 자료** 링크가 붙어요.

## 모델 고르기 (사용자 10-22: 일마다 나누기)

**`ask` 는 `--job` 이나 `--model` 을 꼭 골라요**(안 고르면 종료 코드 2). `research` 는 안 고르면 sonnet. `--model` 이 `--job` 보다 우선.

| `--job` | 모델 | 이럴 때 |
|---|---|---|
| `summary` · `tone` · `check` | haiku | 긴 글 요약, 글 말투 검토, 간단 확인·분류 |
| `research` | sonnet | 웹 조사 (`research` 기본) |
| `judge` · `image` | opus | 어려운 판단·헷갈리는 비교, 그림 검수 |

100만 토큰당 가격:

| 모델 | 입력 | 출력 | 캐시 읽기 |
|---|---|---|---|
| `opus` | $4 | $20 | $0.20 |
| `sonnet` | $2 | $10 | $0.10 |
| `haiku` | $0.10 | $0.50 | $0.01 (**opus보다 약 40배 싸요**) |

- haiku는 한 번에 보내는 글이 10만 토큰을 넘으면 $0.50 / $2.50 으로 올라요.
- 검색은 1,000번에 $10 (한 번 = $0.01), 토큰 값과 따로 더해요.
- 생각(thinking)한 토큰도 "출력"이라 돈이 들어요. 쉬운 일은 `--effort low`, 어려운 일만 `high`.
- 예: 글 10만 토큰을 읽고 2천 토큰으로 요약 → opus 약 $0.44, sonnet 약 $0.22, haiku 약 $0.011.
- 웹 조사에서 haiku는 기본 검색 버전을 써요 (opus·sonnet은 더 새 검색 버전).
- 모델이 거절하면(`refusal`) 종료 코드 4예요. opus·sonnet은 일부 거절(보안·경쟁 AI 관련)을 서버가 알아서 다른 모델로 한 번 더 시도해 줘요 (haiku는 그런 기능이 없어요).

## 키 2개, 자동 전환

- 키 이름은 `ANTHROPIC_API_KEY_1`, `ANTHROPIC_API_KEY_2` (`ANTHROPIC_API_KEY1`, `ANTHROPIC_API_KEY 1` 처럼 써도 읽어요). 그냥 `ANTHROPIC_API_KEY` 는 "키 0"이라는 마지막 보험이에요.
- 찾는 순서: 프로세스 환경 변수 → 사용자 환경 변수(윈도우 레지스트리) → `.env` (`../Game/.env`, `../Halo & Horns/.env`).
  메모리에서만 읽어요. **`.env` 를 열어 보지 마세요** — 도구가 알아서 읽어요.
- **키 1을 먼저 쓰다가**, 키 1의 장부가 예산($60)의 98%에 닿거나 서버가 "크레딧 부족"(HTTP 402, `billing_error`)이라고 하면 **자동으로 키 2로** 바꿔요.
  그때 `API 키 1 다 씀 → 키 2로 바꿈 (메인에게 알리기)` 가 떠요 → **메인에게 알려 주세요.**
- 두 키 다 98%를 넘으면 `API 크레딧 소진 — 사용자에게 키 교체 부탁` 이 뜨고 호출을 안 해요 (종료 코드 3).
- 키를 새로 바꾼 쪽은 장부를 0으로: `py tools/claude_api.py ledger --reset --key 1` (예산을 바꾸려면 `--budget 60`). 어느 키인지 꼭 적어야 해요 (`--key 1|2|0|all`).

## 장부 (`notes/api_ledger.json`)

- 호출할 때마다 한 줄씩 쌓여요: 시각, 어느 키, 명령, 모델, 입력/출력/캐시 토큰, 검색 횟수, 돈(추정), 끝난 이유, request_id.
- 돈은 공개 가격표(위 표)로 계산한 **추정값**이에요. 진짜 잔액은 Anthropic 콘솔이 맞아요.
- 90%가 넘으면 호출 전에 `API 크레딧 거의 다 씀: $X / $60 — 메인에 알리기` 가 떠요 → 메인에게 알려 주세요.
- 호출이 끝날 때마다 한 줄: 모델, 토큰, 이번 돈, 합계 / 예산.
- 세션 여러 개가 동시에 써도 안 꼬이게 잠금 파일을 써요.

## 키는 절대 화면·파일에 안 나와요

- 키 값은 화면에도, 장부에도, 로그에도, 에러 글에도 안 적어요 (에러 글에서도 걸러 내요). `ledger` 와 `--dry-run` 은 "키 1: 있음" 같은 **있고 없음만** 보여줘요.
- 이 컴퓨터는 클로드 앱이 `ANTHROPIC_BASE_URL` (내부 프록시)을 환경에 넣어 둬요. 이 도구는 그걸 **무시**하고 늘 `https://api.anthropic.com` 으로 사용자 키를 직접 써요.

## 종료 코드

| 코드 | 뜻 |
|---|---|
| 0 | 잘 됐어요 |
| 2 | 입력이 잘못됐거나 키가 없어요 (키는 사용자 환경 변수 `ANTHROPIC_API_KEY_1` 로 넣어 달라고 부탁) |
| 3 | 크레딧을 다 썼어요 → 사용자에게 키 교체 부탁 |
| 4 | 모델이 거절했어요 (`--out` 파일에 메모만 적혀요) |
| 5 | 키가 거절당했어요 (401) → 키 확인 부탁 |
| 6 | 그 밖의 API 오류 (요청 많음 429, 인터넷 등) |

## 옛 단일 키 도구와의 관계

- `tools/api_research.py` — 게임 장르 리서치 전용 (검색 + 웹 페이지 읽기, 게임용 프롬프트가 들어 있어요). 키 하나, 장부는 `notes/research/api/_spend.json`.
- `tools/api_image_review.py` — `gpt_image_review.py` 가 막혔을 때 그림 검토를 대신해요. 같은 장부를 나눠 써요.
- 둘 다 그대로 써도 돼요. `claude_api.py` 는 **아무 일에나 쓰는 범용 도구**이고, 키 2개 자동 전환과 새 장부(`notes/api_ledger.json`)를 써요.
- **옛 도구로 쓴 돈은 새 장부에 안 들어가요.** 같은 키를 둘 다 쓰면 진짜 남은 돈은 장부보다 적을 수 있으니, 크레딧이 빠듯해지면 콘솔에서 확인해 달라고 하세요.
