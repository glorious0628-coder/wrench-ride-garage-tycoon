-- The shared plate of the small mini-game screens (Balance, Fill — and any kind that gets a plate; the Scrub works right
-- on the 3D scene and has none): a steel plate with bolts above the tool bar, ONE short title line (a yellow word),
-- a start cue word (big, 0.6 s), a round close button (leave any time: nothing lost, no Good), the green result pill
-- (+ twinkle on Perfect) and the "keep doing this one myself" chip. Everything sits on one centre axis (user 10-22: "I like
-- centre alignment"). The kind builds its own gauge inside `frame.panel` (between the title and the bottom edge) and says
-- what happens when a thing is tapped. Approved mocks: notes/gpt/wr-ui/mock/balance_mock1.png, fill_mock2.png (+ parts).
--
--   local f = MiniFrame.new({ name = "Fill", kind = "Coolant", ratio = 0.9, titleKey = "mg.fill", onLeave = function() ... end })
--   f.panel  -- Frame (the plate); f:open(auto, cueKey)  f:setTitle(key)  f:notice(key, seconds)  f:finish(...)  f:hide()
--   f.open_ (bool) · f.finished (bool) · f.token (changes on every open / finish / hide: guard delayed work with it)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarParts = require(ReplicatedStorage.Shared.CarParts)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local HUD = require(script.Parent.HUD)
local UIKit = require(script.Parent.UIKit)
local UIStyle = require(script.Parent.UIStyle)

local MiniFrame = {}
MiniFrame.__index = MiniFrame

local C = UIStyle.Color

export type Options = {
	name: string,
	kind: string, -- the mini-game's kind id ("Balance", "Coolant", ...): the keep chip answers with it
	ratio: number, -- plate height / width
	reserve: number?, -- room kept free above the plate for the result pill (default 72)
	titleKey: string,
	onLeave: () -> (), -- the close button: tell the server (quit) and hide
	extraFit: ((self: any, w: number, h: number, x: number, room: number) -> ())?,
}

function MiniFrame.new(o: Options)
	local self = setmetatable({}, MiniFrame)
	self.o = o
	self.open_ = false
	self.finished = false
	self.token = 0
	self.titleKey = o.titleKey
	local gui = HUD.gui()

	local panel = UIKit.plate(gui, { name = o.name, bolts = true, z = 5 }) :: any
	panel.AnchorPoint = Vector2.new(0.5, 1)
	panel.Visible = false
	self.panel = panel
	-- (the title: one short line, never near the corner bolts — its box is only 62 % of the plate's width)
	self.title = UIKit.text(panel, { name = "Title", key = o.titleKey, rich = true, font = "Title", anchor = Vector2.new(0.5, 0), pos = UDim2.fromScale(0.5, 0.04), size = UDim2.fromScale(0.62, 0.12), max = 21 })
	self.title.ZIndex = 7 -- (over every gauge: a title is never half hidden under one)

	-- the result: a green pill with a check over the plate, the keep chip right under it
	local pill = Instance.new("Frame")
	pill.Name = o.name .. "Result"
	pill.AnchorPoint = Vector2.new(0.5, 0.5)
	pill.Size = UDim2.fromOffset(250, 60)
	pill.BackgroundColor3 = C.Green
	pill.BorderSizePixel = 0
	pill.ZIndex = 8
	local rc = Instance.new("UICorner")
	rc.CornerRadius = UDim.new(1, 0)
	rc.Parent = pill
	local rs = Instance.new("UIStroke")
	rs.Color = C.GreenDark
	rs.Thickness = 3
	rs.Parent = pill
	pill.Visible = false
	pill.Parent = gui
	local tick = UIKit.icon(pill, UIStyle.Icon.Check, { name = "Tick", anchor = Vector2.new(0, 0.5), pos = UDim2.fromScale(0.05, 0.5), size = UDim2.fromScale(0.6, 0.6) })
	if tick then
		tick.SizeConstraint = Enum.SizeConstraint.RelativeYY
		tick.ZIndex = 9
	end
	self.pill = pill
	self.pillLabel = UIKit.text(pill, { name = "Text", key = "mg.result.good", font = "Title", anchor = Vector2.new(1, 0.5), pos = UDim2.fromScale(0.96, 0.5), size = UDim2.fromScale(if tick then 0.74 else 0.9, 0.7), max = 28, z = 9 })
	self.keep = UIKit.button(gui, { name = o.name .. "Keep", key = "mg.keep", style = "Blue", anchor = Vector2.new(0.5, 0), size = UDim2.fromOffset(250, 40), max = 20, z = 8, onClick = function()
		Remotes.SetMinigames:FireServer({ keep = o.kind })
		self.keep.Visible = false
	end })
	self.keep.Visible = false

	-- the start cue: one big word for 0.6 s
	self.cue = UIKit.text(gui, { name = o.name .. "Cue", key = "mg.cue.tap", font = "Title", color = C.Gold, anchor = Vector2.new(0.5, 0.5), size = UDim2.fromOffset(330, 96), max = 84, z = 9 })
	self.cue.Rotation = -5
	self.cue.Visible = false

	-- leave any time: a small round close button on the plate's top-right corner
	local exitButton = UIKit.closeButton(gui, { name = o.name .. "Exit" }, function()
		if self.open_ and not self.finished then
			o.onLeave()
		end
	end)
	exitButton.ZIndex = 9
	exitButton.Visible = false
	self.exit = exitButton
	task.spawn(function() -- (the close and tick pictures first, so they are there the moment a plate opens)
		local list: { Instance } = { exitButton }
		if tick then
			table.insert(list, tick)
		end
		game:GetService("ContentProvider"):PreloadAsync(list)
	end)

	UIKit.bind(panel, function()
		self:fit()
	end)
	task.spawn(function()
		while true do
			task.wait(0.25)
			if panel.Visible then
				self:fit()
			end
		end
	end)
	return self
end

-- where the thing being worked on is on the screen, in layout px (the wheel in a wheel view, the coolant tank in the engine
-- bay); nil when there is none / it is off screen. wr-uidesign A②: the plate must not hide what the player is fixing.
local function aimPoint(): Vector2?
	local player = game:GetService("Players").LocalPlayer
	local id = player:GetAttribute("WorkCar")
	local zone = player:GetAttribute("WorkZone") :: string?
	local cars = workspace:FindFirstChild("Cars")
	local cam = workspace.CurrentCamera
	if not id or not zone or not cars or not cam then
		return nil
	end
	local car: Model? = nil
	for _, c in cars:GetChildren() do
		if c:GetAttribute("CarId") == id then
			car = c :: Model
		end
	end
	if not car then
		return nil
	end
	local at: Vector3? = nil
	local corner = zone:match("^Wheel_(%u%u)$")
	if corner then
		local wc = CarParts.type(car:GetAttribute("CarType") :: string?).WheelCenters[corner]
		at = if wc then car:GetPivot():PointToWorldSpace(wc) else nil
	else
		-- (the reservoir when it is a part, else its socket, else the radiator it sits by)
		local mech = car:FindFirstChild("MechanicalParts")
		local thing = (mech and (mech:FindFirstChild("CoolantReservoir") or mech:FindFirstChild("Radiator"))) :: Instance?
		local snap = car:FindFirstChild("Snap_CoolantReservoir", true) :: Instance?
		if snap and snap:IsA("Attachment") then
			at = snap.WorldPosition
		elseif thing then
			at = if thing:IsA("Model") then thing:GetPivot().Position elseif thing:IsA("BasePart") then thing.Position else nil
		end
	end
	if not at then
		return nil
	end
	local v, onScreen = cam:WorldToViewportPoint(at)
	if not onScreen then
		return nil
	end
	local parent = HUD.gui()
	local inset = game:GetService("GuiService"):GetGuiInset()
	local z = UIKit.zoom()
	local base = parent.AbsolutePosition
	return Vector2.new((v.X - inset.X - base.X) / z, (v.Y - inset.Y - base.Y) / z)
end

-- above the tool bar, in the gap between the tutorial strip (left) and the job card (right) when they're up — on a
-- 667 px phone a centred plate sat over the strip's end; a narrow gap makes the plate narrower (190 px at least)
function MiniFrame:fit()
	local panel = self.panel
	if not panel.Parent then
		return
	end
	local screen = UIKit.size()
	local gui = HUD.gui()
	local z = UIKit.zoom()
	local lo, hi = 8, screen.X - 8
	for _, name in { "TutorialTask", "JobCard" } do
		local o = gui:FindFirstChild(name, true) :: GuiObject? -- (the phone check moves them into its frame)
		if o and o.Visible then
			local x0 = (o.AbsolutePosition.X - (panel.Parent :: GuiObject).AbsolutePosition.X) / z
			local x1 = x0 + o.AbsoluteSize.X / z
			if x1 < screen.X / 2 then
				lo = math.max(lo, x1 + 8)
			elseif x0 > screen.X / 2 then
				hi = math.min(hi, x0 - 8)
			end
		end
	end
	-- (about 236 px on an 844 phone: the mock's plate; the gauge inside is bigger instead — wr-uidesign A②)
	local centred = math.clamp(math.floor(screen.X * 0.28), 220, 260)
	local w, x = centred, screen.X / 2
	if hi - lo < centred then
		w = math.max(190, hi - lo)
		x = if hi - lo >= 190 then (lo + hi) / 2 else screen.X / 2
	elseif x - centred / 2 < lo or x + centred / 2 > hi then
		x = math.clamp(x, lo + centred / 2, hi - centred / 2)
	end
	-- (a clear gap of at least 12 px above the tool bar's selected slot, plate bolts included, so a thumb that slips doesn't pick a tool)
	local room = screen.Y - UIKit.hotbarHeight() - UIKit.hotbarGap() - 18
	local h = math.min(math.floor(w * self.o.ratio), room - (self.o.reserve or 72))
	-- the work target must stay beside the plate: when it sits under the plate's box, the plate moves to its far side
	local aim = if self.open_ then aimPoint() else nil
	if aim and aim.Y > room - h - 30 and aim.X > x - w / 2 - 54 and aim.X < x + w / 2 + 54 then
		local right = aim.X + 54 + w / 2 -- (the plate's centre if it goes right of the target)
		local left = aim.X - 54 - w / 2
		local canRight = right + w / 2 <= hi
		local canLeft = left - w / 2 >= lo
		if canRight and (not canLeft or aim.X < screen.X / 2) then
			x = right
		elseif canLeft then
			x = left
		end
	end
	panel.Size = UDim2.fromOffset(w, h)
	panel.Position = UDim2.new(0, math.floor(x), 0, room)
	local pillW = math.min(250, math.max(w, 220))
	local pillY = math.max(UIKit.barHeight() + 34, room - h - 28) -- (the pill clears the money bar above it; on a tall plate it overlaps the plate's top, whose title is gone by then)
	self.pill.Size = UDim2.fromOffset(pillW, 54)
	self.pill.Position = UDim2.fromOffset(math.floor(x), pillY)
	self.keep.Size = UDim2.fromOffset(pillW, 30)
	self.keep.Position = UDim2.fromOffset(math.floor(x), pillY + 30)
	self.cue.Position = UDim2.fromOffset(math.floor(x), room - math.floor(h * 0.52))
	self.exit.Position = UDim2.fromOffset(math.floor(x + w / 2) - 30, room - h + 30) -- (the one close button: inside the plate, 8 px in from the corner, 44 to press)
	self.exit.Visible = panel.Visible and self.open_ and not self.finished
	if self.o.extraFit then
		self.o.extraFit(self, w, h, x, room)
	end
end

function MiniFrame:setTitle(key: string, args: { [string]: any }?)
	self.title.Visible = true
	UIKit.setText(self.title, key, args)
end

-- (the card / Buy parts / Invite / thumbstick step aside while a plate is up — one thing at a time)
function MiniFrame:flag(on: boolean)
	HUD.minigame(self.o.name, on)
end

-- show the plate. cueKey: the one-word start cue (nil = none, e.g. Auto)
function MiniFrame:open(cueKey: string?, titleKey: string?)
	self.token += 1
	local my = self.token
	self.open_ = true
	self.finished = false
	self.pill.Visible = false
	self.keep.Visible = false
	self:setTitle(titleKey or self.titleKey)
	self.panel.Visible = true
	self:flag(true)
	self:fit()
	if cueKey then
		UIKit.setText(self.cue, cueKey)
		self.cue.Visible = true
		UIKit.pop(self.cue, 0.5)
		task.delay(0.6, function()
			if my == self.token then
				self.cue.Visible = false
			end
		end)
	else
		self.cue.Visible = false
	end
end

-- a short notice on the title line (the reason of a miss: "Almost!", "Not enough", "Too full!"), then the title again
function MiniFrame:notice(key: string, seconds: number, after: string?)
	local my = self.token
	self:setTitle(key)
	task.delay(seconds, function()
		if my == self.token and self.open_ and not self.finished then
			self:setTitle(after or self.titleKey)
		end
	end)
end

-- the end: the pill (Perfect + the tip / Good / Done for you), the keep chip when the server asked, closed after a while.
-- onClosed runs when the plate hides by itself.
function MiniFrame:finish(grade: string, tip: number?, auto: boolean?, keepable: boolean?, keys: { perfect: string, good: string }, onClosed: (() -> ())?)
	if not self.open_ then
		return
	end
	self.finished = true
	self.token += 1
	local my = self.token
	self.title.Visible = false
	self.cue.Visible = false
	local key = if auto then "mg.result.auto" elseif grade == "Perfect" then keys.perfect else keys.good
	if grade == "Perfect" and not auto and (tip or 0) <= 0 then
		key ..= "0" -- (a tip of $0 is not shown: "Perfect!" alone)
	end
	UIKit.setText(self.pillLabel, key, { money = "$" .. tostring(tip or 0) })
	self.pill.Visible = true
	UIKit.pop(self.pill, 0.6)
	self.keep.Visible = keepable == true
	if keepable then
		self:flag(false) -- (the chip waits up to 10 s: the thumbstick and the card come back meanwhile)
	end
	self:fit()
	if grade == "Perfect" and not auto then
		task.defer(UIKit.sparkles, self.pill, 7) -- ('Perfect!' twinkle: the 2D part; the world's sparkle is wr-vfx's)
	end
	task.delay(if keepable then 10 else 1.8, function()
		if my == self.token then
			self:hide()
			if onClosed then
				onClosed()
			end
		end
	end)
end

function MiniFrame:hide()
	self.token += 1
	self.open_ = false
	self.finished = false
	self.pill.Visible = false
	self.keep.Visible = false
	self.cue.Visible = false
	self.exit.Visible = false
	self.panel.Visible = false
	self:flag(false)
end

return MiniFrame
