class("HoverState").extends(AirState)

local hover_speed <const> = -30

function HoverState:init(actor)
  HoverState.super.init(self, actor, _image_player_jump[1])
end

function HoverState:update(inputs)
  HoverState.super.update(self, inputs)

  self.actor.dy = hover_speed

  if not inputs.jump then
    self.actor.sm:fall()
  end
end
