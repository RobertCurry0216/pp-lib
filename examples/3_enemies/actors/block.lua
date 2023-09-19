local gfx <const> = playdate.graphics

class("Block").extends(Solid)

function Block:init(x, y)
  Block.super.init(self)

  self:setZIndex(ZIndex.solid)
  self:setImage(_image_block)
  self:moveTo(x, y)
  self:setCollideRect(0,0, self:getSize())
end