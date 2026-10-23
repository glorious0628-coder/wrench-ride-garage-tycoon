-- The tools & upgrades shop (Shared/Equipment; alpha_scope v0.2 §3): a "Tools & upgrades" prompt at the tool chest
-- opens the client's window; BuyUpgrade checks the level, the money, and who may buy it (garage upgrades = the
-- garage owner), saves it in their data (PlayerData.owned → DataService), then
--   hand tools: into their backpack (and back after every respawn / rejoin)
--   garage:     the map follows the owner's level + upgrades (UpgradeService → World/Upgrades): Bay2 appears, the
--               lift turns hydraulic, the shelf goes up...

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Equipment = require(ReplicatedStorage.Shared.Equipment)
local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local ToolKit = require(script.Parent.ToolKit)
local UpgradeService = require(script.Parent.UpgradeService)
local Places = require(script.Parent.Places)
local Guard = require(script.Parent.Guard)

local EquipmentService = {}
EquipmentService.onBought = nil :: ((p: Player, key: string) -> ())? -- ShiftService.unlock

-- the garage looks like its owner's: their level, their garage upgrades
function EquipmentService.refreshMap()
	local owner = PlayerData.owner()
	local d = owner and PlayerData.get(owner)
	local owned = {}
	for id in (if d then d.owned else {}) do
		local it = Equipment.ById[id]
		if it and it.kind == "garage" then
			owned[id] = true
		end
	end
	-- a new owner without a bay / lift the old owner had: nobody loses a car in progress — that bay and the
	-- hydraulic lift stay (as temporary) until the work there is done (Main's loop lets them go)
	local bay2 = Places.find("Bays.Bay2")
	if bay2 and bay2:GetAttribute("CarId") and not owned.Bay2 then
		UpgradeService.setTemp("Bay2", true)
	end
	if not owned.HydraulicLift then
		for _, bay in Places.bays() do
			if (bay:GetAttribute("LiftLevel") or 1) > 2 then
				UpgradeService.setTemp("HydraulicLift", true)
			end
		end
	end
	UpgradeService.set(if owner then PlayerData.levelFor(d.rep) else 1, owned)
end

-- the garage has it (owner bought it) / this player has it (hand tool)
function EquipmentService.garageHas(id: string): boolean
	local owner = PlayerData.owner()
	return owner ~= nil and PlayerData.owns(owner, id)
end

function EquipmentService.playerHas(player: Player, id: string): boolean
	return PlayerData.owns(player, id)
end

local function giveTools(player: Player)
	for id in Equipment.HandTools do
		if PlayerData.owns(player, id) then
			ToolKit.give(player, id)
		end
	end
end

local function buy(player: Player, id: any): (boolean, string?, { [string]: any }?)
	local it = type(id) == "string" and Equipment.ById[id]
	if not it then
		return false
	end
	local d = PlayerData.get(player)
	if not d then
		return false
	end
	local spot = Places.find("Tools.ToolChest1.UsePoint") :: BasePart?
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	-- (no character = no buying: a respawn isn't a way round the distance — exploit audit L4)
	if not root or (spot and not Guard.near(player, spot.Position, Config.ShopReach)) then
		return false, "n.tooFar"
	end
	if it.kind == "garage" and PlayerData.owner() ~= player then
		return false, "n.ownerOnly"
	end
	if PlayerData.owns(player, it.id) then
		return false
	end
	if PlayerData.levelFor(d.rep) < it.level then
		return false, "n.needLevel", { level = it.level }
	end
	if not PlayerData.spend(player, it.price) then
		return false, "n.noMoney"
	end
	PlayerData.addOwned(player, it.id)
	if EquipmentService.onBought then
		EquipmentService.onBought(player, "@equip." .. it.id) -- (today's receipt: new at your garage)
	end
	if Equipment.HandTools[it.id] then
		ToolKit.give(player, it.id)
	end
	if it.kind == "garage" then
		EquipmentService.refreshMap()
	end
	return true, "n.boughtUpgrade", { item = "@equip." .. it.id }
end

function EquipmentService.start()
	Remotes.BuyUpgrade.OnServerInvoke = Guard.wrap("BuyUpgrade", 0.5, buy)
	local spot = Places.find("Tools.ToolChest1.UsePoint") :: BasePart?
	if spot then
		local p = Instance.new("ProximityPrompt")
		p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
		p.Name = "UpgradePrompt"
		p.KeyboardKeyCode = Enum.KeyCode.E
		p.MaxActivationDistance = Config.PromptDistance
		p.RequiresLineOfSight = false
		Locale.tag(p, "act.upgrades")
		Locale.tag(p, "obj.toolChest", nil, "ObjectText")
		p.Parent = spot
	end
	-- bought tools come back with every character; the map follows the owner (joins, leaves, levels up)
	local function hook(player: Player)
		player.CharacterAdded:Connect(function()
			task.defer(giveTools, player)
		end)
		player:GetAttributeChangedSignal("Level"):Connect(function()
			if PlayerData.owner() == player then
				EquipmentService.refreshMap()
			end
		end)
	end
	Players.PlayerAdded:Connect(hook)
	for _, p in Players:GetPlayers() do
		hook(p)
	end
	PlayerData.joined.Event:Connect(function(player)
		giveTools(player)
		EquipmentService.refreshMap()
	end)
	PlayerData.ownerChanged.Event:Connect(EquipmentService.refreshMap)
	-- anyone whose save came in before this started
	for _, p in Players:GetPlayers() do
		if PlayerData.get(p) then
			giveTools(p)
		end
	end
	EquipmentService.refreshMap()
end

return EquipmentService
