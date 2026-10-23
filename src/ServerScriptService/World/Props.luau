--!strict
-- World/Props: second dressing pass — variants of the same shapes (turned / moved a little, no copy-paste look),
-- shutter ribs, street furniture, block stand-in cars (Placeholder3D = "Car": the real car meshes replace them).
-- Nothing here is in world_contract (free to change). Cars stay OFF the Parking1..6 spots (those are the
-- customer queue) and off the drive lane.

local Kit = require(script.Parent.Kit)
local Town = require(script.Parent.Town)
local GearportProps = require(script.Parent.GearportProps)
local Site = require(script.Parent.Site)
local C, M = Kit.C, Kit.M
local box, rod = Kit.box, Kit.rod

local Props = {}

local F = 0.2
local PAD = Color3.fromRGB(34, 34, 38)

-- block stand-in car, car_spec size (7.6 x 5.8 x 17), front = local -Z, pivot = ground centre
function Props.standInCar(parent: Instance, name: string, cf: CFrame, paint: Color3): Model
	local m = Kit.model(parent, name)
	m:SetAttribute("Placeholder3D", "Car")
	local function p(n: string, size: Vector3, off: CFrame, color: Color3, mat: Enum.Material?, opts: Kit.Opts?)
		return Kit.part(m, n, size, cf * off, color, mat, opts)
	end
	local dark = Color3.new(paint.R * 0.7, paint.G * 0.7, paint.B * 0.7)
	p("Body", Vector3.new(7.6, 2.4, 17), CFrame.new(0, 0.5 + 1.2, 0), paint, M.smooth)
	p("Hood", Vector3.new(7.2, 0.4, 4.6), CFrame.new(0, 3.1, -5.6), paint, M.smooth)
	p("Trunk", Vector3.new(7.2, 0.4, 3.0), CFrame.new(0, 3.1, 6.6), paint, M.smooth)
	p("Cabin", Vector3.new(6.6, 2.4, 8.2), CFrame.new(0, 3.1 + 1.2, 0.4), paint, M.smooth)
	p("Glass", Vector3.new(6.7, 1.7, 7.6), CFrame.new(0, 3.1 + 1.3, 0.4), Color3.fromRGB(46, 58, 72), M.glass, { transparency = 0.15 })
	p("Roof", Vector3.new(6.4, 0.3, 6.4), CFrame.new(0, 5.65, 0.6), paint, M.smooth)
	p("BumperF", Vector3.new(7.8, 1.0, 0.8), CFrame.new(0, 1.3, -8.6), dark, M.smooth)
	p("BumperR", Vector3.new(7.8, 1.0, 0.8), CFrame.new(0, 1.4, 8.6), dark, M.smooth)
	for _, sx in ipairs({ -1, 1 }) do
		p("Headlight", Vector3.new(1.6, 0.6, 0.2), CFrame.new(sx * 2.6, 2.5, -8.55), Color3.fromRGB(250, 248, 230), M.neon, { collide = false })
		p("Taillight", Vector3.new(1.4, 0.5, 0.2), CFrame.new(sx * 2.7, 2.6, 8.55), Color3.fromRGB(200, 40, 40), M.smooth, { collide = false })
		for _, wz in ipairs({ -5, 5 }) do
			p("Wheel", Vector3.new(0.9, 2.4, 2.4), CFrame.new(sx * 3.25, 1.2, wz), PAD, M.smooth, { shape = "cyl" })
			p("Rim", Vector3.new(0.92, 1.4, 1.4), CFrame.new(sx * 3.26, 1.2, wz), C.steel, M.metal, { shape = "cyl", collide = false })
		end
	end
	return m
end

