-- Wilson's algorithm
-- Detailed description: http://weblog.jamisbuck.org/2011/1/20/maze-generation-wilson-s-algorithm
local random = math.random
local ceil = math.ceil

-- Data structure that will map itself onto the maze and will contain the list of cells
local CellList = {}

function CellList:new(maze, list)
  list = list or {}

  -- this vars and some of the functions will be hidden inside a closure
  local width = maze:width()
  local height = maze:height()

  local function hash(x, y)
    return width * (y - 1) + x
  end

  local function dehash(hash)
    local x = hash % width
    local y = ceil(hash / width)

    if x == 0 then
      x = width
    end

    return x, y
  end

  -- vector of cell for O(1) random cell picking
  local cells_vec = {}

  -- hash table of cells for O(1) lookup time
  -- each entry is an index to cell_vec, for keeping track where each cell is stored
  local cells_table = {}

  for y = 1, height do
    for x = 1, width do
      local prod = hash(x, y)
      cells_vec[prod] = prod
      cells_table[prod] = prod
    end
  end
  
  -- Interface of the list

  -- returns true if the cell with [x, y] coord is in this list, false othervise
  function list:contains(x, y)
    if cells_table[hash(x, y)] then
      return true
    else
      return false
    end
  end

  -- returns x and y coord of the random cell in this list
  function list:random()
    return dehash(cells_vec[random(#cells_vec)])
  end

  -- removes cell from a list, if list does not contain a cell with supplied coords - invokes error
  function list:remove(x, y)
    local idx = hash(x, y)
    if not cells_table[idx] then
      error("Attempting to remove cell that is not in the list!", 2)
    end

    -- copy value and update pointer
    cells_vec[cells_table[idx]] = cells_vec[#cells_vec]
    cells_table[cells_vec[#cells_vec]] = cells_table[idx]

    -- remove garbage
    cells_vec[#cells_vec] = nil
    cells_table[idx] = nil
  end

  -- returns the number of cells in the list
  function list:length()
    return #cells_vec
  end

  return list
end

-- simple 2D map that will be used to mark algorithms path
local Map = {}

function Map:new(maze, map)
  map = map or {}

  for i = 1, maze:height() do
    map[#map + 1] = {}
  end

  return map
end

local function wilson(maze)
  maze:ResetDoors(true)

  -- list of all cells
  local list = CellList:new(maze)

  list:remove(list:random())

  while list:length() ~= 0 do
    local start_x, start_y = list:random()
    local x, y = start_x, start_y

    -- wander around the maze creating a path
    map = Map:new(maze)
    repeat
      local directions = maze:DirectionsFrom(x, y)
      local dirn = directions[random(#directions)]

      map[y][x] = dirn
      x, y = dirn.x, dirn.y
    until not list:contains(x, y)

    -- carve along the latest path
    x, y = start_x, start_y
    repeat
      list:remove(x, y)

      local dirn = map[y][x]
      maze[y][x][dirn.name]:Open()
      x, y = dirn.x, dirn.y
    until not list:contains(x, y)
  end
end

return wilson
