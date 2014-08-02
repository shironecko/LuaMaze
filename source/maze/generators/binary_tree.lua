-- Binary tree algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/2/1/maze-generation-binary-tree-algorithm
local random = math.random
local Maze = require "maze"
_ENV = nil

local function binary_tree(maze)
  maze:ResetDoors(true)
  
  for y = 1, #maze do
    for x = 1, #maze[1] do
      if x ~= #maze[1] and (y == #maze or random(2) == 1) then
        maze[y][x].east:Open()
      else
        maze[y][x].south:Open()
      end
    end
  end
  
  maze[#maze][#maze[1]].south:Close()
end

return binary_tree