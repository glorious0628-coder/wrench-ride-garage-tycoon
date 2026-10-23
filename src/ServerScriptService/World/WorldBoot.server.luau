-- World/WorldBoot (wr-builder): at server start, build the map if the place has none (or an old one).
-- A map baked in edit mode (tools/bake_world.luau) with the same WorldVersion is kept as is.
-- Measuring refs from a builder bake (workspace.BuilderRefs: R15 dummies, car boxes) never belong in a game: removed here.
local refs = workspace:FindFirstChild("BuilderRefs")
if refs then
	refs:Destroy()
end
local Build = require(script.Parent.Build)
Build.build()
require(script.Parent.Seasonal).start() -- Halloween decor in its weeks (World/Seasonal)
