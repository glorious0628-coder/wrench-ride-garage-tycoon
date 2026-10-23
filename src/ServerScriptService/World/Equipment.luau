--!strict
-- World/Equipment: shop equipment built from parts (README 'build vs 3D': anything parts read well as = builder).
-- Real photos: notes/research/ref_garage_small (01, 05, 11, 14, 17) + style_B (blue posts, yellow arms, red chest).
--   Equipment.lift(bay)  -> bay.Lift: two-post lift on bay.LiftSpot. Moving parts are ONE model, Lift.Carriage:
--                           move it with  Carriage:PivotTo(Lift.CarriageHome.CFrame + Vector3.yAxis * y)
--                           y = car_spec 3-3 (Ground 0 / Wheel 2 / Under 6). Pads sit under the car's LiftPoint_*.
--   floor jack, engine crane, scrap bin, oil drums, waiting-room sofa: see Equipment.build.
-- Names other code uses: docs/specs/world_contract.md.

local Kit = require(script.Parent.Kit)
local GearportProps = require(script.Parent.GearportProps)
local C, M = Kit.C, Kit.M
local box, marker, rod = Kit.box, Kit.marker, Kit.rod

local Equipment = {}

local F = 0.2
local ARM = Color3.fromRGB(246, 196, 40)
local PAD = Color3.fromRGB(34, 34, 38)
local POST = Color3.fromRGB(30, 80, 200)
local POST_DARK = Color3.fromRGB(22, 58, 150)

-- car_spec numbers the lift depends on — ONE place to change when car_spec moves (now car_spec v0.7):
-- LiftPoint_* (±x, y, ±z), lift heights, car height, wheel size. Pads sit centred on the LiftPoints.
Equipment.LIFT = {
	pointX = 3.0, pointY = 0.5, pointZ = 3.0, -- car_spec §7 LiftPoint_* = (±3.0, 0.5, ∓3.0)
	wheel = 1.8, under = 6.0, -- car_spec §3-3 Wheel / Under (v0.7: Wheel 2.0 -> 1.8)
	carHeight = 5.8, -- car_spec §0
	wheelRadius = 1.375, wheelZ = 5.0, -- car_spec §0 / 4-1 (v0.7: tyre 2.75)
	padDiameter = 0.7, -- v0.7: 1.0 -> 0.7 so the pad stays >= 0.25 clear of the bigger wheels
	minClearance = 0.25,
}
local LIFT = Equipment.LIFT

-- gap between a pad's outer edge and the wheel's inner edge (along the car), and roof-to-beam at Under
function Equipment.liftClearance(): (number, number)
	local padGap = (LIFT.wheelZ - LIFT.wheelRadius) - (LIFT.pointZ + LIFT.padDiameter / 2)
	local beamBottom = math.max(13, LIFT.under + LIFT.carHeight + 1.2) - 0.4
	local roofGap = beamBottom - (LIFT.under + LIFT.carHeight)
	return padGap, roofGap
end
do
	local padGap = Equipment.liftClearance()
	if padGap < LIFT.minClearance then
		warn(("[World] lift pad only %.2f from the wheel (want %.2f): check Equipment.LIFT vs car_spec"):format(padGap, LIFT.minClearance))
	end
end

-- the car is placed with car:PivotTo(CarSpot.CFrame), and LiftSpot has the same CFrame, so car-local
-- coordinates (car_spec: front = local -Z, right = +X, y from the floor) ARE the LiftSpot frame
local function carLocal(spot: CFrame, x: number, y: number, z: number): CFrame
	return spot * CFrame.new(x, y, z)
end

