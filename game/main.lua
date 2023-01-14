require("./dslayout")

local top_width = 400
local top_height = 240

local bottom_width = 320
local bottom_height = 240

local image = nil
local image_x = 0
local image_y = 0

function love.load()
   dslayout:init({
         color = { r = 0.2, g = 0.2, b = 0.25, a = 1 },
         title = "Tamago"
   })

   image = love.graphics.newImage("assets/yay.png")
end


function drawTopScreen()
   love.graphics.setColor(255, 255, 255)

   love.graphics.draw(image, image_x, image_y)

   --love.graphics.reset()
end

function drawBottomScreen()
   love.graphics.setColor(255, 255, 255)
end

function love.draw(screen)
   dslayout:draw(
      screen,

      drawTopScreen,

      drawBottomScreen
   )
end

function love.update()
end

-- https://love2d.org/wiki/GamepadButton
function love.gamepadpressed(joystick, button)
   if button == "dpleft" then
      image_x = image_x - 1
   elseif button == "dpright" then
      image_x = image_x + 1
   elseif button == "dpup" then
      image_y = image_y - 1
   elseif button == "dpdown" then
      image_y = image_y + 1
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
