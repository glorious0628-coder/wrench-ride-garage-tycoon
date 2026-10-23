-- Wrench & Ride Garage Tycoon: server entry point.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Shared.Remotes) -- makes the remotes before any client waits for them
local Modules = script.Parent:WaitForChild("Modules")

-- the part data (Shared/PartData): a mistake there could leave a car that can't come apart — say it loudly
for _, problem in require(ReplicatedStorage.Shared.PartGraph).check() do
	warn("[PartGraph] " .. problem)
end

-- the two sound groups: every effect plays in SFX, the background music in Music (each client sets its own group
-- volumes from Settings — wr-ui; the music player fades and dips its songs, never the group)
for _, name in { "Music", "SFX" } do
	local SoundService = game:GetService("SoundService")
	if not SoundService:FindFirstChild(name) then
		local g = Instance.new("SoundGroup")
		g.Name = name
		g.Volume = 1
		g.Parent = SoundService
	end
end

-- the map: wr-builder's World/WorldBoot builds workspace.Garage at start (parented once, when the whole town is
-- done); wait for it, else a stand-in garage. (10 s was too short on a busy PC: the stand-in went up first and the
-- real map came in beside it — two workspace.Garage, bays / jack kit looked up in the wrong one, 10-22)
if script.Parent:FindFirstChild("World") then
	local t0 = os.clock()
	while not (workspace:FindFirstChild("Garage") and workspace.Garage:GetAttribute("WorldVersion")) and os.clock() - t0 < 90 do
		task.wait(0.1)
	end
	if not workspace:FindFirstChild("Garage") then
		warn("[Main] World/ built no map in 90 s: using the stand-in garage")
	end
end
if not workspace:FindFirstChild("Garage") then
	require(script.Parent.Dev.TempGarage).build()
end

local S = {}
S.Remotes = require(ReplicatedStorage.Shared.Remotes)
-- one prompt on screen at a time (the nearest, any key): main 10-21 "too busy" — set on every prompt in the world
local function oneAtATime(d: Instance)
	if d:IsA("ProximityPrompt") then
		d.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	end
end
workspace.DescendantAdded:Connect(oneAtATime)
for _, d in workspace:GetDescendants() do
	oneAtATime(d)
