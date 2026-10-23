-- Name your garage (monetization.md §1b, name_filter.md): one small window — a text box, one button, one line
-- for what went wrong. The server (NameService) checks and saves; a blocked name can be tried again for free.
-- Opens by itself once a session when the owner may name it for free (Lv3+, not named yet), and from the settings
-- window's "Garage name" row (Settings.luau). Without the free try it asks for the pass.
-- Look: the name is typed onto a bolted dark plate, like the sign it ends up on.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Modules = script.Parent
local Localizer = require(Modules.Localizer)
local UIKit = require(Modules.UIKit)
local UIStyle = require(Modules.UIStyle)
local HUD = require(Modules.HUD)
local JobCard = require(Modules.JobCard)
local Cinema = require(Modules.Cinema)
local SoundPlayer = require(Modules.SoundPlayer)

local NameWindow = {}

local player = Players.LocalPlayer
local C = UIStyle.Color
local NAME_LEVEL = 3

local frame: GuiObject
local box: TextBox
local errLine: TextLabel
local paint: TextButton
local busy = false
local offered = false
local offeredOpen = false -- (the free first name's own window is up: closing it with X still gets the sign's sparkle)

function NameWindow.close()
	UIKit.close(frame)
end

-- the line under the sign: what went wrong (red), else "free the first time" while it is
local function say(key: string?, args: { [string]: any }?)
	if not key and player:GetAttribute("NameFree") and not player:GetAttribute("GarageNamed") then
		errLine.TextColor3 = C.InkSoft
		UIKit.setText(errLine, "name.free")
	else
		errLine.TextColor3 = C.RedDark
		UIKit.setText(errLine, key, args)
	end
end

function NameWindow.open()
	say(nil)
	box.Text = (workspace:GetAttribute("GarageName") :: string?) or ""
	UIKit.open(frame)
end

-- the sign out front that carries the name now (the facade changes with the level: the newest one there wins)
local function liveSign(): BasePart?
	local garage = workspace:FindFirstChild("Garage")
	for _, name in { "NeonSign", "SignBoard", "SignFresh" } do
		local s = garage and garage:FindFirstChild(name, true)
		if s and s:IsA("BasePart") then
			return s
		end
	end
	return nil
end

