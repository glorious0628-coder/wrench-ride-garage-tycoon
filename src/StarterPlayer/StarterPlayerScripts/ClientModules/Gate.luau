-- Who plays in this garage, the client half (server_model.md §5; the server's GateService decides). Every move says
-- why in one line, so nobody feels kicked: a full-screen "taking you to your garage" (also the teleport screen),
-- and one small card with one button for the rest — a send that failed (Try again), the owner went home (Back to
-- my garage), my own reserved garage (Join can't follow here: Invite). Gate.invite() is there for a lasting
-- Invite button (Settings.luau, next to the settings button). Look: wr-ui (the moving screen = the loading screen's).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local TeleportService = game:GetService("TeleportService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Modules = script.Parent
local Localizer = require(Modules.Localizer)
local UIKit = require(Modules.UIKit)
local UIStyle = require(Modules.UIStyle)
local HUD = require(Modules.HUD)

local Gate = {}

local player = Players.LocalPlayer

local moving: ScreenGui
local movingText: TextLabel
local card: Frame
local cardIcon: ImageLabel
local cardText: TextLabel
local cardButton: TextButton
local cardWhat: string? = nil -- "failed" | "ownerLeft" | "invite"
local cardToken = 0

-- can I send game invites from here (some devices / young accounts can't)
function Gate.canInvite(): boolean
	local ok, yes = pcall(SocialService.CanSendGameInviteAsync, SocialService, player)
	return ok and yes == true
end

-- invite friends to this garage: they land here even when Join can't follow (a reserved garage)
function Gate.invite()
	local opts = Instance.new("ExperienceInviteOptions")
	opts.LaunchData = tostring(workspace:GetAttribute("GarageOwner") or player.UserId)
	pcall(SocialService.PromptGameInvite, SocialService, player, opts)
end

local function showMoving(key: string, args: { [string]: any }?)
	movingText.Text = Localizer.t(key, args)
	-- the logo in the player's language (the Korean one once it's uploaded: UIStyle.Travel.logoKo)
	local logo = moving:FindFirstChild("Logo", true) :: ImageLabel?
	local T = UIStyle.Travel
	if logo then
		local ko = Localizer.lang == "ko" and T.logoKo ~= ""
		logo.Image = if ko then T.logoKo else T.logo
		local shape = logo:FindFirstChildOfClass("UIAspectRatioConstraint")
		if shape then
			shape.AspectRatio = if ko then T.logoKoShape else 2012 / 782
		end
	end
	moving.Enabled = true
end

local function hideCard()
	cardWhat = nil
	card.Visible = false
end

-- top centre, but left of the job card when it's there (small phones: 667 x 375 would overlap it)
local function placeCard()
	local size = UIKit.size()
	local w = math.clamp(size.X * 0.4, 280, 520)
	local x = size.X / 2
	local job = HUD.gui():FindFirstChild("JobCard", true) :: GuiObject?
	if job and job.Visible then
		local root = card.Parent :: GuiObject
		x = math.min(x, (job.AbsolutePosition.X - root.AbsolutePosition.X) / UIKit.zoom() - 10 - w / 2)
	end
	card.Size = UDim2.fromOffset(w, math.clamp(w * 0.17, 56, 76))
	card.Position = UDim2.new(0, x, 0, math.max(0, UIKit.barHeight() + 4 - UIKit.topInset()) + 8)
end

-- the one card: a line and a button (seconds = hides by itself)
local function showCard(what: string, key: string, args: { [string]: any }?, buttonKey: string, seconds: number?)
	cardWhat = what
	cardToken += 1
	UIKit.setText(cardText, key, args)
	-- a sign in front when there's one for it (the line starts after it)
	local icon = if what == "failed" then UIStyle.Icon.Warning elseif what == "invite" then UIStyle.Icon.Invite else ""
	cardIcon.Image = icon
	cardIcon.Visible = icon ~= ""
	local left = if icon ~= "" then 0.15 else 0.045
	cardText.Position = UDim2.fromScale(left, 0.5)
	cardText.Size = UDim2.fromScale(0.64 - left, 0.66)
	local label = cardButton:FindFirstChild("Label", true) :: TextLabel?
	if label then
		UIKit.setText(label, buttonKey)
	end
	placeCard()
	card.Visible = true
	if seconds then
		local token = cardToken
		task.delay(seconds, function()
			if cardToken == token then
				hideCard()
			end
		end)
	end
end

-- a picture repeated over a box of the moving screen; tile(screen size) = one copy's size
local function tiled(parent: GuiObject, name: string, id: string, anchorY: number, height: number, tile: (Vector2) -> Vector2): ImageLabel?
	if id == "" then
		return nil
	end
	local i = Instance.new("ImageLabel")
	i.Name = name
	i.Image = id
	i.BackgroundTransparency = 1
	i.ScaleType = Enum.ScaleType.Tile
	i.AnchorPoint = Vector2.new(0, anchorY)
	i.Position = UDim2.fromScale(0, anchorY)
	i.Size = UDim2.fromScale(1, height)
	i.Parent = parent
	local function fit()
		local t = tile(parent.AbsoluteSize)
		i.TileSize = UDim2.fromOffset(math.max(t.X, 1), math.max(t.Y, 1))
	end
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()
	return i
end

local function build()
	-- the moving screen: over everything (the loading screen too), and kept up through the teleport. It looks like
	-- the loading screen (UIStyle.Travel), so moving and arriving read as one trip; the reason sits where
	-- "Loading..." does
	local T = UIStyle.Travel
	moving = Instance.new("ScreenGui")
	moving.Name = "GateMoving"
	moving.IgnoreGuiInset = true
	moving.ScreenInsets = Enum.ScreenInsets.None
	moving.ResetOnSpawn = false
	moving.DisplayOrder = 1001
	moving.Enabled = false
	local back = Instance.new("Frame")
	back.Name = "Root"
	back.AnchorPoint = Vector2.new(0.5, 0.5)
	back.Position = UDim2.fromScale(0.5, 0.5)
	back.Size = UDim2.fromScale(1, 1)
	back.BackgroundColor3 = T.blue
	back.BorderSizePixel = 0
	back.Parent = moving
	local pattern = tiled(back, "Pattern", T.pattern, 0, 1, function(sz)
		return Vector2.new(sz.Y * 0.5, sz.Y * 0.5)
	end)
	if pattern then
		pattern.ImageTransparency = 0.3
	end
	tiled(back, "Top", T.top, 0, 0.26, function(sz)
		return Vector2.new(sz.Y * 0.26 * 2172 / 724, sz.Y * 0.26)
	end)
	tiled(back, "Bottom", T.bottom, 1, 0.28, function(sz)
		return Vector2.new(sz.Y * 0.28 * 2172 / 724, sz.Y * 0.28)
	end)
	local logo = UIKit.icon(back, T.logo, { name = "Logo", pos = UDim2.fromScale(0.5, 0.42), size = UDim2.fromScale(0.52, 0.3) })
	if logo then
		local shape = Instance.new("UIAspectRatioConstraint")
		shape.AspectRatio = 2012 / 782
		shape.AspectType = Enum.AspectType.FitWithinMaxSize
		shape.Parent = logo
	end
	local nut = UIKit.icon(back, T.spinner, { name = "Spinner", pos = UDim2.fromScale(0.5, 0.635), size = UDim2.fromScale(0.13, 0.13) })
	if nut then
		nut.SizeConstraint = Enum.SizeConstraint.RelativeYY
		RunService.RenderStepped:Connect(function(dt)
			if moving.Enabled then
				nut.Rotation = (nut.Rotation + dt * 240) % 360
			end
		end)
	end
	movingText = UIKit.text(back, { name = "Line", font = "Title", pos = UDim2.fromScale(0.5, 0.775), size = UDim2.fromScale(0.8, 0.09), max = 30, wrap = true, outlineColor = T.ink })
	moving.Parent = player:WaitForChild("PlayerGui")

	-- the card: one row (sign | line | button) under the money bar, clear of the car and the job card — it can stay
	-- up a while (the owner went home: finish your car first)
	card = UIKit.plate(HUD.gui(), { name = "GateCard", anchor = Vector2.new(0.5, 0), z = 5 })
	card.Visible = false
	cardIcon = Instance.new("ImageLabel")
	cardIcon.Name = "Icon"
	cardIcon.BackgroundTransparency = 1
	cardIcon.ScaleType = Enum.ScaleType.Fit
	cardIcon.AnchorPoint = Vector2.new(0, 0.5)
	cardIcon.Position = UDim2.fromScale(0.035, 0.5)
	cardIcon.Size = UDim2.fromScale(0.5, 0.5)
	cardIcon.SizeConstraint = Enum.SizeConstraint.RelativeYY
	cardIcon.Parent = card
	cardText = UIKit.text(card, { name = "Line", anchor = Vector2.new(0, 0.5), alignX = Enum.TextXAlignment.Left, max = 18, wrap = true })
	cardButton = UIKit.button(card, {
		name = "Go",
		text = "",
		style = "Blue",
		anchor = Vector2.new(1, 0.5),
		size = UDim2.fromScale(0.3, 0.62),
		pos = UDim2.fromScale(0.965, 0.5),
		max = 18,
		onClick = function()
			local what = cardWhat
			if what == "failed" then
				hideCard()
				Remotes.Gate:FireServer("retry")
			elseif what == "ownerLeft" then
				Remotes.Gate:FireServer("home")
			elseif what == "invite" then
				hideCard()
				Gate.invite()
			end
		end,
	})
	UIKit.bind(card, placeCard)
end

function Gate.start()
	build()
	Remotes.Gate.OnClientEvent:Connect(function(what: string, key: string?, args: { [string]: any }?)
		if what == "moving" and key then
			hideCard()
			showMoving(key, args)
			pcall(TeleportService.SetTeleportGui, TeleportService, moving)
		elseif what == "retry" then
			showMoving("gate.retry")
		elseif what == "failed" then
			moving.Enabled = false
			showCard("failed", "gate.failed", nil, "gate.tryAgain")
		elseif what == "ownerLeft" and key then
			showCard("ownerLeft", key, args, "gate.home")
		end
	end)
	-- the owner came back: the "head home" card goes
	workspace:GetAttributeChangedSignal("GarageClosed"):Connect(function()
		if not workspace:GetAttribute("GarageClosed") and cardWhat == "ownerLeft" then
			hideCard()
		end
	end)
	-- my own reserved garage: friends can't Join here, say so once (with the Invite button)
	task.spawn(function()
		while not player:GetAttribute("Loaded") do
			player:GetAttributeChangedSignal("Loaded"):Wait()
		end
		task.wait(4)
		if workspace:GetAttribute("GarageKind") == "reserved" and workspace:GetAttribute("GarageOwner") == player.UserId
			and cardWhat == nil and Gate.canInvite() then
			showCard("invite", "gate.reservedTip", nil, "gate.invite", 15)
		end
	end)
end

return Gate
