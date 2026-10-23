--!strict
-- World/GearportDistricts (wr-builder): Gearport stage 2 (plan: notes/design/detroit_town_plan.md §3 E, I, J + §4).
--   Brickyard Heights — brick bungalow / two-storey / porch-house streets behind the avenue shops (photos 21-23)
--   River walk + Gearport River — the south map edge: promenade, railing, lamps; walkable shallow water, tall far wall
--   Midtown — the skyline across the river: big plain masses only, no collision, one Persistent model (≤ 300 parts)
--   Union Depot — station hall with three arched windows + clock tower at the west end, platform, tracks into a tunnel
--   Map edges — tall retaining walls west / east / north (visible, no invisible walls)
-- Looks only, except the reserved marker Town.UnionDepot.ArrivalPoint (world_contract ★ Gearport).

local Kit = require(script.Parent.Kit)
local Site = require(script.Parent.Site)
local Town = require(script.Parent.Town)
local GearportProps = require(script.Parent.GearportProps)
local C, M = Kit.C, Kit.M
local box, marker = Kit.box, Kit.marker

local Districts = {}

local MX0, MX1, MZ0, MZ1 = Site.MAP_X0, Site.MAP_X1, Site.MAP_Z0, Site.MAP_Z1
local X0, X1 = Site.CROSS_X0, Site.CROSS_X1
local DECO = { collide = false }
local FLAT = { shadow = false } -- huge flat / far pieces: no shadow (shadow maps of map-sized parts cost render time)

local BRICK = { Color3.fromRGB(206, 104, 74), Color3.fromRGB(194, 96, 70), Color3.fromRGB(216, 126, 88), Color3.fromRGB(188, 112, 86) }
local SIDING = { Color3.fromRGB(196, 214, 226), Color3.fromRGB(236, 226, 196), Color3.fromRGB(198, 214, 186), Color3.fromRGB(232, 206, 196) }
local ROOFS = { Color3.fromRGB(84, 88, 98), Color3.fromRGB(112, 82, 70), Color3.fromRGB(70, 96, 88), Color3.fromRGB(96, 98, 108) }
local WHITE = Color3.fromRGB(246, 244, 236)
local STONE = Color3.fromRGB(226, 214, 186)
local WINDOW = Color3.fromRGB(78, 104, 132)

-- gable roof, ridge along X (front slope faces +Z)
local function gable(parent: Instance, x0: number, x1: number, z0: number, z1: number, y: number, rise: number, color: Color3)
	local zm = (z0 + z1) / 2
	Kit.part(parent, "Roof", Vector3.new(x1 - x0, rise, zm - z0), CFrame.new((x0 + x1) / 2, y + rise / 2, (z0 + zm) / 2), color, M.smooth, { shape = "wedge" })
	Kit.part(parent, "Roof", Vector3.new(x1 - x0, rise, z1 - zm), CFrame.new((x0 + x1) / 2, y + rise / 2, (zm + z1) / 2) * CFrame.Angles(0, math.pi, 0),
		color, M.smooth, { shape = "wedge" })
end

-- white-framed window on a +Z wall at z
local function window(parent: Instance, x: number, y: number, z: number, w: number, h: number)
	box(parent, "WindowFrame", x - w / 2 - 0.35, y - h / 2 - 0.35, z, x + w / 2 + 0.35, y + h / 2 + 0.35, z + 0.15, WHITE, M.smooth, DECO)
	box(parent, "Window", x - w / 2, y - h / 2, z + 0.15, x + w / 2, y + h / 2, z + 0.22, WINDOW, M.glass, DECO)
end

-- a block "theme": its own wall / roof / door palette (Maple Row changes block by block — main review)
export type Theme = { walls: { Color3 }, siding: { Color3 }, roofs: { Color3 }, doors: { Color3 } }

