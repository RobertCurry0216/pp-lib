# Enemies

While you might want to use the `BasePlatformer` class, I'd recommend against it unless you have some very specific need for it. The `BasePlatformer` and `DefaultPlatformer` have a lot of logic and weight that isn't necessary for simple enemies and hazzards. Instead we'll just be using the `Trigger` class again. Rules for how triggers move isn't set anywhere in the pp-lib, so you simply handle it the way you would in any other game.

## Create the Enemy class

Again we'll extend the `Trigger`

```lua
class("Snake").extends(Trigger)
```

We'll add some simple logic to move the snake back and forth and to animate it using `AnimatedImage`

```lua
function Snake:init(x, y)
  Snake.super.init(self)
  self.images = AnimatedImage.new(_image_snake, {loop=true, delay=200})

  self:setZIndex(ZIndex.enemy)
  self:setImage(self.images:getImage())
  self:setCenter(0.5, 1)
  self:moveTo(x, y)
  self:setCollideRect(0,0, self:getSize())
  self:setCollidesWithGroups({Group.solid}) -- this sets it to collide with the walls

  -- some basic properties
  self.speed = 20 * deltaTime
  self.img_flip = gfx.kImageFlippedX
end

function Snake:update()
  Snake.super.update(self)

  -- update image
  self:setImage(self.images:getImage())
  self:setImageFlip(self.img_flip)

  -- move the snake
  local ax, ay, cols, l = self:moveWithCollisions(self.x + self.speed, self.y)

  -- flip it around when it hits a wall
  for _, col in ipairs(cols) do
    if col.other:isa(Solid) then
      self.speed *= -1
      if self.speed < 0 then
        self.img_flip = gfx.kImageUnflipped
      else
        self.img_flip = gfx.kImageFlippedX
      end
      break
    end
  end
end
```

## The Trigger

Now we add the `perform` method to the snake, here we have access to the actor colliding with it so you are free to update any properties or call any methods on it.
I usually add a `hurt` or a `die` method to my player class that I call in the perform methods but feel free to do what works for you.

```lua
-- in the Snake class
function Snake:perform(actor, col)
  actor:die()
end
```

```lua
-- in the Player class
function Player:die()
  -- todo: impliment dying
  print("ouch")
  self:destroy()
end
```

Have a look at [main.lua](examples/3_enemies/main.lua) to see how this all works together
