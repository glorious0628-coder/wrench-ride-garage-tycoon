# 깃허브 레포 조사 (10-22)

**라이선스 기준: 상업 OK + 코드 공개 의무 없는 것만 (MIT · Apache-2.0 · BSD · MPL-2.0 · ISC · Zlib · CC0 · Unlicense 등).** 이 기준 밖은 아예 목록에 넣지 않았다.

- 별 수·라이선스·마지막 업데이트는 **2026-10-22에 GitHub API(`api.github.com/repos/...`)에서 직접** 확인한 값이다. "마지막 업데이트" = 마지막으로 코드가 올라간 날(push).
- API가 라이선스를 못 읽은 4곳(ffmpeg-normalize, lucide, pretendard, Pillow)은 `LICENSE` 파일을 직접 열어 확인했다.
- 설치·다운로드·로그인은 하지 않았다. 읽고 정리만 했다.
- 읽는 법: MPL-2.0 도구(Rojo, Selene, StyLua, Wally, Lune)는 **개발 도구라 게임에 안 들어간다.** 그 도구의 파일을 고쳐서 다시 퍼뜨릴 때만 그 파일을 공개하면 된다.

## 별 100만에 대해 (한 줄)

GitHub 전체에서 별이 제일 많은 저장소도 약 55만(`codecrafters-io/build-your-own-x` 555,292)이라 **100만 넘는 곳은 없다.** 우리 분야에서 별이 가장 많은 건 `godotengine/godot` 118,839와 `mrdoob/three.js` 116,752이고, 로블록스 라이브러리는 수백~수천 단위다(로블록스 개발자 수가 적어서). 별이 적어도 쓰임은 다르다: ProfileStore는 DevForum 글에 큰 게임(Grow a Garden, Dead Rails)이 쓴다고 적혀 있다.

---

## TOP 10 (우리 일에 쓸모 있는 순서, 별은 2026-10-22)

