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