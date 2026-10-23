--!strict
-- World/Junkyard: the Lv6 salvage yard at the end of the junkyard road (blockout; real photos
-- notes/research/ref_junkyard). Yard = x -40..140, z 204..380, entrance gate on the south side at the road.
-- Fence, gate, container office, tow-truck spot, 10 wreck spots (where buyable wrecks appear), pink places
-- for wreck piles and the scrap crane. Names: docs/specs/world_contract.md (Junkyard).

local Kit = require(script.Parent.Kit)
local GearportProps = require(script.Parent.GearportProps)
local C, M = Kit.C, Kit.M
local box, marker, rod = Kit.box, Kit.marker, Kit.rod

local Junkyard = {}

local YX0, YX1, YZ0, YZ1 = -40, 140, 204, 380
local WORN = { "BG_Sedan_1_Worn", "BG_Sedan_2_Worn", "BG_Pickup_1_Worn", "BG_Sedan_1_Worn" }
local WORN_SEDAN = { "BG_Sedan_1_Worn", "BG_Sedan_2_Worn" }
local GATE_X0, GATE_X1 = 33, 61 -- 28 wide, the road (x 40..54) runs through the middle
local FENCE_H = 10
local DIRT = Color3.fromRGB(150, 124, 94)
local GRAVEL = Color3.fromRGB(150, 144, 132)
local RUST = { Color3.fromRGB(178, 112, 74), Color3.fromRGB(156, 138, 120), Color3.fromRGB(146, 152, 158) }
local POST = Color3.fromRGB(84, 80, 78)

