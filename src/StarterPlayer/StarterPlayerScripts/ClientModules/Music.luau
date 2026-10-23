-- Background music (docs/design/music_list.md v0.2, wr-sound). By day: garageDayA first, then A <-> B by turns (each
-- 2-3 times round, a 1.5 s fade out, 4-8 s of quiet, a 1.5 s fade in). Ella's Halloween night (HalloweenService's
-- workspace "EllaNight"): "dusk" = halloweenNight crossfades in (1.5 s) from "Closing soon", "midnight" = cut in 0.5 s
-- as the midnight scene starts (the twelve bells stand alone), nil = morning: the day song again (2 s in).
-- Flat and looped in SoundService.Music. Settings (wr-ui) owns that group's volume; here only each song's own Volume
-- moves = its fade x the dims (Music.dim: the tutorial 0.75 -> 0.15, Ella's arrive / leave scenes 0.5 -> 0.1) x the
-- dip under a big moment (Music.duck: 30 % in 0.3 s, back in 1 s — the Sounds entries marked duck do it themselves).
-- Empty ids = silence (the songs go in after main's 2nd review).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Sounds = require(ReplicatedStorage.Shared.Sounds)
local SoundPlayer = require(script.Parent.SoundPlayer)

local Music = {}

local DAY = { "garageDayA", "garageDayB" }
local NIGHT = "halloweenNight"
local DUCK, DUCK_DOWN, DUCK_HOLD, DUCK_UP = 0.3, 0.3, 1.2, 1
local DIM_TIME = 0.5 -- (a dim comes and goes over half a second)

type Song = { s: Sound, base: number, fade: number, to: number, speed: number }

local player = Players.LocalPlayer
local songs: { Song } = {}
local mood: string? = nil -- "day" | "night" | "off"
local token = 0 -- the day rotation running (a mood change ends it)
local dims: { [string]: number } = {}
local dimNow, duckNow, duckUntil = 1, 1, 0

local function approach(a: number, b: number, d: number): number
	return if a < b then math.min(b, a + d) else math.max(b, a - d)
end

local function hasId(name: string): boolean
	local def = Sounds[name]
	return def ~= nil and def.id ~= ""
end

-- a song fading in from silence over `fade` s; nil while it has no id
local function start(name: string, fade: number): Song?
	if not hasId(name) then
		return nil
	end
	local def = Sounds[name]
	local group = SoundService:FindFirstChild("Music") :: SoundGroup?
	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = def.id
	s.Looped = true
	s.Volume = 0
	s.SoundGroup = group
	s.Parent = group or SoundService
	s:Play()
	local song = { s = s, base = def.volume, fade = 0, to = 1, speed = 1 / math.max(fade, 0.01) }
	table.insert(songs, song)
	return song
end

local function fadeOut(song: Song, t: number)
	song.to = 0
	song.speed = math.max(song.speed, 1 / math.max(t, 0.01)) -- (one already going out never slows down)
end

-- by day: A, then B, then A ... each 2-3 times round
local function dayLoop(my: number, fadeIn: number)
	local i = 1
	while token == my do
		local song = start(DAY[i], fadeIn)
		if song then
			local loops, n = math.random(2, 3), 0
			local c = song.s.DidLoop:Connect(function()
				n += 1
			end)
			while token == my and n < loops do
				task.wait(0.25)
			end
			c:Disconnect()
			if token ~= my then
				return -- (the new mood fades it out)
			end
			fadeOut(song, 1.5) -- (at the loop seam: the song's own bar line)
			task.wait(1.5 + math.random(4, 8))
		elseif not hasId(DAY[i % #DAY + 1]) then
			return -- (no day songs yet)
		end
		i = i % #DAY + 1
		fadeIn = 1.5
	end
end

-- "day" | "night" | "off": what plays now; the songs playing fade out (0.5 s for "off", else 1.5 s) as the new one
-- fades in over fadeIn (default 1.5 s)
function Music.mood(m: string, fadeIn: number?)
	if m == mood then
		return
	end
	mood = m
	token += 1
	for _, song in songs do
		fadeOut(song, if m == "off" then 0.5 else 1.5)
	end
	if m == "day" then
		task.spawn(dayLoop, token, fadeIn or 1.5)
	elseif m == "night" then
		start(NIGHT, fadeIn or 1.5)
	end
end

-- a named scale under the music (why = "tutorial" / "scene" ...); k = nil takes it away
function Music.dim(why: string, k: number?)
	dims[why] = k
end

-- a big moment (the car starts after a fix, the pay card, a level up): the music dips to 30 % for a moment
function Music.duck(hold: number?)
	duckUntil = math.max(duckUntil, os.clock() + DUCK_DOWN + (hold or DUCK_HOLD))
end

local function step(dt: number)
	local want = 1
	for _, k in dims do
		want *= k
	end
	dimNow = approach(dimNow, want, dt / DIM_TIME)
	local duckWant = if os.clock() < duckUntil then DUCK else 1
	duckNow = approach(duckNow, duckWant, dt * (1 - DUCK) / (if duckWant < duckNow then DUCK_DOWN else DUCK_UP))
	for i = #songs, 1, -1 do
		local song = songs[i]
		song.fade = approach(song.fade, song.to, dt * song.speed)
		if song.to == 0 and song.fade <= 0 then
			song.s:Destroy()
			table.remove(songs, i)
		else
			song.s.Volume = song.base * song.fade * dimNow * duckNow
		end
	end
end

function Music.start()
	SoundPlayer.onBig = function()
		Music.duck()
	end
	RunService.Heartbeat:Connect(step)
	-- the tutorial: a little quieter while the task lines are up (they're being read)
	local function tutorial()
		local stage = (player:GetAttribute("Tut") :: number?) or 4
		Music.dim("tutorial", if stage < 4 and not player:GetAttribute("TutSkip") then 0.75 else nil)
	end
	player:GetAttributeChangedSignal("Tut"):Connect(tutorial)
	player:GetAttributeChangedSignal("TutSkip"):Connect(tutorial)
	tutorial()
	-- Ella's night (HalloweenService)
	local first = true
	local function night()
		local n = workspace:GetAttribute("EllaNight")
		if n == "dusk" then
			Music.mood("night", if first then 2 else 1.5)
		elseif n == "midnight" then
			Music.mood("off")
		else
			Music.mood("day", 2)
		end
		first = false
	end
	workspace:GetAttributeChangedSignal("EllaNight"):Connect(night)
	night()
end

return Music
