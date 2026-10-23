--!strict
-- World/Interior (wr-builder, 10-22 user: "the shop looks cheap" -> GPT mock art/concepts/interior/interior_better_a.png):
-- Bay 1 made to read as a real US neighbourhood shop without adding many parts (Lv16 is near the 5,500 budget).
-- Runs after ShopDetail / LivedIn: re-dresses what they made. Looks only, no contract names.
--   walls: painted concrete block (Brick material) + a dark lower band, no empty frames
--   floor: concrete with saw-cut joints + a steel drain grate; the round grey stain discs are gone — old oil stains
--          and tyre marks come back as faded images (Interior.DECALS ids) on the floor carrier
--   ceiling: steel deck + more joists + a conduit run; walls: fire extinguisher + sign, hose reel, tool board,
--          calendar, small-parts drawer cabinet; floor: trash can, drain pan.

local Kit = require(script.Parent.Kit)
local C, M = Kit.C, Kit.M
local box = Kit.box
local GearportProps = require(script.Parent.GearportProps)

local Interior = {}

local F = 0.2
local BAND = Color3.fromRGB(60, 65, 74) -- dark lower wall band (the mock's slate grey; v31 a touch bluer + lighter)
local BAND_MORTAR = Color3.fromRGB(92, 98, 108)
local BLOCK = Color3.fromRGB(232, 232, 231) -- painted block (v31: near-neutral light grey; 228/220/214 read beige next to the mock, GPT r1 agreed)
local JOINT = Color3.fromRGB(72, 72, 70)
local DECO = { collide = false, shadow = false }
local WARM = Color3.fromRGB(255, 190, 120) -- the bench's warm light (v35)

-- uploaded decal image ids (rbxassetid numbers as strings); "" = not uploaded yet
-- image ids (decals 76227391480748 / 77053110975673 / 107203955310726 resolved to their images, art/roblox_assets.json)
Interior.DECALS = { oilOldA = "118791203805564", oilOldB = "77489039319025", tyreMarks = "93740613454385" }
-- Decal.Color3 multiplies the image: these pull each image's average to a neutral dark grey (~38-50)
local DECAL_TINT = {
	oilOldA = Color3.new(0.47, 0.64, 0.9),
	oilOldB = Color3.new(0.36, 0.48, 0.68),
	tyreMarks = Color3.new(0.54, 0.64, 0.78),
}

local function touchesBay(p: BasePart): boolean
	local q, h = p.Position, p.Size / 2
	return q.X - h.X < 14.05 and q.X + h.X > -14 and q.Z - h.Z < 20 and q.Z + h.Z > -20
end

-- painted concrete block: mortar lines drawn on the bay-facing face (Roblox's Brick material read as a photo of red
-- brick). Rows 1.4 studs, blocks 2.8 long, every other row shifted half a block. A tile texture can replace this later.
local MORTAR = Color3.fromRGB(168, 168, 166)
local function blockLines(p: BasePart, face: Enum.NormalId, faceW: number, faceH: number, mortar: Color3?, noShade: boolean?)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "BlockLines"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 12
	gui.LightInfluence = 1
	local col = mortar or MORTAR
	local RH, BW = 1.4, 2.8
	local rows = math.floor(faceH / RH)
	for r = 1, rows do
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.BackgroundColor3 = col
		f.Position = UDim2.new(0, 0, 1 - r * RH / faceH, 0)
		f.Size = UDim2.new(1, 0, 0, 1)
		f.Parent = gui
	end
	for r = 0, rows - 1 do
		local off = (r % 2) * BW / 2
		local x = off
		while x < faceW do
			if x > 0.2 then
				local f = Instance.new("Frame")
				f.BorderSizePixel = 0
				f.BackgroundColor3 = col
				f.Position = UDim2.new(x / faceW, 0, 1 - (r + 1) * RH / faceH, 0)
				f.Size = UDim2.new(0, 1, RH / faceH, 0)
				f.Parent = gui
			end
			x += BW
		end
	end
	if noShade then
		gui.Parent = p
		return
	end
	-- the lower wall a little darker (light falls off toward the floor): one gradient frame
	local shade = Instance.new("Frame")
	shade.BorderSizePixel = 0
	shade.BackgroundColor3 = Color3.fromRGB(40, 42, 48)
	shade.Position = UDim2.fromScale(0, 0.45)
	shade.Size = UDim2.fromScale(1, 0.55)
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Transparency = NumberSequence.new(1, 0.72)
	g.Parent = shade
	shade.Parent = gui
	-- v31 (GPT r2: the mock's wall tops go dark into the ceiling): the top 22% fades to a shadow under the deck
	local top = Instance.new("Frame")
	top.BorderSizePixel = 0
	top.BackgroundColor3 = Color3.fromRGB(34, 34, 38)
	top.Size = UDim2.fromScale(1, 0.22)
	local tg = Instance.new("UIGradient")
	tg.Rotation = 90
	tg.Transparency = NumberSequence.new(0.5, 1)
	tg.Parent = top
	top.Parent = gui
	gui.Parent = p
end

local function inBay(p: BasePart): boolean
	local q = p.Position
	return q.X > -14 and q.X < 14 and q.Z > -20 and q.Z < 20 and q.Y < 20.5
end

-- picture drawn with frames on a flat board (no image asset, no text): rects = { {x, y, w, h, color} } in 0..1
local function drawing(part: BasePart, face: Enum.NormalId, bg: Color3, rects: { { any } })
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Drawing"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.8
	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = bg
	root.BorderSizePixel = 0
	root.Parent = gui
	for _, r in ipairs(rects) do
		local f = Instance.new("Frame")
		f.Position = UDim2.fromScale(r[1], r[2])
		f.Size = UDim2.fromScale(r[3], r[4])
		f.BackgroundColor3 = r[5]
		f.BorderSizePixel = 0
		if r[6] then
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(r[6], 0)
			c.Parent = f
		end
		f.Parent = root
	end
	gui.Parent = part
end

-- a hanging shop rag's folds: a few soft darker creases down it + a hem line (casual, drawn)
local function RAG_FOLDS(dark: Color3): { { any } }
	return {
		{ 0.3, 0.06, 0.06, 0.86, dark, 0.5 },
		{ 0.68, 0.2, 0.05, 0.6, dark, 0.5 },
	}
end

-- waiting room pictures (v35): a SurfaceGui root on a board's face, frames in scale, a TextLabel for words
local function sheet(part: BasePart, face: Enum.NormalId, bg: Color3): Frame
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Picture"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0.8
	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = bg
	root.BorderSizePixel = 0
	root.Parent = gui
	gui.Parent = part
	return root
end
local function fr(parent: Instance, x: number, y: number, w: number, h: number, col: Color3, round: number?, square: boolean?): Frame
	local f = Instance.new("Frame")
	f.Position = UDim2.fromScale(x, y)
	f.Size = UDim2.fromScale(w, h)
	f.BackgroundColor3 = col
	f.BorderSizePixel = 0
	if round then
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(round, 0)
		c.Parent = f
	end
	if square then -- a circle stays round on a non-square sheet (width rules)
		local a = Instance.new("UIAspectRatioConstraint")
		a.AspectRatio = 1
		a.DominantAxis = Enum.DominantAxis.Width
		a.Parent = f
	end
	f.Parent = parent
	return f
end
local function words(parent: Instance, x: number, y: number, w: number, h: number, text: string, col: Color3, font: Enum.Font)
	local t = Instance.new("TextLabel")
	t.Position = UDim2.fromScale(x, y)
	t.Size = UDim2.fromScale(w, h)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = font
	t.TextColor3 = col
	t.Text = text
	t.Parent = parent
end

-- the cross-wall poster (3 x 4): a free tyre check, a big tyre on shop blue
local function posterTires(b: BasePart)
	local root = sheet(b, Enum.NormalId.Front, Color3.fromRGB(40, 86, 170))
	words(root, 0.08, 0.05, 0.84, 0.13, "FREE", Color3.fromRGB(255, 214, 64), Enum.Font.FredokaOne)
	words(root, 0.06, 0.18, 0.88, 0.11, "TIRE CHECK", Color3.new(1, 1, 1), Enum.Font.FredokaOne)
	local tyre = fr(root, 0.15, 0.35, 0.7, 0.7, Color3.fromRGB(34, 34, 38), 0.5, true)
	fr(tyre, 0.25, 0.25, 0.5, 0.5, Color3.fromRGB(176, 182, 190), 0.5)
	fr(tyre, 0.42, 0.42, 0.16, 0.16, Color3.fromRGB(70, 74, 80), 0.5)
	for i = 0, 7 do -- tread blocks round the edge
		local a = i * math.pi / 4
		local q = fr(tyre, 0.5 + 0.44 * math.cos(a) - 0.04, 0.5 + 0.44 * math.sin(a) - 0.04, 0.08, 0.08, Color3.fromRGB(60, 60, 66), 0.2)
		q.Rotation = math.deg(a)
	end
	words(root, 0.1, 0.88, 0.8, 0.08, "Ask at the desk", Color3.fromRGB(220, 230, 250), Enum.Font.GothamBold)
end

-- the framed certificate (2.2 x 1.6): cream paper, title, signature lines, a gold seal with ribbons
local function certificate(b: BasePart)
	local root = sheet(b, Enum.NormalId.Front, Color3.fromRGB(248, 242, 224))
	local edge = fr(root, 0.04, 0.05, 0.92, 0.9, Color3.fromRGB(248, 242, 224))
	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(196, 160, 72)
	st.Thickness = 3
	st.Parent = edge
	words(root, 0.12, 0.12, 0.76, 0.17, "CERTIFIED", Color3.fromRGB(60, 52, 40), Enum.Font.Merriweather)
	words(root, 0.18, 0.31, 0.64, 0.1, "Auto Repair Technician", Color3.fromRGB(96, 86, 70), Enum.Font.Merriweather)
	fr(root, 0.14, 0.72, 0.3, 0.015, Color3.fromRGB(120, 112, 100))
	fr(root, 0.14, 0.62, 0.22, 0.04, Color3.fromRGB(70, 90, 140), 0.5) -- a scrawl of ink
	fr(root, 0.14, 0.5, 0.42, 0.02, Color3.fromRGB(170, 162, 150))
	fr(root, 0.66, 0.73, 0.06, 0.2, Color3.fromRGB(190, 44, 40)).Rotation = 12
	fr(root, 0.74, 0.73, 0.06, 0.2, Color3.fromRGB(190, 44, 40)).Rotation = -12
	local seal = fr(root, 0.62, 0.5, 0.22, 0.22, Color3.fromRGB(214, 172, 64), 0.5, true)
	fr(seal, 0.2, 0.2, 0.6, 0.6, Color3.fromRGB(236, 200, 96), 0.5)
end

-- where the snapshots were taken (frames in the photo's 0..1): ground line + a few shapes behind the car
local SKY, ROAD, BLOCK_W = Color3.fromRGB(170, 206, 232), Color3.fromRGB(104, 106, 112), Color3.fromRGB(214, 212, 206)
local SNAP_PLACES: { { ground: number, bits: { { any } } } } = {
	{ ground = 0.8, bits = { -- the street: a brick building, a tree
		{ 0.0, 0.0, 1, 0.8, SKY }, { 0.55, 0.12, 0.4, 0.68, Color3.fromRGB(168, 88, 70) }, { 0.62, 0.22, 0.1, 0.12, Color3.fromRGB(230, 226, 210) },
		{ 0.78, 0.22, 0.1, 0.12, Color3.fromRGB(230, 226, 210) }, { 0.08, 0.3, 0.22, 0.22, Color3.fromRGB(84, 140, 70), 0.5, true },
		{ 0.17, 0.5, 0.04, 0.3, Color3.fromRGB(110, 80, 56) }, { 0, 0.8, 1, 0.2, ROAD } } },
	{ ground = 0.86, bits = { -- in front of our bay door (block wall, the shutter's slats)
		{ 0.0, 0.0, 1, 0.86, BLOCK_W }, { 0.2, 0.1, 0.6, 0.76, Color3.fromRGB(190, 196, 204) }, { 0.2, 0.3, 0.6, 0.02, Color3.fromRGB(150, 156, 166) },
		{ 0.2, 0.5, 0.6, 0.02, Color3.fromRGB(150, 156, 166) }, { 0.2, 0.7, 0.6, 0.02, Color3.fromRGB(150, 156, 166) }, { 0, 0.86, 1, 0.14, Color3.fromRGB(150, 146, 142) } } },
	{ ground = 0.74, bits = { -- a sunny lot: low sun, a lamp post, the kerb
		{ 0.0, 0.0, 1, 0.74, Color3.fromRGB(240, 206, 150) }, { 0.7, 0.08, 0.16, 0.16, Color3.fromRGB(255, 240, 190), 0.5, true },
		{ 0.12, 0.1, 0.03, 0.64, Color3.fromRGB(70, 74, 80) }, { 0.08, 0.08, 0.12, 0.04, Color3.fromRGB(70, 74, 80) },
		{ 0, 0.74, 1, 0.06, Color3.fromRGB(200, 196, 188) }, { 0, 0.8, 1, 0.2, ROAD } } },
	{ ground = 0.82, bits = { -- by the junkyard fence at dusk
		{ 0.0, 0.0, 1, 0.82, Color3.fromRGB(120, 130, 170) }, { 0, 0.5, 1, 0.32, Color3.fromRGB(96, 100, 104) },
		{ 0.1, 0.5, 0.02, 0.32, Color3.fromRGB(70, 72, 76) }, { 0.4, 0.5, 0.02, 0.32, Color3.fromRGB(70, 72, 76) },
		{ 0.7, 0.5, 0.02, 0.32, Color3.fromRGB(70, 72, 76) }, { 0, 0.82, 1, 0.18, Color3.fromRGB(122, 110, 96) } } },
}
-- car box per photo: size, x shift, y shift, facing (+1 right / -1 left): some close, some far, off-centre
local SNAP_FRAMING = { { 0.9, 0.0, 0.0, 1 }, { 1.05, 0.06, 0.04, -1 }, { 0.7, -0.12, 0.0, 1 }, { 0.82, 0.1, 0.02, -1 }, { 1.0, -0.04, 0.03, 1 },
	{ 0.62, 0.14, 0.0, -1 }, { 0.95, 0.0, 0.02, -1 }, { 0.76, -0.1, 0.0, 1 }, { 1.1, 0.02, 0.05, 1 }, { 0.68, 0.08, 0.0, -1 } }

-- the photo board over the seats (11.4 x 4.4 cork, "OUR CUSTOMERS"): pinned instant photos of cars that came in
-- (the shop's own kinds: sedans, hatches, pickups, vans), each a little turned
local function customerPhotos(board: BasePart)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Photos"
	gui.Face = Enum.NormalId.Left
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.8
	local W, H = 11.4, 4.4
	local cars: { { any } } = {
		-- body colour, kind, backdrop
		{ Color3.fromRGB(64, 182, 176), "sedan", Color3.fromRGB(170, 206, 232) },
		{ Color3.fromRGB(206, 52, 46), "pickup", Color3.fromRGB(196, 190, 180) },
		{ Color3.fromRGB(226, 182, 64), "sedan", Color3.fromRGB(170, 206, 232) },
		{ Color3.fromRGB(240, 236, 226), "van", Color3.fromRGB(150, 160, 170) },
		{ Color3.fromRGB(56, 96, 176), "hatch", Color3.fromRGB(170, 206, 232) },
		{ Color3.fromRGB(232, 134, 42), "sedan", Color3.fromRGB(196, 190, 180) },
		{ Color3.fromRGB(96, 150, 90), "pickup", Color3.fromRGB(170, 206, 232) },
		{ Color3.fromRGB(150, 156, 166), "sedan", Color3.fromRGB(196, 190, 180) },
		{ Color3.fromRGB(140, 70, 140), "hatch", Color3.fromRGB(170, 206, 232) },
		{ Color3.fromRGB(46, 48, 54), "van", Color3.fromRGB(196, 190, 180) },
	}
	local turns = { -5, 3, -2, 6, -4, 2, 5, -3, 4, -6 }
	local PW, PH = 1.5, 1.8
	for i, c in ipairs(cars) do
		local col, row = (i - 1) % 5, math.floor((i - 1) / 5)
		local cz = 0.9 + col * 2.35 + (if row == 1 then 0.6 else 0)
		local cy = 0.35 + row * 2.1
		local p = fr(gui, (cz - PW / 2) / W, cy / H, PW / W, PH / H, Color3.fromRGB(250, 250, 246))
		p.Rotation = turns[i]
		-- (GPT fix11 r1: ten copies of one icon read as cards, not snapshots -> each its own place, framing and side)
		local ph = fr(p, 0.08, 0.07, 0.84, 0.66, c[3])
		ph.ClipsDescendants = true
		local place = SNAP_PLACES[(i - 1) % #SNAP_PLACES + 1]
		for _, e in ipairs(place.bits) do
			fr(ph, e[1], e[2], e[3], e[4], e[5], e[6], e[7])
		end
		local fs = SNAP_FRAMING[(i - 1) % #SNAP_FRAMING + 1] -- car box: scale, x offset, y offset, facing
		local cb = Instance.new("Frame")
		cb.BackgroundTransparency = 1
		cb.Size = UDim2.fromScale(fs[1], fs[1])
		cb.Position = UDim2.fromScale(0.5 - fs[1] / 2 + fs[2], place.ground - 0.78 * fs[1] + fs[3])
		cb.Parent = ph
		local flip = fs[4] < 0
		local function part(x: number, y: number, w: number, h: number, col: Color3, round: number?, sq: boolean?): Frame
			return fr(cb, if flip then 1 - x - w else x, y, w, h, col, round, sq)
		end
		local body, kind = c[1], c[2]
		local GLASS = Color3.fromRGB(196, 226, 246)
		if kind == "pickup" then
			part(0.06, 0.52, 0.88, 0.22, body, 0.25)
			part(0.4, 0.3, 0.3, 0.26, body, 0.25)
			part(0.45, 0.34, 0.2, 0.14, GLASS, 0.2)
		elseif kind == "van" then
			part(0.08, 0.26, 0.84, 0.48, body, 0.2)
			part(0.62, 0.32, 0.24, 0.16, GLASS, 0.2)
			part(0.14, 0.32, 0.4, 0.16, GLASS, 0.2)
		else
			local cabX, cabW = (if kind == "hatch" then 0.3 else 0.24), (if kind == "hatch" then 0.52 else 0.48)
			part(0.06, 0.5, 0.88, 0.24, body, 0.3)
			part(cabX, 0.3, cabW, 0.26, body, 0.35)
			part(cabX + 0.05, 0.34, cabW - 0.1, 0.13, GLASS, 0.25)
		end
		part(0.9, 0.56, 0.05, 0.06, Color3.fromRGB(255, 236, 170), 0.3) -- the headlamp shows which way it faces
		for _, wx in ipairs({ 0.14, 0.64 }) do
			local wh = part(wx, 0.62, 0.22, 0.22, Color3.fromRGB(30, 30, 34), 0.5, true)
			fr(wh, 0.3, 0.3, 0.4, 0.4, Color3.fromRGB(170, 176, 184), 0.5)
		end
		fr(p, 0.2, 0.82, 0.45, 0.04, Color3.fromRGB(120, 124, 136), 0.5) -- a pen scrawl on the strip
		fr(p, 0.44, -0.04, 0.12, 0.12, if i % 2 == 0 then Color3.fromRGB(206, 52, 46) else Color3.fromRGB(56, 96, 176), 0.5, true) -- the pin
	end
	gui.Parent = board
end

function Interior.build(garage: Model)
	local d = Kit.folder(garage, "Interior")

	-- 1. take away what read as cheap: round grey stain discs, empty frames, the thin blue stripe
	local gone = 0
	for _, p in ipairs(garage:GetDescendants()) do
		if p:IsA("BasePart") and inBay(p) then
			local n = p.Name
			if n == "OilStain" or n == "OilSpot" or n == "WainscotStripe" or n == "ArtFrame" or n == "TyreTrack" -- (tyre marks = decals)
				or (n == "ArtSlot" and string.sub((p:GetAttribute("ArtSlot") :: string?) or "", 1, 3) == "B1_") then
				p:Destroy()
				gone += 1
			end
		end
	end
	d:SetAttribute("Removed", gone)

	-- 2. walls: painted concrete block on the bay's walls, dark lower band
	local shell = garage:FindFirstChild("Building")
	if shell then
		for _, p in ipairs(shell:GetChildren()) do
			if p:IsA("BasePart") and touchesBay(p) and (p.Name == "BackWall" or p.Name == "ExpansionWallWest" or p.Name == "FrontWall"
				or p.Name == "BayHeader" or p.Name == "MidWall") then
				p.Color = BLOCK
				p.Material = M.concrete
				-- the face that looks into the bay (walls are axis-aligned boxes)
				local q, sz = p.Position, p.Size
				if p.Name == "ExpansionWallWest" then
					blockLines(p, Enum.NormalId.Right, sz.Z, sz.Y)
				elseif p.Name == "MidWall" then
					blockLines(p, Enum.NormalId.Left, sz.Z, sz.Y)
				elseif p.Name == "BackWall" and q.X < 14 then
					blockLines(p, Enum.NormalId.Front, sz.X, sz.Y)
				elseif p.Name == "FrontWall" and q.X < 14 or p.Name == "BayHeader" then
					blockLines(p, Enum.NormalId.Back, sz.X, sz.Y)
				end
			end
		end
		local slab = shell:FindFirstChild("FloorSlab") :: BasePart?
		if slab then
			-- v31: Concrete material (its fine cloudy grain reads as the mock's worn sealed slab) in a warm grey; the
			-- mock floor renders ~150/130/110 under its warm tubes. No Reflectance: any amount mirrors the outdoor
			-- sky (pale blue floor) in Voxel AND Future lighting (tested 10-22) — the shine is drawn (FloorPaint)
			slab.Material = M.concrete
			slab.Color = Color3.fromRGB(148, 140, 138) -- (renders ~158/138/118 next to the mock's 159/138/119)
			slab.Reflectance = 0
		end
	end
	local dress = garage:FindFirstChild("Dressing")
	if dress then
		for _, p in ipairs(dress:GetChildren()) do
			if p:IsA("BasePart") and p.Name == "Wainscot" and inBay(p) then
				p.Color = BAND
				p.Material = M.concrete
				p.Size = Vector3.new(p.Size.X, 3.4, p.Size.Z)
				p.Position = Vector3.new(p.Position.X, F + 1.7, p.Position.Z)
				-- v31 (main: "the mock's band reads as painted block, ours as a black strip"): the same block courses as
				-- the wall above, mortar a shade lighter than the paint, on the two big faces (thin = X or Z)
				local thinX = p.Size.X < p.Size.Z
				for _, face in ipairs(if thinX then { Enum.NormalId.Left, Enum.NormalId.Right } else { Enum.NormalId.Front, Enum.NormalId.Back }) do
					blockLines(p, face, if thinX then p.Size.Z else p.Size.X, p.Size.Y, BAND_MORTAR, true)
				end
			end
		end
	end

	-- 3. floor: saw-cut joints, cast-iron drain grate, decal slots for old stains / tyre marks
	-- everything painted / worn into the slab is drawn on ONE invisible carrier (v31: the joints were 5 parts + the
	-- sheen 1). Top-face SurfaceGui axes (probed 10-22): gui X runs along -Z from the +Z edge, gui Y along +X from -X.
	local X0, X1, Z0, Z1 = -12.9, 13.9, -18.9, 18.9
	local paint = Kit.part(d, "FloorPaint", Vector3.new(X1 - X0, 0.01, Z1 - Z0), CFrame.new((X0 + X1) / 2, F + 0.035, (Z0 + Z1) / 2),
		Color3.new(1, 1, 1), M.smooth, { collide = false, shadow = false, transparency = 1 })
	paint.CanQuery = false
	paint.CanTouch = false
	local pg = Instance.new("SurfaceGui")
	pg.Name = "Paint"
	pg.Face = Enum.NormalId.Top
	pg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	pg.PixelsPerStud = 16
	pg.LightInfluence = 1
	local function rect(x0: number, x1: number, z0: number, z1: number, col: Color3, alpha: number?, round: number?): Frame
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.BackgroundColor3 = col
		f.BackgroundTransparency = alpha or 0
		f.Position = UDim2.fromScale((Z1 - z1) / (Z1 - Z0), (x0 - X0) / (X1 - X0))
		f.Size = UDim2.fromScale((z1 - z0) / (Z1 - Z0), (x1 - x0) / (X1 - X0))
		if round then
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(round, 0)
			c.Parent = f
		end
		f.Parent = pg
		return f
	end
	-- (the mottling comes from the Concrete material's grain; drawn round patches read as the old stain discs)
	-- joints every ~9 studs (~9 ft: a 4" slab is cut every 8-12 ft in near-square panels, Home Depot / concretenetwork)
	for _, z in ipairs({ -10, -1, 8 }) do
		rect(X0, X1, z - 0.07, z + 0.07, JOINT)
	end
	for _, x in ipairs({ -4.5, 4.5 }) do
		rect(x - 0.07, x + 0.07, Z0, Z1, JOINT)
	end
	-- v32: the mock's 'L' of floor tape round the creeper + stand: a cross line from the west bay line (x -10.2,
	-- moved in section 7) to the wall, on the door side of them (painted, 0 parts)
	-- (v33: on the door side of the creeper's foot, z -3.02, so the board stands inside the 'L')
	rect(X0, -10.0, -3.6, -3.2, C.lineYellow)
	local bays = garage:FindFirstChild("Bays")
	local bay1 = bays and bays:FindFirstChild("Bay1")
	local drain = bay1 and bay1:FindFirstChild("Drain") :: BasePart?
	if drain then
		-- ductile / cast iron slotted grate (Zurn Z610 type): dark iron frame, black slots
		drain.Color = Color3.fromRGB(46, 48, 52)
		drain.Material = M.metal
		local bars: { { any } } = { { 0.04, 0.04, 0.92, 0.92, Color3.fromRGB(70, 72, 76) } }
		for i = 0, 6 do
			table.insert(bars, { 0.1 + i * 0.12, 0.1, 0.07, 0.8, Color3.fromRGB(14, 14, 16) } :: { any })
		end
		drawing(drain, Enum.NormalId.Top, Color3.fromRGB(46, 48, 52), bars)
	end
	-- old stains + tyre marks (v33, main 10-23 "the black blobs read as holes, the mock has faint grey marks spread
	-- wide"): image labels on their own SurfaceGui over the carrier instead of 13 decal parts. Faded far more (an old
	-- stain scrubbed for years goes pale grey; only the fresh drip under the engine stays darker), more of them, wider
	local stains: { { any } } = {
		-- key, x, z, width (x), depth (z), yaw, image transparency
		{ "oilOldA", -0.6, -2.4, 4.6, 3.6, 18, 0.62 }, -- under the engine at the car spot
		{ "oilOldB", 0.8, 5.2, 3.0, 2.4, -30, 0.62 }, -- under the rear axle
		{ "oilOldB", -8.0, -10.0, 2.2, 1.8, 64, 0.7 }, -- by the floor jack's rest
		{ "oilOldA", 6.8, 11.4, 2.6, 2.0, 140, 0.68 }, -- in front of the bench
		{ "oilOldB", -4.6, 1.2, 2.4, 2.0, 200, 0.7 },
		{ "oilOldA", 3.6, -8.8, 2.4, 2.0, 75, 0.74 },
		{ "oilOldB", 5.6, -1.4, 3.4, 2.8, 110, 0.7 },
		{ "oilOldA", -3.2, -9.4, 2.6, 2.0, 35, 0.76 }, -- (v34: the big near ones a size smaller)
		{ "oilOldB", 9.2, -13.2, 3.0, 2.4, 250, 0.74 },
		{ "oilOldA", -6.6, 6.8, 3.0, 2.4, 160, 0.72 },
		{ "oilOldB", -7.5, -3.5, 4.0, 3.2, 20, 0.8 },
		{ "oilOldA", 9.5, 3.5, 4.4, 3.4, 300, 0.8 },
		{ "oilOldB", -2.0, 12.0, 4.0, 3.0, 95, 0.8 },
		{ "oilOldA", 2.5, -14.0, 2.6, 2.2, 210, 0.82 },
		{ "oilOldB", 10.5, -6.5, 3.0, 2.6, 45, 0.8 },
		{ "oilOldA", -9.5, 12.5, 2.6, 2.2, 120, 0.8 },
		{ "tyreMarks", 0, -14.5, 8.6, 9, 0, 0.2 }, -- the way in through the door (v34: main "the floor went flat", GPT: faint at play distance)
		{ "tyreMarks", 0, 2, 8.6, 10, 180, 0.15 }, -- worn into the car spot
		{ "tyreMarks", 2.2, 12.6, 6, 5.5, 172, 0.45 }, -- off-line: a car once pulled up to the bench
		-- v35 (main's list "floor wear all alike"): small fresh drips where real ones fall — under the drum pump, the
		-- bench's vise end, by the drain, the cart's side, the creeper's wheels — darker than the old scrubbed stains
		{ "oilOldB", -10.3, -10.9, 0.9, 0.7, 30, 0.5 },
		{ "oilOldA", -10.0, -9.9, 0.45, 0.4, 80, 0.55 },
		{ "oilOldA", 10.4, 15.4, 0.7, 0.6, 140, 0.55 },
		{ "oilOldB", 0.9, 6.3, 0.6, 0.5, 10, 0.5 },
		{ "oilOldA", -0.7, 7.8, 0.4, 0.35, 60, 0.6 },
		{ "oilOldB", 11.6, 6.9, 0.7, 0.55, 200, 0.58 },
		{ "oilOldA", -10.9, -0.2, 0.55, 0.45, 300, 0.6 },
		{ "oilOldB", 3.8, -2.9, 0.5, 0.4, 120, 0.52 }, -- under the car spot's oil pan, a second drop
	}
	local stg = Instance.new("SurfaceGui")
	stg.Name = "Stains"
	stg.Face = Enum.NormalId.Top
	stg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	stg.PixelsPerStud = 24
	stg.LightInfluence = 1
	for _, s in ipairs(stains) do
		local id = Interior.DECALS[s[1]]
		if id and id ~= "" then
			local im = Instance.new("ImageLabel")
			im.BackgroundTransparency = 1
			im.Image = "rbxassetid://" .. id
			-- the images are brown (avg oil_a 78/58/44, oil_b 113/88/66): tinted to old soaked-in oil = grey
			im.ImageColor3 = DECAL_TINT[s[1]] or Color3.new(1, 1, 1)
			im.ImageTransparency = s[7]
			im.AnchorPoint = Vector2.new(0.5, 0.5)
			im.Position = UDim2.fromScale((Z1 - s[3]) / (Z1 - Z0), (s[2] - X0) / (X1 - X0))
			im.Size = UDim2.fromScale(s[5] / (Z1 - Z0), s[4] / (X1 - X0))
			im.Rotation = s[6]
			if s[1] == "tyreMarks" then
				-- (v34) the decal laid the image's up along world Z (the way cars drive in); on this gui image-up is
				-- world X, so the tracks crossed the bay: turned a quarter, the box sized for after the turn
				im.Size = UDim2.fromScale(s[4] / (Z1 - Z0), s[5] / (X1 - X0))
				im.Rotation = s[6] + 90
			end
			im.Parent = stg
		end
	end
	stg.Parent = paint
	-- sealed-concrete sheen (v33, main 10-23: the mock has soft glows under the ceiling lights, ours read as ruled
	-- lines): soft light pools on the floor under the two tube rows (Dressing.LightTube x -6 / 6, z -13.6..13.6), a
	-- faint wide glow + uneven pools along each, no hard core. Real Reflectance mirrors the outdoor sky, so it is
	-- drawn. Its own SurfaceGui (lit less: a reflection does not darken in shade)
	local sg = Instance.new("SurfaceGui")
	sg.Name = "Sheen"
	sg.Face = Enum.NormalId.Top
	sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	sg.PixelsPerStud = 16
	sg.LightInfluence = 0.4
	local SHINE = Color3.fromRGB(255, 252, 240)
	local function soft(f: Frame, mid: number, rot: number)
		local g = Instance.new("UIGradient")
		g.Rotation = rot -- 90 = across (gui Y = world X), 0 = along (gui X = world Z)
		g.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, mid),
			NumberSequenceKeypoint.new(1, 1),
		})
		g.Parent = f
	end
	-- a pool = 12 nested ellipses, faded across and along by turns: the overlap makes a round falloff (6 layers
	-- faded one way showed rings at the hard ends). mid 0.9 -> each layer 0.95 -> ~0.46 opaque at the centre
	-- (GPT fix9 r1: ~0.37 hardly showed in the whole view)
	local function pool(cx: number, cz: number, rx: number, rz: number, mid: number, col: Color3?)
		for k = 0, 11 do
			local s = 1 - k * 0.075
			local f = rect(cx - rx * s, cx + rx * s, cz - rz * s, cz + rz * s, col or SHINE, 0, 0.5)
			f.Parent = sg
			soft(f, 1 - (1 - mid) * 0.5, if k % 2 == 0 then 90 else 0)
		end
	end
	for _, cx in ipairs({ -6, 6 }) do
		local f = rect(cx - 3.4, cx + 3.4, -13.2, 13.2, SHINE, 0, 0.5) -- the faint wide glow
		f.Parent = sg
		soft(f, 0.92, 90)
	end
	-- uneven along the tube (the mock's glow is brighter in places): x, z, half x, half z, mid transparency
	for _, p in ipairs({
		{ -6, -9.5, 2.2, 3.4, 0.9 }, { -5.8, -2.5, 1.9, 2.6, 0.92 }, { -6.1, 4.5, 2.3, 3.6, 0.9 }, { -6, 10.5, 1.8, 2.2, 0.93 },
		{ 6, -10.5, 1.9, 2.4, 0.93 }, { 5.8, -4, 2.4, 3.6, 0.9 }, { 6.1, 3.5, 2.0, 2.8, 0.92 }, { 6, 9.5, 2.2, 3.2, 0.91 },
	}) do
		pool(p[1], p[2], p[3], p[4], p[5])
	end
	-- the red cart and the red chest tint the sealed slab just in front of them (a short faded smear, no outline)
	for _, r in ipairs({ { 6.3, 10.9, 1.7, 2.85 }, { -10.8, -4.2, 15.0, 16.6 } }) do
		local f = rect(r[1], r[2], r[3], r[4], Color3.fromRGB(170, 46, 40), 0, 0.2)
		f.Parent = sg
		local g = Instance.new("UIGradient")
		g.Rotation = 0 -- along gui X = toward -Z: strongest at the object (its +Z end), gone toward the camera
		g.Transparency = NumberSequence.new(0.84, 1)
		g.Parent = f
	end
	-- v35: the bench light's warm pool on the slab in front of the bench (section 7 draws its wash on the wall)
	pool(7, 15.0, 4.6, 2.2, 0.8, WARM) -- (GPT fix11 r1: stronger, 0.88 hardly showed)
	-- v35 wear variety (main's list): hairline cracks off the saw-cut joints, a patched square by the drain, pale
	-- scuffs where the floor jack and creeper get dragged, short black rubber scuffs where tyres turned in
	local function streak(cx: number, cz: number, len: number, w: number, deg: number, col: Color3, alpha: number)
		-- a segment along world X, turned deg on the floor (gui rotation; gui Y = world X)
		local f = rect(cx - len / 2, cx + len / 2, cz - w / 2, cz + w / 2, col, alpha)
		f.Rotation = deg
		return f
	end
	local CRACK = Color3.fromRGB(86, 84, 82)
	for _, c in ipairs({
		-- x, z, length, angle: short kinked runs (2-3 segments) starting at a joint
		{ -4.5, -10.0, 1.4, 20 }, { -3.3, -9.5, 1.1, -15 }, { -2.3, -9.9, 0.9, 35 },
		{ 4.5, 8.0, 1.2, 70 }, { 4.8, 9.1, 1.0, 40 }, { 5.3, 9.9, 0.8, 85 },
		{ -8.2, -1.0, 1.3, -10 }, { -7.0, -0.8, 1.0, 25 },
		{ 9.6, -10.0, 1.1, 60 }, { 10.2, -11.0, 0.9, 20 },
	}) do
		streak(c[1], c[2], c[3], 0.045, c[4], CRACK, 0.35)
	end
	local patch = rect(-1.9, 1.9, 5.3, 8.7, Color3.fromRGB(126, 120, 118), 0.72) -- re-poured round the drain
	local pe = Instance.new("UIStroke")
	pe.Color = Color3.fromRGB(96, 94, 92)
	pe.Transparency = 0.55
	pe.Thickness = 1
	pe.Parent = patch
	local SCUFF = Color3.fromRGB(206, 202, 196)
	for _, c in ipairs({
		{ -8.6, -8.4, 3.2, 0.22, 25 }, { -7.9, -7.5, 2.4, 0.16, 32 }, -- the jack's rest: wheels dragged out
		{ -9.6, 1.6, 2.6, 0.2, -40 }, { -8.8, 2.6, 2.0, 0.14, -35 }, -- the creeper rolled out from the wall
		{ 6.2, 3.2, 3.0, 0.18, 70 }, -- the cart pushed round
	}) do
		streak(c[1], c[2], c[3], c[4], c[5], SCUFF, 0.84)
	end
	local RUBBER = Color3.fromRGB(46, 46, 48)
	for _, c in ipairs({
		{ -3.0, -16.2, 1.6, 0.24, 78 }, { -3.15, -14.7, 1.4, 0.22, 70 }, -- front tyres turned in at the door
		{ 3.4, -16.0, 1.5, 0.24, 100 }, { 3.6, -14.6, 1.3, 0.22, 108 },
	}) do
		streak(c[1], c[2], c[3], c[4], c[5], RUBBER, 0.78)
	end
	pg.Parent = paint
	sg.Parent = paint
	-- fine wear over the whole slab (GPT r2 "the mock floor is worn everywhere, ours smooth between the stains"): the two
	-- old-oil images tiled very faintly at unrelated tile sizes, so the repeat never lines up (0 parts)
	-- (v33, GPT fix9 r3 "the mock's slab is fine-scuffed all over, ours wide and smooth": + a small, dense tile)
	local wear: { { key: string, tile: number, alpha: number } } = {
		{ key = "oilOldA", tile = 7.3, alpha = 0.9 },
		{ key = "oilOldB", tile = 11.9, alpha = 0.92 },
		{ key = "oilOldB", tile = 3.7, alpha = 0.92 },
		{ key = "oilOldA", tile = 2.3, alpha = 0.95 },
	}
	for i, w in ipairs(wear) do
		local id = Interior.DECALS[w.key]
		if id ~= "" then
			local tx = Instance.new("Texture")
			tx.Name = "Wear" .. i
			tx.Face = Enum.NormalId.Top
			tx.Texture = "rbxassetid://" .. id
			tx.StudsPerTileU = w.tile
			tx.StudsPerTileV = w.tile * 0.83
			tx.OffsetStudsU = i * 2.7
			tx.Transparency = w.alpha
			tx.Color3 = DECAL_TINT[w.key]
			tx.Parent = paint
		end
	end

	-- 4. ceiling: corrugated steel deck + joists between the old beams + a conduit run along the back wall
	-- (v33, GPT fix9 r3: the mock's deck is galvanised grey, ours read brown)
	local deck = box(d, "CeilingDeck", -13, 18.75, -19, 14, 18.85, 19, Color3.fromRGB(86, 88, 92), M.smooth, { shadow = false }) -- (v34 main: a notch darker)
	-- v31: the deck's corrugations, front to back like the mock (Bottom face: gui X = world Z), drawn coarse (4 px/stud)
	local dg = Instance.new("SurfaceGui")
	dg.Name = "Ribs"
	dg.Face = Enum.NormalId.Bottom
	dg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	dg.PixelsPerStud = 4
	dg.LightInfluence = 1
	for i = 0, 35 do
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.BackgroundColor3 = Color3.fromRGB(74, 76, 80) -- low contrast (main v34: the ribs read as a flat drawing)
		f.Position = UDim2.fromScale(0, (i + 0.3) / 36)
		f.Size = UDim2.fromScale(1, 0.35 / 36)
		f.Parent = dg
	end
	dg.Parent = deck
	for _, bz in ipairs({ -16.5, -7, 3, 13.5 }) do
		box(d, "Joist", -13, 18.2, bz - 0.25, 14, 18.75, bz + 0.25, Color3.fromRGB(36, 38, 44), M.metal, { shadow = false })
	end
	box(d, "Conduit", -13, 17.4, 18.6, 14, 17.7, 18.9, C.steel, M.metal, { collide = false, shadow = false })

	-- 5. walls: things a real bay has (camera band y 4.5..10: only flat + solid there)
	-- fire extinguisher on the east pier between the counter window and the parts window (where the mock has it, in
	-- view from the bay door; the old spot by the front door was behind the camera). 10 lb ABC = 20.5" x 5" (Amerex
	-- B456) -> 1.8 x 0.55 studs (a touch chunky to read); NFPA 10: top <= 5 ft, bottom >= 4 in. Sign 9x12" above.
	local ext = Kit.model(d, "FireExtinguisher")
	local EX, EZ = 13.62, 3.5 -- pier face x 14.0 (wainscot face 13.85)
	-- the main's 3D extinguisher + wall hook (10-22, 0.90 x 2.11 x 0.66, back flat to the wall), front to the bay;
	-- bottom 2.4 -> top 4.5 (NFPA 10: top <= 5 ft). The part one stays if the mesh can't load
	local em = GearportProps.mesh(ext, "FireExtinguisher", 13.85 - 0.33, 2.4, EZ, GearportProps.facing(-1, 0), true)
	if not em then
		Kit.post(ext, "Body", EX, EZ, 2.4, 4.2, 0.55, Color3.fromRGB(206, 30, 30), M.smooth)
		Kit.post(ext, "Valve", EX, EZ, 4.2, 4.6, 0.24, C.metalDark, M.metal, { collide = false })
		box(ext, "Hose", EX - 0.05, 2.9, EZ + 0.27, EX + 0.05, 4.35, EZ + 0.35, Color3.fromRGB(30, 30, 32), M.smooth, DECO)
		box(ext, "Bracket", 13.82, 2.9, EZ - 0.3, 13.86, 3.3, EZ + 0.3, C.metalDark, M.metal, DECO)
	end
	local sign = box(ext, "Sign", 13.94, 5.0, EZ - 0.55, 14.0, 6.6, EZ + 0.55, Color3.fromRGB(206, 30, 30), M.smooth)
	drawing(sign, Enum.NormalId.Left, Color3.fromRGB(206, 30, 30), {
		{ 0.38, 0.22, 0.24, 0.56, Color3.new(1, 1, 1), 0.3 }, -- the extinguisher shape
		{ 0.44, 0.12, 0.12, 0.12, Color3.new(1, 1, 1) },
		{ 0.55, 0.14, 0.2, 0.06, Color3.new(1, 1, 1) },
	})
	-- air hose reel on the west wall, high (over the camera band, ~10 ft like garagejournal's wall-mounted reels),
	-- hose hanging down to the stop ball + nozzle at reach height. Real 3/8" x 50 ft spring reel (Reelcraft 7650 OLP /
	-- Coxreels P-LP-350): ~19" across, ~7" wide -> flange 1.55, reel 0.6 wide (was 2.6 across: twice too big)
	local reel = Kit.model(d, "HoseReel")
	local RY, RZ = 10.9, -2
	-- the main's 3D reel (10-22): dark steel 1.90 disc + red hose down to the nozzle, 1.90 x 3.73 x 0.89, back flat on
	-- the wall (x -13.0 above the band); disc centre = bottom + 2.779 -> bottom 8.121 keeps it at RY. Solid, so the
	-- camera stops in front of it (camera band rule). The part one stays if the mesh can't load
	-- (GPT fix8 r1: from the bay door the dark front disc hid the red coil, the mock's main read -> swung 40° toward
	-- the back wall on its swivel bracket, as wall reels mount, so the coil side faces the way players come in;
	-- its rotated depth 0.95 kept off the wall)
	local rm = GearportProps.mesh(reel, "HoseReel", -13.0 + 0.95, RY - 2.779, RZ, GearportProps.facing(1, 0.84), true)
	if rm then
		rm.Name = "HoseReel"
		-- v35 (main's list, before launch): the swung reel touched the wall at one corner and read as floating. Wall
		-- reels hang on a swivel bracket (Reelcraft / Coxreels: a square wall plate + a yoke out to the reel's axle):
		-- dark steel plate flat on the block + the arm to the hub (hub = bottom + 2.779)
		box(reel, "WallPlate", -13.0, RY - 0.6, RZ - 0.55, -12.9, RY + 0.6, RZ + 0.55, Color3.fromRGB(58, 60, 64), M.metal)
		box(reel, "SwivelArm", -12.9, RY - 0.13, RZ - 0.13, -12.15, RY + 0.13, RZ + 0.13, Color3.fromRGB(44, 46, 50), M.metal, DECO)
	else
		box(reel, "Plate", -13, RY - 0.7, RZ - 0.55, -12.88, RY + 0.7, RZ + 0.55, C.metalDark, M.metal)
		for _, fx in ipairs({ -12.84, -12.26 }) do
			Kit.part(reel, "Flange", Vector3.new(0.08, 1.55, 1.55), CFrame.new(fx, RY, RZ), Color3.fromRGB(206, 40, 36), M.smooth, { shape = "cyl", collide = false })
		end
		Kit.part(reel, "Coil", Vector3.new(0.5, 1.15, 1.15), CFrame.new(-12.55, RY, RZ), Color3.fromRGB(36, 36, 40), M.smooth, { shape = "cyl" })
		box(reel, "Hose", -12.59, 6.3, RZ - 0.05, -12.51, RY - 0.5, RZ + 0.03, Color3.fromRGB(46, 96, 176), M.smooth, DECO) -- blue rubber air hose (common in the photos; black read as a pole)
		Kit.part(reel, "StopBall", Vector3.new(0.3, 0.3, 0.3), CFrame.new(-12.55, 6.3, RZ - 0.01), C.yellow, M.smooth, { shape = "ball", collide = false, shadow = false })
		Kit.part(reel, "Nozzle", Vector3.new(0.14, 0.55, 0.14), CFrame.new(-12.55, 5.88, RZ - 0.01) * CFrame.Angles(math.rad(35), 0, 0),
			C.metalDark, M.metal, DECO) -- blow gun hangs tipped off the stop ball
	end
	-- tool board (where the empty west frame was): wrench outlines drawn on a dark board
	-- v31 like the mock: a framed shadow board (silver edge), three big combination wrenches + a white checklist sheet
	local tb = box(d, "ToolBoard", -13, 11.2, 4.6, -12.88, 14.4, 8.8, Color3.fromRGB(40, 42, 46), M.smooth)
	local SILVER, BOARD = Color3.fromRGB(196, 200, 206), Color3.fromRGB(40, 42, 46)
	local wr: { { any } } = {
		{ 0, 0, 1, 1, Color3.fromRGB(150, 154, 160) }, -- the frame
		{ 0.03, 0.04, 0.94, 0.92, BOARD },
	}
	for i = 0, 2 do
		local x = 0.1 + i * 0.13
		table.insert(wr, { x - 0.035, 0.12, 0.12, 0.13, SILVER, 0.5 } :: { any }) -- open end
		table.insert(wr, { x + 0.005, 0.1, 0.04, 0.07, BOARD } :: { any }) -- its jaw gap
		table.insert(wr, { x, 0.22, 0.05, 0.56, SILVER } :: { any }) -- shank
		table.insert(wr, { x - 0.03, 0.74, 0.11, 0.13, SILVER, 0.5 } :: { any }) -- ring end
		table.insert(wr, { x + 0.005, 0.78, 0.04, 0.05, BOARD, 0.5 } :: { any })
	end
	table.insert(wr, { 0.56, 0.1, 0.36, 0.8, Color3.fromRGB(232, 232, 228) } :: { any }) -- the sheet
	for k = 0, 6 do
		table.insert(wr, { 0.6, 0.18 + k * 0.09, if k % 3 == 0 then 0.2 else 0.27, 0.025, Color3.fromRGB(120, 124, 130) } :: { any })
	end
	drawing(tb, Enum.NormalId.Right, BOARD, wr)
	-- calendar on the back wall (where the empty back frame was): red header, day grid, no words
	-- (v31: moved from over the bench to just west of the back door, the mock's spot)
	local cal = box(d, "Calendar", -6.4, 12.6, 18.86, -4.0, 15.4, 18.95, Color3.fromRGB(248, 248, 244), M.smooth)
	local grid: { { any } } = { { 0, 0, 1, 0.16, Color3.fromRGB(200, 40, 36) } }
	for row = 0, 4 do
		for col = 0, 6 do
			table.insert(grid, { 0.06 + col * 0.13, 0.24 + row * 0.14, 0.1, 0.1, Color3.fromRGB(214, 214, 210) } :: { any })
		end
	end
	drawing(cal, Enum.NormalId.Front, Color3.fromRGB(248, 248, 244), grid)
	-- small-parts drawer cabinet over the tool chest (where the empty safety frame was)
	local cab = box(d, "DrawerCabinet", -11.6, 8.8, 18.3, -7.4, 11.6, 19, Color3.fromRGB(60, 64, 72), M.metal) -- (v31: west of the calendar, like the mock)
	local dr: { { any } } = {}
	for row = 0, 3 do
		for col = 0, 4 do
			table.insert(dr, { 0.04 + col * 0.19, 0.05 + row * 0.235, 0.17, 0.2, Color3.fromRGB(196, 200, 206) } :: { any })
			table.insert(dr, { 0.09 + col * 0.19, 0.17 + row * 0.235, 0.07, 0.03, Color3.fromRGB(60, 64, 72) } :: { any })
		end
	end
	drawing(cab, Enum.NormalId.Front, Color3.fromRGB(60, 64, 72), dr)

	-- 6. floor props: trash can (front-left corner), drain pan by the tyre rack
	-- the main's 3D shop can (10-22, 1.90 x 2.51 x 1.83) by the back door: on the bay floor in front of the bench's
	-- door end, clear of the doorway (x -3.4..0.6). The part one stays in the front corner if the mesh can't load
	local trash = Kit.model(d, "TrashCan")
	if not GearportProps.mesh(trash, "ShopTrashCan", 1.55, F, 15.25, GearportProps.facing(0, -1), true) then
		Kit.post(trash, "Can", -11.6, -17.2, F, 3.0, 1.8, Color3.fromRGB(70, 74, 80), M.metal)
		Kit.post(trash, "Lid", -11.6, -17.2, 3.0, 3.2, 1.9, C.yellow, M.smooth, { collide = false })
	end
	-- (v31: the pan out in front of the tyre rack, where the mock has it and the bay camera sees it)
	local PX, PZ = -9.5, 4.4
	local pan = GearportProps.mesh(d, "DrainPan", PX, F, PZ, math.rad(20), true)
	if pan then
		pan.Size = pan.Size * (2.6 / math.max(pan.Size.X, pan.Size.Z)) -- about 30 in across
		pan.CFrame = CFrame.new(PX, F + pan.Size.Y / 2, PZ) * CFrame.Angles(0, math.rad(20), 0)
		-- black poly pan like the mock (the mesh's own look is orange): drop its SurfaceAppearance, colour the part
		local sa = pan:FindFirstChildOfClass("SurfaceAppearance")
		if sa then
			sa:Destroy()
		end
		pan.Color = Color3.fromRGB(34, 34, 36)
		pan.Material = M.smooth
	else
		Kit.post(d, "DrainPan", PX, PZ, F, F + 0.4, 2.6, Color3.fromRGB(30, 30, 32), M.smooth)
	end
	-- shop rags on the cart / bench edge (a red cloth hanging over the bench front)
	-- (v35: plain colour + drawn folds — the Fabric material is a photo texture that broke the block look up close)
	local rag = box(d, "Rag", 9.6, 2.4, 16.25, 10.6, 3.42, 16.32, Color3.fromRGB(196, 60, 52), M.smooth, DECO)
	drawing(rag, Enum.NormalId.Front, Color3.fromRGB(196, 60, 52), RAG_FOLDS(Color3.fromRGB(160, 44, 40)))

	-- 7. v31 (main: match the mock everywhere before launch)
	if bay1 then
		-- the yellow bay line along the west wall comes out to x -10.2 (the mock's line runs in front of the stands)
		for _, p in ipairs(bay1:GetChildren()) do
			if p:IsA("BasePart") and p.Name == "BayLine" and p.Position.X < 0 then
				p.Position = Vector3.new(-10.2, p.Position.Y, p.Position.Z)
			end
		end
		-- the creeper leans on the west wall (casters to the wall, the lying side + headrest out, head up) in the gap
		-- between the tyre rack and the tyre changer's floor spot — the mock's spot; its old hook was behind the oil
		-- drums from the bay camera. WorkService keeps whatever pose it has at the first slide as its home.
		local kit = bay1:FindFirstChild("JackKit")
		local cr = kit and kit:FindFirstChild("Creeper")
		local board = cr and cr:FindFirstChild("Board") :: BasePart?
		if kit and cr and cr:IsA("Model") and board then
			-- the board centre frame (WorkService's creeper local: head -Z, casters -Y): the 3D creeper's model pivot,
			-- the part creeper's Board. From it: half length L, depth below (casters) and above (headrest / pad)
			local mesh = board:IsA("MeshPart")
			local bc = if mesh then cr:GetPivot() else board.CFrame
			local L = board.Size.Z / 2
			local down = if mesh then board.Size.Y / 2 + 0.1 else 0.41
			local lean = math.rad(9) -- v34 (main 10-23: at 15° it looked like falling over; the mock leans it near upright)
			local c, s = math.cos(lean), math.sin(lean)
			-- the casters' top end touches the wall face (x -12.85), the lowest corner the floor; z -1.12: the 3D board
			-- (1.86 wide) fits between the Lv7 tyre changer (z <= -2.1) and the Lv11 spring compressor (z >= -0.2)
			-- local X = along the wall (-Z), Y = out of the wall + a bit up, Z = toward the foot (down + out)
			local at = CFrame.fromMatrix(Vector3.new(-12.85 + L * s + down * c, F + L * c + down * s, -1.12), Vector3.new(0, 0, -1),
				Vector3.new(c, s, 0), Vector3.new(s, -c, 0))
			cr:PivotTo(at * (bc:Inverse() * cr:GetPivot()))
			local hook = kit:FindFirstChild("CreeperHook")
			if hook then
				hook:Destroy()
			end
			local spot = kit:FindFirstChild("CreeperWallSpot") :: BasePart?
			if spot then
				spot.CFrame = CFrame.lookAt(at.Position, at.Position + Vector3.new(1, 0, 0))
			end
			-- jack stand 2 just out from the creeper's foot, on its door side (the mock; GPT fix9 r1: at (-10.45, -1.0)
			-- it read as under the tyre rack). z -1.45 keeps it clear of the Lv7 tyre changer's base (z <= -2.1)
			local st = kit:FindFirstChild("JackStand2")
			if st and st:IsA("Model") then
				st:PivotTo(CFrame.new(-10.75, st:GetPivot().Y, -1.45) * st:GetPivot().Rotation)
			end
			local ss = kit:FindFirstChild("StandSpot2") :: BasePart?
			if ss then
				ss.CFrame = CFrame.new(-10.75, ss.Position.Y, -1.45) * ss.CFrame.Rotation
			end
			-- v33 (main 10-23 "match the mock's right side"): the mock runs rack -> creeper + stand -> charger against
			-- the wall -> red drum, one stand in view. Stand 1 (its old spot is the charger's now) goes on along the wall
			-- past the drums toward the front wall (out on the floor it stood big in the bay camera's foreground)
			local st1 = kit:FindFirstChild("JackStand1")
			if st1 and st1:IsA("Model") then
				st1:PivotTo(CFrame.new(-11.5, st1:GetPivot().Y, -13.3) * st1:GetPivot().Rotation)
			end
			local ss1 = kit:FindFirstChild("StandSpot1") :: BasePart?
			if ss1 then
				ss1.CFrame = CFrame.new(-11.5, ss1.Position.Y, -13.3) * ss1.CFrame.Rotation
			end
		end
	end
	-- the pegboard over the bench in the mock's charcoal; the bench an open steel frame like the mock (4 legs + a
	-- low shelf under the wood top): the solid body becomes the shelf, the two drawer fronts the front legs, + 2 back legs
	local wbs = garage:FindFirstChild("Workbenches")
	local wb1 = wbs and wbs:FindFirstChild("Workbench1")
	if wb1 then
		local STEEL = Color3.fromRGB(56, 60, 66)
		local legX = { 2.2, 11.8 }
		local n = 0
		for _, p in ipairs(wb1:GetChildren()) do
			if p:IsA("BasePart") then
				if p.Name == "Pegboard" then
					p.Color = Color3.fromRGB(58, 60, 64)
					-- a warm pool over the bench (GPT r2: the mock's light gathers warm at the work area), no shadows
					local l = Instance.new("SurfaceLight")
					l.Name = "BenchGlow"
					l.Face = Enum.NormalId.Front
					l.Brightness = 1.1 -- (0.5 did not show: GPT r3)
					l.Range = 10
					l.Angle = 110
					l.Color = Color3.fromRGB(255, 214, 168)
					l.Shadows = false
					l.Parent = p
				elseif p.Name == "Body" then
					p.Name = "Shelf"
					p.Color = STEEL
					p.Size = Vector3.new(9.8, 0.2, 2.2)
					p.Position = Vector3.new(7, F + 0.7, 17.75)
				elseif p.Name == "Drawer" then
					n += 1
					p.Name = "Leg"
					p.Color = STEEL
					p.Size = Vector3.new(0.3, 2.8, 0.3)
					p.Position = Vector3.new(legX[n] or 7, F + 1.4, 16.6)
				end
			end
		end
		for _, x in ipairs(legX) do
			box(wb1, "Leg", x - 0.15, F, 18.55, x + 0.15, 3.0, 18.85, STEEL, M.metal)
		end
		-- v35 (main's list before launch: "the bench's warm light is weak" — Voxel lighting barely shows a SurfaceLight):
		-- the warm wash over the bench drawn on a clear carrier just in front of the pegboard (x 1..13, y 5..11, face
		-- z 18.8), brightest over the bench top, + a warm pool on the slab in front of it (section 3's sheen gui)
		local glow = Kit.part(d, "BenchGlowWall", Vector3.new(13.2, 8.8, 0.02), CFrame.new(7, 3.4 + 4.4, 18.77), Color3.new(1, 1, 1), M.smooth,
			{ collide = false, shadow = false, transparency = 1 })
		glow.CanQuery = false
		glow.CanTouch = false
		local gg = Instance.new("SurfaceGui")
		gg.Name = "Warm"
		gg.Face = Enum.NormalId.Front
		gg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gg.PixelsPerStud = 10
		gg.LightInfluence = 0.15
		for k = 0, 9 do
			local s = 1 - k * 0.09
			local f = Instance.new("Frame")
			f.BorderSizePixel = 0
			f.BackgroundColor3 = WARM
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Position = UDim2.fromScale(0.5, 0.78) -- over the bench top (y ~4.3 of 3.4..12.2)
			f.Size = UDim2.fromScale(1.0 * s, 1.2 * s)
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0.5, 0)
			c.Parent = f
			local g = Instance.new("UIGradient")
			g.Rotation = if k % 2 == 0 then 90 else 0
			g.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0.93), -- (GPT fix11 r1: 0.955 hardly showed v34 -> v35)
				NumberSequenceKeypoint.new(1, 1),
			})
			g.Parent = f
			f.Parent = gg
		end
		gg.Parent = glow
	end
	-- a grey shop rag over the end of the parts cart's top tray (the mock's cart)
	local cart = bay1 and bay1:FindFirstChild("BayCart")
	if cart and cart:IsA("Model") then
		local cf, sz = cart:GetBoundingBox()
		local ex, top, fz = cf.X - sz.X / 2 + 0.9, cf.Y + sz.Y / 2, cf.Z - sz.Z / 2
		-- (v35, wr-play eval B11 / T8_05: the Fabric material read as a brown photo panel next to the block props ->
		-- plain light grey + drawn folds, like the mock's rag)
		-- (API r1: a grey slab read as a white bin -> the blue cloth US shops wipe with (shop towels), off the red
		-- cart; two layers hung a little crooked so the hem is uneven, + the part over the top edge)
		local RAG = Color3.fromRGB(64, 104, 170)
		local RAG_DARK = Color3.fromRGB(46, 78, 134)
		-- (GPT fix11 r1/r2 "a thick blue box", then "still a square box edge"): the hanging part is a clear panel with
		-- the cloth DRAWN on it — soft corners, a hem of uneven tongues, two folds — so its outline is a cloth's, not a
		-- block's; only the bit over the top edge is a (0.03 thin) part
		local cr = box(d, "CartRag", ex - 0.5, top - 1.0, fz - 0.02, ex + 0.5, top - 0.02, fz, RAG, M.smooth, DECO)
		cr.Transparency = 1
		local rg = Instance.new("SurfaceGui")
		rg.Name = "Cloth"
		rg.Face = Enum.NormalId.Front
		rg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		rg.PixelsPerStud = 60
		rg.LightInfluence = 1
		local function cloth(x: number, y: number, w: number, h: number, col: Color3, round: number, rot: number?)
			local f = Instance.new("Frame")
			f.BorderSizePixel = 0
			f.BackgroundColor3 = col
			f.Position = UDim2.fromScale(x, y)
			f.Size = UDim2.fromScale(w, h)
			f.Rotation = rot or 0
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(round, 0)
			c.Parent = f
			f.Parent = rg
		end
		cloth(0.06, 0.0, 0.86, 0.62, RAG, 0.12) -- the body, top flush with the tray edge
		-- the hem: two wide, uneven flaps (narrow round tongues read as a glove's fingers) + the layer behind
		-- (GPT r3: the flaps' straight ends read stiff -> different widths, ends slanted different ways)
		cloth(0.44, 0.46, 0.5, 0.36, RAG_DARK, 0.3, -9)
		cloth(0.04, 0.42, 0.6, 0.54, RAG, 0.3, 7)
		cloth(0.58, 0.42, 0.34, 0.28, RAG, 0.35, -12)
		cloth(0.3, 0.08, 0.04, 0.6, RAG_DARK, 0.5, 3) -- folds
		cloth(0.66, 0.12, 0.035, 0.46, RAG_DARK, 0.5, -4)
		rg.Parent = cr
		box(d, "CartRagFold", ex - 0.4, top - 0.02, fz - 0.02, ex + 0.3, top, fz + 0.22, RAG, M.smooth, DECO) -- the bit over the top edge (r3: smaller)
	end
	-- stand-ins the main's 3D props will replace (10-22: no prop pack, our own 3D) gathered under Interior by the
	-- names the swap uses (notes/playtest/wr-builder/interior/prop_swap_table.md). The creeper stays in JackKit
	-- (WorkService reads <bay>.JackKit.Creeper); the vise keeps its part name (PartTag's deco.Vise label)
	local dressing = garage:FindFirstChild("Dressing")
	local drums = dressing and dressing:FindFirstChild("OilDrums")
	if drums then
		drums.Name = "OilDrum"
		drums.Parent = d
	end
	local vise = wb1 and wb1:FindFirstChild("Vise") :: BasePart?
	if vise then
		local bv = Kit.model(d, "BenchVise")
		-- the main's 3D 6 in swivel vise (10-22) on the bench's right end, screw toward the bay; keeps the part name
		-- Vise (PartTag's deco.Vise). The blue part block stays if the mesh can't load
		local mp = GearportProps.mesh(bv, "BenchVise", 10.7, 3.4, 16.95, GearportProps.facing(0, -1), true)
		if mp then
			mp.Name = "Vise"
			vise:Destroy()
		else
			vise.Parent = bv
		end
	end
	-- the mock's red box by the drums = a wheeled shop battery charger (main 3D 10-22) against the west wall,
	-- front to the bay, between jack stand 1 and the creeper. That floor is the Lv7 tyre changer's: the charger is
	-- shown only until the changer is bought (UpgradeState Locked)
	local ch = Kit.model(d, "BatteryCharger")
	-- (GPT fix7 r1: half hidden behind the red drum from the bay door -> 0.7 further from the drum, face turned ~20°
	-- toward the door so the gauges read)
	-- (v33: 1.5 nearer the door, the mock's spot between the creeper and the drum — at -3.2 it hid the creeper's
	-- foot and the wall band behind it)
	local cm = GearportProps.mesh(ch, "BatteryCharger", -12.85 + 0.85, F, -4.45, GearportProps.facing(1, -0.45), true) -- (v35: the drums moved 0.6 to the door, the charger 0.25 the other way + a touch more toward the door: its whole box clear of the drum, GPT fix7 "weaker silhouette than the mock")
	if cm then
		ch:SetAttribute("UpgradeId", "TireChanger")
		ch:SetAttribute("UpgradeState", "Locked")
	else
		ch:Destroy()
	end
	-- an electrical conduit down the west wall to a switch box (the mock's right wall), flush + solid for the camera
	box(d, "WallConduit", -12.88, 6.4, 10.85, -12.7, 18.2, 11.05, C.steel, M.metal)
	box(d, "SwitchBox", -12.88, 5.4, 10.6, -12.6, 6.4, 11.3, Color3.fromRGB(150, 154, 160), M.metal)

	-- 8. v35 the waiting room's empty frames (main's list before launch): real shop lounges hang a service poster,
	-- a framed certificate and customers' car photos (fix11/ref). Drawn in the game's flat block style, words in a
	-- real font, no image assets, 0 parts (the poster hidden behind the photo board goes: -2)
	local wroom = garage:FindFirstChild("WaitingRoom")
	local wlived = wroom and wroom:FindFirstChild("LivedIn")
	local slots = wlived and wlived:FindFirstChild("ArtSlots")
	if slots then
		for _, b in ipairs(slots:GetChildren()) do
			if b:IsA("BasePart") and b.Name == "ArtSlot" then
				local id = b:GetAttribute("ArtSlot")
				if id == "WR_PosterEast" then
					for _, f in ipairs(slots:GetChildren()) do
						if f ~= b and f:IsA("BasePart") and f.Name == "ArtFrame" and (f.Position - b.Position).Magnitude < 0.3 then
							f:Destroy()
						end
					end
					b:Destroy()
				elseif id == "WR_PosterCross" then
					posterTires(b)
				elseif id == "WR_Certificate" then
					certificate(b)
				end
			end
		end
	end
	local pw = wroom and wroom:FindFirstChild("PhotoWall")
	local board = pw and pw:FindFirstChild("Board") :: BasePart?
	if board then
		customerPhotos(board)
	end
end

return Interior
