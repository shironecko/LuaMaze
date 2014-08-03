LuaMaze
=======

I'm trying to implement all of the maze generation algorithms described at [Think Labyrinth!](http://www.astrolog.org/labyrnth/algrithm.htm) using [Love2D](http://love2d.org/) for visualization.
[Jamis Buck blog](http://weblog.jamisbuck.org/2011/2/7/maze-generation-algorithm-recap) is also very helpful, this is my place to go when algorithm descriptions I find at Think Labyrinth! isn't clear enough for me to implement.

####TODO:####

* [x] Implement all of the perfect maze generation algorithms (found at Think Labyrinth!)
* [ ] Work on the module structure
  * [x] Separate generators definitions across separate files
  * [ ] Clean and optimize generators code
* [ ] Work on Wiki
  * [ ] Quickstart guide
  * [ ] Maze structure description
  * [ ] Algorithms descriptions
* [ ] Improve maze visualization
* [ ] Implement a method for testing a maze for perfection
* [ ] Implement all of the maze solving algorithms (found at Think Labyrinth!)
* [ ] Optional: allow user to watch the maze created step by step by each algorithm

####Algorithms####

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