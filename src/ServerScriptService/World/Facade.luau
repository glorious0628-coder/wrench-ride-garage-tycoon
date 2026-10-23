--!strict
-- World/Facade (wr-builder): the shop grows up in three eras (docs/design/garage_growth.md, wr-carbook detroit.md
-- §3-1 / idea J — NPS Preservation Brief 46: shed -> house-shaped brick -> white porcelain-enamel box).
-- Only the FRONT changes: skins over the front walls, signs, roofline, a canopy. Same place, same markers, same
-- openings (bay door, storefront glass, customer door) in every era. World/Upgrades shows one era at a time:
--   Building.Facade.Shed                    Level6 Locked   (Lv1-5)  planks + corrugated iron, hand-painted sign
--   Building.Facade.BrickEra (Level6 Owned) > Brick  Level16 Locked (Lv6-15) brick, gable, steel sign + bulbs
--   Building.Facade.Enamel                  Level16 Owned  (Lv16+)  white enamel, rounded corner, canopy, neon
-- The annex bays carry their own skins (Bay2: Shed / Brick, Bay3: Brick; Bay4 is Lv16-only = the white base).
-- Small steps between: Lv3 the shed sign is repainted, Lv10 flags out front, Lv12 a flower pot, Lv17 a gold
-- star border on the neon sign. Contract: world_contract.md ★ 정비소가 자란다.

local Kit = require(script.Parent.Kit)
local C, M = Kit.C, Kit.M
local box, marker = Kit.box, Kit.marker

local Facade = {}

local DECO = { collide = false }
local MAT = Enum.Material
local WZ0, WZ1 = -20.55, -20.3 -- wall skin plane (in front of the pilasters at -20.4 and the roof slab edge at -20.5)
local PZ0, PZ1 = -20.9, -20.6 -- parapet skin plane (in front of the coping at -20.8)

local PLANK = Color3.fromRGB(198, 138, 86)
local TIN = Color3.fromRGB(192, 194, 186) -- galvanised corrugated iron (light, not rusty: casual)
local BRICK = Color3.fromRGB(170, 76, 60)
local STONE = Color3.fromRGB(226, 218, 200)
local ENAMEL = Color3.fromRGB(244, 244, 240)
local BULB = Color3.fromRGB(255, 226, 150)

local function tag(inst: Instance, id: string, state: string, lv: number)
	inst:SetAttribute("UpgradeId", id)
	inst:SetAttribute("UpgradeState", state)
	inst:SetAttribute("UnlockLevel", lv)
end

type Skin = { low: Enum.Material, lowCol: Color3, high: Enum.Material, highCol: Color3, par: Enum.Material, parCol: Color3 }

-- skin panels for a front x0..x1 with a bay door centred at bx (opening x bx-8.6..bx+8.6 up to y 16, the shutter
-- hood included); office = the Bay1 block's storefront (glass x 15..29, door x 29..35, transom up to y 12)
local function frontSkin(m: Instance, x0: number, x1: number, bx: number, office: boolean, s: Skin)
	box(m, "Skin", x0, 0, WZ0, bx - 8.6, 16, WZ1, s.lowCol, s.low)
	local rx1 = if office then 15 else x1
	box(m, "Skin", bx + 8.6, 0, WZ0, rx1, 16, WZ1, s.lowCol, s.low)
	if office then
		box(m, "Skin", 15, 0, WZ0, 29, 2.2, WZ1, s.lowCol, s.low) -- under the glass
		box(m, "Skin", 35, 0, WZ0, x1, 12, WZ1, s.lowCol, s.low) -- the pier east of the door
		box(m, "Skin", 15, 12, WZ0, x1, 16, WZ1, s.highCol, s.high) -- over the storefront
	end
	box(m, "Skin", x0, 16, WZ0, x1, 20.6, WZ1, s.highCol, s.high)
	box(m, "ParapetSkin", x0, 20.6, PZ0, x1, 24.45, PZ1, s.parCol, s.par)
end

local SHED: Skin = { low = MAT.WoodPlanks, lowCol = PLANK, high = MAT.Metal, highCol = TIN, par = MAT.Metal, parCol = Color3.fromRGB(182, 184, 176) }
local BRICKS: Skin = { low = MAT.Brick, lowCol = BRICK, high = MAT.Brick, highCol = BRICK, par = MAT.Brick, parCol = Color3.fromRGB(160, 70, 56) }

