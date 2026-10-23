-- Work View, the screen side (docs/design/work_view.md v0.4; looks decided with GPT: notes/gpt/wr-ui/workview_*).
-- wr-dev's Work View code moves the camera and reads the input; it calls these to draw:
--   WorkViewUI.enter(zone, car?) / exit()      the work screen's buttons on / off (Exit bottom left, Cart bottom right
--                                              — the thumbs' spots, free while the character stands still), the job
--                                              card folds to its steps line. Presses: WorkViewUI.Exit.Event,
--                                              WorkViewUI.Cart.Event, WorkViewUI.Lower.Event ("Lower car" over Cart:
--                                              only while the car sits on its stands with that end's wheels on and
--                                              tight; locked with the name while someone else works on the car)
--   WorkViewUI.glow(part?, kind)               one look for "pickable" (what comes off), "target" (the empty spot a
--                                              part snaps into) and "drag" (the part in your finger); nil = off
--   WorkViewUI.hold(target, share) / holdEnd() the hold-to-turn ring: 12 dots light up round a bolt, drawn beside the
--                                              finger so the finger doesn't hide it
--   WorkViewUI.checkHere(car, zones) / clearCheck(car)   the scan result: a "Check here" marker over each zone +
--                                              the zone lit in a neutral colour (never a fault colour)
--   WorkViewUI.scanSweep(car, seconds)         the scan light sweeping over the car front to back
--   WorkViewUI.Cam[zone]                       the camera numbers for wr-dev (pitch, distance, fov, centre)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local HUD = require(script.Parent.HUD)
local JobCard = require(script.Parent.JobCard)
local PromptFocus = require(script.Parent.PromptFocus)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local WorkViewUI = {}

local C = UIStyle.Color
local player = Players.LocalPlayer

WorkViewUI.Exit = Instance.new("BindableEvent")
WorkViewUI.Cart = Instance.new("BindableEvent")
WorkViewUI.Lower = Instance.new("BindableEvent")

-- camera numbers per zone (car space; centre = the point looked at; pitch = degrees down from level; fov = vertical
-- degrees on a 16:9-ish phone). The car model's WorkCam_<zone> attachment wins when there is one.
-- (EngineBay 10-21: a step back and centred — measured on true 667×375 / 844×390 phone views, every tap part sits
-- between the top row and the hint line: notes/gpt/wr-ui/workview_phone_decision.md)
WorkViewUI.Cam = {
	EngineBay = { centre = Vector3.new(-0.8, 2.5, -6.5), pitch = 66, yaw = 0, distance = 7.0, fov = 50 },
	-- the wheel's own centre; two steps: the wheel still on (whole wheel in view) / the wheel off (caliper + pads)
	Wheel = { centre = Vector3.new(0, 0.375, 0), pitch = 12, yaw = 0, distance = 5.2, fov = 50 },
	WheelOff = { centre = Vector3.new(0, 0.375, 0), pitch = 12, yaw = 0, distance = 4.2, fov = 50 },
	Under = { centre = Vector3.new(0, 0.9, 0), pitch = -70, yaw = 0, distance = 2.6, fov = 60 },
}

local GLOW = {
	pickable = { fill = Color3.fromRGB(255, 220, 90), fillT = 0.75, line = Color3.fromRGB(255, 230, 120) },
	drag = { fill = Color3.fromRGB(255, 220, 90), fillT = 0.55, line = Color3.new(1, 1, 1) },
	target = { fill = Color3.fromRGB(110, 236, 120), fillT = 0.6, line = Color3.fromRGB(150, 255, 160) },
	zone = { fill = Color3.fromRGB(170, 220, 255), fillT = 0.85, line = Color3.fromRGB(200, 235, 255) },
}

local buttons: Frame? = nil
local lowerButton: TextButton? = nil
local lowerShown: string? = nil -- what the button shows now (lowerState)
local lowerWait = 0
local workCar: Model? = nil
local highlights: { [string]: Highlight } = {}
local ring: Frame? = nil
local ringTarget: Instance? = nil
local markers: { [Model]: { { gui: Frame, part: Instance, ok: boolean?, at: number? } } } = {}
local active: string? = nil

------------------------------------------------------------------------------------------------------- buttons

