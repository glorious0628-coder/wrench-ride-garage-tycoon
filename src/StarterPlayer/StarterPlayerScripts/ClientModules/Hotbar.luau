-- The tool bar (bottom centre, between the touch stick and the jump button) in place of Roblox's backpack bar:
-- slot 1 = bare hands, then the tools you own in a fixed order. Tap / click a slot or press 1..6 to hold it, again
-- to put it away. UI B look: dark plates, the held tool has a yellow edge. Each slot: the tool's picture big and its
-- number top left (keyboards only) — no name (user 10-22: "names on every slot look too messy"). The held tool's name
-- heads the hint line (HUD.hint), and one small name tag goes over a slot when needed (tagTarget): the tutorial's tool,
-- the slot the mouse rests on (PC), a pick the hint line doesn't name; it takes the hint's line while it shows.
-- (user 10-21: pictures, not just words; GPT: notes/gpt/wr-ui/hotbar_icons_decision.md, hotbar_names_decision.md)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local PartGraph = require(game:GetService("ReplicatedStorage").Shared.PartGraph)
local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local Hotbar = {}

local C = UIStyle.Color
-- (the Scanner stays on 3 whatever is bought later: new tools go behind it — wr-play eval 10-23 TOP 6, a bought Ratchet Wrench pushed it to 4)
local ORDER = { "Wrench", "Scanner", "RatchetWrench", "ImpactWrench", "BatteryTester", "Stethoscope", "OBDReader" }
local MAX = 6
local KEYS = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six }

-- set by the client entry: true while both hands carry a part (the slots go dim)
Hotbar.dimmed = nil :: (() -> boolean)?

local player = Players.LocalPlayer
local bar: Frame
local slots: { TextButton } = {}
local list: { Tool } = {} -- slot i + 1 = list[i]
local lastSig = ""
local nudgeName: string? = nil
-- the name tag: which slot the mouse is on (since when), which slot was just picked (when), how shown it is
local hoverSlot: number?, hoverAt = nil, 0
local flashSlot: number?, flashAt = nil, 0
local lastHeld: Tool? | false = false -- (false = not looked yet: the first look picks nothing)
local tag: Frame
local tagLabel: TextLabel
local tagSlot: number? = nil
local tagShown = 0
local HOVER_DELAY = 0.12 -- (a mouse just passing over the bar shows nothing)
local HINT_WAIT = 0.25 -- a pick waits for the hint line (Client fills it every 0.2 s): most hints start with the name
local FLASH = 1.5 -- (GPT r1: "Impact Wrench" on a phone needs more than a second)

local function rank(name: string): number
	return table.find(ORDER, name) or 100
end

local function owned(): { Tool }
	local out = {}
	for _, holder in { player:FindFirstChildOfClass("Backpack"), player.Character } do
		for _, t in (if holder then holder:GetChildren() else {}) do
			if t:IsA("Tool") then
				table.insert(out, t)
			end
		end
	end
	table.sort(out, function(a, b)
		local ra, rb = rank(a.Name), rank(b.Name)
		return if ra == rb then a.Name < b.Name else ra < rb
	end)
	return out
end

-- more tools than slots (Features.ToolMatch: the server puts the right tool in the hand for each fastener, so the
-- turning tools need no slot of their own): the bar keeps what you pick yourself (Scanner, tester, stethoscope ...)
-- and one slot for the best bolt tool; FusePuller / PlugSocket / TrimTool … come by themselves when you press their
-- fastener. Only while the tools wouldn't fit — a short list shows everything as before.
local function visibleTools(all: { Tool }): { Tool }
	if #all + 1 <= MAX or not Config.feature("ToolMatch") then
		return all
	end
	local out: { Tool } = {}
	local best: Tool? = nil
	local bestRank = -math.huge
	for _, t in all do
		local row = PartGraph.Tools[t.Name]
		if not row then
			table.insert(out, t)
		elseif table.find(row.does, "Bolt") and row.rank > bestRank then
			best, bestRank = t, row.rank
		end
	end
	-- the tool the server just put in the hand for a fastener (the trim tool for a clip …) takes the bolt slot while it
	-- is held: the slot lights and its name tag says what came into the hand
	local char = player.Character
	local inHand = char and char:FindFirstChildOfClass("Tool")
	if inHand and PartGraph.Tools[inHand.Name] and not table.find(out, inHand) then
		best = inHand
	end
	if best then
		table.insert(out, best)
	end
	table.sort(out, function(a, b)
		local ra, rb = rank(a.Name), rank(b.Name)
		return if ra == rb then a.Name < b.Name else ra < rb
	end)
	while #out + 1 > MAX do
		table.remove(out)
	end
	return out
