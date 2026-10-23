-- Dump everything ReplicatedStorage.Shared.CarParts hands out, as sorted text (Edit execute_luau).
-- Run before and after a change to CarParts / PartGraph and diff the two: the same text = nothing moved.
--   py -I -c "import json; json.dump({'code': open('tools/dump_carparts.luau', encoding='utf-8').read(), 'datamodel_type': 'Edit'}, open('build/dump_args.json', 'w'))"
--   $env:STUDIO_ID = "<id>"; py tools/studio_mcp.py call execute_luau '@build/dump_args.json' > build/carparts_<before|after>.txt
-- (a fresh clone is required, so an older copy cached in the plugin VM never answers)

local Shared = game:GetService("ReplicatedStorage").Shared
local clones = {}
local function fresh(name: string): any
	local m = Shared:FindFirstChild(name)
	if not m then
		return nil
	end
	local c = m:Clone()
	c.Name = name .. "_DumpClone"
	c.Parent = Shared
	table.insert(clones, c)
	return c
end
-- the modules CarParts may require get fresh copies too (PartGraph + its data folder)
local graph = Shared:FindFirstChild("PartGraph")
local data = Shared:FindFirstChild("PartData")
local saved = {}
for _, m in { graph, data } do
	if m then
		local c = m:Clone()
		saved[m] = m.Parent
		m.Parent = nil
		c.Parent = Shared
		table.insert(clones, c)
	end
end
local ok, CarParts = pcall(function()
	return require(fresh("CarParts"))
end)

local function num(n: number): string
	local r = math.round(n * 10000) / 10000
	if r == 0 then
		r = 0
	end
	return string.format("%.4f", r)
end

local function ser(v: any, depth: number?): string
	local d = depth or 0
	local t = typeof(v)
	if t == "number" then
		return num(v)
	elseif t == "Vector3" then
		return "V(" .. num(v.X) .. "," .. num(v.Y) .. "," .. num(v.Z) .. ")"
	elseif t == "Color3" then
		return "C(" .. v:ToHex() .. ")"
	elseif t == "CFrame" then
		local parts = { v:GetComponents() }
		for i, p in parts do
			parts[i] = num(p)
		end
		return "CF(" .. table.concat(parts, ",") .. ")"
	elseif t == "EnumItem" then
		return tostring(v)
	elseif t == "table" then
		if d > 12 then
			return "{...}"
		end
		local keys = {}
		for k in v do
			table.insert(keys, k)
		end
		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)
		local out = {}
		for _, k in keys do
			if type(v[k]) ~= "function" then
				table.insert(out, tostring(k) .. "=" .. ser(v[k], d + 1))
			end
		end
		return "{" .. table.concat(out, ";") .. "}"
	elseif t == "string" then
		return string.format("%q", v)
	end
	return tostring(v)
end

local lines = {}
local function put(label: string, v: any)
	table.insert(lines, label .. " " .. ser(v))
end

local dumped, err = pcall(function()
if not ok then
	table.insert(lines, "REQUIRE FAILED " .. tostring(CarParts))
else
	put("Kinds", CarParts.Kinds)
	put("SlotOrder", CarParts.SlotOrder)
	put("Slots", CarParts.Slots)
	put("WheelCenters", CarParts.WheelCenters)
	put("PadOffset", CarParts.PadOffset)
	put("MeshSets", CarParts.MeshSets)
	put("DecorShow", CarParts.DecorShow)
	put("HoodOpenDeg", CarParts.HoodOpenDeg)
	put("HoodProp", CarParts.HoodProp)
	put("LiftLevels", CarParts.LiftLevels)
	put("Blocks", CarParts.Blocks)
	put("Chassis", CarParts.Chassis)
	put("Shell", CarParts.Shell)
	put("Glass", CarParts.Glass)
	put("Decor", CarParts.Decor)
	put("TypeSets", CarParts.TypeSets)
	put("Scale", CarParts.Scale)
	local typeNames = {}
	for name in CarParts.Types do
		table.insert(typeNames, name)
	end
	table.sort(typeNames)
	for _, name in typeNames do
		local ty = CarParts.type(name)
		put("Type." .. name, ty)
		put("Work." .. name, CarParts.work(name))
		for _, slot in CarParts.SlotOrder do
			local s = ty.Slots[slot]
			put("BlocksFor." .. name .. "." .. slot, CarParts.blocksFor(s.kind, slot, name))
		end
	end
	put("Type.nil", CarParts.type(nil).name)
	put("Type.Unknown", CarParts.type("Unknown").name)
	put("BlocksFor.shared.Battery", CarParts.blocksFor("Battery", nil, nil))
	for _, slot in CarParts.SlotOrder do
		put("Zone." .. slot, { zone = CarParts.zoneOf(slot) or "nil", ["end"] = CarParts.endOf(slot) or "nil" })
	end
	put("Zone.Unknown", { zone = CarParts.zoneOf("Nope") or "nil", ["end"] = CarParts.endOf(nil) or "nil" })
end
end)
if not dumped then
	table.insert(lines, "DUMP FAILED " .. tostring(err))
end

-- (always put the originals back, even after an error)
for _, c in clones do
	c:Destroy()
end
for m, parent in saved do
	m.Parent = parent
end
return table.concat(lines, "\n")
