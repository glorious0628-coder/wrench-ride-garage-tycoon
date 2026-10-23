# 튜토리얼 v0.3 글자 (작업 화면 위, 첫 차 3대) — wr-design, 2026-10-21

> wr-dev가 바로 쓰는 표. 흐름 = `work_view.md` v0.5 §5(Rosa·Tyler·3번째 차), §2b(잭·스탠드), §2d(스캔). 대본 = `tutorial_script.md`(대사·60/180초 목표 그대로).
> 키 표시: **유지** = 지금 Locale 그대로 / **바꿈** = 같은 키, 글자만 새로 / **새** = 새 키 / **안 씀** = 작업 화면에선 안 나옴(지워도 됨).
> 원문 영어(미국식), 한국어 = 번역. 할 일 줄은 짧게(영어 6단어 안팎).

## 1. Rosa — 배터리 (BAT_DEAD)
| # | 언제 넘어가나 | 키 | EN | KO | 표시 |
|---|---|---|---|---|---|
| 1 | 차가 섬 | `tut.firstJob` 유지 | YOUR FIRST JOB! | 첫 일이에요! | 배너 |
| 2 | Try to start 누름 | `tut.tryStart` 유지 | Try to start it | 시동을 걸어 봐요 | 운전석 문 빛남 |
| 3 | Scan 끝 | `tut.scanCar` **새** | Scan the car | 차를 스캔해요 | 작업 카드 Scan 버튼 통통 |
| 4 | 보닛 열림(작업 화면 자동) | `tut.openHood` 유지 | Open the hood | 보닛을 열어요 | 보닛 위 "Check here" |
| 5 | 배터리 탭(Scanner 자동 장착) | `tut.scanBattery` 유지 | Tap the battery with the Scanner | 스캐너로 배터리를 눌러요 | 배터리 빛남 |
| 6 | (자동 1.5초) | `tut.foundBattery` 유지 | Dead battery. You found it! | 배터리가 나갔어요. 찾았어요! | 빨강 + 딸깍 소리 |
| 7 | 주문 버튼 | `tut.order` 유지 | Order a battery ({money}) | 배터리 주문하기 ({money}) | 작업 카드 버튼 |
| 8 | 카트에 도착(카메라 0.3초 카트로) | `tut.cartArrive` **새** | It's on your cart! | 카트에 왔어요! | 카트에 '툭' |
| 9 | 볼트 3개 풀림 | `tut.loosenBattery` 유지 | (-) first, then (+), then the clamp | (-) 먼저, 그다음 (+), 그다음 고정쇠 | 볼트 위 1·2·3 + −/+ |
| 10 | 헌 배터리 들림 | `tut.liftOut` 유지 | Lift out the old battery | 헌 배터리를 들어내요 | 배터리 빛남 |
| 11 | 카트에 놓음 | `tut.toCart` **새** | Put it on the cart | 카트에 올려요 | Cart 버튼 통통 |
| 12 | 새 배터리 '착' | `tut.putIn` 유지 | Put the new one in | 새 걸 넣어요 | 빈 자리 점선 |
| 13 | 볼트 3개 조임 | `tut.tightenBattery` 유지 | (+) first, then (-), then the clamp | (+) 먼저, 그다음 (-), 그다음 고정쇠 | 1·2·3 |
| 14 | 시동(카메라가 차 전체로) | `tut.startUp` 유지 | Start it up! | 시동! | 작업 카드 큰 버튼 |
| 15 | 열쇠 돌려줌 | `tut.handBack` 유지 | Hand back the keys | 손님에게 열쇠를 돌려줘요 | 손님 빛남 |
| 16 | (덤) | `tut.scrap` 유지 | Scrap the old battery for {money} | 헌 배터리를 고물통에 넣으면 {money} | 카트 옆 고물통 |
| 17 | 레벨 업 | `tut.level2` · `tut.newJob` 유지 | Garage Level {level}! · New job: Brake Pads | 정비소 레벨 {level}! · 새 일: 브레이크 패드 | 카드 |

