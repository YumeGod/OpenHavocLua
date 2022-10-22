--region dependencies
--region dependency: havoc_vector_2_4_0
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
			p = p and p or 0,
			y = y and y or 0,
			r = r and r or 0
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
	return angle(
		-operand_a.p,
		-operand_a.y,
		-operand_a.r
	)
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
			x = x and x or 0,
			y = y and y or 0,
			z = z and z or 0
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
	return vector(
		-operand_a.x,
		-operand_a.y,
		-operand_a.z
	)
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
function vector_old_c:to_screen(only_inside_screen)
	local x, y = renderer.world_to_screen(self.x, self.y, self.z)

	if (x == nil or y == nil) then
		return nil
	end

	if (only_inside_screen == true) then
		local screen_x, screen_y = client.screen_size()

		if (x < 0 or x > screen_x or y < 0 or y > screen_y) then
			return nil
		end
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
--- @param destination vector_old_c
--- @return angle_old_c
function vector_old_c:angle_to(destination)
	-- Calculate the delta of vectors.
	local delta_vector = vector(destination.x - self.x, destination.y - self.y, destination.z - self.z)

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
--- @param destination vector_old_c
--- @param skip_entindex number
--- @return number, number|nil
function vector_old_c:trace_line_to(destination, skip_entindex)
	skip_entindex = skip_entindex or -1

	return client.trace_line(
		skip_entindex,
		self.x,
		self.y,
		self.z,
		destination.x,
		destination.y,
		destination.z
	)
end

--- Lerp to another vector.
--- @param destination vector_old_c
--- @param percentage number
--- @return vector_old_c
function vector_old_c:lerp(destination, percentage)
	return self + (destination - self) * percentage
end

--- Trace line to another vector and return the impact point.
--- @param destination vector_old_c
--- @param skip_entindex number
--- @return number, number, vector_old_c
function vector_old_c:trace_line_impact(destination, skip_entindex)
	skip_entindex = skip_entindex or -1

	local fraction, eid = client.trace_line(skip_entindex, self.x, self.y, self.z, destination.x, destination.y, destination.z)
	local impact = self:lerp(destination, fraction)

	return fraction, eid, impact
end

--- Trace line to another vector, skipping any entity indices returned by the callback.
--- @param destination vector_old_c
--- @param callback fun(eid: number): boolean
--- @param max_traces number
--- @return number, number, vector_old_c
function vector_old_c:trace_line_skip(destination, callback, max_traces)
	max_traces = max_traces or 10

	local fraction, eid = 0, -1
	local impact = self
	local i = 0

	while (max_traces >= i and fraction < 1 and ((eid > -1 and callback(eid)) or impact == self)) do
		fraction, eid, impact = impact:trace_line_impact(destination, eid)
		i = i + 1
	end

	return self:distance(impact) / self:distance(destination), eid, impact
end

--- Returns the result of client.trace_bullet between two vectors.
--- @param from_player number
--- @param destination vector_old_c
--- @return number|nil, number
function vector_old_c:trace_bullet_to(from_player, destination)
	return client.trace_bullet(
		from_player,
		self.x,
		self.y,
		self.z,
		destination.x,
		destination.y,
		destination.z
	)
end

--- Returns the vector of the closest point along a ray.
--- @param source vector_old_c
--- @param destination vector_old_c
--- @return vector_old_c
function vector_old_c:closest_ray_point(source, destination)
	local direction = (destination - source) / source:distance(destination)
	local v = self - source
	local length = v:dot_product(direction)

	return source + direction * length
end

--- Returns a point along a ray after dividing it.
--- @param destination vector_old_c
--- @param ratio number
--- @return vector_old_c
function vector_old_c:divide_ray(destination, ratio)
	return (self * ratio + destination) / (1 + ratio)
end

--- Internally divide a ray.
--- @param source vector_old_c
--- @param destination vector_old_c
--- @param m number
--- @param n number
--- @return vector_old_c
local function vector_internal_division(source, destination, m, n)
	return vector((source.x*n + destination.x*m) / (m+n),
		(source.y*n + destination.y*m) / (m+n),
		(source.z*n + destination.z*m) / (m+n))
