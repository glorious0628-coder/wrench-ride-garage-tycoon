-- "Clumsy is fine" (game_textbook 5): when several prompts are in reach, the one for what you're doing wins
-- instead of the nearest (Roblox shows only one prompt at a time: OneGlobally, any key).
--   1. the tutorial's current target (Tutorial.target)
--   2. carrying a part: its Install spots; other parts' Pick up are pushed back
--   3. a customer's car (after the tutorial too — test 2 TOP3: "Jack up the front" beat "Open hood" at the bumper,
--      "Hand back the keys" showed up before the fix): the prompts for where the job is now (jobFocus — the job card's
--      own stages): the hood / engine bay until the problem's found or when it's under the hood, that end's jack /
--      stands / wheels when the part sits at an end; Lower and Hand back win only once it's fixed
--   4. otherwise: a new part's Pick up before an old one's, then the nearest (Roblox's own rule)
-- and some never show (blocked, below): on a tutorial car the prompts its job never uses; Hand back while the car is
-- up (the server says "lower it first"); with a wrench in hand on a car not fixed yet: Lower (its card sat on the
-- bumper's lower bolts and a click there brought the car down: test 2 TOP1), and the hood / engine bay when the job is
-- at an end; someone else's quick job (prompt attribute OnlyFor, wr-dev CurbService).
-- Local only: a losing prompt gets MaxActivationDistance 0 on this screen and its own distance back afterwards.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarParts = require(ReplicatedStorage.Shared.CarParts)

local PromptFocus = {}

PromptFocus.target = function(): Instance?
	return nil
end -- set by the client entry (the tutorial's target)
PromptFocus.held = function(): Instance?
	return nil
end -- set by the client entry (Carry.held)

local player = Players.LocalPlayer
local prompts: { [ProximityPrompt]: number } = {} -- every E prompt -> its own MaxActivationDistance
local muted: { [ProximityPrompt]: boolean } = {}

local function track(d: Instance)
	if d:IsA("ProximityPrompt") and not prompts[d] then
		prompts[d] = d.MaxActivationDistance
	end
end

local function where(p: ProximityPrompt): Vector3?
	local a = p.Parent
	if a and a:IsA("Attachment") then
		return a.WorldPosition
	elseif a and a:IsA("BasePart") then
		return a.Position
	end
	return nil
end

local function partOf(p: ProximityPrompt): Instance?
	local n: Instance? = p.Parent
	while n and not n:GetAttribute("PartKind") do
		n = n.Parent
	end
	return n
end

local function carOf(p: ProximityPrompt): Model?
	local cars = workspace:FindFirstChild("Cars")
	if not cars or not p:IsDescendantOf(cars) then
		return nil
	end
	local car: Instance = p
	while car.Parent ~= cars do
		car = car.Parent :: Instance
	end
	return if car:IsA("Model") then car else nil
end

local function tutorialOn(): number?
	local tut = player:GetAttribute("Tut") :: number?
	if tut == nil or tut >= 4 or player:GetAttribute("TutSkip") then
		return nil
	end
	return tut
end

-- where this car's job is: "done" (fixed), "F" / "R" (the part found sits at that end: its jack, stands, wheels),
-- "hood" (not found yet, or found under the hood) — the job card's stages (JobCard.stageOf)
local function jobFocus(car: Model): string
	if car:GetAttribute("Fixed") == true then
		return "done"
	end
	local faults = {}
	for _, slot in string.split((car:GetAttribute("Faults") :: string?) or "", ",") do
		faults[slot] = true
	end
	local ok, list = pcall(HttpService.JSONDecode, HttpService, (car:GetAttribute("Clues") :: string?) or "[]")
	for _, clue in (if ok and type(list) == "table" then list else {}) do
		local slot = type(clue) == "table" and clue.a and clue.a.slot
		if slot and faults[slot] then
			return CarParts.endOf(slot) or "hood"
		end
	end
	-- no clue yet but an end already on its stands: the work is there (wr-dev: a pad job started from the customer's
	-- "squeal" alone — a wheel lying by the car won the F back into the wheel view)
	local support = (car:GetAttribute("Support") :: string?) or "None"
	local up = support:match("^Stands(%u)$")
	if up then
		return up
	end
	return "hood"
end

-- the car end a jack / stand / wheel prompt belongs to ("F" / "R"), else nil
local function endOf(p: ProximityPrompt): string?
	local at = p.Parent and p.Parent.Name or ""
	return at:match("^Jack_(%u)") or at:match("^Stand_(%u)") or at:match("^Work_Wheel_(%u)")
end

PromptFocus.jobFocus = jobFocus -- (WorkViewUI: the wheel view's Lower button waits for the fix at the job's end)

local function holdingWrench(): boolean
	local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
	return tool ~= nil and (tool.Name == "Wrench" or tool.Name == "ImpactWrench" or tool.Name == "RatchetWrench")
end

local function jobScore(p: ProximityPrompt): number
	-- the mini-game step that blocks the hand-back (wr-mini's MinigameService): it wins over the car's other prompts, which hid it
	if p.Name == "MgStepPrompt" then
		return 40
	end
	local car = carOf(p)
	if not car then
		-- the garage's own spots (parts counter, toolbox, desk, ...) stand level with a job's car prompts, so the nearest
		-- of them wins: walking past bay 1 to the counter, E opened that car's hood (wr-gamer fun 1 ⑦). A part lying
		-- about stays below them.
		local loose = p.Name == "PickupPrompt" or p.Name == "SellPrompt"
		return if loose then 0 else 20
	end
	if car:GetAttribute("CurbJob") or not car:GetAttribute("Parked") then
		return 0
	end
	-- the hand fix of a fault still on the car (FaultService FixPrompt on its Issue_* mark: the terminals' scrub, the light
	-- scratch's polish): over the hood / work-view prompts beside it (20), which hid it — under the blocking mini-game step
	-- (40). The terminals only once the hood is up (wr-mini integration test 1, GPT)
	if p.Name == "FixPrompt" and p.Parent and p.Parent.Name:sub(1, 6) == "Issue_" then
		local battery = p.Parent.Name:find("Battery", 1, true) ~= nil
		if not battery or car:GetAttribute("HoodOpen") == true then
			return 25
		end
	end
	local focus = jobFocus(car)
	-- Lower / Hand back step back until it's fixed — the tutorial's cars too (test 2 TOP9: "Lower car" hid "Work on
	-- wheel" beside the stands on the third car)
	if p.Name == "ReleasePrompt" then
		return if focus == "done" then 20 else -20
	end
	if p.Name == "LowerPrompt" then
		-- (up at the wrong end — nothing to fix there: lowering it is the way back, GPT test2_ui r1)
		return if focus == "done" then 20 elseif focus == endOf(p) then -20 else 10
	end
	local tut = tutorialOn()
	if tut and car:GetAttribute("Tutorial") == tut then
		return 0 -- (the tutorial leads its own car: its target, unused)
	end
	local at = p.Parent and p.Parent.Name or ""
	if focus == "hood" and (p.Name == "HoodPrompt" or at == "Work_EngineBay") then
		return 20
	end
	local e = endOf(p)
	if e and e == focus then
		return 20
	end
	return 0
end

-- never shown now, whatever else is in reach
local function blocked(p: ProximityPrompt): boolean
	local only = p:GetAttribute("OnlyFor")
	if only ~= nil and only ~= player.UserId then
		return true
	end
	-- the scrap bin with empty hands does nothing: it beat the toolbox beside it (wr-gamer a18)
	if p.Name == "ScrapPrompt" and not PromptFocus.held() then
		return true
	end
	local car = carOf(p)
	if not car then
		return false
	end
	if p.Name == "ReleasePrompt" then
		local up = ((car:GetAttribute("LiftOffset") :: number?) or 0) > 0.05
		local support = (car:GetAttribute("Support") :: string?) or "None"
		return up or support ~= "None"
	end
	if p.Name == "LowerPrompt" then
		return holdingWrench() and car:GetAttribute("Fixed") ~= true and jobFocus(car) == endOf(p)
	end
	-- (wrench in hand on a job at an end — the bumper, a wheel: the bolts are the work, no hood card over them)
	if p.Name == "HoodPrompt" or (p.Parent and p.Parent.Name == "Work_EngineBay") then
		local focus = if holdingWrench() and not tutorialOn() then jobFocus(car) else nil
		return focus == "F" or focus == "R"
	end
	return false
end

local function isTarget(p: ProximityPrompt, target: Instance?): boolean
	return target ~= nil and (p.Parent == target or p:IsDescendantOf(target) or (target.Parent ~= nil and target.Parent:IsA("Model") and p:IsDescendantOf(target.Parent)))
end

local function score(p: ProximityPrompt, target: Instance?, held: Instance?): number
	local s = jobScore(p)
	if isTarget(p, target) then
		s += 100
	end
	if held then
		if p.Name == "InstallPrompt" then
			s += 50
		elseif p.Name == "PickupPrompt" then
			s -= 50
		end
	elseif p.Name == "PickupPrompt" then
		local part = partOf(p)
		if part and ((part:GetAttribute("Condition") :: number?) or 100) >= 50 then
			s += 5 -- a new part before an old one
		end
	end
	return s
end

-- the tutorial's cars: the car prompts a job never uses stay quiet the whole job, so the one that matters is the only
-- one by the car even on steps without a target (test 1 #10: "Open hood" and "Jack up the front" sat side by side on
-- the first car and the jack went up). Job 1 = the battery (no jack, stands or wheels); jobs 2 and 3 = the front-left
-- wheel (no hood, no engine bay, nothing at the back or on the other wheels).
local function unused(p: ProximityPrompt): boolean
	local tut = tutorialOn()
	if tut == nil then
		return false
	end
	local car = carOf(p)
	if not car or car:GetAttribute("Tutorial") ~= tut then
		return false
	end
	local at = p.Parent and p.Parent.Name or ""
	if tut == 1 then
		return at:match("^Jack_") ~= nil or at:match("^Stand_") ~= nil or at:match("^Work_Wheel_") ~= nil
	end
	return p.Name == "HoodPrompt" or at == "Work_EngineBay" or at:match("^Jack_R") ~= nil or at:match("^Stand_R") ~= nil
		or (at:match("^Work_Wheel_") ~= nil and at ~= "Work_Wheel_FL")
end

local function update()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end
	local target, held = PromptFocus.target(), PromptFocus.held()
	-- the E prompts in reach right now (with their own distances)
	local near = {}
	for p, dist in prompts do
		if not p.Parent then
			prompts[p], muted[p] = nil, nil
			continue
		end
		local pos = where(p)
		if p.Enabled and pos and (pos - root.Position).Magnitude <= dist and not unused(p) and (isTarget(p, target) or not blocked(p)) then
			table.insert(near, { p = p, d = (pos - root.Position).Magnitude, s = score(p, target, held) })
		end
	end
	local best = nil
	for _, n in near do
		if not best or n.s > best.s or (n.s == best.s and n.d < best.d) then
			best = n
		end
	end
	local keep: { [ProximityPrompt]: boolean } = {}
	for _, n in near do
		-- exactly one prompt stays: the card (PromptUI) shows the last one Roblox showed and E triggers every shown prompt of
		-- that key, so two shown at once (equal scores, one OnePerButton and one OneGlobally, E beside F) made the card say
		-- "Buy parts" while E picked up the old battery (wr-play eval TOP 1, 10-23). A tie goes to the nearer one.
		if best and n ~= best then
			keep[n.p] = false
		end
	end
	for p, dist in prompts do
		local mute = keep[p] == false or unused(p) or (blocked(p) and not isTarget(p, target)) -- (the tutorial's target always shows)
		if mute and not muted[p] then
			muted[p] = true
			p.MaxActivationDistance = 0
		elseif not mute and muted[p] then
			muted[p] = nil
			p.MaxActivationDistance = dist
		end
	end
end

function PromptFocus.start()
	workspace.DescendantAdded:Connect(track)
	for _, d in workspace:GetDescendants() do
		track(d)
	end
	task.spawn(function()
		while true do
			pcall(update)
			task.wait(0.07) -- (a prompt that lost is gone within ~4 frames: a press right as the walk changes the winner hit the old one)
		end
	end)
end

return PromptFocus
