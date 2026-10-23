--!strict
-- World/Town: what you see around the shop — suburban houses across the street (style_B: clean, bright US
-- neighbourhood), street trees, two small commercial neighbours beside the lot. Same few shapes reused (cheap),
-- each copy turned / sized / coloured a little differently so it doesn't look copy-pasted.

local Kit = require(script.Parent.Kit)
local C, M = Kit.C, Kit.M
local box = Kit.box

local Town = {}

local HOUSE_WALLS = {
	Color3.fromRGB(236, 226, 204), Color3.fromRGB(206, 222, 232), Color3.fromRGB(232, 214, 214),
	Color3.fromRGB(214, 228, 206), Color3.fromRGB(238, 236, 228), Color3.fromRGB(226, 214, 190),
}
local ROOFS = { Color3.fromRGB(92, 96, 112), Color3.fromRGB(120, 84, 72), Color3.fromRGB(78, 82, 90), Color3.fromRGB(104, 112, 124) }
local LEAF = { Color3.fromRGB(86, 150, 70), Color3.fromRGB(104, 166, 78), Color3.fromRGB(74, 136, 66) }

-- gable roof, ridge along X, slopes to -Z and +Z
local function gable(parent: Instance, x0: number, x1: number, z0: number, z1: number, y: number, rise: number, color: Color3)
	local zm = (z0 + z1) / 2
	local w = x1 - x0
	-- back half: default wedge slope faces -Z (low edge at z0)
	Kit.part(parent, "Roof", Vector3.new(w, rise, zm - z0), CFrame.new((x0 + x1) / 2, y + rise / 2, (z0 + zm) / 2), color, M.smooth, { shape = "wedge" })
	-- front half: turned 180 so the slope faces +Z (low edge at z1)
	Kit.part(parent, "Roof", Vector3.new(w, rise, z1 - zm), CFrame.new((x0 + x1) / 2, y + rise / 2, (zm + z1) / 2) * CFrame.Angles(0, math.pi, 0),
		color, M.smooth, { shape = "wedge" })
end

local function window(parent: Instance, x: number, y: number, z: number, w: number, h: number, frame: Color3)
	-- on a +Z facing wall whose outer face is at z
	box(parent, "WindowFrame", x - w / 2 - 0.3, y - h / 2 - 0.3, z, x + w / 2 + 0.3, y + h / 2 + 0.3, z + 0.2, frame, M.smooth)
	box(parent, "WindowGlass", x - w / 2, y - h / 2, z + 0.1, x + w / 2, y + h / 2, z + 0.3, C.glass, M.glass, { transparency = 0.2 })
	box(parent, "WindowBar", x - 0.1, y - h / 2, z + 0.25, x + 0.1, y + h / 2, z + 0.35, frame, M.smooth)
	box(parent, "Sill", x - w / 2 - 0.5, y - h / 2 - 0.5, z, x + w / 2 + 0.5, y - h / 2 - 0.3, z + 0.6, frame, M.smooth)
end