-- two looks share one structure (same names, same Carriage / Control / CarriageHome):
--   Old       = Lv1 "Old Lift": shorter faded posts, grey arms, Wheel height only (attribute MaxLevel = "Wheel")
--   Hydraulic = Lv6 "Hydraulic Lift" upgrade: tall blue posts, yellow arms, Under height (MaxLevel = "Under")
-- Both are named "Lift"; World/Upgrades keeps exactly one of them in the bay (UpgradeId "HydraulicLift").
local LIFT_STYLES = {
	Old = {
		post = Color3.fromRGB(122, 148, 170), postDark = Color3.fromRGB(92, 110, 128), arm = Color3.fromRGB(150, 150, 146),
		pad = Color3.fromRGB(58, 56, 54), stripe = Color3.fromRGB(196, 168, 92), height = math.max(10.6, LIFT.wheel + LIFT.carHeight + 2.6), postW = 1.4,
		control = Color3.fromRGB(206, 180, 96), maxLevel = "Wheel", rust = true,
	},
	Hydraulic = {
		post = POST, postDark = POST_DARK, arm = ARM, pad = PAD, stripe = ARM, height = math.max(13, LIFT.under + LIFT.carHeight + 1.2), postW = 1.6,
		control = ARM, maxLevel = "Under", rust = false,
	},
}

function Equipment.lift(bay: Instance, variant: string?): Model?
	local spot = bay:FindFirstChild("LiftSpot") :: BasePart?
	if not spot then
		return nil
	end
	local st = LIFT_STYLES[variant or "Hydraulic"] or LIFT_STYLES.Hydraulic
	local S = spot.CFrame
	local postX = (spot:GetAttribute("PostOffsetX") :: number?) or 6
	local H = st.height
	local lift = Kit.model(nil, "Lift")
	lift:SetAttribute("Levels", "Ground=0,Wheel=2,Under=6")
	lift:SetAttribute("Variant", variant or "Hydraulic")
	lift:SetAttribute("MaxLevel", st.maxLevel)

	-- static: base plates, posts, top beam, hose, warning stripes
	local postZ = -0.5 -- car-local z (a little toward the front: engine weight)
	for _, side in ipairs({ -1, 1 }) do
		local cx = side * postX
		local base = carLocal(S, cx, 0, postZ)
		Kit.part(lift, "BasePlate", Vector3.new(3, 0.2, 3), base * CFrame.new(0, 0.1, 0), C.metal, M.diamond)
		Kit.part(lift, side < 0 and "PostL" or "PostR", Vector3.new(st.postW, H, st.postW), base * CFrame.new(0, 0.2 + H / 2, 0), st.post, M.smooth)
		Kit.part(lift, "PostTrack", Vector3.new(0.3, H - 1, 1.0), base * CFrame.new(side * (st.postW / 2 + 0.15), 0.2 + H / 2, 0), st.postDark, M.metal, { collide = false })
		Kit.part(lift, "PostCap", Vector3.new(st.postW + 0.4, 0.4, st.postW + 0.4), base * CFrame.new(0, H + 0.4, 0), st.postDark, M.smooth)
		for k = 0, 2 do
			Kit.part(lift, "SafetyStripe", Vector3.new(st.postW + 0.06, 0.3, st.postW + 0.06), base * CFrame.new(0, 1.6 + k * 0.6, 0), k % 2 == 0 and st.stripe or st.pad, M.smooth, { collide = false })
		end
		if st.rust then
			-- worn: rust patches + a dented panel
			Kit.part(lift, "Rust", Vector3.new(st.postW + 0.04, 1.2, 0.8), base * CFrame.new(0, 5.2 + side, 0.2), Color3.fromRGB(150, 96, 62), M.metal, { collide = false })
			Kit.part(lift, "Rust", Vector3.new(st.postW + 0.04, 0.6, 1.0), base * CFrame.new(0, 0.8, 0), Color3.fromRGB(140, 90, 60), M.metal, { collide = false })
		end
	end
	Kit.part(lift, "TopBeam", Vector3.new(postX * 2 + st.postW, 0.8, 1.0), carLocal(S, 0, H, postZ), st.post, M.smooth)
	Kit.part(lift, "Hose", Vector3.new(postX * 2, 0.2, 0.2), carLocal(S, 0, H - 0.55, postZ - 0.3), PAD, M.smooth, { collide = false })
	-- power unit on the right post (car-local +X) + control box
	local pu = carLocal(S, postX + 1.3, 0, postZ)
	Kit.part(lift, "PowerUnit", Vector3.new(1, 2.2, 1.2), pu * CFrame.new(0, 3.2, 0), st.rust and Color3.fromRGB(110, 110, 104) or C.metalDark, M.metal)
	Kit.part(lift, "Motor", Vector3.new(0.9, 0.9, 0.9), pu * CFrame.new(0, 4.8, 0), st.postDark, M.metal, { shape = "cyl" })
	local ctl = Kit.part(lift, "Control", Vector3.new(0.8, 1.6, 0.6), carLocal(S, postX + 1.3, 6.2, postZ), st.control, M.smooth)
	Kit.part(lift, "ButtonUp", Vector3.new(0.3, 0.3, 0.1), ctl.CFrame * CFrame.new(0, 0.3, -0.33), Color3.fromRGB(60, 190, 80), M.neon, { collide = false })
	Kit.part(lift, "ButtonDown", Vector3.new(0.3, 0.3, 0.1), ctl.CFrame * CFrame.new(0, -0.3, -0.33), Color3.fromRGB(220, 50, 40), M.neon, { collide = false })
	local home = Kit.marker(lift, "CarriageHome", S.Position, S.LookVector)

	-- moving: carriages on the posts, 4 swing arms to the pads under the car's LiftPoint_* (±3.0, 0.5, ∓3.0)
	local car = Kit.model(lift, "Carriage")
	local root = Kit.part(car, "CarriageRoot", Vector3.new(1, 0.2, 1), home.CFrame, C.marker, M.smooth, { collide = false, transparency = 1, shadow = false })
	root.CanQuery = false
	root.CanTouch = false
	car.PrimaryPart = root
	local armY = 0.15 -- arm centre at Ground (arm 0.3 thick sits on the floor)
	for _, side in ipairs({ -1, 1 }) do
		local cx = side * (postX - st.postW / 2 - 0.3)
		local slider = carLocal(S, cx, 0, postZ)
		Kit.part(car, "CarriageBlock", Vector3.new(0.8, 2.4, 1.4), slider * CFrame.new(0, 0.2 + 1.2, 0), st.postDark, M.metal, { collide = false })
		local hub = (slider * CFrame.new(0, armY, 0)).Position
		for _, pz in ipairs({ -LIFT.pointZ, LIFT.pointZ }) do
			local padCF = carLocal(S, side * LIFT.pointX, 0, pz)
			local tip = (padCF * CFrame.new(0, armY, 0)).Position
			rod(car, "Arm", hub, tip, 0.6, 0.3, st.arm, M.smooth, { collide = false })
			Kit.part(car, "PadBase", Vector3.new(math.max(0.2, LIFT.pointY - 0.15), LIFT.padDiameter - 0.1, LIFT.padDiameter - 0.1), padCF * CFrame.new(0, math.max(0.2, LIFT.pointY - 0.15) / 2 + 0.05, 0) * CFrame.Angles(0, 0, math.rad(90)), st.arm, M.smooth, { shape = "cyl", collide = false })
			-- pad top = floor + car LiftPoint height (0.2 + 0.5) at Ground
			Kit.part(car, "Pad", Vector3.new(0.1, LIFT.padDiameter, LIFT.padDiameter), padCF * CFrame.new(0, LIFT.pointY - 0.05, 0) * CFrame.Angles(0, 0, math.rad(90)), st.pad, M.smooth, { shape = "cyl", collide = false })
		end
		Kit.part(car, "ArmHub", Vector3.new(0.5, 1.0, 1.0), carLocal(S, cx, armY, postZ) * CFrame.Angles(0, 0, math.rad(90)), st.postDark, M.metal, { shape = "cyl", collide = false })
	end
	spot:SetAttribute("Installed", true)
	lift:SetAttribute("UpgradeId", "HydraulicLift")
	lift:SetAttribute("UpgradeState", if variant == "Old" then "Locked" else "Owned")
	lift.Parent = bay
	return lift
