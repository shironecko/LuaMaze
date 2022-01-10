-- this is an example love2d project entry-point

local Maze = require "maze"
local list = require "listbox"

local maze
local algo = "aldous_broder"
local time = 0
local walls
local should_draw_walls

local function draw_walls(root_x, root_y, w)
  local color = {
    [true] = {0.1,0.1,0.1,1},
    [false] = {0.5,0.9,0.9,1},
  }
  -- x,y start at 1 so they'll push us off by one width. Shift back to make the
  -- math easier.
  root_x = root_x - w
  root_y = root_y - w
  for y=1,walls.height do
    for x=1,walls.width do
      local is_wall = walls.walls[x][y]
      love.graphics.setColor(unpack(color[is_wall]))
      local px,py = root_x + x * w, root_y + y * w
      love.graphics.rectangle('fill', px, py, w, w)
    end
  end
end

local function regenerate_maze(a)
  algo = a
  local t = os.clock()
  Maze.generators[algo](maze)
  time = os.clock() - t

  walls = maze:AsTileLayout(true)
end

function love.load()
  love.window.setTitle("LuaMaze")
  math.randomseed(os.time())
  maze = Maze:new(17, 19, true)
  regenerate_maze(algo)

  local tlist = {
    selected=1,
    x=550,
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
  Maze.love.rect(maze, 10, 10, 20, 10, { 0.58, 0.58, 0.78 }, { 0.07, 0.07, 0.39 })
  love.graphics.printf(string.format("took %fms", time), 550, 220, 230 )
  local controls = [[Controls:
q - quit
space - toggle AsTileLayout display
]]
  if should_draw_walls then
    controls = controls .. [[k - RemoveDeadEnds
l - ExpandRooms
]]
    draw_walls(5, 5, 15)
  end
  love.graphics.setColor(1,1,1,1)
  love.graphics.printf(controls, 550, 260, 230)
end

function love.keypressed(key)
  if key == 'q' or key == 'escape' then
    love.event.quit()
  elseif key == 'space' then
    should_draw_walls = not should_draw_walls
  elseif key == 'k' then
    print("RemoveDeadEnds")
    walls:RemoveDeadEnds()
  elseif key == 'l' then
    print("ExpandRooms")
    walls:ExpandRooms()
  else
    list:key(key, true)
  end
end

function love.wheelmoved(x, y)
  list:mousew(x, y)
end

function love.update(dt)
  list:update(dt)
  local a = list:getdata(list:getselected())
  if a ~= algo then
    regenerate_maze(a)
  end
end
