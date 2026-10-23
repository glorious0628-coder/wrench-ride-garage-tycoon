-- Loop B step 1 (docs/design/flip_loop.md §1-2, world_contract ★ 폐차장): wrecks for sale in the junkyard.
--   From garage Lv8 the 10 WreckSpots fill with rusty cars (2~3 mechanical faults + 1 body problem, dirty).
--   AppraisePoints.SpotN: "Appraise" → the client's appraisal card (what you can see, the price, a repair estimate
--   with a "$0~250 hidden" margin, the expected profit) → Buy (Remotes.BuyWreck) — needs the Restoration Bay.
--   Bought: "Tow it for me" — the wreck leaves its spot and, TowSeconds later, sits in RestoreBay.CarSpot (yours).
--   A sold spot gets a new wreck 2~4 minutes later.
-- What the card shows comes from carbook restoration.md §1: the title stamp (CLEAN / SALVAGE -> sells as Rebuilt /
-- JUNK = parts only, can't be bought to restore) and rust by where it is (fender bottom minor ... frame rail serious;
-- under-the-car rust only shows on the lift, so it hides in the "$0~250").

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Faults = require(ReplicatedStorage.Shared.Faults)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local DiagnosisService = require(script.Parent.DiagnosisService)
local EquipmentService = require(script.Parent.EquipmentService)
local FaultService = require(script.Parent.FaultService)
local PlayerData = require(script.Parent.PlayerData)
local Places = require(script.Parent.Places)
local RestoreService = require(script.Parent.RestoreService)
local Guard = require(script.Parent.Guard)

local JunkyardService = {}

local rng = Random.new()
local wrecks: { [number]: Model } = {} -- spot index -> wreck for sale
local refillAt: { [number]: number } = {}

-- the body problem every wreck has (flip_loop §3-1: one visible exterior job)
local BODY = { { slot = "Hood", variant = "BODY_DENT" }, { slot = "Bumper_F", variant = "BUMPER_HANGING" }, { slot = "Bumper_R", variant = "BODY_SCRATCH_DEEP" } }
-- what you can see without lifting it (the hood opens for a look); brake pads / muffler stay a guess
local SEEN = { Battery = true, Radiator = true, Wheel = true, Hood = true, Bumper = true }

local function spotsFolder(): Instance?
	return Places.find("Junkyard.WreckSpots")
end

local VISIBLE_RUST = { "FenderBottom", "WheelArch", "Rocker" }
local HIDDEN_RUST = { "TrunkFloor", "FloorPan", "FrameRail" }

local function pickTitle(): string
	local level = PlayerData.garageLevel()
	local odds = Config.TitleChance[1]
	for _, o in Config.TitleChance do
		if level >= o.level then
			odds = o
		end
	end
	local r, acc = rng:NextNumber(), 0
	for _, t in { "Clean", "Salvage", "Flood", "Junk" } do
		acc += (odds :: any)[t] or 0
		if r <= acc then
			return t
		end
	end
	return "Clean"
end

