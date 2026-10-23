-- Lifting a car without a lift (docs/design/work_view.md v0.4 2b; wr-carbook under_car_work.md): the Lv1 garage has a
-- floor jack, two jack stands and a creeper. Order, like the manual: chock the wheels that stay down -> jack under
-- the middle of the front (or rear) -> pump -> a stand under each sill -> work. Never work on the jack alone.
--   car attributes: Support = "None" | "JackF" | "JackR" | "StandsF" | "StandsR", LiftEnd = "F" | "R" (CarFactory.pose
--   pitches the car about the other axle), LiftOffset = how high the jacked end's axle is, StandsPlaced = "1" / "12".
--   CarService.check: "Lift:Wheel" for a slot = its end on stands (or a real lift at Wheel).
-- Every step is a server prompt on the car (works on its own) and Remotes.Jack (the work view's taps).
-- Height lock: nobody may change the height while someone is in a work zone of this car or carries one of its parts
-- (WorkService.busyBy). Looks: the bay's own jack set (world_contract ★ 잭 세트: <bay>.JackKit.JackStand1/2,
-- WheelChock1/2, the floor jack = JackKit.FloorJack1 or Bay1's Garage.Tools.FloorJack1) is moved from its storage
-- spot onto the car and back when the car comes down; a bay without a kit gets ReplicatedStorage.WorkGear models,
-- else plain blocks.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local JackLook = require(script.Parent.JackLook)
local Guard = require(script.Parent.Guard)

local JackService = {}

-- set by Main (WorkService): who is busy on this car (a work zone / a carried part), nil = nobody
JackService.busyBy = nil :: ((car: Model, except: Player?) -> Player?)?
JackService.onChanged = nil :: ((car: Model) -> ())? -- WorkService: a zone may have opened / closed

local pumping: { [Model]: boolean } = {}

local function support(car: Model): string
	return (car:GetAttribute("Support") :: string?) or "None"
end

local function liftedByLift(car: Model): boolean
	return car:GetAttribute("LiftEnd") == nil and ((car:GetAttribute("LiftOffset") :: number?) or 0) > 0.05
end

------------------------------------------------------------------------------------------------------- the gear

local function gearFolder(car: Model): Folder
	local root = workspace:FindFirstChild("WorkGear") or Instance.new("Folder")
	root.Name = "WorkGear"
	root.Parent = workspace
	local name = "Car_" .. tostring(car:GetAttribute("CarId"))
	local f = root:FindFirstChild(name) :: Folder?
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = root
	end
	return f :: Folder
end

local function block(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or Enum.Material.Metal
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

-- the bay's own prop for a gear piece (moved onto the car, back home afterwards), or nil
local KIT = { Jack = "FloorJack1", Stand1 = "JackStand1", Stand2 = "JackStand2", Chock1 = "WheelChock1", Chock2 = "WheelChock2" }
local moved: { [Model]: { [string]: PVInstance } } = {}
local function kitProp(car: Model, name: string): PVInstance?
	local bay = CarService.bayOf(car)
	local kit = bay and bay:FindFirstChild("JackKit")
	local want = KIT[name]
	if not kit or not want then
		return nil
	end
	local prop = kit:FindFirstChild(want)
	if not prop and name == "Jack" then
		local g = workspace:FindFirstChild("Garage")
		local tools = g and g:FindFirstChild("Tools")
		prop = tools and tools:FindFirstChild(want)
	end
	return if prop and prop:IsA("PVInstance") then prop else nil
end

-- the 3D jack's handle under a car: pumping while the pump is held, else left low where the stroke ends (a jack
-- holding a car with its handle stood up read as a parked jack — user 10-22); stood up only when stored (JackLook.rest)
local function handleAt(car: Model): number
	if pumping[car] then
		return JackLook.HANDLE_PUMP + 8 * math.sin(os.clock() * math.pi * 2 * 1.6)
	end
	return JackLook.HANDLE_PUMP
end

-- a gear piece: the bay's own prop moved here, else a WorkGear model (pivot = on the floor, facing the car's -Z),
-- else blocks. The 3D floor jack (JackLook) is posed: saddle on the point at the height, arm and handle to match.
local function gear(car: Model, kind: string, name: string, at: CFrame, height: number): Instance
	local prop = kitProp(car, name)
	if prop then
		if prop:GetAttribute("HomeCF") == nil then
			prop:SetAttribute("HomeCF", prop:GetPivot())
		end
		if JackLook.is3D(prop) then
			JackLook.place(prop :: Model, at, height, handleAt(car))
		else
			prop:PivotTo(at)
		end
		moved[car] = moved[car] or {}
		moved[car][name] = prop
		return prop
	end
	local f = gearFolder(car)
	local old = f:FindFirstChild(name)
	if old and JackLook.is3D(old) then
		JackLook.place(old :: Model, at, height, handleAt(car))
		return old
	end
	if old then
		old:Destroy()
	end
	local lib = ReplicatedStorage:FindFirstChild("WorkGear")
	local t = lib and lib:FindFirstChild(kind)
	if kind == "FloorJack" and not t then
		local meshes = ReplicatedStorage:FindFirstChild("CarMeshes")
		local jack = meshes and meshes:FindFirstChild("Gear_FloorJack")
		if jack then
			local m = jack:Clone() :: Model
			m.Name = name
			m:SetAttribute("Jack3D", true)
			JackLook.place(m, at, height, handleAt(car))
			m.Parent = f
			return m
		end
	end
	if t and t:IsA("Model") then
		local m = t:Clone()
		m.Name = name
		m:SetAttribute("Height", height)
		m:PivotTo(at)
		m.Parent = f
		return m
	end
	local m = Instance.new("Model")
	m.Name = name
	if kind == "WheelChock" then
		block(m, "Chock", Vector3.new(0.7, 0.5, 0.9), at * CFrame.new(0, 0.25, 0), Color3.fromRGB(230, 180, 30), Enum.Material.Plastic)
	elseif kind == "FloorJack" then
		block(m, "Body", Vector3.new(1.2, 0.45, 3.2), at * CFrame.new(0, 0.25, 1.2), Color3.fromRGB(196, 40, 36))
		block(m, "Handle", Vector3.new(0.2, 0.2, 3.4), at * CFrame.new(0, 1.0, 3.9) * CFrame.Angles(math.rad(-25), 0, 0), Color3.fromRGB(60, 60, 64))
		block(m, "Arm", Vector3.new(0.5, math.max(0.2, height - 0.3), 0.5), at * CFrame.new(0, (height - 0.3) / 2 + 0.25, 0), Color3.fromRGB(150, 30, 28))
		block(m, "Saddle", Vector3.new(0.9, 0.15, 0.9), at * CFrame.new(0, height - 0.05, 0), Color3.fromRGB(40, 40, 44))
	elseif kind == "JackStand" then
		block(m, "Base", Vector3.new(1.3, 0.2, 1.3), at * CFrame.new(0, 0.1, 0), Color3.fromRGB(230, 120, 30))
		block(m, "Post", Vector3.new(0.35, math.max(0.2, height - 0.3), 0.35), at * CFrame.new(0, (height - 0.3) / 2 + 0.2, 0), Color3.fromRGB(200, 200, 205))
		block(m, "Saddle", Vector3.new(0.7, 0.12, 0.5), at * CFrame.new(0, height - 0.06, 0), Color3.fromRGB(230, 120, 30))
	end
	m.Parent = f
	return m
