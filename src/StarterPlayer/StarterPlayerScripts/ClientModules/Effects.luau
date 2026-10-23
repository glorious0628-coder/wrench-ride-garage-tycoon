-- Little feedback from Remotes.Effect: a flash ring on a bolt (bigger kick for the impact wrench), sparks on a
-- wrong battery terminal, a glow on a part that just went on, and their sounds (Shared/Sounds; no id = silent).
-- The moment a fixed car works (proof): the camera leans in a little for the people at the car.

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local HUD = require(script.Parent.HUD)
local JobCard = require(script.Parent.JobCard)
local SoundPlayer = require(script.Parent.SoundPlayer)
local BoltLook = require(script.Parent.BoltLook)
local VFX = require(ReplicatedStorage.Shared.VFX)
local Presets = require(ReplicatedStorage.Shared.VfxPresets)

local Effects = {}

local player = Players.LocalPlayer

local function flash(pos: Vector3, color: Color3, size: number)
	if VFX.enabled() then -- (a small ring, not a glowing ball)
		VFX.burst("bolt_ring", pos, size, { color = color })
		return
	end
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Size = Vector3.one * 0.2
	p.Position = pos
	p.Parent = workspace.CurrentCamera
	TweenService:Create(p, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * size, Transparency = 1 }):Play()
	task.delay(0.25, function()
		p:Destroy()
	end)
end

local function sparks(pos: Vector3)
	if VFX.enabled() then -- (a real terminal spark is small: one zap and a few streaks)
		VFX.burst("terminal_zap", pos)
		VFX.burst("terminal_spark", pos)
		return
	end
	local a = Instance.new("Part")
	a.Anchored = true
	a.CanCollide = false
	a.CanQuery = false
	a.Transparency = 1
	a.Size = Vector3.one * 0.1
	a.Position = pos
	a.Parent = workspace.CurrentCamera
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Color = ColorSequence.new(Color3.fromRGB(255, 220, 120))
	pe.LightEmission = 1
	pe.Speed = NumberRange.new(6, 12)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Lifetime = NumberRange.new(0.2, 0.45)
	pe.Size = NumberSequence.new(0.25, 0)
	pe.Acceleration = Vector3.new(0, -30, 0)
	pe.Rate = 0
	pe.Parent = a
	pe:Emit(28)
	task.delay(0.8, function()
		a:Destroy()
	end)
end

local function glow(part: Instance)
	local h = Instance.new("Highlight")
	h.FillColor = Color3.fromRGB(120, 255, 160)
	h.OutlineColor = h.FillColor
	h.FillTransparency = 0.4
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Adornee = part
	h.Parent = workspace.CurrentCamera
	TweenService:Create(h, TweenInfo.new(0.6), { FillTransparency = 1, OutlineTransparency = 1 }):Play()
	task.delay(0.65, function()
		h:Destroy()
	end)
end

-- an old part left lying went to the scrap pile: a small grey puff of dust where it was
local function puff(pos: Vector3)
	if VFX.enabled() then
		VFX.burst("scrap_puff", pos)
		VFX.burst("scrap_dust", pos)
		return
	end
	local a = Instance.new("Part")
	a.Anchored = true
	a.CanCollide = false
	a.CanQuery = false
	a.Transparency = 1
	a.Size = Vector3.one * 0.1
	a.Position = pos
	a.Parent = workspace.CurrentCamera
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(Color3.fromRGB(185, 180, 170))
	pe.Speed = NumberRange.new(1, 3)
	pe.SpreadAngle = Vector2.new(180, 30)
	pe.Lifetime = NumberRange.new(0.5, 0.9)
	pe.Size = NumberSequence.new(0.8, 2)
	pe.Transparency = NumberSequence.new(0.4, 1)
	pe.Rate = 0
	pe.Parent = a
	pe:Emit(10)
	task.delay(1.5, function()
		a:Destroy()
	end)
end

