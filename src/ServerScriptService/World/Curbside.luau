--!strict
-- World/Curbside (v23, wr-builder): the service apron in front of Bay 1 — the downtime fix (notes/gpt/main/
-- downtime_main_decision.md, user OK 10-22) and the short curb jobs (docs/design/curb_jobs.md).
--   Queue: two WAIT HERE stalls straight in front of the Bay 1 door. The next customers wait here while the bays
--          are busy, nose to the bay, the driver beside the car waving -> when a bay frees the car drives straight in.
--   Curb:  one QUICK SERVICE stall beside them for the 1-minute curb jobs (wiper blades, washer fluid) +
--          a supply rack, an A-frame sign and the washer jug the code hands out.
-- Cars come straight in off the eastbound avenue (a right turn) through the wide curb cut Site.SERVICE_X0..X1 and
-- leave by the drive lane like every other car (lane west -> Traffic.LaneWest -> ExitCurb).
-- Real US: lube shops line the cars up in front of the bay doors (drivers passing see "cars in the bay and cars in
-- line" — NOLN, McPherson Quick Lube); parts stores fit wiper blades in the lot right after checkout (O'Reilly).
-- Names / positions: docs/specs/world_contract.md ★ Curbside (the names wr-dev's CurbService reads: Curb.CurbSpot, Curb.Jug ...).

local Kit = require(script.Parent.Kit)
local Site = require(script.Parent.Site)
local C, M = Kit.C, Kit.M
local box, marker = Kit.box, Kit.marker

local Curbside = {}

local DECO = { collide = false }
local CAR = Vector3.new(8, 0.2, 18) -- car floor spot (world_contract §1)
local SPOT_Z = -56 -- stall centre (car pivot); nose +Z at -47.5, tail at -64.5
local ROAD_Z = -79.5 -- the near eastbound lane (Traffic.RoadIn)
local APRON_Z = -68 -- on the curb cut, lined up with the stall: the last leg runs straight in
local TURN_BACK = 5 -- the road turn point sits this far west of the stall: a slanted leg across the cut, not a 90° pivot
local LANE_Z = -36 -- the drive lane in front of the bays
local BAY_DOOR = Vector3.new(0, 0, -20) -- Bay 1 shutter, where the waving driver looks
local SIDE = 5.3 -- car half width 3.8 + room to stand
local WIPER_Z = SPOT_Z + 3.5 -- windshield base (sedan hood ends ~4 ahead of the pivot) -> beside the wiper arms
local STENCIL_TURN = math.pi / 2

local function flatLook(from: Vector3, to: Vector3): Vector3
	local d = Vector3.new(to.X - from.X, 0, to.Z - from.Z)
	return d.Unit
end

-- pavement stencil: text on a flat see-through plate, reading for a driver pulling in (heading +Z).
-- (a Top-face SurfaceGui runs its width along the part's Z: the plate is turned so that Z lies along world X)
local function stencil(parent: Instance, name: string, x: number, z: number, w: number, d: number, text: string, color: Color3)
	local p = Kit.part(parent, name, Vector3.new(d, 0.05, w), CFrame.new(x, 0.03, z) * CFrame.Angles(0, STENCIL_TURN, 0),
		color, M.smooth, { collide = false, transparency = 1, shadow = false })
	p.CanQuery = false
	p.CanTouch = false
	local gui = Kit.label(p, Enum.NormalId.Top, text, color, nil)
	gui.LightInfluence = 1
	return p
end

-- white arrow painted toward the bay (+Z): shaft + a triangle head from two flat wedges (right angles on the shaft)
local function arrow(parent: Instance, x: number, z0: number)
	local zb, zt, half = z0 + 3.2, z0 + 5.0, 1.3
	box(parent, "Arrow", x - 0.3, 0, z0, x + 0.3, 0.05, zb, C.lineWhite, M.smooth, DECO)
	local size = Vector3.new(0.05, half, zt - zb)
	for _, s in ipairs({ 1, -1 }) do
		local cf = CFrame.new(x + s * half / 2, 0.025, (zb + zt) / 2) * CFrame.Angles(0, math.pi, 0) * CFrame.Angles(0, 0, s * math.pi / 2)
		Kit.part(parent, "ArrowHead", size, cf, C.lineWhite, M.smooth, { collide = false, shape = "wedge" })
	end
end

-- washer fluid gallon jug (real 16 x 27 x 11 cm, x1.15): blue body + white cap at the back corner. PrimaryPart = Body.
-- Faces +X (label side). Curb.Jug is one of these, sitting on the rack: the code clones it into a hand.
local function jug(parent: Instance, name: string, x: number, y: number, z: number): Model
	local m = Kit.model(parent, name)
	local body = Kit.part(m, "Body", Vector3.new(0.45, 1.1, 0.65), CFrame.new(x, y + 0.55, z), Color3.fromRGB(52, 132, 220), M.plastic, DECO)
	Kit.post(m, "Cap", x - 0.1, z + 0.18, y + 1.1, y + 1.28, 0.24, Color3.fromRGB(244, 244, 240), M.plastic, DECO)
	m.PrimaryPart = body
	m:SetAttribute("Kind", "WasherJug")
	return m
end

-- wire supply rack beside the curb stall's front bumper, front toward the stall (+X): blade boxes on the middle
-- shelf, washer jugs on the bottom one, a header board (real parts-store / quick-lube curb displays, no brands)
local function supplyRack(c: Instance, x0: number, z0: number)
	local m = Kit.model(c, "SupplyRack")
	m:SetAttribute("Kind", "SupplyRack")
	local x1, z1 = x0 + 1.4, z0 + 3
	for _, px in ipairs({ x0 + 0.1, x1 - 0.1 }) do
		for _, pz in ipairs({ z0 + 0.1, z1 - 0.1 }) do
			Kit.post(m, "Post", px, pz, 0, 4.8, 0.16, C.steel, M.metal, DECO)
		end
	end
	box(m, "Shelf", x0, 0.25, z0, x1, 0.35, z1, C.steel, M.diamond, DECO)
	box(m, "Shelf", x0, 1.8, z0, x1, 1.9, z1, C.steel, M.diamond, DECO)
	-- blade boxes: long cartons lying along the rack, two rows x three high, orange / black
	local orange, black = Color3.fromRGB(232, 118, 43), Color3.fromRGB(38, 38, 42)
	for row = 0, 1 do
		for k = 0, 2 do
			local bx = x0 + 0.4 + row * 0.62
			box(m, "BladeBox", bx - 0.25, 1.9 + k * 0.24, z0 + 0.2, bx + 0.25, 2.12 + k * 0.24, z1 - 0.2,
				if (row + k) % 2 == 0 then orange else black, M.smooth, DECO)
		end
	end
	for k = 1, 3 do
		jug(m, "Jug", x0 + 0.85, 0.35, z0 + 0.3 + k * 0.72)
	end
	local head = box(m, "Header", x0 + 0.62, 3.9, z0 + 0.1, x0 + 0.78, 4.8, z1 - 0.1, Color3.fromRGB(250, 250, 246), M.smooth, DECO)
	for _, face in ipairs({ Enum.NormalId.Right, Enum.NormalId.Left }) do
		local t = Kit.label(head, face, "WIPER BLADES\nWASHER FLUID", C.red, nil):FindFirstChildOfClass("TextLabel") :: TextLabel
		t.Size = UDim2.fromScale(0.86, 0.84)
		t.Position = UDim2.fromScale(0.07, 0.08)
	end
	-- one solid box for bumping into (the wire bits are see-through to the pathfinder anyway)
	box(m, "Solid", x0, 0, z0, x1, 4.8, z1, C.steel, M.smooth, { transparency = 1, shadow = false })
	return m
end

-- A-frame sidewalk sign (two boards leaning together), QUICK SERVICE both ways: street (-Z) and shop (+Z)
local function aFrame(c: Instance, x: number, z: number)
	local m = Kit.model(c, "Sign")
	m:SetAttribute("Kind", "AFrame")
	for _, s in ipairs({ -1, 1 }) do
		local board = Kit.part(m, "Board", Vector3.new(2.4, 3.2, 0.12),
			CFrame.new(x, 1.57, z + s * 0.34) * CFrame.Angles(math.rad(-s * 12), 0, 0), C.red, M.smooth)
		local face = if s < 0 then Enum.NormalId.Front else Enum.NormalId.Back
		local title = Kit.label(board, face, "QUICK\nSERVICE", C.lineWhite, nil):FindFirstChildOfClass("TextLabel") :: TextLabel
		title.Size = UDim2.fromScale(0.9, 0.5)
		title.Position = UDim2.fromScale(0.05, 0.06)
		local jobs = title:Clone()
		jobs.Text = "WIPERS\nWASHER FLUID"
		jobs.TextColor3 = Color3.fromRGB(255, 226, 120)
		jobs.Size = UDim2.fromScale(0.84, 0.3)
		jobs.Position = UDim2.fromScale(0.08, 0.62)
		jobs.Parent = title.Parent
	end
	return m
end

local function queue(garage: Model)
	local q = Kit.folder(garage, "Queue")
	for i, cx in ipairs(Site.QUEUE_X) do
		marker(q, "QueueSpot" .. i, Vector3.new(cx, 0, SPOT_Z), Vector3.zAxis, CAR)
		-- route: Traffic.RoadIn -> QueueEntryN (road) -> QueueApronN (curb cut) -> QueueSpotN
		marker(q, "QueueEntry" .. i, Vector3.new(cx - TURN_BACK, 0, ROAD_Z), Vector3.new(TURN_BACK, 0, APRON_Z - ROAD_Z).Unit)
		marker(q, "QueueApron" .. i, Vector3.new(cx, 0, APRON_Z), Vector3.zAxis)
		-- the driver gets out (left = +X, US) and waits by the front fender, waving at the bay door
		local wave = Vector3.new(cx + SIDE + 0.2, 0, SPOT_Z + 5.5)
		marker(q, "WaveSpot" .. i, wave, flatLook(wave, BAY_DOOR))
		-- paint: stop bar at the stall mouth, WAIT HERE, an arrow to the bay
		box(q, "StopBar", cx - 4.4, 0, -46.9, cx + 4.4, 0.05, -46.3, C.lineWhite, M.smooth, DECO)
		stencil(q, "WaitHere", cx, -52, 8, 2.6, "WAIT HERE", C.lineWhite)
		arrow(q, cx, -59.6)
	end
end

local function curb(garage: Model)
	local c = Kit.folder(garage, "Curb")
	local cx = Site.CURB_X
	marker(c, "CurbSpot", Vector3.new(cx, 0, SPOT_Z), Vector3.zAxis, CAR)
	-- route in: Traffic.RoadIn -> CurbEntry (road) -> CurbApron (curb cut) -> CurbSpot; out: CurbExit -> Traffic.LaneWest ...
	marker(c, "CurbEntry", Vector3.new(cx - TURN_BACK, 0, ROAD_Z), Vector3.new(TURN_BACK, 0, APRON_Z - ROAD_Z).Unit)
	marker(c, "CurbApron", Vector3.new(cx, 0, APRON_Z), Vector3.zAxis)
	marker(c, "CurbExit", Vector3.new(cx, 0, LANE_Z), -Vector3.xAxis) -- joins the lane heading west
	-- where the player stands (each faces the car)
	marker(c, "HoodSpot", Vector3.new(cx, 0, -45.6), -Vector3.zAxis) -- in front of the nose: hood up, washer cap
	marker(c, "WiperSpotL", Vector3.new(cx + SIDE, 0, WIPER_Z), -Vector3.xAxis) -- driver side (long blade)
	marker(c, "WiperSpotR", Vector3.new(cx - SIDE, 0, WIPER_Z), Vector3.xAxis) -- passenger side (open stall beside)
	-- the curb customer waits by the passenger-side rear, watching the hood
	local wait = Vector3.new(cx - SIDE - 0.3, 0, SPOT_Z - 5)
	marker(c, "CustomerSpot", wait, flatLook(wait, Vector3.new(cx, 0, -47)))
	-- paint, the supply rack by the front bumper (in the empty stall west, clear of the car's turn into the lane and
	-- of Bay 2's), the A-frame by the curb where the avenue sees it, and the jug the code hands the player
	stencil(c, "QuickService", cx, -52, 9, 2.4, "QUICK SERVICE", C.lineYellow)
	supplyRack(c, cx - 9.2, -50.6)
	aFrame(c, cx - 8.4, -62.4)
	jug(c, "Jug", cx - 8.35, 0.35, -50.6 + 0.3)
end

function Curbside.build(garage: Model)
	queue(garage)
	curb(garage)
end

return Curbside
