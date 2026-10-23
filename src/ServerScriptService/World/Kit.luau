--!strict
-- World/Kit: small helpers for the map build code (wr-builder).
-- Everything is placed by its bounds (x0, y0, z0 .. x1, y1, z1) in studs, world space. Big shapes snap to 1,
-- details to 0.5 / 0.2 / 0.1 (never below 0.05). Front of the shop = -Z (toward the street).

local Kit = {}

-- Palette: US neighbourhood garage, casual look. 2~3 tones per surface + red / blue / yellow accents.
Kit.C = {
	grass = Color3.fromRGB(104, 150, 74),
	grassDark = Color3.fromRGB(88, 132, 64),
	asphalt = Color3.fromRGB(62, 64, 70),
	asphaltLot = Color3.fromRGB(74, 76, 82),
	asphaltWorn = Color3.fromRGB(92, 90, 88),
	lineWhite = Color3.fromRGB(236, 236, 228),
	lineYellow = Color3.fromRGB(242, 192, 44),
	sidewalk = Color3.fromRGB(196, 194, 188),
	curb = Color3.fromRGB(170, 168, 162),
	concrete = Color3.fromRGB(184, 182, 176),
	floor = Color3.fromRGB(190, 192, 194), -- light polished concrete (style_B)
	floorTile = Color3.fromRGB(214, 210, 200),
	wall = Color3.fromRGB(232, 228, 218), -- painted block, warm white
	wallInside = Color3.fromRGB(228, 230, 230),
	wainscot = Color3.fromRGB(196, 200, 204),
	trim = Color3.fromRGB(64, 70, 82), -- dark slate trim / coping
	plinth = Color3.fromRGB(150, 148, 144),
	roof = Color3.fromRGB(110, 112, 116),
	beam = Color3.fromRGB(120, 126, 136),
	shutter = Color3.fromRGB(214, 218, 224),
	shutterBox = Color3.fromRGB(150, 156, 166),
	frame = Color3.fromRGB(70, 74, 82), -- window / door frames
	glass = Color3.fromRGB(150, 196, 220),
	door = Color3.fromRGB(96, 104, 118),
	red = Color3.fromRGB(214, 40, 36),
	redDark = Color3.fromRGB(160, 30, 28),
	blue = Color3.fromRGB(30, 80, 200),
	pegboard = Color3.fromRGB(112, 116, 124),
	steel = Color3.fromRGB(200, 204, 210),
	yellow = Color3.fromRGB(246, 196, 40),
	metal = Color3.fromRGB(128, 134, 142),
	metalDark = Color3.fromRGB(78, 82, 90),
	wood = Color3.fromRGB(176, 132, 88),
	rubber = Color3.fromRGB(34, 34, 38),
	cardboard = Color3.fromRGB(196, 158, 108),
	seat = Color3.fromRGB(86, 130, 196),
	pink = Color3.fromRGB(255, 105, 180), -- placeholder (not built yet)
	marker = Color3.fromRGB(0, 255, 120),
	neighbour = { Color3.fromRGB(176, 108, 86), Color3.fromRGB(200, 190, 170), Color3.fromRGB(150, 160, 170),
		Color3.fromRGB(190, 170, 140), Color3.fromRGB(160, 120, 100) },
}

local M = Enum.Material
Kit.M = {
	smooth = M.SmoothPlastic,
	plastic = M.Plastic,
	concrete = M.Concrete,
	asphalt = M.Asphalt,
	pavement = M.Pavement,
	grass = M.Grass,
	brick = M.Brick,
	metal = M.Metal,
	diamond = M.DiamondPlate,
	glass = M.Glass,
	wood = M.Wood,
	fabric = M.Fabric,
	neon = M.Neon,
}

export type Opts = {
	collide: boolean?,
	transparency: number?,
	shadow: boolean?,
	shape: string?, -- "wedge" | "cyl" | "ball"
	class: string?, -- e.g. "Seat", "SpawnLocation"
}

local function finish(p: BasePart, name: string, color: Color3, mat: Enum.Material?, opts: Opts?)
	p.Name = name
	p.Anchored = true
	p.Color = color
	p.Material = mat or M.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if opts then
		if opts.collide == false then
			p.CanCollide = false
		end
		if opts.transparency then
			p.Transparency = opts.transparency
		end
		if opts.shadow == false then
			p.CastShadow = false
		end
	end
end

