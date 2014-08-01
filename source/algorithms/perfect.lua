require "maze"

--[[
This is the implementations of the perfect maze generation algorithm which descriptions
can be found at http://www.astrolog.org/labyrnth/algrithm.htm
]]

-- Backtracker algorithm (a variation of the recursive backtracker algorithm made without recursion)
function Maze:Backtracker(maze)
  maze:resetDoors(true)
  
  local stack = Stack:Create()
  
  local cell = { x = 1, y = 1 }
  while true do
    maze[cell.y][cell.x].visited = true
    
    -- Gathering all possible travel direction in a list
    local directions = {}
    for key, value in pairs(self.directions) do
      local newPos = { x = cell.x + value.x, y = cell.y + value.y }
      -- Checking if the targeted cell is in bounds and was not visited previously
      if maze[newPos.y] and maze[newPos.y][newPos.x] and not maze[newPos.y][newPos.x].visited then
        directions[#directions + 1] = { name = key, pos = newPos }
      end
    end
        
    -- If there are no possible travel directions - backtracking
    if #directions == 0 then
      if #stack > 0 then
        cell = stack:pop()
        goto continue
      else break end -- Stack is empty and there are no possible directions - maze is generated
    end
    
    -- Choosing a random direction from a list of possible direction and carving
    stack:push(cell)
    local dir = directions[math.random(#directions)]
    maze[cell.y][cell.x][dir.name]:open() 
    cell = dir.pos
    
    ::continue::
  end
  
  maze:resetVisited()
end

-- Recursive Backtracker algorithm
function Maze:RecursiveBacktracker(maze, cell)
  local firstOne = nil
  if not cell then
    maze:resetDoors(true)
    cell = { x = 1, y = 1 }
    firstOne = true
  end
  
  maze[cell.y][cell.x].visited = true
  
  local directions = {}
  for key, value in pairs(self.directions) do
    local newPos = { x = cell.x + value.x, y = cell.y + value.y }
    
    if maze[newPos.y] and maze[newPos.y][newPos.x] and not maze[newPos.y][newPos.x].visited then
      directions[#directions + 1] = { name = key, pos = newPos }
    end
  end
  
  while #directions ~= 0 do
    local rand_i = math.random(#directions)
    local dir = directions[rand_i]
    
    directions[rand_i] = directions[#directions]
    directions[#directions] = nil
    
    if not maze[dir.pos.y][dir.pos.x].visited then
      maze[cell.y][cell.x][dir.name]:open()
      Maze:RecursiveBacktracker(maze, dir.pos)
    end
  end
  
  if firstOne then maze:resetVisited() end
end

-- Prim's algorithm
function Maze:Prim(maze)
  maze:resetDoors(true)
  
  local frontiers = {}
  local cell = { x = math.random(#maze[1]), y = math.random(#maze) }
  
  while true do
    maze[cell.y][cell.x].visited = true
    maze[cell.y][cell.x].frontier = nil
    
    for key, value in pairs(self.directions) do
      local newPos = { x = cell.x + value.x, y = cell.y + value.y }
      
      -- Marking every adjastment cell as a frontier, if not done so already
      if maze[newPos.y] and maze[newPos.y][newPos.x] and not maze[newPos.y][newPos.x].visited and
      not maze[newPos.y][newPos.x].frontier then
        maze[newPos.y][newPos.x].frontier = true
        frontiers[#frontiers + 1] = newPos
      end
    end
    
    -- If there are no frontiers left - our job here is done
    if #frontiers == 0 then break end
    
    -- Choosing random frontier
    local rand_i = math.random(#frontiers)
    local rand_f = frontiers[rand_i]
    -- Removing it from the list
    frontiers[rand_i] = frontiers[#frontiers]
    frontiers[#frontiers] = nil
    
    -- Choosing random 'in' adjastment cell to carve from
    local ins = {}
    for key, value in pairs(self.directions) do
      local newPos = { x = rand_f.x + value.x, y = rand_f.y + value.y }
      
      if maze[newPos.y] and maze[newPos.y][newPos.x] and maze[newPos.y][newPos.x].visited then
        ins[#ins + 1] = key
      end
    end
    
    maze[rand_f.y][rand_f.x][ins[math.random(#ins)]]:open()
    cell = rand_f
  end
    
  maze:resetVisited()
end

--Aldous-Broder algorithm
function Maze:AldousBroder(maze)
  maze:resetDoors(true)
  local remaining = #maze * #maze[1] - 1
  
  local cell = { x = math.random(#maze[1]), y = math.random(#maze) }
  maze[cell.y][cell.x].visited = true
  while remaining ~= 0 do
    local directions = {}
    for key, value in pairs(self.directions) do
      local newPos = { x = cell.x + value.x, y = cell.y + value.y }
      
      if maze[newPos.y] and maze[newPos.y][newPos.x] then
        directions[#directions + 1] = { name = key, pos = newPos }
      end
    end
    
    local dir = directions[math.random(#directions)]
    if not maze[dir.pos.y][dir.pos.x].visited then
      maze[dir.pos.y][dir.pos.x].visited = true
      maze[cell.y][cell.x][dir.name]:open()
      remaining = remaining - 1
    end
    
    cell = dir.pos
  end
  
  maze:resetVisited()
end 

-- Hunt and kill algorithm
function Maze:HuntAndKill(maze)
  maze:resetDoors(true)
  
  maze[1][1].visited = true
  while true do
    local cell
    -- Hunt
    for y = 1, #maze do
      for x = 1, #maze[1] do
        if maze[y][x].visited then
          for key, value in pairs(self.directions) do
            newPos = { x = x + value.x, y = y + value.y }
            
            if maze[newPos.y] and maze[newPos.y][newPos.x] and not maze[newPos.y][newPos.x].visited then
              cell = { x = x, y = y }
              goto carve
            end
          end
        end
      end
    end
    
    -- If we're reached this spot, then there left no unvisited cells
    goto hunt_completed
    
    ::carve::
    while true do
      -- Gathering all possible travel direction in a list
      local directions = {}
      for key, value in pairs(self.directions) do
        local newPos = { x = cell.x + value.x, y = cell.y + value.y }
        -- Checking if the targeted cell is in bounds and was not visited previously
        if maze[newPos.y] and maze[newPos.y][newPos.x] and not maze[newPos.y][newPos.x].visited then
          directions[#directions + 1] = { name = key, pos = newPos }
        end
      end
      
      -- If there are no possible carve directions, then we sould enter the hunt mode again
      if #directions == 0 then break end
      
      -- Choosing a random direction from a list of possible direction and carving
      local dir = directions[math.random(#directions)]
      maze[cell.y][cell.x][dir.name]:open() 
      cell = dir.pos
      maze[cell.y][cell.x].visited = true
    end
  end
  
  ::hunt_completed::
  maze:resetVisited()
end

-- Kruskal's algorithm
function Maze:Kruskal(maze)
  maze:resetDoors(true)
  
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
    local rnd_i = math.random(#walls)
    local wall = walls[rnd_i]
    walls[rnd_i] = walls[#walls]
    walls[#walls] = nil
    
    if wall.from.set ~= wall.to.set then
      -- Carve
      wall.from[wall.direction]:open()
      
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

-- Eller's algorithm
function Maze:Eller(maze)
  maze:resetDoors(true)
  
  -- Prepairing sets representations
  local sets = {}
  local setMap = {}
  for i = 1, #maze[1] do
    setMap[i] = i
    sets[i] = { [i] = true, n = 1 }
  end
  
  for y = 1, #maze do
    for x = 1, #maze[1] - 1 do
      -- Randomly remove east wall and merging sets
      if setMap[x] ~= setMap[x + 1] and
      (math.random(2) == 1 or y == #maze) then
        maze[y][x].east:open()
        -- Merging sets together
        local lIndex = setMap[x]; local rIndex = setMap[x + 1]
        local lSet = sets[lIndex]; local rSet = sets[rIndex]
        for i = 1, #maze[1] do
          if setMap[i] ~= rIndex then goto continue end
          lSet[i] = true; lSet.n = lSet.n + 1
          rSet[i] = nil;  rSet.n = rSet.n - 1
          setMap[i] = lIndex
          ::continue::
        end
      end
    end
    
    if y == #maze then break end
    
    -- Randomly remove south walls and making sure that at least one cell in each set has no south wall
    for i, set in pairs(sets) do
      local opened
      local lastCell
      for x, j in pairs(set) do
        if x == "n" then goto continue end
        lastCell = x
        if math.random(2) == 1 then 
          maze[y][x].south:open() 
          opened = true
        end
        ::continue::
      end
      
      if not opened and lastCell then maze[y][lastCell].south:open() end
    end
    
    -- Removing cell with south walls from their sets
    for x = 1, #maze[1] do
      if maze[y][x].south:isClosed() then
        local set = sets[setMap[x]]
        set[x] = nil; set.n = set.n - 1
        setMap[x] = nil
      end
    end
    
    -- Gathering all empty sets in a list
    local emptySets = {}
    for i, set in pairs(sets) do
      if set.n == 0 then emptySets[#emptySets + 1] = i end
    end
    
    -- Assigning all cell without a set to an empty set from the list
    for x = 1, #maze[1] do
      if not setMap[x] then
        setMap[x] = emptySets[#emptySets]; emptySets[#emptySets] = nil
        local set = sets[setMap[x]]
        set[x] = true; set.n = set.n + 1
      end
    end
  end
end

-- Wilson's algorithm
function Maze:Wilson(maze)
  maze:resetDoors(true)
  
  -- List of cells to randomly choose from
  local cells = {}
  for y = 1, #maze do
    for x = 1, #maze[1] do
      local idx = #cells + 1
      cells[idx] = { x = x, y = y }
      maze[y][x].list_idx = idx
    end
  end
  
  local initial_cell = math.random(#cells)
  local target = maze[cells[initial_cell].y][cells[initial_cell].x]
  target.list_idx = nil
  maze[cells[#cells].y][cells[#cells].x].list_idx = initial_cell
  cells[initial_cell] = cells[#cells]
  cells[#cells] = nil
  
  while #cells ~= 0 do
    local sh = #cells
    local map = {}
    for y = 1, #maze do map[y] = {} end
    
    local starting_cell = cells[math.random(#cells)]
    local cell = starting_cell
    -- Wander around, forming a path, untill stumble upon allready visited cell (e.g. cell with no index in the list)
    while maze[cell.y][cell.x].list_idx do
      local directions = {}
      for key, value in pairs(self.directions) do
        local newPos = { x = cell.x + value.x, y = cell.y + value.y }
        
        if maze[newPos.y] and maze[newPos.y][newPos.x] then
          directions[#directions + 1] = { name = key, pos = newPos }
        end
      end
      
      local dir = directions[math.random(#directions)]
      map[cell.y][cell.x] = { direction = dir.name, travelPos = dir.pos }
      cell = dir.pos
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
      
      cl[node.direction]:open()
      cell = node.travelPos
      node = map[cell.y][cell.x]
    end
  end
end

-- Growing tree algorithm
function Maze:GrowingTree(maze, selector)
  maze:resetDoors(true)
  selector = selector or function (list) return math.random(#list) end
  
  local cell = { x = math.random(#maze[1]), y = math.random(#maze) }
  maze[cell.y][cell.x].visited = true
  local list = { cell }
  
  while #list ~= 0 do
    local rnd_i = selector(list)
    cell = list[rnd_i]
    
    local directions = {}
    for key, value in pairs(self.directions) do
      local newPos = { x = cell.x + value.x, y = cell.y + value.y }
      
      if maze[newPos.y] and maze[newPos.y][newPos.x] and not maze[newPos.y][newPos.x].visited then
        directions[#directions + 1] = { name = key, pos = newPos }
      end
    end
    
    if #directions < 2 then
      list[rnd_i] = list[#list]
      list[#list] = nil
    end
    if #directions == 0 then goto continue end
    
    local dir = directions[math.random(#directions)]
    maze[cell.y][cell.x][dir.name]:open()
    maze[dir.pos.y][dir.pos.x].visited = true
    list[#list + 1] = dir.pos
    
    ::continue::
  end
  
  maze:resetVisited()
end

-- Recursive division algorithm
function Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x, y, w, h)
  if not x then
    maze:resetDoors(false, false)
    x, y, w, h = 1, 1, #maze[1], #maze
    
    splitDecider = splitDecider or function (w, h) 
      do return w > h end
      if w > h then
        return math.random(5) > 1
      elseif h > w then
        return math.random(5) == 1
      else
        return math.random(2) == 1
      end
    end
    
    splitBalancer = splitBalancer or function(length)
      return math.random(length)
    end
  elseif w <= 1 and h <= 1 then return end
  
  if h == 1 or w > 1 and splitDecider(w, h) then
    -- Vertical wall
    local halfW = splitBalancer(w - 1)
    local middle = x - 1 + halfW
    for _y = y, y - 1 + h do
      maze[_y][middle].east:close()
    end
    
    maze[math.random(y, y - 1 + h)][middle].east:open()
    
      Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x, y, halfW, h)
      Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x + halfW, y, w - halfW, h)
  else
    -- Horizontal wall
    local halfH = splitBalancer(h - 1)
    local middle = y - 1 + halfH
    for _x = x, x - 1 + w do
      maze[middle][_x].south:close()
    end
    
    maze[middle][math.random(x, x - 1 + w)].south:open()
    
    Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x, y, w, halfH)
    Maze:RecursiveDivision(maze, splitDecider, splitBalancer, x, y + halfH, w, h - halfH)
  end
end