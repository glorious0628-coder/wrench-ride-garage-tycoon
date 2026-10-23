--!strict
-- World/LivedIn (wr-builder): "people work here" touches — very faint oil / tyre marks, blank art boards for posters
-- and safety signs (pictures come later from Codex: each board has attribute ArtSlot + AspectW/H), clutter on the
-- workbenches, magazines / plants / a clock in the waiting room. Same props turned / spread a little. Looks only.
-- Pieces inside Bay2 / RestoreBay / Showroom live inside those models, so they hide / show with them.

local Kit = require(script.Parent.Kit)
local C, M = Kit.C, Kit.M
local box = Kit.box

local LivedIn = {}

local F = 0.2
local OIL = Color3.fromRGB(92, 94, 100)
local TRACK = Color3.fromRGB(118, 120, 126)

-- flat, faint floor mark (no collision, no shadow, half see-through). Tyre tracks are strips; spills are round
-- blotches (a big disc + a smaller one and a drop trailing off one side, like a drip — a square read as a floor
-- tile in pictures; two equal side discs read as a cartoon mouse head, 10-21)
local function mark(parent: Instance, name: string, x: number, y: number, z: number, w: number, d: number, yaw: number, col: Color3, transp: number)
	local opts = { collide = false, shadow = false, transparency = transp }
	local at = CFrame.new(x, y + 0.01, z) * CFrame.Angles(0, math.rad(yaw), 0)
	local p: BasePart
	if name == "TyreTrack" then
		p = Kit.part(parent, name, Vector3.new(w, 0.02, d), at, col, M.smooth, opts)
	else
		local size = math.max(w, d)
		local flat = CFrame.Angles(0, 0, math.rad(90))
		local discOpts = { collide = false, shadow = false, transparency = transp, shape = "cyl" }
		p = Kit.part(parent, name, Vector3.new(0.02, size * 0.85, size * 0.85), at * flat, col, M.smooth, discOpts)
		for i, o in ipairs({ { 0.36, 0.06, 0.5 }, { 0.62, 0.1, 0.26 } }) do
			local q = Kit.part(parent, name, Vector3.new(0.02, size * o[3], size * o[3]), at * CFrame.new(size * o[1], 0.004 * i, size * o[2]) * flat,
				col, M.smooth, discOpts)
			q.CanQuery = false
			q.CanTouch = false
		end
	end
	p.CanQuery = false
	p.CanTouch = false
	return p
end

-- tyre tracks: two faint strips (wheel track ±3.25) from a door toward where the car stops
local function tracks(parent: Instance, cx: number, y: number, z0: number, z1: number, seed: number)
	local r = Kit.rng(seed)
	for _, s in ipairs({ -3.25, 3.25 }) do
		mark(parent, "TyreTrack", cx + s + (r() - 0.5) * 0.3, y, (z0 + z1) / 2, 0.9, math.abs(z1 - z0), (r() - 0.5) * 2, TRACK, 0.72)
	end
end

-- blank art board with a thin frame. face = direction the picture faces.
local function artSlot(parent: Instance, id: string, pos: Vector3, face: Vector3, w: number, h: number, safety: boolean?)
	local cf = CFrame.lookAt(pos, pos + face)
	local frame = Kit.part(parent, "ArtFrame", Vector3.new(w + 0.3, h + 0.3, 0.08), cf * CFrame.new(0, 0, 0.05), safety and C.yellow or C.trim, M.smooth,
		{ collide = false, shadow = false })
	frame.CanQuery = false
	-- the board is solid (flush on the wall, nothing walks into it): the camera stops in front of it instead of
	-- backing onto the wall behind it, with the board filling the screen (test 2 TOP10)
	local board = Kit.part(parent, "ArtSlot", Vector3.new(w, h, 0.06), cf * CFrame.new(0, 0, -0.02), Color3.fromRGB(242, 240, 232), M.smooth,
		{ shadow = false })
	board:SetAttribute("ArtSlot", id)
	board:SetAttribute("AspectW", w)
	board:SetAttribute("AspectH", h)
	board:SetAttribute("Kind", safety and "SafetySign" or "Poster")
	return board
end

