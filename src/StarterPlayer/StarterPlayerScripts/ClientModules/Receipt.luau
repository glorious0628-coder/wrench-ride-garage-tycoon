-- Today's receipt (docs/design/daily_receipt.md v0.3): a short look back over a shift — never a minus, never a
-- comparison. The server sends it (Remotes.Receipt: kind "last" = the previous visit, 3 s after spawning; "this" =
-- so far, from the front desk printer) with my share only:
--   { cars, spotOn, earned, rep, repFrom, repTo, levelFrom, levelTo, unlocks = { "@key", ... }, restored,
--     restoredEarned, customer = { name = "@npc.X" }?, crew = { "Name", ... }, waiting = "key"?, waitingArgs = {}? }
--   (waiting = the car waiting for you, with its customer's name in waitingArgs — daily_receipt §5b)
-- A paper slip slides in from the right: the lines (numbers big; 5 on a phone, 7 on a PC), the level bar with what
-- this shift added in its own colour, a red THANK YOU! stamp that thumps on beside the title, then one Nice! (two
-- buttons that both only close it were one choice too many). GPT 2 rounds: notes/gpt/wr-ui/receipt_decision.md.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local HUD = require(script.Parent.HUD)
local SoundPlayer = require(script.Parent.SoundPlayer)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local Receipt = {}

local C = UIStyle.Color
local MONO = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold) -- (the header only)
local PAPER = Color3.fromRGB(250, 247, 238)
local INK = Color3.fromRGB(40, 38, 36)
local SOFT = Color3.fromRGB(110, 106, 98)
local STAMP = Color3.fromRGB(206, 40, 36)

local slip: CanvasGroup? = nil

-- reputation inside a level, 0..1 (as the money bar's)
local function share(rep: number, level: number): number
	local levels = Config.GarageLevels
	local lo, hi = levels[level], levels[level + 1]
	if not lo or not hi then
		return 1
	end
	return math.clamp((rep - lo) / (hi - lo), 0, 1)
end

function Receipt.close()
	local s = slip
	if not s then
		return
	end
	slip = nil
	TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = s.Position + UDim2.fromScale(0.3, 0),
		GroupTransparency = 1,
	}):Play()
	task.delay(0.3, function()
		s:Destroy()
	end)
end

-- a label that keeps one fixed size (no shrinking to fit: GPT — shrunk text was the problem); cut with … if long
local function word(parent: Instance, name: string, font: Font, color: Color3, size: number, alignX: Enum.TextXAlignment): TextLabel
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.FontFace = font
	l.TextColor3 = color
	l.TextSize = size
	l.TextXAlignment = alignX
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = parent
	return l
end

