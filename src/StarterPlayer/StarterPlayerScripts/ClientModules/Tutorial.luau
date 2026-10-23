-- The first 15 minutes, on this player's screen (docs/design/tutorial_script.md v0.2; server half = TutorialService).
-- No guide NPC: the car gives the clue, one task line under the job card, one arrow, one glow (bolts: only the next
-- one). The step is worked out from the tutorial car's state every tick, so it moves on whoever does the work (a
-- friend's bolt counts too) and never gets stuck on a missed event.
--   Stuck on the same step: 30 s the arrow blinks, 60 s the task line shakes + a one-line hint, 90 s a big glow
--   (the first car: 20 / 40 / 60 s - v0.2 aims at the engine starting within 180 s).
--   v0.2 first car: "Order a battery" right on the task strip (it lands by the bay), and a glowing spot by the car
--   to set the old battery down with one press. Third car = a small whodunit: no arrows, two suspect lines
--   ("Brakes?" / "Tire?") stamped by what the player finds, and why it was the tire when the car works again.
--   Players who already did their first job see "Help your friend - it's their first job!" instead.
--   "Skip tutorial" (top left): arrows and task lines off; the first job, its bonus and the rep stay.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)
local Carry = require(script.Parent.Carry)
local JobCard = require(script.Parent.JobCard)
local LevelCard = require(script.Parent.LevelCard)
local Shop = require(script.Parent.Shop)
local Hotbar = require(script.Parent.Hotbar)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)
local WorkView = require(script.Parent.WorkView)
local SoundPlayer = require(script.Parent.SoundPlayer)

local Tutorial = {}
Tutorial.target = nil :: Instance? -- what the arrow points at now (PromptFocus puts its prompt first)

type Step = { id: string, text: string?, args: { [string]: any }?, target: Instance?, glow: Instance?, tool: string?, shop: string?, hint: string?, drop: boolean?, order: string?, lines: { string }?, action: string? }

local player = Players.LocalPlayer
local taskFrame: Frame
local taskLabel: TextLabel
local tick: GuiObject
local toolLabel: TextLabel
local bannerLabel: TextLabel
local edgeArrow: Frame
local skipButton: TextButton
local arrow: Frame -- drawn on the screen over the target (follows it every frame)
local C = UIStyle.Color
local arrowTarget: Instance? = nil
local arrowScale = 1
local highlight: Highlight
local lastStep: string? = nil
local stepSince = os.clock()
local seen: { [string]: boolean } = {} -- one-off banners already shown
local orderButton: GuiObject
local actionButton: GuiButton -- "Try starting it" / "Press the brake" (Remotes.TryCar) — the door prompts are gone
local actionCar: Model? = nil
local actionWhat: string? = nil
local orderedAt = -math.huge -- (the button hides for a moment after a press: the battery is on its way)
local suspectLines: { TextLabel } = {}
local dropSpot: BasePart? = nil -- the first car's "set the old battery down here" spot (local)

-- one-line hints at 60 s (tutorial_script §5)
local HINTS = {
	start = "tut.hint.door", hood = "tut.hint.front", scan = "tut.hint.tapPart", buy = "tut.hint.counter",
	bolt = "tut.hint.bolt", liftout = "tut.hint.pickup", install = "tut.hint.carry", startup = "tut.hint.door",
	release = "tut.hint.release", brakes = "tut.hint.door", lift = "tut.hint.lift", piston = "tut.hint.piston",
	-- v0.3 (the work view)
	scancar = "tut.hint.scan", fromcart = "tut.hint.fromCart", tocart = "tut.hint.cart", jack = "tut.hint.jack",
	jacking = "tut.hint.pump", jackself = "tut.hint.stands", spin = "tut.hint.spin", rollwheel = "tut.hint.pickup",
	padsout = "tut.hint.pickup", wheeloff = "tut.hint.pickup", wheelback = "tut.hint.fromCart", lower = "tut.hint.lower",
	finalcheck = "tut.hint.scan",
}
local equippedFor: string? = nil -- the step the wrench was put in the hand for (once per step)

---------------------------------------------------------------------------------------------------- car state

local function partRoot(inst: Instance?): BasePart?
	if not inst then
		return nil
	end
	if inst:IsA("BasePart") then
		return inst
	end
	if inst:IsA("Model") then
		return inst.PrimaryPart
	end
	return nil
end

local function slotPart(car: Model, slot: string): Instance?
	for _, d in car:GetDescendants() do
		if d:GetAttribute("Slot") == slot and d:GetAttribute("PartKind") and d:GetAttribute("State") == "Installed" then
			return d
		end
	end
	return nil
end

local function isNew(p: Instance): boolean
	return ((p:GetAttribute("Condition") :: number?) or 100) >= 50
end

-- loose parts of a kind: popped off a car (Car.Detached) or on the floor / in someone's hands (LooseParts)
local function loose(kind: string): { Instance }
	local out = {}
	local folders = { workspace:FindFirstChild("LooseParts") }
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		table.insert(folders, c:FindFirstChild("Detached"))
	end
	for _, f in folders do
		for _, p in f:GetChildren() do
			if p:GetAttribute("PartKind") == kind then
				table.insert(out, p)
			end
		end
	end
	return out
end

local function newLoose(kind: string): Instance?
	for _, p in loose(kind) do
		if isNew(p) then
			return p
		end
	end
	return nil
end

local function oldLoose(kind: string): Instance?
	for _, p in loose(kind) do
		if not isNew(p) then
			return p
		end
	end
	return nil
end

-- the next bolt head to turn: the first in `order` that is still tight (loosen) / still loose (tighten)
local function nextBolt(part: Instance, order: { number }, wantTight: boolean): BasePart?
	for _, n in order do
		local h = part:FindFirstChild("Bolt_" .. n .. "_Head", true) :: BasePart?
		if h and (h:GetAttribute("Tight") == true) == wantTight then
			return h
		end
	end
	return nil
end

local function left(part: Instance): number
	return (part:GetAttribute("BoltsRemaining") :: number?) or 0
end

local function count(part: Instance): number
	return (part:GetAttribute("BoltCount") :: number?) or 0
end

local function snap(car: Model, slot: string): Attachment?
	return car.PrimaryPart and car.PrimaryPart:FindFirstChild("Snap_" .. slot) :: Attachment?
end

local function counter(): Instance?
	local g = workspace:FindFirstChild("Garage")
	local pc = g and g:FindFirstChild("PartsCounter")
	return pc and pc:FindFirstChild("ServicePoint")
end

local function hasClue(car: Model, prefix: string): boolean
	return (((car:GetAttribute("Clues") :: string?) or ""):find('"k":"' .. prefix, 1, true)) ~= nil
end

local function driver(car: Model): Instance?
	return car.PrimaryPart and car.PrimaryPart:FindFirstChild("DriverSide")
end

