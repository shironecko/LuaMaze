-- this is a rectangle-method of drawing a maze

local draw_maze = function(maze, x, y, cell_dim, wall_dim, cell_col, wall_col)
  love.graphics.setColor(wall_col)
  local maze_width = (cell_dim + wall_dim) * maze:width() + wall_dim
  local maze_height = (cell_dim + wall_dim) * maze:height() + wall_dim
  love.graphics.rectangle("fill", x, y, maze_width, maze_height)
  
  love.graphics.setColor(cell_col)
  for yi = 1, maze:height() do
    for xi = 1, maze:width() do
      local pos_x = x + (cell_dim + wall_dim) * (xi - 1) + wall_dim
      local pos_y = y + (cell_dim + wall_dim) * (yi - 1) + wall_dim
      love.graphics.rectangle("fill", pos_x, pos_y, cell_dim, cell_dim)
      
      -- Need to redo this, badly...
      if maze[yi][xi].north:IsOpened() then
        love.graphics.rectangle("fill", pos_x, pos_y - wall_dim, cell_dim, wall_dim)
      end
      if maze[yi][xi].east:IsOpened() then
        love.graphics.rectangle("fill", pos_x + cell_dim, pos_y, wall_dim, cell_dim)
      end
      if maze[yi][xi].south:IsOpened() then
        love.graphics.rectangle("fill", pos_x, pos_y + cell_dim, cell_dim, wall_dim)
      end
      if maze[yi][xi].west:IsOpened() then
        love.graphics.rectangle("fill", pos_x - wall_dim, pos_y, wall_dim, cell_dim)
      end
    end
  end 
end

return draw_maze
