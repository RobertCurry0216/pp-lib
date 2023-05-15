-- source/animatedImage.lua--------------------------------------------------
import "CoreLibs/animation"

local graphics <const> = playdate.graphics
local animation <const> = playdate.graphics.animation

AnimatedImage = {}

-- image_table_path should be a path to an image table.
-- options is a table of initial settings:
--   sequence:  table of frames to be used in the animation, e.g. {4, 3, 2, 1}
--   delay:     the amount of time to delay (in milliseconds) before moving to the next frame.
--   paused:    start in a paused state (boolean)
--   loop:      loop the animation (boolean)
--   first:     tindex of the first frame in the animation (default = 1)
--   last:      index of the last frame in the animation (default = length of animation)

function AnimatedImage.new(image_table_path, options)
	options = options or {}

	local image_table
	if type(image_table_path) == "string" then
		image_table = graphics.imagetable.new(image_table_path)
	elseif getmetatable(image_table_path) == graphics.imagetable then
		image_table = image_table_path
	end

	if image_table == nil then
		print("ANIMATEDIMAGE: FAILED TO LOAD IMAGE TABLE AT", image_table_path)
		return nil
	end

	if options.sequence ~= nil then
		local temp_imagetable = graphics.imagetable.new(#options.sequence)
		for i, v in ipairs(options.sequence) do
			temp_imagetable:setImage(i, image_table:getImage(v))
		end
		image_table = temp_imagetable
	end

	local animation_loop = animation.loop.new(options.delay or 100, image_table, options.loop and true or false)
	animation_loop.paused = options.paused and true or false
	animation_loop.startFrame = options.first or 1
	animation_loop.endFrame = options.last or image_table:getLength()

	local animated_image = {}
	setmetatable(animated_image, AnimatedImage)
	animated_image.image_table = image_table
	animated_image.loop = animation_loop

	return animated_image
end

function AnimatedImage:reset()
	self.loop.frame = self.loop.startFrame
end

function AnimatedImage:setDelay(delay)
	self.loop.delay = delay
end

function AnimatedImage:getDelay()
	return self.loop.delay
end

function AnimatedImage:setShouldLoop(should_loop)
	self.loop.shouldLoop = should_loop
end

function AnimatedImage:getShouldLoop()
	return self.loop.shouldLoop
end

function AnimatedImage:setPaused(paused)
	self.loop.paused = paused
end

function AnimatedImage:getPaused()
	return self.loop.paused
end

function AnimatedImage:setFrame(frame)
	self.loop.frame = frame
end

function AnimatedImage:getFrame()
	return self.loop.frame
end

function AnimatedImage:getImage()
	return self.image_table:getImage(self.loop.frame)
end

function AnimatedImage:setFirstFrame(frame)
	self.loop.startFrame = frame
end

function AnimatedImage:setLastFrame(frame)
	self.loop.endFrame = frame
end

AnimatedImage.__index = function(animated_image, key)
	local proxy_value = rawget(AnimatedImage, key)
	if proxy_value then
		return proxy_value
	end
	proxy_value = animated_image.image_table:getImage(animated_image.loop.frame)[key]
	if type(proxy_value) == "function" then
		rawset(animated_image, key, function(ai, ...)
			local img = ai.image_table:getImage(ai.loop.frame)
			return img[key](img, ...)
		end)
		return animated_image[key]
	end
	return proxy_value
end
-- source/statemachine.lua--------------------------------------------------
-- based on - https://github.com/kyleconroy/lua-state-machine

class("State").extends()

function State:init() end
function State:onenter(name, from, to, ...) end
function State:onleave(name, from, to, ...) end
function State:update() end


class("Machine").extends()

local function call_handler(handler, params)
  if handler then
    return handler(table.unpack(params))
  end
end

local function create_transition(name)
  local can, to, from, params

  local function transition(self, ...)
    can, to = self:can(name)
    from = self.currentName

    if type(to) == "function" then
      to = to(self, name, from)
    end

    params = { self, name, from, to, ...}

    if not can then return end

    local beforeReturn = call_handler(self["onbefore" .. name], params)
    if beforeReturn == false then return end

    local leaveReturn = self:current():onleave(table.unpack(params))
    if leaveReturn == false then return end

    self.currentName = to

    self:current():onenter(table.unpack(params))

    call_handler(self["onafter" .. name] or self["on" .. name], params)
    call_handler(self["onstatechange"], params)
    call_handler(self["onevent"], params)
  end

  return transition
end

local function add_to_map(map, event)
  if type(event.from) == 'string' then
    map[event.from] = event.to
  else
    for _, from in ipairs(event.from) do
      map[from] = event.to
    end
  end
end

function Machine:init(options)
  options = options or {}
  self.options = options
  self.currentName = options.initial or 'none'
  self.events = {}

  for _, event in ipairs(options.events or {}) do
    self:addEvent(event)
  end
  
  for name, callback in pairs(options.callbacks or {}) do
    self:addCallback(callback)
  end

  self.states = options.states or {}
end

function Machine:addEvent(event)
  local name = event.name
  self[name] = self[name] or create_transition(name)
  self.events[name] = self.events[name] or { map = {} }
  add_to_map(self.events[name].map, event)
end

function Machine:addCallback(name, callback)
  self[name] = callback
end

function Machine:addState(name, state)
  self.states[name] = state
  if self.currentName == 'none' then
    self.currentName = name
  end
end

function Machine:current()
  return self.states[self.currentName]
end

function Machine:is(state)
  return self.currentName == state
end

function Machine:can(e)
  local event = self.events[e]
  local to = event and event.map[self.currentName] or event.map['*']
  return to ~= nil, to
end

function Machine:cannot(e)
  return not self:can(e)
end

function Machine:get(name)
  return self.states[name]
end

-- source/utils.lua--------------------------------------------------
function table.each( t, fn )
	if not fn then return end

	for _, e in pairs(t) do
		fn(e)
	end
end

function math.sign(n)
	if n > 0 then
		return 1
	elseif n < 0 then
		return -1
	end

	return 0
end

function math.clamp(a, min, max)
	if min > max then
		min, max = max, min
	end
	return math.max(min, math.min(max, a))
end

-- source/enum.lua--------------------------------------------------
Group = {
  actor=32,
  solid=31,
  trigger=30,
}

Side = {
  top=0x1000,
  bottom=0x0100,
  left=0x0010,
  right=0x0001,
}
-- source/inputHandlers.lua--------------------------------------------------
class("InputHandler").extends()

function InputHandler:init()
  self._jump_last_pressed = 0
  self._left = false
  self._right = false
  self.dx = 0
  self.jump = false
  self.jump_pressed = false
  self.jump_buffered = false
end

function InputHandler:update(buttons, actor)
  self._left=playdate.buttonIsPressed(buttons.left)
  self._right=playdate.buttonIsPressed(buttons.right)
  self.jump=playdate.buttonIsPressed(buttons.jump)
  self.jump_pressed=playdate.buttonJustPressed(buttons.jump)

  if self.jump_pressed then
    self._jump_last_pressed = playdate.getCurrentTimeMilliseconds()
  end

  local time_since_jump = playdate.getCurrentTimeMilliseconds() - self._jump_last_pressed
  self.jump_buffered = time_since_jump < actor.jump_buffer_time

  self.dx = (self._right and 1 or 0) - (self._left and 1 or 0)
end

-- source/actor.lua--------------------------------------------------
class("Actor").extends(playdate.graphics.sprite)

function Actor:init()
	Actor.super.init(self)
	self:add()
end

function Actor:destroy()
	self:remove()
end
-- source/solid.lua--------------------------------------------------
class("Solid").extends(Actor)

function Solid:init()
  Solid.super.init(self)
  self.mask = 0x1111
  self:setGroups({Group.solid})
end

function Solid:isSolid()
  return self.mask == 0x1111
end

function Solid:setSidePassthrough(side, passable)
  if passable then
    self.mask = self.mask & ~side
  else
    self.mask = self.mask | side
  end
end

function Solid:getSidePassthrough(side)
  return (self.mask & side) == 0
end

function Solid:stops(actor, col)
  if self:isSolid() then return true end

  -- only check on first frame of overlap
  if col.overlaps then return false end

  local x, y = col.normal.x, col.normal.y
  return (
    (x > 0 and not self:getSidePassthrough(Side.right) ) or
    (x < 0 and not self:getSidePassthrough(Side.left)) or
    (y > 0 and not self:getSidePassthrough(Side.bottom)) or
    (y < 0 and not self:getSidePassthrough(Side.top))
  )
end

function Solid:resolveCollision(actor, col)
  -- if fully solid let bump handle it
  if self:isSolid() then return end

  local bx, by, bw, bh = actor:getCollideBounds()
  local ax, ay, aw, ah = actor:getBounds()
  local tx, ty = col.touch.x, col.touch.y
  local cx, cy = self:getCenter()

  local horiz = col.normal.x == 0 and 0 or 1
  local vert = col.normal.y == 0 and 0 or 1

  actor:moveBy((tx-ax-bx-(self.width*cx))*horiz, (ty-ay-by-(self.height*cy))*vert)
end


function Solid.addEmptyCollisionSprite(x, y, w, h)
  local solid = Solid()
  solid:setSize(w, h)
  solid:setCenter(0,0)
  solid:moveTo(x, y)
  solid:setCollideRect(0,0,w,h)
  solid:setVisible(false)
  solid:setUpdatesEnabled(false)
  return solid
end
-- source/trigger.lua--------------------------------------------------
class("Trigger").extends(Actor)

function Trigger:init()
  Trigger.super.init(self)
  self:setGroups({Group.trigger})
end


function Trigger:perform(actor, col) end

-- source/basePlatformer.lua--------------------------------------------------
class("BasePlatformer").extends(Actor)

local deltaTime <const> = 1 / playdate.display.getRefreshRate()

function BasePlatformer:init()
  BasePlatformer.super.init(self)
  
  self:setCollideRect(0,0, 32, 32)
  self:setGroups({Group.actor})
  self:setCollidesWithGroups({
    Group.solid, Group.trigger
  })

  -- state machine
  self.sm = Machine()

  -- input handler
  self.inputs = InputHandler()

  -- init state
  self._image_flip = playdate.graphics.kImageUnflipped
  self._acc = 0
  self._jump_count = 0
  self.dx = 0
  self.dy = 0
  self.buttons = {}
  
end

function BasePlatformer:update()
  self.inputs:update(self.buttons, self)
  self.sm:current():update(self.inputs)
  self:move()
  self:updateImageFlip()
end

function BasePlatformer:updateImageFlip()
  -- set image flip
  if self.dx < 0 then
    self._image_flip = playdate.graphics.kImageFlippedX
  elseif self.dx > 0 then
    self._image_flip = playdate.graphics.kImageUnflipped
  end
  self:setImageFlip(self._image_flip)
end

function BasePlatformer:collisionResponse(other)
  if other:isa(Solid) and other:isSolid() then
    return playdate.graphics.sprite.kCollisionTypeSlide
  else
    return playdate.graphics.sprite.kCollisionTypeOverlap
  end
end

function BasePlatformer:move()
  local tx = self.x+(self.dx * deltaTime)
  local ty = self.y+(self.dy * deltaTime)
  local ax, ay, cols, l = self:moveWithCollisions(tx, ty)
  table.each(cols, function(c)
    if c.other:isa(Solid) and c.other:stops(self, c) then
      c.other:resolveCollision(self, c)
    elseif c.other:isa(Trigger) then
      c.other:perform(self, c)
    end
  end)
  self.sm:current():aftermove(cols, l, tx, ty)
  self:aftermove(cols, l, tx, ty)
end

function BasePlatformer:aftermove(cols, l, tx, ty) end

-- source/defaultPlatformer.lua--------------------------------------------------
function defaultLandEvent(sm)
  if sm:current().actor.dx == 0 then
    return 'idle'
  else
    return 'run'
  end
end

function defaultOnLandCallback(sm)
  sm:current().actor._jump_count = 0
end

function defaultOnBeforeFallCallback(sm)
  if sm:current():isa(GroundState) then
    sm:current().actor._jump_count = 1
  end
end

function defaultOnBeforeJumpCallback(sm)
  local actor = sm:current().actor
  actor._jump_count += 1
  return actor._jump_count <= actor.jump_count_max
end

class("DefaultPlatformer").extends(BasePlatformer)

function DefaultPlatformer:init(images, options)
  assert(images.idle, "pp-lib error - Images for 'idle' not found")
  assert(images.run, "pp-lib error - Images for 'run' not found")
  assert(images.jump, "pp-lib error - Images for 'jump' not found")
  assert(images.fall, "pp-lib error - Images for 'fall' not found")
  options = options or {}

  DefaultPlatformer.super.init(self)

  self.buttons = {
    left=playdate.kButtonLeft,
    right=playdate.kButtonRight,
    jump=playdate.kButtonA
  }

  local machine = self.sm
  machine:addState("idle", IdleState(self, images.idle, options.idle))
  machine:addState("run", RunState(self, images.run, options.run))
  machine:addState("jump", JumpState(self, images.jump, options.jump))
  machine:addState("fall", FallState(self, images.fall, options.fall))

  machine:addEvent({name='run', from='*', to='run'})
  machine:addEvent({name='stop', from='run', to='idle'})
  machine:addEvent({name='jump', from='*', to='jump'})
  machine:addEvent({name='fall', from='*', to='fall'})
  machine:addEvent({name='land', from='fall', to=defaultLandEvent})

  machine:addCallback('onland', defaultOnLandCallback)
  machine:addCallback('onbeforefall', defaultOnBeforeFallCallback)
  machine:addCallback('onbeforejump', defaultOnBeforeJumpCallback)

  -- properties
  self.has_air_control = true
  self.has_ground_control = true
  self.run_speed_max = 200
  self.run_speed_acc = 20
  self.run_speed_dcc = 40
  self.air_speed_max = 200
  self.air_speed_acc = 20
  self.air_speed_dcc = 4
  self.jump_boost = 400
  self.jump_dcc = 20 --gravity
  self.jump_max_time = 300
  self.jump_min_time = 120
  self.jump_count_max = 1
  self.jump_buffer_time = 300
  self.apex_boost = 10
  self.bump_max = 6
  self.fall_acc = 30
  self.fall_hang_acc = 20
  self.fall_hang_time = 100
  self.fall_max = 400
  self.coyote_time = 120
end
-- source/states/baseState.lua--------------------------------------------------
class("BaseState").extends(State)

function BaseState:init(actor, images, options)
  self.actor = actor
  options = options or {loop=true}
  if images then
    if getmetatable(images) == playdate.graphics.imagetable then
      self.images = AnimatedImage.new(images, options)
      actor:setImage(self.images:getImage())
    elseif getmetatable(images) == playdate.graphics.image then
      self.image = images
      actor:setImage(self.image)
    else
      self.images = images
      actor:setImage(self.images:getImage())
    end
  end
end

function BaseState:onenter(sm, name, from, to)
  if self.images then
    self.images:reset()
  elseif self.image then
    self.actor:setImage(self.image)
  end
end

function BaseState:aftermove(cols, l, tx, ty) end

function BaseState:update()
  if self.images then
    self.actor:setImage(self.images:getImage())
  end
end
-- source/states/groundState.lua--------------------------------------------------
class("GroundState").extends(BaseState)

function GroundState:onenter()
  GroundState.super.onenter(self)
  local actor = self.actor
  actor.dy = 0
  if actor.inputs.jump_buffered then
    actor.sm:jump()
  end
end

function GroundState:update(inputs)
  GroundState.super.update(self)
  local actor = self.actor

  if inputs.jump_pressed then
    actor.sm:jump()
    return
  end
end

function GroundState:aftermove()
  local actor = self.actor
  local _, _, collisions, count = actor:checkCollisions(actor.x, actor.y+1)
  local shouldFall = true
  actor._jump_count = 0

  if count ~= 0 then
    table.each(collisions, function(c)
      if c.other:isa(Solid)
      and c.normal.y < 0
      and c.other:stops(self, c)
      then
        shouldFall = false
      end
    end)
  end

  if shouldFall then
    actor.sm:fall()
  end
end



-- source/states/airState.lua--------------------------------------------------
class("AirState").extends(BaseState)

function AirState:update(inputs)
  AirState.super.update(self)
  local actor = self.actor
  
  if not actor.has_air_control then return end

  local dx = inputs.dx

  if dx == 0 then
    local sign = math.sign(actor.dx)
    actor.dx -= sign * actor.air_speed_dcc
    if math.abs(actor.dx) < actor.air_speed_dcc then
      actor.dx = 0
    end
  else
    if actor.dx ~= 0 and dx ~= math.sign(actor.dx) then
      -- if going against it's current direction
      -- also add deceleration
      actor.dx += dx * actor.air_speed_dcc
    end
    actor.dx += inputs.dx * actor.air_speed_acc
    actor.dx = math.clamp(actor.dx, actor.air_speed_max, -actor.air_speed_max)
  end


  if inputs.jump_pressed then
    actor.sm:jump()
  end

  -- set image flip
  if inputs.dx < 0 then
    actor:setImageFlip(playdate.graphics.kImageFlippedX)
  elseif inputs.dx > 0 then
    actor:setImageFlip(playdate.graphics.kImageUnflipped)
  end
end

function AirState:aftermove(cols, l)
  if l == 0 then return end
  table.each(cols, function(c)
    if c.other:isa(Solid)
    and c.normal.x ~= 0
    then
      self.actor.dx = 0
    end
  end)
end
-- source/states/idleState.lua--------------------------------------------------
class("IdleState").extends(GroundState)

function IdleState:update(inputs)
  IdleState.super.update(self, inputs)
  local actor = self.actor

  if actor.dx ~= 0 then
    local sign = math.sign(actor.dx)
    actor.dx -= sign * actor.run_speed_dcc
    if math.abs(actor.dx) < actor.run_speed_dcc then
      actor.dx = 0
    end
  end

  if not actor.has_ground_control then return end

  if inputs.dx ~= 0 then
    self.actor.sm:run()
  end
end
-- source/states/runState.lua--------------------------------------------------
class("RunState").extends(GroundState)

function RunState:update(inputs)
  RunState.super.update(self, inputs)
  local actor = self.actor
  local dx = inputs.dx

  if dx == 0 then
    actor.sm:stop()
  else
    if actor.dx ~= 0 and dx ~= math.sign(actor.dx) then
      -- if going against it's current direction
      -- also add deceleration
      actor.dx += dx * actor.run_speed_dcc
    end
    actor.dx += dx * actor.run_speed_acc
    actor.dx = math.clamp(actor.dx, actor.run_speed_max, -actor.run_speed_max)
  end
end
-- source/states/jumpState.lua--------------------------------------------------
class("JumpState").extends(AirState)

function JumpState:onenter()
  JumpState.super.onenter(self)
  self.actor.dy = -(self.actor.jump_boost)
  self.jump_start = playdate.getCurrentTimeMilliseconds()
end

function JumpState:update(inputs)
  JumpState.super.update(self, inputs)

  local actor = self.actor
  local jump_time = playdate.getCurrentTimeMilliseconds() - self.jump_start
  local min_jump_reached = jump_time > actor.jump_min_time
  local max_jump_reached = jump_time > actor.jump_max_time

  actor.dy = actor.dy + actor.jump_dcc

  if (actor.dy + actor.jump_dcc > 0) -- reached apex
  or (min_jump_reached and not inputs.jump)
  or max_jump_reached
  then
    actor.sm:fall(actor.apex_boost)
  end
end

function JumpState:aftermove(cols, l, tx, ty)
  JumpState.super.aftermove(self, cols, l, tx, ty)
  local actor = self.actor
  if l ~= 0 then
    table.each(cols, function(c)
      if c.other:isa(Solid)
      and c.other:stops(actor, c)
      then
        if c.normal.y > 0 then
          -- bump
          local bump = self:bump(actor, c.other, tx, ty)
          if bump == 0 then
            actor.sm:fall(actor.apex_boost)
          else
            actor:moveTo(tx+bump, ty)
          end
        end
      end
    end)
  end
end

function JumpState:bump(actor, solid, tx, ty)
  local scbx, _, scbw, _ = solid:getCollideBounds()
  local sbx, _, sbw, _ = solid:getBounds()
  local acbx, _, acbw, _ = actor:getCollideBounds()
  local abx, _, abw, _ = actor:getBounds()

  -- solid left - actor right
  local bump = (sbx+scbx)-(abx+acbx+acbw)
  if math.abs(bump) <= actor.bump_max then
    return bump
  end

  -- solid right - actor left
  bump = (sbx+scbx+scbw)-(abx+acbx)
  if math.abs(bump) <= actor.bump_max then
    return bump
  end

  return 0
end

-- source/states/fallState.lua--------------------------------------------------
class("FallState").extends(AirState)

function FallState:onenter(_, _, from, _, init_dy)
  FallState.super.onenter(self)
  local actor = self.actor
  actor.dy = init_dy or 0
  self.fall_start = playdate.getCurrentTimeMilliseconds()

  local from_state = actor.sm:get(from)
  if from_state:isa(GroundState) then
    self.coyote_time = actor.coyote_time
  else
    self.coyote_time = 0
  end
end

function FallState:update(inputs)
  FallState.super.update(self, inputs)
  local actor = self.actor

  -- coyote time
  local fall_time = playdate.getCurrentTimeMilliseconds() - self.fall_start
  if fall_time < self.coyote_time and inputs.jump then
    actor._jump_count = 0
    actor.sm:jump()
  end

  if fall_time < actor.fall_hang_time then
    actor.dy += actor.fall_hang_acc
  else
    actor.dy += actor.fall_acc
  end
  actor.dy = math.min(actor.dy, actor.fall_max)
end

function FallState:aftermove(cols, l, tx, ty)
  FallState.super.aftermove(self, cols, l, tx, ty)
  local actor = self.actor
  if l ~= 0 then
    table.each(cols, function(c)
      if c.other:isa(Solid) and c.other:stops(actor, c) then
        if c.normal.y < 0 then
          actor.sm:land()
        end
      end
    end)
  end
end

