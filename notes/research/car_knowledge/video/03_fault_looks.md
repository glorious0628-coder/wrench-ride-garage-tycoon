# 영상 공부 3 — 고장 모습: 누유 색 · 단자 부식 (wr-carbook, 10-21)

> 내장 브라우저 유튜브(다운로드·로그인 X). 스크립트 창은 이 브라우저에서 계속 안 열려(아래 '막힌 것') **챕터 + 멈춘 화면**으로만 봤어요. 말로만 설명하는 영상은 화면에서 얻을 게 적어서 **챕터 목록만** 썼어요. 쓸 곳: wr-design `docs/design/fault_looks.md` §3(웅덩이·부식) 확인.

## 1. 누유(새는 액체) 색
| 영상 | 채널 | 길이 | 링크 | 본 방식 |
|---|---|---|---|---|
| The ULTIMATE Car Leak Color Guide! | Cars Simplified | 8:36 | https://www.youtube.com/watch?v=120qcd79Qjw | **챕터만**(화면은 말하는 사람뿐) |
| How to Identify Car Fluid Leaks by Smell and Color with Scotty Kilmer | YourMechanic | 4:31 | https://www.youtube.com/watch?v=FhPnctBuz30 | 멈춘 화면 |

**Cars Simplified 챕터 = 색 갈래 순서**(설명란): 빨강(0:37) → 주황(1:02) → 노랑·초록(1:22) → 파랑(1:46) → 보라·분홍(2:07) → 그 밖의 색(2:21) → **맑은 액체(2:42)** → 같은 색 두 액체 구별(3:57) → 색이 잘 안 보일 때(4:47) → **냄새**(5:13) → 얼마나 급한지(5:33).
- → fault_looks §3의 '색 + **자리** + **냄새** + 급한 정도'를 함께 쓰는 설계와 같은 구성(색만으로 맞히기 X). '같은 색 두 액체 구별'이 따로 챕터일 만큼 헷갈림이 실제로 있음 → 색 + 자리 조합이 맞는 방향.

**Scotty Kilmer(YourMechanic) 화면**
| 시간 | 본 것 | 링크 |
|---|---|---|
| 0:40 | 정비사가 **차 앞 범퍼 밑 바닥의 어두운 웅덩이 옆에 쪼그려 앉아** 가리킴 — 웅덩이는 **차 앞쪽 아래 아스팔트 위** | https://www.youtube.com/watch?v=FhPnctBuz30&t=40s |
| 1:25~2:10 | 보닛 열고 웅덩이 바로 위 엔진룸 부품을 짚으며 따라 올라감 — **아래 웅덩이 자리 → 위에서 새는 곳 찾기** 흐름 | &t=85s, &t=130s |
| 3:40 | **투명 컵에 주황빛 액체 샘플**을 들고 보여 줌 — 액체를 그릇에 받아 색을 비춰 보는 방법 | &t=220s |

**우리 게임에 쓰는 법**: ① 웅덩이는 **차를 들기 전 바닥**에서 먼저 보임(손님 차가 서 있던 자리) → 그 위 엔진룸 부품으로 '따라 올라가기'. ② 색 판정은 **흰 종이 타월·투명 컵**에 묻혀 보는 연출(바닥 아스팔트 위에선 다 검게 보이니까 — 이 '이유'는 영상 음성 미확인, 화면에서 컵에 받아 보여 주는 것만 확인).

## 2. 배터리 단자 부식
| 영상 (찾음, 이번엔 화면 못 봄) | 채널 | 길이 | 링크 |
|---|---|---|---|
| 5 Common Causes of a Battery Terminal Corrosion in Your Car & How to Prevent? | car PROblems | 4:35 | https://www.youtube.com/watch?v=Cc7FNbIgo1Y |
| Why do my Car Battery Terminals keep Corroding? | Mercie J Auto Care, llc | 2:39 | https://www.youtube.com/watch?v=6bgRRjJq6F0 |
| How to Clean Corroded Car Battery Terminals like a Pro | YOU Can Fix Anything: Auto | 3:22 | https://www.youtube.com/watch?v=ewuOf4aBqMQ |
- car PROblems 챕터(설명란) = 원인 5갈래: **수소 가스 새어 나옴(0:26) · 화학 반응(0:49) · 전해액 샘(1:09) · 과충전(1:23) · 물을 너무 많이 넣음(1:40)** → 고치기(1:52) → 막기(3:17). (내용은 음성이라 미확인 — 갈래 이름만.)
- 화면 확인은 다음 차례로 미룸(광고·로딩 때문에) — fault_catalog의 '(+) 파랑·초록 / (−) 흰·회색'은 여전히 **블로그 경향**으로만(규칙 X).

## 막힌 것 (메인 참고)
- 유튜브 **스크립트 창**: 이 내장 브라우저에선 '스크립트 표시' 버튼이 화면 밖에 있거나 아래쪽(설명란)이 로딩되지 않아 못 염. 스크립트 API(get_transcript)·자막 주소도 막힘(400 / 빈 응답). 스크립트를 보여 주는 외부 사이트는 **봇 확인 화면**이 떠서 쓰지 않음(우회 X).
- 그래서 지금은 **손·부품이 나오는 영상의 멈춘 화면 + 설명란 챕터**만 쓸 수 있어요. 말로만 설명하는 영상은 거의 못 씀 → 앞으로 **손으로 보여 주는 짧은 영상** 위주로 고를게요.
