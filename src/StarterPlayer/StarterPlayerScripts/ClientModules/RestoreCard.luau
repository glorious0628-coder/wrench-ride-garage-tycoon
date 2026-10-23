-- The restoration card (loop B step 2): while you're near a car being restored, the left side shows its
-- restoration % and grade (badge + the grade word) and the work list the server keeps (RestoreService: wash, body
-- parts, rust spots with their next step, mechanical faults fixed). Done lines get a check. UI B look (UIKit plate).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local RestoreCard = {}

local C = UIStyle.Color
local player = Players.LocalPlayer
local frame: Frame
local list: Frame
local badge: ImageLabel
local gradeLabel: TextLabel
local pctLabel: TextLabel
local shown: Model? = nil
local lastList: string? = nil

local function line(t: string, done: boolean, order: number)
	local row = Instance.new("Frame")
	row.Name = "Line"
	row.Size = UDim2.new(1, 0, 0, 0)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.BackgroundTransparency = 1
	row.LayoutOrder = order
	row.Parent = list
	-- a check when done, an empty ring when not
	local mark: GuiObject
	if done and UIStyle.Icon.Check ~= "" then
		mark = UIKit.icon(row, UIStyle.Icon.Check, { anchor = Vector2.new(0, 0), pos = UDim2.new() }) :: ImageLabel
	else
		local ring = Instance.new("Frame")
		ring.BackgroundTransparency = 1
		local s = Instance.new("UIStroke")
		s.Color = C.PlateEdge
		s.Thickness = 2
		s.Parent = ring
		local rc = Instance.new("UICorner")
		rc.CornerRadius = UDim.new(1, 0)
		rc.Parent = ring
		ring.Parent = row
		mark = ring
	end
	local l = Instance.new("TextLabel")
	l.Text = t
	l.BackgroundTransparency = 1
	l.FontFace = UIStyle.Font.Body
	l.TextColor3 = if done then C.Good else C.White
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.Parent = row
	UIKit.bind(l, function()
		local ts = UIKit.px(0.04, 12, 16)
		l.TextSize = ts
		local m = math.floor(ts * 1.1)
		-- (the ring's stroke sits outside it: a little smaller so it matches the check)
		local d = if done then m else m - 4
		mark.Size = UDim2.fromOffset(d, d)
		mark.Position = UDim2.fromOffset((m - d) / 2, 2 + (m - d) / 2)
		l.Position = UDim2.fromOffset(m + 6, 0)
		l.Size = UDim2.new(1, -(m + 6), 0, 0)
	end)
end

local function render(car: Model)
	local grade = (car:GetAttribute("Grade") :: string?) or "None"
	local id = UIStyle.Badge[grade]
	badge.Image = id or ""
	badge.Visible = id ~= nil
	UIKit.setText(gradeLabel, "grade." .. grade)
	gradeLabel.TextColor3 = UIStyle.GradeColor[grade] or UIStyle.GradeColor.None
	UIKit.setText(pctLabel, "ui.restore.pct", { pct = car:GetAttribute("RestorePct") or 0 })
	local raw = (car:GetAttribute("RestoreList") :: string?) or "[]"
	if raw == lastList then
		return
	end
	lastList = raw
	for _, c in list:GetChildren() do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
	local ok, items = pcall(HttpService.JSONDecode, HttpService, raw)
	for i, it in (if ok then items else {}) do
		line(Localizer.t(it.k, it.a), it.done == true, i)
	end
end

local function nearest(): Model?
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local cars = workspace:FindFirstChild("Cars")
	if not root or not cars then
		return nil
	end
	for _, c in cars:GetChildren() do
		if c:IsA("Model") and c:GetAttribute("Restore") and c:GetAttribute("Parked") and (c:GetPivot().Position - root.Position).Magnitude < 26 then
			return c
		end
	end
	return nil
end

function RestoreCard.start()
	-- left side, under the money bar row, above the phone joystick
	frame = UIKit.plate(HUD.gui(), { name = "RestoreCard", anchor = Vector2.new(0, 0), bolts = true })
	frame.Position = UDim2.new(0, 8, 0, 8)
	frame.Size = UDim2.fromScale(0.3, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Visible = false
	local limit = Instance.new("UISizeConstraint")
	limit.MinSize = Vector2.new(210, 0)
	limit.MaxSize = Vector2.new(330, math.huge)
	limit.Parent = frame
	-- (the content lives in its own frame: a list layout on the plate would also move the corner bolts)
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.Parent = frame
	local pad = Instance.new("UIPadding")
	pad.Parent = content
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content

	-- the header: badge, the grade word big, "Restoration 96%" small above it
	local head = Instance.new("Frame")
	head.Name = "Header"
	head.BackgroundTransparency = 1
	head.LayoutOrder = 1
	head.Parent = content
	badge = Instance.new("ImageLabel")
	badge.Name = "Badge"
	badge.BackgroundTransparency = 1
	badge.ScaleType = Enum.ScaleType.Fit
	badge.SizeConstraint = Enum.SizeConstraint.RelativeYY
	badge.Size = UDim2.fromScale(1, 1)
	badge.Parent = head
	pctLabel = UIKit.text(head, {
		name = "Pct",
		color = C.SteelLight,
		anchor = Vector2.new(0, 0),
		alignX = Enum.TextXAlignment.Left,
		max = 16,
	})
	gradeLabel = UIKit.text(head, {
		name = "Grade",
		font = "Title",
		anchor = Vector2.new(0, 1),
		alignX = Enum.TextXAlignment.Left,
		max = 30,
	})

	list = Instance.new("Frame")
	list.Name = "List"
	list.BackgroundTransparency = 1
	list.Size = UDim2.new(1, 0, 0, 0)
	list.AutomaticSize = Enum.AutomaticSize.Y
	list.LayoutOrder = 2
	list.Parent = content
	local ll = Instance.new("UIListLayout")
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	ll.Parent = list

	UIKit.bind(frame, function()
		local p = UIKit.px(0.03, 8, 14)
		pad.PaddingTop, pad.PaddingBottom = UDim.new(0, p), UDim.new(0, p)
		pad.PaddingLeft, pad.PaddingRight = UDim.new(0, p + 2), UDim.new(0, p + 2)
		layout.Padding = UDim.new(0, UIKit.px(0.02, 4, 8))
		ll.Padding = UDim.new(0, UIKit.px(0.01, 2, 5))
		local h = UIKit.px(0.13, 44, 64)
		head.Size = UDim2.new(1, 0, 0, h)
		-- the words start after the badge (the badge is as wide as the header is tall)
		pctLabel.Position = UDim2.new(0, h + 8, 0, 0)
		pctLabel.Size = UDim2.new(1, -(h + 8), 0.38, 0)
		gradeLabel.Position = UDim2.new(0, h + 8, 1, 0)
		gradeLabel.Size = UDim2.new(1, -(h + 8), 0.6, 0)
	end)

	Localizer.Changed.Event:Connect(function()
		lastList = nil -- the work list is drawn again in the new language
	end)
	task.spawn(function()
		while true do
			local car = nearest()
			if car ~= shown then
				shown = car
				lastList = nil
			end
			frame.Visible = car ~= nil
			if car then
				render(car)
			end
			task.wait(0.3)
		end
	end)
end

return RestoreCard
