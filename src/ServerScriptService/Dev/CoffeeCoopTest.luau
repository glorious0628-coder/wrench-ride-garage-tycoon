-- Studio-only 2-player test of the coffee (wr-dev): StudioTestService:ExecuteMultiplayerTestAsync(2, "coffeecoop") from edit
-- mode with workspace Dev_Coffee = true. Player A has done the tutorial, B has not: B's Pour is refused; B finishes it,
-- both pour (two cups, each in its own hand), A gives the waiting customer a cup (one coffee, one tip), B's give does
-- nothing (the customer already has theirs, B keeps the cup), the car is fixed and handed back: the tip is in the pay.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StudioTestService = game:GetService("StudioTestService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local CoffeeCoopTest = {}

local acks: { [string]: string } = {}
local nextId = 0

local function ask(player: Player, cmd: { [string]: any }): string
	nextId += 1
	local id = tostring(nextId)
	cmd.id = id
	player:SetAttribute("DevDo", HttpService:JSONEncode(cmd))
	local t0 = os.clock()
	while not acks[id] and os.clock() - t0 < 14 do
		task.wait(0.05)
	end
	return acks[id] or "timeout"
end

function CoffeeCoopTest.run(S: { [string]: any })
	Remotes.DevAck.OnServerEvent:Connect(function(_, id, res)
		acks[tostring(id)] = tostring(res)
	end)
	local log = {}
	local ok = true
	local function note(s: string)
		table.insert(log, s)
		print("[CoffeeCoopTest] " .. s)
	end
	local function check(what: string, cond: boolean)
		note((if cond then "ok   " else "FAIL ") .. what)
		if not cond then
			ok = false
		end
	end
	local t0 = os.clock()
	while (#Players:GetPlayers() < 2 or not Players:GetPlayers()[2]:GetAttribute("Loaded")) and os.clock() - t0 < 60 do
		task.wait(0.5)
	end
	local A, B = Players:GetPlayers()[1], Players:GetPlayers()[2]
	if not A or not B then
		StudioTestService:EndTest("FAIL: only " .. #Players:GetPlayers() .. " player(s)")
		return
	end
	-- the waiting customer's prompt (a seated customer with a parked car)
	local prompt: ProximityPrompt? = nil
	while os.clock() - t0 < 150 do
		for _, d in workspace:GetDescendants() do
			if d:IsA("ProximityPrompt") and d.Name == "CoffeePrompt" and d.Enabled then
				prompt = d
			end
		end
		if prompt then
			break
		end
		task.wait(1)
	end
	if not prompt then
		StudioTestService:EndTest("FAIL: no coffee prompt on a customer")
		return
	end
	task.wait(2)
	local car: Model? = nil
	for _, c in workspace.Cars:GetChildren() do
		if c:GetAttribute("Parked") and c:GetAttribute("CoffeeBy") == nil then
			car = c
		end
	end
	if not car then
		StudioTestService:EndTest("FAIL: no parked car")
		return
	end
	S.Data.markFirstJob(A)
	S.Data.markFirstJob(B)
	S.Data.setTut(A, 4)
	S.Data.setTut(B, 1)
	A:SetAttribute("TutSkip", nil)
	B:SetAttribute("TutSkip", nil)
	task.wait(0.5)
	local Coffee = S.Coffee
	check("A's coffee is open, B's is not (tutorial)", Coffee.open(A) and not Coffee.open(B))
	local maker = workspace.Garage.Dressing.CoffeeMaker
	local makerPath = "Garage.Dressing.CoffeeMaker.PourPrompt"
	local function standAt(p: Player, at: Vector3, face: Vector3, k: number)
		local flat = Vector3.new(face.X - at.X, 0, face.Z - at.Z)
		local dir = if flat.Magnitude > 0.1 then flat.Unit else Vector3.zAxis
		local pos = at - dir * k
		return ask(p, { cmd = "tp", x = pos.X, y = 3.4, z = pos.Z, lx = at.X, lz = at.Z })
	end
	standAt(A, maker.Position, maker.Position, 2.6)
	standAt(B, maker.Position + Vector3.new(0, 0, 2), maker.Position, 2.4)
	task.wait(0.8)
	note("B pours (tutorial not done): " .. ask(B, { cmd = "prompt", path = makerPath, extra = 1.0 }))
	task.wait(0.6)
	check("B has no cup", not Coffee.holding(B))
	note("A pours: " .. ask(A, { cmd = "prompt", path = makerPath, extra = 1.0 }))
	task.wait(0.8)
	check("A has a cup", Coffee.holding(A))
	S.Data.setTut(B, 4)
	task.wait(0.5)
	check("B's coffee opens once their tutorial is done", Coffee.open(B))
	note("B pours: " .. ask(B, { cmd = "prompt", path = makerPath, extra = 1.0 }))
	task.wait(0.8)
	check("B has a cup", Coffee.holding(B))
	local cups = 0
	for _, d in workspace:GetDescendants() do
		if d:IsA("Model") and d.Name == "CoffeeCup" then
			cups += 1
		end
	end
	check("two cups in the world, one per hand (" .. cups .. ")", cups == 2)
	-- to the customer: A gives
	local npcAt = (prompt.Parent :: BasePart).Position
	local promptPath = prompt:GetFullName():gsub("^Workspace%.", "")
	standAt(A, npcAt, npcAt, 2.2)
	standAt(B, npcAt + Vector3.new(0, 0, 2), npcAt, 2.4)
	task.wait(1)
	note("A gives: " .. ask(A, { cmd = "prompt", path = promptPath }))
	task.wait(1.2)
	check("the customer has A's coffee (CoffeeBy = A)", car:GetAttribute("CoffeeBy") == A.UserId)
	check("A's cup is gone, B still has theirs", not Coffee.holding(A) and Coffee.holding(B))
	note("B gives (the customer already has one): " .. ask(B, { cmd = "prompt", path = promptPath }))
	task.wait(1)
	check("still A's coffee after B tried (one coffee, one tip)", car:GetAttribute("CoffeeBy") == A.UserId)
	Coffee.drop(B, true)
	-- the job's end: fixed and handed back: the tip is in the pay
	ServerStorage.DevCall:Invoke("fixFaults")
	task.wait(1.5)
	local rel = ServerStorage.DevCall:Invoke("release")
	note("release: " .. tostring(rel))
	check("pay has the coffee tip", string.find(tostring(rel), "pay.coffee", 1, true) ~= nil)
	StudioTestService:EndTest((if ok then "OK" else "FAIL") .. "\n" .. table.concat(log, "\n"))
end

return CoffeeCoopTest
