-- CFU Core 2 (modular phase 1b): the five-game registry plus the shared logo artwork for weapons, Favorites and Operators.
-- Games are fixed and always shown in this order. BO7 is always unlocked; BO6 unlocks when Kronos provides BO6 rows;
-- every other game unlocks per screen when a module for it has registered:
--   local q = rawget(_G, "CFU_MODULES") or {}; rawset(_G, "CFU_MODULES", q)
--   q[#q + 1] = { api = 1, id = "cfu_mw2_weapons", game = "mwii", content = "weapons", prefixes = { "iw9_" } }
-- The queue is read when a menu is built, so the order Kronos loads mod Lua files in does not matter.
if rawget(_G, "MWCF_GAME_LOGOS_V1") then return end
local clua = rawget(_G, "CLUA")
local H = type(clua) == "table" and clua.PushXHash or rawget(_G, "xhash")
if type(H) ~= "function" then return end
local tileKey, imageKey = H("0x0648ecb61dd2e647"), H("0xc59481e8ff223721")

local GAMES = {
  { id = "bo7", label = "BO7", prefixes = { "sat_" }, icon = "mwcf_game_logo_bo7" },
  { id = "bo6", label = "BO6", prefixes = { "t10_" }, icon = "mwcf_game_logo_bo6" },
  { id = "mwiii", label = "MWIII", prefixes = { "jup_" }, icon = "mwcf_game_logo_mwiii" },
  { id = "mwii", label = "MWII", prefixes = { "iw9_" }, icon = "mwcf_game_logo_mwii" },
  { id = "vanguard", label = "Vanguard", prefixes = { "rdf_sm_vg_", "rdf_dm_vg_" }, icon = "mwcf_game_logo_vanguard" },
}
local GAME_INDEX = {}
for index, game in ipairs(GAMES) do GAME_INDEX[game.id] = index end
local CONTENT = { weapons = true, operators = true }
-- Locked logos are separate grayscale PNGs (<icon>_locked) at the same opacity as an unselected logo; the native
-- tile shows them like any other logo and the lock badge sits on top.
local LOCK_IMAGE = "mwcf_game_lock"
local unpack = unpack or table.unpack

local API = { games = GAMES, lockImage = LOCK_IMAGE }

function API.icon(index, locked)
  local game = assert(GAMES[index], "invalid CFU game")
  local name = locked and index ~= 1 and (game.icon .. "_locked") or game.icon
  return assert(clua.PushXHashAsset, "CFU custom image lookup missing")(name)
end

-- One string per lock pattern, so a picker can tell when its tiles need rebuilding.
function API.lockSignature(locked)
  local parts = {}
  for index = 1, #GAMES do parts[index] = locked[index] and "1" or "0" end
  return table.concat(parts)
end

-- Registered modules, deduplicated by id. Invalid entries are skipped.
function API.modules()
  local list, seen = {}, {}
  local function add(entry)
    if type(entry) ~= "table" or type(entry.id) ~= "string" or seen[entry.id] then return end
    if not GAME_INDEX[entry.game] or not CONTENT[entry.content] then return end
    if entry.api ~= nil and entry.api ~= 1 then return end
    seen[entry.id] = true
    list[#list + 1] = entry
  end
  local queue = rawget(_G, "CFU_MODULES")
  if type(queue) == "table" then
    for _, entry in ipairs(queue) do add(entry) end
  end
  -- Vanguard module 0.1.0 and earlier announced itself through the old single-game extension.
  local legacy = rawget(_G, "MWCF_WEAPON_GAME_EXTENSION")
  if type(legacy) == "table" and legacy.prefix == "rdf_sm_vg_" then
    add({ api = 1, id = "cfu_vanguard_module", game = "vanguard", content = "weapons",
      prefixes = { legacy.prefix, legacy.alternatePrefix } })
  end
  return list
end

-- Kronos' Carry Forward launcher setting, read the way Kronos' own Lua does (dvar 970a7a4f1d271a37 is "1" when on).
-- BO6 guns only exist while it is on. nil when the dvar can't be read (then callers fall back to row detection).
function API.kronosCarryForward()
  local K = rawget(_G, "KRONOS")
  if type(K) ~= "table" or type(K.dvar) ~= "function" then return nil end
  local ok, value = pcall(K.dvar, "970a7a4f1d271a37")
  if not ok then return nil end
  return tostring(value) == "1"
end

function API.hasModule(gameId, content)
  for _, entry in ipairs(API.modules()) do
    if entry.game == gameId and entry.content == content then return true end
  end
  return false
end

-- Weapon-ref prefixes per game: Core's fixed ones plus any a registered weapons module adds.
function API.prefixes(index)
  local game = GAMES[index]
  local result = {}
  for _, prefix in ipairs(game.prefixes) do result[#result + 1] = prefix end
  for _, entry in ipairs(API.modules()) do
    if entry.game == game.id and entry.content == "weapons" and type(entry.prefixes) == "table" then
      for _, prefix in ipairs(entry.prefixes) do
        if type(prefix) == "string" and prefix ~= "" then result[#result + 1] = prefix end
      end
    end
  end
  return result
end

-- Game index for a weapon ref; nil if no game claims it.
function API.gameOfRef(ref)
  if type(ref) ~= "string" then return nil end
  for index in ipairs(GAMES) do
    for _, prefix in ipairs(API.prefixes(index)) do
      if ref:sub(1, #prefix) == prefix then return index end
    end
  end
end

-- content = "weapons" or "operators"; bo6Present = whether Kronos gave this screen BO6 rows.
function API.lockStates(content, bo6Present)
  local locked = {}
  for index, game in ipairs(GAMES) do
    if index == 1 then
      locked[index] = false
    elseif game.id == "bo6" then
      locked[index] = not bo6Present and not API.hasModule("bo6", content)
    else
      locked[index] = not API.hasModule(game.id, content)
    end
  end
  return locked
end

-- Next unlocked index from `from`, stepping by `step` (+1/-1) with wrap; `from` itself if none.
function API.step(locked, from, step)
  local count = #GAMES
  local index = from
  for _ = 1, count - 1 do
    index = ((index - 1 + step) % count) + 1
    if not locked[index] then return index end
  end
  return from
end

-- Where a focus request on `target` should land. A click on a locked tab snaps back to the current game.
-- Controller/keyboard navigation through the tab bar's own buttons (navigating = true) skips locked tabs in the
-- direction of travel; a jump that is not to a neighbour also snaps back.
function API.redirect(locked, current, target, navigating)
  if not locked[target] then return target end
  if not navigating then return current end
  local count = #GAMES
  if target == ((current % count) + 1) then return API.step(locked, current, 1) end
  if target == (((current - 2) % count) + 1) then return API.step(locked, current, -1) end
  return current
end

-- Lock badge in the tile's bottom-right corner and no mouse on locked tiles. Every call is protected: the tile is native.
function API.applyLock(tile, locked)
  if not tile then return end
  locked = locked == true
  if type(tile.SetHandleMouse) == "function" then pcall(tile.SetHandleMouse, tile, not locked) end
  local badge = tile._cfuLockBadge
  if locked and not badge then
    pcall(function()
      local image = LUI.UIImage.new()
      image:SetAnchorsAndPosition(1, 0, 1, 0, -14, -2, -14, -2)
      local material = RegisterMaterial(clua.PushXHashAsset(LOCK_IMAGE))
      if material then image:setImage(material, 0) end
      image:SetAlpha(1, 0)
      tile:addElement(image)
      badge = image
      tile._cfuLockBadge = image
    end)
  end
  if badge then pcall(badge.SetAlpha, badge, locked and 1 or 0, 0) end
  tile._cfuLocked = locked
end

-- Mark focus changes that come from the tab bar's own controller/keyboard buttons (shoulders, Q/E, stick), so a
-- click can be told apart from navigation. `owner.navigating` is > 0 while such a callback runs.
function API.trackNavigation(tabs, owner)
  if type(tabs) ~= "table" or tabs._cfuNavigationTracked then return end
  tabs._cfuNavigationTracked = true
  local function wrap(callback)
    if type(callback) ~= "function" then return callback end
    return function(...)
      owner.navigating = (owner.navigating or 0) + 1
      local result = (function(...) return { n = select("#", ...), ... } end)(pcall(callback, ...))
      owner.navigating = owner.navigating - 1
      if not result[1] then error(result[2], 0) end
      return unpack(result, 2, result.n)
    end
  end
  local callbacks = tabs.m_gamepadEventCallbackTable
  if type(callbacks) == "table" then
    for button, callback in pairs(callbacks) do callbacks[button] = wrap(callback) end
  end
  local add = tabs.AddGamepadEventCallback
  if type(add) == "function" then
    tabs.AddGamepadEventCallback = function(self, button, callback, ...)
      return add(self, button, wrap(callback), ...)
    end
  end
end

function API.buildTile(builder, controller)
  local tile = builder.BuildRegisteredType(tileKey, { controllerIndex = controller })
  local image = tile[imageKey] or tile[H("0x459481e8ff223721")]
  if image == nil then error("native project logo element missing", 0) end
  -- The stock square icon uses SetFixedAspectRatioImage, which repeats wide
  -- PNGs vertically. Use the engine's non-tiling mode and a matching 2:1 box.
  image:SetFixedAspectRatioImage(false)
  image:SetFixedAspectRatioImageNoTile(true)
  image:SetAnchorsAndPosition(0.5, 0.5, 0.5, 0.5, -25, 25, -12.5, 12.5)
  return tile
end

rawset(_G, "MWCF_GAME_LOGOS_V1", API)
rawset(_G, "CFU_CORE", API)
