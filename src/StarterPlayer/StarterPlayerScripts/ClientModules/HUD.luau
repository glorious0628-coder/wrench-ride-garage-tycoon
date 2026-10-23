-- The money bar (top centre, in the Roblox top bar row: cash counting up, Garage Lv + reputation bar, star rating
-- when the server sends one), a hint line above the tool bar, and notices from the server (Remotes.Notify: key +
-- args). UI B look (UIKit). (The settings button next to it: Settings.luau.)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Localizer = require(script.Parent.Localizer)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)
local SoundPlayer = require(script.Parent.SoundPlayer)

local HUD = {}

local C = UIStyle.Color
local player = Players.LocalPlayer
local gui: ScreenGui
local bar: Frame
local moneyLabel: TextLabel
local levelLabel: TextLabel
local repFill: Frame
local starLabel: TextLabel
local hintLabel: TextLabel
local noticeLabel: TextLabel
local noticeIcon: ImageLabel?
local noticeToken = 0
local shownMoney = Instance.new("NumberValue")

local KIND_COLOR = {
	info = C.White,
	good = C.Good,
	bad = C.Bad,
}

-- the tool bar's slot height (Hotbar uses the same numbers): hint and notices sit above it
function HUD.hotbarHeight(): number
	return UIKit.hotbarHeight()
end

-- reputation inside the current level, 0..1
local function repShare(rep: number, level: number): number
	local levels = Config.GarageLevels
	local lo = levels[level]
	local hi = levels[level + 1]
	if not lo or not hi then
		return 1
	end
	return math.clamp((rep - lo) / (hi - lo), 0, 1)
end

-- the reputation bar waits for the settlement card (first10_payout §3): the server gives the rep at the hand-back,
-- the card comes once the customer has driven off — the bar fills (and a new level shows) when the card closes
local repHeldUntil = 0
local moneyHeld = false -- (the money chip waits with the bar: coins fly in when the card closes)
local shownLevel: number? = nil

local moneyKnown = false -- (the save loads a moment after joining: until then no "$0", and the first amount shows at once)

local function refresh()
	local raw = player:GetAttribute("Money") :: number?
	if raw == nil then
		moneyKnown = false
		moneyLabel.Text = Localizer.t("hud.money", { money = "$…" })
	elseif not moneyKnown then
		moneyKnown = true
		shownMoney.Value = raw -- (no roll-up from 0: that read as a reward on joining — wr-release 10-22)
		moneyLabel.Text = Localizer.t("hud.money", { money = math.floor(raw + 0.5) })
	end
	local money = raw or 0
	local rep = player:GetAttribute("Rep") or 0
	local level = player:GetAttribute("Level") or 1
	-- money rolls up (or down) to the new amount
	if not moneyHeld and raw ~= nil then
		TweenService:Create(shownMoney, TweenInfo.new(if math.abs(money - shownMoney.Value) < 1 then 0 else 0.6, Enum.EasingStyle.Quad), { Value = money }):Play()
	end
	if os.clock() >= repHeldUntil then
		UIKit.setText(levelLabel, "ui.garageLv", { level = level })
		if shownLevel and level > shownLevel then
			-- a new level: the badge pops and the bar starts again from the new level's start (never drains backwards)
			repFill.Size = UDim2.fromScale(0.04, 1)
			UIKit.pop(levelLabel, 0.6)
		end
		shownLevel = level
		TweenService:Create(repFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Size = UDim2.fromScale(math.max(repShare(rep, level), 0.04), 1) }):Play()
	end
	local stars = player:GetAttribute("Stars") :: number?
	starLabel.Visible = stars ~= nil
	if stars then
		starLabel.Text = string.format("\u{2605}%.1f", stars)
	end
end

