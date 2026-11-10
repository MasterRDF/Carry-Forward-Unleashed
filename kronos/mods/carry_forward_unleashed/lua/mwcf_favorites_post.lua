-- Carry Forward Unleashed - Favorites 1.7 (fav-12).
-- Native class tabs + native roster eligibility; saved base refs in archived local string dvars.
-- LOADOUT publication stays owned by mwcf_categories_post.lua. Favorites lists explicitly retain type headers.
do
  local function activate()
    local K = rawget(_G, "KRONOS")
    if type(K) ~= "table" or type(K.H) ~= "function" then return false end
    local previous = rawget(_G, "__mwcfFavoritesV1")
    if type(previous) == "table" then previous.install(); return true end
    local H, unpack = K.H, unpack or table.unpack
    local S = { tabs = {}, nativeTabs = {}, grids = setmetatable({}, {__mode="k"}),
      menus = setmetatable({}, {__mode="k"}), cards = setmetatable({}, {__mode="k"}), wrapped = setmetatable({}, {__mode="k"}) }
    rawset(_G, "__mwcfFavoritesV1", S)
    local function pack(...) return {n=select("#", ...), ...} end
    local function log(text) if type(K.log) == "function" then pcall(K.log, "mwcf favorites 12: " .. tostring(text)) end end
    local function get(t, k)
      if t == nil then return nil end
      local ok, v = pcall(function() return t[k] end)
      if ok then return v end
    end
    local function alt(h) return string.format("%x", (tonumber(h:sub(1,1),16)+8)%16)..h:sub(2) end
    local function fld(t, h)
      local v = get(t, H(h))
      if v ~= nil then return v, H(h) end
      local k = H(alt(h)); return get(t, k), k
    end
    local function call(t, h, ...)
      local f = fld(t, h)
      if type(f) ~= "function" then error("missing API "..h) end
      return f(...)
    end
    local function value(m, c)
      local f = get(m, "GetValue")
      if type(f) == "function" then return f(m, c) end
    end
    local function set(m, c, v)
      local f = get(m, "SetValue")
      if type(f) == "function" then f(m, c, v); return true end
      return false
    end
    local function source()
      local n = rawget(_G, "_DataSources")
      for _, h in ipairs({"08a94a07b5502cf8", "41cbd901b87fabb6", "75e2f4190ce482de", "0c58f68f1b37dd22"}) do n = fld(n, h) end
      return n
    end
    local function same(a,b) return a == b or (a ~= nil and b ~= nil and tostring(a) == tostring(b)) end
    local function X(s)
      local f = get(rawget(_G, "CLUA"), "PushXHash")
      return type(f) == "function" and f(s) or s
    end
    -- An arbitrary, unique class ID. It never replaces a real weapon's class.
    local FAVORITES = H("5431e723ffe65709")
    S.class = FAVORITES
    local function selected(c) return value(fld(source(), "778b25789ce193d4"), c) end
    local function later(f)
      local nextFrame = get(rawget(_G,"Frame"), "Next")
      local q = get(nextFrame, "Queue")
      if type(q) == "function" then q(nextFrame, f) else f() end
    end
    local function valid(ref)
      return type(ref) == "string" and #ref <= 64 and ref:match("^[a-z][a-z0-9_]+$") ~= nil
        and (ref:sub(1,4)=="sat_" or ref:sub(1,4)=="t10_" or ref:sub(1,4)=="iw9_" or ref:sub(1,4)=="jup_")
        and ref ~= "sat_dm_tasman"
    end
    local function refOf(row) return fld(get(row,"bundleData"), "09e9c01960f4c582") end
    local function baseRef(row)
      local ref = refOf(row)
      return valid(ref) and ref or nil
    end

    -- fav-05: the shard dvars are created in the main menu by custom_scripts\mp_mwcf_favorites.gsc, which keeps them on disk in
    -- kronos\mwcf_favorites\favorites.json (as Kronos's own mp_bo6_store does for its BO6 picks): on load it gives each shard its
    -- saved text ("-" when empty), then saves every change within 0.5 s. Before fav-05 nothing created them (`seta` from Lua
    -- cannot), so every menu reload started empty. Until the dvars exist, changes stay in this menu session and nothing is written
    -- over the saved list; once they exist, the saved list loads and those changes are merged on top of it and written.
    -- Shards keep every value well under the engine's limits.
    local SHARDS, CHUNK, MAX = 16, 720, 256
    -- fav-06: the engine's own name hashes (ACTS @"mwcf_favorites_v1_NN"; mw2_guns_fixes.dll 22o makes the dvars with them),
    -- looked up the way Kronos's Lua reads its kronos_bo6_var: H(hex, 1), else xhashdvar(name). fav-05 used only
    -- CLUA.PushXHashDvar(name), which never found them (the DLL made and read all 16; the Lua stayed "not ready").
    local DVAR_HEX = { "f42fcd5b9ddd131b", "f42fce5b9ddd154e", "f42fcf5b9ddd1781", "f42fd05b9ddd19b4", "f42fd15b9ddd1be7",
      "f42fd25b9ddd1e1a", "f42fd35b9ddd204d", "f42fc45b9ddcff50", "f42fc55b9ddd0183", "f433d25b9de113f1", "f433d15b9de111be",
      "f433d05b9de10f8b", "f433cf5b9de10d58", "f433d65b9de11cbd", "f433d55b9de11a8a", "f433d45b9de11857" }
    local function dvarCandidates(i)
      S.dvarCands = S.dvarCands or {}
      if S.dvarCands[i] then return S.dvarCands[i] end
      local name = string.format("mwcf_favorites_v1_%02d",i)
      local list = {}
      local okH, kh = pcall(H, DVAR_HEX[i], 1)
      if okH and kh ~= nil then list[#list+1] = kh end
      local xd = rawget(_G, "xhashdvar")
      if type(xd) == "function" then local okX, kx = pcall(xd, name); if okX and kx ~= nil then list[#list+1] = kx end end
      local f = get(rawget(_G,"CLUA"), "PushXHashDvar")
      if type(f) == "function" then local okP, kp = pcall(f, name); if okP and kp ~= nil then list[#list+1] = kp end end
      S.dvarCands[i] = {name, list}
      return S.dvarCands[i]
    end
    -- {name, key}: the key that last read this shard, else the first candidate.
    local function dvarKey(i)
      local c = dvarCandidates(i)
      S.dvarKeyAt = S.dvarKeyAt or {}
      return {c[1], c[2][S.dvarKeyAt[i] or 1]}
    end
    -- nil until the store script has created every shard.
    local function readShards()
      local refs, chunks, n = {}, {}, 0
      for i=1,SHARDS do
        local v
        S.dvarKeyAt = S.dvarKeyAt or {}
        for k, key in ipairs(dvarCandidates(i)[2]) do
          local ok, x = pcall(call, rawget(_G,"Dvar"), "254084d7ca2317bb", key)
          if ok and type(x) == "string" and x ~= "" then v = x; S.dvarKeyAt[i] = k; break end
        end
        if not v then return nil end
        chunks[i] = v
        if #v <= CHUNK then
          for ref in v:gmatch("[^,]+") do
            if valid(ref) and not refs[ref] and n < MAX then refs[ref]=true; n=n+1 end
          end
        end
      end
      return refs, chunks
    end
    local function size(refs) local n = 0; for _ in pairs(refs) do n = n + 1 end; return n end
    local function writeShards(refs, c)
      local sorted, chunks = {}, {}
      for ref in pairs(refs) do if valid(ref) then sorted[#sorted+1]=ref end end
      table.sort(sorted)
      if #sorted > MAX then return false, "favorite limit reached" end
      local i, chunk = 1, ""
      for _,ref in ipairs(sorted) do
        local candidate = chunk=="" and ref or chunk..","..ref
        if #candidate > CHUNK then chunks[i]=chunk; i=i+1; chunk=ref else chunk=candidate end
      end
      chunks[i] = chunk=="" and "-" or chunk
      if i > SHARDS then return false, "favorite storage full" end
      S.chunks = S.chunks or {}
      for j=1,SHARDS do
        local text = chunks[j] or "-"
        if S.chunks[j] ~= text then
          local key = dvarKey(j)
          pcall(call, rawget(_G,"Dvar"), "1e3cb005036e0c0f", key[2], text)
          local okR, back = pcall(call, rawget(_G,"Dvar"), "254084d7ca2317bb", key[2])
          if not okR or back ~= text then
            -- Only validated lowercase base refs and commas can reach this command.
            pcall(call, rawget(_G,"Engine"), "eb81a5136c5503e4", 'set '..key[1]..' "'..text..'"', c or 0)
          end
          S.chunks[j] = text
        end
      end
      return true
    end
    local function saved()
      if S.saved and S.ready then return S.saved end
      local refs, chunks = readShards()
      if not refs then
        if not S.notReadyLogged then
          -- fav-07 diagnostic: what each key form returns for shard 1, and Kronos's own kronos_bo6_var as a control.
          pcall(function()
            local function show(label, key)
              local ok, x = pcall(call, rawget(_G,"Dvar"), "254084d7ca2317bb", key)
              log("diag "..label..": key "..type(key).." "..tostring(key)..", read "..tostring(ok).." "..type(x).." '"..tostring(x):sub(1,40).."'")
            end
            local c = dvarCandidates(1)
            for k, key in ipairs(c[2]) do show("shard1 candidate "..k, key) end
            local okH, kh = pcall(H, "9501b5803b01ae76", 1)
            if okH then show("control kronos_bo6_var H(hex,1)", kh) end
            local xd = rawget(_G, "xhashdvar")
            log("diag xhashdvar is "..type(xd))
            if type(xd) == "function" then
              local okX, kx = pcall(xd, "kronos_bo6_var")
              if okX then show("control kronos_bo6_var xhashdvar", kx) end
            end
          end)
          S.notReadyLogged = true
          log("storage not ready (mp_mwcf_favorites.gsc has not made its dvars yet); changes stay in this menu session until it has")
        end
        S.saved = S.saved or {}
        return S.saved
      end
      S.chunks, S.ready = chunks, true
      if S.saved and S.pending then
        -- Changes made before the store loaded go on top of the saved list.
        local n = size(refs)
        for ref in pairs(S.saved) do if not refs[ref] and n < MAX then refs[ref]=true; n=n+1 end end
        for ref in pairs(S.removed or {}) do refs[ref] = nil end
        S.pending, S.removed = nil, nil
        S.saved = refs
        local ok, err = writeShards(refs, 0)
        if not ok then log("merge write failed: "..tostring(err)) end
      else
        S.saved = refs
      end
      log("loaded "..size(S.saved).." saved favorites")
      return S.saved
    end
    local function persist(refs, c)
      if size(refs) > MAX then return false, "favorite limit reached" end
      if not S.ready then saved() end
      if not S.ready then
        S.removed = S.removed or {}
        for ref in pairs(S.saved or {}) do if not refs[ref] then S.removed[ref] = true end end
        for ref in pairs(refs) do S.removed[ref] = nil end
        S.saved, S.pending = refs, true
        return true
      end
      local ok, err = writeShards(refs, c)
      if not ok then return false, err end
      S.saved = refs
      return true
    end
    S.savedRefs = saved
    S.persist = persist

    -- Exact stock WEAPON roster helper (prototypes 933-935 of the installed BO7 frontend).
    -- Root has zero upvalues. Its children retain the stock filters, unlock checks and enum callback.
    -- Header keeps the original debug flag, since these records include their debug blocks.
    local ROSTER_BYTECODE = "\27\76\74\132\24\242\6\0\1\11\15\11\0\148\1\148\1\153\125\63\40\1\0\0\59\1\1\0\14\0\0\0\91\2\2\128\44\2\1\0\79\2\2\0\40\2\1\0\59\2\2\0\15\0\2\0\91\3\3\128\42\3\0\0\3\2\3\0\91\3\2\128\44\3\1\0\79\3\2\0\40\3\2\0\59\3\3\0\14\0\3\0\91\4\4\128\40\3\3\0\59\3\3\0\14\0\3\0\91\3\2\128\44\3\1\0\79\3\2\0\46\3\0\0\15\0\3\0\91\4\9\128\46\3\0\0\40\4\4\0\40\5\3\0\59\5\5\0\38\4\5\4\4\3\4\0\91\3\2\128\44\3\1\0\79\3\2\0\46\3\1\0\40\5\5\0\59\5\5\0\69\3\2\2\14\0\3\0\91\3\14\128\46\3\2\0\40\5\6\0\40\6\5\0\59\6\6\0\38\5\6\5\69\3\2\2\15\0\3\0\91\4\6\128\40\4\7\0\59\4\4\3\14\0\4\0\91\4\2\128\44\4\1\0\79\4\2\0\40\3\8\0\59\3\3\0\14\0\3\0\91\4\3\128\46\3\3\0\18\5\1\0\69\3\2\2\46\4\4\0\59\4\3\4\15\0\4\0\91\5\2\128\44\4\1\0\79\4\2\0\46\4\5\0\18\6\3\0\69\4\2\2\15\0\4\0\91\5\2\128\44\4\1\0\79\4\2\0\46\4\6\0\46\6\7\0\46\7\8\0\18\8\1\0\69\4\4\2\14\0\4\0\91\5\6\128\40\5\9\0\59\5\5\0\15\0\5\0\91\6\2\128\44\5\1\0\79\5\2\0\46\5\9\0\15\0\5\0\91\6\4\128\46\5\9\0\60\5\10\5\14\0\5\0\91\6\1\128\44\5\0\0\4\1\5\0\91\5\2\128\44\5\1\0\91\6\1\128\44\5\2\0\15\0\5\0\91\6\2\128\44\6\2\0\79\6\2\0\12\6\4\0\91\6\2\128\46\6\10\0\19\6\6\0\14\0\6\0\91\7\16\128\46\7\11\0\15\0\7\0\91\8\4\128\46\7\11\0\59\7\1\7\11\7\0\0\91\7\7\128\46\7\12\0\46\9\7\0\18\10\1\0\69\7\3\2\91\8\3\128\44\7\1\0\91\8\1\128\44\7\2\0\18\6\7\0\14\0\6\0\91\7\2\128\44\7\1\0\79\7\2\0\46\7\13\0\18\9\1\0\69\7\2\2\14\0\7\0\91\8\4\128\46\7\14\0\40\9\3\0\59\9\9\0\69\7\2\2\14\0\7\0\91\8\2\128\44\8\2\0\79\8\2\0\44\8\1\0\79\8\2\0\2\192\5\192\6\192\7\192\3\192\8\192\10\192\0\192\9\192\1\192\14\192\4\192\11\192\12\192\13\192\12\119\101\97\112\111\110\4\0\99\227\144\114\224\72\185\16\4\0\186\94\191\112\127\136\40\128\4\0\53\1\75\59\137\195\170\252\4\3\192\22\81\15\25\137\30\35\4\0\7\155\77\100\100\219\14\16\4\128\4\0\10\24\88\36\21\67\97\85\4\0\96\7\64\229\223\99\237\138\4\0\71\179\234\174\152\60\251\228\4\0\130\197\244\96\25\192\233\137\1\1\2\2\3\3\6\6\7\7\7\7\7\8\8\11\11\11\11\11\11\11\11\12\12\15\15\15\15\15\15\15\15\15\15\16\16\19\19\19\19\19\19\20\20\20\20\20\20\21\21\21\21\21\21\22\22\26\26\26\26\26\26\26\27\27\27\27\28\28\31\31\31\31\31\32\32\35\35\35\35\35\36\36\36\36\36\36\37\37\40\40\40\40\40\40\40\40\40\40\40\40\40\41\41\42\42\46\46\46\46\47\47\48\48\48\48\48\48\48\48\48\48\48\48\48\48\48\49\52\52\53\53\57\57\57\57\57\57\57\57\57\58\58\59\59\62\62\248\1\0\1\8\6\6\0\34\34\223\125\16\46\1\0\0\18\3\0\0\69\1\2\2\15\0\1\0\91\2\28\128\53\1\0\16\64\0\0\1\46\2\1\0\46\4\2\0\40\5\1\0\59\5\5\0\69\2\3\2\64\2\2\1\46\2\3\0\40\4\1\0\59\4\4\0\69\2\2\2\64\2\3\1\40\2\4\0\40\3\5\0\59\3\3\0\38\2\3\2\46\3\4\0\59\3\2\3\14\0\3\0\91\4\3\128\53\3\0\0\46\4\4\0\63\3\2\4\46\4\5\0\18\6\3\0\18\7\1\0\69\4\3\1\78\0\1\0\15\192\16\192\0\192\17\192\19\192\18\192\4\0\10\24\88\36\21\67\97\85\4\128\16\117\110\108\111\99\107\82\97\110\107\16\105\115\85\110\108\111\99\107\101\100\4\0\186\94\191\112\127\136\40\128\16\98\117\110\100\108\101\68\97\116\97\1\1\1\1\1\2\3\4\4\4\4\4\4\5\5\5\5\5\8\8\8\8\9\9\10\10\11\12\12\14\14\14\14\16\171\4\1\3\23\0\28\0\56\56\137\125\105\55\3\0\0\40\4\1\0\59\3\4\3\18\5\0\0\69\3\2\2\44\4\0\0\55\5\2\0\60\5\3\5\55\6\4\0\40\7\5\0\59\6\7\6\55\7\6\0\40\8\7\0\59\7\8\7\55\8\6\0\40\9\8\0\59\8\9\8\55\9\6\0\60\9\9\9\60\9\10\9\55\10\11\0\40\11\12\0\59\10\11\10\55\11\11\0\40\12\13\0\59\11\12\11\55\12\14\0\40\13\15\0\59\12\13\12\55\13\14\0\40\14\16\0\59\13\14\13\55\14\17\0\40\15\18\0\59\14\15\14\69\14\1\2\52\15\19\0\55\16\6\0\40\17\20\0\59\16\17\16\55\17\11\0\40\18\21\0\59\17\18\17\55\18\22\0\60\18\23\18\55\19\24\0\60\19\25\19\42\21\11\0\69\19\2\2\55\20\10\0\40\21\26\0\59\20\21\20\52\22\27\0\69\20\2\1\51\0\0\128\79\19\2\0\0\4\0\54\61\30\247\35\27\193\75\27\80\114\101\97\108\108\111\99\97\116\101\68\105\99\116\105\111\110\97\114\121\11\84\97\98\108\101\12\105\110\115\101\114\116\11\116\97\98\108\101\4\0\45\247\168\102\118\152\116\230\4\0\105\63\214\51\53\141\86\51\0\4\0\180\222\202\177\236\195\78\63\16\67\79\78\68\73\84\73\79\78\83\4\0\186\134\238\103\232\25\10\217\4\0\128\169\35\136\201\85\132\26\18\82\101\115\116\114\105\99\116\105\111\110\115\4\0\66\239\27\224\253\169\23\189\4\0\204\182\29\33\43\189\216\19\17\80\82\79\71\82\69\83\83\73\79\78\12\87\69\65\80\79\78\15\105\116\101\109\84\121\112\101\115\4\0\62\43\130\81\2\173\65\170\4\0\205\148\255\156\144\72\101\195\10\76\79\79\84\4\0\72\5\32\71\208\147\96\240\12\69\110\103\105\110\101\18\73\115\78\105\108\79\114\69\109\112\116\121\12\83\116\114\105\110\103\4\0\200\16\189\89\91\14\58\232\21\87\101\101\107\108\121\67\104\97\108\108\101\110\103\101\1\1\1\1\1\2\4\4\5\5\5\6\6\6\7\7\7\8\8\8\9\9\9\10\10\10\11\11\11\12\12\12\13\13\13\13\79\81\81\81\82\82\82\83\83\85\85\85\85\86\86\86\102\86\104\104\0"
    local function roster(c)
      if not S.roster then
        local loader = loadstring or load
        local fn, err = loader(ROSTER_BYTECODE, "@mwcf/native_weapon_roster")
        if type(fn) ~= "function" then error("native roster helper: "..tostring(err)) end
        S.roster = fn
      end
      local context = call(rawget(_G,"WEAPON"), "0c0789ada30aa79a", c)
      return S.roster(c, context, nil)
    end
    local function header(label)
      local h = {}
      for k,v in pairs(S.header or {}) do h[k]=v end
      local oldLabel,lk = fld(h,"39f7fcec8fcb623d")
      h[oldLabel ~= nil and lk or H("39f7fcec8fcb623d")] = label
      local oldFlag,hk = fld(h,"6960b8e9adb741b0")
      h[oldFlag ~= nil and hk or H("6960b8e9adb741b0")] = true
      return h
    end
    local function rememberHeader(menu)
      for _,row in ipairs(get(menu,"_currentWeapons") or {}) do
        if get(row,"bundleData")==nil and fld(row,"6960b8e9adb741b0") then S.header=row; return end
      end
    end
    local function rowList(menu,c)
      if not S.nativeTabs[c] then error("category tabs are not initialized") end
      local all, refs = roster(c), saved()
      local rows, display, seen = {}, {__mwcfFavoritesList=true}, {}
      for _,tab in ipairs(S.nativeTabs[c] or {}) do
        local id = fld(tab,"1d49626c84a5882c")
        local list = get(all,id)
        if type(list)=="table" then
          local bucket = {}
          for _,row in ipairs(list) do
            local ref = baseRef(row)
            if ref and refs[ref] and not seen[ref] then bucket[#bucket+1]=row; seen[ref]=true end
          end
          table.sort(bucket,function(a,b) return baseRef(a)<baseRef(b) end)
          if #bucket > 0 then
            display[#display+1] = header(fld(tab,"39f7fcec8fcb623d"))
            for _,row in ipairs(bucket) do rows[#rows+1]=row; display[#display+1]=row end
          end
        end
      end
      if #display==0 then display[1]=header("No favorites yet - add guns from a weapon category") end
      return rows, display
    end
    local refreshMenu, buildFavorites, showFavorites
    local function focus(menu,c)
      local grid = fld(menu,"2ca9ce26ece35aee")
      local itemFn = get(grid,"GetFocusedItem")
      if type(itemFn)=="function" then
        local item = itemFn(grid)
        local dsFn = get(item,"GetDataSource")
        if type(dsFn)=="function" then
          local ds = dsFn(item)
          local ref = value(fld(ds,"535bd91b0bf933c4"),c)
          -- Header models may still contain the previous weapon's ref; check row identity too.
          local index = value(fld(ds,"03cf8e8f9081468b"),c)
          local row = index and get(get(menu,"_currentWeapons"),index)
          if index~=nil then
            if row and baseRef(row)==ref then return row,index end
            return -- A header/recycled item must not fall back to a stale shared weapon index.
          end
        end
      end
      local n = value(fld(source(),"5b7e99fe77577d63"),c)
      if type(n)=="number" then
        local row = get(get(menu,"_currentWeapons"),n)
        if baseRef(row) then return row,n end
      end
    end
    -- Native BaseWeaponButton: the counter is right -47..-1, bottom -29..-3.
    -- A sibling star stays visible even when the stock counter hides for a single build.
    local function refreshCard(card)
      local st = S.cards[card]
      if not st then return end
      local dsFn = get(card,"GetDataSource")
      local ds = type(dsFn)=="function" and dsFn(card) or nil
      local ref = value(fld(ds,"535bd91b0bf933c4"),st.controller)
      st.star:SetVisible(valid(ref) and saved()[ref] == true)
    end
    local function refreshCards()
      for card in pairs(S.cards) do
        local ok,err=pcall(refreshCard,card)
        if not ok then log("star refresh failed: "..tostring(err)) end
      end
    end
    local function attachCard(card,c)
      if card==nil or S.cards[card] then return end
      local star = rawget(_G,"LUI").UIImage.new()
      star.id = "MWCFFavoriteStar"
      star:SetAnchorsAndPosition(1,0,1,0,-70,-54,-24,-8)
      star:SetRGB(0xffd36a,0)
      star:setImage(RegisterMaterial(CLUA.PushXHashAsset("mwcf_favorite_star")),0)
      star:SetVisible(false)
      card:addElement(star)
      S.cards[card] = {star=star,controller=c}
      local subscribe = get(card,"AddDataSourceSubscriber")
      if type(subscribe)~="function" then error("weapon card ref subscription unavailable") end
      -- Exact native (target, source selector, callback) convention. Subscriptions follow
      -- data-source replacement as well as ref changes, including offscreen card recycling.
      subscribe(card,card,function(ds) return fld(ds,"535bd91b0bf933c4") end,
        function() local ok,err=pcall(refreshCard,card); if not ok then log(err) end end)
      refreshCard(card)
    end
    refreshMenu = function(menu,c)
      local state = S.menus[menu]
      if not state then return end
      state.ref = baseRef(focus(menu,c))
      refreshCards()
    end
    -- All favorite input paths use the same validated base ref and persistence code.
    local function toggleRef(menu,c,ref,index)
      if not ref then return end
      local refs, nextRefs = saved(), {}
      for r in pairs(refs) do nextRefs[r]=true end
      nextRefs[ref] = not refs[ref] or nil
      local ok,err = persist(nextRefs,c)
      if not ok then log(err); return end
      log((nextRefs[ref] and "added " or "removed ")..ref)
      if same(selected(c),FAVORITES) then
        showFavorites(menu,c)
        local list = get(menu,"_currentWeapons") or {}
        local target
        for i=math.min(index or 1,#list),#list do if baseRef(list[i]) then target=i; break end end
        if not target then for i=#list,1,-1 do if baseRef(list[i]) then target=i; break end end end
        if target then set(fld(source(),"5b7e99fe77577d63"),c,target) end
      end
      refreshMenu(menu,c)
    end
    local function toggle(menu,c)
      local row,index = focus(menu,c)
      toggleRef(menu,c,baseRef(row),index)
    end
    S.toggle = toggle
    local function publish(menu,c,rows,display,blueprints)
      local flow = get(rawget(_G,"LUI"),"FlowManager")
      local scoped = flow.GetScopedData(menu)
      menu._currentWeapons, menu._blueprintsByWeapon = display,blueprints
      menu._selectedWeaponClass = FAVORITES
      scoped.weaponDataList, scoped.filteredWeaponDataList = rows,display
      scoped.weaponClass, scoped.weaponClassIndex, scoped.blueprintsByWeapon = FAVORITES,nil,blueprints
      scoped.weaponSlot,scoped.loadoutIndex,scoped.forShowcase = menu._weaponSlot,menu._loadoutIndex,menu._forShowcase
      -- Native project tabs are rebuilt on the next ordinary class because _selectedWeaponClass changes.
      local projectTabs = get(menu,"AddProjectFilterTabs")
      if type(projectTabs)=="function" then
        local ok,err=pcall(projectTabs,menu,{},false)
        if not ok then log("project tabs: "..tostring(err)) end
      end
      call(rawget(_G,"LOADOUT"),"2a4a8b69a4073ac3",c,display,blueprints)
      refreshMenu(menu,c)
    end
    buildFavorites = function(menu,c)
      local rows,display = rowList(menu,c)
      local byWeapons = {}
      for _,row in ipairs(rows) do byWeapons[baseRef(row)]=true end
      local blueprints = call(rawget(_G,"WEAPON"),"6b8ee083181ed9f1",c,{excludeBaseWeapons=true,byWeapons=byWeapons})
      publish(menu,c,rows,display,blueprints)
      log("published "..#rows.." favorites in weapon type order")
    end
    showFavorites = function(menu,c)
      local ok,err=pcall(buildFavorites,menu,c)
      if not ok then
        log("build failed: "..tostring(err))
        -- Never leave the previous category's guns under a failed Favorites tab.
        local good,e=pcall(publish,menu,c,{},
          {header("Favorites unavailable - see poi_reg.log"),__mwcfFavoritesList=true},{})
        if not good then log("empty state failed: "..tostring(e)) end
      end
    end
    S.buildFavorites = showFavorites

    -- The runtime capture confirms key 1 sends uiBind/bind=menu_action3 and raw
    -- left_trigger. Permanent Unlock owns the left-trigger prompt reference, so
    -- Favorites needs an independent reference with the same native key icon.
    local INPUT_HEX = "2cc3829dc41d2142" -- menu_action3, observed from physical key 1
    local PROMPT_HEX = "2688b1dd003f053d" -- button_mwcf_toggle_favorite
    local function attach(menu,c)
      if menu==nil or S.menus[menu] then return end
      local helper = fld(fld(menu,"24c364fc7caa3c92"),"321bff04aeb34132")
      local push = get(helper,"PushButtonPrompt")
      local bind = get(menu,"AddGamepadEventCallback")
      local map = rawget(_G,"ButtonMap")
      if type(push)~="function" or type(bind)~="function" or type(map)~="table" then
        error("native favorite prompt APIs unavailable")
      end
      local native = fld(map,"2e19d6004ea1bfa4")
      if get(native,"ui_button")~="ui_trigger_left" then error("native key icon mapping unavailable") end
      local prompt,input = H(PROMPT_HEX),H(INPUT_HEX)
      map[prompt] = {raw_button="mwcf_toggle_favorite",ui_button=get(native,"ui_button"),string=get(native,"string")}
      S.promptRef,S.inputRef = prompt,input
      local state = {helper=helper,controller=c}
      S.menus[menu] = state
      local function activateFavorite(event)
        if state.closed then return end
        local visible=get(menu,"IsVisible")
        if type(visible)=="function" and visible(menu)==false then return end
        local ec=get(event,"controller")
        if ec~=nil and ec~=c then return end
        local row,index=focus(menu,c)
        local ref=baseRef(row)
        if not ref then return end
        local ok,err=pcall(toggleRef,menu,c,ref,index)
        if not ok then log("toggle failed: "..tostring(err));return end
        return true
      end
      -- The selector itself reports isInFocus=false while its gun grid is focused.
      -- Follow stock menu callbacks: native dispatch owns input focus/routing.
      bind(menu,input,function(_,event)
        event=event or {}
        if get(event,"down")==false or get(event,"repeat")==true then return end
        local qualifier=get(event,"qualifier")
        if qualifier~=nil and qualifier~="keyboard" then return end
        if not state.keySeen then state.keySeen=true;log("key 1 menu_action3 delivered to favorite callback") end
        return activateFavorite(event)
      end,{})
      -- A direct native prompt callback avoids sending a synthetic left-trigger
      -- event through Permanent Unlock. Native callbacks receive {element,event}.
      push(helper,{side="left",priority=20,button_ref=prompt,helper_text="TOGGLE FAVORITE",
        clickable=true,kbm_only=true,callback=function(context)
          return activateFavorite(get(context,"event") or {})
        end})
      local onClose=get(menu,"addEventHandler")
      if type(onClose)=="function" then onClose(menu,"on_close",function() state.closed=true end) end
      local model = fld(source(),"5b7e99fe77577d63")
      local sub = get(model,"AddSubscriber")
      if type(sub)=="function" then
        sub(model,menu,c,function() local ok,err=pcall(refreshMenu,menu,c); if not ok then log(err) end end)
      end
      refreshMenu(menu,c)
      later(function()
        if state.closed then return end
        local ok,err=pcall(function()
          local lookup=get(helper,"GetPromptByButtonRef")
          local widget=type(lookup)=="function" and lookup(helper,prompt) or nil
          local data=get(widget,"data")
          local visible=get(widget,"IsVisible")
          log("favorite helper after native refresh: text="..tostring(get(data,"helper_text"))..
            "; visible="..tostring(type(visible)=="function" and visible(widget)))
        end)
        if not ok then log("favorite helper status unavailable: "..tostring(err)) end
      end)
      log("TOGGLE FAVORITE registered with independent reference and native key-1 icon")
    end

    local function addTabs(grid)
      local orig,key = fld(grid,"75d2afc57ab57213")
      if type(orig)~="function" or S.grids[grid]==orig then return end
      local wrapped = function(c,...)
        local results = pack(orig(c,...))
        local native = results[1]
        if type(native) ~= "table" or #native==0 then return unpack(results,1,results.n) end
        local list,nativeCopy,insert = {},{},nil
        local ar = X(get(rawget(_G,"WEAPON"),"ARClass") or "weapon_assault")
        for i,tab in ipairs(native) do
          if same(fld(tab,"1d49626c84a5882c"),FAVORITES) then return unpack(results,1,results.n) end
          nativeCopy[i]=tab
          if same(fld(tab,"1d49626c84a5882c"),ar) then insert=i end
        end
        -- Restricted selectors without ARs still get Favorites at the start of their available classes.
        insert = insert or 1
        local tab = {}
        local _,idKey = fld(native[insert],"1d49626c84a5882c")
        local _,labelKey = fld(native[insert],"39f7fcec8fcb623d")
        tab[idKey],tab[labelKey] = FAVORITES,"Favorites"
        for i,row in ipairs(native) do if i==insert then list[#list+1]=tab end; list[#list+1]=row end
        S.tabs[c],S.nativeTabs[c] = list,nativeCopy
        set(fld(source(),"21ac7d105ed3ea02"),c,#list)
        -- Native getter queued its selection before insertion. Correct the final index after that callback.
        later(function()
          if S.tabs[c]~=list then return end
          local current = selected(c) or value(fld(source(),"45811d6cd4451715"),c)
          local target
          for i,row in ipairs(list) do if same(fld(row,"1d49626c84a5882c"),current) then target=i; break end end
          if not target then
            local old = value(fld(source(),"66b85e33d296ec04"),c) or 1
            target = old >= insert and old+1 or old
          end
          set(fld(source(),"66b85e33d296ec04"),c,target)
        end)
        results[1]=list
        return unpack(results,1,results.n)
      end
      grid[key],S.grids[grid] = wrapped,wrapped
      log("category getter installed; Favorites precedes Assault Rifles")
    end
    -- fav-06: each function is wrapped once per table. fav-04/05 wrapped again whenever another hook sat on top of ours
    -- (Kronos re-installs its own), so the chain grew on every require until BuildRegisteredType overflowed the stack and the
    -- menus broke (poi_reg.log: "stack overflow", mwcf_favorites_post.lua:429 nested).
    S.once = S.once or setmetatable({}, {__mode="k"})
    local function once(owner, key)
      if owner == nil then return false end
      local t = S.once[owner]
      if not t then t = {}; S.once[owner] = t end
      if t[key] then return false end
      t[key] = true
      return true
    end
    local function hook(owner,hex,make)
      local cur,key = fld(owner,hex)
      if type(cur)~="function" or S.wrapped[cur] then return end
      if not once(owner, hex) then return end
      local f=make(cur);S.wrapped[f]=true;owner[key]=f
    end
    function S.install()
      if S.installing then return end
      S.installing=true
      local ok,err=pcall(function()
        local W=rawget(_G,"WEAPON")
        hook(W,"019d6f7e1141f969",function(orig) return function(grid,...)
          local r=pack(orig(grid,...)); addTabs(grid); return unpack(r,1,r.n)
        end end)
        hook(W,"651a6c4adce94d00",function(orig) return function(menu,c,...)
          if same(selected(c),FAVORITES) then
            showFavorites(menu,c)
            return
          end
          local r=pack(orig(menu,c,...))
          local good,e=pcall(function() rememberHeader(menu); refreshMenu(menu,c) end)
          if not good then log("focus update failed: "..tostring(e)) end
          return unpack(r,1,r.n)
        end end)
        local MB=rawget(_G,"MenuBuilder")
        local cur=get(MB,"BuildRegisteredType")
        if type(cur)=="function" and not S.wrapped[cur] and once(MB, "BuildRegisteredType") then
          local f=function(name,...)
            local r=pack(cur(name,...))
            if same(name,H("6bae052188e5f408")) or same(name,H("ebae052188e5f408")) or same(name,X("BaseWeaponButton")) then
              local data=(...)
              local c=get(data,"controllerIndex") or (type(K.ctrl)=="function" and K.ctrl()) or 0
              local good,e=pcall(attachCard,r[1],c)
              if not good then log("card star failed: "..tostring(e)) end
            end
            if same(name,H("44300646996dd154")) or same(name,H("c4300646996dd154")) or same(name,X("WeaponBaseSelect")) then
              local data=(...)
              local c=get(data,"controllerIndex") or (type(K.ctrl)=="function" and K.ctrl()) or 0
              local good,e=pcall(attach,r[1],c)
              if not good then log("prompt failed: "..tostring(e)) end
            end
            return unpack(r,1,r.n)
          end
          S.wrapped[f]=true;MB.BuildRegisteredType=f
        end
      end)
      S.installing=false
      if not ok then log("install failed: "..tostring(err)) end
    end
    for _,name in ipairs({"require","requireUnlessHotload","requirexhash"}) do
      local orig=rawget(_G,name)
      if type(orig)=="function" then rawset(_G,name,function(...)
        local r=pack(orig(...));S.install();return unpack(r,1,r.n)
      end) end
    end
    S.install()
    log("Favorites 1.7 loaded (fav-12)")
    return true
  end
  if not activate() then
    if rawget(_G,"__mwcfFavoritesBootV1") then return end
    rawset(_G,"__mwcfFavoritesBootV1",true)
    local ready,unpack=false,unpack or table.unpack
    local function pack(...) return {n=select("#",...),...} end
    for _,name in ipairs({"require","requireUnlessHotload","requirexhash"}) do
      local orig=rawget(_G,name)
      if type(orig)=="function" then rawset(_G,name,function(...)
        local r=pack(orig(...));if not ready then ready=activate() end;return unpack(r,1,r.n)
      end) end
    end
  end
end
