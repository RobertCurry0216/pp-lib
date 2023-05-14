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