-- coins fly from where the settlement card was to the money chip, and the number rolls up as they land (B3: the
-- payout you just earned, shown once and short). 7 gold dots, 0.45 s each, 0.06 s apart; code-drawn dots only.
local function coinsFly(fromAbs: Vector2?)
	if not gui or not moneyLabel then
		return
	end
	local z = UIKit.zoom()
	local rootAbs = gui.AbsolutePosition
	local target = moneyLabel.AbsolutePosition + moneyLabel.AbsoluteSize * Vector2.new(0.25, 0.5)
	local origin = fromAbs or (rootAbs + gui.AbsoluteSize / 2)
	local d = 14
	for i = 1, 7 do
		task.delay((i - 1) * 0.06, function()
			local c = Instance.new("Frame")
			c.Name = "Coin"
			c.AnchorPoint = Vector2.new(0.5, 0.5)
			c.Size = UDim2.fromOffset(d, d)
			c.BackgroundColor3 = C.Gold
			c.BorderSizePixel = 0
			c.ZIndex = 20
			local cc = Instance.new("UICorner")
			cc.CornerRadius = UDim.new(0.5, 0)
			cc.Parent = c
			local edge = Instance.new("UIStroke")
			edge.Color = C.OrangeDark
			edge.Thickness = 2
			edge.Parent = c
			local start = origin + Vector2.new((i - 4) * 14, (i % 3 - 1) * 12)
			c.Position = UDim2.fromOffset((start.X - rootAbs.X) / z, (start.Y - rootAbs.Y) / z)
			c.Parent = gui
			local tw = TweenService:Create(c, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.fromOffset((target.X - rootAbs.X) / z, (target.Y - rootAbs.Y) / z),
				Size = UDim2.fromOffset(d * 0.6, d * 0.6),
			})
			tw.Completed:Connect(function()
				c:Destroy()
				UIKit.pop(moneyLabel, 1.12)
			end)
			tw:Play()
		end)
	end
end

-- JobCard: the settlement card (or the short banner) is gone — fill the bar now
function HUD.showRep()
	repHeldUntil = 0
	local gain = (player:GetAttribute("Money") or 0) - shownMoney.Value
	if moneyHeld and gain > 0.5 then
		coinsFly(nil)
	end
	moneyHeld = false
	refresh()
end

function HUD.hint(key: string?, args: { [string]: any }?)
	-- a held tool's hint starts with the tool's name in yellow (the phone tool bar has no names: decision
	-- hotbar_icons). The Scanner's own hint (hud.inspect) already starts with its name.
	local tool = key and key:match("^hud%.toolHint%.(.+)$")
	if tool then
		UIKit.setText(hintLabel, "ui.hint.tool", { tool = "@tool." .. tool, hint = "@" .. key })
	else
		UIKit.setText(hintLabel, key, args)
	end
end

-- nothing on the hint's line now (the tool bar may put a name tag there)
function HUD.hintEmpty(): boolean
	return hintLabel.Visible and hintLabel.Text == ""
end

-- the tool bar's name tag sits on the hint's line for a moment: the hint fades under it (shown 0 .. 1 = tag fully up)
function HUD.hintFade(shown: number)
	hintLabel.TextTransparency = shown
	local s = hintLabel:FindFirstChildOfClass("UIStroke")
	if s then
		s.Transparency = shown
	end
end

local lastBuzz = -math.huge
function HUD.notify(key: string, args: { [string]: any }?, kind: string?)
	-- (a phone has no G key: the server's "G to drop" line in its touch words — the Drop button is on screen)
	if key == "n.handsFull" and not UIKit.keyboard() then
		key = "n.handsFull.touch"
	end
	-- the first tutorial job: its "YOUR FIRST JOB!" banner and the job card already say a customer came in
	local tut = player:GetAttribute("Tut") :: number?
	if key == "n.customerIn" and tut == 1 and not player:GetAttribute("TutSkip") then
		return
	end
	noticeToken += 1
	local my = noticeToken
	-- a "not that" notice: the soft two-note buzz (not more than once a second and a half)
	if kind == "bad" and os.clock() - lastBuzz > 1.5 then
		lastBuzz = os.clock()
		SoundPlayer.play("wrongBuzz")
	end
	noticeLabel.Text = Localizer.t(key, args)
	noticeLabel.TextColor3 = KIND_COLOR[kind or "info"] or KIND_COLOR.info
	noticeLabel.TextTransparency = 0
	-- in a work view it takes the tool hint's line (the one band over no part: one line higher it sat on a wheel's
	-- lower nuts — measured 10-22 on 844×390 / 667×375), the hint steps out while it shows
	local inWork = gui:GetAttribute("WorkView") == true
	noticeLabel.Position = noticeLabel:GetAttribute(if inWork then "WorkPos" else "Pos") :: UDim2? or noticeLabel.Position
	noticeLabel.TextYAlignment = if inWork then Enum.TextYAlignment.Bottom else Enum.TextYAlignment.Center
	hintLabel.Visible = not inWork
	-- a warning sign in front of a bad one, just left of where the text starts
	local icon = noticeIcon
	if icon then
		icon.Visible = false
		icon.ImageTransparency = 0
		task.defer(function() -- (TextBounds is measured after this frame)
			if my ~= noticeToken or kind ~= "bad" then
				return
			end
			-- shares of the label's own size: right even mid pop-in (UIScale) or in the zoomed phone check
			local box = noticeLabel.AbsoluteSize
			local w = math.min(noticeLabel.TextBounds.X / box.X, 1)
			local h = math.min(noticeLabel.TextBounds.Y / box.Y, 0.5) * 1.35
			icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
			icon.Size = UDim2.fromScale(h, h)
			icon.Position = UDim2.new(0.5 - w / 2, -8, 0.5, 0)
			icon.Visible = true
		end)
	end
	local stroke = noticeLabel:FindFirstChildOfClass("UIStroke") :: UIStroke
	stroke.Transparency = 0
	UIKit.pop(noticeLabel, 0.7)
	task.delay(2.6, function()
		if my == noticeToken then
			TweenService:Create(noticeLabel, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.4), { Transparency = 1 }):Play()
			if noticeIcon then
				TweenService:Create(noticeIcon, TweenInfo.new(0.4), { ImageTransparency = 1 }):Play()
			end
			task.delay(0.4, function()
				if my == noticeToken then
					hintLabel.Visible = true
				end
			end)
		end
	end)
