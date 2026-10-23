-- The prompt card: our own look for every ProximityPrompt (user 10-21: "이런게 너무 복잡해보인다" — four grey boxes
-- with key letters and status words by the car). Roblox shows one prompt at a time (OneGlobally, wr-dev); this draws
-- that one as a small dark plate (kit B) above the thing: a yellow key badge ("E" on a keyboard, "Tap" on a phone)
-- and the action in one line. A hold prompt fills a yellow bar along the plate's bottom. No ObjectText line.
-- Drawn on the screen layer (moved to the thing every frame), so phone checks and photos show it.
-- Decision: notes/gpt/wr-ui/prompt_card_decision.md

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local Modules = script.Parent
local UIKit = require(Modules.UIKit)
local Localizer = require(Modules.Localizer)
local UIStyle = require(Modules.UIStyle)
local HUD = require(Modules.HUD)
local Tutorial = require(Modules.Tutorial)

local C = UIStyle.Color

local PromptUI = {}

local card: Frame
local badge: Frame
local keyLabel: TextLabel
local action: TextLabel
local fill: Frame
local current: ProximityPrompt? = nil
local holdTween: Tween? = nil

-- every prompt draws with this card instead of Roblox's grey box (local: the server's prompts stay Default there)
local function adopt(d: Instance)
	if d:IsA("ProximityPrompt") then
		d.Style = Enum.ProximityPromptStyle.Custom
	end
end

local function where(p: ProximityPrompt): Vector3?
	local a = p.Parent
	if a and a:IsA("Attachment") then
		return a.WorldPosition
	elseif a and a:IsA("BasePart") then
		return a.Position
	elseif a and a:IsA("Model") then
		return a:GetPivot().Position
	end
	return nil
end

-- the badge: the key on a keyboard / pad, "Tap" on a phone — "Hold" for a hold prompt (Pump, Hand back: "Tap" there
-- made phones tap and wonder) (the phone check counts as a phone)
local function keyText(p: ProximityPrompt, input: Enum.ProximityPromptInputType): (string?, string?)
	if input == Enum.ProximityPromptInputType.Touch or not UIKit.keyboard() and input ~= Enum.ProximityPromptInputType.Gamepad then
		return nil, if p.HoldDuration > 0 then "ui.prompt.hold" else "ui.prompt.tap"
	elseif input == Enum.ProximityPromptInputType.Gamepad then
		return (p.GamepadKeyCode.Name:gsub("^Button", "")), nil
	end
	local k = UIKit.keyboard() and p.KeyboardKeyCode or Enum.KeyCode.E
	local names = { One = "1", Two = "2", Three = "3", Four = "4", Five = "5" }
	return names[k.Name] or k.Name, nil
end

local function resetHold()
	if holdTween then
		holdTween:Cancel()
		holdTween = nil
	end
	fill.Size = UDim2.fromScale(0, 1)
end

-- the card's words: the action, and for a hold on a keyboard / pad "· hold" (the badge shows the key there, not "Hold"
-- like a phone's — wr-dev's 1.5 s Hand back without fixing read as one press: main 10-23)
local function actionWords(p: ProximityPrompt, input: Enum.ProximityPromptInputType): string
	local text = keyText(p, input)
	return if p.HoldDuration > 0 and text ~= nil then Localizer.t("ui.prompt.holdAction", { action = p.ActionText }) else p.ActionText
end
local shownInput = Enum.ProximityPromptInputType.Keyboard

local function show(p: ProximityPrompt, input: Enum.ProximityPromptInputType)
	current = p
	resetHold()
	local text, key = keyText(p, input)
	if key then
		UIKit.setText(keyLabel, key)
	else
		UIKit.setText(keyLabel, nil)
		keyLabel.Text = text or ""
	end
	shownInput = input
	action.Text = actionWords(p, input)
	fill.Parent.Visible = p.HoldDuration > 0
	card.Visible = true
end

local function hide(p: ProximityPrompt)
	if current == p then
		current = nil
		resetHold()
		card.Visible = false
	end
end