-- roll-up shutter ribs: lines on the shutter faces that stay right when wr-dev resizes the shutter
function Props.shutterRibs(shutter: BasePart)
	for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
		local gui = Instance.new("SurfaceGui")
		gui.Name = "Ribs"
		gui.Face = face
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 40
		gui.LightInfluence = 1
		gui.ClipsDescendants = true
		local list = Instance.new("UIListLayout")
		list.FillDirection = Enum.FillDirection.Vertical
		list.VerticalAlignment = Enum.VerticalAlignment.Bottom -- the bottom slat always shows
		list.Parent = gui
		for i = 1, 36 do
			local row = Instance.new("Frame")
			row.Name = "Rib"
			row.BackgroundTransparency = 1
			row.Size = UDim2.new(1, 0, 0, 16) -- one slat = 0.4 stud
			row.LayoutOrder = i
			local line = Instance.new("Frame")
			line.BorderSizePixel = 0
			line.BackgroundColor3 = Color3.fromRGB(132, 138, 148) -- (v35: a shade darker, the slats read when it is down)
			line.Size = UDim2.new(1, 0, 0, 3)
			line.Position = UDim2.new(0, 0, 1, -3)
			line.Parent = row
			row.Parent = gui
		end
		-- v35: the bottom bar (a steel angle + rubber seal, every roll-up door has one): the strip under the hood when
		-- open, and the edge that reads "a door, not a wall" when it is down (the under-car view shows it closed)
		local bar = Instance.new("Frame")
		bar.Name = "BottomBar"
		bar.BorderSizePixel = 0
		bar.BackgroundColor3 = Color3.fromRGB(84, 88, 96)
		bar.Size = UDim2.new(1, 0, 0, 10)
		bar.LayoutOrder = 99
		bar.Parent = gui
		gui.Parent = shutter
	end
end

local function toolCart(parent: Instance, x: number, z: number, yaw: number)
	-- small two-shelf rolling cart, same red as the big chest (style_B)
	local m = Kit.model(parent, "ToolCart1")
	local O = CFrame.new(x, F, z) * CFrame.Angles(0, math.rad(yaw), 0)
	local function p(n: string, size: Vector3, off: CFrame, color: Color3, mat: Enum.Material?, opts: Kit.Opts?)
		return Kit.part(m, n, size, O * off, color, mat, opts)
	end
	for _, sy in ipairs({ 1.0, 3.2 }) do
		p("Tray", Vector3.new(2.4, 0.2, 3.4), CFrame.new(0, sy, 0), C.red, M.smooth)
		p("TrayLip", Vector3.new(2.4, 0.4, 0.1), CFrame.new(0, sy + 0.2, -1.7), C.redDark, M.smooth)
		p("TrayLip", Vector3.new(2.4, 0.4, 0.1), CFrame.new(0, sy + 0.2, 1.7), C.redDark, M.smooth)
	end
	for _, cx in ipairs({ -1.1, 1.1 }) do
		for _, cz in ipairs({ -1.6, 1.6 }) do
			p("Leg", Vector3.new(0.15, 3.0, 0.15), CFrame.new(cx, 0.4 + 1.5, cz), C.steel, M.metal)
			p("Caster", Vector3.new(0.25, 0.5, 0.5), CFrame.new(cx, 0.25, cz), PAD, M.smooth, { shape = "cyl" })
		end
	end
	p("Handle", Vector3.new(2.0, 0.15, 0.15), CFrame.new(0, 4.0, 1.9), C.steel, M.metal)
	p("Socket", Vector3.new(1.6, 0.5, 1.0), CFrame.new(-0.2, 3.55, -0.6), PAD, M.smooth, { collide = false })
	p("Rag", Vector3.new(1.0, 0.1, 1.2), CFrame.new(0.5, 3.35, 0.9) * CFrame.Angles(0, 0.4, 0), C.lineWhite, M.smooth, { collide = false })
	p("Box", Vector3.new(1.6, 0.8, 1.2), CFrame.new(0, 1.5, 0.3), C.blue, M.smooth, { collide = false })
	return m
end