end

--- Returns a ray divided into a number of segments.
--- @param destination vector_old_c
--- @param segments number
--- @return table<number, vector_old_c>
function vector_old_c:segment_ray(destination, segments)
	local points = {}

	for i = 0, segments do
		points[i] = vector_internal_division(self, destination, i, segments - i)
	end

	return points
end

--- Returns the best source vector and destination vector to draw a line on-screen using world-to-screen.
--- @param destination vector_old_c
--- @param total_segments number
--- @return vector_old_c|nil, vector_old_c|nil
function vector_old_c:ray(destination, total_segments)
	total_segments = total_segments or 128

	local segments = {}
	local step = self:distance(destination) / total_segments
	local angle = self:angle_to(destination)
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
--- @param source vector_old_c
--- @param destination vector_old_c
--- @return number
function angle_old_c:fov_to(source, destination)
	local fwd = self:to_forward_vector()
	local delta = (destination - source):normalized()
	local fov = math.acos(fwd:dot_product(delta) / delta:length())

	return math.max(0.0, math.deg(fov))
end

--- Returns the degrees bearing of the angle's yaw.
--- @param precision number
--- @return number
function angle_old_c:bearing(precision)
	local yaw = 180 - self.y + 90
	local degrees = (yaw % 360 + 360) % 360

	degrees = degrees > 180 and degrees - 360 or degrees

	return math.round(degrees + 180, precision)
end

--- Returns the yaw appropriate for renderer circle's start degrees.
--- @return number
function angle_old_c:start_degrees()
	local yaw = self.y
	local degrees = (yaw % 360 + 360) % 360

	degrees = degrees > 180 and degrees - 360 or degrees

	return degrees + 180
end

--- Returns a copy of the angles normalized and clamped.
--- @return number
function angle_old_c:normalize()
	local pitch = self.p

	if (pitch < -89) then
		pitch = -89
	elseif (pitch > 89) then
		pitch = 89
	end

	local yaw = self.y

	while yaw > 180 do
		yaw = yaw - 360
	end

	while yaw < -180 do
		yaw = yaw + 360
	end

	return angle(pitch, yaw, 0)
end

--- Normalizes and clamps the angles.
--- @return number
function angle_old_c:normalized()
	if (self.p < -89) then
		self.p = -89
	elseif (self.p > 89) then
		self.p = 89
	end

	local yaw = self.y

	while yaw > 180 do
		yaw = yaw - 360
	end

	while yaw < -180 do
		yaw = yaw + 360
	end

	self.y = yaw
	self.r = 0
end
--endregion
--endregion

--region dependency: havoc_shader_1_5_0
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
	__call = function(shader, r, g, b, a)
		if (r ~= nil) then
			shader:set_r(r)
			shader:set_g(g)
			shader:set_b(b)
			shader:set_a(a)
		else
			return shader:unpack()
		end
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
	automatically_update_spaces = automatically_update_spaces or true

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

--- Sorted pairs iteration.
--- @param t table<any, any>
--- @param order function
--- @return table<any, any>
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

--region oova_enemy
--- @class oova_enemy_c
--- @field public eid number
--- @field public shader shader_c
--- @field public shader_occluded shader_c
--- @field public target_alpha number
--- @field public current_alpha number
--- @field public min_alpha number
--- @field public max_alpha number
--- @field public is_dormant boolean
--- @field public is_dead boolean
--- @field public on_dormant boolean
--- @field public in_view boolean
--- @field public distance number
local oova_enemy_c = {}
local oova_enemy_mt = { __index = oova_enemy_c }

--- Instantiate an object of oova_enemy_c.
--- @param eid number
--- @param shader shader_c
--- @param shader_occluded shader_c
--- @return oova_enemy_c
function oova_enemy_c.new(eid, shader, shader_occluded)
	return setmetatable({
		eid = eid,
		shader = shader,
		shader_occluded = shader_occluded,
		current_alpha = 0,
		target_alpha = 0,
		min_alpha = 5,
		max_alpha = shader.a,
		is_dormant = false,
		is_dead = false,
		on_dormant = false,
		in_view = false,
		distance = 0
	}, oova_enemy_mt)
