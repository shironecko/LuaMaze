-- this is an example love2d project entry-point

local Maze = require "maze"

local maze

local algo = "recursive_backtracker"

function love.load()
  math.randomseed(os.time())
  maze = Maze:new(17, 19, true)
  Maze.generators[algo](maze)
  print(algo .. ":")
  print(maze)
end

function love.draw()
  Maze.love.rect(maze, 10, 10, 20, 10, { 0, 0, 0.5 }, { 0.1, 0.2, 0.2 })
end
