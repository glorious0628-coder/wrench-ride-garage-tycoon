-- The map that grows with the garage (world_contract ★ 업그레이드, wr-builder's World/Upgrades): keeps the map in
-- step with the garage level and what's been bought (owned ids), and tells the rest of the code when it changed
-- (a lift swapped → new prompts, Bay2 built → a new bay for customers).

local ServerScriptService = game:GetService("ServerScriptService")

local UpgradeService = {}

local Upgrades: any = nil
do
	local world = ServerScriptService:FindFirstChild("World")
	local m = world and world:FindFirstChild("Upgrades")
	if m then
		local ok, res = pcall(require, m)
		if ok then
			Upgrades = res
		else
			warn("[UpgradeService] World.Upgrades failed: " .. tostring(res))
		end
	end
end

local state = { level = 1, owned = {} :: { [string]: boolean } }
local temp: { [string]: boolean } = {} -- shown for now, not owned (the temporary bay while friends are here)

UpgradeService.changed = Instance.new("BindableEvent") -- :Fire(ids) after the map changed

function UpgradeService.state()
	return state
end

function UpgradeService.has(id: string): boolean
	local n = string.match(id, "^Level(%d+)$")
	if n then
		return state.level >= (tonumber(n) :: number)
	end
	return state.owned[id] == true
end

local function apply()
	if Upgrades then
		local shown = table.clone(state.owned)
		for id in temp do
			shown[id] = true
		end
		-- (apply fires World.Upgrades.Changed itself, which start() forwards)
		local ok, err = pcall(Upgrades.apply, { level = state.level, owned = shown })
		if not ok then
			warn("[UpgradeService] apply failed: " .. tostring(err))
		end
	end
end

-- show (or stop showing) a piece without owning it — the temporary bay (alpha_scope §1-4)
function UpgradeService.setTemp(id: string, on: boolean)
	if (temp[id] == true) == on then
		return
	end
	temp[id] = if on then true else nil
	apply()
end

function UpgradeService.isTemp(id: string): boolean
	return temp[id] == true and not state.owned[id]
end

-- set the garage level / owned ids and update the map (no-op when nothing changed)
function UpgradeService.set(level: number, owned: { [string]: boolean }?)
	state.level = level
	if owned then
		state.owned = table.clone(owned)
	end
	apply()
end

function UpgradeService.start()
	if Upgrades and Upgrades.Changed then
		-- World/Upgrades fires on its own too (e.g. the map was rebuilt)
		Upgrades.Changed.Event:Connect(function(ids)
			UpgradeService.changed:Fire(ids)
		end)
	end
end

return UpgradeService
