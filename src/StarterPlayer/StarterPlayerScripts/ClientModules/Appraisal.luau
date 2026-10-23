-- The junkyard appraisal card (docs/design/flip_loop.md §1): what you can see on the wreck, the price, the extra
-- repair estimate ("$0~250" for what's hidden) and the expected profit; Buy & tow asks the server (Remotes.BuyWreck).
-- The server sends the card (Remotes.Appraisal) when the AppraisePrompt at a wreck spot is used.
-- UI B window like the other shops (UIKit.window: the X top right, 44 px+); a wreck you can't buy shows the shared
-- "can't yet" button (UIKit.setLocked: grey, the lock, the reason) — docs/research/tutorial_taps_1021.md B-1 / B-2.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local Appraisal = {}

local C = UIStyle.Color
local player = Players.LocalPlayer
local frame: CanvasGroup
local sheet: ScrollingFrame
local buy: TextButton
local card: { [string]: any }? = nil
local openedAt: Vector3? = nil

-- one line on the white sheet (dark words; the title / profit keep their colour, darker for a white ground)
local function line(t: string, color: Color3?, order: number, big: boolean?)
	local l = UIKit.text(sheet, {
		name = "Line",
		text = t,
		font = if big then "Title" else "Bold",
		color = color or C.Ink,
		outline = false,
		anchor = Vector2.new(0, 0),
		alignX = Enum.TextXAlignment.Left,
		max = if big then 26 else 20,
	})
	l.LayoutOrder = order
	-- a set size that wraps (a long title line — "Salvage — passes the inspection…" — shrank to nothing when scaled)
	l.TextScaled = false
	l.TextWrapped = true
	l.TextSize = UIKit.px(if big then 0.05 else 0.042, if big then 17 else 14, if big then 24 else 19)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.Size = UDim2.new(0.94, 0, 0, 0)
end

function Appraisal.close()
	UIKit.close(frame)
	card = nil
	openedAt = nil
end

function Appraisal.open(c: { [string]: any })
	card = c
	for _, ch in sheet:GetChildren() do
		if ch:IsA("TextLabel") then
			ch:Destroy()
		end
	end
	line(Localizer.t("wreck.price", { price = c.price }), C.Ink, 1, true)
	local titleColor = if c.title == "Clean" then Color3.fromRGB(26, 110, 190) elseif c.title == "Salvage" then Color3.fromRGB(190, 110, 10) else Color3.fromRGB(190, 50, 40)
	line(Localizer.t("title." .. c.title), titleColor, 2)
	line(Localizer.t("wreck.seen"), C.InkSoft, 3)
	if #c.seen == 0 then
		line("  " .. Localizer.t("wreck.nothing"), C.Ink, 4)
	end
	for i, item in c.seen do
		line("  - " .. Localizer.t(item.k, item.a), Color3.fromRGB(180, 60, 45), 3 + i)
	end
	if c.hidden then
		line(Localizer.t("wreck.hidden"), C.InkSoft, 20)
	end
	if c.title ~= "Junk" then
		line(Localizer.t("wreck.repair", { lo = c.repairLo, hi = c.repairHi }), C.Ink, 21)
		line(Localizer.t("wreck.profit", { lo = c.profitLo, hi = c.profitHi }), C.Price, 22, true)
	end
	if c.title == "Junk" then
		UIKit.setLocked(buy, "wreck.partsOnly")
	elseif c.canBuy then
		UIKit.setButton(buy, Localizer.t("wreck.buy", { price = c.price }), "Green")
	else
		UIKit.setLocked(buy, "wreck.needBay")
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	openedAt = root and root.Position
	if not frame.Visible then
		UIKit.open(frame)
	end
end

function Appraisal.start()
	local win = UIKit.window(HUD.gui(), { name = "Appraisal", title = "wreck.title", maxSize = Vector2.new(560, 420), onClose = Appraisal.close })
	frame = win.root
	-- the lines on a white sheet (scrolls if a wreck has many), the one button under it
	local paper = UIKit.row(win.body, { name = "Sheet", anchor = Vector2.new(0.5, 0), pos = UDim2.fromScale(0.5, 0.04), size = UDim2.fromScale(0.94, 0.66) })
	sheet = UIKit.list(paper, { pos = UDim2.fromScale(0.5, 0.03), size = UDim2.fromScale(0.98, 0.94) })
	buy = UIKit.button(win.body, {
		name = "Buy",
		anchor = Vector2.new(0.5, 1),
		pos = UDim2.fromScale(0.5, 0.96),
		size = UDim2.fromScale(0.62, 0.22),
		max = 26,
		onClick = function()
			if not card or not card.canBuy then
				return
			end
			local ok, key, args = Remotes.BuyWreck:InvokeServer(card.spot)
			if key then
				HUD.notify(key, args, if ok then "good" else "bad")
			end
			if ok then
				Appraisal.close()
			end
		end,
	})
	UIKit.fitButton(buy, { text = 0.56, pad = 0.5, min = 2.6, max = 26 }) -- (as wide as its words: user 10-22)

	Remotes.Appraisal.OnClientEvent:Connect(Appraisal.open)
	Localizer.Changed.Event:Connect(function()
		if frame.Visible and card then
			Appraisal.open(card :: { [string]: any }) -- the same card in the new language
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.3)
			if openedAt then
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if not root or (root.Position - openedAt).Magnitude > Config.ShopReach * 0.6 then
					Appraisal.close()
				end
			end
		end
	end)
end

return Appraisal
