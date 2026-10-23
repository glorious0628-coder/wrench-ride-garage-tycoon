-- Wrench / impact wrench input: the bolt nearest the pointer on screen (within Config.BoltPickPixels) is the
-- target, shown with a ring. Wrench = one click, one bolt (loosen a tight one, tighten a loose one).
-- Impact wrench = hold and sweep: the first bolt decides loosen or tighten, then every bolt you pass gets the same.
-- In the work view (work_view 3): the hand wrench is "hold to turn" — keep pressing on a bolt for Config.HoldBoltTime
-- (the ring round it fills, WorkViewUI.hold), let go early and the turn so far stays; a quick tap finishes by itself.
-- The pick range there is Config.WorkPickPixels (the camera is close).
-- The server checks everything; this only picks and sends.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PartGraph = require(ReplicatedStorage.Shared.PartGraph)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local WorkViewUI = require(script.Parent.WorkViewUI)

local Wrench = {}

local player = Players.LocalPlayer
local tool: string? = nil
local bolts: { BasePart } = {}
local lastScan = 0
local hover: BasePart? = nil
local ring: SelectionSphere
local pointer = Vector2.zero
local holding = false
local sweepMode: string? = nil
local sent: { [BasePart]: boolean } = {}
local lastSend = 0

Wrench.blocked = function(): boolean
	return false
end -- set by the client entry (true while carrying)
Wrench.preferred = function(): Instance?
	return nil
end -- set by the client entry (the tutorial's glowing bolt)
Wrench.workView = function(): boolean
	return false
end -- set by WorkView: in a work zone (hold to turn, a wider pick)

-- hold to turn (work view, hand wrench): the bolt being held, when the press began, how far each bolt has turned
local holdBolt: BasePart? = nil
local holdFrom = 0
local holdAuto = false -- a quick tap: it finishes by itself
local turned: { [BasePart]: number } = {}

-- a bolt that will actually turn now: the terminal order (LoosenAfter / TightenAfter) lets it
local function ready(b: BasePart): boolean
	local part = b.Parent
	local root = part and (if part:IsA("Model") then part.PrimaryPart else part)
	local att = root and root:FindFirstChild((b:GetAttribute("Attachment") :: string?) or "")
	if not att then
		return true
	end
	local loosen = b:GetAttribute("Tight") == true
	local after = att:GetAttribute(if loosen then "LoosenAfter" else "TightenAfter") :: string?
	local other = after and part and part:FindFirstChild(after .. "_Head", true)
	if not other then
		return true
	end
	local otherTight = other:GetAttribute("Tight") == true
	return if loosen then not otherTight else otherTight
end

local function scan()
	table.clear(bolts)
	local cars = workspace:FindFirstChild("Cars")
	for _, d in (if cars then cars:GetDescendants() else {}) do
		if d:IsA("BasePart") and d:GetAttribute("Bolt") then
			table.insert(bolts, d)
		end
	end
end

local function pick(): BasePart?
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local cam = workspace.CurrentCamera
	if not root or not cam then
		return nil
	end
	local best, bestScore = nil, math.huge
	-- a finger is wider than a mouse pointer; "clumsy is fine": the next bolt / one that turns wins a near tie
	local touch = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
	local reach = if Wrench.workView() then Config.WorkPickPixels else Config.BoltPickPixels * (if touch then Config.TouchPickScale else 1)
	local preferred = Wrench.preferred()
	-- in a work view only the bolts of THIS zone count: a press beside the empty battery spot used to catch a brake
	-- caliper bolt out of sight behind the wheel ("take the wheel off first", a stale hold ring — wr-play test 4)
	local zone = if Wrench.workView() then player:GetAttribute("WorkZone") else nil
	for _, b in bolts do
		local part = b.Parent
		local slot = part and part:GetAttribute("Slot")
		local zoneOfBolt = if zone and type(slot) == "string" then CarParts.zoneOf(slot) else nil
		if zoneOfBolt and zoneOfBolt ~= zone and (zoneOfBolt == "EngineBay" or zoneOfBolt:sub(1, 6) == "Wheel_") then -- (body-panel bolts have no work zone: never filtered)
			continue
		end
		if b.Parent and part and part:GetAttribute("State") == "Installed" and (b.Position - root.Position).Magnitude <= Config.ReachDistance + 1 then
			local v, onScreen = cam:WorldToViewportPoint(b.Position)
			if onScreen then
				local d = (Vector2.new(v.X, v.Y) - pointer).Magnitude
				if d <= reach then
					local score = d + v.Z * 0.5 -- nearer to the camera wins a tie
					if b == preferred then
						score -= 1000
					elseif not ready(b) then
						score += 500
					end
					if score < bestScore then
						best, bestScore = b, score
					end
				end
			end
		end
	end
	return best
end

local function modeFor(b: BasePart): string
	return if b:GetAttribute("Tight") then "loosen" else "tighten"
end

local function send(b: BasePart, mode: string)
	lastSend = os.clock()
	sent[b] = true
	Remotes.Bolt:FireServer(b, mode)
end

-- (Features.ToolMatch) the tool really in hand, and whether bare hands count as "the wrench" in the work view: the
-- server puts the right tool in the hand for each fastener, so a tap works with nothing held (full_teardown §4-1)
local inHand: string? = nil
local function current(): string?
	if tool or not Config.feature("ToolMatch") then
		return tool
	end
	if inHand == nil and Wrench.workView() then
		return "Wrench" -- (picks like the hand wrench; the server swaps in the tool that fits)
	end
	return nil
end

-- how the tool in hand is used: "hold" (work view) / "click" / "sweep"
local function use(): string?
	local t = current()
	if not t then
		return nil
	end
	local row = Config.feature("ToolMatch") and PartGraph.Tools[t]
	local kind = if row then row.use elseif t == "Wrench" then "hold" else "sweep"
	if kind == "hold" then
		return if Wrench.workView() then "hold" else "click"
	end
	return kind
end

-- a fastener's hold time (Features.ToolMatch: its kind's `hold`, PartData/Fasteners)
local function holdTime(b: BasePart): number
	if not Config.feature("ToolMatch") then
		return Config.HoldBoltTime
	end
	local f = PartGraph.Fasteners[(b:GetAttribute("Fastener") :: string?) or "Bolt"]
	return Config.HoldBoltTime * (if f then f.hold else 1)
