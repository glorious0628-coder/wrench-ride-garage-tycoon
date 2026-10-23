-- The corner buttons (top right of the top bar row: settings, and Invite left of it) and the settings window: one
-- row per setting.
-- Language — English | 한국어 (user 10-21: "한/영 이거는 설정에서 바꿀 수 있게"). A pick calls Localizer.setLang (saved
-- by wr-dev's code); every UI B label follows Localizer.Changed (UIKit).
-- Garage name — this garage's name and, for its owner, a button to NameWindow (Lv3+; locked like the upgrade rows
-- before that: lock + "Lv 3").
-- Music / Sound effects (user 10-21: background music is in now) — Off | Low | Normal | High, picked like the
-- language (blue = the one on; GPT settings_sound r1/r2: thin volume bars read as a meter, not as buttons; one set of
-- four words is on/off and loudness at once). Each sets its SoundGroup's volume on this screen only:
-- SoundService.Music / .SFX (made by wr-dev's server code; the music player and SoundPlayer put their sounds in them
-- and never touch the group volume).
-- Saved like the language: Remotes.SetSound -> player attributes MusicOn / MusicLv / SfxOn / SfxLv (nil = on, 4).
-- Invite (server_model.md: friends only) — always there while this account can send invites (Gate.canInvite); a
-- friend lands in this garage even where Join can't follow. A corner button, not a new screen.
-- Later rows (graphics) go into the same list.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local SoundPlayer = require(script.Parent.SoundPlayer)

local Localizer = require(script.Parent.Localizer)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)
local Gate = require(script.Parent.Gate)
local NameWindow = require(script.Parent.NameWindow)
local StoreUI = require(script.Parent.StoreUI)

local Settings = {}

local C = UIStyle.Color
local player = Players.LocalPlayer
local NAME_LEVEL = 3 -- (NameService / NameWindow: the same)
-- each language named in itself, so anyone can find their own
local LANGS = { { id = "en", text = "English" }, { id = "ko", text = "한국어" } }

local frame: CanvasGroup
local langButtons: { [string]: TextButton } = {}

