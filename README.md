LuaMaze
=======

I'm trying to implement all of the maze generation algorithms described at [Think Labyrinth!](http://www.astrolog.org/labyrnth/algrithm.htm) using [Love2D](http://love2d.org/) for visualization.
[Jamis Buck blog](http://weblog.jamisbuck.org/2011/2/7/maze-generation-algorithm-recap) is also very helpful, this is my place to go when algorithm descriptions I find at Think Labyrinth! isn't clear enough for me to implement.

####TODO:####

* [ ] Implement all the perfect maze generation algorithms
* [ ] Separate generators definitions across separate files and clean up their code
* [ ] Work on Wiki
* [ ] Improve maze visualization
* [ ] Optional: make a small mod for the Legend of Grimrock with random maze generation
* [ ] Optional: allow user to watch the maze created step by step by each algorithm
* [ ] Super-optional: make a small game for android about maze solving

####Algorithms####

* Perfect
  * [x] Backtracker
  * [x] Recursive backtracker 
  * [x] Prim's algorithm
  * [x] Kruskal's algorithm
  * [x] Aldous-Broder algorithm
  * [x] Wilson's algorithm
  * [x] Hunt and kill algorithm
  * [x] Growing tree algorithm
  * [x] Eller's algorithm
  * [x] Recursive division
  * [ ] Binary tree Mazes
  * [ ] Sidewinder Mazes
