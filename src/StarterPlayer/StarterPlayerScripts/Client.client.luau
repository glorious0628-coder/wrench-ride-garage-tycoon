-- Wrench & Ride Garage Tycoon: client entry point. Input and drawing only; the server decides.

local Players = game:GetService("Players")

local Modules = script.Parent:WaitForChild("ClientModules")
local Localizer = require(Modules.Localizer)
local HUD = require(Modules.HUD)
local UIKit = require(Modules.UIKit)
local Inspect = require(Modules.Inspect)
local Wrench = require(Modules.Wrench)
local Carry = require(Modules.Carry)
local Shop = require(Modules.Shop)
local Effects = require(Modules.Effects)
local JobCard = require(Modules.JobCard)
local EquipShop = require(Modules.EquipShop)
local Balance = require(Modules.Balance)
local Fill = require(Modules.Fill)
local Scrub = require(Modules.Scrub)
local Listen = require(Modules.Listen)
local Appraisal = require(Modules.Appraisal)
local CarLook = require(Modules.CarLook)
local RestoreCard = require(Modules.RestoreCard)
local Dealer = require(Modules.Dealer)
local Haggle = require(Modules.Haggle)
local Tutorial = require(Modules.Tutorial)
local PromptFocus = require(Modules.PromptFocus)
local Hotbar = require(Modules.Hotbar)
local Settings = require(Modules.Settings)
local Receipt = require(Modules.Receipt)
local WorkViewUI = require(Modules.WorkViewUI)
local FarewellCam = require(Modules.FarewellCam)
local GuideButton = require(Modules.GuideButton)
local GuideGlow = require(Modules.GuideGlow)
local StoreUI = require(Modules.StoreUI)
local WorkView = require(Modules.WorkView)
local PromptUI = require(Modules.PromptUI)
local Gate = require(Modules.Gate)
local NameWindow = require(Modules.NameWindow)
local Halloween = require(Modules.Halloween)
local Cinema = require(Modules.Cinema)
local Music = require(Modules.Music)
local CurbUI = require(Modules.CurbUI)
local BlobShadow = require(Modules.BlobShadow)
local BoltLook = require(Modules.BoltLook)
local CameraGuard = require(Modules.CameraGuard)
local Guide = require(Modules.Guide)
local MechAnim = require(Modules.MechAnim)
local Coffee = require(Modules.Coffee)
local OilUI = require(Modules.OilUI)
local WorkLight = require(Modules.WorkLight)

local player = Players.LocalPlayer

