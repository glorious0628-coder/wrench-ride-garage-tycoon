--!strict
-- World/Growth (wr-builder): the map pieces that appear as the shop grows (economy.md 1-2, alpha_scope.md 3).
-- Each piece carries UpgradeId + UpgradeState ("Owned" = shown when you have it, "Locked" = shown before);
-- World/Upgrades moves them in / out. Build shows the Lv1 look. Contract: world_contract.md ★ 업그레이드.
--   PartsShelfPlus (Lv3)  Bay2 (Lv4)  WheelBalancer (Lv5)  HydraulicLift / OBDReader (Lv6)  Level6 (free: seats)
--   TireChanger (Lv7)  Level8 (junkyard road opens)  PartsWasher (Lv9)  SpringCompressor (Lv11)  EngineCrane (Lv13)
-- Later (still pink): RestorationBay (8), Bay3 (10), Bay4 / PaintBooth (16), Showroom spots (9 / 12 / 16).

local Kit = require(script.Parent.Kit)
local Equipment = require(script.Parent.Equipment)
local Props = require(script.Parent.Props)
local C, M = Kit.C, Kit.M
local box, marker, rod = Kit.box, Kit.marker, Kit.rod

local Growth = {}

local F = 0.2
local H = 20
local OUTLINE = Color3.fromRGB(28, 30, 40)

local function tag(inst: Instance, id: string, state: string, unlockLevel: number?)
	inst:SetAttribute("UpgradeId", id)
	inst:SetAttribute("UpgradeState", state)
	if unlockLevel then
		inst:SetAttribute("UnlockLevel", unlockLevel)
	end
end

local function surfaceLight(part: BasePart, brightness: number, range: number)
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

