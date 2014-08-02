-- Sidewinder algorithm
function Maze:Sidewinder(maze)
  maze:resetDoors(true)
  
  local set = {}
  for y = 1, #maze - 1 do
    for x = 1, #maze[1] do
      set[#set + 1] = { x = x, y = y }
      
      if math.random(2) == 1 and x ~= #maze[1] then
        maze[y][x].east:open()
      else
        local cell = set[math.random(#set)]
        maze[cell.y][cell.x].south:open()
        set = {}
      end
    end
  end
  
  for x = 1, #maze[1] - 1 do
    maze[#maze][x].east:open()
  end
end