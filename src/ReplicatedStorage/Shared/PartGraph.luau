-- The parts graph (notes/handoff/sessions/wr-dev_teardown_plan.md §2): every part a car is made of is one row of data
-- in ReplicatedStorage.Shared.PartData.Cars.<Type> — what it is (kind), where it sits, what has to come off first
-- (needs), how it leaves the car. A new part = a new row; a new car type = a file that says how it differs from its
-- base. CarParts builds its Slots from here (the same shape as before), so the rest of the code doesn't change.
--
-- needs: another part's id = that part has to be OFF — to take this one off and to put it back (one rule both ways,
-- so putting a car together is the teardown backwards without writing it down) — or a condition (CONDITIONS below;
-- CarService.check knows each one, a new one goes in both places).
-- Corner rows (id ending "_*") stand for all four wheels: * = FL / FR / RL / RR in the id, zone and needs; `at` is the
-- offset from the wheel centre on a LEFT corner (right corners: x mirrored, and turned 180° about Y if `mirror`).
-- A derived type (`base = "Sedan"`) starts from its base's rows: `move` (a Vector3 = new pivot, { by = v } = shifted),
-- `set` (fields to replace), `remove` (ids), `add` (more rows); its corner rows sit on its own `wheels`.

export type Row = {
	id: string,
	kind: string,
	pivot: Vector3?, -- car space (car_spec 0); corner rows use `at`
	at: Vector3?,
	zone: string, -- the work zone ("EngineBay", "Wheel_*", "Body_Front", ...: the scan's "Check here")
	liftEnd: string?, -- "F" | "R": the end that has to be up for it (corner rows: from the corner)
	needs: { string }?,
	detach: string, -- "Drop" (falls to the floor) | "Pop" (pops out of the bay and stays)
	faultable: boolean?,
	turned: boolean?, -- a part turned 180° about Y in its slot (one bumper model for both ends)
	mirror: boolean?, -- corner rows: the right-side copy is the left model turned 180°
	yaw: number?, -- degrees about Y for the snap
	starDepth: number?, -- the depth the car stars count for it, when the chain alone says one more (fault_mix v0.2 ③)
}

export type Part = {
	id: string,
	kind: string,
	pivot: Vector3,
	at: Vector3?,
	zone: string,
	liftEnd: string?,
	needs: { string },
	detach: string,
	faultable: boolean?,
	turned: boolean?,
	yaw: number?,
	corner: string?,
	starDepth: number?,
}

export type Car = {
	name: string,
	wheels: { [string]: Vector3 },
	parts: { [string]: Part },
	order: { string }, -- ids, sorted
	problems: { string }, -- what's wrong with the data (empty = fine); PartGraph.check prints them
}

local Shared = script.Parent
local PartData = Shared:WaitForChild("PartData")
local Kinds = require(PartData:WaitForChild("Kinds")) :: { [string]: any }
local CarsFolder = PartData:WaitForChild("Cars")

local PartGraph = {}

local Config = require(Shared:WaitForChild("Config"))
local Car3D = require(PartData:WaitForChild("Car3D"))

-- the ids of a type's piece-E rows (its own bayIds, else its base's — a derived type keeps its base's rows)
local function lumpRowIds(typeName: string): { [string]: boolean }
	for _ = 1, 8 do
		local m = CarsFolder:FindFirstChild(typeName)
		local d = if m and m:IsA("ModuleScript") then require(m) :: any else nil
		if not d then
			return {}
		elseif d.bayIds or not d.base then
			return d.bayIds or {}
		end
		typeName = d.base
	end
	return {}
end

-- piece E: a decor lump whose parts come apart on this car type (wr-dev plan §4) — Features.NewParts on, the type's
-- Config.LiveLumps row (Studio: workspace Dev_Lump_<lump>), and outside Studio every part mesh of it baked
-- (ReplicatedStorage.CarMeshes.<id>_Detail). Read once per car type (the graph is cached): set it before the game runs.
-- (the corner lumps Deco_Hub_F / _R are piece E2, the suspension: their own switch Features.E2Susp and their own 3D
-- data <type>Susp — main 10-22)
local liveSeen: { [string]: boolean } = {} -- (a lump found live stays live: its meshes don't go away mid-game)
function PartGraph.lumpLive(typeName: string, lump: string): boolean
	if liveSeen[typeName .. "|" .. lump] then
		return true
	end
	local susp = lump:sub(1, 9) == "Deco_Hub_"
	-- (the body's lumps — Decor_Shell / Glass / Chassis, the interior blocks — their own switch, NewBody)
	local body = lump:sub(1, 6) == "Decor_" or lump == "Deco_Interior" or lump == "Deco_Dash"
	if not Config.feature(if susp then "E2Susp" elseif body then "NewBody" else "NewParts") then
		return false
	end
	local key = Car3D.key(lump)
	local studio = game:GetService("RunService"):IsStudio()
	local row = Config.LiveLumps[typeName]
	-- (a type with no row has no new parts at all yet; a row needs the type's own 3D sets too — Generated/<type>Bay …)
	local on = row ~= nil and (row[lump] == true or (studio and workspace:GetAttribute("Dev_Lump_" .. lump) == true))
	if not on then
		return false
	end
	-- (Studio: blocks stand in for meshes that aren't baked yet — the type's 3D data must be there all the same)
	local meshes = game:GetService("ReplicatedStorage"):FindFirstChild("CarMeshes")
	local gen = PartData:FindFirstChild("Generated")
	if not gen or (not meshes and not studio) then
		return false
	end
	-- (the type's 3D sets: <type>Bay, <type>Under, <type>Susp — the one that has this lump. Baked = each part row's
	-- own <id>_Detail (the corner set: every part's) and the lump's fixed decor Decor_<lump>V2 — the underside's part
	-- nodes with no row yet are drawn in that decor)
	-- (each type's meshes carry its prefix: Crossover_AirBoxLid_Detail, Crossover_Decor_EngineBayV2 — Car3D.prefix)
	local rows = lumpRowIds(typeName)
	local prefix = Car3D.prefix(typeName)
	local found = false
	for _, set in gen:GetChildren() do
		local rest = set.Name:sub(#typeName + 1)
		if set:IsA("ModuleScript") and set.Name:sub(1, #typeName) == typeName and (if susp then rest == "Susp" else table.find(Car3D.SETS, rest) ~= nil) then
			local under = rest == "Under"
			for id, p in (require(set) :: any).parts do
				if p.lump == lump then
					found = true
					if studio then
						continue
					end
					if p.role == "part" and (susp or rows[id]) and not meshes:FindFirstChild(prefix .. id .. "_Detail") then
						return false
					end
					-- (the underside bakes its seen-from-above nodes apart: that decor must be there too)
					if under and p.show == "both" and not meshes:FindFirstChild(prefix .. "Decor_" .. key .. "V2Both") then
						return false
					end
				end
			end
		end
	end
	local live = found and (susp or studio or meshes:FindFirstChild(prefix .. "Decor_" .. key .. "V2") ~= nil)
	liveSeen[typeName .. "|" .. lump] = live or nil
	return live
end

-- a row that exists on this type now: no lump, or its lump live (P5 rows: that piece's switch too)
local function rowLive(typeName: string, r: { [string]: any }): boolean
	if not r.lump then
		return true
	end
	return PartGraph.lumpLive(typeName, r.lump) and (not r.p5 or Config.feature("NewPartsP5"))
		and (not r.later or Config.feature("NewPartsLater"))
		and (not r.oil or (Config.feature("OilChange") and Config.feature("UnderView")))
		and (not r.under or Config.feature("UnderView")) -- (the under covers: worked from the creeper — Cars/SedanCovers)
end

-- the conditions a `needs` entry can name (anything with a ":" is a condition, not a part)
PartGraph.CONDITIONS = { ["Hood:Open"] = true, ["Lift:Wheel"] = true, ["Lift:Under"] = true }
-- per corner (corner rows write "Arm:*"): the floor jack under that corner's lower arm, the car on its stands —
-- piece E2 (full_teardown §0-2 Support:Arm: a knuckle / arm that comes loose hangs on the jack, not on the car)
for _, c in { "FL", "FR", "RL", "RR" } do
	PartGraph.CONDITIONS["Arm:" .. c] = true
end

function PartGraph.isCondition(need: string): boolean
	return string.find(need, ":", 1, true) ~= nil
end

local DETACH = { Drop = true, Pop = true, Swing = true } -- (Swing: stays on, hinged down on its inner bolt — E2)

local rawCache: { [string]: any } = {}
local function rawOf(name: string): any
	if rawCache[name] == nil then
		local m = CarsFolder:FindFirstChild(name)
		rawCache[name] = if m and m:IsA("ModuleScript") then require(m) else false
	end
	return rawCache[name] or nil
end

local function copyRow(r: { [string]: any }): { [string]: any }
	local c = table.clone(r)
	if r.needs then
		c.needs = table.clone(r.needs)
	end
	return c
end

-- a type's rows (its base's, changed by move / set / remove / add) and its wheel centres
local function rowsOf(name: string, problems: { string }, depth: number?): ({ { [string]: any } }, { [string]: Vector3 })
	local d = rawOf(name)
	if not d then
		table.insert(problems, "no data for car type " .. name)
		return {}, {}
	end
	if not d.base then
		local rows = {}
		for _, r in d.parts or {} do
			table.insert(rows, copyRow(r))
		end
		return rows, d.wheels or {}
	end
	if (depth or 0) > 8 then
		table.insert(problems, name .. ": base chain too long (a loop?)")
		return {}, {}
	end
	local rows, baseWheels = rowsOf(d.base, problems, (depth or 0) + 1)
	local byId: { [string]: { [string]: any } } = {}
	for _, r in rows do
		byId[r.id] = r
	end
	for id, to in d.move or {} do
		local r = byId[id]
		if not r then
			table.insert(problems, name .. ": move of unknown part " .. id)
		elseif typeof(to) == "Vector3" then
			r.pivot = to
		elseif type(to) == "table" and typeof(to.by) == "Vector3" and r.pivot then
			r.pivot = (r.pivot :: Vector3) + to.by
		else
			table.insert(problems, name .. ": bad move for " .. id)
		end
	end
	for id, fields in d.set or {} do
		local r = byId[id]
		if not r then
			table.insert(problems, name .. ": set on unknown part " .. id)
		else
			for k, v in fields do
				r[k] = v
			end
		end
	end
	local gone = {}
	for _, id in d.remove or {} do
		if not byId[id] then
			table.insert(problems, name .. ": remove of unknown part " .. id)
		end
		gone[id] = true
	end
	local out = {}
	for _, r in rows do
		if not gone[r.id] then
			table.insert(out, r)
		end
	end
	for _, r in d.add or {} do
		table.insert(out, copyRow(r))
	end
	return out, d.wheels or baseWheels
end

local function star(s: string?, corner: string?): string?
	if s and corner then
		return (string.gsub(s, "%*", corner))
	end
	return s
end

local function partFrom(r: { [string]: any }, id: string, pivot: Vector3, corner: string?, turned: boolean?): Part
	local needs = {}
	for _, n in r.needs or {} do
		table.insert(needs, star(n, corner) :: string)
	end
	return {
		id = id,
		kind = r.kind,
		pivot = pivot,
		at = r.at,
		zone = star(r.zone, corner) :: string,
		liftEnd = r.liftEnd or (if corner then corner:sub(1, 1) else nil),
		needs = needs,
		detach = r.detach,
		faultable = r.faultable,
		turned = turned,
		yaw = r.yaw,
		corner = corner,
		starDepth = r.starDepth,
	}
end

-- every way the data can be wrong that would stop a car being taken apart or put back together
local function validate(car: Car)
	local problems = car.problems
	for _, id in car.order do
		local p = car.parts[id]
		if not Kinds[p.kind] then
			table.insert(problems, id .. ": unknown kind " .. tostring(p.kind))
		end
		if type(p.zone) ~= "string" or p.zone == "" then
			table.insert(problems, id .. ": no zone")
		end
		if not DETACH[p.detach] then
			table.insert(problems, id .. ": detach must be Drop or Pop")
		end
		for _, n in p.needs do
			if PartGraph.isCondition(n) then
				if not PartGraph.CONDITIONS[n] then
					table.insert(problems, id .. ": unknown condition " .. n)
				end
			elseif n == id then
				table.insert(problems, id .. ": needs itself")
			elseif not car.parts[n] then
				table.insert(problems, id .. ": needs unknown part " .. n)
			end
		end
	end
	-- loops ("A before B before A"): such a car could never come apart
	local state: { [string]: number } = {} -- 1 = on the way, 2 = done
	local function visit(id: string, trail: { string })
		if state[id] == 2 then
			return
		elseif state[id] == 1 then
			table.insert(problems, "loop: " .. table.concat(trail, " > ") .. " > " .. id)
			return
		end
		state[id] = 1
		table.insert(trail, id)
		for _, n in car.parts[id].needs do
			if car.parts[n] then
				visit(n, trail)
			end
		end
		table.remove(trail)
		state[id] = 2
	end
	for _, id in car.order do
		visit(id, {})
	end
end

local carCache: { [string]: Car } = {}

-- one car type resolved (nil = no such type)
function PartGraph.car(name: string): Car?
	if carCache[name] then
		return carCache[name]
	end
	if not rawOf(name) then
		return nil
	end
	local problems = {}
	local all, wheels = rowsOf(name, problems)
	-- (rows of a lump that isn't live yet aren't parts on this type; what they'd have blocked isn't blocked by them.
	-- A live one sits where the type's own 3D has its node — none there = not on this type either)
	-- (a corner row — piece E2 — the same from the type's own suspension 3D: `at` from its left node, the right side
	-- its own mirrored mesh, not the left one turned — suspension_v1 PROGRESS ④)
	local own3D, ownSusp = Car3D.of(name).parts, Car3D.susp(name).parts
	local rows, waiting = {}, {}
	for _, r in all do
		local node = nil
		if r.lump and r.pivot then
			node = own3D[r.id]
			if node then
				r.pivot = node.pivot
			end
		elseif r.lump and type(r.id) == "string" and r.id:sub(-2) == "_*" then
			node = ownSusp[r.id:sub(1, -2) .. "FL"] or ownSusp[r.id:sub(1, -2) .. "RL"]
			if node and node.at then
				r.at = node.at
				r.mirror = nil
			end
		end
		if rowLive(name, r) and (node ~= nil or not r.lump) then
			table.insert(rows, r)
		elseif type(r.id) == "string" then
			waiting[r.id] = true
		end
	end
	for _, r in rows do
		if r.needs then
			local keep = {}
			for _, n in r.needs do
				if not waiting[n] then
					table.insert(keep, n)
				end
			end
			r.needs = keep
		end
	end
	local parts: { [string]: Part } = {}
	local order = {}
	local function add(p: Part)
		if parts[p.id] then
			table.insert(problems, p.id .. ": two rows with this id")
		end
		parts[p.id] = p
		table.insert(order, p.id)
	end
	for _, r in rows do
		if type(r.id) ~= "string" then
			table.insert(problems, "a row without an id")
		elseif r.id:sub(-2) == "_*" then
			for corner, c in wheels do
				if r.corners and not table.find(r.corners, corner) then
					continue -- (a front-only / rear-only corner row: struts at the front, shocks at the back)
				end
				local left = c.X < 0
				local at = r.at or Vector3.zero
				local off = if left then at else Vector3.new(-at.X, at.Y, at.Z)
				local turned = if r.mirror then not left else nil
				add(partFrom(r, r.id:sub(1, -2) .. corner, c + off, corner, turned))
			end
		elseif typeof(r.pivot) ~= "Vector3" then
			table.insert(problems, r.id .. ": no pivot")
		else
			add(partFrom(r, r.id, r.pivot, nil, r.turned))
		end
	end
	table.sort(order)
	local car: Car = { name = name, wheels = wheels, parts = parts, order = order, problems = problems }
	validate(car)
	carCache[name] = car
	return car
end

local function must(name: string): Car
	local car = PartGraph.car(name)
	assert(car, "no part data for car type " .. tostring(name))
	return car
end

-- the car types that have part data (a module of extra rows another type takes in — Cars/SedanOil, SedanCovers — isn't one)
function PartGraph.types(): { string }
	local out = {}
	for _, m in CarsFolder:GetChildren() do
		local d = if m:IsA("ModuleScript") then rawOf(m.Name) else nil
		if d and (d.base or d.wheels) then
			table.insert(out, m.Name)
		end
	end
	table.sort(out)
	return out
end

function PartGraph.part(name: string, id: string): Part?
	return must(name).parts[id]
end

-- CarParts.Slot tables (the shape CarFactory / CarService / FaultService always used): requires = needs
local slotCache: { [string]: { [string]: any } } = {}
function PartGraph.slots(name: string): { [string]: any }
	if slotCache[name] then
		return slotCache[name]
	end
	local out = {}
	for id, p in must(name).parts do
		out[id] = {
			kind = p.kind,
			pivot = p.pivot,
			requires = if #p.needs > 0 then table.clone(p.needs) else nil,
			detach = p.detach,
			faultable = p.faultable,
			turned = p.turned,
			yaw = p.yaw,
		}
	end
	slotCache[name] = out
	return out
end

-- how deep a part sits (car_difficulty §2): 1 + the longest chain of parts that have to come off before it
-- (conditions — hood open, lift up — don't count as a layer)
local depthCache: { [string]: { [string]: number } } = {}
function PartGraph.depth(name: string, id: string): number
	local car = must(name)
	depthCache[name] = depthCache[name] or {}
	local memo = depthCache[name]
	local function d(pid: string, guard: { [string]: boolean }): number
		if memo[pid] then
			return memo[pid]
		end
		if car.parts[pid].starDepth then
			memo[pid] = car.parts[pid].starDepth :: number
			return memo[pid]
		end
		if guard[pid] then
			return 1 -- a loop (validate reports it): don't hang
		end
		guard[pid] = true
		local deepest = 0
		for _, n in car.parts[pid].needs do
			if car.parts[n] then
				deepest = math.max(deepest, d(n, guard))
			end
		end
		guard[pid] = nil
		memo[pid] = deepest + 1
		return deepest + 1
	end
	if not car.parts[id] then
		return 0
	end
	return d(id, {})
end

-- the parts in the way right now: the ones this part needs off that are still on (installed(id) says which are on)
function PartGraph.blockers(name: string, id: string, installed: (string) -> boolean): { string }
	local car = must(name)
	local out = {}
	local p = car.parts[id]
	for _, n in (if p then p.needs else {}) do
		if car.parts[n] and installed(n) then
			table.insert(out, n)
		end
	end
	return out
end

-- every part that has to come off to reach this one, in an order that works (deepest blockers first), then the part
function PartGraph.path(name: string, id: string): { string }
	local car = must(name)
	local out, seen = {}, {}
	local function visit(pid: string)
		if seen[pid] then
			return
		end
		seen[pid] = true
		local needs = table.clone(car.parts[pid].needs)
		table.sort(needs)
		for _, n in needs do
			if car.parts[n] then
				visit(n)
			end
		end
		table.insert(out, pid)
	end
	if car.parts[id] then
		visit(id)
	end
	return out
end

-------------------------------------------------------------------------------------------------------------------
-- Fasteners and tools (PartData/Fasteners, PartData/Tools — Config.Features.ToolMatch)
-------------------------------------------------------------------------------------------------------------------

PartGraph.Fasteners = require(PartData:WaitForChild("Fasteners")) :: { [string]: { hold: number, hand: boolean? } }
PartGraph.Tools = require(PartData:WaitForChild("Tools")) :: { [string]: { [string]: any } }

-- does this tool undo this kind of fastener? ("Hand" = bare hands: only the hand kinds)
function PartGraph.fits(tool: string?, fastener: string): boolean
	local f = PartGraph.Fasteners[fastener]
	if f and f.hand then
		return true
	end
	local t = tool and PartGraph.Tools[tool]
	return t ~= nil and t.enabled ~= false and table.find(t.does, fastener) ~= nil
end

-- the best tool among `owned` (names) for a fastener: the highest rank that fits; "Hand" for a hand kind; nil = none
function PartGraph.bestTool(owned: { string }, fastener: string): string?
	local best, rank = nil, -math.huge
	for _, name in owned do
		local t = PartGraph.Tools[name]
		if t and PartGraph.fits(name, fastener) and not (PartGraph.Fasteners[fastener] or {}).hand and t.rank > rank then
			best, rank = name, t.rank
		end
	end
	if not best and (PartGraph.Fasteners[fastener] or {}).hand then
		return "Hand"
	end
	return best
end

-- the lowest-level tool that would do it (for "Needs: Trim Tool — Lv 6")
function PartGraph.neededTool(fastener: string): string?
	local best, lv = nil, math.huge
	for name, t in PartGraph.Tools do
		if t.enabled ~= false and table.find(t.does, fastener) and (t.level or 1) < lv then
			best, lv = name, t.level or 1
		end
	end
	return best
end

-- what's wrong with the data, for every type (tools/partgraph_check.luau, and the server prints it at start)
function PartGraph.check(): { string }
	local out = {}
	for _, name in PartGraph.types() do
		local car = PartGraph.car(name)
		for _, p in (if car then car.problems else { "could not load" }) do
			table.insert(out, name .. ": " .. p)
		end
	end
	for name, t in PartGraph.Tools do
		for _, f in t.does or {} do
			if not PartGraph.Fasteners[f] then
				table.insert(out, "tool " .. name .. ": unknown fastener " .. f)
			end
		end
	end
	for f, def in PartGraph.Fasteners do
		local listed = def.hand == true
		for _, t in PartGraph.Tools do
			listed = listed or table.find(t.does or {}, f) ~= nil
		end
		if not listed then
			table.insert(out, "fastener " .. f .. ": no tool row undoes it")
		end
	end
	return out
end

return PartGraph
