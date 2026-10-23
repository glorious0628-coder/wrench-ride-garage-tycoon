--!strict
-- World/Seasonal (wr-builder, 10-21): decor that only shows in its weeks. Build keeps it in ServerStorage.WorldSeasonal;
-- at runtime this moves it into workspace.Garage while the season is on and back out after.
--   Halloween: Config.Halloween.start .. finish (server UTC). workspace attribute SeasonHalloween = true / false forces
--   it for play tests (nil = by the dates) — HalloweenService.forceActive can set the same attribute.
--   The "Closing soon" sign: when HalloweenService enables ClosingSign.Label, its back glow + light flicker on here.
--   Seasonal.start()  WorldBoot calls it once (checks now, on the attribute, and every 30 s)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Seasonal = {}

local function halloweenOn(): boolean
	local force = workspace:GetAttribute("SeasonHalloween")
	if force ~= nil then
		return force == true
	end
	local h = (Config :: any).Halloween
	local now = os.time()
	return h ~= nil and now >= h.start and now < h.finish
end

local wired: { [Instance]: boolean } = {}

-- the sign's glow follows its words (a short neon flicker when they come on)
local function wireSign(decor: Instance)
	local sign = decor:FindFirstChild("ClosingSign", true)
	local hanger = decor:FindFirstChild("ClosingSignHanger", true)
	local glow = hanger and hanger:FindFirstChild("SignGlow") :: BasePart?
	local gui = sign and sign:FindFirstChild("Label") :: SurfaceGui?
	local light = glow and glow:FindFirstChild("SignLight") :: PointLight?
	if not (glow and gui and light) or wired[gui] then
		return
	end
	wired[gui] = true
	local offColor = glow.Color
	local words = gui:FindFirstChildOfClass("TextLabel")
	local function set(on: boolean)
		glow.Material = if on then Enum.Material.Neon else Enum.Material.SmoothPlastic
		glow.Color = if on then Color3.fromRGB(150, 74, 222) else offColor
		light.Enabled = on
		if words then
			words.TextTransparency = if on then 0 else 0.85
		end
	end
	gui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not gui.Enabled then
			set(false)
			return
		end
		task.spawn(function()
			for _, t in ipairs({ 0.08, 0.1, 0.06, 0.18 }) do -- bzzt: on, off, on, off... on
				set(true)
				task.wait(t)
				set(false)
				task.wait(t * 0.7)
			end
			set(gui.Enabled)
		end)
	end)
end

function Seasonal.refresh()
	local garage = workspace:FindFirstChild("Garage")
	local store = ServerStorage:FindFirstChild("WorldSeasonal")
	if not garage then
		return
	end
	local decor = garage:FindFirstChild("HalloweenDecor") or (store and store:FindFirstChild("HalloweenDecor"))
	if not decor then
		return
	end
	wireSign(decor)
	local home: Instance? = if halloweenOn() then garage else store
	if home and decor.Parent ~= home then
		decor.Parent = home
	end
end

function Seasonal.start()
	Seasonal.refresh()
	workspace:GetAttributeChangedSignal("SeasonHalloween"):Connect(Seasonal.refresh)
	task.spawn(function()
		while true do
			task.wait(30)
			Seasonal.refresh()
		end
	end)
end

return Seasonal