end
--endregion

--region oova
--- @class oova_c
--- @field public enemies table<number, oova_enemy_c>
--- @field public screen vector_old_c
--- @field public screen_center vector_old_c
--- @field public radius number
--- @field public thickness number
--- @field public fade number
--- @field public length number
--- @field public shader shader_c
--- @field public shader_occluded shader_c
--- @field public shader_dormant shader_c
--- @field public only_oov boolean
--- @field public distance_based_radius boolean
--- @field public distance_based_length boolean
--- @field public rainbow boolean
--- @field public rainbow_speed number
--- @field public visible_based_color boolean
--- @field public target_alpha number
--- @field public current_alpha number
--- @field public max_alpha number
--- @field public min_alpha number
--- @field public current_thickness number
--- @field public radii table<number, number>
local oova_c = {}
local oova_mt = { __index = oova_c }

--- Instantiate an object of oova_c.
--- @return oova_c
function oova_c.new()
	return setmetatable({
		enemies = {},
		screen = vector(),
		screen_center = vector(),
		radius = 100,
		thickness = 2,
		fade = 0,
		length = 0.1,
		shader = shader_c.rgb(255, 0, 0, 255),
		shader_occluded = shader_c.rgb(255, 0, 0, 100),
		shader_dormant = shader_c.rgb(100, 100, 100, 100),
		rainbow = false,
		rainbow_speed = 0,
		only_oov = false,
		visible_based_color = false,
		distance_based_length = false,
		target_alpha = 255,
		current_alpha = 0,
		max_alpha = 255,
		min_alpha = 0,
		current_thickness = 0,
		radii = {}
	}, oova_mt)
end

--- Updata OOVA data.
--- @return void
function oova_c:sync()
	self.screen(client.screen_size())
	self.screen_center(self.screen.x / 2, self.screen.y / 2)
end

--- Render OOVA.
--- @return void
function oova_c:render()
	local i = 1
	local enemy_count = 0

	if (self.rainbow == true) then
		self.shader:shift_hue(self.rainbow_speed)
	end

	for _, enemy in pairs(self.enemies) do
		if (enemy.current_alpha > 1) then
			enemy_count = enemy_count + 1
		end
	end

	if (enemy_count > 0) then
		local target_thickness = self.thickness - enemy_count * 1.5
		self.current_thickness = self.current_thickness + (target_thickness - self.current_thickness) * 0.025
	end

	if (self.fade == 0) then
		self.current_alpha = self.max_alpha
	else
		self.current_alpha = self.current_alpha + (self.target_alpha - self.current_alpha) * self.fade

		if (self.current_alpha < 25) then
			self.target_alpha = self.max_alpha
		elseif (self.current_alpha > self.max_alpha - 25) then
			self.target_alpha = self.min_alpha
		end
	end

	for _, enemy in spairs(self.enemies, function(table, a, b)
		return table[a].distance < table[b].distance
	end) do
		if (self.rainbow == true) then
			enemy.shader = self.shader:clone()
		end

		local shader, alpha, radius, start_degrees, length = self:get_enemy_indicator_data(enemy)

		renderer.circle_outline(
			self.screen_center.x, self.screen_center.y,
			shader.r, shader.g, shader.b, alpha,
			radius - (i * (self.current_thickness * 1.15)),
			start_degrees, length,
			self.current_thickness
		)

		if (enemy.current_alpha > 1) then
			i = i + 1
		end
	end
end

