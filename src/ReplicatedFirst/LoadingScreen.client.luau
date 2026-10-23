-- The loading screen (user 10-21: "게임 열면 리소스 다운로드 하게"): the first thing a player sees. v2 (user 10-21:
-- "이런 식으로 간단하게 ... 팁 빼구"): one garage-blue colour over the whole screen, a small nut / dot pattern, dark
-- silhouettes along the edges (tools hanging from a rail on top, tyres / car / tool cart on the floor), the logo in
-- the middle, one turning lug nut and "Loading..." with a small percent. The percent comes from
-- ContentProvider:PreloadAsync (the list: ReplicatedStorage.Shared.Preload.list(), wr-dev); shows 100% for a moment and
-- fades away once the game is loaded — no Skip button (user 10-21: "건너뛰기 없이 다 받으면 100% 되고 자동으로").
-- Runs before anything else is here, so it needs no other module: colours, fonts and words live in this file.
-- Decision: notes/gpt/wr-ui/loading_v2_decision.md

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local started = os.clock()
local player = Players.LocalPlayer
-- the language (user 10-22: the loading screen differs in English / Korean): the saved choice if it's here already
-- (player attribute Lang, set when the player's data loads), else the Roblox language (ko-kr -> ko, others en — the
-- same rule as Localizer). A saved choice arriving while this shows switches it at once. (Roblox keeps nothing on the
-- device between visits, so the very first frame of a visit always follows the Roblox language.)
local function langNow(): string
	local saved = player:GetAttribute("Lang")
	if saved == "en" or saved == "ko" then
		return saved
	end
	return if (player.LocaleId or ""):sub(1, 2) == "ko" then "ko" else "en"
end
local lang = langNow()

local GIVE_UP = 30 -- seconds: never stuck — after this it reaches 100% and the game opens anyway (nothing shown)

-- wr-art's pictures (art/ui/loading_v2/, transparent, no words); "" = left out (the plain colour and the words stay)
local ART = {
	pattern = "rbxassetid://89043560912173", -- pattern_tile.png: light nuts and dots, tiled
	top = "rbxassetid://135309756868938", -- silhouette_top.png: tools hanging from a rail (2172 × 724, tiled sideways)
	bottom = "rbxassetid://127993333692199", -- silhouette_bottom.png: tyres, tool cart, car, jack on a floor line (2172 × 724, tiled sideways)
	spinner = "rbxassetid://92413434154455", -- spinner_nut.png: the lug nut that turns
}
-- the game's name: "Wrench & Ride : Garage Tycoon", in Korean "렌치 & 라이드 : 정비소 타이쿤" (user 10-22)
local NAME, SUBNAME = "Wrench & Ride", "Garage Tycoon"
-- wr-art's logos per language; an empty one uses the English logo (no error while the Korean one isn't uploaded)
local LOGO = {
	en = { id = "rbxassetid://93670065897289", shape = 2012 / 782 }, -- art/ui/brand/logo.png
	ko = { id = "", shape = 2022 / 778 }, -- art/ui/brand/logo_ko.png (wr-art 10-22): main uploads -> the id here
}
local TEXT = {
	en = { loading = "Loading" },
	ko = { loading = "불러오는 중" },
}
local words = TEXT[lang]
local function logoFor(l: string): { id: string, shape: number? }
	return if LOGO[l] and LOGO[l].id ~= "" then LOGO[l] else LOGO.en
end

local rgb = Color3.fromRGB
local TITLE = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Bold)
local BLUE, YELLOW, INK = rgb(52, 116, 210), rgb(250, 200, 30), rgb(16, 30, 64)

local gui = Instance.new("ScreenGui")
gui.Name = "Loading"
gui.IgnoreGuiInset = true
gui.ScreenInsets = Enum.ScreenInsets.None -- the whole screen, notch corners too: nothing of the game shows around it
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000 -- over every other screen
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- everything sits in one group so it fades out as one piece
local root = Instance.new("CanvasGroup")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = BLUE
root.BackgroundTransparency = 0
root.BorderSizePixel = 0
root.Parent = gui

