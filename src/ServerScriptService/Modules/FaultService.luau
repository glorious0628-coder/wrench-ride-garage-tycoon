-- Random faults on a new car (기획서 6장 FaultScript): 2~5 faultable parts drop to Condition 0~30, the rest stay
-- 72~100. A broken part shows what a driver would notice: steam + a coolant puddle (Radiator), black smoke from the
-- tail pipe (Muffler, which also dangles), the car leaning on a flat tyre, a crooked bumper, a buckled hood, rust.
-- refresh(car) turns symptoms off once the broken part is out or replaced. (Sounds: Config.Sounds, later.)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Faults = require(ReplicatedStorage.Shared.Faults)
local Locale = require(ReplicatedStorage.Shared.Locale)
local PartGraph = require(ReplicatedStorage.Shared.PartGraph)
local CarFactory = require(script.Parent.CarFactory)
local Guard = require(script.Parent.Guard)
local VFX = require(ReplicatedStorage.Shared.VFX)

local FaultService = {}

local rng = Random.new()
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local RUST = Color3.fromRGB(120, 72, 40)
local SCUFF = Color3.fromRGB(150, 146, 140) -- plastic / paint doesn't rust: it fades and scuffs
local METALS = { [Enum.Material.Metal] = true, [Enum.Material.DiamondPlate] = true, [Enum.Material.CorrodedMetal] = true }

-- smoke / steam per slot: car-space spot (car_spec FX_HoodGap, FX_Exhaust) and look
local EMITTERS = {
	Radiator = { pos = Vector3.new(0, 4.0, -8.0), color = Color3.fromRGB(245, 245, 245), rate = 18 }, -- FX_HoodGap (v0.7)
	Muffler = { pos = Vector3.new(1.2, 0.75, 8.8), color = Color3.fromRGB(30, 30, 30), rate = 10 },
}
-- (fault_looks §5b: the sedan's coolant is pink, under the radiator; size grows a little while it's parked)
local PUDDLES = {
	Radiator = { pos = Vector3.new(1.8, 0, -9.0), color = Color3.fromHex("E7A9C4"), size = 2.2, image = "coolant_pink" }, -- (-7.2 / 0 hid the picture under the bumper and in the drain grate (bars cut the pink into stripes): off to the side and forward of it, Play photos 10-22)
}

local function isBroken(part: Instance?): boolean
	return part ~= nil and (part:GetAttribute("Condition") :: number) < Config.BrokenBelow
end
FaultService.isBroken = isBroken

local function puddlesFolder(): Folder
	local f = workspace:FindFirstChild("Puddles") :: Folder
	if not f then
		f = Instance.new("Folder")
		f.Name = "Puddles"
		f.Parent = workspace
	end
	return f
end

-- how worn a part looks: metal drifts toward rust (broken = corroded), plastic / paint fades and scuffs
function FaultService.paint(part: Instance)
	local cond = part:GetAttribute("Condition") :: number
	local wear = math.clamp((Config.WarnBelow - cond) / Config.WarnBelow, 0, 1)
	for _, p in CarFactory.allParts(part) do
		if not p:GetAttribute("Bolt") then
			local base = p:GetAttribute("BaseColor") :: Color3?
			if not base then
				base = p.Color
				p:SetAttribute("BaseColor", base)
				p:SetAttribute("BaseMaterial", p.Material.Name)
			end
			local mat = (Enum.Material :: any)[p:GetAttribute("BaseMaterial") :: string]
			if METALS[mat] then
				p.Color = (base :: Color3):Lerp(RUST, wear * 0.7)
				p.Material = if cond < Config.BrokenBelow then Enum.Material.CorrodedMetal else mat
			else
				p.Color = (base :: Color3):Lerp(SCUFF, wear * 0.45)
				p.Material = mat
			end
		end
	end
end

-- car tilt from a flat tyre (degrees: roll toward the side, pitch toward the end)
function FaultService.lean(car: Model): CFrame
	local roll, pitch = 0, 0
	for corner in CarParts.WheelCenters do
		if isBroken(CarFactory.slotPart(car, "Wheel_" .. corner)) then
			roll += if corner:sub(2, 2) == "L" then -1.8 else 1.8
			pitch += if corner:sub(1, 1) == "F" then -1.0 else 1.0
		end
	end
	return CFrame.Angles(math.rad(pitch), 0, math.rad(roll))
end

-- an installed broken part's offset from its socket
function FaultService.sag(part: Instance): CFrame
	local car = part.Parent and part.Parent.Parent
	local hanging = car ~= nil and car:GetAttribute("Issue_Muffler") == "hang" and part:GetAttribute("PartKind") == "Muffler"
	if not isBroken(part) and not hanging then
		return CFrame.identity
	end
	local kind = part:GetAttribute("PartKind")
	if kind == "Muffler" then -- one rubber hanger gone: drops at one end
		return CFrame.new(-1.3, 0, 0) * CFrame.Angles(0, 0, math.rad(-10)) * CFrame.new(1.3, 0, 0)
	elseif kind == "Bumper" then -- one end knocked loose
		return CFrame.new(-3.7, 0, 0) * CFrame.Angles(0, math.rad(5), math.rad(-6)) * CFrame.new(3.7, 0, 0)
	elseif kind == "Hood" then -- buckled: sits crooked on its hinge
		return CFrame.Angles(math.rad(3), math.rad(1.5), math.rad(-1.5))
	end
	return CFrame.identity
