import "init"

local pd <const> = playdate
local gfx <const> = pd.graphics
LDtk.load("levels/world.ldtk")

deltaTime = 1 / playdate.display.getRefreshRate()

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

local function init()
	-- ldtk
	loadLevel("Level_0")

	Player(200, 50)

	-- walls
	Solid.addEmptyCollisionSprite(0, -10, 400, 11)
	Solid.addEmptyCollisionSprite(0, 240, 400, 10)
	Solid.addEmptyCollisionSprite(-10, 0, 11, 240)
	Solid.addEmptyCollisionSprite(399, 0, 10, 240)
end

local function updateGame()
	pd.timer.updateTimers()
	gfx.sprite.update()
end

init()
pd.setMinimumGCTime(2)

function playdate.update()
	updateGame()
	pd.drawFPS(2,0) -- FPS widget
end