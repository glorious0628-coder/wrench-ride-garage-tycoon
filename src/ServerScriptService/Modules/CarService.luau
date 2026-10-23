-- Cars in bays: spawn one with faults, the hood prompt, finding a car / bay from a part.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local FaultService = require(script.Parent.FaultService)
local Guard = require(script.Parent.Guard)

local CarService = {}
CarService.onHoodOpened = nil :: ((player: Player, car: Model) -> ())? -- Main: into the work view

-- the car Model a part / bolt belongs to (nil for loose parts)
function CarService.carOf(inst: Instance): Model?
	local cars = workspace:FindFirstChild("Cars")
	local n: Instance? = inst
	while n and n.Parent ~= cars do
		n = n.Parent
	end
	return if n and n:IsA("Model") then n else nil
end

function CarService.bayOf(car: Model): Instance?
	local garage = workspace:FindFirstChild("Garage")
	local bays = garage and garage:FindFirstChild("Bays")
	if not bays then
		return nil
	end
	for _, bay in bays:GetChildren() do
		if bay:GetAttribute("CarId") == car:GetAttribute("CarId") then
			return bay
		end
	end
	return nil
end

function CarService.carIn(bay: Instance): Model?
	local id = bay:GetAttribute("CarId")
	if not id then
		return nil
	end
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:GetAttribute("CarId") == id then
			return c :: Model
		end
	end
	return nil
end

local function hoodPrompt(car: Model)
	local hood = CarFactory.slotPart(car, "Hood")
	if not hood or hood:FindFirstChild("HoodPrompt") then
		return
	end
	local p = Instance.new("ProximityPrompt")
	p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
	p.Name = "HoodPrompt"
	p.MaxActivationDistance = Config.PromptDistance
	p.RequiresLineOfSight = false
	p.HoldDuration = 0
	p.KeyboardKeyCode = Enum.KeyCode.E
	Locale.tag(p, if car:GetAttribute("HoodOpen") then "act.closeHood" else "act.openHood")
	p.Parent = CarFactory.root(hood)
	p.Triggered:Connect(Guard.prompt(p, "Hood", 0.3, function(player)
		CarService.toggleHood(car, player)
	end))
end
CarService.hoodPrompt = hoodPrompt

