local require = require
_ENV = nil

local namespace = {}
namespace.recursive_backtracker = require "maze.generators.recursive_backtracker"
namespace.aldous_broder = require "maze.generators.aldous_broder"

return namespace