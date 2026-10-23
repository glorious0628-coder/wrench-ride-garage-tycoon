-- The crossover SUV (docs/specs/suv_spec.md v0.3 + art/3d/suv_body/*_attachments.json, 3D 3rd pass): the sedan's
-- parts, moved to the SUV's places. The body stand-ins (shell, decor, its own hood / bumper blocks) stay in
-- CarParts.Types.Crossover.

local BAY = Vector3.new(0, 0.5, 0.15) -- suv_spec 4: the engine bay = the sedan's + this

return {
	name = "Crossover",
	base = "Sedan",
	wheels = {
		FL = Vector3.new(-3.25, 1.49, -4.85),
		FR = Vector3.new(3.25, 1.49, -4.85),
		RL = Vector3.new(-3.25, 1.49, 4.85),
		RR = Vector3.new(3.25, 1.49, 4.85),
	},
	move = {
		Hood = Vector3.new(0, 4.61, -4.1),
		Bumper_F = Vector3.new(0, 1.9, -7.8),
		Bumper_R = Vector3.new(0, 2.0, 8.1),
		Battery = { by = BAY },
		Radiator = { by = BAY },
		Muffler = { by = Vector3.new(0, 0.2, 0) }, -- under the car: +0.2 ground clearance
	},
}
