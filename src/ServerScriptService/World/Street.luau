--!strict
-- World/Street: makes the US neighbourhood feel alive — a cross street with a signalled intersection east of
-- the lot, a strip of small shops across the street (different widths / heights / colours / awnings), street
-- signs, crosswalks and parallel parking with a couple of stand-in cars. Looks only (no contract names).
-- Shop words are plain English nouns (no brands).

local Kit = require(script.Parent.Kit)
local Site = require(script.Parent.Site)
local C, M = Kit.C, Kit.M
local box, rod = Kit.box, Kit.rod

local Street = {}

local OUTLINE = Color3.fromRGB(28, 30, 40)
local X0, X1 = Site.CROSS_X0, Site.CROSS_X1

local function crossStreet(st: Instance)
	local road = Kit.folder(st, "CrossStreet")
	-- asphalt: south arm, the two sidewalk squares at the intersection, north arm
	box(road, "Road", X0, -1, -258, X1, 0, -104, C.asphalt, M.asphalt) -- (stage 2: runs down to the river walk)
	box(road, "Road", X0, -1, -104, X1, 0, Site.ROAD_Z0, C.asphalt, M.asphalt)
	box(road, "Road", X0, -1, Site.WALK_Z0, X1, 0, Site.WALK_Z1, C.asphalt, M.asphalt)
	box(road, "Road", X0, -1, Site.WALK_Z1, X1, 0, 212, C.asphalt, M.asphalt) -- (stage 3: up to Foundry Road)
	-- sidewalks + curbs along it
	for _, seg in ipairs({ { -258, -134 }, { Site.WALK_Z1, 192 } }) do
		box(road, "Sidewalk", X0 - 4, -1, seg[1], X0, 0.5, seg[2], C.sidewalk, M.concrete)
		box(road, "Sidewalk", X1, -1, seg[1], X1 + 4, 0.5, seg[2], C.sidewalk, M.concrete)
		box(road, "Curb", X0 - 0.5, -1, seg[1], X0, 0.5, seg[2], C.curb, M.concrete)
		box(road, "Curb", X1, -1, seg[1], X1 + 0.5, 0.5, seg[2], C.curb, M.concrete)
	end
	-- double yellow centre line (stops at the crosswalks)
	local cx = (X0 + X1) / 2
	for _, seg in ipairs({ { -250, -143 }, { -56, 190 } }) do
		box(road, "CentreLine", cx - 0.5, 0, seg[1], cx - 0.2, 0.05, seg[2], C.lineYellow, M.smooth, { collide = false })
		box(road, "CentreLine", cx + 0.2, 0, seg[1], cx + 0.5, 0.05, seg[2], C.lineYellow, M.smooth, { collide = false })
	end
	-- crosswalks (continental bars): across the main road west of the corner, across the cross street N and S
	for z = -94.6, -76, 2.4 do
		box(road, "Crosswalk", X0 - 10, 0, z, X0 - 2, 0.05, z + 1.2, C.lineWhite, M.smooth, { collide = false })
	end
	for x = X0 + 1, X1 - 2, 2.4 do
		box(road, "Crosswalk", x, 0, -141, x + 1.2, 0.05, -135, C.lineWhite, M.smooth, { collide = false })
		box(road, "Crosswalk", x, 0, -65, x + 1.2, 0.05, -58, C.lineWhite, M.smooth, { collide = false })
	end
	-- stop bars
	box(road, "StopBar", X0 - 12.5, 0, Site.ROAD_Z0, X0 - 11.7, 0.05, Site.ROAD_Z1, C.lineWhite, M.smooth, { collide = false })
	box(road, "StopBar", X1 + 11.7, 0, -126, X1 + 12.5, 0.05, -104, C.lineWhite, M.smooth, { collide = false })
	box(road, "StopBar", X0, 0, -143, cx, 0.05, -142.2, C.lineWhite, M.smooth, { collide = false })
	box(road, "StopBar", cx, 0, -56.8, X1, 0.05, -56, C.lineWhite, M.smooth, { collide = false })
