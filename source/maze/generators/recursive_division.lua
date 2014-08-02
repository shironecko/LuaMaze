-- Recursive division algorithm
function Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x, y, w, h)
  if not x then
    maze:resetDoors(false, false)
    x, y, w, h = 1, 1, #maze[1], #maze
    
    splitDecider = splitDecider or function (w, h) 
      do return w > h end
      if w > h then
        return math.random(5) > 1
      elseif h > w then
        return math.random(5) == 1
      else
        return math.random(2) == 1
      end
    end
    
    splitBalancer = splitBalancer or function(length)
      return math.random(length)
    end
  elseif w <= 1 and h <= 1 then return end
  
  if h == 1 or w > 1 and splitDecider(w, h) then
    -- Vertical wall
    local halfW = splitBalancer(w - 1)
    local middle = x - 1 + halfW
    for _y = y, y - 1 + h do
      maze[_y][middle].east:close()
    end
    
    maze[math.random(y, y - 1 + h)][middle].east:open()
    
      Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x, y, halfW, h)
      Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x + halfW, y, w - halfW, h)
  else
    -- Horizontal wall
    local halfH = splitBalancer(h - 1)
    local middle = y - 1 + halfH
    for _x = x, x - 1 + w do
      maze[middle][_x].south:close()
    end
    
    maze[middle][math.random(x, x - 1 + w)].south:open()
    
    Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x, y, w, halfH)
    Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x, y + halfH, w, h - halfH)
  end
end