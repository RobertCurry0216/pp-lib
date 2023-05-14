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

function InputHandler:update(actor, buttons)
  self._left=playdate.buttonIsPressed(buttons.left)
  self._right=playdate.buttonIsPressed(buttons.right)
  self.jump=playdate.buttonIsPressed(buttons.jump)
  self.jump_pressed=playdate.buttonJustPressed(buttons.jump)

  if self.jump_pressed then
    self._jump_last_pressed = playdate.getCurrentTimeMilliseconds()
  end

  local time_since_jump = playdate.getCurrentTimeMilliseconds() - self._jump_last_pressed
  self.jump_buffered = time_since_jump < (actor.jump_buffer_time or 0)

  self.dx = (self._right and 1 or 0) - (self._left and 1 or 0)
end