-- open / shut the hood (its prompt, or the first car's Scan — rival_upgrade B1-2: "Scan → the hood opens → the
-- work view"); the one who opened it goes into the engine bay view
function CarService.toggleHood(car: Model, player: Player?)
	local hood = CarFactory.slotPart(car, "Hood")
	if not hood or hood:GetAttribute("State") ~= "Installed" or CarService.carOf(hood) ~= car then
		return
	end
	local open = not car:GetAttribute("HoodOpen")
	local from = CarFactory.root(hood).CFrame -- (each screen swings it on its hinge from here — BoltLook.swing)
	car:SetAttribute("HoodOpen", open)
	CarFactory.reseat(car, "Hood")
	Remotes.Effect:FireAllClients("hood", { car = car, open = open, part = hood, from = from })
	if open and player and CarService.onHoodOpened then
		CarService.onHoodOpened(player, car) -- (the work view: the one who opened it goes in — work_view 2)
	end
	local p = CarFactory.root(hood):FindFirstChild("HoodPrompt")
	if p then
		Locale.tag(p, if open then "act.closeHood" else "act.openHood")
	end
end

-- the engine bay is reachable: hood swung open, or the hood is off the car
function CarService.hoodOpen(car: Model): boolean
	return car:GetAttribute("HoodOpen") == true or CarFactory.slotPart(car, "Hood") == nil
end

-- Requires strings (car_spec 3-2): "Hood:Open", "Lift:Wheel", "Lift:Under", or a slot that must be empty.
-- Returns ok, or false + a notice key and args.
-- how high the car has to be for "Lift:Wheel" / "Lift:Under" (its type's LiftLevels: sedan Wheel 1.8, SUV 1.7)
local function liftY(car: Model, name: string): number
	for _, l in CarFactory.geo(car).LiftLevels do
		if l.name == name then
			return l.y
		end
	end
	return 0
end
-- slotName: the part the check is for — on a floor jack only the end on jack stands counts as "Lift:Wheel"
-- (work_view 2b: never work under a car held by the jack alone). player: who does it — on the floor jack
-- "Lift:Under" also needs them lying under that end on the creeper (WorkService zone Under_Front / Under_Rear)
function CarService.check(car: Model, requires: string?, slotName: string?, player: Player?): (boolean, string?, { [string]: any }?)
	if not requires or requires == "" then
		return true
	end
	for req in requires:gmatch("[^,]+") do
		if req == "Hood:Open" then
			if not CarService.hoodOpen(car) then
				return false, "n.needHood"
			end
		elseif req:sub(1, 4) == "Arm:" then
			-- E2: the floor jack under that corner's lower arm, the car on its stands (JackService.arm)
			if car:GetAttribute("ArmJack") ~= req:sub(5) then
				return false, "n.supportArm"
			end
		elseif req:sub(1, 5) == "Lift:" then
			local liftEnd = car:GetAttribute("LiftEnd") :: string?
			-- (the floor jack only ever reaches stand height: under it you lie on the creeper instead of the lift's Under)
			local need = liftY(car, if liftEnd then "Wheel" else req:sub(6))
			local up = ((car:GetAttribute("LiftOffset") :: number?) or 0) >= need - 0.05
			if liftEnd then
				-- on the floor jack: Wheel = that end on stands; Under = that end on stands + you on the creeper under
				-- it (work_view 2c — Features.UnderView; without it there's no way under a jacked car yet)
				local support = (car:GetAttribute("Support") :: string?) or "None"
				local want = CarParts.endOf(slotName)
				if req == "Lift:Under" and not Config.feature("UnderView") then
					return false, "n.needLiftUnder"
				end
				if support:sub(1, 4) == "Jack" then
					return false, "n.standsFirst"
				end
				if not up or support ~= "Stands" .. liftEnd or (want ~= nil and want ~= liftEnd) then
					return false, "n.needJack"
				end
				if req == "Lift:Under" then
					local zone = player and player:GetAttribute("WorkZone") :: string?
					local mine = player ~= nil and player:GetAttribute("WorkCar") == car:GetAttribute("CarId")
					if not mine or CarParts.work(car:GetAttribute("CarType") :: string?).under[zone or ""] ~= liftEnd then
						return false, "n.goUnder"
					end
				end
			elseif not up then
				-- a bay with no lift yet (Lv1~5: the jack kit) says jack, not lift (wr-gamer g02)
				local bay = CarService.bayOf(car)
				if bay and not bay:FindFirstChild("Lift") then
					return false, if req == "Lift:Under" and not Config.feature("UnderView") then "n.needLiftUnder" else "n.needJack"
				end
				return false, if req == "Lift:Under" then "n.needLiftUnder" else "n.needLift"
			end
		elseif CarParts.Slots[req] then
			if CarFactory.slotPart(car, req) then
				return false, "n.blockedBy", { part = "@part." .. CarParts.Slots[req].kind }
			end
		end
	end
	return true
end

-- who worked on a car (everyone who touched it gets paid the same: 기획서 4장)
local helpers: { [Model]: { [Player]: boolean } } = {}
function CarService.touch(car: Model, player: Player)
	helpers[car] = helpers[car] or {}
	helpers[car][player] = true
	player:SetAttribute("LastCar", car:GetAttribute("CarId")) -- (the bay whose cart gets their counter parts)
end
function CarService.helpers(car: Model): { Player }
	local out = {}
	for p in helpers[car] or {} do
		if p.Parent then
			table.insert(out, p)
		end
	end
	return out
end
function CarService.forget(car: Model)
	helpers[car] = nil
end

-- a broken car parked at a ground CFrame (faults rolled, symptoms on); carType nil = a sedan
function CarService.spawn(at: CFrame, plan: { FaultService.Fault }, carType: string?, paint: Color3?): Model
	local car = CarFactory.build(at, carType, paint)
	FaultService.roll(car, plan)
	for _, slotName in CarParts.SlotOrder do
		CarFactory.reseat(car, slotName)
	end
	CarFactory.pose(car)
	hoodPrompt(car)
	return car
end

-- the car came to a stop in its bay: puddles can appear under it
function CarService.park(car: Model, bay: Instance)
	local spot = bay:FindFirstChild("CarSpot") :: BasePart
	car:SetAttribute("BaseCFrame", spot.CFrame)
	car:SetAttribute("Parked", true)
	CarFactory.setDetail(car, "Detail") -- the bay car: every corner in full detail
	bay:SetAttribute("CarId", car:GetAttribute("CarId"))
	CarFactory.pose(car)
	FaultService.refresh(car)
end

return CarService
