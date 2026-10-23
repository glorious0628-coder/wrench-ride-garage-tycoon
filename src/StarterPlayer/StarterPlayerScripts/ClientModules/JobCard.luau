-- The job card (top right) for the customer car you're near: on top the job's steps (a bar that starts a little
-- filled — the customer is already checked in — then "1/3 Find the problem" and the one next thing to do), under it
-- what the customer said, a first-job tip, every clue found so far (from the car's "Clues" attribute, shared by
-- everyone), and — once it's all bolted up — the before / after buttons (fun_boost #4). Plus the "JOB DONE" card.
-- UI B look (UIKit plate). (tycoon_analysis: one step + one next action; a head-start bar is finished more often)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Diagnosis = require(ReplicatedStorage.Shared.Diagnosis)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)
local MidnightClock = require(script.Parent.MidnightClock)
local SoundPlayer = require(script.Parent.SoundPlayer)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local JobCard = {}
JobCard.Scan = Instance.new("BindableEvent") -- (car) the Scan button was pressed
JobCard.PayClosed = Instance.new("BindableEvent") -- the settlement line card's Nice! (the next card can come now)

local player = Players.LocalPlayer
local card: CanvasGroup
local body: TextLabel
local compareRow: Frame
local steps: Frame
local stepLabel: TextLabel
local nextLabel: TextLabel
local car: Model? = nil
local lastSig = ""
local scanRow: Frame
local scanButton: GuiButton
local finalButton: GuiButton
local tryRow: Frame -- "Try starting it" / "Press the brake" (wr-dev: the door prompts are gone — Remotes.TryCar)
local compact = false -- (work screen: steps + next action only)
local refit: (() -> ())? = nil
local bannerUntil = 0 -- the card steps aside while the JOB DONE banner shows
local clock: MidnightClock.Chip -- Ella's midnight clock (halloween_pumpkin §4): the car's "Midnight" attribute
local clockShown: number? = nil
local bodyNoTip: string? = nil -- the card's text without the tip line: used when the tip would run the text out of the box
local tipDropped = false

local function label(parent: Instance, name: string, size: UDim2, textSize: number): TextLabel
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size
	l.BackgroundTransparency = 1
	l.FontFace = UIStyle.Font.Body
	l.TextSize = textSize
	l.TextColor3 = UIStyle.Color.White
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.TextWrapped = true
	l.RichText = true
	l.Parent = parent
	return l
end

local function nearestCar(): Model?
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
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
	return best
end

local function esc(s: string): string
	return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- the fixed kinds of this car (for the before / after pair): the faults list
local function faultKind(c: Model): string?
	local first = string.split((c:GetAttribute("Faults") :: string?) or "", ",")[1]
	local slot = first and CarParts.Slots[first]
	return slot and slot.kind
end

-- this slot's part (or one of its bolts) can only be worked with its end up on stands (Requires "Lift:Wheel"), and
-- the car isn't there yet: "F" / "R", else nil (the front bumper's two lower bolts — test 2 TOP1)
local function liftNeeded(c: Model, slotName: string): string?
	local e = CarParts.endOf(slotName)
	if not e then
		return nil
	end
	local need = false
	local slot = CarParts.Slots[slotName]
	for _, r in (slot and slot.requires) or {} do
		need = need or r == "Lift:Wheel"
	end
	for _, d in c:GetDescendants() do
		if need then
			break
		end
		if d:GetAttribute("Slot") == slotName and d:GetAttribute("PartKind") then
			for _, a in d:GetDescendants() do
				local req = a:GetAttribute("Requires")
				if type(req) == "string" and req:find("Lift:Wheel", 1, true) then
					need = true
					break
				end
			end
		end
	end
	if not need then
		return nil
	end
	local liftUp = c:GetAttribute("LiftEnd") == nil and ((c:GetAttribute("LiftOffset") :: number?) or 0) > 1 -- (a real lift)
	if liftUp or c:GetAttribute("Support") == "Stands" .. e then
		return nil
	end
	return e
end

-- the mini-game step a fixed car still waits for (MinigameService's car attribute MgStep, wr-dev: "Torque" | "Tire" |
-- "Coolant", nil = none): the nuts torqued / the new tire filled / the coolant topped up still belong to "Fix it"
local MG_STEP = { Torque = "mg.torque.prompt", Tire = "mg.tire.prompt", Coolant = "mg.coolant.prompt" }
local function mgStepOf(c: Model): string?
	local kind = c:GetAttribute("MgStep")
	return if c:GetAttribute("Fixed") == true and type(kind) == "string" then MG_STEP[kind] else nil
end

-- where the job is: 1 find the problem, 2 fix it, 3 hand it back — and the one thing to do next.
-- (step 1 never names the part: finding it is the game)
local function stageOf(c: Model): (number, string, { [string]: any }?)
	local mg = mgStepOf(c)
	if mg then
		return 2, mg, nil
	end
	if c:GetAttribute("Fixed") == true then
		return 3, "ui.job.handBack", nil
	end
	local faults = {}
	for _, slot in string.split((c:GetAttribute("Faults") :: string?) or "", ",") do
		faults[slot] = true
	end
	local ok, list = pcall(HttpService.JSONDecode, HttpService, (c:GetAttribute("Clues") :: string?) or "[]")
	list = if ok and type(list) == "table" then list else {}
	for _, clue in list do
		local slot = clue.a and clue.a.slot
		local info = slot and faults[slot] and CarParts.Slots[slot]
		if info then
			local e = liftNeeded(c, slot)
			if e then
				return 2, if e == "F" then "ui.job.liftFront" else "ui.job.liftRear", nil -- (up on stands first)
			end
			return 2, "ui.job.swap", { part = "@part." .. info.kind }
		end
	end
	return 1, if #list == 0 then "ui.job.tryCar" else "ui.job.scan", nil
end

local SEG_DONE, SEG_NOW, SEG_LATER = UIStyle.Color.Green, UIStyle.Color.Yellow, UIStyle.Color.PlateEdge

