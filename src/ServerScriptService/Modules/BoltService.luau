-- Bolts (기획서 6장 '볼트 해체 타격감'): the client says which bolt and loosen / tighten; the server checks the tool
-- in hand, reach, the tool's rate, the part's Requires (hood open, lift height, a part in front off first) and the
-- battery terminal order (car_spec 4-1: (-) off first, (+) on first — a wrong order sparks, no penalty).
-- Last bolt out → the part detaches (CarryService).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CarFactory = require(script.Parent.CarFactory)
local CarService = require(script.Parent.CarService)
local CarryService = require(script.Parent.CarryService)
local ToolKit = require(script.Parent.ToolKit)
local Metrics = require(script.Parent.Metrics)
local Guard = require(script.Parent.Guard)
local PartGraph = require(ReplicatedStorage.Shared.PartGraph)

local BoltService = {}

local INTERVAL = { Wrench = Config.WrenchInterval, RatchetWrench = Config.RatchetInterval, ImpactWrench = Config.ImpactInterval }
local REACH_BONUS = { ImpactWrench = 1 } -- alpha_scope §3: the impact wrench reaches a little further
local lastUse: { [Player]: number } = {}

local function notify(player: Player, key: string, args: { [string]: any }?)
	Remotes.Notify:FireClient(player, key, args, "bad")
end

local function headFor(part: Instance, attName: string): BasePart?
	return part:FindFirstChild(attName .. "_Head") :: BasePart?
end

