-- Hunt and kill algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/24/maze-generation-hunt-and-kill-algorithm
local random = math.random
local pairs = pairs
local Maze = require "maze"
_ENV = nil

local function hunt_and_kill(maze)
  maze:ResetDoors(true)
  
  maze[1][1].visited = true
  while true do
    local cell
    -- Hunt
    for y = 1, #maze do
      for x = 1, #maze[1] do
        if maze[y][x].visited then
          for key, value in pairs(maze:DirectionsFrom(x, y, function (cell) return not cell.visited end)) do
            cell = { x = x, y = y }
            goto carve
          end
        end
      end
    end
    
    -- If we're reached this spot, then there left no unvisited cells
    goto hunt_completed
    
    ::carve::
    while true do
      -- Gathering all possible travel direction in a list
      local directions = maze:DirectionsFrom(cell.x, cell.y, function (cell) return not cell.visited end)
      
      -- If there are no possible carve directions, then we sould enter the hunt mode again
      if #directions == 0 then break end
      
      -- Choosing a random direction from a list of possible direction and carving
      local dirn = directions[random(#directions)]
      maze[cell.y][cell.x][dirn.name]:Open() 
      cell = { x = dirn.x, y = dirn.y }
      maze[cell.y][cell.x].visited = true
    end
  end
  
  ::hunt_completed::
  maze:ResetVisited()
end

return hunt_and_kill