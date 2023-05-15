# pp-lib

The Playdate-Platformer Library is a library to make creating a platformer game for the playdate easy, while including all the things that make jumping feel good.

# Quick start

# Adding new states

# API

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
Adds the player to the `actor` group, and sets collidesWithGroups to `{solid, trigger}`

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

### `BasePlatformer:aftermove([collisions], [no of collisions], [target x], [target y])`

called after all movement resolutions are done
override if you want to do something here

---

## InputHandler

---

## State

---

## Machine

---

## Actor

---

## Solid

---

## Trigger

---

## BaseState

---

## GroundState

---

## AirState

---

## IdleState

---

## RunState

---

## JumpState

---

## FallState

---

## AnimatedImage
