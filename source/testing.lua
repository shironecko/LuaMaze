require "maze"

maze = Maze:Create(20, 3, true)
math.randomseed(os.time())
Maze:recursiveBacktracker(maze)
print(maze:tostring())