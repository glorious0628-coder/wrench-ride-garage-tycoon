-- The 3D floor jack (art/3d/floor_jack/floor_jack_attachments.json; baked: ReplicatedStorage.CarMeshes.Gear_FloorJack).
-- The map's block jacks (Placeholder3D = "FloorJack") become the 3D one, and JackService poses it: the arm swings up
-- about its hinge to the wanted saddle height, the saddle rides the arm tip but stays level, the handle pumps.
-- Jack axes: origin = ground under the frame, saddle toward -Z, handle toward +Z. Each part keeps its rest CFrame
-- (attribute Rest, jack space); a pose sets every part from the jack's origin.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JackLook = {}

local HINGE = CFrame.new(0, 0.86, 0.75)
local ARM_LEN = 1.948
local ARM_REST = -18.249
local ARM_MAX = 66
local STACK = 0.23 -- saddle pin -> saddle top
local PIN_REST = Vector3.new(0, 0.25, -1.1)
local HANDLE = CFrame.new(0, 0.87, 1.24)
JackLook.HANDLE_REST = 72 -- standing up (stored)
JackLook.HANDLE_PUMP = 40 -- the pumping stroke swings 32..48 about this

local function template(): Model?
	local lib = ReplicatedStorage:FindFirstChild("CarMeshes")
	local t = lib and lib:FindFirstChild("Gear_FloorJack")
	return if t and t:IsA("Model") then t else nil
end

function JackLook.is3D(m: Instance): boolean
	return m:GetAttribute("Jack3D") == true
end

-- the arm angle (deg above horizontal) that puts the saddle top at height h above the floor
local function armFor(h: number): number
	local s = math.clamp((h - STACK - HINGE.Y) / ARM_LEN, -1, 1)
	return math.clamp(math.deg(math.asin(s)), ARM_REST, ARM_MAX)
end

-- every part from the origin: arm angle a, handle elevation e
local function set(m: Model, origin: CFrame, a: number, e: number)
	local r = math.rad(a)
	local pin = HINGE.Position + Vector3.new(0, ARM_LEN * math.sin(r), -ARM_LEN * math.cos(r))
	for _, p in m:GetChildren() do
		local rest = p:GetAttribute("Rest")
		if p:IsA("BasePart") and typeof(rest) == "CFrame" then
			local cf = rest
			if p.Name == "Arm" then
				cf = HINGE * CFrame.Angles(math.rad(a - ARM_REST), 0, 0) * HINGE:Inverse() * rest
			elseif p.Name == "Saddle" then
				cf = rest + (pin - PIN_REST)
			elseif p.Name == "Handle" then
				cf = HANDLE * CFrame.Angles(math.rad(JackLook.HANDLE_REST - e), 0, 0) * HANDLE:Inverse() * rest
			end
			p.CFrame = origin * cf
		end
	end
	m.WorldPivot = origin
end

-- under a car: the saddle top on `at` (a floor point, the jack facing along its -Z) at height h, handle at e
-- (the saddle moves back toward the hinge as it rises: the jack's origin shifts so the saddle stays on the point)
function JackLook.place(m: Model, at: CFrame, h: number, e: number?)
	local a = armFor(h)
	local saddleZ = HINGE.Z - ARM_LEN * math.cos(math.rad(a))
	set(m, at * CFrame.new(0, 0, -saddleZ), a, e or JackLook.HANDLE_REST)
end

-- stored: arm down, handle up, origin here
function JackLook.rest(m: Model, origin: CFrame)
	set(m, origin, ARM_REST, JackLook.HANDLE_REST)
end

-- a block jack -> the 3D one (same name, place and attributes); its origin = 5.2 ahead of its UsePoint marker
local function swap(stand: Model): Model?
	local t = template()
	local use = stand:FindFirstChild("UsePoint")
	if not t or not use or not use:IsA("BasePart") or not stand.Parent then
		return nil
	end
	local m = t:Clone()
	m.Name = stand.Name
	for k, v in stand:GetAttributes() do
		m:SetAttribute(k, v)
	end
	m:SetAttribute("Placeholder3D", nil)
	m:SetAttribute("Jack3D", true)
	for _, p in m:GetChildren() do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = true -- (taps / prompts may still find it)
		end
	end
	use:SetAttribute("Rest", CFrame.new(0, 0, 5.2)) -- (keeps the stand-in's marker; it moves with the jack)
	use.Parent = m
	JackLook.rest(m, use.CFrame * CFrame.new(0, 0, -5.2))
	local parent = stand.Parent
	stand:Destroy()
	m.Parent = parent
	return m
end

function JackLook.start()
	if not template() then
		warn("[JackLook] no CarMeshes.Gear_FloorJack (bake tools/bake_carmeshes.luau): block jacks stay")
		return
	end
	local function check(d: Instance)
		if d:IsA("Model") and d:GetAttribute("Placeholder3D") == "FloorJack" then
			task.defer(swap, d) -- (after its parts are in)
		end
	end
	for _, d in workspace:GetDescendants() do
		check(d)
	end
	workspace.DescendantAdded:Connect(check) -- (bays bought later bring their own kit)
end

return JackLook
