--!strict
-- World/Build: builds the whole map into workspace.Garage (wr-builder).
--   Build.build()                 -> builds only if workspace.Garage is missing or its WorldVersion is old
--   Build.build({ force = true }) -> always rebuilds
-- Used by World/WorldBoot.server.luau (server start) and tools/bake_world.luau (edit mode bake).
-- Names / positions other code may rely on: docs/specs/world_contract.md. Bump VERSION when the map changes.

local Kit = require(script.Parent.Kit)
local Site = require(script.Parent.Site)
local Shop = require(script.Parent.Shop)
local Expansion = require(script.Parent.Expansion)
local Town = require(script.Parent.Town)
local ShopDetail = require(script.Parent.ShopDetail)
local Lights = require(script.Parent.Lights)
local Equipment = require(script.Parent.Equipment)
local Props = require(script.Parent.Props)
local Street = require(script.Parent.Street)
local Junkyard = require(script.Parent.Junkyard)
local Growth = require(script.Parent.Growth)
local FlipPlaces = require(script.Parent.FlipPlaces)
local LivedIn = require(script.Parent.LivedIn)
local Motors = require(script.Parent.Motors)
local Facade = require(script.Parent.Facade)
local Gearport = require(script.Parent.Gearport)
local GearportDistricts = require(script.Parent.GearportDistricts)
local GearportWorks = require(script.Parent.GearportWorks)
local GearportProps = require(script.Parent.GearportProps)
local GearportSkyLoop = require(script.Parent.GearportSkyLoop)
local Upgrades = require(script.Parent.Upgrades)
local Halloween = require(script.Parent.Halloween)
local Curbside = require(script.Parent.Curbside)
local Interior = require(script.Parent.Interior)

local Build = {}

