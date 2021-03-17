#!/usr/bin/env luajit

-- This is a CLI-example of generating mazes
-- run with luajit

-- lua doesn't have a built-in way to require a rtelative file...
local requireRel
if arg and arg[0] then
    package.path = arg[0]:match("(.-)[^\\/]+$") .. "?.lua;" .. package.path
    requireRel = require
elseif ... then
    local d = (...):match("(.-)[^%.]+$")
    function requireRel(module) return require(d .. module) end
end

-- get CLI args
local width = arg[1] or 10
local height = arg[2] or 10
local algo = arg[3] or "recursive_backtracker"

-- this loads the whole thing, but you could load just the generator you want
-- and maze with maze.maze and maze.generators.ALGO
local Maze = requireRel('maze.init')

local maze = Maze:new(width, height, true)

-- maek sure random is more random
math.randomseed(os.time())

-- call the selected generator on the maze
Maze.generators[algo](maze)

-- this uses maze.tostring() to print
print(maze)
