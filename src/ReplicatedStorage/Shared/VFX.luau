-- Plays the effects in Shared/VfxPresets (the one table of numbers). Only runs with Config.Features.VfxV2 on; with it
-- off nothing here is called and the old effects stay as they were.
--
--   VFX.burst(name, where, scale?, opts?)   one-shot at a Vector3 / Attachment (opts: color, count, big)
--   VFX.loop(name, attachment, scale?)      a steady / beating effect on an Attachment; returns { stop = fn }
--   VFX.mark(attachment, names, scale?)     (server) tag an Attachment so every client builds its own loops there
--   VFX.watch()                             (client, once) builds loops for tagged Attachments
--   VFX.scaleOf(car)                        effect size for a car (sedan = 1)
--
-- Loops are built on the client, so each screen can run fewer of them: Phone / low graphics get fewer particles and only
-- the nearest few loops run at once (Presets.Quality). `scale` also scales sizes, speeds and fall; light Range is
-- the caller's own.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(script.Parent.Config)
local Presets = require(script.Parent.VfxPresets)

local VFX = {}

local TAG = "VfxLoop"

function VFX.enabled(): boolean
	return Config.feature("VfxV2")
end

-------------------------------------------------------------------------------------------------------------------
-- quality: "low" | "mid" | "high" (the phone / low-graphics step). SavedQualityLevel 1~3 = the player lowered it;
-- Automatic (0) can't be read as a number, so a touch device with a small screen counts as mid.
-------------------------------------------------------------------------------------------------------------------
local qualityName = "high"
local qualityAt = -100

local function readQuality(): string
	local forced = workspace:GetAttribute("VfxQuality")
	if forced == "low" or forced == "mid" or forced == "high" then
		return forced :: string
	end
	if not RunService:IsClient() then
		return "high"
	end
	local level = 0
	pcall(function()
		level = (UserSettings():GetService("UserGameSettings").SavedQualityLevel :: any).Value
	end)
	if level >= 1 and level <= 3 then
		return "low"
	elseif level >= 4 and level <= 6 then
		return "mid"
	elseif level == 0 then
		local cam = workspace.CurrentCamera
		local small = cam ~= nil and math.min(cam.ViewportSize.X, cam.ViewportSize.Y) < 700
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and small then
			return "mid"
		end
	end
	return "high"
end

function VFX.quality(): string
	if os.clock() - qualityAt > 3 then
		qualityAt = os.clock()
		qualityName = readQuality()
	end
	return qualityName
end

local function mult(): number
	return Presets.Quality[VFX.quality()].mult
end

-------------------------------------------------------------------------------------------------------------------
-- building one emitter from a preset
-------------------------------------------------------------------------------------------------------------------
local function colorSeq(c: any): ColorSequence
	if typeof(c) == "Color3" then
		return ColorSequence.new(c)
	end
	return ColorSequence.new((c :: any)[1], (c :: any)[2])
end

local function numberSeq(t: { number }, scale: number): NumberSequence
	if #t == 1 then
		return NumberSequence.new(t[1] * scale)
	elseif #t == 2 then
		return NumberSequence.new(t[1] * scale, t[2] * scale)
	end
	local n = #t
	local keys = {}
	for i, v in t do
		table.insert(keys, NumberSequenceKeypoint.new((i - 1) / (n - 1), v * scale))
	end
	return NumberSequence.new(keys)
end

local function makeEmitter(p: any, scale: number, color: Color3?): ParticleEmitter
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = Presets.Tex[p.texture]
	pe.Color = colorSeq(color or p.color)
	pe.LightEmission = p.light or 0
	pe.LightInfluence = p.lit or (if p.light then 0 else 0.25)
	if p.bright then
		pe.Brightness = p.bright
	end
	if p.zOffset then -- (negative = further from the camera: an outline layer under the star)
		pe.ZOffset = p.zOffset
	end
	pe.Size = numberSeq(p.size, scale)
	pe.Transparency = numberSeq(p.transparency, 1)
	pe.Lifetime = NumberRange.new(p.lifetime[1], p.lifetime[2])
	pe.Speed = NumberRange.new(p.speed[1] * scale, p.speed[2] * scale)
	pe.SpreadAngle = Vector2.new(p.spread, p.spread)
	pe.Acceleration = (p.accel or Vector3.zero) * scale
	pe.Drag = p.drag or 0
	if p.rot then
		pe.Rotation = NumberRange.new(p.rot[1], p.rot[2])
	end
	if p.rotSpeed then
		pe.RotSpeed = NumberRange.new(p.rotSpeed[1], p.rotSpeed[2])
	end
	if p.orient == "VelocityParallel" then
		pe.Orientation = Enum.ParticleOrientation.VelocityParallel
	end
	if p.squash then
		pe.Squash = NumberSequence.new(p.squash)
	end
	if p.dir then
		pe.EmissionDirection = (Enum.NormalId :: any)[p.dir]
	end
	pe.Rate = 0
	pe.Enabled = false
	return pe
