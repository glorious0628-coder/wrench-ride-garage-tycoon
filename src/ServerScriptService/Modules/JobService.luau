-- A customer's job on a car: done = every slot has a part with every bolt tight. Then a "Hand car back" prompt
-- appears on the car; pressing it (lift down) pays out (docs/design/economy.md v0.2 §2-1, §3):
--   customer pays: parts x 1.3 (back to whoever bought each part) + labor (by garage level) x faults fixed + tips
--   (fast $80, "Spot On!" +15% of labor, the tutorial customer $150).
--   Labor + tips: everyone who did a work unit gets Config.CoopShare[players] of it each ("Team pay $X each").
--   Reputation (only adds): +10 per fault fixed, +3 Spot On, +2 fast; a fault left in = no rep for it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local FaultService = require(script.Parent.FaultService)
local PlayerData = require(script.Parent.PlayerData)
local Metrics = require(script.Parent.Metrics)
local StoreService = require(script.Parent.StoreService)
local Guard = require(script.Parent.Guard)
local Faults = require(ReplicatedStorage.Shared.Faults)

local JobService = {}

export type Line = { key: string, money: number, n: number?, stars: number? } -- stars: the car's ★ (Labor line)
export type Result = { fixed: number, unfixed: number, money: number, rep: number, tip: boolean, happy: boolean, spotOn: boolean, first: boolean, kinds: { string }, players: { Player }, paid: { [Player]: number }, lines: { [Player]: { Line } }, full: { [Player]: boolean } }

-- set by CustomerService: the customer's patience stage right now (Calm / Restless / Upset)
JobService.stageOf = nil :: ((car: Model) -> string)?

-- set by CustomerService: the customer takes the car away after payment
JobService.onReleased = nil :: ((car: Model, result: Result) -> ())?
JobService.onTutorial = nil :: ((car: Model, workers: { Player }) -> ())? -- TutorialService.released
JobService.onProof = nil :: ((car: Model, kind: string) -> ())? -- CustomerService: the customer reacts, the car shakes
-- MinigameService (set by Main): a mini-game step still waiting on the car (its notice key), and what's left of a
-- player's tip cap on it (their star-pattern tip is trimmed to it)
JobService.waitFor = nil :: ((car: Model, player: Player) -> string?)?
JobService.tipRoom = nil :: ((car: Model, p: Player) -> number)?

local started: { [Model]: number } = {}
local originals: { [Model]: { [string]: Instance } } = {} -- the parts the car came in with, per slot
local firstJob: { [Model]: boolean } = {}
local releasePrompt: (car: Model) -> ProximityPrompt

function JobService.begin(car: Model, isFirst: boolean?)
	started[car] = os.clock()
	firstJob[car] = isFirst == true
	originals[car] = {}
	for _, slotName in CarParts.SlotOrder do
		local p = CarFactory.slotPart(car, slotName)
		if p then
			originals[car][slotName] = p
		end
	end
	car:SetAttribute("Ready", false)
	releasePrompt(car)
end