local function makeButtons()
	local f = Instance.new("Frame")
	f.Name = "WorkButtons"
	f.BackgroundTransparency = 1
	f.Size = UDim2.fromScale(1, 1)
	f.Visible = false
	f.Parent = HUD.gui()
	local exit = UIKit.button(f, { name = "Exit", key = "ui.work.exit", style = "Gray", anchor = Vector2.new(0, 1), max = 26, onClick = function()
		WorkViewUI.Exit:Fire()
	end })
	local cart = UIKit.button(f, { name = "Cart", key = "ui.work.cart", style = "Blue", anchor = Vector2.new(1, 1), max = 26, onClick = function()
		WorkViewUI.holdEnd() -- (a bolt's hold ring stayed up over the cart view: test 2)
		WorkViewUI.Cart:Fire()
	end })
	-- "Lower car" over Cart (the right thumb), orange: the jack's one big button (work_view 2b) — no walking out to
	-- the jack's prompt any more
	local lower
	lower = UIKit.button(f, { name = "Lower", key = "act.lowerCar", style = "Orange", anchor = Vector2.new(1, 1), max = 26, onClick = function()
		lower.Visible = false -- (gone at once; back if the server said no)
		lowerShown, lowerWait = nil, os.clock() + 0.8
		WorkViewUI.Lower:Fire()
	end })
	lower.Visible = false
	lowerButton = lower
	-- the thumbs' corners (where the stick / jump button are while walking), big on a phone (56 px+ tall), each as
	-- wide as its words (user 10-22: boxes fit the words); with a mouse just the words' size
	local function height(): number
		return UIKit.buttonH(UIKit.px(0.17, 56, 72))
	end
	for _, b in { exit, cart, lower } do
		UIKit.fitButton(b, { height = height, text = 0.46, pad = 0.4, max = 26, min = 1.4 })
	end
	UIKit.bind(f, function()
		local h = height()
		local gap = UIKit.hotbarGap()
		exit.Position = UDim2.new(0, 16, 1, -gap)
		cart.Position = UDim2.new(1, -16, 1, -gap)
		lower.Position = UDim2.new(1, -16, 1, -gap - h - 10)
	end)
	return f
end

-- can this car come down now? nil = no (not on its stands, or that end's wheels aren't on and tight — you don't lower
-- a car onto a bare hub); "" = yes; a name = yes, but someone else is in one of its work views / carrying one of its
-- parts (the server's height lock, WorkService.busyBy — the button says who, GPT r2 of work_view 2b)
local function lowerState(car: Model): string?
	local e = ((car:GetAttribute("Support") :: string?) or ""):match("^Stands(%u)$")
	local mech = car:FindFirstChild("MechanicalParts")
	if not e or not mech then
		return nil
	end
	for _, side in { "L", "R" } do
		local wheel = mech:FindFirstChild("Wheel_" .. e .. side)
		if not wheel or wheel:GetAttribute("State") ~= "Installed" then
			return nil
		end
		for _, d in wheel:GetDescendants() do
			if d:GetAttribute("Bolt") and d:GetAttribute("Tight") ~= true then
				return nil
			end
		end
	end
	-- the job at this end not done yet: the wheels are on and tight before it even starts (test 2 TOP8: the big orange
	-- button came the moment the wheel view opened, also on the tutorial's "loosen the 5 nuts")
	if car:GetAttribute("Fixed") ~= true and PromptFocus.jobFocus(car) == e then
		return nil
	end
	local id = car:GetAttribute("CarId")
	for _, p in Players:GetPlayers() do
		if p ~= player and p:GetAttribute("WorkCar") == id then
			return p.DisplayName
		end
	end
	local loose = workspace:FindFirstChild("LooseParts")
	for _, part in (if loose then loose:GetChildren() else {}) do
		local by = part:GetAttribute("CarriedBy")
		if by and by ~= player.UserId and part:GetAttribute("FromCar") == id then
			local p = Players:GetPlayerByUserId(by)
			return if p then p.DisplayName else "?"
		end
	end
	return ""
end

local function showLower()
	local b = lowerButton
	if not b or os.clock() < lowerWait then
		return
	end
	local state = if workCar and workCar.Parent then lowerState(workCar) else nil
	if state == lowerShown then
		return
	end
	local was = lowerShown
	lowerShown = state
	b.Visible = state ~= nil
	if state == "" then
		UIKit.setButton(b, nil, "Orange")
		UIKit.setText(b:FindFirstChild("Label", true) :: TextLabel, "act.lowerCar")
		if was == nil then
			UIKit.pop(b, 0.6) -- (it comes the moment the last nut is tight: the next thing to do)
		end
	elseif state then
		-- (a long display name would shrink the words to nothing on a phone button)
		local name = if utf8.len(state) and (utf8.len(state) :: number) > 10 then state:sub(1, (utf8.offset(state, 10) :: number) - 1) .. ".." else state
		UIKit.setLocked(b, "ui.work.busy", { name = name })
	end
end

task.spawn(function()
	while true do
		task.wait(0.2)
		if active then
			showLower()
		end
	end
end)

local touchWas: boolean? = nil

function WorkViewUI.enter(zone: string, car: Model?)
	active = zone
	workCar = car
	-- no walking in here: the phone's stick and jump button would sit on Exit and Cart (wr-play test 1 #8)
	if touchWas == nil then
		touchWas = GuiService.TouchControlsEnabled
		GuiService.TouchControlsEnabled = false
	end
	buttons = buttons or makeButtons()
	;(buttons :: Frame).Visible = true
	UIKit.open(buttons :: Frame)
	lowerShown = "?" -- (re-read for this car / zone now)
	showLower()
	-- the rest of the screen steps back while the car is open (Settings' Invite, the tutorial strip / Skip)
	HUD.gui():SetAttribute("WorkView", true)
	if (JobCard :: any).setCompact then
		(JobCard :: any).setCompact(true)
	end
end

function WorkViewUI.exit()
	active = nil
	workCar = nil
	if touchWas ~= nil then
		GuiService.TouchControlsEnabled = touchWas
		touchWas = nil
	end
	if buttons then
		buttons.Visible = false
	end
	WorkViewUI.glow(nil, "pickable")
	WorkViewUI.glow(nil, "target")
	WorkViewUI.glow(nil, "drag")
	WorkViewUI.holdEnd()
	HUD.gui():SetAttribute("WorkView", false)
	if (JobCard :: any).setCompact then
		(JobCard :: any).setCompact(false)
	end
end

function WorkViewUI.active(): string?
	return active
end

------------------------------------------------------------------------------------------------------- glow

-- one Highlight per kind (a part can be pickable while another is the target)
function WorkViewUI.glow(part: Instance?, kind: string)
	local h = highlights[kind]
	if not h then
		local look = GLOW[kind] or GLOW.pickable
		h = Instance.new("Highlight")
		h.Name = "WorkGlow_" .. kind
		h.FillColor = look.fill
		h.OutlineColor = look.line
		h.FillTransparency = look.fillT
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = workspace.CurrentCamera
		highlights[kind] = h
	end
	h.Adornee = part
	h.Enabled = part ~= nil
end

-- the pickable glow breathes so it reads as "touch me", the target one too (slower)
RunService.RenderStepped:Connect(function()
	local t = os.clock()
	local p = highlights.pickable
	if p and p.Enabled then
		p.OutlineTransparency = 0.1 + 0.3 * (0.5 + 0.5 * math.sin(t * 5))
	end
	local g = highlights.target
	if g and g.Enabled then
		g.FillTransparency = 0.45 + 0.3 * (0.5 + 0.5 * math.sin(t * 3))
	end
end)

------------------------------------------------------------------------------------------------------- hold ring

local DOTS = 12
local HINT_BOLTS = 3 -- the "Hold" word shows for this many bolts in a session
local boltsHeld = 0

local function makeRing(): Frame
	local f = Instance.new("Frame")
	f.Name = "HoldRing"
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.BackgroundColor3 = C.Plate
	f.BackgroundTransparency = 0.25
	f.Visible = false
	f.ZIndex = 9
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = f
	local s = Instance.new("UIStroke")
	s.Color = C.PlateEdge
	s.Thickness = 2
	s.Parent = f
	for i = 1, DOTS do
		local a = (i - 1) / DOTS * math.pi * 2 - math.pi / 2 -- from 12 o'clock, clockwise
		local d = Instance.new("Frame")
		d.Name = "Dot" .. i
		d.AnchorPoint = Vector2.new(0.5, 0.5)
		d.Position = UDim2.fromScale(0.5 + 0.36 * math.cos(a), 0.5 + 0.36 * math.sin(a))
		d.Size = UDim2.fromScale(0.17, 0.17)
		d.BackgroundColor3 = C.PlateEdge
		d.ZIndex = 10
		local dc = Instance.new("UICorner")
		dc.CornerRadius = UDim.new(1, 0)
		dc.Parent = d
		d.Parent = f
	end
	local icon = UIKit.icon(f, UIStyle.Icon.Wrench, { name = "Wrench", size = UDim2.fromScale(0.42, 0.42) })
	if icon then
		icon.ZIndex = 10
	end
	-- "Hold" under the ring for the first few bolts (dots alone don't say "keep pressing" — GPT r1)
	local hint = UIKit.text(f, { name = "Hint", key = "ui.work.hold", font = "Title", anchor = Vector2.new(0.5, 0), pos = UDim2.new(0.5, 0, 1, 4), size = UDim2.new(1.8, 0, 0.38, 0), max = 18 })
	hint.ZIndex = 10
	f.Parent = HUD.gui()
	return f
end

local function worldPos(t: Instance): Vector3?
	if t:IsA("Attachment") then
		return t.WorldPosition
	elseif t:IsA("BasePart") then
		return t.Position
	end
	return nil
end

-- share 0..1 of the hold; the ring sits up and to the right of the bolt (a right thumb covers the bolt and the
-- space below-left of it)
function WorkViewUI.hold(target: Instance, share: number)
	ring = ring or makeRing()
	local r = ring :: Frame
	ringTarget = target
	local lit = math.floor(math.clamp(share, 0, 1) * DOTS + 0.0001)
	for i = 1, DOTS do
		local d = r:FindFirstChild("Dot" .. i) :: Frame
		d.BackgroundColor3 = if i <= lit then C.Yellow else C.PlateEdge
	end
	local icon = r:FindFirstChild("Wrench")
	if icon then
		(icon :: ImageLabel).Rotation = share * 360
	end
	if share >= 1 and r.Visible then
		UIKit.pop(r, 1.25) -- the 'click' moment
		boltsHeld += 1
	end
	;(r:FindFirstChild("Hint") :: TextLabel).Visible = boltsHeld < HINT_BOLTS
	r.Visible = true
end

function WorkViewUI.holdEnd()
	ringTarget = nil
	if ring then
		ring.Visible = false
	end
end

RunService.RenderStepped:Connect(function()
	local r = ring
	local t = ringTarget
	if not r or not t or not r.Visible then
		return
	end
	local pos = worldPos(t)
	local cam = workspace.CurrentCamera
	if not pos or not cam then
		return
	end
	local v = cam:WorldToViewportPoint(pos)
	local inset = game:GetService("GuiService"):GetGuiInset()
	local d = UIKit.px(0.15, 52, 72)
	local z = UIKit.zoom()
	-- (the phone check draws into a shrunk frame: screen pixels → that frame's pixels)
	local root = r.Parent :: GuiObject
	local rel = (Vector2.new(v.X, v.Y - inset.Y) - root.AbsolutePosition) / z
	-- beside the bolt, never over the part being worked on (GPT r2: even 0.4 s of covering it is too much) and
	-- always inside the work area (not over the money bar row or the buttons). Tries the spots in order; if every
	-- spot touches the part, the smallest overlap wins and the ring shrinks.
	local size = UIKit.size()
	local top = math.max(0, UIKit.barHeight() + 4 - UIKit.topInset()) + 4
	local bottom = size.Y - UIKit.hotbarHeight() - UIKit.hotbarGap() - 22
	local part = if t:IsA("BasePart") then t:FindFirstAncestorWhichIsA("Model") or t else t.Parent
	local box0, box1 = Vector2.new(math.huge, math.huge), Vector2.new(-math.huge, -math.huge)
	if part and part:IsA("Model") then
		local cf, ext = part:GetBoundingBox()
		for _, sx in { -1, 1 } do
			for _, sy in { -1, 1 } do
				for _, sz in { -1, 1 } do
					local w = cam:WorldToViewportPoint(cf:PointToWorldSpace(ext / 2 * Vector3.new(sx, sy, sz)))
					local p = (Vector2.new(w.X, w.Y - inset.Y) - root.AbsolutePosition) / z
					box0, box1 = box0:Min(p), box1:Max(p)
				end
			end
		end
	end
	local function overlap(c: Vector2, half: number): number
		local x = math.max(0, math.min(c.X + half, box1.X) - math.max(c.X - half, box0.X))
		local y = math.max(0, math.min(c.Y + half, box1.Y) - math.max(c.Y - half, box0.Y))
		return x * y
	end
	local best, bestCost, bestD = nil, math.huge, d
	for _, scale in { 1, 0.75 } do
		local dd = d * scale
		local gap = dd * 0.6 + 6
		local spots = {}
		for _, dir in { Vector2.new(1, -1), Vector2.new(-1, -1), Vector2.new(1, 0), Vector2.new(-1, 0), Vector2.new(1, 1), Vector2.new(-1, 1) } do
			table.insert(spots, rel + dir.Unit * (gap + dd * 0.5))
		end
		-- a big part (a whole wheel): just outside its left / right edge, at the bolt's height
		if box1.X > box0.X then
			table.insert(spots, Vector2.new(box1.X + dd / 2 + 8, rel.Y))
			table.insert(spots, Vector2.new(box0.X - dd / 2 - 8, rel.Y))
		end
		for _, c in spots do
			local inside = c.X - dd / 2 >= 4 and c.X + dd / 2 <= size.X - 4 and c.Y - dd / 2 >= top and c.Y + dd / 2 <= bottom
			if inside then
				local cost = overlap(c, dd / 2)
				if cost < bestCost then
					best, bestCost, bestD = c, cost, dd
				end
			end
		end
		if bestCost == 0 then
			break
		end
	end
	best = best or Vector2.new(math.clamp(rel.X, d / 2 + 4, size.X - d / 2 - 4), math.clamp(rel.Y, top + d / 2, bottom - d / 2))
	r.Size = UDim2.fromOffset(bestD, bestD)
	r.Position = UDim2.fromOffset(best.X, best.Y)
end)

------------------------------------------------------------------------------------------------------- scan

-- the zone → the part to light and to hang the marker on
local function zoneParts(car: Model, zone: string): { Instance }
	local body = car:FindFirstChild("Body")
	local mech = car:FindFirstChild("MechanicalParts")
	if zone == "EngineBay" then
		return { body and body:FindFirstChild("Hood") } :: any
	elseif zone:sub(1, 6) == "Wheel_" then
		return { mech and mech:FindFirstChild(zone) } :: any
	elseif zone == "Under" or zone == "Under_Rear" then
		return { mech and mech:FindFirstChild("Muffler") } :: any
	elseif zone == "Body_Front" then
		return { body and body:FindFirstChild("Bumper_F") } :: any
	elseif zone == "Body_Rear" then
		return { body and body:FindFirstChild("Bumper_R") } :: any
	end
	return {}
end

function WorkViewUI.clearCheck(car: Model)
	for _, m in markers[car] or {} do
		m.gui:Destroy()
	end
	markers[car] = nil
	for _, h in car:GetChildren() do
		if h.Name == "CheckZone" then
			h:Destroy()
		end
	end
end

-- zones: names ("EngineBay", "Wheel_FL"…) or { zone = name, ok = true } — ok = the final check found that zone fixed:
-- a green ✓ "Fixed" marker and a green outline instead of the sky "Check here"
function WorkViewUI.checkHere(car: Model, zones: { any })
	WorkViewUI.clearCheck(car)
	local list = {}
	for _, item in zones do
		local zone = if type(item) == "table" then item.zone else item
		local ok = type(item) == "table" and item.ok == true
		for _, part in zoneParts(car, zone) do
			if part then
				-- the zone lit in a neutral sky colour (not a fault colour)
				local h = Instance.new("Highlight")
				h.Name = "CheckZone"
				h.Adornee = part
				h.FillColor = if ok then GLOW.target.fill else GLOW.zone.fill
				h.FillTransparency = GLOW.zone.fillT
				h.OutlineColor = if ok then GLOW.target.line else GLOW.zone.line
				h.DepthMode = Enum.HighlightDepthMode.Occluded
				h.Parent = car
				-- "Check here": a sky pill with a pointer, drawn on the screen over the zone (a screen element, like the
				-- tutorial arrow: same layer, exact pixel size, and it shows in the phone check)
				local b = Instance.new("Frame")
				b.Name = "CheckHere"
				b.AnchorPoint = Vector2.new(0.5, 1)
				b.BackgroundTransparency = 1
				b.Size = UDim2.fromOffset(130, 48)
				b:SetAttribute("World", true)
				local pill = Instance.new("Frame")
				pill.AnchorPoint = Vector2.new(0.5, 0)
				pill.Position = UDim2.fromScale(0.5, 0)
				pill.Size = UDim2.new(1, 0, 0, 34)
				pill.BackgroundColor3 = if ok then Color3.fromRGB(232, 252, 234) else Color3.fromRGB(235, 246, 255)
				local pc = Instance.new("UICorner")
				pc.CornerRadius = UDim.new(1, 0)
				pc.Parent = pill
				local ps = Instance.new("UIStroke")
				ps.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				ps.Color = if ok then C.GreenDark else Color3.fromRGB(40, 110, 190)
				ps.Thickness = 3
				ps.Parent = pill
				pill.Parent = b
				local check = if ok then UIKit.icon(pill, UIStyle.Icon.Check, { anchor = Vector2.new(0, 0.5), pos = UDim2.new(0, 4, 0.5, 0), size = UDim2.fromOffset(26, 26) }) else nil
				local word = UIKit.text(pill, { name = "Text", key = if ok then "ui.work.fixed" else "ui.work.checkHere", font = "Title", color = if ok then C.GreenDark else Color3.fromRGB(30, 80, 150), outline = false, size = UDim2.fromScale(0.86, 0.72), max = 20 })
				if check then
					word.Position = UDim2.new(0.5, 14, 0.5, 0)
					word.Size = UDim2.new(1, -40, 0.72, 0)
				end
				local tip = Instance.new("Frame")
				tip.Name = "Tip"
				tip.AnchorPoint = Vector2.new(0.5, 0.5)
				tip.Position = UDim2.new(0.5, 0, 0, 38)
				tip.Size = UDim2.fromOffset(14, 14)
				tip.Rotation = 45
				tip.BackgroundColor3 = if ok then C.GreenDark else Color3.fromRGB(40, 110, 190)
				tip.BorderSizePixel = 0
				tip.ZIndex = 0
				tip.Parent = b
				b.Parent = HUD.gui()
				table.insert(list, { gui = b, part = part, ok = ok, at = os.clock() })
			end
		end
	end
	markers[car] = list
end

-- markers that outlived their news (test 2: "Check here" still up after the fix, even behind the settlement card):
-- "Check here" goes once the car is fixed, the green "Fixed" ticks after 6 s, all of them once the car's gone
task.spawn(function()
	while true do
		task.wait(0.5)
		for car, list in markers do
			if not car.Parent or car:GetAttribute("Parked") ~= true then
				WorkViewUI.clearCheck(car)
				continue
			end
			local fixed = car:GetAttribute("Fixed") == true
			local stale = true
			for _, m in list do
				local keep = if m.ok then os.clock() - m.at < 6 else not fixed
				stale = stale and not keep
			end
			if stale then
				WorkViewUI.clearCheck(car)
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local inset = game:GetService("GuiService"):GetGuiInset()
	local bob = 6 * math.sin(os.clock() * 3)
	local char = player.Character
	local me = char and char:GetPivot().Position
	for _, list in markers do
		-- more than one zone: the nearest leads (full size), the rest wait smaller and lighter (GPT r2: two equal
		-- markers left 'which first?' open)
		local lead, leadD = nil, math.huge
		for _, m in list do
			local p0 = if m.part:IsA("Model") then m.part:GetPivot().Position else (m.part :: BasePart).Position
			local dist = if me then (p0 - me).Magnitude else 0
			if dist < leadD then
				lead, leadD = m, dist
			end
		end
		for _, m in list do
			local scale = m.gui:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
			scale.Parent = m.gui
			scale.Scale = if m == lead then 1 else 0.8
			m.gui:SetAttribute("Lead", m == lead)
			local part = m.part
			local pos = if part:IsA("Model") then part:GetPivot().Position elseif part:IsA("BasePart") then part.Position else nil
			if pos then
				-- a wheel: just outside its outer face (straight above it is the hood / fender — it read as the hood)
				local top = pos + Vector3.new(0, 1.6, 0)
				local car = part:FindFirstAncestorOfClass("Model")
				if part.Name:sub(1, 6) == "Wheel_" and car then
					local cf = car:GetPivot()
					local side = if cf:PointToObjectSpace(pos).X < 0 then -1 else 1
					top = pos + cf.RightVector * side * 1.4 + Vector3.new(0, 0.9, 0)
				end
				local v, onScreen = cam:WorldToViewportPoint(top)
				m.gui.Visible = onScreen
				local root = m.gui.Parent :: GuiObject
				local z = UIKit.zoom()
				local rel = (Vector2.new(v.X, v.Y - inset.Y) - root.AbsolutePosition) / z
				-- the pointer aims at the zone itself (a wheel's marker sits beside it, so the point would read as
				-- the hood otherwise — GPT r1); the pill stays under the money bar row
				local zv = cam:WorldToViewportPoint(pos)
				local zrel = (Vector2.new(zv.X, zv.Y - inset.Y) - root.AbsolutePosition) / z
				local y = math.max(rel.Y - 8 + bob, math.max(0, UIKit.barHeight() + 4 - UIKit.topInset()) + 48 + 4)
				-- never over the tutorial's Skip button (wr-gamer a06): the pill steps right of it
				local skip = HUD.gui():FindFirstChild("SkipTutorial", true) :: GuiObject?
				local x = rel.X
				if skip and skip.Visible then
					local sp = (skip.AbsolutePosition - root.AbsolutePosition) / z
					local sw = skip.AbsoluteSize.X / z
					local half = 65 * scale.Scale
					if y > sp.Y - 8 and y - 48 * scale.Scale < sp.Y + 36 and x - half < sp.X + sw + 6 and x + half > sp.X then
						x = sp.X + sw + 6 + half
					end
				end
				m.gui.Position = UDim2.fromOffset(x, y)
				local pill = m.gui:FindFirstChildOfClass("Frame")
				if pill then
					pill.BackgroundTransparency = if m.gui:GetAttribute("Lead") then 0 else 0.35
				end
				local tip = m.gui:FindFirstChild("Tip") :: Frame?
				if tip then
					local dx = math.clamp((zrel.X - x) * 0.4, -50, 50)
					tip.Position = UDim2.new(0.5, dx, 0, 38)
				end
			end
		end
	end
end)

-- a thin bright sheet passing over the car front to back (client only, for the one who scans)
function WorkViewUI.scanSweep(car: Model, seconds: number?)
	local time = seconds or 1
	local cf, size = car:GetBoundingBox()
	local p = Instance.new("Part")
	p.Name = "ScanSweep"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = Color3.fromRGB(150, 220, 255)
	p.Transparency = 0.35
	p.Size = Vector3.new(size.X + 0.6, size.Y + 0.6, 0.15)
	local front = car:GetPivot().LookVector * -1 -- the car's front is −Z
	local half = size.Z / 2
	p.CFrame = CFrame.lookAt(cf.Position + front * half, cf.Position + front * (half + 1))
	p.Parent = workspace.CurrentCamera
	TweenService:Create(p, TweenInfo.new(time, Enum.EasingStyle.Sine), { CFrame = p.CFrame - front * size.Z }):Play()
	task.delay(time, function()
		TweenService:Create(p, TweenInfo.new(0.2), { Transparency = 1 }):Play()
		task.delay(0.25, function()
			p:Destroy()
		end)
	end)
end

------------------------------------------------------------------------------------------------------- start

function WorkViewUI.start()
	require(script.Parent.PartTag).start() -- (the part name tag: hover / tap in the work view)
	-- Studio test hook only (like the loading screen's HoldForTest): a player attribute "UITestWork" = JSON
	-- { fn = "enter" | "exit" | "glow" | "hold" | "check" | "sweep", ... } drives the looks without wr-dev's code
	if not RunService:IsStudio() then
		return
	end
	player:GetAttributeChangedSignal("UITestWork"):Connect(function()
		local ok, cmd = pcall(HttpService.JSONDecode, HttpService, player:GetAttribute("UITestWork") or "")
		if not ok or type(cmd) ~= "table" then
			return
		end
		local function find(path: string?): Instance?
			local node: Instance? = workspace
			for n in (path or ""):gmatch("[^%.]+") do
				node = node and node:FindFirstChild(n)
			end
			return node
		end
		if cmd.fn == "enter" then
			WorkViewUI.enter(cmd.zone)
		elseif cmd.fn == "exit" then
			WorkViewUI.exit()
		elseif cmd.fn == "glow" then
			WorkViewUI.glow(find(cmd.path), cmd.kind)
		elseif cmd.fn == "hold" then
			local t = find(cmd.path)
			if t then
				WorkViewUI.hold(t, cmd.share)
			end
		elseif cmd.fn == "check" then
			WorkViewUI.checkHere(find(cmd.car) :: Model, cmd.zones)
		elseif cmd.fn == "sweep" then
			WorkViewUI.scanSweep(find(cmd.car) :: Model, cmd.seconds)
		end
	end)
end

return WorkViewUI