| # | 이름 | 별 | 라이선스 | 마지막 업데이트 | 우리에게 무엇에 쓰나 | 주의 |
|---|---|---|---|---|---|---|
| 1 | [MadStudioRoblox/ProfileStore](https://github.com/MadStudioRoblox/ProfileStore) | 346 | Apache-2.0 | 2025-07-31 | 저장 + **세션 잠금** 모듈(파일 1개). 서버를 빨리 옮겨도 옛 서버 저장이 새 서버 저장을 덮지 못하게 함 → 보안 점검 C2 | **우리 `DataService.luau`에 이미 직접 만든 세션 잠금이 있다(오늘 15:31 수정)** → "갈아탈지·그대로 둘지" 비교 거리. 아래 '1번 자세히' |
| 2 | [JohnnyMorganz/luau-lsp](https://github.com/JohnnyMorganz/luau-lsp) | 558 | MIT | 2026-10-22 | `luau-lsp analyze`로 **프로젝트 전체의 타입·로블록스 API 오류를 컴퓨터에서 검사**(Studio 안 열고). 지금 `tools/luau_lint.py`는 괄호·`end` 균형만 봄 | 모듈 `require` 경로를 읽으려면 보통 Rojo `sourcemap`을 같이 씀 → Rojo가 PATH에 없음(아래 겹침 표) |
| 3 | [Kampfkarren/selene](https://github.com/Kampfkarren/selene) | 835 | MPL-2.0 | 2026-10-01 | 린터: 안 쓰는 변수, 이름 가림, 옛 함수(`wait()` 등) 경고. 로블록스 표준 설정이 들어 있음 | Luau 파일이 137개라 경고가 많이 나올 수 있음 → 규칙을 골라 켜기 |
| 4 | [rojo-rbx/rojo](https://github.com/rojo-rbx/rojo) | 1,812 | MPL-2.0 | 2026-10-06 | `default.project.json`과 `src/` 구조는 이미 Rojo 규칙. 파일→Studio 동기화, `rojo build`, `rojo sourcemap`(luau-lsp용) | **겹침**: 지금은 `tools/sync_to_studio.py`(Studio MCP)로 밀어 넣고, `rojo` 실행 파일은 이 컴퓨터 PATH에 없음 |
| 5 | [Sleitnick/RbxUtil](https://github.com/Sleitnick/RbxUtil) | 470 | MIT | 2026-08-11 | Signal, Trove(정리 도구), Timer, TableUtil 같은 작은 도구 모음. 모듈별로 따로 쓸 수 있음 | 전체를 넣지 말고 필요한 것 1~2개만. 우리 코드에 이미 비슷한 게 있는지 먼저 확인 |
| 6 | [zeux/meshoptimizer](https://github.com/zeux/meshoptimizer) | 8,587 | MIT | 2026-10-14 | 3D 메시 삼각형 줄이기·정리(`gltfpack`으로 glb→glb). 차 부품 수가 많아 로딩이 무거울 때 | 줄인 결과가 부품 모양을 깨지 않는지 **눈으로** 확인(Blender Decimate와 비교). 로블록스 메시 한도에 맞출 것 |
| 7 | [mikedh/trimesh](https://github.com/mikedh/trimesh) | 3,706 | MIT | 2026-10-21 | 파이썬으로 메시 검사: 닫힌 모양(watertight)·부피·겹침·크기. 우리 파이썬 도구에 바로 끼움 | **겹침**: `tools/blender/qa_glb.py` 등 자체 검사가 있음 → 빠진 검사만 보태기 |
| 8 | [donmccurdy/glTF-Transform](https://github.com/donmccurdy/glTF-Transform) | 1,989 | MIT | 2026-10-20 | glb 안을 `inspect`로 들여다보기, 텍스처 줄이기·정리(Node 명령). Node는 이미 이 컴퓨터에 있음 | **겹침**: `tools/glb_texture.py`, `quantize_pbr.py` |
| 9 | [tabler/tabler-icons](https://github.com/tabler/tabler-icons) | 22,410 | MIT | 2026-10-21 | 상업 OK 아이콘 SVG. PNG로 바꿔 올리면 작은 HUD 기호(자물쇠·화살표 등)로 쓸 수 있음 | 선 스타일이라 우리 캐주얼 그림체와 맞는지 **눈으로** 확인(플레이어가 "AI 티/흔한 앱 아이콘"이라 느끼지 않게). 큰 그림엔 X |
| 10 | [slhck/ffmpeg-normalize](https://github.com/slhck/ffmpeg-normalize) | 1,540 | MIT (LICENSE.md 확인) | 2026-10-14 | 효과음·음악 **소리 크기(라우드니스)를 한꺼번에** 맞춤. ffmpeg는 이미 있음 | **겹침**: `tools/sfx_finalize.py`가 이미 LUFS를 재고 `sfx_levels.py`·`sfx_volumes.py`가 크기를 맞춤 → 새로 넣을 이유 약함(비교용) |

### 1번 자세히: ProfileStore (보안 점검 C2)

| 항목 | 확인한 것 |
|---|---|
| 링크 | 코드 https://github.com/MadStudioRoblox/ProfileStore · 설명서 https://madstudioroblox.github.io/ProfileStore/ · DevForum 글 https://devforum.roblox.com/t/profilestore/3190543 |
| 만든 사람 | loleris(MAD STUDIO). 옛 모듈 ProfileService를 만든 사람. DevForum 글에 "ProfileService의 후속"이라고 적혀 있음(글 올린 날 2024-10-11) |
| 별 · 라이선스 | 346★ · **Apache-2.0**(`LICENSE` 직접 확인). 게임에 넣어도 됨. 코드 파일 위쪽에 원래 저작권·라이선스 문구를 그대로 둘 것 |
| 마지막 업데이트 | 2025-07-31(마지막 합침). 코드가 바뀐 건 2025-03-25("MessagingService 막힘 방지"), 2025-06-18(타입 이름 오타). 올해(2026)에는 코드 변경 없음 = **안정된 상태**일 가능성(추측) |
| 열린 이슈 | 1개: "공식 Wally 올리기 있나요?"(2026-06-28). **데이터 손실·세션 잠금 버그 이슈는 없음**(2026-10-22 확인) |
| 하는 일 | 파일 1개(ModuleScript). 서버 하나만 플레이어 데이터를 쥐게 잠그고, 다른 서버가 요청하면 MessagingService로 "마지막 저장 해주세요"를 보내 **빨리 넘겨받음**(기다리다 포기하지 않음). 같은 키 호출은 줄 세워 처리. 자동 저장 기본 300초 |
| 로블록스 공식 문서 언급 | **이름으로는 없음.** 공식 문서(`creator-docs` 원문) 3쪽(player-data-purchasing / best-practices / data-stores 첫 쪽)에서 ProfileStore·ProfileService 검색 0건. 대신 ① 공식 문서가 세션 잠금을 직접 설명하고 샘플(`SessionLockedDataStoreWrapper`)을 줌, ② best-practices는 "타사 데이터 모듈도 선택지. 쓰기 전에 주인·유지보수 상태·기능을 확인하고, 모듈 없이 데이터를 꺼내고 옮기는 법을 알아 둘 것"이라고 하고, DataStore2는 새 게임에 쓰지 말라고 함. 즉 **공식 추천은 아니고 선택은 우리 판단** |
| 쓰는 법 핵심 | `ProfileStore:StartSessionAsync(키)`로 시작 → `profile.Data` 수정 → 끝나면 꼭 `profile:EndSession()`. 시작이 `nil`이면(다른 서버와 겹침) 설명서가 **Kick을 권함**. `{Steal = true}`는 디버그 전용(잠금을 우회해서 복제 구멍이 생김) |
| 시험하기 | Studio에서 `ProfileStore.Mock`(가짜 저장소)로 바꿔 쓸 수 있음. 실제 DataStore 접근은 Studio에서 API 접근을 켜야 함 |
| **우리 코드와 비교** | 현재 `DataService.luau`(7,288바이트, 오늘 15:31): `UpdateAsync` 안에 `_lock = {job, t}`를 쓰고, 남의 새 잠금이면 2~3초마다 다시 물어 최대 30초(`loadWait`) 기다리다 그래도 안 되면 **이번 판은 저장 없이 플레이**, 잠금 300초(`LOCK_TTL`) 지나면 죽은 서버로 보고 가져옴, 떠날 때·서버 닫힐 때 잠금 풀고 마지막 저장. 글 읽고 비교만 했고 **돌려보지는 않았다** |
| 차이(읽고 비교) | ① ProfileStore는 옛 서버에 "지금 저장해"를 보내 빨리 넘김, 우리는 시간 기다림(최대 30초) ② ProfileStore는 큰 게임에서 쓰이며 검증됨, 우리 것은 새로 쓴 코드 ③ 갈아타면 **옛 저장 모양(`u_<UserId>` 키, 평평한 표 + `v`, `_lock`)을 읽어 옮기는 단계가 필요**할 수 있음 — ProfileStore는 ProfileService 저장과는 호환이라고 적혀 있지만 **우리 모양과 호환인지는 확인 못 함** → 시험 필요 ④ 영수증(`ProcessReceipt`) 중복 막기는 어느 쪽이든 직접 짜야 함(공식 문서의 5단계 그대로) |
| 정리 | 지금 코드에 잠금이 있으니 급한 건 아님. **선택지**: (A) 우리 잠금을 두고 Studio 2대 시험으로 검증 (B) 공개 전에 ProfileStore로 갈아타기(검증된 코드, 대신 옮기기 시험 필요). 공개(10/31)가 가까우니 (A)+시험이 현실적이고, 거래·선물을 넣는 날 (B)를 다시 보는 것도 한 방법(내 의견) |

---

## 분야별 표

표 안의 "겹침"은 우리 폴더에 이미 비슷한 게 있다는 뜻이다(아래 ⑦에 정리).

### ① 로블록스 Luau 라이브러리

| 이름 | 별 | 라이선스 | 마지막 업데이트 | 용도 | 겹침/주의 |
|---|---|---|---|---|---|
| [ProfileStore](https://github.com/MadStudioRoblox/ProfileStore) | 346 | Apache-2.0 | 2025-07-31 | 저장 + 세션 잠금 | 위 '1번 자세히' |
| [ProfileService](https://github.com/MadStudioRoblox/ProfileService) | 332 | Apache-2.0 | 2024-10-13 | ProfileStore의 옛 버전 | 작성자가 새 프로젝트엔 ProfileStore를 권함 → 이쪽은 비추 |
| [evaera/roblox-lua-promise](https://github.com/evaera/roblox-lua-promise) | 351 | MIT | 2024-08-06 | Promise(비동기 흐름 정리) | 완성된 라이브러리라 업데이트 적음. 우리는 `task.spawn` 위주라 꼭 필요하진 않음 |
| [Sleitnick/RbxUtil](https://github.com/Sleitnick/RbxUtil) | 470 | MIT | 2026-08-11 | Signal·Trove·Timer 등 | TOP 10 5번 |
| [howmanysmall/Janitor](https://github.com/howmanysmall/Janitor) | 151 | MIT | 2026-07-28 | 연결·인스턴스 정리(Trove와 같은 일) | 둘 중 하나만 |
| [dphfox/Fusion](https://github.com/dphfox/Fusion) | 806 | MIT | 2026-02-02 | UI를 값 변화에 따라 자동 갱신 | **겹침**: 우리는 자체 `UIKit.luau`. 갈아타면 UI 전부 다시 → 비추 |
| [jsdotlua/react-lua](https://github.com/jsdotlua/react-lua) | 576 | MIT | 2025-05-23 | React 방식 UI | 겹침(UIKit). 무거움 |
| [jsdotlua/jest-lua](https://github.com/jsdotlua/jest-lua) | 57 | MIT | 2024-12-23 | Luau 테스트 틀(Jest 방식) | 별 적고 업데이트 오래됨 |
| [Roblox/testez](https://github.com/Roblox/testez) | 210 | Apache-2.0 | 2024-03-05 | 옛 테스트 틀 | **보관됨(archived, 더 안 고침)** → 새로 쓰지 말 것 |
| [evaera/Cmdr](https://github.com/evaera/Cmdr) | 533 | MIT | 2026-10-21 | 게임 안 명령창(개발자·관리자 명령) | 겹침: `Dev/DevHooks.luau`. 쓰면 **공개 빌드에서 꺼야 함**(주인만) |
| [red-blox/zap](https://github.com/red-blox/zap) | 190 | MIT | 2026-06-23 | Remote 이벤트 설계도를 쓰면 **값 검사 코드를 만들어 줌**(보안 점검용) | **겹침**: `Modules/Guard.luau`. 바꾸려면 Remote 전부 손봐야 해서 공개 전엔 무리 |
| [1Axen/blink](https://github.com/1Axen/blink) | 193 | MIT | 2026-09-23 | zap과 같은 종류 | 위와 같음 |
| [buildthomas/MockDataStoreService](https://github.com/buildthomas/MockDataStoreService) | 84 | Apache-2.0 | 2023-08-15 | 가짜 DataStore(시험용) | **겹침**: `DataService.useStore`와 `Dev/DevHooks`의 가짜 저장소. 업데이트 오래됨 |

### ② 로블록스 개발 도구

| 이름 | 별 | 라이선스 | 마지막 업데이트 | 용도 | 겹침/주의 |
|---|---|---|---|---|---|
| [luau-lang/luau](https://github.com/luau-lang/luau) (옛 주소 Roblox/luau) | 6,015 | MIT | 2026-10-20 | Luau 언어 자체 + `luau-analyze`(타입 검사)·`luau`(실행) 명령 | 로블록스 클래스(`game`, `Instance`)는 모름 → 그쪽은 luau-lsp |
| [JohnnyMorganz/StyLua](https://github.com/JohnnyMorganz/StyLua) | 2,321 | MPL-2.0 | 2026-10-12 | 코드 모양(들여쓰기 등) 자동 정리 | 전체에 돌리면 Luau 파일 137개가 다 바뀜 → 한 번에 하고 따로 저장하기 |
| [rojo-rbx/rojo](https://github.com/rojo-rbx/rojo) | 1,812 | MPL-2.0 | 2026-10-06 | 파일↔Studio 동기화 | TOP 10 4번(겹침) |
| [roblox-ts/roblox-ts](https://github.com/roblox-ts/roblox-ts) | 1,322 | MIT | 2026-10-19 | TypeScript → Luau | 우리는 Luau 파일 137개가 이미 있음 → 비추 |
| [lune-org/lune](https://github.com/lune-org/lune) | 967 | MPL-2.0 | 2026-10-21 | Luau를 컴퓨터에서 실행(스크립트·시험) | `tools/*.luau`(bake·dump)는 Studio 안에서 돌리는 것으로 보임. Lune은 Studio 없이 순수 Luau 시험용 |
| [Kampfkarren/selene](https://github.com/Kampfkarren/selene) | 835 | MPL-2.0 | 2026-10-01 | 린터 | TOP 10 3번 |
| [JohnnyMorganz/luau-lsp](https://github.com/JohnnyMorganz/luau-lsp) | 558 | MIT | 2026-10-22 | 편집기 도우미 + `analyze` 검사 | TOP 10 2번 |
| [UpliftGames/wally](https://github.com/UpliftGames/wally) | 505 | MPL-2.0 | 2026-10-12 | 패키지 관리자 | 지금은 모듈 파일을 직접 복사하는 방식이라 급하지 않음 |
| [rojo-rbx/rokit](https://github.com/rojo-rbx/rokit) | 485 | MIT | 2026-09-27 | 위 도구들을 버전 맞춰 한 번에 설치·관리 | 설치 때 쓰는 도구(사용자 OK 후) |
| [pesde-pkg/pesde](https://github.com/pesde-pkg/pesde) | 129 | MIT | 2026-10-21 | Wally 대신 쓰는 패키지 관리자 | 별 적음, 급하지 않음 |
| [blake-mealey/mantle](https://github.com/blake-mealey/mantle) | 116 | MIT | 2026-05-28 | 게임 패스·상품·배지 같은 설정을 **파일로 적어 한 번에 만듦** | **겹침**: `tools/create_gamepass.py`, `create_devproduct.py`, `grant_all.py` |
| [rojo-rbx/run-in-roblox](https://github.com/rojo-rbx/run-in-roblox) | 78 | MIT | 2024-03-06 | 명령으로 Studio에서 스크립트 실행 | **겹침**: `tools/studio_mcp.py`. 업데이트 오래됨 |

### ③ Blender · 3D

| 이름 | 별 | 라이선스 | 마지막 업데이트 | 용도 | 겹침/주의 |
|---|---|---|---|---|---|
| [zeux/meshoptimizer](https://github.com/zeux/meshoptimizer) | 8,587 | MIT | 2026-10-14 | 메시 줄이기·정리, `gltfpack` | TOP 10 6번 |
| [mikedh/trimesh](https://github.com/mikedh/trimesh) | 3,706 | MIT | 2026-10-21 | 파이썬 메시 검사 | TOP 10 7번 |
| [CesiumGS/gltf-pipeline](https://github.com/CesiumGS/gltf-pipeline) | 2,135 | Apache-2.0 | 2026-06-23 | glTF 정리·압축(Node) | glTF-Transform과 비슷한 일 → 하나만 |
| [donmccurdy/glTF-Transform](https://github.com/donmccurdy/glTF-Transform) | 1,989 | MIT | 2026-10-20 | glb 검사·텍스처 줄이기(Node) | TOP 10 8번 |
| [KhronosGroup/glTF-Blender-IO](https://github.com/KhronosGroup/glTF-Blender-IO) | 1,666 | Apache-2.0 | 2026-10-22 | Blender의 glTF 가져오기/내보내기 원본 코드 | 같은 기능이 Blender에 기본으로 들어 있는 것으로 알고 있음(이 컴퓨터에서 확인은 안 함). 내보내기 옵션 문제를 풀 때 읽는 용도 |
| [KhronosGroup/glTF-Validator](https://github.com/KhronosGroup/glTF-Validator) | 475 | Apache-2.0 | 2026-10-06 | glb 파일이 규격에 맞는지 검사 | `qa_glb.py`와 겹칠 수 있음. 내보낸 파일이 규격 오류인지 확인할 때 |
| [ahujasid/mcp-for-blender](https://github.com/ahujasid/mcp-for-blender) (옛 이름 blender-mcp) | 31,943 | MIT | 2026-10-20 | Claude가 Blender를 직접 조작 | **겹침**: 비슷한 일을 하는 Blender MCP를 이미 씀(기능 비교용으로만) |
| [mrdoob/three.js](https://github.com/mrdoob/three.js) | 116,752 | MIT | 2026-10-22 | 웹에서 glb 돌려 보기(미리보기 페이지) | 우리 게임엔 직접 안 씀. 부품·차를 웹으로 한눈에 볼 때만 |

### ④ 소리

| 이름 | 별 | 라이선스 | 마지막 업데이트 | 용도 | 겹침/주의 |
|---|---|---|---|---|---|
| [jiaaro/pydub](https://github.com/jiaaro/pydub) | 9,803 | MIT | 2026-03-19 | 파이썬으로 소리 자르기·붙이기·크기 바꾸기 | 우리는 ffmpeg 직접 호출(`sfx_*.py`). 새로 넣을 이유는 약함 |
| [librosa/librosa](https://github.com/librosa/librosa) | 8,699 | ISC | 2026-10-06 | 소리 분석(길이·주파수·박자) | **이미 씀**: `tools/`의 4개 파일(`music_judge.py`, `music_loop.py`, `sfx_judge_batch.py`, `sound_judge.py`) + `audio_ai` 환경 |
| [iver56/audiomentations](https://github.com/iver56/audiomentations) | 2,323 | MIT | 2026-04-13 | 한 소리를 높낮이·속도·잡음으로 **변형 여러 개** 만들기 | 효과음이 반복돼 지루할 때(예: 볼트 소리 5변형). 사람 귀로 확인 필수 |
| [slhck/ffmpeg-normalize](https://github.com/slhck/ffmpeg-normalize) | 1,540 | MIT | 2026-10-14 | 소리 크기 맞춤 | TOP 10 10번 |
| [csteinmetz1/pyloudnorm](https://github.com/csteinmetz1/pyloudnorm) | 784 | MIT | 2026-01-04 | 소리 크기(LUFS) 재기 | `sfx_finalize.py`가 이미 LUFS를 재고 있어 겹침 |

### ⑤ 그림 · UI

아이콘(전부 상업 OK, 공개 의무 없음). 로블록스엔 SVG를 바로 못 올리니 **PNG로 바꿔서** 올려야 한다.

| 이름 | 별 | 라이선스 | 마지막 업데이트 | 비고 |
|---|---|---|---|---|
| [google/material-design-icons](https://github.com/google/material-design-icons) | 54,141 | Apache-2.0 | 2026-10-09 | 가장 많이 쓰이는 앱 아이콘. 그만큼 "흔한 느낌" |
| [lucide-icons/lucide](https://github.com/lucide-icons/lucide) | 25,201 | ISC (LICENSE 확인) | 2026-10-21 | 선 아이콘 |
| [tailwindlabs/heroicons](https://github.com/tailwindlabs/heroicons) | 23,875 | MIT | 2026-05-12 | 선·채움 두 가지 |
| [tabler/tabler-icons](https://github.com/tabler/tabler-icons) | 22,410 | MIT | 2026-10-21 | TOP 10 9번 |
| [ionic-team/ionicons](https://github.com/ionic-team/ionicons) | 18,213 | MIT | 2026-07-28 | 둥근 느낌 |
| [twbs/icons](https://github.com/twbs/icons) | 8,156 | MIT | 2026-10-12 | Bootstrap 아이콘 |
| [phosphor-icons/core](https://github.com/phosphor-icons/core) | 393 | MIT | 2026-01-06 | 굵기 6가지 |

도구:

| 이름 | 별 | 라이선스 | 마지막 업데이트 | 용도 | 겹침/주의 |
|---|---|---|---|---|---|
| [linebender/resvg](https://github.com/linebender/resvg) (옛 주소 RazrFalcon/resvg) | 4,150 | Apache-2.0 | 2026-10-20 | SVG를 PNG로 정확하게 바꿈(아이콘 올리기 전 단계) | 설치 필요(사용자 OK 후) |
| [python-pillow/Pillow](https://github.com/python-pillow/Pillow) | 13,912 | MIT-CMU(MIT와 비슷, LICENSE 확인) | 2026-10-22 | 파이썬 그림 처리 | **이미 씀**: `tools/`의 파이썬 76개 파일이 PIL 사용 |

글꼴 (SIL OFL 1.1: 상업 OK, 글꼴 파일 자체를 따로 파는 것만 금지):

| 이름 | 별 | 라이선스 | 마지막 업데이트 | 비고 |
|---|---|---|---|---|
| [rsms/inter](https://github.com/rsms/inter) | 19,989 | OFL-1.1 | 2024-11-19 | 영문 UI 글꼴 |
| [orioncactus/pretendard](https://github.com/orioncactus/pretendard) | 3,627 | OFL-1.1 (LICENSE 확인) | 2026-07-23 | 한글+영문 글꼴 |

**중요: 로블록스 공식 문서(Assets 쪽)에 "글꼴은 가져올 수 없다. Creator Store에 80가지 넘는 글꼴이 있다"고 적혀 있다(10-22 확인).** 그래서 위 글꼴은 **게임 안 글자**에는 못 쓰고, 썸네일·아이콘 같은 **그림에 박는 글자**에만 쓸 수 있다.

### ⑥ 게임 디자인 · 밸런스

| 이름 | 별 | 라이선스 | 마지막 업데이트 | 용도 | 비고 |
|---|---|---|---|---|---|
| [sindresorhus/awesome](https://github.com/sindresorhus/awesome) | 522,544 | CC0-1.0 | 2026-09-02 | "좋은 목록들의 목록". Game Development 칸이 있음 | 별은 가장 많지만 입구일 뿐 |
| [ellisonleao/magictools](https://github.com/ellisonleao/magictools) | 17,548 | MIT | 2026-10-21 | 게임 개발 자료 모음(디자인·그림·소리·도구) | awesome이 가리키는 게임 개발 목록 |
| [awesome-roblox/awesome-roblox](https://github.com/awesome-roblox/awesome-roblox) | 84 | CC0-1.0 | 2026-10-18 | 로블록스 자료 모음 | 별은 적지만 최근에도 고쳐짐 |
| [godotengine/godot](https://github.com/godotengine/godot) | 118,839 | MIT | 2026-10-22 | 게임 엔진 | 우리 게임엔 안 씀. 별이 가장 많은 축이라 적어 둠 |

**밸런스 전용 오픈소스는 이번 조사에서 확인한 게 없다.** 우리 `tools/econ_sim.py`, `fault_mix_sim.py`가 그 일을 하고 있다(이번에 검증한 대안이 없어 목록에 안 넣음).

---

## ⑦ 우리가 이미 쓰는 것과 겹침

| 우리 쪽 | 겹치는 레포 | 판단 |
|---|---|---|
| `DataService.luau`의 직접 만든 세션 잠금(오늘 추가) | ProfileStore | 비교·선택 거리 ('1번 자세히') |
| `default.project.json` + `src/` Rojo 이름 규칙, `tools/sync_to_studio.py`(Studio MCP로 밀어 넣음). **`rojo` 실행 파일은 PATH에 없음** | Rojo, Rokit | 규칙만 Rojo, 동기화는 자체 도구. Rojo를 쓰면 luau-lsp 연결까지 얻음 |
| `tools/luau_lint.py`(괄호·`end` 균형), `tools/compile_check.luau`(Studio에서 컴파일) | luau-lsp, Selene, luau-analyze | 컴퓨터에서 타입·API 오류까지 보려면 luau-lsp `analyze`가 가장 가까움 |
| 자체 `UIKit.luau` | Fusion, react-lua | 바꾸지 않기 |
| `Modules/Guard.luau`(Remote 값 검사) | zap, blink | 바꾸지 않기. 새 Remote를 만들 때만 참고 |
| `DataService.useStore` + `Dev/DevHooks` 가짜 저장소 | MockDataStoreService, `ProfileStore.Mock` | 지금 방식으로 충분 |
| `tools/create_gamepass.py`, `create_devproduct.py`, `grant_all.py` | Mantle | 이미 동작하는 걸 바꿀 이유 없음 |
| `tools/blender/qa_glb.py`, `glb_texture.py`, `quantize_pbr.py` | trimesh, glTF-Transform, glTF-Validator | 빠진 검사만 보태기 |
| Blender MCP(비슷한 일) | mcp-for-blender | 이미 씀 |
| `tools/studio_mcp.py` | run-in-roblox | 이미 씀 |
| ffmpeg 직접 호출(`sfx_*.py`), librosa(4개 파일), soundfile(1개), LUFS 재기(`sfx_finalize.py`) | pydub, librosa, ffmpeg-normalize, pyloudnorm | librosa는 이미 씀. 나머지는 새 이점 약함 |
| Pillow(`tools/` 파이썬 76개 파일), numpy(84개) | Pillow | 이미 씀 |

---

## 바로 해볼 순서 (제안)

1. **C2**: 오늘 들어온 직접 잠금을 Studio 2대(또는 `CoopTest`)로 시험하고, ProfileStore로 갈아탈지는 위 '1번 자세히'의 (A)/(B) 중 사용자·wr-dev가 고르기.
2. **검사 도구**: luau-lsp `analyze` + Selene을 한 번 돌려 결과만 보기(설치는 사용자 OK 뒤에).
3. **3D 무게**: 차 부품이 무거우면 meshoptimizer `gltfpack`을 한 부품에 시험해 모양이 안 깨지는지 눈으로 보기.
4. 아이콘·글꼴은 **그림체가 맞는지 눈으로 본 뒤**에만 쓰기. 글꼴은 게임 안엔 못 쓴다.

## 확인 방법과 출처

- 별·라이선스·마지막 push: `https://api.github.com/repos/<주인>/<이름>` (2026-10-22, 비로그인). 가장 별 많은 저장소: GitHub 검색 `stars:>300000`.
- ProfileStore: README·`docs/index.md`·`docs/api.md`·LICENSE는 `raw.githubusercontent.com`에서 읽음, 커밋·이슈는 GitHub 페이지, 글은 DevForum.
- 로블록스 공식 문서: `Roblox/creator-docs` 원문(`cloud-services/data-stores/player-data-purchasing.md`, `best-practices.md`, `index.md`, `projects/assets/index.md`).
- 이름이 바뀐 저장소(luau-lang/luau, linebender/resvg, ahujasid/mcp-for-blender)는 새 주소로 적었다.
