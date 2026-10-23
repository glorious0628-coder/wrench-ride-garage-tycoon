-- The midnight clock (halloween_pumpkin §4): a round wall clock face whose hands go 11:50 -> 12:00, as a chip with the
-- time beside it. It sits in the job card for Ella's car (no screen of its own: the tutorial strip is long gone by
-- then — the card is what you read while fixing) and in the scenes' top black bar, where it strikes 12 (Cinema.clock).
-- GPT 2 rounds: notes/gpt/wr-ui/ella_ui_decision.md. The face is the code look until wr-art's clock face picture is
-- uploaded (UIStyle.Image.ClockFace).
--   local c = MidnightClock.chip(parent, z)   c.set(minutes)  -- minutes past 11:00, 50..60 (60 = midnight)
--   c.frame                                    -- the row to place (width 2.7 × height)
--   MidnightClock.new(parent, size, z)         -- the dial alone

local TweenService = game:GetService("TweenService")

local UIStyle = require(script.Parent.UIStyle)

local MidnightClock = {}

local FACE = Color3.fromRGB(250, 246, 232)
local RIM = Color3.fromRGB(46, 40, 38)
local HAND = Color3.fromRGB(30, 28, 30)
local RED = Color3.fromRGB(214, 40, 32)

export type Clock = {
	frame: Frame,
	set: (minutes: number, instant: boolean?) -> (),
}

-- a hand: a bar whose bottom end sits on the centre, turned by Rotation (0 = up = 12)
local function hand(face: Frame, name: string, length: number, width: number, color: Color3, z: number): Frame
	local pivot = Instance.new("Frame")
	pivot.Name = name
	pivot.AnchorPoint = Vector2.new(0.5, 0.5)
	pivot.Position = UDim2.fromScale(0.5, 0.5)
	pivot.Size = UDim2.fromScale(1, 1)
	pivot.BackgroundTransparency = 1
	pivot.ZIndex = z
	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.AnchorPoint = Vector2.new(0.5, 1)
	bar.Position = UDim2.fromScale(0.5, 0.5 + width * 0.6) -- (a little past the centre, as real hands are)
	bar.Size = UDim2.fromScale(width, length)
	bar.BackgroundColor3 = color
	bar.BorderSizePixel = 0
	bar.ZIndex = z
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = bar
	bar.Parent = pivot
	pivot.Parent = face
	return pivot
end

