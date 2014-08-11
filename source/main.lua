local Maze = require "maze"
local generators = require "maze.generators"

local draw_maze;
local maze;
local text;

local generators_aliases =
{
  aldous_broder         = "Aldous - Broder",
  binary_tree           = "Binary Tree",
  eller                 = "Eller's algorithm",
  growing_tree          = "Growing Tree",
  hunt_and_kill         = "Hunt and Kill",
  kruskal               = "Kruskal's algorithm",
  prim                  = "Prim's algorithm",
  recursive_backtracker = "Recursive Backtracker",
  recursive_division    = "Recursive Division",
  sidewinder            = "Sidewinder",
  wilson                = "Wilson's algorithm"
}

local generators_aliases_rev;


function love.load()
  -- seems like a weird place to put require to, but whatever, documentation says so...
  require "frames"
  
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  generators_aliases_rev = {}
  for key, value in pairs(generators_aliases) do
    generators_aliases_rev[value] = key
  end
  
  -- Interface
  local margin = 10
  local width_franction = 0.3
  
  local frame = loveframes.Create("frame")
  frame:SetName("Maze generation")
  frame.width = love.graphics.getWidth() * width_franction
  frame.height = love.graphics.getHeight() - margin * 2
  frame.x = love.graphics.getWidth() - frame.width - margin
  frame.y = margin
  frame:SetDraggable(false):ShowCloseButton(false)
  
  local generators_list = loveframes.Create("list", frame)
  generators_list:SetPos(margin, 25 + margin):SetSize(frame.width - margin * 2, frame.height * 0.475)
  for name, generator in pairs(generators) do
    local button = loveframes.Create("button")
    button:SetText(generators_aliases[name])
    button.OnClick = function(obj)
        local time = love.timer.getTime()
        generators[name](maze)
        time = love.timer.getTime() - time
        
        text:SetText(string.format("Algorithm: %s\nTime: %.4fs", obj:GetText(), time))
      end
    
    generators_list:AddItem(button)
  end
  
  text = loveframes.Create("text", frame)
  text:SetPos(margin, generators_list.y + generators_list.height + 50)
  text:SetSize(frame.width - margin * 2, frame.height * 0.3)
  
  -- Maze creation and misc
  maze = Maze:new(17, 19, true)
  math.randomseed(os.time())
end

function love.update(dt)
  loveframes.update(dt) 
end

function love.draw()
  love.graphics.setBackgroundColor(100, 100, 200)
  draw_maze(maze, 10, 10, 20, 10, { 150, 150, 200 }, { 20, 20, 100 })
  love.graphics.setColor(255, 255, 255)
  
  loveframes.draw()
end
 
function love.mousepressed(x, y, button)
  loveframes.mousepressed(x, y, button)
end
 
function love.mousereleased(x, y, button)
  loveframes.mousereleased(x, y, button) 
end
 
function love.keypressed(key, unicode)
  loveframes.keypressed(key, unicode) 
end
 
function love.keyreleased(key)
  loveframes.keyreleased(key) 
end

draw_maze = function(maze, x, y, cell_dim, wall_dim, cell_col, wall_col)
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