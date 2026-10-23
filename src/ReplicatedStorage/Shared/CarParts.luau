-- The car's parts, following docs/specs/car_spec.md v0.3 (wr-design): names, pivots, sizes, bolt counts, Requires,
-- CarryMode. Block stand-ins now; wr-3d meshes later keep the same names / attachments (Snap_<Slot>, Bolt_N, Hinge).
-- Prototype = the 12 repair parts of car_spec 4-1 (Hood, Bumper_F/R, Battery, Wheel x4, BrakePads x4)
-- + Radiator and Muffler from 4-2 early, so smoke / steam / a puddle / a rattle have a part to come from.
-- The parts themselves (which ones, where, what comes off first, which zone) are data: Shared/PartData (kinds, and one
-- file per car type), read through Shared/PartGraph — Slots / WheelCenters / zoneOf / endOf below come from there.
--
-- Car space (car_spec 0): pivot = ground between the axles, -Z = front, +Y = up, +X = the car's right. Studs.

local PartGraph = require(script.Parent.PartGraph)
local Car3D = require(script.Parent.PartData:WaitForChild("Car3D"))

export type Kind = {
	massKg: number,
	price: number,
	bolts: number,
	carry: "OneHand" | "TwoHand" | "Roll" | "Crane",
	tool: "Hand" | "Wrench" | "Lug",
	group: "Body" | "MechanicalParts",
}

export type Slot = {
	kind: string,
	pivot: Vector3, -- where the part's SnapAttachment sits on the car (car_spec 4-1)
	requires: { string }?, -- "Hood:Open" | "Lift:Wheel" | "Lift:Under" | another slot that must be off first
	faultable: boolean?,
	detach: "Drop" | "Pop", -- when the last bolt comes out: fall to the floor, or pop out and stay
	turned: boolean?,
	yaw: number?, -- degrees about Y for the snap (car_spec v0.8: the battery's long side runs front-back) -- right-side copy of a left-side part: the same model turned 180° about Y (car_spec 0)
}

local CarParts = {}

CarParts.Scale = 1 -- car_spec 1: everything can shrink to 0.9 later with one number (not wired yet)

CarParts.Kinds = require(script.Parent.PartData.Kinds) :: { [string]: Kind }

-- the sedan's slots (PartData/Cars/Sedan); other types: CarParts.type(name).Slots
local slots: { [string]: Slot } = PartGraph.slots("Sedan") :: any

CarParts.WheelCenters = (PartGraph.car("Sedan") :: PartGraph.Car).wheels
-- the pad set's place from the wheel centre (the BrakePads row's `at`; x = inward on the left side)
CarParts.PadOffset = (PartGraph.part("Sedan", "BrakePads_FL") :: PartGraph.Part).at :: Vector3

CarParts.Slots = slots

CarParts.SlotOrder = {}
for name in slots do
	table.insert(CarParts.SlotOrder, name)
end
table.sort(CarParts.SlotOrder)

-- 3D meshes in two weights (notes/gpt/main/wheel_brake_3d_main_decision.md, 10-21 morning fix): a car in a bay
-- (attribute Detail) shows every corner in Detail; every other car / loose part is Detail within LodNear studs of
-- the player's camera, Lite beyond — swapped on each player's own screen (ClientModules/CarLook), one server model.
-- Templates: ReplicatedStorage.CarMeshes.<set>_Detail / <set>_Lite — a Model whose PrimaryPart's CFrame = the part's
-- SnapAttachment (car_spec pivot); its MeshParts are welded onto the part locally, the block stand-ins hide (bolt
-- heads stay). No template = the blocks stay (today). <set> per kind below; "Hub" / "BrakeCaliper" are the car's
-- Decor / Moving pieces.
CarParts.MeshSets = {
	Wheel = "Wheel",
	BrakePads = "BrakePads",
	BrakeCaliper = "BrakeCaliper", -- Moving/BrakeCaliper_XX
	Hub = "Hub", -- Decor/Deco_Hub_XX: disc + hub + caliper bracket at the wheel centre
	Battery = "Battery",
	Radiator = "Radiator",
	Muffler = "Muffler",
	Hood = "Hood",
	Bumper = "Bumper", -- (CarLook picks Bumper_F / Bumper_R by the slot)
}
-- piece E: each new part's template is its own id (<id>_Detail / _Lite — the GLB node names, one per coil / plug);
-- "@slot" = the piece's Slot, or the first slot of its kind for a new one from the counter (CarParts.FirstSlot)
CarParts.FirstSlot = {} :: { [string]: string }
CarParts.Bay = (require(script.Parent.PartData:WaitForChild("Sedan3D")) :: any) -- (the bay + the underside)
-- an old part row whose look comes from the new 3D while that lump is live on the car's type (same pivot, same
-- bolts — underbody_v1 built the muffler on the old row's places): slot -> { lump, set } (bake: <set>_Detail / _Lite)
CarParts.Swap3D = {
	Muffler = { lump = "Deco_Underbody", set = "Muffler_UB" },
} :: { [string]: { lump: string, set: string } }
-- the ids that are part rows (PartData/Cars/Sedan bayIds — the later ones too): a car without that slot live draws
-- them fixed, from their own <id>_Detail (so the bay's fixed decor must not hold them)
CarParts.BayRows = (require(script.Parent.PartData:WaitForChild("Cars"):WaitForChild("Sedan")) :: any).bayIds :: { [string]: boolean }
for id, p in CarParts.Bay.parts do
	if CarParts.BayRows[id] then
		CarParts.MeshSets[p.kind] = "@slot"
		if not CarParts.FirstSlot[p.kind] or id < CarParts.FirstSlot[p.kind] then
			CarParts.FirstSlot[p.kind] = id
		end
	end
end
-- (piece E2: each corner part wears its own node too — Strut_FL_Detail, the right side its own mirrored mesh)
for id, p in Car3D.susp("Sedan").parts do
	if p.role == "part" then
		CarParts.MeshSets[p.kind] = "@slot"
		if not CarParts.FirstSlot[p.kind] or id < CarParts.FirstSlot[p.kind] then
			CarParts.FirstSlot[p.kind] = id
		end
	end
end

-- When each decor piece is drawn (main 10-21: a bay car must fit 70k triangles) — on each player's screen
-- (ClientModules/CarLook). "hood" = the hood is open, "lift" = the lift is at Wheel or higher, "both" = either one
-- (the oil pan and the gearbox show from above and from below). Anything not listed is always drawn.
-- 3D: ReplicatedStorage.CarMeshes.Decor_<Name> (a Model whose PrimaryPart CFrame = the car's pivot, car_spec
-- coordinates) replaces the block Deco_<Name> on every car; no template = the block stays.
CarParts.DecorShow = {
	Deco_EngineTop = "hood",
	Deco_EngineBay = "hood",
	Deco_BatteryStand = "hood",
	Deco_HoodProp = "hood",
	Deco_EngineLower = "both",
	Deco_Transaxle = "both",
	Deco_FrontSubframe = "lift",
	Deco_Underbody = "lift",
	Deco_RearAxle = "lift",
}
-- the body's lumps (Features.NewBody, main lumps 10-23) -> what of the old body each replaces on the car (CarLook hides
-- them while that lump is live; its new pieces are Decor_<key>V2)
CarParts.BodyLumps = {
	Decor_Shell = { "Mesh_Body_Shell" },
	Decor_Glass = { "Mesh_Body_Glass" },
	Decor_Chassis = { "Mesh_Body_Chassis" },
	Deco_Interior = { "Deco_Interior", "Mesh_Deco_Interior" },
	Deco_Dash = { "Deco_Dash", "Mesh_Deco_Dash" },
} :: { [string]: { string } }
-- a decor block that another lump's new 3D draws itself: hidden while that lump is live (the battery tray is in
-- Decor_EngineBayV2 — main lumps_inventory_1023)
CarParts.DecorInLump = { Deco_BatteryStand = "Deco_EngineBay" } :: { [string]: string }

