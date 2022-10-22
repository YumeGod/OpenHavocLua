--region dependencies
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

--region dependency: havoc_binary_1_0_0
--- @class bin_c
--- @field public hex string
--- @field public bin string
--- @field public exe function
--- @field public byte_count number
--- @field public suffixes_short table<number, string>
--- @field public suffixes_long table<number, string>
local bin_c = {}
local bin_mt = {
	__index = bin_c,
	--- @param bin bin_c
	--- @vararg any
	__call = function(bin, ...)
		if (bin.is_executable == true) then
			pcall(bin.exe(), ...)
		else
			return bin.bin
		end
	end
}

--- Instantiate an object of bytecode_c.
--- @param hex string
--- @param is_executable boolean
--- @return bin_c
function bin_c.new(hex, is_executable, format)
	return setmetatable({
		hex = hex,
		bin = nil,
		exe = nil,
		byte_count = nil,
		suffixes_short = { "B", "KB", "MB", "GB", "TB" },
		suffixes_long = { "bytes", "kilobytes", "megabytes", "gigabytes", "terabytes" },
		is_executable = is_executable or false
	}, bin_mt):init(format)
end

--- bytecode_c constructor method.
--- @param format boolean
--- @return bin_c
function bin_c:init(format)
	self.bin = type(format) ~= "number" and self:to_bin(self.hex) or self:to_binf(self.hex, format)
	self.byte_count = self.bin:len()

	if (self.is_executable) then
		local exe, err = loadstring(self.bin)

		assert(err == nil, string.format("Could not load binary: %s", err))

		self.exe = exe
	end

	return self
end

--- Returns the size of the binary data. If precision is nil an integer is returned, else a formatted string.
--- @param precision number|nil
--- @return string|number
function bin_c:size(precision, long_suffix_name)
	if (precision == nil) then
		return self.byte_count
	end

	local base = math.log(self.byte_count, 10) / math.log(1024, 10)
	local size = 1024 ^ (base - math.floor(base))
	local rounded = 10 ^ (precision or 0)

	size = math.floor(size * rounded + 0.5) / rounded

	local suffixes = self.suffixes_short

	if (long_suffix_name == true) then
		suffixes = self.suffixes_long
	end

	return string.format("%s %s", size, suffixes[math.floor(base) + 1])
end

--- Convert hex to binary data.
--- @return string
function bin_c:to_bin(hex)
	return (hex:gsub('..', function (cc)
		return string.char(tonumber(cc, 16))
	end))
end

--- Convert hex to binary data.
--- @param hex string
--- @param format number
--- @return string
function bin_c:to_binf(hex, format)
	local i = 1

	return (hex:gsub('..', function (cc)
		local byte

		if (i % format == 0) then
			byte = 255 - tonumber(cc, 16)
		else
			byte = tonumber(cc, 16)
		end

		i = i + 1

		return string.char(byte)
	end))
end

--- Convert binary to hex string.
--- @return string
function bin_c:to_hex()
	return (self.bin:gsub('.', function (c)
		return string.format('%02X', string.byte(c))
	end))
end
--endregion
--endregion

--region illusion
local illusion = require("havoc_illusion")("havoc orb")
--endregion

--region orb_manager
--- @class orb_manager_c
--- @field public orb illusion_particle_c
--- @field public shader shader_c
--- @field public rainbow boolean
--- @field public rainbow_speed number
--- @field public radius number
--- @field public orbit_height number
--- @field public trail_fade_time number
local orb_manager_c = {}
local orb_manager_mt = { __index = orb_manager_c }

--- Instantiate an object of orb_manager_c.
--- @return orb_manager_c
function orb_manager_c.new()
	return setmetatable({
		orb = nil,
		shader = illusion.shader.rgb(255, 255, 150, 255),
		rainbow = false,
		rainbow_speed = 1,
		radius = 30,
		orbit_height = 32,
		trail_fade_time = 1
	}, orb_manager_mt)
