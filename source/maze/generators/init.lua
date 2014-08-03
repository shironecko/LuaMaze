local require = require
_ENV = nil

local namespace = {}
namespace.recursive_backtracker = require "maze.generators.recursive_backtracker"
namespace.aldous_broder = require "maze.generators.aldous_broder"
namespace.binary_tree = require "maze.generators.binary_tree"
namespace.eller = require "maze.generators.eller"
namespace.growing_tree = require "maze.generators.growing_tree"
namespace.hunt_and_kill = require "maze.generators.hunt_and_kill"
namespace.kruskal = require "maze.generators.kruskal"
namespace.prim = require "maze.generators.prim"
namespace.recursive_division = require "maze.generators.recursive_division"

return namespace