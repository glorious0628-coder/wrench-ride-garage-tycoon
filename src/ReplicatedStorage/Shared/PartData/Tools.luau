-- The hand tools (docs/design/full_teardown.md v0.1 §0-1 / §4): what each undoes (PartData/Fasteners names), how
-- fast, which is better (rank: of the owned tools that fit, the highest is picked), and for the free ones the level
-- they come at. Read while Config.Features.ToolMatch is on: a fastener only turns with a tool that `does` it (or bare
-- hands when the fastener says hand) — the server picks the best owned one by itself (§4-1 "picked for you").
--   use      = "hold" (press and hold in the work view, a click outside) | "sweep" (hold and pass over them)
--   interval = seconds between two fasteners (the server's rate limit)
--   free     = given at `level` (with a card), only once a live part needs it; bought ones come from Shared/Equipment
--   enabled  = false keeps a tool out (its 3D / icon not good enough yet) — what it does falls to the next tool
--   mesh     = ReplicatedStorage.CarMeshes.Tool_<mesh> once baked (wr-dev plan §4); nil = the block stand-in
--   block    = the stand-in: handle size + colour, and a head piece (size, offset along the handle, colour)

return {
	Wrench = { does = { "Bolt", "LugNut", "Terminal", "DrainPlug" }, rank = 1, use = "hold", interval = 0.32, enabled = true },
	RatchetWrench = { does = { "Bolt", "LugNut", "Terminal", "DrainPlug" }, rank = 2, use = "sweep", interval = 0.22, enabled = true },
	ImpactWrench = { does = { "Bolt", "BoltHeavy", "LugNut" }, rank = 3, use = "sweep", interval = 0.09, enabled = true },
	FusePuller = {
		does = { "FusePull" }, rank = 1, use = "hold", interval = 0.32, enabled = true, free = true, level = 4,
		mesh = "FusePuller", grip = { pos = Vector3.new(-0.1081, 0, 0), bbox = Vector3.new(0.001, 0, 0), axis = Vector3.new(1, 0, 0), sec = Vector3.new(0, 0, -1) }, -- art/3d/tools_v2/fuse_puller/*_attachments.json
		block = { size = Vector3.new(0.2, 0.2, 0.9), color = Color3.fromRGB(235, 235, 235), head = { size = Vector3.new(0.3, 0.12, 0.3), at = -0.5, color = Color3.fromRGB(235, 235, 235) } },
	},
	PlugSocket = {
		does = { "SparkPlug" }, rank = 2, use = "hold", interval = 0.32, enabled = true, free = true, level = 5,
		mesh = "PlugSocket", grip = { pos = Vector3.new(0, 0.683, 0), bbox = Vector3.new(0, 0.55, 0), axis = Vector3.new(0, 1, 0), sec = Vector3.new(0, 0, -1) }, -- plug_socket (hand on the red sleeve, socket hangs below)
		block = { size = Vector3.new(0.25, 0.25, 1.8), color = Color3.fromRGB(190, 192, 198), head = { size = Vector3.new(0.35, 0.35, 0.7), at = -1.1, color = Color3.fromRGB(150, 152, 158) } },
	},
	TrimTool = {
		does = { "Clip" }, rank = 1, use = "hold", interval = 0.25, enabled = true, free = true, level = 6,
		mesh = "TrimTool", grip = { pos = Vector3.new(-0.31, 0, 0), bbox = Vector3.new(-0.001, 0, 0.0083), axis = Vector3.new(1, 0, 0), sec = Vector3.new(0, 0, -1) }, -- trim_tool
		block = { size = Vector3.new(0.2, 0.08, 1.4), color = Color3.fromRGB(245, 140, 40), head = { size = Vector3.new(0.35, 0.06, 0.25), at = -0.8, color = Color3.fromRGB(245, 140, 40) } },
	},
	HosePliers = {
		does = { "HoseClamp" }, rank = 1, use = "hold", interval = 0.4, enabled = true, free = true, level = 6,
		mesh = "HosePliers", grip = { pos = Vector3.new(-0.6565, 0, 0), bbox = Vector3.new(-0.2089, 0, 0), axis = Vector3.new(1, 0, 0), sec = Vector3.new(0, 0, -1) }, -- hose_pliers (between the two red grips)
		block = { size = Vector3.new(0.22, 0.22, 1.5), color = Color3.fromRGB(200, 50, 45), head = { size = Vector3.new(0.4, 0.15, 0.35), at = -0.9, color = Color3.fromRGB(160, 162, 168) } },
	},
	-- E2: the knuckle bolts (290 N·m) — free with the strut job's level, the impact wrench does them faster (§0-2)
	BreakerBar = {
		does = { "BoltHeavy" }, rank = 1, use = "hold", interval = 0.6, enabled = true, free = true, level = 9,
		block = { size = Vector3.new(0.22, 0.22, 2.2), color = Color3.fromRGB(60, 62, 66), head = { size = Vector3.new(0.35, 0.35, 0.4), at = -1.2, color = Color3.fromRGB(150, 152, 158) } },
	},
	-- the oil job (full_teardown §0-1 ④, Lv3): the under-cover panel's screws, then the filter. Both are given only
	-- once a live part needs them (ToolKit.grantFree `needed`), so nothing comes before the job's parts are in the game.
	Screwdriver = {
		does = { "Screw" }, rank = 1, use = "hold", interval = 0.3, enabled = true, free = true, level = 3,
		block = { size = Vector3.new(0.18, 0.18, 1.3), color = Color3.fromRGB(240, 190, 30), head = { size = Vector3.new(0.08, 0.08, 0.6), at = -0.9, color = Color3.fromRGB(190, 192, 198) } },
	},
	-- (a spin-on filter: a cap-style / band filter wrench — the stand-in until its 3D: wr-art 6-view -> Tool_FilterWrench)
	FilterWrench = {
		does = { "OilFilter" }, rank = 1, use = "hold", interval = 0.4, enabled = true, free = true, level = 3,
		block = { size = Vector3.new(0.22, 0.22, 1.3), color = Color3.fromRGB(200, 60, 40), head = { size = Vector3.new(0.5, 0.5, 0.3), at = -0.8, color = Color3.fromRGB(150, 152, 158) } },
	},
	-- the drain pan is bay equipment (Fluid:Coolant, piece E), not a hand tool: no row here
}
