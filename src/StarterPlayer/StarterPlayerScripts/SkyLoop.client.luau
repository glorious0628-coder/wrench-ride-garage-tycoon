--!strict
-- SkyLoop (wr-builder, looks only): moves the Gearport SkyLoop train on this client — a short shuttle between
-- workspace.Garage.Town.SkyLoop.StopWest and StopEast: wait at a station, ease out, cruise, ease in, wait, back.
-- No game rule, nothing to ride; the server copy of the train just stays at StopWest. Map: World/GearportSkyLoop.
-- If the map / train isn't there (e.g. streamed out), it quietly does nothing.

local RunService = game:GetService("RunService")

local garage = workspace:WaitForChild("Garage", 60)
local town = garage and garage:WaitForChild("Town", 30)
local loop = town and town:WaitForChild("SkyLoop", 30)
local trainModel = loop and loop:WaitForChild("Train", 30)
local west = loop and loop:WaitForChild("StopWest", 30)
local east = loop and loop:WaitForChild("StopEast", 30)
if not (trainModel and trainModel:IsA("Model") and west and west:IsA("BasePart") and east and east:IsA("BasePart")) then
	return
end
local train = trainModel :: Model

local DWELL = 6 -- seconds at a station
local SPEED = 32 -- studs / s when cruising
local EASE = 4 -- seconds to speed up / slow down

local a, b = west.Position, east.Position
local dist = (b - a).Magnitude
local travel = dist / SPEED + EASE -- ease in + out costs about one EASE of extra time
local cycle = 2 * (DWELL + travel)

-- smooth 0..1 progress with eased ends (ease-in-out on the whole leg)
local function progress(t: number): number
	local u = math.clamp(t / travel, 0, 1)
	return u * u * (3 - 2 * u)
end

local t0 = os.clock()
RunService.Heartbeat:Connect(function()
	if not train.Parent then
		return
	end
	local t = (os.clock() - t0) % cycle
	local pos: Vector3
	if t < DWELL then
		pos = a
	elseif t < DWELL + travel then
		pos = a:Lerp(b, progress(t - DWELL))
	elseif t < 2 * DWELL + travel then
		pos = b
	else
		pos = b:Lerp(a, progress(t - 2 * DWELL - travel))
	end
	train:PivotTo(CFrame.new(pos)) -- (the train is built facing +X with an unrotated Root)
end)