end

-- Lv1 has no lift (user decision 10-21, work_view v0.5 §2b): floor jack + 2 jack stands + creeper + 2 wheel chocks.
-- Real order (carbook under_car_work.md, Camry manual): chocks on the other axle -> floor jack at the centre jack
-- point -> stands under the rocker support points (= car LiftPoint_*) -> lower onto the stands -> slide under on
-- the creeper. Here they wait at the bay's west wall: stands + chocks on the floor, the creeper hung on a hook.
-- The old lift is not built any more (the hydraulic lift still comes with the HydraulicLift upgrade).
Equipment.OLD_LIFT = false

-- jack stand (local origin = floor centre): 4 splayed legs (pyramid), a ratchet column, a rubber-topped saddle
local STAND_RED = Color3.fromRGB(196, 44, 38)
local function jackStand(parent: Instance, name: string, cf: CFrame): Model
	local m = Kit.model(parent, name)
	local top = cf * CFrame.new(0, 1.15, 0)
	for _, c in ipairs({ { -0.6, -0.6 }, { 0.6, -0.6 }, { 0.6, 0.6 }, { -0.6, 0.6 } }) do
		rod(m, "Leg", (cf * CFrame.new(c[1], 0.06, c[2])).Position, top.Position, 0.18, 0.18, STAND_RED, M.metal)
	end
	Kit.part(m, "Column", Vector3.new(0.3, 0.9, 0.3), cf * CFrame.new(0, 1.45, 0), Color3.fromRGB(176, 180, 186), M.metal)
	Kit.part(m, "Saddle", Vector3.new(0.75, 0.16, 0.36), cf * CFrame.new(0, 1.98, 0), PAD, M.smooth) -- rubber top (manual: rubber pad on the stand)
	Kit.part(m, "Handle", Vector3.new(0.12, 0.12, 0.6), cf * CFrame.new(0.2, 1.2, -0.3) * CFrame.Angles(math.rad(25), 0, 0), Color3.fromRGB(176, 180, 186), M.metal, { collide = false })
	return m