end

local function clearGear(car: Model, prefix: string?)
	-- the bay's own props go back to their storage spots
	for name, prop in moved[car] or {} do
		if not prefix or name:sub(1, #prefix) == prefix then
			local home = prop:GetAttribute("HomeCF")
			if typeof(home) == "CFrame" and prop.Parent then
				if JackLook.is3D(prop) then
					JackLook.rest(prop :: Model, home) -- (arm down, handle up)
				else
					prop:PivotTo(home)
				end
			end
			moved[car][name] = nil
		end
	end
	local f = gearFolder(car)
	for _, c in f:GetChildren() do
		if not prefix or c.Name:sub(1, #prefix) == prefix then
			c:Destroy()
		end
	end
	if not prefix then
		f:Destroy()
	end
end

-- the floor under the car (the parked spot) and the underside's height at a car-local point once lifted
local function floorAt(car: Model, p: Vector3): CFrame
	local base = (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
	return base * CFrame.new(p.X, 0, p.Z)
end

local function undersideAt(car: Model, p: Vector3): number
	local geo = CarParts.type(car:GetAttribute("CarType") :: string?)
	local w = CarParts.work(geo.name)
	local liftEnd = car:GetAttribute("LiftEnd") :: string?
	local h = (car:GetAttribute("LiftOffset") :: number?) or 0
	local rise = 0
	if liftEnd then
		local about = if liftEnd == "F" then w.axle.R else w.axle.F
		rise = h * math.abs(p.Z - about) / (w.axle.R - w.axle.F)
	end
	return geo.sill + rise
end

local function placeJack(car: Model)
	local e = car:GetAttribute("LiftEnd") :: string?
	if not e or support(car):sub(1, 4) ~= "Jack" then
		return
	end
	local w = CarParts.work(car:GetAttribute("CarType") :: string?)
	local p = (w.jack :: any)[e] :: Vector3
	-- (the handle sticks out from under the bumper; the 3D jack's pump is taller than the bumper's lower edge, so it
	-- waits a little way out while the car is down and rolls in under the point as the end rises)
	local turn = if e == "F" then CFrame.Angles(0, math.pi, 0) else CFrame.identity
	local out = 0.7 * math.max(0, 1 - ((car:GetAttribute("LiftOffset") :: number?) or 0) / 0.5)
	gear(car, "FloorJack", "Jack", floorAt(car, p) * turn * CFrame.new(0, 0, out), undersideAt(car, p))
end

local function placeStands(car: Model)
	local e = car:GetAttribute("LiftEnd") :: string?
	if not e then
		return
	end
	local w = CarParts.work(car:GetAttribute("CarType") :: string?)
	local placed = (car:GetAttribute("StandsPlaced") :: string?) or ""
	for i, p in (w.stands :: any)[e] :: { Vector3 } do
		if placed:find(tostring(i), 1, true) then
			gear(car, "JackStand", "Stand" .. i, floorAt(car, p), undersideAt(car, p) - 0.02)
		end
	end
end

------------------------------------------------------------------------------------------------------- actions

local function say(player: Player?, key: string, args: { [string]: any }?)
	if player then
		Remotes.Notify:FireClient(player, key, args, "bad")
	end
end

-- someone else in a work zone / carrying a part of this car: no height change (the reason, with their name)
local function locked(car: Model, player: Player?): boolean
	local who = JackService.busyBy and JackService.busyBy(car, player)
	if who then
		say(player, "n.heightLockedWork", { name = who.DisplayName })
		return true
	end
	return false
end

local placeArmJackLater: ((Model) -> ())? = nil -- (defined with the arm jack below)

local function changed(car: Model)
	CarFactory.pose(car)
	placeJack(car)
	placeStands(car)
	if placeArmJackLater then
		placeArmJackLater(car)
	end
	if JackService.onChanged then
		JackService.onChanged(car)
	end
end

-- 1. chocks on the other end's wheels, the jack rolls under the middle of this end
function JackService.jack(car: Model, e: string, player: Player?): boolean
	if (e ~= "F" and e ~= "R") or car:GetAttribute("Parked") ~= true or not CarService.bayOf(car) then
		return false
	end
	if support(car) ~= "None" or liftedByLift(car) or locked(car, player) then
		return false
	end
	car:SetAttribute("Support", "Jack" .. e)
	car:SetAttribute("LiftEnd", e)
	car:SetAttribute("LiftOffset", 0)
	car:SetAttribute("StandsPlaced", nil)
	local w = CarParts.work(car:GetAttribute("CarType") :: string?)
	for i, p in (w.chocks :: any)[e] :: { Vector3 } do
		gear(car, "WheelChock", "Chock" .. i, floorAt(car, p) * (if e == "F" then CFrame.identity else CFrame.Angles(0, math.pi, 0)), 0.5)
	end
	if player then
		CarService.touch(car, player)
	end
	changed(car)
	return true
end

-- 2. pump: the jacked end rises while the pump is held (to StandHeight)
function JackService.pump(car: Model, on: boolean, player: Player?)
	if not on then
		pumping[car] = nil
		return
	end
	if support(car):sub(1, 4) ~= "Jack" or pumping[car] or locked(car, player) then
		return
	end
	pumping[car] = true
	task.spawn(function()
		local top = Config.StandHeight
		while pumping[car] and car.Parent and support(car):sub(1, 4) == "Jack" do
			local h = (car:GetAttribute("LiftOffset") :: number?) or 0
			if h >= top then
				break
			end
			local dt = RunService.Heartbeat:Wait()
			car:SetAttribute("LiftOffset", math.min(top, h + top / Config.JackPumpTime * dt))
			changed(car)
		end
		pumping[car] = nil
		if car.Parent then
			placeJack(car) -- (the handle settles low, out from under the bumper)
		end
	end)
end

-- 3. a stand under one sill (i = 1 left / 2 right); both down = the car rests on the stands, the jack rolls away
function JackService.stand(car: Model, i: number, player: Player?): boolean
	local s = support(car)
	if s:sub(1, 4) ~= "Jack" or (i ~= 1 and i ~= 2) then
		return false
	end
	if ((car:GetAttribute("LiftOffset") :: number?) or 0) < Config.StandHeight - 0.05 then
		say(player, "n.pumpFirst")
		return false
	end
	local placed = (car:GetAttribute("StandsPlaced") :: string?) or ""
	if placed:find(tostring(i), 1, true) then
		return false
	end
	placed ..= tostring(i)
	car:SetAttribute("StandsPlaced", placed)
	local w = CarParts.work(car:GetAttribute("CarType") :: string?)
	local sp = ((w.stands :: any)[car:GetAttribute("LiftEnd")] or {})[i] :: Vector3?
	if sp then
		Remotes.Effect:FireAllClients("sfx", { sound = "liftLock", pos = floorAt(car, sp).Position }) -- (the stand's ratchet clicks in)
	end
	if #placed >= 2 then
		local e = car:GetAttribute("LiftEnd") :: string
		car:SetAttribute("Support", "Stands" .. e)
		car:SetAttribute("LiftOffset", Config.StandHeight - 0.04) -- (it settles onto the stands)
		clearGear(car, "Jack")
		Remotes.Effect:FireAllClients("standsDown", { car = car })
	end
	changed(car)
	return true
end

-- both wheels on at the lifted end (a car never comes down on a bare hub; the work view's button hides then too)
local function wheelsOn(car: Model): boolean
	local e = car:GetAttribute("LiftEnd") :: string?
	if not e then
		return true
	end
	return CarFactory.slotPart(car, "Wheel_" .. e .. "L") ~= nil and CarFactory.slotPart(car, "Wheel_" .. e .. "R") ~= nil
end

-- a part at the lifted end with some bolts out and some in (mid-job): it doesn't come down then (a stray V press
-- while working the front bumper's lower bolts lowered the car — test 2 TOP1)
local function halfBolted(car: Model): boolean
	local e = car:GetAttribute("LiftEnd") :: string?
	for slotName in CarParts.Slots do
		local part = (e and CarParts.endOf(slotName) == e) and CarFactory.slotPart(car, slotName) or nil
		local left, count = part and part:GetAttribute("BoltsRemaining"), part and part:GetAttribute("BoltCount")
		-- (a wheel with no nut on yet too: the car came down on a loose wheel — wr-dev Guide play test)
		local wheel = part and part:GetAttribute("PartKind") == "Wheel"
		if type(left) == "number" and type(count) == "number" and (left > 0 or wheel) and left < count then
			return true
		end
	end
	return false
end

-- lower the car: the jack takes it, the stands come out, down it goes (everything back in the corner)
function JackService.lower(car: Model, player: Player?): boolean
	if support(car) == "None" or locked(car, player) then
		return false
	end
	if not wheelsOn(car) then
		say(player, "n.wheelsOnFirst")
		return false
	end
	if halfBolted(car) then
		say(player, "n.boltsFirst")
		return false
	end
	if car:GetAttribute("ArmJack") then
		say(player, "n.armJackFirst") -- (the jack is under an arm: out from there first)
		return false
	end
	pumping[car] = nil
	car:SetAttribute("Support", "Lowering")
	task.spawn(function()
		local h0 = (car:GetAttribute("LiftOffset") :: number?) or 0
		local t0 = os.clock()
		while car.Parent and os.clock() - t0 < Config.LowerCarTime do
			car:SetAttribute("LiftOffset", h0 * (1 - (os.clock() - t0) / Config.LowerCarTime))
			CarFactory.pose(car)
			RunService.Heartbeat:Wait()
		end
		if not car.Parent then
			return
		end
		car:SetAttribute("LiftOffset", 0)
		car:SetAttribute("LiftEnd", nil)
		car:SetAttribute("StandsPlaced", nil)
		car:SetAttribute("Support", "None")
		clearGear(car)
		changed(car)
	end)
	return true
end

-- piece E2 (full_teardown §0-2 Support:Arm, carbook e2_suspension_answers): with the car on its stands the floor jack
-- rolls under one corner's lower arm (a wood block on its saddle) — the knuckle / arm that comes loose hangs on it.
-- The car attribute ArmJack = that corner, the part rows' "Arm:XX" condition (CarService.check).
local function armSpot(car: Model, corner: string): Vector3
	local geo = CarParts.type(car:GetAttribute("CarType") :: string?)
	local c = geo.WheelCenters[corner] :: Vector3
	-- (inboard, under the lower arm: the front one by the ball joint, the rear No.2 arm under its spring seat —
	-- suspension_v1 PROGRESS bushings)
	return c + Vector3.new(if c.X < 0 then 1.05 else -1.05, -0.75, if corner:sub(1, 1) == "R" then 0.48 else 0)
end

-- this car type has parts that need the jack under that corner's arm (E2 rows live)
local function armUsed(car: Model, corner: string): boolean
	for _, slot in CarParts.type(car:GetAttribute("CarType") :: string?).Slots do
		if slot.requires and table.find(slot.requires, "Arm:" .. corner) then
			return true
		end
	end
	return false
end

-- something at this corner is off / hinged down: the arm is hanging on the jack, it can't come out
local function armHolding(car: Model, corner: string): boolean
	for slotName, slot in CarParts.type(car:GetAttribute("CarType") :: string?).Slots do
		if slot.requires and table.find(slot.requires, "Arm:" .. corner) and not CarFactory.slotPart(car, slotName) then
			return true
		end
	end
	return false
end

local function placeArmJack(car: Model)
	local corner = car:GetAttribute("ArmJack") :: string?
	if not corner then
		return
	end
	local p = armSpot(car, corner)
	local turn = if corner:sub(1, 1) == "F" then CFrame.Angles(0, math.pi, 0) else CFrame.identity
	gear(car, "FloorJack", "Jack", floorAt(car, p) * turn, math.max(0.3, undersideAt(car, p) + (p.Y - CarParts.type(car:GetAttribute("CarType") :: string?).sill)))
end

placeArmJackLater = placeArmJack

-- under that corner's arm (from the stands), or back out of there
function JackService.arm(car: Model, corner: string, player: Player?): boolean
	if not armUsed(car, corner) or locked(car, player) then
		return false
	end
	local now = car:GetAttribute("ArmJack") :: string?
	if now == corner then
		if armHolding(car, corner) then
			say(player, "n.armHolds") -- (put back what hangs on it first)
			return false
		end
		car:SetAttribute("ArmJack", nil)
		clearGear(car, "Jack")
		changed(car)
		return true
	end
	if now and armHolding(car, now) then
		say(player, "n.armHolds")
		return false
	end
	if support(car) ~= "Stands" .. corner:sub(1, 1) then
		say(player, "n.standsFirst")
		return false
	end
	car:SetAttribute("ArmJack", corner)
	clearGear(car, "Jack")
	placeArmJack(car)
	Remotes.Effect:FireAllClients("sfx", { sound = "liftLock", pos = floorAt(car, armSpot(car, corner)).Position })
	changed(car)
	return true
end

-- the first time (Tyler): one tap shows the whole order — chocks, jack, pump, both stands (work_view 2b)
function JackService.demo(car: Model, e: string, player: Player?): boolean
	if not JackService.jack(car, e, player) then
		return false
	end
	task.spawn(function()
		local step = Config.JackDemoTime / 4
		task.wait(step)
		JackService.pump(car, true, nil)
		local t0 = os.clock()
		while pumping[car] and os.clock() - t0 < Config.JackPumpTime + 0.5 do
			task.wait(0.05)
		end
		task.wait(step * 0.5)
		JackService.stand(car, 1, nil)
		task.wait(step * 0.5)
		JackService.stand(car, 2, nil)
	end)
	return true
end

------------------------------------------------------------------------------------------------------- prompts

local function prompt(parent: Instance, name: string, key: Enum.KeyCode, hold: number?): ProximityPrompt
	local p = parent:FindFirstChild(name) :: ProximityPrompt?
	if p then
		return p
	end
	local np = Instance.new("ProximityPrompt")
	np.Name = name
	np.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	np.KeyboardKeyCode = key
	np.MaxActivationDistance = Config.PromptDistance
	np.RequiresLineOfSight = false
	np.HoldDuration = hold or 0
	np.Enabled = false
	np.Parent = parent
	return np
end

local function spot(car: Model, name: string, p: Vector3, y: number): Attachment
	local chassis = car.PrimaryPart :: BasePart
	local a = chassis:FindFirstChild(name) :: Attachment?
	if not a then
		a = Instance.new("Attachment")
		a.Name = name
		a.Parent = chassis
	end
	local base = car:GetAttribute("BaseCFrame") :: CFrame
	;(a :: Attachment).Position = chassis.CFrame:PointToObjectSpace((base * CFrame.new(p.X, y, p.Z)).Position)
	return a :: Attachment
end

-- which prompts show now
local function refresh(car: Model)
	local chassis = car.PrimaryPart
	if not chassis or not car:GetAttribute("BaseCFrame") then
		return
	end
	local w = CarParts.work(car:GetAttribute("CarType") :: string?)
	local s = support(car)
	local e = car:GetAttribute("LiftEnd") :: string?
	local inBay = car:GetAttribute("Parked") == true and CarService.bayOf(car) ~= nil
	local tutorial2 = car:GetAttribute("Tutorial") == 2
	for _, end_ in { "F", "R" } do
		local a = spot(car, "Jack_" .. end_, (w.jack :: any)[end_], 0.9)
		local jp = prompt(a, "JackPrompt", Enum.KeyCode.E)
		Locale.tag(jp, if end_ == "F" then "act.jackFront" else "act.jackRear")
		jp.Enabled = inBay and s == "None" and not liftedByLift(car) and not (tutorial2 and end_ == "R")
		local pp = prompt(a, "PumpPrompt", Enum.KeyCode.E, Config.JackPumpTime)
		Locale.tag(pp, "act.pump")
		pp.Enabled = s == "Jack" .. end_ and ((car:GetAttribute("LiftOffset") :: number?) or 0) < Config.StandHeight - 0.05
		local lp = prompt(a, "LowerPrompt", Enum.KeyCode.V)
		Locale.tag(lp, "act.lowerCar")
		lp.UIOffset = Vector2.new(0, 72)
		lp.Enabled = e == end_ and s:sub(1, 6) == "Stands" -- (on the jack alone: Pump is the one thing to do there)
		for i, p in (w.stands :: any)[end_] :: { Vector3 } do
			local sa = spot(car, "Stand_" .. end_ .. i, p, 0.6)
			local sp = prompt(sa, "StandPrompt", Enum.KeyCode.E)
			Locale.tag(sp, "act.placeStand")
			local placed = ((car:GetAttribute("StandsPlaced") :: string?) or ""):find(tostring(i), 1, true) ~= nil
			sp.Enabled = s == "Jack" .. end_ and not placed and ((car:GetAttribute("LiftOffset") :: number?) or 0) >= Config.StandHeight - 0.05
		end
	end
	-- E2: the jack under a corner's arm (only on a type whose suspension parts come apart)
	for corner in CarParts.type(car:GetAttribute("CarType") :: string?).WheelCenters do
		if armUsed(car, corner) then
			local p = armSpot(car, corner)
			local a = spot(car, "Arm_" .. corner, p, p.Y)
			local ap = prompt(a, "ArmPrompt", Enum.KeyCode.E)
			local here = car:GetAttribute("ArmJack") == corner
			Locale.tag(ap, if here then "act.armJackOut" else "act.armJack")
			ap.Enabled = s == "Stands" .. corner:sub(1, 1) and (here or car:GetAttribute("ArmJack") == nil)
		end
	end
end
JackService.refresh = refresh

local wired: { [Model]: boolean } = {}
function JackService.setup(car: Model)
	if wired[car] or not car.PrimaryPart then
		return
	end
	wired[car] = true
	refresh(car)
	for _, end_ in { "F", "R" } do
		local a = car.PrimaryPart:FindFirstChild("Jack_" .. end_) :: Attachment
		local jp = a:FindFirstChild("JackPrompt") :: ProximityPrompt
		jp.Triggered:Connect(Guard.prompt(jp, "JackPlace", 0.3, function(player)
			if car:GetAttribute("Tutorial") == 2 and car:GetAttribute("JackDemoDone") ~= true then
				car:SetAttribute("JackDemoDone", true)
				JackService.demo(car, end_, player) -- (the first time: one tap shows the whole order)
			else
				JackService.jack(car, end_, player)
			end
		end))
		local pp = a:FindFirstChild("PumpPrompt") :: ProximityPrompt
		pp.PromptButtonHoldBegan:Connect(function(player)
			JackService.pump(car, true, player)
		end)
		pp.PromptButtonHoldEnded:Connect(function()
			JackService.pump(car, false)
		end)
		pp.Triggered:Connect(Guard.prompt(pp, "Pump", 0.3, function(player)
			JackService.pump(car, true, player) -- (held to the end: up it goes the rest of the way)
		end))
		local lp = a:FindFirstChild("LowerPrompt") :: ProximityPrompt
		lp.Triggered:Connect(Guard.prompt(lp, "JackLower", 0.3, function(player)
			JackService.lower(car, player)
		end))
		for i = 1, 2 do
			local sa = car.PrimaryPart:FindFirstChild("Stand_" .. end_ .. i) :: Attachment
			local sp = sa:FindFirstChild("StandPrompt") :: ProximityPrompt
			sp.Triggered:Connect(Guard.prompt(sp, "Stand", 0.3, function(player)
				JackService.stand(car, i, player)
			end))
		end
	end
	for corner in CarParts.type(car:GetAttribute("CarType") :: string?).WheelCenters do
		local a = car.PrimaryPart:FindFirstChild("Arm_" .. corner)
		local ap = a and a:FindFirstChild("ArmPrompt") :: ProximityPrompt?
		if ap then
			ap.Triggered:Connect(Guard.prompt(ap, "ArmJack", 0.3, function(player)
				JackService.arm(car, corner, player)
			end))
		end
	end
	for _, attr in { "Support", "LiftOffset", "Parked", "LiftEnd", "StandsPlaced", "ArmJack" } do
		car:GetAttributeChangedSignal(attr):Connect(function()
			refresh(car)
		end)
	end
	car.AncestryChanged:Connect(function()
		if not car.Parent then
			wired[car] = nil
			pumping[car] = nil
			for _, prop in moved[car] or {} do
				local home = prop:GetAttribute("HomeCF")
				if typeof(home) == "CFrame" and prop.Parent then
					if JackLook.is3D(prop) then
						JackLook.rest(prop :: Model, home)
					else
						prop:PivotTo(home)
					end
				end
			end
			moved[car] = nil
			local root = workspace:FindFirstChild("WorkGear")
			local f = root and root:FindFirstChild("Car_" .. tostring(car:GetAttribute("CarId")))
			if f then
				f:Destroy()
			end
		end
	end)
end

function JackService.start()
	Remotes.Jack.OnServerEvent:Connect(function(player: Player, car: any, action: any, arg: any)
		if typeof(car) ~= "Instance" or not car:IsA("Model") or car.Parent ~= workspace:FindFirstChild("Cars") then
			return
		end
		-- (paced per action: letting go of the pump is never dropped)
		if not Guard.player(player) or not (action == "pump" and arg ~= true or Guard.rate(player, "Jack:" .. tostring(action), 0.2)) then
			return
		end
		if not Guard.free(player, "Jack") then
			return
		end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root or (root.Position - car:GetPivot().Position).Magnitude > 25 then
			return
		end
		if (action == "jack" or action == "demo") and arg ~= "F" and arg ~= "R" then
			return -- (an end is "F" or "R": anything else from a client is made up — luau-lsp check 10-22)
		end
		if action == "jack" then
			JackService.jack(car, arg, player)
		elseif action == "demo" then
			-- (only the tutorial's jack lesson, once — exploit audit L1: not a skip on any car)
			if car:GetAttribute("Tutorial") == 2 and car:GetAttribute("JackDemoDone") ~= true then
				car:SetAttribute("JackDemoDone", true)
				JackService.demo(car, arg, player)
			end
		elseif action == "pump" then
			JackService.pump(car, arg == true, player)
		elseif action == "stand" and type(arg) == "number" then
			JackService.stand(car, arg, player)
		elseif action == "lower" then
			JackService.lower(car, player)
		elseif action == "arm" and type(arg) == "string" and CarParts.type(car:GetAttribute("CarType") :: string?).WheelCenters[arg] then
			JackService.arm(car, arg, player) -- (the wheel view's button too — wr-ui)
		end
	end)
	-- every customer car in a bay gets the jack prompts
	local function watch(car: Instance)
		if car:IsA("Model") then
			task.defer(function()
				if car.PrimaryPart then
					JackService.setup(car :: Model)
				end
			end)
		end
	end
	task.spawn(function()
		local cars = workspace:FindFirstChild("Cars")
		while not cars do
			task.wait(0.5)
			cars = workspace:FindFirstChild("Cars")
		end
		cars.ChildAdded:Connect(watch)
		for _, c in cars:GetChildren() do
			watch(c)
		end
	end)
end

return JackService
