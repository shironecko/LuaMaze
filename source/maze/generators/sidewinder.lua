-- Sidewinder algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/2/3/maze-generation-sidewinder-algorithm
local random = math.random
local Maze = require "maze"
_ENV = nil

local function sidewinder(maze)
  maze:ResetDoors(true)
  
  local set = {}
  for y = 1, maze:height() - 1 do
    -- for each cell in a row
    for x = 1, maze:width() do
      -- add cell to the set
      set[#set + 1] = { x = x, y = y }
      
      -- randomly choose will we carve east (right)
      if random(2) == 1 and x ~= maze:width() then
        maze[y][x].east:Open()
      else
        -- if not, carve north (down) from the random cell in the current set
        local cell = set[random(#set)]
        maze[cell.y][cell.x].south:Open()
        -- start a new set
        set = {}
      end
    end
  end
  
  -- open all side walls of the last row
  for x = 1, maze:width() - 1 do
    maze[maze:height()][x].east:Open()
  end
end

return sidewinder