Build.VERSION = 35 -- 35: before-launch leftovers (main 10-23 "nothing waits for after launch"): hose reel wall bracket, charger clear of the drums, the bench's warm wash, more varied floor wear (drips, cracks, patch, scuffs), cart / bench rags drawn plain (no Fabric photo texture), an invisible header over the parts counter (no standing on it), the waiting room's coffee station beside the seats (was by the bay door, poured through the wall) + its frames filled (tyre poster, certificate, customer photos). 34: Bay 1 touch-ups (main review of v33): creeper leans 9° (was 15°, looked like falling), tyre marks back to v32 strength and turned to run the way cars drive in (as image labels they crossed the bay), the big near stains smaller, ceiling deck darker with low-contrast ribs. 33: Bay 1 floor + west wall closer to the mock (main 10-23): old stains + tyre marks as faded image labels on the floor carrier (13 decal parts gone, more and paler marks), sheen as soft pools under the tubes (no ruled core), battery charger to z -4.7 + jack stand 1 along the wall past the drums so the creeper and the dark wall band read, floor tape L moved past the creeper, jack stand 2 at the creeper's foot, finer wear tiles on the slab, ceiling deck galvanised grey. 32: the main's 3D wall kit (extinguisher, hose reel, shop trash can by the back door) + 3D drums (red / blue), battery charger (Lv1-6, by the creeper), bench vise + 3D creeper (Equipment.creeper: every bay's JackKit) leaning at 15° in Bay 1, Lv7 tyre changer 0.3 toward the door to make room. 31: Bay 1 matched to the mock (main, before launch): wainscot drawn as block, Concrete floor warm grey + drawn sheen / joints / patches on one carrier, ceiling ribs, creeper leaning on the west wall, drain pan by the tyre rack, shadow board + calendar / drawer cabinet re-laid, conduit + switch box; sidewalk joints drawn (-100 parts). 30: Bay 1 interior fixes (main review): oil stain decals tinted dark grey-black, hose reel to real size (19" reel) up high, joints every ~9 studs + darker, cast-iron drain grate, soft floor sheen under the tubes (Interior.FloorSheen), extinguisher moved onto the east pier in view; Alignment bay unlock Lv16 -> Lv12 (shop_areas §7); 29: Bay 1 interior re-dress (World/Interior: block walls + dark band, concrete floor + joints + grate, no round stains / empty frames, steel deck + joists, extinguisher, hose reel, tool board, calendar, drawer cabinet, trash can, drain pan); 28: closed-road sign on the junkyard barrier ("SALVAGE YARD / Opens at Level 8", goes with the barrier at Lv8) + the junkyard UnlockLevel set to 8 at its source (Site / Junkyard; Growth already said 8); 27: shadows on for every visible solid part (was: all parts under 3 studs off), see Build's shadow pass; 26: daylight a notch down (indoor ambient 128 -> 92, sun 1.95, exposure -0.1, ceiling light panels 0.55 -> 0.4: the shop looked washed out white); 25: brighter, clearer daylight (World/Lights: sun 1.6 -> 2.1, ambient up, haze 0.5 -> 0.12, saturation up) + a soft engine-room fill light per bay (Bays.BayN.EngineFill, 0.6); 24: camera-friendly Bay 1 walls (test 2 TOP10: the camera backed onto the pegboard behind the spray cans): spray cans off the pegboard shelf onto the bench, tire rack down to floor level (top shelf, gas can, oil bottles and the two stacks under it gone), PARTS sign / art boards / exit sign solid so the camera stops in front; every part-built tyre is now the 3D tyre (GearportProps.swapTires); 23: service apron in front of Bay 1 (World/Curbside): wide curb cut off the avenue, two WAIT HERE queue stalls (Queue.QueueSpot1/2 + WaveSpot / QueueEntry / QueueApron) and the QUICK SERVICE curb stall (Curb.CurbSpot + HoodSpot / WiperSpotL/R / CustomerSpot / CurbEntry / CurbApron / CurbExit, SupplyRack, A-frame Sign, Jug); cars on the road: Traffic.EntryTurn / ExitTurn turn points + flared entry / exit cuts (no leg crosses the sidewalk); Parking1..4 + their wheel stops gone; bench, bin, lamp, hydrant moved off the cuts; ShowCamera moved; 22: Halloween (World/Halloween): scene camera markers (Bays.BayN.CinemaCam_Street / _Door, Cinema.*), waiting-room TrophyShelf + SlipperSpot, HalloweenDecor kept in ServerStorage.WorldSeasonal (World/Seasonal shows it in its weeks); round blotchy oil stains; 21: bay parts carts (Bays.BayN.BayCart, top tray = PartsCart); 20: the shop front grows in three eras (World/Facade: shed / brick + gable / white enamel + canopy + neon), Lv3 sign repaint, boarded Bay 2 spot, Lv10 flags, Lv12 pot, Lv17 star border, waiting-room photo wall; 19: 3D street props by the street-props note (hydrants + curb paint, collection boxes, fire-escape stairs + drop ladders, pay kiosks, MUTCD work zone, guard posts, tyres, bins, cobra-head / globe lamps) + SkyLoop stations (platforms both sides, roof, elevator towers) + train cab noses; 18: Gearport stage 4 SkyLoop (guideway, columns, 2 stations, 2-car train) + stage 3 review (sawtooth across, rail sleepers, sign back); 17: Gearport street props (parts) + old-style river lamps; 16: Gearport stage 3 (Market Hall, Foundry Road, Old Works factories / sawtooth sheds / stacks, rail yard); 15: Gearport stage 2 (bungalow streets, river walk + river, skyline, Union Depot, map edge walls, map x -440..480); 14: Gearport stage 1 (Piston Avenue: median, westbound half, brick shop row, rival garages, fuel station, mural walls); 13: QA walk (bay|waiting door 6 wide, customer door 5.4, reception desk 2 south, coffee table west, stool no-collide); 12: Lv16 motors (Bay3/4 annexes, alignment bay, dyno room, paint-booth gear); 11: lift numbers to car_spec v0.7 (Wheel 1.8, tyre 2.75, pads 0.7); 10: lived-in touches (marks, blank art boards, clutter) + lift numbers in Equipment.LIFT; 9: perf pass (junkyard parts halved, small-part shadows off, Atomic streaming models); 8: loop B places (restore bay, paint booth, showroom) + junkyard detail; 7: growth pieces (Bay2, lift looks, upgrade equipment) + Upgrades show/hide; 6: street life (cross street, signals, shop strip) + junkyard blockout; 5: props pass (variants, shutter ribs, street furniture, stand-in cars); 4: softer lighting (no Play wash-out); 2: detail pass (style_B) + town + lights; 3: equipment (lift, jack, crane, scrap bin, sofa)

export type Options = { force: boolean? }

function Build.build(opts: Options?): Model
	local old = workspace:FindFirstChild("Garage")
	if old and not (opts and opts.force) and old:GetAttribute("WorldVersion") == Build.VERSION then
		return old :: Model
	end
	if old then
		old:Destroy()
	end
	for _, name in ipairs({ "WorldHidden", "WorldSeasonal" }) do
		local oldStore = game:GetService("ServerStorage"):FindFirstChild(name)
		if oldStore then
			oldStore:Destroy() -- pieces hidden / stored by the previous map
		end
	end
	-- the template's default Baseplate / SpawnLocation sit where the lot and back lane are: the map replaces them
	for _, name in ipairs({ "Baseplate", "SpawnLocation" }) do
		local d = workspace:FindFirstChild(name)
		if d and d:IsA("BasePart") then
			d:Destroy()
		end
	end

	-- build outside the DataModel, then parent once per section (keeps Studio responsive)
	local garage = Kit.model(nil, "Garage")
	garage:SetAttribute("WorldVersion", Build.VERSION)
	garage:SetAttribute("Front", "-Z")
	Kit.folder(garage, "Bays")
	Kit.folder(garage, "Workbenches")
	Kit.folder(garage, "Tools")

	Site.build(garage)
	Shop.build(garage)
	Expansion.build(garage)
	Town.build(garage)
	ShopDetail.build(garage)
	Equipment.build(garage)
	Props.build(garage)
	Curbside.build(garage) -- the next customers' queue + the quick-service curb stall in front of Bay 1
	Street.build(garage, Props.standInCar)
	Gearport.build(garage, Props.standInCar) -- the motor city around the shop (stage 1: Piston Avenue)
	GearportDistricts.build(garage) -- stage 2: Brickyard Heights, river walk, Midtown skyline, Union Depot, map edges
	GearportWorks.build(garage) -- stage 3: Market Hall, Foundry Road, the Old Works, rail yard
	GearportProps.build(garage) -- street props from parts (drums, meters, fire escapes, bollards, old lamps, tanks...)
	GearportSkyLoop.build(garage) -- stage 4: elevated guideway, two stations, the train (moved by SkyLoop.client.luau)
	Junkyard.build(garage)
	Growth.build(garage)
	FlipPlaces.build(garage)
	Motors.build(garage)
	Facade.build(garage) -- the shop front grows: shed (Lv1) -> brick (Lv6) -> white enamel (Lv16), photo wall
	LivedIn.build(garage)
	Interior.build(garage) -- Bay 1 re-dressed: block walls, concrete floor + joints, deck, wall gear (after LivedIn)
	Halloween.marks(garage) -- Ella's scene cameras + the trophy shelf (always there, invisible markers)
	GearportProps.swapTires(garage) -- every part-built tyre (Placeholder3D = "Tire") -> the 3D tyre
	Lights.build(garage) -- last

	-- shadow pass (10-22 user: "things need shadows if there's light"): every visible solid part casts one; off only for
	-- what shouldn't block light or isn't worth a shadow-map draw: see-through / glowing / glass, specks under 0.8,
	-- floor decals (thin + lying on the ground: lane lines, oil marks), map-sized pieces and anything far from the
	-- shop (past where a phone's shadow map reaches anyway). Before this (10-21) all parts under 3 studs were off
	-- (2,873 -> 945 casters); now ~half the parts cast. Everything anchored.
	for _, d in ipairs(garage:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true
			local s = d.Size
			local biggest = math.max(s.X, s.Y, s.Z)
			local decal = math.min(s.X, s.Y, s.Z) <= 0.35 and d.Position.Y < 1
			local far = Vector2.new(d.Position.X - 12, d.Position.Z).Magnitude > 260
			local glow = d.Transparency > 0.3 or d.Material == Enum.Material.Neon or d.Material == Enum.Material.Glass
			d.CastShadow = not (glow or biggest < 0.8 or decal or biggest > 150 or far)
		end
	end
	-- StreamingEnabled-ready: models that code reads as a whole arrive on a client in one piece
	local atomic = { "Bays", "Tools", "Workbenches" }
	for _, folderName in ipairs(atomic) do
		local f = garage:FindFirstChild(folderName)
		if f then
			for _, m in ipairs(f:GetChildren()) do
				if m:IsA("Model") then
					m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
				end
			end
		end
	end
	for _, name in ipairs({ "WaitingRoom", "PartsCounter", "ScrapBin", "PartsShelfPlus", "RestoreBay", "PaintBooth", "Showroom", "AlignmentBay", "DynoRoom" }) do
		local m = garage:FindFirstChild(name)
		if m and m:IsA("Model") then
			m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		end
	end
	for _, d in ipairs(garage:GetDescendants()) do
		if d:IsA("Model") and d.Name == "Lift" then
			d.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		end
	end
	garage.WorldPivot = CFrame.new(0, 0, 0)
	garage.Parent = workspace
	-- growth pieces: remember where each belongs, then show the Lv1 look (wr-dev calls Upgrades.apply later)
	-- seasonal decor waits in ServerStorage; World/Seasonal (WorldBoot) moves it into the map in its weeks
	local seasonal = Kit.folder(game:GetService("ServerStorage"), "WorldSeasonal")
	Halloween.decor().Parent = seasonal
	Upgrades.tagHomes(garage)
	Upgrades.apply({ level = 1, owned = {} }, garage)
	return garage
end

return Build
