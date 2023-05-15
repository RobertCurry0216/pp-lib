local gfx <const> = playdate.graphics

class("Snake").extends(Trigger)

function Snake:init(x, y)
  Snake.super.init(self)
  self.images = AnimatedImage.new(_image_snake, {loop=true, delay=200})

  self:setZIndex(ZIndex.enemy)
  self:setImage(self.images:getImage())
  self:setCenter(0.5, 1)
  self:moveTo(x, y)
  self:setCollideRect(0,0, self:getSize())
  self:setCollidesWithGroups({Group.solid})

  self.speed = 20 * deltaTime
  self.img_flip = gfx.kImageFlippedX
end

function Snake:update()
  Snake.super.update(self)
  self:setImage(self.images:getImage())
  self:setImageFlip(self.img_flip)

  local ax, ay, cols, l = self:moveWithCollisions(self.x + self.speed, self.y)
  for _, col in ipairs(cols) do
    if col.other:isa(Solid) then
      self.speed *= -1
      if self.speed < 0 then
        self.img_flip = gfx.kImageUnflipped
      else
        self.img_flip = gfx.kImageFlippedX
      end
      break
    end
  end
end

function Snake:perform(actor, col)
  actor:die()
end