end

local function press()
	if not current() or Wrench.blocked() then
		return
	end
	local b = pick()
	local how = use()
	if how == "hold" then
		if b then
			holdBolt, holdFrom, holdAuto = b, os.clock() - (turned[b] or 0) * holdTime(b), false
		end
	elseif how == "click" then
		if b and os.clock() - lastSend >= Config.WrenchInterval then
			send(b, modeFor(b))
		end
	elseif how == "sweep" then
		holding = true
		table.clear(sent)
		sweepMode = if b then modeFor(b) else nil
		if b then
			send(b, sweepMode :: string)
		end
	end
end

function Wrench.setTool(name: string?)
	inHand = name
	if Config.feature("ToolMatch") and name and PartGraph.Tools[name] then
		tool = name
	else
		tool = if name == "Wrench" or name == "ImpactWrench" or name == "RatchetWrench" then name else nil
	end
	holding = false
	if not tool then
		ring.Adornee = nil
	end
end

function Wrench.active(): string?
	return tool
end

-- turning a bolt right now (a press on one, its hold or its auto-finish): the work view leaves the wheel alone then
function Wrench.busy(): boolean
	return holdBolt ~= nil or holding
end

function Wrench.start()
	ring = Instance.new("SelectionSphere")
	ring.Name = "BoltRing"
	ring.SurfaceTransparency = 0.6
	ring.Transparency = 0.1
	ring.Parent = workspace.CurrentCamera

	-- input positions are below the top bar; WorldToViewportPoint counts from the window top: add the inset
	local function at(input: InputObject): Vector2
		return Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()
	end
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pointer = at(input)
			press()
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			pointer = at(input)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			holding = false
			local b = holdBolt
			if b and not holdAuto then
				local share = (os.clock() - holdFrom) / holdTime(b)
				if share < 0.35 then
					holdAuto = true -- a tap: keep going by itself
				else
					turned[b] = math.clamp(share, 0, 0.99) -- let go: the turn so far stays
					holdBolt = nil
					WorkViewUI.holdEnd()
				end
			end
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not current() or Wrench.blocked() then
			ring.Adornee = nil
			if holdBolt then -- (the tool was put away / hands full mid-hold: no hold ring left hanging on the screen)
				holdBolt = nil
				WorkViewUI.holdEnd()
			end
			return
		end
		if os.clock() - lastScan > 0.5 then
			lastScan = os.clock()
			scan()
		end
		-- hold to turn (work view): fill the ring, then the bolt turns
		local hb = holdBolt
		if hb then
			if not hb.Parent or use() ~= "hold" then
				holdBolt = nil
				WorkViewUI.holdEnd()
			else
				local share = (os.clock() - holdFrom) / holdTime(hb)
				WorkViewUI.hold(hb, math.min(share, 1))
				if share >= 1 then
					holdBolt = nil
					turned[hb] = nil
					send(hb, modeFor(hb))
					task.delay(0.15, function()
						if not holdBolt then
							WorkViewUI.holdEnd()
						end
					end)
				end
			end
		end
		hover = pick()
		ring.Adornee = hover
		if hover then
			ring.Color3 = if hover:GetAttribute("Tight") then Color3.fromRGB(255, 200, 60) else Color3.fromRGB(80, 200, 255)
			ring.SurfaceColor3 = ring.Color3
		end
		if holding and use() == "sweep" and hover and not sent[hover] then
			sweepMode = sweepMode or modeFor(hover)
			local row = Config.feature("ToolMatch") and PartGraph.Tools[tool :: string]
			local every = if row then row.interval elseif tool == "ImpactWrench" then Config.ImpactInterval else Config.RatchetInterval
			if modeFor(hover) == sweepMode and os.clock() - lastSend >= every then
				send(hover, sweepMode :: string)
			end
		end
	end)
end

return Wrench
