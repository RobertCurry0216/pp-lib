local pd <const> = playdate
local gfx <const> = playdate.graphics

class("Player").extends(DefaultPlatformer)
local w, h = _image_player_idle[1]:getSize()

local _images <const> = {
  idle = _image_player_idle,
  run = _image_player_run,
  jump = _image_player_jump[1],
  fall = _image_player_jump[2]
}

function Player:init(x, y)
  Player.super.init(self, _images)
  self:moveTo(x, y)
  self:setZIndex(ZIndex.player)
  self:setCollideRect(5, 0, w-10, h)
  self.alive = true

  self.sm:addState('dead', DeadState(self))
  self.sm:addEvent({name='die', from={'idle', 'run', 'jump', 'fall'}, to='dead'})
  self.sm:addEvent({name='respawn', from='dead', to='idle'})
  
  self.sm:addCallback('onrespawn', function(sm) sm:current().actor:moveTo(50,50) end)
end

function Player:die()
  self.sm:die()
end
