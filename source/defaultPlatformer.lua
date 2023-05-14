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

function DefaultPlatformer:init(images, options, handler)
  assert(images.idle, "pp-engine error - Images for 'idle' not found")
  assert(images.run, "pp-engine error - Images for 'run' not found")
  assert(images.jump, "pp-engine error - Images for 'jump' not found")
  assert(images.fall, "pp-engine error - Images for 'fall' not found")
  options = options or {}

  DefaultPlatformer.super.init(self)

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

  -- inputs
  self.inputs = handler and handler(self) or InputDPadAndA(self)
end