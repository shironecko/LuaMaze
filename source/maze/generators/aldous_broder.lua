-- Aldous-Broder algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/17/maze-generation-aldous-broder-algorithm
local random = math.random
local Maze = require "maze"
_ENV = nil

local function aldous_broder(maze)
  maze:ResetDoors(true)
  local remaining = #maze * #maze[1] - 1
  
  local cell = { x = random(#maze[1]), y = random(#maze) }
  maze[cell.y][cell.x].visited = true
  while remaining ~= 0 do
    local directions = maze:DirectionsFrom(cell.x, cell.y)
    
    local dirn = directions[random(#directions)]
    if not maze[dirn.y][dirn.x].visited then
      maze[dirn.y][dirn.x].visited = true
      maze[cell.y][cell.x][dirn.name]:Open()
      remaining = remaining - 1
    end
    
    cell = { x = dirn.x, y = dirn.y }
  end
  
  maze:ResetVisited()
end

return aldous_broder