end

-- the new symptoms (Features.VfxV2; Shared/VFX + VfxPresets): the server only marks Attachments, each client builds the
-- steam / drip / puffs itself (so a phone can run fewer). Steam and a drip from a worn radiator; a rust-hole muffler
-- (MUF_HOLE) leaks grey puffs on a beat with soot round the hole — no black smoke (that is too much fuel, another
-- fault). The hanger / heat shield kinds only rattle and sag: nothing comes out.
local HOLE = Vector3.new(-0.2, -0.27, 0) -- the rust hole, in the muffler's own space (its can is 2.6 x 0.6 x 1.0)
local leaks: { [Model]: Attachment } = setmetatable({} :: any, { __mode = "k" })
local swings: { [Model]: Instance } = setmetatable({} :: any, { __mode = "k" }) -- the muffler tagged to swing, per car

local function markAt(chassis: BasePart, car: Model, name: string, carSpot: Vector3, names: { string }, on: boolean)
	local a = chassis:FindFirstChild(name)
	if on and not a then
		local att = Instance.new("Attachment")
		att.Name = name
		att.Position = chassis.CFrame:PointToObjectSpace((car:GetPivot() * CFrame.new(carSpot)).Position)
		att.Parent = chassis
		VFX.mark(att, names, VFX.scaleOf(car))
	elseif not on and a then
		a:Destroy()
	end
end