-- the hood opens to where the 3D prop rod holds it (art/3d hood_prop_attachments.json: 57.8°; car_spec said 70°, a
-- 70° rod would not fit stowed). The rod stands up about its hinge when the hood is open (CarLook).
CarParts.HoodOpenDeg = 57.8
CarParts.HoodProp = { hinge = Vector3.new(2.12, 3.1, -7.91), axis = Vector3.new(0, 0.3127, -0.9499), deg = 86.88 }

-- Lift heights (car_spec 3-3): how far the car's pivot goes up
CarParts.LiftLevels = { { name = "Ground", y = 0 }, { name = "Wheel", y = 1.8 }, { name = "Under", y = 6.0 } }

-------------------------------------------------------------------------------------------------------------------
-- Block stand-in geometry (goes away when the meshes come). Each piece: size, offset from the part's pivot, colour.
-- `shape` Cylinder runs along X. Bolts: offset from pivot + outward direction (= the Bolt_N attachment's +X axis).
-------------------------------------------------------------------------------------------------------------------

local PAINT = Color3.fromHex("098FFC") -- the sedan's default paint (sedan_body_paint.json); each car picks its own (Config.PaintColors)
local DARK = Color3.fromRGB(46, 47, 52)
local METAL = Color3.fromRGB(160, 162, 168)

export type Piece = { name: string, size: Vector3, offset: Vector3, color: Color3, material: Enum.Material?, shape: string?, turn: boolean? } -- turn: a cylinder that runs front-back
-- f = what kind of fastener it is (Shared/PartData/Fasteners; nil = "Bolt") — the tool it needs (Features.ToolMatch)
export type Bolt = { offset: Vector3, out: Vector3, requires: { string }? , loosenAfter: string?, tightenAfter: string?, f: string? }

local L, R, U, D, F, B = Vector3.new(-1, 0, 0), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, -1, 0), Vector3.new(0, 0, -1), Vector3.new(0, 0, 1)

