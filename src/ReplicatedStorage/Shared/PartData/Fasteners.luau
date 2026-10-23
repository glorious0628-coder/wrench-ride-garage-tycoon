-- What holds a part on (docs/design/full_teardown.md v0.1 §3): one row per kind of fastener — which tools undo it
-- (PartData/Tools `does` lists the same names) and how long a hold on it takes in the work view (x Config.HoldBoltTime).
-- hand = bare hands do it, whatever tool is held (connectors, latches, rubber hangers). Every bolt of CarParts.Blocks
-- names its kind (`f`, nil = "Bolt"); a part row's holds will too. Only read while Config.Features.ToolMatch is on.

return {
	Bolt = { hold = 1.0 }, -- bolts / nuts 6~19 mm
	BoltHeavy = { hold = 3.0 }, -- over 100 N·m (a breaker bar / the impact wrench)
	LugNut = { hold = 1.0 },
	Terminal = { hold = 1.0 }, -- battery / alternator terminal nuts ((-) first: BoltService)
	Screw = { hold = 1.25 },
	Clip = { hold = 0.75 }, -- plastic push clips
	HoseClamp = { hold = 1.5 }, -- spring hose clamps
	Connector = { hold = 0.5, hand = true }, -- press the tab, pull the plug (not the wire)
	Latch = { hold = 0.5, hand = true }, -- latches, twist-locks, rubber grommets
	Hanger = { hold = 0.75, hand = true }, -- rubber exhaust hangers
	DrainPlug = { hold = 1.0 },
	OilFilter = { hold = 1.5 }, -- the spin-on oil filter, turned off with a filter wrench
	SparkPlug = { hold = 1.0 },
	FusePull = { hold = 0.5 },
}
