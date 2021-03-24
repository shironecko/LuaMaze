-- Recursive division algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/12/maze-generation-recursive-division-algorithm
local random = math.random

local function divide(maze, split_decider, split_balancer, x, y, w, h)
  if w <= 1 and h <= 1 then return end
  
  -- decide wich type of wall to place, vertical or horizontal
  if h == 1 or w > 1 and split_decider(w, h) then
    -- vertical wall
    local halfW = split_balancer(w - 1)
    local middle = x - 1 + halfW
    for _y = y, y - 1 + h do
      maze[_y][middle].east:Close()
    end
    
    maze[random(y, y - 1 + h)][middle].east:Open()
    
    divide(maze, split_decider, split_balancer, x, y, halfW, h)
    divide(maze, split_decider, split_balancer, x + halfW, y, w - halfW, h)
  else
    -- horizontal wall
    local halfH = split_balancer(h - 1)
    local middle = y - 1 + halfH
    for _x = x, x - 1 + w do
      maze[middle][_x].south:Close()
    end
    
    maze[middle][random(x, x - 1 + w)].south:Open()
    
    divide(maze, split_decider, split_balancer, x, y, w, halfH)
    divide(maze, split_decider, split_balancer, x, y + halfH, w, h - halfH)
  end
end

local function recursive_division(maze, split_decider, split_balancer, x, y, w, h)
  maze:ResetDoors(false, false)
  x, y, w, h = 1, 1, maze:width(), maze:height()
  
  -- function that will decide which wall to place, true for vertical
  split_decider = split_decider or function (w, h) 
    do return w > h end
    if w > h then
      return random(5) > 1
    elseif h > w then
      return random(5) == 1
    else
      return random(2) == 1
    end
  end
  
  -- function that decides where new wall will be place in the available space
  split_balancer = split_balancer or function(length)
    return random(length)
  end

  -- start recursive division process
  divide(maze, split_decider, split_balancer, x, y, w, h)
end

return recursive_division
