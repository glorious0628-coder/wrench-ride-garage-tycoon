--!strict
-- World/Shop: the Lv1 shop building — Bay1 (x -14..14) + office block (x 14..38: WaitingRoom front, PartsRoom back),
-- z -20..20, floor top 0.2, walls 1 thick, ceiling 20. Front = -Z. US neighbourhood garage, flat roof, sign band.
-- Contract names: docs/specs/world_contract.md.

local Kit = require(script.Parent.Kit)
local C, M = Kit.C, Kit.M
local box, marker = Kit.box, Kit.marker

local Shop = {}

local F = 0.2 -- floor top
local H = 20 -- wall top / ceiling
local X0, XM, X1 = -14, 14, 38 -- west wall, bay|office wall, east wall (outer faces / wall line)
local Z0, Z1 = -20, 20 -- front, back (outer faces)
Shop.FLOOR, Shop.CEILING = F, H

local function bayShell(shell: Instance)
	-- floor slab (whole building)
	box(shell, "FloorSlab", X0, -1, Z0, X1, F, Z1, C.floor, M.smooth).Reflectance = 0.04
	-- back wall with a back door (Bay1, x -3.4..0.6, between the tool chest and the bench)
	box(shell, "BackWall", X0, F, Z1 - 1, -3.4, H, Z1, C.wall, M.smooth)
	box(shell, "BackWall", 0.6, F, Z1 - 1, X1, H, Z1, C.wall, M.smooth)
	box(shell, "BackWall", -3.4, 8.2, Z1 - 1, 0.6, H, Z1, C.wall, M.smooth)
	box(shell, "BackDoor", -3.4, F, Z1 - 0.7, 0.6, 8.2, Z1 - 0.3, C.door, M.metal)
	-- west wall = the wall Bay2 opens through at Lv6 (ExpansionWall)
	box(shell, "ExpansionWallWest", X0, F, Z0 + 1, X0 + 1, H, Z1 - 1, C.wall, M.smooth)
	-- east wall
	box(shell, "EastWall", X1 - 1, F, Z0 + 1, X1, H, Z1 - 1, C.wall, M.smooth)
	-- front: bay opening x -8..8, y up to 14
	box(shell, "FrontWall", X0, F, Z0, -8, H, Z0 + 1, C.wall, M.smooth)
	box(shell, "FrontWall", 8, F, Z0, XM + 1, H, Z0 + 1, C.wall, M.smooth)
	box(shell, "BayHeader", -8, 14, Z0, 8, H, Z0 + 1, C.wall, M.smooth)
	-- office storefront x 15..38: bulkhead, glass, door x 29..35 (5.4 clear), header
	box(shell, "OfficeHeader", XM + 1, 12, Z0, X1, H, Z0 + 1, C.wall, M.smooth)
	box(shell, "OfficePier", 35, F, Z0, X1, 12, Z0 + 1, C.wall, M.smooth)
	box(shell, "Bulkhead", XM + 1, F, Z0, 29, 2.2, Z0 + 1, C.wall, M.smooth)
	box(shell, "StoreGlass", XM + 1, 2.2, Z0 + 0.4, 29, 12, Z0 + 0.6, C.glass, M.glass, { transparency = 0.6 })
	for _, mx in ipairs({ XM + 1, 22, 29 }) do
		box(shell, "Mullion", mx - 0.2, 2.2, Z0 + 0.2, mx + 0.2, 12, Z0 + 0.8, C.frame, M.metal)
	end
	box(shell, "StoreSill", XM + 1, 2.2, Z0 - 0.2, 29, 2.4, Z0 + 1, C.frame, M.metal)
	box(shell, "StoreHead", XM + 1, 11.8, Z0 + 0.2, 29, 12, Z0 + 0.8, C.frame, M.metal)
	box(shell, "DoorTransom", 29, 9, Z0, 35, 12, Z0 + 1, C.frame, M.metal)
	box(shell, "DoorJamb", 29, F, Z0, 29.3, 9, Z0 + 1, C.frame, M.metal)
	box(shell, "DoorJamb", 34.7, F, Z0, 35, 9, Z0 + 1, C.frame, M.metal)
	-- the customer door itself: glass leaf, walk-through (no collision) so NPCs / players pass
	box(shell, "CustomerDoorLeaf", 29.3, F, Z0 + 0.45, 34.7, 9, Z0 + 0.55, C.glass, M.glass, { collide = false, transparency = 0.7 })
	-- bay | office wall (x 14..15): window to the bay, a door, the parts counter opening
	local wx0, wx1 = XM, XM + 1
	box(shell, "MidWall", wx0, F, Z0 + 1, wx1, H, -16, C.wallInside, M.smooth)
	box(shell, "MidWall", wx0, F, -16, wx1, 3.2, -6, C.wallInside, M.smooth)
	box(shell, "BayWindow", wx0 + 0.4, 3.2, -16, wx0 + 0.6, 9.2, -6, C.glass, M.glass, { transparency = 0.6 })
	box(shell, "BayWindowFrame", wx0 - 0.1, 3, -16, wx1 + 0.1, 3.2, -6, C.frame, M.metal)
	box(shell, "BayWindowFrame", wx0 - 0.1, 9.2, -16, wx1 + 0.1, 9.4, -6, C.frame, M.metal)
	box(shell, "MidWall", wx0, 9.4, -16, wx1, H, -6, C.wallInside, M.smooth)
	box(shell, "MidWall", wx0, F, -6, wx1, H, -5, C.wallInside, M.smooth)
	box(shell, "MidWall", wx0, 8.2, -5, wx1, H, 1, C.wallInside, M.smooth) -- over the bay door (z -5..1, 6 wide)
	box(shell, "MidWall", wx0, F, 1, wx1, H, 6, C.wallInside, M.smooth)
	box(shell, "MidWall", wx0, F, 6, wx1, 3.0, 14, C.wallInside, M.smooth) -- under the parts counter
	box(shell, "MidWall", wx0, 8.6, 6, wx1, H, 14, C.wallInside, M.smooth) -- over the parts counter
	box(shell, "MidWall", wx0, F, 14, wx1, H, Z1 - 1, C.wallInside, M.smooth)
	box(shell, "BayDoorFrame", wx0 - 0.1, 8.2, -5.2, wx1 + 0.1, 8.4, 1.2, C.frame, M.metal)
	-- office cross wall z 2..3 (WaitingRoom | PartsRoom), staff door x 33..36
	box(shell, "CrossWall", wx1, F, 2, 33, H, 3, C.wallInside, M.smooth)
	box(shell, "CrossWall", 36, F, 2, X1 - 1, H, 3, C.wallInside, M.smooth)
	box(shell, "CrossWall", 33, 8.2, 2, 36, H, 3, C.wallInside, M.smooth)
	-- office drop ceiling (rooms feel human-sized; the bay keeps its high ceiling for the lift)
	box(shell, "DropCeiling", wx1, 12, Z0 + 1, X1 - 1, 12.4, Z1 - 1, C.lineWhite, M.smooth)
	for _, cz in ipairs({ -12, 10 }) do
		box(shell, "CeilingLightPanel", 22, 11.9, cz - 1.5, 30, 12, cz + 1.5, C.lineWhite, M.smooth, { collide = false })
	end

	-- roof: slab, parapet (sign band at the front), coping
	box(shell, "Roof", X0 - 0.5, H, Z0 - 0.5, X1 + 0.5, H + 1, Z1 + 0.5, C.roof, M.concrete)
	box(shell, "ParapetFront", X0 - 0.5, H + 1, Z0 - 0.5, X1 + 0.5, H + 4, Z0 + 0.5, C.wall, M.smooth)
	box(shell, "ParapetBack", X0 - 0.5, H + 1, Z1 - 0.5, X1 + 0.5, H + 2.5, Z1 + 0.5, C.wall, M.smooth)
	box(shell, "ParapetSide", X0 - 0.5, H + 1, Z0 + 0.5, X0 + 0.5, H + 2.5, Z1 - 0.5, C.wall, M.smooth)
	box(shell, "ParapetSide", X1 - 0.5, H + 1, Z0 + 0.5, X1 + 0.5, H + 2.5, Z1 - 0.5, C.wall, M.smooth)
	box(shell, "Coping", X0 - 0.8, H + 4, Z0 - 0.8, X1 + 0.8, H + 4.4, Z0 + 0.6, C.trim, M.concrete)
	box(shell, "Coping", X0 - 0.8, H + 2.5, Z0 + 0.6, X0 + 0.8, H + 2.9, Z1 + 0.8, C.trim, M.concrete)
	box(shell, "Coping", X1 - 0.8, H + 2.5, Z0 + 0.6, X1 + 0.8, H + 2.9, Z1 + 0.8, C.trim, M.concrete)
	box(shell, "Coping", X0 + 0.8, H + 2.5, Z1 - 0.8, X1 - 0.8, H + 2.9, Z1 + 0.8, C.trim, M.concrete)
	-- sign board (blank; text goes on later as SurfaceGui — English original, no real brand)
	box(shell, "SignBoard", -6, H + 1.4, Z0 - 1, 30, H + 3.8, Z0 - 0.5, C.red, M.smooth)
	box(shell, "SignTrim", -6.3, H + 1.1, Z0 - 1.1, 30.3, H + 1.4, Z0 - 0.5, C.trim, M.metal)
	box(shell, "SignTrim", -6.3, H + 3.8, Z0 - 1.1, 30.3, H + 4.1, Z0 - 0.5, C.trim, M.metal)
	-- depth: base plinth + dark band under the parapet, corner pilasters
	box(shell, "Plinth", X0 - 0.2, 0, Z0 - 0.2, -8.6, 1.2, Z0, C.plinth, M.concrete)
	box(shell, "Plinth", 8.6, 0, Z0 - 0.2, 29, 1.2, Z0, C.plinth, M.concrete)
	box(shell, "Plinth", 35, 0, Z0 - 0.2, X1 + 0.2, 1.2, Z0, C.plinth, M.concrete)
	box(shell, "Plinth", X1, 0, Z0, X1 + 0.2, 1.2, Z1 + 0.2, C.plinth, M.concrete)
	box(shell, "Plinth", X0 - 0.2, 0, Z0, X0, 1.2, Z1 + 0.2, C.plinth, M.concrete)
	box(shell, "Plinth", X0, 0, Z1, X1, 1.2, Z1 + 0.2, C.plinth, M.concrete)
	box(shell, "Band", X0 - 0.2, 18.9, Z0 - 0.2, X1 + 0.2, 19.5, Z0, C.blue, M.smooth)
	box(shell, "Pilaster", X0 - 0.4, 0, Z0 - 0.4, X0 + 1, H, Z0, C.wall, M.smooth)
	box(shell, "Pilaster", X1 - 1, 0, Z0 - 0.4, X1 + 0.4, H, Z0, C.wall, M.smooth)
	box(shell, "Pilaster", XM - 0.2, 0, Z0 - 0.4, XM + 1.2, H, Z0, C.wall, M.smooth)
	-- office awning over the storefront
	box(shell, "Awning", XM + 1, 12.4, Z0 - 4, X1 - 0.4, 12.8, Z0, C.blue, M.smooth)
	box(shell, "AwningEdge", XM + 1, 11.6, Z0 - 4.2, X1 - 0.4, 12.8, Z0 - 4, C.blue, M.smooth)
	-- front walkway in front of the office
	box(shell, "Walkway", XM, -1, -28, X1 + 0.2, F, Z0, C.concrete, M.concrete)
	box(shell, "WalkwayCurb", XM, -1, -28.4, X1 + 0.2, F, -28, C.curb, M.concrete)
	-- bay apron (concrete pad in front of the bay door)
	box(shell, "BayApron", -12, -1, -32, 12, 0.05, Z0, C.concrete, M.concrete)
	-- bollards either side of the bay door
	for _, bx in ipairs({ -10, 10 }) do
		Kit.post(shell, "Bollard", bx, -21.6, 0, 4.4, 1, C.yellow, M.metal)
	end
