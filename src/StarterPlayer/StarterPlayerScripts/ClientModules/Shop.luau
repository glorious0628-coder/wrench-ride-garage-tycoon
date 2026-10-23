-- The parts counter window: opens from the counter's "Buy parts" prompt. Tabs (Engine / Brakes / Wheels / Body /
-- Exhaust), one row per part kind (icon, name, price, Buy); Buy asks the server (Remotes.BuyPart). Closes when you
-- walk away. UI B look (UIKit window).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)
local StoreUI = require(script.Parent.StoreUI)

local Shop = {}

local C = UIStyle.Color
local TABS = { "Engine", "Brakes", "Wheels", "Body", "Exhaust" }
local TAB_OF = { Battery = "Engine", Radiator = "Engine", BrakePads = "Brakes", Wheel = "Wheels", Hood = "Body", Bumper = "Body", Muffler = "Exhaust" }
-- customers with a name of their own (the tutorial's): "For Mrs. Rosa Delgado"
local NAMED = { Rosa = true, Tyler = true }

local player = Players.LocalPlayer
local frame: CanvasGroup
local list: ScrollingFrame
local header: TextLabel
local link: TextButton
local empty: TextLabel
local tabs: UIKit.Tabs
local openedAt: Vector3? = nil
local layout: () -> ()

local function showTab(id: string)
	local any = false
	for _, row in list:GetChildren() do
		if row:IsA("Frame") then
			row.Visible = TAB_OF[row.Name] == id
			any = any or row.Visible
		end
	end
	empty.Visible = not any
	list.CanvasPosition = Vector2.zero
end

-- that part's tab, its row first with a yellow edge: the tutorial's part ("Buy a new battery": tutorial_script §2-6),
-- else the part the nearest customer car's found problem needs (test 2 TOP7: an ordinary customer's counter opened on
-- whatever tab was last — wheels for a bumper job)
local focusKind: string? = nil -- shown now
local tutKind: string? = nil -- the tutorial's (Shop.focus)
local jobKind: string? = nil -- the found problem's (Shop.open)

local function applyFocus()
	local kind = tutKind or jobKind
	if kind == focusKind or not frame then
		return
	end
	focusKind = kind
	for _, row in list:GetChildren() do
		if row:IsA("Frame") then
			local on = row.Name == kind
			if row:GetAttribute("Order") == nil then
				row:SetAttribute("Order", row.LayoutOrder)
			end
			row.LayoutOrder = if on then -1 else row:GetAttribute("Order") :: number
			local edge = row:FindFirstChildOfClass("UIStroke")
			if edge then
				edge.Color = if on then C.Yellow else C.RowEdge
				edge.Thickness = if on then UIKit.px(0.012, 3, 5) else UIKit.px(UIStyle.Size.Stroke, 1, 4)
			end
		end
	end
	if kind and TAB_OF[kind] then
		tabs.select(TAB_OF[kind])
		showTab(TAB_OF[kind])
	end
end

function Shop.focus(kind: string?)
	tutKind = kind
	applyFocus()
end

