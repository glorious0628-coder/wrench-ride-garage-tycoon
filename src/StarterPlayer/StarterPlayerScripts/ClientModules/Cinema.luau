-- The screen around an in-game camera scene (halloween_pumpkin §5 / §5b: Ella's arrival, leaving, midnight pop):
-- black bars slide in at the top and bottom, our HUD, the touch stick and the prompts step away, Ella's words show
-- in the bottom bar as one subtitle line (a bubble over a moving 3D head is hard to read on a phone), and — only for
-- someone who has seen the scenes to the end once — a small "Tap to skip" sits in the top bar's right corner.
-- wr-dev's scene code moves the camera and the cars; this only draws.
--   Cinema.play({ canSkip = bool })   bars in, HUD away (call before the first cut)
--   Cinema.say(lineKey?, args?, whoKey?)   the subtitle ("Ella" in yellow + the line); nil clears it
--   Cinema.clock(minutes?)            the midnight clock chip in the top bar's middle (the job card's clock, carried
--                                     into the scene); 60 = it strikes 12: red "12:00" + a pop — call it with the bells.
--                                     nil hides it. (No big centre insert: GPT — it looked pasted on the 3D picture.)
--   Cinema.stop()                     bars out, everything back
--   Cinema.Skipped.Event              fired once per play when the screen is tapped (canSkip only): jump to the end
--   Cinema.playing()
--   Cinema.layer()                    the scene screen, for a card that is the scene's last beat (TrophyCard)
--   Cinema.holdSkip()                 a card takes the taps now: skipping off for the rest of this play
--   Cinema.sinceSkip()                seconds since this play was skipped (math.huge if it wasn't)
-- GPT 2 rounds: notes/gpt/wr-ui/ella_ui_decision.md

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)
local MidnightClock = require(script.Parent.MidnightClock)
local SoundPlayer = require(script.Parent.SoundPlayer)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local Cinema = {}
Cinema.Skipped = Instance.new("BindableEvent")

local C = UIStyle.Color
local BAR = 0.13 -- each bar's share of the screen height (≈50 px on a phone: room for a two-line subtitle)
local IN = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local OUT = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local gui: ScreenGui
local stage: Frame -- the whole screen (the emulated phone while the HUD's phone check is on)
local top: Frame
local bottom: Frame
local subtitle: TextLabel
local skipHint: Frame
local catcher: TextButton
local isPlaying = false
local token = 0
local saved: { [string]: any } = {}
local skipText: () -> () = function() end
local chip: MidnightClock.Chip
local skippedAt = -math.huge

-- follow the HUD's phone check (UIKit only moves the HUD's own children into its frame)
local function fitStage()
	local hud = HUD.gui()
	local want = hud:GetAttribute("EmuSize") :: Vector2?
	local zoom = UIKit.zoom()
	local scale = stage:FindFirstChildOfClass("UIScale") :: UIScale
	local device = hud:FindFirstChild("EmuDevice") :: GuiObject?
	if typeof(want) == "Vector2" and device then
		stage.Size = UDim2.fromOffset(want.X, want.Y)
		scale.Scale = zoom
		-- over the HUD's phone frame (the HUD sits under the top bar; this gui doesn't)
		local mid = device.AbsolutePosition + device.AbsoluteSize / 2 + GuiService:GetGuiInset()
		stage.Position = UDim2.fromOffset(mid.X, mid.Y)
	else
		stage.Size = UDim2.fromScale(1, 1)
		stage.Position = UDim2.fromScale(0.5, 0.5)
		scale.Scale = 1
	end
end

local function hideWorld(on: boolean)
	local hud = HUD.gui()
	if on then
		saved = {
			hud = hud.Enabled,
			touch = GuiService.TouchControlsEnabled,
			prompts = ProximityPromptService.Enabled,
			chat = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat),
			list = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList),
		}
		hud.Enabled = false
		GuiService.TouchControlsEnabled = false
		ProximityPromptService.Enabled = false
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Chat, false)
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.PlayerList, false)
	else
		hud.Enabled = if saved.hud == nil then true else saved.hud
		GuiService.TouchControlsEnabled = if saved.touch == nil then true else saved.touch
		ProximityPromptService.Enabled = if saved.prompts == nil then true else saved.prompts
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Chat, saved.chat ~= false)
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.PlayerList, saved.list ~= false)
	end
