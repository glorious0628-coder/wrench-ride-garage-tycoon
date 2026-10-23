-- Bake ReplicatedStorage.CarMeshes from the uploaded 3D (art/3d/models.json). Run in an EDIT window (MCP execute_luau,
-- datamodel Edit), then save the place. Safe to run again: it rebuilds the folder.
--   wr-dev: py tools/studio_mcp.py call execute_luau '{"code": <this file>, "datamodel_type": "Edit"}'
--
-- What it makes (contract: src/ReplicatedStorage/Shared/CarParts.luau MeshSets / DecorShow, ClientModules/CarLook):
--   <set>_Detail       Model, PrimaryPart "Root" = the part's pivot (car_spec), meshes in car axes for that side.
--                      Sets: Wheel, BrakePads(+_L), Battery, Radiator, Muffler, Hood, Bumper_F, Bumper_R,
--                      Hub(+_L) = disc + hub + caliper bracket at the wheel centre, BrakeCaliper(+_L) at the pad centre
--   Decor_<Name>       Model, Root = the car's origin: Shell, Glass, Chassis
--   Tool_<Name>        the tool's MeshPart (origin = its bbox centre): Wrench, ImpactWrench, OBDScanner, FusePuller, PlugSocket,
--                      TrimTool, HosePliers, DrainPan (+ Tool_FusePuller_Rig / Tool_HosePliers_Rig: Models of 2 arm MeshParts with attribute Rest)
--   Gear_FloorJack     the Lv1 floor jack (art/3d/floor_jack/floor_jack_attachments.json): 4 MeshParts in jack axes
--                      (origin = ground under the frame, saddle toward -Z), each with attribute Rest = its rest CFrame;
--                      Server JackLook swaps the map's block jacks for it and poses arm / saddle / handle
--   Crossover_<...>    the SUV's own (CarParts.Types / TypeSets): Decor_*, Hood, Bumper_F/R, Wheel (the sedan rim
--                      with the tire scaled to 2.98 x 1.15, suv_spec 1); its brakes / engine parts are the shared ones
--   fault looks        (art/3d/fault_parts/fault_parts_attachments.json, sedan): Decor_EngineBay = decor v2 + the two
--                      see-through tanks (body 0.45 see-through, cap, hose / base); Decor_Levels = the liquids
--                      Deco_Level_Coolant(_Upper) / Deco_Level_BrakeFluid (CarLook moves each top, bottom fixed);
--                      Decor_Wipers = WiperArm_/WiperBlade_ Long / Short, each with attribute Rest (car frame);
--                      Decor_WiperBladesWorn = WiperBlade_*_Worn (whole meshes, v5); the hood nozzles ride in
--                      Hood_Detail (attribute NoPaint: they keep their own black)
-- Right-side meshes are used turned 180° on the left when there is no _L mesh (CarLook does that).
-- Imported assets come in turned 180° about Y (glTF -> Roblox): every mesh is turned back to the GLB / car_spec axes.

