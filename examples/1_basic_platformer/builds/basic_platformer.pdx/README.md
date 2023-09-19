# BASIC PLATFORMER

## Creating the player

The simplest way to create a new platformer is to extend the `DefaultPlatformer` class

```lua
class("Player").extends(DefaultPlatformer)
```

Then in the init function set the images for each of the default states (idle, run, jump, fall). For each state you may provide either an `image`, `imagetable`, or an `AnimatedImage`.
Also remember to set the collide rect too.

```lua
local w, h = _image_player_idle[1]:getSize()

local _images <const> = {
  idle = _image_player_idle, -- imagetable
  run = _image_player_run, -- imagetable
  jump = _image_player_jump[1], -- image
  fall = _image_player_jump[2] -- image
}

function Player:init(x, y)
  Player.super.init(self, _images)
  self:moveTo(x, y) -- setting the initial position
  self:setZIndex(ZIndex.player)
  self:setCollideRect(5, 0, w-10, h) -- set the collide rect
end
```

This will give you a platformer character with sensible defaults for movement speed and jump height etc.
These can (and should) be over-ridden to give your character it's own unique feel.

```lua
function Player:init(x, y)
  Player.super.init(self, _images)
  self:moveTo(x, y) -- setting the initial position
  self:setZIndex(ZIndex.player)
  self:setCollideRect(5, 0, w-10, h) -- set the collide rect

  -- overrides
  self.jump_count_max = 2 -- double jump
  self.jump_boost = 300 -- affects jump height
end

```