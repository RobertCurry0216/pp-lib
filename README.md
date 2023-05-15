# pp-lib

The Playdate-Platformer Library is a library to make creating a platformer game for the playdate easy, while including all the things that make jumping feel good.

# Quick start

# Adding new states

# API

---

## Actor

extends `playdate.graphics.sprite`

a very thin wrapper around `playdate.graphics.sprite`, mostly because I prefer calling things 'actors' insted of 'sprites' 🤷

### `Actor:init()`

also calls `self:add()`

### `Actor:destroy()`

calls `self:remove()`

---

## Solid

extends `Actor`

extend this class to create blocks/platforms that you want you player to be able to stand on.

### `Solid:init()`

sets its group to `{Group.solid}`

### `Solid:setSidePassthrough(side, passable)`

- `side`: `Side.top`, `Side.bottom`, `Side.left`, or `Side.right`. bitwise or can be used to set multiple sides at once `Side.left | Side.right`
- `passable`: boolean, if the player is able to passthrough coming from that direction.
  you may also set the mask directly, `solid.mask = Side.top`, this has the effect of setting all sides except that one being passable.

### `Solid.addEmptyCollisionSprite(x, y, w, h)`

utility function to add an invisible solid to the game

---

## Trigger

extends `Actor`

a catch all class for everything that interacts with the player but doesn't stop them, eg: pickups, coins, spikes, enemies, etc.

### `Trigger:init()`

sets its group to `{Group.trigger}`

### `Trigger:perform(actor, col)`

to be overridden, is called when this object overlaps with the player

