local function a(b,c,d,...)if not b then error(string.format(d,...),c)end end;local e={rage={"aimbot","other"},aa={"anti-aimbot angles","fake lag","other"},legit={"weapon type","aimbot","triggerbot","other"},visuals={"player esp","other esp","colored models","effects"},misc={"miscellaneous","settings","lua","other"},skins={"weapon skin","knife options","glove options"},config={"presets","lua"},players={"players","adjustments"},lua={"a","b"}}for f,g in pairs(e)do e[f]={}for h=1,#g do e[f][g[h]]=true end end;local i={}local j={__index=i}function j.__call(k,...)local l={...}if#l==0 then return k:get()end;local m={pcall(k.set,k,unpack(l))}a(m[1],4,m[2])return k end;function i.new(n,f,o,p,...)local q;local r=false;if type(n)=="function"then local s={pcall(n,f,o,p,...)}a(s[1],4,"Cannot create menu item because: %s",s[2])q=s[2]else q=n;r=true end;return setmetatable({tab=f,container=o,name=p,reference=q,visible=true,hidden_value=nil,children={},ui_callback=nil,callbacks={},is_menu_reference=r,getter={callback=nil,data=nil},setter={callback=nil,data=nil},parent_value_or_callback=nil},j)end;function i:set_hidden_value(t)self.hidden_value=t end;function i:set(...)local l={...}if self.setter.callback~=nil then l=self.setter.callback(unpack(l))end;local m={pcall(ui.set,self.reference,unpack(l))}a(m[1],3,"Cannot set values of menu item because: %s",m[2])end;function i:get()if self.visible==false and self.hidden_value~=nil then return self.hidden_value end;local u={ui.get(self.reference)}if self.getter.callback~=nil then return self.getter.callback(u)end;return unpack(u)end;function i:set_setter_callback(v,w)a(type(v)=="function",3,"Cannot set menu item setter callback: argument must be a function.")self.setter.callback=v;self.setter.data=w end;function i:set_getter_callback(v,w)a(type(v)=="function",3,"Cannot set menu item getter callback: argument must be a function.")self.getter.callback=v;self.getter.data=w end;function i:add_children(x,y)if y==nil then y=true end;if getmetatable(x)==j then x={x}end;for z,A in pairs(x)do a(getmetatable(A)==j,3,"Cannot add child to menu item: children must be menu item objects. Make sure you are not trying to parent a UI reference.")a(A.reference~=self.reference,3,"Cannot parent a menu item to iself.")A.parent_value_or_callback=y;self.children[A.reference]=A end;i._process_callbacks(self)end;function i:add_callback(v)a(self.is_menu_reference==false,3,"Cannot add callbacks to built-in menu items.")a(type(v)=="function",3,"Callbacks for menu items must be functions.")table.insert(self.callbacks,v)i._process_callbacks(self)end;function i._process_callbacks(k)local v=function()for z,A in pairs(k.children)do local B;if type(A.parent_value_or_callback)=="function"then B=A.parent_value_or_callback()else B=k:get()==A.parent_value_or_callback end;local C=B==true and k.visible==true;A.visible=C;ui.set_visible(A.reference,C)if A.ui_callback~=nil then A.ui_callback()end end;for h=1,#k.callbacks do k.callbacks[h]()end end;ui.set_callback(k.reference,v)k.ui_callback=v;v()end;local D={}local E={__index=D}function D.new(f,o)D._validate_tab_container(f,o)return setmetatable({tab=f,container=o,children={}},E)end;function D:save_to_db()local F=string.format("%s_%s",self.tab,self.container)for z,k in pairs(self.children)do local G=string.format("%s_%s",F,k.name)local w={k()}database.write(G,w)end end;function D:load_from_db()local F=string.format("%s_%s",self.tab,self.container)for z,k in pairs(self.children)do local G=string.format("%s_%s",F,k.name)local w=database.read(G)if w~=nil then k(unpack(w))end end end;function D:parent_all_to(k,y)local x=self.children;x[k.reference]=nil;k:add_children(x,y)end;function D.reference(f,o,p)D._validate_tab_container(f,o)local H={pcall(ui.reference,f,o,p)}a(H[1],3,"Cannot reference Gamesense menu item because: %s",H[2])local I={select(2,unpack(H))}local J={}for h=1,#I do table.insert(J,i.new(I[h],f,o,p))end;return unpack(J)end;function D:checkbox(p)return self:_create_item(ui.new_checkbox,p)end;function D:slider(p,K,L,M,N,O,P,Q)if type(M)=="table"then local R=M;M=R.default;N=R.show_tooltip;O=R.unit;P=R.scale;Q=R.tooltips end;M=M or nil;N=N or true;O=O or nil;P=P or 1;Q=Q or nil;a(type(K)=="number",3,"Slider min value must be a number.")a(type(L)=="number",3,"Slider max value must be a number.")a(K<L,3,"Slider min value must be below the max value.")if M~=nil then a(M>=K and M<=L,3,"Slider default must be between min and max values.")end;return self:_create_item(ui.new_slider,p,K,L,M,N,O,P,Q)end;function D:combobox(p,...)local l={...}if type(l[1])=="table"then l=l[1]end;return self:_create_item(ui.new_combobox,p,l)end;function D:multiselect(p,...)local l={...}if type(l[1])=="table"then l=l[1]end;return self:_create_item(ui.new_multiselect,p,l)end;function D:hotkey(p,S)if S==nil then S=false end;a(type(S)=="boolean",3,"Hotkey inline argument must be a boolean.")return self:_create_item(ui.new_hotkey,p,S)end;function D:button(p,v)a(type(v)=="function",3,"Cannot set button callback because the callback argument must be a function.")return self:_create_item(ui.new_button,p,v)end;function D:color_picker(p,T,U,V,W)T=T or 255;U=U or 255;V=V or 255;W=W or 255;a(type(T)=="number"and T>=0 and T<=255,3,"Cannot set color picker red channel value. It must be between 0 and 255.")a(type(U)=="number"and U>=0 and U<=255,3,"Cannot set color picker green channel value. It must be between 0 and 255.")a(type(V)=="number"and V>=0 and V<=255,3,"Cannot set color picker blue channel value. It must be between 0 and 255.")a(type(W)=="number"and W>=0 and W<=255,3,"Cannot set color picker alpha channel value. It must be between 0 and 255.")return self:_create_item(ui.new_color_picker,p,T,U,V,W)end;function D:textbox(p)return self:_create_item(ui.new_textbox,p)end;function D:listbox(p,...)local l={...}if type(l[1])=="table"then l=l[1]end;local k=self:_create_item(ui.new_listbox,p,l)k:set_getter_callback(function(u)return k.getter.data[u+1]end,l)return k end;function D:label(p)a(type(p)=="string","Label name must be a string.")return self:_create_item(ui.new_label,p)end;function D:_create_item(n,p,...)a(type(p)=="string"and p~="",3,"Cannot create menu item: name must be a non-empty string.")local k=i.new(n,self.tab,self.container,p,...)self.children[k.reference]=k;return k end;function D._validate_tab_container(f,o)a(type(f)=="string"and f~="",4,"Cannot create menu manager: tab name must be a non-empty string.")a(type(o)=="string"and o~="",4,"Cannot create menu manager: tab name must be a non-empty string.")f=f:lower()a(e[f]~=nil,4,"Cannot create menu manager: tab name does not exist.")a(e[f][o:lower()]~=nil,4,"Cannot create menu manager: container name does not exist.")end;local X={}local Y={__index=X}function X.new()return setmetatable({delta=0,screen_x=0,screen_y=0,vignette_size=0,vignette_intensity=0,vignette_target_intensity=0,vignette_max_size=0,screen_opacity=0,screen_target_opacity=0},Y)end;function X:sync()self.delta=globals.absoluteframetime()*100;self.screen_x,self.screen_y=client.screen_size()end;function X:hurt(Z)self.screen_opacity=(1-(100-Z)/100)*150 end;function X:render()self:sync()self:vignette()self:screen()end;function X:vignette()local _=entity.get_prop(entity.get_local_player(),"m_iHealth")if entity.is_alive(entity.get_local_player())==false then _=100 end;local a0=(0-(_-100)/100)*50;local a1=math.min(200,math.max(0,a0+math.sin(globals.realtime()*math.pi*0.75)*(100-_)*0.2))local a2=self.screen_y/1.33;local a3=(0-(_-100)/100)*a2;self.vignette_intensity=self.vignette_intensity+(a1-self.vignette_intensity)*0.02*self.delta;renderer.gradient(0,0,self.screen_x,a3,255,10,10,self.vignette_intensity,255,10,10,0,false)renderer.gradient(0,self.screen_y-a3,self.screen_x,a3,255,10,10,0,255,10,10,self.vignette_intensity,false)renderer.gradient(0,0,a3,self.screen_y,255,10,10,self.vignette_intensity,255,10,10,0,true)renderer.gradient(self.screen_x-a3,0,a3,self.screen_y,255,10,10,0,255,10,10,self.vignette_intensity,true)end;function X:screen()self.screen_opacity=self.screen_opacity+(self.screen_target_opacity-self.screen_opacity)*0.005*self.delta;renderer.rectangle(0,0,self.screen_x,self.screen_y,255,10,10,self.screen_opacity)end;local a4=X.new()local a5=D.new("config","presets")a5:label("--------------------------------------------------")a5:label("Bleeding - v1.0.2")local a6=a5:checkbox("Enable Bleeding")a5:load_from_db()client.set_event_callback("paint",function()if a6()==false then return end;a4:render()end)client.set_event_callback("player_hurt",function(w)if a6()==false then return end;local a7=client.userid_to_entindex(w.userid)local a8=entity.get_local_player()if a7~=a8 then return end;a4:hurt(w.dmg_health)end)client.set_event_callback("shutdown",function()a5:save_to_db()end)