-- Prim's algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/10/maze-generation-prim-s-algorithm
local random = math.random
local pairs = pairs
local Maze = require "maze"
_ENV = nil

local function prim(maze)
  maze:ResetDoors(true)
  
  local frontiers = {}
  local cell = { x = random(maze:width()), y = random(maze:height()) }
  
  while true do
    maze[cell.y][cell.x].visited = true
    maze[cell.y][cell.x].frontier = nil
    
    for _, dirn in pairs(maze:DirectionsFrom(cell.x, cell.y, function (cell) return not cell.visited and not cell.frontier end)) do
      -- Marking every adjastment cell as a frontier, if not done so already
      maze[dirn.y][dirn.x].frontier = true
      frontiers[#frontiers + 1] = { x = dirn.x, y = dirn.y }
    end
    
    -- If there are no frontiers left - our job here is done
    if #frontiers == 0 then break end
    
    -- Choosing random frontier
    local rand_i = random(#frontiers)
    local rand_f = frontiers[rand_i]
    -- Removing it from the list
    frontiers[rand_i] = frontiers[#frontiers]
    frontiers[#frontiers] = nil
    
    -- Choosing random 'in' adjastment cell to carve from
    local ins = {}
    for _, dirn in pairs(maze:DirectionsFrom(rand_f.x, rand_f.y, function (cell) return cell.visited end)) do
      ins[#ins + 1] = dirn.name
    end
    
    maze[rand_f.y][rand_f.x][ins[random(#ins)]]:Open()
    cell = rand_f
  end
    
  maze:ResetVisited()
end

return prim
