-- Studio-only 2-player co-op play test (StudioTestService multiplayer test, args "coop"). Since the work view: the
-- front goes up on the floor jack + stands, player 1 works in the engine bay's view, player 2 in the front-left
-- wheel's, old parts go onto the bay's cart, bought parts arrive on it.
-- Started from edit mode: StudioTestService:ExecuteMultiplayerTestAsync(2, "coop"). The first car comes with two
-- faults (Battery + Wheel_FL). Player 1 does the battery (two hands), player 2 the front-left wheel (rolled) on the
-- lift, AT THE SAME TIME, each through their own client's real remotes / prompts (DevClient.client.luau).
-- Then player 1 hands the car back; the test checks both got the same team pay, the job card was shared, and the
-- carry speeds, and ends the test with a report (returned to the caller).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StudioTestService = game:GetService("StudioTestService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local CoopTest = {}

local acks: { [string]: string } = {}
local nextId = 0

-- tell a client to do something and wait for its answer
local function ask(player: Player, cmd: { [string]: any }): string
	nextId += 1
	local id = tostring(nextId)
	cmd.id = id
	player:SetAttribute("DevDo", HttpService:JSONEncode(cmd))
	local t0 = os.clock()
	while not acks[id] and os.clock() - t0 < 12 do
		task.wait(0.05)
	end
	local res = acks[id] or "timeout"
	print(string.format("[CoopTest] %s %s -> %s", player.Name, tostring(cmd.cmd) .. (if cmd.path then " " .. cmd.path elseif cmd.mode then " " .. cmd.mode else ""), res))
	return res
end

local function tpLocal(player: Player, car: Model, x: number, z: number, lookX: number?, lookZ: number?)
	local p = (car:GetPivot() * CFrame.new(x, 0, z)).Position
	local l = (car:GetPivot() * CFrame.new(lookX or 0, 0, lookZ or z)).Position
	return ask(player, { cmd = "tp", x = p.X, y = 3.4, z = p.Z, lx = l.X, lz = l.Z })
end

local function tpAt(player: Player, pos: Vector3, look: Vector3?)
	local l = look or (pos + Vector3.zAxis)
	return ask(player, { cmd = "tp", x = pos.X, y = pos.Y + 3.2, z = pos.Z, lx = l.X, lz = l.Z })
end

local function newPartPath(player: Player, kind: string): string?
	local loose = workspace:FindFirstChild("LooseParts")
	for _, p in (if loose then loose:GetChildren() else {}) do
		if p.Name == kind and p:GetAttribute("BoughtBy") == player.UserId and p:GetAttribute("State") == "Free" then
			return "LooseParts." .. p.Name
		end
	end
	return nil
end

function CoopTest.run(S: { [string]: any }, vip: boolean?, carType: string?)
	Remotes.DevAck.OnServerEvent:Connect(function(_, id, res)
		acks[tostring(id)] = tostring(res)
	end)
	S.Customers.forceNext = { "Battery", "Wheel_FL" }
	S.Customers.forceType = carType
	if vip then
		S.Customers.forceKind = "VIP" -- (Lv6+, 2 players: alpha_scope §1-1)
	end

	local log = {}
	local function note(s: string)
		table.insert(log, s)
		print("[CoopTest] " .. s)
	end

	-- two players, loaded, and a parked car
	local t0 = os.clock()
	while (#Players:GetPlayers() < 2 or not Players:GetPlayers()[2]:GetAttribute("Loaded")) and os.clock() - t0 < 60 do
		task.wait(0.5)
	end
	local A, B = Players:GetPlayers()[1], Players:GetPlayers()[2]
	if not A or not B then
		StudioTestService:EndTest("FAIL: only " .. #Players:GetPlayers() .. " player(s)")
		return
	end
	if vip then
		for _, p in { A, B } do
			S.Data.addRep(p, 230) -- Lv6
			S.Data.markFirstJob(p)
		end
	end
	local car: Model? = nil
	-- the car in Bay1 (with friends here a second car may come to the temporary Bay2)
	local bay1 = workspace.Garage.Bays.Bay1
	while os.clock() - t0 < 90 do
		for _, c in (workspace:FindFirstChild("Cars") and workspace.Cars:GetChildren() or {}) do
			if c:GetAttribute("Parked") and c:GetAttribute("CarId") == bay1:GetAttribute("CarId") then
				car = c :: Model
			end
		end
		if car then
			break
		end
		task.wait(0.5)
	end
	if not car then
		StudioTestService:EndTest("FAIL: no car")
		return
	end
	local C = "Cars." .. car.Name
	note("players " .. A.Name .. " + " .. B.Name .. ", car " .. car.Name .. ", faults " .. tostring(car:GetAttribute("Faults")) .. ", customer " .. tostring(car:GetAttribute("CustomerKind")) .. ", level " .. tostring(A:GetAttribute("Level")))
	local money0 = { [A] = A:GetAttribute("Money"), [B] = B:GetAttribute("Money") }
	task.wait(1)

	local speeds = {}
	local doneA, doneB = false, false

	-- a loose part of a kind, new or old (by Condition), on the floor / cart / popped out — renamed so a client
	-- path finds just that one
	local function looseOne(kind: string, new: boolean, name: string): string?
		local folders = { workspace:FindFirstChild("LooseParts"), car:FindFirstChild("Detached") }
		for _, f in folders do
			for _, p in (if f then f:GetChildren() else {}) do
				if p:GetAttribute("PartKind") == kind and p:GetAttribute("State") == "Free" and (((p:GetAttribute("Condition") :: number?) or 100) >= 50) == new then
					p.Name = name
					return (if f == car:FindFirstChild("Detached") then C .. ".Detached." else "LooseParts.") .. name
				end
			end
		end
		return nil
	end

	-- the front goes up on the floor jack + stands first (nobody may be in a work view while the height changes)
	S.Jack.jack(car, "F", B)
	S.Jack.pump(car, true, B)
	task.wait(Config.JackPumpTime + 0.4)
	S.Jack.stand(car, 1, B)
	S.Jack.stand(car, 2, B)
	note("jacked: " .. tostring(car:GetAttribute("Support")))

	-- player 1 (work view, engine bay): hood (straight into the work view), scanner check, battery out onto the cart,
	-- buy at the counter (it goes to the cart), back in, the new one from the cart onto its spot, bolts
	task.spawn(function()
		tpLocal(A, car, 0, -11, 0, -5)
		ask(A, { cmd = "prompt", path = C .. ".Body.Hood.HoodPrompt" })
		task.wait(0.6)
		note("A zone after the hood: " .. tostring(A:GetAttribute("WorkZone")))
		ask(A, { cmd = "equip", name = "Scanner" })
		task.wait(0.3)
		ask(A, { cmd = "check", path = C .. ".MechanicalParts.Battery.Battery" })
		task.wait(Config.CheckInterval + 0.1)
		ask(A, { cmd = "equip", name = "Wrench" })
		task.wait(0.3)
		for _, i in { 1, 2, 3 } do
			ask(A, { cmd = "bolt", path = C .. ".MechanicalParts.Battery.Bolt_" .. i .. "_Head", mode = "loosen" })
			task.wait(Config.WrenchInterval + 0.1)
		end
		task.wait(0.4)
		ask(A, { cmd = "unequip" })
		local old = looseOne("Battery", false, "OldBattery")
		note("A take old battery: " .. (if old then ask(A, { cmd = "workpick", path = old }) else "none"))
		task.wait(0.4)
		speeds.battery = A.Character.Humanoid.WalkSpeed
		ask(A, { cmd = "workplace" }) -- onto the cart
		task.wait(0.3)
		ask(A, { cmd = "workexit" })
		task.wait(0.3)
		tpAt(A, workspace.Garage.PartsCounter.ServicePoint.Position, workspace.Garage.PartsCounter.HandoverPoint.Position)
		note("A buy: " .. ask(A, { cmd = "buy", kind = "Battery" }))
		task.wait(Config.CartDeliver + 0.5)
		tpLocal(A, car, 0, -11, 0, -5)
		local ok = S.Work.enter(A, car, "EngineBay")
		task.wait(0.4)
		local new = looseOne("Battery", true, "NewBattery")
		note("A back in: " .. tostring(ok) .. ", new battery on the cart: " .. tostring(new ~= nil))
		if new then
			ask(A, { cmd = "workpick", path = new })
			task.wait(0.4)
			ask(A, { cmd = "workplace", car = C, slot = "Battery" })
			task.wait(0.4)
		end
		note("A install: " .. tostring(S.Factory.slotPart(car, "Battery") ~= nil))
		ask(A, { cmd = "equip", name = "Wrench" })
		task.wait(0.3)
		for _, i in { 2, 1, 3 } do
			ask(A, { cmd = "bolt", path = C .. ".MechanicalParts.Battery.Bolt_" .. i .. "_Head", mode = "tighten" })
			task.wait(Config.WrenchInterval + 0.1)
		end
		ask(A, { cmd = "unequip" })
		ask(A, { cmd = "workexit" })
		doneA = true
	end)

	-- player 2 (work view, front-left wheel on the stands): impact wrench, the wheel onto the cart, buy, back in,
	-- the new wheel from the cart onto its spot, nuts; then down off the stands once player 1 is out
	task.spawn(function()
		S.Tools.give(B, "ImpactWrench") -- (a shop tool since the alpha: B gets one for this test)
		tpLocal(B, car, -7, -4, -3.25, -5)
		local ok = S.Work.enter(B, car, "Wheel_FL")
		task.wait(0.4)
		note("B zone: " .. tostring(ok) .. " " .. tostring(B:GetAttribute("WorkZone")))
		ask(B, { cmd = "equip", name = "ImpactWrench" })
		task.wait(0.3)
		for i = 1, 5 do
			ask(B, { cmd = "bolt", path = C .. ".MechanicalParts.Wheel_FL.Bolt_" .. i .. "_Head", mode = "loosen" })
			task.wait(Config.ImpactInterval + 0.05)
		end
		task.wait(0.5)
		ask(B, { cmd = "unequip" })
		local old = looseOne("Wheel", false, "OldWheel")
		note("B take old wheel: " .. (if old then ask(B, { cmd = "workpick", path = old }) else "none"))
		task.wait(0.4)
		speeds.wheel = B.Character.Humanoid.WalkSpeed
		ask(B, { cmd = "workplace" })
		task.wait(0.3)
		ask(B, { cmd = "workexit" })
		task.wait(0.3)
		tpAt(B, workspace.Garage.PartsCounter.ServicePoint.Position + Vector3.new(0, 0, -2), workspace.Garage.PartsCounter.HandoverPoint.Position)
		note("B buy: " .. ask(B, { cmd = "buy", kind = "Wheel" }))
		task.wait(Config.CartDeliver + 0.5)
		tpLocal(B, car, -7, -4, -3.25, -5)
		S.Work.enter(B, car, "Wheel_FL")
		task.wait(0.4)
		local new = looseOne("Wheel", true, "NewWheel")
		if new then
			ask(B, { cmd = "workpick", path = new })
			task.wait(0.4)
			ask(B, { cmd = "workplace", car = C, slot = "Wheel_FL" })
			task.wait(0.4)
		end
		note("B install: " .. tostring(S.Factory.slotPart(car, "Wheel_FL") ~= nil))
		ask(B, { cmd = "equip", name = "ImpactWrench" })
		task.wait(0.3)
		for i = 1, 5 do
			ask(B, { cmd = "bolt", path = C .. ".MechanicalParts.Wheel_FL.Bolt_" .. i .. "_Head", mode = "tighten" })
			task.wait(Config.ImpactInterval + 0.05)
		end
		ask(B, { cmd = "unequip" })
		ask(B, { cmd = "workexit" })
		local w0 = os.clock()
		while not doneA and os.clock() - w0 < 60 do
			task.wait(0.2)
		end
		task.wait(0.3)
		note("lower: " .. tostring(S.Jack.lower(car, B)))
		task.wait(Config.LowerCarTime + 0.4)
		doneB = true
	end)

	while not (doneA and doneB) and os.clock() - t0 < 200 do
		task.wait(0.3)
	end
	note(string.format("ready=%s, clues=%s", tostring(car:GetAttribute("Ready")), tostring(car:GetAttribute("Clues"))))
	-- both clients see the same job card
	note("A card: " .. ask(A, { cmd = "card" }):sub(1, 90))
	note("B card: " .. ask(B, { cmd = "card" }):sub(1, 90))

	-- hand it back (player 1) and wait for the money
	tpLocal(A, car, -5, 0, 0, 0)
	ask(A, { cmd = "prompt", path = C .. ".Chassis.ReleasePrompt" })
	task.wait(Config.ProofSeconds + 1.5) -- (the "it works now" moment comes before the pay)
	local dA = A:GetAttribute("Money") - money0[A]
	local dB = B:GetAttribute("Money") - money0[B]
	note(string.format("carry speed: battery(two hands)=%s wheel(roll)=%s (normal %d)", tostring(speeds.battery), tostring(speeds.wheel), Config.NormalWalkSpeed))
	note(string.format("money: A %+d, B %+d (parts: A spent battery, B spent wheel)", dA, dB))
	local bay2 = workspace.Garage.Bays:FindFirstChild("Bay2")
	local car2 = nil
	for _, c in workspace.Cars:GetChildren() do
		if bay2 and c:GetAttribute("CarId") == bay2:GetAttribute("CarId") then
			car2 = c
		end
	end
	note(string.format("temporary Bay2: in map=%s, sign=%s, car there=%s (%s)", tostring(bay2 ~= nil), tostring(bay2 and bay2.CarSpot:FindFirstChild("TempSign") ~= nil), tostring(car2 and car2.Name), tostring(car2 and car2:GetAttribute("CustomerKind"))))
	note(string.format("rep: A %s, B %s; stage at hand-back: %s", tostring(A:GetAttribute("Rep")), tostring(B:GetAttribute("Rep")), tostring(car:GetAttribute("Stage"))))
	local t0 = os.clock() -- (the pay card comes after the customer walks to the car)
	while not A:GetAttribute("Metric_firstPay") and os.clock() - t0 < 25 do
		task.wait(0.5)
	end
	note("metrics A: " .. S.Metrics.summary(A))
	note("metrics B: " .. S.Metrics.summary(B))
	for _, who in { A, B } do
		local r = S.Shift.summary(who)
		note(string.format("receipt %s: cars %s, earned %s, spotOn %s, rep +%s, crew %s, customer %s", who.Name, tostring(r and r.cars), tostring(r and r.earned), tostring(r and r.spotOn), tostring(r and r.rep), r and r.crew and table.concat(r.crew, "/") or "-", tostring(r and r.customer and r.customer.name)))
	end
	local desk = workspace.Garage:FindFirstChild("WaitingRoom") and workspace.Garage.WaitingRoom:FindFirstChild("ReceptionDesk")
	note("receipt printer prompt: " .. tostring(desk and desk:FindFirstChild("ReceiptPrompt", true) ~= nil))
	task.wait(1)
	StudioTestService:EndTest(table.concat(log, "\n"))
end

-- the garage owner (player 1) buys Bay2 + the hydraulic lift, a customer car parks in Bay2 and goes up to the
-- top, then the owner leaves: Bay2 and the hydraulic lift must stay until that car is down and gone
function CoopTest.ownerLeave(S: { [string]: any })
	Remotes.DevAck.OnServerEvent:Connect(function(_, id, res)
		acks[tostring(id)] = tostring(res)
	end)
	local log = {}
	local function note(s: string)
		table.insert(log, s)
		print("[CoopTest] " .. s)
	end
	local t0 = os.clock()
	while (#Players:GetPlayers() < 2 or not Players:GetPlayers()[2]:GetAttribute("Loaded")) and os.clock() - t0 < 60 do
		task.wait(0.5)
	end
	local A, B = Players:GetPlayers()[1], Players:GetPlayers()[2]
	note("owner = " .. tostring(S.Data.owner() and S.Data.owner().Name))
	S.Data.addRep(A, 230)
	S.Data.addMoney(A, 6000)
	local chest = workspace.Garage.Tools.ToolChest1.UsePoint
	while not (A.Character and A.Character:FindFirstChild("HumanoidRootPart")) and os.clock() - t0 < 60 do
		task.wait(0.3)
	end
	task.wait(2)
	tpAt(A, chest.Position)
	task.wait(1)
	note("buy Bay2: " .. ask(A, { cmd = "buyup", id2 = "Bay2" }))
	note("buy HydraulicLift: " .. ask(A, { cmd = "buyup", id2 = "HydraulicLift" }))
	task.wait(1)
	-- a car in Bay2
	local bay2, car2
	while os.clock() - t0 < 150 do
		bay2 = workspace.Garage.Bays:FindFirstChild("Bay2")
		if bay2 then
			for _, c in workspace.Cars:GetChildren() do
				if c:GetAttribute("Parked") and c:GetAttribute("CarId") == bay2:GetAttribute("CarId") then
					car2 = c
				end
			end
		end
		if car2 then
			break
		end
		task.wait(1)
	end
	if not car2 then
		StudioTestService:EndTest("FAIL: no car came to Bay2\n" .. table.concat(log, "\n"))
		return
	end
	S.Lift.setLevel(bay2, 3)
	note(string.format("car %s in Bay2, lift %s at level %s", car2.Name, tostring(bay2.Lift:GetAttribute("Variant")), tostring(bay2:GetAttribute("LiftLevel"))))
	note("owner leaves: " .. ask(A, { cmd = "leave" }))
	task.wait(6)
	bay2 = workspace.Garage.Bays:FindFirstChild("Bay2")
	note(string.format("after the owner left: owner=%s, Bay2 in map=%s (temporary=%s), lift=%s, car still there=%s", tostring(S.Data.owner() and S.Data.owner().Name), tostring(bay2 ~= nil), tostring(S.Upgrades.isTemp("Bay2")), tostring(bay2 and bay2:FindFirstChild("Lift") and bay2.Lift:GetAttribute("Variant")), tostring(car2.Parent ~= nil)))
	-- finish that car: lift down, fix, hand back (as B)
	if bay2 then
		S.Lift.setLevel(bay2, 1)
	end
	task.wait(1)
	for _, slot in string.split(car2:GetAttribute("Faults") or "", ",") do
		local p = S.Factory.slotPart(car2, slot)
		if p then
			p:SetAttribute("Condition", 100)
		end
		S.Faults.clearIssue(car2, slot)
	end
	S.Carry.onCarChanged(car2)
	S.Jobs.release(car2, B)
	local t1 = os.clock()
	while car2.Parent and os.clock() - t1 < 60 do
		task.wait(1)
	end
	task.wait(5)
	bay2 = workspace.Garage.Bays:FindFirstChild("Bay2")
	note(string.format("after that car left: Bay2 in map=%s, Bay1 lift=%s", tostring(bay2 ~= nil), tostring(workspace.Garage.Bays.Bay1.Lift:GetAttribute("Variant"))))
	StudioTestService:EndTest(table.concat(log, "\n"))
end

-- the gate (args "gate", server_model.md): everyone counts as a stranger from the start, so player 1 owns the
-- garage and player 2 is "sent to their own" (Studio: pretend) and never loads here; then player 2 counts as a
-- friend and tries again (in, save loaded); then the owner leaves (closed: no new customers, no new people)
function CoopTest.gate(S: { [string]: any })
	Remotes.DevAck.OnServerEvent:Connect(function(_, id, res)
		acks[tostring(id)] = tostring(res)
	end)
	local log = {}
	local function note(s: string)
		table.insert(log, s)
		print("[CoopTest] " .. s)
	end
	local t0 = os.clock()
	while (#Players:GetPlayers() < 2 or not Players:GetPlayers()[1]:GetAttribute("Loaded")) and os.clock() - t0 < 60 do
		task.wait(0.5)
	end
	task.wait(4)
	local A, B = Players:GetPlayers()[1], Players:GetPlayers()[2]
	local function state(who: Player): string
		return string.format("%s playing=%s loaded=%s", who.Name, tostring(S.Gate.isPlaying(who)), tostring(who:GetAttribute("Loaded")))
	end
	note(string.format("stranger: owner=%s (A=%d) kind=%s | %s | %s", tostring(workspace:GetAttribute("GarageOwner")), A.UserId, tostring(workspace:GetAttribute("GarageKind")), state(A), state(B)))
	note("data owner = " .. tostring(S.Data.owner() and S.Data.owner().Name))
	S.Gate.studioStrangers.all = nil
	S.Gate.retry(B) -- (what B's "Try again" button does)
	task.wait(3)
	note("friend, tried again: " .. state(B))
	-- exploit audit H1: B (A playing here) with a made-up invite / TeleportData, as a stranger and as a friend
	note("h1: " .. tostring(game:GetService("ServerStorage").DevCall:Invoke("gate", "h1")))
	note("owner leaves: " .. ask(A, { cmd = "leave" }))
	task.wait(4)
	note(string.format("after: closed=%s attr=%s data owner=%s | %s", tostring(S.Gate.closed), tostring(workspace:GetAttribute("GarageClosed")), tostring(S.Data.owner() and S.Data.owner().Name), state(B)))
	StudioTestService:EndTest(table.concat(log, "\n"))
end

return CoopTest