end

-- creeper (local origin = centre of the board, board in local XZ, head toward local -Z, casters toward local -Y)
local function creeper(parent: Instance, cf: CFrame): Model
	local m = Kit.model(parent, "Creeper")
	-- the main's 3D creeper (one MeshPart, named Board so World/Interior can lean it): the model's pivot stays the
	-- board centre WorkService expects (the lying surface 0.11 above it ≈ 0.1 above the mesh's middle); the mesh's
	-- headrest comes in at +Z, turned half a circle to the local -Z here
	local mp = GearportProps.mesh(m, "Creeper", 0, 0, 0, 0, true)
	if mp then
		mp.Name = "Board"
		mp.PivotOffset = CFrame.identity
		mp.CFrame = cf * CFrame.new(0, -0.1, 0) * CFrame.Angles(0, math.pi, 0)
		m.WorldPivot = cf
		return m
	end
	Kit.part(m, "Board", Vector3.new(1.5, 0.22, 3.6), cf, Color3.fromRGB(196, 44, 38), M.smooth)
	Kit.part(m, "Headrest", Vector3.new(1.0, 0.24, 0.6), cf * CFrame.new(0, 0.22, -1.35), PAD, M.smooth)
	for _, c in ipairs({ { -0.55, -1.5 }, { 0.55, -1.5 }, { -0.55, 0 }, { 0.55, 0 }, { -0.55, 1.5 }, { 0.55, 1.5 } }) do
		Kit.part(m, "Caster", Vector3.new(0.34, 0.34, 0.34), cf * CFrame.new(c[1], -0.24, c[2]), PAD, M.smooth, { collide = false, shape = "ball" })
	end
	return m
end

-- rubber wheel chock (local origin = floor centre, the slope faces local -Z = toward the tyre)
local function chock(parent: Instance, name: string, cf: CFrame)
	Kit.part(parent, name, Vector3.new(0.9, 0.6, 1.0), cf * CFrame.new(0, 0.3, 0), C.yellow, M.smooth, { shape = "wedge" })
end

local function floorJack(parent: Instance, x: number, z: number, yaw: number)
	-- low red trolley jack (photo 04 / 11), handle back toward +Z of its frame
	local m = Kit.model(parent, "FloorJack1")
	local O = CFrame.new(x, F, z) * CFrame.Angles(0, math.rad(yaw), 0)
	Kit.part(m, "Body", Vector3.new(1.2, 0.6, 2.6), O * CFrame.new(0, 0.5, 0), C.red, M.smooth)
	Kit.part(m, "Body", Vector3.new(0.9, 0.3, 2.2), O * CFrame.new(0, 0.95, 0.1), C.redDark, M.smooth)
	Kit.part(m, "LiftArm", Vector3.new(0.5, 0.25, 1.4), O * CFrame.new(0, 0.95, -1.2) * CFrame.Angles(math.rad(-12), 0, 0), C.redDark, M.smooth)
	Kit.part(m, "Saddle", Vector3.new(0.25, 0.8, 0.8), O * CFrame.new(0, 1.2, -1.85) * CFrame.Angles(0, 0, math.rad(90)), PAD, M.smooth, { shape = "cyl" })
	for _, wx in ipairs({ -0.65, 0.65 }) do
		for _, wz in ipairs({ -1.0, 1.0 }) do
			Kit.part(m, "Wheel", Vector3.new(0.2, 0.5, 0.5), O * CFrame.new(wx, 0.25, wz), PAD, M.smooth, { shape = "cyl" })
		end
	end
	local a = (O * CFrame.new(0, 0.9, 1.2)).Position
	local b = (O * CFrame.new(0, 3.6, 3.8)).Position
	rod(m, "Handle", a, b, 0.2, 0.2, C.steel, M.metal)
	Kit.part(m, "Grip", Vector3.new(0.9, 0.3, 0.3), CFrame.new(b) * O.Rotation, PAD, M.smooth)
	marker(m, "UsePoint", (O * CFrame.new(0, 0, 5.2)).Position, O.LookVector)
	return m
end

-- the jack set of one bay: wallX = the bay's west wall inner face, cx / cz = the car spot (CarSpot) centre.
-- Markers (storage spots, world_contract ★ 잭 세트): FloorJackSpot (saddle toward LookVector), StandSpot1/2,
-- ChockSpot1/2, CreeperWallSpot (hung, LookVector out of the wall), CreeperFloorSpot (laid by the car's left
-- rocker, LookVector = slide-under direction). Where they go ON the car = the car's own points (car_spec
-- LiftPoint_* for the stands; jack points front / rear centre) — code reads those from the car.
function Equipment.jackKit(bay: Instance, wallX: number, cx: number, cz: number, withJack: boolean): Model
	local kit = Kit.model(bay, "JackKit")
	local dz = cz + 1 -- (Bay1's car spot is z -1: the numbers below were laid out there)
	if withJack then
		local j = floorJack(kit, cx - 4.5, dz + 8.5, 0)
		j:SetAttribute("Placeholder3D", "FloorJack") -- the 3D floor jack replaces it (main)
	end
	marker(kit, "FloorJackSpot", Vector3.new(cx - 4.5, F, dz + 8.5), Vector3.new(0, 0, -1))
	for i, sz in ipairs({ -6.0, -1.8 }) do -- (clear of the oil drums at z -10.4..-8)
		jackStand(kit, "JackStand" .. i, CFrame.new(wallX + 1.4, F, dz + sz) * CFrame.Angles(0, math.rad(i * 17), 0))
		marker(kit, "StandSpot" .. i, Vector3.new(wallX + 1.4, F, dz + sz), Vector3.new(0, 0, -1))
	end
	-- creeper on a wall hook, board upright, casters out, head up
	box(kit, "CreeperHook", wallX, 5.0, dz - 4.7, wallX + 0.35, 5.2, dz - 4.1, Color3.fromRGB(150, 154, 160), M.metal)
	creeper(kit, CFrame.new(wallX + 0.4, 3.1, dz - 4.4) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(90), 0, 0))
	marker(kit, "CreeperWallSpot", Vector3.new(wallX + 0.4, 3.1, dz - 4.4), Vector3.new(1, 0, 0))
	marker(kit, "CreeperFloorSpot", Vector3.new(cx - 6.6, F, cz), Vector3.new(1, 0, 0))
	for i, kz in ipairs({ 0.4, 1.6 }) do
		chock(kit, "WheelChock" .. i, CFrame.new(wallX + 1.0, F, dz + kz) * CFrame.Angles(0, math.rad(90), 0))
		marker(kit, "ChockSpot" .. i, Vector3.new(wallX + 1.0, F, dz + kz), Vector3.new(1, 0, 0))
	end
	return kit
