--!strict
-- World/FlipPlaces (wr-builder): loop B places (docs/design/flip_loop.md) — Restoration Bay (Lv8 buy), Paint Booth
-- (Lv16 buy), Used-car Showroom (Lv9 free: spot 1, Lv12: spots 2-3, Lv16: spots 4-6). Each is built in its
-- "Owned" look plus a "Locked" look (bare pad + sign); World/Upgrades shows one. Photos: notes/research/ref_showroom_paint.
-- Names: docs/specs/world_contract.md (★ 루프 B 장소).

local Kit = require(script.Parent.Kit)
local Equipment = require(script.Parent.Equipment)
local Props = require(script.Parent.Props)
local C, M = Kit.C, Kit.M
local box, marker, rod = Kit.box, Kit.marker, Kit.rod

local FlipPlaces = {}

local F = 0.2
local OUTLINE = Color3.fromRGB(28, 30, 40)

local function tag(inst: Instance, id: string, state: string, lv: number?)
	inst:SetAttribute("UpgradeId", id)
	inst:SetAttribute("UpgradeState", state)
	if lv then
		inst:SetAttribute("UnlockLevel", lv)
	end
end

local function light(part: BasePart, brightness: number, range: number)
	local l = Instance.new("SurfaceLight")
	l.Name = "Light"
	l.Face = Enum.NormalId.Bottom
	l.Brightness = brightness
	l.Range = range
	l.Angle = 110
	l.Color = Color3.fromRGB(255, 246, 228)
	l.Shadows = false
	l.Parent = part
end

-- "before" look: bare concrete pad, chain posts along the front, a COMING SOON sign
local function lockedPad(garage: Instance, name: string, id: string, lv: number, x0: number, z0: number, x1: number, z1: number, text: string)
	local spots = garage:FindFirstChild("UpgradeSpots") or Kit.folder(garage, "UpgradeSpots")
	local lk = Kit.model(spots, name)
	tag(lk, id, "Locked", lv)
	box(lk, "Pad", x0, -1, z0, x1, 0.1, z1, C.concrete, M.concrete)
	for x = x0 + 1, x1 - 1, 6.5 do
		Kit.post(lk, "ChainPost", x, z0 - 0.6, 0.1, 3.2, 0.5, C.yellow, M.metal)
	end
	box(lk, "Chain", x0 + 1, 2.4, z0 - 0.65, x1 - 1, 2.5, z0 - 0.55, C.metalDark, M.metal, { collide = false })
	local cx = (x0 + x1) / 2
	Kit.post(lk, "SignPost", cx - 3.4, z0 + 2, 0.1, 9, 0.4, C.trim, M.metal)
	Kit.post(lk, "SignPost", cx + 3.4, z0 + 2, 0.1, 9, 0.4, C.trim, M.metal)
	local sg = box(lk, "Sign", cx - 4.6, 5.6, z0 + 1.8, cx + 4.6, 8.8, z0 + 2.2, Color3.fromRGB(250, 248, 240), M.smooth)
	Kit.label(sg, Enum.NormalId.Front, text .. "\nCOMING SOON", C.blue, nil)
	for i = 0, 1 do
		Kit.part(lk, "Cone", Vector3.new(1.2, 1.8, 1.2), CFrame.new(x0 + 4 + i * (x1 - x0 - 8), 1.0, z0 + 3), Color3.fromRGB(240, 120, 30), M.smooth)
	end
	return lk
end

