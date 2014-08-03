-- Wilson's algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/20/maze-generation-wilson-s-algorithm
local random = math.random
local pairs = pairs
local Maze = require "maze"
_ENV = nil

local function wilson(maze)
  maze:ResetDoors(true)
  
  -- List of cells to randomly choose from
  local cells = {}
  for y = 1, #maze do
    for x = 1, #maze[1] do
      local idx = #cells + 1
      cells[idx] = { x = x, y = y }
      maze[y][x].list_idx = idx
    end
  end
  
  local initial_cell = random(#cells)
  local target = maze[cells[initial_cell].y][cells[initial_cell].x]
  target.list_idx = nil
  maze[cells[#cells].y][cells[#cells].x].list_idx = initial_cell
  cells[initial_cell] = cells[#cells]
  cells[#cells] = nil
  
  while #cells ~= 0 do
    local sh = #cells
    local map = {}
    for y = 1, #maze do map[y] = {} end
    
    local starting_cell = cells[random(#cells)]
    local cell = starting_cell
    -- Wander around, forming a path, untill stumble upon allready visited cell (e.g. cell with no index in the list)
    while maze[cell.y][cell.x].list_idx do
      local directions = maze:DirectionsFrom(cell.x, cell.y)      
      local dirn = directions[random(#directions)]
      local new_pos = { x = dirn.x, y = dirn.y }
      map[cell.y][cell.x] = { direction = dirn.name, travel_pos = new_pos }
      cell = new_pos
    end
    
    cell = starting_cell
    local node = map[cell.y][cell.x]
    -- Follow a path and carve it
    while node do
      local cl = maze[cell.y][cell.x]
      maze[cells[#cells].y][cells[#cells].x].list_idx = cl.list_idx
      cells[cl.list_idx] = cells[#cells]
      cells[#cells] = nil
      cl.list_idx = nil
      
      cl[node.direction]:Open()
      cell = node.travel_pos
      node = map[cell.y][cell.x]
    end
  end
end

return wilson