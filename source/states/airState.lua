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