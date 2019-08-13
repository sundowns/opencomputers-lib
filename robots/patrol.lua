local robot = require("robot")
local computer = require("computer")

local config = {
  RECHARGE_SELF = true,
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
    print(obstacle) -- TODO: remove
    if will_collide or obstacle ~= "passable" then -- TODO: sense check the 'passable' bit
      choose_and_execute(
        function()
          turn_until_unblocked(robot.turnLeft)
        end,
        function()
          turn_until_unblocked(robot.turnRight)
        end
      )
    else
      -- TODO: if power is low, seek charger. otherwise, perform random actions

      chance_to_act(0.15, randomly_turn)
      chance_to_act(0.025, chime)
      chance_to_act(0.65, robot.forward)
    end
  end
end

os.execute("clear")
print("watch me run dad!")
run()
