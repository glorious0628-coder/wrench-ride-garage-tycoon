-- The garage's name (docs/design/name_filter.md, monetization.md §1b): the owner names it on the sign from Lv3,
-- free the first time (used up only when a name is saved), after that with the Garage Rename pass. Two filters:
-- Roblox's (FilterStringAsync -> broadcast string, any "#" = no) and ours (Data/NameBlocklist after normalize()).
-- The saved name is filtered again every time it's shown. Until it's named, the sign keeps the map's own words.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local GateService = require(script.Parent.GateService)
local Passes = require(script.Parent.Passes)
local Blocklist = require(script.Parent.Parent.Data.NameBlocklist)
local Guard = require(script.Parent.Guard)

local NameService = {}

local NAME_LEVEL = 3 -- naming opens with the fresh sign (Facade SignFresh = Level3 Owned)
local SIGNS = { SignFresh = false, SignBoard = false, NeonSign = true } -- sign part -> upper-case (the neon)
local LEET = { ["1"] = "i", ["0"] = "o", ["3"] = "e", ["4"] = "a", ["5"] = "s", ["7"] = "t", ["8"] = "b", ["$"] = "s", ["@"] = "a", ["!"] = "i" }
local lastTry: { [Player]: number } = {}

local function hangul(c: number): boolean
	return c >= 0xAC00 and c <= 0xD7A3
end
local function jamo(c: number): boolean
	return c >= 0x3131 and c <= 0x3163
end
local function latin(c: number): boolean
	return (c >= 97 and c <= 122) or (c >= 48 and c <= 57)
end

-- the same letter over and over -> once
local function squash(s: string): string
	local out, last = {}, nil
	for _, c in utf8.codes(s) do
		if c ~= last then
			table.insert(out, utf8.char(c))
		end
		last = c
	end
	return table.concat(out)
end

-- name_filter §3: lower case, leet -> letters, only latin / digits / Hangul left, latin stuck between Hangul out
local function normalize(raw: string): string
	local s = string.lower(raw):gsub("[0134578%$@!]", function(ch)
		return LEET[ch] or ch
	end)
	local cs = {}
	for _, c in utf8.codes(s) do
		if latin(c) or hangul(c) or jamo(c) then
			table.insert(cs, c)
		end
	end
	local kept = {}
	for i, c in cs do
		if latin(c) then
			-- (inside a Hangul word: 시1발 -> 시발)
			local before, after = false, false
			for j = i - 1, 1, -1 do
				if not latin(cs[j]) then
					before = hangul(cs[j])
					break
				end
			end
			for j = i + 1, #cs do
				if not latin(cs[j]) then
					after = hangul(cs[j])
					break
				end
			end
			if before and after then
				continue
			end
		end
		table.insert(kept, utf8.char(c))
	end
	return table.concat(kept)
end

local function blocked(raw: string): boolean
	local plain = normalize(raw)
	for _, a in Blocklist.allow do
		plain = plain:gsub(a, "")
	end
	local short = squash(plain)
	for _, w in Blocklist.substring do
		if string.find(plain, w, 1, true) or string.find(short, w, 1, true) then
			return true
		end
	end
	for token in string.lower(raw):gmatch("[%w%$@!]+") do
		local t = squash(normalize(token))
		for _, w in Blocklist.word do
			if t == squash(w) then
				return true
			end
		end
	end
	local typed = {}
	for _, c in utf8.codes(raw) do
		if jamo(c) then
			table.insert(typed, utf8.char(c))
		end
	end
	local js = table.concat(typed)
	for _, w in Blocklist.jamo do
		if string.find(js, w, 1, true) then
			return true
		end
	end
	return false
end

-- name_filter §4: the shape (says why, so a kid can fix it); returns the tidied name or nil + the reason key
local function shape(text: string): (string?, string?)
	local s = text:gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
	local n = utf8.len(s)
	if not n or n < 3 or n > 20 then
		return nil, "name.length"
	end
	for _, c in utf8.codes(s) do
		local ch = utf8.char(c)
		if not (hangul(c) or ch:match("^[%a%d ' %-&%.!]$")) then
			return nil, "name.chars"
		end
	end
	local low = string.lower(s)
	local digits = select(2, low:gsub("%d", ""))
	if digits >= 7 or (low:find("@", 1, true) and low:find(".", 1, true)) or low:find("http", 1, true)
		or low:find("www", 1, true) or low:find("%.com") or low:find("%.net") or low:find("%.kr") then
		return nil, "name.private"
	end
	return s, nil
