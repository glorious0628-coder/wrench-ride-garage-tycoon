-- A soft fill light while a work view looks into the engine bay or up under the car (wr-play: the new engine bay read almost
-- black behind the scan marks; under the car the underside and its bolts were near-black — the garage's lamps and the sky don't
-- reach there). One local PointLight (no shadows) on an invisible plate next to the camera + a gentle local colour lift (blacks
-- up a little: the engine bay's dark plastic stays dark under any lamp), both faded in / out; nothing for the wheel views or the
-- world. Client only: other players' screens and the map are untouched. The scan marks (Highlights) and the UI are not touched.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local HUD = require(script.Parent.HUD)

local WorkLight = {}

-- per zone kind: how bright, how far it reaches, how far ahead of the camera it sits (along the view), and a lift (studs)
local KINDS = {
	EngineBay = { bright = 1.4, range = 20, ahead = 2.0, up = 1.5, color = Color3.fromRGB(255, 244, 226), lift = 0.035, flat = 0.02 },
	Under = { bright = 1.7, range = 18, ahead = 1.4, up = 0.0, color = Color3.fromRGB(255, 240, 215), lift = 0.012, flat = 0.0 },
}
local FADE = 5 -- 1/s: brightness follows its goal this fast

local player = Players.LocalPlayer
local plate: Part? = nil
local light: PointLight? = nil
local grade: ColorCorrectionEffect? = nil
local level = 0 -- 0..1 now
local last = KINDS.EngineBay

local function kindOf(zone: string?): typeof(KINDS.EngineBay)?
	if zone == "EngineBay" then
		return KINDS.EngineBay
	elseif zone and zone:sub(1, 6) == "Under_" then
		return KINDS.Under
	end
	return nil
end

function WorkLight.start()
	local gui = HUD.gui()
	local p = Instance.new("Part")
	p.Name = "WorkFill"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.Parent = workspace.CurrentCamera
	local l = Instance.new("PointLight")
	l.Shadows = false
	l.Brightness = 0
	l.Enabled = false
	l.Parent = p
	plate, light = p, l
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "WorkLift"
	cc.Enabled = false
	cc.Parent = game:GetService("Lighting")
	grade = cc
	RunService.RenderStepped:Connect(function(dt)
		local cam = workspace.CurrentCamera
		if not plate or not light or not cam then
			return
		end
		if plate.Parent ~= cam then
			plate.Parent = cam
		end
		local k = if gui:GetAttribute("WorkView") == true then kindOf(player:GetAttribute("WorkZone") :: string?) else nil
		if k then
			last = k
		end
		level = if k then math.min(1, level + dt * FADE) else math.max(0, level - dt * FADE)
		light.Enabled = level > 0.01
		if grade then
			grade.Enabled = level > 0.01
			grade.Brightness = last.lift * level
			grade.Contrast = -last.flat * level
		end
		if not light.Enabled then
			return
		end
		light.Brightness = last.bright * level
		light.Range = last.range
		light.Color = last.color
		local cf = cam.CFrame
		plate.CFrame = CFrame.new(cf.Position + cf.LookVector * last.ahead + Vector3.new(0, last.up, 0))
	end)
end

return WorkLight
