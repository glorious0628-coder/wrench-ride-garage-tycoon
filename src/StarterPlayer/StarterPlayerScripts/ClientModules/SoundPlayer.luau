-- Plays a sound from Shared/Sounds by name, at a point in the world or flat (UI). Empty ids are skipped (returns
-- false, so the caller can show text instead). Every one plays in SoundService.SFX (Settings' "Sound effects" row);
-- a duck = true one tells the music to dip (onBig).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Sounds = require(ReplicatedStorage.Shared.Sounds)

local SoundPlayer = {}

SoundPlayer.onBig = nil :: (() -> ())? -- set by Music: a big moment just played (the music dips under it)

-- the work sounds get a slightly different pitch every time (+-4 %), never the same value twice in a row for one
-- sound — a bolt that clicks exactly the same 20 times in a row sounds like a machine (wr-dev's idea, 10-22). Not the
-- loops, the music, the long sounds or the big moments.
local VARY = {
	wrench = true, wrenchTighten = true, ratchet = true, impact = true, clank = true, install = true,
	partDrop = true, boltPop = true, hammerTap = true, tick = true,
}
local lastSpeed: { [string]: number } = {}

local function speedFor(name: string): number
	local v = 1
	for _ = 1, 4 do
		v = math.floor((1 + (math.random() - 0.5) * 0.08) * 1000 + 0.5) / 1000
		if v ~= lastSpeed[name] then
			break
		end
	end
	lastSpeed[name] = v
	return v
end

local function sfx(s: Sound, def: { duck: boolean? })
	s.SoundGroup = SoundService:FindFirstChild("SFX") :: SoundGroup?
	if def.duck and SoundPlayer.onBig then
		SoundPlayer.onBig()
	end
end

-- a sound at a point (or flat, at = nil) until stop(fade?) — the lift motor, the night crickets, the coach's sparkle
-- trail; it loops when its entry says loop. nil when the sound has no id yet
function SoundPlayer.loop(name: string, at: Vector3?): { stop: (fade: number?) -> () }?
	local def = Sounds[name]
	if not def or def.id == "" then
		return nil
	end
	local holder: Instance
	if at then
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.Transparency = 1
		p.Size = Vector3.one * 0.2
		p.Position = at
		p.Parent = workspace.CurrentCamera
		holder = p
	else
		holder = Instance.new("Folder")
		holder.Parent = SoundService
	end
	local s = Instance.new("Sound")
	s.SoundId = def.id
	s.Volume = def.volume
	s.Looped = def.loop == true
	s.RollOffMaxDistance = 60
	sfx(s, def)
	s.Parent = holder
	s.Ended:Once(function()
		holder:Destroy()
	end)
	s:Play()
	return {
		stop = function(fade: number?)
			if fade and fade > 0 and holder.Parent then
				TweenService:Create(s, TweenInfo.new(fade), { Volume = 0 }):Play()
				task.delay(fade, function()
					holder:Destroy()
				end)
			else
				holder:Destroy()
			end
		end,
	}
end

function SoundPlayer.play(name: string?, at: Vector3?): boolean
	local def = name and Sounds[name]
	if not def or def.id == "" then
		return false
	end
	local s = Instance.new("Sound")
	s.SoundId = def.id
	s.Volume = def.volume
	if VARY[name :: string] and not def.loop then
		s.PlaybackSpeed = speedFor(name :: string)
	end
	sfx(s, def)
	if at then
		local holder = Instance.new("Part")
		holder.Anchored = true
		holder.CanCollide = false
		holder.CanQuery = false
		holder.Transparency = 1
		holder.Size = Vector3.one * 0.2
		holder.Position = at
		holder.Parent = workspace.CurrentCamera
		s.RollOffMaxDistance = 80
		s.Parent = holder
		s.Ended:Once(function()
			holder:Destroy()
		end)
		task.delay(15, function()
			holder:Destroy()
		end)
		s:Play()
	else
		s.Parent = SoundService
		SoundService:PlayLocalSound(s)
		task.delay(10, function()
			s:Destroy()
		end)
	end
	return true
end

-- the same sound twice, `gap` seconds apart (hammerTap: tink-tink — 0.12 s)
function SoundPlayer.playTwice(name: string, at: Vector3?, gap: number?): boolean
	if not SoundPlayer.play(name, at) then
		return false
	end
	task.delay(gap or 0.12, function()
		SoundPlayer.play(name, at)
	end)
	return true
end

return SoundPlayer