local function bay1(garage: Model)
	local d = Kit.folder(garage, "LivedIn")
	-- oil spots (sizes / turns all different) + tyre tracks from the door
	mark(d, "OilSpot", -4, F, 3, 2.4, 1.5, 22, OIL, 0.55)
	mark(d, "OilSpot", 4.6, F, 9.4, 1.5, 1.1, -14, OIL, 0.6)
	mark(d, "OilSpot", -8.4, F, -9.8, 1.3, 1.0, 40, OIL, 0.6)
	mark(d, "OilSpot", 9.2, F, 14.2, 1.0, 0.8, 8, OIL, 0.65)
	tracks(d, 0, F, -19, -10, 901)
	tracks(d, 0, 0.05, -31, -20.5, 902) -- on the apron outside
	-- parking lot: a few oil drips in the spots
	for i, p in ipairs({ { -30, -54, 12 }, { -18, -60, -20 }, { 18, -57, 35 } }) do
		mark(d, "LotOil", p[1], 0, p[2], 1.4 + i * 0.2, 1.0, p[3], Color3.fromRGB(46, 48, 54), 0.5)
	end
	-- art boards (blank — Codex pictures later)
	local art = Kit.folder(d, "ArtSlots")
	artSlot(art, "B1_PosterWest", Vector3.new(-12.85, 12.8, 6.5), Vector3.new(1, 0, 0), 4, 3)
	artSlot(art, "B1_PosterBack", Vector3.new(10, 14.2, 18.85), Vector3.new(0, 0, -1), 3.6, 3.6)
	artSlot(art, "B1_SafetyDoor", Vector3.new(13.85, 10.2, -2), Vector3.new(-1, 0, 0), 3.2, 1.6, true)
	artSlot(art, "B1_SafetyLift", Vector3.new(-7.5, 10.4, 18.85), Vector3.new(0, 0, -1), 2.4, 1.8, true)
	-- workbench clutter (bench top y 3.4, x 1.8..12.2, z 16.3..19)
	local r = Kit.rng(911)
	box(d, "SocketCase", 5.8, 3.4, 16.5, 7.6, 3.8, 17.3, C.red, M.smooth)
	box(d, "SocketLid", 5.8, 3.8, 16.5, 7.6, 3.85, 17.3, C.redDark, M.smooth, { collide = false })
	for _, wpos in ipairs({ { 4.2, 16.7, 8 }, { 9.6, 16.6, -12 } }) do
		Kit.part(d, "WrenchLying", Vector3.new(1.8, 0.1, 0.22), CFrame.new(wpos[1], 3.45, wpos[2]) * CFrame.Angles(0, math.rad(wpos[3] + (r() - 0.5) * 4), 0),
			C.steel, M.metal, { collide = false, shadow = false })
	end
	Kit.part(d, "BrakeDisc", Vector3.new(0.25, 1.3, 1.3), CFrame.new(9.7, 3.53, 18.4) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(150, 150, 154), M.metal,
		{ shape = "cyl", collide = false })
	Kit.post(d, "Mug", 2.5, 17.5, 3.4, 4.0, 0.5, Color3.fromRGB(246, 246, 242), M.smooth, { collide = false })
	box(d, "Rag", 2.0, 3.4, 16.5, 3.0, 3.46, 17.2, Color3.fromRGB(200, 70, 60), M.smooth, { collide = false })
	-- broom + bucket by the bench end, a box stack in the back-left corner (turned a little)
	Kit.rod(d, "Broom", Vector3.new(13.4, F, 17.4), Vector3.new(13.7, 6.4, 18.6), 0.15, 0.15, C.wood, M.wood, { collide = false })
	box(d, "BroomHead", 12.9, F, 17.0, 13.9, 0.6, 17.6, C.yellow, M.smooth, { collide = false })
	Kit.post(d, "Bucket", 12.9, 18.2, F, 1.6, 1.0, C.blue, M.smooth)
end

local function bay2(garage: Model)
	local bay = garage.Bays:FindFirstChild("Bay2")
	local pr = bay and bay:FindFirstChild("Props")
	if not pr then
		return
	end
	mark(pr, "OilSpot", -25, F, 4, 2.0, 1.3, -18, OIL, 0.55)
	mark(pr, "OilSpot", -33, F, -6, 1.2, 1.0, 30, OIL, 0.6)
	tracks(pr, -28, F, -19, -10, 921)
	local art = Kit.folder(pr, "ArtSlots")
	artSlot(art, "B2_PosterBack", Vector3.new(-33.5, 11.5, 18.85), Vector3.new(0, 0, -1), 4, 3)
	artSlot(art, "B2_SafetyWest", Vector3.new(-40.85, 10.5, -5.5), Vector3.new(1, 0, 0), 2.4, 3, true)
	local r = Kit.rng(922)
	local y = F
	for i = 0, 2 do
		local s = 1.6 - i * 0.2
		Kit.part(pr, "Carton", Vector3.new(s * 1.3, s, s), CFrame.new(-38.6 + (r() - 0.5) * 0.4, y + s / 2, -16.6) * CFrame.Angles(0, math.rad((r() - 0.5) * 20), 0),
			C.cardboard, M.smooth)
		y += s
	end
