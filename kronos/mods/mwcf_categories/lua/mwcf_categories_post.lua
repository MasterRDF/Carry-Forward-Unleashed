-- Weapon select lists grouped by game: "Black Ops 7", "Black Ops 6", "Modern Warfare III", "Modern Warfare II"
-- instead of the stock "Seasonal" / "Progression" sections.
-- The stock list builder (WEAPON[651a6c4adce94d00]) adds a header row per section and hands the list to
-- LOADOUT[2a4a8b69a4073ac3](controller, list, blueprints); the menu keeps that same table. This wraps that one function and
-- rebuilds the list in place: same rows, same order inside each game, the stock header row copied with its text changed.
-- Anything that does not look like a weapon list (a header row plus rows whose bundleData has a weapon ref) is left alone.
do
  local GAMES = {
    { prefix = "sat_", label = "Black Ops 7" },
    { prefix = "t10_", label = "Black Ops 6" },
    { prefix = "jup_", label = "Modern Warfare III" },
    { prefix = "iw9_", label = "Modern Warfare II" },
  }
  local OTHER = "Other"
  local MARK = "__mwcfGameHeader"

  local function activate()
    local K = rawget(_G, "KRONOS")
    if type(K) ~= "table" or type(K.H) ~= "function" then return false end
    local S = rawget(_G, "__mwcfCategoriesV1")
    if type(S) == "table" and type(S.install) == "function" then S.install(); return true end
    local H = K.H
    S = {}
    rawset(_G, "__mwcfCategoriesV1", S)
    local function log(s) if type(K.log) == "function" then K.log("mwcf categories: " .. s) end end
    -- The stored hashes keep their top bit; both forms are tried so either spelling of a key works.
    local REF = { H("89e9c01960f4c582"), H("09e9c01960f4c582") }
    local LABEL = { H("b9f7fcec8fcb623d"), H("39f7fcec8fcb623d") }
    local LIST_FN = { "aa4a8b69a4073ac3", "2a4a8b69a4073ac3" }

    local function field(t, k)
      if t == nil then return nil end
      local ok, v = pcall(function() return t[k] end)
      if ok then return v end
      return nil
    end

    local function gameOf(ref)
      for i, g in ipairs(GAMES) do
        if ref:sub(1, #g.prefix) == g.prefix then return i end
      end
      return #GAMES + 1
    end

    local function regroup(list)
      if type(list) ~= "table" or #list < 2 then return false end
      local header, labelKey
      local buckets = {}
      for i = 1, #GAMES + 1 do buckets[i] = {} end
      for i = 1, #list do
        local row = list[i]
        if type(row) ~= "table" then return false end
        if rawget(row, MARK) then return false end  -- already grouped
        local bd = field(row, "bundleData")
        if bd == nil then
          local key
          for _, k in ipairs(LABEL) do
            if field(row, k) ~= nil then key = k; break end
          end
          if not key then return false end  -- a row that is neither a weapon nor a section header
          if not header then header, labelKey = row, key end
        else
          local ref = field(bd, REF[1])
          if ref == nil then ref = field(bd, REF[2]) end
          if ref == nil then return false end
          ref = tostring(ref)
          local b = buckets[gameOf(ref)]
          b[#b + 1] = row
        end
      end
      if not header then return false end
      for i = #list, 1, -1 do list[i] = nil end
      for i = 1, #GAMES + 1 do
        local rows = buckets[i]
        if #rows > 0 then
          local h = {}
          for k, v in pairs(header) do h[k] = v end
          setmetatable(h, getmetatable(header))
          h[labelKey] = GAMES[i] and GAMES[i].label or OTHER
          h[MARK] = true
          list[#list + 1] = h
          for _, row in ipairs(rows) do list[#list + 1] = row end
        end
      end
      return true
    end
    S.regroup = regroup

    function S.install()
      local LO = rawget(_G, "LOADOUT")
      if type(LO) ~= "table" then return end
      for _, hex in ipairs(LIST_FN) do
        local key = H(hex)
        local f = field(LO, key)
        if type(f) == "function" then
          if f == S.wrapped then return end
          local orig = f
          S.wrapped = function(a, list, ...)
            local ok, e = pcall(regroup, list)
            if not ok and not S.errLogged then
              S.errLogged = true
              log("left a list as it was: " .. tostring(e))
            elseif ok and e and not S.okLogged then
              S.okLogged = true
              log("weapon list grouped by game")
            end
            return orig(a, list, ...)
          end
          LO[key] = S.wrapped
          log("weapon select lists will be grouped by game")
          return
        end
      end
    end

    local unpack = unpack or table.unpack
    local function pack(...) return { n = select("#", ...), ... } end
    for _, key in ipairs({ "require", "requireUnlessHotload", "requirexhash" }) do
      local orig = rawget(_G, key)
      if type(orig) == "function" then
        rawset(_G, key, function(...)
          local r = pack(orig(...))
          pcall(S.install)
          return unpack(r, 1, r.n)
        end)
      end
    end
    pcall(S.install)
    return true
  end

  -- Mod post scripts can run before ui/LUIFPSCounter creates KRONOS.H: keep a bootstrap until it exists.
  if not activate() then
    if rawget(_G, "__mwcfCategoriesBootstrapV1") then return end
    local B = { ready = false }
    rawset(_G, "__mwcfCategoriesBootstrapV1", B)
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
