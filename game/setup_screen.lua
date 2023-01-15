local top_width = 400
local top_height = 240

local bottom_width = 320
local bottom_height = 240

local bottom_x = (top_width - bottom_width) / 2
local bottom_y = top_height
local bottom_canvas = nil

function initScreens()
   -- Emulate 3DS on PC
   if love._console_name ~= "3DS" then
      love.window.setMode(400, 480)
      bottom_canvas = love.graphics.newCanvas(bottom_width, bottom_height)
   end
end

function drawScreens(screen)
   -- 3DS screens
   if screen == "bottom" then
      drawBottomScreen(bottom_width, bottom_height)
   else
      drawTopScreen(top_width, top_height)
   end

   if bottom_canvas ~= nil then
      love.graphics.draw(bottom_canvas, bottom_x, bottom_y)
      love.graphics.setCanvas(bottom_canvas)
      drawBottomScreen(bottom_width, bottom_height)
      love.graphics.setCanvas()
   end
end

-- Emulate gamepad with keyboard
function love.keypressed(key)
   if key == "left" then
      love.gamepadpressed({}, "dpleft")
   elseif key == "right" then
      love.gamepadpressed({}, "dpright")
   elseif key == "up" then
      love.gamepadpressed({}, "dpup")
   elseif key == "down" then
      love.gamepadpressed({}, "dpdown")
   elseif key == "escape" then
      love.gamepadpressed({}, "start")
   else
      love.gamepadpressed({}, key)
   end
end

-- Emulate touchscreen with mouse
local isPressed = false

function love.mousemoved(x, y, dx, dy, istouch)
   if isPressed then
      love.touchmoved(1, x - bottom_x, y - bottom_y, dx, dy, 1)
   end
end

function love.mousepressed(x, y, button, istouch, presses)
   isPressed = true
   love.touchpressed(1, x - bottom_x, y - bottom_y, 1, 1, 1)
end

function love.mousereleased(x, y, button, istouch, presses)
   isPressed = false
   love.touchreleased(1, x - bottom_x, y - bottom_y, 1, 1, 1)
end

