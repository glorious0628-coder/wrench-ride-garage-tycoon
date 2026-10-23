--!strict
-- World/Gearport (wr-builder): the made-up motor city around the shop (plan: notes/design/detroit_town_plan.md,
-- photos: notes/research/ref_detroit/index.md). Stage 1 = Piston Avenue: the old road becomes the eastbound half of a
-- wide boulevard, a planted median with banner lamps, a westbound half with parked cars, a far sidewalk and a row of
-- two / three storey brick shops (awnings, painted wall signs, two vacant lots with mural walls), two small rival
-- garages and an old enamel-panel fuel station at the corner. Looks only: no contract markers, the shop block and the
-- customer lane (z -79.5) are untouched. Same few shapes reused, each copy sized / coloured a little differently.

local Kit = require(script.Parent.Kit)
local Site = require(script.Parent.Site)
local LivedIn = require(script.Parent.LivedIn)
local C, M = Kit.C, Kit.M
local box = Kit.box

local Gearport = {}

-- avenue layout (z): old road -96..-74 (eastbound now), median -104..-96, westbound -126..-104, far sidewalk -134..-126
local MED_Z0, MED_Z1 = -104, Site.ROAD_Z0
local SR_Z0, SR_Z1 = -126, MED_Z0
local SW_Z0, SW_Z1 = -134, SR_Z0
local FRONT = SW_Z0 -- shop fronts sit right on the sidewalk (no front yards)
local DEPTH = 28
local W, E = Site.MAP_X0, Site.MAP_X1
local X0, X1 = Site.CROSS_X0, Site.CROSS_X1
-- gaps in the median: the mid-block crosswalk in front of the shop and the corner crosswalk
local CUTS = { { 22, 30 }, { 192, 202 }, { X0, X1 } }
local OUTLINE = Color3.fromRGB(28, 30, 40)
local DECO = { collide = false } -- flush / high-up decoration: no collision (less physics memory)

-- text label at a lower resolution than Kit's default 40 px/stud (big signs cost texture memory)
local function sign(part: BasePart, face: Enum.NormalId, text: string, color: Color3, stroke: Color3?, font: Enum.Font?, pps: number): SurfaceGui
	local gui = Kit.label(part, face, text, color, stroke, font)
	gui.PixelsPerStud = pps
	return gui
end

-- bright orange-red brick family (style_B: a little lighter than real Detroit brick), cream brick, stone
local BRICK = {
	Color3.fromRGB(206, 104, 74), Color3.fromRGB(194, 96, 70), Color3.fromRGB(216, 126, 88), Color3.fromRGB(188, 112, 86),
	Color3.fromRGB(212, 114, 80),
}
local CREAM = Color3.fromRGB(226, 204, 166)
local STONE = Color3.fromRGB(232, 222, 198)
local WINDOW = Color3.fromRGB(78, 104, 132)
local INTERIOR = Color3.fromRGB(236, 222, 196) -- warm lit shop inside (behind the glass, in front of the brick)
local FRAME_WHITE = Color3.fromRGB(246, 244, 236)
local GOODS = { Color3.fromRGB(214, 70, 60), Color3.fromRGB(60, 120, 200), Color3.fromRGB(244, 186, 50), Color3.fromRGB(70, 160, 100),
	Color3.fromRGB(170, 90, 170) }
local STOREFRONT = Color3.fromRGB(128, 168, 192) -- (rival garage office window: opaque)
local BLIND = Color3.fromRGB(226, 214, 186)

-- a door that can't be opened reads as closed: blind pulled down + a small CLOSED plate (no mat, no handle)
local function closedDoor(m: Instance, x0: number, x1: number, y0: number, y1: number, zFace: number)
	box(m, "DoorBlind", x0 + 0.3, y0 + 0.8, zFace, x1 - 0.3, y1 - 0.6, zFace + 0.05, BLIND, M.fabric, DECO)
	local cx = (x0 + x1) / 2
	local plate = box(m, "ClosedSign", cx - 1.1, y0 + 3.6, zFace + 0.05, cx + 1.1, y0 + 4.6, zFace + 0.1, Color3.fromRGB(250, 250, 246), M.smooth, DECO)
	sign(plate, Enum.NormalId.Back, "CLOSED", Color3.fromRGB(200, 40, 40), nil, Enum.Font.GothamBold, 24)
end
local AWNINGS = {
	{ Color3.fromRGB(206, 44, 38), Color3.fromRGB(250, 248, 240) },
	{ Color3.fromRGB(40, 120, 90), Color3.fromRGB(240, 236, 220) },
	{ Color3.fromRGB(44, 98, 190), Color3.fromRGB(250, 248, 240) },
	{ Color3.fromRGB(236, 150, 40), Color3.fromRGB(250, 246, 230) },
	{ Color3.fromRGB(120, 60, 120), Color3.fromRGB(240, 230, 240) },
}
local CITY_BLUE = Color3.fromRGB(40, 86, 170)
local CITY_ORANGE = Color3.fromRGB(232, 128, 40)

