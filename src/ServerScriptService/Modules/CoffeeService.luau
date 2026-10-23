-- Coffee for the waiting customers (user 10-22: "손님은 사무실에 앉아 있게 하자. 커피를 준다거나") — Features.Coffee.
--   The waiting room's coffee maker (map: Garage.Dressing.CoffeeMaker, found here at run time — World files stay as
--   they are) gets a "Pour coffee" hold prompt -> a paper cup in my right hand. Each customer gets a "Give coffee"
--   prompt (shown on a screen only while that player holds a cup: ClientModules/Coffee) -> the cup goes into their
--   hand, they say thanks and calm down a little (Config.CoffeeCalm), and the settlement pays the one who gave it a
--   coffee tip line (Config.CoffeeTip, JobService) — once per customer.
--   Server decides everything: Guard.prompt (in / near / rate), the cup really in my hand, one coffee a customer,
--   the tip from Config. A cup goes away when its holder picks up a part, takes out a tool, dies or leaves.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Places = require(script.Parent.Places)
local Guard = require(script.Parent.Guard)
local PlayerData = require(script.Parent.PlayerData)

local CoffeeService = {}

CoffeeService.carried = nil :: ((Player) -> Instance?)? -- CarryService.carried (Main): hands full = no pouring
CoffeeService.say = nil :: ((npc: Model, key: string, seconds: number?) -> ())? -- CustomerService's speech bubble
CoffeeService.sitCup = nil :: ((npc: Model, on: boolean) -> boolean)? -- CustomerService: the cup-in-hand sit (false = no animation yet)

local cups: { [Player]: Model } = {}

local WHITE = Color3.fromRGB(246, 244, 238)
local LID = Color3.fromRGB(92, 64, 48)
local SLEEVE = Color3.fromRGB(196, 150, 100)

