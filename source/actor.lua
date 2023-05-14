class("Actor").extends(playdate.graphics.sprite)

function Actor:init()
	Actor.super.init(self)
	self:add()
end

function Actor:destroy()
	self:remove()
end