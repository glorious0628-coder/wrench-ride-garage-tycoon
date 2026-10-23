-- Quick jobs at the curb (docs/design/curb_jobs.md v0.1 §2; main decision notes/gpt/main/downtime_main_decision.md,
-- user OK 10-22): now and then a car pulls into the QUICK SERVICE stall in front of the shop (World/Curbside:
-- Curb.CurbSpot) for a one-minute job — Washer fluid (Lv3) / Wiper blades (Lv4). Two holds, one prompt at a time,
-- no work view, no faults / scan / patience clock; small money (Config.CurbJobs), never a penalty for skipping it or
-- walking off.
--   when: counted at each ordinary bay hand-back (CustomerService.onHandBack): the first one FirstAfter cars in, then
--         every EveryJobs bay jobs once MinGap s have passed since the last one left; one at a time; never while
--         someone is in the tutorial, held (Ella) or closed
--   who:  one player (alone = them; friends = the one who had one longest ago and isn't in a work view); nobody starts
--         in OpenToAll s -> anyone (the first to press); WaitStart s without a start -> the customer leaves; started
--         and nobody within PauseRange for GiveUp s -> leaves (no money, no penalty)
--   for the screens (wr-ui): car attributes CurbJob = "Washer" / "Wipers", CurbStep (0 = not started, 1, 2 = done),
--   CurbOwner (userId, nil = anyone), CurbBy (who pressed first), CurbPay; the prompt's attribute OnlyFor (userId)
--   while it's someone's (wr-ui hides it for the others)
--   Washer: "Top up washer" (hood up) -> "Pour" (a jug over the cap) -> hood down, test spray
--   Wipers: "Change wipers" (up to the service position, then off the glass) -> "Swap blades" (driver's, then the
--           passenger's: click, click) -> back down, test spray

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local CustomerService = require(script.Parent.CustomerService)
local GateService = require(script.Parent.GateService)
local PlayerData = require(script.Parent.PlayerData)
local Places = require(script.Parent.Places)
local Guard = require(script.Parent.Guard)

local CurbService = {}

CurbService.onEarned = nil :: ((player: Player, money: number) -> ())? -- ShiftService.quick

-- car-local points (sedan: fault_parts_attachments.json / decor_attachments.json)
local WIPER_AT = Vector3.new(0, 4.4, -3.6) -- the windshield's bottom middle
local HOOD_AT = Vector3.new(0, 3.5, -8.2) -- the hood's front edge
local CAP_AT = Vector3.new(2.62, 3.88, -6.5) -- 0.6 over the washer cap (Fluid_Washer)
local JETS = { -- the hood nozzles: tip, direction (when the hood is shut)
	{ Vector3.new(-1.1026, 4.1998, -4.0821), Vector3.new(0.0809, 0.5, 0.8622) },
	{ Vector3.new(1.1025, 4.1998, -4.0821), Vector3.new(-0.0809, 0.5, 0.8622) },
}
local WATER = Color3.fromHex("4FA3E0")

type Job = {
	car: Model,
	kind: string,
	npc: Model?,
	owner: Player?, -- whose it is (nil = anyone)
	step: number, -- 0 not started, 1, 2 done
	arrived: number,
	lastNear: number,
	prompt: ProximityPrompt?,
	jug: Model?,
	busy: boolean, -- (an animation is playing: the prompt is off)
	over: boolean,
}

local rng = Random.new()
local current: Job? = nil
local bayJobs = 0 -- ordinary bay jobs handed back since the last quick job
local everyJobs = 0 -- this many before the next (EveryJobs)
local lastLeft = -math.huge
local firstDone = false
local lastKind: string? = nil
local lastGot: { [Player]: number } = {}
local seenKind: { [string]: boolean } = {}

local function inTutorial(): boolean
	for _, p in Players:GetPlayers() do
		local t = PlayerData.tut(p)
		if t and t < 4 and not p:GetAttribute("TutSkip") then
			return true
		end
	end
	return false
end

local function open(): boolean
	return #Players:GetPlayers() > 0 and not GateService.closed and not CustomerService.hold
end

-- the kinds this garage's level has, the one not done last time first
local function pickKind(): string?
	local level = PlayerData.garageLevel()
	local kinds = {}
	for _, k in { "Washer", "Wipers" } do
		if level >= Config.CurbJobs[k].level then
			table.insert(kinds, k)
		end
	end
	if #kinds == 0 then
		return nil
	end
	if not firstDone then
		return kinds[1] -- (the first meeting: the washer)
	end
	if #kinds > 1 and lastKind then
		for _, k in kinds do
			if k ~= lastKind then
				return k
			end
		end
	end
	return kinds[rng:NextInteger(1, #kinds)]
end

-- one player: the one who had a quick job longest ago (not inside a work view, unless they're alone)
local function pickOwner(): Player?
	local all = Players:GetPlayers()
	if #all == 1 then
		return all[1]
	end
	local best, bestT = nil, math.huge
	for _, p in all do
		local t = lastGot[p] or -math.huge
		if not p:GetAttribute("WorkCar") and t < bestT then
			best, bestT = p, t
		end
	end
	return best or all[rng:NextInteger(1, #all)]
end

local function sfx(name: string, at: Vector3)
	Remotes.Effect:FireAllClients("sfx", { sound = name, pos = at })
end

local function carPoint(car: Model, p: Vector3): Vector3
	return (((car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()) * CFrame.new(p)).Position
end

-- the test spray: two blue fans from the hood nozzles onto the glass
local function spray(car: Model, seconds: number)
	local chassis = car.PrimaryPart
	if not chassis then
		return
	end
	local base = (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
	for _, jet in JETS do
		local dir = jet[2].Unit
		local side = (Vector3.xAxis - dir * dir.X).Unit
		local a = Instance.new("Attachment")
		a.Name = "WasherJet"
		a.CFrame = chassis.CFrame:ToObjectSpace(base * CFrame.fromMatrix(jet[1], side, dir))
		local pe = Instance.new("ParticleEmitter")
		pe.EmissionDirection = Enum.NormalId.Top
		pe.Color = ColorSequence.new(WATER)
		pe.Rate = 160
		pe.Lifetime = NumberRange.new(0.25, 0.4)
		pe.Speed = NumberRange.new(9, 12)
		pe.SpreadAngle = Vector2.new(12.5, 4) -- (a ~25° fan across)
		pe.Size = NumberSequence.new(0.09, 0.05)
		pe.Transparency = NumberSequence.new(0.25, 0.8)
		pe.Acceleration = Vector3.new(0, -12, 0)
		pe.LightEmission = 0.2
		pe.Parent = a
		a.Parent = chassis
		task.delay(seconds, function()
			pe.Enabled = false
			task.delay(0.5, function()
				a:Destroy()
			end)
		end)
	end
end

local function setHood(car: Model, up: boolean)
	car:SetAttribute("HoodOpen", up)
	CarFactory.reseat(car, "Hood")
	Remotes.Effect:FireAllClients("hood", { car = car, open = up })
end

local function hoodPrompt(car: Model): ProximityPrompt?
	local hood = CarFactory.slotPart(car, "Hood")
	return hood and CarFactory.root(hood):FindFirstChild("HoodPrompt") :: ProximityPrompt?
end

-- the jug over the washer cap while pouring (World/Curbside's jug, else a plain stand-in): tipped over, its cap just
-- above the car's washer cap
local function jugAt(car: Model): Model
	local stall = Places.curbStall()
	local t = stall and stall.jug
	local m: Model
	if t and t:IsA("Model") then
		m = t:Clone()
	else
		m = Instance.new("Model")
		m.Name = "Jug"
		local body = Instance.new("Part")
		body.Name = "Body"
		body.Size = Vector3.new(0.65, 1.1, 0.45) -- (a gallon jug, washer_fluid ×1.15)
		body.Color = WATER
		body.Material = Enum.Material.SmoothPlastic
		body.Parent = m
		local cap = Instance.new("Part")
		cap.Name = "Cap"
		cap.Shape = Enum.PartType.Cylinder
		cap.Size = Vector3.new(0.14, 0.22, 0.22)
		cap.Color = Color3.new(1, 1, 1)
		cap.Material = Enum.Material.SmoothPlastic
		cap.CFrame = body.CFrame * CFrame.new(0, 0.62, 0) * CFrame.Angles(0, 0, math.rad(90))
		cap.Parent = m
		m.PrimaryPart = body
	end
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
		end
	end
	local body = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart") :: BasePart
	local cap = m:FindFirstChild("Cap") :: BasePart?
	local capAt = if cap then body.CFrame:PointToObjectSpace(cap.Position) else Vector3.new(0, 0.62, 0)
	local base = (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
	local turn = base.Rotation * CFrame.Angles(math.rad(-120), 0, 0)
	local target = base * Vector3.new(2.62, 3.45, -6.5) -- (0.17 over the washer cap)
	local frame = CFrame.new(target - turn:VectorToWorldSpace(capAt)) * turn
	m:PivotTo(frame * body.CFrame:ToObjectSpace(m:GetPivot()))
	m.Parent = car
	return m
end

local function setOwner(j: Job, p: Player?)
	j.owner = p
	j.car:SetAttribute("CurbOwner", if p then p.UserId else nil)
	if j.prompt then
		j.prompt:SetAttribute("OnlyFor", if p then p.UserId else nil)
	end
end

local STEPS = {
	Washer = { { key = "curb.p.washer", at = HOOD_AT, hold = "start" }, { key = "curb.p.pour", at = CAP_AT, hold = "pour" } },
	Wipers = { { key = "curb.p.wipers", at = WIPER_AT, hold = "start" }, { key = "curb.p.blades", at = WIPER_AT, hold = "blades" } },
}

-- the one prompt, moved to this step's spot
local function showStep(j: Job)
	local s = STEPS[j.kind][j.step + 1]
	local p = j.prompt
	if not s or not p then
		return
	end
	local chassis = j.car.PrimaryPart :: BasePart
	local a = p.Parent :: Attachment
	a.Position = chassis.CFrame:PointToObjectSpace(carPoint(j.car, s.at))
	p.HoldDuration = Config.CurbJobs.Hold[s.hold]
	Locale.tag(p, s.key)
	p.Enabled = true
end

-- they go: the hood down / wipers back, the customer gets in, the car leaves by the drive lane
local function drive(j: Job, happy: boolean)
	if j.over then
		return
	end
	j.over = true
	if current == j then
		current = nil
	end
	lastLeft = os.clock()
	bayJobs = 0
	everyJobs = rng:NextInteger(Config.CurbJobs.EveryJobs[1], Config.CurbJobs.EveryJobs[2])
	local car = j.car
	if j.prompt then
		j.prompt.Enabled = false
	end
	if j.jug then
		j.jug:Destroy()
	end
	if car:GetAttribute("HoodOpen") then
		setHood(car, false)
	end
	car:SetAttribute("Wipers", nil)
	local npc = j.npc
	if npc and npc.Parent then
		CustomerService.speak(npc, if happy then "curb.good." .. j.kind else "curb.bye", 4)
		local hum = npc:FindFirstChildOfClass("Humanoid")
		if happy and hum then
			hum.Jump = true
		end
		task.wait(1.6)
		npc:Destroy()
	end
	if not car.Parent then
		return
	end
	if happy then
		sfx("cheer", car:GetPivot().Position) -- (a thank-you toot)
	end
	local legs = {}
	local stall = Places.curbStall()
	if stall and stall.exit then
		table.insert(legs, { to = stall.exit.Position, speed = Config.CarParkSpeed })
	end
	for _, leg in CustomerService.exitLegs() do
		table.insert(legs, leg)
	end
	CustomerService.drive(car, legs)
	car:Destroy()
end

local function pay(j: Job, p: Player)
	local cfg = Config.CurbJobs[j.kind]
	PlayerData.addMoney(p, cfg.pay)
	PlayerData.addRep(p, cfg.rep)
	lastGot[p] = os.clock()
	if CurbService.onEarned then
		CurbService.onEarned(p, cfg.pay)
	end
	Remotes.Notify:FireClient(p, "curb.paid", { money = cfg.pay, job = "@curb.name." .. j.kind }, "good")
	print(string.format("[Metrics] %s curb %s %.0fs", p.Name, j.kind, os.clock() - j.arrived))
end

-- step 1 / 2 pressed (the pour's jug comes with the hold, below)
local function pressed(j: Job, player: Player)
	if j.busy or j.over then
		return
	end
	local only = j.prompt and j.prompt:GetAttribute("OnlyFor")
	if only and only ~= player.UserId then
		local who = j.owner
		Remotes.Notify:FireClient(player, "curb.tag", { name = if who then who.DisplayName else "?" }, "info")
		return
	end
	if not j.owner then
		setOwner(j, player) -- (anyone's: it's the first to start it)
	end
	if j.step == 0 then
		j.car:SetAttribute("CurbBy", player.UserId) -- (who's doing it: wr-ui's camera / card)
	end
	j.busy = true
	if j.prompt then
		j.prompt.Enabled = false
	end
	local car = j.car
	j.step += 1
	car:SetAttribute("CurbStep", j.step)
	if j.kind == "Wipers" and j.step == 1 then
		-- up to the service position, then off the glass (the Camry's lever, in one hold)
		sfx("wiperMotor", carPoint(car, WIPER_AT))
		car:SetAttribute("Wipers", "service")
		task.wait(0.5)
		car:SetAttribute("Wipers", "lifted")
	elseif j.kind == "Wipers" then
		-- the driver's blade, then the passenger's: click, click
		sfx("bladeSnap", carPoint(car, Vector3.new(-0.9, 4.4, -3.6)))
		car:SetAttribute("WiperWorn", "Short")
		task.wait(0.3)
		sfx("bladeSnap", carPoint(car, Vector3.new(1.4, 4.3, -3.7)))
		car:SetAttribute("WiperWorn", nil)
		task.wait(0.4)
		car:SetAttribute("Wipers", nil)
		task.wait(0.4)
		sfx("washerSpray", carPoint(car, WIPER_AT))
		spray(car, 1.4)
		task.wait(1.6)
	elseif j.step == 1 then
		setHood(car, true) -- (the work view stays out of it: no hood prompt on this car)
		task.wait(0.4)
	else
		task.wait(0.3)
		if j.jug then
			j.jug:Destroy()
			j.jug = nil
		end
		setHood(car, false)
		task.wait(0.5)
		sfx("washerSpray", carPoint(car, WIPER_AT))
		spray(car, 1.4)
		task.wait(1.6)
	end
	j.busy = false
	if j.over then
		return
	end
	if j.step >= 2 then
		pay(j, player)
		drive(j, true)
	else
		showStep(j)
	end
end

-- a car pulls into the stall
local function come(kind: string)
	local stall = Places.curbStall()
	local roadIn = CustomerService.point("Traffic.RoadIn")
	if not stall or not roadIn or current then
		return
	end
	local look = CustomerService.pickLook("Sedan", "Regular") -- (any kit and paint; sedans only: wipers / washer 3D)
	local car = CarService.spawn(CFrame.lookAt(roadIn, roadIn + Vector3.xAxis), {}, "Sedan", look.paint)
	CustomerService.wearLook(car, look, true)
	local j: Job = { car = car, kind = kind, step = 0, arrived = os.clock(), lastNear = os.clock(), busy = false, over = false }
	current = j
	firstDone = true
	lastKind = kind
	car:SetAttribute("CurbJob", kind)
	car:SetAttribute("CurbStep", 0)
	car:SetAttribute("CurbPay", Config.CurbJobs[kind].pay)
	car:SetAttribute("NoPatience", true)
	car:SetAttribute("CustomerKind", "Regular")
	if kind == "Wipers" then
		car:SetAttribute("WiperWorn", true)
	end
	local hp = hoodPrompt(car)
	if hp then
		hp.Enabled = false -- (the job opens the hood itself: no work view)
	end
	CustomerService.takeRoad() -- (cars don't bunch up on the way in)
	local legs = {}
	if stall.entry then
		table.insert(legs, { to = stall.entry.Position, speed = Config.CarDriveSpeed })
	end
	if stall.apron then
		table.insert(legs, { to = stall.apron.Position, speed = Config.CarParkSpeed }) -- (the turn in: slow)
	end
	table.insert(legs, { to = stall.spot.Position, speed = Config.CarDriveSpeed * 0.5 })
	CustomerService.drive(car, legs)
	if j.over or not car.Parent then
		return
	end
	local face = CFrame.lookAt(stall.spot.Position, stall.spot.Position + stall.spot.CFrame.LookVector)
	car:SetAttribute("BaseCFrame", face)
	CarFactory.pose(car)
	j.arrived = os.clock()
	j.lastNear = os.clock()
	-- the driver gets out and waits by the car
	local npc = CustomerService.makeNpc("Regular")
	if npc then
		j.npc = npc
		local at = if stall.customer then stall.customer.CFrame else face * CFrame.new(5.6, 0, 5)
		npc:PivotTo(at + Vector3.new(0, 3, 0))
		local bar = npc:FindFirstChild("Patience", true)
		if bar then
			bar.Visible = false
		end
		npc.Parent = workspace
		CustomerService.speak(npc, "curb.say." .. kind, 7)
	end
	-- the trouble, shown: the pump whirrs dry / one spray, the old blades streak
	if kind == "Washer" then
		sfx("washerWhirr", carPoint(car, WIPER_AT))
	else
		sfx("washerSpray", carPoint(car, WIPER_AT))
		spray(car, 1.2)
	end
	-- the one prompt
	local chassis = car.PrimaryPart :: BasePart
	local a = Instance.new("Attachment")
	a.Name = "CurbPoint"
	a.Parent = chassis
	local p = Instance.new("ProximityPrompt")
	p.Name = "CurbPrompt"
	p.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	p.KeyboardKeyCode = Enum.KeyCode.E
	p.MaxActivationDistance = 10
	p.RequiresLineOfSight = false
	p.Enabled = false
	p.Parent = a
	j.prompt = p
	setOwner(j, pickOwner())
	showStep(j)
	p.Triggered:Connect(Guard.prompt(p, "Curb", 0.5, function(player)
		pressed(j, player)
	end))
	-- the pour: the jug tips over the cap while the hold lasts
	p.PromptButtonHoldBegan:Connect(function(player)
		local only = p:GetAttribute("OnlyFor")
		if j.kind == "Washer" and j.step == 1 and not j.jug and not (only and only ~= player.UserId) then
			j.jug = jugAt(car)
			sfx("pourGlug", carPoint(car, CAP_AT))
		end
	end)
	p.PromptButtonHoldEnded:Connect(function()
		task.wait(0.1)
		if j.jug and not j.busy then
			j.jug:Destroy()
			j.jug = nil
		end
	end)
	local owner = j.owner
	if owner and not seenKind[kind] then
		Remotes.Notify:FireClient(owner, "curb.new." .. kind, nil, "info")
	end
	seenKind[kind] = true
	-- waiting on it: anyone after OpenToAll, gone after WaitStart; started and left alone GiveUp s -> gone
	local cfg = Config.CurbJobs
	while not j.over and car.Parent do
		task.wait(0.5)
		local now = os.clock()
		if j.owner and not j.owner.Parent then
			setOwner(j, nil)
		end
		for _, pl in Players:GetPlayers() do
			local root = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if root and (root.Position - car:GetPivot().Position).Magnitude <= cfg.PauseRange then
				j.lastNear = now
			end
		end
		if not open() then
			drive(j, false)
		elseif j.step == 0 then
			if j.owner and now - j.arrived >= cfg.OpenToAll then
				setOwner(j, nil)
			end
			if now - j.arrived >= cfg.WaitStart then
				drive(j, false)
			end
		elseif not j.busy and now - j.lastNear >= cfg.GiveUp then
			drive(j, false)
		end
	end
end

-- a bay job was handed back: maybe a quick job comes now
function CurbService.handBack(car: Model)
	if car:GetAttribute("Tutorial") then
		return
	end
	bayJobs += 1
	if current or inTutorial() or not open() then
		return
	end
	local kind = pickKind()
	if not kind then
		return
	end
	local due = if firstDone then bayJobs >= everyJobs and os.clock() - lastLeft >= Config.CurbJobs.MinGap else bayJobs >= Config.CurbJobs.FirstAfter
	if due then
		come(kind)
	end
end

-- play tests: one now (kind or the level's pick)
function CurbService.force(kind: string?)
	local k = kind or pickKind() or "Washer"
	task.spawn(come, k)
	return k
end

function CurbService.start()
	everyJobs = rng:NextInteger(Config.CurbJobs.EveryJobs[1], Config.CurbJobs.EveryJobs[2])
	Players.PlayerRemoving:Connect(function(p)
		lastGot[p] = nil
	end)
end

return CurbService
