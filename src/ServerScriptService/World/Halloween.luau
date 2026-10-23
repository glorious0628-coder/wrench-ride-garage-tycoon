--!strict
-- World/Halloween (wr-builder, 10-21): Ella's evening on the map (docs/design/halloween_pumpkin.md v0.3 §4·§5b).
--   Halloween.marks(garage)  always there (invisible markers + the trophy shelf; HalloweenService / Halloween.luau
--                            read them):
--     Bays.BayN.CinemaCam_Street / CinemaCam_Door   each bay's own camera spots (eye position; arrive / leave cuts)
--     Cinema.CinemaCam_StreetEnd                    the corner where the coach stops (Traffic.ExitCurb) and pops
--     Cinema.CinemaCam_Shelf                        1.8 in front of the slipper on the trophy shelf
--     Cinema.PopSpot / PumpkinRollTo / CoachAppear  where the coach stops for the bells, where the pumpkin rolls,
--                                                   where its lights first show on the avenue (optional for code)
--     WaitingRoom.TrophyShelf + SlipperSpot         "SPECIAL GUESTS" shelf by the photo wall; the slipper's sole
--                                                   centre, toe = LookVector (-Z)
--   Halloween.decor() -> Model "HalloweenDecor"     only in the Halloween weeks (World/Seasonal parents it in):
--     a US neighbourhood shop at Halloween — hay bales with jack-o'-lanterns and corn stalks by the doors,
--     orange / purple string lights across the front, cobwebs in the bay door / window corners, and the
--     "Closing soon" sign hanging in the office window (ClosingSign: SurfaceGui "Label", off until HalloweenService
--     enables it; Seasonal lights its glow then). Jack-o'-lanterns are part stand-ins (Placeholder3D "JackOLantern").
-- Everything sits in front of the facade shell (z <= -21) and away from the doors, so it fits all three shop eras.

local Kit = require(script.Parent.Kit)

local C, M = Kit.C, Kit.M

local Halloween = {}

local F = 0.2 -- floor top
local DECO = { collide = false, shadow = false }
local ORANGE = Color3.fromRGB(232, 122, 34)
local PURPLE = Color3.fromRGB(150, 74, 222)
local GLOW = Color3.fromRGB(255, 196, 80)
local STRAW = Color3.fromRGB(240, 208, 122) -- (fabric darkens it: reads as golden straw)
local STALK = Color3.fromRGB(196, 170, 112)
local WEB = Color3.fromRGB(240, 240, 236)

-- markers ------------------------------------------------------------------------------------------------------

local function camMark(parent: Instance, name: string, eye: Vector3, at: Vector3): BasePart
	return Kit.marker(parent, name, eye, (at - eye).Unit)
end

-- the trophy shelf on the waiting room's east wall, between the poster and the corner (by the photo wall)
local function trophyShelf(room: Instance): BasePart
	local s = Kit.model(room, "TrophyShelf")
	local wx = 37.0 -- the wall's inside face
	Kit.box(s, "Board", wx - 0.95, 6.3, -1.5, wx, 6.5, 1.3, C.wood, M.wood)
	for _, z in ipairs({ -1.1, 0.9 }) do
		Kit.part(s, "Bracket", Vector3.new(0.12, 0.6, 0.6), CFrame.new(wx - 0.3, 6.0, z) * CFrame.Angles(0, math.rad(90), 0), C.metalDark,
			M.metal, { shape = "wedge", shadow = false })
	end
	local plaque = Kit.box(s, "Plaque", wx - 0.06, 5.0, -1.0, wx, 5.6, 0.8, Color3.fromRGB(196, 160, 72), M.metal, DECO)
	Kit.label(plaque, Enum.NormalId.Left, "SPECIAL GUESTS", Color3.fromRGB(60, 40, 18), nil, Enum.Font.GothamBold)
	-- a small warm light over the shelf (the slipper shot is at night)
	local lamp = Kit.box(s, "ShelfLamp", wx - 0.5, 8.3, -0.5, wx, 8.5, 0.3, C.metalDark, M.metal, DECO)
	local glow = Instance.new("SpotLight")
	glow.Face = Enum.NormalId.Bottom
	glow.Color = Color3.fromRGB(255, 220, 170)
	glow.Brightness = 2
	glow.Range = 6
	glow.Angle = 70
	glow.Parent = lamp
	return Kit.marker(s, "SlipperSpot", Vector3.new(wx - 0.5, 6.5, -0.1), Vector3.new(0, 0, -1), Vector3.new(0.6, 0.2, 1.2))
