-- The Robux items working in the game (docs/design/monetization.md v2 확정판, notes/handoff/pass_build_list.md; the
-- screen is wr-ui's StoreUI, the numbers Shared/StoreData). Every effect waits for main's sale switch
-- (Config.StoreOn[key]) — in Studio the creator "owns" every pass, so off = nothing happens even then. Studio tests:
-- player attribute StoreTest = "Key,Key" switches items on for that player, DevCall store … (Dev/DevHooks).
--   Cash Envelopes (developer products): MarketplaceService.ProcessReceipt — each purchase id is paid once (kept in the
--     save, Config.ReceiptsKept), the money = StoreData.envelopeMoney(level, minutes) (never x Pay Boost), and it only
--     counts once the save is stored: a failed save takes the money back and answers NotProcessedYet (Roblox asks
--     again later). A day holds StoreData.DayMinutes of envelopes (player attribute EnvLeft; the screen locks the rest).
--   Starter Pack (pass): Config.StarterCash once a player (save starterGiven) + the Starter Look attribute.
--   Pay Boost (pass): JobService adds my labor + tips x (Config.PayBoostMult - 1) as its own pay line (StoreService.boost).
--   VIP Mechanic (pass): walking +10% (under Config.PaidSpeed, CarryService.walkBase) + attribute VIP (the tag / outfit /
--     couch are their sessions' looks).
-- Player attributes for the screen: Owns<Key> = true, EnvLeft = minutes of today's envelopes left.
-- Records / rankings (Pit Stop Rush, weekly — none in the game yet) must call StoreService.boost / walk with record = true.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local StoreData = require(ReplicatedStorage.Shared.StoreData)
local Passes = require(script.Parent.Passes)
local PlayerData = require(script.Parent.PlayerData)

local StoreService = {}

local itemOf: { [string]: StoreData.Item } = {}
for _, it in StoreData.Items do
	itemOf[it.key] = it
end

-- the item works for this player now: main's switch (or the Studio test list) and, for a pass, owning it
function StoreService.on(player: Player, key: string): boolean
	if Config.StoreOn[key] == true then
		return true
	end
	if RunService:IsStudio() then
		local list = (player:GetAttribute("StoreTest") :: string?) or ""
		return table.find(string.split(list, ","), key) ~= nil
	end
	return false
end

local function active(player: Player, key: string): boolean
	return StoreService.on(player, key) and Passes.owns(player, key)
end

-- Pay Boost: what to add to this player's labor + tips share (0 without it / in a record run)
function StoreService.boost(player: Player, laborAndTips: number, record: boolean?): number
	if record or not active(player, "PayBoost") then
		return 0
	end
	return math.floor(laborAndTips * (Config.PayBoostMult - 1))
end

-- the walking speed with nothing in hands (VIP: +10%, all paid speed together under Config.PaidSpeed)
function StoreService.walk(player: Player, record: boolean?): number
	local extra = if not record and active(player, "VIPMechanic") then 0.10 else 0
	return Config.NormalWalkSpeed * (1 + math.min(extra, Config.PaidSpeed))
end

------------------------------------------------------------------------------------------------------- envelopes

local function today(): number
	return math.floor(os.time() / 86400) -- (UTC days)
end

-- minutes of envelopes left today (rolls the day over in the save)
local function envLeft(player: Player): number
	local d = PlayerData.get(player) :: any
	if not d then
		return 0
	end
	if d.envDay ~= today() then
		d.envDay, d.envUsed = today(), 0
	end
	return math.max(0, StoreData.DayMinutes - (d.envUsed or 0))
end

local function mirror(player: Player)
	player:SetAttribute("EnvLeft", envLeft(player))
	for _, it in StoreData.Items do
		if it.kind == "pass" then
			player:SetAttribute("Owns" .. it.key, Passes.owns(player, it.key) or nil)
		end
	end
	player:SetAttribute("VIP", active(player, "VIPMechanic") or nil)
	player:SetAttribute("StarterLook", active(player, "StarterPack") or nil)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.WalkSpeed >= Config.NormalWalkSpeed - 0.01 then
		hum.WalkSpeed = StoreService.walk(player) -- (not while carrying — slower then: CarryService sets that itself)
	end
end
StoreService.refresh = mirror

local function keyOfProduct(id: number): string?
	for key, pid in Config.Products do
		if pid == id then
			return key
		end
	end
	return nil
end

-- one purchase paid (or found paid already). Separate from ProcessReceipt so Studio tests can run it (DevCall)
function StoreService.grant(player: Player, key: string, purchaseId: string): Enum.ProductPurchaseDecision
	local d = PlayerData.get(player) :: any
	local item = itemOf[key]
	if not d or not item or not item.minutes or not player:GetAttribute("Loaded") then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	d.receipts = d.receipts or {}
	if table.find(d.receipts, purchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted -- (Roblox asked again: it was paid)
	end
	local left = envLeft(player)
	if left < item.minutes then
		-- (the screen locks it; someone got past that — paid all the same, it's their Robux: logged for main)
		warn(string.format("[StoreService] %s bought %s over today's envelope minutes (%d left)", player.Name, key, left))
	end
	local level = (player:GetAttribute("Level") :: number?) or 1
	local money = StoreData.envelopeMoney(level, item.minutes)
	PlayerData.addMoney(player, money)
	PlayerData.hold(player, money) -- (not spendable until it's stored: a failed save takes all of it back)
	d.envUsed = (d.envUsed or 0) + item.minutes
	table.insert(d.receipts, purchaseId)
	while #d.receipts > Config.ReceiptsKept do
		table.remove(d.receipts, 1)
	end
	-- counted only once stored (Studio has no store: the test runs count as stored)
	local stored = PlayerData.saveNow(player) or RunService:IsStudio()
	PlayerData.hold(player, -money)
	if not stored then
		PlayerData.addMoney(player, -money)
		d.envUsed -= item.minutes
		table.remove(d.receipts, table.find(d.receipts, purchaseId) :: number)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	Remotes.Notify:FireClient(player, "n.cashEnvelope", { money = money }, "good")
	mirror(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- exploit audit C3: Roblox calls this at join for receipts it still owes — wait for the player's save to load (up to
-- LOAD_WAIT, stops if they leave) instead of saying "not yet" at once; and while one receipt is being paid (its save
-- yields), the same receipt asked again is "not yet" — never "granted" for a payment whose save may still fail
local LOAD_WAIT = 30
local inFlight: { [string]: boolean } = {}

local function processReceipt(receipt: { [string]: any }): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	local key = keyOfProduct(receipt.ProductId)
	if not player or not key then
		return Enum.ProductPurchaseDecision.NotProcessedYet -- (they left / an unknown product: Roblox asks again later)
	end
	local t0 = os.clock()
	while player.Parent and not player:GetAttribute("Loaded") and os.clock() - t0 < LOAD_WAIT do
		task.wait(0.5)
	end
	local id = tostring(receipt.PurchaseId)
	if inFlight[id] then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	inFlight[id] = true
	local ok, r = pcall(StoreService.grant, player, key, id)
	inFlight[id] = nil
	if not ok then
		warn("[StoreService] receipt " .. id .. " failed: " .. tostring(r))
	end
	return if ok then r else Enum.ProductPurchaseDecision.NotProcessedYet
end
StoreService.processReceipt = processReceipt -- (DevCall store tests)

------------------------------------------------------------------------------------------------------- passes

-- the Starter Pack's money, once ever per player
local function starter(player: Player)
	local d = PlayerData.get(player) :: any
	if not d or d.starterGiven or not active(player, "StarterPack") then
		return
	end
	d.starterGiven = true
	PlayerData.addMoney(player, Config.StarterCash)
	if not (PlayerData.saveNow(player) or RunService:IsStudio()) then
		-- (not stored: undone, it comes again on the next join)
		d.starterGiven = false
		PlayerData.addMoney(player, -Config.StarterCash)
		return
	end
	Remotes.Notify:FireClient(player, "n.starterPack", { money = Config.StarterCash }, "good")
end

local function ready(player: Player)
	mirror(player)
	starter(player)
end
StoreService.ready = ready

function StoreService.start()
	MarketplaceService.ProcessReceipt = processReceipt
	PlayerData.joined.Event:Connect(ready)
	Passes.bought.Event:Connect(function(player: Player)
		ready(player)
	end)
	local function onPlayer(p: Player)
		p.CharacterAdded:Connect(function()
			task.defer(mirror, p)
		end)
		p:GetAttributeChangedSignal("StoreTest"):Connect(function()
			ready(p)
		end)
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in Players:GetPlayers() do
		onPlayer(p)
	end
end

return StoreService