-- one house facing +Z, front wall at zf, centre cx. kind 1 = brick bungalow (dormer + porch with brick piers),
-- 2 = two-storey brick (pointed entry), 3 = porch house (siding, columns). One small yard feature by i:
-- mailbox / bike / woodpile / garden flag / window flower box / trash cans / nothing. Returns the model.
local function house(parent: Instance, kind: number, cx: number, zf: number, i: number, th: Theme): Model
	local r = Kit.rng(5000 + i)
	local m = Kit.model(parent, "House")
	local d = 18
	local z0 = zf - d
	local roof = th.roofs[i % #th.roofs + 1]
	local w = if kind == 1 then 24 else 22
	local x0, x1 = cx - w / 2, cx + w / 2
	local h = if kind == 1 then 10 else 19
	local wall = if kind == 3 then th.siding[i % #th.siding + 1] else th.walls[i % #th.walls + 1]
	local doorCol = th.doors[(i * 3) % #th.doors + 1]
	box(m, "Foundation", x0 - 0.3, 0, z0 - 0.3, x1 + 0.3, 1.2, zf + 0.3, C.plinth, M.concrete)
	box(m, "Walls", x0, 1.2, z0, x1, h, zf, wall, if kind == 3 then M.wood else M.brick)
	gable(m, x0 - 1, x1 + 1, z0 - 1, zf + 1, h, if kind == 1 then 7 + math.floor(r() * 2) else 6, roof)
	local left = i % 2 == 0
	local dx = cx + (if left then -4.5 else 4.5)
	box(m, "Door", dx - 1.5, 1.2, zf, dx + 1.5, 8, zf + 0.3, doorCol, M.smooth, DECO)
	local wx = cx + (if left then 4.5 else -4.5)
	window(m, wx, 5.4, zf, 4.4, 3.6)
	if kind == 1 then
		box(m, "Dormer", cx - 3.5, h + 1, zf - 6, cx + 3.5, h + 5, zf - 2.6, wall, M.brick)
		Kit.part(m, "DormerRoof", Vector3.new(8, 1.2, 4.4), CFrame.new(cx, h + 5.6, zf - 4.3) * CFrame.Angles(0, math.pi, 0), roof, M.smooth, { shape = "wedge" })
		window(m, cx, h + 3, zf - 2.6, 3.6, 2.2)
		box(m, "Porch", x0 + 1, 0, zf, x1 - 1, 1.2, zf + 6, C.concrete, M.concrete)
		for _, px in ipairs({ x0 + 1.5, x1 - 1.5 }) do
			box(m, "PorchPier", px - 0.9, 1.2, zf + 4.6, px + 0.9, 8, zf + 6, wall, M.brick)
		end
		box(m, "PorchRoof", x0 + 0.6, 8, zf, x1 - 0.6, 8.7, zf + 6.6, roof, M.smooth)
		if i % 3 == 0 then
			box(m, "Fence", x0, 0, zf + 7.4, x1, 2.4, zf + 7.6, WHITE, M.wood)
		end
	elseif kind == 2 then
		box(m, "Entry", dx - 2.6, 1.2, zf, dx + 2.6, 10, zf + 2.4, wall, M.brick)
		Kit.part(m, "EntryRoof", Vector3.new(2.6, 3, 3), CFrame.new(dx - 1.3, 11.5, zf + 1.2) * CFrame.Angles(0, math.rad(90), 0), roof, M.smooth, { shape = "wedge" })
		Kit.part(m, "EntryRoof", Vector3.new(2.6, 3, 3), CFrame.new(dx + 1.3, 11.5, zf + 1.2) * CFrame.Angles(0, math.rad(-90), 0), roof, M.smooth, { shape = "wedge" })
		window(m, cx - 5, 14.5, zf, 3.6, 3.6)
		window(m, cx + 5, 14.5, zf, 3.6, 3.6)
		box(m, "Steps", dx - 2, 0, zf + 2.4, dx + 2, 1.2, zf + 4.4, C.concrete, M.concrete)
	else
		box(m, "Porch", x0 + 0.5, 0, zf, x1 - 0.5, 1.6, zf + 7, Color3.fromRGB(176, 160, 140), M.wood)
		for k = 0, 2 do
			Kit.post(m, "Column", x0 + 1.5 + k * (w - 3) / 2, zf + 6.3, 1.6, 9.5, 0.9, WHITE, M.smooth)
		end
		box(m, "PorchRoof", x0, 9.5, zf, x1, 10.2, zf + 7.6, roof, M.smooth)
		window(m, cx - 5, 14.5, zf, 3.6, 3.6)
		window(m, cx + 5, 14.5, zf, 3.6, 3.6)
	end
	box(m, "Walk", dx - 1.4, -1, zf + (if kind == 3 then 7 else if kind == 1 then 6 else 4.4), dx + 1.4, 0.15, zf + 8, C.concrete, M.concrete)
	-- one small yard feature (the same street, different lives)
	local f = (i * 5 + kind) % 7
	local sx = if left then x1 - 2 else x0 + 2 -- the side away from the door
	if f == 0 then
		-- curbside box: bottom 41-45 in up, red flag on the side (street_props.md A2)
		local mx = dx + (if left then -2.6 else 2.6)
		Kit.post(m, "MailboxPost", mx, zf + 7.4, 0, 3.8, 0.3, C.wood, M.wood)
		box(m, "Mailbox", mx - 0.6, 3.8, zf + 6.8, mx + 0.6, 4.8, zf + 8, Color3.fromRGB(46, 52, 60), M.metal)
		box(m, "MailboxFlag", mx + 0.6, 4.2, zf + 7.2, mx + 0.68, 5.4, zf + 7.6, Color3.fromRGB(214, 50, 44), M.smooth, DECO)
	elseif f == 1 then
		for k = -1, 1, 2 do
			Kit.part(m, "BikeWheel", Vector3.new(0.2, 2, 2), CFrame.new(sx + k * 1.1, 1.2, zf + 2.4) * CFrame.Angles(0, math.rad(90), 0),
				C.rubber, M.smooth, { shape = "cyl", collide = false })
		end
		Kit.rod(m, "BikeFrame", Vector3.new(sx - 1.1, 1.3, zf + 2.4), Vector3.new(sx + 1.1, 2.1, zf + 2.4), 0.2, 0.2, Color3.fromRGB(214, 60, 52), M.metal, DECO)
	elseif f == 2 then
		box(m, "Woodpile", x1 + 0.3, 0, z0 + 3, x1 + 2.1, 2.6, z0 + 10, Color3.fromRGB(150, 104, 66), M.wood)
		box(m, "WoodpileTop", x1 + 0.1, 2.6, z0 + 2.8, x1 + 2.4, 2.9, z0 + 10.2, Color3.fromRGB(96, 70, 50), M.wood, DECO)
	elseif f == 3 then
		Kit.rod(m, "FlagPole", Vector3.new(wx, 7, zf + 0.2), Vector3.new(wx, 9.6, zf + 2.6), 0.15, 0.15, C.steel, M.metal, DECO)
		box(m, "GardenFlag", wx + 0.1, 7.6, zf + 1.6, wx + 0.15, 9.4, zf + 2.5, if i % 2 == 0 then Color3.fromRGB(240, 170, 50) else Color3.fromRGB(70, 130, 200), M.fabric, DECO)
	elseif f == 4 then
		box(m, "FlowerBox", wx - 2.6, 3, zf, wx + 2.6, 3.7, zf + 0.9, Color3.fromRGB(150, 104, 66), M.wood, DECO)
		box(m, "Flowers", wx - 2.4, 3.7, zf + 0.15, wx + 2.4, 4.5, zf + 0.85, if i % 2 == 0 then Color3.fromRGB(236, 96, 130) else Color3.fromRGB(250, 210, 70), M.grass, DECO)
	elseif f == 5 then
		-- Detroit carts: black = trash, blue = recycling (street_props.md A5), by the house till pick-up day
		for k = 0, 1 do
			local tx = sx + k * 1.9 * (if left then -1 else 1)
			box(m, "Cart", tx - 0.8, 0, z0 + 0.4, tx + 0.8, 3.1, z0 + 2.2, if k == 0 then Color3.fromRGB(36, 38, 42) else Color3.fromRGB(40, 90, 170), M.smooth)
			box(m, "CartLid", tx - 0.85, 3.1, z0 + 0.35, tx + 0.85, 3.35, z0 + 2.3, if k == 0 then Color3.fromRGB(28, 30, 34) else Color3.fromRGB(34, 76, 150), M.smooth, DECO)
		end
	end
	return m
end

-- three tree kinds so blocks don't repeat: round (Town.tree), columnar, small flowering
local function lawnTree(parent: Instance, kind: number, x: number, z: number, seed: number)
	if kind == 1 then
		Town.tree(parent, x, z, 0.95 + (seed % 3) * 0.15, seed)
		return
	end
	local m = Kit.model(parent, "Tree")
	local tall = kind == 2
	Kit.post(m, "Trunk", x, z, 0, if tall then 4 else 3.2, 0.7, Color3.fromRGB(116, 84, 60), M.wood)
	local size = if tall then Vector3.new(5, 13, 5) else Vector3.new(5.5, 4.5, 5.5)
	local col = if tall then Color3.fromRGB(64, 120, 62) else (if seed % 2 == 0 then Color3.fromRGB(236, 150, 180) else Color3.fromRGB(244, 204, 90))
	Kit.part(m, "Leaves", size, CFrame.new(x, (if tall then 4 else 3.2) + size.Y / 2 - 0.6, z), col, M.grass, { shape = "ball" })
end

local function brickyard(town: Instance)
	local hood = Kit.folder(town, "BrickyardHeights")
	-- Maple Row: a narrow two-lane street, sidewalks both sides (front lawns between them and the houses)
	local SX0, SX1 = -290, X0
	box(hood, "Street", SX0, -1, -216, SX1, 0, -200, C.asphalt, M.asphalt, FLAT)
	box(hood, "Sidewalk", SX0, -1, -200, X0 - 4, 0.5, -196, C.sidewalk, M.concrete)
	box(hood, "Sidewalk", SX0, -1, -220, X0 - 4, 0.5, -216, C.sidewalk, M.concrete)
	for x = SX0 + 10, SX1 - 10, 20 do
		box(hood, "CentreDash", x - 3, 0, -208.15, x + 3, 0.05, -207.85, C.lineYellow, M.smooth, DECO)
	end
	-- 15 lots (31.6 wide) per side; lots 5 and 10 are cross lanes (Elm St / Birch St) that split the street into
	-- three blocks with their own look: West = brick bungalows, Middle = pastel porch houses, East = two-storey brick
	local themes: { Theme } = {
		{ walls = { Color3.fromRGB(206, 104, 74), Color3.fromRGB(180, 92, 70), Color3.fromRGB(196, 112, 84) }, siding = { Color3.fromRGB(236, 226, 196) },
			roofs = { Color3.fromRGB(70, 74, 84), Color3.fromRGB(92, 92, 100), Color3.fromRGB(60, 64, 72) },
			doors = { Color3.fromRGB(40, 90, 70), Color3.fromRGB(150, 40, 40), Color3.fromRGB(30, 50, 90) } },
		{ walls = { Color3.fromRGB(220, 132, 96) }, siding = { Color3.fromRGB(196, 214, 226), Color3.fromRGB(236, 226, 196), Color3.fromRGB(198, 220, 186), Color3.fromRGB(240, 206, 200) },
			roofs = { Color3.fromRGB(80, 108, 140), Color3.fromRGB(70, 110, 92), Color3.fromRGB(150, 92, 80), Color3.fromRGB(96, 98, 108) },
			doors = { Color3.fromRGB(230, 180, 60), Color3.fromRGB(220, 90, 80), Color3.fromRGB(250, 250, 244), Color3.fromRGB(80, 150, 170) } },
		{ walls = { Color3.fromRGB(168, 84, 62), Color3.fromRGB(190, 120, 90), Color3.fromRGB(150, 96, 80), Color3.fromRGB(214, 190, 150) }, siding = { Color3.fromRGB(214, 200, 176) },
			roofs = { Color3.fromRGB(110, 80, 64), Color3.fromRGB(84, 62, 52), Color3.fromRGB(120, 100, 84) },
			doors = { Color3.fromRGB(250, 250, 244), Color3.fromRGB(60, 60, 66), Color3.fromRGB(120, 40, 50) } },
	}
	local blockKinds = { { 1, 1, 2, 1, 1 }, { 3, 1, 3, 3 }, { 2, 2, 1, 2 } }
	local LANES = { 5, 10 }
	local function blockOf(k: number): (number, number)
		if k < 5 then
			return 1, k + 1
		elseif k < 10 then
			return 2, k - 5
		end
		return 3, k - 10
	end
	for row = 1, 2 do
		for k = 0, 14 do
			if k ~= LANES[1] and k ~= LANES[2] then
				local cx = -274 + 15.8 + 31.6 * k
				local idx = row * 20 + k
				local b, j = blockOf(k)
				local kinds = blockKinds[b]
				local kind = kinds[(j + row) % #kinds + 1]
				local th = themes[b]
				local zJitter = ((idx * 7) % 3 - 1) * 1.2 -- set-backs differ a little
				if row == 2 then
					house(hood, kind, cx, -228 - zJitter, idx, th)
				else
					local m = house(hood, kind, cx, -170 - zJitter, idx, th)
					local centre = CFrame.new(cx, 0, -179 - zJitter)
					m.WorldPivot = centre
					m:PivotTo(centre * CFrame.Angles(0, math.pi, 0))
				end
			end
		end
	end
	-- cross lanes from the back alley down to the river walk, with name signs at Maple Row
	for li, k in ipairs(LANES) do
		local cx = -274 + 15.8 + 31.6 * k
		box(hood, "Lane", cx - 6, -1, -196, cx + 6, 0, -170, C.asphalt, M.asphalt, FLAT)
		box(hood, "Lane", cx - 6, -1, -258, cx + 6, 0, -220, C.asphalt, M.asphalt, FLAT)
		local name = if li == 1 then "ELM ST" else "BIRCH ST"
		Kit.post(hood, "SignPost", cx - 7.5, -198, 0.5, 10.6, 0.3, C.steel, M.metal)
		local sg = Kit.part(hood, "StreetName", Vector3.new(0.12, 1.1, 4.6), CFrame.lookAt(Vector3.new(cx - 7.5, 10, -198), Vector3.new(cx - 7.5 + 1, 10, -198)),
			Color3.fromRGB(30, 120, 70), M.smooth, DECO)
		Kit.label(sg, Enum.NormalId.Left, name, Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
		Kit.label(sg, Enum.NormalId.Right, name, Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
	end
	-- lawn trees: a different kind per block (round / columnar / small flowering), sizes vary
	local r = Kit.rng(5401)
	local treeKinds = { 1, 2, 3 }
	for k = 0, 14 do
		if k ~= LANES[1] and k ~= LANES[2] and k % 2 == 0 then
			local b = blockOf(k)
			local x = -274 + 31.6 * (k + 1)
			lawnTree(hood, treeKinds[b], x + (r() - 0.5) * 2, -192, 5410 + k)
			lawnTree(hood, treeKinds[(b % 3) + 1], x - 31.6 + (r() - 0.5) * 2, -224, 5430 + k)
		end
	end
	-- neighbourhood lamps: one at every corner + one mid-block (street_props.md B3 3-4), cobra-heads over the street
	for _, x in ipairs({ -282, -195, -108, -21, 50, 137, 194 }) do
		GearportProps.cobraLamp(hood, x, -197.2, -1)
	end
	-- hydrants near the corners, green caps (class A) on the side-street mains
	GearportProps.hydrant(hood, "Hydrant", -91.6, -200, -1)
	GearportProps.hydrant(hood, "Hydrant", 66.4, -216, 1)
	GearportProps.hydrant(hood, "Hydrant", -278, -216, 1)
	local sign = Kit.part(hood, "StreetName", Vector3.new(0.12, 1.1, 5.2), CFrame.lookAt(Vector3.new(X0 - 2, 10, -198), Vector3.new(X0 - 2, 10, -190)),
		Color3.fromRGB(30, 120, 70), M.smooth, DECO)
	Kit.label(sign, Enum.NormalId.Left, "MAPLE ROW", Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
	Kit.label(sign, Enum.NormalId.Right, "MAPLE ROW", Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
	Kit.post(hood, "SignPost", X0 - 2, -198, 0.5, 10.6, 0.3, C.steel, M.metal, DECO) -- thin: no snag at the corner
end

-- Riverside Park: the corner east of Chassis Street down to the river walk (cheap: lawn, two paths, trees, benches)
local function park(town: Instance)
	local p = Kit.folder(town, "RiversidePark")
	box(p, "Path", X1 + 4, -1, -258, 290, 0.15, -253, C.concrete, M.concrete)
	box(p, "Path", 284, -1, -253, 290, 0.15, -134, C.concrete, M.concrete)
	local r = Kit.rng(5601)
	for i, t in ipairs({ { 246, -196 }, { 262, -222 }, { 312, -170 }, { 330, -230 }, { 372, -200 }, { 400, -160 }, { 420, -236 }, { 452, -186 }, { 352, -146 }, { 236, -238 } }) do
		Town.tree(p, t[1] + (r() - 0.5) * 4, t[2], 1.1 + r() * 0.4, 5610 + i)
	end
	for _, bx in ipairs({ 250, 320, 400 }) do
		box(p, "BenchSeat", bx - 3, 1.6, -252.4, bx + 3, 1.9, -251, C.wood, M.wood)
		box(p, "BenchBack", bx - 3, 1.9, -251, bx + 3, 3.8, -250.7, C.wood, M.wood, DECO)
		box(p, "BenchLegs", bx - 2.6, 0.15, -252.2, bx + 2.6, 1.6, -251.2, C.metalDark, M.metal)
	end
end

-- the river walk (promenade, railing, lamps), the river (walkable shallow water), the tall far wall and the far bank
local function river(town: Instance)
	local rv = Kit.folder(town, "RiverWalk")
	box(rv, "Promenade", MX0, -1, MZ0, MX1, 0.5, -258, Color3.fromRGB(206, 200, 188), M.concrete, FLAT)
	box(rv, "Seawall", MX0, -8, MZ0 - 1, MX1, 0.5, MZ0, C.concrete, M.concrete, FLAT)
	box(rv, "Parapet", MX0, 0.5, MZ0, MX1, 3.6, MZ0 + 0.8, C.concrete, M.concrete, FLAT)
	box(rv, "Rail", MX0, 3.6, MZ0 + 0.1, MX1, 4.1, MZ0 + 0.7, C.metalDark, M.metal, FLAT)
	for x = MX0 + 30, MX1 - 30, 60 do
		GearportProps.oldLamp(rv, x, MZ0 + 0.4, 3.6) -- old-style lamps (props sheet 39/40) standing on the river wall, out of the walkway
	end
	-- water: top y -1.5 (a player who jumps the rail can walk / jump back up — no trap)
	local water = box(rv, "Water", MX0, -9, -441, MX1, -1.5, MZ0 - 1, Color3.fromRGB(44, 112, 140), M.smooth, FLAT)
	water.Reflectance = 0.18
	-- far side (main review: it read as a grey slab floating on the water): a low dark-stone quay 9.5 above the
	-- water (still too high to jump out), a wet line where it meets the water, a cap, then a wide low earthy bank
	local stone = Color3.fromRGB(118, 112, 104)
	box(rv, "FarWall", MX0 - 600, -9, -443, MX1 + 600, 8, -441, stone, M.concrete, FLAT)
	box(rv, "FarWallCap", MX0 - 600, 8, -443.4, MX1 + 600, 8.6, -440.6, Color3.fromRGB(150, 144, 134), M.concrete, FLAT)
	box(rv, "WetLine", MX0 - 600, -1.7, -441.1, MX1 + 600, -0.6, -440.9, Color3.fromRGB(58, 66, 70), M.smooth, { collide = false, shadow = false })
	box(rv, "RiverEndWall", MX0 - 2, -9, -443, MX0, 16, MZ0, C.concrete, M.concrete, FLAT)
	box(rv, "RiverEndWall", MX1, -9, -443, MX1 + 2, 16, MZ0, C.concrete, M.concrete, FLAT)
	local bank = box(rv, "FarBank", MX0 - 1000, -4, -1700, MX1 + 1000, 7.5, -443, Color3.fromRGB(118, 124, 112), M.concrete, { shadow = false, collide = false }) -- nobody can reach it
	bank.CanQuery = false
end

-- Midtown skyline (across the river, background only): towers with the Detroit hints spread over different
-- buildings (setback orange brick, a green stepped roof, one glass cylinder, a lit crown) — never all on one.
-- Main review: it sat too big and close behind the houses -> towers moved ~300 back and a little lower, the low
-- blocks vary in height / width / colour and step back, then a few window bands (no night lights yet).
local function skyline(town: Instance)
	local sk = Kit.model(town, "Midtown")
	sk.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local o = { collide = false, shadow = false }
	local base = 7.5
	local function mass(name: string, x: number, z: number, w: number, d: number, y0: number, y1: number, col: Color3, mat: Enum.Material?)
		local p = Kit.box(sk, name, x - w / 2, base + y0, z - d / 2, x + w / 2, base + y1, z + d / 2, col, mat or M.smooth, o)
		p.CanQuery = false
		p.CanTouch = false
		return p
	end
	local function bands(x: number, z: number, w: number, d: number, y0: number, y1: number, step: number)
		for y = y0, y1, step do
			mass("WindowBand", x, z, w + 0.4, d + 0.4, y, y + 2.2, Color3.fromRGB(70, 84, 104))
		end
	end
	local orange = Color3.fromRGB(214, 124, 72)
	local beige = Color3.fromRGB(222, 206, 176)
	local grey = Color3.fromRGB(170, 176, 184)
	local glass = Color3.fromRGB(92, 128, 160)
	local green = Color3.fromRGB(86, 150, 120)
	local brick = Color3.fromRGB(176, 102, 78)
	local cream = Color3.fromRGB(214, 204, 184)
	-- low city: three loose rows of blocks with different widths / heights / colours (dense enough that it reads as
	-- a city from above too, not single boxes on a lawn)
	local palette = { grey, brick, cream, beige, Color3.fromRGB(150, 158, 168), Color3.fromRGB(196, 132, 100) }
	local r = Kit.rng(7301)
	local n = 0
	for row, z in ipairs({ -500, -575, -650 }) do
		for x = -440 + row * 9, 480, 46 do
			n += 1
			local w = 30 + r() * 14
			local h = (6 + r() * 16) * (1 + (row - 1) * 0.35)
			mass("Block" .. n, x + (r() - 0.5) * 8, z + (r() - 0.5) * 16, w, 30 + r() * 20, 0, h, palette[n % #palette + 1])
		end
	end
	-- 1: setback orange-brick tower with a slim spire
	mass("T1", -210, -880, 36, 36, 0, 125, orange, M.brick)
	mass("T1b", -210, -880, 27, 27, 125, 160, orange, M.brick)
	mass("T1c", -210, -880, 16, 16, 160, 182, orange, M.brick)
	mass("T1spire", -210, -880, 3, 3, 182, 212, Color3.fromRGB(196, 120, 70))
	bands(-210, -880, 36, 36, 20, 110, 18)
	-- 2: beige stone tower with a green stepped roof
	mass("T2", -60, -930, 32, 32, 0, 145, beige, M.concrete)
	mass("T2b", -60, -930, 25, 25, 145, 166, beige, M.concrete)
	mass("T2roof", -60, -930, 21, 21, 166, 173, green)
	mass("T2roof", -60, -930, 14, 14, 173, 180, green)
	mass("T2roof", -60, -930, 6, 6, 180, 188, green)
	-- 3: a glass cylinder (alone, not a cluster)
	local cyl = Kit.part(sk, "T3", Vector3.new(136, 36, 36), CFrame.new(110, base + 68, -900) * CFrame.Angles(0, 0, math.rad(90)), glass, M.glass,
		{ shape = "cyl", collide = false, shadow = false })
	cyl.CanQuery = false
	mass("T3cap", 110, -900, 27, 27, 136, 140, Color3.fromRGB(60, 70, 84))
	-- 4: grey stone tower with a lit crown band
	mass("T4", 260, -860, 30, 30, 0, 120, grey, M.concrete)
	mass("T4b", 260, -860, 23, 23, 120, 137, grey, M.concrete)
	mass("T4crown", 260, -860, 24, 24, 137, 140, Color3.fromRGB(255, 236, 180), M.neon)
	bands(260, -860, 30, 30, 16, 100, 16)
	-- 5 / 6 / 7: plain glass far east, orange-brick mid-rise far west, a small green-roof tower behind
	mass("T5", 370, -950, 36, 36, 0, 102, glass, M.glass)
	bands(370, -950, 36, 36, 12, 90, 14)
	mass("T6", -340, -960, 30, 30, 0, 92, orange, M.brick)
	mass("T7", 30, -1000, 26, 26, 0, 110, grey, M.concrete)
	mass("T7roof", 30, -1000, 19, 19, 110, 119, green)
end

-- Union Depot: hall (three arched windows, columns, name band), clock tower, plaza, platform with canopy, two
-- tracks running west into a tunnel in the west wall. Reserved marker: ArrivalPoint (platform edge).
local function depot(town: Instance)
	local dp = Kit.model(town, "UnionDepot")
	local zf = -150
	box(dp, "Plaza", -436, -1, zf, -290, 0.55, -134, Color3.fromRGB(214, 206, 192), M.concrete)
	-- the hall in three pieces: the middle arch is a real entrance — a passage straight through to the platform
	-- (main review: all three arches read as shut windows; "looks = works": you can walk in here)
	local px0, px1 = -386, -374
	box(dp, "Hall", -416, 0.5, -192, px0, 28, zf, STONE, M.concrete)
	box(dp, "Hall", px1, 0.5, -192, -344, 28, zf, STONE, M.concrete)
	box(dp, "Hall", px0, 11.5, -192, px1, 28, zf - 0.3, STONE, M.concrete)
	box(dp, "PassageFloor", px0, -1, -192, px1, 0.6, zf, Color3.fromRGB(186, 160, 128), M.concrete)
	box(dp, "PassageLiner", px0, 0.6, -192, px0 + 0.2, 11.5, zf - 0.5, Color3.fromRGB(120, 96, 76), M.wood, DECO)
	box(dp, "PassageLiner", px1 - 0.2, 0.6, -192, px1, 11.5, zf - 0.5, Color3.fromRGB(120, 96, 76), M.wood, DECO)
	box(dp, "PassageLight", px0 + 2, 11.4, -188, px1 - 2, 11.5, -154, Color3.fromRGB(255, 240, 210), M.neon, DECO)
	local trains = box(dp, "TrainsSign", px0 + 1, 8.6, -170.1, px1 - 1, 10.4, -169.9, Color3.fromRGB(30, 50, 80), M.smooth, DECO)
	local tg = Kit.label(trains, Enum.NormalId.Back, "TO TRAINS", Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
	tg.PixelsPerStud = 24
	local ticket = box(dp, "TicketWindow", px0 + 0.2, 3.4, -176, px0 + 0.35, 6.6, -168, Color3.fromRGB(226, 214, 186), M.fabric, DECO)
	local tk = Kit.label(ticket, Enum.NormalId.Right, "TICKETS · CLOSED", Color3.fromRGB(110, 60, 40), nil, Enum.Font.Antique)
	tk.PixelsPerStud = 24
	box(dp, "PassageBench", px1 - 2, 0.6, -184, px1 - 0.4, 2.2, -176, C.wood, M.wood)
	-- door leaves swung open against the passage walls, a glass transom + fanlight above the opening
	box(dp, "DoorLeafOpen", px0 + 0.2, 0.6, zf - 6, px0 + 0.5, 11.2, zf - 0.6, Color3.fromRGB(60, 74, 70), M.wood, DECO)
	box(dp, "DoorLeafOpen", px1 - 0.5, 0.6, zf - 6, px1 - 0.2, 11.2, zf - 0.6, Color3.fromRGB(60, 74, 70), M.wood, DECO)
	box(dp, "Transom", px0, 11.5, zf - 0.3, px1, 17, zf, Color3.fromRGB(120, 150, 170), M.glass, DECO)
	box(dp, "Cornice", -416.5, 28, -192.5, -343.5, 29.2, zf + 0.8, Color3.fromRGB(200, 188, 160), M.concrete)
	box(dp, "Plinth", -416, 0.5, zf, -386, 2.5, zf + 0.4, Color3.fromRGB(180, 170, 150), M.concrete)
	box(dp, "Plinth", -374, 0.5, zf, -344, 2.5, zf + 0.4, Color3.fromRGB(180, 170, 150), M.concrete) -- (gap = the entrance)
	for k = 0, 2 do
		local ax = -404 + k * 24
		if k ~= 1 then
			box(dp, "ArchGlass", ax - 6, 3, zf, ax + 6, 17, zf + 0.25, Color3.fromRGB(120, 150, 170), M.glass, DECO)
		end
		local arch = Kit.part(dp, "ArchTop", Vector3.new(0.25, 12, 12), CFrame.new(ax, 17, zf + 0.12) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(120, 150, 170), M.glass,
			{ shape = "cyl", collide = false })
		arch.CastShadow = false
	end
	for _, cx in ipairs({ -416, -392, -368, -344 }) do
		Kit.post(dp, "Column", cx + (if cx < -380 then 2 else -2), zf + 1.6, 0.5, 24, 2.4, Color3.fromRGB(236, 228, 208), M.concrete)
	end
	local band = box(dp, "NameBand", -412, 24, zf, -348, 27.4, zf + 0.4, Color3.fromRGB(236, 228, 208), M.concrete, DECO)
	local gui = Kit.label(band, Enum.NormalId.Back, "UNION DEPOT", Color3.fromRGB(110, 92, 70), nil, Enum.Font.Antique)
	gui.PixelsPerStud = 16
	box(dp, "WingWest", -436, 0.5, -186, -416, 18, zf - 1, STONE, M.concrete)
	box(dp, "WingEast", -344, 0.5, -186, -330, 18, zf - 1, STONE, M.concrete)
	-- clock tower (east end)
	box(dp, "Tower", -330, 0.5, -186, -314, 62, -170, Color3.fromRGB(200, 120, 84), M.brick)
	box(dp, "TowerBelt", -330.5, 50, -186.5, -313.5, 51, -169.5, STONE, M.concrete, DECO)
	box(dp, "TowerTop", -331, 62, -187, -313, 64, -169, STONE, M.concrete)
	box(dp, "TowerCap", -327, 64, -183, -317, 72, -173, Color3.fromRGB(86, 150, 120), M.smooth)
	Kit.post(dp, "Spire", -322, -178, 72, 80, 0.6, Color3.fromRGB(86, 150, 120), M.metal, DECO)
	local face = Kit.part(dp, "ClockFace", Vector3.new(0.4, 12, 12), CFrame.new(-322, 56, -169.8) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(250, 248, 236), M.smooth,
		{ shape = "cyl", collide = false })
	face.CastShadow = false
	-- clock: 12 marks (longer at 12 / 3 / 6 / 9) + hour and minute hands (ten past ten)
	local cc = CFrame.new(-322, 56, -169.5)
	for k = 0, 11 do
		local long = k % 3 == 0
		Kit.part(dp, "ClockMark", Vector3.new(if long then 0.8 else 0.5, if long then 1.8 else 1.0, 0.1), cc * CFrame.Angles(0, 0, math.rad(-30 * k)) * CFrame.new(0, 4.8, 0),
			C.rubber, M.smooth, DECO)
	end
	Kit.part(dp, "HourHand", Vector3.new(0.9, 3.2, 0.1), cc * CFrame.Angles(0, 0, math.rad(60)) * CFrame.new(0, 1.5, -0.05), C.rubber, M.smooth, DECO)
	Kit.part(dp, "MinuteHand", Vector3.new(0.7, 4.4, 0.1), cc * CFrame.Angles(0, 0, math.rad(-60)) * CFrame.new(0, 2.1, -0.05), C.rubber, M.smooth, DECO)
	Kit.part(dp, "ClockHub", Vector3.new(1, 1, 0.15), cc * CFrame.new(0, 0, -0.1), C.rubber, M.smooth, DECO)
	-- platform + canopy behind the hall, two tracks (ballast + rails) into a tunnel portal in the west wall
	box(dp, "Platform", -436, 0, -206, -300, 1.4, -192, C.concrete, M.concrete)
	box(dp, "PlatformEdge", -436, 1.4, -206, -300, 1.45, -205.2, C.yellow, M.smooth, DECO)
	for _, px in ipairs({ -420, -390, -360, -330 }) do
		Kit.post(dp, "CanopyPost", px, -199, 1.4, 11, 0.8, C.metalDark, M.metal)
	end
	box(dp, "Canopy", -430, 11, -204, -306, 11.8, -194, Color3.fromRGB(70, 96, 88), M.metal)
	for _, tz in ipairs({ -214, -228 }) do
		box(dp, "Ballast", MX0, -1, tz - 5, -296, 0.3, tz + 5, Color3.fromRGB(120, 112, 104), M.concrete)
		for _, rz in ipairs({ tz - 2.4, tz + 2.4 }) do
			box(dp, "Rail", MX0, 0.3, rz - 0.2, -298, 0.7, rz + 0.2, C.steel, M.metal, DECO)
		end
		box(dp, "BufferStop", -300, 0.3, tz - 3, -296, 3.2, tz + 3, C.red, M.metal)
	end
	box(dp, "TunnelPortal", MX0, 0, -240, MX0 + 2, 20, -202, C.concrete, M.concrete)
	box(dp, "TunnelMouth", MX0 + 1.9, 0.3, -236, MX0 + 2.05, 14, -206, Color3.fromRGB(26, 28, 32), M.smooth, DECO)
	-- reserved (world_contract ★ Gearport): where the train stops at the platform edge — VIP visit preview (wr-design / wr-dev)
	marker(dp, "ArrivalPoint", Vector3.new(-370, 1.4, -205), Vector3.new(0, 0, -1))
	return dp
end

-- tall retaining walls on the west / east / north map edges (the river is the south edge)
local function edges(town: Instance)
	local e = Kit.folder(town, "MapEdges")
	local wallCol = Color3.fromRGB(168, 160, 150)
	box(e, "EdgeWall", MX0 - 2, -4, MZ0, MX0, 16, MZ1 + 2, wallCol, M.concrete, FLAT)
	box(e, "EdgeWall", MX1, -4, MZ0, MX1 + 2, 16, MZ1 + 2, wallCol, M.concrete, FLAT)
	box(e, "EdgeWall", MX0, -4, MZ1, MX1, 16, MZ1 + 2, wallCol, M.concrete, FLAT)
	for _, w in ipairs({ { MX0 - 2.4, MZ0, MX0 + 0.4, MZ1 + 2 }, { MX1 - 0.4, MZ0, MX1 + 2.4, MZ1 + 2 }, { MX0, MZ1 - 0.4, MX1, MZ1 + 2.4 } }) do
		box(e, "EdgeCap", w[1], 16, w[2], w[3], 17, w[4], Color3.fromRGB(150, 144, 136), M.concrete, FLAT)
	end
end

function Districts.build(garage: Model)
	local town = garage:FindFirstChild("Town") or Kit.folder(garage, "Town")
	brickyard(town)
	park(town)
	river(town)
	skyline(town)
	depot(town)
	edges(town)
end

return Districts
