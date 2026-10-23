-- Studio-only play-test helper (multiplayer tests via StudioTestService): the server's Dev/CoopTest writes a command
-- into this player's "DevDo" attribute (JSON), this client does it through the real remotes / prompts, then sets
-- "DevDone" to the command id. Does nothing outside Studio.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	return
end

local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- which prompts this client shows right now, and the last notice the server sent (both go back in the answer)
local shown: { [ProximityPrompt]: boolean } = {}
ProximityPromptService.PromptShown:Connect(function(p)
	shown[p] = true
end)
ProximityPromptService.PromptHidden:Connect(function(p)
	shown[p] = nil
end)
local lastNote = ""
Remotes.Notify.OnClientEvent:Connect(function(key)
	lastNote = tostring(key)
end)

-- (wr-mini, lag tests) the Balance gauge as the screen sees it: start / hit events keep the zone current
local gauge: { [string]: any }? = nil
Remotes.Minigame.OnClientEvent:Connect(function(what, data)
	if what == "start" and type(data) == "table" and data.period then
		gauge = { t0 = data.t0, period = data.period, zone = data.zone, width = data.width }
	elseif (what == "hit" or what == "miss") and gauge and type(data) == "table" then
		gauge.zone = data.zone or gauge.zone
		gauge.width = data.width or gauge.width
	end
end)

local function find(path: string): Instance?
	local node: Instance? = workspace
	for name in path:gmatch("[^%.]+") do
		node = node and node:FindFirstChild(name)
	end
	return node
end

