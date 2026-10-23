-- The tools & upgrades window (Shared/Equipment): opens from the tool chest's prompt, one row per item with what it
-- does and its button: Buy $X (green) / Lv N (still locked: UIKit.setLocked, grey with the lock) / Owned. Buy asks the server
-- (Remotes.BuyUpgrade). UI B look (UIKit window).

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Equipment = require(ReplicatedStorage.Shared.Equipment)
local StoreData = require(ReplicatedStorage.Shared.StoreData)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Localizer = require(script.Parent.Localizer)
local StoreUI = require(script.Parent.StoreUI)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local EquipShop = {}

local C = UIStyle.Color
local player = Players.LocalPlayer
local frame: CanvasGroup
local rows: { [string]: { buy: TextButton, state: Frame, stateIcon: ImageLabel?, stateText: TextLabel, new: GuiObject, need: TextButton } } = {}
local openedAt: Vector3? = nil

local function owned(): { [string]: boolean }
	local out = {}
	for id in ((player:GetAttribute("Owned") :: string?) or ""):gmatch("[^,]+") do
		out[id] = true
	end
	return out
end

-- the row this level just opened (first10_payout ③: no "Next: buy…" goal line — the Ratchet's row stands out
-- instead): the first item of the current level not owned yet, one at a time
local function newest(have: { [string]: boolean }, level: number): string?
	local best = nil
	for _, it in Equipment.Items do
		if it.level == level and not have[it.id] and (not best or it.order < best.order) then
			best = it
		end
	end
	return best and best.id
end

local function refresh()
	local have = owned()
	local level = player:GetAttribute("Level") or 1
	local fresh = newest(have, level)
	for id, r in rows do
		r.new.Visible = id == fresh
		local it = Equipment.ById[id]
		-- owned: a check with words instead of a button; locked: the shared "can't yet" button (grey, the lock, Lv N)
		local owns, locked = have[id] == true, level < it.level
		r.buy.Visible = not owns
		r.state.Visible = owns
		if owns then
			UIKit.setText(r.stateText, "equip.owned")
			r.stateText.TextColor3 = C.Price
		elseif locked then
			UIKit.setLocked(r.buy, "equip.level", { level = it.level })
		else
			UIKit.setButton(r.buy, Localizer.t("equip.buy", { price = it.price }), "Green")
		end
		-- money short for an item you could buy: a small grey line under the button, only while Cash Envelopes are on
		-- sale (never anywhere else — monetization §4-4); it is a link to the Garage Shop, nothing opens by itself
		local money = (player:GetAttribute("Money") :: number?) or 0
		local short = not owns and not locked and money < it.price and StoreData.ToolShopHint and StoreUI.cashOn()
		r.need.Visible = short
		r.buy.Position = UDim2.fromScale(0.975, if short then 0.34 else 0.5)
		r.buy.Size = UDim2.fromScale(0.3, if short then 0.5 else 0.72)
		local note = (r.buy.Parent :: Instance):FindFirstChild("Note") :: TextLabel? -- (the words wrap shorter beside the hint)
		if note then
			note.Size = UDim2.fromScale(if short then 0.42 else 0.47, 0.4)
		end
		if short then
			UIKit.setText(r.need, "store.cashHint", { money = it.price - money })
		end
		if r.stateIcon then
			r.stateIcon.Image = UIStyle.Icon.Check
		end
	end
end

function EquipShop.close()
	UIKit.close(frame)
	openedAt = nil
end

function EquipShop.open()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	openedAt = root and root.Position
	refresh()
	UIKit.open(frame)
end