-- a running engine: a puff of exhaust and the headlights flashing twice
local function carStart(car: Model, big: boolean?)
	if not car or not car.Parent then
		return
	end
	local tail = (car:GetPivot() * CFrame.new(1.2, 0.75, 8.8)).Position
	if VFX.enabled() then
		VFX.burst("engine_start", tail, VFX.scaleOf(car), { big = big })
	else
		local a = Instance.new("Part")
		a.Anchored = true
		a.CanCollide = false
		a.CanQuery = false
		a.Transparency = 1
		a.Size = Vector3.one * 0.1
		a.Position = tail
		a.Parent = workspace.CurrentCamera
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
		pe.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
		pe.Speed = NumberRange.new(3, 6)
		pe.SpreadAngle = Vector2.new(20, 20)
		pe.Lifetime = NumberRange.new(0.8, 1.4)
		pe.Size = NumberSequence.new(0.6, 2.4)
		pe.Transparency = NumberSequence.new(0.3, 1)
		pe.Rate = 0
		pe.Parent = a
		pe:Emit(if big then 30 else 14)
		task.delay(2, function()
			a:Destroy()
		end)
	end
	SoundPlayer.play("engineStart", tail)
	-- the headlights come on (light from the lamp spots: the 3D shell has no emissive lamps yet)
	for _, x in { -2.6, 2.6 } do
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Transparency = 1
		p.Size = Vector3.one * 0.2
		p.CFrame = car:GetPivot() * CFrame.new(x, 3.3, -8.3)
		local l = Instance.new("SpotLight")
		l.Face = Enum.NormalId.Front
		l.Angle = 70
		l.Range = 18
		l.Brightness = 5
		l.Color = Color3.fromRGB(255, 248, 225)
		l.Parent = p
		local glow = Instance.new("PointLight")
		glow.Range = 3
		glow.Brightness = 3
		glow.Color = l.Color
		glow.Parent = p
		p.Parent = workspace.CurrentCamera
		task.delay(if big then 3.5 else 2.5, function()
			p:Destroy()
		end)
	end
end

-- "it works now" before the pay: the old symptom, a short pause, then it's gone (and the car starts)
local ENGINE = { Battery = true, Radiator = true, Muffler = true }
-- lean in: the field of view narrows a little and eases back (only near the car; the camera itself isn't moved)
local function leanIn(car: Model)
	local char = player.Character
	local cam = workspace.CurrentCamera
	if not char or not cam or (char:GetPivot().Position - car:GetPivot().Position).Magnitude > 35 then
		return
	end
	local fov = cam.FieldOfView
	TweenService:Create(cam, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = fov - 8 }):Play()
	task.delay(0.9, function()
		TweenService:Create(cam, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = fov }):Play()
	end)
end

local function proof(car: Model, kind: string)
	task.spawn(function()
		JobCard.compare("before", kind)
		task.wait(1.1)
		leanIn(car)
		if ENGINE[kind] then
			carStart(car, true)
			JobCard.compare("after", kind, true) -- (the engine is already heard from the car)
		elseif kind == "BrakePads" and HUD.proof then
			HUD.proof("ui.proof.brakeQuiet") -- (the quiet brakes have no sound: the check says it)
		else
			JobCard.compare("after", kind)
		end
	end)
end

-- "뾰로롱": a mini-game that ends well sparkles where the work was (Features.VfxSparkle). Perfect = the big one + its
-- sound; a plain success = a small one; Auto / failure = nothing. The 2D words and the pill on the screen are wr-ui's.
local function sparkleSpot(kind: string?, at: any): Vector3?
	if typeof(at) == "Vector3" then -- (the server says where the work was: Scrub, Polish, Tire, Coolant, Torque all sparkle in place)
		return at + Vector3.new(0, 1.2, 0)
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if kind == "Scrub" then -- (the battery just cleaned: the nearest one on a car)
		local cars = workspace:FindFirstChild("Cars")
		local best: Vector3? = nil
		local bestD = 40
		for _, car in if cars then cars:GetChildren() else {} do
			local mp = car:FindFirstChild("MechanicalParts")
			local b = mp and mp:FindFirstChild("Battery")
			local part = if b and b:IsA("Model") then b.PrimaryPart elseif b and b:IsA("BasePart") then b else nil
			if part and root and (part.Position - root.Position).Magnitude < bestD then
				bestD = (part.Position - root.Position).Magnitude
				best = part.Position + Vector3.new(0, 1.5, 0)
			end
		end
		if best then
			return best
		end
	end
	if root then -- (the balancer: the wheel is held in front of the player)
		return root.Position + root.CFrame.LookVector * 2.5 + Vector3.new(0, 2.2, 0)
	end
	return nil
end

