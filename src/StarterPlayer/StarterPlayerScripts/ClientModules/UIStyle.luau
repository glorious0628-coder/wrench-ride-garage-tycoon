-- UI look B "garage" (user pick 10-21, art/concepts/ui/ui_B.png): red metal windows, steel panels, yellow/black
-- hazard stripe, bolts only on the outer frame (decoration stays on the border: notes/gpt/main/ui3_r1_a.md).
-- Colours, fonts, motion numbers and image ids in one place; UIKit builds with them.

local UIStyle = {}

local Localizer = require(script.Parent.Localizer)

local FONT_EN = {
	-- window titles, money, big numbers. Bold: English looks the same, but Hangul (a fallback font) comes out bold
	-- instead of thin
	Title = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Bold),
	Body = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.ExtraBold),
	Bold = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Heavy),
}
-- Korean mode (wr-uidesign A⑦): digits and Latin letters come from BuilderSans too, so they sit with the Hangul instead of
-- Fredoka's round shapes; only titles / amounts / buttons stay ExtraBold, descriptions go one step lower
local FONT_KO = {
	Title = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.ExtraBold),
	Body = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
	Bold = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Heavy),
}
-- UIStyle.Font.Title etc. answer for the language the screen is in now
UIStyle.Font = setmetatable({}, {
	__index = function(_, role: string)
		return (if Localizer.lang == "ko" then FONT_KO else FONT_EN)[role]
	end,
}) :: any

-- a label made in one language's fonts, in the other's (UIKit calls it for every label on a language change)
function UIStyle.refont(f: Font, from: string, to: string): Font?
	local a = if from == "ko" then FONT_KO else FONT_EN
	local b = if to == "ko" then FONT_KO else FONT_EN
	for role, font in a do
		if font.Family == f.Family and font.Weight == f.Weight then
			return b[role]
		end
	end
	return nil
end

local rgb = Color3.fromRGB
UIStyle.Color = {
	-- the red metal window frame
	Red = rgb(214, 40, 32),
	RedLight = rgb(240, 86, 66),
	RedDark = rgb(128, 20, 16),
	-- steel inner panel and list rows
	Steel = rgb(196, 202, 210),
	SteelLight = rgb(232, 235, 239),
	SteelDark = rgb(118, 126, 138),
	Row = rgb(244, 245, 247),
	RowEdge = rgb(186, 192, 200),
	-- dark plates (money bar, job card, tool slots)
	Plate = rgb(34, 38, 46),
	PlateLight = rgb(58, 64, 76),
	PlateEdge = rgb(120, 128, 142),
	-- bolts
	Bolt = rgb(206, 211, 218),
	BoltDark = rgb(84, 90, 100),
	-- hazard stripe
	Yellow = rgb(250, 200, 30),
	Black = rgb(30, 30, 32),
	-- buttons / tabs
	Green = rgb(54, 182, 62),
	GreenDark = rgb(26, 112, 34),
	Blue = rgb(38, 140, 232),
	BlueDark = rgb(18, 82, 164),
	Gray = rgb(112, 120, 132),
	GrayDark = rgb(62, 68, 78),
	Orange = rgb(236, 150, 34),
	OrangeDark = rgb(150, 86, 14),
	-- text
	White = rgb(255, 255, 255),
	Ink = rgb(32, 34, 40), -- dark text on steel / white rows
	InkSoft = rgb(92, 98, 110),
	Cash = rgb(110, 236, 96), -- money on a dark plate
	Price = rgb(30, 140, 48), -- money on a white row
	Outline = rgb(22, 18, 16), -- text outline
	Good = rgb(120, 240, 140),
	Bad = rgb(255, 120, 110),
	Gold = rgb(255, 210, 60),
}

-- button colour sets: face, lip (the darker bottom edge)
UIStyle.Button = {
	Green = { UIStyle.Color.Green, UIStyle.Color.GreenDark },
	Blue = { UIStyle.Color.Blue, UIStyle.Color.BlueDark },
	Gray = { UIStyle.Color.Gray, UIStyle.Color.GrayDark },
	Red = { UIStyle.Color.Red, UIStyle.Color.RedDark },
	Orange = { UIStyle.Color.Orange, UIStyle.Color.OrangeDark },
	Yellow = { UIStyle.Color.Yellow, rgb(170, 120, 10) },
}

