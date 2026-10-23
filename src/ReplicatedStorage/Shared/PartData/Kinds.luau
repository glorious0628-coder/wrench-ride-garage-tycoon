-- Part kinds (car_spec v0.3 4-1/4-2): one row per kind of part, shared by every car type that has it — what it costs
-- at the parts counter, how heavy it is, how it's carried, which folder of the car it lives in. Read through
-- CarParts.Kinds. A new kind = a new row here (+ its Locale name part.<Kind>).

return {
	Hood = { massKg = 16, price = 260, bolts = 4, carry = "TwoHand", tool = "Wrench", group = "Body" },
	Bumper = { massKg = 5, price = 160, bolts = 4, carry = "TwoHand", tool = "Wrench", group = "Body" },
	Battery = { massKg = 16, price = 90, bolts = 3, carry = "TwoHand", tool = "Wrench", group = "MechanicalParts" },
	Wheel = { massKg = 20, price = 140, bolts = 5, carry = "Roll", tool = "Lug", group = "MechanicalParts" },
	BrakePads = { massKg = 0.6, price = 45, bolts = 2, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	Radiator = { massKg = 7, price = 220, bolts = 2, carry = "TwoHand", tool = "Wrench", group = "MechanicalParts" },
	Muffler = { massKg = 8, price = 150, bolts = 2, carry = "TwoHand", tool = "Wrench", group = "MechanicalParts" },
	-- piece E, the engine bay taken apart (full_teardown §0-1; prices = a US parts store, rounded): only on a car whose
	-- lump is live (Config.LiveLumps) — `bolts` = how many fasteners hold it (PartData/Generated/SedanBay points)
	AirBoxLid = { massKg = 0.5, price = 30, bolts = 2, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	AirFilter = { massKg = 0.3, price = 18, bolts = 0, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	CoolantReservoir = { massKg = 0.7, price = 45, bolts = 3, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	FuseBoxLid = { massKg = 0.2, price = 15, bolts = 1, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	Fuse = { massKg = 0.01, price = 3, bolts = 1, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	EngineCover = { massKg = 1.5, price = 70, bolts = 2, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	IgnitionCoil = { massKg = 0.3, price = 60, bolts = 2, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	SparkPlug = { massKg = 0.06, price = 9, bolts = 1, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	Dipstick = { massKg = 0.1, price = 12, bolts = 1, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	OilFillCap = { massKg = 0.05, price = 8, bolts = 1, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	RadiatorCover = { massKg = 0.8, price = 40, bolts = 3, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	RadiatorHose = { massKg = 0.4, price = 28, bolts = 2, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	-- piece E2, the suspension (full_teardown §0-2 prices: strut 180 · shock 70 · spring 60; the arm isn't sold)
	Strut = { massKg = 8, price = 180, bolts = 7, carry = "TwoHand", tool = "Wrench", group = "MechanicalParts" },
	Shock = { massKg = 3, price = 70, bolts = 4, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	StabLink = { massKg = 0.6, price = 35, bolts = 2, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	LowerArm = { massKg = 4, price = 0, bolts = 2, carry = "TwoHand", tool = "Wrench", group = "MechanicalParts", notSold = true },
	Spring = { massKg = 2.5, price = 60, bolts = 0, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	IntakeDuct = { massKg = 0.5, price = 35, bolts = 2, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	ThrottleBody = { massKg = 1.2, price = 180, bolts = 5, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	-- the oil change (Features.OilChange; full_teardown §0-1 ④): the under cover's small door, the plug, its gasket, the filter
	OilAccessPanel = { massKg = 0.8, price = 30, bolts = 4, carry = "OneHand", tool = "Screwdriver", group = "MechanicalParts" },
	OilDrainPlug = { massKg = 0.1, price = 7, bolts = 1, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	DrainPlugGasket = { massKg = 0.01, price = 2, bolts = 0, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
	OilFilter = { massKg = 0.4, price = 12, bolts = 1, carry = "OneHand", tool = "FilterWrench", group = "MechanicalParts" },
	ECM = { massKg = 1.0, price = 320, bolts = 4, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	-- the underside's covers (Cars/SedanCovers, Features.UnderView): plastic panels on bolts + push clips — off to see
	-- the oil pan, the fuel tank, the exhaust hangers (main 10-23)
	EngineUnderCover = { massKg = 2.0, price = 60, bolts = 9, carry = "TwoHand", tool = "Wrench", group = "MechanicalParts" },
	FloorCover = { massKg = 1.5, price = 45, bolts = 7, carry = "OneHand", tool = "Wrench", group = "MechanicalParts" },
	FuelTankProtector = { massKg = 0.8, price = 35, bolts = 4, carry = "OneHand", tool = "Hand", group = "MechanicalParts" },
}
