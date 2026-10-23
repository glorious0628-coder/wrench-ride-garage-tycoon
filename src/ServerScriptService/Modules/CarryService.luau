-- A part off the car: it drops to the floor (or pops out of the engine bay), gets a "Pick up" prompt, is carried
-- in front of you (car_spec CarryMode: OneHand / TwoHand slow + no tools / Roll), dropped with G, put in the scrap
-- bin, or installed on an empty matching slot (client sends Remotes.Install, the server checks everything).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local PlayerData = require(script.Parent.PlayerData)
local Places = require(script.Parent.Places)
local Guard = require(script.Parent.Guard)

local CarryService = {}
CarryService.onEarned = nil :: ((p: Player, money: number) -> ())? -- ShiftService.earn (scrap)

local carrying: { [Player]: Instance } = {}
local putAway: { [Player]: string } = {} -- the tool put away for a two-hand part (back in the hand after)

-- called after a part goes in / comes out: symptoms, tilt, calipers, the completion check
CarryService.onCarChanged = nil :: ((car: Model) -> ())?

local function rootOf(player: Player): BasePart?
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function notify(player: Player, key: string, args: { [string]: any }?, kind: string?)
	Remotes.Notify:FireClient(player, key, args, kind or "bad")
end

function CarryService.carried(player: Player): Instance?
	local p = carrying[player]
	if p and p.Parent == nil then
		carrying[player] = nil
		return nil
	end
	return p
end

local function labelPrompt(part: Instance)
	local prompt = CarFactory.root(part):FindFirstChild("PickupPrompt") :: ProximityPrompt?
	if prompt then
		Locale.tag(prompt, "obj.part", { part = "@part." .. tostring(part:GetAttribute("PartKind")), cond = part:GetAttribute("Condition") }, "ObjectText")
	end
end

local function ensurePrompt(part: Instance)
	local root = CarFactory.root(part)
	local prompt = root:FindFirstChild("PickupPrompt") :: ProximityPrompt?
	if not prompt then
		local p = Instance.new("ProximityPrompt")
		p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
		p.Name = "PickupPrompt"
		p.KeyboardKeyCode = Enum.KeyCode.E
		p.MaxActivationDistance = Config.PromptDistance
		p.RequiresLineOfSight = false
		Locale.tag(p, "act.pickUp")
		p.Parent = root
		p.Triggered:Connect(Guard.prompt(p, "PickUp", 0.2, function(player)
			CarryService.pickUp(player, part)
		end))
		prompt = p
	end
	labelPrompt(part)
	;(prompt :: ProximityPrompt).Enabled = true
end

local function setPrompt(part: Instance, on: boolean)
	local prompt = CarFactory.root(part):FindFirstChild("PickupPrompt") :: ProximityPrompt?
	if prompt then
		prompt.Enabled = on
	end
end

-- lowest point of a part below its SnapAttachment (to stand it on the floor)
local function bottomBelowSnap(part: Instance): number
	local snap = CarFactory.snapCFrame(part)
	local low = math.huge
	for _, p in CarFactory.allParts(part) do
		local cf, s = p.CFrame, p.Size / 2
		for _, x in { -1, 1 } do
			for _, y in { -1, 1 } do
				for _, z in { -1, 1 } do
					local w = cf * Vector3.new(s.X * x, s.Y * y, s.Z * z)
					low = math.min(low, w.Y)
				end
			end
		end
	end
	return snap.Position.Y - low
end

local function floorBelow(pos: Vector3, ignore: { Instance }): number
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local list = table.clone(ignore)
	for _, f in { "Cars", "LooseParts", "Puddles" } do
		local folder = workspace:FindFirstChild(f)
		if folder then
			table.insert(list, folder)
		end
	end
	for _, plr in Players:GetPlayers() do
		if plr.Character then
			table.insert(list, plr.Character)
		end
	end
	params.FilterDescendantsInstances = list
	local hit = workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -60, 0), params)
	return if hit then hit.Position.Y else 0
end

-- set a free part down on the floor at a spot, upright (keeps its yaw)
local function setDown(part: Instance, at: Vector3, yaw: CFrame)
	local h = bottomBelowSnap(part)
	local y = floorBelow(at, { part })
	CarFactory.moveTo(part, CFrame.new(at.X, y + h, at.Z) * yaw)
