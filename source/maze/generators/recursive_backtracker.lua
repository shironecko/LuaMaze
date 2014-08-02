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
