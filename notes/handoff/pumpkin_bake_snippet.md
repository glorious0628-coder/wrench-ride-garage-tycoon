# PumpkinCoach 굽기 줄 — **10-23 13:03: 이 줄들은 이미 `tools/bake_carmeshes.luau`에 들어감(v3.1 id 11개, 내 창에서 굽고 Play 확인). 아래는 설명용**

`tools/bake_carmeshes.luau`에 아래를 더하면 `CarParts.baked("PumpkinCoach")`(= CarMeshes `PumpkinCoach_Decor_Shell`)가 켜지고
**HalloweenService가 알아서 호박차를 씀**(그 전엔 주황 세단). 게임 쪽(`CarParts.Types.PumpkinCoach`, `PartData/Cars/PumpkinCoach`)은 이미 들어감 — id만 기다림.
id는 메인이 GLB 11개(v3.1 기준)와 맵을 올린 뒤 줌. 값 출처 `art/3d/pumpkin_car/v3(_1)/pumpkin_spec.md` §0·`work/b1/spec_values.json`.

## 1. IDS (메인이 줌)
```lua
-- pumpkin coach v3.1 (art/3d/pumpkin_car/v3_1; main's upload): the 11 GLBs
pumpkin_shell = nil :: number?, pumpkin_trim = nil :: number?, pumpkin_glow = nil :: number?, pumpkin_glass = nil :: number?,
pumpkin_hood = nil :: number?, pumpkin_bumper_f = nil :: number?, pumpkin_bumper_r = nil :: number?, pumpkin_chassis = nil :: number?,
pumpkin_underbody = nil :: number?, pumpkin_hoodprop = nil :: number?, pumpkin_rim = nil :: number?,
```
(엔진룸·하체 장식은 **새 업로드 없이 SUV 것 재사용**: `suv_deco_*`.)

