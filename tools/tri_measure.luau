-- How many triangles the screen really draws right now (main bay_v2 decision, code #4: "measure in Studio, each work
-- view on its own"). Run in PLAY, datamodel Client, while the view to measure is up (enter it first: DevCall ask
-- prompt Work_EngineBay / Work_Wheel_FL ...). The HUD is hidden while it samples (3 s), then comes back.
-- Stats.SceneTriangleCount = the whole scene (map + cars): compare the same view before / after a change.
--   10-22 baseline, old bay (dev window, Sedan in Bay 1, Lv5): engine view 75.5k · wheel view (FL on stands) 86.7k
--   10-23 (Lv1, 2 cars): engine view, switches off 83.2k / 81 calls · bay + top 98.1k / 124 · + lower, gearbox,
--   underside 97.3k / 134 (notes/gpt/wr-dev/lumps_1023/items_1023.md §5: the phone budget and the steps)

local Players = game:GetService("Players")
local Stats = game:GetService("Stats")

local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
local was = {}
for _, g in gui:GetChildren() do
	if g:IsA("ScreenGui") then
		was[g] = g.Enabled
		g.Enabled = false
	end
end
local hi, sum, n, calls = 0, 0, 0, 0
for _ = 1, 15 do
	task.wait(0.2)
	local v = Stats.SceneTriangleCount
	hi = math.max(hi, v)
	sum += v
	n += 1
	calls = math.max(calls, Stats.SceneDrawcallCount)
end
for g, on in was do
	g.Enabled = on
end
return string.format("zone %s: max %d · avg %d triangles · %d draw calls (max)", tostring(Players.LocalPlayer:GetAttribute("WorkZone")), hi, math.floor(sum / n), calls)
