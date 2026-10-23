# 진짜 지연 시험 (wr-mini, 10-23, Studio Play 1인)

방법: 서버가 세션을 열고 → 이 플레이어의 **진짜 클라이언트**가 `Remotes.MinigameInput`·`MinigameScrub`로 보냄(클라 시계로 hold·딸깍·문지르기) → 서버가 **받은 시각**으로 판정. 지연은 `settings().Network.IncomingReplicationLag`(execute_luau에서 설정 — 게임 스크립트는 `settings()` 못 부름). 사람 오차 σ = 0.08초(Torque = 딸깍 뒤 반응 0.28초 겨냥, Fill = Perfect 띠 가운데 겨냥), 밸런스·문지르기는 사람 흉내 간단판. 도구: `DevCall mg lag <종류들> <횟수> <σ> <lag> <밸런스 늦음> <흔들림 J>` + DevClient `mgtrial`·`mgbalance`·`mgscrub`(Studio 전용, 스위치 꺼진 채). 시험 뒤 lag 0으로 되돌림.

측정: Studio 기본 한쪽 지연 0.08초(ping은 0.001이라 서버 보정이 못 보는 지연), lag 0.3 → 한쪽 0.41초(= 0.08 + 약 1.1×lag).

## ① 고정 지연 (누름·뗌이 같이 늦음)
| 종류 | lag 0 | 0.15 | 0.30 |
|---|---|---|---|
| Torque | P4 G6 | P4 G4 | P3 G5 |
| Tire | P10 | P8 | P7 G1 |
| Coolant | P10 | P8 | P8 |
| Balance* | P7 G1 | P6 G2 | P2 G6 (미스 0~2) |
| Scrub | P10 | P8 | P8 |
| Polish | P8 | P8 | P8 |
n = 8~10, **넘침·부족·이상한 것 0, 끝까지 못 간 것 0.** (P=Perfect, G=Good)
→ 누름·뗌에서 상쇄돼 성공·Perfect가 거의 그대로(Torque Perfect는 σ 때문에 원래 반반).
*밸런스: 서버는 ping/2만 보정하는데 Studio ping은 0.001이라 **보정 안 된 한쪽 지연 0.08초가 그대로 미스**(lag 0에서도 처음엔 h0/m9). 클라가 '한쪽 지연'만큼 앞서 누르는 판(lead)으로 시험 → 위 표. 진짜 폰은 ping이 지연을 반영하므로 이 부분은 Studio 한계, 흔들림(ping 추정 오차)이 문제.

## ② 흔들림 (lag 0.15 + '뗌'만 U(0, J)초 늦게, n=12)
| 종류 | J=0.15 | J=0.30 |
|---|---|---|
| Torque | P3 G9 | P0 G11 **over 1** |
| Tire | P10 G2 | P5 G7 |
| Coolant | P10 **over 2** | P7 **over 5** |
→ Torque·Tire는 흔들림이 커져도 Good으로 떨어질 뿐 막히지 않음. **Coolant만 넘침**(Perfect 띠 위쪽 = 넘침 경계). 시뮬(jitter_sim_1023.md)과 같은 방향.

## 판단
- 6종 모두 150·300 ms 고정 지연에서 **일이 막히거나 이상해지지 않음** → 지연 때문에 뺄 이유 없음.
- 흔들림 150ms 이하는 문제 없음. 300ms급 흔들림에서만 Coolant over 40%(벌 없는 재시도) → 띠 조정 논의 `notes/gpt/wr-mini/lag_decision.md`.

## ③ 밸런스 탭 흔들림 (lag 0.15, 탭을 결정 뒤 U(0, late)초 늦게, 클라가 한쪽 지연만큼 앞서 누름)
- late 0.1: 6세션 모두 3칸 완료·미스 0 / late 0.25: 6세션 모두 완료, 미스 0·1·1·2·0·1 (P2 G4).
- 서버 ping/2 보정이 진짜 폰에서 흔들림을 얼마나 먹는지는 Studio로 못 봄 → 10/29 사람 시험에서 폰으로.

## 결과로 바뀐 것
냉각수 넘침을 `Slack = 0.03`만큼 부드럽게(F 바로 위는 Good) — `notes/gpt/wr-mini/lag_decision.md`. 흔들림 0.15 · F−0.02 겨냥: 넘침 39% → 2%.
