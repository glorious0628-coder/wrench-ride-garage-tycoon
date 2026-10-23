-- What the loading screen fetches first (ReplicatedFirst/LoadingScreen, wr-ui: ContentProvider:PreloadAsync(list),
-- the bar = this list's count). Only what the first minute shows, in that order (main 10-21) — fetching everything
-- would make the wait longer:
--   1. UI images (UIStyle Image / Icon / Badge ids)
--   2. the first customer car's 3D (a sedan: body, glass, chassis, hood, bumpers, wheel, battery) + the paint textures
--   3. the 3 hand tools
--   (4. the first sounds, when they come)
-- Called from ReplicatedFirst, so things may not be here yet: each wait is short and a missing piece is just skipped.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Preload = {}

local FIRST_CAR = { "Decor_Shell", "Decor_Glass", "Decor_Chassis", "Hood_Detail", "Bumper_F_Detail", "Bumper_R_Detail", "Wheel_Detail", "Battery_Detail" }
local TOOLS = { "Tool_Wrench", "Tool_ImpactWrench", "Tool_OBDScanner" }

-- UIStyle lives with the client modules (StarterPlayerScripts, copied to PlayerScripts)
local function uiStyle(): { [string]: any }?
	for _, from in { StarterPlayer:FindFirstChild("StarterPlayerScripts"), Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerScripts") } do
		local modules = from and from:WaitForChild("ClientModules", 3)
		local m = modules and modules:WaitForChild("UIStyle", 2)
		if m and m:IsA("ModuleScript") then
			local ok, style = pcall(require, m)
			if ok then
				return style
			end
		end
	end
	return nil
end

function Preload.list(): { Instance | string }
	local list: { Instance | string } = {}
	local seen: { [string]: boolean } = {}
	-- an image id goes in as a parentless ImageLabel: PreloadAsync on a bare id string fails for images (wr-ui test)
	local function id(s: any)
		if type(s) == "string" and s ~= "" and not seen[s] then
			seen[s] = true
			local holder = Instance.new("ImageLabel")
			holder.Image = s
			table.insert(list, holder)
		end
	end

	local style = uiStyle()
	if style then
		for _, group in { style.Image, style.Icon, style.Badge } do
			local names = {}
			for name in group or {} do
				table.insert(names, name)
			end
			table.sort(names) -- (a steady order)
			for _, name in names do
				id(group[name])
			end
		end
	end

	local meshes = ReplicatedStorage:WaitForChild("CarMeshes", 5)
	if meshes then
		for _, name in FIRST_CAR do
			local t = meshes:FindFirstChild(name)
			if t then
				table.insert(list, t) -- (the model with every mesh in it)
				for _, mp in t:GetDescendants() do
					-- the paint textures, so the bar counts them (copied by the bake: game scripts can't read
					-- SurfaceAppearance maps)
					for _, map in string.split((mp:GetAttribute("PaintMaps") :: string?) or "", ",") do
						id(map)
					end
				end
			end
		end
		for _, name in TOOLS do
			local t = meshes:FindFirstChild(name)
			if t then
				table.insert(list, t)
			end
		end
	end
	return list
end

return Preload
