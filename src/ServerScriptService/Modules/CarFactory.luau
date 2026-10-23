-- Builds a customer car out of blocks, in the car_spec 3-1 layout (wr-3d meshes later keep the same names), with
-- its car type's places (CarParts.type: Sedan, Crossover):
--   <CarType>_<id> (Model, PrimaryPart = Chassis, pivot = ground between the axles, front = -Z)
--     Chassis              Snap_<Slot> attachments = where each part's SnapAttachment goes
--     Body/                Shell (Model of blocks), Glass, Hood, Bumper_F, Bumper_R
--     MechanicalParts/     Battery, Radiator, Muffler, Wheel_FL.. (Model: Rim + Tire), BrakePads_FL..
--     Moving/              BrakeCaliper_FL.. (flips up while its pads are out)
--     Decor/               see-only stand-ins (engine, transaxle, hubs, interior)
-- A repair part is a BasePart, or a Model (several blocks) whose PrimaryPart is the root. On it: SnapAttachment
-- and Bolt_1..N attachments (+X = the way the bolt comes out) on the root, Bolt_N_Head parts (attribute Bolt) as
-- direct children, attributes PartKind, Slot, Condition, BoltCount, BoltsRemaining, Requires, CarryMode, MassKg,
-- Tool, State ("Installed" | "Free" | "Carried").
-- Everything is anchored (no car physics). The car moves with PivotTo (lift, driving in / out).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)

local CarFactory = {}

-- set by FaultService (it requires this module, so no require back): extra offsets from faults
CarFactory.hooks = {
	sag = nil :: ((part: Instance) -> CFrame)?, -- an installed part's offset from its socket
	lean = nil :: ((car: Model) -> CFrame)?, -- the whole car's tilt
}

local nextId = 0
local rng = Random.new()

local function folderIn(parent: Instance, name: string): Folder
	local f = parent:FindFirstChild(name) :: Folder
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

function CarFactory.looseFolder(): Folder
	return folderIn(workspace, "LooseParts")
end

-- the part's root BasePart (itself, or the Model's PrimaryPart)
function CarFactory.root(part: Instance): BasePart
	if part:IsA("BasePart") then
		return part
	end
	return (part :: Model).PrimaryPart :: BasePart
end

-- every BasePart that belongs to a repair part (blocks + bolt heads)
function CarFactory.allParts(part: Instance): { BasePart }
	local list = {}
	if part:IsA("BasePart") then
		table.insert(list, part)
	end
	for _, d in part:GetDescendants() do
		-- (mesh visuals are welded to the root and follow it — moving them one by one would drag it along)
		if d:IsA("BasePart") and not d:GetAttribute("Visual") then
			table.insert(list, d)
		end
	end
	return list
end

function CarFactory.snapCFrame(part: Instance): CFrame
	local snap = CarFactory.root(part):FindFirstChild("SnapAttachment") :: Attachment
	return snap.WorldCFrame
end

-- move a repair part so its SnapAttachment sits at a world CFrame (everything in it moves together)
function CarFactory.moveTo(part: Instance, target: CFrame)
	local delta = target * CarFactory.snapCFrame(part):Inverse()
	for _, p in CarFactory.allParts(part) do
		p.CFrame = delta * p.CFrame
	end
end

-- a bolt head sits on its attachment: flush when tight, sticking out when loose
function CarFactory.seatBolt(head: BasePart)
	local part = head.Parent :: Instance
	local att = CarFactory.root(part):FindFirstChild(head:GetAttribute("Attachment") :: string) :: Attachment
	local tight = head:GetAttribute("Tight") == true
	head.CFrame = att.WorldCFrame * CFrame.new(if tight then 0 else 0.18, 0, 0)
	head.Color = if tight then Config.BoltTightColor else Config.BoltLooseColor
end

