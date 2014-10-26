-- Binary tree algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/2/1/maze-generation-binary-tree-algorithm
local random = math.random
local Maze = require "maze"
_ENV = nil

local function binary_tree(maze)
  maze:ResetDoors(true)
  
  -- wander through the maze
  for y = 1, maze:height() do
    for x = 1, maze:width() do
      -- and randomly open east or south doors
      if x ~= maze:width() and (y == maze:height() or random(2) == 1) then
        maze[y][x].east:Open()
      else
        maze[y][x].south:Open()
      end
    end
  end
  
  maze[maze:height()][maze:width()].south:Close()
end

return binary_tree
