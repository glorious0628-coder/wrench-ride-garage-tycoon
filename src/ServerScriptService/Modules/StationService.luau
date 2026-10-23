-- The bought diagnosis / repair stations (alpha_scope v0.2 §3, fault_catalog v0.4):
--   Wheel Balancer: bring a wheel, the timing gauge (기획서 3장 '타이밍 게이지'): stop the needle in the green
--                   3 times → the wheel is balanced (WHEEL_IMBALANCE). A MinigameService kind: the server owns the
--                   needle and judges each tap by when it arrived, so the client can't fake hits.
--   Stethoscope:    held near the car, the client shows how close the noise is; a tap right on it asks the server
--                   (Remotes.Listen), which names the part making it (a clue on the job card).
--   OBD Reader:     "Read codes" at the driver's door: the trouble codes of what's wrong (or "no codes stored").

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Faults = require(ReplicatedStorage.Shared.Faults)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local CarryService = require(script.Parent.CarryService)
local DiagnosisService = require(script.Parent.DiagnosisService)
local EquipmentService = require(script.Parent.EquipmentService)
local FaultService = require(script.Parent.FaultService)
local Places = require(script.Parent.Places)
local ToolKit = require(script.Parent.ToolKit)
local Guard = require(script.Parent.Guard)
local MinigameService = require(script.Parent.MinigameService)

local StationService = {}

local rng = Random.new()

----------------------------------------------------------------------------------------------------------------
-- Wheel Balancer: the timing gauge
----------------------------------------------------------------------------------------------------------------
-- (a MinigameService kind, "Balance": the server's clock only — the tap is taken to have happened half this player's
-- round trip before it arrived, give or take Config.BalanceGrace; what the client says the time was is never used —
-- exploit audit M3, minigames §4)
local MISS_REST = 0.6

-- where the needle is (0..1) at a server time: a triangle wave, there and back once per period
local function needleAt(st: { [string]: any }, t: number): number
	local x = ((t - st.t0) / st.period) % 1
	return if x < 0.5 then x * 2 else 2 - x * 2
end

local function newZone(st: { [string]: any })
	st.zone = rng:NextNumber(0.2, 0.8)
end

local function inGreen(st: { [string]: any }, t: number): boolean
	for _, dt in { 0, -Config.BalanceGrace, Config.BalanceGrace } do
		if math.abs(needleAt(st, t + dt) - st.zone) <= st.width / 2 then
			return true
		end
	end
	return false
end

MinigameService.define("Balance", {
	begin = function(s, opts)
		local st = { wheel = opts.wheel, t0 = s.t0, period = Config.BalancePeriod, zone = 0.5, width = Config.BalanceZone, hits = 0, misses = 0, restUntil = 0, lastTap = -math.huge }
		newZone(st)
		s.state = st
		return { t0 = st.t0, period = st.period, zone = st.zone, width = st.width, need = Config.BalanceHits }
	end,
	still = function(s)
		return s.state.wheel.Parent ~= nil and CarryService.carried(s.player) == s.state.wheel
	end,
	input = function(s, what, _, now)
		local st = s.state
		if what ~= "tap" or now < st.restUntil or now - st.lastTap < Config.BalanceTapGap then
			return nil
		end
		st.lastTap = now
		if not inGreen(st, now - math.clamp(s.player:GetNetworkPing() / 2, 0, 0.2)) then
			st.misses += 1
			st.restUntil = now + MISS_REST -- (a miss rests the hand a moment)
			return "miss", { hits = st.hits, zone = st.zone, width = st.width }
		end
		st.hits += 1
		if st.hits >= Config.BalanceHits then
			return "done", { grade = if st.misses == 0 then "Perfect" else "Good" }
		end
		newZone(st)
		return "hit", { hits = st.hits, zone = st.zone, width = st.width }
	end,
	help = function(s)
		s.state.width = math.min(0.9, s.state.width * Config.Minigame.HelpWiden)
	end,
	finish = function(s)
		local wheel = s.state.wheel
		wheel:SetAttribute("Balanced", true)
		for _, d in wheel:GetDescendants() do
			if d.Name:sub(1, 6) == "Issue_" then
				d:Destroy() -- the weight is back on the rim
			end
		end
		Remotes.Notify:FireClient(s.player, "n.balanced", nil, "good")
	end,
})