end

-- the bay's parts cart (work_view: old part onto the cart, new part from the cart; bought parts are delivered here).
-- Real 3-shelf steel service cart: lipped trays, 4 corner posts, 4 black casters, push handle on one end, all red.
-- Stands by the car's front left (car left = +X, nose = +Z), long side along the car. The TOP TRAY is the part
-- named `PartsCart` (code: WorkService.cartSpot / WorkView cartAt — parts go on its top, 3 x 2 grid along its local X / Z),
-- so the model itself has another name (`BayCart`): FindFirstChild("PartsCart", true) must hit the tray.
function Equipment.partsCart(bay: Instance, cx: number, cz: number): Model
	local m = Kit.model(bay, "BayCart")
	m:SetAttribute("Kind", "PartsCart")
	local O = CFrame.new(cx + 8.6, F, cz + 5.6) * CFrame.Angles(0, math.rad(90), 0) -- local +X = world -Z (handle toward the door); clear of the counter ServicePoint
	local L, W = 4.8, 2.8
	local hx, hz = L / 2 - 0.1, W / 2 - 0.1
	local function p(n: string, size: Vector3, off: CFrame, color: Color3, mat: Enum.Material?, opts: Kit.Opts?): BasePart
		return Kit.part(m, n, size, O * off, color, mat, opts)
	end
	for i, ty in ipairs({ 0.9, 2.1, 3.3 }) do
		p(if i == 3 then "PartsCart" else "Tray", Vector3.new(L, 0.2, W), CFrame.new(0, ty, 0), C.red, M.smooth)
		for _, s in ipairs({ -1, 1 }) do
			p("TrayLip", Vector3.new(L, 0.35, 0.1), CFrame.new(0, ty + 0.27, s * (W / 2 - 0.05)), C.redDark, M.smooth)
			if i == 3 then
				p("TrayLip", Vector3.new(0.1, 0.35, W - 0.2), CFrame.new(s * (L / 2 - 0.05), ty + 0.27, 0), C.redDark, M.smooth)
			end
		end
	end
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			local top = if sx > 0 then 4.2 else 3.45 -- the handle end's posts carry the handle
			p("Post", Vector3.new(0.2, top - 0.6, 0.2), CFrame.new(sx * hx, 0.6 + (top - 0.6) / 2, sz * hz), C.red, M.smooth)
			p("Caster", Vector3.new(0.3, 0.6, 0.6), CFrame.new(sx * hx, 0.3, sz * hz) * CFrame.Angles(0, math.rad(90), 0), PAD, M.smooth, { shape = "cyl" })
		end
	end
	for _, sz in ipairs({ -1, 1 }) do
		p("HandleArm", Vector3.new(0.7, 0.15, 0.15), CFrame.new(hx + 0.35, 4.1, sz * hz), C.red, M.smooth)
	end
	p("HandleGrip", Vector3.new(W, 0.22, 0.22), CFrame.new(hx + 0.7, 4.1, 0) * CFrame.Angles(0, math.rad(90), 0), PAD, M.smooth, { shape = "cyl" })
	p("PartsBin", Vector3.new(1.4, 0.7, 1.1), CFrame.new(-1.0, 1.35, 0.3), C.blue, M.smooth, { collide = false })
	return m
