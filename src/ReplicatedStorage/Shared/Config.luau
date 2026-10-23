-- Every tunable number in one place (server and client both read it).
-- Studs: 1 stud ~ 0.3 m for the car (R15 is ~5.5 studs tall), cars are 1.15x wider than real (기획서 3장).

local Config = {}

-- the teardown update's pieces, one switch each (notes/handoff/sessions/wr-dev_teardown_plan.md §5-1): off = the
-- game exactly as before. Main turns one on once it passed review. In Studio only, a workspace attribute
-- Dev_<Name> = true turns it on in that window (a published game never reads it)
Config.Features = {
	Stars = false, -- car stars ★1~★3 (docs/design/car_difficulty.md v0.1)
	ToolMatch = false, -- the right tool for each fastener, picked for you (docs/design/full_teardown.md §3-§4)
	NewParts = false, -- piece E: the new engine-bay parts (full_teardown §0-1, 3D art/3d/engine_bay_v2) — with LiveLumps
	NewPartsP5 = false, -- (piece P5, the radiator chain: cover · hoses · the radiator deeper — needs Fluid:Coolant)
	E2Susp = false, -- piece E2: the suspension (front struts · rear link / shock / No.2 arm / spring) — with LiveLumps Deco_Hub_F / _R
	Minigames = false, -- the mini-game screens + the Settings "Mini-games: Play | Auto" row from Lv 8 (docs/design/minigames.md v0.3)
	VfxV2 = false, -- the new effects (Shared/VFX.luau + VfxPresets: Kenney textures, steam / drip / muffler puffs / zap, phone steps)
	VfxSparkle = false, -- the '뾰로롱' sparkle at a mini-game success (Shared/VFX Sparkle_Perfect / Sparkle_Small, heard in Effects.luau)
	NewPartsLater = false, -- (intake duct · throttle body · engine computer: rows ready, waiting for their 3D F_ points)
	UnderView = false, -- the creeper view under a car on its stands (work_view §2c): zones Under_Front / Under_Rear + the muffler's job from Lv 6
	Coffee = false, -- every customer waits sitting in the waiting room + coffee for them (user 10-22): CoffeeService
	ClampTrap = false, -- the loose battery hold-down trap from Lv 3 (full_teardown §0-1 P0: tighten its clamp bolt)
	OilChange = false, -- the oil change job (Lv3, full_teardown ④ — Modules/OilService, rows Cars/SedanOil): needs UnderView and the sedan's under lumps live
	NewBody = false, -- the body taken apart (main lumps 10-23: shell panels / doors / trunk lid, glass, chassis, interior) — with LiveLumps Decor_Shell / Decor_Glass / Decor_Chassis / Deco_Interior / Deco_Dash
	MechAnim = false, -- the mechanic's body moves (lean · kneel · bolt sweeps · hood) — ClientModules/MechAnim, ids from main's upload
}
-- per car type, the old decor lumps whose new parts come apart (wr-dev plan §4): a lump goes live only with
-- Features.NewParts on, its row here true, and (outside Studio) every part mesh of it baked. Studio: workspace
-- attribute Dev_Lump_<lump> = true turns one on in my window (blocks stand in for missing meshes).
Config.LiveLumps = {
	-- (Deco_Hub_F / _R: piece E2's suspension at the front / rear corners — full_teardown §0-2)
	-- (Deco_Underbody / EngineLower / Transaxle: the underside, art/3d/underbody_v1 — drawn only, no part rows yet:
	-- notes/gpt/wr-dev/underbody_decision.md)
	Sedan = {
		Deco_EngineBay = false, Deco_EngineTop = false, Deco_Hub_F = false, Deco_Hub_R = false,
		Deco_Underbody = false, Deco_EngineLower = false, Deco_Transaxle = false,
		Decor_Shell = false, Decor_Glass = false, Decor_Chassis = false, Deco_Interior = false, Deco_Dash = false,
	},
	-- (the SUV and the pumpkin coach: the same lumps, each needs its own 3D first — Generated/<type>Bay / Under /
	-- Susp and CarMeshes <type>_<id>_Detail, <type>_Decor_<lump>V2; main lumps 10-23. A row stays off without them)
	Crossover = {
		Deco_EngineBay = false, Deco_EngineTop = false, Deco_Hub_F = false, Deco_Hub_R = false,
		Deco_Underbody = false, Deco_EngineLower = false, Deco_Transaxle = false,
		Decor_Shell = false, Decor_Glass = false, Decor_Chassis = false, Deco_Interior = false, Deco_Dash = false,
	},
	PumpkinCoach = {
		Deco_EngineBay = false, Deco_EngineTop = false, Deco_Hub_F = false, Deco_Hub_R = false,
		Deco_Underbody = false, Deco_EngineLower = false, Deco_Transaxle = false,
		Decor_Shell = false, Decor_Glass = false, Decor_Chassis = false, Deco_Interior = false, Deco_Dash = false,
	},
}
function Config.feature(name: string): boolean
	if game:GetService("RunService"):IsStudio() and workspace:GetAttribute("Dev_" .. name) == true then
		return true
	end
	return Config.Features[name] == true
end

-- one mini-game kind on? — the whole switch (Features.Minigames) and the kind's own (Config.Minigame.Enabled: false = that
-- kind is off and its job step goes the way it did before mini-games: Scrub / Polish the old hold, Tire / Torque / Coolant
-- no step). Balance is the old balancer's screen — always on.
function Config.minigameKind(kind: string): boolean
	return Config.feature("Minigames") and (Config.Minigame :: any).Enabled[kind] ~= false
