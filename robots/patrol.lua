local robot = require("robot")
local computer = require("computer")

local function choose_and_execute(...)
  local args = {...}
  args[math.random(1, #args)]()
end

local function randomly_turn()
  choose_and_execute(robot.turnLeft, robot.turnRight)
end

local function chime()
  computer.beep("--.-...--")
end

local function chance_to_act(weighting, callback)
  if math.random() < weighting then
    callback()
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

local function try_avoid_obstacle_infront()
  if math.random() < 0.5 then
    turn_until_unblocked(robot.turnLeft)
  else
    turn_until_unblocked(robot.turnRight)
  end
end

local function patrol()
  while true do
    local will_collide, obstacle = robot.detect()
    if will_collide or obstacle ~= "passable" then -- TODO:
      try_avoid_obstacle_infront()
    else
      chance_to_act(0.15, randomly_turn)
      chance_to_act(0.025, chime)
      chance_to_act(0.65, robot.forward)
    end
  end
end

print("watch me run dad!")
patrol()
