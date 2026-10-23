-- The sedan's oil change parts (10-23 user: "put the oil change in before launch"; docs/design/full_teardown.md ④,
-- notes/research/car_knowledge/teardown/oil_belt_study.md §1, decision notes/gpt/wr-dev2/oil_decision.md): the small
-- door in the engine's under cover, the drain plug and its gasket, the filter. The 3D is underbody_v1
-- (PartData/Generated/SedanUnder); the bay's OilFillCap and Dipstick rows are in Cars/Sedan. They only exist on a car
-- while Features.OilChange AND Features.UnderView are on (PartGraph.rowLive, flag `oil`) and their lump is live.
-- Order in the game = who is reachable first: the door first (its 4 screws), then the plug and the filter under it.
-- The oil itself (pan, draining, pouring, the level) is Modules/OilService, not a `needs`: a `needs` is the same rule
-- coming off and going back on, so "the new gasket goes on before the plug" can't be said here.

local Under = require(script.Parent.Parent:WaitForChild("Generated"):WaitForChild("SedanUnder")).parts

-- a row under the engine: the pivot from the 3D, the creeper's front zone (you lie on the creeper at the front stands,
-- under the oil pan — CarParts.work), falls down when it comes off
local function under(id: string, kind: string, needs: { string }, extra: { [string]: any }?): { [string]: any }
	local row: { [string]: any } =
		{ id = id, kind = kind, pivot = Under[id].pivot, zone = "Under_Front", liftEnd = "F", needs = needs, detach = "Drop", lump = Under[id].lump, oil = true }
	if extra then
		for k, v in extra do
			row[k] = v
		end
	end
	return row
end

return {
	rows = {
		-- the door (the cover's "No.4" part): 4 screws, a screwdriver
		under("OilAccessPanel", "OilAccessPanel", { "Lift:Under" }),
		-- the plug: socket / wrench, 40 N·m. Its gasket comes off with it and a new one goes on (OilService checks it)
		under("OilDrainPlug", "OilDrainPlug", { "Lift:Under", "OilAccessPanel" }),
		under("OilDrainPlugGasket", "DrainPlugGasket", { "OilDrainPlug" }),
		-- the filter: a filter wrench. The job's slot (a faultable kind: Faults OIL_DUE)
		under("OilFilter", "OilFilter", { "Lift:Under", "OilAccessPanel" }, { faultable = true }),
	},
}