end

local function engineCrane(parent: Instance, x: number, z: number)
	-- folding shop crane (photo 04): two leg rails with casters, mast, boom, chain + hook. Faces +X (into the bay).
	local m = Kit.model(parent, "EngineCrane1")
	local red = C.red
	for _, lz in ipairs({ -1.4, 1.4 }) do
		box(m, "Leg", x, F + 0.3, z + lz - 0.25, x + 6, F + 0.8, z + lz + 0.25, red, M.smooth)
		Kit.part(m, "Caster", Vector3.new(0.3, 0.6, 0.6), CFrame.new(x + 5.7, F + 0.3, z + lz) * CFrame.Angles(0, math.rad(90), 0), PAD, M.smooth, { shape = "cyl" })
	end
	box(m, "Crossbar", x - 0.3, F + 0.3, z - 1.65, x + 0.3, F + 0.8, z + 1.65, red, M.smooth)
	box(m, "Mast", x - 0.3, F + 0.8, z - 0.3, x + 0.3, F + 7, z + 0.3, red, M.smooth)
	local top = Vector3.new(x, F + 6.8, z)
	local tip = Vector3.new(x + 4.6, F + 7.8, z)
	rod(m, "Boom", top, tip, 0.5, 0.5, red, M.smooth)
	rod(m, "Ram", Vector3.new(x, F + 2.4, z), Vector3.new(x + 2.2, F + 7.2, z), 0.3, 0.3, C.steel, M.metal)
	box(m, "Chain", tip.X - 0.06, F + 4.4, z - 0.06, tip.X + 0.06, tip.Y, z + 0.06, C.metalDark, M.metal, { collide = false })
	box(m, "Hook", tip.X - 0.25, F + 3.9, z - 0.1, tip.X + 0.25, F + 4.4, z + 0.1, C.metalDark, M.metal, { collide = false })
	return m
