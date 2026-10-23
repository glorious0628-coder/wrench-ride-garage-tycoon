--!strict
-- World/Lights (done last, after the build looks right in plain light): bright, clear afternoon (style_B; 10-22 the user
-- found it dark / hazy next to a bright reference: more sun + ambient, thin haze, richer colour) +
-- light from the shop's own fixtures. Few lights, no light shadows (cheap on phones).
-- Touches objects it names (WorldAtmosphere, WorldColor), a few Lighting properties, and the template's
-- ColorGrading tonemapper (its "Retro" preset + bright sun washed the Play view out to near white, wr-dev 10-20).

local Lighting = game:GetService("Lighting")

local Lights = {}

local WARM = Color3.fromRGB(255, 246, 228)

local function surfaceLight(part: Instance, brightness: number, range: number, angle: number)
	if not part:IsA("BasePart") then
		return
	end
	local l = Instance.new("SurfaceLight")
	l.Name = "Light"
	l.Face = Enum.NormalId.Bottom
	l.Brightness = brightness
	l.Range = range
	l.Angle = angle
	l.Color = WARM
	l.Shadows = false
	l.Parent = part
end

function Lights.environment()
	Lighting.ClockTime = 14.5
	Lighting.GeographicLatitude = 38
	Lighting.Brightness = 1.95
	Lighting.Ambient = Color3.fromRGB(82, 82, 86) -- indoor only (sun-lit outdoors uses OutdoorAmbient): v29b, the user wanted the mock's contrast inside (dark ceiling, light pooling from the tubes)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 152, 162)
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 0.3
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.5
	Lighting.ExposureCompensation = -0.1

	local atm = Lighting:FindFirstChild("WorldAtmosphere") :: Atmosphere?
	if not atm then
		local a = Instance.new("Atmosphere")
		a.Name = "WorldAtmosphere"
		a.Parent = Lighting
		atm = a
	end
	assert(atm)
	atm.Density = 0.1
	atm.Offset = 0.1
	atm.Color = Color3.fromRGB(200, 222, 245)
	atm.Decay = Color3.fromRGB(110, 150, 205)
	atm.Glare = 0.05
	atm.Haze = 0.12

	local cc = Lighting:FindFirstChild("WorldColor") :: ColorCorrectionEffect?
	if not cc then
		local c = Instance.new("ColorCorrectionEffect")
		c.Name = "WorldColor"
		c.Parent = Lighting
		cc = c
	end
	assert(cc)
	cc.Saturation = 0.22
	cc.Contrast = 0.08
	cc.Brightness = 0
	cc.TintColor = Color3.fromRGB(255, 252, 246)

	-- template effects: keep them, but neutral tonemapping and no bloom blow-out
	local grading = Lighting:FindFirstChildOfClass("ColorGradingEffect")
	if grading then
		pcall(function()
			(grading :: any).TonemapperPreset = Enum.TonemapperPreset.Default
		end)
	end
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then
		bloom.Intensity = math.min(bloom.Intensity, 0.4)
		bloom.Threshold = math.max(bloom.Threshold, 0.95)
	end
end

function Lights.build(garage: Model)
	-- engine-room fill: the work view looks down into the engine bay under the open hood, which stays near black in
	-- the sun-only light. A soft point light in front of and above each bay's car (the car stands at the cart's x - 8.6,
	-- z -1), no shadows. 0.6: at 1.6 the cream parts blew out, at 0.3 nothing changed (a spot light on the engine barely helped).
	local bays = garage:FindFirstChild("Bays")
	if bays then
		for _, bay in ipairs(bays:GetChildren()) do
			local cart = bay:FindFirstChild("BayCart")
			if cart and cart:IsA("Model") then
				local p = Instance.new("Part")
				p.Name = "EngineFill"
				p.Size = Vector3.one
				p.Transparency = 1
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.CastShadow = false
				p.Position = Vector3.new(cart:GetPivot().Position.X - 8.6, 8, 9)
				local l = Instance.new("PointLight")
				l.Brightness = 0.6
				l.Range = 20
				l.Color = WARM
				l.Shadows = false
				l.Parent = p
				p.Parent = bay
			end
		end
	end
	local d = garage:FindFirstChild("Dressing")
	if d then
		for _, p in ipairs(d:GetChildren()) do
			if p.Name == "LightTube" then
				surfaceLight(p, 1.4, 18, 120)
				local sl = p:FindFirstChildOfClass("SurfaceLight")
				if sl then
					sl.Color = Color3.fromRGB(255, 242, 226) -- warm pools under the tubes (mock: interior_better_a)
				end
			elseif p.Name == "PanelGlow" then
				surfaceLight(p, 0.33, 11, 110)
			end
		end
	end
	Lights.environment()
end

return Lights
