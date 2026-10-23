--!strict
-- World/Upgrades (wr-builder): shows / hides the map pieces that change when the shop grows.
-- Contract: docs/specs/world_contract.md (★ 업그레이드로 바뀌는 맵).
--
-- Every switchable piece is a Model or Part with two attributes:
--   UpgradeId    = a shop item id ("Bay2", "HydraulicLift", "WheelBalancer", ...) or a level gate ("Level6")
--   UpgradeState = "Owned"  -> in the world only when the player HAS it (level gate: level >= N)
--                  "Locked" -> in the world only when the player does NOT have it (the "before" look)
-- Hidden pieces are moved to ServerStorage.WorldHidden (not drawn, no collision, no prompts) and come back to
-- the same parent (attribute `Home` = path under workspace.Garage, set at build time).
--
--   Upgrades.apply({ level = 5, owned = { Bay2 = true, WheelBalancer = true } })  -> { changed ids }
--   Upgrades.has(state, id) -> boolean
--   Upgrades.Changed  (BindableEvent, server) :Fire(changedIds)  — e.g. re-bind lift prompts after a lift swap
-- Build calls apply({ level = 1, owned = {} }) so a fresh map shows the Lv1 look.

local ServerStorage = game:GetService("ServerStorage")

local Upgrades = {}

export type State = { level: number, owned: { [string]: boolean } }

local changed = Instance.new("BindableEvent")
changed.Name = "UpgradesChanged"
Upgrades.Changed = changed

local function hiddenFolder(): Folder
	local f = ServerStorage:FindFirstChild("WorldHidden")
	if not f then
		local nf = Instance.new("Folder")
		nf.Name = "WorldHidden"
		nf.Parent = ServerStorage
		f = nf
	end
	return f :: Folder
end

function Upgrades.has(state: State, id: string): boolean
	local n = string.match(id, "^Level(%d+)$")
	if n then
		return (state.level or 1) >= tonumber(n) :: number
	end
	return state.owned ~= nil and state.owned[id] == true
end

local function pathOf(inst: Instance, garage: Instance): string
	local parts = {}
	local node = inst
	while node and node ~= garage do
		table.insert(parts, 1, node.Name)
		node = node.Parent :: Instance
	end
	return table.concat(parts, "/")
end

local function resolve(garage: Instance, path: string): Instance?
	if path == "" then
		return garage
	end
	local node: Instance? = garage
	for name in string.gmatch(path, "[^/]+") do
		node = node and node:FindFirstChild(name)
	end
	return node
end

-- mark every switchable piece with its home path (Build calls this once, before the first apply)
function Upgrades.tagHomes(garage: Instance)
	for _, d in ipairs(garage:GetDescendants()) do
		if d:GetAttribute("UpgradeState") ~= nil and d.Parent then
			d:SetAttribute("Home", pathOf(d.Parent :: Instance, garage))
		end
	end
end

function Upgrades.apply(state: State, garage: Instance?): { string }
	local g = garage or workspace:FindFirstChild("Garage")
	if not g then
		return {}
	end
	local hidden = hiddenFolder()
	local changedIds: { [string]: boolean } = {}
	-- a few passes: pieces nested inside other switchable pieces (a lift inside Bay2) come back after their parent
	for _ = 1, 4 do
		local moved = false
		local candidates = {}
		for _, d in ipairs(g:GetDescendants()) do
			if d:GetAttribute("UpgradeState") ~= nil then
				table.insert(candidates, d)
			end
		end
		for _, d in ipairs(hidden:GetChildren()) do
			if d:GetAttribute("UpgradeState") ~= nil then
				table.insert(candidates, d)
			end
		end
		for _, d in ipairs(candidates) do
			local id = d:GetAttribute("UpgradeId") :: string?
			if id then
				local has = Upgrades.has(state, id)
				local want = if d:GetAttribute("UpgradeState") == "Owned" then has else not has
				local inHidden = d.Parent == hidden
				if want and inHidden then
					local home = resolve(g, (d:GetAttribute("Home") :: string?) or "")
					if home then
						d.Parent = home
						moved = true
						changedIds[id] = true
					end
				elseif not want and not inHidden and d:IsDescendantOf(g) then
					-- (a piece inside a hidden piece rides along with it and is not in this list)
					d.Parent = hidden
					moved = true
					changedIds[id] = true
				end
			end
		end
		if not moved then
			break
		end
	end
	local list = {}
	for id in pairs(changedIds) do
		table.insert(list, id)
	end
	table.sort(list)
	if #list > 0 then
		changed:Fire(list)
	end
	return list
end

return Upgrades