end

local function scrapBin(garage: Instance, x: number, z: number)
	-- where old parts get thrown (wr-dev ask ①). Open-top steel bin, yellow rim, a few junk pieces inside.
	local m = Kit.model(garage, "ScrapBin")
	local grey = Color3.fromRGB(96, 104, 112)
	local w, d, h = 3.2, 3.2, 3.0
	local x0, x1, z0, z1 = x - w / 2, x + w / 2, z - d / 2, z + d / 2
	box(m, "Floor", x0, F, z0, x1, F + 0.3, z1, grey, M.metal)
	box(m, "Side", x0, F, z0, x0 + 0.2, F + h, z1, grey, M.metal)
	box(m, "Side", x1 - 0.2, F, z0, x1, F + h, z1, grey, M.metal)
	box(m, "Side", x0 + 0.2, F, z0, x1 - 0.2, F + h, z0 + 0.2, grey, M.metal)
	box(m, "Side", x0 + 0.2, F, z1 - 0.2, x1 - 0.2, F + h, z1, grey, M.metal)
	for _, r in ipairs({ { x0 - 0.05, z0 - 0.05, x1 + 0.05, z0 + 0.25 }, { x0 - 0.05, z1 - 0.25, x1 + 0.05, z1 + 0.05 },
		{ x0 - 0.05, z0, x0 + 0.25, z1 }, { x1 - 0.25, z0, x1 + 0.05, z1 } }) do
		box(m, "Rim", r[1], F + h, r[2], r[3], F + h + 0.2, r[4], C.yellow, M.smooth)
	end
	local lab = box(m, "Plate", x1 + 0.0, F + 1.2, z - 1.0, x1 + 0.05, F + 2.2, z + 1.0, C.yellow, M.smooth, { collide = false })
	Kit.label(lab, Enum.NormalId.Right, "SCRAP", Color3.fromRGB(30, 30, 36), nil)
	-- junk inside (rusty bits)
	local rust = Color3.fromRGB(150, 92, 60)
	box(m, "Junk", x - 0.9, F + 0.3, z - 0.8, x + 0.3, F + 1.5, z + 0.4, rust, M.metal, { collide = false })
	Kit.part(m, "Junk", Vector3.new(0.6, 1.6, 1.6), CFrame.new(x + 0.5, F + 1.2, z + 0.5) * CFrame.Angles(0.3, 0, 1.2), C.metalDark, M.metal, { shape = "cyl", collide = false })
	box(m, "Junk", x - 0.2, F + 1.4, z - 1.1, x + 1.0, F + 1.8, z + 0.0, rust, M.metal, { collide = false })
	marker(m, "DropPoint", Vector3.new(x + w / 2 + 1.6, F, z), Vector3.new(-1, 0, 0)) -- player stands here
	marker(m, "DropSpot", Vector3.new(x, F + h, z), Vector3.new(0, 0, 1)) -- part falls in here
	return m
end