end

-- "it works now" made visible (a fix with no sound of its own — quiet brakes, user 10-21): a green plate with a
-- check and a short line pops up in the middle of the screen for a moment. key = a Locale key, e.g.
-- "ui.proof.brakeQuiet". (Effects / wr-dev decides when.)
local proofToken = 0
function HUD.proof(key: string, args: { [string]: any }?)
	proofToken += 1
	local my = proofToken
	local old = gui:FindFirstChild("Proof", true)
	if old then
		old:Destroy()
	end
	local plate = Instance.new("CanvasGroup")
	plate.Name = "Proof"
	plate.AnchorPoint = Vector2.new(0.5, 0.5)
	plate.Position = UDim2.fromScale(0.5, 0.36)
	plate.BackgroundColor3 = C.Green
	plate.BorderSizePixel = 0
	plate.ZIndex = 8
	local pc = Instance.new("UICorner")
	pc.CornerRadius = UDim.new(0.5, 0)
	pc.Parent = plate
	local edge = Instance.new("UIStroke")
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Color = C.GreenDark
	edge.Thickness = 3
	edge.Parent = plate
	local h = UIKit.px(0.11, 40, 56)
	local icon = UIKit.icon(plate, UIStyle.Icon.Check, { anchor = Vector2.new(0, 0.5), pos = UDim2.new(0, 6, 0.5, 0), size = UDim2.fromOffset(h - 10, h - 10) })
	local label = UIKit.text(plate, { name = "Text", key = key, args = args, font = "Title", anchor = Vector2.new(0, 0.5), max = 30 })
	local left = if icon then h else 14
	label.Position = UDim2.new(0, left, 0.5, 0)
	label.Size = UDim2.new(1, -left - 14, 0.7, 0)
	plate.Size = UDim2.fromOffset(math.floor(h * 5.2), h)
	plate.Parent = gui
	UIKit.pop(plate, 0.5)
	task.delay(1.6, function()
		if my == proofToken and plate.Parent then
			TweenService:Create(plate, TweenInfo.new(0.35), { GroupTransparency = 1 }):Play()
			task.delay(0.4, function()
				plate:Destroy()
			end)
		end
	end)
end

function HUD.gui(): ScreenGui
	return gui
end

-- a mini-game screen is up (MiniFrame / Scrub say so): the HUD attribute `Minigame` hides the job card, Buy parts, Invite
-- and the thumbstick — only the money bar, the leave button and the tool bar stay (user 10-22: "fewest things at once")
local miniOpen: { [string]: boolean } = {}
function HUD.minigame(key: string, on: boolean)
	miniOpen[key] = if on then true else nil :: any
	local any: boolean = next(miniOpen) ~= nil
	if gui and gui:GetAttribute("Minigame") ~= any then
		gui:SetAttribute("Minigame", any)
		hintLabel.Visible = not any -- (the tool hint line sat half under the plate: it steps out too)
		local touch = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("TouchGui")
		if touch and touch:IsA("ScreenGui") then
			touch.Enabled = not any
		end
	end
end

