-- The guide line's words for every customer job after the tutorial (rival_upgrade B2-2, made of what the car shows —
-- the job card's stages, the part table's `requires`, the bolts left, what lies on the cart): the ONE next thing.
-- Guide.next(car) -> key, args, info   (info = { target = the spot / part it's about, glow = the part to light,
-- order = a part kind to order from here — BuyPart(kind, "job") }). Locale keys `guide.*`, the key word yellow.
-- JobCard.guide (wr-ui) asks; nil = say nothing new (its own stage line stays). Quick jobs at the curb, Ella's coach and
-- the trap fixes (clean / polish / hang / balance) keep the job card's line: their steps aren't a part swap.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)

local Guide = {}

local player = Players.LocalPlayer

export type Info = { target: Instance?, glow: Instance?, order: string? }

-- the car's parts by slot, read once per Guide.next (it runs ~3×/s plus the job card): installed / hinged down (E2 Swing)
local view: { car: Model?, installed: { [string]: Instance }, swung: { [string]: Instance } } = { car = nil, installed = {}, swung = {} }

local function scan(car: Model)
	view = { car = car, installed = {}, swung = {} }
	for _, d in car:GetDescendants() do
		local slot = d:GetAttribute("Slot") :: string?
		if slot and d:GetAttribute("PartKind") then
			local state = d:GetAttribute("State")
			if state == "Installed" then
				view.installed[slot] = d
			elseif state == "Swung" then
				view.swung[slot] = d
			end
		end
	end
end

local function slotPart(car: Model, slot: string): Instance?
	if view.car ~= car then
		scan(car)
	end
	return view.installed[slot]
end

local function rootOf(part: Instance?): BasePart?
	if not part then
		return nil
	end
	return if part:IsA("BasePart") then part else (part :: Model).PrimaryPart
end

local function isNew(part: Instance): boolean
	return ((part:GetAttribute("Condition") :: number?) or 100) >= 50
end

local function bolted(part: Instance): boolean
	local count = (part:GetAttribute("BoltCount") :: number?) or 0
	return count == 0 or ((part:GetAttribute("BoltsRemaining") :: number?) or 0) >= count
end

local function head(part: Instance, name: string): BasePart?
	for _, d in part:GetChildren() do
		if d:IsA("BasePart") and d:GetAttribute("Attachment") == name then
			return d
		end
	end
	return nil
end