local function fenceRun(parent: Instance, a: Vector3, b: Vector3, seed: number)
	-- corrugated-sheet fence from a to b (straight along X or Z): panels 24 long in 3 rust/grey tones, a post at
	-- each joint, ONE top rail for the whole run (perf pass 10-21: 3 parts / 12 studs -> about 2 parts / 24)
	local r = Kit.rng(seed)
	local len = (b - a).Magnitude
	local dir = (b - a).Unit
	local n = math.max(1, math.round(len / 24))
	local step = len / n
	for i = 0, n - 1 do
		local p0 = a + dir * (i * step)
		local p1 = a + dir * ((i + 1) * step)
		local mid = (p0 + p1) / 2
		local h = FENCE_H + (r() - 0.5) * 0.8
		local col = RUST[math.floor(r() * #RUST) + 1]
		Kit.part(parent, "FencePanel", Vector3.new(0.4, h, step - 0.1), CFrame.lookAt(Vector3.new(mid.X, h / 2, mid.Z), Vector3.new(p1.X, h / 2, p1.Z)),
			col, M.metal)
		Kit.post(parent, "FencePost", p0.X, p0.Z, 0, FENCE_H + 0.8, 0.6, POST, M.metal)
	end
	Kit.post(parent, "FencePost", b.X, b.Z, 0, FENCE_H + 0.8, 0.6, POST, M.metal)
	local mid = (a + b) / 2
	Kit.part(parent, "FenceRail", Vector3.new(0.3, 0.3, len), CFrame.lookAt(Vector3.new(mid.X, FENCE_H - 0.6, mid.Z), Vector3.new(b.X, FENCE_H - 0.6, b.Z)),
		POST, M.metal, { collide = false, shadow = false })
end

local function gate(jy: Instance)
	local g = Kit.model(jy, "Gate")
	g:SetAttribute("Open", true)
	-- tall gate posts + sign beam across the top
	for _, gx in ipairs({ GATE_X0, GATE_X1 }) do
		box(g, "GatePost", gx - 0.8, 0, YZ0 - 0.8, gx + 0.8, 16, YZ0 + 0.8, POST, M.metal)
	end
	box(g, "SignBeam", GATE_X0 - 0.8, 16, YZ0 - 0.6, GATE_X1 + 0.8, 16.8, YZ0 + 0.6, POST, M.metal)
	local sign = box(g, "Sign", GATE_X0 + 2, 16.8, YZ0 - 0.3, GATE_X1 - 2, 20.2, YZ0 + 0.3, Color3.fromRGB(206, 44, 38), M.smooth)
	Kit.label(sign, Enum.NormalId.Front, "SALVAGE YARD", Color3.new(1, 1, 1), Color3.fromRGB(28, 30, 40))
	Kit.label(sign, Enum.NormalId.Back, "SALVAGE YARD", Color3.new(1, 1, 1), Color3.fromRGB(28, 30, 40))
	-- two chain-link leaves, swung all the way back against the inside of the fence (hinged on the posts), so they
	-- never stand across the lane to the office; the mesh is solid (QA 10-21: it used to be walk-through)
	for i, gx in ipairs({ GATE_X0, GATE_X1 }) do
		local leaf = Kit.model(g, i == 1 and "GateL" or "GateR")
		local s = if i == 1 then -1 else 1
		local xa, xb = gx + s * 0.8, gx + s * 13.8 -- hinge end, free end
		local x0, x1 = math.min(xa, xb), math.max(xa, xb)
		local z = YZ0 + 1.1
		box(leaf, "Frame", x0, 0.4, z - 0.2, x1, 0.8, z + 0.2, C.steel, M.metal)
		box(leaf, "Frame", x0, 8.6, z - 0.2, x1, 9.0, z + 0.2, C.steel, M.metal)
		local xe = if s < 0 then x0 else x1 - 0.4
		box(leaf, "Frame", xe, 0.4, z - 0.2, xe + 0.4, 9.0, z + 0.2, C.steel, M.metal)
		box(leaf, "Mesh", x0, 0.8, z - 0.05, x1, 8.6, z + 0.05, C.steel, M.metal, { transparency = 0.6 })
		Kit.post(leaf, "Wheel", xe + 0.2, z, 0, 0.4, 0.4, C.rubber, M.smooth)
	end
	marker(g, "GatePoint", Vector3.new(47, 0, YZ0), Vector3.new(0, 0, 1))
end

local function office(jy: Instance)
	-- 20 ft shipping container on blocks, door + pay window on the +X side (facing the yard lane)
	local o = Kit.model(jy, "Office")
	local x0, x1, z0, z1 = 14, 22.8, 210, 231.8
	local y0, y1 = 0.8, 0.8 + 9.3
	local blue = Color3.fromRGB(44, 98, 170)
	for _, bz in ipairs({ z0 + 1, z1 - 1 }) do
		for _, bx in ipairs({ x0 + 1, x1 - 1 }) do
			box(o, "Block", bx - 0.8, 0, bz - 0.8, bx + 0.8, y0, bz + 0.8, C.concrete, M.concrete)
		end
	end
	box(o, "Container", x0, y0, z0, x1, y1, z1, blue, M.metal)
	-- corrugation ribs on both long sides (depth)
	for z = z0 + 1, z1 - 1, 3.2 do
		box(o, "Rib", x0 - 0.15, y0 + 0.4, z, x0, y1 - 0.4, z + 0.6, Color3.fromRGB(36, 84, 150), M.metal, { collide = false, shadow = false })
		local inOpening = (z > 213 and z < 218.5) or (z > 220.6 and z < 227.4)
		if not inOpening then
			box(o, "Rib", x1, y0 + 0.4, z, x1 + 0.15, y1 - 0.4, z + 0.6, Color3.fromRGB(36, 84, 150), M.metal, { collide = false, shadow = false })
		end
	end
	box(o, "Door", x1, y0, 214, x1 + 0.2, y0 + 7.4, 218, C.lineWhite, M.smooth)
	box(o, "Window", x1, y0 + 3.6, 221, x1 + 0.2, y0 + 7.4, 227, C.glass, M.glass, { transparency = 0.3 })
	box(o, "WindowFrame", x1, y0 + 3.4, 220.8, x1 + 0.3, y0 + 3.6, 227.2, C.lineWhite, M.smooth)
	box(o, "PayShelf", x1, y0 + 3.2, 221, x1 + 1.2, y0 + 3.5, 227, C.wood, M.wood)
	box(o, "Awning", x1, y0 + 7.8, 212, x1 + 3, y0 + 8.1, 229, C.yellow, M.smooth)
	local plate = box(o, "Plate", x1 + 0.2, y0 + 8.3, 214, x1 + 0.4, y0 + 9.1, 227, Color3.fromRGB(250, 248, 240), M.smooth)
	Kit.label(plate, Enum.NormalId.Right, "OFFICE  ·  BUY / SELL", C.blue, nil)
	-- steps to the door
	box(o, "Step", x1, 0, 213.6, x1 + 2.4, 0.4, 218.4, C.metal, M.diamond)
	box(o, "Step", x1, 0.4, 213.6, x1 + 1.2, 0.8, 218.4, C.metal, M.diamond)
	-- AC unit on the back end
	box(o, "AC", x0 + 2, y1 - 3.4, z1, x0 + 6, y1 - 0.8, z1 + 1.4, C.steel, M.metal)
	marker(o, "ServicePoint", Vector3.new(x1 + 2.6, 0, 224), Vector3.new(-1, 0, 0)) -- player at the pay window
	marker(o, "DoorPoint", Vector3.new(x1 + 3.2, 0, 216), Vector3.new(-1, 0, 0))
end

function Junkyard.build(garage: Model)
	local jy = garage:FindFirstChild("Junkyard") or Kit.model(garage, "Junkyard")
	jy:SetAttribute("UnlockLevel", 8)
	local yard = Kit.folder(jy, "Yard")
	-- ground: dirt, a gravel lane up the middle, a cross lane at the back (turnaround)
	box(yard, "Dirt", YX0, -1, YZ0, YX1, 0, YZ1, DIRT, Enum.Material.Ground)
	box(yard, "Lane", 37, 0, YZ0, 57, 0.04, 344, GRAVEL, Enum.Material.Pebble, { collide = false })
	box(yard, "Lane", -30, 0, 326, 130, 0.04, 344, GRAVEL, Enum.Material.Pebble, { collide = false })
	-- oil stains / grass tufts (small, scattered)
	local r = Kit.rng(131)
	for _ = 1, 8 do
		local x = YX0 + 6 + r() * (YX1 - YX0 - 12)
		local z = YZ0 + 10 + r() * (YZ1 - YZ0 - 20)
		if r() > 0.5 then
			box(yard, "Stain", x - 1.5, 0, z - 1, x + 1.5, 0.05, z + 1.2, Color3.fromRGB(96, 84, 72), M.smooth, { collide = false })
		else
			Kit.part(yard, "Tuft", Vector3.new(1.6, 1.0, 1.6), CFrame.new(x, 0.2, z), Color3.fromRGB(110, 150, 70), M.grass, { shape = "ball", collide = false })
		end
	end

	-- fence (south side split by the gate)
	local fence = Kit.folder(jy, "Fence")
	fenceRun(fence, Vector3.new(YX0, 0, YZ0), Vector3.new(GATE_X0 - 0.8, 0, YZ0), 141)
	fenceRun(fence, Vector3.new(GATE_X1 + 0.8, 0, YZ0), Vector3.new(YX1, 0, YZ0), 142)
	fenceRun(fence, Vector3.new(YX1, 0, YZ0), Vector3.new(YX1, 0, YZ1), 143)
	fenceRun(fence, Vector3.new(YX1, 0, YZ1), Vector3.new(YX0, 0, YZ1), 144)
	fenceRun(fence, Vector3.new(YX0, 0, YZ1), Vector3.new(YX0, 0, YZ0), 145)
	gate(jy)
	office(jy)

	-- tow truck spot (inside, right of the gate), painted outline
	marker(jy, "TowSpot", Vector3.new(74, 0, 228), Vector3.new(0, 0, -1), Vector3.new(10, 0.2, 30))
	for _, e in ipairs({ { 68.6, 212, 69, 244 }, { 79, 212, 79.4, 244 }, { 68.6, 243.6, 79.4, 244 } }) do
		box(yard, "TowLine", e[1], 0, e[2], e[3], 0.06, e[4], C.yellow, M.smooth, { collide = false })
	end
	local tow = box(yard, "TowSign", 70, 0.06, 214, 78, 0.07, 218, C.yellow, M.smooth, { collide = false })
	tow.Transparency = 1
	Kit.label(tow, Enum.NormalId.Top, "TOW", C.yellow, nil)

	-- wreck spots: two rows facing the lane (car front toward the lane), with rusty wheel stands
	local spots = Kit.folder(jy, "WreckSpots")
	local i = 0
	for _, z in ipairs({ 252, 268, 284, 300, 316 }) do
		for _, side in ipairs({ -1, 1 }) do
			i += 1
			local cx = side < 0 and 22 or 72
			local look = Vector3.new(-side, 0, 0)
			marker(spots, "Spot" .. i, Vector3.new(cx, 0, z), look, Vector3.new(8, 0.2, 18))
			-- 4 stacked-rim stands under where the wheels would be (U-pull look)
			for _, w in ipairs({ { -5, -3.25 }, { 5, 3.25 } }) do
				Kit.post(yard, "RimStand", cx + w[1], z + w[2], 0, 0.9, 1.6, RUST[(i + w[1]) % 3 + 1], M.metal, { shadow = false })
			end
		end
	end

	-- wreck piles: crushed worn background cars stacked a few high (bundle meshes, junkyard piles only — main
	-- decision 10-21; the old slab stand-in stays as the fallback)
	local piles = Kit.folder(jy, "Piles")
	local pileBoxes = {
		{ -36, 350, -6, 376, 14 }, { -2, 352, 30, 376, 18 }, { 64, 350, 100, 376, 12 }, { 104, 350, 136, 376, 16 },
		{ -38, 240, -26, 320, 10 }, { 124, 250, 138, 300, 12 },
	}
	local SLAB_COLORS = { Color3.fromRGB(170, 70, 60), Color3.fromRGB(80, 110, 160), Color3.fromRGB(200, 196, 186),
		Color3.fromRGB(96, 120, 90), Color3.fromRGB(150, 120, 80), Color3.fromRGB(110, 110, 116), Color3.fromRGB(176, 104, 64) }
	for k, p in ipairs(pileBoxes) do
		local pile = Kit.model(piles, "Pile" .. k)
		local pr = Kit.rng(500 + k)
		local x0, z0, x1, z1, h = p[1], p[2], p[3], p[4], p[5]
		local alongZ = (z1 - z0) > (x1 - x0)
		local cols = math.max(1, math.floor(((alongZ and (x1 - x0)) or (z1 - z0)) / 8.4))
		local rows = math.max(1, math.floor(((alongZ and (z1 - z0)) or (x1 - x0)) / 17))
		-- real yards stack whole cars 2-3 high, each a little turned on the roof below (photos: ref_junkyard)
		local layers = math.clamp(math.floor(h / 6), 1, 3)
		for c = 0, cols - 1 do
			for rr = 0, rows - 1 do
				local top = math.max(1, layers - (c == 0 and 0 or math.floor(pr() * 2)))
				local y = 0
				for l = 0, top - 1 do
					local u = (c + 0.5) / cols
					local v = (rr + 0.5) / rows
					local cx = alongZ and (x0 + (x1 - x0) * u) or (x0 + (x1 - x0) * v)
					local cz = alongZ and (z0 + (z1 - z0) * v) or (z0 + (z1 - z0) * u)
					local yaw = (alongZ and 0 or 90) + (pr() - 0.5) * 16 + (if pr() > 0.5 then 180 else 0)
					local col = SLAB_COLORS[math.floor(pr() * #SLAB_COLORS) + 1]
					local ox, oz = (pr() - 0.5) * 1.4, (pr() - 0.5) * 1.4
					local tilt = CFrame.Angles((pr() - 0.5) * 0.08, 0, (pr() - 0.5) * 0.1)
					-- a worn background car (bundle mesh); the old slab stand-in if it can't load
					-- pickups only at the bottom (a car on a pickup's tall cab would float over its bed)
					local name = if l == 0 then WORN[math.floor(pr() * #WORN) + 1] else WORN_SEDAN[math.floor(pr() * #WORN_SEDAN) + 1]
					local car = GearportProps.mesh(pile, name, cx + ox, y, cz + oz, math.rad(yaw), true, nil, tilt)
					if car then
						y += car.Size.Y * 0.8 -- the roof below gives a little
					else
						local slab = Kit.part(pile, "Slab", Vector3.new(7.4, 2.9, 16), CFrame.new(cx + ox, y + 1.45, cz + oz)
							* CFrame.Angles(0, math.rad(yaw), 0) * tilt, col, M.metal)
						slab.Material = (pr() > 0.6) and Enum.Material.CorrodedMetal or M.metal
						y += 2.9
					end
				end
			end
		end
	end

	-- scrap crane (material handler): tracks, turntable, cab, counterweight, boom + stick, magnet on a chain
	local crane = Kit.model(jy, "Crane")
	local CY = Color3.fromRGB(246, 190, 40)
	local CD = Color3.fromRGB(56, 58, 64)
	local O = CFrame.new(118, 0, 316) * CFrame.Angles(0, math.pi, 0) -- cab / boom face +Z (the back piles)
	local function cp(n: string, size: Vector3, off: CFrame, col: Color3, mat: Enum.Material?, opts: Kit.Opts?)
		return Kit.part(crane, n, size, O * off, col, mat, opts)
	end
	for _, tx in ipairs({ -4.6, 4.6 }) do
		cp("Track", Vector3.new(2.6, 2.4, 13), CFrame.new(tx, 1.2, 0), CD, M.metal)
	end
	cp("Carbody", Vector3.new(6.6, 1.4, 6), CFrame.new(0, 2.4, 0), CD, M.metal)
	cp("Turntable", Vector3.new(0.8, 6, 6), CFrame.new(0, 3.5, 0) * CFrame.Angles(0, 0, math.rad(90)), CD, M.metal, { shape = "cyl" })
	cp("House", Vector3.new(8, 4, 11), CFrame.new(0, 6, 1), CY, M.smooth)
	cp("Counterweight", Vector3.new(8.4, 3, 2.4), CFrame.new(0, 5.6, 7.2), CD, M.metal)
	cp("Cab", Vector3.new(3.4, 5, 4.4), CFrame.new(-2.4, 10.5, -3), CY, M.smooth)
	cp("CabGlass", Vector3.new(3.5, 3.2, 4.5), CFrame.new(-2.4, 11, -3), Color3.fromRGB(60, 90, 120), M.glass, { transparency = 0.3, collide = false })
	cp("Exhaust", Vector3.new(0.5, 2.4, 0.5), CFrame.new(3, 9.2, 5), CD, M.metal)
	-- the boom reaches toward the back piles (+Z of the yard)
	local hinge = (O * CFrame.new(1.4, 8.4, -4)).Position
	local elbow = (O * CFrame.new(1.4, 26, -16)).Position
	local tip = (O * CFrame.new(1.4, 22, -30)).Position
	rod(crane, "Boom", hinge, elbow, 1.4, 1.6, CY, M.smooth)
	rod(crane, "Stick", elbow, tip, 1.0, 1.2, CY, M.smooth)
	rod(crane, "BoomRam", (O * CFrame.new(1.4, 6.5, -2)).Position, (O * CFrame.new(1.4, 15, -8)).Position, 0.6, 0.6, C.steel, M.metal)
	local magY = 10.8
	box(crane, "Chain", tip.X - 0.08, magY + 0.8, tip.Z - 0.08, tip.X + 0.08, tip.Y, tip.Z + 0.08, CD, M.metal, { collide = false })
	Kit.part(crane, "Magnet", Vector3.new(1.4, 5, 5), CFrame.new(tip.X, magY, tip.Z) * CFrame.Angles(0, 0, math.rad(90)), CD, M.metal, { shape = "cyl" })
	Kit.part(crane, "MagnetRim", Vector3.new(0.3, 5.2, 5.2), CFrame.new(tip.X, magY + 0.6, tip.Z) * CFrame.Angles(0, 0, math.rad(90)), CY, M.smooth, { shape = "cyl", collide = false })
	marker(crane, "CraneSpot", Vector3.new(118, 0, 316), Vector3.new(0, 0, 1), Vector3.new(16, 0.2, 16))

	-- appraisal: where the player stands to look a wreck over (lane side of each spot) + a price tag pole
	local ap = Kit.folder(jy, "AppraisePoints")
	local tags = Kit.folder(jy, "PriceTags")
	for n = 1, 10 do
		local sp = spots:FindFirstChild("Spot" .. n) :: BasePart?
		if sp then
			local look = sp.CFrame.LookVector -- car front, toward the lane
			local front = sp.Position + look * 8.5
			marker(ap, "Spot" .. n, front + look * 2.6, -look)
			local pole = front + look * 1.2 + Vector3.new(0, 0, 3.6)
			Kit.post(tags, "TagPole", pole.X, pole.Z, 0, 4.2, 0.2, C.steel, M.metal)
			local board = Kit.part(tags, "Spot" .. n, Vector3.new(2.4, 1.4, 0.12), CFrame.lookAt(Vector3.new(pole.X, 4.6, pole.Z), Vector3.new(pole.X, 4.6, pole.Z) + look),
				C.yellow, M.smooth, { collide = false })
			local gui = Kit.label(board, Enum.NormalId.Front, "$ ---", Color3.fromRGB(30, 30, 36), nil)
			local t = gui:FindFirstChildOfClass("TextLabel")
			if t then
				t.Name = "Price" -- code sets PriceTags.SpotN.Label.Price.Text
			end
		end
	end

	-- mud + rust ground (darker patches, mostly by the lane and the tow spot) and tire tracks gate -> tow spot
	local mr = Kit.rng(611)
	for _ = 1, 10 do
		local x = 30 + mr() * 54
		local z = 210 + mr() * 130
		local w, d = 4 + mr() * 6, 4 + mr() * 8
		box(yard, "Mud", x - w / 2, 0, z - d / 2, x + w / 2, 0.03, z + d / 2, Color3.fromRGB(104, 82, 62), Enum.Material.Mud, { collide = false })
	end
	for _ = 1, 6 do
		local x = YX0 + 4 + mr() * (YX1 - YX0 - 8)
		local z = 240 + mr() * 120
		box(yard, "RustStain", x - 1.4, 0, z - 1.4, x + 1.4, 0.04, z + 1.4, Color3.fromRGB(150, 86, 52), M.smooth, { collide = false })
	end
	for _, side in ipairs({ -2.6, 2.6 }) do
		rod(yard, "TireTrack", Vector3.new(47 + side, 0.03, 206), Vector3.new(74 + side, 0.03, 222), 1.4, 0.06, Color3.fromRGB(88, 70, 54), M.smooth, { collide = false })
	end
	-- tire piles (cylinder placeholders, like the shop's)
	for k, tp in ipairs({ { 30, 240, 5 }, { -30, 336, 6 }, { 90, 236, 4 } }) do
		local tr = Kit.rng(700 + k)
		local m = Kit.model(yard, "TirePile")
		for t = 0, tp[3] - 1 do
			local ring = t < 3 and 0 or 1
			local tire = Kit.part(m, "Tire", Vector3.new(0.9, 2.4, 2.4),
				CFrame.new(tp[1] + (t % 3) * 2.2 - 2.2 + ring * 1.1 + (tr() - 0.5) * 0.4, 0.45 + ring * 0.9, tp[2] + (tr() - 0.5) * 0.6) * CFrame.Angles(0, 0, math.rad(90)),
				C.rubber, M.plastic, { shape = "cyl" })
			tire:SetAttribute("Placeholder3D", "Tire")
		end
	end
	-- parts shed by the west fence: lean-to roof, shelves of engines / batteries, doors leaning on it
	local shed = Kit.model(jy, "PartsShed")
	local sx0, sx1, sz0, sz1 = -38, -16, 210, 232
	for _, pz in ipairs({ sz0, sz1 }) do
		box(shed, "Post", sx1 - 0.4, 0, pz - 0.2, sx1, 9, pz + 0.2, POST, M.metal)
		box(shed, "Post", sx0 + 0.2, 0, pz - 0.2, sx0 + 0.6, 11, pz + 0.2, POST, M.metal)
	end
	rod(shed, "Roof", Vector3.new(sx0, 11.3, (sz0 + sz1) / 2), Vector3.new(sx1 + 1.5, 9.0, (sz0 + sz1) / 2), sz1 - sz0 + 2, 0.4, RUST[3], M.metal)
	local shelfCol = Color3.fromRGB(70, 74, 82)
	for _, sy in ipairs({ 0.2, 3.2, 6.2 }) do
		box(shed, "Shelf", sx0 + 0.8, sy, sz0 + 1, sx0 + 4.4, sy + 0.3, sz1 - 1, shelfCol, M.metal)
	end
	local er = Kit.rng(733)
	for z = sz0 + 2.5, sz1 - 3, 3.4 do
		for _, sy in ipairs({ 0.5, 3.5, 6.5 }) do
			if er() > 0.25 then
				if er() > 0.6 then
					box(shed, "Battery", sx0 + 1.4, sy, z - 0.6, sx0 + 2.6, sy + 1.0, z + 0.6, C.rubber, M.smooth)
				else
					box(shed, "Engine", sx0 + 1.0, sy, z - 1.2, sx0 + 3.8, sy + 2.0, z + 1.2, Color3.fromRGB(120 + math.floor(er() * 40), 110, 100), M.metal)
					box(shed, "EngineHead", sx0 + 1.4, sy + 2.0, z - 0.9, sx0 + 3.4, sy + 2.5, z + 0.9, C.metalDark, M.metal)
				end
			end
		end
	end
	for k = 0, 2 do
		Kit.part(shed, "Door", Vector3.new(0.3, 4, 4.4), CFrame.new(sx1 - 3 - k * 0.5, 2.0, sz0 + 6 + k * 4.5) * CFrame.Angles(0, 0, math.rad(-12)), SLAB_COLORS[k + 1], M.metal)
	end
	local shedSign = box(shed, "Sign", sx1 - 0.2, 7.6, sz0 + 4, sx1, 9.0, sz1 - 4, Color3.fromRGB(250, 248, 240), M.smooth, { collide = false })
	Kit.label(shedSign, Enum.NormalId.Right, "USED PARTS", C.red, nil)
	-- sign inside the gate
	local ts = box(jy, "TowSignBoard", 64, 3, 206, 70, 5.4, 206.3, C.yellow, M.smooth)
	Kit.label(ts, Enum.NormalId.Back, "TOW TRUCKS >", Color3.fromRGB(30, 30, 36), nil)
	Kit.post(jy, "TowSignPost", 67, 206.15, 0, 3, 0.25, C.steel, M.metal)

	-- a few rusty stand-in wrecks lying around OUTSIDE the wreck spots (decor; the spots stay empty for the game)
	local Props = require(script.Parent.Props)
	local decor = Kit.folder(jy, "DecorWrecks")
	for k, w in ipairs({ { -14, 292, 24, Color3.fromRGB(150, 110, 80), "BG_Sedan_2_Worn" },
		{ 102, 266, 102, Color3.fromRGB(160, 90, 70), "BG_Pickup_1_Worn" } }) do
		-- a worn background car sunk on the dirt (wheels half in the ground), the block stand-in if it can't load
		local tilt = CFrame.Angles(0, 0, math.rad(k == 2 and 3 or -2))
		local car = GearportProps.mesh(decor, w[5] :: string, w[1] :: number, -0.9, w[2] :: number, math.rad(w[3] :: number), true, nil, tilt)
		if not car then
			local m = Props.standInCar(decor, "Wreck" .. k, CFrame.new(w[1] :: number, -0.9, w[2] :: number) * CFrame.Angles(0, math.rad(w[3] :: number), 0) * tilt, w[4] :: Color3)
			for _, p in ipairs(m:GetChildren()) do
				if p:IsA("BasePart") and (p.Name == "Wheel" or p.Name == "Rim" or p.Name == "Headlight") then
					p:Destroy() -- wheels gone, sitting on the dirt
				elseif p:IsA("BasePart") and p.Name == "Glass" then
					p.Transparency = 0.6
				end
			end
		end
	end

	-- two flood light poles, a few trees outside the fence
	for _, lp in ipairs({ { 34, 250 }, { 60, 330 } }) do
		Kit.post(yard, "FloodPole", lp[1], lp[2], 0, 26, 0.8, POST, M.metal)
		box(yard, "FloodHead", lp[1] - 1.5, 25, lp[2] - 0.5, lp[1] + 1.5, 26.4, lp[2] + 0.5, POST, M.metal)
	end
	local Town = require(script.Parent.Town)
	for k, t in ipairs({ { -56, 230 }, { -52, 350 }, { 156, 240 }, { 160, 330 }, { 60, 402 } }) do
		Town.tree(yard, t[1], t[2], 1.1 + (k % 3) * 0.15, 1300 + k)
	end
end

return Junkyard
