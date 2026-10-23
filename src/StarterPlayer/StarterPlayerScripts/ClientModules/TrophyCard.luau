-- "New trophy!" (halloween_pumpkin §8: the glass slipper Ella leaves on the garage shelf — a look that stays, no new
-- money). The last beat of Ella's scenes (wr-dev calls it after the morning cut, bars still up, when the server gives
-- the trophy): a plate card that pops in, the hazard band, the title, the trophy turning slowly (its 3D model —
-- CarMeshes.Gear_<id> or ReplicatedStorage.Trophies.<id> — else its icon), its tag line, where it went, and one Nice! button. Outside a
-- scene it shows over the HUD. GPT 2 rounds: notes/gpt/wr-ui/ella_ui_decision.md
--   TrophyCard.show("GlassSlipper")   -- (yields up to 1.2 s right after a skip)
--   TrophyCard.Closed.Event:Wait()     -- then Cinema.stop()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Cinema = require(script.Parent.Cinema)
local HUD = require(script.Parent.HUD)
local SoundPlayer = require(script.Parent.SoundPlayer)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local TrophyCard = {}
TrophyCard.Closed = Instance.new("BindableEvent") -- Nice! pressed (a scene's code then calls Cinema.stop)

local C = UIStyle.Color
local KEY = { GlassSlipper = "trophy.glassSlipper" }
local ICON = { GlassSlipper = "GlassSlipper" } -- UIStyle.Icon name

local card: CanvasGroup? = nil

local function close()
	local c = card
	if not c then
		return
	end
	card = nil
	TrophyCard.Closed:Fire()
	TweenService:Create(c, TweenInfo.new(0.25), { GroupTransparency = 1 }):Play()
	task.delay(0.3, function()
		c:Destroy()
	end)
end

-- the trophy's 3D model turning in a little window (nil when there's no model yet)
local function turning(parent: Instance, id: string): ViewportFrame?
	-- (the baked 3D: CarMeshes.Gear_<id>, as wr-dev's shelf trophy uses; or a Trophies folder)
	local meshes = ReplicatedStorage:FindFirstChild("CarMeshes")
	local folder = ReplicatedStorage:FindFirstChild("Trophies")
	local src = (meshes and meshes:FindFirstChild("Gear_" .. id)) or (folder and folder:FindFirstChild(id))
	if not src or not (src:IsA("Model") or src:IsA("BasePart")) then
		return nil
	end
	local vp = Instance.new("ViewportFrame")
	vp.Name = "Model"
	vp.BackgroundTransparency = 1
	vp.Ambient = Color3.fromRGB(200, 200, 210)
	vp.LightColor = Color3.fromRGB(255, 255, 255)
	vp.LightDirection = Vector3.new(-1, -1, -0.6)
	local model = src:Clone()
	local m: Model
	if model:IsA("Model") then
		m = model
	else
		m = Instance.new("Model")
		model.Parent = m
	end
	m.Parent = vp
	local cf, size = m:GetBoundingBox()
	local r = size.Magnitude * 0.5
	local cam = Instance.new("Camera")
	cam.FieldOfView = 30
	cam.Parent = vp
	vp.CurrentCamera = cam
	local spin = 0
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		if not vp.Parent then
			conn:Disconnect()
			return
		end
		spin += dt * 0.9
		local dist = r / math.tan(math.rad(cam.FieldOfView / 2)) * 1.1
		local eye = cf.Position + Vector3.new(math.sin(spin), 0.35, math.cos(spin)).Unit * dist
		cam.CFrame = CFrame.lookAt(eye, cf.Position)
	end)
	vp.Parent = parent
	return vp
end