-- where the mini-game's green result pill is on the screen, in viewport pixels (nil when none is showing)
local function pillRect(): { cx: number, cy: number, w: number, h: number }?
	local pg = player:FindFirstChildOfClass("PlayerGui")
	if not pg then
		return nil
	end
	for _, o in pg:GetDescendants() do
		if o:IsA("Frame") and o.Visible and o.Name:sub(-6) == "Result" and o.AbsoluteSize.X > 120 and o.AbsoluteSize.Y > 30 then
			local gui = o:FindFirstAncestorOfClass("ScreenGui")
			local inset = if gui and not gui.IgnoreGuiInset then GuiService:GetGuiInset().Y else 0
			return {
				cx = o.AbsolutePosition.X + o.AbsoluteSize.X / 2,
				cy = o.AbsolutePosition.Y + inset + o.AbsoluteSize.Y / 2,
				w = o.AbsoluteSize.X,
				h = o.AbsoluteSize.Y,
			}
		end
	end
	return nil
end

local function onMinigame(what: any, data: any)
	if not Config.feature("VfxSparkle") or type(data) ~= "table" then
		return
	end
	local grade: string? = nil
	if what == "done" and not data.auto then
		grade = data.grade
	elseif what == "scrubResult" then
		grade = if data.result == "perfect" then "Perfect" elseif data.result == "good" then "Good" else nil
	end
	if grade ~= "Perfect" and grade ~= "Good" then
		return
	end
	local at = sparkleSpot(data.kind, data.at)
	if not at then
		return
	end
	VFX.burst(if grade == "Perfect" then "Sparkle_Perfect" else "Sparkle_Small", at)
	-- the result pill (a GUI, drawn over the 3D) hides what is behind it: the stars that must be seen go above and
	-- beside it, on the screen, where the pill really is (it sits at a different height in each mini-game). The
	-- mini-game's own module shows the pill from this same event, so look for it a moment later.
	local kind = if grade == "Perfect" then "Perfect" else "Good"
	task.delay(0.05, function()
		local rect = pillRect()
		if rect then
			VFX.burstAroundRect((Presets.SparkleAround :: any)[kind], rect)
		else
			VFX.burstScreen("sparkle_pop", (Presets.SparkleScreen :: any)[kind])
		end
	end)
	if grade == "Perfect" then
		SoundPlayer.play("sparkle", at)
	end
end

local motors: { [Instance]: { stop: () -> () } } = {} -- a lift's running motor sound
local lastImpact = 0

-- a tiny camera kick for my own impact wrench
local function kick()
	local cam = workspace.CurrentCamera
	local angle = math.rad(0.35)
	cam.CFrame = cam.CFrame * CFrame.Angles(angle * (math.random() - 0.5), angle * (math.random() - 0.5), 0)
end

-- the floor jack's pump: one "thunk" per stroke while a car is being jacked up. The server only moves the car's
-- LiftOffset (JackService.pump, Config.JackPumpTime of it) — this watches it on every screen and plays jackPump each
-- time the car has risen another third of the way, starting with the first push
local JACK_STROKES = 3
local jackSeen: { [Model]: number } = {}
local function jackSounds()
	local cars = workspace:FindFirstChild("Cars")
	if not cars then
		return
	end
	for _, car in cars:GetChildren() do
		if car:IsA("Model") then
			local h = (car:GetAttribute("LiftOffset") :: number?) or 0
			local before = jackSeen[car]
			jackSeen[car] = h
			if before and h > before and tostring(car:GetAttribute("Support") or ""):sub(1, 4) == "Jack" then
				local top = Config.StandHeight
				local a = math.ceil(before / top * JACK_STROKES - 1e-6)
				local b = math.ceil(h / top * JACK_STROKES - 1e-6)
				if (before <= 0 and h > 0) or b > a then
					SoundPlayer.play("jackPump", car:GetPivot().Position)
				end
			end
		end
	end
end

