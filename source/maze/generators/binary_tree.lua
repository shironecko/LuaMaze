-- Binary tree algorithm
function Maze:BinaryTree(maze)
  maze:resetDoors(true)
  
  for y = 1, #maze do
    for x = 1, #maze[1] do
      if x ~= #maze[1] and (y == #maze or math.random(2) == 1) then
        maze[y][x].east:open()
      else
        maze[y][x].south:open()
      end
    end
  end
  
  maze[#maze][#maze[1]].south:close()
end