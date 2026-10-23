-- NPC customers (기획서 2장 루프 A, 3장 손님 AI), following world_contract v1:
--   car drives Traffic.RoadIn → EntryCurb → LaneEast → Bay.ApproachSpot → Bay.CarSpot, the R15 driver gets out at
--   DriverExitSpot, says what's wrong (speech bubble, the first fault), walks BayDoor → ReceptionDesk.ServicePoint →
--   a free WaitingRoom seat and waits. After "Hand car back" (JobService) the customer walks back, reacts, and the
--   car backs out: CarSpot → ApproachSpot → LaneWest → ExitCurb → RoadOut. Then the bay takes the next customer.
-- The line (main 10-22, notes/gpt/main/downtime_main_decision.md): while every bay works, the next customer already
--   waits in a WAIT HERE stall in front of Bay 1 by their car; the bay frees the moment the old car is out of it,
--   and the one waiting drives straight in (~4 s) and says what's wrong as they get out.

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local FaultService = require(script.Parent.FaultService)
local JobService = require(script.Parent.JobService)
local DiagnosisService = require(script.Parent.DiagnosisService)
local PlayerData = require(script.Parent.PlayerData)
local GateService = require(script.Parent.GateService)
local Metrics = require(script.Parent.Metrics)
local Faults = require(ReplicatedStorage.Shared.Faults)
local Places = require(script.Parent.Places)
local CoffeeService = require(script.Parent.CoffeeService)

local CustomerService = {}

CustomerService.forceNext = nil :: { string }? -- play tests: the next car's broken slots
CustomerService.forceKind = nil :: string? -- play tests: the next customer's kind
CustomerService.forceType = nil :: string? -- play tests: the next car's CarType
CustomerService.onJobDone = nil :: ((p: Player, money: number, spotOn: boolean, team: { Player }, kind: string, happy: boolean) -> ())? -- ShiftService.job
CustomerService.onHandBack = nil :: ((car: Model) -> ())? -- CurbService: a bay job handed back (counts toward a quick job)
CustomerService.tutorialPick = nil :: ((ahead: boolean?, ignore: Model?) -> { [string]: any }?)? -- TutorialService.pick: the scripted customers
CustomerService.onTutorialCar = nil :: ((car: Model) -> ())?
CustomerService.afterTutorial = false -- TutorialService: someone just finished it (the next ordinary car is a new job)
local AFTER_TUTORIAL_AVOID = { Battery = true, BrakePads = true, TIRE_FLAT = true }
-- special customers (HalloweenService): no ordinary customers while held; the next car is this one; hooks around
-- the hand-back (afterRelease: every job; onSpecialStart: the special car fires up; specialDrive: takes over the
-- drive away and returns true)
CustomerService.hold = false
CustomerService.special = nil :: { kind: string, plan: { any }, carType: string?, paint: Color3?, say: string?, hello: string?, good: string? }?
CustomerService.afterRelease = nil :: ((car: Model, result: any) -> ())?
CustomerService.onSpecialStart = nil :: ((car: Model) -> ())?
CustomerService.specialDrive = nil :: ((car: Model, legs: { any }) -> boolean)?

local rng = Random.new()
local customers: { [Model]: Model } = {} -- car -> NPC
local seatTaken: { [Seat]: Model } = {}

local SKIN = { Color3.fromRGB(255, 224, 189), Color3.fromRGB(234, 192, 134), Color3.fromRGB(198, 134, 66), Color3.fromRGB(141, 85, 36), Color3.fromRGB(96, 57, 19) }
local SHIRT = { Color3.fromRGB(52, 101, 164), Color3.fromRGB(196, 40, 28), Color3.fromRGB(75, 151, 75), Color3.fromRGB(245, 205, 48), Color3.fromRGB(99, 95, 98), Color3.fromRGB(255, 255, 255) }
local PANTS = { Color3.fromRGB(39, 70, 120), Color3.fromRGB(40, 40, 44), Color3.fromRGB(110, 90, 70) }

