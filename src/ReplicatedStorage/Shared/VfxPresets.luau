-- Every effect in one table (notes/handoff/vfx_brief_1022.md; the idea of EmitCount / EmitDelay properties in the VFX
-- video): change a number here and every place that plays the effect changes. Textures = Kenney Particle Pack
-- (CC0, white on clear, tinted with Color). Smoke / steam never glow (LightEmission 0); light is for zaps and sparks only.
-- Shared/VFX.luau plays them: VFX.burst(name, where, scale) and VFX.loop(name, attachment, scale).
--
-- A preset is a plain table:
--   texture   key of Presets.Tex
--   color     Color3, or { from, to }
--   size      { start, end } (studs at scale 1)      transparency { start, end } or { start, mid, end }
--   lifetime  { min, max } seconds                    speed { min, max } studs/s      spread degrees
--   accel     Vector3 studs/s^2                       drag, rot { min, max } start angle, rotSpeed { min, max }
--   orient    "VelocityParallel" for streaks (default faces the camera)       squash  -1..1 (streak shape)
--   light     LightEmission (default 0)      lit  LightInfluence (default 0.25; steam 0)      bright  Brightness (steam 3: the texture is grey)               zOffset
--   count     burst: particles per VFX.burst           (loop presets use `rate` or `pulse`)
--   rate      loop: particles per second, steady       hoodOpen  rate factor while the car's hood is open
--   pulse     loop: { every = { min, max } seconds, count = { min, max } } puffs on a beat
--   sway      loop: the source drifts sideways { amp studs, speed rad/s }
--   parts     a bundle: { { name, scale?, count?, delay? } ... } — VFX.burst plays each part (Sparkle_Perfect)
--   drip      loop: a falling drop every `every` seconds, then a ring on the floor (see VFX.luau)

local Presets = {}

Presets.Tex = {
	steam_cloud = "rbxassetid://103788368681944",
	steam_wisp = "rbxassetid://111922041749975",
	smoke_cloud = "rbxassetid://133040601398033",
	smoke_puff = "rbxassetid://92482215163332",
	dust_flecks = "rbxassetid://137595598104902",
	zap = "rbxassetid://134873323429835",
	streak = "rbxassetid://91154651646281",
	soot = "rbxassetid://139316219214926", -- (a Decal, not a particle)
	ring = "rbxassetid://120639155900790",
	dot_soft = "rbxassetid://98589754735886",
	-- (sparkle set, Kenney CC0: star_06 / star_04 / star_09 / magic_05)
	sparkle_big = "rbxassetid://119368513139562",
	sparkle_small = "rbxassetid://139419920882104",
	sparkle_burst = "rbxassetid://107750032554959",
	glow_soft = "rbxassetid://95012168319037",
}

local PINK = Color3.fromHex("E7A9C4") -- the sedan's coolant (fault_looks §5b)
local PINK_DROP = Color3.fromHex("D9578A") -- (the falling drop a shade deeper: the pale one melted into the bumper / floor on a phone — API check 10-23)

