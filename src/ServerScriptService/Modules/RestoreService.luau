-- Loop B step 2 (docs/design/flip_loop.md §3, fault_catalog paint order, carbook restoration.md §1-3, §2-2):
-- bringing a bought wreck back in the restoration bay.
--   1. Wash: grab the pressure washer at RestoreBay.WashPoint, hold "Wash" on each of the 4 sides (the dirt goes,
--      the rust stays — that's what you'll fix).
--   2. Rust spots (where the rust is decides how bad: carbook 1-3): Sand -> (bad / serious: cut & weld a patch
--      panel) -> Primer -> Paint -> Clear coat -> Polish, one hold per step, in that order. Under-the-car spots need
--      the lift at Under.
--   3. Mechanical faults + the body part (dented hood / hanging bumper / deep scratches): the usual repair flow
--      (Scanner, bolts, buy, swap).
--   4. Restoration % = core parts 60 + looks 25 + clean 15 (flip_loop 3-2) -> Bronze 60+ / Silver 80+ / Gold 95+.
--      Without the Paint Booth the spray-gun paint scores at most Config.SprayQuality.
--   5. "Finish restoration": every part on, lift down -> it starts (or not) and the grade is locked in.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarService = require(script.Parent.CarService)
local EquipmentService = require(script.Parent.EquipmentService)
local FaultService = require(script.Parent.FaultService)
local JobService = require(script.Parent.JobService)
local PlayerData = require(script.Parent.PlayerData)
local Places = require(script.Parent.Places)
local ToolKit = require(script.Parent.ToolKit)
local Guard = require(script.Parent.Guard)

local RestoreService = {}

-- rust spots, car space for the car's right side (x flips for the left). sev 1 minor / 2 bad / 3 serious
RestoreService.Rust = {
	FenderBottom = { sev = 1, pos = Vector3.new(3.82, 3.1, -6.8), size = Vector3.new(0.1, 0.45, 1.4) },
	WheelArch = { sev = 2, pos = Vector3.new(3.82, 3.05, 4.4), size = Vector3.new(0.1, 0.5, 1.8) },
	Rocker = { sev = 2, pos = Vector3.new(3.82, 1.15, -0.6), size = Vector3.new(0.1, 0.45, 4.2) },
	TrunkFloor = { sev = 2, hidden = true, pos = Vector3.new(0, 0.47, 6.2), size = Vector3.new(4, 0.06, 2.6) },
	FloorPan = { sev = 3, hidden = true, pos = Vector3.new(0, 0.47, -0.2), size = Vector3.new(5, 0.06, 4.4) },
	FrameRail = { sev = 3, hidden = true, pos = Vector3.new(2.9, 0.47, -1), size = Vector3.new(0.6, 0.06, 8) },
}
local STEPS = {
	[1] = { "sand", "primer", "paint", "clear", "polish" },
	[2] = { "sand", "weld", "primer", "paint", "clear", "polish" },
	[3] = { "sand", "weld", "primer", "paint", "clear", "polish" },
}
local SIDES = { F = Vector3.new(0, 2.2, -9.4), B = Vector3.new(0, 2.2, 9.4), L = Vector3.new(-4.6, 2.2, 0), R = Vector3.new(4.6, 2.2, 0) }
local DIRT = Color3.fromRGB(110, 92, 70)