local function startBalance(player: Player)
	if MinigameService.active(player) then
		return -- already at it (E is also a tap key)
	end
	local wheel = CarryService.carried(player)
	if not wheel or wheel:GetAttribute("PartKind") ~= "Wheel" then
		return Remotes.Notify:FireClient(player, "n.bringWheel", nil, "info")
	end
	if wheel:GetAttribute("Balanced") then
		return Remotes.Notify:FireClient(player, "n.alreadyBalanced", nil, "info")
	end
	MinigameService.open(player, "Balance", { wheel = wheel, carId = wheel:GetAttribute("FromCar") })
end

-- the balancer screen's tap (its old time argument is ignored)
local function onTap(player: Player)
	MinigameService.input(player, nil, nil, "tap")
end

----------------------------------------------------------------------------------------------------------------
-- Stethoscope: where's that noise?
----------------------------------------------------------------------------------------------------------------
local function onListen(player: Player, car: any, point: any)
	if ToolKit.equipped(player) ~= "Stethoscope" or typeof(car) ~= "Instance" or typeof(point) ~= "Vector3" then
		return
	end
	if not car:IsA("Model") or car.Parent ~= workspace:FindFirstChild("Cars") then
		return
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root or (root.Position - point).Magnitude > Config.ReachDistance + 2 then
		return
	end
	-- the closest noisy slot to where the stethoscope touched
	local best, bestD = nil, Config.ListenRadius
	for _, slotName in CarParts.SlotOrder do
		local v = Faults.ById[FaultService.variantOf(car, slotName)]
		local part = CarFactory.slotPart(car, slotName)
		if v and v.noise and part and not FaultService.slotOK(car, slotName) then
			local d = (CarFactory.root(part).Position - point).Magnitude
			if d < bestD then
				best, bestD = { slot = slotName, noise = v.noise }, d
			end
		end
	end
	if best then
		DiagnosisService.addClue(car, "clue.listen." .. best.noise, { part = "@part." .. CarParts.Slots[best.slot].kind, slot = best.slot })
		CarService.touch(car, player) -- found a fault
		Remotes.Effect:FireAllClients("clue", { car = car, key = "clue.listen." .. best.noise, args = { part = "@part." .. CarParts.Slots[best.slot].kind }, sound = "", pos = point, quiet = true })
	else
		Remotes.Notify:FireClient(player, "n.quiet", nil, "info")
	end
end

----------------------------------------------------------------------------------------------------------------
-- OBD Reader: the trouble codes
----------------------------------------------------------------------------------------------------------------
function StationService.readCodes(car: Model, player: Player)
	if not EquipmentService.garageHas("OBDReader") then
		return Remotes.Notify:FireClient(player, "n.needObd", nil, "info")
	end
	local found = false
	for _, slotName in CarParts.SlotOrder do
		local v = Faults.ById[FaultService.variantOf(car, slotName)]
		if v and v.obd and not FaultService.slotOK(car, slotName) then
			found = true
			-- (a misfire's code names its cylinder: P030x -> P0302 for coil / plug 2)
			local code = v.obd:gsub("x$", slotName:match("_(%d)$") or "0")
			DiagnosisService.addClue(car, "clue.obd.code", { code = code, meaning = "@obd." .. v.obd })
		end
	end
	if not found then
		DiagnosisService.addClue(car, "clue.obd.none")
	end
	Remotes.Notify:FireClient(player, if found then "n.obdFound" else "clue.obd.none", nil, "info")
end

function StationService.start()
	Remotes.MinigameTap.OnServerEvent:Connect(Guard.wrap("Tap", 0.1, onTap))
	Remotes.Listen.OnServerEvent:Connect(Guard.wrap("Listen", 0.3, onListen))
	-- the balancer's prompt appears whenever the balancer is in the map (bought)
	local function hookBalancer()
		local spot = Places.find("Tools.WheelBalancer.UsePoint") :: BasePart?
		if spot and not spot:FindFirstChild("BalancePrompt") then
			local p = Instance.new("ProximityPrompt")
			p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
			p.Name = "BalancePrompt"
			p.KeyboardKeyCode = Enum.KeyCode.E
			p.MaxActivationDistance = Config.PromptDistance
			p.RequiresLineOfSight = false
			Locale.tag(p, "act.balance")
			Locale.tag(p, "equip.WheelBalancer", nil, "ObjectText")
			p.Parent = spot
			p.Triggered:Connect(Guard.prompt(p, "Balance", 0.5, startBalance))
		end
	end
	hookBalancer()
	return hookBalancer -- (Main calls it again when the map changes)
end

return StationService
