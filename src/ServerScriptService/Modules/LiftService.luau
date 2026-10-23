-- Two-post lift in each bay: three heights (car_spec 3-3: Ground 0 / Wheel 2 / Under 6), raise / lower prompts
-- on its control box. Uses wr-builder's lift (world_contract ★ `Bays.BayN.Lift`): the moving part is
-- `Lift.Carriage` (PivotTo CarriageHome + y), the prompts go on `Lift.Control`. A bay without a lift gets a plain
-- stand-in with the same names.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local Places = require(script.Parent.Places)
local Guard = require(script.Parent.Guard)

local LiftService = {}
LiftService.busyBy = nil :: ((car: Model, except: Player?) -> Player?)? -- WorkService: someone in a work zone / carrying

local LEVELS = CarParts.LiftLevels -- the names / count; the heights are the car's own (levelY)

-- how high a level lifts this car (CarParts.Types: the SUV's wheels sit higher, so its Wheel level is lower)
local function levelY(car: Model?, level: number): number
	return CarFactory.geo(car).LiftLevels[level].y
end
-- the arms' height: up to the car's sills (the SUV's are 0.2 higher)
local function armY(car: Model?, y: number): number
	return y + (if car then CarFactory.geo(car).sill - CarParts.Types.Sedan.sill else 0)
end

local function part(name: string, size: Vector3, cf: CFrame, color: Color3, parent: Instance): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.Metal
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

-- the carriage (arms + pads) follows the car's height
local function placeCarriage(bay: Instance, y: number)
	local lift = bay:FindFirstChild("Lift")
	local carriage = lift and lift:FindFirstChild("Carriage") :: Model?
	local home = lift and lift:FindFirstChild("CarriageHome") :: BasePart?
	if carriage and home and carriage:IsA("Model") then
		carriage:PivotTo(home.CFrame + Vector3.yAxis * y)
	end
end

local function label(bay: Instance)
	local lift = bay:FindFirstChild("Lift")
	local box = lift and lift:FindFirstChild("Control")
	if not box then
		return
	end
	local top = (bay:GetAttribute("LiftLevel") or 1) >= LiftService.maxLevel(bay)
	local p = box:FindFirstChild("RaisePrompt")
	if p then
		Locale.tag(p, if top then "act.lowerLift" else "act.raiseLift")
	end
end

-- anyone standing under the car (blocks lowering)
local function someoneUnder(car: Model): boolean
	local cf = car:GetPivot()
	local bottom = cf.Position.Y + 0.5
	for _, plr in Players:GetPlayers() do
		local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			local l = cf:PointToObjectSpace(root.Position)
			if math.abs(l.X) < 4 and math.abs(l.Z) < 8.6 and root.Position.Y < bottom + 1.5 then
				return true
			end
		end
	end
	return false
end

-- how high this bay's lift goes: the map's Lift.MaxLevel ("Wheel" = the old Lv1 lift, "Under" = hydraulic)
function LiftService.maxLevel(bay: Instance): number
	local lift = bay:FindFirstChild("Lift")
	local name = lift and lift:GetAttribute("MaxLevel")
	for i, l in LEVELS do
		if l.name == name then
			return i
		end
	end
	return #LEVELS
end

function LiftService.setLevel(bay: Instance, level: number, player: Player?)
	local top = LiftService.maxLevel(bay)
	if level > top then
		if player then
			Remotes.Notify:FireClient(player, "n.liftMax", nil, "bad")
		end
		return
	end
	level = math.clamp(level, 1, #LEVELS)
	if bay:GetAttribute("LiftMoving") then
		if player then
			Remotes.Notify:FireClient(player, "n.liftBusy", nil, "bad")
		end
		return
	end
	local from = bay:GetAttribute("LiftLevel") or 1
	if level == from then
		return
	end
	local car = CarService.carIn(bay)
	if car and car:GetAttribute("Parked") ~= true then
		return -- a car still driving in / out
	end
	if car and car:GetAttribute("LiftEnd") then
		return -- on the floor jack
	end
	local who = car and LiftService.busyBy and LiftService.busyBy(car, player)
	if who then
		if player then
			Remotes.Notify:FireClient(player, "n.heightLockedWork", { name = who.DisplayName }, "bad")
		end
		return
	end
	if level < from and car and someoneUnder(car) then
		if player then
			Remotes.Notify:FireClient(player, "n.someoneUnder", nil, "bad")
		end
		return
	end
	bay:SetAttribute("LiftMoving", true)
	Remotes.Effect:FireAllClients("liftMotor", { bay = bay, on = true })
	local y0 = levelY(car, from)
	local y1 = levelY(car, level)
	local y = y0
	local dir = if y1 > y0 then 1 else -1
	while y ~= y1 do
		local dt = RunService.Heartbeat:Wait()
		y += dir * Config.LiftSpeed * dt
		if (dir > 0 and y > y1) or (dir < 0 and y < y1) then
			y = y1
		end
		car = CarService.carIn(bay)
		if car then
			car:SetAttribute("LiftOffset", y)
			CarFactory.pose(car)
		end
		placeCarriage(bay, armY(car, y))
	end
	bay:SetAttribute("LiftLevel", level)
	bay:SetAttribute("LiftMoving", false)
	Remotes.Effect:FireAllClients("liftMotor", { bay = bay, on = false })
	label(bay)
end

-- a plain stand-in lift with the contract's names (only when the map has none)
local function buildStandIn(bay: Instance, spot: BasePart)
	local postX = (spot:GetAttribute("PostOffsetX") :: number?) or 6
	local lift = Instance.new("Model")
	lift.Name = "Lift"
	lift:SetAttribute("Temporary", true)
	local blue = Color3.fromRGB(40, 90, 170)
	for _, x in { -postX, postX } do
		part("Post", Vector3.new(0.8, 13, 0.8), spot.CFrame * CFrame.new(x, 6.5, -0.5), blue, lift)
	end
	local home = part("CarriageHome", Vector3.new(1, 0.2, 1), spot.CFrame, blue, lift)
	home.Transparency = 1
	home.CanCollide = false
	local carriage = Instance.new("Model")
	carriage.Name = "Carriage"
	local root = part("CarriageRoot", Vector3.new(0.2, 0.2, 0.2), spot.CFrame, blue, carriage)
	root.Transparency = 1
	root.CanCollide = false
	carriage.PrimaryPart = root
	for _, x in { -3.0, 3.0 } do
		local arm = part("Arm", Vector3.new(0.5, 0.3, 7.5), spot.CFrame * CFrame.new(x, 0.3, 0), Color3.fromRGB(60, 60, 64), carriage)
		arm.CanCollide = false
	end
	carriage.Parent = lift
	part("Control", Vector3.new(0.8, 1.6, 0.6), spot.CFrame * CFrame.new(-(postX + 1), 1.6, 1.2), Color3.fromRGB(230, 190, 40), lift)
	lift.Parent = bay
end

local function setup(bay: Instance)
	local spot = Places.marker(bay, "LiftSpot") or Places.marker(bay, "CarSpot")
	if not spot then
		return
	end
	if not bay:FindFirstChild("Lift") then
		-- a real map without a lift in this bay = the Lv1 floor jack + stands (work_view 2b; JackService), not a gap:
		-- the stand-in is only for the dev garage
		local g = workspace:FindFirstChild("Garage")
		if g and g:GetAttribute("WorldVersion") then
			return
		end
		buildStandIn(bay, spot)
	end
	local box = (bay :: any).Lift:FindFirstChild("Control") :: BasePart?
	if not box then
		return
	end
	-- one prompt (main 10-21: no pile of prompts): "Raise lift" one level at a time, at the top "Lower lift" goes
	-- all the way down
	local old = box:FindFirstChild("LowerPrompt")
	if old then
		old:Destroy()
	end
	if not box:FindFirstChild("RaisePrompt") then
		local p = Instance.new("ProximityPrompt")
		p.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
		p.Name = "RaisePrompt"
		p.KeyboardKeyCode = Enum.KeyCode.R
		p.MaxActivationDistance = Config.PromptDistance
		p.RequiresLineOfSight = false
		Locale.tag(p, "act.raiseLift")
		p.Parent = box
		p.Triggered:Connect(Guard.prompt(p, "Lift", 0.5, function(player)
			local level = bay:GetAttribute("LiftLevel") or 1
			LiftService.setLevel(bay, if level < LiftService.maxLevel(bay) then level + 1 else 1, player)
		end))
	end
	-- a swapped lift (World/Upgrades) starts where the car is
	local level = math.min(bay:GetAttribute("LiftLevel") or 1, LiftService.maxLevel(bay))
	bay:SetAttribute("LiftLevel", level)
	local car = CarService.carIn(bay)
	placeCarriage(bay, armY(car, levelY(car, level)))
	label(bay)
end

function LiftService.start(changed: BindableEvent?)
	for _, bay in Places.liftBays() do
		setup(bay)
	end
	-- the map changed (a lift swapped, a bay built): prompts on every lift again
	if changed then
		changed.Event:Connect(function()
			task.defer(function()
				for _, bay in Places.liftBays() do
					setup(bay)
				end
			end)
		end)
	end
end

return LiftService