-- a picture repeated over a box; tile(screen size) = the size of one copy
local function tiled(name: string, id: string, pos: UDim2, anchorY: number, size: UDim2, tile: (Vector2) -> Vector2, rect: Rect?): ImageLabel?
	if id == "" then
		return nil
	end
	local i = Instance.new("ImageLabel")
	i.Name = name
	i.Image = id
	i.BackgroundTransparency = 1
	i.ScaleType = Enum.ScaleType.Tile
	if rect then -- (the picture's own clear margin cut off: the copies meet with no gap — wr-play: a seam in the rail)
		i.ImageRectOffset = rect.Min
		i.ImageRectSize = rect.Max - rect.Min
	end
	i.AnchorPoint = Vector2.new(0, anchorY)
	i.Position = pos
	i.Size = size
	i.Parent = root
	local function fit()
		-- (sizes undo the Studio phone check's shrink, if any)
		local zoom = root:FindFirstChildOfClass("UIScale")
		local z = if zoom then zoom.Scale else 1
		local t = tile(root.AbsoluteSize / z)
		i.TileSize = UDim2.fromOffset(math.max(t.X, 1), math.max(t.Y, 1))
	end
	root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()
	return i
end
local TOP_H, BOTTOM_H = 0.26, 0.28 -- the edge bands, share of the screen height
local pattern = tiled("Pattern", ART.pattern, UDim2.fromScale(0, 0), 0, UDim2.fromScale(1, 1), function(sz)
	local t = sz.Y * 0.5
	return Vector2.new(t, t)
end)
if pattern then
	pattern.ImageTransparency = 0.3 -- (quiet, so the logo stands out)
end
-- (silhouette_top.png: its rail runs x 9..2161 — 10 px of nothing at each side made a gap where the copies met)
tiled("Top", ART.top, UDim2.fromScale(0, 0), 0, UDim2.fromScale(1, TOP_H), function(sz)
	local h = sz.Y * TOP_H
	return Vector2.new(h * 2150 / 724, h)
end, Rect.new(11, 0, 2161, 724))
tiled("Bottom", ART.bottom, UDim2.fromScale(0, 1), 1, UDim2.fromScale(1, BOTTOM_H), function(sz)
	local h = sz.Y * BOTTOM_H
	return Vector2.new(h * 2172 / 724, h)
end)

local function text(name: string, t: string, pos: UDim2, size: UDim2, max: number, outline: number): TextLabel
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Text = t
	l.FontFace = TITLE
	l.TextColor3 = Color3.new(1, 1, 1)
	l.BackgroundTransparency = 1
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Position = pos
	l.Size = size
	l.TextWrapped = true
	l.TextScaled = true -- (after TextWrapped)
	local cap = Instance.new("UITextSizeConstraint")
	cap.MaxTextSize = max
	cap.Parent = l
	local st = Instance.new("UIStroke")
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	st.LineJoinMode = Enum.LineJoinMode.Round
	st.Color = INK
	st.Thickness = outline
	st.Parent = l
	l.Parent = root
	return l
end

-- the logo in the middle (it keeps its own shape inside this box)
local logo: ImageLabel? = nil
local shape: UIAspectRatioConstraint? = nil
local function setLogo()
	local l = logoFor(lang)
	if logo and shape then
		logo.Image = l.id
		shape.Parent = if l.shape then logo else nil -- (no known shape: Fit alone keeps the picture's own)
		shape.AspectRatio = l.shape or 1
	end
end
if LOGO.en.id ~= "" then
	local lg = Instance.new("ImageLabel")
	lg.Name = "Logo"
	lg.ScaleType = Enum.ScaleType.Fit
	lg.BackgroundTransparency = 1
	lg.AnchorPoint = Vector2.new(0.5, 0.5)
	lg.Position = UDim2.fromScale(0.5, 0.42)
	lg.Size = UDim2.fromScale(0.52, 0.3) -- (clear of the hanging tools, GPT loading_v2_r1)
	local sh = Instance.new("UIAspectRatioConstraint")
	sh.AspectType = Enum.AspectType.FitWithinMaxSize
	lg.Parent = root
	logo, shape = lg, sh
	setLogo()
else
	text("Title", NAME, UDim2.fromScale(0.5, 0.36), UDim2.fromScale(0.8, 0.17), 96, 3)
	local sub = text("Sub", SUBNAME, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.5, 0.07), 40, 2)
	sub.TextColor3 = YELLOW
end

-- the turning nut, then "Loading..." (the dots move) and the percent in one line under it
local spinner: ImageLabel? = nil
if ART.spinner ~= "" then
	local sp = Instance.new("ImageLabel")
	sp.Name = "Spinner"
	sp.Image = ART.spinner
	sp.ScaleType = Enum.ScaleType.Fit
	sp.BackgroundTransparency = 1
	sp.AnchorPoint = Vector2.new(0.5, 0.5)
	sp.Position = UDim2.fromScale(0.5, 0.635)
	sp.Size = UDim2.fromScale(0.13, 0.13)
	sp.SizeConstraint = Enum.SizeConstraint.RelativeYY
	sp.Parent = root
	spinner = sp
end
local line = text("Loading", words.loading, UDim2.fromScale(0.5, 0.745), UDim2.fromScale(0.6, 0.06), 30, 2)
line.RichText = true
-- the progress bar under the words (wr-play: a number alone read as "is it moving?"): dark rounded track, yellow fill
local track = Instance.new("Frame")
track.Name = "Bar"
track.AnchorPoint = Vector2.new(0.5, 0.5)
track.Position = UDim2.fromScale(0.5, 0.8)
track.Size = UDim2.fromScale(0.34, 0.045) -- (about 18 px tall on a phone: GPT loading_bar r1 — 0.032 looked thin over the pattern)
track.BackgroundColor3 = INK
track.BackgroundTransparency = 0.25
track.BorderSizePixel = 0
local tcorner = Instance.new("UICorner")
tcorner.CornerRadius = UDim.new(1, 0)
tcorner.Parent = track
local tstroke = Instance.new("UIStroke")
tstroke.Color = Color3.new(1, 1, 1)
tstroke.Thickness = 2
tstroke.Transparency = 0.2
tstroke.Parent = track
local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.BackgroundColor3 = YELLOW
fill.BorderSizePixel = 0
fill.Size = UDim2.fromScale(0.02, 1)
local fcorner = Instance.new("UICorner")
fcorner.CornerRadius = UDim.new(1, 0)
fcorner.Parent = fill
fill.Parent = track
track.Parent = root

-- Studio check only: HoldForTest keeps it up, EmuSize (Vector2) shows it at a phone size (shrunk to fit)
local testing = RunService:IsStudio()
local function emulate()
	local want = gui:GetAttribute("EmuSize")
	local zoom = root:FindFirstChildOfClass("UIScale")
	if typeof(want) == "Vector2" then
		root.Size = UDim2.fromOffset(want.X, want.Y)
		local room = gui.AbsoluteSize
		zoom = zoom or Instance.new("UIScale")
		zoom.Scale = math.min(1, (room.X - 8) / want.X, (room.Y - 8) / want.Y)
		zoom.Parent = root
	else
		root.Size = UDim2.fromScale(1, 1)
		if zoom then
			zoom:Destroy()
		end
	end
end
if testing then
	gui:GetAttributeChangedSignal("EmuSize"):Connect(emulate)
end

-- the pictures wait unseen until they're all here, then come in together (test 2 ⑩: they popped in one by one over
-- the first second) — the blue and the "Loading" line show at once
local own: { ImageLabel } = {}
local look: { [ImageLabel]: number } = {}
for _, d in root:GetDescendants() do
	if d:IsA("ImageLabel") and d.Image ~= "" then
		table.insert(own, d)
		look[d] = d.ImageTransparency
		d.ImageTransparency = 1
	end
end
local artIn = false
local function showArt()
	if artIn then
		return
	end
	artIn = true
	for d, t in look do
		if d.Parent then
			TweenService:Create(d, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { ImageTransparency = t }):Play()
		end
	end
end
task.delay(2.5, showArt) -- (never waits longer than this for them)

gui.Parent = player:WaitForChild("PlayerGui")

-------------------------------------------------------------------------------------------------- the work

local done, total, failed = 0, 0, 0
local preloadDone = false
local leaving = false

local shown, dots = 0, 0
local function draw()
	-- (the dots keep their room, so the line doesn't wobble)
	-- (all three dots always there, the ones not reached yet dim: the line keeps its width and doesn't wobble)
	-- (Korean: one "…" like every other Korean line — the 2nd Korean pass made it the one ellipsis; main 10-23)
	local d = if lang == "ko" then "…" else string.rep(".", dots) .. '<font transparency="0.7">' .. string.rep(".", 3 - dots) .. "</font>"
	line.Text = words.loading .. d .. "  " .. math.floor(shown * 100 + 0.5) .. "%"
	fill.Size = UDim2.fromScale(math.clamp(shown, 0.02, 1), 1)
end
local function show(share: number)
	shown = math.max(shown, math.clamp(share, 0, 1)) -- (never goes back)
	draw()
end
draw()

-- the saved language came while this shows: follow it (and nothing once it's gone — wr-gamer all1: a language
-- arriving after the screen left touched the destroyed logo)
local langConn: RBXScriptConnection? = nil
langConn = player:GetAttributeChangedSignal("Lang"):Connect(function()
	if not gui.Parent then
		if langConn then
			langConn:Disconnect()
		end
		return
	end
	if langNow() ~= lang then
		lang = langNow()
		words = TEXT[lang]
		setLogo()
		draw()
	end
end)

-- the nut turns and the dots move until it's gone
RunService.RenderStepped:Connect(function(dt)
	if spinner then
		spinner.Rotation = (spinner.Rotation + dt * 240) % 360
	end
end)
task.spawn(function()
	while gui.Parent do
		task.wait(0.35)
		dots = (dots + 1) % 4
		draw()
	end
end)

local function leave(why: string)
	if leaving then
		return
	end
	leaving = true
	show(1)
	print(string.format("[Loading] %s after %.1f s (%d / %d assets, %d failed)", why, os.clock() - started, done, total, failed))
	task.wait(0.4) -- (100% shows for a moment before it goes)
	TweenService:Create(root, TweenInfo.new(0.45, Enum.EasingStyle.Quad), { GroupTransparency = 1 }):Play()
	task.wait(0.5)
	if langConn then
		langConn:Disconnect()
	end
	gui:Destroy()
end

-- the list to fetch first (wr-dev): Shared.Preload.list() -> { Instance | content id }. Missing: just wait for the game
task.spawn(function()
	-- this screen's own pictures go first (wr-gamer all1: a first visit showed the bare pattern for a few seconds while
	-- the game's list filled the queue) — as instances, not id strings (strings fail here)
	pcall(ContentProvider.PreloadAsync, ContentProvider, own)
	showArt()
	local shared = ReplicatedStorage:WaitForChild("Shared", 10)
	local mod = shared and shared:WaitForChild("Preload", 3)
	local ok, list = false, nil
	if mod and mod:IsA("ModuleScript") then
		ok, list = pcall(function()
			return (require(mod) :: any).list()
		end)
	end
	if ok and type(list) == "table" and #list > 0 then
		total = #list
		-- (an Instance in the list can bring several pictures: count each content once and never past the end —
		-- wr-gamer all1 saw "42 / 39")
		local seen = {}
		pcall(ContentProvider.PreloadAsync, ContentProvider, list, function(id, status)
			if seen[id] then
				return
			end
			seen[id] = true
			done += 1
			total = math.max(total, done)
			if status ~= Enum.AssetFetchStatus.Success then
				failed += 1 -- (the output log only: a missing picture must not hold the game up)
			end
			show(done / total)
		end)
	end
	preloadDone = true
end)

-- the percent creeps along while there's no list to count (never sits at 0)
task.spawn(function()
	while not leaving do
		if total == 0 then
			local t = os.clock() - started
			show(0.9 * (1 - math.exp(-t / 2.5)))
		end
		task.wait(0.2)
	end
end)

-- leave when the game is in and the list is fetched (at least a moment, so it doesn't just flash) — or after
-- GIVE_UP seconds whatever happens
local function ready(): boolean
	return game:IsLoaded() and preloadDone and os.clock() - started >= 1.2
end
while not ready() or (testing and script:GetAttribute("HoldForTest")) do
	if os.clock() - started > GIVE_UP and not (testing and script:GetAttribute("HoldForTest")) then
		break
	end
	task.wait(0.1)
end
leave(if ready() then "loaded" else "gave up waiting")
