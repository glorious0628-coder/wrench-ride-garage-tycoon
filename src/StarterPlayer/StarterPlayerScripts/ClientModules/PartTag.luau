-- The part name tag in the work view (user 10-22: "내부도 마우스 갖다대거나 하면 이름 뜨게 하자"): what the pointer
-- is on, named in one small plate — a PC shows it beside the mouse after a short rest, a phone shows it where a
-- quick tap landed (1.6 s). One tag at a time. Names come from Locale only: part.<Kind> (a part's PartKind),
-- part.<Name> / deco.<Name> (the pieces with no kind: calipers, the engine, the dash ...), fastener.<Kind> (a bolt's
-- Fastener, with the part it holds: "Lug nut · Wheel"). A corner word is added for the four wheels / both ends
-- ("Brake Pads · front left"). Nothing found in Locale = no tag (a raw name never shows).
-- Looks and rules: notes/gpt/wr-ui/parttag_decision.md. Started by WorkViewUI.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local CarParts = require(game:GetService("ReplicatedStorage").Shared.CarParts)
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local PartGraph = require(game:GetService("ReplicatedStorage").Shared.PartGraph)
local Locale = require(game:GetService("ReplicatedStorage").Shared.Locale)
local Carry = require(script.Parent.Carry)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local PartTag = {}

local C = UIStyle.Color
local player = Players.LocalPlayer
local HOVER_REST = 0.12 -- (a mouse just passing over shows nothing)
local TAP_TIME = 1.6
local MOVE_PX = 8

local tag: Frame
local label: TextLabel
local shownFor: Instance? = nil
local shownUntil = math.huge -- (a tap's tag ends by itself; a hover's by moving off)
local pointer = Vector2.zero
local restSince = 0
local pressed = false
local lastCast = 0

local CORNER = { FL = true, FR = true, RL = true, RR = true, F = true, R = true }

local function has(key: string): boolean
	return Locale.en[key] ~= nil
end

-- outside parts everyone can name: no tag (user 10-22)
-- no tag on the car's body shell alone (user 10-22 evening: "bonnet, tyres in — just leave the body out"): every separate
-- part, inside part and fastener gets one. A part's attribute Tag = true / false still wins over this.
local WORLD_TOOLS = { BayCart = true, ToolChest = true, ToolCart = true, FloorJack = true, JackStand = true, Creeper = true, TireRack = true, Workbench = true, HoseReel = true, Vise = true, Pegboard = true, DrainPan = true }
local PLAIN_NAMES = { Shell = true }

local function plainKind(_kind: string): boolean
	return false
end

local function plainName(name: string): boolean
	local base = name:gsub("_(%u+)$", ""):gsub("^Deco_", "")
	return PLAIN_NAMES[base] == true
end

-- the garage's own tools and equipment lying about (jack, stands, creeper, tool chest …): a tag whenever the pointer
-- rests on one (Locale deco.<Name>); never the walls
local function worldTool(hit: Instance): string?
	if not hit:FindFirstAncestor("Garage") then
		return nil
	end
	local n: Instance? = hit
	while n and n ~= workspace do
		local base = n.Name:gsub("%d+$", "")
		if (n:IsA("Model") or n:IsA("BasePart")) and has("deco." .. base) and WORLD_TOOLS[base] then
			return "deco." .. base
		end
		n = n.Parent
	end
	return nil
end

-- what is this thing called: (key, args) or nil
local function describe(hit: Instance): (string?, { [string]: any }?)
	local carModel = hit:FindFirstAncestor("Cars") or hit:FindFirstAncestor("LooseParts")
	if not carModel or not HUD.gui():GetAttribute("WorkView") then
		-- (outside a work view only the garage's own tools speak; the car's parts wait for the work view)
		return worldTool(hit), nil
	end
	-- a bolt / nut / clip: its fastener kind, with the part it holds
	if hit:GetAttribute("Bolt") then
		local f = (hit:GetAttribute("Fastener") :: string?) or "Bolt"
		if not has("fastener." .. f) then
			return nil
		end
		local owner = hit.Parent
		while owner and owner ~= carModel and not owner:GetAttribute("PartKind") do
			owner = owner.Parent
		end
		local kind = owner and owner:GetAttribute("PartKind")
		-- (Features.ToolMatch) which tool turns it: "Hose clamp · Radiator — Hose Pliers" — the server puts the one
		-- you own in your hand when you press it; the tag says what that will be
		-- (only while I own nothing that turns it: with a fitting tool the tag stays short — GPT r1)
		local need = nil
		if Config.feature("ToolMatch") then
			local owned = {}
			for _, holder in { player:FindFirstChildOfClass("Backpack"), player.Character } do
				for _, t in (if holder then holder:GetChildren() else {}) do
					if t:IsA("Tool") then
						table.insert(owned, t.Name)
					end
				end
			end
			if not PartGraph.bestTool(owned, f) then
				need = PartGraph.neededTool(f)
			end
		end
		if kind and has("part." .. kind) and need and has("tool." .. need) then
			return "ui.tag.fastenerTool", { fastener = "@fastener." .. f, part = "@part." .. kind, tool = "@tool." .. need }
		end
		if kind and has("part." .. kind) then
			return "ui.tag.fastener", { fastener = "@fastener." .. f, part = "@part." .. kind }
		end
		return "fastener." .. f, nil
	end
	-- a part: climb to what has a kind (a wheel's tyre and rim count as the wheel), else name by its own name
	local n: Instance? = hit
	while n and n ~= carModel do
		local kind = n:GetAttribute("PartKind")
		-- (user 10-22: no tag on what everybody knows — body panels, tyres / wheels, glass, mirrors; the insides get
		-- one. A part row can say so itself: attribute Tag = true / false wins over this default)
		local want = n:GetAttribute("Tag")
		if want == false or (want == nil and ((kind and plainKind(kind)) or plainName(n.Name))) then
			return nil
		end
		local slot = (n:GetAttribute("Slot") :: string?) or n.Name
		local corner = slot:match("_(%u+)$")
		if kind and has("part." .. kind) then
			if corner and CORNER[corner] and has("where." .. corner) then
				return "ui.tag.at", { part = "@part." .. kind, where = "@where." .. corner }
			end
			return "part." .. kind, nil
		end
		-- a piece of the split engine bay / underside drawn fixed (Decor_<lump>V2: named by its 3D node id, or
		-- "<id>_<mesh>" when one node has several meshes): its kind from the 3D data — "Exhaust pipe", "Fuel tank" …
		-- (lumps_1023: every separate piece names itself, the fixed ones too)
		-- (the car's own type's 3D: workspace.Cars.<car> holds it)
		local holder: Instance? = n
		while holder and holder.Parent and holder.Parent ~= workspace:FindFirstChild("Cars") do
			holder = holder.Parent
		end
		local bay = CarParts.bayOf(holder and holder:GetAttribute("CarType") :: string?).parts
		local node = bay[n.Name] or bay[n.Name:match("^(.+)_[^_]+$") or ""]
		if not kind and node and has("part." .. node.kind) then
			return "part." .. node.kind, nil
		end
		local base = n.Name:gsub("_(%u+)$", "")
		for _, key in { "part." .. base, "deco." .. base:gsub("^Deco_", "") } do
			if has(key) then
				if corner and CORNER[corner] and has("where." .. corner) then
					return "ui.tag.at", { part = "@" .. key, where = "@where." .. corner }
				end
				return key, nil
			end
		end
		n = n.Parent
	end
	return nil
end

-- a tap that does something (WorkView.tap): a loose part is picked up, a held part is put down, a tool's bolt turns —
-- those taps say nothing (GPT r1: pickup and the hold ring win over the name)
local function tapDoesWork(hit: Instance): boolean
	if Carry.held() then
		return true
	end
	local owner: Instance? = hit
	while owner and not owner:GetAttribute("PartKind") do
		owner = owner.Parent
	end
	if owner and owner:GetAttribute("State") == "Free" then
		return true
	end
	if hit:GetAttribute("Bolt") then
		local char = player.Character
		return char ~= nil and char:FindFirstChildOfClass("Tool") ~= nil
	end
	return false
end

local function under(at: Vector2): Instance?
	local cam = workspace.CurrentCamera
	if not cam then
		return nil
	end
	-- (the pointer is over a button / window: the world behind it says nothing)
	local inset = GuiService:GetGuiInset()
	for _, g in (player:FindFirstChild("PlayerGui") :: PlayerGui):GetGuiObjectsAtPosition(at.X, at.Y - inset.Y) do
		if g:IsA("GuiButton") or (g :: GuiObject).Active then
			return nil
		end
	end
	local ray = cam:ViewportPointToRay(at.X, at.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character :: Instance }
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 60, params)
	return hit and hit.Instance
end

local function hide()
	shownFor = nil
	shownUntil = math.huge
	if tag then
		tag.Visible = false
	end
end

-- put the tag by a screen point (viewport px) for what's under it; `forSeconds` = a tap's
local function show(at: Vector2, forSeconds: number?)
	local hit = under(at)
	local key, args
	if hit and forSeconds and tapDoesWork(hit) then
		hide()
		return
	end
	if hit then
		key, args = describe(hit)
	end
	if not key then
		hide()
		return
	end
	if hit ~= shownFor or not tag.Visible then
		UIKit.setText(label, key, args)
	end
	shownFor = hit
	shownUntil = if forSeconds then os.clock() + forSeconds else math.huge
	tag.Visible = true
	local z = UIKit.zoom()
	local inset = GuiService:GetGuiInset()
	local root = tag.Parent :: GuiObject
	local rel = (Vector2.new(at.X, at.Y - inset.Y) - root.AbsolutePosition) / z
	local size = UIKit.size()
	local w, h = tag.AbsoluteSize.X / z, tag.AbsoluteSize.Y / z
	-- a mouse: beside the pointer, down-right (the cursor never hides it); a finger: above the fingertip
	local x, y
	if UIKit.keyboard() then
		x, y = rel.X + 16 + w / 2, rel.Y + 14 + h
	else
		x, y = rel.X, rel.Y - 46
	end
	x = math.clamp(x, w / 2 + 6, math.max(w / 2 + 6, size.X - w / 2 - 6))
	y = math.clamp(y, h + 6, math.max(h + 6, size.Y - 6))
	tag.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
end

local function build()
	tag = Instance.new("Frame")
	tag.Name = "PartTag"
	tag.AnchorPoint = Vector2.new(0.5, 1)
	tag.AutomaticSize = Enum.AutomaticSize.X
	tag.BackgroundColor3 = C.Plate
	tag.BorderSizePixel = 0
	tag.ZIndex = 12
	tag.Visible = false
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = tag
	local edge = Instance.new("UIStroke")
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Color = C.PlateEdge
	edge.Thickness = 1.5
	edge.Parent = tag
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
	pad.Parent = tag
	label = Instance.new("TextLabel")
	label.Name = "Label"
	label.AutomaticSize = Enum.AutomaticSize.X
	label.BackgroundTransparency = 1
	label.FontFace = UIStyle.Font.Bold
	label.TextColor3 = C.White
	label.ZIndex = 13
	label.Parent = tag
	UIKit.outline(label)
	tag.Parent = HUD.gui()
	UIKit.bind(tag, function()
		local size = UIKit.px(0.045, 14, 20)
		label.TextSize = size
		label.Size = UDim2.fromOffset(0, size + 8)
		tag.Size = UDim2.fromOffset(0, size + 8)
	end)
end

function PartTag.start()
	build()
	local gui = HUD.gui()
	local function inWork(): boolean
		return gui:GetAttribute("WorkView") == true
	end
	gui:GetAttributeChangedSignal("WorkView"):Connect(hide)
	gui:GetAttributeChangedSignal("WindowOpen"):Connect(hide)

	local function at(input: InputObject): Vector2
		return Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()
	end
	-- a phone: a quick tap that stayed put names what it touched (a tap that picks a part up still says its name)
	local downAt: Vector2? = nil
	local downTime = 0
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			downAt, downTime = at(input), os.clock()
			hide()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			pressed = true -- (a mouse press on a bolt = turning it: the tag steps aside)
			hide()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			local from = downAt
			downAt = nil
			if from and os.clock() - downTime < 0.4 and (at(input) - from).Magnitude <= MOVE_PX then
				show(from, TAP_TIME)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			pressed = false
			restSince = os.clock()
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local now = at(input)
			if (now - pointer).Magnitude > 2 then
				restSince = os.clock()
			end
			pointer = now
		end
	end)
	RunService.RenderStepped:Connect(function()
		if gui:GetAttribute("WindowOpen") == true then
			return -- (a window is up: no tags behind it)
		end
		if tag.Visible and os.clock() > shownUntil then
			hide()
			return
		end
		-- a mouse: rest on something and its name comes; move off and it goes (looked up ~12 times a second)
		if UIKit.keyboard() and not pressed and os.clock() - lastCast > 0.08 then
			lastCast = os.clock()
			local mouse = UserInputService:GetMouseLocation()
			if (mouse - pointer).Magnitude > 2 then
				pointer, restSince = mouse, os.clock()
			end
			if os.clock() - restSince >= HOVER_REST then
				local hit = under(pointer)
				if hit ~= shownFor or not tag.Visible then
					show(pointer)
				elseif tag.Visible then
					show(pointer) -- (follows the mouse inside the same part)
				end
			elseif tag.Visible and (under(pointer) ~= shownFor) then
				hide()
			end
		end
	end)
	-- Studio play-test hook only (a touch can't be made on a PC): player attribute DevTag = "x,y" taps there
	if RunService:IsStudio() then
		player:GetAttributeChangedSignal("DevTag"):Connect(function()
			local s = player:GetAttribute("DevTag")
			local x, y = tostring(s):match("^(%-?[%d%.]+),(%-?[%d%.]+)$")
			if x then
				show(Vector2.new(tonumber(x) :: number, tonumber(y) :: number), TAP_TIME)
			end
		end)
	end
end

return PartTag