-- the tutorial inside a work view: its strip already says what's next — the card shows only for its button (Scan /
-- Final check), so the car has the screen (GPT workview_phone r1)
local function quietInWork(): boolean
	if not compact or (scanRow and scanRow.Visible) then
		return false
	end
	local tut = player:GetAttribute("Tut") :: number?
	return tut ~= nil and tut < 4 and not player:GetAttribute("TutSkip")
end

local function refresh()
	car = nearestCar()
	if not car or os.clock() < bannerUntil then
		card.Visible = false
		lastSig = ""
		return
	end
	local sig = tostring(car:GetAttribute("CarId")) .. (car:GetAttribute("Clues") or "") .. tostring(car:GetAttribute("Fixed")) .. tostring(car:GetAttribute("Stage"))
		.. tostring(car:GetAttribute("Midnight")) .. tostring(car:GetAttribute("FinalChecked")) .. tostring(car:GetAttribute("Scanned"))
		.. tostring(car:GetAttribute("Support")) .. tostring(((car:GetAttribute("LiftOffset") :: number?) or 0) > 1) -- (up on stands: the next step changes)
		.. tostring(car:GetAttribute("MgStep"))
		.. tostring(player:GetAttribute("Tut")) .. tostring(player:GetAttribute("TutSkip")) -- (Skip / the last tutorial car: the full card at once)
		.. tostring(UIKit.size().Y < 500) -- (a phone's short card)
	card.Visible = not quietInWork() and HUD.gui():GetAttribute("WindowOpen") ~= true and not HUD.gui():FindFirstChild("LevelUp", true) and HUD.gui():GetAttribute("Minigame") ~= true -- (a window / the settlement or level card / a mini-game is up: one objective at a time)
	if sig == lastSig then
		return
	end
	lastSig = sig
	-- the midnight clock: minutes past 11 (50..60), moved by the job's progress only (never a timer — §4); one soft
	-- tick each time it moves while you look at it
	local midnight = car:GetAttribute("Midnight") :: number?
	clock.frame.Visible = midnight ~= nil
	if midnight then
		clock.set(midnight, clockShown == nil)
		if clockShown and midnight > clockShown then
			SoundPlayer.play("clockTickSoft")
		end
	end
	clockShown = midnight
	-- the steps: segment 1 (checked in) is always done
	local n, nextKey, nextArgs = stageOf(car)
	local mgStep = mgStepOf(car)
	local stepName = if mgStep then "@" .. mgStep else "@ui.job.s" .. n -- (a mini-game step names itself: "2/3 · Fill coolant")
	-- inside a work screen the car is open in front of you: "try it at the driver's door" no longer fits (GPT r1)
	if compact and nextKey == "ui.job.tryCar" then
		nextKey = "ui.job.scan"
	end
	for i = 1, 4 do
		local seg = steps:FindFirstChild("Seg" .. i) :: Frame
		seg.BackgroundColor3 = if i <= n then SEG_DONE elseif i == n + 1 then SEG_NOW else SEG_LATER
	end
	-- a car with stars (car_difficulty; only exists while Config.Features.Stars is on): the stars close the step line
	local stars = car:GetAttribute("Stars") :: number?
	if stars and stars >= 1 and stars <= 5 then
		UIKit.setText(stepLabel, "ui.job.stepNameStars", { name = stepName, stars = string.rep("★", math.floor(stars)) .. " " .. Localizer.t("stars." .. math.floor(stars)) })
	else
		-- (the name alone: the bar's four segments — checked in, find, fix, hand back — already say where you are; an
		-- "n/3" over four segments read as a mismatch — main 10-23)
		UIKit.setText(stepLabel, "ui.job.stepName", { name = stepName })
	end
	-- the tutorial's task strip already says the next thing: no second copy of it here
	local tut = Players.LocalPlayer:GetAttribute("Tut") :: number?
	local inTutorial = tut ~= nil and tut < 4 and not Players.LocalPlayer:GetAttribute("TutSkip")
	UIKit.setText(nextLabel, nextKey, nextArgs)
	nextLabel.Visible = false -- (the next step is the guide line at the bottom now: JobCard.guide, the tutorial strip before that)
	-- the Scan button: step 1, until the car has been scanned (the server marks it Scanned). On a tutorial car only
	-- once it's been tried (the strip's own button comes first: one "next" at a time) — the strip then says "Scan the
	-- car" and this is the button for it.
	-- Fixed: the same button is the Final check (work_view §2d: before handing it back; optional, the server marks
	-- FinalChecked — the tutorial's second car waits for it)
	local tutCar = inTutorial and car:GetAttribute("Tutorial") ~= nil
	local scanNow = n == 1 and car:GetAttribute("Scanned") ~= true and not (tutCar and #(car:GetAttribute("Clues") or "") <= 2)
	-- the tutorial's strip is asking for the car to be tried (its own button: "Try starting it"): the card's Final check
	-- would be the same ask twice (wr-play eval TOP 7: two blue buttons, "Final check" and "Start it", one job) — it waits
	local strip = HUD.gui():FindFirstChild("TutorialTask", true) :: GuiObject?
	local stripTry = strip ~= nil and strip.Visible and (strip:FindFirstChild("TryCar", true) :: GuiObject?) ~= nil and (strip:FindFirstChild("TryCar", true) :: GuiObject).Visible
	local finalNow = car:GetAttribute("Fixed") == true and car:GetAttribute("FinalChecked") ~= true and not mgStep and not (tutCar and stripTry)
	scanButton.Visible = scanNow
	finalButton.Visible = finalNow and not scanNow
	scanRow.Visible = scanNow or finalNow
	-- in a work view a step with its button says it with the button alone (GPT workview_phone r2)
	if compact and scanRow.Visible then
		nextLabel.Visible = false
	end
	-- trying the car: while finding the problem, and once it's fixed (hear it work); the tutorial's strip has its own.
	-- Not inside a work view: that's the driver's door's job — one button here (GPT workview_phone r1)
	tryRow.Visible = car:GetAttribute("Parked") == true and (n == 1 or (car:GetAttribute("Fixed") == true and not mgStep))
		and not (inTutorial and (car:GetAttribute("Tutorial") ~= nil)) and not compact
	local ok, list = pcall(HttpService.JSONDecode, HttpService, (car:GetAttribute("Clues") :: string?) or "[]")
	list = if ok and type(list) == "table" then list else {}
	-- (fixed: the clues are done with — room for the before / after buttons on a short phone screen)
	local clued = n < 3 and not mgStep and #list > 0
	-- a phone, walking (GPT jobcard_phone r1/r2: the card was capped at 55% of the screen and cut the clues off): one
	-- button row, the next action's — try the car until it has told you something, then Scan; fixed: Final check, then
	-- the before / after pair under "Hand back the keys" — and no next-action line over buttons that already say it
	local short = not compact and UIKit.size().Y < 500
	if short then
		if car:GetAttribute("Fixed") == true then
			tryRow.Visible = false
		elseif tryRow.Visible and scanRow.Visible then
			if clued then
				tryRow.Visible = false
			else
				scanRow.Visible = false
			end
		end
		if tryRow.Visible or scanRow.Visible then
			nextLabel.Visible = false
		end
	end
	local lines = {}
	local tipAt: number? = nil
	local who = car:GetAttribute("CustomerKind")
	local stage = car:GetAttribute("Stage") or "Calm"
	local col = if stage == "Calm" then "#7be08a" elseif stage == "Restless" then "#ffd25a" else "#ff8a70"
	local stageText = if car:GetAttribute("NoPatience") then "" else ' - <font color="' .. col .. '">' .. esc(Localizer.t("stage." .. stage)) .. "</font>"
	local function clueLines(newest: number?)
		table.insert(lines, '<font color="#c2e8ff">' .. esc(Localizer.t("card.clues")) .. "</font>")
		for i = math.max(1, #list - (newest or #list) + 1), #list do
			local c = list[i]
			table.insert(lines, "- " .. esc(Localizer.t(c.k, c.a)))
		end
	end
	-- (a phone: the customer's name only as a warning once they're getting impatient — they can leave — one line under
	-- the rest; the words, the tip and the clues need the room at a readable size, GPT jobcard_phone r2)
	local function moodLine()
		if who and stage ~= "Calm" and stageText ~= "" then
			-- ("Customer: Restless" — a full name wrapped to two lines on a small phone and got cut)
			table.insert(lines, esc(Localizer.t("card.mood")) .. ' <font color="' .. col .. '">' .. esc(Localizer.t("stage." .. stage)) .. "</font>")
		end
	end
	if short and clued then
		-- the clues first, the newest two
		clueLines(2)
		moodLine()
	else
		if who and not short then
			table.insert(lines, '<font size="' .. (body.TextSize + 4) .. '">' .. esc(Localizer.t("npc." .. who)) .. "</font>" .. stageText)
		end
		-- (no "Customer says:" over it: the quote marks say it — fewer words in the first minute)
		table.insert(lines, '"' .. esc(Localizer.t(car:GetAttribute("Symptom") or "say.hello")) .. '"')
		local tip = car:GetAttribute("Tip")
		-- the tutorial's task line already says it (the tip comes back if the tutorial is skipped); and the tip is
		-- about finding the problem: gone once it's found
		if inTutorial or n >= 2 then
			tip = nil
		end
		if tip then
			table.insert(lines, '<font color="#ffe27a">' .. esc(Localizer.t(tip)) .. "</font>")
			tipAt = #lines
		end
		-- the clues only once there are some (the next-action line already says how to find them: fewer words)
		if clued then
			table.insert(lines, "")
			clueLines()
		end
		if short then
			moodLine()
		end
	end
	body.Text = table.concat(lines, "\n")
	bodyNoTip = nil
	tipDropped = false
	if tipAt then
		local without = table.clone(lines)
		table.remove(without, tipAt)
		bodyNoTip = table.concat(without, "\n")
	end
	task.delay(0.1, function() -- (the box measures the new text a frame later: refit then, the tip goes if it doesn't fit)
		if refit then
			refit()
		end
	end)
	compareRow.Visible = car:GetAttribute("Fixed") == true and faultKind(car) ~= nil and not compact and not (short and finalNow) and not mgStep
	card.Visible = not quietInWork() and HUD.gui():GetAttribute("WindowOpen") ~= true and not HUD.gui():FindFirstChild("LevelUp", true) and HUD.gui():GetAttribute("Minigame") ~= true
end

local function playCompare(which: string)
	local c = car
	local kind = c and faultKind(c)
	local pair = kind and Diagnosis.Compare[kind]
	if not pair then
		return
	end
	local p = pair[which]
	SoundPlayer.play(p[1], c and c:GetPivot().Position)
	HUD.notify(p[2], nil, if which == "after" then "good" else "info")
end

-- the tutorial plays the before / after pair once by itself for the first two jobs (tutorial_script §9-4)
function JobCard.compare(which: string, kind: string, silent: boolean?)
	local pair = Diagnosis.Compare[kind]
	if not pair then
		return
	end
	local p = pair[which]
	if not silent then
		SoundPlayer.play(p[1], car and car:GetPivot().Position)
	end
	HUD.notify(p[2], nil, if which == "after" then "good" else "info")
end

local function button(parent: Instance, key: string, x: number, style: string, onClick: () -> ())
	UIKit.button(parent, {
		key = key,
		style = style,
		anchor = Vector2.new(0, 0),
		pos = UDim2.fromScale(x, 0),
		size = UDim2.fromScale(0.48, 1),
		max = 20,
		onClick = onClick,
	})
end

-- the settlement lines in invoice order (first10_payout §3: labor first — "what I did" — then the parts I bought, then
-- the bonuses with the one-time first-job bonus last), whatever order the server sends; nothing worth $0
local BONUS = { ["pay.spotOn"] = 1, ["pay.star"] = 2, ["pay.tip"] = 3, ["pay.coffee"] = 3.5, ["pay.first"] = 4, ["pay.boost"] = 5 } -- (pay.coffee: Features.Coffee, wr-dev; pay.boost: the Pay Boost pass — left out, the lines didn't add up to the total)
local function payLines(lines: { { [string]: any } })
	local work, parts, bonus = {}, {}, {}
	local earlier, bought = 0, 0 -- (grey minus lines: the check-up fee paid earlier, the parts I bought at the counter)
	for _, l in lines do
		local money = l.money or 0
		if l.key == "pay.paidEarlier" then
			earlier += math.abs(money)
			continue
		elseif l.key == "pay.bought" then
			bought += math.abs(money)
			continue
		end
		if money <= 0 then
			continue
		end
		if l.key == "pay.diag" then
			table.insert(work, { key = "pay.diag", text = Localizer.t("pay.diag"), money = money })
		elseif l.key == "pay.labor" then
			table.insert(work, { text = if (l.n or 1) >= 2 then Localizer.t("pay.laborN", { n = l.n }) else Localizer.t("pay.labor"), money = money })
		elseif l.key == "pay.parts" or string.sub(l.key, 1, 5) == "part." then
			table.insert(parts, l)
		elseif BONUS[l.key] then
			table.insert(bonus, { key = l.key, text = Localizer.t(l.key), money = money, big = l.key == "pay.first" })
		else
			-- a line this card doesn't know yet still counts: the lines must add up to the total (main 10-23)
			table.insert(bonus, { key = l.key, text = Localizer.t(l.key), money = money })
		end
	end
	-- parts: one line a kind ("Wheel ×2"); more than 3 kinds fold into "Parts ×n"
	if #parts > 3 then
		local n, sum = 0, 0
		for _, l in parts do
			n += l.n or 1
			sum += l.money
		end
		table.insert(work, { text = Localizer.t("pay.partsN", { n = n }), money = sum })
	else
		for _, l in parts do
			local text = if l.key == "pay.parts" then Localizer.t("pay.parts")
				elseif (l.n or 1) >= 2 then Localizer.t("pay.partN", { part = "@" .. l.key, n = l.n })
				else Localizer.t(l.key)
			table.insert(work, { text = text, money = l.money })
		end
	end
	table.sort(bonus, function(a, b)
		return (BONUS[a.key] or 9) < (BONUS[b.key] or 9)
	end)
	return work, bonus, earlier, bought
end

-- the settlement card with its lines (first10_payout §3): the tutorial's three cars and the first time a new kind of
-- line shows up (the server marks those `full`); every other job keeps the short banner. Lines pop in 0.15 s apart,
-- then the Total counts up, then Nice! closes it (no fixed timer).
local function payCard(data: { [string]: any })
	local gui = HUD.gui()
	UIKit.closeOthers(nil) -- (settings / a shop the player had open: the settlement takes the screen alone)
	local work, bonus, earlier, bought = payLines(data.lines)
	for _, w in work do
		if w.key == "pay.diag" and earlier > 0 then
			w.text ..= " " .. Localizer.t("pay.got") -- ("(paid)": the fee came earlier — no minus line, no sum sentence: main 10-23 r2)
		end
	end
	do -- (Studio: say it when the lines don't add up to the money paid — main 10-23)
		local sum = -earlier
		for _, l in work do
			sum += l.money
		end
		for _, l in bonus do
			sum += l.money
		end
		if sum ~= (data.money or 0) and game:GetService("RunService"):IsStudio() then
			warn(string.format("[JobCard] pay lines add up to %d, paid %d", sum, data.money or 0))
		end
	end
	local f = UIKit.plate(gui, { name = "PayCard", bolts = true, group = true, z = 6 }) :: any
	card.Visible = false
	bannerUntil = math.huge
	local screen = UIKit.size()
	local rowH = UIKit.px(0.062, 20, 30)
	local pad = UIKit.px(0.04, 12, 20)
	local titleH = UIKit.px(0.1, 30, 46)
	local rows = #work + (if #bonus > 0 then #bonus + 1 else 0) + (if bought > 0 then 1 else 0) -- (the small "minus parts" line under the money you get)
	-- (a thumb's 44 px on a phone: GPT boxfit r2 — 34 read fine but was a small tap)
	local okH = if UIKit.keyboard() then UIKit.px(0.1, 34, 46) else math.max(UIKit.px(0.1, 34, 46), 44)
	-- the room between the money bar row and the tool bar (667x375: the card sat over the money bar)
	local top = math.max(0, UIKit.barHeight() + 4 - UIKit.topInset())
	local room = screen.Y - UIKit.hotbarHeight() - UIKit.hotbarGap() - 8 - top
	-- too many lines for a short phone screen: the lines get shorter, never spill over the button (down to 14 px)
	local foldBonus = false
	local headerOn = #bonus > 0 -- (the small "Bonus" word over the bonus lines: the first thing to go when the lines get tiny)
	do
		local fixed = pad + titleH + 6 + 8 + 8 + 14 + okH + pad
		local base = rowH
		if fixed + (rows + 1.6) * rowH > room - 8 then
			rowH = math.max(math.floor((room - 8 - fixed) / (rows + 1.6)), 14)
			if rowH < 19 and headerOn then
				headerOn = false
				rows -= 1
				rowH = math.max(math.floor((room - 8 - fixed) / (rows + 1.6)), 14)
			end
			-- still tiny (GPT r1: 14 px is too tight): the bonus lines fold into one "Bonus $168" line
			if rowH < 19 and #bonus > 1 then
				foldBonus = true
				rows -= #bonus - 1
				rowH = math.max(math.floor((room - 8 - fixed) / (rows + 1.6)), 14)
			end
		end
		rowH = math.min(rowH, base)
		-- the lines at their smallest and still too tall (11 lines on 667x375 ran under Nice! — wr-release 10-23): the
		-- title and the edges give up the rest, never the lines or the thumb-sized button
		local over = pad + titleH + 6 + 8 + 8 + 14 + okH + pad + (rows + 1.6) * rowH - (room - 8)
		if over > 0 then
			local cut = math.min(over, titleH - 24)
			titleH -= cut
			over -= cut
			if over > 0 then
				pad = math.max(8, pad - math.ceil(over / 2))
			end
		end
	end
	-- (the Total row is 1.3 x 1.15 rows tall and the bought / keep rows 1.05: 1.6 rows over the plain count, so the last
	-- line never runs under Nice! — wr-release 10-23, 11 lines on 667x375)
	local h = pad + titleH + 6 + (rows + 1.6) * rowH + 8 + 8 + 14 + okH + pad -- (+8 the rule over the Total, +14 air above Nice!)
	local w = math.clamp(math.floor(screen.X * 0.42), 260, 400)
	-- centred in the room above the tool bar
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromOffset(screen.X / 2, top + room / 2)
	f.Size = UDim2.fromOffset(w, math.min(h, room - 8))
	f:SetAttribute("IsWindow", true) -- (the HUD's WindowOpen: the tutorial strip steps back behind it)
	UIKit.hazard(f, { pos = UDim2.new(0.5, 0, 0, pad * 0.6), size = UDim2.new(0.8, 0, 0, math.max(6, pad * 0.5)) })
	UIKit.text(f, {
		name = "Title",
		key = if data.first then "banner.first" else "banner.done",
		font = "Title",
		color = if data.happy then UIStyle.Color.Gold else Color3.fromRGB(255, 160, 140),
		anchor = Vector2.new(0.5, 0),
		pos = UDim2.new(0.5, 0, 0, pad + 2),
		size = UDim2.new(0.84, 0, 0, titleH),
		max = 44,
	})
	local inner = w - 2 * (pad + 10)
	local y = pad + titleH + 6
	local shown: { GuiObject } = {}
	local GREY = Color3.fromRGB(176, 184, 198)
	local function row(text: string, money: number?, color: Color3, big: boolean?, negative: boolean?): Frame
		local r = Instance.new("Frame")
		r.Name = "Row"
		r.BackgroundTransparency = 1
		r.Position = UDim2.fromOffset(pad + 10, y)
		r.Size = UDim2.fromOffset(inner, if big then rowH * 1.15 else rowH)
		r.Visible = false
		r.Parent = f
		UIKit.text(r, { name = "Name", text = text, font = "Bold", color = color, anchor = Vector2.new(0, 0.5), pos = UDim2.fromScale(0, 0.5), size = UDim2.fromScale(0.68, 0.86), alignX = Enum.TextXAlignment.Left, max = if big then 22 else 18 })
		if money then
			UIKit.text(r, { name = "Money", text = (if negative then "−" else "") .. Localizer.t("hud.money", { money = money }), font = "Title", color = if negative then GREY else UIStyle.Color.Cash, anchor = Vector2.new(1, 0.5), pos = UDim2.fromScale(1, 0.5), size = UDim2.fromScale(0.32, 0.86), alignX = Enum.TextXAlignment.Right, max = if big then 24 else 19 })
		end
		y += r.Size.Y.Offset
		table.insert(shown, r)
		return r
	end
	for _, l in work do
		row(l.text, l.money, UIStyle.Color.White)
	end
	if #bonus > 0 then
		-- a small "Bonus" over them (no dashes: GPT paycard r1 — the word explains the group)
		if headerOn then
			local sep = row(Localizer.t("pay.bonus"), nil, Color3.fromRGB(205, 214, 228))
			local name = sep:FindFirstChild("Name") :: TextLabel
			name.Size = UDim2.fromScale(0.4, 0.66)
		end
		if foldBonus then
			local sum = 0
			for _, l in bonus do
				sum += l.money
			end
			row(Localizer.t("pay.bonus"), sum, UIStyle.Color.White)
		else
			for _, l in bonus do
				row(l.text, l.money, UIStyle.Color.White, l.big)
			end
		end
	end
	-- (the check-up fee paid earlier is no minus line here any more: "Check-up fee $30" and "Paid earlier −$30" cancelled out
	-- and confused — main 10-23. It is said once, small, under the job's money)
	-- the Total: a line over it, big, counting up
	y += 4
	local rule = Instance.new("Frame")
	rule.BorderSizePixel = 0
	rule.BackgroundColor3 = UIStyle.Color.PlateEdge
	rule.Position = UDim2.fromOffset(pad + 10, y)
	rule.Size = UDim2.fromOffset(inner, 2)
	rule.Visible = false
	rule.Parent = f
	y += 4
	rowH = math.floor(rowH * 1.3)
	-- the money that goes into the wallet, big and gold ("+$372": the wallet bar goes up by exactly this when the card
	-- closes — main 10-23 r2; the parts bought are only said once, small, under it)
	local totalRow = row(Localizer.t("pay.receive"), 0, UIStyle.Color.Gold, true)
	local totalMoney = totalRow:FindFirstChild("Money") :: TextLabel
	totalMoney.TextColor3 = UIStyle.Color.Gold
	if bought > 0 then
		rowH = math.floor(rowH / 1.3 * 1.05)
		local net = (data.money or 0) + earlier - bought
		local after = row(Localizer.t("pay.afterParts", { bought = "$" .. bought, net = (if net < 0 then "−$" else "$") .. math.abs(net) }), nil, GREY)
		local afterName = after:FindFirstChild("Name") :: TextLabel
		afterName.Size = UDim2.fromScale(1, 0.8)
	end
	local ok = UIKit.button(f, {
		name = "Ok",
		key = "pay.collect",
		style = "Green",
		anchor = Vector2.new(0.5, 1),
		pos = UDim2.new(0.5, 0, 1, -pad),
		size = UDim2.new(0.42, 0, 0, okH),
		max = 24,
	})
	UIKit.fitButton(ok, { text = 0.5, pad = 0.5, min = 2.6, max = 22 }) -- (as wide as its words: user 10-22)
	ok.Visible = false
	UIKit.open(f)
	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		bannerUntil = 0
		UIKit.close(f)
		JobCard.PayClosed:Fire()
		task.delay(0.35, function()
			f:Destroy()
			HUD.showRep() -- (the rep bar fills now, under the money: first10_payout §3)
		end)
	end
	ok.Activated:Connect(close)
	task.spawn(function()
		task.wait(0.25)
		for _, r in shown do
			if r == totalRow then
				rule.Visible = true
			end
			r.Visible = true
			UIKit.pop(r, 0.7)
			if r ~= totalRow then
				SoundPlayer.play("tick")
			end
			task.wait(0.15)
		end
		if not SoundPlayer.play("payout") then
			SoundPlayer.play("reward")
		end
		local target = (data.money or 0) + earlier -- (the total of the lines above, the fee paid earlier too)
		local t0 = os.clock()
		while os.clock() - t0 < 0.8 and not closed do
			totalMoney.Text = "+" .. Localizer.t("hud.money", { money = math.floor(target * (os.clock() - t0) / 0.8) })
			task.wait()
		end
		totalMoney.Text = "+" .. Localizer.t("hud.money", { money = target })
		ok.Visible = true
		UIKit.pop(ok, 0.6)
		-- (a safety net, not a timer to read by: someone who walks off still gets the card out of the way)
		task.wait(20)
		close()
	end)
end

-- the JOB DONE banner (+ SPOT ON! / YOUR FIRST JOB!) with the money counting up; the line card when it's a full one
function JobCard.banner(data: { [string]: any })
	local tut = Players.LocalPlayer:GetAttribute("Tut") :: number?
	if type(data.lines) == "table" and #data.lines > 0 and (data.full == true or (data.full == nil and (data.first or (tut ~= nil and tut < 4)))) then
		payCard(data)
		return
	end
	local gui = HUD.gui()
	bannerUntil = os.clock() + 4.4
	card.Visible = false
	-- a plate card (fades as one piece): hazard band, the title, the money counting up, Spot On
	local f = UIKit.plate(gui, { name = "Banner", bolts = true, group = true, z = 6 }) :: any
	f.Position = UDim2.fromScale(0.5, 0.4)
	f.Size = UDim2.fromScale(0.5, 0.42)
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.AspectRatio = 1.75
	ratio.Parent = f
	local cap = Instance.new("UISizeConstraint")
	cap.MinSize = Vector2.new(260, 150)
	cap.MaxSize = Vector2.new(480, 275)
	cap.Parent = f
	UIKit.hazard(f, { pos = UDim2.fromScale(0.5, 0.07), size = UDim2.fromScale(0.86, 0.06) })
	UIKit.text(f, {
		name = "Title",
		key = if data.first then "banner.first" else "banner.done",
		font = "Title",
		color = if data.happy then UIStyle.Color.Gold else Color3.fromRGB(255, 160, 140),
		pos = UDim2.fromScale(0.5, 0.3),
		size = UDim2.fromScale(0.88, 0.24),
		max = 52,
	})
	local money = UIKit.text(f, {
		name = "Money",
		font = "Title",
		color = UIStyle.Color.Cash,
		pos = UDim2.fromScale(0.5, 0.58),
		size = UDim2.fromScale(0.88, 0.26),
		max = 52,
	})
	UIKit.text(f, {
		name = "Spot",
		key = if data.spotOn then "banner.spotOn" else nil,
		font = "Title",
		color = Color3.fromRGB(120, 220, 255),
		pos = UDim2.fromScale(0.5, 0.84),
		size = UDim2.fromScale(0.88, 0.16),
		max = 32,
	})
	UIKit.pop(f, 0.3)
	if not SoundPlayer.play("payout") then
		SoundPlayer.play("reward")
	end
	task.spawn(function()
		local target = data.money or 0
		local t0 = os.clock()
		while os.clock() - t0 < 1 do
			money.Text = Localizer.t("banner.money", { money = math.floor(target * (os.clock() - t0)) })
			task.wait()
		end
		money.Text = Localizer.t("banner.money", { money = target })
		task.wait(3)
		TweenService:Create(f, TweenInfo.new(0.4), { GroupTransparency = 1 }):Play()
		task.wait(0.45)
		f:Destroy()
		HUD.showRep()
	end)
end

function JobCard.start()
	-- placed by hand (a list layout would also move the corner bolts): body on top, the before / after row under it
	card = UIKit.plate(HUD.gui(), { name = "JobCard", anchor = Vector2.new(1, 0), bolts = true, group = true }) :: any
	card.Position = UDim2.new(1, -8, 0, 8)
	card.ClipsDescendants = true
	card.Visible = false
	local limit = Instance.new("UISizeConstraint")
	limit.Parent = card

	-- the steps: four segments (checked in, find, fix, hand back), the step's name, the next thing to do
	steps = Instance.new("Frame")
	steps.Name = "Steps"
	steps.BackgroundTransparency = 1
	steps.Parent = card
	local sl = Instance.new("UIListLayout")
	sl.FillDirection = Enum.FillDirection.Horizontal
	sl.SortOrder = Enum.SortOrder.LayoutOrder
	sl.Padding = UDim.new(0.025, 0)
	sl.Parent = steps
	for i = 1, 4 do
		local seg = Instance.new("Frame")
		seg.Name = "Seg" .. i
		seg.LayoutOrder = i
		seg.Size = UDim2.fromScale(0.23, 1)
		seg.BackgroundColor3 = if i == 1 then SEG_DONE else SEG_LATER
		seg.BorderSizePixel = 0
		local sc = Instance.new("UICorner")
		sc.CornerRadius = UDim.new(1, 0)
		sc.Parent = seg
		seg.Parent = steps
	end
	clock = MidnightClock.chip(card, 2)
	clock.frame.AnchorPoint = Vector2.new(1, 0)
	clock.frame.Visible = false
	clock.frame:GetPropertyChangedSignal("Visible"):Connect(function()
		if refit then
			refit()
		end
	end)
	stepLabel = label(card, "Step", UDim2.new(1, 0, 0, 0), 17)
	stepLabel.FontFace = UIStyle.Font.Title
	stepLabel.TextColor3 = UIStyle.Color.Yellow
	stepLabel.RichText = false
	stepLabel.AutomaticSize = Enum.AutomaticSize.Y
	UIKit.textSize(stepLabel, 0.05, 15, 21)
	nextLabel = label(card, "Next", UDim2.new(1, 0, 0, 0), 15)
	nextLabel.FontFace = UIStyle.Font.Bold
	nextLabel.RichText = false
	nextLabel.AutomaticSize = Enum.AutomaticSize.Y
	UIKit.textSize(nextLabel, 0.05, 15, 19) -- (15 px+ on a phone: GPT — smaller was hard to read)

	body = label(card, "Body", UDim2.new(1, 0, 0, 0), 15)
	body.AutomaticSize = Enum.AutomaticSize.Y
	UIKit.textSize(body, 0.05, 16, 17) -- (16 px on a phone too: the clues were too small to read — GPT jobcard_phone r2/r3)
	body.LineHeight = 1.05
	body:GetPropertyChangedSignal("TextSize"):Connect(function()
		lastSig = "" -- the customer line's size follows the body
	end)
	UIKit.onLang(function()
		lastSig = "" -- rebuilt in the new language on the next refresh
	end)

	-- "Scan the car" (work_view §2d: always the first thing on a car; works without holding the Scanner).
	-- Pressed: JobCard.Scan fires (wr-dev's WorkView asks the server). Shown while the job is at step 1.
	scanRow = Instance.new("Frame")
	scanRow.Name = "Scan"
	scanRow.BackgroundTransparency = 1
	scanRow.Visible = false
	scanRow.Parent = card
	scanButton = UIKit.button(scanRow, { name = "ScanButton", key = "ui.work.scan", style = "Blue", anchor = Vector2.new(0, 0), pos = UDim2.fromScale(0, 0), size = UDim2.fromScale(1, 1), max = 20, onClick = function()
		JobCard.Scan:Fire(car)
	end })
	-- (the same Scan: on a fixed car WorkView sends it as the final check)
	finalButton = UIKit.button(scanRow, { name = "FinalButton", key = "ui.work.finalCheck", style = "Blue", anchor = Vector2.new(0, 0), pos = UDim2.fromScale(0, 0), size = UDim2.fromScale(1, 1), max = 20, onClick = function()
		JobCard.Scan:Fire(car)
	end })

	tryRow = Instance.new("Frame")
	tryRow.Name = "Try"
	tryRow.BackgroundTransparency = 1
	tryRow.Visible = false
	tryRow.Parent = card
	button(tryRow, "tut.btnStart", 0, "Blue", function()
		if car then
			Remotes.TryCar:FireServer(car, "start")
		end
	end)
	button(tryRow, "tut.btnBrake", 0.52, "Blue", function()
		if car then
			Remotes.TryCar:FireServer(car, "brake")
		end
	end)

	compareRow = Instance.new("Frame")
	compareRow.Name = "Compare"
	compareRow.BackgroundTransparency = 1
	compareRow.Visible = false
	compareRow.Parent = card
	button(compareRow, "btn.before", 0, "Red", function()
		playCompare("before")
	end)
	button(compareRow, "btn.after", 0.52, "Green", function()
		playCompare("after")
	end)

	local function fit()
		local screen = UIKit.size()
		local p = UIKit.px(0.03, 8, 14)
		local rowH = UIKit.px(0.105, 40, 46) -- (wr-uidesign A③: a phone's blue buttons were 29-30 px high; a thumb needs 40+)
		-- (a phone: 215 px at least — at 190 a long English clue took three lines on a 667-wide phone)
		limit.MinSize = Vector2.new(if screen.Y < 500 then 215 else 190, 0)
		-- (a phone: 60% — its card is already trimmed to one button row, and the clues at a readable size need it)
		limit.MaxSize = Vector2.new(320, math.floor(screen.Y * (if screen.Y < 500 then 0.74 else 0.55)))
		local z = UIKit.zoom()
		-- under the money bar row / the corner buttons (667x375: they reach into the play area — the card's top hid
		-- under the gear)
		local top = math.max(0, UIKit.barHeight() + 4 - UIKit.topInset(), UIKit.cornerBottom() + 4)
		card.Position = UDim2.new(1, -8, 0, top + 8)
		limit.MaxSize = Vector2.new(320, math.floor(screen.Y * (if screen.Y < 500 then 0.74 else 0.55)) - top)
		local inner = UDim2.new(1, -2 * (p + 2), 0, 0)
		local segH = UIKit.px(0.022, 6, 9)
		-- the top and bottom rows sit between the plate picture's corner bolts
		local bolt = p + 2 + UIKit.px(0.035, 10, 16)
		steps.Position = UDim2.fromOffset(bolt, p)
		steps.Size = UDim2.new(1, -2 * bolt, 0, segH)
		local h = p + segH + 4
		stepLabel.Position = UDim2.fromOffset(p + 2, h)
		-- Ella's clock at the right end of the step line (the line wraps shorter beside it)
		local clockH = if clock.frame.Visible then UIKit.px(0.082, 28, 36) else 0
		local clockW = math.floor(clockH * 2.7)
		stepLabel.Size = UDim2.new(1, -2 * (p + 2) - (if clockH > 0 then clockW + 4 else 0), 0, 0)
		clock.frame.Size = UDim2.fromOffset(clockW, clockH)
		clock.frame.Position = UDim2.new(1, -(p + 2), 0, h)
		h += math.max(stepLabel.AbsoluteSize.Y / z, clockH)
		if nextLabel.Visible then
			nextLabel.Position = UDim2.fromOffset(p + 2, h)
			nextLabel.Size = inner
			h += nextLabel.AbsoluteSize.Y / z
		end
		if scanRow.Visible then
			scanRow.Position = UDim2.fromOffset(p + 2, h + 4)
			scanRow.Size = UDim2.new(1, -2 * (p + 2), 0, rowH)
			h += rowH + 6
		end
		if tryRow.Visible then
			tryRow.Position = UDim2.fromOffset(p + 2, h + 4)
			tryRow.Size = UDim2.new(1, -2 * (p + 2), 0, rowH)
			h += rowH + 6
		end
		body.Visible = not compact
		if not compact then
			h += math.floor(p * 0.6)
			body.Position = UDim2.fromOffset(p + 2, h)
			body.Size = inner
			h += body.AbsoluteSize.Y / z
		end
		compareRow.Position = UDim2.fromOffset(bolt, h + p)
		compareRow.Size = UDim2.new(1, -2 * bolt, 0, rowH)
		if compareRow.Visible then
			h += p + rowH
		end
		-- (the last line clears the bottom corner bolts too: a bolt's height under it — less covered the first letter)
		local need = h + p + UIKit.px(0.04, 12, 16)
		-- the text must never run out of the box (user 10-22): too long for the card's height cap -> the tip line goes
		-- (the guide line at the bottom of the screen says the same thing); the box then refits when the text settles
		if need > limit.MaxSize.Y and bodyNoTip and not tipDropped then
			tipDropped = true
			body.Text = bodyNoTip
		end
		card.Size = UDim2.new(0.27, 0, 0, need)
	end
	UIKit.bind(card, fit)
	refit = fit

	-- the tutorial arrow (Tutorial.luau) may point at something behind the card: the card turns see-through while
	-- the arrow is over it, so the arrow, the thing it points at and the text don't fight
	local faded = false
	RunService.RenderStepped:Connect(function()
		local arrow = HUD.gui():FindFirstChild("TutorialArrow", true) :: GuiObject?
		local over = false
		if arrow and arrow.Visible and card.Visible then
			local a0, a1 = arrow.AbsolutePosition, arrow.AbsolutePosition + arrow.AbsoluteSize
			local c0, c1 = card.AbsolutePosition, card.AbsolutePosition + card.AbsoluteSize
			over = a0.X < c1.X and a1.X > c0.X and a0.Y < c1.Y and a1.Y > c0.Y
		end
		if over ~= faded then
			faded = over
			TweenService:Create(card, TweenInfo.new(0.2), { GroupTransparency = if over then 0.8 else 0 }):Play()
		end
	end)
	body:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	stepLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	nextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	nextLabel:GetPropertyChangedSignal("Visible"):Connect(fit)
	compareRow:GetPropertyChangedSignal("Visible"):Connect(fit)
	scanRow:GetPropertyChangedSignal("Visible"):Connect(fit)
	tryRow:GetPropertyChangedSignal("Visible"):Connect(fit)

	HUD.gui():GetAttributeChangedSignal("Minigame"):Connect(refresh)
	task.spawn(function()
		while true do
			refresh()
			task.wait(0.3)
		end
	end)
end

-- the work screen (WorkViewUI): only the steps and the next thing to do — the customer's words and the clues fold
-- away so the car has the screen
function JobCard.setCompact(on: boolean)
	compact = on
	lastSig = "" -- (the next-action line depends on it)
	if refit then
		refit()
	end
end

-- The guide line (rival_upgrade B2-1 ①): the one next thing for the car I'm at, as the bottom hint line's words with
-- the key word in yellow (Client.client's hint loop asks; wr-dev's Guide.next can replace this later). Only after the
-- tutorial — its own strip says it before that. Returns a Locale key + args, or nil.
local GUIDE_FOR = {
	["ui.job.tryCar"] = "guide.tryCard",
	["ui.job.scan"] = "guide.scan",
	["ui.job.swap"] = "guide.putIn",
	["ui.job.liftFront"] = "guide.liftF",
	["ui.job.liftRear"] = "guide.liftR",
	["ui.job.handBack"] = "guide.handBack",
	["mg.torque.prompt"] = "guide.mgTorque",
	["mg.tire.prompt"] = "guide.mgTire",
	["mg.coolant.prompt"] = "guide.mgCoolant",
}
-- the guide keys the job card's own buttons already say (wr-uidesign A①): while the card is up the bottom line stays quiet
local CARD_SAYS: { [string]: boolean } = { ["guide.tryCard"] = true, ["guide.try"] = true, ["guide.scan"] = true }
function JobCard.guide(): (string?, { [string]: any }?, { [string]: any }?)
	local tut = player:GetAttribute("Tut") :: number?
	if tut ~= nil and tut < 4 and not player:GetAttribute("TutSkip") then
		return nil
	end
	local c = nearestCar()
	if not c then
		return nil
	end
	-- (a window / the level-up or settlement card has the screen: the line behind it only added noise — wr-uidesign #14)
	if HUD.gui():GetAttribute("WindowOpen") == true or HUD.gui():FindFirstChild("LevelUp", true) then
		return nil
	end
	-- wr-dev's Guide module (ClientModules/Guide.luau, `Guide.next(car) -> key, args?`), when it exists, says it for every job
	local gm = script.Parent:FindFirstChild("Guide")
	if gm then
		local ok, G = pcall(require, gm)
		if ok and type(G) == "table" and G.next then
			local ok2, k, a, info = pcall(G.next, c)
			if ok2 and k then
				if CARD_SAYS[k] and card and card.Visible then
					return nil, nil, info -- (the card's own button says it: one instruction at a time; the glow stays)
				end
				return k, a, info
			end
		end
	end
	local _, key, args = stageOf(c)
	if key == "ui.job.tryCar" and HUD.gui():GetAttribute("WorkView") then
		key = "ui.job.scan" -- (inside a work screen: as the card said it)
	end
	return GUIDE_FOR[key], args
end

return JobCard