function HUD.start()
	gui = Instance.new("ScreenGui")
	gui.Name = "HUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")
	UIKit.setRoot(gui)

	-- the money bar: up in the top bar row (its centre is free), hanging below it when the row is thin (phones)
	bar = UIKit.plate(gui, { name = "MoneyBar", anchor = Vector2.new(0.5, 0), bolts = true })
	local function placeBar(size: Vector2)
		local h = UIKit.barHeight()
		-- narrow screens: keep clear of the corner buttons (settings, invite: Settings.luau sets CornerWidth)
		-- ...and of Roblox's own buttons on the left (narrow screens: the bar moves right and shrinks)
		local corner = ((gui:GetAttribute("CornerWidth") :: number?) or UIKit.px(0.11, 44, 52)) + 16
		local left, right = UIKit.topbarLeft() + 8, size.X - corner
		local w = math.floor(math.min(h * 6.6, right - left))
		bar.Size = UDim2.fromOffset(w, h)
		bar.Position = UDim2.new(0, math.clamp(size.X / 2, left + w / 2, right - w / 2), 0, -UIKit.topInset() + 4)
	end
	UIKit.bind(bar, placeBar)
	gui:GetAttributeChangedSignal("CornerWidth"):Connect(function()
		placeBar(UIKit.size())
	end)
	moneyLabel = UIKit.text(bar, {
		name = "Money",
		font = "Title",
		color = C.Cash,
		anchor = Vector2.new(0, 0.5),
		pos = UDim2.fromScale(0.05, 0.5),
		size = UDim2.fromScale(0.4, 0.72),
		alignX = Enum.TextXAlignment.Left,
		max = 40,
	})
	shownMoney.Changed:Connect(function(v)
		moneyLabel.Text = Localizer.t("hud.money", { money = math.floor(v + 0.5) })
	end)
	local split = Instance.new("Frame")
	split.Name = "Split"
	split.AnchorPoint = Vector2.new(0.5, 0.5)
	split.Position = UDim2.fromScale(0.47, 0.5)
	split.Size = UDim2.new(0, 2, 0.62, 0)
	split.BackgroundColor3 = C.PlateEdge
	split.BorderSizePixel = 0
	split.Parent = bar
	levelLabel = UIKit.text(bar, {
		name = "Level",
		anchor = Vector2.new(0, 0.5),
		pos = UDim2.fromScale(0.51, 0.31),
		size = UDim2.fromScale(0.3, 0.38),
		alignX = Enum.TextXAlignment.Left,
		max = 22,
	})
	local track = Instance.new("Frame")
	track.Name = "RepBar"
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.Position = UDim2.fromScale(0.51, 0.72)
	track.Size = UDim2.fromScale(0.3, 0.2)
	track.BackgroundColor3 = C.Black
	track.BorderSizePixel = 0
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = track
	track.Parent = bar
	repFill = Instance.new("Frame")
	repFill.Name = "Fill"
	repFill.Size = UDim2.fromScale(0.04, 1)
	repFill.BackgroundColor3 = C.Blue
	repFill.BorderSizePixel = 0
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = repFill
	local fg = Instance.new("UIGradient")
	fg.Color = ColorSequence.new(Color3.fromRGB(150, 215, 255), Color3.new(1, 1, 1))
	fg.Rotation = 90
	fg.Parent = repFill
	repFill.Parent = track
	starLabel = UIKit.text(bar, {
		name = "Stars",
		font = "Title",
		color = C.Gold,
		anchor = Vector2.new(1, 0.5),
		pos = UDim2.fromScale(0.96, 0.5),
		size = UDim2.fromScale(0.14, 0.62),
		alignX = Enum.TextXAlignment.Right,
		max = 30,
	})
	starLabel.Visible = false
	-- with no rating the level part takes the right side
	local function layout()
		local hasStars = player:GetAttribute("Stars") ~= nil
		local w = if hasStars then 0.3 else 0.43
		levelLabel.Size = UDim2.fromScale(w, 0.38)
		track.Size = UDim2.fromScale(w, 0.2)
	end
	layout()

	hintLabel = UIKit.text(gui, { name = "Hint", anchor = Vector2.new(0.5, 1), max = 22, rich = true })
	noticeLabel = UIKit.text(gui, { name = "Notice", font = "Bold", anchor = Vector2.new(0.5, 1), max = 24, wrap = true })
	noticeLabel.TextTransparency = 1
	noticeIcon = UIKit.icon(noticeLabel, UIStyle.Icon.Warning, { name = "Warning", anchor = Vector2.new(1, 0.5) })
	if noticeIcon then
		noticeIcon.Visible = false
	end
	-- a soft dark band under the hint / notice words, as wide as the words (wr-play TOP 8: white outlines, the tutorial
	-- ball and bright parts behind the line made it hard to read in the work view)
	local function backing(label: TextLabel)
		local band = Instance.new("Frame")
		band.Name = label.Name .. "Back"
		band.AnchorPoint = Vector2.new(0.5, 0.5)
		band.BackgroundColor3 = Color3.fromRGB(14, 16, 20)
		band.BorderSizePixel = 0
		band.Visible = false
		band.ZIndex = math.max(1, label.ZIndex - 1)
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(1, 0)
		bc.Parent = band
		band.Parent = label.Parent
		local function place()
			local z = UIKit.zoom()
			local b = label.TextBounds / z
			local on = label.Visible and label.Text ~= "" and b.X > 1 and label.TextTransparency < 0.95
			band.Visible = on
			if on then
				band.BackgroundTransparency = 0.5 + 0.5 * label.TextTransparency
				band.Size = UDim2.fromOffset(b.X + 28, b.Y + 8)
				local c = (label.AbsolutePosition + label.AbsoluteSize / 2 - (band.Parent :: GuiObject).AbsolutePosition) / z
				band.Position = UDim2.fromOffset(c.X, c.Y)
			end
		end
		for _, prop in { "TextBounds", "Visible", "TextTransparency", "AbsolutePosition", "Text" } do
			label:GetPropertyChangedSignal(prop):Connect(place)
		end
		place()
	end
	-- (the notice / hint over the job card's foot: a two-line notice ran under the card's corner on 667 — English pass 10-23)
	hintLabel.ZIndex = 3
	noticeLabel.ZIndex = 3
	backing(hintLabel)
	backing(noticeLabel)
	hintLabel:GetPropertyChangedSignal("Visible"):Connect(function()
		if hintLabel.Visible and gui:GetAttribute("Minigame") == true then
			hintLabel.Visible = false -- (a notice's end / the tool bar's tag ask for it back: not while a mini-game is up)
		end
	end)
	UIKit.bind(hintLabel, function()
		local above = HUD.hotbarHeight() + 24 -- (8 px more than before: the hint line needs air over the tool bar — GPT)
		local line = UIKit.px(0.06, 18, 30)
		hintLabel.Size = UDim2.new(0.7, 0, 0, line)
		hintLabel.Position = UDim2.new(0.5, 0, 1, -above)
		noticeLabel.Size = UDim2.new(0.6, 0, 0, line * 2)
		noticeLabel:SetAttribute("Pos", UDim2.new(0.5, 0, 1, -above - line - 6))
		noticeLabel:SetAttribute("WorkPos", UDim2.new(0.5, 0, 1, -above)) -- (the hint's own bottom: HUD.notify)
		noticeLabel.Position = noticeLabel:GetAttribute(if gui:GetAttribute("WorkView") then "WorkPos" else "Pos")
	end)

	-- (a hand-back's notice arrives just after the money: a moment's wait lets it hold the chip first)
	player:GetAttributeChangedSignal("Money"):Connect(function()
		task.delay(0.3, refresh)
	end)
	for _, name in { "Rep", "Level" } do
		-- (the hand-back's notice arrives just after the rep: a moment's wait lets it hold the bar first)
		player:GetAttributeChangedSignal(name):Connect(function()
			task.delay(0.4, refresh)
		end)
	end
	player:GetAttributeChangedSignal("Stars"):Connect(function()
		layout()
		refresh()
	end)
	UIKit.onLang(refresh)
	shownMoney.Value = player:GetAttribute("Money") or 0
	moneyKnown = player:GetAttribute("Money") ~= nil
	moneyLabel.Text = Localizer.t("hud.money", { money = shownMoney.Value })
	refresh()

	-- (the hand-back's "+$405, +15 rep" line: the settlement card says the money a moment later, and the rep shows
	-- as the bar filling — first10_payout §3 "no +15 Rep text"; the unfixed one stays, it says why the pay is low)
	local PAID = { ["n.paid"] = true, ["n.paidSpotOn"] = true, ["n.paidTeam"] = true, ["n.paidTip"] = true }
	Remotes.Notify.OnClientEvent:Connect(function(key, args, kind)
		if PAID[key] then
			-- a hand-back: the rep bar holds until the card closes (HUD.showRep; 60 s safety net if no card comes)
			repHeldUntil = os.clock() + 60
			moneyHeld = true
			task.delay(60.2, function()
				if os.clock() >= repHeldUntil then
					moneyHeld = false
				end
				refresh()
			end)
			return
		end
		HUD.notify(key, args, kind)
	end)
end

return HUD