-- press a prompt the way a player would: it has to be showing first (prompts update as the character moves, so
-- nudge it a little if it isn't)
local function hold(prompt: ProximityPrompt, extra: number?): string
	local char = player.Character
	-- prompts only show while their spot is on screen: look at it, like a player would
	local anchor = prompt.Parent
	local at = if anchor and anchor:IsA("Attachment") then anchor.WorldPosition elseif anchor and anchor:IsA("BasePart") then anchor.Position else nil
	local cam = workspace.CurrentCamera
	if at and char then
		cam.CameraType = Enum.CameraType.Scriptable
		local from = char:GetPivot().Position + Vector3.new(0, 2.5, 0)
		cam.CFrame = CFrame.lookAt(from + (from - at).Unit * 6, at)
	end
	for try = 1, 3 do
		local t0 = os.clock()
		while not shown[prompt] and os.clock() - t0 < 0.8 do
			task.wait(0.05)
		end
		if shown[prompt] then
			break
		end
		if char then
			char:PivotTo(char:GetPivot() * CFrame.new(0, 0, if try % 2 == 1 then 0.6 else -0.6))
		end
	end
	if not shown[prompt] then
		cam.CameraType = Enum.CameraType.Custom
		return "not shown"
	end
	prompt:InputHoldBegin()
	task.wait(prompt.HoldDuration + (extra or 0.15)) -- (extra: a long hold needs more than 0.15 s of slack on the server — the coffee pour)
	prompt:InputHoldEnd()
	cam.CameraType = Enum.CameraType.Custom
	return "pressed"
end

local function run(cmd: { [string]: any }): string
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if cmd.cmd == "tp" then
		local p = Vector3.new(cmd.x, cmd.y, cmd.z)
		local look = if cmd.lx then Vector3.new(cmd.lx, p.Y, cmd.lz) else p + Vector3.zAxis
		char:PivotTo(CFrame.lookAt(p, look))
		task.wait(0.4) -- let the server see where we are before the next checked action
	elseif cmd.cmd == "equip" then
		local tool = player.Backpack:FindFirstChild(cmd.name) or char:FindFirstChild(cmd.name)
		if tool and hum then
			hum:EquipTool(tool)
		end
	elseif cmd.cmd == "unequip" and hum then
		hum:UnequipTools()
	elseif cmd.cmd == "bolt" then
		local b = find(cmd.path)
		if not b then
			return "no bolt " .. cmd.path
		end
		Remotes.Bolt:FireServer(b, cmd.mode)
	elseif cmd.cmd == "workpick" then -- the work view's tap on a loose part
		local p = find(cmd.path)
		if not p then
			return "no part " .. cmd.path
		end
		Remotes.WorkPick:FireServer(p)
	elseif cmd.cmd == "workplace" then -- ... set what I hold on the cart / on a slot
		if cmd.slot then
			Remotes.WorkPlace:FireServer(find(cmd.car), cmd.slot)
		else
			Remotes.WorkPlace:FireServer("cart")
		end
	elseif cmd.cmd == "workexit" then
		Remotes.WorkExit:FireServer()
	elseif cmd.cmd == "scan" then
		local ok, key = Remotes.Scan:InvokeServer(find(cmd.car), cmd.final)
		return tostring(ok) .. " " .. tostring(key)
	elseif cmd.cmd == "check" then
		local p = find(cmd.path)
		if not p then
			return "no part " .. cmd.path
		end
		Remotes.Check:FireServer(p)
	elseif cmd.cmd == "prompt" then
		-- a prompt by path (server prompts), or the local Install prompt on a car socket
		local inst = find(cmd.path)
		local prompt = inst and (if inst:IsA("ProximityPrompt") then inst else inst:FindFirstChildWhichIsA("ProximityPrompt", true))
		if not prompt then
			return "no prompt " .. cmd.path
		end
		return hold(prompt :: ProximityPrompt, cmd.extra)
	elseif cmd.cmd == "buy" then
		local ok, key = Remotes.BuyPart:InvokeServer(cmd.kind, cmd.deliver)
		return tostring(ok) .. " " .. tostring(key)
	elseif cmd.cmd == "buyup" then
		local ok, key = Remotes.BuyUpgrade:InvokeServer(cmd.id2)
		return tostring(ok) .. " " .. tostring(key)
	elseif cmd.cmd == "leave" then
		local sts = game:GetService("StudioTestService")
		if sts:CanLeaveTest() then
			task.delay(0.3, function()
				sts:LeaveTest()
			end)
			return "leaving"
		end
		return "can't leave"
	elseif cmd.cmd == "mgtrial" then -- (wr-mini) a hold game: down, hold on THIS client's clock, up (the server's receive times are judged)
		local sent = {}
		local seq = cmd.seq or 1
		for _, h in cmd.holds or {} do
			table.insert(sent, string.format("%.4f", workspace:GetServerTimeNow()))
			Remotes.MinigameInput:FireServer(cmd.sid, seq, "down")
			local t0 = os.clock()
			while os.clock() - t0 < h do
				task.wait()
			end
			seq += 1
			if cmd.jit then
				task.wait(math.random() * cmd.jit) -- (the shake: this "up" arrives U(0, jit) late — the held time the server sees grows)
			end
			if cmd.upOnly ~= false then
				table.insert(sent, string.format("%.4f", workspace:GetServerTimeNow()))
				Remotes.MinigameInput:FireServer(cmd.sid, seq, "up")
				seq += 1
			end
			task.wait(0.12)
		end
		return table.concat(sent, ",")
	elseif cmd.cmd == "mgscrub" then -- (wr-mini) the rub as the screen sends it: cells in a few messages, then the finish
		local cells = cmd.cells or {}
		local per = cmd.per or 4
		local i = 1
		while i <= #cells do
			local chunk = {}
			for k = i, math.min(i + per - 1, #cells) do
				table.insert(chunk, cells[k])
			end
			Remotes.MinigameScrub:FireServer(cmd.sid, chunk, false)
			i += per
			task.wait(cmd.gap or 0.25)
		end
		Remotes.MinigameScrub:FireServer(cmd.sid, {}, true)
		return "rubbed " .. #cells
	elseif cmd.cmd == "mgbalance" then -- (wr-mini) taps when the needle is in the green (needle from the synced server clock), n taps / max seconds
		local seq, taps, t0 = cmd.seq or 1, 0, os.clock()
		while gauge and taps < (cmd.n or 8) and os.clock() - t0 < (cmd.max or 12) do
			local g = gauge :: any
			local x = ((workspace:GetServerTimeNow() + (cmd.lead or 0) - g.t0) / g.period) % 1
			local p = if x < 0.5 then x * 2 else 2 - x * 2
			if math.abs(p - g.zone) <= g.width / 2 * (cmd.inside or 0.5) then
				task.wait(math.random() * (cmd.late or 0.03))
				Remotes.MinigameInput:FireServer(cmd.sid, seq, "tap")
				seq += 1
				taps += 1
				task.wait(0.45)
			else
				task.wait()
			end
		end
		return "taps " .. taps
	elseif cmd.cmd == "drop" then
		Remotes.Drop:FireServer()
	elseif cmd.cmd == "card" then
		local hud = player.PlayerGui:FindFirstChild("HUD")
		local card = hud and hud:FindFirstChild("JobCard")
		local body = card and card:FindFirstChild("Body") :: TextLabel?
		if not (body and card.Visible) then
			return "(no card)"
		end
		local text = body.Text:gsub("<[^>]->", "")
		return (text:gsub("%c", " / "))
	end
	return "ok"
end

player:GetAttributeChangedSignal("DevDo"):Connect(function()
	local raw = player:GetAttribute("DevDo")
	if type(raw) ~= "string" then
		return
	end
	local cmd = HttpService:JSONDecode(raw)
	lastNote = ""
	local ok, res = pcall(run, cmd)
	task.wait(0.15)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local where = if root then string.format(" @(%.0f,%.0f,%.0f)", root.Position.X, root.Position.Y, root.Position.Z) else ""
	Remotes.DevAck:FireServer(cmd.id, (if ok then res else "error: " .. tostring(res)) .. where .. (if lastNote ~= "" then " [" .. lastNote .. "]" else ""))
end)
