## 파일별 정리 (표)

먼저 확인할 점: 깃허브 조사 문서는 설치·다운로드를 하지 않았다고 적혀 있고, 에셋 쇼핑 문서도 구매를 하지 않았다고 적혀 있습니다. 그래서 그 두 문서의 항목은 '조사만'으로 적었습니다. 실제로 받아 둔 것은 `art/_bought/` 아래 3개 폴더뿐입니다.

| 이름 | 종류 | 라이선스(문서 그대로) | 받아 둔 위치 | 문서가 말한 쓸 곳 | 문서의 쓰지 말 것·주의 |
|---|---|---|---|---|---|
| ProfileStore | 코드 | Apache-2.0 | 조사만 | 저장 + 세션 잠금(C2 비교) | 지금 `DataService.luau` 잠금과 비교 중. 갈아타면 옛 저장 모양을 옮기는 시험이 필요할 수 있음. 설치 안 함 |
| luau-lsp | 도구 | MIT | 조사만 | `analyze`로 타입·API 오류 검사 | 모듈 경로를 읽으려면 Rojo sourcemap이 필요한데, Rojo가 PATH에 없음 |
| Selene | 도구 | MPL-2.0 | 조사만 | 린터(안 쓰는 변수, 옛 함수 등) | Luau 파일 137개라 경고가 많을 수 있음. 규칙을 골라서 켜기 |
| Rojo | 도구 | MPL-2.0 | 조사만 | 파일↔Studio 동기화, sourcemap | 지금은 `sync_to_studio.py`를 씀. 개발 도구라 게임에 들어가지 않음 |
| RbxUtil | 코드 | MIT | 조사만 | Signal, Trove, Timer 등 | 전체를 넣지 말고 1~2개만. 기존 코드와 겹치는지 먼저 확인 |
| meshoptimizer | 도구 | MIT | 조사만 | 3D 메시 줄이기(`gltfpack`) | 부품 모양이 깨지지 않는지 눈으로 확인. 로블록스 메시 한도에 맞출 것 |
| trimesh | 도구 | MIT | 조사만 | 파이썬 메시 검사 | `qa_glb.py`와 겹침. 빠진 검사만 보태기 |
| glTF-Transform | 도구 | MIT | 조사만 | glb 검사, 텍스처 줄이기 | `glb_texture.py`, `quantize_pbr.py`와 겹침 |
| Tabler Icons | 아이콘 | MIT | 조사만 | 작은 HUD 기호 | 우리 캐주얼 그림체와 맞는지 눈으로 확인. 큰 그림에는 쓰지 않기 |
| ffmpeg-normalize | 도구 | MIT (LICENSE.md 확인) | 조사만 | 소리 크기 맞춤 | `sfx_finalize.py`가 이미 함. 비교용 |
| gvesster 무료 아이콘 팩 (Basic v3.1) | 아이콘 | 상업 게임 OK, 출처 선택. 고치기·되팔기·아이콘 팩 만들기 X (README 요약) | `art/_bought/free_icon_pack_gvesster/extracted/` | 설정, 닫기, 체크, 돈, 선물, 잠금, 저장, 망치, 시계 등 정비소 UI | 디스코드·트위터 등 외부 링크 아이콘 X. Robux는 공식 글리프 사용. 판타지·펫 아이콘 X. 색 바꾸기 X |
| itch Creator Bundle Vol.1 (RG Poly · EmaceArt) | 3D | RG Poly: CC0. EmaceArt: 게임 안 사용 OK, 되팔기·나눠주기·다른 팩에 넣기 X | `art/_bought/itch_creator_bundle_v1/` (cartoon_city, cars_1, cars_2, cars_megapack, harboria) | 지나가는 차, 주차된 차, 폐차장 더미, 거리 소품 | 손님 차는 우리 3D. 번들 차는 배경만. 원본을 남에게 주거나 공개 저장소에 올리지 않기. 그림체 확인 후 사용. Creator Store 공개·Allow Copying 끔 |
| Pizza Doggy 음향 (Cozy Tunes, Classics, Cozy FX) | 소리·음악 | 상업 OK, 고치기 OK, 출처 선택. 나눠주기·팔기 X, **AI에 넣기 X** | `art/_bought/pizzadoggy_audio/extracted/` | 배경 음악 20곡, 짧은 UI 효과음 37개 | AI(GPT·Codex·Claude)에 파일 보내기 금지. 소리 고르기는 사용자 귀로. Vienna Woods 약 10분은 자르기 필요. 오디오 비공개 업로드 |
| Sonniss Car Interiors ($35) | 소리 | Sonniss 라이선스 2.0 (게임 OK, 출처 X) | 조사만 | 문, 와이퍼, 경적, 깜박이, 브레이크 페달 | AI 입력 금지. 트랙리스트 106개 중 28개만 확인 |
| Sonniss Tools ($36) | 소리 | 위와 같음 | 조사만 | 임팩트·라쳇 렌치, 망치, 컴프레서 | 손 렌치(스패너) 없음. 5.9 GB |
| Sonniss Toyota Rav4 2004 ($25) | 소리 | 위와 같음 | 조사만 | 시동, 헛돎(false start), 점화 키, 문 | 'dead battery' 정확한 파일은 없음. 귀로 확인 |
| Sonniss Electric Cash Register ($25) | 소리 | 위와 같음 | 조사만 | 영수증 인쇄, 서랍, 버튼 | 계산대 종소리는 없음 |
| Stormwave 라쳇 + 가솔린 엔진 ($3.98) | 소리 | 가게 약관: 비디오 게임 사용 OK | 조사만 | 라쳇, 엔진 시동·공회전 | itch 압축 안 PDF는 구매 전에 못 읽음 |
| Sonniss GDC 2026 무료 묶음 (7.47 GB) | 소리 | 묶음 라이선스 2.0 (게임 OK, 출처 X) | 조사만 | 빈 곳 메우기 | 트랙리스트 페이지를 못 열어서 공구·시동이 있는지 모름. AI 입력 금지 |
| ProSoundEffects 무료 효과음 (Roblox 상점 ID) | 소리 | Roblox 문서: 무료 사용, ID로 게임에 쓰기 OK | 조사만 (ID 목록만 있음) | 보닛, 문, 트렁크, 키, 서랍, 공기, 배경 | 파일을 받을 수 없어 자르기·EQ 불가. 게임 안 재생은 Studio에서 확인 필요 |
| APM Music (Roblox 상점 무료) | 음악 | Roblox 상점 무료 | 조사만 | 배경 음악 후보 | 영화풍이 많음. 사용자 귀로 고르기 |
| Freesound CC0 (목록 9곳) | 소리 | 페이지마다 CC0 확인 | 조사만 | 임팩트 렌치, 소켓 렌치, 시동, 차고 배경 등 | 품질 들쭉날쭉. 브레이크 끽·타이어 바람·유압 잭은 쓸 만한 게 없었음 |
| Moon Animator 2 ($19.99) | 도구(플러그인) | 상점 정식 판매 | 조사만 | R15 자세 애니메이션 편집 | 필수 아님. 기본 Animation Editor로도 가능 |
| Animation Capture + RBXMonkey | 도구 | 로블록스 공식 기능(베타) / RBXMonkey 무료 | 조사만 | 영상 → 애니메이션, Blender 연결 | 베타라 결과가 거칠 수 있음. 영상 15초 이하 |
| Quaternius Universal Animation Library 1·2 | 3D 애니메이션 | CC0 | 조사만 | 참고용 사람 동작 | R15로 옮기는 일이 큼. 정비 자세는 없음 |
| Mixamo | 애니메이션 | 안 적힘(로블록스 허락 확인 못 함) | 조사만 | 무릎 꿇기, 앉기, 눕기 | 로그인 필요, 정비 동작 목록 확인 못 함. 보류 |
| gvesster Icon Pack ($16.99) | 아이콘 | 작가 글: 게임 OK, 수익 OK, 디자인 의뢰 판매만 라이선스 필요 | 조사만 | 공용 UI 아이콘 | 시뮬레이터·RNG 풍이 많아서 일부만 쓸 것. 공개 뒤에 |
| Highway Gothic · Special Elite (Roblox 내장 글꼴) | 글꼴 | Roblox 안 무료 | 조사만 (Roblox 내장) | 도로 표지판 글꼴, 영수증 타자기 글꼴 | 한글 지원 확인 못 함. 영문 간판·영수증용 |
| Kenney All-in-1 ($19.95) | 여러 종류 | 문서에 'CC0' 직접 적힘 X | 조사만 | 여러 에셋 묶음 | 정비소 소품 있는지 확인 못 함. 보류 |
| 보류 소리 묶음 (Pneuma, 동전, 유압 리프트, 금속 마찰 등) | 소리 | Sonniss 2.0 | 조사만 | 보조 소리 | 필요해지면 나중에 |
| 사지 말 것 (NoduoDev, Irchris5 등 정비소 소품, 일부 UI 키트, Magic Sound 등) | 3D·UI·소리 | 해당 없음 | 조사만 | — | AI 생성 표시, 그림체 불일치, 중복 등 이유가 문서에 적혀 있음 |
| Epidemic Sound · Artlist · Soundstripe · Envato | 소리 | 게임 사용 약관 확인 못 함 | 조사만 | — | 확인 전에는 쓰지 않기 |

