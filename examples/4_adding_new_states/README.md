# Adding new states

## Creating a new state

Typically we'll start by extending the `BaseState`, this just has some simple logic to handle animating sprites.

```lua
class("DeadState").extends(BaseState)
```

In the `init` function we'll provide the image we want to use as we'll as some options. These are the same as the options passed into the `DefaultPlatformer:init` method.
```lua
function DeadState:init(actor)
  DeadState.super.init(self, actor, _image_player_die, {loop=false})
end
```

The `onenter` method is called whenever we go to this state, there is also `onleave` for whenever we leave this state, and `aftermove` which can be used for additional collision resolutions (have a look at (JumpState)[source/states/jumpState.lua] for an example).
We'll use `onenter` to stop the player moving

```lua
function DeadState:onenter(...)
  DeadState.super.onenter(self, ...)
  self.actor.dx = 0
end
```

## Adding the state to the statemachine

In the `Player:init` method, lets add the new `DeadState`. We'll want to add both the state it's self and the event to allow us to go to that state.
This event will allow us to go from any state except `dead`, to `dead`

```lua
self.sm:addState('dead', DeadState(self))
self.sm:addEvent({name='die', from={'idle', 'run', 'jump', 'fall'}, to='dead'})
```

now lets update our `Player:die` method to use our new state

```lua
function Player:die()
  self.sm:die()
end
```

Now we'll actually die when we hit the snake.

## Adding more events and callbacks

But now we're stuck when we hit the snake, it'd be nice to be able to respawn.
first, lets add a new event to go from the dead state back to the idle state.

```lua
self.sm:addEvent({name='respawn', from='dead', to='idle'})
```

This allows up to return to the idle state after dying, so lets update the `DeadState:update` method.

```lua
function DeadState:update()
  DeadState.super.update(self)
  -- we could use the input handler here but I'll get to that in a later example
  if playdate.buttonJustPressed(playdate.kButtonB) then
    self.actor.sm:respawn()
  end
end
```

Now we respawn but we respawn in the same location and die again. We could fix this by moving the player in the `DeadState:update` method, but another option is to use a callback.
Callbacks are added to the state machine, the follow the nameing convetion `"on<event name>"`, and are called whenever that event is triggered.

```lua
self.sm:addCallback('onrespawn', function(sm) sm:current().actor:moveTo(50,50) end)
```

This is called whenever the `respawn` event happens and will move the player back to the start.


Have a look at [player.lua](examples/4_adding_new_states/player/player.lua) to see how this all works together