end

-------------------------------------------------------------------------------------------------------------------
-- one-shots
-------------------------------------------------------------------------------------------------------------------
local function holderAt(pos: Vector3): (BasePart, Attachment)
	local a = Instance.new("Part")
	a.Anchored = true
	a.CanCollide = false
	a.CanQuery = false
	a.CanTouch = false
	a.CastShadow = false
	a.Transparency = 1
	a.Size = Vector3.one * 0.1
	a.Position = pos
	a.Parent = workspace.CurrentCamera
	local att = Instance.new("Attachment")
	att.Parent = a
	return a, att
end

function VFX.burst(name: string, where: Vector3 | Attachment, scale: number?, opts: { color: Color3?, count: number?, big: boolean? }?)
	local p = (Presets.Effects :: any)[name]
	if not p then
		return
	end
	if p.parts then -- (a bundle: each part on its own, sized by the bundle's scale times the part's)
		for _, part in p.parts do
			local o: any = table.clone(opts or {})
			o.count = part.count or o.count
			if part.delay then
				task.delay(part.delay, function()
					if typeof(where) == "Vector3" or (where :: Instance).Parent then
						VFX.burst(part.name, where, (scale or 1) * (part.scale or 1), o)
					end
				end)
			else
				VFX.burst(part.name, where, (scale or 1) * (part.scale or 1), o)
			end
		end
		return
	end
	scale = scale or 1
	local o = opts or {}
	local holder: BasePart? = nil
	local att: Attachment
	if typeof(where) == "Vector3" then
		holder, att = holderAt(where)
	else
		att = where :: Attachment
	end
	local pe = makeEmitter(p, scale :: number, o.color)
	pe.Parent = att
	local base = o.count or (if o.big and p.countBig then p.countBig else p.count) or 1
	pe:Emit(math.max(1, math.floor(base * mult() + 0.5)))
	task.delay(p.lifetime[2] + 0.4, function()
		if holder then
			holder:Destroy()
		else
			pe:Destroy()
		end
	end)
end

-- One-shots pinned to the SCREEN (the 3D scene is drawn under the GUI, so a sparkle for a result pill must sit around it,
-- not behind it). `spots` = { { x, y (0..1 of the viewport), scale?, delay?, name? } }; each spot is a point `depth` studs in
-- front of the camera, and the effect's scale grows with the depth so it looks the same size on screen at any camera.
function VFX.burstScreen(name: string, spots: { any }, depth: number?)
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	-- (1 stud from the lens: the hood glass, a cart or a wall in front of a deeper spot hides the stars; the scale keeps the look)
	local d = depth or 1.0
	for _, s in spots do
		local function go()
			local c = workspace.CurrentCamera
			if not c then
				return
			end
			local size = c.ViewportSize
			local ray = c:ViewportPointToRay(size.X * s.x, size.Y * s.y)
			-- (the same share of the screen height at any field of view: 70 degrees is what the sizes are tuned at)
			local fovK = math.tan(math.rad(c.FieldOfView / 2)) / math.tan(math.rad(35))
			local sc = (d / 8) * fovK * (s.scale or 1)
			VFX.burst(s.name or name, ray.Origin + ray.Direction * d, sc, if s.count then { count = s.count } else nil)
		end
		if s.delay and s.delay > 0 then
			task.delay(s.delay, go)
		else
			go()
		end
	end
end