end

-- player money / reputation (saved: PlayerData / DataService)
Config.StartMoney = 600
Config.StartReputation = 0

-- people-test timing (ServerScriptService/Modules/Metrics): also send the times as AnalyticsService custom events
-- (FTUE_firstTouch / FTUE_firstChange / FTUE_firstPay) on live servers — off until main says so
Config.SendAnalytics = false

-- the work view (docs/design/work_view.md 8): camera, hold-to-turn bolts, the floor jack and stands, the cart
Config.WorkCamTween = 0.5 -- seconds: into / out of a work zone
Config.WorkPeekTween = 0.3 -- a quick look aside (the cart)
Config.HoldBoltTime = 0.4 -- hand wrench: hold this long on a bolt (ratchet / impact keep their own pace)
Config.WorkPickPixels = 60 -- touch / click range on bolts and parts in a work view
Config.ExitHoldMove = 0.5 -- a move key held this long leaves the work view
Config.CartDeliver = 2 -- parts bought at the counter land on the bay's cart after this long
Config.ScanTime = 1.0 -- Scan / Final check
Config.JackPumpTime = 1.5 -- the car rises this long while Pump is held
Config.JackDemoTime = 3 -- the first time (Tyler): one tap shows chock -> jack -> pump -> stands
Config.LowerCarTime = 0.8
Config.StandHeight = 1.8 -- the jacked end's axle goes up this much (the lift's Wheel level)
Config.CreeperSlide = 0.6 -- lying on the creeper, rolling in under the car (work_view §8)
Config.UnderUnlock = { Muffler = 6 } -- the jobs under the car, joined into FaultUnlock only with Features.UnderView (economy v0.5 Lv6)
Config.WorkPickReach = 20 -- in a work view, parts on the bay's cart can be taken from the work stand

-- today's receipt (docs/design/daily_receipt.md 4): keep the last shift when it had MinJobs jobs and lasted MinMinutes;
-- the "Receipt ready" notice at these job counts
Config.Receipt = { MinJobs = 1, MinMinutes = 5, BannerAtJobs = { 5, 10 }, MaxLines = 7 }

