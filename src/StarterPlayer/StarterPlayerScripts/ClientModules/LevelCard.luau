-- The level-up card, every level (wr-gamer all_report_1 TOP2: "from Lv4 there was no card and no sign of what's next").
-- "Garage Level N!" + up to two lines of what opened and where to find it, read from the game's own tables:
--   a new job (Config.FaultUnlock), new things in the toolbox (Equipment.Items), the junkyard (Config.JunkyardLevel);
--   a level that opens nothing says when the next new thing comes. One card at a time: it waits for the settlement
--   card (tutorial cars: the line card + its Nice!) or the plain JOB DONE banner first, closes with Nice! or by
--   itself after 10 s. The garage-name window waits for the frame named "LevelUp" (NameWindow.offer).
-- Moved here from Tutorial.luau (it only knew Lv2 and Lv3).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Equipment = require(ReplicatedStorage.Shared.Equipment)
local PartGraph = require(ReplicatedStorage.Shared.PartGraph)
local HUD = require(script.Parent.HUD)
local JobCard = require(script.Parent.JobCard)
local SoundPlayer = require(script.Parent.SoundPlayer)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local LevelCard = {}

local player = Players.LocalPlayer
local C = UIStyle.Color

type Line = { key: string, args: { [string]: any }? }

-- one level's news, most useful first: a new job, free tools (Features.ToolMatch), things in the toolbox, the junkyard
local function opened(level: number): { Line }
	local out: { Line } = {}
	local jobs = {}
	for kind, at in Config.FaultUnlock do
		if at == level then
			table.insert(jobs, kind)
		end
	end
	table.sort(jobs)
	if #jobs > 0 then
		table.insert(out, { key = "ui.lvl.job", args = { part = "@part." .. jobs[1] } })
	end
	if Config.feature("ToolMatch") then
		local free = {}
		for name, row in PartGraph.Tools do
			if row.free and row.enabled ~= false and row.level == level then
				table.insert(free, name)
			end
		end
		table.sort(free)
		if #free > 0 then
			table.insert(out, { key = if #free > 1 then "ui.lvl.freeMore" else "ui.lvl.free", args = { item = "@tool." .. free[1], n = #free - 1 } })
		end
	end
	-- shop news: the tools on sale and the garage upgrades are two lines (one language, one list: Equipment.Items by its
	-- own order — "New in the tool shop" was read as given for free; wr-play eval 10-23 TOP 5)
	local tools, garage = {}, {}
	for _, it in Equipment.Items do
		if it.level == level then
			table.insert(if it.kind == "garage" then garage else tools, it)
		end
	end
	for _, row in { { tools, "ui.lvl.tool" }, { garage, "ui.lvl.garage" } } do
		local list, base = row[1] :: { Equipment.Item }, row[2] :: string
		if #list > 0 then
			table.sort(list, function(x, y)
				return x.order < y.order
			end)
			table.insert(out, { key = if #list > 1 then base .. "More" else base, args = { item = "@equip." .. list[1].id, n = #list - 1 } })
		end
	end
	if level == Config.JunkyardLevel then
		table.insert(out, { key = "ui.lvl.yard" })
	end
	return out
end

-- the name of the first thing a level opens ("@part.X" / "@equip.Y" / the junkyard), for the "next" line
local function firstName(level: number): string?
	for kind, at in Config.FaultUnlock do
		if at == level then
			return "@part." .. kind
		end
	end
	for _, it in Equipment.Items do
		if it.level == level then
			return "@equip." .. it.id
		end
	end
	if level == Config.JunkyardLevel then
		return "@ui.lvl.yardName"
	end
	return nil
end

-- what to put on the card: what opened (at most two lines), then — while there is room — when the next new thing
-- comes, so the bar's far end is never a mystery
function LevelCard.news(level: number): { Line }
	local out = opened(level)
	-- Lv 8 also tells where the mini-games can be turned to Auto (only while the feature is on): that card has 3 lines
	local mini = level == 8 and Config.feature("Minigames")
	while #out > (if mini then 2 else 2) do
		table.remove(out)
	end
	if mini then
		table.insert(out, { key = "ui.lvl.mini" })
	end
	if #out < 2 then
		local nextAt = math.huge
		for _, at in Config.FaultUnlock do
			if at > level and at < nextAt then
				nextAt = at
			end
		end
		for _, it in Equipment.Items do
			if it.level > level and it.level < nextAt then
				nextAt = it.level
			end
		end
		if Config.JunkyardLevel > level and Config.JunkyardLevel < nextAt then
			nextAt = Config.JunkyardLevel
		end
		local what = if nextAt < math.huge then firstName(nextAt) else nil
		if what then
			table.insert(out, { key = "ui.lvl.next", args = { next = nextAt, what = what } })
		end
	end
	return out
end

function LevelCard.show(level: number)
	SoundPlayer.play("levelUp")
	local f = UIKit.plate(HUD.gui(), { name = "LevelUp", bolts = true, z = 6 })
	f.Position = UDim2.fromScale(0.5, 0.45)
	f.Size = UDim2.fromScale(0.42, 0.42)
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.AspectRatio = 1.6
	ratio.Parent = f
	local limit = Instance.new("UISizeConstraint")
	limit.MinSize = Vector2.new(240, 150)
	limit.MaxSize = Vector2.new(440, 275)
	limit.Parent = f
	UIKit.hazard(f, { pos = UDim2.fromScale(0.5, 0.06), size = UDim2.fromScale(0.86, 0.06), z = 6 })
	UIKit.text(f, {
		name = "Title",
		key = "tut.level2",
		args = { level = level },
		font = "Title",
		color = C.Gold,
		pos = UDim2.fromScale(0.5, 0.27),
		size = UDim2.fromScale(0.86, 0.24),
		max = 44,
		z = 6,
	})
	local lines = LevelCard.news(level)
	for i, l in lines do
		local news = UIKit.text(f, {
			name = "News" .. i,
			key = l.key,
			args = l.args,
			pos = UDim2.fromScale(0.5, if #lines == 1 then 0.52 elseif #lines == 2 then 0.45 + (i - 1) * 0.14 else 0.42 + (i - 1) * 0.12),
			size = UDim2.fromScale(0.94, if #lines == 3 then 0.1 else 0.12),
			max = 22,
			z = 6,
		})
		if l.key == "ui.lvl.mini" then
			news.TextColor3 = Color3.fromRGB(255, 230, 140) -- (the tip line, soft yellow: GPT mock lv8_mock1)
		end
	end
	UIKit.button(f, {
		name = "Nice",
		key = "tut.nice",
		pos = UDim2.fromScale(0.5, if #lines == 3 then 0.9 else 0.8),
		size = UDim2.fromScale(0.46, if #lines == 3 then 0.2 else 0.24),
		max = 28,
		z = 6,
		onClick = function()
			f:Destroy()
		end,
	})
	UIKit.pop(f, 0.3)
	task.delay(10, function()
		if f.Parent then
			f:Destroy() -- (closes by itself too: it must never sit over the next job)
		end
	end)
end

-- a new level arrived: its card comes after the card(s) already on screen
function LevelCard.onLevel(level: number)
	task.spawn(function()
		local gui = HUD.gui()
		local tut = player:GetAttribute("Tut") :: number?
		-- tutorial cars: the settlement line card can come seconds later (the car drives off first); after that,
		-- a plain JOB DONE banner shows right away
		local settling = tut ~= nil and tut < 4
		local t0 = os.clock()
		while os.clock() - t0 < (if settling then 15 else 3) do
			if gui:FindFirstChild("PayCard", true) or (not settling and gui:FindFirstChild("Banner", true)) then
				break
			end
			task.wait(0.1)
		end
		if gui:FindFirstChild("PayCard", true) then
			JobCard.PayClosed.Event:Wait()
			task.wait(0.4)
		else
			local w0 = os.clock()
			while gui:FindFirstChild("Banner", true) and os.clock() - w0 < 6 do
				task.wait(0.1)
			end
			task.wait(0.3)
		end
		-- one thing at a time: a window the player has open (settings, the shop) goes first
		local w0 = os.clock()
		while gui:GetAttribute("WindowOpen") == true and os.clock() - w0 < 40 do
			task.wait(0.5)
		end
		LevelCard.show(level)
	end)
end

return LevelCard
