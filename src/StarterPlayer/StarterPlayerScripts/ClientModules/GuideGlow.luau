-- "Only that part lights up" (rival_upgrade B2-1 ②): the guide line's one part gets a soft yellow outline (yellow =
-- the next thing, the colour promise for every screen), and when the next thing is one bolt, that bolt gets a brighter
-- one. One of each at a time; nothing while the tutorial leads (its own highlight) or when the guide has no part.
-- Fed by the Client hint loop with Guide.next's info: GuideGlow.set(info?).

local Players = game:GetService("Players")

local HUD = require(script.Parent.HUD)

local GuideGlow = {}

local YELLOW = Color3.fromRGB(250, 200, 30)
local player = Players.LocalPlayer
local partGlow: Highlight? = nil
local boltGlow: Highlight? = nil

local function make(name: string, fillT: number, lineT: number): Highlight
	local h = Instance.new("Highlight")
	h.Name = name
	h.FillColor = YELLOW
	h.FillTransparency = fillT
	h.OutlineColor = YELLOW
	h.OutlineTransparency = lineT
	h.DepthMode = Enum.HighlightDepthMode.Occluded -- (never through the hood: only what you can see)
	h.Enabled = false
	h.Parent = workspace.CurrentCamera
	return h
end

local function aim(h: Highlight, what: Instance?)
	if h.Adornee ~= what then
		h.Adornee = what
	end
	h.Enabled = what ~= nil and what.Parent ~= nil
end

function GuideGlow.set(info: { [string]: any }?)
	if not partGlow then
		partGlow = make("GuidePart", 0.8, 0.1)
		boltGlow = make("GuideBolt", 0.3, 0)
	end
	local tut = player:GetAttribute("Tut") :: number?
	local hud = HUD.gui()
	-- (a mini-game screen is up: its own picture shows the spot — nothing glows over it)
	local leading = (tut ~= nil and tut < 4 and not player:GetAttribute("TutSkip")) or (hud ~= nil and hud:GetAttribute("Minigame") == true)
	local glow = if info and not leading then info.glow else nil
	local target = if info and not leading then info.target else nil
	local bolt = if target and typeof(target) == "Instance" and target:IsA("BasePart") and target:GetAttribute("Bolt") then target else nil
	-- one bright target: while the step is a bolt only the bolt shines; the part outline waits for a step about the part
	aim(partGlow :: Highlight, if bolt == nil and typeof(glow) == "Instance" then glow else nil)
	aim(boltGlow :: Highlight, bolt)
end

return GuideGlow
