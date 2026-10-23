--!strict
-- World/Expansion: places for Lv2 (전문 정비소, UnlockLevel 6) and Lv3 (대형 모터스, UnlockLevel 16).
-- For now each is a pink placeholder block (see-through, no collision) holding the SAME contract markers the real
-- build will have, so code can be written and tested against them now. Names stay when the pink turns real.

local Kit = require(script.Parent.Kit)
local marker = Kit.marker

local Expansion = {}

local F = 0.2

local function bay(bays: Instance, name: string, cx: number, unlock: number)
	local m = Kit.model(bays, name)
	m:SetAttribute("UnlockLevel", unlock)
	m:SetAttribute("Placeholder", true)
	Kit.placeholder(m, "Placeholder", cx - 14, 0, -20, cx + 14, 20, 20)
	marker(m, "CarSpot", Vector3.new(cx, F, -1), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	local lift = marker(m, "LiftSpot", Vector3.new(cx, F, -1), Vector3.new(0, 0, 1), Vector3.new(16, 0.2, 4))
	lift:SetAttribute("Installed", false)
	lift:SetAttribute("PostOffsetX", 6.0)
	marker(m, "ApproachSpot", Vector3.new(cx, 0, -36), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(m, "DriverExitSpot", Vector3.new(cx + 7, F, -3), Vector3.new(1, 0, 0))
	marker(m, "WorkArea", Vector3.new(cx, F + 9.9, 0), Vector3.new(0, 0, 1), Vector3.new(26, 19.8, 38))
	return m
end

-- a back-yard building (restore bay / paint booth): x cx-16..cx+16, z 44..80, door to the back lane (-Z)
local function backBuilding(garage: Instance, name: string, cx: number, unlock: number)
	local m = Kit.model(garage, name)
	m:SetAttribute("UnlockLevel", unlock)
	m:SetAttribute("Placeholder", true)
	Kit.placeholder(m, "Placeholder", cx - 16, 0, 44, cx + 16, 20, 80)
	marker(m, "CarSpot", Vector3.new(cx, F, 62), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(m, "ApproachSpot", Vector3.new(cx, 0, 32), Vector3.new(0, 0, 1), Vector3.new(8, 0.2, 18))
	marker(m, "WorkArea", Vector3.new(cx, F + 9.9, 62), Vector3.new(0, 0, 1), Vector3.new(30, 19.8, 34))
	return m
end

function Expansion.build(garage: Model)
	local bays = garage:FindFirstChild("Bays") or Kit.folder(garage, "Bays")
	-- Bay3 / Bay4: real annexes now (World/Growth annexBay, Owned / Locked looks) — no pink blocks left here
	local _ = bay

	-- RestoreBay, PaintBooth, Showroom: World/FlipPlaces (real builds with Owned / Locked looks)

	-- signs on the pink blocks so a viewer knows what goes where (blockout only)
	for _, item in ipairs({
		{ bays:FindFirstChild("Bay3"), "BAY 3 - Lv10" },
		{ bays:FindFirstChild("Bay4"), "BAY 4 - Lv16" },
	}) do
		local holder = item[1] :: Instance?
		local ph = holder and holder:FindFirstChild("Placeholder") :: BasePart?
		if ph then
			local gui = Instance.new("SurfaceGui")
			gui.Name = "Label"
			gui.Face = Enum.NormalId.Front
			gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			gui.PixelsPerStud = 20
			local t = Instance.new("TextLabel")
			t.Size = UDim2.fromScale(1, 0.3)
			t.Position = UDim2.fromScale(0, 0.35)
			t.BackgroundTransparency = 1
			t.TextScaled = true
			t.Font = Enum.Font.GothamBold
			t.TextColor3 = Color3.new(1, 1, 1)
			t.Text = item[2] :: string
			t.Parent = gui
			gui.Parent = ph
		end
	end
end

return Expansion