Presets.Effects = {
	------------------------------------------------------------------ radiator (steam out of the hood gap, a drip)
	-- steam is thinner than smoke and gone fast (real photos: it hangs a moment, then vanishes)
	radiator_cloud = {
		texture = "steam_cloud",
		color = Color3.fromRGB(248, 248, 248),
		-- (a little bigger and longer than v2: on a phone in the bay it barely showed over the hood — main 10-23; still
		-- gone in about a second, like the photos)
		size = { 1.3, 4.2 },
		transparency = { 0.04, 0.32, 1 },
		lifetime = { 0.95, 1.35 },
		speed = { 0.9, 1.5 },
		lit = 0, -- steam is bright white: not darkened by the room light
		bright = 3, -- (the texture itself is grey: Brightness makes it white)
		spread = 14,
		accel = Vector3.new(0, 1.2, 0),
		drag = 1.2,
		rot = { 0, 360 },
		rotSpeed = { -20, 20 },
		rate = 15,
		hoodOpen = 0.3, -- with the hood open the steam thins out (it gets out; and the parts stay visible)
		sway = { 0.8, 1.7 }, -- (the gap is as wide as the hood: the source drifts across it)
	},
	radiator_wisp = {
		texture = "steam_wisp",
		color = Color3.fromRGB(250, 250, 250),
		size = { 1.0, 2.6 },
		transparency = { 0.2, 0.55, 1 },
		lifetime = { 0.7, 1.0 },
		speed = { 1.8, 2.6 },
		lit = 0,
		bright = 3,
		spread = 10,
		accel = Vector3.new(0, 1.8, 0),
		drag = 1.4,
		rot = { -12, 12 },
		rotSpeed = { -10, 10 },
		rate = 7,
		hoodOpen = 0.3,
		sway = { 0.9, 2.3 },
	},
	-- one drop every ~1.2 s from under the front bumper; the ring where it lands is VFX.luau's (coolant_ring)
	coolant_drip = {
		texture = "dot_soft", -- a round drop, stretched along its fall (squash > 0 = taller): reads as a falling drop
		color = PINK_DROP,
		size = { 0.8, 0.74 }, -- (big enough to read on a phone from the bay: 0.28 was a few pixels; GPT drip r1 0.55; main r2 "2x")
		squash = 0.55, -- (positive = taller: a falling drop, not a flat disc)
		transparency = { 0, 0, 0.1 },
		lifetime = { 0.3, 0.3 }, -- (VFX.luau sets it to the real fall time)
		speed = { 0, 0 }, -- (it just falls: `accel`)
		spread = 0,
		lit = 0,
		accel = Vector3.new(0, -80, 0),
		-- (hang: the drop first swells under the bumper for a moment, then lets go — a lone dot flashing by read as "a blue
		-- circle" on a phone: wr-play 10-23 → main no_defer #15)
		drip = { every = { 1.2, 1.7 }, fall = 80, hang = 0.45 },
	},
	coolant_tail = { -- the drop's pointed top: three smaller drops just behind it as it falls (VFX.luau drip) — a teardrop, not a ball
		texture = "dot_soft",
		color = PINK_DROP,
		size = { 0.46, 0.38 },
		squash = 0.5,
		transparency = { 0.1, 0.1, 0.3 },
		lifetime = { 0.16, 0.16 },
		speed = { 0, 0 },
		spread = 0,
		lit = 0,
		accel = Vector3.new(0, -80, 0),
		count = 1,
	},
	coolant_hang = { -- the drop swelling at the leak before it falls (VFX.luau drip)
		texture = "dot_soft",
		color = PINK_DROP,
		size = { 0.1, 0.5 },
		transparency = { 0.1, 0 },
		lifetime = { 0.45, 0.45 },
		speed = { 0, 0 },
		spread = 0,
		lit = 0,
		count = 1,
	},
	coolant_ring = { -- a ripple on the puddle (a flat Decal, not a particle)
		color = PINK,
		size = { 0.25, 1.1 },
		lifetime = { 0.7, 0.7 },
	},
	coolant_splash = {
		texture = "dot_soft",
		color = PINK,
		size = { 0.14, 0.04 },
		transparency = { 0.1, 1 },
		lifetime = { 0.25, 0.4 },
		speed = { 2, 4 },
		spread = 70,
		accel = Vector3.new(0, -30, 0),
		count = 5, -- (a little crown of splashes on the puddle: the drop landed)
	},

	------------------------------------------------------------------ muffler (a rust hole that leaks on a beat)
	-- grey exhaust, 2~4 short puffs a second; never black (black = too much fuel, a different fault)
	muffler_leak = {
		texture = "smoke_puff",
		color = Color3.fromRGB(176, 174, 170),
		lit = 0,
		bright = 1.8,
		size = { 0.5, 1.5 },
		transparency = { 0.3, 0.6, 1 },
		lifetime = { 0.35, 0.6 },
		speed = { 1.2, 2.6 },
		dir = "Back", -- out of the hole toward the rear (the floor is right under the can)
		spread = 35,
		accel = Vector3.new(0, 0.8, 0),
		drag = 2,
		rot = { 0, 360 },
		rotSpeed = { -60, 60 },
		pulse = { every = { 0.26, 0.42 }, count = { 1, 2 } },
	},

	------------------------------------------------------------------ battery terminal (a small, short zap)
	terminal_zap = {
		texture = "dot_soft", -- the hot point the sparks leave from (GPT's target mock: one small, strong white-yellow point)
		color = Color3.fromRGB(255, 244, 200),
		size = { 1.0, 0.4 },
		transparency = { 0, 0.4, 1 },
		lifetime = { 0.1, 0.16 },
		speed = { 0, 0 },
		spread = 0,
		rot = { 0, 0 },
		light = 1,
		count = 1,
	},
	terminal_spark = {
		texture = "streak",
		color = { Color3.fromRGB(255, 240, 170), Color3.fromRGB(255, 95, 10) }, -- (hot cream at the start, saturated orange after)
		size = { 0.65, 0.22 }, -- (short: long + fat read as a flame — GPT r3~r5, API r4; thin 0.45~0.6 squash = hair lines gone on a phone; Play photos 10-22)
		squash = 0.85,
		orient = "VelocityParallel",
		transparency = { 0, 0.5, 1 },
		lifetime = { 0.12, 0.26 },
		speed = { 8, 14 },
		spread = 180,
		accel = Vector3.new(0, -26, 0),
		light = 0.7,
		count = 14,
	},

	------------------------------------------------------------------ one-shots
	engine_start = { -- the first "puh" out of the tail pipe
		texture = "smoke_cloud",
		color = Color3.fromRGB(205, 205, 205),
		size = { 0.6, 2.6 },
		transparency = { 0.35, 0.7, 1 },
		lifetime = { 0.8, 1.4 },
		speed = { 3, 6 },
		spread = 16,
		drag = 1,
		rot = { 0, 360 },
		rotSpeed = { -30, 30 },
		count = 6,
		countBig = 10,
	},
	scrap_puff = { -- an old part went to the scrap pile
		texture = "smoke_puff",
		color = Color3.fromRGB(185, 180, 170),
		size = { 0.8, 2.0 },
		transparency = { 0.45, 0.75, 1 },
		lifetime = { 0.5, 0.9 },
		speed = { 1, 3 },
		spread = 80,
		drag = 1.5,
		rot = { 0, 360 },
		rotSpeed = { -40, 40 },
		count = 5,
	},
	scrap_dust = {
		texture = "dust_flecks",
		color = Color3.fromRGB(150, 128, 105),
		size = { 0.5, 0.9 },
		transparency = { 0.2, 0.6, 1 },
		lifetime = { 0.5, 0.9 },
		speed = { 2, 5 },
		spread = 100,
		accel = Vector3.new(0, -6, 0),
		drag = 1,
		rot = { 0, 360 },
		count = 3,
	},
	bolt_ring = { -- a small ring when a bolt turns (instead of the old neon ball); color comes from the caller
		texture = "ring",
		color = Color3.fromRGB(255, 200, 80),
		size = { 0.25, 1.0 },
		transparency = { 0.15, 1 },
		lifetime = { 0.22, 0.22 },
		speed = { 0, 0 },
		spread = 0,
		count = 1,
	},
	------------------------------------------------------------------ sparkle ("뾰로롱": a mini-game Perfect, later a repair done, first pay ...)
	-- a few big stars pop (grow, then vanish), small stars scatter upward, one soft glow, a quick ring. Sparkles may glow;
	-- the smoke / steam never do.
	sparkle_pop = {
		texture = "sparkle_big",
		color = { Color3.fromRGB(255, 226, 70), Color3.fromRGB(255, 184, 20) }, -- (saturated gold, almost no glow: a pale added star vanishes on a bright wall)
		size = { 0.4, 5.2, 4.6, 0 }, -- pops open fast, hangs, then shrinks away (0.9 s: it must be seen)
		transparency = { 0, 0, 0.15, 1 },
		-- (everything fixed, nothing random: sparkle_edge is drawn under it and has to line up exactly)
		lifetime = { 0.9, 0.9 },
		speed = { 0, 0 },
		spread = 0,
		accel = Vector3.new(0, 0.8, 0),
		rot = { 0, 0 },
		light = 0.08,
		count = 1,
	},
	sparkle_edge = { -- the same star, a little bigger and dark orange, behind it: a hard outline (a soft added star blurs into a bright wall)
		texture = "sparkle_big",
		color = Color3.fromRGB(226, 128, 6),
		size = { 0.5, 6.0, 5.3, 0 },
		transparency = { 0, 0, 0.15, 1 },
		lifetime = { 0.9, 0.9 },
		speed = { 0, 0 },
		spread = 0,
		accel = Vector3.new(0, 0.8, 0),
		rot = { 0, 0 },
		light = 0,
		zOffset = -0.04,
		count = 1,
	},
	-- (5.2 studs seen from 8 studs away = ~46% of the screen height before the spot's own scale; the lists below set where)
	sparkle_dust = {
		texture = "sparkle_small",
		color = { Color3.fromRGB(255, 236, 110), Color3.fromRGB(255, 190, 40) },
		size = { 0.3, 1.8, 1.4, 0 },
		transparency = { 0, 0, 0.35, 1 },
		lifetime = { 0.7, 1.1 },
		speed = { 2.0, 4.6 },
		spread = 80,
		accel = Vector3.new(0, 1.6, 0),
		drag = 2.2,
		rot = { 0, 360 },
		rotSpeed = { -120, 120 },
		light = 0.08,
		count = 10,
	},
	sparkle_glow = {
		texture = "glow_soft",
		color = Color3.fromRGB(255, 236, 170),
		size = { 1.2, 6.5 },
		transparency = { 0.35, 1 },
		lifetime = { 0.8, 0.8 },
		speed = { 0, 0 },
		spread = 0,
		light = 1,
		count = 1,
	},
	sparkle_ring = {
		texture = "sparkle_burst",
		color = Color3.fromRGB(255, 246, 210),
		size = { 0.3, 2.2 },
		transparency = { 0.2, 1 },
		lifetime = { 0.32, 0.32 },
		speed = { 0, 0 },
		spread = 0,
		rot = { 0, 360 },
		light = 1,
		count = 1,
	},
	-- where the work was, in the world (a repair done, a first pay ...: one line VFX.burst("Sparkle_Perfect", pos))
	Sparkle_Perfect = {
		parts = {
			{ name = "sparkle_glow", scale = 0.3 },
			{ name = "sparkle_ring", scale = 0.8 },
			{ name = "sparkle_edge", scale = 0.5 },
			{ name = "sparkle_pop", scale = 0.5 },
			{ name = "sparkle_edge", scale = 0.3, delay = 0.1 }, -- (different sizes, not all at once: GPT r2)
			{ name = "sparkle_pop", scale = 0.3, delay = 0.1 },
			{ name = "sparkle_dust", scale = 0.7, count = 4 },
			{ name = "sparkle_dust", count = 3, scale = 0.45, delay = 0.12 },
		},
	},
	Sparkle_Small = { -- a plain success: smaller, fewer
		parts = {
			{ name = "sparkle_edge", scale = 0.3 },
			{ name = "sparkle_pop", scale = 0.3 },
			{ name = "sparkle_dust", scale = 0.4, count = 3 },
		},
	},

	clue_ring = {
		texture = "ring",
		color = Color3.fromRGB(120, 200, 255),
		size = { 0.5, 3.0 },
		transparency = { 0.2, 1 },
		lifetime = { 0.45, 0.45 },
		speed = { 0, 0 },
		spread = 0,
		count = 1,
	},
}

-- The mini-game result sparkle on the SCREEN (VFX.burstScreen): the result pill is a GUI drawn over the 3D scene, so the
-- stars go above and beside it — x, y = fraction of the viewport, scale on top of the preset's size, delay seconds.
-- Perfect = 5 big stars (different sizes, staggered) + dust going up; Good = 3 smaller stars. Each star is two
-- layers on the same spot: the dark orange outline under, the gold star over it (stars(...) below writes both).
local function stars(list: { any }, dust: { any }): { any }
	local out = {}
	for _, s in list do -- (every field of the spot carries over: x/y or the pill-relative rx/ry/dx/dy)
		for _, name in { "sparkle_edge", "sparkle_pop" } do
			local o = table.clone(s)
			o.name = name
			table.insert(out, o)
		end
	end
	for _, d in dust do
		table.insert(out, d)
	end
	return out
end

Presets.SparkleScreen = {
	Perfect = stars({
		{ x = 0.5, y = 0.24, scale = 1.0 }, -- (above the part that was just fixed: the work is in the middle of the screen)
		{ x = 0.24, y = 0.52, scale = 0.72, delay = 0.06 },
		{ x = 0.76, y = 0.50, scale = 0.8, delay = 0.1 },
		{ x = 0.34, y = 0.2, scale = 0.47, delay = 0.16 },
		{ x = 0.67, y = 0.2, scale = 0.54, delay = 0.2 },
	}, {
		{ name = "sparkle_dust", x = 0.3, y = 0.5, scale = 1.0, delay = 0.04, count = 3 },
		{ name = "sparkle_dust", x = 0.7, y = 0.5, scale = 1.0, delay = 0.08, count = 3 },
		{ name = "sparkle_dust", x = 0.5, y = 0.42, scale = 1.2, delay = 0.12, count = 4 },
	}),
	Good = stars({
		{ x = 0.5, y = 0.32, scale = 0.58 },
		{ x = 0.3, y = 0.5, scale = 0.4, delay = 0.08 },
		{ x = 0.7, y = 0.5, scale = 0.4, delay = 0.12 },
	}, {
		{ name = "sparkle_dust", x = 0.5, y = 0.42, scale = 0.8, delay = 0.05, count = 3 },
	}),
}

-- The same, laid out around the result pill where it really is (VFX.burstAroundRect): the pill sits at a different
-- height in each mini-game, and a star behind the pill is hidden (the GUI is drawn over the 3D). Position = the pill's
-- centre + rx / ry times its half width / height + dx / dy times the screen height.
Presets.SparkleAround = {
	Perfect = stars({
		{ rx = 0, ry = -1, dx = 0, dy = -0.2, scale = 0.8 }, -- (GPT r1: the top star pulled the eye from the pill text: -20%)
		{ rx = -1, ry = 0, dx = -0.22, dy = 0, scale = 0.72, delay = 0.06 }, -- (+20 px left)
		{ rx = 1, ry = 0, dx = 0.17, dy = 0.05, scale = 0.8, delay = 0.1 }, -- (+20 px down, clear of the work card)
		{ rx = -0.6, ry = -1, dx = 0, dy = -0.34, scale = 0.47, delay = 0.16 },
		{ rx = 0.6, ry = -1, dx = 0.02, dy = -0.36, scale = 0.54, delay = 0.2 },
	}, {
		{ name = "sparkle_dust", rx = -1, ry = 0, dx = -0.1, dy = -0.04, scale = 1.0, delay = 0.04, count = 3 },
		{ name = "sparkle_dust", rx = 1, ry = 0, dx = 0.1, dy = -0.04, scale = 1.0, delay = 0.08, count = 3 },
		{ name = "sparkle_dust", rx = 0, ry = -1, dx = 0, dy = -0.1, scale = 1.2, delay = 0.12, count = 4 },
	}),
	Good = stars({
		{ rx = 0, ry = -1, dx = 0, dy = -0.15, scale = 0.58 },
		{ rx = -1, ry = 0, dx = -0.13, dy = 0, scale = 0.4, delay = 0.08 },
		{ rx = 1, ry = 0, dx = 0.13, dy = 0, scale = 0.4, delay = 0.12 },
	}, {
		{ name = "sparkle_dust", rx = 0, ry = -1, dx = 0, dy = -0.08, scale = 0.8, delay = 0.05, count = 3 },
	}),
}

-- A sagging muffler swings a little on its hanger (the client turns its look on a Weld): +-deg degrees, slowly
Presets.Sway = {
	muffler = { deg = 1.3, speed = 1.1, pivot = Vector3.new(-1.3, 0, 0), within = 45 }, -- (pivot in the muffler's own space; only near the camera)
}

-- Phone / low graphics (VFX.luau reads the quality once): how many particles, and how many loops run on screen at
-- once (the nearest cars first, the far ones are switched off)
Presets.Quality = {
	low = { mult = 0.5, maxLoops = 3 },
	mid = { mult = 0.75, maxLoops = 5 },
	high = { mult = 1.0, maxLoops = 8 },
}
Presets.CullDistance = 110 -- studs from the camera: a loop farther than this is off

return Presets
