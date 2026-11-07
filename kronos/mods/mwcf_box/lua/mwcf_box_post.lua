-- Independent MW2 override row immediately below Mystery Box Weapons.
-- Uses public option getters; no debug/upvalue access or stock edits.
do
  local function activate()
  local K = rawget(_G, "KRONOS")
  if type(K) ~= "table" or type(K.H) ~= "function" then return false end
  local previous = rawget(_G, "__mwcfBoxV1")
  if type(previous) == "table" and type(previous.install) == "function" then previous.install(); return true end
  local H = K.H
  local S = { choice = nil, extended = false }
  rawset(_G, "__mwcfBoxV1", S)
  local BOX_ID, BOX_DV, OWN_DV = "5a6d0000000000c0", "4d9298260a67304f", "ccd6e9c45368c605"
  local function pack(...) return {n=select("#",...),...} end
  local unpack = unpack or table.unpack
  local function log(s) if type(K.log)=="function" then K.log("mwcf box: "..s) end end
  local function read(hex)
    local ok,v=pcall(K.dvar,hex); return ok and tonumber(v) or nil
  end
  local function valid(v) return v and v==math.floor(v) and v>=0 and v<=3 end
  local function choice()
    if valid(S.choice) then return S.choice end
    local v=read(OWN_DV); if valid(v) then return v end
    v=read(BOX_DV); return valid(v) and v or 0
  end
  local function setChoice(v)
    if not valid(v) then return end
    S.choice=v
    pcall(function() Dvar[H("1e3cb005036e0c0f")](H(OWN_DV,1),tostring(v)) end)
    pcall(function() Engine[H("eb81a5136c5503e4")]("seta mwcf_box_mode "..v, K.ctrl and K.ctrl() or 0) end)
    log("selected "..(v==3 and "MW2" or tostring(v)))
  end
  local ROW_ID = "4d57434600000001"
  local OPT = { id="08b72e07b55c3ac0", sb="7228576e3216368b", type="a79439ef7bfa9c2d",
    name="c4bcadba8e631b86", desc="0cc44970c8397929", labels="4bc513f856980a8a",
    value="7ce4fd9430e80cea", action="6568640b035a56df", def="1230e315819fab00", list="de7843f98867b161" }
  local function same(a,b) return a==b or tostring(a)==tostring(b) end
  local function auto(t)
    local X=rawget(_G,"XHash")
    if type(X)=="table" and type(X.SetAutoXHashMetatable)=="function" then return X.SetAutoXHashMetatable(t,0) or t end
    return t
  end
  local function copy(t)
    local r={};for k,v in pairs(t) do r[k]=v end
    return setmetatable(r,getmetatable(t))
  end
  local function stockMode()
    local stock=read(BOX_DV)
    return stock and stock==math.floor(stock) and stock>=0 and stock<=2 and stock or 0
  end
  local function selectedMode()
    return choice()==3 and 3 or stockMode()
  end
  local function rowData()
    local t,id={},H(ROW_ID,3)
    t[H(OPT.id)]=id;t[H(OPT.sb)]=id;t[H(OPT.def)]=1
    t[H(OPT.name)]="MW2 Mystery Box";t[H(OPT.type)]="ToggleButton"
    t[H(OPT.desc)]="Diagnostic M4 probe: On tests one assembled MW2 M4 with early asset loading. Start with a different weapon. Unready rewards stay stock. Off: use the dropdown above. Wonder weapons are unaffected."
    t[H(OPT.labels)]={"Off","On"}
    t[H(OPT.value)]=function() return choice()==3 and 2 or 1 end
    t[H(OPT.action)]=function(c,v)
      if v==2 then setChoice(3) else
        local stock=read(BOX_DV);setChoice(stock and stock>=0 and stock<=2 and stock or 0)
      end
    end
    return auto(t)
  end
  local kronosIds={}
  for n=0xa1,0xdf do kronosIds[tostring(H(string.format("5a6d0000000000%02x",n),3))]=true end
  local function addRow(groups,outermost)
    local g=type(groups)=="table" and groups[1]
    local items=type(g)=="table" and g[H(OPT.list)]
    if type(items)~="table" then return groups end
    local kept,seen,boxAt={},{},nil
    for _,it in ipairs(items) do
      local sb=type(it)=="table" and it[H(OPT.sb)]
      local key=sb~=nil and tostring(sb)
      if not same(sb,H(ROW_ID,3)) and (outermost or not kronosIds[key]) and (not key or not seen[key]) then
        kept[#kept+1]=it;if key then seen[key]=true end
        if same(sb,H(BOX_ID,3)) then boxAt=#kept end
      end
    end
    table.insert(kept,boxAt and boxAt+1 or #kept+1,auto({[H(OPT.sb)]=H(ROW_ID,3)}))
    local result,group=copy(groups),copy(g)
    group[H(OPT.list)]=setmetatable(kept,getmetatable(items));result[1]=group
    return result
  end
  local dataHooked=setmetatable({},{__mode="k"})
  local listHooks=setmetatable({},{__mode="k"})
  local function extendOptions()
    local O=rawget(_G,"OPTIONS")
    if type(O)~="table" or type(O.TabIds)~="table" or O.TabIds.DEBUG==nil then return false end
    local listKey=H("7bf7f57679e8d050")
    if type(O[listKey])~="function" then return false end
    for _,hex in ipairs({"e7686f7a9907efd8","9f6c4b08602983fb"}) do
      if type(O[H(hex)])~="function" then return false end
    end
    if not dataHooked[O] then
      dataHooked[O]=true
      for _,hex in ipairs({"e7686f7a9907efd8","9f6c4b08602983fb"}) do
        local key=H(hex);local orig=O[key]
        O[key]=function(sb,...)
          if same(sb,H(ROW_ID,3)) then return rowData() end
          return orig(sb,...)
        end
      end
    end
    if O[listKey]~=listHooks[O] then
      local orig=O[listKey];local wrapped
      wrapped=function(tab,c,idx,...)
        local r=pack(orig(tab,c,idx,...))
        if type(tab)=="table" and same(tab[H(OPT.id)],O.TabIds.DEBUG) and type(r[1])=="table" then
          if idx==nil then
            local section=r[1][1]
            if type(section)=="table" and type(section[H(OPT.list)])=="table" then
              local result,sec=copy(r[1]),copy(section)
              sec[H(OPT.list)]=addRow(section[H(OPT.list)],O[listKey]==wrapped);result[1]=sec;r[1]=result
            end
          else r[1]=addRow(r[1],O[listKey]==wrapped) end
        end
        return unpack(r,1,r.n)
      end
      listHooks[O]=wrapped;O[listKey]=wrapped
    end
    if not S.extended then S.extended=true;log("MW2 override row installed") end
    return true
  end
  local function patchLaunch()
    local start=rawget(_G,"LUMEN_ZM_LOCAL_START")
    local req=type(start)=="table" and start.request
    if type(req)~="table" or type(req.record)~="table" then return end
    if req.mwcfBoxMode==selectedMode() and req.mwcfStockBoxMode==stockMode() then return end
    local v,stock=selectedMode(),stockMode();local record,config={},{}
    for k,x in pairs(req.record) do record[k]=x end
    for _,entry in ipairs(req.record.configuration or {}) do
      if type(entry)~="table" or (entry.key~="0x"..OWN_DV and entry.key~="0x"..BOX_DV) then config[#config+1]=entry end
    end
    config[#config+1]={key="0x"..OWN_DV,console_key="#x3"..OWN_DV,kind="string",value=tostring(v),consumer_default="-1",required=false}
    config[#config+1]={key="0x"..BOX_DV,console_key="#x3"..BOX_DV,kind="string",value=tostring(stock),consumer_default="0",required=false}
    record.configuration=config;req.record=record;req.mwcfBoxMode=v;req.mwcfStockBoxMode=stock
  end
  local building,loading={},{}
  local busy=false
  local function install()
    if busy then return end
    busy=true
    local ok,err=pcall(function()
      extendOptions();patchLaunch()
      local MB=rawget(_G,"MenuBuilder")
      if type(MB)=="table" and type(MB.BuildRegisteredType)=="function" and not building[MB] then
        building[MB]=true
        local orig=MB.BuildRegisteredType
        MB.BuildRegisteredType=function(...)
          extendOptions();patchLaunch()
          local r=pack(orig(...));extendOptions();patchLaunch();return unpack(r,1,r.n)
        end
      end
      local P=rawget(_G,"Playlist")
      if type(P)=="table" and not building[P] then
        local key=rawget(P,"DoPlaylistId") and "DoPlaylistId" or (rawget(_G,"CLUA") and CLUA.PushXHash("DoPlaylistId"))
        local orig=key and P[key]
        if type(orig)=="function" then
          building[P]=true
          P[key]=function(...) local r=pack(orig(...));patchLaunch();return unpack(r,1,r.n) end
        end
      end
    end)
    busy=false
    if not ok then log("install error: "..tostring(err)) end
  end
  S.install=install
  for _,key in ipairs({"require","requireUnlessHotload","requirexhash"}) do
    local orig=rawget(_G,key)
    if type(orig)=="function" and not loading[key] then
      loading[key]=true
      rawset(_G,key,function(...) local r=pack(orig(...));install();return unpack(r,1,r.n) end)
    end
  end
  install()
  return true
  end
  -- Mod post scripts can run before ui/LUIFPSCounter creates KRONOS.H.
  -- Keep the bootstrap alive across that first UI module load.
  if not activate() then
    local pending = rawget(_G, "__mwcfBoxBootstrapV1")
    if pending then return end
    local B = { ready = false }
    rawset(_G, "__mwcfBoxBootstrapV1", B)
    local unpack = unpack or table.unpack
    local function pack(...) return {n=select("#",...),...} end
    for _,key in ipairs({"require", "requireUnlessHotload", "requirexhash"}) do
      local orig = rawget(_G,key)
      if type(orig)=="function" then
        rawset(_G,key,function(...)
          local result=pack(orig(...))
          if not B.ready then B.ready=activate() end
          return unpack(result,1,result.n)
        end)
      end
    end
    if type(DebugPrint)=="function" then pcall(DebugPrint,"mwcf box: waiting for KRONOS UI APIs") end
  end
end