-- 1 rust spot you can see + sometimes one under the car — but what's hidden never adds up to more than the
-- card's "$0~250" (hidden mechanical faults count too)
local function planRust(plan: { FaultService.Fault }): { { spot: string, side: number } }
	local spots = { { spot = VISIBLE_RUST[rng:NextInteger(1, #VISIBLE_RUST)], side = if rng:NextNumber() < 0.5 then 1 else -1 } }
	local hidden = 0
	for _, f in plan do
		local kind = CarParts.Slots[f.slot].kind
		if not SEEN[kind] then
			hidden += CarParts.Kinds[kind].price
		end
	end
	if rng:NextNumber() < Config.HiddenRustChance then
		local spot = HIDDEN_RUST[rng:NextInteger(1, #HIDDEN_RUST)]
		if hidden + RestoreService.rustCost(RestoreService.Rust[spot].sev) <= Config.WreckHiddenMax then
			table.insert(spots, { spot = spot, side = if rng:NextNumber() < 0.5 then 1 else -1 })
		end
	end
	return spots
end

local function planWreck(): { FaultService.Fault }
	local pool = {}
	for _, slotName in CarParts.SlotOrder do
		local slot = CarParts.Slots[slotName]
		if slot.faultable and slot.kind ~= "Hood" and slot.kind ~= "Bumper" then
			table.insert(pool, slotName)
		end
	end
	local plan = {}
	local used = {}
	local want = rng:NextInteger(Config.WreckFaults[1], Config.WreckFaults[2])
	while #plan < want and #pool > 0 do -- different kinds: two flat tires would be one job twice
		local slotName = table.remove(pool, rng:NextInteger(1, #pool))
		local kind = CarParts.Slots[slotName].kind
		if not used[kind] then
			used[kind] = true
			-- a worn-out part of that kind (no traps in a wreck: everything is just old)
			local options = {}
			for _, v in Faults.Variants do
				if v.kind == kind and v.fix == "replace" and not v.gear then
					table.insert(options, v)
				end
			end
			if #options > 0 then -- (a kind with no worn-out fault yet: piece E's new parts before their faults)
				local v = options[rng:NextInteger(1, #options)]
				table.insert(plan, { slot = slotName, variant = v.id })
			end
		end
	end
	table.insert(plan, BODY[rng:NextInteger(1, #BODY)])
	return plan
end

-- price + estimates (flip_loop §1, §6): restored value x a typical Silver restoration, minus what's needed
local function appraise(car: Model): { [string]: any }
	local seen, guess = {}, 0
	local partsSeen = 0
	for pair in ((car:GetAttribute("Variants") :: string?) or ""):gmatch("[^,]+") do
		local slot, id = pair:match("^(.-)=(.+)$")
		local kind = CarParts.Slots[slot].kind
		local price = CarParts.Kinds[kind].price
		if SEEN[kind] then
			table.insert(seen, { k = "wreck." .. id })
			partsSeen += price
		else
			guess += 1
		end
	end
	local rust = car:FindFirstChild("Rust")
	for _, r in (if rust then rust:GetChildren() else {}) do
		if r:GetAttribute("Hidden") then
			guess += 1
		else
			table.insert(seen, { k = "wreck.rust", a = { spot = "@rust." .. r:GetAttribute("Spot"), sev = "@rust.sev" .. r:GetAttribute("Sev") } })
			partsSeen += RestoreService.rustCost(r:GetAttribute("Sev") :: number)
		end
	end
	local price = car:GetAttribute("Price") :: number
	local title = car:GetAttribute("Title") :: string
	local value = Config.RestoredValue * Config.TypicalRestore * Config.TitleValue[title]
	return {
		price = price,
		title = title,
		seen = seen,
		hidden = guess > 0,
		repairLo = partsSeen,
		repairHi = partsSeen + Config.WreckHiddenMax,
		profitLo = math.floor(value * Config.QuickSellRate - price - partsSeen - Config.WreckHiddenMax),
		profitHi = math.floor(value - price - partsSeen),
	}
end

local function setTag(i: number, text: string)
	local tag = Places.find("Junkyard.PriceTags.Spot" .. i .. ".Label.Price") :: TextLabel?
	if tag and tag:IsA("TextLabel") then
		tag.Text = text
	end
end

local function spawnWreck(i: number)
	local spot = Places.find("Junkyard.WreckSpots.Spot" .. i) :: BasePart?
	if not spot then
		return
	end
	local plan = planWreck()
	local car = CarService.spawn(spot.CFrame, plan)
	car:SetAttribute("Wreck", true)
	car:SetAttribute("WreckSpot", i)
	RestoreService.dress(car, planRust(plan)) -- dirt + rust patches
	local title = pickTitle()
	car:SetAttribute("Title", title)
	car:SetAttribute("OneOwner", rng:NextNumber() < Config.OneOwnerChance or nil)
	-- a cheaper wreck the more it needs (flip_loop §1: $500~900, a good one up to ~$1,200); a salvage title costs
	-- less to buy and sells for less; a junk title is only worth its metal and parts
	local faults = #string.split(car:GetAttribute("Faults") or "", ",")
	local price = math.clamp(Config.WreckPrice[2] - (faults - 2) * 130 + rng:NextInteger(-60, 60), Config.WreckPrice[1], Config.WreckPrice[3])
	price *= Config.TitlePrice[title]
	car:SetAttribute("Price", math.floor(price / 10) * 10)
	car:SetAttribute("BaseCFrame", spot.CFrame)
	CarFactory.pose(car)
	wrecks[i] = car
	setTag(i, if title == "Junk" then Locale.text("en", "wreck.partsTag") else Locale.money(car:GetAttribute("Price")))
end

-- fill the empty spots (Lv8+, junkyard in the map)
function JunkyardService.refresh()
	if not spotsFolder() or PlayerData.garageLevel() < Config.JunkyardLevel then
		return
	end
	for i = 1, 10 do
		if not wrecks[i] and os.clock() >= (refillAt[i] or 0) then
			spawnWreck(i)
		end
	end
end

local function nearSpot(player: Player, i: number): boolean
	local ap = Places.find("Junkyard.AppraisePoints.Spot" .. i) :: BasePart?
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	return ap ~= nil and root ~= nil and (root.Position - ap.Position).Magnitude <= Config.ShopReach
end

-- the tow truck (block stand-in until the 3D one): drives in to Junkyard.TowSpot, hooks the wreck by its front
-- wheels, waits out the tow time and then drives the yard road -> side drive -> RestoreBay.ApproachSpot, where the
-- wreck is set down in RestoreBay.CarSpot. Not in workspace.Cars (it's not a job car).
local TRUCK = {
	{ "Frame", Vector3.new(6.4, 1.2, 17), Vector3.new(0, 2, 0), Color3.fromRGB(40, 40, 44) },
	{ "Cab", Vector3.new(6.8, 4.6, 5.6), Vector3.new(0, 4.6, -4.8), Color3.fromRGB(232, 168, 40) },
	{ "Glass", Vector3.new(6.2, 1.8, 0.3), Vector3.new(0, 5.6, -7.65), Color3.fromRGB(110, 150, 180) },
	{ "Bed", Vector3.new(6.8, 1.6, 10), Vector3.new(0, 3.2, 3.2), Color3.fromRGB(232, 168, 40) },
	{ "Boom", Vector3.new(1, 1, 6), Vector3.new(0, 4.4, 7.6), Color3.fromRGB(60, 60, 64) },
	{ "Beacon", Vector3.new(1.6, 0.6, 0.8), Vector3.new(0, 7.2, -4.8), Color3.fromRGB(255, 140, 20), Enum.Material.Neon },
}
local TRUCK_WHEELS = { Vector3.new(-3.3, 1.4, -5), Vector3.new(3.3, 1.4, -5), Vector3.new(-3.3, 1.4, 5), Vector3.new(3.3, 1.4, 5) }
local HITCH = CFrame.new(0, 1.4, 17.5) * CFrame.Angles(math.rad(6), 0, 0) -- the wreck behind, front wheels up

local function buildTruck(at: CFrame): Model
	local m = Instance.new("Model")
	m.Name = "TowTruck"
	for _, d in TRUCK do
		local p = Instance.new("Part")
		p.Name, p.Size, p.Color = d[1], d[2], d[4]
		p.Material = d[5] or Enum.Material.SmoothPlastic
		p.CFrame = at * CFrame.new(d[3])
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Parent = m
	end
	for i, w in TRUCK_WHEELS do
		local p = Instance.new("Part")
		p.Name = "Wheel" .. i
		p.Shape = Enum.PartType.Cylinder
		p.Size = Vector3.new(1.2, 2.8, 2.8)
		p.Color = Color3.fromRGB(28, 28, 30)
		p.CFrame = at * CFrame.new(w)
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
		p.Parent = m
	end
	m.WorldPivot = at
	m.Parent = workspace
	return m
end

-- drive the truck (and what hangs off it) through the points at TowSpeed, turning smoothly at the corners
local function drive(truck: Model, points: { Vector3 }, wreck: Model?)
	local function place(cf: CFrame)
		truck:PivotTo(cf)
		if wreck then
			wreck:PivotTo(cf * HITCH)
		end
	end
	local cf = truck:GetPivot()
	for _, target in points do
		local from = cf.Position
		local flat = Vector3.new(target.X, from.Y, target.Z)
		local dist = (flat - from).Magnitude
		if dist > 0.5 then
			local heading = CFrame.lookAt(from, flat).Rotation
			local startRot = cf.Rotation
			local t, T = 0, dist / Config.TowSpeed
			while t < T do
				t += task.wait()
				local a = math.min(t / T, 1)
				local turn = math.min(t / 0.8, 1) -- 0.8 s to swing round to the new heading
				cf = CFrame.new(from:Lerp(flat, a)) * startRot:Lerp(heading, turn)
				place(cf)
			end
		end
	end
	return cf
end

local function marker(path: string): Vector3?
	local m = Places.find(path) :: BasePart?
	return m and m.Position
end

-- "Tow it for me": free, the wreck is in the restoration bay TowSeconds after buying
local function tow(car: Model, owner: Player)
	local restore = Places.find("RestoreBay")
	local spot = restore and restore:FindFirstChild("CarSpot") :: BasePart?
	local towSpot = Places.find("Junkyard.TowSpot") :: BasePart?
	local entry, gate = marker("Junkyard.JunkyardEntry"), marker("Junkyard.Gate.GatePoint")
	local side, approach = marker("Traffic.SideDriveBack"), marker("RestoreBay.ApproachSpot")
	if not (restore and spot and towSpot and entry and gate and side and approach) then
		return
	end
	restore:SetAttribute("CarId", car:GetAttribute("CarId")) -- reserved
	car:SetAttribute("Towing", true)
	task.spawn(function()
		local t0 = os.clock()
		local truck = buildTruck(CFrame.lookAt(entry, gate))
		drive(truck, { gate, towSpot.Position })
		truck:PivotTo(towSpot.CFrame) -- backed up to the wreck lane
		car:PivotTo(towSpot.CFrame * HITCH) -- hooked
		local back = { gate, entry, side, approach, approach + Vector3.new(-14, 0, 0) }
		-- leave so it pulls up at the bay right on time (the road is ~270 studs)
		local length, from = 0, towSpot.Position
		for _, p in back do
			length += (Vector3.new(p.X, 0, p.Z) - Vector3.new(from.X, 0, from.Z)).Magnitude
			from = p
		end
		task.wait(math.max(0, Config.TowSeconds - (os.clock() - t0) - length / Config.TowSpeed))
		drive(truck, back, car)
		if car.Parent then
			car:SetAttribute("Towing", nil)
			CarService.park(car, restore) -- set down in the bay
			DiagnosisService.setup(car)
			RestoreService.setup(car)
			if owner.Parent then
				CarService.touch(car, owner)
			end
			if owner.Parent then
				Remotes.Notify:FireClient(owner, "n.towed", nil, "good")
			end
		end
		drive(truck, { approach + Vector3.new(-60, 0, 0) })
		truck:Destroy()
	end)
end

local function buy(player: Player, i: any): (boolean, string?, { [string]: any }?)
	if type(i) ~= "number" then
		return false
	end
	local car = wrecks[i]
	if not car or not nearSpot(player, i) then
		return false, "n.tooFar"
	end
	if car:GetAttribute("Title") == "Junk" then
		return false, "n.junkTitle"
	end
	if not EquipmentService.garageHas("RestorationBay") then
		return false, "n.needRestoreBay"
	end
	local restore = Places.find("RestoreBay")
	if not restore or restore:GetAttribute("CarId") then
		return false, "n.restoreBusy"
	end
	if not PlayerData.spend(player, car:GetAttribute("Price") :: number) then
		return false, "n.noMoney"
	end
	wrecks[i] = nil
	refillAt[i] = os.clock() + rng:NextInteger(Config.WreckRefill[1], Config.WreckRefill[2])
	setTag(i, "")
	car:SetAttribute("Wreck", nil)
	car:SetAttribute("OwnerId", player.UserId) -- the buyer: paid back first when it sells (flip_loop §7)
	car:SetAttribute("PaidPrice", car:GetAttribute("Price"))
	car:SetAttribute("Restore", true)
	tow(car, player)
	return true, "n.boughtWreck", { price = car:GetAttribute("Price"), seconds = Config.TowSeconds }
end

function JunkyardService.start()
	Remotes.BuyWreck.OnServerInvoke = Guard.wrap("BuyWreck", 0.5, buy)
	-- the appraise prompts at each spot
	local function hookPrompts()
		for i = 1, 10 do
			local ap = Places.find("Junkyard.AppraisePoints.Spot" .. i) :: BasePart?
			if ap and not ap:FindFirstChild("AppraisePrompt") then
				local p = Instance.new("ProximityPrompt")
				p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
				p.Name = "AppraisePrompt"
				p.KeyboardKeyCode = Enum.KeyCode.E
				p.MaxActivationDistance = Config.PromptDistance + 3
				p.RequiresLineOfSight = false
				Locale.tag(p, "act.appraise")
				Locale.tag(p, "obj.wreck", nil, "ObjectText")
				p.Parent = ap
				p.Triggered:Connect(function(player)
					local car = wrecks[i]
					if car then
						local card = appraise(car)
						card.spot = i
						card.canBuy = EquipmentService.garageHas("RestorationBay") and card.title ~= "Junk"
						Remotes.Appraisal:FireClient(player, card)
					end
				end)
			end
			-- only where a wreck sits (before Lv8 there are none: "Appraise" showed up and did nothing — wr-gamer g15)
			local p = ap and ap:FindFirstChild("AppraisePrompt") :: ProximityPrompt?
			if p then
				p.Enabled = wrecks[i] ~= nil and wrecks[i].Parent ~= nil
			end
		end
	end
	task.spawn(function()
		while true do
			JunkyardService.refresh()
			hookPrompts()
			task.wait(5)
		end
	end)
end

return JunkyardService