-- per kind: the blocks (first one = the root part) and the bolts, in the part's own space with the part sitting on
-- a LEFT-side slot where it matters (wheels / pads); right-side parts are the same model turned 180° (car_spec 0)
CarParts.Blocks = {
	Hood = {
		pieces = { { name = "Hood", size = Vector3.new(6.4, 0.3, 4.1), offset = Vector3.new(0, -0.2, -2.2), color = PAINT } },
		-- hinge bolts under the hood (hood_attachments.json, from the hinge)
		bolts = { { offset = Vector3.new(-2.75, -0.194, -0.3), out = D }, { offset = Vector3.new(-2.75, -0.201, -0.55), out = D }, { offset = Vector3.new(2.75, -0.193, -0.3), out = D }, { offset = Vector3.new(2.75, -0.201, -0.55), out = D } },
		hinge = true,
	},
	Bumper = {
		pieces = { { name = "Bumper", size = Vector3.new(7.4, 2.0, 1.2), offset = Vector3.new(0, 0, 0.6), color = Color3.fromRGB(62, 62, 66) } },
		-- top 2 need the hood open, bottom 2 need the lift at Wheel (car_spec 4-1 #2); places = bumper_f_attachments.json
		bolts = {
			{ offset = Vector3.new(-2.2, 1.014, 0.45), out = U, requires = { "Hood:Open" } },
			{ offset = Vector3.new(2.2, 1.014, 0.45), out = U, requires = { "Hood:Open" } },
			{ offset = Vector3.new(-2.4, -1.035, 0.4), out = D, requires = { "Lift:Wheel" } },
			{ offset = Vector3.new(2.4, -1.035, 0.4), out = D, requires = { "Lift:Wheel" } },
		},
	},
	Battery = {
		pieces = {
			{ name = "Battery", size = Vector3.new(0.95, 0.75, 0.7), offset = Vector3.new(0, 0.375, 0), color = Color3.fromRGB(36, 36, 40) },
			{ name = "Label", size = Vector3.new(0.97, 0.3, 0.72), offset = Vector3.new(0, 0.45, 0), color = Color3.fromRGB(240, 190, 40) },
		},
		-- (-) first off, (+) first on (car_spec 4-1 #1): a wrong order sparks, no penalty.
		-- Terminals on the part's front long edge, + at its -X end; the slot turns it -90° (v0.8) so in the car the
		-- terminals face the engine (+X), + at the front: + ~(-1.95, 3.1, -6.0), - ~(-1.95, 3.1, -5.4); the clamp
		-- bolt sits on the floor ledge on that side ~(-1.8, 2.4, -5.7)
		bolts = {
			-- (the terminals' pinch nuts beside the posts, done up across — battery_posts_v1 §4: a real clamp's 10 mm nut)
			{ offset = Vector3.new(0.416, 0.687, -0.0705), out = R, tightenAfter = "Bolt_2", f = "Terminal" }, -- (-) terminal
			{ offset = Vector3.new(-0.324, 0.687, -0.0665), out = R, loosenAfter = "Bolt_1", f = "Terminal" }, -- (+) terminal
			{ offset = Vector3.new(0, 0.069, -0.4), out = U }, -- hold-down clamp (bottom ledge)
		},
	},
	Wheel = {
		pieces = {
			{ name = "Rim", size = Vector3.new(1.08, 1.78, 1.78), offset = Vector3.zero, color = METAL, material = Enum.Material.Metal, shape = "Cylinder" },
			{ name = "Tire", size = Vector3.new(1.03, 2.75, 2.75), offset = Vector3.zero, color = Color3.fromRGB(30, 30, 32), material = Enum.Material.Rubber, shape = "Cylinder" },
		},
		-- 5 lug nuts on the outer hub face, radius 0.275 (car_spec v0.7), from 12 o'clock every 72° (car_spec v0.3 4-1;
		-- star order 1→3→5→2→4 is the real way, not forced). Left wheel: outer = -X
		bolts = (function()
			local t = {}
			for i = 1, 5 do
				local a = math.rad((i - 1) * 72)
				t[i] = { offset = Vector3.new(-0.3208, math.cos(a) * 0.275, math.sin(a) * 0.275), out = L, f = "LugNut" } -- nut seats on the hub face (wheel_attachments.json)
			end
			return t
		end)(),
	},
	BrakePads = {
		-- long side up (car_spec v0.7: 0.29 x 0.69 x 0.23); the caliper's top / bottom bolts
		pieces = { { name = "BrakePads", size = Vector3.new(0.29, 0.69, 0.23), offset = Vector3.zero, color = Color3.fromRGB(200, 130, 50) } },
		-- the slide-pin bolts on the piston side, coming out toward the car (brake_attachments.json; z between the
		-- left / right mirror places)
		bolts = { { offset = Vector3.new(0.2922, 0.4103, 0), out = R }, { offset = Vector3.new(0.2922, -0.4103, 0), out = R } },
	},
	Radiator = {
		pieces = { { name = "Radiator", size = Vector3.new(3.6, 1.9, 0.6), offset = Vector3.zero, color = Color3.fromRGB(120, 125, 132), material = Enum.Material.DiamondPlate } },
		bolts = { { offset = Vector3.new(0.92, 0.88, -0.23), out = F }, { offset = Vector3.new(-0.92, 0.88, -0.23), out = F } }, -- upper brackets
	},
	Muffler = {
		pieces = {
			-- a cross-wise can under the rear bumper with its tail pipe (car_spec v0.3 #14)
			{ name = "Muffler", size = Vector3.new(2.6, 0.6, 1.0), offset = Vector3.zero, color = DARK, material = Enum.Material.Metal },
			{ name = "Tip", size = Vector3.new(0.9, 0.3, 0.3), offset = Vector3.new(0.9, -0.05, 0.75), color = METAL, material = Enum.Material.Metal, shape = "Cylinder", turn = true },
		},
		-- the front joint flange's 2 bolts, reached from under the car
		bolts = { { offset = Vector3.new(1.145, 0, -0.525), out = F }, { offset = Vector3.new(0.765, 0, -0.525), out = F } }, -- inlet flange
	},
} :: { [string]: { pieces: { Piece }, bolts: { Bolt }, hinge: boolean? } }

-- piece E2, the suspension: block stand-ins until the corner 3D (full_teardown §0-2 corner spec), left side (x = the
-- car's inside), fasteners in the manual's order (carbook e2_suspension_answers; torque only noted)
local SPRING = Color3.fromRGB(60, 120, 200)
local STRUT = Color3.fromRGB(70, 72, 78)
CarParts.Blocks.Strut = {
	pieces = {
		{ name = "Strut", size = Vector3.new(0.32, 1.75, 0.32), offset = Vector3.zero, color = STRUT, material = Enum.Material.Metal },
		{ name = "Spring", size = Vector3.new(0.62, 0.85, 0.62), offset = Vector3.new(0, 0.35, 0), color = SPRING },
	},
	bolts = {
		{ offset = Vector3.new(0.2, -0.35, 0), out = R }, -- 1 the stabilizer link nut (74 N·m)
		{ offset = Vector3.new(-0.2, -0.55, 0), out = L }, -- 2 the brake hose / speed sensor bracket bolt (29 N·m)
		{ offset = Vector3.new(0, -0.8, 0.12), out = F, f = "BoltHeavy", tightenAfter = "Bolt_7" }, -- 3 knuckle bolt + nut (290 N·m)
		{ offset = Vector3.new(0, -0.8, -0.12), out = F, f = "BoltHeavy", tightenAfter = "Bolt_7" }, -- 4 the other one
		{ offset = Vector3.new(0.15, 0.86, 0), out = U, requires = { "Hood:Open" }, loosenAfter = "Bolt_4" }, -- 5-7 top nuts (50 N·m),
		{ offset = Vector3.new(-0.08, 0.86, 0.13), out = U, requires = { "Hood:Open" }, loosenAfter = "Bolt_4" }, -- under the hood, the
		{ offset = Vector3.new(-0.08, 0.86, -0.13), out = U, requires = { "Hood:Open" }, loosenAfter = "Bolt_4" }, -- knuckle off first
	},
}
CarParts.Blocks.StabLink = {
	pieces = { { name = "StabLink", size = Vector3.new(0.14, 0.7, 0.14), offset = Vector3.zero, color = STRUT, material = Enum.Material.Metal } },
	bolts = { { offset = Vector3.new(-0.08, 0.3, 0), out = L }, { offset = Vector3.new(-0.08, -0.3, 0), out = L } }, -- both ends (75 N·m)
}
CarParts.Blocks.Shock = {
	pieces = { { name = "Shock", size = Vector3.new(0.26, 1.28, 0.26), offset = Vector3.zero, color = STRUT, material = Enum.Material.Metal } },
	bolts = {
		{ offset = Vector3.new(-0.14, -0.62, 0), out = L }, -- the lower nut + plate washer (125 N·m)
		{ offset = Vector3.new(0, 0.66, 0.12), out = U }, -- the body bolts (55 N·m)
		{ offset = Vector3.new(0, 0.66, -0.12), out = U },
		{ offset = Vector3.new(-0.3, 0.25, 0.2), out = F }, -- the upper control arm's bolt at the carrier (73 N·m)
	},
}
CarParts.Blocks.LowerArm = {
	pieces = { { name = "LowerArm", size = Vector3.new(1.4, 0.18, 0.36), offset = Vector3.zero, color = Color3.fromRGB(45, 46, 50), material = Enum.Material.Metal } },
	bolts = {
		{ offset = Vector3.new(-0.65, 0, 0), out = F }, -- the outer bolt + nut, out (73 N·m)
		{ offset = Vector3.new(0.65, 0, 0), out = F }, -- the inner cam nut, only loosened — it hinges on this one (100 N·m)
	},
}
CarParts.Blocks.Spring = {
	pieces = { { name = "Spring", size = Vector3.new(0.6, 1.33, 0.6), offset = Vector3.zero, color = SPRING } },
	bolts = {}, -- (nothing holds it: it comes out once the arm under it is down)
}

-- piece E (the engine bay taken apart): each part's stand-in = one block of its 3D bounds, fasteners = the 3D's
-- F_<Fastener>_<n> points (PartData/Generated/SedanBay — tools/gen_partdata.py). Per slot (coils / plugs each sit at
-- their own place) and per kind (a new one from the counter); only used where a row of it is live (PartGraph.lumpLive).
-- Each type's own 3D (PartData/Car3D) into its own table: the sedan's = the shared CarParts.Blocks, another type's =
-- its CarType.Blocks (blocksFor looks there first)
local function blocks3D(gen: { [string]: any }, into: { [string]: any })
	for id, p in gen do
		local marked = false -- (a fixed node the 3D has given fasteners to: a "later" row — intake duct, ECM …)
		for _, pt in p.points or {} do
			marked = marked or pt.f ~= nil
		end
		if p.role == "part" or marked then
			local bolts = {}
			for _, pt in p.points or {} do
				if pt.f then
					table.insert(bolts, { offset = pt.at, out = pt.axis, f = pt.f, point = pt })
				end
			end
			table.sort(bolts, function(a, b)
				return a.f .. tostring(a.offset) < b.f .. tostring(b.offset)
			end)
			-- (suspension_v1: a fastener's own condition — "Arm:*" = this corner's — and the ones out before it: it
			-- loosens after the last of them, they tighten after it on the way back — Bolt_<n> = its place here)
			local named = {}
			for i, bolt in bolts do
				named[bolt.point.name] = i
			end
			for i, bolt in bolts do
				local pt = bolt.point
				if pt.needs then
					bolt.requires = { (pt.needs:gsub("%*", p.corner or "*")) }
				end
				local last = 0
				for _, a in pt.after or {} do
					local j = named[a] or 0
					last = math.max(last, j)
					if j > 0 then
						local back = bolts[j]
						back.tightenAfter = "Bolt_" .. math.max(i, tonumber((back.tightenAfter or "Bolt_0"):sub(6)) or 0)
					end
				end
				if last > 0 then
					bolt.loosenAfter = "Bolt_" .. last
				end
			end
			for _, bolt in bolts do
				bolt.point = nil
			end
			local set = {
				pieces = { { name = id, size = p.size, offset = p.centre - p.pivot, color = Color3.fromRGB(110, 112, 118) } },
				bolts = bolts,
			}
			into[id] = into[id] or set
			into[p.kind] = into[p.kind] or set
		end
	end
end
blocks3D(CarParts.Bay.parts, CarParts.Blocks)

-- the way out of the bay (3D v2.2 P_Exit_1..n — PROGRESS 'new contract'): per slot id, the part's pose after each
-- step, relative to where it sits (CFrame.fromMatrix(at, axis, up): the part's own axes = the car's, unturned). Lifted
-- out = these one after another, Lerp between (BoltLook.partOut), and it rests at the last one (CarryService.detach).
-- None = straight up Config.DetachPop. Aside = the nodes turned out of the way first (Hinge_Off, deg) — CarLook.
CarParts.Exit = {} :: { [string]: { CFrame } }
CarParts.Aside = {} :: { [string]: { { node: string, deg: number, with: { string } } } }
CarParts.Exits = { Sedan = CarParts.Exit } :: { [string]: { [string]: { CFrame } } } -- (per type: its own 3D's)
CarParts.Asides = { Sedan = CarParts.Aside } :: { [string]: { [string]: { { node: string, deg: number, with: { string } } } } }
local function ways3D(gen: { [string]: any }, exit: { [string]: { CFrame } }, aside: { [string]: any })
	for id, p in gen do
		local steps = {}
		for _, pt in p.points or {} do
			local n = tonumber(pt.name:match("^P_Exit_(%d+)$"))
			if n then
				steps[n] = CFrame.fromMatrix(pt.at, pt.axis or Vector3.xAxis, pt.up or Vector3.yAxis)
			end
		end
		if #steps > 0 then
			exit[id] = steps
		elseif p.way then
			exit[id] = p.way -- (suspension_v1: the planner's checked waypoints, the same poses)
		end
		if p.aside then
			aside[id] = p.aside
		end
	end
end
ways3D(CarParts.Bay.parts, CarParts.Exit, CarParts.Aside)
-- piece E2, the corners (Generated/SedanSusp): each slot's own block, bolts and way out — Strut_FL / Strut_FR apart,
-- the right side its own mirrored mesh (only read where E2's lump is live: PartGraph.lumpLive)
blocks3D(Car3D.susp("Sedan").parts, CarParts.Blocks)
ways3D(Car3D.susp("Sedan").parts, CarParts.Exit, CarParts.Aside)
-- the battery's two short leads (v2.2: BatteryLead_Pos with the red + cover welded on, BatteryTerminal_Neg) are their
-- own pieces: each turns aside on its Hinge_Off while that terminal's nut is off — or the battery is out — so the
-- battery comes up past them (PROGRESS v2.2 wr-dev 4; the same turn the tray's way out needs). Bolt = the battery's.
-- the battery's lead posts, battery-local (battery_posts_v1 battery_attachments.json Post_Pos / Post_Neg — the mesh has
-- real posts now): the terminal clean-up screen and its crust marks sit on them, not on the pinch nuts (Scrub, FaultService)
CarParts.BatteryPosts = { Pos = Vector3.new(-0.37, 0.742, -0.18), Neg = Vector3.new(0.37, 0.736, -0.18) }
-- where one of them is in the world, on a battery part (its SnapAttachment = the battery's own frame); nil = not a battery
function CarParts.batteryPost(part: Instance?, which: string): Vector3?
	local snap = part and part:FindFirstChild("SnapAttachment", true)
	local at = CarParts.BatteryPosts[which]
	return if snap and snap:IsA("Attachment") and at then snap.WorldCFrame * at else nil
end
CarParts.TerminalAside = {
	{ node = "BatteryLead_Pos", slot = "Battery", bolt = "Bolt_2" }, -- (+)
	{ node = "BatteryTerminal_Neg", slot = "Battery", bolt = "Bolt_1" }, -- (-)
}
for _, t in CarParts.TerminalAside do
	for _, a in CarParts.Aside.BatteryTray or {} do
		if a.node == t.node then
			t.deg, t.with = a.deg, a.with
		end
	end
end

-- fixed body: Chassis (PrimaryPart, holds Snap_ attachments), Body/Shell (one model of blocks), Body/Glass,
-- Moving/BrakeCaliper_XX, Decor/* (car_spec 3-1, 5)
CarParts.Chassis = { size = Vector3.new(7.0, 0.4, 16.4), pos = Vector3.new(0, 0.7, 0.1), color = DARK }
CarParts.Shell = {
	{ name = "SideL", size = Vector3.new(0.3, 3.3, 7.0), pos = Vector3.new(-3.65, 2.55, -0.1), color = PAINT },
	{ name = "SideR", size = Vector3.new(0.3, 3.3, 7.0), pos = Vector3.new(3.65, 2.55, -0.1), color = PAINT },
	{ name = "FenderFL", size = Vector3.new(0.3, 1.05, 4.4), pos = Vector3.new(-3.65, 3.425, -5.8), color = PAINT },
	{ name = "FenderFR", size = Vector3.new(0.3, 1.05, 4.4), pos = Vector3.new(3.65, 3.425, -5.8), color = PAINT },
	{ name = "FenderRL", size = Vector3.new(0.3, 1.35, 5.0), pos = Vector3.new(-3.65, 3.575, 5.9), color = PAINT },
	{ name = "FenderRR", size = Vector3.new(0.3, 1.35, 5.0), pos = Vector3.new(3.65, 3.575, 5.9), color = PAINT },
	{ name = "Cowl", size = Vector3.new(7.0, 3.2, 0.4), pos = Vector3.new(0, 2.5, -3.6), color = DARK },
	{ name = "Nose", size = Vector3.new(7.0, 1.25, 0.3), pos = Vector3.new(0, 3.225, -7.95), color = PAINT },
	{ name = "Roof", size = Vector3.new(7.2, 0.3, 5.4), pos = Vector3.new(0, 5.65, 0.0), color = PAINT },
	{ name = "PillarA_L", size = Vector3.new(0.3, 1.3, 0.3), pos = Vector3.new(-3.5, 4.85, -3.4), color = PAINT },
	{ name = "PillarA_R", size = Vector3.new(0.3, 1.3, 0.3), pos = Vector3.new(3.5, 4.85, -3.4), color = PAINT },
	{ name = "PillarC_L", size = Vector3.new(0.3, 1.3, 0.3), pos = Vector3.new(-3.5, 4.85, 3.2), color = PAINT },
	{ name = "PillarC_R", size = Vector3.new(0.3, 1.3, 0.3), pos = Vector3.new(3.5, 4.85, 3.2), color = PAINT },
	{ name = "TrunkLid", size = Vector3.new(7.0, 0.3, 5.2), pos = Vector3.new(0, 4.2, 6.0), color = PAINT },
	{ name = "RearPanel", size = Vector3.new(7.0, 1.45, 0.3), pos = Vector3.new(0, 3.325, 8.35), color = PAINT },
	{ name = "TailLightL", size = Vector3.new(1.4, 0.4, 0.1), pos = Vector3.new(-2.6, 3.6, 8.52), color = Color3.fromRGB(210, 30, 30), material = Enum.Material.Neon },
	{ name = "TailLightR", size = Vector3.new(1.4, 0.4, 0.1), pos = Vector3.new(2.6, 3.6, 8.52), color = Color3.fromRGB(210, 30, 30), material = Enum.Material.Neon },
	{ name = "HeadLightL", size = Vector3.new(1.4, 0.4, 0.1), pos = Vector3.new(-2.6, 3.3, -8.12), color = Color3.fromRGB(250, 248, 225), material = Enum.Material.Neon },
	{ name = "HeadLightR", size = Vector3.new(1.4, 0.4, 0.1), pos = Vector3.new(2.6, 3.3, -8.12), color = Color3.fromRGB(250, 248, 225), material = Enum.Material.Neon },
}
CarParts.Glass = { size = Vector3.new(7.0, 1.3, 6.8), pos = Vector3.new(0, 4.85, -0.1), color = Color3.fromRGB(150, 195, 215) }
CarParts.Decor = {
	{ name = "Deco_EngineTop", size = Vector3.new(3.0, 2.2, 2.0), pos = Vector3.new(0.3, 2.3, -5.6), color = Color3.fromRGB(85, 88, 95), material = Enum.Material.Metal },
	{ name = "Deco_Transaxle", size = Vector3.new(1.6, 0.7, 1.6), pos = Vector3.new(-1.9, 1.2, -6.2), color = Color3.fromRGB(110, 112, 118), material = Enum.Material.Metal },
	{ name = "Deco_EngineBay", size = Vector3.new(0.9, 0.2, 1.15), pos = Vector3.new(-2.2, 2.25, -5.7), color = DARK }, -- battery tray (v0.7: up on a leg)
	{ name = "Deco_BatteryStand", size = Vector3.new(0.3, 0.7, 0.3), pos = Vector3.new(-2.2, 1.8, -5.7), color = DARK },
	{ name = "Deco_Interior", size = Vector3.new(6.0, 1.0, 1.4), pos = Vector3.new(0, 1.5, -0.6), color = Color3.fromRGB(70, 60, 55) },
	{ name = "Deco_Dash", size = Vector3.new(6.6, 0.8, 0.8), pos = Vector3.new(0, 3.7, -3.0), color = Color3.fromRGB(40, 40, 44) },
}
for corner, c in CarParts.WheelCenters do
	local disc = if c.Z < 0 then 1.26 else 1.17 -- front / rear discs (car_spec v0.7; rear discs too)
	table.insert(CarParts.Decor, { name = "Deco_Hub_" .. corner, size = Vector3.new(0.15, disc, disc), pos = c, color = METAL, material = Enum.Material.Metal, shape = "Cylinder" })
end

-------------------------------------------------------------------------------------------------------------------
-- Car types (docs/design/car_roster.md): each type's own places and sizes. Everything above is the Sedan's;
-- CarParts.type(car's CarType attribute) gives one type's whole set. Part kinds, bolt counts, Requires are shared.
-- Crossover = docs/specs/suv_spec.md v0.3 + art/3d/suv_body/*_attachments.json (3D 3rd pass).
-------------------------------------------------------------------------------------------------------------------

export type CarType = {
	name: string,
	prefix: string, -- CarMeshes template prefix for this type's own meshes ("" = the Sedan's)
	paint: Color3,
	Slots: { [string]: Slot },
	WheelCenters: { [string]: Vector3 },
	LiftLevels: { { name: string, y: number } },
	HoodOpenDeg: number,
	HoodProp: { hinge: Vector3, axis: Vector3, deg: number },
	sill: number, -- the lift pads' height under the car (LiftPoint_* Y)
	workCentre: { [string]: Vector3 }?, -- a work view's look-at point in car coordinates where the car's bay isn't the sedan's (WorkViewUI.Cam's centre is)
	jackZ: { F: number, R: number }?, -- the floor jack's lifting points' Z when the 3D's cross-member isn't 1.6 ahead of the axle / bumper
	Chassis: { [string]: any },
	Shell: { { [string]: any } },
	Glass: { [string]: any },
	Decor: { { [string]: any } },
	Blocks: { [string]: { pieces: { Piece }, bolts: { Bolt }, hinge: boolean? } }, -- by slot, then by kind
}

-- a copy of block specs moved by `d`, with some pieces changed (`set[name]` = fields to replace)
local function moved(list: { { [string]: any } }, d: Vector3, set: { [string]: { [string]: any } }?, paint: Color3?): { { [string]: any } }
	local out = {}
	for _, s in list do
		local c = table.clone(s)
		c.pos += d
		if paint and s.color == PAINT then
			c.color = paint
		end
		for k, v in (set and set[s.name]) or {} do
			c[k] = v
		end
		table.insert(out, c)
	end
	return out
end

local function hubs(centers: { [string]: Vector3 }): { { [string]: any } }
	local out = {}
	for corner, c in centers do
		local disc = if c.Z < 0 then 1.26 else 1.17
		table.insert(out, { name = "Deco_Hub_" .. corner, size = Vector3.new(0.15, disc, disc), pos = c, color = METAL, material = Enum.Material.Metal, shape = "Cylinder" })
	end
	return out
end

local sedanDecor = {}
for _, s in CarParts.Decor do
	if s.name:sub(1, 9) ~= "Deco_Hub_" then
		table.insert(sedanDecor, s)
	end
end

local Types: { [string]: CarType } = {}
Types.Sedan = {
	name = "Sedan",
	prefix = "",
	paint = PAINT,
	Slots = slots,
	WheelCenters = CarParts.WheelCenters,
	LiftLevels = CarParts.LiftLevels,
	HoodOpenDeg = CarParts.HoodOpenDeg,
	HoodProp = CarParts.HoodProp,
	sill = 0.5,
	Chassis = CarParts.Chassis,
	Shell = CarParts.Shell,
	Glass = CarParts.Glass,
	Decor = CarParts.Decor,
	Blocks = {},
}

do
	local SAGE = Color3.fromHex("8FA283") -- suv_spec 4: the default paint (MeshPart.Color)
	local centers = (PartGraph.car("Crossover") :: PartGraph.Car).wheels -- (its parts' places: PartData/Cars/Crossover)
	local bay = Vector3.new(0, 0.5, 0.15) -- suv_spec 4: the engine bay = the sedan's + this (the decor moves with it)
	local tire = table.clone(CarParts.Blocks.Wheel.pieces[2])
	tire.size = Vector3.new(1.15, 2.98, 2.98) -- the same rim, a taller tire (suv_spec 1)
	Types.Crossover = {
		name = "Crossover",
		prefix = "Crossover_",
		paint = SAGE,
		Slots = PartGraph.slots("Crossover") :: any,
		WheelCenters = centers,
		-- the wheel centre at a standing R15's chest like the sedan: 1.49 + 1.7 (suv_spec 6)
		LiftLevels = { { name = "Ground", y = 0 }, { name = "Wheel", y = 1.7 }, { name = "Under", y = 6.0 } },
		HoodOpenDeg = 57.8,
		HoodProp = { hinge = Vector3.new(2.12, 3.6, -7.76), axis = Vector3.new(0, 0.3273, -0.9449), deg = 86.66 },
		sill = 0.7,
		Chassis = { size = Vector3.new(7.0, 0.4, 16.0), pos = Vector3.new(0, 0.9, 0.15), color = DARK },
		-- stand-in blocks (hidden under the 3D; they keep the clicks / the solid car): the sedan's, taller
		Shell = moved(CarParts.Shell, Vector3.new(0, 0.5, 0), {
			SideL = { size = Vector3.new(0.3, 3.4, 7.0) },
			SideR = { size = Vector3.new(0.3, 3.4, 7.0) },
			Roof = { size = Vector3.new(7.2, 0.3, 8.6), pos = Vector3.new(0, 6.45, 1.6) },
			PillarA_L = { size = Vector3.new(0.3, 1.6, 0.3), pos = Vector3.new(-3.5, 5.5, -3.9) },
			PillarA_R = { size = Vector3.new(0.3, 1.6, 0.3), pos = Vector3.new(3.5, 5.5, -3.9) },
			PillarC_L = { size = Vector3.new(0.3, 1.6, 0.3), pos = Vector3.new(-3.5, 5.5, 5.8) },
			PillarC_R = { size = Vector3.new(0.3, 1.6, 0.3), pos = Vector3.new(3.5, 5.5, 5.8) },
			TrunkLid = { name = "Liftgate", size = Vector3.new(6.8, 3.0, 0.3), pos = Vector3.new(0, 5.1, 7.6) },
			Cowl = { pos = Vector3.new(0, 3.0, -4.2) },
		}, SAGE),
		Glass = { size = Vector3.new(7.0, 1.6, 9.4), pos = Vector3.new(0, 5.5, 1.0), color = CarParts.Glass.color },
		Decor = (function()
			local d = moved(sedanDecor, bay, {
				Deco_Interior = { pos = Vector3.new(0, 1.9, -0.5) },
				Deco_Dash = { pos = Vector3.new(0, 4.2, -3.5) },
			})
			for _, h in hubs(centers) do
				table.insert(d, h)
			end
			return d
		end)(),
		-- art/3d/suv_body/B_concept/*_attachments.json, from each pivot (the rear bumper's in its own turned axes)
		Blocks = {
			Wheel = { pieces = { CarParts.Blocks.Wheel.pieces[1], tire }, bolts = CarParts.Blocks.Wheel.bolts },
			Hood = {
				pieces = { { name = "Hood", size = Vector3.new(6.35, 0.3, 3.65), offset = Vector3.new(0, -0.45, -2.0), color = SAGE } },
				bolts = { { offset = Vector3.new(-2.75, -0.225, -0.35), out = D }, { offset = Vector3.new(-2.75, -0.246, -0.6), out = D }, { offset = Vector3.new(2.75, -0.224, -0.35), out = D }, { offset = Vector3.new(2.75, -0.246, -0.6), out = D } },
				hinge = true,
			},
			Bumper_F = {
				pieces = { { name = "Bumper", size = Vector3.new(7.6, 2.2, 1.2), offset = Vector3.new(0, 0.04, 0.5), color = Color3.fromRGB(62, 62, 66) } },
				bolts = {
					{ offset = Vector3.new(-2.2, 1.106, 0.35), out = U, requires = { "Hood:Open" } },
					{ offset = Vector3.new(2.2, 1.106, 0.35), out = U, requires = { "Hood:Open" } },
					{ offset = Vector3.new(-2.4, -1.046, 0.35), out = D, requires = { "Lift:Wheel" } },
					{ offset = Vector3.new(2.4, -1.046, 0.35), out = D, requires = { "Lift:Wheel" } },
				},
			},
			Bumper_R = {
				pieces = { { name = "Bumper", size = Vector3.new(7.6, 1.9, 1.3), offset = Vector3.new(0, -0.048, 0.652), color = Color3.fromRGB(62, 62, 66) } },
				-- 2 bolts inside the rear wheel wells (facing them), 2 underneath
				bolts = {
					{ offset = Vector3.new(3.45, 0.25, 1.35), out = B },
					{ offset = Vector3.new(-3.45, 0.25, 1.35), out = B },
					{ offset = Vector3.new(2.3, -0.953, 0.15), out = D },
					{ offset = Vector3.new(-2.3, -0.953, 0.15), out = D },
				},
			},
		},
	}
end
-- Ella's pumpkin coach (Halloween: HalloweenService uses it only once CarParts.baked("PumpkinCoach"); until then an orange
-- sedan comes). Values = art/3d/pumpkin_car/v3/pumpkin_spec.md §0 / work/b1/spec_values.json (3D 10-23): the sedan's parts
-- at the coach's places (PartData/Cars/PumpkinCoach), a wheelbase of 5.1 (the sedan's 10.0), the hood hinge at (0, 5.035, -2.68).
-- NOT in Config.CarTypeShare: it never turns up as an ordinary customer. Waiting for the 3D ids (main uploads, wr-release bakes
-- PumpkinCoach_*): the block stand-ins below only keep the clicks / solid car meshes-off; the numbers are the 3D's own.
do
	local ORANGE = Color3.fromHex("E8862A") -- halloween_pumpkin: the coach's paint (MeshPart.Color; the ridges show the darker overlay)
	local centers = (PartGraph.car("PumpkinCoach") :: PartGraph.Car).wheels
	-- the front group (engine bay, radiator, battery, bumper, hood) sits 2.45 further back than the sedan's + the SUV's lift
	-- (v3: wheelbase 5.1; the SUV bay's decor, +(0, -0.115, +2.30) from the SUV's places, i.e. the sedan's + this)
	local bay = Vector3.new(0, 0.385, 2.45)
	Types.PumpkinCoach = {
		name = "PumpkinCoach",
		prefix = "PumpkinCoach_",
		paint = ORANGE,
		Slots = PartGraph.slots("PumpkinCoach") :: any,
		WheelCenters = centers,
		LiftLevels = CarParts.LiftLevels, -- (the wheel centre 1.375 like the sedan: Wheel 1.8 / Under 6.0)
		HoodOpenDeg = 57.8,
		-- v3: the prop's hinge, its axis (to the hood's frame socket (1.4, 4.479, -3.77)), 90 deg of swing
		HoodProp = { hinge = Vector3.new(1.40, 3.76, -5.25), axis = Vector3.new(0, 0.6241, -0.7813), deg = 90.0 },
		workCentre = { EngineBay = Vector3.new(-0.8, 2.885, -4.05) }, -- (the sedan's (-0.8, 2.5, -6.5) + the front group's (0, 0.385, 2.45))
		jackZ = { F = -3.90, R = 3.60 }, -- (spec §0: the front sub-frame cross-bar the floor jack lifts, moved with the front group; the rear as the rule)
		sill = 0.6, -- LiftPoint_* (+-3.0, 0.6, -+0.693) on the door sills (Z -1.01..1.01)
		Chassis = { size = Vector3.new(6.4, 0.45, 9.6), pos = Vector3.new(0, 0.85, -0.3), color = DARK },
		-- stand-in blocks (hidden under the 3D; they keep the clicks / the solid car): a short, round-ish coach
		Shell = moved(CarParts.Shell, Vector3.new(0, 0.4, 0), {
			SideL = { size = Vector3.new(0.3, 3.4, 5.2), pos = Vector3.new(-3.65, 2.8, -0.2) },
			SideR = { size = Vector3.new(0.3, 3.4, 5.2), pos = Vector3.new(3.65, 2.8, -0.2) },
			FenderFL = { size = Vector3.new(0.3, 1.05, 3.4), pos = Vector3.new(-3.65, 3.6, -4.0) },
			FenderFR = { size = Vector3.new(0.3, 1.05, 3.4), pos = Vector3.new(3.65, 3.6, -4.0) },
			FenderRL = { size = Vector3.new(0.3, 1.35, 3.4), pos = Vector3.new(-3.65, 3.8, 3.8) },
			FenderRR = { size = Vector3.new(0.3, 1.35, 3.4), pos = Vector3.new(3.65, 3.8, 3.8) },
			Cowl = { pos = Vector3.new(0, 2.9, -2.7) },
			Nose = { pos = Vector3.new(0, 3.5, -5.4) },
			Roof = { size = Vector3.new(6.4, 0.3, 6.2), pos = Vector3.new(0, 6.6, 0.4) },
			PillarA_L = { size = Vector3.new(0.3, 1.6, 0.3), pos = Vector3.new(-3.2, 5.8, -2.6) },
			PillarA_R = { size = Vector3.new(0.3, 1.6, 0.3), pos = Vector3.new(3.2, 5.8, -2.6) },
			PillarC_L = { size = Vector3.new(0.3, 1.6, 0.3), pos = Vector3.new(-3.2, 5.8, 3.4) },
			PillarC_R = { size = Vector3.new(0.3, 1.6, 0.3), pos = Vector3.new(3.2, 5.8, 3.4) },
			TrunkLid = { size = Vector3.new(6.4, 0.3, 3.2), pos = Vector3.new(0, 5.0, 3.4) },
			RearPanel = { size = Vector3.new(6.4, 1.45, 0.3), pos = Vector3.new(0, 3.6, 5.0) },
			TailLightL = { pos = Vector3.new(-2.4, 4.0, 5.14) },
			TailLightR = { pos = Vector3.new(2.4, 4.0, 5.14) },
			HeadLightL = { pos = Vector3.new(-2.4, 3.7, -5.6) },
			HeadLightR = { pos = Vector3.new(2.4, 3.7, -5.6) },
		}, ORANGE),
		Glass = { size = Vector3.new(6.4, 1.6, 6.4), pos = Vector3.new(0, 5.6, 0.2), color = CarParts.Glass.color },
		Decor = (function()
			local d = moved(sedanDecor, bay, {
				Deco_Interior = { pos = Vector3.new(0, 1.9, -0.2) },
				Deco_Dash = { pos = Vector3.new(0, 4.2, -1.7) },
			})
			for _, h in hubs(centers) do
				table.insert(d, h)
			end
			return d
		end)(),
		-- art/3d/pumpkin_car/v3/work/b1/spec_values.json, from each pivot (the rear bumper's in its own turned axes). Bumper_F: v3's
		-- numbers except Bumper_F: v3.1 trimmed the front bar (6.309 x 2.68 x 1.294 @ (0, 0.76, -0.307); the bolts stay)
		Blocks = {
			Wheel = CarParts.Blocks.Wheel, -- (the shared block and bolts: the rim's bolt circle 0.275, the hub face 0.3208)
			Hood = {
				pieces = { { name = "Hood", size = Vector3.new(5.67, 0.3, 3.108), offset = Vector3.new(0, -0.528, -1.476), color = ORANGE } },
				-- (the hood's hinge leaf, on top: reachable any time; out = U)
				bolts = {
					{ offset = Vector3.new(-2.05, -0.062, -0.19), out = U },
					{ offset = Vector3.new(-2.05, -0.101, -0.41), out = U },
					{ offset = Vector3.new(2.05, -0.057, -0.19), out = U },
					{ offset = Vector3.new(2.05, -0.107, -0.41), out = U },
				},
				hinge = true,
			},
			Bumper_F = {
				pieces = { { name = "Bumper", size = Vector3.new(6.309, 2.68, 1.294), offset = Vector3.new(0, 0.76, -0.307), color = Color3.fromRGB(138, 132, 80) } },
				bolts = {
					{ offset = Vector3.new(-1.58, 2.1, 0.23), out = U, requires = { "Hood:Open" } },
					{ offset = Vector3.new(1.58, 2.1, 0.23), out = U, requires = { "Hood:Open" } },
					{ offset = Vector3.new(-1.7, -0.15, 0.0), out = D, requires = { "Lift:Wheel" } },
					{ offset = Vector3.new(1.7, -0.15, 0.0), out = D, requires = { "Lift:Wheel" } },
				},
			},
			Bumper_R = {
				pieces = { { name = "Bumper", size = Vector3.new(5.861, 0.86, 1.141), offset = Vector3.new(0, 0.16, 0.394), color = Color3.fromRGB(138, 132, 80) } },
				-- 4 bolts under the car (the v2 spec's: 2 at the corners, 2 inboard)
				bolts = {
					{ offset = Vector3.new(2.212, -0.209, 0.686), out = D },
					{ offset = Vector3.new(-2.212, -0.209, 0.686), out = D },
					{ offset = Vector3.new(1.2, -0.10, 0.83), out = D },
					{ offset = Vector3.new(-1.2, -0.10, 0.83), out = D },
				},
			},
		},
	}
end
CarParts.Types = Types
-- the other types' own taken-apart 3D (main lumps 10-23: Generated/CrossoverBay … — none yet = nothing comes apart)
for name, t in Types do
	if name == "Sedan" then
		continue
	end
	for _, gen in { Car3D.of(name).parts, Car3D.susp(name).parts } do
		if next(gen) then
			blocks3D(gen, t.Blocks)
			CarParts.Exits[name] = CarParts.Exits[name] or {}
			CarParts.Asides[name] = CarParts.Asides[name] or {}
			ways3D(gen, CarParts.Exits[name], CarParts.Asides[name])
		end
	end
end

-- one car type's set (unknown / nil = the Sedan)
function CarParts.type(name: string?): CarType
	return Types[name or "Sedan"] or Types.Sedan
end

-- a type's taken-apart 3D (bay + underside; empty for a type that has none yet) and its parts' ways out of the car
function CarParts.bayOf(typeName: string?): Car3D.Set
	return Car3D.of(typeName or "Sedan")
end
function CarParts.exitOf(slotName: string?, typeName: string?): { CFrame }?
	local own = CarParts.Exits[typeName or "Sedan"]
	return own and own[slotName or ""]
end
-- the battery's leads that turn aside on this type (CarParts.TerminalAside with that type's own hinge turns)
function CarParts.terminalAside(typeName: string?): { { node: string, slot: string, bolt: string, deg: number?, with: { string }? } }
	if (typeName or "Sedan") == "Sedan" then
		return CarParts.TerminalAside
	end
	local out = {}
	for _, t in CarParts.TerminalAside do
		local c = { node = t.node, slot = t.slot, bolt = t.bolt, deg = nil :: number?, with = nil :: { string }? }
		for _, a in (CarParts.Asides[typeName :: string] or {}).BatteryTray or {} do
			if a.node == t.node then
				c.deg, c.with = a.deg, a.with
			end
		end
		table.insert(out, c)
	end
	return out
end

-- is this car type's 3D in the place (its body baked into ReplicatedStorage.CarMeshes)? A type without it would show as
-- blocks, so it isn't used (an old save without the SUV bake: only sedans come)
function CarParts.baked(name: string?): boolean
	local folder = game:GetService("ReplicatedStorage"):FindFirstChild("CarMeshes")
	return folder ~= nil and folder:FindFirstChild(CarParts.type(name).prefix .. "Decor_Shell") ~= nil
end

-- where the light-scratch mark (FaultService "polish") lies on a bumper, per car type and end: dy / dz from the root
-- box's centre, dz = out along the bumper's outward axis. The painted face of the 3D bumper stands 0.3-0.4 beyond the root
-- box, so the old "box face + 0.03" buried the mark (wr-ui 10:05). Measured in Play with rows of probe dots (visible = in
-- front of the mesh): Sedan front face 7.33 (y 2.4-2.85) / rear -9.50; Crossover front 7.21 (the white band y~2.5) / rear -9.42;
-- each +0.02. A new car type needs a row (the Sedan's is the fallback).
CarParts.ScratchFace = {
	Sedan = { F = { dy = 0.67, dz = 0.95 }, R = { dy = 0.56, dz = 0.92 } },
	Crossover = { F = { dy = 0.40, dz = 0.93 }, R = { dy = 0.40, dz = 1.0 } },
} :: { [string]: { F: { dy: number, dz: number }, R: { dy: number, dz: number } } }

-- sets whose 3D is the car type's own (<prefix><set>_Detail); the rest (pads, brakes, battery...) are shared
CarParts.TypeSets = { Wheel = true, Hood = true, Bumper_F = true, Bumper_R = true }

-- the parts counter sells a kind only while some car type really has it (piece E / E2 rows live) and it's for sale
-- (the No.2 arm isn't: it stays on the car)
function CarParts.sold(kind: string): boolean
	local k = CarParts.Kinds[kind] :: any
	if not k or k.notSold then
		return false
	end
	for _, ty in Types do
		for _, slot in ty.Slots do
			if slot.kind == kind then
				return true
			end
		end
	end
	return false
end

-- the new parts' jobs open only where those parts are live (Config.FaultUnlockLive → FaultUnlock), on the server and
-- every screen alike (both read this module)
do
	local Config = require(script.Parent.Config)
	for kind, level in Config.FaultUnlockLive do
		if CarParts.sold(kind) then
			Config.FaultUnlock[kind] = level
		end
	end
	-- (P5: the radiator sits under its cover and two hoses now — a ★3 job, later — full_teardown §0-1)
	if CarParts.sold("RadiatorHose") then
		Config.FaultUnlock.Radiator = Config.RadiatorDeepUnlock
	end
	-- (the muffler is worked on from the creeper: its job opens with the under view)
	if Config.feature("UnderView") then
		for kind, level in Config.UnderUnlock do
			Config.FaultUnlock[kind] = level
		end
	end
end

-- the blocks / bolts a part is built with: the type's own for that slot or kind, else the shared ones
function CarParts.blocksFor(kind: string, slotName: string?, carType: string?)
	local own = CarParts.type(carType).Blocks
	return (slotName and own[slotName]) or own[kind] or (slotName and CarParts.Blocks[slotName]) or CarParts.Blocks[kind]
end

-------------------------------------------------------------------------------------------------------------------
-- Work zones (docs/design/work_view.md v0.4 2 / 2d): where a fault is looked at and worked on, and what holds the car
-- up. Zone per slot = the scan's "Check here"; the end (F / R) = which jack stands make it reachable.
-------------------------------------------------------------------------------------------------------------------

-- (each part row's `zone`, PartData; hood / front bumper = "Body_Front": the outside, worked on from the floor)
function CarParts.zoneOf(slotName: string): string?
	local p = PartGraph.part("Sedan", slotName)
	return p and p.zone
end

-- the end of the car that has to be up for this slot ("F" / "R"), nil = no lifting needed (the row's `liftEnd`)
function CarParts.endOf(slotName: string?): string?
	if not slotName then
		return nil
	end
	local p = PartGraph.part("Sedan", slotName)
	if p then
		return p.liftEnd
	end
	return slotName:match("_(%u)%u$") -- (not a part: a wheel zone name like "Wheel_FL")
end

export type WorkGeo = {
	stand: { [string]: CFrame }, -- zone -> where the character stands (car axes), facing the work
	camera: { [string]: { pos: Vector3, look: Vector3 } }, -- zone -> default camera (car axes; wr-ui's WorkViewLook wins)
	jack: { F: Vector3, R: Vector3 }, -- the floor jack's lifting points (front / rear, middle underneath)
	stands: { F: { Vector3 }, R: { Vector3 } }, -- the jack stand spots (sills, behind the front / ahead of the rear wheels)
	chocks: { F: { Vector3 }, R: { Vector3 } }, -- wheel chocks when that end goes up (on the other end's wheels)
	axle: { F: number, R: number }, -- axle Z (the car pitches about the other one)
	under: { [string]: string }, -- the creeper zones (work_view 2c) -> the end that has to be on its stands
	prompt: { [string]: Vector3 }, -- a zone's prompt spot when it isn't over its stand (the creeper's: by the left sill)
	out: { [string]: CFrame }, -- where you stand up again after the creeper (facing the car)
}

local workCache: { [string]: WorkGeo } = {}
function CarParts.work(typeName: string?): WorkGeo
	local geo = CarParts.type(typeName)
	if workCache[geo.name] then
		return workCache[geo.name]
	end
	local c = geo.WheelCenters
	local front = geo.Slots.Bumper_F.pivot.Z
	local rear = geo.Slots.Bumper_R.pivot.Z
	local bay = geo.Slots.Battery.pivot
	local w: WorkGeo = {
		stand = {
			EngineBay = CFrame.lookAt(Vector3.new(0, 0, front - 2.4), Vector3.new(0, 0, front + 5)),
		},
		camera = {
			EngineBay = { pos = Vector3.new(0, bay.Y + 6.6, front - 3.4), look = Vector3.new(0, bay.Y - 0.2, bay.Z + 0.3) },
		},
		-- front: the jack pad on the front suspension member, 1.6 ahead of the front axle whatever the overhang (Camry
		-- manual lift diagram, notes/research/car_knowledge/diagrams/25; sedan -6.45 ~ carbook -6.5); rear: estimate
		jack = { F = Vector3.new(0, 0, if geo.jackZ then geo.jackZ.F else c.FL.Z - 1.6), R = Vector3.new(0, 0, if geo.jackZ then geo.jackZ.R else rear - 1.6) },
		stands = {
			F = { Vector3.new(-3.0, 0, c.FL.Z + 2.0), Vector3.new(3.0, 0, c.FR.Z + 2.0) },
			R = { Vector3.new(-3.0, 0, c.RL.Z - 2.0), Vector3.new(3.0, 0, c.RR.Z - 2.0) },
		},
		chocks = {
			F = { Vector3.new(-3.25, 0, c.RL.Z + 1.7), Vector3.new(3.25, 0, c.RR.Z + 1.7) },
			R = { Vector3.new(-3.25, 0, c.FL.Z - 1.7), Vector3.new(3.25, 0, c.FR.Z - 1.7) },
		},
		axle = { F = c.FL.Z, R = c.RL.Z },
		under = { Under_Front = "F", Under_Rear = "R" },
		prompt = {},
		out = {},
	}
	-- the creeper (work_view 2c): lying on your back across the car, feet out past the left sill, head under the work.
	-- Stand = the root lying there (its up = toward the head, its look = up at the car); camera = from the face up.
	-- Front: under the oil pan, behind the front jack point (the drain plug / filter, underbody_v1 0.7~1.24, -5.6);
	-- rear: under the muffler's front joint (its flange bolts ~(1.1~1.45, 0.8, 7.1)).
	-- The body lies clear of the tyres and the jack stands (Play 10-22: across the rear axle the legs went through the
	-- tyre) — rear: behind the rear wheel, right under the muffler; front: behind the front stands. The camera (tried
	-- in Play) sits a bit toward the middle, low, looking out past the work: the whole muffler, its flange bolts and
	-- the pipe in view; any closer and the can filled the screen.
	local lie = {
		Under_Front = { z = c.FL.Z + 3.1, eye = c.FL.Z + 1.2, look = Vector3.new(0.9, 0.9, c.FL.Z - 0.7) },
		Under_Rear = { z = c.RL.Z + 1.9, eye = c.RL.Z + 0.3, look = Vector3.new(1.0, 0.8, c.RL.Z + 2.2) },
	}
	for zone, l in lie do
		-- (root 0.99 up: an R15's back (0.5 below its root) on the 3D creeper's pad, top 0.492 — art/3d/creeper_v1)
		w.stand[zone] = CFrame.fromMatrix(Vector3.new(-1.5, 0.99, l.z), Vector3.new(0, 0, -1), Vector3.new(1, 0, 0))
		w.camera[zone] = { pos = Vector3.new(-0.6, 1.0, l.eye), look = l.look }
		w.prompt[zone] = Vector3.new(c.FL.X - 1.3, 2.2, l.z)
		w.out[zone] = CFrame.lookAt(Vector3.new(c.FL.X - 2.3, 0, l.z), Vector3.new(0, 0, l.z))
	end
	for corner, p in c do
		local side = if p.X < 0 then -1 else 1
		local at = Vector3.new(p.X + side * 3.4, 0, p.Z)
		w.stand["Wheel_" .. corner] = CFrame.lookAt(at, Vector3.new(p.X, 0, p.Z))
		w.camera["Wheel_" .. corner] = { pos = Vector3.new(p.X + side * 6.0, p.Y + 2.4, p.Z + (if p.Z < 0 then -1.2 else 1.2)), look = p + Vector3.new(-side * 0.3, -0.1, 0) }
	end
	workCache[geo.name] = w
	return w
end

return CarParts
