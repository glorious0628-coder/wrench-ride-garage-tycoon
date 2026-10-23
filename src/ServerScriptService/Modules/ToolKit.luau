-- The hand tools every mechanic starts with (block stand-ins until wr-3d tools): Wrench, Impact Wrench, Scanner.
-- Put in StarterPack, so every spawn gets them. The server checks which one is in the character's hand.

local StarterPack = game:GetService("StarterPack")

local ToolKit = {}

local function handle(size: Vector3, color: Color3, material: Enum.Material): Part
	local h = Instance.new("Part")
	h.Name = "Handle"
	h.Size = size
	h.Color = color
	h.Material = material
	h.CanCollide = false
	h.Massless = true
	h.TopSurface = Enum.SurfaceType.Smooth
	h.BottomSurface = Enum.SurfaceType.Smooth
	return h
end

local function deco(parentHandle: Part, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material)
	local p = handle(size, color, material)
	p.Name = name
	p.CFrame = parentHandle.CFrame * offset
	p.Parent = parentHandle
	local w = Instance.new("WeldConstraint")
	w.Part0 = parentHandle
	w.Part1 = p
	w.Parent = p
end

-- the 3D tools (ReplicatedStorage.CarMeshes.Tool_<mesh>, tools/bake_carmeshes.luau): grip from art/3d/tool_*/
-- *_attachments.json — pos / axis (up the grip) / secondary (where the tool points) in GLB axes, mesh bbox centre
local MESH_TOOLS = {
	Wrench = { mesh = "Tool_Wrench", pos = Vector3.new(-0.015, 0, 0), bbox = Vector3.new(0.0003, 0, 0.033), axis = Vector3.new(1, 0, 0), sec = Vector3.new(0, 0, -1) },
	ImpactWrench = { mesh = "Tool_ImpactWrench", pos = Vector3.new(0, 0.55, 0.1075), bbox = Vector3.new(0, 0.577, -0.109), axis = Vector3.new(0, 0.9824, -0.1867), sec = Vector3.new(0, -0.1867, -0.9824) },
	Scanner = { mesh = "Tool_OBDScanner", pos = Vector3.new(0, -0.22, 0), bbox = Vector3.new(0, 0.2725, -0.011), axis = Vector3.new(0, 1, 0), sec = Vector3.new(0, 0, -1) },
}

-- the mesh's own axes are the GLB ones turned 180° about Y (the import), so x and z swap sign
local function meshLocal(v: Vector3): Vector3
	return Vector3.new(-v.X, v.Y, -v.Z)
end

local function meshHandle(t: Tool, def: { [string]: any }): boolean
	local folder = game:GetService("ReplicatedStorage"):FindFirstChild("CarMeshes")
	local mesh = folder and folder:FindFirstChild(def.mesh) :: MeshPart?
	if not mesh then
		return false
	end
	local h = mesh:Clone()
	h.Name = "Handle"
	h.Anchored = false
	h.CanCollide = false
	h.Massless = true
	h.Parent = t
	-- Tool.Grip = the hand's grip frame in the handle: up = up the grip, look (-Z) = where the tool points
	local up = meshLocal(def.axis).Unit
	local back = -meshLocal(def.sec).Unit
	t.Grip = CFrame.fromMatrix(meshLocal(def.pos - def.bbox), up:Cross(back), up, back)
	return true
end

local function make(name: string, build: (Tool) -> ()): Tool
	local t = Instance.new("Tool")
	t.Name = name
	t.CanBeDropped = false
	t.RequiresHandle = true
	if not (MESH_TOOLS[name] and meshHandle(t, MESH_TOOLS[name])) then
		build(t) -- (block stand-in until its mesh is baked)
	end
	return t
end

