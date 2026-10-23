-- Game pass ownership, checked on the server (docs/design/monetization.md 5): Passes.owns(player, "GoldTools").
-- Asks Roblox once per player and pass, then remembers; a purchase made in game counts once Roblox confirms it (C1).
-- A failed check counts as not owned this time and is asked again next time. No pass does anything yet (features come
-- after the people test).

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Passes = {}

local known: { [Player]: { [number]: boolean } } = {}

local function askOwns(player: Player, name: string): boolean
	local id = Config.Passes[name]
	if not id then
		return false
	end
	known[player] = known[player] or {}
	local have = known[player][id]
	if have ~= nil then
		return have
	end
	local ok, res = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
	if ok then
		known[player][id] = res == true
		return res == true
	end
	return false
end

Passes.bought = Instance.new("BindableEvent") -- :Fire(player, name) — a pass bought in game (StoreService)

-- Studio play tests only (DevCall store): this player owns / doesn't own that pass (a pass with no id yet too)
local faked: { [Player]: { [string]: boolean } } = {}
function Passes.fake(player: Player, name: string, on: boolean)
	faked[player] = faked[player] or {}
	faked[player][name] = on
end

-- does this player own that pass (Studio tests: what Passes.fake says, if it said)
function Passes.owns(player: Player, name: string): boolean
	local f = faked[player]
	if f and f[name] ~= nil then
		return f[name]
	end
	return askOwns(player, name)
end

-- exploit audit C1: the "bought" signal can be faked by a client — it only makes us ask Roblox again (a few times:
-- a fresh purchase can take a moment to show). Still "no" at the end: not on now, the next join's check finds it
local RECHECK = { 0, 2, 5, 10 }
Passes.ask = function(player: Player, id: number): boolean
	local ok, res = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
	return ok and res == true
end

function Passes.onBought(player: Player, id: number)
	for _, w in RECHECK do
		task.wait(w)
		if not player.Parent then
			return
		end
		if Passes.ask(player, id) then
			known[player] = known[player] or {}
			known[player][id] = true
			for name, pid in Config.Passes do
				if pid == id then
					Passes.bought:Fire(player, name)
				end
			end
			return
		end
	end
	warn("[Passes] " .. player.Name .. " said they bought pass " .. tostring(id) .. " but Roblox says no")
end

function Passes.start()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, bought)
		if bought then
			task.spawn(Passes.onBought, player, id)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		known[player] = nil
		faked[player] = nil
	end)
end

return Passes
