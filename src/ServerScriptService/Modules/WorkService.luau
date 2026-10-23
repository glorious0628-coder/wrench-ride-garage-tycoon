-- The work view's server half (docs/design/work_view.md v0.4): work zones, the bay's parts cart, the scan.
--   Zones (MVP): EngineBay (hood open) and Wheel_FL/FR/RL/RR (that end up on jack stands, or a lift at Wheel).
--   One player per zone per car; inside, the character stands at the zone's WorkStand (CarParts.work), anchored,
--   and the client's WorkView moves the camera. Player attributes WorkCar (CarId) / WorkZone say where.
--   The rules don't change: bolts, pick up, install and the magnet are the same server calls (BoltService /
--   CarryService) — reach is simply measured from the work stand. New: taking parts from the bay's cart from the
--   stand (WorkPickReach), setting parts down on the cart, and the counter's parts delivered to the cart.
--   Scan: Remotes.Scan (no Scanner in hand needed) -> the zones of the car's faults ("Check here", not which part);
--   final = the zones again with a check where everything is fixed (work_view 2d).
--   The creeper (work_view 2c, Features.UnderView): zones Under_Front / Under_Rear, open while that end sits on its
--   jack stands — you lie on the bay's creeper and roll in under the car (CreeperSlide), and stand up by the sill again.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local CarryService = require(script.Parent.CarryService)
local FaultService = require(script.Parent.FaultService)
local DiagnosisService = require(script.Parent.DiagnosisService)
local Guard = require(script.Parent.Guard)

local WorkService = {}

-- zone users: car -> zone -> player
local users: { [Model]: { [string]: Player } } = {}
-- (creeper zones also keep the bay's creeper and the stand-up spot from the moment you went in: the car may be gone
-- by the time you leave — API review 10-22 notes/api/wr-dev/under_review_a.md ②)
local where: { [Player]: { car: Model, zone: string, creeper: Model?, out: CFrame? } } = {}

local function carById(id: any): Model?
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:GetAttribute("CarId") == id then
			return c :: Model
		end
	end
	return nil
end

local function rootOf(player: Player): BasePart?
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
end

-- someone (not `except`) in a work zone of this car, or carrying one of its parts: the car's height must not change
function WorkService.busyBy(car: Model, except: Player?): Player?
	for _, p in users[car] or {} do
		if p ~= except and p.Parent then
			return p
		end
	end
	local id = car:GetAttribute("CarId")
	for _, p in Players:GetPlayers() do
		local held = CarryService.carried(p)
		if p ~= except and held and held:GetAttribute("FromCar") == id then
			return p
		end
	end
	return nil
end

------------------------------------------------------------------------------------------------------- the cart

-- the bay's parts cart: the map's PartsCart marker in the bay when there is one, else the floor by the front left
function WorkService.cartSpot(car: Model): CFrame?
	local bay = CarService.bayOf(car)
	local cart = bay and bay:FindFirstChild("PartsCart", true)
	if cart and cart:IsA("BasePart") then
		return cart.CFrame + Vector3.new(0, cart.Size.Y / 2 + 0.6, 0)
	end
	local spot = bay and bay:FindFirstChild("CarSpot") :: BasePart?
	return spot and spot.CFrame * CFrame.new(-8.6, 0.6, -6.6)
end

