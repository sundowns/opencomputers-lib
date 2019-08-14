local robot = require("robot")
local computer = require("computer")
local component = require("component")
local navigation = component.navigation

local config = {
  DEBUG = true,
  RECHARGE = true,
  CRITICAL_POWER_LEVEL = 0.95,
  MUTE = false
}

-- Utility functions

local function choose_and_execute(...)
  local args = {...}
  args[math.random(1, #args)]()
end

local function choose(...)
  local args = {...}
  return args[math.random(1, #args)]
end

local function chance_to_act(weighting, callback)
  if math.random() < weighting then
    callback()
  end
end

local function get_power_level()
  assert(computer, "computer component not found. Has it been imported?")
  return computer.energy() / computer.maxEnergy()
end

-- actions

local function randomly_turn()
  choose_and_execute(robot.turnLeft, robot.turnRight)
end

local function chime()
  if not config.MUTE then
    computer.beep(".--.-...--")
  end
end

local function turn_until_unblocked(turn_callback)
  local blocked, _ = robot.detect()
  local turns = 0
  while blocked and turns < 4 do
    turn_callback()
    turns = turns + 1
    blocked, _ = robot.detect()
  end
  if turns >= 4 then
    robot.back()
  end
end

local function navigate_to_waypoint(target)
  local x, y, z, err = navigation.getPosition()
  if err then
    print(err)
  end
  local waypoint = navigation.findWaypoints(navigation.getRange())[1]
  print("robot: " .. x .. "," .. y .. "," .. z)

  local dx, dy, dz = (x - waypoint.position[1]), (y - waypoint.position[2]), (z - waypoint.position[3])
  print("dx: " .. dx .. "," .. dy .. "," .. dz)
end

-- main loop

local function run()
  while true do
    local will_collide, _ = robot.detect()
    if will_collide then -- TODO: investigate passable blocks (pressure plates/doors etc?)
      choose_and_execute(
        function()
          turn_until_unblocked(robot.turnLeft)
        end,
        function()
          turn_until_unblocked(robot.turnRight)
        end
      )
    else
      -- if power is low, seek charging station. otherwise, perform standard behaviour
      if config.RECHARGE and get_power_level() < config.CRITICAL_POWER_LEVEL then
        -- TODO: Seek power supply (use waypoint + charging station?)

        navigate_to_waypoint("charger")
      else
        chance_to_act(0.05, randomly_turn)
        chance_to_act(0.025, chime)
        chance_to_act(0.65, robot.forward)
      end
    end
  end
end

if not config.DEBUG then
  os.execute("clear")
end
print("watch me run dad!")
run()