function EquipShop.start()
	local win = UIKit.window(HUD.gui(), { name = "EquipShop", title = "equip.title", overHotbar = true, onClose = EquipShop.close })
	frame = win.root
	local list = UIKit.list(win.body, { pos = UDim2.fromScale(0.5, 0.03), size = UDim2.fromScale(0.96, 0.94) })

	for _, it in Equipment.Items do
		local row = UIKit.row(list, { name = it.id })
		row.LayoutOrder = it.order
		UIKit.bind(row, function()
			row.Size = UDim2.new(0.97, 0, 0, if UIKit.size().Y < 500 then UIKit.px(0.16, 56, 66) else UIKit.px(0.2, 64, 100))
		end)
		-- the item's picture on the left (wr-uidesign A⑤: the tool shop had words only, the parts counter has pictures)
		local pic = UIKit.icon(row, (UIStyle.Icon :: any)[it.id], {
			name = "Pic",
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(0.02, 0.5),
			size = UDim2.fromScale(0.13, 0.84),
		})
		local textX = if pic then 0.17 else 0.035
		UIKit.text(row, {
			name = "Name",
			key = "equip." .. it.id,
			font = "Bold",
			color = C.Ink,
			outline = false,
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(textX, 0.3),
			size = UDim2.fromScale(0.64 - textX, 0.34),
			alignX = Enum.TextXAlignment.Left,
			max = 28,
		})
		UIKit.text(row, {
			name = "Note",
			key = "equip." .. it.id .. ".d",
			color = C.InkSoft,
			outline = false,
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(textX, 0.7),
			size = UDim2.fromScale(0.64 - textX, 0.4),
			alignX = Enum.TextXAlignment.Left,
			wrap = true,
			max = 18,
		})
		local b = UIKit.button(row, {
			name = "Buy",
			anchor = Vector2.new(1, 0.5),
			pos = UDim2.fromScale(0.975, 0.5),
			size = UDim2.fromScale(0.3, 0.72),
			max = 26,
			onClick = function()
				local ok, key, args = Remotes.BuyUpgrade:InvokeServer(it.id)
				if key then
					HUD.notify(key, args, if ok then "good" else "bad")
				end
				refresh()
			end,
		})
		local state = Instance.new("Frame")
		state.Name = "State"
		state.AnchorPoint = Vector2.new(1, 0.5)
		state.Position = UDim2.fromScale(0.975, 0.5)
		state.Size = UDim2.fromScale(0.3, 0.72)
		state.BackgroundTransparency = 1
		state.Visible = false
		state.Parent = row
		local stateIcon = UIKit.icon(state, UIStyle.Icon.Lock, {
			name = "Icon",
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(0, 0.5),
			size = UDim2.fromScale(0.3, 0.9),
		})
		local stateText = UIKit.text(state, {
			name = "Text",
			font = "Title",
			outline = false,
			anchor = Vector2.new(1, 0.5),
			pos = UDim2.fromScale(1, 0.5),
			size = UDim2.fromScale(if stateIcon then 0.66 else 1, 0.6),
			max = 26,
		})
		-- "NEW": a yellow sticker on the item picture's corner
		local tag = Instance.new("Frame")
		tag.Name = "New"
		tag.AnchorPoint = Vector2.new(0, 0)
		tag.Position = UDim2.fromScale(0.005, 0.02) -- (on the picture's corner: it sat on the Buy button and hid its price)
		tag.Rotation = -8
		tag.BackgroundColor3 = C.Yellow
		tag.ZIndex = 5
		tag.Visible = false
		tag.Parent = row
		local tc = Instance.new("UICorner")
		tc.CornerRadius = UDim.new(0.3, 0)
		tc.Parent = tag
		local ts = Instance.new("UIStroke")
		ts.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ts.Color = C.Outline
		ts.Parent = tag
		UIKit.text(tag, { name = "Label", key = "equip.new", font = "Title", color = C.Ink, outline = false, size = UDim2.fromScale(0.86, 0.8), max = 18, z = 5 })
		UIKit.bind(tag, function()
			local h = UIKit.px(0.05, 18, 24)
			tag.Size = UDim2.fromOffset(math.floor(h * 2.4), h)
			ts.Thickness = math.max(1, math.floor(h * 0.08))
		end)
		local need = Instance.new("TextButton")
		need.Name = "Need"
		need.AnchorPoint = Vector2.new(1, 1)
		need.Position = UDim2.fromScale(0.975, 0.97)
		need.Size = UDim2.fromScale(0.36, 0.34)
		need.BackgroundTransparency = 1
		need.AutoButtonColor = false
		need.FontFace = UIStyle.Font.Body
		need.TextColor3 = C.InkSoft
		need.TextWrapped = true
		need.TextXAlignment = Enum.TextXAlignment.Right
		need.TextYAlignment = Enum.TextYAlignment.Top
		need.Visible = false
		need.Parent = row
		UIKit.bind(need, function()
			need.TextSize = UIKit.px(0.03, 11, 14)
		end)
		need.Activated:Connect(StoreUI.open)
		rows[it.id] = { buy = b, state = state, stateIcon = stateIcon, stateText = stateText, new = tag, need = need }
	end

	player:GetAttributeChangedSignal("Owned"):Connect(refresh)
	player:GetAttributeChangedSignal("Money"):Connect(refresh)
	UIKit.onLang(refresh)
	player:GetAttributeChangedSignal("Level"):Connect(refresh)
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt.Name == "UpgradePrompt" then
			EquipShop.open()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.3)
			if openedAt then
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if not root or (root.Position - openedAt).Magnitude > Config.ShopReach * 0.6 then
					EquipShop.close()
				end
			end
		end
	end)
end

return EquipShop