local function refreshV2(car: Model, chassis: BasePart)
	-- (the old black-smoke / white-smoke emitters go if the switch was just turned on)
	for _, old in { "FX_Radiator", "FX_Muffler" } do
		local a = chassis:FindFirstChild(old)
		if a then
			a:Destroy()
		end
	end
	local rad = CarFactory.slotPart(car, "Radiator")
	local radOff = not FaultService.slotOK(car, "Radiator")
	markAt(chassis, car, "FXV_Radiator", EMITTERS.Radiator.pos, { "radiator_cloud", "radiator_wisp" }, radOff)
	markAt(chassis, car, "FXV_Drip", Vector3.new(0.7, 1.0, -7.6), { "coolant_drip" }, isBroken(rad)) -- (x 1.4 → 0.7: nearer the bumper's middle, it looked like it came out of the wheel — main 10-23)
	-- the muffler: puffs ride on the part itself (it sags, and it leaves with the part), soot too
	local muf = CarFactory.slotPart(car, "Muffler")
	local variant = FaultService.variantOf(car, "Muffler")
	local leak = isBroken(muf) and (variant == "MUF_HOLE" or variant == "")
	-- a hanging / broken muffler swings a little (the client moves its look; only the part is tagged)
	local sagging = muf ~= nil and (isBroken(muf) or car:GetAttribute("Issue_Muffler") == "hang")
	local swung = swings[car]
	if swung and (swung ~= muf or not sagging) then
		VFX.markSway(swung, false)
		swings[car] = nil
	end
	if sagging and muf and swings[car] ~= muf then
		VFX.markSway(muf, true, "muffler")
		swings[car] = muf
	end
	local had = leaks[car]
	if had and not had.Parent then
		had = nil
	end
	if leak and muf and not had then
		local root = CarFactory.root(muf)
		local att = Instance.new("Attachment")
		att.Name = "FXV_Muffler"
		att.Position = root.CFrame:PointToObjectSpace(root.CFrame * HOLE)
		att.Parent = root
		VFX.mark(att, { "muffler_leak" }, VFX.scaleOf(car))
		leaks[car] = att
		if not root:FindFirstChild("Soot") then
			local soot = Instance.new("Part")
			soot.Name = "Soot"
			soot.Size = Vector3.new(1.0, 0.04, 0.8)
			soot.Transparency = 1
			soot.Anchored = true
			soot.CanCollide = false
			soot.CanQuery = false
			soot.CanTouch = false
			soot.CastShadow = false
			soot.CFrame = root.CFrame * CFrame.new(HOLE + Vector3.new(0, -0.02, 0))
			local d = Instance.new("Decal")
			d.Texture = "rbxassetid://139316219214926"
			d.Face = Enum.NormalId.Bottom
			d.Color3 = Color3.fromRGB(28, 24, 22)
			d.Transparency = 0.1
			d.Parent = soot
			soot.Parent = muf
		end
	elseif not leak and had then
		had:Destroy()
		leaks[car] = nil
	end
end

-- turn symptoms on / off for what is on the car right now
function FaultService.refresh(car: Model)
	local chassis = car.PrimaryPart :: BasePart
	local carId = car:GetAttribute("CarId")
	-- smoke rides on chassis attachments (moves with the car and the lift)
	local v2 = VFX.enabled()
	if v2 then
		refreshV2(car, chassis)
	else
		for _, new in { "FXV_Radiator", "FXV_Drip" } do -- (the switch was turned off: the new marks go)
			local a = chassis:FindFirstChild(new)
			if a then
				a:Destroy()
			end
		end
		local leak, swung, muf = leaks[car], swings[car], CarFactory.slotPart(car, "Muffler")
		if leak then
			leak:Destroy()
			leaks[car] = nil
		end
		if swung then
			VFX.markSway(swung, false)
			swings[car] = nil
		end
		local soot = muf and muf:FindFirstChild("Soot")
		if soot then
			soot:Destroy()
		end
	end
	local emitters: typeof(EMITTERS) = if v2 then {} :: any else EMITTERS
	for slotName, e in emitters do
		local on = not FaultService.slotOK(car, slotName)
		local a = chassis:FindFirstChild("FX_" .. slotName)
		if on and not a then
			local att = Instance.new("Attachment")
			att.Name = "FX_" .. slotName
			att.Position = chassis.CFrame:PointToObjectSpace((car:GetPivot() * CFrame.new(e.pos)).Position)
			att.Parent = chassis
			local pe = Instance.new("ParticleEmitter")
			pe.Texture = SMOKE
			pe.Color = ColorSequence.new(e.color)
			pe.Rate = e.rate
			pe.Lifetime = NumberRange.new(1.6, 2.6)
			pe.Speed = NumberRange.new(1.5, 3)
			pe.SpreadAngle = Vector2.new(25, 25)
			pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 3) })
			pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) })
			pe.Acceleration = Vector3.new(0, 2, 0)
			pe.Parent = att
		elseif not on and a then
			a:Destroy()
		end
	end
	-- puddles stay on the floor (not on the car), so they don't ride up with the lift
	local pf = puddlesFolder()
	for slotName, p in PUDDLES do
		local name = "Puddle_" .. tostring(carId) .. "_" .. slotName
		local on = isBroken(CarFactory.slotPart(car, slotName)) and car:GetAttribute("Parked") == true
		local existing = pf:FindFirstChild(name)
		if on and not existing then
			local base = (car:GetAttribute("BaseCFrame") :: CFrame?) or car:GetPivot()
			local d = Instance.new("Part")
			d.Name = name
			local id = Config.PuddleImages[p.image or ""]
			if id and id ~= "" then
				-- wr-art's picture on an invisible floor plate (a little see-through: the middle reads too thick)
				local aspect = (Config.PuddleAspect :: any)[p.image or ""] or 1 -- (the picture's width / height, same area as the square plate)
				d.Size = Vector3.new(p.size * 1.3 * math.sqrt(aspect), 0.05, p.size * 1.3 / math.sqrt(aspect))
				d.CFrame = base * CFrame.new(p.pos + Vector3.new(0, 0.03, 0)) * CFrame.Angles(0, math.rad(37 * (tonumber(carId) or 0) % 360), 0)
				d.Transparency = 1
				local decal = Instance.new("Decal")
				decal.Face = Enum.NormalId.Top
				decal.Texture = "rbxassetid://" .. id
				decal.Color3 = Color3.fromRGB(222, 178, 196) -- (a touch darker and clearer: bright opaque pink read as paint, GPT 10-22)
				decal.Transparency = 0.38
				decal.Parent = d
			else
				d.Shape = Enum.PartType.Cylinder
				d.Size = Vector3.new(0.05, p.size, p.size)
				d.CFrame = base * CFrame.new(p.pos + Vector3.new(0, 0.03, 0)) * CFrame.Angles(0, 0, math.rad(90))
				d.Color = p.color
				d.Material = Enum.Material.Glass
				d.Transparency = 0.15
			end
			d.Anchored = true
			d.CanCollide = false
			d.CanQuery = false
			d.CastShadow = false
			d.Parent = pf
		elseif not on and existing then
			existing:Destroy()
		end
	end
end

function FaultService.clearPuddles(car: Model)
	local prefix = "Puddle_" .. tostring(car:GetAttribute("CarId")) .. "_"
	for _, d in puddlesFolder():GetChildren() do
		if d.Name:sub(1, #prefix) == prefix then
			d:Destroy()
		end
	end
end

-------------------------------------------------------------------------------------------------------------------
-- The random generator (alpha_scope v0.2 §2): how many faults (FaultsByLevel), which kinds (weights among the kinds
-- open at the level), which variant, the rules that keep it fresh, and the occasional trap.
-------------------------------------------------------------------------------------------------------------------
export type Fault = { slot: string, variant: string }

-- what the garage has seen lately (one garage per server)
local history = {
	kinds = {} :: { string }, -- the main kind of each recent car, newest last
	variants = {} :: { string }, -- every variant of the last Config.VariantMemory cars (fault_mix v0.2 ①)
	recent = {} :: { { string } }, -- the same, one list a car, newest last
	lastLevel = 0,
	newKinds = {} :: { [string]: number }, -- kind -> cars left to show it at least once (unlock taste: 1 of the next 3)
	stars = {} :: { number }, -- (car stars) the stars of the last few cars, newest last
	slots = {} :: { [string]: string }, -- kind -> the slot it last broke on (the next one picks another wheel)
}
FaultService.history = history

local function weighted<T>(items: { T }, weightOf: (T) -> number): T?
	local total = 0
	for _, it in items do
		total += weightOf(it)
	end
	if total <= 0 then
		return nil
	end
	local r = rng:NextNumber() * total
	for _, it in items do
		r -= weightOf(it)
		if r <= 0 then
			return it
		end
	end
	return items[#items]
end

local function slotsOf(kind: string): { string }
	local out = {}
	for _, slotName in CarParts.SlotOrder do
		local slot = CarParts.Slots[slotName]
		if slot.kind == kind and slot.faultable then
			table.insert(out, slotName)
		end
	end
	return out
end

local function variantsOf(kind: string, level: number, trap: boolean): { Faults.Variant }
	local out = {}
	for _, v in Faults.Variants do
		local geared = v.gear == nil or (FaultService.gearOpen ~= nil and FaultService.gearOpen(v.gear))
		if v.kind == kind and level >= (v.minLevel or 1) and (v.trap == true) == trap and geared and (v.feature == nil or Config.feature(v.feature)) then
			table.insert(out, v)
		end
	end
	return out
end

-- a kind's weight (fault_mix v0.2 §3 ②): 10 for each ordinary fault line it has open now, times Faults.KindScale
local function kindWeight(kind: string, level: number): number
	return 10 * #variantsOf(kind, level, false) * (Faults.KindScale[kind] or 1)
end

-- pick a variant, keeping away from the variants of the last few cars when there is another choice (and from `avoid`)
local function pickVariant(kind: string, level: number, trap: boolean, avoid: { [string]: boolean }?): Faults.Variant?
	local all = variantsOf(kind, level, trap)
	if avoid then
		local kept = {}
		for _, v in all do
			if not avoid[v.id] then
				table.insert(kept, v)
			end
		end
		all = kept
	end
	local fresh = {}
	for _, v in all do
		if not table.find(history.variants, v.id) then
			table.insert(fresh, v)
		end
	end
	return weighted(if #fresh > 0 then fresh else all, function(v)
		return v.weight
	end)
end

-- a slot of this kind, not the one it last broke on when there's another (a flat front-left twice running)
local function otherSlot(kind: string, slots: { string }): string
	local last = history.slots[kind]
	local left = {}
	for _, s in slots do
		if s ~= last then
			table.insert(left, s)
		end
	end
	local from = if #left > 0 then left else slots
	return from[rng:NextInteger(1, #from)]
end

-- how deep a kind's parts sit (PartGraph depth: 1 = reached straight away, 2 = something else off first ...)
local function kindDepth(kind: string): number
	local d = 0
	for _, slotName in slotsOf(kind) do
		d = math.max(d, PartGraph.depth("Sedan", slotName))
	end
	return d
end

export type PlanOpts = {
	noTrap: boolean?,
	slots: { string }?,
	avoid: { [string]: boolean }?,
	prefer: string?,
	count: number?, -- (stars) exactly this many faults instead of FaultsByLevel
	maxDepth: number?, -- (stars) no kind deeper than this
	needDepth: number?, -- (stars) the first fault this deep when one is open
	gap: number?, -- (stars) the first fault isn't the main kind of the last `gap` cars
}

-- plan the faults of the next customer car. opts.noTrap = never a trap (hurry customer); opts.slots = exact slots
-- (first job / play tests: their usual non-trap variant); opts.avoid = kinds / variant ids to leave out (the first
-- car after the tutorial: not its three faults again), opts.prefer = the first fault's kind when it's open
function FaultService.plan(level: number, opts: PlanOpts?): { Fault }
	local o = opts or {}
	local plan: { Fault } = {}
	if o.slots then
		for _, slotName in o.slots do
			local kind = CarParts.Slots[slotName].kind
			local v = variantsOf(kind, math.huge, false)[1]
			table.insert(plan, { slot = slotName, variant = if v then v.id else "" })
		end
		return plan
	end
	-- a level-up opened new kinds: each shows up within the next 3 cars, and no trap on the first car after it
	local justLeveled = level > history.lastLevel and history.lastLevel > 0
	for kind, at in Config.FaultUnlock do
		if at > history.lastLevel and at <= level and history.lastLevel > 0 then
			history.newKinds[kind] = 3
		end
	end
	history.lastLevel = level

	local open = {}
	for kind, at in Config.FaultUnlock do
		if level >= at or (FaultService.gearOpen and FaultService.gearOpen(kind)) then
			table.insert(open, kind)
		end
	end
	table.sort(open)
	local range = Config.FaultCount
	for _, row in Config.FaultsByLevel do
		if level <= row.upTo then
			range = row.count
			break
		end
	end
	local n = o.count or rng:NextInteger(range[1], range[2])
	-- the first fault is never the last car's main kind while another kind is open (it was "no three in a row":
	-- batteries came 4 times and pads twice running in the first half hour — wr-gamer fun 1 ③)
	local k = history.kinds
	local banned = k[#k]
	-- (stars: the first fault isn't any of the last `gap` cars' main kinds — car_difficulty §3 rule 4)
	local recentKinds: { [string]: boolean } = {}
	if o.gap then
		for j = math.max(1, #k - o.gap + 1), #k do
			recentKinds[k[j]] = true
		end
	end
	local function deepOK(kk: string): boolean
		return o.maxDepth == nil or kindDepth(kk) <= o.maxDepth
	end
	local avoid = o.avoid or {}
	local used = {}
	for i = 1, n do
		local kind: string? = nil
		if i == 1 then
			if o.prefer and table.find(open, o.prefer) and not avoid[o.prefer] then
				kind = o.prefer
			end
			for newKind, left in history.newKinds do
				if not kind and not avoid[newKind] and rng:NextNumber() < 1 / left then
					kind = newKind
				end
			end
		end
		if not kind then
			local choices = {}
			for _, kk in open do
				if kk ~= banned and not used[kk] and not avoid[kk] and deepOK(kk) and not (i == 1 and recentKinds[kk]) then
					table.insert(choices, kk)
				end
			end
			if i == 1 and o.needDepth then
				local deep = {}
				for _, kk in choices do
					if kindDepth(kk) >= o.needDepth then
						table.insert(deep, kk)
					end
				end
				if #deep > 0 then
					choices = deep
				end
			end
			if #choices == 0 then
				for _, kk in open do
					if not used[kk] and not avoid[kk] and deepOK(kk) then
						table.insert(choices, kk)
					end
				end
			end
			kind = weighted(choices, function(kk)
				return kindWeight(kk, level)
			end)
		end
		if not kind then
			break
		end
		used[kind] = true
		local slots = slotsOf(kind)
		local v = pickVariant(kind, level, false, avoid)
		if #slots > 0 and v then
			table.insert(plan, { slot = otherSlot(kind, slots), variant = v.id })
		end
	end
	-- a trap now and then (§2-4): replaces one fault, at most one per car
	local p = 0
	for _, row in Faults.TrapChance do
		if level <= row.upTo then
			p = row.p
			break
		end
	end
	if #plan > 0 and not o.noTrap and not justLeveled and rng:NextNumber() < p then
		-- the trap takes the place of one fault, drawn from the open kinds that have a trap
		local trapKinds = {}
		for _, kk in open do
			if #variantsOf(kk, level, true) > 0 and (kk ~= banned or #plan > 1) and not avoid[kk] then
				table.insert(trapKinds, kk)
			end
		end
		local kind = weighted(trapKinds, function(kk)
			return kindWeight(kk, level)
		end)
		local trap = kind and pickVariant(kind, level, true)
		local slots = kind and slotsOf(kind) or {}
		if trap and #slots > 0 then
			local at = otherSlot(kind :: string, slots)
			-- (a banned kind never takes the first place: that one is the car's main kind, never three in a row)
			local i = if kind == banned and #plan > 1 then rng:NextInteger(2, #plan) else rng:NextInteger(1, #plan)
			for j, f in plan do
				if CarParts.Slots[f.slot].kind == kind and not (kind == banned and j == 1) then
					i = j -- the same kind already on this car: that one becomes the trap (no slot twice)
				end
			end
			plan[i] = { slot = at, variant = trap.id }
		end
	end
	-- remember
	for _, f in plan do
		history.slots[CarParts.Slots[f.slot].kind] = f.slot
	end
	if plan[1] then
		local kind1 = CarParts.Slots[plan[1].slot].kind
		table.insert(history.kinds, kind1)
		if #history.kinds > 5 then
			table.remove(history.kinds, 1)
		end
		for kind in history.newKinds do
			if used[kind] then
				history.newKinds[kind] = nil
			else
				history.newKinds[kind] -= 1
				if history.newKinds[kind] <= 0 then
					history.newKinds[kind] = nil
				end
			end
		end
	end
	-- the variants of the last few cars: one list a car (this one's at the end, the oldest dropped), `variants` = all of
	-- them flat. (Until 10-22 one shared list took every older car's too, and the rule faded out after a few cars.)
	local mine = {}
	for _, f in plan do
		table.insert(mine, f.variant)
	end
	table.insert(history.recent, mine)
	while #history.recent > Config.VariantMemory do
		table.remove(history.recent, 1)
	end
	history.variants = {}
	for _, car in history.recent do
		for _, id in car do
			table.insert(history.variants, id)
		end
	end
	return plan
end

-------------------------------------------------------------------------------------------------------------------
-- Car stars (docs/design/car_difficulty.md v0.1, Config.Features.Stars): a star is drawn first (by level, with the
-- rhythm rules), then faults in one of that star's shapes (Config.StarRules); the car's star is what it really got.
-------------------------------------------------------------------------------------------------------------------

-- a fault set's star: the deepest fault and how many (§2: ★3 = depth 3 or three faults, ★2 = depth 2 or two)
function FaultService.starsOf(slots: { string }): number
	local deepest = 0
	for _, slotName in slots do
		deepest = math.max(deepest, PartGraph.depth("Sedan", slotName))
	end
	local n = #slots
	if deepest >= 4 then
		return 5
	elseif deepest == 3 or n >= 3 then
		return 3
	elseif deepest == 2 or n == 2 then
		return 2
	end
	return 1
end

-- one fault's labor units (§4: by depth)
function FaultService.luOf(slotName: string): number
	local d = math.max(1, PartGraph.depth("Sedan", slotName))
	return Config.StarLU[math.min(d, #Config.StarLU)]
end

local function slotsIn(plan: { Fault }): { string }
	local out = {}
	for _, f in plan do
		table.insert(out, f.slot)
	end
	return out
end

local function snapshot(): { [string]: any }
	return {
		kinds = table.clone(history.kinds),
		variants = table.clone(history.variants),
		recent = table.clone(history.recent), -- (each car's list is never changed after: a shallow copy is enough)
		lastLevel = history.lastLevel,
		newKinds = table.clone(history.newKinds),
		slots = table.clone(history.slots),
	}
end

local function restore(s: { [string]: any })
	for k, v in s do
		history[k] = v
	end
end

-- the star to aim for: the level's chances, the extra players' bonus, the rhythm rules
local function aim(level: number, players: number): number
	local row = Config.CarStars[#Config.CarStars]
	for _, r in Config.CarStars do
		if level <= r.upTo then
			row = r
			break
		end
	end
	local w = table.clone(row.w)
	local bonus = math.min(w[1] or 0, math.max(0, players - 1) * Config.Rhythm.coopStarBonus * 100)
	if #w >= 3 and bonus > 0 then
		w[1] -= bonus
		w[3] += bonus
	end
	-- stars without rules yet (★4 / ★5 before their update) fall to the highest one that has
	local top = #Config.StarRules
	for s = #w, top + 1, -1 do
		w[top] = (w[top] or 0) + w[s]
		w[s] = nil
	end
	local stars = {}
	for s = 1, #w do
		table.insert(stars, s)
	end
	local star = weighted(stars, function(s)
		return w[s] or 0
	end) or 1
	-- after hardInARow hard cars, an easy one
	local h = history.stars
	local hard = #h >= Config.Rhythm.hardInARow
	for j = #h - Config.Rhythm.hardInARow + 1, #h do
		if j < 1 or h[j] < 3 then
			hard = false
		end
	end
	if hard then
		star = math.min(star, 2)
	end
	-- a kind the level just opened shows up on an easier car (rule 2: learn only the new thing)
	local opening = next(history.newKinds) ~= nil
	if not opening and history.lastLevel > 0 and level > history.lastLevel then
		for _, at in Config.FaultUnlock do
			if at > history.lastLevel and at <= level then
				opening = true
			end
		end
	end
	if opening then
		star = math.max(1, star - 1)
	end
	return star
end

-- the next customer car's faults by stars: (plan, star). opts = FaultService.plan's (avoid / prefer / noTrap)
function FaultService.planStars(level: number, opts: PlanOpts?, players: number?): ({ Fault }, number)
	local o = opts or {}
	local target = aim(level, players or 1)
	local function done(plan: { Fault }): ({ Fault }, number)
		local star = FaultService.starsOf(slotsIn(plan))
		table.insert(history.stars, star)
		if #history.stars > 5 then
			table.remove(history.stars, 1)
		end
		return plan, star
	end
	for star = target, 1, -1 do
		local shapes = table.clone(Config.StarRules[star] or {})
		for i = #shapes, 2, -1 do -- (a shuffled order: each shape gets its turn)
			local j = rng:NextInteger(1, i)
			shapes[i], shapes[j] = shapes[j], shapes[i]
		end
		for _, shape in shapes do
			local before = snapshot()
			local plan = FaultService.plan(level, {
				avoid = o.avoid,
				prefer = o.prefer,
				noTrap = o.noTrap or star == 1, -- (traps on ★2~★4 cars only, §5-4)
				count = rng:NextInteger(shape.count[1], shape.count[2]),
				maxDepth = shape.maxDepth,
				needDepth = shape.needDepth,
				gap = Config.Rhythm.sameKindGap,
			})
			if #plan > 0 and FaultService.starsOf(slotsIn(plan)) == star then
				return done(plan)
			end
			restore(before)
		end
	end
	return done(FaultService.plan(level, o)) -- (nothing fitted: the old way, the star it got)
end

-- a trap's visible clue on the car, and the prompt that fixes it (the fix action from Faults.Actions)
local function trapClue(car: Model, slotName: string, fix: string)
	local part = CarFactory.slotPart(car, slotName)
	local holder: BasePart? = nil
	if fix == "clamp" and part then
		-- the hold-down clamp's bolt comes in loose (no prompt: the wrench on that bolt is the fix — slotOK)
		local head = FaultService.clampBolt(part)
		if head and head:GetAttribute("Tight") == true then
			head:SetAttribute("Tight", false)
			CarFactory.seatBolt(head)
			part:SetAttribute("BoltsRemaining", ((part:GetAttribute("BoltsRemaining") :: number?) or 1) - 1)
		end
		return
	end
	if fix == "clean" and part then
		-- white crust on both battery terminals (the car's cable clamps: a new battery doesn't take it away)
		-- (on the lead posts themselves — the battery mesh has real posts, the pinch nuts sit beside them: battery_posts_v1)
		for i, post in { "Neg", "Pos" } do
			local at = CarParts.batteryPost(part, post)
			if at then
				local crust = Instance.new("Part")
				crust.Name = "Issue_" .. slotName .. "_" .. i
				crust.Size = Vector3.new(0.2, 0.08, 0.2)
				crust.CFrame = CFrame.new(at + Vector3.new(0, 0.01, 0))
				crust.Color = Color3.fromRGB(235, 240, 225)
				crust.Material = Enum.Material.Sand
				crust.Anchored = true
				crust.CanCollide = false
				crust.Parent = car:FindFirstChild("Decor")
				holder = holder or crust
			end
		end
	elseif fix == "polish" and part then
		-- a scuff line across the bumper (polishing takes it off; a new bumper also has none). It lies on the painted face of
		-- the car's 3D bumper — CarParts.ScratchFace, measured per type and end — not on the root box, which sits 0.3-0.4 inside the
		-- mesh (a line there was buried: the child never found it before the polish, 10-23). Pale on a dark paint, grey on a pale one.
		local root = CarFactory.root(part)
		local scratch = Instance.new("Part")
		scratch.Name = "Issue_" .. slotName
		-- (the same picture the polish screen draws — scratch_marks_A, 1024x512, 3 lines rising to the right — on a see-through
		-- plate, so the scratch seen from outside is the one you polish. The plate is the anchor: Scrub / PromptFocus read its place.)
		scratch.Size = Vector3.new(3.0, 1.5, 0.04) -- (bigger than the polish picture's 2.4: from a few studs away the thin lines must still read)
		local ends = CarParts.ScratchFace[(car:GetAttribute("CarType") :: string?) or "Sedan"] or CarParts.ScratchFace.Sedan
		local face = if slotName == "Bumper_R" then ends.R else ends.F
		local out = if root.CFrame.LookVector:Dot(car:GetPivot().LookVector) > 0 then -1 else 1 -- (the root's side that faces away from the car)
		scratch.CFrame = root.CFrame * CFrame.new(1.2, face.dy, out * face.dz)
		local bodyFolder = car:FindFirstChild("Body")
		local shell = bodyFolder and bodyFolder:FindFirstChild("Shell")
		local paintPart = shell and shell:FindFirstChildWhichIsA("BasePart", true)
		local c = if paintPart then paintPart.Color else Color3.fromRGB(80, 160, 160)
		local pale = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B > 0.7
		scratch.Transparency = 1
		local gui = Instance.new("SurfaceGui")
		gui.Name = "Mark"
		gui.Face = if out == -1 then Enum.NormalId.Front else Enum.NormalId.Back
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 340
		gui.LightInfluence = 1
		gui.Parent = scratch
		local img = Instance.new("ImageLabel")
		img.BackgroundTransparency = 1
		img.Size = UDim2.fromScale(1, 1)
		img.Image = "rbxassetid://115482987106213" -- (UIStyle.Image.Scratch)
		img.ImageColor3 = if pale then Color3.fromRGB(40, 44, 54) else Color3.fromRGB(235, 235, 240) -- (grey on a pale paint, as the polish screen's ink)
		img.Parent = gui
		scratch.Material = Enum.Material.SmoothPlastic
		scratch.Anchored = true
		scratch.CanCollide = false
		scratch.Parent = car:FindFirstChild("Decor")
		holder = scratch
	elseif fix == "balance" and part then
		-- the clean spot on the rim where a wheel weight fell off (the clue you can see)
		local root = CarFactory.root(part)
		local mark = Instance.new("Part")
		mark.Name = "Issue_" .. slotName
		mark.Size = Vector3.new(0.05, 0.35, 0.18)
		mark.CFrame = root.CFrame * CFrame.new(0, 0.62, 0.2)
		mark.Color = Color3.fromRGB(245, 245, 240)
		mark.Material = Enum.Material.SmoothPlastic
		mark.Anchored = true
		mark.CanCollide = false
		mark.Parent = part
		return -- fixed at the Wheel Balancer, no prompt on the car
	elseif fix == "hang" and part then
		-- the snapped rubber hanger, dangling from the floor pan
		local root = CarFactory.root(part)
		local hanger = Instance.new("Part")
		hanger.Name = "Issue_" .. slotName
		hanger.Size = Vector3.new(0.25, 0.6, 0.25)
		hanger.CFrame = CFrame.new(root.Position + Vector3.new(1.2, 0.55, 0))
		hanger.Color = Color3.fromRGB(25, 25, 25)
		hanger.Material = Enum.Material.Rubber
		hanger.Anchored = true
		hanger.CanCollide = false
		hanger.Parent = car:FindFirstChild("Decor")
		holder = hanger
	end
	if not holder then
		return
	end
	local action = Faults.Actions[fix]
	local p = Instance.new("ProximityPrompt")
	p.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton -- one E at a time: the nearest
	p.Name = "FixPrompt"
	p.KeyboardKeyCode = Enum.KeyCode.E
	-- (the terminals / the light scratch with mini-games on: a tap opens the scrub / polish instead of the hold —
	-- MinigameService "Scrub" / "Polish")
	p.HoldDuration = if (fix == "clean" or fix == "polish") and Config.minigameKind(if fix == "clean" then "Scrub" else "Polish") then 0 else action.hold
	p.MaxActivationDistance = Config.PromptDistance
	p.RequiresLineOfSight = false
	Locale.tag(p, action.act)
	Locale.tag(p, "part." .. CarParts.Slots[slotName].kind, nil, "ObjectText")
	p.Parent = holder
	p.Triggered:Connect(Guard.prompt(p, "Fix", 0.3, function(player)
		if FaultService.onTrapAction then
			FaultService.onTrapAction(car, slotName, player)
		end
	end))
end

FaultService.onTrapAction = nil :: ((car: Model, slotName: string, player: Player) -> ())?

-- the battery's hold-down clamp bolt (CarParts.Blocks.Battery: the one that isn't a terminal)
function FaultService.clampBolt(part: Instance): BasePart?
	for _, d in part:GetChildren() do
		if d:IsA("BasePart") and d:GetAttribute("Bolt") and d:GetAttribute("Fastener") ~= "Terminal" then
			return d
		end
	end
	return nil
end
-- set by Main: kinds opened by equipment rather than level (Muffler <- the hydraulic lift)
FaultService.gearOpen = nil :: ((kind: string) -> boolean)?
FaultService.trapClue = trapClue

-- the trap is fixed: its clue goes, the issue is cleared
function FaultService.clearIssue(car: Model, slotName: string)
	car:SetAttribute("Issue_" .. slotName, nil)
	local decor = car:FindFirstChild("Decor")
	for _, d in (if decor then decor:GetChildren() else {}) do
		if d.Name:sub(1, #("Issue_" .. slotName)) == "Issue_" .. slotName then
			d:Destroy()
		end
	end
end

-- a slot is fine when its part isn't worn out and no trap issue is left on it
function FaultService.slotOK(car: Model, slotName: string): boolean
	local part = CarFactory.slotPart(car, slotName)
	local issue = car:GetAttribute("Issue_" .. slotName)
	if issue == "balance" and part and part:GetAttribute("Balanced") then
		return true -- a wheel off the balancer (or a new one) is in
	end
	if issue == "clamp" and part then
		local head = FaultService.clampBolt(part)
		if head and head:GetAttribute("Tight") == true then
			return not isBroken(part) -- the clamp tightened (or a new battery bolted in)
		end
	end
	return not isBroken(part) and issue == nil
end

-- the slots that make symptoms right now (worn parts + open trap issues)
function FaultService.symptomSlots(car: Model): { [string]: boolean }
	local out = {}
	for _, slotName in CarParts.SlotOrder do
		if not FaultService.slotOK(car, slotName) then
			out[slotName] = true
		end
	end
	return out
end

-- put a plan on a fresh car: worn parts get Condition 0..30, everything else stays healthy; traps get their issue
function FaultService.roll(car: Model, plan: { Fault }): { string }
	local brokenSet, slots, variants = {}, {}, {}
	for _, f in plan do
		local v = Faults.ById[f.variant]
		table.insert(slots, f.slot)
		table.insert(variants, f.slot .. "=" .. f.variant)
		-- (the clamp trap needs the clamp bolt there, tight: without it the battery is just worn out — never a car
		-- that can't be finished)
		local clampOk = false
		if v and v.fix == "clamp" then
			local part = CarFactory.slotPart(car, f.slot)
			local head = part and FaultService.clampBolt(part)
			clampOk = head ~= nil and head:GetAttribute("Tight") == true
		end
		if not v or v.fix == "replace" or (v.fix == "clamp" and not clampOk) then
			brokenSet[f.slot] = true
		else
			car:SetAttribute("Issue_" .. f.slot, v.fix)
		end
	end
	for _, slotName in CarParts.SlotOrder do
		local part = CarFactory.slotPart(car, slotName)
		if part then
			local range = if brokenSet[slotName] then Config.FaultCondition else Config.HealthyCondition
			part:SetAttribute("Condition", rng:NextInteger(range[1], range[2]))
			FaultService.paint(part)
		end
	end
	for _, f in plan do
		local v = Faults.ById[f.variant]
		if v and v.fix ~= "replace" then
			trapClue(car, f.slot, v.fix)
		end
		if v and v.fix == "balance" then
			local w = CarFactory.slotPart(car, f.slot)
			if w then
				w:SetAttribute("Balanced", false)
			end
		end
	end
	-- a look for the 3D (CarLook picks <set>_<Look> when there is one): a flat tyre, a dented front bumper
	for _, f in plan do
		local part = CarFactory.slotPart(car, f.slot)
		if part and f.variant == "TIRE_FLAT" then
			part:SetAttribute("Look", "Flat")
			-- the culprit: a nail head in the tread, somewhere round the tire (you spin the wheel to find it)
			local old = part:FindFirstChild("Nail")
			if old then
				old:Destroy()
			end
			local tire = part:FindFirstChild("Tire") :: BasePart?
			local r = (if tire then tire.Size.Y / 2 else 1.4) + 0.02
			local a = math.rad(math.random(110, 250)) -- (on the far / lower side, not the first thing you see)
			local nail = Instance.new("Part")
			nail.Name = "Nail"
			nail.Shape = Enum.PartType.Cylinder
			nail.Size = Vector3.new(0.08, 0.18, 0.18)
			nail.Material = Enum.Material.Metal
			nail.Color = Color3.fromRGB(200, 200, 205)
			nail.Anchored = true
			nail.CanCollide = false
			nail.CanTouch = false
			nail:SetAttribute("Keep", true) -- (CarLook leaves it showing over the tire mesh)
			nail:SetAttribute("Nail", true)
			local snap = CarFactory.snapCFrame(part)
			nail.CFrame = snap * CFrame.new(-0.25, math.cos(a) * r, math.sin(a) * r) * CFrame.Angles(a, 0, 0) * CFrame.Angles(0, 0, math.rad(90))
			nail.Parent = part
		elseif part and f.slot == "Bumper_F" and brokenSet[f.slot] then
			part:SetAttribute("Look", "Dented")
		end
	end
	car:SetAttribute("Faults", table.concat(slots, ","))
	car:SetAttribute("Variants", table.concat(variants, ","))
	return slots
end

-- the variant id on a slot of this car ("" if none)
function FaultService.variantOf(car: Model, slotName: string): string
	for pair in ((car:GetAttribute("Variants") :: string?) or ""):gmatch("[^,]+") do
		local s, v = pair:match("^(.-)=(.+)$")
		if s == slotName then
			return v
		end
	end
	return ""
end

CarFactory.hooks.sag = FaultService.sag
CarFactory.hooks.lean = FaultService.lean

return FaultService
