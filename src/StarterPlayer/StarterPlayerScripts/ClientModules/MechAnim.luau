-- Mechanic moves on my own character (wr-anim 10-22; grounds notes/research/mechanic_motions_1022.md §3 TOP 5, user
-- 10-22: "브레이크를 밟을 때 모션 같은 것 … 실제 정비소에서 어케 행동하는지"). Kneel by a wheel and lean over the engine bay
-- while I work there, swing the wrench / hold the impact wrench on the bolt the server just turned (the torque click
-- on the last wheel nut is made but held: MechAnim.HOLD), lift the hood and set its rod. Animator tracks on my character replicate, so a friend sees
-- them; my own camera hides me inside a work view (WorkView), so they are mostly for the others (10-23: showing my arms
-- there was tried and left out — notes/gpt/wr-anim/workview_arms_decision.md).
-- Off unless Config.feature("MechAnim") (main turns it on). Ids = the uploaded KeyframeSequences (made by
-- tools/anim/mech_anim.py → art/anim/*.rbxmx); a move without an id simply doesn't play. In Studio a sequence in
-- ReplicatedStorage.MechAnimDev stands in for a missing id (my screen only).
-- Nothing here changes the game: it only listens (WorkZone, Effect "bolt" / "hood", my hood / pump / stand prompts).
-- The one thing it moves is my own character, a step or two, onto the jack's handle while I pump and beside the
-- stand spot as I set a stand (my client owns my character: no new remote, the server's prompt checks don't change).
-- Not hooked yet: Mech_SitPedalPress (needs the driver's seat — the hands-on start flow).

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local MechAnim = {}

-- rbxassetid numbers once uploaded (group 572517831); 0 = not yet
MechAnim.IDS = {
	Mech_Lean = 90932476571643,
	Mech_Kneel = 120951326173339,
	Mech_BoltSweep = 85111950911875,
	Mech_BayGun = 89579172107640,
	Mech_WheelSweep = 91977185539545,
	Mech_WheelGun = 136835297787041,
	Mech_TorqueClick = 0,
	Mech_HoodRelease = 131131467091651,
	Mech_HoodLift = 129622541952861,
	Mech_PropRod = 114562971969083,
	Mech_JackPump = 96914339791345, -- (10-23 v3: upright, head up — notes/gpt/wr-anim/cup_jack_v4_decision.md; old 74539224439162 · 131097235768490)
	Mech_StandPlace = 78952453455467,
	Mech_StandPlace_L = 111262455875865, -- (the left arm's: the car on my left)
	Mech_SitPedalPress = 0,
	-- the slender-body versions (narrow torso, long legs, short arms): picked by slimBody() below
	Mech_Kneel_S = 0,
	Mech_WheelGun_S = 0,
	Mech_WheelSweep_S = 0,
}

-- made but not passed for launch (quality review 10-22, notes/gpt/wr-anim/): the torque click waits for a real torque
-- wrench tool; the seat one for the driver's seat. play() skips these.
MechAnim.HOLD = {
	Mech_TorqueClick = true,
	Mech_SitPedalPress = true,
}

-- where the keys put the body (tools/anim/mech_anim.py JACK_D / stand()): pumping, my root stands this far behind the
-- handle's end (mid stroke) facing the car; setting a stand, I crouch this far out from the stand spot facing it
local JACK_D = 1.0
local JACK_REACH = 1.97 -- the handle's base -> its end, flat, mid stroke (JackLook HANDLE_PUMP 40, measured)
local STAND_D = 2.3 -- (the hand reaches 1.95 out (0.2 short is fine: a hand is 0.5 thick) + the stand base 0.15: tools/anim/mech_anim.py STAND_HAND; the door panel is 0.65 out of the spot)
local STAND_AHEAD = 0.9
local PUMP_LOOP = 0.625 -- one stroke (JackService.handleAt: 1.6 Hz)
local HANDLE_TILT = 18 -- the Handle mesh's up axis sits this many degrees above JackLook's handle angle

local player = Players.LocalPlayer
local tracks: { [string]: AnimationTrack | false } = {}
local animator: Animator? = nil
local strokeUntil = 0
local stroke: string? = nil
local hoodCar: Model? = nil
local hoodAt = 0
local slim = false

local function idOf(name: string): string?
	local n = MechAnim.IDS[name]
	if n and n ~= 0 then
		return "rbxassetid://" .. n
	end
	if RunService:IsStudio() then
		local dev = ReplicatedStorage:FindFirstChild("MechAnimDev")
		local seq = dev and dev:FindFirstChild(name)
		if seq and seq:IsA("KeyframeSequence") then
			local ok, id = pcall(function()
				return game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(seq)
			end)
			return if ok then id else nil
		end
	end
	return nil
end

-- a body whose arms are short for its height (the slender avatars: arm 0.54 of the hip height, the blocky R15 0.72)
-- can't reach the wheel nut with the blocky body's keys: it gets the "_S" version, made on that body, when there is one
local function slimBody(char: Model): boolean
	local function gap(part: string, a: string, b: string): number?
		local p = char:FindFirstChild(part)
		local x, y = p and p:FindFirstChild(a), p and p:FindFirstChild(b)
		return if x and y and x:IsA("Attachment") and y:IsA("Attachment") then (x.Position - y.Position).Magnitude else nil
	end
	local upper = gap("RightUpperArm", "RightShoulderRigAttachment", "RightElbowRigAttachment")
	local lower = gap("RightLowerArm", "RightElbowRigAttachment", "RightWristRigAttachment")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not upper or not lower or not hum or hum.HipHeight <= 0 then
		return false
	end
	return (upper + lower) / hum.HipHeight < 0.63
end

local function track(name: string): AnimationTrack?
	local t = tracks[name]
	if t ~= nil then
		return t or nil
	end
	local id = animator and ((slim and MechAnim.IDS[name .. "_S"] ~= nil and idOf(name .. "_S")) or idOf(name))
	if not id then
		tracks[name] = false
		return nil
	end
	local a = Instance.new("Animation")
	a.AnimationId = id
	local ok, loaded = pcall((animator :: Animator).LoadAnimation, animator, a)
	tracks[name] = if ok then loaded else false
	return if ok then loaded else nil
end

function MechAnim.play(name: string, fade: number?, speed: number?): AnimationTrack?
	if not Config.feature("MechAnim") or MechAnim.HOLD[name] then
		return nil
	end
	local t = track(name)
	if t then
		t:Play(fade or 0.12, 1, speed or 1)
	end
	return t
end

function MechAnim.stop(name: string, fade: number?)
	local t = tracks[name]
	if t and t.IsPlaying then
		t:Stop(fade or 0.15)
	end
end

------------------------------------------------------------------------------------------------------- the work zone

-- standing over the engine bay / one knee down by a wheel, for as long as I'm in that zone
local function onZone()
	local zone = player:GetAttribute("WorkZone") :: string?
	local bay = zone == "EngineBay"
	local wheel = zone ~= nil and zone:sub(1, 6) == "Wheel_"
	if bay then
		MechAnim.play("Mech_Lean", 0.3)
	else
		MechAnim.stop("Mech_Lean", 0.25)
	end
	if wheel then
		MechAnim.play("Mech_Kneel", 0.3)
	else
		MechAnim.stop("Mech_Kneel", 0.25)
	end
	if not bay and not wheel and stroke then
		MechAnim.stop(stroke, 0.1)
		stroke = nil
	end
end

local function myRoot(): BasePart?
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
end

-- the bolt the server just turned is mine when, of everyone in a work zone, I stand nearest to it
local function boltIsMine(bolt: BasePart): boolean
	local me = myRoot()
	if not me or not player:GetAttribute("WorkZone") then
		return false
	end
	local mine = (me.Position - bolt.Position).Magnitude
	if mine > 9 then
		return false
	end
	for _, p in Players:GetPlayers() do
		local r = p ~= player and p:GetAttribute("WorkZone") and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if r and ((r :: BasePart).Position - bolt.Position).Magnitude < mine then
			return false
		end
	end
	return true
end

-- the tool goes round with the bolt (BoltLook turns it at the tool's own pace: about this long)
local PACE = { Wrench = 0.34, RatchetWrench = 0.22, ImpactWrench = 0.15 }

local function onBolt(data: any)
	local bolt = data.bolt
	if typeof(bolt) ~= "Instance" or not bolt:IsA("BasePart") or not boltIsMine(bolt) then
		return
	end
	local zone = player:GetAttribute("WorkZone") :: string
	local gun = data.tool == "ImpactWrench"
	local wheel = zone:sub(1, 6) == "Wheel_"
	-- the last wheel nut done up by hand: the torque wrench's smooth pull and its click
	if wheel and not gun and data.last and not MechAnim.HOLD.Mech_TorqueClick then
		if stroke then
			MechAnim.stop(stroke, 0.08)
			stroke = nil
		end
		MechAnim.play("Mech_TorqueClick", 0.1)
		return
	end
	local name = if wheel then (if gun then "Mech_WheelGun" else "Mech_WheelSweep") else (if gun then "Mech_BayGun" else "Mech_BoltSweep")
	if stroke and stroke ~= name then
		MechAnim.stop(stroke, 0.08)
	end
	stroke = name
	strokeUntil = os.clock() + (PACE[data.tool or ""] or 0.26) + 0.1
	local t = tracks[name]
	if not (t and t.IsPlaying) then
		MechAnim.play(name, 0.08)
	end
end

------------------------------------------------------------------------------------------------------- the hood

local function onHood(data: any)
	if not data.open or data.car ~= hoodCar or os.clock() - hoodAt > 2 then
		return
	end
	hoodCar = nil
	-- the hood swings up in 0.45 s (BoltLook.swing): hands go up with it, then set the rod
	MechAnim.stop("Mech_HoodRelease", 0.1)
	local lift = MechAnim.play("Mech_HoodLift", 0.1)
	if lift then
		task.delay(0.48, function()
			MechAnim.play("Mech_PropRod", 0.08)
		end)
	end
end

------------------------------------------------------------------------------------------------------- the jack

local function carOf(inst: Instance): Model?
	local car = inst:FindFirstAncestorWhichIsA("Model")
	while car and car.Parent and not car:GetAttribute("CarId") do
		car = car.Parent:FindFirstAncestorWhichIsA("Model")
	end
	return car
end

-- the 3D floor jack (JackLook: Jack3D) nearest a point: the bay's own jack set or a WorkGear copy
local function jackNear(at: Vector3): BasePart?
	local best, bestD = nil, 7
	for _, root in { workspace:FindFirstChild("Garage"), workspace:FindFirstChild("WorkGear") } do
		for _, m in (root and root:GetDescendants() or {}) do
			if m:IsA("Model") and m:GetAttribute("Jack3D") then
				local h = m:FindFirstChild("Handle")
				local d = (m:GetPivot().Position - at).Magnitude
				if h and h:IsA("BasePart") and d < bestD then
					best, bestD = h, d
				end
			end
		end
	end
	return best
end

-- the handle's base (by its hinge, it barely moves) and its flat direction out toward me
local function handleBase(h: BasePart): (Vector3, Vector3)
	local base = h.CFrame * Vector3.new(0, -h.Size.Y / 2, 0)
	local up = h.CFrame.UpVector
	local flat = Vector3.new(up.X, 0, up.Z)
	return base, if flat.Magnitude > 1e-3 then flat.Unit else Vector3.zAxis
end

-- the stroke's phase from the handle's angle: track time 0 = the top of the stroke (sin = 1)
local function strokeTime(prevK: number, k: number): number
	local s = math.asin(math.clamp(k, -1, 1))
	local phi = if k >= prevK then s else math.pi - s
	return ((phi - math.pi / 2) % (2 * math.pi)) / (2 * math.pi) * PUMP_LOOP
end

local function handleK(h: BasePart): number
	return (math.deg(math.asin(math.clamp(h.CFrame.UpVector.Y, -1, 1))) - HANDLE_TILT - 40) / 8
end

-- my root onto a flat spot, facing a way (only a short step: never across the bay)
local function stepTo(spot: Vector3, face: Vector3): boolean
	local root = myRoot()
	if not root or (Vector3.new(spot.X, root.Position.Y, spot.Z) - root.Position).Magnitude > 8 then
		return false
	end
	local at = Vector3.new(spot.X, root.Position.Y, spot.Z)
	root.CFrame = CFrame.lookAt(at, at + Vector3.new(face.X, 0, face.Z))
	return true
end

local pumpToken = 0
local function onPump(prompt: ProximityPrompt)
	local att = prompt.Parent
	local car = carOf(prompt)
	local h = att and att:IsA("Attachment") and jackNear(att.WorldPosition)
	local t = h and car and MechAnim.play("Mech_JackPump", 0.15)
	if not t or not h or not car then
		return
	end
	pumpToken += 1
	local token = pumpToken
	local lastRise, lastLift = os.clock(), (car:GetAttribute("LiftOffset") :: number?) or 0
	local prevK, synced = handleK(h), false
	local t0 = os.clock()
	while pumpToken == token and h.Parent and car.Parent do
		-- stand behind the handle's end, facing the car (the jack rolls in under the car as it starts to rise), but
		-- never out of the prompt's reach: stepping out of it would let go of the pump
		local base, out = handleBase(h)
		local spot = base + out * (JACK_REACH + JACK_D)
		local root = myRoot()
		if root then
			local at = (att :: Attachment).WorldPosition
			local dy = root.Position.Y - at.Y
			local flat = Vector3.new(spot.X - at.X, 0, spot.Z - at.Z)
			local most = math.sqrt(math.max(0, (Config.PromptDistance - 0.4) ^ 2 - dy * dy))
			if flat.Magnitude > most then
				spot = Vector3.new(at.X, spot.Y, at.Z) + flat.Unit * most
			end
		end
		stepTo(spot, -out)
		-- keep in step with the handle the server swings (once it's moving: my press reaches it a moment later)
		local k = handleK(h)
		if not synced and os.clock() - t0 > 0.15 and math.abs(k - prevK) > 0.02 then
			t.TimePosition = strokeTime(prevK, k)
			synced = true
		end
		prevK = k
		-- the server pumps while I hold, and on to the top once I've held it right through: stop once it stops
		local lift = (car:GetAttribute("LiftOffset") :: number?) or 0
		if lift > lastLift + 1e-4 then
			lastRise = os.clock()
		end
		lastLift = lift
		if os.clock() - lastRise > 0.25 and os.clock() - t0 > 0.4 then
			break
		end
		RunService.RenderStepped:Wait()
	end
	if pumpToken == token then
		MechAnim.stop("Mech_JackPump", 0.2)
	end
end

-- a stand under the sill: crouch beside its spot, facing it, and push it in
local function onStand(prompt: ProximityPrompt)
	local att = prompt.Parent
	local car = carOf(prompt)
	if not car or not att or not att:IsA("Attachment") or not Config.feature("MechAnim") then
		return
	end
	local spot = att.WorldPosition
	local pivot = car:GetPivot()
	local out = if (spot - pivot.Position):Dot(pivot.RightVector) >= 0 then pivot.RightVector else -pivot.RightVector
	-- kneel side-on to the car by the sill, STAND_D out from the spot and STAND_AHEAD short of it along my facing; the
	-- arm nearer the car does the reach: the car on my right = the right arm (Mech_StandPlace), on my left = the
	-- mirrored one. I stand toward the car's middle and face the end (the wheel is out there, the door panel by me).
	local toEnd = (spot - pivot.Position) - (spot - pivot.Position):Dot(pivot.RightVector) * pivot.RightVector
	local end_ = if toEnd.Magnitude > 0.1 then toEnd.Unit else pivot.LookVector
	local right = -out -- (the direction of my right hand if the car is on my right)
	local carOnRight = Vector3.yAxis:Cross(right):Dot(end_) >= 0 -- (then facing = Y x right points to the end)
	local face = if carOnRight then Vector3.yAxis:Cross(right) else Vector3.yAxis:Cross(-right)
	local at = spot + out * STAND_D - face * STAND_AHEAD
	-- (no id yet = no move: the character is only put there when the animation exists to play)
	local name = if carOnRight then "Mech_StandPlace" else "Mech_StandPlace_L"
	if track(name) and stepTo(at, face) then
		MechAnim.play(name, 0.1)
	end
end

------------------------------------------------------------------------------------------------------- start

local function onCharacter(char: Model)
	tracks = {}
	stroke = nil
	animator = nil
	local hum = char:WaitForChild("Humanoid", 10) :: Humanoid?
	local a = hum and hum:WaitForChild("Animator", 10)
	if a and a:IsA("Animator") and char.Parent then
		animator = a
		slim = slimBody(char)
		onZone()
	end
end

function MechAnim.start()
	player:GetAttributeChangedSignal("WorkZone"):Connect(onZone)
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		task.spawn(onCharacter, player.Character)
	end
	Remotes.Effect.OnClientEvent:Connect(function(name, data)
		if not Config.feature("MechAnim") or type(data) ~= "table" then
			return
		end
		if name == "bolt" then
			onBolt(data)
		elseif name == "hood" then
			onHood(data)
		end
	end)
	-- my hood prompt: the hand goes under the front edge for the latch while the server opens it
	ProximityPromptService.PromptTriggered:Connect(function(prompt, who)
		if who ~= player then
			return
		end
		if prompt.Name == "StandPrompt" then
			onStand(prompt)
			return
		end
		if prompt.Name ~= "HoodPrompt" then
			return
		end
		local car = carOf(prompt)
		if car and not car:GetAttribute("HoodOpen") then
			hoodCar, hoodAt = car, os.clock()
			MechAnim.play("Mech_HoodRelease", 0.1)
		end
	end)
	-- the jack's pump: held (PromptButtonHoldBegan fires for my own presses only)
	ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, who)
		if who == player and prompt.Name == "PumpPrompt" and Config.feature("MechAnim") then
			task.spawn(onPump, prompt)
		end
	end)
	-- a stroke stops once its bolt has gone round
	RunService.Heartbeat:Connect(function()
		if stroke and os.clock() > strokeUntil then
			MechAnim.stop(stroke, 0.1)
			stroke = nil
		end
	end)
end

return MechAnim
