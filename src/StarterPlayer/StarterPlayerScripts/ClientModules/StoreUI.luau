-- The Garage Shop window: the Robux items (Starter Pack, Pay Boost, Cash Envelopes, VIP, Gold Tools, Garage Rename — Shared/StoreData),
-- kept apart from the parts counter's game cash. One window, one list, one row per item: picture, name, one line
-- of words, and a price button (or "Owned" / "Tomorrow again"). A tap on a price button opens Roblox's own purchase
-- window — nothing here pushes: no pop-ups, no countdowns, no "limited" words, it only opens when the player asks
-- (the HUD "Shop" button, the counter's small "Robux shop" link, or the grey "Cash options" line in the tools shop
-- when the money is short). Items show only while main has switched them on (Config.StoreOn[key]) AND Roblox says the
-- pass / product is for sale (a made-but-not-on-sale item never shows a dead button).
-- Server signals (wr-dev): player attributes "Owns<Key>" = true once owned; "EnvLeft" = minutes of the day's 90 left.
-- Decision + GPT rounds: notes/gpt/wr-ui/store_decision.md.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local StoreData = require(ReplicatedStorage.Shared.StoreData)
local HUD = require(script.Parent.HUD)
local Localizer = require(script.Parent.Localizer)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local StoreUI = {}

local C = UIStyle.Color
local player = Players.LocalPlayer

local frame: CanvasGroup
local list: ScrollingFrame
local rows: { [string]: { row: Frame, buy: TextButton, state: Frame, desc: TextLabel, price: number } } = {}
local info: { [string]: { forSale: boolean, price: number? } } = {} -- (what Roblox says, asked once per item)
local asked: { [string]: boolean } = {}

local function idOf(item: StoreData.Item): number?
	local table_ = if item.kind == "pass" then Config.Passes else (Config :: any).Products
	return table_ and table_[item.key]
end

-- main's switch (Config.StoreOn) — in Studio the player attribute "StoreTest" (a comma list) also switches items on
local function switchedOn(key: string): boolean
	local on = (Config :: any).StoreOn
	if on and on[key] then
		return true
	end
	local test = player:GetAttribute("StoreTest")
	return RunService:IsStudio() and type(test) == "string" and (",".. test .. ","):find("," .. key .. ",", 1, true) ~= nil
end

local function owned(item: StoreData.Item): boolean
	return player:GetAttribute("Owns" .. item.key) == true
end

local function visible(item: StoreData.Item): boolean
	if not switchedOn(item.key) then
		return false
	end
	local i = info[item.key]
	return not (i and not i.forSale) -- (asking is in flight or failed: show it; Roblox itself refuses a dead one)
end

-- any item up now? (the HUD button and the links only exist then)
function StoreUI.anyOn(): boolean
	for _, item in StoreData.Items do
		if visible(item) then
			return true
		end
	end
	return false
end

-- is some Cash Envelope for sale (the tools shop's "Cash options" line)
function StoreUI.cashOn(): boolean
	for _, item in StoreData.Items do
		if item.minutes and visible(item) then
			return true
		end
	end
	return false
end

local function ask(item: StoreData.Item)
	local id = idOf(item)
	if not id or asked[item.key] then
		return
	end
	asked[item.key] = true
	task.spawn(function()
		local ok, res = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, if item.kind == "pass" then Enum.InfoType.GamePass else Enum.InfoType.Product)
		if ok and type(res) == "table" then
			info[item.key] = { forSale = res.IsForSale == true, price = res.PriceInRobux }
			StoreUI.refresh()
		else
			asked[item.key] = nil -- (try again next time it opens)
		end
	end)
end

local function envLeft(): number
	local left = player:GetAttribute("EnvLeft")
	return if type(left) == "number" then left else StoreData.DayMinutes
end

local function buy(item: StoreData.Item)
	local id = idOf(item)
	if not id then
		HUD.notify("store.unavailable", nil, "bad")
		return
	end
	if item.minutes and envLeft() < item.minutes then
		HUD.notify("n.envelopeFull", nil, "info") -- (the button is locked then; a quick double tap can still come here)
		return
	end
	if item.kind == "pass" then
		MarketplaceService:PromptGamePassPurchase(player, id)
	else
		MarketplaceService:PromptProductPurchase(player, id)
	end
end

function StoreUI.refresh()
	if not frame then
		return
	end
	local level = (player:GetAttribute("Level") :: number?) or 1
	local order = 0
	for _, item in StoreData.Items do
		local r = rows[item.key]
		if not r then
			continue
		end
		local show = visible(item)
		r.row.Visible = show
		if not show then
			continue
		end
		local have = owned(item)
		-- things you can still buy first, owned ones last
		order += 1
		-- (the Starter Pack leads only for newcomers, up to Lv 5; for veterans it waits lower down, still findable — GPT r2)
		r.row.LayoutOrder = if have then 100 + order elseif item.key == "StarterPack" and level > 5 then 50 else order
		local price = (info[item.key] and info[item.key].price) or item.price
		if item.minutes then
			UIKit.setText(r.desc, "store." .. item.key .. ".d", { money = StoreData.envelopeMoney(level, item.minutes) })
		end
		r.state.Visible = have
		r.buy.Visible = not have
		if not have then
			if item.minutes and envLeft() < item.minutes then
				UIKit.setLocked(r.buy, "store.tomorrow")
			else
				UIKit.setButton(r.buy, Localizer.t("store.price", { n = price }), "Blue") -- (blue = Robux; green stays the game-cash Buy)
			end
		end
	end