local function oilDrums(parent: Instance, x: number, z: number)
	local m = Kit.model(parent, "OilDrums")
	-- the main's 3D 55-gallon drums (10-22, real size 2.10 across x 3.13 tall, colour in their SurfaceAppearance)
	local blue = GearportProps.mesh(m, "OilDrum_Blue", x, F + 0.4, z - 1.25, 0, true)
	local red = GearportProps.mesh(m, "OilDrum", x, F + 0.4, z + 1.25, math.rad(40), true)
	if blue and red then
		blue.Name = "Drum"
		red.Name = "Drum"
		box(m, "SpillTray", x - 1.35, F, z - 2.5, x + 1.35, F + 0.4, z + 2.5, C.yellow, M.metal)
		-- hand pump in the blue drum's bung
		local top = F + 0.4 + blue.Size.Y
		box(m, "Pump", x - 0.15, top, z - 1.55, x + 0.15, top + 1.9, z - 1.25, C.steel, M.metal)
		box(m, "PumpHandle", x - 0.1, top + 1.7, z - 1.6, x + 0.1, top + 1.9, z - 0.5, C.rubber, M.smooth)
		return m
	end
	for _, d in ipairs(m:GetChildren()) do
		d:Destroy()
	end
	box(m, "SpillTray", x - 1.6, F, z - 2.9, x + 1.6, F + 0.4, z + 2.9, C.yellow, M.metal)
	for i, dz in ipairs({ -1.4, 1.4 }) do
		local col = i == 1 and C.blue or C.red
		Kit.post(m, "Drum", x, z + dz, F + 0.4, F + 4.2, 2.4, col, M.metal)
		for _, ry in ipairs({ 1.6, 3.0 }) do
			Kit.post(m, "DrumRib", x, z + dz, F + 0.4 + ry - 0.08, F + 0.4 + ry + 0.08, 2.5, col, M.metal, { collide = false })
		end
		Kit.post(m, "DrumLid", x, z + dz, F + 4.2, F + 4.3, 2.3, C.metalDark, M.metal)
	end
	-- hand pump on the blue drum
	box(m, "Pump", x - 0.15, F + 4.3, z - 1.55, x + 0.15, F + 6.2, z - 1.25, C.steel, M.metal)
	box(m, "PumpHandle", x - 0.1, F + 6.0, z - 1.6, x + 0.1, F + 6.2, z - 0.5, C.rubber, M.smooth)
	return m
end

local function sofa(wr: Instance, seats: Instance, x0: number, x1: number, zBack: number)
	-- two-seat sofa along the storefront glass, facing +Z (into the room). Seat5 / Seat6 for NPCs.
	local col = Color3.fromRGB(104, 150, 210)
	local dark = Color3.fromRGB(80, 122, 184)
	local m = Kit.model(wr, "Sofa")
	box(m, "Base", x0, F, zBack, x1, F + 1.8, zBack + 3, dark, M.smooth)
	box(m, "Back", x0, F + 1.8, zBack, x1, F + 4.6, zBack + 0.9, col, M.smooth)
	box(m, "Arm", x0 - 0.8, F, zBack, x0, F + 3.0, zBack + 3, col, M.smooth)
	box(m, "Arm", x1, F, zBack, x1 + 0.8, F + 3.0, zBack + 3, col, M.smooth)
	local n = #seats:GetChildren()
	local w = (x1 - x0) / 2
	for k = 0, 1 do
		local cx = x0 + w * (k + 0.5)
		local s = Kit.part(seats, "Seat" .. (n + k + 1), Vector3.new(w - 0.2, 0.6, 2.1), CFrame.lookAt(Vector3.new(cx, F + 2.1, zBack + 1.95), Vector3.new(cx, F + 2.1, zBack + 10)),
			col, M.smooth, { class = "Seat" })
		s:SetAttribute("Facing", "+Z")
	end
	return m
end

function Equipment.build(garage: Model)
	local bays = garage:FindFirstChild("Bays") :: Folder
	local bay1 = bays:FindFirstChild("Bay1")
	if bay1 then
		if Equipment.OLD_LIFT then
			Equipment.lift(bay1, "Old")
		end
		Equipment.lift(bay1, "Hydraulic")
		Equipment.jackKit(bay1, -13, 0, -1, false)
		Equipment.partsCart(bay1, 0, -1)
	end
	local tools = garage:FindFirstChild("Tools") :: Folder
	floorJack(tools, -4.5, 8.5, 0):SetAttribute("Placeholder3D", "FloorJack") -- Bay 1's jack (Tools.FloorJack1)
	engineCrane(tools, -12.6, -15.6)
	scrapBin(garage, -11.2, 14.2)
	oilDrums(garage:FindFirstChild("Dressing") or garage, -11.4, -9.8) -- (v35: 0.6 toward the door so the charger reads clear of the red drum)
	local wr = garage:FindFirstChild("WaitingRoom")
	local seats = wr and wr:FindFirstChild("Seats")
	if wr and seats then
		sofa(wr, seats, 18, 25, -18.8)
	end
end

return Equipment
