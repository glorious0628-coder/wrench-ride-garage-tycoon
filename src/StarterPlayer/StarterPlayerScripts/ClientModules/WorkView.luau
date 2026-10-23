-- The work view on this player's screen (docs/design/work_view.md v0.4): open the hood and the camera comes in over
-- the engine bay; on jack stands, "Work on wheel" brings it down to the wheel. The server decides who is in which
-- zone (WorkService: player attributes WorkCar / WorkZone, the character anchored at the zone's stand) — this moves
-- the camera, reads taps / clicks and calls the same server rules as before:
--   bolts: the wrench (Wrench.luau — hold to turn here)        parts: tap a loose one -> it's in your hands,
--   tap near its empty spot (lit) -> it goes on ('착', the magnet); Cart button -> look at the bay's cart (take a new
--   part / tap the cart to set what you hold on it) -> Cart again to come back. Exit button / Esc / a move key held
--   Config.ExitHoldMove -> out (the zone is remembered by the server only while you're in it).
--   In a wheel's view with the bare hand, dragging spins the wheel (on this screen only) to look round the tread:
--   a nail there, turned to face you, is found (Remotes.Spotted -> the server's clue). A tap = press and let go
--   without dragging.
-- Looks (buttons, glows, the hold ring, Check here, the scan sweep, camera numbers) = wr-ui's WorkViewUI.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Car3D = require(ReplicatedStorage.Shared.PartData.Car3D)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local WorkViewUI = require(script.Parent.WorkViewUI)
local Wrench = require(script.Parent.Wrench)
local Carry = require(script.Parent.Carry)
local JobCard = require(script.Parent.JobCard)
local HUD = require(script.Parent.HUD)

local WorkView = {}

local player = Players.LocalPlayer
local car: Model? = nil
local zone: string? = nil
local cartView = false
local from: CFrame? = nil -- the camera when the move began (blended over WorkCamTween / WorkPeekTween)
local moveStart = 0
local moveTime = Config.WorkCamTween
local lastStage: string? = nil -- the corner's E2 job view (suspStage) the camera is on
local savedFov = 70
local ghost: BasePart? = nil -- the empty spot the held part goes to (lit as "target")
local pointer = Vector2.zero
local moveHeld = 0

function WorkView.zone(): string?
	return zone
end

function WorkView.car(): Model?
	return car
end

function WorkView.cartView(): boolean
	return cartView
end

------------------------------------------------------------------------------------------------------- the spin

-- the wheel of this zone, spun on this screen only (the server's wheel never moves): its parts' CFrames from the
-- axle when the spin began, and the angle now
local spin = { wheel = nil :: Instance?, rel = {} :: { [BasePart]: CFrame }, axle = CFrame.identity, angle = 0, faced = 0 }

local function unspin()
	for p, rel in spin.rel do
		if p.Parent then
			p.CFrame = spin.axle * rel
		end
	end
	spin.wheel, spin.rel, spin.angle, spin.faced = nil, {}, 0, 0
end

local function spinBy(delta: number)
	if not car or not zone then
		return
	end
	local corner = zone:match("^Wheel_(%u%u)$")
	local group = car:FindFirstChild("MechanicalParts")
	local wheel = corner and group and group:FindFirstChild("Wheel_" .. corner)
	if not wheel or wheel:GetAttribute("State") ~= "Installed" then
		return
	end
	if spin.wheel ~= wheel then
		unspin()
		local root = if wheel:IsA("Model") then wheel.PrimaryPart else wheel :: any
		if not root then
			return
		end
		spin.wheel, spin.axle = wheel, (root :: BasePart).CFrame
		for _, d in wheel:GetDescendants() do
			if d:IsA("BasePart") and d.Anchored then -- (the meshes are welded to the root and follow it)
				spin.rel[d] = spin.axle:ToObjectSpace(d.CFrame)
			end
		end
		if wheel:IsA("BasePart") then
			spin.rel[wheel] = CFrame.identity
		end
	end
	spin.angle += delta
	local turn = spin.axle * CFrame.Angles(spin.angle, 0, 0) -- (the wheel's axle runs along its X)
	for p, rel in spin.rel do
		p.CFrame = turn * rel
	end
end

-- the nail facing the camera for a moment = found
local function lookForNail()
	local wheel = spin.wheel
	local nail = wheel and wheel:FindFirstChild("Nail") :: BasePart?
	if not nail or not car or car:GetAttribute("NailFound") then
		return
	end
	-- (the camera looks at the wheel's side: compare in the plane across the axle — the tread turned towards the
	-- camera's side of the wheel, i.e. the top / near edge you can see)
	local cam = workspace.CurrentCamera
	local centre = spin.axle.Position
	local axle = spin.axle.RightVector
	local function across(v: Vector3): Vector3
		local p = v - axle * v:Dot(axle)
		return if p.Magnitude > 1e-4 then p.Unit else Vector3.zero
	end
	local out = across(nail.Position - centre)
	local toCam = across(cam.CFrame.Position - centre)
	if out:Dot(toCam) > 0.75 then
		spin.faced += 1
		if spin.faced >= 6 then
			spin.faced = -1000 -- (once)
			WorkViewUI.glow(nail, "target")
			Remotes.Spotted:FireServer(car, "nail")
		end
	else
		spin.faced = math.max(spin.faced, 0) - (if spin.faced > 0 then 1 else 0)
	end
end

local function carById(id: any): Model?
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:GetAttribute("CarId") == id then
			return c :: Model
		end
	end
	return nil
end

local function bayOf(c: Model): Instance?
	local g = workspace:FindFirstChild("Garage")
	local bays = g and g:FindFirstChild("Bays")
	for _, b in (if bays then bays:GetChildren() else {}) do
		if b:GetAttribute("CarId") == c:GetAttribute("CarId") then
			return b
		end
	end
	return nil
end

-- the bay's cart (the same place WorkService.cartSpot uses)
local function cartAt(c: Model): CFrame?
	local bay = bayOf(c)
	local cart = bay and bay:FindFirstChild("PartsCart", true)
	if cart and cart:IsA("BasePart") then
		return cart.CFrame + Vector3.new(0, cart.Size.Y / 2 + 0.6, 0)
	end
	local spot = bay and bay:FindFirstChild("CarSpot") :: BasePart?
	return spot and spot.CFrame * CFrame.new(-8.6, 0.6, -6.6)
end

------------------------------------------------------------------------------------------------------- camera

-- where the camera sits for this zone now: the car's WorkCam_<zone> attachment when the model has one, else wr-ui's
-- numbers (centre / pitch / yaw / distance / fov, car axes; a wheel's centre is from the wheel's centre)
-- piece E2, a corner with its wheel off: which of the 3D's job views (Generated/<type>Susp `cameras`, suspension_v1
-- camera_hints — the default wheel view looks through the disc at the rear shock nuts and the front knuckle bolts):
-- front = from the back of the well while a bolt down there is still in, then the 3 top nuts with the hood open;
-- rear = the shock's view, or from under the car for the No.2 arm / spring (that job, or the shock already done)
local function installed(c: Model, id: string): Instance?
	local p = c:FindFirstChild(id, true)
	return if p and p:GetAttribute("State") == "Installed" then p else nil
end
local function suspStage(c: Model, z: string): string?
	local corner = z:match("^Wheel_(%u%u)$")
	if not corner or installed(c, "Wheel_" .. corner) then
		return nil
	end
	if corner:sub(1, 1) == "F" then
		local strut = installed(c, "Strut_" .. corner)
		if not strut then
			return nil
		end
		for _, a in strut:GetDescendants() do
			if a:IsA("Attachment") and a.Name:match("^Bolt_%d+$") and not string.find((a:GetAttribute("Requires") :: string?) or "", "Hood:Open", 1, true) then
				local head = strut:FindFirstChild(a.Name .. "_Head", true)
				if head and head:GetAttribute("Tight") == true then
					return "Strut_F"
				end
			end
		end
		return if c:GetAttribute("HoodOpen") == true then "Top_nuts" else "Strut_F"
	end
	if not installed(c, "Shock_" .. corner) and not installed(c, "RearArm2_" .. corner) then
		return nil
	end
	local springJob = c:GetAttribute("Issue_Spring_" .. corner) ~= nil or c:GetAttribute("Issue_RearArm2_" .. corner) ~= nil
	return if springJob or not installed(c, "Shock_" .. corner) then "Spring_R" else "Shock_R"
end

local function zoneCamera(c: Model, z: string): (CFrame, number)
	local cam = (c.PrimaryPart and c.PrimaryPart:FindFirstChild("WorkCam_" .. z)) :: Attachment?
	if cam then
		return cam.WorldCFrame, 50
	end
	local base = (c:GetAttribute("BaseCFrame") :: CFrame?) or c:GetPivot()
	local level = base - base.Position -- (the parked car's heading, kept level even when it's jacked up)
	local pivot = c:GetPivot()
	local corner = z:match("^Wheel_(%u%u)$")
	local cams = (Config :: any).WorkCam or WorkViewUI.Cam -- (wr-ui's numbers: Config.WorkCam when given there)
	local geo = CarParts.work(c:GetAttribute("CarType") :: string?)
	local stage = suspStage(c, z)
	local view = stage and Car3D.susp((c:GetAttribute("CarType") :: string?) or "Sedan").cameras[stage]
	if view and corner then
		-- (car space, the car on the ground — the pivot carries the lift; the 3D's numbers are the left side's)
		local flip = if CarParts.type(c:GetAttribute("CarType") :: string?).WheelCenters[corner].X < 0 then 1 else -1
		local function side(v: Vector3): Vector3
			return Vector3.new(v.X * flip, v.Y, v.Z)
		end
		return CFrame.lookAt(pivot * side(view.eye), pivot * side(view.target)), 50
	end
	local under = geo.under[z] and geo.camera[z]
	if under then
		-- on the creeper: from my face (on the floor) up at the work (on the car, jacked up with it)
		local look = under
		return CFrame.lookAt(base * look.pos, pivot * look.look), (cams.Under and cams.Under.fov) or 60
	end
	local look = cams[if corner then "Wheel" else z] or cams.EngineBay
	local p, yaw, d = math.rad(look.pitch), math.rad(look.yaw or 0), look.distance
	local centre: Vector3
	local offset: Vector3
	if corner then
		local wc = CarParts.type(c:GetAttribute("CarType") :: string?).WheelCenters[corner]
		local side = if wc.X < 0 then -1 else 1
		centre = pivot * (wc + look.centre)
		offset = (CFrame.Angles(0, yaw, 0) * Vector3.new(side * math.cos(p) * d, math.sin(p) * d, 0))
	else
		local own = CarParts.type(c:GetAttribute("CarType") :: string?).workCentre
		centre = pivot * ((own and own[z]) or look.centre)
		offset = (CFrame.Angles(0, yaw, 0) * Vector3.new(0, math.sin(p) * d, -math.cos(p) * d)) -- in front, above
	end
	local eye = centre + level:VectorToWorldSpace(offset)
	return CFrame.lookAt(eye, centre), look.fov or 50
end

-- the cart, seen from where the character stands
local function cartCamera(c: Model): (CFrame?, number)
	local at = cartAt(c)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not at or not root then
		return nil, 55
	end
	-- (wr-ui: a step back from the cart on the character's side, so its whole top fits — from the head it was so close
	-- that a new part sat half off the screen: test 2)
	local flat = (root.Position - at.Position) * Vector3.new(1, 0, 1)
	local away = if flat.Magnitude > 0.1 then flat.Unit else Vector3.new(0, 0, 1)
	local eye = at.Position + away * 5.5 + Vector3.new(0, 3.6, 0)
	return CFrame.lookAt(eye, at.Position), 55
end

local function target(): (CFrame?, number)
	if not car or not zone then
		return nil, savedFov
	end
	if cartView then
		local cf, fov = cartCamera(car)
		if cf then
			return cf, fov
		end
	end
	-- (a corner's job view changed — the knuckle bolts out, up to the top nuts: glide over like any camera move)
	local stage = suspStage(car, zone)
	if stage ~= lastStage then
		if lastStage ~= nil or stage ~= nil then
			from, moveStart = workspace.CurrentCamera.CFrame, os.clock()
		end
		lastStage = stage
	end
	return zoneCamera(car, zone)
end

-- my own character, hidden on my screen while I work (the camera is right where my head would be); others see me
local function hideMe(on: boolean)
	local char = player.Character
	for _, d in (if char then char:GetDescendants() else {}) do
		if d:IsA("BasePart") or d:IsA("Decal") then
			(d :: any).LocalTransparencyModifier = if on then 1 else 0
		end
	end
end

local function startMove(seconds: number)
	local cam = workspace.CurrentCamera
	from = cam.CFrame
	moveStart = os.clock()
	moveTime = seconds
end

------------------------------------------------------------------------------------------------------- in / out

local function enter(c: Model, z: string)
	-- inside a work view nothing outside it asks for attention: every prompt off on this screen (taps do the work)
	game:GetService("ProximityPromptService").Enabled = false
	local cam = workspace.CurrentCamera
	if not zone then
		savedFov = cam.FieldOfView
	end
	car, zone, cartView = c, z, false
	cam.CameraType = Enum.CameraType.Scriptable
	startMove(Config.WorkCamTween)
	WorkViewUI.enter(z, c)
end

local function leave()
	if not zone then
		return
	end
	unspin()
	car, zone, cartView = nil, nil, false
	game:GetService("ProximityPromptService").Enabled = true
	hideMe(false)
	WorkViewUI.exit()
	if ghost then
		ghost:Destroy()
		ghost = nil
	end
	local cam = workspace.CurrentCamera
	cam.FieldOfView = savedFov
	cam.CameraType = Enum.CameraType.Custom
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		cam.CameraSubject = hum
	end
	-- back behind the character, looking the way it faces (wr-play test 1 #9: the camera stayed looking down from
	-- the work view's spot, or behind a shelf). Once, after the camera scripts have taken over again: they keep
	-- turning from wherever the camera points.
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		RunService:BindToRenderStep("WorkViewBack", Enum.RenderPriority.Camera.Value + 1, function()
			RunService:UnbindFromRenderStep("WorkViewBack")
			local look = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
			look = if look.Magnitude > 0.01 then look.Unit else Vector3.new(0, 0, -1)
			local at = root.Position + Vector3.new(0, 1.5, 0)
			cam.CFrame = CFrame.lookAt(at - look * 12 + Vector3.new(0, 4, 0), at)
		end)
	end
end

local function sync()
	local id = player:GetAttribute("WorkCar")
	local z = player:GetAttribute("WorkZone") :: string?
	local c = id and carById(id)
	if c and z then
		if c ~= car or z ~= zone then
			enter(c, z)
		end
	else
		leave()
	end
end

local function exitNow()
	Remotes.WorkExit:FireServer()
end

------------------------------------------------------------------------------------------------------- taps

local function partOf(inst: Instance?): Instance?
	local n = inst
	while n and n ~= workspace and not n:GetAttribute("PartKind") do
		n = n.Parent
	end
	return if n and n ~= workspace then n else nil
end

local function rootOf(part: Instance): BasePart?
	return if part:IsA("Model") then part.PrimaryPart elseif part:IsA("BasePart") then part else nil
end

-- a loose part this zone can take: off this car (popped out / rolled beside it) or on its bay's cart
local function pickable(part: Instance?): boolean
	if not part or not car then
		return false
	end
	-- a part nothing holds (the air filter under its lid, piece E): it lifts straight out of its place
	if part:GetAttribute("State") == "Installed" and part:GetAttribute("BoltCount") == 0 and part:IsDescendantOf(car) then
		return true
	end
	-- a hinged-down arm (E2): a tap lifts it back up
	if part:GetAttribute("State") == "Swung" and part:IsDescendantOf(car) then
		return true
	end
	if part:GetAttribute("State") ~= "Free" then
		return false
	end
	local id = car:GetAttribute("CarId")
	return part:GetAttribute("FromCar") == id or part:GetAttribute("OnCart") == id or part:IsDescendantOf(car)
end

local function under(at: Vector2): Instance?
	local cam = workspace.CurrentCamera
	local ray = cam:ViewportPointToRay(at.X, at.Y)
	local params = RaycastParams.new()
	local ignore = { player.Character } :: { Instance }
	if ghost then
		table.insert(ignore, ghost)
	end
	params.FilterDescendantsInstances = ignore
	params.FilterType = Enum.RaycastFilterType.Exclude
	-- the wheel boxes reach into the engine bay from above (their tops, under the fender): a tap on the bay's parts found
	-- "the front tyre" first (user 10-23). Parts of the OTHER work zone (a wheel while the bay is up, and back) are
	-- looked through, a few times — the same rule Wrench.pick uses for bolts.
	local origin = ray.Origin
	for _ = 1, 6 do
		local hit = workspace:Raycast(origin, ray.Direction * 60, params)
		if not hit then
			return nil
		end
		local part = partOf(hit.Instance)
		local slot = part and part:GetAttribute("Slot")
		local z = if type(slot) == "string" then CarParts.zoneOf(slot) else nil
		local other = z ~= nil and zone ~= nil and z ~= zone and (z == "EngineBay" or z:sub(1, 6) == "Wheel_") and (zone == "EngineBay" or zone:sub(1, 6) == "Wheel_")
		if not other then
			return part
		end
		origin = hit.Position + ray.Direction * 0.05
	end
	return nil
end

-- the empty spot for what I hold nearest to the pointer on screen (within a wide finger range), or nil
local function spotFor(held: Instance, at: Vector2?): (string?, Attachment?)
	if not car or not car.PrimaryPart then
		return nil
	end
	local kind = held:GetAttribute("PartKind")
	local cam = workspace.CurrentCamera
	local best, bestD, bestAtt = nil, math.huge, nil
	for _, a in car.PrimaryPart:GetChildren() do
		if a:IsA("Attachment") and a:GetAttribute("PartKind") == kind then
			local slot = a:GetAttribute("Slot") :: string
			local s = CarParts.Slots[slot]
			local taken = false
			local group = s and car:FindFirstChild(CarParts.Kinds[s.kind].group)
			local inSlot = group and group:FindFirstChild(slot)
			if inSlot and inSlot:GetAttribute("State") == "Installed" then
				taken = true
			end
			if not taken then
				local v, on = cam:WorldToViewportPoint(a.WorldPosition)
				local d = if at then (Vector2.new(v.X, v.Y) - at).Magnitude else 0
				if on and d < bestD and (not at or d <= Config.WorkPickPixels * 2.5) then
					best, bestD, bestAtt = slot, d, a
				end
			end
		end
	end
	return best, bestAtt
end

local quietUntil = 0 -- (just put a part down / on: the same tap must not count again)
local function tap(at: Vector2)
	if not zone or not car or os.clock() < quietUntil then
		return
	end
	local held = Carry.held()
	if held then
		quietUntil = os.clock() + 0.35 -- (test 2 ⑩: a fitted battery's tap came back as a pick — a red "Take off …")
		if cartView then
			Remotes.WorkPlace:FireServer("cart")
			return
		end
		local slot = spotFor(held, at) or spotFor(held, nil)
		if slot then
			Remotes.WorkPlace:FireServer(car, slot)
		end
		return
	end
	-- the wrench / scanner take their own taps on bolts / parts
	local tool = Wrench.active()
	-- a caliper waiting for its piston to go back: a tap on it does it, whatever is in hand (test 1 #4: the wrench
	-- was still out after its bolts and the tap did nothing)
	if zone:sub(1, 6) == "Wheel_" then
		local corner = zone:sub(7)
		local moving = car:FindFirstChild("Moving")
		local cal = moving and moving:FindFirstChild("BrakeCaliper_" .. corner) :: BasePart?
		local prompt = cal and cal:FindFirstChild("PistonPrompt") :: ProximityPrompt?
		if cal and prompt and prompt.Enabled then
			local cam = workspace.CurrentCamera
			local v, on = cam:WorldToViewportPoint(cal.Position)
			if on and (Vector2.new(v.X, v.Y) - at).Magnitude <= Config.WorkPickPixels * 1.5 then
				Remotes.WorkPick:FireServer(cal)
				return
			end
		end
	end
	local part = under(at)
	if pickable(part) and not (tool and part and part:FindFirstChild("Bolt_1_Head", true) and part:GetAttribute("State") == "Installed") then
		Remotes.WorkPick:FireServer(part)
	end
end

------------------------------------------------------------------------------------------------------- frame

local lastGlow = 0
local function frame()
	if not zone or not car then
		return
	end
	if not car.Parent then
		leave()
		return
	end
	local cam = workspace.CurrentCamera
	hideMe(not cartView)
	if spin.wheel and (Wrench.busy() or Carry.held()) then
		unspin() -- (a bolt being turned / a part in hand: the bolts must sit where the server has them)
	end
	if spin.wheel then
		lookForNail()
	end -- (every frame: tools / carried parts come and go; the cart view looks past me anyway)
	if cam.CameraType ~= Enum.CameraType.Scriptable then
		cam.CameraType = Enum.CameraType.Scriptable -- (something set it back: the work view owns the camera)
	end
	local to, fov = target()
	if to then
		local k = math.clamp((os.clock() - moveStart) / moveTime, 0, 1)
		k = k * k * (3 - 2 * k)
		cam.CFrame = if from and k < 1 then from:Lerp(to, k) else to
		cam.FieldOfView = savedFov + (fov - savedFov) * k
	end
	-- a move key held long enough leaves (one press doesn't: work_view 2)
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local moving = hum ~= nil and hum.MoveDirection.Magnitude > 0.5
	for _, key in { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right } do
		moving = moving or UserInputService:IsKeyDown(key)
	end
	if moving and not UserInputService:GetFocusedTextBox() then
		moveHeld = if moveHeld == 0 then os.clock() else moveHeld
		if os.clock() - moveHeld >= Config.ExitHoldMove then
			moveHeld = 0
			exitNow()
		end
	else
		moveHeld = 0
	end
	-- glows (a few times a second): the loose part under the pointer / the spot for what I hold
	if os.clock() - lastGlow < 0.08 then
		return
	end
	lastGlow = os.clock()
	local held = Carry.held()
	if held then
		WorkViewUI.glow(nil, "pickable")
		WorkViewUI.glow(held, "drag")
		local _, att = spotFor(held, pointer)
		if not att then
			_, att = spotFor(held, nil)
		end
		if att and not cartView then
			if not ghost then
				local g = Instance.new("Part")
				g.Name = "WorkTargetGhost"
				g.Anchored = true
				g.CanCollide = false
				g.CanQuery = false
				g.CanTouch = false
				g.Transparency = 0.8
				g.Material = Enum.Material.Neon
				g.Color = Color3.fromRGB(110, 236, 120)
				g.Parent = workspace.CurrentCamera
				ghost = g
			end
			local root = rootOf(held)
			local size = if held:IsA("Model") then held:GetExtentsSize() elseif root then root.Size else Vector3.one
			;(ghost :: BasePart).Size = size
			;(ghost :: BasePart).CFrame = att.WorldCFrame
			WorkViewUI.glow(ghost, "target")
		else
			WorkViewUI.glow(nil, "target")
		end
	else
		WorkViewUI.glow(nil, "drag")
		WorkViewUI.glow(nil, "target")
		if ghost then
			ghost:Destroy()
			ghost = nil
		end
		local part = under(pointer)
		WorkViewUI.glow(if pickable(part) then part else nil, "pickable")
	end
end

function WorkView.start()
	Wrench.workView = function()
		return zone ~= nil
	end
	-- the scan (work_view 2d): the job card's Scan button -> the server -> the zones to check ("Check here");
	-- on a fixed car it's the final check (a check mark where everything is fixed)
	JobCard.Scan.Event:Connect(function(c: Model?)
		if c then
			task.spawn(function()
				local ok, key = Remotes.Scan:InvokeServer(c, c:GetAttribute("Fixed") == true)
				if not ok and key then
					HUD.notify(key, nil, "bad")
				end
			end)
		end
	end)
	Remotes.ScanZones.OnClientEvent:Connect(function(c: Model, list: { { zone: string, ok: boolean } }, final: boolean)
		-- wr-ui's checkHere: a zone name = "Check here" (sky), { zone, ok = true } = the green "Fixed" check
		local zones = {}
		for _, z in list do
			table.insert(zones, if z.ok then { zone = z.zone, ok = true } else z.zone)
		end
		WorkViewUI.checkHere(c, zones :: any)
	end)
	Remotes.Effect.OnClientEvent:Connect(function(name, data)
		if name == "scan" and data and data.car then
			local char = player.Character
			if char and (char:GetPivot().Position - data.car:GetPivot().Position).Magnitude < 40 then
				WorkViewUI.scanSweep(data.car, Config.ScanTime)
			end
		end
	end)
	player:GetAttributeChangedSignal("WorkZone"):Connect(sync)
	player:GetAttributeChangedSignal("WorkCar"):Connect(sync)
	WorkViewUI.Exit.Event:Connect(exitNow)
	-- Lower car from inside (wr-ui's button, only once that end's wheels are on and tight): the same server rule as
	-- the jack's V prompt; in a wheel's view the server then takes you out (the zone needs the stands)
	WorkViewUI.Lower.Event:Connect(function()
		if car then
			Remotes.Jack:FireServer(car, "lower")
		end
	end)
	WorkViewUI.Cart.Event:Connect(function()
		if zone then
			cartView = not cartView
			startMove(Config.WorkPeekTween)
		end
	end)
	local function at(input: InputObject): Vector2
		return Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()
	end
	-- a press: a tap when let go without dragging; a drag in a wheel's view with the bare hand spins the wheel
	local down: Vector2? = nil
	local dragged = false
	UserInputService.InputBegan:Connect(function(input, processed)
		if input.KeyCode == Enum.KeyCode.Escape and zone then
			exitNow()
			return
		end
		if processed or not zone then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pointer = at(input)
			down, dragged = pointer, false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local now = at(input)
			-- (a drag off the bolts spins the wheel whatever tool is in hand — test 2 TOP2: the wrench was out by
			-- itself and the tire wouldn't turn)
			if down and zone and zone:sub(1, 6) == "Wheel_" and not Wrench.busy() and not Carry.held() then
				if (now - down).Magnitude > 8 then
					dragged = true
				end
				if dragged then
					local d = now - pointer
					spinBy((d.Y - d.X) * 0.012)
				end
			end
			pointer = now
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if down and zone and not dragged then
				tap(down)
			end
			down = nil
		end
	end)
	-- Studio play-test hook only: a player attribute DevSpin = radians spins this zone's wheel like a drag would
	if RunService:IsStudio() then
		player:GetAttributeChangedSignal("DevSpin"):Connect(function()
			local by = player:GetAttribute("DevSpin")
			if type(by) == "number" then
				spinBy(by)
			end
		end)
	end
	RunService:BindToRenderStep("WorkView", Enum.RenderPriority.Camera.Value + 1, frame)
	player.CharacterAdded:Connect(function()
		leave()
	end)
	sync()
end

return WorkView
