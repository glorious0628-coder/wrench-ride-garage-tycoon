-- The map's block stand-in cars (Placeholder3D = "Car": wr-builder's Props.standInCar — parked street cars, staff
-- cars, the junkyard's decor wrecks) become real-looking cars at server start: a sedan or an SUV from
-- ReplicatedStorage.CarMeshes in a random paint (Config.PaintColors). Look only: no prompts, no faults, anchored.
-- The block stays where it is, invisible, as the car's solid box (players bump into it, not through the meshes).
-- The junkyard's wrecks: a faded paint, a dented front bumper, one flat tire, the cracked headlight (sedan pieces).
-- Seen from the street, so the lighter pieces: no chassis / engine bay, Lite wheels with the one-piece brake.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Config = require(ReplicatedStorage.Shared.Config)

local DecorCars = {}

local TURN = CFrame.Angles(0, math.pi, 0)
local FADE = Color3.fromHex("C9CED3") -- wreck paint fades toward this (sedan wreck.json paint_fade)
local rng = Random.new()

local function find(name: string): Model?
	local folder = ReplicatedStorage:FindFirstChild("CarMeshes")
	local t = folder and folder:FindFirstChild(name)
	return if t and t:IsA("Model") and t.PrimaryPart then t else nil
end

-- one template, put at a CFrame (its Root), into the car; painted pieces take the paint
local function put(car: Model, name: string, at: CFrame, paint: Color3?)
	local t = find(name)
	if not t then
		return false
	end
	local v = t:Clone()
	v:PivotTo(at)
	for _, d in v:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
			if paint and d:IsA("MeshPart") and not d:GetAttribute("NoPaint") then -- (the hood's washer nozzles)
				d.Color = paint
			end
		end
	end
	v.Parent = car
	return true
end

-- the stand-in's own frame (front = -Z, pivot = the ground centre): its Body block sits 1.7 above it
local function frameOf(stand: Model): CFrame?
	local body = stand:FindFirstChild("Body")
	if body and body:IsA("BasePart") then
		return body.CFrame * CFrame.new(0, -1.7, 0)
	end
	return nil
end

function DecorCars.dress(stand: Model, carType: string, paint: Color3, wreck: boolean): Model?
	local frame = frameOf(stand)
	if not frame or not find("Decor_Shell") then
		return nil
	end
	local geo = CarParts.type(carType)
	local pre = geo.prefix
	local car = Instance.new("Model")
	car.Name = stand.Name .. "_Look"
	car:SetAttribute("CarType", geo.name)
	if not put(car, pre .. "Decor_Shell", frame, paint) then
		car:Destroy()
		return nil -- (this car type isn't baked: keep the block)
	end
	put(car, pre .. "Decor_Glass", frame)
	put(car, pre .. "Hood_Detail", frame * CFrame.new(geo.Slots.Hood.pivot), paint)
	put(car, (if wreck and find(pre .. "Bumper_F_Dented_Detail") then pre .. "Bumper_F_Dented_Detail" else pre .. "Bumper_F_Detail"), frame * CFrame.new(geo.Slots.Bumper_F.pivot), paint)
	put(car, pre .. "Bumper_R_Detail", frame * CFrame.new(geo.Slots.Bumper_R.pivot), paint)
	put(car, pre .. "Decor_Wipers", frame) -- (resting; a type without its own wipers has none)
	if wreck then
		put(car, pre .. "Decor_HeadlightCrack", frame)
	end
	local flat = if wreck then "FL" else nil
	for corner, c in geo.WheelCenters do
		local left = c.X < 0
		local at = frame * CFrame.new(c) * (if left then TURN else CFrame.identity) -- (right-side meshes, turned for the left)
		local wheel = if corner == flat and find(pre .. "Wheel_Flat_Detail") then pre .. "Wheel_Flat_Detail" else pre .. "Wheel_Lite"
		if not put(car, wheel, at) then
			put(car, "Wheel_Lite", at)
		end
		if not (left and put(car, "Hub_L_Lite", frame * CFrame.new(c))) then
			put(car, "Hub_Lite", at)
		end
	end
	car.Parent = stand.Parent
	-- the block: invisible, its big boxes stay solid
	for _, d in stand:GetDescendants() do
		if d:IsA("BasePart") then
			d.Transparency = 1
			d.CastShadow = false
			if d.Name ~= "Body" and d.Name ~= "Cabin" then
				d.CanCollide = false
			end
		end
	end
	stand:SetAttribute("Dressed", true)
	return car
end

-- every stand-in car on the map (run after the map is built)
function DecorCars.start(): number
	local n = 0
	for _, d in workspace:GetDescendants() do
		if d:IsA("Model") and d:GetAttribute("Placeholder3D") == "Car" and not d:GetAttribute("Dressed") then
			local wreck = d:FindFirstAncestor("Junkyard") ~= nil
			local carType = if not wreck and rng:NextNumber() < 0.35 and CarParts.baked("Crossover") then "Crossover" else "Sedan"
			local paint = Config.PaintColors[rng:NextInteger(1, #Config.PaintColors)]
			if wreck then
				paint = paint:Lerp(FADE, 0.4) -- (well faded: these have sat in the yard a long time)
			end
			if DecorCars.dress(d, carType, paint, wreck) then
				n += 1
			end
		end
	end
	return n
end

return DecorCars