## 2. 칠하는 맵(PAINT_SA)과 기본 색
- `PAINT_DEFAULT`에 `pumpkin = Color3.fromHex("E8862A")` (`meshes()`가 `name:match("^%a+")`로 고름 → `pumpkin_*`).
- **껍질·보닛·범퍼 2개**만 칠하는 부품(SurfaceAppearance `ColorMap = *_color_overlay.png`, AlphaMode Overlay, MeshPart.Color = #E8862A, 골 어두운 주황은 맵에): `PAINT_SA.pumpkin_shell / pumpkin_hood / pumpkin_bumper_f / pumpkin_bumper_r = { 색맵 id, 거칠기 id }` — 기존 sedan_* 줄과 같은 모양.
- **금속·고무 같은 칠 안 하는 부품**(trim·chassis·glass·glow·underbody·hoodprop·rim)은 GLB 안 질감 그대로. 단 호박차 맵 세트엔 **금속도 `*_metalness.png`**와 **글로우 `pumpkin_glow_emissive.png`·범퍼 `pumpkin_bumper_*_emissive.png`**(앞 깜박이·후진등)가 있어서 기존 `PAINT_SA`(색·거칠기 2개)로는 모자람 → `meshes()`의 `SurfaceAppearance` 만드는 곳에 `MetalnessMap`·`EmissiveMaskContent`(맵 있으면)를 더하는 한 줄씩이 필요해요. 맵 목록·설명 = `art/3d/pumpkin_car/v3/pumpkin_paint.json` (어느 맵이 어느 부품인지). 메인이 올릴 때 어떤 맵을 어떤 id로 줄지 함께 정해 주세요(판단은 메인).

## 3. 굽기 줄 (`try`로 — 실패해도 나머지는 계속; id가 nil이면 `if IDS.pumpkin_shell then ... end`로 감싸 건너뜀)
```lua
-- Ella's pumpkin coach (PumpkinCoach_): v3 coords = car coords (origin = the ground between the axles); 11 GLBs + the SUV's engine-bay decor
if IDS.pumpkin_shell then
	try("PumpkinCoach_Decor_Shell", function() template("PumpkinCoach_Decor_Shell", O, { { "pumpkin_shell" }, { "pumpkin_trim" }, { "pumpkin_glow" } }) end)
	try("PumpkinCoach_Decor_Glass", function() template("PumpkinCoach_Decor_Glass", O, { { "pumpkin_glass" } }) end)
	try("PumpkinCoach_Decor_Chassis", function() template("PumpkinCoach_Decor_Chassis", O, { { "pumpkin_chassis" } }) end)
	try("PumpkinCoach_Decor_Underbody", function() template("PumpkinCoach_Decor_Underbody", O, { { "pumpkin_underbody" } }) end)
	try("PumpkinCoach_Decor_HoodProp", function() template("PumpkinCoach_Decor_HoodProp", O, { { "pumpkin_hoodprop" } }) end)
	-- the front group moved +2.30 back, the rear axle -2.30 forward (v3: wheelbase 6.6 -> 5.1; spec §0), both (0, -0.115, dz) from the SUV's places
	local FRONT, REAR = CFrame.new(0, -0.115, 2.30), CFrame.new(0, -0.115, -2.30)
	for _, n in { "EngineBay", "EngineTop", "EngineLower", "Transaxle", "FrontSubframe" } do
		try("PumpkinCoach_Decor_" .. n, function() template("PumpkinCoach_Decor_" .. n, O, { { "suv_deco_" .. n:lower(), FRONT } }) end)
	end
	try("PumpkinCoach_Decor_RearAxle", function() template("PumpkinCoach_Decor_RearAxle", O, { { "suv_deco_rearaxle", REAR } }) end)
	-- pivots = the Slots' (PartData/Cars/PumpkinCoach move): Hood (0, 5.035, -2.68) · Bumper_F (0, 1.45, -5.10) · Bumper_R (0, 1.42, 5.20)
	try("PumpkinCoach_Hood", function() template("PumpkinCoach_Hood_Detail", Vector3.new(0, 5.035, -2.68), { { "pumpkin_hood" } }) end)
	try("PumpkinCoach_Bumper_F", function() template("PumpkinCoach_Bumper_F_Detail", Vector3.new(0, 1.45, -5.10), { { "pumpkin_bumper_f" } }) end)
	try("PumpkinCoach_Bumper_R", function() template("PumpkinCoach_Bumper_R_Detail", Vector3.new(0, 1.42, 5.20), { { "pumpkin_bumper_r" } }) end)
	-- the 5-spoke rim (852 tris x4) + the shared tyre (not scaled: the sedan's 1.03 x 2.75)
	try("PumpkinCoach_Wheel", function() template("PumpkinCoach_Wheel_Detail", O, { { "pumpkin_rim" }, { "Tire" } }) end)
	try("PumpkinCoach_Wheel_Lite", function() template("PumpkinCoach_Wheel_Lite", O, { { "pumpkin_rim" }, { "Tire_Lite" } }) end)
	try("PumpkinCoach_Wheel_Flat", function() template("PumpkinCoach_Wheel_Flat_Detail", O, { { "pumpkin_rim" }, { "Tire_Flat" } }) end)
end
```
- 지금 Crossover 줄과 같은 모양(`template(이름, 피벗, {{asset, 추가 CFrame, 크기}})`). `Bumper_R`은 코드가 180° 돌려 쓰는 축(`turned`) — SUV·세단과 같은 방식이라 따로 처리 없음(GLB 좌표는 `pumpkin_bumper_r_attachments.json`의 `turned_offsets_for_code`).
- 굽기 뒤 확인: `CarParts.baked("PumpkinCoach")` true · Play에서 `DevCall cartype PumpkinCoach`(손님 다음 차) → 차·보닛·잭·바퀴 일 · **`DevCall ella`**(할로윈 켜고 Ella 부르기)로 호박차 도착 장면.
- 삼각형 합계 58,959(+ 장식 재사용) — 한 대가 나올 때 그리기 예산 확인(`tools/tri_measure.luau`).