function TrophyCard.show(id: string)
	if card then
		card:Destroy()
	end
	-- inside a scene: the card is its last beat — the bars stay, the HUD stays away, the card takes the taps. Just
	-- skipped: let the end of the scene show for a moment first, so the reward has a visible cause (GPT r2)
	local inScene = Cinema.playing()
	if inScene then
		Cinema.holdSkip()
		Cinema.say(nil) -- (after the morning cut: the words and the clock are done with)
		Cinema.clock(nil)
		local wait = 1.2 - Cinema.sinceSkip()
		if wait > 0 then
			task.wait(wait)
		end
	end
	local f = UIKit.plate(if inScene then Cinema.layer() else HUD.gui(), { name = "TrophyCard", bolts = true, group = true, z = 7 }) :: any
	card = f
	-- the trophy first: the 3D model turning, else its icon, else none (then the card is a short one, no gap)
	local pic = Instance.new("Frame")
	pic.Name = "Picture"
	pic.AnchorPoint = Vector2.new(0.5, 0.5)
	pic.SizeConstraint = Enum.SizeConstraint.RelativeYY
	pic.BackgroundColor3 = C.White
	pic.BackgroundTransparency = 0.85 -- (a soft light disc behind it, as the tool slots)
	pic.Parent = f
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(1, 0)
	round.Parent = pic
	local shown = turning(pic, id) or UIKit.icon(pic, UIStyle.Icon[ICON[id] or id], {})
	if shown then
		shown.Size = UDim2.fromScale(0.92, 0.92)
		shown.AnchorPoint = Vector2.new(0.5, 0.5)
		shown.Position = UDim2.fromScale(0.5, 0.5)
	end
	pic.Visible = shown ~= nil
	-- y positions (share of the card): with the picture ≈40% of the card's height (≈110 px on a phone, between the
	-- scene's bars) / without it a short card
	local y = if shown
		then { hazard = 0.06, title = 0.16, titleH = 0.12, name = 0.71, nameH = 0.08, where = 0.795, whereH = 0.06, ok = 0.9, okH = 0.115 }
		else { hazard = 0.09, title = 0.28, titleH = 0.2, name = 0.5, nameH = 0.13, where = 0.64, whereH = 0.1, ok = 0.84, okH = 0.2 }
	f.Position = UDim2.fromScale(0.5, 0.5)
	f.Size = UDim2.fromScale(0.42, 0.72)
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.AspectRatio = if shown then 1 else 1.7
	ratio.Parent = f
	local cap = Instance.new("UISizeConstraint")
	cap.MinSize = if shown then Vector2.new(230, 230) else Vector2.new(250, 147)
	cap.MaxSize = if shown then Vector2.new(400, 400) else Vector2.new(440, 260)
	cap.Parent = f
	pic.Position = UDim2.fromScale(0.5, 0.445)
	pic.Size = UDim2.fromScale(0.4, 0.4)
	UIKit.hazard(f, { pos = UDim2.fromScale(0.5, y.hazard), size = UDim2.fromScale(0.82, 0.05) })
	UIKit.text(f, {
		name = "Title",
		key = "trophy.new",
		font = "Title",
		color = C.Gold,
		pos = UDim2.fromScale(0.5, y.title),
		size = UDim2.fromScale(0.84, y.titleH),
		max = 40,
	})
	UIKit.text(f, {
		name = "Name",
		key = KEY[id] or ("trophy." .. id),
		font = "Bold",
		pos = UDim2.fromScale(0.5, y.name),
		size = UDim2.fromScale(0.88, y.nameH),
		max = 24,
	})
	UIKit.text(f, {
		name = "Where",
		key = "trophy.onShelf",
		color = Color3.fromRGB(190, 200, 214),
		pos = UDim2.fromScale(0.5, y.where),
		size = UDim2.fromScale(0.8, y.whereH),
		max = 18,
	})
	local ok = UIKit.button(f, {
		name = "Ok",
		key = "tut.nice",
		style = "Green",
		pos = UDim2.fromScale(0.5, y.ok),
		size = UDim2.fromScale(0.42, y.okH),
		max = 24,
		onClick = close,
	})
	UIKit.fitButton(ok, { text = 0.56, pad = 0.5, min = 2.6, max = 24 }) -- (as wide as its words: user 10-22)
	UIKit.pop(f, 0.3)
	if not SoundPlayer.play("sparkle") then
		SoundPlayer.play("reward")
	end
end

function TrophyCard.close()
	close()
end

return TrophyCard
