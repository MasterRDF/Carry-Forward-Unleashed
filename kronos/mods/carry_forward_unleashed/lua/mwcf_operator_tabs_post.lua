if rawget(_G, "MWCF_OPERATOR_TABS_V1") then return end

local clua = rawget(_G, "CLUA")
local H = type(clua) == "table" and clua.PushXHash or rawget(_G, "xhash")
if type(H) ~= "function" then return end
rawset(_G, "MWCF_OPERATOR_TABS_V1", true)

if rawget(_G, "KRONOS_ZOMBIES_OPERATOR_TABS_ZT1") then return end
rawset(_G, "KRONOS_ZOMBIES_OPERATOR_TABS_ZT1", true)
local bo6Rank = {
  ["02930f777705bcfe"] = 1,
  ["2aa0c21c82b46ff0"] = 2,
  ["1044fee70a2600cc"] = 3,
  ["60a944573bd16b2a"] = 4,
  ["6aa83088893431a8"] = 5,
  ["41eab140c3d51f96"] = 6,
  ["6be320a121f57981"] = 7,
  ["350f5ffaf94efd9a"] = 8,
  ["7ee7f4399ea9ce15"] = 9,
  ["76314540268bdcf6"] = 10,
  ["5168af5851c0df54"] = 11,
  ["2a11f64aba7384fc"] = 12,
  ["629fd1ef8406277a"] = 13,
  ["6d124712f1a1144b"] = 14,
  ["6b4ddbedadd0b93d"] = 15,
  ["450e69d63609a7d8"] = 16,
  ["4befb758cbd115f9"] = 17,
  ["41c7749edcbe490d"] = 18,
  ["2abb18d783087fc4"] = 19,
  ["014fa87f362e43cb"] = 20,
  ["76f4c7ce2409ca17"] = 21,
  ["1b1d2543ffe7bb67"] = 22,
  ["67921f77a4625d95"] = 23,
  ["603c7668bc5bfd75"] = 24,
  ["46051793adb64ee1"] = 25,
  ["1f2151367d44cff4"] = 26,
  ["299235f344080dd5"] = 27,
  ["40b38385a6946b00"] = 28,
  ["6fc6e9fad211e49f"] = 29,
  ["2d067e5df50750f2"] = 30,
  ["3d5927f4b59f3a93"] = 31,
  ["032f71e07db7bf44"] = 32,
  ["13f3a6a4e3ee9761"] = 33,
  ["03db737b53a3b503"] = 34,
  ["0f14711fa228b1ee"] = 35,
  ["001225aa45b7f70e"] = 36,
  ["67871f4add7ea85f"] = 37,
  ["2703b478111207ce"] = 38,
  ["30faf2fceaebc15c"] = 39,
  ["188a1bf1c27b76c4"] = 40,
  ["4c603a78fb07d9c7"] = 41,
  ["2f09e7279d99bde3"] = 42,
  ["788a4b9d7cac2ae1"] = 43,
  ["387d9fd28976a721"] = 44,
  ["75df2505a621a8dd"] = 45,
  ["1402d158f1739578"] = 46,
  ["4b94743107daa5c5"] = 47,
  ["46107b93bf26e953"] = 48,
  ["605cc7886d5c7566"] = 49,
  ["307737d1cef8686c"] = 50,
  ["4f13c316d224a460"] = 51,
  ["42b60637ba62e816"] = 52,
  ["77f27320a94a4323"] = 53,
  ["39950f5858ad2edf"] = 54,
  ["3fb631500d3d2b4c"] = 55,
  ["71d7bc48a427edc0"] = 56,
  ["2e229ded16855d29"] = 57,
  ["7fc5dbf6ee1791cb"] = 58,
  ["374e1f894515f658"] = 59,
  ["6d693e82226caf3c"] = 60,
  ["060bb66b72586c94"] = 61,
  ["398b487ab3ab3604"] = 62,
  ["4c852d9621b4e298"] = 63,
  ["6c87d14c8bcfbc20"] = 64,
  ["3717a8a0491a802f"] = 65,
  ["7b174d5bcd462460"] = 66,
  ["4ce150e94bd139f1"] = 67,
  ["595c0db38d26e3c5"] = 68,
  ["5e6d59344db26859"] = 69,
}
local mwGame = {
  ["2144b231ee61b7bc"] = 4,
  ["57ce19d8501b12bb"] = 4,
  ["7c6754028bc31103"] = 4,
  ["64160da0791cbf36"] = 3,
  ["1fad9559d907446e"] = 4,
  ["4ddb12f471a98764"] = 4,
  ["029daf10efcddd21"] = 3,
  ["57c1cb281374c5f9"] = 3,
  ["5b76a143c2511e46"] = 4,
  ["2bb41893adbd2966"] = 3,
  ["7eba0705b56228d6"] = 3,
  ["046e22ee73e7dc50"] = 3,
  ["20bd95b7fd5b0516"] = 3,
  ["17c855dc6c70bd02"] = 4,
  ["129e23b338521ff0"] = 4,
  ["20b2417c10010917"] = 4,
  ["5996c23723c9764d"] = 3,
  ["443f7f49d4390a26"] = 3,
  ["03820265cb045762"] = 3,
  ["61845612411c257e"] = 3,
  ["35255fe8c7af1aed"] = 3,
  ["488e8ad6ac097fd7"] = 3,
  ["4e11a9d78f102246"] = 3,
  ["788e21c702bce512"] = 3,
  ["3a98aacb2933ea58"] = 3,
  ["67298a9ef9c94d86"] = 3,
  ["4a28bad9e7d4aec3"] = 3,
  ["6b57f4888b07f764"] = 3,
  ["7e6a0176a2674fc5"] = 3,
  ["558e185cd316c8df"] = 3,
  ["6893fdb22671c6b1"] = 3,
  ["18b72732700e64aa"] = 3,
  ["3c26cbdd18b22058"] = 3,
  ["2ce1a212a8d46a7c"] = 3,
  ["2d8212c34493d105"] = 3,
  ["55eec25f6e94471a"] = 3,
  ["5313be5ea15fc280"] = 3,
  ["0c425395f74780ce"] = 3,
  ["230fbd95a034836c"] = 3,
  ["081931cc82bf2aa9"] = 3,
  ["09b4a17bdbdf2291"] = 3,
  ["0461c14000296c24"] = 3,
  ["6f536635c026c149"] = 3,
  ["2d243210f3334135"] = 3,
  ["101eae661b3bd9ee"] = 3,
  ["2e26fc477b45ca8c"] = 3,
  ["4f01a7478d5f3064"] = 3,
  ["6091f54797637160"] = 3,
  ["460cf7e240e95a4c"] = 3,
  ["07f7c5a08dc8cfa1"] = 3,
  ["69b14d54bf98ea37"] = 3,
  ["583960d199299e4f"] = 3,
  ["6c3f7e7c98321fc5"] = 3,
  ["5a77edf921176a4d"] = 3,
  ["5d161d72b5fd807d"] = 3,
  ["7c14ee2f50e66eec"] = 3,
  ["33468880f3a8f49e"] = 3,
  ["1a81dfbf44e19bfa"] = 3,
  ["46810eb555dd0632"] = 3,
  ["6dc3ade09c6775a6"] = 3,
  ["0148785e56d61e4d"] = 3,
  ["517227ca53e51fcc"] = 3,
  ["6b0512b0ba9ef554"] = 3,
  ["068f9a7285029f21"] = 3,
  ["5537717cd3f13e51"] = 3,
  ["7828a3c28529a94d"] = 3,
  ["720d61a31a459702"] = 3,
  ["28d3f84f53acaff9"] = 3,
  ["3dfd72bb1eac299d"] = 3,
  ["26e9baa656a104c5"] = 3,
  ["1201c8a39949848e"] = 4,
  ["72c148f5392bf42d"] = 4,
  ["7cc5851d831398be"] = 4,
  ["0e22beaf5b4af639"] = 4,
  ["322ab09849868ebb"] = 4,
  ["06264a1fe3983357"] = 4,
  ["392495cf8fa933c7"] = 4,
  ["0e10c440839b0b70"] = 4,
  ["7e67e344d0323afb"] = 4,
  ["7f7a0c7371216966"] = 4,
  ["3a3287df14310640"] = 4,
  ["10be543335b72ac3"] = 4,
  ["7cc6a025a1de45f5"] = 4,
  ["13cb05535a90ce53"] = 4,
  ["03bf9fc07837fd84"] = 4,
  ["68a66039bfdb40b5"] = 4,
  ["312de57c40184877"] = 4,
  ["7ccc73e20851ff9d"] = 4,
  ["1420c4f94246208f"] = 4,
  ["0465a8af5abaa28f"] = 4,
  ["7f427b545033f8fc"] = 4,
  ["12f493d3163d0f4d"] = 4,
  ["0a3b08c441281768"] = 4,
  ["5492db9b14aa08e0"] = 4,
  ["5ea38c76ab0e975d"] = 4,
  ["5640f98513cf3bd5"] = 4,
  ["061ca70b13e9d3cc"] = 4,
  ["6fa5801ab5e382b7"] = 4,
  ["50aee65463daddce"] = 4,
  ["0b07e68003acce03"] = 4,
  ["3306b3b2de6acc19"] = 4,
  ["4cfe76ba7307be86"] = 4,
  ["1620cc538f9baecc"] = 4,
  ["114bebf3da4c7d8a"] = 4,
  ["599a5c5f0ba3511f"] = 4,
  ["45cb789ebf14f6bd"] = 4,
  ["2da374201b08c4b7"] = 4,
  ["33241a7584d96657"] = 4,
  ["4c29f231f9b1558d"] = 4,
  ["0663d7c45b6a9117"] = 4,
  ["61789f98ca6393bc"] = 4,
  ["05eb2487291905ad"] = 4,
  ["0bb22ccd889e927f"] = 4,
  ["5caee9a847b43c6e"] = 4,
  ["6c3a322ae8af7690"] = 4,
  ["0d33467afa658c7d"] = 4,
  ["08d549c954575e2c"] = 4,
  ["680846934fa9a173"] = 4,
  ["4b41df0bd80c517b"] = 4,
  ["3d6e6382efad77d9"] = 4,
  ["58b13415e9fd4d20"] = 4,
  ["6684b79ed25c345a"] = 4,
  ["0a4d960b98fb53a6"] = 4,
  ["33e63c0dd1d1e1a1"] = 4,
  ["4db4a87d517b1469"] = 4,
  ["3732faeaf282dceb"] = 4,
  ["1d3b6176cd6fbe7b"] = 4,
  ["1a5e168b2d01e350"] = 4,
}
local bo6RankCount = 69
local hiddenOperator = {
  ["0e0caef16259bd96"] = true,
  ["142f55e6c13cde9a"] = true,
  ["42586938d87ad941"] = true,
  ["003f376d9b53418f"] = true,
  ["24052897969a2b3b"] = true,
  ["362949e9384080d6"] = true,
  ["6f7f4a53c363fde9"] = true,
  ["398d449ce0f62cdf"] = true,
  ["4c56f8020460f7ba"] = true,
  ["1b4c998079e1f934"] = true,
  ["1248f42524a2452d"] = true,
}
local menuKey = H("0x6f5877a0229c03a2")
local gridKey = H("0x6f9269969df7d039")
local stockTabsKey = H("0x80d06d74ad5d2a5c")
local tabTileKey = H("0x0648ecb61dd2e647")
local projectIconsKey = H("0x0f0f221b69988bff")
local projectNamesKey = H("0xea4f138c40981e2b")
local frontKey = H("0x112586a3f4fb490e")
local zombiesKey = H("0x589367a5b3c4aa7f")
local unlockedKey = H("0x7a55e1714aecc27c")
local randomKey = H("0x46478178a93ec857")
local positionKey = H("0xb0a40fac7a2f4c0f")
local unlockWidgetKey = H("0x964680debbdd0100")
local closeKey = H("0x40c83bfa5eb0de2b")
local focusKey = H("0x2ad199a309edf37e")
local asyncRosterKey = H("0x65b2cac5b9de3065")
local rosterOptionConditionKey = H("0x6597dbc5b9c78590")
local rosterOptionKey = H("0xdae650b6438ac144")
local showcaseOptionKey = H("0xdb6d56e65a89558d")
local rosterKey = H("0xf984b15da88608ac")
local projectCacheKey = H("0xa5a05e13ac947c99")
local cachedMenuListKey = H("0x3d2fd448feb7a519")
local operatorCacheKey = H("0xd027dc265c99e256")
local animationMaskKey = H("0x28dfd5e2759ba3f8")
local rowAnimationsKey = H("0xa0522766f1a57642")
local readRowAnimationsKey = H("0x8c28fc94b77fed2a")
local animationMapsKey = H("0x6261548dcb2c3290")
local unpack = unpack or table.unpack
local seen = setmetatable({}, { __mode = "k" })
local watched = setmetatable({}, { __mode = "k" })
local bo6Listeners = setmetatable({}, { __mode = "k" })
local reported = false
local recoveryReported = false
local traces = {}
local retryDelays = { 250, 750, 1750, 3750 }