local function onBolt(player: Player, bolt: any, mode: any)
	if typeof(bolt) ~= "Instance" or not bolt:IsA("BasePart") or not bolt:GetAttribute("Bolt") then
		return
	end
	if mode ~= "loosen" and mode ~= "tighten" then
		return
	end
	Metrics.mark(player, "firstTouch")
	local tool = ToolKit.equipped(player)
	local interval = tool and INTERVAL[tool]
	if Config.feature("ToolMatch") then
		-- the right tool for this fastener (full_teardown §3-§4): the one in hand if it fits, else the best one owned
		-- goes into the hand by itself; bare hands for connectors / latches; none owned = "Needs: <tool>"
		local fastener = (bolt:GetAttribute("Fastener") :: string?) or "Bolt"
		if not PartGraph.fits(tool, fastener) then
			local best = PartGraph.bestTool(ToolKit.owned(player), fastener)
			if not best then
				local need = PartGraph.neededTool(fastener)
				local row = need and PartGraph.Tools[need]
				return notify(player, "n.needTool", { tool = "@tool." .. tostring(need), lv = row and row.level or 1 })
			elseif best ~= "Hand" and not ToolKit.equip(player, best) then
				return
			end
			tool = if best == "Hand" then tool else best
		end
		local row = tool and PartGraph.Tools[tool]
		interval = if row then row.interval else Config.WrenchInterval
	end
	if not interval then
		return
	end
	-- the rate limit is the anti-cheat for "unbolt everything in one frame" (a little slack for network jitter)
	local now = os.clock()
	if now - (lastUse[player] or 0) < interval * 0.8 then
		return
	end
	if CarryService.carried(player) then
		return notify(player, "n.handsFull")
	end
	local part = bolt.Parent :: Instance
	if not part or part:GetAttribute("State") ~= "Installed" then
		return
	end
	local car = CarService.carOf(part)
	if not car then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root or (root.Position - bolt.Position).Magnitude > Config.ReachDistance + (REACH_BONUS[tool] or 0) then
		-- (in a work view a ratchet sweep crosses bolts out of reach: no "Too far" there — wr-gamer g11)
		return if player:GetAttribute("WorkZone") then nil else notify(player, "n.tooFar")
	end
	local tight = bolt:GetAttribute("Tight") == true
	if (mode == "loosen") ~= tight then
		return -- already that way (an impact-wrench sweep passing over it)
	end
	local att = CarFactory.root(part):FindFirstChild(bolt:GetAttribute("Attachment") :: string) :: Attachment?
	if not att then
		return
	end
	local slotName = part:GetAttribute("Slot") :: string?
	local ok, key, args = CarService.check(car, part:GetAttribute("Requires") :: string?, slotName, player)
	if ok then
		ok, key, args = CarService.check(car, att:GetAttribute("Requires") :: string?, slotName, player)
	end
	if not ok then
		return notify(player, key :: string, args)
	end
	lastUse[player] = now
	-- terminal order: the other terminal has to be off (loosen) / on (tighten) first
	local after = att:GetAttribute(if mode == "loosen" then "LoosenAfter" else "TightenAfter") :: string?
	if after then
		local other = headFor(part, after)
		local otherTight = other and other:GetAttribute("Tight") == true
		if (mode == "loosen" and otherTight) or (mode == "tighten" and not otherTight) then
			Remotes.Effect:FireAllClients("spark", { pos = bolt.Position })
			return notify(player, if mode == "loosen" then "n.spark" else "n.sparkOn")
		end
	end

	bolt:SetAttribute("Tight", mode == "tighten")
	CarFactory.seatBolt(bolt)
	-- lug nuts: the order they go on (star pattern 1-3-5-2-4, either way round = a small bonus)
	if part:GetAttribute("PartKind") == "Wheel" then
		local n = tonumber((bolt:GetAttribute("Attachment") :: string):match("%d+"))
		local order = (part:GetAttribute("TightOrder") :: string?) or ""
		part:SetAttribute("TightOrder", if mode == "tighten" then order .. tostring(n) else "")
		part:SetAttribute("StarOrder", nil)
	end
	local left = (part:GetAttribute("BoltsRemaining") :: number) + (if mode == "tighten" then 1 else -1)
	if mode == "tighten" and car:GetAttribute("Tutorial") == 2 then
		-- the tutorial's second car: one tighten does them all ("Hold to tighten all" — just this once)
		for _, d in part:GetDescendants() do
			if d:IsA("BasePart") and d:GetAttribute("Bolt") and d:GetAttribute("Tight") ~= true then
				d:SetAttribute("Tight", true)
				CarFactory.seatBolt(d)
			end
		end
		left = part:GetAttribute("BoltCount") :: number
	end
	part:SetAttribute("BoltsRemaining", left)
	-- (last = the part is fully bolted in now: the impact wrench's long burst)
	Remotes.Effect:FireAllClients("bolt", { bolt = bolt, loosen = mode == "loosen", tool = tool, last = mode == "tighten" and left >= (part:GetAttribute("BoltCount") :: number) })
	if mode == "loosen" and left <= 0 then
		CarService.touch(car, player) -- a work unit: the part is off
		part:SetAttribute("Handler", player.UserId) -- (left lying old: its scrap money goes to them — CarryService)
		Remotes.Effect:FireAllClients("clank", { pos = CarFactory.root(part).Position })
		CarryService.detach(car, part)
		Remotes.Notify:FireClient(player, "n.partOff", { part = "@part." .. tostring(part:GetAttribute("PartKind")) }, "info")
	elseif mode == "tighten" and left >= (part:GetAttribute("BoltCount") :: number) then
		CarService.touch(car, player) -- a work unit: the part is bolted in
		if part:GetAttribute("PartKind") == "Wheel" and BoltService.isStar((part:GetAttribute("TightOrder") :: string?) or "") then
			part:SetAttribute("StarOrder", true)
			Remotes.Notify:FireClient(player, "n.star", nil, "good")
		end
		Remotes.Notify:FireClient(player, "n.partOn", { part = "@part." .. tostring(part:GetAttribute("PartKind")) }, "good")
		if CarryService.onCarChanged then
			CarryService.onCarChanged(car)
		end
	end
end

-- "13524" (or "14253", any start): every next nut is two along the circle, the same way round
function BoltService.isStar(order: string): boolean
	if #order ~= 5 then
		return false
	end
	local step = nil
	for i = 2, 5 do
		local d = (tonumber(order:sub(i, i)) - tonumber(order:sub(i - 1, i - 1))) % 5
		if d ~= 2 and d ~= 3 then
			return false
		end
		if step and d ~= step then
			return false
		end
		step = d
	end
	return true
end

function BoltService.start()
	Remotes.Bolt.OnServerEvent:Connect(Guard.wrap("Bolt", 0, onBolt)) -- (the tool's own interval paces it)
	if Config.feature("ToolMatch") then
		-- the free tools come with the level that opens their first job, with a card (full_teardown §4-2)
		local function watch(p: Player)
			local function grant()
				for _, name in ToolKit.grantFree(p) do
					Remotes.Notify:FireClient(p, "n.newTool", { tool = "@tool." .. name }, "good")
				end
			end
			p:GetAttributeChangedSignal("Level"):Connect(grant)
			p.CharacterAdded:Connect(function()
				task.wait(1)
				grant()
			end)
			task.defer(grant)
		end
		game:GetService("Players").PlayerAdded:Connect(watch)
		for _, p in game:GetService("Players"):GetPlayers() do
			watch(p)
		end
	end
	game:GetService("Players").PlayerRemoving:Connect(function(p)
		lastUse[p] = nil
	end)
end

return BoltService
