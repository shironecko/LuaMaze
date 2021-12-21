-- https://github.com/shironecko/LuaMaze

local Maze = 
{
  directions =
  {
    north = { x = 0, y = -1 },
    east  = { x = 1, y = 0 },
    south = { x = 0, y = 1 },
    west  = { x = -1, y = 0 }
  }
}

function Maze:new( width, height, closed, obj )
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self

  -- Actual maze setup
  for y = 1, height do
    obj[y] = {}
    for x = 1, width do
      obj[y][x] = { east = obj:CreateDoor(closed), south = obj:CreateDoor(closed)}
      
      -- Doors are shared between the cells to avoid out of sync conditions and data duplication
      if x ~= 1 then obj[y][x].west = obj[y][x - 1].east
      else obj[y][x].west = obj:CreateDoor(closed) end
      
      if y ~= 1 then obj[y][x].north = obj[y - 1][x].south
      else obj[y][x].north = self:CreateDoor(closed) end
    end
  end
  
  return obj
end

function Maze:width()
  return #self[1]
end

function Maze:height()
  return #self
end

function Maze:DirectionsFrom(x, y, validator)
  local directions = {}
  validator = validator or function() return true end
  
  for name, shift in pairs(self.directions) do
    local x, y = x + shift.x, y + shift.y
    
    if self[y] and self[y][x] and validator(self[y][x], x, y) then
      directions[#directions + 1] = { name = name, x = x, y = y }
    end
  end
  
  return directions
end
  
function Maze:ResetDoors(close, borders)
  for y = 1, #self do
    for i, cell in ipairs(self[y]) do
      cell.north:SetClosed(close or y == 1 and not borders)
      cell.west:SetClosed(close)
    end
    
    self[y][1].west:SetClosed(close or not borders)
    self[y][#self[1]].east:SetClosed(close or not borders)
  end
  
  for i, cell in ipairs(self[#self]) do
    cell.south:SetClosed(close or not borders)
  end
end
  
function Maze:ResetVisited()
  for y = 1, #self do
    for x = 1, #self[1] do
      self[y][x].visited = nil
    end
  end
end

local function walls_to_string(self)
  local str = ""
  for y=1,self.height do
    local line = ""
    for x=1,self.width do
      local c = self.walls[x][y] and '█' or ' '
      line = line .. c
    end
    str = str .. line .. '\n'
  end
  return str
end


local function RemoveDeadEnds(walls)
  local to_fill = {}
  for y = 1, walls.height do
    for x = 1, walls.width do
      local count = 0
      for _,shift in pairs(Maze.directions) do
        local col = walls.walls[x + shift.x]
        local is_wall = col and col[y + shift.y]
        if is_wall then
          count = count + 1
        end
      end
      if count == 3 then
        table.insert(to_fill, { x = x, y = y, })
      end
    end
  end
  for _,pos in ipairs(to_fill) do
    walls.walls[pos.x][pos.y] = true
  end
end

local function ExpandRooms(walls, threshold)
  -- 4 is a good threshold for general expanding and 5 will eliminates single
  -- cell nubs.
  threshold = threshold or 4
  local eightway = {
    north = { x = 0,  y = -1 },
    east  = { x = 1,  y = 0 },
    south = { x = 0,  y = 1 },
    west  = { x = -1, y = 0 },
    ne    = { x = 1,  y = -1 },
    nw    = { x = -1, y = -1 },
    se    = { x = 1,  y = 1 },
    sw    = { x = -1, y = 1 },
  }
  local growth = {}
  for y = 1, walls.height do
    for x = 1, walls.width do
      if walls.walls[x][y] then
        local count = 0
        for _,shift in pairs(eightway) do
          local col = walls.walls[x + shift.x] or nil
          local cell = col and col[y + shift.y] or nil
          local is_wall = col == nil or cell
          if not is_wall then
            count = count + 1
          end
        end
        if count >= threshold then
          table.insert(growth, { x = x, y = y, count = count, })
        end
      end
    end
  end
  for _,pos in ipairs(growth) do
    walls.walls[pos.x][pos.y] = false
  end
  if walls.closed then
    walls:EnsureBorder()
  end
end

local function EnsureBorder(walls)
  for x = 1, walls.width do
    walls.walls[x][1] = true
    walls.walls[x][walls.height] = true
  end
  for y = 1, walls.height do
    walls.walls[1][y] = true
    walls.walls[walls.width][y] = true
  end
end


-- Create a table for building walls as tiles -- each position is a wall or is
-- not a wall. Useful for bitmasked tilesets
-- (https://gamedevelopment.tutsplus.com/tutorials/how-to-use-tile-bitmasking-to-auto-tile-your-level-layouts--cms-25673)
-- table contents: {
--   walls: table where t[x][y] is a whether a wall.
--   width: width of walls table.
--   height: width of walls table.
--   tostring: build a string to visualize the tiles.
-- }
function Maze:AsTileLayout(closed)
  local data = {}

  local w = self:width() * 2 + 1
  local h = self:height() * 2 + 1
  for x = 1, w do
    data[x] = {}
    for y = 1, h do
      data[x][y] = closed
    end
  end

  local function safe_set(x,y, val)
    if data[x] then
      data[x][y] = val
    end
  end
      
  for col = 1, self:width() do
    for row = 1, self:height() do
      local room = self[row][col]
      local x,y = col*2, row*2
      data[x][y] = false
      safe_set(x,   y-1, room.north:IsClosed())
      safe_set(x-1, y,   room.west:IsClosed())
      safe_set(x,   y+1, room.south:IsClosed())
      safe_set(x+1, y,   room.east:IsClosed())
    end
  end

  return { walls = data, width = w, height = h,
    closed = closed,
    tostring = walls_to_string,
    RemoveDeadEnds = RemoveDeadEnds,
    ExpandRooms = ExpandRooms,
    EnsureBorder = EnsureBorder,
  }
end

local function test_AsTileLayout()
  local m = Maze:new(4, 8)
  m[1][1].north:Close()
  m[1][1].south:Close()
  m[1][1].east:Close()
  m[1][1].west:Close()

  local w = m:AsTileLayout(true)

  --~ print() print(w:tostring())

  for i=1,3 do
    -- top
    assert(w.walls[i][1])
    assert(w.walls[i][1])
    assert(w.walls[i][1])

    -- bottom
    assert(w.walls[i][3])
    assert(w.walls[i][3])
    assert(w.walls[i][3])
  end
  -- sides
  assert(w.walls[1][2])
  assert(w.walls[3][2])

  m:ResetDoors()
  m[6][1].north:Close()
  m[6][1].west:Close()
  m[6][1].east:Close()
  m[7][1].west:Close()
  m[7][1].east:Close()
  m[8][1].west:Close()
  m[8][1].south:Close()
  m[8][2].north:Close()
  m[8][2].south:Close()
  m[8][2].east:Close()
  w = m:AsTileLayout(true)
  
  --~ print() print(w:tostring())

  -- vertical path
  for i=12,12+4 do
    assert(w.walls[1][i], i) -- wall
    assert(w.walls[2][i] == false, i) -- path
    assert(w.walls[3][i] or i == 16, i) -- wall
  end
  -- horizontal path
  for i=2,2+2 do
    assert(w.walls[i][15] or i == 2, i)
    assert(w.walls[i][16] == false, i)
    assert(w.walls[i][17], i)
  end
end

local function test_RemoveDeadEnds()
  local m = Maze:new(4, 8)
  m[6][1].north:Close()
  m[6][1].west:Close()
  m[6][1].east:Close()
  m[7][1].west:Close()
  m[7][1].east:Close()
  m[8][1].west:Close()
  m[8][1].south:Close()
  m[8][2].north:Close()
  m[8][2].south:Close()
  m[8][2].east:Close()

  local w = m:AsTileLayout(true)

  --~ print() print(w:tostring())

  assert(w.walls[2][11] == true, "expected dead end wall")
  assert(w.walls[2][12] == false, "expected path, dead end")
  assert(w.walls[2][13] == false, "expected path")

  assert(w.walls[5][16] == true, "expected dead end wall")
  assert(w.walls[4][16] == false, "expected path, dead end")
  assert(w.walls[3][16] == false, "expected path")

  w:RemoveDeadEnds()

  assert(w.walls[2][11] == true, "expected still dead end wall")
  assert(w.walls[2][12] == true, "expected filled")
  assert(w.walls[2][13] == false, "expected still path")

  assert(w.walls[5][16] == true, "expected still dead end wall")
  assert(w.walls[4][16] == true, "expected filled")
  assert(w.walls[3][16] == false, "expected still path")
  
  --~ print() print(w:tostring())
end

local function test_ExpandRooms()
  -- Must make maze closed so we don't clear everything.
  local m = Maze:new(4, 8, true)
  m[6][1].south:Open()
  m[7][1].north:Open()
  m[7][1].south:Open()
  m[8][1].north:Open()
  m[8][1].east:Open()

  local w = m:AsTileLayout(true)

  --~ print() print(w:tostring())

  assert(w.walls[2][14] == false, "expected path")
  assert(w.walls[3][16] == false, "expected path")

  assert(w.walls[2][11] == true, "expected dead end wall")
  assert(w.walls[2][12] == false, "expected path, dead end")
  assert(w.walls[2][13] == false, "expected path")

  assert(w.walls[5][16] == true, "expected dead end wall")
  assert(w.walls[4][16] == false, "expected path, dead end")
  assert(w.walls[3][16] == false, "expected path")

  w:ExpandRooms()

  assert(w.walls[2][14] == false, "expected still path")
  assert(w.walls[3][16] == false, "expected still path")
  
  assert(w.walls[2][11] == true, "expected still dead end wall")
  assert(w.walls[2][12] == false, "expected still dead end path")
  assert(w.walls[2][13] == false, "expected still path")
  assert(w.walls[3][13] == false, "expected cleared")

  assert(w.walls[5][16] == true, "expected still dead end wall")
  assert(w.walls[4][16] == false, "expected cleared")
  assert(w.walls[3][16] == false, "expected still path")
  assert(w.walls[3][15] == false, "expected cleared")
  
  --~ print() print(w:tostring())
end


function Maze.tostring(maze, wall, passage)
  wall = wall or "#"
  passage = passage or " "
  
  local result = ""
  
  local verticalBorder = ""
  for i = 1, #maze[1] do
    verticalBorder = verticalBorder .. wall .. (maze[1][i].north:IsClosed() and wall or passage)
  end
  verticalBorder = verticalBorder .. wall
  result = result .. verticalBorder .. "\n"

  for y, row in ipairs(maze) do
    local line = row[1].west:IsClosed() and wall or passage
    local underline = wall
    for x, cell in ipairs(row) do
      line = line .. " " .. (cell.east:IsClosed() and wall or passage)
      underline = underline .. (cell.south:IsClosed() and wall or passage) .. wall
    end
    result = result .. line .. "\n" .. underline .. "\n"
  end
  
  return result
end

Maze.__tostring = Maze.tostring

function Maze:CreateDoor(closed)
  local door = {}
  door.closed = closed and true or false
  
  function door:IsClosed()
    return self.closed
  end
  
  function door:IsOpened()
    return not self.closed
  end
  
  function door:Close()
    self.closed = true
  end
  
  function door:Open()
    self.closed = false
  end
  
  function door:SetOpened(opened)
    if opened then
      self:Open()
    else
      self:Close()
    end
  end
  
  function door:SetClosed(closed)
    self:SetOpened(not closed)
  end
  
  return door
end

return Maze
