-- CFU Core 2 game picker: five games from the Core registry (mwcf_game_logos_post.lua); locked games stay visible, dimmed
-- and unselectable until a module for them registers.
if rawget(_G, "MWCF_GAME_TABS_V1") then return end

local clua = rawget(_G, "CLUA")
local H = type(clua) == "table" and clua.PushXHash or rawget(_G, "xhash")
if type(H) ~= "function" then return end

if rawget(_G, "KRONOS_ZOMBIES_WEAPON_TABS_WT1") then
  pcall(rawget(_G, "DebugPrint"), "k1 [CFU game tabs 4] native two-game owner already active; compatibility startup did not complete")
  return
end
rawset(_G, "KRONOS_ZOMBIES_WEAPON_TABS_WT1", true)

local pickerKey = H("0x44300646996dd154")
local stockTabsKey = H("0x80d06d74ad5d2a5c")
local tileKey = H("0x0648ecb61dd2e647")
local refreshKey = H("0x651a6c4adce94d00")
local publishKey = H("0x2a4a8b69a4073ac3")
local frontKey = H("0x112586a3f4fb490e")
local zombiesKey = H("0x589367a5b3c4aa7f")
local closeKey = H("0x40c83bfa5eb0de2b")
local gamepadEvent = H("0x13db0863509199a1")
local dpadLeft = H("0x86636c500cd317c7")
local dpadRight = H("0x544ed6dcd32fb7f8")
local projectType = H("0xefa786ccc4be4587")
local projectKeys = { H("0x822d97195cd5ebf7"), H("0xf5f0fd190cf0cf85") }
local iconType = H("0xda31296c0c1b6029")
local iconKeys = { H("0x51637b16239b65bf"), H("0x7ac56c146f9c531d") }
local socialIcons = H("0xb5a3b0a6af9e4216")
local lootProjectKey = H("0x4243ea4416919e21")
local weaponRefKey = H("0x89e9c01960f4c582")
local weaponLootKey = H("0x8028887f70bf5eba")

local states = setmetatable({}, { __mode = "kv" })
local unpack = unpack or table.unpack
local active
local hooks
local directionalHooked
local reported = false

local function pack(...)
  return { n = select("#", ...), ... }
end

local function report(err)
  if reported then return end
  reported = true
  pcall(rawget(_G, "DebugPrint"), "k1 [CFU game tabs 5] error=" .. tostring(err))
end

local function eligible()
  local ok, value = pcall(function()
    return Engine[frontKey]() == true and GameModesUtils[zombiesKey]() == true
  end)
  return ok and value == true
end

local function core()
  return assert(rawget(_G, "CFU_CORE"), "CFU Core registry missing")
end
local function games()
  return core().games
end
local alternateRefKey = H("0x09e9c01960f4c582")
local function gameOf(row)
  local bundle = row and row.bundleData
  if not bundle then return nil end
  local ref = bundle[weaponRefKey] or bundle[alternateRefKey]
  if ref ~= nil then ref = tostring(ref) end
  -- Other installed mods retain their existing BO7 placement.
  return core().gameOfRef(ref) or 1
end
-- Kronos gives BO6 guns only with its Carry Forward setting on. Favorites lists can lack them, so remember a sighting.
local bo6Seen = false