- `actor`: the player actor
- `col`: the [collision object](https://sdk.play.date/1.13.7/#m-graphics.sprite.moveWithCollisions)

---

## DefaultPlatformer

extends `BasePlatformer`
A good starting place for most platformers, sets up sensible defaults for all values and sets up the state machine.
Sub class this class to create your platformer character.

### `DefaultPlatformer:init(images, options)`

- `images`:`{idle=[image or imagetable], run=[image or imagetable], jump=[image or imagetable], fall=[image or imagetable]}`. The images to be used for each of the different states, under the hood it uses [AnimatedImage](https://github.com/mierau/playdate-animatedimage).
- `options`:`{idle=[AnimatedImage options], run=[AnimatedImage options], jump=[AnimatedImage options], fall=[AnimatedImage options]}`
  - options for each of the different images, as per [AnimatedImage](https://github.com/mierau/playdate-animatedimage)
    - `delay`: time in milliseconds to wait before moving to next frame. (default: 100ms)
    - `paused`: start in a paused state. (default: false)
    - `loop`: loop the animation. (default: false)
    - `step`: number of frames to step. (default: 1)
    - `sequence`: an array of frame numbers in order to be used in the animation e.g. `{1, 1, 3, 5, 2}`. (default: all of the frames from the specified image table)

initalises the state machine like this:

```
self.sm:addState("idle", IdleState(self, images.idle, options.idle))
self.sm:addState("run", RunState(self, images.run, options.run))
self.sm:addState("jump", JumpState(self, images.jump, options.jump))
self.sm:addState("fall", FallState(self, images.fall, options.fall))

self.sm:addEvent({name='run', from='*', to='run'})
self.sm:addEvent({name='stop', from='run', to='idle'})
self.sm:addEvent({name='jump', from='*', to='jump'})
self.sm:addEvent({name='fall', from='*', to='fall'})
self.sm:addEvent({name='land', from='fall', to=defaultLandEvent})

self.sm:addCallback('onland', defaultOnLandCallback)
self.sm:addCallback('onbeforefall', defaultOnBeforeFallCallback)
self.sm:addCallback('onbeforejump', defaultOnBeforeJumpCallback)
```

### `DefaultPlatformer.buttons`

buttons is a table containing the key to be used to control the player

- `left`: button to move left
  - default `playdate.kButtonLeft`
- `right`: button to move right
  - default `playdate.kButtonRight`
- `jump`: button to jump
  - default `playdate.kButtonA`

### `DefaultPlatformer.has_air_control`

- determins if player can be controlled while in the air
- default `true`

### `DefaultPlatformer.has_ground_control`

- determins if player can be controlled while on the ground
- default `true`

### `DefaultPlatformer.run_speed_max`

- maximum ground speed, in px/s
- default `200`

### `DefaultPlatformer.run_speed_acc`

- acceleration speed when the player starts moving while on the ground, in px/s
- default `20`

### `DefaultPlatformer.run_speed_dcc`

- deceleration speed when the player stops moving while on the ground
- default `40`

### `DefaultPlatformer.air_speed_max`

- maximum horizontal air speed, in px/s
- default `200`

### `DefaultPlatformer.air_speed_acc`

- horizontal acceleration speed when the player starts moving while on the air, in px/s
- default `20`

### `DefaultPlatformer.air_speed_dcc`

- horizontal deceleration speed when the player stops moving while on the air, in px/s
- default `4`

### `DefaultPlatformer.jump_boost`

- initial vertical speed when the player jumps, in px/s
- default `400`

### `DefaultPlatformer.jump_dcc`

- the gravity applied while the player is jumping, in px/s
- default `20`

### `DefaultPlatformer.jump_max_time`

- the maximum time the player can be accending, in ms
- if, due to `jump_scc`, the players vertical speed reaches 0 before this time, they will enter the fall state before this time
- default `300`

### `DefaultPlatformer.jump_min_time`

- the minimum time the player can be accending, in ms
- default `120`

### `DefaultPlatformer.jump_count_max`

- how many times the player can jump without touching the groud
- default `1`

### `DefaultPlatformer.jump_buffer_time`

- how long should buffered jump inputs be remembered, in ms
- if the player hits jump slightly before hitting the ground this will allow the to still jump
- default `300`

### `DefaultPlatformer.apex_boost`

- a small vertical boost when the player goes from the `JumpState` into the `FallState` to smooth out the arc, in px/s
- default `10`

### `DefaultPlatformer.bump_max`

- if the player hits the edge of a block while jumping, this allows them to be pushed aside and continue the jump
- the maxium distand the player can be bumped, in px
- default `6`

### `DefaultPlatformer.fall_acc`

- the gravity applied when the player is falling, in px/s
- default `30`

### `DefaultPlatformer.fall_hang_acc`

- a reduced gravity applied at the apex of a jump to allow for more precision platforming, in px/s
- default `20`

### `DefaultPlatformer.fall_hang_time`

- the time the reduced gravity is applied for, is ms
- default `100`

### `DefaultPlatformer.fall_max`

- the maximum fall speed, in px/s
- default `400`

### `DefaultPlatformer.coyote_time`

- the amount of time after the player walks off a platform where the jump button will still work, in ms
- default `120`

---

## BasePlatformer

extends `Actor`

A bare bone starting point for a platformer. Initalises the statemachine but does not add any states or events.
Does not initalise any parameters.
Sub class this class to create your platformer character.

### `BasePlatformer.sm`

the players state machine

### `BasePlatformer.inputs`

the players input handler

### `BasePlatformer:init()`

Initalises the statemachine but does not add any states or events.
Does not initalise any parameters.
Adds the player to the `{Group.actor}` group, and sets collidesWithGroups to `{Group.solid, Group.trigger}`

### `BasePlatformer:update()`

performs the following thins in order:

1. calls `update` on the input handler
2. calls `update` on the current state
3. calls `move` on self
4. calls `updateImageFlip` on self

### `BasePlatformer:collisionResponse()`

returns `kCollisionTypeSlide` if othe is fully solid, otherwise returns `kCollisionTypeOverlap`

### `BasePlatformer:move()`

performs the following thins in order:

1. moves the player with collisions
2. calls `resolveCollision` on all `Solid`s collided with
3. calls `perform` on all `Trigger`s collided with
4. calls `aftermove` on the current state
5. calls `aftermove` on self

### `BasePlatformer:aftermove(cols, l, tx, ty)`

- `cols`: [collision objects](https://sdk.play.date/1.13.7/#m-graphics.sprite.moveWithCollisions)
- `l`: number of collisions
- `tx`: target x
- `ty`: target y

called after all movement resolutions are done
override if you want to do something here

---

## InputHandler

all input management is handled her to create a seperation of concerns and to make changing the controll scheme easy

### `InputHandler:update(buttons, actor)`

must set the following parametes

- `dx`: the horozontal direction, a number between -1 and 1 (usually -1, 0, or 1)
- `jump`: boolean, jump button held down
- `jump_pressed`: boolean, jump button just pressed
- `jump_buffered`: boolean, jump button pressed with in the last n ms (the `jump_buffer_time` set on the actor)

---

## Machine

the state machine based on [this one](https://github.com/kyleconroy/lua-state-machine) without the async transitions and some extra utility added.

### `Machine:addState(name, state)`

adds a state to the state machine, if it is the first state added, will also set it as the initial state

### `Machine:addEvent(event)`

event is a table with the values:

- `name`: the name of the event, a method will be added to the state maching allowing you to trigger this event. Additional arguments will be passed to the `onenter` method of the state. eg: `sm:run()`
- `from`: either a string or a list of strings, the states this event can be triggered from. If this event is triggered while the current state isn't part of this list, nothing happens. `'*'` may be used to allow the event from all states.
- `to`: either a string, the name of the state to enter, or a function that returns the name of the state to enter. The function is passed the args `{[Machine], [event name], [from]}`

### `addCallback([name], [callback])`

adds a callback function to be on or before a given event

- `name`: either `'on'..[event name]`, `'onbefore'..[event name]`, or `'onstatechange'`
- `callback`: function to be called, args passed `{ [Machine], name, from, to, ...}`

### `Machine:current()`

returns the current state object

### `Machine:get([name])`

returns the state object of that name

---

## State

the empty state class

---

## BaseState

extends `State`

extend from this class to create new states for your platformer. Handles updating the spite image.

### `BaseState:init(actor, images, options)`

- `actor`: a `BasePlatformer`
- `images`: either a image or an imagetable
- `options`: `AnimatedImage` options

### `BaseState:onenter(sm, name, from, to)`

- `sm`: the state `Machine`
- `name`: the event name string
- `from`: the class name string of the state coming from
- `to`: the class name string of the state going to

### `BaseState:aftermove(cols, l, tx, ty)`

- `cols`: [collision objects](https://sdk.play.date/1.13.7/#m-graphics.sprite.moveWithCollisions)
- `l`: number of collisions
- `tx`: target x
- `ty`: target y

### `BaseState:update()`

called every frame when this is the current state

---

## GroundState

extends `BaseState`

handles jumping and checking if the player should fall

---

## AirState

extends `BaseState`

handles horizontal movement while in the air

---

## IdleState

extends `GroundState`

handles deceleration when the player stops, otherwise just sits there

---

## RunState

extends `GroundState`

handles horozontal movement while on the ground

---

## JumpState

extends `AirState`

handles the vertical movement while in the accending portion of a jump, also handles the edge bumping behaviour

---

## FallState

extends `AirState`

handles the vertical movement while in the decending portion of a jump, also handles the coyote time when running of a solid

---

## AnimatedImage

this library uses a slightly modified version of [AnimatedImage](https://github.com/mierau/playdate-animatedimage)