local function pickOf<T>(t: { T }): T
	return t[rng:NextInteger(1, #t)]
end

----------------------------------------------------------------------------------------------------------------
-- driving: a list of points; the car faces where it goes (or the other way when backing up) and turns smoothly
----------------------------------------------------------------------------------------------------------------
type Leg = { to: Vector3, speed: number, back: boolean? }

local function yawOf(dir: Vector3): number
	local _, y = CFrame.lookAt(Vector3.zero, Vector3.new(dir.X, 0, dir.Z)):ToEulerAnglesYXZ()
	return y
end

local function drive(car: Model, legs: { Leg })
	local base = (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
	local pos = base.Position
	local _, yaw = base:ToEulerAnglesYXZ()
	for _, leg in legs do
		local total = (leg.to - pos).Magnitude
		local start = pos
		local gone = 0
		while gone < total do
			local dt = RunService.Heartbeat:Wait()
			if not car.Parent then
				return
			end
			gone = math.min(total, gone + leg.speed * dt)
			pos = start:Lerp(leg.to, gone / total)
			local dir = (leg.to - start).Unit * (if leg.back then -1 else 1)
			local want = yawOf(dir)
			local diff = (want - yaw + math.pi) % (2 * math.pi) - math.pi
			-- (faster on the road, so the nose keeps up with the way it goes: no sliding sideways over a curb)
			yaw += diff * math.min(1, dt * math.max(3.5, leg.speed * 0.25))
			car:SetAttribute("BaseCFrame", CFrame.new(pos) * CFrame.Angles(0, yaw, 0))
			CarFactory.pose(car)
		end
	end
end

local function point(path: string): Vector3?
	local m = Places.find(path) :: BasePart?
	return m and m.Position
end

-- a road route by marker names (each { name, speed }), the ones the map doesn't have skipped. Cars stay on the
-- roadway: they cross the sidewalk only at a curb cut, and a corner leg goes at parking speed (wr-builder 10-22:
-- the straight RoadIn -> EntryCurb ran 120 studs over the sidewalk — user "the cars drive on the sidewalk")
local function route(points: { { any } }): { Leg }
	local legs: { Leg } = {}
	for _, p in points do
		local at = point(p[1])
		if at then
			table.insert(legs, { to = at, speed = p[2] })
		end
	end
	return legs
end

-- off the lot and away: the drive lane west, out the exit cut, a right turn onto the avenue
local function exitLegs(): { Leg }
	return route({
		{ "Traffic.LaneWest", Config.CarDriveSpeed * 0.5 },
		{ "Traffic.ExitCurb", Config.CarParkSpeed },
		{ "Traffic.ExitTurn", Config.CarParkSpeed },
		{ "Traffic.RoadOut", Config.CarDriveSpeed },
	})
end

----------------------------------------------------------------------------------------------------------------
-- the customer NPC
----------------------------------------------------------------------------------------------------------------
-- Roblox's own R15 moves (the rig's Animate is a LocalScript, which never runs on a server NPC: customers slid about
-- in the rest pose and sat in the waiting room arms out, half sideways — wr-gamer a23). One track each, reused.
local MOVES = {
	idle = "rbxassetid://507766666",
	walk = "rbxassetid://507777826",
	sit = "rbxassetid://2506281703",
	wave = "rbxassetid://507770239",
	sitcup = "rbxassetid://135266351280446" :: string?, -- Mech_SitCup (wr-anim, right arm over the stock sit): "rbxassetid://<id>" once main uploads it; nil = no cup animation (the cup rests on the lap)
}
local tracks: { [Model]: { [string]: AnimationTrack } } = {}

local function move(npc: Model, name: string): AnimationTrack?
	if not MOVES[name] then
		return nil
	end
	local h = npc:FindFirstChildOfClass("Humanoid")
	if not h then
		return nil
	end
	local mine = tracks[npc]
	if not mine then
		mine = {}
		tracks[npc] = mine
		npc.Destroying:Connect(function()
			tracks[npc] = nil
		end)
	end
	if not mine[name] then
		local animator = h:FindFirstChildOfClass("Animator") or Instance.new("Animator")
		animator.Parent = h
		local a = Instance.new("Animation")
		a.AnimationId = MOVES[name]
		local ok, t = pcall(animator.LoadAnimation, animator, a)
		if not ok then
			return nil
		end
		t.Priority = if name == "wave" or name == "sitcup" then Enum.AnimationPriority.Action else Enum.AnimationPriority.Core
		t.Looped = name ~= "wave"
		mine[name] = t
	end
	return mine[name]
end

-- idle / walk / sit follow the humanoid by themselves; the wave plays over them
local function animate(npc: Model)
	local h = npc:FindFirstChildOfClass("Humanoid") :: Humanoid
	local now = ""
	local function base(name: string, speed: number?)
		local t = move(npc, name)
		if t and speed then
			t:AdjustSpeed(speed)
		end
		if name == now then
			return
		end
		for n, other in tracks[npc] or {} do
			if n ~= "wave" and n ~= "sitcup" and n ~= name and other.IsPlaying then
				other:Stop(0.2)
			end
		end
		now = name
		if t then
			t:Play(0.2)
			if speed then
				t:AdjustSpeed(speed)
			end
		end
	end
	local stopId = 0
	h.Running:Connect(function(speed)
		if h.Sit then
			return
		end
		stopId += 1
		if speed > 0.5 then
			base("walk", math.clamp(speed / 14, 0.6, 1.6))
		else
			-- (a path stops for a blink at each waypoint: stand only if it stays stopped)
			local id = stopId
			task.delay(0.25, function()
				if id == stopId and not h.Sit and npc.Parent then
					base("idle")
				end
			end)
		end
	end)
	h.Seated:Connect(function(on)
		base(if on then "sit" else "idle")
	end)
	base("idle")
end

local function makeNpc(kind: string): Model?
	local desc = Instance.new("HumanoidDescription")
	local skin = pickOf(SKIN)
	desc.HeadColor = skin
	desc.LeftArmColor = skin
	desc.RightArmColor = skin
	desc.TorsoColor = pickOf(SHIRT)
	local pants = pickOf(PANTS)
	desc.LeftLegColor = pants
	desc.RightLegColor = pants
	local look = Config.NpcLooks[kind] -- (a special customer's own colours / clothes)
	if look then
		desc.TorsoColor = look.torso or desc.TorsoColor
		desc.LeftLegColor = look.legs or desc.LeftLegColor
		desc.RightLegColor = look.legs or desc.RightLegColor
		desc.LeftArmColor = look.arms or desc.LeftArmColor
		desc.RightArmColor = look.arms or desc.RightArmColor
		desc.Shirt = look.shirt or 0
		desc.Pants = look.pants or 0
		desc.HairAccessory = look.hair or ""
	end
	local ok, npc = pcall(function()
		return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	end)
	if not ok or not npc then
		warn("[CustomerService] could not make an NPC: " .. tostring(npc))
		return nil
	end
	npc.Name = "Customer"
	local hum = npc:FindFirstChildOfClass("Humanoid") :: Humanoid
	hum.WalkSpeed = Config.CustomerWalkSpeed
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	-- no sitting on whatever seat it brushes past (the bay has a creeper): only the waiting-room seat, on purpose
	hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	-- name + speech bubble over the head (text from Locale keys, each client in its own language)
	local head = npc:FindFirstChild("Head") :: BasePart
	local gui = Instance.new("BillboardGui")
	gui.Name = "Bubble"
	gui.Size = UDim2.fromOffset(260, 100)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.MaxDistance = 60
	gui.AlwaysOnTop = true
	gui.Parent = head
	local say = Instance.new("TextLabel")
	say.Name = "Say"
	say.Size = UDim2.new(1, 0, 1, -32)
	say.BackgroundColor3 = Color3.new(1, 1, 1)
	say.BackgroundTransparency = 0.05
	say.TextColor3 = Color3.fromRGB(30, 30, 34)
	say.Font = Enum.Font.GothamBold
	say.TextSize = 16
	say.TextWrapped = true
	say.Visible = false
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = say
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = say
	say.Parent = gui
	local name = Instance.new("TextLabel")
	name.Name = "Name"
	name.Size = UDim2.new(1, 0, 0, 20)
	name.Position = UDim2.new(0, 0, 1, -28)
	name.BackgroundTransparency = 1
	name.TextColor3 = Color3.new(1, 1, 1)
	name.TextStrokeTransparency = 0.3
	name.Font = Enum.Font.GothamBold
	name.TextSize = 16
	Locale.tag(name, "npc." .. kind)
	if kind == "VIP" then
		name.TextColor3 = Color3.fromRGB(255, 215, 90)
	end
	name.Parent = gui
	-- patience: a thin bar under the name (CustomerService.showPatience fills and colours it)
	local bar = Instance.new("Frame")
	bar.Name = "Patience"
	bar.Size = UDim2.new(0.4, 0, 0, 6)
	bar.Position = UDim2.new(0.3, 0, 1, -6)
	bar.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
	bar.BorderSizePixel = 0
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BorderSizePixel = 0
	fill.BackgroundColor3 = Color3.fromRGB(90, 210, 110)
	fill.Parent = bar
	bar.Parent = gui
	-- (tracks load once it's in the world: every caller parents it itself)
	local wired = false
	npc.AncestryChanged:Connect(function()
		if not wired and npc:IsDescendantOf(workspace) then
			wired = true
			animate(npc)
		end
	end)
	return npc
end

local function speak(npc: Model, key: string, seconds: number?)
	local gui = npc:FindFirstChild("Bubble", true)
	local say = gui and gui:FindFirstChild("Say") :: TextLabel?
	if not say then
		return
	end
	Locale.tag(say, key)
	say.Visible = true
	local token = (say:GetAttribute("Token") or 0) + 1
	say:SetAttribute("Token", token)
	task.delay(seconds or 6, function()
		if say.Parent and say:GetAttribute("Token") == token then
			say.Visible = false
		end
	end)
end
CoffeeService.say = speak -- ("Thanks!" as the cup comes)

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

local function moveStraight(hum: Humanoid, npc: Model, pos: Vector3): boolean
	hum:MoveTo(pos)
	local done = false
	local conn = hum.MoveToFinished:Connect(function(reached)
		done = true
	end)
	local t0 = os.clock()
	local limit = (npc:GetPivot().Position - pos).Magnitude / Config.CustomerWalkSpeed + 2
	while not done and os.clock() - t0 < limit and npc.Parent do
		task.wait(0.1)
	end
	conn:Disconnect()
	return done
end

-- walk around desks and walls (PathfindingService); a straight walk if no path; a hop there if stuck. A newer walk of
-- the same NPC takes over (the older one just stops)
local function walkTo(npc: Model, pos: Vector3?)
	if not pos or not npc.Parent then
		return
	end
	local token = ((npc:GetAttribute("WalkId") :: number?) or 0) + 1
	npc:SetAttribute("WalkId", token)
	local hum = npc:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if not hum then
		return
	end
	local path = PathfindingService:CreatePath({ AgentRadius = 1.5, AgentHeight = 5.5, AgentCanJump = false, WaypointSpacing = 4 })
	local ok = pcall(function()
		path:ComputeAsync(npc:GetPivot().Position, pos)
	end)
	local arrived = true
	if ok and path.Status == Enum.PathStatus.Success then
		for i, wp in path:GetWaypoints() do
			-- (gone while the path was worked out — sent home: a nil humanoid error, wr-gamer fun 1)
			if npc:GetAttribute("WalkId") ~= token or not npc.Parent or not hum.Parent then
				return
			end
			if i > 1 and not moveStraight(hum, npc, wp.Position) then
				arrived = false
				break
			end
		end
	else
		arrived = moveStraight(hum, npc, pos)
	end
	if npc:GetAttribute("WalkId") ~= token then
		return
	end
	if npc.Parent and (not arrived or (npc:GetPivot().Position - pos).Magnitude > 4) then
		npc:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0))) -- stuck on something: just get there
		npc:SetAttribute("Hops", (npc:GetAttribute("Hops") or 0) + 1) -- (play tests count these)
		npc:SetAttribute("HopsTo", ((npc:GetAttribute("HopsTo") or "") :: string) .. string.format("(%.0f,%.0f)", pos.X, pos.Z))
	end
end

local function freeSeat(npc: Model): Seat?
	for _, s in Places.seats() do
		if not s.Occupant and not seatTaken[s] then
			seatTaken[s] = npc
			return s
		end
	end
	return nil
end

----------------------------------------------------------------------------------------------------------------
-- customer kinds (alpha_scope v0.2 §1): who comes, and how patient they are
----------------------------------------------------------------------------------------------------------------
local nextVisit: { [string]: number } = { Rosa = 0, Tyler = 0, VIP = 0 } -- earliest os.clock() each may come again
local here: { [string]: boolean } = {} -- named customers / VIP currently at the garage (never two at once)

local function pickKind(level: number, first: boolean): string
	if first then
		return "Regular"
	end
	local now = os.clock()
	for _, name in { "VIP", "Rosa", "Tyler" } do
		local k = Config.CustomerKinds[name]
		if level >= k.fromLevel and #Players:GetPlayers() >= (k.minPlayers or 1) and now >= nextVisit[name] and not here[name] then
			nextVisit[name] = now + rng:NextInteger(k.every[1], k.every[2])
			return name
		end
	end
	local h = Config.CustomerKinds.Hurry
	if level >= h.fromLevel and rng:NextNumber() < h.chance then
		return "Hurry"
	end
	return "Regular"
end

-- the last customer cars, newest last: { type, kit, paint } (Config.CarVariety: no two alike in a row)
type Look = { type: string, face: string, rim: string, extra: string, pattern: string, paint: Color3 }
local recent: { Look } = {}

-- the car they come in (Config.CarTypeShare, the sedan takes the rest): never the last car's type, and with 3+
-- types none of the last Recent ones (user 10-22) — when the garage has that many to choose from. Named regulars
-- come in their own (Config.RegularLooks); not plain (tutorial / test / special) = a sedan
local function pickType(level: number, kind: string, plain: boolean): string
	local own = Config.RegularLooks[kind]
	if own then
		return own.type
	end
	if not plain then
		return "Sedan"
	end
	local options: { { any } } = {}
	local rest = 1
	for _, t in Config.CarTypeShare do
		if level >= t.fromLevel and CarParts.baked(t.type) then
			table.insert(options, { t.type, t.share })
			rest -= t.share
		end
	end
	table.insert(options, { "Sedan", math.max(0.05, rest) })
	local function pickFrom(avoidN: number): string?
		local avoid = {}
		for i = #recent, math.max(1, #recent - avoidN + 1), -1 do
			avoid[recent[i].type] = true
		end
		local total, left = 0, {}
		for _, o in options do
			if not avoid[o[1]] then
				table.insert(left, o)
				total += o[2]
			end
		end
		if #left == 0 then
			return nil
		end
		local roll = rng:NextNumber() * total
		for _, o in left do
			roll -= o[2]
			if roll <= 0 then
				return o[1]
			end
		end
		return left[#left][1]
	end
	return pickFrom(if #options >= 3 then Config.CarVariety.Recent else 1) or pickFrom(1) or options[1][1]
end

-- the car's look: a regular's own, else a random kit and paint unlike the last car's (same type -> a different kit)
local function pickLook(carType: string, kind: string): Look
	local own = Config.RegularLooks[kind]
	if own then
		return table.clone(own) :: any
	end
	local v = Config.CarVariety
	local last = recent[#recent]
	local look: Look = nil :: any
	for _ = 1, 12 do
		look = {
			type = carType,
			face = pickOf(v.Faces),
			rim = pickOf(v.Rims),
			extra = pickOf(v.Extras),
			pattern = pickOf(v.Patterns),
			paint = pickOf(Config.PaintColors),
		}
		local sameKit = last and last.type == carType and last.face == look.face and last.rim == look.rim and last.extra == look.extra and last.pattern == look.pattern
		if not last or (last.paint ~= look.paint and not sameKit) then
			break
		end
	end
	return look
end

-- the kit onto the car (CarLook draws it: its parts carry their piece, so a swapped-in shop part is the plain one)
local function wearLook(car: Model, look: Look, apart: boolean?)
	car:SetAttribute("Face", look.face)
	car:SetAttribute("Rim", look.rim)
	car:SetAttribute("Extra", look.extra)
	car:SetAttribute("Pattern", look.pattern)
	for _, slotName in CarParts.SlotOrder do
		local part = CarFactory.slotPart(car, slotName)
		local kind = CarParts.Slots[slotName].kind
		if part then
			if kind == "Wheel" then
				part:SetAttribute("Rim", look.rim)
			elseif slotName == "Bumper_F" then
				part:SetAttribute("Face", look.face)
			end
			if kind == "Hood" or kind == "Bumper" then
				part:SetAttribute("Pattern", look.pattern)
			end
		end
	end
	if apart then
		return -- (a quick-job car at the curb: not one of the customers in a row)
	end
	table.insert(recent, look)
	if #recent > 8 then
		table.remove(recent, 1)
	end
end

-- Calm / Restless / Upset from the time since the car parked (the first job has no clock)
function CustomerService.stage(car: Model): string
	local kind = Config.CustomerKinds[car:GetAttribute("CustomerKind") or "Regular"]
	local parked = car:GetAttribute("ParkedAt") :: number?
	if not kind or not parked or car:GetAttribute("NoPatience") then
		return "Calm"
	end
	local t = workspace:GetServerTimeNow() - parked
	local m = (car:GetAttribute("PatienceMult") :: number?) or 1 -- (car stars: a deeper job, a longer wait)
	return if t < kind.calm * m then "Calm" elseif t < kind.restless * m then "Restless" else "Upset"
end

local STAGE_COLOR = { Calm = Color3.fromRGB(90, 210, 110), Restless = Color3.fromRGB(250, 200, 60), Upset = Color3.fromRGB(235, 90, 70) }

-- the little patience bar under the name tag: how much calm is left, coloured by stage
local function showPatience(npc: Model, car: Model)
	local gui = npc:FindFirstChild("Bubble", true)
	local bar = gui and gui:FindFirstChild("Patience")
	local fill = bar and bar:FindFirstChild("Fill") :: Frame?
	if not bar or not fill then
		return
	end
	if car:GetAttribute("NoPatience") then
		bar.Visible = false
		return
	end
	local kind = Config.CustomerKinds[car:GetAttribute("CustomerKind") or "Regular"]
	local t = workspace:GetServerTimeNow() - ((car:GetAttribute("ParkedAt") :: number?) or workspace:GetServerTimeNow())
	fill.Size = UDim2.new(math.clamp(1 - t / (kind.restless * ((car:GetAttribute("PatienceMult") :: number?) or 1)), 0.04, 1), 0, 1, 0)
	fill.BackgroundColor3 = STAGE_COLOR[CustomerService.stage(car)]
end

local function line(kind: string, moment: string): string
	return kind .. "." .. moment .. "." .. rng:NextInteger(1, 2)
end

local function hum(npc: Model): Humanoid
	return npc:FindFirstChildOfClass("Humanoid") :: Humanoid
end

local function sitDown(npc: Model, seat: Seat)
	local id = ((npc:GetAttribute("WalkId") :: number?) or 0) + 1
	walkTo(npc, seat.Position + seat.CFrame.LookVector * 1.5)
	if npc:GetAttribute("WalkId") ~= id then
		return -- (called away on the way: the car's done)
	end
	hum(npc):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
	seat:Sit(hum(npc))
end

local function standUp(npc: Model)
	local mySeat: Seat? = nil
	for s, n in seatTaken do
		if n == npc then
			mySeat = s
		end
	end
	-- the seat's weld has to go, or the walk can't start
	local weld = mySeat and mySeat:FindFirstChild("SeatWeld")
	if weld then
		weld:Destroy()
	end
	local h = hum(npc)
	h.Sit = false
	h:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	h:ChangeState(Enum.HumanoidStateType.GettingUp)
	task.wait(0.4)
	if mySeat then
		-- one step out in front of the seat (a path can't start inside the seat)
		npc:PivotTo(CFrame.new(mySeat.Position + mySeat.CFrame.LookVector * 2.2 + Vector3.new(0, 2.5, 0)) * mySeat.CFrame.Rotation)
		task.wait(0.2)
	end
end

local function mySeatOf(npc: Model): Seat?
	for s, n in seatTaken do
		if n == npc then
			return s
		end
	end
	return nil
end

-- back to the car (downtime 10-22, curb_jobs §1-2 ①): once the car is fixed the customer gets up and waits on the
-- waiting-room side of the bay door, watching (out of the work view's way); at the hand-back they walk on to the
-- driver's door (from the seat if it came to that) — a little quicker, no desk stop (paid already: the card)
local back: { [Model]: string } = {} -- NPC -> "door" (going) / "atDoor" / "car" (going) / "there"

local function getUp(npc: Model)
	standUp(npc)
	for s, n in seatTaken do
		if n == npc then
			seatTaken[s] = nil
		end
	end
	hum(npc).WalkSpeed = Config.CustomerLeaveWalkSpeed
	npc.Destroying:Once(function()
		back[npc] = nil
	end)
end

local function toDoor(npc: Model, car: Model)
	if back[npc] ~= nil or not npc.Parent then
		return
	end
	back[npc] = "door"
	getUp(npc)
	local door = Places.find("WaitingRoom.BayDoor") :: BasePart?
	local bay = CarService.bayOf(car)
	local spot = bay and Places.marker(bay, "CarSpot")
	if door and spot then
		local away = Vector3.new(door.Position.X - spot.Position.X, 0, door.Position.Z - spot.Position.Z).Unit
		walkTo(npc, door.Position + away * Config.CustomerReadyWait)
		if back[npc] == "door" and npc.Parent then
			local at = npc:GetPivot().Position
			npc:PivotTo(CFrame.lookAt(at, at - away)) -- (watching the bay)
		end
	end
	if back[npc] == "door" then
		back[npc] = "atDoor"
	end
end

local function walkBack(npc: Model, car: Model)
	while back[npc] == "door" and npc.Parent do
		task.wait(0.1) -- (still getting to the door)
	end
	if back[npc] == "car" then
		while back[npc] == "car" and npc.Parent do
			task.wait(0.1) -- (already on the way)
		end
		return
	elseif back[npc] == "there" or not npc.Parent then
		return
	end
	local fromSeat = back[npc] == nil
	back[npc] = "car"
	if fromSeat then
		getUp(npc)
		walkTo(npc, point("WaitingRoom.BayDoor"))
	end
	local bay = CarService.bayOf(car)
	local exit = bay and Places.marker(bay, "DriverExitSpot")
	walkTo(npc, if exit then exit.Position else nil)
	back[npc] = "there"
end

-- waiting (alpha_scope §1-2): Calm = sit, a line now and then; Restless = get up, tap feet, ask at the bay door,
-- sit back down; Upset = one "could I get an update?" and sit, arms crossed (never comes into the bay, never leaves)
local function waitAround(car: Model, npc: Model)
	local kind = car:GetAttribute("CustomerKind") or "Regular"
	local last = CustomerService.stage(car)
	local nextTalk = os.clock() + rng:NextInteger(Config.CustomerTalkEvery[1], Config.CustomerTalkEvery[2])
	while customers[car] == npc and car.Parent and npc.Parent and not car:GetAttribute("Leaving") and back[npc] == nil do
		showPatience(npc, car)
		local stage = CustomerService.stage(car)
		car:SetAttribute("Stage", stage)
		if stage ~= last then
			last = stage
			if stage == "Restless" then
				standUp(npc)
				walkTo(npc, point("WaitingRoom.BayDoor"))
				speak(npc, line(kind, "Restless"), 5)
				for _ = 1, 3 do -- tapping a foot
					hum(npc).Jump = true
					task.wait(0.8)
				end
				local seat = mySeatOf(npc)
				if seat and not car:GetAttribute("Leaving") and back[npc] == nil then
					sitDown(npc, seat)
				end
			elseif stage == "Upset" then
				speak(npc, line(kind, "Upset"), 6)
			end
			nextTalk = os.clock() + rng:NextInteger(Config.CustomerTalkEvery[1], Config.CustomerTalkEvery[2])
		elseif os.clock() > nextTalk and stage ~= "Upset" then
			speak(npc, line(kind, stage), 4)
			nextTalk = os.clock() + rng:NextInteger(Config.CustomerTalkEvery[1], Config.CustomerTalkEvery[2])
		end
		task.wait(1)
	end
end

----------------------------------------------------------------------------------------------------------------
-- one customer, start to finish
----------------------------------------------------------------------------------------------------------------
-- a customer and their car: made on the road (arrive) or for the line (joinLine), then parked in a bay (settle)
type Visit = {
	car: Model,
	kind: string,
	tut: { [string]: any }?,
	first: boolean,
	special: boolean,
	afterTut: boolean,
	npc: Model?,
	state: string?, -- the line: "coming" (pulling into its stall) / "waiting"
	stall: number?, -- the line: which Queue stall
}

local lastIn = 0 -- (os.clock) a car last pulled into a bay
local nextRoad = 0 -- (os.clock) the next car off the road no sooner (two cars don't bunch up on the way in)

-- the job's car attributes from who the customer is, the tutorial stage and the fault plan
local function label(car: Model, kind: string, plan: { any }, tut: { [string]: any }?, first: boolean, special: { [string]: any }?)
	car:SetAttribute("CustomerKind", kind)
	car:SetAttribute("NoPatience", (first or special ~= nil or (tut ~= nil and tut.stage < 3)) or nil)
	if special then
		car:SetAttribute("SayHello", special.hello)
		car:SetAttribute("SayGood", special.good)
	end
	-- the customer says the first fault's symptom (fault_catalog lines)
	local v1 = plan[1] and Faults.ById[plan[1].variant]
	car:SetAttribute("Symptom", (special and special.say) or (tut and tut.say) or (if v1 then v1.say else "say.hello"))
	car:SetAttribute("Tip", if first then "tip.first" else nil)
end

-- an ordinary car's faults; the first ordinary car after someone's tutorial (main 10-21): not its three faults
-- again — the new job the Lv3 card just named (a bumper) when it's open, else anything but a dead battery / worn
-- pads / a flat; no trap
-- (car stars on, Config.Features.Stars: drawn by stars — car_difficulty v0.1 — and the star comes back too)
local function ordinaryPlan(level: number, kind: string, forced: { string }?, afterTut: boolean): ({ any }, number?)
	local opts = {
		slots = forced,
		noTrap = kind == "Hurry" or afterTut,
		avoid = if afterTut then AFTER_TUTORIAL_AVOID else nil,
		prefer = if afterTut then "Bumper" else nil,
	}
	if Config.feature("Stars") and not forced then
		return FaultService.planStars(level, opts, #Players:GetPlayers())
	end
	return FaultService.plan(level, opts), nil
end

-- (car stars) the customer waits longer for a deeper job: patience x labor units^StarPatiencePow, never less
local function patienceFor(plan: { any }): number
	local lu = 0
	for _, f in plan do
		lu += FaultService.luOf(f.slot)
	end
	return math.max(1, lu ^ Config.StarPatiencePow)
end

-- who comes next, what's wrong with their car, and the car itself at `start`. ahead = for the line (a car is in the
-- bay right now): the tutorial's stage after it, and never "the first car"
local function newVisit(start: CFrame, ahead: boolean): Visit
	-- someone new here: the first car is the sure one (a dead battery, one clue: fun_boost #1)
	local first = not ahead and PlayerData.anyoneNew()
	local forced: { string }? = if first then { "Battery" } else nil
	local testCar = CustomerService.forceNext ~= nil -- (a play test's own car: no tutorial customer instead)
	if CustomerService.forceNext then -- play tests: a chosen set of faults
		forced, first = CustomerService.forceNext, false
		CustomerService.forceNext = nil
	end
	local level = PlayerData.garageLevel()
	local special = CustomerService.special
	CustomerService.special = nil
	if special then
		CustomerService.forceKind = special.kind
		CustomerService.forceType = special.carType or "Sedan"
		testCar = true -- (no tutorial customer instead)
	end
	-- the tutorial's scripted customers (Rosa's dead battery, Tyler's worn pads, then a marked ordinary car)
	local tut = if not testCar and CustomerService.tutorialPick then CustomerService.tutorialPick(ahead) else nil
	local tutEnds = tut ~= nil and tut.after == true -- (the line: the car in the bay is someone's last tutorial car)
	if tutEnds then
		tut = nil
	end
	local kind = CustomerService.forceKind or (tut and tut.kind) or pickKind(level, first)
	CustomerService.forceKind = nil
	here[kind] = true
	local afterTut = (CustomerService.afterTutorial or tutEnds) and tut == nil and not testCar and not first
	if afterTut and not ahead then
		CustomerService.afterTutorial = false -- (the line's car uses it up as it goes in: fromLine)
	end
	local plan, stars
	if special then
		plan = special.plan
	elseif tut and tut.plan then
		plan = tut.plan
	else
		plan, stars = ordinaryPlan(level, kind, forced, afterTut)
	end
	local carType = CustomerService.forceType or pickType(level, kind, not first and tut == nil and not testCar)
	CustomerService.forceType = nil
	local look = pickLook(carType, kind)
	local car = CarService.spawn(start, plan, carType, (special and special.paint) or look.paint)
	if special then
		table.insert(recent, { type = carType, face = "Base", rim = "", extra = "None", pattern = "Solid", paint = special.paint or look.paint })
	else
		wearLook(car, look)
	end
	label(car, kind, plan, tut, first, special)
	if stars then
		car:SetAttribute("Stars", stars) -- (the job card's star line; JobService pays by labor units on these cars)
		car:SetAttribute("PatienceMult", patienceFor(plan))
	end
	if tut then
		-- (waiting in the lot it's "next": the tutorial's hints only follow the car once it's in the bay)
		car:SetAttribute(if ahead then "TutorialNext" else "Tutorial", tut.stage)
	end
	return { car = car, kind = kind, tut = tut, first = first, special = special ~= nil, afterTut = afterTut }
end

-- parked in the bay: the job starts, the driver gets out and says what's wrong, then off to the waiting room.
-- fromLine = came in from the lot (said hi out there: straight to the problem)
local function settle(v: Visit, bay: Instance, fromLine: boolean)
	local car, kind, tut = v.car, v.kind, v.tut
	CarService.park(car, bay)
	car:SetAttribute("ParkedAt", workspace:GetServerTimeNow())
	car:SetAttribute("Stage", "Calm")
	if tut then
		car:SetAttribute("TutorialNext", nil)
		car:SetAttribute("Tutorial", tut.stage)
	end
	lastIn = os.clock()
	JobService.begin(car, v.first)
	DiagnosisService.setup(car)
	if tut and CustomerService.onTutorialCar then
		CustomerService.onTutorialCar(car)
	end
	for _, p in Players:GetPlayers() do
		Remotes.Notify:FireClient(p, if kind == "VIP" then "n.vipIn" else "n.customerIn", nil, if kind == "VIP" then "good" else "info")
	end

	local npc = v.npc or makeNpc(kind)
	if not npc then
		return
	end
	v.npc = nil
	customers[car] = npc
	local exit = Places.marker(bay, "DriverExitSpot")
	local at = if exit then exit.Position else (bay:FindFirstChild("CarSpot") :: BasePart).Position + Vector3.new(6, 0, 0)
	npc:PivotTo(CFrame.new(at + Vector3.new(0, 3, 0)))
	npc.Parent = workspace
	local bar = npc:FindFirstChild("Patience", true)
	if bar then
		bar.Visible = true -- (hidden in the lot: the clock starts now; showPatience hides it again for NoPatience)
	end
	showPatience(npc, car)
	CoffeeService.offer(npc, car) -- (Features.Coffee: a "Give coffee" prompt on them until they have one)
	-- the car is fixed: up and to the bay door, ready to take it (whatever they're doing then)
	car:GetAttributeChangedSignal("Fixed"):Connect(function()
		if car:GetAttribute("Fixed") == true and customers[car] == npc then
			task.spawn(toDoor, npc, car)
		end
	end)
	if fromLine or (tut and tut.stage == 1) then
		-- straight to the problem as they get out (the very first car: tutorial_script v0.2 A)
		speak(npc, car:GetAttribute("Symptom") :: string, 8)
	else
		speak(npc, car:GetAttribute("SayHello") or line(kind, "hello"), 3)
		task.wait(3)
		speak(npc, car:GetAttribute("Symptom") :: string, 8)
	end
	task.wait(2)
	-- (each step: unless the car got fixed meanwhile — then they're off to the door instead)
	if back[npc] then
		return
	end
	if tut and tut.stage == 1 and not Config.feature("Coffee") then
		-- the very first customer waits by her car, a few steps out from the driver's door, watching (rival_upgrade
		-- B1 ⑤: the walk to the waiting room and back was dead time before the first pay)
		local spot = bay:FindFirstChild("CarSpot") :: BasePart?
		if exit and spot then
			local out = Vector3.new(exit.Position.X - spot.Position.X, 0, exit.Position.Z - spot.Position.Z)
			out = if out.Magnitude > 0.1 then out.Unit else Vector3.xAxis
			walkTo(npc, exit.Position + out * Config.FirstCustomerStandOff)
			if npc.Parent and back[npc] == nil then
				back[npc] = "atDoor" -- (walkBack takes the few steps from here)
				local p = npc:GetPivot().Position
				npc:PivotTo(CFrame.lookAt(p, p - out))
			end
		end
		return
	end
	walkTo(npc, point("WaitingRoom.BayDoor"))
	local desk = point("WaitingRoom.ReceptionDesk.ServicePoint")
	if back[npc] then
		return
	end
	walkTo(npc, desk)
	if desk and npc.Parent and not back[npc] then
		Remotes.Effect:FireAllClients("sfx", { sound = "deskBell", pos = desk }) -- (ding: someone's at the desk)
	end
	-- some grab a can from the machine first
	local vending = point("WaitingRoom.VendingMachine.UsePoint")
	if vending and rng:NextNumber() < Config.VendingChance and not back[npc] then
		walkTo(npc, vending)
		task.wait(2.5)
	end
	local seat = if back[npc] then nil else freeSeat(npc)
	if seat then
		sitDown(npc, seat)
		CoffeeService.ask(npc, car) -- (Features.Coffee: "Is there any coffee?" once, a little later)
	end
	waitAround(car, npc)
end

-- off the road and into this bay
local function arrive(bay: Instance)
	local spot = Places.marker(bay, "CarSpot")
	local approach = Places.marker(bay, "ApproachSpot")
	local roadIn = point("Traffic.RoadIn")
	if not spot or not approach then
		return
	end
	local start = if roadIn then CFrame.lookAt(roadIn, roadIn + Vector3.xAxis) else approach.CFrame
	nextRoad = os.clock() + Config.CustomerInterval
	local v = newVisit(start, false)
	local car = v.car
	bay:SetAttribute("CarId", car:GetAttribute("CarId")) -- reserved while it drives in
	local legs: { Leg } = {}
	if v.tut and v.tut.stage == 1 then
		-- the very first car: the short way in, seen from the start (tutorial_script v0.2 A)
		local back = approach.Position + (approach.Position - spot.Position).Unit * 18
		car:PivotTo(CFrame.lookAt(back, approach.Position))
		car:SetAttribute("BaseCFrame", car:GetPivot())
	elseif roadIn then
		-- along the avenue, a right turn through the entry cut, up the side to the drive lane
		legs = route({
			{ "Traffic.EntryTurn", Config.CarDriveSpeed },
			{ "Traffic.EntryCurb", Config.CarParkSpeed },
			{ "Traffic.LaneEast", Config.CarDriveSpeed * 0.5 },
		})
	end
	table.insert(legs, { to = approach.Position, speed = Config.CarDriveSpeed * 0.5 })
	table.insert(legs, { to = spot.Position, speed = Config.CarParkSpeed })
	drive(car, legs)
	settle(v, bay, false)
end

----------------------------------------------------------------------------------------------------------------
-- the line: the next customers wait in the WAIT HERE stalls in front of Bay 1 (World/Curbside: Queue.QueueSpotN,
-- nose to the bay), the driver by the front fender (WaveSpotN) waving now and then; a free bay -> straight in.
-- Config.LineMax of them (stalls / maxCars permitting). Closing time / held / the owner gone -> they go home.
----------------------------------------------------------------------------------------------------------------
local waiting: { Visit } = {} -- in the order they came
local joining = false -- (set by the loop as it starts joinLine, until the visit is in `waiting`)
local lastJoin = 0 -- (os.clock) the last one pulled into a stall

local function hoodPromptOn(car: Model, on: boolean)
	local hood = CarFactory.slotPart(car, "Hood")
	local p = hood and CarFactory.root(hood):FindFirstChild("HoodPrompt") :: ProximityPrompt?
	if p then
		p.Enabled = on
	end
end

local function wave(npc: Model)
	-- (one track, played again: a new one each time piled up 38 on one customer in the line)
	local t = move(npc, "wave")
	if t and not t.IsPlaying then
		t:Play()
	end
end

local function dropFromLine(v: Visit)
	local i = table.find(waiting, v)
	if i then
		table.remove(waiting, i)
	end
end

-- a stall nobody in the line has
local function freeStall(): number?
	local taken = {}
	for _, v in waiting do
		taken[v.stall or 0] = true
	end
	for i in Places.queueStalls() do
		if not taken[i] then
			return i
		end
	end
	return nil
end

-- the next customer pulls off the avenue into a stall and waits by the car (not a job yet: no hood prompt, no clock)
local function joinLine()
	local i = freeStall()
	local stall = i and Places.queueStalls()[i]
	local roadIn = point("Traffic.RoadIn")
	if not stall or not roadIn then
		joining = false
		return
	end
	nextRoad = os.clock() + Config.CustomerInterval
	lastJoin = os.clock()
	local ok, made = pcall(newVisit, CFrame.lookAt(roadIn, roadIn + Vector3.xAxis), true)
	joining = false
	if not ok then
		error(made)
	end
	local v = made :: Visit
	v.state, v.stall = "coming", i
	table.insert(waiting, v)
	local car = v.car
	hoodPromptOn(car, false)
	local spot = stall.spot
	local legs: { Leg } = {}
	if stall.entry then
		table.insert(legs, { to = stall.entry.Position, speed = Config.CarDriveSpeed })
	end
	if stall.apron then
		table.insert(legs, { to = stall.apron.Position, speed = Config.CarParkSpeed }) -- (the turn in: slow)
	end
	table.insert(legs, { to = spot.Position, speed = Config.CarDriveSpeed * 0.5 })
	drive(car, legs)
	if not table.find(waiting, v) or not car.Parent then
		return
	end
	local face = CFrame.lookAt(spot.Position, spot.Position + spot.CFrame.LookVector) -- (nose to the bay)
	car:SetAttribute("BaseCFrame", face)
	CarFactory.pose(car)
	-- the driver gets out and waits by the front fender, facing the bay door
	local npc = makeNpc(v.kind)
	if npc then
		v.npc = npc
		local at = if stall.wave then stall.wave.CFrame else face * CFrame.new(-5.5, 0, -5.5)
		npc:PivotTo(at + Vector3.new(0, 3, 0))
		local bar = npc:FindFirstChild("Patience", true)
		if bar then
			bar.Visible = false
		end
		npc:SetAttribute("LineWait", true) -- (wr-ui: a small sign over their head while they wait)
		npc.Parent = workspace
		Remotes.Effect:FireAllClients("sfx", { sound = "lineHonk", pos = spot.Position })
		speak(npc, "line.wait.1", 5)
		wave(npc)
	end
	v.state = "waiting"
	local n = 0
	while table.find(waiting, v) and v.npc and v.npc.Parent do
		task.wait(rng:NextNumber(Config.LineWaveEvery[1], Config.LineWaveEvery[2]))
		if not table.find(waiting, v) or not v.npc or not v.npc.Parent then
			break
		end
		wave(v.npc)
		n += 1
		if n % 3 == 0 then
			speak(v.npc, "line.wait.2", 4)
		end
	end
end

-- the waiting car's job, checked again as it goes in: the tutorial may not have moved on (the car before handed
-- back without that player's work in it, a friend on another stage) -> this car gets the job wanted now
local function refit(v: Visit)
	if v.special or not CustomerService.tutorialPick then
		return
	end
	local want = CustomerService.tutorialPick(false, v.car)
	if (want and want.stage) == (v.tut and v.tut.stage) then
		return
	end
	local car = v.car
	local level = PlayerData.garageLevel()
	here[v.kind] = nil
	local kind = (want and want.kind) or pickKind(level, false)
	here[kind] = true
	local plan, stars = nil, nil
	if want and want.plan then
		plan = want.plan
	else
		plan, stars = ordinaryPlan(level, kind, nil, false)
	end
	car:SetAttribute("Stars", stars)
	car:SetAttribute("PatienceMult", if stars then patienceFor(plan) else nil)
	for name in car:GetAttributes() do
		if name:sub(1, 6) == "Issue_" then
			FaultService.clearIssue(car, name:sub(7)) -- the old plan's leftovers
		end
	end
	for _, slotName in CarParts.SlotOrder do
		local part = CarFactory.slotPart(car, slotName)
		if part then
			part:SetAttribute("Look", nil)
			part:SetAttribute("Balanced", nil)
			local nail = part:FindFirstChild("Nail")
			if nail then
				nail:Destroy()
			end
		end
	end
	FaultService.roll(car, plan)
	car:SetAttribute("Clues", nil)
	for _, slotName in CarParts.SlotOrder do
		CarFactory.reseat(car, slotName)
	end
	label(car, kind, plan, want, false, nil)
	car:SetAttribute("TutorialNext", nil)
	v.kind, v.tut, v.afterTut = kind, want, false
	local tag = v.npc and v.npc:FindFirstChild("Name", true)
	if tag then
		Locale.tag(tag, "npc." .. kind)
	end
end

-- a bay is free: the first one waiting gets in and drives straight in
local function fromLine(v: Visit, bay: Instance)
	dropFromLine(v)
	local car = v.car
	local spot, approach = Places.marker(bay, "CarSpot"), Places.marker(bay, "ApproachSpot")
	if not car.Parent or not spot or not approach then
		here[v.kind] = nil
		return
	end
	bay:SetAttribute("CarId", car:GetAttribute("CarId")) -- reserved while it drives in
	refit(v)
	if v.afterTut then
		CustomerService.afterTutorial = false -- (used up: the one after it is any car again)
	end
	if v.npc then
		v.npc:SetAttribute("LineWait", nil)
		v.npc.Parent = nil -- (gets in)
	end
	-- the old car's whole body clear of the way in first (it's already driving off: a moment at most)
	local t0 = os.clock()
	local function inTheWay(): boolean
		for _, c in (workspace:FindFirstChild("Cars") :: Folder):GetChildren() do
			if c ~= car and c:IsA("Model") and c:GetAttribute("Leaving") and (c:GetPivot().Position - approach.Position).Magnitude < 17 then
				return true
			end
		end
		return false
	end
	while inTheWay() and os.clock() - t0 < 3 do
		task.wait(0.1)
	end
	drive(car, { { to = approach.Position, speed = Config.CarDriveSpeed * 0.5 }, { to = spot.Position, speed = Config.CarParkSpeed } })
	hoodPromptOn(car, true)
	settle(v, bay, true)
end

-- closing time / held for a special customer / nobody here: the one waiting goes home (out by the drive lane)
local function leaveLine(v: Visit)
	if not table.find(waiting, v) then
		return
	end
	dropFromLine(v)
	here[v.kind] = nil
	local car = v.car
	if v.npc and v.npc.Parent then
		speak(v.npc, "line.later", 3)
		task.wait(2)
	end
	if v.npc then
		v.npc:Destroy()
	end
	if not car.Parent then
		return
	end
	local legs: { Leg } = {}
	local lane = point("Traffic.LaneWest")
	local base = car:GetAttribute("BaseCFrame") :: CFrame?
	if lane and base then
		table.insert(legs, { to = Vector3.new(base.X, lane.Y, lane.Z), speed = Config.CarParkSpeed })
	end
	for _, leg in exitLegs() do
		table.insert(legs, leg)
	end
	drive(car, legs)
	car:Destroy()
end

-- a running engine shakes the car a little (server pose, everyone sees it)
function CustomerService.shake(car: Model, seconds: number)
	local base = car:GetAttribute("BaseCFrame") :: CFrame
	local t0 = os.clock()
	while os.clock() - t0 < seconds and car.Parent do
		local k = 1 - (os.clock() - t0) / seconds
		car:SetAttribute("BaseCFrame", base * CFrame.Angles(math.rad((rng:NextNumber() - 0.5) * 1.2 * k), 0, math.rad((rng:NextNumber() - 0.5) * 1.2 * k)))
		CarFactory.pose(car)
		task.wait(0.03)
	end
	car:SetAttribute("BaseCFrame", base)
	CarFactory.pose(car)
end

local function leave(car: Model, result: JobService.Result)
	local bay = CarService.bayOf(car)
	local npc = customers[car]
	local kind = car:GetAttribute("CustomerKind") or "Regular"
	car:SetAttribute("Leaving", true)
	customers[car] = nil
	car:SetAttribute("HoodOpen", false)
	CarFactory.reseat(car, "Hood")
	-- old parts still sitting on the car go on the floor beside it (for the scrap bin)
	local detached = car:FindFirstChild("Detached")
	if detached then
		for _, part in detached:GetChildren() do
			part.Parent = CarFactory.looseFolder()
			CarFactory.moveTo(part, car:GetPivot() * CFrame.new(-6, 1, 0))
			CarFactory.setSolid(part, true)
		end
	end
	-- the pay card right away (the money was paid in JobService.release): it shows while the car goes and the next
	-- one comes in (curb_jobs §1-2 ②)
	for _, p in result.players do
		if p.Parent then
			Metrics.mark(p, "firstPay")
			if CustomerService.onJobDone then
				CustomerService.onJobDone(p, result.paid[p] or result.money or 0, result.spotOn == true, result.players, kind, result.happy == true)
			end
			Remotes.Effect:FireClient(p, "jobDone", { money = result.paid[p] or result.money, spotOn = result.spotOn, first = result.first, kinds = result.kinds, happy = result.happy, lines = result.lines[p], full = result.full[p] == true, rep = result.rep, team = #result.players })
		end
	end
	if CustomerService.onHandBack then
		task.spawn(CustomerService.onHandBack, car)
	end
	if npc then
		walkBack(npc, car) -- (from the door, or from the seat)
		local exit = bay and Places.marker(bay, "DriverExitSpot")
		-- the big moment (fun_boost #3): turn the key, it fires up, the customer cheers
		if exit then
			npc:PivotTo(CFrame.lookAt(npc:GetPivot().Position, Vector3.new(car:GetPivot().X, npc:GetPivot().Y, car:GetPivot().Z)))
		end
		task.wait(0.4)
		if result.happy then
			Remotes.Effect:FireAllClients("carStart", { car = car, big = true })
			if car:GetAttribute("SayGood") and CustomerService.onSpecialStart then
				CustomerService.onSpecialStart(car)
			end
			CustomerService.shake(car, 0.9)
		end
		local special = car:GetAttribute("SayGood") :: string?
		speak(npc, if special and result.happy then special else line(kind, if result.happy then "good" else "bad"), 4)
		if result.happy then
			hum(npc).Jump = true -- (one hop: curb_jobs §1-2 ③)
			task.wait(0.7)
		end
		task.wait(0.5)
		npc:Destroy() -- gets in
	end
	here[kind] = nil
	FaultService.clearPuddles(car)
	car:SetAttribute("Parked", false)
	CarFactory.setDetail(car, "Lite") -- off the bay: the client picks by distance again
	local approach = bay and Places.marker(bay, "ApproachSpot")
	local legs: { Leg } = {}
	if approach then
		table.insert(legs, { to = approach.Position, speed = Config.CarParkSpeed, back = true })
	end
	for _, leg in exitLegs() do
		table.insert(legs, leg)
	end
	if car:GetAttribute("SayGood") and CustomerService.specialDrive then
		if bay then
			task.delay(3, function()
				bay:SetAttribute("CarId", nil) -- the bay frees once the car is out of it
			end)
		end
		if CustomerService.specialDrive(car, legs) then
			return
		end
		drive(car, legs)
		car:Destroy()
		return
	end
	-- backed out to the lane: the bay is free right then (the next one may be waiting in the lot)
	if approach then
		drive(car, { table.remove(legs, 1) :: Leg })
	end
	if bay then
		bay:SetAttribute("CarId", nil)
	end
	drive(car, legs)
	car:Destroy()
end

-- how many customer cars at once (alpha_scope §1-4): 1-2 players = up to 2 (as many bays as there are),
-- 3-4 players = 2 / 3 / 4 by level
function CustomerService.maxCars(): number
	local players = #Players:GetPlayers()
	local level = PlayerData.garageLevel()
	local cap = if players <= 2 then 2 elseif level <= 2 then 2 elseif level <= 5 then 3 else 4
	return math.min(cap, #Places.bays())
end

local function carsHere(): number
	local n = 0
	for _, bay in Places.bays() do
		if bay:GetAttribute("CarId") then
			n += 1
		end
	end
	return n
end

-- a car on its way into (or out of) a bay right now
local function moving(): boolean
	for _, bay in Places.bays() do
		local car = CarService.carIn(bay)
		if car and not car:GetAttribute("Parked") then
			return true
		end
	end
	return false
end

-- a customer bay nobody has (no car in it or on its way, the lift down)
local function freeBay(): Instance?
	for _, bay in Places.bays() do
		if not bay:GetAttribute("CarId") and (bay:GetAttribute("LiftLevel") or 1) == 1 then
			return bay
		end
	end
	return nil
end

function CustomerService.start()
	JobService.stageOf = CustomerService.stage
	-- the moment it works (before the pay): the engine catches and the car shakes, the customer is thrilled
	JobService.onProof = function(car, kind)
		local npc = customers[car]
		if npc and npc.Parent then
			task.spawn(walkBack, npc, car) -- (on their way to the car while the hand-back finishes)
		end
		task.wait(1.1) -- (with the client's before -> after: the "after" lands here)
		if npc and npc.Parent then
			speak(npc, if kind == "BrakePads" then "proof.brake" else "proof.engine", 3)
			hum(npc).Jump = true
		end
		if kind ~= "BrakePads" and car.Parent then
			CustomerService.shake(car, 0.8)
		end
	end
	JobService.onReleased = function(car, result)
		if CustomerService.afterRelease then
			task.spawn(CustomerService.afterRelease, car, result)
		end
		task.spawn(leave, car, result)
	end
	task.spawn(function()
		local started = os.clock()
		-- wait for everyone's save to load (the first car depends on "first job done"), at most 15 s
		local t0 = os.clock()
		while os.clock() - t0 < 15 do
			local all = #Players:GetPlayers() > 0
			for _, p in Players:GetPlayers() do
				all = all and p:GetAttribute("Loaded") == true
			end
			if all then
				break
			end
			task.wait(0.3)
		end
		-- someone brand new: their first car starts driving in right away (tutorial_script v0.2 A), else a moment
		local new = false
		for _, p in Players:GetPlayers() do
			new = new or (PlayerData.tut(p) == 1 and not p:GetAttribute("TutSkip"))
		end
		task.wait(math.max(0, (if new then 0 else Config.CustomerFirstDelay) - (os.clock() - started)))
		local function run(f: (...any) -> (), ...: any)
			local ok, err = pcall(f, ...)
			if not ok then
				warn("[CustomerService] " .. tostring(err))
			end
		end
		-- a few times a second (bays come and go with upgrades, so the list is read fresh): a free bay takes the first
		-- one in line, else the next car off the road (CustomerInterval apart), up to maxCars; every bay busy -> the
		-- next customer pulls into a WAIT HERE stall (LineDelay after the last one went in / joined), as many as there
		-- are stalls, up to maxCars. Closed / held for a special customer / nobody here -> the line goes home.
		while true do
			local open = #Players:GetPlayers() > 0 and not GateService.closed and not CustomerService.hold
			local bay = if open and carsHere() < CustomerService.maxCars() then freeBay() else nil
			local first = waiting[1]
			if not open then
				for _, v in table.clone(waiting) do
					if v.state == "waiting" then
						task.spawn(run, leaveLine, v)
					end
				end
			elseif bay then
				if first then
					if first.state == "waiting" then
						task.spawn(run, fromLine, first, bay)
					end -- (still pulling into its stall: in as soon as it's there)
				elseif not joining and os.clock() >= nextRoad then
					nextRoad = os.clock() + Config.CustomerInterval
					task.spawn(run, arrive, bay)
				end
			elseif not joining and #waiting < math.min(Config.LineMax, #Places.queueStalls(), CustomerService.maxCars()) and carsHere() > 0
				and not moving() and os.clock() >= nextRoad and os.clock() - math.max(lastIn, lastJoin) >= Config.LineDelay
			then
				joining = true
				task.spawn(run, joinLine)
			end
			task.wait(0.25)
		end
	end)
end

-- another service's car coming off the road (CurbService): it waits its turn, like ours (CustomerInterval apart)
function CustomerService.takeRoad()
	while os.clock() < nextRoad do
		task.wait(0.25)
	end
	nextRoad = os.clock() + Config.CustomerInterval
end

-- shared with the showroom buyers (ShowroomService)
CustomerService.makeNpc = makeNpc
CustomerService.arrive = arrive
CustomerService.drive = drive
CustomerService.point = point
CustomerService.carsHere = carsHere
CustomerService.exitLegs = exitLegs
CustomerService.pickLook = pickLook
CustomerService.wearLook = wearLook
CustomerService.speak = speak
CustomerService.walkTo = walkTo

return CustomerService
