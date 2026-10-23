-- Halloween: Ella, the last customer before closing (docs/design/halloween_pumpkin.md v0.3). Only between
-- Config.Halloween.start and .finish (server UTC). The first visit comes after the owner's tutorial + one ordinary
-- job; later ones once a shift after 2-3 of the owner's jobs. While the last ordinary car leaves: no new customers,
-- "Closing soon" on, the sky goes to night; Ella's coach takes the next free bay (a real job: dead battery first,
-- then a flat or worn pads). A clock (MidnightClock 50..59) moves only with the work, never past 11:59 — no fail.
-- She drives off happy, her glass slipper stays on the garage's shelf, and at the street end the bells ring and the
-- coach pops back into a big pumpkin; then morning. The camera scenes are each client's own (Remotes.Cinema).
-- workspace "EllaNight" = "dusk" (from "Closing soon") | "midnight" (the bells on) | nil: the clients' music (Music).
-- 3D contracts (main): CarParts.Types.PumpkinCoach + CarMeshes "PumpkinCoach_*" (used once baked, else an orange
-- sedan), CarMeshes.Gear_BigPumpkin (pivot = ball centre), CarMeshes.Gear_GlassSlipper (pivot = sole centre, toe -Z);
-- map markers (wr-builder): Garage..ClosingSign (a part with SurfaceGui "Label"), Garage..SlipperSpot.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local CustomerService = require(script.Parent.CustomerService)
local CarService = require(script.Parent.CarService)
local Places = require(script.Parent.Places)
local Guard = require(script.Parent.Guard)

local HalloweenService = {}

local H = Config.Halloween
local rng = Random.new()
HalloweenService.forceActive = nil :: boolean? -- play tests (DevCall "ella")

local state = "idle" -- idle | closing | ella | leaving
local ownerJobs = 0 -- the owner's ordinary jobs this shift (since the last visit)
local target: number? = nil
local visited = false -- once a shift
local dayTime = 14.5
local sign: Instance? = nil
local slipper: Instance? = nil

function HalloweenService.active(): boolean
	if HalloweenService.forceActive ~= nil then
		return HalloweenService.forceActive
	end
	local now = os.time()
	return now >= H.start and now < H.finish
end

local function find(name: string): Instance?
	local g = workspace:FindFirstChild("Garage")
	return g and g:FindFirstChild(name, true)
end

-- the midnight clock: on the server (workspace) and on Ella's car (wr-ui's job card chip reads the car's "Midnight")
local function setClock(m: number?, car: Model?)
	workspace:SetAttribute("MidnightClock", m)
	if not car then
		local cars = workspace:FindFirstChild("Cars")
		for _, c in (if cars then cars:GetChildren() else {}) do
			if c:GetAttribute("CustomerKind") == "Ella" then
				car = c :: Model
			end
		end
	end
	if car then
		car:SetAttribute("Midnight", m)
	end
end

local newTrophy: number? = nil -- the owner who just got the slipper (the morning shows them the trophy card)

local function sky(clock: number, seconds: number)
	TweenService:Create(Lighting, TweenInfo.new(seconds, Enum.EasingStyle.Sine), { ClockTime = clock }):Play()
end

