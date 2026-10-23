-- A car type's taken-apart 3D, one table: its engine bay (Generated/<type>Bay) + its underside (Generated/<type>Under)
-- — the same shape as one generated module ({ car, lumps, parts }), so everything that reads a type's 3D (blocks, ways
-- out, CarLook, the bake) sees both. Node ids never repeat across one type's sets. A type with no sets of its own =
-- an empty table (its lumps can't come apart: PartGraph.lumpLive). (The corner suspension, piece E2, stays apart:
-- Generated/<type>Susp, its own switch.) Main lumps 10-23: the SUV / the pumpkin coach get their own sets.

local Generated = script.Parent:WaitForChild("Generated")

export type Set = { car: string, lumps: { string }, parts: { [string]: any }, setOf: { [string]: string } }

local Car3D = {}

-- (<type><set>: the module names tools/gen_partdata.py writes — the engine bay, the underside, and the body taken apart:
-- shell panels / doors / trunk lid, glass, chassis, interior — main lumps 10-23)
Car3D.SETS = { "Bay", "Under", "Shell", "Glass", "Chassis", "Interior" }

local cache: { [string]: Set } = {}
function Car3D.of(typeName: string): Set
	if cache[typeName] then
		return cache[typeName]
	end
	local out: Set = { car = typeName, lumps = {}, parts = {}, setOf = {} }
	for _, s in Car3D.SETS do
		local m = Generated:FindFirstChild(typeName .. s)
		if not (m and m:IsA("ModuleScript")) then
			continue
		end
		local gen = require(m) :: any
		for _, lump in gen.lumps do
			table.insert(out.lumps, lump)
		end
		for id, p in gen.parts do
			assert(out.parts[id] == nil, "Car3D: " .. typeName .. " node " .. id .. " is in two 3D sets")
			out.parts[id] = p
			out.setOf[id] = m.Name
		end
	end
	cache[typeName] = out
	return out
end

-- a type's corner suspension 3D (Generated/<type>Susp, piece E2 — its own switch), empty if none. cameras = each job's
-- view with the wheel off, { eye, target } in car space, left side (parts.json camera_hints — WorkView)
local suspCache: { [string]: any } = {}
function Car3D.susp(typeName: string): {
	lumps: { string },
	hides: { [string]: { string } },
	cameras: { [string]: { eye: Vector3, target: Vector3 } },
	parts: { [string]: any },
}
	if suspCache[typeName] == nil then
		local m = Generated:FindFirstChild(typeName .. "Susp")
		local gen = if m and m:IsA("ModuleScript") then require(m) :: any else {}
		suspCache[typeName] = { lumps = gen.lumps or {}, hides = gen.hides or {}, cameras = gen.cameras or {}, parts = gen.parts or {} }
	end
	return suspCache[typeName]
end

-- a lump's name in its meshes: Deco_EngineBay -> EngineBay (Decor_EngineBayV2), Decor_Chassis -> Chassis (Decor_ChassisV2)
function Car3D.key(lump: string): string
	return (lump:gsub("^Decor?_", ""))
end

-- a type's mesh prefix in ReplicatedStorage.CarMeshes (the sedan's = none; CarParts.Types.<type>.prefix says the same)
function Car3D.prefix(typeName: string): string
	return if typeName == "Sedan" then "" else typeName .. "_"
end

return Car3D
