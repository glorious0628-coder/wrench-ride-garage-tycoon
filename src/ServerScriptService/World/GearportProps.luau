--!strict
-- World/GearportProps (wr-builder): street props. Part-built ones per the main decision
-- (notes/gpt/main/cc_props_main_decision.md) and uploaded 3D ones (art/3d/street_props/README.md), all placed by the
-- street-props research note notes/research/car_knowledge/street_props.md (section numbers in brackets, e.g. [A1]):
-- where they stand, how far apart, which colour. Few per area, colours from the town palette.

local InsertService = game:GetService("InsertService")

local Kit = require(script.Parent.Kit)
local C, M = Kit.C, Kit.M
local box, marker = Kit.box, Kit.marker

local Props = {}

local DECO = { collide = false }
local IRON = Color3.fromRGB(40, 42, 46) -- near-black iron [A3]
local LAMP_BLACK = Color3.fromRGB(34, 36, 40)
local GLOBE = Color3.fromRGB(255, 244, 222) -- milky glass, warm light [B3 3-4]
local CURB_YELLOW = Color3.fromRGB(240, 200, 50)

-- uploaded meshes (one MeshPart each, origin = bottom centre, front = -Z; 1 stud = 0.28 m real size)
local MESH: { [string]: number } = {
	Hydrant = 137716807359932, -- chrome-yellow barrel, green cap = class A [A1]
	Hydrant_Blue = 77975202703285, -- same barrel, light-blue cap = class AA (big mains: the avenue)
	Mailbox = 109072415236527, -- olive collection box (the green era) [A2]
	Cone = 95815519493318, -- 28 in cone [B1 1-2]
	Trashbag = 82654359453942,
	FireEscapeStair = 74260508504792, -- origin = bottom end centre, climbs toward -Z, top end (0, 11.61, -7.85)
	Tire = 120248490181551, -- 3.12 across: used at 0.88 (our cars' tyres are 2.75)
	GasCan = 107128474000949,
	DrainPan = 124236586583210, -- red waste-oil drain pan (art/3d/models.json; Bay 1 by the tyre rack)
	OilDrum = 120609728689812, -- 55 gal drum, red (main 3D 10-22): 2.10 x 3.13 x 2.10
	OilDrum_Blue = 134476345453989,
	BatteryCharger = 116017220546690, -- wheeled shop battery charger (the mock's red box on the right wall): 1.65 x 2.79 x 1.44
	BenchVise = 97750393235051, -- 6 in swivel bench vise: 0.90 x 0.78 x 1.56
	FireExtinguisher = 129213220316956, -- 10 lb ABC + wall hook (main 3D 10-22): 0.90 x 2.11 x 0.66, back = wall side
	HoseReel = 124066712233090, -- wall air-hose reel, dark steel + red hose: 1.90 x 3.73 x 0.89, disc centre 2.779 up
	ShopTrashCan = 77334973451262, -- shop trash can: 1.90 x 2.51 x 1.83
	Creeper = 72358194138192, -- mechanic's creeper (main 3D 10-22, colour + ORM in its SurfaceAppearance): 1.86 x 0.60 x 3.80, headrest +Z once imported
	ParkBin_1 = 90669403280357,
	ParkBin_2 = 80465685259602,
	-- background cars from the bought pack (art/3d/bundle_bg_cars/README.md; origin = ground, between the axles,
	-- front -Z). Only far from players (60+ studs) or in junkyard piles (the _Worn ones):
	-- notes/gpt/main/bundle_bg_cars_main_decision.md
	-- 10-23 front amber turn-signal sections (art/3d/turn_signal_v1/v3/bg): Sedan_2/_4, Compact_1, Pickup_1(_Worn), Van_1, Sedan_2_Worn
	BG_Sedan_1 = 110125114514309,
	BG_Sedan_2 = 118439700947029,
	BG_Sedan_3 = 134492234375177,
	BG_Sedan_4 = 91829139234932,
	BG_Compact_1 = 118294274021503,
	BG_Pickup_1 = 93568341012755,
	BG_Van_1 = 114349187550891,
	BG_Sedan_1_Worn = 113168265405069,
	BG_Sedan_2_Worn = 88560109658211,
	BG_Pickup_1_Worn = 87362202102346,
}
local TIRE_SCALE = 0.88

local cache: { [string]: MeshPart | false } = {}
local function template(name: string): MeshPart?
	local c = cache[name]
	if c ~= nil then
		return if c then c else nil
	end
	local found: MeshPart? = nil
	local ok, model = pcall(function()
		return InsertService:LoadAsset(MESH[name])
	end)
	if ok and model then
		local mp = model:FindFirstChildWhichIsA("MeshPart", true)
		if mp then
			found = mp:Clone()
		end
		model:Destroy()
	else
		warn("[GearportProps] could not load " .. name .. ": " .. tostring(model))
	end
	cache[name] = found or false
	return found
end

-- yaw that turns a mesh's front (-Z in the GLB) toward the direction (dx, dz). Imported meshes come in turned
-- 180° about Y (glTF -> Roblox, like the car meshes: tools/bake_carmeshes.luau), so the turn adds half a circle.
local function facing(dx: number, dz: number): number
	return math.atan2(-dx, -dz) + math.pi
end
Props.facing = facing

-- a 3D prop standing with its bottom centre at (x, y0, z), front toward yaw; nil if the mesh couldn't load.
-- scale: one number, or per axis (a crushed car = Vector3.new(1, 0.45, 1)); tilt: a small turn after the yaw
function Props.mesh(parent: Instance, name: string, x: number, y0: number, z: number, yaw: number, collide: boolean,
	scale: (number | Vector3)?, tilt: CFrame?): MeshPart?
	local t = template(name)
	if not t then
		return nil
	end
	local p = t:Clone()
	p.Name = "Prop_" .. name
	local sc = if typeof(scale) == "Vector3" then scale else Vector3.one * ((scale :: number?) or 1)
	p.Size = t.Size * sc
	p.CFrame = CFrame.new(x, y0 + p.Size.Y / 2, z) * CFrame.Angles(0, yaw, 0) * (tilt or CFrame.identity)
	p.PivotOffset = CFrame.new(0, -p.Size.Y / 2, 0)
	p.Anchored = true
	p.CanCollide = collide
	p.CanQuery = collide
	p.CanTouch = false
	p.Parent = parent
	return p
end

-- [A1] fire hydrant on the sidewalk ~2 ft behind the curb, the big outlet toward the street; the curb painted
-- yellow 15 ft each way (no parking) — curbZ = the curb's street edge (paint covers the curb top + face), street = +1 / -1 (which way the street is)
local function hydrant(parent: Instance, name: string, x: number, curbZ: number, street: number)
	local m = Kit.model(parent, "Hydrant")
	local hz = curbZ - street * 1.9
	Props.mesh(m, name, x, 0.5, hz, facing(1, 0), true) -- (the mesh's two hose outlets run along the curb)
	-- the mesh has no big pumper outlet or top nut: add them — the pumper faces the street, its cap in the class colour
	local cap = if name == "Hydrant_Blue" then Color3.fromRGB(80, 190, 236) else Color3.fromRGB(70, 160, 80)
	Kit.part(m, "PumperOutlet", Vector3.new(0.6, 0.95, 0.95), CFrame.new(x, 2.0, hz + street * 0.6) * CFrame.Angles(0, math.pi / 2, 0),
		Color3.fromRGB(232, 190, 30), M.metal, { collide = false, shape = "cyl" })
	Kit.part(m, "PumperCap", Vector3.new(0.2, 0.85, 0.85), CFrame.new(x, 2.0, hz + street * 0.98) * CFrame.Angles(0, math.pi / 2, 0),
		cap, M.metal, { collide = false, shape = "cyl" })
	Kit.post(m, "OperatingNut", x, hz, 3.5, 3.78, 0.36, Color3.fromRGB(200, 170, 40), M.metal, DECO)
	box(m, "CurbPaint", x - 16.5, 0, curbZ - street * 0.5, x + 16.5, 0.53, curbZ + street * 0.06, CURB_YELLOW, M.smooth, DECO)
end

-- [B3 3-4] old-style street lamp (big street / park / river walk): black pole with a wide foot, milky glass globe
function Props.oldLamp(parent: Instance, x: number, z: number, y0: number)
	local m = Kit.model(parent, "OldLamp")
	Kit.post(m, "Base", x, z, y0, y0 + 1.6, 1.2, LAMP_BLACK, M.metal)
	Kit.post(m, "Post", x, z, y0 + 1.6, y0 + 11.6, 0.45, LAMP_BLACK, M.metal)
	Kit.part(m, "Globe", Vector3.new(1.9, 1.9, 1.9), CFrame.new(x, y0 + 12.4, z), GLOBE, M.neon, { collide = false, shape = "ball" })
	Kit.post(m, "Finial", x, z, y0 + 13.2, y0 + 13.8, 0.5, LAMP_BLACK, M.metal, DECO)
	return m
end

-- [B1 1-1] work-zone drum: plastic, black base, orange / white bands with orange on top
local function drum(parent: Instance, x: number, z: number)
	local m = Kit.model(parent, "ConstructionDrum")
	Kit.post(m, "Base", x, z, 0, 0.5, 2.6, C.rubber, M.smooth)
	Kit.post(m, "Body", x, z, 0.5, 3.6, 2.1, Color3.fromRGB(236, 120, 40), M.smooth)
	for _, y in ipairs({ 1.4, 2.6 }) do
		Kit.post(m, "Band", x, z, y, y + 0.5, 2.2, Color3.fromRGB(246, 244, 236), M.smooth, DECO)
	end
end

-- steel crowd barrier round the work space: two feet, a see-through frame, end bars, top rail
local function barrier(parent: Instance, x0: number, x1: number, z: number)
	local m = Kit.model(parent, "SteelBarrier")
	for _, fx in ipairs({ x0 + 0.3, x1 - 0.3 }) do
		box(m, "Foot", fx - 0.15, 0, z - 0.8, fx + 0.15, 0.2, z + 0.8, C.steel, M.metal)
	end
	box(m, "Frame", x0, 0.2, z - 0.06, x1, 3.2, z + 0.06, C.steel, M.metal, { transparency = 0.55 })
	for _, fx in ipairs({ x0, x1 - 0.15 }) do
		box(m, "EndBar", fx, 0.2, z - 0.1, fx + 0.15, 3.2, z + 0.1, C.steel, M.metal, DECO)
	end
	box(m, "TopRail", x0, 3.2, z - 0.12, x1, 3.5, z + 0.12, Color3.fromRGB(170, 176, 182), M.metal, DECO)
end

-- [B1 1-6] ROAD WORK AHEAD (W20-1): orange diamond, black words, on a post facing the coming traffic (+X here),
-- bottom over 7 ft up (people walk here)
local function workAheadSign(parent: Instance, x: number, z: number)
	local m = Kit.model(parent, "RoadWorkSign")
	Kit.post(m, "Post", x, z, 0.5, 9.4, 0.3, C.steel, M.metal, DECO)
	Kit.part(m, "Diamond", Vector3.new(0.1, 3.3, 3.3), CFrame.new(x + 0.2, 10.4, z) * CFrame.Angles(math.rad(45), 0, 0),
		Color3.fromRGB(240, 130, 30), M.smooth, DECO)
	local words = Kit.part(m, "Words", Vector3.new(0.05, 2.2, 2.6), CFrame.new(x + 0.28, 10.4, z), Color3.new(1, 1, 1), M.smooth,
		{ collide = false, transparency = 1 })
	words.CanQuery = false
	local g = Kit.label(words, Enum.NormalId.Right, "ROAD\nWORK\nAHEAD", Color3.fromRGB(20, 20, 20), nil, Enum.Font.GothamBlack)
	g.PixelsPerStud = 30
end

-- [A4] pay-by-plate kiosk (one per parking stretch; single coin meters went in 2015): box post, screen, solar panel
local function kiosk(parent: Instance, x: number, z: number)
	local m = Kit.model(parent, "ParkingKiosk")
	box(m, "Body", x - 0.5, 0.5, z - 0.35, x + 0.5, 5.2, z + 0.35, Color3.fromRGB(70, 78, 90), M.metal)
	box(m, "Screen", x - 0.35, 3.6, z - 0.4, x + 0.35, 4.6, z - 0.35, Color3.fromRGB(110, 190, 220), M.neon, DECO)
	Kit.part(m, "Solar", Vector3.new(1.3, 0.12, 1.1), CFrame.new(x, 5.5, z) * CFrame.Angles(math.rad(-20), 0, 0), Color3.fromRGB(30, 44, 80), M.glass, DECO)
end

-- [A4] parking-zone sign: zone number, pay at the kiosk / app
local function zoneSign(parent: Instance, x: number, z: number, zone: string)
	local m = Kit.model(parent, "ParkingZoneSign")
	Kit.post(m, "Post", x, z, 0.5, 9.4, 0.3, C.steel, M.metal, DECO)
	local plate = box(m, "Plate", x - 0.06, 7, z - 1.1, x + 0.06, 9.4, z + 1.1, Color3.fromRGB(250, 250, 246), M.smooth, DECO)
	for _, face in ipairs({ Enum.NormalId.Left, Enum.NormalId.Right }) do
		local g = Kit.label(plate, face, "P\nZONE " .. zone .. "\nPAY AT KIOSK", Color3.fromRGB(30, 110, 60), nil, Enum.Font.GothamBold)
		g.PixelsPerStud = 30
	end
end

-- [B3 3-1/3-2] guard post: yellow steel pipe with a dome top and one black band
local function bollard(parent: Instance, x: number, z: number, y0: number)
	local m = Kit.model(parent, "Bollard")
	Kit.post(m, "Pipe", x, z, y0, y0 + 3.3, 1.1, C.yellow, M.metal) -- 1.1 across: pathfinding sees it (thinner posts snag)
	Kit.part(m, "Dome", Vector3.new(1.1, 1.1, 1.1), CFrame.new(x, y0 + 3.3, z), C.yellow, M.metal, { collide = false, shape = "ball" })
	Kit.post(m, "Band", x, z, y0 + 2.5, y0 + 2.8, 1.16, Color3.fromRGB(30, 30, 30), M.smooth, DECO)
end

-- [A3] fire escape on a back (alley) wall facing -Z at zb: a landing per upper floor (grating, rails, wall
-- brackets), the stair between landings (3D), and the drop ladder hanging up out of reach from the lowest landing
-- (~12 ft up). Marker FireEscapeStairSpot = the stair's bottom end.
local function fireEscape(parent: Instance, cx: number, zb: number, storeys: number)
	local m = Kit.model(parent, "FireEscape")
	for f = 2, storeys do
		local y = 13 + (f - 2) * 9 - 0.3
		box(m, "Landing", cx - 6, y, zb - 2.6, cx + 6, y + 0.3, zb, IRON, M.metal)
		box(m, "Rail", cx - 6, y + 3, zb - 2.6, cx + 6, y + 3.2, zb - 2.4, IRON, M.metal, DECO)
		box(m, "RailGrid", cx - 6, y + 0.3, zb - 2.55, cx + 6, y + 3, zb - 2.45, IRON, M.metal, { collide = false, transparency = 0.6 })
		for _, sx in ipairs({ cx - 6, cx + 5.8 }) do
			box(m, "SideRail", sx, y + 3, zb - 2.6, sx + 0.2, y + 3.2, zb, IRON, M.metal, DECO)
			box(m, "RailPost", sx, y + 0.3, zb - 2.6, sx + 0.2, y + 3, zb - 2.4, IRON, M.metal, DECO)
		end
		for _, bx in ipairs({ cx - 4.5, cx + 4.5 }) do -- wall brackets under the landing
			Kit.rod(m, "Bracket", Vector3.new(bx, y - 3, zb), Vector3.new(bx, y, zb - 2.3), 0.25, 0.25, IRON, M.metal, DECO)
		end
		if f < storeys then
			-- stair from this landing up to the next, along the wall (scaled to the 9-stud storey)
			local s = 9 / 11.61
			local st = template("FireEscapeStair")
			if st then
				local p = st:Clone()
				p.Name = "Prop_FireEscapeStair"
				p.Size = st.Size * s
				local bx0, by0, bz0 = cx - 4, y + 0.3, zb - 1.3
				-- the bottom end sits 5.804 below / 3.926 behind the mesh centre (README, GLB axes); climbs toward +X here
				p.CFrame = CFrame.new(bx0 + 3.926 * s, by0 + 5.804 * s, bz0) * CFrame.Angles(0, facing(1, 0), 0)
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.Parent = m
			end
		end
	end
	-- drop ladder, raised: two rails + rungs at the lowest landing's east end, bottom ~8 studs up
	local yl = 12.7
	for _, lx in ipairs({ cx + 3.8, cx + 5.2 }) do
		box(m, "LadderRail", lx - 0.1, yl - 4.6, zb - 2.85, lx + 0.1, yl + 4, zb - 2.65, IRON, M.metal, DECO)
	end
	box(m, "LadderRungs", cx + 3.9, yl - 4.4, zb - 2.8, cx + 5.1, yl + 3.8, zb - 2.7, IRON, M.metal, { collide = false, transparency = 0.5 })
	marker(m, "FireEscapeStairSpot", Vector3.new(cx - 4, 13, zb - 1.3), Vector3.new(1, 0, 0))
end

-- [A5] front-load dumpster in the alley behind the shops: body, two plastic lids, fork pockets, dark base
local function dumpster(parent: Instance, x: number, z0: number, col: Color3)
	local m = Kit.model(parent, "Dumpster")
	box(m, "Base", x - 3, 0, z0, x + 3, 0.7, z0 - 3.6, C.rubber, M.smooth)
	box(m, "Body", x - 3, 0.7, z0, x + 3, 4.2, z0 - 3.6, col, M.metal)
	for _, lx in ipairs({ x - 1.55, x + 1.55 }) do
		Kit.part(m, "Lid", Vector3.new(3, 0.5, 3.9), CFrame.new(lx, 4.45, z0 - 1.8) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(44, 46, 52), M.smooth, DECO)
	end
	for _, sx in ipairs({ x - 3.25, x + 3 }) do
		box(m, "ForkPocket", sx, 2.4, z0 - 2.9, sx + 0.25, 3.1, z0 - 0.7, Color3.fromRGB(60, 62, 68), M.metal, DECO)
	end
end

-- [B2] used tyres at a small garage: a lying stack (0.88 scale) and its blue tarp
local function tireStack(parent: Instance, x: number, z: number, n: number, tarp: boolean)
	local m = Kit.model(parent, "TireStack")
	local h = 1.18 * TIRE_SCALE
	for k = 0, n - 1 do
		Props.mesh(m, "Tire", x, 0.5 + k * h, z, k * 0.7, true, TIRE_SCALE)
	end
	if tarp then
		box(m, "Tarp", x - 1.5, 0.5 + n * h, z - 1.5, x + 1.5, 0.62 + n * h, z + 1.5, Color3.fromRGB(46, 96, 170), M.fabric, DECO)
		box(m, "TarpDrape", x - 1.5, 0.5 + (n - 1) * h, z + 1.38, x + 1.5, 0.5 + n * h, z + 1.5, Color3.fromRGB(46, 96, 170), M.fabric, DECO)
	end
	return m
end

-- [B2] a tyre standing on its tread against the wall (front wall at zf facing +Z)
local function tireLeaning(parent: Instance, x: number, zf: number)
	local t = template("Tire")
	if not t then
		return
	end
	local p = t:Clone()
	p.Name = "Prop_Tire"
	p.Size = t.Size * TIRE_SCALE
	p.CFrame = CFrame.new(x, 0.5 + p.Size.X / 2, zf + p.Size.Y / 2 + 0.05) * CFrame.Angles(math.rad(90), 0, 0)
	p.Anchored = true
	p.CanCollide = true
	p.CanTouch = false
	p.Parent = parent
end

-- the part-built tyres (Placeholder3D = "Tire" cylinders: Bay 1's rack, bay stacks, the display rack, junkyard
-- piles) become the 3D tyre in the same place, as wide across (one mesh for all = cheap). Left as cylinders if the
-- mesh can't load. Before Upgrades.tagHomes (Build), so the bays' tyres still hide / show with their level.
function Props.swapTires(root: Instance)
	local t = template("Tire")
	if not t then
		return
	end
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("BasePart") and d:GetAttribute("Placeholder3D") == "Tire" then
			local p = t:Clone()
			p.Name = d.Name
			p.Size = t.Size * (math.max(d.Size.Y, d.Size.Z) / t.Size.X)
			p.CFrame = d.CFrame * CFrame.Angles(0, 0, -math.pi / 2) -- a cylinder's axis is X, the mesh's is Y
			p.Anchored = true
			p.CanCollide = d.CanCollide
			p.CanQuery = d.CanQuery
			p.CanTouch = false
			p.CastShadow = d.CastShadow
			p.Parent = d.Parent
			d:Destroy()
		end
	end
end

-- [50/51] tall gas tank (27 studs), calm colours: shell, two bands, a top cap, a side pipe
local function gasTank(parent: Instance, x: number, z: number, col: Color3)
	local m = Kit.model(parent, "GasTank")
	Kit.post(m, "Shell", x, z, 0, 27, 9, col, M.metal)
	for _, y in ipairs({ 8, 18 }) do
		Kit.post(m, "Band", x, z, y, y + 0.8, 9.4, Color3.fromRGB(210, 210, 204), M.metal, DECO)
	end
	Kit.post(m, "Cap", x, z, 27, 28, 6, Color3.fromRGB(96, 100, 104), M.metal)
	box(m, "Pipe", x + 4.4, 2, z - 0.4, x + 5.6, 14, z + 0.4, Color3.fromRGB(120, 124, 128), M.metal)
end

-- [A1][A2][A4][A5][B1][B2][B3]
function Props.build(garage: Model)
	local town = garage:FindFirstChild("Town") or Kit.folder(garage, "Town")
	local sp = Kit.folder(town, "StreetProps")
	-- avenue work zone in the westbound curb lane, in MUTCD order for the coming (westbound, -X) traffic:
	-- warning sign -> taper of cones out to the lane line -> buffer -> drums along the work space -> short end taper
	workAheadSign(sp, 6, -127.4)
	for k = 0, 4 do
		local t = k / 4
		Props.mesh(sp, "Cone", -24 - 16 * t, 0, -124.6 + 8.2 * t, 0, false)
	end
	for _, x in ipairs({ -46, -53, -60, -67, -74 }) do
		drum(sp, x, -116.6)
	end
	box(sp, "SteelPlate", -64, 0, -124, -56, 0.08, -119, Color3.fromRGB(92, 96, 100), M.diamond, DECO)
	barrier(sp, -68, -64.5, -121.5)
	barrier(sp, -55.5, -52, -121.5)
	Props.mesh(sp, "Cone", -77.5, 0, -118.6, 0, false)
	Props.mesh(sp, "Cone", -80, 0, -122.6, 0, false)
	-- parking: a pay kiosk + zone sign per stretch, stall end marks round each parked car
	kiosk(sp, -100, -127.4)
	zoneSign(sp, -108, -127.6, "7")
	kiosk(sp, 100, -127.4)
	zoneSign(sp, 108, -127.6, "8")
	for _, cx in ipairs({ -214, -88, 56, 128 }) do
		for _, s in ipairs({ -1, 1 }) do
			box(sp, "StallMark", cx + s * 12 - 0.2, 0, -126, cx + s * 12 + 0.2, 0.05, -124.2, C.lineWhite, M.smooth, DECO)
		end
	end
	-- hydrants: one near each end of the shop row and one mid-block; light-blue caps on the avenue's big main
	hydrant(sp, "Hydrant_Blue", 180, -125.5, 1)
	hydrant(sp, "Hydrant_Blue", -38, -125.5, 1)
	hydrant(sp, "Hydrant_Blue", -268, -125.5, 1)
	-- collection box at the commercial corner, near the curb, slot toward the sidewalk
	Props.mesh(sp, "Mailbox", 188, 0.5, -127.9, facing(0, -1), true)
	-- guard posts: both ends of the pump island, beside each roll-up garage door
	bollard(sp, 235.4, -140.75, 0)
	bollard(sp, 264.6, -140.75, 0)
	for _, x0 in ipairs({ 62, -176 }) do
		for _, bx in ipairs({ x0 + 1.4, x0 + 11.75, x0 + 22.1 }) do
			bollard(sp, bx, -133.2, 0.5)
		end
	end
	-- used tyres at the two small garages (by their pole signs), gas cans at SAM'S
	tireStack(sp, 90.5 - 1.9, -132.4, 4, true)
	Props.mesh(sp, "GasCan", 90.5 - 4.6, 0.5, -133.5, facing(0, 1), false)
	tireStack(sp, -147.5 - 1.9, -132.4, 3, false)
	tireLeaning(sp, -147.5 - 4.3, -134)
	-- back of the shop row (alley): fire escapes on the three-storey blocks, dumpsters (one colour each, not under
	-- the fire escapes), a couple of overflow bags (Detroit bags go inside the bin: only by one)
	for _, cx in ipairs({ -188, -113, 25, 125 }) do
		fireEscape(sp, cx, -162, 3)
	end
	local bins = { Color3.fromRGB(54, 96, 150), Color3.fromRGB(58, 118, 80), Color3.fromRGB(40, 84, 64) }
	for i, x in ipairs({ -232, -150, -64, 70, 170 }) do
		dumpster(sp, x, -162.2, bins[i % #bins + 1])
	end
	Props.mesh(sp, "Trashbag", -59.6, 0, -163.2, 0.4, false)
	Props.mesh(sp, "Trashbag", -59.9, 0, -164.8, 2.1, false)
	-- park: old-style lamps, slatted bins by the benches
	for _, p in ipairs({ { 240, -250 }, { 300, -200 }, { 360, -248 }, { 430, -196 } }) do
		Props.oldLamp(sp, p[1], p[2], 0)
	end
	for i, bx in ipairs({ 250, 320, 400 }) do
		Props.mesh(sp, if i == 2 then "ParkBin_2" else "ParkBin_1", bx + 4.4, 0.15, -251.7, 0, true)
	end
	-- the Old Works: two tall gas tanks, a steel fence along Chassis Street
	gasTank(sp, 404, 320, Color3.fromRGB(128, 140, 136))
	gasTank(sp, 428, 320, Color3.fromRGB(168, 96, 84))
	for z = 26, 186, 20 do
		Kit.post(sp, "FencePost", 236.5, z, 0, 6, 0.4, IRON, M.metal)
	end
	box(sp, "FenceRail", 236.3, 5.4, 26, 236.7, 5.7, 186, IRON, M.metal)
	box(sp, "FenceMesh", 236.45, 0.2, 26, 236.55, 5.4, 186, Color3.fromRGB(150, 156, 160), M.metal, { transparency = 0.5 })
end

-- [B3 3-4] neighbourhood lamp (Maple Row): grey pole, arm over the street, cobra-head with its lens underneath —
-- at every corner and mid-block; street = +1 / -1 (the side of the pole the street is on, along Z)
function Props.cobraLamp(parent: Instance, x: number, z: number, street: number)
	local m = Kit.model(parent, "StreetLamp")
	local head = Color3.fromRGB(196, 200, 204)
	Kit.post(m, "Pole", x, z, 0.5, 14, 0.5, Color3.fromRGB(150, 154, 160), M.metal, DECO) -- thin: pathfinding misses it, walkers snagged (QA 10-21)
	box(m, "Arm", x - 0.12, 13.6, math.min(z, z + street * 4), x + 0.12, 13.85, math.max(z, z + street * 4), Color3.fromRGB(150, 154, 160), M.metal, DECO)
	box(m, "Head", x - 0.55, 13.4, math.min(z + street * 3.3, z + street * 5.3), x + 0.55, 14, math.max(z + street * 3.3, z + street * 5.3), head, M.metal, DECO)
	box(m, "Lens", x - 0.4, 13.35, math.min(z + street * 3.5, z + street * 5.1), x + 0.4, 13.4, math.max(z + street * 3.5, z + street * 5.1), GLOBE, M.neon, DECO)
	return m
end

-- for other districts' builders (same rules)
Props.hydrant = hydrant
Props.facing = facing

return Props
