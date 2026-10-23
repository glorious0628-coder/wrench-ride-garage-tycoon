-- The simple diagnosis (docs/design/fun_boost.md #1, fault_catalog.md): the customer only says the symptom; the car
-- gives clues when you try it (start it, press the brakes) and when you check a part with the Scanner (a reading:
-- volts, psi, mm). Shared so the server picks the clue and the client knows the sounds / before-after pair.

local Config = require(script.Parent.Config)

local Diagnosis = {}

-- (keys: "front left" / "앞 왼쪽" follow the language — plain English words showed up inside the Korean lines)
local CORNER_WORD = { FL = "@corner.FL", FR = "@corner.FR", RL = "@corner.RL", RR = "@corner.RR" }

local function broken(cond: number?): boolean
	return cond ~= nil and cond < Config.BrokenBelow
end

-- "Try to start": what happens, given the broken slots on the car ({ [slot] = true })
function Diagnosis.startClue(brokenSlots: { [string]: boolean }): (string, string)
	if brokenSlots.Battery then
		return "clue.start.click", "engineFail"
	elseif brokenSlots.Radiator then
		return "clue.start.steam", "steamHiss"
	elseif brokenSlots.Muffler then
		return "clue.start.loud", "exhaustLoud"
	end
	-- piece E stage 2 (rival_upgrade B2: one sense clue each — the engine bay's new jobs)
	for slot in brokenSlots do
		if slot:match("^IgnitionCoil_") or slot:match("^SparkPlug_") then
			return "clue.start.shake", "engineStart" -- (it runs, rough: the body shakes at idle)
		end
	end
	if brokenSlots.RadiatorHose_Upper or brokenSlots.RadiatorHose_Lower then
		return "clue.start.steam", "steamHiss"
	elseif brokenSlots.CoolantReservoir then
		return "clue.start.sweet", "engineStart"
	elseif brokenSlots.Fuse_Horn then
		return "clue.start.horn", "engineStart"
	elseif brokenSlots.AirFilter then
		return "clue.start.sluggish", "engineStart"
	end
	return "clue.start.ok", "engineStart"
end

-- "Press the brakes": a squeal from the worn corner (the first one, if several)
function Diagnosis.brakeClue(brokenSlots: { [string]: boolean }): (string, { [string]: any }?, string, string?)
	for _, corner in { "FL", "FR", "RL", "RR" } do
		if brokenSlots["BrakePads_" .. corner] then
			return "clue.brake.squeal", { side = CORNER_WORD[corner] }, "brakeSqueal", corner
		end
	end
	return "clue.brake.ok", nil, "brakeQuiet", nil
end

-- the Scanner's reading for a part (a number a mechanic would read, then a verdict)
function Diagnosis.reading(kind: string, cond: number, slot: string?): (string, { [string]: any })
	local corner = slot and slot:match("_(%u%u)$")
	local where = if corner then CORNER_WORD[corner] else nil
	local bad = broken(cond)
	local worn = cond < Config.WarnBelow
	if kind == "Battery" then
		-- fault_catalog 1-1: 12.6 V full, ~12.4 = 3/4, ~12.2 = half, <= 12.0 dead
		local v = if bad then 11.6 + cond / 100 else 12.2 + 0.45 * (cond / 100)
		return if bad then "read.battery.dead" else "read.battery.ok", { volts = string.format("%.1f", v) }
	elseif kind == "Wheel" then
		local psi = if bad then 6 + math.floor(cond / 5) else 30 + math.floor(cond / 20)
		return if bad then "read.tire.flat" else "read.tire.ok", { psi = psi, where = where or "" }
	elseif kind == "BrakePads" then
		local mm = if bad then 2 else (if worn then 5 else 9)
		return if bad then "read.pads.worn" else "read.pads.ok", { mm = mm, where = where or "" }
	elseif kind == "Radiator" then
		return if bad then "read.radiator.leak" else "read.ok", { part = "@part.Radiator" }
	elseif kind == "Strut" or kind == "Shock" then
		-- (E2: a leaking damper — wet with oil down its body; the spring kind reads its broken coil)
		return if bad then "read.damper.leak" else "read.ok", { part = "@part." .. kind }
	elseif kind == "Spring" then
		return if bad then "read.spring.broken" else "read.ok", { part = "@part.Spring" }
	elseif kind == "Muffler" then
		return if bad then "read.muffler.rust" else "read.ok", { part = "@part.Muffler" }
	elseif kind == "AirFilter" then
		return if bad then "read.filter.dirty" else "read.filter.ok", {}
	elseif kind == "CoolantReservoir" then
		return if bad then "read.tank.crack" else "read.ok", { part = "@part.CoolantReservoir" }
	elseif kind == "Fuse" then
		return if bad then "read.fuse.blown" else "read.fuse.ok", {}
	elseif kind == "IgnitionCoil" then
		return if bad then "read.coil.dead" else "read.ok", { part = "@part.IgnitionCoil" }
	elseif kind == "SparkPlug" then
		-- (the tip's colour: light tan = fine, black soot = fouled — carbook rival_upgrade_check §6)
		return if bad then "read.plug.fouled" else "read.plug.ok", {}
	elseif kind == "RadiatorHose" then
		return if bad then "read.hose.leak" else "read.ok", { part = "@part.RadiatorHose" }
	end
	return if bad then "read.dented" else "read.ok", { part = "@part." .. kind }
end

-- before / after the repair: a sound and a line for each (fun_boost #4)
Diagnosis.Compare = {
	Battery = { before = { "engineFail", "cmp.battery.before" }, after = { "engineStart", "cmp.battery.after" } },
	Wheel = { before = { "tireHiss", "cmp.wheel.before" }, after = { "", "cmp.wheel.after" } },
	BrakePads = { before = { "brakeSqueal", "cmp.pads.before" }, after = { "brakeQuiet", "cmp.pads.after" } },
	Radiator = { before = { "steamHiss", "cmp.radiator.before" }, after = { "engineStart", "cmp.radiator.after" } },
	Muffler = { before = { "exhaustLoud", "cmp.muffler.before" }, after = { "engineStart", "cmp.muffler.after" } },
	Bumper = { before = { "", "cmp.body.before" }, after = { "", "cmp.body.after" } },
	Hood = { before = { "", "cmp.body.before" }, after = { "", "cmp.body.after" } },
	AirFilter = { before = { "", "cmp.filter.before" }, after = { "engineStart", "cmp.filter.after" } },
	CoolantReservoir = { before = { "", "cmp.tank.before" }, after = { "", "cmp.tank.after" } },
	Fuse = { before = { "", "cmp.horn.before" }, after = { "", "cmp.horn.after" } },
	IgnitionCoil = { before = { "engineStart", "cmp.misfire.before" }, after = { "engineStart", "cmp.misfire.after" } },
	SparkPlug = { before = { "engineStart", "cmp.misfire.before" }, after = { "engineStart", "cmp.misfire.after" } },
	RadiatorHose = { before = { "steamHiss", "cmp.radiator.before" }, after = { "engineStart", "cmp.radiator.after" } },
}

return Diagnosis
