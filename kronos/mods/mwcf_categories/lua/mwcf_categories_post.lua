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
          if S.swapIcon then pcall(S.swapIcon, bd, ref) end
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

    -- 1.1.0: BO6 / MW2 / MW3 list icons. The list's image getter (WEAPON[88ec23607b53add1]) gives those guns a flat icon
    -- (BO6 dark, MW washed out); their loot image (LOOT[ffa7ac7cb1a8d0c6](lootID)) is the lit render. Kronos sets
    -- WEAPON[that] = _G.__kronosBo6Image and re-wraps it whenever they differ, so this wrapper is stored in both places.
    local IMG_FN, LOOT_IMG = H("88ec23607b53add1"), H("ffa7ac7cb1a8d0c6")
    local DATA_KEY, LOOT_ID, IMAGE = H("86d696ad252f1cb1"), H("8028887f70bf5eba"), H("2ab612888528489a")
    local BUNDLE_FN, BUNDLE_PREFIX = H("f06093d047200548"), H("31705bf9ed477170", 3)
    local renderLogged, renderLogs = {}, 0
    local function carried(ref)
      return type(ref) == "string" and (ref:sub(1, 4) == "t10_" or ref:sub(1, 4) == "iw9_" or ref:sub(1, 4) == "jup_")
    end
    local function rowRef(m, c)
      if type(m) ~= "table" then return nil end
      local okV, v = pcall(function() return m:GetValue(c) end)
      if okV and carried(v) then return v end
      local parent
      for kk, vv in pairs(m) do if vv == "_parent" then parent = kk end end
      local ok, ref = pcall(function() return parent[DATA_KEY]:GetValue(c) end)
      if ok and carried(ref) then return ref end
      return nil
    end
    local function lootRender(ref)
      local okB, wb = pcall(Engine[BUNDLE_FN], BUNDLE_PREFIX .. ref)
      if not okB or type(wb) ~= "table" then return nil end
      local id = field(wb, LOOT_ID)
      local LOOT = rawget(_G, "LOOT")
      if id == nil or type(LOOT) ~= "table" then return nil end
      local okI, img = pcall(LOOT[LOOT_IMG], id)
      if okI and img ~= nil and img ~= "" then return img end
      return nil
    end
    -- The loadout weapon list (the one regrouped above) draws each row from row.bundleData; its Image field is the flat icon.
    -- Swap it for the loot render on BO6 / MW rows. Logs the first 12 guns either way.
    local iconLogged, iconLogs = {}, 0
    local dumped, dumps = {}, {}
    local function dumpBundle(bd, ref)
      local group = ref:sub(1, 3)
      if dumped[ref] or (dumps[group] or 0) >= ((group == "iw9" or group == "jup") and 2 or 1) or type(bd) ~= "table" then return end
      dumped[ref] = true
      dumps[group] = (dumps[group] or 0) + 1
      local parts = {}
      for k, v in pairs(bd) do
        local sv = tostring(v)
        if type(v) ~= "table" and type(v) ~= "function" and (sv:find("xhash", 1, true) or type(v) == "string") then
          parts[#parts + 1] = tostring(k) .. "=" .. sv
        end
      end
      table.sort(parts)
      log("bundle " .. ref .. " (" .. #parts .. " fields): " .. table.concat(parts, " ; "))
    end
    local function lootRenderFrom(bd, ref)
      local LOOT = rawget(_G, "LOOT")
      local id = field(bd, LOOT_ID)
      local okI, img = false, nil
      if id ~= nil and type(LOOT) == "table" then okI, img = pcall(LOOT[LOOT_IMG], id) end
      if okI and img ~= nil and img ~= "" then return img, id end
      local okL, img2 = pcall(lootRender, ref)
      return okL and img2 or nil, id
    end
    local MW_RENDER = {
      iw9_ar_acharlie300 = { "3800c6be674a8a45", "icon_weapon_ar_acharlie300" },
      iw9_ar_akilo = { "1b4d7cc4d7f0dbe7", "icon_weapon_ar_akilo" },
      iw9_ar_akilo105 = { "513bc282eded0f79", "icon_weapon_ar_akilo105" },
      iw9_ar_akilo74 = { "1999eae2e01c598c", "icon_weapon_ar_akilo74" },
      iw9_ar_augolf = { "67ff8445d5533ccd", "icon_weapon_ar_augolf" },
      iw9_ar_falpha = { "ca6ff0531696cf1", "icon_weapon_ar_falpha" },
      iw9_ar_fecho = { "543c6dcd063e9536", "icon_weapon_ar_fecho" },
      iw9_ar_golf3 = { "40ec954cae7ce38", "icon_weapon_ar_golf3" },
      iw9_ar_helima = { "444e4033869374e9", "icon_weapon_ar_helima" },
      iw9_ar_kilo53 = { "567c83853432536e", "icon_weapon_ar_kilo53" },
      iw9_ar_malima = { "310b992d830a69bc", "icon_weapon_ar_malima" },
      iw9_ar_mcbravo = { "165a338975c40c15", "icon_weapon_ar_mcbravo" },
      iw9_ar_mcharlie = { "27a9d55039c41b78", "icon_weapon_ar_mcharlie" },
      iw9_ar_mike16 = { "3d65d24e1957e3ea", "icon_weapon_ar_mike16" },
      iw9_ar_mike4 = { "28e6890e4dbdbbd7", "icon_weapon_ar_mike4" },
      iw9_ar_scharlie = { "5f499954df38107a", "icon_weapon_ar_scharlie" },
      iw9_ar_schotel = { "5c6f919f6fcc8459", "icon_weapon_ar_schotel" },
      iw9_br_msecho = { "422efc768b84acf2", "icon_weapon_dm_msecho" },
      iw9_br_ngsierra = { "5035c067654c5e37", "icon_weapon_br_ngsierra" },
      iw9_br_soscar14 = { "34b9de81d3dff6cc", "icon_weapon_br_soscar14" },
      iw9_dm_crossbow = { "90baf3b40e109bf", "icon_weapon_dm_crossbow" },
      iw9_dm_la700 = { "f599035ca1b9a0b", "icon_weapon_sn_la700" },
      iw9_dm_mike14 = { "306a8769459aee74", "icon_weapon_dm_mike14" },
      iw9_dm_mike24 = { "3074796945a32b2f", "icon_weapon_dm_mike24" },
      iw9_dm_pgolf1 = { "5e18b0a02d864644", "icon_weapon_dm_pgolf1" },
      iw9_dm_sa700 = { "c21ae14f59661fc", "icon_weapon_dm_sa700" },
      iw9_dm_sbeta = { "33051ceacdb1d2", "icon_weapon_dm_sbeta" },
      iw9_dm_scromeo = { "25a8dc36b9727e9d", "icon_weapon_dm_scromeo" },
      iw9_dm_stango25 = { "1220395bb6b613d4", "icon_weapon_dm_stango25" },
      iw9_dm_xmike2010 = { "2b8b025e0ad7282e", "icon_weapon_sn_xmike2010" },
      iw9_la_gromeo = { "78ebb651edc90666", "icon_weapon_la_gromeo" },
      iw9_la_juliet = { "1812394ba9a300d4", "icon_weapon_la_juliet" },
      iw9_la_kgolf = { "6e1aad9cf10cfefc", "icon_weapon_la_kgolf" },
      iw9_la_mike32 = { "3809f6bdd916e6e0", "icon_weapon_la_mike32" },
      iw9_la_rpapa7 = { "76ba1aa14fb4c248", "icon_weapon_la_rpapa7" },
      iw9_lm_ahotel = { "1fc533602df1ea48", "icon_weapon_lm_ahotel" },
      iw9_lm_foxtrot = { "62a73fcb19da1be1", "icon_weapon_lm_foxtrot" },
      iw9_lm_kilo21 = { "5197f21a88ea384f", "icon_weapon_lm_kilo21" },
      iw9_lm_ngolf7 = { "5ce5d1e554741840", "icon_weapon_lm_ngolf7" },
      iw9_lm_rkilo = { "cb3c56c10732b2e", "icon_weapon_lm_rkilo" },
      iw9_lm_slima = { "5928463af7b48e15", "icon_weapon_lm_slima" },
      iw9_me_kamas = { "3aa78ad67bed54ef", "icon_weapon_me_kamas" },
      iw9_me_knife = { "35aae5112f10530d", "icon_weapon_me_knife" },
      iw9_me_pickaxe = { "12080c10417d100b", "icon_weapon_me_pickaxe" },
      iw9_me_sword01 = { "4e24a3ca2067245a", "icon_weapon_me_sword01" },
      iw9_me_tonfa = { "6488a0583d093bac", "icon_weapon_me_tonfa" },
      iw9_pi_decho = { "714b82d1fc09173c", "icon_weapon_pi_decho" },
      iw9_pi_dechoauto = { "6ec814ab8fa9da8b", "icon_weapon_pi_dechoauto" },
      iw9_pi_golf17 = { "3310c394a9232f63", "icon_weapon_pi_golf17" },
      iw9_pi_golf18 = { "3310d094a923457a", "icon_weapon_pi_golf18" },
      iw9_pi_mike2011 = { "3a005c45e99049bd", "icon_weapon_pi_mike2011" },
      iw9_pi_papa220 = { "6156e277e4773509", "icon_weapon_pi_papa220" },
      iw9_pi_swhiskey = { "2833b3c6c80c86ba", "icon_weapon_pi_swhiskey" },
      iw9_pi_tango9 = { "73de519685a75c1f", "icon_weapon_pi_tango9" },
      iw9_sh_charlie725 = { "3fdfb0b253765381", "icon_weapon_sh_charlie725" },
      iw9_sh_mbravo = { "9f77207c50ecbf6", "icon_weapon_sh_mbravo" },
      iw9_sh_mike1014 = { "25cab5c0893a38d9", "icon_weapon_sh_mike1014" },
      iw9_sh_mviktor = { "73abfd1daf5e44a9", "icon_weapon_sh_mviktor" },
      iw9_sh_tsierra12 = { "7e7248f4acbcf910", "icon_weapon_sh_tsierra12" },
      iw9_sh_vecho = { "7cf8a6af86ebedca", "icon_weapon_sh_vecho" },
      iw9_sm_acharlie45 = { "c0565660f7be89a", "icon_weapon_sm_acharlie45" },
      iw9_sm_acharlie9 = { "514cdb7558e65b4c", "icon_weapon_sm_acharlie9" },
      iw9_sm_alpha57 = { "470d7dcbc96ba02e", "icon_weapon_sm_alpha57" },
      iw9_sm_apapa = { "61a919daa108fcc1", "icon_weapon_sm_apapa" },
      iw9_sm_aviktor = { "2c9a49e7a900bda2", "icon_weapon_sm_aviktor" },
      iw9_sm_beta = { "559614aa83b8ad40", "icon_weapon_sm_beta" },
      iw9_sm_mpapa5 = { "132148db8b9e1190", "icon_weapon_sm_mpapa5" },
      iw9_sm_mpapa7 = { "13214adb8b9e14f6", "icon_weapon_sm_mpapa7" },
      iw9_sm_mpapax = { "132195db8b9e9467", "icon_weapon_sm_mpapax" },
      iw9_sm_papa90 = { "4fae0d77c940133b", "icon_weapon_sm_papa90" },
      iw9_sm_sdelta = { "39b284ed9e911053", "icon_weapon_sm_sdelta" },
      iw9_sm_victor = { "1d90e9a24c14cf5d", "icon_weapon_sm_victor" },
      iw9_sn_alpha50 = { "3676ccc071937ed6", "icon_weapon_sn_alpha50" },
      iw9_sn_india = { "506623ac70dd2534", "icon_weapon_sn_india" },
      iw9_sn_limax = { "65279078ac4c8bf0", "icon_weapon_sn_limax" },
      iw9_sn_mromeo = { "7d09c194db5bb6fe", "icon_weapon_sn_mromeo" },
      iw9_sn_walpha = { "37df1cd2ba3f8436", "icon_weapon_sn_walpha" },
      jup_cp01_sh_aromeo410 = { "55a671fa38c84a96", "icon_weapon_jup_cp01_sh_aromeo410_mp" },
      jup_cp01_sm_coscar635 = { "4b3fa55f7ccf20e6", "icon_weapon_jup_cp01_sm_coscar635_mp" },
      jup_cp01_sm_pcharlie9 = { "39e8f06e336f160c", "icon_weapon_jup_cp01_sm_pcharlie9_mp" },
      jup_cp05_lm_halpha = { "50fd75d745bb8a2a", "icon_weapon_jup_cp05_lm_halpha_mp" },
      jup_cp06_ar_falpha = { "340340ccee93cc03", "icon_weapon_jup_cp06_ar_falpha_mp" },
      jup_cp08_br_xmike5 = { "1880712ddd0a2c9b", "icon_weapon_jup_cp08_br_xmike5_mp" },
      jup_cp15_lm_mkilo3 = { "ccf68d02e6ad590", "icon_weapon_jup_cp15_lm_mkilo3_mp" },
      jup_cp24_pi_glima21 = { "44ad13f13757c8b0", "icon_weapon_jup_cp24_pi_glima21_mp" },
      jup_jp01_ar_golf36 = { "5be4388873f0aae6", "icon_weapon_jup_jp01_ar_golf36_mp" },
      jup_jp01_dm_slima8 = { "f2b3dd06431df91", "icon_weapon_jup_jp01_dm_slima8_mp" },
      jup_jp01_lm_mgolf36 = { "323a7da2dceeb39d", "icon_weapon_jup_jp01_lm_mgolf36_mp" },
      jup_jp02_ar_bromeo805 = { "72c80b621c4ce5cf", "icon_weapon_jup_jp02_ar_bromeo805_mp" },
      jup_jp02_br_bromeo2 = { "27d076ef599cb05", "icon_weapon_jup_jp02_br_bromeo2_mp" },
      jup_jp02_dm_bromeop = { "498eade564aaca26", "icon_weapon_jup_jp02_dm_bromeop_mp" },
      jup_jp02_sm_scharlie3 = { "6e41eacbd92d0e95", "icon_weapon_jup_jp02_sm_scharlie3_mp" },
      jup_jp03_br_aromeo200 = { "76b199c28caa871", "icon_weapon_jup_jp03_br_aromeo200_mp" },
      jup_jp03_sm_pmike = { "7dea585c0508845a", "icon_weapon_jup_jp03_sm_pmike_mp" },
      jup_jp04_sm_lwhiskey = { "59b89160ce1c6cfd", "icon_weapon_jup_jp04_sm_lwhiskey_mp" },
      jup_jp04_sm_umike = { "abd5a4f852578d6", "icon_weapon_jup_jp04_sm_umike_mp" },
      jup_jp05_ar_foxtrot2000 = { "6a89846cd9134b9", "icon_weapon_jup_jp05_ar_foxtrot2000_mp" },
      jup_jp06_lm_pkilop = { "6473419ab0a38d53", "icon_weapon_jup_jp06_lm_pkilop_mp" },
      jup_jp07_pi_uzulum = { "4501a6e5d8fff5db", "icon_weapon_jup_jp07_pi_uzulum_mp" },
      jup_jp07_sm_uzulu = { "5835fdd92ef709eb", "icon_weapon_jup_jp07_sm_uzulu_mp" },
      jup_jp07_sm_uzulup = { "36e309ecbcec32b5", "icon_weapon_jup_jp07_sm_uzulup_mp" },
      jup_jp08_ar_qbravo97 = { "2e7f1ab8183e446f", "icon_weapon_jup_jp08_ar_qbravo97_mp" },
      jup_jp08_lm_qbravo95lsw = { "482afa330a00b7bd", "icon_weapon_jup_jp08_lm_qbravo95lsw_mp" },
      jup_jp09_sh_oromeo12 = { "437f079b3874a817", "icon_weapon_jup_jp09_sh_oromeo12_mp" },
      jup_jp10_sn_cdelta50 = { "2b60478f406a4ad9", "icon_weapon_jup_jp10_sn_cdelta50_mp" },
      jup_jp12_pi_mike93 = { "2b0f3f10e2d2cc77", "icon_weapon_jup_jp12_pi_mike93_mp" },
      jup_jp13_dm_svictork = { "5a4270d4673740fd", "icon_weapon_jup_jp13_dm_svictork_mp" },
      jup_jp13_sn_svictor = { "2b0b45192ec41578", "icon_weapon_jup_jp13_sn_svictor_mp" },
      jup_jp14_pi_rsierra12 = { "206d6a1c6e3e2884", "icon_weapon_jup_jp14_pi_rsierra12_mp" },
      jup_jp16_sh_recho870 = { "d3d2684ea6bdee7", "icon_weapon_jup_jp16_sh_recho870_mp" },
      jup_jp17_sn_hsierra = { "698469000eebf03c", "icon_weapon_jup_jp17_sn_hsierra_mp" },
      jup_jp19_ar_acharlie = { "7cd07401f9ee2dff", "icon_weapon_jup_jp19_ar_acharlie_mp" },
      jup_jp19_br_acharlie450 = { "6c8afe8a91ffe78f", "icon_weapon_jup_jp19_br_acharlie450_mp" },
      jup_jp19_dm_acharlied = { "528b3fda72a44449", "icon_weapon_jup_jp19_dm_acharlied_mp" },
      jup_jp20_lm_evictor = { "6fa662da324f1c22", "icon_weapon_jup_jp20_lm_evictor_mp" },
      jup_jp22_la_dromeo = { "5317a4c68e3007e", "icon_weapon_jup_jp22_la_dromeo_mp" },
      jup_jp23_me_kalpha = { "1b3fa683ed9db285", "icon_weapon_jup_jp23_me_kalpha_mp" },
      jup_jp23_me_pdango = { "2ac46963dcd53157", "icon_weapon_jup_jp23_me_pdango_mp" },
      jup_jp23_me_shotel = { "5e86b5c5209afbef", "icon_weapon_jup_jp23_me_shotel_mp" },
      jup_jp23_me_spear = { "5a7d45675a2a780f", "icon_weapon_jup_jp23_me_spear_mp" },
      jup_jp23_me_swhiskey = { "6e707e0334187597", "icon_weapon_jup_jp23_me_swhiskey_mp" },
      jup_jp25_ar_talpha95 = { "6156651ff8b32461", "icon_weapon_jup_jp25_ar_talpha95_mp" },
      jup_jp25_sm_talpham = { "476ac6c0ae22f691", "icon_weapon_jup_jp25_sm_talpham_mp" },
      jup_jp28_lm_rpapa20 = { "7581f02a7f8046be", "icon_weapon_jup_jp28_lm_rpapa20_mp" },
      jup_jp31_dm_compound = { "45b621af92513673", "icon_weapon_jup_jp31_dm_compound_mp" },
      jup_jp32_pi_mpapa9 = { "52349f401a970511", "icon_weapon_jup_jp32_pi_mpapa9_mp" },
      jup_jp34_ar_balpha27 = { "6de3fd348f9c869e", "icon_weapon_jup_jp34_ar_balpha27_mp" },
      jup_jp35_sn_moscar = { "34c8995a28f87a79", "icon_weapon_jup_jp35_sn_moscar_mp" },
      jup_jp36_ar_anov94 = { "cbf2541bc629e32", "icon_weapon_jup_jp36_ar_anov94_mp" },
      jup_jp36_sn_boscar = { "3544d34107b72adf", "icon_weapon_jup_jp36_sn_boscar_mp" },
      jup_jp37_dm_kappa98 = { "1229b4183b6b169c", "icon_weapon_jup_jp37_dm_kappa98_mp" },
      jup_jp38_sh_spapa12 = { "687e21b250d47171", "icon_weapon_jup_jp38_sh_spapa12_mp" },
      jup_jp40_br_hcharlie36 = { "25bbced2d94cd632", "icon_weapon_jup_jp40_br_hcharlie36_mp" },
      jup_jp41_sm_kpappa50 = { "12172117b6a6d86e", "icon_weapon_jup_jp41_sm_kpappa50_mp" },
      jup_jp44_ar_stango44 = { "6818c6e2cfb23cea", "icon_weapon_jup_jp44_ar_stango44_mp" },
      jup_pi_raygun = { "cd63ad36bb421ab", "icon_weapon_jup_pi_raygun_mp" },
    }
    -- MW2 / MW3: each gun's grey render (icon_weapon_<class>_<name>, icon_weapon_jup_..._mp) is already in the game; the list
    -- shows another, washed-out image. Point the row's bundle at the render: Image is an image hash (kind 4), and two string
    -- fields hold the icon name. BO6 icons are replaced by re-graded PNGs in kronos/Assets/Images instead (same names).
    local ICON_STR = { H("2bd538bb85256d75"), H("4a141b4aba47b77b") }
    -- 1.2.1: the image value must be the game's own image hash ("xhash: #x4<hash>"). K.H(hex, 4) made a short, wrong one (white
    -- squares), so the value now comes from CLUA.PushXHashAsset(name) and is used only when it reads back as exactly that hash.
    local function imageHash(r)
      local C = rawget(_G, "CLUA")
      if type(C) ~= "table" or type(C.PushXHashAsset) ~= "function" then return nil, "no CLUA.PushXHashAsset" end
      local ok, v = pcall(C.PushXHashAsset, r[2])
      if not ok or v == nil then return nil, "PushXHashAsset failed" end
      if tostring(v) ~= "xhash: #x4" .. r[1] then return nil, "got " .. tostring(v) end
      return v
    end
    function S.swapIcon(bd, ref)
      pcall(dumpBundle, bd, ref)
      local r = MW_RENDER[ref]
      if not r then return end
      local before = field(bd, IMAGE)
      local want, why = imageHash(r)
      local okS, eS, layers = true, nil, 0
      if want then
        -- 1.2.2: Kronos shows some guns (MW battle rifles under Marksman) through a proxy table whose __index is the real
        -- bundle; the menu reads the real one, so the image is written on every table of that chain.
        okS, eS = pcall(function()
          local t = bd
          for _ = 1, 4 do
            t[IMAGE] = want
            layers = layers + 1
            local okM, mt = pcall(getmetatable, t)
            if not okM or type(mt) ~= "table" or type(rawget(mt, "__index")) ~= "table" then break end
            t = rawget(mt, "__index")
          end
        end)
      end
      local isBr = ref:find("_br_", 1, true) ~= nil
      if isBr and not iconLogged[ref] then
        iconLogged[ref] = true
        log("list icon " .. ref .. " (battle rifle): image " .. tostring(before) .. (want and (" -> " .. tostring(field(bd, IMAGE)) .. ", " .. layers .. " table(s)") or
          (" kept (" .. tostring(why) .. ")")))
      end
      if not iconLogged[ref] and iconLogs < 12 then
        iconLogged[ref] = true
        iconLogs = iconLogs + 1
        log("list icon " .. ref .. ": image " .. tostring(before) .. (want and (" -> " .. tostring(field(bd, IMAGE)) .. (okS and "" or (" not set: " .. tostring(eS))))
          or (" kept (" .. tostring(why) .. ")")))
      end
    end

    function S.installImages()
      local W = rawget(_G, "WEAPON")
      if type(W) ~= "table" then return end
      local cur = field(W, IMG_FN)
      if type(cur) ~= "function" or cur == S.imgWrapped then return end
      local inner = cur
      S.imgWrapped = function(...)
        local g, m = inner(...), (...)
        if type(g) ~= "function" then return g end
        return function(c, ...)
          local r = g(c, ...)
          local okR, ref = pcall(rowRef, m, c)
          if not okR or not ref then return r end
          local okL, img = pcall(lootRender, ref)
          local use = okL and img or nil
          if not renderLogged[ref] and renderLogs < 12 then
            renderLogged[ref] = true
            renderLogs = renderLogs + 1
            log("icon " .. ref .. ": game gave " .. tostring(r) .. ", loot render " .. tostring(img) .. (use and use ~= r and " (used)" or " (not changed)"))
          end
          if use then return use end
          return r
        end
      end
      W[IMG_FN] = S.imgWrapped
      rawset(_G, "__kronosBo6Image", S.imgWrapped)
      log("BO6 / MW list icons use the loot render")
    end

    function S.install()
      pcall(S.installImages)
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
