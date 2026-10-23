-- The oil change (10-23 user: "put it in before launch"; notes/gpt/wr-dev2/oil_decision.md, docs/design/full_teardown.md
-- ④, notes/research/car_knowledge/teardown/oil_belt_study.md §1). Switch: Config.Features.OilChange (with UnderView — the
-- rows Cars/SedanOil only exist then). The parts (cover, drain plug, gasket, filter, cap) are ordinary part rows with their
-- ordinary bolts; what this module adds is the oil: how much is in the engine, draining it, pouring it, and clearing the
-- job (the OIL_DUE fault, fix "oil": FaultService.slotOK is false while Issue_OilFilter is set).
--   * The server owns the level: car attribute OilL (liters, a plain number the client only reads). The client says
--     "pouring" (Remotes.Oil) and the server adds oil by its own clock, only while the client keeps saying it.
--   * Draining: the plug is out and the cover is off → the pan sits under it (picked for you, like the tools: full_teardown
--     §4-1) and OilL falls. The oil cap on top off = faster (air gets in), as the manual says (x-2082 step 2).
--   * The job is done when everything is back, the gasket and the filter are new and the level is in the good band.
--     Attributes for the screen: OilStep (which line to show), OilL, OilJob (true = this is an oil job car).
-- Old = the car's own gasket / filter (attribute OilOld, put on when the job starts); a part bought at the counter has none.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local CarryService = require(script.Parent.CarryService)
local FaultService = require(script.Parent.FaultService)
local Guard = require(script.Parent.Guard)

local OilService = {}

