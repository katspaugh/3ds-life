local top_width = 400
local top_height = 240

local bottom_width = 320
local bottom_height = 240

local bottom_x = (top_width - bottom_width) / 2
local bottom_y = top_height
local bottom_canvas = nil

local touchx = -100
local touchy = -100

local scale_x = 1
local image = nil
local sprite_size = 64
local max_sprites = 8
local image_x = 0
local image_y = 1
local next_image_y = 1

-- How many sprites are on each row of the sprite sheet
local sprite_sheet = {
   0,
   8,
   3,
   8,
   3,
   4,
   8,
   4,
   8
}

-- The sprite sheet: a map of names to sprite locations
local sprite_names = {
   standing = 1,
   sit_down = 2,
   sitting = 3,
   stand_up = 4,
   lean_down = 5,
   munching = 6,
   lean_up = 7,
   walking = 8
}

local sprite_count = 0


local item_size = 16
local items = {
   toilet = { x = 1, y = 0, position = 1, selected = false },
   food = { x = 2, y = 4, position = 3, selected = false },
   ball = { x = 1, y = 2, position = 5, selected = false },
   clock = { x = 5, y = 1, position = 7, selected = false },
}

function love.load()
   if love._console_name ~= "3DS" then
      love.window.setMode(400, 480)
      bottom_canvas = love.graphics.newCanvas(bottom_width, bottom_height)
   end

   pet_image = love.graphics.newImage("assets/capibara.png")
   pet_canvas = love.graphics.newCanvas(sprite_size, sprite_size)

   items_image = love.graphics.newImage("assets/items.png")
   item_canvas_1 = love.graphics.newCanvas(item_size, item_size)
   item_canvas_2 = love.graphics.newCanvas(item_size, item_size)
   item_canvas_3 = love.graphics.newCanvas(item_size, item_size)
   item_canvas_4 = love.graphics.newCanvas(item_size, item_size)
end


function drawTopScreen()
   -- scale the canvas 2x around the center
   love.graphics.push()
   love.graphics.translate(-top_width / 2, -top_height / 2)
   love.graphics.scale(2, 2)

   -- draw the sprite canvas
   love.graphics.draw(pet_canvas, top_width / 2, top_height / 2, 0, scale_x, 1, sprite_size / 2, sprite_size / 2)

   love.graphics.pop()

    -- direct drawing operations to the canvas
   love.graphics.setCanvas(pet_canvas)

   love.graphics.clear()

   local scale_offset = 0
   if scale_x < 0 then scale_offset = top_width end

   love.graphics.draw(
      pet_image, -image_x * sprite_size, -image_y * sprite_size, 0, scale_x, 1, scale_offset
   )

   -- re-enable drawing to the main screen
   love.graphics.setCanvas()
end

function getSelectedItem()
   for k, v in pairs(items) do
      if v.selected then
         return v
      end
   end
   return nil
end

function drawBottomScreen()
   if bottom_canvas ~= nil then
      love.graphics.draw(bottom_canvas, bottom_x, bottom_y)
      love.graphics.setCanvas(bottom_canvas)
      love.graphics.clear()
   end

   -- draw background
   love.graphics.setColor(0.5, 0.5, 0.5)
   love.graphics.rectangle("fill", 0, 0, bottom_width, bottom_height)
   love.graphics.setColor(1, 1, 1)

   drawItems(0, 0)

   -- reset the canvas
   love.graphics.setCanvas()
end

function drawItems(x, y)
   -- draw toilet
   love.graphics.draw(item_canvas_1, x + item_size * items.toilet.position, y + item_size)
   love.graphics.setCanvas(item_canvas_1)
   love.graphics.clear()
   love.graphics.draw(items_image, -items.toilet.x * item_size, -items.toilet.y * item_size)
   love.graphics.setCanvas(bottom_canvas)

   -- draw food
   love.graphics.draw(item_canvas_2, x + item_size * items.food.position, y + item_size)
   love.graphics.setCanvas(item_canvas_2)
   love.graphics.clear()
   love.graphics.draw(items_image, -items.food.x * item_size, -items.food.y * item_size)
   love.graphics.setCanvas(bottom_canvas)

   -- draw ball
   love.graphics.draw(item_canvas_3, x + item_size * items.ball.position, y + item_size)
   love.graphics.setCanvas(item_canvas_3)
   love.graphics.clear()
   love.graphics.draw(items_image, -items.ball.x * item_size, -items.ball.y * item_size)
   love.graphics.setCanvas(bottom_canvas)

   -- draw clock
   love.graphics.draw(item_canvas_4, x + item_size * items.clock.position, y + item_size)
   love.graphics.setCanvas(item_canvas_4)
   love.graphics.clear()
   love.graphics.draw(items_image, -items.clock.x * item_size, -items.clock.y * item_size)
   love.graphics.setCanvas(bottom_canvas)

   -- print the touch coordinates
   -- love.graphics.print("Touch: " .. touchx .. ", " .. touchy, 0, 0)

   -- draw a padded rectangle around the selected item
   local selected_item = getSelectedItem()
   if selected_item ~= nil then
      love.graphics.setColor(1, 1, 1)
      love.graphics.rectangle("line", x + item_size * selected_item.position - 2, y + item_size - 2, item_size + 4, item_size + 4)
   end
