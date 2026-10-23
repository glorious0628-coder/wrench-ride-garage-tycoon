--!strict
-- World/GearportSkyLoop (wr-builder): Gearport stage 4 (plan: notes/design/detroit_town_plan.md §3 H; photo
-- notes/research/ref_detroit #17 — a small two-car automated train on a concrete guideway).
-- A guideway over the avenue median (top y 30, above the street trees), columns between the median's trees and
-- lamps, two stations (DEPOT by Union Depot, CHASSIS ST by the crossing) and a two-car train.
-- The train moves only on clients: StarterPlayerScripts/SkyLoop.client.luau shuttles it between StopWest and
-- StopEast (looks only — no game rule, nobody rides it).
-- Stations (review notes/gpt/main/skyloop_r1_a.md): a platform longer than the train under a roof over the track,
-- and an elevator tower down to the median at each end of the line — its street door is shut with a
-- "CLOSED FOR SERVICE" plate (you can see how people would get up there, and that you can't today).

local Kit = require(script.Parent.Kit)
local C, M = Kit.C, Kit.M
local box, marker = Kit.box, Kit.marker

local SkyLoop = {}

local Z = -100 -- median centre (median z -104..-96)
local TOP = 30 -- guideway top
local XW, XE = -360, 192 -- line ends = the elevator towers' outer faces' inner sides (see towers below)
local TOWER = 4.5 -- elevator tower length along X
local GW0, GW1 = XW, XE - TOWER -- guideway runs between the towers
local FLOOR = TOP + 1.2 -- platform top = the train's floor
local DECO = { collide = false }
local CONCRETE = Color3.fromRGB(206, 204, 198)
local STEEL = Color3.fromRGB(70, 74, 82)
local CITY_BLUE = Color3.fromRGB(40, 86, 170)
local CITY_ORANGE = Color3.fromRGB(232, 128, 40)
local WINDOW = Color3.fromRGB(50, 64, 84)
local HALF = 17.6 -- half the train's length with its cab noses

local function signBoth(part: BasePart, title: string, ppsx: number)
	for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
		local g = Kit.label(part, face, title, Color3.new(1, 1, 1), nil, Enum.Font.GothamBold)
		g.PixelsPerStud = ppsx
	end
end

-- side platform south of the track (x0..x1) under a canopy that also covers the track
local function station(parent: Instance, name: string, x0: number, x1: number, title: string)
	local m = Kit.model(parent, name)
	local zb = Z - 8 -- back of the platform
	box(m, "Platform", x0, TOP - 0.4, zb, x1, FLOOR, Z - 2.5, Color3.fromRGB(222, 216, 202), M.concrete)
	box(m, "PlatformEdge", x0, FLOOR, Z - 3.1, x1, FLOOR + 0.05, Z - 2.5, C.yellow, M.smooth, DECO)
	box(m, "Fascia", x0, TOP - 0.6, zb - 0.2, x1, FLOOR, zb, CITY_BLUE, M.smooth, DECO)
	box(m, "GlassWall", x0, FLOOR, zb, x1, TOP + 7, zb + 0.2, Color3.fromRGB(150, 190, 210), M.glass, { transparency = 0.5 })
	for _, px in ipairs({ x0 + 1, (x0 + x1) / 2, x1 - 1 }) do
		Kit.post(m, "CanopyPost", px, zb + 0.6, FLOOR, TOP + 7, 0.5, STEEL, M.metal)
	end
	-- a narrow second platform on the shop side, so the station reads as one from there too (the train hid the first)
	local zn = Z + 6
	box(m, "PlatformNorth", x0, TOP - 0.4, Z + 2.5, x1, FLOOR, zn, Color3.fromRGB(222, 216, 202), M.concrete)
	box(m, "PlatformEdge", x0, FLOOR, Z + 2.5, x1, FLOOR + 0.05, Z + 3.1, C.yellow, M.smooth, DECO)
	box(m, "Fascia", x0, TOP - 0.6, zn, x1, FLOOR, zn + 0.2, CITY_BLUE, M.smooth, DECO)
	box(m, "Railing", x0, FLOOR, zn - 0.2, x1, FLOOR + 3.2, zn, Color3.fromRGB(150, 190, 210), M.glass, { transparency = 0.5 })
	box(m, "Canopy", x0 - 0.5, TOP + 7, zb - 0.6, x1 + 0.5, TOP + 7.6, zn + 0.6, Color3.fromRGB(70, 96, 88), M.metal)
	-- name board along the roof's street edges (read from both sides of the avenue)
	local sign = box(m, "Sign", (x0 + x1) / 2 - 9, TOP + 7.6, zn + 0.3, (x0 + x1) / 2 + 9, TOP + 9.6, zn + 0.5, CITY_BLUE, M.smooth, DECO)
	signBoth(sign, title, 20)
	local back = box(m, "BackSign", (x0 + x1) / 2 - 9, TOP + 7.6, zb - 0.5, (x0 + x1) / 2 + 9, TOP + 9.6, zb - 0.3, CITY_BLUE, M.smooth, DECO)
	signBoth(back, title, 20)
end

-- elevator tower in the median at a line end: shaft, glass strips, shut street door with a plate
local function tower(parent: Instance, name: string, x0: number, x1: number, doorFace: Enum.NormalId)
	local m = Kit.model(parent, name)
	local z0, z1 = Z - 3.6, Z + 3.6
	box(m, "Shaft", x0, 0.5, z0, x1, TOP + 8.4, z1, CONCRETE, M.concrete, { shadow = false })
	for _, zz in ipairs({ z0 - 0.1, z1 }) do -- the lift's glass strip on both street faces
		box(m, "ShaftGlass", x0 + 1, 2, zz, x1 - 1, TOP + 6.5, zz + 0.1, WINDOW, M.glass, DECO)
	end
	box(m, "Cap", x0 - 0.3, TOP + 8.4, z0 - 0.3, x1 + 0.3, TOP + 9.2, z1 + 0.3, Color3.fromRGB(70, 96, 88), M.metal)
	local band = box(m, "NameBand", x0 - 0.05, TOP + 3, z0 - 0.15, x1 + 0.05, TOP + 5.4, z1 + 0.15, CITY_BLUE, M.smooth, DECO)
	signBoth(band, "SKYLOOP", 20)
	-- street door on the outer face: closed, no handle, plate on it
	local out = if doorFace == Enum.NormalId.Right then 1 else -1
	local fx = if out > 0 then x1 else x0
	box(m, "Door", fx - 0.1 * out, 0.5, Z - 1.6, fx + 0.1 * out, 7.5, Z + 1.6, STEEL, M.metal, DECO)
	box(m, "DoorFrame", fx - 0.05 * out, 7.5, Z - 2, fx + 0.15 * out, 8.1, Z + 2, Color3.fromRGB(150, 156, 164), M.metal, DECO)
	local plate = box(m, "ClosedPlate", fx + 0.1 * out, 3.8, Z - 1.3, fx + 0.2 * out, 5.4, Z + 1.3, C.yellow, M.smooth, DECO)
	local g = Kit.label(plate, doorFace, "CLOSED FOR\nSERVICE", Color3.fromRGB(30, 30, 30), nil, Enum.Font.GothamBlack)
	g.PixelsPerStud = 30
	box(m, "Lamp", fx + 0.1 * out, 8.3, Z - 0.6, fx + 0.35 * out, 8.7, Z + 0.6, Color3.fromRGB(255, 236, 190), M.neon, DECO)
end

-- two-car train, cab noses at both ends (it runs both ways); Root (invisible) = the pivot the client script moves
local function train(parent: Instance, x: number): Model
	local t = Kit.model(parent, "Train")
	t.ModelStreamingMode = Enum.ModelStreamingMode.Persistent -- small; the client script needs it present
	local y0 = TOP + 0.6
	local root = Kit.part(t, "Root", Vector3.new(1, 1, 1), CFrame.new(x, y0, Z), C.steel, M.smooth, { collide = false, transparency = 1 })
	root.CanQuery = false
	root.CanTouch = false
	t.PrimaryPart = root
	local white = Color3.fromRGB(240, 240, 236)
	for k = 0, 1 do
		local cx = x - 7.5 + k * 15
		local livery = if k == 0 then CITY_BLUE else CITY_ORANGE
		box(t, "Body", cx - 7, y0 + 0.8, Z - 2.2, cx + 7, y0 + 5.6, Z + 2.2, white, M.smooth, DECO)
		box(t, "Windows", cx - 6.4, y0 + 3.2, Z - 2.25, cx + 6.4, y0 + 4.8, Z + 2.25, WINDOW, M.glass, DECO)
		local band = box(t, "Livery", cx - 7.05, y0 + 1.2, Z - 2.3, cx + 7.05, y0 + 2.8, Z + 2.3, livery, M.smooth, DECO)
		for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
			local g = Kit.label(band, face, "SKYLOOP", Color3.new(1, 1, 1), nil, Enum.Font.GothamBlack)
			g.PixelsPerStud = 16
		end
		box(t, "Roof", cx - 6.8, y0 + 5.6, Z - 2, cx + 6.8, y0 + 6.1, Z + 2, Color3.fromRGB(150, 156, 164), M.metal, DECO)
		box(t, "Skirt", cx - 6.4, y0, Z - 1.8, cx + 6.4, y0 + 0.8, Z + 1.8, Color3.fromRGB(60, 62, 68), M.metal, DECO)
		-- cab nose on the outer end: a short lower nose in the car's colour + a big raked windscreen, headlights
		local s = if k == 0 then -1 else 1
		local ex = cx + s * 7 -- the car's outer end
		local L = HALF - 14.5
		box(t, "Nose", math.min(ex, ex + s * L), y0 + 0.8, Z - 2.2, math.max(ex, ex + s * L), y0 + 2.8, Z + 2.2, livery, M.smooth, DECO)
		Kit.part(t, "Windscreen", Vector3.new(4.4, 2.8, L), CFrame.new(ex + s * L / 2, y0 + 4.2, Z) * CFrame.Angles(0, -s * math.pi / 2, 0),
			WINDOW, M.glass, { collide = false, shape = "wedge" })
		box(t, "Headlights", ex + s * (L - 0.05), y0 + 1.5, Z - 1.8, ex + s * (L + 0.05), y0 + 2.1, Z + 1.8, Color3.fromRGB(255, 244, 214), M.neon, DECO)
	end
	return t
end

function SkyLoop.build(garage: Model)
	local town = garage:FindFirstChild("Town") or Kit.folder(garage, "Town")
	local sl = Kit.model(town, "SkyLoop")
	-- guideway: one beam + two low side walls (from below it reads as a concrete ribbon)
	box(sl, "Guideway", GW0, TOP - 1.5, Z - 2.4, GW1, TOP, Z + 2.4, CONCRETE, M.concrete, { shadow = false })
	for _, s in ipairs({ -1, 1 }) do
		box(sl, "GuideWall", GW0, TOP, Z + s * 2.4 - 0.25, GW1, TOP + 0.9, Z + s * 2.4 + 0.25, Color3.fromRGB(186, 184, 178), M.concrete, { collide = false, shadow = false })
	end
	-- columns in the median, between its trees (x = -424 + 36k) and banner lamps (x = -406 + 36k)
	for x = -343, GW1 - 4, 36 do
		if not (x > 18 and x < 34) then
			Kit.post(sl, "Column", x, Z, 0.6, TOP - 1.5, 2.2, CONCRETE, M.concrete)
			box(sl, "ColumnCap", x - 1.6, TOP - 3, Z - 2.6, x + 1.6, TOP - 1.5, Z + 2.6, CONCRETE, M.concrete)
		end
	end
	-- stops (train Root, nose +X): the train fills its platform with a little to spare at each end
	local westX, eastX = GW0 + HALF + 1.5, GW1 - HALF - 1.5
	-- towers stand in the median at the line ends (the DEPOT one by Union Depot's front, the CHASSIS ST one by
	-- the corner crosswalk's refuge); their door faces outward, down the avenue
	tower(sl, "TowerDepot", XW - TOWER, XW, Enum.NormalId.Left)
	tower(sl, "TowerChassis", GW1, XE, Enum.NormalId.Right)
	-- platforms run from the tower (their end landing) past the train's far end
	station(sl, "StationDepot", XW - TOWER, westX + HALF + 2, "SKYLOOP · DEPOT")
	station(sl, "StationChassis", eastX - HALF - 2, XE, "SKYLOOP · CHASSIS ST")
	local y0 = TOP + 0.6
	marker(sl, "StopWest", Vector3.new(westX, y0, Z), Vector3.new(1, 0, 0))
	marker(sl, "StopEast", Vector3.new(eastX, y0, Z), Vector3.new(1, 0, 0))
	train(sl, westX)
end

return SkyLoop
