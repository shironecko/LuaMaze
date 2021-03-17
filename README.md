LuaMaze
=======

Initial mission was to implement all of the maze generation algorithms described at [Think Labyrinth!](http://www.astrolog.org/labyrnth/algrithm.htm) using [Love2D](http://love2d.org/) for visualization and [Löve Frames](http://nikolairesokav.com/projects/loveframes) as a GUI library.
Having done that, I'm concentraiting on cleaning up the code and adding tests as well as more impressive visualization before moving on to more advanced algorithms.

### TODO:

* [x] Implement all of the perfect maze generation algorithms (found at Think Labyrinth!)
* [ ] Work on the module structure
  * [x] Separate generators definitions across separate files
  * [ ] Clean and optimize generators code
* [ ] Work on Wiki
  * [ ] Quickstart guide
  * [ ] Maze structure description
  * [ ] Algorithms descriptions
* [ ] Improve maze visualization
  * [x] Integrate LoveFrames and make a basic interface
  * [ ] Extend interface with algorithm descriptions
  * [ ] Add algorithm benchmarking
* [ ] Implement a method for testing a maze for perfection
* [ ] Implement all of the maze solving algorithms (found at Think Labyrinth!)
* [ ] Optional: allow user to watch the maze created step by step by each algorithm

### Algorithms

* Generating (perfect mazes)
  * [x] Recursive backtracker 
  * [x] Prim's algorithm
  * [x] Kruskal's algorithm
  * [x] Aldous-Broder algorithm
  * [x] Wilson's algorithm
  * [x] Hunt and kill algorithm
  * [x] Growing tree algorithm
  * [x] Eller's algorithm
  * [x] Recursive division
  * [x] Binary tree Mazes
  * [x] Sidewinder Mazes

### Usage

There are a few ways to use this lib in your own project. Copy [source/maze](source/maze) into your project's path to use this library.

#### CLI

You can use [source/cli.lua](source/cli.lua) as a CLI example. It's meant to be run in luajit or similar lua-runtime:

```
luajit source/cli.lua <width> <height> <algo>
```

Here is an example:

```
luajit source/cli.lua 20 10 sidewinder

#########################################
# #   #   # # #   #   #   #   #   #   # #
# ### # ### # ### # ### ### ##### ### # #
# # #   #     #   # #   #     # # # #   #
# # ### # ##### ### # ##### ### # # ### #
# # #   # #     #     #   # # #   #     #
# # # ### ### ### ##### ### # # ##### ###
# # # # # # #     #     # #   #   #     #
# # # # # # ### ##### ### ### ### ### ###
# #   # #   # #     #           #   # # #
# # ### ### # ##### ######### ### ### # #
# #   # #     # # #   # #   # # # #     #
# ### # ### ### # # ### ### # # # ##### #
# #     #   #     #   #     # # #     # #
# # ####### # ##### ##### ### # # ##### #
# #   # #   #   #       # # # # #       #
# # ### ### ### ### ##### # # # # #######
# # # #   #   #     # #   #   # #     # #
# # # # ##### ### ### ### ### # ### ### #
#                                       #
#########################################
```

#### Love2d

There are 2 output helpers for love. One is [source/maze/love/rect.lua](source/maze/love/rect.lua) for using rectangle shape-primitive, and the other is [source/maze/love/tile.lua](source/maze/love/tile.lua) for using images.

[source/](source) is an example love2d project that uses rects & frames lib for it's UI. See [source/main.lua](source/main.lua) to see how it works.

To test it, do `git clone --recursive git@github.com:shironecko/LuaMaze.git` then `love source`.


### Sources of knowledge and inspiration

* [Think Labyrinth!](http://www.astrolog.org/labyrnth/algrithm.htm) - place containing invaluable knowledge for everyone interested in labyrinths and their random generation.
* [Jamis Buck blog](http://weblog.jamisbuck.org/2011/2/7/maze-generation-algorithm-recap) - this was my place to go when algorithm descriptions I found at Think Labyrinth! wasn't clear enough for me to implement.
* [CS50x](https://www.edx.org/node/1022) on [edx.org](https://www.edx.org) - I've decided to make this module as a final project ot this course. It's also great :)