function MidnightClock.new(parent: Instance, size: UDim2, z: number?): Clock
	local zi = z or 1
	local face = Instance.new("Frame")
	face.Name = "MidnightClock"
	face.Size = size
	face.BackgroundColor3 = FACE
	face.BorderSizePixel = 0
	face.ZIndex = zi
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.AspectRatio = 1
	ratio.Parent = face
	local art = UIStyle.Image.ClockFace
	if art and art ~= "" then
		face.BackgroundTransparency = 1
		local img = Instance.new("ImageLabel")
		img.Name = "Art"
		img.BackgroundTransparency = 1
		img.Size = UDim2.fromScale(1, 1)
		img.Image = art
		img.ZIndex = zi
		img.Parent = face
	else
		local round = Instance.new("UICorner")
		round.CornerRadius = UDim.new(1, 0)
		round.Parent = face
		local rim = Instance.new("UIStroke")
		rim.Color = RIM
		rim.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		rim.Parent = face
		face:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			rim.Thickness = math.max(2, face.AbsoluteSize.X * 0.07)
		end)
		-- the 12 marks: the hours as short bars, 12 thicker and red (where the hands are going)
		for k = 0, 11 do
			local p = Instance.new("Frame")
			p.Name = "Mark" .. k
			p.AnchorPoint = Vector2.new(0.5, 0.5)
			p.Position = UDim2.fromScale(0.5, 0.5)
			p.Size = UDim2.fromScale(1, 1)
			p.BackgroundTransparency = 1
			p.Rotation = k * 30
			p.ZIndex = zi
			local m = Instance.new("Frame")
			m.AnchorPoint = Vector2.new(0.5, 0)
			m.Position = UDim2.fromScale(0.5, 0.07)
			m.Size = UDim2.fromScale(if k == 0 then 0.09 else 0.05, if k % 3 == 0 then 0.14 else 0.08)
			m.BackgroundColor3 = if k == 0 then RED else HAND
			m.BorderSizePixel = 0
			m.ZIndex = zi
			m.Parent = p
			p.Parent = face
		end
	end
	local hour = hand(face, "Hour", 0.27, 0.085, HAND, zi + 1)
	local minute = hand(face, "Minute", 0.4, 0.06, RED, zi + 2)
	local hub = Instance.new("Frame")
	hub.Name = "Hub"
	hub.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.Position = UDim2.fromScale(0.5, 0.5)
	hub.Size = UDim2.fromScale(0.13, 0.13)
	hub.BackgroundColor3 = HAND
	hub.BorderSizePixel = 0
	hub.ZIndex = zi + 3
	local hc = Instance.new("UICorner")
	hc.CornerRadius = UDim.new(1, 0)
	hc.Parent = hub
	hub.Parent = face
	face.Parent = parent

	local shown = -1
	local function set(minutes: number, instant: boolean?)
		local m = math.clamp(minutes, 0, 60)
		if m == shown then
			return
		end
		shown = m
		-- 11:mm -> the minute hand at mm * 6°, the hour hand between 11 (330°) and 12 (360°)
		local goalMin = m * 6
		local goalHour = 330 + m * 0.5
		if instant then
			minute.Rotation, hour.Rotation = goalMin, goalHour
			return
		end
		-- a tick: a quick jump with a small overshoot, as a wall clock's hand does
		local tick = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(minute, tick, { Rotation = goalMin }):Play()
		TweenService:Create(hour, tick, { Rotation = goalHour }):Play()
	end
	set(50, true)
	return { frame = face, set = set }
end

export type Chip = {
	frame: Frame,
	set: (minutes: number, instant: boolean?) -> (),
}

-- the dial + the time beside it ("11:52", red "12:00" at midnight) in one row: the dial says "clock" at a glance, the
-- digits say how close (GPT ella_ui r1/r2 — the hand's 300°→354° travel alone doesn't read at 32 px). Its height
-- comes from the frame; width = 2.7 × height.
function MidnightClock.chip(parent: Instance, z: number?): Chip
	local zi = z or 1
	local row = Instance.new("Frame")
	row.Name = "MidnightChip"
	row.BackgroundTransparency = 1
	row.ZIndex = zi
	local dial = MidnightClock.new(row, UDim2.fromScale(1, 1), zi)
	dial.frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	local time = Instance.new("TextLabel")
	time.Name = "Time"
	time.AnchorPoint = Vector2.new(1, 0.5)
	time.Position = UDim2.fromScale(1, 0.5)
	time.Size = UDim2.fromScale(0.6, 0.62)
	time.BackgroundTransparency = 1
	time.FontFace = UIStyle.Font.Title
	time.TextColor3 = UIStyle.Color.Yellow
	time.TextXAlignment = Enum.TextXAlignment.Left
	time.TextScaled = true
	time.ZIndex = zi
	local stroke = Instance.new("UIStroke")
	stroke.Color = UIStyle.Color.Outline
	stroke.Thickness = 1.5
	stroke.Parent = time
	time.Parent = row
	local scale = Instance.new("UIScale")
	scale.Parent = time
	row.Parent = parent

	local shown = -1
	local function set(minutes: number, instant: boolean?)
		local m = math.clamp(math.floor(minutes), 0, 60)
		dial.set(m, instant)
		if m == shown then
			return
		end
		shown = m
		time.Text = if m >= 60 then "12:00" else string.format("11:%02d", m)
		time.TextColor3 = if m >= 60 then RED else UIStyle.Color.Yellow
		if m >= 60 and not instant then
			-- midnight: one 1.2× pop on the digits, in time with the bells
			scale.Scale = 1.2
			TweenService:Create(scale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end
	end
	set(50, true)
	return { frame = row, set = set }
end

return MidnightClock
