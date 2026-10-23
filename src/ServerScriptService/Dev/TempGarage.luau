-- A very plain stand-in garage, only built when there is no workspace.Garage and no World/ map code
-- (e.g. a place without wr-builder's files). Same names and spots as docs/specs/world_contract.md v1, so the game
-- code runs the same on it.

local TempGarage = {}

local function part(props: { [string]: any }, parent: Instance): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

local function model(name: string, parent: Instance): Model
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

-- an invisible marker: Position on the floor, LookVector = the way it faces
local function marker(parent: Instance, name: string, pos: Vector3, look: Vector3, size: Vector3?)
	part({
		Name = name,
		Size = size or Vector3.new(1, 0.2, 1),
		CFrame = CFrame.lookAt(pos, pos + look),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
	}, parent):SetAttribute("Marker", true)
end

function TempGarage.build()
	local g = Instance.new("Model")
	g.Name = "Garage"
	g:SetAttribute("Temporary", true)
	g:SetAttribute("Front", "-Z")

	part({ Name = "Floor", Size = Vector3.new(80, 0.2, 60), CFrame = CFrame.new(10, 0.1, -4), Color = Color3.fromRGB(150, 150, 146), Material = Enum.Material.Concrete }, g)

	local bay = model("Bay1", model("Bays", g))
	marker(bay, "CarSpot", Vector3.new(0, 0.2, -1), Vector3.zAxis, Vector3.new(8, 0.2, 18))
	marker(bay, "LiftSpot", Vector3.new(0, 0.2, -1), Vector3.zAxis, Vector3.new(16, 0.2, 4))
	bay.LiftSpot:SetAttribute("PostOffsetX", 6)
	bay.LiftSpot:SetAttribute("Installed", false)
	marker(bay, "ApproachSpot", Vector3.new(0, 0, -36), Vector3.zAxis, Vector3.new(8, 0.2, 18))
	marker(bay, "DriverExitSpot", Vector3.new(7, 0.2, -3), Vector3.xAxis)

	local pc = model("PartsCounter", g)
	part({ Name = "CounterTop", Size = Vector3.new(3.4, 3.2, 8), CFrame = CFrame.new(14.7, 1.8, 10), Color = Color3.fromRGB(70, 72, 78) }, pc)
	marker(pc, "ServicePoint", Vector3.new(11.5, 0.2, 10), Vector3.xAxis)
	marker(pc, "HandoverPoint", Vector3.new(14.5, 3.4, 10), -Vector3.xAxis)

	local wr = model("WaitingRoom", g)
	local seats = Instance.new("Folder")
	seats.Name = "Seats"
	seats.Parent = wr
	for i, z in { -16.5, -13.5, -10.5, -7.5 } do
		local s = Instance.new("Seat")
		s.Name = "Seat" .. i
		s.Anchored = true
		s.Size = Vector3.new(2.4, 1, 2.4)
		s.CFrame = CFrame.lookAt(Vector3.new(34.6, 1.9, z), Vector3.new(30, 1.9, z))
		s.Color = Color3.fromRGB(60, 90, 140)
		s.Parent = seats
	end
	marker(model("ReceptionDesk", wr), "ServicePoint", Vector3.new(21, 0.2, -9), Vector3.zAxis)
	marker(wr, "BayDoor", Vector3.new(14.5, 0.2, -1), Vector3.xAxis)
	marker(wr, "CustomerDoor", Vector3.new(32, 0.2, -21), Vector3.zAxis)

	local traffic = model("Traffic", g)
	marker(traffic, "RoadIn", Vector3.new(-250, 0, -79.5), Vector3.xAxis)
	marker(traffic, "EntryCurb", Vector3.new(48, 0, -70), Vector3.zAxis)
	marker(traffic, "LaneEast", Vector3.new(48, 0, -36), -Vector3.xAxis)
	marker(traffic, "LaneWest", Vector3.new(-95, 0, -36), -Vector3.zAxis)
	marker(traffic, "ExitCurb", Vector3.new(-95, 0, -70), -Vector3.zAxis)
	marker(traffic, "RoadOut", Vector3.new(250, 0, -79.5), Vector3.xAxis)

	g.Parent = workspace
	return g
end

return TempGarage