-- "Closing soon": the map's sign if it has one, else words over the first bay's door
local function signOn(on: boolean)
	local mapSign = find("ClosingSign")
	if mapSign then
		local g = mapSign:FindFirstChild("Label")
		if g and g:IsA("SurfaceGui") then
			g.Enabled = on
			local t = g:FindFirstChildOfClass("TextLabel")
			if t then
				Locale.tag(t, "sign.closingSoon")
			end
		end
		return
	end
	if sign then
		sign:Destroy()
		sign = nil
	end
	local bay = Places.bays()[1]
	local approach = bay and Places.marker(bay, "ApproachSpot")
	if not on or not approach then
		return
	end
	local anchor = Instance.new("Part")
	anchor.Name = "ClosingSoon"
	anchor.Anchored, anchor.CanCollide, anchor.CanQuery, anchor.CanTouch = true, false, false, false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.Position = approach.Position + Vector3.new(0, 11, 0)
	local g = Instance.new("BillboardGui")
	g.Size = UDim2.fromScale(14, 2.6)
	g.LightInfluence = 0
	g.Parent = anchor
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = Enum.Font.GothamBlack
	t.TextColor3 = Color3.fromRGB(255, 120, 60)
	t.TextStrokeColor3 = Color3.fromRGB(255, 220, 190)
	t.TextStrokeTransparency = 0.2
	Locale.tag(t, "sign.closingSoon")
	t.Parent = g
	anchor.Parent = workspace
	sign = anchor
end

-- the glass slipper on the owner's shelf (once they have it)
local function placeSlipper()
	if slipper then
		slipper:Destroy()
		slipper = nil
	end
	local owner = PlayerData.owner()
	if not owner or not PlayerData.owns(owner, "GlassSlipper") then
		return
	end
	local spot = find("SlipperSpot")
	local at: CFrame
	if spot and spot:IsA("BasePart") then
		at = spot.CFrame
	else
		local desk = Places.find("WaitingRoom.ReceptionDesk")
		if not desk or not desk:IsA("PVInstance") then
			return
		end
		local cf, size = (desk :: any):GetBoundingBox()
		at = cf * CFrame.new(size.X * 0.32, size.Y / 2 + 0.25, 0)
	end
	local meshes = ReplicatedStorage:FindFirstChild("CarMeshes")
	local t = meshes and meshes:FindFirstChild("Gear_GlassSlipper")
	local m: Instance
	if t and t:IsA("Model") then
		m = t:Clone()
		;(m :: Model):PivotTo(at)
	else
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.45, 0.35, 1)
		p.CFrame = at * CFrame.Angles(0, math.rad(-30), 0)
		p.Material = Enum.Material.Glass
		p.Color = Color3.fromRGB(190, 225, 255)
		p.Transparency = 0.35
		p.Reflectance = 0.2
		p.Anchored, p.CanCollide = true, false
		m = p
	end
	m.Name = "GlassSlipperTrophy"
	m:SetAttribute("Trophy", "trophy.glassSlipper")
	m.Parent = workspace:FindFirstChild("Garage") or workspace
	slipper = m
end

local function morning()
	Remotes.Cinema:FireAllClients("morning", { trophy = newTrophy })
	newTrophy = nil
	sky(dayTime, 1)
	signOn(false)
	workspace:SetAttribute("EllaNight", nil)
	workspace:SetAttribute("MidnightClock", nil)
	local owner = PlayerData.owner()
	local d = owner and PlayerData.get(owner) :: any
	if d then
		d.ellaVisits = (d.ellaVisits or 0) + 1
	end
	state = "idle"
	ownerJobs = 0
	target = nil
	CustomerService.hold = false
end

local function freeBay(): Instance?
	for _, bay in Places.bays() do
		if not bay:GetAttribute("CarId") and (bay:GetAttribute("LiftLevel") or 1) == 1 then
			return bay
		end
	end
	return nil
end