end

function StoreUI.close()
	UIKit.close(frame)
end

function StoreUI.open()
	for _, item in StoreData.Items do
		if switchedOn(item.key) then
			ask(item)
		end
	end
	StoreUI.refresh()
	list.CanvasPosition = Vector2.zero -- (always from the top)
	UIKit.open(frame)
end

function StoreUI.start()
	local win = UIKit.window(HUD.gui(), { name = "GarageShop", title = "store.title", overHotbar = true, onClose = StoreUI.close })
	frame = win.root
	list = UIKit.list(win.body, { pos = UDim2.fromScale(0.5, 0.02), size = UDim2.fromScale(0.96, 0.84) })
	UIKit.text(win.body, {
		name = "Note",
		key = "store.note",
		color = C.Ink, -- (dark on the grey steel: the grey line was hard to read — GPT)
		outline = false,
		anchor = Vector2.new(0.5, 1),
		pos = UDim2.fromScale(0.5, 0.995),
		size = UDim2.fromScale(0.94, 0.11),
		max = 16,
	})

	for _, item in StoreData.Items do
		local row = UIKit.row(list, { name = item.key })
		row.Visible = false
		UIKit.bind(row, function()
			row.Size = UDim2.new(0.97, 0, 0, UIKit.px(0.2, 60, 96))
		end)
		local icon = UIKit.icon(row, UIStyle.Icon["Store" .. item.key], { name = "Icon", anchor = Vector2.new(0, 0.5), pos = UDim2.fromScale(0.02, 0.5), size = UDim2.fromScale(0.14, 0.8) })
		if icon then
			icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
			icon.Size = UDim2.fromScale(0.8, 0.8)
		end
		local left = if icon then 0.2 else 0.035
		UIKit.text(row, {
			name = "Name",
			key = "store." .. item.key .. ".name",
			font = "Bold",
			color = C.Ink,
			outline = false,
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(left, 0.26),
			size = UDim2.fromScale(0.6 - (left - 0.035), 0.3),
			alignX = Enum.TextXAlignment.Left,
			max = 26,
		})
		local desc = UIKit.text(row, {
			name = "Desc",
			key = "store." .. item.key .. ".d",
			args = if item.minutes then { money = StoreData.envelopeMoney(1, item.minutes) } else nil,
			color = C.InkSoft,
			outline = false,
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(left, 0.66),
			size = UDim2.fromScale(0.6 - (left - 0.035), 0.5),
			alignX = Enum.TextXAlignment.Left,
			wrap = true,
			max = 17,
		})
		local b = UIKit.button(row, {
			name = "Buy",
			anchor = Vector2.new(1, 0.5),
			pos = UDim2.fromScale(0.975, 0.5),
			size = UDim2.fromScale(0.27, 0.6), -- (a little smaller than the game-cash Buy: the eye goes to the words first)
			max = 26,
			onClick = function()
				buy(item)
			end,
		})
		local state = Instance.new("Frame")
		state.Name = "State"
		state.AnchorPoint = Vector2.new(1, 0.5)
		state.Position = UDim2.fromScale(0.975, 0.5)
		state.Size = UDim2.fromScale(0.3, 0.7)
		state.BackgroundTransparency = 1
		state.Visible = false
		state.Parent = row
		local check = UIKit.icon(state, UIStyle.Icon.Check, { name = "Icon", anchor = Vector2.new(0, 0.5), pos = UDim2.fromScale(0, 0.5), size = UDim2.fromScale(0.3, 0.9) })
		UIKit.text(state, {
			name = "Text",
			key = "store.owned",
			font = "Title",
			color = C.Price,
			outline = false,
			anchor = Vector2.new(1, 0.5),
			pos = UDim2.fromScale(1, 0.5),
			size = UDim2.fromScale(if check then 0.66 else 1, 0.6),
			max = 24,
		})
		rows[item.key] = { row = row, buy = b, state = state, desc = desc, price = item.price }
	end

	-- a pass just became mine (the server's "Owns<Key>" turned on after a purchase): say what I got, once
	local readyAt = os.clock() + 8 -- (not the saved ones arriving at join)
	for _, item in StoreData.Items do
		player:GetAttributeChangedSignal("Owns" .. item.key):Connect(function()
			if owned(item) and os.clock() > readyAt then
				HUD.notify("store.got", { name = "@store." .. item.key .. ".name" }, "good")
			end
			StoreUI.refresh()
		end)
	end
	for _, name in { "EnvLeft", "Level", "StoreTest" } do
		player:GetAttributeChangedSignal(name):Connect(StoreUI.refresh)
	end
	UIKit.onLang(StoreUI.refresh)
	-- a purchase just went through (the server's "Owns<Key>" follows a moment later)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function()
		task.delay(1, StoreUI.refresh)
	end)
	MarketplaceService.PromptProductPurchaseFinished:Connect(function()
		task.delay(1, StoreUI.refresh)
	end)
end

return StoreUI