-- the first name painted (first10_payout §2② 4): the camera goes out front to the real sign for 1.5 s — the name
-- sparkles on it — and comes back. withCamera = false (the window was closed with X): just the sparkle and the sound.
local function celebrate(withCamera: boolean)
	local sign = liveSign()
	if not sign then
		return
	end
	if not (SoundPlayer.play("signPaint", sign.Position) or SoundPlayer.play("levelUp")) then
		SoundPlayer.play("reward")
	end
	local sparkles = Instance.new("Sparkles")
	sparkles.SparkleColor = UIStyle.Color.Gold
	sparkles.Parent = sign
	task.delay(2.6, function()
		sparkles.Enabled = false
		task.wait(1)
		sparkles:Destroy()
	end)
	if not withCamera then
		return
	end
	-- out of the sign's face: its SurfaceGui says which side the words are on
	local gui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
	local normal = sign.CFrame:VectorToWorldSpace(Vector3.FromNormalId(if gui then gui.Face else Enum.NormalId.Front))
	local width = math.max(sign.Size.X, sign.Size.Z)
	local eye = sign.Position + normal * math.max(14, width * 0.8) + Vector3.new(0, -2, 0)
	-- a cut out there (a glide would pass through the shop's walls), a slow push in while it sparkles, a cut back
	local near = eye:Lerp(sign.Position, 0.12)
	local cam = workspace.CurrentCamera
	Cinema.play()
	local t0 = os.clock()
	local HOLD = 1.6
	RunService:BindToRenderStep("NameSignShot", Enum.RenderPriority.Camera.Value + 1, function()
		cam.CameraType = Enum.CameraType.Scriptable
		local k = math.clamp((os.clock() - t0) / HOLD, 0, 1)
		k = 1 - (1 - k) * (1 - k)
		cam.CFrame = CFrame.lookAt(eye:Lerp(near, k), sign.Position)
	end)
	task.delay(HOLD, function()
		RunService:UnbindFromRenderStep("NameSignShot")
		cam.CameraType = Enum.CameraType.Custom
		Cinema.stop()
	end)
end

local function submit()
	if busy then
		return
	end
	busy = true
	UIKit.setButton(paint, nil, "Green", true) -- (while the server checks: no double sends)
	local first = not player:GetAttribute("GarageNamed")
	local ok, key, args = Remotes.NameGarage:InvokeServer(box.Text)
	busy = false
	UIKit.setButton(paint, nil, "Green")
	if ok then
		offeredOpen = false
		NameWindow.close()
		if first then
			celebrate(true)
		end
	elseif key == "rename.need" and Config.Passes.GarageRename then
		NameWindow.close()
		MarketplaceService:PromptGamePassPurchase(player, Config.Passes.GarageRename)
	elseif key then
		say(key, args)
	end
end

-- the free first name: offer it once (a moment after the level-up card)
local function offer()
	if offered or player:GetAttribute("GarageNamed") or not player:GetAttribute("NameFree") then
		return
	end
	if workspace:GetAttribute("GarageOwner") ~= player.UserId or ((player:GetAttribute("Level") :: number?) or 1) < NAME_LEVEL then
		return
	end
	offered = true
	-- one card at a time (first10_payout §2②): the settlement card → its Nice! → the Lv3 card → its Nice! → this
	-- (the level arrives at the hand-back, the settlement card some seconds later when the car has driven off)
	task.spawn(function()
		local gui = HUD.gui()
		local t0 = os.clock()
		while not gui:FindFirstChild("PayCard", true) and os.clock() - t0 < 40 do
			task.wait(0.1)
		end
		if gui:FindFirstChild("PayCard", true) then
			JobCard.PayClosed.Event:Wait()
		end
		task.wait(0.8) -- (the level card comes 0.4 s after the settlement card)
		while gui:FindFirstChild("LevelUp", true) do
			task.wait(0.1)
		end
		task.wait(0.3)
		-- one window at a time: the player opened settings / the shop / anything meanwhile — wait for it to close, then ask
		-- (wr-play test 3: settings, the name window and a card were all up at once)
		-- and not on top of the work: the engine bay / wheel view or a mini-game screen is the player's hands-on moment (wr-play
		-- eval 10-23 TOP 4: the window sat over the engine bay and the job card) — ask once they are out of it
		local function busyNow(): boolean
			return gui:GetAttribute("WindowOpen") == true or player:GetAttribute("WorkZone") ~= nil or gui:GetAttribute("Minigame") == true or Cinema.playing() -- (Ella's film turns the HUD off: wr-dev)
		end
		repeat
			while busyNow() and player.Parent do
				task.wait(0.5)
			end
			task.wait(0.4)
		until not busyNow() or not player.Parent
		if not player:GetAttribute("GarageNamed") then
			offeredOpen = true
			NameWindow.open()
		end
	end)
end

function NameWindow.start()
	local win = UIKit.window(HUD.gui(), { name = "NameGarage", title = "name.prompt", maxSize = Vector2.new(520, 300), onClose = function()
		local wasOffer = offeredOpen
		offeredOpen = false
		NameWindow.close()
		if wasOffer and not player:GetAttribute("GarageNamed") then
			celebrate(false) -- (no name yet: the fresh sign still sparkles, no camera trip)
		end
	end })
	frame = win.root
	-- the name goes on a sign: the bolted dark plate, white outlined letters like the sign outside
	local sign = UIKit.plate(win.body, {
		name = "Sign",
		anchor = Vector2.new(0.5, 0),
		pos = UDim2.fromScale(0.5, 0.08),
		size = UDim2.fromScale(0.86, 0.34),
	})
	box = Instance.new("TextBox")
	box.Name = "Name"
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.fromScale(0.5, 0.5)
	box.Size = UDim2.fromScale(0.8, 0.56)
	box.BackgroundTransparency = 1
	box.TextColor3 = C.White
	box.PlaceholderColor3 = C.PlateEdge
	box.FontFace = UIStyle.Font.Title
	box.TextScaled = true
	box.ClearTextOnFocus = false
	box.Text = ""
	box.PlaceholderText = Localizer.t("name.hint")
	local cap = Instance.new("UITextSizeConstraint")
	cap.MaxTextSize = 34
	cap.Parent = box
	box.Parent = sign
	UIKit.outline(box :: any)
	box.FocusLost:Connect(function(enter)
		if enter then
			submit()
		end
	end)
	UIKit.onLang(function()
		box.PlaceholderText = Localizer.t("name.hint")
	end)
	-- (dark on the steel: an outlined gold line didn't read there)
	errLine = UIKit.text(win.body, { name = "Why", font = "Bold", size = UDim2.fromScale(0.9, 0.13), pos = UDim2.fromScale(0.5, 0.53), outline = false, max = 20 })
	paint = UIKit.button(win.body, { name = "Paint", key = "name.ok", size = UDim2.fromScale(0.5, 0.24), pos = UDim2.fromScale(0.5, 0.8), max = 22, onClick = submit })
	UIKit.fitButton(paint, { text = 0.56, pad = 0.5, min = 2.6, max = 22 }) -- (as wide as its words: user 10-22)

	for _, a in { "Level", "NameFree", "GarageNamed" } do
		player:GetAttributeChangedSignal(a):Connect(offer)
	end
	workspace:GetAttributeChangedSignal("GarageOwner"):Connect(offer)
	offer()
end

return NameWindow