end
S.Metrics = require(Modules.Metrics)
S.Metrics.start() -- first-session times for the people tests (before anyone's save loads)
S.Passes = require(Modules.Passes)
S.Passes.start() -- game pass ownership (Passes.owns)
-- the Robux items (StoreService: ProcessReceipt, Pay Boost, VIP walk, Starter Pack) — each waits for Config.StoreOn
S.Store = require(Modules.StoreService)
S.Store.start()
require(Modules.CarryService).walkBase = S.Store.walk
-- the map's block stand-in cars become real-looking parked cars (look only)
task.spawn(function()
	local n = require(Modules.DecorCars).start()
	print(string.format("[DecorCars] %d stand-in cars dressed", n))
end)
S.Gate = require(Modules.GateService)
S.Gate.start() -- who plays here: the owner + friends; strangers go to their own garage (server_model.md)
if game:GetService("RunService"):IsStudio() and select(2, pcall(function()
	return game:GetService("StudioTestService"):GetTestArgs()
end)) == "gate" then
	S.Gate.studioStrangers.all = true -- (the gate test: player 2 arrives as a stranger)
end
require(Modules.JackLook).start() -- the map's block floor jacks become the 3D one (CarMeshes.Gear_FloorJack)
S.Data = require(Modules.PlayerData)
S.Data.start() -- loads every player's save (DataService) once GateService lets them in
S.Tools = require(Modules.ToolKit)
S.Cars = require(Modules.CarService)
S.Faults = require(Modules.FaultService)
S.Factory = require(Modules.CarFactory)
S.Carry = require(Modules.CarryService)
S.Bolts = require(Modules.BoltService)
S.Shop = require(Modules.ShopService)
S.Lift = require(Modules.LiftService)
S.Places = require(Modules.Places)
S.Upgrades = require(Modules.UpgradeService)
S.Equip = require(Modules.EquipmentService)
S.Jobs = require(Modules.JobService)
S.Customers = require(Modules.CustomerService)
S.Diagnosis = require(Modules.DiagnosisService)

-- a part went on / came off a car: symptoms, tilt and calipers follow
S.Carry.onCarChanged = function(car: Model)
	S.Faults.refresh(car)
	if S.Halloween then
		S.Halloween.tick(car) -- (Ella's midnight clock moves with the work)
	end
	S.Factory.pose(car)
	S.Jobs.check(car)
	if car:GetAttribute("Restore") then
		S.Restore.refresh(car) -- a restoration car: score + work list
	end
	local mg = (S :: any).Minigames -- (set further down)
	if mg then
		mg.carChanged(car) -- (mini-games on: the coolant fill after a new radiator, the wheels' last step)
	end
end
-- a trap fixed by hand (clean the terminals / polish / hang the rubber hanger): reach + what has to be open first
S.Faults.onTrapAction = function(car: Model, slotName: string, player: Player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local part = S.Factory.slotPart(car, slotName)
	if not root or not part or (S.Factory.root(part).Position - root.Position).Magnitude > require(ReplicatedStorage.Shared.Config).ReachDistance + 1 then
		return
	end
	local ok, key, args = S.Cars.check(car, part:GetAttribute("Requires"))
	if not ok then
		return S.Remotes.Notify:FireClient(player, key, args, "bad")
	end
	local fix = car:GetAttribute("Issue_" .. slotName)
	if not fix then
		return
	end
	local function done()
		if car.Parent and car:GetAttribute("Issue_" .. slotName) == fix then
			S.Faults.clearIssue(car, slotName)
			S.Cars.touch(car, player)
			S.Remotes.Notify:FireClient(player, require(ReplicatedStorage.Shared.Faults).Actions[fix].done, nil, "good")
			S.Carry.onCarChanged(car)
		end
	end
	-- with mini-games on: the crusty terminals scrubbed, the light scratch polished by hand (MinigameService "Scrub" /
	-- "Polish" — at / normal: where the scratch is, which way the bumper faces)
	if (fix == "clean" or fix == "polish") and require(ReplicatedStorage.Shared.Config).minigameKind(if fix == "clean" then "Scrub" else "Polish") then
		local at = S.Factory.root(part).Position
		local opts: { [string]: any } = { carId = car:GetAttribute("CarId"), car = car, near = at, done = done }
		if fix == "polish" then
			local decor = car:FindFirstChild("Decor")
			local mark = decor and decor:FindFirstChild("Issue_" .. slotName)
			local pivot = car:GetPivot()
			opts.at = if mark and mark:IsA("BasePart") then mark.Position else at
			opts.normal = if pivot:PointToObjectSpace(opts.at).Z < 0 then pivot.LookVector else -pivot.LookVector
		end
		(S :: any).Minigames.open(player, if fix == "clean" then "Scrub" else "Polish", opts)
		return
	end
	done()
end
S.Carry.start()
S.Bolts.start()
S.Shop.start()
S.Upgrades.start()
S.Upgrades.set(1, {}) -- Lv1 look until the garage owner's level / purchases are known
S.Lift.start(S.Upgrades.changed)
-- friends here and only one bay bought: Bay2 opens as a temporary bay while they stay (alpha_scope §1-4);
-- when they leave it closes once its car is gone (nobody loses a car in progress)
task.spawn(function()
	while true do
		task.wait(3)
		local want = #Players:GetPlayers() >= 2 and not S.Upgrades.state().owned.Bay2
		if want then
			S.Upgrades.setTemp("Bay2", true)
		elseif S.Upgrades.isTemp("Bay2") then
			local bay2 = S.Places.find("Bays.Bay2")
			if not (bay2 and bay2:GetAttribute("CarId")) then
				S.Upgrades.setTemp("Bay2", false)
			end
		end
		-- a lift kept hydraulic for a car still up high (the owner who bought it left) goes back once it's down
		if S.Upgrades.isTemp("HydraulicLift") then
			local high = false
			for _, bay in S.Places.bays() do
				high = high or (bay:GetAttribute("LiftLevel") or 1) > 2
			end
			if not high then
				S.Upgrades.setTemp("HydraulicLift", false)
			end
		end
		-- the sign on the temporary bay
		local bay2 = S.Places.find("Bays.Bay2")
		local spot = bay2 and bay2:FindFirstChild("CarSpot")
		if spot then
			local sign = spot:FindFirstChild("TempSign")
			if S.Upgrades.isTemp("Bay2") and not sign then
				local g = Instance.new("BillboardGui")
				g.Name = "TempSign"
				g.Size = UDim2.fromOffset(320, 40)
				g.StudsOffset = Vector3.new(0, 9, 0)
				g.MaxDistance = 90
				local l = Instance.new("TextLabel")
				l.Size = UDim2.fromScale(1, 1)
				l.BackgroundColor3 = Color3.fromRGB(30, 34, 42)
				l.BackgroundTransparency = 0.2
				l.TextColor3 = Color3.fromRGB(255, 220, 110)
				l.Font = Enum.Font.GothamBold
				l.TextScaled = true
				require(ReplicatedStorage.Shared.Locale).tag(l, "bay.temporary")
				l.Parent = g
				g.Parent = spot
			elseif not S.Upgrades.isTemp("Bay2") and sign then
				sign:Destroy()
			end
		end
	end
end)

-- tools & upgrades shop; the map follows the garage owner's level + garage upgrades (EquipmentService)
S.Equip.start()
-- muffler jobs only once the garage has a lift that goes all the way up (economy.md §1-2)
S.Shop.shelfSpot = function(): CFrame?
	if not S.Equip.garageHas("PartsShelfPlus") then
		return nil
	end
	local slots = S.Places.find("PartsShelfPlus.Slots")
	for _, slot in (if slots then slots:GetChildren() else {}) do
		if slot:IsA("BasePart") then
			local taken = false
			for _, p in S.Factory.looseFolder():GetChildren() do
				if p:GetAttribute("State") == "Free" and (p:GetPivot().Position - slot.Position).Magnitude < 1.6 then
					taken = true
				end
			end
			if not taken then
				return slot.CFrame
			end
		end
	end
	return nil
end
S.Faults.gearOpen = function(kindOrGear: string): boolean
	if kindOrGear == "Muffler" then
		return S.Equip.garageHas("HydraulicLift")
	end
	return S.Equip.garageHas(kindOrGear) -- a variant that needs equipment (WHEEL_IMBALANCE <- WheelBalancer)
end
-- the bought stations: balancer, stethoscope, OBD Reader
S.Minigames = require(Modules.MinigameService)
S.Minigames.start()
S.Minigames.onEarned = function(p: Player, money: number)
	if S.Shift then
		S.Shift.earn(p, money)
	end
end
S.Jobs.waitFor = S.Minigames.waiting -- (a mini-game step still waiting on the car: not handed back yet)
S.Jobs.tipRoom = function(car: Model, p: Player): number
	return S.Minigames.tipRoom(car:GetAttribute("CarId"), p) -- (Perfect tips + the star-pattern tip: one cap a player)
end
S.Stations = require(Modules.StationService)
local hookBalancer = S.Stations.start()
S.Diagnosis.onReadCodes = S.Stations.readCodes
S.Upgrades.changed.Event:Connect(function()
	task.defer(function()
		hookBalancer()
		for _, car in (workspace:FindFirstChild("Cars") and workspace.Cars:GetChildren() or {}) do
			local obd = car.PrimaryPart and car.PrimaryPart:FindFirstChild("ObdPrompt", true)
			if obd then
				obd.Enabled = S.Equip.garageHas("OBDReader")
			end
		end
	end)
end)
S.Diagnosis.start()
S.Customers.start()
S.Halloween = require(Modules.HalloweenService)
S.Halloween.start() -- Ella, the last customer before closing (only in the Halloween dates)
S.Remotes.SetLang.OnServerEvent:Connect(function(player, lang)
	S.Data.setLang(player, lang) -- (only "en" / "ko" are kept)
end)
S.Remotes.SetSound.OnServerEvent:Connect(function(player, t)
	S.Data.setSound(player, t) -- (bools and whole levels 1..5 only)
end)
S.Tutorial = require(Modules.TutorialService)
S.Tutorial.start()
S.Customers.tutorialPick = S.Tutorial.pick
S.Customers.onTutorialCar = S.Tutorial.setup
S.Tutorial.onDone = function()
	S.Customers.afterTutorial = true -- (the next ordinary car: not the tutorial's three faults again)
end
-- the work view: zones + the bay's cart (WorkService), the floor jack and stands (JackService)
S.Work = require(Modules.WorkService)
S.Jack = require(Modules.JackService)
S.Jack.busyBy = S.Work.busyBy
S.Jack.onChanged = function(car)
	S.Work.recheck(car)
	S.Work.prompts(car)
end
S.Lift.busyBy = S.Work.busyBy
S.Shop.cartSpot = S.Work.cartSpot -- the first car's ordered battery lands on the bay's cart
S.Shop.deliver = S.Work.deliver
S.Work.start()
S.Jack.start()
-- opening a hood always takes the opener into the engine bay's work view (user decision 10-21) — not a quick job's
S.Cars.onHoodOpened = function(player, car)
	if not car:GetAttribute("CurbJob") then
		S.Work.enter(player, car, "EngineBay")
	end
end
-- the tutorial's first car, fixed: out of the work view to start it up (the whole car in view)
S.Tutorial.onFixed = function(car)
	for _, p in game:GetService("Players"):GetPlayers() do
		if p:GetAttribute("WorkCar") == car:GetAttribute("CarId") then
			S.Work.leave(p)
		end
	end
end
-- today's receipt: this shift counted, the last one kept for next time
S.Shift = require(Modules.ShiftService)
S.Customers.onJobDone = S.Shift.job
require(Modules.ShowroomService).onSold = S.Shift.sold -- (S.Showroom starts further down)
S.Equip.onBought = S.Shift.unlock
S.Carry.onEarned = S.Shift.earn
S.Shift.start()
-- quick jobs at the curb (curb_jobs.md §2): counted at each bay hand-back
S.Curb = require(Modules.CurbService)
S.Customers.onHandBack = S.Curb.handBack
S.Curb.onEarned = S.Shift.quick
S.Curb.start()
S.Jobs.onTutorial = S.Tutorial.released
S.Restore = require(Modules.RestoreService)
S.Restore.start()
S.Junkyard = require(Modules.JunkyardService)
S.Junkyard.start()
S.Showroom = require(Modules.ShowroomService)
S.Showroom.start()
S.Names = require(Modules.NameService)
S.Names.start() -- the owner names the garage (Lv3+, free once, then the Garage Rename pass; two filters)
S.Coffee = require(Modules.CoffeeService) -- coffee for the waiting customers (Features.Coffee)
S.Coffee.carried = S.Carry.carried
S.Carry.onPickUp = function(p: Player)
	S.Coffee.drop(p, true) -- (a part in both hands: the cup's put down, and it says so)
end
S.Coffee.start()
S.Oil = require(Modules.OilService) -- the oil change: drain, pour, done (Features.OilChange; rows Cars/SedanOil)
S.Oil.start()
require(script.Parent.Dev.DevHooks).start(S) -- Studio only (MCP play tests)
if game:GetService("RunService"):IsStudio() then
	local ok, args = pcall(function()
		return game:GetService("StudioTestService"):GetTestArgs()
	end)
	if ok and (args == "coop" or args == "coopvip" or args == "coopsuv") then
		-- 2-player test (StudioTestService); coopsuv = the same job on a Crossover
		task.spawn(require(script.Parent.Dev.CoopTest).run, S, args == "coopvip", if args == "coopsuv" then "Crossover" else nil)
	elseif ok and args == "mgcoop" then
		task.spawn(require(script.Parent.Dev.MgCoopTest).run, S) -- the mini-game wheel step between two players (wr-mini)
	elseif ok and args == "coffeecoop" then
		task.spawn(require(script.Parent.Dev.CoffeeCoopTest).run, S) -- coffee between two players (wr-dev; Dev_Coffee on in edit mode)
	elseif ok and args == "gate" then
		task.spawn(require(script.Parent.Dev.CoopTest).gate, S) -- strangers go to their own garage, friends stay
	elseif ok and args == "ownerleave" then
		task.spawn(require(script.Parent.Dev.CoopTest).ownerLeave, S) -- the garage owner leaves mid-job
	end
end

S.Tools.setup()
-- players who spawned before the tools went into StarterPack get them now
for _, p in Players:GetPlayers() do
	local backpack = p:FindFirstChildOfClass("Backpack")
	if backpack and not backpack:FindFirstChild("Wrench") then
		for _, t in game:GetService("StarterPack"):GetChildren() do
			t:Clone().Parent = backpack
		end
	end
end