end

local function bay1(garage: Instance, bays: Instance)
	local bay = Kit.model(bays, "Bay1")
	bay:SetAttribute("UnlockLevel", 1)
	-- markers
	marker(bay, "CarSpot", Vector3.new(0, F, -1), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	local lift = marker(bay, "LiftSpot", Vector3.new(0, F, -1), Vector3.new(0, 0, 1), Vector3.new(16, 0.2, 4))
	lift:SetAttribute("Installed", false)
	lift:SetAttribute("PostOffsetX", 6.0) -- car_spec §7: posts at car-local x +-6.0, z -0.5
	marker(bay, "ApproachSpot", Vector3.new(0, 0, -36), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(bay, "DriverExitSpot", Vector3.new(7, F, -3), Vector3.new(1, 0, 0))
	marker(bay, "WorkArea", Vector3.new(0, F + 9.9, 0), Vector3.new(0, 0, 1), Vector3.new(26, 19.8, 38))
	-- shutter (roll-up). Built OPEN (rolled into the hood). Attributes say how to close it: see contract.
	local shutter = box(bay, "Shutter", -8, 13.4, Z0 + 0.1, 8, 14, Z0 + 0.5, C.shutter, M.metal)
	shutter:SetAttribute("TopY", 14)
	shutter:SetAttribute("ClosedBottomY", F)
	shutter:SetAttribute("OpenBottomY", 13.4)
	box(bay, "ShutterHood", -8.6, 14, Z0 - 0.8, 8.6, 16, Z0, C.shutterBox, M.metal)
	box(bay, "ShutterGuide", -8.6, F, Z0 - 0.4, -8, 14, Z0, C.shutterBox, M.metal)
	box(bay, "ShutterGuide", 8, F, Z0 - 0.4, 8.6, 14, Z0, C.shutterBox, M.metal)
	-- floor: bay lines, lift-spot outline (Lv1 = no lift yet, floor jack only)
	box(bay, "BayLine", -12.6, F, -19, -12.2, F + 0.05, 18, C.lineYellow, M.smooth, { collide = false })
	box(bay, "BayLine", 12.2, F, -19, 12.6, F + 0.05, 13, C.lineYellow, M.smooth, { collide = false })
	-- old oil stain under the car spot: soft round blotches (a grey square read as a floor tile)
	for i, o in ipairs({ { -0.5, -2.5, 3.0, 0.62 }, { 0.8, -1.9, 1.6, 0.68 }, { 1.9, -1.4, 0.8, 0.72 } }) do
		Kit.part(bay, "OilStain", Vector3.new(0.02, o[3], o[3]), CFrame.new(o[1], F + 0.01 + i * 0.004, o[2]) * CFrame.Angles(0, 0, math.rad(90)),
			Color3.fromRGB(78, 80, 86), M.smooth, { collide = false, shadow = false, transparency = o[4], shape = "cyl" })
	end
	box(bay, "Drain", -1, F, 6, 1, F + 0.03, 8, C.metalDark, M.diamond, { collide = false })
	-- ceiling: steel beams + light fixtures (no lights yet: lighting comes last)
	for _, bz in ipairs({ -12, -2, 8 }) do
		box(bay, "RoofBeam", X0 + 1, H - 1.2, bz - 0.4, XM, H, bz + 0.4, C.beam, M.metal)
	end
	for _, lx in ipairs({ -6, 6 }) do
		box(bay, "LightFixture", lx - 0.6, H - 1.6, -14, lx + 0.6, H - 1.2, 14, C.lineWhite, M.smooth)
	end

	-- workbench (back wall, right) + pegboard
	local benches = garage:FindFirstChild("Workbenches") or Kit.folder(garage, "Workbenches")
	local wb = Kit.model(benches, "Workbench1")
	box(wb, "Body", 2, F, 16.5, 12, 3.0, Z1 - 1, C.metal, M.metal)
	box(wb, "Top", 1.8, 3.0, 16.3, 12.2, 3.4, Z1 - 1, C.wood, M.wood)
	box(wb, "Drawer", 2.4, 1.4, 16.4, 6.6, 2.6, 16.5, C.metalDark, M.metal)
	box(wb, "Drawer", 7.4, 1.4, 16.4, 11.6, 2.6, 16.5, C.metalDark, M.metal)
	box(wb, "Vise", 10, 3.4, 16.6, 11.4, 4.4, 17.8, C.blue, M.metal)
	box(wb, "Pegboard", 1, 5, Z1 - 1.2, 13, 11, Z1 - 1, C.pegboard, M.smooth)
	marker(wb, "WorkPoint", Vector3.new(7, F, 14.5), Vector3.new(0, 0, 1))

	-- red rolling tool chest (back wall, left)
	local tools = garage:FindFirstChild("Tools") or Kit.folder(garage, "Tools")
	local tc = Kit.model(tools, "ToolChest1")
	box(tc, "Base", -11, F + 0.6, 16.6, -4, 4.6, Z1 - 1, C.red, M.smooth)
	box(tc, "Hutch", -11, 4.6, 17.6, -4, 6.6, Z1 - 1, C.red, M.smooth) -- top 6.6 (~1.8 m, a real chest + hutch): taller, it filled the screen when the camera backed onto this wall
	box(tc, "Top", -11.1, 4.6, 16.5, -3.9, 4.8, 17.6, C.metalDark, M.metal)
	for i = 0, 3 do
		box(tc, "DrawerLine", -10.8, 1.4 + i * 0.8, 16.5, -4.2, 1.5 + i * 0.8, 16.6, C.redDark, M.smooth, { collide = false })
	end
	for _, cx in ipairs({ -10.4, -4.6 }) do
		box(tc, "Caster", cx - 0.3, F, 16.9, cx + 0.3, F + 0.6, 17.5, C.rubber, M.smooth)
	end
	marker(tc, "UsePoint", Vector3.new(-7.5, F, 14.5), Vector3.new(0, 0, 1))

	-- tire rack (west wall) with a few car tyres (2.75 across): low, the tops under the camera's eye height — a
	-- tall one filled the screen when the camera backed against this wall beside the car
	-- (notes/playtest/wr-builder/camera/camera_1022.md)
	local rack = Kit.model(bay, "TireRack")
	box(rack, "RackPost", X0 + 1, F, 2, X0 + 1.4, 3.9, 2.4, C.steel, M.metal)
	box(rack, "RackPost", X0 + 1, F, 11.6, X0 + 1.4, 3.9, 12, C.steel, M.metal)
	box(rack, "RackPost", X0 + 3, F, 2, X0 + 3.4, 3.9, 2.4, C.steel, M.metal)
	box(rack, "RackPost", X0 + 3, F, 11.6, X0 + 3.4, 3.9, 12, C.steel, M.metal)
	box(rack, "RackBar", X0 + 1, F + 0.5, 2, X0 + 3.4, F + 0.8, 12, C.steel, M.metal)
	box(rack, "RackRail", X0 + 3, 3.6, 2, X0 + 3.4, 3.9, 12, C.steel, M.metal) -- front top rail only (open top)
	local r = Kit.rng(11)
	-- (v35, GPT fix11 r1 "the tyres read as one black lump" from the bay door, which looks down the rack: 0.3 more
	-- between them, every other one leaning on its neighbour and set 0.15 out, so each round edge shows)
	for i = 0, 3 do
		local tz = 3.4 + i * 2.5 + (r() - 0.5) * 0.2
		local lean = if i % 2 == 0 then 7 else -5
		local tire = Kit.part(rack, "Tire", Vector3.new(1.1, 2.75, 2.75), CFrame.new(X0 + 2.2 + (if i % 2 == 0 then 0.15 else 0), F + 0.8 + 1.375, tz)
			* CFrame.Angles(math.rad(lean), 0, 0) * CFrame.Angles(0, math.rad(90 + (r() - 0.5) * 8), 0),
			C.rubber, M.plastic, { shape = "cyl" })
		tire:SetAttribute("Placeholder3D", "Tire") -- the 3D tyre takes its place (GearportProps.swapTires)
	end
	-- (oil drums, engine crane, floor jack, scrap bin, lift: World/Equipment)
	-- compressor hose reel on the wall
	box(bay, "HoseReel", 12.4, 6, -14.8, 13, 7.6, -13.2, C.yellow, M.metal)
end

local function waitingRoom(garage: Instance)
	local wr = Kit.model(garage, "WaitingRoom")
	box(wr, "Floor", XM + 1, F, Z0 + 1, X1 - 1, F + 0.05, 2, C.floorTile, M.smooth)
	-- reception desk (staff side faces the bay door)
	local desk = Kit.model(wr, "ReceptionDesk")
	box(desk, "Front", 17, F, -9, 22.4, 3.4, -8, C.wood, M.wood)
	box(desk, "Side", 21.4, F, -8, 22.4, 3.4, -6, C.wood, M.wood)
	box(desk, "Top", 16.8, 3.4, -9.2, 22.6, 3.7, -6, C.metalDark, M.smooth)
	box(desk, "Register", 19, 3.7, -7.6, 20.6, 4.7, -6.6, C.metalDark, M.smooth)
	marker(desk, "ServicePoint", Vector3.new(20.5, F, -11), Vector3.new(0, 0, 1))
	marker(desk, "StaffPoint", Vector3.new(20.5, F, -4.5), Vector3.new(0, 0, -1))
	-- seats along the east wall (Seat instances so NPCs can sit), facing -X
	local seats = Kit.folder(wr, "Seats")
	local seatZ = { -16.5, -13.5, -10.5, -7.5 }
	for i, sz in ipairs(seatZ) do
		local s = Kit.part(seats, "Seat" .. i, Vector3.new(2.4, 0.4, 2.4), CFrame.new(34.6, 2.4, sz) * CFrame.Angles(0, math.rad(90), 0),
			C.seat, M.smooth, { class = "Seat" })
		s:SetAttribute("Facing", "-X")
		box(wr, "SeatBack", 35.8, 2.6, sz - 1.2, 36.2, 5.4, sz + 1.2, C.seat, M.smooth)
	end
	box(wr, "SeatFrame", 33.4, F, -17.8, 36.2, 2.2, -6.2, C.metalDark, M.metal)
	-- coffee table + magazines
	box(wr, "CoffeeTable", 27.4, 1.9, -15, 29.2, 2.2, -9, C.wood, M.wood) -- 4.8 from the desk end, 4.2 from the chairs; top 2.2 (seat 2.4): NPC paths go round, not over
	box(wr, "TableLeg", 27.6, F, -14.8, 29.0, 1.9, -9.2, C.metalDark, M.metal)
	box(wr, "Magazine", 27.7, 2.2, -13, 28.9, 2.3, -11.6, C.red, M.smooth, { collide = false })
	-- vending machine against the cross wall
	local vm = Kit.model(wr, "VendingMachine")
	box(vm, "Body", 25, F, -1, 29, 7.4, 2, C.red, M.smooth)
	box(vm, "Window", 25.4, 2.6, -1.1, 27.6, 6.8, -1, C.glass, M.glass, { transparency = 0.3 })
	box(vm, "Panel", 27.9, 3.4, -1.1, 28.7, 6.2, -1, C.metalDark, M.smooth)
	box(vm, "Slot", 25.6, 0.8, -1.1, 27.4, 1.8, -1, C.rubber, M.smooth)
	marker(vm, "UsePoint", Vector3.new(27, F, -3), Vector3.new(0, 0, 1))
	-- water cooler + plant + TV (wall)
	box(wr, "WaterCooler", 29.4, F, 0.2, 31, 4.6, 1.8, C.lineWhite, M.smooth) -- flush with the vending machine (no dead-end slot)
	-- (v35: the coffee station has the seats' end now (ShopDetail): the plant stands just past it, 2.5 off the cross wall)
	Kit.post(wr, "PlantPot", 35.6, -1.4, F, 2, 1.8, C.cardboard, M.smooth)
	Kit.part(wr, "Plant", Vector3.new(3, 3, 3), CFrame.new(35.6, 3.4, -1.4), C.grassDark, M.grass, { shape = "ball" })
	marker(wr, "CustomerDoor", Vector3.new(32, F, -21), Vector3.new(0, 0, 1))
	marker(wr, "BayDoor", Vector3.new(14.5, F, -2), Vector3.new(1, 0, 0))
end

local function partsRoom(garage: Instance)
	local pc = Kit.model(garage, "PartsCounter")
	box(pc, "CounterTop", XM - 1, 3.0, 6, XM + 2.4, 3.4, 14, C.metalDark, M.smooth)
	box(pc, "CounterBell", XM - 0.6, 3.4, 9.6, XM - 0.2, 3.8, 10, C.yellow, M.metal)
	marker(pc, "ServicePoint", Vector3.new(11.5, F, 10), Vector3.new(1, 0, 0))
	marker(pc, "StaffPoint", Vector3.new(17, F, 10), Vector3.new(-1, 0, 0))
	marker(pc, "HandoverPoint", Vector3.new(XM + 0.5, 3.4, 10), Vector3.new(-1, 0, 0))
	-- v35 (wr-play eval 10-23 TOP 9: players jumped up and stood on the counter, y 3.4): the window over the counter
	-- is filled with a clear solid from the counter top to 12 (above any jump: 7.2 from the tool cart's 3.5 tray), the
	-- whole counter depth. A 3.5-high header left a gap a character wedged into (Play: Climbing at y 5.9). Parts handed
	-- over still land on the counter (anchored; CarryService's floor ray starts inside it, so it hits the top); every
	-- counter prompt has RequiresLineOfSight off; clear, so the camera's popper passes through it like window glass
	local ns = box(pc, "NoStand", XM - 1, 3.4, 6, XM + 2.4, 12, 14, C.metalDark, M.smooth, { shadow = false })
	ns.Transparency = 1
	ns.CanTouch = false

	local shelves = Kit.folder(garage, "PartsShelves")
	local r = Kit.rng(23)
	local boxColors = { C.cardboard, C.blue, C.red, C.cardboard, C.yellow, C.metal }
	local function shelf(name: string, x0: number, z0: number, x1: number, z1: number)
		local m = Kit.model(shelves, name)
		local alongX = (x1 - x0) >= (z1 - z0)
		for _, py in ipairs({ 0.2, 3.4, 6.6, 9.8 }) do
			box(m, "Board", x0, py, z0, x1, py + 0.2, z1, C.blue, M.metal)
		end
		local corners = { { x0, z0 }, { x1 - 0.3, z0 }, { x0, z1 - 0.3 }, { x1 - 0.3, z1 - 0.3 } }
		for _, c in ipairs(corners) do
			box(m, "Upright", c[1], F, c[2], c[1] + 0.3, 11, c[2] + 0.3, C.metalDark, M.metal)
		end
		-- stock on every level (no empty shelves): cartons of different sizes, slightly turned
		for _, py in ipairs({ 0.4, 3.6, 6.8, 10.0 }) do
			local len = alongX and (x1 - x0) or (z1 - z0)
			local t = 0.6
			while t < len - 1.6 do
				local w = 1.2 + r() * 1.4
				local h = 1.0 + r() * 1.6
				if py >= 10 then
					h = math.min(h, 1.2)
				end
				local d = (alongX and (z1 - z0) or (x1 - x0)) - 0.6
				local cx = alongX and (x0 + t + w / 2) or ((x0 + x1) / 2)
				local cz = alongX and ((z0 + z1) / 2) or (z0 + t + w / 2)
				local size = alongX and Vector3.new(w, h, d * (0.7 + r() * 0.25)) or Vector3.new(d * (0.7 + r() * 0.25), h, w)
				Kit.part(m, "Carton", size, CFrame.new(cx, py + h / 2, cz) * CFrame.Angles(0, math.rad((r() - 0.5) * 6), 0),
					boxColors[math.floor(r() * #boxColors) + 1], M.smooth, { shadow = false })
				t += w + 0.3 + r() * 0.6
			end
		end
		return m
	end
	shelf("Shelf1", 18, Z1 - 3.4, 35, Z1 - 1)
	shelf("Shelf2", X1 - 3.4, 6, X1 - 1, 15)
	shelf("Shelf3", 23, 9, 31, 11.4) -- island: 6.6 behind the counter so a 3rd-person camera fits
end

function Shop.build(garage: Model)
	local shell = Kit.folder(garage, "Building")
	bayShell(shell)
	local bays = garage:FindFirstChild("Bays") or Kit.folder(garage, "Bays")
	bay1(garage, bays)
	waitingRoom(garage)
	partsRoom(garage)

	-- spawn on the bay apron, east of the car's way in, looking into Bay 1: the first customer's car is the first
	-- thing on screen (first-60-seconds check 10-21: from the old walkway spawn the bay door was edge-on, car unseen).
	-- Clear of the drive lane (z -36), the car's path (x -3..3) and the tyre display (z > -27).
	local spawn = Kit.part(garage, "SpawnLocation", Vector3.new(4, 0.2, 4), CFrame.lookAt(Vector3.new(8, 0.2, -30), Vector3.new(5.04, 0.2, -20.45)),
		C.concrete, M.concrete, { class = "SpawnLocation" }) :: SpawnLocation
	spawn.Duration = 0
	spawn.Neutral = true
	box(shell, "SpawnRing", 5.4, 0.2, -32.4, 10.6, 0.25, -27.6, C.yellow, M.smooth, { collide = false })
end

return Shop
