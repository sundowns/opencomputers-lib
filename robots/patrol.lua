local robot = require("robot")
local computer = require("computer")

local config = {
  RECHARGE = true,
  CRITICAL_POWER_LEVEL = 0.2,
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
  print(
    "[debug] energy: " ..
      computer.energy() ..
        " / " .. computer.maxEnergy() .. " [" .. (computer.energy() / computer.maxEnergy()) * 100 .. "%]"
  )
  return computer.energy() / computer.maxEnergy()
end

-- actions

local function randomly_turn()
  choose_and_execute(robot.turnLeft, robot.turnRight)
end

local function chime()
  if not config.MUTE then
    computer.beep("--.-...--")
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

-- main loop

local function run()
  while true do
    local will_collide, obstacle = robot.detect()
    print("[debug] type: " .. obstacle) -- TODO: remove
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
        print("[debug] Power is critically low, seeking recharge!!")
      else
        chance_to_act(0.15, randomly_turn)
        chance_to_act(0.025, chime)
        chance_to_act(0.65, robot.forward)
      end
    end
  end
end

os.execute("clear")
print("watch me run dad!")
run()
