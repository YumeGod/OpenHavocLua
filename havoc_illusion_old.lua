-->>START_INFO_BLOCK
-- project_name=Havoc Illusion;
-- version=1.0.0;
-- authors=Kessie;
--<<END_INFO_BLOCK
-->>START_BETA_BLOCK
local test = math.min(765)

local settings = {}

for k, v in pairs(settings) do
	v = nil
end
--<<END_BETA_BLOCK

--region apis
--region gs_api
-- todo remove - non-permanent solution
function client.random_int(min, max)
	return math.random(min, max)
end

-- todo remove - non-permanent solution
function client.random_float(min, max)
	min = min * 1000000
	max = max * 1000000

	return math.random(min, max) * 0.000001
end

--region client
local client_latency, client_log, client_userid_to_entindex, client_set_event_callback, client_screen_size, client_eye_position, client_color_log, client_delay_call, client_visible, client_exec, client_trace_line, client_draw_hitboxes, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float, client_trace_bullet, client_scale_damage, client_timestamp, client_set_clan_tag, client_system_time, client_reload_active_scripts, client_update_player_list, client_camera_position = client.latency, client.log, client.userid_to_entindex, client.set_event_callback, client.screen_size, client.eye_position, client.color_log, client.delay_call, client.visible, client.exec, client.trace_line, client.draw_hitboxes, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float, client.trace_bullet, client.scale_damage, client.timestamp, client.set_clan_tag, client.system_time, client.reload_active_scripts, client.update_player_list, client.camera_position
--endregion

--region entity
local entity_get_local_player, entity_is_enemy, entity_hitbox_position, entity_get_player_name, entity_get_steam64, entity_get_bounding_box, entity_get_all, entity_set_prop, entity_is_alive, entity_get_player_weapon, entity_get_prop, entity_get_players, entity_get_classname, entity_get_game_rules, entity_get_player_resource, entity_is_dormant = entity.get_local_player, entity.is_enemy, entity.hitbox_position, entity.get_player_name, entity.get_steam64, entity.get_bounding_box, entity.get_all, entity.set_prop, entity.is_alive, entity.get_player_weapon, entity.get_prop, entity.get_players, entity.get_classname, entity.get_game_rules, entity.get_prop, entity.is_dormant
--endregion

--region globals
local globals_realtime, globals_absoluteframetime, globals_tickcount, globals_curtime, globals_mapname, globals_tickinterval, globals_framecount, globals_frametime, globals_maxplayers, globals_lastoutgoingcommand = globals.realtime, globals.absoluteframetime, globals.tickcount, globals.curtime, globals.mapname, globals.tickinterval, globals.framecount, globals.frametime, globals.maxplayers, globals.lastoutgoingcommand
--endregion

--region ui
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_is_menu_open, ui_new_color_picker, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get, ui_new_textbox, ui_mouse_position = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.is_menu_open, ui.new_color_picker, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get, ui.new_textbox, ui.mouse_position
--endregion

--region renderer
local renderer_text, renderer_measure_text, renderer_rectangle, renderer_line, renderer_gradient, renderer_circle, renderer_circle_outline, renderer_triangle, renderer_world_to_screen, renderer_indicator, renderer_texture, renderer_load_svg, renderer_load_png, renderer_load_jpg = renderer.text, renderer.measure_text, renderer.rectangle, renderer.line, renderer.gradient, renderer.circle, renderer.circle_outline, renderer.triangle, renderer.world_to_screen, renderer.indicator, renderer.texture, renderer.load_svg, renderer.load_png, renderer.load_jpg
--endregion

--region database
local database_read, database_write = database.read, database.write
--endregion

--region materialsystem
local materialsystem_arms_material, materialsystem_chams_material, materialsystem_find_materials, materialsystem_find_texture, materialsystem_get_model_materials, materialsystem_override_material = materialsystem.arms_material, materialsystem.chams_material, materialsystem.find_materials, materialsystem.find_texture, materialsystem.get_model_materials, materialsystem.override_material
--endregion
--endregion

--region std_api
--region math
--- Round a number to the nearest precision, or none by default.
--- @param number number
--- @param precision number
--- @return number
function math.round(number, precision)
	local mult = 10 ^ (precision or 0)

	return math.floor(number * mult + 0.5) / mult
end
--endregion

--region table
--- Returns true if the table contains the value being searched for.
--- @param search_table table
--- @param search_value any
--- @return boolean
function table.contains(search_table, search_value)
	for _, table_value in pairs(search_table) do
		if (search_value == table_value) then
			return true
		end
	end

	return false
end
--endregion
--endregion

