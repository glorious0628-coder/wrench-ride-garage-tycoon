-- tools/bake_world.luau (wr-builder): bake the map into the open place in EDIT mode.
-- 1) STUDIO_ID=<id> py tools/sync_to_studio.py --only ServerScriptService.World
-- 2) run this file with execute_luau (Edit), e.g.
--    py tools/studio_mcp.py call execute_luau  (code = this file, datamodel_type = Edit)
-- Set REFS = true to also drop measuring refs (R15 dummies + car-size boxes) into workspace.BuilderRefs
-- (builder window only; off by default so a shipping bake never gets them. WorldBoot also removes them at server start).
local REFS = false

local SSS = game:GetService("ServerScriptService")
local src = SSS:FindFirstChild("World")
assert(src, "ServerScriptService.World is missing: sync src first")

-- require() caches per instance: work on a fresh clone so edits to the modules always take effect
local tmp = src:Clone()
for _, d in ipairs(tmp:GetDescendants()) do
	if d:IsA("Script") then
		d:Destroy()
	end
end
tmp.Parent = game:GetService("ServerStorage")
local ok, res = pcall(function()
	return require(tmp:FindFirstChild("Build")).build({ force = true })
end)
tmp:Destroy()
if not ok then
	error("bake failed: " .. tostring(res))
end
local garage = res

local refs = workspace:FindFirstChild("BuilderRefs")
if refs then
	refs:Destroy()
end
if REFS then
	refs = Instance.new("Folder")
	refs.Name = "BuilderRefs"
	local function carBox(name, cf)
		local p = Instance.new("Part")
		p.Name = name
		p.Anchored = true
		p.CanCollide = false
		p.Size = Vector3.new(7.6, 5.8, 17) -- docs/specs/car_spec.md §0
		p.CFrame = cf * CFrame.new(0, 2.9, 0)
		p.Color = Color3.fromRGB(70, 140, 220)
		p.Transparency = 0.35
		p.Parent = refs
	end
	local bay1 = garage.Bays.Bay1
	carBox("CarRef_Bay1", bay1.CarSpot.CFrame)
	carBox("CarRef_Approach", bay1.ApproachSpot.CFrame)
	carBox("CarRef_Parking1", garage.Parking.Parking1.CFrame)
	carBox("CarRef_Parking4", garage.Parking.Parking4.CFrame)
	-- R15 dummies (default body) standing where people work / wait
	local Players = game:GetService("Players")
	local okRig, rig = pcall(function()
		return Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
	end)
	local spots = {
		{ "R15_BesideCar", Vector3.new(6.5, 0.2, -1) },
		{ "R15_AtBench", bay1.Parent.Parent.Workbenches.Workbench1.WorkPoint.Position },
		{ "R15_AtCounter", garage.PartsCounter.ServicePoint.Position },
		{ "R15_InDoorway", Vector3.new(0, 0.2, -19) },
		{ "R15_Waiting", garage.WaitingRoom.ReceptionDesk.ServicePoint.Position },
	}
	for _, s in ipairs(spots) do
		local m
		if okRig and rig then
			m = rig:Clone()
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Anchored = true
					d.CanCollide = false -- a ref, never a wall
					d.CanQuery = false
				end
			end
			m:PivotTo(CFrame.new(s[2]))
			local bcf, size = m:GetBoundingBox()
			m:PivotTo(m:GetPivot() + Vector3.new(0, s[2].Y - (bcf.Position.Y - size.Y / 2), 0))
		else
			m = Instance.new("Part") -- fallback: 2 x 5.2 x 1 block
			m.Anchored = true
			m.Size = Vector3.new(2, 5.2, 1)
			m.CanCollide = false
			m.CFrame = CFrame.new(s[2] + Vector3.new(0, 2.6, 0))
		end
		m.Name = s[1]
		m.Parent = refs
	end
	if okRig and rig then
		rig:Destroy()
	end
	refs.Parent = workspace
end

local n = 0
for _, d in ipairs(garage:GetDescendants()) do
	if d:IsA("BasePart") then
		n += 1
	end
end
return ("baked Garage v%s: %d parts%s"):format(tostring(garage:GetAttribute("WorldVersion")), n, REFS and " (+refs)" or "")
