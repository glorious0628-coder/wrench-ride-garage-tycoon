--!strict
-- World/Site: ground, the street in front (-Z), sidewalks, the shop lot, parking, traffic markers, the junkyard road,
-- and blockout neighbours across the street. Numbers: docs/specs/world_contract.md (map plan).

local Kit = require(script.Parent.Kit)
local C, M = Kit.C, Kit.M
local box, marker = Kit.box, Kit.marker

local Site = {}

-- street layout (z): road -96..-74, near sidewalk -74..-66, lot -66..-20 (parking -66..-46, drive lane -46..-20)
Site.ROAD_Z0, Site.ROAD_Z1 = -96, -74
Site.WALK_Z0, Site.WALK_Z1 = -74, -66
Site.LOT_X0, Site.LOT_X1 = -104, 112
Site.ENTRY_X0, Site.ENTRY_X1 = 34, 60 -- curb cut in (customer cars, tow truck); v23: flared 40..56 -> 34..60
Site.EXIT_X0, Site.EXIT_X1 = -104, -78 -- curb cut out; v23: flared -102..-88 -> -104..-78 (the tail swings east)
-- v23 service apron in front of Bay 1 (in only, a right turn off the eastbound avenue): the two WAIT HERE queue
-- stalls straight in front of the bay door + the QUICK SERVICE curb stall beside them (World/Curbside)
Site.SERVICE_X0, Site.SERVICE_X1 = -28, 14 -- (stalls x -24..12 + 4 / 2 of flare: the cars swing in off the lane)
Site.QUEUE_X = { 6, -6 } -- Queue.QueueSpot1, QueueSpot2
Site.CURB_X = -18 -- Curb.CurbSpot
Site.CORNER_X = -30 -- the stall west of it: the curb job's supply rack + A-frame (no parking)
Site.PARKING_X = { -30, -18, -6, 6, 18, 30 } -- (the stall grid; -30 / -18 / -6 / 6 = rack corner, curb + queue stalls now)
Site.CROSS_X0, Site.CROSS_X1 = 202, 224 -- cross street (north-south) east of the lot: World/Street
-- the whole map (Gearport stage 2): x -440..480, z from the river wall (-266) to the north wall (480)
Site.MAP_X0, Site.MAP_X1 = -440, 480
Site.MAP_Z0, Site.MAP_Z1 = -266, 480

