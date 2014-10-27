-- Hunt and kill algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/24/maze-generation-hunt-and-kill-algorithm
local random = math.random
local pairs = pairs
local Maze = require "maze"
_ENV = nil

local function hunt_and_kill(maze)
  maze:ResetDoors(true)
  
  maze[1][1].visited = true
  -- these will track last hunt position and free us of need to traverse the whole maze on each hunt
  local hunt_x, hunt_y = 1, 1
  while true do
    local cell
    -- Hunt
    repeat -- y iteration
      repeat -- x iteration
        if maze[hunt_y][hunt_x].visited then
          for key, value in pairs(maze:DirectionsFrom(hunt_x, hunt_y, function (cell) return not cell.visited end)) do
            cell = { x = hunt_x, y = hunt_y }
            goto carve
          end
        end
        hunt_x = hunt_x + 1
      until hunt_x > maze:width()
      hunt_x = 1
      hunt_y = hunt_y + 1
    until hunt_y > maze:height()
    
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
