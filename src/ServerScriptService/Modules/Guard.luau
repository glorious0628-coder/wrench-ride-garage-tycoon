-- The door in front of remote and prompt handlers (notes/security/exploit_audit_1022.md 4): is this someone playing in
-- this garage, not too often, close enough. One line per handler: Guard.wrap for a remote, Guard.prompt for a prompt.
-- An exploiter can fire any remote with any values and press any prompt from any distance, as often as they like
-- (Roblox docs) — so the server checks. Too-often calls are only counted for now (strikes), never a kick: first see
-- that slow phones and Studio don't trip it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GateService = require(script.Parent.GateService)

local Guard = {}

local SLACK = 6 -- (studs past a prompt's own distance: lag, a big part's pivot)

-- the job's steps: they wait while an Auto mini-game runs for this player (MinigameService sets `busy` — minigames
-- §3: Auto mustn't do two things at once). Walking, looking, the job card and the shops stay free.
local WORK = {
	Bolt = true, Install = true, Check = true, TryCar = true, Listen = true, Spotted = true, Scan = true,
	WorkPick = true, WorkPlace = true, WorkEnter = true, Jack = true, Release = true, PickUp = true, Piston = true,
	Hood = true, Fix = true, WorkPrompt = true, JackPlace = true, Pump = true, JackLower = true, Stand = true,
	ArmJack = true, Lift = true, Balance = true, Curb = true, Finish = true, Seat = true,
}
Guard.busy = nil :: ((Player) -> boolean)?

-- false (and a word) while an Auto mini-game holds this player's hands
function Guard.free(player: Player, name: string): boolean
	if WORK[name] and Guard.busy and Guard.busy(player) then
		Remotes.Notify:FireClient(player, "mg.autoBusy", nil, "info")
		return false
	end
	return true
end

local last: { [Player]: { [string]: number } } = {}
local strikes: { [Player]: number } = {}

-- playing in this garage: let in by the gate, save loaded, alive (audit M4: nothing before the gate decides)
function Guard.player(player: Player): boolean
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return GateService.isPlaying(player) and player:GetAttribute("Loaded") == true and hum ~= nil and hum.Health > 0
end

-- false when the same thing came again within gap seconds
function Guard.rate(player: Player, key: string, gap: number): boolean
	local t = last[player]
	if not t then
		t = {}
		last[player] = t
	end
	local now = os.clock()
	if t[key] and now - t[key] < gap then
		strikes[player] = (strikes[player] or 0) + 1
		return false
	end
	t[key] = now
	return true
end

-- a real number in [lo, hi] (NaN and infinities fail)
function Guard.num(v: any, lo: number, hi: number, int: boolean?): boolean
	return type(v) == "number" and v == v and v >= lo and v <= hi and (not int or v == math.floor(v))
end

-- within max studs of pos (true only when dist <= max: a NaN distance fails — audit L3)
function Guard.near(player: Player, pos: any, max: number): boolean
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") or typeof(pos) ~= "Vector3" then
		return false
	end
	return (root.Position - pos).Magnitude <= max
end

-- where a prompt is
local function promptAt(prompt: ProximityPrompt): Vector3?
	local at = prompt.Parent
	if at and at:IsA("Attachment") then
		return at.WorldPosition
	elseif at and at:IsA("BasePart") then
		return at.Position
	elseif at and at:IsA("Model") then
		return at:GetPivot().Position
	end
	return nil
end

-- a remote's handler, behind the gate and the rate (an error is only logged: the handler's script keeps running)
function Guard.wrap(name: string, gap: number, handler: (Player, ...any) -> ...any): (Player, ...any) -> ...any
	return function(player: Player, ...: any)
		if not Guard.player(player) or not Guard.rate(player, name, gap) or not Guard.free(player, name) then
			return nil
		end
		local res = table.pack(pcall(handler, player, ...))
		if not res[1] then
			warn("[Guard] " .. name .. ": " .. tostring(res[2]))
			return nil
		end
		return table.unpack(res, 2, res.n)
	end
end

-- a prompt's handler: the server checks the distance too, and the rate
function Guard.prompt(prompt: ProximityPrompt, name: string, gap: number, handler: (Player) -> ()): (Player) -> ()
	return function(player: Player)
		if not Guard.player(player) or not Guard.near(player, promptAt(prompt), prompt.MaxActivationDistance + SLACK) then
			return
		end
		if Guard.rate(player, name, gap) and Guard.free(player, name) then
			handler(player)
		end
	end
end

function Guard.strikes(player: Player): number
	return strikes[player] or 0
end

Players.PlayerRemoving:Connect(function(p)
	last[p], strikes[p] = nil, nil
end)

return Guard
