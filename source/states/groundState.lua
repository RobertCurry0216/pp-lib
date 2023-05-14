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