local function tireStack(parent: Instance, name: string, x: number, z: number, n: number, seed: number)
	-- lying tires (cylinder placeholders, same as the rack: Placeholder3D = "Tire"), each turned / shifted a bit
	local r = Kit.rng(seed)
	local m = Kit.model(parent, name)
	for i = 0, n - 1 do
		local t = Kit.part(m, "Tire", Vector3.new(0.9, 2.4, 2.4),
			CFrame.new(x + (r() - 0.5) * 0.3, F + 0.45 + i * 0.9, z + (r() - 0.5) * 0.3) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(r() * 3, 0, 0),
			PAD, M.plastic, { shape = "cyl" })
		t:SetAttribute("Placeholder3D", "Tire")
	end
	return m
end

local function benchGrinder(parent: Instance, x: number, y: number, z: number)
	local m = Kit.model(parent, "BenchGrinder")
	box(m, "Base", x - 0.6, y, z - 0.4, x + 0.6, y + 0.3, z + 0.4, C.metalDark, M.metal)
	Kit.part(m, "Motor", Vector3.new(1.2, 0.8, 0.8), CFrame.new(x, y + 0.7, z), Color3.fromRGB(70, 130, 90), M.smooth, { shape = "cyl" })
	for _, s in ipairs({ -1, 1 }) do
		Kit.part(m, "Wheel", Vector3.new(0.3, 1.1, 1.1), CFrame.new(x + s * 0.8, y + 0.7, z), C.steel, M.metal, { shape = "cyl" })
		box(m, "Guard", x + s * 0.8 - 0.2, y + 1.1, z - 0.6, x + s * 0.8 + 0.2, y + 1.3, z + 0.6, Color3.fromRGB(70, 130, 90), M.smooth)
	end
	return m
end

local function monitor(parent: Instance, name: string, x: number, y: number, z: number, yaw: number)
	local m = Kit.model(parent, name)
	local O = CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(yaw), 0)
	Kit.part(m, "Stand", Vector3.new(0.8, 0.1, 0.6), O * CFrame.new(0, 0.05, 0), PAD, M.smooth)
	Kit.part(m, "Neck", Vector3.new(0.15, 0.6, 0.15), O * CFrame.new(0, 0.4, 0.1), PAD, M.smooth)
	Kit.part(m, "Screen", Vector3.new(1.8, 1.1, 0.12), O * CFrame.new(0, 1.15, 0), PAD, M.smooth)
	Kit.part(m, "Display", Vector3.new(1.65, 0.95, 0.02), O * CFrame.new(0, 1.15, -0.07), Color3.fromRGB(70, 130, 190), M.neon, { collide = false }).Transparency = 0.3
	Kit.part(m, "Keyboard", Vector3.new(1.5, 0.08, 0.5), O * CFrame.new(0, 0.04, -0.7), Color3.fromRGB(60, 60, 66), M.smooth, { collide = false })
	return m
end