-- a one-storey suburban house facing +Z (the street). cx = centre x, zf = front wall face z.
local function house(parent: Instance, name: string, cx: number, zf: number, w: number, d: number, i: number, r: () -> number)
	local m = Kit.model(parent, name)
	local wall = HOUSE_WALLS[(i - 1) % #HOUSE_WALLS + 1]
	local roof = ROOFS[(i - 1) % #ROOFS + 1]
	local trim = Color3.fromRGB(248, 248, 244)
	local x0, x1, z0, z1 = cx - w / 2, cx + w / 2, zf - d, zf
	local h = 12
	box(m, "Foundation", x0 - 0.3, 0, z0 - 0.3, x1 + 0.3, 1.2, z1 + 0.3, C.plinth, M.concrete)
	box(m, "Walls", x0, 1.2, z0, x1, h, z1, wall, M.smooth)
	box(m, "Fascia", x0 - 1.2, h - 0.4, z0 - 1.2, x1 + 1.2, h, z1 + 1.2, trim, M.smooth)
	gable(m, x0 - 1.2, x1 + 1.2, z0 - 1.2, z1 + 1.2, h, 7 + math.floor(r() * 3), roof)
	-- attached garage on one side (alternating), white sectional door
	local left = i % 2 == 0
	local gx0 = left and x0 or (x1 - 12)
	local gx1 = gx0 + 12
	box(m, "GarageDoor", gx0 + 1.5, 1.2, z1, gx1 - 1.5, 9.4, z1 + 0.3, trim, M.smooth)
	for y = 3.2, 8.2, 2 do
		box(m, "GarageDoorLine", gx0 + 1.5, y, z1 + 0.3, gx1 - 1.5, y + 0.1, z1 + 0.35, Color3.fromRGB(214, 214, 210), M.smooth, { collide = false })
	end
	-- front door + step + porch light, windows
	local dx = left and (x1 - 8) or (x0 + 8)
	box(m, "FrontDoor", dx - 1.6, 1.2, z1, dx + 1.6, 8.4, z1 + 0.3, ROOFS[(i % #ROOFS) + 1], M.smooth)
	box(m, "DoorFrame", dx - 2, 8.4, z1, dx + 2, 8.8, z1 + 0.4, trim, M.smooth)
	box(m, "Step", dx - 2.6, 0, z1, dx + 2.6, 1.2, z1 + 2.4, C.concrete, M.concrete)
	local wx = left and (x1 - 3.5) or (x0 + 3.5)
	window(m, wx, 6, z1, 3.4, 3.6, trim)
	if w >= 34 then
		window(m, left and (x1 - 13) or (x0 + 13), 6, z1, 3.4, 3.6, trim)
	end
	-- driveway to the far sidewalk
	box(m, "Driveway", gx0 + 1, -1, z1, gx1 - 1, 0.05, -104, C.concrete, M.concrete)
	-- a hedge / bush pair by the door
	for k = -1, 1, 2 do
		Kit.part(m, "Bush", Vector3.new(2.6, 2.4, 2.6) * (0.85 + r() * 0.3), CFrame.new(dx + k * 4.2, 1.2, z1 + 1.6),
			LEAF[(i + k + 2) % #LEAF + 1], M.grass, { shape = "ball" })
	end
	return m
end

function Town.tree(parent: Instance, x: number, z: number, scale: number, seed: number)
	local r = Kit.rng(seed)
	local m = Kit.model(parent, "Tree")
	local trunkH = 7 * scale
	Kit.post(m, "Trunk", x, z, 0, trunkH + 2, 1.2 * scale, Color3.fromRGB(116, 84, 60), M.wood)
	for k = 1, 3 do
		local a = r() * math.pi * 2
		local s = (6 + r() * 3) * scale
		Kit.part(m, "Leaves", Vector3.new(s, s, s), CFrame.new(x + math.cos(a) * 1.6 * scale, trunkH + 2 + (k - 1) * 1.6 * scale, z + math.sin(a) * 1.6 * scale),
			LEAF[(seed + k) % #LEAF + 1], M.grass, { shape = "ball", shadow = k == 1 })
	end
	return m
end

function Town.build(garage: Model)
	local town = Kit.folder(garage, "Town")
	local r = Kit.rng(41)
	-- (the houses that faced the old road are gone: that side is Piston Avenue's far half + shop row now, World/Gearport.
	-- Stage 2 brings the brick bungalow streets behind the shops; house() is kept for that.)
	local _ = house
	-- street trees on the grass beyond the lot ends
	for i, p in ipairs({ { -118, -40 }, { -122, -4 }, { -116, 30 }, { 118, -30 }, { 186, -50 }, { -196, -48 }, { 70, 70 }, { -80, 96 }, { 20, 104 } }) do
		Town.tree(town, p[1], p[2], 0.9 + r() * 0.35, 200 + i)
	end

	-- backdrop: loose rows of bigger trees behind the houses and behind the shop (the world reads wider)
	local n = 0
	for x = -240, 240, 17 do
		n += 1
		local onCross = x > 190 and x < 246 -- keep the cross street (and the Old Works fence at x 236) clear
		-- (the tree row behind the avenue shops is gone: Brickyard Heights houses + street trees are there now)
		if (x < 20 or x > 70) and not onCross then -- keep the junkyard road clear
			Town.tree(town, x + (r() - 0.5) * 8, 100 + r() * 30, 1.1 + r() * 0.5, 600 + n)
		end
	end

	-- commercial neighbours beside the lot (front = -Z toward the road)
	local function shopBlock(name: string, x0: number, x1: number, z0: number, z1: number, h: number, col: Color3, mat: Enum.Material, awning: Color3)
		local m = Kit.model(town, name)
		box(m, "Body", x0, 0, z0, x1, h, z1, col, mat)
		box(m, "Cap", x0 - 0.4, h, z0 - 0.4, x1 + 0.4, h + 0.8, z1 + 0.4, C.trim, M.concrete)
		box(m, "Base", x0 - 0.2, 0, z0 - 0.2, x1 + 0.2, 1.2, z0, C.plinth, M.concrete)
		box(m, "ShopGlass", x0 + 3, 2, z0 - 0.2, x1 - 3, 10, z0, C.glass, M.glass, { transparency = 0.25 })
		box(m, "ShopFrame", x0 + 2.6, 10, z0 - 0.4, x1 - 2.6, 10.6, z0, C.frame, M.metal)
		box(m, "Awning", x0 + 2, 11.4, z0 - 4, x1 - 2, 11.8, z0, awning, M.smooth)
		box(m, "SignBand", x0 + 4, 12.6, z0 - 0.4, x1 - 4, 15, z0, Color3.fromRGB(250, 248, 240), M.smooth)
	end
	shopBlock("NeighbourWest", -164, -112, -62, 10, 20, Color3.fromRGB(196, 186, 168), M.brick, Color3.fromRGB(46, 130, 96))
	shopBlock("NeighbourEast", 124, 176, -62, 20, 16, Color3.fromRGB(182, 112, 90), M.brick, Color3.fromRGB(226, 160, 40))
end

return Town
