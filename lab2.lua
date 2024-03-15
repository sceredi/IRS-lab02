-- Put your global variables here
local robot_wrapper = require("src.wrapper.robot_wrapper")
local logger = require("src.wrapper.logger")

local MAX_VELOCITY = 15
local LIGHT_THRESHOLD = 6.01
local MIN_LIGHT = 0.5
local MAX_PROXIMITY = 0.5

local n_steps = 0
local left_v = 0
local right_v = 0

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = 0
	right_v = 0
	robot_wrapper.wheels.set_velocity(left_v, right_v)
	robot_wrapper.leds.set_all_colors("black")
	n_steps = 0
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
	-- logger.Log("Gonna move by " .. left_v .. " " .. right_v)
	local task = define_task()
	logger.log("Task: " .. task)
	if task == "random_walk" then
		random_walk()
	elseif task == "light_found" then
		light_found()
	elseif task == "collision" then
		collision_avoidance()
	else
		light_controller()
	end
	-- logger.Log("Moving by " .. left_v .. " " .. right_v)
	robot_wrapper.wheels.set_velocity(left_v, right_v)
end

function random_walk()
	left_v = robot_wrapper.random.uniform(0, MAX_VELOCITY)
	right_v = robot_wrapper.random.uniform(0, MAX_VELOCITY)
	robot_wrapper.leds.set_all_colors("green")
end
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
		return "light_found"
	elseif closest > MAX_PROXIMITY then
		return "collision"
	elseif sum_light < MIN_LIGHT then
		return "random_walk"
	else
		return "move"
	end
end

function light_found()
	robot_wrapper.leds.set_all_colors("yellow")
	left_v = 0
	right_v = 0
end

function collision_avoidance()
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
	if closest.pos <= 12 then
		left_v = MAX_VELOCITY
		right_v = -MAX_VELOCITY
	else
		left_v = -MAX_VELOCITY
		right_v = MAX_VELOCITY
	end
end

function light_controller()
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
		left_v = robot_wrapper.random.uniform(0, -MAX_VELOCITY)
		right_v = robot_wrapper.random.uniform(0, MAX_VELOCITY)
		robot_wrapper.leds.set_all_colors("black")
		robot_wrapper.leds.set_single_color(brightest.pos / 2, "yellow")
	else
		left_v = robot_wrapper.random.uniform(0, MAX_VELOCITY)
		right_v = robot_wrapper.random.uniform(0, -MAX_VELOCITY)
		robot_wrapper.leds.set_all_colors("black")
		robot_wrapper.leds.set_single_color(brightest.pos / 2, "yellow")
	end
end

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = 0
	right_v = 0
	-- robot.wheels.set_velocity(left_v, right_v)
	robot_wrapper.wheels.set_velocity(left_v, right_v)
	n_steps = 0
	robot_wrapper.leds.set_all_colors("black")
end

--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
	-- put your code here
end
