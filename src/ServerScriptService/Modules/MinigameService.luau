-- Mini-games, judged on the server (docs/design/minigames.md v0.3 §3-§4, minigames_launch_set.md, the latest word:
-- notes/gpt/main/minigames_launch_decision.md). One frame for every kind: the server starts a session (an id, its own
-- clock, the values the screen draws), the client only sends what the hand did (Remotes.MinigameInput: id, a rising
-- input number, "tap" | "down" | "up" | "cells" | "quit"), and the kind's rules (`define`) turn that into hit / miss /
-- progress / done. Old or repeated inputs, another session's, a second session: dropped. Done is handled once.
-- Nothing for Timeout seconds, or "quit" (the screen's ✕, any time): the session just ends — nothing saved, nothing
-- lost, the step waits to be started again (the torque wrench keeps the same click delay).
-- Auto (Settings "Mini-games: Play | Auto", Features.Minigames): from Config.Minigame.AutoLevel, for a kind this
-- player has played by hand once and didn't ask to keep playing — the server decides, whatever the client says —
-- the session runs by itself for AutoTime seconds and ends 'Good' (never the Perfect tip). Meanwhile the other steps
-- of the job wait (Guard asks `busy`): no doing two things at once.
-- One car (decision 7): at most MaxPerCar different hand actions by hand; the wheel job gets ONE of Tire / Torque, the
-- engine bay ONE of Scrub / Coolant (a kind not tried yet is likelier). A fault's own fix past that runs as 'Good' by
-- itself (forced Auto, no chip); an extra step (Tire / Torque / Coolant) past that simply isn't asked.
-- Perfect: a small tip to whoever played it, at most TipCap a car for one player counting the star-pattern tip
-- (JobService trims that one at pay time — `tipRoom`). Three misses in a row: easier this time (no Perfect). The first
-- FirstPlays times a player meets a kind its band is wider (Perfect still counts).
--
-- To the client (Remotes.Minigame): (the kind's start event — "start" for the balancer, "scrub" for the scrub frame,
-- "fill" for the fill frame — { id, kind, ...the kind's view }) · ("hit" | "miss" | "progress", {...}) · ("auto",
-- { id, kind, time, seconds }) · the result — ("done", { id, kind, grade "Perfect" | "Good", tip?, auto?, ask? }), or
-- the kind's own (the scrub frame: "scrubResult" { id, kind, result "perfect" | "good" | "auto", money?, keepable? })
-- · ("stop", { id }). No tip = no `tip` field (never "+$0": board 18:31). `at` = where the work is (the sparkle).
-- `ask` / keepable: "first" (the first time by hand while Auto is on) or "auto" (an Auto result) — the chip "keep
-- doing this one myself" answers with SetMinigames({ keep = kind }). Screens: wr-ui Balance / Scrub / Fill / MiniFrame.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local PartGraph = require(ReplicatedStorage.Shared.PartGraph)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local FaultService = require(script.Parent.FaultService)
local Guard = require(script.Parent.Guard)
local PlayerData = require(script.Parent.PlayerData)

local MinigameService = {}

export type Session = {
	id: string,
	kind: string,
	player: Player,
	seq: number, -- the last input number taken
	t0: number, -- server clock (workspace:GetServerTimeNow) at the start
	last: number, -- os.clock of the last input (the timeout)
	auto: boolean,
	forced: boolean, -- Auto because the car had its share of hand actions (not the player's setting: no chip)
	missRow: number,
	helped: boolean, -- made easier this time: no Perfect
	wide: number, -- the band's widening this time (1 = none; the first FirstPlays times a little wider)
	finished: boolean,
	carId: number?, -- the car the work is for (the Perfect tip cap, the hand-action count)
	at: Vector3?, -- where the work is (the result carries it: wr-vfx's sparkle lands there)
	alive: (() -> boolean)?, -- the work can still go on (the car is still here, the hood still open, …)
	onStop: (() -> ())?, -- ended without a result (✕, timeout, walked off): the step frees up
	state: { [string]: any }, -- the kind's own
}

-- a kind's rules. begin: set s.state up, return what the screen draws (nil = can't start, + a notice key). input:
-- one hand action → the event to send ("hit" / "miss" / "progress" / "done") + its data; "done" ends it, data.grade =
-- "Perfect" | "Good"; a "miss" with soft = true doesn't count toward the help (just "keep going"). still: false when
-- the session can't go on (the wheel was dropped, walked away). finish: the result (always once). help: make it easier.
export type Def = {
	begin: (s: Session, opts: { [string]: any }) -> ({ [string]: any }?, string?),
	input: (s: Session, what: string, data: any, now: number) -> (string?, { [string]: any }?),
	still: ((s: Session) -> boolean)?,
	finish: (s: Session, grade: string) -> (),
	help: ((s: Session) -> ())?,
	startEvent: string?, -- (default "start")
	result: ((out: { [string]: any }) -> (string, { [string]: any }))?, -- the result as this kind's screen wants it
}

local defs: { [string]: Def } = {}
local sessions: { [Player]: Session } = {}
local nextId = 0
local rng = Random.new()

-- per car (by CarId): which kinds it had by hand, which of each pair, the Perfect tips each player got, the torque
-- click delay per player (the same after a quit — no re-rolling for an easy one). Dropped an hour after last use.
type Plan = { kinds: { [string]: boolean }, n: number, pair: { [string]: string }, tips: { [number]: number }, clickD: { [number]: number }, used: number, wheelDone: boolean? }
local plans: { [number]: Plan } = {}
local PAIR = { Tire = "wheel", Torque = "wheel", Scrub = "bay", Coolant = "bay" }

MinigameService.onEarned = nil :: ((p: Player, money: number) -> ())? -- set by Main: today's receipt

function MinigameService.define(kind: string, def: Def)
	defs[kind] = def
end

function MinigameService.defOf(kind: string): Def?
	return defs[kind] -- (play tests feed it exact server times)
end

local function on(): boolean
	return Config.feature("Minigames")
end

local function planOf(carId: number): Plan
	local p = plans[carId]
	if not p then
		p = { kinds = {}, n = 0, pair = {}, tips = {}, clickD = {}, used = os.clock() }
		plans[carId] = p
	end
	p.used = os.clock()
	return p
end

-- may this car have this kind by hand? (MaxPerCar = different kinds — a kind is asked once a car: one wheel step,
-- one coolant fill, a fault's one fix). Without peek the ask reserves it: the pair is settled, it counts
function MinigameService.claim(carId: number?, kind: string, peek: boolean?): boolean
	if not carId then
		return true
	end
	local p = planOf(carId)
	if p.kinds[kind] then
		return true
	end
	local pair = PAIR[kind]
	if (pair and p.pair[pair] and p.pair[pair] ~= kind) or p.n >= Config.Minigame.MaxPerCar then
		return false
	end
	if peek then
		return true
	end
	p.kinds[kind] = true
	p.n += 1
	if pair then
		p.pair[pair] = kind
	end
	return true
end

-- what's left of this player's Perfect-tip cap on this car (JobService trims the star-pattern tip to it at pay time)
function MinigameService.tipRoom(carId: number?, player: Player): number
	if not on() or not carId then
		return math.huge
	end
	local p = plans[carId]
	if p then
		p.used = os.clock()
	end
	return math.max(0, Config.Minigame.TipCap - ((p and p.tips[player.UserId]) or 0))
end

-- does this one go by itself (the server's own check: level, setting, played once, not kept)
function MinigameService.autoFor(player: Player, kind: string): boolean
	if not on() or ((player:GetAttribute("Level") :: number?) or 1) < Config.Minigame.AutoLevel then
		return false
	end
	local mode, plays, keep = PlayerData.minigames(player)
	return mode == "auto" and (plays[kind] or 0) >= 1 and not keep[kind]
end

function MinigameService.active(player: Player): Session?
	return sessions[player]
end

-- an Auto session is running: the job's other steps wait
function MinigameService.busy(player: Player): boolean
	local s = sessions[player]
	return s ~= nil and s.auto
end

-- hands within reach of the work (a player inside a work view stands at the view's own spot: that counts — the same
-- as the bolts, BoltService)
local function handsNear(player: Player, near: Vector3): boolean
	return player:GetAttribute("WorkZone") ~= nil or Guard.near(player, near, Config.ReachDistance + 3)
end

-- the session can go on: its kind's own check (hands near, the wheel still carried) and the job's (the car is here)
local function going(s: Session): boolean
	local def = defs[s.kind]
	return (not def.still or def.still(s)) and (not s.alive or s.alive())
end

local function stop(s: Session)
	if sessions[s.player] == s then
		sessions[s.player] = nil
	end
	if not s.finished then
		s.finished = true
		if s.onStop then
			task.spawn(s.onStop)
		end
		if s.player.Parent then
			Remotes.Minigame:FireClient(s.player, "stop", { id = s.id })
		end
	end
end
MinigameService.stop = function(player: Player)
	local s = sessions[player]
	if s then
		stop(s)
	end
end

local function complete(s: Session, grade: string, extra: { [string]: any }?)
	if s.finished then
		return
	end
	s.finished = true
	sessions[s.player] = nil
	local player = s.player
	if s.helped or s.auto or not on() then
		grade = "Good" -- (help / Auto never Perfect; off: no grades at all — the old balancer)
	end
	local ok, err = pcall(defs[s.kind].finish, s, grade)
	if not ok then
		warn("[MinigameService] finish " .. s.kind .. ": " .. tostring(err)) -- (the screen still gets its result)
	end
	local out: { [string]: any } = { id = s.id, kind = s.kind, grade = grade, auto = s.auto or nil, at = s.at }
	for k, v in extra or {} do
		if k ~= "soft" then
			out[k] = v
		end
	end
	out.grade = grade
	if grade == "Perfect" then
		local tip = math.min(Config.Minigame.PerfectTip, MinigameService.tipRoom(s.carId, player))
		if tip > 0 then
			-- (paid before it shows; the cap is counted where it's paid: one player, one car — decision 9)
			if s.carId then
				local p = planOf(s.carId)
				p.tips[player.UserId] = (p.tips[player.UserId] or 0) + tip
			end
			out.tip = tip
			PlayerData.addMoney(player, tip)
			if MinigameService.onEarned then
				MinigameService.onEarned(player, tip)
			end
		end
	end
	if not s.auto then
		local mode, plays = PlayerData.minigames(player)
		if on() and mode == "auto" and (plays[s.kind] or 0) == 0 then
			out.ask = "first" -- (Auto on, first time by hand: from next time automatic — or keep playing it)
		end
		PlayerData.minigamePlayed(player, s.kind)
	elseif on() and not s.forced then
		out.ask = "auto"
	end
	MinigameService.last = out -- (play tests read it)
	local def = defs[s.kind]
	if not player.Parent then
		return
	elseif def.result then
		Remotes.Minigame:FireClient(player, def.result(out))
	else
		Remotes.Minigame:FireClient(player, "done", out)
	end
end

-- open a session of this kind for this player (the station / prompt that opens it already checked where they are).
-- opts.carId: the car (the hand-action count — past it the fault's fix runs by itself, forced Auto). False = not now.
function MinigameService.open(player: Player, kind: string, opts: { [string]: any }?): boolean
	local def = defs[kind]
	if not def or sessions[player] or (on() and not Config.minigameKind(kind)) then
		return false -- (a kind switched off: its caller goes the old way)
	end
	local o = opts or {}
	local forced = on() and (o.forceAuto == true or not MinigameService.claim(o.carId, kind, true))
	nextId += 1
	local _, plays = PlayerData.minigames(player)
	local s: Session = {
		id = tostring(nextId),
		kind = kind,
		player = player,
		seq = 0,
		t0 = workspace:GetServerTimeNow(),
		last = os.clock(),
		auto = forced or MinigameService.autoFor(player, kind),
		forced = forced,
		missRow = 0,
		helped = false,
		wide = if on() and (plays[kind] or 0) < Config.Minigame.FirstPlays then Config.Minigame.FirstWiden else 1,
		finished = false,
		carId = o.carId,
		at = if typeof(o.at) == "Vector3" then o.at elseif typeof(o.near) == "Vector3" then o.near else nil,
		alive = o.alive,
		onStop = o.onStop,
		state = {},
	}
	if typeof(o.car) == "Instance" then
		local car, more = o.car, o.alive
		s.alive = function()
			return car.Parent ~= nil and (not more or more())
		end
	end
	local view, why = def.begin(s, o)
	if not view then
		if why then
			Remotes.Notify:FireClient(player, why, nil, "info")
		end
		return false
	end
	sessions[player] = s
	if on() and not forced then
		MinigameService.claim(o.carId, kind) -- (reserved once it really started)
	end
	if s.auto then
		Remotes.Minigame:FireClient(player, "auto", { id = s.id, kind = kind, time = Config.Minigame.AutoTime, seconds = Config.Minigame.AutoTime })
		task.delay(Config.Minigame.AutoTime, function()
			if sessions[player] == s and going(s) then
				complete(s, "Good")
			else
				stop(s)
			end
		end)
		return true
	end
	view.id = s.id
	view.kind = kind
	Remotes.Minigame:FireClient(player, def.startEvent or "start", view)
	return true
end

-- one hand action. seq: the client's rising input number (nil from the old balancer screen / the scrub screen: taken
-- as the next one)
function MinigameService.input(player: Player, id: any, seq: any, what: any, data: any)
	local s = sessions[player]
	if not s or s.finished then
		return
	end
	if id ~= nil and id ~= s.id then
		return -- (another / an old session's)
	end
	if what == "quit" then
		return stop(s) -- (the ✕, any time — Auto too: nothing given, nothing lost; its own numbering doesn't matter)
	end
	if s.auto then
		return
	end
	if seq ~= nil then
		if not Guard.num(seq, s.seq + 1, s.seq + 1000, true) then
			return -- (old, repeated or made up)
		end
		s.seq = seq
	else
		s.seq += 1
	end
	if type(what) ~= "string" then
		return
	end
	local def = defs[s.kind]
	if not going(s) then
		return stop(s)
	end
	s.last = os.clock()
	local event, out = def.input(s, what, data, workspace:GetServerTimeNow())
	if not event then
		return
	end
	if event == "done" then
		return complete(s, (out and out.grade) or "Good", out)
	end
	if event == "miss" and not (out and out.soft) then
		s.missRow += 1
		if on() and s.missRow >= Config.Minigame.HelpAfter and not s.helped and def.help then
			s.helped = true
			def.help(s)
			out = out or {}
			out.helped = true
		end
	elseif event == "hit" then
		s.missRow = 0
	end
	if out then
		out.soft = nil
	end
	Remotes.Minigame:FireClient(player, event, out)
end

-------------------------------------------------------------------------------------------------------------------
-- ③ the scrub frame — "Scrub" (the battery terminals, minigames E, BAT_CORROSION) and "Polish" (a light scratch,
-- BODY_SCRATCH_LIGHT — rubbed out with polish, no paint: car_knowledge 11 [27]). The dirt is a grid the server owns
-- (Cols x Rows, cells numbered 1.. row by row); the client sends the cell numbers its finger went over, the server
-- takes at most CellsPerSecond of them (counted from the start) and says what's left ("progress" { left, cleaned }).
-- The screen says it's finished ("tap" / MinigameScrub's finished) once at most AutoLeft cells are left unrubbed
-- (decision 5: the last one goes by itself) — then it ends as soon as the rubbed ones are taken and MinTime passed.
-- Perfect = done within PerfectTime. opts: carId, near (Vector3: hands stay within reach of it), done (() -> (): what
-- it fixes — called once, when it ends well), at / normal (Polish: where the scratch is, which way the panel faces)
-------------------------------------------------------------------------------------------------------------------
local function scrubKind(kind: string, cfg: { [string]: any }, dirt: (n: number) -> { [number]: boolean })
	MinigameService.define(kind, {
		begin = function(s, opts)
			local n = cfg.Cols * cfg.Rows
			local dirty = dirt(n)
			local list = {}
			for i in dirty do
				table.insert(list, i)
			end
			table.sort(list)
			s.state = { dirty = dirty, left = #list, taken = 0, near = opts.near, done = opts.done, waiting = {}, finishing = false }
			return { cols = cfg.Cols, rows = cfg.Rows, dirty = list, minTime = cfg.MinTime, at = opts.at, normal = opts.normal }
		end,
		still = function(s)
			local near = s.state.near
			if typeof(near) ~= "Vector3" then
				return true
			end
			return handsNear(s.player, near)
		end,
		input = function(s, what, data, now)
			local st = s.state
			local since = now - s.t0
			local n = cfg.Cols * cfg.Rows
			if what == "cells" and type(data) == "table" and #data <= n then
				for _, i in data do
					if Guard.num(i, 1, n, true) and st.dirty[i] then
						st.waiting[i] = true
					end
				end
			end
			-- (a finger can only go so fast: the cells allowed so far, counted from the start, plus a little burst — the
			-- rest wait here for the next input; the screen never has to send a cell twice)
			local budget = math.floor(since * cfg.CellsPerSecond) + 2 - st.taken
			local cleaned = {}
			for i in st.waiting do
				if budget <= 0 then
					break
				end
				st.waiting[i] = nil
				if st.dirty[i] then
					st.dirty[i] = nil
					st.left -= 1
					st.taken += 1
					budget -= 1
					table.insert(cleaned, i)
				end
			end
			local queued = 0
			for _ in st.waiting do
				queued += 1
			end
			if what == "tap" and st.left - queued <= cfg.AutoLeft then
				st.finishing = true
			end
			if st.finishing then
				if queued == 0 and since >= cfg.MinTime then
					return "done", { grade = if since <= cfg.PerfectTime * s.wide then "Perfect" else "Good" }
				elseif not st.again then
					-- (all rubbed, only too soon / still being taken in: asked again when it can be)
					st.again = true
					task.delay(math.max(cfg.MinTime - since, queued / cfg.CellsPerSecond) + 0.05, function()
						st.again = false
						MinigameService.input(s.player, s.id, nil, "tick")
					end)
				end
			end
			if #cleaned == 0 then
				return nil
			end
			return "progress", { left = st.left, cleaned = cleaned }
		end,
		finish = function(s)
			if s.state.done then
				s.state.done()
			end
		end,
		startEvent = "scrub",
		result = function(out)
			local result = if out.auto then "auto" elseif out.grade == "Perfect" then "perfect" else "good"
			return "scrubResult", { id = out.id, kind = out.kind, result = result, money = out.tip, keepable = out.ask ~= nil, ask = out.ask, at = out.at }
		end,
	})
end

-- the terminal crust: about 70% of the grid, at least half
scrubKind("Scrub", Config.Scrub, function(n)
	local dirty, count = {}, 0
	for i = 1, n do
		if rng:NextNumber() < 0.7 then
			dirty[i] = true
			count += 1
		end
	end
	while count < math.ceil(n / 2) do
		local i = rng:NextInteger(1, n)
		if not dirty[i] then
			dirty[i] = true
			count += 1
		end
	end
	return dirty
end)

-- the scratch: one wandering line across the panel (each column, a row next to the last one's), a few cells doubled
scrubKind("Polish", Config.Polish, function()
	local c = Config.Polish
	local dirty = {}
	local row = rng:NextInteger(1, c.Rows)
	for col = 1, c.Cols do
		dirty[(row - 1) * c.Cols + col] = true
		if rng:NextNumber() < 0.3 then
			local r2 = math.clamp(row + (if rng:NextNumber() < 0.5 then -1 else 1), 1, c.Rows)
			dirty[(r2 - 1) * c.Cols + col] = true
		end
		row = math.clamp(row + rng:NextInteger(-1, 1), 1, c.Rows)
	end
	return dirty
end)

-------------------------------------------------------------------------------------------------------------------
-- ② the fill frame — "Coolant" (the coolant reservoir to its F line after a new radiator, car_knowledge 04 [7]) and
-- "Tire" (a new tire to the driver's-door sticker, 03 [11]). Hold to fill, let go in the band. The level is the
-- server's: the time between the "down" and the "up" it received, times the rate (both arrive late by about the same,
-- so the hold's length survives the lag). Under the band: "Not enough" — the level stays, hold again (no penalty, soft).
-- Over: "Too full" — it drains back below the band, Perfect is gone, again. In the band: done; Perfect = the narrow
-- band right under the top (and never over-filled first).
-------------------------------------------------------------------------------------------------------------------
type FillCfg = { lo: number, hi: number, plo: number, phi: number, slack: number?, rate: number, start: number, drain: number, liquid: string, label: string?, unit: string?, max: number? }

local function fillKind(kind: string, setup: (s: Session, opts: { [string]: any }) -> FillCfg?)
	MinigameService.define(kind, {
		begin = function(s, opts)
			local c = setup(s, opts)
			if not c then
				return nil
			end
			-- (wider the first times: the band grows about its middle, the Perfect band stays)
			local mid, half = (c.lo + c.hi) / 2, (c.hi - c.lo) / 2 * s.wide
			s.state = { c = c, lo = mid - half, hi = math.min(1, mid + half), slack = c.slack or 0, level = c.start, downAt = nil, over = false, near = opts.near, done = opts.done, carId = opts.carId }
			return { lo = s.state.lo, hi = s.state.hi, rate = c.rate, level = c.start, liquid = c.liquid, label = c.label, unit = c.unit, max = c.max }
		end,
		still = function(s)
			local near = s.state.near
			return typeof(near) ~= "Vector3" or handsNear(s.player, near)
		end,
		input = function(s, what, _, now)
			local st = s.state
			if what == "down" then
				if not st.downAt then
					st.downAt = now
				end
				return nil
			elseif what ~= "up" or not st.downAt then
				return nil
			end
			local level = math.min(1, st.level + st.c.rate * (now - st.downAt))
			st.downAt = nil
			if level < st.lo then
				st.level = level
				return "miss", { reason = "under", level = level, soft = true }
			elseif level > st.hi + st.slack then
				st.over = true
				st.level = math.max(0, st.lo - st.c.drain)
				return "miss", { reason = "over", level = st.level }
			end
			st.level = level
			-- (a hair over the line, within the slack — the shake of a late "up" — is a Good fill, never a Perfect)
			local perfect = not st.over and level >= st.c.plo and level <= st.c.phi
			return "done", { grade = if perfect then "Perfect" else "Good", level = level }
		end,
		help = function(s)
			local st = s.state
			local mid, half = (st.lo + st.hi) / 2, (st.hi - st.lo) / 2 * Config.Minigame.HelpWiden
			st.lo, st.hi = mid - half, math.min(1, mid + half)
		end,
		finish = function(s, grade)
			local st = s.state
			if st.done then
				st.done(grade, if s.auto then (st.lo + st.hi) / 2 else st.level) -- (Auto: it stops in the band's middle)
			end
		end,
		startEvent = "fill",
	})
end

-- the tank: drained (a new radiator) → the L..F band, Perfect = just under F
fillKind("Coolant", function()
	local c = Config.CoolantFill
	return { lo = c.L, hi = c.F, plo = c.F - c.Perfect, phi = c.F, slack = c.Slack, rate = c.Rate, start = c.Start, drain = c.Drain, liquid = "pink" }
end)

-- the tire: a fresh one at StartPsi up to the door sticker's number (the car type's, Config.TirePsi) ± Band
fillKind("Tire", function(_, opts)
	local c = Config.TireFill
	local psi = Config.TirePsi[opts.carType or "Sedan"] or Config.TirePsi.Sedan
	local max = c.MaxPsi
	return {
		lo = (psi - c.Band) / max,
		hi = (psi + c.Band) / max,
		plo = (psi - c.Perfect) / max,
		phi = (psi + c.Perfect) / max,
		rate = c.PsiPerSecond / max,
		start = c.StartPsi / max,
		drain = c.Drain / max,
		liquid = "air",
		label = tostring(psi) .. " PSI",
		unit = "PSI",
		max = max,
	}
end)

-------------------------------------------------------------------------------------------------------------------
-- ① variant — "Torque" (the click-type torque wrench on the wheel nuts, the car down on its wheels: car_knowledge 03
-- [12][32][33], tools_real [S104][S105] "stop at the click"). Decision 3: the server picks the click delay d (Min..Max,
-- the same for this player on this car after a quit) and tells the screen, which clicks by its own clock d into the
-- hold; the judgement is the time between the "down" and the "up" the SERVER received: [d, d + Window + Slack] =
-- tight (Perfect [d, d + Perfect]), [d − Almost, d) = "Almost! Again" free, earlier = "not tight yet", later =
-- "over-tightened" — each just again (nothing breaks).
-------------------------------------------------------------------------------------------------------------------
MinigameService.define("Torque", {
	begin = function(s, opts)
		local c = Config.TorqueClick
		local d: number
		if s.carId then
			local p = planOf(s.carId)
			d = p.clickD[s.player.UserId] or rng:NextNumber(c.Min, c.Max)
			p.clickD[s.player.UserId] = d
		else
			d = rng:NextNumber(c.Min, c.Max)
		end
		local rate = c.Rate
		s.state = { d = d, window = c.Window * s.wide, downAt = nil, near = opts.near, done = opts.done }
		return { lo = rate * d, hi = math.min(1, rate * (d + s.state.window)), rate = rate, level = 0, clickAt = d, liquid = "steel" }
	end,
	still = function(s)
		local near = s.state.near
		return typeof(near) ~= "Vector3" or handsNear(s.player, near)
	end,
	input = function(s, what, _, now)
		local st, c = s.state, Config.TorqueClick
		if what == "down" then
			if not st.downAt then
				st.downAt = now
			end
			return nil
		elseif what ~= "up" or not st.downAt then
			return nil
		end
		local held = now - st.downAt
		st.downAt = nil
		if held < st.d - c.Almost then
			return "miss", { reason = "under", level = 0 }
		elseif held < st.d then
			return "miss", { reason = "under", level = 0, almost = true, soft = true }
		elseif held > st.d + st.window + c.Slack then
			return "miss", { reason = "over", level = 0 }
		end
		return "done", { grade = if held <= st.d + c.Perfect then "Perfect" else "Good" }
	end,
	help = function(s)
		s.state.window *= Config.Minigame.HelpWiden
	end,
	finish = function(s, grade)
		if s.state.done then
			s.state.done(grade)
		end
	end,
	startEvent = "fill",
})

-------------------------------------------------------------------------------------------------------------------
-- The job steps the new kinds add (Features.Minigames only — off, the job is exactly as before):
--  · the wheel job's end: the car back down on its wheels (jack lowered / lift at the floor) with wheels whose nuts
--    went on this visit → ONE prompt on a wheel: "Torque" (the click wrench) or "Inflate" (a new tire to the door
--    sticker) — whichever this car gets (the pair rule; a kind the player hasn't tried yet is likelier). Done = every
--    such wheel done (the first wheel by hand, the rest the same — design: first wheel only).
--  · the new radiator (RAD_LEAK) in and bolted → "Fill Coolant" at the coolant reservoir (hood open). The engine start
--    that checks the job afterwards doubles as bleeding the air (launch_set 2).
-- A waiting step keeps the car from going back (JobService.release asks `waiting`); not given to this car (the pair
-- rule, the cap) = no step at all.
-------------------------------------------------------------------------------------------------------------------
type Step = {
	kind: string,
	prompt: ProximityPrompt,
	holder: Instance,
	open: (Player, boolean) -> (),
	asked: { [Player]: number }, -- when each player pressed Hand back while it waited
	taken: Player?, -- someone is at it right now (one at a time: no two sessions, no two results)
	target: Instance?, -- the wheel it sits on
}
local steps: { [Model]: Step } = {}

local function wheelsOf(car: Model): { Instance }
	local out = {}
	for _, slotName in CarParts.SlotOrder do
		local slot = CarParts.Slots[slotName]
		if slot and slot.kind == "Wheel" then
			local w = CarFactory.slotPart(car, slotName)
			if w then
				table.insert(out, w)
			end
		end
	end
	return out
end

local function isDown(car: Model): boolean
	local sup = car:GetAttribute("Support")
	return ((car:GetAttribute("LiftOffset") :: number?) or 0) <= 0.05 and (sup == nil or sup == "None")
end

local function clearStep(car: Model)
	local st = steps[car]
	if st then
		steps[car] = nil
		car:SetAttribute("MgStep", nil)
		st.holder:Destroy()
	end
end

-- the nearest player at the car (whose tries weigh the pair's pick)
local function nearestTo(pos: Vector3): Player?
	local best, bestD = nil, 30
	for _, p in Players:GetPlayers() do
		local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root and (root.Position - pos).Magnitude < bestD then
			best, bestD = p, (root.Position - pos).Magnitude
		end
	end
	return best
end

-- start the step's session for this player (force = by itself as 'Good', from anywhere: the hand-back's safety). The
-- step is theirs while it runs; ended without a result it frees up; its done runs only while it is still the step
local function runStep(car: Model, st: Step, player: Player, kind: string, opts: { [string]: any }, done: (string, number?) -> ())
	opts.car = car
	opts.onStop = function()
		if steps[car] == st and st.taken == player then
			st.taken = nil
		end
	end
	opts.done = function(grade: string, level: number?)
		if steps[car] ~= st then
			return
		end
		clearStep(car)
		done(grade, level)
		task.defer(function()
			if car.Parent then
				MinigameService.carChanged(car) -- (the other step this car may still want)
			end
		end)
	end
	if MinigameService.open(player, kind, opts) then
		st.taken = player
	end
end

-- open(player, force) — see runStep
local function makeStep(car: Model, kind: string, at: BasePart, offset: CFrame, actKey: string, objKey: string, open: (Player, boolean) -> ()): Step
	clearStep(car)
	local holder = Instance.new("Attachment")
	holder.Name = "MgStep_" .. kind
	holder.CFrame = offset
	holder.Parent = at
	local p = Instance.new("ProximityPrompt")
	p.Name = "MgStepPrompt"
	p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	p.KeyboardKeyCode = Enum.KeyCode.E
	p.HoldDuration = 0
	p.MaxActivationDistance = Config.PromptDistance
	p.RequiresLineOfSight = false
	Locale.tag(p, actKey)
	Locale.tag(p, objKey, nil, "ObjectText")
	p.Parent = holder
	local st: Step = { kind = kind, prompt = p, holder = holder, open = open, asked = {} }
	p.Triggered:Connect(Guard.prompt(p, "Fix", 0.5, function(player)
		if steps[car] == st and not st.taken and not sessions[player] then
			open(player, false)
		end
	end))
	steps[car] = st
	-- (the step this car waits on, for the job card / the guide line: "Torque" | "Tire" | "Coolant"; nil = none)
	car:SetAttribute("MgStep", kind)
	return st
end

-- the wheels whose nuts went on this visit and still want the step (TightOrder = the order they went on; MgDone =
-- the order when the step was done for it)
local function wheelsWanting(car: Model): ({ Instance }, { Instance })
	local tight, fresh = {}, {}
	for _, w in wheelsOf(car) do
		local order = (w:GetAttribute("TightOrder") :: string?) or ""
		if order ~= "" and w:GetAttribute("BoltsRemaining") == w:GetAttribute("BoltCount") and w:GetAttribute("MgDone") ~= order then
			table.insert(tight, w)
			if w:GetAttribute("BoughtBy") ~= nil then
				table.insert(fresh, w)
			end
		end
	end
	return tight, fresh
end

local function markDone(list: { Instance })
	for _, w in list do
		w:SetAttribute("MgDone", w:GetAttribute("TightOrder"))
	end
end

local function wheelStep(car: Model)
	local st = steps[car]
	if st and (st.kind == "Tire" or st.kind == "Torque") then
		-- (its wheel came off again meanwhile: the step goes, picked again below once the wheels are back on)
		local t = st.target
		if st.taken or (t and t.Parent and t:GetAttribute("State") == "Installed" and table.find(wheelsWanting(car), t)) then
			st.prompt.Enabled = isDown(car) -- (only on its wheels: up again, it waits)
			return
		end
		clearStep(car)
		st = nil
	end
	if st or not on() or not isDown(car) then
		return
	end
	local tight, fresh = wheelsWanting(car)
	if #tight == 0 then
		return
	end
	local carId = car:GetAttribute("CarId") :: number?
	-- one wheel step a car (GPT r1 1): wheels done again later on this visit just count as done
	local plan = carId and plans[carId]
	if plan and plan.wheelDone then
		markDone(tight)
		return
	end
	-- which of the pair: Tire only with a new tire on; a kind the player hasn't played yet weighs Untried
	local kinds = {}
	local candidates = if #fresh > 0 then { "Tire", "Torque" } else { "Torque" }
	for _, k in candidates do
		if Config.minigameKind(k) then
			table.insert(kinds, k)
		end
	end
	if #kinds == 0 then
		markDone(tight) -- (both wheel kinds off: the job is as it was)
		return
	end
	local who = car.PrimaryPart and nearestTo(car.PrimaryPart.Position)
	local plays: { [string]: number } = {}
	if who then
		local _, p = PlayerData.minigames(who)
		plays = p
	end
	local pick: string? = nil
	local total = 0
	for _, k in kinds do
		total += if (plays[k] or 0) == 0 then Config.Minigame.Untried else 1
	end
	local r = rng:NextNumber() * total
	for _, k in kinds do
		r -= if (plays[k] or 0) == 0 then Config.Minigame.Untried else 1
		if r <= 0 then
			pick = k
			break
		end
	end
	-- (the other one if the pick isn't this car's to have; neither = no step)
	local order = { pick or kinds[1] }
	for _, k in kinds do
		if k ~= order[1] then
			table.insert(order, k)
		end
	end
	local kind: string? = nil
	for _, k in order do
		if MinigameService.claim(carId, k) then
			kind = k
			break
		end
	end
	if not kind then
		markDone(tight)
		return
	end
	local isTire = kind == "Tire"
	local target = (if isTire then fresh else tight)[1]
	local root = CarFactory.root(target)
	local step: Step
	step = makeStep(car, kind, root, CFrame.new(), if isTire then "mg.tire.prompt" else "mg.torque.prompt", "part.Wheel", function(player, force)
		if not isDown(car) then
			return
		end
		runStep(car, step, player, kind, {
			carId = carId,
			carType = car:GetAttribute("CarType"),
			near = if force then nil else root.Position,
			forceAuto = force,
			alive = function()
				return isDown(car) and target.Parent ~= nil and target:GetAttribute("State") == "Installed"
			end,
		}, function(_, level)
			markDone((wheelsWanting(car)))
			if carId then
				planOf(carId).wheelDone = true
			end
			if isTire then
				local psi = math.floor((level or 0) * Config.TireFill.MaxPsi + 0.5)
				Remotes.Notify:FireClient(player, "n.inflated", { psi = psi }, "good")
			else
				Remotes.Notify:FireClient(player, "n.torqued", nil, "good")
			end
		end)
	end)
	step.target = target
end

-- where the coolant goes in: the reservoir (its socket on the chassis, else its place in the car's part data)
local function reservoirAt(car: Model): (BasePart?, CFrame)
	local chassis = car.PrimaryPart
	if not chassis then
		return nil, CFrame.new()
	end
	local snap = chassis:FindFirstChild("Snap_CoolantReservoir")
	if snap and snap:IsA("Attachment") then
		return chassis, snap.CFrame
	end
	-- (its 3D part isn't live yet: its place from the engine-bay data, measured from the radiator's socket — the SUV's
	-- bay has the same transverse four-cylinder layout as the sedan's, ref_suv)
	local gen = ReplicatedStorage.Shared.PartData:FindFirstChild("Generated")
	local bayData = gen and gen:FindFirstChild("SedanBay")
	local ok, bay = pcall(require, bayData :: any)
	local rv = ok and type(bay) == "table" and bay.parts and bay.parts.CoolantReservoir and bay.parts.CoolantReservoir.pivot
	local radSlot = (PartGraph.slots("Sedan") :: any).Radiator
	local radSnap = chassis:FindFirstChild("Snap_Radiator")
	if typeof(rv) == "Vector3" and radSlot and radSlot.pivot and radSnap and radSnap:IsA("Attachment") then
		return chassis, CFrame.new(radSnap.Position + (rv - radSlot.pivot) + Vector3.new(0, 0.3, 0))
	end
	local rad = CarFactory.slotPart(car, "Radiator")
	return if rad then CarFactory.root(rad) else chassis, CFrame.new(0, 0.6, 0)
end

local function coolantStep(car: Model)
	if steps[car] or not on() or not Config.minigameKind("Coolant") or car:GetAttribute("CoolantFilled") then
		return
	end
	-- (the new radiator in and every bolt of it tight)
	local rad = CarFactory.slotPart(car, "Radiator")
	if FaultService.variantOf(car, "Radiator") ~= "RAD_LEAK" or not FaultService.slotOK(car, "Radiator") or not rad or rad:GetAttribute("BoltsRemaining") ~= rad:GetAttribute("BoltCount") then
		return
	end
	local carId = car:GetAttribute("CarId") :: number?
	if not MinigameService.claim(carId, "Coolant") then
		car:SetAttribute("CoolantFilled", true)
		return
	end
	local c = Config.CoolantFill
	car:SetAttribute("Level_Coolant", c.TankEmpty) -- (the old coolant went out with the old radiator)
	local at, offset = reservoirAt(car)
	if not at then
		return
	end
	local step: Step
	step = makeStep(car, "Coolant", at, offset, "mg.coolant.prompt", "part.CoolantReservoir", function(player, force)
		if not force and not car:GetAttribute("HoodOpen") then
			Remotes.Notify:FireClient(player, "n.needHood", nil, "info")
			return
		end
		runStep(car, step, player, "Coolant", {
			carId = carId,
			near = if force then nil else (at.CFrame * offset).Position,
			forceAuto = force,
			alive = function()
				return force or car:GetAttribute("HoodOpen") == true -- (the hood shut on the funnel: stop, again later)
			end,
		}, function(_, level)
			car:SetAttribute("CoolantFilled", true)
			-- (the tank's liquid: the band L..F on the screen = the L..F lines on the tank)
			local share = math.clamp(((level or c.F) - c.L) / (c.F - c.L), 0, 1)
			car:SetAttribute("Level_Coolant", c.TankL + share * (c.TankF - c.TankL))
			Remotes.Notify:FireClient(player, "n.coolantFilled", nil, "good")
		end)
	end)
	-- In the engine bay's work view every prompt is off (WorkView: "taps do the work") — the player who just bolted the
	-- radiator in is standing in it, so the fill opens for them by itself a moment later (✕ closes it; the prompt
	-- stays for when they step out). Found by the wr-mini integration test 10-22: it could not be pressed from there.
	task.delay(0.9, function()
		if steps[car] ~= step or step.taken then
			return
		end
		local who: Player? = nil
		local best = 40
		for _, p in Players:GetPlayers() do
			local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if root and p:GetAttribute("WorkZone") == "EngineBay" and p:GetAttribute("WorkCar") == carId and not sessions[p] and (root.Position - at.Position).Magnitude < best then
				who, best = p, (root.Position - at.Position).Magnitude
			end
		end
		if who then
			step.open(who, false)
		end
	end)
end

-- a part went on / came off (Main's onCarChanged, after JobService.check)
function MinigameService.carChanged(car: Model)
	coolantStep(car)
	wheelStep(car)
end

-- JobService.release: a step still waiting on this car (the notice key), else nil. The same player pressing Hand back
-- again within AskAgain seconds: the step runs by itself as 'Good' for them (never stuck behind a prompt they can't
-- reach / see — 4.5 s like Auto, no tip: no faster than doing it). Someone at it already: just the notice.
function MinigameService.waiting(car: Model, player: Player): string?
	local st = steps[car]
	if not st or not on() then
		return nil
	end
	local asked = st.asked[player]
	if not st.taken and asked and os.clock() - asked < Config.Minigame.AskAgain and not sessions[player] then
		st.asked[player] = nil
		st.open(player, true)
	else
		st.asked[player] = os.clock()
	end
	return if st.kind == "Torque" then "n.torqueFirst" elseif st.kind == "Tire" then "n.tireFirst" else "n.coolantFirst"
end

local function watchCar(car: Instance)
	if not car:IsA("Model") then
		return
	end
	local function check()
		task.defer(function()
			if car.Parent then
				wheelStep(car)
			end
		end)
	end
	car:GetAttributeChangedSignal("Support"):Connect(check)
	car:GetAttributeChangedSignal("LiftOffset"):Connect(function()
		local off = (car:GetAttribute("LiftOffset") :: number?) or 0
		if off <= 0.05 or (steps[car] and steps[car].prompt.Enabled) then
			check()
		end
	end)
	car.AncestryChanged:Connect(function()
		if not car.Parent then
			steps[car] = nil
			local id = car:GetAttribute("CarId")
			if type(id) == "number" then
				plans[id] = nil -- (handed back and gone: its tips are paid)
			end
		end
	end)
end

-- Settings' row and the chips: { mode = "play" | "auto" } · { keep = kind } · { clearKeep = true }. The server checks
-- the values and the level (the row only shows from AutoLevel)
local function onSet(player: Player, t: any)
	if type(t) ~= "table" then
		return
	end
	if t.mode == "play" or t.mode == "auto" then
		if t.mode == "auto" and (not on() or ((player:GetAttribute("Level") :: number?) or 1) < Config.Minigame.AutoLevel) then
			PlayerData.refresh(player) -- (the screen guessed: put it back)
			return
		end
		PlayerData.setMinigames(player, if t.mode == "auto" then "auto" else nil)
	elseif type(t.keep) == "string" and Config.Minigame.Kinds[t.keep] then
		PlayerData.minigameKeep(player, t.keep, true)
	elseif t.clearKeep == true then
		for kind in Config.Minigame.Kinds do
			PlayerData.minigameKeep(player, kind, false)
		end
	end
end

MinigameService.setFor = onSet

function MinigameService.start()
	Guard.busy = MinigameService.busy
	Remotes.MinigameInput.OnServerEvent:Connect(Guard.wrap("MinigameInput", 0.05, MinigameService.input))
	Remotes.SetMinigames.OnServerEvent:Connect(Guard.wrap("SetMinigames", 0.2, onSet))
	-- the scrub screen: (id, cells, finished?) → "cells", then its "finished" = "tap" (at most AutoLeft cells left)
	Remotes.MinigameScrub.OnServerEvent:Connect(Guard.wrap("MinigameScrub", 0.1, function(player: Player, id: any, cells: any, finished: any)
		if type(cells) == "table" and #cells > 0 then
			MinigameService.input(player, id, nil, "cells", cells)
		end
		if finished == true then
			MinigameService.input(player, id, nil, "tap")
		end
	end))
	Players.PlayerRemoving:Connect(function(p)
		local s = sessions[p]
		sessions[p] = nil
		if s and not s.finished then
			s.finished = true
			if s.onStop then
				task.spawn(s.onStop) -- (the step they were at frees up for the others — GPT r2 3)
			end
		end
	end)
	-- (workspace.Cars comes with the first car: never hold Main up waiting for it)
	local function watchFolder(cars: Instance)
		for _, car in cars:GetChildren() do
			watchCar(car)
		end
		cars.ChildAdded:Connect(watchCar)
	end
	local cars = workspace:FindFirstChild("Cars")
	if cars then
		watchFolder(cars)
	else
		local conn: RBXScriptConnection? = nil
		conn = workspace.ChildAdded:Connect(function(c)
			if c.Name == "Cars" and conn then
				conn:Disconnect()
				conn = nil
				watchFolder(c)
			end
		end)
	end
	-- the timeout, old car plans
	task.spawn(function()
		while true do
			task.wait(2)
			local now = os.clock()
			for _, s in sessions do
				if (not s.auto and now - s.last > Config.Minigame.Timeout) or not going(s) then
					stop(s)
				end
			end
			for id, p in plans do
				if now - p.used > 3600 then
					plans[id] = nil
				end
			end
		end
	end)
end

return MinigameService