end

function Halloween.marks(garage: Model)
	local bays = garage:FindFirstChild("Bays")
	for _, bay in ipairs(if bays then bays:GetChildren() else {}) do
		local spot = bay:FindFirstChild("CarSpot")
		if spot and spot:IsA("BasePart") then
			local cx = spot.Position.X
			-- across the front lane (in the customer lot), high enough to see the sign and the door
			camMark(bay, "CinemaCam_Street", Vector3.new(cx + 14, 6.5, -58), Vector3.new(cx, 6, -1))
			-- just inside the door, beside the car's path (3 studs off its side), above the door handles
			camMark(bay, "CinemaCam_Door", Vector3.new(cx + 6.8, 5.0, -18.6), Vector3.new(cx + 7, 2.7, -3))
		end
	end
	local cine = Kit.folder(garage, "Cinema")
	-- the coach leaves by the exit drive (Traffic.ExitCurb (-95, 0, -70)) and stops there for the bells
	camMark(cine, "CinemaCam_StreetEnd", Vector3.new(-83, 5, -59), Vector3.new(-96, 3, -75)) -- (Union Depot's clock tower in the back, left)
	Kit.marker(cine, "PopSpot", Vector3.new(-95, 0, -70), Vector3.new(0, 0, -1))
	Kit.marker(cine, "PumpkinRollTo", Vector3.new(-112, 0, -84), Vector3.new(-1, 0, 0))
	Kit.marker(cine, "CoachAppear", Vector3.new(-170, 0, -79.5), Vector3.new(1, 0, 0))
	local room = garage:FindFirstChild("WaitingRoom")
	if room then
		local slipper = trophyShelf(room)
		camMark(cine, "CinemaCam_Shelf", Vector3.new(34.0, 7.6, 1.6), slipper.Position + Vector3.new(0, 0.2, 0))
	end
end

-- decor ----------------------------------------------------------------------------------------------------------

-- a jack-o'-lantern: squat orange ball, stem, glowing diamond eyes + nose, wide mouth on its -Z (front) side
local function lantern(parent: Instance, x: number, y0: number, z: number, d: number, yaw: number)
	local m = Kit.model(parent, "JackOLantern")
	m:SetAttribute("Placeholder3D", "JackOLantern")
	local ry = d * 0.39
	local base = CFrame.new(x, y0 + ry, z) * CFrame.Angles(0, math.rad(yaw), 0)
	local body = Kit.part(m, "Body", Vector3.new(d, ry * 2, d), base, ORANGE, M.smooth, { collide = false })
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = body
	Kit.part(m, "Stem", Vector3.new(d * 0.24, d * 0.12, d * 0.12), base * CFrame.new(0, ry + d * 0.08, 0) * CFrame.Angles(math.rad(8), 0, math.rad(90)),
		Color3.fromRGB(104, 110, 58), M.wood, { shape = "cyl", collide = false, shadow = false })
	local r = d / 2
	local function onFace(fx: number, fy: number): CFrame
		local k = 1 - (fx / r) ^ 2 - (fy / ry) ^ 2
		return base * CFrame.new(fx, fy, -r * math.sqrt(math.max(k, 0.05)) + 0.03)
	end
	local e = d * 0.17
	for _, s in ipairs({ -1, 1 }) do
		Kit.part(m, "Eye", Vector3.new(e, e, 0.08), onFace(s * d * 0.2, ry * 0.25) * CFrame.Angles(0, 0, math.rad(45)), GLOW, M.neon, DECO)
	end
	Kit.part(m, "Nose", Vector3.new(e * 0.6, e * 0.6, 0.08), onFace(0, -ry * 0.05) * CFrame.Angles(0, 0, math.rad(45)), GLOW, M.neon, DECO)
	Kit.part(m, "Mouth", Vector3.new(d * 0.5, e * 0.55, 0.08), onFace(0, -ry * 0.42), GLOW, M.neon, DECO)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 150, 60)
	light.Range = 6 + d * 2
	light.Brightness = 1.2
	light.Shadows = false
	light.Parent = body
end

