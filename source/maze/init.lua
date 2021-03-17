-- https://github.com/shironecko/LuaMaze

-- these can all be required seperately, but this makes it easier by putting them all together

-- lua doesn't have a built-in way to require a relative file...
local requireRel
if arg and arg[0] then
    package.path = arg[0]:match("(.-)[^\\/]+$") .. "?.lua;" .. package.path
    requireRel = require
elseif ... then
    local d = (...):match("(.-)[^%.]+$")
    function requireRel(module) return require(d .. module) end
end

local maze = requireRel('maze.maze')
maze.generators = {
    recursive_backtracker = requireRel("maze.generators.recursive_backtracker"),
    aldous_broder = requireRel("maze.generators.aldous_broder"),
    binary_tree = requireRel("maze.generators.binary_tree"),
    eller = requireRel("maze.generators.eller"),
    growing_tree = requireRel("maze.generators.growing_tree"),
    hunt_and_kill = requireRel("maze.generators.hunt_and_kill"),
    kruskal = requireRel("maze.generators.kruskal"),
    prim = requireRel("maze.generators.prim"),
    recursive_division = requireRel("maze.generators.recursive_division"),
    sidewinder = requireRel("maze.generators.sidewinder"),
    wilson = requireRel("maze.generators.wilson")
}

maze.love = {
    rect = requireRel("maze.love.rect"),
    tile = requireRel("maze.love.tile")
}

return maze