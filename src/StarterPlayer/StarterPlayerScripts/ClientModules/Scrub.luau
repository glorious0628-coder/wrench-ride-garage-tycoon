-- The Terminal Scrub mini-game, version 2 (approved mock: notes/gpt/wr-ui/mock/scrub_mock2.png; owner's rule "do it with
-- your body, not with buttons"): NO popup. The camera moves in over the battery's + terminal in the engine bay and the
-- player rubs the terminal ITSELF with a finger / the mouse. Flat brown crust lumps sit on it (local parts, drawn only on
-- this screen); rubbing shrinks them and they go. On screen: one short line ("Rub the terminal clean", key word yellow),
-- a slim progress bar with its %, nothing else — it finishes by itself at 100% (no button); every other card / window is
-- hidden meanwhile (this screen counts as the open window, UIKit "WindowOpen"). One hand, one gesture, 4-6 s.
-- The screen draws and sends INTENT only — which cells were rubbed — the server judges everything.
--
-- Signals (board [10-22 wr-ui] "미니 게임 신호", wr-dev's MinigameService):
--   server -> client  Remotes.Minigame:  "scrub"       { id, cols, rows, dirty = {cells}, minTime }
--                                         "auto"        { id, seconds, kind }
--                                         "scrubResult" { id, result = "good" | "perfect" | "auto", money?, keepable? }
--                                         "stop"
--   client -> server  Remotes.MinigameScrub:FireServer(id, cells {number}, finished?)  1-based, row by row, every 0.25 s
--                     Remotes.SetMinigames:FireServer({ keep = "Scrub" })               the result chip
--   kind "Polish" (BODY_SCRATCH_LIGHT, approved mock notes/gpt/wr-ui/mock/scratch_mock1.png): the same screen on a flat
--   body panel — the start signal also carries `at` (where the scratch is) and `normal` (which way the panel faces); the
--   camera hangs in front of that panel, the dirt is a thin white scratch line, the cursor a foam polishing pad.
-- Studio test: player attribute "MgTest" = "scrub" | "auto" | "perfect" | "autodone" (with the work car's hood open),
--   "polish" | "polishrub" | "polishhalf" | "polishauto" (a door) · "polishnose" | "polishnosehalf" (the front bumper, where
--   FaultService puts the real scuff).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local Scrub = {}

local C = UIStyle.Color
local player = Players.LocalPlayer
-- (+) terminal corrosion is blue-green with white powder (car_knowledge common_jobs_visible [21]; brown discs read as
-- cookies — API check scrub_cam3)
local CRUST = Color3.fromRGB(238, 238, 230)
local CRUST_DARK = Color3.fromRGB(170, 210, 196) -- (mostly white powder, a little pale blue-green: main v4)
local LEAD = Color3.fromRGB(190, 194, 202)
local SEND_EVERY = 0.25
local RUB_PX = 6 -- (a lump thins a bit for every this many pixels the finger moves over it)
local LUMP = 0.1 -- studs, a lump's size
-- what differs per kind: the area (studs across, deep/high) the grid covers, the camera, the words
local KIND = {
	-- (the camera stands back ~2 studs: the whole battery top in view, so it reads as a battery terminal; the crust still
	-- big enough to rub)
	Scrub = { area = Vector2.new(0.4, 0.26), hint = "mg.scrub.hint", auto = "mg.auto.hint", rub = RUB_PX },
	-- (the scratch picture's own box: 940 x 296 px of scratch_marks_A -> 2.44 studs across at POLISH_DIST: its lines thick
	-- enough to read on a phone)
	Polish = { area = Vector2.new(2.44, 2.44 * 296 / 940), hint = "mg.polish.hint", auto = "mg.polish.auto", rub = 8 },
}
-- studs in front of the panel (FOV 38: about 3.1 studs high — the wheel arch / door gap / handle show around the scratch,
-- mock); the scratch's area grows with it, so the scratch and the pad stay the size they were on screen
local POLISH_DIST = 4.5
-- the wr-art scratch picture (UIStyle.Image.Scratch): the pixel box its marks sit in. SCR_FLIP mirrors the
-- scratch (B falls to the right; A already rises to the right, like the mock's swipe along the door)
local SCR = { x0 = 44, x1 = 984, y0 = 120, y1 = 416 }
local SCR_FLIP = false
local refitScrub: (() -> ())? = nil -- (placed again whenever a screen opens: the gear may have moved)
local pad: Frame -- the polishing pad under the pointer (Polish)
-- Polish draws its scratch apart from the cells (which only carry the server's grid state): the scratch picture cut into one
-- slice per column, each slice fading with its column's cells (the paint under it stays as it is — main v4: no white
-- polish smear); a small twinkle by the pad where a column comes clean, one bigger one when the last goes
local slices: { { mark: ImageLabel, fade: UIGradient, ghost: ImageLabel?, ghostFade: UIGradient?, cells: { number } } } = {}
local shines: { Instance } = {}

local root: CanvasGroup
local hintLabel: TextLabel
local barFill: Frame
local barLabel: TextLabel
local resultPill: Frame
local resultLabel: TextLabel
local keepButton: TextButton
local cueLabel: TextLabel
local exitButton: GuiButton
local quitSeq = 0
local finger: ImageLabel? = nil
local hintBand: Frame -- a soft dark band under the hint words
local target: Frame -- the start hint's gold ring round the dirt (main 10-23: the hand rubs beside it, this says "here")
local targetStroke: UIStroke
local cue: Frame -- the first-seconds hint: a soft finger-sized dot rubbing back and forth over the terminal until the first touch
local cueOn = false
local cells: { { part: Part, grime: number, sent: boolean, pre: boolean?, k: number, tone: number, yaw: number, pos: Vector3 } } = {}
-- the plane the grid lies on: `right` = screen right, `w` = down the screen on the plane, `n` = the plane's normal (towards
-- the camera), `lift` = how far off the surface the dirt floats
local scene: { at: Vector3, right: Vector3, w: Vector3, n: Vector3, lift: number, kind: string, area: Vector2, ink: Color3?, fitH: number? } | nil = nil
local session: { id: any, kind: string, cols: number, rows: number, auto: boolean, seconds: number?, t0: number } | nil = nil
local queue: { number } = {}
local lastSend = 0
local lastPos: Vector2? = nil
local rubbing = false
local resultToken = 0
local savedFov = 70

-- the car I'm working on and where its + terminal is: the battery's + lead post (battery_posts_v1 — the pinch nut sits
-- beside it now), else the (+) bolt head
local function findTerminal(): (Model?, Vector3?)
	local carId = player:GetAttribute("WorkCar")
	local cars = workspace:FindFirstChild("Cars")
	local best: Model? = nil
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:IsA("Model") and c:GetAttribute("Parked") and (carId == nil or c:GetAttribute("CarId") == carId) then
			best = c
			break
		end
	end
	if not best then
		return nil, nil
	end
	local battery = best:FindFirstChild("Battery", true)
	local post = CarParts.batteryPost(battery, "Pos")
	if post then
		return best, post
	end
	local nut = battery and battery:FindFirstChild("Bolt_2_Head", true)
	if nut and nut:IsA("BasePart") then
		return best, nut.Position
	end
	if battery then
		local pos = if battery:IsA("Model") then battery:GetPivot().Position else (battery :: BasePart).Position
		return best, pos + Vector3.new(0, 0.4, 0)
	end
	return best, (best:GetPivot() * CFrame.new(-1.99, 3.1, -6.03)).Position
end

-- the scratch (Polish): the work car and the spot + the way the panel faces. The server's start signal says where; the Auto
-- signal doesn't, so then it is the nearest scratch mark of the car I'm working on
local function findScratch(at: Vector3?, normal: Vector3?): (Model?, Vector3?, Vector3?)
	local carId = player:GetAttribute("WorkCar")
	local cars = workspace:FindFirstChild("Cars")
	local best: Model? = nil
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:IsA("Model") and c:GetAttribute("Parked") and (carId == nil or c:GetAttribute("CarId") == carId) then
			best = c
			break
		end
	end
	if not best then
		return nil, nil, nil
	end
	local pivot = best:GetPivot()
	if not at then
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local decor = best:FindFirstChild("Decor")
		local far = math.huge
		for _, d in (if decor then decor:GetChildren() else {}) do
			if d:IsA("BasePart") and d.Name:sub(1, 6) == "Issue_" and root and (d.Position - root.Position).Magnitude < far then
				far = (d.Position - root.Position).Magnitude
				at = d.Position
			end
		end
		if not at then
			return nil, nil, nil
		end
	end
	if not normal then
		normal = if pivot:PointToObjectSpace(at :: Vector3).Z < 0 then pivot.LookVector else -pivot.LookVector
	end
	return best, at, (normal :: Vector3).Unit
end

local function paint(i: number)
	local c = cells[i]
	local g = c.grime
	if g <= 0 then
		c.part.Transparency = 1
		return
	end
	local sc = scene
	if sc and sc.kind == "Polish" then
		c.part.Transparency = 1 -- (the cell is state only: the strokes show it)
		return
	end
	c.part.Transparency = 0
	c.part.Color = LEAD:Lerp(CRUST:Lerp(CRUST_DARK, c.tone * 0.6), math.clamp(g * 1.3, 0, 1))
	-- lumpy clots of powder (round, grainy), shrinking under the finger — flat chips read as paper (API v4 check)
	local s = LUMP * (0.3 + 0.7 * g) * c.k
	c.part.Size = Vector3.new(s, s, s)
	c.part.CFrame = CFrame.new(c.pos + Vector3.new(0, -s * 0.25, 0)) -- (half sunk into the battery top: clumps, not marbles)
end

local buildStrokes: (cols: number, rows: number) -> ()

-- Polish: the strokes follow their cells' grime: thinner and fainter while rubbed, gone when clean (blink: what is
-- left flashes once most of it is done)
local function paintStrokes(blink: number?)
	-- each column's see-through: fainter while rubbed, gone when clean
	local see: { number } = {}
	for k, sl in slices do
		local g, n = 0, 0
		for _, i in sl.cells do
			local c = cells[i]
			if c and not c.pre then
				g += c.grime
				n += 1
			end
		end
		g = if n > 0 then g / n else 0
		-- (a column half rubbed already looks it: the line was barely fainter at 30% — wr-play recheck M05)
		see[k] = if g <= 0.02 then 1 else math.max(math.min((1 - g) * 1.6, 0.92), blink or 0)
	end
	-- then each slice fades into its neighbours along the line (a gradient from the shared edge values): the rubbed end
	-- of the scratch tapers off where the pad went, no square column edges (main v4 ②)
	for k, sl in slices do
		local a = (see[k - 1] or see[k]) * 0.5 + see[k] * 0.5
		local b = (see[k + 1] or see[k]) * 0.5 + see[k] * 0.5
		local seq = NumberSequence.new({ NumberSequenceKeypoint.new(0, a), NumberSequenceKeypoint.new(0.5, see[k]), NumberSequenceKeypoint.new(1, b) })
		sl.fade.Transparency = seq
		sl.mark.ImageTransparency = if a >= 1 and b >= 1 and see[k] >= 1 then 1 else 0
		if sl.ghost and sl.ghostFade then
			sl.ghostFade.Transparency = seq
			sl.ghost.ImageTransparency = if sl.mark.ImageTransparency >= 1 then 1 else 0.1
		end
	end
end

-- Polish: a column rubbed clean twinkles once, right by the pad (on the scratch's line there); the last one gives one
-- bigger twinkle in the middle — then the panel is just clean paint (main v4: 100% = no scratch, no smear)
local function twinkle(gui: Instance, x: number, y: number, size: number)
	local star = Instance.new("Frame")
	star.Name = "Twinkle"
	star.AnchorPoint = Vector2.new(0.5, 0.5)
	star.Position = UDim2.fromScale(x, y)
	star.Size = UDim2.fromOffset(0, 0)
	star.BackgroundTransparency = 1
	star.ZIndex = 3
	for i, rot in { 0, 90, 45, 135 } do
		local bar = Instance.new("Frame")
		bar.AnchorPoint = Vector2.new(0.5, 0.5)
		bar.Position = UDim2.fromScale(0.5, 0.5)
		bar.Size = if i <= 2 then UDim2.fromScale(1, 0.13) else UDim2.fromScale(0.55, 0.09) -- (a four-point star: long cross, short diagonals)
		bar.Rotation = rot
		bar.BackgroundColor3 = Color3.new(1, 1, 1)
		bar.BorderSizePixel = 0
		bar.ZIndex = 3
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = bar
		local g = Instance.new("UIGradient")
		g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
		g.Parent = bar
		bar.Parent = star
	end
	star.Parent = gui
	local TweenService = game:GetService("TweenService")
	local grow = TweenService:Create(star, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(size, size), Rotation = 20 })
	grow:Play()
	task.delay(0.18, function()
		if star.Parent then
			TweenService:Create(star, TweenInfo.new(0.22), { Size = UDim2.fromOffset(0, 0), Rotation = 45 }):Play()
			task.delay(0.24, function()
				star:Destroy()
			end)
		end
	end)
end

local function shine(col: number, cols: number)
	local sc = scene :: any
	if not sc or sc.kind ~= "Polish" or not sc.gui or sc.polished[col] then
		return
	end
	sc.polished[col] = true
	-- (on the line: the picture's lines climb from bottom left to top right)
	local fx = (col - 0.5) / cols
	twinkle(sc.gui, fx, 0.5 + sc.markH * 0.3 * (1 - 2 * fx), 70)
	local n = 0
	for _ in sc.polished do
		n += 1
	end
	if n >= sc.dirtyCols then
		task.delay(0.2, function()
			if scene == sc then
				twinkle(sc.gui, 0.5, 0.5, 170)
			end
		end)
	end
end

local function progress(): number
	-- only the lumps that started on the terminal count (the server's own dirty list; with no list, all of them)
	local clean, total = 0, 0
	for _, c in cells do
		if not c.pre then
			total += 1
			clean += 1 - c.grime
		end
	end
	return if total == 0 then 0 else clean / total
end

local LEAD_POST = Color3.fromRGB(128, 132, 138)
local GRIMY_POST = Color3.fromRGB(86, 84, 76) -- (dull dark grey-brown: the grime film on the dirty post before it's rubbed)
local dirtyPost: { BasePart } = {}
local function showProgress(share: number)
	for _, d in dirtyPost do
		if d.Parent then
			d.Color = GRIMY_POST:Lerp(LEAD_POST, math.clamp(share, 0, 1))
			if d.Name == "ScrubGrimeFilm" then
				d.Transparency = math.clamp(share, 0, 1) * 0.9 -- (the mesh's clean post comes through)
			end
		end
	end
	if share >= 1 then
		hintLabel.Visible = false -- (done: the result says it, not "rub…" — main v4)
	end
	barFill.Size = UDim2.fromScale(math.clamp(share, 0.02, 1), 1)
	barFill.Visible = share > 0.005 -- (0%: an empty bar, no green sliver — main 10-23)
	barLabel.Text = tostring(math.floor(math.clamp(share, 0, 1) * 100 + 0.5)) .. "%"
end

local GAP = 0.15 -- (the server takes one MinigameScrub a player per 0.1 s and drops the rest: never send closer than this)
local function flush(finished: boolean?)
	local sess = session :: any
	if not sess or sess.auto then
		return
	end
	if finished then
		sess.finishing = true
	end
	if os.clock() - lastSend < GAP then
		return -- (too soon after the last send: the frame loop sends it a moment later — a dropped last send left the
		-- screen at 100% with the server still waiting: wr-play "stuck at 92%" / wr-ui 10-23)
	end
	if sess.finishing then
		-- the finish carries every cell rubbed clean (the server ignores ones it already has): nothing is lost if an
		-- earlier send was dropped
		local all = {}
		for i, c in cells do
			if not c.pre and c.grime <= 0 then
				table.insert(all, i)
			end
		end
		Remotes.MinigameScrub:FireServer(sess.id, all, true)
		queue = {}
		sess.finishAt = os.clock()
	elseif #queue > 0 then
		Remotes.MinigameScrub:FireServer(sess.id, queue, false)
		queue = {}
	end
	lastSend = os.clock()
end

local shut: { GuiObject } = {} -- the other cards, hidden while the screen is up
local hidden: { [BasePart]: number } = {} -- car parts hidden from this player's view only (the hood etc. between the camera and the terminal)
local tinted: { [BasePart]: Color3 } = {} -- the battery posts, recoloured lead grey while the screen is up (their colour before)

local quiet: { BillboardGui } = {} -- the world's speech bubbles over heads, hidden here meanwhile (a '…' over the bumper)

-- (CustomerService's "Bubble" on a customer's Head; locally only — the server turns them back on, so this runs every
-- frame while the screen is up)
local function quietBubbles()
	for _, m in workspace:GetChildren() do
		local head = m:IsA("Model") and m:FindFirstChild("Head")
		local b = head and head:FindFirstChild("Bubble")
		if b and b:IsA("BillboardGui") and b.Enabled then
			b.Enabled = false
			if not table.find(quiet, b) then
				table.insert(quiet, b)
			end
		end
	end
end

local function showOthers()
	for _, o in shut do
		if o.Parent then
			o.Visible = true
		end
	end
	shut = {}
	for _, b in quiet do
		if b.Parent then
			b.Enabled = true
		end
	end
	quiet = {}
end

-- (what stays: the money bar, the tool bar and the settings gear — the approved mocks keep them)
local STAYS = { MoneyBar = true, Hotbar = true, SettingsButton = true }

local function hideOthers()
	showOthers()
	local function sweep(from: Instance)
		for _, o in from:GetChildren() do
			-- (never this screen's own pieces: a second open while one is up would hide them here and bring them back on close)
			local own = o == exitButton or o == pad or o == finger or o == cue or o == cueLabel or o == resultPill or o == keepButton or o == target
			if o ~= root and o:IsA("GuiObject") and o.Visible and not root:IsDescendantOf(o) and not STAYS[o.Name] and not own then
				o.Visible = false
				table.insert(shut, o)
			end
		end
	end
	sweep(root.Parent :: Instance)
	quietBubbles()
	local buttons = HUD.gui():FindFirstChild("WorkButtons") -- (the work view's own buttons sit outside the safe frame)
	if buttons and buttons:IsA("GuiObject") and buttons.Visible then
		buttons.Visible = false
		table.insert(shut, buttons)
	end
end

local function clearScene()
	for _, c in cells do
		c.part:Destroy()
	end
	cells = {}
	slices = {}
	for _, g in shines do
		g:Destroy()
	end
	shines = {}
	RunService:UnbindFromRenderStep("ScrubCam")
	for p, was in hidden do
		if p.Parent then
			p.LocalTransparencyModifier = was
			local markGui = p:FindFirstChildOfClass("SurfaceGui")
			if markGui then
				markGui.Enabled = true
			end
		end
	end
	hidden = {}
	for p, was in tinted do
		if p.Parent then
			p.Color = was
		end
	end
	tinted = {}
	for _, d in dirtyPost do
		if d.Name == "ScrubGrimeFilm" then
			d:Destroy()
		end
	end
	dirtyPost = {}
	local cam = workspace.CurrentCamera
	if scene and cam then
		cam.FieldOfView = savedFov
		-- the camera back to the player (outside a work view nobody else takes it back: after the server ended a polish —
		-- the car driven off — it stayed fixed at the shoulder: wr-play recheck M07); inside one, the work view's own
		-- camera takes over on the next frame
		if HUD.gui():GetAttribute("WorkView") ~= true and cam.CameraType == Enum.CameraType.Scriptable then
			cam.CameraType = Enum.CameraType.Custom
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				cam.CameraSubject = hum
			end
		end
	end
	scene = nil
end

local function build(kind: string, cols: number, rows: number, car: Model?, at: Vector3, normal: Vector3?)
	clearScene()
	local cam = workspace.CurrentCamera
	savedFov = cam.FieldOfView
	local area = KIND[kind].area
	local look: CFrame
	if kind == "Polish" and normal then
		-- the camera hangs in front of the panel looking straight at it, aimed a little below the scratch so the line sits in
		-- the upper part (the bar and the tool bar take the bottom); the player's own body is hidden from this view
		local right = Vector3.yAxis:Cross(normal)
		right = if right.Magnitude < 1e-3 then Vector3.xAxis else right.Unit
		local up = normal:Cross(right)
		-- onto the paint itself: the server's spot is on the bumper's box face, but its mesh bulges out past that (the
		-- picture would sit inside it), and a bumper's painted band is narrow (a black grille under it). The outermost flat
		-- run of the panel up/down from the spot = the paint: the picture goes on it, no taller than it
		local fitH: number? = nil
		local body = car and car:FindFirstChild("Body")
		if body then
			local lent: { BasePart } = {}
			for _, d in body:GetDescendants() do
				if d:IsA("BasePart") and not d.CanQuery and d.Transparency < 1 then
					d.CanQuery = true -- (the car's meshes don't take rays; locally, for this one look)
					table.insert(lent, d)
				end
			end
			local snap = RaycastParams.new()
			snap.FilterType = Enum.RaycastFilterType.Include
			snap.FilterDescendantsInstances = { body }
			local runs: { { dy: number, d: number, flat: boolean } } = {}
			local front = -math.huge
			for j = 0, 32 do
				local dy = -0.7 + j * 0.05
				local hit = workspace:Raycast(at + up * dy + normal * 2, -normal * 4, snap)
				if hit then
					local d = hit.Position:Dot(normal)
					local flat = hit.Normal:Dot(normal) > 0.9
					table.insert(runs, { dy = dy, d = d, flat = flat })
					if flat then
						front = math.max(front, d)
					end
				end
			end
			for _, d in lent do
				d.CanQuery = false
			end
			-- the painted run nearest the spot
			local best, lo, hi = math.huge, 0, 0
			local i = 1
			while i <= #runs do
				if runs[i].flat and runs[i].d > front - 0.06 then
					local j = i
					while j < #runs and runs[j + 1].flat and runs[j + 1].d > front - 0.06 and runs[j + 1].dy - runs[j].dy < 0.06 do
						j += 1
					end
					local far = if runs[i].dy <= 0 and runs[j].dy >= 0 then 0 else math.min(math.abs(runs[i].dy), math.abs(runs[j].dy))
					if far < best then
						best, lo, hi = far, runs[i].dy, runs[j].dy
					end
					i = j + 1
				else
					i += 1
				end
			end
			if best < math.huge then
				local runH = hi - lo + 0.05
				local depth = front - at:Dot(normal)
				if runH < area.Y * 1.5 then -- (a narrow band: the picture centred on it and squashed to it)
					at = at + up * ((lo + hi) / 2) + normal * depth
					fitH = runH * 0.92
				else
					at = at + normal * depth
				end
			end
		end
		local target = at - up * 0.14 -- (aimed below the scratch: it sits over the middle, the hint + bar under it, mock)
		-- the camera stands a little in from the scratch towards the car's middle, looking out past it at the car's corner
		-- (a wheel / lamp / gap in view, so it reads as a car, not a flat wall); square on when the spot is mid-panel
		local side = if car then (at - car:GetPivot().Position):Dot(right) else 0
		local turn = if math.abs(side) > 0.6 then -math.rad(24) * math.sign(side) else 0
		local dir = normal * math.cos(turn) + right * math.sin(turn)
		look = CFrame.lookAt(target + dir * POLISH_DIST, target)
		-- (the grid lies square on the panel: the scratch picture itself carries the slant)
		scene = { at = at, right = right, w = -up, n = normal, lift = 0.015, kind = kind, area = area, fitH = fitH }
		local char = player.Character
		for _, d in (if char then char:GetDescendants() else {}) do
			if d:IsA("BasePart") and not hidden[d] then
				hidden[d] = d.LocalTransparencyModifier
				d.LocalTransparencyModifier = 1
			end
		end
		-- the server's own scuff mark (FaultService "Issue_<slot>" on the bumper) is drawn by these strokes now: hidden
		-- here, it goes for good once the fault is fixed
		local decor = car and car:FindFirstChild("Decor")
		for _, d in (if decor then decor:GetChildren() else {}) do
			if d:IsA("BasePart") and d.Name:sub(1, 6) == "Issue_" and (d.Position - at).Magnitude < 0.6 and not hidden[d] then
				hidden[d] = d.LocalTransparencyModifier
				d.LocalTransparencyModifier = 1
				local markGui = d:FindFirstChildOfClass("SurfaceGui") -- (the mark's picture, FaultService: a gui ignores the plate's hiding)
				if markGui then
					markGui.Enabled = false
				end
			end
		end
		-- the paint under it: on a pale car the silver lines go darker grey (wr-art: weak on white)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { cam, decor :: Instance, char :: Instance }
		local hit = workspace:Raycast(at + normal * 0.4, -normal * 0.8, params)
		local paint = if hit then hit.Instance.Color else Color3.new(0.3, 0.6, 0.6)
		local light = 0.299 * paint.R + 0.587 * paint.G + 0.114 * paint.B
		local sc0 = scene :: any
		sc0.ink = if light > 0.72 then Color3.fromRGB(150, 156, 166) else nil -- (the picture tinted grey: silver on white is lost, darker reads as pen)
	else
		-- the camera: over the battery's outer side, looking down at both posts side by side (the dirty + one and the − one
		-- — main v4: the old spot looked in from the cabin side, the seats filled the left); the crust area's axes follow
		-- the camera so columns run left -> right on screen
		local battery = car and car:FindFirstChild("Battery", true)
		local other = CarParts.batteryPost(battery, "Neg")
		local mid = if other then (at + other) / 2 else at
		local along = if other then other - at else (if car then car:GetPivot().LookVector else Vector3.zAxis)
		along = Vector3.new(along.X, 0, along.Z).Unit
		local side = Vector3.yAxis:Cross(along).Unit
		local centre = if car then car:GetPivot().Position else mid
		if side:Dot(Vector3.new(mid.X - centre.X, 0, mid.Z - centre.Z)) < 0 then
			side = -side -- (from the bay's edge, not from over the engine)
		end
		look = CFrame.lookAt(mid + side * 0.7 + Vector3.new(0, 1.75, 0), mid)
		-- the server's own crust marks (FaultService "Issue_Battery_1/2": a 0.42-stud cream block on each post) hidden here —
		-- our powder ring lay inside them, so the player saw two big cream blocks that never shrank (wr-play / wr-mini
		-- 10-23); they go for good once the fault is fixed
		local decor = car and car:FindFirstChild("Decor")
		for _, d in (if decor then decor:GetChildren() else {}) do
			if d:IsA("BasePart") and d.Name:sub(1, 6) == "Issue_" and (d.Position - mid).Magnitude < 1.2 and not hidden[d] then
				hidden[d] = d.LocalTransparencyModifier
				d.LocalTransparencyModifier = 1
			end
		end
		-- the dirty (+) post starts dull and grimy (a film of grime on its top, under the powder) and comes clean as the bar
		-- fills — the mesh's own lead post shows through (battery_posts_v1: real posts, the bolt heads aren't posts now)
		local grimy: { BasePart } = {}
		if not CarParts.batteryPost(battery, "Pos") then
			-- (an old battery mesh without posts: its bolt heads stand in, tinted lead grey — put back on close)
			for _, name in { "Bolt_1_Head", "Bolt_2_Head" } do
				local post = battery and battery:FindFirstChild(name, true)
				if post and post:IsA("BasePart") and not tinted[post] then
					tinted[post] = post.Color
					post.Color = if name == "Bolt_2_Head" then GRIMY_POST else LEAD_POST
					if name == "Bolt_2_Head" then
						table.insert(grimy, post)
					end
				end
			end
		else
			local film = Instance.new("Part")
			film.Name = "ScrubGrimeFilm"
			film.Shape = Enum.PartType.Cylinder
			film.Size = Vector3.new(0.02, 0.11, 0.11)
			film.CFrame = CFrame.new(at + Vector3.new(0, 0.002, 0)) * CFrame.Angles(0, 0, math.rad(90))
			film.Color = GRIMY_POST
			film.Material = Enum.Material.SmoothPlastic
			film.Anchored, film.CanCollide, film.CanQuery, film.CanTouch, film.CastShadow = true, false, false, false, false
			film.Parent = workspace.CurrentCamera
			table.insert(grimy, film)
		end
		dirtyPost = grimy
		local right = Vector3.new(look.RightVector.X, 0, look.RightVector.Z).Unit
		local fwd = Vector3.new(look.LookVector.X, 0, look.LookVector.Z).Unit
		-- (the powder sits around the post's foot, the post itself standing out of it: main v4 "around the terminal")
		scene = { at = at, right = right, w = -fwd, n = Vector3.yAxis, lift = 0.04, kind = kind, area = area }
	end
	local sc = scene :: any
	sc.car = car -- (the screen goes if the car does: driven off / taken away mid-job)
	-- see-through (locally) whatever of the car's body sits between the camera and the terminal
	if car and kind ~= "Polish" then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local skip = {}
		local from = look.Position
		for _ = 1, 8 do
			params.FilterDescendantsInstances = skip
			local hit = workspace:Raycast(from, at - from, params)
			if not hit or (hit.Position - at).Magnitude < 0.2 then
				break
			end
			local part = hit.Instance
			table.insert(skip, part)
			if part:IsDescendantOf(car) and part:FindFirstAncestor("Body") and part.Transparency < 1 then
				hidden[part] = part.LocalTransparencyModifier
				part.LocalTransparencyModifier = 1
			end
		end
		-- the hood's prop rod, the open hood and the bay's modelled red battery cable (it lies right across the terminal) are in the
		-- picture's way too
		for _, d in car:GetDescendants() do
			if d:IsA("BasePart") and (d:FindFirstAncestor("Mesh_Deco_HoodProp") or d:FindFirstAncestor("Visual_Hood") or d:FindFirstAncestor("Mesh_Deco_EngineBay")) and not hidden[d] then
				hidden[d] = d.LocalTransparencyModifier
				d.LocalTransparencyModifier = 1
			end
		end
	end
	-- (a later step than the work view's camera: this one wins every frame while the lumps are up)
	RunService:BindToRenderStep("ScrubCam", Enum.RenderPriority.Camera.Value + 3, function()
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = look
		cam.FieldOfView = 38
	end)
	local cw, ch = area.X / cols, area.Y / rows
	for r = 1, rows do
		for k = 1, cols do
			local p = Instance.new("Part")
			p.Name = "Crust"
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
			p.Material = if kind == "Polish" then Enum.Material.SmoothPlastic else Enum.Material.Sand -- (matte and grainy: powder, not ice or gems)
			p.Shape = if kind == "Polish" then Enum.PartType.Block else Enum.PartType.Ball
			local u = (k - 0.5) * cw - area.X / 2
			local v = (r - 0.5) * ch - area.Y / 2
			local h1, h2, h3 = math.sin(r * 12.9 + k * 78.2), math.cos(r * 39.3 + k * 11.1), math.sin(r * 5.3 + k * 91.7)
			local jitter = sc.right * (h1 * cw * 0.2) + sc.w * (h2 * ch * 0.2)
			local off = sc.right * u + sc.w * v + jitter
			if kind ~= "Polish" and off.Magnitude < 0.19 then -- (a ring round the post, outside its 0.3 hex head: none hides under it)
				off = if off.Magnitude > 1e-3 then off.Unit * 0.19 else sc.right * 0.19
			end
			local pos = at + off + sc.n * sc.lift
			if kind == "Polish" then
				p.Shape = Enum.PartType.Block
				pos = at + sc.right * u + sc.w * (v + h2 * ch * 0.08) + sc.n * sc.lift
			end
			p.Position = pos
			p.Parent = cam
			cells[(r - 1) * cols + k] = { part = p, grime = 1, sent = false, k = if kind == "Polish" then cw * 1.9 else 0.62 + 0.36 * (h3 + 1), tone = (h2 + 1) / 2, yaw = if kind == "Polish" then 0 else h1 * 3, pos = pos }
			paint((r - 1) * cols + k)
		end
	end
end

-- the pointer's cell: a ray through it onto the lumps' flat plane
local function cellAt(p: Vector2): number?
	local s, sess = scene, session
	if not s or not sess then
		return nil
	end
	local cam = workspace.CurrentCamera
	local gi = GuiService:GetGuiInset()
	local ray = cam:ViewportPointToRay(p.X, p.Y + gi.Y) -- (input positions sit below the top bar, the camera's don't)
	local denom = ray.Direction:Dot(s.n)
	if math.abs(denom) < 1e-3 then
		return nil
	end
	local t = (s.at + s.n * s.lift - ray.Origin):Dot(s.n) / denom
	if t <= 0 then
		return nil
	end
	local hit = ray.Origin + ray.Direction * t - s.at
	if s.kind ~= "Polish" then
		-- the terminal's powder lies in a ring (pushed off the post), not on the grid's squares: the lump nearest the
		-- finger, if it is within a finger's reach on the plane
		local best, far = nil, 0.11
		for i, c in cells do
			if c.grime > 0 and not c.pre then
				local d = hit - (c.pos - s.at)
				d -= s.n * d:Dot(s.n)
				if d.Magnitude < far then
					best, far = i, d.Magnitude
				end
			end
		end
		return best
	end
	local u, v = hit:Dot(s.right), hit:Dot(s.w)
	local cols, rows = sess.cols, sess.rows
	local area = s.area
	local cu, cv = (u + area.X / 2) / area.X, (v + area.Y / 2) / area.Y
	if s.kind == "Polish" and cv > -0.3 and cv < 1.3 then
		cv = math.clamp(cv, 0, 0.999) -- (the pad is bigger than the scratch is high: just above / below it still counts)
	end
	if cu < 0 or cu >= 1 or cv < 0 or cv >= 1 then
		return nil
	end
	return math.floor(cv * rows) * cols + math.floor(cu * cols) + 1
end

local function rubAt(p: Vector2)
	local i = cellAt(p)
	local moved = if lastPos then (p - lastPos).Magnitude else 0
	lastPos = p
	if finger then
		-- (its fingertip on the pointer; in the phone check the frame's corner is taken off, like the pad)
		local parent = root.Parent
		local o = if parent and parent:IsA("GuiObject") then parent.AbsolutePosition else Vector2.zero
		finger.Visible = i ~= nil or (session ~= nil and session.kind == "Polish")
		finger.Position = UDim2.fromOffset((p.X - o.X) / UIKit.zoom(), (p.Y - o.Y) / UIKit.zoom())
	end
	if session and session.kind == "Polish" and pad then
		pad.Visible = true
		local parent = root.Parent
		local o = if parent and parent:IsA("GuiObject") then parent.AbsolutePosition else Vector2.zero
		pad.Position = UDim2.fromOffset((p.X - o.X) / UIKit.zoom(), (p.Y - o.Y) / UIKit.zoom())
	end
	if not i or not cells[i] then
		return
	end
	cueOn = false
	cue.Visible = false
	hintLabel.Visible = false -- (rubbing: the words are understood, and the hand would sit on them — main 10-23)
	local c = cells[i]
	if c.grime <= 0 then
		return
	end
	local rub = moved / UIKit.zoom() / (KIND[if session then session.kind else "Scrub"].rub) * 0.12 + 0.02
	local touched: { [number]: number } = { [i] = 1 }
	local sess = session
	if sess and sess.kind == "Polish" then
		-- (the pad covers the scratch's whole height and a bit of the columns beside: a thin line needs no pixel aim on a
		-- phone, and the picture's lines don't sit on the server's rows anyway)
		local col = (i - 1) % sess.cols + 1
		for r2 = 1, sess.rows do
			for dc = -1, 1 do
				local c2 = col + dc
				if c2 >= 1 and c2 <= sess.cols then
					touched[(r2 - 1) * sess.cols + c2] = if dc == 0 then 1 else 0.6
				end
			end
		end
	end
	for j, share in touched do
		local cj = cells[j]
		if cj and cj.grime > 0 then
			cj.grime = math.max(0, cj.grime - rub * share)
			paint(j)
			if cj.grime <= 0 and not cj.sent then
				cj.sent = true
				table.insert(queue, j)
				local sc = scene :: any
				if sc and sc.kind == "Polish" and sess then
					shine((j - 1) % sess.cols + 1, sess.cols)
				end
			end
		end
	end
	if scene and scene.kind == "Polish" then
		paintStrokes()
	end
	local share = progress()
	showProgress(share)
	local left = 0
	for _, c3 in cells do
		if not c3.pre and c3.grime > 0 then
			left += 1
		end
	end
	-- (the server's own number: Config.Scrub / Polish AutoLeft — a finger that can't find the last two small lumps must not be stuck)
	local autoLeft = if scene and scene.kind == "Polish" then Config.Polish.AutoLeft else Config.Scrub.AutoLeft
	if left <= autoLeft and share > 0 then
		-- (a lump or two left, or none: it ends by itself, no button; the last bits are done for the hand — the server takes the cells and judges)
		for j, c2 in cells do
			if not c2.pre and c2.grime > 0 then
				c2.grime = 0
				paint(j)
				if not c2.sent then
					c2.sent = true
					table.insert(queue, j)
				end
			end
		end
		if scene and scene.kind == "Polish" then
			paintStrokes() -- (the last thin line too: wr-mini saw one left on the 100% card)
		end
		showProgress(1)
		flush(true)
	end
end

local function close()
	cueLabel.Visible = false
	exitButton.Visible = false
	session = nil
	rubbing = false
	cueOn = false
	cue.Visible = false
	target.Visible = false
	if finger then
		finger.Visible = false
	end
	pad.Visible = false
	clearScene()
	showOthers()
	HUD.minigame("Scrub", false)
	UIKit.close(root)
end

local function showResult(result: string, money: number?, keepable: boolean?)
	resultToken += 1
	local my = resultToken
	hintLabel.Visible = false
	cue.Visible = false
	showProgress(1) -- (the server says it's done: the bar agrees)
	-- (and the picture: the server ends with a cell or two still unrubbed — nothing of the dirt / scratch stays)
	for j, c in cells do
		if c.grime > 0 then
			c.grime = 0
			paint(j)
		end
	end
	if scene and scene.kind == "Polish" then
		paintStrokes()
	end
	pad.Visible = false
	if finger then
		finger.Visible = false
	end
	UIKit.setText(resultLabel, "mg.result." .. result .. (if result == "perfect" and (money or 0) <= 0 then "0" else ""), { money = "$" .. tostring(money or 0) })
	resultPill.Visible = true
	UIKit.pop(resultPill, 0.6)
	if result == "perfect" then
		task.defer(UIKit.sparkles, resultPill, 7) -- ('Spotless!' twinkle: the 2D part; the world's sparkle is wr-vfx's)
	end
	keepButton.Visible = keepable == true
	task.delay(if keepable then 10 else 1.6, function()
		if my == resultToken then
			resultPill.Visible = false
			keepButton.Visible = false
			close()
		end
	end)
end

-- the scratch's look (Polish): the scratch picture on the panel, cut into one slice per column (each slice fades with its
-- column's cells), and the shine picture's slices under it, hidden until their column is clean
buildStrokes = function(cols: number, rows: number)
	local sc = scene :: any
	local area = sc.area
	local up = -sc.w
	local h = area.X * 0.5 -- (room for the stretched scratch lines and the shine: the board clips what sticks out)
	local board = Instance.new("Part")
	board.Name = "Scratch"
	board.Anchored = true
	board.CanCollide = false
	board.CanQuery = false
	board.CanTouch = false
	board.CastShadow = false
	board.Transparency = 1
	board.Size = Vector3.new(area.X, h, 0.002)
	board.CFrame = CFrame.fromMatrix(sc.at + sc.n * sc.lift, sc.right, up, sc.n)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back -- (-Z of a fromMatrix frame = the normal: the side the camera looks at)
	gui.LightInfluence = 0 -- (full bright: a shaded silver line sinks into the paint)
	gui.PixelsPerStud = 400
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.Parent = board
	-- (drawn 50% taller than the picture: the lines get thicker and steeper, like the mock's — GPT polish3 r1; on a narrow
	-- painted band no taller than the band)
	local markH = math.min(area.Y * 1.5, if sc.fitH then sc.fitH * 1.5 else math.huge) / h -- (bumper: 1.3 → 1.5, a little thicker on a phone — main 10-23 #14) -- (the picture's lines sit inside its box: 15% more still stays on the band)
	local sw = (SCR.x1 - SCR.x0) / cols
	local dirtyCols = 0
	for k = 1, cols do
		local own = {}
		for r = 1, rows do
			local i = (r - 1) * cols + k
			if cells[i] and not cells[i].pre then
				table.insert(own, i)
			end
		end
		local mark = Instance.new("ImageLabel")
		mark.Name = "Mark" .. k
		mark.BackgroundTransparency = 1
		mark.Image = UIStyle.Image.Scratch
		if SCR_FLIP then -- (a negative rect width mirrors the slice)
			mark.ImageRectOffset = Vector2.new(SCR.x1 - (k - 1) * sw, SCR.y0)
			mark.ImageRectSize = Vector2.new(-sw, SCR.y1 - SCR.y0)
		else
			mark.ImageRectOffset = Vector2.new(SCR.x0 + (k - 1) * sw, SCR.y0)
			mark.ImageRectSize = Vector2.new(sw, SCR.y1 - SCR.y0)
		end
		mark.ImageColor3 = sc.ink or Color3.new(1, 1, 1)
		mark.Position = UDim2.fromScale((k - 1) / cols, (1 - markH) / 2)
		mark.Size = UDim2.fromScale(1 / cols, markH)
		mark.ZIndex = 2
		mark.Visible = #own > 0
		mark.Parent = gui
		-- the groove's shadow: a dark copy a few pixels lower, under the silver line — a light line on bright paint read
		-- faint (main v4: the bumper's 0% scratch); on white paint the line is already dark, no shadow
		local fade = Instance.new("UIGradient")
		fade.Parent = mark
		local ghost: ImageLabel? = nil
		local ghostFade: UIGradient? = nil
		if not sc.ink then
			local gh = mark:Clone()
			gh.Name = "Ghost" .. k
			gh.ImageColor3 = Color3.fromRGB(14, 30, 36)
			gh.Position = mark.Position + UDim2.fromOffset(0, if sc.fitH then 8 else 6)
			gh.ZIndex = 1
			gh.Parent = gui
			ghost = gh
			ghostFade = gh:FindFirstChildWhichIsA("UIGradient")
		end
		slices[k] = { mark = mark, fade = fade, ghost = ghost, ghostFade = ghostFade, cells = own }
		if #own > 0 then
			dirtyCols += 1
		end
	end
	board.Parent = workspace.CurrentCamera
	table.insert(shines, board)
	sc.gui = gui
	sc.markH = markH
	sc.dirtyCols = math.max(1, dirtyCols)
	sc.polished = {}
	paintStrokes()
end

local function open(kind: string, auto: boolean, cols: number, rows: number, id: any, seconds: number?, dirty: { number }?, scratchAt: Vector3?, scratchNormal: Vector3?): boolean
	local car, at, normal
	if kind == "Polish" then
		car, at, normal = findScratch(scratchAt, scratchNormal)
	else
		car, at = findTerminal()
	end
	if not at then
		return false
	end
	resultToken += 1
	pad.Visible = false -- (a polish pad left from a screen before must not ride over the terminal)
	if finger then
		finger.Visible = false -- (an Auto screen shows no hand)
	end
	session = { id = id, kind = kind, cols = cols, rows = rows, auto = auto, seconds = seconds, t0 = os.clock() }
	queue = {}
	lastPos = nil
	build(kind, cols, rows, car, at, normal)
	hideOthers()
	HUD.minigame("Scrub", true)
	cueOn = not auto
	-- the server's start: only its dirty cells carry crust (it judges against exactly these)
	if dirty then
		local isDirty: { [number]: boolean } = {}
		for _, i in dirty do
			isDirty[i] = true
		end
		for i, c in cells do
			if not isDirty[i] then
				c.grime = 0
				c.sent = true
				c.pre = true
				paint(i)
			end
		end
	end
	if kind == "Polish" then
		buildStrokes(cols, rows)
	end
	showProgress(progress())
	if refitScrub then
		refitScrub()
	end
	resultPill.Visible = false
	keepButton.Visible = false
	hintLabel.Visible = true
	UIKit.setText(hintLabel, if auto then KIND[kind].auto else KIND[kind].hint)
	UIKit.open(root)
	if not auto then
		-- the one-word cue, big, 0.6 s (rubbing already works)
		local my = resultToken
		UIKit.setText(cueLabel, "mg.cue.rub")
		cueLabel.Visible = true
		UIKit.pop(cueLabel, 0.5)
		task.delay(0.6, function()
			if my == resultToken then
				cueLabel.Visible = false
			end
		end)
	end
	exitButton.Visible = true
	return true
end

-- Auto: the lumps rub themselves off in the order the bar fills, so it still reads as scrubbing
local function autoFill()
	task.spawn(function()
		local mine = resultToken
		while session and session.auto and mine == resultToken do
			local share = (os.clock() - session.t0) / (session.seconds or 4.5)
			showProgress(share)
			local sess = session :: any
			local polish = sess.kind == "Polish"
			for i, c in cells do
				-- (the scratch comes off along its length, left to right; the terminal's crust in reading order)
				local at = if polish then ((i - 1) % sess.cols + 1) / sess.cols else i / #cells
				if not c.pre and at <= share and c.grime > 0 then
					c.grime = math.max(0, c.grime - 0.35)
					paint(i)
					if polish and c.grime <= 0 then
						shine((i - 1) % sess.cols + 1, sess.cols)
					end
				end
			end
			if polish then
				paintStrokes()
			end
			task.wait(0.1)
		end
	end)
end

function Scrub.start()
	-- the screen layer: transparent, the only things on it are the line + the bar (and the result pill / keep chip)
	root = Instance.new("CanvasGroup")
	root.Name = "Scrub"
	root:SetAttribute("IsWindow", true) -- (counts as the open window: every other card hides meanwhile)
	root.AnchorPoint = Vector2.new(0.5, 1)
	root.BackgroundTransparency = 1
	root.GroupTransparency = 1
	root.Visible = false
	root.Size = UDim2.fromOffset(360, 110)
	root.ZIndex = 5
	root.Parent = HUD.gui()

	hintLabel = UIKit.text(root, { name = "ScrubHint", key = "mg.scrub.hint", rich = true, anchor = Vector2.new(0.5, 0), pos = UDim2.fromScale(0.5, 0.02), size = UDim2.fromScale(1, 0.5), max = 24 })
	hintBand = Instance.new("Frame")
	hintBand.Name = "HintBand"
	hintBand.AnchorPoint = Vector2.new(0.5, 0.5)
	hintBand.BackgroundColor3 = Color3.fromRGB(14, 16, 20)
	hintBand.BackgroundTransparency = 0.4
	hintBand.BorderSizePixel = 0
	hintBand.Visible = false
	hintBand.ZIndex = 2
	local bandCorner = Instance.new("UICorner")
	bandCorner.CornerRadius = UDim.new(1, 0)
	bandCorner.Parent = hintBand
	hintBand.Parent = root
	hintLabel.ZIndex = 3
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.AnchorPoint = Vector2.new(0, 1)
	track.Position = UDim2.fromScale(0.04, 0.96)
	track.Size = UDim2.fromScale(0.72, 0.2)
	track.BackgroundColor3 = C.PlateLight
	track.BorderSizePixel = 0
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = track
	local ts = Instance.new("UIStroke")
	ts.Color = C.Outline
	ts.Thickness = 2
	ts.Parent = track
	track.Parent = root
	barFill = Instance.new("Frame")
	barFill.Name = "Fill"
	barFill.BackgroundColor3 = C.Green
	barFill.BorderSizePixel = 0
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = barFill
	barFill.Parent = track
	barLabel = UIKit.text(root, { name = "Percent", text = "0%", font = "Title", anchor = Vector2.new(0, 1), pos = UDim2.fromScale(0.79, 0.98), size = UDim2.fromScale(0.2, 0.28), alignX = Enum.TextXAlignment.Left, max = 22 })

	-- the finished moment: a small green pill over the screen's middle ("Spotless! +$15" / "Nice and clean!" / "Done for you")
	resultPill = Instance.new("Frame")
	resultPill.Name = "Result"
	resultPill.AnchorPoint = Vector2.new(0.5, 0.5)
	resultPill.Position = UDim2.fromScale(0.5, -3.2)
	resultPill.Size = UDim2.fromOffset(250, 72)
	resultPill.BackgroundColor3 = C.Green
	resultPill.BorderSizePixel = 0
	local rc = Instance.new("UICorner")
	rc.CornerRadius = UDim.new(1, 0)
	rc.Parent = resultPill
	local rs = Instance.new("UIStroke")
	rs.Color = C.GreenDark
	rs.Thickness = 3
	rs.Parent = resultPill
	resultPill.Visible = false
	resultPill.Parent = root
	local tick = UIKit.icon(resultPill, UIStyle.Icon.Check, { name = "Tick", anchor = Vector2.new(0, 0.5), pos = UDim2.fromScale(0.05, 0.5), size = UDim2.fromScale(0.6, 0.6) })
	if tick then
		tick.SizeConstraint = Enum.SizeConstraint.RelativeYY
	end
	resultLabel = UIKit.text(resultPill, { name = "Text", key = "mg.result.good", font = "Title", anchor = Vector2.new(1, 0.5), pos = UDim2.fromScale(0.96, 0.5), size = UDim2.fromScale(if tick then 0.74 else 0.9, 0.7), max = 30 })
	keepButton = UIKit.button(root, { name = "Keep", key = "mg.keep", style = "Blue", anchor = Vector2.new(0.5, 0), pos = UDim2.fromScale(0.5, -4.2), size = UDim2.fromScale(1, 0.4), max = 20, onClick = function()
		Remotes.SetMinigames:FireServer({ keep = "Scrub" })
		keepButton.Visible = false
	end })
	keepButton.Visible = false
	cueLabel = UIKit.text(HUD.gui(), { name = "ScrubCue", key = "mg.cue.rub", font = "Title", color = C.Gold, anchor = Vector2.new(0.5, 0.5), size = UDim2.fromOffset(330, 96), max = 84, z = 9 })
	cueLabel.Rotation = -5
	cueLabel.Visible = false
	-- leave any time (nothing lost): a round close button at the top right of the picture
	exitButton = UIKit.closeButton(HUD.gui(), { name = "ScrubExit" }, function()
		if session then
			if not session.auto then
				quitSeq += 1
				Remotes.MinigameInput:FireServer(session.id, quitSeq, "quit")
			end
			resultToken += 1
			close()
			HUD.notify("mg.left", nil, "info")
		end
	end)
	exitButton.ZIndex = 9
	exitButton.Visible = false
	-- the finger cursor (mock part_finger): the approved picture once main has uploaded it (UIStyle.Icon.ScrubFinger),
	-- following the pointer over the terminal; until then the mouse's own arrow / the real finger do the job
	local fingerId = (UIStyle.Icon :: any).ScrubFinger
	if type(fingerId) == "string" and fingerId ~= "" then
		finger = Instance.new("ImageLabel")
		finger.Name = "Finger"
		finger.BackgroundTransparency = 1
		finger.AnchorPoint = Vector2.new(0.17, 0.12) -- (the picture's fingertip)
		-- big and outlined, like the mock's hand: the grey glove alone sinks into a teal / grey panel (GPT polish r2)
		finger.Size = UDim2.fromOffset(96, 96)
		finger.ZIndex = 9
		finger.Visible = false
		for _, d in { Vector2.new(3, 0), Vector2.new(-3, 0), Vector2.new(0, 3), Vector2.new(0, -3), Vector2.new(2, 2), Vector2.new(-2, 2), Vector2.new(2, -2), Vector2.new(-2, -2) } do
			local edge = Instance.new("ImageLabel")
			edge.Name = "Edge"
			edge.BackgroundTransparency = 1
			edge.Image = fingerId
			edge.ImageColor3 = Color3.fromRGB(24, 26, 30)
			edge.Position = UDim2.fromOffset(d.X, d.Y)
			edge.Size = UDim2.fromScale(1, 1)
			edge.ZIndex = 1
			edge.Parent = finger
		end
		local hand = Instance.new("ImageLabel")
		hand.Name = "Hand"
		hand.BackgroundTransparency = 1
		hand.Image = fingerId
		hand.Size = UDim2.fromScale(1, 1)
		hand.ZIndex = 2
		hand.Parent = finger
		finger.Parent = HUD.gui()
	end

	-- the polishing pad (Polish): a foam disc with a dark backing plate, following the pointer over the panel
	pad = Instance.new("Frame")
	pad.Name = "Pad"
	pad.AnchorPoint = Vector2.new(0.5, 0.5)
	pad.Size = UDim2.fromOffset(58, 58)
	pad.BackgroundColor3 = Color3.fromRGB(246, 214, 70)
	pad.BorderSizePixel = 0
	pad.ZIndex = 7
	pad.Visible = false
	local pc = Instance.new("UICorner")
	pc.CornerRadius = UDim.new(1, 0)
	pc.Parent = pad
	local ps = Instance.new("UIStroke")
	ps.Color = Color3.fromRGB(150, 120, 20)
	ps.Thickness = 3
	ps.Transparency = 0.15
	ps.Parent = pad
	local back = Instance.new("Frame")
	back.Name = "Plate"
	back.AnchorPoint = Vector2.new(0.5, 0.5)
	back.Position = UDim2.fromScale(0.5, 0.5)
	back.Size = UDim2.fromScale(0.44, 0.44)
	back.BackgroundColor3 = Color3.fromRGB(46, 50, 58)
	back.BorderSizePixel = 0
	back.ZIndex = 8
	local bpc = Instance.new("UICorner")
	bpc.CornerRadius = UDim.new(1, 0)
	bpc.Parent = back
	back.Parent = pad
		pad.Parent = HUD.gui()

	-- the start hint's "here" ring (round for the terminal, a rounded box along the scratch)
	target = Instance.new("Frame")
	target.Name = "ScrubTarget"
	target.AnchorPoint = Vector2.new(0.5, 0.5)
	target.BackgroundTransparency = 1
	target.Visible = false
	target.ZIndex = 6
	local tcorner = Instance.new("UICorner")
	tcorner.CornerRadius = UDim.new(0.5, 0)
	tcorner.Parent = target
	targetStroke = Instance.new("UIStroke")
	targetStroke.Color = C.Gold
	targetStroke.Thickness = 5
	targetStroke.Parent = target
	-- a dark rim just inside the gold: the ring reads on beige paint / white steam as well as on dark metal
	local rim = Instance.new("Frame")
	rim.Name = "Rim"
	rim.AnchorPoint = Vector2.new(0.5, 0.5)
	rim.Position = UDim2.fromScale(0.5, 0.5)
	rim.Size = UDim2.new(1, -14, 1, -14)
	rim.BackgroundTransparency = 1
	local rimCorner = Instance.new("UICorner")
	rimCorner.CornerRadius = UDim.new(0.5, 0)
	rimCorner.Parent = rim
	local rimStroke = Instance.new("UIStroke")
	rimStroke.Color = Color3.fromRGB(24, 20, 10)
	rimStroke.Thickness = 3
	rimStroke.Transparency = 0.1
	rimStroke.Parent = rim
	rim.Parent = target
	target.Parent = HUD.gui()

	cue = Instance.new("Frame")
	cue.Name = "Cue"
	cue.AnchorPoint = Vector2.new(0.5, 0.5)
	cue.Size = UDim2.fromOffset(40, 40)
	cue.BackgroundColor3 = Color3.new(1, 1, 1)
	cue.BackgroundTransparency = 0.35
	cue.BorderSizePixel = 0
	cue.ZIndex = 7
	cue.Visible = false
	local cuc = Instance.new("UICorner")
	cuc.CornerRadius = UDim.new(1, 0)
	cuc.Parent = cue
	local cus = Instance.new("UIStroke")
	cus.Color = Color3.new(1, 1, 1)
	cus.Transparency = 0.2
	cus.Thickness = 3
	cus.Parent = cue

	local function fit()
		local screen = UIKit.size()
		local w = math.min(math.floor(screen.X * 0.42), 340)
		root.Size = UDim2.fromOffset(w, math.floor(w * 0.27))
		local bottom = screen.Y - UIKit.hotbarHeight() - UIKit.hotbarGap() - 10
		root.Position = UDim2.fromOffset(math.floor(screen.X / 2), bottom)
		root:SetAttribute("Home", root.Position) -- (UIKit.open slides back to "Home": a stale one from before a resize put the bar on the tool bar)
		-- the result pill (and the keep chip under it) can't live in the root (a CanvasGroup clips to its box): they sit
		-- next to it, over the screen's upper-middle
		if target.Parent ~= root.Parent then
			target.Parent = root.Parent
		end
		for _, o in { resultPill, keepButton, cue, pad, finger } do
			if o.Parent ~= root.Parent then
				o.Parent = root.Parent
			end
			o.ZIndex = 8
		end
		pad.ZIndex = 7 -- (under the finger: the hand holds the pad)
		if finger then
			finger.ZIndex = 10
		end
		resultPill.Position = UDim2.fromOffset(math.floor(screen.X / 2), math.floor(screen.Y * 0.53))
		for _, o in { cueLabel, exitButton } do
			if o.Parent ~= root.Parent then
				o.Parent = root.Parent
			end
		end
		cueLabel.Position = UDim2.fromOffset(math.floor(screen.X / 2), math.floor(screen.Y * 0.42))
		-- the close button sits just left of the settings gear, on its row (the gear stays on screen)
		local sb = (root.Parent :: Instance):FindFirstChild("SettingsButton") :: GuiObject?
		local z = UIKit.zoom()
		if sb and sb.Visible and sb.AbsoluteSize.X > 0 then
			local c0 = (sb.AbsolutePosition - (root.Parent :: GuiObject).AbsolutePosition) / z
			exitButton.Position = UDim2.fromOffset(math.floor(c0.X - 26), math.floor(c0.Y + sb.AbsoluteSize.Y / z / 2))
		else
			exitButton.Position = UDim2.fromOffset(screen.X - 40, 46)
		end
		keepButton.AnchorPoint = Vector2.new(0.5, 0)
		keepButton.Size = UDim2.fromOffset(w, 40)
		keepButton.Position = UDim2.fromOffset(math.floor(screen.X / 2), math.floor(screen.Y * 0.53) + 50)
	end
	UIKit.bind(root, fit)
	refitScrub = function()
		fit()
	end

	-- leaving the work view / the character going: the screen goes with it, and the server hears "quit" like the ✕
	local function leave()
		if session then
			if not session.auto and session.id ~= "test" then
				quitSeq += 1
				Remotes.MinigameInput:FireServer(session.id, quitSeq, "quit")
			end
			resultToken += 1
			close()
		end
	end
	player:GetAttributeChangedSignal("WorkZone"):Connect(function()
		if session and not session.auto and player:GetAttribute("WorkZone") == nil and HUD.gui():GetAttribute("WorkView") ~= true then
			leave()
		end
	end)
	player.CharacterRemoving:Connect(leave)

	UserInputService.InputBegan:Connect(function(input, processed)
		if not session or session.auto or processed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local p = Vector2.new(input.Position.X, input.Position.Y)
			rubbing = true
			lastPos = p
			rubAt(p)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if rubbing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			rubAt(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			rubbing = false
			lastPos = nil
		end
	end)
	RunService.RenderStepped:Connect(function()
		-- (a safety net: whatever way the screen went — result, ✕, the server's stop, a new screen — nothing it hid or
		-- recoloured stays so once no screen is up: the engine bay never stays empty — main 10-23)
		if not session and (scene or next(hidden) or next(tinted)) then
			clearScene()
		end
		local sc = scene
		local gone = sc and (sc :: any).car
		if session and gone and not gone:IsDescendantOf(workspace) then
			resultToken += 1
			close() -- (the car left while the screen was up: the camera and my avatar come back — wr-play recheck M07)
			sc = nil
		end
		if sc then
			quietBubbles()
			-- my own avatar out of this close view (it filled a third of the terminal screen — wr-mini 10-23); every frame,
			-- as the camera guard gives its own fade back once the camera turns Scriptable
			local char = player.Character
			for _, d in (if char then char:GetDescendants() else {}) do
				if d:IsA("BasePart") then
					if hidden[d] == nil then
						hidden[d] = 0
					end
					d.LocalTransparencyModifier = 1
				end
			end
		end
		-- the hint words sit on a soft dark band (like the world's guide line: white words on a bright engine bay / paint)
		do
			local on = hintLabel.Visible and hintLabel.Text ~= "" and hintLabel.TextBounds.X > 1
			hintBand.Visible = on
			if on then
				local z = UIKit.zoom()
				local bnd = hintLabel.TextBounds / z
				hintBand.Size = UDim2.fromOffset(bnd.X + 30, bnd.Y + 10)
				local c = (hintLabel.AbsolutePosition + hintLabel.AbsoluteSize / 2 - root.AbsolutePosition) / z
				hintBand.Position = UDim2.fromOffset(c.X, c.Y)
			end
		end
		if HUD.gui():FindFirstChild("PayCard", true) then
			-- (the settlement card is up: nothing of this screen's start hint shows behind it)
			target.Visible, pad.Visible = false, false
			if finger then
				finger.Visible = false
			end
		elseif cueOn and sc and session and not session.auto then
			local t = os.clock() - session.t0
			local polish = sc.kind == "Polish"
			local cam = workspace.CurrentCamera
			local gi = GuiService:GetGuiInset()
			local z = UIKit.zoom()
			-- (in the phone check the picture's frame sits inside the window: the camera's pixels start at the window's corner)
			local parent = root.Parent
			local o = if parent and parent:IsA("GuiObject") then parent.AbsolutePosition else Vector2.zero
			local function px(w: Vector3): (Vector2, boolean)
				local p, vis = cam:WorldToViewportPoint(w)
				return Vector2.new((p.X - o.X) / z, (p.Y - gi.Y - o.Y) / z), vis
			end
			-- "here": a pulsing gold ring round what is to be rubbed — the dirty terminal's crust / the whole scratch
			local halfX = if polish then sc.area.X * 0.52 else 0.30
			local halfY = if polish then math.max((sc.fitH or sc.area.Y) * 0.8, 0.12) else 0.30 -- (a bumper: only as tall as its painted band)
			local a, vis1 = px(sc.at - sc.right * halfX - sc.w * halfY)
			local b = px(sc.at + sc.right * halfX + sc.w * halfY)
			local c0 = (a + b) / 2
			local w, h = math.abs(b.X - a.X), math.abs(b.Y - a.Y)
			target.Position = UDim2.fromOffset(c0.X, c0.Y)
			target.Size = UDim2.fromOffset(w, h)
			target.Visible = vis1
			local beat = 0.5 + 0.5 * math.sin(t * 5)
			targetStroke.Transparency = 0.15 * beat -- (never faint: it must read on a busy engine bay)
			targetStroke.Thickness = 5 + 2 * (1 - beat) -- (thinner again, 5-7 px: wr-uidesign A②, the ring hid the scratch)
			-- the hand: outside the ring at its lower right, a short swipe towards it (never over the dirt or between two
			-- posts; no filled pad under it — that read as a button)
			local swipe = math.sin(t * 3.2) * 7
			-- (east of the ring, its fingertip just outside the rim: the words and the bar are under it, so lower right is no room;
			-- the hand sits clear of both posts and of the hint)
			local tip = if polish then c0 + Vector2.new(w * 0.5 + 6 + swipe, h * 0.15 + swipe * 0.4) else c0 + Vector2.new(w * 0.5 + 4 + swipe, -h * 0.42 + swipe * 0.6)
			pad.Visible = false
			cue.Visible = false
			if finger then
				finger.Position = UDim2.fromOffset(tip.X, tip.Y)
				finger.Visible = vis1
			end
		elseif target.Visible then
			target.Visible = false
		end
		local s = session :: any
		if s and not s.auto then
			if s.finishing then
				-- (the finish goes again every 0.6 s until the server answers: the screen closes on its result)
				if not s.finishAt or os.clock() - s.finishAt >= 0.6 then
					flush(true)
				end
			elseif os.clock() - lastSend >= SEND_EVERY then
				flush(false)
			end
		end
		if s and not s.auto and progress() >= 0.7 then
			-- (what is left blinks, so the last bits are easy to find)
			local blink = 0.5 * (1 + math.sin(os.clock() * 9)) * 0.55
			if s.kind == "Polish" then
				paintStrokes(blink)
			else
				for _, c in cells do
					if not c.pre and c.grime > 0 then
						c.part.Transparency = blink
					end
				end
			end
		end
	end)
	Remotes.Minigame.OnClientEvent:Connect(function(what, data)
		if what == "scrub" and data then
			local kind = if data.kind == "Polish" then "Polish" else "Scrub"
			open(kind, false, data.cols or 6, data.rows or 4, data.id, nil, data.dirty, data.at, data.normal)
		elseif what == "auto" and data and (data.kind == "Scrub" or data.kind == "Polish") then
			-- (only these two: the Auto of the coolant / tire / torque / balance screens is theirs — it must not open this camera)
			local kind = data.kind
			local isPolish = kind == "Polish"
			if open(kind, true, if isPolish then 8 else 6, if isPolish then 3 else 4, data.id, data.seconds or 4.5, nil, data.at, data.normal) then
				autoFill()
			end
		elseif what == "scrubResult" and data then
			showResult(data.result or "good", data.money, data.keepable)
		elseif what == "stop" or what == "done" then
			-- (the same two signals also end the other mini-games: only mine — same session id, or one of my kinds — closes this)
			local mine = type(data) ~= "table" or data.id == nil or (session ~= nil and data.id == session.id) or data.kind == "Scrub" or data.kind == "Polish"
			if session and mine then
				close()
			end
		end
	end)
	-- Studio only: draw the screen with no server (player attribute MgTest, with a work car in the bay)
	if RunService:IsStudio() then
		player:GetAttributeChangedSignal("MgTest"):Connect(function()
			local t = player:GetAttribute("MgTest")
			if t == "scrub" then
				open("Scrub", false, 6, 4, "test", nil, nil)
			elseif t == "auto" then
				if open("Scrub", true, 6, 4, "test", 4.5, nil) then
					autoFill()
				end
			elseif t == "polish" or t == "polishnose" or t == "polishrub" or t == "polishhalf" or t == "polishnosehalf" or t == "polishauto" or t == "polishnoseauto" then
				local onNose = t == "polishnose" or t == "polishnosehalf" or t == "polishnoseauto"
				local half = t == "polishhalf" or t == "polishnosehalf"
				-- (the work car's front bumper stands in for the scratch: its nose, a bit low, the panel facing forward)
				local cars = workspace:FindFirstChild("Cars")
				local car = cars and cars:FindFirstChildWhichIsA("Model")
				if car then
					local cf, size = car:GetBoundingBox()
					local nose = car:GetPivot().LookVector
					local side = car:GetPivot().RightVector
					local at = cf.Position + nose * (size.Z / 2) - Vector3.new(0, size.Y * 0.1, 0)
					local facing = nose
					-- (the bumper: right where FaultService puts the real scuff mark — the root's face, 1.2 right / 0.3 up)
					local bumper = car:FindFirstChild("Bumper_F", true)
					if bumper and bumper:IsA("BasePart") then
						local face = bumper.CFrame * CFrame.new(1.2, 0.3, -bumper.Size.Z / 2 - 0.03)
						if bumper.CFrame.LookVector:Dot(nose) <= 0 then
							face = bumper.CFrame * CFrame.new(1.2, 0.3, bumper.Size.Z / 2 + 0.03)
						end
						at = face.Position
					end
					if not onNose then -- (the door: a bigger flat panel to judge the look on)
						-- (the car's left side, like the mock: the front wheel on the left, the door handle off to the right)
						facing = -side
						at = cf.Position - side * (size.X / 2) + nose * (size.Z * 0.07) - Vector3.new(0, size.Y * 0.06, 0) -- (the front door's middle: the arch on the left, like the mock; the handle is body-coloured mesh and does not read)
					end
					local list = {}
					local row = 2
					for col = 1, 8 do
						table.insert(list, (row - 1) * 8 + col)
						row = math.clamp(row + (if col % 3 == 0 then 1 elseif col % 3 == 1 then -1 else 0), 1, 3)
					end
					if t == "polishauto" or t == "polishnoseauto" then
						if open("Polish", true, 8, 3, "test", (player:GetAttribute("MgSlow") :: number?) or 4.5, nil, at, facing) then -- (MgSlow: seconds, for step-by-step photos)
							autoFill()
						end
					else
						open("Polish", false, 8, 3, "test", nil, list, at, facing)
					end
					if t == "polishrub" or half then
						task.spawn(function()
							task.wait(0.6)
							local cam = workspace.CurrentCamera
							local gi = GuiService:GetGuiInset()
							local from = os.clock()
							while session and os.clock() - from < 8 do
								for ci, c in cells do
									if c.grime > 0 and not c.pre and (not half or (ci - 1) % 8 < 4) then
										local v = cam:WorldToViewportPoint(c.part.Position)
										rubAt(Vector2.new(v.X, v.Y - gi.Y + 3))
										rubAt(Vector2.new(v.X + 30, v.Y - gi.Y - 3))
										task.wait(0.3)
									end
								end
								task.wait()
							end
						end)
					end
				end
			elseif (t == "rub" or t == "rubhalf") and session and scene then -- (a scripted finger: sweeps over every lump, as fast as a hand would; rubhalf = the left half only)
				task.spawn(function()
					local cam = workspace.CurrentCamera
					local gi = GuiService:GetGuiInset()
					local from = os.clock()
					while session and os.clock() - from < 8 do
						for _, c in cells do
							local v0 = cam:WorldToViewportPoint(c.part.Position)
							local mid = cam:WorldToViewportPoint((scene :: any).at)
							if c.grime > 0 and (t == "rub" or v0.X < mid.X) then
								local v = v0
								rubAt(Vector2.new(v.X, v.Y - gi.Y + 3))
								rubAt(Vector2.new(v.X + 40, v.Y - gi.Y - 3))
								task.wait(1 / 60)
							end
						end
						task.wait()
					end
				end)
			elseif t == "perfect" then
				showResult("perfect", 15, false)
			elseif t == "autodone" then
				showResult("auto", nil, true)
			end
		end)
	end
end

return Scrub
