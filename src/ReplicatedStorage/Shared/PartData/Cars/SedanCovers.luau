-- The sedan's under covers (main 10-23: "the floor reads as one big black plate, the oil pan / fuel tank / exhaust
-- hangers hidden — a cover that is a real part comes off"): the engine's two under covers, the floor's four, the fuel
-- tank guard. The 3D is underbody_v1 (PartData/Generated/SedanUnder: role "part", its F_ bolts / clips). They only
-- exist on a car while Features.UnderView is on (PartGraph.rowLive, flag `under`) and Deco_Underbody is live; no fault
-- uses them yet — they come off to get at what's above them. Worked from the creeper: the front end's covers on
-- Under_Front, the rear floor's on Under_Rear.

local Under = require(script.Parent.Parent:WaitForChild("Generated"):WaitForChild("SedanUnder")).parts

local function cover(id: string, kind: string, zone: string, needs: { string }): { [string]: any }
	return {
		id = id,
		kind = kind,
		pivot = Under[id].pivot,
		zone = zone,
		liftEnd = if zone == "Under_Front" then "F" else "R",
		needs = needs,
		detach = "Drop",
		lump = Under[id].lump,
		under = true,
	}
end

return {
	rows = {
		-- (No.1 under the radiator / bumper; No.2 under the oil pan holds the oil door — the door comes off first: Cars/SedanOil)
		cover("EngineUnderCover_No1", "EngineUnderCover", "Under_Front", { "Lift:Under" }),
		cover("EngineUnderCover_No2", "EngineUnderCover", "Under_Front", { "Lift:Under", "OilAccessPanel" }),
		cover("FrontFloorCover_L", "FloorCover", "Under_Front", { "Lift:Under" }),
		cover("FrontFloorCover_R", "FloorCover", "Under_Front", { "Lift:Under" }),
		cover("FloorUnderCover_L", "FloorCover", "Under_Rear", { "Lift:Under" }),
		cover("FloorUnderCover_R", "FloorCover", "Under_Rear", { "Lift:Under" }),
		cover("FuelTankProtector", "FuelTankProtector", "Under_Rear", { "Lift:Under" }),
	},
}