local function trace(event, detail)
  if traces[event] then return end
  traces[event] = true
  pcall(rawget(_G, "DebugPrint"), "k1 [CFU operator tabs 4] event=" .. event .. " " .. detail)
end

local function reportError(stage, err, restoreErr)
  if reported then return end
  reported = true
  local detail = restoreErr and " restore_error=" .. tostring(restoreErr) or ""
  pcall(rawget(_G, "DebugPrint"), "k1 [CFU operator tabs 4] stage=" .. stage ..
    " error=" .. tostring(err) .. detail)
end

local function pack(...)
  return { n = select("#", ...), ... }
end

local function bo6Watcher()
  local watcher = rawget(_G, "__kronosBo6MenuWraps")
  if type(watcher) ~= "table" or watcher.o ~= OPERATOR or type(watcher.check) ~= "function" then return end
  if not watched[watcher] then
    local check = watcher.check
    watcher.check = function(...)
      if next(bo6Listeners) == nil then return check(...) end
      local previous = watcher.resets
      local result = pack(check(...))
      if watcher.resets ~= previous then
        for _, listener in pairs(bo6Listeners) do pcall(listener) end
      end
      return unpack(result, 1, result.n)
    end
    watched[watcher] = true
  end
  return watcher
end

local function isZombiesFrontend()
  return Engine[frontKey]() == true and GameModesUtils[zombiesKey]() == true
