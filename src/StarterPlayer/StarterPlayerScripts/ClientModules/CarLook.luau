-- The corners' 3D look on this player's screen (CarParts.MeshSets; main decision 10-21 morning): wheels, pads,
-- calipers and hubs wear ReplicatedStorage.CarMeshes.<set>_Detail or _Lite.
--   car in a bay (server attribute Detail) -> always Detail
--   anything else (parked, showroom, junkyard, passing, loose / carried parts) -> Detail within Config.LodNear studs of
--   the camera, Lite beyond Config.LodFar (in between it keeps what it had, so it doesn't flicker)
-- Only this client sees the meshes: one server model, the blocks stay for clicks / attributes (hidden locally, bolt
-- heads stay visible). No template yet = the blocks show as before; no _Lite yet = the _Detail one.
-- Templates are in car axes for their side (tools/bake_carmeshes.luau): a part's frame = its snap with the slot's
-- 180° "turned" undone; corner pieces on the left take the _L mesh, or the right one turned 180° when there is none.
-- Hood / bumpers / body shell are painted with the car's colour (SurfaceAppearance Overlay shows MeshPart.Color).
-- Car types (CarParts.Types): the body, decor and CarParts.TypeSets (wheel, hood, bumpers) use the type's own
-- templates (<prefix><name>, e.g. Crossover_Hood_Detail) and never another type's; the rest are shared.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local PartGraph = require(ReplicatedStorage.Shared.PartGraph)
local Car3DOf = require(ReplicatedStorage.Shared.PartData.Car3D)

local CarLook = {}

type Holder = { root: BasePart, set: string, snap: boolean, weight: string?, key: string?, visual: Instance? }
local holders: { [BasePart]: Holder } = {}

local PIECES = { { "BrakeCaliper_", "BrakeCaliper" }, { "Deco_Hub_", "Hub" } } -- the car's own Moving / Decor pieces
local CORNER = { Wheel = true, BrakePads = true, BrakeCaliper = true, Hub = true } -- sets that have a left / right
local PAINTED = { Hood = true, Bumper_F = true, Bumper_R = true }
local TURN = CFrame.Angles(0, math.pi, 0)

local function carOf(inst: Instance): Model?
	local cars = workspace:FindFirstChild("Cars")
	local n: Instance? = inst
	while n and n.Parent ~= cars do
		n = n.Parent
	end
	return if n and n:IsA("Model") then n else nil
end

local function consider(inst: Instance)
	if inst:GetAttribute("Visual") then
		return -- our own mesh clones
	end
	local kind = inst:GetAttribute("PartKind")
	if kind and CarParts.MeshSets[kind] then
		local root = if inst:IsA("Model") then inst.PrimaryPart else inst
		if root and root:IsA("BasePart") then
			holders[root] = { root = root, set = CarParts.MeshSets[kind], snap = true }
		end
		return
	end
	if inst:IsA("BasePart") then
		for _, pair in PIECES do
			if inst.Name:sub(1, #pair[1]) == pair[1] and carOf(inst) then
				holders[inst] = { root = inst, set = CarParts.MeshSets[pair[2]], snap = false }
			end
		end
	end
end

-- the stand-in blocks of a piece (bolt heads stay)
local function blocks(root: BasePart): { BasePart }
	local list = { root }
	local model = root.Parent
	if model and model:IsA("Model") and model.PrimaryPart == root then
		for _, d in model:GetChildren() do
			if d:IsA("BasePart") and d ~= root and not d:GetAttribute("Bolt") and not d:GetAttribute("Keep") then
				table.insert(list, d)
			end
		end
	end
	return list
end

local function homeOf(root: BasePart): Instance
	return if root.Parent and root.Parent:IsA("Model") and (root.Parent :: Model).PrimaryPart == root then root.Parent else root
end

-- a car's mesh prefix ("" = the sedan's)
local function prefixOf(car: Instance?): string
	return CarParts.type(car and car:GetAttribute("CarType") :: string?).prefix
end

-- which template, how to place it: (template?, frame, cache key, painted)
local function resolve(h: Holder, weight: string): (Model?, CFrame, string, boolean)
	local root = h.root
	local folder = ReplicatedStorage:FindFirstChild("CarMeshes")
	local set = h.set
	-- on a car: that car's type; a loose part: the type it was made for (Fits)
	local car = carOf(root)
	local prefix = if car then prefixOf(car) else CarParts.type(homeOf(root):GetAttribute("Fits") :: string?).prefix
	local frame = root.CFrame
	local left = false
	if h.snap then
		local slotName = homeOf(root):GetAttribute("Slot") :: string?
		local def = slotName and CarParts.Slots[slotName]
		if set == "@slot" then
			-- (piece E: its own node — a counter one wears its kind's first: IgnitionCoil_1)
			set = slotName or CarParts.FirstSlot[homeOf(root):GetAttribute("PartKind") :: string] or "?"
		end
		if set == "Bumper" then
			set = if slotName == "Bumper_R" then "Bumper_R" else "Bumper_F"
		end
		-- (the new 3D's look for an old row, on a car whose lump is live: the muffler — CarParts.Swap3D)
		local swap = CarParts.Swap3D[slotName or (homeOf(root):GetAttribute("PartKind") :: string?) or ""]
		-- (off the car / a new one: the type it fits — Fits)
		local typeName = ((if car then car:GetAttribute("CarType") else homeOf(root):GetAttribute("Fits")) :: string?) or "Sedan"
		if swap and PartGraph.lumpLive(typeName, swap.lump) and folder and folder:FindFirstChild(swap.set .. "_Detail") then
			set = swap.set
		end
		local snap = root:FindFirstChild("SnapAttachment") :: Attachment?
		frame = if snap then snap.WorldCFrame else root.CFrame
		if def and def.turned then
			frame *= TURN -- back to car axes
		end
		left = CORNER[set] == true and def ~= nil and def.pivot.X < 0
	else
		left = root.Name:match("_[FR]L$") ~= nil
	end
	-- (a bay part of a type with its own taken-apart 3D wears that type's: Crossover_AirBoxLid_Detail)
	local fits = ((if car then car:GetAttribute("CarType") else homeOf(root):GetAttribute("Fits")) :: string?) or "Sedan"
	local own = if CarParts.TypeSets[set] or (h.set == "@slot" and fits ~= "Sedan" and next(CarParts.bayOf(fits).parts) ~= nil)
		then prefix
		else ""
	local painted = PAINTED[set] == true
	local function find(name: string): Model?
		name = own .. name
		local t = folder and (folder:FindFirstChild(name .. "_" .. weight) or folder:FindFirstChild(name .. "_Detail"))
		return if t and t:IsA("Model") and t.PrimaryPart then t else nil
	end
	-- a broken part's own look first (Wheel_Flat, Bumper_F_Dented), when its mesh is there
	local home = homeOf(root)
	local look = h.snap and home:GetAttribute("Look") :: string?
	if look and find(set .. "_" .. look) then
		set ..= "_" .. look
	else
		-- the car's kit (car_variety §1, CustomerService.wearLook — the piece carries it): <set>_<Face|Rim>_<Pattern>,
		-- <set>_<Face|Rim>, <set>_<Pattern>, the first one baked; none = the base look. Far away the base Lite
		-- beats a kit piece without its own Lite
		local kit = (if set == "Wheel" then home:GetAttribute("Rim") elseif set == "Bumper_F" then home:GetAttribute("Face") else nil) :: string?
		local pattern = home:GetAttribute("Pattern") :: string?
		pattern = if pattern == "Solid" then nil else pattern
		local function exact(name: string): boolean
			local t = folder and folder:FindFirstChild(own .. name .. "_" .. weight)
			return t ~= nil or (weight == "Detail" and folder ~= nil and folder:FindFirstChild(own .. name .. "_Detail") ~= nil)
		end
		local tries = {}
		if kit and pattern then
			table.insert(tries, set .. "_" .. kit .. "_" .. pattern)
		end
		if kit then
			table.insert(tries, set .. "_" .. kit)
		end
		if pattern then
			table.insert(tries, set .. "_" .. pattern)
		end
		for _, c in tries do
			if exact(c) or (left and exact(c .. "_L")) then
				set = c
				break
			end
		end
	end
	local template = if left then find(set .. "_L") else nil
	if not template then
		template = find(set)
		if template and left then
			frame *= TURN -- a right-side mesh, turned for the left
		end
	end
	return template, frame, weight .. ":" .. own .. set .. (if left then ":L" else ""), painted
end

-- this piece's look now (kept on the holder: the part's name changes as it goes on a car — "Bumper" on the floor,
-- "Bumper_F" in the slot — so a name lookup left the old look behind: two bumpers, test 2 TOP5)
local function lookOf(h: Holder): Instance?
	local v = h.visual
	return if v and v.Parent == homeOf(h.root) then v else nil
end

local function dress(h: Holder, weight: string)
	local root = h.root
	local home = homeOf(root)
	local old = lookOf(h)
	local template, frame, key, painted = resolve(h, weight)
	if old and h.key == key then
		h.weight = weight
		return
	end
	-- (any other look left on this piece goes too)
	for _, c in home:GetChildren() do
		if c ~= old and c.Name:sub(1, 7) == "Visual_" then
			c:Destroy()
		end
	end
	if not template then
		if old then
			old:Destroy()
		end
		h.visual = nil
		for _, b in blocks(root) do
			b.LocalTransparencyModifier = 0
		end
		h.weight, h.key = weight, key
		return
	end
	local v = template:Clone()
	v.Name = "Visual_" .. root.Name
	v:SetAttribute("Painted", painted)
	v:PivotTo(frame)
	for _, m in v:GetDescendants() do
		if m:IsA("BasePart") then
			m:SetAttribute("Visual", true)
			m.Anchored = false
			m.Massless = true
			m.CanCollide = false
			m.CanTouch = false
			m.CanQuery = false -- clicks go through to the block underneath
			local w = Instance.new("WeldConstraint")
			w.Part0 = root
			w.Part1 = m
			w.Parent = m
		end
	end
	v.Parent = home
	h.visual = v
	if old then
		old:Destroy() -- after the new one is in: no blank frame
	end
	for _, b in blocks(root) do
		b.LocalTransparencyModifier = 1
	end
	h.weight, h.key = weight, key
end

-- the car's paint right now (the shell block keeps it: restoration dirt changes it too)
local function paintOf(car: Model?): Color3?
	local body = car and car:FindFirstChild("Body")
	local shell = body and body:FindFirstChild("Shell")
	local side = shell and shell:FindFirstChild("SideL") :: BasePart?
	return side and side.Color
end

local function paint(v: Instance, color: Color3)
	for _, m in v:GetDescendants() do
		if m:IsA("MeshPart") and m.Color ~= color and not m:GetAttribute("NoPaint") then -- (the hood's washer nozzles)
			m.Color = color
		end
	end
end

-- piece E (main 10-22: the new bay is 88k triangles drawn all at once): a part on the car is drawn only once it can be
-- seen — the hood open, and nothing it sits under still on (a coil once the engine cover is off, a plug once its
-- coil is, the filter once the lid is) → ~19k in the usual view. Off the car it's always drawn.
local installed: { [Model]: { [string]: boolean } } = {} -- (per update pass: each car's slots that are on)
local function covered(car: Model, part: Instance): boolean
	if part:GetAttribute("State") ~= "Installed" then
		return false
	end
	if car:GetAttribute("HoodOpen") ~= true then
		return true
	end
	local on = installed[car]
	if not on then
		on = {}
		for _, d in car:GetDescendants() do
			local slot = d:GetAttribute("Slot")
			if slot and d:GetAttribute("PartKind") and d:GetAttribute("State") == "Installed" then
				on[slot] = true
			end
		end
		installed[car] = on
	end
	for req in string.gmatch((part:GetAttribute("Requires") :: string?) or "", "[^,]+") do
		if on[req] then
			return true
		end
	end
	return false
end

local coveredNow: { [Instance]: boolean } = {}
local function setCovered(look: Instance, on: boolean)
	if coveredNow[look] == on then
		return
	end
	coveredNow[look] = on
	for _, m in look:GetDescendants() do
		if m:IsA("BasePart") then
			m.LocalTransparencyModifier = if on then 1 else 0
		end
	end
	look.Destroying:Once(function()
		coveredNow[look] = nil
	end)
end

local function update()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local eye = cam.CFrame.Position
	table.clear(installed)
	for root, h in holders do
		if not root.Parent then
			holders[root] = nil
			continue
		end
		local car = carOf(root)
		local want = h.weight
		if car and car:GetAttribute("Detail") == "Detail" then
			want = "Detail"
		else
			local d = (root.Position - eye).Magnitude
			if d <= Config.LodNear then
				want = "Detail"
			elseif d >= Config.LodFar or want == nil then
				want = "Lite"
			end
		end
		-- re-dress when the weight / side changes, or when the server rebuilt the piece (the local look is gone)
		local _, _, key = resolve(h, want :: string)
		local look = lookOf(h)
		if want ~= h.weight or key ~= h.key or (want and not look and ReplicatedStorage:FindFirstChild("CarMeshes")) then
			dress(h, want :: string)
			look = lookOf(h)
		end
		local color = look and look:GetAttribute("Painted") and paintOf(car)
		if color then
			paint(look :: Instance, color)
		end
		if look and h.set == "@slot" then
			setCovered(look :: Instance, car ~= nil and covered(car, homeOf(root)))
		end
	end
end

-------------------------------------------------------------------------------------------------- the car's decor

local decorState: { [Instance]: boolean } = {} -- what each decor piece is set to now (only touch it on a change)

local function setShown(inst: Instance, on: boolean)
	if decorState[inst] == on then
		return
	end
	decorState[inst] = on
	local list = if inst:IsA("BasePart") then { inst } else {}
	for _, d in inst:GetDescendants() do
		if d:IsA("BasePart") then
			table.insert(list, d)
		end
	end
	for _, p in list do
		p.LocalTransparencyModifier = if on then 0 else 1
	end
end

-- 3D decor: one clone per car of CarMeshes.Decor_<Name>, welded to the chassis (local, like the wheel meshes)
local function decorMesh(car: Model, name: string, up: boolean?): Model?
	local folder = ReplicatedStorage:FindFirstChild("CarMeshes")
	local template = folder and folder:FindFirstChild(prefixOf(car) .. "Decor_" .. Car3DOf.key(name)) :: Model?
	if not template or not template.PrimaryPart or not car.PrimaryPart then
		return nil
	end
	local decor = car:FindFirstChild("Decor")
	local have = decor and decor:FindFirstChild("Mesh_" .. name)
	if have then
		return have :: Model
	end
	local v = template:Clone()
	v.Name = "Mesh_" .. name
	v:SetAttribute("Up", up == true)
	local frame = car:GetPivot()
	if up then
		local p = CarParts.type(car:GetAttribute("CarType") :: string?).HoodProp
		frame *= CFrame.new(p.hinge) * CFrame.fromAxisAngle(p.axis.Unit, math.rad(p.deg)) * CFrame.new(-p.hinge)
	end
	v:PivotTo(frame)
	for _, m in v:GetDescendants() do
		if m:IsA("BasePart") then
			m:SetAttribute("Visual", true)
			m.Anchored = false
			m.Massless = true
			m.CanCollide = false
			m.CanTouch = false
			m.CanQuery = false
			local w = Instance.new("WeldConstraint")
			w.Part0 = car.PrimaryPart
			w.Part1 = m
			w.Parent = m
		end
	end
	v.Parent = decor
	return v
end

-- piece E: a part node shown fixed (its row isn't live on this car yet): a copy of CarMeshes.<prefix><id>_Detail at its pivot
-- (turned by `turn`, car space, when given: a lead turned aside — asideParts)
local function staticPart(car: Model, id: string, pivot: Vector3, turn: CFrame?): Model?
	local folder = ReplicatedStorage:FindFirstChild("CarMeshes")
	local template = folder and folder:FindFirstChild(prefixOf(car) .. id .. "_Detail") :: Model?
	local decor = car:FindFirstChild("Decor")
	if not template or not template.PrimaryPart or not car.PrimaryPart or not decor then
		return nil
	end
	local have = decor:FindFirstChild("Static_" .. id)
	if have then
		return have :: Model
	end
	local v = template:Clone()
	v.Name = "Static_" .. id
	v:SetAttribute("Turned", turn ~= nil)
	v:PivotTo(car:GetPivot() * (turn or CFrame.identity) * CFrame.new(pivot))
	for _, m in v:GetDescendants() do
		if m:IsA("BasePart") then
			m:SetAttribute("Visual", true)
			m.Anchored = false
			m.Massless = true
			m.CanCollide = false
			m.CanTouch = false
			m.CanQuery = false
			local w = Instance.new("WeldConstraint")
			w.Part0 = car.PrimaryPart
			w.Part1 = m
			w.Parent = m
		end
	end
	v.Parent = decor
	return v
end

-- v2.2: the battery's short leads (CarParts.TerminalAside) — their own pieces, turned up and over on their Hinge_Off
-- while that terminal's nut is off or the battery is out, so the battery comes up past them; back down when it's on
local function asideParts(car: Model, shown: boolean)
	local typeName = car:GetAttribute("CarType") :: string?
	local bay = CarParts.bayOf(typeName).parts
	for _, t in CarParts.terminalAside(typeName) do
		local node = bay[t.node]
		local hinge = nil
		for _, pt in (node and node.points) or {} do
			if pt.name == "Hinge_Off" then
				hinge = pt
			end
		end
		if not node or not hinge or not t.deg then
			continue
		end
		local group = car:FindFirstChild(CarParts.Kinds.Battery.group)
		local bat = group and group:FindFirstChild(t.slot)
		local nut = bat and bat:GetAttribute("State") == "Installed" and bat:FindFirstChild(t.bolt .. "_Head", true)
		local open = not (nut and nut:GetAttribute("Tight") == true)
		local h = node.pivot + hinge.at
		local turn = if open then CFrame.new(h) * CFrame.fromAxisAngle(hinge.axis, math.rad(t.deg)) * CFrame.new(-h) else nil
		local decor = car:FindFirstChild("Decor")
		for _, id in { t.node, table.unpack(t.with or {}) } do
			local have = decor and decor:FindFirstChild("Static_" .. id)
			if have and have:GetAttribute("Turned") ~= open then
				have:Destroy()
				decorState[have] = nil
			end
			local m = bay[id] and staticPart(car, id, bay[id].pivot, turn)
			if m then
				setShown(m, shown)
			end
		end
	end
end

-- the body: Decor_Shell / Decor_Glass / Decor_Chassis replace Body/Shell, Body/Glass and the chassis block (the shell
-- in the car's paint pattern when that one is baked: Decor_Shell_TwoTone / _Stripe)
local function bodyMesh(car: Model, decor: Instance, name: string, block: Instance?)
	local folder = ReplicatedStorage:FindFirstChild("CarMeshes")
	local pattern = car:GetAttribute("Pattern") :: string?
	local template = folder and ((name == "Shell" and pattern and folder:FindFirstChild(prefixOf(car) .. "Decor_Shell_" .. pattern))
		or folder:FindFirstChild(prefixOf(car) .. "Decor_" .. name)) :: Model?
	if not template or not template.PrimaryPart or not block or not car.PrimaryPart then
		return
	end
	local mesh = decor:FindFirstChild("Mesh_Body_" .. name)
	if not mesh then
		local v = template:Clone()
		v.Name = "Mesh_Body_" .. name
		v:PivotTo(car:GetPivot())
		for _, m in v:GetDescendants() do
			if m:IsA("BasePart") then
				m:SetAttribute("Visual", true)
				m.Anchored = false
				m.Massless = true
				m.CanCollide = false
				m.CanTouch = false
				m.CanQuery = false
				local w = Instance.new("WeldConstraint")
				w.Part0 = car.PrimaryPart
				w.Part1 = m
				w.Parent = m
			end
		end
		v.Parent = decor
		mesh = v
	end
	setShown(block, false)
	if name == "Shell" then
		local color = paintOf(car)
		if color then
			paint(mesh :: Instance, color)
		end
	end
end

-- (re)weld a local piece onto the car at a frame in car coordinates
local function place(car: Model, part: BasePart, at: CFrame)
	for _, w in part:GetChildren() do
		if w:IsA("WeldConstraint") then
			w:Destroy()
		end
	end
	part.Anchored = true
	part.CFrame = car:GetPivot() * at
	part.Anchored = false
	local w = Instance.new("WeldConstraint")
	w.Part0 = car.PrimaryPart
	w.Part1 = part
	w.Parent = part
end

-- the liquid inside the see-through tanks (CarMeshes.Decor_Levels, art/3d/fault_parts/fault_parts_attachments.json,
-- sedan coords): its top moves with the car's state, the bottom stays — coolant under L while the radiator leaks,
-- brake fluid near MIN while the pads are worn (normal: it follows the pads). A car attribute Level_Coolant /
-- Level_BrakeFluid (a height) wins when set (a job that pours, a test); BrakeFluidOld = the brown old fluid.
local LEVELS = {
	Coolant = { slot = "Radiator", low = 2.80, ok = 3.25, min = 2.6, max = 3.45 }, -- L 3.00 · F 3.40 · 3.45 = over
	BrakeFluid = { slot = "BrakePads_", low = 3.06, ok = 3.22, min = 2.93, max = 3.32 }, -- MIN 3.02 · MAX 3.28
}
-- each liquid mesh: its bottom and the tops it can take (the coolant tank is narrower below 2.925 — the wheel house
-- — so two prisms: the upper one only shows above 2.93)
local PRISMS = {
	Deco_Level_Coolant = { level = "Coolant", bottom = 2.495, from = 2.5, to = 2.925 },
	Deco_Level_Coolant_Upper = { level = "Coolant", bottom = 2.925, from = 2.93, to = math.huge },
	Deco_Level_BrakeFluid = { level = "BrakeFluid", bottom = 2.925, from = 2.93, to = math.huge },
}
local BRAKE_FLUID = { new = Color3.fromHex("E9C766"), old = Color3.fromHex("8A5A2E") }
local function slotBroken(car: Model, slot: string): boolean
	for _, d in car:GetDescendants() do
		local s = d:GetAttribute("Slot")
		if type(s) == "string" and s:sub(1, #slot) == slot and d:GetAttribute("PartKind") and d:GetAttribute("State") == "Installed" then
			if ((d:GetAttribute("Condition") :: number?) or 100) < Config.BrokenBelow then
				return true
			end
		end
	end
	return false
end
local function levels(car: Model, decor: Instance, shown: boolean)
	local folder = ReplicatedStorage:FindFirstChild("CarMeshes")
	local set = folder and folder:FindFirstChild(prefixOf(car) .. "Decor_Levels")
	if not set or not car.PrimaryPart then
		return -- (sedan tanks only for now; no 3D tanks = no liquid)
	end
	local h = {}
	for name, l in LEVELS do
		local want = car:GetAttribute("Level_" .. name)
		h[name] = math.clamp(if type(want) == "number" then want elseif slotBroken(car, l.slot) then l.low else l.ok, l.min, l.max)
	end
	for _, t in set:GetChildren() do
		local r = PRISMS[t.Name]
		if not r or not t:IsA("BasePart") then
			continue
		end
		local top = math.clamp(h[r.level], r.from, r.to)
		local part = decor:FindFirstChild(t.Name) :: BasePart?
		if not part then
			local c = t:Clone()
			c.CanCollide, c.CanQuery, c.CanTouch, c.Massless = false, false, false, true
			c:SetAttribute("Visual", true)
			part = c
		end
		local p = part :: BasePart
		if p:GetAttribute("Top") ~= top then
			-- the template's frame is the car frame: same X / Z, the bottom stays put
			p.Size = Vector3.new(t.Size.X, top - r.bottom, t.Size.Z)
			place(car, p, CFrame.new(t.Position.X, (r.bottom + top) / 2, t.Position.Z) * t.CFrame.Rotation)
			p:SetAttribute("Top", top)
			p.Parent = decor
		end
		if r.level == "BrakeFluid" then
			p.Color = if car:GetAttribute("BrakeFluidOld") then BRAKE_FLUID.old else BRAKE_FLUID.new
		end
		p.LocalTransparencyModifier = if shown and h[r.level] > r.from then 0 else 1
	end
end

-- the wipers (CarMeshes.Decor_Wipers, fault_parts_attachments.json Wipers, sedan coords), always drawn. Car attribute
-- Wipers = "service" (both swung up the glass about their pivots — fault_looks §2 #2 "Service position") or "lifted"
-- (service + the arm up off the glass, for a blade swap); WiperWorn = the cracked blades (Decor_WiperBladesWorn: whole
-- meshes swapped in): true = both, "Long" / "Short" = that one only (a swap in progress)
local WIPERS = {
	Long = { pivot = Vector3.new(-2.4, 4.094, -3.8), sweep = Vector3.new(-0.0379, 0.6554, -0.7543), hinge = Vector3.new(-2.3452, 4.1757, -3.8776), lift = Vector3.new(-0.1787, 0.7383, 0.6504), liftDeg = 15.71 },
	Short = { pivot = Vector3.new(0.2, 4.214, -3.8), sweep = Vector3.new(0.0542, 0.6954, -0.7166), hinge = Vector3.new(0.2657, 4.291, -3.8738), lift = Vector3.new(-0.0639, 0.7186, 0.6925), liftDeg = 20.19 },
}
local SERVICE_DEG = -60
local function about(p: Vector3, axis: Vector3, deg: number): CFrame
	return CFrame.new(p) * CFrame.fromAxisAngle(axis.Unit, math.rad(deg)) * CFrame.new(-p)
end
local function wipers(car: Model)
	local mesh = decorMesh(car, "Deco_Wipers")
	if not mesh then
		return
	end
	local pose = car:GetAttribute("Wipers")
	local worn = car:GetAttribute("WiperWorn")
	local key = tostring(pose) .. "+" .. tostring(worn)
	if mesh:GetAttribute("Pose") == key then
		return
	end
	mesh:SetAttribute("Pose", key)
	local folder = ReplicatedStorage:FindFirstChild("CarMeshes")
	local wornSet = folder and folder:FindFirstChild("Decor_WiperBladesWorn")
	if worn and wornSet and not mesh:FindFirstChild("WiperBlade_Long_Worn") then
		for _, t in wornSet:GetChildren() do
			if t:IsA("BasePart") and t:GetAttribute("Rest") then
				local c = t:Clone()
				c.CanCollide, c.CanQuery, c.CanTouch, c.Massless = false, false, false, true
				c:SetAttribute("Visual", true)
				c.Parent = mesh
			end
		end
	end
	for _, p in mesh:GetChildren() do
		local rest = p:GetAttribute("Rest")
		local side = p.Name:match("_(Long)") or p.Name:match("_(Short)") or ""
		local w = WIPERS[side]
		if not p:IsA("BasePart") or typeof(rest) ~= "CFrame" or not w then
			continue
		end
		local wornHere = worn == true or worn == side
		local at = rest
		if pose == "lifted" then
			at = about(w.hinge, w.lift, w.liftDeg) * at -- (the lift is about the rest-pose hinge: before the swing)
		end
		if pose == "service" or pose == "lifted" then
			at = about(w.pivot, w.sweep, SERVICE_DEG) * at
		end
		place(car, p, at)
		local swapped = wornHere and mesh:FindFirstChild(p.Name .. "_Worn") ~= nil
		p.LocalTransparencyModifier = if p.Name:match("_Worn$") then (if wornHere then 0 else 1) elseif swapped then 1 else 0
	end
end

local function updateDecor()
	local cars = workspace:FindFirstChild("Cars")
	for _, car in (if cars then cars:GetChildren() else {}) do
		local decor = car:FindFirstChild("Decor")
		if not decor or not car:IsA("Model") then
			continue
		end
		local body = car:FindFirstChild("Body")
		-- (a body piece whose taken-apart 3D is live — NewBody — isn't made as one mesh at all)
		local bodyType = (car:GetAttribute("CarType") :: string?) or "Sedan"
		for _, piece in { "Shell", "Glass", "Chassis" } do
			if not PartGraph.lumpLive(bodyType, "Decor_" .. piece) then
				bodyMesh(car, decor, piece, if piece == "Chassis" then car.PrimaryPart else body and body:FindFirstChild(piece))
			end
		end
		-- the cracked lamp while the car is a wreck (bought, not finished yet)
		local wreck = car:GetAttribute("Wreck") == true or (car:GetAttribute("Restore") == true and not car:GetAttribute("Restored"))
		local crack = decorMesh(car, "Deco_HeadlightCrack")
		if crack then
			setShown(crack, wreck)
		end
		wipers(car)
		-- the kit's one extra (roof rack / spoiler: Decor_Extra_<Extra>, when baked), always drawn
		local extra = car:GetAttribute("Extra") :: string?
		if extra and extra ~= "None" then
			decorMesh(car, "Deco_Extra_" .. extra)
		end
		local hood = car:GetAttribute("HoodOpen") == true
		levels(car, decor, hood)
		local lift = ((car:GetAttribute("LiftOffset") :: number?) or 0) >= CarParts.type(car:GetAttribute("CarType") :: string?).LiftLevels[2].y - 0.05
		-- piece E: a live lump (PartGraph.lumpLive) shows the new bay instead — its fixed meshes (Decor_<lump>V2, and
		-- Decor_<lump>V2Under for what shows from below too: the engine mounts), and the part nodes this car doesn't
		-- take apart yet (P5 off) as fixed copies of <id>_Detail
		local typeName = (car:GetAttribute("CarType") :: string?) or "Sedan"
		local live: { [string]: boolean } = {}
		local bay3D = CarParts.bayOf(typeName)
		for _, lump in bay3D.lumps do
			if PartGraph.lumpLive(typeName, lump) then
				live[lump] = true
				-- (the bay's: with the hood open. The underside's — underbody_v1 — from below; its nodes seen from above
				-- too, the engine block / oil pan / alternator (show = both), in Decor_<lump>V2Both)
				local v2 = decorMesh(car, lump .. "V2")
				if v2 then
					-- (the body's — shell, glass, chassis, interior: no DecorShow rule — always)
					local rule = CarParts.DecorShow[lump]
					setShown(v2, if rule == "hood" then hood elseif rule == nil then true else lift)
					-- (the strut tower tops are the body's own metal: the car's paint — bake CarPaint)
					local color = paintOf(car)
					if color and v2:GetAttribute("PaintAs") ~= color then
						v2:SetAttribute("PaintAs", color)
						for _, m in v2:GetDescendants() do
							if m:IsA("MeshPart") and m:GetAttribute("CarPaint") then
								m.Color = color
							end
						end
					end
				end
				local both = decorMesh(car, lump .. "V2Both")
				if both then
					setShown(both, hood or lift)
				end
				local under = decorMesh(car, lump .. "V2Under")
				if under then
					setShown(under, hood or lift)
				end
			end
		end
		-- the body taken apart (NewBody): its old one-mesh pieces / blocks go — Mesh_Body_Shell / Glass / Chassis, the
		-- interior's two blocks (and their meshes, when baked)
		for lump, old in CarParts.BodyLumps do
			if live[lump] then
				for _, name in old do
					local inst = decor:FindFirstChild(name)
					if inst and name:sub(1, 5) == "Mesh_" then
						decorState[inst] = nil
						inst:Destroy() -- (our own local copy: gone, not hidden)
					elseif inst then
						setShown(inst, false) -- (the server's block)
					end
				end
			end
		end
		-- piece E2: a live corner lump (Generated/<type>Susp) draws its fixed nodes (Decor_Hub_FV2 / _RV2) and the old
		-- pieces it replaces go (Deco_Hub_FL / FR, the subframe — the 3D's `hides`), their dressed looks with them
		local susp = Car3DOf.susp(typeName)
		for _, lump in { "Deco_Hub_F", "Deco_Hub_R" } do
			if PartGraph.lumpLive(typeName, lump) then
				live[lump] = true
				local v2 = decorMesh(car, lump .. "V2")
				if v2 then
					setShown(v2, true)
				end
				for _, name in susp.hides[lump] or {} do
					local old = decor:FindFirstChild(name)
					for _, d in (if old then old:GetDescendants() else {}) do
						if d:IsA("BasePart") and d.LocalTransparencyModifier < 1 then
							d.LocalTransparencyModifier = 1
						end
					end
					if old and old:IsA("BasePart") then
						old.LocalTransparencyModifier = 1
					end
					live[name] = true -- (and not drawn by the DecorShow rules below: the subframe / rear axle)
				end
			end
		end
		-- (the front struts' 3 top nuts + cap are the strut's now: the bay's tower tops give way to Decor_StrutTowerE2, the
		-- same towers without them — suspension_v1 bay_patch; until it's baked the bay's stay)
		local towers = live.Deco_Hub_F and decorMesh(car, "Deco_StrutTowerE2")
		local bayV2 = decor:FindFirstChild("Mesh_Deco_EngineBayV2")
		if towers and bayV2 then
			setShown(towers, hood)
			local color = paintOf(car)
			if color and towers:GetAttribute("PaintAs") ~= color then
				towers:SetAttribute("PaintAs", color)
				for _, m in towers:GetDescendants() do
					if m:IsA("MeshPart") and m:GetAttribute("CarPaint") then
						m.Color = color
					end
				end
			end
			for _, m in bayV2:GetChildren() do
				if m:IsA("BasePart") and m.Name:match("^StrutTower_[LR]") and m.LocalTransparencyModifier < 1 then
					m.LocalTransparencyModifier = 1
				end
			end
		end
		if live.Deco_EngineBay then
			asideParts(car, hood)
		end
		if next(live) then
			local slots = CarParts.type(typeName).Slots
			for id, p in bay3D.parts do
				if CarParts.BayRows[id] and live[p.lump] and not slots[id] then
					local m = staticPart(car, id, p.pivot)
					if m then
						-- (when its lump's pieces show: the bay's with the hood open, the underside's from below — the oil
						-- door, the covers — the oil pan's both)
						local rule = CarParts.DecorShow[p.lump]
						setShown(m, if rule == "lift" then lift elseif rule == "both" then hood or lift else hood)
					end
				end
			end
		end
		for name, rule in CarParts.DecorShow do
			local block = decor:FindFirstChild(name)
			-- (a lump whose new 3D is live: its old one-piece mesh isn't made at all — gone, not see-through — and the
			-- server's stand-in block stays hidden: main 10-23 "숨김이 아니라 아예 안 그리기")
			if live[name] or live[CarParts.DecorInLump[name] or ""] then
				local old = decor:FindFirstChild("Mesh_" .. name)
				if old then
					decorState[old] = nil
					old:Destroy()
				end
				if block then
					setShown(block, false)
				end
				continue
			end
			local on = (rule == "hood" and hood) or (rule == "lift" and lift) or (rule == "both" and (hood or lift))
			local mesh = decorMesh(car, name)
			if mesh and name == "Deco_HoodProp" and mesh:GetAttribute("Up") ~= hood then
				-- the prop rod stands up under the open hood (about its hinge), lies stowed otherwise
				mesh:Destroy()
				decorState[mesh] = nil
				mesh = decorMesh(car, name, hood)
			end
			if mesh then
				setShown(mesh, on)
				if block then
					setShown(block, false) -- the 3D piece took over
				end
			elseif block then
				setShown(block, on)
			end
		end
	end
	for inst in decorState do
		if not inst.Parent then
			decorState[inst] = nil
		end
	end
end

function CarLook.start()
	for _, d in workspace:GetDescendants() do
		consider(d)
	end
	workspace.DescendantAdded:Connect(function(d)
		task.defer(consider, d) -- (a model's PrimaryPart may arrive a moment later)
	end)
	task.spawn(function()
		while true do
			update()
			updateDecor()
			task.wait(0.2)
		end
	end)
end

return CarLook