end

-- the last bolt came out: the part leaves its slot
-- a Swing part hinged down: about its inner end (part +X, both sides — the right one is the left turned) by SwingDeg
function CarryService.swungCFrame(part: Instance): CFrame
	local root = CarFactory.root(part)
	local half = root.Size.X / 2
	local swung = root.CFrame * CFrame.new(half, 0, 0) * CFrame.Angles(0, 0, math.rad(Config.SwingDeg)) * CFrame.new(-half, 0, 0)
	return swung * root.CFrame:Inverse() * CarFactory.snapCFrame(part) -- (as the snap's place: CarFactory.moveTo)
end

-- the hinged-down arm back up onto the car (the jack under it lifts it, the spring above squeezes): bolts loose
function CarryService.swingUp(player: Player, car: Model, part: Instance): boolean
	local slotName = part:GetAttribute("Slot") :: string
	local slot = CarParts.Slots[slotName]
	if part:GetAttribute("State") ~= "Swung" or not slot then
		return false
	end
	-- (the Arm:XX condition: the jack is what lifts it — CarService.check says why when it isn't there)
	for _, req in slot.requires or {} do
		if req:sub(1, 4) == "Arm:" then
			local ok, key, args = CarService.check(car, req, slotName)
			if not ok then
				notify(player, key :: string, args)
				return false
			end
		end
	end
	-- what sits on it goes in first (the spring onto its seat)
	for other, s in CarParts.Slots do
		if s.requires and table.find(s.requires, slotName) and other:match("^Spring_") and not CarFactory.slotPart(car, other) then
			notify(player, "n.springFirst")
			return false
		end
	end
	part:SetAttribute("State", "Installed")
	part:SetAttribute("FromCar", nil)
	CarFactory.reseat(car, slotName)
	CarService.touch(car, player)
	Remotes.Effect:FireAllClients("install", { part = part })
	notify(player, "n.armUp", nil, "good")
	if CarryService.onCarChanged then
		CarryService.onCarChanged(car)
	end
	return true
end

function CarryService.detach(car: Model, part: Instance)
	local slotName = part:GetAttribute("Slot") :: string
	local slot = CarParts.Slots[slotName]
	local from = CarFactory.root(part).CFrame -- (where it sat: each screen slides it out from here — BoltLook.partOut)
	if slot and slot.detach == "Swing" then
		-- E2 (the rear No.2 arm): its outer bolt out, the inner cam bolt only loosened — it stays on the car, hinged
		-- down on that inner bolt onto the jack, and the spring above it comes free. Up again = CarryService.swingUp
		part:SetAttribute("State", "Swung")
		part:SetAttribute("FromCar", car:GetAttribute("CarId"))
		CarFactory.moveTo(part, CarryService.swungCFrame(part))
		Remotes.Effect:FireAllClients("partOut", { part = part, from = from })
		if CarryService.onCarChanged then
			CarryService.onCarChanged(car)
		end
		return
	end
	part:SetAttribute("State", "Free")
	part:SetAttribute("FromCar", car:GetAttribute("CarId"))
	part.Name = part:GetAttribute("PartKind") :: string
	local hoodPrompt = CarFactory.root(part):FindFirstChild("HoodPrompt")
	if hoodPrompt then
		hoodPrompt:Destroy()
	end
	if slot and slot.detach == "Pop" then
		-- lifted out of the engine bay, it rests on top (moves with the car until picked up)
		local detached = car:FindFirstChild("Detached") or Instance.new("Folder")
		detached.Name = "Detached"
		detached.Parent = car
		-- (a bay part with a way out from the 3D — CarParts.Exit — rests at its end: the screens slide it there)
		local exit = CarParts.exitOf(slotName, car:GetAttribute("CarType") :: string?)
		local snap = CarFactory.snapCFrame(part)
		CarFactory.moveTo(part, if exit then snap * exit[#exit] else snap + Vector3.new(0, Config.DetachPop, 0))
		part.Parent = detached
	else
		local snap = CarFactory.snapCFrame(part)
		local _, yaw = snap:ToEulerAnglesYXZ()
		part.Parent = CarFactory.looseFolder()
		-- side parts (wheels, pads) roll out past the car's side, end parts (bumpers) fall off the end, so nothing
		-- ends up under the car where you can't reach it
		local carCf = car:GetPivot()
		local l = carCf:PointToObjectSpace(snap.Position)
		if math.abs(l.X) > 2 then
			-- (and toward the car's middle: straight out, it lay between the wheel and the wheel view's camera —
			-- test 2 ⑩, a big black tire over the bottom of the screen)
			l = Vector3.new(math.sign(l.X) * 5.0, l.Y, l.Z - math.sign(l.Z) * 3.2)
		elseif math.abs(l.Z) > 7.5 then
			l = Vector3.new(l.X, l.Y, math.sign(l.Z) * 9.6)
		end
		setDown(part, carCf * l, CFrame.Angles(0, yaw, 0))
		CarFactory.setSolid(part, true)
	end
	ensurePrompt(part)
	Remotes.Effect:FireAllClients("partOut", { part = part, from = from })
	if part:GetAttribute("PartKind") == "BrakePads" then
		CarryService.pistonPrompt(car, slotName:match("_(%u%u)$") :: string, true)
	end
	if CarryService.onCarChanged then
		CarryService.onCarChanged(car)
	end
end

-- the caliper's piston (car_spec 4-1 #3): worn pads leave it sticking out, so the new (thicker) pads only fit after
-- it's pushed back — one press on the caliper while its pads are out
function CarryService.pistonPrompt(car: Model, corner: string, on: boolean)
	local moving = car:FindFirstChild("Moving")
	local cal = moving and moving:FindFirstChild("BrakeCaliper_" .. corner) :: BasePart?
	if not cal then
		return
	end
	local p = cal:FindFirstChild("PistonPrompt") :: ProximityPrompt?
	if not p then
		local np = Instance.new("ProximityPrompt")
		np.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
		np.Name = "PistonPrompt"
		-- its own key: the wheel just taken off lies right here, and its E "Pick up" would hide this one
		np.KeyboardKeyCode = Enum.KeyCode.Q
		np.HoldDuration = 0.8
		np.MaxActivationDistance = Config.PromptDistance
		np.RequiresLineOfSight = false
		Locale.tag(np, "act.pushPiston")
		np.Parent = cal
		np.Triggered:Connect(Guard.prompt(np, "Piston", 0.3, function(player)
			CarryService.pushPiston(player, car, corner)
		end))
		p = np
	end
	if on then
		cal:SetAttribute("PistonIn", false)
	end
	;(p :: ProximityPrompt).Enabled = on and not cal:GetAttribute("PistonIn")
end

-- push the caliper's piston back (its prompt, or a tap on the caliper in the wheel's work view)
function CarryService.pushPiston(player: Player, car: Model, corner: string)
	local moving = car:FindFirstChild("Moving")
	local cal = moving and moving:FindFirstChild("BrakeCaliper_" .. corner) :: BasePart?
	local np = cal and cal:FindFirstChild("PistonPrompt") :: ProximityPrompt?
	if not cal or not np or not np.Enabled or cal:GetAttribute("PistonIn") then
		return
	end
	local root = rootOf(player)
	if not root or (root.Position - cal.Position).Magnitude > Config.ReachDistance then
		return notify(player, "n.tooFar")
	end
	cal:SetAttribute("PistonIn", true)
	np.Enabled = false
	CarService.touch(car, player)
	Remotes.Effect:FireAllClients("install", { part = cal })
	Remotes.Notify:FireClient(player, "n.pistonIn", nil, "good")
end

-- the player's walk with empty hands (set by Main: StoreService.walk — VIP's +10%); carrying slows from there
CarryService.walkBase = function(_player: Player): number
	return Config.NormalWalkSpeed
end

local function speedFor(player: Player, part: Instance): number
	local mode = part:GetAttribute("CarryMode") :: string
	return CarryService.walkBase(player) * (Config.CarrySpeed[mode] or 1)
end

-- far: from a work stand (WorkService checked the reach to the cart / the car itself)
CarryService.onPickUp = nil :: ((Player) -> ())? -- CoffeeService.drop (Main)

function CarryService.pickUp(player: Player, part: Instance, far: boolean?)
	if CarryService.carried(player) then
		return notify(player, "n.handsFull")
	end
	local root = rootOf(player)
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health <= 0 then
		return
	end
	if part:GetAttribute("State") ~= "Free" or not part.Parent then
		return
	end
	if not far and (CarFactory.root(part).Position - root.Position).Magnitude > Config.PromptDistance + 4 then
		return notify(player, "n.tooFar")
	end
	local mode = part:GetAttribute("CarryMode") :: string
	if mode ~= "OneHand" then
		-- both hands on it (car_spec TwoHand / Roll); the tool comes back to the hand once it's put down (a wheel put on
		-- and then bare hands on its nuts: the taps did nothing — wr-dev Guide play test)
		local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
		putAway[player] = if tool then tool.Name else nil
		hum:UnequipTools()
	end
	if CarryService.onPickUp then
		CarryService.onPickUp(player)
	end
	part:SetAttribute("State", "Carried")
	part:SetAttribute("CarriedBy", player.UserId)
	setPrompt(part, false)
	part.Parent = CarFactory.looseFolder()
	-- hold it so its SnapAttachment sits at the carry offset, upright, facing where you face
	-- (move first, weld after: moving welded parts one by one would drag the others along)
	local offset = Config.CarryOffset[mode] or Config.CarryOffset.TwoHand
	CarFactory.moveTo(part, root.CFrame * offset)
	CarFactory.setCarried(part, true)
	local partRoot = CarFactory.root(part)
	local weld = Instance.new("WeldConstraint")
	weld.Name = "HoldWeld"
	weld.Part0 = root
	weld.Part1 = partRoot
	weld.Parent = partRoot
	pcall(function()
		partRoot:SetNetworkOwner(player)
	end)
	hum.WalkSpeed = speedFor(player, part)
	carrying[player] = part
end

-- let go of the carried part (the caller places it afterwards)
local function release(player: Player): Instance?
	local part = CarryService.carried(player)
	carrying[player] = nil
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = CarryService.walkBase(player)
	end
	local back = putAway[player]
	putAway[player] = nil
	if back and hum then
		task.defer(function()
			local bp = player:FindFirstChildOfClass("Backpack")
			local tool = bp and bp:FindFirstChild(back)
			if tool and tool:IsA("Tool") and not CarryService.carried(player) and not (player.Character and player.Character:FindFirstChildOfClass("Tool")) then
				hum:EquipTool(tool)
			end
		end)
	end
	if not part then
		return nil
	end
	local w = CarFactory.root(part):FindFirstChild("HoldWeld")
	if w then
		w:Destroy()
	end
	CarFactory.setCarried(part, false)
	part:SetAttribute("CarriedBy", nil)
	part:SetAttribute("Handler", player.UserId) -- (an old part left lying: its scrap money goes to them)
	return part
end

-- "clumsy is fine" (game_textbook 5): a part set down close to its empty spot goes on, like a magnet
local function magnet(player: Player): boolean
	local part = CarryService.carried(player)
	local kind = part and part:GetAttribute("PartKind")
	local cars = workspace:FindFirstChild("Cars")
	if not part or not kind or not cars then
		return false
	end
	if ((part:GetAttribute("Condition") :: number?) or 100) < 50 then
		return false -- a worn-out part set down by its old spot stays down (it's not going back on)
	end
	local at = CarFactory.root(part).Position
	local best, bestCar, bestD = nil, nil, Config.MagnetRange
	for _, car in cars:GetChildren() do
		local chassis = car:IsA("Model") and car.PrimaryPart
		for slotName, slot in CarParts.Slots do
			local snap = chassis and chassis:FindFirstChild("Snap_" .. slotName) :: Attachment?
			if slot.kind == kind and snap and not CarFactory.slotPart(car :: Model, slotName) then
				local d = (snap.WorldPosition - at).Magnitude
				if d < bestD then
					best, bestCar, bestD = slotName, car, d
				end
			end
		end
	end
	if not best then
		return false
	end
	CarryService.install(player, bestCar :: Model, best)
	return part:GetAttribute("State") == "Installed"
end

-- set what I carry down at a place (the bay's cart: WorkService) — the part, or nil when the hands were empty
function CarryService.putDown(player: Player, at: CFrame): Instance?
	local part = release(player)
	if not part then
		return nil
	end
	part:SetAttribute("State", "Free")
	local _, yaw = at:ToEulerAnglesYXZ()
	setDown(part, at.Position, CFrame.Angles(0, yaw, 0))
	CarFactory.setSolid(part, true)
	ensurePrompt(part)
	Remotes.Effect:FireAllClients("partDrop", { pos = CarFactory.root(part).Position })
	return part
end

function CarryService.drop(player: Player)
	if magnet(player) then
		return
	end
	local root = rootOf(player)
	local part = release(player)
	if not part then
		return
	end
	part:SetAttribute("State", "Free")
	local front = if root then root.CFrame * CFrame.new(0, 0, -2.6) else CarFactory.snapCFrame(part)
	local _, yaw = front:ToEulerAnglesYXZ()
	setDown(part, front.Position, CFrame.Angles(0, yaw, 0))
	Remotes.Effect:FireAllClients("partDrop", { pos = CarFactory.root(part).Position })
	CarFactory.setSolid(part, true)
	ensurePrompt(part)
end

-- the carried part goes onto an empty slot of a car
function CarryService.install(player: Player, car: Instance, slotName: string)
	local part = CarryService.carried(player)
	if not part or typeof(car) ~= "Instance" or not car:IsA("Model") or car.Parent ~= workspace:FindFirstChild("Cars") then
		return
	end
	local slot = CarParts.Slots[slotName]
	if not slot then
		return
	end
	if slot.kind ~= part:GetAttribute("PartKind") then
		return notify(player, "n.wrongSlot")
	end
	if CarFactory.slotPart(car, slotName) then
		return
	end
	local root = rootOf(player)
	local snap = (car :: Model).PrimaryPart and (car :: Model).PrimaryPart:FindFirstChild("Snap_" .. slotName) :: Attachment?
	if not root or not snap or (snap.WorldPosition - root.Position).Magnitude > Config.ReachDistance then
		return notify(player, "n.tooFar")
	end
	local ok, key, args = CarService.check(car :: Model, if slot.requires then table.concat(slot.requires, ",") else nil, slotName, player)
	if not ok then
		return notify(player, key :: string, args)
	end
	-- what this part covers has to be bolted in first: a wheel over pads whose caliper bolts are still loose sat there
	-- with the job card stuck on "change the pads" and nothing said why (wr-gamer fun 1 ⑦)
	for other in CarParts.Slots do
		local under = CarFactory.slotPart(car :: Model, other)
		local req = under and (under:GetAttribute("Requires") :: string?)
		local count = under and under:GetAttribute("BoltCount") :: number?
		if req and table.find(string.split(req, ","), slotName) and type(count) == "number" and count > 0
			and ((under :: Instance):GetAttribute("BoltsRemaining") :: number? or 0) < count then
			return notify(player, "n.tightenFirst", { part = "@part." .. tostring((under :: Instance):GetAttribute("PartKind")) })
		end
	end
	local corner = slotName:match("_(%u%u)$")
	if slot.kind == "BrakePads" then
		local cal = (car :: Model):FindFirstChild("Moving") and (car :: any).Moving:FindFirstChild("BrakeCaliper_" .. tostring(corner))
		if cal and cal:GetAttribute("PistonIn") == false then
			return notify(player, "n.piston")
		end
	end
	release(player)
	part.Name = slotName
	part:SetAttribute("Slot", slotName)
	part:SetAttribute("Requires", if slot.requires then table.concat(slot.requires, ",") else nil)
	part:SetAttribute("State", "Installed")
	part:SetAttribute("FromCar", nil)
	part:SetAttribute("Fresh", nil) -- it went on a car: no selling back
	setPrompt(part, false)
	CarFactory.setSolid(part, false)
	part.Parent = CarFactory.groupOf(car :: Model, slot.kind)
	if slot.kind == "Hood" then
		car:SetAttribute("HoodOpen", true) -- a hood goes on open; its bolts are at the hinge
		CarService.hoodPrompt(car :: Model)
	end
	CarFactory.reseat(car :: Model, slotName)
	if slot.kind == "BrakePads" and corner then
		CarryService.pistonPrompt(car :: Model, corner, false) -- the next pads out will need it again
		local cal = (car :: any).Moving:FindFirstChild("BrakeCaliper_" .. corner)
		if cal then
			cal:SetAttribute("PistonIn", nil)
		end
	end
	for _, d in part:GetChildren() do
		if d:IsA("BasePart") and d:GetAttribute("Bolt") then
			CarFactory.seatBolt(d)
		end
	end
	CarService.touch(car :: Model, player)
	Remotes.Effect:FireAllClients("install", { part = part })
	if CarryService.onCarChanged then
		CarryService.onCarChanged(car :: Model)
	end
end

-- a bought part that never went on a car can go back for its full price ("Wrong part. Sell it back": tutorial_script
-- 5 — a wrong guess costs nothing). Only the buyer can; the prompt is there while it lies free.
local function sellPrompt(part: Instance)
	local kind = part:GetAttribute("PartKind") :: string
	local price = CarParts.Kinds[kind].price
	local p = Instance.new("ProximityPrompt")
	p.Name = "SellPrompt"
	p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	p.KeyboardKeyCode = Enum.KeyCode.R
	p.MaxActivationDistance = Config.PromptDistance
	p.RequiresLineOfSight = false
	p.UIOffset = Vector2.new(0, 72)
	Locale.tag(p, "act.sellBack", { money = price })
	p.Parent = CarFactory.root(part)
	local function free()
		p.Enabled = part:GetAttribute("State") == "Free" and part:GetAttribute("Fresh") == true
	end
	free()
	part:GetAttributeChangedSignal("State"):Connect(free)
	p.Triggered:Connect(Guard.prompt(p, "SellBack", 0.3, function(player)
		if part:GetAttribute("BoughtBy") ~= player.UserId or part:GetAttribute("Fresh") ~= true or part:GetAttribute("State") ~= "Free" or not part.Parent then
			return
		end
		part:Destroy()
		PlayerData.addMoney(player, price)
		Remotes.Notify:FireClient(player, "n.soldBack", { part = "@part." .. kind, money = price }, "good")
	end))
end

-- a fresh part from the parts counter (bolts loose, Condition 100), lying at a spot
function CarryService.spawnNew(kind: string, at: CFrame, owner: Player): Instance
	local part = CarFactory.makePart(kind, nil, at)
	part:SetAttribute("BoughtBy", owner.UserId)
	part:SetAttribute("Fresh", true) -- never on a car yet: can be sold back
	if kind == "Wheel" then
		part:SetAttribute("Balanced", true)
	end
	part:SetAttribute("BoltsRemaining", 0)
	for _, d in part:GetChildren() do
		if d:IsA("BasePart") and d:GetAttribute("Bolt") then
			d:SetAttribute("Tight", false)
			CarFactory.seatBolt(d)
		end
	end
	part.Parent = CarFactory.looseFolder()
	local _, yaw = at:ToEulerAnglesYXZ()
	setDown(part, at.Position, CFrame.Angles(0, yaw, 0))
	CarFactory.setSolid(part, true)
	ensurePrompt(part)
	sellPrompt(part)
	return part
end

-- the scrap bin pays for a worn part off a car only (exploit audit H2): a part bought at the counter goes back for
-- its price with R, never to the bin for more than it cost — and a good part pulled off a car isn't scrap money either
local function scrapPays(part: Instance): boolean
	local worn = ((part:GetAttribute("Condition") :: number?) or 100) < 50
	local bought = part:GetAttribute("Fresh") == true or part:GetAttribute("BoughtBy") ~= nil
	return worn and not bought and part:GetAttribute("Scrapped") ~= true
end
CarryService.scrapPays = scrapPays

local function scrap(player: Player)
	local part = CarryService.carried(player)
	if not part then
		return
	end
	local kind = part:GetAttribute("PartKind")
	local pays = scrapPays(part)
	release(player)
	part:Destroy()
	if not pays then
		Remotes.Notify:FireClient(player, "n.scrappedNoPay", { part = "@part." .. tostring(kind) })
		return -- (paid on the cart already / bought / not worn)
	end
	PlayerData.addMoney(player, Config.ScrapValue)
	if CarryService.onEarned then
		CarryService.onEarned(player, Config.ScrapValue) -- (today's receipt)
	end
	Remotes.Notify:FireClient(player, "n.scrapped", { part = "@part." .. tostring(kind), money = Config.ScrapValue }, "good")
end

-- an old part left lying (floor or cart) goes to the scrap pile by itself (main 10-21: no "Pick up" prompts piling
-- up around the bays): the scrap bin's money to whoever last had it in hand (or took it off), a small puff of dust
-- an old part set on the cart's old side is paid for there and then (rival_upgrade B1 ③: the core credit came 45 s
-- later, unseen) — once a part (Scrapped): it still lies there and goes to the pile later with no second pay
function CarryService.credit(player: Player, part: Instance)
	if not scrapPays(part) then
		return
	end
	part:SetAttribute("Scrapped", true)
	local kind = part:GetAttribute("PartKind")
	PlayerData.addMoney(player, Config.ScrapValue)
	if CarryService.onEarned then
		CarryService.onEarned(player, Config.ScrapValue)
	end
	local key = if kind == "Battery" then "n.coreReturn" else "n.scrapCredit"
	Remotes.Notify:FireClient(player, key, { part = "@part." .. tostring(kind), money = Config.ScrapValue }, "good")
	Remotes.Effect:FireClient(player, "credit", { money = Config.ScrapValue, pos = CarFactory.root(part).Position })
end

local function autoScrap(part: Instance)
	local root = CarFactory.root(part)
	local pos = root and root.Position
	local kind = part:GetAttribute("PartKind")
	local who = Players:GetPlayerByUserId((part:GetAttribute("Handler") :: number?) or 0) or PlayerData.owner()
	local pays = scrapPays(part)
	part:Destroy()
	if pos then
		Remotes.Effect:FireAllClients("puff", { pos = pos })
	end
	if who and pays then
		PlayerData.addMoney(who, Config.ScrapValue)
		if CarryService.onEarned then
			CarryService.onEarned(who, Config.ScrapValue)
		end
		Remotes.Notify:FireClient(who, "n.autoScrapped", { part = "@part." .. tostring(kind), money = Config.ScrapValue }, "good")
	end
end

local function watchOldParts()
	local freeSince: { [Instance]: number } = {}
	while true do
		task.wait(3)
		local now = os.clock()
		local lying = {}
		for _, part in CarFactory.looseFolder():GetChildren() do
			if part:GetAttribute("State") == "Free" and ((part:GetAttribute("Condition") :: number?) or 100) < 50 then
				lying[part] = true
				local t = freeSince[part]
				if not t then
					freeSince[part] = now
				elseif now - t >= Config.OldPartScrapSeconds then
					autoScrap(part)
				end
			end
		end
		for part in freeSince do
			if not lying[part] or not part.Parent then
				freeSince[part] = nil -- (picked up, gone: the clock starts again next time it's set down)
			end
		end
	end
end

function CarryService.start()
	Remotes.Drop.OnServerEvent:Connect(Guard.wrap("Drop", 0.15, CarryService.drop))
	Remotes.Install.OnServerEvent:Connect(Guard.wrap("Install", 0.15, function(player, car, slotName)
		if type(slotName) == "string" then
			CarryService.install(player, car, slotName)
		end
	end))
	local bin = Places.scrapBin()
	local p = Instance.new("ProximityPrompt")
	p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
	p.Name = "ScrapPrompt"
	p.KeyboardKeyCode = Enum.KeyCode.E
	p.MaxActivationDistance = Config.PromptDistance
	p.RequiresLineOfSight = false
	Locale.tag(p, "act.scrap")
	Locale.tag(p, "obj.scrapBin", nil, "ObjectText")
	p.Parent = bin
	p.Triggered:Connect(Guard.prompt(p, "Scrap", 0.5, scrap))
	task.spawn(watchOldParts)

	-- no carrying through death / leaving; tools stay off while both hands are busy
	local function onChar(player: Player, char: Model)
		carrying[player] = nil
		char.ChildAdded:Connect(function(child)
			local part = CarryService.carried(player)
			if child:IsA("Tool") and part and part:GetAttribute("CarryMode") ~= "OneHand" then
				task.defer(function()
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then
						hum:UnequipTools()
					end
				end)
			end
		end)
		local hum = char:WaitForChild("Humanoid") :: Humanoid
		hum.Died:Connect(function()
			if CarryService.carried(player) then
				CarryService.drop(player)
			end
		end)
	end
	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(function(char)
			onChar(player, char)
		end)
		if player.Character then
			onChar(player, player.Character)
		end
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, plr in Players:GetPlayers() do
		onPlayer(plr)
	end
	Players.PlayerRemoving:Connect(function(player)
		if CarryService.carried(player) then
			CarryService.drop(player)
		end
		putAway[player] = nil
	end)
end

return CarryService