local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IDS = {
	Rim = 139088387585730, Tire = 94542215577057, Disc = 140365082604222,
	Caliper = 137205984668214, Caliper_L = 82743934393862,
	CaliperBracket = 73820205616095, CaliperBracket_L = 93908905565085,
	BrakePads = 108783550922289, BrakePads_L = 111423408528956,
	Hub = 93130000454719, Hub_L = 95762820179213,
	Battery = 98474124924077, Radiator = 88604251574747, Muffler = 114818495252771,
	Wrench = 104628384291107, ImpactWrench = 129594226567770, OBDScanner = 71355787312813,
	-- hand tools 2nd set (10-22, art/3d/tools_v2, art/3d/models.json); *_Rig = two arm meshes that squeeze
	FusePuller = 71030507898919, FusePuller_Rig = 70753500396822, PlugSocket = 99005400792708, TrimTool = 131742311936777,
	HosePliers = 136437699216590, HosePliers_Rig = 134285288625913,
	DrainPan = 124236586583210, -- 10-22 (the fixed-handle version): Tool_DrainPan, bay equipment (Fluid:Coolant), not a hand tool
	sedan_shell = 137209673676814, sedan_glass = 80782899687101, sedan_hood = 116525512404749,
	sedan_bumper_f = 75620652934264, sedan_bumper_r = 126962097903321, sedan_chassis = 81698167242468,
	-- batch 2 (10-21): Lite corners, decor, hood prop, wreck pieces
	Rim_Lite = 75826263494102, Tire_Lite = 75329683092084, Brake_Lite = 117012886529643, Brake_Lite_L = 78867124523606,
	sedan_deco_enginebay = 77409174503854, -- v2 (10-22): no tanks of its own (v1 129815421268502), goes WITH the tanks
	sedan_deco_enginetop = 102840621249630,
	sedan_deco_enginelower = 118976991016539, sedan_deco_transaxle = 104407360593530,
	sedan_deco_frontsubframe = 136289450773889, sedan_deco_underbody = 124784293721785,
	sedan_deco_rearaxle = 74447456637207, sedan_hoodprop = 108835751476191,
	FloorJack = 87141781841597, -- 4 meshes: Body · Arm · Saddle · Handle (10-21 17:00)
	sedan_bumper_f_dented = 112335431997932, Tire_Flat = 131378583836683, sedan_headlight_crack_L = 83308083501339,
	-- SUV (10-21, art/3d/suv_body B_concept + decor)
	suv_shell = 115153728519871, suv_glass = 102512937058551, suv_hood = 82592788872051,
	suv_bumper_f = 98607031876113, suv_bumper_r = 71906722932311, suv_chassis = 103120939891596,
	suv_deco_enginebay = 135345504518532, suv_deco_enginetop = 110609266748709,
	suv_deco_enginelower = 121429169742182, suv_deco_transaxle = 97838244924146,
	suv_deco_frontsubframe = 135170395985099, suv_deco_underbody = 104031513632788,
	suv_deco_rearaxle = 132108953968822, suv_hoodprop = 97671337736224,
	-- Ella's pumpkin coach v3.1 (10-23, art/3d/pumpkin_car/v3_1, art/3d/models.json): colour is in each GLB's own texture
	pumpkin_shell = 77360065376073, pumpkin_hood = 72099313383956, pumpkin_glass = 98871922967057, pumpkin_trim = 126567410884769,
	pumpkin_glow = 73511602109907, pumpkin_bumper_f = 105100460440511, pumpkin_bumper_r = 100388481529703, pumpkin_chassis = 87040139931809,
	pumpkin_hoodprop = 88676780253711, pumpkin_underbody = 73453532948026, pumpkin_rim = 86628525244245,
	-- Ella's big pumpkin (10-23, art/3d/ella_v1/big_pumpkin.glb: body + stem, pivot = the ball's centre (0, 3, 0))
	big_pumpkin = 72641857261945,
	-- fault looks (10-22, notes/gpt/main/fault_parts_main_decision.md)
	CoolantTank = 118772505684405, BrakeReservoir = 119991401837977, Wipers = 106211042682928,
	WasherNozzles = 98897410968126,
	WiperBlades_Worn = 82943648263505, -- v5 10-22: WiperBlade_Long_Worn / _Short_Worn, the wear is in the shape
	-- piece E, the engine bay taken apart (art/3d/engine_bay_v2, 60 nodes): main fills these in after the upload —
	-- until then the bay section below is skipped (the old Decor_EngineBay / EngineTop stay)
	-- (10-23 14:12 battery_posts_v1 r2: the battery's real lead posts + the bay's terminal clamps / covers — only the 3
	-- terminal nodes changed; was Battery 109905417501121 · bay 102372306804907 / 71319957740536)
	sedan_bay_v2 = 115063831625651 :: number?, -- sedan_bay_v2_Detail.glb (v2.3 + battery_posts_v1, 63 nodes)
	sedan_bay_v2_lite = 96264844788392 :: number?, -- sedan_bay_v2_Lite.glb
	-- the underside taken apart (art/3d/underbody_v1, 61 nodes, asset-qa PASS e=0): replaces Deco_Underbody /
	-- EngineLower / Transaxle while those lumps are live
	sedan_under_v1 = 71076737020034 :: number?, -- sedan_under_v1_Detail.glb
	sedan_under_v1_lite = 116199968342665 :: number?, -- sedan_under_v1_Lite.glb
	-- the corners taken apart (art/3d/suspension_v1, 78 nodes, piece E2): main fills these in after the upload — until
	-- then the section below is skipped (the old Deco_Hub / FrontSubframe / RearAxle stay)
	sedan_susp_v1 = nil :: number?, -- sedan_susp_v1_Detail.glb
	sedan_susp_v1_lite = nil :: number?, -- sedan_susp_v1_Lite.glb
	sedan_susp_v1_faults = nil :: number?, -- sedan_susp_v1_Faults_Detail.glb (Strut_FL_Leak, Shock_RL_Leak, Spring_RL_Broken …)
	sedan_susp_v1_faults_lite = nil :: number?, -- sedan_susp_v1_Faults_Lite.glb
	-- the bay's strut tower tops without the 3 top nuts + rubber cap (those are the strut's now): drawn instead of the
	-- bay's StrutTower_L / _R while Deco_Hub_F is live (suspension_v1/bay_patch) -> Decor_StrutTowerE2
	-- the body taken apart (main uploads; BODY3D below): shell panels / doors / trunk lid, glass, chassis, interior
	sedan_shell_v2 = nil :: number?,
	sedan_shell_v2_lite = nil :: number?,
	sedan_glass_v2 = nil :: number?,
	sedan_glass_v2_lite = nil :: number?,
	sedan_chassis_v2 = nil :: number?,
	sedan_chassis_v2_lite = nil :: number?,
	sedan_interior_v1b = nil :: number?,
	sedan_interior_v1b_lite = nil :: number?,
	sedan_strut_tower_l_e2 = nil :: number?, -- sedan_bay_v2_StrutTower_L_E2.glb
	sedan_strut_tower_r_e2 = nil :: number?, -- sedan_bay_v2_StrutTower_R_E2.glb
}
-- painted parts' SurfaceAppearance (art/roblox_assets.json): ColorMap = the _color_overlay map (AlphaMode Overlay:
-- the see-through parts show MeshPart.Color = the car's paint), RoughnessMap, no MetalnessMap
local PAINT_SA = {
	-- 10-23 front orange turn signal v2.1: sedan_shell / sedan_bumper_f(_dented) ColorMap = turn_signal_v1/v2_1/sedan overlays (RoughnessMap unchanged)
	sedan_shell = { 103809565683353, 106938012813926 },
	sedan_hood = { 89880414893069, 108583504054292 },
	-- 10-23 v3 side markers (orange, sedan bumper_f / suv_shell): decal 71645387866910 / 119023449641197 -> image ids below
	sedan_bumper_f = { 83183468282958, 131224329068457 },
	sedan_bumper_f_dented = { 83183468282958, 131224329068457 }, -- (same UV as Bumper_F)
	sedan_bumper_r = { 136672391046893, 127230809457395 },
	-- 10-23 front orange turn signal v2.2: suv_shell ColorMap = turn_signal_v1/v2_2/suv overlay (RoughnessMap unchanged)
	suv_shell = { 132520092925058, 98564205837311 },
	suv_hood = { 83140740427017, 131061681586438 },
	suv_bumper_f = { 99379880542620, 83142413661655 },
	suv_bumper_r = { 83862057090317, 80301268124237 },
}
-- the new engine bay's palette for its body-coloured nodes (art/3d/engine_bay_v2: bay_palette_color_overlay — only the
-- paint cell, row 3 col 8, see-through — and bay_palette_roughness; uploaded by main 10-22 19:08)
local BAY_PAINT = { 70814257258575, 114570604109893 }
-- template colours (each car sets its own): sedan_body_paint.json / suv_body_paint.json
local PAINT_DEFAULT = { sedan = Color3.fromHex("098FFC"), suv = Color3.fromHex("8FA283") }
local FLIP = CFrame.Angles(0, math.pi, 0)
local PAD = CFrame.new(0, 0, -0.5271) -- pad-set centre from the wheel centre (brake_attachments.json)