-- the customer car parked nearest the counter, if its owner has a name ("For Tyler") — or it's a tutorial car,
-- whose customer has none ("For the customer's car": test 1, the third car opened with no line)
local function customerName(): (string?, boolean, Model?)
	local cars = workspace:FindFirstChild("Cars")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not cars or not root then
		return nil, false
	end
	local best, bestD = nil, 80
	for _, c in cars:GetChildren() do
		if c:IsA("Model") and c:GetAttribute("Parked") then
			local d = (c:GetPivot().Position - root.Position).Magnitude
			if d < bestD then
				best, bestD = c, d
			end
		end
	end
	local who = best and best:GetAttribute("CustomerKind")
	if who and NAMED[who] then
		return "@npc." .. who, true, best -- (a key: it follows the language)
	end
	return nil, best ~= nil, best -- (every customer's car: "For the customer's car" — test 2 TOP7)
end

-- the part kind the car's found problem needs (its clue on one of its faulty slots), if it's found yet
local function foundKind(car: Model?): string?
	if not car or car:GetAttribute("Fixed") == true then
		return nil
	end
	local faults = {}
	for _, slot in string.split((car:GetAttribute("Faults") :: string?) or "", ",") do
		faults[slot] = true
	end
	local ok, clues = pcall(HttpService.JSONDecode, HttpService, (car:GetAttribute("Clues") :: string?) or "[]")
	for _, clue in (if ok and type(clues) == "table" then clues else {}) do
		local slot = type(clue) == "table" and clue.a and clue.a.slot
		local info = slot and faults[slot] and CarParts.Slots[slot]
		if info then
			return info.kind
		end
	end
	return nil
end

-- tabs, the "For ..." line and the list from the top of the steel panel, in touch-size pixels (not the concept
-- picture's proportions: GPT ui3 note)
layout = function()
	local pad = UIKit.px(0.02, 4, 10)
	-- (a phone: three rows must show — wr-uidesign A⑤; the window comes down over the tool bar, nothing to hold while shopping)
	local phone = UIKit.size().Y < 500
	local tabsH = if phone then UIKit.px(0.095, 34, 40) else UIKit.px(0.12, 46, 60)
	local lineOn = header.Visible or link.Visible
	local headerH = if lineOn then UIKit.px(if phone then 0.05 else 0.055, 15, 26) else 0
	tabs.frame.Position = UDim2.new(0.5, 0, 0, pad)
	tabs.frame.Size = UDim2.new(0.96, 0, 0, tabsH)
	header.Position = UDim2.new(0.03, 0, 0, pad * 1.6 + tabsH)
	header.Size = UDim2.new(0.62, 0, 0, headerH)
	-- the small Robux shop link on the same line, at the right end (a different kind of money: kept apart from the parts)
	link.Position = UDim2.new(0.97, 0, 0, pad * 1.6 + tabsH + headerH / 2)
	link.Size = UDim2.new(0.32, 0, 0, math.max(headerH, 24))
	local y = pad * 2 + tabsH + (if lineOn then headerH + pad * 0.6 else 0)
	list.Position = UDim2.new(0.5, 0, 0, y)
	list.Size = UDim2.new(0.96, 0, 1, -y - pad)
	local rowH = if phone then UIKit.px(0.135, 50, 56) else UIKit.px(0.17, 58, 88)
	for _, row in list:GetChildren() do
		if row:IsA("Frame") then
			row.Size = UDim2.new(0.97, 0, 0, rowH)
		end
	end
end

function Shop.close()
	UIKit.close(frame)
	openedAt = nil
end

function Shop.open()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	openedAt = root and root.Position
	local who, any, car = customerName()
	UIKit.setText(header, if who then "ui.shop.for" elseif any then "ui.shop.forCustomer" else nil, if who then { who = who } else nil)
	header.Visible = any
	link.Visible = StoreUI.anyOn() -- (only when something is on sale)
	layout()
	showTab(tabs.selected() or TABS[1])
	jobKind = foundKind(car)
	focusKind = "?" -- (re-apply: the rows / tab for this car now)
	applyFocus()
	UIKit.open(frame)
end

function Shop.start()
	local win = UIKit.window(HUD.gui(), { name = "Shop", title = "shop.title", overHotbar = true, onClose = Shop.close })
	frame = win.root
	win.close.Name = "Close"
	local items = {}
	for _, id in TABS do
		table.insert(items, { id = id, key = "ui.tab." .. id })
	end
	tabs = UIKit.tabs(win.body, items, {}, showTab)
	tabs.select(TABS[1])
	header = UIKit.text(win.body, {
		name = "Header",
		font = "Bold",
		color = C.Ink,
		outline = false,
		anchor = Vector2.new(0, 0),
		alignX = Enum.TextXAlignment.Left,
		max = 26,
	})
	-- "Robux shop ›": a small link (no button box, no pop-up) — opens the Garage Shop when the player asks
	link = Instance.new("TextButton")
	link.Name = "RobuxLink"
	link.AnchorPoint = Vector2.new(1, 0.5)
	link.BackgroundTransparency = 1
	link.AutoButtonColor = false
	link.FontFace = UIStyle.Font.Bold
	link.TextColor3 = C.BlueDark
	link.TextSize = 18
	link.TextXAlignment = Enum.TextXAlignment.Right
	link.TextTruncate = Enum.TextTruncate.AtEnd
	link.Visible = false
	link.Parent = win.body
	UIKit.setText(link, "store.counter")
	link.Activated:Connect(function()
		Shop.close()
		StoreUI.open()
	end)
	UIKit.bind(link, function()
		link.TextSize = UIKit.px(0.045, 15, 20)
	end)
	list = UIKit.list(win.body, { name = "Rows" })
	empty = UIKit.text(win.body, {
		name = "Empty",
		key = "ui.shop.empty",
		color = C.InkSoft,
		outline = false,
		pos = UDim2.fromScale(0.5, 0.55),
		size = UDim2.fromScale(0.8, 0.1),
		max = 22,
	})

	local kinds = {}
	for k in CarParts.Kinds do
		if CarParts.sold(k) then -- (wr-dev: piece E / E2 kinds only once their parts are live)
			table.insert(kinds, k)
		end
	end
	table.sort(kinds, function(a, b)
		return CarParts.Kinds[a].price < CarParts.Kinds[b].price
	end)
	for i, kind in kinds do
		local row = UIKit.row(list, { name = kind })
		row.LayoutOrder = i
		local icon = UIKit.icon(row, UIStyle.Icon[kind], {
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(0.02, 0.5),
			size = UDim2.fromScale(0.13, 0.84),
			-- (Fit keeps the icon square inside this box)
		})
		local left = if icon then 0.17 else 0.04
		UIKit.text(row, {
			name = "Name",
			key = "part." .. kind,
			font = "Bold",
			color = C.Ink,
			outline = false,
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(left, 0.5),
			size = UDim2.fromScale(0.62 - left, 0.46),
			alignX = Enum.TextXAlignment.Left,
			max = 30,
		})
		UIKit.text(row, {
			name = "Price",
			key = "hud.money",
			args = { money = CarParts.Kinds[kind].price },
			font = "Title",
			color = C.Price,
			outline = false,
			pos = UDim2.fromScale(0.645, 0.5),
			size = UDim2.fromScale(0.15, 0.46),
			max = 30,
		})
		UIKit.button(row, {
			name = "Buy",
			key = "ui.buy",
			anchor = Vector2.new(1, 0.5),
			pos = UDim2.fromScale(0.975, 0.5),
			size = UDim2.fromScale(0.22, 0.8),
			max = 30,
			onClick = function()
				local ok, key, args = Remotes.BuyPart:InvokeServer(kind)
				if key then
					HUD.notify(key, args, if ok then "good" else "bad")
				end
			end,
		})
	end

	header.Visible = false
	UIKit.bind(frame, function()
		layout()
	end)

	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt.Name == "ShopPrompt" then
			Shop.open()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.3)
			if openedAt then
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				if not root or (root.Position - openedAt).Magnitude > Config.ShopReach * 0.6 then
					Shop.close()
				end
			end
		end
	end)
end

return Shop
