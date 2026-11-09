-- MW Carry Forward - Mystery Box 1.5.0: which games' guns the Mystery Box gives.
-- Zombies > Weapons gets a fifth button, MYSTERY BOX, after Firing Range. It opens a menu with four checkboxes (Black Ops 7,
-- Black Ops 6, Modern Warfare III, Modern Warfare II); at least one stays checked. The choice is the dvar mwcf_box_pools
-- (1 BO7 + 2 BO6 + 4 MW3 + 8 MW2, all four by default), kept with seta and put into every Zombies launch's settings, since
-- Kronos carries launch settings into the match. The mod script rolls every spin over the checked games' guns.
-- The Weapons row is the game's own list: WEAPON[2e5272f250111d6e] fills _DataSources.MP.WEAPONS.CAC.WEAPONS_TAB's entries
-- (label, command, flag, text, id, tab) and sets its count; this wraps it and adds one entry after Firing Range.
-- The menu is the stock Zombies Map Selection screen with its list taken out and stock buttons put in (as Rogue Re-Run does).
-- 1.5.0 removes the old Debug Options "MW2 Mystery Box" row.
do
  local function activate()
    local K = rawget(_G, "KRONOS")
    if type(K) ~= "table" or type(K.H) ~= "function" then return false end
    local previous = rawget(_G, "__mwcfBoxV2")
    if type(previous) == "table" and type(previous.install) == "function" then previous.install(); return true end
    local H = K.H
    local S = {}
    rawset(_G, "__mwcfBoxV2", S)
    local unpack = unpack or table.unpack
    local function pack(...) return { n = select("#", ...), ... } end
    local function log(s) if type(K.log) == "function" then pcall(K.log, "mwcf box: " .. tostring(s)) end end
    local function X(name)
      local C = rawget(_G, "CLUA")
      if type(C) == "table" and type(C.PushXHash) == "function" then return C.PushXHash(name) end
      return name
    end
    local function same(a, b) return a == b or tostring(a) == tostring(b) end
    local function get(v, k)
      local ok, x = pcall(function() return v[k] end)
      if ok then return x end
    end
    local function hasMethod(v, name) return type(get(v, name)) == "function" end
    -- Stored hashes may keep their top bit: try both spellings of a key.
    local function alt(hex) return string.format("%x", (tonumber(hex:sub(1, 1), 16) + 8) % 16) .. hex:sub(2) end
    local function fld(t, hex)
      local v = get(t, H(hex))
      if v ~= nil then return v end
      return get(t, H(alt(hex)))
    end
    local function ctrl()
      local ok, c = pcall(function() return K.ctrl and K.ctrl() end)
      return (ok and type(c) == "number") and c or 0
    end
    local function exec(cmd, c)
      local f = get(rawget(_G, "Engine"), H("eb81a5136c5503e4"))
      if type(f) ~= "function" then log("exec unavailable: " .. cmd); return false end
      local ok, e = pcall(f, cmd, c or ctrl())
      if not ok then log("exec " .. cmd .. " failed: " .. tostring(e)) end
      return ok
    end

    -- The pools.
    local POOLS_DV, BOX_DV, MODE_DV = "7a69d9551939e7a5", "4d9298260a67304f", "ccd6e9c45368c605"
    local ALL = 15
    local GAMES = {
      { bit = 1, label = "BLACK OPS 7" }, { bit = 2, label = "BLACK OPS 6" },
      { bit = 4, label = "MODERN WARFARE III" }, { bit = 8, label = "MODERN WARFARE II" },
    }
    local function valid(v) return type(v) == "number" and v == math.floor(v) and v >= 1 and v <= ALL end
    local function has(v, b) return math.floor(v / b) % 2 == 1 end
    local function read(hex)
      local ok, v = pcall(K.dvar, hex)
      return ok and tonumber(v) or nil
    end
    local function pools()
      if valid(S.pools) then return S.pools end
      local v = read(POOLS_DV)
      if valid(v) then return v end
      return ALL
    end
    local function setPools(v)
      if not valid(v) then return false end
      S.pools = v
      pcall(function() Dvar[H("1e3cb005036e0c0f")](H(POOLS_DV, 1), tostring(v)) end)
      exec("seta mwcf_box_pools " .. v)
      log("box pools now " .. v)
      return true
    end
    S.pools_value = pools
    S.set_pools = setPools
    -- A checkbox press: flips one game; the last checked game stays on. Returns the pools after it.
    local function toggle(bit)
      local v = pools()
      local nv = has(v, bit) and (v - bit) or (v + bit)
      if nv == 0 then log("the last checked game stays on"); return v end
      setPools(nv)
      return nv
    end
    S.toggle = toggle
    local function stockMode()
      local v = read(BOX_DV)
      return (v and v == math.floor(v) and v >= 0 and v <= 2) and v or 0
    end

    -- Every Zombies launch carries the pools (and the stock dropdown's value, as before).
    local function patchLaunch()
      local start = rawget(_G, "LUMEN_ZM_LOCAL_START")
      local req = type(start) == "table" and start.request
      if type(req) ~= "table" or type(req.record) ~= "table" then return end
      local v, stock = pools(), stockMode()
      if req.mwcfBoxPools == v and req.mwcfStockBoxMode == stock then return end
      local record, config = {}, {}
      for k, x in pairs(req.record) do record[k] = x end
      for _, entry in ipairs(req.record.configuration or {}) do
        if type(entry) ~= "table" or (entry.key ~= "0x" .. POOLS_DV and entry.key ~= "0x" .. BOX_DV and entry.key ~= "0x" .. MODE_DV) then
          config[#config + 1] = entry
        end
      end
      config[#config + 1] = { key = "0x" .. POOLS_DV, console_key = "#x3" .. POOLS_DV, kind = "string", value = tostring(v),
        consumer_default = tostring(ALL), required = false }
      config[#config + 1] = { key = "0x" .. BOX_DV, console_key = "#x3" .. BOX_DV, kind = "string", value = tostring(stock),
        consumer_default = "0", required = false }
      record.configuration = config
      req.record = record
      req.mwcfBoxPools = v
      req.mwcfStockBoxMode = stock
    end

    -- The menu.
    local MENU = "MwcfBoxPools"
    local MAP_SELECTION = "0xb87e923e71d969f0"
    local BUTTON = "3246871af1e086b7"
    local TITLE = "MYSTERY BOX"
    local DESC = "Choose which games' guns the Mystery Box can give. Every gun in the checked games is equally likely. At least one game stays checked."
    local function children(el)
      local out = {}
      local ok, c = pcall(function() return el:getFirstChild() end)
      while ok and c ~= nil and #out < 200 do
        out[#out + 1] = c
        local cur = c
        ok, c = pcall(function() return cur:getNextSibling() end)
      end
      return out
    end
    local function findElement(root, test, depth)
      depth = depth or 1
      if depth > 3 then return end
      for _, ch in ipairs(children(root)) do
        local ok, hit = pcall(test, ch)
        if ok and hit then return ch end
      end
      for _, ch in ipairs(children(root)) do
        local found = findElement(ch, test, depth + 1)
        if found then return found end
      end
    end
    local function isGrid(v)
      return type(get(v, "SetGridDataSource")) == "function" or type(get(v, X("SetGridDataSource"))) == "function"
        or type(get(v, H("a2e75a327dce993a"))) == "function"
    end
    local function containsGrid(el, depth)
      depth = depth or 1
      if depth > 3 then return false end
      for _, ch in ipairs(children(el)) do
        if isGrid(ch) or containsGrid(ch, depth + 1) then return true end
      end
      return false
    end
    local function checkLabel(g, v) return (has(v, g.bit) and "[X]  " or "[  ]  ") .. g.label end
    -- The game's own checkbox widget (GenericCheckBox, the one MenuButtonCheckBox puts on its right edge): SetValue(bool) shows or
    -- hides its check mark, SetCallback(fn) is told when it changes.
    local CHECKBOX, CHECKBOX_MODULE = "7219bab9383a0257", "3e7f0b6265df88ba"
    local function buildCheckbox(c)
      local RU = rawget(_G, "requireUnlessHotload")
      if type(RU) == "function" then
        pcall(RU, H(CHECKBOX_MODULE, 3), H(CHECKBOX))
        pcall(RU, H(alt(CHECKBOX_MODULE), 3), H(alt(CHECKBOX)))
      end
      for _, hex in ipairs({ CHECKBOX, alt(CHECKBOX) }) do
        local ok, cb = pcall(MenuBuilder.BuildRegisteredType, H(hex), { controllerIndex = c })
        if ok and cb ~= nil and type(get(cb, "SetValue")) == "function" then return cb end
      end
    end

    -- The screen's "MAP SELECTION" heading reads "MYSTERY BOX LOADOUT" on our copy: the engine's localize functions (as Rogue
    -- Re-Run wraps them) answer that text differently while our copy is being built or is open, and text elements already
    -- holding it get the new text. Any other Map Selection screen (the real one, Rogue Re-Run's) turns this off again.
    local TITLE_FROM, TITLE_TO = "map selection", "Mystery Box Loadout"
    local function retitle(v)
      if type(v) ~= "string" or #v > 40 then return v end
      local plain = v:gsub("%^.", ""):gsub("^%s+", ""):gsub("%s+$", "")
      if plain:lower() ~= TITLE_FROM then return v end
      return plain == plain:upper() and TITLE_TO:upper() or TITLE_TO
    end
    local localizeWraps = {}
    local function hookLocalize()
      local E = rawget(_G, "Engine")
      if type(E) ~= "table" then return end
      for _, name in ipairs({ "Localize", "07d3158a9539a355", "aed84c33ec5f01ea" }) do
        local keys = name == "Localize" and { name, X(name) } or { H(name), H(alt(name)) }
        for _, k in ipairs(keys) do
          local f = get(E, k)
          if type(f) == "function" and not localizeWraps[f] then
            local wrapped = function(...)
              local r = pack(f(...))
              if (S.building or S.inMenu) and r.n >= 1 then r[1] = retitle(r[1]) end
              return unpack(r, 1, r.n)
            end
            if pcall(function() E[k] = wrapped end) and E[k] == wrapped then localizeWraps[wrapped] = true end
          end
        end
      end
    end
    local function retitleTree(root, depth, seen)
      depth = depth or 1
      seen = seen or {}
      if depth > 6 then return end
      for _, ch in ipairs(children(root)) do
        local gt = get(ch, "getText")
        local st = get(ch, "setText")
        if type(st) == "function" then
          if type(gt) == "function" then
            local ok, t = pcall(gt, ch)
            if ok and type(t) == "string" then
              if #seen < 24 then seen[#seen + 1] = tostring(get(ch, "id")) .. "=" .. t end
              local nt = retitle(t)
              if nt ~= t then
                -- The heading: the screen sets it again later with a localized text id, so this element keeps ours.
                pcall(st, ch, nt)
                for _, k in ipairs({ "setText", "SetText" }) do
                  local f = get(ch, k)
                  if type(f) == "function" then pcall(function() ch[k] = function(self) return f(self, nt) end end) end
                end
                S.titled = (S.titled or 0) + 1
              end
            end
          end
        end
        retitleTree(ch, depth + 1, seen)
      end
      return seen
    end

    local function fill(menu, c)
      local list
      for _, ch in ipairs(children(menu)) do
        local id = get(ch, "id")
        if same(id, "ZMMaplist") or same(id, X("ZMMaplist")) or same(id, H("bb75dab396330882")) or isGrid(ch) or containsGrid(ch) then list = ch; break end
      end
      if list then
        pcall(function() list:SetAlpha(0); list:SetVisible(false) end)
        pcall(function() list:closeTree() end)
      end
      local panel = findElement(menu, function(v) return get(v, H("4caca94f968abe27")) ~= nil end)
      if panel then
        pcall(function() panel[H("3a506cb501761960")][H("c4bcadba8e631b86")]:setText(TITLE) end)
        pcall(function() panel[H("4caca94f968abe27")]:setText(DESC) end)
      end
      -- The heading element (id 28c70c243b5750d0 in the stock screen) keeps our text, whatever the screen sets it to later.
      local heading = nil
      local function findById(root, depth)
        if depth > 8 then return end
        for _, ch in ipairs(children(root)) do
          local id = get(ch, "id")
          if same(id, H("28c70c243b5750d0")) or same(id, H(alt("28c70c243b5750d0"))) then return ch end
          local f = findById(ch, depth + 1)
          if f then return f end
        end
      end
      pcall(function() heading = findById(menu, 1) end)
      if heading then
        local headingText = TITLE_TO:upper()
        for _, k in ipairs({ "setText", "SetText" }) do
          local f = get(heading, k)
          if type(f) == "function" then
            pcall(f, heading, headingText)
            pcall(function() heading[k] = function(self) return f(self, headingText) end end)
          end
        end
        S.titled = (S.titled or 0) + 1
      end
      local okT, seen = pcall(retitleTree, menu)
      if okT and seen and not S.textsLogged then S.textsLogged = true; log("pools menu heading replaced: " .. tostring(S.titled or 0) .. ", found by id: " .. tostring(heading ~= nil)) end
      local req = rawget(_G, "requirexhash")
      if type(req) == "function" then pcall(req, H(BUTTON)) end
      local EBU = rawget(_G, "ElementAndButtonUtils")
      local link, dirs
      pcall(function() link = EBU[H("042b31d442266478c")]; dirs = EBU[H("075992a095c731b0c")] end)
      local prev, first, built, checkboxes = nil, nil, 0, 0
      for i, g in ipairs(GAMES) do
        local okb, eb = pcall(function()
          local btn = MenuBuilder.BuildRegisteredType(H(BUTTON), { controllerIndex = c })
          local y = 192 + (i - 1) * 72
          btn:SetAnchorsAndPosition(0, 1, 0, 1, 87, 511, y, y + 64)
          -- A game checkbox on the button's right edge, vertically centred; the label is then just the game.
          local cb = buildCheckbox(c)
          if cb then
            local okP = pcall(function()
              -- Its native 28x28: the border and fill stretch, but the check image is a fixed 28 wide, so any other size moves it.
              cb:SetAnchorsAndPosition(1, 0, 0.5, 0.5, -56, -28, -14, 14)
              btn:addElement(cb)
            end)
            -- The row shows the hover; the checkbox's own hover outline (a little off at this size) and clicks are switched off,
            -- so clicks land on the row.
            for _, m in ipairs({ "SetHandleMouse", "setHandleMouse", "SetHandleMouseButton", "setHandleMouseButton" }) do
              local f = get(cb, m)
              if type(f) == "function" then pcall(f, cb, false) end
            end
            for _, ev in ipairs({ "42a38db44454a06f", "51573f49a6333a48", "3872fd384b8e9347", "b0a3c7cac3e03af5" }) do
              pcall(function() cb:registerEventHandler(H(ev), function() return true end) end)
            end
            if not okP then cb = nil end
          end
          local function text() return cb and g.label or checkLabel(g, pools()) end
          local labels = {}
          for _, k in ipairs({ "39f7fcec8fcb623d", "69f6cc5b1a5cbb83" }) do
            local el = get(btn, H(k))
            local set = el and get(el, "setText")
            if type(set) == "function" then
              labels[#labels + 1] = { el = el, set = set }
              pcall(set, el, text())
              pcall(function() el.setText = function() end end)  -- the button's own updates would put the stock text back
            end
          end
          local syncing = false
          local function refresh()
            for _, l in ipairs(labels) do pcall(l.set, l.el, text()) end
            if cb then syncing = true; pcall(cb.SetValue, cb, has(pools(), g.bit)); syncing = false end
          end
          if cb then
            -- A click that lands on the checkbox itself: apply it the same way, then show the result.
            pcall(cb.SetCallback, cb, function(_, v)
              if syncing then return end
              if (v and true or false) ~= has(pools(), g.bit) then toggle(g.bit) end
              refresh()
            end)
            refresh()
          end
          for _, m in ipairs({ "SetHandleMouse", "setHandleMouse", "SetHandleMouseButton", "setHandleMouseButton" }) do
            local f = get(btn, m)
            if type(f) == "function" then pcall(f, btn, true) end
          end
          local lastFire = -1
          local function fire()
            local clk = (type(os) == "table" and os.clock) and os.clock() or nil
            if clk then if clk - lastFire < 0.4 then return end; lastFire = clk end
            toggle(g.bit)
            refresh()
          end
          for _, how in ipairs({ "addEventHandler", "registerEventHandler" }) do
            if hasMethod(btn, how) then pcall(btn[how], btn, H("e7eefe998522ec88"), function() fire() end) end
          end
          menu:addElement(btn)
          if prev and link and dirs then
            pcall(link, prev, btn, dirs[H("dc04126761bb7455")])
            pcall(link, btn, prev, dirs[H("08c43a07b566d980")])
          end
          prev = btn
          first = first or btn
          built = built + 1
          if cb then checkboxes = checkboxes + 1 end
        end)
        if not okb then log("checkbox failed for " .. g.label .. ": " .. tostring(eb)) end
      end
      if first then pcall(function() menu:SetDefaultFocusToElement(first) end) end
      log("pools menu: " .. built .. " games, " .. checkboxes .. " game checkboxes, pools " .. pools())
      return built > 0
    end

    local function poolsMenu(_, data)
      local c = (data and data.controllerIndex) or ctrl()
      local MB = rawget(_G, "MenuBuilder")
      pcall(hookLocalize)
      S.building = true
      local ok, m = pcall(MB.BuildRegisteredType, X(MAP_SELECTION), data or { controllerIndex = c })
      S.building = false
      S.inMenu = ok and m ~= nil
      if not ok or not m then log("menu frame failed: " .. tostring(m)); return nil end
      pcall(function() m.id = X(MENU) end)
      -- Leaving our copy ends the new heading (the real Map Selection keeps its own).
      for _, k in ipairs({ "close", "closeTree" }) do
        local f = get(m, k)
        if type(f) == "function" then pcall(function() m[k] = function(self, ...) S.inMenu = false; return f(self, ...) end end) end
      end
      local okF, eF = pcall(fill, m, c)
      if not okF then log("menu fill failed: " .. tostring(eF)) end
      return m
    end
    local registered = setmetatable({}, { __mode = "k" })
    local function registerMenu()
      local MB = rawget(_G, "MenuBuilder")
      if type(MB) ~= "table" or type(MB.registerType) ~= "function" or registered[MB] then return end
      local ok, e = pcall(MB.registerType, X(MENU), poolsMenu)
      registered[MB] = ok
      if not ok then log("menu registration failed: " .. tostring(e)) end
    end
    local function openPools(c)
      registerMenu()
      exec("luiOpenMenu " .. MENU, type(c) == "number" and c or ctrl())
    end
    S.open = openPools

    -- 1.5.9: the Zombies Confirm Loadout screen (ZMLoadoutConfirmation, before a match) gets a MYSTERY BOX LOADOUT button under
    -- EDIT AUGMENTS that opens the same menu. Its buttons are found by their text once the screen is built; the new one copies
    -- EDIT AUGMENTS's anchors and sits one row lower (the EDIT LOADOUT -> EDIT AUGMENTS step).
    local CONFIRM, CONFIRM_HASH = "ZMLoadoutConfirmation", "51330ed90c8b545d"
    local LABEL_KEYS = { "39f7fcec8fcb623d", "69f6cc5b1a5cbb83" }
    S.confirmDone = S.confirmDone or setmetatable({}, { __mode = "k" })
    local function textOf(el)
      local gt = get(el, "getText")
      if type(gt) ~= "function" then return nil end
      local ok, t = pcall(gt, el)
      if ok and type(t) == "string" then return t:gsub("%^.", ""):upper() end
    end
    local function findTexts(root, out, depth)
      depth = depth or 1
      if depth > 9 then return out end
      for _, ch in ipairs(children(root)) do
        local t = textOf(ch)
        if t and #t > 0 then out[#out + 1] = { el = ch, text = t } end
        findTexts(ch, out, depth + 1)
      end
      return out
    end
    -- The button that holds a text element: the nearest ancestor whose label field is that element, else its parent.
    local function buttonOf(textEl)
      local cur = textEl
      for _ = 1, 5 do
        local okP, p = pcall(function() return cur:getParent() end)
        if not okP or p == nil then break end
        for _, k in ipairs(LABEL_KEYS) do
          if get(p, H(k)) == textEl or get(p, H(alt(k))) == textEl then return p end
        end
        cur = p
      end
      local okP, p = pcall(function() return textEl:getParent() end)
      return okP and p or nil
    end
    -- An element's place in its parent as SetAnchorsAndPosition's eight values: from GetAnchorsAndPosition when it gives eight
    -- numbers, else (1.5.12; the 1.5.11 game log: not found) from getLocalRect's left, top, right, bottom, anchored to the parent's
    -- top left the way the pools menu places its rows (0, 1, 0, 1). what says what each call gave, for the log.
    local function anchors(el, what)
      local f = get(el, "GetAnchorsAndPosition")
      if type(f) == "function" then
        local r = pack(pcall(f, el))
        local types = {}
        for i = 2, math.min(r.n, 10) do types[#types + 1] = type(r[i]) == "number" and tostring(r[i]) or type(r[i]) end
        if what then what[#what + 1] = "GetAnchorsAndPosition " .. tostring(r[1]) .. " (" .. table.concat(types, ",") .. ")" end
        if r[1] and r.n >= 9 then
          local v, ok = {}, true
          for i = 2, 9 do if type(r[i]) ~= "number" then ok = false end; v[#v + 1] = r[i] end
          if ok then return v end
        end
        if r[1] and type(r[2]) == "table" then
          local t, v = r[2], {}
          for i = 1, 8 do v[i] = t[i] end
          if type(v[8]) == "number" then return v end
        end
      elseif what then
        what[#what + 1] = "no GetAnchorsAndPosition"
      end
      local g = get(el, "getLocalRect")
      if type(g) == "function" then
        local r = pack(pcall(g, el))
        if what then what[#what + 1] = "getLocalRect " .. tostring(r[1]) .. " (" .. tostring(r[2]) .. "," .. tostring(r[3]) .. "," .. tostring(r[4]) .. "," .. tostring(r[5]) .. ")" end
        if r[1] and type(r[2]) == "number" and type(r[3]) == "number" and type(r[4]) == "number" and type(r[5]) == "number" then
          return { 0, 1, 0, 1, r[2], r[4], r[3], r[5] }
        end
      elseif what then
        what[#what + 1] = "no getLocalRect"
      end
      return nil
    end
    -- Position-related method names an element has (for the log when its position cannot be read).
    local function placeMethods(el)
      local out, seen = {}, {}
      local okM, mt = pcall(getmetatable, el)
      local depth = 0
      while okM and type(mt) == "table" and depth < 6 do
        local idx = rawget(mt, "__index")
        if type(idx) ~= "table" then break end
        for k, v in pairs(idx) do
          if type(k) == "string" and type(v) == "function" and not seen[k] then
            local l = k:lower()
            if l:find("rect") or l:find("anchor") or l:find("pos") or l:find("top") or l:find("left") or l:find("height") or l:find("width") then
              seen[k] = true; out[#out + 1] = k
            end
          end
        end
        okM, mt = pcall(getmetatable, idx)
        depth = depth + 1
      end
      table.sort(out)
      return table.concat(out, ",")
    end
    local function addConfirmButton(menu, data)
      if menu == nil or S.confirmDone[menu] then return end
      local texts = findTexts(menu, {})
      local aug, load, ready
      for _, t in ipairs(texts) do
        if not aug and t.text:find("AUGMENT", 1, true) then aug = t end
        if not load and t.text:find("EDIT LOADOUT", 1, true) then load = t end
        if not ready and t.text:find("READY", 1, true) then ready = t end
      end
      if not aug then
        -- 1.5.11: the texts may be filled in after the screen is built; later UI builds try again.
        if S.confirmRetry ~= menu then
          local seen = {}
          for i = 1, math.min(#texts, 12) do seen[#seen + 1] = texts[i].text end
          log("confirm loadout: no EDIT AUGMENTS text yet (" .. #texts .. " texts: " .. table.concat(seen, " | ") .. "); trying again on later UI builds")
        end
        S.confirmRetry = menu
        S.confirmRetries = (S.confirmRetries or 0) + 1
        return
      end
      S.confirmRetry = nil
      S.confirmDone[menu] = true
      local augBtn, loadBtn, readyBtn = buttonOf(aug.el), load and buttonOf(load.el), ready and buttonOf(ready.el)
      local parent = augBtn and get(augBtn, "getParent") and augBtn:getParent()
      local what = {}
      local a, b = augBtn and anchors(augBtn, what), loadBtn and anchors(loadBtn)
      if not (augBtn and parent and a) then
        log("confirm loadout: EDIT AUGMENTS button or its position not found (button " .. tostring(augBtn ~= nil) .. ", parent " ..
          tostring(parent ~= nil) .. "; " .. table.concat(what, "; ") .. "; methods: " .. (augBtn and placeMethods(augBtn) or "-") .. ")")
        return
      end
      local step = (b and a[7] - b[7] ~= 0) and (a[7] - b[7]) or (a[8] - a[7]) + 8
      local c = (type(data) == "table" and data.controllerIndex) or ctrl()
      local req = rawget(_G, "requirexhash")
      if type(req) == "function" then pcall(req, H(BUTTON)) end
      local okB, btn = pcall(MenuBuilder.BuildRegisteredType, H(BUTTON), { controllerIndex = c })
      if not okB or btn == nil then log("confirm loadout: button failed: " .. tostring(btn)); return end
      pcall(function() btn:SetAnchorsAndPosition(a[1], a[2], a[3], a[4], a[5], a[6], a[7] + step, a[8] + step) end)
      for _, k in ipairs(LABEL_KEYS) do
        local el = get(btn, H(k))
        local set = el and get(el, "setText")
        if type(set) == "function" then
          pcall(set, el, "MYSTERY BOX LOADOUT")
          pcall(function() el.setText = function() end end)
        end
      end
      for _, m in ipairs({ "SetHandleMouse", "setHandleMouse", "SetHandleMouseButton", "setHandleMouseButton" }) do
        local fm = get(btn, m)
        if type(fm) == "function" then pcall(fm, btn, true) end
      end
      local lastFire = -1
      local function fire()
        local clk = (type(os) == "table" and os.clock) and os.clock() or nil
        if clk then if clk - lastFire < 0.4 then return end; lastFire = clk end
        log("confirm loadout: MYSTERY BOX LOADOUT pressed")
        openPools(c)
      end
      for _, how in ipairs({ "addEventHandler", "registerEventHandler" }) do
        if hasMethod(btn, how) then pcall(btn[how], btn, H("e7eefe998522ec88"), function() fire() end) end
      end
      local okA, eA = pcall(function() parent:addElement(btn) end)
      if not okA then log("confirm loadout: could not add the button: " .. tostring(eA)); return end
      local EBU = rawget(_G, "ElementAndButtonUtils")
      local link, dirs
      pcall(function() link = EBU[H("042b31d442266478c")]; dirs = EBU[H("075992a095c731b0c")] end)
      if link and dirs then
        local down, up = dirs[H("dc04126761bb7455")], dirs[H("08c43a07b566d980")]
        pcall(link, augBtn, btn, down)
        pcall(link, btn, augBtn, up)
        if readyBtn then
          pcall(link, btn, readyBtn, down)
          pcall(link, readyBtn, btn, up)
        end
      end
      log(string.format("confirm loadout: MYSTERY BOX LOADOUT added under EDIT AUGMENTS (anchors %s, step %s, ready up %s)",
        table.concat(a, ","), tostring(step), tostring(readyBtn ~= nil)))
    end
    S.addConfirmButton = addConfirmButton

    -- The Weapons row.
    local TAB_FN = "2e5272f250111d6e"
    local KEY = { mp = "08a94a07b5502cf8", weapons = "41cbd901b87fabb6", cac = "75e2f4190ce482de", tab = "0b4a26ecab469bf2",
      list = "186b37e486024e3b", count = "31e5e28e4479a274", label = "39f7fcec8fcb623d", command = "66655dca2c3e8a12",
      flag = "44b612ba739b38f0", text = "348f78c62cab376f", auto = "488ca93aa60dc466", tabid = "381409384b3e1327" }
    local function command()
      if S.command then return S.command end
      local LUIc = rawget(_G, "LUI")
      local new = get(get(LUIc, "Command"), "new")
      if type(new) ~= "function" then return nil end
      local ok, cmd = pcall(new, function(c) openPools(c) end, function() return true end)
      if ok then S.command = cmd end
      return S.command
    end
    -- Model reads and writes take a controller index; the row function's own calls use its first argument for the entries and
    -- its second for the count. Try those, then whichever argument is a number, then the active controller.
    local function tries(first, a0, a1)
      local out, seen = {}, {}
      for _, v in ipairs({ first, type(a0) == "number" and a0 or false, type(a1) == "number" and a1 or false, ctrl() }) do
        if v ~= false and v ~= nil and not seen[v] then seen[v] = true; out[#out + 1] = v end
      end
      return out
    end
    local function getv(m, first, a0, a1)
      for _, c in ipairs(tries(first, a0, a1)) do
        local ok, v = pcall(m.GetValue, m, c)
        if ok and v ~= nil then return v end
      end
    end
    local function setv(m, first, a0, a1, v)
      for _, c in ipairs(tries(first, a0, a1)) do
        if pcall(m.SetValue, m, c, v) then return true end
      end
      return false
    end
    local function addButton(a0, a1)
      if not S.argsLogged then S.argsLogged = true; log("weapons row called with " .. type(a0) .. " " .. tostring(a0) .. ", " .. type(a1) .. " " .. tostring(a1)) end
      local GM = rawget(_G, "GameModesUtils")
      local isZm = fld(GM, "589367a5b3c4aa7f")
      if type(isZm) ~= "function" or not isZm() then return "not zombies" end
      local list = rawget(_G, "_DataSources")
      for _, k in ipairs({ "mp", "weapons", "cac", "tab", "list" }) do
        list = fld(list, KEY[k])
        if list == nil then return "no data source at " .. k end
      end
      local countModel = fld(list, KEY.count)
      if countModel == nil then return "no count" end
      local n = getv(countModel, a1, a0, a1)
      if type(n) ~= "number" or n < 1 or n > 8 then return "count " .. tostring(n) end
      local fire = get(get(get(rawget(_G, "LUI"), "Commands"), "Loadout"), "OpenFiringRange")
      local cmd, fireEntry = command(), nil
      if not cmd then return "no command" end
      for i = 1, n do
        local e = get(list, i)
        local m = e and fld(e, KEY.command)
        if m == nil then return "no command in entry " .. i end
        local c = getv(m, a0, a0, a1)
        if c == cmd then return "already there" end
        if fire ~= nil and c == fire then fireEntry = e end
      end
      if not fireEntry then return "no Firing Range entry among " .. n end
      local e = get(list, n + 1)
      if e == nil then return "no free entry " .. (n + 1) end
      local missing = {}
      local function set(k, v)
        local m = fld(e, KEY[k])
        if m == nil then missing[#missing + 1] = k; return end
        if not setv(m, a0, a0, a1, v) then missing[#missing + 1] = k .. "(write)" end
      end
      local tabModel = fld(fireEntry, KEY.tabid)
      set("label", TITLE)
      set("command", cmd)
      set("flag", false)
      set("text", "")
      set("auto", X("mwcf_box_pools_button"))
      set("tabid", tabModel and getv(tabModel, a0, a0, a1) or nil)
      for _, k in ipairs(missing) do
        if k:sub(1, 5) == "label" or k:sub(1, 7) == "command" then return "entry fields missing: " .. table.concat(missing, ",") end
      end
      if not setv(countModel, a1, a0, a1, n + 1) then return "count could not be written" end
      return "added as entry " .. (n + 1) .. (#missing > 0 and (" (missing " .. table.concat(missing, ",") .. ")") or "")
    end
    local function hookTab()
      local W = rawget(_G, "WEAPON")
      if type(W) ~= "table" then return end
      local cur = get(W, H(TAB_FN))
      if type(cur) ~= "function" or cur == S.tabWrapped then return end
      local orig = cur
      S.tabWrapped = function(a0, a1, ...)
        S.inMenu = false
        local r = pack(orig(a0, a1, ...))
        local ok, how = pcall(addButton, a0, a1)
        if how ~= S.lastHow then S.lastHow = how; log("weapons row: " .. (ok and tostring(how) or ("failed: " .. tostring(how)))) end
        return unpack(r, 1, r.n)
      end
      W[H(TAB_FN)] = S.tabWrapped
      log("weapons row wrapped")
    end

    local hooked, loading = {}, {}
    local busy = false
    local function install()
      if busy then return end
      busy = true
      local ok, err = pcall(function()
        registerMenu()
        hookTab()
        patchLaunch()
        local MB = rawget(_G, "MenuBuilder")
        if type(MB) == "table" and type(MB.BuildRegisteredType) == "function" and not hooked[MB] then
          hooked[MB] = true
          local orig = MB.BuildRegisteredType
          MB.BuildRegisteredType = function(name, ...)
            if not S.building and same(name, X(MAP_SELECTION)) then S.inMenu = false end
            pcall(hookTab); pcall(patchLaunch)
            local r = pack(orig(name, ...))
            pcall(patchLaunch)
            if r.n >= 1 and (same(name, X(CONFIRM)) or same(name, H(CONFIRM_HASH)) or same(name, H(alt(CONFIRM_HASH)))) then
              if not S.confirmSeenBuild then S.confirmSeenBuild = true; log("confirm loadout: screen built through MenuBuilder.BuildRegisteredType") end
              local okC, eC = pcall(addConfirmButton, r[1], (...))
              if not okC then log("confirm loadout: " .. tostring(eC)) end
            elseif S.confirmRetry ~= nil and (S.confirmRetries or 0) < 300 then
              local okC, eC = pcall(addConfirmButton, S.confirmRetry, nil)
              if not okC then S.confirmRetry = nil; log("confirm loadout: " .. tostring(eC)) end
            end
            return unpack(r, 1, r.n)
          end
        end
        -- 1.5.11: the screen's own builder, wrapped when the game registers it, in case the game builds the screen without going
        -- through MenuBuilder.BuildRegisteredType.
        if type(MB) == "table" and type(MB.registerType) == "function" and not hooked.registerType then
          hooked.registerType = true
          local origReg = MB.registerType
          MB.registerType = function(name, fn, ...)
            if type(fn) == "function" and (same(name, X(CONFIRM)) or same(name, H(CONFIRM_HASH)) or same(name, H(alt(CONFIRM_HASH)))) then
              local inner = fn
              fn = function(...)
                local r = pack(inner(...))
                if not S.confirmSeenType then S.confirmSeenType = true; log("confirm loadout: screen built through its registered builder") end
                local okC, eC = pcall(addConfirmButton, r[1], (select(2, ...)))
                if not okC then log("confirm loadout: " .. tostring(eC)) end
                return unpack(r, 1, r.n)
              end
              log("confirm loadout: screen type registered; its builder is wrapped")
            end
            return origReg(name, fn, ...)
          end
        end
        local P = rawget(_G, "Playlist")
        if type(P) == "table" and not hooked[P] then
          local key = rawget(P, "DoPlaylistId") and "DoPlaylistId" or X("DoPlaylistId")
          local orig = get(P, key)
          if type(orig) == "function" then
            hooked[P] = true
            P[key] = function(...) local r = pack(orig(...)); pcall(patchLaunch); return unpack(r, 1, r.n) end
          end
        end
      end)
      busy = false
      if not ok then log("install error: " .. tostring(err)) end
    end
    S.install = install
    -- Menus are opened by name through requirexhash; this one has no module.
    local rx = rawget(_G, "requirexhash")
    if type(rx) == "function" and not loading.requirexhash then
      loading.requirexhash = true
      rawset(_G, "requirexhash", function(h, ...)
        if same(h, X(MENU)) then registerMenu(); return true end
        local r = pack(rx(h, ...)); install(); return unpack(r, 1, r.n)
      end)
    end
    for _, key in ipairs({ "require", "requireUnlessHotload" }) do
      local orig = rawget(_G, key)
      if type(orig) == "function" and not loading[key] then
        loading[key] = true
        rawset(_G, key, function(...) local r = pack(orig(...)); install(); return unpack(r, 1, r.n) end)
      end
    end
    install()
    log("1.5.12 loaded, pools " .. pools())
    return true
  end
  -- Mod post scripts can run before ui/LUIFPSCounter creates KRONOS.H: keep a bootstrap until it exists.
  if not activate() then
    if rawget(_G, "__mwcfBoxBootstrapV2") then return end
    local B = { ready = false }
    rawset(_G, "__mwcfBoxBootstrapV2", B)
    local unpack = unpack or table.unpack
    local function pack(...) return { n = select("#", ...), ... } end
    for _, key in ipairs({ "require", "requireUnlessHotload", "requirexhash" }) do
      local orig = rawget(_G, key)
      if type(orig) == "function" then
        rawset(_G, key, function(...)
          local r = pack(orig(...))
          if not B.ready then B.ready = activate() end
          return unpack(r, 1, r.n)
        end)
      end
    end
  end
end
