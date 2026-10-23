-- The fault catalogue the random generator draws from (docs/design/alpha_scope.md v0.2 §2, fault_catalog.md v0.3).
-- kind weights, then a variant inside the kind. A variant is either
--   fix = "replace": the part itself is worn out (Condition 0..30, red on the Scanner) — swap it
--   fix = <action>:  a TRAP — the part is fine (green on the Scanner) but something next to it isn't (crusty battery
--                    terminals, a light scratch, a snapped rubber hanger); a new part won't fix it, the action will.
-- Shared: the server rolls, the client shows the action prompts' text.

local Faults = {}

-- a kind's chance among the kinds open at the garage level (docs/design/fault_mix.md v0.2 §3 ②): 10 for each of its
-- ordinary (non-trap) fault lines open right now (FaultService.kindWeight) — a kind with more ways to break comes up
-- more, and a new line rebalances by itself — times this scale (Strut / Spring: their depth already wins them star cars)
Faults.KindScale = { Strut = 0.8, Spring = 0.8 }

export type Variant = {
	id: string,
	kind: string,
	weight: number,
	minLevel: number?,
	fix: string, -- "replace" | "clean" | "polish" | "hang" | "balance"
	trap: boolean?, -- the part reads fine on the Scanner; counted in TrapChance (alpha_scope §2-4)
	gear: string?, -- only once the garage owns this (Shared/Equipment id)
	noise: string?, -- what the Stethoscope hears near it: "rattle" | "hiss" | "roar"
	obd: string?, -- the trouble code the OBD Reader finds (fault_catalog v0.4); none = "no codes stored"
	say: string, -- Locale key: what the customer says
	brake: string?, -- Locale key for "Press the brakes" when this is the fault (else the kind's default)
	laborMult: number?, -- labor units this job counts (JobService; none = 1)
	feature: string?, -- only while this Config.Features switch is on
}

Faults.Variants = {
	-- Battery
	{ id = "BAT_DEAD", kind = "Battery", weight = 50, fix = "replace", say = "sym.BAT_DEAD" },
	{ id = "BAT_CORROSION", kind = "Battery", weight = 20, minLevel = 3, fix = "clean", trap = true, say = "sym.BAT_CORROSION" },
	{ id = "BAT_OLD", kind = "Battery", weight = 50, fix = "replace", say = "sym.BAT_OLD" },
	-- (full_teardown §0-1 P0: the hold-down clamp's bolt is loose — the battery rocks in its tray, the connection
	-- comes and goes. Fixed with the wrench: tighten it. Switch ClampTrap)
	{ id = "BATTERY_CLAMP_LOOSE", kind = "Battery", weight = 20, minLevel = 3, fix = "clamp", trap = true, feature = "ClampTrap", say = "sym.BATTERY_CLAMP_LOOSE" },
	-- Wheel / tire
	{ id = "TIRE_FLAT", kind = "Wheel", weight = 25, fix = "replace", noise = "hiss", say = "sym.TIRE_FLAT" },
	{ id = "TIRE_BALD", kind = "Wheel", weight = 25, fix = "replace", say = "sym.TIRE_BALD" },
	{ id = "TIRE_BULGE", kind = "Wheel", weight = 25, minLevel = 3, fix = "replace", say = "sym.TIRE_BULGE" },
	{ id = "WHEEL_IMBALANCE", kind = "Wheel", weight = 25, gear = "WheelBalancer", fix = "balance", say = "sym.WHEEL_IMBALANCE" },
	-- Brake pads
	{ id = "PAD_WORN", kind = "BrakePads", weight = 50, fix = "replace", say = "sym.PAD_WORN", brake = "clue.brake.squeal" },
	{ id = "PAD_GONE", kind = "BrakePads", weight = 50, fix = "replace", say = "sym.PAD_GONE", brake = "clue.brake.grind" },
	-- Bumper
	{ id = "BUMPER_HANGING", kind = "Bumper", weight = 50, fix = "replace", say = "sym.BUMPER_HANGING" },
	{ id = "BODY_SCRATCH_LIGHT", kind = "Bumper", weight = 25, fix = "polish", trap = true, say = "sym.BODY_SCRATCH" },
	{ id = "BODY_SCRATCH_DEEP", kind = "Bumper", weight = 50, fix = "replace", say = "sym.BODY_SCRATCH" },
	-- Radiator
	{ id = "RAD_LEAK", kind = "Radiator", weight = 50, fix = "replace", noise = "hiss", obd = "P0217", say = "sym.RAD_LEAK" },
	{ id = "RAD_FAN", kind = "Radiator", weight = 50, fix = "replace", obd = "P0217", say = "sym.RAD_FAN" },
	-- Muffler
	{ id = "MUF_HOLE", kind = "Muffler", weight = 50, fix = "replace", noise = "roar", say = "sym.MUF_HOLE" },
	{ id = "MUF_HANGER", kind = "Muffler", weight = 35, fix = "hang", trap = true, noise = "rattle", say = "sym.MUF_HANGER" },
	{ id = "MUF_SHIELD", kind = "Muffler", weight = 50, fix = "replace", noise = "rattle", say = "sym.MUF_HANGER" },
	-- Hood
	{ id = "BODY_DENT", kind = "Hood", weight = 100, fix = "replace", say = "sym.BODY_DENT" },
	-- piece E2, the suspension (full_teardown §0-2): open only while those parts are live (Config.FaultUnlockLive);
	-- laborMult = this job's labor units (the strut / the rear spring take more than a shock)
	{ id = "STRUT_LEAK", kind = "Strut", weight = 100, fix = "replace", say = "sym.STRUT_LEAK", laborMult = 1.5 },
	{ id = "SHOCK_LEAK", kind = "Shock", weight = 100, fix = "replace", say = "sym.SHOCK_LEAK", laborMult = 1.0 },
	{ id = "SPRING_BROKEN", kind = "Spring", weight = 100, fix = "replace", say = "sym.SPRING_BROKEN", laborMult = 1.5 },
	-- piece E stage 2, the engine bay taken apart (full_teardown §0-1 P1-P5; words + one sense clue each = rival_upgrade
	-- B2 table): open only while those parts are live (Config.FaultUnlockLive). obd "…x" = that cylinder's number
	{ id = "AIRFILTER_DIRTY", kind = "AirFilter", weight = 100, fix = "replace", say = "sym.AIRFILTER_DIRTY" },
	{ id = "COOLANT_TANK_CRACK", kind = "CoolantReservoir", weight = 100, fix = "replace", say = "sym.COOLANT_TANK_CRACK" },
	{ id = "FUSE_BLOWN", kind = "Fuse", weight = 100, fix = "replace", say = "sym.FUSE_BLOWN" },
	{ id = "MISFIRE_COIL", kind = "IgnitionCoil", weight = 100, fix = "replace", obd = "P030x", say = "sym.MISFIRE" },
	{ id = "MISFIRE_PLUG", kind = "SparkPlug", weight = 100, fix = "replace", obd = "P030x", say = "sym.MISFIRE" },
	{ id = "RAD_HOSE_LEAK", kind = "RadiatorHose", weight = 100, fix = "replace", noise = "hiss", obd = "P0217", say = "sym.RAD_HOSE_LEAK" },
	-- the oil change (Lv3; Modules/OilService): a service job, not a worn part — the filter's slot carries it and
	-- OilService clears the issue once the oil is changed (fix "oil": no prompt on the car, like the clamp)
	{ id = "OIL_DUE", kind = "OilFilter", weight = 100, fix = "oil", feature = "OilChange", say = "sym.OIL_DUE", laborMult = 1.5 },
} :: { Variant }

Faults.ById = {}
for _, v in Faults.Variants do
	Faults.ById[v.id] = v
end

-- trap actions: the prompt on the part, how long to hold, the notice when done
Faults.Actions = {
	clean = { act = "act.cleanTerminals", hold = 1.5, done = "n.cleaned" },
	polish = { act = "act.polish", hold = 1.5, done = "n.polished" },
	hang = { act = "act.hangHanger", hold = 1.0, done = "n.hung" },
	-- (balance: done at the Wheel Balancer, not on the car)
}

-- how often a car's fault is a trap, by garage level (§2-4); never right after a level-up or for a hurry customer
Faults.TrapChance = { { upTo = 2, p = 0 }, { upTo = 5, p = 0.05 }, { upTo = 15, p = 0.10 }, { upTo = math.huge, p = 0.10 } }

return Faults