--region hvc_api
local function spairs(t, order)
	-- Collect the keys
	local keys = {}

	for k in pairs(t) do keys[#keys+1] = k end
	-- If order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end

	local i = 0

	-- Return the iterator function.
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end
--endregion
--endregion

--region dependencies
--region dependency: havoc_panic_1_0_1
--- Acts as a fail-safe that trips a script into shutting down safely, and resetting players to use the Gamesense resolver.
--- @class panic_c
local panic_c = {}
local panic_mt = { __index = panic_c }

--- Instaniate panic_c.
--- @return panic_c
function panic_c.new(panic_callback)
	return setmetatable(
		{
			interrupt = false, -- Was the previous cycle interrupted?
			panic = false, -- Has the system entered panic mode?
			panic_callback = panic_callback, -- Callback to run upon a panic.
		},
		panic_mt
	)
end

--- Test to ensure that all running processes from the previous cycle were successful and did not encounter errors.
--- @vararg any
function panic_c:test(...)
	-- Panic if the interrupt was never reset from the previous cycle.
	if (self.interrupt == true and self.panic == false) then
		self.panic = true
		-- Otherwise, if the previous cycle already initiated the panic, no further action is required.
	elseif (self.interrupt == true and self.panic == true) then
		-- Let the execuding code know that the test failed.
		return false
	end

	-- Initiate the panic.
	if (self.interrupt == true) then
		self.panic = true

		-- Run the panic callback given to us.
		self.panic_callback(...)
	end

	-- Let the executing code know that the test passed.
	return true
end

--- Begin the panic test.
--- Run this at the start of events.
--- @return void
function panic_c:start()
	self.interrupt = true
end

--- End the panic test.
--- Run this at the end of events.
--- @return void
function panic_c:stop()
	self.interrupt = false
end

--- Forcefully trigger a panic attack.
--- Call this mid-test.
--- @return void
function panic_c:trip()
	self.interrupt = true
end
--endregion

--region dependency: havoc_vector_2_0_1
--region math
function math.round(number, precision)
	local mult = 10 ^ (precision or 0)

	return math.floor(number * mult + 0.5) / mult
end
--endregion

--region angle
--- @class angle_old_c
--- @field public p number Angle pitch.
--- @field public y number Angle yaw.
--- @field public r number Angle roll.
local angle_old_c = {}
local angle_mt = {
	__index = angle_old_c
}

--- Overwrite the angle's angles. Nil values leave the angle unchanged.
--- @param angle angle_old_c
--- @param p_new number
--- @param y_new number
--- @param r_new number
--- @return void
angle_mt.__call = function(angle, p_new, y_new, r_new)
	p_new = p_new or angle.p
	y_new = y_new or angle.y
	r_new = r_new or angle.r

	angle.p = p_new
	angle.y = y_new
	angle.r = r_new
end

--- Create a new vector object.
--- @param p number
--- @param y number
--- @param r number
--- @return angle_old_c
local function angle(p, y, r)
	return setmetatable(
		{
			p = p,
			y = y,
			r = r
		},
		angle_mt
	)
end

--- Offset the angle's angles. Nil values leave the angle unchanged.
--- @param p_offset number
--- @param y_offset number
--- @param r_offset number
--- @return void
function angle_old_c:offset(p_offset, y_offset, r_offset)
	p_offset = self.p + p_offset or 0
	y_offset = self.y + y_offset or 0
	r_offset = self.r + r_offset or 0

	self.p = self.p + p_offset
	self.y = self.y + y_offset
	self.r = self.r + r_offset
end

--- Clone the angle object.
--- @return angle_old_c
function angle_old_c:clone()
	return setmetatable(
		{
			p = self.p,
			y = self.y,
			r = self.r
		},
		angle_mt
	)
end

--- Clone and offset the angle's angles. Nil values leave the angle unchanged.
--- @param p_offset number
--- @param y_offset number
--- @param r_offset number
--- @return angle_old_c
function angle_old_c:clone_offset(p_offset, y_offset, r_offset)
	p_offset = self.p + p_offset or 0
	y_offset = self.y + y_offset or 0
	r_offset = self.r + r_offset or 0

	return angle(
		self.p + p_offset,
		self.y + y_offset,
		self.r + r_offset
	)
end

--- Unpack the angle.
--- @return number, number, number
function angle_old_c:unpack()
	return self.p, self.y, self.r
end

--- Set the angle's euler angles to 0.
--- @return void
function angle_old_c:nullify()
	self.p = 0
	self.y = 0
	self.r = 0
end

--- Returns a string representation of the angle.
function angle_mt.__tostring(operand_a)
	return string.format("%s, %s, %s", operand_a.p, operand_a.y, operand_a.r)
end

--- Concatenates the angle in a string.
function angle_mt.__concat(operand_a)
	return string.format("%s, %s, %s", operand_a.p, operand_a.y, operand_a.r)
end

--- Adds the angle to another angle.
function angle_mt.__add(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a + operand_b.p,
			operand_a + operand_b.y,
			operand_a + operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p + operand_b,
			operand_a.y + operand_b,
			operand_a.r + operand_b
		)
	end

	return angle(
		operand_a.p + operand_b.p,
		operand_a.y + operand_b.y,
		operand_a.r + operand_b.r
	)
end

--- Subtracts the angle from another angle.
function angle_mt.__sub(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a - operand_b.p,
			operand_a - operand_b.y,
			operand_a - operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p - operand_b,
			operand_a.y - operand_b,
			operand_a.r - operand_b
		)
	end

	return angle(
		operand_a.p - operand_b.p,
		operand_a.y - operand_b.y,
		operand_a.r - operand_b.r
	)
end

--- Multiplies the angle with another angle.
function angle_mt.__mul(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a * operand_b.p,
			operand_a * operand_b.y,
			operand_a * operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p * operand_b,
			operand_a.y * operand_b,
			operand_a.r * operand_b
		)
	end

	return angle(
		operand_a.p * operand_b.p,
		operand_a.y * operand_b.y,
		operand_a.r * operand_b.r
	)
end

--- Divides the angle by the another angle.
function angle_mt.__div(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a / operand_b.p,
			operand_a / operand_b.y,
			operand_a / operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p / operand_b,
			operand_a.y / operand_b,
			operand_a.r / operand_b
		)
	end

	return angle(
		operand_a.p / operand_b.p,
		operand_a.y / operand_b.y,
		operand_a.r / operand_b.r
	)
end

--- Raises the angle to the power of an another angle.
function angle_mt.__pow(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			math.pow(operand_a, operand_b.p),
			math.pow(operand_a, operand_b.y),
			math.pow(operand_a, operand_b.r)
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			math.pow(operand_a.p, operand_b),
			math.pow(operand_a.y, operand_b),
			math.pow(operand_a.r, operand_b)
		)
	end

	return angle(
		math.pow(operand_a.p, operand_b.p),
		math.pow(operand_a.y, operand_b.y),
		math.pow(operand_a.r, operand_b.r)
	)
end

--- Performs modulo on the angle with another angle.
function angle_mt.__mod(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a % operand_b.p,
			operand_a % operand_b.y,
			operand_a % operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p % operand_b,
			operand_a.y % operand_b,
			operand_a.r % operand_b
		)
	end

	return angle(
		operand_a.p % operand_b.p,
		operand_a.y % operand_b.y,
		operand_a.r % operand_b.r
	)
end

--- Perform a unary minus operation on the angle.
function angle_mt.__unm(operand_a)
	operand_a.p = -operand_a.p
	operand_a.y = -operand_a.y
	operand_a.r = -operand_a.r
end

--- Clamps the angle's angles to whole numbers. Equivalent to "angle:round" with no precision.
--- @return void
function angle_old_c:round_zero()
	self.p = math.floor(self.p + 0.5)
	self.y = math.floor(self.y + 0.5)
	self.r = math.floor(self.r + 0.5)
end

--- Round the angle's angles.
--- @param precision number
function angle_old_c:round(precision)
	self.p = math.round(self.p, precision)
	self.y = math.round(self.y, precision)
	self.r = math.round(self.r, precision)
end

--- Clamps the angle's angles to the nearest base.
--- @param base number
function angle_old_c:round_base(base)
	self.p = base * math.round(self.p / base)
	self.y = base * math.round(self.y / base)
	self.r = base * math.round(self.r / base)
end

--- Clamps the angle's angles to whole numbers. Equivalent to "angle:round" with no precision.
--- @return angle_old_c
function angle_old_c:rounded_zero()
	return angle(
		math.floor(self.p + 0.5),
		math.floor(self.y + 0.5),
		math.floor(self.r + 0.5)
	)
end

--- Round the angle's angles.
--- @param precision number
--- @return angle_old_c
function angle_old_c:rounded(precision)
	return angle(
		math.round(self.p, precision),
		math.round(self.y, precision),
		math.round(self.r, precision)
	)
end

--- Clamps the angle's angles to the nearest base.
--- @param base number
--- @return angle_old_c
function angle_old_c:rounded_base(base)
	return angle(
		base * math.round(self.p / base),
		base * math.round(self.y / base),
		base * math.round(self.r / base)
	)
end
--endregion

--region vector
--- @class vector_old_c
--- @field public x number X coordinate.
--- @field public y number Y coordinate.
--- @field public z number Z coordinate.
local vector_old_c = {}
local vector_mt = {
	__index = vector_old_c,
}

--- Overwrite the vector's coordinates. Nil will leave coordinates unchanged.
--- @param x_new number
--- @param y_new number
--- @param z_new number
--- @return void
vector_mt.__call = function(vector, x_new, y_new, z_new)
	x_new = x_new or vector.x
	y_new = y_new or vector.y
	z_new = z_new or vector.z

	vector.x = x_new
	vector.y = y_new
	vector.z = z_new
end

--- Create a new vector object.
--- @param x number
--- @param y number
--- @param z number
--- @return vector_old_c
local function vector(x, y, z)
	return setmetatable(
		{
			x = x,
			y = y,
			z = z
		},
		vector_mt
	)
end

--- Offset the vector's coordinates. Nil will leave the coordinates unchanged.
--- @param x_offset number
--- @param y_offset number
--- @param z_offset number
--- @return void
function vector_old_c:offset(x_offset, y_offset, z_offset)
	x_offset = x_offset or 0
	y_offset = y_offset or 0
	z_offset = z_offset or 0

	self.x = self.x + x_offset
	self.y = self.y + y_offset
	self.z = self.z + z_offset
end

--- Clone the vector object.
--- @return vector_old_c
function vector_old_c:clone()
	return setmetatable(
		{
			x = self.x,
			y = self.y,
			z = self.z
		},
		vector_mt
	)
end

--- Clone the vector object and offset its coordinates. Nil will leave the coordinates unchanged.
--- @param x_offset number
--- @param y_offset number
--- @param z_offset number
--- @return vector_old_c
function vector_old_c:clone_offset(x_offset, y_offset, z_offset)
	x_offset = x_offset or 0
	y_offset = y_offset or 0
	z_offset = z_offset or 0

	return setmetatable(
		{
			x = self.x + x_offset,
			y = self.y + y_offset,
			z = self.z + z_offset
		},
		vector_mt
	)
end

--- Unpack the vector.
--- @return number, number, number
function vector_old_c:unpack()
	return self.x, self.y, self.z
end

--- Set the vector's coordinates to 0.
--- @return void
function vector_old_c:nullify()
	self.x = 0
	self.y = 0
	self.z = 0
end

--- Returns a string representation of the vector.
function vector_mt.__tostring(operand_a)
	return string.format("%s, %s, %s", operand_a.x, operand_a.y, operand_a.z)
end

--- Concatenates the vector in a string.
function vector_mt.__concat(operand_a)
	return string.format("%s, %s, %s", operand_a.x, operand_a.y, operand_a.z)
end


--- Returns true if the vector's coordinates are equal to another vector.
function vector_mt.__eq(operand_a, operand_b)
	return (operand_a.x == operand_b.x) and (operand_a.y == operand_b.y) and (operand_a.z == operand_b.z)
end

--- Returns true if the vector is less than another vector.
function vector_mt.__lt(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return (operand_a < operand_b.x) or (operand_a < operand_b.y) or (operand_a < operand_b.z)
	end

	if (type(operand_b) == "number") then
		return (operand_a.x < operand_b) or (operand_a.y < operand_b) or (operand_a.z < operand_b)
	end

	return (operand_a.x < operand_b.x) or (operand_a.y < operand_b.y) or (operand_a.z < operand_b.z)
end

--- Returns true if the vector is less than or equal to another vector.
function vector_mt.__le(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return (operand_a <= operand_b.x) or (operand_a <= operand_b.y) or (operand_a <= operand_b.z)
	end

	if (type(operand_b) == "number") then
		return (operand_a.x <= operand_b) or (operand_a.y <= operand_b) or (operand_a.z <= operand_b)
	end

	return (operand_a.x <= operand_b.x) or (operand_a.y <= operand_b.y) or (operand_a.z <= operand_b.z)
end

--- Add a vector to another vector.
function vector_mt.__add(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a + operand_b.x,
			operand_a + operand_b.y,
			operand_a + operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x + operand_b,
			operand_a.y + operand_b,
			operand_a.z + operand_b
		)
	end

	return vector(
		operand_a.x + operand_b.x,
		operand_a.y + operand_b.y,
		operand_a.z + operand_b.z
	)
end

--- Subtract a vector from another vector.
function vector_mt.__sub(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a - operand_b.x,
			operand_a - operand_b.y,
			operand_a - operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x - operand_b,
			operand_a.y - operand_b,
			operand_a.z - operand_b
		)
	end

	return vector(
		operand_a.x - operand_b.x,
		operand_a.y - operand_b.y,
		operand_a.z - operand_b.z
	)
end

--- Multiply a vector with another vector.
function vector_mt.__mul(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a * operand_b.x,
			operand_a * operand_b.y,
			operand_a * operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x * operand_b,
			operand_a.y * operand_b,
			operand_a.z * operand_b
		)
	end

	return vector(
		operand_a.x * operand_b.x,
		operand_a.y * operand_b.y,
		operand_a.z * operand_b.z
	)
end

--- Divide a vector by another vector.
function vector_mt.__div(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a / operand_b.x,
			operand_a / operand_b.y,
			operand_a / operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x / operand_b,
			operand_a.y / operand_b,
			operand_a.z / operand_b
		)
	end

	return vector(
		operand_a.x / operand_b.x,
		operand_a.y / operand_b.y,
		operand_a.z / operand_b.z
	)
end

--- Raised a vector to the power of another vector.
function vector_mt.__pow(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			math.pow(operand_a, operand_b.x),
			math.pow(operand_a, operand_b.y),
			math.pow(operand_a, operand_b.z)
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			math.pow(operand_a.x, operand_b),
			math.pow(operand_a.y, operand_b),
			math.pow(operand_a.z, operand_b)
		)
	end

	return vector(
		math.pow(operand_a.x, operand_b.x),
		math.pow(operand_a.y, operand_b.y),
		math.pow(operand_a.z, operand_b.z)
	)
end

--- Performs a modulo operation on a vector with another vector.
function vector_mt.__mod(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a % operand_b.x,
			operand_a % operand_b.y,
			operand_a % operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x % operand_b,
			operand_a.y % operand_b,
			operand_a.z % operand_b
		)
	end

	return vector(
		operand_a.x % operand_b.x,
		operand_a.y % operand_b.y,
		operand_a.z % operand_b.z
	)
end

--- Perform a unary minus operation on the vector.
function vector_mt.__unm(operand_a)
	operand_a.x = -operand_a.x
	operand_a.y = -operand_a.y
	operand_a.z = -operand_a.z
end

--- Returns the vector's 2 dimensional length squared.
--- @return number
function vector_old_c:length2_squared()
	return (self.x * self.x) + (self.y * self.y);
end

--- Return's the vector's 2 dimensional length.
--- @return number
function vector_old_c:length2()
	return math.sqrt(self:length2_squared())
end

--- Returns the vector's 3 dimensional length squared.
--- @return number
function vector_old_c:length_squared()
	return (self.x * self.x) + (self.y * self.y) + (self.z * self.z);
end

--- Return's the vector's 3 dimensional length.
--- @return number
function vector_old_c:length()
	return math.sqrt(self:length_squared())
end

--- Returns the vector's dot product.
--- @param other_vector vector_old_c
--- @return number
function vector_old_c:dot_product(other_vector)
	return (self.x * other_vector.x) + (self.y * other_vector.y) + (self.z * other_vector.z)
end

--- Returns the vector's cross product.
--- @param other_vector vector_old_c
--- @return vector_old_c
function vector_old_c:cross_product(other_vector)
	return vector_old_c(
		(self.y * other_vector.z) - (self.z * other_vector.y),
		(self.z * other_vector.x) - (self.x * other_vector.z),
		(self.x * other_vector.y) - (self.y * other_vector.x)
	)
end

--- Returns the 2 dimensional distance between the vector and another vector.
--- @param other_vector vector_old_c
--- @return number
function vector_old_c:distance2(other_vector)
	return (other_vector - self):length2()
end

--- Returns the 3 dimensional distance between the vector and another vector.
--- @param other_vector vector_old_c
--- @return number
function vector_old_c:distance(other_vector)
	return (other_vector - self):length()
end

--- Returns the distance on the X axis between the vector and another vector.
--- @param other_vector vector_old_c
--- @return number
function vector_old_c:distance_x(other_vector)
	return math.abs(self.x - other_vector.x)
end

--- Returns the distance on the Y axis between the vector and another vector.
--- @param other_vector vector_old_c
--- @return number
function vector_old_c:distance_y(other_vector)
	return math.abs(self.y - other_vector.y)
end

--- Returns the distance on the Z axis between the vector and another vector.
--- @param other_vector vector_old_c
--- @return number
function vector_old_c:distance_z(other_vector)
	return math.abs(self.z - other_vector.z)
end

--- Returns true if the vector is within the given distance to another vector.
--- @param other_vector vector_old_c
--- @param distance number
--- @return boolean
function vector_old_c:in_range(other_vector, distance)
	return self:distance(other_vector) <= distance
end

--- Clamps the vector's coordinates to whole numbers. Equivalent to "vector:round" with no precision.
--- @return void
function vector_old_c:round_zero()
	self.x = math.floor(self.x + 0.5)
	self.y = math.floor(self.y + 0.5)
	self.z = math.floor(self.z + 0.5)
end

--- Round the vector's coordinates.
--- @param precision number
--- @return void
function vector_old_c:round(precision)
	self.x = math.round(self.x, precision)
	self.y = math.round(self.y, precision)
	self.z = math.round(self.z, precision)
end

--- Clamps the vector's coordinates to the nearest base.
--- @param base number
--- @return void
function vector_old_c:round_base(base)
	self.x = base * math.round(self.x / base)
	self.y = base * math.round(self.y / base)
	self.z = base * math.round(self.z / base)
end

--- Clamps the vector's coordinates to whole numbers. Equivalent to "vector:round" with no precision.
--- @return vector_old_c
function vector_old_c:rounded_zero()
	return vector(
		math.floor(self.x + 0.5),
		math.floor(self.y + 0.5),
		math.floor(self.z + 0.5)
	)
end

--- Round the vector's coordinates.
--- @param precision number
--- @return vector_old_c
function vector_old_c:rounded(precision)
	return vector(
		math.round(self.x, precision),
		math.round(self.y, precision),
		math.round(self.z, precision)
	)
end

--- Clamps the vector's coordinates to the nearest base.
--- @param base number
--- @return vector_old_c
function vector_old_c:rounded_base(base)
	return vector(
		base * math.round(self.x / base),
		base * math.round(self.y / base),
		base * math.round(self.z / base)
	)
end

--- Normalize the vector.
--- @return void
function vector_old_c:normalize()
	local length = self:length()

	-- Prevent possible divide-by-zero errors.
	if (length ~= 0) then
		self.x = self.x / length
		self.y = self.y / length
		self.z = self.z / length
	else
		self.x = 0
		self.y = 0
		self.z = 1
	end
end

--- Returns the normalized length of a vector.
--- @return number
function vector_old_c:normalized_length()
	return self:length()
end

--- Returns a copy of the vector, normalized.
--- @return vector_old_c
function vector_old_c:normalized()
	local length = self:length()

	if (length ~= 0) then
		return vector(
			self.x / length,
			self.y / length,
			self.z / length
		)
	else
		return vector(0, 0, 1)
	end
end

--- Returns a new 2 dimensional vector of the original vector when mapped to the screen, or nil if the vector is off-screen.
--- @return vector_old_c
function vector_old_c:to_screen()
	local x, y = renderer.world_to_screen(self.x, self.y, self.z)

	if (x == nil or y == nil) then
		return nil
	end

	return vector(x, y)
end

--- Returns the magnitude of the vector, use this to determine the speed of the vector if it's a velocity vector.
--- @return number
function vector_old_c:magnitude()
	return math.sqrt(
		math.pow(self.x, 2) +
			math.pow(self.y, 2) +
			math.pow(self.z, 2)
	)
end

--- Returns the angle of the vector in regards to another vector.
--- @param other_vector vector_old_c
--- @return angle_old_c
function vector_old_c:angle_to(other_vector)
	-- Calculate the delta of vectors.
	local delta_vector = vector(other_vector.x - self.x, other_vector.y - self.y, other_vector.z - self.z)

	if (delta_vector.x == 0 and delta_vector.y == 0) then
		return angle((delta_vector.z > 0 and 270 or 90), 0)
	else
		-- Calculate the yaw.
		local yaw = math.deg(math.atan2(delta_vector.y, delta_vector.x))

		-- Calculate the pitch.
		local hyp = math.sqrt(delta_vector.x * delta_vector.x + delta_vector.y * delta_vector.y)
		local pitch = math.deg(math.atan2(-delta_vector.z, hyp))

		return angle(pitch, yaw)
	end
end

--- Returns the result of client.trace_line between two vectors.
--- @param other_vector vector_old_c
--- @param skip_entindex number
--- @return number, number|nil
function vector_old_c:trace_line_to(other_vector, skip_entindex)
	skip_entindex = skip_entindex or 0

	return client.trace_line(
		skip_entindex,
		self.x,
		self.y,
		self.z,
		other_vector.x,
		other_vector.y,
		other_vector.z
	)
end

--- Returns the result of client.trace_bullet between two vectors.
--- @param from_player number
--- @param other_vector vector_old_c
--- @return number|nil, number
function vector_old_c:trace_bullet_to(from_player, other_vector)
	return client.trace_bullet(
		from_player,
		self.x,
		self.y,
		self.z,
		other_vector.x,
		other_vector.y,
		other_vector.z
	)
end

--- Returns the vector of the closest point along a ray.
--- @param source_vector vector_old_c
--- @param target_vector vector_old_c
--- @return vector_old_c
function vector_old_c:closest_ray_point(source_vector, target_vector)
	local direction = (target_vector - source_vector) / source_vector:distance(target_vector)
	local v = self - source_vector
	local length = v:dot_product(direction)

	return source_vector + direction * length
end

--- Returns a point along a ray after dividing it.
--- @param target_vector vector_old_c
--- @param ratio number
--- @return vector_old_c
function vector_old_c:divide_ray(target_vector, ratio)
	return (self * ratio + target_vector) / (1 + ratio)
end

--- Returns the best source vector and destination vector to draw a line on-screen using world-to-screen.
--- @param target_vector vector_old_c
--- @param total_segments number
--- @return vector_old_c|nil, vector_old_c|nil
function vector_old_c:ray(target_vector, total_segments)
	total_segments = total_segments or 128

	local segments = {}
	local step = self:distance(target_vector) / total_segments
	local angle = self:angle_to(target_vector)
	local direction = angle:to_forward_vector()

	for i = 1, total_segments do
		table.insert(segments, self + (direction * (step * i)))
	end

	local src_screen_position = vector(0, 0, 0)
	local dst_screen_position = vector(0, 0, 0)
	local src_in_screen = false
	local dst_in_screen = false

	for i = 1, #segments do
		src_screen_position = segments[i]:to_screen()

		if src_screen_position ~= nil then
			src_in_screen = true

			break
		end
	end

	for i = #segments, 1, -1 do
		dst_screen_position = segments[i]:to_screen()

		if dst_screen_position ~= nil then
			dst_in_screen = true

			break
		end
	end

	if src_in_screen and dst_in_screen then
		return src_screen_position, dst_screen_position
	end

	return nil
end
--endregion

--region angle_vector_methods
--- Returns a forward vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_old_c
function angle_old_c:to_forward_vector()
	local degrees_to_radians = function(degrees) return degrees * math.pi / 180 end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))

	return vector(cp * cy, cp * sy, -sp)
end

--- Return an up vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_old_c
function angle_old_c:to_up_vector()
	local degrees_to_radians = function(degrees) return degrees * math.pi / 180 end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))
	local sr = math.sin(degrees_to_radians(self.r))
	local cr = math.cos(degrees_to_radians(self.r))

	return vector(cr * sp * cy + sr * sy, cr * sp * sy + sr * cy * -1, cr * cp)
end

--- Return a right vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_old_c
function angle_old_c:to_right_vector()
	local degrees_to_radians = function(degrees) return degrees * math.pi / 180 end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))
	local sr = math.sin(degrees_to_radians(self.r))
	local cr = math.cos(degrees_to_radians(self.r))

	return vector(sr * sp * cy * -1 + cr * sy, sr * sp * sy * -1 + -1 * cr * cy, -1 * sr * cp)
end

--- Return a backward vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_old_c
function angle_old_c:to_backward_vector()
	local degrees_to_radians = function(degrees) return degrees * math.pi / 180 end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))

	return -vector(cp * cy, cp * sy, -sp)
end

--- Return a left vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_old_c
function angle_old_c:to_left_vector()
	local degrees_to_radians = function(degrees) return degrees * math.pi / 180 end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))
	local sr = math.sin(degrees_to_radians(self.r))
	local cr = math.cos(degrees_to_radians(self.r))

	return -vector(sr * sp * cy * -1 + cr * sy, sr * sp * sy * -1 + -1 * cr * cy, -1 * sr * cp)
end

--- Return a down vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_old_c
function angle_old_c:to_down_vector()
	local degrees_to_radians = function(degrees) return degrees * math.pi / 180 end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))
	local sr = math.sin(degrees_to_radians(self.r))
	local cr = math.cos(degrees_to_radians(self.r))

	return -vector(cr * sp * cy + sr * sy, cr * sp * sy + sr * cy * -1, cr * cp)
end

--- Calculate where a vector is in a given field of view.
--- @param source_vector vector_old_c
--- @param target_vector vector_old_c
--- @return number
function angle_old_c:fov_to(source_vector, target_vector)
	local fwd = self:to_forward_vector();
	local delta = (target_vector - source_vector):normalized();
	local fov = math.acos(fwd:dot_product(delta) / delta:length());

	return math.max(0.0, math.deg(fov));
end
--endregion
--endregion

--region dependency: havoc_shader_1_4_0
--- @class shader_c
--- @field public r number
--- @field public g number
--- @field public b number
--- @field public h number
--- @field public s number
--- @field public l number
--- @field public a number
--- @field public update_method fun(shader: shader_c, space: number): void
--- @field public rgb_updated boolean
--- @field public hsl_updated boolean
local shader_c = {}
local shader_mt = {
	__index = shader_c,
	--- @param shader shader_c
	__call = function(shader)
		return shader:unpack()
	end
}