-- a work bay shell in the shop's language, door on the -Z side (centre cx, 16 wide), height H
local function bayShell(m: Instance, X0: number, X1: number, Z0: number, Z1: number, plateText: string)
	local H = 20
	local cx = (X0 + X1) / 2
	local sh = Kit.folder(m, "Shell")
	box(sh, "FloorSlab", X0, -1, Z0, X1, F, Z1, C.floor, M.smooth).Reflectance = 0.04
	box(sh, "BackWall", X0, F, Z1 - 1, X1, H, Z1, C.wall, M.smooth)
	box(sh, "WestWall", X0, F, Z0 + 1, X0 + 1, H, Z1 - 1, C.wall, M.smooth)
	box(sh, "EastWall", X1 - 1, F, Z0 + 1, X1, H, Z1 - 1, C.wall, M.smooth)
	box(sh, "FrontWall", X0, F, Z0, cx - 8, H, Z0 + 1, C.wall, M.smooth)
	box(sh, "FrontWall", cx + 8, F, Z0, X1, H, Z0 + 1, C.wall, M.smooth)
	box(sh, "Header", cx - 8, 14, Z0, cx + 8, H, Z0 + 1, C.wall, M.smooth)
	box(sh, "Roof", X0 - 0.5, H, Z0 - 0.5, X1 + 0.5, H + 1, Z1 + 0.5, C.roof, M.concrete)
	box(sh, "ParapetFront", X0 - 0.5, H + 1, Z0 - 0.5, X1 + 0.5, H + 3.4, Z0 + 0.5, C.wall, M.smooth)
	box(sh, "Coping", X0 - 0.8, H + 3.4, Z0 - 0.8, X1 + 0.8, H + 3.8, Z0 + 0.6, C.trim, M.concrete)
	box(sh, "ParapetBack", X0 - 0.5, H + 1, Z1 - 0.5, X1 + 0.5, H + 2.4, Z1 + 0.5, C.wall, M.smooth)
	box(sh, "Band", X0 - 0.2, 18.9, Z0 - 0.2, X1 + 0.2, 19.5, Z0, C.blue, M.smooth)
	box(sh, "Plinth", X0 - 0.2, 0, Z0 - 0.2, cx - 8.6, 1.2, Z0, C.plinth, M.concrete)
	box(sh, "Plinth", cx + 8.6, 0, Z0 - 0.2, X1 + 0.2, 1.2, Z0, C.plinth, M.concrete)
	box(sh, "Pilaster", X0 - 0.4, 0, Z0 - 0.4, X0 + 1, H, Z0, C.wall, M.smooth)
	box(sh, "Pilaster", X1 - 1, 0, Z0 - 0.4, X1 + 0.4, H, Z0, C.wall, M.smooth)
	local plate = box(sh, "Plate", cx - 8, 16.4, Z0 - 0.3, cx + 8, 18.4, Z0, Color3.fromRGB(250, 250, 246), M.smooth)
	Kit.label(plate, Enum.NormalId.Front, plateText, C.red, OUTLINE)
	for _, bx in ipairs({ cx - 10, cx + 10 }) do
		Kit.post(sh, "Bollard", bx, Z0 - 1.6, 0, 4.4, 1, C.yellow, M.metal)
		Kit.part(sh, "BollardCap", Vector3.new(1, 1, 1), CFrame.new(bx, 4.4, Z0 - 1.6), C.yellow, M.metal, { shape = "ball" })
	end
	-- inside
	local function band(x0: number, z0: number, x1: number, z1: number)
		box(sh, "Wainscot", x0, F, z0, x1, 3.0, z1, C.wainscot, M.smooth)
		box(sh, "WainscotStripe", x0, 3.0, z0, x1, 3.3, z1, C.blue, M.smooth)
	end
	band(X0 + 1, Z0 + 1, X0 + 1.1, Z1 - 1)
	band(X1 - 1.1, Z0 + 1, X1 - 1, Z1 - 1)
	band(X0 + 1, Z1 - 1.1, X1 - 1, Z1 - 1)
	for _, bz in ipairs({ Z0 + 8, Z0 + 18, Z0 + 28 }) do
		box(sh, "RoofBeam", X0 + 1, H - 1.2, bz - 0.4, X1 - 1, H, bz + 0.4, C.beam, M.metal)
	end
	for _, lx in ipairs({ cx - 6, cx + 6 }) do
		box(sh, "LightFixture", lx - 0.6, H - 1.6, Z0 + 6, lx + 0.6, H - 1.2, Z1 - 6, C.lineWhite, M.smooth)
		light(box(sh, "LightTube", lx - 0.4, 18.3, Z0 + 6.4, lx + 0.4, 18.4, Z1 - 6.4, Color3.fromRGB(255, 252, 240), M.neon, { collide = false, shadow = false }), if X1 - X0 < 26 then 0.95 else 0.6, 20)
	end
	box(sh, "BayLine", X0 + 1.4, F, Z0 + 1, X0 + 1.8, F + 0.05, Z1 - 2, C.lineYellow, M.smooth, { collide = false })
	box(sh, "BayLine", X1 - 1.8, F, Z0 + 1, X1 - 1.4, F + 0.05, Z1 - 2, C.lineYellow, M.smooth, { collide = false })
	-- shutter (same rules as the bays)
	local shutter = box(m, "Shutter", cx - 8, 13.4, Z0 + 0.1, cx + 8, 14, Z0 + 0.5, C.shutter, M.metal)
	shutter:SetAttribute("TopY", 14)
	shutter:SetAttribute("ClosedBottomY", F)
	shutter:SetAttribute("OpenBottomY", 13.4)
	Props.shutterRibs(shutter)
	box(m, "ShutterHood", cx - 8.6, 14, Z0 - 0.8, cx + 8.6, 16, Z0, C.shutterBox, M.metal)
	box(m, "ShutterGuide", cx - 8.6, F, Z0 - 0.4, cx - 8, 14, Z0, C.shutterBox, M.metal)
	box(m, "ShutterGuide", cx + 8, F, Z0 - 0.4, cx + 8.6, 14, Z0, C.shutterBox, M.metal)
end