function Receipt.show(kind: string, data: { [string]: any })
	if (data.cars or 0) <= 0 then
		return -- nothing done: no receipt (daily_receipt §2)
	end
	if slip then
		slip:Destroy()
	end
	local phone = not UIKit.keyboard()
	local screen = UIKit.size()
	local body = UIKit.px(0.043, 14, 18) -- line words
	local num = UIKit.px(0.058, 18, 24) -- line numbers
	local rowH = UIKit.px(0.072, 23, 32)

	local s = Instance.new("CanvasGroup")
	s.Name = "Receipt"
	s.AnchorPoint = Vector2.new(1, 0.5)
	s.BackgroundColor3 = PAPER
	s.BorderSizePixel = 0
	s.ZIndex = 7
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = s
	-- most of the screen height on a phone (it may cover the tool bar: a short look back, closed with one tap);
	-- under the money bar row; on a PC the upper right half
	local top = math.max(0, UIKit.barHeight() + 4 - UIKit.topInset()) + 6
	local h = math.floor(math.min(screen.Y * (if phone then 0.88 else 0.62), 470))
	local w = math.floor(math.min(h * 1.05, screen.X * 0.5))
	s.Size = UDim2.fromOffset(w, h)
	s.Position = UDim2.new(1, -12, 0, top + h / 2)
	-- wr-art's paper (9-sliced) with its torn edge along the bottom (tiled sideways); else the plain colour
	local edgeH = 0
	local paper = UIKit.skin(s, "paper", function()
		return 14
	end)
	local ek = UIStyle.Kit.paperEdge
	if paper and ek and ek.id ~= "" then
		edgeH = 10
		paper.Size = UDim2.new(1, 0, 1, -edgeH + 1)
		corner.CornerRadius = UDim.new(0, 0)
		local r = ek.rect
		local torn = Instance.new("ImageLabel")
		torn.Name = "Torn"
		torn.BackgroundTransparency = 1
		torn.Image = ek.id
		torn.ImageRectOffset = Vector2.new(r[1], r[2])
		torn.ImageRectSize = Vector2.new(r[3] - r[1], r[4] - r[2])
		torn.ScaleType = Enum.ScaleType.Tile
		torn.TileSize = UDim2.fromOffset(math.floor(edgeH * (r[3] - r[1]) / (r[4] - r[2])), edgeH)
		torn.AnchorPoint = Vector2.new(0, 1)
		torn.Position = UDim2.fromScale(0, 1)
		torn.Size = UDim2.new(1, 0, 0, edgeH)
		torn.ZIndex = 0
		torn.Parent = s
	end

	local rows = Instance.new("Frame") -- (the rows in their own frame: the stamp sits over them)
	rows.Name = "Rows"
	rows.BackgroundTransparency = 1
	rows.Size = UDim2.fromScale(1, 1)
	rows.Parent = s
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 16), UDim.new(0, 16)
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 8), UDim.new(0, 10 + edgeH)
	pad.Parent = rows
	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.Padding = UDim.new(0, 2)
	list.Parent = rows
	local order = 0
	local function slot(height: number): Frame
		order += 1
		local f = Instance.new("Frame")
		f.Name = "Row" .. order
		f.LayoutOrder = order
		f.BackgroundTransparency = 1
		f.Size = UDim2.new(1, 0, 0, height)
		f.Parent = rows
		return f
	end
	local function dashes()
		local d = word(slot(10), "Dashes", MONO, Color3.fromRGB(160, 156, 148), 10, Enum.TextXAlignment.Center)
		d.Size = UDim2.fromScale(1, 1)
		d.Text = string.rep("- ", 60)
		d.TextTruncate = Enum.TextTruncate.None
		d.Parent.ClipsDescendants = true
	end

	-- header + title (the stamp gets its own spot at the title row's right end)
	local header = word(slot(14), "Header", MONO, SOFT, 11, Enum.TextXAlignment.Left)
	header.Size = UDim2.fromScale(1, 1)
	-- the garage's own name on the paper once it has one (rival_upgrade B2-5 #8): "MIKE'S GARAGE · GEARPORT" (a middle dot like the default header)
	local gname = workspace:GetAttribute("GarageName")
	if type(gname) == "string" and gname ~= "" then
		header.Text = string.upper(gname) .. " · GEARPORT"
	else
		UIKit.setText(header, "receipt.header")
	end
	local titleRow = slot(UIKit.px(0.085, 28, 38))
	local title = word(titleRow, "Title", UIStyle.Font.Title, INK, UIKit.px(0.065, 21, 26), Enum.TextXAlignment.Left)
	title.Size = UDim2.new(1, -140, 1, 0)
	UIKit.setText(title, if kind == "last" then "receipt.title.last" else "receipt.title.this")
	dashes()

	-- one "words ...... number" line
	local function line(key: string, args: { [string]: any }?, valueKey: string?, valueArgs: { [string]: any }?, valueText: string?): TextLabel
		local f = slot(rowH)
		local l = word(f, "Label", UIStyle.Font.Body, INK, body, Enum.TextXAlignment.Left)
		l.Size = UDim2.fromScale(0.62, 1)
		UIKit.setText(l, key, args)
		local v = word(f, "Value", UIStyle.Font.Title, INK, num, Enum.TextXAlignment.Right)
		v.AnchorPoint = Vector2.new(1, 0)
		v.Position = UDim2.fromScale(1, 0)
		v.Size = UDim2.fromScale(0.4, 1)
		if valueKey then
			UIKit.setText(v, valueKey, valueArgs)
		else
			v.Text = valueText or ""
		end
		return v
	end
	-- one full-width line (words that would not fit beside a label)
	local function wide(key: string, args: { [string]: any }?)
		local l = word(slot(rowH), "Wide", UIStyle.Font.Body, INK, body, Enum.TextXAlignment.Left)
		l.Size = UDim2.fromScale(1, 1)
		UIKit.setText(l, key, args)
	end

	-- the lines, most important first; a phone shows 5 (GPT: 7 + a note + buttons was too much for 390 px)
	local maxLines = if phone then 5 else ((Config.Receipt and Config.Receipt.MaxLines) or 7)
	local shown = 0
	local function room(): boolean
		shown += 1
		return shown <= maxLines
	end
	if room() then
		line("receipt.cars", nil, nil, nil, tostring(data.cars))
	end
	if room() then
		line("receipt.earned", nil, "hud.money", { money = math.max(data.earned or 0, 0) }).TextColor3 = C.Price
	end
	if room() then
		local levelTo = data.levelTo or 1
		local up = levelTo > (data.levelFrom or levelTo)
		line("receipt.rep", nil, if up then "ui.receipt.repUp" else "ui.receipt.rep", { rep = math.max(data.rep or 0, 0), level = levelTo })
		-- the level bar: what this shift added in the bright colour. A level gained: the bar fills to the end,
		-- then starts again and fills to where the new level really is (a full bar at rest would read 'maxed')
		local track = Instance.new("Frame")
		track.Name = "LevelBar"
		track.Size = UDim2.new(1, 0, 0, 8)
		track.BackgroundColor3 = Color3.fromRGB(214, 210, 200)
		track.BorderSizePixel = 0
		local tc = Instance.new("UICorner")
		tc.CornerRadius = UDim.new(1, 0)
		tc.Parent = track
		track.Parent = slot(10)
		local before = if up then 0 else share(data.repFrom or 0, levelTo)
		local after = share(data.repTo or 0, levelTo)
		for i, part in { { "Before", before, C.BlueDark }, { "Gain", after, C.Blue } } do
			local fill = Instance.new("Frame")
			fill.Name = part[1] :: string
			fill.ZIndex = 3 - i
			fill.Size = UDim2.fromScale(if i == 1 then math.max(part[2] :: number, 0.03) else 0, 1)
			fill.BackgroundColor3 = part[3] :: Color3
			fill.BorderSizePixel = 0
			local fc = Instance.new("UICorner")
			fc.CornerRadius = UDim.new(1, 0)
			fc.Parent = fill
			fill.Parent = track
			if i == 2 then
				local final = UDim2.fromScale(math.max(part[2] :: number, 0.03), 1)
				if up then
					local fillUp = TweenService:Create(fill, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Size = UDim2.fromScale(1, 1) })
					fillUp.Completed:Connect(function()
						fill.Size = UDim2.fromScale(0, 1)
						TweenService:Create(fill, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Size = final }):Play()
					end)
					fillUp:Play()
				else
					TweenService:Create(fill, TweenInfo.new(0.8, Enum.EasingStyle.Quad), { Size = final }):Play()
				end
			end
		end
	end
	if (data.spotOn or 0) > 0 and room() then
		line("receipt.spotOn", nil, nil, nil, tostring(data.spotOn))
	end
	-- growth first (the garage grows): what's new, else the customer of the shift
	local unlocks = data.unlocks or {}
	if #unlocks > 0 and room() then
		wide(if #unlocks > 1 then "ui.receipt.newMore" else "ui.receipt.newOne", { a = unlocks[1], n = #unlocks - 1 })
	end
	if data.customer and data.customer.name and room() then
		wide("ui.receipt.customerLine", { who = data.customer.name })
	end
	if (data.restored or 0) > 0 and room() then
		line("receipt.restored", nil, "ui.receipt.restoredVal", { n = data.restored, money = data.restoredEarned or 0 })
	end
	if data.crew and #data.crew > 0 and room() then
		line("receipt.crew", nil, nil, nil, table.concat(data.crew, ", "))
	end
	-- the barcode closes the lines (the dashes when there's no picture)
	local bk = UIStyle.Kit.barcode
	if bk and bk.id ~= "" then
		local r = bk.rect
		local code = Instance.new("ImageLabel")
		code.Name = "Barcode"
		code.BackgroundTransparency = 1
		code.Image = bk.id
		code.ImageRectOffset = Vector2.new(r[1], r[2])
		code.ImageRectSize = Vector2.new(r[3] - r[1], r[4] - r[2])
		code.ScaleType = Enum.ScaleType.Fit
		code.Size = UDim2.fromScale(0.6, 1)
		code.AnchorPoint = Vector2.new(0.5, 0)
		code.Position = UDim2.fromScale(0.5, 0)
		code.Parent = slot(UIKit.px(0.05, 16, 22))
	else
		dashes()
	end
	if data.waiting then
		local note = word(slot(rowH - 4), "Waiting", UIStyle.Font.Bold, C.OrangeDark, body, Enum.TextXAlignment.Center)
		note.Size = UDim2.fromScale(1, 1)
		UIKit.setText(note, data.waiting, data.waitingArgs)
	end

	-- one button (44 px+)
	local buttons = slot(math.max(UIKit.px(0.13, 44, 56), 44))
	buttons.Name = "Buttons"
	local nice = UIKit.button(buttons, { name = "Nice", key = "receipt.nice", style = "Green", size = UDim2.fromScale(0.6, 1), max = 24, onClick = Receipt.close })
	UIKit.fitButton(nice, { text = 0.56, pad = 0.5, min = 2.6, max = 24 }) -- (as wide as its words: user 10-22)

	-- the THANK YOU! stamp: its own spot at the right end of the title row (8 px+ from the title, never over a
	-- number), thumps on after the slip is in
	local stamp = word(titleRow, "Stamp", UIStyle.Font.Title, STAMP, 16, Enum.TextXAlignment.Center)
	stamp.TextTruncate = Enum.TextTruncate.None
	stamp.TextScaled = true
	stamp.AnchorPoint = Vector2.new(1, 0.5)
	stamp.Position = UDim2.new(1, -44, 0.5, 0)
	stamp.Size = UDim2.new(0, 84, 0.8, 0)
	stamp.Rotation = 10
	stamp.ZIndex = 9
	UIKit.setText(stamp, "receipt.stamp")
	local box = Instance.new("UIStroke")
	box.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	box.Color = STAMP
	box.Thickness = 2
	box.Parent = stamp
	stamp.TextTransparency = 1
	box.Transparency = 1

	-- a corner X (it only closes, same as Nice!: a paper nobody could shut was the wr-gamer finding); 40 px = a thumb
	local x = UIKit.closeButton(s, { name = "Close", anchor = Vector2.new(1, 0), pos = UDim2.new(1, -4, 0, 4) }, Receipt.close)
	x.ZIndex = 10

	s.GroupTransparency = 1
	s.Parent = HUD.gui()
	slip = s
	-- it never stays over the next thing: a work view opening, or 30 s, closes it
	local gui = HUD.gui()
	local conn = gui:GetAttributeChangedSignal("WorkView"):Connect(function()
		if gui:GetAttribute("WorkView") and slip == s then
			Receipt.close()
		end
	end)
	s.Destroying:Connect(function()
		conn:Disconnect()
	end)
	task.delay(30, function()
		if slip == s then
			Receipt.close()
		end
	end)
	-- ... and a card that matters more (the settlement, a level-up, any window) takes its place (GPT r1)
	task.spawn(function()
		while slip == s do
			task.wait(0.3)
			if gui:FindFirstChild("PayCard", true) or gui:FindFirstChild("LevelUp", true) or gui:GetAttribute("WindowOpen") then
				Receipt.close()
			end
		end
	end)
	local home = s.Position
	s.Position = home + UDim2.fromScale(0.3, 0)
	TweenService:Create(s, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = home, GroupTransparency = 0 }):Play()
	task.delay(0.7, function()
		if slip ~= s then
			return
		end
		stamp.TextTransparency = 0
		box.Transparency = 0
		UIKit.pop(stamp, 1.6)
		if not SoundPlayer.play("stamp") then
			SoundPlayer.play("reward")
		end
	end)
end

function Receipt.start()
	local event = (Remotes :: any).Receipt
	if event then
		event.OnClientEvent:Connect(function(kind, data)
			if type(data) == "table" then
				Receipt.show(kind, data)
			end
		end)
	end
end

return Receipt