-- x pieces of [a, b] left after cutting out CUTS
local function pieces(a: number, b: number): { { number } }
	local out = { { a, b } }
	for _, c in ipairs(CUTS) do
		local nxt = {}
		for _, s in ipairs(out) do
			if c[2] <= s[1] or c[1] >= s[2] then
				table.insert(nxt, s)
			else
				if c[1] > s[1] then
					table.insert(nxt, { s[1], c[1] })
				end
				if c[2] < s[2] then
					table.insert(nxt, { c[2], s[2] })
				end
			end
		end
		out = nxt
	end
	return out
end

local function inCut(x: number, pad: number): boolean
	for _, c in ipairs(CUTS) do
		if x > c[1] - pad and x < c[2] + pad then
			return true
		end
	end
	return false
end

-- median street tree: tall clear trunk, canopy from y ~13 up, so shop signs and awnings stay in view (main review)
local function streetTree(parent: Instance, x: number, z: number, seed: number)
	local r = Kit.rng(seed)
	local m = Kit.model(parent, "Tree")
	Kit.post(m, "Trunk", x, z, 0.6, 16.5, 0.9, Color3.fromRGB(116, 84, 60), M.wood)
	local leaf = { Color3.fromRGB(86, 150, 70), Color3.fromRGB(104, 166, 78), Color3.fromRGB(74, 136, 66) }
	for k = 1, 3 do
		local a = r() * math.pi * 2
		local sz = 7 + r() * 2
		Kit.part(m, "Leaves", Vector3.new(sz, sz * 0.8, sz), CFrame.new(x + math.cos(a) * 1.4, 17.4 + (k - 1) * 1.5, z + math.sin(a) * 1.4),
			leaf[(seed + k) % #leaf + 1], M.grass, { shape = "ball", shadow = k == 1 })
	end
end

-- no median tree in front of these (the rival garages' pole signs and the fuel station must read from the shop)
local TREE_SKIP = { { -440, -296 }, { -184, -138 }, { 54, 100 }, { 196, 300 } } -- (first: Union Depot front)

-- banner lamp for the median: black pole, lamp head, one city banner (GEARPORT)
local function bannerLamp(parent: Instance, x: number, z: number, i: number)
	local m = Kit.model(parent, "BannerLamp")
	Kit.post(m, "Pole", x, z, 0.6, 20, 0.6, C.metalDark, M.metal)
	Kit.post(m, "Base", x, z, 0.6, 1.8, 1.1, C.metalDark, M.metal)
	-- big street: black pole, milky glass globe (street_props.md B3 3-4)
	Kit.part(m, "Globe", Vector3.new(2.2, 2.2, 2.2), CFrame.new(x, 21, z), Color3.fromRGB(255, 244, 222), M.neon, { collide = false, shape = "ball" })
	Kit.post(m, "Finial", x, z, 21.9, 22.6, 0.6, C.metalDark, M.metal, DECO)
	local flag = box(m, "Banner", x + 0.35, 11.5, z - 0.05, x + 2.75, 16.5, z + 0.05, if i % 2 == 0 then CITY_BLUE else CITY_ORANGE, M.fabric,
		{ collide = false })
	sign(flag, Enum.NormalId.Front, "GEAR\nPORT", Color3.new(1, 1, 1), nil, nil, 16)
	sign(flag, Enum.NormalId.Back, "GEAR\nPORT", Color3.new(1, 1, 1), nil, nil, 16)
end

local function avenue(town: Instance)
	local av = Kit.folder(town, "PistonAvenue")
	-- planted median with gaps for the crosswalks / the cross street; refuge pads in the crosswalk gaps
	for _, p in ipairs(pieces(W, E)) do
		box(av, "Median", p[1], -1, MED_Z0, p[2], 0.5, MED_Z1, C.curb, M.concrete)
		box(av, "MedianGrass", p[1] + 0.6, 0.5, MED_Z0 + 0.6, p[2] - 0.6, 0.6, MED_Z1 - 0.6, C.grass, M.grass)
	end
	box(av, "Refuge", 22, -1, MED_Z0, 30, 0.1, MED_Z1, C.concrete, M.concrete)
	box(av, "Refuge", 192, -1, MED_Z0, X0, 0.1, MED_Z1, C.concrete, M.concrete)
	local r = Kit.rng(1301)
	local n = 0
	for x = W + 16, E - 16, 36 do
		local skip = inCut(x, 6)
		for _, t in ipairs(TREE_SKIP) do
			skip = skip or (x > t[1] and x < t[2])
		end
		n += 1
		if not skip then
			streetTree(av, x + (r() - 0.5) * 3, -100, 1300 + n)
		end
		local lx = x + 18
		if lx < E - 8 and not inCut(lx, 4) then
			bannerLamp(av, lx, -100, n)
		end
	end
	-- westbound half: asphalt (the cross street has its own), dashed lane line, yellow left edge by the median
	for _, s in ipairs({ { W, X0 }, { X1, E } }) do
		box(av, "Road", s[1], -1, SR_Z0, s[2], 0, SR_Z1, C.asphalt, M.asphalt)
		box(av, "EdgeLine", s[1], 0, SR_Z1 - 0.9, s[2], 0.05, SR_Z1 - 0.6, C.lineYellow, M.smooth, { collide = false })
	end
	for x = W + 6, E - 6, 18 do
		if not inCut(x, 4) then
			box(av, "LaneDash", x - 3, 0, -115.15, x + 3, 0.05, -114.85, C.lineWhite, M.smooth, { collide = false })
		end
	end
	-- crosswalk bars across the westbound half (corner + mid-block) and the eastbound half (mid-block)
	for z = SR_Z0 + 1.2, SR_Z1 - 2, 2.4 do
		box(av, "Crosswalk", X0 - 10, 0, z, X0 - 2, 0.05, z + 1.2, C.lineWhite, M.smooth, { collide = false })
		box(av, "Crosswalk", 22, 0, z, 30, 0.05, z + 1.2, C.lineWhite, M.smooth, { collide = false })
	end
	for z = -94.6, -76, 2.4 do
		box(av, "Crosswalk", 22, 0, z, 30, 0.05, z + 1.2, C.lineWhite, M.smooth, { collide = false })
	end
	-- far sidewalk + curb (the cross street keeps its own corner squares)
	for _, s in ipairs({ { W, X0 }, { X1, E } }) do
		box(av, "Sidewalk", s[1], -1, SW_Z0, s[2], 0.5, SW_Z1, C.sidewalk, M.concrete)
		box(av, "Curb", s[1], -1, SW_Z1, s[2], 0.5, SW_Z1 + 0.5, C.curb, M.concrete)
	end
	-- back alley behind the shop row
	box(av, "Alley", -276, -1, FRONT - DEPTH - 8, X0 - 4, 0, FRONT - DEPTH, C.asphaltWorn, M.asphalt) -- (west of -276: Union Depot)
	return av
end

-- painted wall sign on a side wall (faded letters, no board): face = side the wall looks at
local function ghostSign(parent: Instance, x: number, z0: number, z1: number, y0: number, y1: number, face: number, text: string)
	local p = box(parent, "GhostSign", x - 0.05, y0, z0, x + 0.05, y1, z1, CREAM, M.smooth, { collide = false, transparency = 1 })
	p.CanQuery = false
	p.CanTouch = false
	local gui = sign(p, if face > 0 then Enum.NormalId.Right else Enum.NormalId.Left, text, Color3.fromRGB(246, 236, 214), nil, Enum.Font.Bangers, 10)
	local t = gui:FindFirstChildOfClass("TextLabel") :: TextLabel
	t.TextTransparency = 0.25
end

export type ShopSpec = {
	name: string, x0: number, x1: number, storeys: number, wall: Color3, awning: number, word: string, seed: number,
	cornice: Color3?,
	plate: string?, -- carved name / date on a raised parapet
	aframe: string?, -- A-frame sidewalk sign text
}

-- a brick storefront building facing +Z with its front on the sidewalk (photos 2-4)
local function shopBuilding(parent: Instance, s: ShopSpec): Model
	local r = Kit.rng(s.seed)
	local m = Kit.model(parent, s.name)
	local x0, x1 = s.x0, s.x1
	local zf, z0 = FRONT, FRONT - DEPTH
	local h = 13 + (s.storeys - 1) * 9
	local trimCol = s.cornice or STONE
	box(m, "Body", x0, 0, z0, x1, h, zf, s.wall, M.brick)
	box(m, "Cornice", x0 - 0.3, h, z0, x1 + 0.3, h + 0.8, zf + 0.6, trimCol, M.concrete)
	if s.plate then
		-- raised parapet with a carved stone name / date plate (the cheapest real Detroit clue: "1923 · ... BLOCK")
		local mid = (x0 + x1) / 2
		local pw = math.min(20, x1 - x0 - 4)
		box(m, "Parapet", mid - pw / 2 - 1, h + 0.8, zf - 0.8, mid + pw / 2 + 1, h + 5.2, zf, s.wall, M.brick)
		box(m, "ParapetCap", mid - pw / 2 - 1.3, h + 5.2, zf - 1.1, mid + pw / 2 + 1.3, h + 5.8, zf + 0.3, trimCol, M.concrete)
		local plate = box(m, "NamePlate", mid - pw / 2, h + 1.4, zf, mid + pw / 2, h + 4.6, zf + 0.25, STONE, M.concrete, DECO)
		sign(plate, Enum.NormalId.Back, s.plate, Color3.fromRGB(116, 98, 78), nil, Enum.Font.Antique, 24)
	elseif s.seed % 3 == 0 then
		local mid = (x0 + x1) / 2
		box(m, "Parapet", mid - 4, h + 0.8, zf - 0.6, mid + 4, h + 2.8, zf, s.wall, M.brick)
	end
	box(m, "Base", x0, 0, zf, x1, 1.6, zf + 0.25, C.plinth, M.concrete)
	-- storefront (main review: an opaque sheet read as a closed shop): framed opening with depth, a warm lit inside,
	-- a display shelf with goods and an OPEN sign behind see-through glass, then mullions + door
	local gx0, gx1 = x0 + 1.8, x1 - 1.8
	box(m, "Interior", gx0, 1.6, zf, gx1, 9.6, zf + 0.05, INTERIOR, M.smooth, DECO)
	box(m, "DisplayShelf", gx0 + 0.6, 3.0, zf + 0.05, gx1 - 0.6, 3.4, zf + 0.12, C.wood, M.wood, DECO)
	box(m, "DisplayGoods", gx0 + 1.4, 3.4, zf + 0.05, gx1 - 1.4, 5.8, zf + 0.1, GOODS[s.seed % #GOODS + 1], M.smooth, DECO)
	box(m, "Glass", gx0, 1.6, zf + 0.15, gx1, 9.6, zf + 0.25, C.glass, M.glass, { transparency = 0.6 })
	box(m, "FrameHead", gx0 - 0.4, 9.6, zf, gx1 + 0.4, 10.1, zf + 0.6, C.frame, M.metal, DECO)
	box(m, "FrameSill", gx0 - 0.4, 1.3, zf, gx1 + 0.4, 1.7, zf + 0.7, C.frame, M.metal, DECO)
	box(m, "FrameJamb", gx0 - 0.4, 1.6, zf, gx0, 9.6, zf + 0.6, C.frame, M.metal, DECO)
	box(m, "FrameJamb", gx1, 1.6, zf, gx1 + 0.4, 9.6, zf + 0.6, C.frame, M.metal, DECO)
	local nm = if (gx1 - gx0) > 18 then 2 else 1
	for k = 1, nm do
		local mx = gx0 + (gx1 - gx0) * k / (nm + 1)
		box(m, "Mullion", mx - 0.2, 1.6, zf, mx + 0.2, 9.6, zf + 0.45, C.frame, M.metal, DECO)
	end
	local dx = if s.seed % 2 == 0 then gx0 + 2.6 else gx1 - 2.6
	box(m, "Door", dx - 1.6, 0.5, zf, dx + 1.6, 8.6, zf + 0.4, C.frame, M.metal, DECO)
	closedDoor(m, dx - 1.6, dx + 1.6, 0.5, 8.6, zf + 0.4) -- shops can't be entered (no "come in" signals at the door)
	-- window neon = what the shop sells (a display, not an OPEN invitation)
	local ox = if s.seed % 2 == 0 then gx1 - 3 else gx0 + 3
	local neon = box(m, "WindowNeon", ox - 2, 6.4, zf + 0.26, ox + 2, 7.6, zf + 0.3, AWNINGS[(s.awning - 1) % #AWNINGS + 1][1], M.neon, DECO)
	sign(neon, Enum.NormalId.Back, s.word, Color3.new(1, 1, 1), nil, Enum.Font.GothamBlack, 24)
	-- sidewalk life in front of the display window only (never at the door): planter, A-frame sign
	if s.seed % 4 == 1 then
		local px = ox + (if s.seed % 2 == 0 then -3 else 3)
		Kit.post(m, "Planter", px, zf + 1.4, 0.5, 2.3, 1.8, Color3.fromRGB(150, 110, 84), M.concrete)
		Kit.part(m, "PlanterBush", Vector3.new(2.2, 1.8, 2.2), CFrame.new(px, 2.9, zf + 1.4), Color3.fromRGB(96, 156, 72), M.grass, { shape = "ball", collide = false })
	end
	if s.aframe then
		local ax = ox
		for k = -1, 1, 2 do
			local panel = Kit.part(m, "AFrame", Vector3.new(2.2, 3.2, 0.12), CFrame.new(ax, 2.05, zf + 4 + k * 0.45) * CFrame.Angles(math.rad(k * 14), 0, 0),
				Color3.fromRGB(40, 44, 50), M.smooth, DECO)
			sign(panel, if k < 0 then Enum.NormalId.Front else Enum.NormalId.Back, s.aframe, Color3.new(1, 1, 1), nil, Enum.Font.PermanentMarker, 24)
		end
	end
	-- awning: one slanted sheet + a stripe-coloured valance
	local aw = AWNINGS[(s.awning - 1) % #AWNINGS + 1]
	local depth = 3.2 + r() * 1.2
	Kit.part(m, "Awning", Vector3.new(gx1 - gx0, 0.3, depth + 0.4), CFrame.new((gx0 + gx1) / 2, 10.2, zf + depth / 2) * CFrame.Angles(math.rad(18), 0, 0),
		aw[1], M.fabric)
	box(m, "AwningValance", gx0, 8.5, zf + depth - 0.1, gx1, 9.8, zf + depth + 0.15, aw[1], M.fabric, { collide = false })
	box(m, "ValanceStripe", gx0, 9.1, zf + depth + 0.15, gx1, 9.4, zf + depth + 0.2, aw[2], M.smooth, DECO)
	local band = box(m, "SignBand", gx0 + 1, 10.7, zf, gx1 - 1, 13.0, zf + 0.35, Color3.fromRGB(250, 248, 240), M.smooth, DECO)
	sign(band, Enum.NormalId.Back, s.word, aw[1], OUTLINE, nil, 24)
	-- upper floors: a stone belt course + a row of windows with stone lintels
	local wn = math.max(2, math.floor((x1 - x0) / 8))
	for k = 2, s.storeys do
		local yb = 13 + (k - 2) * 9
		if k == 2 then
			box(m, "Belt", x0, yb - 0.4, zf, x1, yb + 0.2, zf + 0.35, trimCol, M.concrete, DECO)
		end
		for j = 0, wn - 1 do
			local wx = x0 + (x1 - x0) * (j + 0.5) / wn
			box(m, "WindowFrame", wx - 2.0, yb + 1.3, zf, wx + 2.0, yb + 6.9, zf + 0.15, FRAME_WHITE, M.smooth, DECO)
			box(m, "Window", wx - 1.6, yb + 1.7, zf + 0.15, wx + 1.6, yb + 6.5, zf + 0.22, WINDOW, M.glass, DECO)
			box(m, "Sill", wx - 2.3, yb + 0.9, zf, wx + 2.3, yb + 1.3, zf + 0.55, trimCol, M.concrete, DECO)
			if s.seed % 2 == 1 then
				box(m, "Lintel", wx - 2.2, yb + 6.9, zf, wx + 2.2, yb + 7.5, zf + 0.35, trimCol, M.concrete, DECO)
			end
		end
	end
	if r() < 0.4 then
		local ax = x0 + 3 + r() * (x1 - x0 - 9)
		box(m, "RoofAC", ax, h + 0.8, z0 + 6, ax + 4, h + 3, z0 + 11, C.steel, M.metal, DECO)
	end
	return m
end

-- a small rival garage: one storey, two roll-up doors, office window, pole sign with a letter board (photo 25)
local function rivalGarage(parent: Instance, name: string, x0: number, x1: number, wall: Color3, word: string, board: string, _seed: number)
	local m = Kit.model(parent, name)
	local zf, z0 = FRONT, FRONT - DEPTH
	local h = 15
	box(m, "Body", x0, 0, z0, x1, h, zf, wall, M.brick)
	box(m, "Cornice", x0 - 0.3, h, z0, x1 + 0.3, h + 0.7, zf + 0.5, C.trim, M.concrete)
	box(m, "Base", x0, 0, zf, x1, 1.2, zf + 0.25, C.plinth, M.concrete)
	local doorW = 9
	for k = 0, 1 do
		local dx0 = x0 + 2 + k * (doorW + 1.5)
		local door = box(m, "RollUpDoor", dx0, 0.5, zf, dx0 + doorW, 10, zf + 0.3, C.shutter, M.metal)
		door.Material = M.metal
		box(m, "DoorHead", dx0 - 0.4, 10, zf, dx0 + doorW + 0.4, 10.6, zf + 0.5, C.trim, M.metal, DECO)
	end
	local ox0 = x0 + 2 + 2 * (doorW + 1.5)
	box(m, "OfficeGlass", ox0, 2.5, zf, x1 - 1.6, 9, zf + 0.2, STOREFRONT, M.glass)
	closedDoor(m, ox0 + 0.5, math.min(ox0 + 4, x1 - 2), 1.2, 9, zf + 0.2)
	local band = box(m, "SignBand", x0 + 2, 11.2, zf, x1 - 2, 14.2, zf + 0.35, Color3.fromRGB(250, 248, 240), M.smooth, DECO)
	sign(band, Enum.NormalId.Back, word, C.red, OUTLINE, nil, 24)
	-- pole sign at the front corner (on the sidewalk, by the building)
	local px = x1 - 1.5
	Kit.post(m, "SignPole", px, SW_Z0 + 1.2, 0.5, 18, 0.6, C.metalDark, M.metal) -- behind the board, not through the letters
	local b = box(m, "LetterBoard", px - 4, 12, SW_Z0 + 1.85, px + 4, 16.4, SW_Z0 + 2.15, Color3.fromRGB(250, 250, 244), M.smooth)
	sign(b, Enum.NormalId.Back, board, Color3.fromRGB(30, 30, 36), nil, Enum.Font.GothamBold, 24)
	sign(b, Enum.NormalId.Front, board, Color3.fromRGB(30, 30, 36), nil, Enum.Font.GothamBold, 24)
	box(m, "BoardTop", px - 4.3, 16.4, SW_Z0 + 1.7, px + 4.3, 17.2, SW_Z0 + 2.3, C.red, M.smooth, DECO)
	-- (used tyres by the pole: 3D tyre stacks, World/GearportProps)
	return m
end

-- the old enamel-panel fuel station on the SE corner (photo 24): two bays, a striped centre tower, office, two pumps
local function fuelStation(parent: Instance)
	local m = Kit.model(parent, "FuelStation")
	local mint = Color3.fromRGB(196, 230, 206)
	local green = Color3.fromRGB(46, 128, 84)
	local x0, x1, zf, z0 = 230, 268, -150, -164
	box(m, "Apron", X1 + 4, -1, z0, 276, 0.5, SW_Z0, C.concrete, M.concrete)
	box(m, "Body", x0, 0.5, z0, x1, 13.4, zf, mint, M.smooth)
	box(m, "Band", x0 - 0.2, 10.6, zf, x1 + 0.2, 11.4, zf + 0.25, green, M.smooth)
	box(m, "Cap", x0 - 0.3, 13.4, z0, x1 + 0.3, 14, zf + 0.4, green, M.smooth)
	box(m, "Base", x0, 0.5, zf, x1, 1.4, zf + 0.25, green, M.smooth)
	-- two service bays (west), office (east)
	for k = 0, 1 do
		local bx = x0 + 1.5 + k * 8.5
		box(m, "BayDoor", bx, 0.5, zf, bx + 7.5, 9.2, zf + 0.2, Color3.fromRGB(70, 96, 112), M.glass, { transparency = 0.1 })
	end
	box(m, "OfficeGlass", 254, 2.5, zf, x1 - 1.5, 9.2, zf + 0.2, STOREFRONT, M.glass)
	box(m, "OfficeDoor", 254.5, 0.5, zf, 257.5, 8.4, zf + 0.3, green, M.smooth)
	closedDoor(m, 254.5, 257.5, 0.5, 8.4, zf + 0.3)
	-- centre tower with vertical fins, round sign
	box(m, "Tower", 247, 0.5, zf - 1, 253, 22, zf + 1, mint, M.smooth) -- tall enough that the round sign clears the canopy
	for k = 0, 2 do
		local fx = 248.2 + k * 1.8
		box(m, "Fin", fx - 0.25, 13.4, zf + 1, fx + 0.25, 21.4, zf + 1.4, green, M.smooth, DECO)
	end
	box(m, "TowerCap", 246.6, 22, zf - 1.4, 253.4, 22.8, zf + 1.4, green, M.smooth)
	local disc = Kit.part(m, "RoundSign", Vector3.new(0.4, 5, 5), CFrame.new(250, 17.6, zf + 1.6) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(250, 248, 240),
		M.smooth, { shape = "cyl" })
	sign(disc, Enum.NormalId.Left, "FUEL", green, nil, nil, 24) -- (cylinder turned: its Left face looks at the street)
	local letters = box(m, "Lettering", x0 + 1, 11.5, zf, 246.5, 13.3, zf + 0.3, green, M.smooth, DECO)
	letters.Transparency = 1
	sign(letters, Enum.NormalId.Back, "AVENUE FUEL", green, nil, Enum.Font.GothamBold, 24)
	local letters2 = box(m, "Lettering", 253.5, 11.5, zf, x1 - 1, 13.3, zf + 0.3, green, M.smooth, DECO)
	letters2.Transparency = 1
	sign(letters2, Enum.NormalId.Back, "TIRES · OIL", green, nil, Enum.Font.GothamBold, 24)
	-- pump island (raised curb, yellow noses) + lane lines where cars stop + two old pumps with round globe heads
	box(m, "Island", 238, 0.5, -142, 262, 1.1, -139.5, C.concrete, M.concrete)
	box(m, "IslandNose", 236.8, 0.5, -142, 238, 1.1, -139.5, C.yellow, M.smooth)
	box(m, "IslandNose", 262, 0.5, -142, 263.2, 1.1, -139.5, C.yellow, M.smooth)
	for _, lz in ipairs({ -146.4, -135.6 }) do
		box(m, "StopLane", 236, 0.5, lz - 0.15, 264, 0.55, lz + 0.15, C.lineWhite, M.smooth, DECO)
	end
	for _, px in ipairs({ 243, 257 }) do
		box(m, "Pump", px - 1, 1.1, -141.6, px + 1, 6.4, -139.9, Color3.fromRGB(250, 248, 240), M.smooth)
		box(m, "PumpFace", px - 0.8, 3.6, -139.95, px + 0.8, 5.6, -139.85, green, M.smooth, DECO)
		box(m, "PumpTop", px - 1.1, 6.4, -141.7, px + 1.1, 7.0, -139.8, C.red, M.smooth)
		Kit.part(m, "Globe", Vector3.new(1.6, 1.6, 1.6), CFrame.new(px, 7.7, -140.75), Color3.fromRGB(250, 246, 232), M.smooth, { shape = "ball", collide = false })
		Kit.rod(m, "Hose", Vector3.new(px + 1, 5.2, -140.4), Vector3.new(px + 1.5, 1.6, -139.4), 0.25, 0.25, C.rubber, M.smooth, DECO)
	end
	-- canopy over the island: two posts, a flat roof with an enamel-green fascia that carries the name, light panel
	for _, cx in ipairs({ 240.5, 259.5 }) do
		Kit.post(m, "CanopyPost", cx, -140.75, 1.1, 11.4, 1.0, green, M.metal)
	end
	local fascia = box(m, "CanopyFascia", 234, 11.4, -146.6, 266, 12.6, -134.9, green, M.smooth)
	sign(fascia, Enum.NormalId.Back, "AVENUE FUEL", Color3.new(1, 1, 1), nil, Enum.Font.GothamBold, 16)
	box(m, "CanopyStripe", 234, 12.6, -146.6, 266, 12.9, -134.9, Color3.fromRGB(250, 248, 240), M.smooth, DECO)
	box(m, "CanopyLight", 236, 11.35, -145.6, 264, 11.4, -135.9, Color3.fromRGB(255, 250, 232), M.neon, DECO)
	-- price pole sign on the corner
	Kit.post(m, "SignPole", 272, SW_Z0 + 2.3, 0.5, 20, 0.7, C.metalDark, M.metal)
	local b = box(m, "PriceBoard", 267, 14, SW_Z0 + 2.85, 277, 19, SW_Z0 + 3.15, Color3.fromRGB(250, 250, 244), M.smooth)
	sign(b, Enum.NormalId.Back, "AVENUE FUEL\nREG 3.19", green, nil, Enum.Font.GothamBold, 24)
	sign(b, Enum.NormalId.Front, "AVENUE FUEL\nREG 3.19", green, nil, Enum.Font.GothamBold, 24)
	return m
end

-- a vacant lot between two buildings: gravel, two bollards (the side walls next to it carry a mural / a painted sign)
local function vacantLot(parent: Instance, x0: number, x1: number)
	local m = Kit.model(parent, "VacantLot")
	box(m, "Gravel", x0, -1, FRONT - DEPTH, x1, 0.15, FRONT, Color3.fromRGB(150, 144, 132), M.concrete)
	for _, bx in ipairs({ x0 + 3, x1 - 3 }) do
		Kit.post(m, "Bollard", bx, FRONT - 1, 0.15, 3, 0.8, C.yellow, M.metal)
	end
	return m
end

local function shopRow(town: Instance)
	local row = Kit.folder(town, "AvenueShops")
	local art = Kit.folder(row, "ArtSlots")
	local b = BRICK
	local specs: { ShopSpec } = {
		{ name = "CornerWest", x0 = -276, x1 = -246, storeys = 3, wall = b[2], awning = 2, word = "GROCERY", seed = 21 },
		{ name = "Bakery", x0 = -246, x1 = -224, storeys = 2, wall = b[1], awning = 4, word = "BAKERY", seed = 22, aframe = "FRESH\nBREAD" },
		{ name = "Barber", x0 = -224, x1 = -200, storeys = 2, wall = CREAM, awning = 3, word = "BARBER", seed = 23, cornice = C.trim, aframe = "WALK\nINS" },
		{ name = "Records", x0 = -200, x1 = -176, storeys = 3, wall = b[3], awning = 5, word = "RECORDS", seed = 24 },
		{ name = "Shoes", x0 = -146, x1 = -124, storeys = 2, wall = b[4], awning = 1, word = "SHOES", seed = 25 },
		{ name = "Hotel", x0 = -124, x1 = -102, storeys = 3, wall = b[5], awning = 3, word = "ROOMS", seed = 26 },
		{ name = "Pharmacy", x0 = -102, x1 = -80, storeys = 2, wall = CREAM, awning = 2, word = "PHARMACY", seed = 27, cornice = C.trim },
		{ name = "Hardware", x0 = -80, x1 = -58, storeys = 2, wall = b[1], awning = 4, word = "HARDWARE", seed = 28 },
		{ name = "Laundry", x0 = -36, x1 = -14, storeys = 2, wall = b[3], awning = 3, word = "LAUNDRY", seed = 29 },
		{ name = "Books", x0 = -14, x1 = 10, storeys = 2, wall = b[2], awning = 5, word = "BOOKS", seed = 30 },
		{ name = "Diner", x0 = 10, x1 = 40, storeys = 3, wall = b[5], awning = 1, word = "DINER", seed = 33, plate = "1923 · HALVERSON BLOCK", aframe = "PIE\nTODAY" },
		{ name = "Pizza", x0 = 40, x1 = 62, storeys = 2, wall = CREAM, awning = 2, word = "PIZZA", seed = 31, cornice = C.trim },
		{ name = "Hobby", x0 = 92, x1 = 114, storeys = 2, wall = b[4], awning = 4, word = "HOBBY SHOP", seed = 34 },
		{ name = "Tailor", x0 = 114, x1 = 136, storeys = 3, wall = b[1], awning = 3, word = "TAILOR", seed = 35 },
		{ name = "Cafe", x0 = 150, x1 = 172, storeys = 2, wall = b[3], awning = 2, word = "CAFE", seed = 37, aframe = "COFFEE" },
		{ name = "CornerEast", x0 = 172, x1 = 198, storeys = 4, wall = b[2], awning = 5, word = "BANK", seed = 39, plate = "1928 · GEARPORT SAVINGS" },
	}
	for _, s in ipairs(specs) do
		shopBuilding(row, s)
	end
	rivalGarage(row, "RivalGarageWest", -176, -146, CREAM, "BROTHERS GARAGE", "BRAKES\nTIRES", 41)
	rivalGarage(row, "RivalGarageEast", 62, 92, BRICK[3], "SAM'S AUTO", "OIL CHANGE\n$27", 42)
	vacantLot(row, -58, -36)
	vacantLot(row, 136, 150)
	-- mural walls (blank boards: the picture comes from wr-art / Codex later) + painted wall signs
	local zc = FRONT - DEPTH / 2
	LivedIn.artSlot(art, "GP_MuralWest", Vector3.new(-57.85, 11, zc), Vector3.new(1, 0, 0), 24, 16)
	LivedIn.artSlot(art, "GP_MuralEast", Vector3.new(149.85, 11, zc), Vector3.new(-1, 0, 0), 24, 16)
	LivedIn.artSlot(art, "GP_MuralCross", Vector3.new(198.15, 20, zc), Vector3.new(1, 0, 0), 24, 28)
	ghostSign(row, -36.1, zc - 11, zc + 11, 13, 21, -1, "PISTON AVE. HARDWARE & PAINT")
	ghostSign(row, 136.1, zc - 11, zc + 11, 20, 30, 1, "GEARPORT TIRE & RUBBER CO.")
	ghostSign(row, -276.1, zc - 12, zc + 12, 18, 30, -1, "GEARPORT MOTOR PARTS")
	return row
end

local function parkedCars(town: Instance, standInCar: (Instance, string, CFrame, Color3) -> Model)
	local pk = Kit.folder(town, "AvenueParking")
	local cars = {
		{ -214, 89.2, Color3.fromRGB(232, 190, 60) },
		{ -88, 90.6, Color3.fromRGB(120, 170, 120) },
		{ 56, 89.4, Color3.fromRGB(60, 64, 76) }, -- 20 ft clear of the mid-block crosswalk
		{ 128, 90.8, Color3.fromRGB(196, 84, 70) },
	}
	for i, c in ipairs(cars) do
		standInCar(pk, "StreetCar" .. i, CFrame.new(c[1] :: number, 0, -122) * CFrame.Angles(0, math.rad(c[2] :: number), 0), c[3] :: Color3)
	end
end

function Gearport.build(garage: Model, standInCar: (Instance, string, CFrame, Color3) -> Model)
	local town = garage:FindFirstChild("Town") or Kit.folder(garage, "Town")
	town:SetAttribute("City", "Gearport")
	avenue(town)
	shopRow(town)
	fuelStation(town)
	parkedCars(town, standInCar)
end

return Gearport
