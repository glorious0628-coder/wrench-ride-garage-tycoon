-- First-session timing for the people tests (docs/design/tycoon_analysis.md #1): how long after joining each
-- player first touches something, first sees the car change (it starts / the brakes go quiet after their fix) and
-- first gets paid. Goal: a touch within 60 s, the change within 180 s.
-- Each time is kept once per session: printed to the output ([Metrics] ...), mirrored on the player as attributes
-- Metric_<name> (seconds) for the play tests, and a summary line when they leave. Config.SendAnalytics = true sends
-- them as AnalyticsService custom events too (live servers only).

local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)

local Metrics = {}

-- in the order they should happen; goal = seconds after joining (nil = no goal, just measured)
local MARKS = {
	{ name = "firstTouch", goal = 60 },
	{ name = "firstChange", goal = 180 },
	{ name = "firstPay" },
}

local joined: { [Player]: number } = {}
local seen: { [Player]: { [string]: number } } = {}

local function summary(player: Player): string
	local parts = {}
	for _, m in MARKS do
		local t = seen[player] and seen[player][m.name]
		local verdict = if not m.goal then "" elseif t and t <= m.goal then " ok" else " MISS"
		table.insert(parts, string.format("%s=%s%s", m.name, if t then string.format("%.0fs", t) else "-", verdict))
	end
	return table.concat(parts, " ")
end

-- this player did it now (only the first time counts)
function Metrics.mark(player: Player, name: string)
	local t0 = joined[player]
	if not t0 or (seen[player] and seen[player][name]) then
		return
	end
	local t = os.clock() - t0
	seen[player] = seen[player] or {}
	seen[player][name] = t
	player:SetAttribute("Metric_" .. name, math.floor(t * 10 + 0.5) / 10)
	print(string.format("[Metrics] %s %s %.1fs (tutorial %s)", player.Name, name, t, tostring(player:GetAttribute("Tut"))))
	if Config.SendAnalytics and not RunService:IsStudio() then
		pcall(AnalyticsService.LogCustomEvent, AnalyticsService, player, "FTUE_" .. name, t)
	end
end

-- everyone who worked on that car saw it change
function Metrics.markAll(players: { Player }, name: string)
	for _, p in players do
		Metrics.mark(p, name)
	end
end

function Metrics.start()
	local function add(p: Player)
		joined[p] = os.clock()
	end
	Players.PlayerAdded:Connect(add)
	for _, p in Players:GetPlayers() do
		add(p)
	end
	Players.PlayerRemoving:Connect(function(p)
		if joined[p] then
			print(string.format("[Metrics] %s left after %.0fs: %s", p.Name, os.clock() - joined[p], summary(p)))
		end
		joined[p], seen[p] = nil, nil
	end)
	-- any E prompt (hood, start the car, pick up, install...) is a touch; bolts / the scanner call mark() themselves
	ProximityPromptService.PromptTriggered:Connect(function(_, player)
		Metrics.mark(player, "firstTouch")
	end)
end

Metrics.summary = summary

return Metrics
