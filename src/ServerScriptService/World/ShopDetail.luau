--!strict
-- World/ShopDetail: dressing on the Lv1 shop (style_B: clean, bright US neighbourhood garage, casual).
-- Only looks: nothing here is in the contract, so it can change freely. Depth: wainscot, trims, plates;
-- props in small groups along the walls (the middle of the bay stays clear for the car and players).

local Kit = require(script.Parent.Kit)
local C, M = Kit.C, Kit.M
local box = Kit.box

local ShopDetail = {}

local F = 0.2
local OUTLINE = Color3.fromRGB(28, 30, 40)

local function wrench(parent: Instance, x: number, y: number, z: number, len: number)
	-- hanging on a board whose face is at z (tool sticks out toward -Z)
	box(parent, "WrenchShaft", x - 0.12, y - len / 2, z - 0.15, x + 0.12, y + len / 2, z, C.steel, M.metal, { collide = false, shadow = false })
	box(parent, "WrenchHead", x - 0.3, y + len / 2 - 0.1, z - 0.15, x + 0.3, y + len / 2 + 0.35, z, C.steel, M.metal, { collide = false, shadow = false })
	box(parent, "WrenchRing", x - 0.26, y - len / 2 - 0.4, z - 0.15, x + 0.26, y - len / 2 + 0.05, z, C.steel, M.metal, { collide = false, shadow = false })
end

local function screwdriver(parent: Instance, x: number, y: number, z: number, handle: Color3)
	box(parent, "DriverHandle", x - 0.17, y, z - 0.3, x + 0.17, y + 0.9, z, handle, M.smooth, { collide = false, shadow = false })
	box(parent, "DriverShaft", x - 0.05, y - 1.1, z - 0.2, x + 0.05, y, z - 0.1, C.steel, M.metal, { collide = false, shadow = false })
end

