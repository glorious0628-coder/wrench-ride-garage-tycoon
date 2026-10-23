-- The sedan's taken-apart 3D, one table: the engine bay (Generated/SedanBay, engine_bay_v2) + the underside
-- (Generated/SedanUnder, underbody_v1). Every type reads its own the same way: PartData/Car3D.
-- (kept for the tools that read the sedan's: the bake, CarParts.Bay)

return require(script.Parent:WaitForChild("Car3D")).of("Sedan")