-- the first bolt head still to turn on a part that turns now (loosen: a tight one / tighten: a loose one) — one whose
-- turn waits for another (the strut's top nuts after the knuckle, a battery terminal: LoosenAfter / TightenAfter) is
-- skipped while that one isn't done yet. Also its place, for the bolt's own conditions (the top nuts: hood open)
local function nextBolt(part: Instance, tight: boolean): (BasePart?, Attachment?)
	local root = rootOf(part)
	for i = 1, 16 do
		local b = head(part, "Bolt_" .. i)
		if b and (b:GetAttribute("Tight") == true) == tight then
			local att = root and root:FindFirstChild("Bolt_" .. i) :: Attachment?
			local after = att and att:GetAttribute(if tight then "LoosenAfter" else "TightenAfter") :: string?
			local other = after and head(part, after)
			if not other or (other:GetAttribute("Tight") == true) ~= tight then
				return b, att
			end
		end
	end
	return nil
end

-- loose parts of a kind (on the floor, on the cart, popped out beside the car)
local function loose(car: Model, kind: string, new: boolean): Instance?
	local id = car:GetAttribute("CarId")
	local best: Instance? = nil
	local pools = { workspace:FindFirstChild("LooseParts"), car:FindFirstChild("Detached") }
	for _, pool in pools do
		for _, p in (if pool then pool:GetChildren() else {}) do
			if p:GetAttribute("PartKind") == kind and p:GetAttribute("State") == "Free" and isNew(p) == new then
				-- (this car's first: on its cart / came off it)
				if p:GetAttribute("OnCart") == id or p:GetAttribute("FromCar") == id then
					return p
				end
				best = best or p
			end
		end
	end
	return if new then best else nil
end

local function held(): Instance?
	local pool = workspace:FindFirstChild("LooseParts")
	for _, p in (if pool then pool:GetChildren() else {}) do
		if p:GetAttribute("CarriedBy") == player.UserId and p:GetAttribute("State") == "Carried" then
			return p
		end
	end
	return nil
end

local function inZone(car: Model, zone: string): boolean
	return player:GetAttribute("WorkCar") == car:GetAttribute("CarId") and player:GetAttribute("WorkZone") == zone
end

local function spot(car: Model, name: string): Instance?
	return car.PrimaryPart and car.PrimaryPart:FindFirstChild(name)
end

local function partWord(slot: string): string
	return "@part." .. CarParts.Slots[slot].kind
end

-- this car's own slots (a Crossover's aren't the sedan's)
local function slotsOf(car: Model): { [string]: any }
	return CarParts.type(car:GetAttribute("CarType") :: string?).Slots
end

-- how many parts sit over this one (the link under the wheel = 1): what's deeper goes back on first (static data)
local depths: { [any]: { [string]: number } } = {} -- (per slot table: per car type)
local function depthOf(slots: { [string]: any }, slot: string, n: number): number
	local memo = depths[slots] or {}
	depths[slots] = memo
	if memo[slot] then
		return memo[slot]
	end
	local d = 0
	for _, req in (if n < 8 then slots[slot].requires else nil) or {} do
		if slots[req] then
			d = math.max(d, 1 + depthOf(slots, req, n + 1))
		end
	end
	memo[slot] = d
	return d
end

-- a part of that kind that came off this car (held, lying beside it, on its cart): there's something to put back
local function ours(car: Model, kind: string, mine: Instance?): Instance?
	local id = car:GetAttribute("CarId")
	if mine and mine:GetAttribute("PartKind") == kind and isNew(mine) and mine:GetAttribute("FromCar") == id then
		return mine
	end
	local p = loose(car, kind, true)
	return if p and (p:GetAttribute("FromCar") == id or p:GetAttribute("OnCart") == id) then p else nil
end

-- up on its stands at that end? (else: the jack / stands step)
local function liftStep(car: Model, e: string): (string?, { [string]: any }?, Info?)
	local support = (car:GetAttribute("Support") :: string?) or "None"
	if support == "Stands" .. e then
		return nil
	end
	if support == "Jack" .. e then
		return "guide.stands", nil, { target = spot(car, "Stand_" .. e .. "1") }
	end
	if support ~= "None" then
		return "guide.lowerFirst", nil, { target = spot(car, "Jack_" .. (car:GetAttribute("LiftEnd") or e)) }
	end
	return if e == "F" then "guide.liftF" else "guide.liftR", nil, { target = spot(car, "Jack_" .. e) }
end

-- E2: the floor jack under that corner's lower arm (car on its stands — JackService.arm). Its prompt is beside the
-- car, off inside a work view: step out first
local function armStep(car: Model, corner: string): (string?, { [string]: any }?, Info?)
	local now = car:GetAttribute("ArmJack") :: string?
	if now == corner then
		return nil
	end
	local leave = player:GetAttribute("WorkZone") ~= nil
	if now then
		-- (under another corner's arm: out from there first — its prompt is the one that's on)
		return if leave then "guide.armOutLeave" else "guide.armOut", nil, { target = spot(car, "Arm_" .. now) }
	end
	return if leave then "guide.armLeave" else "guide.arm", nil, { target = spot(car, "Arm_" .. corner) }
end

local function hoodStep(car: Model): (string?, { [string]: any }?, Info?)
	local hood = slotPart(car, "Hood")
	-- (from a wheel's view — the strut's top nuts: its prompt is outside)
	return if player:GetAttribute("WorkZone") then "guide.hoodLeave" else "guide.hood", nil, { target = rootOf(hood), glow = hood }
end

-- one part off for the job: the steps to reach it, then loosen and lift it out. The car up on its stands before the
-- jack goes under an arm (JackService.arm needs the stands), whatever order the row lists them in
local function needOpen(car: Model, slot: string): (boolean, string?, { [string]: any }?, Info?)
	local info = CarParts.Slots[slot]
	for _, req in info.requires or {} do
		if req == "Hood:Open" and not car:GetAttribute("HoodOpen") then
			return true, hoodStep(car)
		elseif req == "Lift:Wheel" or (req == "Lift:Under" and Config.feature("UnderView")) then
			-- (the creeper: that end on its stands too — then zoneStep says slide under)
			local e = CarParts.endOf(slot)
			if e then
				local k, a, i = liftStep(car, e)
				if k then
					return true, k, a, i
				end
			end
		end
		-- (Lift:Under without the creeper view: the job card says it)
	end
	for _, req in info.requires or {} do
		if req:sub(1, 4) == "Arm:" then
			local k, a, i = armStep(car, req:sub(5))
			if k then
				return true, k, a, i
			end
		end
	end
	return false
end

-- the next bolt to turn on a part, or what that bolt waits for (the strut's top nuts: under the hood)
local function boltStep(car: Model, part: Instance, tight: boolean, key: string, args: { [string]: any }): (string?, { [string]: any }?, Info?)
	local b, att = nextBolt(part, tight)
	local req = att and att:GetAttribute("Requires") :: string?
	if req and req:find("Hood:Open", 1, true) and not car:GetAttribute("HoodOpen") then
		return hoodStep(car)
	end
	return key, args, { target = b, glow = part }
end

-- the work view this part is done in (engine bay / a wheel): go in, when that zone has one
local function zoneStep(car: Model, slot: string): (string?, { [string]: any }?, Info?)
	local zone = CarParts.zoneOf(slot)
	if not zone or inZone(car, zone) then
		return nil
	end
	if zone == "EngineBay" then
		return "guide.workEngine", nil, { target = spot(car, "Work_EngineBay") }
	elseif zone:match("^Wheel_") then
		return "guide.workWheel", nil, { target = spot(car, "Work_" .. zone) }
	elseif zone:match("^Under_") and Config.feature("UnderView") then
		return "guide.slideUnder", nil, { target = spot(car, "Work_" .. zone) }
	end
	return nil
end

-- the way to this part: its conditions, then each part over it off — down the chain (the rear spring under the No.2
-- arm, that under the stabilizer link and the wheel: each one's own conditions and parts first). nil = clear
local function reachStep(car: Model, slot: string, seen: { [string]: boolean }): (string?, { [string]: any }?, Info?)
	local opening, k, a, i = needOpen(car, slot)
	if opening then
		return k, a, i
	end
	for _, req in CarParts.Slots[slot].requires or {} do
		local over = CarParts.Slots[req] and not seen[req] and slotPart(car, req)
		if over then
			seen[req] = true
			local rk, ra, ri = reachStep(car, req, seen)
			if rk then
				return rk, ra, ri
			end
			local zk, za, zi = zoneStep(car, req)
			if zk then
				return zk, za, zi
			end
			if ((over:GetAttribute("BoltsRemaining") :: number?) or 0) == 0 then
				return "guide.takeOut", { part = partWord(req) }, { target = rootOf(over), glow = over }
			end
			return boltStep(car, over, true, "guide.remove", { part = partWord(req) })
		end
	end
	return nil
end

-- what's left to do for one found fault; nil when that one is done
local function faultStep(car: Model, slot: string): (string?, { [string]: any }?, Info?)
	local info = CarParts.Slots[slot]
	local kind = info.kind
	local mine = held()
	local here = slotPart(car, slot)
	if here and isNew(here) and bolted(here) then
		return nil -- (fixed: the new one's in and bolted)
	end
	local k, a, i = reachStep(car, slot, {})
	if k then
		return k, a, i
	end
	local zk, za, zi = zoneStep(car, slot)
	if zk then
		return zk, za, zi
	end
	if here and not isNew(here) then
		if ((here:GetAttribute("BoltsRemaining") :: number?) or 0) > 0 then
			return boltStep(car, here, true, "guide.loosen", { part = "@part." .. kind })
		end
		return "guide.takeOut", { part = "@part." .. kind }, { target = rootOf(here), glow = here }
	end
	if mine and mine:GetAttribute("PartKind") == kind and not isNew(mine) then
		return "guide.oldTray", { part = "@part." .. kind }, nil
	end
	if not here then
		local old = loose(car, kind, false)
		if old and old:GetAttribute("OnCart") == nil and old.Parent and old.Parent.Name == "Detached" then
			return "guide.takeOut", { part = "@part." .. kind }, { target = rootOf(old), glow = old }
		end
		if kind == "BrakePads" then
			local cal = car:FindFirstChild("Moving") and (car :: any).Moving:FindFirstChild("BrakeCaliper_" .. slot:sub(-2))
			if cal and cal:GetAttribute("PistonIn") == false then
				return "guide.piston", nil, { target = cal, glow = cal }
			end
		end
		if mine and mine:GetAttribute("PartKind") == kind and isNew(mine) then
			return "guide.putIn", { part = "@part." .. kind }, { target = spot(car, "Snap_" .. slot) }
		end
		local new = loose(car, kind, true)
		if new then
			return "guide.putIn", { part = "@part." .. kind }, { target = rootOf(new), glow = new }
		end
		return "guide.order", { part = "@part." .. kind, money = (CarParts.Kinds[kind] :: any).price }, { order = kind }
	end
	-- the new one's in: its bolts
	return boltStep(car, here, false, "guide.tighten", { part = "@part." .. kind })
end

-- the parts taken off to reach it go back on (the wheel over the new pads), tight
local function putBackStep(car: Model): (string?, { [string]: any }?, Info?)
	local slots = slotsOf(car)
	-- an arm hinged down on the jack (E2 Swing) goes back up first — a tap in that wheel's view, the spring seated
	for slot, d in view.swung do
		if slots[slot] then
			local zk, za, zi = zoneStep(car, slot)
			if zk then
				return zk, za, zi
			end
			return "guide.armUp", { part = partWord(slot) }, { target = rootOf(d), glow = d }
		end
	end
	for slot, info in slots do
		local p = slotPart(car, slot)
		-- (the loose battery clamp is a trap: a healthy battery with one bolt out reads as "a new part not bolted yet" —
		-- the scan finds it first; its own step is further down. Switch ClampTrap)
		if p and not bolted(p) and isNew(p) and car:GetAttribute("Issue_" .. slot) ~= "clamp" then
			local zk, za, zi = zoneStep(car, slot)
			if zk then
				return zk, za, zi
			end
			return boltStep(car, p, false, "guide.tighten", { part = "@part." .. info.kind })
		end
	end
	-- what came off to reach it goes back, the inner ones first (the stabilizer link before the wheel over it): a
	-- wheel always (a car never leaves on three), any other part when one that came off this car is here to put back
	local empty: { string } = {}
	local mine = held()
	for slot, info in slots do
		if not slotPart(car, slot) and not view.swung[slot] and (info.kind == "Wheel" or ours(car, info.kind, mine)) then
			table.insert(empty, slot)
		end
	end
	table.sort(empty, function(x, y)
		local dx, dy = depthOf(slots, x, 0), depthOf(slots, y, 0)
		return if dx ~= dy then dx > dy else x < y
	end)
	for _, slot in empty do
		local kind = slots[slot].kind
		if mine and mine:GetAttribute("PartKind") == kind and isNew(mine) then
			return "guide.putBack", { part = "@part." .. kind }, { target = spot(car, "Snap_" .. slot) }
		end
		local zk, za, zi = zoneStep(car, slot)
		if zk then
			return zk, za, zi
		end
		local lying = loose(car, kind, true)
		if lying then
			return "guide.putBack", { part = "@part." .. kind }, { target = rootOf(lying), glow = lying }
		end
		return "guide.order", { part = "@part." .. kind, money = (CarParts.Kinds[kind] :: any).price }, { order = kind }
	end
	return nil
end

local MG_STEP = { Torque = "guide.mgTorque", Tire = "guide.mgTire", Coolant = "guide.mgCoolant" }

function Guide.next(car: Model): (string?, { [string]: any }?, Info?)
	scan(car)
	if not car:GetAttribute("Parked") or car:GetAttribute("CurbJob") or car:GetAttribute("Special") then
		return nil
	end
	if car:GetAttribute("Fixed") == true then
		local arm = car:GetAttribute("ArmJack") :: string?
		if arm then
			-- (the jack under an arm comes out before the car can come down — JackService.lower)
			return if player:GetAttribute("WorkZone") then "guide.armOutLeave" else "guide.armOut", nil, { target = spot(car, "Arm_" .. arm) }
		end
		if ((car:GetAttribute("Support") :: string?) or "None") ~= "None" then
			local e = (car:GetAttribute("LiftEnd") :: string?) or "F"
			return "guide.lower", nil, { target = spot(car, "Jack_" .. e) }
		end
		-- (a mini-game step the car still waits on, MinigameService sets `MgStep`: the hand-back refuses until it is done)
		local mg = car:GetAttribute("MgStep") :: string?
		local mgKey = if mg then MG_STEP[mg] else nil
		if mgKey then
			local prompt = car:FindFirstChild("MgStepPrompt", true)
			return mgKey, nil, { target = if prompt then prompt.Parent else nil }
		end
		return "guide.handBack", nil, { target = car.PrimaryPart }
	end
	local faults: { string } = string.split((car:GetAttribute("Faults") :: string?) or "", ",")
	local ok, list = pcall(HttpService.JSONDecode, HttpService, (car:GetAttribute("Clues") :: string?) or "[]")
	list = if ok and type(list) == "table" then list else {}
	local found: { [string]: boolean } = {}
	for _, clue in list do
		local slot = type(clue) == "table" and clue.a and clue.a.slot
		if slot and table.find(faults, slot) and CarParts.Slots[slot] then
			found[slot] = true
		end
	end
	for _, slot in faults do
		if found[slot] then
			local issue = car:GetAttribute("Issue_" .. slot)
			if issue == "clamp" then
				-- (the loose battery hold-down: the wrench on its clamp bolt — FaultService.slotOK)
				local battery = slotPart(car, slot)
				local loose: Instance? = nil
				for _, d in (if battery then battery:GetChildren() else {}) do
					if d:IsA("BasePart") and d:GetAttribute("Bolt") and d:GetAttribute("Fastener") ~= "Terminal" and d:GetAttribute("Tight") ~= true then
						loose = d
					end
				end
				if loose and battery then
					if not car:GetAttribute("HoodOpen") then
						return hoodStep(car)
					end
					local zk, za, zi = zoneStep(car, slot)
					if zk then
						return zk, za, zi
					end
					return "guide.clamp", nil, { target = loose, glow = battery }
				end
				continue
			elseif issue == "clean" or issue == "polish" then
				-- (the crusted terminals / the light scratch: the Issue_ part's FixPrompt, a tap with the mini-games on.
				-- Only that spot lights up, not the whole battery; without this line the job card's fallback said
				-- "put in a new Battery" for the corrosion trap: wr-mini integration test #3)
				if issue == "clean" and not car:GetAttribute("HoodOpen") then
					return hoodStep(car)
				end
				local decor = car:FindFirstChild("Decor")
				local mark = decor and decor:FindFirstChild("Issue_" .. slot .. (if issue == "clean" then "_1" else ""))
				if mark then
					return if issue == "clean" then "guide.clean" else "guide.polish", nil, { target = mark, glow = mark }
				end
				return nil
			elseif issue then
				return nil -- (a trap: hanging a muffler / balancing a wheel: the job card says how)
			end
			local k, a, i = faultStep(car, slot)
			if k then
				return k, a, i
			end
		end
	end
	local k, a, i = putBackStep(car)
	if k then
		return k, a, i
	end
	if #list == 0 then
		return if player:GetAttribute("WorkZone") then "guide.scan" else "guide.tryCard", nil, nil -- (the door prompts are gone: the card's buttons try the car — wr-play TOP2)
	end
	-- something's still wrong that nobody has found
	return "guide.scan", nil, nil
end

-- the spot the guide points at, for PromptFocus (B2-2: "the prompt for the step you're on wins" — jack vs hood,
-- a wheel's Pick up vs Work on wheel — after the tutorial too). Only spots with a prompt; worked out 3 times a second.
local cached: Instance? = nil
local cachedAt = 0
function Guide.focus(): Instance?
	if os.clock() - cachedAt < 0.3 then
		return cached
	end
	cachedAt = os.clock()
	cached = nil
	local tut = player:GetAttribute("Tut") :: number?
	if tut ~= nil and tut < 4 and not player:GetAttribute("TutSkip") then
		return nil
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local cars = workspace:FindFirstChild("Cars")
	if not root or not cars then
		return nil
	end
	local best, bestD = nil, 40
	for _, c in cars:GetChildren() do
		if c:IsA("Model") and c:GetAttribute("Parked") then
			local d = (c:GetPivot().Position - root.Position).Magnitude
			if d < bestD then
				best, bestD = c, d
			end
		end
	end
	if best then
		local ok, _, _, info = pcall(Guide.next, best)
		local t = ok and info and info.target
		if t and t:FindFirstChildWhichIsA("ProximityPrompt", true) then
			cached = t
		end
	end
	return cached
end

return Guide