end

local function signalHead(parent: Instance, cf: CFrame)
	-- 3-light box; cf looks toward the drivers it faces
	Kit.part(parent, "SignalBox", Vector3.new(1.4, 4, 1.2), cf, Color3.fromRGB(240, 196, 40), M.smooth)
	local colors = { Color3.fromRGB(220, 50, 40), Color3.fromRGB(250, 190, 40), Color3.fromRGB(60, 200, 90) }
	for i, col in ipairs(colors) do
		local lit = i == 3
		Kit.part(parent, "Lamp", Vector3.new(0.2, 0.9, 0.9), cf * CFrame.new(0, 1.3 - (i - 1) * 1.3, -0.62) * CFrame.Angles(0, math.rad(90), 0),
			lit and col or Color3.new(col.R * 0.35, col.G * 0.35, col.B * 0.35), lit and M.neon or M.smooth, { shape = "cyl", collide = false })
	end
end

local function nameSign(parent: Instance, pos: Vector3, along: Vector3, text: string)
	local p = Kit.part(parent, "StreetName", Vector3.new(0.12, 1.1, 5.2), CFrame.lookAt(pos, pos + along),
		Color3.fromRGB(30, 120, 70), M.smooth, { collide = false })
	Kit.label(p, Enum.NormalId.Left, text, Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
	Kit.label(p, Enum.NormalId.Right, text, Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
end

local function intersection(st: Instance)
	local sig = Kit.folder(st, "Signals")
	local pole = C.trim
	-- NW corner: mast arm over the eastbound lane (drivers coming from the west look toward -X)
	local nw = Vector3.new(X0 - 2, 0.5, Site.WALK_Z0 + 2)
	Kit.post(sig, "SignalPole", nw.X, nw.Z, 0.5, 20, 0.9, pole, M.metal)
	rod(sig, "MastArm", Vector3.new(nw.X, 19, nw.Z), Vector3.new(nw.X, 19, nw.Z - 16), 0.5, 0.5, pole, M.metal)
	signalHead(sig, CFrame.lookAt(Vector3.new(nw.X, 17, nw.Z - 6), Vector3.new(nw.X - 10, 17, nw.Z - 6)))
	signalHead(sig, CFrame.lookAt(Vector3.new(nw.X, 17, nw.Z - 13), Vector3.new(nw.X - 10, 17, nw.Z - 13)))
	nameSign(sig, Vector3.new(nw.X, 14.6, nw.Z), Vector3.new(1, 0, 0), "PISTON AVE")
	nameSign(sig, Vector3.new(nw.X, 13.2, nw.Z), Vector3.new(0, 0, 1), "CHASSIS ST")
	-- SE corner: mast arm over the westbound lane
	local se = Vector3.new(X1 + 2, 0.5, -128) -- far corner of the westbound half (Gearport avenue)
	Kit.post(sig, "SignalPole", se.X, se.Z, 0.5, 20, 0.9, pole, M.metal)
	rod(sig, "MastArm", Vector3.new(se.X, 19, se.Z), Vector3.new(se.X, 19, se.Z + 16), 0.5, 0.5, pole, M.metal)
	signalHead(sig, CFrame.lookAt(Vector3.new(se.X, 17, se.Z + 6), Vector3.new(se.X + 10, 17, se.Z + 6)))
	signalHead(sig, CFrame.lookAt(Vector3.new(se.X, 17, se.Z + 13), Vector3.new(se.X + 10, 17, se.Z + 13)))
	-- NE / SW corners: pedestal signals for the cross street + push-button posts
	for _, c in ipairs({ { X1 + 2, Site.WALK_Z1 - 2, 1 }, { X0 - 2, -130, -1 } }) do
		Kit.post(sig, "SignalPole", c[1], c[2], 0.5, 12, 0.6, pole, M.metal)
		signalHead(sig, CFrame.lookAt(Vector3.new(c[1], 13.5, c[2]), Vector3.new(c[1], 13.5, c[2] + c[3] * 10)))
	end
	-- speed limit + one-way-ish "NO PARKING" sign (plain words)
	local function plate(name: string, x: number, z: number, text: string, face: Vector3)
		Kit.post(sig, "SignPost", x, z, 0.5, 8, 0.25, C.steel, M.metal)
		local pos = Vector3.new(x, 7, z)
		local p = Kit.part(sig, name, Vector3.new(2.4, 3, 0.1), CFrame.lookAt(pos, pos + face), Color3.fromRGB(250, 250, 246), M.smooth, { collide = false })
		Kit.label(p, Enum.NormalId.Front, text, Color3.fromRGB(30, 30, 36), nil, Enum.Font.GothamBold)
	end
	plate("SpeedLimit", -150, -73, "SPEED\nLIMIT\n30", Vector3.new(-1, 0, 0))
	plate("SpeedLimit", 160, -129, "SPEED\nLIMIT\n30", Vector3.new(1, 0, 0))
end

local AWNINGS = {
	{ Color3.fromRGB(206, 44, 38), Color3.fromRGB(250, 248, 240) },
	{ Color3.fromRGB(40, 120, 90), Color3.fromRGB(240, 236, 220) },
	{ Color3.fromRGB(44, 98, 190), Color3.fromRGB(250, 248, 240) },
	{ Color3.fromRGB(236, 150, 40), Color3.fromRGB(250, 246, 230) },
	{ Color3.fromRGB(120, 60, 120), Color3.fromRGB(240, 230, 240) },
}

-- one shop facing +Z (the street), front face at zf
local function shop(parent: Instance, name: string, x0: number, x1: number, zf: number, h: number, wall: Color3, mat: Enum.Material,
	awning: number, word: string, storeys: number, seed: number)
	local r = Kit.rng(seed)
	local m = Kit.model(parent, name)
	local d = 30
	local z0 = zf - d
	box(m, "Body", x0, 0, z0, x1, h, zf, wall, mat)
	-- parapet: flat or stepped in the middle (variety)
	box(m, "Cap", x0 - 0.3, h, z0 - 0.3, x1 + 0.3, h + 0.6, zf + 0.3, C.trim, M.concrete)
	if seed % 2 == 0 then
		local mid = (x0 + x1) / 2
		box(m, "Step", mid - 6, h + 0.6, zf - 0.6, mid + 6, h + 3, zf, wall, mat)
		box(m, "StepCap", mid - 6.3, h + 3, zf - 0.9, mid + 6.3, h + 3.4, zf + 0.3, C.trim, M.concrete)
	end
	box(m, "Base", x0 - 0.2, 0, zf, x1 + 0.2, 1.2, zf + 0.2, C.plinth, M.concrete)
	-- storefront: glass, mullions, door (door off-centre, side alternates)
	local gx0, gx1 = x0 + 2.4, x1 - 2.4
	box(m, "Glass", gx0, 2, zf, gx1, 10, zf + 0.2, C.glass, M.glass, { transparency = 0.25 })
	local n = math.max(2, math.floor((gx1 - gx0) / 7))
	for k = 0, n do
		local mx = gx0 + (gx1 - gx0) * k / n
		box(m, "Mullion", mx - 0.2, 2, zf, mx + 0.2, 10, zf + 0.4, C.frame, M.metal)
	end
	box(m, "Sill", gx0, 1.6, zf, gx1, 2, zf + 0.5, C.frame, M.metal)
	box(m, "Head", gx0, 10, zf, gx1, 10.4, zf + 0.4, C.frame, M.metal)
	local dx = (seed % 3 == 0) and (gx0 + 3) or (gx1 - 3)
	box(m, "Door", dx - 1.6, 0.5, zf, dx + 1.6, 8.6, zf + 0.3, C.frame, M.metal)
	box(m, "DoorGlass", dx - 1.2, 1.2, zf + 0.3, dx + 1.2, 8.0, zf + 0.35, C.glass, M.glass, { transparency = 0.3, collide = false })
	-- striped awning (2 colours), slightly different depth per shop
	local aw = AWNINGS[(awning - 1) % #AWNINGS + 1]
	local depth = 3.2 + r() * 1.4
	local stripes = math.floor((gx1 - gx0) / 2)
	for k = 0, stripes - 1 do
		local sx0 = gx0 + (gx1 - gx0) * k / stripes
		local sx1 = gx0 + (gx1 - gx0) * (k + 1) / stripes
		local col = aw[(k % 2) + 1]
		Kit.part(m, "Awning", Vector3.new(sx1 - sx0, 0.3, depth + 0.6), CFrame.new((sx0 + sx1) / 2, 11.4, zf + depth / 2) * CFrame.Angles(math.rad(16), 0, 0), col, M.smooth) -- front edge down
	end
	box(m, "AwningValance", gx0, 9.9, zf + depth - 0.1, gx1, 10.8, zf + depth + 0.2, aw[1], M.smooth)
	-- sign band with a plain word
	local sign = box(m, "SignBand", gx0 + 1, 12.4, zf, gx1 - 1, 14.8, zf + 0.4, Color3.fromRGB(250, 248, 240), M.smooth)
	Kit.label(sign, Enum.NormalId.Back, word, aw[1], OUTLINE)
	-- upper floor windows
	if storeys >= 2 then
		local wn = math.max(2, math.floor((x1 - x0) / 8))
		for k = 0, wn - 1 do
			local wx = x0 + (x1 - x0) * (k + 0.5) / wn
			box(m, "UpperWindow", wx - 1.8, 16.5, zf, wx + 1.8, 21, zf + 0.2, C.glass, M.glass, { transparency = 0.2 })
			box(m, "UpperSill", wx - 2.1, 16.2, zf, wx + 2.1, 16.5, zf + 0.5, C.lineWhite, M.smooth)
		end
	end
	-- roof AC
	local ax = x0 + 4 + r() * (x1 - x0 - 10)
	box(m, "RoofAC", ax, h + 0.6, z0 + 8, ax + 4, h + 3, z0 + 13, C.steel, M.metal)
	return m
end

local function shops(st: Instance)
	local strip = Kit.folder(st, "Shops")
	local zf = -108 -- front faces 4 behind the far sidewalk
	-- (the shops across the avenue are World/Gearport; the corner north-east of the crossing is Market Hall:
	-- World/GearportWorks. shop() stays for later street pieces.)
	local _ = zf
	local _s = shop
end

local function parallelParking(st: Instance, standInCar: (Instance, string, CFrame, Color3) -> Model)
	local pk = Kit.folder(st, "StreetParking")
	-- T marks along the far curb in front of the shops (westbound lane edge)
	for x = 44, 190, 20 do
		box(pk, "ParkMark", x - 0.15, 0, -95.8, x + 0.15, 0.05, -88.6, C.lineWhite, M.smooth, { collide = false })
		box(pk, "ParkMark", x - 1.5, 0, -88.9, x + 1.5, 0.05, -88.6, C.lineWhite, M.smooth, { collide = false })
	end
	standInCar(pk, "StreetCar2", CFrame.new(64.5, 0, -91.6) * CFrame.Angles(0, math.rad(90.8), 0), Color3.fromRGB(120, 170, 120))
	standInCar(pk, "StreetCar3", CFrame.new(143.6, 0, -91.8) * CFrame.Angles(0, math.rad(89.2), 0), Color3.fromRGB(60, 64, 76))
end

function Street.build(garage: Model, standInCar: (Instance, string, CFrame, Color3) -> Model)
	local town = garage:FindFirstChild("Town") or Kit.folder(garage, "Town")
	local st = Kit.folder(town, "StreetLife")
	crossStreet(st)
	intersection(st)
	shops(st)
	local _ = parallelParking -- (street parking moved to the avenue's westbound half: World/Gearport)
end

return Street
