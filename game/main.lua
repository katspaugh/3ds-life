require("setup_screen")

-- Game of life
-- Rules:
-- * Any live cell with fewer than two live neighbours dies, as if by underpopulation.
-- * Any live cell with two or three live neighbours lives on to the next generation.
-- * Any live cell with more than three live neighbours dies, as if by overpopulation.
-- * Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

local screen_width = 400
local screen_height = 240

-- Grid is a flat array of boolean values (true = alive, nil = dead)
-- where the index is the cell's position as x * y.
local grid = {}
local grid_width = 100
local grid_height = 60

local min_zoom = screen_width / grid_width
local zoom = min_zoom
local pan_x = 0
local pan_y = 0

local paused = false
local frame = 0
local start_time = 0

local frame_rate = 3
if love._console_name ~= "3DS" then
   frame_rate = 1
end

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
         frame = frame_rate
      end
      frame = frame - 1
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

function updateGrid()
   -- Compute the next generation with periodic boundary conditions
   local next_grid = {}
   for y = 1, grid_height do
      for x = 1, grid_width do
         local neighbors = 0
         for dy = -1, 1 do
            for dx = -1, 1 do
               if dx ~= 0 or dy ~= 0 then
                  local neighbor_x = (x + dx - 1) % grid_width + 1
                  local neighbor_y = (y + dy - 1) % grid_height + 1
                  local neighbor_index = neighbor_x + (neighbor_y - 1) * grid_width
                  if grid[neighbor_index] then
                     neighbors = neighbors + 1
                  end
               end
            end
         end

         local index = x + (y - 1) * grid_width
         if grid[index] then
            if neighbors == 2 or neighbors == 3 then
               next_grid[index] = true
            end
         else
            if neighbors == 3 then
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
      pan_x = pan_x - zoom
   elseif button == "dpright" then
      pan_x = pan_x + zoom
   elseif button == "dpup" then
      pan_y = pan_y - zoom
   elseif button == "dpdown" then
      pan_y = pan_y + zoom
   elseif button == "dpup" then
      zoom = zoom + 0.5
   elseif button == "dpdown" then
      if zoom > 1 then
         zoom = zoom - 0.5
      end
   elseif button == 'a' then
     paused = not paused
   elseif button == 'b' then
     initGrid()
   elseif button == "x" then
      zoom = zoom + 0.5
   elseif button == "y" then
      if zoom > min_zoom then
         zoom = zoom - 0.5
      end
   elseif button == 'start' then
      love.event.quit()
   end
end

function drawGrid()
   -- Draw the cells of the grid according to the current zoom level around the center of the grid
   -- Take the zoomed pan into account
   local x_min = math.max(1, math.floor(-pan_x / zoom))
   local x_max = math.min(grid_width, math.floor((screen_width - pan_x) / zoom))
   local y_min = math.max(1, math.floor(-pan_y / zoom))
   local y_max = math.min(grid_height, math.floor((screen_height - pan_y) / zoom))
   local cell_size = math.max(1, math.floor(zoom + 0.5))
   for y = y_min, y_max do
      for x = x_min, x_max do
         local index = x + (y - 1) * grid_width
         if grid[index] then
            love.graphics.rectangle("fill", (x - 1) * zoom + pan_x, (y - 1) * zoom + pan_y, cell_size, cell_size)
         end
      end
   end
end

function drawTopScreen(w, h)
   drawGrid()
end

function drawBottomScreen(w, h)
   love.graphics.clear()

   love.graphics.print("The Game of Life", 10, 60)
   love.graphics.print("Press X/Y to zoom", 10, 120)
   love.graphics.print("Press the dpad to pan", 10, 140)
   love.graphics.print("Press Start to exit", 10, 160)
end