-- a hand-painted board (shed era)
local function paintedBoard(m: Instance, name: string, x0: number, y0: number, x1: number, y1: number, z: number, text: string, ink: Color3, tilt: number)
	local b = Kit.part(m, name, Vector3.new(x1 - x0, y1 - y0, 0.2), CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, z) * CFrame.Angles(0, 0, math.rad(tilt)),
		Color3.fromRGB(240, 222, 176), MAT.WoodPlanks)
	Kit.label(b, Enum.NormalId.Front, text, ink, nil, Enum.Font.Cartoon)
	return b
end

-- corrugated iron reads by its ribs: one rib every 3 studs over the tin band and the false front
local function ribs(m: Instance, x0: number, x1: number)
	for x = x0 + 1.5, x1 - 1, 3 do
		box(m, "Rib", x - 0.12, 16, PZ0 - 0.05, x + 0.12, 24.45, WZ0, Color3.fromRGB(146, 150, 146), MAT.Metal, DECO)
	end
end

-- the shed's low lean-to roof edge in corrugated iron along the front
local function eave(m: Instance, x0: number, x1: number)
	Kit.part(m, "Eave", Vector3.new(x1 - x0 + 1, 0.35, 3.4), CFrame.new((x0 + x1) / 2, 21.8, PZ0 - 1.6) * CFrame.Angles(math.rad(-20), 0, 0),
		Color3.fromRGB(150, 158, 154), MAT.Metal)
end

-- stone coping + cornice ledge (brick era)
local function brickTrim(m: Instance, x0: number, x1: number)
	box(m, "Coping", x0 - 0.2, 24.45, PZ0 - 0.15, x1 + 0.2, 24.95, PZ1 + 0.2, STONE, M.concrete)
	box(m, "Cornice", x0 - 0.1, 20.4, PZ0 - 0.05, x1 + 0.1, 20.9, WZ1, STONE, M.concrete)
end

