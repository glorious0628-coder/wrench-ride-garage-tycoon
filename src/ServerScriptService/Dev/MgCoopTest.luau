-- Studio-only 2-player test of the mini-game steps (wr-mini): StudioTestService:ExecuteMultiplayerTestAsync(2, "mgcoop").
-- A car with a new wheel on and its nuts tight, the car down: the wheel step (Torque / Tire) waits. Player A presses
-- its prompt through their own client; player B can't open a second one, B's Hand back gets the notice (not B's own
-- forced Auto while A is at it), the session / its screen are A's only; A ends it; then the car can go back.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StudioTestService = game:GetService("StudioTestService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local MgCoopTest = {}

local acks: { [string]: string } = {}
local nextId = 0

local function ask(player: Player, cmd: { [string]: any }): string
	nextId += 1
	local id = tostring(nextId)
	cmd.id = id
	player:SetAttribute("DevDo", HttpService:JSONEncode(cmd))
	local t0 = os.clock()
	while not acks[id] and os.clock() - t0 < 12 do
		task.wait(0.05)
	end
	return acks[id] or "timeout"
end

function MgCoopTest.run(S: { [string]: any })
	Remotes.DevAck.OnServerEvent:Connect(function(_, id, res)
		acks[tostring(id)] = tostring(res)
	end)
	workspace:SetAttribute("Dev_Minigames", true)
	local log = {}
	local function note(s: string)
		table.insert(log, s)
		print("[MgCoopTest] " .. s)
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
	local car: Model? = nil
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
	task.wait(2)
	S.Data.markFirstJob(A)
	S.Data.markFirstJob(B)
	for _, p in { A, B } do
		S.Data.setTut(p, 4)
	end
	-- the stage: a new wheel on the front-left, nuts tight, the car down (a real wheel job's end)
	local wheel: Instance? = nil
	for _, d in car:GetDescendants() do
		if d.Name == "Wheel_FL" and d:GetAttribute("PartKind") == "Wheel" and d:GetAttribute("State") == "Installed" then
			wheel = d
		end
	end
	if not wheel then
		StudioTestService:EndTest("FAIL: no wheel")
		return
	end
	wheel:SetAttribute("BoughtBy", A.UserId)
	wheel:SetAttribute("Condition", 100)
	wheel:SetAttribute("TightOrder", "13524")
	car:SetAttribute("LiftOffset", 0.6)
	car:SetAttribute("Support", "StandsF")
	task.wait(0.3)
	car:SetAttribute("LiftOffset", 0)
	car:SetAttribute("Support", "None")
	task.wait(0.6)
	local prompt = car:FindFirstChild("MgStepPrompt", true)
	note("step prompt: " .. tostring(prompt and prompt.Parent.Name))
	if not prompt then
		StudioTestService:EndTest("FAIL: no step prompt\n" .. table.concat(log, "\n"))
		return
	end
	local att = prompt.Parent :: Attachment
	local piv = car:GetPivot()
	local lp = piv:PointToObjectSpace(att.WorldPosition)
	local side = piv:VectorToWorldSpace(Vector3.new(math.sign(lp.X), 0, 0))
	local function stand(p: Player, k: number)
		local at = att.WorldPosition + side * k
		return ask(p, { cmd = "tp", x = at.X, y = 3.4, z = at.Z, lx = att.WorldPosition.X, lz = att.WorldPosition.Z })
	end
	stand(A, 2.6)
	stand(B, 3.4)
	task.wait(0.8)
	local path = prompt:GetFullName():gsub("^Workspace%.", "")
	note("A presses: " .. ask(A, { cmd = "prompt", path = path }))
	task.wait(1)
	local M = S.Minigames
	local sa, sb = M.active(A), M.active(B)
	note("sessions after A: A=" .. tostring(sa and sa.kind) .. " B=" .. tostring(sb and sb.kind))
	note("B presses: " .. ask(B, { cmd = "prompt", path = path }))
	task.wait(0.8)
	sb = M.active(B)
	note("sessions after B tried: B=" .. tostring(sb and sb.kind) .. " A still=" .. tostring(M.active(A) ~= nil))
	note("B Hand back x2: " .. tostring(M.waiting(car, B)) .. " / " .. tostring(M.waiting(car, B)) .. " → B session " .. tostring(M.active(B) ~= nil) .. ", A still " .. tostring(M.active(A) ~= nil))
	-- A ends it (the kind's good hold, server-side time)
	local s = M.active(A)
	if s then
		local hold = if s.kind == "Torque" then s.state.d + 0.3 else ((s.state.lo + s.state.hi) / 2 - s.state.level) / s.state.c.rate
		M.input(A, s.id, nil, "down")
		task.wait(hold)
		M.input(A, s.id, nil, "up")
	end
	task.wait(0.6)
	note("after A done: step left " .. tostring(car:FindFirstChild("MgStepPrompt", true) ~= nil) .. ", waiting " .. tostring(M.waiting(car, B)) .. ", MgDone " .. tostring(wheel:GetAttribute("MgDone")))
	StudioTestService:EndTest("OK\n" .. table.concat(log, "\n"))
end

return MgCoopTest