local cache: { [string]: { MeshPart } } = {}
-- the asset's MeshParts, turned back to GLB axes (CFrames relative to the GLB origin)
local function meshes(name: string): { MeshPart }
	if cache[name] then
		return cache[name]
	end
	local model = InsertService:LoadAsset(IDS[name])
	local out = {}
	for _, d in model:GetDescendants() do
		if d:IsA("MeshPart") then
			d.CFrame = FLIP * d.CFrame
			d.Anchored = true
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
			d.Massless = true
			local sa = PAINT_SA[name]
			if sa then
				for _, old in d:GetChildren() do
					if old:IsA("SurfaceAppearance") then
						old:Destroy()
					end
				end
				local s = Instance.new("SurfaceAppearance")
				s.AlphaMode = Enum.AlphaMode.Overlay
				s.ColorMap = "rbxassetid://" .. sa[1]
				s.RoughnessMap = "rbxassetid://" .. sa[2]
				s.Parent = d
				d.Color = PAINT_DEFAULT[name:match("^%a+")]
				-- (game scripts can't read SurfaceAppearance maps: the loading screen's list reads these — Shared/Preload)
				d:SetAttribute("PaintMaps", s.ColorMap .. "," .. s.RoughnessMap)
			end
			table.insert(out, d)
		end
	end
	cache[name] = out
	return out
end

local folder = ReplicatedStorage:FindFirstChild("CarMeshes")
if folder then
	folder:Destroy()
end
folder = Instance.new("Folder")
folder.Name = "CarMeshes"

-- a mesh's Size scaled by `s` given in GLB (car) axes, whichever way the MeshPart's own axes point
local function scaleBy(mp: MeshPart, s: Vector3)
	local function pick(v: Vector3): number
		local a = Vector3.new(math.abs(v.X), math.abs(v.Y), math.abs(v.Z))
		return if a.X >= a.Y and a.X >= a.Z then s.X elseif a.Y >= a.Z then s.Y else s.Z
	end
	local cf = mp.CFrame
	mp.Size *= Vector3.new(pick(cf.RightVector), pick(cf.UpVector), pick(cf.LookVector))
end

-- a template: Root at `pivot` (GLB coords), then each { asset, extra CFrame applied about the GLB origin, size scale? }
local function template(name: string, pivot: Vector3, parts: { { any } })
	local m = Instance.new("Model")
	m.Name = name
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(0.1, 0.1, 0.1)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.CFrame = CFrame.new(pivot)
	root.Parent = m
	m.PrimaryPart = root
	for _, p in parts do
		for _, mp in meshes(p[1]) do
			local c = mp:Clone()
			c.CFrame = (p[2] or CFrame.identity) * mp.CFrame
			if p[3] then
				scaleBy(c, p[3])
			end
			c.Name = p[1] .. "_" .. mp.Name
			c.Parent = m
		end
	end
	m.Parent = folder
	return m
end

-- an asset's meshes into a template made above (same space: GLB coords, the template's Root at its pivot), named as
-- in the GLB; `keep` picks some
local function add(m: Model, name: string, keep: ((MeshPart) -> boolean)?): { MeshPart }
	local list = {}
	for _, mp in meshes(name) do
		if keep == nil or keep(mp) then
			local c = mp:Clone()
			c.Parent = m
			table.insert(list, c)
		end
	end
	return list
end

local log = {}
local function try(name: string, f: () -> ())
	local ok, err = pcall(f)
	table.insert(log, name .. (if ok then " ok" else " FAIL " .. tostring(err)))
end