end

--- Spawn the orb.
--- @return void
function orb_manager_c:spawn_orb()
	if (self.orb ~= nil and self.orb.dead == false) then
		return
	end

	local orb = illusion:create()

	orb.type = "circle"
	orb.origin = illusion.shared.player_origin:clone_offset()
	orb.radius = self.radius
	orb.shader = self.shader
	orb.animator = illusion.animator(orb)
	orb.skip_offscreen = false

	orb.on_dead = function()
		self.orb = nil
	end

	orb.on_frame = function()
		if (self.rainbow == true) then
			orb.shader:shift_hue(self.rainbow_speed * illusion.simulation.delta)
		end

		orb.animator:orbit_easing(
			illusion.shared.player_origin:clone_offset(0, 0, self.orbit_height),
			4, 0.005, 64,
			{
				speed = 1.25,
				traces = 64,
				collision = true,
				ignore = illusion.shared.player_eid
			}
		)

		orb.animator:float_z(0.5, 1)

		if (self.trail_fade_time > 0) then
			local trail = illusion:create()
			local trail_shader = orb.shader:clone()

			trail_shader.a = 5

			trail.type = "circle"
			trail.origin = orb.origin:clone()
			trail.radius = orb.radius
			trail.shader = trail_shader
			trail.lifespan = 0
			trail.fade_time = self.trail_fade_time
			trail.skip_offscreen = true

			trail.on_frame = function()
				trail.radius = trail.radius + 1 * illusion.simulation.delta
			end
		end
	end

	self.orb = orb
end

function orb_manager_c:kill_orb()
	if (self.orb ~= nil) then
		self.orb.dead = true
		self.orb = nil
	end
end
--endregion

--region setup
local orb_manager = orb_manager_c.new()
--endregion

--region menu
local menu = menu_manager_c.new("config", "presets")

menu:label("--------------------------------------------------")
menu:label("Havoc Orb Pet - v1.0.3-beta")

local enable_script = menu:checkbox("Enable script")

enable_script:add_callback(function()
	orb_manager:kill_orb()
end)

local orb_color = menu:color_picker("Orb color", 255, 255, 150, 255)

orb_color:add_callback(function()
	local r, g, b, a = orb_color()

	orb_manager.shader(r, g, b, a)
end)

local orb_rainbow = menu:checkbox("Orb rainbow")

orb_rainbow:add_callback(function()
	orb_manager.rainbow = orb_rainbow()
end)

local orb_rainbow_speed = menu:slider("Rainbow speed", 1, 10, {
	unit = "x"
})

orb_rainbow_speed:add_callback(function()
	orb_manager.rainbow_speed = orb_rainbow_speed() * 0.05
end)

local orb_radius = menu:slider("Orb radius", 10, 40, {
	default = 30,
	unit = "x"
})

orb_radius:add_callback(function()
	orb_manager.radius = orb_radius()

	orb_manager:kill_orb()
end)

local orb_trail_fade_time = menu:slider("Orb trail fade speed", 0, 20, {
	default = 5,
	unit = "s",
	scale = 0.1
})

orb_trail_fade_time:add_callback(function()
	orb_manager.trail_fade_time = orb_trail_fade_time() * 0.1
end)

enable_script:add_children({
	orb_color,
	orb_rainbow,
	orb_rainbow_speed,
	orb_radius,
	orb_trail_fade_time
})

menu:load_from_db()
--endregion

--region main
client.set_event_callback("paint", function()
	if (illusion:available() == false or enable_script() == false) then
		return
	end

	orb_manager:spawn_orb()
end)

client.set_event_callback("player_spawn", function(data)
	if (entity.get_local_player() ~= client.userid_to_entindex(data.userid)) then
		return
	end

	if (illusion:available() == true and enable_script() == true) then
		orb_manager:kill_orb()
	end
end)

client.set_event_callback("shutdown", function()
	menu:save_to_db()
end)
--endregion
