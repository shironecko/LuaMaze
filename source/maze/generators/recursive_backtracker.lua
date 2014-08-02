 -- Recursive Backtracker algorithm
 -- Detailed description: http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
local random = math.random
local Maze = require "maze"
_ENV = nil

local function recursive_backtracker(maze, x, y)
  local first_one = nil
  if not x then
    first_one = true
    maze:ResetDoors(true)
    x, y = random(#maze[1]), random(#maze)
  end
  
  maze[y][x].visited = true
  
  local directions = maze:DirectionsFrom(x, y, function (cell) return not cell.visited end)  
  while #directions ~= 0 do
    local rand_i = random(#directions)
    local dirn = directions[rand_i]
    
    directions[rand_i] = directions[#directions]
    directions[#directions] = nil
    
    if not maze[dirn.y][dirn.x].visited then
      maze[y][x][dirn.name]:Open()
      recursive_backtracker(maze, dirn.x, dirn.y)
    end
  end
  
  if first_one then maze:ResetVisited() end
end

return recursive_backtracker