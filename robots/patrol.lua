local robot = require("robot")
local computer = require("computer")

function choose_and_execute(...)
  local args = {...}
  args[math.random(1, #args)]()
end

function chance_to_act(weighting, callback)
  local choice = math.random()
  if choice < weighting then
    callback()  
  end
end

function turn_until_unblocked(turn_callback)
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

function try_avoid_obstacle_infront()
  local left = math.random(0,1) < 0.5
  
  if math.random() < 0.5 then
    turn_until_unblocked(robot.turnLeft)
  else
    turn_until_unblocked(robot.turnRight)     
  end
end

function patrol()
  while true do
    local will_collide, obstacle = robot.detect()
    if will_collide then
      try_avoid_obstacle_infront()
    else
      chance_to_act(0.15, randomly_turn)
      chance_to_act(0.3, wait)
      chance_to_act(0.025, chime)
      chance_to_act(0.65, robot.forward)
    end
  end
end

function randomly_turn()
  choose_and_execute(robot.turnLeft, robot.turnRight)
end

function chime()
  computer.beep("--.-...--")
end

function wait()
end

print("watch me run dad!")
patrol()