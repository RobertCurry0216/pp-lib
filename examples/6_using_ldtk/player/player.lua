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
  self:moveTo(x, y) -- setting the initial position
  self:setZIndex(ZIndex.player)
  self:setCollideRect(5, 0, w-10, h) -- set the collide rect

  self.buttons.jump = "up"

  self.jump_count_max = 2 -- double jump
  self.jump_boost = 300 -- affects jump height
end