local O = Vector3.zero
try("Wheel", function() template("Wheel_Detail", O, { { "Rim" }, { "Tire" } }) end)
try("BrakePads", function() template("BrakePads_Detail", O, { { "BrakePads" } }) end)
try("BrakePads_L", function() template("BrakePads_L_Detail", O, { { "BrakePads_L" } }) end)
try("Battery", function() template("Battery_Detail", O, { { "Battery" } }) end)
try("Radiator", function() template("Radiator_Detail", O, { { "Radiator" } }) end)
try("Muffler", function() template("Muffler_Detail", O, { { "Muffler" } }) end)
try("Hood", function() template("Hood_Detail", Vector3.new(0, 4.15, -3.85), { { "sedan_hood" } }) end)
-- the washer nozzles sit on the hood (they open with it); NoPaint: the hood's paint doesn't colour them
try("Hood nozzles", function()
	for _, c in add(folder:FindFirstChild("Hood_Detail") :: Model, "WasherNozzles") do
		c:SetAttribute("NoPaint", true)
	end
end)
try("Bumper_F", function() template("Bumper_F_Detail", Vector3.new(0, 1.751, -8.0), { { "sedan_bumper_f" } }) end)
try("Bumper_R", function() template("Bumper_R_Detail", Vector3.new(0, 1.64, 8.2), { { "sedan_bumper_r" } }) end)
try("Hub", function() template("Hub_Detail", O, { { "Disc" }, { "Hub" }, { "CaliperBracket", PAD } }) end)
try("Hub_L", function() template("Hub_L_Detail", O, { { "Disc", FLIP }, { "Hub_L" }, { "CaliperBracket_L", PAD } }) end)
try("BrakeCaliper", function() template("BrakeCaliper_Detail", O, { { "Caliper" } }) end)
try("BrakeCaliper_L", function() template("BrakeCaliper_L_Detail", O, { { "Caliper_L" } }) end)
-- Lite: wheel = Rim_Lite + Tire_Lite; the brake is one piece (disc + caliper + bracket) on the hub; the caliper and
-- pads have nothing of their own in Lite (empty templates: the blocks hide, nothing doubles up)
try("Wheel_Lite", function() template("Wheel_Lite", O, { { "Rim_Lite" }, { "Tire_Lite" } }) end)
try("Hub_Lite", function() template("Hub_Lite", O, { { "Brake_Lite" } }) end)
try("Hub_L_Lite", function() template("Hub_L_Lite", O, { { "Brake_Lite_L" } }) end)
try("BrakeCaliper_Lite", function() template("BrakeCaliper_Lite", O, {}) end)
try("BrakeCaliper_L_Lite", function() template("BrakeCaliper_L_Lite", O, {}) end)
try("BrakePads_Lite", function() template("BrakePads_Lite", O, {}) end)
try("BrakePads_L_Lite", function() template("BrakePads_L_Lite", O, {}) end)
-- decor (car origin): shown by CarParts.DecorShow (hood open / lift up)
for _, n in { "EngineBay", "EngineTop", "EngineLower", "Transaxle", "FrontSubframe", "Underbody", "RearAxle" } do
	try("Decor_" .. n, function() template("Decor_" .. n, O, { { "sedan_deco_" .. n:lower() } }) end)