end

function sitDown()
   sprite_count = 0
   if image_y == sprite_names.sitting then
      image_y = sprite_names.stand_up
      next_image_y = sprite_names.standing
   else
      image_y = sprite_names.sit_down
      next_image_y = sprite_names.sitting
   end
end

function standUp()
   sprite_count = 0
   if image_y == sprite_names.munching then
      image_y = sprite_names.lean_up
      next_image_y = sprite_names.standing
   elseif image_y == sprite_names.sitting then
      image_y = sprite_names.stand_up
      next_image_y = sprite_names.standing
   else
      image_y = sprite_names.standing
      next_image_y = sprite_names.standing
   end
end

function munch()
   if image_y == sprite_names.sitting then
      image_y = sprite_names.stand_up
      next_image_y = sprite_names.munching
   else
      image_y = sprite_names.lean_down
      next_image_y = sprite_names.munching
   end
end

function walk()
   if image_y == sprite_names.sitting then
      image_y = sprite_names.stand_up
      next_image_y = sprite_names.walking
   elseif image_y == sprite_names.munching then
      image_y = sprite_names.lean_up
      next_image_y = sprite_names.walking
   else
      image_y = sprite_names.walking
      next_image_y = sprite_names.walking
   end
end

function touchIntersects(position)
   return touchx >= position * item_size and touchx <= (position + 1) * item_size and
      touchy >= item_size and touchy <= item_size * 2
end

function love.update()
   sprite_count = sprite_count + 0.2
   if sprite_count > max_sprites then
      sprite_count = 0
   end

   local sprites = sprite_sheet[image_y + 1]
   image_x = math.floor(sprite_count)
   if image_x >= sprites then
      image_x = 0
      image_y = next_image_y
   end

   -- detect if touchx and touchy are within the bounds of the toilet
   if touchIntersects(items.toilet.position) then
      if not items.toilet.selected then
         sitDown()
         -- mark all items as not selected
         for k, v in pairs(items) do
            v.selected = false
         end
         items.toilet.selected = true
      end
   end

   -- detect if touchx and touchy are within the bounds of the food
   if touchIntersects(items.food.position) then
      if not items.food.selected then
         munch()
         -- mark all items as not selected
         for k, v in pairs(items) do
            v.selected = false
         end
         items.food.selected = true
      end
   end

   -- detect if touchx and touchy are within the bounds of the ball
   if touchIntersects(items.ball.position) then
      if not items.ball.selected then
         walk()
         -- mark all items as not selected
         for k, v in pairs(items) do
            v.selected = false
         end
         items.ball.selected = true
      end
   end

   -- detect if touchx and touchy are within the bounds of the clock
   if touchIntersects(items.clock.position) then
      if not items.clock.selected then
         standUp()
         -- mark all items as not selected
         for k, v in pairs(items) do
            v.selected = false
         end
         items.clock.selected = true
      end
   end
end

function love.draw(screen)
   if screen ~= "bottom" then
      drawTopScreen()
   end

   if screen == 'bottom' or bottom_canvas ~= nil then
      drawBottomScreen()
   end
end

-- https://love2d.org/wiki/GamepadButton
function love.gamepadpressed(joystick, button)
   sprite_count = 0

   if button == "dpleft" then
      munch()
   elseif button == "dpright" then
      walk()
   elseif button == "dpup" then
      standUp()
   elseif button == "dpdown" then
      sitDown()
   elseif button == 'start' then
      love.event.quit()
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
  touchx = -100
  touchy = -100
end

-- Desktop compatibility

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
