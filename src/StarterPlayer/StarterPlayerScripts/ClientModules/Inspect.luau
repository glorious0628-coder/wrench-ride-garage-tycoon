-- Scanner in hand = inspect mode on the nearest car (기획서 6장): body panels go see-through
-- (LocalTransparencyModifier). Click a part to check it (Remotes.Check -> a reading on the job card); only CHECKED
-- parts show their colour (green / yellow / red) - unchecked ones get a faint white outline, so the diagnosis stays a
-- puzzle (fun_boost #1). Client-only drawing.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local HUD = require(script.Parent.HUD)

local Inspect = {}

local player = Players.LocalPlayer
local active = false
local car: Model? = nil
local highlights: { [Instance]: Highlight } = {}
local faded: { [Instance]: boolean } = {}
local holder: Folder

local MAX_HIGHLIGHTS = 30 -- Roblox draws at most 31 at once

local function colorFor(cond: number): Color3
	if cond < Config.BrokenBelow then
		return Config.Colors.Bad
	elseif cond < Config.WarnBelow then
		return Config.Colors.Warn
	end
	return Config.Colors.Good
end

local function nearestCar(): Model?
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local cars = workspace:FindFirstChild("Cars")
	if not root or not cars then
		return nil
	end
	local best, bestD = nil, Config.InspectRange
	for _, c in cars:GetChildren() do
		if c:IsA("Model") then
			local d = (c:GetPivot().Position - root.Position).Magnitude
			if d < bestD then
				best, bestD = c, d
			end
		end
	end
	return best
end

-- see-through while scanning; each part keeps what it had before (CarLook hides the blocks under the 3D with 1 —
-- putting 0 back showed the blocks: test 1 #7)
local before: { [BasePart]: number } = {}
local function setFade(p: Instance, t: number?)
	local list = if p:IsA("BasePart") then { p } else {}
	for _, d in p:GetDescendants() do
		if d:IsA("BasePart") then
			table.insert(list, d)
		end
	end
	for _, d in list do
		if t then
			if before[d] == nil then
				before[d] = d.LocalTransparencyModifier
			end
			d.LocalTransparencyModifier = math.max(before[d], t)
		elseif before[d] ~= nil then
			d.LocalTransparencyModifier = before[d]
			before[d] = nil
		end
	end
end

local function clear()
	for _, h in highlights do
		h:Destroy()
	end
	table.clear(highlights)
	for p in faded do
		setFade(p, nil)
	end
	table.clear(faded)
	table.clear(before)
end

local function fade(p: Instance)
	setFade(p, Config.InspectBodyTransparency)
	faded[p] = true
end

local function zoneOfPart(p: Instance): string?
	local slot = p:GetAttribute("Slot")
	return if type(slot) == "string" then CarParts.zoneOf(slot) else nil
end

-- Looking into the engine bay (the hood is up and the camera is over the nose, or the engine-bay work view): the
-- scan shows and takes only the bay's own parts. The wheels, brakes and muffler outlines drew big white ovals over the
-- engine and a click on the engine found "the front tyre" (user 10-23); they come back from the side / back / under.
local function bayMode(c: Model): boolean
	if player:GetAttribute("WorkZone") == "EngineBay" then
		return true
	end
	if c:GetAttribute("HoodOpen") ~= true then
		return false
	end
	local cam = workspace.CurrentCamera
	if not cam then
		return false
	end
	local at = c:GetPivot():PointToObjectSpace(cam.CFrame.Position)
	local ahead = -at.Z -- (the nose is the car's -Z)
	return ahead > 5 and math.abs(at.X) < ahead * 0.85
end

local function update()
	local c = nearestCar()
	if c ~= car then
		clear()
		car = c
	end
	if not car then
		return
	end
	-- a mini-game screen is up (terminal scrub …): its own dirt is the picture — the scan colours would cover the whole
	-- battery (wr-mini integration test #3); the see-through body stays, the highlights come back after
	local hud = HUD.gui()
	if hud and hud:GetAttribute("Minigame") == true then
		for p, h in highlights do
			h:Destroy()
			highlights[p] = nil
		end
		return
	end
	-- what should be highlighted this tick: mechanical parts, then broken body parts
	local want: { Instance } = {}
	local mech = car:FindFirstChild("MechanicalParts")
	local body = car:FindFirstChild("Body")
	local inBay = bayMode(car)
	-- (the new engine bay, piece E: a part under another one still on — a plug under its coil, the filter under the lid,
	-- the fuse under the box lid — gets no outline: the outlines are drawn on top of everything, so the bay showed rings
	-- floating over the coils for parts nobody can see yet. CarLook hides those parts by the same rule)
	local on: { [string]: boolean } = {}
	for _, p in (if mech then mech:GetChildren() else {}) do
		local slot = p:GetAttribute("Slot")
		if type(slot) == "string" and p:GetAttribute("State") == "Installed" then
			on[slot] = true
		end
	end
	local function hidden(p: Instance): boolean
		for req in string.gmatch((p:GetAttribute("Requires") :: string?) or "", "[^,]+") do
			if on[req] then
				return true
			end
		end
		return false
	end
	for _, p in (if mech then mech:GetChildren() else {}) do
		if p:GetAttribute("Condition") and (not inBay or zoneOfPart(p) == "EngineBay") and not hidden(p) then
			table.insert(want, p)
		end
	end
	for _, p in (if body then body:GetChildren() else {}) do
		if p:GetAttribute("Checked") and (p:GetAttribute("Condition") :: number) < Config.WarnBelow then
			table.insert(want, p) -- a checked broken hood / bumper stays solid and lights up
		else
			if p:GetAttribute("Condition") then
				table.insert(want, p) -- removable panels can be checked too
			end
			if not faded[p] then
				fade(p) -- Shell, Glass, panels go see-through
			end
		end
	end
	-- checked + worst first, so the broken ones are never the ones cut by the limit
	local function score(p: Instance): number
		return (if p:GetAttribute("Checked") then 0 else 200) + (p:GetAttribute("Condition") :: number)
	end
	table.sort(want, function(a, b)
		return score(a) < score(b)
	end)
	local keep = {}
	for i, p in want do
		if i > MAX_HIGHLIGHTS then
			break
		end
		keep[p] = true
		local h = highlights[p]
		if not h then
			h = Instance.new("Highlight")
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.FillTransparency = 0.45
			h.OutlineTransparency = 0
			h.Adornee = p
			h.Parent = holder
			highlights[p] = h
		end
		if p:GetAttribute("Checked") then
			local col = colorFor(p:GetAttribute("Condition") :: number)
			h.FillColor = col
			h.OutlineColor = col
			h.FillTransparency = 0.45
		else
			h.FillColor = Color3.new(1, 1, 1)
			h.OutlineColor = Color3.new(1, 1, 1)
			h.FillTransparency = 0.9
		end
	end
	for p, h in highlights do
		if not keep[p] then
			h:Destroy()
			highlights[p] = nil
		end
	end
end

function Inspect.setActive(on: boolean)
	if on == active then
		return
	end
	active = on
	if not on then
		clear()
		car = nil
	end
end

-- the car's parts as a clicked ray finds them: a PartKind owner, or nil
local function ownerOf(n: Instance?, cars: Instance): Instance?
	while n and n ~= cars and not n:GetAttribute("PartKind") do
		n = n.Parent
	end
	return if n and n ~= cars then n else nil
end

-- the open engine bay, clicked: the wheel / bumper boxes reach into it (the tyre's top, the bumper's whole width), so a
-- click on the battery or the radiator found "the front tyre" first (user 10-23: "보닛 열면 … 타이어가 제일 먼저 눌림").
-- Hood up (or the engine-bay work view): the engine-bay part whose box covers the pointer wins over a wheel / bumper
-- hit, and over a ray that found nothing; the smallest box wins a tie. `at` is the ray's viewport point.
local function bayPartAt(car: Model, at: Vector2): BasePart?
	local mech = car:FindFirstChild("MechanicalParts")
	local cam = workspace.CurrentCamera
	if not mech or not cam then
		return nil
	end
	local pad = if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then 16 else 6
	local best, bestArea = nil, math.huge
	for _, p in mech:GetChildren() do
		if p:GetAttribute("State") ~= "Installed" or zoneOfPart(p) ~= "EngineBay" then
			continue
		end
		local cf, size
		if p:IsA("Model") then
			cf, size = p:GetBoundingBox()
		elseif p:IsA("BasePart") then
			cf, size = p.CFrame, p.Size
		else
			continue
		end
		local lo, hi, behind = Vector2.new(math.huge, math.huge), Vector2.new(-math.huge, -math.huge), false
		for sx = -1, 1, 2 do
			for sy = -1, 1, 2 do
				for sz = -1, 1, 2 do
					local v = cam:WorldToViewportPoint(cf:PointToWorldSpace(size * 0.5 * Vector3.new(sx, sy, sz)))
					if v.Z <= 0 then
						behind = true
					end
					lo = Vector2.new(math.min(lo.X, v.X), math.min(lo.Y, v.Y))
					hi = Vector2.new(math.max(hi.X, v.X), math.max(hi.Y, v.Y))
				end
			end
		end
		if not behind and at.X >= lo.X - pad and at.X <= hi.X + pad and at.Y >= lo.Y - pad and at.Y <= hi.Y + pad then
			local area = (hi.X - lo.X) * (hi.Y - lo.Y)
			if area < bestArea then
				best, bestArea = p, area
			end
		end
	end
	if not best then
		return nil
	end
	return if best:IsA("BasePart") then best else (best :: Model).PrimaryPart or best:FindFirstChildWhichIsA("BasePart", true)
end

-- click (or tap) a part while scanning: ask the server for a reading
local function onPress(input: InputObject, processed: boolean)
	if processed or not active then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local cars = workspace:FindFirstChild("Cars")
	if not cars then
		return
	end
	local cam = workspace.CurrentCamera
	local at = Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()
	local ray = cam:ViewportPointToRay(at.X, at.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { cars }
	-- see through the shell / glass while scanning: skip hits that aren't repair parts, a few times
	local origin = ray.Origin
	local found: Instance? = nil
	local foundHit: BasePart? = nil
	local inBayNow = car ~= nil and bayMode(car)
	for _ = 1, 6 do
		local hit = workspace:Raycast(origin, ray.Direction * 60, params)
		if not hit then
			break
		end
		local n = ownerOf(hit.Instance, cars)
		-- a wheel box's top lies under the fender: nobody sees it, nothing to click there
		local outOfBay = inBayNow and n ~= nil and n.Parent ~= nil and n.Parent.Name == "MechanicalParts" and zoneOfPart(n) ~= "EngineBay"
		if n and not outOfBay and not (n.Name:sub(1, 6) == "Wheel_" and hit.Normal.Y > 0.5) then
			found, foundHit = n, hit.Instance :: BasePart
			break
		end
		origin = hit.Position + ray.Direction * 0.05
	end
	-- hood up / engine-bay work view: the bay's own part under the pointer beats a wheel / bumper (or nothing) the ray found
	local car: Instance? = found
	if car then
		while car and car.Parent ~= cars do
			car = car.Parent
		end
	else
		-- (a miss: the car whose hood is up — the one the scan is on)
		for _, c in cars:GetChildren() do
			if c:IsA("Model") and c:GetAttribute("HoodOpen") == true then
				car = c
				break
			end
		end
	end
	if car and car:IsA("Model") and (car:GetAttribute("HoodOpen") == true or player:GetAttribute("WorkZone") == "EngineBay") then
		local z = if found then zoneOfPart(found) else nil
		if z ~= "EngineBay" and not (found and found.Name == "Hood") then
			local bay = bayPartAt(car, at)
			if bay then
				Remotes.Check:FireServer(bay)
				return
			end
		end
	end
	if foundHit then
		Remotes.Check:FireServer(foundHit)
	end
end

function Inspect.start()
	UserInputService.InputBegan:Connect(onPress)
	holder = Instance.new("Folder")
	holder.Name = "InspectHighlights"
	holder.Parent = workspace.CurrentCamera
	local acc = 0
	RunService.Heartbeat:Connect(function(dt)
		if not active then
			return
		end
		acc += dt
		if acc >= 0.2 then
			acc = 0
			update()
		end
	end)
end

return Inspect
