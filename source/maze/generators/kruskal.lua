-- Kruskal's algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/3/maze-generation-kruskal-s-algorithm
local random = math.random
local pairs = pairs
local Maze = require "maze"
_ENV = nil

local function kruskal(maze)
  maze:ResetDoors(true)
  
  local sets = {}
  local walls = {}
  for y = 1, #maze do
    for x = 1, #maze[1] do
      -- Sets
      local currCell = maze[y][x]
      local setID = (y - 1) * #maze[1] + x
      sets[setID] = { [currCell] = true }
      currCell.set = setID
      
      -- Walls list
      if x ~= #maze[1] then 
        walls[#walls + 1] = { from = currCell, to = maze[y][x + 1], direction = "east" } 
      end
      if y ~= #maze then
        walls[#walls + 1] = { from = currCell, to = maze[y + 1][x], direction = "south" }
      end
    end
  end
  
  while #walls ~= 0 do
    -- Choosing a random wall to process, then removing it from the walls list
    local rnd_i = random(#walls)
    local wall = walls[rnd_i]
    walls[rnd_i] = walls[#walls]
    walls[#walls] = nil
    
    if wall.from.set ~= wall.to.set then
      -- Carve
      wall.from[wall.direction]:Open()
      
      -- Merge sets
      local lSet = wall.from.set
      local rSet = wall.to.set
      for cell, _ in pairs(sets[rSet]) do
        sets[lSet][cell] = true
        cell.set = lSet
      end
      sets[rSet] = nil
    end
  end
  
  -- Clean sets data
  for y = 1, #maze do
    for x = 1, #maze[1] do
      maze[y][x].set = nil
    end
  end
end

return kruskal