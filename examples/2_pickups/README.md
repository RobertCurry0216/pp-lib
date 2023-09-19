# Pickups

The `Trigger` class is designed to trigger an effect whenever the player touches it. This can be used for hazzards like spikes etc, or in this case pickups.

## Create the Pickup class

extend the `Trigger` class.

```lua
class("Coin").extends(Trigger)
```

The `Trigger` class is ultimatly just an `sprite` so you can use it as you would normally use sprites.
Let's set up the init and update functions with some simple stuff to animate the coin.

```lua
function Coin:init(x, y)
  Coin.super.init(self)
  -- using AnimatedImage to handle the animation
  self.images = AnimatedImage.new(_image_coin, {loop=true, delay=300})

  self:setZIndex(ZIndex.pickups)
  self:setImage(self.images:getImage())
  self:moveTo(x, y)
  self:setCollideRect(0,0, self:getSize())
end

function Coin:update()
  Coin.super.update(self)
  -- update the image
  self:setImage(self.images:getImage())
end
```


## The Trigger

The meat of the `Trigger` class is on the perform function, this is what gets called whenever the player interacts with it.
This will receive the player colliding with it, and the collision object from the sdk, (LINK)[https://sdk.play.date/2.0.3/Inside%20Playdate.html#m-graphics.sprite.moveWithCollisions]

```lua
function Coin:perform(actor, col)
  Coin(math.random(20, 380), math.random(20, 220))
  self:destroy()
end
```

Have a look at [main.lua](examples/2_pickups/main.lua) to see how this all works together
