import "init"

local pd <const> = playdate
local gfx <const> = pd.graphics

deltaTime = 1 / playdate.display.getRefreshRate()

local function init()
	Player(50, 50)

	-- blocks
	for i=1,12,1 do
		Block(8+(i-1)*16, 80)
	end
	for i=1,12,1 do
		Block(392-(i-1)*16, 160)
	end

  -- things
  Coin(math.random(20, 380), math.random(20, 220))
  Snake(200, 240)

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