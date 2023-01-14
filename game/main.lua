require("dslayout")

local top_width = 400
local top_height = 240

local bottom_width = 320
local bottom_height = 240

local image_x = 0
local image_y = -50
local scale_x = 1
local scale_offset = 0

local touchx = -10
local touchy = -10

local current_image = nil

function love.load()
   dslayout:init({
         color = { r = 0.2, g = 0.2, b = 0.25, a = 1 },
         title = "Tamago"
   })

   image = love.graphics.newImage("assets/yay.png")
   image2 = love.graphics.newImage("assets/yay2.png")
   current_image = image
end


function drawTopScreen()
   love.graphics.draw(current_image, image_x, image_y, 0, scale_x, 1, scale_offset)
end

function drawBottomScreen()
   love.graphics.draw(current_image, image_x - (top_width - bottom_width) / 2, image_y - bottom_height, 0, scale_x, 1, scale_offset)
end

function love.draw(screen)
   dslayout:draw(
      screen,

      drawTopScreen,

      drawBottomScreen
   )
end

function love.update()
   local time = love.timer.getTime()

   if time % 2 < 1 then
      current_image = image
   else
      current_image = image2
   end
end

-- https://love2d.org/wiki/GamepadButton
function love.gamepadpressed(joystick, button)
   if button == "dpleft" then
      scale_x = -1
      scale_offset = top_width
   elseif button == "dpright" then
      scale_x = 1
      scale_offset = 0
   elseif button == "dpup" then
      image_y = image_y - 10
   elseif button == "dpdown" then
      image_y = image_y + 10
   elseif button == 'start' then
      love.event.quit()
   end
end

function love.keypressed(key)
   if key == "left" then
      love.gamepadpressed({}, "dpleft")
   elseif key == "right" then
      love.gamepadpressed({}, "dpright")
   elseif key == "up" then
      love.gamepadpressed({}, "dpup")
   elseif key == "down" then
      love.gamepadpressed({}, "dpdown")
   end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
  touchx = x
  touchy = y
end

function love.mousemoved(x, y, dx, dy, istouch)
  dslayout:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
  dslayout:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
  dslayout:mousereleased(x, y, button, istouch, presses)
end