-- a square straw bale (about 3 x 1.3 x 1.6), long side along X unless turned
local function bale(parent: Instance, cf: CFrame, long: number)
	Kit.part(parent, "HayBale", Vector3.new(long, 1.3, 1.6), cf, STRAW, M.fabric, { shadow = true })
	-- the two twine bands a real bale has
	for _, s in ipairs({ -1, 1 }) do
		Kit.part(parent, "Twine", Vector3.new(0.08, 1.34, 1.64), cf * CFrame.new(s * long * 0.27, 0, 0), Color3.fromRGB(150, 118, 64), M.fabric, DECO)
	end
end

-- a bundle of dry corn stalks tied to lean on the wall (the classic porch-post decoration)
local function cornStalks(parent: Instance, x: number, z: number, h: number)
	local m = Kit.model(parent, "CornStalks")
	local r = Kit.rng(math.floor(x * 10))
	for i = 1, 5 do
		local a = (i - 3) * 0.13
		local foot = Vector3.new(x + (i - 3) * 0.16, F, z + (r() - 0.5) * 0.2)
		local top = Vector3.new(x + math.sin(a) * h * 0.4, F + h * (0.92 + r() * 0.08), z + 0.15)
		Kit.rod(m, "Stalk", foot, top, 0.16, 0.16, STALK:Lerp(Color3.fromRGB(170, 140, 84), r()), M.wood, DECO)
	end
	Kit.part(m, "Tie", Vector3.new(0.3, 1.0, 1.0), CFrame.new(x, F + h * 0.45, z + 0.05) * CFrame.Angles(0, 0, math.rad(90)), ORANGE, M.fabric,
		{ shape = "cyl", collide = false, shadow = false })
	-- two dry leaves hanging off
	for _, s in ipairs({ -1, 1 }) do
		Kit.part(m, "Leaf", Vector3.new(0.05, 2.2, 0.35), CFrame.new(x + s * 0.45, F + h * 0.62, z - 0.1) * CFrame.Angles(0, 0, math.rad(s * 28)),
			STALK, M.fabric, DECO)
	end
end

-- a corner cobweb: threads fanning out of a corner + two rings of threads across them
local function cobweb(parent: Instance, corner: Vector3, dx: number, dy: number, len: number)
	local m = Kit.model(parent, "Cobweb")
	local ends = {}
	for i = 0, 3 do
		local a = math.rad(i * 30)
		local p = corner + Vector3.new(dx * math.cos(a), dy * math.sin(a), 0) * len
		Kit.rod(m, "Thread", corner, p, 0.05, 0.05, WEB, M.smooth, { collide = false, shadow = false, transparency = 0.2 })
		table.insert(ends, (p - corner).Unit)
	end
	for _, k in ipairs({ 0.45, 0.8 }) do
		for i = 1, 3 do
			local a, b = corner + ends[i] * len * k, corner + ends[i + 1] * len * (k - 0.06)
			Kit.rod(m, "Thread", a, b, 0.04, 0.04, WEB, M.smooth, { collide = false, shadow = false, transparency = 0.3 })
		end
	end
	return m
end

-- string lights along the front: wire in shallow droops between hooks, C9 bulbs alternating orange / purple
local function stringLights(parent: Instance, x0: number, x1: number, y: number, z: number, spans: number)
	local m = Kit.model(parent, "StringLights")
	local per = 4 -- wire pieces per droop; a bulb hangs at each joint between the hooks
	local prev: Vector3? = nil
	local n = 0
	for s = 0, spans - 1 do
		local a = x0 + (x1 - x0) * s / spans
		local b = x0 + (x1 - x0) * (s + 1) / spans
		for k = (if s == 0 then 0 else 1), per do
			local t = k / per
			local p = Vector3.new(a + (b - a) * t, y - 0.75 * (1 - (2 * t - 1) ^ 2), z)
			if prev then
				Kit.rod(m, "Wire", prev, p, 0.06, 0.06, C.rubber, M.smooth, DECO)
			end
			if k > 0 and k < per then
				n += 1
				Kit.part(m, "Bulb", Vector3.new(0.3, 0.42, 0.3), CFrame.new(p - Vector3.new(0, 0.26, 0)),
					if n % 2 == 0 then PURPLE else ORANGE, M.neon, { shape = "ball", collide = false, shadow = false })
			end
			prev = p
		end
	end
end

