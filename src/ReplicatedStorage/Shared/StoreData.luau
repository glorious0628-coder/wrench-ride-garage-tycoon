-- The Robux shop's items (docs/design/monetization.md v2 확정판, notes/handoff/pass_build_list.md): what the Garage Shop
-- window lists, in the order it lists them. Shared so the screen and the server read the same numbers
-- (StoreData.envelopeMoney is what a Cash Envelope is worth NOW — wr-dev's ProcessReceipt must pay exactly this).
--
--   key   = Config.Passes[key] (kind "pass") / Config.Products[key] (kind "product") holds the Roblox id
--   shown = only while Config.StoreOn[key] is true (main flips it with the sale switch: made-but-not-on-sale items
--           never appear, and a missing id never shows a dead button)
--   owned = player attribute "Owns<Key>" = true (wr-dev: Passes.owns on join / purchase)
--   Cash Envelopes: player attribute "EnvLeft" = minutes of the day's 90 left (nil = all 90); one that doesn't fit is
--   shown locked "Tomorrow again" (no countdown), the server refuses it too.
-- Names / descriptions: Locale store.<Key>.name / store.<Key>.d (EN + KO).

local StoreData = {}

export type Item = { key: string, kind: "pass" | "product", price: number, minutes: number?, size: string? }

StoreData.Items = {
	{ key = "StarterPack", kind = "pass", price = 99 },
	{ key = "PayBoost", kind = "pass", price = 249 },
	{ key = "CashSmall", kind = "product", price = 49, minutes = 10, size = "small" },
	{ key = "CashMedium", kind = "product", price = 129, minutes = 30, size = "medium" },
	{ key = "CashBig", kind = "product", price = 299, minutes = 90, size = "big" },
	{ key = "VIPMechanic", kind = "pass", price = 299 },
	{ key = "GoldTools", kind = "pass", price = 249 },
	{ key = "GarageRename", kind = "pass", price = 299 },
} :: { Item }

StoreData.DayMinutes = 90 -- (one Big envelope's worth a day)

-- the small grey "Need $400 more · Cash options" under a tools-shop Buy button when money is short and envelopes are on
-- sale (monetization §4-4, as specified). GPT (store_r1) advises removing it: it turns a game-cash shortage into a Robux
-- nudge for kids. One switch: false removes it everywhere.
StoreData.ToolShopHint = false -- (off by default: GPT twice advised against it; the owner may turn it on)

-- money for 10 / 30 / 90 minutes of solo work by garage level band (pass_build_list B: Lv1-5 · Lv6-15 · Lv16+)
local PAY = { [10] = { 480, 750, 870 }, [30] = { 1450, 2250, 2600 }, [90] = { 4350, 6750, 7800 } }
local function band(level: number): number
	return if level >= 16 then 3 elseif level >= 6 then 2 else 1
end

-- what an envelope of `minutes` (10 / 30 / 90) pays at this garage level; Pay Boost never multiplies it
function StoreData.envelopeMoney(level: number, minutes: number): number
	local row = PAY[minutes]
	return if row then row[band(level)] else 0
end

return StoreData
