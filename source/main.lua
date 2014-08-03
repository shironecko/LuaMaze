local Maze = require "maze"
local generators = require "maze.generators"

---[[
function draw_maze(maze, x, y, cell_dim, wall_dim, cell_col, wall_col)
  love.graphics.setColor(wall_col)
  local maze_width = (cell_dim + wall_dim) * #maze[1] + wall_dim
  local maze_height = (cell_dim + wall_dim) * #maze + wall_dim
  love.graphics.rectangle("fill", x, y, maze_width, maze_height)
  
  love.graphics.setColor(cell_col)
  for yi = 1, #maze do
    for xi = 1, #maze[1] do
      local pos_x = x + (cell_dim + wall_dim) * (xi - 1) + wall_dim
      local pos_y = y + (cell_dim + wall_dim) * (yi - 1) + wall_dim
      love.graphics.rectangle("fill", pos_x, pos_y, cell_dim, cell_dim)
      
      -- Need to redo this, badly...
      if maze[yi][xi].north:IsOpened() then
        love.graphics.rectangle("fill", pos_x, pos_y - wall_dim, cell_dim, wall_dim)
      end
      if maze[yi][xi].east:IsOpened() then
        love.graphics.rectangle("fill", pos_x + cell_dim, pos_y, wall_dim, cell_dim)
      end
      if maze[yi][xi].south:IsOpened() then
        love.graphics.rectangle("fill", pos_x, pos_y + cell_dim, cell_dim, wall_dim)
      end
      if maze[yi][xi].west:IsOpened() then
        love.graphics.rectangle("fill", pos_x - wall_dim, pos_y, wall_dim, cell_dim)
      end
    end
  end 
end

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  maze = Maze:new(25, 19)
  math.randomseed(os.time())
end

function love.keyreleased(key)
  if key == "1" then
    generators.recursive_backtracker(maze)
  elseif key == "2" then
    generators.prim(maze)
  elseif key == "3" then
    generators.eller(maze)
  elseif key == "4" then
    generators.aldous_broder(maze)
  elseif key == "5" then
    generators.hunt_and_kill(maze)
  elseif key == "6" then
    generators.kruskal(maze)
  elseif key == "7" then
    generators.wilson(maze)
  elseif key == "8" then
    generators.growing_tree(maze)
  elseif key == "q" then
    generators.recursive_division(maze)
  elseif key == "w" then
    generators.binary_tree(maze)
  elseif key == "e" then
    generators.sidewinder(maze)
  elseif key == "escape" then
    love.event.quit()
  end
end

function love.draw()
  love.graphics.setBackgroundColor(100, 100, 200)
  draw_maze(maze, 10, 10, 20, 10, { 150, 150, 200 }, { 20, 20, 100 })
end
--]]