-- the bought ones (Shared/Equipment HandTools) are built on demand and given to their owner
local builders: { [string]: (Tool) -> () } = {
	Wrench = function(t)
		local h = handle(Vector3.new(0.25, 0.25, 2.2), Color3.fromRGB(190, 192, 198), Enum.Material.Metal)
		h.Parent = t
		deco(h, "Jaw", Vector3.new(0.25, 0.6, 0.35), CFrame.new(0, 0, -1.2), Color3.fromRGB(190, 192, 198), Enum.Material.Metal)
		t.Grip = CFrame.new(0, 0, 0.5) * CFrame.Angles(math.rad(-90), 0, 0)
	end,
	RatchetWrench = function(t)
		local h = handle(Vector3.new(0.3, 0.3, 2.0), Color3.fromRGB(60, 62, 68), Enum.Material.Metal)
		h.Parent = t
		deco(h, "Head", Vector3.new(0.45, 0.45, 0.45), CFrame.new(0, 0, -1.1), Color3.fromRGB(200, 60, 50), Enum.Material.SmoothPlastic)
		t.Grip = CFrame.new(0, 0, 0.5) * CFrame.Angles(math.rad(-90), 0, 0)
	end,
	ImpactWrench = function(t)
		local h = handle(Vector3.new(0.5, 1.3, 0.6), Color3.fromRGB(30, 30, 34), Enum.Material.SmoothPlastic)
		h.Parent = t
		deco(h, "Body", Vector3.new(0.6, 0.6, 1.4), CFrame.new(0, 0.75, -0.4), Color3.fromRGB(240, 190, 30), Enum.Material.SmoothPlastic)
		deco(h, "Anvil", Vector3.new(0.25, 0.25, 0.5), CFrame.new(0, 0.75, -1.3), Color3.fromRGB(150, 150, 155), Enum.Material.Metal)
		t.Grip = CFrame.new(0, -0.2, 0)
	end,
	Stethoscope = function(t)
		local h = handle(Vector3.new(0.3, 0.3, 1.6), Color3.fromRGB(40, 40, 46), Enum.Material.SmoothPlastic)
		h.Parent = t
		deco(h, "Bell", Vector3.new(0.5, 0.5, 0.2), CFrame.new(0, 0, -0.9), Color3.fromRGB(200, 205, 212), Enum.Material.Metal)
		t.Grip = CFrame.new(0, 0, 0.4) * CFrame.Angles(math.rad(-90), 0, 0)
	end,
	PressureWasher = function(t) -- the restoration bay's wash wand (loop B)
		local h = handle(Vector3.new(0.3, 0.3, 2.6), Color3.fromRGB(240, 190, 30), Enum.Material.SmoothPlastic)
		h.Parent = t
		deco(h, "Grip", Vector3.new(0.35, 0.8, 0.35), CFrame.new(0, -0.4, 0.9), Color3.fromRGB(40, 40, 44), Enum.Material.SmoothPlastic)
		deco(h, "Nozzle", Vector3.new(0.2, 0.2, 0.5), CFrame.new(0, 0, -1.5), Color3.fromRGB(160, 162, 168), Enum.Material.Metal)
		t.Grip = CFrame.new(0, 0, 0.6) * CFrame.Angles(math.rad(-90), 0, 0)
	end,
	Scanner = function(t)
		local h = handle(Vector3.new(0.9, 1.3, 0.3), Color3.fromRGB(40, 44, 50), Enum.Material.SmoothPlastic)
		h.Parent = t
		deco(h, "Screen", Vector3.new(0.7, 0.6, 0.05), CFrame.new(0, 0.25, -0.16), Color3.fromRGB(60, 220, 120), Enum.Material.Neon)
		t.Grip = CFrame.new(0, -0.3, 0) * CFrame.Angles(math.rad(-20), 0, 0)
	end,
}

