-- CFU stable v1.41: native radio beside Toggle Favorite; request/ack rename bridge.
do
  local K=rawget(_G,"KRONOS")
  if type(K)~="table" or type(K.H)~="function" then return end
  local previous=rawget(_G,"__mwcfWeaponRenamesV1")
  if previous then previous.install();return end
  local H=K.H
  local API={menus=setmetatable({}, {__mode="k"}),builders=setmetatable({}, {__mode="k"})}
  rawset(_G,"__mwcfWeaponRenamesV1",API)
  local unpack=unpack or table.unpack
  local function pack(...) return {n=select("#",...),...} end
  local function get(t,k) if t==nil then return nil end local ok,v=pcall(function() return t[k] end);if ok then return v end end
  local function field(t,hex)
    local v=get(t,H(hex));if v~=nil then return v end
    local alt=string.format("%x",(tonumber(hex:sub(1,1),16)+8)%16)..hex:sub(2)
    return get(t,H(alt))
  end
  local function log(s) pcall(DebugPrint,"k1 [CFU weapon renames] "..tostring(s)) end
  local requestKey,appliedKey=H("3ed27fd8fd0b9c18",1),H("569cabecaded094a",1)
  local function read(key)
    local f=field(rawget(_G,"Dvar"),"254084d7ca2317bb")
    if type(f)~="function" then return nil end
    local ok,v=pcall(f,key);if ok and (v=="0" or v=="1") then return v end
  end
  function API.isEnabled() return read(appliedKey)~="0" end
  local function eligible()
    local E,G=rawget(_G,"Engine"),rawget(_G,"GameModesUtils")
    local front,zm=field(E,"112586a3f4fb490e"),field(G,"589367a5b3c4aa7f")
    local ok,v=pcall(function() return type(front)=="function" and front()==true and type(zm)=="function" and zm()==true end)
    return ok and v==true
  end
  local function request(value,c)
    local f=field(rawget(_G,"Dvar"),"1e3cb005036e0c0f")
    if type(f)=="function" then pcall(f,requestKey,value) end
    if read(requestKey)~=value then
      local exec=field(rawget(_G,"Engine"),"eb81a5136c5503e4")
      if type(exec)=="function" then pcall(exec,'set mwcf_weapon_renames "'..value..'"',c) end
    end
    return read(requestKey)==value
  end
  local function refresh(menu,c)
    local f=field(rawget(_G,"WEAPON"),"651a6c4adce94d00")
    if type(f)=="function" then f(menu,c) end
  end
  local function findFavorite(menu)
    local helper=field(field(menu,"24c364fc7caa3c92"),"321bff04aeb34132")
    local lookup=get(helper,"GetPromptByButtonRef")
    if type(lookup)=="function" then return lookup(helper,H("2688b1dd003f053d")) end
  end
  local function create(builder,menu,state,favorite)
    local requireWidget=rawget(_G,"requireUnlessHotload")
    if type(requireWidget)=="function" then requireWidget(H("42ee0faab80ac6ee",3),H("cb39b96783c9d319")) end
    local button=LUI.UIButton.new()
    button.id="CFUWeaponRenamesRadio"
    -- Position follows the native favorite prompt's right edge and vertical center.
    button:SetAnchorsAndPosition(1,0,0.5,0.5,18,248,-14,14)
    button:SetHandleMouse(true)
    local radio=builder.BuildRegisteredType(H("cb39b96783c9d319"),{controllerIndex=state.controller})
    if not radio or type(radio.SetValue)~="function" then error("native GenericRadio unavailable",0) end
    radio:SetAnchorsAndPosition(0,1,0.5,0.5,0,24,-12,12)
    button:addElement(radio)
    local label=LUI.UIText.new()
    label:SetFont(FONT_HANDLE.PrimaryRegular);label:SetFontSize(16)
    label:SetAlignment(LUI.Alignment.Left)
    label:SetAnchorsAndPosition(0,0,0,0,30,0,0,0)
    label:setText("WEAPON RENAMES",0);button:addElement(label)
    button:addEventHandler(H("e7eefe998522ec88"),function(_,event)
      if state.closed or state.pending or not eligible() then return end
      if event and event.controller~=nil and event.controller~=state.controller then return end
      local current=read(requestKey)
      if not current or not read(appliedKey) then return end
      local value=current=="1" and "0" or "1"
      if request(value,state.controller) then
        state.pending=value;button:SetButtonDisabled(true);label:setText("WEAPON RENAMES...",0)
      else log("setting request rejected") end
      return true
    end)
    favorite:addElement(button)
    state.button,state.radio,state.label,state.favorite=button,radio,label,favorite
    log("native GenericRadio attached to the right of Toggle Favorite")
  end
  local function attach(builder,menu,c)
    if not menu or API.menus[menu] or not eligible() or menu._forShowcase then return end
    local state={controller=c or menu._controllerIndex or 0}
    API.menus[menu]=state
    menu:addEventHandler(H("40c83bfa5eb0de2b"),function() state.closed=true end)
    local function tick()
      if state.closed then return end
      local ok,err=pcall(function()
        local favorite=findFavorite(menu)
        if favorite and favorite~=state.favorite then
          if state.button then state.button:close() end
          create(builder,menu,state,favorite)
        end
        if state.radio then
          local wanted,applied=read(requestKey),read(appliedKey)
          if state.lastApplied~=applied then
            state.radio:SetValue(applied=="1");state.lastApplied=applied
          end
          state.button:SetButtonDisabled(not wanted or not applied or state.pending~=nil)
          if state.pending and applied==state.pending then
            state.pending=nil;state.label:setText("WEAPON RENAMES",0)
            state.button:SetButtonDisabled(false)
            refresh(menu,state.controller)
            log("applied "..(applied=="1" and "on" or "off").."; weapon picker refreshed")
          end
        end
      end)
      if not ok and not state.reported then state.reported=true;log(err) end
      if not state.closed then menu:Wait(100).onComplete=tick end
    end
    tick()
  end
  function API.install()
    local builder=rawget(_G,"MenuBuilder")
    if type(builder)~="table" or type(builder.BuildRegisteredType)~="function" or API.builders[builder] then return end
    local original=builder.BuildRegisteredType
    builder.BuildRegisteredType=function(ref,...)
      local r=pack(original(ref,...))
      if ref=="WeaponBaseSelect" or ref=="weaponbaseselect" or ref==H("44300646996dd154") or ref==H("c4300646996dd154") then
        local options=(...);local c=type(options)=="table" and options.controllerIndex or nil
        local ok,err=pcall(attach,builder,r[1],c);if not ok then log(err) end
      end
      return unpack(r,1,r.n)
    end
    API.builders[builder]=true
  end
  API.install()
  for _,name in ipairs({"require","requireUnlessHotload","requirexhash"}) do
    local original=rawget(_G,name)
    if type(original)=="function" then rawset(_G,name,function(...)
      local r=pack(original(...));API.install();return unpack(r,1,r.n)
    end) end
  end
end
