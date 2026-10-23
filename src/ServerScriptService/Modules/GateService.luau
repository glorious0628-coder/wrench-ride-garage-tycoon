-- Who plays in this garage (docs/design/server_model.md v0.4, "C 섞기"): one garage = its owner + people who know
-- someone here. The first person into an empty public server owns it (kept by UserId, not by who's still here).
-- Someone who isn't friends with anyone here goes to their own garage: a reserved server (Roblox can't make a new
-- empty public one, and Join can't follow into a reserved one — an invite does). A friend's invite (LaunchData =
-- the owner's UserId) sends them on to that garage, found through a short MemoryStore note "owner -> where".
-- PlayerData waits on GateService.admit before loading a save: someone being sent away never loads here.
-- Studio can't teleport or check friends (test players): everyone counts as a friend unless DevCall "gate" says
-- otherwise, and a send only pretends (the moving screen, then the "couldn't get there" card).

local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local GateService = {}

local STUDIO = RunService:IsStudio()
local GATE_GAP = 5
local MAX_PLAYERS = 4 -- (the place's MaxPlayers on the dashboard: server_model §2)
local WHERE_TTL = 150 -- seconds a "garage is here" note lives; refreshed every minute
local TRIES = 5 -- teleport tries, 1 s apart (the official teleport example)

GateService.ownerId = nil :: number?
GateService.closed = false -- the owner left: no new customers, no new people (friends finish up and head home)
GateService.reserved = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
GateService.studioStrangers = {} :: { [any]: boolean } -- DevCall "gate": these UserIds (or "all") count as strangers

local admitted: { [Player]: boolean } = {} -- the decision, once made (true = plays here)
local deciding: { [Player]: BindableEvent } = {}
local myCode: string? = nil -- this reserved server's access code (from the teleport that made it)
local where: any = nil -- MemoryStore hash map "owner UserId -> { job | code, n }"
do
	local ok, res = pcall(function()
		return MemoryStoreService:GetHashMap("GarageWhere")
	end)
	where = if ok then res else nil
end

local function mark()
	workspace:SetAttribute("GarageOwner", GateService.ownerId)
	workspace:SetAttribute("GarageKind", if GateService.reserved then "reserved" else "public")
	workspace:SetAttribute("GarageClosed", GateService.closed or nil)
end

local function playing(): { Player }
	local out = {}
	for p, ok in admitted do
		if ok and p.Parent then
			table.insert(out, p)
		end
	end
	return out
end

-- tell the MemoryStore where this garage is (invites and "go to the owner" read it)
local function publish()
	local id = GateService.ownerId
	if not where or not id then
		return
	end
	if GateService.closed then
		pcall(function()
			where:RemoveAsync(tostring(id))
		end)
		return
	end
	local note = { job = if GateService.reserved then nil else game.JobId, code = myCode, n = #playing() }
	if GateService.reserved and not myCode then
		return -- (don't know our own code: the note the sending server wrote stays until it runs out)
	end
	pcall(function()
		where:SetAsync(tostring(id), note, WHERE_TTL)
	end)
end

-- friends with that one person (Studio: everyone is, unless DevCall "gate" made this player a stranger)
local function friendOf(player: Player, userId: number): boolean
	if STUDIO then
		return not (GateService.studioStrangers.all or GateService.studioStrangers[player.UserId])
	end
	local ok, yes = pcall(player.IsFriendsWithAsync, player, userId)
	return ok and yes == true
end

local function friendsWithSomeone(player: Player): boolean
	if STUDIO then
		return not (GateService.studioStrangers.all or GateService.studioStrangers[player.UserId])
	end
	local tries = 0
	for _, p in playing() do
		if p ~= player and tries < 3 then
			tries += 1
			local ok, yes = pcall(player.IsFriendsWithAsync, player, p.UserId)
			if ok and yes then
				return true
			end
		end
	end
	return false
end

-- teleport with retries; the client shows why the whole time. false = it couldn't (the player stays, looking around)
local pending: { [Player]: { opts: TeleportOptions, tries: number } } = {}
local function send(player: Player, opts: TeleportOptions, key: string, args: { [string]: any }?): boolean
	Remotes.Gate:FireClient(player, "moving", key, args)
	if STUDIO then
		-- (Studio can't teleport: show the moving screen a moment, then what a failed send looks like)
		print(string.format("[Gate] would send %s: %s", player.Name, key))
		task.wait(2)
		Remotes.Gate:FireClient(player, "failed")
		return false
	end
	pending[player] = { opts = opts, tries = 0 }
	for i = 1, TRIES do
		local ok, err = pcall(TeleportService.TeleportAsync, TeleportService, game.PlaceId, { player }, opts)
		if ok then
			return true -- (it can still fail on the way: TeleportInitFailed tries again)
		end
		warn("[Gate] teleport " .. player.Name .. " try " .. i .. ": " .. tostring(err))
		if i == 2 then
			Remotes.Gate:FireClient(player, "retry")
		end
		task.wait(1)
	end
	pending[player] = nil
	Remotes.Gate:FireClient(player, "failed")
	return false
end

-- to their own garage: a fresh reserved server (its code goes in the "where" note, so invites can follow)
local function sendHome(player: Player): boolean
	local code: string? = nil
	if not STUDIO then
		local ok, res = pcall(TeleportService.ReserveServer, TeleportService, game.PlaceId)
		code = if ok then res else nil
		if not code then
			Remotes.Gate:FireClient(player, "failed")
			return false
		end
		if where then
			pcall(function()
				where:SetAsync(tostring(player.UserId), { code = code, n = 0 }, WHERE_TTL)
			end)
		end
	end
	local opts = Instance.new("TeleportOptions")
	opts.ReservedServerAccessCode = code or ""
	opts:SetTeleportData({ garage = player.UserId, code = code })
	return send(player, opts, "gate.toOwn")
end
GateService.sendHome = sendHome

-- to the garage of this owner, if the note says where (false = not found / full / already here)
local function sendTo(player: Player, ownerId: number): boolean
	if not where then
		return false
	end
	local ok, note = pcall(function()
		return where:GetAsync(tostring(ownerId))
	end)
	if not ok or type(note) ~= "table" or note.job == game.JobId then
		return false
	end
	local name = "?"
	pcall(function()
		name = Players:GetNameFromUserIdAsync(ownerId)
	end)
	if (tonumber(note.n) or 0) >= MAX_PLAYERS then
		Remotes.Notify:FireClient(player, "gate.full", { name = name }, "bad")
		return false
	end
	local opts = Instance.new("TeleportOptions")
	if note.code then
		opts.ReservedServerAccessCode = note.code
	elseif note.job then
		opts.ServerInstanceId = note.job
	else
		return false
	end
	opts:SetTeleportData({ garage = ownerId, code = note.code })
	return send(player, opts, "gate.toFriend", { name = name })
end

-- LaunchData (an invite link) and TeleportData are the client's to change (exploit audit H1): they only say where
-- someone wants to go — whether they get in is still the friends rule, checked here
GateService.fakeJoin = {} :: { [Player]: any } -- (Studio tests: this player "arrived" with this join data)
local function decide(player: Player): boolean
	local join = GateService.fakeJoin[player] or player:GetJoinData()
	local data = type(join.TeleportData) == "table" and join.TeleportData or {}
	local garage = tonumber(data.garage)
	-- nobody plays here any more (all left, or a fresh server): this person starts it over as the owner
	if #playing() == 0 and not GateService.reserved then
		local launch = tonumber(join.LaunchData)
		if launch and launch ~= player.UserId and friendOf(player, launch) and sendTo(player, launch) then
			return false -- (an invite: off to the friend's garage)
		end
		GateService.ownerId = player.UserId
		GateService.closed = false
		return true
	end
	if GateService.reserved and GateService.ownerId == nil then
		-- (the server's owner is who it was reserved for: themself, or a friend of theirs — never just anyone's UserId)
		GateService.ownerId = if garage and (garage == player.UserId or friendOf(player, garage)) then garage else player.UserId
		myCode = if type(data.code) == "string" then data.code else nil
		return true
	end
	if player.UserId == GateService.ownerId then
		GateService.closed = false -- the owner is back
		return true
	end
	if garage and garage == GateService.ownerId and not GateService.closed and (friendOf(player, garage) or friendsWithSomeone(player)) then
		return true -- sent here on purpose (an invite / "go to my friend")
	end
	local launch = tonumber(join.LaunchData)
	if launch and launch ~= GateService.ownerId and launch ~= player.UserId and friendOf(player, launch) and sendTo(player, launch) then
		return false
	end
	if not GateService.closed and friendsWithSomeone(player) then
		return true
	end
	task.spawn(sendHome, player)
	return false
end

-- yields until it's decided whether this player plays here (PlayerData asks before loading their save)
function GateService.admit(player: Player): boolean
	if admitted[player] ~= nil then
		return admitted[player]
	end
	if deciding[player] then
		deciding[player].Event:Wait()
		return admitted[player] == true
	end
	local done = Instance.new("BindableEvent")
	deciding[player] = done
	local ok, res = pcall(decide, player)
	if not ok then
		warn("[Gate] " .. tostring(res))
	end
	admitted[player] = if ok then res else true -- (a broken check never locks anyone out)
	deciding[player] = nil
	done:Fire()
	mark()
	if admitted[player] then
		task.spawn(publish)
	end
	return admitted[player]
end

-- Studio: decide again as if they just arrived (DevCall "gate")
function GateService.recheck(player: Player): boolean
	admitted[player] = nil
	return GateService.admit(player)
end

GateService.onLateAdmit = nil :: ((Player) -> ())? -- set by PlayerData: load the save of someone let in on a retry

-- "Try again" after a failed send: decide again (a friend may be here now), else send again
function GateService.retry(player: Player)
	if admitted[player] == false and not pending[player] and GateService.recheck(player) and GateService.onLateAdmit then
		GateService.onLateAdmit(player)
	end
end

function GateService.isPlaying(player: Player): boolean
	return admitted[player] == true
end

function GateService.start()
	mark()
	Players.PlayerRemoving:Connect(function(player)
		local was = admitted[player]
		admitted[player] = nil
		pending[player] = nil
		if was and player.UserId == GateService.ownerId and #playing() > 0 then
			-- the owner went home: the friends finish the car they're on, then head to their own garages
			GateService.closed = true
			mark()
			Remotes.Gate:FireAllClients("ownerLeft", "gate.ownerLeft", { name = player.DisplayName })
		end
		task.spawn(publish)
	end)
	TeleportService.TeleportInitFailed:Connect(function(player, result, message)
		local p = pending[player]
		if not p then
			return
		end
		warn("[Gate] teleport failed for " .. player.Name .. ": " .. tostring(result) .. " " .. tostring(message))
		p.tries += 1
		if p.tries >= TRIES then
			pending[player] = nil
			Remotes.Gate:FireClient(player, "failed")
			return
		end
		Remotes.Gate:FireClient(player, "retry")
		task.wait(1)
		pcall(TeleportService.TeleportAsync, TeleportService, game.PlaceId, { player }, p.opts)
	end)
	-- the client's buttons: "Try again" (a failed send) / "Back to my garage" (the owner left)
	-- (rate only — someone not let in yet uses these too: at most once in GATE_GAP s, each try asks friends / reserves a
	-- server / reads the MemoryStore — exploit audit M2)
	local lastAsk: { [Player]: number } = {}
	Players.PlayerRemoving:Connect(function(player)
		lastAsk[player] = nil
	end)
	Remotes.Gate.OnServerEvent:Connect(function(player, what)
		local now = os.clock()
		if lastAsk[player] and now - lastAsk[player] < GATE_GAP then
			return
		end
		lastAsk[player] = now
		if what == "retry" then
			GateService.retry(player)
		elseif what == "home" and GateService.closed and not pending[player] then
			sendHome(player)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(60)
			publish()
		end
	end)
end

return GateService
