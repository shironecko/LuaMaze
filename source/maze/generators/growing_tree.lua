-- Growing tree algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
local random = math.random
local Maze = require "maze"
_ENV = nil

local function growing_tree(maze, selector)
  maze:ResetDoors(true)
  selector = selector or function (list) return random(#list) end
  
  local cell = { x = random(#maze[1]), y = random(#maze) }
  maze[cell.y][cell.x].visited = true
  local list = { cell }
  
  while #list ~= 0 do
    local rnd_i = selector(list)
    cell = list[rnd_i]
    
    local directions = maze:DirectionsFrom(cell.x, cell.y, function (cell) return not cell.visited end)
    
    if #directions < 2 then
      list[rnd_i] = list[#list]
      list[#list] = nil
    end
    if #directions == 0 then goto continue end
    
    local dirn = directions[random(#directions)]
    maze[cell.y][cell.x][dirn.name]:Open()
    maze[dirn.y][dirn.x].visited = true
    list[#list + 1] = { x = dirn.x, y = dirn.y }
    
    ::continue::
  end
  
  maze:ResetVisited()
end

return growing_tree