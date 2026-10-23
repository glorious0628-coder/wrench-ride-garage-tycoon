-- The simple diagnosis (fun_boost #1, fault_catalog): a parked customer car gets two prompts at the driver's door —
-- "Try to start" and "Press the brakes" — that give a clue (text for everyone + a sound), and the Scanner checks one
-- part at a time (Remotes.Check) for a reading; a checked part shows its colour in inspect mode.
-- Clues live on the car (attribute "Clues", JSON) so everyone working on it sees the same job card.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Diagnosis = require(ReplicatedStorage.Shared.Diagnosis)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local FaultService = require(script.Parent.FaultService)
local Faults = require(ReplicatedStorage.Shared.Faults)
local ToolKit = require(script.Parent.ToolKit)
local EquipmentService = require(script.Parent.EquipmentService)
local Metrics = require(script.Parent.Metrics)
local Guard = require(script.Parent.Guard)

local DiagnosisService = {}

local lastCheck: { [Player]: number } = {}
local lastTry: { [Model]: number } = {}

-- worn parts + trap issues: both make the car act up
local function brokenSlots(car: Model): { [string]: boolean }
	return FaultService.symptomSlots(car)
end

-- the finds that name a part by where it is (a squeal from one wheel, the nail): they carry that slot too, which
-- moves the job card to "fix it" (test 1: the second car sat on "1/3 find it" until the pads were in) — they stay
-- next to a reading of the same part instead of being replaced by it (the tutorial looks for them)
local function isFind(key: string): boolean
	return key:sub(1, 11) == "clue.brake." or key == "clue.nail"
end

-- add a clue line to the car's job card (no duplicates)
function DiagnosisService.addClue(car: Model, key: string, args: { [string]: any }?)
	local ok, list = pcall(HttpService.JSONDecode, HttpService, (car:GetAttribute("Clues") :: string?) or "[]")
	list = if ok and type(list) == "table" then list else {}
	local sig = key .. HttpService:JSONEncode(args or {})
	for _, c in list do
		if c.k .. HttpService:JSONEncode(c.a or {}) == sig then
			return
		end
	end
	-- a newer reading of the same part replaces the old one
	if args and args.slot and not isFind(key) then
		for i = #list, 1, -1 do
			if list[i].a and list[i].a.slot == args.slot and not isFind(list[i].k) then
				table.remove(list, i)
			end
		end
	end
	table.insert(list, { k = key, a = args })
	car:SetAttribute("Clues", HttpService:JSONEncode(list))
end

local function wheelPos(car: Model, corner: string?): Vector3
	local c = corner and CarParts.type(car:GetAttribute("CarType") :: string?).WheelCenters[corner]
	return (car:GetPivot() * CFrame.new(c or Vector3.new(0, 2, -5))).Position
end

local function tryCar(car: Model, player: Player, what: string)
	if car:GetAttribute("Parked") ~= true then
		return
	end
	if os.clock() - (lastTry[car] or 0) < 1.5 then
		return
	end
	lastTry[car] = os.clock()
	local broken = brokenSlots(car)
	local key, args, sound, pos
	if what == "start" then
		key, sound = Diagnosis.startClue(broken)
		if key == "clue.start.click" and car:GetAttribute("Issue_Battery") == "clamp" and not FaultService.slotOK(car, "Battery")
			and not FaultService.isBroken(CarFactory.slotPart(car, "Battery")) then
			key, sound = "clue.start.clamp", "engineStart" -- (it cuts out, then catches: the battery rocks in its tray)
		end
		pos = (car:GetPivot() * CFrame.new(0, 2.5, -6)).Position
		if key == "clue.start.ok" then
			-- the engine sound comes with carStart (once) — its own crank is the 'click' (test 2 ⑩: the old fail click
			-- first made the happy moment start with a failure sound)
			sound = nil
			Remotes.Effect:FireAllClients("carStart", { car = car })
		end
	else
		local corner
		key, args, sound, corner = Diagnosis.brakeClue(broken)
		pos = wheelPos(car, corner)
		-- the variant decides how it sounds (worn = squeal, gone = grinding)
		local v = corner and Faults.ById[FaultService.variantOf(car, "BrakePads_" .. corner)]
		if v and v.brake then
			key = v.brake
		end
		if corner then
			args = args or {}
			args.slot = "BrakePads_" .. corner -- (a find: the job card's step 2)
		end
	end
	DiagnosisService.addClue(car, key, args)
	Remotes.Effect:FireAllClients("clue", { car = car, key = key, args = args, sound = sound, pos = pos })
	-- the fix shows (Metrics): a fixed car that starts now (an engine-bay job) / whose brakes are quiet now
	if car:GetAttribute("Fixed") == true then
		local first = string.split((car:GetAttribute("Faults") :: string?) or "", ",")[1]
		local brakeJob = first ~= nil and first:sub(1, 10) == "BrakePads_"
		if (key == "clue.start.ok" and not brakeJob) or (key == "clue.brake.ok" and brakeJob) then
			Metrics.mark(player, "firstChange")
		end
	end
end

local function onCheck(player: Player, target: any)
	if typeof(target) ~= "Instance" then
		return
	end
	Metrics.mark(player, "firstTouch")
	if ToolKit.equipped(player) ~= "Scanner" then
		return Remotes.Notify:FireClient(player, "n.needScanner", nil, "info")
	end
	if os.clock() - (lastCheck[player] or 0) < Config.CheckInterval then
		return
	end
	-- a battery terminal: wiggled by hand — tight and clean, or not (rival_upgrade B1 ⓪: "battery or terminals?")
	local terminal = target:IsA("BasePart") and target:GetAttribute("Bolt") and target:GetAttribute("Fastener") == "Terminal"
	-- climb from the clicked block to the repair part (the instance with PartKind)
	local part: Instance? = target
	while part and not part:GetAttribute("PartKind") do
		part = part.Parent
	end
	if not part or part:GetAttribute("State") ~= "Installed" then
		return
	end
	local car = CarService.carOf(part)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not car or not root or (CarFactory.root(part).Position - root.Position).Magnitude > Config.ReachDistance + 2 then
		return Remotes.Notify:FireClient(player, "n.tooFar", nil, "bad")
	end
	lastCheck[player] = os.clock()
	local kind = part:GetAttribute("PartKind") :: string
	local slot = part:GetAttribute("Slot") :: string
	if terminal then
		-- (no slot on it: it sits beside the battery's own reading instead of replacing it)
		local issue = car:GetAttribute("Issue_" .. slot) :: string?
		local tkey = if issue and not FaultService.slotOK(car, slot) then "read.trap." .. issue else "read.terminals.ok"
		car:SetAttribute("TerminalsChecked", true)
		DiagnosisService.addClue(car, tkey)
		Remotes.Effect:FireAllClients("clue", { car = car, key = tkey, args = {}, sound = "scannerBeep", pos = (target :: BasePart).Position, quiet = true })
		return
	end
	local key, args = Diagnosis.reading(kind, part:GetAttribute("Condition") :: number, slot)
	-- a trap: the part reads fine, but the reading points at what's really wrong next to it
	local issue = car:GetAttribute("Issue_" .. slot) :: string?
	if issue and not FaultService.slotOK(car, slot) then
		key = "read.trap." .. issue
	elseif kind == "Battery" and not EquipmentService.playerHas(player, "BatteryTester") then
		-- volts need the Battery Tester (alpha_scope §3, Lv2): the Scanner only says worn / fine
		key = if FaultService.isBroken(part) then "read.battery.deadNoTester" else "read.battery.okNoTester"
	end
	args.slot = slot
	part:SetAttribute("Checked", true)
	DiagnosisService.addClue(car, key, args)
	-- the first car: who found the dead battery — the settlement shows its diagnosis line (B1 ⓪; user 10-22 "그냥
	-- 한꺼번에 해": nothing is paid before the hand-back, it's one line of the one settlement)
	if car:GetAttribute("Tutorial") == 1 and kind == "Battery" and FaultService.isBroken(part) and not car:GetAttribute("DiagBy") then
		car:SetAttribute("DiagBy", player.UserId)
	end
	if not FaultService.slotOK(car, slot) then
		CarService.touch(car, player) -- a work unit: found a fault
	end
	Remotes.Effect:FireAllClients("clue", { car = car, key = key, args = args, sound = "scannerBeep", pos = CarFactory.root(part).Position, quiet = true })
end

-- the two prompts at the driver's door (car's left = -X in car space). Own keys (T = turn the key, B = brakes): the
-- hood's E is in reach from the door too
function DiagnosisService.setup(car: Model)
	local chassis = car.PrimaryPart :: BasePart
	if chassis:FindFirstChild("DriverSide") then
		return
	end
	local att = Instance.new("Attachment")
	att.Name = "DriverSide"
	att.Position = chassis.CFrame:PointToObjectSpace((car:GetPivot() * CFrame.new(-4.2, 3, -0.6)).Position)
	att.Parent = chassis
	-- (trying the car = the job card / task strip buttons now: Remotes.TryCar. Only the OBD reader stays a prompt.)
	for _, def in { { "ObdPrompt", "act.readCodes", Enum.KeyCode.Y, "obd", 0 } } do
		local p = Instance.new("ProximityPrompt")
		p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
		p.Name = def[1]
		p.KeyboardKeyCode = def[3]
		p.HoldDuration = 0.3
		p.MaxActivationDistance = Config.PromptDistance
		p.RequiresLineOfSight = false
		p.UIOffset = Vector2.new(0, def[5])
		Locale.tag(p, def[2])
		Locale.tag(p, "obj.driverSeat", nil, "ObjectText")
		p.Parent = att
		p.Triggered:Connect(Guard.prompt(p, "Seat", 0.5, function(player)
			if def[4] == "obd" then
				if DiagnosisService.onReadCodes then
					DiagnosisService.onReadCodes(car, player)
				end
				return
			end
			tryCar(car, player, def[4])
		end))
		if def[4] == "obd" then
			p.Enabled = EquipmentService.garageHas("OBDReader") -- (Main turns it on when the reader is bought)
		end
	end
end

-- set by Main: the OBD Reader (StationService.readCodes)
DiagnosisService.onReadCodes = nil :: ((car: Model, player: Player) -> ())?

function DiagnosisService.start()
	Remotes.Check.OnServerEvent:Connect(Guard.wrap("Check", 0, onCheck)) -- (CheckInterval paces it)
	Remotes.TryCar.OnServerEvent:Connect(Guard.wrap("TryCar", 0.3, function(player: Player, car: any, what: any)
		if typeof(car) ~= "Instance" or not car:IsA("Model") or car.Parent ~= workspace:FindFirstChild("Cars") then
			return
		end
		if what ~= "start" and what ~= "brake" then
			return
		end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root or (root.Position - car:GetPivot().Position).Magnitude > 22 then
			return Remotes.Notify:FireClient(player, "n.tooFar", nil, "bad")
		end
		tryCar(car :: Model, player, what)
	end))
	game:GetService("Players").PlayerRemoving:Connect(function(p)
		lastCheck[p] = nil
	end)
end

return DiagnosisService
