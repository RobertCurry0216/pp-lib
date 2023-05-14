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