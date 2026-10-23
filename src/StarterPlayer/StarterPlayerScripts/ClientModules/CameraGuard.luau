-- Keeps the camera out of the cars (wr-play test 3 ③-6; wr-builder board 10-22 night ②: not the map — the customer
-- car's shell / glass). Roblox's own camera pops in front of walls, but a car's look is local meshes that don't
-- collide (and its blocks are hidden), so the camera slid inside the body. Each frame, after the camera scripts: if the
-- camera sits inside a nearby car's body box, it comes forward along its line to the character until it's out.
-- The work views drive the camera themselves (Scriptable) and are left alone; a character inside a car's box (on a
-- lift, say) too.
-- Also (wr-play eval TOP 3, 10-23): a car standing BETWEEN the character and the camera — the character at the garage
-- door facing out, the car behind them — filled the screen with its roof / trunk: Roblox's own popper doesn't see the
-- cars' local meshes. The camera now stops at the car's near face, like it does at a wall (never closer than MINDIST).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CameraGuard = {}

local NEAR = 40 -- studs: cars farther than this are skipped
local PAD = 0.35 -- studs the camera stays out from the box
local MINDIST = 3 -- studs: the camera never comes nearer the character than this because of a car
local MAXZOOM = 28 -- studs the player can zoom out (the place default was 400: the camera floated ~34 studs up at the start)

-- each car's body box in its own frame (Body/Shell blocks: hidden on this screen, still the body's shape)
local boxes: { [Model]: { cf: CFrame, half: Vector3 } } = {}

local function boxOf(car: Model): { cf: CFrame, half: Vector3 }?
	local b = boxes[car]
	if b then
		return b
	end
	local body = car:FindFirstChild("Body")
	local shell = body and body:FindFirstChild("Shell")
	if not shell or not shell:IsA("Model") or not car.PrimaryPart then
		return nil
	end
	local cf, size = shell:GetBoundingBox()
	b = { cf = car:GetPivot():ToObjectSpace(cf), half = size / 2 + Vector3.new(PAD, PAD, PAD) }
	boxes[car] = b
	car.Destroying:Once(function()
		boxes[car] = nil
	end)
	return b
end

local function inside(p: Vector3, half: Vector3): boolean
	return math.abs(p.X) < half.X and math.abs(p.Y) < half.Y and math.abs(p.Z) < half.Z
end

-- the avatar goes see-through while the camera is close behind it (a car right behind pulls the camera in: the head filled a
-- third of the screen — main 10-23). Only what this module faded is given back, so Roblox's own near-fade is left alone.
local FADE_NEAR = 4 -- studs from the head: closer than this the avatar is see-through
local FADE = 0.6
local fadedChar: Model? = nil -- the character this module has faded (a new character after a respawn starts clean)

local function fadeAvatar(char: Model, on: boolean)
	if on then
		fadedChar = char -- (every frame while near: a tool / accessory added meanwhile is faded too)
	else
		local was = fadedChar
		fadedChar = nil
		if not was or not was.Parent then
			return
		end
		char = was
	end
	for _, d in char:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
			d.LocalTransparencyModifier = if on then FADE else 0
		end
	end
end

local function guard()
	local cam = workspace.CurrentCamera
	local cars = workspace:FindFirstChild("Cars")
	if not cam or not cars or cam.CameraType == Enum.CameraType.Scriptable then
		local c = Players.LocalPlayer.Character
		if fadedChar and c then
			fadeAvatar(c, false)
		end
		return
	end
	local char = Players.LocalPlayer.Character
	local head = char and char:FindFirstChild("Head") :: BasePart?
	if not head then
		return
	end
	local focus = head.Position
	local pos = cam.CFrame.Position
	for _, car in cars:GetChildren() do
		if not car:IsA("Model") or not car.PrimaryPart then
			continue
		end
		if (car.PrimaryPart.Position - pos).Magnitude > NEAR then
			continue
		end
		local b = boxOf(car)
		if not b then
			continue
		end
		local frame = car:GetPivot() * b.cf
		local hp = frame:PointToObjectSpace(focus)
		if inside(hp, b.half) then
			continue -- (the character is in the box — on a lift: the camera is left to Roblox)
		end
		-- the segment head -> camera against the box (slab method in the box frame): where it first enters, the camera stops
		local cp = frame:PointToObjectSpace(pos)
		local d = cp - hp
		local tIn, tOut = 0, 1
		local hit = true
		for _, axis in { "X", "Y", "Z" } do
			local o, dv, h = (hp :: any)[axis], (d :: any)[axis], (b.half :: any)[axis]
			if math.abs(dv) < 1e-6 then
				if math.abs(o) > h then
					hit = false
					break
				end
			else
				local t1, t2 = (-h - o) / dv, (h - o) / dv
				if t1 > t2 then
					t1, t2 = t2, t1
				end
				tIn, tOut = math.max(tIn, t1), math.min(tOut, t2)
				if tIn > tOut then
					hit = false
					break
				end
			end
		end
		if hit and tIn > 0 and tIn < 1 then
			local full = (pos - focus).Magnitude
			local t = math.max(tIn, math.min(MINDIST / math.max(full, 1e-3), 1))
			pos = focus + (pos - focus) * t
			cam.CFrame = cam.CFrame.Rotation + pos
		end
	end
	-- (a little hysteresis so it doesn't flicker at the edge)
	local near = (cam.CFrame.Position - focus).Magnitude
	if char and (near < FADE_NEAR or (fadedChar == char and near < FADE_NEAR + 0.6)) then
		fadeAvatar(char, true)
	elseif char then
		fadeAvatar(char, false)
	end
end

function CameraGuard.start()
	Players.LocalPlayer.CameraMaxZoomDistance = MAXZOOM
	RunService:BindToRenderStep("WRCameraGuard", Enum.RenderPriority.Camera.Value + 2, function()
		pcall(guard)
	end)
end

return CameraGuard
