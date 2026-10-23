-- While carrying a part: G drops it, and every empty slot that takes this kind of part gets a local "Install"
-- prompt plus a see-through ghost of where it goes. Pressing it asks the server (Remotes.Install), which checks.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)

local Carry = {}

local player = Players.LocalPlayer
local held: Instance? = nil
local prompts: { [string]: ProximityPrompt } = {} -- key = carId .. "/" .. slot
local ghosts: { [string]: BasePart } = {}
local dropButton: TextButton

function Carry.held(): Instance?
	return held
end

local function find(): Instance?
	local loose = workspace:FindFirstChild("LooseParts")
	for _, p in (if loose then loose:GetChildren() else {}) do
		if p:GetAttribute("CarriedBy") == player.UserId and p:GetAttribute("State") == "Carried" then
			return p
		end
	end
	return nil
end

local function slotEmpty(car: Model, slotName: string): boolean
	local slot = CarParts.Slots[slotName]
	local folder = car:FindFirstChild(CarParts.Kinds[slot.kind].group)
	local p = folder and folder:FindFirstChild(slotName)
	return not (p and p:GetAttribute("State") == "Installed")
end

local function clearPrompts(keep: { [string]: boolean }?)
	for key, p in prompts do
		if not (keep and keep[key]) then
			p:Destroy()
			prompts[key] = nil
			if ghosts[key] then
				ghosts[key]:Destroy()
				ghosts[key] = nil
			end
		end
	end
end

local function ghostFor(kind: string, snap: Attachment): BasePart
	-- a box the size of the part's main block, where it will sit
	local b = CarParts.Blocks[kind].pieces[1]
	local g = Instance.new("Part")
	g.Name = "InstallGhost"
	g.Anchored = true
	g.CanCollide = false
	g.CanQuery = false
	g.CanTouch = false
	g.CastShadow = false
	g.Material = Enum.Material.ForceField
	g.Color = Config.Colors.Good
	g.Transparency = 0.3
	g.Size = b.size
	if b.shape == "Cylinder" then
		g.Shape = Enum.PartType.Cylinder
	end
	local turn = if b.turn then CFrame.Angles(0, math.rad(90), 0) else CFrame.identity
	g.CFrame = snap.WorldCFrame * CFrame.new(b.offset) * turn
	g.Parent = workspace.CurrentCamera
	return g
end

local function refresh()
	held = find()
	dropButton.Visible = held ~= nil
	if not held then
		clearPrompts()
		return
	end
	local kind = held:GetAttribute("PartKind") :: string
	local cars = workspace:FindFirstChild("Cars")
	local want: { [string]: boolean } = {}
	for _, car in (if cars then cars:GetChildren() else {}) do
		local chassis = car:IsA("Model") and car.PrimaryPart
		if chassis then
			for _, snap in chassis:GetChildren() do
				local slotName = snap:GetAttribute("Slot") :: string?
				if snap:IsA("Attachment") and slotName and snap:GetAttribute("PartKind") == kind and slotEmpty(car :: Model, slotName) then
					local key = tostring(car:GetAttribute("CarId")) .. "/" .. slotName
					want[key] = true
					if not prompts[key] then
						local p = Instance.new("ProximityPrompt")
						p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
						p.Name = "InstallPrompt"
						Localizer.bind(p, "act.install")
						Localizer.bind(p, "part." .. kind, nil, "ObjectText")
						p.KeyboardKeyCode = Enum.KeyCode.E
						p.MaxActivationDistance = Config.PromptDistance
						p.RequiresLineOfSight = false
						p.Parent = snap
						p.Triggered:Connect(function()
							Remotes.Install:FireServer(car, slotName)
						end)
						prompts[key] = p
						ghosts[key] = ghostFor(kind, snap)
					else
						-- the car may have moved (lift): keep the ghost on its socket
						local b = CarParts.Blocks[kind].pieces[1]
						local turn = if b.turn then CFrame.Angles(0, math.rad(90), 0) else CFrame.identity
						ghosts[key].CFrame = snap.WorldCFrame * CFrame.new(b.offset) * turn
					end
				end
			end
		end
	end
	clearPrompts(want)
end

function Carry.start()
	-- G on a keyboard; this button for touch / everyone — the kit's orange button, as wide as its word (wr-ui: the old
	-- flat brown one was the only button not in the UI B look, test 2 ⑩)
	dropButton = UIKit.button(HUD.gui(), {
		name = "Drop",
		key = "btn.drop",
		style = "Orange",
		anchor = Vector2.new(1, 1),
		pos = UDim2.new(1, -24, 1, -150),
		max = 22,
		onClick = function()
			Remotes.Drop:FireServer()
		end,
	})
	UIKit.fitButton(dropButton, {
		height = function()
			return UIKit.buttonH(UIKit.px(0.13, 46, 56))
		end,
		text = 0.46,
		pad = 0.42,
		max = 22,
		min = 1.6,
	})
	dropButton.Visible = false
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.G and held then
			Remotes.Drop:FireServer()
		end
	end)
	task.spawn(function()
		while true do
			refresh()
			task.wait(0.15)
		end
	end)
	-- a part from the counter wears a small green NEW tag until it goes on a car, like a shop part still in its
	-- sticker: the old battery and the new one on the cart looked the same and the old one went back in (wr-gamer a08)
	local tags: { [Instance]: BillboardGui } = {}
	local function tag(part: Instance)
		local root = if part:IsA("BasePart") then part else (part :: Model).PrimaryPart
		local want = root ~= nil and part:GetAttribute("Fresh") == true and part:GetAttribute("State") == "Free"
		if want and not tags[part] then
			local b = Instance.new("BillboardGui")
			b.Name = "FreshTag"
			b.Adornee = root
			b.AlwaysOnTop = true
			b.LightInfluence = 0
			b.MaxDistance = 26
			b.Size = UDim2.fromOffset(46, 20)
			b.StudsOffsetWorldSpace = Vector3.new(0, (root :: BasePart).Size.Y / 2 + 0.6, 0)
			local l = Instance.new("TextLabel")
			l.Size = UDim2.fromScale(1, 1)
			l.BackgroundColor3 = Color3.fromRGB(62, 168, 84)
			l.TextColor3 = Color3.new(1, 1, 1)
			l.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Heavy)
			l.TextScaled = true
			UIKit.setText(l, "tag.new")
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 5)
			corner.Parent = l
			local pad = Instance.new("UIPadding")
			pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 2), UDim.new(0, 2)
			pad.Parent = l
			l.Parent = b
			b.Parent = player.PlayerGui
			tags[part] = b
		elseif not want and tags[part] then
			tags[part]:Destroy()
			tags[part] = nil
		end
	end
	local function watch(part: Instance)
		part:GetAttributeChangedSignal("Fresh"):Connect(function()
			tag(part)
		end)
		part:GetAttributeChangedSignal("State"):Connect(function()
			tag(part)
		end)
		part.AncestryChanged:Connect(function()
			if tags[part] and not part:IsDescendantOf(workspace) then
				tags[part]:Destroy()
				tags[part] = nil
			end
		end)
		tag(part)
	end
	UIKit.onLang(function()
		for _, b in tags do
			local l = b:FindFirstChildOfClass("TextLabel")
			if l then
				UIKit.setText(l, "tag.new")
			end
		end
	end)
	task.spawn(function()
		local loose = workspace:WaitForChild("LooseParts", 120)
		if loose then
			loose.ChildAdded:Connect(watch)
			for _, p in loose:GetChildren() do
				watch(p)
			end
		end
	end)
end

return Carry
