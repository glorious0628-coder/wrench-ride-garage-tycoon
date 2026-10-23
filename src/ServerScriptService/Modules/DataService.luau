-- Saving (DataStoreService): money, reputation (the garage level comes from it), first job done, the car book.
-- Safe in Studio and when Roblox's data stores are down: a failed load plays on with fresh numbers and NEVER saves
-- over the stored data that session (so a hiccup can't wipe anyone's progress). Saves on leave, every
-- AutoSaveSeconds, and on shutdown (BindToClose).

local DataStoreService = game:GetService("DataStoreService")

local DataService = {}

local STORE_NAME = "WrenchRide_v1"
local AUTOSAVE_SECONDS = 120
local RETRIES = 3

export type Saved = {
	v: number,
	money: number,
	rep: number,
	firstJobDone: boolean,
	tut: number,
	tutSkip: boolean,
	lang: string?,
	sound: { musicOn: boolean?, musicLv: number?, sfxOn: boolean?, sfxLv: number? }?, -- Settings' sound rows (nil = on, 4)
	codex: { [string]: number }, -- car type -> times fixed (the car book / 도감)
	jobs: number,
	owned: { [string]: boolean }, -- tools & garage upgrades bought (Shared/Equipment ids)
	lastShift: { [string]: any }?, -- the last shift's receipt (ShiftService), shown at the next join then dropped
	garageName: string?, -- the garage's name as typed (NameService filters it again whenever it's shown)
	nameFreeUsed: boolean?, -- the free first naming is spent (after that: the Garage Rename pass)
	ellaVisits: number?, -- Halloween: how many times Ella came to this player's garage
	ellaSeen: boolean?, -- watched Ella's scenes to the end once (then a tap skips them)
	seen: { [string]: boolean }?, -- one-time things already shown (the settlement line card's first Star / Team pay)
	receipts: { string }?, -- the last developer-product purchase ids paid out (StoreService: never twice)
	envDay: number?, -- Cash Envelopes: the UTC day the minutes below belong to
	envUsed: number?, -- ... minutes of work bought that day (cap StoreData.DayMinutes)
	starterGiven: boolean?, -- the Starter Pack's money is in (once a player)
	minigames: string?, -- Settings "Mini-games": "auto" (nil = Play) — MinigameService
	mgPlays: { [string]: number }?, -- mini-game kind -> times played by hand (Auto only for one played once)
	mgKeep: { [string]: boolean }?, -- kinds the player keeps playing by hand even on Auto
}

local store: DataStore? = nil
do
	local ok, res = pcall(function()
		return DataStoreService:GetDataStore(STORE_NAME)
	end)
	if ok then
		store = res
	else
		warn("[DataService] no data store (" .. tostring(res) .. "): playing without saving")
	end
end

-- per player: was the load good (only then do we save)
local loadedOk: { [Player]: boolean } = {}

local function key(player: Player): string
	return "u_" .. player.UserId
end

local function retry<T>(f: () -> T): (boolean, T | string)
	local lastErr
	for i = 1, RETRIES do
		local ok, res = pcall(f)
		if ok then
			return true, res
		end
		lastErr = res
		task.wait(i)
	end
	return false, tostring(lastErr)
end

-- Session lock (exploit audit C2): a save holds _lock = { job = this server, t = when } — taken on load, renewed by
-- every save, let go by the leave / shutdown save. A server that finds someone else's fresh lock waits (the old
-- server's leave save is a few seconds behind a fast teleport) and, if it's still held after loadWait, plays this
-- session on fresh numbers and never saves over it. A lock older than LOCK_TTL (a server that died) is taken over.
-- Old saves have no _lock: they load as before.
local LOCK_TTL = 300 -- > AUTOSAVE_SECONDS: a live server renews it well before that
DataService.loadWait = 30 -- (seconds; play tests make it short)

local function lockedByOther(t: any): boolean
	local l = type(t) == "table" and t._lock
	return type(l) == "table" and l.job ~= game.JobId and os.time() - (tonumber(l.t) or 0) < LOCK_TTL
end

-- the stored table, or nil (new player / failed load). Second value: true when it is safe to save later.
function DataService.load(player: Player): (Saved?, boolean)
	if not store then
		loadedOk[player] = false
		return nil, false
	end
	local t0 = os.clock()
	local lastErr = nil
	while player.Parent and os.clock() - t0 < DataService.loadWait do
		local mine = false
		local ok, res = pcall(function()
			return (store :: DataStore):UpdateAsync(key(player), function(old)
				mine = false
				if lockedByOther(old) then
					return nil -- (another server still has them: no write, ask again)
				end
				local t = if type(old) == "table" then old else {}
				t._lock = { job = game.JobId, t = os.time() }
				mine = true
				return t
			end)
		end)
		if ok and mine then
			loadedOk[player] = true
			local t = res :: any
			-- (a brand-new player: only the lock is stored yet — nothing to load)
			local only = type(t) == "table" and next(t) == "_lock" and next(t, "_lock") == nil
			return if type(t) == "table" and not only then t :: Saved else nil, true
		end
		lastErr = if ok then "held by another server" else tostring(res)
		task.wait(if ok then 2 else 3)
	end
	warn("[DataService] load failed for " .. player.Name .. ": " .. tostring(lastErr) .. " (this session won't save)")
	loadedOk[player] = false
	return nil, false
end

-- leaving = the last save of this session here (the lock goes with it)
function DataService.save(player: Player, data: Saved, leaving: boolean?): boolean
	if not store or not loadedOk[player] then
		return false
	end
	local lost = false
	local ok, res = retry(function()
		return (store :: DataStore):UpdateAsync(key(player), function(old)
			lost = false
			-- never write an older shape over a newer one
			if type(old) == "table" and (old.v or 0) > data.v then
				return nil
			end
			-- the lock moved to another server (it took a dead lock over): don't write over that session
			if lockedByOther(old) then
				lost = true
				return nil
			end
			local out = table.clone(data :: any)
			out._lock = if leaving then nil else { job = game.JobId, t = os.time() }
			return out
		end)
	end)
	if not ok then
		warn("[DataService] save failed for " .. player.Name .. ": " .. tostring(res))
	elseif lost then
		warn("[DataService] " .. player.Name .. "'s data is held by another server now: not saved here")
		loadedOk[player] = false
		return false
	end
	return ok
end

-- play tests only (Dev/DevHooks): a stand-in store with GetAsync / UpdateAsync, since an unpublished place has none
function DataService.useStore(fake: any)
	store = fake
end

function DataService.forget(player: Player)
	loadedOk[player] = nil
end

-- getAll() returns { [Player] = Saved } of everyone online; called for autosave and shutdown
function DataService.start(getAll: () -> { [Player]: Saved })
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_SECONDS)
			for player, data in getAll() do
				task.spawn(DataService.save, player, data, false)
			end
		end
	end)
	game:BindToClose(function()
		local pending = 0
		for player, data in getAll() do
			pending += 1
			task.spawn(function()
				DataService.save(player, data, true) -- (shutting down: the lock goes too)
				pending -= 1
			end)
		end
		local t0 = os.clock()
		while pending > 0 and os.clock() - t0 < 25 do
			task.wait(0.2)
		end
	end)
end

return DataService
