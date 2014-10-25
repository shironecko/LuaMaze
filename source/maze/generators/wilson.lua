-- Wilson's algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/20/maze-generation-wilson-s-algorithm
local random = math.random
local setmetatable = setmetatable
local pairs = pairs
local error = error
local Maze = require "maze"
_ENV = nil

-- Data structure that will map itself onto the maze and will contain the list of cells
local CellList = {}

function CellList:new(maze, obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self

  obj.maze = maze

  -- map this list to the maze
  for y = 1, #maze do
    for x = 1, #maze[1] do
      local idx = #obj + 1
      obj[idx] = { x = x, y = y, pointer = maze[y][x] }
      maze[y][x].list_idx = idx
    end
  end

  return obj
end

function CellList:remove(cell)
  if type(cell) == "number" then
    -- cell is list index
    cell = self[cell].pointer
  else
    -- cell is the actual cell or coordinates in maze
    cell = cell.pointer or self.maze[cell.y][cell.x]
  end

  if not cell then error("Cell is null!", 2) end

  local idx = cell.list_idx
  cell.list_idx = nil

  self[idx] = self[#self]
  self[idx].pointer.list_idx = idx
  self[#self] = nil
end

function CellList:random()
  return self[random(#self)]
end

local function wilson(maze)
  maze:ResetDoors(true)
  
  -- list of cells to randomly choose from
  local cells = CellList:new(maze)
  cells:remove(random(#cells))
  

  while #cells ~= 0 do
    local starting_cell = cells:random()
    local cell = starting_cell
    
    -- travel map for algorithm
    local map = {}
    for y = 1, #maze do map[y] = {} end

    -- wander around, forming a path, untill stumble cell that is a part of the maze already
    while cell.pointer.list_idx do
      local directions = maze:DirectionsFrom(cell.x, cell.y)      
      local dirn = directions[random(#directions)]
      local new_pos = { x = dirn.x, y = dirn.y, pointer = maze[dirn.y][dirn.x] }
      map[cell.y][cell.x] = { direction = dirn.name, travel_pos = new_pos }
      cell = new_pos
    end
    
    cell = starting_cell
    local node = map[cell.y][cell.x]

    -- follow a path and carve it
    while node do
      cells:remove(cell)
      
      cell.pointer[node.direction]:Open()
      cell = node.travel_pos
      node = map[cell.y][cell.x]
    end
  end
end

return wilson