function Effects.start()
	VFX.watch() -- (loops the server marked: steam, drip, muffler puffs — they only build with Features.VfxV2 on)
	task.spawn(function()
		while true do
			task.wait(0.1)
			pcall(jackSounds)
		end
	end)
	Remotes.Minigame.OnClientEvent:Connect(onMinigame)
	Remotes.Effect.OnClientEvent:Connect(function(name, data)
		if name == "bolt" and data and data.bolt then
			local loosen = data.loosen
			BoltLook.turn(data.bolt, loosen == true, data.tool) -- (it turns out / in, A③)
			flash(data.bolt.Position, if loosen then Color3.fromRGB(255, 200, 80) else Color3.fromRGB(120, 210, 255), if data.tool == "ImpactWrench" then 1.1 else 0.8)
			if data.tool == "ImpactWrench" and player.Character and (player.Character:GetPivot().Position - data.bolt.Position).Magnitude < 10 then
				kick()
			end
			-- tool sounds (the impact wrench sweeps a nut every 0.09 s: one burst per 0.2 s is enough)
			if data.tool == "ImpactWrench" and data.last then
				SoundPlayer.play("impactBurst", data.bolt.Position) -- the last nut snugs down
			elseif data.tool == "ImpactWrench" and os.clock() - lastImpact > 0.2 then
				lastImpact = os.clock()
				SoundPlayer.play("impact", data.bolt.Position)
			elseif data.tool == "RatchetWrench" then
				SoundPlayer.play("ratchet", data.bolt.Position)
			elseif data.tool == "Wrench" then
				SoundPlayer.play(if loosen then "wrench" else "wrenchTighten", data.bolt.Position)
			end
		elseif name == "partOut" and data and data.part and data.from then
			BoltLook.partOut(data.part, data.from) -- (it slides out of its spot, A③ 3)
		elseif name == "clank" and data then
			SoundPlayer.play("clank", data.pos)
		elseif name == "hood" and data and data.car then
			SoundPlayer.play(if data.open then "hoodOpen" else "hoodClose", (data.car:GetPivot() * CFrame.new(0, 4, -6)).Position)
			if data.part and data.from then
				BoltLook.swing(data.part, data.from) -- (on its hinge, A③ 5)
			end
		elseif name == "coffee" and data and typeof(data.pos) == "Vector3" then -- (a coffee handed over: one small sparkle, no sound)
			local char = player.Character
			if Config.feature("VfxSparkle") and char and (char:GetPivot().Position - data.pos).Magnitude < 60 then
				VFX.burst("Sparkle_Small", data.pos)
			end
		elseif name == "sfx" and data then -- (a sound at a spot: deskBell, liftLock ...)
			SoundPlayer.play(data.sound, data.pos)
		elseif name == "liftMotor" and data and data.bay then
			local old = motors[data.bay]
			local lift = data.bay:FindFirstChild("Lift")
			local at = lift and lift:FindFirstChild("Control")
			if old then
				old.stop()
				motors[data.bay] = nil
				if not data.on and at and at:IsA("PVInstance") then
					SoundPlayer.play("liftLock", (at :: PVInstance):GetPivot().Position) -- (it stops and locks at the height)
				end
			end
			if data.on and at and at:IsA("PVInstance") then
				motors[data.bay] = SoundPlayer.loop("liftMotor", (at :: PVInstance):GetPivot().Position) :: any
			end
		elseif name == "spark" and data then
			sparks(data.pos)
			SoundPlayer.play("spark", data.pos)
		elseif name == "install" and data and data.part then
			glow(data.part)
			local root = if data.part:IsA("Model") then data.part.PrimaryPart else data.part
			SoundPlayer.play("install", if root and root:IsA("BasePart") then root.Position else nil)
		elseif name == "partDrop" and data then
			SoundPlayer.play("partDrop", data.pos)
		elseif name == "puff" and data and data.pos then
			puff(data.pos)
		elseif name == "clue" and data then
			-- a clue: the line on screen (for people near the car), its sound, a little ring where it came from
			local char = player.Character
			if char and data.pos and (char:GetPivot().Position - data.pos).Magnitude < 40 then
				-- a fixed brake job gone quiet: no sound on purpose (user), a green check instead of the plain notice
				if data.key == "clue.brake.ok" and data.car and data.car:GetAttribute("Fixed") == true and HUD.proof then
					HUD.proof("ui.proof.brakeQuiet")
				else
					HUD.notify(data.key, data.args, "info")
				end
				SoundPlayer.play(data.sound, data.pos)
				-- (a smaller ring: the old 3-stud blue one by the coolant tank read as "a blue water drop" — wr-play 10-23)
				flash(data.pos, Color3.fromRGB(120, 200, 255), if data.quiet then 1.0 else 1.6)
			end
		elseif name == "carStart" and data then
			carStart(data.car, data.big)
		elseif name == "proof" and data and data.car then
			proof(data.car, data.kind)
		elseif name == "jobDone" and data then
			JobCard.banner(data)
		end
	end)
end

return Effects
