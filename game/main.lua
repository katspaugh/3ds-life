require("setup_screen")

-- Game of life
-- Rules:
-- * Any live cell with fewer than two live neighbours dies, as if by underpopulation.
-- * Any live cell with two or three live neighbours lives on to the next generation.
-- * Any live cell with more than three live neighbours dies, as if by overpopulation.
-- * Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

local cell_size = 5
-- Grid is a flat array of boolean values (true = alive, nil = dead)
-- where the index is the cell's position as x * y.
local grid = {}
local grid_width = 400 / cell_size
local grid_height = 240 / cell_size

local paused = true
local frame = 0
local start_time = 0

local touchx = nil
local touchy = nil

function love.load()
   initScreens()
   initGrid()
   start_time = love.timer.getTime()
end

function love.draw(screen)
   drawScreens(screen)
end

function love.update()
   if not paused then
      if frame == 0 then
         updateGrid()
         frame = 3
      end
      frame = frame - 1
   end

   if touchx ~= nil and touchy ~= nil then
      if not paused then
        paused = true
        grid = {}
      end
      local x = math.floor(touchx / cell_size)
      local y = math.floor(touchy / cell_size)
      local index = x + y * grid_width
      grid[index] = true
   end
end

function initGrid()
   love.math.setRandomSeed(start_time, love.timer.getTime())

   grid = {}
   -- Randomly populate the grid
   for i = 1, grid_width * grid_height do
      if love.math.random() > 0.9 then
         grid[i] = true
      end
   end
end

function countNeighbours(x, y)
   local count = 0
   for i = -1, 1 do
      for j = -1, 1 do
         if i ~= 0 or j ~= 0 then
            local index = (x + i) + (y + j) * grid_width
            if grid[index] then
               count = count + 1
            end
         end
      end
   end
   return count
end

function updateGrid()
   -- Compute the next generation
   local next_grid = {}
   for y = 0, grid_height - 1 do
      for x = 0, grid_width - 1 do
         local index = x + y * grid_width
         local alive = grid[index]
         local neighbours = countNeighbours(x, y)
         if alive then
            if neighbours == 2 or neighbours == 3 then
               next_grid[index] = true
            end
         else
            if neighbours == 3 then
               next_grid[index] = true
            end
         end
      end
   end
   grid = next_grid
end

-- https://love2d.org/wiki/GamepadButton
function love.gamepadpressed(joystick, button)
   if button == "dpleft" then
   elseif button == "dpright" then
   elseif button == "dpup" then
   elseif button == "dpdown" then
   elseif button == 'a' then
     paused = not paused
   elseif button == 'b' then
     initGrid()
   elseif button == 'start' then
      love.event.quit()
   end
end

function drawGrid()
   -- love.graphics.setColor(0.1, 0.1, 0.1)
   -- for x = 0, grid_width do
   --    love.graphics.line(x * cell_size, 0, x * cell_size, grid_height * cell_size)
   -- end
   -- for y = 0, grid_height do
   --    love.graphics.line(0, y * cell_size, grid_width * cell_size, y * cell_size)
   -- end

   -- Draw the cells of the grid
   love.graphics.setColor(1, 1, 1)
   for cell, alive in pairs(grid) do
      if alive then
         local x = (cell % grid_width) * cell_size
         local y = math.floor(cell / grid_width) * cell_size
         love.graphics.rectangle("fill", x, y, cell_size, cell_size)
      end
   end
end

function drawTopScreen(w, h)
   love.graphics.setColor(1, 1, 1)
   drawGrid()
end

function drawBottomScreen(w, h)
   love.graphics.clear()

   if touchx == nil and touchy == nil then
      love.graphics.print("The Game of Life", 10, 60)
      love.graphics.print("Draw something on the screen", 10, 90)
      love.graphics.print("Press A to start or pause", 10, 120)
      love.graphics.print("Press B to reset", 10, 140)
      love.graphics.print("Press Start to exit", 10, 160)
   end

   if paused and touchx ~= nil and touchy ~= nil then
      drawGrid()
   end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
  touchx = x
  touchy = y
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  touchx = x
  touchy = y
end

function love.touchreleased(id, x, y, dx, dy, pressure)
  touchx = nil
  touchy = nil
end