-- motion (YouTube notes 17: % scale, elastic release, fade + short slide)
UIStyle.Anim = {
	Hover = 1.1,
	Press = 0.9,
	HoverTime = 0.12,
	PressTime = 0.07,
	ReleaseTime = 0.45, -- elastic back to 1
	OpenTime = 0.2,
	Slide = 0.04, -- windows slide up this much of the screen while fading in
}

-- sizes as a share of the screen height (UIKit.px clamps them); text outline = share of the text height
UIStyle.Size = {
	Stroke = 0.006, -- plate / frame edges
	Bolt = 0.022,
	Corner = 0.022,
	TextOutline = 0.075, -- thin: small text keeps its strokes (GPT note)
}

-- wr-art kit_B (9-slice) and icons: rbxassetid strings after main uploads them. Empty = the code look / text.
UIStyle.Image = {
	WindowFrame = "",
	Plate = "",
	Hazard = "",
	ButtonGreen = "",
	ButtonBlue = "",
	ButtonGray = "",
	ClockFace = "", -- Ella's midnight clock face, no hands (MidnightClock; wr-art) — empty = the code look
	-- the polish screen (Scrub kind "Polish", wr-art art/ui/scratch/): the scratch marks and the polished shine, sliced per column
	-- scratch_marks_A.png 1024x512: 3 lines rising to the right, thicker than B (123246385286191: B's 4 thin lines went
	-- faint on a phone — polish3 decision)
	Scratch = "rbxassetid://115482987106213",
	PolishShine = "rbxassetid://128017618682570", -- polish_shine.png 512x512
}
UIStyle.Icon = {
	-- parts (art/ui/icons/<file>.png)
	Battery = "rbxassetid://133586604195603", -- battery.png
	BrakePads = "rbxassetid://82719775620061", -- brake_pads.png
	Wheel = "rbxassetid://88763403133723", -- wheel.png
	Hood = "rbxassetid://72627436620550", -- hood.png
	Bumper = "rbxassetid://80306861835337", -- front_bumper.png (the parts counter has one Bumper kind)
	BumperRear = "rbxassetid://94902967697878", -- rear_bumper.png
	Radiator = "rbxassetid://113731861676651", -- radiator.png
	Muffler = "rbxassetid://80204346427721", -- muffler.png
	-- tools (hot bar slots: Hand = bare hands)
	Hand = "rbxassetid://106273723467245", -- open-palm work glove (user pick 10-21: the R15 hand read as an eraser at 64 px)
	Scanner = "rbxassetid://72431958316249", -- obd_reader.png (same picture as OBDReader)
	Wrench = "rbxassetid://114980900301488", -- wrench.png
	ImpactWrench = "rbxassetid://125449570342297", -- impact_wrench.png
	OBDReader = "rbxassetid://72431958316249", -- obd_reader.png
	-- (uploaded 10-22, ids art/roblox_assets.json — the hot bar / shop showed their names only: wr-play TOP 6, wr-mini)
	FusePuller = "rbxassetid://86557170695683", -- fuse_puller.png
	PlugSocket = "rbxassetid://118206152445377", -- spark_plug_socket.png
	TrimTool = "rbxassetid://85851419568289", -- trim_tool.png
	HosePliers = "rbxassetid://128587776897983", -- hose_clamp_pliers.png
	DrainPan = "rbxassetid://75745096559420", -- drain_pan.png
	RatchetWrench = "rbxassetid://96618934642331", -- (10-23 wr-mini, GPT drawing)
	BatteryTester = "rbxassetid://86787804809467",
	Stethoscope = "rbxassetid://81796313235660",
	TorqueWrench = "rbxassetid://140143354048986",
	-- the tool shop's garage upgrades (10-23 wr-ui, GPT drawings in the same set; wr-uidesign A⑤)
	PartsShelfPlus = "rbxassetid://111005018005495", -- parts_shelf_plus.png
	Bay2 = "rbxassetid://135099843673742", -- bay2.png
	WheelBalancer = "rbxassetid://129572016902079", -- wheel_balancer.png
	HydraulicLift = "rbxassetid://81294257554104", -- hydraulic_lift.png
	RestorationBay = "rbxassetid://97478031531354", -- restoration_bay.png
	-- shared UI icons, small helper buttons only (main + GPT 10-21, notes/gpt/main/icons_free_pack_main_decision.md):
	-- free icon pack by gvesster, used as is (size only); files art/ui/icons_pack/, ids art/roblox_assets.json.
	-- Money, level, repair actions and rewards stay ours (text / Codex art).
	TutPointer = "rbxassetid://107170201336480", -- the tutorial pointer (art/ui/tutorial/tut_pointer.png, wr-art); empty = the code-drawn ball
	Settings = "rbxassetid://112141711900312", -- HUD settings button (square)
	Close = "rbxassetid://112433895262243", -- every window's close button
	Check = "rbxassetid://111414970334713", -- owned (upgrade rows)
	Lock = "rbxassetid://140219780447100", -- still locked (upgrade rows)
	Skip = "rbxassetid://139116263413375", -- skip tutorial, always next to its words (Tutorial.luau, wr-dev)
	Warning = "rbxassetid://73547572190394", -- in front of a "bad" notice (wrong part etc.)
	GlassSlipper = "", -- the trophy card's picture when there's no 3D model in ReplicatedStorage.Trophies (wr-art)
	ScrubFinger = "rbxassetid://132123215687737", -- the gloved pointing finger (art/ui/icons/scrub_finger.png): mini-game tap / Hold buttons, the scrub & polish cursor
	Invite = "rbxassetid://109002425981715", -- the HUD Invite button, next to settings (add_player.png, Add Player 1st); empty = the word
	-- store rows (StoreUI: UIStyle.Icon["Store" .. key]; art/ui/gamepass/512/<file>.png, ids art/roblox_assets.json)
	StorePayBoost = "rbxassetid://88064104888928", -- pay_boost.png
	StoreVIPMechanic = "rbxassetid://82104398417676", -- vip_mechanic.png
	StoreStarterPack = "rbxassetid://94261915375879", -- starter_pack.png
	StoreCashSmall = "rbxassetid://137349463922024", -- envelope_small.png
	StoreCashMedium = "rbxassetid://86588299140223", -- envelope_medium.png
	StoreCashBig = "rbxassetid://111447351068845", -- envelope_big.png
	StoreGoldTools = "rbxassetid://116797674843662", -- gold_tools.png
	StoreGarageRename = "rbxassetid://97148864478979", -- garage_rename.png
}

