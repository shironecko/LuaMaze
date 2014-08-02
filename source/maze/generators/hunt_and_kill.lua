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