local function restoreBay(garage: Model)
	local X0, X1, Z0, Z1 = -14, 18, 44, 80
	local cx = (X0 + X1) / 2 -- 2
	local m = Kit.model(garage, "RestoreBay")
	tag(m, "RestorationBay", "Owned", 8)
	bayShell(m, X0, X1, Z0, Z1, "RESTORATION")
	marker(m, "CarSpot", Vector3.new(cx, F, 62), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	local ls = marker(m, "LiftSpot", Vector3.new(cx, F, 62), Vector3.new(0, 0, 1), Vector3.new(16, 0.2, 4))
	ls:SetAttribute("PostOffsetX", 6.0)
	marker(m, "ApproachSpot", Vector3.new(cx, 0, 32), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(m, "WorkArea", Vector3.new(cx, F + 9.9, 62), Vector3.new(0, 0, 1), Vector3.new(30, 19.8, 34))
	if Equipment.OLD_LIFT then
		Equipment.lift(m, "Old")
	end
	Equipment.lift(m, "Hydraulic")
	Equipment.jackKit(m, X0 + 1, cx, 62, true)
	local pr = Kit.folder(m, "Props")
	-- pressure washer cart (wash first: flip_loop 3-1) + hose reel
	local wash = Kit.model(pr, "PressureWasher")
	box(wash, "Body", 13.4, F, 47.4, 16, 3.4, 50.6, C.yellow, M.smooth)
	box(wash, "Handle", 15.6, 3.4, 47.6, 15.8, 5.6, 50.4, C.metalDark, M.metal)
	box(wash, "HandleBar", 15.6, 5.4, 47.6, 15.8, 5.6, 50.4, C.metalDark, M.metal)
	Kit.part(wash, "HoseCoil", Vector3.new(0.5, 2.0, 2.0), CFrame.new(13.2, 2.4, 49) * CFrame.Angles(0, 0, math.rad(0)), C.rubber, M.smooth, { shape = "cyl" })
	for _, wz in ipairs({ 47.8, 50.2 }) do
		Kit.part(wash, "Wheel", Vector3.new(0.4, 1.2, 1.2), CFrame.new(16.1, F + 0.6, wz), C.rubber, M.smooth, { shape = "cyl" })
	end
	marker(m, "WashPoint", Vector3.new(11.2, F, 49), Vector3.new(1, 0, 0))
	-- panels taken off restored cars, leaning on the west wall (hood, doors) in primer grey / bare metal
	local panelCols = { Color3.fromRGB(150, 152, 156), Color3.fromRGB(176, 178, 182), Color3.fromRGB(122, 124, 128) }
	for k = 0, 2 do
		Kit.part(pr, "Panel", Vector3.new(0.3, 4.2, 5.4 - k * 0.6), CFrame.new(X0 + 1.6 + k * 0.4, F + 2.1, 52 + k * 6) * CFrame.Angles(0, 0, math.rad(-10 - k * 2)),
			panelCols[k + 1], M.metal)
	end
	-- body work bench + sanders + primer cans, parts shelf on the back wall
	box(pr, "BodyBench", X1 - 4, F, 66, X1 - 1, 3.2, 76, C.metal, M.metal)
	box(pr, "BenchTop", X1 - 4.2, 3.2, 65.8, X1 - 0.9, 3.5, 76.2, C.wood, M.wood)
	for k = 0, 2 do
		Kit.post(pr, "PrimerCan", X1 - 3 + (k % 2) * 0.9, 67 + k * 1.1, 3.5, 4.7, 0.8, ({ C.red, Color3.fromRGB(150, 152, 156), C.yellow })[k + 1], M.metal)
	end
	box(pr, "Sander", X1 - 3.4, 3.5, 71, X1 - 1.8, 4.1, 72.4, C.blue, M.smooth)
	box(pr, "Hammer", X1 - 3.2, 3.5, 73.4, X1 - 1.6, 3.8, 73.8, C.metalDark, M.metal)
	for _, ux in ipairs({ X0 + 4, X0 + 9.85, X0 + 15.7 }) do
		box(pr, "ShelfUpright", ux, F, Z1 - 3.4, ux + 0.3, 10, Z1 - 1, C.blue, M.metal)
	end
	local sr = Kit.rng(812)
	for _, sy in ipairs({ 2.2, 5.2, 8.2 }) do
		box(pr, "ShelfBoard", X0 + 4, sy, Z1 - 3.4, X0 + 16, sy + 0.2, Z1 - 1, C.metalDark, M.metal)
		local x = X0 + 4.6
		while x < X0 + 15 do
			local w = 1.2 + sr() * 1.4
			box(pr, "Box", x, sy + 0.2, Z1 - 3.0, math.min(x + w, X0 + 15.6), sy + 0.2 + 0.9 + sr() * 1.2, Z1 - 1.4, ({ C.cardboard, C.blue, C.red })[math.floor(sr() * 3) + 1], M.smooth, { shadow = false })
			x += w + 0.4
		end
	end
	-- two work light stands
	for _, wl in ipairs({ { -8, 56 }, { 12, 70 } }) do
		Kit.post(pr, "LightStand", wl[1], wl[2], F, 7, 0.25, C.metalDark, M.metal)
		box(pr, "LightHead", wl[1] - 0.8, 6.6, wl[2] - 0.4, wl[1] + 0.8, 7.6, wl[2] + 0.4, C.yellow, M.smooth)
	end
	lockedPad(garage, "RestoreBay", "RestorationBay", 8, X0, Z0, X1, Z1, "RESTORATION BAY")
end

local function paintBooth(garage: Model)
	local X0, X1, Z0, Z1 = -50, -18, 44, 80
	local cx = (X0 + X1) / 2 -- -34
	local m = Kit.model(garage, "PaintBooth")
	tag(m, "PaintBooth", "Owned", 16)
	local panel = Color3.fromRGB(238, 234, 222)
	local inside = Color3.fromRGB(246, 246, 244)
	local H = 14
	local sh = Kit.folder(m, "Booth")
	-- the booth box (floor, walls with a 16-wide door opening, roof) — enclosed, white
	box(sh, "Floor", X0, -1, Z0, X1, F, Z1, Color3.fromRGB(196, 198, 200), M.smooth)
	box(sh, "Grating", cx - 4, F, Z0 + 4, cx + 4, F + 0.05, Z1 - 4, Color3.fromRGB(110, 114, 120), M.diamond, { collide = false })
	box(sh, "BackWall", X0, F, Z1 - 1, X1, H, Z1, panel, M.smooth)
	box(sh, "WestWall", X0, F, Z0, X0 + 1, H, Z1 - 1, panel, M.smooth)
	box(sh, "EastWall", X1 - 1, F, Z0, X1, H, Z1 - 1, panel, M.smooth)
	box(sh, "FrontWall", X0 + 1, F, Z0, cx - 8, H, Z0 + 1, panel, M.smooth)
	box(sh, "FrontWall", cx + 8, F, Z0, X1 - 1, H, Z0 + 1, panel, M.smooth)
	box(sh, "Header", cx - 8, 11, Z0, cx + 8, H, Z0 + 1, panel, M.smooth)
	box(sh, "Roof", X0 - 0.3, H, Z0 - 0.3, X1 + 0.3, H + 0.8, Z1 + 0.3, Color3.fromRGB(214, 210, 200), M.metal)
	-- panel seams outside (vertical lines every 4 on the sides, every 4 on the front)
	for z = Z0 + 4, Z1 - 4, 4 do
		box(sh, "Seam", X0 - 0.1, F, z - 0.1, X0, H, z + 0.1, Color3.fromRGB(200, 196, 186), M.smooth, { collide = false, shadow = false })
		box(sh, "Seam", X1, F, z - 0.1, X1 + 0.1, H, z + 0.1, Color3.fromRGB(200, 196, 186), M.smooth, { collide = false, shadow = false })
	end
	-- inside: white liner, slanted light boxes along the top of both long walls, a small inner ceiling
	box(sh, "Liner", X0 + 1, F, Z0 + 1, X0 + 1.1, 11, Z1 - 1, inside, M.smooth)
	box(sh, "Liner", X1 - 1.1, F, Z0 + 1, X1 - 1, 11, Z1 - 1, inside, M.smooth)
	box(sh, "Ceiling", X0 + 1, 12.6, Z0 + 1, X1 - 1, 13, Z1 - 1, inside, M.smooth)
	for _, side in ipairs({ -1, 1 }) do
		local wx = side < 0 and (X0 + 1) or (X1 - 1)
		for k, z in ipairs({ Z0 + 4, Z0 + 12, Z0 + 20, Z0 + 28 }) do
			local pos = Vector3.new(wx - side * 1.1, 11.6, z + 2.5)
			local lb = Kit.part(sh, "LightBox", Vector3.new(0.3, 2.4, 6), CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(side * 45)), Color3.fromRGB(255, 252, 244), M.neon, { collide = false, shadow = false })
			if k % 2 == 1 then
				local l = Instance.new("SurfaceLight")
				l.Face = side < 0 and Enum.NormalId.Right or Enum.NormalId.Left
				l.Brightness = 0.8
				l.Range = 16
				l.Angle = 120
				l.Shadows = false
				l.Parent = lb
			end
		end
	end
	box(sh, "Filter", cx - 8, 12.5, Z0 + 3, cx + 8, 12.6, Z1 - 3, Color3.fromRGB(240, 242, 244), M.smooth, { collide = false })
	box(sh, "ExhaustGrate", cx - 6, F, Z1 - 1.2, cx + 6, 4, Z1 - 1.1, C.metalDark, M.diamond, { collide = false })
	-- hose / spray gun holder on the east wall
	box(sh, "GunHolder", X1 - 1.4, 4, 58, X1 - 1.1, 6, 60, C.metalDark, M.metal)
	Kit.part(sh, "HoseReel", Vector3.new(0.4, 2.2, 2.2), CFrame.new(X1 - 1.4, 7.4, 59) * CFrame.Angles(0, 0, 0), C.blue, M.smooth, { shape = "cyl" })
	-- big front doors, round windows (photo 08), swung all the way back flat against the front wall
	-- (QA 10-21: standing out at 90 degrees their free ends snagged people walking in)
	for i, hx in ipairs({ cx - 8, cx + 8 }) do
		local s = i == 1 and -1 or 1
		local xa, xb = hx, hx + s * 8
		box(m, i == 1 and "DoorL" or "DoorR", math.min(xa, xb), F, Z0 - 0.6, math.max(xa, xb), 11, Z0 - 0.1, panel, M.smooth)
		Kit.part(m, "DoorWindow", Vector3.new(0.6, 3.2, 3.2), CFrame.new(hx + s * 4, 7, Z0 - 0.35) * CFrame.Angles(0, math.rad(90), 0), C.glass, M.glass, { shape = "cyl", transparency = 0.3, collide = false })
		box(m, "DoorHandle", hx + s * 7.2 - 0.1, 4.6, Z0 - 0.9, hx + s * 7.4 + 0.1, 5.6, Z0 - 0.6, C.metalDark, M.metal, { collide = false })
	end
	-- roof: two exhaust stacks + intake unit (photo 10)
	for _, ex in ipairs({ cx - 8, cx + 8 }) do
		Kit.post(m, "ExhaustStack", ex, Z1 - 6, H + 0.8, H + 9, 1.6, C.steel, M.metal)
		Kit.post(m, "StackCap", ex, Z1 - 6, H + 9, H + 9.4, 2.2, C.steel, M.metal)
	end
	box(m, "AirUnit", cx - 5, H + 0.8, Z0 + 4, cx + 5, H + 4, Z0 + 12, Color3.fromRGB(200, 204, 210), M.metal)
	-- paint mixing room on the west side (shelves of cans behind a window)
	local mix = Kit.model(m, "MixRoom")
	box(mix, "Body", X0 - 8, F, Z0 + 8, X0, 10, Z0 + 22, panel, M.smooth)
	box(mix, "Roof", X0 - 8.3, 10, Z0 + 7.7, X0, 10.6, Z0 + 22.3, Color3.fromRGB(214, 210, 200), M.metal)
	box(mix, "Window", X0 - 8.1, 4, Z0 + 10, X0 - 7.9, 7.4, Z0 + 16, C.glass, M.glass, { transparency = 0.3 })
	box(mix, "Door", X0 - 8.1, F, Z0 + 17, X0 - 7.9, 7.6, Z0 + 20.6, C.door, M.metal)
	local mixSign = box(mix, "Sign", X0 - 8.15, 8, Z0 + 10, X0 - 8.1, 9.4, Z0 + 20, C.blue, M.smooth, { collide = false })
	Kit.label(mixSign, Enum.NormalId.Left, "PAINT MIX", Color3.new(1, 1, 1), nil)
	local plate = box(m, "Plate", cx - 7, 11.6, Z0 - 0.3, cx + 7, 13.4, Z0, C.blue, M.smooth)
	Kit.label(plate, Enum.NormalId.Front, "PAINT BOOTH", Color3.new(1, 1, 1), OUTLINE)
	for _, bx in ipairs({ cx - 10.4, cx + 10.4 }) do
		Kit.post(m, "Bollard", bx, Z0 - 9, 0, 4.4, 1, C.yellow, M.metal)
	end
	-- markers
	marker(m, "CarSpot", Vector3.new(cx, F, 62), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(m, "ApproachSpot", Vector3.new(cx, 0, 32), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(m, "WorkArea", Vector3.new(cx, F + 6, 62), Vector3.new(0, 0, 1), Vector3.new(30, 12, 34))
	marker(m, "SprayPoint", Vector3.new(cx + 7, F, 62), Vector3.new(-1, 0, 0))
	marker(m, "MixPoint", Vector3.new(X0 - 10, F, Z0 + 18.8), Vector3.new(1, 0, 0))
	lockedPad(garage, "PaintBooth", "PaintBooth", 16, X0, Z0, X1, Z1, "PAINT BOOTH")
end

local function showroom(garage: Model)
	local X0, X1, Z0, Z1 = 56, 112, -20, 30
	local H = 18
	local m = Kit.model(garage, "Showroom")
	tag(m, "Level9", "Owned", 9)
	local sh = Kit.folder(m, "Building")
	local silver = Color3.fromRGB(206, 210, 216)
	local floor = box(sh, "Floor", X0, -1, Z0, X1, F, Z1, Color3.fromRGB(226, 228, 230), M.smooth)
	floor.Reflectance = 0.12
	-- back wall (solid), west wall solid with a glass car door (cars come in from the side drive), glass front + east
	box(sh, "BackWall", X0, F, Z1 - 1, X1, H, Z1, C.wall, M.smooth)
	box(sh, "WestWall", X0, F, Z0 + 1, X0 + 1, H, 0, C.wall, M.smooth)
	box(sh, "WestWall", X0, F, 16, X0 + 1, H, Z1 - 1, C.wall, M.smooth)
	box(sh, "WestHeader", X0, 13, 0, X0 + 1, H, 16, C.wall, M.smooth)
	local carDoor = box(m, "CarDoor", X0 + 0.3, F, 0, X0 + 0.6, 13, 16, C.glass, M.glass, { transparency = 0.5 })
	carDoor:SetAttribute("TopY", 13)
	carDoor:SetAttribute("ClosedBottomY", F)
	carDoor:SetAttribute("OpenBottomY", 12.4)
	-- glass curtain walls: front (with the buyer door at x 82..86) and east
	local function glassRun(a: Vector3, b: Vector3, gap0: number?, gap1: number?)
		local dir = (b - a).Unit
		local len = (b - a).Magnitude
		local n = math.floor(len / 6)
		for i = 0, n - 1 do
			local t0, t1 = i * len / n, (i + 1) * len / n
			local skip = gap0 and gap1 and t0 >= (gap0 :: number) - 0.01 and t1 <= (gap1 :: number) + 0.01
			local p0 = a + dir * t0
			local p1 = a + dir * t1
			local mid = (p0 + p1) / 2
			if not skip then
				Kit.part(sh, "Glass", Vector3.new(0.3, 13.6, t1 - t0), CFrame.lookAt(Vector3.new(mid.X, F + 6.8, mid.Z), Vector3.new(p1.X, F + 6.8, p1.Z)), C.glass, M.glass, { transparency = 0.55 })
			end
			Kit.post(sh, "Mullion", p0.X, p0.Z, F, 14, 0.4, silver, M.metal)
		end
		Kit.post(sh, "Mullion", b.X, b.Z, F, 14, 0.4, silver, M.metal)
		Kit.part(sh, "Transom", Vector3.new(0.6, 4, len), CFrame.lookAt(Vector3.new((a.X + b.X) / 2, 16, (a.Z + b.Z) / 2), Vector3.new(b.X, 16, b.Z)), C.wall, M.smooth)
	end
	glassRun(Vector3.new(X0, 0, Z0 + 0.3), Vector3.new(X1, 0, Z0 + 0.3), 24, 32) -- door gap at x 80..88
	glassRun(Vector3.new(X1 - 0.3, 0, Z0), Vector3.new(X1 - 0.3, 0, Z1 - 1))
	-- buyer door: glass leaves (walk-through), canopy over it (photo 03)
	box(m, "BuyerDoorLeaf", 81.1, F, Z0 + 0.25, 86.9, 9, Z0 + 0.35, C.glass, M.glass, { collide = false, transparency = 0.7 })
	box(sh, "DoorTransom", 80, 9, Z0, 88, 13.8, Z0 + 0.6, silver, M.metal)
	box(sh, "Canopy", 76, 10.4, Z0 - 7, 92, 11, Z0, C.red, M.smooth)
	box(sh, "CanopyEdge", 76, 9.6, Z0 - 7.2, 92, 11, Z0 - 7, C.red, M.smooth)
	for _, px in ipairs({ 76.6, 91.4 }) do
		Kit.post(sh, "CanopyPost", px, Z0 - 6.6, 0, 10.4, 0.5, silver, M.metal)
	end
	-- roof + thin silver fascia with the sign
	box(sh, "Roof", X0 - 0.5, H, Z0 - 0.5, X1 + 0.5, H + 0.8, Z1 + 0.5, C.roof, M.concrete)
	box(sh, "Fascia", X0 - 0.8, H - 0.2, Z0 - 1, X1 + 0.8, H + 2.6, Z0 - 0.4, silver, M.metal)
	box(sh, "Fascia", X1 + 0.4, H - 0.2, Z0 - 1, X1 + 1, H + 2.6, Z1 + 0.5, silver, M.metal)
	local sign = box(sh, "SignPanel", 66, H, Z0 - 1.2, 102, H + 2.4, Z0 - 1, C.blue, M.smooth)
	Kit.label(sign, Enum.NormalId.Front, "PRE-OWNED CARS", Color3.new(1, 1, 1), OUTLINE)
	-- inside: white ceiling with light panels, back offices (glass), sales desk, lounge
	box(sh, "Ceiling", X0 + 1, H - 0.8, Z0 + 0.6, X1 - 0.6, H - 0.6, Z1 - 1, Color3.fromRGB(244, 244, 242), M.smooth)
	for _, lz in ipairs({ -8, 6, 20 }) do
		for _, lx in ipairs({ 66, 84, 102 }) do
			light(box(sh, "CeilingPanel", lx - 3, H - 0.9, lz - 1.5, lx + 3, H - 0.8, lz + 1.5, Color3.fromRGB(255, 252, 244), M.neon, { collide = false, shadow = false }), 0.5, 18)
		end
	end
	-- back strip (z 23..29): glass office (west), lounge (middle), sales desk (east)
	box(sh, "OfficeWall", X0 + 1, F, 23.2, 70, 10, 23.5, C.glass, M.glass, { transparency = 0.5 })
	box(sh, "OfficeWall", 70, F, 23.2, 70.3, 10, Z1 - 1, C.wall, M.smooth)
	box(sh, "OfficeTop", X0 + 1, 10, 23.2, 70.3, 10.3, Z1 - 1, C.wall, M.smooth)
	box(sh, "OfficeDesk", 60, F, 25.6, 66, 3.2, 27.6, C.wood, M.wood)
	local desk = Kit.model(m, "SalesDesk")
	box(desk, "Desk", 99, F, 24.6, 109, 3.4, 26.4, Color3.fromRGB(250, 250, 248), M.smooth)
	box(desk, "Top", 98.8, 3.4, 24.4, 109.2, 3.7, 26.6, C.wood, M.wood)
	box(desk, "Monitor", 103, 3.7, 25.8, 104.8, 5.0, 26.0, C.rubber, M.smooth)
	box(desk, "DealerChair", 103, 1.8, 27, 105, 2.2, 28.6, C.rubber, M.smooth)
	box(desk, "DeskSign", 101, 3.7, 24.5, 107, 4.9, 24.6, C.blue, M.smooth, { collide = false })
	Kit.label(desk:FindFirstChild("DeskSign") :: BasePart, Enum.NormalId.Front, "SALES", Color3.new(1, 1, 1), nil)
	marker(m, "SellDesk", Vector3.new(104, F, 23.2), Vector3.new(0, 0, 1)) -- player stands here, facing the dealer
	marker(m, "DealerPoint", Vector3.new(104, F, 27.8), Vector3.new(0, 0, -1))
	local lounge = Kit.model(m, "Lounge")
	box(lounge, "Sofa", 76, F, 25.6, 88, 2.6, 28.6, Color3.fromRGB(104, 150, 210), M.smooth)
	box(lounge, "SofaBack", 76, F, 28, 88, 5, 29, Color3.fromRGB(104, 150, 210), M.smooth)
	box(lounge, "Table", 79, 1.4, 23.6, 85, 1.7, 25, C.wood, M.wood)
	for _, pp in ipairs({ { 58.6, -17.6 }, { 91, 27.4 }, { 109.4, -17.6 } }) do
		Kit.post(lounge, "PlantPot", pp[1], pp[2], F, 2.2, 1.8, C.cardboard, M.smooth)
		Kit.part(lounge, "Plant", Vector3.new(3, 3, 3), CFrame.new(pp[1], 3.6, pp[2]), C.grassDark, M.grass, { shape = "ball" })
	end
	-- display spots: low platform + price stand; spot 1 comes with the building (Lv9), 2-3 at Lv12, 4-6 at Lv16
	local spots = Kit.folder(m, "DisplaySpots")
	local views = Kit.folder(m, "ViewPoints")
	local tags = Kit.folder(m, "PriceTags")
	local plat = Kit.folder(m, "Platforms")
	local i = 0
	for _, sz in ipairs({ -8.5, 12 }) do
		for _, sx in ipairs({ 66, 84, 102 }) do
			i += 1
			local lv = if i == 1 then 9 elseif i <= 3 then 12 else 16
			local mk = marker(spots, "Spot" .. i, Vector3.new(sx, F + 0.3, sz), Vector3.new(0, 0, -1), Vector3.new(8, 0.2, 18))
			mk:SetAttribute("UnlockLevel", lv)
			local pm = Kit.model(plat, "Spot" .. i)
			if i > 1 then
				tag(pm, "Level" .. lv, "Owned", lv)
			end
			box(pm, "Platform", sx - 6, F, sz - 9.5, sx + 6, F + 0.3, sz + 9.5, Color3.fromRGB(150, 156, 168), M.smooth)
			box(pm, "PlatformEdge", sx - 6.2, F, sz - 9.7, sx + 6.2, F + 0.2, sz + 9.7, silver, M.metal)
			-- price stand in front of the car (code writes PriceTags.SpotN.Label.Price.Text)
			Kit.part(pm, "PriceStandPost", Vector3.new(0.2, 3.4, 0.2), CFrame.new(sx - 7.2, F + 1.7, sz - 5), silver, M.metal)
			local board = Kit.part(tags, "Spot" .. i, Vector3.new(2.4, 1.6, 0.1), CFrame.lookAt(Vector3.new(sx - 7.2, F + 3.8, sz - 5), Vector3.new(sx - 7.2, F + 3.8, sz - 20)),
				Color3.fromRGB(250, 250, 246), M.smooth, { collide = false })
			if i > 1 then
				tag(board, "Level" .. lv, "Owned", lv)
			end
			local gui = Kit.label(board, Enum.NormalId.Front, "$ ---", C.blue, nil)
			local t = gui:FindFirstChildOfClass("TextLabel")
			if t then
				t.Name = "Price"
			end
			marker(views, "Spot" .. i, Vector3.new(sx + 6.8, F, sz - 3), Vector3.new(-1, 0, 0)) -- buyer looks the car over here
			-- before that level: rope stanchions round an empty spot
			if i > 1 then
				local lk = Kit.model(plat, "Spot" .. i .. "Locked")
				tag(lk, "Level" .. lv, "Locked", lv)
				for _, c in ipairs({ { -5, -9 }, { 5, -9 }, { 5, 9 }, { -5, 9 } }) do
					Kit.post(lk, "Stanchion", sx + c[1], sz + c[2], F, F + 3.2, 0.4, silver, M.metal)
				end
				box(lk, "Rope", sx - 5, F + 2.6, sz - 9.1, sx + 5, F + 2.8, sz - 8.9, C.red, M.fabric, { collide = false })
				box(lk, "Rope", sx - 5, F + 2.6, sz + 8.9, sx + 5, F + 2.8, sz + 9.1, C.red, M.fabric, { collide = false })
				local note = box(lk, "Note", sx - 2, F + 2.9, sz - 9.15, sx + 2, F + 4.3, sz - 9.05, Color3.fromRGB(250, 248, 240), M.smooth, { collide = false })
				Kit.label(note, Enum.NormalId.Front, "Lv " .. lv, C.red, nil)
			end
		end
	end
	-- buyer route: sidewalk -> door -> lobby -> ViewPoints -> SellDesk
	marker(m, "BuyerSpawn", Vector3.new(84, 0.5, -70), Vector3.new(0, 0, 1))
	marker(m, "BuyerDoor", Vector3.new(84, 0, -21), Vector3.new(0, 0, 1))
	marker(m, "Lobby", Vector3.new(84, F, -15), Vector3.new(0, 0, 1))
	marker(m, "CarEntry", Vector3.new(50, 0, 8), Vector3.new(1, 0, 0))
	-- outside: feather flags along the glass, bunting to the lot poles, a pylon sign by the street
	local out = Kit.folder(m, "Outside")
	local flagCols = { C.red, C.blue, Color3.fromRGB(250, 250, 246) }
	for k, fx in ipairs({ 60, 72, 96, 108 }) do
		Kit.post(out, "FlagPole", fx, Z0 - 3, 0, 12, 0.2, silver, M.metal)
		box(out, "Flag", fx + 0.1, 5, Z0 - 3.05, fx + 1.8, 11.6, Z0 - 2.95, flagCols[(k - 1) % 3 + 1], M.fabric, { collide = false })
	end
	for k = 0, 9 do
		local x = 58 + k * 5.4
		local y = 10.2 - math.abs(k - 4.5) * 0.25
		Kit.part(out, "Pennant", Vector3.new(1.2, 1.2, 0.05), CFrame.new(x, y, Z0 - 1.6) * CFrame.Angles(0, 0, math.rad(45)), flagCols[k % 3 + 1], M.fabric, { collide = false, shadow = false })
	end
	box(out, "BuntingLine", 56, 10.6, Z0 - 1.65, 110, 10.7, Z0 - 1.55, C.metalDark, M.metal, { collide = false })
	Kit.post(out, "PylonPole", 108, -63, 0, 22, 1.2, silver, M.metal)
	local pylon = box(out, "PylonSign", 102, 16, -63.4, 114, 22, -62.6, C.red, M.smooth)
	Kit.label(pylon, Enum.NormalId.Front, "USED CARS", Color3.new(1, 1, 1), OUTLINE)
	Kit.label(pylon, Enum.NormalId.Back, "USED CARS", Color3.new(1, 1, 1), OUTLINE)
	local sub = box(out, "PylonSub", 103, 13, -63.3, 113, 15.6, -62.7, Color3.fromRGB(250, 250, 246), M.smooth)
	Kit.label(sub, Enum.NormalId.Front, "WE BUY & SELL", C.blue, nil)
	lockedPad(garage, "Showroom", "Level9", 9, X0, Z0, X1, Z1, "SHOWROOM")
end

FlipPlaces.bayShell = bayShell
FlipPlaces.lockedPad = lockedPad

function FlipPlaces.build(garage: Model)
	restoreBay(garage)
	paintBooth(garage)
	showroom(garage)
end

return FlipPlaces
