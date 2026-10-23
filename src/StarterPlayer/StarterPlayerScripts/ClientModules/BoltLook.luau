-- Bolts that look and move like bolts (rival_upgrade A③ 1·10, user 10-22: "볼트 풀 때, 볼트가 돌아간다거나").
-- The server's bolt head is a plain cylinder (it stays for clicks, hidden on this screen): here it wears a hex head and
-- a threaded shank, welded to it, so a turn shows. When the server says a bolt came loose / went tight (Effect "bolt"),
-- it turns the real way — out counter-clockwise by its thread length, a small "tock" at the end; in clockwise and a
-- snug stop — at the tool's own pace: a wrench in half-turn bites, a ratchet in one go, the impact wrench in a burst.
-- Only ever as long as the hold before it (it plays after the server's yes), never blocking the next press.
-- Local only (my screen), nothing new made per turn: each bolt's look is built once and reused.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local SoundPlayer = require(script.Parent.SoundPlayer)

local BoltLook = {}

local OUT = 0.18 -- studs a loose bolt stands out (CarFactory.seatBolt)
local TOCK = 0.05 -- the little overshoot as it pops free
local PACE = { -- seconds, turns, half-turn bites
	Wrench = { t = 0.34, turns = 2, bites = 4 },
	RatchetWrench = { t = 0.22, turns = 2.5, bites = 0 },
	ImpactWrench = { t = 0.15, turns = 3, bites = 0 },
}
local DEFAULT = { t = 0.26, turns = 2, bites = 0 }

local looks: { [BasePart]: { Part } } = {}
local playing: { [BasePart]: { att: Attachment, loosen: boolean, start: number, pace: any } } = {}

local function attOf(head: BasePart): Attachment?
	local part = head.Parent
	local root = part and (if part:IsA("BasePart") then part else (part :: Model).PrimaryPart)
	return root and root:FindFirstChild((head:GetAttribute("Attachment") :: string?) or "") :: Attachment?
end

local function piece(name: string, shape: Enum.PartType, size: Vector3): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = shape
	p.Size = size
	p.Material = Enum.Material.Metal
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Massless = true
	return p
end

-- a hex head (three flat boxes 60° apart) + the shank behind it, welded to the server's head
local function dress(head: BasePart)
	if looks[head] then
		return
	end
	local set = {}
	local across = head.Size.Y * 0.86
	for i = 0, 2 do
		local f = piece("Hex" .. i, Enum.PartType.Block, Vector3.new(head.Size.X * 0.8, across, across / math.sqrt(3)))
		f.CFrame = head.CFrame * CFrame.Angles(math.rad(60 * i), 0, 0)
		table.insert(set, f)
	end
	local shank = piece("Shank", Enum.PartType.Cylinder, Vector3.new(OUT + 0.06, head.Size.Y * 0.42, head.Size.Y * 0.42))
	shank.CFrame = head.CFrame * CFrame.new(-(head.Size.X * 0.4 + (OUT + 0.06) / 2), 0, 0)
	shank.Material = Enum.Material.DiamondPlate -- (the thread's ridges)
	table.insert(set, shank)
	local function paint()
		for _, p in set do
			p.Color = if p.Name == "Shank" then head.Color:Lerp(Color3.new(0.35, 0.35, 0.38), 0.6) else head.Color
		end
	end
	paint()
	head:GetPropertyChangedSignal("Color"):Connect(paint)
	for _, p in set do
		local w = Instance.new("WeldConstraint")
		w.Part0 = head
		w.Part1 = p
		w.Parent = p
		p.Anchored = false
		p.Parent = head
	end
	head.LocalTransparencyModifier = 1
	looks[head] = set
	head.Destroying:Connect(function()
		looks[head] = nil
		playing[head] = nil
	end)
end

local function watch(root: Instance)
	for _, d in root:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("Bolt") then
			dress(d)
		end
	end
	root.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") and d:GetAttribute("Bolt") then
			task.defer(dress, d)
		end
	end)
end

-- the server's yes: turn it the real way (Effects "bolt")
function BoltLook.turn(head: BasePart, loosen: boolean, tool: string?)
	local att = attOf(head)
	if not att or not head.Anchored then
		return
	end
	dress(head)
	playing[head] = {
		att = att,
		loosen = loosen,
		start = os.clock(),
		pace = PACE[tool or ""] or DEFAULT,
	}
end

-- a part whose last bolt let go slides out of its spot (A③ 3): from where it sat, a little wobble, over to where the
-- server put it — 0.25 s, up to 0.5 s for the heavy ones. Never in the way: picked up meanwhile = it stops there.
local moving: { [Instance]: { from: CFrame, rootTo: CFrame, rel: { [BasePart]: CFrame }, start: number, t: number, hinge: Vector3?, path: { CFrame }? } } = {}
local STEP = 0.28 -- seconds a step of a bay part's way out (CarParts.Exit), the whole way 1.4 s at most

function BoltLook.partOut(part: Instance, from: CFrame)
	local root = if part:IsA("BasePart") then part else (part :: Model).PrimaryPart
	if not root then
		return
	end
	local rel = {}
	for _, d in part:GetDescendants() do
		if d:IsA("BasePart") and d.Anchored then
			rel[d] = root.CFrame:ToObjectSpace(d.CFrame)
		end
	end
	rel[root] = CFrame.identity
	local kg = (part:GetAttribute("MassKg") :: number?) or 5
	-- a bay part with a way out from the 3D (v2.2 P_Exit_1..n): through each pose in turn, the way it really comes out
	-- (two ends slid off their necks, lifted, out from under the snorkel …) — the server rests it at the last one
	local exit = CarParts.exitOf(part:GetAttribute("Slot") :: string?, part:GetAttribute("Fits") :: string?)
	local path = nil
	if exit then
		path = {}
		for _, e in exit do
			table.insert(path, from * e)
		end
	end
	local t = if path then math.min(1.4, STEP * #path) else 0.25 + math.min(0.25, kg / 80)
	moving[part] = { from = from, rootTo = root.CFrame, rel = rel, start = os.clock(), t = t, path = path }
end

-- the hood swings on its hinge (A③ 5) instead of jumping open / shut: about the hinge point, 0.45 s, a soft stop
local SWING = 0.45
function BoltLook.swing(part: Instance, from: CFrame)
	local root = if part:IsA("BasePart") then part else (part :: Model).PrimaryPart
	local hinge = root and root:FindFirstChild("Hinge") :: Attachment?
	if not root or not hinge then
		return
	end
	BoltLook.partOut(part, from)
	local m = moving[part]
	if m then
		m.t = SWING
		m.hinge = hinge.WorldPosition
	end
end

local function slide(now: number)
	for part, m in moving do
		local k = math.clamp((now - m.start) / m.t, 0, 1)
		local keep = if m.hinge then "Installed" else "Free"
		local stop = k >= 1 or part:GetAttribute("State") ~= keep or not part.Parent
		local pose = m.rootTo
		if not stop and m.hinge then
			local e = 1 - (1 - k) ^ 2
			local axis, angle = (m.rootTo * m.from:Inverse()).Rotation:ToAxisAngle()
			local h = CFrame.new(m.hinge)
			pose = h * CFrame.fromAxisAngle(axis, angle * e) * h:Inverse() * m.from
		elseif not stop and m.path then
			-- step by step: each leg the same share of the time, eased in and out so each pose reads
			local n = #m.path
			local i = math.min(math.floor(k * n), n - 1)
			local a = if i == 0 then m.from else m.path[i]
			local u = k * n - i
			pose = a:Lerp(m.path[i + 1], u * u * (3 - 2 * u))
		elseif not stop then
			local e = 1 - (1 - k) ^ 3 -- (eases out: quick off the spot, settles)
			local lift = math.sin(math.pi * k) * 0.5
			local wobble = math.sin(k * math.pi * 3) * (1 - k) * math.rad(6)
			pose = m.from:Lerp(m.rootTo, e) * CFrame.new(0, lift, 0) * CFrame.Angles(0, 0, wobble)
		else
			moving[part] = nil
			if part:GetAttribute("State") ~= keep then
				continue -- (picked up: the carry weld has it now)
			end
		end
		for p, r in m.rel do
			if p.Parent then
				p.CFrame = pose * r
			end
		end
	end
end

local function step()
	local now = os.clock()
	for head, p in playing do
		local k = math.clamp((now - p.start) / p.pace.t, 0, 1)
		local done = k >= 1 or not head.Parent or not head.Anchored
		-- (the turn: steady, or in half-turn bites with a short regrip between)
		local turn = k
		if p.pace.bites > 0 then
			local n = p.pace.bites
			local i = math.min(math.floor(k * n), n - 1)
			turn = (i + math.clamp((k * n - i) / 0.7, 0, 1)) / n
		end
		local angle = turn * p.pace.turns * 2 * math.pi * (if p.loosen then 1 else -1) -- (seen from outside: out = counter-clockwise)
		local along = if p.loosen then OUT * k else OUT * (1 - k)
		if p.loosen and k > 0.8 then
			along = OUT + TOCK * math.sin((k - 0.8) / 0.2 * math.pi) -- tock: it pops a hair past and settles
		end
		if done then
			playing[head] = nil
			if head.Parent then
				-- the moment it pops free at the end of a loosening turn: a small "tok" (boltPop)
				if p.loosen and k >= 1 and head.Anchored then
					SoundPlayer.play("boltPop", head.Position)
				end
				-- back to exactly where the server has it
				head.CFrame = p.att.WorldCFrame * CFrame.new(if head:GetAttribute("Tight") == true then 0 else OUT, 0, 0)
			end
		else
			head.CFrame = p.att.WorldCFrame * CFrame.new(along, 0, 0) * CFrame.Angles(angle, 0, 0)
		end
	end
end

function BoltLook.start()
	task.spawn(function()
		local cars = workspace:WaitForChild("Cars", 120)
		if cars then
			watch(cars)
		end
	end)
	RunService.RenderStepped:Connect(function()
		if next(moving) then
			pcall(slide, os.clock())
		end
		if next(playing) then
			pcall(step) -- (after the slide: a bolt turning on a moving part follows its spot)
		end
	end)
end

return BoltLook
