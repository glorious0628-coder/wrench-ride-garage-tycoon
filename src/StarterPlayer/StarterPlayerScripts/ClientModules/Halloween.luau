-- Halloween on this screen (halloween_pumpkin.md §5b; the server's HalloweenService runs the story): the camera scenes
-- — arrive, leave (+ the slipper on the shelf), midnight at the street end, then the trophy card in the morning —
-- as cuts from fixed spots, and the pop. The screen around a scene (bars, Ella's subtitle, the clock chip, "Tap to
-- skip") is wr-ui's Cinema; the job card shows the midnight clock (the car's "Midnight"). Scenes take the camera only
-- from people outside a work view; the first time they play through, after that a tap skips (only this camera).
-- Camera spots: the map's markers — CinemaCam_Street / _Door from the bay Ella's car is in (each bay has its own),
-- Cinema.CinemaCam_Shelf / _StreetEnd — else worked out from the bay. The owner who just got the slipper keeps the
-- midnight scene's bars for the trophy card (one scene, no bars out and back in).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Modules = script.Parent
local Cinema = require(Modules.Cinema)
local TrophyCard = require(Modules.TrophyCard)
local SoundPlayer = require(Modules.SoundPlayer)
local Music = require(Modules.Music)

local Halloween = {}

local player = Players.LocalPlayer
local BELLS = Config.Halloween.bells -- (the server pops the coach when they end)

type Cut = { t: number, pos: () -> Vector3, look: () -> Vector3, sound: string?, say: string?, clock: number? }

local playing = 0 -- the scene token (a newer scene / a skip ends the one running)
local inScene = false
local held: "wait" | "card" | nil = nil -- the midnight scene's bars kept up for the trophy card
local watched: { [string]: boolean } = {}
local night: { stop: (fade: number?) -> () }? = nil

local function garage(): Instance?
	return workspace:FindFirstChild("Garage")
end

-- a camera marker: the one in this bay first (Bays.BayN.CinemaCam_Door), else the first in the garage
local function marker(name: string, bay: Instance?): Vector3?
	local g = garage()
	local m = (bay and bay:FindFirstChild(name, true)) or (g and g:FindFirstChild(name, true))
	return if m and m:IsA("BasePart") then m.Position else nil
end

local function bayPoint(bay: Instance?, name: string): Vector3?
	local m = bay and bay:FindFirstChild(name)
	return if m and m:IsA("BasePart") then m.Position else nil
end

local function ellaCar(): Model?
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:GetAttribute("CustomerKind") == "Ella" then
			return c :: Model
		end
	end
	return nil
end

local function controls(on: boolean)
	local ok, pm = pcall(function()
		return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule") :: any)
	end)
	if ok and pm then
		local c = pm:GetControls()
		if on then
			c:Enable()
		else
			c:Disable()
		end
	end
end

-- run the cuts on this camera (nil if this screen sits it out)
local function inWork(): boolean
	return player:GetAttribute("WorkZone") ~= nil or player:GetAttribute("WorkCar") ~= nil
end

-- the bars down, the camera and the controls back
local function endScene()
	held = nil
	inScene = false
	Music.dim("scene", nil)
	Cinema.stop()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	controls(true)
end

-- keep: the bars stay up at the end (the trophy card comes next inside them — trophy())
local function play(name: string, cuts: { Cut }, keep: boolean?)
	if inWork() then
		return -- (in a work view: the scene doesn't take the screen — the sky still changes)
	end
	if held then
		endScene() -- (bars kept for a card that never came: a fresh scene starts clean)
	end
	playing += 1
	local my = playing
	local cam = workspace.CurrentCamera
	inScene = true
	Music.dim("scene", 0.5) -- (the night waltz under the scene: 0.2 -> 0.1; at midnight it's cut anyway)
	Cinema.play({ canSkip = player:GetAttribute("EllaSeen") == true })
	controls(false)
	cam.CameraType = Enum.CameraType.Scriptable
	local skipped = false
	local tap = Cinema.Skipped.Event:Connect(function()
		skipped = true
	end)
	for i, cut in cuts do
		if playing ~= my or skipped then
			break
		end
		SoundPlayer.play(cut.sound)
		if cut.say then
			Cinema.say(cut.say, nil, "npc.Ella")
		end
		if cut.clock then
			Cinema.clock(cut.clock)
		end
		local t0 = os.clock()
		local blendFrom = cam.CFrame
		while os.clock() - t0 < cut.t and playing == my and not skipped do
			local want = CFrame.lookAt(cut.pos(), cut.look())
			local k = math.min(1, (os.clock() - t0) / 0.2) -- (0.2 s blend between cuts)
			cam.CFrame = if i == 1 then want else blendFrom:Lerp(want, k)
			RunService.RenderStepped:Wait()
		end
	end
	tap:Disconnect()
	if playing == my then
		if not skipped then
			watched[name] = true
			if watched.arrive and watched.leave and watched.midnight and not player:GetAttribute("EllaSeen") then
				Remotes.Cinema:FireServer("seen")
			end
		end
		if keep then
			held = "wait"
			task.delay(8, function()
				if held == "wait" and playing == my then
					endScene() -- (the morning never came: don't sit in the bars)
				end
			end)
		else
			endScene()
		end
	end
end

-- ① arrive: the street with the sign, the coach rolling in, Ella at the door
local function arrive(bay: Instance)
	local spot = bayPoint(bay, "CarSpot") or Vector3.zero
	local approach = bayPoint(bay, "ApproachSpot") or spot
	local out = (approach - spot)
	out = if out.Magnitude > 0.1 then out.Unit else Vector3.new(0, 0, -1)
	local street = marker("CinemaCam_Street", bay) or (approach + out * 24 + Vector3.new(0, 7, 0))
	local door = marker("CinemaCam_Door", bay) or (bayPoint(bay, "DriverExitSpot") or spot) + out * 4 + Vector3.new(0, 4, 0)
	local function car(): Vector3
		local c = ellaCar()
		return if c then c:GetPivot().Position + Vector3.new(0, 2, 0) else spot
	end
	SoundPlayer.play("neonOn")
	-- the coach's sparkle trail while it rolls in, fading out (0.3 s) as it stops
	task.spawn(function()
		local trail = SoundPlayer.loop("sparkleTrail")
		local t0 = os.clock()
		while trail and os.clock() - t0 < 15 do
			local c = ellaCar()
			if c and c:GetAttribute("Parked") then
				break
			end
			task.wait(0.1)
		end
		if trail then
			trail.stop(0.3)
		end
	end)
	play("arrive", {
		{ t = 1.5, pos = function() return street end, look = function() return spot + Vector3.new(0, 6, 0) end },
		{ t = 2.4, pos = function() return street end, look = car, sound = "coachRoll" },
		{ t = 1.6, pos = function() return door end, look = function() return (bayPoint(bay, "DriverExitSpot") or spot) + Vector3.new(0, 2.5, 0) end, sound = "slipperDing", say = (function()
			local c = ellaCar()
			return c and c:GetAttribute("SayHello") or "ella.hello.1"
		end)() },
	})
end

-- ③ leave: bright lights first, Ella cheering, then the slipper on the shelf
local function leave(car: Model, bay: Instance?)
	local spot = bayPoint(bay, "CarSpot") or car:GetPivot().Position
	local approach = bayPoint(bay, "ApproachSpot") or spot
	local out = (approach - spot)
	out = if out.Magnitude > 0.1 then out.Unit else Vector3.new(0, 0, -1)
	local door = marker("CinemaCam_Door", bay) or (approach + out * 3 + Vector3.new(4, 4, 0))
	local function carAt(): Vector3
		return if car.Parent then car:GetPivot().Position + Vector3.new(0, 2, 0) else approach
	end
	local function slipperAt(): Vector3
		local s = workspace:FindFirstChild("GlassSlipperTrophy", true)
		return if s and s:IsA("PVInstance") then s:GetPivot().Position else spot
	end
	local shelf = marker("CinemaCam_Shelf")
	play("leave", {
		{ t = 1.5, pos = function() return door end, look = carAt },
		{ t = 2.0, pos = function() return door + Vector3.new(0, 1, 0) end, look = carAt, sound = "ellaCheer", say = "ella.good.1" },
		{ t = 1.5, pos = function() return shelf or (slipperAt() + Vector3.new(2.5, 1.4, 2.5)) end, look = slipperAt, sound = "slipperDing" },
	})
end

-- ② midnight at the street end: the bells (~3 s: bell12), the pop, the pumpkin rolling off. keep = the trophy card
-- comes next for this screen (the bars stay)
local function midnight(pos: Vector3, keep: boolean)
	local g = garage()
	local home = if g and g:IsA("Model") then g:GetPivot().Position else Vector3.zero
	local back = Vector3.new(home.X - pos.X, 0, home.Z - pos.Z)
	back = if back.Magnitude > 0.1 then back.Unit else Vector3.new(0, 0, 1)
	local camAt = marker("CinemaCam_StreetEnd") or (pos + back * 16 + Vector3.new(0, 5, 0))
	local function target(): Vector3
		local b = workspace:FindFirstChild("BigPumpkin")
		return if b and b:IsA("PVInstance") then b:GetPivot().Position else pos + Vector3.new(0, 2, 0)
	end
	play("midnight", {
		{ t = BELLS, pos = function() return camAt end, look = target, sound = "bell12", clock = 60 },
		{ t = 2.2, pos = function() return camAt:Lerp(target(), 0.15) end, look = target, sound = "pumpkinRoll", say = "ella.home" },
	}, keep)
end

-- the pop: a puff of white and orange
local function pop(pos: Vector3)
	SoundPlayer.play("pumpkinPop", pos)
	for i = 1, 10 do
		local p = Instance.new("Part")
		p.Shape = Enum.PartType.Ball
		p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, false, false, false
		p.Material = Enum.Material.Neon
		p.Color = if i % 2 == 0 then Color3.fromRGB(255, 160, 70) else Color3.fromRGB(255, 245, 235)
		p.Size = Vector3.one * 1.5
		local dir = Vector3.new(math.random() - 0.5, math.random() * 0.8, math.random() - 0.5)
		p.Position = pos + dir
		p.Parent = workspace.CurrentCamera
		local tw = TweenService:Create(p, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.one * 5,
			Position = pos + dir * 4,
			Transparency = 1,
		})
		tw.Completed:Once(function()
			p:Destroy()
		end)
		tw:Play()
	end
end

-- morning: the owner who just got the glass slipper sees the trophy card — the last beat, inside the midnight
-- scene's bars (kept up for it); if that scene didn't play here, in bars of its own
local function trophy()
	local t0 = os.clock()
	while inScene and not held and os.clock() - t0 < 8 do -- (the midnight scene finishes first)
		task.wait(0.1)
	end
	if held then
		held = "card"
		TrophyCard.show("GlassSlipper")
		TrophyCard.Closed.Event:Wait()
		endScene()
		return
	end
	if inWork() then
		return
	end
	task.wait(0.35) -- (its bars are on their way out)
	Cinema.play({ canSkip = false })
	TrophyCard.show("GlassSlipper")
	TrophyCard.Closed.Event:Wait()
	Cinema.stop()
end

function Halloween.start()
	Remotes.Cinema.OnClientEvent:Connect(function(scene: string, data: { [string]: any })
		data = data or {}
		if scene == "arrive" and data.bay then
			if not night then
				night = SoundPlayer.loop("nightAmb") -- (flat: the camera travels between scenes)
			end
			task.spawn(arrive, data.bay)
		elseif scene == "leave" and data.car then
			task.spawn(leave, data.car, data.bay)
		elseif scene == "midnight" and data.pos then
			task.spawn(midnight, data.pos, data.trophy == player.UserId)
		elseif scene == "morning" then
			if night then
				night.stop(1)
				night = nil
			end
			SoundPlayer.play("morningBird")
			if data.trophy == player.UserId then
				task.spawn(trophy)
			end
		end
	end)
	Remotes.Effect.OnClientEvent:Connect(function(name: string, data: any)
		if name == "ellaPop" and data and data.pos then
			pop(data.pos)
		end
	end)
end

return Halloween