-- the new hand tools (Shared/PartData/Tools rows with a `block`): a stand-in from the row until Tool_<mesh> is baked
do
	local Tools = require(game:GetService("ReplicatedStorage").Shared.PartGraph).Tools
	for name, row in Tools do
		if row.block and not builders[name] then
			builders[name] = function(t)
				local b = row.block
				local h = handle(b.size, b.color, Enum.Material.SmoothPlastic)
				h.Parent = t
				if b.head then
					deco(h, "Head", b.head.size, CFrame.new(0, 0, b.head.at), b.head.color, Enum.Material.Metal)
				end
				t.Grip = CFrame.new(0, 0, b.size.Z * 0.25) * CFrame.Angles(math.rad(-90), 0, 0)
			end
		end
		if row.mesh and not MESH_TOOLS[name] and row.grip then
			MESH_TOOLS[name] = { mesh = "Tool_" .. row.mesh, pos = row.grip.pos, bbox = row.grip.bbox, axis = row.grip.axis, sec = row.grip.sec }
		end
	end
end

-- everyone starts with these (alpha_scope §3 Lv1: hand wrench + scanner)
ToolKit.Names = { "Wrench", "Scanner" }

function ToolKit.setup()
	for _, n in { "Wrench", "Scanner", "ImpactWrench", "RatchetWrench" } do
		local old = StarterPack:FindFirstChild(n)
		if old then
			old:Destroy()
		end
	end
	for _, n in ToolKit.Names do
		make(n, builders[n]).Parent = StarterPack
	end
end

-- a bought hand tool into this player's backpack, and their StarterGear so it comes back after a respawn
function ToolKit.give(player: Player, name: string)
	local build = builders[name]
	if not build then
		return
	end
	for _, holder in { player:FindFirstChildOfClass("Backpack"), player:FindFirstChild("StarterGear") } do
		if holder and not holder:FindFirstChild(name) then
			make(name, build).Parent = holder
		end
	end
end

-- the tool in the character's hand, or nil
function ToolKit.equipped(player: Player): string?
	local char = player.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	return if tool then tool.Name else nil
end

-- every tool this player has (in hand + backpack)
function ToolKit.owned(player: Player): { string }
	local out = {}
	for _, holder in { player.Character, player:FindFirstChildOfClass("Backpack") } do
		for _, t in (if holder then holder:GetChildren() else {}) do
			if t:IsA("Tool") and not table.find(out, t.Name) then
				table.insert(out, t.Name)
			end
		end
	end
	return out
end

-- put one of the player's own tools in their hand (the "picked for you" tool, full_teardown §4-1)
function ToolKit.equip(player: Player, name: string): boolean
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local backpack = player:FindFirstChildOfClass("Backpack")
	local tool = backpack and backpack:FindFirstChild(name)
	if char and char:FindFirstChild(name) then
		return true
	end
	if not hum or not tool or not tool:IsA("Tool") then
		return false
	end
	hum:EquipTool(tool)
	return true
end

-- the free tools (PartData/Tools `free`) once the garage level reaches them — only a tool some part on the cars
-- really needs (a fastener of CarParts.Blocks it undoes), so no tool comes before its job (full_teardown §4-2)
local function needed(name: string): boolean
	local CarParts = require(game:GetService("ReplicatedStorage").Shared.CarParts)
	local row = require(game:GetService("ReplicatedStorage").Shared.PartGraph).Tools[name]
	-- (only the parts a car type really has now — piece E's rows count once their lump is live)
	for typeName, ty in CarParts.Types do
		for slotName, slot in ty.Slots do
			local b = CarParts.blocksFor(slot.kind, slotName, typeName)
			for _, bolt in (if b then b.bolts else {}) do
				if table.find(row.does, bolt.f or "Bolt") then
					return true
				end
			end
		end
	end
	return false
end

function ToolKit.grantFree(player: Player): { string }
	local given = {}
	local level = (player:GetAttribute("Level") :: number?) or 1
	for name, row in require(game:GetService("ReplicatedStorage").Shared.PartGraph).Tools do
		if row.free and row.enabled ~= false and level >= (row.level or 1) and not table.find(ToolKit.owned(player), name) and needed(name) then
			ToolKit.give(player, name)
			table.insert(given, name)
		end
	end
	return given
end

return ToolKit