-- the last ordinary car is on its way out: close up, then Ella's coach
local function closing()
	state = "closing"
	visited = true
	CustomerService.hold = true
	sky(H.night, H.duskTime)
	signOn(true)
	workspace:SetAttribute("EllaNight", "dusk")
	local t0 = os.clock()
	local bay = freeBay()
	while not bay do
		task.wait(1)
		if #Players:GetPlayers() == 0 then
			return
		end
		bay = freeBay()
	end
	task.wait(math.max(0, H.duskTime - (os.clock() - t0))) -- (night first, then the coach's lights down the road)
	local owner = PlayerData.owner()
	local d = owner and PlayerData.get(owner) :: any
	local firstVisit = not d or (d.ellaVisits or 0) == 0
	local plan
	if firstVisit then
		plan = { { slot = "Battery", variant = "BAT_DEAD" } }
	elseif rng:NextNumber() < 0.5 then
		plan = { { slot = "Wheel_" .. ({ "FL", "FR", "RL", "RR" })[rng:NextInteger(1, 4)], variant = "TIRE_FLAT" } }
	else
		plan = { { slot = "BrakePads_" .. ({ "FL", "FR" })[rng:NextInteger(1, 2)], variant = "PAD_WORN" } }
	end
	local pumpkin = CarParts.Types.PumpkinCoach ~= nil and CarParts.baked("PumpkinCoach")
	CustomerService.special = {
		kind = "Ella",
		plan = plan,
		carType = if pumpkin then "PumpkinCoach" else "Sedan",
		paint = H.paint, -- (the coach's own orange too: nil here drew a random paint on it — CustomerService falls back to the look's)
		say = "ella.sym." .. plan[1].variant,
		hello = if firstVisit then "ella.hello.1" else "ella.hello.2",
		good = "ella.good.1",
	}
	state = "ella"
	setClock(50)
	task.spawn(function()
		local ok, err = pcall(CustomerService.arrive, bay)
		if not ok then
			warn("[Halloween] " .. tostring(err))
			morning()
		end
	end)
	task.delay(0.5, setClock, 50) -- (the coach exists by now: its job card shows the clock)
	task.wait(0.2)
	Remotes.Cinema:FireAllClients("arrive", { bay = bay })
end

local function due(): boolean
	local owner = PlayerData.owner()
	local d = owner and PlayerData.get(owner) :: any
	if not d or state ~= "idle" or visited or not HalloweenService.active() then
		return false
	end
	if (d.tut or 1) < 4 and not d.tutSkip then
		return false
	end
	if (d.ellaVisits or 0) == 0 then
		return ownerJobs >= 1
	end
	target = target or rng:NextInteger(H.laterAfter[1], H.laterAfter[2])
	return ownerJobs >= (target :: number)
end

-- every hand-back (CustomerService.afterRelease): count the owner's ordinary jobs, maybe close up
local function afterRelease(car: Model, result: any)
	if car:GetAttribute("CustomerKind") == "Ella" or car:GetAttribute("Tutorial") then
		return
	end
	local owner = PlayerData.owner()
	if not owner or not table.find(result.players or {}, owner) then
		return
	end
	ownerJobs += 1
	if due() then
		closing()
	end
end

-- a part came off / went on Ella's coach: the clock moves on (never past 11:59)
function HalloweenService.tick(car: Model)
	if car:GetAttribute("CustomerKind") ~= "Ella" then
		return
	end
	local m = (workspace:GetAttribute("MidnightClock") :: number?) or 50
	setClock(math.min(59, m + 2), car)
end

-- the coach fires up: the leaving scene, the slipper goes on the shelf
local function onSpecialStart(car: Model)
	state = "leaving"
	setClock(59, car)
	local owner = PlayerData.owner()
	if owner then
		if not PlayerData.owns(owner, "GlassSlipper") then
			newTrophy = owner.UserId
		end
		PlayerData.addOwned(owner, "GlassSlipper")
		placeSlipper()
	end
	Remotes.Cinema:FireAllClients("leave", { car = car, bay = CarService.bayOf(car) })
end

local ROLL_RAD = 2 -- the big pumpkin's turn over its 9-stud roll (3 rad ended it upside down: the stem went into the road, main 10-23)
-- off down the road, then at the street end: twelve bells, pop — a big pumpkin rolls away, Ella waves
local function specialDrive(car: Model, legs: { any }): boolean
	-- (stops at the corner — the exit cut, Cinema.PopSpot — not off the map: everything after it is cut)
	local trimmed = table.clone(legs)
	local corner = CustomerService.point("Traffic.ExitCurb")
	for i, leg in legs do
		if corner and (leg.to - corner).Magnitude < 0.5 then
			trimmed = { table.unpack(legs, 1, i) }
			break
		end
	end
	if #trimmed == #legs and #trimmed > 1 then
		table.remove(trimmed)
	end
	CustomerService.drive(car, trimmed)
	if not car.Parent then
		morning()
		return true
	end
	local at = car:GetPivot()
	workspace:SetAttribute("EllaNight", "midnight") -- (the night's music stops: the bells alone)
	Remotes.Cinema:FireAllClients("midnight", { pos = at.Position, trophy = newTrophy }) -- (trophy: keeps its bars)
	task.wait(H.bells) -- (the bells)
	workspace:SetAttribute("MidnightClock", 60)
	Remotes.Effect:FireAllClients("ellaPop", { pos = at.Position + Vector3.new(0, 2, 0) })
	car:Destroy()
	local meshes = ReplicatedStorage:FindFirstChild("CarMeshes")
	local t = meshes and meshes:FindFirstChild("Gear_BigPumpkin")
	local ball: PVInstance
	if t and t:IsA("Model") then
		ball = t:Clone()
	else
		local p = Instance.new("Part")
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.one * 6
		p.Color = H.paint
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored, p.CanCollide = true, false
		local stem = Instance.new("Part")
		stem.Name = "Stem"
		stem.Size = Vector3.new(0.5, 1.2, 0.5)
		stem.Color = Color3.fromHex("4E7A3A")
		stem.Anchored, stem.CanCollide = true, false
		stem.CFrame = CFrame.new(0, 3.4, 0)
		local m = Instance.new("Model")
		p.Name = "Ball"
		p.Parent = m
		stem.Parent = m
		m.PrimaryPart = p
		ball = m
	end
	ball.Name = "BigPumpkin"
	local start = at * CFrame.new(0, 3, 0)
	ball:PivotTo(start)
	ball.Parent = workspace
	local npc = CustomerService.makeNpc("Ella")
	if npc then
		npc:PivotTo(at * CFrame.new(5, 3, 0))
		npc.Parent = workspace
		CustomerService.speak(npc, "ella.home", 3)
		local hum = npc:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Jump = true
		end
	end
	-- roll it down the road a little (turning as it goes)
	local roll = at.LookVector * 9
	local t0 = os.clock()
	while os.clock() - t0 < 1.4 do
		local k = (os.clock() - t0) / 1.4
		ball:PivotTo(CFrame.new(start.Position + roll * k) * CFrame.fromAxisAngle(at.RightVector, -k * ROLL_RAD))
		task.wait()
	end
	task.wait(0.8)
	ball:Destroy()
	if npc then
		npc:Destroy()
	end
	morning()
	return true
end

-- play tests: Ella next (skips the job count; still needs a free bay)
function HalloweenService.force()
	HalloweenService.forceActive = true
	workspace:SetAttribute("SeasonHalloween", true) -- (World/Seasonal: the decor and the "Closing soon" sign too)
	visited = false
	if state == "idle" then
		task.spawn(closing)
	end
end

function HalloweenService.start()
	dayTime = Lighting.ClockTime
	CustomerService.afterRelease = afterRelease
	CustomerService.onSpecialStart = onSpecialStart
	CustomerService.specialDrive = specialDrive
	PlayerData.ownerChanged.Event:Connect(placeSlipper)
	PlayerData.joined.Event:Connect(function(player)
		if PlayerData.owner() == player then
			placeSlipper()
		end
	end)
	-- watched every scene once: from then on a tap skips them
	Remotes.Cinema.OnServerEvent:Connect(Guard.wrap("Cinema", 1, function(player, what)
		local d = PlayerData.get(player) :: any
		if what == "seen" and d and not d.ellaSeen then
			d.ellaSeen = true
			PlayerData.refresh(player)
		end
	end))
end

return HalloweenService