-- "Closing soon" — a dark neon-style sign hanging inside the office window (HalloweenService switches "Label")
local function closingSign(parent: Instance)
	local m = Kit.model(parent, "ClosingSignHanger")
	-- the left pane's middle, between the mullions (x 15 / 22, z -19.8..-19.2) and in front of the StoreGlass
	-- (z -19.6..-19.4: Glass material hides a SurfaceGui behind it)
	local cx, cy, cz = 18.5, 8.9, -19.71
	local glow = Kit.part(m, "SignGlow", Vector3.new(6.1, 2.0, 0.04), CFrame.new(cx, cy, cz + 0.1), Color3.fromRGB(70, 40, 90), M.smooth, DECO)
	local sign = Kit.part(parent, "ClosingSign", Vector3.new(5.7, 1.6, 0.16), CFrame.new(cx, cy, cz), Color3.fromRGB(28, 26, 32), M.smooth, DECO)
	local gui = Kit.label(sign, Enum.NormalId.Front, "Closing soon", Color3.fromRGB(255, 156, 52), Color3.fromRGB(255, 226, 190), Enum.Font.FredokaOne)
	gui.LightInfluence = 0
	gui.Brightness = 2
	gui.Enabled = false
	local light = Instance.new("PointLight")
	light.Name = "SignLight"
	light.Color = Color3.fromRGB(255, 150, 60)
	light.Range = 12
	light.Brightness = 1.6
	light.Enabled = false
	light.Parent = glow
	for _, s in ipairs({ -1, 1 }) do
		Kit.box(m, "Chain", cx + s * 2.3 - 0.04, cy + 0.8, cz - 0.04, cx + s * 2.3 + 0.04, 11.9, cz + 0.04, C.metal, M.metal, DECO)
	end
end

function Halloween.decor(): Model
	local d = Kit.model(nil, "HalloweenDecor")
	d:SetAttribute("Season", "Halloween")
	-- left of the bay door: the tyre display + tyre stack stand in front of the pillar, so a lantern sits on the
	-- stack, a small one in front of the display, and corn stalks lean on the pillar behind them
	lantern(d, 15.5, 3.62, -26.4, 1.6, -10)
	lantern(d, 12.6, F, -28.1, 1.1, 8)
	cornStalks(d, 14.3, -21.2, 6.4)
	-- right of the bay door, between the bay and the Bay 2 wall
	bale(d, CFrame.new(-12.3, F + 0.65, -22.0), 3.2)
	bale(d, CFrame.new(-12.4, F + 1.95, -21.95) * CFrame.Angles(0, math.rad(-5), 0), 2.6)
	lantern(d, -12.0, F + 2.6, -22.2, 1.5, 12)
	lantern(d, -11.6, F, -23.6, 1.1, -6)
	cornStalks(d, -13.7, -21.15, 6.0)
	-- beside the office door (right of it, clear of the 5.4 door)
	bale(d, CFrame.new(36.7, F + 0.65, -22.55) * CFrame.Angles(0, math.rad(90), 0), 3.1)
	lantern(d, 36.7, F + 1.3, -22.0, 1.3, 6)
	lantern(d, 37.0, F, -25.0, 1.0, -12)
	cornStalks(d, 37.9, -21.15, 6.2)
	-- string lights across the front, under every era's sign / canopy and above the door heads
	stringLights(d, -13.5, 38.0, 15.2, -21.35, 6)
	-- cobwebs: both top corners of the bay door, the office window's top-left corner
	cobweb(d, Vector3.new(-8.0, 13.4, -20.75), 1, -1, 3.0)
	local web = cobweb(d, Vector3.new(8.0, 13.4, -20.75), -1, -1, 3.2)
	Kit.part(web, "Spider", Vector3.new(0.45, 0.45, 0.45), CFrame.new(6.9, 12.1, -20.8), C.rubber, M.smooth, { shape = "ball", collide = false, shadow = false })
	Kit.part(web, "SpiderHead", Vector3.new(0.28, 0.28, 0.28), CFrame.new(6.75, 12.35, -20.8), C.rubber, M.smooth, { shape = "ball", collide = false, shadow = false })
	cobweb(d, Vector3.new(15.3, 11.5, -20.75), 1, -1, 2.6)
	closingSign(d)
	for _, p in ipairs(d:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanQuery = p.Name == "HayBale"
			p.CanTouch = false
		end
	end
	return d
end

return Halloween