function Site.build(garage: Model)
	local site = Kit.folder(garage, "Site")

	-- ground: grass under everything (top -0.1, so paved tops at 0 never fight it)
	box(site, "Ground", Site.MAP_X0, -4, Site.MAP_Z0, Site.MAP_X1, -0.1, Site.MAP_Z1, C.grass, M.grass, { shadow = false })

	-- road (two lanes, 11 each) + double yellow centre line
	local road = Kit.folder(site, "Road")
	box(road, "Road", Site.MAP_X0, -1, Site.ROAD_Z0, Site.MAP_X1, 0, Site.ROAD_Z1, C.asphalt, M.asphalt)
	-- (Gearport: this road is now the eastbound half of Piston Avenue -> dashed white lane line, median at z -104..-96)
	for lx = Site.MAP_X0 + 6, Site.MAP_X1 - 6, 18 do
		if not (lx > 18 and lx < 34) and not (lx > 188 and lx < 228) then
			box(road, "LaneDash", lx - 3, 0, -85.15, lx + 3, 0.05, -84.85, C.lineWhite, M.smooth, { collide = false })
		end
	end
	-- dashed edge lines near each curb
	for x = Site.MAP_X0 + 4, Site.MAP_X1 - 4, 16 do
		box(road, "EdgeDash", x - 3, 0, -75.2, x + 3, 0.05, -74.9, C.lineWhite, M.smooth, { collide = false })
		box(road, "EdgeDash", x - 3, 0, -95.1, x + 3, 0.05, -94.8, C.lineWhite, M.smooth, { collide = false })
	end

	-- sidewalks: near (with three curb cuts) and far. Sidewalk top 0.5, curb cut top 0.1.
	local walk = Kit.folder(site, "Sidewalk")
	local cuts = { { Site.EXIT_X0, Site.EXIT_X1 }, { Site.SERVICE_X0, Site.SERVICE_X1 }, { Site.ENTRY_X0, Site.ENTRY_X1 } }
	local x = Site.MAP_X0
	for _, cut in ipairs(cuts) do
		box(walk, "Sidewalk", x, -1, Site.WALK_Z0, cut[1], 0.5, Site.WALK_Z1, C.sidewalk, M.concrete)
		box(walk, "CurbCut", cut[1], -1, Site.WALK_Z0, cut[2], 0.1, Site.WALK_Z1, C.concrete, M.concrete)
		box(walk, "Curb", x, -1, Site.WALK_Z0 - 0.5, cut[1], 0.5, Site.WALK_Z0, C.curb, M.concrete)
		x = cut[2]
	end
	-- (the cross street cuts both sidewalks at x CROSS_X0..CROSS_X1)
	box(walk, "Sidewalk", x, -1, Site.WALK_Z0, Site.CROSS_X0, 0.5, Site.WALK_Z1, C.sidewalk, M.concrete)
	box(walk, "Sidewalk", Site.CROSS_X1, -1, Site.WALK_Z0, Site.MAP_X1, 0.5, Site.WALK_Z1, C.sidewalk, M.concrete)
	box(walk, "Curb", x, -1, Site.WALK_Z0 - 0.5, Site.CROSS_X0, 0.5, Site.WALK_Z0, C.curb, M.concrete)
	box(walk, "Curb", Site.CROSS_X1, -1, Site.WALK_Z0 - 0.5, Site.MAP_X1, 0.5, Site.WALK_Z0, C.curb, M.concrete)
	-- (the old far sidewalk z -104..-96 is now the avenue median: World/Gearport)
	-- sidewalk joints every 8 (depth): drawn on each sidewalk slab's top (v31: were ~100 parts, freed for the bay).
	-- Top-face SurfaceGui axes (probed 10-22): gui X runs along -Z from the slab's +Z edge, gui Y along +X from its -X edge.
	for _, p in ipairs(walk:GetChildren()) do
		if p:IsA("BasePart") and p.Name == "Sidewalk" then
			local x0, len = p.Position.X - p.Size.X / 2, p.Size.X
			local gui = Instance.new("SurfaceGui")
			gui.Name = "Joints"
			gui.Face = Enum.NormalId.Top
			gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			gui.PixelsPerStud = 5
			gui.LightInfluence = 1
			for jx = Site.MAP_X0 + 8, Site.MAP_X1 - 8, 8 do
				if jx > x0 + 0.5 and jx < x0 + len - 0.5 then
					local f = Instance.new("Frame")
					f.BorderSizePixel = 0
					f.BackgroundColor3 = C.curb
					f.Position = UDim2.fromScale(0, (jx - x0) / len)
					f.Size = UDim2.new(7.5 / p.Size.Z, 0, 0, 1) -- from the lot edge to the curb (0.2 stud = 1 px)
					f.Parent = gui
				end
			end
			gui.Parent = p
		end
	end

	-- the shop lot: asphalt, drive lane, parking row, side drive to the back, back lane
	local lot = Kit.folder(site, "Lot")
	box(lot, "Lot", Site.LOT_X0, -1, Site.WALK_Z1, Site.LOT_X1, 0, -20, C.asphaltLot, M.asphalt)
	box(lot, "SideDrive", 38, -1, -20, 56, 0, 44, C.asphaltLot, M.asphalt)
	box(lot, "BackLane", -54, -1, 20, 38, 0, 44, C.asphaltLot, M.asphalt)
	-- lot edge curbs (west / east)
	box(lot, "LotCurb", Site.LOT_X0 - 1, -1, Site.WALK_Z1, Site.LOT_X0, 0.5, -20, C.curb, M.concrete)
	box(lot, "LotCurb", Site.LOT_X1, -1, Site.WALK_Z1, Site.LOT_X1 + 1, 0.5, -20, C.curb, M.concrete)
	-- parking row: 6 spots 12 wide x 20 deep, white lines, wheel stops. Spots 1..4 are the rack corner + curb + queue stalls
	-- (cars drive straight in off the avenue, nose to the shop: no wheel stop, no Parking marker — World/Curbside)
	local parking = Kit.folder(garage, "Parking")
	for i, px in ipairs(Site.PARKING_X) do
		if (px < Site.SERVICE_X0 or px > Site.SERVICE_X1) and px ~= Site.CORNER_X then
			marker(parking, "Parking" .. i, Vector3.new(px, 0, -56), Vector3.new(0, 0, -1), Vector3.new(8, 0.2, 18))
			box(lot, "WheelStop", px - 3, 0, -64.5, px + 3, 0.5, -63.7, C.concrete, M.concrete)
		end
	end
	for _, lx in ipairs({ -36, -24, -12, 0, 12, 24, 36 }) do
		box(lot, "ParkingLine", lx - 0.2, 0, -66, lx + 0.2, 0.05, -46, C.lineWhite, M.smooth, { collide = false })
	end
	-- arrows on the drive lane (one-way: in at east, out at west)
	for _, ax in ipairs({ 70, 20, -40 }) do
		box(lot, "LaneArrow", ax - 4, 0, -38.3, ax + 2, 0.05, -37.7, C.lineWhite, M.smooth, { collide = false })
		box(lot, "LaneArrowHead", ax - 5, 0, -39.2, ax - 4, 0.05, -36.8, C.lineWhite, M.smooth, { collide = false })
	end
	-- light poles at the lot front (fixtures only; lights come last)
	-- (kept off the car routes: lane z -36, entry x 48, exit x -95, parking x -36..36)
	for _, lx in ipairs({ -42, 106 }) do
		Kit.post(lot, "LightPole", lx, -60, 0, 24, 0.8, C.metalDark, M.metal)
		box(lot, "LightHead", lx - 0.6, 23, -60 - 1, lx + 0.6, 24, -60 + 3, C.metalDark, M.metal)
	end

	-- traffic markers (cars follow these; see world_contract.md)
	local traffic = Kit.folder(garage, "Traffic")
	marker(traffic, "RoadIn", Vector3.new(-250, 0, -79.5), Vector3.new(1, 0, 0))
	-- v23: every route point is on the road or a curb cut — a straight leg between two of them never crosses the
	-- sidewalk (RoadIn -> EntryCurb used to cut 120 studs of it). Turn points sit in the near lane before / after a cut.
	marker(traffic, "EntryTurn", Vector3.new(42, 0, -79.5), Vector3.new(6, 0, 9.5).Unit) -- road: swing right into the entry cut
	marker(traffic, "EntryCurb", Vector3.new(48, 0, -70), Vector3.new(0, 0, 1))
	marker(traffic, "LaneEast", Vector3.new(48, 0, -36), Vector3.new(-1, 0, 0))
	marker(traffic, "LaneWest", Vector3.new(-95, 0, -36), Vector3.new(0, 0, -1))
	marker(traffic, "ExitCurb", Vector3.new(-95, 0, -70), Vector3.new(0, 0, -1))
	marker(traffic, "ExitTurn", Vector3.new(-88, 0, -81), Vector3.new(1, 0, 0)) -- road: out of the exit cut, now heading east
	marker(traffic, "RoadOut", Vector3.new(250, 0, -79.5), Vector3.new(1, 0, 0))
	marker(traffic, "SideDriveFront", Vector3.new(47, 0, -24), Vector3.new(0, 0, 1))
	marker(traffic, "SideDriveBack", Vector3.new(47, 0, 32), Vector3.new(-1, 0, 0))

	-- junkyard road (north, behind the shop) — exists from Lv1, closed by a barrier until the junkyard unlocks (Lv8, Config.JunkyardLevel)
	local jy = Kit.model(garage, "Junkyard")
	jy:SetAttribute("UnlockLevel", 8)
	box(jy, "JunkyardRoad", 40, -1, 44, 54, 0, 204, C.asphaltWorn, M.asphalt)
	local barrier = Kit.model(jy, "Barrier")
	for _, bx in ipairs({ 42, 47, 52 }) do
		box(barrier, "Leg", bx - 1.6, 0, 47.8, bx - 1.3, 3.6, 48.2, C.metalDark, M.metal)
		box(barrier, "Leg", bx + 1.3, 0, 47.8, bx + 1.6, 3.6, 48.2, C.metalDark, M.metal)
	end
	box(barrier, "Board", 40, 2.4, 47.7, 54, 3.4, 47.9, C.lineWhite, M.smooth)
	for sx = 40.5, 53.5, 2 do
		box(barrier, "Stripe", sx, 2.4, 47.6, sx + 1, 3.4, 47.7, Color3.fromRGB(236, 110, 30), M.smooth, { collide = false })
	end
	box(barrier, "Block", 40, 0, 48.2, 54, 3.6, 48.4, C.metalDark, M.smooth, { transparency = 1 }) -- keeps players / cars out
	-- "closed until Lv8" road sign (gone with the barrier at Lv8; readable from the shop side, face -Z)
	for _, px in ipairs({ 44.2, 49.7 }) do
		box(barrier, "SignPost", px, 0, 47.8, px + 0.3, 7.2, 48.1, C.metalDark, M.metal)
	end
	local signTop = box(barrier, "SignTop", 41.5, 5.9, 47.5, 52.5, 7.4, 47.8, Color3.fromRGB(206, 44, 38), M.smooth)
	Kit.label(signTop, Enum.NormalId.Front, "SALVAGE YARD", Color3.new(1, 1, 1), Color3.fromRGB(28, 30, 40))
	local signLow = box(barrier, "SignLow", 41.5, 4.2, 47.5, 52.5, 5.9, 47.8, Color3.fromRGB(250, 248, 240), M.smooth)
	Kit.label(signLow, Enum.NormalId.Front, "Opens at Level 8", Color3.fromRGB(30, 30, 36), nil)
	-- the yard itself (fence, gate, office container, wreck spots, pink pile / crane places): World/Junkyard
	marker(jy, "JunkyardEntry", Vector3.new(47, 0, 192), Vector3.new(0, 0, 1))

	-- neighbours / houses / trees: World/Town.luau
	-- low fences at lot sides / back
	local fence = Kit.folder(site, "Fence")
	for fz = -60, 80, 10 do
		box(fence, "FencePost", -107.3, 0, fz - 0.3, -106.7, 5, fz + 0.3, C.metalDark, M.metal)
	end
	box(fence, "FenceMesh", -107.1, 0.5, -60, -106.9, 5, 86, C.metal, M.metal, { transparency = 0.5 })
	box(fence, "FenceMesh", -107, 0.5, 85.9, 40, 5, 86.1, C.metal, M.metal, { transparency = 0.5 })
	box(fence, "FenceMesh", 54, 0.5, 85.9, 120, 5, 86.1, C.metal, M.metal, { transparency = 0.5 })
	for fx = -100, 120, 10 do
		if fx < 40 or fx > 54 then
			box(fence, "FencePost", fx - 0.3, 0, 85.7, fx + 0.3, 5, 86.3, C.metalDark, M.metal)
		end
	end
end

return Site