-- saved level (1..5) → the group's volume (4 = the mix as made: wr-sound's music at 0.2, the effects at their own)
local LEVEL = { 0.25, 0.5, 0.75, 1, 1.3 }
local DEFAULT_LV = 4
-- a sound row's four choices: Off, then the levels Low / Normal / High set
local CHOICES = { { lv = 0, key = "ui.settings.off" }, { lv = 2, key = "ui.settings.low" }, { lv = 4, key = "ui.settings.normal" }, { lv = 5, key = "ui.settings.high" } }
-- one row's state + its group: { on, lv, group = "Music" | "SFX", attrOn, attrLv, keyOn, keyLv }
type Channel = { on: boolean, lv: number, group: string, attrOn: string, attrLv: string, keyOn: string, keyLv: string, show: () -> () }
local channels: { Channel } = {
	{ on = true, lv = DEFAULT_LV, group = "Music", attrOn = "MusicOn", attrLv = "MusicLv", keyOn = "musicOn", keyLv = "musicLv", show = function() end },
	{ on = true, lv = DEFAULT_LV, group = "SFX", attrOn = "SfxOn", attrLv = "SfxLv", keyOn = "sfxOn", keyLv = "sfxLv", show = function() end },
}
local localUntil = 0 -- (just tapped: the saved attributes catch up a moment later — don't jump back meanwhile)

local function apply()
	for _, ch in channels do
		for _, g in SoundService:GetChildren() do
			if g:IsA("SoundGroup") and g.Name == ch.group then
				g.Volume = if ch.on then LEVEL[ch.lv] or 1 else 0
			end
		end
	end
end

local function readSaved()
	if os.clock() < localUntil then
		return
	end
	for _, ch in channels do
		local on = player:GetAttribute(ch.attrOn)
		local lv = player:GetAttribute(ch.attrLv)
		ch.on = if type(on) == "boolean" then on else true
		ch.lv = if type(lv) == "number" and LEVEL[lv] then lv else DEFAULT_LV
		ch.show()
	end
	apply()
end

local function setChannel(ch: Channel, on: boolean, lv: number)
	ch.on, ch.lv = on, lv
	ch.show()
	apply()
	localUntil = os.clock() + 1.5
	Remotes.SetSound:FireServer({ [ch.keyOn] = on, [ch.keyLv] = lv })
	if ch.group == "SFX" and on then
		SoundPlayer.play("uiClick") -- (hear how loud it is now)
	end
	task.delay(1.6, readSaved)
end

local function showLang()
	for id, b in langButtons do
		UIKit.setButton(b, nil, if Localizer.lang == id then "Blue" else "Gray")
	end
end

function Settings.close()
	UIKit.close(frame)
end

local showName: () -> () = function() end

function Settings.open()
	showLang()
	showName()
	UIKit.open(frame)
end

-- one row: the setting's name on the left, its choices on the right
local function row(list: Instance, order: number, name: string, key: string): Frame
	local r = UIKit.row(list, { name = name })
	r.LayoutOrder = order
	UIKit.bind(r, function()
		r.Size = UDim2.new(0.97, 0, 0, UIKit.px(0.17, 58, 88))
	end)
	UIKit.text(r, {
		name = "Name",
		key = key,
		font = "Bold",
		color = C.Ink,
		outline = false,
		anchor = Vector2.new(0, 0.5),
		pos = UDim2.fromScale(0.035, 0.5),
		size = UDim2.fromScale(0.33, 0.46),
		alignX = Enum.TextXAlignment.Left,
		max = 28,
	})
	return r
end

-- a sound row: Off | Low | Normal | High, the one on in blue (the language row's look). Off keeps the level, so
-- the saved state is still on + level
local function soundRow(list: Instance, order: number, name: string, key: string, ch: Channel)
	local r = row(list, order, name, key)
	local buttons: { [number]: TextButton } = {}
	for i, choice in CHOICES do
		buttons[choice.lv] = UIKit.button(r, {
			name = if choice.lv == 0 then "Off" else "Lv" .. choice.lv,
			key = choice.key,
			style = "Gray",
			anchor = Vector2.new(0, 0.5),
			pos = UDim2.fromScale(0.37 + (i - 1) * 0.155, 0.5),
			size = UDim2.fromScale(0.145, 0.72),
			max = 22,
			onClick = function()
				if choice.lv == 0 then
					setChannel(ch, false, ch.lv)
				else
					setChannel(ch, true, choice.lv)
				end
			end,
		})
	end
	ch.show = function()
		-- (a saved 1 / 3 shows as the nearest word)
		local now = if not ch.on then 0 elseif ch.lv <= 2 then 2 elseif ch.lv <= 4 then 4 else 5
		for lv, b in buttons do
			UIKit.setButton(b, nil, if lv == now then "Blue" else "Gray")
		end
	end
	ch.show()
end

-- a square plate in the corner with the pack's picture (the word, wider, while there's no id)
local function cornerButton(gui: Instance, name: string, icon: string, key: string, onClick: () -> ()): (TextButton, boolean)
	local b = UIKit.plateButton(gui, { name = name, anchor = Vector2.new(1, 0), kit = "slot" }, onClick)
	local pic = UIKit.icon(b, icon, { size = UDim2.fromScale(0.7, 0.7) })
	if not pic then
		-- the word, a fixed size; the button is as wide as it (layout below, user 10-22: boxes fit the words)
		local l = UIKit.text(b, { name = "Label", key = key, font = "Title", size = UDim2.fromScale(1, 0.56) })
		l.TextScaled = false
	end
	return b, pic ~= nil
end

-- the corner button's width at height h: square with a picture, else its word + room each side
local function cornerWidth(b: TextButton, h: number, pictured: boolean): number
	local l = b:FindFirstChild("Label") :: TextLabel?
	if pictured or not l then
		return h
	end
	l.TextSize = math.floor(h * 0.42 + 0.5)
	return math.max(math.ceil(l.TextBounds.X / UIKit.zoom()) + 2 * math.floor(h * 0.34), h)
end

function Settings.start()
	local gui = HUD.gui()

	-- the buttons: the pack's gear (an emoji gear isn't safe on phones), Invite left of it
	local open, gear = cornerButton(gui, "SettingsButton", UIStyle.Icon.Settings, "ui.settings", function()
		if frame.Visible then
			Settings.close()
		else
			Settings.open()
		end
	end)
	local invite, face = cornerButton(gui, "InviteButton", UIStyle.Icon.Invite, "gate.invite", Gate.invite)
	invite.Visible = false
	local canInvite = false
	-- the Garage Shop button (Robux items): only while something is on sale, never in a work view or the first cars
	local shop, sface = cornerButton(gui, "ShopButton", (UIStyle.Icon :: any).Store or "", "store.button", StoreUI.open)
	shop.Visible = false
	local shopOn = false
	local function layout()
		local h = UIKit.px(0.11, 44, 52) -- a thumb's size on a phone
		local inset = UIKit.topInset()
		-- in the top bar row, a little smaller when the row is short (667 x 375: 44 px), else the corner under it
		-- (where it would sit under the job card)
		local inRow = inset - 4 >= 34
		if inRow then
			h = math.min(h, inset - 4)
		end
		local y = if inRow then -inset + math.floor((inset - h) / 2) else 8
		local w = cornerWidth(open, h, gear)
		open.Size = UDim2.fromOffset(w, h)
		open.Position = UDim2.new(1, -8, 0, y)
		local iw = cornerWidth(invite, h, face)
		invite.Size = UDim2.fromOffset(iw, h)
		invite.Position = UDim2.new(1, -8 - w - 6, 0, y)
		-- the Shop button sits left of Invite (its room stays kept while Invite steps out, so nothing jumps)
		local sw = cornerWidth(shop, h, sface)
		shop.Size = UDim2.fromOffset(sw, h)
		shop.Position = UDim2.new(1, -8 - w - 6 - (if canInvite then iw + 6 else 0), 0, y)
		-- the money bar keeps clear of all of them (HUD)
		gui:SetAttribute("CornerWidth", w + (if canInvite then iw + 6 else 0) + (if shopOn then sw + 6 else 0))
	end
	UIKit.bind(open, function()
		layout()
	end)
	-- (a language change makes the word longer / shorter)
	for _, b in { open, invite, shop } do
		local l = b:FindFirstChild("Label") :: TextLabel?
		if l then
			l:GetPropertyChangedSignal("TextBounds"):Connect(layout)
		end
	end
	-- (not inside a work view: the car has the screen — GPT workview_phone r1)
	-- (not during the first cars either: the first screen had 7 things on it — test 2 ⑩; its room stays kept)
	local function showInvite()
		local tut = player:GetAttribute("Tut") :: number?
		local learning = tut ~= nil and tut < 4 and not player:GetAttribute("TutSkip")
		invite.Visible = canInvite and not gui:GetAttribute("WorkView") and not learning and gui:GetAttribute("Minigame") ~= true
	end
	local function showShop()
		local tut = player:GetAttribute("Tut") :: number?
		local learning = tut ~= nil and tut < 4 and not player:GetAttribute("TutSkip")
		local on = StoreUI.anyOn()
		if on ~= shopOn then
			shopOn = on
			layout()
		end
		shop.Visible = on and not gui:GetAttribute("WorkView") and not learning and gui:GetAttribute("WindowOpen") ~= true and gui:GetAttribute("Minigame") ~= true
	end
	gui:GetAttributeChangedSignal("Minigame"):Connect(showInvite)
	gui:GetAttributeChangedSignal("Minigame"):Connect(showShop)
	gui:GetAttributeChangedSignal("WorkView"):Connect(showInvite)
	gui:GetAttributeChangedSignal("WorkView"):Connect(showShop)
	gui:GetAttributeChangedSignal("WindowOpen"):Connect(showShop)
	player:GetAttributeChangedSignal("Tut"):Connect(showShop)
	player:GetAttributeChangedSignal("TutSkip"):Connect(showShop)
	player:GetAttributeChangedSignal("StoreTest"):Connect(showShop)
	task.spawn(function()
		while true do
			showShop() -- (what is on sale can change: main's switch, Roblox's answer)
			task.wait(2)
		end
	end)
	player:GetAttributeChangedSignal("Tut"):Connect(showInvite)
	player:GetAttributeChangedSignal("TutSkip"):Connect(showInvite)
	task.spawn(function()
		canInvite = Gate.canInvite() -- (asks Roblox: some devices / young accounts can't send invites)
		layout()
		showInvite()
	end)

	local win = UIKit.window(gui, { name = "Settings", title = "ui.settings", maxSize = Vector2.new(620, 440), overHotbar = true, onClose = Settings.close })
	frame = win.root
	local list = UIKit.list(win.body, { pos = UDim2.fromScale(0.5, 0.03), size = UDim2.fromScale(0.96, 0.94) })

	local lang = row(list, 1, "Language", "ui.settings.language")
	for i, l in LANGS do
		langButtons[l.id] = UIKit.button(lang, {
			name = l.id,
			text = l.text,
			style = "Gray",
			anchor = Vector2.new(1, 0.5),
			pos = UDim2.fromScale(if i == 1 then 0.66 else 0.975, 0.5),
			size = UDim2.fromScale(0.29, 0.72),
			max = 24,
			onClick = function()
				if Localizer.lang ~= l.id then
					Localizer.setLang(l.id)
				end
				showLang()
			end,
		})
	end
	showLang()
	UIKit.onLang(showLang)

	-- music / sound effects (saved; the groups may come after this script starts — set them as they arrive)
	soundRow(list, 2, "Music", "ui.settings.music", channels[1])
	soundRow(list, 3, "SoundEffects", "ui.settings.sfx", channels[2])
	SoundService.ChildAdded:Connect(function(c)
		if c:IsA("SoundGroup") then
			apply()
		end
	end)
	for _, ch in channels do
		player:GetAttributeChangedSignal(ch.attrOn):Connect(readSaved)
		player:GetAttributeChangedSignal(ch.attrLv):Connect(readSaved)
	end
	readSaved()

	-- mini-games: Play | Auto, from Lv 8 and only while the feature is on (docs/design/minigames.md v0.3 §3: before Lv 8
	-- the row is not there at all, no locked teaser). Saved by the server (SetMinigames -> player attribute MgMode),
	-- which also keeps "which ones I keep playing by hand" (MgKeep, a comma list; main 10-22: no extra bar for it in Settings)
	local mgRow = row(list, 5, "Minigames", "ui.settings.minigames")
	local mgButtons: { [string]: TextButton } = {}
	for i, mode in { "play", "auto" } do
		mgButtons[mode] = UIKit.button(mgRow, {
			name = mode,
			key = if mode == "play" then "ui.settings.mgPlay" else "ui.settings.mgAuto",
			style = "Gray",
			anchor = Vector2.new(1, 0.5),
			pos = UDim2.fromScale(if i == 1 then 0.66 else 0.975, 0.5),
			size = UDim2.fromScale(0.29, 0.72),
			max = 24,
			onClick = function()
				Remotes.SetMinigames:FireServer({ mode = mode })
				player:SetAttribute("MgMode", mode) -- (Studio / right away; the server's saved value comes back the same)
			end,
		})
	end
	local mgNote = UIKit.text(list, { name = "MinigamesNote", key = "ui.settings.mgNote", color = C.Ink, outline = false, wrap = true, alignX = Enum.TextXAlignment.Left, max = 15 })
	mgNote.LayoutOrder = 6
	mgNote.AnchorPoint = Vector2.new(0, 0)
	UIKit.bind(mgNote, function()
		mgNote.Size = UDim2.new(0.94, 0, 0, UIKit.px(0.1, 30, 40))
	end)
	-- the way back from "Keep doing this one myself" (the result chip): shown only while some are kept, under the note —
	-- "Still by hand: 2 · tap to put them back on Auto" (GPT mgkeep: a second tap on a blue Auto clearing them unseen
	-- would surprise; the server's clearKeep was there with nothing calling it)
	local mgKept = UIKit.button(list, { name = "MinigamesKept", key = "ui.settings.mgKept", args = { n = 0 }, style = "Gray", max = 16, onClick = function()
		Remotes.SetMinigames:FireServer({ clearKeep = true })
		player:SetAttribute("MgKeep", nil) -- (Studio / right away; the server's saved value comes back the same)
	end })
	mgKept.LayoutOrder = 7
	UIKit.bind(mgKept, function()
		mgKept.Size = UDim2.new(0.94, 0, 0, UIKit.px(0.09, 30, 40))
	end)
	local function showMinigames()
		local level = (player:GetAttribute("Level") :: number?) or 1
		local on = Config.feature("Minigames") and level >= 8
		mgRow.Visible, mgNote.Visible = on, on
		local kept = (player:GetAttribute("MgKeep") :: string?) or ""
		local n = if kept == "" then 0 else #string.split(kept, ",")
		mgKept.Visible = on and n > 0
		local label = mgKept:FindFirstChildWhichIsA("TextLabel", true)
		if label then
			UIKit.setText(label, "ui.settings.mgKept", { n = n })
		end
		local mode = (player:GetAttribute("MgMode") :: string?) or "play"
		for m, b in mgButtons do
			UIKit.setButton(b, nil, if m == mode then "Blue" else "Gray")
		end
	end
	for _, a in { "Level", "MgMode", "MgKeep" } do
		player:GetAttributeChangedSignal(a):Connect(showMinigames)
	end
	UIKit.onLang(showMinigames)
	showMinigames()

	-- garage name: the name in the middle (on the sign's dark plate, as it reads outside), the button on the right
	local nameRow = row(list, 4, "GarageName", "ui.settings.garageName")
	local sign = UIKit.plate(nameRow, {
		name = "Sign",
		anchor = Vector2.new(0, 0.5),
		pos = UDim2.fromScale(0.37, 0.5),
		size = UDim2.fromScale(0.29, 0.72),
		kit = "slotWide",
	})
	local signText = UIKit.text(sign, { name = "Text", font = "Title", size = UDim2.fromScale(0.88, 0.6), max = 24 })
	local rename = UIKit.button(nameRow, {
		name = "Rename",
		key = "ui.settings.nameIt",
		style = "Blue",
		anchor = Vector2.new(1, 0.5),
		pos = UDim2.fromScale(0.975, 0.5),
		size = UDim2.fromScale(0.29, 0.72),
		max = 24,
		onClick = function()
			Settings.close()
			NameWindow.open()
		end,
	})

	showName = function()
		local name = workspace:GetAttribute("GarageName") :: string?
		-- (no name yet: what the sign outside says)
		signText.Text = if name and name ~= "" then name else "Wrench & Ride"
		local owner = workspace:GetAttribute("GarageOwner") == player.UserId
		local level = (player:GetAttribute("Level") :: number?) or 1
		-- a friend's garage: just its name; the owner below Lv3: locked; else name it (free once) / change it
		rename.Visible = owner
		if level < NAME_LEVEL then
			UIKit.setLocked(rename, "ui.settings.nameLock", { level = NAME_LEVEL }) -- (the shared "can't yet" look)
		else
			UIKit.setButton(rename, nil, "Blue")
			local label = rename:FindFirstChild("Label", true) :: TextLabel?
			if label then
				UIKit.setText(label, if name and name ~= "" then "ui.settings.rename" else "ui.settings.nameIt")
			end
		end
	end
	showName()
	for _, a in { "GarageName", "GarageOwner" } do
		workspace:GetAttributeChangedSignal(a):Connect(showName)
	end
	player:GetAttributeChangedSignal("Level"):Connect(showName)
end

return Settings
