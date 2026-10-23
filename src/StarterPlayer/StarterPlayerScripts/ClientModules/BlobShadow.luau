-- A soft round shadow on the floor under every character and customer while they're under a roof (board wr-builder
-- 10-22 evening: indoors the roof blocks the sun, and ceiling lights only cast shadows with Future lighting — too heavy
-- for phones). Four flat discs, darker in the middle; outdoors the sun's own shadow does it, so none there.
-- Local only, one set per humanoid, follows the floor below (a jump fades it); hidden with my own character in a work
-- view.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BlobShadow = {}

local RINGS = { { r = 0.75, t = 0.66 }, { r = 0.95, t = 0.8 }, { r = 1.12, t = 0.88 }, { r = 1.28, t = 0.94 } } -- (studs, a grown-up's size)
local MAX_DIST = 140 -- studs from the camera
local ROOF_UP = 80 -- a roof this far above counts as indoors

local folder: Folder
local blobs: { [Model]: { Part } } = {}
local down = RaycastParams.new()
down.FilterType = Enum.RaycastFilterType.Exclude
local up = RaycastParams.new()
up.FilterType = Enum.RaycastFilterType.Exclude

local function make(model: Model)
	if blobs[model] then
		return
	end
	local set = {}
	for i, ring in RINGS do
		local p = Instance.new("Part")
		p.Name = "Blob" .. i
		p.Shape = Enum.PartType.Cylinder
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = Enum.Material.SmoothPlastic
		p.Color = Color3.new(0, 0, 0)
		p.Transparency = 1
		p:SetAttribute("Base", ring.t)
		p:SetAttribute("R", ring.r)
		p.Parent = folder
		table.insert(set, p)
	end
	blobs[model] = set
	model.Destroying:Connect(function()
		for _, p in set do
			p:Destroy()
		end
		blobs[model] = nil
	end)
end

local function watch(model: Instance)
	if not model:IsA("Model") then
		return
	end
	if model:FindFirstChildOfClass("Humanoid") then
		make(model)
		return
	end
	-- (a character can arrive before its Humanoid: wait for it a little while)
	local conn: RBXScriptConnection
	conn = model.ChildAdded:Connect(function(c)
		if c:IsA("Humanoid") then
			conn:Disconnect()
			make(model)
		end
	end)
	task.delay(10, function()
		conn:Disconnect()
	end)
end

local function hide(set: { Part })
	for _, p in set do
		p.Transparency = 1
	end
end

local function update()
	local cam = workspace.CurrentCamera
	local ignore: { Instance } = { folder }
	for model in blobs do
		table.insert(ignore, model)
	end
	local cars = workspace:FindFirstChild("Cars")
	down.FilterDescendantsInstances = ignore
	-- (the roof test skips the cars too: under a car isn't indoors)
	local upIgnore = table.clone(ignore)
	if cars then
		table.insert(upIgnore, cars)
	end
	up.FilterDescendantsInstances = upIgnore
	for model, set in blobs do
		local root = model.Parent and model:FindFirstChild("HumanoidRootPart") :: BasePart?
		local head = model:FindFirstChild("Head") :: BasePart?
		if not root or (cam and (root.Position - cam.CFrame.Position).Magnitude > MAX_DIST) or (head and head.LocalTransparencyModifier > 0.9) then
			hide(set)
			continue
		end
		local hum = model:FindFirstChildOfClass("Humanoid")
		local floor = workspace:Raycast(root.Position, Vector3.new(0, -12, 0), down)
		local roof = workspace:Raycast(root.Position + Vector3.new(0, 2, 0), Vector3.new(0, ROOF_UP, 0), up)
		if not floor or not roof or (hum and hum.Sit) then
			hide(set)
			continue
		end
		local gap = root.Position.Y - floor.Position.Y - (if hum then hum.HipHeight + root.Size.Y / 2 else 2.5)
		local fade = math.clamp(1 - gap / 6, 0, 1) -- (in the air: smaller and lighter)
		local width = (model:GetScale() or 1) * (0.7 + 0.3 * fade)
		local at = CFrame.new(floor.Position + floor.Normal * (0.02)) * CFrame.Angles(0, 0, math.rad(90))
		for i, p in set do
			local r = width * (p:GetAttribute("R") :: number)
			p.Size = Vector3.new(0.02 + i * 0.004, r * 2, r * 2)
			p.CFrame = at * CFrame.new(i * 0.004, 0, 0)
			p.Transparency = 1 - (1 - (p:GetAttribute("Base") :: number)) * fade
		end
	end
end

function BlobShadow.start()
	folder = Instance.new("Folder")
	folder.Name = "BlobShadows"
	folder.Parent = workspace.CurrentCamera
	-- customers / Ella sit straight under workspace; players' characters too
	workspace.ChildAdded:Connect(function(c)
		task.defer(watch, c)
	end)
	for _, c in workspace:GetChildren() do
		watch(c)
	end
	local function onPlayer(p: Player)
		p.CharacterAdded:Connect(function(char)
			task.defer(watch, char)
		end)
		if p.Character then
			watch(p.Character)
		end
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in Players:GetPlayers() do
		onPlayer(p)
	end
	RunService.Heartbeat:Connect(function()
		pcall(update)
	end)
end

return BlobShadow
