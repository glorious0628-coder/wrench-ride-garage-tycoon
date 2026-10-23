-- Today's receipt (docs/design/daily_receipt.md v0.3; drawn by ClientModules/Receipt, wr-ui): a shift = from joining
-- to leaving, only this player's own share.
--   This shift: counted in memory; the front-desk printer prompt ("Print receipt") shows it. At the 5th / 10th job a
--   small "Receipt ready at the front desk!" notice.
--   Last shift: kept in the save (PlayerData lastShift, one summary) when the shift had a job and lasted long enough
--   (Config.Receipt); shown 3 s after the next spawn, then dropped.
-- Earned = money that came IN only (job pay, sales, scrap) — parts bought are never taken off, so it is never negative.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PlayerData = require(script.Parent.PlayerData)

local ShiftService = {}

type Shift = {
	start: number,
	cars: number,
	spotOn: number,
	earned: number,
	repFrom: number,
	levelFrom: number,
	unlocks: { string },
	restored: number,
	restoredEarned: number,
	quick: number, -- quick jobs at the curb (CurbService)
	customer: { name: string, rank: number }?,
	crew: { [string]: boolean },
}

local shifts: { [Player]: Shift } = {}

local NAMED = { Rosa = 3, Tyler = 3, VIP = 2 } -- "customer of the shift": the regulars first

-- what the receipt screen gets (the Remotes.Receipt contract)
function ShiftService.summary(player: Player): { [string]: any }?
	local s = shifts[player]
	if not s then
		return nil
	end
	local crew = {}
	for name in s.crew do
		table.insert(crew, name)
	end
	table.sort(crew)
	return {
		t = os.time(),
		minutes = math.floor((os.time() - s.start) / 60),
		cars = s.cars,
		spotOn = s.spotOn,
		earned = s.earned,
		rep = ((player:GetAttribute("Rep") :: number?) or s.repFrom) - s.repFrom,
		repFrom = s.repFrom,
		repTo = (player:GetAttribute("Rep") :: number?) or s.repFrom,
		levelFrom = s.levelFrom,
		levelTo = (player:GetAttribute("Level") :: number?) or s.levelFrom,
		unlocks = table.clone(s.unlocks),
		restored = s.restored,
		restoredEarned = s.restoredEarned,
		quick = s.quick, -- (receipt line "Quick jobs ×N": receipt.curb)
		customer = if s.customer then { name = s.customer.name } else nil,
		crew = if #crew > 0 then { table.unpack(crew, 1, math.min(3, #crew)) } else nil,
	}
end

-- worth keeping for next time: a job done and long enough (daily_receipt 1)
local function keep(player: Player)
	local s = shifts[player]
	local r = Config.Receipt
	local good = s ~= nil and s.cars >= r.MinJobs and os.time() - s.start >= r.MinMinutes * 60
	PlayerData.setLastShift(player, if good then ShiftService.summary(player) else nil)
end

local function begin(player: Player)
	shifts[player] = {
		start = os.time(),
		cars = 0,
		spotOn = 0,
		earned = 0,
		repFrom = (player:GetAttribute("Rep") :: number?) or 0,
		levelFrom = (player:GetAttribute("Level") :: number?) or 1,
		unlocks = {},
		restored = 0,
		restoredEarned = 0,
		quick = 0,
		crew = {},
	}
	-- last time's receipt: 3 s after they're standing in the garage
	local last = PlayerData.takeLastShift(player)
	if last and (tonumber(last.cars) or 0) > 0 then
		task.spawn(function()
			local char = player.Character or player.CharacterAdded:Wait()
			char:WaitForChild("HumanoidRootPart", 10)
			task.wait(3)
			if player.Parent then
				Remotes.Receipt:FireClient(player, "last", last)
			end
		end)
	end
end

-- money that came in (job pay share, a sale, scrap)
function ShiftService.earn(player: Player, amount: number)
	local s = shifts[player]
	if s and amount > 0 then
		s.earned += math.floor(amount)
	end
end

-- a customer car this player worked on was handed back (their share, Spot On, who else, how happy)
function ShiftService.job(player: Player, money: number, spotOn: boolean, team: { Player }, kind: string, happy: boolean)
	local s = shifts[player]
	if not s then
		return
	end
	s.cars += 1
	s.spotOn += if spotOn then 1 else 0
	ShiftService.earn(player, money)
	for _, p in team do
		if p ~= player then
			s.crew[p.DisplayName] = true
		end
	end
	local rank = (NAMED[kind] or 1) + (if happy then 10 else 0)
	if not s.customer or rank > s.customer.rank then
		s.customer = { name = "@npc." .. kind, rank = rank }
	end
	if table.find(Config.Receipt.BannerAtJobs, s.cars) then
		task.delay(5, function() -- (after the pay card)
			if player.Parent then
				Remotes.Notify:FireClient(player, "receipt.ready", nil, "info")
			end
		end)
	end
	keep(player)
end

-- a quick job at the curb done (CurbService): counted on its own line, its money in Earned
function ShiftService.quick(player: Player, money: number)
	local s = shifts[player]
	if s then
		s.quick += 1
		ShiftService.earn(player, money)
	end
end

-- something new at the garage (a tool / upgrade bought): "@equip.<id>"
function ShiftService.unlock(player: Player, key: string)
	local s = shifts[player]
	if s and not table.find(s.unlocks, key) then
		table.insert(s.unlocks, key)
	end
end

-- a restored car sold: their share of the sale
function ShiftService.sold(player: Player, money: number)
	local s = shifts[player]
	if s then
		s.restored += 1
		s.restoredEarned += math.floor(money)
		ShiftService.earn(player, money)
		keep(player)
	end
end

-- the printer at the front desk (the map's WaitingRoom.ReceptionDesk.ReceiptPrinter, else the desk's ServicePoint)
local function printer()
	local g = workspace:FindFirstChild("Garage")
	local desk = g and g:FindFirstChild("WaitingRoom") and (g :: any).WaitingRoom:FindFirstChild("ReceptionDesk")
	local at = desk and (desk:FindFirstChild("ReceiptPrinter", true) or desk:FindFirstChild("ServicePoint", true))
	if not at or not (at:IsA("BasePart") or at:IsA("Attachment")) then
		return
	end
	local p = Instance.new("ProximityPrompt")
	p.Name = "ReceiptPrompt"
	p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	p.KeyboardKeyCode = Enum.KeyCode.R
	p.MaxActivationDistance = Config.PromptDistance
	p.RequiresLineOfSight = false
	p.UIOffset = Vector2.new(0, 72)
	Locale.tag(p, "act.printReceipt")
	p.Parent = at
	p.Triggered:Connect(function(player)
		local data = ShiftService.summary(player)
		if data and data.cars > 0 then
			Remotes.Receipt:FireClient(player, "this", data)
		else
			Remotes.Notify:FireClient(player, "receipt.empty", nil, "info")
		end
	end)
end

function ShiftService.start()
	PlayerData.joined.Event:Connect(begin)
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("Loaded") and not shifts[p] then
			begin(p)
		end
	end
	-- the final word on keeping it (the shift's length counts now), just before the leave save
	PlayerData.finalize = keep
	Players.PlayerRemoving:Connect(function(p)
		task.defer(function()
			shifts[p] = nil
		end)
	end)
	printer()
end

return ShiftService
