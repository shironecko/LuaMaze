-- this is a tile-method of drawing a maze

local LoveTileMaze = {}

function LoveTileMaze:setup(maze, image)
  -- image is 5 tiles that are composited: N, S, W, E, floor
  local width, height = image:getDimensions()
  local tile_size = width / 5
  local tiles = {
        N = love.graphics.newQuad(tile_size * 0, 0, tile_size, tile_size, width, height),
        S = love.graphics.newQuad(tile_size * 1, 0, tile_size, tile_size, width, height),
        W = love.graphics.newQuad(tile_size * 2, 0, tile_size, tile_size, width, height),
        E = love.graphics.newQuad(tile_size * 3, 0, tile_size, tile_size, width, height),
    floor = love.graphics.newQuad(tile_size * 4, 0, tile_size, tile_size, width, height)
  }
  local batches = {}
  
  for k,v in pairs(tiles) do
    batches[k] = love.graphics.newSpriteBatch(image, maze:height()*maze:width() )
  end
  
  for yi = 1, maze:height() do
    for xi = 1, maze:width() do
      batches.floor:add( tiles.floor, (xi-1) * tile_size, (yi-1) * tile_size)     
      if maze[yi][xi].north:IsClosed() then
        batches.N:add( tiles.N, (xi-1) * tile_size, (yi-1) * tile_size)
      end
      if maze[yi][xi].east:IsClosed() then
        batches.E:add( tiles.E, (xi-1) * tile_size, (yi-1) * tile_size)
      end
      if maze[yi][xi].south:IsClosed() then
        batches.S:add( tiles.S, (xi-1) * tile_size, (yi-1) * tile_size)
      end
      if maze[yi][xi].west:IsClosed() then
        batches.W:add( tiles.W, (xi-1) * tile_size, (yi-1) * tile_size)
      end
    end
  end
  
  return batches
end

function LoveTileMaze:draw(batches, x, y)
  x = x or 0
  y = y or 0
  love.graphics.draw(batches.floor, x, y)
  love.graphics.draw(batches.N, x, y)
  love.graphics.draw(batches.S, x, y)
  love.graphics.draw(batches.W, x, y)
  love.graphics.draw(batches.E, x, y)
end

return LoveTileMaze
