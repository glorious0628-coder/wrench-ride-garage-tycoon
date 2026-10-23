-- Builds the UI B pieces (UIStyle): text with a thin outline, metal plates with corner bolts, the red window with
-- a hazard stripe, buttons and tabs — and the motion: buttons grow 1.1x on hover, 0.9x on press and spring back to
-- 1x on release; windows fade in with a short slide (YouTube notes 8 / 17).
-- Layout is Scale + aspect ratio; edge widths and bolt sizes follow the screen height (UIKit.px).
-- Phone check: set the HUD ScreenGui attribute EmuSize = Vector2(844, 390) (and EmuInset = top bar px) in Play —
-- every screen element moves into a frame that size, with the touch stick / jump button drawn where they sit.

local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local Localizer = require(script.Parent.Localizer)
local UIStyle = require(script.Parent.UIStyle)

local UIKit = {}
local windowClose: { [Instance]: () -> () } = {} -- (each window's own close, so UIKit.closeOthers shuts it the way its X would)

local C = UIStyle.Color
local A = UIStyle.Anim
local S = UIStyle.Size

local root: ScreenGui? = nil
local emu: Frame? = nil
local emuZoom = 1
local resized = Instance.new("BindableEvent")
local langChanged = Instance.new("BindableEvent") -- after every label is re-filled in the new language

-- the screen the UI lays out in (the emulated phone while EmuSize is set)
function UIKit.size(): Vector2
	if emu then
		return emu.AbsoluteSize / emuZoom
	elseif root then
		return root.AbsoluteSize
	end
	local cam = workspace.CurrentCamera
	return if cam then cam.ViewportSize else Vector2.new(1280, 720)
end

-- a keyboard to show key numbers / tool names for (the phone check counts as a phone)
function UIKit.keyboard(): boolean
	return emu == nil and game:GetService("UserInputService").KeyboardEnabled
end

-- AbsoluteSize / TextBounds read this much smaller than the layout size while the phone check is zoomed
function UIKit.zoom(): number
	return emuZoom
end

-- a share of the screen height in whole pixels, kept between lo and hi
function UIKit.px(share: number, lo: number, hi: number): number
	return math.clamp(math.floor(UIKit.size().Y * share + 0.5), lo, hi)
end

-- the Roblox top bar height above the HUD (the emulated one while EmuSize is set)
function UIKit.topInset(): number
	if emu and root then
		return (root:GetAttribute("EmuInset") :: number?) or 36
	end
	return game:GetService("GuiService"):GetGuiInset().Y
end

-- where Roblox's own top bar buttons (menu, chat...) end on the left: our things in that row start after it
function UIKit.topbarLeft(): number
	if emu then
		return UIKit.topInset() * 2 -- (the phone check draws two round buttons there)
	end
	return game:GetService("GuiService").TopbarInset.Min.X
end

-- the money bar and the tool bar heights (HUD / Hotbar use these; windows keep clear of both)
function UIKit.barHeight(): number
	return UIKit.px(0.12, 38, 56)
end

-- the bottom edge of the top-right corner buttons (the gear), in layout px from the top of the play area: what a right-
-- column card (job card, tutorial strip) must start under. 0 when the gear is not up. (667x375: it reaches below the
-- money bar row and sat on the job card's corner.)
function UIKit.cornerBottom(): number
	local gui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
	local hud = gui and gui:FindFirstChild("HUD")
	local gear = hud and hud:FindFirstChild("SettingsButton", true) :: GuiObject?
	if not gear or not gear.Visible or not gear.Parent then
		return 0
	end
	local parent = gear.Parent :: GuiObject
	return (gear.AbsolutePosition.Y + gear.AbsoluteSize.Y - parent.AbsolutePosition.Y) / emuZoom
end

function UIKit.hotbarHeight(): number
	return UIKit.px(0.17, 48, 72) -- (≈56 px on a phone: GPT round, notes/gpt/wr-ui/hotbar_icons_decision.md)
end

function UIKit.hotbarGap(): number
	return UIKit.px(0.025, 4, 14)
end

-- run fn now and on every screen resize, for as long as inst lives
function UIKit.bind(inst: Instance, fn: (Vector2) -> ())
	fn(UIKit.size())
	local conn = resized.Event:Connect(fn)
	inst.Destroying:Connect(function()
		conn:Disconnect()
	end)
end

local function corner(parent: Instance, share: number?): UICorner
	local c = Instance.new("UICorner")
	c.Parent = parent
	UIKit.bind(c, function()
		c.CornerRadius = UDim.new(0, UIKit.px(share or S.Corner, 4, 16))
	end)
	return c
end

local function edge(parent: Instance, color: Color3, share: number?): UIStroke
	local s = Instance.new("UIStroke")
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = color
	s.Parent = parent
	UIKit.bind(s, function()
		s.Thickness = UIKit.px(share or S.Stroke, 1, 4)
	end)
	return s
end

-- top-to-bottom shading: the colour at the top, `low` (0..1) of it at the bottom
local function shade(parent: Instance, low: number, rotation: number?): UIGradient
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(low, low, low))
	g.Rotation = rotation or 90
	g.Parent = parent
	return g
end

-- a thin outline that follows the text height (thin, so small text keeps its strokes)
function UIKit.outline(l: TextLabel | TextButton, color: Color3?): UIStroke
	local s = Instance.new("UIStroke")
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Color = color or C.Outline
	s.Parent = l
	local function fit()
		local h = l.TextSize
		if l.TextScaled then
			local cap = l:FindFirstChildOfClass("UITextSizeConstraint")
			h = math.min(l.TextBounds.Y / emuZoom, l.AbsoluteSize.Y / emuZoom, if cap then cap.MaxTextSize else math.huge)
		end
		-- Hangul comes from a fallback font with thinner strokes than ours: a heavier rim keeps it as strong
		local ko = if Localizer.lang == "ko" then 1.3 else 1
		s.Thickness = math.clamp(h * S.TextOutline * ko, 1.5, 3.5)
	end
	l:GetPropertyChangedSignal("TextBounds"):Connect(fit)
	l:GetPropertyChangedSignal("TextSize"):Connect(fit)
	local conn = langChanged.Event:Connect(fit)
	l.Destroying:Connect(function()
		conn:Disconnect()
	end)
	fit()
	return s
end

-- language: labels keep their Locale key (attributes UiKey / UiArgs) and are re-filled on a language change

function UIKit.setText(l: TextLabel | TextButton, key: string?, args: { [string]: any }?)
	l:SetAttribute("UiKey", key)
	l:SetAttribute("UiArgs", if args then HttpService:JSONEncode(args) else nil)
	l.Text = if key then Localizer.t(key, args) else ""
end

local function relabel(under: Instance)
	for _, d in under:GetDescendants() do
		local key = d:GetAttribute("UiKey")
		if type(key) == "string" and (d:IsA("TextLabel") or d:IsA("TextButton")) then
			local raw = d:GetAttribute("UiArgs") :: string?
			local args = if raw then HttpService:JSONDecode(raw) else nil
			d.Text = Localizer.t(key, args)
		end
	end
end

-- run fn after every language change (for text a screen computes itself)
function UIKit.onLang(fn: () -> ())
	langChanged.Event:Connect(fn)
end

export type TextProps = {
	name: string?,
	text: string?, -- fixed text (numbers, "X"); words come from key
	key: string?, -- a Locale key: re-filled when the language changes
	args: { [string]: any }?,
	font: string?, -- "Title" | "Body" | "Bold"
	color: Color3?,
	size: UDim2?,
	pos: UDim2?,
	anchor: Vector2?,
	alignX: Enum.TextXAlignment?,
	max: number?, -- biggest text size (TextScaled)
	outline: boolean?, -- default true
	outlineColor: Color3?,
	wrap: boolean?,
	rich: boolean?,
	z: number?,
}

-- a scaled text label (TextScaled, capped at max)
function UIKit.text(parent: Instance, p: TextProps): TextLabel
	local l = Instance.new("TextLabel")
	l.Name = p.name or "Text"
	l.Text = p.text or ""
	if p.key then
		UIKit.setText(l, p.key, p.args)
	end
	l.FontFace = UIStyle.Font[p.font or "Body"]
	l.TextColor3 = p.color or C.White
	l.Size = p.size or UDim2.fromScale(1, 1)
	l.Position = p.pos or UDim2.fromScale(0.5, 0.5)
	l.AnchorPoint = p.anchor or Vector2.new(0.5, 0.5)
	l.TextXAlignment = p.alignX or Enum.TextXAlignment.Center
	l.BackgroundTransparency = 1
	l.TextWrapped = p.wrap == true
	l.TextScaled = true -- (after TextWrapped: TextWrapped = false turns scaling off)
	l.RichText = p.rich == true
	if p.z then
		l.ZIndex = p.z
	end
	local cap = Instance.new("UITextSizeConstraint")
	cap.MaxTextSize = p.max or 40
	cap.MinTextSize = 8
	cap.Parent = l
	if p.outline ~= false then
		UIKit.outline(l, p.outlineColor)
	end
	l.Parent = parent
	return l
end

-- a text size (not scaled) that follows the screen: for wrapped, auto-sized blocks (job card)
function UIKit.textSize(l: TextLabel | TextButton, share: number, lo: number, hi: number)
	UIKit.bind(l, function()
		l.TextSize = UIKit.px(share, lo, hi)
	end)
end

-- a kit B picture behind a box (UIStyle.Kit[name]): 9-sliced when the kit has a slice, else stretched. The box's
-- own fill, edge and bolts give way to it. corner(size) = the on-screen size of the sliced ends for this box size.
-- Returns nil when the picture isn't uploaded (the code look stays).
function UIKit.skin(host: GuiObject, name: string, corner: ((Vector2) -> number)?): ImageLabel?
	local k = UIStyle.Kit[name]
	if not k or k.id == "" then
		return nil
	end
	local r = k.rect
	local img = Instance.new("ImageLabel")
	img.Name = "Skin"
	img.BackgroundTransparency = 1
	img.Image = k.id
	img.ImageRectOffset = Vector2.new(r[1], r[2])
	img.ImageRectSize = Vector2.new(r[3] - r[1], r[4] - r[2])
	img.Size = UDim2.fromScale(1, 1)
	img.ZIndex = 0 -- (under the box's other children)
	if k.slice then
		local sl = k.slice
		img.ScaleType = Enum.ScaleType.Slice
		img.SliceCenter = Rect.new(sl[1] - r[1], sl[2] - r[2], sl[3] - r[1], sl[4] - r[2])
		local margin = math.max(sl[1] - r[1], sl[2] - r[2])
		local function fit()
			local size = host.AbsoluteSize / emuZoom
			if size.Y < 1 then
				return
			end
			-- default: keep the picture's own height ratio (buttons), else the given corner size
			local px = if corner then corner(size) else size.Y * margin / (r[4] - r[2])
			img.SliceScale = math.max(px / margin, 0.01)
		end
		host:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
		fit()
	else
		img.ScaleType = Enum.ScaleType.Stretch
	end
	-- the box's code look off
	host.BackgroundTransparency = 1
	for _, c in host:GetChildren() do
		if c:IsA("UIStroke") then
			c.Enabled = false
		end
	end
	img.Parent = host
	return img
end

-- the plate-style corners: about a third of the shorter side, 10..26 px
local function plateCorner(size: Vector2): number
	return math.clamp(math.min(size.X, size.Y) * 0.4, 14, 30)
end

-- four bolts in the corners of a frame (the only decoration, and only on outer frames)
function UIKit.bolts(frame: GuiObject, share: number?)
	for i, a in { Vector2.new(0, 0), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(1, 1) } do
		local b = Instance.new("Frame")
		b.Name = "Bolt" .. i
		b.AnchorPoint = a
		b.BackgroundColor3 = C.Bolt
		b.ZIndex = frame.ZIndex + 1
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = b
		shade(b, 0.62, 45)
		local s = Instance.new("UIStroke")
		s.Color = C.BoltDark
		s.Thickness = 1
		s.Parent = b
		b.Parent = frame
		UIKit.bind(b, function()
			local d = UIKit.px(share or S.Bolt, 5, 13)
			local inset = math.floor(d * 0.55)
			b.Size = UDim2.fromOffset(d, d)
			b.Position = UDim2.new(a.X, if a.X == 0 then inset else -inset, a.Y, if a.Y == 0 then inset else -inset)
		end)
	end
end

export type BoxProps = {
	name: string?,
	size: UDim2?,
	pos: UDim2?,
	anchor: Vector2?,
	bolts: boolean?,
	z: number?,
	group: boolean?, -- a CanvasGroup (the whole box can fade)
	kit: string?, -- a UIStyle.Kit picture instead of the code look
}

local function box(parent: Instance, p: BoxProps, color: Color3, edgeColor: Color3, low: number, class: string?): any
	local f = Instance.new(class or "Frame") :: any
	f.Name = p.name or "Box"
	f.Size = p.size or UDim2.fromScale(1, 1)
	f.Position = p.pos or UDim2.fromScale(0.5, 0.5)
	f.AnchorPoint = p.anchor or Vector2.new(0.5, 0.5)
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	if p.z then
		f.ZIndex = p.z
	end
	corner(f)
	edge(f, edgeColor)
	local g = shade(f, low)
	local skin = p.kit and UIKit.skin(f, p.kit, if p.kit == "plate" then plateCorner else nil)
	if skin then
		-- the picture has its own light; on a CanvasGroup the shading would also darken everything inside (the job
		-- card's words read grey, the prompt card's yellow key went brown)
		g:Destroy()
	end
	if p.bolts and not skin then -- (the pictures carry their own bolts)
		UIKit.bolts(f)
	end
	f.Parent = parent
	return f
end

-- the dark metal plate (money bar, job card, tool slots)
function UIKit.plate(parent: Instance, p: BoxProps): Frame
	p.kit = p.kit or "plate"
	return box(parent, p, C.PlateLight, C.PlateEdge, 0.62, if p.group then "CanvasGroup" else nil)
end

-- a dark plate you can press (tool slots): no text of its own, children carry the look
function UIKit.plateButton(parent: Instance, p: BoxProps, onClick: (() -> ())?): TextButton
	p.kit = p.kit or "plate"
	local b = box(parent, p, C.PlateLight, C.PlateEdge, 0.62, "TextButton") :: TextButton
	b.Text = ""
	b.AutoButtonColor = false
	UIKit.press(b, onClick)
	return b
end

-- the light steel panel inside a window
function UIKit.steel(parent: Instance, p: BoxProps): Frame
	return box(parent, p, C.SteelLight, C.SteelDark, 0.86)
end

-- a white list row
function UIKit.row(parent: Instance, p: BoxProps): Frame
	return box(parent, p, C.Row, C.RowEdge, 0.93)
end

-- a vertical scroll list (rows: UIKit.row with a pixel height from UIKit.px, LayoutOrder sorts)
function UIKit.list(parent: Instance, p: BoxProps): ScrollingFrame
	local sf = Instance.new("ScrollingFrame")
	sf.Name = p.name or "List"
	sf.Size = p.size or UDim2.fromScale(1, 1)
	sf.Position = p.pos or UDim2.fromScale(0.5, 0)
	sf.AnchorPoint = p.anchor or Vector2.new(0.5, 0)
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel = 0
	sf.CanvasSize = UDim2.new()
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.ScrollingDirection = Enum.ScrollingDirection.Y
	sf.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	-- (dark and thick enough to say "there's more below": a half-hidden last row alone read as cut off — GPT
	-- settings_sound r2)
	sf.ScrollBarImageColor3 = C.Ink
	sf.ScrollBarImageTransparency = 0.25
	local ll = Instance.new("UIListLayout")
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ll.Parent = sf
	local pad = Instance.new("UIPadding") -- room for a row's button to grow on hover
	pad.Parent = sf
	UIKit.bind(sf, function()
		sf.ScrollBarThickness = UIKit.px(0.024, 9, 12)
		ll.Padding = UDim.new(0, UIKit.px(0.014, 3, 8))
		pad.PaddingTop = UDim.new(0, UIKit.px(0.012, 3, 6))
		pad.PaddingBottom = pad.PaddingTop
	end)
	sf.Parent = parent
	return sf
end

-- the yellow / black hazard stripe (bars rebuilt to fit the width)
function UIKit.hazard(parent: Instance, p: BoxProps): Frame
	local f = Instance.new("Frame")
	f.Name = p.name or "Hazard"
	f.Size = p.size or UDim2.fromScale(1, 0.04)
	f.Position = p.pos or UDim2.fromScale(0.5, 0)
	f.AnchorPoint = p.anchor or Vector2.new(0.5, 0)
	f.BackgroundColor3 = C.Yellow
	f.BorderSizePixel = 0
	f.ClipsDescendants = true
	if p.z then
		f.ZIndex = p.z
	end
	f.Parent = parent
	local k = UIStyle.Kit.hazard
	if k and k.id ~= "" then
		local r = k.rect
		local img = Instance.new("ImageLabel")
		img.Name = "Skin"
		img.BackgroundTransparency = 1
		img.Image = k.id
		img.ImageRectOffset = Vector2.new(r[1], r[2])
		img.ImageRectSize = Vector2.new(r[3] - r[1], r[4] - r[2])
		img.ScaleType = Enum.ScaleType.Tile
		img.Size = UDim2.fromScale(1, 1)
		img.ZIndex = f.ZIndex
		img.Parent = f
		f.BackgroundTransparency = 1
		local function tile()
			local h = math.max(f.AbsoluteSize.Y, 1)
			img.TileSize = UDim2.fromOffset(h * (r[3] - r[1]) / (r[4] - r[2]), h)
		end
		f:GetPropertyChangedSignal("AbsoluteSize"):Connect(tile)
		tile()
		return f
	end
	local function build()
		for _, c in f:GetChildren() do
			c:Destroy()
		end
		local w, h = f.AbsoluteSize.X / emuZoom, f.AbsoluteSize.Y / emuZoom
		if h < 1 then
			return
		end
		local step = h * 2.2
		for i = 0, math.ceil(w / step) + 1 do
			local bar = Instance.new("Frame")
			bar.AnchorPoint = Vector2.new(0.5, 0.5)
			bar.Size = UDim2.fromOffset(h * 1.1, h * 3)
			bar.Position = UDim2.new(0, i * step, 0.5, 0)
			bar.Rotation = 40
			bar.BackgroundColor3 = C.Black
			bar.BorderSizePixel = 0
			bar.ZIndex = f.ZIndex
			bar.Parent = f
		end
	end
	f:GetPropertyChangedSignal("AbsoluteSize"):Connect(build)
	build()
	return f
end

-- an image (icon) when its id is known; nil before main uploads the art
function UIKit.icon(parent: Instance, id: string?, p: BoxProps): ImageLabel?
	if not id or id == "" then
		return nil
	end
	local i = Instance.new("ImageLabel")
	i.Name = p.name or "Icon"
	i.Image = id
	i.ScaleType = Enum.ScaleType.Fit
	i.BackgroundTransparency = 1
	i.Size = p.size or UDim2.fromScale(1, 1)
	i.Position = p.pos or UDim2.fromScale(0.5, 0.5)
	i.AnchorPoint = p.anchor or Vector2.new(0.5, 0.5)
	i.Parent = parent
	return i
end

-- a picture you can press (the pack's close button): same press feel as the other buttons
function UIKit.iconButton(parent: Instance, id: string, p: BoxProps, onClick: (() -> ())?): ImageButton
	local b = Instance.new("ImageButton")
	b.Name = p.name or "IconButton"
	b.Image = id
	b.ScaleType = Enum.ScaleType.Fit
	b.BackgroundTransparency = 1
	b.AutoButtonColor = false
	b.Size = p.size or UDim2.fromScale(0.1, 0.1)
	b.Position = p.pos or UDim2.fromScale(0.5, 0.5)
	b.AnchorPoint = p.anchor or Vector2.new(0.5, 0.5)
	b.Parent = parent
	UIKit.press(b, onClick)
	return b
end

-- the one close button of every window and mini-game plate (wr-uidesign A⑥): a red round button INSIDE the plate with a
-- white ✕, 44x44 to press; p.pos / p.anchor place the 44 box (8 px in from the corner: pos (1,-30),(0,30) anchor 0.5)
function UIKit.closeButton(parent: Instance, p: BoxProps, onClick: (() -> ())?): TextButton
	local b = Instance.new("TextButton")
	b.Name = p.name or "Close"
	b.Text = ""
	b.AutoButtonColor = false
	b.BackgroundTransparency = 1
	b.Size = p.size or UDim2.fromOffset(44, 44)
	b.Position = p.pos or UDim2.fromScale(0.5, 0.5)
	b.AnchorPoint = p.anchor or Vector2.new(0.5, 0.5)
	local disc = Instance.new("Frame")
	disc.Name = "Disc"
	disc.AnchorPoint = Vector2.new(0.5, 0.5)
	disc.Position = UDim2.fromScale(0.5, 0.5)
	disc.Size = UDim2.fromOffset(30, 30)
	disc.BackgroundColor3 = Color3.fromRGB(226, 52, 44)
	disc.BorderSizePixel = 0
	disc.Active = false
	local dc = Instance.new("UICorner")
	dc.CornerRadius = UDim.new(1, 0)
	dc.Parent = disc
	local ds = Instance.new("UIStroke")
	ds.Color = Color3.fromRGB(95, 18, 16)
	ds.Thickness = 2.5
	ds.Parent = disc
	disc.Parent = b
	for i = 1, 2 do -- (the ✕: two white bars, so it needs no font)
		local bar = Instance.new("Frame")
		bar.Name = "Bar" .. i
		bar.AnchorPoint = Vector2.new(0.5, 0.5)
		bar.Position = UDim2.fromScale(0.5, 0.5)
		bar.Size = UDim2.fromOffset(17, 4)
		bar.Rotation = if i == 1 then 45 else -45
		bar.BackgroundColor3 = Color3.new(1, 1, 1)
		bar.BorderSizePixel = 0
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(1, 0)
		bc.Parent = bar
		bar.Parent = disc
	end
	b.Parent = parent
	UIKit.press(b, onClick)
	return b
end

-- press feel: hover 1.1x, press 0.9x, release springs back to 1x (touch has no hover)
function UIKit.press(b: GuiButton, onClick: (() -> ())?)
	local s = b:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = b
	local down = false
	local function to(v: number, t: number, style: Enum.EasingStyle?)
		TweenService:Create(s, TweenInfo.new(t, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = v }):Play()
	end
	b.InputBegan:Connect(function(input)
		if b:GetAttribute("Disabled") then
			return
		end
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement then
			if not down then
				to(A.Hover, A.HoverTime)
			end
		elseif t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			down = true
			to(A.Press, A.PressTime)
			local img = b:FindFirstChild("Skin") :: ImageLabel?
			if img and img:GetAttribute("Down") then
				img.Image = img:GetAttribute("Down")
			end
		end
	end)
	b.InputEnded:Connect(function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement then
			if not down then
				to(1, A.HoverTime)
			end
		elseif t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			if down then
				down = false
				to(1, A.ReleaseTime, Enum.EasingStyle.Elastic)
				local img = b:FindFirstChild("Skin") :: ImageLabel?
				if img and img:GetAttribute("Up") then
					img.Image = img:GetAttribute("Up")
				end
			end
		end
	end)
	b.Activated:Connect(function()
		if onClick and not b:GetAttribute("Disabled") then
			onClick()
		end
	end)
end

export type ButtonProps = {
	name: string?,
	text: string?,
	key: string?,
	args: { [string]: any }?,
	style: string?, -- UIStyle.Button key
	size: UDim2?,
	pos: UDim2?,
	anchor: Vector2?,
	max: number?,
	font: string?,
	z: number?,
	kitPrefix: string?, -- picture set: UIStyle.Kit[kitPrefix .. style] (tabs: "Tab")
	onClick: (() -> ())?,
}

-- a chunky button: a darker lip under a shaded face, white outlined text
function UIKit.button(parent: Instance, p: ButtonProps): TextButton
	local b = Instance.new("TextButton")
	b.Name = p.name or "Button"
	b.Text = ""
	b.AutoButtonColor = false
	b.Size = p.size or UDim2.fromScale(0.3, 0.1)
	b.Position = p.pos or UDim2.fromScale(0.5, 0.5)
	b.AnchorPoint = p.anchor or Vector2.new(0.5, 0.5)
	b.BorderSizePixel = 0
	if p.z then
		b.ZIndex = p.z
	end
	corner(b, 0.018)
	local face = Instance.new("Frame")
	face.Name = "Face"
	face.Size = UDim2.fromScale(1, 0.86)
	face.BorderSizePixel = 0
	face.ZIndex = b.ZIndex
	corner(face, 0.018)
	shade(face, 0.8)
	face.Parent = b
	local label = UIKit.text(face, {
		name = "Label",
		text = p.text,
		key = p.key,
		args = p.args,
		font = p.font or "Title",
		size = UDim2.fromScale(0.9, 0.74),
		max = p.max or 30,
		z = b.ZIndex,
	})
	label.TextColor3 = C.White
	-- (the kit picture, when the style has one: set by setButton)
	local img = Instance.new("ImageLabel")
	img.Name = "Skin"
	img.BackgroundTransparency = 1
	img.Size = UDim2.fromScale(1, 1)
	img.ZIndex = 0
	img.Visible = false
	img.Parent = b
	b:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local k = UIStyle.Kit[(b:GetAttribute("KitPrefix") or "") .. (b:GetAttribute("Style") or "")]
		if k and k.slice and img.Visible then
			local r, sl = k.rect, k.slice
			local margin = math.max(sl[1] - r[1], sl[2] - r[2])
			img.SliceScale = math.max((b.AbsoluteSize.Y / emuZoom) * margin / (r[4] - r[2]) / margin, 0.01)
		end
	end)
	b:SetAttribute("KitPrefix", p.kitPrefix)
	UIKit.setButton(b, p.text, p.style or "Green")
	b.Parent = parent
	UIKit.press(b, p.onClick)
	return b
end

-- one line's width in layout px at a text size (asks TextService: yields a moment); 0 when it can't tell
function UIKit.textWidth(text: string, font: Font, size: number): number
	if text == "" then
		return 0
	end
	local params = Instance.new("GetTextBoundsParams")
	params.Text = text
	params.Font = font
	params.Size = size
	params.Width = 100000
	local ok, bounds = pcall(TextService.GetTextBoundsAsync, TextService, params)
	return if ok then bounds.X else 0
end

-- a UIKit button as wide as its words (user 10-22: "the boxes should fit the words — now they're much too big for
-- them"): the words keep one size (`text` share of the height, at most `max` px), the button is the words plus `pad`
-- share of the height on each side (plus the lock while locked), at least `min` heights wide (default 1: square).
-- height() = the height now (the caller's rule — a thumb's size on a phone); without it the button keeps the height
-- its own Size gives it (a window's button) and only the width fits. Returns the re-fit function.
function UIKit.fitButton(b: GuiButton, p: { height: (() -> number)?, text: number?, pad: number?, max: number?, min: number?, maxW: number? }): () -> ()
	local face = b:FindFirstChild("Face") :: Frame
	local label = face:FindFirstChild("Label") :: TextLabel
	label.TextWrapped = false
	label.TextScaled = false -- (after TextWrapped)
	local function apply()
		local h = if p.height then p.height() else math.floor(b.AbsoluteSize.Y / emuZoom)
		if h <= 0 then
			return
		end
		label.TextSize = math.min(math.floor(h * (p.text or 0.5) + 0.5), p.max or math.huge)
		local pad = math.floor(h * (p.pad or 0.42))
		local words = math.ceil(label.TextBounds.X / emuZoom)
		local lock = face:FindFirstChild("Lock") :: GuiObject?
		local w
		if lock and lock.Visible then
			-- lock | words, from the left
			local lw = math.floor(h * 0.86 * 0.62)
			local gap = math.floor(h * 0.12)
			lock.AnchorPoint = Vector2.new(0, 0.5)
			lock.Position = UDim2.new(0, pad, 0.5, 0)
			label.Position = UDim2.new(0, pad + lw + gap + words / 2, 0.5, 0)
			w = pad + lw + gap + words + pad
		else
			label.Position = UDim2.fromScale(0.5, 0.5)
			w = words + 2 * pad
		end
		w = math.clamp(w, math.floor(h * (p.min or 1)), p.maxW or math.huge)
		if p.height then
			b.Size = UDim2.fromOffset(w, h)
		elseif b.Size.X.Scale ~= 0 or b.Size.X.Offset ~= w then
			b.Size = UDim2.new(0, w, b.Size.Y.Scale, b.Size.Y.Offset)
		end
	end
	label:GetPropertyChangedSignal("TextBounds"):Connect(apply)
	b:GetAttributeChangedSignal("Style"):Connect(function()
		task.defer(apply) -- (setLocked adds the lock after the style)
	end)
	if p.height then
		UIKit.bind(b, apply)
	else
		-- (its height follows its window: re-fit when that changes — a width change alone settles at once)
		local lastH = -1
		b:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if b.AbsoluteSize.Y ~= lastH then
				lastH = b.AbsoluteSize.Y
				apply()
			end
		end)
		task.defer(apply)
	end
	return apply
end

-- a button's height: a thumb's size on a touch screen (touch px), the words' size with a mouse
function UIKit.buttonH(touch: number): number
	return if UIKit.keyboard() then UIKit.px(0.085, 34, 44) else touch
end

-- recolour / retext a UIKit button; disabled = no press feel, no click
function UIKit.setButton(b: GuiButton, text: string?, style: string?, disabled: boolean?)
	local face = b:FindFirstChild("Face") :: Frame?
	local set = UIStyle.Button[style or "Green"] or UIStyle.Button.Green
	b.BackgroundColor3 = set[2]
	if face then
		face.BackgroundColor3 = set[1]
		local label = face:FindFirstChild("Label") :: TextLabel?
		if label and text then
			UIKit.setText(label, nil) -- plain text now: its screen re-sets it on a language change
			label.Text = text
		end
	end
	b:SetAttribute("Disabled", disabled == true)
	b:SetAttribute("Style", style or "Green")
	-- (a lock from UIKit.setLocked goes away: the words take the whole face again)
	local lock = face and face:FindFirstChild("Lock") :: GuiObject?
	if lock and lock.Visible then
		lock.Visible = false
		local label = (face :: Frame):FindFirstChild("Label") :: TextLabel?
		if label then
			label.Position = UDim2.fromScale(0.5, 0.5)
			label.Size = UDim2.fromScale(0.9, 0.74)
		end
	end
	-- the kit picture for this style, else the code colours
	local img = b:FindFirstChild("Skin") :: ImageLabel?
	local k = UIStyle.Kit[(b:GetAttribute("KitPrefix") or "") .. (style or "Green")]
	local pictured = img ~= nil and k ~= nil and k.id ~= ""
	if img then
		img.Visible = pictured
		if pictured then
			local r = k.rect
			img.Image = k.id
			img:SetAttribute("Up", k.id)
			img:SetAttribute("Down", k.pressed)
			img.ImageRectOffset = Vector2.new(r[1], r[2])
			img.ImageRectSize = Vector2.new(r[3] - r[1], r[4] - r[2])
			if k.slice then
				local sl = k.slice
				img.ScaleType = Enum.ScaleType.Slice
				img.SliceCenter = Rect.new(sl[1] - r[1], sl[2] - r[2], sl[3] - r[1], sl[4] - r[2])
				local margin = math.max(sl[1] - r[1], sl[2] - r[2])
				img.SliceScale = math.max((b.AbsoluteSize.Y / emuZoom) * margin / (r[4] - r[2]) / margin, 0.01)
			end
			img.ImageTransparency = if disabled then 0.35 else 0
		end
	end
	-- (locked / owned: faded so it doesn't read as something to press)
	b.BackgroundTransparency = if pictured then 1 elseif disabled then 0.35 else 0
	if face then
		face.BackgroundTransparency = b.BackgroundTransparency
		local label = face:FindFirstChild("Label") :: TextLabel?
		local stroke = label and label:FindFirstChildOfClass("UIStroke")
		if label and stroke then
			label.TextTransparency = if disabled then 0.3 else 0
			stroke.Transparency = label.TextTransparency
		end
	end
end

-- the one "can't yet" look (docs/research/tutorial_taps_1021.md B-1): the button itself, grey and faded, with the
-- lock in front of its words ("Lv 3", "Need a free bay"); it doesn't press. UIKit.setButton undoes it.
function UIKit.setLocked(b: GuiButton, key: string, args: { [string]: any }?)
	UIKit.setButton(b, nil, "Gray", true)
	local face = b:FindFirstChild("Face") :: Frame?
	local label = face and face:FindFirstChild("Label") :: TextLabel?
	if not face or not label then
		return
	end
	UIKit.setText(label, key, args)
	local lock = face:FindFirstChild("Lock") :: GuiObject?
	if not lock then
		lock = UIKit.icon(face, UIStyle.Icon.Lock, { name = "Lock", anchor = Vector2.new(0, 0.5), pos = UDim2.fromScale(0.07, 0.5), size = UDim2.fromScale(0.62, 0.62) })
		if lock then
			lock.ZIndex = b.ZIndex
			local sq = Instance.new("UIAspectRatioConstraint")
			sq.DominantAxis = Enum.DominantAxis.Height
			sq.Parent = lock
		end
	end
	if lock then
		lock.Visible = true
		label.Position = UDim2.fromScale(0.6, 0.5)
		label.Size = UDim2.fromScale(0.68, 0.74)
	end
end

export type Tabs = { select: (id: string) -> (), frame: Frame, selected: () -> string? }

-- a row of tabs (selected = blue); sizes come from the text and the touch area, not the concept picture
function UIKit.tabs(parent: Instance, items: { { id: string, key: string } }, p: BoxProps, onSelect: (string) -> ()): Tabs
	local f = Instance.new("Frame")
	f.Name = p.name or "Tabs"
	f.Size = p.size or UDim2.fromScale(1, 0.12)
	f.Position = p.pos or UDim2.fromScale(0.5, 0)
	f.AnchorPoint = p.anchor or Vector2.new(0.5, 0)
	f.BackgroundTransparency = 1
	f.Parent = parent
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0.012, 0)
	list.Parent = f
	local n = #items
	local w = (1 - 0.012 * (n - 1)) / n
	local buttons: { [string]: TextButton } = {}
	local current: string? = nil
	local function select(id: string)
		current = id
		for bid, b in buttons do
			UIKit.setButton(b, nil, if bid == id then "Blue" else "Gray")
			-- the others sit lower and shorter, so they don't weigh as much as the window's real buttons (GPT, kitB_r1)
			b.Size = UDim2.fromScale(w, if bid == id then 1 else 0.82)
		end
	end
	for i, it in items do
		local b = UIKit.button(f, {
			name = it.id,
			key = it.key,
			style = "Gray",
			size = UDim2.fromScale(w, 0.82),
			kitPrefix = "Tab",
			max = 26,
			onClick = function()
				select(it.id)
				onSelect(it.id)
			end,
		})
		b.LayoutOrder = i
		buttons[it.id] = b
	end
	-- one text size for every tab: the biggest that fits the longest word (each tab scaling its own looks uneven).
	-- Measured from the row, not the tabs (their hover scale would change it)
	local token = 0
	local function fitText()
		token += 1
		local my = token
		task.defer(function()
			local w = f.AbsoluteSize.X / emuZoom * ((1 - 0.012 * (n - 1)) / n) * 0.9 * 0.9
			local h = f.AbsoluteSize.Y / emuZoom * 0.86 * 0.74
			local best = 26
			for _, b in buttons do
				local label = (b :: any).Face.Label :: TextLabel
				local params = Instance.new("GetTextBoundsParams")
				params.Text = label.Text
				params.Font = label.FontFace
				params.Size = 100
				params.Width = 100000
				local ok, bounds = pcall(TextService.GetTextBoundsAsync, TextService, params)
				if ok and bounds.X > 0 then
					best = math.min(best, math.floor(100 * math.min(w / bounds.X, h / bounds.Y)))
				end
			end
			if my ~= token then
				return
			end
			for _, b in buttons do
				local label = (b :: any).Face.Label :: TextLabel
				label.TextScaled = false
				label.TextSize = math.max(best, 8)
			end
		end)
	end
	f:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitText)
	langChanged.Event:Connect(fitText)
	fitText()
	return {
		select = select,
		frame = f,
		selected = function()
			return current
		end,
	}
end

export type Window = { root: CanvasGroup, body: Frame, title: TextLabel, close: GuiButton }

-- the red metal window: title + X on top, the hazard stripe, a steel panel for the content (body).
-- Hidden at first; UIKit.open / UIKit.close fade + slide it. title = a Locale key.
-- overHotbar: the window may come down over the tool bar (Settings: nothing to hold while you change it — GPT
-- settings_sound r1: on a phone the sound rows must all show)
function UIKit.window(parent: Instance, p: { name: string, title: string, aspect: number?, maxSize: Vector2?, overHotbar: boolean?, onClose: () -> () }): Window
	local w = Instance.new("CanvasGroup")
	w.Name = p.name
	w:SetAttribute("IsWindow", true)
	w.AnchorPoint = Vector2.new(0.5, 0.5)
	w.BackgroundTransparency = 1
	w.GroupTransparency = 1
	w.ZIndex = 5 -- over the job card
	w.Visible = false
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.AspectType = Enum.AspectType.FitWithinMaxSize
	ratio.Parent = w
	-- the room between the money bar and the tool bar (both stay in view); wider on short (phone) screens so
	-- rows keep their touch size
	UIKit.bind(w, function(size)
		local top = math.max(0, UIKit.barHeight() + 4 - UIKit.topInset()) + 6
		local bottom = if p.overHotbar then 10 else UIKit.hotbarHeight() + UIKit.hotbarGap() + 10
		local h = math.max(size.Y - top - bottom, 100)
		ratio.AspectRatio = if size.Y < 500 then 1.8 else p.aspect or 1.42
		w.Size = UDim2.new(0.9, 0, 0, h)
		local home = UDim2.new(0.5, 0, 0, top + h / 2)
		w:SetAttribute("Home", home)
		w.Position = home
	end)
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = p.maxSize or Vector2.new(820, 580)
	windowClose[w] = p.onClose
	limit.Parent = w

	-- the frame sits inside the group by its edge width (a CanvasGroup cuts anything outside it)
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.BackgroundColor3 = C.Red
	frame.BorderSizePixel = 0
	corner(frame, 0.03)
	local rim = edge(frame, C.RedDark, 0.008)
	shade(frame, 0.78)
	UIKit.bind(frame, function()
		local t = rim.Thickness
		frame.Size = UDim2.new(1, -2 * t, 1, -2 * t)
	end)
	frame.Parent = w
	local framed = UIKit.skin(frame, "window", function(size)
		return math.clamp(math.min(size.X, size.Y) * 0.09, 14, 30)
	end)
	if not framed then
		UIKit.bolts(frame)
	end

	local title = UIKit.text(frame, {
		name = "Title",
		key = p.title,
		font = "Title",
		size = UDim2.fromScale(0.72, 0.105),
		pos = UDim2.fromScale(0.5, 0.085),
		max = 44,
	})
	-- close: the one red round button inside the plate with a white ✕ (UIKit.closeButton, wr-uidesign A⑥), 44 to press
	local close: GuiButton = UIKit.closeButton(frame, {
		name = "Close",
		pos = UDim2.new(1, -30, 0.085, 0),
	}, p.onClose)
	local band = UIKit.hazard(frame, { pos = UDim2.fromScale(0.5, 0.165), size = UDim2.new(1, 0, 0.032, 0) })
	-- the title sits in the middle of the grey head: between the frame's inner top edge and the yellow-black stripe,
	-- the same room above and below (user 10-22: it touched the red top). The inner edge is the frame picture's
	-- corner size (px, clamped 14..30) x 0.63; the stripe's top is 14.9% down — measured on the settings window.
	local function seatTitle()
		local s = frame.AbsoluteSize / emuZoom
		if s.Y < 1 then
			return
		end
		local cornerPx = math.clamp(math.min(s.X, s.Y) * 0.09, 14, 30)
		local top = cornerPx * 0.63
		local stripeTop = s.Y * 0.149
		title.Position = UDim2.new(0.5, 0, 0, math.floor((top + stripeTop) / 2 + 0.5))
		title.Size = UDim2.new(0.72, 0, 0, math.max(math.floor((stripeTop - top) * 0.9), 12))
	end
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(seatTitle)
	seatTitle()
	local body = UIKit.steel(frame, {
		name = "Body",
		pos = UDim2.fromScale(0.5, 0.215),
		anchor = Vector2.new(0.5, 0),
		size = UDim2.fromScale(0.935, 0.745),
	})
	if framed then
		-- the picture is already steel inside: the body is just the content's area, the band stays inside the rim
		body.BackgroundTransparency = 1
		for _, c in body:GetChildren() do
			if c:IsA("UIStroke") then
				c.Enabled = false
			end
		end
		band.Size = UDim2.new(0.935, 0, 0.032, 0)
	end
	w.Parent = parent
	return { root = w, body = body, title = title, close = close }
end

local openToken: { [Instance]: number } = {}
-- the windows open now: the HUD's "WindowOpen" attribute says if any is, so things behind (the tutorial strip) can
-- step back
local openWindows: { [Instance]: true } = {}
local function markOpen(w: GuiObject, on: boolean)
	if not w:GetAttribute("IsWindow") then
		return
	end
	openWindows[w] = if on then true else nil
	if root then
		root:SetAttribute("WindowOpen", next(openWindows) ~= nil)
	end
end

-- fade + short slide up (0.2 s); any GuiObject (a CanvasGroup also fades)
function UIKit.open(w: GuiObject)
	-- the settlement card is on screen: a window the player asks for waits (one thing at a time — wr-play test 3); it
	-- can be asked again once Nice! is tapped
	if root and w.Name ~= "PayCard" and w:GetAttribute("IsWindow") and root:FindFirstChild("PayCard", true) then
		return
	end
	local home = (w:GetAttribute("Home") :: UDim2?) or w.Position
	w:SetAttribute("Home", home)
	openToken[w] = (openToken[w] or 0) + 1
	for _, d in w:GetDescendants() do
		if d:IsA("UIScale") and d.Parent and d.Parent:IsA("GuiButton") then
			d.Scale = 1 -- a press left half-way when it last closed
		end
	end
	w.Position = home + UDim2.fromScale(0, A.Slide)
	w.Visible = true
	markOpen(w, true)
	local goal: { [string]: any } = { Position = home }
	if w:IsA("CanvasGroup") then
		w.GroupTransparency = 1
		goal.GroupTransparency = 0
	end
	TweenService:Create(w, TweenInfo.new(A.OpenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

function UIKit.close(w: GuiObject)
	if not w.Visible then
		return
	end
	local home = (w:GetAttribute("Home") :: UDim2?) or w.Position
	openToken[w] = (openToken[w] or 0) + 1
	local my = openToken[w]
	markOpen(w, false)
	local goal: { [string]: any } = { Position = home + UDim2.fromScale(0, A.Slide) }
	if w:IsA("CanvasGroup") then
		goal.GroupTransparency = 1
	end
	TweenService:Create(w, TweenInfo.new(A.OpenTime * 0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), goal):Play()
	task.delay(A.OpenTime * 0.75, function()
		if openToken[w] == my then
			w.Visible = false
			w.Position = home
		end
	end)
end

-- a card that must be seen now (the settlement) takes the screen: every window that is open (settings, shops ...) is
-- closed first, each the way its own X closes it — one thing at a time (wr-play test 3: settings + name window + card)
function UIKit.closeOthers(except: Instance?)
	for w in openWindows do
		if w ~= except and w.Parent then
			local fn = windowClose[w]
			if fn then
				fn()
			else
				UIKit.close(w :: GuiObject)
			end
		end
	end
end

-- pop in from small (banners, level-up)
function UIKit.pop(g: GuiObject, from: number?)
	local s = g:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = g
	s.Scale = from or 0.4
	TweenService:Create(s, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

-- a few small four-point sparkles twinkling around a card or pill ("Perfect!" moments, wr-ui 10-22: the 2D side; the 3D
-- sparkle in the world is wr-vfx's). `around` must be anchored in its centre and placed with an offset UDim2 (its
-- parent holds the stars, drawn over it); each star pops in, turns a quarter and goes, staggered, then removes itself
function UIKit.sparkles(around: GuiObject, count: number?, tint: Color3?)
	local parent = around.Parent
	if not parent then
		return
	end
	local n = count or 6
	local w, h = around.Size.X.Offset, around.Size.Y.Offset -- (its set size: not mid-pop)
	local c = around.Position
	for i = 1, n do
		local a = (i / n) * math.pi * 2 + 0.5
		local rx, ry = w / 2 * (1 + 0.08 * (i % 3)), h / 2 * (1.1 + 0.12 * (i % 2))
		local d = 28 + (i * 7) % 15
		local star = Instance.new("Frame")
		star.Name = "Sparkle"
		star.AnchorPoint = Vector2.new(0.5, 0.5)
		star.BackgroundTransparency = 1
		star.Size = UDim2.fromOffset(d, d)
		star.Position = UDim2.new(c.X.Scale, c.X.Offset + math.cos(a) * rx, c.Y.Scale, c.Y.Offset + math.sin(a) * ry)
		star.ZIndex = around.ZIndex + 3
		-- (a twinkle: a long cross with a shorter one turned 45 degrees across it, thin sharp rays — gold over a slightly
		-- bigger dark orange copy, its edge: the colour of wr-vfx's 3D Perfect stars, so 2D and 3D read as one sparkle)
		for _, look in { { 0.12, Color3.fromRGB(196, 96, 18), 0 }, { 0, tint or Color3.fromRGB(255, 226, 70), 1 } } do
			for _, ray in { { 0.2, 1, 0 }, { 1, 0.2, 0 }, { 0.14, 0.66, 45 }, { 0.66, 0.14, 45 } } do
				local f = Instance.new("Frame")
				f.AnchorPoint = Vector2.new(0.5, 0.5)
				f.Position = UDim2.fromScale(0.5, 0.5)
				f.Size = UDim2.fromScale(ray[1] + look[1], ray[2] + look[1]) -- (the edge copy: a little thicker all round)
				f.Rotation = ray[3]
				f.BackgroundColor3 = look[2]
				f.BorderSizePixel = 0
				f.ZIndex = star.ZIndex + look[3]
				local fc = Instance.new("UICorner")
				fc.CornerRadius = UDim.new(0, 2)
				fc.Parent = f
				f.Parent = star
			end
		end
		local sc = Instance.new("UIScale")
		sc.Scale = 0
		sc.Parent = star
		star.Rotation = -20
		star.Parent = parent
		task.delay(0.08 * (i - 1), function()
			TweenService:Create(sc, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			TweenService:Create(star, TweenInfo.new(0.7, Enum.EasingStyle.Sine), { Rotation = 70 }):Play()
			task.delay(0.4, function()
				local out = TweenService:Create(sc, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
				out:Play()
				out.Completed:Wait()
				star:Destroy()
			end)
		end)
	end
end

-- phone check in Studio (see the top): a device frame with the safe area, top bar, stick and jump button
local function circle(parent: Instance, d: number, pos: UDim2, color: Color3, t: number)
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(d, d)
	f.Position = pos
	f.BackgroundColor3 = color
	f.BackgroundTransparency = t
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = f
	f.Parent = parent
	return f
end

local function setEmu()
	local g = root :: ScreenGui
	local want = g:GetAttribute("EmuSize") :: Vector2?
	local device = g:FindFirstChild("EmuDevice")
	if emu and device then
		for _, c in emu:GetChildren() do
			c.Parent = g
		end
		device:Destroy()
		emu = nil
		emuZoom = 1
	end
	if typeof(want) == "Vector2" then
		local inset = (g:GetAttribute("EmuInset") :: number?) or 36
		local d = Instance.new("Frame")
		d.Name = "EmuDevice"
		d.AnchorPoint = Vector2.new(0.5, 0.5)
		d.Position = UDim2.fromScale(0.5, 0.5)
		d.Size = UDim2.fromOffset(want.X, want.Y)
		d.BackgroundTransparency = 1
		d.ZIndex = 0
		local s = Instance.new("UIStroke")
		s.Color = Color3.new(1, 0, 1)
		s.Thickness = 2
		s.Parent = d
		local band = Instance.new("Frame")
		band.Size = UDim2.new(1, 0, 0, inset)
		band.BackgroundColor3 = Color3.new(0, 0, 0)
		band.BackgroundTransparency = 0.6
		band.Parent = d
		circle(band, inset * 0.8, UDim2.new(0, inset * 0.6, 0.5, 0), Color3.new(1, 1, 1), 0.5) -- Roblox menu
		circle(band, inset * 0.8, UDim2.new(0, inset * 1.5, 0.5, 0), Color3.new(1, 1, 1), 0.5) -- chat
		local small = math.min(want.X, want.Y) <= 500
		local jump = if small then 70 else 120
		local stick = circle(d, if small then 90 else 140, UDim2.new(0, if small then 95 else 150, 1, if small then -85 else -140), Color3.new(1, 1, 1), 0.7)
		local jumpButton = circle(d, jump, UDim2.new(1, if small then -60 else -105, 1, if small then -55 else -95), Color3.new(1, 1, 1), 0.7)
		-- (gone with the real ones: the work view and the scenes turn the touch controls off)
		local GuiService = game:GetService("GuiService")
		local function touchShown()
			stick.Visible = GuiService.TouchControlsEnabled
			jumpButton.Visible = GuiService.TouchControlsEnabled
		end
		touchShown()
		GuiService:GetPropertyChangedSignal("TouchControlsEnabled"):Connect(touchShown)
		local e = Instance.new("Frame")
		e.Name = "EmuSafe"
		e.Position = UDim2.fromOffset(0, inset)
		e.Size = UDim2.new(1, 0, 1, -inset)
		e.BackgroundTransparency = 1
		e.Parent = d
		-- shrunk evenly to fit a small Studio window (UIKit.size undoes it for the layout)
		local room = g.AbsoluteSize
		emuZoom = math.min(1, (room.X - 8) / want.X, (room.Y - 8) / want.Y)
		local z = Instance.new("UIScale")
		z.Scale = emuZoom
		z.Parent = d
		d.Parent = g
		for _, c in g:GetChildren() do
			if c ~= d then
				c.Parent = e
			end
		end
		emu = e
	end
	resized:Fire(UIKit.size())
end

-- the HUD ScreenGui every screen lives in
function UIKit.setRoot(g: ScreenGui)
	root = g
	local fontLang = Localizer.lang
	Localizer.Changed.Event:Connect(function()
		-- (every label's font follows the language: Korean uses BuilderSans for digits / English too)
		if fontLang ~= Localizer.lang then
			for _, d in g:GetDescendants() do
				if d:IsA("TextLabel") or d:IsA("TextButton") then
					local f = UIStyle.refont(d.FontFace, fontLang, Localizer.lang)
					if f then
						d.FontFace = f
					end
				end
			end
			fontLang = Localizer.lang
		end
		relabel(g)
		langChanged:Fire()
	end)
	g:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		resized:Fire(UIKit.size())
	end)
	game:GetService("GuiService"):GetPropertyChangedSignal("TopbarInset"):Connect(function()
		resized:Fire(UIKit.size())
	end)
	g:GetAttributeChangedSignal("EmuSize"):Connect(setEmu)
	g:GetAttributeChangedSignal("EmuInset"):Connect(setEmu)
	g.ChildAdded:Connect(function(c)
		local e = emu
		if e and c.Name ~= "EmuDevice" then
			task.defer(function()
				-- (still emulating: switching it off moves everything back to g and must not be undone here)
				if c.Parent == g and emu == e then
					c.Parent = e
				end
			end)
		end
	end)
end

return UIKit
