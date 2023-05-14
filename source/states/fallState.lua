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
