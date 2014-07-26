require "maze"
require "algorithms/perfect"

maze = Maze:Create(10, 10, true)
--[[  Maze generation depends on the random seed, so you will get 
      exactly identical maze every time you pass exactly identical seed ]]
math.randomseed(os.time())
Maze:Prim(maze)
print(maze:tostring())