local function build()
	card = UIKit.plate(HUD.gui(), { name = "PromptCard", anchor = Vector2.new(0.5, 1), z = 4, kit = "slotWide", group = true }) :: any
	card.AutomaticSize = Enum.AutomaticSize.X
	card.Visible = false

	local row = Instance.new("Frame")
	row.Name = "Row"
	row.BackgroundTransparency = 1
	row.AutomaticSize = Enum.AutomaticSize.X
	row.Size = UDim2.fromScale(0, 1)
	row.ZIndex = 4
	row.Parent = card
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = row
	local pad = Instance.new("UIPadding")
	pad.Parent = row

	-- the yellow key badge (a key cap: dark letter on yellow)
	badge = Instance.new("Frame")
	badge.Name = "Key"
	badge.LayoutOrder = 1
	badge.BackgroundColor3 = C.Yellow
	badge.AutomaticSize = Enum.AutomaticSize.X
	badge.ZIndex = 4
	badge.Parent = row
	local bc = Instance.new("UICorner")
	bc.Parent = badge
	local bs = Instance.new("UIStroke")
	bs.Color = C.Outline
	bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bs.Parent = badge
	local bp = Instance.new("UIPadding")
	bp.Parent = badge
	keyLabel = Instance.new("TextLabel")
	keyLabel.Name = "Letter"
	keyLabel.BackgroundTransparency = 1
	keyLabel.FontFace = UIStyle.Font.Title
	keyLabel.TextColor3 = C.Ink
	keyLabel.AutomaticSize = Enum.AutomaticSize.X
	keyLabel.Size = UDim2.fromScale(0, 1)
	keyLabel.ZIndex = 4
	keyLabel.Parent = badge

	local gap = Instance.new("Frame")
	gap.Name = "Gap"
	gap.LayoutOrder = 2
	gap.BackgroundTransparency = 1
	gap.Parent = row

	-- the action, one line (words from the prompt: Locale.tag fills ActionText in the player's language)
	action = Instance.new("TextLabel")
	action.Name = "Action"
	action.LayoutOrder = 3
	action.BackgroundTransparency = 1
	action.FontFace = UIStyle.Font.Title
	action.TextColor3 = C.White
	action.AutomaticSize = Enum.AutomaticSize.X
	action.Size = UDim2.fromScale(0, 1)
	action.ZIndex = 4
	action.Text = ""
	action.Parent = row
	UIKit.outline(action)

	-- the hold bar: a thin yellow fill along the bottom, inside the rim
	local track = Instance.new("Frame")
	track.Name = "Hold"
	track.AnchorPoint = Vector2.new(0.5, 1)
	track.BackgroundColor3 = C.Black
	track.BackgroundTransparency = 0.3
	track.BorderSizePixel = 0
	track.ZIndex = 5
	track.Parent = card
	local ts = Instance.new("UIStroke") -- (the empty bar shows before the press: "this one fills" — main 10-23)
	ts.Color = C.Yellow
	ts.Transparency = 0.35
	ts.Thickness = 1
	ts.Parent = track
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = track
	fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = C.Yellow
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.ZIndex = 5
	fill.Parent = track
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = fill

	-- a phone presses the card itself (Roblox only does keys / pad buttons for a Custom prompt)
	local hit = Instance.new("TextButton")
	hit.Name = "Hit"
	hit.Text = ""
	hit.BackgroundTransparency = 1
	hit.Size = UDim2.fromScale(1, 1)
	hit.ZIndex = 6
	hit.Parent = card
	-- (a keyboard presses the key: the card lets mouse clicks through to what's under it — a bolt under the "Lower car"
	-- card was clicked and the car came down: test 2 TOP1)
	UIKit.bind(hit, function()
		hit.Visible = not UIKit.keyboard()
	end)
	local scale = Instance.new("UIScale")
	scale.Parent = card
	local A = UIStyle.Anim
	hit.InputBegan:Connect(function(io)
		local t = io.UserInputType
		if current and (t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1) then
			TweenService:Create(scale, TweenInfo.new(A.PressTime), { Scale = A.Press }):Play()
			current:InputHoldBegin()
		end
	end)
	hit.InputEnded:Connect(function(io)
		local t = io.UserInputType
		if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
			TweenService:Create(scale, TweenInfo.new(A.ReleaseTime, Enum.EasingStyle.Elastic), { Scale = 1 }):Play()
			if current then
				current:InputHoldEnd()
			end
		end
	end)

	UIKit.bind(card, function()
		-- (a thumb's size on a phone: the card is the button there; with a mouse it's a key, just the words' size —
		-- user 10-22: boxes fit the words)
		local h = UIKit.buttonH(UIKit.px(0.13, 46, 56))
		card.Size = UDim2.fromOffset(0, h)
		local text = math.floor(h * 0.46 + 0.5)
		action.TextSize = text
		keyLabel.TextSize = math.floor(h * 0.4 + 0.5)
		local b = math.floor(h * 0.6 + 0.5)
		badge.Size = UDim2.fromOffset(b, b)
		bc.CornerRadius = UDim.new(0, math.floor(b * 0.25))
		bs.Thickness = math.max(1, math.floor(h * 0.04))
		bp.PaddingLeft = UDim.new(0, math.floor(b * 0.2))
		bp.PaddingRight = UDim.new(0, math.floor(b * 0.2))
		keyLabel.Size = UDim2.new(0, b - 2 * math.floor(b * 0.2), 1, 0)
		gap.Size = UDim2.fromOffset(math.floor(h * 0.22), 1)
		-- (ends clear of the plate picture's corner bolts)
		pad.PaddingLeft = UDim.new(0, math.floor(h * 0.3))
		pad.PaddingRight = UDim.new(0, math.floor(h * 0.4))
		track.Size = UDim2.new(1, -math.floor(h * 0.9), 0, math.max(3, math.floor(h * 0.09)))
		track.Position = UDim2.new(0.5, 0, 1, -math.max(3, math.floor(h * 0.1)))
	end)
end

-- while the tutorial leads, only its own target speaks up: any other prompt's card steps back (GPT prompt_card_r1:
-- the strip's button, a card and the job card's button all at once read as three "next" things)
local function quiet(p: ProximityPrompt): boolean
	local player = Players.LocalPlayer
	local tut = player:GetAttribute("Tut") :: number?
	if tut == nil or tut >= 4 or player:GetAttribute("TutSkip") then
		return false
	end
	local target = Tutorial.target
	return not (target and (p.Parent == target or p:IsDescendantOf(target)))
end

-- follow the thing every frame; stay inside the play area (under the money bar row, over the tool bar)
local function follow()
	local p = current
	local cam = workspace.CurrentCamera
	-- (a window is up: the card would sit behind it; a work view: parts are tapped there, the card only sat over the
	-- bolts — rival_upgrade B2-5 #3)
	local covered = HUD.gui():GetAttribute("WindowOpen") or HUD.gui():GetAttribute("WorkView") or HUD.gui():GetAttribute("Minigame")
	if not p or not cam or not card then
		return
	end
	local pos = where(p)
	if not pos or covered then
		card.Visible = false
		return
	end
	local v, onScreen = cam:WorldToViewportPoint(pos)
	if not onScreen then
		card.Visible = false
		return
	end
	card.Visible = true
	;(card :: any).GroupTransparency = if quiet(p) then 0.55 else 0
	-- the tutorial's step has its own button: that's the one thing — another (dim) card goes (test 2 ⑩: the first screen
	-- showed "E Buy parts" beside "Try starting it")
	if quiet(p) then
		local strip = HUD.gui():FindFirstChild("TutorialTask", true)
		local try = strip and strip:FindFirstChild("TryCar", true) :: GuiObject?
		local order = strip and strip:FindFirstChild("Order", true) :: GuiObject?
		if (strip :: GuiObject?) and (strip :: GuiObject).Visible and ((try and try.Visible) or (order and order.Visible)) then
			card.Visible = false
			return
		end
	end
	local z = UIKit.zoom()
	local inset = GuiService:GetGuiInset()
	local parent = card.Parent :: GuiObject
	local rel = (Vector2.new(v.X, v.Y - inset.Y) - parent.AbsolutePosition) / z
	local size = UIKit.size()
	local w, h = card.AbsoluteSize.X / z, card.AbsoluteSize.Y / z
	local top = math.max(0, UIKit.barHeight() + 4 - UIKit.topInset()) + h + 6
	local bottom = size.Y - UIKit.hotbarHeight() - UIKit.hotbarGap() - 8
	-- (a prompt may ask for its card beside the point instead of over it — CurbUI's wiper close-up: over it, the card
	-- hid the blade to swap)
	local side = p:GetAttribute("CardSide")
	local wantX = if side == "right" then rel.X + w / 2 + 10 else rel.X
	local wantY = if side == "right" then rel.Y + h / 2 - 10 else rel.Y - 10 -- (10 up: clear of the tool bar, GPT r2)
	local x = math.clamp(wantX, w / 2 + 8, math.max(w / 2 + 8, size.X - w / 2 - 8))
	local y = math.clamp(wantY, top, math.max(top, bottom))
	-- a phone: never under a thumb (wr-gamer a20) — the walk stick (bottom left, ~150 wide, 140 up from the bottom) and
	-- the jump button (bottom right, ~120 wide, 100 up): a card there goes up out of it (measured on the 844x390 check)
	if not UIKit.keyboard() then
		for _, zone in { { 0, 150, 140 }, { size.X - 120, size.X, 100 } } do
			local zoneTop = size.Y - zone[3]
			if x + w / 2 > zone[1] and x - w / 2 < zone[2] and y > zoneTop then
				y = math.max(top, zoneTop - 6)
			end
		end
	end
	-- never over the yellow task strip, the job card or the quick job's card (wr-play test 1 #10: the card hid the
	-- step's words; a curb car's prompt often sits at the screen's top, where the quick job card is): step
	-- sideways off it first (they sit at a screen side), else under it, else over it
	for _, name in { "TutorialTask", "JobCard", "CurbCard", "MiniBalance", "MiniFill" } do
		local o = HUD.gui():FindFirstChild(name, true) :: GuiObject?
		if o and o.Visible then
			local lo = (o.AbsolutePosition - parent.AbsolutePosition) / z
			local hi = lo + o.AbsoluteSize / z
			if x + w / 2 > lo.X - 6 and x - w / 2 < hi.X + 6 and y > lo.Y - 6 and y - h < hi.Y + 6 then
				if lo.X - 6 - w / 2 >= w / 2 + 8 then
					x = lo.X - 6 - w / 2
				elseif hi.X + 6 + w / 2 <= size.X - w / 2 - 8 then
					x = hi.X + 6 + w / 2
				elseif hi.Y + 6 + h <= bottom then
					y = hi.Y + 6 + h
				elseif lo.Y - 6 >= top then
					y = lo.Y - 6
				end
			end
		end
	end
	card.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
end

function PromptUI.start()
	build()
	workspace.DescendantAdded:Connect(adopt)
	for _, d in workspace:GetDescendants() do
		adopt(d)
	end
	ProximityPromptService.PromptShown:Connect(show)
	ProximityPromptService.PromptHidden:Connect(hide)
	ProximityPromptService.PromptButtonHoldBegan:Connect(function(p)
		if p == current and p.HoldDuration > 0 then
			resetHold()
			holdTween = TweenService:Create(fill, TweenInfo.new(p.HoldDuration, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 1) })
			holdTween:Play()
		end
	end)
	ProximityPromptService.PromptButtonHoldEnded:Connect(function(p)
		if p == current then
			resetHold()
		end
	end)
	ProximityPromptService.PromptTriggered:Connect(function(p)
		if p == current then
			resetHold()
			UIKit.pop(card, 0.9)
		end
	end)
	-- the action words can change while it shows (Raise lift → Lower lift)
	RunService.RenderStepped:Connect(function()
		if current then
			local words = actionWords(current, shownInput)
			if action.Text ~= words then
				action.Text = words
				local track = fill.Parent :: GuiObject
				track.Visible = current.HoldDuration > 0
			end
			follow()
		end
	end)
	Players.LocalPlayer.CharacterRemoving:Connect(function()
		if current then
			hide(current)
		end
	end)
end

return PromptUI