local function newPart(opts: Opts?): BasePart
	local cls = opts and opts.class
	if cls then
		return Instance.new(cls :: any) :: BasePart
	end
	if opts and opts.shape == "wedge" then
		return Instance.new("WedgePart")
	end
	local p = Instance.new("Part")
	if opts and opts.shape == "cyl" then
		p.Shape = Enum.PartType.Cylinder
	elseif opts and opts.shape == "ball" then
		p.Shape = Enum.PartType.Ball
	end
	return p
end

-- part by size + CFrame
function Kit.part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, opts: Opts?): BasePart
	local p = newPart(opts)
	p.Size = size
	p.CFrame = cf
	finish(p, name, color, mat, opts)
	p.Parent = parent
	return p
end

-- axis-aligned box by bounds
function Kit.box(parent: Instance, name: string, x0: number, y0: number, z0: number, x1: number, y1: number, z1: number,
	color: Color3, mat: Enum.Material?, opts: Opts?): BasePart
	local size = Vector3.new(math.abs(x1 - x0), math.abs(y1 - y0), math.abs(z1 - z0))
	local cf = CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
	return Kit.part(parent, name, size, cf, color, mat, opts)
end

-- upright cylinder (axis = Y): centre x,z, bottom y0, top y1, diameter d
function Kit.post(parent: Instance, name: string, x: number, z: number, y0: number, y1: number, d: number, color: Color3,
	mat: Enum.Material?, opts: Opts?): BasePart
	-- copy: callers share option tables (e.g. a DECO = { collide = false } constant); writing shape into theirs
	-- turned every later box made with that table into a cylinder
	local o: Opts = { shape = "cyl" }
	if opts then
		o.collide, o.transparency, o.shadow, o.class = opts.collide, opts.transparency, opts.shadow, opts.class
	end
	return Kit.part(parent, name, Vector3.new(y1 - y0, d, d), CFrame.new(x, (y0 + y1) / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
		color, mat, o)
end

-- a box running from point a to point b (beams, arms, braces). w = width (sideways), h = height (up-ish)
function Kit.rod(parent: Instance, name: string, a: Vector3, b: Vector3, w: number, h: number, color: Color3,
	mat: Enum.Material?, opts: Opts?): BasePart
	local len = (b - a).Magnitude
	local mid = (a + b) / 2
	local up = math.abs((b - a).Unit.Y) > 0.99 and Vector3.xAxis or Vector3.yAxis
	return Kit.part(parent, name, Vector3.new(w, h, len), CFrame.lookAt(mid, b, up), color, mat, opts)
end

-- invisible contract marker. Position = the floor point (y = floor top), LookVector = the facing named in
-- docs/specs/world_contract.md. Not collidable, not queryable, not touchable.
function Kit.marker(parent: Instance, name: string, pos: Vector3, look: Vector3?, size: Vector3?): BasePart
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Transparency = 1
	p.Size = size or Vector3.new(1, 0.2, 1)
	p.Color = Kit.C.marker
	p.Material = M.SmoothPlastic
	local dir = look or Vector3.new(0, 0, -1)
	p.CFrame = CFrame.lookAt(pos, pos + dir)
	p:SetAttribute("Marker", true)
	p.Parent = parent
	return p
end

-- pink "not built yet" block (RoBuilder way): see-through, no collision, no shadow
function Kit.placeholder(parent: Instance, name: string, x0: number, y0: number, z0: number, x1: number, y1: number, z1: number): BasePart
	local p = Kit.box(parent, name, x0, y0, z0, x1, y1, z1, Kit.C.pink, M.SmoothPlastic, { collide = false, transparency = 0.55, shadow = false })
	p.CanQuery = false
	p.CanTouch = false
	p:SetAttribute("Placeholder", true)
	return p
end

function Kit.model(parent: Instance?, name: string): Model
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

function Kit.folder(parent: Instance?, name: string): Folder
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

-- text on a part face (signs). English = original text; outline so it reads on any background.
function Kit.label(part: BasePart, face: Enum.NormalId, text: string, color: Color3, stroke: Color3?, font: Enum.Font?): SurfaceGui
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Label"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.6
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(0.96, 0.9)
	t.Position = UDim2.fromScale(0.02, 0.05)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = font or Enum.Font.FredokaOne
	t.TextColor3 = color
	t.TextStrokeColor3 = stroke or Color3.fromRGB(30, 30, 36)
	t.TextStrokeTransparency = stroke and 0 or 1
	t.Text = text
	t.Parent = gui
	gui.Parent = part
	return gui
end

-- small deterministic "random" (same map every build)
function Kit.rng(seed: number): () -> number
	local r = Random.new(seed)
	return function()
		return r:NextNumber()
	end
end

return Kit
