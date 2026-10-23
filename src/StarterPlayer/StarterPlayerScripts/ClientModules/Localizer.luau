-- This player's language (English source, Korean from Shared/LocaleKo) and everything tagged with Locale.tag
-- (Loc_<Field> attributes: the server's prompts / signs and client UI made with Localizer.bind) kept in it.
--   Localizer.t(key, args)        -> text in the current language (a missing Korean key shows the English)
--   Localizer.bind(inst, key, args?, field?)  -> a client label / button / prompt that follows language changes
--   Localizer.setLang("en"|"ko")  -> switch now; the choice is saved with the player (Remotes.SetLang)
--   Localizer.Changed.Event       -> (lang) fired after a switch: screens that build text themselves redraw
-- First language: the saved choice (player attribute Lang), else the Roblox LocaleId (ko-kr -> ko, others en).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Locale = require(ReplicatedStorage.Shared.Locale)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Localizer = {}

local player = Players.LocalPlayer
Localizer.lang = (player:GetAttribute("Lang") :: string?) or Locale.langOf(player.LocaleId)
Localizer.Changed = Instance.new("BindableEvent")

local FIELDS = { "Text", "ActionText", "ObjectText" }
local watched: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local function apply(inst: Instance)
	for _, f in FIELDS do
		local key = inst:GetAttribute("Loc_" .. f)
		if type(key) == "string" then
			local args = Locale.decodeArgs(inst:GetAttribute("LocArgs_" .. f) :: string?)
			pcall(function()
				(inst :: any)[f] = Locale.format(Localizer.lang, key, args)
			end)
		end
	end
end

local function watch(inst: Instance)
	if watched[inst] or not (inst:IsA("ProximityPrompt") or inst:IsA("TextLabel") or inst:IsA("TextButton")) then
		return
	end
	watched[inst] = true
	apply(inst)
	inst.AttributeChanged:Connect(function(name)
		if name:sub(1, 4) == "Loc_" or name:sub(1, 8) == "LocArgs_" then
			apply(inst)
		end
	end)
	-- a server prompt's English text can land after its key (same key re-tagged, replication order): back to ours
	-- (prompts only: client labels may set their own text over a key on purpose)
	for _, f in (if inst:IsA("ProximityPrompt") then { "ActionText" } else {}) do
		local ok, signal = pcall(inst.GetPropertyChangedSignal, inst, f)
		if ok then
			signal:Connect(function()
				local key = inst:GetAttribute("Loc_" .. f)
				if type(key) == "string" then
					local want = Locale.format(Localizer.lang, key, Locale.decodeArgs(inst:GetAttribute("LocArgs_" .. f) :: string?))
					if (inst :: any)[f] ~= want then
						(inst :: any)[f] = want
					end
				end
			end)
		end
	end
end

function Localizer.t(key: string, args: { [string]: any }?): string
	return Locale.format(Localizer.lang, key, args)
end

function Localizer.bind(inst: Instance, key: string, args: { [string]: any }?, field: string?)
	Locale.tag(inst, key, args, field)
	watched[inst] = nil
	watch(inst)
end

function Localizer.setLang(lang: string, fromServer: boolean?)
	if (lang ~= "en" and lang ~= "ko") or lang == Localizer.lang then
		return
	end
	Localizer.lang = lang
	for inst in watched do
		if inst.Parent then
			apply(inst)
		end
	end
	Localizer.Changed:Fire(lang)
	if not fromServer then
		Remotes.SetLang:FireServer(lang)
	end
end

function Localizer.start()
	for _, root in { workspace :: Instance, player:WaitForChild("PlayerGui") } do
		root.DescendantAdded:Connect(watch)
		for _, d in root:GetDescendants() do
			watch(d)
		end
	end
	-- the saved choice arrives with the save (after this script starts)
	player:GetAttributeChangedSignal("Lang"):Connect(function()
		local saved = player:GetAttribute("Lang") :: string?
		if saved then
			Localizer.setLang(saved, true)
		end
	end)
	local saved = player:GetAttribute("Lang") :: string?
	if saved then
		Localizer.setLang(saved, true)
	end
end

return Localizer