--- Process enemies for rendering.
--- @return void
function oova_c:process_enemies()
	for _, eid in pairs(entity.get_players(true)) do
		if (self.enemies[eid] == nil) then
			self.enemies[eid] = oova_enemy_c.new(eid, self.shader:clone(), self.shader_occluded:clone())
		end
	end

	for _, enemy in pairs(self.enemies) do
		if (entity.is_enemy(enemy.eid) == false) then
			self.enemies[enemy.eid] = nil
		else
			local enemy_origin = vector(entity.get_prop(enemy.eid, "m_vecOrigin"))
			local enemy_w2s = enemy_origin:to_screen(true)

			enemy.in_view = enemy_w2s ~= nil
			enemy.is_dead = entity.is_alive(enemy.eid) == false
			enemy.is_dormant = entity.is_dormant(enemy.eid)

			if (enemy.on_dormant == false and enemy.is_dormant == true) then
				enemy.on_dormant = true

				if (self.only_oov == true and enemy.in_view == false) then
					enemy.current_alpha = 255
				elseif (self.only_oov == false) then
					enemy.current_alpha = 255
				end
			elseif (enemy.on_dormant == true and enemy.is_dormant == false) then
				enemy.on_dormant = false
			end
		end
		end
end

--- Update the enemy shaders.
--- @return void
function oova_c:update_enemy_shaders()
	for _, enemy in pairs(self.enemies) do
		enemy.shader = self.shader:clone()
		enemy.shader_occluded = self.shader_occluded:clone()
		enemy.max_alpha = enemy.shader.a
		enemy.current_alpha = enemy.shader.a
	end
end

--- Returns the data necessary to render the enemy's indicator: shader, radius, start degrees.
--- @param enemy oova_enemy_c
--- @return shader_c, number, number, number
function oova_c:get_enemy_indicator_data(enemy)
	local shader = enemy.shader
	local player_eye_pos = vector(client.eye_position())

	if (self.visible_based_color == true) then
		shader = enemy.shader_occluded

		for i = 0, 18 do
			local hitbox = vector(entity.hitbox_position(enemy.eid, i))

			local _, eid_hit = player_eye_pos:trace_line_skip(
				hitbox,
				function(eid)
					return eid == entity.get_local_player()
				end,
				4
			)

			if (eid_hit == enemy.eid) then
				shader = enemy.shader
			end
		end
	end

	if (enemy.is_dormant == true) then
		enemy.target_alpha = 0

		shader = self.shader_dormant
	elseif (enemy.is_dead == true) then
		enemy.target_alpha = 0

		shader = self.shader_dormant
	elseif (enemy.current_alpha < enemy.min_alpha) then
		enemy.target_alpha = enemy.max_alpha
	elseif (enemy.current_alpha > enemy.max_alpha - 5) then
		enemy.target_alpha = 0
	end

	if (enemy.is_dormant == true) then
		enemy.current_alpha = math.max(0, enemy.current_alpha - 1)
	elseif (enemy.is_dead == true) then
		enemy.current_alpha = math.max(0, enemy.current_alpha - 2)
	elseif (self.only_oov == true and enemy.in_view == true) then
		enemy.current_alpha = math.max(0, enemy.current_alpha - 2)
	else
		enemy.current_alpha = self.current_alpha
	end

	local player_origin = vector(entity.get_prop(entity.get_local_player(), "m_vecOrigin"))
	local enemy_origin = vector(entity.get_prop(enemy.eid, "m_vecOrigin"))
	local length = self.length
	local distance = player_origin:distance(enemy_origin)

	enemy.distance = distance

	if (self.distance_based_length == true) then
		length = math.min(0.33, math.max(0.05, ((2048 - distance) / 2048) / 5))
	end

	local radius = self.radius
	local enemy_angle = player_origin:angle_to(enemy_origin)
	local camera_angles = angle(client.camera_angles())
	local delta_angle = angle(0, enemy_angle.y - camera_angles.y, 0):normalize()

	local start_degrees = 180 - delta_angle:start_degrees() + 270
	local offset = length * 360

	start_degrees = start_degrees - (offset / 2)

	return shader, enemy.current_alpha, radius, start_degrees, length
end
--endregion

--region setup
local oova = oova_c.new()
--endregion

--region menu
local menu = menu_manager_c.new("config", "presets")

menu:label("--------------------------------------------------")
menu:label("Indicators - v1.0.2")

local enable_script = menu:checkbox("Enable indicators")

