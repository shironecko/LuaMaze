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
