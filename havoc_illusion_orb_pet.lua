--region dependencies
--region dependency: havoc_menu_1_0_0
-- v1.0.0

--region menu_assert
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
local menu_item = {}

local menu_item_mt = {
	__index = menu_item
}

function menu_item_mt.__call(item, ...)
	local args = {...}

	if (#args == 0) then
		return item:get()
	end

	local do_ui_set = {pcall(item.set, item, unpack(args))}

	menu_assert(do_ui_set[1], 4, do_ui_set[2])
end

function menu_item.new(element, tab, container, name, ...)
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

function menu_item:set_hidden_value(value)
	self.hidden_value = value
end

function menu_item:set(...)
	local args = {...}

	if (self.setter.callback ~= nil) then
		args = self.setter.callback(unpack(args))
	end

	local do_ui_set = {pcall(ui.set, self.reference, unpack(args))}

	menu_assert(do_ui_set[1], 3, "Cannot set values of menu item because: %s", do_ui_set[2])
end

function menu_item:get()
	if (self.visible == false and self.hidden_value ~= nil) then
		return self.hidden_value
	end

	local get = {ui.get(self.reference)}

	if (self.getter.callback ~= nil) then
		return self.getter.callback(get)
	end

	return unpack(get)
end

function menu_item:set_setter_callback(callback, data)
	menu_assert(type(callback) == "function", 3, "Cannot set menu item setter callback: argument must be a function.")

	self.setter.callback = callback
	self.setter.data = data
end

function menu_item:set_getter_callback(callback, data)
	menu_assert(type(callback) == "function", 3, "Cannot set menu item getter callback: argument must be a function.")

	self.getter.callback = callback
	self.getter.data = data
end

function menu_item:add_children(children, value_or_callback)
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

	menu_item._process_callbacks(self)
end

function menu_item:add_callback(callback)
	menu_assert(self.is_menu_reference == false, 3, "Cannot add callbacks to built-in menu items.")
	menu_assert(type(callback) == "function", 3, "Callbacks for menu items must be functions.")

	table.insert(self.callbacks, callback)

	menu_item._process_callbacks(self)
end

function menu_item._process_callbacks(item)
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
local menu_manager = {}

local menu_manager_mt = {
	__index = menu_manager
}

function menu_manager.new(tab, container)
	menu_manager._validate_tab_container(tab, container)

	return setmetatable(
		{
			tab = tab,
			container = container,
			children = {}
		},
		menu_manager_mt
	)
end

function menu_manager:parent_all_to(item, value_or_callback)
	local children = self.children

	children[item.reference] = nil

	item:add_children(children, value_or_callback)
end

function menu_manager.reference(tab, container, name)
	menu_manager._validate_tab_container(tab, container)

	local do_reference = {pcall(ui.reference, tab, container, name)}

	menu_assert(do_reference[1], 3, "Cannot reference Gamesense menu item because: %s", do_reference[2])

	local references = {select(2, unpack(do_reference))}
	local items = {}

	for i = 1, #references do
		table.insert(
			items,
			menu_item.new(
				references[i],
				tab,
				container,
				name
			)
		)
	end

	return unpack(items)
end

function menu_manager:checkbox(name)
	return self:_create_item(ui.new_checkbox, name)
end

function menu_manager:slider(name, min, max, default_or_options, show_tooltip, unit, scale, tooltips)
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

function menu_manager:combobox(name, ...)
	local args = {...}

	if (type(args[1]) == "table") then
		args = args[1]
	end

	return self:_create_item(ui.new_combobox, name, args)
end

function menu_manager:multiselect(name, ...)
	local args = {...}

	if (type(args[1]) == "table") then
		args = args[1]
	end

	return self:_create_item(ui.new_multiselect, name, args)
end

function menu_manager:hotkey(name, inline)
	if (inline == nil) then
		inline = false
	end

	menu_assert(type(inline) == "boolean", 3, "Hotkey inline argument must be a boolean.")

	return self:_create_item(ui.new_hotkey, name, inline)
end

function menu_manager:button(name, callback)
	menu_assert(type(callback) == "function", 3, "Cannot set button callback because the callback argument must be a function.")

	return self:_create_item(ui.new_button, name, callback)
end

function menu_manager:color_picker(name, r, g, b, a)
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

function menu_manager:textbox(name)
	return self:_create_item(ui.new_textbox, name)
end

function menu_manager:listbox(name, ...)
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

function menu_manager:_create_item(element, name, ...)
	menu_assert(type(name) == "string" and name ~= "", 3, "Cannot create menu item: name must be a non-empty string.")

	local item = menu_item.new(element, self.tab, self.container, name, ...)
	self.children[item.reference] = item

	return item
end

function menu_manager._validate_tab_container(tab, container)
	menu_assert(type(tab) == "string" and tab ~= "", 4, "Cannot create menu manager: tab name must be a non-empty string.")
	menu_assert(type(container) == "string" and container ~= "", 4, "Cannot create menu manager: tab name must be a non-empty string.")

	tab = tab:lower()

	menu_assert(menu_map[tab] ~= nil, 4, "Cannot create menu manager: tab name does not exist.")
	menu_assert(menu_map[tab][container:lower()] ~= nil, 4, "Cannot create menu manager: container name does not exist.")
end
--endregion
--endregion
--endregion

--region illusion
local hook_illusion = require("havoc_illusion_old")
local illusion = hook_illusion("orb pet", "1.0.0")
--endregion

--region menu
local menu = menu_manager.new("misc", "miscellaneous")

local color = menu:slider("Orb Hue", 0, 360)
local orb_s = illusion.shader.rgb(255, 0, 0, 200)

local orb_s_h = 0

color:add_callback(function()
	orb_s_h = color()
end)
--endregion

--region spawn_orb
local orb

local function spawn_orb()
	--region orb
	orb = illusion:create("circle", illusion.shared.player.eye_position:clone_offset(0, 0, 16), {
		visible_shader = orb_s,
		occluded_shader = orb_s:clone(),
		radius = 15,
		custom = {
			orbit_a = illusion.angle(0, 0, 0),
			orbit_radius = 64,
			float_timer = illusion.timer.standard(true),
			kill = false,
			lightness = orb_s.l,
			soul_hitboxes = {}
		},
		on_spawn = function(particle)
			particle.shader.occluded.a = 25
		end,
		on_frame = function(particle)
			--region kill_lightness
			if (particle.custom.kill == true) then
				if (particle.shader.visible.l <= particle.custom.lightness) then
					particle.custom.kill = false
				else
					particle.shader.visible:darken(0.005 * particle.shared.simulation.delta)
				end
			end
			--endregion

			--region snaplines
			local enemies = entity.get_players(true)

			for i = 1, #enemies do
				local enemy = enemies[i]
				local target_vector = illusion.vector(entity.hitbox_position(enemy, 3))

				particle.custom.soul_hitboxes[enemy] = target_vector

				local tracker_r1, tracker_r2 = particle.vector:ray(target_vector, 512)

				if (tracker_r1 ~= nil or tracker_r2 ~= nil) then
					renderer.line(
						tracker_r1.x, tracker_r1.y,
						tracker_r2.x, tracker_r2.y,
						particle.shader.visible.r, particle.shader.visible.g, particle.shader.visible.b, 25
					)
				end
			end
			--endregion

			--region orbit_and_movement
			local lowest_trace = particle.custom.orbit_radius
			local origin_v = illusion.shared.player.eye_position:clone()

			origin_v.z = particle.vector.z

			for i = 1, 32 do
				local target_a = illusion.angle(0, (360 / 32) * i, 0)
				local target_v = origin_v + target_a:to_forward_vector() * particle.custom.orbit_radius
				local trace_t = origin_v:trace_line_to(target_v, illusion.shared.player.eid)
				local distance = particle.custom.orbit_radius * trace_t

				if (distance < lowest_trace) then
					lowest_trace = distance
				end
			end

			particle.custom.orbit_a.y = particle.custom.orbit_a.y + 1 * particle.shared.simulation.delta
			particle.custom.orbit_a.y = particle.custom.orbit_a.y % 360

			local orbit_v = particle.custom.orbit_a:to_forward_vector() * lowest_trace
			local target_v = illusion.shared.player.eye_position:clone_offset(0, 0, 16) + orbit_v
			local target_a = particle.vector:angle_to(target_v)
			local target_fv = target_a:to_forward_vector()
			local speed = particle.vector:distance(target_v) / 40

			particle.shader.visible:set_h(orb_s_h + 0 - (speed - 30) / 30 * 360)

			particle.vector = particle.vector + target_fv * speed * particle.shared.simulation.delta
			particle.vector.z = particle.vector.z +
				math.sin(particle.custom.float_timer() * math.pi * 0.66) * 0.5 * particle.shared.simulation.delta
			--endregion

			--region trail
			illusion:create("circle", particle.vector:clone(), {
				visible_shader = particle.shader.visible:clone(),
				lifespan = 0,
				fade_time = 0.5,
				radius = 10,
				skip_offscreen = true,
				on_spawn = function(child)
					child.shader.visible.a = math.abs(0 - (speed - 255) / 255 * 255 - 255) + 4
				end
			})
			--endregion
		end
	})
	--endregion
end
--endregion

spawn_orb()

client.set_event_callback("player_death", function(data)
	local victim = client.userid_to_entindex(data.userid)
	local killer = client.userid_to_entindex(data.attacker)

	if (victim == entity.get_local_player()) then
		return
	end

	if (killer == entity.get_local_player()) then
		orb.custom.kill = true

		orb_s:set_l(1)

		illusion:create("circle", orb.custom.soul_hitboxes[victim], {
			visible_shader = orb.shader.visible,
			occluded_shader = orb.shader.occluded,
			radius = 8,
			skip_offscreen = true,
			custom = {
				orbit_a = illusion.angle(0, 0, 0),
				speed_mod = 40,
				speed_timer = illusion.timer.standard(true)
			},
			on_frame = function(child)
				child.custom.speed_timer:event(1, function(timer)
					child.custom.speed_mod = 10

					timer:stop()
				end)

				--region tracelines
				local tracker_r1, tracker_r2 = child.vector:ray(orb.vector, 64)

				if (tracker_r1 ~= nil and tracker_r2 ~= nil) then
					renderer.line(
						tracker_r1.x, tracker_r1.y,
						tracker_r2.x, tracker_r2.y,
						child.shader.visible.r, child.shader.visible.g, child.shader.visible.b, 25
					)
				end
				--endregion

				--region orbit_and_movement
				child.custom.orbit_a.p = child.custom.orbit_a.p + 1 * child.shared.simulation.delta
				child.custom.orbit_a.p = child.custom.orbit_a.p % 360
				child.custom.orbit_a.y = child.custom.orbit_a.y + 1 * child.shared.simulation.delta
				child.custom.orbit_a.y = child.custom.orbit_a.y % 360

				local orbit_v = child.custom.orbit_a:to_forward_vector() * 8
				local target_v = orb.vector + orbit_v
				local target_a = child.vector:angle_to(target_v)
				local target_fv = target_a:to_forward_vector()
				local speed = child.vector:distance(target_v) / child.custom.speed_mod
				child.vector = child.vector + target_fv * speed * child.shared.simulation.delta
				--endregion
			end
		})
	end
end)

client.set_event_callback("round_start", function()
	illusion:wipe()

	spawn_orb()
end)
