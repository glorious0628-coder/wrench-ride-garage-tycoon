-- The guide line's one action button (rival_upgrade B2-1 ① / B2-4): when the next step is "order a new part" it sits
-- right over the guide line — "Order ($90)" — so nobody has to walk to the counter for a part the clues already named
-- (server: BuyPart(kind, "job") puts it on that car's cart two seconds later, same price). Only this one action for now;
-- the walking steps keep their prompts. Fed by the Client hint loop: GuideButton.set(orderKind?, money?).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local HUD = require(script.Parent.HUD)
local Localizer = require(script.Parent.Localizer)
local UIKit = require(script.Parent.UIKit)

local GuideButton = {}

local button: TextButton? = nil
local current: string? = nil
local busyUntil = 0

local function place()
	local b = button
	if not b then
		return
	end
	local above = HUD.hotbarHeight() + 24 + UIKit.px(0.06, 18, 30) + 8 -- (over the guide line)
	local h = UIKit.buttonH(44)
	b.Position = UDim2.new(0.5, 0, 1, -above)
	b.Size = UDim2.fromOffset(b.Size.X.Offset, h)
end

function GuideButton.set(order: string?, money: number?)
	if not order or os.clock() < busyUntil or HUD.gui():GetAttribute("WindowOpen") then
		if button then
			button.Visible = false
		end
		current = nil
		return
	end
	if not button then
		local b = UIKit.button(HUD.gui(), {
			name = "GuideOrder",
			key = "guide.orderBtn",
			args = { money = money or 0 },
			style = "Green",
			anchor = Vector2.new(0.5, 1),
			size = UDim2.fromOffset(150, 44),
			max = 22,
			onClick = function()
				local kind = current
				if not kind or os.clock() < busyUntil then
					return
				end
				busyUntil = os.clock() + 3 -- (it lands on the cart in 2 s; one tap is one order)
				local ok, key, args = Remotes.BuyPart:InvokeServer(kind, "job")
				if key then
					HUD.notify(key, args, if ok then "good" else "bad")
				end
				if not ok then
					busyUntil = 0
				end
			end,
		})
		button = b
		UIKit.fitButton(b, { text = 0.5, pad = 0.6, min = 2.4, max = 22 })
		UIKit.bind(b, place)
	end
	local b = button :: TextButton
	if current ~= order then
		current = order
		UIKit.setText(b:FindFirstChild("Label", true) :: TextLabel, "guide.orderBtn", { money = money or 0 })
	end
	b.Visible = true
	place()
end

return GuideButton
