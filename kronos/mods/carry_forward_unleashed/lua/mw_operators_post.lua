-- MW Operators (kronos\mods\mw_operators), built by mw_operator_poc/tools/build_mod.mjs from operators.json.
-- Runs after Kronos' LUIFPSCounter.lua on every UI load and leaves that file stock. Three parts:
--  1. Kronos' in-match "BO6 Operator" picker: the 128 added operators as rows #67 onwards
--     (_G.__kronosBo6Ops, read by the picker each time the page opens). Only added to Kronos' own 66 rows.
--  2. Lobby fix (v8): the lobby asks OPERATOR.0xde343b80e9004f35 for an operator's select scene and gets nil for
--     these operators; they get the BO7 random-operator scene. The engine bundle getter (Engine.0xf06093d047200548)
--     no longer throws for the missing bundle 0x45bb01060d731329 or for that scene.
--  3. Character preview: MWIII/MWII reactive skins name a *_reactiveoperator asset only Warzone's packs carry; the
--     preview skips that layer up front (shown plain, as Warzone does before it reacts) instead of failing first.
-- Parts 2 and 3 run from Kronos' own 250 ms lobby hook (_G.__kronosBo6LobbyHook), which this file wraps.
-- Needs the patched XINPUT9_1_0.dll (operator and skin tables enlarged past 72/434); this file cannot check for it.
do
  local K = rawget(_G, "KRONOS")
  if type(K) ~= "table" or type(K.H) ~= "function" then
    pcall(DebugPrint, "k1 mwops: KRONOS helpers missing - MW Operators off")
    return
  end
  local H = K.H
  local function log(s) pcall(DebugPrint, "k1 mwops: " .. tostring(s)) end
  local weak = function() return setmetatable({}, { __mode = "k" }) end
  local G = rawget(_G, "__mwOpsState")
  if type(G) ~= "table" then
    G = { rowsIn = weak(), hooks = weak(), mine = weak(), fixWrapped = weak(), told = 0, bundleTold = 0 }
    rawset(_G, "__mwOpsState", G)
  end

  -- 1. picker rows: { label, { skin labels }, operator hash, { skin hashes } }, in the DLL's slot order
  local ROWS = {
    { "Ghost (MWII)", { "Ghost" }, "2144b231ee61b7bc", { "39543e23437af108" } },
    { "Nicki Minaj (MWII)", { "Nicki Minaj" }, "57ce19d8501b12bb", { "06d00be2fbdd9117" } },
    { "Sardaukar (Dune)", { "Sardaukar" }, "7c6754028bc31103", { "210e56dc7d5a270f" } },
    { "Paul Atreides (MWIII)", { "Paul Atreides", "Paul Atreides (alt)" }, "64160da0791cbf36", { "277a6d0f69a3b03a", "158f87fc73566f36" } },
    { "Snoop Dogg (MWII)", { "Snoop Dogg", "Snoop Dogg (alt)" }, "1fad9559d907446e", { "5aadade3bc0326c6", "182ec936351d96de" } },
    { "Homelander (MWII)", { "Homelander" }, "4ddb12f471a98764", { "01600e429585c160" } },
    { "Cheech (MWIII)", { "Cheech" }, "029daf10efcddd21", { "30836ac26901117f" } },
    { "Chong (MWIII)", { "Chong" }, "57c1cb281374c5f9", { "40fc8ae7029e1cc7" } },
    { "Gus kitty (MWII)", { "Kitty", "Kitty (alt)" }, "5b76a143c2511e46", { "4cb9027146178742", "3a0131cc10de636a" } },
    { "Scorch (MWIII)", { "Scorch", "Scorch (skin 10)", "Scorch (skin 11)", "Scorch (skin 12)", "Scorch (skin 13)", "Scorch (skin 14)", "Scorch (skin 15a)", "Scorch (skin 15b)", "Scorch (skin 17)", "Scorch (skin 18)", "Scorch (skin 19)", "Scorch (skin 20)", "Scorch (skin 21)", "Scorch (skin 22)", "Scorch (skin 23)", "Scorch (skin 26)" }, "2bb41893adbd2966", { "4d357b3bf41c93ca", "4f3c2695238c2106", "4ac2c937f7c93c83", "330954fde42efeac", "550e45e6edb26f31", "34e0eaf331443832", "6a17844a88faf960", "65fec64617403917", "0916d4973338b98d", "6aa1514d3dfd02be", "795ce3c4aaaabc3b", "5be456da78a2d27f", "5dc9f9eb4242da22", "074794c12553d4fd", "71fa53d86c1eb588", "2842b272a44d87a1" } },
    { "Void (MWIII)", { "Void", "Void (skin 10)", "Void (skin 11)", "Void (skin 13)", "Void (skin 14)" }, "7eba0705b56228d6", { "4c1169414f0a9d9a", "0164ebb6d6ca7b56", "7b9b5d22dfc06093", "5d3bd9d09d1cc341", "6a34b687e2c74742" } },
    { "Pathfinder (MWIII)", { "Pathfinder", "Pathfinder (skin 10)", "Pathfinder (skin 11)", "Pathfinder (skin 12)", "Pathfinder (skin 13)", "Pathfinder (skin 14)", "Pathfinder (skin 15)", "Pathfinder (skin 17)", "Pathfinder (skin 18)", "Pathfinder (skin 19)", "Pathfinder (skin 20)", "Pathfinder (skin 21)", "Pathfinder (skin 22)" }, "046e22ee73e7dc50", { "2a22320ce61ddae0", "6b69fec6810a9794", "3a3f32af155a05f9", "2b9e08e4e0e35a2e", "69bdb70cb8d2182b", "7d1e9d75d8e62000", "2adc6e8b34c05515", "2a4f41dc8c9e7937", "7e252844bcacb39c", "44d152bbffc0bb61", "57b0281984938a11", "34bea1eceb5c3d0c", "728c162be41049e3" } },
    { "Jabber (MWIII)", { "Jabber", "Jabber (skin 10)", "Jabber (skin 11)", "Jabber (skin 12)", "Jabber (skin 13)", "Jabber (skin 14)", "Jabber (skin 15)", "Jabber (skin 16)", "Jabber (skin 17)", "Jabber (skin 18)", "Jabber (skin 19)", "Jabber (skin 21)", "Jabber (skin 22)", "Jabber (skin 23)", "Jabber (skin 24)", "Jabber (skin 25)", "Jabber (skin 26)", "Jabber (skin 27)", "Jabber (skin 28)", "Jabber (skin 28b)", "Jabber (skin 29)", "Jabber (skin 30)", "Jabber (skin 31)" }, "20bd95b7fd5b0516", { "320d9f3eb73f29da", "7dfb2cc96ce93296", "2715c8b2c54b2dd3", "374cf8c70de2aebc", "08b6456082a79081", "105b2a6dfe0ea582", "0e61548e974654df", "4d19ef1c80354f68", "37d69acb7c97115d", "1811664abc14fdce", "02247f33ef30004b", "3b6cea9cdb0b94f2", "3744a9bea597084d", "71fdb7a192352c18", "227ed132ef4ccc43", "21900417b3a3f8c6", "30314de1e81adaf1", "0e2c5cf8de976a6c", "3bc37d075a12d487", "4d32ad27db1faa7f", "56282525434aa42a", "1ad331561437e248", "3387723ed051ddbd" } },
    { "Price (MWII)", { "Price (a)", "Price (highrise)", "Price (intercept)", "Price (desert)", "Price (MWIII vault)", "Price (3)", "Price (MWIII 10)", "Price (MWIII 13)", "Price (MWIII 11)", "Price (MWIII 12)", "Price (MWIII 16)", "Price (MWIII 15)", "Price (MWIII 20)", "Price (MWIII 17)", "Price (MWIII 23)", "Price (MWIII 22)", "Price (MWIII 21)" }, "17c855dc6c70bd02", { "427b7a56d0b26c52", "5c03dbcee5fcd2ce", "51b30aa2ee48e2a7", "2bb6592287536706", "503164a131a24d7a", "427b4856d0b2175c", "73c605b02d97be55", "5cc15d18c7e9ca9a", "191301c749b36c40", "6fd1d90182910677", "09181b5e2c828d6b", "30ed95eb76fed7d4", "23a250a955e5c528", "506097aebbff876e", "0e79e8eef21f719f", "66e38bfad3bf1b42", "0e742f26ef71831d" } },
    { "Soap (MWII)", { "Soap (a)", "Soap (nightwar)", "Soap (co)", "Soap (classic)", "Soap (nightwar bc)", "Soap (4)", "Soap (4 alt)", "Soap (mexico)", "Soap (MWIII 10)", "Soap (MWIII 12)", "Soap (MWIII 11)", "Soap (MWIII 14)", "Soap (MWIII 13)", "Soap (MWIII 17)", "Soap (MWIII 19)", "Soap (MWIII 20)", "Soap (MWIII 15)", "Soap (MWIII 16)", "Soap (MWIII 22)" }, "129e23b338521ff0", { "140eac49169d07f4", "0fd74fee7623e6d9", "31fd5b316cda0b0f", "13314fc354513b9b", "2ec4207fa3f3f049", "140ed949169d546b", "31eee07ca80644ff", "241bd596dcbdaa6e", "562c8277d4bc765f", "7fa1c8b4ba0d32dd", "582658573b84c702", "6ee0f69c02c14f53", "14e51d05bdab70e8", "7f1826b04b58d03c", "4713eedcb00c09fa", "7c634111bf60af66", "45c65ab2aa5f5416", "50817349c01db201", "0e2804b43fbbc68c" } },
    { "Valeria (MWII)", { "Valeria (a)", "Valeria (t100)", "Valeria (2 2)", "Valeria (blackcell)", "Valeria (jaguar)", "Valeria (5)", "Valeria (5 bc alt)", "Valeria (3)", "Valeria (6)", "Valeria (7)", "Valeria (8)", "Valeria (MWIII 10)", "Valeria (MWIII 11)", "Valeria (MWIII 12)", "Valeria (MWIII 17)", "Valeria (MWIII 15)", "Valeria (MWIII 18)", "Valeria (MWIII 19)", "Valeria (MWIII 14)", "Valeria (MWIII 21)", "Valeria (MWIII 22)" }, "20b2417c10010917", { "552030118df51fdb", "217acad6c32ca5e7", "4013ec9b4803c373", "60effdd7775e5b77", "089e8590b76a956e", "552064118df57837", "0d5b0634fa48df33", "552062118df574d1", "552065118df579ea", "552066118df57b9d", "552057118df56220", "7a86ac1c38175ee6", "4a18e3fdb12682e3", "0c4b6fbeb872760c", "0cd551c32727456d", "63b8da5326b91e6f", "6d5e6c12fa3f251e", "4f38fe857c0b0a9b", "343805b8eaa33192", "5649c361b43b7682", "7dc533bf32c3e25d" } },
    { "Raptor (MWIII)", { "Raptor", "Raptor (10)", "Raptor (11)", "Raptor (13)", "Raptor (14)", "Raptor (15)", "Raptor (18)", "Raptor (19)", "Raptor (20)", "Raptor (21)" }, "5996c23723c9764d", { "47ffe47eb7f78793", "4428efaca36c8e59", "279ce641616aabf4", "67d0f05fc1436e8e", "670f560615206975", "0fc2521d341f4060", "2992a4f8386b9e41", "5f7f7a80f272ba7c", "3b55bbab39a61e1c", "0201e6227cba25e1" } },
    { "Ripper (MWIII)", { "Ripper", "Ripper (10)", "Ripper (13)", "Ripper (12)", "Ripper (14)", "Ripper (17)", "Ripper (15)", "Ripper (16)", "Ripper (18)", "Ripper (19)", "Ripper (20)" }, "443f7f49d4390a26", { "3cfbb58074593b8a", "5e55e9d29916a8c6", "6cf7339ccd8d8af1", "4af242b3c40a1a6c", "7832d057c07e44f2", "740a8f798b09b84d", "737c82cae2e65fcf", "2ec39d5c77a7dc18", "50401485cb88df7e", "1332c92451e46afb", "705311c1b8727c3f" } },
    { "Riptide (MWIII)", { "Riptide", "Riptide (10)", "Riptide (11)", "Riptide (12)", "Riptide (18)", "Riptide (15)", "Riptide (16)", "Riptide (17)", "Riptide (20)", "Riptide (22)", "Riptide (21)", "Riptide (23)", "Riptide (19)", "Riptide (25)", "Riptide (26)" }, "03820265cb045762", { "79f225d6af41382e", "6f336da55faeb39a", "0243e98e1a55ef77", "2b851253e1785540", "55b441e62e526022", "1b8a2beac447766b", "435fa6780ec3c0d4", "6351afe353a8cc39", "71cfe771db95bb33", "7bfecee0f13cec61", "48b64b88833572f6", "3552a469ae28e49c", "53ce9ed564b2587f", "5b15492d145932e2", "5916b985aae4a6bd" } },
    { "Swagger (MWIII)", { "Swagger", "Swagger (10)", "Swagger (11)", "Swagger (13)", "Swagger (14)", "Swagger (18)", "Swagger (15)", "Swagger (17)", "Swagger (16)", "Swagger (20)", "Swagger (21)", "Swagger (22)", "Swagger (23)", "Swagger (24)" }, "61845612411c257e", { "78e4d7c227915112", "504b665fe2ede98e", "36f97f491327760b", "2ca365acc5170959", "0ff6b8ad78d2223a", "36362cde93c3d156", "74240a18e40efb17", "4f89cc0636cae475", "783cc81d55c9bb60", "1b9f529a4982b247", "616df266e21b25ea", "7478d4879a14a9a5", "1bd1df6b9c84ee50", "5fc4b90143e1f6bb" } },
    { "Warden (MWIII)", { "Warden (vault)", "Warden (10)", "Warden (11)", "Warden (13)", "Warden (14)", "Warden (16)" }, "35255fe8c7af1aed", { "3c7aca29163e0746", "7566e63e08071679", "2691b25573b7a814", "66c5bc73d3906aae", "6604221a276d6595", "6576f56b7f4b89b7" } },
    { "MWIII india", { "MWIII india (base)", "MWIII india (02)" }, "488e8ad6ac097fd7", { "0b2b6877bd0889d1", "2846b4aafc6af6d2" } },
    { "MWIII charlie", { "MWIII charlie (base)" }, "4e11a9d78f102246", { "00a6c296bf37ea6a" } },
    { "MWIII delta", { "MWIII delta (base)", "MWIII delta (02)" }, "788e21c702bce512", { "05ced452f9f5b5be", "52874a00ac24784b" } },
    { "BBQ (MWIII)", { "BBQ (base)", "BBQ (10)", "BBQ (12)", "BBQ (15)", "BBQ (11)", "BBQ (13)", "BBQ (13a)", "BBQ (13c)", "BBQ (16)", "BBQ (17)", "BBQ (25)", "BBQ (23)", "BBQ (26)", "BBQ (20)", "BBQ (19)", "BBQ (24)", "BBQ (27)", "BBQ (28)", "BBQ (29)", "BBQ (30)", "BBQ (31)", "BBQ (32)" }, "3a98aacb2933ea58", { "158a887cc17017f8", "5b48d4eb33ac630c", "49841148b3514be6", "5bd2b6efa261326d", "7e3a5b17cce3b011", "1916492a2c606fe3", "6724fc09587c8d9c", "7a88a3282d891bf6", "03356ae565dd1e92", "32b63f7fa1f30b6f", "5e98d5da7d905510", "5f98fad19e91d1fe", "07e2490e128e7707", "17b564a0bb079589", "18b3108c57a0eba9", "353da07e16978165", "2246f12bfbc646aa", "7c5019e8a0967d71", "5a4b28ff97130cec", "1e89f9ac268188da", "080c42c15c0383b7", "5adb9e5aa84b2a80" } },
    { "MWIII cdl_male_away", { "MWIII cdl_male_away (base)" }, "67298a9ef9c94d86", { "6f930d0f998103aa" } },
    { "MWIII cdl_male_home", { "MWIII cdl_male_home (base)" }, "4a28bad9e7d4aec3", { "22bc6774bb1aefb5" } },
    { "Bantam (MWIII)", { "Bantam (base)", "Bantam (10)", "Bantam (11)", "Bantam (12)", "Bantam (14)", "Bantam (16)", "Bantam (17)", "Bantam (13)", "Bantam (15)", "Bantam (19)", "Bantam (20)", "Bantam (21)", "Bantam (18)" }, "6b57f4888b07f764", { "5afb12bb6892710c", "4749facfe6752e10", "1deec5737f7c5a65", "0af8162164ab1faa", "0508e475899d54e4", "484a1fc70776aafe", "0b3cd4658dd2367b", "70936e037b735007", "0066899623ec6e89", "6c149abac6f783cd", "53ba301711102a7d", "3e6cef2e57db0b08", "26cda89db395a798" } },
    { "Alpine (MWIII)", { "Alpine (base)", "Alpine (10)", "Alpine (11)", "Alpine (12)", "Alpine (14)", "Alpine (17)", "Alpine (13)", "Alpine (18)", "Alpine (19)", "Alpine (15)", "Alpine (16)", "Alpine (21)", "Alpine (24)", "Alpine (23)", "Alpine (22)" }, "7e6a0176a2674fc5", { "06fef1ad1c040a3b", "2845c2b2a2fbd761", "6199983b5fe7cf9c", "1e16db438d54a633", "055dad575ca391bd", "075c3cfec6181de2", "74fd3f5a34f45df6", "1db3a2a5b89521f9", "4ede6ebd2445b394", "6ca96c6ea0899648", "0563671f5f51803f", "2ea306d66c9af9c9", "226878151a074050", "665b51aac16448bb", "579fbf3354b68f3e" } },
    { "Ateret Dahan (MWIII)", { "Ateret Dahan (base)", "Ateret Dahan (10)", "Ateret Dahan (11)", "Ateret Dahan (12)", "Ateret Dahan (13)", "Ateret Dahan (14)", "Ateret Dahan (20)", "Ateret Dahan (18)", "Ateret Dahan (19)", "Ateret Dahan (17)", "Ateret Dahan (21)", "Ateret Dahan (15)", "Ateret Dahan (22)" }, "558e185cd316c8df", { "408a3af83024e0c9", "772de3970c3fd417", "1300922ba102fb3a", "5293a5845efbbd75", "7b46a19b7dfa9460", "3a0358c73b584f0b", "0c4379da231350de", "49a62e21e651cc9f", "220fd12dc7f17642", "132135bfab45fff4", "49e236cedf2b6d5b", "53553fde0b1ec28e", "1b1fdc1d82abbd44" } },
    { "Elodie Michaux (MWIII)", { "Elodie Michaux (base)", "Elodie Michaux (10)", "Elodie Michaux (14)", "Elodie Michaux (11)", "Elodie Michaux (13)", "Elodie Michaux (15)", "Elodie Michaux (16)" }, "6893fdb22671c6b1", { "523e9075404eec6f", "2d91751eba946595", "3cf439429b2e1679", "7fd3a4095eba3080", "4381ff5adcf08eda", "6e1f055a06dea814", "6c72bda03ea628ab" } },
    { "Byline (MWIII)", { "Byline (base)", "Byline (10)", "Byline (11)", "Byline (12)", "Byline (13)", "Byline (14)", "Byline (15)", "Byline (17)", "Byline (16)", "Byline (18)", "Byline (19)", "Byline (21)", "Byline (20)", "Byline (23)" }, "18b72732700e64aa", { "1f2c5a360d37ea06", "72d98773c7c6b7b2", "431b64691eb4b78f", "2ebf4c22493570d8", "470f7117c9bb390d", "0d34c315ba0ea086", "08bb65b88e4bbc03", "1306e2678434eeb1", "7101f17e7ab17e2c", "38feb9aadf666aea", "733019de46cdf747", "28e0fcc0fe3769ee", "619880706eba6feb", "096dfafdb936ba54" } },
    { "Corso (MWIII)", { "Corso (base)", "Corso (10)", "Corso (13)", "Corso (11)", "Corso (19)", "Corso (18)", "Corso (15)", "Corso (20)", "Corso (14)", "Corso (21)", "Corso (22)", "Corso (23)" }, "3c26cbdd18b22058", { "684323e74b9af9f8", "7aadb265f88d590c", "387b26a4f14165e3", "1d9f389291c4a611", "3817ee071c81e1a9", "410dde2a14cb8084", "7b37946a6742286d", "371a421b7fe88b89", "3957a24d56c52838", "3bbc9cfae59971e4", "41f08ceae9ce537b", "7efdd84c6372c7fe" } },
    { "Jet (MWIII)", { "Jet (base)", "Jet (10)", "Jet (12)", "Jet (11)", "Jet (13)", "Jet (17)", "Jet (16)", "Jet (14)", "Jet (15)", "Jet (18)", "Jet (19)", "Jet (20)", "Jet (24)", "Jet (22)", "Jet (21)", "Jet (23)", "Jet (26)", "Jet (25)", "Jet (27)", "Jet (28)", "Jet (29)" }, "2ce1a212a8d46a7c", { "5269749db1b22914", "4b43af16dbc24398", "14b2e2122498ac72", "108aa133ef241fcd", "0ffc94854700c74f", "7bc4c8a838d9e3c3", "7ad5fb8cfd311046", "6772546e282481ec", "0977455731a7f271", "6bc001490ea1ca10", "4264cbeca7a8f665", "71e271467f957e45", "013b356e0ee76669", "707b8497d6ba6b67", "70ad116929baf470", "0bccc1f94fa6178a", "0c11803d78cd2e5b", "5d4f258c1c4d7e44", "4e72c348bcb511de", "4459dbd159a5fa2d", "2c09b6dbd92031f8" } },
    { "Enigma (MWIII)", { "Enigma (base)", "Enigma (10)", "Enigma (11)", "Enigma (14)", "Enigma (12)", "Enigma (13)", "Enigma (15)", "Enigma (16)", "Enigma (17)", "Enigma (18)", "Enigma (19)", "Enigma (23)", "Enigma (22)", "Enigma (24)", "Enigma (25)" }, "2d8212c34493d105", { "6560a9df7ae3ab7b", "0166b23f427f4ea1", "08705d4aad1c07dc", "606b948dc3859bfd", "20c797f7bccf5573", "4e1e2ee6d477d536", "4b1e53a50a507c88", "350856a716d4997f", "36edf9b7e074a122", "448b67b505cb0d39", "24995e49c0e601d4", "17ee38dc4047a7fb", "54fb843db9ec1c7e", "53fb5f4698ea9f90", "2aa029ea31f1cbe5" } },
    { "Ben (MWIII)", { "Ben (base)", "Ben (10)", "Ben (10a)" }, "55eec25f6e94471a", { "0d2ebaff0c1a09d6", "47d31d2850fb9c42", "63cbcc1b7a70dd83" } },
    { "Laswell (MWIII)", { "Laswell (base)", "Laswell (11)", "Laswell (12)" }, "5313be5ea15fc280", { "1f7ba41f75cb5930", "4b43ebf3bf7b4709", "13278224a305837e" } },
    { "Nolan (MWIII)", { "Nolan (base)", "Nolan (10)", "Nolan (11)", "Nolan (15)", "Nolan (13)", "Nolan (16)", "Nolan (17)", "Nolan (18)", "Nolan (19)" }, "0c425395f74780ce", { "77479950959dc742", "6d913ebae404defe", "3083f3596a606a7b", "15da8cf758018407", "25ada88a007aa289", "6c9119c3c3036210", "4335e4675c0a8e65", "7ba71407b192a846", "7c95e122ed3b7bc3" } },
    { "MWIII uniform", { "MWIII uniform (02)", "MWIII uniform (01)" }, "230fbd95a034836c", { "6274d8af5598ccad", "65b18449fb5b2fd2" } },
    { "Makarov (MWIII)", { "Makarov (vault)", "Makarov (12)", "Makarov (13)", "Makarov (14)", "Makarov (21)", "Makarov (15)", "Makarov (20)", "Makarov (16)", "Makarov (18)", "Makarov (19)" }, "081931cc82bf2aa9", { "17fbf05c81a71f82", "594d033e3fad2ebf", "5b45d91da673cc62", "7c2f5ed1835785e1", "4ef9094ff7f2aa25", "3583345a40437e1c", "76521433fa62eed0", "720077626db054b3", "623a7aa0b8571f95", "347ca98b5c7cea80" } },
    { "MWIII cdl_female_away", { "MWIII cdl_female_away (base)" }, "09b4a17bdbdf2291", { "57710835c1576a0f" } },
    { "MWIII cdl_female_home", { "MWIII cdl_female_home (base)" }, "0461c14000296c24", { "4112b06e8e1da1cc" } },
    { "Ari (MWIII)", { "Ari (base)", "Ari (13)", "Ari (11)", "Ari (10)", "Ari (14)", "Ari (15)", "Ari (18)", "Ari (19)", "Ari (20)" }, "6f536635c026c149", { "5621e88daa434437", "384235312969eb02", "7500f9dfab9094e8", "5fbda58ea7f256dd", "309d5023ae02d601", "5f34038a393df43c", "635ddf0f59087a35", "3af405a3c771b420", "081b56d084743df0" } },
    { "MWIII gamma", { "MWIII gamma (base)" }, "2d243210f3334135", { "11b703fa8779008b" } },
    { "MWIII zeta", { "MWIII zeta (base)" }, "101eae661b3bd9ee", { "29a3cff4930b84a2" } },
    { "MWIII eta", { "MWIII eta (base)" }, "2e26fc477b45ca8c", { "5475778d742fb944" } },
    { "MWIII ash", { "MWIII ash (01)", "MWIII ash (10)" }, "4f01a7478d5f3064", { "7d6e8be44eaebcfa", "109fd4c4a12d8710" } },
    { "MWIII cal", { "MWIII cal (base)" }, "6091f54797637160", { "6f2f4f6027839a50" } },
    { "Rick Grimes (MWIII)", { "Rick Grimes (base)", "Rick Grimes (10)" }, "460cf7e240e95a4c", { "2f4df1006b141a04", "60e73ac5a0998688" } },
    { "Michonne (MWIII)", { "Michonne (base)" }, "07f7c5a08dc8cfa1", { "695a2d8fbef5d8ff" } },
    { "Bashiir (MWIII)", { "Bashiir (base)", "Bashiir (10)", "Bashiir (11)", "Bashiir (13)", "Bashiir (12)", "Bashiir (14)", "Bashiir (15)" }, "69b14d54bf98ea37", { "30428a6d42b79871", "140fa2f7997ff79f", "6c7946037b1fa142", "29380ab1fd464b28", "1409e92f96d2091d", "7ddfec9e7818ba93", "03a97b326f22d556" } },
    { "Orla Murphy (MWIII)", { "Orla Murphy (base)", "Orla Murphy (10)", "Orla Murphy (12)", "Orla Murphy (15)", "Orla Murphy (17)", "Orla Murphy (14)", "Orla Murphy (16)" }, "583960d199299e4f", { "5c3c62bcb324e559", "496e5bbb038b3927", "458250bfe2249005", "2212a2c21f44239e", "075fd231f9b59c04", "03ed3534a110091b", "7e69e20f016bfd29" } },
    { "MWIII fall", { "MWIII fall (base)" }, "6c3f7e7c98321fc5", { "6de3c3e753927a3b" } },
    { "Book (MWIII)", { "Book (base)" }, "5a77edf921176a4d", { "1ae466984024e393" } },
    { "MWIII thyme", { "MWIII thyme (base)" }, "5d161d72b5fd807d", { "5394f18a62e089e3" } },
    { "MWIII sage", { "MWIII sage (base)" }, "7c14ee2f50e66eec", { "0d855fe9bf21d2e4" } },
    { "Woods (MWIII)", { "Woods (base)", "Woods (10)", "Woods (11)" }, "33468880f3a8f49e", { "1264735546c950f2", "2845bdce503570ae", "66656bf628242eab" } },
    { "Hammer (MWIII)", { "Hammer (base)", "Hammer (10)", "Hammer (12)", "Hammer (11)", "Hammer (13)", "Hammer (14)" }, "1a81dfbf44e19bfa", { "42511f84126964f6", "7417a14291a26b22", "0847fb2fbb7e4688", "7231fe31c802637f", "1d953c1874b365fd", "0b47d67185a59f36" } },
    { "MWIII mochi", { "MWIII mochi (base)" }, "46810eb555dd0632", { "0b45cb560e21cb1e" } },
    { "WWE gelato (MWIII)", { "WWE gelato (base)" }, "6dc3ade09c6775a6", { "189abc83c34fce0a" } },
    { "Rhea Ripley (MWIII)", { "Rhea Ripley (base)", "Rhea Ripley (11)", "Rhea Ripley (12)", "Rhea Ripley (13)" }, "0148785e56d61e4d", { "5a370fba8b6c7f93", "6ccdc571769c53f4", "13afe87906aea30b", "2d01cf8fd675168e" } },
    { "MWIII onyx", { "MWIII onyx (base)" }, "517227ca53e51fcc", { "319741bd74b87a84" } },
    { "Ivan (MWIII)", { "Ivan (base)", "Ivan (10)" }, "6b0512b0ba9ef554", { "20559eae72f5335c", "1b83ba2d630e2fa0" } },
    { "Eric (The Crow) (MWIII)", { "Eric (The Crow) (base)", "Eric (The Crow) (10)" }, "068f9a7285029f21", { "4a2d7b48d2bc177f", "0f65b0ceaa5b56a5" } },
    { "MWIII fuse", { "MWIII fuse (base)" }, "5537717cd3f13e51", { "54d778844af543cf" } },
    { "Felix (MWIII)", { "Felix (base)", "Felix (10)" }, "7828a3c28529a94d", { "1b5e374df2494093", "651dc2979c912159" } },
    { "Daryl Dixon (MWIII)", { "Daryl Dixon (base)", "Daryl Dixon (10)" }, "720d61a31a459702", { "5f1a16268c124a8e", "51321b796274a83a" } },
    { "Sam (MWIII)", { "Sam (base)", "Sam (10)" }, "28d3f84f53acaff9", { "64d8c42f35219ac7", "32ff01b39a7e802d" } },
    { "Michael Myers (MWIII)", { "Michael Myers (base)", "Michael Myers (10)" }, "3dfd72bb1eac299d", { "1b09b4ee8931bdc3", "7d9ef3379b6c5b49" } },
    { "Art the Clown (MWIII)", { "Art the Clown (base)" }, "26e9baa656a104c5", { "46c0ccef8e47093b" } },
    { "Zimo (MWII)", { "Zimo (base)", "Zimo (pa)", "Zimo (dmz_2)", "Zimo (dmz_1)", "Zimo (lny)", "Zimo (4_1)" }, "1201c8a39949848e", { "61d7cab2c72dcd26", "6fb4b8c873054eb8", "24b88d15e2eafb0b", "24b88e15e2eafcbe", "31c7199b5d92b050", "4d1cf59a4b2b7dfd" } },
    { "Kpop (MWII)", { "Kpop (base)", "Kpop (wf)", "Kpop (drug)", "Kpop (pilotish)", "Kpop (6)", "Kpop (8)", "Kpop (8_alt)" }, "72c148f5392bf42d", { "374c20500aaf7455", "25841b0227e2872f", "50e8e609e177c4d4", "4ee911cb21ba10fc", "374bc9500aaee080", "374bd7500aaef84a", "3ca2f7678ec41e92" } },
    { "Chili (MWII)", { "Chili (base)", "Chili (agu)", "Chili (chuy)", "Chili (ma)", "Chili (s2)", "Chili (assassin)", "Chili (diego)", "Chili (overgrown)", "Chili (diego_bc)", "Chili (wendingo)" }, "7cc5851d831398be", { "4473081b9074c6f6", "61a4576b3be7dd62", "01e6d72a0c5e5a5a", "446665d676908541", "440082d6763a0356", "78be13707c87beee", "07070556ac6cc319", "2e77b5251779f020", "2e9f922a61752989", "7c5b9f98d084a2f0" } },
    { "Hutch (MWII)", { "Hutch (base)", "Hutch (b)", "Hutch (greed)", "Hutch (frontline)", "Hutch (merry)", "Hutch (por)", "Hutch (fox)", "Hutch (darpa)", "Hutch (10)" }, "0e22beaf5b4af639", { "5163439f0449b3a9", "5163409f0449ae90", "663200049abd1167", "3d98f72166326ff7", "0db4231162f79807", "7a06a8d81db34a3b", "15c880d875e08223", "0960dc9771966896", "1602803449c68e4b" } },
    { "Fender (MWII)", { "Fender (base)", "Fender (b)", "Fender (knight)", "Fender (fringe)", "Fender (por)", "Fender (bodybuilder)", "Fender (grenadier)", "Fender (9)" }, "322ab09849868ebb", { "0e385da335086d17", "0e385ea335086eca", "0e1d07dc5f75cec1", "0ae99c5ee2f8af23", "235dfc3b1c04f0e9", "4071514ec4c605ef", "18a44f06b946eba1", "0e38a5a33508e76f" } },
    { "Stiletto (MWII)", { "Stiletto (a1)", "Stiletto (mt)", "Stiletto (et)", "Stiletto (c)", "Stiletto (sicaria_bc)", "Stiletto (sicaria)", "Stiletto (krueger)", "Stiletto (8_1)" }, "06264a1fe3983357", { "0d8a7340369c325e", "0d7cb84036906a41", "0d97a84036a716c9", "4189801bceb0ec81", "7222b68fd0c4959e", "0e4d75ca652d7c54", "6f2794e807c34603", "1ae5801b1637c474" } },
    { "Farah (MWII)", { "Farah (base)", "Farah (raid)", "Farah (xrk)", "Farah (convoy)", "Farah (convoy_bc)" }, "392495cf8fa933c7", { "48a89af37208d6ab", "28dd4ba5e7a6e1e8", "2190252cea5f6b37", "13b41363854afe4e", "2966605df568cef0" } },
    { "Kleo (MWII)", { "Kleo (base)", "Kleo (th2)", "Kleo (por)", "Kleo (bm1)", "Kleo (bm2)", "Kleo (envy)", "Kleo (darpa)", "Kleo (s2)", "Kleo (7)", "Kleo (bc_alt)", "Kleo (8)" }, "0e10c440839b0b70", { "0f37433da51d3f74", "3856718282e88951", "5967d3829530b58e", "77af6482ef828e63", "77af6582ef829016", "356211419a459d8f", "1b6a0d9aa230d7b7", "77f70fbf908a4748", "0f37713da51d8d9e", "2f768b396c251172", "0f376c3da51d851f" } },
    { "Ronin (MWII)", { "Ronin (base)", "Ronin (b)", "Ronin (wrath)", "Ronin (5)" }, "7e67e344d0323afb", { "56fc840657530857", "56fc850657530a0a", "0678ea63e752c7a4", "56fc50065752affb" } },
    { "Kilgore (MWII)", { "Kilgore (base)", "Kilgore (sloth)", "Kilgore (dmz_2)", "Kilgore (dmz_3)", "Kilgore (dmz_1)", "Kilgore (overgrown)", "Kilgore (por)", "Kilgore (hazmat)", "Kilgore (dr)", "Kilgore (nightops)", "Kilgore (wolf)", "Kilgore (cthulhu)", "Kilgore (phalanx)", "Kilgore (mgl_c)", "Kilgore (1_5)", "Kilgore (12)", "Kilgore (12_alt)" }, "7f7a0c7371216966", { "4814d31091192d0e", "16cfc7793461d33d", "19f9fb433617e403", "19f9fa433617e250", "19f9fc433617e5b6", "0f1b1fe51084d8e8", "3740bb82a1baf238", "7a948b8b3efc0dac", "14a123268dd6c04d", "583087f172594a9d", "359aaefe95c5f5b3", "7d2d09993633817e", "01bd44fa1d4ac6eb", "3876e61d23e9f653", "57fa0983d5fc2372", "1532e1268e523e44", "48d6dd1515190f50" } },
    { "Calisto (MWII)", { "Calisto (base)", "Calisto (et)", "Calisto (red)", "Calisto (purple)", "Calisto (7)", "Calisto (5)", "Calisto (6)" }, "3a3287df14310640", { "4b1e3303c085aca4", "29ef8f6023188344", "210c9f5c12db03b4", "43de453a31e1a4b7", "4b1e0103c08557ae", "4b1dff03c0855448", "4b1e0203c0855961" } },
    { "Nova (MWII)", { "Nova (base)", "Nova (tht)", "Nova (por)", "Nova (inkblot)", "Nova (champions)", "Nova (4_1)", "Nova (sergeant)", "Nova (8)" }, "10be543335b72ac3", { "1659d9435a56cbcf", "35d360919fa880c4", "568d0491b1a6a751", "6485591b76ff6e15", "4724da72cfa16290", "0a7ce59064d6a9f4", "096bdde0e6b702e3", "165990435a564fc4" } },
    { "Oni (MWII)", { "Oni (base)", "Oni (b)", "Oni (s2)", "Oni (s3)", "Oni (combat_p4)", "Oni (6)", "Oni (7)" }, "7cc6a025a1de45f5", { "3cdbe54b8fb2b18d", "3cdbe24b8fb2ac74", "1c1ace652c6f64bf", "1c1acd652c6f630c", "447f9f114d8b0a13", "3cdc0e4b8fb2f738", "3cdc0f4b8fb2f8eb" } },
    { "Reyes (MWII)", { "Reyes (base)", "Reyes (b)", "Reyes (et)", "Reyes (dr)", "Reyes (lust)", "Reyes (s2)", "Reyes (nc)", "Reyes (rat)", "Reyes (8)" }, "13cb05535a90ce53", { "581fe1c983fd027f", "581fe2c983fd0432", "3b21a46b46dfd325", "3b1e9c6b46dd8fb6", "50a44a0212e2b1e8", "3b6c666b471f5545", "3b3fc56b46f908c7", "0e5e2049d4102f37", "582038c983fd9654" } },
    { "Conor (MWII)", { "Conor (base)", "Conor (b)", "Conor (greased)", "Conor (exotic)", "Conor (por)", "Conor (stpatrick)" }, "03bf9fc07837fd84", { "0c8f91dce2c70dc0", "0c8f94dce2c712d9", "2f784ea00ad20faa", "1f1a82d89411a28b", "01963205427113a2", "6d8eb9b37b7092a8" } },
    { "Aksel (MWII)", { "Aksel (base)", "Aksel (wrath)", "Aksel (guerrilla)", "Aksel (s3bp)", "Aksel (bc)", "Aksel (techno)", "Aksel (unmasked)", "Aksel (police)" }, "68a66039bfdb40b5", { "2907bb15a681884d", "790cbd3947f51032", "267d70e2a035500f", "60755916e4e825ee", "39a123c9ee122cd5", "718f3de657c41b79", "025877536a9ee4a8", "43c55ccf490840b4" } },
    { "Gromsko (MWII)", { "Gromsko (base)", "Gromsko (b)", "Gromsko (gluttony)", "Gromsko (sanguine)", "Gromsko (weedlove)", "Gromsko (pro)" }, "312de57c40184877", { "6306feec5c2e64fb", "6306ffec5c2e66ae", "02f8d77326390016", "33b4da2065abef74", "7844393dc9c89875", "2705f7f45e742403" } },
    { "Luna (MWII)", { "Luna (base)", "Luna (b)", "Luna (s3)" }, "7ccc73e20851ff9d", { "5a717a380a6f3425", "5a7177380a6f2f0c", "1e365339bb1de6d4" } },
    { "Roze (MWII)", { "Roze (base)", "Roze (dmz_1)", "Roze (bp)", "Roze (dmz_2)", "Roze (por)", "Roze (sl)", "Roze (s3)", "Roze (4_1)", "Roze (code)", "Roze (7)", "Roze (7_alt)", "Roze (1_5)" }, "1420c4f94246208f", { "255d973c0df30fe3", "6645cc04f5c33847", "711b940bb40769d2", "6645cd04f5c339fa", "1dc567e290a2f51d", "70e8a60bb3dc2ecf", "70e85b0bb3dbaf5e", "6a4200e3ddcee0a8", "2894d2975ec8e605", "255dcd3c0df36ba5", "5e27e1bd6856ca75", "4e62f9e3cd7ce083" } },
    { "Zero (MWII)", { "Zero (base)", "Zero (yj)", "Zero (dw)", "Zero (et)", "Zero (s2)", "Zero (hollywood)", "Zero (s2_alt)", "Zero (6)", "Zero (evildeath)", "Zero (7)" }, "0465a8af5abaa28f", { "6f88b7fe4be1e1e3", "67172e1af0bb7413", "673c491af0dabe31", "67404c1af0deac21", "6703061af0aa8711", "635437c3141bfde9", "55fbcc339ec7f589", "6f88ecfe4be23bf2", "6fa9028272588c3c", "6f88edfe4be23da5" } },
    { "Pogba (MWII)", { "Pogba (base)" }, "7f427b545033f8fc", { "6aa3b506df10b648" } },
    { "Neymar (MWII)", { "Neymar (base)" }, "12f493d3163d0f4d", { "111d9300d24904b5" } },
    { "Zeus (MWII)", { "Zeus (base)", "Zeus (b)", "Zeus (bl)", "Zeus (fashion)" }, "0a3b08c441281768", { "4ca778852a6ed7fc", "4ca77b852a6edd15", "2f745c471a62549b", "34a91f195e11ae8f" } },
    { "Messi (MWII)", { "Messi (base)" }, "5492db9b14aa08e0", { "552f517d267b6504" } },
    { "Klaus (MWII)", { "Klaus (base)", "Klaus (easter)", "Klaus (easter_alt)" }, "5ea38c76ab0e975d", { "5bdc7bcc834053e5", "488394477f3e6024", "2255cb1dff3cd0f0" } },
    { "Gaz (MWII)", { "Gaz (base)", "Gaz (intercept)", "Gaz (convoy)", "Gaz (highrise)", "Gaz (highrise_bc)" }, "5640f98513cf3bd5", { "2509bb7f650f45ad", "431a9271b220ed8c", "5c962d7cd8320790", "209f9ae86c48908b", "29b7736e53d975bb" } },
    { "Shredder (MWII)", { "Shredder (base)" }, "061ca70b13e9d3cc", { "55d12c422e340378" } },
    { "Alejandro (MWII)", { "Alejandro (base)", "Alejandro (2_2)", "Alejandro (2_1)", "Alejandro (bc)", "Alejandro (space)", "Alejandro (space_alt)" }, "6fa5801ab5e382b7", { "512f3056e453e73b", "2f632007414b5493", "2f632107414b5646", "471963a5fa942797", "295eedd1a86b249e", "0d0782fcaadba88e" } },
    { "NICKMERCS (MWII)", { "NICKMERCS (base)", "NICKMERCS (b)" }, "50aee65463daddce", { "1be2e4c4cba66a66", "1be2e3c4cba668b3" } },
    { "Alex (MWII)", { "Alex (base)", "Alex (c)", "Alex (b)", "Alex (5)", "Alex (5_alt)", "Alex (4)" }, "0b07e68003acce03", { "57f3fe1c6e606c0f", "57f4001c6e606f75", "57f3ff1c6e606dc2", "57f42a1c6e60b6d3", "53401de08a82ca27", "57f4291c6e60b520" } },
    { "TimTheTatman (MWII)", { "TimTheTatman (base)" }, "3306b3b2de6acc19", { "7705a4b3eac827c9" } },
    { "Nikto (MWII)", { "Nikto (base)", "Nikto (t100)", "Nikto (t100_alt)", "Nikto (t0_alt)", "Nikto (3)", "Nikto (3_alt)" }, "4cfe76ba7307be86", { "3812d2ebc82a306e", "4931758f56982064", "2f2ce0f19f31a930", "3b776336b7d159b3", "381280ebc829a518", "098909e89fb479bc" } },
    { "Heather (MWII)", { "Heather (base)", "Heather (masked)" }, "1620cc538f9baecc", { "4c5d61f068e11678", "3bf7d98a10e80f2c" } },
    { "Black Noir (MWII)", { "Black Noir (base)" }, "114bebf3da4c7d8a", { "62eb3638c57d614a" } },
    { "Starlight (MWII)", { "Starlight (base)" }, "599a5c5f0ba3511f", { "787e8ad150b38e93" } },
    { "Zoltan (MWII)", { "Zoltan (base)", "Zoltan (bc)", "Zoltan (t100)", "Zoltan (t100bc)" }, "45cb789ebf14f6bd", { "49cd00061f0a9505", "71e18066bef1effd", "364f0a1e94f88b6d", "057381ef5539f0fa" } },
    { "Tetiana (MWII)", { "Tetiana (base)", "Tetiana (3)", "Tetiana (3_alt)" }, "2da374201b08c4b7", { "7492d82ea4d1793b", "74928a2ea4d0f4b1", "42b5b56da5e7c3e9" } },
    { "Arthur (MWII)", { "Arthur (base)" }, "33241a7584d96657", { "39e90c51d85b141b" } },
    { "Velikan (MWII)", { "Velikan (base)", "Velikan (alt)", "Velikan (2)" }, "4c29f231f9b1558d", { "72859acbe823bff5", "0261f3c75fcfa2fd", "7285c7cbe8240c6c" } },
    { "Graves (MWII)", { "Graves (base)", "Graves (sc)", "Graves (sc_bc)", "Graves (a_alt)" }, "0663d7c45b6a9117", { "6793f3574573e7db", "741f254b03cb31b6", "250cb400d0635378", "143c4f5421dd172f" } },
    { "21 Savage (MWII)", { "21 Savage (base)" }, "61789f98ca6393bc", { "399d30b5dddb2d08" } },
    { "Lara Croft (MWII)", { "Lara Croft (base)" }, "05eb2487291905ad", { "474f9248d12bc1d5" } },
    { "Mace (MWII)", { "Mace (base)" }, "0bb22ccd889e927f", { "1b76df4ca13725b3" } },
    { "Skeletor (MWII)", { "Skeletor (base)", "Skeletor (b)", "Skeletor (c)" }, "5caee9a847b43c6e", { "491297f0c59edec6", "491296f0c59edd13", "491295f0c59edb60" } },
    { "Inarius (MWII)", { "Inarius (base)" }, "6c3a322ae8af7690", { "21e77f91c811c8d4" } },
    { "Lilith (MWII)", { "Lilith (base)" }, "0d33467afa658c7d", { "3be6b7853dc962c5" } },
    { "Spawn (MWII)", { "Spawn (base)", "Spawn (tactical)", "Spawn (tactical_alt)", "Spawn (2)", "Spawn (2_alt)", "Spawn (burned)", "Spawn (burned_alt)", "Spawn (a_alt)" }, "08d549c954575e2c", { "092370b6b7a37498", "0afefdd560982f30", "77dc18b667839a34", "0923c3b6b7a401a1", "43aa8dec10111159", "7721f77a1aa9ef4d", "1d6d0ace4cdb33bd", "2be8dfa4ad95013c" } },
    { "Ash Williams (MWII)", { "Ash Williams (base)" }, "680846934fa9a173", { "06c9f58e6e6c9f5f" } },
    { "CDL male east (MWII)", { "CDL male east (ranked_away)" }, "4b41df0bd80c517b", { "356384c3cba3c066" } },
    { "CDL male west (MWII)", { "CDL male west (king)", "CDL male west (ranked)" }, "3d6e6382efad77d9", { "69de4006669df3bd", "2ff5f5bc08291255" } },
    { "CDL female east (MWII)", { "CDL female east (ranked_away)" }, "58b13415e9fd4d20", { "3eafb0dbd0c4b36d" } },
    { "CDL female west (MWII)", { "CDL female west (ranked)" }, "6684b79ed25c345a", { "37b0962057b77864" } },
    { "Blackcell (MWII)", { "Blackcell (base)" }, "0a4d960b98fb53a6", { "3df1177903a8df4e" } },
    { "Neo Tokyo (MWII)", { "Neo Tokyo (base)" }, "33e63c0dd1d1e1a1", { "354117e779fe1081" } },
    { "Freedom (MWII)", { "Freedom (masked)" }, "4db4a87d517b1469", { "36cb362e392b20db" } },
    { "Io (MWII)", { "Io (base)" }, "3732faeaf282dceb", { "3b8a02b09a10c027" } },
    { "Hellsing (MWII)", { "Hellsing (base)" }, "1d3b6176cd6fbe7b", { "590b081078c797d7" } },
    { "Kevin Durant (MWII)", { "Kevin Durant (base)" }, "1a5e168b2d01e350", { "3dc9f836a7c10594" } },
  }
  local d = rawget(_G, "__kronosBo6Ops")
  if type(d) ~= "table" then
    log("Kronos' BO6 operator list (__kronosBo6Ops) not found - picker rows not added")
  elseif not G.rowsIn[d] then
    G.rowsIn[d] = true
    local last = d[#d]
    if #d == 66 and type(last) == "table" and last[3] == "46107b93bf26e953" then
      for _, r in ipairs(ROWS) do d[#d + 1] = r end
      log("picker: " .. #ROWS .. " operators added after Kronos' 66 (#67-#" .. #d .. ")")
    else
      log("picker: Kronos' list has " .. #d .. " rows, not its stock 66 - rows not added")
    end
  end

  -- 2. lobby select-scene fix
  local SCENE_OPS = { "2144b231ee61b7bc", "57ce19d8501b12bb", "7c6754028bc31103", "64160da0791cbf36", "1fad9559d907446e", "4ddb12f471a98764", "29daf10efcddd21", "57c1cb281374c5f9", "5b76a143c2511e46", "2bb41893adbd2966", "7eba0705b56228d6", "46e22ee73e7dc50", "20bd95b7fd5b0516", "17c855dc6c70bd02", "129e23b338521ff0", "20b2417c10010917", "5996c23723c9764d", "443f7f49d4390a26", "3820265cb045762", "61845612411c257e", "35255fe8c7af1aed", "488e8ad6ac097fd7", "4e11a9d78f102246", "788e21c702bce512", "3a98aacb2933ea58", "67298a9ef9c94d86", "4a28bad9e7d4aec3", "6b57f4888b07f764", "7e6a0176a2674fc5", "558e185cd316c8df", "6893fdb22671c6b1", "18b72732700e64aa", "3c26cbdd18b22058", "2ce1a212a8d46a7c", "2d8212c34493d105", "55eec25f6e94471a", "5313be5ea15fc280", "c425395f74780ce", "230fbd95a034836c", "81931cc82bf2aa9", "9b4a17bdbdf2291", "461c14000296c24", "6f536635c026c149", "2d243210f3334135", "101eae661b3bd9ee", "2e26fc477b45ca8c", "4f01a7478d5f3064", "6091f54797637160", "460cf7e240e95a4c", "7f7c5a08dc8cfa1", "69b14d54bf98ea37", "583960d199299e4f", "6c3f7e7c98321fc5", "5a77edf921176a4d", "5d161d72b5fd807d", "7c14ee2f50e66eec", "33468880f3a8f49e", "1a81dfbf44e19bfa", "46810eb555dd0632", "6dc3ade09c6775a6", "148785e56d61e4d", "517227ca53e51fcc", "6b0512b0ba9ef554", "68f9a7285029f21", "5537717cd3f13e51", "7828a3c28529a94d", "720d61a31a459702", "28d3f84f53acaff9", "3dfd72bb1eac299d", "26e9baa656a104c5", "1201c8a39949848e", "72c148f5392bf42d", "7cc5851d831398be", "e22beaf5b4af639", "322ab09849868ebb", "6264a1fe3983357", "392495cf8fa933c7", "e10c440839b0b70", "7e67e344d0323afb", "7f7a0c7371216966", "3a3287df14310640", "10be543335b72ac3", "7cc6a025a1de45f5", "13cb05535a90ce53", "3bf9fc07837fd84", "68a66039bfdb40b5", "312de57c40184877", "7ccc73e20851ff9d", "1420c4f94246208f", "465a8af5abaa28f", "7f427b545033f8fc", "12f493d3163d0f4d", "a3b08c441281768", "5492db9b14aa08e0", "5ea38c76ab0e975d", "5640f98513cf3bd5", "61ca70b13e9d3cc", "6fa5801ab5e382b7", "50aee65463daddce", "b07e68003acce03", "3306b3b2de6acc19", "4cfe76ba7307be86", "1620cc538f9baecc", "114bebf3da4c7d8a", "599a5c5f0ba3511f", "45cb789ebf14f6bd", "2da374201b08c4b7", "33241a7584d96657", "4c29f231f9b1558d", "663d7c45b6a9117", "61789f98ca6393bc", "5eb2487291905ad", "bb22ccd889e927f", "5caee9a847b43c6e", "6c3a322ae8af7690", "d33467afa658c7d", "8d549c954575e2c", "680846934fa9a173", "4b41df0bd80c517b", "3d6e6382efad77d9", "58b13415e9fd4d20", "6684b79ed25c345a", "a4d960b98fb53a6", "33e63c0dd1d1e1a1", "4db4a87d517b1469", "3732faeaf282dceb", "1d3b6176cd6fbe7b", "1a5e168b2d01e350" }
  local function isAdded(s)
    for i = 1, #SCENE_OPS do
      if s:find(SCENE_OPS[i], 1, true) then return true end
    end
    return false
  end
  local function installFix()
    local O = rawget(_G, "OPERATOR")
    if type(O) ~= "table" then return end
    local E = rawget(_G, "Engine")
    local kb = H("f06093d047200548")
    local b = type(E) == "table" and E[kb]
    if type(b) == "function" and not G.fixWrapped[b] then
      local gb = function(...)
        local res = { n = 0 }
        local function keep(ok, ...) res = { n = select("#", ...) + 1, ok, ... } end
        keep(pcall(b, ...))
        if res[1] then return unpack(res, 2, res.n) end
        local s = tostring((...))
        G.bundleTold = G.bundleTold + 1
        if G.bundleTold <= 8 then
          local tb = ""
          pcall(function() tb = tostring(debug.traceback("", 2)):gsub("[\r\n\t]+", " | ") end)
          log("bundle lookup failed: " .. s .. " - " .. tostring(res[2]) .. tb)
        end
        -- the hash shows up in the error text, not the argument (R10); the fallback scene is never allowed to throw
        if s:find("45bb01060d731329", 1, true) or tostring(res[2]):find("45bb01060d731329", 1, true)
          or (G.scene and (...) == G.scene) then
          return nil
        end
        error(res[2], 0)
      end
      G.fixWrapped[gb] = true
      E[kb] = gb
    end
    local k = H("de343b80e9004f35")
    local f = O[k]
    if type(f) ~= "function" or G.fixWrapped[f] then return end
    if G.scene == nil then
      -- the random operator's scene; asset hashes are kind 3 (kind 4 made a broken value in R10)
      local ok, v = pcall(H, "3c241579101a9a92", 3)
      G.scene = ok and v or false
    end
    local g = function(ref, ...)
      local r = f(ref, ...)
      if r == nil and G.scene and ref ~= nil and type(ref) ~= "table" then
        local s = tostring(ref)
        if isAdded(s) then
          r = G.scene
          if G.told < 6 then
            G.told = G.told + 1
            log("select scene for " .. s .. " was nil - using the random operator's")
          end
        end
      end
      return r
    end
    G.fixWrapped[g] = true
    O[k] = g
  end

  -- 3. character preview: goes in front of Kronos' guard (_G.__kronosBo6Preview.wrapped). cs.wrapped is set to this
  --    wrapper too, so Kronos' "f ~= cs.wrapped" check sees it as its own and does not wrap it again.
  local function guardPreview()
    local CC = rawget(_G, "ClientCharacter")
    local cs = rawget(_G, "__kronosBo6Preview")
    if type(CC) ~= "table" or type(cs) ~= "table" or cs.t ~= CC or not cs.key then return end
    local kw = cs.wrapped
    if type(kw) ~= "function" or CC[cs.key] ~= kw or G.mine[kw] then return end
    cs.mwSkip = cs.mwSkip or {}
    local skip = cs.mwSkip
    local mine = function(c, name, ...)
      local s = type(name) == "string" and name or nil
      if s and s ~= "" and (skip[s] or s:find("^jup_.*_reactiveoperator$") or s:find("^iw9_.*_reactiveoperator$")) then
        if not skip[s] then
          skip[s] = true
          log("reactive: " .. s .. " is not in MP's packs - skin shown plain, as Warzone does before it reacts")
        end
        return kw(c, "", ...)
      end
      local before = cs.fails
      local r = kw(c, name, ...)
      if s and cs.fails ~= before and s:find("_reactiveoperator$") then skip[s] = true end
      return r
    end
    G.mine[mine] = true
    cs.wrapped = mine
    CC[cs.key] = mine
    log("character preview: reactive-skin guard in front of Kronos'")
  end

  local hook = rawget(_G, "__kronosBo6LobbyHook")
  if type(hook) == "function" and not G.hooks[hook] then
    local wrapped = function(...)
      local ok, e = pcall(hook, ...)
      pcall(installFix)
      pcall(guardPreview)
      if not ok then error(e, 0) end
    end
    G.hooks[wrapped] = true
    rawset(_G, "__kronosBo6LobbyHook", wrapped)
  elseif type(hook) ~= "function" then
    log("Kronos' lobby hook (__kronosBo6LobbyHook) not found - lobby fix and preview guard not installed")
  end
  pcall(installFix)
  pcall(guardPreview)
end
