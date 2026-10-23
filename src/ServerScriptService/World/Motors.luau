--!strict
-- World/Motors (wr-builder): Lv16 "대형 모터스" equipment (economy.md 1-2: Bay4 -> Paint Booth -> Alignment -> Dyno).
-- Photos: notes/research/ref_alignment_dyno. Two small buildings in the back yard west of the paint booth
-- (door to the back lane, -Z), each "Owned" by its upgrade id with a "Locked" pad before; plus paint-booth gear.
--   AlignmentBay (UpgradeId Alignment): 4-post lift (Lift.Carriage = runways + cross beams + turn / slip plates),
--                camera tower in front of the car, console.
--   DynoRoom     (UpgradeId Dyno): 2 roller pairs in a floor plate, big cooling fan, monitor, exhaust hose.
-- Names: docs/specs/world_contract.md (★ Lv16 장비).

local Kit = require(script.Parent.Kit)
local FlipPlaces = require(script.Parent.FlipPlaces)
local Equipment = require(script.Parent.Equipment)
local C, M = Kit.C, Kit.M
local box, marker, rod = Kit.box, Kit.marker, Kit.rod

local Motors = {}

local F = 0.2
local Z0, Z1 = 44, 80
local RED = Color3.fromRGB(206, 44, 38)
local DARK = Color3.fromRGB(46, 48, 54)
local STEEL = Color3.fromRGB(176, 180, 186)

local function tag(inst: Instance, id: string, state: string, lv: number?)
	inst:SetAttribute("UpgradeId", id)
	inst:SetAttribute("UpgradeState", state)
	if lv then
		inst:SetAttribute("UnlockLevel", lv)
	end
end