## 2. Tyler — 앞 왼쪽 브레이크 패드 (PAD_WORN)
| # | 언제 | 키 | EN | KO | 표시 |
|---|---|---|---|---|---|
| 1 | 끼익 들음 | `tut.pressBrakes` 유지 | Press the brakes | 브레이크를 밟아 봐요 | 운전석 문 |
| 2 | Scan 끝 | `tut.scanCar` (위와 같음) | Scan the car | 차를 스캔해요 | 앞 왼쪽 바퀴 "Check here" |
| 3 | 잭 자리 탭 → 3초 연출 | `tut.jackUp` **새** (`tut.raiseLift` 대신) | Tap the jack spot under the front | 차 앞 아래 잭 자리를 눌러요 | 앞 범퍼 아래 빛나는 동그라미 |
| 4 | "Work on wheel" | `tut.workWheel` **새** | Work on the front left wheel | 앞 왼쪽 바퀴를 작업해요 | 바퀴 빛남 |
| 5 | 너트 5개(첫 번만 한 번에) | `tut.loosenNuts` 유지 | Loosen the 5 lug nuts | 바퀴 너트 5개를 풀어요 | 너트 빛남 |
| 6 | 바퀴 빠짐 | `tut.rollWheel` **바꿈** | Swipe the wheel off | 바퀴를 옆으로 밀어 빼요 | 화살표 |
| 7 | 캘리퍼 볼트 2 | `tut.unbolt` 유지 | Unbolt the caliper | 캘리퍼 볼트를 풀어요 | |
| 8 | (자동) | `tut.worn` 유지 | Worn out! See how thin? | 다 닳았어요! 얇죠? | 패드 확대 |
| 9 | 헌 패드 2장 빠짐 | `tut.pullPads` **새** | Pull out the old pads | 헌 패드를 끌어서 빼요 | 패드 빛남 |
| 10 | 피스톤 원 꾹 | `tut.piston` 유지 | Push the piston back | 피스톤을 밀어 넣어요 | 캘리퍼 위 동그라미 |
| 11 | 카운터에서 삼 | `tut.buyPads` 유지 | Buy new brake pads | 새 브레이크 패드를 사요 | Exit 통통 → 카운터 |
| 12 | 다시 바퀴 앞 | `tut.backToWork` **새** | Your pads are on the cart. Back to the wheel! | 패드가 카트에 왔어요. 바퀴로 돌아가요! | 바퀴 Prompt |
| 13 | 새 패드 2장 '착' | `tut.putPads` 유지 | Put in the new pads | 새 패드를 넣어요 | 점선 |
| 14 | 캘리퍼 탭 | `tut.caliperDown` **새** | Tap the caliper to close it | 캘리퍼를 눌러 닫아요 | |
| 15 | 바퀴 '착' + 조임 | `tut.wheelBack` · `tut.holdTighten` 유지 | Put the wheel back on · Hold to tighten all | 바퀴를 다시 끼워요 · 꾹 눌러 전부 조이기 | |
| 16 | Lower car | `tut.lowerCar` **새** (`tut.lowerLift` 대신) | Lower the car | 차를 내려요 | Lower car 버튼 |
| 17 | Final check 끝 | `tut.finalCheck` **새** | Final check: scan it once more | 마지막 점검: 한 번 더 스캔해요 | Scan 버튼(초록 ✓) |
| 18 | | `tut.handBack` 유지 | Hand back the keys | 손님에게 열쇠를 돌려줘요 | |

## 3. 3번째 차 — 앞 왼쪽 타이어 못 (TIRE_FLAT, 용의자 카드)
| # | 언제 | 키 | EN | KO | 표시 |
|---|---|---|---|---|---|
| 1 | 손님 말 | `tut.say3` 유지 | My car pulls to the left, and something goes flap-flap-flap. | 차가 왼쪽으로 쏠리고 뭔가 펄럭펄럭 소리가 나요. | 말풍선 |
| 2 | 용의자 카드 | `tut.whatIsIt` · `tut.susBrakes` · `tut.susTire` 유지 | What could it be? · Brakes? · Tire? | 뭘까요? · 브레이크? · 타이어? | 카드 2장 |
| 3 | Scan | `tut.scanCar` | Scan the car | 차를 스캔해요 | 앞 왼쪽 "Check here" |
| 4 | 브레이크 조용 | `tut.pressBrakes` → `tut.susBrakesNo` 유지 | Brakes? Quiet. Not the brakes. | 브레이크? 조용해요. 브레이크는 아니에요. | 회색 도장 |
| 5 | 바퀴 구역에서 바퀴 돌림 | `tut.findIt` **새** | Spin the wheel and look closely | 바퀴를 돌려 가며 잘 봐요 | 타이어 빛남 |
| 6 | 못 찾음 | `tut.susTireYes` **바꿈** | Tire? A nail! That's it. | 타이어? 못이에요! 이거예요. | 빨간 도장 + 못 빛남 |
| 7 | 잭 3동작 직접 | `tut.jackYourself` **새** | Now you do it: jack, pump, stands | 이번엔 직접: 잭, 펌프, 스탠드 | 자리가 차례로 빛남 |
| 8 | 바퀴 교체 시작 | `tut.fixFlat` **바꿈** | Swap the whole wheel | 바퀴를 통째로 바꿔요 | |
| 9 | (작은 글) | `tut.noMachine` **새** | No tire machine yet, so swap the whole wheel. | 아직 타이어 기계가 없어서 바퀴를 통째로 바꿔요. | 작업 카드 아래 작은 글 |
| 10 | 새 바퀴(카운터 → 카트) · Lower car | `tut.hint.counter` · `tut.lowerCar` | | | |
| 11 | 출고 | `tut.why3` **바꿈** | The pull came from a nail in the tire. The brakes were quiet. | 쏠림은 타이어에 박힌 못 때문이었어요. 브레이크는 조용했죠. | 카트의 헌 바퀴에 못 |
| 12 | 끝 | `tut.goal3` 유지 | Reach Garage Level 3 | 정비소 레벨 3 만들기 | 튜토리얼 끝 |

