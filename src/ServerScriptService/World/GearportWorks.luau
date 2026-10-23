--!strict
-- World/GearportWorks (wr-builder): Gearport stage 3 (plan: notes/design/detroit_town_plan.md §3 F, G;
-- photos notes/research/ref_detroit #9-15 factories / stacks / sawtooth / water tank, #18-19 market).
--   Market Hall — brick gable hall with two open arches (you can walk in), market stalls inside, long open sheds on
--     both sides; reserved marker Town.MarketHall.CouponStall.PromptPoint (world_contract ★ Gearport)
--   Foundry Road — the cross street now ends in an east-west works road
--   The Old Works — a five-storey concrete-grid motor works with a rooftop letter frame and a water tank, a brick
--     factory with a mural wall, two sawtooth sheds, a row of four smokestacks (Persistent, seen from far)
--   Rail yard — two sidings along the junkyard's east fence, boxcars, flatcars with spots for background cars
-- Looks only, except the reserved marker. "Looks = works": the market arches are open; factory doors are shut
-- shutters; nothing invites you in that you can't enter.

local Kit = require(script.Parent.Kit)
local Site = require(script.Parent.Site)
local LivedIn = require(script.Parent.LivedIn)
local GearportProps = require(script.Parent.GearportProps)
local C, M = Kit.C, Kit.M
local box, marker = Kit.box, Kit.marker

local Works = {}

local X0, X1 = Site.CROSS_X0, Site.CROSS_X1
local MX1 = Site.MAP_X1
local DECO = { collide = false }
local FLAT = { shadow = false }
local BRICK = Color3.fromRGB(196, 100, 72)
local BRICK2 = Color3.fromRGB(178, 96, 74)
local STONE = Color3.fromRGB(226, 214, 186)
local CONCRETE = Color3.fromRGB(226, 224, 216)
local GLASS = Color3.fromRGB(96, 116, 118) -- grey-green factory sash glass (blue read as offices)
local SHUTTER = Color3.fromRGB(150, 156, 160)

local function label(part: BasePart, face: Enum.NormalId, text: string, color: Color3, font: Enum.Font?, pps: number)
	local g = Kit.label(part, face, text, color, nil, font)
	g.PixelsPerStud = pps
	return g
end

-- gable roof with the ridge along Z (slopes face -X and +X)
local function gableZ(parent: Instance, x0: number, x1: number, z0: number, z1: number, y: number, rise: number, color: Color3)
	local xm = (x0 + x1) / 2
	Kit.part(parent, "Roof", Vector3.new(z1 - z0, rise, xm - x0), CFrame.new((x0 + xm) / 2, y + rise / 2, (z0 + z1) / 2) * CFrame.Angles(0, math.rad(90), 0), color, M.smooth,
		{ shape = "wedge" })
	Kit.part(parent, "Roof", Vector3.new(z1 - z0, rise, x1 - xm), CFrame.new((xm + x1) / 2, y + rise / 2, (z0 + z1) / 2) * CFrame.Angles(0, math.rad(-90), 0), color, M.smooth,
		{ shape = "wedge" })
end

-- Market Hall (photo 18): faces the avenue (-Z), front at z -62, x 246..276; open arches lead into a hall with stalls
local function marketHall(town: Instance)
	local mh = Kit.model(town, "MarketHall")
	local x0, x1, zf, zb = 246, 276, -62, -26
	local h = 15
	box(mh, "Plaza", X1 + 4, -1, Site.WALK_Z1, 300, 0.5, -8, Color3.fromRGB(206, 198, 184), M.concrete, FLAT)
	-- front wall split around two arches (8 wide, 10 tall), lintel band, side + back walls, gable roof
	local arches = { { 250, 258 }, { 264, 272 } }
	box(mh, "FrontWall", x0, 0.5, zf, arches[1][1], h, zf + 1, BRICK, M.brick)
	box(mh, "FrontWall", arches[1][2], 0.5, zf, arches[2][1], h, zf + 1, BRICK, M.brick)
	box(mh, "FrontWall", arches[2][2], 0.5, zf, x1, h, zf + 1, BRICK, M.brick)
	for _, a in ipairs(arches) do
		-- open arch: wall above, a stone frame around the opening (nothing blocks the doorway)
		box(mh, "OverArch", a[1], 10.5, zf, a[2], h, zf + 1, BRICK, M.brick)
		box(mh, "ArchFrame", a[1] - 0.6, 0.5, zf - 0.3, a[1], 10.5, zf, STONE, M.concrete, DECO)
		box(mh, "ArchFrame", a[2], 0.5, zf - 0.3, a[2] + 0.6, 10.5, zf, STONE, M.concrete, DECO)
		box(mh, "ArchFrame", a[1] - 0.6, 10.5, zf - 0.3, a[2] + 0.6, 11.2, zf, STONE, M.concrete, DECO)
	end
	box(mh, "WallWest", x0, 0.5, zf + 1, x0 + 1, h, zb, BRICK, M.brick)
	box(mh, "WallEast", x1 - 1, 0.5, zf + 1, x1, h, zb, BRICK, M.brick)
	box(mh, "WallBack", x0, 0.5, zb - 1, x1, h, zb, BRICK, M.brick)
	-- gable end on the front (pediment) + roof
	Kit.part(mh, "Pediment", Vector3.new(1, 7, (x1 - x0) / 2), CFrame.new(x0 + (x1 - x0) / 4, h + 3.5, zf + 0.5) * CFrame.Angles(0, math.rad(90), 0), BRICK, M.brick, { shape = "wedge" })
	Kit.part(mh, "Pediment", Vector3.new(1, 7, (x1 - x0) / 2), CFrame.new(x1 - (x1 - x0) / 4, h + 3.5, zf + 0.5) * CFrame.Angles(0, math.rad(-90), 0), BRICK, M.brick, { shape = "wedge" })
	gableZ(mh, x0 - 0.8, x1 + 0.8, zf + 1, zb + 0.6, h, 7, Color3.fromRGB(90, 94, 100)) -- starts behind the brick pediment (its end would hide it)
	-- stone name band + a row of round windows under the gable (photo 18)
	local band = box(mh, "NameBand", x0 + 3, 11.8, zf - 0.3, x1 - 3, 14.2, zf, STONE, M.concrete, DECO)
	label(band, Enum.NormalId.Front, "MARKET HALL", Color3.fromRGB(110, 92, 70), Enum.Font.Antique, 24)
	for k = 0, 4 do
		local wx = x0 + 7 + k * 4
		local wnd = Kit.part(mh, "RoundWindow", Vector3.new(0.3, 2, 2), CFrame.new(wx, h + 2, zf - 0.05) * CFrame.Angles(0, math.rad(90), 0), GLASS, M.glass,
			{ shape = "cyl", collide = false })
		wnd.CastShadow = false
	end
	-- inside: floor, two stall rows, hanging lights, and the parts stall at the back (CouponStall)
	box(mh, "HallFloor", x0 + 1, -1, zf + 1, x1 - 1, 0.6, zb - 1, Color3.fromRGB(176, 150, 120), M.concrete, FLAT)
	local produce = { Color3.fromRGB(220, 60, 50), Color3.fromRGB(250, 180, 50), Color3.fromRGB(110, 170, 70), Color3.fromRGB(240, 120, 40) }
	for i, sx in ipairs({ x0 + 1, x1 - 4 }) do
		for k = 0, 1 do
			local sz = zf + 8 + k * 9
			box(mh, "StallCounter", sx, 0.6, sz, sx + 3, 3.4, sz + 6, C.wood, M.wood)
			box(mh, "StallCrates", sx + 0.3, 3.4, sz + 0.5, sx + 2.7, 4.4, sz + 5.5, produce[(i + k) % #produce + 1], M.smooth, DECO)
		end
	end
	for _, lz in ipairs({ zf + 10, zf + 22 }) do
		box(mh, "HallLight", 256, 13.4, lz - 1, 266, 13.6, lz + 1, Color3.fromRGB(255, 240, 210), M.neon, DECO)
	end
	local cs = Kit.model(mh, "CouponStall")
	box(cs, "Counter", 254, 0.6, zb - 6, 268, 3.6, zb - 3, Color3.fromRGB(70, 90, 120), M.wood)
	box(cs, "Shelf", 254, 3.6, zb - 2.6, 268, 9, zb - 1.2, C.metalDark, M.metal)
	for k = 0, 4 do
		Kit.part(cs, "Gear", Vector3.new(0.4, 1.4, 1.4), CFrame.new(255.5 + k * 2.6, 5.4, zb - 1.9) * CFrame.Angles(0, math.rad(90), 0), if k % 2 == 0 then C.steel else C.yellow, M.metal,
			{ shape = "cyl", collide = false })
	end
	local sign = box(cs, "Sign", 255, 9.4, zb - 2.2, 267, 11.4, zb - 1.9, Color3.fromRGB(250, 246, 232), M.smooth, DECO)
	label(sign, Enum.NormalId.Front, "PARTS SWAP", Color3.fromRGB(200, 60, 40), Enum.Font.GothamBold, 24)
	-- reserved (world_contract ★ Gearport): the player stands here at the parts stall (daily coupon — wr-design / wr-dev)
	marker(cs, "PromptPoint", Vector3.new(261, 0.6, zb - 8), Vector3.new(0, 0, 1))
	-- long open market shed on the east side: posts + a roof + tables (the west wall stays open for the mural)
	for _, sh in ipairs({ { x1 + 0.5, 292 } }) do
		for _, pz in ipairs({ zf, zf + 16, zf + 32, -12 }) do
			for _, px in ipairs({ sh[1] + 0.6, sh[2] - 0.6 }) do
				Kit.post(mh, "ShedPost", px, pz, 0.5, 10, 0.6, C.metalDark, M.metal)
			end
		end
		box(mh, "ShedRoof", sh[1] - 0.5, 10, zf - 1, sh[2] + 0.5, 10.6, -11, Color3.fromRGB(70, 96, 88), M.metal)
		for k = 0, 2 do
			box(mh, "ShedTable", sh[1] + 3, 0.5, zf + 6 + k * 15, sh[2] - 3, 3, zf + 11 + k * 15, C.wood, M.wood)
		end
	end
	-- the side wall facing Chassis Street carries a mural (blank board, picture later from wr-art)
	LivedIn.artSlot(mh, "GP_MuralMarket", Vector3.new(x0 - 0.15, 8, (zf + zb) / 2), Vector3.new(-1, 0, 0), 26, 10)
	return mh
end

-- concrete-grid motor works (photos 9-11): long five-storey block facing the avenue (-Z) and Chassis St (-X)
local function motorWorks(ow: Instance)
	local m = Kit.model(ow, "MotorWorks")
	local x0, x1, z0, z1, h = 250, 400, 40, 92, 50
	box(m, "Body", x0 + 0.5, 0, z0 + 0.5, x1, h, z1, CONCRETE, M.concrete)
	box(m, "Cornice", x0 - 0.3, h, z0 - 0.3, x1 + 0.3, h + 1.2, z1 + 0.3, Color3.fromRGB(200, 198, 190), M.concrete)
	-- front (-Z) grid: glass behind, piers every 10, a spandrel band per floor
	box(m, "Glass", x0 + 0.5, 1, z0 + 0.3, x1, h, z0 + 0.5, GLASS, M.glass, DECO)
	for x = x0, x1, 10 do
		box(m, "Pier", x - 0.8, 0, z0 - 0.4, x + 0.8, h, z0 + 0.5, CONCRETE, M.concrete)
	end
	for f = 1, 5 do
		box(m, "Spandrel", x0, f * 10 - 2.6, z0 - 0.3, x1, f * 10, z0 + 0.5, CONCRETE, M.concrete, DECO)
	end
	-- west (-X) grid
	box(m, "Glass", x0 + 0.3, 1, z0 + 0.5, x0 + 0.5, h, z1, GLASS, M.glass, DECO)
	for z = z0 + 10, z1, 10 do
		box(m, "Pier", x0 - 0.4, 0, z - 0.8, x0 + 0.5, h, z + 0.8, CONCRETE, M.concrete)
	end
	for f = 1, 5 do
		box(m, "Spandrel", x0 - 0.3, f * 10 - 2.6, z0, x0 + 0.5, f * 10, z1, CONCRETE, M.concrete, DECO)
	end
	-- two dark (empty) panes — old, not ruined
	box(m, "DarkPane", 291, 21, z0 + 0.2, 299, 27.4, z0 + 0.3, Color3.fromRGB(34, 38, 44), M.smooth, DECO)
	box(m, "DarkPane", 351, 31, z0 + 0.2, 359, 37.4, z0 + 0.3, Color3.fromRGB(34, 38, 44), M.smooth, DECO)
	-- ground-floor loading doors (shut shutters — can't be entered)
	for _, dx in ipairs({ 272, 302, 332 }) do
		box(m, "LoadingDoor", dx - 4, 0, z0 - 0.5, dx + 4, 7.4, z0 - 0.3, SHUTTER, M.metal)
	end
	-- rooftop letter frame (photo 10) + water tank on legs (photo 15)
	for _, lx in ipairs({ 290, 325, 360 }) do
		box(m, "SignLeg", lx - 0.3, h + 1.2, z0 + 3, lx + 0.3, h + 6, z0 + 3.6, C.metalDark, M.metal, DECO)
	end
	local frame = box(m, "RoofSign", 276, h + 6, z0 + 3, 374, h + 13, z0 + 3.4, Color3.fromRGB(46, 50, 58), M.metal, DECO)
	label(frame, Enum.NormalId.Front, "GEARPORT MOTOR WORKS", Color3.fromRGB(250, 246, 232), Enum.Font.GothamBlack, 12)
	label(frame, Enum.NormalId.Back, "GEARPORT MOTOR WORKS", Color3.fromRGB(250, 246, 232), Enum.Font.GothamBlack, 12) -- (reads right from behind too)
	local tx, tz = 384, 78
	for _, o in ipairs({ { -3, -3 }, { 3, -3 }, { -3, 3 }, { 3, 3 } }) do
		box(m, "TankLeg", tx + o[1] - 0.3, h + 1.2, tz + o[2] - 0.3, tx + o[1] + 0.3, h + 10, tz + o[2] + 0.3, Color3.fromRGB(110, 90, 70), M.wood)
	end
	Kit.post(m, "Tank", tx, tz, h + 10, h + 19, 9, Color3.fromRGB(140, 104, 76), M.wood)
	Kit.part(m, "TankRoof", Vector3.new(9.6, 3.6, 9.6), CFrame.new(tx, h + 19.4, tz), Color3.fromRGB(80, 76, 72), M.metal, { shape = "ball" })
	return m
end

-- brick factory with a big mural wall to Chassis Street (photo 11)
local function brickFactory(ow: Instance)
	local m = Kit.model(ow, "BrickFactory")
	local x0, x1, z0, z1, h = 250, 330, 120, 168, 40
	box(m, "Body", x0, 0, z0, x1, h, z1, BRICK2, M.brick)
	box(m, "Cornice", x0 - 0.3, h, z0 - 0.3, x1 + 0.3, h + 1, z1 + 0.3, STONE, M.concrete)
	for f = 0, 3 do
		local y = 3 + f * 9.5
		box(m, "WindowBand", x0 + 3, y, z0 - 0.2, x1 - 3, y + 5.6, z0, GLASS, M.glass, DECO)
		box(m, "Sill", x0 + 2.6, y - 0.5, z0 - 0.5, x1 - 2.6, y, z0, STONE, M.concrete, DECO)
	end
	local plate = box(m, "NamePlate", x0 + 20, h - 4, z0 - 0.3, x1 - 20, h - 1, z0, STONE, M.concrete, DECO)
	label(plate, Enum.NormalId.Front, "1914 · GEARPORT BODY CO.", Color3.fromRGB(110, 92, 70), Enum.Font.Antique, 24)
	LivedIn.artSlot(m, "GP_MuralWorks", Vector3.new(x0 - 0.15, 18, (z0 + z1) / 2), Vector3.new(-1, 0, 0), 40, 22)
	return m
end

-- sawtooth-roof shed (photos 14, 26-27): a low body, then teeth along X — each a sloped roof rising toward -X with
-- a vertical glass face on its high side. Teeth run across Foundry Road's view, so from the road you see the zigzag
-- profile and every tooth's glass (main review: teeth along Z read as one long blue wall)
local function sawtoothShed(ow: Instance, name: string, x0: number, x1: number, z0: number, z1: number, teeth: number)
	local m = Kit.model(ow, name)
	local h = 14
	box(m, "Body", x0, 0, z0, x1, h, z1, Color3.fromRGB(176, 108, 84), M.brick)
	local L = (x1 - x0) / teeth
	for k = 0, teeth - 1 do
		local tx = x0 + k * L
		-- wedge rises toward local +Z; turned -90 so it rises toward -X: the glass faces west, toward Chassis St
		Kit.part(m, "Tooth", Vector3.new(z1 - z0, 6, L), CFrame.new(tx + L / 2, h + 3, (z0 + z1) / 2) * CFrame.Angles(0, math.rad(-90), 0), Color3.fromRGB(168, 172, 176), M.metal,
			{ shape = "wedge" })
		box(m, "NorthLight", tx - 0.05, h + 0.4, z0 + 0.4, tx + 0.05, h + 5.8, z1 - 0.4, GLASS, M.glass, DECO)
	end
	-- shut sliding doors on the road end
	box(m, "SlidingDoor", x0 + 6, 0, z1, x0 + 20, 10, z1 + 0.4, SHUTTER, M.metal)
	return m
end

-- four smokestacks in a row (photo 13) — one small Persistent model so they read from anywhere on the map
local function stacks(ow: Instance)
	local s = Kit.model(ow, "Smokestacks")
	s.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	box(s, "StackBase", 396, 0, 240, 446, 6, 256, BRICK2, M.brick)
	for i, hgt in ipairs({ 84, 94, 88, 78 }) do
		local x = 400 + (i - 1) * 13
		Kit.post(s, "Stack", x, 248, 6, hgt, 7, Color3.fromRGB(150, 92, 72), M.brick)
		Kit.post(s, "StackBand", x, 248, hgt - 6, hgt - 4, 7.6, Color3.fromRGB(226, 220, 210), M.concrete, DECO)
	end
	return s
end

-- rail yard along the junkyard's east fence: two sidings, boxcars, flatcars (decks = spots for background cars)
local function railYard(ow: Instance)
	local ry = Kit.model(ow, "RailYard")
	box(ry, "Gravel", 148, -1, 214, 200, 0.15, 380, Color3.fromRGB(140, 132, 122), M.concrete, FLAT)
	local spots = Kit.folder(ry, "BundleCarSpots")
	for i, tx in ipairs({ 160, 184 }) do
		box(ry, "Ballast", tx - 5, 0.15, 216, tx + 5, 0.4, 378, Color3.fromRGB(156, 148, 136), M.concrete, FLAT)
		-- dark sleepers under two clear rails (main review: from above the rails hardly showed)
		for tz = 218, 376, 5 do
			box(ry, "Sleeper", tx - 3.6, 0.4, tz - 0.5, tx + 3.6, 0.6, tz + 0.5, Color3.fromRGB(74, 54, 42), M.wood, { collide = false, shadow = false })
		end
		for _, rx in ipairs({ tx - 2.4, tx + 2.4 }) do
			box(ry, "Rail", rx - 0.3, 0.6, 216, rx + 0.3, 1.0, 378, Color3.fromRGB(96, 98, 104), M.metal, DECO)
		end
		box(ry, "BufferStop", tx - 3, 0.4, 374, tx + 3, 3.4, 378, C.red, M.metal)
		if i == 1 then
			for k, bz in ipairs({ 250, 290 }) do
				box(ry, "Boxcar", tx - 4.2, 1.6, bz, tx + 4.2, 12, bz + 30, if k == 1 then Color3.fromRGB(150, 70, 50) else Color3.fromRGB(70, 90, 110), M.metal)
				box(ry, "BoxcarRoof", tx - 4.4, 12, bz - 0.2, tx + 4.4, 12.6, bz + 30.2, Color3.fromRGB(80, 82, 88), M.metal, DECO)
				box(ry, "Bogies", tx - 3.6, 0.8, bz + 2, tx + 3.6, 1.6, bz + 28, C.rubber, M.metal)
			end
		else
			for k, fz in ipairs({ 240, 280, 320 }) do
				box(ry, "FlatcarDeck", tx - 4.2, 2.4, fz, tx + 4.2, 3.2, fz + 30, Color3.fromRGB(96, 86, 76), M.wood)
				box(ry, "Bogies", tx - 3.6, 0.8, fz + 2, tx + 3.6, 2.4, fz + 28, C.rubber, M.metal)
				-- where a background (bundle) car can sit on the deck: Position = deck top, facing +Z
				marker(spots, "Spot" .. k, Vector3.new(tx, 3.2, fz + 15), Vector3.new(0, 0, 1), Vector3.new(7.6, 0.2, 17))
				-- new cars being shipped: a background car on each deck, facing +Z (60+ studs from the roads)
				GearportProps.mesh(ry, ({ "BG_Compact_1", "BG_Sedan_2", "BG_Sedan_4" })[k], tx, 3.2, fz + 15, GearportProps.facing(0, 1), true)
			end
		end
	end
	return ry
end

local function foundryRoad(town: Instance)
	local fr = Kit.folder(town, "FoundryRoad")
	box(fr, "Road", 148, -1, 196, X0, 0, 212, C.asphalt, M.asphalt, FLAT)
	box(fr, "Road", X1, -1, 196, MX1, 0, 212, C.asphalt, M.asphalt, FLAT)
	box(fr, "Sidewalk", 148, -1, 192, X0 - 4, 0.5, 196, C.sidewalk, M.concrete)
	box(fr, "Sidewalk", X1 + 4, -1, 192, MX1, 0.5, 196, C.sidewalk, M.concrete)
	for x = 156, MX1 - 8, 20 do
		if x < X0 - 4 or x > X1 + 4 then
			box(fr, "CentreDash", x - 3, 0, 203.85, x + 3, 0.05, 204.15, C.lineYellow, M.smooth, DECO)
		end
	end
	local sg = Kit.part(fr, "StreetName", Vector3.new(0.12, 1.1, 5.6), CFrame.lookAt(Vector3.new(X1 + 2, 10, 194), Vector3.new(X1 + 3, 10, 194)), Color3.fromRGB(30, 120, 70), M.smooth, DECO)
	Kit.label(sg, Enum.NormalId.Left, "FOUNDRY RD", Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
	Kit.label(sg, Enum.NormalId.Right, "FOUNDRY RD", Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
	Kit.post(fr, "SignPost", X1 + 2, 194, 0.5, 10.6, 0.3, C.steel, M.metal)
end

function Works.build(garage: Model)
	local town = garage:FindFirstChild("Town") or Kit.folder(garage, "Town")
	marketHall(town)
	foundryRoad(town)
	local ow = Kit.model(town, "OldWorks")
	box(ow, "WorksYard", 236, -1, 24, MX1, 0.05, 192, Color3.fromRGB(150, 146, 138), M.concrete, FLAT)
	box(ow, "WorksYard", 236, -1, 212, MX1, 0.05, 470, Color3.fromRGB(150, 146, 138), M.concrete, FLAT)
	motorWorks(ow)
	brickFactory(ow)
	sawtoothShed(ow, "SawtoothShedEast", 342, 462, 112, 186, 4)
	sawtoothShed(ow, "SawtoothShedNorth", 250, 380, 222, 300, 4)
	stacks(ow)
	railYard(ow)
end

return Works