end

local function waiting(garage: Model)
	local wr = garage:FindFirstChild("WaitingRoom") :: Model
	local d = Kit.folder(wr, "LivedIn")
	-- magazines scattered (table top y 2.2), one on the sofa
	local r = Kit.rng(931)
	for i, m in ipairs({ { 28.3, -10.4, C.blue }, { 28.4, -14.1, C.yellow }, { 20.2, -17.0, Color3.fromRGB(60, 160, 120) } }) do
		local y = i == 3 and 2.7 or 2.25
		Kit.part(d, "Magazine", Vector3.new(1.0, 0.08, 1.3), CFrame.new(m[1], y, m[2]) * CFrame.Angles(0, math.rad((r() - 0.5) * 50), 0), m[3], M.smooth,
			{ collide = false, shadow = false })
	end
	-- small plant on the reception desk (v35: the one on the old coffee counter went with it)
	for _, p in ipairs({ { 17.6, 3.7, -8.5 } }) do
		Kit.post(d, "SmallPot", p[1], p[3], p[2], p[2] + 0.7, 0.7, C.cardboard, M.smooth, { collide = false })
		Kit.part(d, "SmallPlant", Vector3.new(1.0, 1.0, 1.0), CFrame.new(p[1], p[2] + 1.1, p[3]), C.grassDark, M.grass, { shape = "ball", collide = false })
	end
	-- wall clock over the vending machine
	Kit.part(d, "Clock", Vector3.new(0.2, 1.8, 1.8), CFrame.new(27, 9.6, 1.85) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(250, 250, 248), M.smooth, { shape = "cyl", collide = false })
	Kit.part(d, "ClockRim", Vector3.new(0.15, 2.0, 2.0), CFrame.new(27, 9.6, 1.95) * CFrame.Angles(0, math.rad(90), 0), C.rubber, M.smooth, { shape = "cyl", collide = false })
	box(d, "ClockHand", 26.95, 9.6, 1.7, 27.05, 10.3, 1.74, C.rubber, M.smooth, { collide = false })
	-- art boards
	local art = Kit.folder(d, "ArtSlots")
	artSlot(art, "WR_PosterCross", Vector3.new(31.4, 8.2, 1.85), Vector3.new(0, 0, -1), 3, 4)
	artSlot(art, "WR_PosterEast", Vector3.new(36.85, 8.6, -14), Vector3.new(-1, 0, 0), 4, 3)
	artSlot(art, "WR_Certificate", Vector3.new(23.7, 8.2, 1.85), Vector3.new(0, 0, -1), 2.2, 1.6)
end

local function restore(garage: Model)
	local rb = garage:FindFirstChild("RestoreBay")
	local pr = rb and rb:FindFirstChild("Props")
	if not pr then
		return
	end
	mark(pr, "OilSpot", 5, F, 56, 1.8, 1.2, 14, OIL, 0.55)
	tracks(pr, 2, F, 45, 53, 941)
	local art = Kit.folder(pr, "ArtSlots")
	artSlot(art, "RB_PosterBack", Vector3.new(8.5, 10, 78.85), Vector3.new(0, 0, -1), 4, 3)
	box(pr, "PartsBox", 14.6, 3.5, 74.6, 16.2, 4.4, 75.8, C.cardboard, M.smooth)
	box(pr, "Rag", 15.2, 3.5, 69.4, 16.2, 3.56, 70.2, Color3.fromRGB(200, 70, 60), M.smooth, { collide = false })
end

local function showroom(garage: Model)
	local sr = garage:FindFirstChild("Showroom")
	if not sr then
		return
	end
	local art = Kit.folder(sr, "ArtSlots")
	artSlot(art, "SR_Banner", Vector3.new(84, 13, 28.85), Vector3.new(0, 0, -1), 12, 3)
end

LivedIn.artSlot = artSlot -- (World/Gearport uses it for mural walls)

function LivedIn.build(garage: Model)
	bay1(garage)
	bay2(garage)
	waiting(garage)
	restore(garage)
	showroom(garage)
end

return LivedIn