-- the "on the road" screens (Gate's moving screen) look like the loading screen: same blue, pattern, silhouettes,
-- logo and turning nut (ids copied from LoadingScreen.client.luau's ART / LOGO — it can't require modules)
UIStyle.Travel = {
	blue = rgb(52, 116, 210),
	ink = rgb(16, 30, 64),
	pattern = "rbxassetid://89043560912173",
	top = "rbxassetid://135309756868938",
	bottom = "rbxassetid://127993333692199",
	spinner = "rbxassetid://92413434154455",
	logo = "rbxassetid://93670065897289",
	logoKo = "", -- logo_ko (wr-art 10-22, "렌치 & 라이드 : 정비소 타이쿤"): same id as LoadingScreen's LOGO.ko; empty = the English logo
	logoKoShape = 2022 / 778, -- art/ui/brand/logo_ko.png width / height
}

-- a soft light disc behind the pictures in the dark tool slots (transparency; nil = none) — see
-- notes/gpt/wr-ui/hotbar_icons2_decision.md
UIStyle.SlotHalo = 0.85 :: number?

-- kit B pictures (wr-art, art/ui/kit_B/ + README: drawn area = rect, 9-slice centre = slice, both in file pixels).
-- (window / plate slices measured on the art: the README's 110 cut through the plate's bolt recess)
-- UIKit draws these when the id is set and falls back to the code look when it's "".
-- Roblox shrinks an upload to 1024 px on its long side, so the file pixels are scaled to the uploaded size here.
local function kit(id: string, file: { number }, rect: { number }, slice: { number }?, pressed: string?)
	local f = math.min(1, 1024 / math.max(file[1], file[2]))
	local function scaled(t: { number }?): { number }?
		if not t then
			return nil
		end
		local out = {}
		for i, v in t do
			out[i] = math.floor(v * f + 0.5)
		end
		return out
	end
	return { id = id, rect = scaled(rect), slice = scaled(slice), pressed = pressed }
end
UIStyle.Kit = {
	window = kit("rbxassetid://95808438067423", { 1254, 1254 }, { 7, 7, 1245, 1239 }, { 135, 135, 1119, 1119 }),
	plate = kit("rbxassetid://123124885512426", { 1254, 1254 }, { 17, 19, 1236, 1217 }, { 205, 205, 1049, 1049 }),
	slot = kit("rbxassetid://121738381147107", { 1254, 1254 }, { 46, 58, 1206, 1199 }),
	-- the slot's steel, sliced so it can be a wide card (the prompt card: no bolts on a small plate — GPT prompt_card_r1)
	slotWide = kit("rbxassetid://121738381147107", { 1254, 1254 }, { 46, 58, 1206, 1199 }, { 270, 270, 985, 985 }),
	slotSelected = kit("rbxassetid://100132967429341", { 1254, 1254 }, { 46, 58, 1206, 1199 }),
	hazard = kit("rbxassetid://102265639411770", { 2172, 724 }, { 0, 244, 2171, 463 }),
	-- buttons by UIStyle.Button style: the middle band is a thin strip, so the rounded ends keep their shape at any
	-- size (tabs are the same shape: Blue / Gray). A slice with 0 top / bottom margins draws only the picture's top
	-- half in Roblox (tested 10-21) — keep real margins on all four sides.
	Green = kit("rbxassetid://84162714858291", { 1942, 809 }, { 26, 89, 1914, 697 }, { 230, 360, 1710, 430 }, "rbxassetid://70888287355732"),
	Red = kit("rbxassetid://110788983896202", { 1254, 1254 }, { 35, 48, 1219, 1204 }, { 235, 249, 1017, 1003 }, "rbxassetid://107920949339090"),
	-- (blue / gray / orange pressed: redrawn 10-21 b3 on the same canvas and cell, only the lip gone — same slices)
	Blue = kit("rbxassetid://135104824304404", { 1959, 803 }, { 15, 136, 1944, 646 }, { 220, 361, 1739, 421 }, "rbxassetid://117535594253629"),
	Gray = kit("rbxassetid://120140018492535", { 1942, 809 }, { 13, 162, 1930, 631 }, { 203, 366, 1740, 426 }, "rbxassetid://75879454544396"),
	Orange = kit("rbxassetid://84011472288520", { 1920, 819 }, { 33, 121, 1887, 682 }, { 258, 371, 1662, 431 }, "rbxassetid://90232469694262"),
	-- tabs (UIKit.tabs: Kit "Tab" .. style)
	TabBlue = kit("rbxassetid://137950078668173", { 2020, 778 }, { 41, 110, 1983, 628 }, { 260, 340, 1760, 400 }),
	TabGray = kit("rbxassetid://93083701634048", { 2020, 778 }, { 41, 110, 1983, 628 }, { 260, 340, 1760, 400 }),
	-- the tutorial's task strip: yellow plate, hazard band on top, a bolt at each end (the middle band sits between
	-- the band and the bolts, so neither stretches)
	task = kit("rbxassetid://90830244739041", { 2172, 724 }, { 5, 138, 2167, 542 }, { 262, 252, 1910, 296 }),
	-- the receipt (Receipt.luau): paper, its torn bottom edge (tiled sideways), the barcode
	paper = kit("rbxassetid://88914075804406", { 1024, 1536 }, { 108, 21, 917, 1514 }, { 188, 101, 837, 1434 }),
	paperEdge = kit("rbxassetid://75584855933790", { 2073, 758 }, { 3, 234, 2072, 512 }),
	barcode = kit("rbxassetid://103590745858107", { 2172, 724 }, { 186, 186, 1987, 540 }),
}

-- restoration grade badges: our own art (wr-art, art/ui/badges/) — no words in them, so the grade word goes beside
UIStyle.Badge = {
	Bronze = "rbxassetid://74518944268780",
	Silver = "rbxassetid://78003254059312",
	Gold = "rbxassetid://133013813423463",
}
UIStyle.GradeColor = {
	Gold = rgb(255, 205, 70),
	Silver = rgb(205, 212, 222),
	Bronze = rgb(214, 140, 80),
	None = rgb(190, 196, 206),
}

return UIStyle
