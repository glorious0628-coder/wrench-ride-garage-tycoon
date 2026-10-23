# 손님이 커피 컵을 쥐고 앉기 — wr-dev에 줄 코드 (wr-anim 10-23)

**애니메이션**: `art/anim/Mech_SitCup.rbxmx`(오른팔만, Action 우선순위, 루프 8초: 컵을 손바닥 위에 세워 배 앞에 둠 → 가끔 입으로 한 모금 → 내림). 만드는 곳 `tools/anim/sit_cup.py`. 업로드 = 메인 → id가 나오면 아래 `MOVES.sitcup`에. 사진 `notes/playtest/wr-anim/coffee/`(00 = 지금: 컵이 무릎 옆에 달랑, 01 = 쉬는 모습, 02 = 한 모금, 03 = 옆모습). 컵 자리 = **오른손**(CoffeeService.holdIn 그대로, 무릎 위 `onLap`은 이 애니메이션이 없을 때만 쓰는 예비).

## 1) CustomerService.luau (손님 애니메이션, `MOVES` 근처)
```lua
local MOVES = {
	idle = "rbxassetid://507766666",
	walk = "rbxassetid://507777826",
	sit = "rbxassetid://2506281703",
	wave = "rbxassetid://507770239",
	sitcup = nil, -- Mech_SitCup (wr-anim): "rbxassetid://<메인이 올린 id>"; nil 동안은 애니메이션 없음(컵이 무릎 위, 예전대로)
}
```
`move()` 맨 위: `if not MOVES[name] then return nil end` · 우선순위 줄: `t.Priority = if name == "wave" or name == "sitcup" then Enum.AnimationPriority.Action else Enum.AnimationPriority.Core` · `base()`의 다른 트랙 끄는 줄 `if n ~= "wave" and n ~= name ...` → `if n ~= "wave" and n ~= "sitcup" and n ~= name ...`(앉아 있는 동안 sit 위에 계속 얹혀야 함).
새 함수(`speak` 줄 337 옆):
```lua
-- the coffee cup in a seated customer's right hand (Mech_SitCup over the stock sit); false = no animation yet
function CustomerService.sitCup(npc: Model, on: boolean): boolean
	local t = move(npc, "sitcup")
	if not t then
		return false
	end
	if on then
		t:Play(0.3)
	else
		t:Stop(0.3)
	end
	return true
end
CoffeeService.sitCup = CustomerService.sitCup
```
## 2) CoffeeService.luau
선언부(22~23줄 옆): `CoffeeService.sitCup = nil :: ((npc: Model, on: boolean) -> boolean)?`
`give()`의 `place` 함수(183~192줄)를 이렇게:
```lua
local function place(seated: boolean)
	if not cup.Parent then
		return
	end
	if seated then
		if CoffeeService.sitCup and CoffeeService.sitCup(npc, true) then
			holdIn(cup, hand) -- (in the right hand, the animation holds the arm up)
		else
			onLap(cup, npc) -- (no cup animation yet: on the lap as before)
		end
	else
		if CoffeeService.sitCup then
			CoffeeService.sitCup(npc, false)
		end
		holdIn(cup, hand)
	end
end
```
(`place(h.SeatPart ~= nil)`·`h.Seated:Connect(place)`는 그대로.)

## 시험 순서(Play, `Dev_Coffee`)
손님이 앉은 뒤 컵 주기 → 오른손 컵이 배 앞에서 위로 서 있고 가끔 입 쪽 → 일어서 나갈 때 팔 내려오고 컵은 손에 → 다시 앉으면 다시 쥠. id 0(nil)이면 예전처럼 무릎 위.
