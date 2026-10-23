-- The tools & upgrades shop (docs/design/alpha_scope.md v0.2 §3, economy.md v0.2 §1-2). Game cash only — never Robux.
-- id = the map's UpgradeId where the map changes (world_contract ★ 업그레이드).
--   kind "tool":   a hand tool, the buyer's own (kept in their save, in their backpack)
--   kind "garage": changes the garage (the map / the lift / the bays); bought by the garage owner, saved with them
-- Free things at a level (Terminal Brush, the Level6 seats) need no row here.

export type Item = { id: string, level: number, price: number, kind: "tool" | "garage", order: number }

local Equipment = {}

Equipment.Items = {
	{ id = "BatteryTester", level = 2, price = 250, kind = "tool", order = 1 },
	{ id = "RatchetWrench", level = 3, price = 500, kind = "tool", order = 2 },
	{ id = "PartsShelfPlus", level = 3, price = 400, kind = "garage", order = 3 },
	{ id = "Bay2", level = 4, price = 1000, kind = "garage", order = 4 },
	{ id = "WheelBalancer", level = 5, price = 1200, kind = "garage", order = 5 },
	{ id = "Stethoscope", level = 6, price = 400, kind = "tool", order = 6 },
	{ id = "ImpactWrench", level = 6, price = 1800, kind = "tool", order = 7 },
	{ id = "HydraulicLift", level = 6, price = 2400, kind = "garage", order = 8 },
	{ id = "OBDReader", level = 6, price = 2500, kind = "garage", order = 9 },
	{ id = "RestorationBay", level = 8, price = 3500, kind = "garage", order = 10 }, -- loop B: junkyard wrecks go here
} :: { Item }

Equipment.ById = {}
for _, it in Equipment.Items do
	Equipment.ById[it.id] = it
end

-- free basic tools every garage has on its tool board from the start — no shop row, nothing to buy
-- (TorqueWrench: the click type, for the wheel nuts' last turn — minigames_launch_decision 2; 2D picture + an empty
-- hand until there is a 3D one)
Equipment.Free = { TorqueWrench = true }

-- the hand tools that are also Roblox Tools in the backpack (the rest work by being owned)
Equipment.HandTools = { RatchetWrench = true, ImpactWrench = true, Stethoscope = true }

return Equipment