end

local function held(): Tool?
	local char = player.Character
	return char and char:FindFirstChildOfClass("Tool")
end

local function choose(i: number)
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	local tool = list[i - 1]
	local away = i == 1 or not tool or held() == tool
	if away then
		hum:UnequipTools()
	else
		hum:EquipTool(tool)
	end
	-- (refresh() would notice the change a moment later)
	flashSlot, flashAt = if away then 1 else i, os.clock()
end

local function nameOf(i: number): string
	return if i == 1 then "Hand" else list[i - 1].Name
end

local function keyOf(i: number): string
	return if i == 1 then "ui.hand" else "tool." .. nameOf(i)
end

local function build()
	for _, s in slots do
		s:Destroy()
	end
	slots = {}
	hoverSlot, flashSlot, tagSlot = nil, nil, nil
	for i = 1, math.min(#list + 1, MAX) do
		local name = nameOf(i)
		local s = UIKit.plateButton(bar, { name = "Slot" .. i, kit = "slot" }, function()
			choose(i)
		end)
		s:SetAttribute("Tool", name)
		-- the picture in the middle of the slot (no name under it any more)
		local big = if name == "Scanner" then 0.78 else 0.72 -- (the scanner is tall and thin)
		if UIStyle.SlotHalo and UIStyle.Icon[name] and UIStyle.Icon[name] ~= "" then
			local halo = Instance.new("Frame") -- a soft light disc so dark pictures keep their outline
			halo.Name = "Halo"
			halo.AnchorPoint = Vector2.new(0.5, 0.5)
			halo.Position = UDim2.fromScale(0.5, 0.5)
			halo.Size = UDim2.fromScale(0.74, 0.74)
			halo.BackgroundColor3 = Color3.new(1, 1, 1)
			halo.BackgroundTransparency = UIStyle.SlotHalo
			local hc = Instance.new("UICorner")
			hc.CornerRadius = UDim.new(1, 0)
			hc.Parent = halo
			halo.Parent = s
		end
		local icon = UIKit.icon(s, UIStyle.Icon[name], { size = UDim2.fromScale(big, big), pos = UDim2.fromScale(0.5, 0.5) })
		local key = keyOf(i)
		-- a mouse resting on the slot shows its name tag (touch screens fire MouseEnter on a tap and never leave)
		s.MouseEnter:Connect(function()
			if UIKit.keyboard() then
				hoverSlot, hoverAt = i, os.clock()
			end
		end)
		s.MouseLeave:Connect(function()
			if hoverSlot == i then
				hoverSlot = nil
			end
		end)
		if not icon then
			-- no picture yet: the name big in the middle; one word never breaks in the middle
			local label = Localizer.t(key)
			UIKit.text(s, {
				name = "Name",
				key = key,
				pos = UDim2.fromScale(0.5, 0.6),
				size = UDim2.fromScale(0.88, if label:find(" ") then 0.56 else 0.3),
				wrap = label:find(" ") ~= nil,
				max = 16,
			})
		end
		local key = UIKit.text(s, {
			name = "Key",
			text = tostring(i),
			font = "Title",
			anchor = Vector2.new(0, 0),
			pos = UDim2.fromScale(0.08, 0.04),
			size = UDim2.fromScale(0.3, 0.3),
			alignX = Enum.TextXAlignment.Left,
			max = 18,
		})
		key.Visible = UIKit.keyboard()
		local dim = Instance.new("Frame")
		dim.Name = "Dim"
		dim.Size = UDim2.fromScale(1, 1)
		dim.BackgroundColor3 = Color3.new(0, 0, 0)
		dim.BackgroundTransparency = 0.45
		dim.ZIndex = 3
		dim.Visible = false
		local dc = Instance.new("UICorner")
		dc.CornerRadius = UDim.new(0.12, 0)
		dc.Parent = dim
		dim.Parent = s
		slots[i] = s
	end
end

local function layout()
	local h = HUD.hotbarHeight()
	local gap = math.floor(h * 0.12)
	local n = #slots
	bar.Size = UDim2.fromOffset(n * h + (n - 1) * gap, h)
	bar.Position = UDim2.new(0.5, 0, 1, -UIKit.hotbarGap())
	for i, s in slots do
		s.Size = UDim2.fromOffset(h, h)
		s:SetAttribute("X", (i - 1) * (h + gap) + h / 2)
	end
end

local function refresh()
	list = visibleTools(owned())
	local names = {}
	for _, t in list do
		table.insert(names, t.Name)
	end
	local sig = table.concat(names, ",")
	if sig ~= lastSig then
		lastSig = sig
		build()
		layout()
	end
	local now = held()
	if now ~= lastHeld then
		-- a tool picked (or put away), also by code (the tutorial hands you the wrench): see tagTarget
		if lastHeld ~= false then
			local at = if now then table.find(list, now) else 0
			flashSlot, flashAt = if at then at + 1 else nil, os.clock()
		end
		lastHeld = now
	end
	local dimmed = Hotbar.dimmed ~= nil and Hotbar.dimmed()
	for i, s in slots do
		local on = if i == 1 then now == nil else list[i - 1] == now
		-- the held tool: the gold slot picture (or the yellow edge in the code look)
		local skin = s:FindFirstChild("Skin") :: ImageLabel?
		if skin then
			local k = if on then UIStyle.Kit.slotSelected else UIStyle.Kit.slot
			skin.Image = k.id
		end
		local edge = s:FindFirstChildOfClass("UIStroke")
		if edge and edge.Enabled then
			edge.Color = if on then C.Yellow else C.PlateEdge
			edge.Thickness = if on then UIKit.px(0.012, 3, 5) else UIKit.px(UIStyle.Size.Stroke, 1, 4)
		end
		local dim = s:FindFirstChild("Dim") :: Frame?
		if dim then
			dim.Visible = dimmed and i > 1
		end
	end
end

-- the name tag: a small dark plate, one line, sized to its word
local function makeTag()
	tag = Instance.new("Frame")
	tag.Name = "NameTag"
	tag.AnchorPoint = Vector2.new(0.5, 1)
	tag.AutomaticSize = Enum.AutomaticSize.X
	tag.BackgroundColor3 = C.Plate
	tag.BorderSizePixel = 0
	tag.ZIndex = 5
	tag.Visible = false
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = tag
	local edge = Instance.new("UIStroke")
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Color = C.PlateEdge
	edge.Thickness = 1.5
	edge.Parent = tag
	local pad = Instance.new("UIPadding")
	pad.Parent = tag
	tagLabel = Instance.new("TextLabel")
	tagLabel.Name = "Label"
	tagLabel.AutomaticSize = Enum.AutomaticSize.X
	tagLabel.BackgroundTransparency = 1
	tagLabel.FontFace = UIStyle.Font.Bold
	tagLabel.TextColor3 = C.White
	tagLabel.ZIndex = 6
	tagLabel.Parent = tag
	UIKit.outline(tagLabel)
	tag.Parent = bar
	UIKit.bind(tag, function()
		local size = UIKit.px(0.045, 14, 20)
		tagLabel.TextSize = size
		tagLabel.Size = UDim2.fromOffset(0, size + 8)
		tag.Size = UDim2.fromOffset(0, size + 8)
		pad.PaddingLeft = UDim.new(0, math.floor(size * 0.6))
		pad.PaddingRight = pad.PaddingLeft
	end)
end

-- which slot wears the tag now (GPT r1: the tutorial's beats a parked mouse):
-- 1. the tutorial's tool, while it isn't in the hand yet (once it is, the hint line names it)
-- 2. the slot the mouse rests on (PC)
-- 3. the slot just picked: on a phone always, at once (the tap's answer, picture ↔ word; the hint follows when it
--    goes — GPT r2), on a PC only when the hint line stays empty (Hand, a tool with no hint): every other hint starts
--    with the tool's name in yellow at once and the mouse can rest on the slot (GPT r1: no pick flash on a PC)
local function tagTarget(): number?
	if nudgeName then
		local now = held()
		for i, s in slots do
			if s:GetAttribute("Tool") == nudgeName and not (now and now.Name == nudgeName) then
				return i
			end
		end
	end
	if hoverSlot and slots[hoverSlot] and os.clock() - hoverAt >= HOVER_DELAY then
		return hoverSlot
	end
	local since = os.clock() - flashAt
	if flashSlot and slots[flashSlot] then
		if not UIKit.keyboard() and since < FLASH then
			return flashSlot
		end
		if since >= HINT_WAIT and since < HINT_WAIT + FLASH and HUD.hintEmpty() then
			return flashSlot
		end
	end
	return nil
end

local function updateTag(dt: number)
	local want = tagTarget()
	if want and want ~= tagSlot then
		tagSlot = want
		UIKit.setText(tagLabel, keyOf(want))
	end
	-- fades in fast, out a little slower; the hint line fades the other way (they share the line)
	local goal = if want then 1 else 0
	local before = tagShown
	tagShown = math.clamp(tagShown + (goal - tagShown) * math.min(dt * (if want then 18 else 10), 1), 0, 1)
	if math.abs(tagShown - goal) < 0.02 then
		tagShown = goal
	end
	if tagShown ~= before then
		local t = 1 - tagShown
		tag.Visible = tagShown > 0
		tag.BackgroundTransparency = 0.08 + 0.92 * t
		tagLabel.TextTransparency = t
		for _, st in { tag:FindFirstChildOfClass("UIStroke"), tagLabel:FindFirstChildOfClass("UIStroke") } do
			(st :: UIStroke).Transparency = t
		end
		HUD.hintFade(tagShown)
	end
	local s = tagSlot and slots[tagSlot]
	if s and tag.Visible then
		-- just over the slot, riding its bob
		tag.Position = UDim2.new(0, (s:GetAttribute("X") :: number?) or 0, s.Position.Y.Scale - 0.5, -6)
	end
end

-- the tutorial points at a tool: that slot bobs until nudge(nil)
function Hotbar.nudge(toolName: string?)
	nudgeName = toolName
end

function Hotbar.start()
	-- Roblox's own bar off (it can say no while the core scripts load)
	task.spawn(function()
		for _ = 1, 20 do
			if pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Backpack, false) then
				break
			end
			task.wait(0.5)
		end
	end)
	bar = Instance.new("Frame")
	bar.Name = "Hotbar"
	bar.AnchorPoint = Vector2.new(0.5, 1)
	bar.BackgroundTransparency = 1
	bar.Parent = HUD.gui()
	makeTag()
	local keyboard = UIKit.keyboard()
	UIKit.bind(bar, function()
		layout()
		if UIKit.keyboard() ~= keyboard then
			keyboard = UIKit.keyboard()
			lastSig = "" -- (the phone check switched on / off: names and numbers come and go)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		local i = table.find(KEYS, input.KeyCode)
		if i and slots[i] then
			choose(i)
		end
	end)
	RunService.RenderStepped:Connect(function(dt)
		-- the slot under the mouse, found by position every frame (a MouseEnter is lost when the bar is rebuilt under a
		-- resting mouse — a tool picked up, the list changed — and the name then never came: user 10-22 "no names")
		if UIKit.keyboard() then
			local m = UserInputService:GetMouseLocation()
			local gi = GuiService:GetGuiInset()
			local found: number? = nil
			for i, s in slots do
				local p, sz = s.AbsolutePosition, s.AbsoluteSize
				if m.X >= p.X and m.X <= p.X + sz.X and m.Y - gi.Y >= p.Y and m.Y - gi.Y <= p.Y + sz.Y then
					found = i
					break
				end
			end
			if found ~= hoverSlot then
				hoverSlot, hoverAt = found, os.clock()
			end
		end
		for _, s in slots do
			-- (placed by hand, not a list layout, so the tutorial's bob can move a slot)
			local bob = if nudgeName and s:GetAttribute("Tool") == nudgeName then -math.abs(math.sin(os.clock() * 5)) * 0.18 else 0
			s.Position = UDim2.new(0, (s:GetAttribute("X") :: number?) or 0, 0.5 + bob, 0)
		end
		updateTag(dt)
	end)
	task.spawn(function()
		while true do
			refresh()
			task.wait(0.15)
		end
	end)
end

return Hotbar