-- anchored = on the car / on the floor; unanchored + welded = carried
function CarFactory.setCarried(part: Instance, carried: boolean)
	local root = CarFactory.root(part)
	for _, p in CarFactory.allParts(part) do -- (welded mesh visuals aren't in allParts: they ride along)
		p.Anchored = not carried
		p.Massless = carried
		p.CanCollide = false
		local w = p:FindFirstChild("CarryWeld")
		if p ~= root and carried and not w then
			w = Instance.new("WeldConstraint")
			w.Name = "CarryWeld"
			w.Part0 = root
			w.Part1 = p
			w.Parent = p
		elseif not carried and w then
			w:Destroy() -- no welds while anchored: moveTo moves the parts one by one
		end
	end
end

-- solid on the floor, not solid on a car (car_spec 3: attached parts CanCollide off, CanQuery on)
function CarFactory.setSolid(part: Instance, solid: boolean)
	for _, p in CarFactory.allParts(part) do
		p.CanCollide = solid and not p:GetAttribute("Bolt")
	end
end

local function block(spec: CarParts.Piece, cf: CFrame): Part
	local p = Instance.new("Part")
	p.Name = spec.name
	p.Size = spec.size
	p.Color = spec.color
	p.Material = spec.material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if spec.shape == "Cylinder" then
		p.Shape = Enum.PartType.Cylinder
	end
	local turn = if spec.turn then CFrame.Angles(0, math.rad(90), 0) else CFrame.identity
	p.CFrame = cf * CFrame.new(spec.offset) * turn
	return p
end

-- a car's type set (places / sizes / lift heights: CarParts.Types)
function CarFactory.geo(car: Instance?): CarParts.CarType
	return CarParts.type(car and car:GetAttribute("CarType") :: string?)
end

-- a new part of a kind (Condition 100), not on any car yet, built with its SnapAttachment at a world CFrame
-- (carType: made for that car type's slot — its own size / bolt places; nil = the shared part)
function CarFactory.makePart(kind: string, slotName: string?, at: CFrame?, carType: string?): Instance
	local k = CarParts.Kinds[kind]
	local b = CarParts.blocksFor(kind, slotName, carType)
	assert(k and b, "unknown part kind " .. kind)
	local cf = at or CFrame.identity
	local root = block(b.pieces[1], cf)
	local part: Instance = root
	if #b.pieces > 1 then
		local m = Instance.new("Model")
		root.Parent = m
		for i = 2, #b.pieces do
			block(b.pieces[i], cf).Parent = m
		end
		m.PrimaryPart = root
		part = m
	end
	part.Name = slotName or kind
	local snap = Instance.new("Attachment")
	snap.Name = "SnapAttachment"
	snap.CFrame = root.CFrame:ToObjectSpace(cf)
	snap.Parent = root
	if b.hinge then
		local h = snap:Clone()
		h.Name = "Hinge"
		h.Parent = root
	end
	for i, bolt in b.bolts do
		local att = Instance.new("Attachment")
		att.Name = "Bolt_" .. i
		-- +X axis = the way the bolt comes out (car_spec 3-2)
		local up = if math.abs(bolt.out.Y) > 0.9 then Vector3.zAxis else Vector3.yAxis
		local world = CFrame.fromMatrix(cf * bolt.offset, cf:VectorToWorldSpace(bolt.out), cf:VectorToWorldSpace(up))
		att.CFrame = root.CFrame:ToObjectSpace(world)
		if bolt.requires then
			att:SetAttribute("Requires", table.concat(bolt.requires, ","))
		end
		att:SetAttribute("LoosenAfter", bolt.loosenAfter)
		att:SetAttribute("TightenAfter", bolt.tightenAfter)
		att.Parent = root

		local head = Instance.new("Part")
		head.Name = "Bolt_" .. i .. "_Head"
		head.Shape = Enum.PartType.Cylinder
		-- (a battery terminal's pinch nut is a 10 mm nut beside the post — battery_posts_v1 §4; BoltLook's hex follows)
		head.Size = if bolt.f == "Terminal" then Vector3.new(0.05, 0.1, 0.1) else Vector3.new(0.2, 0.3, 0.3)
		head.Material = Enum.Material.Metal
		head.Anchored = true
		head.CanCollide = false
		head.CastShadow = false
		head:SetAttribute("Bolt", true)
		head:SetAttribute("Attachment", att.Name)
		head:SetAttribute("Fastener", bolt.f or "Bolt") -- (which tool it needs: Features.ToolMatch)
		head:SetAttribute("Tight", true)
		head.Parent = part
		CarFactory.seatBolt(head)
	end
	part:SetAttribute("PartKind", kind)
	part:SetAttribute("Fits", if carType and carType ~= "Sedan" then carType else nil)
	part:SetAttribute("Slot", slotName)
	part:SetAttribute("Condition", Config.NewPartCondition)
	part:SetAttribute("BoltCount", #b.bolts)
	part:SetAttribute("BoltsRemaining", #b.bolts)
	part:SetAttribute("CarryMode", k.carry)
	part:SetAttribute("MassKg", k.massKg)
	part:SetAttribute("Tool", k.tool)
	part:SetAttribute("State", "Free")
	return part
end

function CarFactory.groupOf(car: Model, kind: string): Folder
	return car:FindFirstChild(CarParts.Kinds[kind].group) :: Folder
end

-- the installed part in a slot, or nil when the slot is empty
function CarFactory.slotPart(car: Model, slotName: string): Instance?
	local slot = CarParts.Slots[slotName]
	local folder = car:FindFirstChild(CarParts.Kinds[slot.kind].group)
	local p = folder and folder:FindFirstChild(slotName)
	if p and p:GetAttribute("State") == "Installed" then
		return p
	end
	return nil
end

-- world CFrame a part's SnapAttachment should sit at in this slot (hood open = swung up on its hinge)
function CarFactory.partCFrame(car: Model, slotName: string): CFrame
	local chassis = car.PrimaryPart :: BasePart
	local cf = (chassis:FindFirstChild("Snap_" .. slotName) :: Attachment).WorldCFrame
	if slotName == "Hood" and car:GetAttribute("HoodOpen") then
		cf = cf * CFrame.Angles(math.rad(CarFactory.geo(car).HoodOpenDeg), 0, 0) -- +X lifts the front, to where the prop rod holds it
	end
	local part = CarFactory.slotPart(car, slotName)
	if part and CarFactory.hooks.sag then
		cf = cf * CarFactory.hooks.sag(part)
	end
	return cf
end

-- re-seat one installed part on its socket (hood opened, a fault changed, a new part went in)
function CarFactory.reseat(car: Model, slotName: string)
	local part = CarFactory.slotPart(car, slotName)
	if part then
		CarFactory.moveTo(part, CarFactory.partCFrame(car, slotName))
	end
end

-- brake calipers flip up 70° on their lower guide bolt while the pads are out (car_spec 4-1)
function CarFactory.calipers(car: Model)
	local moving = car:FindFirstChild("Moving")
	if not moving then
		return
	end
	local base = car:GetPivot()
	for corner, c in CarFactory.geo(car).WheelCenters do
		local cal = moving:FindFirstChild("BrakeCaliper_" .. corner) :: BasePart?
		if cal then
			-- around the pads at the wheel's front, swung up on its upper slide pin (brake_attachments.json Hinge:
			-- +70° about +X lifts the body forward and up, both sides)
			local pad = CarParts.PadOffset
			local closed = base * CFrame.new(c + Vector3.new(if c.X < 0 then pad.X else -pad.X, pad.Y, pad.Z))
			local hinge = closed * CFrame.new(if c.X < 0 then 0.2429 else -0.2429, 0.4103, 0.0871)
			local up = CarFactory.slotPart(car, "BrakePads_" .. corner) == nil
			cal.CFrame = if up then hinge * CFrame.Angles(math.rad(70), 0, 0) * hinge:ToObjectSpace(closed) else closed
		end
	end
end

-- the corners' look (wheels, pads, calipers, hubs): "Detail" while the car is in a bay, otherwise unset — the
-- client (ClientModules/CarLook) then picks Detail / Lite by camera distance. Meshes are local only.
function CarFactory.setDetail(car: Model, weight: string)
	car:SetAttribute("Detail", if weight == "Detail" then "Detail" else nil)
end

-- move the whole car where it belongs: BaseCFrame (ground pivot), raised by LiftOffset, tilted by faults.
-- A floor jack (LiftEnd "F" / "R", work_view 2b) raises one end by LiftOffset: the car pitches about the other axle,
-- whose tires stay on the floor; a lift (no LiftEnd) raises the whole car.
function CarFactory.pose(car: Model)
	local base = (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
	local lift = (car:GetAttribute("LiftOffset") :: number?) or 0
	local lean = if CarFactory.hooks.lean then CarFactory.hooks.lean(car) else CFrame.identity
	local liftEnd = car:GetAttribute("LiftEnd") :: string?
	if liftEnd == "F" or liftEnd == "R" then
		local w = CarParts.work(car:GetAttribute("CarType") :: string?)
		local length = w.axle.R - w.axle.F
		local angle = math.asin(math.clamp(lift / length, 0, 0.5))
		local about = if liftEnd == "F" then w.axle.R else w.axle.F
		local sign = if liftEnd == "F" then 1 else -1 -- (+ about +X lifts the front)
		car:PivotTo(base * CFrame.new(0, 0, about) * CFrame.Angles(sign * angle, 0, 0) * CFrame.new(0, 0, -about) * lean)
	else
		car:PivotTo(CFrame.new(0, lift, 0) * base * lean)
	end
	CarFactory.calipers(car)
end

local function slotCFrame(geo: CarParts.CarType, slotName: string): CFrame
	local slot = geo.Slots[slotName]
	local cf = CFrame.new(slot.pivot)
	if slot.yaw then
		cf *= CFrame.Angles(0, math.rad(slot.yaw), 0)
	end
	return if slot.turned then cf * CFrame.Angles(0, math.pi, 0) else cf
end

local function fixed(spec: { [string]: any }, at: CFrame, parent: Instance, collide: boolean): Part
	local p = block({ name = spec.name, size = spec.size, offset = Vector3.zero, color = spec.color, material = spec.material, shape = spec.shape }, at * CFrame.new(spec.pos))
	p.CanCollide = collide
	p.Parent = parent
	return p
end

function CarFactory.build(at: CFrame, carType: string?, paint: Color3?): Model
	local geo = CarParts.type(carType)
	-- the car's paint: the shell blocks keep it (CarLook paints the 3D with it, restoration dirties it)
	paint = paint or Config.PaintColors[rng:NextInteger(1, #Config.PaintColors)]
	nextId += 1
	local car = Instance.new("Model")
	car.Name = geo.name .. "_" .. nextId
	car:SetAttribute("CarId", nextId)
	car:SetAttribute("CarType", geo.name)
	car:SetAttribute("HoodOpen", false)
	car:SetAttribute("LiftOffset", 0)
	car:SetAttribute("BaseCFrame", at)

	local c = geo.Chassis
	local chassis = fixed({ name = "Chassis", size = c.size, pos = c.pos, color = c.color, material = Enum.Material.Metal }, at, car, true)
	car.PrimaryPart = chassis
	chassis.PivotOffset = chassis.CFrame:ToObjectSpace(at) -- the car's pivot = the ground between the axles

	local body = folderIn(car, "Body")
	folderIn(car, "MechanicalParts")
	local moving = folderIn(car, "Moving")
	local decor = folderIn(car, "Decor")
	local shell = Instance.new("Model")
	shell.Name = "Shell"
	shell.Parent = body
	for _, s in geo.Shell do
		local p = fixed(s, at, shell, true)
		if s.color == geo.paint then
			p.Color = paint :: Color3
		end
	end
	local glass = fixed({ name = "Glass", size = geo.Glass.size, pos = geo.Glass.pos, color = geo.Glass.color, material = Enum.Material.Glass }, at, body, true)
	glass.Transparency = 0.55
	for _, s in geo.Decor do
		local p = fixed(s, at, decor, false)
		p.CanQuery = false
		p.CanTouch = false
	end
	for corner in geo.WheelCenters do
		local cal = fixed({ name = "BrakeCaliper_" .. corner, size = Vector3.new(0.52, 1.03, 0.8), pos = Vector3.zero, color = Color3.fromRGB(190, 40, 40) }, at, moving, false)
		cal.CanQuery = false
	end

	for _, slotName in CarParts.SlotOrder do
		local slot = geo.Slots[slotName]
		if not slot then
			continue -- (a sedan slot this type hasn't got: piece E's new parts before its own bay is fitted)
		end
		local local_ = slotCFrame(geo, slotName)
		local snap = Instance.new("Attachment")
		snap.Name = "Snap_" .. slotName
		snap.CFrame = chassis.CFrame:ToObjectSpace(at * local_)
		snap:SetAttribute("Slot", slotName)
		snap:SetAttribute("PartKind", slot.kind)
		snap.Parent = chassis

		local part = CarFactory.makePart(slot.kind, slotName, at * local_, geo.name)
		part:SetAttribute("State", "Installed")
		part:SetAttribute("Requires", if slot.requires then table.concat(slot.requires, ",") else nil)
		CarFactory.setSolid(part, false)
		part.Parent = CarFactory.groupOf(car, slot.kind)
	end
	CarFactory.calipers(car)
	car.Parent = folderIn(workspace, "Cars")
	return car
end

return CarFactory
