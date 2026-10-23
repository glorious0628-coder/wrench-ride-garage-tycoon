-- Map lookups by the names in docs/specs/world_contract.md (wr-builder). Only this file knows map names.
-- What the map doesn't have (an old place without World/) gets a plain stand-in here.

local Places = {}

local function garage(): Instance
	return workspace:WaitForChild("Garage")
end

local function find(path: string): Instance?
	local node: Instance? = garage()
	for name in path:gmatch("[^%.]+") do
		node = node and node:FindFirstChild(name)
	end
	return node
end
Places.find = find

-- unlocked bays (Placeholder = still pink, not built)
function Places.bays(): { Instance }
	local out = {}
	local bays = find("Bays")
	for _, b in (if bays then bays:GetChildren() else {}) do
		-- bays not bought yet aren't in workspace at all (World/Upgrades keeps them in ServerStorage)
		if b:FindFirstChild("CarSpot") and not b:GetAttribute("Placeholder") then
			table.insert(out, b)
		end
	end
	table.sort(out, function(a, b)
		return a.Name < b.Name
	end)
	return out
end

-- every bay with a lift: the customer bays + the restoration bay (when bought)
function Places.liftBays(): { Instance }
	local out = Places.bays()
	local restore = find("RestoreBay")
	if restore and restore:FindFirstChild("CarSpot") then
		table.insert(out, restore)
	end
	return out
end

-- the WAIT HERE stalls for the next customers (World/Curbside v23): Queue.QueueSpotN (car spot, nose to the bay),
-- QueueEntryN (where the car turns off the avenue), QueueApronN (through the curb cut, when there is one), WaveSpotN
-- (where the driver stands, facing the bay door)
export type Stall = { spot: BasePart, entry: BasePart?, apron: BasePart?, wave: BasePart? }
function Places.queueStalls(): { Stall }
	local out = {}
	local q = find("Queue")
	local i = 1
	while q and q:FindFirstChild("QueueSpot" .. i) do
		table.insert(out, {
			spot = q:FindFirstChild("QueueSpot" .. i) :: BasePart,
			entry = q:FindFirstChild("QueueEntry" .. i) :: BasePart?,
			apron = q:FindFirstChild("QueueApron" .. i) :: BasePart?,
			wave = q:FindFirstChild("WaveSpot" .. i) :: BasePart?,
		})
		i += 1
	end
	return out
end

-- the QUICK SERVICE stall (World/Curbside v23; folder CurbJob (car spot CarSpot) or Curb (CurbSpot)): the car spot
-- (nose to the shop), CurbEntry (where it turns off the avenue), CurbApron (through the curb cut, when there is one),
-- CurbExit (where it joins the drive lane, heading west), CustomerSpot (the driver waits there), Jug (the washer jug
-- the code hands out)
export type CurbStall = { spot: BasePart, entry: BasePart?, apron: BasePart?, exit: BasePart?, customer: BasePart?, jug: Instance? }
function Places.curbStall(): CurbStall?
	local c = find("CurbJob") or find("Curb")
	local spot = c and (c:FindFirstChild("CarSpot") or c:FindFirstChild("CurbSpot")) :: BasePart?
	if not c or not spot then
		return nil
	end
	return {
		spot = spot,
		entry = c:FindFirstChild("CurbEntry") :: BasePart?,
		apron = c:FindFirstChild("CurbApron") :: BasePart?,
		exit = c:FindFirstChild("CurbExit") :: BasePart?,
		customer = c:FindFirstChild("CustomerSpot") :: BasePart?,
		jug = c:FindFirstChild("Jug"),
	}
end

function Places.marker(parent: Instance, name: string): BasePart?
	return parent:FindFirstChild(name) :: BasePart?
end

function Places.partsCounter(): (BasePart?, BasePart?)
	return find("PartsCounter.ServicePoint") :: BasePart?, find("PartsCounter.HandoverPoint") :: BasePart?
end

-- the waiting room's coffee maker (World/ShopDetail: Garage.Dressing.CoffeeMaker), or nil — CoffeeService's prompt
function Places.coffeeMaker(): BasePart?
	local m = find("Dressing.CoffeeMaker") or find("WaitingRoom.CoffeeMaker")
	return if m and m:IsA("BasePart") then m else nil
end

-- WaitingRoom.Seats.Seat1..N (count them: more come with levels)
function Places.seats(): { Seat }
	local out = {}
	local seats = find("WaitingRoom.Seats")
	for _, s in (if seats then seats:GetChildren() else {}) do
		if s:IsA("Seat") then
			table.insert(out, s)
		end
	end
	table.sort(out, function(a, b)
		return a.Name < b.Name
	end)
	return out
end

-- where the scrap bin's prompt goes: ScrapBin.DropSpot (the bin's mouth); a plain bin if the map has none
function Places.scrapBin(): BasePart
	local bin = garage():FindFirstChild("ScrapBin")
	local spot = bin and (bin:FindFirstChild("DropSpot") or (bin:IsA("BasePart") and bin))
	if spot then
		return spot :: BasePart
	end
	local p = Instance.new("Part")
	p.Name = "ScrapBin"
	p.Size = Vector3.new(3.2, 3, 3.2)
	p.CFrame = CFrame.new(-11.2, 1.7, 14.2)
	p.Color = Color3.fromRGB(70, 96, 70)
	p.Material = Enum.Material.CorrodedMetal
	p.Anchored = true
	p:SetAttribute("Temporary", true)
	p.Parent = garage()
	return p
end

return Places
