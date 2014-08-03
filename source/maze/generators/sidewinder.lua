-- Sidewinder algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/2/3/maze-generation-sidewinder-algorithm
local random = math.random
local Maze = require "maze"
_ENV = nil

local function sidewinder(maze)
  maze:ResetDoors(true)
  
  local set = {}
  for y = 1, #maze - 1 do
    for x = 1, #maze[1] do
      set[#set + 1] = { x = x, y = y }
      
      if random(2) == 1 and x ~= #maze[1] then
        maze[y][x].east:Open()
      else
        local cell = set[random(#set)]
        maze[cell.y][cell.x].south:Open()
        set = {}
      end
    end
  end
  
  for x = 1, #maze[1] - 1 do
    maze[#maze][x].east:Open()
  end
end

return sidewinder