--- Returns a string representation of the shader's RGB values.
function shader_mt.__tostring(shader_object)
	return string.format("%s, %s, %s, %s", shader_object.r, shader_object.g, shader_object.b, shader_object.a)
end

--- Concatenates the shader in a string.
function shader_mt.__concat(shader_object)
	return string.format("%s, %s, %s, %s", shader_object.r, shader_object.g, shader_object.b, shader_object.a)
end

--- Create a new shader from RGBA.
--- @param r number
--- @param g number
--- @param b number
--- @param a number
--- @param automatically_update_spaces boolean
--- @return shader_c
function shader_c.rgb(r, g, b, a, automatically_update_spaces)
	if (a == nil) then
		a = 255
	end

	local object = shader_c.new(r, g, b, 0, 0, 0, a, automatically_update_spaces)

	object:validate_rgb_space()
	object:update_hsl_space()

	return object
end

--- Create a new shader from HSLA.
--- @param h number
--- @param s number
--- @param l number
--- @param a number
--- @param automatically_update_spaces boolean
--- @return shader_c
function shader_c.hsl(h, s, l, a, automatically_update_spaces)
	if (a == nil) then
		a = 255
	end

	local object = shader_c.new(0, 0, 0, h, s, l, a, automatically_update_spaces)

	object:validate_hsl_space()
	object:update_rgb_space()

	return object
end

--- Create a new shader from hex.
--- @param hex string
--- @param automatically_update_spaces boolean
--- @return shader_c
function shader_c.hex(hex, automatically_update_spaces)
	local r, g, b, a = shader_c.hex_to_rgb(hex)

	local object = shader_c.new(r, g, b, 0, 0, 0, a, automatically_update_spaces)

	object:validate_rgb_space()
	object:update_hsl_space()

	return object
end

--- Creates a new shader.
--- @param r number
--- @param g number
--- @param b number
--- @param h number
--- @param s number
--- @param l number
--- @param a number
--- @param automatically_update_spaces boolean
--- @return shader_c
function shader_c.new(r, g, b, h, s, l, a, automatically_update_spaces)
	automatically_update_spaces = automatically_update_spaces or false

	local update_method

	-- Either automatically update spaces each change or wait for a call to do so.
	if (automatically_update_spaces == true) then
		update_method = function(shader, space)
			if (space == 0) then
				shader:update_rgb_space()
			else
				shader:update_hsl_space()
			end
		end
	else
		update_method = function(shader, space)
			if (space == 0) then
				shader.rgb_updated = false
			else
				shader.hsl_updated = false
			end
		end
	end

	local properties = {
		r = r,
		g = g,
		b = b,
		h = h,
		s = s,
		l = l,
		a = a,
		update_method = update_method,
		rgb_updated = true,
		hsl_updated = true
	}

	return setmetatable(properties, shader_mt)
end

--- Clones the shader.
--- @return shader_c
function shader_c:clone()
	local properties = {
		r = self.r,
		g = self.g,
		b = self.b,
		h = self.h,
		s = self.s,
		l = self.l,
		a = self.a,
		rgb_updated = true,
		hsl_updated = true,
		update_method = self.update_method
	}

	return setmetatable(properties, shader_mt)
end

--- Unpacks the shader's RGBA properties.
--- @return number, number, number, number
function shader_c:unpack()
	return self.r, self.g, self.b, self.a
end

--- Converts a hex string into RGBA.
--- @param hex string
--- @return number, number, number, number
function shader_c.hex_to_rgb(hex)
	local length = hex:len()

	if (length == 3) then
		local insert = hex:sub(2)

		hex = hex .. insert .. insert
	elseif (length == 4) then
		hex = hex .. hex:sub(2)
	end

	hex = hex:gsub("#","")

	local r = tonumber("0x"..hex:sub(1,2))
	local g = tonumber("0x"..hex:sub(3,4))
	local b = tonumber("0x"..hex:sub(5,6))
	local a = tonumber("0x"..hex:sub(7,8))

	if (a == nil) then
		a = 255
	end

	return r, g, b, a
end

--- Updates shader spaces.
--- @return void
function shader_c:update_spaces()
	if (self.rgb_updated == false) then
		self:update_rgb_space()

		self.rgb_updated = true
	elseif (self.hsl_updated == false) then
		self:update_hsl_space()

		self.hsl_updated = true
	end
end

--- Updates the RGB space.
--- @return void
function shader_c:update_rgb_space()
	local r, g, b

	if (self.s == 0) then
		r, g, b = self.l, self.l, self.l
	else
		local function hue_to_rgb(p, q, t)
			if t < 0   then t = t + 1 end
			if t > 1   then t = t - 1 end
			if t < 1/6 then return p + (q - p) * 6 * t end
			if t < 1/2 then return q end
			if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end

			return p
		end

		local q = 0

		if (self.l < 0.5) then
			q = self.l * (1 + self.s)
		else
			q = self.l + self.s - self.l * self.s
		end

		local p = 2 * self.l - q
		local h = self.h / 360

		r = hue_to_rgb(p, q, h + 1/3)
		g = hue_to_rgb(p, q, h)
		b = hue_to_rgb(p, q, h - 1/3)
	end

	self.r = r * 255
	self.g = g * 255
	self.b = b * 255
end

--- Updates the shader's HSL space.
--- @return void
function shader_c:update_hsl_space()
	local r, g, b = self.r / 255, self.g / 255, self.b / 255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, l

	l = (max + min) / 2

	if (max == min) then
		h, s = 0, 0
	else
		local d = max - min

		if (l > 0.5) then
			s = d / (2 - max - min)
		else
			s = d / (max + min)
		end

		if (max == r) then
			h = (g - b) / d

			if (g < b) then
				h = h + 6
			end
		elseif (max == g) then
			h = (b - r) / d + 2
		elseif (max == b) then
			h = (r - g) / d + 4
		end

		h = (h / 6) * 360
	end

	self.h, self.s, self.l = h, s, l or 255
end

--- Validates the shader's RGB space.
--- @return void
function shader_c:validate_rgb_space()
	self.r = math.min(255, math.max(0, self.r))
	self.g = math.min(255, math.max(0, self.g))
	self.b = math.min(255, math.max(0, self.b))
	self.a = math.min(255, math.max(0, self.a))
end

--- Validates the shader's HSL space.
--- @return void
function shader_c:validate_hsl_space()
	self.h = math.min(360, math.max(0, self.h))
	self.s = math.min(1, math.max(0, self.s))
	self.l = math.min(1, math.max(0, self.l))
	self.a = math.min(255, math.max(0, self.a))
end

--- Set's the shader's red channel.
--- @param r number
--- @return void
function shader_c:set_r(r)
	self.r = r

	self.update_method(self, 1)
end

--- Set's the shader's green channel.
--- @param g number
--- @return void
function shader_c:set_g(g)
	self.g = g

	self.update_method(self, 1)
end

--- Set's the shader's blue channel.
--- @param b number
--- @return void
function shader_c:set_b(b)
	self.b = b

	self.update_method(self, 1)
end

--- Set's the shader's hue property.
--- @param h number
--- @return void
function shader_c:set_h(h)
	self.h = h

	self.update_method(self, 0)
end

--- Set's the shader's saturation property.
--- @param s number
--- @return void
function shader_c:set_s(s)
	self.s = s

	self.update_method(self, 0)
end

--- Set's the shader's lightness property.
--- @param l number
--- @return void
function shader_c:set_l(l)
	self.l = l

	self.update_method(self, 0)
end

--- Set's the shader's alpha channel.
--- @param a number
--- @return void
function shader_c:set_a(a)
	self.a = a
end

--- Returns 0 for white, and 1 for black depending on whether a colour is most visible against white or black.
--- @param tolerance number
--- @return number
function shader_c:contrast(tolerance)
	tolerance = tolerance or 150

	local contrast = self.r * 0.213 + self.g * 0.715 + self.b * 0.072

	if (contrast < tolerance) then
		return 0
	end

	return 1
end

--- Shift the hue of the shader.
--- @param amount number
--- @return void
function shader_c:shift_hue(amount)
	self.h = (self.h + amount) % 360

	self.update_method(self, 0)
end

--- Shift the saturation of the shader--- @param amount number
--- @return void
function shader_c:shift_saturation(amount)
	self.s = math.min(1, math.max(0, self.s + amount))

	self.update_method(self, 0)
end

--- Shift the lightness of the shader.
--- @param amount number
--- @return void
function shader_c:shift_lightness(amount)
	self.l = math.min(1, math.max(0, self.l + amount))

	self.update_method(self, 0)
end

--- Lighten the shader.
--- @param amount number
--- @return void
function shader_c:lighten(amount)
	self.l = math.min(1, math.max(0, self.l + amount))

	self.update_method(self, 0)
end

--- Darken the shader.
--- @param amount number
--- @return void
function shader_c:darken(amount)
	self.l = math.min(1, math.max(0, self.l - amount))

	self.update_method(self, 0)
end

--- Saturate the shader.
--- @param amount number
--- @return void
function shader_c:saturate(amount)
	self.s = math.min(1, math.max(0, self.s + amount))

	self.update_method(self, 0)
end

--- Desaturate the shader.
--- @param amount number
--- @return void
function shader_c:desaturate(amount)
	self.s = math.min(1, math.max(0, self.s - amount))

	self.update_method(self, 0)
end

--- Fade the shader's opacity in.
--- @param amount number
--- @return void
function shader_c:fade_in(amount)
	if (self.a == 255) then
		return
	end

	self.a = self.a + amount

	if (self.a > 255) then
		self.a = 255
	end
end

--- Fade the shader's opacity out.
--- @param amount number
--- @return void
function shader_c:fade_out(amount)
	if (self.a == 0) then
		return
	end

	self.a = self.a - amount

	if (self.a < 0) then
		self.a = 0
	end
end

--- Returns true if the shader is invisible.
--- @return boolean
function shader_c:is_invisible()
	return self.a == 0
end

--- Returns true if the shader is visible.
--- @return boolean
function shader_c:is_visible()
	return self.a > 0
end
--endregion

--region dependency: havoc_timer_4_1_0
--- Timer table.
local timer = {
	--- @type fun(start:boolean, custom:table):timer_standard_c
	standard = nil,
	--- @type fun(start:boolean, count_from:number, custom:table):timer_countdown_c
	countdown = nil,
	--- @type fun(start:boolean, custom:table):timer_tick_c
	tick = nil
}

--region timer_standard
--- @class timer_standard_c
--- @field public started_at number Timer was started at.
--- @field public paused_at number Timer was paused at.
local timer_standard_c = {}
local timer_standard_mt = {
	__index = timer_standard_c,
	__call = function(timer_standard)
		if (timer_standard.started_at == nil) then
			return 0
		end

		if (timer_standard.paused_at ~= nil) then
			return timer_standard.paused_at - timer_standard.started_at
		end

		return globals.realtime() - timer_standard.started_at
	end
}

--- Instantiate timer_standard_c.
--- @param start boolean
--- @param custom table
--- @return timer_standard_c
function timer_standard_c.new(start, custom)
	start = start or false

	local properties = custom or {}

	properties.started_at = nil
	properties.paused_at = nil

	local timer = setmetatable(properties, timer_standard_mt)

	if (start == true) then
		timer:start()
	end

	return timer
end

--- Returns true if the timer was started.
--- @return boolean
function timer_standard_c:has_started()
	return self.started_at ~= nil
end

--- Returns true if the timer is paused.
--- @return boolean
function timer_standard_c:is_paused()
	return self.paused_at ~= nil
end

--- Fires the event callback once the timer has reached the time it was told to count to.
--- @param fire_at number
--- @param callback function
--- @return boolean
function timer_standard_c:event(fire_at, callback)
	if (self() >= fire_at) then
		callback(self)
	end
end

--- Returns true if the seconds argument is greater than or equal to the elapsed time.
--- @param seconds number
--- @return boolean
function timer_standard_c:elapsed(seconds)
	return self() >= seconds
end

--- Tell the timer to start.
--- Calling this while the timer has already started is functionally equivalent to calling :restart().
--- @return void
function timer_standard_c:start()
	self.started_at = globals.realtime()
end

--- Tell the timer to stop.
--- @return void
function timer_standard_c:stop()
	self.started_at = nil
	self.paused_at = nil
end

--- Tell the timer to restart.
--- @return void
function timer_standard_c:restart()
	self:stop()
	self:start()
end

--- Tell the timer to pause.
--- @return void
function timer_standard_c:pause()
	if (self.started_at == nil) then
		return
	end

	self.paused_at = globals.realtime()
end

--- Tell the timer to unpause.
--- @return void
function timer_standard_c:unpause()
	if (self.started_at == nil or self.paused_at == nil) then
		return
	end

	local paused_for = globals.realtime() - self.paused_at

	self.started_at = self.started_at + paused_for
	self.paused_at = nil
end

--- Tell the timer to toggle pause.
--- @return void
function timer_standard_c:toggle_pause()
	if (self.paused_at == nil) then
		self:pause()
	else
		self:unpause()
	end
end

timer.standard = timer_standard_c.new
--endregion

--region timer_tick
--- @class timer_tick_c
--- @field public started_at number Timer was started at.
--- @field public paused_at number Timer was paused at.
local timer_tick_c = {}
local timer_tick_mt = {
	__index = timer_tick_c,
	__call = function(timer_tick)
		if (timer_tick.started_at == nil) then
			return 0
		end

		if (timer_tick.paused_at ~= nil) then
			return timer_tick.paused_at - timer_tick.started_at
		end

		return globals.tickcount() - timer_tick.started_at
	end
}

--- Instantiate timer_tick_c.
--- @param start boolean
--- @param custom table
--- @return timer_tick_c
function timer_tick_c.new(start, custom)
	start = start or false

	local properties = custom or {}

	properties.started_at = nil
	properties.paused_at = nil

	local timer = setmetatable(properties, timer_tick_mt)

	if (start == true) then
		timer:start()
	end

	return timer
end

--- Returns true if the timer was started.
--- @return boolean
function timer_tick_c:has_started()
	return self.started_at ~= nil
end

--- Returns true if the timer is paused.
--- @return boolean
function timer_tick_c:is_paused()
	return self.paused_at ~= nil
end

--- Fires the event callback once the timer has reached the time it was told to count to.
--- @param fire_at number
--- @param callback function
--- @return boolean
function timer_tick_c:event(fire_at, callback)
	if (self() >= fire_at) then
		callback(self)
	end
end

--- Returns true if the seconds argument is greater than or equal to the elapsed time.
--- @param ticks number
--- @return boolean
function timer_standard_c:elapsed(ticks)
	return self() >= ticks
end

--- Tell the timer to start.
--- Calling this while the timer has already started is functionally equivalent to calling :restart().
--- @return void
function timer_tick_c:start()
	self.started_at = globals.tickcount()
end

--- Tell the timer to stop.
--- @return void
function timer_tick_c:stop()
	self.started_at = nil
	self.paused_at = nil
end

--- Tell the timer to restart.
--- @return void
function timer_tick_c:restart()
	self:stop()
	self:start()
end


--- Tell the timer to pause.
--- @return void
function timer_tick_c:pause()
	if (self.started_at == nil) then
		return
	end

	self.paused_at = globals.tickcount()
end

--- Tell the timer to unpause.
--- @return void
function timer_tick_c:unpause()
	if (self.started_at == nil or self.paused_at == nil) then
		return
	end

	local paused_for = globals.tickcount() - self.paused_at

	self.started_at = self.started_at + paused_for
	self.paused_at = nil
end

--- Tell the timer to toggle pause.
--- @return void
function timer_tick_c:toggle_pause()
	if (self.paused_at == nil) then
		self:pause()
	else
		self:unpause()
	end
end

timer.tick = timer_tick_c.new
--endregion

--region timer_countdown
--- @class timer_countdown_c
--- @field public started_at number Timer was started at.
--- @field public paused_at number Timer was paused at.
--- @field public expires_at number Timer expires at.
--- @field public count_from number Timer counts from this to 0.
local timer_countdown_c = {}
local timer_countdown_mt = {
	__index = timer_countdown_c,
	__call = function(timer_countdown)
		if (timer_countdown.started_at == nil) then
			return timer_countdown.count_from
		end

		if (timer_countdown.paused_at ~= nil) then
			return timer_countdown.expires_at - timer_countdown.paused_at
		end

		return timer_countdown.expires_at - globals.realtime()
	end
}

