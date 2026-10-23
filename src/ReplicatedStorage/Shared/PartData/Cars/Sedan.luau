-- The sedan's parts (docs/specs/car_spec.md v0.3 4-1 + Radiator / Muffler from 4-2) — the base car other types derive
-- from. One row per part (PartGraph explains the fields); pivots in car space (car_spec 0: ground between the axles,
-- -Z = front, +X = the car's right). The parts' block stand-ins and bolt places stay in CarParts.Blocks.
-- Rows with a `lump` (piece E, the engine bay taken apart) only exist while that lump is live (Config.LiveLumps):
-- their places come from the 3D's own data (PartData/Generated/SedanBay, tools/gen_partdata.py).

local Bay = require(script.Parent.Parent:WaitForChild("Generated"):WaitForChild("SedanBay")).parts

-- a piece-E row: the part's pivot from the 3D, always in the engine bay, lifted out
local function bay(id: string, kind: string, needs: { string }, extra: { [string]: any }?): { [string]: any }
	local row: { [string]: any } = { id = id, kind = kind, pivot = Bay[id].pivot, zone = "EngineBay", needs = needs, detach = "Pop", lump = Bay[id].lump }
	for k, v in extra or {} do
		row[k] = v
	end
	return row
end

local engineBay = {
	-- P1 the air filter: the box lid's two latches, then the filter lifts out (nothing holds it)
	bay("AirBoxLid", "AirBoxLid", { "Hood:Open" }),
	bay("AirFilter", "AirFilter", { "Hood:Open", "AirBoxLid" }, { faultable = true }),
	-- P2 the coolant tank: bolt + nut, the level-sensor plug (the overflow hose end pushes off by hand)
	bay("CoolantReservoir", "CoolantReservoir", { "Hood:Open" }, { faultable = true }),
	-- P3 the horn fuse: the fuse box lid's latch, then the fuse puller
	bay("FuseBoxLid", "FuseBoxLid", { "Hood:Open" }),
	bay("Fuse_Horn", "Fuse", { "Hood:Open", "FuseBoxLid" }, { faultable = true }),
	-- P4 coils and plugs: the cover's rubber grommets, each coil (bolt + plug), the plug under it
	bay("EngineCover", "EngineCover", { "Hood:Open" }),
	bay("OilFillCap", "OilFillCap", { "Hood:Open" }),
	bay("Dipstick", "Dipstick", { "Hood:Open" }),
	-- P5 the radiator chain (Features.NewPartsP5): the cover's clips, the hoses' clamps — then the radiator
	bay("RadiatorCover", "RadiatorCover", { "Hood:Open" }, { p5 = true }),
	bay("RadiatorHose_Upper", "RadiatorHose", { "Hood:Open", "RadiatorCover" }, { p5 = true, faultable = true }),
	-- (v2.2: the lower hose lies behind the radiator, its way out goes up through the cover's place)
	bay("RadiatorHose_Lower", "RadiatorHose", { "Hood:Open", "RadiatorCover" }, { p5 = true, faultable = true }),
}
for n = 1, 4 do
	table.insert(engineBay, bay("IgnitionCoil_" .. n, "IgnitionCoil", { "Hood:Open", "EngineCover" }, { faultable = true }))
	table.insert(engineBay, bay("SparkPlug_" .. n, "SparkPlug", { "Hood:Open", "EngineCover", "IgnitionCoil_" .. n }, { faultable = true }))
end
-- later (main bay_v2 decision: fixed for now, ready as rows): the intake duct (2 hose clamps), the throttle body under
-- it (4 bolts + its plug), the engine computer (2 lever plugs, 2 bolts + 1 nut — removal-3204; a nut counts as Bolt). Features.NewPartsLater — and their F_ points
-- from the 3D (v2.1); `holds` = what the 3D has to mark, checked by tools/partgraph_check until then
table.insert(engineBay, bay("IntakeDuct", "IntakeDuct", { "Hood:Open" }, { later = true, holds = { HoseClamp = 2 } }))
table.insert(engineBay, bay("ThrottleBody", "ThrottleBody", { "Hood:Open", "IntakeDuct" }, { later = true, holds = { Bolt = 4, Connector = 1 } }))
table.insert(engineBay, bay("ECM", "ECM", { "Hood:Open" }, { later = true, holds = { Bolt = 3, Connector = 2 } }))

local rows = {
	name = "Sedan",
	-- car_spec v0.7: wheels +15% (tire 2.75), centre 1.375; the body floor stays at 0.5
	wheels = {
		FL = Vector3.new(-3.25, 1.375, -5.0),
		FR = Vector3.new(3.25, 1.375, -5.0),
		RL = Vector3.new(-3.25, 1.375, 5.0),
		RR = Vector3.new(3.25, 1.375, 5.0),
	},
	parts = {
		{ id = "Hood", kind = "Hood", pivot = Vector3.new(0, 4.15, -3.85), zone = "Body_Front", needs = { "Hood:Open" }, detach = "Drop", faultable = true },
		{ id = "Bumper_F", kind = "Bumper", pivot = Vector3.new(0, 1.751, -8.0), zone = "Body_Front", liftEnd = "F", detach = "Drop", faultable = true },
		-- (turned: one bumper part fits both ends, its bolts on the side facing the car)
		{ id = "Bumper_R", kind = "Bumper", pivot = Vector3.new(0, 1.64, 8.2), zone = "Body_Rear", liftEnd = "R", needs = { "Lift:Wheel" }, detach = "Drop", faultable = true, turned = true },
		-- car_spec v0.8: the battery's long side runs front-back
		{ id = "Battery", kind = "Battery", pivot = Vector3.new(-2.2, 2.35, -5.7), yaw = -90, zone = "EngineBay", needs = { "Hood:Open" }, detach = "Pop", faultable = true },
		-- (with P5 live the cover and both hoses come first; while they aren't, PartGraph drops those needs)
		{ id = "Radiator", kind = "Radiator", pivot = Vector3.new(0, 2.3, -7.5), zone = "EngineBay", needs = { "Hood:Open", "RadiatorCover", "RadiatorHose_Upper", "RadiatorHose_Lower" }, detach = "Pop", faultable = true },
		{ id = "Muffler", kind = "Muffler", pivot = Vector3.new(0.3, 0.8, 7.6), zone = "Under_Rear", liftEnd = "R", needs = { "Lift:Under" }, detach = "Drop", faultable = true },
		-- the corners (right side = the left model turned 180°, car_spec 0)
		{ id = "Wheel_*", kind = "Wheel", zone = "Wheel_*", needs = { "Lift:Wheel" }, detach = "Drop", faultable = true, mirror = true },
		-- the pad set sits in the caliper at the wheel's front, 9 / 3 o'clock (car_spec v0.6-0.7; 3D brake_attachments.json:
		-- pads, caliper and bracket share the pad-set centre, on the disc plane, in front)
		{ id = "BrakePads_*", kind = "BrakePads", at = Vector3.new(0, 0, -0.5271), zone = "Wheel_*", needs = { "Wheel_*" }, detach = "Drop", faultable = true, mirror = true },
		-- piece E2, the suspension (full_teardown §0-2 + carbook teardown/e2_suspension_answers, XV70 manual 4021 / 4029):
		-- lump Deco_Hub_F / _R (Config.LiveLumps, Features.E2Susp). Places = the 3D helper's measured spots
		-- (art/3d/suspension_v1/PROGRESS.md: strut / spring / shock ends, the arm bushings) until its parts.json (`at` from the wheel
		-- centre, left side, x = inboard). Arm:* = the floor jack under that corner's lower arm (car on its stands).
		-- front: the whole strut (spring on it) — link nut, the hose / sensor bracket bolt, the knuckle bolts (the knuckle
		-- hangs on the jack), then the 3 top nuts under the hood
		{ id = "Strut_*", kind = "Strut", corners = { "FL", "FR" }, at = Vector3.new(0.565, 1.275, 0.235), zone = "Wheel_*", needs = { "Lift:Wheel", "Wheel_*", "Arm:*" }, detach = "Drop", faultable = true, mirror = true, lump = "Deco_Hub_F" },
		-- rear: the stabilizer link comes off first (both the shock and the spring need it off — 4029 step 3, 4021)
		{ id = "StabLink_*", kind = "StabLink", corners = { "RL", "RR" }, at = Vector3.new(0.8, -0.175, 0.42), zone = "Wheel_*", needs = { "Lift:Wheel", "Wheel_*" }, detach = "Drop", mirror = true, lump = "Deco_Hub_R" },
		-- the shock: lower nut + plate washer, the 2 body bolts, the upper control arm's bolt (its arm on the jack — 4029 7)
		{ id = "Shock_*", kind = "Shock", corners = { "RL", "RR" }, at = Vector3.new(0.95, 0.295, -0.34), zone = "Wheel_*", needs = { "Lift:Wheel", "Wheel_*", "StabLink_*", "Arm:*" }, detach = "Drop", faultable = true, mirror = true, lump = "Deco_Hub_R" },
		-- the No.2 lower arm: outer bolt out, the inner cam nut only loosened — it hinges down on the jack (Swing)
		{ id = "RearArm2_*", kind = "LowerArm", corners = { "RL", "RR" }, at = Vector3.new(1.05, -0.53, 0.48), zone = "Wheel_*", needs = { "Lift:Wheel", "Wheel_*", "StabLink_*", "Arm:*" }, detach = "Swing", mirror = true, lump = "Deco_Hub_R" },
		-- the coil spring on that arm: nothing holds it once the arm is down (no compressor — the shock stays on, 4021).
		-- Its chain says depth 4 (wheel → link → arm); the stars count it 3 — 3 parts off first (fault_mix v0.2 ③), else
		-- no star shape (maxDepth 3) ever lets a spring job come
		{ id = "Spring_*", kind = "Spring", corners = { "RL", "RR" }, at = Vector3.new(1.2, 0.25, 0.43), zone = "Wheel_*", needs = { "RearArm2_*" }, detach = "Drop", faultable = true, mirror = true, lump = "Deco_Hub_R", starDepth = 3 },
	},
}

rows.bayIds = {} -- (every piece-E row's id: CarLook draws one that isn't live on a car as a fixed copy)
for _, r in engineBay do
	table.insert(rows.parts, r)
	rows.bayIds[r.id] = true
end
-- the oil change's rows under the engine (Cars/SedanOil: they exist only with Features.OilChange + UnderView)
for _, r in require(script.Parent:WaitForChild("SedanOil")).rows do
	table.insert(rows.parts, r)
	rows.bayIds[r.id] = true
end
-- the under covers (Cars/SedanCovers: they exist only with Features.UnderView)
for _, r in require(script.Parent:WaitForChild("SedanCovers")).rows do
	table.insert(rows.parts, r)
	rows.bayIds[r.id] = true
end

return rows
