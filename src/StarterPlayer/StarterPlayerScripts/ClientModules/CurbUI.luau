-- Quick jobs at the curb, the screen side (docs/design/curb_jobs.md §6; wr-dev CurbService runs them). Kept small
-- (user rule: as little on screen as possible) — the prompt itself is the PromptUI card (CurbPrompt, one at a time).
--  * the job card: one short line at the top middle — job name · +$pay — while you come up to (40 studs) a curb car
--    that's yours to do (car CurbOwner = you or none, CurbBy = you or none); gone once its prompt shows (the prompt
--    card says the step)
--  * someone else's: a small tag over the car ("Sam's quick job"; "Quick job: anyone!" when it's open and you're not
--    alone) — friends' servers only, never on your own job
--  * the wiper swap: while the arms are up (car Wipers = "service" / "lifted") on your job, a low camera from the hood
--    side frames the blades big (main 10-22: 20..30°, ~2x — higher than 45° over the blade hides the worn rubber) with
--    the Swap prompt in the picture and the blades lit; back to your camera after the test spray, or once you move
--  * the line: a small "…" bubble over the head of the customer waiting in the lot (NPC attribute LineWait)
-- Decision: notes/gpt/wr-ui/curb_ui_decision.md

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Modules = script.Parent
local HUD = require(Modules.HUD)
local Localizer = require(Modules.Localizer)
local UIKit = require(Modules.UIKit)
local UIStyle = require(Modules.UIStyle)

local CurbUI = {}

local C = UIStyle.Color
local player = Players.LocalPlayer

