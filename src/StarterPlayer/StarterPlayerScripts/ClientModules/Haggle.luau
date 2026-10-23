-- The showroom offer window (loop B step 3, flip_loop §5): the buyer's offer, the market value, their mood and
-- four choices — Accept / Counter +5% / Counter +10% (each with Likely / Maybe / Risky) / Decline. The server
-- decides (Remotes.HaggleChoice); it sends the window again after a turned-down counter, or nil to close it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)

local Haggle = {}

local frame: Frame
local title: TextLabel
local offer: TextLabel
local value: TextLabel
local note: TextLabel
local moodFill: Frame
local buttons: { [string]: TextButton } = {}

local CHANCE_COLOR = { Likely = Color3.fromRGB(46, 140, 70), Maybe = Color3.fromRGB(190, 140, 40), Risky = Color3.fromRGB(180, 70, 60) }

local function label(t: string, ts: number, color: Color3?, order: number): TextLabel
	local l = Instance.new("TextLabel")
	l.Text = t
	l.Size = UDim2.new(1, 0, 0, 0)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamBold
	l.TextSize = ts
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.LayoutOrder = order
	l.Parent = frame
	return l
end

local last: { [string]: any }? = nil
local function show(v: { [string]: any }?)
	last = v
	if not v then
		frame.Visible = false
		return
	end
	title.Text = Localizer.t("hg.title", { buyer = "@npc.Buyer" .. v.kind })
	offer.Text = Localizer.t("hg.offer", { price = v.offer })
	value.Text = Localizer.t("hg.value", { value = v.value, pct = v.pct, grade = "@grade." .. v.grade })
	note.Visible = v.refused == true
	note.Text = Localizer.t("hg.refused")
	moodFill.Size = UDim2.new(math.clamp(v.mood, 0, 1), 0, 1, 0)
	moodFill.BackgroundColor3 = if v.mood > 0.6 then Color3.fromRGB(90, 210, 110) elseif v.mood > 0.3 then Color3.fromRGB(240, 190, 60) else Color3.fromRGB(230, 80, 60)
	buttons.accept.Text = Localizer.t("hg.accept", { price = v.offer })
	buttons.c5.Text = Localizer.t("hg.counter", { price = v.ask5, chance = "@hg." .. v.c5 })
	buttons.c5.BackgroundColor3 = CHANCE_COLOR[v.c5]
	buttons.c10.Text = Localizer.t("hg.counter", { price = v.ask10, chance = "@hg." .. v.c10 })
	buttons.c10.BackgroundColor3 = CHANCE_COLOR[v.c10]
	frame.Visible = true
end

function Haggle.start()
	frame = Instance.new("Frame")
	frame.Name = "Haggle"
	-- bottom middle: between the phone joystick and the jump button
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.Position = UDim2.new(0.5, 0, 1, -8)
	frame.Size = UDim2.fromOffset(330, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundColor3 = Color3.fromRGB(34, 38, 46)
	frame.BackgroundTransparency = 0.05
	frame.Visible = false
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 12)
	c.Parent = frame
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10), UDim.new(0, 8), UDim.new(0, 10)
	pad.Parent = frame
	local ll = Instance.new("UIListLayout")
	ll.Padding = UDim.new(0, 4)
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	ll.Parent = frame
	frame.Parent = HUD.gui()
	title = label("", 16, Color3.fromRGB(150, 220, 255), 1)
	offer = label("", 20, Color3.fromRGB(255, 214, 90), 2)
	value = label("", 12, Color3.fromRGB(190, 196, 206), 3)
	-- the buyer's mood (same as the bar over their head)
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 6)
	bar.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
	bar.BorderSizePixel = 0
	bar.LayoutOrder = 4
	bar.Parent = frame
	moodFill = Instance.new("Frame")
	moodFill.BorderSizePixel = 0
	moodFill.Size = UDim2.new(1, 0, 1, 0)
	moodFill.Parent = bar
	note = label("", 12, Color3.fromRGB(255, 190, 90), 5)
	local grid = Instance.new("Frame")
	grid.BackgroundTransparency = 1
	grid.Size = UDim2.new(1, 0, 0, 72)
	grid.LayoutOrder = 6
	grid.Parent = frame
	local gl = Instance.new("UIGridLayout")
	gl.CellSize = UDim2.new(0.5, -3, 0, 34)
	gl.CellPadding = UDim2.fromOffset(6, 4)
	gl.SortOrder = Enum.SortOrder.LayoutOrder
	gl.Parent = grid
	for i, def in { { "accept", Color3.fromRGB(46, 140, 70) }, { "c5", Color3.fromRGB(46, 140, 70) }, { "c10", Color3.fromRGB(190, 140, 40) }, { "decline", Color3.fromRGB(110, 70, 66) } } do
		local b = Instance.new("TextButton")
		b.Name = def[1]
		b.LayoutOrder = i
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.TextWrapped = true
		b.TextColor3 = Color3.new(1, 1, 1)
		b.BackgroundColor3 = def[2]
		b.Text = Localizer.t("hg.decline")
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 8)
		bc.Parent = b
		b.Parent = grid
		b.Activated:Connect(function()
			frame.Visible = false
			Remotes.HaggleChoice:FireServer(def[1])
		end)
		buttons[def[1]] = b
	end
	Remotes.Haggle.OnClientEvent:Connect(show)
	Localizer.Changed.Event:Connect(function()
		buttons.decline.Text = Localizer.t("hg.decline")
		if frame.Visible and last then
			show(last)
		end
	end)
end

return Haggle
