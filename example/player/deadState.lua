class("DeadState").extends(BaseState)

function DeadState:init(actor)
  DeadState.super.init(self, actor, _image_player_die, {loop=false})
end

function DeadState:onenter(...)
  DeadState.super.onenter(self, ...)
  self.actor.dx = 0
end

function DeadState:update()
  DeadState.super.update(self)
  if playdate.buttonJustPressed(playdate.kButtonB) then
    self.actor.sm:respawn()
  end
end