-- game passes (art/roblox_gamepasses.json; docs/design/monetization.md 5). Made but NOT on sale: main turns each one
-- on with the user once its feature is in the game. Ownership is checked on the server (Modules/Passes).
Config.Passes = {
	GarageRename = 2046200362,
	GoldTools = 2045396387,
	PaintPro = 2045384384,
	NeonGarage = 2043716463,
	CustomSign = 2044412404,
	-- monetization v2 (notes/handoff/pass_build_list.md): ids come from wr-release / main once made (board)
	PayBoost = 2045007347,
	VIPMechanic = 2045595333,
	StarterPack = 2045222683, -- (the old Starter Look pass, updated to the Starter Pack)
}
-- developer products (Cash Envelopes): ids from wr-release / main (art/roblox_devproducts.json)
Config.Products = {
	CashSmall = 3720997803,
	CashMedium = 3720997830,
	CashBig = 3720997846,
}
-- the sale switch, per Shared/StoreData key (main flips it with Roblox's for-sale): off = the item isn't shown AND does
-- nothing even if owned (in Studio the creator "owns" every pass). Studio test: player attribute StoreTest = "Key,Key"
Config.StoreOn = {
	StarterPack = false,
	PayBoost = false,
	CashSmall = false,
	CashMedium = false,
	CashBig = false,
	VIPMechanic = false,
	GoldTools = false,
	GarageRename = false,
}
Config.PayBoostMult = 1.5 -- Pay Boost: my labor + tips (never parts, reputation, envelopes, records)
Config.PaidSpeed = 0.10 -- every paid speed together stays under this (monetization §4-2): VIP's walk +10%
Config.StarterCash = 750 -- Starter Pack's money, once a player
Config.ReceiptsKept = 40 -- product purchase ids remembered in the save (a repeat of one is never paid twice)

-- reach: how far the server lets a hand / tool touch something (studs, from the HumanoidRootPart)
Config.ReachDistance = 9
Config.PromptDistance = 7

-- bolts
Config.WrenchInterval = 0.32 -- seconds between bolts with the hand wrench (one click = one bolt)
Config.ImpactInterval = 0.09 -- impact wrench: hold and sweep, one bolt per this long
Config.RatchetInterval = 0.22 -- ratchet wrench (Lv3): hold and sweep, slower (alpha_scope §3)
Config.BoltPickPixels = 34 -- client: a bolt within this many screen pixels of the mouse is picked
Config.TouchPickScale = 1.6 -- ... x this on a phone (a finger is wider than a mouse pointer)
-- (the three tool times above are the only bolt times: the same tool always takes the same time per bolt)
Config.MagnetRange = 3.5 -- studs: setting a carried part down this close to its empty spot puts it on
Config.ProofSeconds = 2.4 -- the "it works now" moment before the pay (start / quiet brakes), when not seen yet
Config.BoltLooseColor = Color3.fromRGB(255, 170, 40) -- a loose bolt sticks out, orange, so it's easy to find
Config.BoltTightColor = Color3.fromRGB(210, 212, 218)
Config.DetachPop = 0.6 -- studs a part pops out when its last bolt comes out
Config.SwingDeg = 22 -- a Swing part (E2: the rear No.2 arm) hinges down this far on its inner bolt — the spring comes free

-- carrying (car_spec 3-2 CarryMode: OneHand normal walk, TwoHand 70% and no tools, Roll 85%)
Config.NormalWalkSpeed = 16
Config.CarrySpeed = { OneHand = 1, TwoHand = 0.7, Roll = 0.85, Crane = 0.5 }
Config.CarryOffset = { -- from the HumanoidRootPart
	OneHand = CFrame.new(1.2, -0.6, -1.4),
	TwoHand = CFrame.new(0, -0.3, -2.2),
	Roll = CFrame.new(0, -1.675, -2.4), -- the wheel stands on the floor in front of you (radius 1.375)
	Crane = CFrame.new(0, 0, -3),
}
Config.MaxLooseParts = 12 -- bought parts lying around per player (anti-spam)
Config.ShopReach = 14 -- studs from the parts counter's ServicePoint

-- condition (0..100, an Attribute on every car part)
Config.FaultCount = { 2, 5 } -- random faults per car (min, max): junkyard restorations (later)
-- customers' cars by garage level (wr-design fault_catalog §0: an easy first hour)
Config.FaultsByLevel = {
	{ upTo = 5, count = { 1, 1 } },
	{ upTo = 15, count = { 1, 2 } },
	{ upTo = math.huge, count = { 2, 3 } },
}
-- garage level = cumulative reputation, never goes down (docs/design/economy.md v0.2 §1). Lv1..16, then a star
-- every StarLevelStep
Config.GarageLevels = { 0, 12, 34, 80, 120, 230, 400, 620, 850, 1100, 1400, 1750, 2100, 2500, 2950, 3500 }
Config.StarLevelStep = 900
-- reputation per job (§1-1): only ever adds
Config.Rep = { PerFault = 10, SpotOn = 3, Fast = 2, Unfixed = 0 }
-- which kinds can break on a customer's car, by the level they open at (§1-2; Muffler waits for the hydraulic lift,
-- Hood for Lv9)
Config.FaultUnlock = { Battery = 1, Wheel = 1, BrakePads = 2, Bumper = 3, Radiator = 5, Muffler = math.huge, Hood = 9 }
-- the new parts' jobs (piece E2 — rival_upgrade §B5: rear shock Lv7, front strut / rear spring Lv9): joined into
-- FaultUnlock only on a game where those parts are live (CarParts.sold — so the level cards never promise a job
-- that can't come)
Config.FaultUnlockLive = {
	Shock = 7, Strut = 9, Spring = 9,
	-- piece E stage 2, the engine bay (full_teardown §0-1): air filter Lv1 · coolant tank Lv3 · horn fuse Lv4 · coils and
	-- plugs Lv5 · radiator hoses Lv6 (P5 — and with them the whole radiator moves to Lv7: CarParts)
	AirFilter = 1, CoolantReservoir = 3, Fuse = 4, IgnitionCoil = 5, SparkPlug = 5, RadiatorHose = 6,
	-- the oil change (Features.OilChange + UnderView: the filter's row exists then — CarParts.sold): the filter's job is the whole oil change
	OilFilter = 3,
}
Config.RadiatorDeepUnlock = 7 -- the radiator job once its cover and hoses come off first (P5 live)
-- a new car keeps away from the fault variants of this many cars before it, when there's another choice (fault_mix v0.2 ①)
Config.VariantMemory = 4
-- car stars (car_difficulty v0.1 §2-§5; only with Features.Stars — then they decide how many faults, not
-- FaultsByLevel). A car's star comes from what it really got: the deepest fault (PartGraph depth) and how many.
-- CarStars: chance of each star by garage level (★4 / ★5 have no rules yet: their share falls to the highest star
-- that has). StarRules: the shapes a star can take (count = faults, maxDepth = none deeper, needDepth = one this deep).
Config.CarStars = {
	{ upTo = 2, w = { 100 } },
	{ upTo = 5, w = { 65, 35 } },
	{ upTo = 8, w = { 30, 45, 25 } },
	{ upTo = 12, w = { 15, 35, 35, 15 } },
	{ upTo = 15, w = { 10, 25, 35, 25, 5 } },
	{ upTo = math.huge, w = { 10, 20, 30, 25, 15 } },
}
Config.StarRules = {
	{ { count = { 1, 1 }, maxDepth = 1 } },
	{ { count = { 1, 1 }, maxDepth = 2, needDepth = 2 }, { count = { 2, 2 }, maxDepth = 2 } },
	{ { count = { 1, 2 }, maxDepth = 3, needDepth = 3 }, { count = { 3, 3 }, maxDepth = 2 } },
}
-- §3 rhythm: after hardInARow cars of ★3+ an easy one (★1~★2); the first fault isn't a kind of the last sameKindGap
-- cars; each extra player moves coopStarBonus of the ★1 share to ★3
Config.Rhythm = { hardInARow = 2, sameKindGap = 2, coopStarBonus = 0.05 }
-- §4 labor units by depth (1, 2, 3, 4+): labor = LaborByLevel x the fixed faults' units, rep = Rep.PerFault x units,
-- the customer's patience x units^PatiencePow (never less than now)
Config.StarLU = { 1.0, 1.5, 2.2, 4.0 }
Config.StarPatiencePow = 0.8
Config.FaultCondition = { 0, 30 } -- a broken part's condition
Config.HealthyCondition = { 72, 100 } -- everything else
Config.WarnBelow = 70 -- inspect colours: >= 70 green, 31..69 yellow, <= 30 red
Config.BrokenBelow = 31
Config.NewPartCondition = 100

-- inspect mode (scanner)
Config.InspectBodyTransparency = 0.6 -- LocalTransparencyModifier on body panels (기획서 6장)
Config.InspectRange = 30 -- studs from the car
Config.Colors = {
	Good = Color3.fromRGB(70, 220, 110),
	Warn = Color3.fromRGB(255, 205, 60),
	Bad = Color3.fromRGB(240, 60, 50),
}

-- lift
Config.LiftSpeed = 2.4 -- studs per second (levels: CarParts.LiftLevels)

-- jobs / payout (economy.md v0.2 §2-1: parts x 1.3 + labor x faults fixed + tips)
Config.LaborByLevel = { { upTo = 5, labor = 120 }, { upTo = 15, labor = 160 }, { upTo = math.huge, labor = 200 } }
Config.PartsMarkup = 1.3 -- the customer pays this times the part price for each fault fixed
Config.FirstJobTip = 150 -- the tutorial customer tips big, so the Battery Tester ($250) is in reach (§2-1)
Config.FirstCustomerStandOff = 4.5 -- studs out from the driver's door where the first customer waits (B1 ⑤)
Config.DiagnosisFee = 30 -- the first car's settlement: a "Diagnosis" line out of its labor (paid with the rest — user 10-22)
-- coffee for a waiting customer (Features.Coffee — CoffeeService): pour (hold), a tip line for whoever gave it, and
-- the wait feels shorter (the patience clock goes back this many seconds)
Config.CoffeePour = 1.2
Config.CoffeeTip = 5
Config.CoffeeCalm = 30
Config.CoffeeAskAfter = 15 -- seconds after a customer sits down: "Is there any coffee?" once (GPT r1 ⑤)
Config.FastTipSeconds = 240 -- finish within this: +FastTip
Config.FastTip = 80
Config.SpotOnPct = 0.15 -- every replaced part was really broken (fault_catalog §0-4 "Spot On!")
-- 2-4 players on one car: each helper gets this share of labor + tips (§3); parts money goes to whoever bought them
Config.CoopShare = { 1, 0.7, 0.55, 0.45 }
Config.StarTip = 10 -- per wheel whose lug nuts went on in the star pattern (car_spec 4-1: a small bonus, never forced)
Config.CheckInterval = 0.8 -- seconds between Scanner checks
-- Wheel Balancer timing gauge (기획서 3장): the needle goes there and back once per period; stop it in the green
Config.BalancePeriod = 1.6
Config.BalanceZone = 0.34 -- width of the green (0..1 of the gauge; x52 degrees each way = ~35 degrees across: wr-uidesign A2 wanted 30-40)
Config.BalanceHits = 3
-- mini-games (docs/design/minigames.md v0.3; the server judges, the client only says pressed / let go / rubbed):
-- MinigameService. Kinds = the ones there are (a save only keeps these). Auto (Settings "Mini-games: Play | Auto",
-- Features.Minigames): from AutoLevel, for a kind already played once by hand, done as 'Good' in AutoTime seconds
-- (no Perfect tip, nothing else of the job moves meanwhile). Perfect = a small tip to whoever played it, at most TipCap
-- a car for one player counting the star-pattern tip (notes/gpt/main/minigames_launch_decision.md 9). One car: at
-- most MaxPerCar kinds by hand (decision 7), a kind not tried yet weighs Untried when the wheel job picks Tire / Torque
Config.Minigame = {
	Kinds = { Balance = true, Scrub = true, Polish = true, Coolant = true, Tire = true, Torque = true },
	Enabled = { Scrub = true, Polish = true, Coolant = true, Tire = true, Torque = true }, -- (a kind set to false is off: Config.minigameKind)
	AutoLevel = 8,
	AutoTime = 4.5,
	PerfectTip = 10,
	TipCap = 20,
	MaxPerCar = 2,
	Untried = 3,
	FirstPlays = 3, -- the first this many times a player meets a kind, its band is FirstWiden wider (decision 10)
	FirstWiden = 1.25,
	Timeout = 30, -- seconds without an input: the session ends (nothing lost — start again)
	HelpAfter = 3, -- misses in a row, then this time it's easier (Perfect no longer possible)
	HelpWiden = 1.2,
	AskAgain = 10, -- Hand back pressed again within this while a step waits: the step runs by itself ('Good')
}
-- the balancer judged on the server's clock only (exploit audit M3 / minigames §4): the tap is taken to have
-- happened half the player's round trip before it arrived, give or take Grace seconds; taps TapGap apart at least
Config.BalanceGrace = 0.04
Config.BalanceTapGap = 0.25
-- the terminal scrub (minigames E, BAT_CORROSION): the crust is a Cols x Rows grid the server owns; the client sends
-- the cells its finger went over — at most CellsPerSecond, never done before MinTime; the last AutoLeft cells go by
-- themselves (decision 5). Perfect = done within PerfectTime. Polish = the same frame on a light scratch (one line)
Config.Scrub = { Cols = 6, Rows = 4, CellsPerSecond = 14, MinTime = 2.5, PerfectTime = 6, AutoLeft = 2 } -- (AutoLeft 2: the last two small lumps are done for the hand — wr-play 10-23, fingers missed them)
Config.Polish = { Cols = 8, Rows = 3, CellsPerSecond = 10, MinTime = 2.5, PerfectTime = 6, AutoLeft = 1 }
-- the fill frame (MinigameService "Coolant" / "Tire"): levels 0..1 of the tube, Rate = per second held (the server's
-- clock: the time between the down and the up it received). Coolant: drained → the L..F band, Perfect = the last
-- Perfect under F (car_knowledge 04 [7]: fill to F, engine cold); the tank's liquid after = Tank* heights (CarLook)
Config.CoolantFill = { L = 0.68, F = 0.84, Perfect = 0.07, Slack = 0.03, Rate = 0.2, Start = 0.2, Drain = 0.1, TankEmpty = 2.6, TankL = 3.0, TankF = 3.4 }
-- Tire: from StartPsi to the driver's-door sticker (TirePsi by car type: 03 [11] Camry 35 psi cold) ± Band, Perfect ±
-- (Perfect windows ≈ 0.33 s for now; the lag test 10/27 decides — notes/gpt/wr-mini/server_decision.md)
Config.TireFill = { MaxPsi = 50, StartPsi = 26, PsiPerSecond = 3, Band = 1.5, Perfect = 0.5, Drain = 4 }
Config.TirePsi = { Sedan = 35, Crossover = 35, PumpkinCoach = 35 }
-- the torque wrench's click (decision 3): delay d in Min..Max s into the hold, tight = let go within Window (+ Slack for
-- the lag test) after it, Perfect within Perfect, Almost = just before the click (a free retry). Rate = the bar's rise
Config.TorqueClick = { Min = 1.2, Max = 1.8, Window = 0.6, Slack = 0.1, Almost = 0.1, Perfect = 0.25, Rate = 0.35 }
Config.ListenRadius = 2.5 -- studs: how close the stethoscope has to touch the noisy part
Config.ScrapValue = 15 -- an old part dropped in the scrap bin
Config.OldPartScrapSeconds = 45 -- an old part left lying that long goes to the scrap pile by itself (same money)

-- customer kinds (alpha_scope v0.2 §1-1). Patience runs from parking to "Hand car back": Calm until calm s,
-- Restless until restless s, then Upset. The tip by stage replaces the old one-off fast tip. Customers never leave
-- with the car and never get ruder than "could I get an update?" (kids' game).
Config.CustomerKinds = {
	Regular = { calm = 420, restless = 660, tips = { Calm = 80, Restless = 40, Upset = 0 } },
	Hurry = { calm = 300, restless = 480, tips = { Calm = 160, Restless = 60, Upset = 0 }, fromLevel = 2, chance = 0.2 },
	Rosa = { calm = 420, restless = 660, tips = { Calm = 88, Restless = 44, Upset = 0 }, fromLevel = 4, every = { 1800, 2700 } },
	Tyler = { calm = 420, restless = 660, tips = { Calm = 88, Restless = 44, Upset = 0 }, fromLevel = 7, every = { 1800, 2700 } },
	VIP = { calm = 360, restless = 600, tips = { Calm = 200, Restless = 0, Upset = 0 }, fromLevel = 6, minPlayers = 2, every = { 900, 900 }, laborMult = 1.5 },
}
-- special customers' own looks (CustomerService.makeNpc): colours now, clothes asset ids when main makes them
Config.NpcLooks = {
	Ella = { torso = Color3.fromHex("B9BEC6"), legs = Color3.fromHex("B9BEC6"), arms = Color3.fromHex("E8862A") }, -- silver-grey dress, orange shawl
}
-- Halloween: Ella, the last customer before closing (docs/design/halloween_pumpkin.md v0.3). Server UTC dates.
Config.Halloween = {
	start = 1792972800, -- 2026-10-26 00:00 UTC (launch week)
	finish = 1793664000, -- 2026-11-03 00:00 UTC
	laterAfter = { 2, 3 }, -- after the first visit: once a shift, after this many of the owner's jobs
	paint = Color3.fromHex("E8862A"), -- the stand-in coach (a sedan) until the PumpkinCoach 3D is baked
	duskTime = 9, -- seconds the sky takes to go to night
	night = 20.4, -- Lighting.ClockTime at night
	bells = 3, -- seconds of midnight bells before the pop (bell12: twelve slow tower bells; the midnight cut's length)
}
-- floor puddles (fault_looks §3 / §5b): wr-art's top-down pictures (art/textures/puddles/<name>_puddle.png) once main
-- uploads them — "" = a plain coloured disc instead
Config.PuddleImages = { oil = "", coolant_pink = "116842460379212", coolant_green = "", atf_red = "", washer_blue = "", brake_yellow = "", ac_water = "" } -- (coolant_pink = v3 redrawn whole 10-23 — wet centre, thin edges; 1536x1024, decal 132203425013894)
Config.PuddleAspect = { coolant_pink = 1.15 } -- picture width / height (a picture on a square plate would be squeezed); missing = square
Config.VendingChance = 0.4 -- arriving customers who grab a can first
-- customer car types (docs/design/car_roster.md, CarParts.Types): this share of ordinary customers' cars from that
-- garage level, the rest are sedans (the first car, the tutorial and Rosa / Tyler always come in a sedan)
Config.CarTypeShare = { { type = "Crossover", fromLevel = 1, share = 0.3 } }
-- how customer cars differ (docs/design/car_variety.md §1; user 10-22: "no two of the same car in a row — not just
-- another colour"): never the last car's type (with 3+ types, none of the last Recent), never its paint, and a kit
-- (front face / rims / one extra / paint pattern) unlike the last one's. A kit piece whose 3D isn't baked yet shows
-- the base look (CarMeshes names: board 10-22 wr-dev). Named regulars always come in the same car (RegularLooks).
-- New types: add them to CarTypeShare (+ CarParts.Types and their meshes) — nothing else.
Config.CarVariety = {
	Recent = 2,
	Faces = { "Base", "Sport" },
	Rims = { "Steel", "Spoke5", "TwoTone" },
	Extras = { "None", "None", "RoofRack", "Spoiler" }, -- (half come with no extra: at most one per car)
	Patterns = { "Solid", "Solid", "TwoTone", "Stripe" },
}
Config.RegularLooks = {
	Rosa = { type = "Sedan", face = "Base", rim = "Steel", extra = "None", pattern = "Solid", paint = Color3.fromHex("2BA7A0") }, -- an old sedan, steel wheels
	Tyler = { type = "Sedan", face = "Sport", rim = "Spoke5", extra = "None", pattern = "Solid", paint = Color3.fromHex("E9ECEF") }, -- white (a van once there is one)
}
-- customer car paints (MeshPart.Color under the overlay textures): picked at random per car, plain casual colours of
-- a US street (white / grey / black / blue / red lead there), the type's own default in the list too
Config.PaintColors = {
	Color3.fromHex("098FFC"), -- bright blue (the sedan's default)
	Color3.fromHex("8FA283"), -- sage green (the SUV's default)
	Color3.fromHex("E9ECEF"), -- white
	Color3.fromHex("A9B0B7"), -- silver
	Color3.fromHex("43484F"), -- charcoal
	Color3.fromHex("C43A2E"), -- red
	Color3.fromHex("E3B23C"), -- mustard
	Color3.fromHex("2BA7A0"), -- teal
}
Config.CustomerTalkEvery = { 50, 80 } -- seconds between little lines while waiting

-- customers
Config.CustomerFirstDelay = 4
Config.CustomerInterval = 8 -- at least this between two cars coming off the road (the one waiting in the lot skips it)
Config.CarDriveSpeed = 45 -- studs per second on the road (slows down near the bay)
Config.CarParkSpeed = 12 -- into the bay / backing out of it (was 9: the bay sat empty longer — downtime 10-22)
Config.CustomerWalkSpeed = 10
Config.CustomerLeaveWalkSpeed = 16 -- the paid-up customer hurrying back to the car (straight there, no desk)
-- the line (notes/gpt/main/downtime_main_decision.md, user OK 10-22): while every bay works, the next customer pulls
-- into a WAIT HERE stall (World/Curbside) this long after the last car went in, waits by the car, waves now and then
Config.LineDelay = 6
Config.LineWaveEvery = { 8, 12 }
Config.LineMax = 1 -- how many wait at once (curb_jobs §1-2: 1 at launch; 2 if bays sit empty 10 s+ in the 4-player test)
Config.CustomerReadyWait = 1.5 -- studs on the waiting-room side of the bay door where the customer waits once the car is fixed
-- quick jobs at the curb (docs/design/curb_jobs.md v0.1 §2, CurbService): money = the job only (parts off), rep; when they
-- come (bay jobs between, s since the last one left, ordinary cars after the tutorial before the first one); patience
-- (s): WaitStart without a start -> leaves, OpenToAll -> anyone may do it, GiveUp after a start with nobody within
-- PauseRange studs -> leaves (never a penalty); Hold = the prompts' hold seconds
Config.CurbJobs = {
	Washer = { level = 3, pay = 20, rep = 1 },
	Wipers = { level = 4, pay = 30, rep = 1 },
	EveryJobs = { 2, 3 },
	MinGap = 240,
	FirstAfter = 2,
	WaitStart = 150,
	OpenToAll = 60,
	GiveUp = 120,
	PauseRange = 15,
	Hold = { start = 0.6, blades = 0.8, pour = 1.5 },
}
Config.CustomerWaitLine = 120 -- seconds into the wait the customer starts saying "not too much"

-- corner meshes: Detail within LodNear studs of the camera, Lite beyond LodFar (the gap stops flicker)
Config.LodNear = 12
Config.LodFar = 14

-- loop B: junkyard wrecks (docs/design/flip_loop.md §1-2, §6 — first test numbers)
Config.JunkyardLevel = 8
Config.WreckFaults = { 2, 3 } -- mechanical faults in a wreck (+ 1 body problem)
Config.WreckPrice = { 500, 900, 1200 } -- low / usual / best
Config.WreckRefill = { 120, 240 } -- seconds until a sold spot gets a new wreck
Config.WreckHiddenMax = 250 -- what hidden faults can add at most ("$0~250" on the appraisal card)
Config.TowSeconds = 120 -- "Tow it for me": arrives in the restoration bay after this
Config.TowSpeed = 24 -- studs per second, the block tow truck
Config.RestoredValue = 4200 -- a fully restored plain sedan (era multiplier 1x)
Config.TypicalRestore = 0.85 -- the estimate assumes a Silver-ish job
Config.QuickSellRate = 0.8 -- "Sell now" to the dealer
-- the title stamp (carbook restoration.md 1-1): how often, buy price x, restored value x (Salvage sells as Rebuilt)
-- (flip_loop v0.2 1-1: Lv8~9 only CLEAN / SALVAGE, FLOOD and JUNK from Lv10). SALVAGE -> REBUILT after the State
-- Inspection; until then quick sale only
Config.TitleChance = {
	{ level = 1, Clean = 0.7, Salvage = 0.3 },
	{ level = 10, Clean = 0.55, Salvage = 0.25, Flood = 0.1, Junk = 0.1 },
}
Config.TitlePrice = { Clean = 1, Salvage = 0.6, Flood = 0.6, Junk = 0.4 }
Config.TitleValue = { Clean = 1, Salvage = 0.65, Rebuilt = 0.65, Flood = 0.6, Junk = 0 }
Config.OneOwnerChance = 0.2 -- "one owner" on the papers: +5% when sold
Config.HiddenRustChance = 0.5 -- a second rust spot under the car

-- loop B: restoration (flip_loop 3-1, 3-2)
Config.WashHold = 3 -- seconds per side (4 sides)
Config.RustHold = 1.5 -- seconds per body-work step
Config.PaintSupplies = 40 -- primer + paint + clear for one spot, paid at the primer step
Config.PatchPanel = { [2] = 60, [3] = 110 } -- a patch panel cut in and welded (bad / serious rust)
Config.SprayQuality = 0.7 -- best paint score without the Paint Booth (flip_loop: 70 -> 100 with it)
Config.RestoreWeights = { core = 0.6, looks = 0.25, clean = 0.15 }
Config.Grades = { Bronze = 60, Silver = 80, Gold = 95 }

-- loop B: selling (flip_loop §5-7)
Config.ValueBonus = { ServiceRecords = 0.03, OneOwner = 0.05 }
Config.SaleCap = 1.1 -- a buyer never pays more than 110% of the market value
Config.BuyerFirst = 15 -- seconds from putting a car on display to the first buyer
Config.BuyerEvery = { 40, 70 } -- seconds between buyers
Config.BuyerWait = 90 -- how long a buyer waits at the desk
Config.BuyerWeights = { Quick = 40, Bargain = 40, Collector = 20 } -- Collector x2 for a Gold car
Config.Haggle = {
	Quick = { offer = { 0.95, 1.0 }, c5 = 0.8, c10 = 0.45 },
	Bargain = { offer = { 0.75, 0.85 }, c5 = 0.6, c10 = 0.3 },
	Collector = { offer = { 0.9, 0.97 }, c5 = 0.75, c10 = 0.45 },
	GoldOffer = 0.06, -- a Collector offers more for a Gold car
	GoldBonus = 0.15, -- ... and says yes more often
	FailDrop = 0.15, -- each turned-down counter makes the next one less likely
	MoodDrop = 0.45,
	MaxCounters = 2,
}
Config.FlipShare = { { 1 }, { 0.7, 0.3 }, { 0.6, 0.2, 0.2 }, { 0.55, 0.15, 0.15, 0.15 } } -- of the profit, owner first
Config.FlipRep = { Gold = 40, Silver = 25, Bronze = 15, None = 5 } -- per sale (test values)
Config.HelperRep = 0.5

return Config
