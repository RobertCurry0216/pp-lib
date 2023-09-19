local gfx <const> = playdate.graphics

-- playdate libs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- utilities
import "lib/enum"
import "lib/pp-lib"

-- assets
_image_player_idle = gfx.imagetable.new("images/idle")
_image_player_run = gfx.imagetable.new("images/run")
_image_player_jump = gfx.imagetable.new("images/jump")

_image_block = gfx.image.new("images/block")
_image_coin = gfx.imagetable.new("images/coin")
_image_snake = gfx.imagetable.new("images/snake")

-- actors
import "actors/block"
import "actors/coin"
import "actors/snake"

-- player
import "player/player"

-- globals
ZIndex = enum({
  "solid",
  "pickups",
  "enemy",
  "player",
})
