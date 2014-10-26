-- Aldous-Broder algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/17/maze-generation-aldous-broder-algorithm
local random = math.random
local Maze = require "maze"
_ENV = nil

local function aldous_broder(maze)
  maze:ResetDoors(true)
  local remaining = maze:width() * maze:height() - 1
  
  -- wander randomly through the maze
  local x, y = random(maze:width()), random(maze:height())
  maze[y][x].visited = true
  -- till there are unvisited cells left
  while remaining ~= 0 do
    local directions = maze:DirectionsFrom(x, y)
    local dirn = directions[random(#directions)]

    -- if cell in which we want to go was not visited before - carve in it's direction
    if not maze[dirn.y][dirn.x].visited then
      maze[dirn.y][dirn.x].visited = true
      maze[y][x][dirn.name]:Open()
      remaining = remaining - 1
    end
    
    x, y = dirn.x, dirn.y
  end
  
  maze:ResetVisited()
end

return aldous_broder
