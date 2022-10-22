--region dependencies
--- Convert hex to binary data.
--- @return string
local function hex_to_bin(hex)
	return (hex:gsub('..', function (cc)
		return string.char(tonumber(cc, 16))
	end))
end

--region dependency: havoc_menu_1_3_0
--region menu_assert
--- Assert.
--- @param expression boolean
--- @param level number
--- @param message string
--- @vararg string
--- @return void
local function menu_assert(expression, level, message, ...)
	if (not expression) then
		error(string.format(message, ...), level)
	end
end
--endregion

--region menu_map
local menu_map = {
	rage = {"aimbot", "other"},
	aa = {"anti-aimbot angles", "fake lag", "other"},
	legit = {"weapon type", "aimbot", "triggerbot", "other"},
	visuals = {"player esp", "other esp", "colored models", "effects"},
	misc = {"miscellaneous", "settings", "lua", "other"},
	skins = {"weapon skin", "knife options", "glove options"},
	config = {"presets", "lua"},
	players = {"players", "adjustments"},
	lua = {"a", "b"}
}

for tab, containers in pairs(menu_map) do
	menu_map[tab] = {}

	for i=1, #containers do
		menu_map[tab][containers[i]] = true
	end
end
--endregion

--region menu_item
--- @class menu_item_c
--- @field public tab string
--- @field public container string
--- @field public name string
--- @field public reference number
--- @field public visible boolean
--- @field public hidden_value any
--- @field public children table<number, menu_item_c>
--- @field public ui_callback function
--- @field public getter table
--- @field public setter table
--- @field public parent_value_or_callback any|function
local menu_item_c = {}

local menu_item_mt = {
	__index = menu_item_c
}

