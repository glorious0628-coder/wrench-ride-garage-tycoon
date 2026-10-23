-- The stethoscope (fault_catalog '소리 찾기'): while it's in hand, wherever the pointer touches the car is where you
-- listen. A meter fills (and a ring pulses faster) the closer that spot is to a part making a noise — readable with
-- the sound off. Tapping asks the server to name the part (Remotes.Listen).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Faults = require(ReplicatedStorage.Shared.Faults)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local HUD = require(script.Parent.HUD)

local Listen = {}

local player = Players.LocalPlayer
local active = false
local pointer = Vector2.zero
local meter: Frame
local fill: Frame
local hitCar: Model? = nil
local hitPoint: Vector3? = nil
local nextPulse = 0

-- noisy slots on a car: worn parts / open issues whose variant makes a noise
local function noises(car: Model): { Vector3 }
	local out = {}
	for pair in ((car:GetAttribute("Variants") :: string?) or ""):gmatch("[^,]+") do
		local slot, id = pair:match("^(.-)=(.+)$")
		local v = id and Faults.ById[id]
		local kind = slot and CarParts.Slots[slot] and CarParts.Slots[slot].kind
		local folder = kind and car:FindFirstChild(CarParts.Kinds[kind].group)
		local part = folder and folder:FindFirstChild(slot)
		if v and v.noise and part and part:GetAttribute("State") == "Installed" then
			local worn = (part:GetAttribute("Condition") :: number) < Config.BrokenBelow
			if worn or car:GetAttribute("Issue_" .. slot) then
				local root = if part:IsA("BasePart") then part else (part :: Model).PrimaryPart
				if root then
					table.insert(out, root.Position)
				end
			end
		end
	end
	return out
end

local function pulse(at: Vector3, strength: number)
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = Color3.fromRGB(120, 200, 255)
	p.Transparency = 0.3
	p.Size = Vector3.one * 0.3
	p.Position = at
	p.Parent = workspace.CurrentCamera
	TweenService:Create(p, TweenInfo.new(0.35), { Size = Vector3.one * (0.6 + strength * 2), Transparency = 1 }):Play()
	task.delay(0.4, function()
		p:Destroy()
	end)
end

function Listen.setActive(on: boolean)
	active = on
	meter.Visible = on
end

function Listen.start()
	meter = Instance.new("Frame")
	meter.Name = "Stethoscope"
	meter.AnchorPoint = Vector2.new(0.5, 1)
	meter.Position = UDim2.new(0.5, 0, 1, -200)
	meter.Size = UDim2.fromOffset(260, 18)
	meter.BackgroundColor3 = Color3.fromRGB(30, 34, 42)
	meter.Visible = false
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = meter
	fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(120, 200, 255)
	fill.BorderSizePixel = 0
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(0, 8)
	fc.Parent = fill
	fill.Parent = meter
	meter.Parent = HUD.gui()

	local function at(input: InputObject): Vector2
		return Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()
	end
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			pointer = at(input)
		end
	end)
	UserInputService.InputBegan:Connect(function(input, processed)
		if not active or processed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pointer = at(input)
			task.defer(function()
				if hitCar and hitPoint then
					Remotes.Listen:FireServer(hitCar, hitPoint)
				end
			end)
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not active then
			return
		end
		local cars = workspace:FindFirstChild("Cars")
		local cam = workspace.CurrentCamera
		if not cars then
			return
		end
		local ray = cam:ViewportPointToRay(pointer.X, pointer.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = { cars }
		local hit = workspace:Raycast(ray.Origin, ray.Direction * 40, params)
		hitCar, hitPoint = nil, nil
		local strength = 0
		if hit then
			local n: Instance? = hit.Instance
			while n and n.Parent ~= cars do
				n = n.Parent
			end
			if n and n:IsA("Model") then
				hitCar, hitPoint = n, hit.Position
				for _, src in noises(n) do
					strength = math.max(strength, math.clamp(1 - (src - hit.Position).Magnitude / 9, 0, 1))
				end
			end
		end
		fill.Size = UDim2.new(strength, 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(120, 200, 255):Lerp(Color3.fromRGB(255, 120, 80), strength)
		-- a ring that pulses faster as you get closer
		if hitPoint and strength > 0.05 and os.clock() > nextPulse then
			pulse(hitPoint, strength)
			nextPulse = os.clock() + (0.9 - strength * 0.7)
		end
	end)
end

return Listen
