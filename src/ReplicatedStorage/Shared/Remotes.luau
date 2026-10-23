-- Server makes the remotes, clients wait for them. The server decides everything (distance, tool, part state);
-- clients only send what they clicked and draw effects.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EVENTS = {
	"Notify", -- server → client: (key, args?, kind?)  kind = "info" | "good" | "bad"
	"Effect", -- server → client: (name, data)  "bolt" { bolt, loosen } | "detach" { part } | "install" { part } | "cash" { money }
	"Bolt", -- client → server: (bolt BasePart, mode "loosen" | "tighten") with the equipped wrench
	"Drop", -- client → server: drop what I'm carrying
	"Minigame", -- server → client: (what "start" | "hit" | "miss" | "done" | "stop", data) the balancer's timing gauge
	"MinigameTap", -- client → server: () stopped the needle (an old client's time argument is ignored: server clock only)
	"MinigameInput", -- client → server: (sessionId, seq, what "tap" | "down" | "up" | "cells", data?) — MinigameService
	"MinigameScrub", -- client → server: (sessionId, cells { number }, finished?) the terminal scrub screen (Scrub.luau)
	"SetMinigames", -- client → server: ({ mode = "play" | "auto" } | { keep = kind } | { clearKeep = true }) Settings / chips
	"MinigameScrub", -- client → server: (sessionId, cells { number }, finished boolean?) the Terminal Scrub's rubbed cells (intent only: the server judges)
	"SetMinigames", -- client → server: ({ mode = "play" | "auto" } | { keep = kind } | { clearKeep = true }) Settings' mini-game row / the Auto result chip
	"Listen", -- client → server: (car, point) the stethoscope touched here
	"Check", -- client → server: (clicked part) check it with the Scanner (DiagnosisService)
	"DevAck", -- client → server: (id, result) Studio play-test helper only (DevClient / Dev/CoopTest)
	"Install", -- client → server: (car Model, slotName) put what I'm carrying on that empty slot
	"TutSkip", -- client → server: () turn the tutorial's arrows and task lines off (TutorialService)
	"SetLang", -- client → server: ("en" | "ko") the language chosen in Settings, saved with the player
	"SetSound", -- client → server: ({ musicOn?, musicLv?, sfxOn?, sfxLv? }) Settings' sound rows, saved (any of the four)
	"Appraisal", -- server → client: (card) the junkyard appraisal card (JunkyardService)
	"Haggle", -- server → client: (view | nil) the showroom buyer's offer window (ShowroomService); nil = close
	"HaggleChoice", -- client → server: ("accept" | "c5" | "c10" | "decline")
	"Receipt", -- server → client: (kind "last" | "this", data) today's receipt (daily_receipt.md; drawn by Receipt.luau)
	-- the work view (work_view.md; WorkService / JackService, ClientModules/WorkView)
	"WorkExit", -- client → server: () leave my work zone
	"WorkPick", -- client → server: (part) take this part (from the car / the bay's cart) while in a work zone
	"WorkPlace", -- client → server: ("cart") set what I hold on the bay's cart | (car, slotName) put it on that slot
	"Jack", -- client → server: (car, "jack" end | "pump" | "stand" index | "lower" | "demo" end) the floor jack and stands
	"ScanZones", -- server → client: (car, { zones }, final) where to check (shown as "Check here")
	"Spotted", -- client → server: (car, "nail") found it while working on that wheel (WorkService)
	"Oil", -- client → server: (car, pouring boolean) hold-to-pour new oil at the filler cap, resent while held (OilService)
	"TryCar", -- client → server: (car, "start" | "brake") try the car from the job card / task strip button
	-- who plays in this garage (server_model.md; GateService / ClientModules/Gate)
	"Cinema", -- server → client: (scene "arrive" | "leave" | "midnight" | "morning", data) Halloween camera scenes; client → server: ("seen") watched them all once
	"Gate", -- server → client: ("moving", key, args) | ("retry") | ("failed") | ("ownerLeft", key, args); client → server: ("retry" | "home")
}
local FUNCTIONS = {
	"BuyPart", -- client → server: (partType) -> ok, key, args
	"BuyUpgrade", -- client → server: (Shared/Equipment id) -> ok, key, args
	"Dealer", -- client → server: ("list") -> my restored cars | ("sell" | "inspect" | "display", carId) -> ok, key, args
	"BuyWreck", -- client → server: (junkyard spot index) -> ok, key, args  (bought = towed to the restoration bay)
	"WorkEnter", -- client → server: (car, zone) -> ok, key, args  (a work zone: one player each, WorkService)
	"Scan", -- client → server: (car, final?) -> ok, key, args  (the whole-car scan: zones only, ScanZones follows)
	"NameGarage", -- client → server: (text) -> ok, key, args  (the owner names the garage: NameService)
}

-- made only in Studio (exploit audit L2) — on both sides: a live client waiting for one would never get past here
local STUDIO_ONLY = { DevAck = true }
local STUDIO = RunService:IsStudio()

local Remotes = {} :: { [string]: any }

local folder: Folder
if RunService:IsServer() then
	folder = ReplicatedStorage:FindFirstChild("Remotes") :: Folder
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	for _, name in EVENTS do
		if STUDIO_ONLY[name] and not STUDIO then
			continue
		end
		local r = folder:FindFirstChild(name) or Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = folder
		Remotes[name] = r
	end
	for _, name in FUNCTIONS do
		local r = folder:FindFirstChild(name) or Instance.new("RemoteFunction")
		r.Name = name
		r.Parent = folder
		Remotes[name] = r
	end
else
	folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
	for _, name in EVENTS do
		if not (STUDIO_ONLY[name] and not STUDIO) then
			Remotes[name] = folder:WaitForChild(name)
		end
	end
	for _, name in FUNCTIONS do
		Remotes[name] = folder:WaitForChild(name)
	end
end

return Remotes