-- an old part (worn out — the tutorial's "new" is Condition 50+)
local function isOld(p: Instance): boolean
	return ((p:GetAttribute("Condition") :: number?) or 100) < 50
end

-- the next free place on the cart: new parts on the top tray from one end, old ones apart so a tap on the new one
-- never gets the old (test 2 TOP6: the old battery sat right in front of the new) — a small old part on the tray
-- below (1.2 down), a big one at the other end of the top tray
local function cartPlace(car: Model, part: Instance?): CFrame?
	local at = WorkService.cartSpot(car)
	if not at then
		return nil
	end
	local id = car:GetAttribute("CarId")
	local old = part ~= nil and isOld(part)
	local tall = if part and part:IsA("Model") then part:GetExtentsSize().Y elseif part and part:IsA("BasePart") then part.Size.Y else 0
	local low = old and tall <= 0.95
	local n = 0
	for _, p in CarFactory.looseFolder():GetChildren() do
		if p:GetAttribute("OnCart") == id and p:GetAttribute("State") == "Free" and isOld(p) == old and (p:GetAttribute("CartLow") == true) == low then
			n += 1
		end
	end
	if part then
		part:SetAttribute("CartLow", if low then true else nil)
	end
	if low then
		return at * CFrame.new(((n % 3) - 1) * 1.6, -1.2, 0)
	end
	local cols = if old then { 1.6 } else { -1.6, 0 }
	local col, row = cols[(n % #cols) + 1], math.floor(n / #cols) % 2
	return at * CFrame.new(col, 0, (row - 0.5) * 1.8)
end

-- a bought part goes onto the cart of the car this player works on (CartDeliver later)
function WorkService.deliver(player: Player, spawn: (CFrame) -> Instance?): boolean
	local car = carById(player:GetAttribute("LastCar"))
	if not car or car:GetAttribute("Parked") ~= true or not CarService.bayOf(car) then
		return false
	end
	task.delay(Config.CartDeliver, function()
		local at = car.Parent and cartPlace(car)
		local part = at and player.Parent and spawn(at)
		if part then
			part:SetAttribute("OnCart", car:GetAttribute("CarId"))
			Remotes.Effect:FireAllClients("partDrop", { pos = (at :: CFrame).Position })
		end
	end)
	return true
end

------------------------------------------------------------------------------------------------------- the creeper

-- the bay's creeper (Equipment.jackKit: <bay>.JackKit.Creeper, on its wall hook), or nil (a map without one: you lie
-- on the floor). Its local: board in XZ, head toward -Z, casters toward -Y, origin = the board's centre.
local function creeperOf(car: Model): Model?
	local bay = CarService.bayOf(car)
	local kit = bay and bay:FindFirstChild("JackKit")
	local c = kit and kit:FindFirstChild("Creeper")
	return if c and c:IsA("Model") then c else nil
end

-- the board under a lying root (its centre half a stud toward the head, top just under the back). The root lies 0.99
-- above the floor (CarParts lie); the board centre 0.4 above it: the 3D creeper's wheels 0.4025 below its pivot
-- (World/Equipment), the part one's casters 0.41
local function boardUnder(rootCF: CFrame): CFrame
	local head = rootCF.UpVector
	local at = rootCF.Position + head * 0.5
	local y = rootCF.Position.Y - 0.59
	return CFrame.lookAt(Vector3.new(at.X, y, at.Z), Vector3.new(at.X, y, at.Z) + head)
end

-- lying at `cf`: how far a slimmer torso than the standard R15's (back 0.5 behind the root, on the pad) hovers over
-- the pad (GPT 10-22, seen from a friend's side) — measured as it lies (the idle pose moves the torso), at most 0.12:
-- layered clothing sits outside the torso
local function sinkOf(root: BasePart, cf: CFrame): number
	local torso = root.Parent and root.Parent:FindFirstChild("UpperTorso")
	if not (torso and torso:IsA("BasePart")) then
		return 0
	end
	local low = math.huge
	for _, x in { -0.5, 0.5 } do
		for _, y in { -0.5, 0.5 } do
			for _, z in { -0.5, 0.5 } do
				low = math.min(low, (torso.CFrame * (torso.Size * Vector3.new(x, y, z))).Y)
			end
		end
	end
	return math.clamp(low - (cf.Position.Y - 0.5), 0, 0.12)
end

-- lying on the creeper: from out past the sill, rolled in under the car to `to` (the zone's stand) — a few
-- server steps, the creeper riding along
local sliding: { [Player]: number } = {}
local slideSeq = 0 -- (one counter for everyone: a new slide always stops an old one still running — review ①)
local function slideIn(player: Player, car: Model, root: BasePart, to: CFrame)
	local creeper = creeperOf(car)
	if creeper and creeper:GetAttribute("HomeCF") == nil then
		creeper:SetAttribute("HomeCF", creeper:GetPivot())
	end
	local from = to - to.UpVector * 3.4
	slideSeq += 1
	local token = slideSeq
	sliding[player] = token
	local t0 = os.clock()
	while sliding[player] == token and root.Parent and root.Anchored do
		local k = math.clamp((os.clock() - t0) / Config.CreeperSlide, 0, 1)
		k = k * k * (3 - 2 * k)
		local cf = from:Lerp(to, k)
		root.CFrame = cf
		if creeper then
			creeper:PivotTo(boardUnder(cf))
		end
		if k >= 1 then
			root.CFrame = cf - Vector3.new(0, sinkOf(root, cf), 0)
			break
		end
		RunService.Heartbeat:Wait()
	end
end

local function creeperHome(creeper: Model?)
	local home = creeper and creeper:GetAttribute("HomeCF") :: CFrame?
	if creeper and home then
		creeper:PivotTo(home)
	end
end

------------------------------------------------------------------------------------------------------- zones

-- fresh: a new character (respawn) — never move it, it isn't the one that lay on the creeper (review ③)
local function leave(player: Player, fresh: boolean?)
	local w = where[player]
	where[player] = nil
	sliding[player] = nil
	player:SetAttribute("WorkCar", nil)
	player:SetAttribute("WorkZone", nil)
	if w and users[w.car] and users[w.car][w.zone] == player then
		users[w.car][w.zone] = nil
	end
	local root = rootOf(player)
	if w and w.out then
		-- off the creeper: stand up by the left sill, facing the car; the creeper back on its hook
		creeperHome(w.creeper)
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if root and hum and not fresh then
			root.CFrame = w.out + Vector3.new(0, hum.HipHeight + root.Size.Y / 2, 0)
		end
	end
	if root then
		root.Anchored = false
	end
end
WorkService.leave = leave

-- can this zone be worked on now? (ok, notice key, args)
local function open(car: Model, zone: string): (boolean, string?, { [string]: any }?)
	if zone == "EngineBay" then
		if not CarService.hoodOpen(car) then
			return false, "n.needHoodOpen"
		end
		return true
	end
	local corner = zone:match("^Wheel_(%u%u)$")
	if corner and CarParts.type(car:GetAttribute("CarType") :: string?).WheelCenters[corner] then
		return CarService.check(car, "Lift:Wheel", "Wheel_" .. corner)
	end
	-- the creeper: that end on its jack stands (a hydraulic lift has no creeper zone — you walk under it)
	local e = CarParts.work(car:GetAttribute("CarType") :: string?).under[zone]
	if e and Config.feature("UnderView") then
		if car:GetAttribute("LiftEnd") == nil then
			return false, "n.needJack"
		end
		return CarService.check(car, "Lift:Wheel", "Wheel_" .. e .. "L")
	end
	return false
end

function WorkService.enter(player: Player, car: any, zone: any): (boolean, string?, { [string]: any }?)
	if typeof(car) ~= "Instance" or not car:IsA("Model") or car.Parent ~= workspace:FindFirstChild("Cars") or type(zone) ~= "string" then
		return false
	end
	local root = rootOf(player)
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health <= 0 or car:GetAttribute("Parked") ~= true then
		return false
	end
	if (root.Position - car:GetPivot().Position).Magnitude > 22 then
		return false, "n.tooFar"
	end
	local stand = CarParts.work(car:GetAttribute("CarType") :: string?).stand[zone]
	if not stand then
		return false
	end
	local ok, key, args = open(car, zone)
	if not ok then
		return false, key, args
	end
	users[car] = users[car] or {}
	local other = users[car][zone]
	if other and other ~= player and other.Parent then
		return false, "n.zoneBusy", { name = other.DisplayName }
	end
	if where[player] then
		leave(player)
	end
	users[car][zone] = player
	local geo = CarParts.work(car:GetAttribute("CarType") :: string?)
	local base = (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
	local out = if geo.under[zone] and geo.out[zone] then base * geo.out[zone] else nil
	where[player] = { car = car, zone = zone, creeper = if out then creeperOf(car) else nil, out = out }
	player:SetAttribute("WorkCar", car:GetAttribute("CarId"))
	player:SetAttribute("WorkZone", zone)
	player:SetAttribute("LastCar", car:GetAttribute("CarId"))
	-- stand at the zone, facing the work (the floor under the parked car, not the jacked-up body)
	local at = base * stand
	root.Anchored = true
	if out then
		task.spawn(slideIn, player, car, root, at) -- (the stand IS the lying root: on your back, head under the work)
	else
		root.CFrame = at + Vector3.new(0, hum.HipHeight + root.Size.Y / 2, 0)
	end
	CarService.touch(car, player) -- (looking counts as helping only once a work unit is done: JobService)
	return true
end

-- a zone that can't be worked any more (hood closed, the car let down / leaving): everyone in it steps out
local function recheck(car: Model)
	for zone, p in users[car] or {} do
		if not car.Parent or car:GetAttribute("Parked") ~= true or not open(car, zone) then
			leave(p)
		end
	end
end
WorkService.recheck = recheck

------------------------------------------------------------------------------------------------------- picking

local function onPick(player: Player, part: any)
	local w = where[player]
	-- the caliper (a tap = push its piston back, work_view 3: "the one-time actions are a tap on their spot")
	if w and typeof(part) == "Instance" and part.Parent and part.Parent.Name == "Moving" and part:IsDescendantOf(w.car) then
		local corner = part.Name:match("^BrakeCaliper_(%u%u)$")
		if corner then
			CarryService.pushPiston(player, w.car, corner)
		end
		return
	end
	-- a hinged-down arm (E2 Swing): a tap lifts it back up on the jack (the spring in first)
	if w and typeof(part) == "Instance" and part:GetAttribute("State") == "Swung" and CarService.carOf(part) == w.car then
		CarryService.swingUp(player, w.car, part)
		return
	end
	-- a part nothing holds (BoltCount 0 — the air filter): lifted out of its place once what's over it is off
	if w and typeof(part) == "Instance" and part:GetAttribute("PartKind") and part:GetAttribute("State") == "Installed"
		and part:GetAttribute("BoltCount") == 0 and CarService.carOf(part) == w.car and not CarryService.carried(player) then
		local slot = part:GetAttribute("Slot") :: string?
		local ok, key, args = CarService.check(w.car, part:GetAttribute("Requires") :: string?, slot, player)
		if not ok then
			return Remotes.Notify:FireClient(player, key, args, "bad")
		end
		CarService.touch(w.car, player)
		CarryService.detach(w.car, part)
		CarryService.pickUp(player, part, true)
		return
	end
	if not w or typeof(part) ~= "Instance" or not part:GetAttribute("PartKind") or part:GetAttribute("State") ~= "Free" then
		return
	end
	-- from this car (popped out / rolled off beside it) or from its bay's cart
	local id = w.car:GetAttribute("CarId")
	local mine = part:GetAttribute("FromCar") == id or part:GetAttribute("OnCart") == id or part:IsDescendantOf(w.car)
	local root = rootOf(player)
	if not mine or not root or (CarFactory.root(part).Position - root.Position).Magnitude > Config.WorkPickReach then
		return
	end
	part:SetAttribute("OnCart", nil)
	CarryService.pickUp(player, part, true)
end

local function onPlace(player: Player, target: any, slotName: any)
	local w = where[player]
	if not w then
		return
	end
	if target == "cart" then
		local at = cartPlace(w.car, CarryService.carried(player))
		if at then
			local part = CarryService.putDown(player, at)
			if part then
				part:SetAttribute("OnCart", w.car:GetAttribute("CarId"))
				CarryService.credit(player, part) -- (an old one: its scrap / core money now)
			end
		end
	elseif typeof(target) == "Instance" and type(slotName) == "string" then
		CarryService.install(player, target, slotName)
	end
end

------------------------------------------------------------------------------------------------------- the scan

local lastScan: { [Player]: number } = {}

-- the zones of the car's faults; final = with a check on the zones that are all fixed now
local function scan(player: Player, car: any, final: any): (boolean, string?)
	if typeof(car) ~= "Instance" or not car:IsA("Model") or car.Parent ~= workspace:FindFirstChild("Cars") then
		return false
	end
	local root = rootOf(player)
	if not root or (root.Position - car:GetPivot().Position).Magnitude > 25 then
		return false, "n.tooFar"
	end
	if os.clock() - (lastScan[player] or 0) < Config.ScanTime then
		return false
	end
	lastScan[player] = os.clock()
	Remotes.Effect:FireAllClients("scan", { car = car })
	local zones: { [string]: boolean } = {}
	for _, slot in string.split((car:GetAttribute("Faults") :: string?) or "", ",") do
		local zone = CarParts.zoneOf(slot)
		if zone then
			local fixed = FaultService.slotOK(car, slot)
			zones[zone] = (zones[zone] == nil or zones[zone]) and fixed
		end
	end
	local list = {}
	for zone, fixed in zones do
		table.insert(list, { zone = zone, ok = final == true and fixed })
	end
	car:SetAttribute("Scanned", true)
	if final == true then
		car:SetAttribute("FinalChecked", true) -- (the tutorial's "Final check" step)
	end
	task.delay(Config.ScanTime, function()
		if player.Parent then
			Remotes.ScanZones:FireClient(player, car, list, final == true)
		end
		-- the first car: the scan points at the engine bay — the hood comes up and you're in it (rival_upgrade B1-2:
		-- the walk round to the hood was the slowest bit of the first money; the same step, done for you once)
		if final ~= true and zones.EngineBay ~= nil and car.Parent and car:GetAttribute("Tutorial") == 1 and not car:GetAttribute("HoodOpen") and player.Parent then
			CarService.toggleHood(car, player)
		end
	end)
	return true
end

------------------------------------------------------------------------------------------------------- prompts

-- "Work on engine" (a hood already open) / "Work on wheel" by each wheel, when that zone is open
local function prompts(car: Model)
	local chassis = car.PrimaryPart
	if not chassis then
		return
	end
	local w = CarParts.work(car:GetAttribute("CarType") :: string?)
	local base = (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
	for zone, stand in w.stand do
		local a = chassis:FindFirstChild("Work_" .. zone) :: Attachment?
		if not a then
			a = Instance.new("Attachment")
			a.Name = "Work_" .. zone
			a.Parent = chassis
			local p = Instance.new("ProximityPrompt")
			p.Name = "WorkPrompt"
			p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
			p.KeyboardKeyCode = Enum.KeyCode.F
			p.MaxActivationDistance = Config.PromptDistance
			p.RequiresLineOfSight = false
			Locale.tag(p, if zone == "EngineBay" then "act.workEngine" elseif w.under[zone] then "act.slideUnder" else "act.workWheel")
			p.Parent = a
			p.Triggered:Connect(Guard.prompt(p, "WorkPrompt", 0.3, function(player)
				local ok, key, args = WorkService.enter(player, car, zone)
				if not ok and key then
					Remotes.Notify:FireClient(player, key, args, "bad")
				end
			end))
		end
		local spot = if w.prompt[zone] then base * w.prompt[zone] else (base * stand * CFrame.new(0, 2.5, -1.2)).Position
		;(a :: Attachment).Position = chassis.CFrame:PointToObjectSpace(spot)
		local prompt = (a :: Attachment):FindFirstChild("WorkPrompt") :: ProximityPrompt
		local taken = users[car] and users[car][zone]
		prompt.Enabled = car:GetAttribute("Parked") == true and open(car, zone) and not (taken and taken.Parent)
	end
end
WorkService.prompts = prompts

local wired: { [Model]: boolean } = {}
local function setup(car: Model)
	if wired[car] or not car.PrimaryPart then
		return
	end
	wired[car] = true
	local function update()
		recheck(car)
		prompts(car)
	end
	for _, attr in { "HoodOpen", "Support", "LiftOffset", "LiftEnd", "Parked", "Leaving" } do
		car:GetAttributeChangedSignal(attr):Connect(update)
	end
	car.AncestryChanged:Connect(function()
		if not car.Parent then
			for _, p in users[car] or {} do
				leave(p)
			end
			users[car] = nil
			wired[car] = nil
		end
	end)
	update()
end

-- a nail in the tread, found from that wheel's work zone (the third tutorial car: "A nail! That's it.")
local function onSpotted(player: Player, car: any, what: any)
	local w = where[player]
	if not w or w.car ~= car or what ~= "nail" then
		return
	end
	local corner = w.zone:match("^Wheel_(%u%u)$")
	local wheel = corner and CarFactory.slotPart(car, "Wheel_" .. corner)
	if wheel and wheel:FindFirstChild("Nail") and not car:GetAttribute("NailFound") then
		car:SetAttribute("NailFound", true)
		DiagnosisService.addClue(car, "clue.nail", { slot = "Wheel_" .. corner }) -- (a find: the job card's step 2)
		Remotes.Notify:FireClient(player, "clue.nail", nil, "good")
	end
end

function WorkService.start()
	Remotes.Spotted.OnServerEvent:Connect(Guard.wrap("Spotted", 0.5, onSpotted))
	Remotes.WorkEnter.OnServerInvoke = Guard.wrap("WorkEnter", 0.3, WorkService.enter)
	Remotes.WorkExit.OnServerEvent:Connect(Guard.wrap("WorkExit", 0.2, function(p: Player)
		leave(p) -- (nothing the client sends reaches leave's own arguments)
	end))
	Remotes.WorkPick.OnServerEvent:Connect(Guard.wrap("WorkPick", 0.2, onPick))
	Remotes.WorkPlace.OnServerEvent:Connect(Guard.wrap("WorkPlace", 0.2, onPlace))
	Remotes.Scan.OnServerInvoke = Guard.wrap("Scan", 0, scan) -- (ScanTime paces it)
	Players.PlayerRemoving:Connect(function(p)
		leave(p)
		lastScan[p] = nil
	end)
	local function onChar(p: Player, char: Model)
		local hum = char:WaitForChild("Humanoid", 10) :: Humanoid?
		if hum then
			hum.Died:Connect(function()
				leave(p)
			end)
		end
	end
	for _, p in Players:GetPlayers() do
		p.CharacterAdded:Connect(function(c)
			leave(p, true)
			onChar(p, c)
		end)
	end
	Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function(c)
			leave(p, true)
			onChar(p, c)
		end)
	end)
	task.spawn(function()
		local cars = workspace:FindFirstChild("Cars")
		while not cars do
			task.wait(0.5)
			cars = workspace:FindFirstChild("Cars")
		end
		local function watch(c: Instance)
			if c:IsA("Model") then
				task.defer(setup, c :: Model)
			end
		end
		cars.ChildAdded:Connect(watch)
		for _, c in cars:GetChildren() do
			watch(c)
		end
	end)
end

return WorkService