OilService.TUNING = {
	START = 3.0, -- liters in a job car when it arrives (old oil, a bit low)
	GOOD_LO = 4.2, -- the good band (the manual's quantity is about 4.5 L with the filter; the dipstick decides — oil_belt_study)
	GOOD_HI = 4.8,
	MAX = 6.0, -- the engine takes no more than this (the rest runs over: pouring stops)
	DRAIN_CAP_ON = 0.35, -- L/s with the oil cap on (air has to get in)
	DRAIN_CAP_OFF = 0.9, -- L/s with it off
	POUR = 0.55, -- L/s while the button is held
	POUR_TIMEOUT = 0.7, -- seconds without a "still pouring" from the client and it stops
	DRAINED = 0.15, -- below this the engine is empty
	TICK = 0.2,
}
local T = OilService.TUNING

local POUR_ZONE = "EngineBay" -- the oil cap is under the hood

local pouring: { [Model]: { player: Player, at: number } } = {}
local visual: { [Model]: { pan: Instance?, stream: BasePart?, fill: BasePart? } } = {}

local function slotExists(id: string): boolean
	return CarParts.Slots[id] ~= nil
end

-- the installed part in a slot (nil when the slot is empty or this build has no such slot)
local function installed(car: Model, id: string): Instance?
	if not slotExists(id) then
		return nil
	end
	return CarFactory.slotPart(car, id)
end

local function boltedOn(part: Instance?): boolean
	if not part then
		return false
	end
	local n = part:GetAttribute("BoltCount") :: number?
	local left = part:GetAttribute("BoltsRemaining") :: number?
	return n == nil or left == nil or left >= n
end

local function isOld(part: Instance?): boolean
	return part ~= nil and part:GetAttribute("OilOld") == true
end

function OilService.band(oil: number): number
	if oil < T.DRAINED then
		return 0
	elseif oil < T.GOOD_LO then
		return 1
	elseif oil <= T.GOOD_HI then
		return 2
	end
	return 3
end

-- the car is an oil job (the filter's slot carries the OIL_DUE issue, or did until it was done)
function OilService.isJob(car: Model): boolean
	return car:GetAttribute("OilJob") == true
end

-- the facts about the car right now
local function facts(car: Model)
	local panel = installed(car, "OilAccessPanel")
	local plug = installed(car, "OilDrainPlug")
	local gasket = installed(car, "OilDrainPlugGasket")
	local filter = installed(car, "OilFilter")
	local cap = installed(car, "OilFillCap")
	return {
		panel = panel,
		plug = plug,
		gasket = gasket,
		filter = filter,
		cap = cap,
		panelOn = panel ~= nil and boltedOn(panel),
		plugIn = plug ~= nil and boltedOn(plug),
		gasketNew = gasket ~= nil and not isOld(gasket),
		filterIn = filter ~= nil and boltedOn(filter),
		filterNew = filter ~= nil and not isOld(filter),
		-- (a build whose bay isn't live has no oil cap slot: counted as closed for "done", open for pouring)
		capOn = not slotExists("OilFillCap") or boltedOn(cap),
		capOpen = cap == nil,
	}
end

-- which line the screen shows (OilUI): the next thing to do, whatever order the player has gone in
local function stepOf(car: Model, f: any, oil: number): string
	if car:GetAttribute("OilDone") == true then
		return "done"
	end
	local band = OilService.band(oil)
	local drainedOnce = car:GetAttribute("OilDrainedOnce") == true
	-- the cover is on and something under the car is still to do
	if f.panelOn and (not drainedOnce or not f.gasketNew or not f.filterNew) then
		return "panel"
	end
	if f.plug == nil then
		if oil >= T.DRAINED then
			return "drain"
		elseif not f.gasketNew then
			return "gasket"
		end
		return "plugin"
	end
	if not f.plugIn then
		return "plugin"
	end
	if not drainedOnce then
		return "plug"
	end
	if not f.gasketNew then
		return "gasket" -- (a new gasket goes under the plug's head: the plug comes out again)
	end
	if not f.filterIn or not f.filterNew then
		return "filter"
	end
	if band == 3 then
		return "toomuch"
	elseif band < 2 then
		return if f.capOpen then "pour" else "cap"
	end
	if not f.capOn then
		return "capon"
	end
	if not f.panelOn then
		return "paneron"
	end
	return "done"
end

------------------------------------------------------------------------------------------------------- the picture

local function worldOf(car: Model, p: Vector3): Vector3
	return car:GetPivot():PointToWorldSpace(p)
end

local function dropVisual(car: Model)
	local v = visual[car]
	if v then
		for _, i in { v.pan, v.stream, v.fill } do
			if i then
				i:Destroy()
			end
		end
		visual[car] = nil
	end
end

local function plugSpot(car: Model): Vector3?
	local gen = CarParts.bayOf(car:GetAttribute("CarType") :: string?).parts.OilDrainPlug
	return gen and worldOf(car, gen.pivot)
end

-- the pan under the plug (CarMeshes.Tool_DrainPan or a stand-in) and, while oil runs, a stream and the oil in the pan
local function showPan(car: Model, running: boolean, frac: number)
	local at = plugSpot(car)
	if not at then
		return
	end
	local v = visual[car]
	local base = car:GetAttribute("BaseCFrame") :: CFrame?
	local floorY = (if base then base.Position.Y else at.Y - 2.6) + 0.05 -- (the bay floor under the car)
	if not v then
		v = {}
		visual[car] = v
		local meshes = ReplicatedStorage:FindFirstChild("CarMeshes")
		local template = meshes and meshes:FindFirstChild("Tool_DrainPan")
		local pan: Instance
		local at0 = CFrame.new(at.X, floorY, at.Z) * CFrame.Angles(0, math.pi / 2, 0) -- (feet on the floor, spout across the car)
		if template and (template:IsA("MeshPart") or template:IsA("Model")) then
			pan = template:Clone()
			for _, d in { pan, table.unpack(pan:GetDescendants()) } do
				if d:IsA("BasePart") then
					d.Anchored = true
					d.CanCollide = false
					d.CanTouch = false
					d.CanQuery = false
				end
			end
			if pan:IsA("MeshPart") then
				-- (a MeshPart sits on its centre: the 3D's feet are at 0, so lift it by half its height)
				pan.CFrame = at0 * CFrame.new(0, pan.Size.Y / 2, 0)
			else
				(pan :: Model):PivotTo(at0)
			end
		else
			local p = Instance.new("Part")
			p.Size = Vector3.new(1.05, 0.44, 1.96)
			p.Color = Color3.fromRGB(235, 130, 40)
			p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
			p.CFrame = at0 * CFrame.new(0, 0.22, 0)
			pan = p
		end
		pan.Name = "OilPan"
		pan.Parent = car
		v.pan = pan
	end
	if running then
		if not v.stream then
			local s = Instance.new("Part")
			s.Name = "OilStream"
			s.Color = Color3.fromRGB(70, 45, 20)
			s.Material = Enum.Material.SmoothPlastic
			s.Transparency = 0.12
			s.Anchored, s.CanCollide, s.CanTouch, s.CanQuery = true, false, false, false
			s.Parent = car
			v.stream = s
		end
		local top = at.Y - 0.1
		local bottom = floorY + 0.3
		local s = v.stream :: BasePart
		s.Size = Vector3.new(0.07, math.max(0.1, top - bottom), 0.07)
		s.CFrame = CFrame.new(at.X, (top + bottom) / 2, at.Z)
	elseif v.stream then
		v.stream:Destroy()
		v.stream = nil
	end
	if frac > 0.02 then
		if not v.fill then
			local f = Instance.new("Part")
			f.Name = "OilInPan"
			f.Shape = Enum.PartType.Cylinder
			f.Color = Color3.fromRGB(55, 36, 16)
			f.Material = Enum.Material.SmoothPlastic
			f.Anchored, f.CanCollide, f.CanTouch, f.CanQuery = true, false, false, false
			f.Parent = car
			v.fill = f
		end
		local f = v.fill :: BasePart
		local h = 0.02 + 0.12 * math.clamp(frac, 0, 1)
		f.Size = Vector3.new(h, 0.78, 1.25)
		f.CFrame = CFrame.new(at.X, floorY + 0.16 + h / 2, at.Z) * CFrame.Angles(0, 0, math.rad(90))
	elseif v.fill then
		v.fill:Destroy()
		v.fill = nil
	end
end

------------------------------------------------------------------------------------------------------- the job

-- a fresh oil job car: its own gasket and filter are the old ones; the engine holds old oil
local function begin(car: Model)
	-- (the plan is rolled before the car type: a type without the oil parts — the SUV, the coach — can't do this job.
	-- Let it go at once so the car is not stuck on a fault nobody can fix; CustomerService should choose the type first)
	local ty = CarParts.type(car:GetAttribute("CarType") :: string?)
	if not ty.Slots.OilFilter then
		FaultService.clearIssue(car, "OilFilter")
		return
	end
	car:SetAttribute("OilJob", true)
	car:SetAttribute("OilL", T.START)
	car:SetAttribute("OilDone", false)
	for _, id in { "OilDrainPlugGasket", "OilFilter" } do
		local p = installed(car, id)
		if p then
			p:SetAttribute("OilOld", true)
		end
	end
end

local function finish(car: Model)
	car:SetAttribute("OilDone", true)
	car:SetAttribute("OilStep", "done")
	FaultService.clearIssue(car, "OilFilter")
	dropVisual(car)
	pouring[car] = nil
	for _, p in CarService.helpers(car) do
		Remotes.Notify:FireClient(p, "n.oilDone", nil, "good")
	end
	if CarryService.onCarChanged then
		CarryService.onCarChanged(car)
	end
end

local function tickCar(car: Model, dt: number)
	if car:GetAttribute("OilDone") == true then
		return
	end
	local oil = (car:GetAttribute("OilL") :: number?) or T.START
	local f = facts(car)
	local running = false
	-- draining: the plug is out and the cover is off (the pan is under it)
	if f.plug == nil and f.panel == nil and oil > 0 then
		local rate = if f.capOpen then T.DRAIN_CAP_OFF else T.DRAIN_CAP_ON
		oil = math.max(0, oil - rate * dt)
		running = oil > 0
		if oil < T.DRAINED then
			car:SetAttribute("OilDrainedOnce", true)
		end
	end
	-- pouring
	local pour = pouring[car]
	if pour then
		local alive = pour.player.Parent ~= nil and os.clock() - pour.at <= T.POUR_TIMEOUT
		if alive and f.capOpen and f.plugIn and f.filterIn and oil < T.MAX then
			oil = math.min(T.MAX, oil + T.POUR * dt)
		else
			pouring[car] = nil
		end
	end
	if oil ~= car:GetAttribute("OilL") then
		car:SetAttribute("OilL", oil)
	end
	-- the pan stays under the plug while the cover is off and oil has run (it's what you drained into)
	if f.panel == nil and (f.plug == nil or (car:GetAttribute("OilDrainedOnce") == true)) then
		showPan(car, running, math.clamp((T.START - oil) / T.START, 0, 1))
	else
		dropVisual(car)
	end
	local step = stepOf(car, f, oil)
	if car:GetAttribute("OilStep") ~= step then
		car:SetAttribute("OilStep", step)
	end
	-- done: everything back on, new gasket and filter, the good band, drained at least once
	if f.panelOn and f.plugIn and f.gasketNew and f.filterIn and f.filterNew and f.capOn and OilService.band(oil) == 2
		and car:GetAttribute("OilDrainedOnce") == true then
		finish(car)
	end
end

local function carsFolder(): Instance?
	return workspace:FindFirstChild("Cars")
end

local function onPour(player: Player, car: any, on: any)
	if typeof(car) ~= "Instance" or not car:IsA("Model") or car.Parent ~= carsFolder() or type(on) ~= "boolean" then
		return
	end
	if not OilService.isJob(car) or car:GetAttribute("OilDone") == true then
		return
	end
	if not on then
		local cur = pouring[car]
		if cur and cur.player == player then
			pouring[car] = nil
		end
		return
	end
	-- in the engine bay's work zone of this car
	if player:GetAttribute("WorkCar") ~= car:GetAttribute("CarId") or player:GetAttribute("WorkZone") ~= POUR_ZONE then
		return
	end
	local f = facts(car)
	if not f.capOpen then
		Remotes.Notify:FireClient(player, "n.oilCapFirst", nil, "bad")
		return
	end
	if not (f.plugIn and f.filterIn) then
		Remotes.Notify:FireClient(player, "n.oilPlugFirst", nil, "bad")
		return
	end
	local cur = pouring[car]
	if cur and cur.player ~= player and cur.player.Parent and os.clock() - cur.at <= T.POUR_TIMEOUT then
		return -- one pours at a time
	end
	pouring[car] = { player = player, at = os.clock() }
end

function OilService.start()
	if not Config.feature("OilChange") then
		return
	end
	Remotes.Oil.OnServerEvent:Connect(Guard.wrap("Oil", 0.1, onPour))
	task.spawn(function()
		local last = os.clock()
		while true do
			task.wait(T.TICK)
			local now = os.clock()
			local dt = math.min(now - last, 0.5)
			last = now
			local folder = carsFolder()
			for _, car in (if folder then folder:GetChildren() else {}) do
				if car:IsA("Model") then
					if not OilService.isJob(car) and car:GetAttribute("Issue_OilFilter") == "oil" then
						begin(car)
					end
					if OilService.isJob(car) then
						tickCar(car, dt)
					end
				end
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		for car, pour in pouring do
			if pour.player == p then
				pouring[car] = nil
			end
		end
	end)
end

-- Studio tests (DevCall): make this car an oil job now
function OilService.force(car: Model)
	car:SetAttribute("Issue_OilFilter", "oil")
	begin(car)
end

return OilService
