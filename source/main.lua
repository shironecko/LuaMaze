-- this is an example love2d project entry-point

local Maze = require "maze"
local list = require "listbox"

local maze
local algo = "aldous_broder"

function love.load()
  love.window.setTitle("LuaMaze")
  math.randomseed(os.time())
  maze = Maze:new(17, 19, true)
  Maze.generators[algo](maze)

  local tlist = {
    selected=1,
    x=550,
    y=10,
    font=love.graphics.newFont(15),
    ismouse=true,
    rounded=true,
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
  Maze.love.rect(maze, 10, 10, 20, 10, { 0.58, 0.58, 0.78 }, { 0.07, 0.07, 0.39 })
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
    Maze.generators[algo](maze)
  end
end