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
        goto countinue
      else break end -- Stack is empty and there are no possible directions - maze is generated
    end
    
    -- Choosing a random direction from a list of possible direction and carving
    stack:push(cell)
    local dir = directions[math.random(#directions)]
    maze[cell.y][cell.x][dir.name]:open() 
    cell = dir.pos
    
    ::countinue::
  end
  
  maze:resetVisited()
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