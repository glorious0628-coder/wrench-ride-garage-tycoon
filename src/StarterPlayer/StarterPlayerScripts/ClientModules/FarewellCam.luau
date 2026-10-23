-- The farewell shot (main's decision 10-22, wr-play: "after the settlement the camera looked at a corner / a wall"):
-- when a job is handed back the camera eases out to the side of the fixed car and follows it as it drives out of the
-- bay, while the settlement card is on screen. Ends by itself after a few seconds, when the car is gone, or the moment
-- the player moves / jumps (the camera is theirs again at once). Never over the work view or a Cinema scene.
-- Server: CustomerService.leave sets the car's Leaving, then fires Remotes.Effect "jobDone" to the job's players.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Cinema = require(script.Parent.Cinema)
local HUD = require(script.Parent.HUD)

local FarewellCam = {}

local player = Players.LocalPlayer
local MAX_SECONDS = 10
local MOVE_GRACE = 0.7 -- (a held walk key from before the hand-back must not cancel it at once)
local SIDE, UP, BACK = 8.5, 3.4, 2.5 -- from the car: beside it, above it, behind its tail (studs)

local running = false

local function myRoot(): BasePart?
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

-- the car that just left: marked Leaving, nearest to me
local function leavingCar(): Model?
	local root = myRoot()
	local cars = workspace:FindFirstChild("Cars")
	if not root or not cars then
		return nil
	end
	local best, bestD = nil, 90
	for _, c in cars:GetChildren() do
		if c:IsA("Model") and c:GetAttribute("Leaving") == true then
			local d = (c:GetPivot().Position - root.Position).Magnitude
			if d < bestD then
				best, bestD = c, d
			end
		end
	end
	return best
end

-- the bay's ApproachSpot (where the car stops after backing out), the one nearest to the car
local function approachOf(car: Model): BasePart?
	local garage = workspace:FindFirstChild("Garage")
	local from = car:GetPivot().Position
	local best, bestD = nil, 60
	for _, d in (if garage then garage:GetDescendants() else {}) do
		if d.Name == "ApproachSpot" and d:IsA("BasePart") then
			local dist = (d.Position - from).Magnitude
			if dist < bestD then
				best, bestD = d, dist
			end
		end
	end
	return best
end

local function run(car: Model)
	running = true
	local cam = workspace.CurrentCamera
	local started = os.clock()
	local startPos = car:GetPivot().Position
	local spot = approachOf(car)
	-- the stage: out in the lot past the bay door, off to one side (the side I was looking from), a little
	-- above — the car backs out toward it and drives off past it. No spot found: beside the car.
	local stage: Vector3
	if spot then
		local out = Vector3.new(spot.Position.X - startPos.X, 0, spot.Position.Z - startPos.Z)
		out = if out.Magnitude > 0.1 then out.Unit else -car:GetPivot().LookVector
		local side = Vector3.yAxis:Cross(out)
		if side:Dot(cam.CFrame.Position - spot.Position) < 0 then
			side = -side
		end
		stage = spot.Position + out * 9 + side * 11 + Vector3.new(0, 4.2, 0)
	else
		local cf = car:GetPivot()
		stage = cf.Position + cf.RightVector * SIDE + cf.LookVector * BACK + Vector3.new(0, UP, 0)
	end
	-- a cut, not a fly-through: the camera would pass through the bay wall on its way out
	local look = startPos + Vector3.new(0, 1.2, 0)
	local pos = stage
	local last = started
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local tapConn: RBXScriptConnection? = nil
	local function stop()
		if not running then
			return
		end
		running = false
		RunService:UnbindFromRenderStep("FarewellCam")
		cam.CameraType = Enum.CameraType.Custom
		cam.FieldOfView = 70
		if tapConn then
			tapConn:Disconnect()
		end
	end
	-- a tap / click on the world ends it (the card stays usable: a tap on a button is "processed" and does not count)
	tapConn = UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and os.clock() - started > 0.5 and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
			stop()
		end
	end)
	cam.CameraType = Enum.CameraType.Scriptable
	RunService:BindToRenderStep("FarewellCam", Enum.RenderPriority.Camera.Value + 9, function()
		local now = os.clock()
		local dt = math.min(now - last, 0.1)
		last = now
		if not car.Parent or now - started > MAX_SECONDS or Cinema.playing() or HUD.gui():GetAttribute("WorkView") then
			stop()
			return
		end
		if hum and now - started > MOVE_GRACE and (hum.MoveDirection.Magnitude > 0.1 or hum.Jump) then
			stop()
			return
		end
		local at = car:GetPivot().Position + Vector3.new(0, 1.2, 0)
		-- never behind a wall: shorten the arm to the first thing between the car's start and the stage
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { car, player.Character :: Instance }
		local want = stage
		local base = startPos + Vector3.new(0, 1.2, 0)
		local hit = workspace:Raycast(base, want - base, params)
		if hit and not spot then
			want = base + (hit.Position - base) * 0.85
		end
		pos = pos:Lerp(want, 1 - math.exp(-dt * 2.5))
		look = look:Lerp(at, 1 - math.exp(-dt * 4))
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = CFrame.lookAt(pos, look)
		cam.FieldOfView = 62
	end)
end

function FarewellCam.start()
	Remotes.Effect.OnClientEvent:Connect(function(name)
		if name ~= "jobDone" or running then
			return
		end
		task.spawn(function()
			task.wait(0.3) -- (the car's Leaving has come over by now; waits a little if not)
			local cam = workspace.CurrentCamera
			if running or Cinema.playing() or HUD.gui():GetAttribute("WorkView") or cam.CameraType ~= Enum.CameraType.Custom then
				return
			end
			local car = leavingCar()
			if car then
				run(car)
			end
		end)
	end)
end

return FarewellCam