local NEAR = 15 -- studs: the wiper camera works this close to the car (the server's pause range)
local APPROACH = 40 -- studs: the card shows while you come up to your job's car (GPT curb_ui r1: decide to stop)
local TAG_RANGE = 60
local PROMPT_AT = Vector3.new(0, 4.4, -3.6) -- CurbService WIPER_AT: the Swap prompt (car coords)
local BLADES_AT = Vector3.new(-0.57, 5.1, -2.96) -- the two blades' middle, arms up (fault_parts work/v5_worn/svc)
-- from the blades toward the camera, car coords: over the hood on the passenger side, about 25° down onto the glass
-- (measured in the phone view 10-22: both blades whole between the top bar and the tool bar; the reviewed shots in
-- cams_glass.json sat at hood height, where the player's own character filled the bottom)
local CAM_DIR = Vector3.new(0.45, 0.4, -0.8).Unit
local CAM_DIST = 5
local CAM_HFOV = 92 -- degrees across: both blades and the prompt fit on a phone (≈51° tall) and a PC
local SPRAY_HOLD = 1.8 -- s the camera stays after the arms go down (the test spray, the clean glass)

local card: Frame
local nameLabel: TextLabel
local payLabel: TextLabel
local tagFrame: Frame
local tagLabel: TextLabel
local bubbles: { [Model]: Frame } = {}

local function curbCars(): { Model }
	local out = {}
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:IsA("Model") and c:GetAttribute("CurbJob") then
			table.insert(out, c)
		end
	end
	return out
end

local function base(car: Model): CFrame
	return (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
end

-- wr-dev CurbService: CurbOwner = whose it is (nil = anyone's), CurbBy = who pressed first (doing it)
local function mine(car: Model): boolean
	local by = car:GetAttribute("CurbBy") :: number?
	if by then
		return by == player.UserId
	end
	local owner = car:GetAttribute("CurbOwner") :: number?
	return owner == nil or owner == player.UserId
end

local function myRoot(): BasePart?
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function screenAt(world: Vector3): Vector2?
	local cam = workspace.CurrentCamera
	local v, on = cam:WorldToViewportPoint(world)
	if not on or v.Z <= 0 then
		return nil
	end
	-- viewport -> the HUD's layout px (the top bar inset; the phone check's frame and zoom — as PromptUI)
	local inset = game:GetService("GuiService"):GetGuiInset()
	local parent = tagFrame.Parent :: GuiObject
	return (Vector2.new(v.X, v.Y - inset.Y) - parent.AbsolutePosition) / UIKit.zoom()
end

------------------------------------------------------------------------------------------------- the job card

local function makeCard()
	card = UIKit.plate(HUD.gui(), { name = "CurbCard", anchor = Vector2.new(0.5, 0) }) :: Frame
	card.AutomaticSize = Enum.AutomaticSize.X
	card.Visible = false
	local pad = Instance.new("UIPadding")
	pad.Parent = card
	-- (the words in their own row: the plate's picture and bolts stay out of the list layout)
	local row = Instance.new("Frame")
	row.Name = "Row"
	row.BackgroundTransparency = 1
	row.AutomaticSize = Enum.AutomaticSize.X
	row.Size = UDim2.fromScale(0, 1)
	row.ZIndex = 3
	row.Parent = card
	local rl = Instance.new("UIListLayout")
	rl.FillDirection = Enum.FillDirection.Horizontal
	rl.VerticalAlignment = Enum.VerticalAlignment.Center
	rl.SortOrder = Enum.SortOrder.LayoutOrder
	rl.Parent = row
	local function words(name: string, order: number, color: Color3): TextLabel
		local l = Instance.new("TextLabel")
		l.Name = name
		l.LayoutOrder = order
		l.BackgroundTransparency = 1
		l.AutomaticSize = Enum.AutomaticSize.X
		l.FontFace = UIStyle.Font.Title
		l.TextColor3 = color
		l.Text = ""
		l.ZIndex = 3
		l.Parent = row
		UIKit.outline(l)
		return l
	end
	nameLabel = words("Job", 1, C.White)
	local gap = Instance.new("Frame")
	gap.Name = "Gap"
	gap.LayoutOrder = 2
	gap.BackgroundTransparency = 1
	gap.Parent = row
	payLabel = words("Pay", 3, C.Cash)
	UIKit.bind(card, function()
		local h = UIKit.px(0.095, 32, 40)
		card.Size = UDim2.fromOffset(0, h)
		-- just under the money bar (it hangs below a thin top bar on a phone: HUD placeBar)
		local barBottom = -UIKit.topInset() + 4 + UIKit.barHeight()
		card.Position = UDim2.new(0.5, 0, 0, math.max(8, barBottom + 6))
		pad.PaddingLeft = UDim.new(0, math.floor(h * 0.42))
		pad.PaddingRight = pad.PaddingLeft
		local t = math.floor(h * 0.54 + 0.5) -- (17 px on a phone: GPT curb_ui r1)
		for _, l in { nameLabel, payLabel } do
			l.TextSize = t
			l.Size = UDim2.fromOffset(0, h)
		end
		gap.Size = UDim2.fromOffset(math.floor(h * 0.3), h)
	end)
end

local camCar: Model? = nil -- (the wiper close-up, below: the card steps out of it — the prompt card says the step)
local promptUp: ProximityPrompt? = nil -- a curb prompt showing now (its card says the step: this one steps out)

local function showCard(car: Model?)
	local work = HUD.gui():GetAttribute("WorkView") == true or HUD.gui():GetAttribute("WindowOpen") == true
	if not car or work or camCar or promptUp then
		card.Visible = false
		return
	end
	UIKit.setText(nameLabel, "curb.name." .. (car:GetAttribute("CurbJob") :: string))
	payLabel.Text = "+" .. Localizer.t("hud.money", { money = car:GetAttribute("CurbPay") or 0 })
	card.Visible = true
end

------------------------------------------------------------------------------------- tags: someone else's / line

local function pill(name: string, parent: Instance): (Frame, TextLabel)
	local f = Instance.new("Frame")
	f.Name = name
	f.AnchorPoint = Vector2.new(0.5, 1)
	f.AutomaticSize = Enum.AutomaticSize.X
	f.BackgroundColor3 = C.Plate
	f.BackgroundTransparency = 0.15
	f.Visible = false
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = f
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, 10)
	p.PaddingRight = UDim.new(0, 10)
	p.Parent = f
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.AutomaticSize = Enum.AutomaticSize.X
	l.FontFace = UIStyle.Font.Bold
	l.TextColor3 = C.White
	l.Parent = f
	f.Parent = parent
	UIKit.bind(f, function()
		local s = UIKit.px(0.042, 14, 18)
		l.TextSize = s
		l.Size = UDim2.fromOffset(0, s + 8)
		f.Size = UDim2.fromOffset(0, s + 8)
	end)
	return f, l
end

-- the waiting customer: a white bubble with three dots over the head
local function bubble(): Frame
	local f = Instance.new("Frame")
	f.Name = "LineBubble"
	f.AnchorPoint = Vector2.new(0.5, 1)
	f.BackgroundColor3 = C.White
	f.BorderSizePixel = 0
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = f
	local s = Instance.new("UIStroke")
	s.Color = C.Ink
	s.Thickness = 2
	s.Parent = f
	local l = Instance.new("UIListLayout")
	l.FillDirection = Enum.FillDirection.Horizontal
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.VerticalAlignment = Enum.VerticalAlignment.Center
	l.Padding = UDim.new(0, 4)
	l.Parent = f
	for i = 1, 3 do
		local d = Instance.new("Frame")
		d.Name = "Dot" .. i
		d.Size = UDim2.fromOffset(6, 6)
		d.BackgroundColor3 = C.Ink
		d.BorderSizePixel = 0
		local dc = Instance.new("UICorner")
		dc.CornerRadius = UDim.new(1, 0)
		dc.Parent = d
		d.Parent = f
	end
	f.Size = UDim2.fromOffset(38, 20)
	f.Parent = tagFrame.Parent
	return f
end

local function updateTags()
	local root = myRoot()
	-- someone else's quick job (friends' servers only)
	local shown = false
	if root and #Players:GetPlayers() > 1 then
		for _, car in curbCars() do
			-- (the one doing it, else the one it's for; 0 = anyone's)
			local who = (car:GetAttribute("CurbBy") :: number?) or (car:GetAttribute("CurbOwner") :: number?) or 0
			local step = (car:GetAttribute("CurbStep") :: number?) or 0
			if who == player.UserId or step >= 2 then
				continue
			end
			local top = base(car) * Vector3.new(0, 6.2, -1)
			if (top - root.Position).Magnitude > TAG_RANGE then
				continue
			end
			local at = screenAt(top)
			if at then
				if who == 0 then
					UIKit.setText(tagLabel, "curb.tagOpen")
				else
					local p = Players:GetPlayerByUserId(who)
					UIKit.setText(tagLabel, "curb.tag", { name = if p then p.DisplayName else "?" })
				end
				tagFrame.Position = UDim2.fromOffset(at.X, at.Y)
				shown = true
			end
			break
		end
	end
	tagFrame.Visible = shown
	-- the line: "…" over the waiting customer's head (gently bobbing) — not while you're inside a work view or a mini-game
	-- (the bay job comes first: GPT curb_ui r1; a '…' floated over the polish screen's bumper)
	local seen = {}
	-- (also not while a prompt card is up: the "…" and "Raise the rear with the jack" together made two things to look at —
	-- main 10-23 r2; and the dots never ride up over the money bar: kept under it)
	local promptCard = HUD.gui():FindFirstChild("PromptCard") :: GuiObject?
	local busy = HUD.gui():GetAttribute("WorkView") == true or HUD.gui():GetAttribute("Minigame") == true or (promptCard ~= nil and promptCard.Visible)
	local floorY = math.max(0, UIKit.barHeight() + 4 - UIKit.topInset()) + 24
	for _, m in (if busy then {} else workspace:GetChildren()) do
		if m:IsA("Model") and m:GetAttribute("LineWait") then
			local head = m:FindFirstChild("Head") :: BasePart?
			local at = head and root and (head.Position - root.Position).Magnitude < 90 and screenAt(head.Position + Vector3.new(0, 1.3, 0))
			if at then
				seen[m] = true
				local b = bubbles[m] or bubble()
				bubbles[m] = b
				b.Position = UDim2.fromOffset(at.X, math.max(at.Y - 3 * math.abs(math.sin(os.clock() * 2.5)), floorY))
				b.Visible = true
			end
		end
	end
	for m, b in bubbles do
		if not seen[m] then
			b:Destroy()
			bubbles[m] = nil
		end
	end
end

-------------------------------------------------------------------------------------------- the wiper camera

local camFrom: CFrame? = nil
local camStart = 0
local downAt: number? = nil -- when the arms went back down
local leftWiper: Model? = nil -- moved away mid-swap: no camera again for this car until its next step
local leftStep = -1
local glows: { Highlight } = {}

local function blades(car: Model): { BasePart }
	local out = {}
	for _, d in car:GetDescendants() do
		if d:IsA("BasePart") and d.Name:match("^WiperBlade") and d.LocalTransparencyModifier < 0.5 then
			table.insert(out, d)
		end
	end
	return out
end

local function glow(car: Model?)
	for _, h in glows do
		h:Destroy()
	end
	glows = {}
	if not car then
		return
	end
	for _, b in blades(car) do
		-- (the outline only: the worn rubber's cracks stay readable)
		local h = Instance.new("Highlight")
		h.Name = "CurbBladeGlow"
		h.Adornee = b
		h.FillTransparency = 1
		h.OutlineColor = Color3.fromRGB(255, 220, 90)
		h.DepthMode = Enum.HighlightDepthMode.Occluded
		h.Parent = b
		table.insert(glows, h)
	end
end

local function camTarget(car: Model): CFrame
	local b = base(car)
	local mid = b * BLADES_AT
	local parts = blades(car)
	if #parts > 0 then
		local sum = Vector3.zero
		for _, p in parts do
			sum += p.Position
		end
		mid = sum / #parts
	end
	return CFrame.lookAt(mid + b:VectorToWorldSpace(CAM_DIR) * CAM_DIST, mid)
end

-- your own character steps out of the close-up (it stands right where the camera looks from)
local hidden: { [Instance]: boolean } = {}
local function hideMe(on: boolean)
	if on and player.Character then
		for _, d in player.Character:GetDescendants() do
			if d:IsA("BasePart") or d:IsA("Decal") then
				d.LocalTransparencyModifier = 1
				hidden[d] = true
			end
		end
	elseif not on then
		for d in hidden do
			if d.Parent then
				(d :: any).LocalTransparencyModifier = 0
			end
		end
		hidden = {}
	end
end

-- in the close-up the Swap prompt's card goes beside its point, between the blades (over it, it covered the long
-- blade: GPT curb_ui r1) — PromptUI reads CardSide
local function promptSide(car: Model?, side: string?)
	local p = car and car:FindFirstChild("CurbPrompt", true)
	if p then
		p:SetAttribute("CardSide", side)
	end
end

local function camOff()
	if not camCar then
		return
	end
	promptSide(camCar, nil)
	camCar, camFrom, downAt = nil, nil, nil
	RunService:UnbindFromRenderStep("CurbWiperCam")
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Custom
	cam.FieldOfView = 70
	glow(nil)
	hideMe(false)
end

local function camOn(car: Model)
	if camCar == car then
		return
	end
	camOff()
	camCar = car
	local cam = workspace.CurrentCamera
	camFrom, camStart = cam.CFrame, os.clock()
	cam.CameraType = Enum.CameraType.Scriptable
	glow(car)
	hideMe(true)
	promptSide(car, "right")
	RunService:BindToRenderStep("CurbWiperCam", Enum.RenderPriority.Camera.Value + 10, function()
		local c = camCar
		if not c or not c.Parent then
			camOff()
			return
		end
		local view = workspace.CurrentCamera
		local size = view.ViewportSize
		local aspect = if size.Y > 0 then size.X / size.Y else 16 / 9
		view.FieldOfView = math.deg(2 * math.atan(math.tan(math.rad(CAM_HFOV / 2)) / aspect))
		local a = math.clamp((os.clock() - camStart) / 0.45, 0, 1)
		a = 1 - (1 - a) ^ 3
		local to = camTarget(c)
		view.CameraType = Enum.CameraType.Scriptable
		view.CFrame = if camFrom then camFrom:Lerp(to, a) else to
	end)
end

local function updateCam()
	local root = myRoot()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local want: Model? = nil
	for _, car in curbCars() do
		if car:GetAttribute("CurbJob") == "Wipers" and mine(car) and root then
			local near = (base(car) * PROMPT_AT - root.Position).Magnitude < NEAR
			local step = (car:GetAttribute("CurbStep") :: number?) or 0
			local up = car:GetAttribute("Wipers") ~= nil
			if up then
				downAt = nil
			elseif camCar == car and not downAt then
				downAt = os.clock()
			end
			local holding = camCar == car and downAt ~= nil and os.clock() - downAt < SPRAY_HOLD
			if near and (up or holding) and not (leftWiper == car and leftStep == step) then
				want = car
			end
		end
	end
	-- walking away / jumping takes your camera back at once (and not again for this step)
	if camCar and want == camCar and hum and hum.MoveDirection.Magnitude > 0.1 and os.clock() - camStart > 0.3 then
		leftWiper, leftStep = camCar, (camCar:GetAttribute("CurbStep") :: number?) or 0
		want = nil
	end
	if HUD.gui():GetAttribute("WorkView") then
		want = nil
	end
	if want then
		camOn(want)
	else
		camOff()
	end
end

---------------------------------------------------------------------------------------------------------- run

function CurbUI.start()
	makeCard()
	tagFrame, tagLabel = pill("CurbTag", HUD.gui())
	local PromptService = game:GetService("ProximityPromptService")
	PromptService.PromptShown:Connect(function(p)
		if p.Name == "CurbPrompt" then
			promptUp = p
		end
	end)
	PromptService.PromptHidden:Connect(function(p)
		if p == promptUp then
			promptUp = nil
		end
	end)
	task.spawn(function()
		while true do
			if promptUp and not (promptUp.Parent and promptUp.Enabled) then
				promptUp = nil -- (gone or switched off between steps without a Hidden)
			end
			local root = myRoot()
			local near: Model? = nil
			if root then
				for _, car in curbCars() do
					local step = (car:GetAttribute("CurbStep") :: number?) or 0
					if mine(car) and step == 0 and (base(car).Position - root.Position).Magnitude < APPROACH then
						near = car
						break
					end
				end
			end
			showCard(near)
			updateCam()
			task.wait(0.15)
		end
	end)
	RunService.RenderStepped:Connect(updateTags)
end

return CurbUI
