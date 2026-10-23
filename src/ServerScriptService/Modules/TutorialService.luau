-- The first 15 minutes (docs/design/tutorial_script.md v0.2 + work_view.md v0.4 5 = v0.3) — the server half. The client half
-- (ClientModules/Tutorial) reads the car's state and draws the task line, arrows and highlights.
-- Progress per player (saved): Tut 1 = first job (Rosa, dead battery) / 2 = second (Tyler, worn front-left pads) /
-- 3 = third car ("What could it be?") / 4 = done. TutSkip = arrows and task lines off (rewards stay).
--   * The next customer while someone is on stage 1 / 2 / 3 is the scripted one (car attribute Tutorial = stage);
--     stage 3 = the small whodunit (script 4): a flat front-left tire, suspects "Brakes?" / "Tire?".
--   * v0.2 (first touch within 60 s, the start changes within 180 s): opening the first car's hood puts the
--     Scanner in the stage-1 players' hands; the battery can be ordered from the task strip and lands on the floor
--     by the bay (cartSpot) 2 s later; the first car takes the short way in (CustomerService).
--   * A player moves on when a tutorial car of their stage is handed back and they did a work unit on it (the
--     job's contribution rule) — someone who only watched gets the easy car again.
--   * Tutorial car 2: the first jack tap shows the whole order (JackService.demo), and one tighten does every bolt
--     of that part ("Hold to tighten all — just this once").

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local Guard = require(script.Parent.Guard)

local TutorialService = {}

local SCRIPT = {
	[1] = { kind = "Rosa", plan = { { slot = "Battery", variant = "BAT_DEAD" } } },
	[2] = { kind = "Tyler", plan = { { slot = "BrakePads_FL", variant = "PAD_WORN" } } },
	[3] = { kind = "Regular", plan = { { slot = "Wheel_FL", variant = "TIRE_FLAT" } }, say = "tut.say3" },
}

-- a car of that stage here (in a bay, or waiting in the lot: TutorialNext), but not `ignore`
local function carWith(stage: number, ignore: Model?): Model?
	local cars = workspace:FindFirstChild("Cars")
	for _, c in (if cars then cars:GetChildren() else {}) do
		if c ~= ignore and (c:GetAttribute("Tutorial") == stage or c:GetAttribute("TutorialNext") == stage) then
			return c :: Model
		end
	end
	return nil
end

-- the next customer, when the tutorial wants a particular one: { kind, plan?, stage }. ahead = for the one who waits
-- in the lot while a car is in the bay: one stage past the car that's here (it moves them on when handed back with
-- their work in it); { after = true } = that car ends the tutorial. ignore = a car not to count (the waiting one,
-- checked again as it goes in)
function TutorialService.pick(ahead: boolean?, ignore: Model?): { [string]: any }?
	local stage = math.huge
	for _, p in Players:GetPlayers() do
		local t = PlayerData.tut(p)
		if t and t < 4 then
			stage = math.min(stage, t)
		end
	end
	if stage == math.huge then
		return nil
	end
	if ahead and carWith(stage, ignore) then
		stage += 1
		if stage > 3 then
			return { after = true }
		end
	end
	if carWith(stage, ignore) then
		return nil -- nobody new, or their car is already here (a second bay gets an ordinary one)
	end
	local s = SCRIPT[stage]
	return { stage = stage, kind = s and s.kind, plan = s and s.plan, say = s and s.say }
end

-- a tutorial car was handed back: everyone on that stage who did a work unit moves on
function TutorialService.released(car: Model, workers: { Player })
	local stage = car:GetAttribute("Tutorial") :: number?
	if not stage then
		return
	end
	for _, p in workers do
		if PlayerData.tut(p) == stage then
			PlayerData.setTut(p, stage + 1)
			if stage + 1 == 4 and TutorialService.onDone then
				TutorialService.onDone(p)
			end
		end
	end
end
TutorialService.onDone = nil :: ((player: Player) -> ())? -- Main: the next ordinary customer brings a new job

-- the scripted cars' extras: car 1 = the Scanner on hood open, out of the work view once fixed (start it up from
-- the driver's seat: the whole car is in view for the moment it starts). Car 2's first jack tap is a demo
-- (JackService), car 3's flat has a nail to find (FaultService / WorkService).
function TutorialService.setup(car: Model)
	if car:GetAttribute("Tutorial") == 1 then
		TutorialService.scannerOnHood(car) -- (defined below)
		car:GetAttributeChangedSignal("Fixed"):Connect(function()
			if car:GetAttribute("Fixed") == true and TutorialService.onFixed then
				TutorialService.onFixed(car)
			end
		end)
	end
end
TutorialService.onFixed = nil :: ((car: Model) -> ())? -- Main: the first car's workers step out of the work view

-- the first car's hood opens: the Scanner goes into the hands of whoever is on stage 1 near it (v0.2 C)
local function scannerOnHood(car: Model)
	car:GetAttributeChangedSignal("HoodOpen"):Connect(function()
		if not car:GetAttribute("HoodOpen") or car:GetAttribute("TutScanner") then
			return
		end
		car:SetAttribute("TutScanner", true)
		for _, p in Players:GetPlayers() do
			local char = p.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local tool = p:FindFirstChildOfClass("Backpack") and (p :: any).Backpack:FindFirstChild("Scanner")
			if PlayerData.tut(p) == 1 and hum and tool and ((char :: Model):GetPivot().Position - car:GetPivot().Position).Magnitude < 40 then
				hum:EquipTool(tool)
			end
		end
	end)
end

function TutorialService.start()
	Remotes.TutSkip.OnServerEvent:Connect(Guard.wrap("TutSkip", 1, function(player)
		PlayerData.skipTut(player)
	end))
end

TutorialService.scannerOnHood = scannerOnHood

return TutorialService