-- every slot filled and every bolt tight
function JobService.assembled(car: Model): boolean
	local own = CarParts.type(car:GetAttribute("CarType") :: string?).Slots
	for _, slotName in CarParts.SlotOrder do
		if not own[slotName] then
			continue -- (a slot this type hasn't got: piece E's new parts on a car whose bay isn't live)
		end
		local part = CarFactory.slotPart(car, slotName)
		if not part or (part:GetAttribute("BoltsRemaining") :: number) < (part:GetAttribute("BoltCount") :: number) then
			return false
		end
	end
	return true
end

function releasePrompt(car: Model): ProximityPrompt
	local chassis = car.PrimaryPart :: BasePart
	local p = chassis:FindFirstChild("ReleasePrompt") :: ProximityPrompt?
	if not p then
		local np = Instance.new("ProximityPrompt")
		np.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
		np.Name = "ReleasePrompt"
		np.KeyboardKeyCode = Enum.KeyCode.F
		np.HoldDuration = 0.6
		np.MaxActivationDistance = 12
		np.RequiresLineOfSight = false
		np.Enabled = false
		Locale.tag(np, "act.release")
		np.Parent = chassis
		np.Triggered:Connect(Guard.prompt(np, "Release", 1, function(player)
			JobService.release(car, player)
		end))
		p = np
	end
	return p :: ProximityPrompt
end

-- after any part change: the prompt shows only while the car is complete
function JobService.check(car: Model)
	if not started[car] then
		return
	end
	local ready = JobService.assembled(car)
	local was = car:GetAttribute("Ready") == true
	car:SetAttribute("Ready", ready)
	-- every fault the car came in with is gone (the job card's before / after buttons)
	local fixed = ready
	for _, slotName in string.split((car:GetAttribute("Faults") :: string?) or "", ",") do
		if CarParts.Slots[slotName] and not FaultService.slotOK(car, slotName) then
			fixed = false
		end
	end
	car:SetAttribute("Fixed", fixed)
	local rp = releasePrompt(car)
	rp.Enabled = ready
	-- handing a car back still broken is a way out, not the next step: its own words and a long hold, so one E (or a
	-- tap) in the wrong spot can't send it off (user 10-23 "열쇠 돌려주기" at the back of a car with its fault left)
	local wantKey = if fixed then "act.release" else "act.releaseUnfixed"
	if rp:GetAttribute("Loc_ActionText") ~= wantKey then
		Locale.tag(rp, wantKey)
	end
	rp.HoldDuration = if fixed then 0.6 else 1.5
	if ready and not was then
		for _, p in CarService.helpers(car) do
			Remotes.Notify:FireClient(p, "n.carReady", nil, "good")
		end
	end
end

-- the moment the symptom goes away (game_textbook: before the money): the car starts / the brakes are quiet,
-- with the before -> after sounds. Skipped when the players already saw it (they tried it themselves).
local releasing: { [Model]: boolean } = {}
local function proofKind(car: Model): string?
	if car:GetAttribute("Fixed") ~= true then
		return nil -- not fixed: no "it works now"
	end
	local slot = string.split((car:GetAttribute("Faults") :: string?) or "", ",")[1]
	local kind = slot and CarParts.Slots[slot] and CarParts.Slots[slot].kind
	local clues = (car:GetAttribute("Clues") :: string?) or ""
	if car:GetAttribute("Tutorial") == 3 then
		return kind -- the tutorial's whodunit always shows its answer working (and why: Tutorial.luau)
	end
	if kind == "BrakePads" and clues:find('"clue.brake.ok"', 1, true) then
		return nil
	end
	if kind ~= "BrakePads" and clues:find('"clue.start.ok"', 1, true) then
		return nil
	end
	return kind
end

function JobService.release(car: Model, player: Player)
	if not started[car] or not JobService.assembled(car) then
		return Remotes.Notify:FireClient(player, "n.notDone", nil, "bad")
	end
	if ((car:GetAttribute("LiftOffset") :: number?) or 0) > 0.05 then
		return Remotes.Notify:FireClient(player, "n.lowerLift", nil, "bad")
	end
	local step = JobService.waitFor and JobService.waitFor(car, player) -- (a mini-game step left: torque / tire / coolant)
	if step then
		return Remotes.Notify:FireClient(player, step, nil, "info")
	end
	if releasing[car] then
		return
	end
	-- the hood goes down by itself: a car drove off with it up (wr-play eval TOP 7). Not under a partner who's still in the
	-- engine bay's view.
	if car:GetAttribute("HoodOpen") == true then
		local busy = false
		for _, p in Players:GetPlayers() do
			if p:GetAttribute("WorkCar") == car:GetAttribute("CarId") and p:GetAttribute("WorkZone") == "EngineBay" then
				busy = true
			end
		end
		if not busy then
			releasing[car] = true -- (a second press during the swing waits)
			CarService.toggleHood(car, nil)
			task.wait(0.6) -- (the swing is seen before it starts / drives off)
			releasing[car] = nil
			if not car.Parent or not started[car] then
				return
			end
		end
	end
	local kind = proofKind(car)
	if kind then
		releasing[car] = true
		releasePrompt(car).Enabled = false
		Remotes.Effect:FireAllClients("proof", { car = car, kind = kind })
		Metrics.markAll(CarService.helpers(car), "firstChange")
		if JobService.onProof then
			task.spawn(JobService.onProof, car, kind)
		end
		task.wait(Config.ProofSeconds)
		releasing[car] = nil
		if not car.Parent or not started[car] then
			return
		end
	end
	local faults = string.split((car:GetAttribute("Faults") :: string?) or "", ",")
	local faultSet = {}
	local fixed, unfixed = 0, 0
	local kinds = {}
	local partsMoney: { [number]: number } = {} -- userId of the buyer -> price x 1.3 back (economy §3)
	local partsLoose = 0 -- parts money with no buyer here (the car's own good part re-fitted, buyer gone)
	-- the same money by part kind, for the settlement card's lines: userId (0 = loose) -> kind -> { n, money }
	local partsByKind: { [number]: { [string]: { n: number, money: number } } } = {}
	local function addKind(who: number, kindName: string, money: number)
		local byKind = partsByKind[who] or {}
		partsByKind[who] = byKind
		local k = byKind[kindName] or { n = 0, money = 0 }
		byKind[kindName] = k
		k.n += 1
		k.money += money
	end
	for _, slotName in faults do
		local slot = CarParts.Slots[slotName]
		if slot then
			faultSet[slotName] = true
			local part = CarFactory.slotPart(car, slotName)
			local v = Faults.ById[FaultService.variantOf(car, slotName)]
			if not FaultService.slotOK(car, slotName) then
				unfixed += 1
			else
				fixed += 1
				table.insert(kinds, slot.kind)
				-- a trap fixed by hand (clean / polish / hang) has no part to pay for: labor only — and a part nobody
				-- bought (pulled off another customer's car) isn't paid as parts either (exploit audit H3): labor only
				local buyer = part and part:GetAttribute("BoughtBy") :: number?
				local back = if (v and v.fix ~= "replace") or not buyer then 0 else math.floor(CarParts.Kinds[slot.kind].price * Config.PartsMarkup)
				if buyer and Players:GetPlayerByUserId(buyer) then
					partsMoney[buyer] = (partsMoney[buyer] or 0) + back
				else
					partsLoose += back
				end
				if back > 0 then
					addKind(if buyer and Players:GetPlayerByUserId(buyer) then buyer else 0, slot.kind, back)
				end
			end
		end
	end
	-- "Spot On!": nothing healthy was swapped out
	local wasted = 0
	for slotName, orig in originals[car] or {} do
		local v = Faults.ById[FaultService.variantOf(car, slotName)]
		local wasWorn = faultSet[slotName] and not (v and v.fix ~= "replace")
		if CarFactory.slotPart(car, slotName) ~= orig and not wasWorn then
			wasted += 1
		end
	end
	local level = PlayerData.garageLevel()
	local labor = 0
	for _, row in Config.LaborByLevel do
		if level <= row.upTo then
			labor = row.labor
			break
		end
	end
	local spotOn = unfixed == 0 and wasted == 0
	-- the customer's mood tip (alpha_scope §1-1: replaces the old one-off fast tip); a fault left in = no tip
	local kindName = (car:GetAttribute("CustomerKind") :: string?) or "Regular"
	local kind = Config.CustomerKinds[kindName] or Config.CustomerKinds.Regular
	local stage = if JobService.stageOf then JobService.stageOf(car) else "Calm"
	local fast = unfixed == 0 and stage == "Calm" -- (the first job counts as calm: Rep 15 >= 12 = straight to Lv2)
	local moodTip = if unfixed == 0 and not car:GetAttribute("NoPatience") then (kind.tips[stage] or 0) else 0
	local first = firstJob[car] == true and unfixed == 0
	-- (a car with stars — Config.Features.Stars: each fixed fault counts its labor units, car_difficulty §4)
	local starCar = car:GetAttribute("Stars") ~= nil
	local units = fixed
	if starCar then
		units = 0
		for _, slotName in faults do
			if faultSet[slotName] and FaultService.slotOK(car, slotName) then
				units += FaultService.luOf(slotName)
			end
		end
	else
		-- (a fault row's laborMult — E2: the strut and the rear spring take 1.5 a job's labor, full_teardown §0-2)
		units = 0
		for _, slotName in faults do
			if faultSet[slotName] and FaultService.slotOK(car, slotName) then
				local v = Faults.ById[FaultService.variantOf(car, slotName)]
				units += (v and v.laborMult) or 1
			end
		end
	end
	local laborMoney = math.floor(labor * units * (kind.laborMult or 1))
	local stars = 0
	for _, corner in { "FL", "FR", "RL", "RR" } do
		local w = CarFactory.slotPart(car, "Wheel_" .. corner)
		if w and w:GetAttribute("StarOrder") and w ~= (originals[car] or {})["Wheel_" .. corner] then
			stars += 1
		end
	end
	local tips = moodTip + (if spotOn then math.floor(laborMoney * Config.SpotOnPct) else 0) + (if first then Config.FirstJobTip else 0) + stars * Config.StarTip
	local faultRep = math.floor(Config.Rep.PerFault * units + 0.5)
	local rep = if unfixed == 0 then faultRep + (if spotOn then Config.Rep.SpotOn else 0) + (if fast then Config.Rep.Fast else 0) else Config.Rep.Unfixed + faultRep
	started[car] = nil
	originals[car] = nil
	firstJob[car] = nil
	releasePrompt(car).Enabled = false
	car:SetAttribute("Ready", false)

	-- who gets paid: everyone who did a work unit on it (took a part off, put one on, found a fault)
	local helpers = CarService.helpers(car)
	local workers = table.clone(helpers) -- (who really worked on it: the tutorial moves only them on)
	if #helpers == 0 then
		helpers = { player }
	end
	local share = Config.CoopShare[math.min(#helpers, #Config.CoopShare)]
	local each = math.floor((laborMoney + tips) * share)
	local key = if unfixed > 0 then "n.paidUnfixed" elseif #helpers > 1 then "n.paidTeam" elseif spotOn then "n.paidSpotOn" elseif fast then "n.paidTip" else "n.paid"
	local paid: { [Player]: number } = {}
	local lines: { [Player]: { Line } } = {}
	local full: { [Player]: boolean } = {}
	local spotOnMoney = if spotOn then math.floor(laborMoney * Config.SpotOnPct) else 0
	local tutorialCar = car:GetAttribute("Tutorial") ~= nil
	for i, p in helpers do
		local mine = each + (partsMoney[p.UserId] or 0) + (if i == 1 then partsLoose else 0)
		-- the settlement card's lines (first10_payout §3, invoice order): Labor ×fixed → the parts I bought, one line a
		-- kind → Spot On → Star pattern → Tip → First job. Each is my share; what the rounding leaves goes on Labor, so
		-- the lines add up to `mine`
		-- (mini-games on: my star-pattern tip + my Perfect tips on this car stay under one cap — tipRoom, MinigameService)
		local starMine = math.floor(stars * Config.StarTip * share)
		local trim = if JobService.tipRoom then math.max(0, starMine - JobService.tipRoom(car, p)) else 0
		mine -= trim
		local bonus: { Line } = {
			{ key = "pay.spotOn", money = math.floor(spotOnMoney * share) },
			{ key = "pay.star", money = starMine - trim },
			{ key = "pay.tip", money = math.floor(moodTip * share) },
			{ key = "pay.first", money = math.floor((if first then Config.FirstJobTip else 0) * share) },
		}
		local laborLine = each - trim
		for _, l in bonus do
			laborLine -= l.money
		end
		local list: { Line } = {}
		-- the first car's diagnosis (whoever found the dead battery — DiagnosisService): its own line out of the labor,
		-- paid with everything else here (user 10-22: one settlement — the money in all stays the same)
		local diag = if car:GetAttribute("DiagBy") == p.UserId then Config.DiagnosisFee else 0
		if diag > 0 and laborLine > diag then
			table.insert(list, { key = "pay.diag", money = diag })
			laborLine -= diag
		else
			diag = 0
		end
		if laborLine > 0 then
			table.insert(list, { key = "pay.labor", money = laborLine, n = fixed, stars = car:GetAttribute("Stars") :: number? })
		end
		local mineByKind: { [string]: { n: number, money: number } } = {}
		for _, who in { p.UserId, if i == 1 then 0 else -1 } do
			for kindName, k in partsByKind[who] or {} do
				local m = mineByKind[kindName] or { n = 0, money = 0 }
				mineByKind[kindName] = m
				m.n += k.n
				m.money += k.money
			end
		end
		local partLines: { Line } = {}
		for kindName, m in mineByKind do
			table.insert(partLines, { key = "part." .. kindName, money = m.money, n = m.n })
		end
		table.sort(partLines, function(a, b)
			return a.money > b.money
		end)
		for _, l in partLines do
			table.insert(list, l)
		end
		for _, l in bonus do
			if l.money > 0 then
				table.insert(list, l)
			end
		end
		-- Pay Boost (game pass, StoreService): my labor + tips share x 1.5 — its own line, the parts money never
		-- a coffee I gave this customer (CoffeeService): its own tip line, on top (Config.CoffeeTip)
		if car:GetAttribute("CoffeeBy") == p.UserId and Config.feature("Coffee") and unfixed == 0 then -- (a fixed car only: no tip farming on hand-backs — API review)
			table.insert(list, { key = "pay.coffee", money = Config.CoffeeTip })
			mine += Config.CoffeeTip
		end
		local boost = StoreService.boost(p, each - trim) -- (my share after the tip cap)
		if boost > 0 then
			table.insert(list, { key = "pay.boost", money = boost })
			mine += boost
		end
		-- what I paid at the counter for the parts this job used (already taken from my money then — not part of `mine`):
		-- the card shows it as a grey minus line and the profit under it (user 10-22: "subtract the bought battery")
		local cost = 0
		for kindName, k in partsByKind[p.UserId] or {} do
			cost += CarParts.Kinds[kindName].price * k.n
		end
		if cost > 0 then
			table.insert(list, { key = "pay.bought", money = -cost })
		end
		lines[p] = list
		-- the line card (not the short banner): the tutorial's three cars, the first job, and the first time a Star
		-- pattern or a Team pay shows up for this player (each checked on its own: both get marked seen)
		local newStar = bonus[2].money > 0 and PlayerData.firstTime(p, "payStar")
		local newTeam = #helpers > 1 and PlayerData.firstTime(p, "payTeam")
		full[p] = first or (tutorialCar and (PlayerData.tut(p) or 4) < 4) or newStar or newTeam
		partsMoney[p.UserId] = nil
		paid[p] = mine
		PlayerData.addMoney(p, mine)
		PlayerData.addRep(p, rep)
		if unfixed == 0 then
			PlayerData.markFirstJob(p)
			PlayerData.recordJob(p, (car:GetAttribute("CarType") :: string?) or "Sedan")
		end
		Remotes.Notify:FireClient(p, key, { money = mine, rep = rep }, if unfixed > 0 then "bad" else "good")
	end
	-- the coffee from someone who didn't otherwise work on it: their tip still comes
	local coffeeBy = car:GetAttribute("CoffeeBy") :: number?
	local giver = coffeeBy and Players:GetPlayerByUserId(coffeeBy)
	if giver and Config.feature("Coffee") and unfixed == 0 and not table.find(helpers, giver) then
		PlayerData.addMoney(giver, Config.CoffeeTip)
		Remotes.Notify:FireClient(giver, "n.coffeeTip", { money = Config.CoffeeTip }, "good")
	end
	-- a part bought by someone who didn't otherwise work on it: they still get their parts money back
	for userId, back in partsMoney do
		local p = Players:GetPlayerByUserId(userId)
		if p then
			PlayerData.addMoney(p, back)
			Remotes.Notify:FireClient(p, "n.partsBack", { money = back }, "good")
		end
	end
	CarService.forget(car)
	local result: Result = { fixed = fixed, unfixed = unfixed, money = each, rep = rep, tip = fast, happy = unfixed == 0, spotOn = spotOn, first = first, kinds = kinds, players = helpers, paid = paid, lines = lines, full = full }
	JobService.last = result -- (play tests read the settlement)
	if JobService.onTutorial and car:GetAttribute("Tutorial") then
		JobService.onTutorial(car, workers) -- (only real work units: not the hand-back alone)
	end
	if JobService.onReleased then
		JobService.onReleased(car, result)
	end
end

return JobService