-- a takeaway paper cup (casual: white cup, kraft sleeve, brown lid), standing on its own origin's bottom
local function makeCup(): Model
	local m = Instance.new("Model")
	m.Name = "CoffeeCup"
	local function piece(name: string, h: number, d: number, y: number, color: Color3): Part
		local p = Instance.new("Part")
		p.Name = name
		p.Shape = Enum.PartType.Cylinder
		p.Size = Vector3.new(h, d, d)
		p.CFrame = CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(90)) -- (the cylinder's axis = X: stood up)
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		p.CastShadow = false
		p.Parent = m
		return p
	end
	local body = piece("Cup", 0.62, 0.4, 0.31, WHITE)
	piece("Sleeve", 0.24, 0.43, 0.3, SLEEVE)
	piece("Lid", 0.08, 0.45, 0.65, LID)
	m.PrimaryPart = body
	return m
end

-- the cup into this hand (welded; the hand's down = along the hanging arm, so the cup stands in the fist)
local function holdIn(cup: Model, hand: BasePart, seated: boolean?)
	for _, w in cup:GetDescendants() do
		if w:IsA("WeldConstraint") then
			w:Destroy()
		end
	end
	local body = cup.PrimaryPart :: BasePart
	-- (the pivot = the cup body, a cylinder lying on its X: turned so X runs down the hand's own up axis)
	if seated then
		-- (Mech_SitCup: the forearm level, the hand's Z axis straight up. The R15 hand is a 1 x 0.3 x 1 block, so a cup
		-- "round" it only reads as held when the fist hides the cup's lower part and the top stands out of it: the cup's
		-- centre 0.58 up the hand — wr-anim 10-23, notes/playtest/wr-anim/coffee_v2/)
		cup:PivotTo(hand.CFrame * CFrame.new(0, -0.02, -0.58) * CFrame.Angles(0, math.rad(90), 0))
	else
		cup:PivotTo(hand.CFrame * CFrame.new(0, -0.3, -0.15) * CFrame.Angles(0, 0, math.rad(90)))
	end
	for _, p in cup:GetChildren() do
		if p:IsA("BasePart") then
			p.Anchored = false
			if p ~= body then
				local w = Instance.new("WeldConstraint")
				w.Part0, w.Part1 = body, p
				w.Parent = body
			end
		end
	end
	local w = Instance.new("WeldConstraint")
	w.Part0, w.Part1 = hand, body
	w.Parent = body
	cup.Parent = hand.Parent
end

-- sitting (the stock R15 sit has the arms hanging straight down — the cup dangled by the seat): it rests on the lap,
-- standing up it's back in the hand (Play 10-22)
local function onLap(cup: Model, npc: Model)
	local thigh = npc:FindFirstChild("RightUpperLeg") :: BasePart?
	local body = cup.PrimaryPart
	if not thigh or not body then
		return
	end
	for _, w in body:GetChildren() do
		if w:IsA("WeldConstraint") and (w.Part0 ~= body or not w.Part1 or not w.Part1:IsDescendantOf(cup)) then
			w:Destroy()
		end
	end
	cup:PivotTo(CFrame.new(thigh.Position + Vector3.new(0, thigh.Size.Z / 2 + 0.31, 0)) * CFrame.Angles(0, 0, math.rad(90)))
	local w = Instance.new("WeldConstraint")
	w.Part0, w.Part1 = thigh, body
	w.Parent = body
end

local function handOf(char: Model?): BasePart?
	local hand = char and (char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
	return if hand and hand:IsA("BasePart") then hand else nil
end

-- coffee opens for a player once THEIR tutorial is done (GPT r1·r2, notes/gpt/wr-dev/coffee_decision.md: the first
-- cars are for learning the repair; per player, not per garage — a friend who's done it plays it at a new friend's)
function CoffeeService.open(player: Player): boolean
	return Config.feature("Coffee") and ((PlayerData.tut(player) or 4) >= 4 or player:GetAttribute("TutSkip") == true) -- (skipped = done too: GPT r2)
end

function CoffeeService.holding(player: Player): boolean
	local cup = cups[player]
	if cup and not cup.Parent then
		CoffeeService.drop(player) -- (the hand went: the cup with it — the attribute too, or Pour stays hidden)
		return false
	end
	return cup ~= nil
end

-- the cup's gone; told = say so (a part picked up / a tool out — otherwise it reads as a bug: GPT r1 ⑦)
function CoffeeService.drop(player: Player, told: boolean?)
	local cup = cups[player]
	cups[player] = nil
	if cup then
		cup:Destroy()
		if told and player.Parent then
			Remotes.Notify:FireClient(player, "n.coffeeDown", nil, "info")
		end
	end
	if player.Parent then
		player:SetAttribute("HoldingCoffee", nil)
	end
end

local function pour(player: Player)
	if not CoffeeService.open(player) or CoffeeService.holding(player) then
		return
	end
	if CoffeeService.carried and CoffeeService.carried(player) then
		Remotes.Notify:FireClient(player, "n.handsFull", nil, "bad")
		return
	end
	local char = player.Character
	local hand = handOf(char)
	if not char or not hand then
		return
	end
	local tool = char:FindFirstChildOfClass("Tool")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if tool and hum then
		hum:UnequipTools() -- (a cup in the hand that held the wrench)
	end
	local cup = makeCup()
	holdIn(cup, hand)
	cups[player] = cup
	player:SetAttribute("HoldingCoffee", true)
	Remotes.Notify:FireClient(player, "n.coffeePoured", nil, "info")
end

-- the coffee into this customer's hand (CustomerService.offer made the prompt)
local function give(player: Player, car: Model, npc: Model, prompt: ProximityPrompt)
	if not Config.feature("Coffee") or not CoffeeService.holding(player) then
		return
	end
	if car:GetAttribute("CoffeeBy") ~= nil or car:GetAttribute("Leaving") or not car.Parent or not npc.Parent then
		return
	end
	local hand = handOf(npc)
	if not hand then
		return
	end
	local cup = cups[player]
	cups[player] = nil
	player:SetAttribute("HoldingCoffee", nil)
	car:SetAttribute("CoffeeBy", player.UserId) -- (marked first: one coffee, one tip — JobService pays it)
	prompt:Destroy()
	holdIn(cup, hand)
	local h = npc:FindFirstChildOfClass("Humanoid")
	if h then
		local function place(seated: boolean)
			if not cup.Parent then
				return
			end
			if seated then
				if CoffeeService.sitCup and CoffeeService.sitCup(npc, true) then
					holdIn(cup, hand, true) -- (in the right fist: the animation holds the arm up)
				else
					onLap(cup, npc) -- (no cup animation yet: on the lap as before)
				end
			else
				if CoffeeService.sitCup then
					CoffeeService.sitCup(npc, false)
				end
				holdIn(cup, hand)
			end
		end
		place(h.SeatPart ~= nil)
		h.Seated:Connect(place)
	end
	-- a calmer wait: the patience clock goes back a little (never past the moment they parked)
	local parked = car:GetAttribute("ParkedAt") :: number?
	if parked then
		car:SetAttribute("ParkedAt", math.min(parked + Config.CoffeeCalm, workspace:GetServerTimeNow()))
	end
	if CoffeeService.say then
		CoffeeService.say(npc, "say.coffeeThanks", 4)
	end
	local root = npc:FindFirstChild("HumanoidRootPart") :: BasePart?
	Remotes.Effect:FireAllClients("coffee", { pos = if root then root.Position + Vector3.new(0, 2.5, 0) else nil, npc = npc })
end

-- a "Give coffee" prompt on this customer (until they have one, or go)
function CoffeeService.offer(npc: Model, car: Model)
	if not Config.feature("Coffee") or car:GetAttribute("CoffeeBy") ~= nil or car:GetAttribute("Leaving") then
		return
	end
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local old = root:FindFirstChild("CoffeePrompt")
	if old then
		old:Destroy()
	end
	local p = Instance.new("ProximityPrompt")
	p.Name = "CoffeePrompt"
	p.KeyboardKeyCode = Enum.KeyCode.E
	p.HoldDuration = 0
	p.MaxActivationDistance = Config.PromptDistance
	p.RequiresLineOfSight = false
	p.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	Locale.tag(p, "act.giveCoffee")
	p.Parent = root
	p.Triggered:Connect(Guard.prompt(p, "CoffeeGive", 0.5, function(player)
		give(player, car, npc, p)
	end))
	car:GetAttributeChangedSignal("Leaving"):Connect(function()
		if car:GetAttribute("Leaving") and p.Parent then
			p:Destroy()
		end
	end)
	car.Destroying:Once(function()
		if p.Parent then
			p:Destroy()
		end
	end)
end

-- "Is there any coffee?" once, a while after they sat down (GPT r1 ⑤: nobody knows coffee is a thing until asked) —
-- only a car with a patience clock (not the first two tutorial cars), only while someone here has coffee open
function CoffeeService.ask(npc: Model, car: Model)
	task.delay(Config.CoffeeAskAfter, function()
		if not Config.feature("Coffee") or not npc.Parent or not car.Parent or car:GetAttribute("Leaving") or car:GetAttribute("NoPatience") or car:GetAttribute("CoffeeBy") ~= nil then
			return
		end
		local h = npc:FindFirstChildOfClass("Humanoid")
		if not h or not h.SeatPart then
			return
		end
		for _, p in Players:GetPlayers() do
			if CoffeeService.open(p) then
				if CoffeeService.say then
					CoffeeService.say(npc, "say.coffeeAsk", 5)
				end
				return
			end
		end
	end)
end

-- the coffee maker's prompt (the map's own block; a map without one has no coffee)
local function setupMaker()
	-- (the map can finish building after this starts — the Garage is there, its Dressing not yet: Play 10-23 had no
	-- Pour prompt at all. Look again for a while before giving up)
	local maker = Places.coffeeMaker()
	local t0 = os.clock()
	while not maker and os.clock() - t0 < 120 do
		task.wait(1)
		maker = Places.coffeeMaker()
	end
	if not maker or maker:FindFirstChild("PourPrompt") then
		return
	end
	local p = Instance.new("ProximityPrompt")
	p.Name = "PourPrompt"
	p.KeyboardKeyCode = Enum.KeyCode.E
	p.HoldDuration = Config.CoffeePour
	p.MaxActivationDistance = Config.PromptDistance
	p.RequiresLineOfSight = false
	Locale.tag(p, "act.pourCoffee")
	p.Parent = maker
	p.Triggered:Connect(Guard.prompt(p, "CoffeePour", 0.5, pour))
end

function CoffeeService.start()
	if not Config.feature("Coffee") then
		return
	end
	task.spawn(setupMaker)
	local function onChar(p: Player, char: Model)
		-- a tool out = the cup's put down (one hand, one thing)
		char.ChildAdded:Connect(function(c)
			if c:IsA("Tool") and cups[p] then
				CoffeeService.drop(p, true)
			end
		end)
		local hum = char:WaitForChild("Humanoid", 10) :: Humanoid?
		if hum then
			hum.Died:Connect(function()
				CoffeeService.drop(p)
			end)
		end
	end
	local function watch(p: Player)
		p.CharacterAdded:Connect(function(char)
			CoffeeService.drop(p)
			onChar(p, char)
		end)
		if p.Character then
			task.spawn(onChar, p, p.Character)
		end
	end
	for _, p in Players:GetPlayers() do
		watch(p)
	end
	Players.PlayerAdded:Connect(watch)
	Players.PlayerRemoving:Connect(CoffeeService.drop)
end

return CoffeeService
