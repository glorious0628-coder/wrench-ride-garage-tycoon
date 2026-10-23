# Ella 동작 4개 — 번호 + 붙이는 법 (wr-anim 10-23, wr-dev·메인용)

**번호(그룹 572517831, 진짜 번호로 Studio Play에서 로드·길이·루프·우선순위 확인함, 장부 `art/anim/anim_ids.json`)**
| 이름 | id | 길이 | 루프 | 우선순위 | 뭐 | 파일 |
|---|---|---|---|---|---|---|
| Mech_EllaWalk | **100124932349363** | 0.85초 | 예 | Core | 작은 걸음(엉덩이 +20.4/−16.1°·무릎 최대 33°·어깨 ±5° 비틀림·팔 ±11°) | `art/anim/Mech_EllaWalk.rbxmx` |
| Mech_EllaIdle | **121877589006487** | 3.6초 | 예 | Core | 서 있기(팔이 치마 쪽 A자, 숨쉬기) | `Mech_EllaIdle.rbxmx` |
| Mech_EllaSit | **80736877965889** | 4.8초 | 예 | Core | 앉기(앉은 치마용: 무릎 모으고 손을 치마 위에 얌전히, 허리 곧게) | `Mech_EllaSit.rbxmx` |
| Mech_EllaWave | **84151447095285** | 2.3초 | 아니오 | Action(오른팔·머리만) | 도착 장면 1c 손 흔들기(들기 0.35초 → 3번 흔들기 → 잠깐 들고 있기 → 내리기) | `Mech_EllaWave.rbxmx` |
만드는 곳 `tools/anim/ella_anim.py`(몇 초; `--check` 없음), 점검 `tools/anim/ella_blender.py`(Ella 진짜 메시를 이 키 각도 그대로 Blender에서 자세 잡아 치마 뚫림 셈) · `ella_wave_scan.py`·`ella_scan2.py`(각도 탐색). 결정·사진 `notes/gpt/wr-anim/ella_decision.md`·`notes/playtest/wr-anim/ella/`.

## 몸 쪽 전제 (wr-dev가 꼭)
- 이 동작은 **Ella 몸(`art/3d/ella_v2`) 기준**: 관절 높이 엉덩이 2.0·무릎 1.178·발목 0.252(허벅지 0.822·정강이 0.926) → **`Humanoid.HipHeight = 2.0`**, `AuthoredHipHeight` 2.0(KFS에 적어 둠). 지금 Studio 기본 R15는 HipHeight 2.192라 Ella 메시를 얹고 HipHeight를 안 맞추면 발이 0.19칸 뜨고, 이 동작은 기본 R15에서도 돌긴 하지만 다리 길이가 달라 발이 땅에서 뜨거나 파묻힘.
- 걷기 **속도**: 한 번(0.85초)에 지면 위로 발이 지나는 길이가 1.1칸/반주기 → **안 미끄러지는 속도 = 2.6칸/초(재생 ×1)**. 보폭을 늘리면 치마 밑단을 뚫어서(엉덩이 ±25° 상한) 못 늘림. **Ella 걷기는 `WalkSpeed ≈ 5`·트랙 재생 속도 `speed / 2.6`(= 약 1.9)** 로(GPT r2 동의), 8~14칸/초로 달리게 하지 말고 빠른 이동은 컷으로. 옆모습 재생에서 지지 발이 바닥에 고정되는지는 Ella 메시가 들어간 뒤 사진 한 장 더(부탁하면 내가 찍음).

## CustomerService 쪽 (손님 동작 아이디 — Ella만 다른 번호)
`MOVES`(idle·walk·sit·wave)는 지금 모든 NPC가 같은 스톡 번호. Ella 몸일 때만 다른 번호를 쓰게:
```lua
local ELLA_MOVES = {
	idle = "rbxassetid://121877589006487", walk = "rbxassetid://100124932349363",
	sit = "rbxassetid://80736877965889", wave = "rbxassetid://84151447095285",
}
-- move(): 아이디를 고를 때  local ids = if npc:GetAttribute("EllaBody") then ELLA_MOVES else MOVES  (npc에 EllaBody 속성을 makeNpc("Ella")가 true로)
--   a.AnimationId = ids[name];  (sitcup은 Ella에겐 없음 — 앉은 Ella는 컵 없이 손을 치마에, 컵을 쥐면 sitCup 대신 그대로 둠)
-- animate()의 걷기: base("walk", math.clamp(speed / 14, 0.6, 1.6))  →  Ella: base("walk", speed / 2.6)  (WalkSpeed 5면 1.92)
-- wave 우선순위는 이미 Action(오른팔·머리만, 다른 부위는 걷기·서기가 그대로)
```
- 우선순위: 걷기·서기·앉기 = Core(스톡과 같이 하나만 재생, `base()`가 다른 것을 0.2초 페이드로 끔), 손 흔들기 = Action(위에 얹힘).
- 앉기 위 컵 쥐기(`Mech_SitCup`)는 일반 손님 몸 기준 — Ella가 컵을 받으면 오른팔을 따로 정해야 함(필요하면 알려 줘요).
