-- this is an example love2d project entry-point

local Maze = require "maze"
local list = require "listbox"

local maze
local batches
local image
local algo = "aldous_broder"
local time = 0

function love.load()
  love.window.setTitle("LuaMaze")
  math.randomseed(os.time())
  maze = Maze:new(17, 18, true)
  local t = os.clock()
  Maze.generators[algo](maze)
  time = os.clock() - t

  image = love.graphics.newImage("assets/maze.png")
  batches = Maze.love.tile:setup(maze, image)

  local tlist = {
    selected=1,
    x=560,
    y=10,
    font=love.graphics.newFont(15),
    ismouse=true,
    w=230,
    h=200,
    
    -- colors mapped to new 0-1 standard
    fcolor={0, 0.7450980392156863, 0},
    bordercolor={0.19607843137254902, 0.19607843137254902, 0.19607843137254902},
    selectedcolor={0.19607843137254902, 0.19607843137254902, 0.19607843137254902},
    fselectedcolor={0.7843137254901961, 0.7843137254901961, 0.7843137254901961},
    bgcolor={0.0784313725490196, 0.0784313725490196, 0.0784313725490196},
  }
  list:newprop(tlist)
  list:additem("Aldous-Broder","aldous_broder")
  list:additem("Binary Tree","binary_tree")
  list:additem("Eller's algorithm","eller")
  list:additem("Growing Tree","growing_tree")
  list:additem("Hunt and Kill","hunt_and_kill")
  list:additem("Kruskal's algorithm","kruskal")
  list:additem("Prim's algorithm","prim")
  list:additem("Recursive Backtracker","recursive_backtracker")
  list:additem("Recursive Division","recursive_division")
  list:additem("Sidewinder","sidewinder")
  list:additem("Wilson's algorithm","wilson")
end

function love.draw()
  list:draw()
  love.graphics.setColor({1,1,1})
  Maze.love.tile:draw(batches, 10, 10)
  love.graphics.printf(string.format("took %fms", time), 550, 220, 230 )
end

function love.keypressed(key)
  list:key(key, true)
end

function love.wheelmoved(x, y)
  list:mousew(x, y)
end

function love.update(dt)
  list:update(dt)
  local a = list:getdata(list:getselected())
  if a ~= algo then
    algo = a
    local t = os.clock()
    Maze.generators[algo](maze)
    time = os.clock() - t
    batches = Maze.love.tile:setup(maze, image)
  end
end