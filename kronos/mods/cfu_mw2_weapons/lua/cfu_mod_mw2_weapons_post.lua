-- CFU - MWII Weapons: registers with the CFU Core game registry (needs CFU Core).
local queue = rawget(_G, "CFU_MODULES") or {}
rawset(_G, "CFU_MODULES", queue)
queue[#queue + 1] = { api = 1, id = "cfu_mw2_weapons", game = "mwii", content = "weapons", prefixes = { "iw9_" } }
