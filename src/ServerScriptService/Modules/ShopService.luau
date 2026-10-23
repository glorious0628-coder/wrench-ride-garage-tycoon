-- Parts counter (world_contract PartsCounter): a "Buy parts" prompt opens the client's shop window; BuyPart checks
-- reach, money and how many bought parts you already have lying around, then a new part (bolts loose) appears
-- on the counter's HandoverPoint.
-- The tutorial's first car (tutorial_script v0.2 D): its battery can be ordered from the job card ("cart") — no walk,
-- it lands by the bay 2 s later. On the third tutorial car a part it doesn't need gets "Wrong part. Sell it back".
-- Any customer car (rival_upgrade B2-4): BuyPart(kind, "job") orders the part a found fault needs onto that car's cart
-- from anywhere — the job card / work view's Order button (ShopService.foundNeed).

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarryService = require(script.Parent.CarryService)
local CarFactory = require(script.Parent.CarFactory)
local PlayerData = require(script.Parent.PlayerData)
local Places = require(script.Parent.Places)
local Guard = require(script.Parent.Guard)

local ShopService = {}

local stack = 0

local function tutorialCar(stage: number): Model?
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:GetAttribute("Tutorial") == stage and c:GetAttribute("Parked") then
			return c :: Model
		end
	end
	return nil
end

-- does this tutorial car need a part of that kind (any of its faults)
local function needs(car: Model, kind: string): boolean
	for _, slot in string.split((car:GetAttribute("Faults") :: string?) or "", ",") do
		local s = CarParts.Slots[slot]
		if s and s.kind == kind then
			return true
		end
	end
	return false
end

-- the car this player last worked on needs a `kind` part for a fault already found on it (a clue names its slot)
function ShopService.foundNeed(player: Player, kind: string): boolean
	local cars = workspace:FindFirstChild("Cars")
	local car: Instance? = nil
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:GetAttribute("CarId") == player:GetAttribute("LastCar") then
			car = c
		end
	end
	if not car or not car:GetAttribute("Parked") or not needs(car :: Model, kind) then
		return false
	end
	local ok, list = pcall(HttpService.JSONDecode, HttpService, (car:GetAttribute("Clues") :: string?) or "[]")
	for _, clue in (if ok and type(list) == "table" then list else {}) do
		local slot = type(clue) == "table" and clue.a and clue.a.slot
		local s = slot and CarParts.Slots[slot]
		if s and s.kind == kind and table.find(string.split((car:GetAttribute("Faults") :: string?) or "", ","), slot) then
			return true
		end
	end
	return false
end

local ordered: { [Player]: number } = {} -- (cart orders still on their way: they count too — exploit audit L5)
local function looseCount(player: Player): number
	local n = ordered[player] or 0
	for _, p in CarFactory.looseFolder():GetChildren() do
		if p:GetAttribute("BoughtBy") == player.UserId and p:GetAttribute("State") ~= "Installed" then
			n += 1
		end
	end
	return n
end

local function buy(player: Player, kind: any, deliver: any): (boolean, string?, { [string]: any }?)
	if type(kind) ~= "string" or not CarParts.Kinds[kind] or not CarParts.sold(kind) then
		return false
	end
	local service, handover = Places.partsCounter()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not service or not handover or not root then
		return false
	end
	-- the first car's battery, ordered from the job card: no walk to the counter
	local first = tutorialCar(1)
	local cart = deliver == "cart" and first ~= nil and kind == "Battery" and ShopService.cartSpot and ShopService.cartSpot(first :: Model)
	-- (rival_upgrade B2-4) the found part of the car you work on, ordered from the job card / work view: same price,
	-- onto that car's cart — only a part a found fault needs (a wrong guess is still bought at the counter)
	local job = deliver == "job" and ShopService.foundNeed(player, kind)
	if not cart and not job and (root.Position - service.Position).Magnitude > Config.ShopReach then
		return false, "n.tooFar"
	end
	if looseCount(player) >= Config.MaxLooseParts then
		return false, "n.tooManyParts"
	end
	local price = CarParts.Kinds[kind].price
	if not PlayerData.spend(player, price) then
		return false, "n.noMoney"
	end
	if cart then
		ordered[player] = (ordered[player] or 0) + 1
		task.delay(2, function()
			ordered[player] = if (ordered[player] or 0) > 1 then ordered[player] - 1 else nil
			if player.Parent then
				local part = CarryService.spawnNew(kind, cart :: CFrame, player)
				if part and first and first.Parent then
					part:SetAttribute("OnCart", first:GetAttribute("CarId")) -- (on the cart: the cart view can pick it up — test 1 #2)
				end
			end
		end)
		return true, "n.ordered", { part = "@part." .. kind, price = price }
	end
	-- the bay's cart (work_view 4): parts bought at the counter land on the cart of the car you work on
	if ShopService.deliver and ShopService.deliver(player, function(cf)
		return CarryService.spawnNew(kind, cf, player)
	end) then
		local third = tutorialCar(3)
		if third and not needs(third, kind) then
			task.delay(0.8, function()
				Remotes.Notify:FireClient(player, "n.wrongPart", nil, "info")
			end)
		end
		return true, "n.toCart", { part = "@part." .. kind, price = price }
	end
	local third = tutorialCar(3)
	if third and not needs(third, kind) then
		task.delay(0.8, function()
			Remotes.Notify:FireClient(player, "n.wrongPart", nil, "info")
		end)
	end
	-- a few spots along the counter top so parts don't pile into each other; big ones go on the floor in front
	stack = (stack % 3) + 1
	local carry = CarParts.Kinds[kind].carry
	local at: CFrame
	local shelfSpot = ShopService.shelfSpot and ShopService.shelfSpot()
	if shelfSpot then
		at = shelfSpot -- the Parts Shelf upgrade: it waits in the bay (alpha_scope §3)
	elseif carry == "OneHand" then
		at = handover.CFrame * CFrame.new((stack - 2) * 2, 0, 0)
	else
		at = service.CFrame * CFrame.new((stack - 2) * 2.5, 0, 1.5) -- behind you, in the bay
	end
	CarryService.spawnNew(kind, at, player)
	return true, "n.boughtPart", { part = "@part." .. kind, price = price }
end

-- set by Main: where the tutorial's ordered part lands (WorkService.cartSpot), and the cart delivery
ShopService.cartSpot = nil :: ((car: Model) -> CFrame?)?
ShopService.deliver = nil :: ((player: Player, spawn: (CFrame) -> Instance?) -> boolean)?

-- set by Main when the garage has the Parts Shelf: a free slot's CFrame, or nil
ShopService.shelfSpot = nil :: (() -> CFrame?)?

function ShopService.start()
	Remotes.BuyPart.OnServerInvoke = Guard.wrap("BuyPart", 0.25, buy)
	local service = Places.partsCounter()
	if service then
		local p = Instance.new("ProximityPrompt")
		p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
		p.Name = "ShopPrompt"
		p.KeyboardKeyCode = Enum.KeyCode.E
		p.MaxActivationDistance = Config.PromptDistance
		p.RequiresLineOfSight = false
		Locale.tag(p, "act.shop")
		Locale.tag(p, "obj.partsCounter", nil, "ObjectText")
		p.Parent = service
	end
end

return ShopService