-- Bay 2: an annex west of Bay 1 (x -42..-14), same height / facade language, its own shutter and lift.
-- an annex bay west of the one before it (same height / facade language, own shutter + lift).
-- name / id = "Bay2" | "Bay3" | "Bay4"; X0..X1 = its outer x; plate = text over the door; lv = shop level
local function annexBay(garage: Model, name: string, X0: number, X1: number, plate: string, lv: number, seed: number)
	local bays = garage:FindFirstChild("Bays") :: Folder
	local Z0, Z1 = -20, 20
	local cx = (X0 + X1) / 2 -- -28
	local bay = Kit.model(bays, name)
	tag(bay, name, "Owned", lv)
	-- shell
	local sh = Kit.folder(bay, "Shell")
	box(sh, "FloorSlab", X0, -1, Z0, X1, F, Z1, C.floor, M.smooth).Reflectance = 0.04
	box(sh, "BackWall", X0, F, Z1 - 1, X1, H, Z1, C.wall, M.smooth)
	box(sh, "WestWall", X0, F, Z0 + 1, X0 + 1, H, Z1 - 1, C.wall, M.smooth)
	box(sh, "FrontWall", X0, F, Z0, cx - 8, H, Z0 + 1, C.wall, M.smooth)
	box(sh, "FrontWall", cx + 8, F, Z0, X1, H, Z0 + 1, C.wall, M.smooth)
	box(sh, "BayHeader", cx - 8, 14, Z0, cx + 8, H, Z0 + 1, C.wall, M.smooth)
	box(sh, "Roof", X0 - 0.5, H, Z0 - 0.5, X1 - 0.5, H + 1, Z1 + 0.5, C.roof, M.concrete) -- stops where Bay1's roof starts (no overlap)
	box(sh, "ParapetFront", X0 - 0.5, H + 1, Z0 - 0.5, X1 - 0.5, H + 4, Z0 + 0.5, C.wall, M.smooth)
	box(sh, "ParapetBack", X0 - 0.5, H + 1, Z1 - 0.5, X1 - 0.5, H + 2.5, Z1 + 0.5, C.wall, M.smooth)
	box(sh, "ParapetSide", X0 - 0.5, H + 1, Z0 + 0.5, X0 + 0.5, H + 2.5, Z1 - 0.5, C.wall, M.smooth)
	box(sh, "Coping", X0 - 0.8, H + 4, Z0 - 0.8, X1 - 0.8, H + 4.4, Z0 + 0.6, C.trim, M.concrete)
	box(sh, "Coping", X0 - 0.8, H + 2.5, Z0 + 0.6, X0 + 0.8, H + 2.9, Z1 + 0.8, C.trim, M.concrete)
	box(sh, "Coping", X0 + 0.8, H + 2.5, Z1 - 0.8, X1 - 0.8, H + 2.9, Z1 + 0.8, C.trim, M.concrete)
	box(sh, "Band", X0 - 0.2, 18.9, Z0 - 0.2, X1 - 0.5, 19.5, Z0, C.blue, M.smooth)
	box(sh, "Pilaster", X0 - 0.4, 0, Z0 - 0.4, X0 + 1, H, Z0, C.wall, M.smooth)
	box(sh, "Plinth", X0 - 0.2, 0, Z0 - 0.2, cx - 8.6, 1.2, Z0, C.plinth, M.concrete)
	box(sh, "Plinth", cx + 8.6, 0, Z0 - 0.2, X1 - 0.4, 1.2, Z0, C.plinth, M.concrete)
	box(sh, "Plinth", X0 - 0.2, 0, Z0, X0, 1.2, Z1 + 0.2, C.plinth, M.concrete)
	box(sh, "Plinth", X0, 0, Z1, X1, 1.2, Z1 + 0.2, C.plinth, M.concrete)
	local pipe = box(sh, "DownPipe", X0 - 0.9, 0.2, Z0 + 0.6, X0 - 0.3, 21, Z0 + 1.2, C.trim, M.metal)
	local nextBay = ({ Bay2 = "Bay3", Bay3 = "Bay4" })[name]
	if nextBay then
		tag(pipe, nextBay, "Locked", lv) -- the next annex would swallow this pipe
	end
	box(sh, "BayApron", cx - 12, -1, -32, cx + 12, 0.05, Z0, C.concrete, M.concrete)
	local plateBoard = box(sh, "BayPlate", cx - 7, 16.4, Z0 - 0.3, cx + 7, 18.4, Z0, Color3.fromRGB(250, 250, 246), M.smooth)
	Kit.label(plateBoard, Enum.NormalId.Front, plate, C.red, OUTLINE)
	for _, bx in ipairs({ cx - 10, cx + 10 }) do
		Kit.post(sh, "Bollard", bx, -21.6, 0, 4.4, 1, C.yellow, M.metal)
		Kit.part(sh, "BollardCap", Vector3.new(1, 1, 1), CFrame.new(bx, 4.4, -21.6), C.yellow, M.metal, { shape = "ball" })
	end
	-- inside: wainscot + stripe, bay lines, beams, lights
	local function band(x0: number, z0: number, x1: number, z1: number)
		box(sh, "Wainscot", x0, F, z0, x1, 3.0, z1, C.wainscot, M.smooth)
		box(sh, "WainscotStripe", x0, 3.0, z0, x1, 3.3, z1, C.blue, M.smooth)
	end
	band(X0 + 1, Z0 + 1, X0 + 1.1, Z1 - 1)
	band(X0 + 1, Z1 - 1.1, X1, Z1 - 1)
	band(X1 - 0.1, Z0 + 1, X1, Z1 - 1)
	band(X0 + 1, Z0 + 1, cx - 8, Z0 + 1.1)
	band(cx + 8, Z0 + 1, X1 - 0.1, Z0 + 1.1)
	box(sh, "BayLine", cx - 12.6, F, -19, cx - 12.2, F + 0.05, 18, C.lineYellow, M.smooth, { collide = false })
	box(sh, "BayLine", cx + 12.2, F, -19, cx + 12.6, F + 0.05, 18, C.lineYellow, M.smooth, { collide = false })
	for _, bz in ipairs({ -12, -2, 8 }) do
		box(sh, "RoofBeam", X0 + 1, H - 1.2, bz - 0.4, X1, H, bz + 0.4, C.beam, M.metal)
	end
	for _, lx in ipairs({ cx - 6, cx + 6 }) do
		box(sh, "LightFixture", lx - 0.6, H - 1.6, -14, lx + 0.6, H - 1.2, 14, C.lineWhite, M.smooth)
		local tube = box(sh, "LightTube", lx - 0.4, 18.3, -13.6, lx + 0.4, 18.4, 13.6, Color3.fromRGB(255, 252, 240), M.neon, { collide = false, shadow = false })
		surfaceLight(tube, 0.55, 18)
	end
	-- shutter (same rules as Bay1)
	local shutter = box(bay, "Shutter", cx - 8, 13.4, Z0 + 0.1, cx + 8, 14, Z0 + 0.5, C.shutter, M.metal)
	shutter:SetAttribute("TopY", 14)
	shutter:SetAttribute("ClosedBottomY", F)
	shutter:SetAttribute("OpenBottomY", 13.4)
	Props.shutterRibs(shutter)
	box(bay, "ShutterHood", cx - 8.6, 14, Z0 - 0.8, cx + 8.6, 16, Z0, C.shutterBox, M.metal)
	box(bay, "ShutterGuide", cx - 8.6, F, Z0 - 0.4, cx - 8, 14, Z0, C.shutterBox, M.metal)
	box(bay, "ShutterGuide", cx + 8, F, Z0 - 0.4, cx + 8.6, 14, Z0, C.shutterBox, M.metal)
	-- contract markers (same names as Bay1)
	marker(bay, "CarSpot", Vector3.new(cx, F, -1), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	local lift = marker(bay, "LiftSpot", Vector3.new(cx, F, -1), Vector3.new(0, 0, 1), Vector3.new(16, 0.2, 4))
	lift:SetAttribute("PostOffsetX", 6.0)
	marker(bay, "ApproachSpot", Vector3.new(cx, 0, -36), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(bay, "DriverExitSpot", Vector3.new(cx + 7, F, -3), Vector3.new(1, 0, 0))
	marker(bay, "WorkArea", Vector3.new(cx, F + 9.9, 0), Vector3.new(0, 0, 1), Vector3.new(26, 19.8, 38))
	if Equipment.OLD_LIFT then
		Equipment.lift(bay, "Old")
	end
	Equipment.lift(bay, "Hydraulic")
	Equipment.jackKit(bay, X0 + 1, cx, -1, true)
	Equipment.partsCart(bay, cx, -1)
	-- a few props, the same shapes as Bay1 turned / moved a little
	local pr = Kit.folder(bay, "Props")
	local r = Kit.rng(seed)
	local cO = CFrame.new(cx - 9.5, F, 17.6) * CFrame.Angles(0, math.rad(2 + (seed % 5)), 0)
	Kit.part(pr, "ChestBase", Vector3.new(6, 4, 2.4), cO * CFrame.new(0, 2.6, 0), C.red, M.smooth)
	Kit.part(pr, "ChestTop", Vector3.new(6.2, 0.2, 2.6), cO * CFrame.new(0, 4.7, 0), C.metalDark, M.metal)
	for i = 0, 3 do
		Kit.part(pr, "ChestHandle", Vector3.new(3.6, 0.2, 0.15), cO * CFrame.new(0, 1.2 + i * 0.8, -1.25), C.steel, M.metal, { collide = false })
	end
	for i = 0, 2 do
		local t = Kit.part(pr, "Tire", Vector3.new(0.9, 2.4, 2.4), CFrame.new(cx + 11 + (r() - 0.5) * 0.3, F + 0.45 + i * 0.9, 15 + (r() - 0.5) * 0.3) * CFrame.Angles(0, 0, math.rad(90)),
			C.rubber, M.plastic, { shape = "cyl" })
		t:SetAttribute("Placeholder3D", "Tire")
	end
	Kit.post(pr, "OilDrum", cx - 10.8, -12, F, F + 3.8, 2.4, if seed % 2 == 1 then C.blue else C.red, M.metal)
	Kit.post(pr, "OilDrumLid", cx - 10.8, -12, F + 3.8, F + 3.9, 2.3, C.metalDark, M.metal)
	local poster = box(pr, "Poster", X0 + 1, 7, 2, X0 + 1.1, 11, 7, C.blue, M.smooth)
	Kit.label(poster, Enum.NormalId.Right, string.upper((string.gsub(name, "Bay", "BAY "))), Color3.new(1, 1, 1), OUTLINE)

	-- Locked look (before buying): a bare concrete pad with chain posts and a sign
	local spots = garage:FindFirstChild("UpgradeSpots") or Kit.folder(garage, "UpgradeSpots")
	local lk = Kit.model(spots, name)
	tag(lk, name, "Locked", lv)
	box(lk, "Pad", X0, -1, Z0, X1 - 0.1, 0.1, Z1, C.concrete, M.concrete)
	for x = X0 + 1, X1 - 2, 6.5 do
		Kit.post(lk, "ChainPost", x, Z0 - 0.6, 0.1, 3.2, 0.5, C.yellow, M.metal)
	end
	box(lk, "Chain", X0 + 1, 2.4, Z0 - 0.65, X1 - 2.5, 2.5, Z0 - 0.55, C.metalDark, M.metal, { collide = false })
	Kit.post(lk, "SignPost", cx - 3, Z0 + 2, 0.1, 9, 0.4, C.trim, M.metal)
	Kit.post(lk, "SignPost", cx + 3, Z0 + 2, 0.1, 9, 0.4, C.trim, M.metal)
	local sg = box(lk, "Sign", cx - 4, 5.6, Z0 + 1.8, cx + 4, 8.8, Z0 + 2.2, Color3.fromRGB(250, 248, 240), M.smooth)
	Kit.label(sg, Enum.NormalId.Front, string.upper((string.gsub(name, "Bay", "BAY "))) .. "\nCOMING SOON", C.blue, nil)
	-- stacked pallets + a few cones so it reads as "space waiting to be built"
	for i = 0, 2 do
		box(lk, "Pallet", cx + 4 + i * 0.2, 0.1 + i * 0.6, 10, cx + 10 + i * 0.2, 0.6 + i * 0.6, 15, C.wood, M.wood)
	end
	for _, cp in ipairs({ { cx - 10, -14 }, { cx - 6, -16 }, { cx + 8, -15 } }) do
		Kit.part(lk, "Cone", Vector3.new(1.2, 1.8, 1.2), CFrame.new(cp[1], 1.0, cp[2]), Color3.fromRGB(240, 120, 30), M.smooth)
	end
	return bay
end

local function wheelBalancer(tools: Instance)
	local m = Kit.model(tools, "WheelBalancer")
	tag(m, "WheelBalancer", "Owned", 5)
	local grey = Color3.fromRGB(70, 78, 92)
	box(m, "Body", 9, F, -18.6, 12.6, 3.4, -15.6, grey, M.smooth)
	box(m, "Tray", 8.8, 3.4, -18.8, 12.8, 3.7, -15.4, C.metalDark, M.metal)
	Kit.part(m, "Shaft", Vector3.new(1.6, 0.5, 0.5), CFrame.new(8.2, 3.0, -17.1), C.steel, M.metal, { shape = "cyl" })
	Kit.part(m, "Flange", Vector3.new(0.3, 1.4, 1.4), CFrame.new(8.9, 3.0, -17.1), C.steel, M.metal, { shape = "cyl" })
	box(m, "Hood", 6.8, 4.4, -18.6, 9.0, 4.8, -15.6, C.red, M.smooth)
	box(m, "HoodArm", 8.8, 3.7, -18.6, 9.0, 4.6, -18.2, C.red, M.smooth)
	box(m, "Display", 10.4, 3.7, -18.6, 12.4, 6.6, -18.2, grey, M.smooth)
	box(m, "Screen", 10.6, 4.4, -18.25, 12.2, 6.2, -18.15, Color3.fromRGB(70, 200, 120), M.neon, { collide = false })
	box(m, "WeightTray", 9.8, 3.7, -16.4, 12.2, 3.9, -15.7, C.yellow, M.metal, { collide = false })
	marker(m, "UsePoint", Vector3.new(10.6, F, -13.6), Vector3.new(0, 0, -1)) -- in front of the display (the old spot under the hood was too tight)
	marker(m, "WheelMount", Vector3.new(7.6, 3.0, -17.1), Vector3.new(-1, 0, 0))
end

local function tireChanger(tools: Instance)
	local m = Kit.model(tools, "TireChanger")
	tag(m, "TireChanger", "Owned", 7)
	local o = -0.3 -- v32: 0.3 toward the door, clear of the 3D creeper leaning at z -2.05..-0.19 (World/Interior)
	box(m, "Base", -12.6, F, -5 + o, -9.6, 3.0, -1.8 + o, C.red, M.smooth)
	Kit.part(m, "Turntable", Vector3.new(0.3, 3.0, 3.0), CFrame.new(-11.1, 3.15, -3.4 + o) * CFrame.Angles(0, 0, math.rad(90)), C.metalDark, M.metal, { shape = "cyl" })
	box(m, "Column", -13, F, -4.0 + o, -12.4, 7.6, -2.8 + o, C.red, M.smooth)
	box(m, "Arm", -12.7, 7.0, -3.6 + o, -11.0, 7.4, -3.2 + o, C.metalDark, M.metal)
	box(m, "MountHead", -11.3, 4.4, -3.6 + o, -10.9, 7.0, -3.2 + o, C.steel, M.metal)
	box(m, "BeadBreaker", -9.6, 0.8, -1.6 + o, -9.0, 3.2, -1.2 + o, C.metalDark, M.metal)
	for i = 0, 2 do
		box(m, "Pedal", -9.6, F, -4.6 + i * 0.9 + o, -8.9, F + 0.4, -4.0 + i * 0.9 + o, C.rubber, M.smooth)
	end
	marker(m, "UsePoint", Vector3.new(-7.6, F, -3.4 + o), Vector3.new(-1, 0, 0))
	marker(m, "TireMount", Vector3.new(-11.1, 3.4, -3.4 + o), Vector3.new(0, 1, 0))
end

local function springCompressor(tools: Instance)
	local m = Kit.model(tools, "SpringCompressor")
	tag(m, "SpringCompressor", "Owned", 11)
	local o = 0.4 -- v31: 0.4 toward the tyre rack, clear of the creeper now leaning at z -1.75..-0.25 (World/Interior)
	box(m, "Frame", -13, 1, -0.6 + o, -12.6, 9, -0.2 + o, C.red, M.smooth)
	box(m, "Frame", -13, 1, 1.0 + o, -12.6, 9, 1.4 + o, C.red, M.smooth)
	box(m, "Top", -13, 8.6, -0.6 + o, -12, 9.2, 1.4 + o, C.red, M.smooth)
	box(m, "Ram", -12.6, 5.6, 0.2 + o, -12.2, 8.6, 0.6 + o, C.steel, M.metal)
	box(m, "JawTop", -12.6, 5.2, -0.4 + o, -11.6, 5.6, 1.2 + o, C.metalDark, M.metal)
	box(m, "JawLow", -12.6, 2.6, -0.4 + o, -11.6, 3.0, 1.2 + o, C.metalDark, M.metal)
	box(m, "Guard", -11.6, 2.4, -0.6 + o, -11.5, 6.0, 1.4 + o, C.glass, M.glass, { transparency = 0.5, collide = false })
	marker(m, "UsePoint", Vector3.new(-10.0, F, 0.4 + o), Vector3.new(-1, 0, 0))
end

local function partsWasher(tools: Instance)
	local m = Kit.model(tools, "PartsWasher")
	tag(m, "PartsWasher", "Owned", 9)
	box(m, "Cabinet", 9.6, F, -11.6, 12.8, 3.0, -8.8, C.red, M.smooth)
	box(m, "Sink", 9.4, 3.0, -11.8, 13.0, 3.5, -8.6, C.metal, M.metal)
	box(m, "Fluid", 9.8, 3.3, -11.4, 12.6, 3.55, -9.0, Color3.fromRGB(90, 120, 150), M.glass, { transparency = 0.2, collide = false })
	box(m, "Lid", 12.6, 3.5, -11.8, 13.0, 6.2, -8.6, C.red, M.smooth) -- propped open against the wall
	rod(m, "Faucet", Vector3.new(12.4, 3.5, -10.2), Vector3.new(11.4, 5.0, -10.2), 0.2, 0.2, C.steel, M.metal)
	box(m, "Brush", 10.0, 3.55, -11.2, 11.2, 3.75, -10.8, C.yellow, M.smooth, { collide = false })
	marker(m, "UsePoint", Vector3.new(7.8, F, -10.2), Vector3.new(1, 0, 0)) -- (moved 1.6 north: 3.6 gap to the balancer for its UsePoint)
end

local function obdStand(tools: Instance)
	local m = Kit.model(tools, "OBDStand")
	tag(m, "OBDReader", "Owned", 6)
	box(m, "Base", 11.8, F + 0.4, -8.2, 13.4, F + 0.6, -6.6, C.metalDark, M.metal)
	for _, c in ipairs({ { 12, -8.0 }, { 13.2, -8.0 }, { 12, -6.8 }, { 13.2, -6.8 } }) do
		Kit.part(m, "Caster", Vector3.new(0.25, 0.4, 0.4), CFrame.new(c[1], F + 0.2, c[2]), C.rubber, M.smooth, { shape = "cyl" })
	end
	box(m, "Pole", 12.5, F + 0.6, -7.5, 12.7, 4.4, -7.3, C.steel, M.metal)
	Kit.part(m, "Tablet", Vector3.new(1.6, 1.1, 0.2), CFrame.new(12.6, 4.8, -7.4) * CFrame.Angles(math.rad(-20), math.rad(-90), 0), C.rubber, M.smooth)
	Kit.part(m, "Screen", Vector3.new(1.4, 0.9, 0.05), CFrame.new(12.48, 4.8, -7.4) * CFrame.Angles(math.rad(-20), math.rad(-90), 0) * CFrame.new(0, 0, -0.1),
		Color3.fromRGB(70, 160, 230), M.neon, { collide = false })
	box(m, "Basket", 12.0, 2.6, -8.0, 13.2, 3.0, -6.8, C.blue, M.smooth)
	box(m, "Cable", 12.5, 1.6, -6.85, 12.6, 4.2, -6.75, C.rubber, M.smooth, { collide = false })
	local lab = box(m, "Label", 11.95, 2.62, -7.8, 12.0, 2.98, -7.0, C.blue, M.smooth, { collide = false })
	Kit.label(lab, Enum.NormalId.Left, "OBD", Color3.new(1, 1, 1), nil)
	marker(m, "UsePoint", Vector3.new(10.6, F, -7.4), Vector3.new(1, 0, 0))
end

local function partsShelfPlus(garage: Model)
	local m = Kit.model(garage, "PartsShelfPlus")
	tag(m, "PartsShelfPlus", "Owned", 3)
	local x0, x1, z0, z1 = 12.2, 13.9, 1.4, 5.8
	for _, y in ipairs({ 0.4, 2.0, 3.8 }) do
		box(m, "Board", x0, y, z0, x1, y + 0.2, z1, C.blue, M.metal)
	end
	for _, c in ipairs({ { x0, z0 }, { x0, z1 - 0.3 } }) do
		box(m, "Upright", c[1], F, c[2], c[1] + 0.3, 5.2, c[2] + 0.3, C.metalDark, M.metal)
	end
	local sign = box(m, "Sign", x0 - 0.05, 4.4, z0 + 0.4, x0, 5.2, z1 - 0.4, C.yellow, M.smooth, { collide = false })
	Kit.label(sign, Enum.NormalId.Left, "READY PARTS", Color3.fromRGB(30, 30, 36), nil)
	local slots = Kit.folder(m, "Slots")
	local n = 0
	for _, y in ipairs({ 2.2, 4.0 }) do
		for _, z in ipairs({ 2.5, 4.7 }) do
			n += 1
			marker(slots, "Slot" .. n, Vector3.new((x0 + x1) / 2, y, z), Vector3.new(-1, 0, 0), Vector3.new(1.4, 0.2, 2))
		end
	end
	marker(m, "UsePoint", Vector3.new(10.8, F, 3.6), Vector3.new(1, 0, 0))
end

local function waitingPlus(garage: Model)
	-- Level6 (free): two more chairs under the bay window + a side table and a second plant (more customers)
	local wr = garage:FindFirstChild("WaitingRoom") :: Model
	local seats = wr:FindFirstChild("Seats") :: Folder
	local m = Kit.model(wr, "SeatsPlus")
	tag(m, "Level6", "Owned", 6)
	box(m, "SeatFrame", 15.2, F, -16, 17.6, 2.2, -10.2, C.metalDark, M.metal)
	for i, sz in ipairs({ -14.8, -11.4 }) do
		box(m, "SeatBack", 15.2, 2.6, sz - 1.2, 15.6, 5.4, sz + 1.2, C.seat, M.smooth)
		local s = Kit.part(seats, "Seat" .. (6 + i), Vector3.new(2.4, 0.4, 2.4), CFrame.new(16.6, 2.4, sz) * CFrame.Angles(0, math.rad(-90), 0), C.seat, M.smooth, { class = "Seat" })
		s:SetAttribute("Facing", "+X")
		tag(s, "Level6", "Owned", 6)
	end
	box(m, "SideTable", 15.4, F, -13.5, 17.2, 2.0, -12.7, C.wood, M.wood)
	Kit.post(m, "PlantPot", 16.3, -17.6, F, 2, 1.6, C.cardboard, M.smooth)
	Kit.part(m, "Plant", Vector3.new(2.6, 2.6, 2.6), CFrame.new(16.3, 3.2, -17.6), C.grassDark, M.grass, { shape = "ball" })
end

function Growth.build(garage: Model)
	annexBay(garage, "Bay2", -42, -14, "TIRES & BRAKES", 4, 171)
	annexBay(garage, "Bay3", -70, -42, "QUICK SERVICE", 10, 173)
	annexBay(garage, "Bay4", -98, -70, "SERVICE", 16, 175)
	local tools = garage:FindFirstChild("Tools") :: Folder
	wheelBalancer(tools)
	tireChanger(tools)
	springCompressor(tools)
	partsWasher(tools)
	obdStand(tools)
	partsShelfPlus(garage)
	waitingPlus(garage)
	-- existing pieces that are purchases / level gates
	-- Bay1's west front down pipe would poke into Bay2: only there before Bay2 is built
	local dress = garage:FindFirstChild("Dressing")
	if dress then
		for _, p in ipairs(dress:GetChildren()) do
			if p.Name == "DownPipe" and p:IsA("BasePart") and p.Position.X < 0 then
				tag(p, "Bay2", "Locked", 4)
			end
		end
	end
	local crane = tools:FindFirstChild("EngineCrane1")
	if crane then
		tag(crane, "EngineCrane", "Owned", 13)
	end
	local jy = garage:FindFirstChild("Junkyard")
	if jy then
		jy:SetAttribute("UnlockLevel", 8)
		local barrier = jy:FindFirstChild("Barrier")
		if barrier then
			tag(barrier, "Level8", "Locked", 8) -- the road block goes away at Lv8
		end
	end
	-- still-pink places: ids + levels from economy.md (no hide/show yet — they stay as pink until built)
	local bays = garage:FindFirstChild("Bays") :: Folder
	local function meta(inst: Instance?, id: string, lv: number)
		if inst then
			inst:SetAttribute("UpgradeId", id)
			inst:SetAttribute("UnlockLevel", lv)
		end
	end
	meta(bays:FindFirstChild("Bay3"), "Bay3", 10)
	meta(bays:FindFirstChild("Bay4"), "Bay4", 16)
	-- RestoreBay / PaintBooth / Showroom: World/FlipPlaces
end

return Growth
