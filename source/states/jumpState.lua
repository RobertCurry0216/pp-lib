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
