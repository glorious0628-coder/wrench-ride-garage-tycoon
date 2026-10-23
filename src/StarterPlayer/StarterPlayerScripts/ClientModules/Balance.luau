-- The Wheel Balancer's timing gauge (Remotes.Minigame, MinigameService kind "Balance"; approved mock
-- notes/gpt/wr-ui/mock/balance_mock1.png + bal_part_*): a needle sweeps back and forth over a dial with a green zone;
-- tap (click / touch / Space / E) to stop it. The needle's motion comes from the server's start time and period, so
-- what you see is what the server judges; a tap only says "tap" (Remotes.MinigameInput: session id + a rising number) —
-- hit / miss / done come back from the server. Three pips show the progress (no numbers), a miss flashes "Almost!" and
-- rests the button, Auto (Settings, Lv 8+) runs by itself with a slim bar, the end is a green pill (Perfect +$ / Good /
-- Done for you) and the "keep doing this one myself" chip when the server asks. The plate, cue word, close button and
-- result are MiniFrame's (shared with Fill).
-- Studio test: player attribute "MgTest" = "bal" | "balauto" | "balperfect" | "balmiss" | "balgood".

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local MiniFrame = require(script.Parent.MiniFrame)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local Balance = {}

-- the gauge pictures (wr-art b3, art/ui/_check/ui_b3_README.md): a round dial with 9 ticks over ±52°, a needle
-- whose hub is the picture's centre, a green arc drawn about ±25° wide that we cut down to the real zone
local DIAL = "rbxassetid://110859836010821"
local NEEDLE = "rbxassetid://112141751931174"
local ZONE = "rbxassetid://91940259933364"
local SWING = 52 -- degrees each way: the needle's ends = the end ticks
local HUB = Vector2.new(628 / 1254, 616 / 1254)
local ARC = 355 / 1254 -- the green arc's outer radius (share of the dial picture)

local C = UIStyle.Color
local PIP_OFF = Color3.fromRGB(26, 30, 36)
local REST = 0.6 -- (the server rests the hand this long after a miss: StationService MISS_REST)
local AUTO_PERIOD = 1.6

local frame: any
local panel: Frame
local dial: ImageLabel
local zoneTurn: CanvasGroup
local zoneClip: Frame
local needle: ImageLabel
local tapButton: TextButton
local pipRow: Frame
local pips: { Frame } = {}
local autoTrack: Frame
local autoFill: Frame
local autoLabel: TextLabel
local state: {
	id: any,
	t0: number,
	period: number,
	zone: number,
	width: number,
	need: number,
	hits: number,
	seq: number,
	auto: boolean,
	seconds: number,
	restUntil: number,
	finished: boolean,
}? = nil

-- the bottom of the plate in its three states (mock bal_part_*): playing = pips left + the Tap button; Auto = pips
-- centred over a full-width slim bar; done = pips centred alone (the title line goes)
local function layout(mode: string)
	local centred = mode ~= "play"
	pipRow.AnchorPoint = Vector2.new(0.5, 0.5)
	pipRow.Position = UDim2.fromScale(if centred then 0.5 else 0.31, if mode == "auto" then 0.795 else 0.885)
	pipRow.Size = UDim2.fromScale(0.32, if mode == "auto" then 0.12 else 0.17)
	autoTrack.Visible = mode == "auto"
	tapButton.Visible = mode == "play"
end

local function setPips(hits: number, need: number)
	for i, pip in pips do
		pip.Visible = i <= need
		local on = i <= hits
		pip.BackgroundColor3 = if on then C.Green else PIP_OFF
		local tick = pip:FindFirstChild("Tick") :: GuiObject?
		if tick then
			tick.Visible = on
		end
		local stroke = pip:FindFirstChildOfClass("UIStroke") :: UIStroke?
		if stroke then
			stroke.Color = if on then C.GreenDark else Color3.fromRGB(110, 118, 128)
		end
	end
end