-- a part to install: in your hands -> its spot on the car; on the floor -> the part; none yet -> the counter
local function fetch(car: Model, kind: string, slot: string, buyText: string, putText: string): Step
	local held = Carry.held()
	if held and held:GetAttribute("PartKind") == kind and isNew(held) then
		return { id = "install", text = putText, target = snap(car, slot) }
	end
	if held and held:GetAttribute("PartKind") == kind then
		return { id = "carryold", text = putText, hint = "tut.setDown", drop = true }
	end
	local new = newLoose(kind)
	if new then
		return { id = "install", text = putText, target = partRoot(new), glow = new }
	end
	return { id = "buy", text = buyText, target = counter(), shop = kind }
end

-- the first car's drop spot: a glowing ring on the floor by the driver's side, one press sets the old battery down
local function dropSpotFor(car: Model): BasePart
	if dropSpot and dropSpot.Parent then
		return dropSpot
	end
	local p = Instance.new("Part")
	p.Name = "TutorialDropSpot"
	p.Shape = Enum.PartType.Cylinder
	p.Size = Vector3.new(0.1, 3.2, 3.2)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = Enum.Material.Neon
	p.Color = Color3.fromRGB(255, 220, 80)
	p.Transparency = 0.45
	local base = (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
	p.CFrame = base * CFrame.new(-9, 0.25, -3) * CFrame.Angles(0, 0, math.rad(90))
	local prompt = Instance.new("ProximityPrompt")
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = Config.PromptDistance
	prompt.RequiresLineOfSight = false
	Localizer.bind(prompt, "act.setDown")
	prompt.Triggered:Connect(function()
		Remotes.Drop:FireServer()
	end)
	prompt.Parent = p
	p.Parent = workspace
	dropSpot = p
	return p
end

local function clearDropSpot()
	if dropSpot then
		dropSpot:Destroy()
		dropSpot = nil
	end
end

-------------------------------------------------------------------------------------------------- the jobs
-- v0.3 (work_view 5): the same steps worked out from the car's state, now with the work view — scan first, the
-- engine bay / wheel views, the bay's cart instead of the floor, the floor jack and stands instead of the lift.
-- Players outside a work view still get the old way (prompts, the drop spot).

local function inZone(car: Model, zone: string): boolean
	return player:GetAttribute("WorkCar") == car:GetAttribute("CarId") and player:GetAttribute("WorkZone") == zone
end

-- a new part of a kind waiting on this car's cart (or anywhere loose)
local function onCart(car: Model, kind: string): Instance?
	local id = car:GetAttribute("CarId")
	for _, p in loose(kind) do
		if isNew(p) and p:GetAttribute("OnCart") == id then
			return p
		end
	end
	return newLoose(kind)
end

local function jackSpot(car: Model, name: string): Instance?
	return car.PrimaryPart and car.PrimaryPart:FindFirstChild(name)
end

-- holding a part: the old one goes on the cart (work view) / down anywhere; a new one goes on its spot
local function holding(car: Model, kind: string, slot: string, zone: string): Step?
	local held = Carry.held()
	if not held or held:GetAttribute("PartKind") ~= kind then
		return nil
	end
	if isNew(held) then
		if inZone(car, zone) and WorkView.cartView() then
			return { id = "back", text = "tut.putIn", hint = "tut.hint.back" } -- (test 3 ③-4: it said "drop it on the cart")
		end
		return { id = "install", text = "tut.putIn", target = snap(car, slot) }
	end
	if inZone(car, zone) then
		return { id = "tocart", text = "tut.toCart", hint = "tut.hint.cart" }
	end
	return nil
end

-- job 1: Rosa's sedan, a dead battery
local function job1(car: Model): Step
	if not car:GetAttribute("Parked") then
		return { id = "arrive", target = car.PrimaryPart }
	end
	if not hasClue(car, "clue.start.") then
		return { id = "start", text = "tut.tryStart", action = "start" }
	end
	if not car:GetAttribute("Scanned") and not car:GetAttribute("HoodOpen") then
		return { id = "scancar", text = "tut.scanCar" } -- (the job card's Scan button)
	end
	local bat = slotPart(car, "Battery")
	local h = holding(car, "Battery", "Battery", "EngineBay")
	if h then
		return h
	end
	if bat and not isNew(bat) then
		if not car:GetAttribute("HoodOpen") then
			return { id = "hood", text = "tut.openHood", target = partRoot(slotPart(car, "Hood")) }
		end
		if not bat:GetAttribute("Checked") then
			-- two suspects, battery or terminals (rival_upgrade B1 ⓪): either first, no wrong answer — the terminals
			-- wiggle tight and clean, the battery reads dead (and the diagnosis fee comes in, DiagnosisService)
			local wiggled = car:GetAttribute("TerminalsChecked") == true
			local lines = { "tut.susBattery", if wiggled then "tut.susTerminalsNo" else "tut.susTerminals" }
			return { id = "scan", text = "tut.checkBoth", lines = lines, target = partRoot(bat), glow = bat, tool = "Scanner", hint = if wiggled then nil else "tut.hint.terminals" }
		end
		-- (just ordered: it lands on the cart in CartDeliver — the bolts can start meanwhile; the strip still said "buy")
		local coming = os.clock() - orderedAt < Config.CartDeliver + 1.5
		if not coming and not onCart(car, "Battery") and not (Carry.held() and isNew(Carry.held() :: Instance)) then
			return { id = "buy", text = "tut.buyBattery", shop = "Battery", order = "Battery" }
		end
		if left(bat) > 0 then
			if inZone(car, "EngineBay") and WorkView.cartView() then
				return { id = "cartback", text = "tut.cartBack" } -- (wr-uidesign A④: the bolt steps' words were stale on the cart)
			end
			local b = nextBolt(bat, { 1, 2, 3 }, true)
			return { id = "bolt" .. left(bat), text = "tut.loosenBattery", target = b, glow = b, tool = "Wrench" }
		end
		return { id = "liftout", text = "tut.liftOut", target = partRoot(bat), glow = bat }
	end
	if not bat then
		-- the old one popped out and still sits by its spot: lift it out first
		local old = oldLoose("Battery")
		local spot = snap(car, "Battery")
		if old and spot and partRoot(old) and ((partRoot(old) :: BasePart).Position - spot.WorldPosition).Magnitude < 4 then
			return { id = "liftout", text = "tut.liftOut", target = partRoot(old), glow = old }
		end
		local held = Carry.held()
		if held and held:GetAttribute("PartKind") == "Battery" and not isNew(held) then
			-- outside the work view: a glowing spot right here to set it down (one press)
			local d = dropSpotFor(car)
			return { id = "carryold", text = "tut.setDownHere", target = d, glow = d, drop = true }
		end
		local new = onCart(car, "Battery")
		if new then
			return { id = "fromcart", text = "tut.fromCart", target = partRoot(new), glow = new, hint = if inZone(car, "EngineBay") then "tut.hint.fromCart" else nil }
		end
		if os.clock() - orderedAt < Config.CartDeliver + 1.5 then
			return { id = "coming", text = "tut.batteryComing" }
		end
		return { id = "buy", text = "tut.buyBattery", shop = "Battery", order = "Battery" }
	end
	if left(bat) < count(bat) then
		if inZone(car, "EngineBay") and WorkView.cartView() then
			return { id = "cartback", text = "tut.cartBack" }
		end
		local b = nextBolt(bat, { 2, 1, 3 }, false)
		return { id = "bolt" .. left(bat), text = "tut.tightenBattery", target = b, glow = b, tool = "Wrench" }
	end
	if not hasClue(car, "clue.start.ok") then
		return { id = "startup", text = "tut.startUp", action = "start" }
	end
	return { id = "release", text = "tut.handBack", target = car.PrimaryPart }
end

-- job 2: Tyler's sedan, worn front-left pads — the floor jack (the first tap shows the whole order)
local function job2(car: Model): Step
	if not car:GetAttribute("Parked") then
		return { id = "arrive", target = car.PrimaryPart }
	end
	if not hasClue(car, "clue.brake.") then
		return { id = "brakes", text = "tut.pressBrakes", action = "brake" }
	end
	local wheel = slotPart(car, "Wheel_FL")
	local pads = slotPart(car, "BrakePads_FL")
	local support = (car:GetAttribute("Support") :: string?) or "None"
	local moving = car:FindFirstChild("Moving")
	local cal = moving and moving:FindFirstChild("BrakeCaliper_FL")
	local here = inZone(car, "Wheel_FL")
	for _, kind in { "BrakePads", "Wheel" } do
		local h = holding(car, kind, kind .. "_FL", "Wheel_FL")
		-- (the old pads / the old wheel go on the cart; the wheel comes back on after the pads)
		if h and not (kind == "Wheel" and h.id == "tocart" and pads and isNew(pads) and left(pads) >= count(pads)) then
			return h
		end
	end
	if wheel or (pads and isNew(pads)) or not pads then
		if support ~= "StandsF" and (wheel and (not pads or not isNew(pads))) then
			if support == "None" then
				return { id = "jack", text = "tut.jackUp", target = jackSpot(car, "Jack_F") }
			end
			return { id = "jacking", text = "tut.jackUp" } -- (the demo / pump in progress)
		end
	end
	if not pads or not isNew(pads) then
		if wheel then
			if not here then
				return { id = "workwheel", text = "tut.workWheel", target = jackSpot(car, "Work_Wheel_FL") }
			end
			if left(wheel) > 0 then
				local b = nextBolt(wheel, { 1, 3, 5, 2, 4 }, true)
				return { id = "bolt" .. left(wheel), text = "tut.loosenNuts", target = b, glow = b, tool = "Wrench" }
			end
			return { id = "rollwheel", text = "tut.rollWheel", target = partRoot(wheel), glow = wheel }
		end
		local off = loose("Wheel")[1]
		if off and not isNew(off) and off:GetAttribute("OnCart") == nil and here then
			return { id = "wheeloff", text = "tut.toCart", target = partRoot(off), glow = off }
		end
		if pads then
			if left(pads) > 0 then
				local b = nextBolt(pads, { 1, 2 }, true)
				return { id = "bolt" .. left(pads), text = "tut.unbolt", target = b, glow = b, tool = "Wrench" }
			end
			return { id = "padsout", text = "tut.pullPads", target = partRoot(pads), glow = pads }
		end
		if cal and cal:GetAttribute("PistonIn") ~= true then
			return { id = "piston", text = "tut.piston", target = cal, glow = cal }
		end
		local new = onCart(car, "BrakePads")
		if new then
			return { id = "fromcart", text = if here then "tut.fromCart" else "tut.backToWork", target = if here then partRoot(new) else jackSpot(car, "Work_Wheel_FL"), glow = new, hint = if here then "tut.hint.fromCart" else nil }
		end
		return { id = "buy", text = "tut.buyPads", target = counter(), shop = "BrakePads", hint = if here then "tut.hint.exit" else nil }
	end
	if left(pads) < count(pads) then
		local b = nextBolt(pads, { 1, 2 }, false)
		return { id = "tighten", text = "tut.holdTighten", target = b, glow = b, tool = "Wrench" }
	end
	if not wheel then
		local w = loose("Wheel")[1]
		return { id = "wheelback", text = "tut.wheelBack", target = partRoot(w), glow = w, hint = if here then "tut.hint.fromCart" else nil }
	end
	if left(wheel) < count(wheel) then
		local b = nextBolt(wheel, { 1, 3, 5, 2, 4 }, false)
		return { id = "tightenwheel", text = "tut.holdTighten", target = b, glow = b, tool = "Wrench" }
	end
	if support ~= "None" then
		return { id = "lower", text = "tut.lowerCar", target = jackSpot(car, "Jack_F") }
	end
	if not hasClue(car, "clue.brake.ok") then
		return { id = "brakes", text = "tut.pressBrakes", action = "brake" }
	end
	if not car:GetAttribute("FinalChecked") then
		return { id = "finalcheck", text = "tut.finalCheck" } -- (the job card's Scan = the final check on a fixed car)
	end
	return { id = "release", text = "tut.handBack", target = car.PrimaryPart }
end

-- job 3: the small whodunit — "pulls left, flap-flap": brakes or the tire? No arrows: the suspect lines get stamped
-- by what the player finds (quiet brakes / the nail found by spinning the wheel in its work view)
local function job3(car: Model): Step
	if not car:GetAttribute("Parked") then
		return { id = "arrive" }
	end
	local wheel = slotPart(car, "Wheel_FL")
	local quiet = hasClue(car, "clue.brake.ok")
	local nail = car:GetAttribute("NailFound") == true or wheel == nil or isNew(wheel)
	local lines = { if quiet then "tut.susBrakesNo" else "tut.susBrakes", if nail then "tut.susTireYes" else "tut.susTire" }
	local support = (car:GetAttribute("Support") :: string?) or "None"
	if not nail then
		if inZone(car, "Wheel_FL") then
			return { id = "spin", text = "tut.findIt", lines = lines }
		end
		-- suspect one, the brakes: its button (tutorial_taps 🐞3); then the jack yourself — the stands are what open
		-- the wheel's work view, so it comes before the nail, not after (🐞4); then go spin the wheel
		if not quiet then
			return { id = "suspects", text = "tut.whatIsIt", lines = lines, action = "brake" }
		end
		if support ~= "StandsF" then
			return { id = "jackself", text = "tut.jackYourself", lines = lines }
		end
		return { id = "gowheel", text = "tut.findIt", lines = lines, hint = "tut.workWheel" }
	end
	if car:GetAttribute("Fixed") ~= true then
		-- (the jack: three moves yourself this time — work_view 2b; the counter opens on the wheels — test 1)
		if wheel and support ~= "StandsF" then
			return { id = "jackself", text = "tut.jackYourself", lines = lines, hint = "tut.noMachine", shop = "Wheel" }
		end
		return { id = "fixflat", text = "tut.fixFlat", lines = lines, hint = "tut.noMachine", shop = "Wheel" }
	end
	-- (still on the stands: down first, like the second car — test 1 #5)
	if support ~= "None" then
		return { id = "lower", text = "tut.lowerCar", lines = lines, target = jackSpot(car, "Jack_F") }
	end
	return { id = "release3", text = "tut.handBack", lines = lines }
end

------------------------------------------------------------------------------------------------------- drawing

local function banner(key: string, args: { [string]: any }?, seconds: number?)
	UIKit.setText(bannerLabel, key, args)
	local stroke = bannerLabel:FindFirstChildOfClass("UIStroke") :: UIStroke
	bannerLabel.TextTransparency = 0
	stroke.Transparency = 0
	UIKit.pop(bannerLabel, 0.4)
	local token = (bannerLabel:GetAttribute("Token") or 0) + 1
	bannerLabel:SetAttribute("Token", token)
	task.delay(seconds or 1.6, function()
		if bannerLabel:GetAttribute("Token") == token then
			TweenService:Create(bannerLabel, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.4), { Transparency = 1 }):Play()
		end
	end)
end

local function setTask(key: string?, args: { [string]: any }?)
	local text = if key then Localizer.t(key, args) else ""
	if taskLabel.Text == text then
		return
	end
	local had = taskLabel.Text ~= ""
	if had and key then
		-- the old line gets its check, then the new one pops in
		tick.Visible = true
		UIKit.pop(tick, 0.4)
		task.delay(0.45, function()
			tick.Visible = false
		end)
	end
	UIKit.setText(taskLabel, key, args)
	taskLabel.Visible = text ~= ""
	-- (a blocking card or window is up — the settlement, the counter: the strip is not shown behind it, one thing at a time)
	taskFrame.Visible = text ~= "" and HUD.gui():GetAttribute("WindowOpen") ~= true and not HUD.gui():FindFirstChild("LevelUp", true)
	if text ~= "" then
		UIKit.pop(taskFrame, 0.92)
	end
end

local function worldPos(t: Instance): Vector3?
	if t:IsA("Attachment") then
		return t.WorldPosition
	elseif t:IsA("BasePart") then
		return t.Position
	elseif t:IsA("Model") then
		return t:GetPivot().Position
	end
	return nil
end

local function place(step: Step?, stuck: number)
	local target = step and step.target
	local cam = workspace.CurrentCamera
	-- the floating arrow over the target (stuck 30 s+: it pulses bigger so it's hard to miss)
	-- (a shop / dealer window is open: no arrow over it)
	local gui = HUD.gui()
	for _, name in { "Shop", "EquipShop", "Dealer", "Settings" } do
		local w = gui:FindFirstChild(name) :: GuiObject?
		if w and w.Visible then
			target = nil
		end
	end
	arrowTarget = target
	arrowScale = if stuck > 30 then 1 + 0.35 * math.abs(math.sin(os.clock() * 5)) else 1
	-- the glow: the next bolt / the part (big after 90 s)
	local glow = step and step.glow
	highlight.Adornee = glow
	highlight.Enabled = glow ~= nil
	highlight.FillTransparency = if stuck > 90 then 0.45 else 1
	highlight.OutlineTransparency = 0.15 + 0.35 * (0.5 + 0.5 * math.sin(os.clock() * 6))
	-- target off screen: an arrow on the screen edge pointing at it
	local pos = target and worldPos(target)
	edgeArrow.Visible = false
	if pos and cam then
		local v, onScreen = cam:WorldToViewportPoint(pos)
		local size = cam.ViewportSize
		if not onScreen or v.X < 0 or v.Y < 0 or v.X > size.X or v.Y > size.Y then
			local center = size / 2
			local dir = Vector2.new(v.X, v.Y) - center
			if v.Z < 0 then
				dir = -dir
			end
			if dir.Magnitude > 1 then
				dir = dir.Unit
				local r = math.min(center.X, center.Y) - 40
				local inset = game:GetService("GuiService"):GetGuiInset()
				-- (kept above the tool bar at the bottom: wr-ui Hotbar)
				local hotbar = HUD.gui():FindFirstChild("Hotbar") :: GuiObject?
				local floor = if hotbar then hotbar.AbsolutePosition.Y + inset.Y - 30 else size.Y - 40
				-- ... and above the hint line too (wr-play R04: the edge ball for the tool in the bar sat on the first letter
				-- of "Wrench · press a bolt" — the hint's row lies between the tool bar and where the ball stopped)
				local hintLine = HUD.gui():FindFirstChild("Hint") :: GuiObject?
				if hintLine and hintLine.Visible and hintLine.AbsoluteSize.Y > 0 then
					floor = math.min(floor, hintLine.AbsolutePosition.Y + inset.Y - edgeArrow.AbsoluteSize.Y / 2 - 6)
				end
				edgeArrow.Position = UDim2.fromOffset(center.X + dir.X * r, math.min(center.Y + dir.Y * r, floor) - inset.Y)
				edgeArrow.Rotation = math.deg(math.atan2(dir.Y, dir.X)) - 90 -- the "v" points along dir
				edgeArrow.Visible = true
			end
		end
	end
	-- the tool to pick: its hot-bar slot bobs (wr-ui Hotbar)
	toolLabel.Visible = false
	Hotbar.nudge(if step then step.tool else nil)
	-- carrying the old battery around: the Drop button bounces
	local drop = HUD.gui():FindFirstChild("Drop", true) :: GuiObject?
	if drop then
		local scale = drop:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		scale.Parent = drop
		scale.Scale = if step and step.drop then 1 + 0.12 * math.abs(math.sin(os.clock() * 5)) else 1
	end
	-- the task line: the top-left column (the work view) or under the Skip button
	if HUD.gui():GetAttribute("WorkView") then
		-- a work view: the top-left corner under the top bar, the one spot over no engine-bay part on a phone
		-- (wr-ui, GPT workview_phone r1 — Skip waits outside)
		taskFrame.AnchorPoint = Vector2.new(0, 0)
		taskFrame.Position = UDim2.new(0, 16, 0, 8)
	else
		-- the left column under the Skip button on every screen (wr-uidesign A④: it sat under the job card on an 844 phone
		-- and on the left on a 667 one — one place to look), clear of the job card and the jump button
		taskFrame.AnchorPoint = Vector2.new(0, 0)
		taskFrame.Position = UDim2.new(0, 16, 0, 94)
	end
	-- 60 s: shake + the step's one-line hint
	if step and stuck > 60 then
		taskFrame.Rotation = math.sin(os.clock() * 25) * (if stuck % 4 < 0.6 then 2 else 0)
	else
		taskFrame.Rotation = 0
	end
end

local function compare(kind: string)
	-- before -> a short pause -> after, played once by itself (the job card buttons replay it). The battery's is heard
	-- at the real start (click, a breath, vroom: DiagnosisService), so only the brakes are replayed here.
	if kind ~= "BrakePads" then
		return
	end
	task.spawn(function()
		JobCard.compare("before", kind)
		task.wait(1.8)
		if HUD.proof then
			HUD.proof("ui.proof.brakeQuiet") -- (quiet brakes have no sound: the green check)
		else
			JobCard.compare("after", kind)
		end
	end)
end

local function tutorialCar(stage: number): Model?
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c:GetAttribute("Tutorial") == stage then
			return c :: Model
		end
	end
	return nil
end

-- a window is up: the strip steps back to 35% see-through (still readable — dim, don't hide: wr-ui / GPT)
local DIM = 0.35
local dimmed: { [Instance]: { [string]: number } } = {}
local DIM_PROPS = {
	GuiObject = { "BackgroundTransparency" },
	TextLabel = { "TextTransparency", "TextStrokeTransparency" },
	TextButton = { "TextTransparency", "TextStrokeTransparency" },
	ImageLabel = { "ImageTransparency" },
	ImageButton = { "ImageTransparency" },
	UIStroke = { "Transparency" },
}
local function dimStrip(on: boolean)
	if not on then
		for inst, base in dimmed do
			for prop, v in base do
				(inst :: any)[prop] = v
			end
		end
		table.clear(dimmed)
		return
	end
	local all = taskFrame:GetDescendants()
	table.insert(all, taskFrame)
	for _, d in all do
		if dimmed[d] then
			continue
		end
		local base = {}
		for class, props in DIM_PROPS do
			if d:IsA(class) then
				for _, prop in props do
					local v = (d :: any)[prop]
					base[prop] = v
					;(d :: any)[prop] = v + (1 - v) * DIM
				end
			end
		end
		if next(base) then
			dimmed[d] = base
		end
	end
end

local hiddenForLevel = false
local function update()
	local stage = player:GetAttribute("Tut") :: number?
	local skipped = player:GetAttribute("TutSkip") == true
	skipButton.Visible = stage ~= nil and stage < 4 and not skipped and not HUD.gui():GetAttribute("WorkView")
	local step: Step? = nil
	local hintKey: string? = nil
	if stage and stage < 4 and not skipped then
		local car = tutorialCar(stage)
		if stage == 1 and car then
			step = job1(car)
		elseif stage == 2 and car then
			step = job2(car)
		elseif stage == 3 and car then
			step = job3(car)
			hintKey = "tut.goal3"
		end
		if not (stage == 1 and step and step.target == dropSpot) then
			clearDropSpot()
		end
		-- one-off moments
		if car and stage == 1 and car:GetAttribute("Parked") and not seen.first then
			seen.first = true
			banner("tut.firstJob", nil, 1.2)
		end
		local bat = car and stage == 1 and slotPart(car, "Battery")
		if bat and bat:GetAttribute("Checked") and not isNew(bat) and not seen.found then
			seen.found = true
			banner("tut.foundBattery")
		end
		if car and stage == 1 and not seen.cartArrive then
			local id = car:GetAttribute("CarId")
			for _, p in loose("Battery") do
				if isNew(p) and p:GetAttribute("OnCart") == id then
					seen.cartArrive = true
					banner("tut.cartArrive")
				end
			end
		end
		if car and stage == 1 and hasClue(car, "clue.start.ok") and not seen.startOk then
			seen.startOk = true
			compare("Battery")
		end
		if car and stage == 2 and not slotPart(car, "BrakePads_FL") and oldLoose("BrakePads") and not seen.worn then
			seen.worn = true
			banner("tut.worn")
		end
		if car and stage == 2 and hasClue(car, "clue.brake.ok") and not seen.quiet then
			seen.quiet = true
			compare("BrakePads")
		end
		-- the old battery can go in the scrap bin (optional, never blocks)
		if stage == 2 and not car and oldLoose("Battery") then
			hintKey = "tut.scrap"
		end
	else
		clearDropSpot()
	end
	if not stage or stage >= 4 then
		-- a friend's first job: one line for the helpers
		for _, p in Players:GetPlayers() do
			local t = p:GetAttribute("Tut") :: number?
			if p ~= player and t and t <= 2 and tutorialCar(t) then
				step = { id = "help", text = "tut.helpFriend" }
			end
		end
	end
	-- the same step for a while = stuck (a friend's progress changes the step id: the clock starts again)
	local id = step and step.id or nil
	if id ~= lastStep then
		lastStep = id
		stepSince = os.clock()
	end
	local stuck = os.clock() - stepSince
	if stage == 1 then
		stuck *= 1.5 -- the first car: 20 / 40 / 60 s instead of 30 / 60 / 90 (v0.2)
	end
	if step and stuck > 60 and HINTS[(step.id:gsub("%d+$", ""))] then
		hintKey = HINTS[(step.id:gsub("%d+$", ""))]
	elseif step and stuck > 20 and step.hint then
		hintKey = step.hint
	end
	-- in a work view, a bolt step puts the wrench in the hand (once per step; Assist: tutorial_script v0.3)
	if step and step.tool == "Wrench" and player:GetAttribute("WorkZone") and equippedFor ~= step.id then
		equippedFor = step.id
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local tool = player:FindFirstChildOfClass("Backpack") and (player :: any).Backpack:FindFirstChild("Wrench")
		if hum and tool and not char:FindFirstChild("Wrench") then
			hum:EquipTool(tool)
		end
	end
	Tutorial.target = if step and not skipped then step.target else nil
	setTask(step and step.text, step and step.args)
	-- the first car: order the battery right here (the button hides a moment after a press)
	orderButton.Visible = step ~= nil and step.order ~= nil and os.clock() - orderedAt > 4
	-- try the car: a button instead of a prompt by the driver's door
	local what = step and step.action
	if what ~= actionWhat then
		actionWhat = what
		if what then
			local wasDim = next(dimmed) ~= nil
			dimStrip(false) -- (setButton re-sets its looks: dim again after)
			UIKit.setButton(actionButton, nil, "Blue")
			-- (keyed, not plain text: a language change re-fills it)
			local label = actionButton:FindFirstChild("Label", true) :: TextLabel?
			if label then
				UIKit.setText(label, if what == "brake" then "tut.btnBrake" else "tut.btnStart")
			end
			dimStrip(wasDim)
		end
	end
	actionButton.Visible = what ~= nil
	actionCar = tutorialCar((player:GetAttribute("Tut") :: number?) or 0)
	-- the third car's suspects
	for i, l in suspectLines do
		local key = step and step.lines and step.lines[i]
		l.Visible = key ~= nil
		if key then
			UIKit.setText(l, key)
			l.TextColor3 = if key == "tut.susTireYes" then Color3.fromRGB(190, 40, 30) elseif key == "tut.susBrakesNo" then Color3.fromRGB(110, 100, 80) else C.Ink
		end
	end
	toolLabel.Visible = false
	local sub = taskFrame:FindFirstChild("Sub", true) :: TextLabel -- (inside the strip's Words frame)
	sub.Text = if hintKey then Localizer.t(hintKey, { money = Config.ScrapValue }) else ""
	-- (a step with a button: the button is the way — a hint like "Walk to the driver's door" beside "Try starting it"
	-- read as two different things to do: test 2 ⑩)
	sub.Visible = hintKey ~= nil and not (actionButton.Visible or orderButton.Visible) and not WorkView.cartView() -- (in the cart view "press Cart" is already done: test 3 stale line)
	-- a work view: one row — a step with a button shows just the button (its words say the same thing)
	-- (wr-uidesign A①: also outside a work view — "Try starting it" over a "Start it" button was the same thing twice)
	local justButton = actionButton.Visible or orderButton.Visible
	taskLabel.Visible = taskLabel.Text ~= "" and not justButton
	if justButton then
		sub.Visible = false
	end
	if hintKey == "tut.scrap" and not step then
		taskFrame.Visible = HUD.gui():GetAttribute("WindowOpen") ~= true and not HUD.gui():FindFirstChild("LevelUp", true) -- (just the small line: the scrap bin is optional)
	end
	Shop.focus(step and step.shop)
	place(step, stuck)
	-- the level-up card has the screen to itself: the strip steps out and comes back when it is gone (GPT test3 r1)
	if HUD.gui():FindFirstChild("LevelUp", true) then
		taskFrame.Visible = false
		hiddenForLevel = true
	elseif hiddenForLevel then
		hiddenForLevel = false
		taskFrame.Visible = taskLabel.Text ~= "" and HUD.gui():GetAttribute("WindowOpen") ~= true and player:GetAttribute("TutSkip") ~= true
	end
end

-------------------------------------------------------------------------------------------------------- build

-- v0.2 A: someone brand new starts right by Bay 1 (beside the front-left post, facing the car driving in) — done
-- here, once the bay floor has arrived on this screen (moved by the server, the character fell through a floor
-- that wasn't loaded yet). Once per session.
local function placeByBay()
	local t0 = os.clock()
	while not player:GetAttribute("Loaded") and os.clock() - t0 < 10 do
		task.wait(0.1)
	end
	if player:GetAttribute("Tut") ~= 1 or player:GetAttribute("TutSkip") then
		return
	end
	local g = workspace:WaitForChild("Garage", 20)
	local bays = g and g:WaitForChild("Bays", 10)
	local bay = bays and bays:WaitForChild("Bay1", 10)
	local spot = bay and bay:WaitForChild("CarSpot", 10) :: BasePart?
	local floor = g and g:FindFirstChild("Building") and (g :: any).Building:WaitForChild("FloorSlab", 10)
	if not spot or not floor then
		return
	end
	-- a living character standing in the world (in Studio the first one can fall before the map is there and respawn)
	local function alive(): Model?
		local c = player.Character
		local r = c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
		local h = c and c:FindFirstChildOfClass("Humanoid")
		return if r and h and h.Health > 0 and r.Position.Y > -20 then c else nil
	end
	local t1 = os.clock()
	local char = alive()
	while not char and os.clock() - t1 < 20 do
		task.wait(0.2)
		char = alive()
	end
	if not char then
		return
	end
	-- the first clear spot beside the car (the bay's parts cart stood on the old one: test 1 #1, stuck lying on it)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	local at = spot.CFrame * CFrame.new(-8, 3, -5)
	for _, o in { Vector3.new(-8, 3, -5), Vector3.new(-8, 3, -9), Vector3.new(-10, 3, -1), Vector3.new(-6, 3, -12), Vector3.new(8, 3, -9) } do
		local cf = spot.CFrame * CFrame.new(o)
		local hits = workspace:GetPartBoundsInBox(cf, Vector3.new(3, 5, 3), params)
		local blocked = false
		for _, h in hits do
			if h.CanCollide then
				blocked = true
				break
			end
		end
		if not blocked then
			at = cf
			break
		end
	end
	local look = spot.CFrame * Vector3.new(0, 2, 8)
	char:PivotTo(CFrame.lookAt(at.Position, Vector3.new(look.X, at.Y, look.Z)))
end

function Tutorial.start()
	task.spawn(placeByBay)
	local gui = HUD.gui()
	-- the task strip: a yellow plate with a thin hazard band on top, the step (big) and a hint line (small).
	-- (the words live in their own frame: the list layout must not move the band)
	taskFrame = Instance.new("Frame")
	taskFrame.Name = "TutorialTask"
	taskFrame.AnchorPoint = Vector2.new(1, 0)
	taskFrame.AutomaticSize = Enum.AutomaticSize.Y
	taskFrame.BackgroundColor3 = C.Yellow
	taskFrame.Visible = false
	local tc = Instance.new("UICorner")
	tc.Parent = taskFrame
	local edge = Instance.new("UIStroke")
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Color = C.Black
	edge.Parent = taskFrame
	local shine = Instance.new("UIGradient")
	shine.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.88, 0.88, 0.88))
	shine.Rotation = 90
	shine.Parent = taskFrame
	taskFrame.Parent = gui
	local band = UIKit.hazard(taskFrame, { name = "Band", pos = UDim2.fromScale(0.5, 0), anchor = Vector2.new(0.5, 0) })
	-- wr-art's task plate (yellow, its own hazard band and end bolts): the code look steps aside
	local function plateEnd(size: Vector2): number
		return math.clamp(size.X * 0.085, 18, 28)
	end
	local plated = UIKit.skin(taskFrame, "task", plateEnd)
	if plated then
		shine:Destroy()
		band.Visible = false
	end
	local words = Instance.new("Frame")
	words.Name = "Words"
	words.BackgroundTransparency = 1
	words.AutomaticSize = Enum.AutomaticSize.Y
	words.Parent = taskFrame
	local pad = Instance.new("UIPadding")
	pad.Parent = words
	local ll = Instance.new("UIListLayout")
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	ll.Padding = UDim.new(0, 2)
	ll.Parent = words
	local function wordLine(name: string, font: Font, color: Color3, order: number): TextLabel
		local l = Instance.new("TextLabel")
		l.Name = name
		l.Size = UDim2.new(1, 0, 0, 0)
		l.AutomaticSize = Enum.AutomaticSize.Y
		l.BackgroundTransparency = 1
		l.FontFace = font
		l.TextColor3 = color
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextWrapped = true
		l.Text = ""
		l.LayoutOrder = order
		l.Parent = words
		return l
	end
	taskLabel = wordLine("Task", UIStyle.Font.Title, C.Ink, 1)
	local sub = wordLine("Sub", UIStyle.Font.Body, Color3.fromRGB(86, 64, 20), 2)
	sub.Visible = false
	for i = 1, 2 do
		local l = wordLine("Suspect" .. i, UIStyle.Font.Title, C.Ink, 2 + i)
		l.Visible = false
		suspectLines[i] = l
	end
	orderButton = UIKit.button(words, {
		name = "Order",
		key = "tut.order",
		args = { money = 90 },
		size = UDim2.new(1, 0, 0, 34),
		max = 18,
		onClick = function()
			orderedAt = os.clock()
			local ok, key, args = Remotes.BuyPart:InvokeServer("Battery", "cart")
			-- (a success says nothing here: "It's on your cart!" pops a moment later — the two came together, test 2)
			if key and not ok then
				HUD.notify(key, args, "bad")
			end
			if not ok then
				orderedAt = -math.huge
			end
		end,
	})
	orderButton.LayoutOrder = 5
	orderButton.Visible = false
	actionButton = UIKit.button(words, {
		name = "TryCar",
		key = "tut.btnStart",
		size = UDim2.new(1, 0, 0, 34),
		max = 18,
		style = "Blue",
		onClick = function()
			if actionCar and actionWhat then
				Remotes.TryCar:FireServer(actionCar, actionWhat)
			end
		end,
	})
	actionButton.LayoutOrder = 6
	actionButton.Visible = false
	-- the check that flashes when a step is done
	tick = UIKit.icon(taskFrame, UIStyle.Icon.Check, { name = "Tick", anchor = Vector2.new(0.5, 0.5) })
		or UIKit.text(taskFrame, { name = "Tick", text = "OK", font = "Title", color = C.GreenDark, outline = false })
	tick.Visible = false
	gui:GetAttributeChangedSignal("WindowOpen"):Connect(function()
		local open = gui:GetAttribute("WindowOpen") == true
		dimStrip(open)
		taskFrame.Visible = not open and taskLabel.Text ~= "" and player:GetAttribute("TutSkip") ~= true
	end)
	-- the strip is as wide as its longest line (user 10-22: "boxes should fit the words"), its button too; a longer
	-- line wraps at the widest strip (36 % of the screen, 220..330 px)
	local stripW: number? = nil -- the words' own width (fitStrip); nil = not measured yet
	local MIN_W = 150
	local function widest(): number
		-- (0.42 of a 667 phone = 280: the longer English steps — "Battery or terminals (cable ends)? Check with the Scanner"
		-- — took 3 lines at 0.36 and the strip's foot sat on the notice line below; English pass 10-23)
		return math.clamp(math.floor(UIKit.size().X * 0.42), 220, 330)
	end
	local function sideOf(w: number): number
		return if plated then math.floor(plateEnd(Vector2.new(w, 0)) * 1.2) + 2 else UIKit.px(0.022, 6, 10) + 2
	end
	local function btnPad(): number
		return UIKit.px(0.045, 12, 18)
	end
	local function layoutStrip()
		local w = widest()
		if stripW then
			local guess = stripW + 2 * sideOf(w)
			w = math.clamp(stripW + 2 * sideOf(guess), MIN_W, w)
		end
		taskFrame.Size = UDim2.new(0, w, 0, 0)
		tc.CornerRadius = UDim.new(0, UIKit.px(0.025, 6, 12))
		edge.Thickness = UIKit.px(0.006, 2, 3)
		local b = UIKit.px(0.016, 5, 8)
		band.Size = UDim2.new(1, -2 * tc.CornerRadius.Offset, 0, b)
		local p = UIKit.px(0.022, 6, 10)
		local side = sideOf(w)
		if plated then
			-- under the plate's hazard band, clear of its end bolts
			b = math.floor(plateEnd(Vector2.new(w, 0)) * 0.5)
		end
		words.Position = UDim2.new(0, 0, 0, b)
		words.Size = UDim2.new(1, 0, 0, 0)
		pad.PaddingLeft, pad.PaddingRight = UDim.new(0, side), UDim.new(0, side)
		pad.PaddingTop, pad.PaddingBottom = UDim.new(0, p - 3), UDim.new(0, p - 2)
		taskLabel.TextSize = UIKit.px(0.055, 18, 22) -- (18 on a phone: GPT boxfit r1, the strip is small now)
		sub.TextSize = UIKit.px(0.045, 13, 16) -- (wr-uidesign A④: the checklist / hint lines read ~10 px on a phone)
		for _, l in suspectLines do
			l.TextSize = UIKit.px(0.052, 16, 20)
		end
		local t = UIKit.px(0.09, 30, 44)
		tick.Size = UDim2.fromOffset(t, t)
		tick.Position = UDim2.new(1, t / 2 + 6, 0.5, 0) -- (just outside the strip's right end: inside it covered the long words — wr-play test 3)
		-- the buttons: the words' size fixed, a touch height on a phone
		local bh = UIKit.buttonH(UIKit.px(0.105, 40, 44))
		for _, btn in { orderButton, actionButton } do
			btn.Size = UDim2.new(1, 0, 0, bh)
			local label = (btn :: any).Face.Label :: TextLabel
			label.TextWrapped = false
			label.TextScaled = false
			label.TextSize = math.min(math.floor(bh * 0.52 + 0.5), 20)
		end
	end
	UIKit.bind(taskFrame, layoutStrip)
	-- measure the shown lines (TextService yields: the newest call wins)
	local fitToken = 0
	local function fitStrip()
		fitToken += 1
		local my = fitToken
		task.spawn(function()
			local most = 0
			for _, l in { taskLabel, sub, suspectLines[1], suspectLines[2] } do
				if l.Visible and l.Text ~= "" then
					most = math.max(most, UIKit.textWidth(l.Text, l.FontFace, l.TextSize))
				end
			end
			for _, btn in { orderButton, actionButton } do
				local label = (btn :: any).Face.Label :: TextLabel
				if btn.Visible and label.Text ~= "" then
					most = math.max(most, UIKit.textWidth(label.Text, label.FontFace, label.TextSize) + 2 * btnPad())
				end
			end
			if my == fitToken and most > 0 then
				stripW = math.ceil(most) + 2
				layoutStrip()
			end
		end)
	end
	for _, l in { taskLabel, sub, suspectLines[1], suspectLines[2], orderButton, actionButton } do
		l:GetPropertyChangedSignal("Visible"):Connect(fitStrip)
	end
	for _, l in { taskLabel, sub, suspectLines[1], suspectLines[2], (orderButton :: any).Face.Label, (actionButton :: any).Face.Label } do
		l:GetPropertyChangedSignal("Text"):Connect(fitStrip)
		l:GetPropertyChangedSignal("TextSize"):Connect(fitStrip)
	end

	toolLabel = Instance.new("TextLabel") -- (the tool to pick bobs on the hot bar now: kept hidden)
	toolLabel.Visible = false
	toolLabel.Parent = gui

	-- one-off moments ("Found it!"): big outlined words under the money bar
	bannerLabel = UIKit.text(gui, {
		name = "TutorialBanner",
		font = "Title",
		color = C.Gold,
		anchor = Vector2.new(0.5, 0),
		max = 40,
	})
	bannerLabel.TextTransparency = 1
	local bannerStroke = bannerLabel:FindFirstChildOfClass("UIStroke") :: UIStroke
	bannerStroke.Transparency = 1
	UIKit.bind(bannerLabel, function()
		local below = math.max(0, UIKit.barHeight() + 4 - UIKit.topInset())
		bannerLabel.Position = UDim2.new(0.5, 0, 0, below + 8)
		bannerLabel.Size = UDim2.new(0.7, 0, 0, UIKit.px(0.1, 30, 48))
	end)

	-- the yellow ball with a dark chevron (the same look on the screen edge and over the target)
	local function ball(parent: GuiObject, sharp: boolean?): GuiObject
		-- the drawn pointer once it's uploaded (notes/gpt/wr-ui/tut_arrow_decision.md: a round sign, arrow down;
		-- the edge copy is the same picture turned)
		local art = UIKit.icon(parent, UIStyle.Icon.TutPointer, { name = "Ball" })
		if art then
			return art
		end
		local b = Instance.new("Frame")
		b.Name = "Ball"
		b.Size = UDim2.fromScale(1, 1)
		b.BackgroundColor3 = C.Yellow
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(1, 0)
		bc.Parent = b
		local st = Instance.new("UIStroke")
		st.Color = C.Outline
		st.Parent = b
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.85, 0.85, 0.85))
		g.Rotation = 90
		g.Parent = b
		for _, side in { -1, 1 } do
			local bar = Instance.new("Frame")
			bar.AnchorPoint = Vector2.new(0.5, 0.5)
			-- a "v" pointing down; the edge arrow turns the whole ball, so its v is narrower (a wide one turned
			-- sideways reads as clock hands)
			bar.Size = UDim2.fromScale(0.15, 0.48)
			bar.Position = UDim2.new(0.5 + side * (if sharp then 0.085 else 0.13), 0, 0.47, 0)
			bar.Rotation = side * (if sharp then 26 else 40)
			bar.BackgroundColor3 = C.Outline
			bar.BorderSizePixel = 0
			local c3 = Instance.new("UICorner")
			c3.CornerRadius = UDim.new(1, 0)
			c3.Parent = bar
			bar.Parent = b
		end
		b.Parent = parent
		UIKit.bind(st, function()
			st.Thickness = UIKit.px(0.008, 2, 4)
		end)
		return b
	end

	edgeArrow = Instance.new("Frame") -- target off screen: the ball on the screen edge, turned to point at it
	edgeArrow.Name = "TutorialEdge"
	edgeArrow.AnchorPoint = Vector2.new(0.5, 0.5)
	edgeArrow.BackgroundTransparency = 1
	edgeArrow.Visible = false
	ball(edgeArrow, true)
	edgeArrow.Parent = gui

	skipButton = Instance.new("TextButton")
	skipButton.Name = "SkipTutorial"
	skipButton.Position = UDim2.fromOffset(16, 58) -- under the money pill (the job card takes the top right)
	skipButton.Size = UDim2.fromOffset(160, 28)
	skipButton.BackgroundColor3 = C.PlateLight
	skipButton.BackgroundTransparency = 0.1
	skipButton.AutoButtonColor = false
	skipButton.FontFace = UIStyle.Font.Body
	skipButton.TextSize = 14
	-- as wide as its words: icon room (30) + the words + 10 (user 10-22: boxes fit the words)
	skipButton:GetPropertyChangedSignal("TextBounds"):Connect(function()
		skipButton.Size = UDim2.fromOffset(30 + math.ceil(skipButton.TextBounds.X / UIKit.zoom()) + 10, 28)
	end)
	skipButton.TextColor3 = C.SteelLight
	Localizer.bind(skipButton, "tut.skip")
	skipButton.Visible = false
	-- the skip icon always sits in front of its words (alone it reads as fast-forward); original colours
	UIKit.icon(skipButton, UIStyle.Icon.Skip, { anchor = Vector2.new(0, 0.5), pos = UDim2.new(0, -22, 0.5, 0), size = UDim2.fromOffset(18, 18) }) -- (x inside the 30 px padding)
	local skipPad = Instance.new("UIPadding")
	skipPad.PaddingLeft = UDim.new(0, 30)
	skipPad.PaddingRight = UDim.new(0, 8)
	skipPad.Parent = skipButton
	skipButton.TextXAlignment = Enum.TextXAlignment.Left
	local sc = Instance.new("UICorner")
	sc.CornerRadius = UDim.new(0, 8)
	sc.Parent = skipButton
	local sEdge = Instance.new("UIStroke")
	sEdge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	sEdge.Color = C.PlateEdge
	sEdge.Parent = skipButton
	skipButton.Parent = gui
	UIKit.press(skipButton, function()
		Remotes.TutSkip:FireServer()
	end)

	-- the floating arrow: the ball bobbing over the target. A screen element moved every frame (not a
	-- BillboardGui) so it sits on top of everything the same way the edge arrow does
	arrow = Instance.new("Frame")
	arrow.Name = "TutorialArrow"
	arrow.AnchorPoint = Vector2.new(0.5, 1)
	arrow.BackgroundTransparency = 1
	arrow.Visible = false
	local arrowSize = Instance.new("UIScale")
	arrowSize.Parent = arrow
	ball(arrow)
	arrow.Parent = gui
	UIKit.bind(arrow, function()
		local d = UIKit.px(0.13, 40, 60)
		arrow.Size = UDim2.fromOffset(d, d)
		edgeArrow.Size = UDim2.fromOffset(d, d)
	end)
	game:GetService("RunService").RenderStepped:Connect(function()
		local t = arrowTarget
		local pos = t and worldPos(t)
		local cam = workspace.CurrentCamera
		if not pos or not cam then
			arrow.Visible = false
			return
		end
		-- just over the target in screen pixels (wr-play test 3 ③-1: 1.6 studs up was ~195 px in a close work view and
		-- sat on the money / level bar), and never into the top HUD band — there it hangs as low as it must
		local v, onScreen = cam:WorldToViewportPoint(pos)
		arrow.Visible = onScreen
		-- (the HUD keeps the top bar inset: viewport -> gui coordinates)
		local inset = game:GetService("GuiService"):GetGuiInset()
		local gap = 12 + 6 * math.sin(os.clock() * 4)
		local top = UIKit.px(0.15, 96, 120) + arrow.AbsoluteSize.Y -- (the arrow hangs from its bottom: AnchorPoint y = 1)
		-- ... and never down onto the hint line over the tool bar (cart view: the ball sat over "Wrench · press a bolt")
		local bottom = UIKit.size().Y - UIKit.hotbarHeight() - 24 - UIKit.px(0.06, 18, 30) - 4
		-- (the hint line as it really is — its box, not a guess of its height: the ball hung over "Wrench · press a bolt" in the
		-- cart view again, wr-play A06 10-23)
		local hint = HUD.gui():FindFirstChild("Hint") :: GuiObject?
		if hint and hint.Visible and hint.AbsoluteSize.Y > 0 then
			bottom = math.min(bottom, hint.AbsolutePosition.Y - (arrow.Parent :: GuiObject).AbsolutePosition.Y - 6)
		end
		arrow.Position = UDim2.fromOffset(v.X, math.min(math.max(v.Y - inset.Y - gap, top), math.max(top, bottom)))
		arrowSize.Scale = arrowScale
	end)

	highlight = Instance.new("Highlight")
	highlight.Name = "TutorialGlow"
	highlight.FillColor = Color3.fromRGB(255, 220, 80)
	highlight.OutlineColor = Color3.fromRGB(255, 220, 80)
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = false
	highlight.Parent = workspace.CurrentCamera

	-- the third car works again: why it was the tire (script 4: the reason shows, not just the money)
	Remotes.Effect.OnClientEvent:Connect(function(name, data)
		if name == "proof" and data and data.car and data.car:GetAttribute("Tutorial") == 3 and player:GetAttribute("Tut") == 3 then
			task.delay(1.2, banner, "tut.why3", nil, 4.5)
		end
	end)

	-- the level-up card (every level: LevelCard — what opened and where; Lv2 / Lv3 wait for the tutorial settlement card)
	local lastLevel = player:GetAttribute("Level") or 1
	local builtAt = os.clock()
	player:GetAttributeChangedSignal("Level"):Connect(function()
		local lv = player:GetAttribute("Level") or 1
		if lv > lastLevel and os.clock() - builtAt > 8 and player:GetAttribute("Loaded") == true then
			LevelCard.onLevel(lv) -- (not the saved level arriving at join)
		elseif lv > lastLevel then
			SoundPlayer.play("levelUp")
		end
		lastLevel = lv
	end)
	task.spawn(function()
		while true do
			local ok, err = pcall(update)
			if not ok then
				warn("[Tutorial] " .. tostring(err))
			end
			task.wait(0.1)
		end
	end)
end

return Tutorial
