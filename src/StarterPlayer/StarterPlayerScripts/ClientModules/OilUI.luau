-- The oil change on my screen (Features.OilChange; the server's OilService decides everything): while I work in a zone
-- of a car that has an oil job, one line says the next step (car attribute OilStep), a small bar shows how much oil is in
-- (OilL → Empty / Low / Good / Too much) and, at the oil cap under the hood, a hold button pours new oil — the client
-- only says "pouring" (Remotes.Oil), the server adds the oil by its own clock.
-- Look: a first plain version made of the garage kit (UIKit plate / text / button); the final look is wr-ui's.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local OilUI = {}

local player = Players.LocalPlayer
local C = UIStyle.Color

-- the same bands as OilService.band (Empty < 0.15 · Low < 4.2 · Good ≤ 4.8 · Too much)
local function bandOf(oil: number): number
	if oil < 0.15 then
		return 0
	elseif oil < 4.2 then
		return 1
	elseif oil <= 4.8 then
		return 2
	end
	return 3
end
local BAND_COLOR = { [0] = C.Gray, [1] = C.Orange, [2] = C.Green, [3] = C.Red }

local function myCar(): Model?
	local id = player:GetAttribute("WorkCar")
	if id == nil then
		return nil
	end
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:GetAttribute("CarId") == id then
			return c :: Model
		end
	end
	return nil
end

function OilUI.start()
	if not Config.feature("OilChange") then
		return
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "OilUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 40
	gui.Enabled = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local card = UIKit.plate(gui, { name = "Card", size = UDim2.fromScale(0.5, 0.15), pos = UDim2.fromScale(0.5, 0.02), anchor = Vector2.new(0.5, 0) })
	local step = UIKit.text(card, { name = "Step", key = "oil.step.panel", size = UDim2.fromScale(0.94, 0.5), pos = UDim2.fromScale(0.5, 0.3), max = 26, wrap = true, font = "Bold" })
	local barBack = Instance.new("Frame")
	barBack.Name = "Bar"
	barBack.Size = UDim2.fromScale(0.62, 0.16)
	barBack.Position = UDim2.fromScale(0.38, 0.74)
	barBack.AnchorPoint = Vector2.new(0.5, 0.5)
	barBack.BackgroundColor3 = C.Plate
	barBack.BorderSizePixel = 0
	barBack.Parent = card
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0.5, 0)
	barCorner.Parent = barBack
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = C.Orange
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = barBack
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0.5, 0)
	fillCorner.Parent = fill
	-- the "good" window on the bar (4.2~4.8 of 6)
	local good = Instance.new("Frame")
	good.Name = "Good"
	good.BackgroundTransparency = 1
	good.Size = UDim2.fromScale((4.8 - 4.2) / 6, 1)
	good.Position = UDim2.fromScale(4.2 / 6, 0)
	good.BorderSizePixel = 0
	good.Parent = barBack
	local goodEdge = Instance.new("UIStroke")
	goodEdge.Color = C.Good
	goodEdge.Thickness = 2
	goodEdge.Parent = good
	local lv = UIKit.text(card, { name = "Level", key = "oil.lv.1", size = UDim2.fromScale(0.28, 0.2), pos = UDim2.fromScale(0.84, 0.74), max = 20, alignX = Enum.TextXAlignment.Left })
	local tag = UIKit.text(card, { name = "Tag", key = "oil.level", size = UDim2.fromScale(0.1, 0.2), pos = UDim2.fromScale(0.035, 0.74), max = 20, alignX = Enum.TextXAlignment.Left })
	tag.AnchorPoint = Vector2.new(0, 0.5)
	lv.AnchorPoint = Vector2.new(0, 0.5)

	-- the pour button: hold it (a mouse or a thumb), resent every 0.3 s while down
	local holding = false
	local pour = UIKit.button(gui, { name = "Pour", key = "oil.pour", style = "Orange", size = UDim2.fromScale(0.26, 0.14), pos = UDim2.fromScale(0.5, 0.86), max = 30 })
	pour.Visible = false
	local function send(on: boolean)
		local car = myCar()
		if car then
			Remotes.Oil:FireServer(car, on)
		end
	end
	pour.MouseButton1Down:Connect(function()
		holding = true
		send(true)
	end)
	local function release()
		if holding then
			holding = false
			send(false)
		end
	end
	pour.MouseButton1Up:Connect(release)
	pour.MouseLeave:Connect(release)
	pour.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then
			release()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.3)
			if holding then
				send(true)
			end
		end
	end)

	local lastStep = ""
	local lastBand = -1
	task.spawn(function()
		while true do
			task.wait(0.15)
			local car = myCar()
			local on = car ~= nil and car:GetAttribute("OilJob") == true and car:GetAttribute("OilDone") ~= true
			gui.Enabled = on
			if not on or not car then
				if holding then
					release()
				end
				continue
			end
			local s = (car:GetAttribute("OilStep") :: string?) or "panel"
			if s ~= lastStep then
				lastStep = s
				UIKit.setText(step, "oil.step." .. s)
			end
			local oil = (car:GetAttribute("OilL") :: number?) or 0
			local b = bandOf(oil)
			if b ~= lastBand then
				lastBand = b
				UIKit.setText(lv, "oil.lv." .. b)
				fill.BackgroundColor3 = BAND_COLOR[b]
			end
			fill.Size = UDim2.fromScale(math.clamp(oil / 6, 0, 1), 1)
			local zone = player:GetAttribute("WorkZone")
			pour.Visible = zone == "EngineBay" and s == "pour"
			if not pour.Visible and holding then
				release()
			end
		end
	end)
end

return OilUI
