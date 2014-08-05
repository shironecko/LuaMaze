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

local last_generator = "none"

function love.keyreleased(key)
  local generator
  if key == "1" then
    generator = "recursive_backtracker"
  elseif key == "2" then
    generator = "prim"
  elseif key == "3" then
    generator = "eller"
  elseif key == "4" then
    generator = "aldous_broder"
  elseif key == "5" then
    generator = "hunt_and_kill"
  elseif key == "6" then
    generator = "kruskal"
  elseif key == "7" then
    generator = "wilson"
  elseif key == "8" then
    generator = "growing_tree"
  elseif key == "q" then
    generator = "recursive_division"
  elseif key == "w" then
    generator = "binary_tree"
  elseif key == "e" then
    generator = "sidewinder"
  elseif key == "escape" then
    love.event.quit()
  end
  
  if generator then
    local time = love.timer.getTime()
    generators[generator](maze)
    time = love.timer.getTime() - time
    
    last_generator = string.format("%s : %.3fs", generator, time)
  end
end

function love.draw()
  love.graphics.setBackgroundColor(100, 100, 200)
  draw_maze(maze, 10, 10, 20, 10, { 150, 150, 200 }, { 20, 20, 100 })
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(last_generator, 0, 0)
end
--]]