local function mainShed(f: Instance, garage: Model)
	local m = Kit.model(f, "Shed")
	tag(m, "Level6", "Locked", 6)
	frontSkin(m, -14.45, 38.45, 0, true, SHED)
	ribs(m, -14.45, 38.45)
	eave(m, -14.45, 38.45)
	-- hand-painted sign: faded until Lv3, then repainted (brighter)
	local faded = paintedBoard(m, "SignFaded", -2, 22.6, 26, 25.4, PZ0 - 0.3, "WRENCH & RIDE", Color3.fromRGB(170, 96, 84), 0.8)
	tag(faded, "Level3", "Locked", 3)
	local fresh = paintedBoard(m, "SignFresh", -2, 22.6, 26, 25.4, PZ0 - 0.3, "WRENCH & RIDE", Color3.fromRGB(206, 36, 32), 0.8)
	tag(fresh, "Level3", "Owned", 3)
	paintedBoard(m, "RepairsBoard", -7.2, 16.1, 7.2, 18.7, -21.0, "REPAIRS", Color3.fromRGB(40, 60, 120), -0.6)
	paintedBoard(m, "OfficeBoard", 29.4, 12.4, 34.6, 13.9, WZ0 - 0.12, "OFFICE", Color3.fromRGB(40, 60, 120), 0)
	-- plank porch roof over the customer door on two wall braces (no posts on the walkway)
	Kit.part(m, "PorchRoof", Vector3.new(9, 0.3, 3.2), CFrame.new(32, 11.5, WZ0 - 1.5) * CFrame.Angles(math.rad(-12), 0, 0), PLANK, MAT.WoodPlanks)
	for _, px in ipairs({ 28.4, 35.6 }) do
		Kit.rod(m, "PorchBrace", Vector3.new(px, 9.4, WZ0), Vector3.new(px, 11.3, WZ0 - 2.6), 0.25, 0.25, Color3.fromRGB(110, 84, 60), MAT.Wood, DECO)
	end
	-- oil on the apron (a shed garage's floor out front)
	box(m, "OilStain", -4, 0.05, -29.5, 1.5, 0.07, -25.8, Color3.fromRGB(70, 70, 72), M.smooth, DECO)
	box(m, "OilStain", 3, 0.05, -24.6, 5.4, 0.07, -22.6, Color3.fromRGB(84, 84, 86), M.smooth, DECO)
	local _ = garage
end

local function mainBrick(f: Instance, garage: Model)
	local era = Kit.model(f, "BrickEra")
	tag(era, "Level6", "Owned", 6)
	local m = Kit.model(era, "Brick")
	tag(m, "Level16", "Locked", 16)
	frontSkin(m, -14.45, 38.45, 0, true, BRICKS)
	brickTrim(m, -14.45, 38.45)
	-- house-shaped gable over the office (photo idea J: the 1920s "house" station)
	local gx0, gx1, gy0, gy1 = 15, 38.45, 24.95, 30.6
	local half = (gx1 - gx0) / 2
	Kit.part(m, "Gable", Vector3.new(1.5, gy1 - gy0, half), CFrame.new(gx0 + half / 2, (gy0 + gy1) / 2, -20.15) * CFrame.Angles(0, math.pi / 2, 0),
		BRICK, MAT.Brick, { shape = "wedge" })
	Kit.part(m, "Gable", Vector3.new(1.5, gy1 - gy0, half), CFrame.new(gx1 - half / 2, (gy0 + gy1) / 2, -20.15) * CFrame.Angles(0, -math.pi / 2, 0),
		BRICK, MAT.Brick, { shape = "wedge" })
	local peak = Vector3.new(gx0 + half, gy1 + 0.2, -20.95)
	Kit.rod(m, "GableCoping", Vector3.new(gx0 - 0.4, gy0, -20.95), peak, 1.7, 0.45, STONE, M.concrete)
	Kit.rod(m, "GableCoping", peak, Vector3.new(gx1 + 0.4, gy0, -20.95), 1.7, 0.45, STONE, M.concrete)
	Kit.part(m, "GableVent", Vector3.new(0.3, 2.2, 2.2), CFrame.new(gx0 + half, 27.4, -20.92) * CFrame.Angles(0, math.pi / 2, 0), STONE, M.concrete, { collide = false, shape = "cyl" })
	-- the steel sign (the old red board) now with a bulb border; the blue office awning
	local shell = garage:FindFirstChild("Building")
	local dress = garage:FindFirstChild("Dressing")
	for _, pair in ipairs({ { shell, "SignBoard" }, { shell, "SignTrim" }, { shell, "SignTrim" }, { shell, "Awning" }, { shell, "AwningEdge" }, { dress, "OfficePlate" } }) do
		local p = pair[1] and (pair[1] :: Instance):FindFirstChild(pair[2] :: string)
		if p then
			p.Parent = m
		end
	end
	for x = -5.4, 29.5, 2.9 do
		for _, y in ipairs({ 21.05, 24.35 }) do
			Kit.part(m, "Bulb", Vector3.new(0.5, 0.5, 0.5), CFrame.new(x, y, -21.15), BULB, M.neon, { collide = false, shape = "ball" })
		end
	end
end

local function mainEnamel(f: Instance, garage: Model)
	local m = Kit.model(f, "Enamel")
	tag(m, "Level16", "Owned", 16)
	-- the white base walls ARE the enamel: panel seams, a red stripe, a rounded corner
	for _, x in ipairs({ -12, -6, 6, 12, 18, 24, 30, 36 }) do
		box(m, "PanelSeam", x - 0.06, 16, -20.06, x + 0.06, 20, -20, Color3.fromRGB(190, 192, 194), M.smooth, DECO)
	end
	box(m, "Stripe", -14.45, 20.1, -20.62, 38.45, 20.7, -20.5, C.red, M.smooth, DECO)
	Kit.post(m, "RoundCorner", 38, -20, 0, 24.45, 1.8, ENAMEL, M.smooth)
	-- canopy over the walkway and the bay door: its red fascia is the big sign of the services
	box(m, "Canopy", -14.45, 16.8, -26.5, 38.45, 17.4, -20.45, ENAMEL, M.smooth)
	local fascia = box(m, "CanopyFascia", -14.45, 15.9, -26.7, 38.45, 17.9, -26.5, C.red, M.smooth, DECO)
	local g = Kit.label(fascia, Enum.NormalId.Front, "SERVICE  ·  TIRES  ·  BRAKES  ·  PAINT", Color3.new(1, 1, 1), nil, Enum.Font.GothamBlack)
	g.PixelsPerStud = 24
	box(m, "CanopyGlow", -14, 16.7, -26.4, 38, 16.8, -25.8, Color3.fromRGB(255, 250, 236), M.neon, DECO)
	-- the big neon sign on the parapet
	local sign = box(m, "NeonSign", -8, 21.2, -21.25, 32, 25.6, -20.9, Color3.fromRGB(28, 36, 64), M.smooth)
	local ng = Kit.label(sign, Enum.NormalId.Front, "WRENCH & RIDE MOTORS", Color3.fromRGB(255, 96, 84), Color3.fromRGB(255, 214, 200), Enum.Font.GothamBlack)
	ng.PixelsPerStud = 24
	local NEON = Color3.fromRGB(255, 70, 60)
	box(m, "NeonTube", -8.25, 25.6, -21.32, 32.25, 25.85, -21.2, NEON, M.neon, DECO)
	box(m, "NeonTube", -8.25, 20.95, -21.32, 32.25, 21.2, -21.2, NEON, M.neon, DECO)
	box(m, "NeonTube", -8.25, 21.2, -21.32, -8, 25.6, -21.2, NEON, M.neon, DECO)
	box(m, "NeonTube", 32, 21.2, -21.32, 32.25, 25.6, -21.2, NEON, M.neon, DECO)
	-- Lv17+ (Garage Star): a gold border and two stars round the neon sign
	local star = Kit.model(m, "StarBorder")
	tag(star, "Level17", "Owned", 17)
	local GOLD = Color3.fromRGB(255, 200, 60)
	box(star, "GoldTube", -8.6, 26.0, -21.36, 32.6, 26.25, -21.26, GOLD, M.neon, DECO)
	box(star, "GoldTube", -8.6, 20.55, -21.36, 32.6, 20.8, -21.26, GOLD, M.neon, DECO)
	for _, sx in ipairs({ -10, 34 }) do
		local s = box(star, "Star", sx - 1, 22.4, -21.3, sx + 1, 24.4, -21.1, Color3.fromRGB(28, 36, 64), M.smooth, DECO)
		Kit.label(s, Enum.NormalId.Front, "★", GOLD, nil, Enum.Font.GothamBlack)
	end
	local _ = garage
end

-- the annex bays' own era skins (inside the bay model, so they come and go with the bay)
local function annexSkins(garage: Model)
	local bays = garage:FindFirstChild("Bays")
	if not bays then
		return
	end
	for _, spec in ipairs({ { "Bay2", -42, -14, true }, { "Bay3", -70, -42, false } }) do
		local bay = bays:FindFirstChild(spec[1] :: string)
		if bay then
			local X0, X1 = spec[2] :: number, spec[3] :: number
			local x0, x1, cx = X0 - 0.45, X1 - 0.45, (X0 + X1) / 2
			local sh = bay:FindFirstChild("Shell")
			local plate = sh and sh:FindFirstChild("BayPlate")
			if plate and plate:IsA("BasePart") then
				plate.CFrame += Vector3.new(0, 0, -0.5) -- in front of the skins in every era
			end
			if spec[4] then
				local shed = Kit.model(bay, "Shed")
				tag(shed, "Level6", "Locked", 6)
				frontSkin(shed, x0, x1, cx, false, SHED)
				ribs(shed, x0, x1)
				eave(shed, x0, x1)
				paintedBoard(shed, "PlateBoard", cx - 7.2, 16.1, cx + 7.2, 18.7, -21.0, "TIRES & BRAKES", Color3.fromRGB(40, 60, 120), 0.5)
			end
			local era = Kit.model(bay, "BrickEra")
			tag(era, "Level6", "Owned", 6)
			local brick = Kit.model(era, "Brick")
			tag(brick, "Level16", "Locked", 16)
			frontSkin(brick, x0, x1, cx, false, BRICKS)
			brickTrim(brick, x0, x1)
		end
	end
end

-- before Bay 2 is bought: its spot is a boarded-up lean-to (the shed has one working bay; the next waits behind planks)
local function boardedBay2(garage: Model)
	local spots = garage:FindFirstChild("UpgradeSpots")
	local lk = spots and spots:FindFirstChild("Bay2")
	if not lk then
		return
	end
	box(lk, "Boards", -41.6, 0.1, -20.3, -14.6, 12.6, -19.9, Color3.fromRGB(150, 116, 82), MAT.WoodPlanks)
	for _, s in ipairs({ { -38, -24 }, { -24, -38 } }) do
		Kit.rod(lk, "CrossBoard", Vector3.new(s[1], 1, -20.5), Vector3.new(s[2], 11.6, -20.5), 1.1, 0.25, Color3.fromRGB(120, 92, 64), MAT.WoodPlanks, DECO)
	end
	box(lk, "SideBoards", -42, 0.1, -20.3, -41.6, 12.6, 20, Color3.fromRGB(150, 116, 82), MAT.WoodPlanks)
	box(lk, "BackBoards", -41.6, 0.1, 19.6, -14.6, 12.6, 20, Color3.fromRGB(150, 116, 82), MAT.WoodPlanks) -- closed all round: no dead-end room
	Kit.part(lk, "LeanToRoof", Vector3.new(28, 0.35, 41), CFrame.new(-28, 13.6, -0.2) * CFrame.Angles(0, 0, math.rad(-6)), Color3.fromRGB(150, 158, 154), MAT.Metal)
	paintedBoard(lk, "ComingBoard", -34, 5.4, -22, 8.4, -20.55, "BAY 2\nCOMING SOON", Color3.fromRGB(40, 60, 120), -1.2)
end

-- the shop moves its bay plate a little forward so it shows over every era's skin
local function plateForward(garage: Model)
	local d = garage:FindFirstChild("Dressing")
	if not d then
		return
	end
	for _, c in ipairs(d:GetChildren()) do
		if c:IsA("BasePart") and (c.Name == "BayPlate" or c.Name == "BayPlateTrim") then
			c.CFrame += Vector3.new(0, 0, -0.5)
		end
	end
end

-- out front: flags at Lv10, a flower pot at Lv12
local function frontYard(garage: Model)
	local f = garage:FindFirstChild("Building") :: Instance
	local flags = Kit.model(f, "Flags")
	tag(flags, "Level10", "Owned", 10)
	-- two poles at the walkway's front edge, either end of the office (clear of the side drive x 38..56)
	for i, fx in ipairs({ 15.4, 37.2 }) do
		local fz = -27.4
		Kit.post(flags, "FlagPole", fx, fz, 0.2, 24, 0.35, C.steel, M.metal, DECO)
		Kit.part(flags, "PoleBall", Vector3.new(0.6, 0.6, 0.6), CFrame.new(fx, 24.2, fz), C.yellow, M.metal, { collide = false, shape = "ball" })
		local flag = box(flags, "Flag", fx + 0.05, 19.6, fz - 0.05, fx + 4.4, 22.8, fz + 0.05, if i == 1 then C.red else Color3.fromRGB(40, 86, 170), M.fabric, DECO)
		local word = if i == 1 then "W&R" else "GEAR\nPORT"
		Kit.label(flag, Enum.NormalId.Front, word, Color3.new(1, 1, 1), nil, Enum.Font.GothamBlack)
		Kit.label(flag, Enum.NormalId.Back, word, Color3.new(1, 1, 1), nil, Enum.Font.GothamBlack)
	end
	local pot = Kit.model(f, "FlowerPot")
	tag(pot, "Level12", "Owned", 12)
	Kit.post(pot, "Pot", 36.6, -21.4, 0.2, 1.8, 1.6, Color3.fromRGB(176, 96, 64), M.smooth)
	Kit.part(pot, "Flowers", Vector3.new(1.8, 1.4, 1.8), CFrame.new(36.6, 2.3, -21.4), Color3.fromRGB(236, 96, 130), M.grass, { collide = false, shape = "ball" })
end

-- the waiting room's photo wall (over the seats, east wall): an empty board for the "meme car" photos — code later
local function photoWall(garage: Model)
	local wr = garage:FindFirstChild("WaitingRoom")
	if not wr then
		return
	end
	local m = Kit.model(wr, "PhotoWall")
	box(m, "Board", 36.75, 6.2, -18, 36.95, 10.6, -6.6, Color3.fromRGB(184, 140, 96), M.wood)
	local head = box(m, "Header", 36.7, 10.6, -16, 36.95, 11.5, -8.6, Color3.fromRGB(40, 60, 120), M.smooth)
	Kit.label(head, Enum.NormalId.Left, "OUR CUSTOMERS", Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
	marker(m, "PhotoWallSpot", Vector3.new(36.74, 8.4, -12.3), Vector3.new(-1, 0, 0), Vector3.new(0.2, 4.4, 11.4))
end

function Facade.build(garage: Model)
	local shell = garage:FindFirstChild("Building") or Kit.folder(garage, "Building")
	local f = Kit.folder(shell, "Facade")
	-- where a level-up camera can stand to show the new front (ui_screens "Show me"): the whole front in view
	-- (v23: back over the curb + up, looking over the cars waiting in the queue stalls at the bay door)
	marker(f, "ShowCamera", Vector3.new(6, 17, -80), Vector3.new(4, -9, 60).Unit)
	plateForward(garage)
	mainShed(f, garage)
	mainBrick(f, garage)
	mainEnamel(f, garage)
	annexSkins(garage)
	boardedBay2(garage)
	frontYard(garage)
	photoWall(garage)
end

return Facade