local function place()
	if not state then
		return
	end
	local x, zone, width
	if state.auto then
		-- Auto: the needle sweeps by itself, the green stays in the middle, the pips + the bar follow the clock
		local t = os.clock() - state.t0
		x = (t / AUTO_PERIOD) % 1
		zone, width = 0.5, Config.BalanceZone
		local share = math.clamp(t / state.seconds, 0, 1)
		autoFill.Size = UDim2.fromScale(math.max(share, 0.02), 1)
		autoLabel.Text = tostring(math.floor(share * 100 + 0.5)) .. "%"
		local hits = math.floor(share * state.need + 0.5)
		if hits ~= state.hits then
			state.hits = hits
			setPips(hits, state.need)
		end
	else
		x = ((workspace:GetServerTimeNow() - state.t0) / state.period) % 1
		zone, width = state.zone, state.width
	end
	local p = if x < 0.5 then x * 2 else 2 - x * 2
	needle.Rotation = -SWING + 2 * SWING * p
	-- the green: turned to its middle, cut to its width (a vertical strip through the hub, inside the turned group)
	zoneTurn.Rotation = -SWING + 2 * SWING * zone
	local half = math.rad(SWING * width)
	zoneClip.Size = UDim2.fromScale(2 * ARC * math.sin(half), 1)
end

local function flash(color: Color3)
	dial.ImageColor3 = color
	TweenService:Create(dial, TweenInfo.new(0.3), { ImageColor3 = Color3.new(1, 1, 1) }):Play()
end

local function dimTap(t: number)
	local face = tapButton:FindFirstChild("Face") :: Frame?
	if face then
		face.BackgroundTransparency = t
		local label = face:FindFirstChild("Label") :: TextLabel?
		if label then
			label.TextTransparency = t * 0.7
		end
	end
end

local function tap()
	if state and not state.auto and not state.finished and os.clock() >= state.restUntil then
		state.seq += 1
		Remotes.MinigameInput:FireServer(state.id, state.seq, "tap")
	end
end

local function image(parent: Instance, id: string, name: string): ImageLabel
	local i = Instance.new("ImageLabel")
	i.Name = name
	i.BackgroundTransparency = 1
	i.Image = id
	i.ScaleType = Enum.ScaleType.Fit
	i.Parent = parent
	return i
end

-- the miss: the rim flashes, the line says why ("Almost! Try again"), the button rests (dim) for the server's rest time
local function missed()
	if not state then
		return
	end
	state.restUntil = os.clock() + REST
	flash(Color3.fromRGB(235, 70, 60))
	frame:notice("mg.balance.almost", REST, if state.auto then "mg.balance.auto" else "mg.balance")
	UIKit.setButton(tapButton, nil, "Green", true) -- (still green, just faded: it is only resting, not locked)
	dimTap(0.6)
	local my = frame.token
	task.delay(REST, function()
		if my == frame.token and state and not state.finished then
			UIKit.setButton(tapButton, nil, "Green", false)
			dimTap(0)
		end
	end)
end

local function showResult(grade: string, tip: number?, auto: boolean?, keepable: boolean?)
	if not state then
		return
	end
	state.finished = true
	setPips(state.need, state.need)
	layout("done")
	flash(Color3.fromRGB(120, 235, 140))
	frame:finish(grade, tip, auto, keepable, { perfect = "mg.balance.perfect", good = "mg.balance.good" }, function()
		state = nil
	end)
end

local function open(auto: boolean, data: { [string]: any })
	local st = {
		id = data.id,
		t0 = if auto then os.clock() else data.t0,
		period = data.period or AUTO_PERIOD,
		zone = data.zone or 0.5,
		width = data.width or Config.BalanceZone,
		need = data.need or 3,
		hits = 0,
		seq = 0,
		auto = auto,
		seconds = data.seconds or 4.5,
		restUntil = 0,
		finished = false,
	}
	state = st
	setPips(0, st.need)
	layout(if auto then "auto" else "play")
	UIKit.setButton(tapButton, nil, "Green", false)
	dimTap(0)
	dial.ImageColor3 = Color3.new(1, 1, 1)
	-- (the one-word cue: the needle already runs; a tap in the first 0.6 s counts)
	frame:open(if auto then nil else "mg.cue.tap", if auto then "mg.balance.auto" else "mg.balance")
end

