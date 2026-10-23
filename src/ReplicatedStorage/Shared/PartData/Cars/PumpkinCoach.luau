-- Ella's pumpkin coach (Halloween, docs/design/halloween_pumpkin.md; 3D art/3d/pumpkin_car/v3/pumpkin_spec.md §0): the
-- sedan's parts moved to the coach's places. The body stand-ins (shell, decor, its own hood / bumper blocks) stay in
-- CarParts.Types.PumpkinCoach. Not in the garage's usual customer mix (Config.CarTypeShare): HalloweenService brings it, and
-- only once its 3D is baked (CarParts.baked) — until then Ella comes in an orange sedan.

return {
	name = "PumpkinCoach",
	base = "Sedan",
	-- wheelbase 5.1 (v3: the front group +0.75 back, the rear group -0.75 forward — the bay, bolts and hood fit as in v2)
	wheels = {
		FL = Vector3.new(-3.25, 1.375, -2.55),
		FR = Vector3.new(3.25, 1.375, -2.55),
		RL = Vector3.new(-3.25, 1.375, 2.55),
		RR = Vector3.new(3.25, 1.375, 2.55),
	},
	move = {
		Hood = Vector3.new(0, 5.035, -2.68),
		Bumper_F = Vector3.new(0, 1.45, -5.10),
		Bumper_R = Vector3.new(0, 1.42, 5.20),
		Battery = Vector3.new(-2.2, 2.735, -3.25),
		Radiator = Vector3.new(0, 2.685, -5.05),
		Muffler = Vector3.new(0.3, 0.85, 4.25),
	},
}
