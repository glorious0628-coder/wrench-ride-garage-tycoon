-- Check the part data (Shared/PartData through Shared/PartGraph) in an Edit window: execute_luau this file's text.
-- Prints every problem (unknown kind / part / condition, a loop, a missing pivot ...) and each part's depth and the
-- order it comes off in. "problems: none" = every car type can be taken apart and put back together on paper.
-- (fresh clones, so the plugin VM never answers from an older cached copy)

local Shared = game:GetService("ReplicatedStorage").Shared
local moved = {}
for _, name in { "PartGraph", "PartData" } do
	local m = Shared:FindFirstChild(name)
	if m then
		local c = m:Clone()
		moved[m] = c
		m.Parent = nil
		c.Parent = Shared
	end
end

local lines = {}
local ok, err = pcall(function()
	local PartGraph = require(Shared:FindFirstChild("PartGraph") :: ModuleScript) :: any
	local problems = PartGraph.check()
	table.insert(lines, "problems: " .. (if #problems == 0 then "none" else tostring(#problems)))
	for _, p in problems do
		table.insert(lines, "  ! " .. p)
	end
	for _, name in PartGraph.types() do
		local car = PartGraph.car(name)
		table.insert(lines, string.format("%s: %d parts", name, #car.order))
		for _, id in car.order do
			local p = car.parts[id]
			table.insert(lines, string.format("  %-14s %-10s depth %d  zone %-11s needs %s  path %s", id, p.kind, PartGraph.depth(name, id), p.zone, table.concat(p.needs, ","), table.concat(PartGraph.path(name, id), ">")))
		end
	end
end)
if not ok then
	table.insert(lines, "CHECK FAILED " .. tostring(err))
end

for m, c in moved do
	c:Destroy()
	m.Parent = Shared
end
return table.concat(lines, "\n")
