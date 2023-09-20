# Overriding an existing state

If you want to handle one of the default states (run, jump, fall, and idle) in your own way you can simply override that existing state. If you want to override most of them I'd suggest using the `BasePlatformer` class and setting up the state machine yourself from scratch.

In this example I'll be overriding the jump with a hover ability.

## Creating the new state
Start by subclassing an existing state, `BaseState` or another one, I'll be extending `AirState`. Then add whatever functionality you want.

```lua
class("HoverState").extends(AirState)

local hover_speed <const> = -30

function HoverState:init(actor)
  HoverState.super.init(self, actor, _image_player_jump[1])
end

function HoverState:update(inputs)
  HoverState.super.update(self, inputs)

  self.actor.dy = hover_speed

  if not inputs.jump then
    self.actor.sm:fall()
  end
end
```


## Overriding the existing state

To override the existing state, simply add the state to your state machine giving it the same name as the state you're overriding.

```lua
-- in Player:init
-- overriding jump state
  self.sm:addState('jump', HoverState(self))
```

That's it, now your new `HoverState` will be used instead of the default `JumpState`.

