-- CFU stable v1.41 buttons 04: shared artwork for weapons, Favorites and Operators.
if rawget(_G, "MWCF_GAME_LOGOS_V1") then return end
local clua = rawget(_G, "CLUA")
local H = type(clua) == "table" and clua.PushXHash or rawget(_G, "xhash")
if type(H) ~= "function" then return end
local tileKey, imageKey = H("0x0648ecb61dd2e647"), H("0xc59481e8ff223721")
local images = { "mwcf_game_logo_bo7", "mwcf_game_logo_bo6", "mwcf_game_logo_mwiii", "mwcf_game_logo_mwii" }
local API = {}
function API.icon(index)
  return assert(clua.PushXHashAsset, "CFU custom image lookup missing")(assert(images[index], "invalid CFU game"))
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
