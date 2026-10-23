-- Mini-game frame ② "hold to fill, let go in the band" (docs/design/minigames_launch_set.md: Coolant Fill, Tire Fill;
-- Torque Click reuses it with another skin). Approved mocks: notes/gpt/wr-ui/mock/fill_mock2.png (centre axis) + fill2_*1.png.
-- A tall tube on the plate's centre axis, a liquid / air column rising while the big Hold button (or Space / E) is held,
-- ONE target band across the tube (flag on the right, a matching arrow on the left), the one-word cue first ("Pour!"),
-- a reason line when it misses ("Not enough" / "Too full!"), the green result pill, the close button. The screen only
-- DRAWS a guess of the level (the rate the server sent) and sends what the hand did; the server judges from the time
-- it received "down" / "up" and answers with the real level.
--
-- Signals (docs: board [10-22 밤] wr-ui "채우기 신호"; MinigameService kind = Coolant | Tire | ...):
--   server -> client  Remotes.Minigame:
--     "fill"  { id, kind = "Coolant" | "Tire" | "Torque", lo, hi, rate, level?, liquid = "pink" | "air" | "steel", label?, unit?, max? }
--             lo..hi = the band (0..1 of the tube's height), rate = level per second while held, label = the flag's
--             words (nil = "FULL"), unit/max = a live number by the level on the left ("31" of max 50 PSI)
--     "miss"  { reason = "under" | "over", level }   -- under: the level stays (hold again to add more); over: level = where it falls to
--     "auto"  { id, kind, seconds }                   -- Lv 8+ Auto: fills itself, ends 'Good' (the usual "done")
--     "done"  { id, kind, grade = "Perfect" | "Good", tip?, auto?, ask?, level? }
--     "stop"  { id }
--   client -> server  Remotes.MinigameInput:FireServer(id, seq, "down" | "up" | "quit")
-- Studio test: player attribute "MgTest" = "fill" | "fillauto" | "fillunder" | "fillover" | "fillperfect" | "filltire".

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local MiniFrame = require(script.Parent.MiniFrame)
local HUD = require(script.Parent.HUD)
local SoundPlayer = require(script.Parent.SoundPlayer)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local Fill = {}

local C = UIStyle.Color
local LIQUID = {
	pink = Color3.fromRGB(255, 84, 170), -- (Camry's coolant is pink)
	air = Color3.fromRGB(150, 208, 255),
	steel = Color3.fromRGB(214, 220, 228),
}
-- one skin per kind: the words (cue / title / the two reasons / auto line / the result) and the flag's default word
local KINDS: { [string]: { cue: string, title: string, auto: string, under: string, over: string, flag: string, good: string, perfect: string } } = {
	Coolant = { cue = "mg.cue.pour", title = "mg.fill", auto = "mg.fill.auto", under = "mg.fill.under", over = "mg.fill.over", flag = "mg.fill.full", good = "mg.fill.good", perfect = "mg.fill.perfect" },
	Tire = { cue = "mg.cue.fill", title = "mg.fill", auto = "mg.fill.auto", under = "mg.fill.under", over = "mg.fill.over", flag = "mg.fill.full", good = "mg.fill.good", perfect = "mg.fill.perfect" },
	-- Torque Click (wheel nuts): pull the torque wrench until it CLICKS and let go right after (the band = the click)
	Torque = { cue = "mg.cue.pull", title = "mg.pull", auto = "mg.pull.auto", under = "mg.pull.early", over = "mg.pull.over", flag = "mg.pull.click", good = "mg.pull.good", perfect = "mg.pull.perfect" },
}
local REST = 0.6

local frame: any
local panel: Frame
local tube: Frame
local liquidBar: Frame
local band: Frame
local flagRight: Frame
local flagText: TextLabel
local markLeft: Frame
local readout: Frame
local readoutText: TextLabel
local holdButton: TextButton
local autoTrack: Frame
local autoFill: Frame
local autoLabel: TextLabel
local state: {
	id: any,
	kind: string,
	lo: number,
	hi: number,
	rate: number,
	level: number, -- the level when the hold started / now (not holding)
	holdFrom: number?, -- os.clock() when the hold began
	clickAt: number?, -- Torque: the wrench clicks this many seconds into the hold (the server's d)
	clicked: boolean,
	max: number?,
	unit: string?,
	seq: number,
	auto: boolean,
	t0: number,
	seconds: number,
	restUntil: number,
	finished: boolean,
}? = nil

local function currentLevel(): number
	local s = state
	if not s then
		return 0
	end
	if s.auto then
		return math.clamp((os.clock() - s.t0) / s.seconds, 0, 1) * (s.lo + s.hi) / 2
	end
	if s.holdFrom then
		return math.clamp(s.level + s.rate * (os.clock() - s.holdFrom), 0, 1)
	end
	return s.level
end

local function send(what: string)
	local s = state
	if s and not s.auto and not s.finished then
		s.seq += 1
		Remotes.MinigameInput:FireServer(s.id, s.seq, what)
	end
end

local function down()
	local s = state
	if s and not s.auto and not s.finished and not s.holdFrom and os.clock() >= s.restUntil then
		s.holdFrom = os.clock()
		s.clicked = false
		send("down")
	end
end

local function up()
	local s = state
	if s and s.holdFrom then
		s.level = currentLevel()
		s.holdFrom = nil
		send("up")
	end
end

local function dimHold(t: number)
	local face = holdButton:FindFirstChild("Face") :: Frame?
	if face then
		face.BackgroundTransparency = t
		local label = face:FindFirstChild("Label") :: TextLabel?
		if label then
			label.TextTransparency = t * 0.7
		end
	end
end

-- where the band sits on the tube (the tube's top = 1)
local function placeBand(lo: number, hi: number)
	band.Position = UDim2.fromScale(0, 1 - hi)
	band.Size = UDim2.fromScale(1, hi - lo)
	local y = 1 - hi
	flagRight.Position = UDim2.new(1, 6, y, 0)
	markLeft.Position = UDim2.new(0, -6, y, 0)
end

local function draw()
	local s = state
	if not s then
		return
	end
	local level = currentLevel()
	liquidBar.Size = UDim2.fromScale(1, math.max(level, 0.001))
	-- the live number by the level (left side, only when the kind has one): follows the liquid's top
	if s.max then
		readout.Visible = true
		readout.Position = UDim2.new(0, -6, 1 - level, 0)
		readoutText.Text = tostring(math.floor(level * s.max + 0.5))
	else
		readout.Visible = false
	end
	if s.auto then
		local share = math.clamp((os.clock() - s.t0) / s.seconds, 0, 1)
		autoFill.Size = UDim2.fromScale(math.max(share, 0.02), 1)
		autoLabel.Text = tostring(math.floor(share * 100 + 0.5)) .. "%"
	elseif s.holdFrom and level >= 1 then
		up() -- (the top of the tube: the hand lets go for it)
	elseif s.holdFrom and s.clickAt and not s.clicked and os.clock() - s.holdFrom >= s.clickAt then
		-- the torque wrench CLICKS (the server's d, told at the start): sound, a buzz, the band flashes — now let go
		s.clicked = true
		SoundPlayer.play("ratchet")
		pcall(function()
			local H = game:GetService("HapticService")
			if H:IsVibrationSupported(Enum.UserInputType.Gamepad1) then
				H:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 1)
				task.delay(0.15, function()
					H:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
				end)
			end
		end)
		band.BackgroundTransparency = 0
		TweenService:Create(band, TweenInfo.new(0.35), { BackgroundTransparency = 0.3 }):Play()
	end
end

local function missed(reason: string, level: number?)
	local s = state
	if not s then
		return
	end
	s.holdFrom = nil
	s.restUntil = os.clock() + REST
	if level then
		s.level = level
	end
	-- (over: the level falls to the server's value: a short slide so it reads as draining)
	local k = KINDS[s.kind] or KINDS.Coolant
	frame:notice(if reason == "over" then k.over else k.under, REST + 0.3, k.title)
	UIKit.setButton(holdButton, nil, "Green", true)
	dimHold(0.6)
	local my = frame.token
	task.delay(REST, function()
		if my == frame.token and state and not state.finished then
			UIKit.setButton(holdButton, nil, "Green", false)
			dimHold(0)
		end
	end)
end

local function open(auto: boolean, data: { [string]: any })
	local kind = data.kind or "Coolant"
	local k = KINDS[kind] or KINDS.Coolant
	local st = {
		id = data.id,
		kind = kind,
		lo = data.lo or 0.78,
		hi = data.hi or 0.9,
		rate = data.rate or 0.28,
		level = data.level or 0,
		holdFrom = nil,
		clickAt = data.clickAt,
		clicked = false,
		max = data.max,
		unit = data.unit,
		seq = 0,
		auto = auto,
		t0 = os.clock(),
		seconds = data.seconds or 4.5,
		restUntil = 0,
		finished = false,
	}
	state = st
	liquidBar.BackgroundColor3 = LIQUID[data.liquid or "pink"] or LIQUID.pink
	placeBand(st.lo, st.hi)
	UIKit.setText(flagText, nil)
	flagText.Text = if data.label then tostring(data.label) else ""
	if not data.label then
		UIKit.setText(flagText, k.flag)
	end
	holdButton.Visible = not auto
	autoTrack.Visible = auto
	UIKit.setButton(holdButton, nil, "Green", false)
	dimHold(0)
	frame:open(if auto or data.nocue then nil else k.cue, if auto then k.auto else k.title)
end

local function showResult(grade: string, tip: number?, auto: boolean?, keepable: boolean?)
	local s = state
	if not s then
		return
	end
	s.finished = true
	s.holdFrom = nil
	s.level = (s.lo + s.hi) / 2 -- (the liquid sits in the band)
	holdButton.Visible = false
	autoTrack.Visible = false
	local k = KINDS[s.kind] or KINDS.Coolant
	TweenService:Create(tube, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(70, 130, 80) }):Play()
	frame:finish(grade, tip, auto, keepable, { perfect = k.perfect, good = k.good }, function()
		state = nil
		tube.BackgroundColor3 = Color3.fromRGB(34, 40, 48)
	end)
end

function Fill.start()
	frame = MiniFrame.new({
		name = "MiniFill",
		kind = "Coolant",
		reserve = 52,
		ratio = 1.0, -- (the plate is ~236 px wide now: wr-uidesign A②, the gauge is what got bigger)
		titleKey = "mg.fill",
		onLeave = function()
			send("quit")
			state = nil
			frame:hide()
			HUD.notify("mg.left", nil, "info")
		end,
	})
	panel = frame.panel

	-- the tube: dark glass with a steel rim, centred; the liquid grows from its bottom
	local holder = Instance.new("Frame")
	holder.Name = "TubeBox"
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.Position = UDim2.fromScale(0.5, 0.27) -- (under the close button's row: the flag by a band near the top must not touch the ✕) -- (a clear gap under the title line: on 667x375 the Korean title's lower half sat under the tube's rim — wr-release 10-23)
	holder.Size = UDim2.fromScale(0.24, 0.44)
	holder.BackgroundTransparency = 1
	holder.Parent = panel
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.AspectRatio = 0.42
	ratio.Parent = holder
	tube = Instance.new("Frame")
	tube.Name = "Tube"
	tube.Size = UDim2.fromScale(1, 1)
	tube.BackgroundColor3 = Color3.fromRGB(34, 40, 48)
	tube.BorderSizePixel = 0
	tube.ClipsDescendants = true
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0.12, 0)
	tc.Parent = tube
	local ts = Instance.new("UIStroke")
	ts.Color = Color3.fromRGB(170, 178, 190)
	ts.Thickness = 3
	ts.Parent = tube
	tube.Parent = holder
	liquidBar = Instance.new("Frame")
	liquidBar.Name = "Liquid"
	liquidBar.AnchorPoint = Vector2.new(0, 1)
	liquidBar.Position = UDim2.fromScale(0, 1)
	liquidBar.Size = UDim2.fromScale(1, 0.001)
	liquidBar.BackgroundColor3 = LIQUID.pink
	liquidBar.BorderSizePixel = 0
	liquidBar.Parent = tube
	for i = 1, 5 do -- (tick marks along the left edge: the middle one longer — a measuring glass)
		local t = Instance.new("Frame")
		t.Name = "Tick"
		t.AnchorPoint = Vector2.new(0, 0.5)
		t.Position = UDim2.fromScale(0, i / 6)
		t.Size = UDim2.new(if i == 3 then 0.5 else 0.3, 0, 0, 3)
		t.BackgroundColor3 = Color3.fromRGB(235, 240, 245)
		t.BackgroundTransparency = 0.25
		t.BorderSizePixel = 0
		t.ZIndex = 2
		t.Parent = tube
	end
	band = Instance.new("Frame")
	band.Name = "Band"
	band.BackgroundColor3 = C.Green
	band.BackgroundTransparency = 0.3
	band.BorderSizePixel = 0
	band.ZIndex = 3
	band.Parent = tube
	local bandLine = Instance.new("Frame") -- (the line across the band's top: the FULL mark)
	bandLine.Name = "Line"
	bandLine.Size = UDim2.new(1, 0, 0, 4)
	bandLine.BackgroundColor3 = Color3.fromRGB(110, 255, 130)
	bandLine.BorderSizePixel = 0
	bandLine.ZIndex = 4
	bandLine.Parent = band

	-- the glass's metal caps, top and bottom (a little wider than the tube)
	for _, top in { true, false } do
		local cap = Instance.new("Frame")
		cap.Name = if top then "CapTop" else "CapBottom"
		cap.AnchorPoint = Vector2.new(0.5, if top then 1 else 0)
		cap.Position = UDim2.fromScale(0.5, if top then 0.04 else 0.96)
		cap.Size = UDim2.new(1.26, 0, 0.1, 0)
		cap.BackgroundColor3 = Color3.fromRGB(150, 158, 170)
		cap.BorderSizePixel = 0
		cap.ZIndex = 6
		local cc = Instance.new("UICorner")
		cc.CornerRadius = UDim.new(0.35, 0)
		cc.Parent = cap
		local cs = Instance.new("UIStroke")
		cs.Color = Color3.fromRGB(34, 40, 48)
		cs.Thickness = 2
		cs.Parent = cap
		local cg = Instance.new("UIGradient")
		cg.Color = ColorSequence.new(Color3.fromRGB(235, 240, 246), Color3.fromRGB(120, 128, 140))
		cg.Rotation = 90
		cg.Parent = cap
		cap.Parent = holder
	end

	-- the right flag with the target's words, the left arrow marker (same height), so the tube stays on the axis
	flagRight = Instance.new("Frame")
	flagRight.Name = "Flag"
	flagRight.BackgroundColor3 = C.Green
	flagRight.BorderSizePixel = 0
	flagRight.AnchorPoint = Vector2.new(0, 0.5)
	flagRight.Size = UDim2.fromOffset(64, 26)
	local fcorner = Instance.new("UICorner")
	fcorner.CornerRadius = UDim.new(0.3, 0)
	fcorner.Parent = flagRight
	local fstroke = Instance.new("UIStroke")
	fstroke.Color = C.GreenDark
	fstroke.Thickness = 2
	fstroke.Parent = flagRight
	flagRight.Parent = holder
	flagText = UIKit.text(flagRight, { name = "Text", key = "mg.fill.full", font = "Title", size = UDim2.fromScale(0.92, 0.8), max = 18 })
	markLeft = Instance.new("Frame")
	markLeft.Name = "Arrow"
	markLeft.BackgroundColor3 = Color3.fromRGB(110, 255, 130)
	markLeft.BorderSizePixel = 0
	markLeft.AnchorPoint = Vector2.new(1, 0.5)
	markLeft.Size = UDim2.fromOffset(12, 12)
	markLeft.Rotation = 45
	markLeft.Parent = holder

	-- the live number (kinds with a unit): a white chip by the liquid's top on the left
	readout = Instance.new("Frame")
	readout.Name = "Readout"
	readout.AnchorPoint = Vector2.new(1, 0.5)
	readout.Size = UDim2.fromOffset(52, 28)
	readout.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
	readout.BorderSizePixel = 0
	readout.Visible = false
	readout.ZIndex = 5
	local rc = Instance.new("UICorner")
	rc.CornerRadius = UDim.new(0.3, 0)
	rc.Parent = readout
	local rst = Instance.new("UIStroke")
	rst.Color = Color3.fromRGB(170, 178, 190)
	rst.Thickness = 1.5
	rst.Parent = readout
	readout.Parent = holder
	readoutText = UIKit.text(readout, { name = "Digits", text = "0", font = "Title", size = UDim2.fromScale(0.9, 0.82), max = 22, z = 6 })

	holdButton = UIKit.button(panel, { name = "Hold", key = "mg.hold", style = "Green", anchor = Vector2.new(0.5, 0.5), pos = UDim2.fromScale(0.5, 0.865), size = UDim2.fromScale(0.62, 0.23), max = 26 })
	local fingerId = (UIStyle.Icon :: any).ScrubFinger
	local finger = UIKit.icon(holdButton, fingerId, { name = "Finger", anchor = Vector2.new(0, 0.5), pos = UDim2.fromScale(0.06, 0.45), size = UDim2.fromScale(0.3, 0.8) })
	if finger then
		finger.ZIndex = holdButton.ZIndex + 3
		local label = (holdButton:FindFirstChild("Face") :: Frame):FindFirstChild("Label") :: TextLabel
		label.Position = UDim2.fromScale(0.64, 0.5)
		label.Size = UDim2.fromScale(0.5, 0.74)
	end
	-- the hold: pressing the button holds, anything letting go ends it (the finger may slide off the button)
	local held: InputObject? = nil
	holdButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			held = input
			down()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input == held or (held == nil and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E)) then
			held = nil
			up()
		end
	end)
	UserInputService.InputBegan:Connect(function(input, processed)
		if state and not processed and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E) then
			down()
		end
	end)

	-- Auto: a slim bar + its % where the button was
	autoTrack = Instance.new("Frame")
	autoTrack.Name = "AutoBar"
	autoTrack.AnchorPoint = Vector2.new(0.5, 0.5)
	autoTrack.Position = UDim2.fromScale(0.5, 0.875)
	autoTrack.Size = UDim2.fromScale(0.72, 0.065)
	autoTrack.BackgroundColor3 = C.PlateLight
	autoTrack.BorderSizePixel = 0
	autoTrack.Visible = false
	local atc = Instance.new("UICorner")
	atc.CornerRadius = UDim.new(1, 0)
	atc.Parent = autoTrack
	local ats = Instance.new("UIStroke")
	ats.Color = C.Outline
	ats.Thickness = 2
	ats.Parent = autoTrack
	autoTrack.Parent = panel
	autoFill = Instance.new("Frame")
	autoFill.Name = "Fill"
	autoFill.BackgroundColor3 = C.Green
	autoFill.BorderSizePixel = 0
	local afc = Instance.new("UICorner")
	afc.CornerRadius = UDim.new(1, 0)
	afc.Parent = autoFill
	autoFill.Parent = autoTrack
	autoLabel = UIKit.text(autoTrack, { name = "Percent", text = "0%", font = "Title", anchor = Vector2.new(1, 0.5), pos = UDim2.new(1, -10, 0.5, 0), size = UDim2.fromScale(0.2, 1.8), alignX = Enum.TextXAlignment.Right, max = 18, z = 3 })

	Remotes.Minigame.OnClientEvent:Connect(function(what, data)
		if what == "fill" and data then
			open(false, data)
		elseif what == "auto" and data and KINDS[data.kind or ""] then
			open(true, data)
		elseif what == "miss" and state and not state.auto and data and data.reason then
			missed(data.reason, data.level)
		elseif what == "done" and state and data and KINDS[data.kind or ""] then
			showResult(data.grade or "Good", data.tip, data.auto, data.ask ~= nil)
		elseif what == "stop" and state then
			state = nil
			frame:hide()
		end
	end)
	RunService.RenderStepped:Connect(draw)

	-- Studio only: draw the screen with no server (player attribute MgTest)
	if RunService:IsStudio() then
		local player = game:GetService("Players").LocalPlayer
		local coolant = { id = "test", kind = "Coolant", lo = 0.78, hi = 0.9, rate = 0.28, liquid = "pink", nocue = true }
		local tire = { id = "test", kind = "Tire", lo = 0.66, hi = 0.74, rate = 0.3, liquid = "air", label = "35 PSI", unit = "PSI", max = 50, nocue = true }
		player:GetAttributeChangedSignal("MgTest"):Connect(function()
			local t = player:GetAttribute("MgTest")
			if t == "fill" then
				open(false, coolant)
				if state then
					state.level = 0.4
				end
			elseif t == "fillcue" then
				open(false, { id = "test", kind = "Coolant", lo = 0.78, hi = 0.9, rate = 0.28, liquid = "pink" })
			elseif t == "filltire" then
				open(false, tire)
				if state then
					state.level = 0.62
				end
			elseif t == "filltorque" then
				open(false, { id = "test", kind = "Torque", lo = 0.45, hi = 0.63, rate = 0.3, clickAt = 1.5, liquid = "steel", nocue = true })
				if state then
					state.level = 0.55
				end
			elseif t == "fillauto" then
				open(true, { id = "test", kind = "Coolant", lo = 0.78, hi = 0.9, seconds = 4.5 })
			elseif t == "fillunder" then
				open(false, coolant)
				if state then
					state.level = 0.45
				end
				missed("under", 0.45)
			elseif t == "fillover" then
				open(false, coolant)
				if state then
					state.level = 1
				end
				missed("over", 1)
			elseif t == "fillperfect" then
				open(false, coolant)
				showResult("Perfect", 15, false, false)
			elseif t == "fillperfect0" then -- (a tip of $0: the pill says "Perfect!" only)
				open(false, coolant)
				showResult("Perfect", 0, false, false)
			end
		end)
	end
end

return Fill
