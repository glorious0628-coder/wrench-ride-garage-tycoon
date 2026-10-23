-- The dealer window (loop B step 3): opens from the DealerPrompt at the junkyard office window or the showroom
-- desk. One card per restored car you own: market value, Sell now, State Inspection (SALVAGE), Put in showroom.
-- Every button asks the server (Remotes.Dealer), then the list reloads. UI B look (UIKit window).

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local Dealer = {}

local C = UIStyle.Color
local player = Players.LocalPlayer
local frame: CanvasGroup
local scroll: ScrollingFrame
local empty: TextLabel
local openedAt: Vector3? = nil

local reload: () -> ()

local function act(action: string, id: number)
	local ok, key, args = Remotes.Dealer:InvokeServer(action, id)
	if key then
		HUD.notify(key, args, if ok then "good" else "bad")
	end
	reload()
end

reload = function()
	for _, c in scroll:GetChildren() do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
	local rows = Remotes.Dealer:InvokeServer("list")
	empty.Visible = type(rows) ~= "table" or #rows == 0
	if empty.Visible then
		return
	end
	for i, r in rows do
		local card = UIKit.row(scroll, { name = "Car" .. i })
		card.LayoutOrder = i
		-- the grade badge in front of the title (the title says the grade word too)
		local badge = UIKit.icon(card, UIStyle.Badge[r.grade], {
			name = "Badge",
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(0.025, 0.21),
			size = UDim2.fromScale(0.3, 0.32),
		})
		if badge then
			badge.SizeConstraint = Enum.SizeConstraint.RelativeYY
		end
		local title = UIKit.text(card, {
			name = "Title",
			text = Localizer.t("dl.row", { title = "@tt." .. r.title, pct = r.pct, grade = "@grade." .. r.grade }),
			font = "Bold",
			color = C.Ink,
			outline = false,
			anchor = Vector2.new(0, 0.5),
			alignX = Enum.TextXAlignment.Left,
			max = 26,
		})
		UIKit.bind(card, function()
			local h = UIKit.px(0.36, 124, 180)
			card.Size = UDim2.new(0.97, 0, 0, h)
			-- the title starts after the badge (the badge is sized from the card height)
			local x = if badge then math.floor(h * 0.32) + 8 else 0
			title.Position = UDim2.new(0.035, x, 0.2, 0)
			title.Size = UDim2.new(0.93, -x, 0.22, 0)
		end)
		UIKit.text(card, {
			name = "Value",
			text = Localizer.t("dl.value", { value = r.value }),
			font = "Title",
			color = C.Price,
			outline = false,
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(0.035, 0.44),
			size = UDim2.fromScale(0.45, 0.18),
			alignX = Enum.TextXAlignment.Left,
			max = 22,
		})
		if r.reason and not r.canDisplay then
			UIKit.text(card, {
				name = "Reason",
				text = Localizer.t(r.reason),
				color = C.OrangeDark,
				outline = false,
				anchor = Vector2.new(1, 0.5),
				pos = UDim2.fromScale(0.965, 0.44),
				size = UDim2.fromScale(0.46, 0.2),
				alignX = Enum.TextXAlignment.Right,
				wrap = true,
				max = 18,
			})
		end
		-- the buttons, right to left: Sell now always, then State Inspection / Put in showroom when they apply
		local buttons = Instance.new("Frame")
		buttons.Name = "Buttons"
		buttons.AnchorPoint = Vector2.new(0.5, 0.5)
		buttons.Position = UDim2.fromScale(0.5, 0.77)
		buttons.Size = UDim2.fromScale(0.93, 0.36)
		buttons.BackgroundTransparency = 1
		local ll = Instance.new("UIListLayout")
		ll.FillDirection = Enum.FillDirection.Horizontal
		ll.HorizontalAlignment = Enum.HorizontalAlignment.Right
		ll.VerticalAlignment = Enum.VerticalAlignment.Center
		ll.SortOrder = Enum.SortOrder.LayoutOrder
		ll.Padding = UDim.new(0.02, 0)
		ll.Parent = buttons
		buttons.Parent = card
		local function add(text: string, style: string, order: number, action: string)
			local b = UIKit.button(buttons, {
				text = text,
				style = style,
				size = UDim2.fromScale(0.32, 1),
				max = 22,
				onClick = function()
					act(action, r.id)
				end,
			})
			b.LayoutOrder = order
		end
		if r.canDisplay then
			add(Localizer.t("dl.display"), "Blue", 1, "display")
		end
		if r.canInspect then
			add(Localizer.t("dl.inspect"), "Orange", 2, "inspect")
		end
		add(Localizer.t("dl.sell", { price = r.quick }), "Green", 3, "sell")
	end
end

function Dealer.close()
	UIKit.close(frame)
	openedAt = nil
end

function Dealer.open()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	openedAt = root and root.Position
	UIKit.open(frame)
	reload()
end

function Dealer.start()
	local win = UIKit.window(HUD.gui(), { name = "Dealer", title = "dl.title", onClose = Dealer.close })
	frame = win.root
	scroll = UIKit.list(win.body, { pos = UDim2.fromScale(0.5, 0.03), size = UDim2.fromScale(0.96, 0.94) })
	empty = UIKit.text(win.body, {
		name = "Empty",
		key = "dl.none",
		color = C.InkSoft,
		outline = false,
		pos = UDim2.fromScale(0.5, 0.45),
		size = UDim2.fromScale(0.86, 0.2),
		wrap = true,
		max = 24,
	})
	empty.Visible = false
	UIKit.onLang(function()
		if frame.Visible then
			reload() -- the cards are built from the server's list: build them again
		end
	end)

	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt.Name == "DealerPrompt" then
			Dealer.open()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.3)
			if openedAt then
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if not root or (root.Position - openedAt).Magnitude > Config.ShopReach * 0.6 then
					Dealer.close()
				end
			end
		end
	end)
end

return Dealer
