local gfx <const> = playdate.graphics

class("Coin").extends(Trigger)

function Coin:init(x, y)
  Coin.super.init(self)
  self.images = AnimatedImage.new(_image_coin, {loop=true, delay=300})

  self:setZIndex(ZIndex.solid)
  self:setImage(self.images:getImage())
  self:moveTo(x, y)
  self:setCollideRect(0,0, self:getSize())
end

function Coin:update()
  Coin.super.update(self)
  self:setImage(self.images:getImage())
end

function Coin:perform(actor, col)
  Coin(math.random(20, 380), math.random(20, 220))
  self:destroy()
end