Localizer.start()
Music.start() -- the background music: the garage's day songs, Ella's night (music_list.md)
HUD.start()
Inspect.start()
Wrench.start()
Carry.start()
Shop.start()
Effects.start()
JobCard.start()
EquipShop.start()
Balance.start()
Fill.start()
Scrub.start() -- the Terminal Scrub screen + Auto (server-driven, Config.Features.Minigames)
Listen.start()
Appraisal.start()
CarLook.start()
RestoreCard.start()
Dealer.start()
Haggle.start()
Tutorial.start()
PromptFocus.target = function()
	return Tutorial.target or Guide.focus() -- (after the tutorial: the guide line's step, rival_upgrade B2-2)
end
PromptFocus.held = Carry.held
Wrench.preferred = function()
	return Tutorial.target
end
PromptFocus.start()
Hotbar.start()
Settings.start()
StoreUI.start() -- the Garage Shop window (Robux items; opens only when asked: HUD Shop button, counter link, tools-shop hint)
Receipt.start()
FarewellCam.start() -- (the car leaving the bay, seen from beside it, while the settlement card is up)
WorkViewUI.start()
PromptUI.start() -- (every prompt drawn as our card: one plate, a key badge, one line)
-- (local prompts too — the install spots, the tutorial's drop spot: one prompt on screen at a time)
workspace.DescendantAdded:Connect(function(d)
	if d:IsA("ProximityPrompt") then
		d.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	end
end)
WorkView.start() -- the work view: camera + taps over the engine bay / a wheel (WorkService decides the zone)
Halloween.start() -- Ella's camera scenes, the midnight clock, the pop (HalloweenService runs the story)
NameWindow.start() -- name the garage (Lv3+, free once): NameService checks and saves
Gate.start() -- "taking you to your garage" + the one card (failed / owner left / invite) — GateService decides
Cinema.start() -- the screen around Ella's camera scenes (black bars, subtitle, tap to skip) — wr-dev drives it
CurbUI.start() -- quick jobs at the curb: the small card, someone else's tag, the wiper camera, the line's "…" (wr-ui)
BlobShadow.start() -- a soft round shadow under people indoors (the roof blocks the sun's)
MechAnim.start() -- the mechanic's body moves at work (wr-anim; nothing plays while Config.Features.MechAnim is off)
Coffee.start() -- coffee for the waiting customers: which coffee prompts show on my screen (Features.Coffee)
OilUI.start() -- the oil change: the next step, the oil bar, the pour button (Features.OilChange; server OilService)
BoltLook.start() -- hex bolt heads that turn out / in (rival_upgrade A③)
CameraGuard.start()
WorkLight.start() -- a soft fill light in the engine-bay / under-car work views (wr-play: near-black) -- the camera stays out of the cars' bodies (test 3 ③-6)

Wrench.blocked = function()
	return Carry.held() ~= nil
end
Hotbar.dimmed = function()
	local held = Carry.held()
	return held ~= nil and held:GetAttribute("CarryMode") ~= "OneHand"
end

local toolName: string? = nil

-- which tool is in hand drives the mode (Scanner = inspect, Wrench / ImpactWrench = bolts)
local function onCharacter(char: Model)
	local function check()
		local tool = char:FindFirstChildOfClass("Tool")
		toolName = tool and tool.Name
		Inspect.setActive(toolName == "Scanner")
		Wrench.setTool(toolName)
		Listen.setActive(toolName == "Stethoscope")
	end
	char.ChildAdded:Connect(check)
	char.ChildRemoved:Connect(check)
	check()
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then
	onCharacter(player.Character)
end

-- one hint line at the bottom: carrying > tool in hand. A tool's line shows for a few seconds after you pick it up, and
-- all the time inside a work view (where it's what you do) — walking about with the wrench it sat there saying "press
-- a bolt" while the job wanted the brake pedal (test 2 ⑩ #8)
local TOOL_HINT_FOR = 5
task.spawn(function()
	local last = ""
	local lastTool: string? = nil
	local toolSince = 0
	while true do
		task.wait(0.2)
		if toolName ~= lastTool then
			lastTool, toolSince = toolName, os.clock()
		end
		local held = Carry.held()
		local key, args = nil, nil
		if held then
			local kind = "@part." .. tostring(held:GetAttribute("PartKind"))
			key = if held:GetAttribute("CarryMode") == "OneHand" then "hud.carryHint" else "hud.carryHeavy"
			if not UIKit.keyboard() then
				key ..= ".touch" -- (no G key on a phone: the Drop button is there)
			end
			args = { part = kind }
		elseif toolName == "Scanner" then
			key = "hud.inspect"
		elseif toolName == "Wrench" or toolName == "ImpactWrench" or toolName == "RatchetWrench" or toolName == "Stethoscope" then
			key = "hud.toolHint." .. toolName
		end
		-- the guide line (the next step, key word yellow): when there is one, a tool's line gives way to it after 5 s,
		-- also inside a work view; with no guide the tool's line stays there as before
		local guideKey, guideArgs, guideInfo = JobCard.guide()
		if key and not held and os.clock() - toolSince > TOOL_HINT_FOR and (guideKey or not HUD.gui():GetAttribute("WorkView")) then
			key = nil
		end
		if not key and not held and guideKey then
			key, args = guideKey, guideArgs
		end
		-- (the guide line's one button — "Order ($90)" — only while that line is what is showing)
		local showingGuide = key ~= nil and key == guideKey
		GuideButton.set(if showingGuide and guideInfo then guideInfo.order else nil, if guideArgs then guideArgs.money else nil)
		GuideGlow.set(guideInfo) -- (the guide's one part lit yellow, its next bolt brighter)
		local sig = tostring(key) .. tostring(args and args.part)
		if sig ~= last then
			last = sig
			HUD.hint(key, args)
		end
	end
end)