-- The same around a GUI rectangle (the result pill), given in viewport pixels { cx, cy, w, h }: see Presets.SparkleAround.
-- A spot is moved back inside the screen when it would fall off it.
function VFX.burstAroundRect(spots: { any }, rect: { cx: number, cy: number, w: number, h: number })
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local vp = cam.ViewportSize
	local out = {}
	for _, s in spots do
		local o = table.clone(s)
		local px = rect.cx + (s.rx or 0) * rect.w / 2 + (s.dx or 0) * vp.Y
		local py = rect.cy + (s.ry or 0) * rect.h / 2 + (s.dy or 0) * vp.Y
		o.x = math.clamp(px / vp.X, 0.1, 0.9)
		o.y = math.clamp(py / vp.Y, 0.14, 0.9)
		table.insert(out, o)
	end
	VFX.burstScreen("sparkle_pop", out)
end

-- a flat ring on the floor that grows and fades (the ripple of a coolant drop on the puddle)
function VFX.ripple(pos: Vector3, name: string, scale: number?)
	local p = (Presets.Effects :: any)[name]
	if not p then
		return
	end
	scale = scale or 1
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(p.size[1] * scale, 0.04, p.size[1] * scale)
	part.Position = pos
	local d = Instance.new("Decal")
	d.Texture = Presets.Tex.ring
	d.Face = Enum.NormalId.Top
	d.Color3 = p.color
	d.Transparency = 0.25
	d.Parent = part
	part.Parent = workspace.CurrentCamera
	local info = TweenInfo.new(p.lifetime[1], Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(part, info, { Size = Vector3.new(p.size[2] * scale, 0.04, p.size[2] * scale) }):Play()
	TweenService:Create(d, info, { Transparency = 1 }):Play()
	task.delay(p.lifetime[1] + 0.1, function()
		part:Destroy()
	end)
end

-------------------------------------------------------------------------------------------------------------------
-- loops: one controller for all of them (one Heartbeat, one sort of "who is nearest" twice a second)
-------------------------------------------------------------------------------------------------------------------
type Loop = {
	name: string,
	p: any,
	src: Attachment,
	swayAtt: Attachment,
	pe: ParticleEmitter,
	scale: number,
	phase: number,
	active: boolean,
	nextAt: number,
	dist: number,
	handle: { stop: () -> () },
}

local loops: { Loop } = {}
local conn: RBXScriptConnection? = nil
local sortedAt = -100

local function stopLoop(l: Loop)
	local i = table.find(loops, l)
	if i then
		table.remove(loops, i)
	end
	if l.swayAtt.Parent then
		l.swayAtt:Destroy()
	end
end

local function drip(l: Loop)
	local origin = l.src.WorldPosition
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore: { Instance } = {}
	local car = l.src:FindFirstAncestorOfClass("Model")
	if car then
		table.insert(ignore, car)
	end
	if workspace.CurrentCamera then
		table.insert(ignore, workspace.CurrentCamera)
	end
	local pf = workspace:FindFirstChild("Puddles")
	if pf then
		table.insert(ignore, pf)
	end
	params.FilterDescendantsInstances = ignore
	local hit = workspace:Raycast(origin, Vector3.new(0, -40, 0), params)
	local floorY = if hit then hit.Position.Y else origin.Y - 2
	local h = math.max(origin.Y - floorY, 0.2)
	local fall = (l.p.drip.fall :: number) * l.scale
	local v0 = (l.p.speed[1] :: number) * l.scale
	local t = (-v0 + math.sqrt(v0 * v0 + 2 * fall * h)) / fall -- (the first push, then it speeds up)
	local at = Vector3.new(origin.X, floorY + 0.06, origin.Z)
	local scale = l.scale
	local hang = (l.p.drip.hang :: number?) or 0
	if hang > 0 then
		VFX.burst("coolant_hang", origin, scale) -- (it swells at the leak, then lets go)
	end
	task.delay(hang, function()
		if not l.src.Parent then
			return
		end
		l.pe.Lifetime = NumberRange.new(t, t)
		l.pe:Emit(1)
		for i = 1, 2 do -- (the pointed top: two smaller drops a moment behind it)
			task.delay(0.03 * i, function()
				if l.src.Parent then
					VFX.burst("coolant_tail", origin, scale)
				end
			end)
		end
		task.delay(t, function()
			VFX.ripple(at, "coolant_ring", scale)
			VFX.burst("coolant_splash", at, scale)
		end)
	end)
end

local function step()
	local now = os.clock()
	local cam = workspace.CurrentCamera
	-- who is on: the nearest few (twice a second), at the current quality
	if now - sortedAt > 0.5 then
		sortedAt = now
		local q = Presets.Quality[VFX.quality()]
		local camPos = if cam then cam.CFrame.Position else Vector3.zero
		for i = #loops, 1, -1 do
			local l = loops[i]
			if not l.src.Parent or not l.src:IsDescendantOf(workspace) then
				stopLoop(l)
			else
				l.dist = (l.src.WorldPosition - camPos).Magnitude
			end
		end
		local order = table.clone(loops)
		table.sort(order, function(a, b)
			return a.dist < b.dist
		end)
		for rank, l in order do
			local on = rank <= q.maxLoops and l.dist < Presets.CullDistance
			l.active = on
			if l.p.rate then
				local car = l.src:FindFirstAncestorOfClass("Model")
				local open = if l.p.hoodOpen and car and car:GetAttribute("HoodOpen") == true then l.p.hoodOpen else 1
				l.pe.Rate = l.p.rate * q.mult * open
				l.pe.Enabled = on
			end
		end
	end
	for _, l in loops do
		if l.active then
			local p = l.p
			if p.sway then
				l.swayAtt.Position = Vector3.new(math.sin(now * p.sway[2] + l.phase) * p.sway[1] * l.scale, 0, 0)
			end
			if now >= l.nextAt then
				if p.pulse then
					local n = math.random(p.pulse.count[1], p.pulse.count[2])
					l.pe:Emit(math.max(1, math.floor(n * mult() + 0.5)))
					l.nextAt = now + p.pulse.every[1] + math.random() * (p.pulse.every[2] - p.pulse.every[1])
				elseif p.drip then
					drip(l)
					l.nextAt = now + p.drip.every[1] + math.random() * (p.drip.every[2] - p.drip.every[1])
				end
			end
		end
	end
	if #loops == 0 and conn then
		conn:Disconnect()
		conn = nil
	end
end

function VFX.loop(name: string, src: Attachment, scale: number?): { stop: () -> () }?
	local p = (Presets.Effects :: any)[name]
	if not p or not (p.rate or p.pulse or p.drip) then
		return nil
	end
	local swayAtt = Instance.new("Attachment")
	swayAtt.Name = "Vfx_" .. name
	local pe = makeEmitter(p, scale or 1)
	pe.Parent = swayAtt
	swayAtt.Parent = src
	local l: Loop
	l = {
		name = name,
		p = p,
		src = src,
		swayAtt = swayAtt,
		pe = pe,
		scale = scale or 1,
		phase = math.random() * 6.28,
		active = false,
		nextAt = os.clock() + math.random() * 0.4,
		dist = 1e9,
		handle = {
			stop = function()
				stopLoop(l)
			end,
		},
	}
	table.insert(loops, l)
	sortedAt = -100 -- pick who is on right away
	if not conn then
		conn = RunService.Heartbeat:Connect(step)
	end
	return l.handle
end

-------------------------------------------------------------------------------------------------------------------
-- sway: a sagging part (the muffler hanging on one rubber) swings a little on the client. The part's look
-- (CarLook's Visual_ clone) is welded to the part with WeldConstraints; they become plain Welds here so the offset
-- can move each frame. Tagged on the server (VFX.markSway).
-------------------------------------------------------------------------------------------------------------------
local SWAY_TAG = "VfxSway"
type Sway = { part: Model, kind: string, welds: { { weld: Weld, c0: CFrame } }, look: Instance?, phase: number }
local sways: { [Model]: Sway } = {}
local swayConn: RBXScriptConnection? = nil

function VFX.markSway(part: Instance, on: boolean, kind: string?)
	if on then
		part:SetAttribute("VfxSwayKind", kind or "muffler")
		CollectionService:AddTag(part, SWAY_TAG)
	else
		CollectionService:RemoveTag(part, SWAY_TAG)
	end
end

local function swayTake(s: Sway)
	local root = s.part.PrimaryPart
	local look: Instance? = nil
	for _, c in s.part:GetChildren() do
		if c.Name:sub(1, 7) == "Visual_" then
			look = c
		end
	end
	if look == s.look or not root then
		return
	end
	s.look = look
	s.welds = {}
	if not look then
		return
	end
	for _, m in look:GetDescendants() do
		if m:IsA("BasePart") then
			for _, w in m:GetChildren() do
				if w:IsA("WeldConstraint") then
					w:Destroy()
				end
			end
			local weld = Instance.new("Weld")
			weld.Part0 = root
			weld.Part1 = m
			local c0 = root.CFrame:ToObjectSpace(m.CFrame)
			weld.C0 = c0
			weld.Parent = m
			table.insert(s.welds, { weld = weld, c0 = c0 })
		end
	end
end

local function swayStep()
	local cam = workspace.CurrentCamera
	local now = os.clock()
	for part, s in sways do
		local cfg = (Presets.Sway :: any)[s.kind]
		local root = part.PrimaryPart
		if not part:IsDescendantOf(workspace) or not root or not cfg then
			continue
		end
		swayTake(s)
		local near = cam ~= nil and (root.Position - cam.CFrame.Position).Magnitude < cfg.within
		local a = if near then math.rad(cfg.deg) * math.sin(now * cfg.speed * 6.28 + s.phase) else 0
		local pv = CFrame.new(cfg.pivot) * CFrame.Angles(0, 0, a) * CFrame.new(-cfg.pivot)
		for _, w in s.welds do
			if w.weld.Parent then
				w.weld.C0 = pv * w.c0
			end
		end
	end
end

local function swayOn(part: Instance)
	if not part:IsA("Model") or sways[part] then
		return
	end
	sways[part] = { part = part, kind = (part:GetAttribute("VfxSwayKind") :: string?) or "muffler", welds = {}, look = nil, phase = math.random() * 6.28 }
	if not swayConn then
		swayConn = RunService.Heartbeat:Connect(swayStep)
	end
end

local function swayOff(part: Instance)
	local s = sways[part :: Model]
	if not s then
		return
	end
	sways[part :: Model] = nil
	for _, w in s.welds do -- (back to where it was)
		if w.weld.Parent then
			w.weld.C0 = w.c0
		end
	end
	if next(sways) == nil and swayConn then
		swayConn:Disconnect()
		swayConn = nil
	end
end

-------------------------------------------------------------------------------------------------------------------
-- tagging: the server marks an Attachment; each client builds the loops itself
-------------------------------------------------------------------------------------------------------------------
function VFX.mark(att: Attachment, names: { string }, scale: number?)
	att:SetAttribute("VfxNames", table.concat(names, ","))
	att:SetAttribute("VfxScale", scale or 1)
	CollectionService:AddTag(att, TAG)
end

local watched = false
local buildTagged: (Instance) -> () = function() end
-- (tuning in Studio: drop every loop and build them again from the tagged Attachments)
function VFX.rebuild()
	for i = #loops, 1, -1 do
		stopLoop(loops[i])
	end
	for _, inst in CollectionService:GetTagged(TAG) do
		buildTagged(inst)
	end
end

function VFX.watch()
	if watched or not RunService:IsClient() then
		return
	end
	watched = true
	local function built(inst: Instance)
		if not inst:IsA("Attachment") then
			return
		end
		local names = inst:GetAttribute("VfxNames")
		if typeof(names) ~= "string" then
			return
		end
		local sc = (inst:GetAttribute("VfxScale") :: number?) or 1
		local handles = {}
		for n in (names :: string):gmatch("[^,]+") do
			local h = VFX.loop(n, inst, sc)
			if h then
				table.insert(handles, h)
			end
		end
		inst.Destroying:Once(function()
			for _, h in handles do
				h.stop()
			end
		end)
	end
	buildTagged = built
	CollectionService:GetInstanceAddedSignal(TAG):Connect(built)
	for _, inst in CollectionService:GetTagged(TAG) do
		built(inst)
	end
	CollectionService:GetInstanceAddedSignal(SWAY_TAG):Connect(swayOn)
	CollectionService:GetInstanceRemovedSignal(SWAY_TAG):Connect(swayOff)
	for _, inst in CollectionService:GetTagged(SWAY_TAG) do
		swayOn(inst)
	end
end

-- effect size for a car: the sedan = 1; the others by length
function VFX.scaleOf(car: Instance?): number
	local ty = car and car:GetAttribute("CarType")
	if ty == "Crossover" or ty == "SUV" then
		return 1.08
	elseif ty == "PumpkinCoach" then
		return 0.9 -- (a short coach: 11.5 studs against the sedan's 16.8)
	elseif ty == "Hatchback" then
		return 0.9
	end
	return 1
end

return VFX