local function shopExtras(garage: Model)
	local d = garage:FindFirstChild("Dressing") :: Folder
	local tools = garage:FindFirstChild("Tools") :: Folder
	toolCart(tools, 11.9, 15.0, 86) -- parked in the corner by the bench end (keeps the east walkway 9 wide)
	-- (the two stacks under Bay 1's rack went when the rack came down to floor level)
	tireStack(d, "TireStack", 15.6, -26.4, 4, 73) -- outside on the walkway, by the display rack
	benchGrinder(d, 6.5, 3.4, 18.2)
	-- work lamp clamped on the bench
	box(d, "LampPole", 11.6, 3.4, 18.4, 11.8, 6.6, 18.6, PAD, M.metal)
	rod(d, "LampArm", Vector3.new(11.7, 6.6, 18.5), Vector3.new(10.4, 7.2, 17.6), 0.15, 0.15, PAD, M.metal)
	box(d, "LampHead", 9.9, 6.7, 17.2, 10.9, 7.3, 18.0, C.yellow, M.smooth)
	-- reception desk + parts counter: monitors, stool
	monitor(d, "DeskMonitor", 21.6, 3.7, -7.0, 180) -- screen toward the staff side
	monitor(d, "CounterMonitor", 15.6, 3.4, 12.6, -90)
	Kit.post(d, "StoolSeat", 20.5, -5.0, 2.6, 2.9, 1.4, C.rubber, M.smooth, { collide = false })
	Kit.post(d, "StoolLeg", 20.5, -5.0, F, 2.6, 0.25, C.steel, M.metal, { collide = false })
	box(d, "Binder", 13.4, 3.4, 7.0, 14.2, 3.6, 8.2, C.blue, M.smooth, { collide = false })
	-- solid, so the camera stops in front of it instead of backing onto the wall behind it (test 2 TOP10)
	local ps = box(d, "PartsSign", 13.6, 9.0, 7, 13.8, 10.4, 13, C.blue, M.smooth)
	Kit.label(ps, Enum.NormalId.Left, "PARTS", Color3.new(1, 1, 1), Color3.fromRGB(28, 30, 40))
	-- vending machine: product rows behind the window, buttons, light strip
	local vm = garage.WaitingRoom:FindFirstChild("VendingMachine") :: Model?
	if vm then
		local cols = { C.red, C.blue, C.yellow, Color3.fromRGB(60, 170, 90), C.lineWhite }
		local r = Kit.rng(81)
		for row = 0, 3 do
			for k = 0, 4 do
				box(vm, "Can", 25.6 + k * 0.4, 2.8 + row * 1.0, -1.08, 25.9 + k * 0.4, 3.4 + row * 1.0, -1.02, cols[math.floor(r() * #cols) + 1], M.smooth, { collide = false, shadow = false })
			end
		end
		for k = 0, 3 do
			box(vm, "Button", 28.1, 3.6 + k * 0.6, -1.15, 28.5, 3.9 + k * 0.6, -1.1, C.lineWhite, M.smooth, { collide = false })
		end
		box(vm, "LightStrip", 25.2, 6.9, -1.1, 28.8, 7.2, -1.0, Color3.fromRGB(255, 250, 230), M.neon, { collide = false })
	end
	-- magazine rack by the sofa
	box(d, "MagRack", 26.2, F, -18.6, 27.6, 3.0, -17.4, C.wood, M.wood)
	for k = 0, 2 do
		box(d, "MagazineUp", 26.4 + k * 0.4, 1.6, -18.5, 26.6 + k * 0.4, 3.2, -17.5, ({ C.red, C.blue, C.yellow })[k + 1], M.smooth, { collide = false })
	end
	-- shutter ribs + hood ribs
	local bay1 = garage.Bays:FindFirstChild("Bay1")
	local shutter = bay1 and bay1:FindFirstChild("Shutter") :: BasePart?
	if shutter then
		Props.shutterRibs(shutter)
	end
	for k = 0, 2 do
		box(d, "HoodRib", -8.6, 14.4 + k * 0.6, -20.9, 8.6, 14.5 + k * 0.6, -20.8, Color3.fromRGB(128, 134, 144), M.metal, { collide = false })
	end
end

local function streetLamp(parent: Instance, x: number, z: number, faceZ: number)
	local m = Kit.model(parent, "StreetLamp")
	Kit.post(m, "Pole", x, z, 0.5, 18, 0.7, C.trim, M.metal)
	Kit.post(m, "Base", x, z, 0.5, 1.6, 1.2, C.trim, M.metal)
	rod(m, "Arm", Vector3.new(x, 17.6, z), Vector3.new(x, 18.2, z + faceZ * 4), 0.3, 0.3, C.trim, M.metal)
	box(m, "Head", x - 0.7, 17.6, z + faceZ * 4 - 1.2, x + 0.7, 18.2, z + faceZ * 4 + 1.2, C.trim, M.metal)
	box(m, "Lens", x - 0.5, 17.55, z + faceZ * 4 - 1.0, x + 0.5, 17.6, z + faceZ * 4 + 1.0, Color3.fromRGB(255, 248, 225), M.neon, { collide = false })
	return m
end

local function street(garage: Model)
	local st = Kit.folder(garage:FindFirstChild("Town") or garage, "Street")
	-- street lamps on both sidewalks, staggered
	for _, x in ipairs({ -200, -130, -60, 16, 80, 150, 240 }) do -- (16: off the v23 service apron x -24..12)
		if not (x > 38 and x < 58) and not (x > -104 and x < -86) then
			streetLamp(st, x, -73, -1)
		end
	end
	-- (far-side lamps: the avenue median has banner lamps now, World/Gearport)
	-- near-sidewalk trees in pits, only beside the lot (the shop front stays in view)
	local r = Kit.rng(91)
	for i, x in ipairs({ -240, -196, -152, -118, 128, 160, 186, 276 }) do
		box(st, "TreePit", x - 2, 0.5, -71.8, x + 2, 0.55, -67.8, Color3.fromRGB(96, 74, 56), M.smooth, { collide = false })
		Town.tree(st, x, -69.8, 0.8 + r() * 0.3, 900 + i)
	end
	-- fire hydrant (light-blue cap on the avenue main, curb painted 15 ft each way), the corner collection box,
	-- a litter bin — 3D props placed by notes/research/car_knowledge/street_props.md (World/GearportProps)
	GearportProps.hydrant(st, "Hydrant_Blue", -46, Site.WALK_Z0 - 0.5, -1) -- (curb street edge; v23: 15 ft paint ends before the service apron)
	GearportProps.mesh(st, "Mailbox", 190.4, 0.5, -72.4, GearportProps.facing(0, 1), true) -- slot toward the sidewalk
	GearportProps.mesh(st, "ParkBin_1", 19, 0.5, -72.6, 0, true) -- (between the lamp and the crosswalk landing x 22..30)
	local bench = Kit.model(st, "Bench")
	-- (v23: off the curb cuts — in front of the showroom lot, west of the buyers' path at x 84)
	box(bench, "Seat", 64, 2.0, -72.8, 72, 2.3, -71.0, C.wood, M.wood)
	box(bench, "Back", 64, 2.3, -73.2, 72, 4.4, -72.9, C.wood, M.wood)
	for _, bx in ipairs({ 64.6, 71.4 }) do
		box(bench, "Leg", bx - 0.2, 0.5, -73.1, bx + 0.2, 2.0, -71.2, PAD, M.metal)
	end
end

local function parkedCars(garage: Model)
	local d = Kit.folder(garage:FindFirstChild("Dressing") or garage, "ParkedCars")
	local site = garage:FindFirstChild("Site")
	local lot = site and site:FindFirstChild("Lot")
	-- two STAFF spots at the lot's east end (not the customer Parking1..6)
	if lot then
		for _, lx in ipairs({ 74, 86, 98 }) do
			box(lot, "ParkingLine", lx - 0.2, 0, -66, lx + 0.2, 0.05, -46, C.lineWhite, M.smooth, { collide = false })
		end
		for _, sx in ipairs({ 80, 92 }) do
			local t = box(lot, "StaffMark", sx - 2.4, 0, -51.4, sx + 2.4, 0.05, -49.4, C.lineWhite, M.smooth, { collide = false })
			t.Transparency = 1
			Kit.label(t, Enum.NormalId.Top, "STAFF", C.lineWhite, nil)
		end
	end
	Props.standInCar(d, "StaffCar1", CFrame.new(80, 0, -57) * CFrame.Angles(0, math.rad(1.5), 0), Color3.fromRGB(196, 54, 48))
	Props.standInCar(d, "StaffCar2", CFrame.new(92.3, 0, -56.2) * CFrame.Angles(0, math.rad(-2), 0), Color3.fromRGB(230, 230, 226))
	-- (street-parked cars: Town.AvenueParking, World/Gearport)
end

function Props.build(garage: Model)
	shopExtras(garage)
	street(garage)
	parkedCars(garage)
end

return Props