end

local function eligible()
  local ok, value = pcall(isZombiesFrontend)
  return ok and value == true
end

local function hash63(ref)
  local hash = tostring(ref):match("#x%x(%x+)")
  if not hash or #hash > 16 then return nil end
  hash = string.rep("0", 16 - #hash) .. hash:lower()
  return string.format("%x%s", tonumber(hash:sub(1, 1), 16) % 8, hash:sub(2))
end

local bo7PriorityKey = H("0xb60abd1d0ee08560")
local bo7DisplayKey = H("0xe4fb3c98aeeab347")

local function repairBO7Order(rows)
  for _, row in ipairs(rows) do
    if tonumber(row.displayOrder) ~= 0 then return end
  end

  local ranked, recovered = {}, false
  for index, row in ipairs(rows) do
    local priority, unlocked = row[bo7PriorityKey], row[unlockedKey]
    if type(priority) ~= "boolean" or (unlocked ~= nil and type(unlocked) ~= "boolean") then return end
    local bundle = row.bundle
    if bundle == nil then return end
    local value = bundle[bo7DisplayKey]
    local order = math.huge
    if value ~= nil then
      local number = tonumber(value)
      if not number or not (number > -math.huge and number < math.huge) then return end
      if number >= 0 then
        order = number
        recovered = recovered or number > 0
      end
    end
    ranked[index] = { row = row, index = index, priority = priority, unlocked = unlocked == true, order = order }
  end
  if not recovered then return end

  table.sort(ranked, function(a, b)
    if a.priority ~= b.priority then return a.priority end
    if a.unlocked ~= b.unlocked then return a.unlocked end
    if a.order ~= b.order then return a.order < b.order end
    return a.index < b.index
  end)
  for index, entry in ipairs(ranked) do rows[index] = entry.row end
end

local function split(rows)
  local stock, carry, sorted, mw3, mw2 = {}, {}, {}, {}, {}
  for _, row in ipairs(rows) do
    local hash = type(row) == "table" and hash63(row.ref)
    if not hash then return nil end
    if not hiddenOperator[hash] then
      local rank, game = bo6Rank[hash], mwGame[hash]
      if game then
        local group = game == 3 and mw3 or mw2
        group[#group + 1] = row
      elseif rank then
        if carry[rank] then return nil end
        carry[rank] = row
      else
        stock[#stock + 1] = row
      end
    end
  end
  for rank = 1, bo6RankCount do
    if carry[rank] then sorted[#sorted + 1] = carry[rank] end
  end
  if #stock == 0 then return nil end
  pcall(repairBO7Order, stock)
  return { stock, sorted, mw3, mw2 }
end

local function rebuildBO6Roster(screen)
  local cache, operators = PROJECT[projectCacheKey], OPERATOR
  if type(cache) ~= "table" then
    trace("project_cache_unavailable", "type=" .. type(cache))
    return
  end
  local previousList, previousDerived = cache[cachedMenuListKey], operators[operatorCacheKey]
  cache[cachedMenuListKey], operators[operatorCacheKey] = nil, nil
  local ok, groups = pcall(function()
    local showcase = screen._forShowcase
    local rows = operators[rosterKey](screen._controllerIndex, {
      [rosterOptionKey] = CONDITIONS[rosterOptionConditionKey]() and not showcase,
      [showcaseOptionKey] = showcase,
    })
    local result = type(rows) == "table" and split(rows)
    local bo6 = result and result[2]
    trace(bo6 and "original_roster_bo6" or "original_roster_pending",
      "rows=" .. (type(rows) == "table" and #rows or 0) .. " bo6=" .. (bo6 and #bo6 or 0))
    return result
  end)
  local bo6 = ok and groups and groups[2] and #groups[2] > 0 and groups[2]
  if not bo6 and PROJECT[projectCacheKey] == cache and OPERATOR == operators then
    cache[cachedMenuListKey], operators[operatorCacheKey] = previousList, previousDerived
  end
  if not ok then error(groups, 0) end
  return groups
end

local function resize(state, menu, grid, rows, unlocked, random)
  local count = #rows
  local cells = count + random
  state.stage = "read_columns"
  local columns = grid:GetNumColumns()
  assert(type(columns) == "number" and columns > 0 and columns % 1 == 0, "invalid operator grid column count")
  local rowCount = math.ceil(cells / columns)
  state.gridChanged = true
  state.resizing = true
  state.stage = "reset_rows"
  grid:SetNumRows(-1)
  state.stage = "reset_children"
  grid:SetNumChildren(-1)
  state.view, state.random = rows, random
  menu._operators, menu._operatorCount, menu._unlockedOperatorCount = rows, count, unlocked
  state.stage = "set_rows"
  grid:SetNumRows(rowCount)
  state.stage = "set_children"
  grid:SetNumChildren(cells)
  state.resizing = false
  state.stage = "update_count"
  local header = menu[unlockWidgetKey]
  local label = header and header.UnlockCount
  if label and type(label.UpdateCount) == "function" then label:UpdateCount(unlocked, count, true) end
end

local function contains(rows, ref)
  if ref == nil then return false end
  for _, row in ipairs(rows) do
    if row.ref == ref then return true end
  end
  return false
end

local function highlightProjectTab(tabs, index)
  local elements = tabs._tabElements
  if not elements then return end
  local selected = elements[index]
  for i, other in ipairs(elements) do if i ~= index then other:Deselect() end end
  if not selected then return end
  selected:Select()
end

local function attachMenu(builder, menu)
  if not menu or seen[menu] or menu._forShowcase or not menu.isSoloOperatorSelect then return end
  local grid = menu[gridKey]
  local nextFrame = Frame and Frame.Next
  local stockTabs = menu[stockTabsKey]
  if not grid or type(grid.RefreshContent) ~= "function" or not nextFrame or
      type(nextFrame.Queue) ~= "function" or (stockTabs and stockTabs:IsVisible()) then
    trace("attach_skipped", "grid=" .. tostring(grid ~= nil) .. " next_frame=" .. tostring(nextFrame ~= nil)
      .. " stock_tabs_visible=" .. tostring(stockTabs ~= nil and stockTabs:IsVisible()))
    return
  end
  trace("attached", "solo operator screen")

  local originalRefresh = grid.RefreshContent
  local owner = setmetatable({ menu }, { __mode = "v" })
  local state = { selected = 1, focus = {} }

  local function guardRefresh(target)
    state.stage = "guard_refresh"
    local original = target._activeRefreshChild
    assert(type(original) == "function" and type(target.SetRefreshChildInC) == "function",
      "operator tile refresh unavailable")
    if state.refreshOriginal == original then return end
    target:SetRefreshChildInC(function(tile, x, y)
      if state.resizing then return end
      local screen = owner[1]
      local rows = screen and screen._operators
      if rows and rows == state.view and not (state.random == 1 and x == 0 and y == 0) then
        local index = screen[gridKey]:GetContentIndex(x, y) + 1 - state.random
        local row = rows[index]
        if not row then return end
        if tile._operatorInfo ~= row then tile._operatorIndex = nil end
      end
      return original(tile, x, y)
    end)
    state.refreshOriginal = original
  end

  local function fail(screen, target, err)
    local stage = state.stage
    state.disabled = true
    state.resizing = false
    if state.tabs then
      pcall(state.tabs.SetVisible, state.tabs, false)
    end
    local restoreError
    if state.gridChanged and (screen._operators == state.view or screen._operators == state.source) then
      screen._operators, screen._operatorCount, screen._unlockedOperatorCount =
        state.source, state.sourceCount, state.sourceUnlocked
      local restored, reason = pcall(function()
        state.stage = "restore_focus"
        target:SetDefaultFocus(state.sourceDefaultFocus)
        resize(state, screen, target, state.source, state.sourceUnlocked, state.sourceRandom)
        state.stage = "refresh_stock"
        originalRefresh(target)
      end)
      state.resizing = false
      if not restored then restoreError = state.stage .. " " .. tostring(reason) end
    end
    if state.refreshOriginal and target._activeRefreshChild == state.refreshOriginal then
      local restored, reason = pcall(target.SetRefreshChildInC, target, state.refreshOriginal)
      if not restored then restoreError = restoreError or "restore_tile_callback " .. tostring(reason) end
    end
    state.view = nil
    reportError(stage, err, restoreError)
  end

  local function apply(screen, target, index)
    state.stage = "select_operator"
    local rows = state.groups[index]
    local ref = state.focus[index]
    if not contains(rows, ref) then ref = screen:GetSelectedOperator() end
    if not contains(rows, ref) then ref = rows[1] and rows[1].ref end
    local random = index == 1 and CONDITIONS[randomKey]() and 1 or 0
    local unlocked = 0
    for _, row in ipairs(rows) do
      if row[unlockedKey] == true then unlocked = unlocked + 1 end
    end
    guardRefresh(target)
    state.random = random
    resize(state, screen, target, rows, unlocked, random)
    state.stage = "set_focus"
    if #rows == 0 then
      originalRefresh(target)
      return
    end
    local position = OPERATOR[positionKey](target, rows, ref, random)
    assert(position and position.x and position.y, "operator focus unavailable")
    target:SetDefaultFocus(position)
    state.stage = "refresh"
    originalRefresh(target)
    state.stage = "focus_and_preview"
    target:SetFocusedPosition(position, true, false)
    target:SetTargetLine(LUI.DIRECTION.vertical, position.y, false, true)
    target:UpdateScrolling()
    local tile = target:GetElementAtPosition(position.x, position.y)
    if tile and not tile.isRandom and type(tile._operatorPreviewCallback) == "function" then
      tile:_operatorPreviewCallback()
    end
  end

  local function selectTab(index)
    local screen = owner[1]
    if not screen or not state.ready or screen._operators ~= state.view or state.closed or
        state.disabled or state.busy or index == state.selected or not state.groups[index] or
        not eligible() or not screen:IsVisible() then return end
    local target = screen[gridKey]
    state.busy = true
    state.stage = "read_tab_focus"
    local ok, err = pcall(function()
      local oldIndex = target:GetContentIndex(target:GetTargetColumn(), target:GetTargetRow())
      local oldRow = state.view[oldIndex + 1 - state.random]
      if oldRow then state.focus[state.selected] = oldRow.ref end
      state.selected = index
      apply(screen, target, index)
    end)
    if ok then
      pcall(highlightProjectTab, state.tabs, state.selected)
    else
      fail(screen, target, err)
    end
    state.busy = false
  end

  local function syncTabs(screen)
    local count = #state.groups
    if state.tabCount == count then return end
    local logos = assert(rawget(_G, "MWCF_GAME_LOGOS_V1"), "CFU logo module missing")
    local names = { "BO7", "BO6", "MWIII", "MWII" }
    local entries = {}
    for index = 1, count do
      local icon = logos.icon(index)
      local name = names and names[index]
      assert(icon and name, "operator project tabs unavailable")
      entries[index] = { tabIndex = index - 1, project = name, icon = icon, _isVisible = true,
        focusFunction = function() selectTab(index) end }
    end

    local tabs = state.tabs
    if not tabs then
      local controller = screen._controllerIndex
      tabs = LUI.TabManager.new({
        tabHeight = 40, useRightStick = true, spacing = 0, wrap = true,
        rightStickDelay = 500, rightStickDeadzone = 0.5, controllerIndex = controller,
        buildTab = function()
          return logos.buildTile(builder, controller)
        end,
      })
      state.tabs = tabs
      tabs.id = "CFUFourGameOperatorTabs"
      tabs:SetAnchorsAndPosition(0, 1, 0, 1, 83, 393, 613, 663)
      tabs:SetAlignment(LUI.Alignment.Left)
      tabs:SetSendEventOnTabChange(false)
      screen:addElement(tabs)
    end
    tabs:SetTabs(entries, { defaultTab = state.selected - 1 })
    state.tabCount = count
  end

  local function projectRoster(screen)
    local source = screen._operators
    if type(source) ~= "table" or source == state.view then return end
    local groups = split(source)
    if state.groups and #state.groups[2] > 0 then state.bo6Generation = nil end
    state.ready = false
    state.source, state.sourceUnlocked, state.groups = source, screen._unlockedOperatorCount, groups
    state.sourceCount = screen._operatorCount
    state.sourceRandom = CONDITIONS[randomKey]() and 1 or 0
    state.view = nil
    state.gridChanged = false
    if not groups then
      state.view = nil
      if state.tabs then state.tabs:SetVisible(false) end
      return
    end
    local target = screen[gridKey]
    state.busy = true
    local ok, err = pcall(function()
      state.stage = "install_tabs"
      if not groups[state.selected] then state.selected = 1 end
      syncTabs(screen)
      state.stage = "save_stock_focus"
      state.sourceDefaultFocus = target._defaultFocus
      apply(screen, target, state.selected)
      state.stage = "show_tabs"
      state.tabs:SetVisible(true)
      state.ready = true
      trace(groups[2] and "stock_two_tabs" or "stock_bo7_only",
        "bo7=" .. #groups[1] .. " bo6=" .. (groups[2] and #groups[2] or 0))
    end)
    if ok then
      pcall(highlightProjectTab, state.tabs, state.selected)
    else
      fail(screen, target, err)
    end
    state.busy = false
  end

  local function watchBO6(screen, listener)
    if state.disabled or not state.ready or screen._operators ~= state.view or #state.groups[2] > 0 then
      bo6Listeners[screen] = nil
      return
    end
    bo6Listeners[screen] = listener
    local watcher = bo6Watcher()
    if not watcher then
      trace("watcher_unavailable", "no Kronos BO6 readiness check")
      return
    end
    local generation = watcher.resets or 0
    if state.watcher ~= watcher or state.bo6Generation ~= generation then
      state.watcher, state.bo6Generation, state.bo6Attempts, state.bo6Delay = watcher, generation, 0, nil
    end
    if watcher.missing == false and not state.bo6Delay and state.bo6Attempts <= #retryDelays then return watcher end
  end

  local queueProjection
  local function refreshBO6(screen)
    state.bo6Attempts = state.bo6Attempts + 1
    state.busy = true
    local addedTab = false
    local ok, err = pcall(function()
      state.stage = "read_bo6_roster"
      if CONDITIONS[asyncRosterKey]() then
        state.bo6Attempts = #retryDelays + 1
        trace("async_roster", "waiting for the original asynchronous roster")
        return
      end
      local groups = rebuildBO6Roster(screen)
      if not groups or #groups[2] == 0 then return true end
      local bo6 = groups[2]
      state.stage = "prepare_bo6_animations"
      for _, row in ipairs((function() local all = {} for i=2,4 do for _,row in ipairs(groups[i]) do all[#all+1]=row end end return all end)()) do
        local mask = row.bundle and row.bundle[animationMaskKey] or 0
        row[rowAnimationsKey] = OPERATOR[readRowAnimationsKey](row.ref, mask)
      end
      local animations, weapons = OPERATOR[animationMapsKey](screen._controllerIndex)
      state.stage = "add_bo6_tab"
      state.groups = groups
      addedTab = true
      syncTabs(screen)
      screen._operatorAnimations, screen._operatorWeapons = animations, weapons
      apply(screen, screen[gridKey], state.selected)
      bo6Listeners[screen] = nil
      pcall(highlightProjectTab, state.tabs, state.selected)
      if not recoveryReported then
        recoveryReported = true
        pcall(rawget(_G, "DebugPrint"), "k1 [CFU operator tabs 4] BO6 tab added after roster refresh rows=" .. #bo6)
      end
    end)
    if not ok then
      local stage = state.stage
      if addedTab then
        state.groups[2], state.tabCount = {}, nil
        local restored, reason = pcall(syncTabs, screen)
        if restored then
          pcall(highlightProjectTab, state.tabs, state.selected)
        else
          fail(screen, screen[gridKey], reason)
        end
      end
      reportError(stage, err)
    elseif err then
      local delay = retryDelays[state.bo6Attempts]
      if delay then
        local token = {}
        state.bo6Delay = token
        local scheduled, reason = pcall(function()
          screen:Wait(delay).onComplete = function()
            if state.bo6Delay ~= token then return end
            state.bo6Delay = nil
            queueProjection()
          end
        end)
        if not scheduled then
          state.bo6Delay = nil
          state.bo6Attempts = #retryDelays + 1
          reportError("wait_bo6_roster", reason)
        end
      else
        trace("retry_exhausted", "BO6 menu rows did not arrive within the retry window")
      end
    end
    state.busy = false
  end

  local function updateRoster()
    state.pending = false
    local screen = owner[1]
    if not screen or state.closed or state.disabled or state.busy or not eligible() or not screen:IsVisible() then return end
    if screen._operators ~= state.source then projectRoster(screen) end
    if watchBO6(screen, queueProjection) then refreshBO6(screen) end
  end

  queueProjection = function()
    local screen = owner[1]
    if not screen or state.pending or state.busy or state.disabled or state.closed then return end
    local rows = screen._operators
    local changed = type(rows) == "table" and rows ~= state.view and rows ~= state.source
    if changed or watchBO6(screen, queueProjection) then
      state.pending = true
      local queued = pcall(nextFrame.Queue, nextFrame, updateRoster)
      if not queued then state.pending = false end
    end
  end

  menu:addEventHandler(closeKey, function()
    state.closed = true
    state.bo6Delay = nil
    local screen = owner[1]
    if screen then bo6Listeners[screen] = nil end
  end)
  menu:addEventHandler(focusKey, queueProjection)
  grid.RefreshContent = function(target, ...)
    local result = pack(originalRefresh(target, ...))
    pcall(queueProjection)
    return unpack(result, 1, result.n)
  end
  seen[menu] = state
  queueProjection()
end

local function solo(ref)
  return ref == menuKey or ref == "SoloOperatorSelect" or ref == "solooperatorselect"
end

local function hookBuilder(builder)
  if type(builder) ~= "table" or type(builder.BuildRegisteredType) ~= "function" then return end
  local build = builder.BuildRegisteredType
  builder.BuildRegisteredType = function(ref, ...)
    if not solo(ref) or not eligible() then return build(ref, ...) end
    trace("constructor", "original SoloOperatorSelect requested")
    local result = pack(build(ref, ...))
    local ok, err = pcall(attachMenu, builder, result[1])
    if not ok then reportError("attach_menu", err) end
    return unpack(result, 1, result.n)
  end
end

local builder = rawget(_G, "MenuBuilder")
local lui = rawget(_G, "LUI")
hookBuilder(builder)
if type(lui) == "table" and lui.MenuBuilder ~= builder then hookBuilder(lui.MenuBuilder) end
trace("loaded", "stable v1.41 four-game operator tabs")

rawset(_G, "MWCF_OPERATOR_TABS_API", { split=split, states=seen, mwGame=mwGame })