## 4. 힌트 (20·40·60초 멈춰 있으면 — tutorial_script §5 규칙 그대로)
| 키 | 상태 | EN | KO |
|---|---|---|---|
| `tut.hint.door` | 유지 | Walk to the driver's door. | 운전석 문으로 걸어가요. |
| `tut.hint.front` | 유지 | Stand at the front of the car. | 차 앞에 서요. |
| `tut.hint.scan` | **새** | Tap Scan on your job card. | 작업 카드의 Scan을 눌러요. |
| `tut.hint.tapPart` | **새** (`tut.hint.scanner` 대신 — Scanner 자동 장착) | Tap the part that glows. | 빛나는 부품을 눌러요. |
| `tut.hint.bolt` | **바꿈** | Press and hold the glowing bolt. | 빛나는 볼트를 꾹 눌러요. |
| `tut.hint.pickup` | **바꿈** | Drag it up, or just tap it. | 위로 끌거나 그냥 눌러요. |
| `tut.hint.cart` | **새** | Tap Cart, then drop it on the cart. | Cart를 누르고 카트 위에 놓아요. |
| `tut.hint.carry` | **바꿈** | Drag it to the dotted spot. | 점선 자리로 끌어요. |
| `tut.hint.jack` | **새** (`tut.hint.lift` 대신) | Tap the glowing circle under the front bumper. | 앞 범퍼 아래 빛나는 동그라미를 눌러요. |
| `tut.hint.pump` | **새** | Press and hold Pump. | Pump를 꾹 눌러요. |
| `tut.hint.stands` | **새** | Tap both glowing stand spots. | 빛나는 스탠드 자리 두 곳을 눌러요. |
| `tut.hint.spin` | **새** | Drag across the tire to spin it. | 타이어를 끌어서 돌려요. |
| `tut.hint.piston` | **바꿈** | Hold the round button on the caliper. | 캘리퍼의 동그란 버튼을 꾹 눌러요. |
| `tut.hint.counter` | 유지 | Go to the parts counter. | 부품 카운터로 가요. |
| `tut.hint.exit` | **새** | Tap Exit to walk again. | 다시 걸으려면 Exit을 눌러요. |

**안 씀**(작업 화면에선 안 나옴): `tut.raiseLift`, `tut.lowerLift`, `tut.hint.lift`, `tut.hint.scanner`, `tut.hint.release`, `tut.setDown`, `tut.setDownHere`.

## 5. 작업 화면 공용 글자 (튜토리얼 밖에서도 — work_view v0.5)
| 키 | EN | KO |
|---|---|---|
| `act.workEngine` | Work on engine | 엔진 작업 |
| `act.workWheel` | Work on wheel | 바퀴 작업 |
| `act.slideUnder` | Slide under | 차 밑으로 |
| `act.lowerCar` | Lower car | 차 내리기 |
| `btn.exit` | Exit | 나가기 |
| `btn.cart` | Cart | 카트 |
| `btn.scan` | Scan | 스캔 |
| `btn.finalCheck` | Final check | 마지막 점검 |
| `btn.pump` | Pump | 펌프 |
| `btn.servicePos` | Service position | 정비 위치 |
| `scan.checkHere` | Check here | 여기 확인 |
| `n.standsFirst` | Place the jack stands first. | 먼저 잭 스탠드를 받쳐요. |
| `n.zoneBusy` | {name} is working here. | {name}님이 여기서 작업 중이에요. |
| `n.heightLocked` | {name} is under the car. | {name}님이 차 밑에 있어요. |
| `n.heightLockedWork` | {name} is working on this car. | {name}님이 이 차를 작업 중이에요. |
| `n.wrongSpot` | Wrong spot. | 그 자리가 아니에요. |
| `n.letCool` | It's hot. Let it cool first. | 뜨거워요. 먼저 식혀요. |
| `n.fixToo` | Want me to fix that too? | 그것도 고쳐 드릴까요? |
| `n.allGood` | All good! | 다 좋아요! |