local function groupRows(rows)
  local categories = rawget(_G, "__mwcfCategoriesV1")
  if type(categories) == "table" and type(categories.regroup) == "function" then categories.regroup(rows) end
  local favorites = rawget(rows, "__mwcfFavoritesList") == true
  local groups = {}
  for index = 1, #games() do groups[index] = {} end
  local pending, written = nil, {}
  for _, row in ipairs(rows) do
    local index = gameOf(row)
    if index then
      local group = groups[index]
      if favorites and pending and not written[index] then
        group[#group + 1] = pending
        written[index] = true
      end
      group[#group + 1] = row
    elseif favorites then
      pending, written = row, {}
    end
  end
  for _, group in ipairs(groups) do
    if favorites then group.__mwcfFavoritesList = true end
  end
  return groups
end

local function setView(menu, data, rows)
  data.filteredWeaponDataList = rows
  menu._currentWeapons = rows
end

local function disable(menu, state, err)
  states[menu] = nil
  if state.tabs then pcall(state.tabs.close, state.tabs) end
  report(err)
end

local function highlight(state)
  local elements = state.tabs._tabElements
  local selected = elements and elements[state.selected]
  if selected then
    for index, other in ipairs(elements) do
      if index ~= state.selected then other:Deselect() end
    end
    selected:Select()
  end
  if elements and state.locked then
    for index, element in ipairs(elements) do core().applyLock(element, state.locked[index]) end
  end
end

local function selectProject(menu, state, index)
  if state.locked and state.locked[index] and not state.syncing and states[menu] == state then
    local target = core().redirect(state.locked, state.selected, index, (state.navigating or 0) > 0)
    local function land()
      if states[menu] ~= state then return end
      if target ~= state.selected then
        state.tabs:FocusTab(state.controller, target - 1, FocusType.Gamepad)
      else
        state.redirecting = true
        pcall(state.tabs.FocusTab, state.tabs, state.controller, state.selected - 1, FocusType.Gamepad)
        state.redirecting = false
        highlight(state)
      end
    end
    local nextFrame = rawget(_G, "Frame") and Frame.Next
    if not (nextFrame and pcall(nextFrame.Queue, nextFrame, function() pcall(land) end)) then pcall(land) end
    return
  end
  if state.redirecting or state.syncing or states[menu] ~= state or state.selected == index or
      index > state.tabCount or not eligible() or not menu:IsVisible() then return end
  local scopeOK, data = pcall(LUI.FlowManager.GetScopedData, menu)
  if not scopeOK then
    report(data)
    return
  end
  if not data or data ~= state.data or data.filteredWeaponDataList ~= menu._currentWeapons or
      menu._currentWeapons ~= state.view then return end

  state.selected = index
  state.view = state.groups[index]
  setView(menu, data, state.view)
  local ok, err = pcall(state.publish, state.controller, state.view, data.blueprintsByWeapon)
  if ok then ok, err = pcall(highlight, state) end
  if not ok then
    setView(menu, data, state.rows)
    disable(menu, state, err)
    pcall(state.publish, state.controller, state.rows, data.blueprintsByWeapon)
  end
end

local function switchWithDpad(menu, event, index)
  local state = states[menu]
  if not state or state.tabCount ~= #games() or state.syncing or state.selected == index or
      event.controller ~= state.controller or not eligible() or not menu:IsVisible() then return end
  state.tabs:FocusTab(state.controller, index - 1, FocusType.Gamepad)
  return states[menu] == state and state.selected == index
end

local function dpadIndex(event)
  if type(event) ~= "table" or event.name ~= gamepadEvent or
      event.qualifier == "keyboard" or event.down ~= true then return end
  if event.button == "left" then return -1 end
  if event.button == "right" then return 1 end
end

local function tryDpad(event, index, menu, root)
  local ok, switched = pcall(function()
    local info = LUI.FlowManager.GetTopMostOpenMenuInfo(root and root.flowManager)
    local top = info and info.menu
    if not top or (menu and top ~= menu) or not states[top] then return end
    if root then
      local layer = LUI.UIRoot.GetActiveLayer(root)
      if layer and layer ~= top then return end
    end
    local state = states[top]
    local destination = core().step(state.locked or {}, state.selected, index)
    if destination == state.selected then return true end
    return switchWithDpad(top, event, destination)
  end)
  if not ok then report(switched) end
  return ok and switched == true
end

local function bindDpad(menu, tabs)
  local callbacks = menu.m_gamepadEventCallbackTable
  local function bind(button, index)
    if callbacks and callbacks[button] then return end
    menu:AddGamepadEventCallback(button, function(self, event)
      return dpadIndex(event) == index and tryDpad(event, index, self)
    end)
  end
  bind(dpadLeft, -1)
  bind(dpadRight, 1)
  tabs:RemoveGamepadEventCallback(dpadLeft)
  tabs:RemoveGamepadEventCallback(dpadRight)

  local rootClass = LUI.UIRoot
  local original = rootClass and rootClass.ProcessDirectionalInputEvent
  if directionalHooked or type(original) ~= "function" then return end
  -- The directional fast path can skip the picker when the weapon grid has focus.
  rawset(rootClass, "ProcessDirectionalInputEvent", function(root, event, ...)
    local index = dpadIndex(event)
    if index and tryDpad(event, index, nil, root) then return true end
    return original(root, event, ...)
  end)
  directionalHooked = true
end

local function syncTabs(menu, state)
  local signature = core().lockSignature(state.locked)
  if state.tabCount ~= #games() or state.lockSignature ~= signature then
    local entries = {}
    for index, game in ipairs(games()) do
      local chosen = index
      local icon = core().icon(index, state.locked[index])
      entries[index] = {
        tabIndex = index - 1, icon = assert(icon, "missing project icon"),
        _isVisible = true, tabNavigationDelayLength = 0,
        focusFunction = function() selectProject(menu, state, chosen) end,
      }
    end
    state.tabs:SetTabs(entries, { defaultTab = state.selected - 1 })
    state.tabs:ShowShoulderButtonPrompts()
    state.tabCount = #games()
    state.lockSignature = signature
  end
  highlight(state)
end

local function projectRows(menu, state, data, rows)
  local bo6Here = false
  for _, row in ipairs(rows) do
    if gameOf(row) == 2 and row.bundleData then bo6Here = true break end
  end
  if bo6Here then bo6Seen = true end
  -- BO6 guns come from Kronos' Carry Forward setting; its dvar decides. Some BO6 rows can appear even with it off, and
  -- selecting them crashed the game (2026-11-25), so rows only decide when the dvar can't be read.
  local carryForward = core().kronosCarryForward()
  local bo6 = bo6Seen
  if carryForward ~= nil then bo6 = carryForward end
  state.locked = core().lockStates("weapons", bo6)
  if state.locked[state.selected] then state.selected = 1 end
  state.syncing = true
  local ok, err = pcall(syncTabs, menu, state)
  state.syncing = false
  if not ok then error(err, 0) end
  state.rows, state.data = rows, data
  state.groups = groupRows(rows)
  state.view = state.groups[state.selected]
  setView(menu, data, state.view)
  return state.view
end

local function installHooks()
  local weapon, loadout = rawget(_G, "WEAPON"), rawget(_G, "LOADOUT")
  if type(weapon) ~= "table" or type(loadout) ~= "table" then return end
  if hooks and weapon[refreshKey] == hooks.refresh and loadout[publishKey] == hooks.publish then
    return hooks.originalPublish
  end
  if hooks then return hooks.originalPublish end
  local refresh, publish = weapon[refreshKey], loadout[publishKey]
  if type(refresh) ~= "function" or type(publish) ~= "function" then return end

  local function refreshPicker(menu, controller, ...)
    local state = states[menu]
    if not state or not eligible() then return refresh(menu, controller, ...) end
    local previous = active
    active = { menu = menu, state = state, controller = controller }
    local result = pack(pcall(refresh, menu, controller, ...))
    active = previous
    if not result[1] then error(result[2], 0) end
    return unpack(result, 2, result.n)
  end

  local function publishPicker(controller, rows, blueprints, ...)
    local scope = active
    -- Favorites publishes directly rather than through WEAPON.Refresh. Match
    -- the exact list/scoped-data identities, never an unrelated LOADOUT list.
    if not scope and type(rows) == "table" then
      for menu, state in pairs(states) do
        if state.controller == controller and not state.syncing and menu._currentWeapons == rows then
          local ok, data = pcall(LUI.FlowManager.GetScopedData, menu)
          if ok and data and data.filteredWeaponDataList == rows then
            scope = { menu = menu, state = state, controller = controller }
            break
          end
        end
      end
    end
    if scope and scope.controller == controller and type(rows) == "table" then
      local menu, state = scope.menu, scope.state
      if states[menu] == state and menu._currentWeapons == rows and not state.syncing then
        local scopeOK, data = pcall(LUI.FlowManager.GetScopedData, menu)
        if not scopeOK then
          disable(menu, state, data)
        elseif data and data.filteredWeaponDataList == rows and data.blueprintsByWeapon == blueprints then
          local ok, view = pcall(projectRows, menu, state, data, rows)
          if not ok then
            disable(menu, state, view)
          elseif view ~= rows then
            local result = pack(pcall(publish, controller, view, blueprints, ...))
            if not result[1] then
              setView(menu, data, rows)
              disable(menu, state, result[2])
              error(result[2], 0)
            end
            return unpack(result, 2, result.n)
          end
        end
      end
    end
    return publish(controller, rows, blueprints, ...)
  end

  rawset(weapon, refreshKey, refreshPicker)
  rawset(loadout, publishKey, publishPicker)
  hooks = { refresh = refreshPicker, publish = publishPicker, originalPublish = publish }
  return publish
end

local function attach(builder, menu)
  if not menu or states[menu] or menu._forShowcase or menu[stockTabsKey] or
      type(menu.AddProjectFilterTabs) ~= "function" then return end
  local publish = installHooks()
  local controller = menu._controllerIndex
  if not publish or type(controller) ~= "number" then return end

  local state = { selected = 1, controller = controller, publish = publish }
  local ok, err = pcall(function()
    local tabs = LUI.TabManager.new({
      tabHeight = 40, useDpad = true, spacing = 0, wrap = true, controllerIndex = controller,
      buildTab = function()
        return assert(rawget(_G, "MWCF_GAME_LOGOS_V1"), "CFU logo module missing").buildTile(builder, controller)
      end,
    })
    state.tabs = tabs
    core().trackNavigation(tabs, state)
    tabs.id = "CFUGameTabs"
    tabs:SetAnchorsAndPosition(0, 1, 0, 1, 90, 400, 77.5, 127.5)
    tabs:SetAlignment(LUI.Alignment.Center)
    tabs:SetSendEventOnTabChange(false)
    menu:addElement(tabs)
    bindDpad(menu, tabs)
    menu:addEventHandler(closeKey, function() states[menu] = nil end)
    states[menu] = state
    local data = LUI.FlowManager.GetScopedData(menu)
    local rows = menu._currentWeapons
    if type(rows) == "table" and data and data.filteredWeaponDataList == rows then
      local view = projectRows(menu, state, data, rows)
      if view ~= rows then
        local written, reason = pcall(publish, controller, view, data.blueprintsByWeapon)
        if not written then
          setView(menu, data, rows)
          pcall(publish, controller, rows, data.blueprintsByWeapon)
          error(reason, 0)
        end
      end
    end
  end)
  if not ok then disable(menu, state, err) end
end

local function hookBuilder(builder)
  if type(builder) ~= "table" or type(builder.BuildRegisteredType) ~= "function" then return end
  local build = builder.BuildRegisteredType
  builder.BuildRegisteredType = function(ref, ...)
    if (ref ~= pickerKey and ref ~= "WeaponBaseSelect" and ref ~= "weaponbaseselect") or
        not eligible() then return build(ref, ...) end
    local result = pack(build(ref, ...))
    local ok, err = pcall(attach, builder, result[1])
    if not ok then report(err) end
    return unpack(result, 1, result.n)
  end
end

local builder = rawget(_G, "MenuBuilder")
local lui = rawget(_G, "LUI")
hookBuilder(builder)
if type(lui) == "table" and lui.MenuBuilder ~= builder then hookBuilder(lui.MenuBuilder) end
rawset(_G, "MWCF_GAME_TABS_V1", true)

rawset(_G, "MWCF_GAME_TABS_API", { groupRows=groupRows, gameOf=gameOf, states=states })
