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