local function bayInside(garage: Model)
	local d = Kit.folder(garage, "Dressing")
	-- wainscot (lower wall paint band) on the bay's inner faces, with a thin blue stripe on top
	local W = C.wainscot
	local function band(x0: number, z0: number, x1: number, z1: number)
		box(d, "Wainscot", x0, F, z0, x1, 3.0, z1, W, M.smooth)
		local sx0, sz0, sx1, sz1 = x0, z0, x1, z1
		box(d, "WainscotStripe", sx0, 3.0, sz0, sx1, 3.3, sz1, C.blue, M.smooth)
	end
	band(-13, -19, -12.9, 19 - 0.0) -- west wall (inner face x -13)
	band(-13, 18.9, -3.4, 19) -- back wall, left of the back door
	band(0.6, 18.9, 14, 19) -- back wall, right of the back door
	band(13.9, -19, 14, -5) -- bay | office wall, front part (left of the bay door)
	band(13.9, 1, 14, 6)
	band(13.9, 14, 14, 18.9)
	band(-13, -19, -8, -18.9) -- front wall inner faces
	band(8, -19, 14, -18.9)

	-- pegboard tools over the workbench (board face at z 18.8)
	local pz = 18.8
	local lens = { 2.4, 2.1, 1.9, 1.7, 1.5 }
	for i, len in ipairs(lens) do
		wrench(d, 2.2 + i * 0.9, 9.0, pz, len)
	end
	local handles = { C.red, C.red, C.yellow, C.red, C.blue }
	for i, h in ipairs(handles) do
		screwdriver(d, 7.6 + i * 0.7, 8.6, pz, h)
	end
	box(d, "HammerHead", 11.4, 9.6, pz - 0.4, 12.6, 10.1, pz, C.metalDark, M.metal, { collide = false })
	box(d, "HammerHandle", 11.85, 7.2, pz - 0.3, 12.15, 9.6, pz, C.wood, M.wood, { collide = false })
	-- bench top: a small parts tray + oil can, two spray cans in the back corner (they were on a pegboard shelf at
	-- eye height, where the camera backs onto the board: test 2 TOP10)
	box(d, "PartsTray", 3, 3.4, 17, 5.4, 3.7, 18.4, C.blue, M.metal)
	Kit.post(d, "OilCan", 8.4, 17.6, 3.4, 4.6, 0.8, C.yellow, M.metal)
	for i, col in ipairs({ C.red, C.blue }) do
		Kit.post(d, "SprayCan", 1.5 + i * 0.6, 18.4 - (i - 1) * 0.15, 3.4, 4.6, 0.6, col, M.smooth, { shadow = false })
	end

	-- tool chest: silver handles on every drawer line
	for i = 0, 3 do
		box(d, "ChestHandle", -9.4, 1.0 + i * 0.8, 16.35, -5.6, 1.2 + i * 0.8, 16.5, C.steel, M.metal, { collide = false })
	end
	box(d, "ChestHandle", -9.4, 5.8, 17.45, -5.6, 6.0, 17.6, C.steel, M.metal, { collide = false })


	-- electrical panel + conduit on the back wall, wall clock
	box(d, "ElectricPanel", -2.6, 12, 18.4, 0, 15.2, 19, C.steel, M.metal)
	box(d, "PanelDoorLine", -2.4, 12.2, 18.35, -0.2, 12.3, 18.4, C.metalDark, M.smooth, { collide = false })
	box(d, "Conduit", -1.5, 15.2, 18.6, -1.1, 20, 19, C.steel, M.metal)
	box(d, "ExitSign", -2.2, 9.0, 18.7, -0.6, 9.8, 19, Color3.fromRGB(40, 180, 90), M.neon) -- solid: the camera stops in front
	Kit.part(d, "Clock", Vector3.new(0.3, 2.4, 2.4), CFrame.new(6, 14.5, 18.75) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(250, 250, 248), M.smooth, { shape = "cyl" })
	Kit.part(d, "ClockRim", Vector3.new(0.2, 2.7, 2.7), CFrame.new(6, 14.5, 18.9) * CFrame.Angles(0, math.rad(90), 0), C.rubber, M.smooth, { shape = "cyl" })
	box(d, "ClockHand", 5.95, 14.5, 18.55, 6.05, 15.4, 18.6, C.rubber, M.smooth, { collide = false })
	box(d, "ClockHand", 6, 14.45, 18.55, 6.7, 14.55, 18.6, C.rubber, M.smooth, { collide = false })

	-- safety poster on the west wall (faces +X)
	local poster = box(d, "Poster", -12.95, 7, -14, -12.85, 11, -9, C.yellow, M.smooth)
	Kit.label(poster, Enum.NormalId.Right, "SAFETY\nFIRST", Color3.fromRGB(30, 30, 36), nil)

	-- air compressor: outside by the back door (the front-right corner is the wheel balancer's place)
	local comp = Kit.model(d, "AirCompressor")
	Kit.part(comp, "Tank", Vector3.new(3.6, 2.2, 2.2), CFrame.new(5.8, 0 + 1.6, 21.6), C.red, M.smooth, { shape = "cyl" })
	box(comp, "Motor", 5, 2.7, 20.9, 6.6, 3.7, 22.3, C.metalDark, M.metal)
	box(comp, "Feet", 4.2, 0, 21, 7.4, 0.5, 22.2, C.rubber, M.smooth)
	box(comp, "Gauge", 6.7, 2.9, 21.4, 6.9, 3.4, 21.9, C.steel, M.metal)

	-- bay ceiling lights get a glowing strip (real light comes from World/Lights)
	for _, lx in ipairs({ -6, 6 }) do
		box(d, "LightTube", lx - 0.4, 18.3, -13.6, lx + 0.4, 18.4, 13.6, Color3.fromRGB(255, 252, 240), M.neon, { collide = false, shadow = false })
	end
end

local function waitingInside(garage: Model)
	local d = garage:FindFirstChild("Dressing") :: Folder
	-- rug, coffee corner, TV, posters
	box(d, "Rug", 25.5, F + 0.05, -16, 31.1, F + 0.08, -7.6, Color3.fromRGB(70, 96, 150), M.fabric, { collide = false })
	-- coffee station (v35, wr-play eval 10-23 TOP 5: the maker stood by the bay door across the room from the seats,
	-- and its prompt reached through the wall into the bay): a waist-high cabinet at the north end of the seat row, as
	-- real shop waiting rooms have it (notes/playtest/wr-builder/interior/fix11/ref) — a black drip maker + glass pot,
	-- stacks of paper cups, a sugar caddy, a FREE COFFEE card. CoffeeMaker keeps its name (Places.coffeeMaker)
	local SMALL = { collide = false, shadow = false }
	local CUP = Color3.fromRGB(250, 250, 248)
	box(d, "CoffeeCounter", 34.4, F, -6.0, 36.95, 3.0, -2.8, C.wood, M.wood)
	box(d, "CoffeeTop", 34.3, 3.0, -6.05, 36.95, 3.2, -2.75, C.metalDark, M.smooth)
	box(d, "CoffeeMaker", 35.7, 3.2, -5.7, 36.9, 5.0, -4.4, C.rubber, M.smooth)
	box(d, "CoffeeHead", 35.05, 4.4, -5.55, 35.7, 4.95, -4.55, C.rubber, M.smooth, SMALL) -- the brew head over the pot
	box(d, "CoffeePlate", 34.95, 3.2, -5.6, 35.7, 3.3, -4.5, Color3.fromRGB(70, 72, 76), M.metal, SMALL)
	box(d, "CoffeePot", 35.05, 3.3, -5.4, 35.6, 4.3, -4.7, C.glass, M.glass, { transparency = 0.35, collide = false, shadow = false })
	box(d, "CoffeeIn", 35.1, 3.32, -5.35, 35.55, 3.85, -4.75, Color3.fromRGB(74, 46, 30), M.smooth, SMALL)
	box(d, "PotHandle", 35.25, 3.6, -4.7, 35.4, 4.1, -4.5, C.rubber, M.smooth, SMALL)
	-- paper cups: a tall stack + a short one + one set out (the cue for "pour a cup here")
	Kit.post(d, "CupStack", 35.0, -3.75, 3.2, 4.7, 0.5, CUP, M.smooth, SMALL)
	Kit.post(d, "CupStack", 35.6, -3.6, 3.2, 4.15, 0.5, CUP, M.smooth, SMALL)
	Kit.post(d, "Cup", 34.75, -4.3, 3.2, 3.75, 0.48, CUP, M.smooth, SMALL)
	Kit.post(d, "CupCoffee", 34.75, -4.3, 3.75, 3.77, 0.4, Color3.fromRGB(74, 46, 30), M.smooth, SMALL) -- one poured, waiting
	for _, ry in ipairs({ 3.75, 4.25 }) do -- the stacked cups' lips (a coloured band read as a jar)
		Kit.post(d, "CupLip", 35.0, -3.75, ry, ry + 0.04, 0.54, Color3.fromRGB(214, 214, 210), M.smooth, SMALL)
	end
	box(d, "SugarCaddy", 36.0, 3.2, -3.85, 36.8, 3.55, -3.05, C.red, M.smooth, SMALL)
	box(d, "SugarPackets", 36.1, 3.55, -3.75, 36.7, 3.7, -3.15, CUP, M.smooth, SMALL)
	-- (over the cups, under the OIL CHANGE poster's bottom at 6: in view above the maker from the seats)
	local cs = box(d, "CoffeeSign", 36.88, 5.15, -4.3, 36.95, 5.9, -2.75, Color3.fromRGB(246, 238, 220), M.smooth, SMALL)
	Kit.label(cs, Enum.NormalId.Left, "FREE COFFEE", Color3.fromRGB(96, 56, 34))
	box(d, "TV", 16.5, 7, 1.7, 22, 10.2, 2, C.rubber, M.smooth)
	box(d, "TVScreen", 16.8, 7.3, 1.65, 21.7, 9.9, 1.7, Color3.fromRGB(60, 120, 170), M.neon, { collide = false }).Transparency = 0.35
	local p1 = box(d, "Poster", 36.85, 6, -5, 36.95, 9.6, -2, C.blue, M.smooth)
	Kit.label(p1, Enum.NormalId.Left, "OIL\nCHANGE\n$29", Color3.new(1, 1, 1), OUTLINE)
	local p2 = box(d, "Poster", 15.05, 4.4, -18.6, 15.15, 8.4, -16.4, C.red, M.smooth)
	Kit.label(p2, Enum.NormalId.Right, "TIRES\nBRAKES\nBATTERIES", Color3.new(1, 1, 1), OUTLINE)
	-- office ceiling light panels glow
	for _, cz in ipairs({ -12, 10 }) do
		box(d, "PanelGlow", 22.2, 11.85, cz - 1.3, 29.8, 11.9, cz + 1.3, Color3.fromRGB(255, 252, 240), M.neon, { collide = false, shadow = false })
	end
	-- OPEN sign behind the storefront glass
	local open = box(d, "OpenSign", 24, 8.2, -19.2, 28.6, 10, -19.1, Color3.fromRGB(30, 30, 36), M.smooth, { collide = false })
	Kit.label(open, Enum.NormalId.Front, "OPEN", Color3.fromRGB(255, 70, 60), Color3.fromRGB(255, 200, 190))
end

local function outside(garage: Model)
	local d = garage:FindFirstChild("Dressing") :: Folder
	local shell = garage:FindFirstChild("Building") :: Folder
	-- main sign text
	local sign = shell:FindFirstChild("SignBoard") :: BasePart
	if sign then
		Kit.label(sign, Enum.NormalId.Front, "WRENCH & RIDE", Color3.new(1, 1, 1), OUTLINE)
	end
	-- plate over the bay door
	local plate = box(d, "BayPlate", -7, 16.4, -20.3, 7, 18.4, -20, Color3.fromRGB(250, 250, 246), M.smooth)
	Kit.label(plate, Enum.NormalId.Front, "AUTO REPAIR", C.red, OUTLINE)
	box(d, "BayPlateTrim", -7.2, 16.2, -20.4, 7.2, 16.4, -20, C.trim, M.smooth)
	box(d, "BayPlateTrim", -7.2, 18.4, -20.4, 7.2, 18.6, -20, C.trim, M.smooth)
	-- OFFICE over the customer door (on the awning edge)
	local off = box(d, "OfficePlate", 29.4, 12.9, -24.3, 34.6, 14.3, -24, Color3.fromRGB(250, 250, 246), M.smooth)
	Kit.label(off, Enum.NormalId.Front, "OFFICE", C.blue, nil)
	-- gooseneck lamps over the main sign
	for _, lx in ipairs({ 0, 12, 24 }) do
		box(d, "LampArm", lx - 0.15, 24.4, -20.8, lx + 0.15, 25.6, -20.5, C.trim, M.metal)
		box(d, "LampArm", lx - 0.15, 25.4, -22.2, lx + 0.15, 25.7, -20.5, C.trim, M.metal)
		box(d, "LampShade", lx - 0.7, 25, -22.8, lx + 0.7, 25.7, -21.6, C.trim, M.metal)
	end
	-- bollard caps (round tops: casual)
	for _, bx in ipairs({ -10, 10 }) do
		Kit.part(d, "BollardCap", Vector3.new(1, 1, 1), CFrame.new(bx, 4.4, -21.6), C.yellow, M.metal, { shape = "ball" })
	end
	-- planter with bushes under the storefront
	box(d, "Planter", 15, 0.2, -22, 28.6, 1.6, -20.2, C.plinth, M.concrete)
	box(d, "PlanterSoil", 15.3, 1.6, -21.7, 28.3, 1.7, -20.5, Color3.fromRGB(90, 66, 48), M.smooth, { collide = false })
	local r = Kit.rng(57)
	for bx = 16.5, 27.5, 2.75 do
		local s = 2.2 + r() * 0.8
		Kit.part(d, "Bush", Vector3.new(s, s * 0.9, s), CFrame.new(bx + (r() - 0.5) * 0.6, 2.4, -21.1), r() > 0.5 and Color3.fromRGB(86, 150, 70) or Color3.fromRGB(104, 166, 78), M.grass, { shape = "ball" })
	end
	-- down pipes at the front corners, roof AC units
	for _, px in ipairs({ -14.9, 38.9 }) do
		box(d, "DownPipe", px - 0.3, 0.2, -19.4, px + 0.3, 21, -18.8, C.trim, M.metal)
	end
	for i, ax in ipairs({ -4, 22 }) do
		local ac = Kit.model(d, "RoofAC")
		box(ac, "Body", ax - 3, 21, 4 + i * 2, ax + 3, 24, 10 + i * 2, C.steel, M.metal)
		Kit.part(ac, "Fan", Vector3.new(0.2, 4, 4), CFrame.new(ax, 24.1, 7 + i * 2) * CFrame.Angles(0, 0, math.rad(90)), C.metalDark, M.metal, { shape = "cyl" })
	end
	-- dumpster behind the shop (clear of the back-lane route)
	local dump = Kit.model(d, "Dumpster")
	box(dump, "Bin", 28, 0, 21, 35, 4.2, 24.4, Color3.fromRGB(40, 110, 70), M.metal)
	box(dump, "Lid", 27.8, 4.2, 20.8, 35.2, 4.6, 24.6, Color3.fromRGB(30, 84, 54), M.metal)
	-- customer parking sign at the lot front corner
	Kit.post(d, "SignPost", 38, -64, 0, 7, 0.3, C.trim, M.metal)
	local ps = box(d, "ParkingSign", 36.4, 5, -64.2, 39.6, 7.6, -64.0, Color3.fromRGB(250, 250, 246), M.smooth)
	Kit.label(ps, Enum.NormalId.Front, "CUSTOMER\nPARKING", C.blue, nil)
	-- tire display rack outside the bay pier (a little shop life)
	local tr = Kit.model(d, "TireDisplay")
	box(tr, "Frame", 9.4, 0.05, -27, 13, 0.4, -24.2, C.rubber, M.metal)
	for k = 0, 2 do
		Kit.part(tr, "Tire", Vector3.new(1.2, 3, 3), CFrame.new(10 + k * 1.3, 1.9, -25.6), C.rubber, M.plastic, { shape = "cyl" }):SetAttribute("Placeholder3D", "Tire")
	end
end

function ShopDetail.build(garage: Model)
	bayInside(garage)
	waitingInside(garage)
	outside(garage)
end

return ShopDetail
