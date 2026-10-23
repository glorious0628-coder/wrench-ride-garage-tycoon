-- Loop B step 3 (docs/design/flip_loop.md v0.2 §1-1, §5-7): selling a restored car.
--   Dealer window (Junkyard.Office.ServicePoint / Showroom.SellDesk): your finished cars with
--     Sell now  — to the dealer right away, Config.QuickSellRate x market value (always there)
--     State Inspection — a SALVAGE car that's fixed (every mechanical fault) becomes REBUILT
--     Put in showroom — Showroom.DisplaySpots.SpotN (unlocked by level); not SALVAGE (inspect first), not unsafe
--   Buyers (one at a time, only while you're online): BuyerSpawn -> BuyerDoor -> Lobby -> the car's ViewPoint ->
--   wait by the SellDesk. "Hear the offer" (the car's owner) -> haggle: Accept / Counter +5% / +10% / Decline.
--   The buyer's offer comes from the market value (never the price tag), at most Config.SaleCap x market value.
--   A turned-down counter: their offer is still on the table once more; their mood drops, at 0 they walk.
-- Market value = Config.RestoredValue x title x restoration % x (1 + service records + one owner).
-- Money: the owner first gets back what they paid for the wreck, the profit is split (Config.FlipShare).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local CustomerService = require(script.Parent.CustomerService)
local PlayerData = require(script.Parent.PlayerData)
local Places = require(script.Parent.Places)
local Guard = require(script.Parent.Guard)

local ShowroomService = {}
ShowroomService.onSold = nil :: ((p: Player, money: number) -> ())? -- ShiftService.sold

local rng = Random.new()
local display: { [number]: Model } = {}
local buyer: { npc: Model, car: Model, kind: string, offer: number?, failed: number, mood: number, talking: Player? }? = nil
local nextBuyerAt = 0
local nextIndex = 1

local function myCars(player: Player): { Model }
	local out = {}
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:IsA("Model") and c:GetAttribute("Restored") and c:GetAttribute("OwnerId") == player.UserId then
			table.insert(out, c)
		end
	end
	return out
end

-- market value + the small things that move it (shown as lines on the price tag / dealer window)
function ShowroomService.value(car: Model): (number, { { k: string, a: { [string]: any }? } })
	local title = car:GetAttribute("Title") :: string
	local pct = ((car:GetAttribute("RestorePct") :: number?) or 0) / 100
	local base = Config.RestoredValue * (Config.TitleValue[title] or 0) * pct
	local bonus, lines = 0, {}
	if car:GetAttribute("Safe") then
		bonus += Config.ValueBonus.ServiceRecords
		table.insert(lines, { k = "val.records" })
	end
	if car:GetAttribute("OneOwner") then
		bonus += Config.ValueBonus.OneOwner
		table.insert(lines, { k = "val.oneOwner" })
	end
	return math.floor(base * (1 + bonus) / 10) * 10, lines
end

local function nearDealer(player: Player): boolean
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return false
	end
	for _, path in { "Junkyard.Office.ServicePoint", "Showroom.SellDesk" } do
		local m = Places.find(path) :: BasePart?
		if m and (m.Position - root.Position).Magnitude <= Config.ShopReach then
			return true
		end
	end
	return false
end

local function freeSpot(): number?
	local spots = Places.find("Showroom.DisplaySpots")
	if not spots then
		return nil
	end
	local level = PlayerData.garageLevel()
	for i = 1, 6 do
		local s = spots:FindFirstChild("Spot" .. i)
		if s and not display[i] and ((s:GetAttribute("UnlockLevel") :: number?) or 1) <= level then
			return i
		end
	end
	return nil
end

local function setTag(i: number, text: string)
	local tag = Places.find("Showroom.PriceTags.Spot" .. i .. ".Label.Price") :: TextLabel?
	if tag and tag:IsA("TextLabel") then
		tag.Text = text
	end
end

-- what the dealer window shows for one car
local function row(car: Model): { [string]: any }
	local value = ShowroomService.value(car)
	local title = car:GetAttribute("Title") :: string
	local reason: string? = nil
	if car:GetAttribute("Display") then
		reason = "dl.inShowroom"
	elseif title == "Salvage" then
		reason = "dl.needInspection"
	elseif not car:GetAttribute("Safe") then
		reason = "dl.unsafe"
	elseif not Places.find("Showroom.DisplaySpots") then
		reason = "dl.noShowroom"
	elseif not freeSpot() then
		reason = "dl.showroomFull"
	end
	return {
		id = car:GetAttribute("CarId"),
		title = title,
		pct = car:GetAttribute("RestorePct"),
		grade = car:GetAttribute("Grade"),
		value = value,
		quick = math.floor(value * Config.QuickSellRate / 10) * 10,
		canInspect = title == "Salvage" and car:GetAttribute("Safe") == true,
		canDisplay = reason == nil,
		reason = reason,
	}
end

local function carById(player: Player, id: any): Model?
	for _, c in myCars(player) do
		if c:GetAttribute("CarId") == id then
			return c
		end
	end
	return nil
end

-- the car leaves (sold): free its place
local function remove(car: Model)
	local i = car:GetAttribute("Display") :: number?
	if i then
		display[i] = nil
		setTag(i, "")
	end
	local restore = Places.find("RestoreBay")
	if restore and restore:GetAttribute("CarId") == car:GetAttribute("CarId") then
		restore:SetAttribute("CarId", nil)
	end
	CarService.forget(car)
	car:Destroy()
end

-- pay out a sale: the owner gets the wreck price back first, then the profit is split (flip_loop §7)
local function pay(car: Model, price: number)
	local owner = Players:GetPlayerByUserId(car:GetAttribute("OwnerId") :: number)
	local paid = (car:GetAttribute("PaidPrice") :: number?) or 0
	local crew = {}
	if owner then
		table.insert(crew, owner)
	end
	for _, p in CarService.helpers(car) do
		if p ~= owner and p.Parent then
			table.insert(crew, p)
		end
	end
	local got: { [Player]: number } = {}
	local profit = price - paid
	if owner then
		got[owner] = math.min(price, paid)
	end
	if profit > 0 and #crew > 0 then
		local shares = Config.FlipShare[math.min(#crew, #Config.FlipShare)]
		for k, p in crew do
			got[p] = (got[p] or 0) + math.floor(profit * (shares[k] or 0))
		end
	end
	local grade = (car:GetAttribute("Grade") :: string?) or "None"
	for k, p in crew do
		PlayerData.addMoney(p, got[p] or 0)
		if ShowroomService.onSold then
			ShowroomService.onSold(p, got[p] or 0) -- (today's receipt)
		end
		PlayerData.addRep(p, Config.FlipRep[grade] * (if k == 1 and p == owner then 1 else Config.HelperRep))
		Remotes.Notify:FireClient(p, "n.sold", { price = price, money = got[p] or 0 }, "good")
	end
end

local function sellNow(player: Player, car: Model): (boolean, string?, { [string]: any }?)
	if buyer and buyer.car == car then
		return false, "n.buyerLooking"
	end
	local value = ShowroomService.value(car)
	local price = math.floor(value * Config.QuickSellRate / 10) * 10
	pay(car, price)
	remove(car)
	return true
end

local function inspect(player: Player, car: Model): (boolean, string?, { [string]: any }?)
	if car:GetAttribute("Title") ~= "Salvage" then
		return false
	end
	if not car:GetAttribute("Safe") then
		return false, "n.inspectFail"
	end
	car:SetAttribute("Title", "Rebuilt")
	return true, "n.inspectPass"
end

local function put(player: Player, car: Model): (boolean, string?, { [string]: any }?)
	local r = row(car)
	if not r.canDisplay then
		return false, r.reason
	end
	local i = freeSpot() :: number
	local spot = Places.find("Showroom.DisplaySpots.Spot" .. i) :: BasePart
	local restore = Places.find("RestoreBay")
	if restore and restore:GetAttribute("CarId") == car:GetAttribute("CarId") then
		restore:SetAttribute("CarId", nil) -- the restoration bay is free for the next wreck
	end
	display[i] = car
	car:SetAttribute("Display", i)
	car:SetAttribute("LiftOffset", 0)
	car:SetAttribute("BaseCFrame", spot.CFrame)
	CarFactory.setDetail(car, "Lite") -- off the bay: each screen picks by distance
	CarFactory.pose(car)
	setTag(i, Locale.money(r.value))
	if nextBuyerAt < os.clock() + Config.BuyerFirst then
		nextBuyerAt = os.clock() + Config.BuyerFirst
	end
	return true, "n.displayed"
end

local function dealer(player: Player, action: any, id: any): any
	if not nearDealer(player) then
		return false, "n.tooFar"
	end
	if action == "list" then
		local out = {}
		for _, c in myCars(player) do
			table.insert(out, row(c))
		end
		return out
	end
	local car = carById(player, id)
	if not car then
		return false
	end
	if action == "sell" then
		return sellNow(player, car)
	elseif action == "inspect" then
		return inspect(player, car)
	elseif action == "display" then
		return put(player, car)
	end
	return false
end

---------------------------------------------------------------------------------------------------------- buyers

local function chance(kind: string, size: string, car: Model): number
	local t = Config.Haggle[kind]
	local c = t[size]
	if kind == "Collector" and car:GetAttribute("Grade") == "Gold" then
		c += Config.Haggle.GoldBonus
	end
	return math.clamp(c - (if buyer then buyer.failed else 0) * Config.Haggle.FailDrop, 0.05, 0.95)
end

local function label(c: number): string
	return if c >= 0.7 then "Likely" elseif c >= 0.4 then "Maybe" else "Risky"
end

local function view(): { [string]: any }
	local b = buyer :: any
	local value = ShowroomService.value(b.car)
	local cap = math.floor(value * Config.SaleCap)
	return {
		kind = b.kind,
		offer = b.offer,
		value = value,
		mood = b.mood,
		ask5 = math.min(cap, math.floor(b.offer * 1.05)),
		ask10 = math.min(cap, math.floor(b.offer * 1.10)),
		c5 = label(chance(b.kind, "c5", b.car)),
		c10 = label(chance(b.kind, "c10", b.car)),
		grade = b.car:GetAttribute("Grade"),
		pct = b.car:GetAttribute("RestorePct"),
	}
end

local function showMood()
	local b = buyer
	local fill = b and b.npc:FindFirstChild("Fill", true) :: Frame?
	if b and fill then
		fill.Size = UDim2.new(math.clamp(b.mood, 0, 1), 0, 1, 0)
		fill.BackgroundColor3 = if b.mood > 0.6 then Color3.fromRGB(90, 210, 110) elseif b.mood > 0.3 then Color3.fromRGB(240, 190, 60) else Color3.fromRGB(230, 80, 60)
	end
end

local function buyerLeaves(say: string)
	local b = buyer
	if not b then
		return
	end
	buyer = nil
	nextBuyerAt = os.clock() + rng:NextInteger(Config.BuyerEvery[1], Config.BuyerEvery[2])
	if b.talking and b.talking.Parent then
		Remotes.Haggle:FireClient(b.talking, nil) -- close the window
	end
	local prompt = b.npc:FindFirstChild("OfferPrompt", true)
	if prompt then
		prompt:Destroy()
	end
	CustomerService.speak(b.npc, say, 4)
	task.spawn(function()
		task.wait(1.5)
		CustomerService.walkTo(b.npc, (Places.find("Showroom.BuyerDoor") :: BasePart).Position)
		CustomerService.walkTo(b.npc, (Places.find("Showroom.BuyerSpawn") :: BasePart).Position)
		b.npc:Destroy()
	end)
end

local function sold(price: number)
	local b = buyer :: any
	pay(b.car, price)
	remove(b.car)
	buyerLeaves("buyer.deal")
end

local function choose(player: Player, choice: any)
	local b = buyer
	if not b or b.talking ~= player or not b.offer then
		return
	end
	if choice == "accept" then
		sold(b.offer)
	elseif choice == "decline" then
		buyerLeaves("buyer.bye")
	elseif choice == "c5" or choice == "c10" then
		local v = view()
		local ask = if choice == "c5" then v.ask5 else v.ask10
		if rng:NextNumber() < chance(b.kind, choice, b.car) then
			sold(ask)
			return
		end
		b.failed += 1
		b.mood -= Config.Haggle.MoodDrop
		showMood()
		if b.mood <= 0.01 or b.failed > Config.Haggle.MaxCounters then
			buyerLeaves("buyer.walk")
			return
		end
		CustomerService.speak(b.npc, "buyer.no", 4)
		local nv = view()
		nv.refused = true
		Remotes.Haggle:FireClient(player, nv) -- their offer stays on the table once more
	end
end

local function hear(player: Player)
	local b = buyer
	if not b or b.car:GetAttribute("OwnerId") ~= player.UserId then
		return Remotes.Notify:FireClient(player, "n.notYourCar", nil, "bad")
	end
	if not b.offer then
		local value = ShowroomService.value(b.car)
		local r = Config.Haggle[b.kind].offer
		local k = r[1] + rng:NextNumber() * (r[2] - r[1])
		if b.kind == "Collector" and b.car:GetAttribute("Grade") == "Gold" then
			k += Config.Haggle.GoldOffer
		end
		b.offer = math.min(math.floor(value * k / 10) * 10, math.floor(value * Config.SaleCap))
	end
	b.talking = player
	CustomerService.speak(b.npc, "buyer.offer." .. b.kind, 5)
	Remotes.Haggle:FireClient(player, view())
end

local function pickKind(car: Model): string
	local w = table.clone(Config.BuyerWeights)
	if car:GetAttribute("Grade") == "Gold" then
		w.Collector *= 2
	end
	local total = 0
	for _, v in w do
		total += v
	end
	local r = rng:NextNumber() * total
	for _, kind in { "Quick", "Bargain", "Collector" } do
		r -= w[kind]
		if r <= 0 then
			return kind
		end
	end
	return "Quick"
end

local function spawnBuyer()
	local list = {}
	for i = 1, 6 do
		if display[i] and display[i].Parent then
			table.insert(list, i)
		end
	end
	if #list == 0 or #Players:GetPlayers() == 0 then
		return
	end
	nextIndex = (nextIndex % #list) + 1
	local i = list[nextIndex]
	local car = display[i]
	local kind = pickKind(car)
	local npc = CustomerService.makeNpc("Buyer" .. kind)
	local spawnAt = Places.find("Showroom.BuyerSpawn") :: BasePart?
	if not npc or not spawnAt then
		return
	end
	npc.Name = "Buyer"
	npc:PivotTo(spawnAt.CFrame + Vector3.new(0, 3, 0))
	npc.Parent = workspace
	buyer = { npc = npc, car = car, kind = kind, failed = 0, mood = 1 }
	showMood()
	local b = buyer :: any
	task.spawn(function()
		for _, path in { "Showroom.BuyerDoor", "Showroom.Lobby", "Showroom.ViewPoints.Spot" .. i } do
			CustomerService.walkTo(npc, (Places.find(path) :: BasePart?) and (Places.find(path) :: BasePart).Position)
		end
		if buyer ~= b then
			return
		end
		CustomerService.speak(npc, "buyer.look." .. kind, 4)
		task.wait(4)
		local desk = Places.find("Showroom.SellDesk") :: BasePart?
		if desk then
			CustomerService.walkTo(npc, (desk.CFrame * CFrame.new(3, 0, 0)).Position)
		end
		if buyer ~= b then
			return
		end
		local root = npc:FindFirstChild("HumanoidRootPart") :: BasePart
		local p = Instance.new("ProximityPrompt")
		p.Name = "OfferPrompt"
		p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
		p.KeyboardKeyCode = Enum.KeyCode.E
		p.MaxActivationDistance = Config.PromptDistance + 2
		p.RequiresLineOfSight = false
		Locale.tag(p, "act.hearOffer")
		Locale.tag(p, "npc.Buyer" .. kind, nil, "ObjectText")
		p.Parent = root
		p.Triggered:Connect(Guard.prompt(p, "Offer", 0.5, hear))
		CustomerService.speak(npc, "buyer.ready", 6)
		-- they wait a while at the desk, then go (the car stays on display for the next one)
		local t0 = os.clock()
		while buyer == b and os.clock() - t0 < Config.BuyerWait do
			task.wait(1)
		end
		if buyer == b and not b.talking then
			buyerLeaves("buyer.bye")
		end
	end)
end

function ShowroomService.start()
	Remotes.Dealer.OnServerInvoke = Guard.wrap("Dealer", 0, dealer) -- (the list comes right after each sale: not paced)
	Remotes.HaggleChoice.OnServerEvent:Connect(Guard.wrap("Haggle", 0.5, choose))
	task.spawn(function()
		while true do
			-- dealer prompts at the office window and the showroom desk
			for _, path in { "Junkyard.Office.ServicePoint", "Showroom.SellDesk" } do
				local m = Places.find(path)
				if m and not m:FindFirstChild("DealerPrompt") then
					local p = Instance.new("ProximityPrompt")
					p.Name = "DealerPrompt"
					p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
					p.KeyboardKeyCode = Enum.KeyCode.E
					p.MaxActivationDistance = Config.PromptDistance
					p.RequiresLineOfSight = false
					Locale.tag(p, "act.dealer")
					Locale.tag(p, "obj.dealer", nil, "ObjectText")
					p.Parent = m
				end
			end
			-- a sold / gone car frees its spot
			for i, car in display do
				if not car.Parent then
					display[i] = nil
					setTag(i, "")
				end
			end
			if not buyer and os.clock() >= nextBuyerAt then
				spawnBuyer()
				if not buyer then
					nextBuyerAt = os.clock() + 5
				end
			end
			if buyer and not buyer.npc.Parent then
				buyer = nil
			end
			task.wait(1)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		if buyer and buyer.talking == player then
			buyerLeaves("buyer.bye")
		end
	end)
end

return ShowroomService