--- Instantiate timer_standard_c.
--- @param start boolean
--- @param custom table
--- @return timer_countdown_c
function timer_countdown_c.new(start, count_from, custom)
	start = start or false

	local properties = custom or {}

	properties.started_at = nil
	properties.paused_at = nil
	properties.expires_at = globals.realtime() + count_from
	properties.count_from = count_from

	local timer = setmetatable(properties, timer_countdown_mt)

	if (start == true) then
		timer:start()
	end

	return timer
end

--- Returns true if the timer was started.
--- @return boolean
function timer_countdown_c:has_started()
	return self.started_at ~= nil
end

--- Returns true if the timer is paused.
--- @return boolean
function timer_countdown_c:is_paused()
	return self.paused_at ~= nil
end

--- Fires the event callback once the timer has reached the time it was told to count to.
--- @param fire_at number
--- @param callback function
--- @return boolean
function timer_countdown_c:event(fire_at, callback)
	if (self() <= fire_at) then
		callback(self)
	end
end

--- Returns true if the timer is 0 or less.
--- @return boolean
function timer_countdown_c:expired()
	return self() <= 0
end

--- Tell the timer to start.
--- Calling this while the timer has already started is functionally equivalent to calling :restart().
--- @return void
function timer_countdown_c:start()
	self.started_at = globals.realtime()
	self.expires_at = globals.realtime() + self.count_from
end

--- Tell the timer to stop.
--- @return void
function timer_countdown_c:stop()
	self.started_at = nil
	self.paused_at = nil
end

--- Tell the timer to restart.
--- @return void
function timer_countdown_c:restart()
	self:stop()
	self:start()
end


--- Tell the timer to pause.
--- @return void
function timer_countdown_c:pause()
	if (self.started_at == nil) then
		return
	end

	self.paused_at = globals.realtime()
end

--- Tell the timer to unpause.
--- @return void
function timer_countdown_c:unpause()
	if (self.started_at == nil or self.paused_at == nil) then
		return
	end

	local paused_for = globals.realtime() - self.paused_at

	self.started_at = paused_for + self.started_at
	self.expires_at = paused_for + self.expires_at
	self.paused_at = nil
end

--- Tell the timer to toggle pause.
--- @return void
function timer_countdown_c:toggle_pause()
	if (self.paused_at == nil) then
		self:pause()
	else
		self:unpause()
	end
end

timer.countdown = timer_countdown_c.new
--endregion
--endregion

--region dependency: havoc_menu_1_1_0
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
local menu_item_c = {}

local menu_item_mt = {
	__index = menu_item_c
}