-- what a rust spot costs to fix (the appraisal card's estimate): paint supplies + a patch panel for bad / serious
function RestoreService.rustCost(sev: number): number
	return Config.PaintSupplies + (Config.PatchPanel[sev] or 0)
end

local function shellParts(car: Model): { BasePart }
	local out = {}
	local shell = car:FindFirstChild("Body") and car.Body:FindFirstChild("Shell")
	for _, p in (if shell then shell:GetChildren() else {}) do
		if p:IsA("BasePart") and p.Material ~= Enum.Material.Neon then
			table.insert(out, p)
		end
	end
	return out
end

-- years in the yard: the whole body under a coat of dirt (Dirt = sides still dirty, 4..0)
local function paintDirt(car: Model)
	local k = ((car:GetAttribute("Dirt") :: number?) or 0) / 4
	for _, p in shellParts(car) do
		if p:GetAttribute("CleanColor") == nil then
			p:SetAttribute("CleanColor", p.Color)
			p:SetAttribute("CleanMaterial", p.Material.Name)
		end
		local clean = p:GetAttribute("CleanColor") :: Color3
		p.Color = clean:Lerp(DIRT, 0.6 * k)
		p.Material = if k > 0.3 then Enum.Material.Sand else (Enum.Material :: any)[p:GetAttribute("CleanMaterial")]
	end
end

-- a wreck's dirt + rust patches (JunkyardService at spawn). spots = { { spot = "WheelArch", side = 1 | -1 } }
function RestoreService.dress(car: Model, spots: { { spot: string, side: number } })
	car:SetAttribute("Dirt", 4)
	paintDirt(car)
	local folder = Instance.new("Folder")
	folder.Name = "Rust"
	local pv = car:GetPivot()
	for _, s in spots do
		local def = RestoreService.Rust[s.spot]
		local p = Instance.new("Part")
		p.Name = "Rust_" .. s.spot
		p.Size = def.size
		p.CFrame = pv * CFrame.new(def.pos * Vector3.new(s.side, 1, 1))
		p.Color = Color3.fromRGB(128, 70, 34)
		p.Material = Enum.Material.CorrodedMetal
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p:SetAttribute("Spot", s.spot)
		p:SetAttribute("Sev", def.sev)
		p:SetAttribute("Hidden", def.hidden == true)
		p:SetAttribute("Step", 0)
		p.Parent = folder
	end
	folder.Parent = car
end

local function patches(car: Model): { BasePart }
	local f = car:FindFirstChild("Rust")
	local out = {}
	for _, p in (if f then f:GetChildren() else {}) do
		if p:IsA("BasePart") then
			table.insert(out, p)
		end
	end
	return out
end

local function quality(): number
	return if EquipmentService.garageHas("PaintBooth") then 1 else Config.SprayQuality
end

-- the restoration score + the work list the client card shows
function RestoreService.refresh(car: Model)
	if not car:GetAttribute("Restore") or car:GetAttribute("Restored") then
		return
	end
	local list = {}
	local washed = 4 - ((car:GetAttribute("Dirt") :: number?) or 0)
	table.insert(list, { k = "rs.wash", a = { n = washed }, done = washed >= 4 })
	local mechOk, mechAll, looks = 0, 0, {}
	for pair in ((car:GetAttribute("Variants") :: string?) or ""):gmatch("[^,]+") do
		local slot, id = pair:match("^(.-)=(.+)$")
		local kind = CarParts.Slots[slot].kind
		local ok = FaultService.slotOK(car, slot)
		if kind == "Hood" or kind == "Bumper" then
			table.insert(looks, if ok then 1 else 0)
			table.insert(list, { k = "wreck." .. id, done = ok })
		else
			mechAll += 1
			mechOk += if ok then 1 else 0
		end
	end
	local q = quality()
	for _, p in patches(car) do
		local steps = STEPS[p:GetAttribute("Sev") :: number]
		local step = p:GetAttribute("Step") :: number
		table.insert(looks, step / #steps * q)
		table.insert(list, {
			k = "rs.rust",
			a = { spot = "@rust." .. p:GetAttribute("Spot"), sev = "@rust.sev" .. p:GetAttribute("Sev"), step = if step >= #steps then "@rs.done" else "@rs.step." .. steps[step + 1] },
			done = step >= #steps,
		})
	end
	table.insert(list, { k = "rs.mech", a = { n = mechOk, total = mechAll }, done = mechOk == mechAll })
	local lookSum = 0
	for _, v in looks do
		lookSum += v
	end
	local core = if mechAll > 0 then mechOk / mechAll else 1
	local look = if #looks > 0 then lookSum / #looks else 1
	local pct = math.floor(100 * (Config.RestoreWeights.core * core + Config.RestoreWeights.looks * look + Config.RestoreWeights.clean * washed / 4) + 0.5)
	local grade = if pct >= Config.Grades.Gold then "Gold" elseif pct >= Config.Grades.Silver then "Silver" elseif pct >= Config.Grades.Bronze then "Bronze" else "None"
	car:SetAttribute("RestorePct", pct)
	car:SetAttribute("Grade", grade)
	car:SetAttribute("Safe", mechOk == mechAll)
	car:SetAttribute("RestoreList", HttpService:JSONEncode(list))
end

local function look(p: BasePart, car: Model)
	local steps = STEPS[p:GetAttribute("Sev") :: number]
	local step = p:GetAttribute("Step") :: number
	local done = steps[step]
	local side = car.Body.Shell:FindFirstChild("SideL") :: BasePart
	local body = (side:GetAttribute("CleanColor") :: Color3?) or side.Color
	local paint = if p:GetAttribute("Hidden") then Color3.fromRGB(46, 47, 52) else body
	p.Reflectance = 0
	if done == "sand" then
		p.Color, p.Material = Color3.fromRGB(160, 162, 168), Enum.Material.Metal -- bare metal
	elseif done == "weld" then
		p.Color, p.Material = Color3.fromRGB(128, 130, 136), Enum.Material.DiamondPlate -- new patch panel
	elseif done == "primer" then
		p.Color, p.Material = Color3.fromRGB(176, 178, 182), Enum.Material.SmoothPlastic
	elseif done == "paint" then
		p.Color, p.Material = paint:Lerp(Color3.new(0, 0, 0), 0.12), Enum.Material.SmoothPlastic -- dull until the clear coat
	elseif done == "clear" then
		p.Color, p.Material, p.Reflectance = paint, Enum.Material.SmoothPlastic, 0.05
	elseif done == "polish" then
		p.Transparency = 1 -- blends into the body
	end
end

local function near(player: Player, pos: Vector3, reach: number): boolean
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	return root ~= nil and (root.Position - pos).Magnitude <= reach
end

local function prompt(parent: Instance, name: string, key: Enum.KeyCode, hold: number): ProximityPrompt
	local p = Instance.new("ProximityPrompt")
	p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
	p.Name = name
	p.KeyboardKeyCode = key
	p.HoldDuration = hold
	p.MaxActivationDistance = Config.PromptDistance
	p.RequiresLineOfSight = false
	p.Parent = parent
	return p
end

local function stepLabel(p: BasePart, pr: ProximityPrompt)
	local steps = STEPS[p:GetAttribute("Sev") :: number]
	local nextStep = steps[(p:GetAttribute("Step") :: number) + 1]
	if not nextStep then
		pr:Destroy()
		return
	end
	local price = if nextStep == "weld" then Config.PatchPanel[p:GetAttribute("Sev") :: number] elseif nextStep == "primer" then Config.PaintSupplies else nil
	Locale.tag(pr, "rsact." .. nextStep, if price then { price = price } else nil)
	Locale.tag(pr, "rust." .. p:GetAttribute("Spot"), nil, "ObjectText")
end

local function workRust(car: Model, p: BasePart, pr: ProximityPrompt, player: Player)
	if car:GetAttribute("Restored") or not near(player, p.Position, Config.PromptDistance + 4) then
		return
	end
	if ((car:GetAttribute("Dirt") :: number?) or 0) > 0 then
		return Remotes.Notify:FireClient(player, "n.washFirst", nil, "bad")
	end
	if p:GetAttribute("Hidden") then
		local ok, key, args = CarService.check(car, "Lift:Under", nil, player)
		if not ok then
			return Remotes.Notify:FireClient(player, key, args, "bad")
		end
	end
	local sev = p:GetAttribute("Sev") :: number
	local steps = STEPS[sev]
	local step = (p:GetAttribute("Step") :: number) + 1
	local cost = if steps[step] == "weld" then Config.PatchPanel[sev] elseif steps[step] == "primer" then Config.PaintSupplies else 0
	if cost > 0 and not PlayerData.spend(player, cost) then
		return Remotes.Notify:FireClient(player, "n.noMoney", nil, "bad")
	end
	p:SetAttribute("Step", step)
	look(p, car)
	CarService.touch(car, player)
	stepLabel(p, pr)
	RestoreService.refresh(car)
end

local function finish(car: Model, player: Player)
	if car:GetAttribute("Restored") then
		return
	end
	if ((car:GetAttribute("LiftOffset") :: number?) or 0) > 0.05 then
		return Remotes.Notify:FireClient(player, "n.lowerLift", nil, "bad")
	end
	if not JobService.assembled(car) then
		return Remotes.Notify:FireClient(player, "n.notDone", nil, "bad")
	end
	RestoreService.refresh(car)
	car:SetAttribute("Restored", true)
	for _, d in car:GetDescendants() do
		if d:IsA("ProximityPrompt") and (d.Name == "WashPrompt" or d.Name == "RustPrompt" or d.Name == "FinishPrompt") then
			d:Destroy()
		end
	end
	local args = { pct = car:GetAttribute("RestorePct"), grade = "@grade." .. car:GetAttribute("Grade") }
	for _, p in CarService.helpers(car) do
		if car:GetAttribute("Safe") then
			Remotes.Notify:FireClient(p, "n.restored", args, "good")
		else
			Remotes.Notify:FireClient(p, "n.restoredUnsafe", args, "bad")
		end
	end
	if car:GetAttribute("Safe") then
		Remotes.Effect:FireAllClients("carStart", { car = car })
	end
end

-- the car is in the restoration bay: wash / rust / finish prompts
function RestoreService.setup(car: Model)
	local chassis = car.PrimaryPart :: BasePart
	if chassis:FindFirstChild("Wash_F") then
		return
	end
	for side, pos in SIDES do
		local att = Instance.new("Attachment")
		att.Name = "Wash_" .. side
		att.Position = pos
		att.Parent = chassis
		if ((car:GetAttribute("Dirt") :: number?) or 0) > 0 then
			local pr = prompt(att, "WashPrompt", Enum.KeyCode.E, Config.WashHold)
			Locale.tag(pr, "act.wash")
			Locale.tag(pr, "obj.dirtyCar", nil, "ObjectText")
			pr.Triggered:Connect(function(player)
				if car:GetAttribute("Restored") or not near(player, att.WorldPosition, Config.PromptDistance + 4) then
					return
				end
				if ToolKit.equipped(player) ~= "PressureWasher" then
					return Remotes.Notify:FireClient(player, "n.needWasher", nil, "bad")
				end
				pr:Destroy()
				car:SetAttribute("Dirt", math.max(0, ((car:GetAttribute("Dirt") :: number?) or 0) - 1))
				paintDirt(car)
				CarService.touch(car, player)
				RestoreService.refresh(car)
			end)
		end
	end
	for _, p in patches(car) do
		local pr = prompt(p, "RustPrompt", Enum.KeyCode.E, Config.RustHold)
		stepLabel(p, pr)
		pr.Triggered:Connect(function(player)
			workRust(car, p, pr, player)
		end)
	end
	local att = Instance.new("Attachment")
	att.Name = "FinishSpot"
	att.Position = Vector3.new(-4.2, 2.2, 2.4) -- driver's side, behind the door prompts
	att.Parent = chassis
	local fp = prompt(att, "FinishPrompt", Enum.KeyCode.F, 0.8)
	Locale.tag(fp, "act.finishRestore")
	Locale.tag(fp, "obj.restoreCar", nil, "ObjectText")
	fp.Triggered:Connect(Guard.prompt(fp, "Finish", 1, function(player)
		finish(car, player)
	end))
	RestoreService.refresh(car)
end

function RestoreService.start()
	-- the pressure washer at the wash point: everyone can grab one
	task.spawn(function()
		while true do
			local wp = Places.find("RestoreBay.WashPoint") :: BasePart?
			if wp and not wp:FindFirstChild("WasherPrompt") then
				local pr = prompt(wp, "WasherPrompt", Enum.KeyCode.E, 0)
				Locale.tag(pr, "act.grabWasher")
				Locale.tag(pr, "obj.washer", nil, "ObjectText")
				pr.Triggered:Connect(Guard.prompt(pr, "Washer", 1, function(player)
					ToolKit.give(player, "PressureWasher")
					Remotes.Notify:FireClient(player, "n.gotWasher", nil, "good")
				end))
			end
			task.wait(5)
		end
	end)
end

return RestoreService
