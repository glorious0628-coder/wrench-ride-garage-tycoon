-- Money, reputation, first job, the car book — per player, loaded / saved by DataService.
-- Mirrored to player attributes ("Money", "Rep", "Level", "Loaded") so the client HUD can read them; only the
-- server writes. The garage level comes from cumulative reputation (economy.md v0.2 §1) and never goes down:
-- reputation only ever adds.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.DataService)
local GateService = require(script.Parent.GateService)
local Metrics = require(script.Parent.Metrics)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local PlayerData = {}

local VERSION = 1

export type Data = DataService.Saved
local data: { [Player]: Data } = {}

-- garage level for a reputation: Lv1..16 from Config.GarageLevels, then +1 every StarLevelStep
function PlayerData.levelFor(rep: number): number
	local levels = Config.GarageLevels
	local lv = 1
	for i, need in levels do
		if rep >= need then
			lv = i
		end
	end
	if lv == #levels then
		lv += math.floor((rep - levels[#levels]) / Config.StarLevelStep)
	end
	return lv
end

-- "A,B" of the kinds a table has (sorted), nil for none
local function kindList(t: { [string]: any }?): string?
	local out = {}
	for k in t or {} do
		table.insert(out, k)
	end
	table.sort(out)
	return if #out > 0 then table.concat(out, ",") else nil
end

local function mirror(player: Player)
	local d = data[player]
	if d then
		player:SetAttribute("Money", d.money)
		player:SetAttribute("Rep", d.rep)
		player:SetAttribute("Level", PlayerData.levelFor(d.rep))
		local ids = {}
		for id in d.owned or {} do
			table.insert(ids, id)
		end
		table.sort(ids)
		player:SetAttribute("Owned", table.concat(ids, ","))
		player:SetAttribute("Tut", d.tut)
		player:SetAttribute("TutSkip", d.tutSkip or nil)
		player:SetAttribute("Lang", d.lang) -- nil until chosen: the client starts from its LocaleId
		local snd = d.sound or {}
		player:SetAttribute("MusicOn", snd.musicOn) -- (nil = the default: on, level 4 — wr-ui's Settings)
		player:SetAttribute("MusicLv", snd.musicLv)
		player:SetAttribute("SfxOn", snd.sfxOn)
		player:SetAttribute("SfxLv", snd.sfxLv)
		player:SetAttribute("GarageNamed", d.garageName ~= nil)
		player:SetAttribute("NameFree", not d.nameFreeUsed)
		player:SetAttribute("EllaSeen", d.ellaSeen or nil)
		-- the mini-game setting (wr-ui's Settings row): MgMode "auto" or nil, the kinds played by hand / kept by hand
		player:SetAttribute("MgMode", d.minigames)
		player:SetAttribute("MgPlayed", kindList(d.mgPlays))
		player:SetAttribute("MgKeep", kindList(d.mgKeep))
	end
end
PlayerData.refresh = mirror

-- the garage owner (their level / upgrades shape the garage): the one GateService fixed by UserId while they're
-- here, else whoever got here first and is still here (the owner went home: friends finish up)
local order: { Player } = {}
PlayerData.joined = Instance.new("BindableEvent") -- :Fire(player) once their save is in
PlayerData.ownerChanged = Instance.new("BindableEvent") -- :Fire(newOwner?)

function PlayerData.owner(): Player?
	for p in data do
		if p.UserId == GateService.ownerId then
			return p
		end
	end
	for _, p in order do
		if data[p] then
			return p
		end
	end
	return nil
end

function PlayerData.owns(player: Player, id: string): boolean
	local d = data[player]
	return d ~= nil and d.owned[id] == true
end

function PlayerData.addOwned(player: Player, id: string)
	local d = data[player]
	if d then
		d.owned[id] = true
		mirror(player)
	end
end

-- the server's garage level: the best one among the players here (one shared garage per server for now)
function PlayerData.garageLevel(): number
	local lv = 1
	for _, d in data do
		lv = math.max(lv, PlayerData.levelFor(d.rep))
	end
	return lv
end

-- someone here hasn't done their first job yet (the next customer brings the easy, sure one)
function PlayerData.anyoneNew(): boolean
	for _, d in data do
		if not d.firstJobDone then
			return true
		end
	end
	return false
end

-- the language picked in Settings ("en" / "ko"), saved
function PlayerData.setLang(player: Player, lang: any)
	local d = data[player]
	if d and (lang == "en" or lang == "ko") then
		d.lang = lang
		mirror(player)
	end
end

-- Settings' sound rows, saved: music / sound effects on (bool) and level (1..5); only the fields sent change
local function soundSettings(t: any): { [string]: any }
	local out = {}
	if type(t) ~= "table" then
		return out
	end
	for _, k in { "musicOn", "sfxOn" } do
		if type(t[k]) == "boolean" then
			out[k] = t[k]
		end
	end
	for _, k in { "musicLv", "sfxLv" } do
		local n = t[k]
		if type(n) == "number" and n == math.floor(n) and n >= 1 and n <= 5 then
			out[k] = n
		end
	end
	return out
end

function PlayerData.setSound(player: Player, t: any)
	local d = data[player]
	if not d then
		return
	end
	local snd: { [string]: any } = d.sound or {}
	for k, v in soundSettings(t) do
		snd[k] = v
	end
	d.sound = snd :: any
	mirror(player)
end

-- the mini-game setting (MinigameService checks the level and the kind; this only stores)
function PlayerData.minigames(player: Player): (string?, { [string]: number }, { [string]: boolean })
	local d = data[player]
	return d and d.minigames, (d and d.mgPlays) or {}, (d and d.mgKeep) or {}
end

function PlayerData.setMinigames(player: Player, mode: string?)
	local d = data[player]
	if d then
		d.minigames = if mode == "auto" then "auto" else nil
		mirror(player)
	end
end

function PlayerData.minigamePlayed(player: Player, kind: string)
	local d = data[player]
	if d then
		d.mgPlays = d.mgPlays or {}
		;(d.mgPlays :: any)[kind] = ((d.mgPlays :: any)[kind] or 0) + 1
		mirror(player)
	end
end

function PlayerData.minigameKeep(player: Player, kind: string, keep: boolean)
	local d = data[player]
	if d then
		d.mgKeep = d.mgKeep or {}
		;(d.mgKeep :: any)[kind] = if keep then true else nil
		if next(d.mgKeep :: any) == nil then
			d.mgKeep = nil
		end
		mirror(player)
	end
end

-- the tutorial stage (TutorialService): 1 first job / 2 second / 3 third car / 4 done
function PlayerData.tut(player: Player): number?
	local d = data[player]
	return d and d.tut
end

function PlayerData.setTut(player: Player, stage: number)
	local d = data[player]
	if d then
		d.tut = stage
		mirror(player)
	end
end

function PlayerData.skipTut(player: Player)
	local d = data[player]
	if d then
		d.tutSkip = true
		mirror(player)
	end
end

function PlayerData.markFirstJob(player: Player)
	local d = data[player]
	if d then
		d.firstJobDone = true
	end
end

-- true the first time `what` happens to this player (saved): the settlement line card's first Star / Team pay
function PlayerData.firstTime(player: Player, what: string): boolean
	local d = data[player]
	if not d then
		return false
	end
	local seen = d.seen or {}
	d.seen = seen
	if seen[what] then
		return false
	end
	seen[what] = true
	return true
end

-- a finished job goes in the car book
function PlayerData.recordJob(player: Player, carType: string)
	local d = data[player]
	if d then
		d.jobs += 1
		d.codex[carType] = (d.codex[carType] or 0) + 1
	end
end

function PlayerData.get(player: Player): Data?
	return data[player]
end

function PlayerData.money(player: Player): number
	local d = data[player]
	return if d then d.money else 0
end

function PlayerData.addMoney(player: Player, n: number)
	local d = data[player]
	if d then
		d.money = math.max(0, d.money + math.floor(n))
		mirror(player)
		if n > 0 then
			Metrics.mark(player, "firstMoney") -- (rival_upgrade B1 ⑦: the diagnosis fee, a core credit or a pay — whichever comes first)
		end
	end
end

-- money that can't be spent yet (StoreService: an envelope's money until its save is stored — if the save fails it
-- goes back out, and it must still be there; exploit audit L7)
local held: { [Player]: number } = {}
function PlayerData.hold(player: Player, n: number)
	local v = (held[player] or 0) + n
	held[player] = if v > 0 then v else nil
end

-- takes n if the player has it; false otherwise
function PlayerData.spend(player: Player, n: number): boolean
	local d = data[player]
	if not d or d.money - (held[player] or 0) < n then
		return false
	end
	d.money -= n
	mirror(player)
	return true
end

-- reputation only goes up (the level must never drop)
function PlayerData.addRep(player: Player, n: number)
	local d = data[player]
	if d and n > 0 then
		d.rep += math.floor(n)
		mirror(player)
	end
end

local function fresh(): Data
	return { v = VERSION, money = Config.StartMoney, rep = Config.StartReputation, firstJobDone = false, codex = {}, jobs = 0, owned = {}, tut = 1, tutSkip = false }
end

local pendingLast: { [Player]: { [string]: any } } = {} -- last time's receipt, until ShiftService takes it

-- the shift receipt kept for next time (ShiftService), or nil to keep none
function PlayerData.setLastShift(player: Player, summary: { [string]: any }?)
	local d = data[player]
	if d then
		d.lastShift = summary
	end
end

-- last time's receipt (once)
function PlayerData.takeLastShift(player: Player): { [string]: any }?
	local t = pendingLast[player]
	pendingLast[player] = nil
	return t
end

PlayerData.finalize = nil :: ((player: Player) -> ())? -- set by ShiftService: last word before the leave save

local function join(player: Player)
	-- someone being sent to their own garage never loads here (GateService decides first, ~1 s)
	if not GateService.admit(player) or not player.Parent then
		return
	end
	local saved, canSave = DataService.load(player)
	if not player.Parent then
		return -- left while loading
	end
	if not canSave and not game:GetService("RunService"):IsStudio() then
		-- tell them (once the screen is up): this visit plays on fresh numbers and won't overwrite their save
		task.delay(6, function()
			if player.Parent then
				Remotes.Notify:FireClient(player, "n.loadFailed", nil, "bad")
			end
		end)
	end
	local d = fresh()
	if saved then
		-- take what was stored, keep defaults for anything a newer version added
		d.money = tonumber(saved.money) or d.money
		d.rep = tonumber(saved.rep) or d.rep
		d.firstJobDone = saved.firstJobDone == true
		d.codex = if type(saved.codex) == "table" then saved.codex else {}
		d.jobs = tonumber(saved.jobs) or 0
		d.owned = if type(saved.owned) == "table" then saved.owned else {}
		-- saves from before the tutorial: whoever already did a job doesn't get it
		d.tut = tonumber(saved.tut) or (if d.firstJobDone then 4 else 1)
		d.tutSkip = saved.tutSkip == true
		d.lang = if saved.lang == "en" or saved.lang == "ko" then saved.lang else nil
		d.sound = soundSettings(saved.sound) :: any
		d.garageName = if type(saved.garageName) == "string" then saved.garageName else nil
		d.nameFreeUsed = saved.nameFreeUsed == true
		d.ellaVisits = tonumber(saved.ellaVisits) or 0
		d.ellaSeen = saved.ellaSeen == true
		d.seen = if type(saved.seen) == "table" then saved.seen else nil
		d.receipts = if type(saved.receipts) == "table" then saved.receipts else nil
		d.envDay = tonumber(saved.envDay)
		d.envUsed = tonumber(saved.envUsed)
		d.starterGiven = saved.starterGiven == true
		d.minigames = if saved.minigames == "auto" then "auto" else nil
		d.mgPlays, d.mgKeep = nil, nil
		for kind in Config.Minigame.Kinds do -- (only kinds there are)
			local n = type(saved.mgPlays) == "table" and tonumber(saved.mgPlays[kind])
			if n and n >= 1 then
				d.mgPlays = d.mgPlays or {}
				;(d.mgPlays :: any)[kind] = math.floor(n)
			end
			if type(saved.mgKeep) == "table" and saved.mgKeep[kind] == true then
				d.mgKeep = d.mgKeep or {}
				;(d.mgKeep :: any)[kind] = true
			end
		end
		-- last shift's receipt: shown once now (ShiftService), this session keeps its own
		pendingLast[player] = if type(saved.lastShift) == "table" then saved.lastShift else nil
	end
	data[player] = d
	if not table.find(order, player) then
		table.insert(order, player)
	end
	mirror(player)
	player:SetAttribute("Loaded", true)
	PlayerData.joined:Fire(player)
end

-- load again (play tests: after swapping in a test store)
PlayerData.reload = join

-- save this player now (StoreService: a purchase only counts once it's stored). True = it's in the data store;
-- false = no store / the load failed this session / the save failed
function PlayerData.saveNow(player: Player): boolean
	local d = data[player]
	return d ~= nil and DataService.save(player, d, false)
end

function PlayerData.start()
	GateService.onLateAdmit = join
	Players.PlayerAdded:Connect(join)
	for _, p in Players:GetPlayers() do
		task.spawn(join, p)
	end
	Players.PlayerRemoving:Connect(function(player)
		if PlayerData.finalize and data[player] then
			pcall(PlayerData.finalize, player)
		end
		pendingLast[player] = nil
		held[player] = nil
		local wasOwner = PlayerData.owner() == player
		local d = data[player]
		data[player] = nil
		local i = table.find(order, player)
		if i then
			table.remove(order, i)
		end
		if wasOwner then
			PlayerData.ownerChanged:Fire(PlayerData.owner())
		end
		if d then
			DataService.save(player, d, true) -- (the last save here: the lock goes with it)
		end
		DataService.forget(player)
	end)
	DataService.start(function()
		return table.clone(data)
	end)
end

return PlayerData
