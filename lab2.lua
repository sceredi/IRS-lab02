-- utilities to avoid miss spelling functions or parameter of the robot interface
local robot_wrapper = require("src.wrapper.robot_wrapper")
local logger = require("src.wrapper.logger")

local MAX_VELOCITY = 15
local LIGHT_THRESHOLD = 6.01
local MIN_LIGHT = 0.5
local MAX_PROXIMITY = 0.5

local n_steps = 0
local left_v = 0
local right_v = 0

function init()
	left_v = 0
	right_v = 0
	robot_wrapper.wheels.set_velocity(left_v, right_v)
	robot_wrapper.leds.set_all_colors("black")
	n_steps = 0
end

function step()
	n_steps = n_steps + 1
	local task = define_task()
	task()
	robot_wrapper.wheels.set_velocity(left_v, right_v)
end

-- random_walk moves the robot in a random direction
function random_walk()
	logger.log("Random walk")
	left_v = robot_wrapper.random.uniform(0, MAX_VELOCITY)
	right_v = robot_wrapper.random.uniform(0, MAX_VELOCITY)
	robot_wrapper.leds.set_all_colors("green")
end

-- define_task is used to select which task to execute in the current tick
function define_task()
	local sum_light = 0
	for i = 1, 24 do
		sum_light = sum_light + robot_wrapper.get_light_sensor_readings()[i].value
	end
	local closest = robot_wrapper.get_proximity_sensor_readings()[1].value
	for i = 1, #robot_wrapper.get_proximity_sensor_readings() do
		if i <= 7 or i >= 18 then
			if robot_wrapper.get_proximity_sensor_readings()[i].value > closest then
				closest = robot_wrapper.get_proximity_sensor_readings()[i].value
			end
		end
	end
	if sum_light > LIGHT_THRESHOLD then
		return light_found
	elseif closest > MAX_PROXIMITY then
		return collision_avoidance
	elseif sum_light < MIN_LIGHT then
		return random_walk
	else
		return phototaxis
	end
end

-- light_found stops the robot
function light_found()
	logger.log("Light found")
	robot_wrapper.leds.set_all_colors("yellow")
	left_v = 0
	right_v = 0
end

-- collision_avoidance rotates the robot away from an obstacle
function collision_avoidance()
	logger.log("Collision avoidance")
	local closest = {
		pos = 1,
		value = robot_wrapper.get_proximity_sensor_readings()[1].value,
	}
	for i = 1, #robot_wrapper.get_proximity_sensor_readings() do
		if robot_wrapper.get_proximity_sensor_readings()[i].value > closest.value then
			closest = {
				pos = i,
				value = robot_wrapper.get_proximity_sensor_readings()[i].value,
			}
		end
	end
	robot_wrapper.leds.set_all_colors("red")
	if closest.pos <= 7 then
		left_v = MAX_VELOCITY
		right_v = -MAX_VELOCITY
	elseif closest.pos >= 18 then
		left_v = -MAX_VELOCITY
		right_v = MAX_VELOCITY
	end
end

-- phototaxis moves the robot towards the light source
function phototaxis()
	logger.log("Phototaxis")
	local brightest = {
		pos = 1,
		value = robot_wrapper.get_light_sensor_readings()[1].value,
	}
	for i = 1, #robot_wrapper.get_light_sensor_readings() do
		if robot_wrapper.get_light_sensor_readings()[i].value > brightest.value then
			brightest = {
				pos = i,
				value = robot_wrapper.get_light_sensor_readings()[i].value,
			}
		end
	end
	if brightest.pos == 1 or brightest.pos == 24 then
		left_v = MAX_VELOCITY
		right_v = MAX_VELOCITY
		robot_wrapper.leds.set_all_colors("black")
		robot_wrapper.leds.set_single_color(1, "yellow")
		robot_wrapper.leds.set_single_color(12, "yellow")
	elseif brightest.pos <= 12 then
		left_v = robot_wrapper.random.uniform(0, -MAX_VELOCITY / 2)
		right_v = robot_wrapper.random.uniform(0, MAX_VELOCITY)
		robot_wrapper.leds.set_all_colors("black")
		robot_wrapper.leds.set_single_color(brightest.pos / 2, "yellow")
	else
		left_v = robot_wrapper.random.uniform(0, MAX_VELOCITY)
		right_v = robot_wrapper.random.uniform(0, -MAX_VELOCITY / 2)
		robot_wrapper.leds.set_all_colors("black")
		robot_wrapper.leds.set_single_color(brightest.pos / 2, "yellow")
	end
end

function reset()
	left_v = 0
	right_v = 0
	robot_wrapper.wheels.set_velocity(left_v, right_v)
	n_steps = 0
	robot_wrapper.leds.set_all_colors("black")
end

function destroy()
	-- put your code here
end