## 못 씀 (GPL · AGPL · LGPL · NC · 라이선스 없음)

문서에 해당하는 항목은 없습니다. 깃허브 조사는 그런 라이선스를 목록에 넣지 않았다고 적혀 있습니다. 다만 Epidemic Sound·Artlist·Mixamo처럼 **라이선스를 확인 못 한** 항목은 '확인 전 사용 X'로 두었습니다.

## 공개(10/31) 전에 바로 쓸 만한 것 TOP 5

순위는 문서들이 권한 순서를 근거로 제가 정리한 것입니다. 파일 줄 번호는 문서에서 정확히 확인할 수 없어서, 문서 이름과 항목 이름으로 적습니다.

1. **지금 잠금 검증 시험(또는 ProfileStore 비교)**: `github_repos_1022.md`의 「1번 자세히」 '정리' 행에 "(A) 우리 잠금을 두고 Studio 2대 시험"이 공개 전 현실적이라고 적혀 있음.
2. **luau-lsp `analyze` + Selene 한 번 돌리기**: `github_repos_1022.md`의 「바로 해볼 순서」 2번(설치는 사용자 OK 뒤).
3. **gvesster 아이콘 쓰기 좋은 목록 적용**: `art/_bought/free_icon_pack_gvesster/README.md`의 「쓰기 좋은 것」 목록(원본 그대로 크기만 줄여 쓰기).
4. **ProSoundEffects 보닛·키·서랍 ID 시험**: `asset_shopping_1022.md`의 「다음 한 걸음」 1번(공짜, Studio에서 재생 확인 필요).
5. **Pizza Doggy 음악·UI 효과음 사용 검토**: `art/_bought/pizzadoggy_audio/README.md`의 「우리 규칙」(사용자 귀로 고르고, AI에는 파일을 보내지 않기).