end

function Cinema.playing(): boolean
	return isPlaying
end

function Cinema.play(opts: { canSkip: boolean? }?)
	token += 1
	local my = token
	isPlaying = true
	fitStage()
	hideWorld(true)
	gui.Enabled = true
	subtitle.Text = ""
	skipHint.Visible = false
	skipText() -- (tap or click: the device may have changed since start)
	catcher.Visible = opts ~= nil and opts.canSkip == true
	catcher:SetAttribute("Fired", false)
	chip.frame.Visible = false
	skippedAt = -math.huge
	top.Position = UDim2.fromScale(0, -BAR)
	bottom.Position = UDim2.fromScale(0, 1)
	TweenService:Create(top, IN, { Position = UDim2.fromScale(0, 0) }):Play()
	TweenService:Create(bottom, IN, { Position = UDim2.fromScale(0, 1 - BAR) }):Play()
	if catcher.Visible then
		-- the hint comes a moment later: a tap meant for the game just before the scene doesn't skip it
		task.delay(0.8, function()
			if token == my and isPlaying and catcher.Visible then
				skipHint.Visible = true
				skipHint.GroupTransparency = 1
				TweenService:Create(skipHint, TweenInfo.new(0.3), { GroupTransparency = 0.15 }):Play()
			end
		end)
	end
end

function Cinema.stop()
	if not isPlaying then
		return
	end
	token += 1
	local my = token
	isPlaying = false
	catcher.Visible = false
	skipHint.Visible = false
	subtitle.Text = ""
	chip.frame.Visible = false
	TweenService:Create(top, OUT, { Position = UDim2.fromScale(0, -BAR) }):Play()
	TweenService:Create(bottom, OUT, { Position = UDim2.fromScale(0, 1) }):Play()
	hideWorld(false)
	task.delay(0.32, function()
		if token == my then
			gui.Enabled = false
		end
	end)
end