--- @param item menu_item_c
--- @vararg any
--- @return void
function menu_item_mt.__call(item, ...)
	local args = {...}

	if (#args == 0) then
		return item:get()
	end

	local do_ui_set = {pcall(item.set, item, unpack(args))}

	menu_assert(do_ui_set[1], 4, do_ui_set[2])
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

--region dependency: havoc_console_1_0_0
--region command
local command_c = {}
local command_mt = {__index = command_c}

--- Instantiate a command object.
function command_c.new(name, description, options, on_input)
	local save_value
	local persist_value

	if (options.datatype ~= nil) then
		if (type(options.save_value) == "boolean") then
			save_value = options.save_value
		else
			save_value = true
		end

		if (save_value == true and type(options.persist_value) == "boolean") then
			persist_value = options.persist_value
		else
			persist_value = true
		end
	end

	local properties = {
		name = name, -- Command name.
		description = description, -- Command description.
		on_input = on_input, -- Command callback.
		on_reset = options.on_reset or nil, -- Command callback when input value is reset.
		datatype = options.datatype or nil, -- Command datatype.
		save_value = save_value, -- Save the input value.
		persist_value = persist_value, -- Persist values to database.
		value = options.default or nil, -- Command value.
		default = options.default or nil, -- Command default value.
		input_value = nil, -- Last value that was attempted to be set.
		special = options.special or false -- Will submit console object instead of input values to command.
	}

	local command = setmetatable(properties, command_mt)

	-- Fire the on_load event.
	if (options.on_load ~= nil) then
		options.on_load(command)
	end

	return command
end
--endregion

--region state
local state_c = {}
local state_mt = {__index = state_c}

--- Instantiate a state object.
function state_c.new()
	local properties = {
		problem = false, -- Console crashed processing a command.
		reason = nil -- Reason for crash to print to console.
	}

	local state = setmetatable(properties, state_mt)

	return state
end
--endregion

--region console
local console_c = {}
local console_mt = {__index = console_c}

--- Instantiate a console object.
function console_c.new(prefix, options)
	local properties = {
		prefix = prefix and prefix .. "_" or nil, -- Command name prefix.
		log_prefix = options.log_prefix or string.format("[%s]", prefix), -- Logger prefix.
		log_prefix_color = options.log_prefix_color or {200, 200, 200}, -- Log prefix color.
		debug = false, -- Enable or disable debug type logs.
		commands = {
			[prefix .. "_help"] = command_c.new(
				prefix .. "_help",
				"Display help information for this console command group.",
				{
					special = true
				},
				function(console)
					console:log({}, "Command Help")
					console:log({prefix = false}, "The following list is all of the available commands for this command group.")
					console:log({prefix = false}, " ")

					for _, command in pairs(console.commands) do
						local title = command.datatype ~= nil and string.format("# %s ( %s arg )", command.name, command.datatype) or "# " .. command.name

						console:log({prefix = false}, "--------------------")
						console:log({prefix = false}, title)
						console:log({prefix = false}, command.description)

						if (command.save_value == true and (command.special == false or command.datatype ~= nil)) then
							console:log({prefix = false}, string.format("- current value = %s", command.value))
						end

						if (command.default ~= nil) then
							console:log({prefix = false}, string.format("- default value = %s", command.default))
						end

						if (command.datatype ~= nil) then
							if (command.save_value == true and command.persist_value == true) then
								console:log({prefix = false}, "- persisted = true")
							else
								console:log({prefix = false}, "- persisted = false")
							end
						end

						console:log({prefix = false}, " ")
					end
				end
			),
			[prefix .. "_reset"] = command_c.new(
				prefix .. "_reset",
				"Reset a command to its default value.",
				{
					special = true,
					save_value = false,
					datatype = "string"
				},
				function(console, value)
					if (value == nil) then
						console:log({code = 1}, "This command requires an argument.")

						return
					end

					local command = console.commands[value]

					if (command == nil) then
						console:log({code = 1}, "Command was not found.")

						return
					end

					if (command.default == nil) then
						console:log({code = 1}, "Command does not have a default value to reset to.")

						return
					end

					command.value = command.default

					command.on_reset(command)

					console:log({code = 0}, "Command was reset to its default value of '%s'.", command.default)
				end
			)
		},
		state = state_c.new(),
		cast = {
			-- Cast to string.
			string = function(value, _)
				return value
			end,
			-- Cast to int.
			int = function(value, state, command)
				local value = tonumber(value)

				if (value == nil) then
					state.problem = true
					state.reason = string.format(
						"The argument given to '%s' must be of the type %s.",
						command.name,
						command.datatype
					)

					return nil
				end

				return math.floor(value + 0.5)
			end,
			-- Cast to float.
			float = function(value, state, command)
				local value = tonumber(value)

				if (value == nil) then
					state.problem = true
					state.reason = string.format(
						"The argument given to '%s' must be of the type %s.",
						command.name,
						command.datatype
					)

					return nil
				end

				return value
			end,
			-- Cast to bool.
			bool = function(value, _)
				return value and 1 or 0
			end
		}
	}

	local console = setmetatable(properties, console_mt)

	-- Setup events.
	console:setup_events(console)

	return console
end

--- Assert.
function console_c.assert(expression, level, message, ...)
	if (not expression) then
		error(string.format(message, ...), level)
	end
end

--- Setup game events.
function console_c:setup_events(console)
	-- Hook console input event.
	client.set_event_callback("console_input", function(console_input)
		-- Process console input.
		return console:process(console_input)
	end)

	-- Hook shutdown event for database write.
	client.set_event_callback("shutdown", function()
		for _, command in pairs(console.commands) do
			-- If not a special command and if command has an argument.
			if (command.special == false or command.datatype ~= nil) then

				-- Save current value or persist default.
				if (command.persist_value == true) then
					database.write(
						string.format("havoc_console_%s", command.name),
						command.value
					)
				else
					database.write(
						string.format("havoc_console_%s", command.name),
						command.default
					)
				end

			end
		end
	end)
end

--- Log message to console.
function console_c:log(options, ...)
	-- Do not output debug logs if debugging is not enabled.
	if (self.debug == false and options.debug == true) then
		return
	end

	local prefix = options.prefix
	local code = type(options.code) == "number" and options.code or -1

	-- Print prefix.
	if (prefix == nil or prefix == true) then
		client.color_log(self.log_prefix_color[1], self.log_prefix_color[2], self.log_prefix_color[3], self.log_prefix .. " \0")
	end

	-- Print codes.
	if (self.state.problem == true) then
		client.color_log(255, 75, 75, "[BAD INPUT] \0")
	elseif (code == 0) then
		client.color_log(75, 255, 75, "[SUCCESS] \0")
	elseif (code == 1) then
		client.color_log(255, 75, 75, "[ERROR] \0")
	elseif (code == 2) then
		client.color_log(255, 125, 75, "[WARNING] \0")
	end

	-- Print message string.
	client.color_log(240, 240, 240, string.format(...), "\0")

	-- Color top-left logs.
	if (self.state.problem == true) then
		client.color_log(255, 75, 75, " ")
	elseif (code == 0) then
		client.color_log(75, 255, 75, " ")
	elseif (code == 1) then
		client.color_log(255, 75, 75, " ")
	elseif (code == 2) then
		client.color_log(255, 125, 75, " ")
	else
		client.color_log(240, 240, 240, " ")
	end
end

--- Add a console command.
function console_c:command(name, description, options, on_input)
	console_c.assert(type(name) == "string", 2, "Command name must be strings.")
	console_c.assert(type(description) == "string", 2, "Command description must be strings.")
	console_c.assert(
		type(options) == "table" or type(options) == "nil",
		2,
		"Command options must be a table or nil."
	)
	console_c.assert(type(on_input) == "function", 2, "Command callbacks must be functions.")

	-- Create the command.
	local command = command_c.new(
		self.prefix .. name,
		description,
		options,
		on_input
	)

	-- Update command from database.
	if (command.special == false or command.datatype ~= nil) then
		-- Read from database.
		local value = database.read(
			string.format("havoc_console_%s", command.name)
		)

		-- Only update if a value exists.
		if (value ~= nil) then
			command.value = value
		end

	end

	-- Add the command.
	self.commands[self.prefix .. name] = command
end

--- Process console input.
--- Returns true if command was found. False if not.
function console_c:process(console_input)
	local command = self:_format_console_input(console_input)

	-- Do not process faulty console input.
	if (self.state.problem == true) then
		-- Print problem to console.
		self:log({}, self.state.reason)

		-- Reset state.
		self.state.problem = false

		-- Console command was found.
		-- But do not continue processing the console input.
		return true
	end

	if (command == nil) then
		-- Console command was not found.
		return false
	end

	-- Ignore special commands.
	if (command.special == false) then
		-- Update command's current value.
		if (command.save_value == true) then
			command.value = command.input_value
		end

		-- Call the command's callback.
		command.on_input(command.input_value)
	end

	-- Command was found and executed.
	return true
end

--- Returns command name and command argument (if applicable).
function console_c:_format_console_input(console_input)
	local i = 1
	local name
	local argument

	-- I hate this code too.
	for component in string.gmatch(console_input, "%S+") do
		-- Set command name.
		if (i == 1) then
			name = component
		else
			if (i == 2) then
				-- First argument component.
				argument = component
			else
				-- Other argument components.
				argument = argument .. " " .. component
			end
		end

		i = i + 1
	end

	-- Get the command provided.
	local command = self.commands[name]

	-- Invalid command name.
	if (command == nil) then
		return nil
	end

	-- Run special command callback and return.
	if (command.special == true) then
		command.on_input(self, argument)

		return command
	end

	-- Argument was expected.
	if (command.datatype ~= nil and argument == nil) then
		self.state.problem = true
		self.state.reason = string.format(
			"Command '%s' expects an argument to be given (%s).",
			command.name,
			command.datatype
		)

		return nil
	end

	if (command.datatype ~= nil and argument ~= nil) then
		-- Cast argument to command datatype.
		argument = self.cast[command.datatype](argument, self.state, command)

		-- Set last attempted value.
		command.input_value = argument
	end

	return command
end
--endregion
--endregion
--endregion

--region fps
--- @class fps_c
local fps_c = {}
local fps_mt = {
	__index = fps_c,
	--- Return the current FPS.
	--- @param fps fps_c
	--- @return number
	__call = function(fps)
		return fps:get()
	end
}

--- Instantiate a fps object.
--- @return fps_c
function fps_c.new()
	local properties = {
		frametimes = {},
		fps_prev = 0,
		value_prev = {},
		last_update_time = 0,
		timer = timer.tick(true)
	}

	local fps = setmetatable(properties, fps_mt)

	return fps
end

--- Get the current FPS.
--- @return number
function fps_c:get()
	local rt, ft = globals_realtime(), globals_absoluteframetime()

	if ft > 0 then
		table.insert(self.frametimes, 1, ft)
	end

	local count = #self.frametimes

	if count == 0 then
		return 0
	end

	local accum = 0
	local i = 0

	while accum < 0.5 do
		i = i + 1
		accum = accum + self.frametimes[i]

		if i >= count then
			break
		end
	end

	accum = accum / i

	while i < count do
		i = i + 1

		table.remove(self.frametimes)
	end

	local fps = 1 / accum
	local time_since_update = rt - self.last_update_time

	if math.abs(fps - self.fps_prev) > 4 or time_since_update > 1 then
		self.fps_prev = fps
		self.last_update_time = rt
	else
		fps = self.fps_prev
	end

	return math.floor(fps + 0.5)
end
--endregion

--region simulation
--- @class simulation_c
local simulation_c = {}
local simulation_mt = { __index = simulation_c }

--- Instaniate simulation_c.
--- @return simulation_c
function simulation_c.new(speed)
	local properties = {
		speed = speed, -- Simulation speed.
		frametime = globals_frametime(), -- Simulation frametime.
		delta = 0, -- The simulation delta. Multiply animations by this to correct for FPS.
		frame = 0, -- Simulation current frame.
		fps = fps_c.new(),
		vischeck = {
			this_frame = true, -- Perform particle vischeck this frame.
			interval = 1 -- Perform vischeck every n frames.
		}
	}

	local object = setmetatable(properties, simulation_mt)

	return object
end
--endregion

--region hook
--- @class hook_c
local hook_c = {}
local hook_mt = {__index = hook_c}

--- Instantiate hook_c.
--- @return hook_c
function hook_c.new(id, name, target_version, illusion)
	local properties = {
		id = id, -- Hook ID.
		name = name, -- Hook name.
		target_version = target_version, -- Hook target version.
		illusion = illusion, -- Illusion instance.
		options = {
			simulation = {
				tick = {
					timer = timer.standard(true, {
						interval = 0.015625
					}),
				}
			}
		}
	}

	local hook = setmetatable(properties, hook_mt)

	return hook
end
--endregion

--region hook_manager
--- @class hook_manager_c
local hook_manager_c = {}
local hook_manager_mt = {__index = hook_manager_c}

--- Instantiate hook_manager_c.
--- @return hook_manager_c
function hook_manager_c.new()
	local properties = {
		hooks = {}, -- Illusion hooks.
		count = 0 -- Total hooks.
	}

	local hook_manager = setmetatable(properties, hook_manager_mt)

	return hook_manager
end

--- Add a hook.
--- @return void
function hook_manager_c:add(name, target_version, illusion)
	-- Create a new hook ID.
	local id = self.count + 1

	-- Create and add the new hook.
	self.hooks[name] = hook_c.new(id, name, target_version, illusion)

	-- Update the hook count.
	self.count = id
end

--- Update shared properties etc. for hooks.
--- @return void
function hook_manager_c:update(shared)
	-- Loop all hooks.
	for _, hook in pairs(self.hooks) do
		-- Update shared properties.
		hook.illusion.shared = shared
	end
end
--endregion

--region state
--- @class state_c
local state_c = {}
local state_mt = { __index = state_c }

--- Instaniate state_c.
--- @return state_c
function state_c.new()
	local properties = {
		crashed = false, -- Illusion has crashed.
		enabled = false, -- Illusion is running.
		can_spawn = false -- Illusion can spawn particles (player has an observer mode).
	}

	return setmetatable(properties, state_mt)
end

--- Returns true if the engine is available and has not crashed, false if not.
--- @return boolean
function state_c:available()
	return self.crashed == false and self.enabled == true and self.can_spawn == true
end
--endregion

--region debugger
--- @class debugger_c
local debugger_c = {}
local debugger_mt = { __index = debugger_c }

--- Instaniate debugger_c.
--- @return debugger_c
function debugger_c.new()
	local properties = {
		enabled = false,
		groups = {},
		lines = {},
		color = {
			normal = shader_c.rgb(255, 255, 255),
			good = shader_c.rgb(138, 255, 77),
			blue = shader_c.rgb(18, 217, 255),
			purple = shader_c.rgb(173, 153, 255),
			yellow = shader_c.rgb(219, 184, 3),
			warning = shader_c.rgb(255, 163, 71),
			error = shader_c.rgb(255, 71, 71)
		},
		theme = shader_c.rgb(33, 65, 83)
	}

	return setmetatable(properties, debugger_mt)
end

--- Add or update a debug line.
--- @return void
function debugger_c:line(group, name, contents, color)
	color = color or "normal"

	self.lines[group..name] = {
		group = group,
		name = name,
		contents = contents,
		color = color
	}

	if (self.groups[group] == nil) then
		self.groups[group] = {}
	end

	if (self.groups[group][group..name] == nil) then
		self.groups[group][group..name] = 0
	end
end

--- Render debug lines to screen.
--- @return void
function debugger_c:render()
	if (self.enabled == false) then
		return
	end

	local screen_dimension = vector(client_screen_size())
	local line_position = vector()

	line_position.x = screen_dimension.x / 4
	line_position.y = screen_dimension.y - 80

	local padding = 5
	local line_height = 15
	local width = 350
	local background_color = self.theme
	local title_color = background_color:clone()
	local shift = 0.45

	title_color:lighten(shift)
	title_color:saturate(shift)
	title_color:update_spaces()

	for group_name, group in pairs(self.groups) do
		local group_height = 0

		for line_name, _ in pairs(group) do
			local line = self.lines[line_name]
			local color = self.color[line.color]

			-- Line name.
			renderer_text(
				line_position.x + padding, line_position.y,
				color.r, color.g, color.b, 255,
				"l", 0,
				line.name
			)

			-- Line contents.
			renderer_text(
				line_position.x + width - padding, line_position.y,
				color.r, color.g, color.b, 255,
				"r", 0,
				line.contents
			)

			-- Pad line.
			line_position.y = line_position.y - line_height

			group_height = group_height + line_height
		end

		-- Group name padding.
		line_position.y = line_position.y - padding

		-- Group separator.
		renderer_rectangle(
			line_position.x, line_position.y,
			width, 15,
			background_color.r, background_color.g, background_color.b, 100
		)

		-- Group separator.
		renderer_rectangle(
			line_position.x, line_position.y + line_height,
			width, group_height + 20,
			background_color.r, background_color.g, background_color.b, 25
		)

		-- Group name.
		renderer_text(
			line_position.x + padding, line_position.y,
			title_color.r, title_color.g, title_color.b, 255,
			"l", 0,
			group_name
		)

		-- Group padding.
		line_position.y = line_position.y - 30
	end
end
--endregion

--region particle_callbacks
-- Particle type to particle shape.
local hvc_particle_shape = {
	rectangle = "rectangular",
	texture = "rectangular",
	circle = "circular",
	circle_outline = "circular",
	text = "text"
}

-- Particle align callbacks.
local hvc_particle_align = {
	rectangular = {
		x = {
			--- @param screen_dimension vector_old_c
			--- @return number
			left = function(screen_dimension)
				return screen_dimension.x
			end,
			--- @param screen_dimension vector_old_c
			--- @param draw_dimension vector_old_c
			--- @return number
			right = function(screen_dimension, draw_dimension)
				return screen_dimension.x - draw_dimension.x
			end,
			--- @param screen_dimension vector_old_c
			--- @param draw_dimension vector_old_c
			--- @return number
			center = function(screen_dimension, draw_dimension)
				return screen_dimension.x - (draw_dimension.x / 2)
			end
		},
		y = {
			--- @param screen_dimension vector_old_c
			--- @return number
			top = function(screen_dimension)
				return screen_dimension.y
			end,
			--- @param screen_dimension vector_old_c
			--- @param draw_dimension vector_old_c
			--- @return number
			bottom = function(screen_dimension, draw_dimension)
				return screen_dimension.y - draw_dimension.y
			end,
			--- @param screen_dimension vector_old_c
			--- @param draw_dimension vector_old_c
			--- @return number
			center = function(screen_dimension, draw_dimension)
				return screen_dimension.y - (draw_dimension.y / 2)
			end
		}
	},
	circular = {
		x = {
			--- @param screen_dimension vector_old_c
			--- @param radius number
			--- @return number
			left = function(screen_dimension, radius)
				return screen_dimension.x + radius
			end,
			--- @param screen_dimension vector_old_c
			--- @param radius number
			--- @return number
			right = function(screen_dimension, radius)
				return screen_dimension.x - radius
			end,
			--- @param screen_dimension vector_old_c
			--- @return number
			center = function(screen_dimension)
				return screen_dimension.x
			end
		},
		y = {
			--- @param screen_dimension vector_old_c
			--- @param radius number
			--- @return number
			top = function(screen_dimension, radius)
				return screen_dimension.y + radius
			end,
			--- @param screen_dimension vector_old_c
			--- @param radius number
			--- @return number
			bottom = function(screen_dimension, radius)
				return screen_dimension.y - radius
			end,
			--- @param screen_dimension vector_old_c
			--- @return number
			center = function(screen_dimension)
				return screen_dimension.y
			end
		}
	}
}

-- Gamesense renderer callbacks.
local hvc_call_renderer = {
	--- @param _ nil
	--- @param shader shader_c
	--- @param screen_dimension vector_old_c
	--- @param draw_dimension vector_old_c
	--- @return void
	rectangle = function(_, shader, screen_dimension, draw_dimension)
		renderer_rectangle(
			screen_dimension.x, screen_dimension.y,
			draw_dimension.x, draw_dimension.y,
			shader.r, shader.g, shader.b, shader.a
		)
	end,
	--- @param particle particle_c
	--- @param shader shader_c
	--- @param screen_dimension vector_old_c
	--- @param draw_dimension vector_old_c
	--- @return void
	texture = function(particle, shader, screen_dimension, draw_dimension)
		if (draw_dimension.x <= 4 or draw_dimension.y <= 4) then
			renderer_rectangle(
				screen_dimension.x, screen_dimension.y,
				draw_dimension.x, draw_dimension.y,
				shader.r, shader.g, shader.b, shader.a
			)
		else
			renderer_texture(
				particle.shader.draw.texture,
				screen_dimension.x, screen_dimension.y,
				draw_dimension.x, draw_dimension.y,
				shader.r, shader.g, shader.b, shader.a
			)
		end
	end,
	--- @param particle particle_c
	--- @param shader shader_c
	--- @param screen_dimension vector_old_c
	--- @param radius number
	--- @return void
	circle = function(particle, shader, screen_dimension, radius)
		-- Render rectangles at lower than 2 radius as the API will not attempt to render smaller circles.
		if (radius >= 2) then
			renderer_circle(
				screen_dimension.x, screen_dimension.y,
				shader.r, shader.g, shader.b, shader.a,
				radius,
				particle.shader.draw.start_degrees,
				particle.shader.draw.percentage
			)
		else
			renderer_rectangle(
				screen_dimension.x, screen_dimension.y,
				radius * 2, radius * 2,
				shader.r, shader.g, shader.b, shader.a
			)
		end
	end,
	--- @param particle particle_c
	--- @param shader shader_c
	--- @param screen_dimension vector_old_c
	--- @param radius number
	--- @param thickness number
	--- @return void
	circle_outline = function(particle, shader, screen_dimension, radius, thickness)
		-- Render rectangles at lower than 2 radius as the API will not attempt to render smaller circles.
		if (radius >= 2) then
			renderer_circle_outline(
				screen_dimension.x, screen_dimension.y,
				shader.r, shader.g, shader.b, shader.a,
				radius,
				particle.shader.draw.start_degrees,
				particle.shader.draw.percentage,
				thickness
			)
		else
			renderer_rectangle(
				screen_dimension.x, screen_dimension.y,
				radius * 2, radius * 2,
				shader.r, shader.g, shader.b, shader.a
			)
		end
	end,
	--- @param particle particle_c
	--- @param shader shader_c
	--- @param screen_dimension vector_old_c
	text = function(particle, shader, screen_dimension)
		renderer_text(
			screen_dimension.x, screen_dimension.y,
			shader.r, shader.g, shader.b, shader.a,
			particle.shader.draw.text.flags,
			0,
			particle.shader.draw.text.text
		)
	end
}

-- Particle type render callbacks.
local hvc_particle_render = {
	--- Render rectangular particles.
	--- @param particle particle_c
	--- @param shader shader_c
	--- @param screen_dimension vector_old_c
	rectangular = function(particle, shader, screen_dimension)
		local draw_dimension = {}

		-- If render scale is 0:
		if (particle.render.no_scale == true) then
			-- Render particles at their given dimensions.
			draw_dimension.x = particle.shader.draw.width
			draw_dimension.y = particle.shader.draw.height
		else
			-- Render particles based on the render scale and their distance from the player.
			draw_dimension.x = math.max(1, particle.shader.draw.width / (particle.relation.camera_distance / 100))
			draw_dimension.y = math.max(1, particle.shader.draw.height / (particle.relation.camera_distance / 100))
		end

		particle.shader.rendered.width = draw_dimension.x
		particle.shader.rendered.height = draw_dimension.y

		-- Align the particle.
		screen_dimension.x = hvc_particle_align[particle.shape].x[particle.render.align.x](screen_dimension, draw_dimension)
		screen_dimension.y = hvc_particle_align[particle.shape].y[particle.render.align.y](screen_dimension, draw_dimension)

		-- Render the particle to screen.
		hvc_call_renderer[particle.type](particle, shader, screen_dimension, draw_dimension)
	end,
	--- Render circular particles.
	--- @param particle particle_c
	--- @param shader shader_c
	--- @param screen_dimension vector_old_c
	circular = function(particle, shader, screen_dimension)
		local radius
		local thickness

		-- If render scale is 0:
		if (particle.render.no_scale == true) then
			-- Render particles at their given dimensions.
			radius = particle.shader.draw.radius
		else
			-- Render particles based on the render scale and their distance from the player.
			radius = math.max(0.5, particle.shader.draw.radius / (particle.relation.camera_distance / 100))
		end

		-- Rende scale for circle_outline's thickness.
		if (particle.render.no_scale == true) then
			-- If render scale is 0:
			if (particle.render.no_scale == true) then
				-- Render particles at their given dimensions.
				thickness = particle.shader.draw.thickness
			else
				-- Render particles based on the render scale and their distance from the player.
				thickness = math.max(0.2, particle.shader.draw.thickness / (particle.relation.camera_distance / 100))
			end
		end

		-- Set the particle real rendered dimensions.
		particle.shader.rendered.radius = radius
		particle.shader.rendered.thickness = thickness

		screen_dimension.x = hvc_particle_align[particle.shape].x[particle.render.align.x](screen_dimension, radius)
		screen_dimension.y = hvc_particle_align[particle.shape].y[particle.render.align.y](screen_dimension, radius)

		-- Render the particle to screen.
		hvc_call_renderer[particle.type](particle, shader, screen_dimension, radius, thickness)
	end,
	--- Render text particles.
	--- @param particle particle_c
	--- @param shader shader_c
	--- @param screen_dimension vector_old_c
	text = function(particle, shader, screen_dimension)
		-- Render the particle to screen.
		hvc_call_renderer[particle.type](particle, shader, screen_dimension)
	end,
}
--endregion

--region particle
--- @class particle_c
local particle_c = {}
local particle_mt = {__index = particle_c}

--- Create new particle.
--- @param id number
--- @param hook string
--- @param type string
--- @param particle_vector vector_old_c
--- @param options table
--- @param shared table
--- @return particle_c
function particle_c.new(id, hook, type, particle_vector, options, shared)
	-- Particle options.
	options = options or {}

	-- Particle properties.
	local properties = {
		id = id,
		hook = hook, -- Name of the hook associated with this particle.
		type = type, -- Particle type (rectangle, texture, circle, circle_outline).
		shape = hvc_particle_shape[type], -- Particle shape (rectangular, circular).
		vector = particle_vector, -- Particle origin vector.
		shared = shared, -- Particle shared properties.
		parent = {
			particle = options.parent or nil,
			offset_vector = nil
		},
		children = {}, -- Particle's children table.
		shader = {
			visible = options.visible_shader or shader_c.rgb(255, 255, 255, 255),
			occluded = options.occluded_shader,
			draw = {
				texture = options.texture,
				width = options.width or 1,
				height = options.height or 1,
				radius = options.radius or 2,
				start_degrees = options.start_degrees or 0,
				percentage = options.percentage or 1,
				thickness = options.thickness,
				text = {
					text = options.text,
					flags = options.text_flags or "c+"
				}
			},
			rendered = {
				width = 0, -- Particle actual rendered width.
				height = 0, -- Particle actual rendered height.
				radius = 0, -- Particle actual rendered radius.
				thickness = 0 -- Particle actual rendered thickness.
			}
		},
		render = {
			enabled = true, -- Enable rendering of particle. May be overwritten by user to control rendering.
			no_scale = options.no_scale or false,
			max_distance = options.max_render_distance or 8192,
			always_visible = options.always_visible or false,
			align = {
				x = options.align_x or "center",
				y = options.align_y or "center"
			},
			screen_dimension = nil, -- The screen dimensions of the particle.
			skip_offscreen = options.skip_offscreen or false, -- Skip particles that are not on-screen.
		},
		relation = {
			camera_distance = nil -- Distance of particle to the player's camera.
		},
		state = {
			in_view = false, -- Out of view particles shouldn't process occlusion.
			occluded = false, -- Occluded particles are behind cover.
			dying = false, -- Dying particles are transitioning to the dead state.
			dead = false -- Dead particles must be removed from the particle bag.
		},
		lifespan = {
			timer = timer_standard_c.new(true),
			duration = options.lifespan
		},
		death = {
			fade = {
				time = options.fade_time or 0,
				cull_time = options.cull_fade_time or 0.5,
				use_time = nil, -- Time to use to fade the particle out.
				timer = timer_standard_c.new(),
				visible_alpha = nil, -- Visible shader alpha at time of death.
				occluded_alpha = nil, -- Occluded shader alpha at time of death.
			},
			reason = nil
		},
		custom = options.custom or {},
		cull = {
			distance = options.cull_distance or 32768,
			boundary = vector(options.cull_x or 32768, options.cull_y or 32768, options.cull_z or 32768)
		},
		callback = {
			on_frame = options.on_frame,
			on_tick = options.on_tick,
			on_kill = options.on_kill,
			on_dead = options.on_dead,
			while_dying = options.while_dying
		}
	}

	-- Create the particle.
	--- @type particle_c
	local particle = setmetatable(properties, particle_mt)

	-- Set up a particle that is parented.
	if (options.parent ~= nil) then
		-- The particle vector parameter becomes an offset vector and we add it to the parent vector
		-- to form the final absolute vector.
		particle.vector = options.parent.vector + particle_vector

		-- Create an offset vector that will be used to manipulate the parented particle's position.
		-- The normal particle vector will be overriden using the parent vector added to this vector.
		particle.parent.offset_vector = particle_vector

		-- Add the child to the parent.
		options.parent.children[particle.id] = particle
	end

	-- Update particle-player relationship information.
	particle:update_relation()

	return particle
end

--- Kill the particle with a reason.
--- @param reason string
--- @param force_instant_death boolean
--- @param was_culled boolean
--- @return void
function particle_c:kill(reason, force_instant_death, was_culled)
	-- Immediately remove particles regardless of fade-out properties.
	-- Ignore particle dying state.
	if (force_instant_death == true) then
		self.state.dead = true

		-- Set the reason for death. Medical team will want to know.
		self.death.reason = reason or "none"

		return
	end

	-- Do not attempt to kill an already dying particle.
	if (self.state.dying == true) then
		return
	end

	-- Begin the fade timer if fade on death is enabled.
	if (self.death.fade.time > 0) then
		-- Begin the death timer.
		self.death.fade.timer:start()

		-- Select which time to use.
		self.death.fade.use_time = (was_culled == true and self.death.fade.cull_time ~= nil) and self.death.fade.cull_time or self.death.fade.time

		-- Select the current alpha of the visible shader as the alpha to fade out from.
		self.death.fade.visible_alpha = self.shader.visible.a

		-- Select the current alpha of the occluded shader as the alpha to fade out from.
		if (self.shader.occluded ~= nil) then
			self.death.fade.occluded_alpha = self.shader.occluded.a
		end
	end

	-- Set the particle into a dying state.
	self.state.dying = true

	-- Set the reason for death.
	self.death.reason = reason or "none"

	-- If the particle has children, kill all children as well.
	for _, child in pairs(self.children) do
		child:kill(reason .. " (child)")
	end

	-- Fire the on_kill event.
	if (self.callback.on_kill ~= nil) then
		self.callback.on_kill(self)
	end
end

--- Compute particle frame.
--- @return void
function particle_c:frame()
	-- Don't render particles queued for removal.
	if (self.state.dead == true) then
		return
	end

	-- Update parented particle vector.
	if (self.parent.particle ~= nil) then
		-- The particle vector is the parent vector added to the offset vector.
		self.vector = self.parent.particle.vector + self.parent.offset_vector
	end

	-- Update particle-player relationship information.
	self:update_relation()

	-- Process particle death.
	self:process_death()

	-- Process particle screen dimension.
	self:process_screen_dimension()

	-- Allow vischeck this frame.
	if (self.shared.simulation.vischeck.this_frame == true) then
		-- Process particle vischeck.
		self:process_vischeck()
	end

	-- Particle on_frame callback.
	if (self.callback.on_frame ~= nil) then
		self.callback.on_frame(self)
	end

	-- Render the particle to screen.
	self:render_particle()
end

--- Compute particle tick.
--- @return void
function particle_c:tick()
	-- Don't process particles queued for removal.
	if (self.state.dead == true) then
		return
	end

	-- Process particle cull.
	self:process_cull()

	-- Process particle lifespan.
	self:process_lifespan()

	-- Particle while_dying callback.
	if (self.callback.while_dying ~= nil and self.state.dying == true) then
		self.callback.while_dying(self)
	end

	-- Run the tick-time callback.
	if (self.callback.on_tick ~= nil) then
		self.callback.on_tick(self)
	end
end

--- Process particle lifespan.
--- @return void
function particle_c:process_lifespan()
	-- Do not process lifespan if not set.
	-- Kill the particle if the lifespan timer exceeds the lifespan duration.
	if (self.lifespan.duration ~= nil and self.lifespan.timer() > self.lifespan.duration) then
		self:kill("lifespan expired")
	end
end

--- Process particle cull.
--- @return void
function particle_c:process_cull()
	-- Particle absolute vector.
	local abs_vector = vector(math.abs(self.vector.x), math.abs(self.vector.y), math.abs(self.vector.z))

	-- Cull by distance.
	if (self.cull.distance ~= nil and self.relation.camera_distance > self.cull.distance) then
		self:kill("culled (distance)", false, true)
	-- Cull by boundary.
	elseif (abs_vector > self.cull.boundary) then
		self:kill("culled (exceeded boundary)", false, true)
	end
end

--- Process particle death.
--- @return void
function particle_c:process_death()
	-- If the particle is already dead or dying then ignore.
	if (self.state.dying == false or self.state.dead == true) then
		return
	end

	-- Immediately kill particles that are not set to fade out.
	if (self.death.fade.time == 0) then
		self.state.dead = true

		return
	end

	-- Fade the particles out over the given time period.
	self.shader.visible.a = self.death.fade.visible_alpha *
		(0 - (self.death.fade.timer() - self.death.fade.use_time) / self.death.fade.use_time)

	-- Fade occluded particles.
	if (self.shader.occluded ~= nil) then
		self.shader.occluded.a = self.death.fade.occluded_alpha *
			(0 - (self.death.fade.timer() - self.death.fade.use_time) / self.death.fade.use_time)
	end

	-- If the particle is no longer visible then kill the particle.
	if (self.shader.visible.a <= 0) then
		self.state.dead = true
	end
end

--- Update particle-player relationship information.
--- @return void
function particle_c:update_relation()
	-- Update the distance between particle and the player's camera.
	self.relation.camera_distance = self.vector:distance(self.shared.player.camera_position)
end

--- Process particle screen dimension.
--- @return void
function particle_c:process_screen_dimension()
	-- Get the particle's screen dimensions.
	local screen_dimension = self.vector:to_screen()

	-- Update screen_dimension for particle rendering.
	self.render.screen_dimension = screen_dimension
end

--- Process particle occlusion.
--- @return void
function particle_c:process_vischeck()
	-- Get screen dimension.
	local screen_dimension = self.render.screen_dimension

	-- Do not attempt to determine occlusion of out-of-view particles.
	-- Force the occlusion state to false as we cannot know if the particle is occluded or not.
	-- If skip_offscreen is true then we skip particles whose screen dimension vector falls off the screen.
	if (
		screen_dimension == nil or
		self.render.skip_offscreen == true and (
			screen_dimension.x < 0 or
			screen_dimension.y < 0 or
			screen_dimension.x > self.shared.player.screen.x or
			screen_dimension.y > self.shared.player.screen.y
		)
	) then
		self.state.occluded = false
		self.state.in_view = false

		return
	end

	-- Particle is in view.
	self.state.in_view = true

	-- Don't attempt to determine occlusion on particles that should always be rendered.
	if (self.render.always_visible == true) then
		return
	end

	-- We perform a traceline operation from the view position (3rd person camera) to the particle.
	local visibility_trace

	-- Calculate visibility.
	if (self.shared.player.is_thirdperson == true) then
		_, visibility_trace = self.shared.player.camera_position:trace_line_to(self.vector)
	else
		_, visibility_trace = self.shared.player.camera_position:trace_line_to(
			self.vector,
			self.shared.player.observer.target
		)
	end

	-- Particle is occluded if the trace is anything but -1.
	self.state.occluded = visibility_trace ~= -1
end

--- Render particle to screen.
--- @return void
function particle_c:render_particle()
	-- Do not attempt to render particles who have no screen dimension.
	-- Do not attempt to render particles out of view.
	-- Do not render particles beyond the maximum render distance.
	-- Do not render occluded particles if no occluded shader is set.
	-- Do not render particles whose render mode is disabled.
	if (
		self.render.screen_dimension == nil or
		self.state.in_view == false or
		self.relation.camera_distance > self.render.max_distance or
		self.state.occluded == true and self.shader.occluded == nil or
		self.render.enabled == false
	) then
		return
	end

	-- Particle shader to render.
	local shader

	-- Select the visible or occluded shaders in regards to the particle's occlusion state.
	shader = self.state.occluded and self.shader.occluded or self.shader.visible

	-- Update the shader's color spaces if they have been altered.
	shader:update_spaces()

	-- Do not attempt to render invisible particles.
	if (shader.a == 0) then
		return
	end

	-- Call the appropriate render callback.
	hvc_particle_render[self.shape](self, shader, self.render.screen_dimension)
end
--endregion

--region engine
--- @class engine_c
local engine_c = {}
local engine_mt = { __index = engine_c }

--- Create new Illusion engine.
--- @return engine_c
function engine_c.new(options)
	options = options or {}

	-- Engine properties.
	local properties = {
		-- Shared properties available to particle callbacks.
		shared = {
			player = {
				eid = nil, -- Player entity index.
				origin = vector(0, 0, 0), -- Player vector origin.
				eye_position = vector(0, 0, 0), -- Player first person camera orbit.
				camera_position = vector(0, 0, 0), -- Player first or third person camera position.
				speed = 0, -- Player speed.
				velocity = vector(0, 0, 0), -- Player velocity vector.
				camera_angles = angle(0, 0, 0), -- Player eye angles.
				is_thirdperson = nil, -- Player is in thirdperson view.
				dead = nil, -- Player is dead.
				field_of_view = nil, -- Player field of view.
				camera_aspect = nil, -- Camera aspect.
				is_scoped = nil, -- Player is scoped.
				-- Screen size.
				screen = {
					x = 0, -- X size.
					y = 0 -- Y size.
				},
				zoom = {
					-- 0 = unscoped, 1 = 1st level scope, 2 = 2nd level scope.
					level = nil, -- Player's zoom level.
					field_of_view = nil, -- Player's zoom field of view.
					mod = nil, -- Zoom field of view modifier.
				},
				observer = {
					-- 0 = Alive.
					-- 1 = Death cam.
					-- 2 = Freeze cam.
					-- 3 = Fixed cam.
					-- 4 = First person spectator.
					-- 5 = Third person spectator.
					-- 6 = Free mode.
					mode = nil, -- Observer mode.
					-- 1 = spectator, 2 = terrorist, 3 = counter-terrorist.
					target = nil, -- Observer target.
					team = nil, -- Observer team.
					observing_self = nil -- Observer is targeting local player.
				}
			},
			simulation = simulation_c.new(100)
		},
		-- Particle management properties.
		particle = {
			bag = {}, -- Particle table.
			hook_bag = {}, -- Particle table indexed by sub-table of their hooks.
			hard_limit = 512,
			soft_limit = 1024,
			total = 0, -- Total of particles ever spawned.
			alive = 0, -- Current alive particles.
			oldest_culled = 1, -- Oldest culled particle.
			show_death_reasons = false -- Show death logs when particles die.
		},
		-- Engine core modules and data.
		core = {
			version = "#ENGINE_VERSION#", -- Engine version.
			uid = "#ENGINE_UID#", -- Engine build UUID.
			build_date = "#BUILD_DATE#",
			state = state_c.new(), -- Engine state manager.
			debugger = debugger_c.new(), -- Debugger.
			-- Console utility.
			console = console_c.new("hvci", {
				log_prefix = "[Illusion]",
				log_prefix_color = {240, 206, 72}
			}),
			-- Panic module.
			panic = panic_c.new(function(console, state, version, uid)
				-- Log the shutdown to console.
				console:log({code = 1}, "Encountered a fatal error and shut down. This may have been caused by one of your Illusion addons.")
				console:log({code = 1}, string.format(
					"PLEASE PROVIDE THE FOLLOWING TEXT FOR BUG REPORTING: {version: '%s', uid: '%s'}",
					version,
					uid
				))
				console:log({code = 1}, "The above information is critical if you are reporting this crash.")

				-- Set the engine state to crashed.
				state.crashed = true
			end),
			hook_manager = hook_manager_c.new() -- Scripts using the engine.
		},
		-- Menu references.
		reference = {
			override_fov = ui.reference("misc", "miscellaneous", "override fov"), -- Field of view override.
			override_zoom_fov = ui.reference("misc", "miscellaneous", "override zoom fov"), -- Scoped field of view override.
			duck_peek_assist = ui.reference("rage", "other", "duck peek assist")
		},
		-- Engine options.
		options = {
			ignore_outdated_hook_warnings = false -- Ignore warnings about hooks that may be outdated.
		}
	}

	-- Create the engine object.
	--- @type engine_c
	local engine = setmetatable(properties, engine_mt)

	-- Update can engine spawn particles state.
	-- This prevents the engine outputting errors, or attempting to run out-of-game.
	engine:update_can_spawn()

	-- Update initial shared properties.
	engine:update_shared()

	-- Set up console commands.
	engine:setup_console_commands()

	-- Delay certain actions until after Illusion has been fully loaded.
	if (options.silent_startup == false) then
		client_delay_call(0.01, function()
			-- Log successful startup.
			engine.core.console:log({code = 0}, "The render engine started up successfully.")
			engine.core.console:log({}, "Engine version: %s.", engine.core.version)
			engine.core.console:log({}, "Engine UID: %s.", engine.core.uid)
			engine.core.console:log({}, "Engine build date: %s.", engine.core.build_date)
		end)
	end

	return engine
end

--- Set up console commands.
--- @return void
function engine_c:setup_console_commands()
	self.core.console:command(
		"wipe",
		"Wipe all existing particles.",
		{},
		function()
			self:wipe()

			self.core.console:log({code = 0}, "Reset the particle bag successfully.")
		end
	)

	-- Soft limit.
	self.core.console:command(
		"soft_limit",
		"Override the soft particle limit.",
		{
			datatype = "int",
			persist_value = false,
			save_value = false,
			on_load = function(command)
				command.default = self.particle.soft_limit
			end,
			on_reset = function(command)
				self.particle.soft_limit = command.value
			end
		},
		function(value)
			if (value > 32768) then
				self.core.console:log({code = 1}, "Cannot set the soft particle limit over 32768.")

				return
			elseif (value < 16) then
				self.core.console:log({code = 1}, "Cannot set the soft particle limit below 16.")

				return
			end

			if (value > self.particle.hard_limit) then
				self.core.console:log(
					{code = 1},
					"Cannot set the soft particle limit over the hard limit (%s). Please modify hvci_hard_limit first.",
					self.particle.hard_limit
				)

				return
			end

			self.particle.soft_limit = value

			self.core.console:log({code = 0}, "Overriden the soft particle limit to '%s'.", value)
		end
	)

	-- Hard limit.
	self.core.console:command(
		"hard_limit",
		"Override the hard particle limit.",
		{
			datatype = "int",
			persist_value = false,
			save_value = false,
			on_load = function(command)
				command.default = self.particle.hard_limit
			end,
			on_reset = function(command)
				self.particle.hard_limit = command.value
			end
		},
		function(value)
			if (value > 32768) then
				self.core.console:log({code = 1}, "Cannot set the hard particle limit over 32768.")

				return
			elseif (value < 16) then
				self.core.console:log({code = 1}, "Cannot set the hard particle limit below 16.")

				return
			end

			if (value < self.particle.soft_limit) then
				self.core.console:log(
					{code = 1},
					"Cannot set the hard particle limit under the soft limit (%s). Please modify hvci_soft_limit first.",
					self.particle.soft_limit
				)

				return
			end

			self.particle.hard_limit = value

			self.core.console:log({code = 0}, "Overriden the hard particle limit to '%s'.", value)
		end
	)
end

--- Returns true if particles can run their vischecks. False if not.
--- At higher FPS this will cause particles to skip doing vischecking more often.
--- This is potentially the stupidest FPS optimization in this project. It is literally designed to make
--- your FPS worse the lower your FPS gets. However it also works wonderfully.
--- @return void
function engine_c:vischeck_frame_interval()
	-- Determine the interval at which to process vischecking.
	local vischeck_interval = math.max(1, math.floor(self.shared.simulation.fps() / 33))

	-- Update interval.
	self.shared.simulation.vischeck.interval = vischeck_interval

	-- Update whether vischecking occurs on the current frame.
	self.shared.simulation.vischeck.this_frame = self.shared.simulation.frame % vischeck_interval == 0
end

--- Compute frame-time tasks.
--- @return void
function engine_c:compute_frame()
	-- Update can engine spawn particles state.
	self:update_can_spawn()

	-- Do not run if the engine is not enabled.
	if (self.core.state:available() ~= true) then
		return
	end

	-- Increment the simulation frame counter.
	self.shared.simulation.frame = self.shared.simulation.frame + 1

	-- Update player information and other shared properties.
	self:update_shared()

	-- Cull particles over the max particle limit.
	self:cull_max_particles()

	-- Count of all hooks' alive particles.
	local hook_counter = {}

	-- Add every hook to the hook counter.
	for _, hook in pairs(self.core.hook_manager.hooks) do
		hook_counter[hook.name] = 0
	end

	-- Loop every particle.
	for _, particle in spairs(self.particle.bag, function(bag, particle_a, particle_b)
		return bag[particle_b].relation.camera_distance < bag[particle_a].relation.camera_distance
	end) do
		-- Process particle frame.
		particle:frame()

		-- Increment hook counter for the hook owning the particle.
		hook_counter[particle.hook] = hook_counter[particle.hook] + 1
	end

	-- Compute particle tick-time.
	self:compute_tick()

	-- Set every hook's alive particle count.
	for _, hook in pairs(self.core.hook_manager.hooks) do
		hook.illusion.particle.alive = hook_counter[hook.name]
	end

	-- Render debug text panel if debugging is enabled.
	if (self.core.debugger.enabled == true) then
		self:debug_particle()
		self:debug_shared()
		self:debug_engine()
		self.core.debugger:render()
	end
end

--- Process particle tick-time.
--- @return void
function engine_c:compute_tick()
	-- Process each hook.
	for hook_name, hook in pairs(self.particle.hook_bag) do
		-- Hook's tick timer.
		local hook_tick_timer = self.core.hook_manager.hooks[hook_name].options.simulation.tick.timer

		-- Only process particle tick-time event when the timer elapses.
		hook_tick_timer:event(hook_tick_timer.interval, function(timer)
			-- Process ticks for all particles belonging to the hook.
			for _, particle in pairs(hook) do
				-- Remove dead particles from the bag and skip them.
				self:particle_death(particle)

				-- Process particle ticks.
				particle:tick()
			end

			-- Restart timer.
			timer:restart()
		end)
	end
end

--- Remove the oldest extant particle.
--- @return void
function engine_c:cull_max_particles()
	-- todo oldest_culled might be wrong for particles with varied lifespans or killed out of order.
	-- Number of particles to cull this frame.
	local cull_queue = self.particle.alive - self.particle.soft_limit

	-- Predicted alive particle count.
	local predicted_alive = self.particle.alive

	-- Skip if there's no need to cull any particles.
	if (cull_queue <= 0) then
		return
	end

	-- Loop over particles beginning from the oldest spawned extant particle.
	for goal_particle_id = self.particle.oldest_culled, self.particle.total do
		-- Break when the cull queue hits 0.
		if (cull_queue <= 0) then
			break
		end

		-- Particle to check.
		local particle = self.particle.bag[goal_particle_id]
		local can_cull = true

		-- todo remove cull queue check.
		if (cull_queue <= 0 or particle == nil) then
			can_cull = false
		end

		-- Cull the particle.
		if (can_cull == true) then
			particle:kill("culled (max particles reached)", predicted_alive > self.particle.hard_limit, true)

			-- Reduce alive and cull queue values.
			cull_queue = cull_queue - 1
			predicted_alive = predicted_alive - 1
		end
	end
end

--- Remove dead particles from the bag.
--- @param particle particle_c
--- @return void
function engine_c:particle_death(particle)
	-- If the particle is dead:
	if (particle.state.dead == true) then
		-- Call the on_dead callback.
		if (particle.callback.on_dead ~= nil) then
			particle.callback.on_dead(particle)
		end

		-- Remove particle from the bag.
		self:remove(particle)
	end
end

--- Wipe the particle bag.
--- @return void
function engine_c:wipe()
	self.particle.bag = {}
	self.particle.total = 0
	self.particle.alive = 0
	self.particle.oldest_culled = 1
end

--- Remove a particle from the bag.
--- @param particle particle_c
--- @return void
function engine_c:remove(particle)
	-- Remove the particle from the bag.
	self.particle.bag[particle.id] = nil

	-- Remove particle from the hook-indexed bag.
	self.particle.hook_bag[particle.hook][particle.id] = nil

	-- Update alive particle count.
	self.particle.alive = self.particle.alive - 1

	-- Update the oldest culled particle index.
	self.particle.oldest_culled = particle.id

	-- Show death logs.
	if (self.particle.show_death_reasons == true) then
		self.core.console:log({}, "Particle #%s killed: %s", particle.id, particle.death.reason)
	end
end

--- Update whether or not the engine is permitted to spawn or process particles.
--- Prevents attempting to use Illusion when not in an observer mode.
--- @return void
function engine_c:update_can_spawn()
	-- Get the player's entity index.
	local player = entity_get_local_player()

	-- Get the player's observer mode.
	local observer_mode = entity_get_prop(player, "m_iObserverMode")

	-- Update engine state's ability to spawn particles.
	self.core.state.can_spawn = observer_mode ~= nil
end

--- Update shared properties.
--- @return void
function engine_c:update_shared()
	-- Get the player's entity index.
	local player = entity_get_local_player()

	-- Update player entity index.
	self.shared.player.eid = player

	-- Get the player's observer mode.
	local observer_mode = entity_get_prop(player, "m_iObserverMode")

	-- We're not in-game. Do not attempt to update shared properties.
	if (observer_mode == nil) then
		return
	end

	-- Set the shared observer mode.
	self.shared.player.observer.mode = observer_mode

	-- Get the observer target. Default to local player unless they are spectating.
	local observer_target = entity_get_local_player()

	-- Player is viewing themselves.
	local observing_self = true

	-- Set the observer target to the spectated player.
	if (observer_mode == 4 or observer_mode == 5) then
		observer_target = entity_get_prop(player, "m_hObserverTarget")
		observing_self = false
	end

	-- Set observing self.
	self.shared.player.observer.observing_self = observing_self

	-- Get the observer team.
	local observer_team = entity_get_prop(observer_target, "m_iTeamNum")

	-- Set the shared observer target.
	self.shared.player.observer.target = observer_target

	-- Set the shared observer team.
	self.shared.player.observer.team = observer_team

	-- Update frametime.
	self.shared.simulation.frametime = globals_frametime()

	-- Update simulation delta.
	self.shared.simulation.delta = self.shared.simulation.frametime * self.shared.simulation.speed

	-- Update vischecking.
	self:vischeck_frame_interval()

	-- Get player absolute origin.
	local origin_x, origin_y, origin_z = entity_get_prop(player, "m_vecAbsOrigin")

	-- Update player origin.
	self.shared.player.origin(origin_x, origin_y, origin_z)

	-- Player is fake ducking.
	local is_fake_ducking = ui.get(self.reference.duck_peek_assist)

	-- If the player is fake ducking, we want to manually calculate the eye position,
	-- to compensate for the "up and down" motion that fake ducking generates.
	if (is_fake_ducking == true) then
		-- Update player eye position.
		self.shared.player.eye_position = self.shared.player.origin:clone_offset(0, 0, 46)
	else
		-- Get player eye position.
		local eye_position_x, eye_position_y, eye_position_z = client_eye_position()

		-- Update player eye position.
		self.shared.player.eye_position(eye_position_x, eye_position_y, eye_position_z)
	end

	-- Get player camera position.
	local camera_position_x, camera_position_y, camera_position_z = client_camera_position()

	-- Update player camera view position.
	self.shared.player.camera_position(camera_position_x, camera_position_y, camera_position_z)

	-- Update player is thirdperson shared property.
	self.shared.player.is_thirdperson = self.shared.player.eye_position:distance(self.shared.player.camera_position) > 5

	-- Get player camera angles.
	local camera_angle_p, camera_angle_y = client_camera_angles()

	-- Update player eye angles.
	self.shared.player.camera_angles(camera_angle_p, camera_angle_y)

	-- Get player velocity.
	local velocity_x, velocity_y, velocity_z = entity_get_prop(player, "m_vecVelocity")

	-- Update player velocity vector.
	self.shared.player.velocity(velocity_x, velocity_y, velocity_z)

	-- Update player speed.
	self.shared.player.speed = self.shared.player.velocity:magnitude()

	-- Update player field of view.
	self.shared.player.field_of_view = ui.get(self.reference.override_fov)

	local screen_x, screen_y = client_screen_size()

	-- Update camera aspect.
	self.shared.player.camera_aspect = screen_x / screen_y

	-- Update player screen size.
	self.shared.player.screen.x = screen_x
	self.shared.player.screen.y = screen_y

	-- Update player is scoped.
	self.shared.player.is_scoped = entity_get_prop(player, "m_bIsScoped") == 1 and true or false

	-- Update player zoom field of view setting.
	self.shared.player.zoom.mod = ui.get(self.reference.override_zoom_fov) / 100

	-- Get player zoom field of view.
	local zoom_field_of_view = entity_get_prop(player, "m_iFOV")

	-- Correct 0 fov to real fov.
	if (zoom_field_of_view == 0 or zoom_field_of_view == 90) then
		zoom_field_of_view = self.shared.player.field_of_view
	end

	-- Update player zoom field of view.
	self.shared.player.zoom.field_of_view = zoom_field_of_view

	-- Get the player's zoom level.
	local zoom_level = 0

	if (self.shared.player.is_scoped == true and zoom_field_of_view == 40) then
		zoom_level = 1
	elseif (self.shared.player.is_scoped == true and zoom_field_of_view == 15) then
		zoom_level = 2
	end

	-- Update player zoom level.
	self.shared.player.zoom.level = zoom_level

	-- Update player alive state.
	self.shared.player.dead = observer_mode ~= 0
end

--- Returns the engine version as a table.
--- @param version table
--- @return void
function engine_c:transcode_version(version)
	-- Version regex match.
	local version_split = string.gmatch(version, "[0-9]+")

	-- Semantic versioning table map.
	local version_map = {"major", "minor", "patch"}

	-- Version.
	local version = {}

	local index = 1

	for version_index in version_split do
		-- Convert version part to number.
		version_index = tonumber(version_index)

		-- Ensure version is correct.
		if (type(version_index) ~= "number" or version_map[index] == nil) then
			return nil
		end

		version[version_map[index]] = version_index

		index = index + 1
	end

	-- Ensure version is correct.
	if (index ~= 4) then
		return nil
	end

	return version
end

--- Add a hook to the engine.
--- @param hook_name string
--- @param target_version string
--- @param hash string
--- @param illusion_cn string
--- @return illusion_c|nil
function engine_c:hook(hook_name, target_version, hash, illusion_cn)
	-- Transcoded engine version.
	local current_version_transcoded = self:transcode_version(self.core.version)

	-- Transcoded hook version.
	local target_version_transcoded = self:transcode_version(target_version)

	current_version_transcoded = {
		major = 1,
		minor = 0,
		patch = 0
	}

	target_version_transcoded = {
		major = 1,
		minor = 0,
		patch = 0
	}

	-- Assert that the given preferred version is valid.
	assert(
		type(target_version_transcoded) == "table",
		"[Havoc Illusion] the hook version provided to Illusion must be valid (i.e. '1.2.3')"
	)

	-- Check if hook version is a mismatch with the engine's major version.
	if (self.options.ignore_outdated_hook_warnings == false and target_version_transcoded.major < current_version_transcoded.major) then
		-- Delay call so that it displays after all other hooks.
		client_delay_call(0.015, function()
			self.core.console:log({code = 2}, string.format(
				"%s was intended for Havoc Illusion version %s, but your version of Havoc Illusion is %s.",
				hook_name,
				target_version,
				self.core.version
			))

			self.core.console:log({code = 2}, string.format(
				"You may want to check if %s has any updates.",
				hook_name
			))
		end)
	elseif (target_version_transcoded.major > current_version_transcoded.major) then
		-- Delay call so that it displays after all other hooks.
		client_delay_call(0.015, function()
			self.core.console:log({code = 2}, string.format(
				"%s was intended for Havoc Illusion version %s, but your version of Havoc Illusion is %s.",
				hook_name,
				target_version,
				self.core.version
			))

			self.core.console:log({code = 2}, "You may want to check if Havoc Illusion has any updates.")
		end)
	end

	if (hash ~= "#ENGINE_UID#:#HOOK_UID#") then
		self.core.console:log({code = 1}, "Failed to hook Illusion due to an internal build error.")

		return nil
	else
		-- Create the Illusion object.
		local illusion = illusion_cn.new(hook_name)

		-- Add the hook to the hooks list.
		self.core.hook_manager:add(hook_name, target_version_transcoded, illusion)

		-- Create the index for the hook-indexed particle bag.
		self.particle.hook_bag[hook_name] = {}

		-- Delay the console log.
		client_delay_call(0.015, function()
			self.core.console:log({code = 0}, string.format(
				"%s was successfully hooked to the render engine.",
				hook_name
			))
		end)

		return illusion
	end
end

--- Process particle debug lines.
--- @return void
function engine_c:debug_particle()
	-- Soft max particle color.
	local soft_max_color = "normal"

	if (self.particle.soft_limit > 4096) then
		soft_max_color = "error"
	elseif (self.particle.soft_limit > 2048) then
		soft_max_color = "warning"
	elseif (self.particle.soft_limit > 1024) then
		soft_max_color = "yellow"
	end

	-- Soft max particle count.
	self.core.debugger:line("particle", "max particles (soft)", self.particle.soft_limit, soft_max_color)

	-- Hard max particle color.
	local hard_max_color = "normal"

	if (self.particle.hard_limit > 4096) then
		hard_max_color = "error"
	elseif (self.particle.hard_limit > 2048) then
		hard_max_color = "warning"
	elseif (self.particle.hard_limit > 1024) then
		hard_max_color = "yellow"
	end

	-- Hard max particle count.
	self.core.debugger:line("particle", "max particles (hard)", self.particle.hard_limit, hard_max_color)

	-- Alive particles color.
	local alive_particle_color = "normal"

	if (self.particle.alive >= self.particle.hard_limit) then
		alive_particle_color = "error"
	elseif (self.particle.alive > self.particle.soft_limit) then
		alive_particle_color = "warning"
	end

	self.core.debugger:line("particle", "alive particles", self.particle.alive, alive_particle_color)
	self.core.debugger:line("particle", "particles spawned", self.particle.total)
	self.core.debugger:line("particle", "oldest culled particle", self.particle.oldest_culled)
end

--- Process shared debug lines.
--- @return void
function engine_c:debug_shared()
	self.core.debugger:line("player", "entity index", self.shared.player.eid)
	self.core.debugger:line("player", "origin", self.shared.player.origin:rounded_zero())
	self.core.debugger:line("player", "eye position", self.shared.player.eye_position:rounded_zero())
	self.core.debugger:line("player", "view position", self.shared.player.camera_position:rounded_zero())
	self.core.debugger:line("player", "speed", math.round(self.shared.player.speed, 0))
	self.core.debugger:line("player", "velocity (magnitude)", self.shared.player.velocity:rounded_zero())
	self.core.debugger:line("player", "camera angles", self.shared.player.camera_angles:rounded_zero())
	self.core.debugger:line("player", "camera mode", self.shared.player.is_thirdperson and "third person" or "first person")
	self.core.debugger:line("player", "state", self.shared.player.dead == true and "dead" or "alive")
	self.core.debugger:line("player", "is scoped", self.shared.player.is_scoped and "is scoped" or "not scoped")
	self.core.debugger:line("player", "camera aspect", math.round(self.shared.player.camera_aspect, 4))
	self.core.debugger:line("player", "field of view", self.shared.player.field_of_view)
	self.core.debugger:line("player", "zoom field of view", self.shared.player.zoom.field_of_view)
	self.core.debugger:line("player", "zoom level", self.shared.player.zoom.level)

	self.core.debugger:line("simulation", "speed", self.shared.simulation.speed)
	self.core.debugger:line("simulation", "frametime", math.round(self.shared.simulation.frametime, 3))
	self.core.debugger:line("simulation", "delta", math.round(self.shared.simulation.delta, 3))
	self.core.debugger:line("simulation", "frame", self.shared.simulation.frame)
	self.core.debugger:line("simulation", "fps", self.shared.simulation.fps())
	self.core.debugger:line("simulation", "vischeck interval", self.shared.simulation.vischeck.interval)

	local observer_mode

	if (self.shared.player.observer.mode == 0) then
		observer_mode = "self cam"
	elseif (self.shared.player.observer.mode == 1) then
		observer_mode = "death cam"
	elseif (self.shared.player.observer.mode == 2) then
		observer_mode = "freeze cam"
	elseif (self.shared.player.observer.mode == 3) then
		observer_mode = "fixed cam"
	elseif (self.shared.player.observer.mode == 4) then
		observer_mode = "first person spectate"
	elseif (self.shared.player.observer.mode == 5) then
		observer_mode = "third person spectate"
	elseif (self.shared.player.observer.mode == 6) then
		observer_mode = "free roam cam"
	end

	local observer_team

	if (self.shared.player.observer.team == 1) then
		observer_team = "spectator"
	elseif (self.shared.player.observer.team == 2) then
		observer_team = "terrorist"
	elseif (self.shared.player.observer.team == 3) then
		observer_team = "counter-terrorist"
	else
		observer_team = "no team"
	end

	local observing

	if (self.shared.player.observer.target == nil) then
		observing = "nobody"
	elseif (self.shared.player.observer.observing_self == true) then
		observing = "self"
	else
		observing = "other player"
	end

	self.core.debugger:line("observer", "mode", observer_mode)
	self.core.debugger:line("observer", "target", self.shared.player.observer.target or "no target")
	self.core.debugger:line("observer", "team", observer_team)
	self.core.debugger:line("observer", "observing", observing)
end

--- Process engine debug lines.
--- @return void
function engine_c:debug_engine()
	-- Show number of hooks.
	self.core.debugger:line("engine", "hooks", self.core.hook_manager.count)

	-- Format the list of hooks.
	for _, hook in pairs (self.core.hook_manager.hooks) do
		self.core.debugger:line(
			"hooks",
			string.format(
				"%s (for %s)",
				hook.name,
				string.format("%s.%s.%s", hook.target_version.major, hook.target_version.minor, hook.target_version.patch)
			),
			string.format(
				"total	%s | alive	%s",
				hook.illusion.particle.total,
				hook.illusion.particle.alive
			)
		)
	end

	-- Show list of hooks.
	self.core.debugger:line("engine", "version", self.core.version)
	self.core.debugger:line("engine", "uid", self.core.uid)
	self.core.debugger:line("engine", "build date", self.core.build_date)
end
--endregion

--region animation
--- @class animation_c
local animation_c = {}
local animation_mt = { __index = animation_c }

--- Instantiate animation_c.
--- @return animation_c
function animation_c.new()
	return setmetatable({}, animation_mt)
end

--- Floating animation (X axis).
---
--- The sync time keeps the start positions of the animations consistent. Avoid using server/system times.
--- Prefer using timer_standard_c (illusion.timer_standard).
---
--- @param particle particle_c
--- @param amplitude number
--- @param frequency number
--- @param sync_time number
--- @return void
function animation_c:float_x(particle, amplitude, frequency, sync_time)
	particle.vector.x = particle.vector.x +
		math.sin(sync_time * math.pi * frequency) * amplitude * particle.shared.simulation.delta
end

--- Floating animation (Y axis).
---
--- The sync time keeps the start positions of the animations consistent. Avoid using server/system times.
--- Prefer using timer_standard_c (illusion.timer_standard).
---
--- @param particle particle_c
--- @param amplitude number
--- @param frequency number
--- @param sync_time number
--- @return void
function animation_c:float_y(particle, amplitude, frequency, sync_time)
	particle.vector.y = particle.vector.y +
		math.sin(sync_time * math.pi * frequency) * amplitude * particle.shared.simulation.delta
end

--- Floating animation (Z axis).
---
--- The sync time keeps the start positions of the animations consistent. Avoid using server/system times.
--- Prefer using timer_standard_c (illusion.timer_standard).
---
--- @param particle particle_c
--- @param amplitude number
--- @param frequency number
--- @param sync_time number
--- @return void
function animation_c:float_z(particle, amplitude, frequency, sync_time)
	particle.vector.z = particle.vector.z +
		math.sin(sync_time * math.pi * frequency) * amplitude * particle.shared.simulation.delta
end

--- Move to a target at a given speed.
--- @param particle particle_c
--- @param target_v vector_old_c
--- @param speed number
--- @return void
function animation_c:move_target(particle, target_v, speed)
	particle.vector = particle.vector + (target_v - particle.vector) * speed * particle.shared.simulation.delta
end

--- Move along a forward vector at a given speed.
--- @param particle particle_c
--- @param forward_v vector_old_c
--- @param speed number
--- @return void
function animation_c:move_forward(particle, forward_v, speed)
	particle.vector = particle.vector + forward_v * speed * particle.shared.simulation.delta
end

--- Move to a target at a smoothed out speed.
--- @param particle particle_c
--- @param target_v vector_old_c
--- @param rigidity number
--- @param speed number
--- @return void
function animation_c:move_target_smooth(particle, target_v, rigidity, speed)
	particle.vector = particle.vector + (target_v - particle.vector) * rigidity * speed * particle.shared.simulation.delta
end

--- Move along a forward vector at a smoothed out speed.
--- @param particle particle_c
--- @param forward_v vector_old_c
--- @param rigidity number
--- @param speed number
--- @return void
function animation_c:move_forward_smooth(particle, forward_v, rigidity, speed)
	particle.vector = particle.vector + forward_v * rigidity * speed * particle.shared.simulation.delta
end
--endregion

--region illusion
-- Create the rendering engine, that will be accessed by Illusion as an upvalue not available to hooks.
local engine = engine_c.new()

--- @class illusion_c
--- @field timer_standard fun(start:boolean, custom:table):timer_standard_c
--- @field timer_countdown fun(start:boolean, count_from:number, custom:table):timer_countdown_c
--- @field timer_tick fun(start:boolean, custom:table):timer_tick_c
--- @field shader shader_c
--- @field vector fun(x:number, y:number, z:number): vector_old_c
--- @field angle fun(p:number, y:number, r:number): angle_old_c
--- @field animation animation_c
local illusion_c = {}
local illusion_mt = {__index = illusion_c}

--- Create a new Illusion instance.
--- @return illusion_c
function illusion_c.new(hook)
	local properties = {
		timer_standard = timer.standard, -- Timer standard.
		timer_countdown = timer.countdown, -- Timer countdown.
		timer_tick = timer.tick, -- Timer tick.
		timer = timer, -- Timer dependency.
		shader = shader_c, -- Shader dependency.
		vector = vector, -- Vector dependency.
		angle = angle, -- Angle dependency.
		animation = animation_c.new(), -- Animation dependency.
		shared = {}, -- Engine shared properties.
		info = {
			hook = hook, -- Name of the hook associated with this instance. Never modify this.
			version = engine.core.version,
			uid = engine.core.uid,
			build_date = engine.core.build_date
		},
		particle = {
			total = 0, -- Total spawned particles.
			alive = 0 -- Alive particles.
		}
	}

	local illusion = setmetatable(properties, illusion_mt)

	-- Synchronize the engine shared properties with the wrapper.
	illusion.shared = engine.shared

	return illusion
end

--- Set the tick interval for particle on_tick simulation.
--- @param tick_interval number
--- @return void
function illusion_c:set_tick_interval(tick_interval)
	engine.core.hook_manager.hooks[self.info.hook].options.simulation.tick.timer.interval = tick_interval
end

--- Create a particle.
--- @param type string
--- @param particle_origin vector_old_c
--- @param options table<string, any>
--- @return particle_c|void
function illusion_c:create(type, particle_origin, options)
	-- Do not run if the engine is not enabled.
	if (engine.core.state:available() == false) then
		return
	end

	-- Predicted number of alive particles if this one were to be spawned.
	local predicted_alive = engine.particle.alive + 1

	-- Do not attempt to spawn more particle than the hard limit.
	if (predicted_alive >= engine.particle.hard_limit) then
		return
	end

	-- Particle options.
	options = options or {}

	-- Set new particle ID.
	local particle_id = engine.particle.total + 1

	-- Increment total instance particle count.
	self.particle.total = self.particle.total + 1

	-- Create the new particle.
	local particle = particle_c.new(particle_id, self.info.hook, type, particle_origin, options, engine.shared)

	-- Add particle to the bag.
	engine.particle.bag[particle_id] = particle

	-- Add particle to the hook-indexed bag.
	engine.particle.hook_bag[self.info.hook][particle_id] = particle

	-- Update particle total count.
	engine.particle.total = particle_id

	-- Update alive particle count.
	engine.particle.alive = predicted_alive

	-- Call the particle's on_spawn callback.
	-- Keep this at the bottom, otherwise particles created during on_spawn may be overriden by
	-- the original particle.
	if (options.on_spawn ~= nil) then
		options.on_spawn(particle)
	end

	-- Return the particle.
	return particle
end

--- Kills all particles belonging to the instance.
--- @return void
function illusion_c:wipe()
	for _, particle in pairs(engine.particle.bag) do
		if (particle.hook == self.info.hook) then
			particle:kill(string.format("wiped by %s", self.info.hook), true, false)
		end
	end
end

--- Returns true if the engine is available for use, false if not.
--- @return boolean
function illusion_c:available()
	return engine.core.state:available()
end
--endregion

--region menu
-- Create a new Havoc Illusion menu group.
local menu = menu_manager_c.new("misc", "miscellaneous")

-- Enables or disables the engine.
local enable_engine = menu:checkbox("Havoc Illusion (#ENGINE_VERSION#)")

-- Enables or disabled debugging panel.
local enable_debugging = menu:checkbox("|   Enable Debugging")

-- Set the theme of the debug panel.
local debugging_theme = menu:color_picker("|   Debugging Theme", 33, 65, 83)

-- Shows or hides the particle death reason logs.
local show_particle_death_reasons = menu:checkbox("|   Show Particle Death Reasons")

-- Maximum Particles (Soft Limit)
local particle_soft_limit = menu:slider(
	"|   Maximum Particles (Soft Limit)",
	5,
	13,
	{
		default = 11,
		tooltips = {
			[5] = "32",
			[6] = "64",
			[7] = "128",
			[8] = "256",
			[9] = "512",
			[10] = "1024",
			[11] = "2048",
			[12] = "4096",
			[13] = "8192"
		}
	}
)

-- Maximum Particles (Hard Limit)
local particle_hard_limit = menu:slider(
	"|   Maximum Particles (Hard Limit)",
	5,
	13,
	{
		default = 12,
		tooltips = {
			[5] = "32",
			[6] = "64",
			[7] = "128",
			[8] = "256",
			[9] = "512",
			[10] = "1024",
			[11] = "2048",
			[12] = "4096",
			[13] = "8192"
		}
	}
)

-- Ignore Outdated Script Warnings.
local ignore_outdated_hook_warnings = menu:checkbox("|   Ignore Outdated Script Warnings")

-- Dump engine information to console.
local dump_engine_info = menu:button("Dump Engine Info", function()
	engine.core.console:log({}, string.format("Engine version: %s.", engine.core.version))
	engine.core.console:log({}, string.format("Engine UID: %s.", engine.core.uid))
	engine.core.console:log({}, string.format("Engine build date: %s.", engine.core.build_date))

	if (engine.core.state:available() == true) then
		engine.core.console:log({}, "Engine available")
	else
		engine.core.console:log({code = 2}, "Engine unavailable")
	end
end)

-- Default engine to enabled.
enable_engine(true)

-- Menu visibility.
enable_engine:add_children({
	enable_debugging,
	show_particle_death_reasons,
	debugging_theme,
	particle_soft_limit,
	particle_hard_limit,
	ignore_outdated_hook_warnings,
	dump_engine_info
})

-- Toggle the render engine.
enable_engine:add_callback(function()
	engine.core.state.enabled = enable_engine()
end)

-- Toggle debugging.
enable_debugging:add_callback(function()
	engine.core.debugger.enabled = enable_debugging()
end)

-- Show particle death reasons.
show_particle_death_reasons:add_callback(function()
	engine.particle.show_death_reasons = show_particle_death_reasons()
end)

-- Set the debug panel theme.
debugging_theme:add_callback(function()
	local r, g, b = debugging_theme()

	engine.core.debugger.theme = shader_c.rgb(r, g, b)
end)

-- Set the soft max particle count.
particle_soft_limit:add_callback(function()
	local soft_limit = particle_soft_limit()
	local hard_limit = particle_hard_limit()

	-- Clamp limits.
	if (soft_limit > hard_limit) then
		hard_limit = soft_limit
	end

	-- Update menu.
	particle_soft_limit(soft_limit)
	particle_hard_limit(hard_limit)

	-- Update limits.
	engine.particle.soft_limit = 2 ^ soft_limit
	engine.particle.hard_limit = 2 ^ hard_limit

	-- Update console command.
	engine.core.console.commands.hvci_soft_limit.default = 2 ^ soft_limit
end)

-- Set the hard max particle count.
particle_hard_limit:add_callback(function()
	local soft_limit = particle_soft_limit()
	local hard_limit = particle_hard_limit()

	-- Clamp limits.
	if (hard_limit < soft_limit) then
		soft_limit = hard_limit
	end

	-- Update menu.
	particle_soft_limit(soft_limit)
	particle_hard_limit(hard_limit)

	-- Update limits.
	engine.particle.soft_limit = 2 ^ soft_limit
	engine.particle.hard_limit = 2 ^ hard_limit

	-- Update console command.
	engine.core.console.commands.hvci_hard_limit.default = 2 ^ hard_limit
end)

-- Set illusion.options.ignore_outdated_hook_warnings.
ignore_outdated_hook_warnings:add_callback(function()
	engine.options.ignore_outdated_hook_warnings = ignore_outdated_hook_warnings()
end)
--endregion

--region events
-- Compute engine frame.
client_set_event_callback("paint", function()
	-- Panic test failed. Do not attempt to execute any further calls.
	-- Disable the engine, letting scripts know not to attempt to use it.
	if (engine.core.panic:test(
		engine.core.console,
		engine.core.state,
		engine.core.version,
		engine.core.uid
	) == false) then
		return
	end

	-- Begin the test.
	-- If any code causes the event code halt abruptly, the panic switch will trigger.
	-- Next time the event is called, the panic attack will occur and the event will safely exit.
	engine.core.panic:start()

	-- Update shared properties for all hooks.
	engine.core.hook_manager:update(engine.shared)

	-- Compute current frame and render.
	engine:compute_frame()

	-- Stop the panic test.
	-- This will return the panic system to its good state.
	engine.core.panic:stop()
end)

-- On player connect.
client_set_event_callback("level_init", function()
	-- If the local player is connecting to a map or server, wipe the entire particle bag.
	engine:wipe()
end)
--endregion

--region return
--- Return Havoc Illusion hook function.
--- @param name string
--- @param target_version string
--- @return illusion_c
return function(name, target_version)
	-- Assert that hook name is a string.
	assert(
		type(name) == "string",
		"Illusion hook names must be strings."
	)

	-- Assert that hook name length is valid.
	assert(
		string.len(name) >= 4 and string.len(name) <= 32,
		string.format(
			"Illuion hook names must be between 3 and 10 characters long. '%s' is not a valid name.",
			name
		)
	)

	-- Assert that hook target version is valid.
	assert(
		type(engine:transcode_version(target_version)) == "table",
		string.format(
			"Illusion hook target version for '%s' must be in the format '1.2.3'.",
			name
		)
	)

	-- Add the hook to the list of hooks or nil on failure.
	return engine:hook(name, target_version, "#ENGINE_UID#:#HOOK_UID#", illusion_c)
end
--endregion