--------------------------------------------------
local shader = menu:color_picker("Indicator main color picker", 156, 62, 62, 255)

shader:add_callback(function()
	local r, g, b, a = shader()

	oova.shader(r, g, b, a)
	oova:update_enemy_shaders()
end)


local rainbow = menu:checkbox("Indicator rainbow mode")

rainbow:add_callback(function()
	oova.rainbow = rainbow()

	if (rainbow() == false) then
		local r, g, b, a = shader()

		oova.shader(r, g, b, a)
		oova:update_enemy_shaders()
	end
end)

local rainbow_speed = menu:slider("Indicator rainbow speed", 1, 100, {
	default = 33,
	unit = "%",
})

rainbow_speed:add_callback(function()
	oova.rainbow_speed = rainbow_speed() * 0.01 / 2
end)


local dormant_color_label = menu:label ("Indicator dormant color")
local shader_dormant = menu:color_picker("Indicator dormant color picker", 71, 71, 71, 255)

shader_dormant:add_callback(function()
	local r, g, b, a = shader_dormant()

	oova.shader_dormant(r, g, b, a)
	oova:update_enemy_shaders()
end)


local visible_based_color = menu:checkbox("Indicator colors based on visibility")

visible_based_color:set_hidden_value(false)

visible_based_color:add_callback(function()
	oova.visible_based_color = visible_based_color()
end)


local shader_occluded = menu:color_picker("Indicator occluded color picker", 135, 131, 97, 255)

shader_occluded:add_callback(function()
	local r, g, b, a = shader_occluded()

	oova.shader_occluded(r, g, b, a)
	oova:update_enemy_shaders()
end)


visible_based_color:add_children({
	shader_occluded
})

rainbow:add_children(
	{
		rainbow_speed
	}
)

rainbow:add_children(
	{
		visible_based_color,
	},
	function()
		return rainbow() == false
	end
)
-----------------------------------------------------
local only_oov = menu:checkbox("Indicator only out of view")

only_oov:add_callback(function()
	oova.only_oov = only_oov()
end)

--------------------------------------------------
local max_alpha = menu:slider("Indicator maximum opacity", 10, 100, {
	default = 75,
	unit = "%"
})

max_alpha:add_callback(function()
	oova.max_alpha = 255 * (max_alpha() * 0.01)
	oova.target_alpha = 0
end)

--------------------------------------------------
local radius = menu:slider("Indicator radius", 25, 100, {
	default = 60,
	unit = "%"
})

radius:add_callback(function()
	oova.radius = 400 * (radius() * 0.01)
end)

--------------------------------------------------
local thickness = menu:slider("Indicator thickness", 8, 30, {
	default = 20,
	unit = "x"
})

thickness:add_callback(function()
	oova.thickness = thickness()
end)

--------------------------------------------------
local fade = menu:slider("Indicator fade speed", 0, 50, {
	default = 10,
	unit = "x",
	scale = 0.1
})

fade:add_callback(function()
	oova.fade = fade() * 0.001
end)

--------------------------------------------------
local distance_based_length = menu:checkbox("Indicator length based on distance")

distance_based_length:add_callback(function()
	oova.distance_based_length = distance_based_length()
end)


local length = menu:slider("Indicator length", 25, 100, {
	default = 60,
	unit = "%",
})

length:add_callback(function()
	oova.length = length() * 0.001
end)


distance_based_length:add_children(
	{
		length
	},
	function()
		return distance_based_length() == false
	end
)
--------------------------------------------------
enable_script:add_children({
	rainbow,
	shader,
	shader_dormant,
	dormant_color_label,
	only_oov,
	max_alpha,
	radius,
	thickness,
	fade,
	distance_based_length
})

menu:load_from_db()
--endregion

--region main
client.set_event_callback("paint", function()
	if (enable_script() == false or entity.is_alive(entity.get_local_player()) == false) then
		return
	end

	oova:sync()
	oova:process_enemies()
	oova:render()
end)

client.set_event_callback("shutdown", function()
	menu:save_to_db()
end)
--endregion
