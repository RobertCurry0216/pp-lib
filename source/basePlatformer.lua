class("BasePlatformer").extends(Actor)

local deltaTime <const> = 1 / playdate.display.getRefreshRate()

function BasePlatformer:init()
  BasePlatformer.super.init(self)
  
  self:setCollideRect(0,0, 32, 32)
  self:setGroups({Group.actor})
  self:setCollidesWithGroups({
    Group.solid, Group.trigger
  })

  -- state machine
  self.sm = Machine()

  -- input handler
  self.inputs = InputHandler()

  -- init state
  self._image_flip = playdate.graphics.kImageUnflipped
  self._acc = 0
  self._jump_count = 0
  self.dx = 0
  self.dy = 0
  self.buttons = {}
  
end

function BasePlatformer:update()
  self.inputs:update(self.buttons, self)
  self.sm:current():update(self.inputs)
  self:move()
  self:updateImageFlip()
end

function BasePlatformer:updateImageFlip()
  -- set image flip
  if self.inputs.dx < 0 then
    self._image_flip = playdate.graphics.kImageFlippedX
  elseif self.inputs.dx > 0 then
    self._image_flip = playdate.graphics.kImageUnflipped
  end
  self:setImageFlip(self._image_flip)
end

function BasePlatformer:collisionResponse(other)
  if other:isa(Solid) and other:isSolid() then
    return playdate.graphics.sprite.kCollisionTypeSlide
  else
    return playdate.graphics.sprite.kCollisionTypeOverlap
  end
end

function BasePlatformer:move()
  local tx = self.x+(self.dx * deltaTime)
  local ty = self.y+(self.dy * deltaTime)
  local ax, ay, cols, l = self:moveWithCollisions(tx, ty)
  table.each(cols, function(c)
    if c.other:isa(Solid) and c.other:stops(self, c) then
      c.other:resolveCollision(self, c)
    elseif c.other:isa(Trigger) then
      c.other:perform(self, c)
    end
  end)
  self.sm:current():aftermove(cols, l, tx, ty)
  self:aftermove(cols, l, tx, ty)
end

function BasePlatformer:aftermove(cols, l, tx, ty) end
