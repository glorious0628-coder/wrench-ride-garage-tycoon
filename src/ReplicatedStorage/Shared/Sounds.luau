-- Every sound the game plays, in one place: UI = the official "Roblox" account's set, car / tool sounds = our own
-- (wr-sound -> user's pick -> main's private upload, 10-21). id = "" means no sound: the client skips it (and shows
-- the clue as text instead). duck = a big moment: the background music dips under it (Music.duck).

return {
	-- UI (Roblox account)
	uiClick = { id = "rbxassetid://15675059323", volume = 0.5 }, -- Roblox_UI_Bright_Click
	uiSmallClick = { id = "rbxassetid://15675032796", volume = 0.5 }, -- Roblox_UI_Small_Click
	reward = { id = "rbxassetid://15675043410", volume = 0.6 }, -- Roblox_UI_Tonal_Stinger
	pop = { id = "rbxassetid://15675055424", volume = 0.5 }, -- Roblox_UI_Cute_Pop
	whoosh = { id = "rbxassetid://15675024286", volume = 0.4 }, -- Roblox_UI_Whoosh_01

	-- car / tools: our own sounds (v2 10-21: wr-sound AI 1st review -> main 2nd review -> uploaded privately by main
	-- for this game — art/sfx/audio_ids.json, files art/sfx/v2/, review art/sfx/v2/review_v2.md)
	engineStart = { id = "rbxassetid://118709130528835", volume = 0.77, duck = true }, -- after a fix: click -> vroom -> idle
	engineFail = { id = "rbxassetid://121845263687906", volume = 0.99 }, -- starter click-click-click
	brakeSqueal = { id = "rbxassetid://74190786816596", volume = 0.26 }, -- short chirps as the wheel turns
	brakeQuiet = { id = "", volume = 0.5 }, -- no sound on purpose (user 10-21): the squeal being gone is the proof
	tireHiss = { id = "rbxassetid://95145435330691", volume = 0.3 },
	steamHiss = { id = "rbxassetid://120996752045951", volume = 0.29 },
	exhaustLoud = { id = "rbxassetid://114705499565672", volume = 0.33 },
	wrench = { id = "rbxassetid://96458813639943", volume = 0.85 }, -- hand wrench, one bolt loosened
	wrenchTighten = { id = "rbxassetid://135097909656345", volume = 0.61 }, -- ... one bolt tightened
	impact = { id = "rbxassetid://95937278645213", volume = 0.42 }, -- impact wrench, one nut (once per 0.2 s): the burst's first 0.3 s
	impactBurst = { id = "rbxassetid://131916002274922", volume = 0.27 }, -- the long burst: the last nut snugs down
	ratchet = { id = "rbxassetid://129692071953452", volume = 1.0 }, -- ratchet wrench, one bolt
	clank = { id = "rbxassetid://137237477469514", volume = 0.51 }, -- the last bolt out, the part drops loose
	install = { id = "rbxassetid://116916624980822", volume = 0.52 }, -- a part snaps into its spot
	partDrop = { id = "rbxassetid://97737310014560", volume = 0.78 }, -- a carried part set down
	spark = { id = "rbxassetid://126125049819105", volume = 0.98 }, -- the wrong battery terminal
	cheer = { id = "rbxassetid://116954590421786", volume = 0.59 }, -- a thank-you honk twice (sfx_list #19)
	lineHonk = { id = "rbxassetid://87901426315167", volume = 0.36 }, -- the next customer pulls into the lot: one short friendly toot (wr-sound)
	-- quick jobs at the curb (curb_jobs.md §5, wr-sound): empty until they're made
	wiperMotor = { id = "rbxassetid://102861262101248", volume = 0.24 }, -- the wipers rise to the service position
	bladeSnap = { id = "rbxassetid://77583796674312", volume = 1 }, -- a blade unclipped / clipped on
	washerSpray = { id = "rbxassetid://110645114062810", volume = 0.31 }, -- the spray test: pssht + two wipes
	washerWhirr = { id = "", volume = 0.45 }, -- the empty tank: the pump whirrs, no water
	pourGlug = { id = "rbxassetid://123398659995487", volume = 0.48 }, -- glug-glug from the jug while pouring
	hoodOpen = { id = "rbxassetid://86063294516723", volume = 0.82 },
	hoodClose = { id = "rbxassetid://93684093880990", volume = 0.2 },
	liftMotor = { id = "rbxassetid://103568645062317", volume = 0.21, loop = true }, -- while a lift moves (Lv6 hydraulic lift)
	liftLock = { id = "rbxassetid://96315393935883", volume = 0.7 }, -- the lift / jack stand locks at a height
	payout = { id = "rbxassetid://81532380730158", volume = 0.94, duck = true }, -- the pay card (falls back to reward)

	-- shop / progress (v2 10-21, not wired yet: wr-dev picks where they play)
	deskBell = { id = "rbxassetid://119777892547919", volume = 0.72 }, -- a customer at the front desk
	wrongBuzz = { id = "rbxassetid://91098562738049", volume = 0.39 }, -- a gentle two-note "not that one"
	levelUp = { id = "rbxassetid://121834220893277", volume = 0.48, duck = true }, -- the garage levels up
	stamp = { id = "rbxassetid://70523656522023", volume = 0.83 }, -- the receipt gets its PAID stamp
	scannerBeep = { id = "rbxassetid://83659439502491", volume = 0.26 }, -- the scanner shows a reading
	signPaint = { id = "rbxassetid://76710190787337", volume = 0.62, duck = true }, -- the garage's first name on the sign: a brush swish + a small sparkle (NameWindow; levelUp until it comes)

	-- background music (music_list.md v0.2, wr-sound: art/music/v1/; 2nd review + upload: main 10-22). Music.luau
	-- plays them flat and looped in SoundService.Music, ~12 dB under the effects
	garageDayA = { id = "rbxassetid://116085038857317", volume = 0.2, loop = true }, -- the garage by day: first, then A <-> B by turns
	garageDayB = { id = "rbxassetid://101709995403572", volume = 0.2, loop = true },
	halloweenNight = { id = "rbxassetid://113058968251404", volume = 0.2, loop = true }, -- Ella's night: "Closing soon" -> the midnight scene

	-- Halloween: Ella's scenes (halloween_pumpkin.md §5b, wr-sound; 2nd review + upload: main 10-21 / 10-22)
	neonOn = { id = "rbxassetid://102847385224612", volume = 0.28 }, -- the "Closing soon" sign buzzes on
	nightAmb = { id = "rbxassetid://118511914885914", volume = 0.11, loop = true }, -- crickets, while it's night (ambNight)
	coachRoll = { id = "rbxassetid://102893761736428", volume = 0.44 }, -- the coach rolls in / out
	sparkleTrail = { id = "rbxassetid://98618131915665", volume = 0.24 }, -- wind-chime trail as it rolls in (fades out 0.3 s when it stops)
	coachStop = { id = "rbxassetid://86553494933058", volume = 0.24 },
	slipperDing = { id = "rbxassetid://75481956693784", volume = 0.3 }, -- the glass slipper
	ellaCheer = { id = "rbxassetid://85684518768406", volume = 0.25 },
	sparkle = { id = "rbxassetid://98594496230998", volume = 0.36 },
	bell12 = { id = "rbxassetid://91006253935947", volume = 0.49 }, -- twelve slow tower bells 0-2.75 s, the last one rings to 3.95 s (the midnight cut is 3 s: it fades under the pop)
	pumpkinPop = { id = "rbxassetid://135798173818410", volume = 0.41 },
	pumpkinRoll = { id = "rbxassetid://107929415672873", volume = 0.44 },
	ellaGiggle = { id = "rbxassetid://124447498606283", volume = 0.21 },
	morningBird = { id = "rbxassetid://108265326985904", volume = 0.27 },
	clockTickSoft = { id = "rbxassetid://139785675202418", volume = 0.27 }, -- the midnight clock moves on

	-- v3 sounds (10-22: wr-sound -> main 2nd review -> private upload; art/sfx/audio_ids.json, volumes art/sfx/v3/volumes_1022.md)
	beltSqueal = { id = "rbxassetid://91565579338951", volume = 0.38 }, -- a loose belt squeals as the engine turns over
	rattle = { id = "rbxassetid://83568021364192", volume = 0.3 }, -- an exhaust heat shield rattles
	swayClunk = { id = "rbxassetid://123250358981225", volume = 0.48 }, -- the sway bar clunks
	fuelPrime = { id = "rbxassetid://107718673179666", volume = 0.53 }, -- the fuel pump clicks and whines
	hammerTap = { id = "rbxassetid://116056127503187", volume = 0.75 }, -- two light hammer taps (a stuck part)
	orderDing = { id = "rbxassetid://97164989689328", volume = 0.27 }, -- a part order is taken: ding-ding
	clap = { id = "rbxassetid://78256032668277", volume = 1 }, -- four claps
	crankShort = { id = "rbxassetid://115196461590737", volume = 0.51 }, -- a short crank of the starter
	tick = { id = "rbxassetid://90892511183879", volume = 0.4 }, -- one clock click (the settlement lines)
	cartLoad = { id = "rbxassetid://121041546017808", volume = 0.72 }, -- a part set on the cart
	scanStart = { id = "rbxassetid://83542455176756", volume = 0.29 }, -- the scanner starts: bip-bip-beep
	jackPump = { id = "rbxassetid://79131450235078", volume = 0.74 }, -- one stroke of the floor jack's pump
	boltPop = { id = "rbxassetid://115900929244401", volume = 1 }, -- a bolt pops free at the end of its turn
	trainPass = { id = "rbxassetid://74761158848865", volume = 0.18 }, -- a train passes (not wired yet)
	ambGarage = { id = "rbxassetid://128051540592704", volume = 0.23, loop = true }, -- the garage's room tone (not wired yet)
	ambBirds = { id = "rbxassetid://104825407902075", volume = 0.08, loop = true }, -- birds outside (not wired yet)
	ambStreet = { id = "rbxassetid://96550419972866", volume = 0.1, loop = true }, -- street traffic, real recording (CC0; not wired yet)
} :: { [string]: { id: string, volume: number, loop: boolean?, duck: boolean? } }
