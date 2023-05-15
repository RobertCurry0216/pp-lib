class("BaseState").extends(State)

function BaseState:init(actor, images, options)
  self.actor = actor
  options = options or {loop=true}
  if images then
    if getmetatable(images) == playdate.graphics.imagetable then
      self.images = AnimatedImage.new(images, options)
      actor:setImage(self.images:getImage())
    elseif getmetatable(images) == playdate.graphics.image then
      self.image = images
      actor:setImage(self.image)
    else
      self.images = images
      actor:setImage(self.images:getImage())
    end
  end
end

function BaseState:onenter(sm, name, from, to)
  if self.images then
    self.images:reset()
  elseif self.image then
    self.actor:setImage(self.image)
  end
end

function BaseState:aftermove(cols, l, tx, ty) end

function BaseState:update()
  if self.images then
    self.actor:setImage(self.images:getImage())
  end
end