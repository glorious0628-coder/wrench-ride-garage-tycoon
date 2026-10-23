# 지연 '흔들림' 시험 틀 + 첫 결과 (wr-mini, 10-23)

틀 = `DevCall mg jitter <Torque|Tire|Coolant> <횟수> <사람 오차 sigma>` (DevHooks, Studio 전용).
진짜 `def.input`에 사람이 겨냥해 놓고 떼는 걸 넣고, '뗌'만 U(0,J)초 늦게 도착(고정 지연은 누름·뗌에서 상쇄 → 흔들림만 홀드 길이를 바꿈). J = 0 / 0.05 / 0.15 / 0.3.
Torque = 딸깍 d + 반응 0.28초 겨냥, Fill = Perfect 띠 가운데 겨냥. 첫 3번 넓게(wide)는 끈 상태(wide=1).

| 종류 (sigma) | J=0 | 0.05 | 0.15 | 0.30 |
|---|---|---|---|---|
| Torque (0.08) | P46 G55 | P25 G75 | P12 G88 | P7 G93 |
| Torque (0.05) | P38 G62 | P14 G86 | P5 G95 | P3 G97 |
| Tire (0.08) | P100 | P98 G2 | P85 G15 | P59 G41 |
| Tire (0.05) | P100 | P100 | P90 G10 | P59 G41 |
| Coolant (0.08) | P100 | P100 | P86 **over14** | P62 **over38** |
| Coolant (0.05) | P100 | P100 | P93 over7 | P62 over38 |

읽는 법
- **Torque**: 성공 창이 넓어(+0.7초) 어느 J에서도 재시도·실패 0. 흔들림은 Perfect(d~d+0.25)만 깎음. 늦게만 오니 Good으로 떨어질 뿐 손해 없음.
- **Tire**: Perfect 폭 ±0.5 psi = 0.33초 → J 0.15까지 85~90% 유지, 0.3에서 59%(나머지 Good, 실패 0).
- **Coolant**: Perfect 띠가 F선 바로 아래라 뗌이 늦으면 F를 넘어 'over'(벌 없는 재시도, 드레인 0.1) — J 0.15에서 7~14%, 0.3에서 38%. 성공 판정은 안 넓힘(결론 4).
- 해석: 실제 폰 흔들림 보통 ±50~100 ms → 모두 괜찮음. 150~300 ms 흔들림이 잦은 사람에겐 Coolant over가 눈에 띔 → 고치려면 Perfect 띠를 F 아래로 조금 더 내리고(예 [F-0.09, F-0.02]) '넘치면 드레인' 대신 Good으로 받기. **지금은 바꾸지 않음**(10/27 진짜 IncomingReplicationLag 시험 뒤 정함).
- 10/27 진짜 시험: Edit에서 `settings().Network.IncomingReplicationLag = 0.15 / 0.3` + Play 사람 손(또는 `user_mouse_input` instance_path) — 이 시뮬은 '고정 지연 상쇄·흔들림만' 가정이라 모양만 확인.