end
try("Decor_HoodProp", function() template("Decor_HoodProp", O, { { "sedan_hoodprop" } }) end) -- stowed; CarLook stands it up
-- fault looks: the tanks join the engine-bay decor (v2 has none), their liquids are a set of their own
try("Decor_EngineBay tanks", function()
	local bay = folder:FindFirstChild("Decor_EngineBay") :: Model
	local levels = template("Decor_Levels", O, {})
	for _, name in { "CoolantTank", "BrakeReservoir" } do
		for _, c in add(bay, name) do
			if c.Name:match("^Deco_Level_") then
				c.Parent = levels
				c.Color = Color3.fromHex(if c.Name:match("Coolant") then "E59AB8" else "E9C766") -- rose pink / new amber
				c.Material = Enum.Material.SmoothPlastic
			elseif c.Name:match("_Body$") then
				c.Transparency = 0.45 -- see-through: the liquid inside shows
			end
		end
	end
	assert(#levels:GetChildren() == 4, "expected 3 liquids, got " .. #levels:GetChildren() - 1)
end)
-- the wipers (always drawn): Rest = each mesh's car frame, CarLook turns arm + blade from there (Service position)
try("Decor_Wipers", function()
	local m = template("Decor_Wipers", O, {})
	for _, c in add(m, "Wipers") do
		c:SetAttribute("Rest", c.CFrame)
	end
	assert(#m:GetChildren() == 5, "Wipers: expected 4 meshes, got " .. #m:GetChildren() - 1)
end)
-- the cracked blades: whole MeshParts swapped in for the good ones (same frame), CarLook hides the good one
try("Decor_WiperBladesWorn", function()
	local m = template("Decor_WiperBladesWorn", O, {})
	for _, c in add(m, "WiperBlades_Worn") do
		c:SetAttribute("Rest", c.CFrame)
	end
	assert(m:FindFirstChild("WiperBlade_Long_Worn") and m:FindFirstChild("WiperBlade_Short_Worn"), "WiperBlades_Worn: names")
end)
-- wreck looks: a part's `Look` attribute picks <set>_<Look> (FaultService); the cracked lamp on wreck cars
try("Bumper_F_Dented", function() template("Bumper_F_Dented_Detail", Vector3.new(0, 1.751, -8.0), { { "sedan_bumper_f_dented" } }) end)
try("Wheel_Flat", function() template("Wheel_Flat_Detail", O, { { "Rim" }, { "Tire_Flat" } }) end)
try("Decor_HeadlightCrack", function() template("Decor_HeadlightCrack", O, { { "sedan_headlight_crack_L" } }) end)
try("Decor_Shell", function() template("Decor_Shell", O, { { "sedan_shell" } }) end)
try("Decor_Glass", function() template("Decor_Glass", O, { { "sedan_glass" } }) end)
try("Decor_Chassis", function() template("Decor_Chassis", O, { { "sedan_chassis" } }) end)
-- the SUV (Crossover_): body + decor in car coords, its hood / bumpers at their suv_spec pivots, a taller tire
for _, n in { "Shell", "Glass", "Chassis" } do
	try("Crossover_Decor_" .. n, function() template("Crossover_Decor_" .. n, O, { { "suv_" .. n:lower() } }) end)
end
for _, n in { "EngineBay", "EngineTop", "EngineLower", "Transaxle", "FrontSubframe", "Underbody", "RearAxle" } do
	try("Crossover_Decor_" .. n, function() template("Crossover_Decor_" .. n, O, { { "suv_deco_" .. n:lower() } }) end)
end
try("Crossover_Decor_HoodProp", function() template("Crossover_Decor_HoodProp", O, { { "suv_hoodprop" } }) end)
try("Crossover_Hood", function() template("Crossover_Hood_Detail", Vector3.new(0, 4.61, -4.1), { { "suv_hood" } }) end)
try("Crossover_Bumper_F", function() template("Crossover_Bumper_F_Detail", Vector3.new(0, 1.9, -7.8), { { "suv_bumper_f" } }) end)
try("Crossover_Bumper_R", function() template("Crossover_Bumper_R_Detail", Vector3.new(0, 2.0, 8.1), { { "suv_bumper_r" } }) end)
local TIRE = Vector3.new(1.15 / 1.03, 2.98 / 2.75, 2.98 / 2.75)
try("Crossover_Wheel", function() template("Crossover_Wheel_Detail", O, { { "Rim" }, { "Tire", nil, TIRE } }) end)
try("Crossover_Wheel_Lite", function() template("Crossover_Wheel_Lite", O, { { "Rim_Lite" }, { "Tire_Lite", nil, TIRE } }) end)
try("Crossover_Wheel_Flat", function() template("Crossover_Wheel_Flat_Detail", O, { { "Rim" }, { "Tire_Flat", nil, TIRE } }) end)
-- Ella's pumpkin coach (PumpkinCoach_, CarParts.Types.PumpkinCoach / PartData/Cars/PumpkinCoach; notes/handoff/pumpkin_bake_snippet.md):
-- body + decor in car coords; the front engine-bay decor of the SUV +2.30 back and its rear axle -2.30 forward (wheelbase 5.1), (0, -0.115, dz)
try("PumpkinCoach_Decor_Shell", function() template("PumpkinCoach_Decor_Shell", O, { { "pumpkin_shell" }, { "pumpkin_trim" }, { "pumpkin_glow" } }) end)
try("PumpkinCoach_Decor_Glass", function() template("PumpkinCoach_Decor_Glass", O, { { "pumpkin_glass" } }) end)
try("PumpkinCoach_Decor_Chassis", function() template("PumpkinCoach_Decor_Chassis", O, { { "pumpkin_chassis" } }) end)
try("PumpkinCoach_Decor_Underbody", function() template("PumpkinCoach_Decor_Underbody", O, { { "pumpkin_underbody" } }) end)
try("PumpkinCoach_Decor_HoodProp", function() template("PumpkinCoach_Decor_HoodProp", O, { { "pumpkin_hoodprop" } }) end)
for _, n in { "EngineBay", "EngineTop", "EngineLower", "Transaxle", "FrontSubframe" } do
	try("PumpkinCoach_Decor_" .. n, function() template("PumpkinCoach_Decor_" .. n, O, { { "suv_deco_" .. n:lower(), CFrame.new(0, -0.115, 2.30) } }) end)
end
try("PumpkinCoach_Decor_RearAxle", function() template("PumpkinCoach_Decor_RearAxle", O, { { "suv_deco_rearaxle", CFrame.new(0, -0.115, -2.30) } }) end)
try("PumpkinCoach_Hood", function() template("PumpkinCoach_Hood_Detail", Vector3.new(0, 5.035, -2.68), { { "pumpkin_hood" } }) end)
try("PumpkinCoach_Bumper_F", function() template("PumpkinCoach_Bumper_F_Detail", Vector3.new(0, 1.45, -5.10), { { "pumpkin_bumper_f" } }) end)
try("PumpkinCoach_Bumper_R", function() template("PumpkinCoach_Bumper_R_Detail", Vector3.new(0, 1.42, 5.20), { { "pumpkin_bumper_r" } }) end)
try("PumpkinCoach_Wheel", function() template("PumpkinCoach_Wheel_Detail", O, { { "pumpkin_rim" }, { "Tire" } }) end)
try("PumpkinCoach_Wheel_Lite", function() template("PumpkinCoach_Wheel_Lite", O, { { "pumpkin_rim" }, { "Tire_Lite" } }) end)
try("PumpkinCoach_Wheel_Flat", function() template("PumpkinCoach_Wheel_Flat_Detail", O, { { "pumpkin_rim" }, { "Tire_Flat" } }) end)
for _, t in { "Wrench", "ImpactWrench", "OBDScanner", "FusePuller", "PlugSocket", "TrimTool", "HosePliers", "DrainPan" } do
	try("Tool_" .. t, function()
		local list = meshes(t)
		assert(#list == 1, t .. ": expected one MeshPart, got " .. #list)
		local c = list[1]:Clone()
		c.Name = "Tool_" .. t
		c.CFrame = CFrame.new(c.Position) * (c.CFrame - c.Position) -- keep the turned-back orientation
		c.Parent = folder
	end)
end
-- the pliers' two arms (art/3d/tools_v2/*_attachments.json Squeeze): Tool_<Name>_Rig = Model, MeshParts ArmA / ArmB in GLB
-- axes, each with attribute Rest = its rest CFrame (arm CFrame = pivot * rotate * pivot:Inverse() * Rest, convert with meshLocal)
for _, t in { "FusePuller", "HosePliers" } do
	try("Tool_" .. t .. "_Rig", function()
		local m = Instance.new("Model")
		m.Name = "Tool_" .. t .. "_Rig"
		for _, mp in meshes(t .. "_Rig") do
			local c = mp:Clone()
			c.Name = c.Name:gsub("^" .. t .. "_", "")
			c:SetAttribute("Rest", c.CFrame)
			c.Parent = m
		end
		assert(#m:GetChildren() == 2, t .. "_Rig: expected 2 arm meshes, got " .. #m:GetChildren())
		m.WorldPivot = CFrame.identity
		m.Parent = folder
	end)
end
-- Gear_BigPumpkin (HalloweenService: the pumpkin the coach pops into, rolled down the road): Root = the ball's centre
try("Gear_BigPumpkin", function() template("Gear_BigPumpkin", Vector3.new(0, 3, 0), { { "big_pumpkin" } }) end)
try("Gear_FloorJack", function()
	local m = Instance.new("Model")
	m.Name = "Gear_FloorJack"
	for _, mp in meshes("FloorJack") do
		local c = mp:Clone()
		c.Name = c.Name:gsub("^FloorJack_", "")
		c:SetAttribute("Rest", c.CFrame)
		c.Parent = m
	end
	assert(#m:GetChildren() == 4, "FloorJack: expected 4 meshes, got " .. #m:GetChildren())
	m.WorldPivot = CFrame.identity
	m.Parent = folder
end)
-- piece E: the new sedan bay (data = Shared/PartData/Generated/SedanBay, rows = PartData/Cars/Sedan bayIds; contract
-- board 10-22 wr-dev E line). Each part row's node -> <id>_Detail / <id>_Lite (Root = its pivot); the fixed nodes ->
-- Decor_EngineBayV2 / Decor_EngineTopV2 (car origin), the ones shown from below too (show = both) -> Decor_EngineBayV2Under,
-- the on-hood ones (insulation, inner ribs) -> into Hood_Detail; the coolant tank's body rides in CoolantReservoir_Detail
-- (the old decor's tank copy stays for cars whose bay isn't live). A node is matched by its GLB name.
if IDS.sedan_bay_v2 then
	local Shared = ReplicatedStorage:WaitForChild("Shared")
	-- (a fresh copy: Studio's Edit keeps the first require of a module even after a sync changed its Source — once
	-- that baked the old 3D data. SedanBay requires nothing, so a parent-less clone works)
	local gen = (require(Shared.PartData.Generated.SedanBay:Clone()) :: any).parts
	local rows = (require(Shared.PartData.Cars.Sedan) :: any).bayIds
	-- (v2.2: the nodes another part's way out turns aside first — the battery's short leads — are pieces of their own
	-- too, so CarLook can turn them: <id>_Detail like a part row)
	local own = table.clone(rows)
	for _, p in gen do
		for _, a in p.aside or {} do
			own[a.node] = true
			for _, w in a.with or {} do
				own[w] = true
			end
		end
	end
	-- (a node whose mesh is shared — the 4 coils, the 4 plugs — imports as a Model named after the node holding a
	-- MeshPart named after the mesh: SparkPlug_4 > SparkPlug_1; the first one's Model gets a made-up name
	-- (SparkPlug_12_Node), so its MeshPart's own name is the node)
	local function nodeOf(mp: MeshPart): string
		local p = mp.Parent
		if p and p:IsA("Model") then
			local n = (p.Name:gsub("_Lite$", ""):gsub("_Node$", ""))
			if gen[n] then
				return p.Name:gsub("_Node$", "")
			end
		end
		return mp.Name
	end
	local function byNode(asset: string): { [string]: { MeshPart } }
		local out = {}
		for _, mp in meshes(asset) do
			local n = nodeOf(mp):gsub("_Lite$", "")
			out[n] = out[n] or {}
			table.insert(out[n], mp)
		end
		return out
	end
	try("Bay v2", function()
		local detail = byNode("sedan_bay_v2")
		local lite = if IDS.sedan_bay_v2_lite then byNode("sedan_bay_v2_lite") else {}
		local decor = { Deco_EngineBay = template("Decor_EngineBayV2", O, {}), Deco_EngineTop = template("Decor_EngineTopV2", O, {}) }
		local under = template("Decor_EngineBayV2Under", O, {})
		local hood = folder:FindFirstChild("Hood_Detail") :: Model
		local missing = {}
		for id, p in gen do
			local got = detail[id]
			if not got then
				table.insert(missing, id)
				continue
			end
			local function into(m: Model, list: { MeshPart })
				for _, mp in list do
					local c = mp:Clone()
					c.Name = id .. (if #list > 1 then "_" .. mp.Name else "")
					c.Parent = m
				end
			end
			if own[id] then
				local d = template(id .. "_Detail", p.pivot, {})
				into(d, got)
				if lite[id] then
					into(template(id .. "_Lite", p.pivot, {}), lite[id])
				end
				if id == "CoolantReservoir" then
					for _, c in add(d, "CoolantTank") do
						if c.Name:match("^Deco_Level_") then
							c:Destroy() -- (the liquid stays CarLook's: Decor_Levels)
						elseif c.Name:match("_Body$") then
							c.Transparency = 0.45
						end
					end
				end
			elseif p.onHood then
				into(hood, got)
			elseif p.show == "both" then
				into(under, got)
			else
				into(decor[p.lump] or decor.Deco_EngineBay, got)
			end
		end
		add(decor.Deco_EngineBay, "BrakeReservoir", function(mp)
			return not mp.Name:match("^Deco_Level_")
		end)
		-- the body-coloured nodes (paint = true: the strut tower tops — the body's own metal): the bay palette's overlay,
		-- its one paint cell see-through, so MeshPart.Color = the car's paint shows there (CarLook paints CarPaint parts)
		for id, p in gen do
			if p.paint then
				for _, m in decor do
					for _, mp in m:GetDescendants() do
						if mp:IsA("MeshPart") and (mp.Name == id or mp.Name:sub(1, #id + 1) == id .. "_") then
							for _, old in mp:GetChildren() do
								if old:IsA("SurfaceAppearance") then
									old:Destroy()
								end
							end
							local s = Instance.new("SurfaceAppearance")
							s.AlphaMode = Enum.AlphaMode.Overlay
							s.ColorMap = "rbxassetid://" .. BAY_PAINT[1]
							s.RoughnessMap = "rbxassetid://" .. BAY_PAINT[2]
							s.Parent = mp
							mp.Color = PAINT_DEFAULT.sedan
							mp:SetAttribute("CarPaint", true)
							mp:SetAttribute("PaintMaps", s.ColorMap .. "," .. s.RoughnessMap)
						end
					end
				end
			end
		end
		assert(#missing == 0, "bay v2: no GLB node for " .. table.concat(missing, ", "))
	end)
end
-- the underside (data = Shared/PartData/Generated/SedanUnder, underbody_v1): no part rows yet (oil change, belt, covers =
-- the week-2 rows) — every node fixed: Decor_<lump>V2 (seen from below) / Decor_<lump>V2Both (show = both: seen with the
-- hood open too — the block, the oil pan, the alternator). The muffler (+ its gasket) is the Muffler slot's look while
-- Deco_Underbody is live: Muffler_UB_Detail / _Lite, Root = its pivot (CarParts.Swap3D, CarLook)
if IDS.sedan_under_v1 then
	local Shared = ReplicatedStorage:WaitForChild("Shared")
	local gen = (require(Shared.PartData.Generated.SedanUnder:Clone()) :: any).parts
	local swap = { Muffler = "Muffler_UB", ExhaustGasket_Muffler = "Muffler_UB" }
	-- (the under covers' rows, Cars/SedanCovers: their own <id>_Detail / _Lite too — fresh data, like the oil's)
	local COVERS: { [string]: boolean } = {}
	local fresh = Shared.PartData.Cars.SedanCovers:Clone() -- (it reads Generated/SedanUnder: a clone beside it)
	fresh.Name = "_SedanCoversFresh"
	fresh.Parent = Shared.PartData.Cars
	for _, r in (require(fresh) :: any).rows do
		COVERS[r.id] = true
	end
	fresh:Destroy()
	-- (the oil change's part rows, Cars/SedanOil = the nodes the 3D marks batch "OIL": each its own <id>_Detail / _Lite,
	-- Root = its pivot, like the bay's rows. Read from the fresh data, not from Cars/Sedan: Studio's Edit keeps a module's
	-- first require, so a bake after a sync saw the old rows)
	local function byNode(asset: string): { [string]: { MeshPart } }
		local out = {}
		for _, mp in meshes(asset) do
			-- (a node whose mesh is shared — the two wheel-opening pads, the floor covers — imports as a Model named after
			-- the node: the same rule as the bay's nodeOf)
			local p = mp.Parent
			local n = mp.Name
			if p and p:IsA("Model") and gen[(p.Name:gsub("_Lite$", ""):gsub("_Node$", ""))] then
				n = p.Name:gsub("_Node$", "")
			end
			n = n:gsub("_Lite$", "")
			out[n] = out[n] or {}
			table.insert(out[n], mp)
		end
		return out
	end
	try("Under v1", function()
		local detail = byNode("sedan_under_v1")
		local lite = if IDS.sedan_under_v1_lite then byNode("sedan_under_v1_lite") else {}
		local decor: { [string]: Model } = {}
		local missing = {}
		local function into(m: Model, id: string, list: { MeshPart })
			for _, mp in list do
				local c = mp:Clone()
				c.Name = id .. (if #list > 1 then "_" .. mp.Name else "")
				c.Parent = m
			end
		end
		local muffler = gen.Muffler
		local own = { Detail = template("Muffler_UB_Detail", muffler.pivot, {}), Lite = template("Muffler_UB_Lite", muffler.pivot, {}) }
		for id, p in gen do
			local got = detail[id]
			if not got then
				table.insert(missing, id)
				continue
			end
			if swap[id] then
				into(own.Detail, id, got)
				into(own.Lite, id, lite[id] or got)
			elseif (p.batch == "OIL" or COVERS[id]) and p.role == "part" then
				into(template(id .. "_Detail", p.pivot, {}), id, got)
				into(template(id .. "_Lite", p.pivot, {}), id, lite[id] or got)
			else
				-- (seen from above they sit deep under the bay's parts: the Lite meshes there — measured 10-22, the
				-- engine view with the hood open is the heavy one; from below, on the creeper, the Detail)
				local both = p.show == "both"
				local name = "Decor_" .. p.lump:gsub("^Decor?_", "") .. "V2" .. (if both then "Both" else "")
				decor[name] = decor[name] or template(name, O, {})
				into(decor[name], id, if both then lite[id] or got else got)
			end
		end
		assert(#missing == 0, "under v1: no GLB node for " .. table.concat(missing, ", "))
	end)
end
-- the corners (data = Shared/PartData/Generated/SedanSusp, suspension_v1): each part row's node -> <id>_Detail / _Lite
-- (Root = its pivot; the right side its own mirrored mesh), each fault look -> <id>_Detail / _Lite too (CarLook
-- <set>_<Look>: Strut_FL_Leak), the fixed nodes -> Decor_Hub_FV2 / Decor_Hub_RV2 (car origin, always drawn while that
-- lump is live — CarLook, PartGraph.lumpLive)
if IDS.sedan_susp_v1 then
	local Shared = ReplicatedStorage:WaitForChild("Shared")
	local gen = (require(Shared.PartData.Generated.SedanSusp:Clone()) :: any).parts
	local function byNode(asset: string): { [string]: { MeshPart } }
		local out = {}
		for _, mp in meshes(asset) do
			local p = mp.Parent
			local n = mp.Name
			if p and p:IsA("Model") and gen[(p.Name:gsub("_Lite$", ""):gsub("_Node$", ""))] then
				n = p.Name:gsub("_Node$", "")
			end
			n = n:gsub("_Lite$", "")
			out[n] = out[n] or {}
			table.insert(out[n], mp)
		end
		return out
	end
	try("Susp v1", function()
		local detail = byNode("sedan_susp_v1")
		local lite = if IDS.sedan_susp_v1_lite then byNode("sedan_susp_v1_lite") else {}
		local faults = if IDS.sedan_susp_v1_faults then byNode("sedan_susp_v1_faults") else {}
		local faultsLite = if IDS.sedan_susp_v1_faults_lite then byNode("sedan_susp_v1_faults_lite") else {}
		local decor: { [string]: Model } = {}
		local missing = {}
		local function into(m: Model, id: string, list: { MeshPart })
			for _, mp in list do
				local c = mp:Clone()
				c.Name = id .. (if #list > 1 then "_" .. mp.Name else "")
				c.Parent = m
			end
		end
		for id, p in gen do
			local variant = p.role == "fault_variant"
			local got = if variant then faults[id] else detail[id]
			if not got then
				table.insert(missing, id)
				continue
			end
			if p.role == "part" or variant then
				into(template(id .. "_Detail", p.pivot, {}), id, got)
				local l = if variant then faultsLite[id] else lite[id]
				if l then
					into(template(id .. "_Lite", p.pivot, {}), id, l)
				end
			else
				local name = "Decor_" .. p.lump:gsub("^Decor?_", "") .. "V2"
				decor[name] = decor[name] or template(name, O, {})
				into(decor[name], id, got)
			end
		end
		assert(#missing == 0, "susp v1: no GLB node for " .. table.concat(missing, ", "))
	end)
end
-- the body taken apart (Features.NewBody, main lumps 10-23): each set's nodes -> Decor_<key>V2 (car origin, always drawn
-- while its lump is live; key = the lump without Deco_ / Decor_: Decor_Chassis -> Decor_ChassisV2). Data =
-- Generated/<set> (gen_partdata, wr-dev2), meshes = the uploads below — a set is skipped until both are there. (The
-- doors / trunk lid that open, and the shell's paint patterns, come with their own step.)
local BODY3D = {
	{ set = "SedanShell", detail = "sedan_shell_v2", lite = "sedan_shell_v2_lite" },
	{ set = "SedanGlass", detail = "sedan_glass_v2", lite = "sedan_glass_v2_lite" },
	{ set = "SedanChassis", detail = "sedan_chassis_v2", lite = "sedan_chassis_v2_lite" },
	{ set = "SedanInterior", detail = "sedan_interior_v1b", lite = "sedan_interior_v1b_lite" },
}
for _, b in BODY3D do
	local Shared = ReplicatedStorage:WaitForChild("Shared")
	local mod = Shared.PartData.Generated:FindFirstChild(b.set)
	if not ((IDS :: any)[b.detail] and mod) then
		continue
	end
	try(b.set, function()
		local gen = (require(mod:Clone()) :: any).parts
		local got: { [string]: { MeshPart } } = {}
		for _, mp in meshes(b.detail) do
			local p = mp.Parent
			local n = if p and p:IsA("Model") and gen[(p.Name:gsub("_Node$", ""))] then p.Name:gsub("_Node$", "") else mp.Name
			got[n] = got[n] or {}
			table.insert(got[n], mp)
		end
		local decor: { [string]: Model } = {}
		local missing = {}
		for id, p in gen do
			local list = got[id]
			if not list then
				table.insert(missing, id)
				continue
			end
			local name = "Decor_" .. (p.lump:gsub("^Decor?_", ""):gsub("%W.*$", "")) .. "V2"
			decor[name] = decor[name] or template(name, O, {})
			for _, mp in list do
				local c = mp:Clone()
				c.Name = id .. (if #list > 1 then "_" .. mp.Name else "")
				c.Parent = decor[name]
			end
		end
		assert(#missing == 0, b.set .. ": no GLB node for " .. table.concat(missing, ", "))
	end)
end
-- (the strut tower tops for E2: the body's own metal — painted like the bay's, BAY_PAINT overlay + CarPaint)
if IDS.sedan_strut_tower_l_e2 and IDS.sedan_strut_tower_r_e2 then
	try("Strut towers E2", function()
		local m = template("Decor_StrutTowerE2", O, {})
		for _, asset in { "sedan_strut_tower_l_e2", "sedan_strut_tower_r_e2" } do
			for _, mp in meshes(asset) do
				local c = mp:Clone()
				for _, old in c:GetChildren() do
					if old:IsA("SurfaceAppearance") then
						old:Destroy()
					end
				end
				local s = Instance.new("SurfaceAppearance")
				s.AlphaMode = Enum.AlphaMode.Overlay
				s.ColorMap = "rbxassetid://" .. BAY_PAINT[1]
				s.RoughnessMap = "rbxassetid://" .. BAY_PAINT[2]
				s.Parent = c
				c.Color = PAINT_DEFAULT.sedan
				c:SetAttribute("CarPaint", true)
				c:SetAttribute("PaintMaps", s.ColorMap .. "," .. s.RoughnessMap)
				c.Parent = m
			end
		end
	end)
end
folder.Parent = ReplicatedStorage
return table.concat(log, "\n")