end

-- Roblox's filter for something everyone sees after the author leaves; nil = it failed (try again), "" = blocked
local function robloxFilter(text: string, userId: number): string?
	local ok, res = pcall(function()
		return TextService:FilterStringAsync(text, userId):GetNonChatStringForBroadcastAsync()
	end)
	if not ok then
		return nil
	end
	return if string.find(res, "#", 1, true) then "" else res
end

-- the sign shows the owner's (filtered again) name, or the map's own words while there's none
local function applySign()
	local owner = PlayerData.owner()
	local d = owner and PlayerData.get(owner)
	local shown: string? = nil
	if owner and d and d.garageName then
		local f = robloxFilter(d.garageName, owner.UserId)
		if f and f ~= "" and not blocked(f) then
			shown = f
		end
	end
	workspace:SetAttribute("GarageName", shown)
	local garage = workspace:FindFirstChild("Garage")
	for _, d2 in (if garage then garage:GetDescendants() else {}) do
		local upper = SIGNS[d2.Name]
		local label = upper ~= nil and d2:IsA("BasePart") and d2:FindFirstChild("Label")
		local t = label and label:FindFirstChildOfClass("TextLabel")
		if t then
			if t:GetAttribute("BrandText") == nil then
				t:SetAttribute("BrandText", t.Text)
			end
			t.Text = if shown then (if upper then string.upper(shown) else shown) else t:GetAttribute("BrandText")
		end
	end
end
NameService.applySign = applySign

-- may this player name the garage now: (ok, why-not key)
function NameService.canName(player: Player): (boolean, string?)
	local d = PlayerData.get(player)
	if not d or PlayerData.owner() ~= player or GateService.ownerId ~= player.UserId then
		return false, "name.ownerOnly"
	end
	if PlayerData.levelFor(d.rep) < NAME_LEVEL then
		return false, "name.level"
	end
	if d.nameFreeUsed and not Passes.owns(player, "GarageRename") then
		return false, "rename.need"
	end
	return true, nil
end

-- check + save a new name: (ok, key, args)
function NameService.setName(player: Player, text: any): (boolean, string?, { [string]: any }?)
	if type(text) ~= "string" or #text > 200 then
		return false, "name.chars", nil
	end
	local can, why = NameService.canName(player)
	if not can then
		return false, why, nil
	end
	local name, bad = shape(text)
	if not name then
		return false, bad, nil
	end
	-- (Roblox's filter at most once in 5 s each; a shape mistake is free to fix right away)
	local now = os.clock()
	if lastTry[player] and now - lastTry[player] < 5 then
		return false, "name.retry", nil
	end
	lastTry[player] = now
	local f = robloxFilter(name, player.UserId)
	if f == nil then
		return false, "name.retry", nil
	end
	if f == "" or blocked(name) then
		return false, "name.blocked", nil
	end
	local d = PlayerData.get(player) :: any
	d.garageName = name
	d.nameFreeUsed = true -- (only now: a blocked try costs nothing)
	PlayerData.refresh(player)
	applySign()
	Remotes.Notify:FireAllClients("name.done", { name = f }, "good")
	return true, "name.done", { name = f }
end

NameService._blocked = blocked -- (play tests)
NameService._shape = shape

function NameService.start()
	Remotes.NameGarage.OnServerInvoke = Guard.wrap("NameGarage", 0, NameService.setName) -- (its own 5 s pace)
	PlayerData.ownerChanged.Event:Connect(applySign)
	PlayerData.joined.Event:Connect(function(player)
		if PlayerData.owner() == player then
			applySign()
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		lastTry[player] = nil
	end)
	-- a level-up swaps the facade (Shed -> brick -> enamel): the new era's sign gets the name too
	local garage = workspace:WaitForChild("Garage")
	local queued = false
	garage.DescendantAdded:Connect(function(d)
		if SIGNS[d.Name] ~= nil and not queued then
			queued = true
			task.delay(0.5, function()
				queued = false
				applySign()
			end)
		end
	end)
end

return NameService
