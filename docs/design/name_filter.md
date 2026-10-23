# 정비소 이름 필터 (name_filter) — v0.1 (wr-design, 2026-10-21)

> 사용자: "욕, 패드립,, 여혐, 인종차별 이런 거 당연히 안 되게 걸러야 돼." → **두 겹** 필터.
> 이름 짓기·바꾸기 규칙은 `monetization.md` §1b(첫 이름 무료 1번 → Garage Rename 패스). 이 문서는 **거르는 법**만.
> **금지어 목록은 게임 데이터 파일에만**: `src/ServerScriptService/Data/NameBlocklist.luau`(ServerScriptService = 클라이언트로 복제 안 됨 — ServerStorage와 같은 효과, Rojo 매핑 그대로). **이 문서·board엔 단어를 적지 않아요.**

## 1. 1겹 — Roblox 필수 필터 (공식 문서로 확인)
- 서버에서 `TextService:FilterStringAsync(text, player.UserId)` → `TextFilterResult:GetNonChatStringForBroadcastAsync()`.
  - 공식: 이 메서드는 "non-chat text that every user can see, such as for a dialog that lets a user write a message on a sign, visible to all users on the server even after the author has left"([TextFilterResult](https://create.roblox.com/docs/reference/engine/classes/TextFilterResult)) — 간판 이름이 딱 이 경우.
  - [Text filtering](https://create.roblox.com/docs/ui/text-filtering): 서버에서 `FilterStringAsync` → `GetNonChatStringForBroadcastAsync`로 거른 뒤 모두에게 보이는 SurfaceGui에. 데이터 스토어에 **저장한 글도 꺼낼 때 다시 걸러야** 한다는 안내(펫 이름 예).
- 결과에 `#`이 **하나라도** 있으면 거절(일부만 가려진 이름을 쓰지 않음).
- `FilterStringAsync`는 실패할 수 있음 → pcall, 실패면 "Try again in a moment." (이름은 안 바뀜, 기회도 안 날아감).
- **불러올 때마다 다시 거름**: 저장된 이름을 표시할 때도 서버가 다시 `FilterStringAsync`(Roblox 필터가 바뀌어 나중에 걸리면 기본 이름으로 보여 줌 — 저장값은 그대로, §5).

## 2. 2겹 — 우리 금지어 목록 (Roblox 필터가 놓치기 쉬운 것)
- 대상: 한국어 욕·변형, **패드립(부모 욕)**, **여혐·남혐 용어**, **인종·민족 비하**, 장애 비하, 성적 표현, 혐오 커뮤니티·밈 용어, 영어의 같은 것, 실제 인물 비하 밈.
- 구성(데이터 파일 안): `substring`(어디든 들어 있으면) · `word`(짧은 영어 — 단어 하나로만, 'bass'·'class'처럼 정상 단어 속에선 X) · `jamo`(초성·자모만 친 것, 예: 자음만 두 개) · `allow`(정상 단어가 걸리는 경우 미리 빼기).
- 1겹 → 2겹 순서(둘 다 통과해야 OK).

## 3. 정규화 (비교 전에 이름을 이렇게 바꿈)
1. 소문자로.
2. 공백·특수문자·이모지·밑줄·점 제거(한글·영어·숫자만 남김) — 단, `jamo` 검사용으로 **원래 이름의 낱자(ㄱ~ㅣ) 순서**는 따로 보관.
3. 숫자·기호 → 글자: `1→i`(영어 사이) · `0→o` · `3→e` · `4→a` · `5→s` · `7→t` · `8→b` · `$→s` · `@→a` · `!→i`.
4. 같은 글자 연속은 하나로(`fuuuck → fuck`, 한글 같은 음절 반복도 하나로).
5. **한글 사이에 낀 숫자·영어 제거**(`시1발 → 시발`, `씨x발 → 씨발`).
6. `allow` 목록에 있는 부분을 지운 뒤 → `substring` 검사 → `word`는 원래 이름의 영어 단어(공백·기호로 나눈 토큰)를 정규화해서 검사 → `jamo`는 보관한 낱자 순서에서 검사.
- 한글 낱자 판정: 호환 자모(U+3131~U+3163)만 '낱자'로 봄 — 완성 음절을 초성으로 쪼개서 비교하지 않음(정상 단어 오탐이 너무 많음).
- 오탐이 나오면 `allow`에 추가(정규화된 모양으로).

## 4. 형식 규칙
| 규칙 | 값 |
|---|---|
| 길이 | **3~20자**(공백 포함, 앞뒤 공백 자름, 공백 연속은 하나로) |
| 허용 글자 | 영어 대소문자·숫자·한글(완성 음절)·공백·`' - & . !` |
| 개인정보 거절 | 숫자 7개 이상(전화번호 꼴), `@` + `.`(이메일 꼴), `http`·`www`·`.com`·`.net`·`.kr`(주소 꼴) |
| 기본 이름 | `{DisplayName}'s Garage` (Locale: "{name}'s Garage" / "{name}의 정비소") |

## 5. 걸렸을 때 (아이에게 부드럽게)
- 화면: **"That name can't be used. Try another!"** / **"그 이름은 쓸 수 없어요. 다른 이름을 써 주세요!"** — **어떤 단어 때문인지는 알려 주지 않음**(목록을 캐내는 놀이 방지).
- 형식 걸림은 이유를 알려 줌(아이가 고칠 수 있게): 길이 **"Use 3 to 20 letters."** / "3~20자로 써 주세요." · 글자 **"Only letters, numbers and spaces, please."** / "글자·숫자·띄어쓰기만 써 주세요." · 개인정보 **"Please don't put phone numbers or emails in names."** / "이름에 전화번호나 이메일은 쓰지 말아요."
- **기회는 날아가지 않음**: 첫 무료 이름이든 Rename 패스든, 걸리면 그대로 다시 입력(몇 번이든). 바뀐 이름이 저장되는 순간에만 '무료 1번'이 쓰임.
- 너무 빨리 계속 보내기 막기: 같은 사람 **5초에 1번**(서버).

## 6. 나중 대비 (코드는 나중)
- **관리자 스위치**: 신고된 이름 → 그 정비소 이름을 기본 이름으로 되돌림(저장값에 `NameReset = true`, 주인에겐 "Your garage name was reset. You can pick a new one!" — 다음 한 번은 **무료**로 다시 짓기).
- 다시 거르기(§1)에서 걸린 저장 이름도 같은 처리.

## 7. Locale 키
| 키 | English | 한국어 |
|---|---|---|
| `name.prompt` | Name your garage! | 정비소 이름을 지어 주세요! |
| `name.blocked` | That name can't be used. Try another! | 그 이름은 쓸 수 없어요. 다른 이름을 써 주세요! |
| `name.length` | Use 3 to 20 letters. | 3~20자로 써 주세요. |
| `name.chars` | Only letters, numbers and spaces, please. | 글자·숫자·띄어쓰기만 써 주세요. |
| `name.private` | Please don't put phone numbers or emails in names. | 이름에 전화번호나 이메일은 쓰지 말아요. |
| `name.retry` | Try again in a moment. | 잠시 뒤 다시 해 봐요. |
| `name.default` | {name}'s Garage | {name}의 정비소 |
| `name.reset` | Your garage name was reset. You can pick a new one! | 정비소 이름이 처음으로 돌아갔어요. 새 이름을 골라 주세요! |
| `name.done` | Your garage is now "{name}"! | 이제 정비소 이름은 "{name}"이에요! |

## 8. wr-dev에게
- 모듈 제안: `ServerScriptService/Modules/NameService.luau` — `check(player, text) -> (ok, reasonKey)`: 형식 → 1겹(pcall, `#` 거절) → 2겹(`Data/NameBlocklist` + §3 정규화). 저장·불러올 때 다시 거르기.
- 데이터 파일은 wr-design이 만들어 둠(`Data/NameBlocklist.luau`, 린트 통과). 목록 고치기는 그 파일에서만.
- 코드는 사람 시험 뒤(이름 짓기는 Lv3 뒤라 첫 시험에 필요 없음).