local function alignment(garage: Model)
	local X0, X1 = -100, -80
	local cx = (X0 + X1) / 2 -- -90
	local cz = 62
	local m = Kit.model(garage, "AlignmentBay")
	tag(m, "Alignment", "Owned", 12) -- shop_areas.md §7 ④: Lv16 -> Lv12 (E2 referral customers come back)
	FlipPlaces.bayShell(m, X0, X1, Z0, Z1, "ALIGNMENT")
	local LIFT = Equipment.LIFT
	local RUN_TOP = F + 0.6 -- runway top at Ground (the car drives up the ramps)
	local spot = marker(m, "CarSpot", Vector3.new(cx, RUN_TOP, cz), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	local ls = marker(m, "LiftSpot", spot.Position, Vector3.new(0, 0, 1), Vector3.new(10, 0.2, 22))
	ls:SetAttribute("Installed", true)
	marker(m, "ApproachSpot", Vector3.new(cx, 0, 32), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(m, "WorkArea", Vector3.new(cx, F + 9.9, cz), Vector3.new(0, 0, 1), Vector3.new(18, 19.8, 34))
	-- the 4-post lift
	local lift = Kit.model(m, "Lift")
	lift:SetAttribute("Variant", "FourPost")
	lift:SetAttribute("MaxLevel", "Under")
	lift:SetAttribute("Levels", "Ground=0,Wheel=" .. LIFT.wheel .. ",Under=" .. LIFT.under)
	local postX, postZ = 5.8, 11.4
	local H = math.max(13, LIFT.under + LIFT.carHeight + 1.4)
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			local px, pz = cx + sx * postX, cz + sz * postZ
			box(lift, "Post", px - 0.7, F, pz - 0.7, px + 0.7, F + H, pz + 0.7, DARK, M.smooth)
			box(lift, "PostBase", px - 1.1, F, pz - 1.1, px + 1.1, F + 0.2, pz + 1.1, C.metal, M.diamond)
			box(lift, "PostCap", px - 0.9, F + H, pz - 0.9, px + 0.9, F + H + 0.3, pz + 0.9, RED, M.smooth)
			box(lift, "SafetyStripe", px - 0.72, F + 1.6, pz - 0.72, px + 0.72, F + 1.9, pz + 0.72, C.yellow, M.smooth, { collide = false })
		end
	end
	-- ramps at the door end (stay on the floor)
	for _, sx in ipairs({ -1, 1 }) do
		local rx = cx + sx * 3.25
		-- (a wedge is high at its +Z end: low at the door, up to the runway)
		Kit.part(lift, "Ramp", Vector3.new(2.6, 0.6, 3.2), CFrame.new(rx, F + 0.3, cz - 12.6), DARK, M.diamond, { shape = "wedge" })
	end
	local home = marker(lift, "CarriageHome", spot.Position, Vector3.new(0, 0, 1))
	local car = Kit.model(lift, "Carriage")
	local root = Kit.part(car, "CarriageRoot", Vector3.new(1, 0.2, 1), home.CFrame, C.marker, M.smooth, { collide = false, transparency = 1, shadow = false })
	root.CanQuery = false
	root.CanTouch = false
	car.PrimaryPart = root
	-- runways along the wheel tracks (±3.25), cross beams riding the posts, turn plates (front wheels), slip plates (rear)
	local wheelX = 3.25
	for _, sx in ipairs({ -1, 1 }) do
		local rx = cx + sx * wheelX
		box(car, "Runway", rx - 1.3, RUN_TOP - 0.45, cz - 11, rx + 1.3, RUN_TOP, cz + 11, RED, M.smooth)
		box(car, "RunwayLip", rx + sx * 1.3 - 0.1, RUN_TOP, cz - 11, rx + sx * 1.3 + 0.1, RUN_TOP + 0.3, cz + 11, DARK, M.metal, { collide = false })
		-- car nose is +Z: front wheels at cz + 5, rear at cz - 5
		Kit.part(car, "TurnPlate", Vector3.new(0.08, 2.4, 2.4), CFrame.new(rx, RUN_TOP + 0.02, cz + LIFT.wheelZ) * CFrame.Angles(0, 0, math.rad(90)), STEEL, M.metal, { shape = "cyl", collide = false })
		box(car, "SlipPlate", rx - 1.1, RUN_TOP, cz - LIFT.wheelZ - 1.4, rx + 1.1, RUN_TOP + 0.04, cz - LIFT.wheelZ + 1.4, STEEL, M.diamond, { collide = false })
	end
	for _, sz in ipairs({ -1, 1 }) do
		local pz = cz + sz * postZ
		box(car, "CrossBeam", cx - postX - 0.7, RUN_TOP - 0.9, pz - 0.6, cx + postX + 0.7, RUN_TOP - 0.3, pz + 0.6, DARK, M.smooth)
	end
	-- camera tower in front of the car (T: column + bar + 2 cameras), console beside it
	local tw = Kit.model(m, "CameraTower")
	box(tw, "Base", cx - 1.2, F, Z1 - 3.6, cx + 1.2, F + 0.4, Z1 - 1.8, DARK, M.metal)
	box(tw, "Column", cx - 0.35, F + 0.4, Z1 - 3.05, cx + 0.35, F + 9.4, Z1 - 2.35, STEEL, M.metal)
	box(tw, "Bar", cx - 6.4, F + 8.4, Z1 - 3.1, cx + 6.4, F + 9.0, Z1 - 2.3, RED, M.smooth)
	for _, sx in ipairs({ -1, 1 }) do
		box(tw, "Camera", cx + sx * 6 - 0.7, F + 7.4, Z1 - 3.4, cx + sx * 6 + 0.7, F + 8.4, Z1 - 2.0, DARK, M.smooth)
		Kit.part(tw, "Lens", Vector3.new(0.2, 0.6, 0.6), CFrame.new(cx + sx * 6, F + 7.9, Z1 - 3.45) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(90, 160, 230), M.neon, { shape = "cyl", collide = false })
	end
	local con = Kit.model(m, "Console")
	box(con, "Cabinet", X1 - 4.4, F, Z1 - 8, X1 - 1.6, F + 3.6, Z1 - 5.4, RED, M.smooth)
	box(con, "Screen", X1 - 4.2, F + 3.6, Z1 - 7.4, X1 - 1.8, F + 5.6, Z1 - 7.2, DARK, M.smooth)
	box(con, "Display", X1 - 4.0, F + 3.8, Z1 - 7.45, X1 - 2.0, F + 5.4, Z1 - 7.4, Color3.fromRGB(70, 200, 140), M.neon, { collide = false })
	box(con, "Keyboard", X1 - 4.0, F + 3.6, Z1 - 7.9, X1 - 2.0, F + 3.7, Z1 - 7.4, C.rubber, M.smooth, { collide = false })
	marker(m, "ConsolePoint", Vector3.new(X1 - 3, F, Z1 - 10), Vector3.new(0, 0, 1))
	-- wheel targets on a wall rack (the clamps that go on the wheels)
	for k = 0, 3 do
		Kit.part(m, "TargetClamp", Vector3.new(0.4, 1.8, 1.8), CFrame.new(X0 + 1.4, 6 + (k % 2) * 2.4, 52 + math.floor(k / 2) * 2.6) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(0, 0, 0),
			DARK, M.smooth, { shape = "cyl" })
	end
	FlipPlaces.lockedPad(garage, "AlignmentBay", "Alignment", 12, X0, Z0, X1, Z1, "ALIGNMENT")
end

local function dyno(garage: Model)
	local X0, X1 = -79, -59
	local cx = (X0 + X1) / 2 -- -69
	local cz = 62
	local m = Kit.model(garage, "DynoRoom")
	tag(m, "Dyno", "Owned", 16)
	FlipPlaces.bayShell(m, X0, X1, Z0, Z1, "DYNO")
	local LIFT = Equipment.LIFT
	marker(m, "CarSpot", Vector3.new(cx, F, cz), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(m, "ApproachSpot", Vector3.new(cx, 0, 32), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(m, "WorkArea", Vector3.new(cx, F + 9.9, cz), Vector3.new(0, 0, 1), Vector3.new(18, 19.8, 34))
	-- floor plate with 2 roller pairs (front axle at cz + 5, rear at cz - 5), yellow edges
	local dy = Kit.model(m, "Dynamometer")
	box(dy, "Plate", cx - 5.4, F, cz - 8, cx + 5.4, F + 0.04, cz + 8, DARK, M.diamond, { collide = false })
	box(dy, "EdgeL", cx - 5.6, F, cz - 8.2, cx - 5.2, F + 0.06, cz + 8.2, C.yellow, M.smooth, { collide = false })
	box(dy, "EdgeR", cx + 5.2, F, cz - 8.2, cx + 5.6, F + 0.06, cz + 8.2, C.yellow, M.smooth, { collide = false })
	local rollers = Kit.folder(dy, "Rollers")
	local r = LIFT.wheelRadius
	for _, axle in ipairs({ { "Front", cz + LIFT.wheelZ }, { "Rear", cz - LIFT.wheelZ } }) do
		for _, side in ipairs({ -1, 1 }) do
			-- two rollers under each axle, just touching the tyre in front of / behind its lowest point
			local z = axle[2] + side * (r * 0.5)
			local roller = Kit.part(rollers, axle[1] .. "Roller", Vector3.new(10, 1.2, 1.2), CFrame.new(cx, F - 0.35, z), STEEL, M.metal, { shape = "cyl" })
			roller.CanCollide = false
		end
		box(dy, "Gap", cx - 5, F - 0.05, axle[2] - r * 0.9, cx + 5, F + 0.05, axle[2] + r * 0.9, Color3.fromRGB(26, 26, 30), M.smooth, { collide = false })
	end
	marker(dy, "FrontRollers", Vector3.new(cx, F, cz + LIFT.wheelZ), Vector3.new(0, 0, 1))
	marker(dy, "RearRollers", Vector3.new(cx, F, cz - LIFT.wheelZ), Vector3.new(0, 0, 1))
	-- big blue cooling fan in front of the nose
	local fan = Kit.model(m, "CoolingFan")
	local fz = Z1 - 4
	box(fan, "Stand", cx - 2.2, F, fz - 0.8, cx + 2.2, F + 0.4, fz + 0.8, DARK, M.metal)
	box(fan, "Leg", cx - 0.3, F + 0.4, fz - 0.3, cx + 0.3, F + 2.4, fz + 0.3, DARK, M.metal)
	Kit.part(fan, "Housing", Vector3.new(1.2, 6, 6), CFrame.new(cx, F + 5.2, fz) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(40, 110, 210), M.smooth, { shape = "cyl" })
	Kit.part(fan, "Grille", Vector3.new(0.1, 5.4, 5.4), CFrame.new(cx, F + 5.2, fz - 0.65) * CFrame.Angles(0, math.rad(90), 0), C.metalDark, M.metal, { shape = "cyl", transparency = 0.4, collide = false })
	for k = 0, 1 do
		box(fan, "Blade", cx - 2.4, F + 4.95, fz - 0.4, cx + 2.4, F + 5.45, fz - 0.3, STEEL, M.metal, { collide = false }).CFrame =
			CFrame.new(cx, F + 5.2, fz - 0.35) * CFrame.Angles(0, 0, math.rad(45 + k * 90))
	end
	marker(m, "FanSpot", Vector3.new(cx, F, fz), Vector3.new(0, 0, -1))
	-- monitor on a stand + operator desk, exhaust hose from the ceiling to the tail pipe area
	local mon = Kit.model(m, "Monitor")
	box(mon, "Desk", X0 + 1.4, F, cz - 4, X0 + 4, F + 3.2, cz + 4, STEEL, M.metal)
	box(mon, "Screen", X0 + 2.6, F + 3.2, cz - 2.6, X0 + 2.9, F + 6.6, cz + 2.6, DARK, M.smooth)
	box(mon, "Graph", X0 + 2.9, F + 3.5, cz - 2.3, X0 + 2.95, F + 6.3, cz + 2.3, Color3.fromRGB(60, 200, 140), M.neon, { collide = false })
	marker(m, "ConsolePoint", Vector3.new(X0 + 5, F, cz), Vector3.new(-1, 0, 0))
	rod(m, "ExhaustHose", Vector3.new(cx + 2.4, 19.6, cz - 11), Vector3.new(cx + 2.4, 1.6, cz - 12.5), 1.0, 1.0, DARK, M.fabric, { collide = false })
	box(m, "HoseReel", cx + 1.4, 18.6, cz - 12, cx + 3.4, 19.8, cz - 10, C.yellow, M.metal)
	FlipPlaces.lockedPad(garage, "DynoRoom", "Dyno", 16, X0, Z0, X1, Z1, "DYNO")
end

local function boothGear(garage: Model)
	local pb = garage:FindFirstChild("PaintBooth")
	if not pb then
		return
	end
	local g = Kit.folder(pb, "Gear")
	-- spray-gun rack on the east liner (red plate, 3 guns with cups)
	local x = -19.4
	box(g, "GunRack", x - 0.1, 5.6, 64, x, 7.4, 68.4, RED, M.smooth)
	for k = 0, 2 do
		local z = 64.8 + k * 1.4
		box(g, "GunBody", x - 0.7, 5.4, z - 0.15, x - 0.1, 6.6, z + 0.15, STEEL, M.metal, { collide = false })
		Kit.post(g, "GunCup", x - 0.45, z, 6.6, 7.4, 0.5, Color3.fromRGB(240, 240, 236), M.smooth, { collide = false })
	end
	-- IR drying lamp on wheels (3 glowing panels on a frame) and two portable light stands
	local ir = Kit.model(g, "DryingLamp")
	box(ir, "Base", -27.6, F, 50, -24.4, F + 0.4, 53, DARK, M.metal)
	box(ir, "Mast", -26.2, F + 0.4, 51.2, -25.8, F + 6, 51.8, STEEL, M.metal)
	for k = 0, 2 do
		box(ir, "Panel", -27.6, F + 3 + k * 1.1, 52.0, -24.4, F + 3.9 + k * 1.1, 52.3, Color3.fromRGB(255, 120, 60), M.neon, { collide = false })
	end
	for _, s in ipairs({ { -45, 54 }, { -23.5, 72 } }) do
		Kit.post(g, "LightStand", s[1], s[2], F, F + 6.4, 0.25, DARK, M.metal)
		box(g, "LightHead", s[1] - 0.8, F + 6, s[2] - 0.4, s[1] + 0.8, F + 7, s[2] + 0.4, Color3.fromRGB(255, 252, 240), M.neon, { collide = false })
	end
	-- intake filter panels on the west liner (white frames)
	for k = 0, 2 do
		local z = 50 + k * 9
		box(g, "FilterFrame", -48.95, 1.2, z, -48.85, 7.2, z + 6, Color3.fromRGB(214, 216, 220), M.smooth, { collide = false })
		box(g, "FilterMesh", -48.85, 1.6, z + 0.4, -48.8, 6.8, z + 5.6, Color3.fromRGB(250, 250, 246), M.fabric, { collide = false })
	end
	marker(g, "GunRackPoint", Vector3.new(-21.6, F, 66.2), Vector3.new(1, 0, 0))
end

function Motors.build(garage: Model)
	-- back lane runs on west to the two new buildings
	local site = garage:FindFirstChild("Site")
	local lot = site and site:FindFirstChild("Lot")
	if lot then
		box(lot, "BackLaneWest", -100, -1, 20, -54, 0, 44, C.asphaltLot, M.asphalt)
	end
	alignment(garage)
	dyno(garage)
	boothGear(garage)
end

return Motors