function Cinema.say(lineKey: string?, args: { [string]: any }?, whoKey: string?)
	if not lineKey then
		subtitle.Text = ""
		return
	end
	local line = Localizer.t(lineKey, args):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
	local who = Localizer.t(whoKey or "npc.Ella"):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
	subtitle.Text = '<font color="#FAC81E">' .. who .. "</font>  " .. line
	subtitle.TextTransparency = 1
	TweenService:Create(subtitle, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
end

function Cinema.clock(minutes: number?)
	if not minutes then
		chip.frame.Visible = false
		return
	end
	local first = not chip.frame.Visible
	chip.frame.Visible = true
	if first and minutes >= 60 then
		-- shown right at midnight (the midnight cut): 11:59 for a beat, then it strikes 12 with the bells
		chip.set(59, true)
		local my = token
		task.delay(0.35, function()
			if token == my and chip.frame.Visible then
				chip.set(60)
				SoundPlayer.play("clockTickSoft")
			end
		end)
		return
	end
	chip.set(minutes, first)
	if minutes >= 60 then
		SoundPlayer.play("clockTickSoft")
	end
end

function Cinema.layer(): Frame
	return stage
end

function Cinema.holdSkip()
	catcher.Visible = false
	skipHint.Visible = false
end

function Cinema.sinceSkip(): number
	return os.clock() - skippedAt
end

local function bar(name: string): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = UDim2.fromScale(1, BAR)
	f.BackgroundColor3 = Color3.new(0, 0, 0)
	f.BorderSizePixel = 0
	f.ZIndex = 2
	f.Parent = stage
	return f
end

function Cinema.start()
	gui = Instance.new("ScreenGui")
	gui.Name = "Cinema"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true -- (the bars cover the top bar row too)
	gui.ScreenInsets = Enum.ScreenInsets.None
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 900 -- (under the loading / moving screens)
	gui.Enabled = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	stage = Instance.new("Frame")
	stage.Name = "Stage"
	stage.AnchorPoint = Vector2.new(0.5, 0.5)
	stage.Position = UDim2.fromScale(0.5, 0.5)
	stage.Size = UDim2.fromScale(1, 1)
	stage.BackgroundTransparency = 1
	stage.ClipsDescendants = true
	Instance.new("UIScale").Parent = stage
	stage.Parent = gui

	top = bar("Top")
	bottom = bar("Bottom")

	-- the subtitle: one or two lines in the middle of the bottom bar, clear of the side notches
	subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
	subtitle.Position = UDim2.fromScale(0.5, 0.5)
	subtitle.Size = UDim2.fromScale(0.8, 0.8)
	subtitle.BackgroundTransparency = 1
	subtitle.FontFace = UIStyle.Font.Body
	subtitle.TextColor3 = C.White
	subtitle.RichText = true
	subtitle.TextWrapped = true
	subtitle.TextScaled = true -- (after TextWrapped)
	subtitle.Text = ""
	subtitle.ZIndex = 3
	local cap = Instance.new("UITextSizeConstraint")
	cap.MaxTextSize = 24
	cap.MinTextSize = 12
	cap.Parent = subtitle
	subtitle.Parent = bottom

	-- "Tap to skip" (the tutorial's skip icon + the words), small, the top bar's right end (the bottom bar is the
	-- subtitle's; the top right has no Roblox buttons)
	skipHint = Instance.new("CanvasGroup")
	skipHint.Name = "SkipHint"
	skipHint.AnchorPoint = Vector2.new(1, 0.5)
	skipHint.Position = UDim2.new(0.96, 0, 0.5, 0) -- (clear of a side notch)
	skipHint.Size = UDim2.fromScale(0.2, 0.46)
	skipHint.BackgroundTransparency = 1
	skipHint.Visible = false
	skipHint.ZIndex = 3
	skipHint.Parent = top
	UIKit.icon(skipHint, UIStyle.Icon.Skip, { anchor = Vector2.new(0, 0.5), pos = UDim2.fromScale(0, 0.5), size = UDim2.fromScale(0.14, 0.8) })
	local skipWords = UIKit.text(skipHint, {
		name = "Words",
		anchor = Vector2.new(1, 0.5),
		pos = UDim2.fromScale(1, 0.5),
		size = UDim2.fromScale(0.82, 0.8),
		alignX = Enum.TextXAlignment.Left,
		max = 16,
		z = 3,
	})
	skipText = function()
		skipWords.Text = Localizer.t(if UIKit.keyboard() then "cine.skipPc" else "cine.skip")
	end
	skipText()
	Localizer.Changed.Event:Connect(skipText)

	-- the midnight clock chip: the top bar's middle (Roblox's buttons are on the left, the skip hint on the right)
	chip = MidnightClock.chip(top, 3)
	chip.frame.AnchorPoint = Vector2.new(0.5, 0.5)
	chip.frame.Position = UDim2.fromScale(0.5, 0.5)
	chip.frame.Size = UDim2.fromScale(0.13, 0.7)
	local chipRatio = Instance.new("UIAspectRatioConstraint")
	chipRatio.AspectRatio = 2.7
	chipRatio.Parent = chip.frame
	chip.frame.Visible = false

	-- the whole screen catches the tap while skipping is allowed (fired once per scene)
	catcher = Instance.new("TextButton")
	catcher.Name = "TapToSkip"
	catcher.Size = UDim2.fromScale(1, 1)
	catcher.BackgroundTransparency = 1
	catcher.Text = ""
	catcher.ZIndex = 10
	catcher.Visible = false
	catcher.Parent = stage
	catcher.Activated:Connect(function()
		if isPlaying and not catcher:GetAttribute("Fired") then
			catcher:SetAttribute("Fired", true)
			skippedAt = os.clock()
			skipHint.Visible = false
			Cinema.Skipped:Fire()
		end
	end)

	HUD.gui():GetAttributeChangedSignal("EmuSize"):Connect(function()
		task.defer(fitStage)
	end)
end

return Cinema