--- @param item menu_item_c
--- @vararg any
--- @return menu_item_c|any
function menu_item_mt.__call(item, ...)
	local args = {...}

	if (#args == 0) then
		return item:get()
	end

	local do_ui_set = {pcall(item.set, item, unpack(args))}

	menu_assert(do_ui_set[1], 4, do_ui_set[2])

	return item
end

--- Create a new menu_item_c.
--- @param element function
--- @param tab string
--- @param container string
--- @param name string
--- @vararg any
--- @return menu_item_c
function menu_item_c.new(element, tab, container, name, ...)
	local reference
	local is_menu_reference = false

	if ((type(element)) == "function") then
		local do_ui_new = { pcall(element, tab, container, name, ...)}

		menu_assert(do_ui_new[1], 4, "Cannot create menu item because: %s", do_ui_new[2])

		reference = do_ui_new[2]
	else
		reference = element
		is_menu_reference = true
	end

	return setmetatable(
		{
			tab = tab,
			container = container,
			name = name,
			reference = reference,
			visible = true,
			hidden_value = nil,
			children = {},
			ui_callback = nil,
			callbacks = {},
			is_menu_reference = is_menu_reference,
			getter = {
				callback = nil,
				data = nil
			},
			setter = {
				callback = nil,
				data = nil
			},
			parent_value_or_callback = nil
		},
		menu_item_mt
	)
end

--- @param value any
--- @return void
function menu_item_c:set_hidden_value(value)
	self.hidden_value = value
end

--- @vararg any
--- @return void
function menu_item_c:set(...)
	local args = {...}

	if (self.setter.callback ~= nil) then
		args = self.setter.callback(unpack(args))
	end

	local do_ui_set = {pcall(ui.set, self.reference, unpack(args))}

	menu_assert(do_ui_set[1], 3, "Cannot set values of menu item because: %s", do_ui_set[2])
end

--- @return any
function menu_item_c:get()
	if (self.visible == false and self.hidden_value ~= nil) then
		return self.hidden_value
	end

	local get = {ui.get(self.reference)}

	if (self.getter.callback ~= nil) then
		return self.getter.callback(get)
	end

	return unpack(get)
end

--- @param callback function
--- @param data any
--- @return void
function menu_item_c:set_setter_callback(callback, data)
	menu_assert(type(callback) == "function", 3, "Cannot set menu item setter callback: argument must be a function.")

	self.setter.callback = callback
	self.setter.data = data
end

--- @param callback function
--- @param data any
--- @return void
function menu_item_c:set_getter_callback(callback, data)
	menu_assert(type(callback) == "function", 3, "Cannot set menu item getter callback: argument must be a function.")

	self.getter.callback = callback
	self.getter.data = data
end

--- @param children table<any, menu_item_c>
--- @param value_or_callback function|any
--- @return void
function menu_item_c:add_children(children, value_or_callback)
	if (value_or_callback == nil) then
		value_or_callback = true
	end

	if (getmetatable(children) == menu_item_mt) then
		children = {children}
	end

	for _, child in pairs(children) do
		menu_assert(getmetatable(child) == menu_item_mt, 3, "Cannot add child to menu item: children must be menu item objects. Make sure you are not trying to parent a UI reference.")
		menu_assert(child.reference ~= self.reference, 3, "Cannot parent a menu item to iself.")

		child.parent_value_or_callback = value_or_callback
		self.children[child.reference] = child
	end

	menu_item_c._process_callbacks(self)
end

--- @param callback function
--- @return void
function menu_item_c:add_callback(callback)
	menu_assert(self.is_menu_reference == false, 3, "Cannot add callbacks to built-in menu items.")
	menu_assert(type(callback) == "function", 3, "Callbacks for menu items must be functions.")

	table.insert(self.callbacks, callback)

	menu_item_c._process_callbacks(self)
end

--- @param item menu_item_c
--- @return void
function menu_item_c._process_callbacks(item)
	local callback = function()
		for _, child in pairs(item.children) do
			local is_child_visible

			if (type(child.parent_value_or_callback) == "function") then
				is_child_visible = child.parent_value_or_callback()
			else
				is_child_visible = item:get() == child.parent_value_or_callback
			end

			local is_visible = (is_child_visible == true) and (item.visible == true)
			child.visible = is_visible

			ui.set_visible(child.reference, is_visible)

			if (child.ui_callback ~= nil) then
				child.ui_callback()
			end
		end

		for i = 1, #item.callbacks do
			item.callbacks[i]()
		end
	end

	ui.set_callback(item.reference, callback)
	item.ui_callback = callback

	callback()
end
--endregion

--region menu_manager
--- @class menu_manager_c
--- @field public tab string
--- @field public container string
--- @field public children table<number, menu_item_c>
local menu_manager_c = {}

local menu_manager_mt = {
	__index = menu_manager_c
}

--- Create a new menu_manager_c.
--- @param tab string
--- @param container string
--- @return menu_manager_c
function menu_manager_c.new(tab, container)
	menu_manager_c._validate_tab_container(tab, container)

	return setmetatable(
		{
			tab = tab,
			container = container,
			children = {}
		},
		menu_manager_mt
	)
end

--- Saves the values for menu items currently created to the database.
--- @return void
function menu_manager_c:save_to_db()
	local prefix = string.format("%s_%s", self.tab, self.container)

	for _, item in pairs(self.children) do
		local key = string.format("%s_%s", prefix, item.name)
		local data = {item()}

		database.write(key, data)
	end
end

--- Loads the values for menu items currently created from to the database.
--- @return void
function menu_manager_c:load_from_db()
	local prefix = string.format("%s_%s", self.tab, self.container)

	for _, item in pairs(self.children) do
		local key = string.format("%s_%s", prefix, item.name)
		local data = database.read(key)

		if (data ~= nil) then
			item(unpack(data))
		end
	end
end

--- @param item menu_item_c
--- @param value_or_callback function|any
--- @return void
function menu_manager_c:parent_all_to(item, value_or_callback)
	local children = self.children

	children[item.reference] = nil

	item:add_children(children, value_or_callback)
end

--- @param tab string
--- @param container string
--- @param name string
--- @return menu_item_c
function menu_manager_c.reference(tab, container, name)
	menu_manager_c._validate_tab_container(tab, container)

	local do_reference = {pcall(ui.reference, tab, container, name)}

	menu_assert(do_reference[1], 3, "Cannot reference Gamesense menu item because: %s", do_reference[2])

	local references = {select(2, unpack(do_reference))}
	local items = {}

	for i = 1, #references do
		table.insert(
			items,
			menu_item_c.new(
				references[i],
				tab,
				container,
				name
			)
		)
	end

	return unpack(items)
end

--- @param name string
--- @return menu_item_c
function menu_manager_c:checkbox(name)
	return self:_create_item(ui.new_checkbox, name)
end

--- @param name string
--- @param min number
--- @param max number
--- @param default_or_options number|table<any, any>
--- @return menu_item_c
function menu_manager_c:slider(name, min, max, default_or_options, show_tooltip, unit, scale, tooltips)
	if (type(default_or_options) == "table") then
		local options = default_or_options

		default_or_options = options.default
		show_tooltip = options.show_tooltip
		unit = options.unit
		scale = options.scale
		tooltips = options.tooltips
	end

	default_or_options = default_or_options or nil
	show_tooltip = show_tooltip or true
	unit = unit or nil
	scale = scale or 1
	tooltips = tooltips or nil

	menu_assert(type(min) == "number", 3, "Slider min value must be a number.")
	menu_assert(type(max) == "number", 3, "Slider max value must be a number.")
	menu_assert(min < max, 3, "Slider min value must be below the max value.")

	if (default_or_options ~= nil) then
		menu_assert(default_or_options >= min and default_or_options <= max, 3, "Slider default must be between min and max values.")
	end

	return self:_create_item(ui.new_slider, name, min, max, default_or_options, show_tooltip, unit, scale, tooltips)
end

--- @param name string
--- @vararg string
--- @return menu_item_c
function menu_manager_c:combobox(name, ...)
	local args = {...}

	if (type(args[1]) == "table") then
		args = args[1]
	end

	return self:_create_item(ui.new_combobox, name, args)
end

--- @param name string
--- @vararg string
--- @return menu_item_c
function menu_manager_c:multiselect(name, ...)
	local args = {...}

	if (type(args[1]) == "table") then
		args = args[1]
	end

	return self:_create_item(ui.new_multiselect, name, args)
end

--- @param name string
--- @param inline boolean
--- @return menu_item_c
function menu_manager_c:hotkey(name, inline)
	if (inline == nil) then
		inline = false
	end

	menu_assert(type(inline) == "boolean", 3, "Hotkey inline argument must be a boolean.")

	return self:_create_item(ui.new_hotkey, name, inline)
end

--- @param name string
--- @param callback function
--- @return menu_item_c
function menu_manager_c:button(name, callback)
	menu_assert(type(callback) == "function", 3, "Cannot set button callback because the callback argument must be a function.")

	return self:_create_item(ui.new_button, name, callback)
end

--- @param name string
--- @param r number
--- @param g number
--- @param b number
--- @param a number
--- @return menu_item_c
function menu_manager_c:color_picker(name, r, g, b, a)
	r = r or 255
	g = g or 255
	b = b or 255
	a = a or 255

	menu_assert(type(r) == "number" and r >= 0 and r <= 255, 3, "Cannot set color picker red channel value. It must be between 0 and 255.")
	menu_assert(type(g) == "number" and g >= 0 and g <= 255, 3, "Cannot set color picker green channel value. It must be between 0 and 255.")
	menu_assert(type(b) == "number" and b >= 0 and b <= 255, 3, "Cannot set color picker blue channel value. It must be between 0 and 255.")
	menu_assert(type(a) == "number" and a >= 0 and a <= 255, 3, "Cannot set color picker alpha channel value. It must be between 0 and 255.")

	return self:_create_item(ui.new_color_picker, name, r, g, b, a)
end

--- @param name string
--- @return menu_item_c
function menu_manager_c:textbox(name)
	return self:_create_item(ui.new_textbox, name)
end

--- @param name string
--- @vararg string
--- @return menu_item_c
function menu_manager_c:listbox(name, ...)
	local args = {...}

	if (type(args[1]) == "table") then
		args = args[1]
	end

	local item = self:_create_item(ui.new_listbox, name, args)

	item:set_getter_callback(
		function(get)
			return item.getter.data[get + 1]
		end,
		args
	)

	return item
end

--- @param name string
--- @return menu_item_c
function menu_manager_c:label(name)
	menu_assert(type(name) == "string", "Label name must be a string.")

	return self:_create_item(ui.new_label, name)
end

--- @param element function
--- @param name string
--- @vararg any
--- @return menu_item_c
function menu_manager_c:_create_item(element, name, ...)
	menu_assert(type(name) == "string" and name ~= "", 3, "Cannot create menu item: name must be a non-empty string.")

	local item = menu_item_c.new(element, self.tab, self.container, name, ...)
	self.children[item.reference] = item

	return item
end

--- @param tab string
--- @param container string
--- @return void
function menu_manager_c._validate_tab_container(tab, container)
	menu_assert(type(tab) == "string" and tab ~= "", 4, "Cannot create menu manager: tab name must be a non-empty string.")
	menu_assert(type(container) == "string" and container ~= "", 4, "Cannot create menu manager: tab name must be a non-empty string.")

	tab = tab:lower()

	menu_assert(menu_map[tab] ~= nil, 4, "Cannot create menu manager: tab name does not exist.")
	menu_assert(menu_map[tab][container:lower()] ~= nil, 4, "Cannot create menu manager: container name does not exist.")
end
--endregion
--endregion
--endregion

--region emmydoc
--- @class weather_mode_c
--- @field public render fun(self: weather_mode_c, boundary_manager: weather_boundary_manager_c): void
--endregion

--region setup
local illusion = require("havoc_illusion")("havoc weather")
--endregion

--region weather_boundary
--- @class weather_boundary_c
--- @field public sky_z number
--- @field public cull_z number
local weather_boundary_c = {}
local weather_boundary_mt = { __index = weather_boundary_c }

--- Instantiate an object of weather_boundary_c.
--- @return weather_boundary_c
local function weather_boundary(sky_z, cull_z)
	return weather_boundary_c.new(sky_z, cull_z)
end

--- Instantiate an object of weather_boundary_c.
--- @return weather_boundary_c
function weather_boundary_c.new(sky_z)
	return setmetatable({
		sky_z = sky_z
	}, weather_boundary_mt)
end
--endregion

--region weather_boundary_manager
--- @class weather_boundary_manager_c
--- @field public current weather_boundary_c
--- @field public default weather_boundary_c
--- @field public boundaries table<string, weather_boundary_c>
local weather_boundary_manager_c = {}
local weather_boundary_manager_mt = { __index = weather_boundary_manager_c }

--- Instantiate an object of weather_boundary_manager_c.
--- @return weather_boundary_manager_c
function weather_boundary_manager_c.new()
	return setmetatable({
		current = nil,
		default = weather_boundary(1000),
		boundaries = {
			["de_dust2"] = weather_boundary(710),
			["de_mirage"] = weather_boundary(1200),
			["de_mirage_scrimmagemap"] = weather_boundary(1200),
			["de_inferno"] = weather_boundary(570),
			["de_vertigo"] = weather_boundary(12800),
			["de_cbble"] = weather_boundary(1200),
			["de_cache"] = weather_boundary(2400),
			["de_train"] = weather_boundary(1000),
			["de_overpass"] = weather_boundary(1000),
			["de_nuke"] = weather_boundary(700),
			["de_canals"] = weather_boundary(1000),
			["cs_agency"] = weather_boundary(1000),
			["cs_office"] = weather_boundary(650),
			["cs_italy"] = weather_boundary(840),
			["cs_assault"] = weather_boundary(630),
			["workshop/141243798/aim_ag_texture2"] = weather_boundary(1000)
		}
	}, weather_boundary_manager_mt)
end

--- Update current boundary.
--- @return void
function weather_boundary_manager_c:sync()
	local map = globals.mapname()

	if (self.boundaries[map] ~= nil) then
		self.current = self.boundaries[map]
	else
		self.current = self.default
	end
end
--endregion

--region weather_mode_snow
--- @class weather_mode_snow_c : weather_mode_c
--- @field public shader shader_c
--- @field public max_snowflakes number
--- @field public sticky boolean
--- @field public speed number
--- @field public density number
--- @field public radius number
--- @field public texture string
local weather_mode_snow_c = {}
local weather_mode_snow_mt = { __index = weather_mode_snow_c }

--- Instantiate an object of weather_mode_snow_c.
--- @return weather_mode_snow_c
function weather_mode_snow_c.new()
	return setmetatable({
		shader = illusion.shader.rgb(220, 220, 220, 200),
		max_snowflakes = 2048,
		sticky = false,
		speed = 1,
		density = 1,
		radius = 1000,
		texture = renderer.load_png(
			hex_to_bin("89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7AF4000000097048597300000B1300000B1301009A9C18000005B869545874584D4C3A636F6D2E61646F62652E786D7000000000003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B633964223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D2241646F626520584D5020436F726520352E362D633134322037392E3136303932342C20323031372F30372F31332D30313A30363A33392020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264663A61626F75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F2220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D6C6E733A73744576743D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F5265736F757263654576656E74232220786D6C6E733A64633D22687474703A2F2F7075726C2E6F72672F64632F656C656D656E74732F312E312F2220786D6C6E733A70686F746F73686F703D22687474703A2F2F6E732E61646F62652E636F6D2F70686F746F73686F702F312E302F2220786D703A43726561746F72546F6F6C3D2241646F62652050686F746F73686F702043432032303138202857696E646F7773292220786D703A437265617465446174653D22323032302D30322D32315431343A31343A30325A2220786D703A4D65746164617461446174653D22323032302D30322D32315431343A31343A30325A2220786D703A4D6F64696679446174653D22323032302D30322D32315431343A31343A30325A2220786D704D4D3A496E7374616E636549443D22786D702E6969643A30306161336432652D613865362D346134662D383934382D6539303737306465663930642220786D704D4D3A446F63756D656E7449443D2261646F62653A646F6369643A70686F746F73686F703A34626131363065372D623332372D323034632D383162332D6266616139313135646332382220786D704D4D3A4F726967696E616C446F63756D656E7449443D22786D702E6469643A35666235316332612D626661642D363334332D393536662D373461653835613633633531222064633A666F726D61743D22696D6167652F706E67222070686F746F73686F703A436F6C6F724D6F64653D2233223E203C786D704D4D3A486973746F72793E203C7264663A5365713E203C7264663A6C692073744576743A616374696F6E3D2263726561746564222073744576743A696E7374616E636549443D22786D702E6969643A35666235316332612D626661642D363334332D393536662D373461653835613633633531222073744576743A7768656E3D22323032302D30322D32315431343A31343A30325A222073744576743A736F6674776172654167656E743D2241646F62652050686F746F73686F702043432032303138202857696E646F777329222F3E203C7264663A6C692073744576743A616374696F6E3D227361766564222073744576743A696E7374616E636549443D22786D702E6969643A30306161336432652D613865362D346134662D383934382D653930373730646566393064222073744576743A7768656E3D22323032302D30322D32315431343A31343A30325A222073744576743A736F6674776172654167656E743D2241646F62652050686F746F73686F702043432032303138202857696E646F777329222073744576743A6368616E6765643D222F222F3E203C2F7264663A5365713E203C2F786D704D4D3A486973746F72793E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3E6C771F590000039C4944415458857D97DB6EE34610440F4949966427B0B38B0DF2FFDF9687204836F6AE645D28310F532516C794090C78999EAEEA9EBE0C9B611898B99AEAB9D33DC7005C35E6945866A8E627B28B3B0B9B785E68B47A6F43F60A5C80FE0E09349F649A94AD09CC81AF281E48F64D7CBB4AAE9FD193E0E92D630C8B6A01715F000F15C94B05D26ADE6017115BE8DE03A718267CDB969AC010CFE9FA7BFBDCC558486609AC818DF4EC8157E00DD801E75460F6B6BA0D651B8AFB3390AE61F95263254FADE3DB167892DC0FCD77D23121610209BE14F8B316DA43197C26B910F03648747A5E89700B1C04DAC7B8024D6E81C197C0AFC03759B1128095276107A9EF4BA601E7BDB7CC56644EF66A6E81493C48F05924BE00BF01BF842B1D2F4EC19B45FA7E1450236FD6DBF32E129318B05B2DF40CFC01FC2E12CF2261AFD8C29F1ABBCAE256641E34325E9CDA7DBD0526B011E837013FEAFE157891458D2CDF5302ED2DC681317BDE436F578DBE4EC356632DA01779C304BEE8DDCA0679E4451EF80EFC2D12C81B75A66521BAE579CB94C446EEF6FE3D5102D3E06D28EA98A6AF951F98A65FD6915B45AC83D0D67F95C54EB1273DCFF50E18EBC26380ED80FFB426ABDF4045808AC0A3ACB7A5DEAFEC90F565EBBCFE0AFC139EB2D56E5E177F4F0104B4D6B713A5789CF5DC33F682B9B29C8D6A4BD93E181B92091C18BBE7AD195DC3824E8B8E1ACB20602559156B1203633372ADF0FD1C046E8019206D2C3C31160C77352BFBEC2062B00BA3CB2DB79351FE36D441E54AD60B7C4389E4BD166F6445C6CCDC29C9D5D0E48FD2B7D7FA0F41E88526E105EF942D78A554AF0B63DBB5AC53D1BD04C9FD4B295006AEC12194D5EDF64829AF0F8CDB74151103A46B5DE9DC824FC09F944C781378069FAF2109B8B1D86D6F017ED216B807F4B2C6444CC27DE20CFC45A9038E23EBCD986B6A02B6FC49EF07016F9946B6099CB46610F0637875C71874E79033F8E448E668DD53F66ECDD8705E194B2A8C4DC635C256B9DDBA2A129EF329C8D973BBCCD685E24869282B79A1AB1664B4F733734E631FE77AC6F3E025E46FC7F3DC027BE19D123C277901226FF998E70647962F6488097C9767538749906968A0462EF381631932067520E631DD043A8ABB3B4A0CFD642C6235099AF835CBE29279ED54AC49641A7A6E113A06C640CDEA99DB36CC11A8C9F8CCE0EFA9A42690E0931F9099F759027987B1D4D6F39FFD74D61DD6E035E10F049248DDFBE7BECD593F37F7E9FBDC09E7DE5FEE674A9B99F97BD744EE7F21E2A5CE065149E30000000049454E44AE426082"),
			32,
			32
		)
	}, weather_mode_snow_mt)
end

--- Render snow.
--- @param boundary weather_boundary_c
--- @return void
function weather_mode_snow_c:render(boundary)
	if (illusion.hook.total_alive > self.max_snowflakes) then
		illusion.hook:cull()
	end

	if (boundary == nil) then
		return
	end

	local spawn_margin = client.random_int(self.density, 40)

	if (spawn_margin > self.density) then
		return
	end

	for _ = 1, self.density do
		local spawn_vector = illusion.shared.player_camera_position + illusion.vector(
			client.random_float(-self.radius, self.radius),
			client.random_float(-self.radius, self.radius),
			client.random_float(-self.radius, self.radius) / 2
		)

		local sky_vector = illusion.vector(spawn_vector.x, spawn_vector.y, boundary.sky_z)
		local can_spawn_trace = sky_vector:trace_line_to(spawn_vector)

		if (can_spawn_trace == 1) then
			local snowflake = illusion:create()

			local size = client.random_int(8, 22)

			snowflake.origin = spawn_vector
			snowflake.shader = self.shader:clone()
			snowflake.type = "texture"
			snowflake.texture = self.texture
			snowflake.width = size
			snowflake.height = size
			snowflake.fade_time = 2
			snowflake.landed = false
			snowflake.landing_vector = illusion.vector(0, 0, 0)
			snowflake.floating_vector = illusion.vector(0, 0, -0.25)
			snowflake.floating_timer = illusion.timer_tick(true, {
				adjust_after = client.random_int(16, 32)
			})

			local impact_trace_vector = snowflake.origin:clone_offset(0, 0, -32768)
			local floor_trace = snowflake.origin:trace_line_to(impact_trace_vector)

			snowflake.impact_z = snowflake.origin.z - (32768 * floor_trace) + 1
			snowflake.shader.a = 0
			snowflake.target_alpha = 100

			snowflake.on_frame = function()
				if (snowflake.origin.z <= snowflake.impact_z) then
					if (self.sticky == true) then
						local impact_trace_vector = snowflake.origin:clone_offset(0, 0, -32768)
						local floor_trace = snowflake.origin:trace_line_to(impact_trace_vector)

						snowflake.origin.z = snowflake.origin.z - (32768 * floor_trace) + 1
						snowflake.landed = true

						snowflake:kill()
					else
						snowflake:kill()
					end
				end

				snowflake.shader.a = snowflake.shader.a + (snowflake.target_alpha - snowflake.shader.a) * 0.02 * illusion.simulation.delta

				if (snowflake.relation_camera_distance > self.radius) then
					snowflake.fade_time = 0.25

					snowflake:kill()
				end

				if (snowflake.landed == true and snowflake.occluded == true) then
					snowflake.dead = true

					return
				end

				snowflake.floating_timer:event(snowflake.floating_timer.adjust_after, function(timer)
					snowflake.floating_vector(
						client.random_float(-0.1, 0.1),
						client.random_float(-0.1, 0.1),
						client.random_float(-0.33, -0.45)
					)

					timer:restart()
				end)

				if (snowflake.landed == false) then
					snowflake.origin = snowflake.origin + snowflake.floating_vector * self.speed * illusion.simulation.delta
				end
			end
		end
	end
end
--endregion

--region weather_mode_rain
--- @class weather_mode_rain_c
--- @field public shader shader_c
--- @field public max_droplets number
--- @field public splash boolean
--- @field public storm boolean
--- @field public speed number
--- @field public density number
--- @field public radius number
--- @field public texture number
--- @field public sound_indoors string
--- @field public sound_indoors_length number
--- @field public sound_outdoors string
--- @field public sound_outdoors_length number
--- @field public sound_state number
--- @field public sound_timer timer_standard_c
--- @field public storm_timer timer_standard_c
--- @field public storm_interval number
--- @field public storm_sounds table<number, string>
local weather_mode_rain_c = {}
local weather_mode_rain_mt = { __index = weather_mode_rain_c }

--- Instantiate an object of weather_mode_rain_c.
--- @return weather_mode_rain_c
function weather_mode_rain_c.new()
	return setmetatable({
		shader = illusion.shader.rgb(220, 220, 220, 200),
		max_droplets = 2048,
		splash = false,
		storm = false,
		speed = 1,
		density = 1,
		radius = 1000,
		texture = renderer.load_png(
			hex_to_bin("89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7AF4000000097048597300000B1300000B1301009A9C18000005B869545874584D4C3A636F6D2E61646F62652E786D7000000000003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B633964223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D2241646F626520584D5020436F726520352E362D633134322037392E3136303932342C20323031372F30372F31332D30313A30363A33392020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264663A61626F75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F2220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D6C6E733A73744576743D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F5265736F757263654576656E74232220786D6C6E733A64633D22687474703A2F2F7075726C2E6F72672F64632F656C656D656E74732F312E312F2220786D6C6E733A70686F746F73686F703D22687474703A2F2F6E732E61646F62652E636F6D2F70686F746F73686F702F312E302F2220786D703A43726561746F72546F6F6C3D2241646F62652050686F746F73686F702043432032303138202857696E646F7773292220786D703A437265617465446174653D22323032302D30322D32315431363A31323A35365A2220786D703A4D65746164617461446174653D22323032302D30322D32315431363A31323A35365A2220786D703A4D6F64696679446174653D22323032302D30322D32315431363A31323A35365A2220786D704D4D3A496E7374616E636549443D22786D702E6969643A38613834393765352D626166362D303834622D393137312D6230666565383737343963382220786D704D4D3A446F63756D656E7449443D2261646F62653A646F6369643A70686F746F73686F703A38636461633430622D626639332D363434372D383831622D3762326361666562376664302220786D704D4D3A4F726967696E616C446F63756D656E7449443D22786D702E6469643A37376131653737312D653832332D303734302D383831332D363030326433333230336561222064633A666F726D61743D22696D6167652F706E67222070686F746F73686F703A436F6C6F724D6F64653D2233223E203C786D704D4D3A486973746F72793E203C7264663A5365713E203C7264663A6C692073744576743A616374696F6E3D2263726561746564222073744576743A696E7374616E636549443D22786D702E6969643A37376131653737312D653832332D303734302D383831332D363030326433333230336561222073744576743A7768656E3D22323032302D30322D32315431363A31323A35365A222073744576743A736F6674776172654167656E743D2241646F62652050686F746F73686F702043432032303138202857696E646F777329222F3E203C7264663A6C692073744576743A616374696F6E3D227361766564222073744576743A696E7374616E636549443D22786D702E6969643A38613834393765352D626166362D303834622D393137312D623066656538373734396338222073744576743A7768656E3D22323032302D30322D32315431363A31323A35365A222073744576743A736F6674776172654167656E743D2241646F62652050686F746F73686F702043432032303138202857696E646F777329222073744576743A6368616E6765643D222F222F3E203C2F7264663A5365713E203C2F786D704D4D3A486973746F72793E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3ED197373F00000389494441545885AD97E98B134110C57F994CB29BF5BE454444C1F38320827FBF20E80741BC581014F15A4557DC5537D766C60F55CFAE4C3A876843339D9EE9AE57AF5E55775A755DB3626B79D7B808EFEA4C5FA9957F69BC05B4432F80891B9C00953F05EABF0090E102E8021BC0217F96C010F8E57D08EC7BAF5601B12A8002E80167814BC079E000C6C208F802BC013E00BBC1F05210AD251A10E56BC065E0B683D8F039E960047C0636BDEF02035258E61A59C640E1002E007781336EBC0774FC5D0DAC3BA09E1BDCF4F9214B44B908408131701CF3FCA41BE8B9C192941513FFFE347007D3C36B7F17C3B1320009AF0B5C07CEB951795A329D96ED303E85B13500DE93B224CBC422000546F95537DC73E31D123BF17BEDB78E89F42EA68D2D920E66F4900320CFD6816B58CAC9F36EC3DBB859B3305D02F680FBC0986926B28B9ADE9FF24D1473C5BD9DE9DA47A2ED3AE02BC04D52CAC6B0651988DE5F74EF253CD1DF6E782A6AE5A1DA1A56906E605AF89563211782C2115F08C6957A62208660127AC574EEAF0187B1506E619A986A3906DAC0112CFDD68371E57E1460158CAA046B8C8FBB98288F61056AE2EBEB268078D81C6D78AFCAD74C3FD129060462ECDF08C0012CA3DEADC280EAFE5AA337BD97F06ADFA772C30A53E1731DEF27984DDFB91A101325497851C54D35D70DA302B7EF0C94CE42172B50D910105E8CFC593450B7C25CD31B1956C9AD9D919839029ECD82582E7F3A882ACCC968AC05310C311B34370AA075304547B321A8801FC0374CBD15D30255A169C65AE21B07C07A5F033B195B330094567DEC827185945A02D0710002D12209509EC530D4BEDF57DF6B612112957DE02D563C8E010749421300658680B7C2FA71188FB09BD2B7E0E09FD63C0B847EDF17BCC0A81B908A8BA82DE73C239021567C5E6207D30C03B9C34874F68157C0334C134392C09A47712C4C72A08F89F939C6669FD9F3222B42A1DF03B681A75859D671DCC5A82F49028CE578E46B777CED131F8F03032B01C03DD8021EB861D12F9A551D2B2C4C3F81EFD82DF909F0D0D7EF916ACB549B7723129523DFF02D70CF8DDC726F0E926EC6637FB78309EE31F008F8E873732FA78B2EA5AA647BFE7BE2463E61D7B473D87D41FF0DBE63A9BB895D48B77D6EC082ABF9B2FF059068EF615E1FC56EC84ACF0860DBFB2E26BA3E4BAEE5AB0050EB90727F23FC96810189B1217362FE2F002095E29214BE588A15B6FDECEAFF002002C9B5C99CF9B9ED370E884DE1503DBCF60000000049454E44AE426082"),
			32, 32
		),
		texture_splash = renderer.load_png(
			hex_to_bin("89504E470D0A1A0A0000000D4948445200000040000000400806000000AA6971DE000000097048597300000B1300000B1301009A9C18000005B869545874584D4C3A636F6D2E61646F62652E786D7000000000003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B633964223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D2241646F626520584D5020436F726520352E362D633134322037392E3136303932342C20323031372F30372F31332D30313A30363A33392020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264663A61626F75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F2220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D6C6E733A73744576743D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F5265736F757263654576656E74232220786D6C6E733A64633D22687474703A2F2F7075726C2E6F72672F64632F656C656D656E74732F312E312F2220786D6C6E733A70686F746F73686F703D22687474703A2F2F6E732E61646F62652E636F6D2F70686F746F73686F702F312E302F2220786D703A43726561746F72546F6F6C3D2241646F62652050686F746F73686F702043432032303138202857696E646F7773292220786D703A437265617465446174653D22323032302D30322D32315431363A33343A32325A2220786D703A4D65746164617461446174653D22323032302D30322D32315431363A33343A32325A2220786D703A4D6F64696679446174653D22323032302D30322D32315431363A33343A32325A2220786D704D4D3A496E7374616E636549443D22786D702E6969643A32313430303431662D356135382D633834382D613631382D3237623139613935303866382220786D704D4D3A446F63756D656E7449443D2261646F62653A646F6369643A70686F746F73686F703A62323963346530652D396132642D396434632D396539622D3366623163343131363730612220786D704D4D3A4F726967696E616C446F63756D656E7449443D22786D702E6469643A65353562643366612D646239612D626434372D613766372D626666613330623766666332222064633A666F726D61743D22696D6167652F706E67222070686F746F73686F703A436F6C6F724D6F64653D2233223E203C786D704D4D3A486973746F72793E203C7264663A5365713E203C7264663A6C692073744576743A616374696F6E3D2263726561746564222073744576743A696E7374616E636549443D22786D702E6969643A65353562643366612D646239612D626434372D613766372D626666613330623766666332222073744576743A7768656E3D22323032302D30322D32315431363A33343A32325A222073744576743A736F6674776172654167656E743D2241646F62652050686F746F73686F702043432032303138202857696E646F777329222F3E203C7264663A6C692073744576743A616374696F6E3D227361766564222073744576743A696E7374616E636549443D22786D702E6969643A32313430303431662D356135382D633834382D613631382D323762313961393530386638222073744576743A7768656E3D22323032302D30322D32315431363A33343A32325A222073744576743A736F6674776172654167656E743D2241646F62652050686F746F73686F702043432032303138202857696E646F777329222073744576743A6368616E6765643D222F222F3E203C2F7264663A5365713E203C2F786D704D4D3A486973746F72793E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3E24463DFA00000A1A49444154789CED9B4B931BC7118413AF5DEC4B222D4B21877DB0C3FFFFB7F8AEA342175B266592E22EB00B0C7CE8FAB6B36B7A805598340E62474C0C76D0D35D9595F56A90B3C3E1A0DFF3989F5B80738F2F009C5B80738F2F009C5B80738F2F009C5B80738F2F009C5B80738FDF3D00CBCFB0E66CE279AFE6CE73FFEF75F9A70460D6F97C9878360552EFBDCF3A669FA8199AA57B1E539B9C52F8B303F12918E0CAFBE5C21F34ED0207D55894E7E5755E2A8BEF7B74FCAF00B8F273FB3B07D783A4C1049A6BAC3877E6FA1EA714996220EF4EBEFF5B01E851DC959FDBC540005764D69923B5203908A7E471E601AE2B3E09C44B0198525C1A2BBF501F80855A4BCF357693998AE283C68065E15D79F65CD8F383A4BDADE7FB3C8F97009051CECFA6ACEF735C719E0F9D39EE22CE86299998BB9074197780DEDBB55305033924FD3606B8A2F9B95B73B0EF5C49369E759E3940AEE02916B0F74A05800BB5000C929E246D55400088E7BD4E0130B73BF45AD8F739F77B00EBE57B0F7C53236792AC7866E14245F1B50A081803EAAFE2D9D6DE01A0C33100DCC7FDCA11DF237783AEA669EECAF552616648968981EF2F43F955DA47F11DC6039C3D32BFC405D8C0FDDBFD9C057BA3A78883C09C0CE8A0D6ADA698806CB8C03CC9B28A0BD6B2E6A34EB880A714689F534C56205BD69575257A8AFB1A598EDEDF9E6D16F6B997EE566AE5D9DB9CDD4B5D60A60216966110709C0928742C0066803D76E422E8987C3093BBEFE577408229CF31E21800F8251B788A41002CE0BE9FD39EB323E7EA5ED19219E60A4F819899335576C36664989D62C0422D7A59509E43330422200E1ABB80B3466A15CD2ED4AB21DCF7310C167560F71A83CA7806E1140019842CD05225FDF0FD53CCD985405E8038A310D653965B55B6C7C1DE95C60064DFF7CA6FE83C63DD4906E4E0E72EB04C9B918397A1AC67899D29E491D9D329B122C712D9775E58F17E0E7C5201DFEF0AB9A804B97CCD511DE05658C50217F1F9226DE896CBE530C3B3C790E6B8D573B597FDDCC159A8CF4A674066D74E6310468590FB9D47CC8BB8433984D9D95C8F115EA1796DAFA4B407AF1C5C5D6907CB1527FFE7F77D1F62C15E8519F9F3900120B55CC67515176C98DBA20C82E08DFAD5E04CB5F0C8A9AE67654FA1288F82280E33BDC061DD2C5F6E8C9E5499F0CC002F47E7B1F8B5A45BDBC885F4F2D2CBD041D2261647B0BD6AAA04845E60935A2AF3DC0F4FB03AAC5C18580E9483E2DDE0A3522C700678CEBF08E56F0CE51CCD5DF04135E03441C6BE47084044303E63B51CECDC4DBCF5BDB2BD9CEABCE37D81EFEFD74054771088EC572A29CE2B3CA5BFF93C84504E2F170AC53C306500A178AF46C0FF61DB75C88862BE3E7A7840F654E84C6C825ADE88F4D6BC60CA7BDFEDAC60DE4EE3E2833D006D66EF23A8BBA3ECBE5431CAA5A4BB586FA31A27646BED356EA6DC58DD34E829EA4AD25771DFAAF8CE46C5C250CE11F540B6EA80E6A931BB48CFE23091B5884B4B15EB5FA9D6243080C30FA982EF4CED1E8BF50AA1A55D9736790820F6AAFEF5A83662D37ACE544F61B2C51F6D2F773F7CDC031ECF00601DCA03060AAF92D2CE0A1FEE7A870C008A7A9E64518AA007B5810936902601CD69CB203B50327B9384353DB87AF6212E916DD66AA33E3588376CBD33C551E384805E457186F6A036DDDCABB518F44748D075C1519840B831C173DB9B81200EF1FC4A35355FAA329298451F020004620F86B9D7183180A8FD10D7372A686FD5162252EBFB5EDBE7392B8D0F252F54D9E5C50CE0CD6D1D800000AAD37B55EAEFD2FA80A600C9D9C598650010F8295EDAC6465E58E00A87F81E9FA71A5CABB51A96FC3500DD98C230008B61E5B55A6AE36254A4C4945CE878FAF560FAA4B67043F96E0C20AF0200C1C4EB0347125FC52A44682C7BAD6A95B58AD53C45A138BE7B1BEF38E8346607559A03E02E9E7977CAC577CE4EE9880B301C042F5B3D4D52E4CC55AB32CE06F0E35B9554FA2EE6C00E2F750755DA3B03FC470CACE5054F6ED9798E4C7EF899DBEF0684A9039147156B3DAA46783A2F504581B5DAD3575CE246A560B9B7EFBCB0F2D27565FBE03E5856AA75BC9F4778A6401E82E226299A83E1F3C800E006A4BC7B9540486BEC822108E078EF8F3B385DBD9D252BF04E3E5663AE57787BB5A740B00F0571BD7B5577E15D6749370DCA2630E951D21B49DF8570772AD6A62AE41468616B2118D6CCBF12B9153CF8E5F8E225BA579399F2B06F21E98FF1CE1B55236D553311EC694038752AFC93A4BFDACB37269C1F92621D365AC7DC07038436165FCE00486D0A23CFF39C0AD12BC5755CB72A86C2551EE2BD5580B1521B789FC71400B8C22640F8BB6A0ABB50419677E90FFCDCF0328482211CB000508EF2043D5C83FC0EB083EDB133402F555CF40F925EC7BABFC6A500C2DD8678F1DC801DFB6548B1E93F257DAFE2D300E0940559F23FFE483487AA7EB6E8D520B47F527BB099B340CE48CB00F91B0341927E0E59F7AAC1D09BB3E6A8BE7724E6A90216BC95F4B501E6399C792B7B4F2AC1E841B59BDCD93B589EF4E8458C778B588D20EABF035EABB6C5F41F39DAE31254A2B9F53ECA0094DC49FA45D29F54ADE7C5898387D07B49FF96F441D247BB3C8350DD512C7947475C21F3C0943B95DAE246C520CE2CAF157027FA1A0C9019F0E27F20F13140C0CF39FF736A2D6CFEBBD8FC7D5C1F43103F15BE92F42AEE7E62EB20905261CE9D6A36E2C076AD36C079254BC60200FF61F42800078D177C1B9B7BA383E07EDAC2465B55CB7B2B0C536870A0EF6073A0AE779A9E1DBC9374B7F1633AB73E4775F9ACB20B8017395877AF42E70F2A14ECC50B9446591A20ACC17E5E2D7AE7E73D0765382E83E0AC7308E03EA8A65352E33CF6DFA836600EC0D134E8CA4BAD2F6D54A8FD75087FAD36806DED7D3A4A0F7EBE270D14C18C96D52B44AFE0FCD71DFEFEA89A16E95C893F43527E14FCA600C860402D3A2B7CFB4A25EDBC32657F515BB030BC7A5BABB8D14A05C8D701C0569531B275908F1AC0CFFDEEE3BE8BCF1C9951083DA8753F6FB0BA00B8F5B30B1007EE55F2EC9F5522F177F1EE077B871E9C135B7CF22200E344E74EF5C0E59D09896BF9AF515BD5DA833D38779CA9E6FB57F1F97D007AAF5A5F781DD105C0477601A9FAD5BF54AAC3BFC44501443F0E1539D18545372AF1E356B5F5F5361A1F86FAACC5418B1F99C9D6262EAC542CFEB34A3F400AA61FE88EA918E07F135DF1BF77927E0885D62A4D08F97AAD36AFFB2F37D4EC37AAE9CD0B1E3ABB0B559A13673C2B11937017C6A38AD57F54C958EF5553E028FF4F01A0CE24367DB4BFDF48FA870AC27F53B1EC526DE0F3DF181671E7C4C7031E41F252B5F627357E1580B0E683DAFA8377B72A31E86DDCFFA3EAFFA3DCEF63EAFF0B787ACB2741A4322CFA5AD2B7AA960271FF199BAE8DA80F3B9E548FC989E65E0841792F68B6AA391ECB6EE2EFFBB87B3ACE3FD2BC0880291088E8E46BFC94084C4E3ED81C82199F09705EBC60552A41A9B59CD7043BFB7BB0EF0F36C74BDF49E54F01D003219FD86476E4F337BECFEDA8FF2822B59560562ADF65F386F47DFEAC63CA4BD27F0114056BB4984CEE060000000049454E44AE426082"),
			64, 64
		),
		sound_indoors = "ambient/weather/aztec_int_rain_lp_01.wav",
		sound_indoors_length = 5,
		sound_outdoors = "ambient/weather/aztec_rain_lp_01.wav",
		sound_outdoors_length = 2,
		sound_state = nil,
		sound_timer = illusion.timer_standard(true),
		storm_timer = illusion.timer_standard(true),
		storm_interval = client.random_int(10, 70),
		storm_sounds = {
			"ambient/weather/thunderstorm/lightning_strike_1.wav",
			"ambient/weather/thunderstorm/lightning_strike_2.wav",
			"ambient/weather/thunderstorm/lightning_strike_3.wav",
			"ambient/weather/thunderstorm/lightning_strike_4.wav",
			"ambient/weather/thunderstorm/thunder_1.wav",
			"ambient/weather/thunderstorm/thunder_2.wav",
			"ambient/weather/thunderstorm/thunder_3.wav",
			"ambient/weather/thunderstorm/thunder_far_away_1.wav",
			"ambient/weather/thunderstorm/thunder_far_away_2.wav",
			"ambient/weather/thunder_distant_03.wav",
			"ambient/weather/thunder_distant_04.wav",
			"ambient/weather/thunder_distant_05.wav",
		}
	}, weather_mode_rain_mt)
end

--- Render rain.
--- @param boundary weather_boundary_c
--- @return void
function weather_mode_rain_c:render(boundary)
	if (illusion.hook.total_alive > self.max_droplets) then
		illusion.hook:cull()
	end

	if (boundary == nil) then
		return
	end

	self.storm_timer:event(self.storm_interval, function()
		self.storm_timer:restart()
		self.storm_interval = client.random_int(10, 70)

		client.exec(string.format("playvol %s 1", self.storm_sounds[client.random_int(1, #self.storm_sounds)]))
	end)

	local sky_pos = illusion.shared.player_origin:clone()

	sky_pos.z = boundary.sky_z

	local sound_state = illusion.shared.player_origin:trace_line_to(sky_pos, illusion.shared.observer_eid) == 1 and 1 or 0
	local force_sound_refresh = false

	if (sound_state ~= self.sound_state) then
		force_sound_refresh = true
	end

	self.sound_state = sound_state

	local sound
	local sound_length

	if (self.sound_state == 0) then
		sound = self.sound_indoors
		sound_length = self.sound_indoors_length
	else
		sound = self.sound_outdoors
		sound_length = self.sound_outdoors_length
	end

	if (force_sound_refresh == true or self.sound_timer:elapsed(sound_length) == true) then
		self.sound_timer:restart()

		client.exec(string.format("play %s", sound))
	end

	local spawn_margin = client.random_int(self.density, 40)

	if (spawn_margin > self.density) then
		return
	end

	for _ = 1, self.density do
		local spawn_vector = illusion.shared.player_camera_position + illusion.vector(
			client.random_float(-self.radius, self.radius),
			client.random_float(-self.radius, self.radius),
			client.random_float(-self.radius, self.radius) / 2
		)

		local sky_vector = illusion.vector(spawn_vector.x, spawn_vector.y, boundary.sky_z)
		local can_spawn_trace = sky_vector:trace_line_to(spawn_vector)

		if (can_spawn_trace == 1) then
			local droplet = illusion:create()

			local size = client.random_int(10, 15)

			droplet.origin = spawn_vector
			droplet.shader = self.shader:clone()
			droplet.type = "texture"
			droplet.texture = self.texture
			droplet.width = size
			droplet.height = size
			droplet.fade_time = 2
			droplet.landed = false
			droplet.landing_vector = illusion.vector(0, 0, 0)
			droplet.floating_vector = illusion.vector(0, 0, -2)
			droplet.floating_timer = illusion.timer_tick(true, {
				adjust_after = client.random_int(16, 32)
			})

			local impact_trace_vector = droplet.origin:clone_offset(0, 0, -32768)
			local floor_trace = droplet.origin:trace_line_to(impact_trace_vector)

			droplet.impact_z = droplet.origin.z - (32768 * floor_trace) + 1
			droplet.shader.a = 0
			droplet.target_alpha = 100

			droplet.on_frame = function()
				if (droplet.origin.z <= droplet.impact_z) then
					if (self.splash == true) then
						droplet.dead = true
						droplet.landed = true

						local impact_trace_vector = droplet.origin:clone_offset(0, 0, -32768)
						local floor_trace = droplet.origin:trace_line_to(impact_trace_vector)
						local splash_pos = droplet.origin:clone()

						splash_pos.z = splash_pos.z - (32768 * floor_trace) + 1

						local sky_pos = splash_pos:clone()

						sky_pos.z = boundary.sky_z

						if (splash_pos:trace_line_to(sky_pos) ~= 1) then
							return
						end

						local width = client.random_int(5, 10)
						local height = client.random_int(5, 15)
						local splash = illusion:create()

						splash.origin = splash_pos
						splash.shader = self.shader:clone()
						splash.shader.a = 100
						splash.type = "texture"
						splash.texture = self.texture_splash
						splash.width = width
						splash.height = height
						splash.on_frame = function()
							splash:kill_invisible()

							splash.shader:fade_out(5 * illusion.simulation.delta)

							splash.origin.z = splash.origin.z + 0.33 * illusion.simulation.delta
							splash.width = splash.width + 8 * illusion.simulation.delta
							splash.height = splash.height + 6 * illusion.simulation.delta
						end
					else
						droplet.dead = true
					end
				end

				droplet.shader.a = droplet.shader.a + (droplet.target_alpha - droplet.shader.a) * 0.06 * illusion.simulation.delta

				if (droplet.relation_camera_distance > self.radius) then
					droplet.fade_time = 0.1

					droplet:kill()
				end

				if (droplet.landed == true and droplet.occluded == true) then
					droplet.dead = true

					return
				end

				droplet.floating_timer:event(droplet.floating_timer.adjust_after, function(timer)
					droplet.floating_vector(
						client.random_float(-0.1, 0.1),
						client.random_float(-0.1, 0.1)
					)

					timer:restart()
				end)

				if (droplet.landed == false) then
					droplet.origin = droplet.origin + droplet.floating_vector * self.speed * illusion.simulation.delta
				end
			end
		end
	end
end
--endregion

--region weather
--- @class weather_c
--- @field public current_mode weather_mode_c
--- @field public boundary_manager weather_boundary_manager_c
--- @field public snow weather_mode_snow_c
local weather_c = {}
local weather_mt = { __index = weather_c }

--- Instantiate an object of weather_c.
--- @return weather_c
function weather_c.new()
	return setmetatable({
		enabled = false,
		current_mode = nil,
		boundary_manager = weather_boundary_manager_c.new(),
		snow = weather_mode_snow_c.new(),
		rain = weather_mode_rain_c.new()
	}, weather_mt)
end

--- Render current weather mode.
--- @return void
function weather_c:render()
	if (self.enabled == false) then
		return
	end

	self.current_mode:render(self.boundary_manager.current)
end
--endregion

--region menu_setup
local menu = menu_manager_c.new("config", "presets")

menu:label("--------------------------------------------------")
menu:label("Havoc Weather - v1.1.2")

local enable_script = menu:checkbox("Enable script")(true)
local weather_mode = menu:combobox("Weather mode", {"none", "snow", "rain"})("snow")
local snow_shader = menu:color_picker("Snow shader", 200, 200, 200, 100)
local snow_sticky = menu:checkbox("Sticky snow")(true)
local snow_speed = menu:slider("Snow speed", 1, 5, {
	default = 2,
	unit = "x"
})

local snow_density = menu:slider("Snow density", 1, 40, {
	default = 15,
	unit = "x"
})

local snow_radius = menu:slider("Snow radius", 5, 25, {
	default = 15,
	scale = 100
})

weather_mode:add_children(
	{
		snow_shader,
		snow_speed,
		snow_sticky,
		snow_density,
		snow_radius
	},
	function()
		return weather_mode() == "snow"
	end
)

local rain_shader = menu:color_picker("Droplet shader", 200, 200, 200, 100)

local rain_splash = menu:checkbox("Droplet splash")(true)

local rain_storm = menu:checkbox("Thunder and lightning")(true)

local rain_speed = menu:slider("Droplet speed", 1, 5, {
	default = 4,
	unit = "x"
})

local rain_density = menu:slider("Droplet density", 1, 50, {
	default = 20,
	unit = "x"
})

local rain_radius = menu:slider("Droplet radius", 5, 25, {
	default = 8,
	scale = 100
})

weather_mode:add_children(
	{
		rain_shader,
		rain_splash,
		rain_storm,
		rain_speed,
		rain_density,
		rain_radius
	},
	function()
		return weather_mode() == "rain"
	end
)

enable_script:add_children({
	weather_mode
})

menu:load_from_db()
--endregion

--region main
local weather = weather_c.new()

if (illusion:available() == true) then
	weather.boundary_manager:sync()
end

client.set_event_callback("level_init", function()
	weather.boundary_manager:sync()
end)

client.set_event_callback("paint", function()
	if (illusion:available() == false) then
		return
	end

	weather:render()
end)

client.set_event_callback("shutdown", function()
	client.exec(string.format("play %s", "bot/null.wav"))
	menu:save_to_db()
end)
--endregion

--region menu_callbacks
enable_script:add_callback(function()
	weather.enabled = enable_script()
	client.exec(string.format("play %s", "bot/null.wav"))
end)

weather_mode:add_callback(function()
	illusion:wipe()
	client.exec(string.format("play %s", "bot/null.wav"))

	if (weather_mode() == "none") then
		weather.enabled = false

		return
	end

	weather.enabled = true
	weather.current_mode = weather[weather_mode()]
end)

snow_shader:add_callback(function()
	local r, g, b, a = snow_shader()

	weather.snow.shader:set_r(r)
	weather.snow.shader:set_g(g)
	weather.snow.shader:set_b(b)
	weather.snow.shader:set_a(a)
end)

snow_sticky:add_callback(function()
	weather.snow.sticky = snow_sticky()
end)

snow_speed:add_callback(function()
	weather.snow.speed = snow_speed()
end)

snow_density:add_callback(function()
	weather.snow.density = snow_density()
end)

snow_radius:add_callback(function()
	weather.snow.radius = snow_radius() * 100
end)

rain_shader:add_callback(function()
	local r, g, b, a = rain_shader()

	weather.rain.shader:set_r(r)
	weather.rain.shader:set_g(g)
	weather.rain.shader:set_b(b)
	weather.rain.shader:set_a(a)
end)

rain_splash:add_callback(function()
	weather.rain.splash = rain_splash()
end)

rain_storm:add_callback(function()
	weather.rain.storm = rain_storm()
end)

rain_speed:add_callback(function()
	weather.rain.speed = rain_speed()
end)

rain_density:add_callback(function()
	weather.rain.density = rain_density()
end)

rain_radius:add_callback(function()
	weather.rain.radius = rain_radius() * 100
end)
--endregion
