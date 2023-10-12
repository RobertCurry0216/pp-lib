# Using LDtk with pp-lib

First off I'll say this isn't intended to be an instruction manual for LDtk or PlaydateLDtkImporter. This is just a guide for integrating LDtk with pp-lib.
For using LDtk I recommend this [Youtube video](https://youtu.be/7GbUxjE9rRM?t=185) by Squidgoddev.
For using PlaydateLDtkImporter I recommend reading its documentation on [Github](https://github.com/NicMagnier/PlaydateLDtkImporter).

## Prerequsites

Make sure you have `PlaydateLDtkImporter` imported and a LDtk world saved in your project somewhere.

## Loading a level

First load in your world using LDtk:

```lua
LDtk.load("levels/world.ldtk")
```

Next we'll create a helper function for loadind specific levels.

```lua
function loadLevel(levelName)
	local layers = LDtk.get_layers(levelName)
	for layerName, layer in pairs(layers) do
		if layer.tiles then
			local tilemap = LDtk.create_tilemap(levelName, layerName)

			local layerSprite = gfx.sprite.new()
			layerSprite:setTilemap(tilemap)
			layerSprite:moveTo(0, 0)
			layerSprite:setCenter(0, 0)
			layerSprite:setZIndex(ZIndex.background - 3 + layer.zIndex)
			layerSprite:setUpdatesEnabled(false)
			layerSprite:add()

			Solid.addWallSprites(tilemap, LDtk.get_empty_tileIDs(levelName, "Solid", layerName))

			local passable = Solid.addWallSprites(tilemap, LDtk.get_empty_tileIDs(levelName, "Passthrough", layerName))
			for _, s in ipairs(passable) do
				s.mask = Side.top
			end
		end
	end
end
```

This is all normal LDtk stuff. The one thing I want to focus on is the `Solid.addWallSprites` methods. This works basically the same as `playdate.graphics.sprite.addWallSprites` from the sdk with the exception of, it will return the sprites created. This allows to easily keep working on them. You can see I've done this to set the wall sprites to passthrough.

```lua
local passable = Solid.addWallSprites(tilemap, LDtk.get_empty_tileIDs(levelName, "Passthrough", layerName))
for _, s in ipairs(passable) do
  s.mask = Side.top
end
```

