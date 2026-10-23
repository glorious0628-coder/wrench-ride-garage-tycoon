-- Studio-only test hooks for the MCP play tests (execute_luau runs in another VM and can't see module state).
-- ServerStorage.DevCall:Invoke(command, ...) runs inside the game's VM. Never made in a live server.

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local DevHooks = {}

function DevHooks.start(S: { [string]: any })
	if not RunService:IsStudio() then
		return
	end
	local f = ServerStorage:FindFirstChild("DevCall") or Instance.new("BindableFunction")
	f.Name = "DevCall"
	f.Parent = ServerStorage
	f.OnInvoke = function(cmd: string, ...)
		local args = { ... }
		if cmd == "lift" then -- (level 1..3): bay 1's lift
			S.Lift.setLevel(S.Places.bays()[1], args[1])
			return "lift " .. tostring(args[1])
		elseif cmd == "gate" then -- ("stranger" | "friend", userId | "all") / ("check", userId?) / ("send") / ("ownerLeft")
			local Players = game:GetService("Players")
			local what, who = args[1], args[2]
			if what == "stranger" or what == "friend" then
				S.Gate.studioStrangers[who or "all"] = if what == "stranger" then true else nil
				return what .. " " .. tostring(who)
			elseif what == "check" then -- decide again for that player (the first if none) as if they just arrived
				local p = if who then Players:GetPlayerByUserId(who) else Players:GetPlayers()[1]
				return p and tostring(S.Gate.recheck(p)) or "no player"
			elseif what == "h1" then -- exploit audit H1: a stranger with a made-up invite / TeleportData doesn't get in
				-- (the last player is tested; the public-server cases need someone else playing: a 2-player test)
				local all = Players:GetPlayers()
				local p = all[#all]
				local G = S.Gate
				local was = { owner = G.ownerId, reserved = G.reserved, closed = G.closed }
				local out = {}
				G.studioStrangers[p.UserId] = true
				G.ownerId = 999
				G.fakeJoin[p] = { TeleportData = { garage = 999 } }
				table.insert(out, "stranger+garage=owner: " .. tostring(G.recheck(p)))
				G.fakeJoin[p] = { LaunchData = "999" }
				table.insert(out, "stranger+launch: " .. tostring(G.recheck(p)))
				G.reserved, G.ownerId = true, nil
				G.fakeJoin[p] = { TeleportData = { garage = 999 } }
				G.recheck(p)
				table.insert(out, "reserved owner from fake garage: " .. tostring(G.ownerId) .. (if G.ownerId == p.UserId then " (themself)" else " (!!)"))
				G.studioStrangers[p.UserId] = nil
				G.reserved, G.ownerId = true, nil
				G.recheck(p)
				table.insert(out, "friend's reserved: " .. tostring(G.ownerId))
				G.reserved, G.ownerId, G.closed = was.reserved, 999, false
				G.fakeJoin[p] = { TeleportData = { garage = 999 } }
				table.insert(out, "friend+garage=owner: " .. tostring(G.recheck(p)))
				G.fakeJoin[p] = nil
				G.ownerId, G.closed = was.owner, was.closed
				table.insert(out, "back: " .. tostring(G.recheck(p)))
				G.ownerId = was.owner
				return table.concat(out, " | ")
			elseif what == "send" then -- the first player goes through "send home" (Studio: moving screen, then failed card)
				task.spawn(S.Gate.sendHome, Players:GetPlayers()[1])
				return "sending"
			elseif what == "ownerLeft" then -- the owner-left card on every screen (without anyone leaving)
				S.Gate.closed = true
				workspace:SetAttribute("GarageClosed", true)
				S.Remotes.Gate:FireAllClients("ownerLeft", "gate.ownerLeft", { name = "Owner" })
				return "closed"
			end
			return string.format("owner=%s kind=%s closed=%s", tostring(S.Gate.ownerId), tostring(workspace:GetAttribute("GarageKind")), tostring(S.Gate.closed))
		elseif cmd == "curb" then -- (kind?): a quick-job car pulls into the QUICK SERVICE stall now ("Washer" / "Wipers")
			return "curb " .. S.Curb.force(args[1])
		elseif cmd == "ella" then -- Ella's coach next (Halloween on, no job count; needs a free bay)
			S.Halloween.force()
			return "ella coming"
		elseif cmd == "stars" then -- (level, n?, players?): draw n star cars at that level, the garage's history kept as it was
			local h = S.Faults.history
			local keep = { kinds = table.clone(h.kinds), variants = table.clone(h.variants), recent = table.clone(h.recent), lastLevel = h.lastLevel, newKinds = table.clone(h.newKinds), stars = table.clone(h.stars) }
			h.lastLevel = args[1]
			local count, samples = {}, {}
			for i = 1, args[2] or 200 do
				local plan, star = S.Faults.planStars(args[1], nil, args[3] or 1)
				count[star] = (count[star] or 0) + 1
				if i <= 8 then
					local slots = {}
					for _, f in plan do
						table.insert(slots, f.slot .. ":" .. f.variant)
					end
					table.insert(samples, star .. "* " .. table.concat(slots, "+"))
				end
			end
			for k, v in keep do
				h[k] = v
			end
			local out = {}
			for s = 1, 5 do
				table.insert(out, s .. "*=" .. (count[s] or 0))
			end
			return table.concat(out, " ") .. "\n" .. table.concat(samples, "\n")
		elseif cmd == "mix" then -- (level, n, stars?): n cars from an empty history (like a fresh server — fault_mix_dump
			-- 1022 way): the share of cars with each fault, the same fault again within 4 cars, faults a car, memory size
			local h = S.Faults.history
			local keep = { kinds = h.kinds, variants = h.variants, recent = h.recent, lastLevel = h.lastLevel, newKinds = h.newKinds, stars = h.stars, slots = h.slots }
			h.kinds, h.variants, h.recent, h.newKinds, h.stars, h.slots = {}, {}, {}, {}, {}, {}
			h.lastLevel = args[1]
			local n = args[2] or 400
			local has, again, faults, last = {}, 0, 0, {}
			for _ = 1, n do
				local plan = if args[3] then S.Faults.planStars(args[1], nil, 1) else S.Faults.plan(args[1])
				local seen, rep = {}, false
				for _, f in plan do
					if not seen[f.variant] then
						seen[f.variant] = true
						has[f.variant] = (has[f.variant] or 0) + 1
						for _, prev in last do
							if prev[f.variant] then
								rep = true
							end
						end
					end
				end
				faults += #plan
				again += if rep then 1 else 0
				table.insert(last, seen)
				if #last > 4 then
					table.remove(last, 1)
				end
			end
			local memory = #h.variants
			for k, v in keep do
				h[k] = v
			end
			local rows = {}
			for id, c in has do
				table.insert(rows, { id = id, c = c })
			end
			table.sort(rows, function(a, b)
				return a.c > b.c
			end)
			local out = {}
			for i = 1, math.min(5, #rows) do
				table.insert(out, string.format("%s %.1f%%", rows[i].id, rows[i].c / n * 100))
			end
			return string.format("Lv%d %s | BAT_DEAD %.1f%% | top: %s | again in 4: %.1f%% | faults/car %.2f | memory %d", args[1], if args[3] then "stars" else "plain",
				(has.BAT_DEAD or 0) / n * 100, table.concat(out, ", "), again / n * 100, faults / n, memory)
		elseif cmd == "fixFaults" then -- every faulty part on every car becomes new (as if replaced)
			for _, car in workspace.Cars:GetChildren() do
				for _, slot in string.split(car:GetAttribute("Faults") or "", ",") do
					if slot == "" then
						continue -- (a quick-job car has no faults)
					end
					local p = S.Factory.slotPart(car, slot)
					if p then
						p:SetAttribute("Condition", 100)
						if args[1] == "bought" then -- (as if the first player bought it; else it came from nowhere — H3 tests)
							p:SetAttribute("BoughtBy", game:GetService("Players"):GetPlayers()[1].UserId)
						end
						S.Faults.paint(p)
					end
					S.Faults.clearIssue(car, slot)
				end
				S.Carry.onCarChanged(car)
			end
			return "fixed"
		elseif cmd == "release" then -- (car name?) that / the first car is handed back by the first player (as if they pressed F)
			local car = (args[1] and workspace.Cars:FindFirstChild(args[1])) or workspace.Cars:GetChildren()[1]
			local plr = game:GetService("Players"):GetPlayers()[1]
			if car and plr then
				S.Jobs.release(car, plr)
			end
			local r = S.Jobs.last
			local lines = {}
			for _, l in r and r.lines and r.lines[plr] or {} do
				table.insert(lines, l.key .. " " .. tostring(l.money))
			end
			return "released: " .. table.concat(lines, ", ")
		elseif cmd == "dataTest" then -- save / load round trip on a stand-in store (no publishing needed)
			local Data = require(script.Parent.Parent.Modules.DataService)
			local plr = game:GetService("Players"):GetPlayers()[1]
			local mem = { ["u_" .. plr.UserId] = { v = 1, money = 1234, rep = 55, firstJobDone = true, codex = { Sedan = 3 }, jobs = 3 } }
			local fake = {}
			function fake:GetAsync(k)
				return mem[k]
			end
			function fake:UpdateAsync(k, f)
				local new = f(mem[k])
				if new ~= nil then
					mem[k] = new
				end
				return new
			end
			Data.useStore(fake)
			S.Data.reload(plr)
			local after = string.format("loaded money=%s rep=%s level=%s", tostring(plr:GetAttribute("Money")), tostring(plr:GetAttribute("Rep")), tostring(plr:GetAttribute("Level")))
			S.Data.addMoney(plr, 100)
			S.Data.addRep(plr, 30)
			S.Data.addRep(plr, -50) -- must be ignored: reputation never goes down
			S.Data.recordJob(plr, "Sedan")
			Data.save(plr, S.Data.get(plr))
			local m = mem["u_" .. plr.UserId]
			return after .. string.format(" | saved money=%d rep=%d level=%s codex.Sedan=%d jobs=%d", m.money, m.rep, tostring(plr:GetAttribute("Level")), m.codex.Sedan, m.jobs)
		elseif cmd == "guard" then -- Guard on the first player: let in, near / far from the scrap bin, the rate, NaN
			local Guard = require(script.Parent.Parent.Modules.Guard)
			local p = game:GetService("Players"):GetPlayers()[1]
			local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			local here = root and root.Position or Vector3.zero
			local r1, r2 = Guard.rate(p, "devTest", 0.5), Guard.rate(p, "devTest", 0.5)
			return string.format("player=%s near=%s far=%s nan=%s rate=%s,%s strikes=%d", tostring(Guard.player(p)), tostring(Guard.near(p, here + Vector3.new(3, 0, 0), 7)),
				tostring(Guard.near(p, here + Vector3.new(40, 0, 0), 7)), tostring(Guard.near(p, Vector3.new(0 / 0, 0, 0), 7)), tostring(r1), tostring(r2), Guard.strikes(p))
		elseif cmd == "call" then -- (service, function, args...): S[service][function](args) — "@me" = the first player,
			-- "@car" = the first car (play tests that need one server step: open the hood, enter a work zone …)
			local pl = game:GetService("Players"):GetPlayers()[1]
			local car = workspace.Cars:GetChildren()[1]
			local a = {}
			for i = 3, #args do
				a[i - 2] = if args[i] == "@me" then pl elseif args[i] == "@car" then car else args[i]
			end
			local res = table.pack(S[args[1]][args[2]](table.unpack(a, 1, #args - 2)))
			local out = {}
			for i = 1, res.n do
				out[i] = tostring(res[i])
			end
			return table.concat(out, ", ")
		elseif cmd == "mg" then -- (what): mini-games on the first player, driven from here — "scrub" (fast finger, early
			-- finish), "auto" (Lv8 + Auto: runs by itself, the job's steps wait), "balance" (a wheel: taps in / out of the
			-- green, too fast), "mode" (Auto below Lv8 is refused). Turns Dev_Minigames on.
			local M = S.Minigames
			local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
			local pl = game:GetService("Players"):GetPlayers()[1]
			workspace:SetAttribute("Dev_Minigames", true)
			local what = args[1]
			local function result()
				local r = M.last
				return if r then string.format("grade=%s tip=%s auto=%s ask=%s", tostring(r.grade), tostring(r.tip), tostring(r.auto), tostring(r.ask)) else "none"
			end
			M.last = nil
			if what == "scrub" then
				local fixed = false
				M.open(pl, "Scrub", { carId = -os.clock(), done = function()
					fixed = true
				end })
				local s = M.active(pl)
				local all = {}
				for i = 1, Config.Scrub.Cols * Config.Scrub.Rows do
					table.insert(all, i)
				end
				M.input(pl, s.id, nil, "cells", all) -- (every cell at once: the speed limit takes 2, the rest wait)
				local left0 = s.state.left
				M.input(pl, s.id, nil, "tap") -- (finished at once: held until MinTime)
				local early = s.finished
				task.wait(Config.Scrub.MinTime + 0.6)
				return string.format("left after the first send %d, done at once %s, fixed %s, %s, played %s", left0, tostring(early), tostring(fixed), result(), tostring(pl:GetAttribute("MgPlayed")))
			elseif what == "auto" then
				local lv = pl:GetAttribute("Level")
				pl:SetAttribute("Level", 8)
				S.Data.setMinigames(pl, "auto")
				pl:SetAttribute("Level", 8)
				local fixed = false
				M.open(pl, "Scrub", { done = function()
					fixed = true
				end })
				local busy = M.busy(pl)
				local Guard = require(script.Parent.Parent.Modules.Guard)
				local blocked = not Guard.free(pl, "Bolt")
				local shop = Guard.free(pl, "BuyPart")
				task.wait(Config.Minigame.AutoTime + 0.4)
				S.Data.setMinigames(pl, nil)
				S.Data.refresh(pl)
				return string.format("busy %s, bolt blocked %s, shop free %s, fixed %s, %s (level was %s)", tostring(busy), tostring(blocked), tostring(shop), tostring(fixed), result(), tostring(lv))
			elseif what == "mode" then
				S.Data.refresh(pl)
				local lv = pl:GetAttribute("Level")
				M.setFor(pl, { mode = "auto" })
				return string.format("level %s → MgMode %s", tostring(lv), tostring(pl:GetAttribute("MgMode")))
			elseif what == "balance" then
				local root = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
				local wheel = S.Carry.spawnNew("Wheel", root.CFrame * CFrame.new(0, 0, -4), pl)
				wheel:SetAttribute("Balanced", nil)
				S.Carry.pickUp(pl, wheel)
				task.wait(0.3)
				M.open(pl, "Balance", { wheel = wheel, carId = -os.clock() })
				local s = M.active(pl)
				local st = s.state
				local out = {}
				local function needle(t)
					local x = ((t - st.t0) / st.period) % 1
					return if x < 0.5 then x * 2 else 2 - x * 2
				end
				-- wait until the needle is in / out of the green (the server's clock), then tap
				local function tapWhen(wantIn)
					local back = math.clamp(pl:GetNetworkPing() / 2, 0, 0.2)
					for _ = 1, 400 do
						local t = workspace:GetServerTimeNow() - back
						local inside = math.abs(needle(t) - st.zone) <= st.width / 2 * 0.6
						local outside = math.abs(needle(t) - st.zone) > st.width / 2 + 0.15
						if (wantIn and inside) or (not wantIn and outside) then
							break
						end
						task.wait()
					end
					local h = st.hits
					M.input(pl, nil, nil, "tap")
					return st.hits > h
				end
				table.insert(out, "out→hit? " .. tostring(tapWhen(false)))
				task.wait(0.7)
				table.insert(out, "in→hit? " .. tostring(tapWhen(true)))
				local h = st.hits
				M.input(pl, nil, nil, "tap") -- (right after: under TapGap)
				table.insert(out, "too fast counted? " .. tostring(st.hits > h))
				task.wait(0.3)
				tapWhen(true)
				task.wait(0.3)
				tapWhen(true)
				task.wait(0.2)
				table.insert(out, "balanced " .. tostring(wheel:GetAttribute("Balanced")) .. " " .. result())
				S.Carry.drop(pl)
				return table.concat(out, " | ")
			elseif what == "fill" or what == "torque" then -- (wr-mini) ("fill", "Tire" | "Coolant", hold s, hold s, …) /
				-- ("torque", offset from the click s, …): each hold = "down", wait, "up" — the server's level / verdict
				local kind = if what == "torque" then "Torque" else args[2]
				local carId = args[#args] == "same" and -1 or -os.clock()
				M.open(pl, kind, { carId = carId, carType = "Sedan" })
				local s = M.active(pl)
				if not s then
					return "no session"
				end
				local out = { "band " .. string.format("%.3f-%.3f", s.state.lo or 0, s.state.hi or 0) .. (if s.state.d then string.format(" d=%.2f", s.state.d) else "") }
				for i = if what == "torque" then 2 else 3, #args do
					local h = tonumber(args[i])
					if not h or s.finished then
						continue
					end
					local t1 = workspace:GetServerTimeNow()
					M.input(pl, s.id, nil, "down")
					local want = if what == "torque" then s.state.d + h else h
					while workspace:GetServerTimeNow() - t1 < want - 0.004 do -- (task.wait overshoots by a frame)
						task.wait()
					end
					M.input(pl, s.id, nil, "up")
					local held = workspace:GetServerTimeNow() - t1
					table.insert(out, string.format("%s(held %.3f)→ level %.3f miss %d fin %s", tostring(h), held, s.state.level or 0, s.missRow, tostring(s.finished)))
					task.wait(0.1)
				end
				if not s.finished then
					M.stop(pl)
				end
				return table.concat(out, " | ") .. " | " .. result()
			elseif what == "finish" then -- (wr-mini) the first player's open fill / torque session, ended well by hand
				local s = M.active(pl)
				if not s then
					return "no session"
				end
				local kind = s.kind
				local hold = if kind == "Torque" then s.state.d + 0.3 else ((s.state.lo + s.state.hi) / 2 - s.state.level) / s.state.c.rate
				M.input(pl, s.id, nil, "down")
				task.wait(hold)
				M.input(pl, s.id, nil, "up")
				return kind .. " " .. result()
			elseif what == "sid" then -- (wr-mini) the first player's open session: id, kind, what's left (finger tests)
				local s = M.active(pl)
				return if s then string.format("%s %s left=%s taken=%s auto=%s", s.id, s.kind, tostring(s.state.left), tostring(s.state.taken), tostring(s.auto)) else "none"
			elseif what == "judge" then -- (wr-mini) the torque verdict at exact hold lengths around d (no clock jitter)
				M.open(pl, "Torque", { carId = -os.clock() })
				local s = M.active(pl)
				local def = M.defOf("Torque")
				local d = s.state.d
				local out = { string.format("d=%.2f", d) }
				for _, off in { -0.3, -0.11, -0.09, -0.01, 0, 0.2, 0.26, 0.69, 0.71 } do
					def.input(s, "down", nil, 100)
					local ev, o = def.input(s, "up", nil, 100 + d + off)
					table.insert(out, string.format("%+.2f→%s%s%s", off, tostring(ev), if o and o.reason then "/" .. o.reason else "", if o and o.grade then "/" .. o.grade elseif o and o.almost then "/almost" else ""))
				end
				M.stop(pl)
				return table.concat(out, " ")
			elseif what == "polish" then -- (wr-mini) the scratch line: every dirty cell, then the screen's finish
				local fixed = false
				M.open(pl, "Polish", { carId = -os.clock(), done = function()
					fixed = true
				end })
				local s = M.active(pl)
				local list = {}
				for i in s.state.dirty do
					table.insert(list, i)
				end
				local n = #list
				table.remove(list) -- (one cell left unrubbed: it goes by itself)
				M.input(pl, s.id, nil, "cells", list)
				M.input(pl, s.id, nil, "tap")
				task.wait(Config.Polish.MinTime + 0.8)
				return string.format("scratch cells %d, fixed %s, %s", n, tostring(fixed), result())
			elseif what == "jitter" then -- (wr-mini) ("jitter", kind, trials?, sigma?): the 'shake' test of the hold games. A
				-- player who aims right and releases with human error (sigma s) is judged by the REAL def.input with the
				-- "up" arriving U(0, J) late (a fixed lag cancels between down and up; only the shake changes the held
				-- time) for J = 0 / 0.05 / 0.15 / 0.3 — the share of Perfect / Good / retry (under, almost) / over.
				-- Torque aims d + a reaction time (mean 0.28, sigma s); Fill aims the middle of the Perfect band.
				local kind = args[2] or "Torque"
				local trials = tonumber(args[3]) or 400
				local sigma = tonumber(args[4]) or 0.08
				local def = M.defOf(kind)
				local slack0 = (Config :: any).CoolantFill.Slack
				if tonumber(args[6]) then
					(Config :: any).CoolantFill.Slack = tonumber(args[6]) -- (compare slacks: the table is the game's own, put back below)
				end
				local rngJ = Random.new(7)
				local rows = {}
				for _, J in { 0, 0.05, 0.15, 0.3 } do
					local n = { Perfect = 0, Good = 0, almost = 0, under = 0, over = 0 }
					for _ = 1, trials do
						local fake: any = { player = pl, wide = 1, carId = nil, kind = kind }
						def.begin(fake, { carType = "Sedan" })
						local st = fake.state
						local hold
						if kind == "Torque" then
							hold = st.d + math.max(0.02, 0.28 + rngJ:NextNumber(-1, 1) * sigma * 1.7)
						else
							local target = if tonumber(args[5]) then st.c.phi - tonumber(args[5]) else (st.c.plo + st.c.phi) / 2 -- (args[5]: aim this far below the line instead of the Perfect band's middle)
							local aim = (target - st.c.start) / st.c.rate
							hold = aim + rngJ:NextNumber(-1, 1) * sigma * 1.7
						end
						hold = math.max(0.01, hold)
						def.input(fake, "down", nil, 100)
						local ev, o = def.input(fake, "up", nil, 100 + hold + rngJ:NextNumber(0, J))
						if ev == "done" then
							n[o.grade] += 1
						elseif o.almost then
							n.almost += 1
						else
							n[o.reason] += 1
						end
					end
					table.insert(rows, string.format("J=%.2f P%3.0f%% G%3.0f%% almost%3.0f%% under%3.0f%% over%3.0f%%", J, n.Perfect / trials * 100, n.Good / trials * 100, n.almost / trials * 100, n.under / trials * 100, n.over / trials * 100))
				end
				(Config :: any).CoolantFill.Slack = slack0
				return kind .. " sigma " .. sigma .. (if tonumber(args[5]) then " aim F-" .. args[5] else "") .. " slack " .. tostring(args[6] or slack0) .. ": " .. table.concat(rows, " | ")
			elseif what == "kind" then -- (wr-mini) ("kind", kind, "on" | "off"): the per-kind switch (Config.Minigame.Enabled) in the game's VM
				(Config :: any).Minigame.Enabled[args[2]] = args[3] ~= "off"
				return string.format("%s enabled %s, minigameKind %s", tostring(args[2]), tostring((Config :: any).Minigame.Enabled[args[2]]), tostring((Config :: any).minigameKind(args[2])))
			elseif what == "lagprobe" then -- (wr-mini) one-way delay of the client's "down": the client's synced clock when it sent it vs the server's receive time
				M.open(pl, "Torque", { carId = nil })
				local s0 = M.active(pl)
				local HS = game:GetService("HttpService")
				local out = {}
				for _, L in { tonumber(args[2]) or 0, tonumber(args[2]) or 0, tonumber(args[2]) or 0 } do
					s0.state.downAt = nil
					local done
					local conn = game:GetService("ReplicatedStorage").Remotes.DevAck.OnServerEvent:Connect(function(_, id, res)
						if id == "lp" then
							done = res
						end
					end)
					pl:SetAttribute("DevDo", HS:JSONEncode({ cmd = "mgtrial", id = "lp", sid = s0.id, seq = 1 + #out * 2 + 50 * #out, holds = { 0.05 }, upOnly = false }))
					local t0 = os.clock()
					while not done and os.clock() - t0 < 6 do
						task.wait(0.05)
					end
					conn:Disconnect()
					task.wait(L + 0.3)
					local T = tonumber(tostring(done):match("^([%d%.]+)"))
					table.insert(out, string.format("lag %.2f: client sent %s, server got %s → one-way %s", L, tostring(T), tostring(s0.state.downAt), if T and s0.state.downAt then string.format("%.3f s", s0.state.downAt - T) else "?"))
				end
				M.stop(pl)
				return table.concat(out, " | ")
			elseif what == "lag" then -- (wr-mini) ("lag", "Torque,Tire,Coolant,Balance,Scrub,Polish", trials, sigma, "0,0.15,0.3"): the REAL input path under IncomingReplicationLag —
				-- the server opens the session, THIS player's client (DevClient mgtrial / mgbalance) holds / taps on its own clock, the
				-- server judges at receive time. Results land in workspace attribute LagResult (poll it; the run takes a few minutes).
				local kinds = string.split(tostring(args[2] or "Torque,Tire,Coolant"), ",")
				local trials = tonumber(args[3]) or 12
				local sigma = tonumber(args[4]) or 0.08
				local lags = {}
				for _, v in string.split(tostring(args[5] or "0,0.15,0.3"), ",") do
					table.insert(lags, tonumber(v))
				end
				workspace:SetAttribute("LagResult", "running")
				local HS = game:GetService("HttpService")
				local Remotes = require(game:GetService("ReplicatedStorage").Shared.Remotes)
				local rngL = Random.new(11)
				local acks = {}
				local nid = 0
				local conn = Remotes.DevAck.OnServerEvent:Connect(function(_, id, res)
					acks[tostring(id)] = tostring(res)
				end)
				local function askClient(cmd: any, wait: number): string
					nid += 1
					local id = "lg" .. nid
					cmd.id = id
					pl:SetAttribute("DevDo", HS:JSONEncode(cmd))
					local t0 = os.clock()
					while not acks[id] and os.clock() - t0 < wait do
						task.wait(0.05)
					end
					return acks[id] or "timeout"
				end
				task.spawn(function()
					local report = {}
					for _, kind in kinds do
						local def = M.defOf(kind)
						for _ = 1, 3 do
							S.Data.minigamePlayed(pl, kind) -- (past 'first times wider': the steady-state band)
						end
						local lastEv, lastO
						local orig = def.input
						def.input = function(...)
							local ev, o = orig(...)
							lastEv, lastO = ev, o
							return ev, o
						end
						for _, L in lags do
							local n = { Perfect = 0, Good = 0, almost = 0, under = 0, over = 0, none = 0, other = 0 }
							local extra = {}
							for _ = 1, trials do
								if M.active(pl) then
									M.stop(pl)
								end
								lastEv, lastO = nil, nil
								local wheel = nil
								if kind == "Balance" then
									wheel = S.Carry.spawnNew("Wheel", pl.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4), pl)
									wheel:SetAttribute("Balanced", nil)
									S.Carry.pickUp(pl, wheel)
									task.wait(0.3)
								end
								M.last = nil
								M.open(pl, kind, { carId = nil, carType = "Sedan", wheel = wheel, near = nil })
								local s = M.active(pl)
								if not s then
									n.other += 1
									continue
								end
								local st = s.state
								if kind == "Balance" then
									askClient({ cmd = "mgbalance", sid = s.id, seq = 1, n = 9, max = 14, inside = 0.5, lead = 0.08 + 1.1 * L, late = tonumber(args[6]) or 0.03 }, 20)
									task.wait(L + 0.4)
									local hits, miss = st.hits, st.misses
									n[if M.last and M.last.grade then M.last.grade else "none"] += 1
									table.insert(extra, string.format("h%d/m%d", hits, miss))
									S.Carry.drop(pl)
									task.wait(0.3)
									continue
								elseif kind == "Scrub" or kind == "Polish" then
									-- (a rub in a few messages, then the finish: the lag only delays them — the server times it by receive)
									local cells = {}
									for i in st.dirty do
										table.insert(cells, i)
									end
									table.sort(cells)
									askClient({ cmd = "mgscrub", sid = s.id, cells = cells, per = 4, gap = 0.25 }, 15)
									task.wait(L + 1.2 + (if kind == "Polish" then Config.Polish.MinTime else Config.Scrub.MinTime))
									n[if M.last and M.last.grade then M.last.grade else "none"] += 1
									task.wait(0.3)
									continue
								end
								local hold
								if kind == "Torque" then
									hold = st.d + math.max(0.02, 0.28 + rngL:NextNumber(-1, 1) * sigma * 1.7)
								else
									local aim = ((st.c.plo + st.c.phi) / 2 - st.c.start) / st.c.rate
									hold = math.max(0.05, aim + rngL:NextNumber(-1, 1) * sigma * 1.7)
								end
								askClient({ cmd = "mgtrial", sid = s.id, seq = 1, holds = { hold }, jit = tonumber(args[7]) }, hold + 6)
								task.wait(L + 0.35)
								if M.last and M.last.grade and M.last.kind == kind then
									n[M.last.grade] += 1
								elseif lastEv == "miss" and lastO then
									n[if lastO.almost then "almost" else (lastO.reason or "other")] += 1
								else
									n.none += 1
								end
							end
							table.insert(report, string.format("%s lag %.2f jit %s sigma %.2f n=%d: Perfect %d Good %d almost %d under %d over %d none %d other %d %s", kind, L, tostring(args[7] or 0), sigma, trials, n.Perfect, n.Good, n.almost, n.under, n.over, n.none, n.other, table.concat(extra, " ")))
							workspace:SetAttribute("LagResult", "running\n" .. table.concat(report, "\n"))
						end
						def.input = orig
					end
					conn:Disconnect()
					if M.active(pl) then
						M.stop(pl)
					end
					workspace:SetAttribute("LagResult", "done\n" .. table.concat(report, "\n"))
				end)
				return "started"
			elseif what == "quit" then -- (wr-mini) inputs 1..3, then the ✕ with the screen's own number 1
				M.open(pl, "Torque", { carId = -os.clock() })
				local s = M.active(pl)
				M.input(pl, s.id, 1, "down")
				M.input(pl, s.id, 2, "up")
				M.input(pl, s.id, 3, "down")
				M.input(pl, s.id, 1, "quit")
				return string.format("after quit active %s, finished %s, %s", tostring(M.active(pl) ~= nil), tostring(s.finished), result())
			elseif what == "cap" then -- (wr-mini) three Perfect fills on one car by one player: the tips (cap TipCap)
				local carId = -os.clock()
				local tips = {}
				for _ = 1, 3 do
					M.open(pl, "Coolant", { carId = carId })
					local s = M.active(pl)
					local c = Config.CoolantFill
					M.input(pl, s.id, nil, "down")
					task.wait((c.F - c.Perfect / 2 - c.Start) / c.Rate)
					M.input(pl, s.id, nil, "up")
					table.insert(tips, tostring(M.last and M.last.tip) .. "/" .. tostring(M.last and M.last.grade))
					task.wait(0.1)
				end
				return "tips " .. table.concat(tips, ", ") .. string.format(" room left %s", tostring(M.tipRoom(carId, pl)))
			end
			return "mg ?"
		elseif cmd == "lockTest" then -- the session lock (exploit audit C2) on a stand-in store: old save, held, dead, stolen
			local Data = require(script.Parent.Parent.Modules.DataService)
			local plr = game:GetService("Players"):GetPlayers()[1]
			local k = "u_" .. plr.UserId
			local mem = {}
			local fake = {}
			function fake:GetAsync(key)
				return mem[key]
			end
			function fake:UpdateAsync(key, f)
				local new = f(mem[key])
				if new ~= nil then
					mem[key] = new
				end
				return new
			end
			Data.useStore(fake)
			local wait0 = Data.loadWait
			Data.loadWait = 3
			local out = {}
			local function lockOf()
				local l = mem[k] and mem[k]._lock
				return if l == nil then "none" elseif l.job == game.JobId then "mine" else "other"
			end
			-- 1 an old save (no lock): loads, the lock is now this server's
			mem[k] = { v = 1, money = 1234, rep = 5 }
			local d, ok = Data.load(plr)
			table.insert(out, string.format("old: ok=%s money=%s lock=%s", tostring(ok), tostring(d and d.money), lockOf()))
			-- 2 a save keeps it, the leave save lets it go
			Data.save(plr, { v = 1, money = 2000 } :: any, false)
			local held = lockOf()
			Data.save(plr, { v = 1, money = 2100 } :: any, true)
			table.insert(out, string.format("save: %s, leave: %s money=%d", held, lockOf(), mem[k].money))
			-- 3 another live server holds them: no load, and this session never saves
			mem[k] = { v = 1, money = 777, _lock = { job = "other-server", t = os.time() } }
			d, ok = Data.load(plr)
			local wrote = Data.save(plr, { v = 1, money = 99999 } :: any, false)
			table.insert(out, string.format("held: ok=%s saved=%s money=%d lock=%s", tostring(ok), tostring(wrote), mem[k].money, lockOf()))
			-- 4 a dead server's old lock: taken over
			mem[k] = { v = 1, money = 888, _lock = { job = "dead-server", t = os.time() - 400 } }
			d, ok = Data.load(plr)
			table.insert(out, string.format("dead: ok=%s money=%s lock=%s", tostring(ok), tostring(d and d.money), lockOf()))
			-- 5 someone took it from us meanwhile: our save stops there
			mem[k]._lock = { job = "thief-server", t = os.time() }
			wrote = Data.save(plr, { v = 1, money = 55555 } :: any, false)
			local again = Data.save(plr, { v = 1, money = 66666 } :: any, true)
			table.insert(out, string.format("stolen: saved=%s again=%s money=%d", tostring(wrote), tostring(again), mem[k].money))
			-- 6 a brand-new player: only a lock gets stored, the load is "no data"
			mem[k] = nil
			d, ok = Data.load(plr)
			table.insert(out, string.format("new: ok=%s data=%s lock=%s", tostring(ok), tostring(d ~= nil), lockOf()))
			Data.loadWait = wait0
			S.Data.reload(plr) -- (back to this player's data on the fake store)
			return table.concat(out, " | ")
		elseif cmd == "fault" then -- (slot, variant, ...): re-roll the parked car with exactly these faults
			local car = workspace.Cars:GetChildren()[1]
			local plan = {}
			for i = 1, #args, 2 do
				table.insert(plan, { slot = args[i], variant = args[i + 1] })
			end
			for name in car:GetAttributes() do
				if name:sub(1, 6) == "Issue_" then
					S.Faults.clearIssue(car, name:sub(7)) -- the old faults' leftovers
				end
			end
			S.Faults.roll(car, plan)
			car:SetAttribute("Clues", nil)
			local v = require(game.ReplicatedStorage.Shared.Faults).ById[args[2]]
			car:SetAttribute("Symptom", v and v.say or "say.hello")
			for _, slot in require(game.ReplicatedStorage.Shared.CarParts).SlotOrder do
				S.Factory.reseat(car, slot)
			end
			S.Carry.onCarChanged(car)
			return "faults " .. tostring(car:GetAttribute("Variants"))
		elseif cmd == "cartype" then -- (CarType): the next customer's car is this type
			S.Customers.forceType = args[1]
			return "next car type " .. tostring(args[1])
		elseif cmd == "kind" then -- (kind): the next customer is this kind
			S.Customers.forceKind = args[1]
			return "next kind " .. tostring(args[1])
		elseif cmd == "age" then -- (seconds): the parked car has been waiting this much longer
			local car = workspace.Cars:GetChildren()[1]
			car:SetAttribute("ParkedAt", (car:GetAttribute("ParkedAt") or workspace:GetServerTimeNow()) - args[1])
			return "aged " .. tostring(args[1])
		elseif cmd == "ask" then -- (cmd table): the first player's client does it through DevClient (real prompts / remotes)
			local HS = game:GetService("HttpService")
			local pl = game:GetService("Players"):GetPlayers()[1]
			local c = args[1]
			c.id = "ask" .. tostring(os.clock())
			local done
			local conn = game:GetService("ReplicatedStorage").Remotes.DevAck.OnServerEvent:Connect(function(_, id, res)
				if id == c.id then
					done = res
				end
			end)
			pl:SetAttribute("DevDo", HS:JSONEncode(c))
			local t0 = os.clock()
			while not done and os.clock() - t0 < 10 do
				task.wait(0.1)
			end
			conn:Disconnect()
			return tostring(done)
		elseif cmd == "tut" then -- (stage): every player's tutorial stage (1..4)
			for _, p in game:GetService("Players"):GetPlayers() do
				S.Data.setTut(p, args[1])
			end
			return "tut " .. tostring(args[1])
		elseif cmd == "pickup" then -- (part): the first player picks it up (skips the prompt: play-test harness only)
			local pl = game:GetService("Players"):GetPlayers()[1]
			S.Carry.pickUp(pl, args[1])
			return "carried " .. tostring(S.Carry.carried(pl))
		elseif cmd == "install" then -- (car, slot): the first player puts what they carry on that slot
			local pl = game:GetService("Players"):GetPlayers()[1]
			S.Carry.install(pl, args[1], args[2])
			return "installed"
		elseif cmd == "piston" then -- (car, corner): push the caliper piston back (the PistonPrompt's job)
			local cal = args[1].Moving:FindFirstChild("BrakeCaliper_" .. args[2])
			cal:SetAttribute("PistonIn", true)
			cal.PistonPrompt.Enabled = false
			S.Cars.touch(args[1], game:GetService("Players"):GetPlayers()[1])
			return "piston in"
		elseif cmd == "touch" then -- (car?): the first player counts as having worked on it (the tutorial moves on)
			local car = args[1] or workspace.Cars:GetChildren()[1]
			S.Cars.touch(car, game:GetService("Players"):GetPlayers()[1])
			return "touched " .. tostring(car)
		elseif cmd == "oldpart" then -- (kind): a worn-out part on the floor beside the first player (auto scrap tests)
			local pl = game:GetService("Players"):GetPlayers()[1]
			local root = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
			local part = S.Carry.spawnNew(args[1] or "BrakePads", root.CFrame * CFrame.new(0, 0, -4), pl)
			part:SetAttribute("Condition", 10)
			part:SetAttribute("Fresh", nil)
			part:SetAttribute("BoughtBy", nil)
			return "old " .. part:GetFullName()
		elseif cmd == "config" then -- (key, value): change a Shared/Config number in the game's VM (shorter waits)
			local Config = require(game:GetService("ReplicatedStorage").Shared.Config) :: any
			Config[args[1]] = args[2]
			return args[1] .. " = " .. tostring(args[2])
		elseif cmd == "store" then -- (what, ...): the Robux items without Roblox — "test" "Key,Key" (switch on for the
			-- first player) · "pass" Key on? (own it or not) · "buy" Key purchaseId? (a Cash Envelope's receipt: same id
			-- twice = paid once) · "state"
			local plr = game:GetService("Players"):GetPlayers()[1]
			local what = args[1]
			if what == "test" then
				plr:SetAttribute("StoreTest", args[2])
			elseif what == "pass" then
				S.Passes.fake(plr, args[2], args[3] ~= false)
				S.Store.ready(plr)
			elseif what == "buy" then
				local before = plr:GetAttribute("Money")
				local r = S.Store.grant(plr, args[2], args[3] or ("test_" .. math.random(1, 1e9)))
				return string.format("%s money %s -> %s EnvLeft %s", r.Name, tostring(before), tostring(plr:GetAttribute("Money")), tostring(plr:GetAttribute("EnvLeft")))
			elseif what == "race" then -- (Key): the same receipt asked twice while the first one's save is still going (audit C3)
				local pid = require(game.ReplicatedStorage.Shared.Config).Products[args[2] or "CashSmall"]
				local id = "race_" .. math.random(1, 1e9)
				local saveNow = S.Data.saveNow
				S.Data.saveNow = function(p)
					task.wait(1) -- (a slow data store)
					return saveNow(p)
				end
				local before = plr:GetAttribute("Money")
				local res, spendMid = {}, nil
				for i = 1, 2 do
					task.spawn(function()
						res[i] = S.Store.processReceipt({ PlayerId = plr.UserId, ProductId = pid, PurchaseId = id }).Name
					end)
				end
				task.wait(0.3)
				spendMid = S.Data.spend(plr, plr:GetAttribute("Money") :: number) -- (all of it mid-save: the envelope part is held)
				task.wait(1.5)
				S.Data.saveNow = saveNow
				local third = S.Store.processReceipt({ PlayerId = plr.UserId, ProductId = pid, PurchaseId = id }).Name
				return string.format("1st %s 2nd %s 3rd %s | money %s -> %s | spend mid-save %s", tostring(res[1]), tostring(res[2]), third, tostring(before), tostring(plr:GetAttribute("Money")), tostring(spendMid))
			end
			local d = S.Data.get(plr) :: any
			local owns = {}
			for _, it in require(game.ReplicatedStorage.Shared.StoreData).Items do
				if plr:GetAttribute("Owns" .. it.key) then
					table.insert(owns, it.key)
				end
			end
			return string.format("money %s EnvLeft %s owns %s VIP %s walk %.1f starterGiven %s receipts %d", tostring(plr:GetAttribute("Money")), tostring(plr:GetAttribute("EnvLeft")),
				table.concat(owns, ","), tostring(plr:GetAttribute("VIP")), S.Store.walk(plr), tostring(d and d.starterGiven), d and d.receipts and #d.receipts or 0)
		elseif cmd == "money" then -- (n): add cash to every player
			for _, p in game:GetService("Players"):GetPlayers() do
				S.Data.addMoney(p, args[1])
			end
			return "money +" .. tostring(args[1])
		elseif cmd == "rep" then -- (n): add reputation to every player (level up for tests)
			for _, p in game:GetService("Players"):GetPlayers() do
				S.Data.addRep(p, args[1])
			end
			return "rep +" .. tostring(args[1])
		elseif cmd == "trap" then -- (slot, variant): turn the parked car's slot into that trap (play tests)
			local car = workspace.Cars:GetChildren()[1]
			local v = require(game.ReplicatedStorage.Shared.Faults).ById[args[2]]
			car:SetAttribute("Issue_" .. args[1], v.fix)
			car:SetAttribute("Faults", args[1])
			car:SetAttribute("Variants", args[1] .. "=" .. args[2])
			car:SetAttribute("Symptom", v.say)
			S.Faults.trapClue(car, args[1], v.fix)
			S.Carry.onCarChanged(car)
			return "trap " .. args[2]
		elseif cmd == "plan" then -- (level, n): roll n plans at a level, count kinds / variants / traps
			local counts, traps, repeats3, repeats2, sameSlot = {}, 0, 0, 0, 0
			local last, lastSlot = {}, nil
			for _ = 1, args[2] or 200 do
				local plan = S.Faults.plan(args[1] or 1)
				for _, f in plan do
					counts[f.variant] = (counts[f.variant] or 0) + 1
					local v = require(game.ReplicatedStorage.Shared.Faults).ById[f.variant]
					if v and v.fix ~= "replace" then
						traps += 1
					end
				end
				local k = plan[1] and S.Factory and string.match(plan[1].slot, "^[^_]+") or "-"
				table.insert(last, k)
				if #last >= 3 and last[#last] == last[#last - 1] and last[#last] == last[#last - 2] then
					repeats3 += 1
				end
				if #last >= 2 and last[#last] == last[#last - 1] then
					repeats2 += 1
				end
				if plan[1] and plan[1].slot == lastSlot then
					sameSlot += 1
				end
				lastSlot = plan[1] and plan[1].slot
			end
			local out = {}
			for id, c in counts do
				table.insert(out, id .. "=" .. c)
			end
			table.sort(out)
			return table.concat(out, " ") .. string.format(" | traps=%d, 3-in-a-row=%d, 2-in-a-row=%d, same slot=%d", traps, repeats3, repeats2, sameSlot)
		elseif cmd == "job" then -- the first car's job state
			local car = workspace.Cars:GetChildren()[1]
			return car and string.format("faults=%s ready=%s assembled=%s", tostring(car:GetAttribute("Faults")), tostring(car:GetAttribute("Ready")), tostring(S.Jobs.assembled(car))) or "no car"
		end
		return "unknown " .. tostring(cmd)
	end
end

return DevHooks