function Balance.start()
	frame = MiniFrame.new({
		name = "MiniBalance",
		kind = "Balance",
		reserve = 52,
		ratio = 0.95, -- (a ~236 px plate: wr-uidesign A②; the dial got bigger, not the plate)
		titleKey = "mg.balance",
		onLeave = function()
			if state and not state.auto then
				state.seq += 1
				Remotes.MinigameInput:FireServer(state.id, state.seq, "quit")
			end
			state = nil
			frame:hide()
			HUD.notify("mg.left", nil, "info")
		end,
	})
	panel = frame.panel
	-- the dial: the upper part of a round gauge is all that moves, so the picture's lower third hides under the row
	local window = Instance.new("Frame")
	window.Name = "Gauge"
	window.BackgroundTransparency = 1
	window.ClipsDescendants = true
	window.AnchorPoint = Vector2.new(0.5, 0)
	window.Position = UDim2.fromScale(0.5, 0.17)
	window.Size = UDim2.fromScale(0.74, 0.58)
	window.Parent = panel
	dial = image(window, DIAL, "Dial")
	dial.AnchorPoint = Vector2.new(0.5, 0)
	dial.Position = UDim2.fromScale(0.5, 0)
	dial.Size = UDim2.fromScale(1, 1)
	local square = Instance.new("UIAspectRatioConstraint")
	square.Parent = dial
	zoneTurn = Instance.new("CanvasGroup")
	zoneTurn.Name = "ZoneTurn"
	zoneTurn.BackgroundTransparency = 1
	zoneTurn.AnchorPoint = HUB
	zoneTurn.Position = UDim2.fromScale(HUB.X, HUB.Y)
	zoneTurn.Size = UDim2.fromScale(1, 1)
	zoneTurn.Parent = dial
	zoneClip = Instance.new("Frame")
	zoneClip.Name = "Clip"
	zoneClip.BackgroundTransparency = 1
	zoneClip.ClipsDescendants = true
	zoneClip.AnchorPoint = Vector2.new(0.5, 0)
	zoneClip.Position = UDim2.fromScale(HUB.X, 0)
	zoneClip.Parent = zoneTurn
	local green = image(zoneClip, ZONE, "Zone")
	green.AnchorPoint = Vector2.new(0.5, 0)
	green.Position = UDim2.fromScale(0.5, 0)
	-- (the arc picture keeps the dial's size while the strip around it narrows)
	zoneClip:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local w = zoneTurn.AbsoluteSize.X
		green.Size = UDim2.new(0, w, 1, 0)
	end)
	needle = image(dial, NEEDLE, "Needle")
	needle.AnchorPoint = Vector2.new(0.5, 0.5)
	needle.Position = UDim2.fromScale(HUB.X, HUB.Y)
	needle.Size = UDim2.fromScale(0.79, 0.79) -- (the tip then reaches the ticks' ends)
	needle.ZIndex = 3
	-- (the pictures first: the first open must not show an empty dial)
	task.spawn(function()
		game:GetService("ContentProvider"):PreloadAsync({ dial, needle, green })
	end)

	-- three pips (the progress; no numbers): green with a check = done, a dark ring = still to do
	local row = Instance.new("Frame")
	row.Name = "Pips"
	row.BackgroundTransparency = 1
	row.AnchorPoint = Vector2.new(0.5, 0.5)
	row.Position = UDim2.fromScale(0.31, 0.885)
	row.Size = UDim2.fromScale(0.32, 0.17)
	row.Parent = panel
	pipRow = row
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.Padding = UDim.new(0.07, 0)
	list.Parent = row
	for i = 1, 3 do
		local pip = Instance.new("Frame")
		pip.Name = "Pip" .. i
		pip.BackgroundColor3 = PIP_OFF
		pip.BorderSizePixel = 0
		pip.LayoutOrder = i
		pip.Size = UDim2.fromScale(0.28, 0.9)
		local ar = Instance.new("UIAspectRatioConstraint")
		ar.Parent = pip
		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(1, 0)
		pc.Parent = pip
		local ps = Instance.new("UIStroke")
		ps.Thickness = 2.5
		ps.Color = Color3.fromRGB(110, 118, 128)
		ps.Parent = pip
		local tick = UIKit.icon(pip, UIStyle.Icon.Check, { name = "Tick", size = UDim2.fromScale(0.62, 0.62) })
		if tick then
			tick.ZIndex = 2
			tick.Visible = false
		end
		pip.Parent = row
		pips[i] = pip
	end

	tapButton = UIKit.button(panel, { name = "Tap", key = "mg.tap", style = "Green", anchor = Vector2.new(1, 0.5), pos = UDim2.new(0.87, 0, 0.86, 0), size = UDim2.fromScale(0.37, 0.22), max = 24, onClick = tap }) -- (clear of the corner bolt: the longer Korean word "톡 누르기" ran onto it on 667x375)
	-- the tap finger (the same picture as the scrub's cursor, UIStyle.Icon.ScrubFinger) in front of the word, once it is uploaded
	local finger = UIKit.icon(tapButton, (UIStyle.Icon :: any).ScrubFinger, { name = "Finger", anchor = Vector2.new(0, 0.5), pos = UDim2.fromScale(0.06, 0.45), size = UDim2.fromScale(0.34, 0.8) })
	if finger then
		finger.ZIndex = tapButton.ZIndex + 3
		local label = (tapButton:FindFirstChild("Face") :: Frame):FindFirstChild("Label") :: TextLabel
		label.Position = UDim2.fromScale(0.64, 0.5)
		label.Size = UDim2.fromScale(0.56, 0.74)
	end
	-- Auto: a slim bar + its % where the button was
	autoTrack = Instance.new("Frame")
	autoTrack.Name = "AutoBar"
	autoTrack.AnchorPoint = Vector2.new(0.5, 0.5)
	autoTrack.Position = UDim2.fromScale(0.5, 0.93)
	autoTrack.Size = UDim2.fromScale(0.72, 0.075)
	autoTrack.BackgroundColor3 = C.PlateLight
	autoTrack.BorderSizePixel = 0
	autoTrack.Visible = false
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = autoTrack
	local ts = Instance.new("UIStroke")
	ts.Color = C.Outline
	ts.Thickness = 2
	ts.Parent = autoTrack
	autoTrack.Parent = panel
	autoFill = Instance.new("Frame")
	autoFill.Name = "Fill"
	autoFill.BackgroundColor3 = C.Green
	autoFill.BorderSizePixel = 0
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = autoFill
	autoFill.Parent = autoTrack
	autoLabel = UIKit.text(autoTrack, { name = "Percent", text = "0%", font = "Title", anchor = Vector2.new(1, 0.5), pos = UDim2.new(1, -10, 0.5, 0), size = UDim2.fromScale(0.2, 1.7), alignX = Enum.TextXAlignment.Right, max = 18, z = 3 })

	UserInputService.InputBegan:Connect(function(input, processed)
		if state and not processed and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E) then
			tap()
		end
	end)
	Remotes.Minigame.OnClientEvent:Connect(function(what, data)
		if what == "start" and data then
			open(false, data)
		elseif what == "auto" and data and (data.kind == nil or data.kind == "Balance") then
			open(true, data)
		elseif what == "hit" and state and not state.auto then
			state.hits = data.hits
			state.zone = data.zone
			state.width = data.width or state.width
			setPips(state.hits, state.need)
			flash(Color3.fromRGB(80, 210, 110))
		elseif what == "miss" and state and not state.auto then
			state.width = (data and data.width) or state.width
			missed()
		elseif what == "done" and state and (data == nil or data.kind == nil or data.kind == "Balance") then
			showResult(if data and data.grade then data.grade else "Good", data and data.tip, data and data.auto, data ~= nil and data.ask ~= nil)
		elseif what == "stop" and state then
			state = nil
			frame:hide()
		end
	end)
	RunService.RenderStepped:Connect(place)

	-- Studio only: draw the screen with no server (player attribute MgTest)
	if RunService:IsStudio() then
		local player = game:GetService("Players").LocalPlayer
		local function begin()
			open(false, { id = "test", t0 = workspace:GetServerTimeNow(), period = 1.6, zone = 0.5, width = Config.BalanceZone, need = 3 })
		end
		player:GetAttributeChangedSignal("MgTest"):Connect(function()
			local t = player:GetAttribute("MgTest")
			if t == "bal" then
				begin()
				if state then
					state.hits = 1
				end
				setPips(1, 3)
			elseif t == "balauto" then
				open(true, { id = "test", seconds = 4.5, need = 3 })
			elseif t == "balmiss" then
				begin()
				if state then
					state.hits = 1
				end
				setPips(1, 3)
				missed()
			elseif t == "balperfect" then
				begin()
				showResult("Perfect", 15, false, false)
			elseif t == "balgood" then
				begin()
				showResult("Good", nil, true, true)
			end
		end)
	end
end

return Balance
